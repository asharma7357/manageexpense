prompt
prompt Creating package PKG_PART_MGR
prompt =============================
prompt
create or replace package pkg_part_mgr AUTHID CURRENT_USER as

---------
-----------------------------------------------------------------------
---                                                                          ---
---  Copyright © 2005-2006 Agilis International, Inc.  All rights reserved.  ---
---                                                                          ---
--- These scripts/source code and the contents of these files are protected  ---
--- by copyright law and International treaties.  Unauthorized reproduction  ---
--- or distribution of the scripts/source code or any portion of these       ---
--- files, may result in severe civil and criminal penalties, and will be    ---
--- prosecuted to the maximum extent possible under the law.                 ---
---                                                                          ---
--------------------------------------------------------------------------------

	--Sanjay Almiya: June 2005

	--Modified: 7th June 2006
	-- Fix for tablespace names with non numeric partition names suffix.

	--Modified: 20 June 2006
	-- Removed dependency from pkg_util.exec_sql, use execute immediate instead

	procedure analyze_table(
		pv_table_name in varchar2 default null,
		pv_part_name in varchar2 default null);

	procedure manage_partitions;

	procedure run_part_mgr;/*(
		pv_jb_number jobs.jb_number%type);*/

	--This function returns version information for this package
	function get_version return varchar2;

end pkg_part_mgr;
/
create or replace package body pkg_part_mgr as

	mv_jb_number jobs.jb_number%type;-- := 8;
	mv_jb_name jobs.jb_name%type := 'Partition Manager';
	mv_thread_id jobs.jb_thread_id%type;
	mv_run_number job_log.jl_run_number%type;
	mv_run_start_dt date;

	procedure log_msg(
		pv_module in varchar2,
		pv_msg in varchar2)	is
	begin
		pkg_util.log_msg(mv_jb_number,mv_thread_id,mv_run_number,' fms.pkg_part_mgr.'||pv_module,pv_msg);
	exception
		when others then null;
	end log_msg;

	--returns the index tablespace for corresponding data tablespace
	function get_index_tbsp(
		lv_data_tbsp in varchar2) return varchar2 is

		lv_d_pos number(10);
		lv_idx_tbsp varchar2(100) := null;
	begin
		--first identify the position of 'D' in tablespace name
		lv_d_pos := instr(upper(trim(lv_data_tbsp)),'D',-1);
		if lv_d_pos>=0 then
			if pkg_util.is_numeric(substr(lv_data_tbsp,lv_d_pos+1)) then
				lv_idx_tbsp := substr(lv_data_tbsp,1,lv_d_pos-1)||'I'||substr(lv_data_tbsp,lv_d_pos+1);
			end if;
		end if;
		return lv_idx_tbsp;
	end;


	--This function will try to identify if the last two digits
	--of the tablespace name are numeric then will attempt to find the
	--next tablespace name in the sequence (based on max_tbsp_num).
	--If however then tablespace name has non numeric suffix then
	--The same tablespace name is returned

	--TODO: verify if the new partition tablespace exists,
	-- if not , use the old one
	function get_next_tbsp_name(
		pr_part_status partition_settings%rowtype) return varchar2 is

		lv_tbsp_digits number(10);
		lv_tbsp_len number(10);
		lv_curr_num number(10);
		lv_new_num number(10);
		lv_new_tbsp partition_settings.next_tbsp%type;
	begin

		lv_tbsp_digits := length(to_char(pr_part_status.max_tbsp_num));
		lv_tbsp_len := length(pr_part_status.next_tbsp);

		lv_curr_num := substr(pr_part_status.next_tbsp,(lv_tbsp_len-lv_tbsp_digits+1));
		lv_new_num := lv_curr_num+1;

		if lv_new_num > pr_part_status.max_tbsp_num then
			lv_new_num := pr_part_status.min_tbsp_num;
		end if;
		if lv_new_num < pr_part_status.min_tbsp_num then
			lv_new_num := pr_part_status.min_tbsp_num;
		end if;

		lv_new_tbsp := substr(pr_part_status.next_tbsp,1,(lv_tbsp_len-lv_tbsp_digits));
		lv_new_tbsp := lv_new_tbsp||lpad(to_char(lv_new_num),lv_tbsp_digits,'0');
		return lv_new_tbsp;
	exception
		when value_error then
			return pr_part_status.curr_tbsp;
		when others then
			log_msg('create_partition',sqlerrm);
			commit;
	end;

	--rebuild global indexes on the given table
	procedure rebuild_global_indexes(
		lv_table_name in varchar2) is

		cursor non_part_ind_cur is
		select index_name
		from user_indexes
		where table_name = upper(trim(lv_table_name))
		and partitioned = 'NO';
	begin
		for i in non_part_ind_cur loop
			execute immediate ' alter index ' ||  i.index_name || ' rebuild ';
		end loop;
	end;

	--rebuild indexes on a newly added partition to assign them
	--correct index tablespace and storage parameters
	procedure rebuild_part_idx(
		pr_part_setting in out partition_settings%rowtype,
		pv_part_name in varchar2) is

		lv_indx_tbsp varchar2(100);
		lv_sql_stmt varchar2(1000);
		lv_idx_initial number(10);

		cursor ind_cur is
		select
			a.index_name, a.tablespace_name
		from
			user_ind_partitions a,
			user_indexes b
		where
			a.index_name = b.index_name and
			b.table_name = pr_part_setting.table_name and
			a.partition_name = upper(trim(pv_part_name));
	begin
		lv_indx_tbsp := get_index_tbsp(pr_part_setting.next_tbsp);
		for i in ind_cur loop
			if lv_indx_tbsp is null then --get the current index tablespace
				lv_indx_tbsp := i.tablespace_name;
			end if;
		--	dbms_output.put_line(' the idx  --> ' ||i.index_name);
		--	dbms_output.put_line(' the tbsp --> ' ||i.tablespace_name);
		--	dbms_output.put_line(' newpart_name --> ' ||pv_part_name);

			--initial extent for index
			select
				max(uip.initial_extent)
			into
				lv_idx_initial
			from
				user_ind_partitions uip,
				user_indexes ui
			where
				uip.index_name = i.index_name and
				ui.index_name = i.index_name and
				ui.table_name = upper(trim(pr_part_setting.table_name)) and
				uip.partition_name <> upper(trim(pv_part_name));

			lv_sql_stmt := 'alter index ' ||i.index_name;
			lv_sql_stmt := lv_sql_stmt||' rebuild partition ';
			lv_sql_stmt := lv_sql_stmt||pv_part_name;
			lv_sql_stmt := lv_sql_stmt||' tablespace ';
			lv_sql_stmt := lv_sql_stmt||lv_indx_tbsp;
			lv_sql_stmt := lv_sql_stmt||' storage ( initial ';
			lv_sql_stmt := lv_sql_stmt||lv_idx_initial;
			lv_sql_stmt := lv_sql_stmt||' pctincrease 0)';
			execute immediate lv_sql_stmt;
		end loop;
	end;

	function get_part_name(
		pv_table_name in varchar2,
		pv_part_dt in date) return varchar2 is
	begin
		return pv_table_name||'_'||to_char(pv_part_dt, 'yyyymmddhh24');
	end;

	--add a new partition
	procedure add_partition(
		pr_part_setting in out partition_settings%rowtype,
		pv_part_dt in date,
		pv_initial in number) is

		high_part_exception exception;
		pragma exception_init(high_part_exception, -14074);

		lv_next_tbsp partition_settings.next_tbsp%type;
		lv_next_part partition_settings.next_part%type;
		lv_condition varchar2(1000);
		lv_sql varchar2(1000);
	begin
		--get the tablespace name
		lv_next_tbsp := get_next_tbsp_name(pr_part_setting);
	--	dbms_output.put_line(' The new tablespace name is  :' || lv_next_tbsp);

		lv_next_part := get_part_name(pr_part_setting.table_name,pv_part_dt);
	--	dbms_output.put_line(' The new partition is  :' || lv_next_part);

		lv_condition := to_char(pv_part_dt, 'yyyymmddhh24');
		lv_condition := ' to_date('||''''|| lv_condition;
		lv_condition := lv_condition||''''||',';
		lv_condition := lv_condition||''''||'yyyymmddhh24'||''')';

		lv_sql := 'alter table ' ||
				  pr_part_setting.table_owner||'.'||
				  pr_part_setting.table_name ||
				  ' add partition ' || lv_next_part ||
				  ' values less than (' || lv_condition ||
				  ') tablespace ' || lv_next_tbsp ||
				  ' storage ( initial ' ||
				  to_char(pv_initial) || '' ||
				  --' next ' || to_char(next_extent_kb) || 'K' ||
				  ' pctincrease 0)';

	--	dbms_output.put_line(lv_sql);

		begin
			execute immediate lv_sql;
		exception
			when high_part_exception then
			--	dbms_output.put_line(' At high part exception !! ');
				null;
		end;
		pr_part_setting.last_switch_dt := pr_part_setting.next_switch_dt;
		pr_part_setting.next_switch_dt := pv_part_dt;
		pr_part_setting.curr_part := pr_part_setting.next_part;
		pr_part_setting.next_part := lv_next_part;
		pr_part_setting.curr_tbsp := pr_part_setting.next_tbsp;
		pr_part_setting.next_tbsp := lv_next_tbsp;

		rebuild_part_idx(pr_part_setting,lv_next_part);
		rebuild_global_indexes(pr_part_setting.table_name);


	end;

	--drop partitions older then
	procedure drop_partition(
		pr_part_setting partition_settings%rowtype,
		pv_part_dt in date) is

		lv_limit number(3);
		lv_start_dt date;
		lv_part_name varchar2(100);
		lv_sql_stmt varchar2(1000);

		cursor c1(cv_part_name in varchar2) is
		select
		 *
		from
			user_tab_partitions utp
		where
			utp.table_name = upper(trim(pr_part_setting.table_name)) and
			utp.partition_name <= cv_part_name
		order by
			utp.partition_name ;
	begin
		lv_start_dt := pv_part_dt-pr_part_setting.part_days;
		lv_part_name := get_part_name(pr_part_setting.table_name,lv_start_dt);

		for i in c1(lv_part_name) loop
			select count(*) into lv_limit from user_tab_partitions utp where utp.table_name = upper(trim(pr_part_setting.table_name));
			if lv_limit > 1 then
				lv_sql_stmt := 'alter table ' || pr_part_setting.table_name ||
									  ' drop partition ' || i.partition_name;
				execute immediate lv_sql_stmt;
			end if;
		end loop;
	end;

	procedure create_partition
	(
		lv_table_name in varchar2,
		lv_till_date in date
	)  is



		invalid_part_type exception;
		pragma exception_init(invalid_part_type, -20001);

		resource_busy exception;
		pragma exception_init(resource_busy, -00054);

		lr_part_setting partition_settings%rowtype;

		lv_next_part_dt date;
		lv_tbl_initial number(10);
	begin

	--	dbms_output.put_line('table :' || lv_table_name);
	--	dbms_output.put_line('till_date ' || to_char(lv_till_date, 'yyyymmdd hh24miss'));

		--load partition settings for this table
		select * into lr_part_setting
		from partition_settings
		where upper(table_name) = upper(lv_table_name);

		--identify suitable initial extent size
		select
			max(utp.initial_extent)
		into
			lv_tbl_initial
		from user_tab_partitions utp
		where
			utp.table_name = upper(trim(lv_table_name));

	--	dbms_output.put_line('Initial extent :' || lv_tbl_initial);

		while (lr_part_setting.next_switch_dt < lv_till_date) loop

			pkg_util.update_job(mv_jb_number,mv_thread_id,mv_jb_name,'R','Creating partition:'||to_char(lr_part_setting.next_switch_dt, 'yyyymmdd hh24miss'));

		--	dbms_output.put_line('next_switch ' || to_char(lr_part_setting.next_switch_dt, 'yyyymmdd hh24miss'));

			--Advance to next partition (Partition range is in hours)
			lv_next_part_dt := lr_part_setting.next_switch_dt + (lr_part_setting.part_range / 24);
		--	dbms_output.put_line(' the next part date is ' ||to_char(lv_next_part_dt, 'YYYYMMDDHH24'));

			--drop old partitions
			drop_partition(lr_part_setting, lv_next_part_dt);

			--add new partition
			add_partition(lr_part_setting, lv_next_part_dt,1048576);--lv_tbl_initial);

			-- dbms_output.put_line('next_switch ' || to_char(lr_part_setting.next_switch_dt, 'yyyymmdd hh24miss'));
			-- dbms_output.put_line(' Before updating partition_status ');
			update partition_settings ps
			set
				ps.curr_part = lr_part_setting.curr_part,
				ps.curr_tbsp = lr_part_setting.curr_tbsp,
				ps.next_part = lr_part_setting.next_part,
				ps.next_tbsp = lr_part_setting.next_tbsp,
				ps.last_switch_dt = lr_part_setting.last_switch_dt,
				ps.next_switch_dt = lr_part_setting.next_switch_dt
			where
				upper(ps.table_name) = upper(lv_table_name);
			commit;

		end loop;

	exception
		when others then
			pkg_util.update_job(mv_jb_number,mv_thread_id,mv_jb_name,'E','Error');
			log_msg('create_partition',sqlerrm);
			commit;
	end create_partition;

	procedure manage_partitions is

	begin

		null;

	end manage_partitions;

	procedure analyze_table
	(
		pv_table_name in varchar2 default null,
		pv_part_name in varchar2 default null
	) is

		cursor c1 is
			select table_name
			  from user_tables
			 where table_name not in
				   (select table_name from user_part_tables);

		cursor c2 is
			select
				a.table_name,
				a.partition_name,
				a.last_analyzed,
				b.analyze_method,
				b.analyze_delay
			from
				user_tab_partitions a,
				partition_settings b
			where
				a.table_name = upper(trim(b.table_name(+)))
			order by
				a.table_name, a.partition_name;

	begin
		if pv_table_name is null then
			for c1rec in c1 loop
				analyze_table(c1rec.table_name);
			end loop;

			for c2rec in c2 loop
				analyze_table(c2rec.table_name, c2rec.partition_name);
			end loop;
		else
			if pv_part_name is null then
				execute immediate 'analyze table '||pv_table_name||' compute statistics';
			else
				execute immediate 'analyze table '||pv_table_name||' partition ('||pv_part_name||') compute statistics';
			end if;
		end if;
	exception
		when others then
			null;
	end analyze_table;

	procedure run_part_mgr/*(
		pv_jb_number jobs.jb_number%type)*/ is

		cursor c1
			(cv_user in varchar2) is
			select ps.table_name, ps.next_switch_dt, ps.part_range
			  from partition_settings ps
			where upper(nvl(trim(ps.table_owner),cv_user)) = upper(cv_user);

		lv_switch_date date;
		lv_curr_user varchar2(30);
		lv_status_msg jobs.jb_status_msg%type;

	begin
		-------------Increse the buffersize---------------
		--	dbms_output.enable(1000000);
		--------------------------------------------------

		--initialize
		select
			j.jb_number,
			j.jb_thread_id
		into
			mv_jb_number,
			mv_thread_id
		from
			jobs j
		where
			j.jb_name=mv_jb_name;
		-- mv_jb_number := pv_jb_number;
		-- mv_thread_id := 0;
		pkg_util.update_job(mv_jb_number,mv_thread_id,mv_jb_name,'R','Start: Alert Generator');
		commit;
		mv_run_number := pkg_util.get_run_num(mv_jb_number,mv_thread_id);
		mv_run_start_dt := sysdate;

		--process partitions
		select user into lv_curr_user from dual;
		-- dbms_output.put_line ('at '||mod_name);
		for c1rec in c1(lv_curr_user) loop
			lv_switch_date := c1rec.next_switch_dt;
			lv_switch_date := trunc(lv_switch_date,'hh24');
			while (lv_switch_date <= sysdate + (c1rec.part_range/24)) loop
				-- dbms_output.put_line('calling manage_part With date : ' ||
				--					 to_char(lv_switch_date, 'dd mon yyyy'));
				lv_switch_date := lv_switch_date + (c1rec.part_range/24);
				create_partition(c1rec.table_name, lv_switch_date);
			end loop;
		end loop;

		--finalize
		pkg_util.set_run_num(mv_jb_number, mv_thread_id, mv_run_number);

		lv_status_msg := 'Complete,';

		pkg_util.update_job(mv_jb_number,mv_thread_id,mv_jb_name,'S',lv_status_msg);
		commit;
	exception
		when others then
			pkg_util.update_job(mv_jb_number,mv_thread_id,mv_jb_name,'E','Error');
			log_msg('run_part_mgr',sqlerrm);
			commit;
	end;

	function get_version return varchar2 is
	begin
		--added fix for case insensitive schema user name comparison
		return '2.1.4';
	end;

end pkg_part_mgr;
/


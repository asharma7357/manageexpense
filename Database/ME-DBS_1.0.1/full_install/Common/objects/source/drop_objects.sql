declare
	lv_sql varchar2(1000);
	lv_done boolean := false;
	--fail safe procedure
	procedure exec_sql is
	begin
		--dbms_output.put_line('Executing:'||substr(lv_sql,1,250));
		execute immediate lv_sql;
	exception
		when others then
			--dbms_output.put_line('Error in exec_sql:'||sqlerrm);
			null;
	end;

	procedure break_jobs is
	begin
		for i in (select * from user_jobs) loop
			dbms_job.broken(i.job, true);
			commit;
		end loop;
	end;

	procedure stop_jobs is
		lv1_ctr number(10):= 0;
		lv1_count number(10);
	begin
		while lv_done = false loop
			lv1_ctr := lv1_ctr + 1;
			for i in (select * from user_jobs) loop
				if i.broken='N' then
					dbms_job.broken(i.job, true);
					commit;
				end if;
			end loop;

			select count(*) into lv1_count 
			from dba_jobs_running djr
			where djr.job in (select uj.job from user_jobs uj);
			if lv1_count = 0 then
				lv_done := true;
			end if;

			if lv1_ctr >= 10000 then
				lv_done := true;
			end if;
		end loop;

	end;

	procedure delete_jobs is
	begin
		for i in (select * from user_jobs) loop
			dbms_job.remove(i.job);
			commit;
		end loop;
	end;

	function con_columns
	(
		p_tab in varchar2,
		p_con in varchar2
	) return varchar2 is
		cursor cu_col_cursor is
			select a.column_name
			from user_cons_columns a
			where a.table_name = p_tab
				  and a.constraint_name = p_con
			order by a.position;
		l_result varchar2(1000);
	begin
		for cur_rec in cu_col_cursor loop
			if cu_col_cursor%rowcount = 1 then
				l_result := cur_rec.column_name;
			else
				l_result := l_result || ',' || cur_rec.column_name;
			end if;
		end loop;
		return lower(l_result);
	end;

begin
	--break all jobs
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Set all jobs as broken');
	break_jobs;
	--drop all constraints
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Drop constraints');
	for i in (select * from user_constraints where constraint_type in ('P','R','U')) loop
		if i.constraint_type = 'P' then
			lv_sql := 'alter table ' || lower(i.table_name) || ' drop primary key';
		elsif i.constraint_type = 'R' then
			lv_sql := 'alter table ' || lower(i.table_name) || ' drop constraint ' || lower(i.constraint_name);
		elsif i.constraint_type = 'U' then
			lv_sql := 'alter table ' || lower(i.table_name) || ' drop unique (' || con_columns(i.table_name, i.constraint_name) || ')';
		end if;
		exec_sql;
	end loop;
	--truncate all tables
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Truncate tables');
	for i in (select table_name from user_tables) loop
		lv_sql := 'truncate table ' || i.table_name;
		exec_sql;
	end loop;
	--delete from all tables
	for i in (select table_name from user_tables) loop
		lv_sql := 'delete from ' || i.table_name;
		exec_sql;
		commit;
	end loop;
	--break all jobs
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Break jobs');
	break_jobs;
	--check if jobs are stopped
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Stop jobs');
	stop_jobs;

	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Delete jobs');
	delete_jobs;
	--drop all objects
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Drop objects');
	for i in (select object_type, object_name from user_objects where object_type not like '%PARTITION') loop
	--dbms_output.put_line('');
		if i.object_type = 'TYPE' then
			lv_sql := 'drop ' || i.object_type || ' ' || i.object_name||' force';
		else
			lv_sql := 'drop ' || i.object_type || ' ' || i.object_name;
		end if;
		exec_sql;
	end loop;
	
	--purge recycle bin
	lv_sql := 'purge recyclebin';
	exec_sql;
	--dbms_output.put_line(lpad('-',50,'-'));
	--dbms_output.put_line('Done !');
end;
/

prompt
prompt Creating package PKG_DATA_PURGER
prompt ================================
prompt
create or replace package pkg_data_purger is

	--------------------------------------------------------------------------------
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

	-- Public function and procedure declarations
	procedure run_data_purger(pv_thread_id jobs.jb_thread_id%type := 0);

	--This function returns version information for this package
	function get_version return varchar2;

end pkg_data_purger;
/

prompt
prompt Creating package body PKG_DATA_PURGER
prompt =====================================
prompt
create or replace package body pkg_data_purger is

	--standard variables
	mc_jb_name					constant jobs.jb_name%type := 'Data Purger';
	mr_jobs						jobs%rowtype;
	mv_thread_id				jobs.jb_thread_id%type;
	mv_run_number				job_log.jl_run_number%type;
	mv_run_start_dt				date;

	mv_tot_lg_bck_time			pg_purger_log.lg_bck_time%type := 0;
	mv_tot_lg_bck_record_cnt	pg_purger_log.lg_bck_records_cnt%type := 0;
	mv_tot_prg_time				pg_purger_log.lg_prg_time%type := 0;
	mv_tot_prg_record_cnt		pg_purger_log.lg_prg_records_cnt%type := 0;
	mv_tot_lg_prg_error			pg_purger_log.lg_prg_error%type := NULL;
	mv_cf_table_group			pg_purger_config.cf_table_group%type;
	--mv_trc_counter number(10) := 0;

	function get_status_msg return varchar2 is
		lv_status_msg varchar2(500);
	begin
		--lv_status_msg := 'New:,CDR:'||nvl(mr_fp_gn_log.lg_cdr_count,0)||',Time:'||nvl(mr_fp_gn_log.lg_time_taken,0);
		return '['||lv_status_msg||']';
	end;

	procedure log_msg(
		pv_module	in varchar2,
		pv_msg		in varchar2,
		pv_severity	in number
		) is
	begin
		pkg_util.log_msg(mr_jobs.jb_number,mr_jobs.jb_thread_id,mv_run_number,'pkg_purge_data.'||pv_module,pv_msg||pv_severity);
	exception
		when others then null;
	end log_msg;

	procedure set_job_progress(lv_msg in jobs.jb_status_msg%type) is
	begin
		pkg_job_utils.set_job_status(mr_jobs.jb_number, mr_jobs.jb_thread_id,'R',lv_msg);
		commit;
	end;

	procedure load_settings is
	begin
		--load configuration settings
		NULL;
	end;

	procedure save_settings is
	begin
		null;
	end;


	function get_next_run_date(
		pv_freq			in varchar2,
		pv_interval		in number,
		pv_last_run_dt	in date ) return date is

		lv_run_date date :=null;
	begin
		case
		when (pv_freq = 'D') then
			lv_run_date := pv_last_run_dt + pv_interval;

		when (pv_freq = 'W') then
			lv_run_date := pv_last_run_dt + (7 * pv_interval);

		when (pv_freq = 'H') then
			lv_run_date := pv_last_run_dt + (pv_interval/24);

		when (pv_freq = 'M') then
			lv_run_date := add_months(pv_last_run_dt,pv_interval);
		end case;
		return lv_run_date;
	end;

	procedure reset_purger_log_variable(
		pr_purger_log in out pg_purger_log%rowtype) is
	begin
		pr_purger_log.lg_table_id := NULL;
		pr_purger_log.lg_table_name := NULL;
		pr_purger_log.lg_prg_run_date := NULL;
		pr_purger_log.lg_bck_time := NULL;
		pr_purger_log.lg_bck_records_cnt := NULL;
		pr_purger_log.lg_prg_time := NULL;
		pr_purger_log.lg_prg_records_cnt := NULL;
		pr_purger_log.lg_prg_error := NULL;
	end;

	-- This procedure does updation of purger log details
	procedure update_purger_log(
		pr_purger_log in pg_purger_log%rowtype) is
	begin
		update PG_PURGER_LOG
		set
			LG_TABLE_NAME		= pr_purger_log.lg_table_name,
			LG_PRG_RUN_DATE		= pr_purger_log.lg_prg_run_date,
			LG_BCK_TIME			= pr_purger_log.lg_bck_time,
			LG_BCK_RECORDS_CNT	= pr_purger_log.lg_bck_records_cnt,
			LG_PRG_TIME			= pr_purger_log.lg_prg_time,
			LG_PRG_RECORDS_CNT	= pr_purger_log.lg_prg_records_cnt,
			LG_PRG_ERROR		= pr_purger_log.lg_prg_error
		where
			LG_TABLE_ID			= pr_purger_log.lg_table_id and
			LG_TABLE_GROUP		= pr_purger_log.lg_table_group;

		if sql%rowcount = 0 then
			if(pr_purger_log.lg_table_id is not null) then
			insert into PG_PURGER_LOG(
				LG_TABLE_ID,
				LG_TABLE_GROUP,
				LG_TABLE_NAME,
				LG_PRG_RUN_DATE,
				LG_BCK_TIME,
				LG_BCK_RECORDS_CNT,
				LG_PRG_TIME,
				LG_PRG_RECORDS_CNT,
				LG_PRG_ERROR)
			values
				(pr_purger_log.lg_table_id,
				pr_purger_log.lg_table_group,
				pr_purger_log.lg_table_name,
				pr_purger_log.lg_prg_run_date,
				pr_purger_log.lg_bck_time,
				pr_purger_log.lg_bck_records_cnt,
				pr_purger_log.lg_prg_time,
				pr_purger_log.lg_prg_records_cnt,
				pr_purger_log.lg_prg_error
			 );
			else
			insert into PG_PURGER_LOG(
				LG_TABLE_ID,
				LG_TABLE_GROUP,
				LG_TABLE_NAME,
				LG_PRG_RUN_DATE,
				LG_BCK_TIME,
				LG_BCK_RECORDS_CNT,
				LG_PRG_TIME,
				LG_PRG_RECORDS_CNT,
				LG_PRG_ERROR)
			values
				(0,
				pr_purger_log.lg_table_group,
				'All Tables of group '||mv_cf_table_group,
				sysdate,
				mv_tot_lg_bck_time,
				mv_tot_lg_bck_record_cnt,
				mv_tot_prg_time,
				mv_tot_prg_record_cnt,
				mv_tot_lg_prg_error);
			end if;
		end if;

	end;

	procedure backup_to_table(
		pv_src_table	in varchar2,
		pv_bak_table	in varchar2,
		pv_where_clause	in varchar2) is

		lv_purge_query varchar2(1000);
	begin
		lv_purge_query := 'insert into ' || pv_bak_table ||
								' select * from ' || pv_src_table ||
								' where ' || pv_where_clause;
		execute immediate lv_purge_query;
	end;


	--select tnametabtype from tab
	function generate_sql_for_csv_output(
		pv_table_name	in varchar2,
		pv_where_clause	in varchar2) return varchar2 is

		lv_table_desc	dbms_sql.desc_tab;
		lv_col_id		numeric;
		lv_sql_stmt		varchar2(4000);
		lv_first_col	boolean := true;

		procedure append_col(
			pv1_col in varchar2) is
		begin
			if not lv_first_col then
				-- Append ||','|| before column name
				lv_sql_stmt := lv_sql_stmt || '||' || '''' || ',' || '''' || '||';
			end if;
			lv_sql_stmt := lv_sql_stmt || pv1_col;
		end;

	begin
		lv_sql_stmt := 'select ';
		lv_table_desc := pkg_sqlgen.get_table_desc(pv_table_name);
		for lv_col_id in 1..lv_table_desc.last loop
			--for string values put the data in double quotes
			--for date values the format is yyyymmddhh24miss
			--for number - it stays as it is
			if (lv_col_id != 1) then
			lv_first_col:=false;
			end if;
			if lv_table_desc(lv_col_id).col_type = 1 or lv_table_desc(lv_col_id).col_type = 96 then  --varchar2
				append_col(''''||'"'||''''||'||'||lv_table_desc(lv_col_id).col_name||'||'||''''||'"'||'''');
			elsif lv_table_desc(lv_col_id).col_type = 12 then         --date
				append_col('to_char('||lv_table_desc(lv_col_id).col_name||',''yyyymmddhh24miss'')');
			elsif lv_table_desc(lv_col_id).col_type = 2 then          --number
				append_col('to_char('||lv_table_desc(lv_col_id).col_name||')');
			end if;
		end loop;

		lv_sql_stmt := lv_sql_stmt || ' from ' || pv_table_name||' where '|| pv_where_clause;
		return lv_sql_stmt;
	end;

	--The purpose of this procedure is to take data backup in CSV files.
	procedure backup_to_file(
		pv_src_table	in varchar2,
		pv_where_clause	in varchar2,
		pv_bak_record_cnt	out number) is

		lv_directory	varchar2(1000);
		lv_sql_stmt		varchar2(4000);
		lv_config_file	UTL_FILE.FILE_TYPE;
		lv_file_name	varchar2(50);

		type tv_col_value is table of varchar2(4000);
		lv_col_value tv_col_value;
	begin
		lv_directory:='PURGER_BACKUP_DIR'; -- Actual Path of directory needs to be verified
		pv_bak_record_cnt:=0;

		lv_sql_stmt := generate_sql_for_csv_output(pv_src_table, pv_where_clause);
		--check if file handler is open then close it
		if (utl_file.is_open(lv_config_file)) then
			utl_file.fclose(lv_config_file);
		end if;

		--create file name
		lv_file_name:=pv_src_table||to_char(sysdate,'yyyymmdd')||'.csv' ;

		--Open the file in write mode
		lv_config_file:=utl_file.fopen(lv_directory,lv_file_name,'W');

		execute immediate lv_sql_stmt  bulk collect into lv_col_value ;
		for i in lv_col_value.first..lv_col_value.last
		loop
			utl_file.put_line(lv_config_file,lv_col_value(i));
			pv_bak_record_cnt:=pv_bak_record_cnt + 1;
		end loop;

		--close file
		utl_file.fclose(lv_config_file);

		--exception block
		--remove the already existing file if any having same lv_file_name and close the file handler
		--raise the exception to handle it in calling procedure
		exception
		when others then
		utl_file.fremove(lv_directory,lv_file_name);
		utl_file.fclose(lv_config_file);
		raise;
	end;


	-- Purpose : This procedure is used to delete the rows from table(passed as an argument)
	-- based upon the where clause supplied in parameter
	-- No exception is handled in this block
	procedure purge_table(
		pv_table_name	in varchar2,
		pv_where_clause	in varchar2) is

		lv_purge_query varchar2(4000);
	begin
		lv_purge_query := 'delete from ' || pv_table_name || ' where ' || pv_where_clause;
		execute immediate lv_purge_query;
	end;

	--This procedure is responsible for processing the table (which is part of a group)
	-- as per the follows:
	-- 1. Identify if a backup needs to be taken, and will perform the back (either to file or table)
	-- 2. Purge the data by calling purge_table routine
	-- 3. It will log the stats in record type variable pr_purger_log which is returned to calling routine
	-- Note: It will not update any configuration tables
	-- and it wll not commit any transactions, any errors generated are raised
	procedure process_table(
		pr_tab_config	in pg_purger_config%rowtype,
		pr_purger_log	out pg_purger_log%rowtype) is

	begin

		set_job_progress('Processing(backup stage) table:'||pr_tab_config.cf_table_name);

		pr_purger_log.lg_table_id		:= pr_tab_config.cf_table_id;
		pr_purger_log.lg_table_group	:= pr_tab_config.cf_table_group;
		pr_purger_log.lg_table_name		:= pr_tab_config.cf_table_name;
		pr_purger_log.lg_prg_run_date	:= sysdate;

		--if a backup table is specified, then perform a backup before performing
		--a purge operation
		pr_purger_log.lg_bck_time := dbms_utility.get_time;
		pr_purger_log.lg_bck_records_cnt := 0;
		if (pr_tab_config.cf_prg_bkp_table is not null) then
			backup_to_table(pr_tab_config.cf_table_name, pr_tab_config.cf_prg_bkp_table, pr_tab_config.cf_prg_clause);
			pr_purger_log.lg_bck_records_cnt := sql%rowcount;
		elsif pr_tab_config.cf_prg_bkp_file = 'Y' then
			backup_to_file(pr_tab_config.cf_table_name, pr_tab_config.cf_prg_clause, pr_purger_log.lg_bck_records_cnt);
		end if;
		pr_purger_log.lg_bck_time := dbms_utility.get_time - pr_purger_log.lg_bck_time;

		set_job_progress('Processing(purge stage) table:'||pr_tab_config.cf_table_name);

		--perform the actual purge
		pr_purger_log.lg_prg_time := dbms_utility.get_time;
		purge_table(pr_tab_config.cf_table_name, pr_tab_config.cf_prg_clause);
		pr_purger_log.lg_prg_records_cnt := sql%rowcount;
		pr_purger_log.lg_prg_time := dbms_utility.get_time - pr_purger_log.lg_prg_time;

		--calculate total
		mv_tot_lg_bck_time:=mv_tot_lg_bck_time + pr_purger_log.lg_bck_time;
		mv_tot_lg_bck_record_cnt:= mv_tot_lg_bck_record_cnt + pr_purger_log.lg_bck_records_cnt;
		mv_tot_prg_time:=mv_tot_prg_time + pr_purger_log.lg_prg_time;
		mv_tot_prg_record_cnt:=mv_tot_prg_record_cnt + pr_purger_log.lg_prg_records_cnt;
	exception
		when others then
			rollback;
			pr_purger_log.lg_prg_error := substr(sqlerrm,1, 2500);
			mv_tot_lg_prg_error:=mv_tot_lg_prg_error||pr_purger_log.lg_prg_error;
			log_msg('purge_table',sqlerrm,4);
			commit;
	end;

	--This procedure will perform the following:
	-- 1. For the given group, it will process all the tables in the order
	--    listed in PR_CONFIG table
	-- 2. For each table, the log (and stats) is returned back in record type variable
	--    which is used to update/insert the PR_PURGER_LOG
	-- 3. If the whole group is processed successfully then the transaction is commited
	--    else it will rollback the transaction and log the error
	procedure process_group(
		pv_table_group in pg_purger_config.cf_table_group%type) is

		cursor c_tab_row(pv_grp_id number) is
			select *
			  from pg_purger_config
			 where CF_TABLE_GROUP = pv_table_group
			 order by CF_TABLE_ID DESC;

		lv_next_run_dt date;
		lv_last_run_dt date;
		lr_purger_log  pg_purger_log%rowtype;
	begin
		savepoint s1;
		for cv_tab_data in c_tab_row(pv_table_group) loop
			--reset the variable lr_purger_log of old statistics
			reset_purger_log_variable(lr_purger_log);
			--Purge the current table, and return the statistic back in lr_purger_log
			process_table(cv_tab_data, lr_purger_log);
			--update the purger log table for the current table statistics in lr_purger_log
			update_purger_log(lr_purger_log);
			--identify the last and next run dates
			lv_last_run_dt := cv_tab_data.cf_prg_next_run;
			lv_next_run_dt := get_next_run_date(cv_tab_data.cf_prg_freq, cv_tab_data.cf_prg_intvl, lv_last_run_dt);
		end loop;
		mv_cf_table_group:= pv_table_group;
		--update the purger log table for the table group
		update_purger_log(NULL);
		--update the next and last run dates
		update pg_purger_config pc
		set
			pc.cf_prg_next_run	= lv_next_run_dt
			,pc.cf_prg_last_run	= lv_last_run_dt
		where pc.cf_table_group	= pv_table_group;
		commit;
	exception
		when others then
			rollback to s1;
			log_msg('purge_group',sqlerrm,4);
			log_msg('purge_group','Error while purging group:'||nvl(to_char(pv_table_group),'<<null>>'),4);
			commit;
	end;

	--This procedure is responsible for identifying the group
	--which is earliest due for purging. In one run of the purger
	--Only one group is processed, to avoid very long running purging
	--task. Since the purger job is quite frequent (once every few seconds)
	-- the next group due will be purged in next run
	procedure purge_data is
		lv_table_group  pg_purger_config.cf_table_group%type;
	begin
		--Identify the next group which is due
		select min(cf_table_group)
				into lv_table_group
			from	pg_purger_config
			where	cf_prg_next_run =
						(select min(cf_prg_next_run)
							from pg_purger_config
							where cf_prg_next_run <= mv_run_start_dt);

		process_group(lv_table_group);

	exception
		when no_data_found then
			null;
		when others then
			dbms_output.put_line(sqlcode||sqlerrm);
			log_msg('purge_data',sqlerrm,4);
			commit;
			raise;
	end;

	-- Purpose : Interface to purger process
	procedure run_data_purger(pv_thread_id jobs.jb_thread_id%type) is
	begin
		--initialize
		mv_thread_id := pv_thread_id;
		--get job details
		mr_jobs := pkg_job_utils.get_job_details(mc_jb_name, mv_thread_id);

		mv_run_start_dt := sysdate;
		pkg_job_utils.set_job_status(mr_jobs.jb_number, mr_jobs.jb_thread_id,'R','Start');
		commit;
		mv_run_number := pkg_job_utils.get_run_num(mr_jobs.jb_number,mr_jobs.jb_thread_id);

		--load settings
		load_settings;

		--start processing
		purge_data;

		--save settings
		save_settings;

		--finalize
		pkg_job_utils.set_run_num(mr_jobs.jb_number, mr_jobs.jb_thread_id, mv_run_number);
		pkg_job_utils.set_job_status(mr_jobs.jb_number, mr_jobs.jb_thread_id,'S','Complete'||get_status_msg);
		commit;
	exception
		when others then
			pkg_job_utils.set_job_status(mr_jobs.jb_number, mr_jobs.jb_thread_id,'E','Error');
			log_msg('run_data_purger',sqlerrm,null);
			commit;
	end run_data_purger;

	function get_version return varchar2 is
	begin

		-- Update: 2.1.5 (Tarun Jain)
		-- 29-Mar-2011: Query to get due table group number in purge_data procedure is changed.

		-- Update: 2.1.4 (Vishal Sinha)
		-- 01-Oct-2007

		-- Known limitations/issues at current point:
		-- 1.If there is large string in CG_PRG_CLAUSE of PG_PURGER_CONFIG Table
		--   then ORA-06502: PL/SQL: numeric or value error: character string buffer too small.

		-- Modified the procedure PURGE_TABLE
		-- Modified  the length of Variable lv_purge_query from 1000 to 4000.


		-- Update: 2.1.3 (Chander Kanta)
		-- 28th Mar 2007

		-- Known limitations/issues at current point:
		-- 1. If a purge of a table fails, the backup files which are partially
		--    created for earlier tables in the same group will not be removed.

		-- Dependencies:
		-- 1. PKG_SQLGEN

		-- Added a feature to allow backup's of purged data to file
		-- For this a backup a directory "PURGER_BACKUP_DIR" should exist
		-- Another option is added to take backup
		-- 1. If the CF_PRG_BKP_FILE is set to "Y" the data is first loaded in .CSV file for backup in
		-- 		external directory specified. File Name should be <table_name_YYYYMMDD.csv>
		-- If an exception occurs during loading of data in csv file, current file is permanently
		-- removed from source directory
		-- 2. Provision to maintain log history is also included, by adding a row level trigger in PG_PURGER_LOG

		-- The program flow can be any of the following:
		-- 1. RUN_DATA_PURGER------>>PURGE_DATA------>>PROCESS_GROUP------>>PROCESS_TABLE------>>PURGE_TABLE------>>BACKUP_TO_FILE------>>UPDATE_PURGER_LOG


		-- Author  : SAGNIHOTRI
		-- Created : 12-Apr-06 11:11:54 AM
		-- Modified: 19-Mar-07
		-- Purpose : This package is used to PURGE/DELETE data from tables based upon the where clause
		-- specified in the PG_PURGER_CONFIG table. Only one table group is purged each time this package
		-- is called. The tables that needs purging are purged based upon the values in frequency
		-- and interval column.

		-- It picks up the oldest table group (as in where NEXT_RUN_DATE <= SYSDATE)
		-- and purges the data from tables contained within that group

		-- Two options are available for backup
		-- 1. If the CF_PRG_BKP_TABLE is specified then the data is first loaded in the backup table
		-- 		specified
		-- 2. After backup and data is deleted from the source table

		-- The PG_PURGER_LOG table maintains the number of records deleted and backup. It also maintains
		-- time taken to purge data and time taken for backup if specified in configuration table.
		-- Apart from this information like table name, table group,date of purging and error if occured
		-- is also maintained.

		-- The program flow can be any of the following:
		-- 1. RUN_DATA_PURGER------>>PURGE_DATA------>>PROCESS_GROUP------>>PROCESS_TABLE------>>PURGE_TABLE------>>UPDATE_PURGER_LOG
		-- 2. RUN_DATA_PURGER------>>PURGE_DATA------>>PROCESS_GROUP------>>PROCESS_TABLE------>>PURGE_TABLE------>>BACKUP_TO_TABLE------>>UPDATE_PURGER_LOG


		return '2.1.5';
	end;

end pkg_data_purger;
/

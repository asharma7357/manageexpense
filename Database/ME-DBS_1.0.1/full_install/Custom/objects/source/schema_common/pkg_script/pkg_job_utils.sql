prompt
prompt Creating package PKG_JOB_UTILS
prompt ==============================
prompt
create or replace package pkg_job_utils is

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

	-- Author  : SALMIYA
	-- Created : 2/9/2006 3:22:37 PM
	-- Purpose :

	--return the job record, if it does not exist
	--a new record is created
	function get_job_details(
		pv_jb_name jobs.jb_name%type,
		pv_thread_id jobs.jb_thread_id%type) return jobs%rowtype;

	--This procedure will update the job status in table JOBS
	PROCEDURE set_job_status(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_job_status in jobs.jb_status%type,
		pv_job_status_msg in jobs.jb_status_msg%type);

	--get a new run number (last run number+1)
	FUNCTION get_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type)	return number;

	--update the jobs table and set the last run number
	PROCEDURE set_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_run_number in jobs.jb_last_run_no%type);


	--This function returns version information for this package
	function get_version return varchar2;

end pkg_job_utils;
/

prompt
prompt Creating package body PKG_JOB_UTILS
prompt ===================================
prompt
create or replace package body pkg_job_utils is
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

	--This procedure is used for logging error in the job_log table
	--severity:
	--0=very low
	--1=low (warning)
	--2=medium (tolerable)
	--3=high (requires investigation)
	--4=very high (partially functional)
	--5=critical (component not functional)
	procedure log_msg(
		pv_module in varchar2,
		pv_msg in varchar2,
		pv_severity in number) is
	begin
		pkg_util.log_msg(0,0,0,'job_utils.'||pv_module,pv_msg);
	exception
		when others then null;
	end log_msg;

	function add_new_job(
		pv_jb_name jobs.jb_name%type,
		pv_thread_id jobs.jb_thread_id%type) return jobs%rowtype is
		lr_jobs jobs%rowtype;
	begin
		--get a job number
		--check is a job number is assigned to this job with different thread id
		
		lock table JOBS in exclusive mode;

		select max(j.jb_number) into lr_jobs.jb_number
		from jobs j where j.jb_name = pv_jb_name;

		--get a new number
		/*if lr_jobs.jb_number is null then
			select max(j.jb_number) into lr_jobs.jb_number
			from jobs j;
			lr_jobs.jb_number := nvl(lr_jobs.jb_number,0)+1;
		end if;*/

		/*insert into JOBS(
			jb_number,
			jb_thread_id,
			jb_name,
			jb_type,
			jb_status,
			jb_status_msg,
			jb_status_dt,
			jb_last_run_no)
		values(
			lr_jobs.jb_number,
			pv_thread_id,
			pv_jb_name,
			null,
			'S',
			null,
			sysdate,
			0
		);*/

	 Begin
		insert into JOBS(
			jb_number,
			jb_thread_id,
			jb_name,
			jb_type,
			jb_status,
			jb_status_msg,
			jb_status_dt,
			jb_last_run_no)
		select 
			nvl(lr_jobs.jb_number,nvl(max(jb_number),0)+1),
			pv_thread_id,
			pv_jb_name,
			null,
			'S',
			null,
			sysdate,
			0 
		 from jobs;	
		exception when others then 
			rollback;
			pkg_util.log_msg(0,0,0,'pkg_job_utils.add_new_job',sqlerrm);
		end;

		commit;

		select * into lr_jobs
		from jobs j
		where
			j.jb_name=pv_jb_name and
			j.jb_thread_id=pv_thread_id;

		return lr_jobs;
	end;

	function get_job_details(
		pv_jb_name jobs.jb_name%type,
		pv_thread_id jobs.jb_thread_id%type) return jobs%rowtype is

		lr_jobs jobs%rowtype;
	begin
		select * into lr_jobs
		from jobs j
		where
			j.jb_name=pv_jb_name and
			j.jb_thread_id=pv_thread_id;
			return lr_jobs;
	exception
		when no_data_found then
			--add a new records
			return add_new_job(pv_jb_name, pv_thread_id);
		when too_many_rows then
			--delete all rows except the most recent
			delete from jobs j where
				j.jb_name=pv_jb_name and
				j.jb_thread_id=pv_thread_id and
				j.rowid not in
				(
					select max(j1.rowid) from jobs j1
					where j1.jb_name = pv_jb_name
						and j1.jb_thread_id = pv_thread_id
				);

			--try again
			select * into lr_jobs
			from jobs j
			where
				j.jb_name=pv_jb_name and
				j.jb_thread_id=pv_thread_id;

			return lr_jobs;
	end;

	PROCEDURE set_job_status(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
    	pv_job_status in jobs.jb_status%type,
    	pv_job_status_msg in jobs.jb_status_msg%type) IS

	BEGIN

		update
			jobs j
		set
			j.jb_status = pv_job_status,
			j.jb_status_msg = pv_job_status_msg,
			j.jb_status_dt = sysdate
		where
			j.jb_number = pv_job_num and
			j.jb_thread_id = pv_thread_id;
		commit;

	END set_job_status;

	FUNCTION get_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type)	return number is

		lv_run_num  number := 0;

	begin
		begin
    		select max(j.jb_last_run_no) + 1
    		into lv_run_num
    		from jobs j
    		where jb_number = pv_job_num
    		and jb_thread_id = pv_thread_id;
    	exception
    		when no_data_found then
	    		lv_run_num := 0;
		end;

		if lv_run_num > 99999 then
			lv_run_num := 0;
		end if;

		return lv_run_num;

	end;

	PROCEDURE set_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_run_number in jobs.jb_last_run_no%type) is

	begin

		update
			jobs j
		set
			j.jb_last_run_no = pv_run_number
		where
			j.jb_number = pv_job_num and
			j.jb_thread_id = pv_thread_id;

	end;

	function get_version return varchar2 is
	begin
		-- modified againgst Ticket# 11030 
		return '3.0.5.01';	
	
		--return '2.1.2';
	end;

end pkg_job_utils;
/

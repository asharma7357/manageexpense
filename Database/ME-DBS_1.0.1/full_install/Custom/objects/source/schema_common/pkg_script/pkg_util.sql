prompt
prompt Creating package PKG_UTIL
prompt =========================
prompt
CREATE OR REPLACE PACKAGE pkg_util authid current_user AS

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

	function get_setting(pv_setting_name in varchar2) return number;

	function get_setting_s(pv_setting_name in varchar2) return varchar2;

	function get_setting_d(pv_setting_name in varchar2) return date;

	function is_numeric(pv_value in varchar2) return boolean;

	--return date in 'to_date....' format
	function get_date_str(pv_dt_val in date) return varchar2;

	-- Get/Set Trace Level
	GC_TRC_NONE			CONSTANT PLS_INTEGER := 0;	 -- No trace
	GC_TRC_INIT			CONSTANT PLS_INTEGER := 01;	 -- Trace Configuration values
	GC_TRC_WARNING		CONSTANT PLS_INTEGER := 02;	 -- Warning msgs
	GC_TRC_OPEN			CONSTANT PLS_INTEGER := 04;	 -- Open / Close msgs
	GC_TRC_FLOW			CONSTANT PLS_INTEGER := 08;	 -- Traces internal execution of application.
	GC_TRC_TIME			CONSTANT PLS_INTEGER := 16;	 -- Time
	GC_TRC_DATA			CONSTANT PLS_INTEGER := 32;	 -- Data
	GC_TRC_SQL			CONSTANT PLS_INTEGER := 64;	 -- Trace SQL Information
	GC_TRC_ALL			CONSTANT PLS_INTEGER := 127; -- Trace All Information

	-- set trace level
	procedure trace_level(
		 pv_trace_level in pls_integer);

	-- get trace level, returns null if trace level is not set
	function trace_level return pls_integer;

	-- log trace messages
	procedure log_trc(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in varchar2,
		pv_trc_level in pls_integer default GC_TRC_ALL);

	GC_ERR_WARN			CONSTANT PLS_INTEGER := 0;	-- Warnings
	GC_ERR_MINOR		CONSTANT PLS_INTEGER := 1;	-- Minor
	GC_ERR_MAJOR		CONSTANT PLS_INTEGER := 5;	-- Major
	GC_ERR_CRITICAL		CONSTANT PLS_INTEGER := 9;	-- Critical

	-- log error message
	procedure log_err(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in varchar2,
		pv_err_sev in pls_integer default GC_ERR_CRITICAL,
		pv_upd in boolean default false);

	--Note: the function log_msg is deprecated. Use the updated routines
	--mentioned above
	procedure log_msg(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in job_log.jl_msg%type,
		pv_user_msg in varchar2 default null,
		pv_upd in boolean default false);

	procedure update_job(
		pv_job_num in number,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_job_name in jobs.jb_name%type,
		pv_job_status in jobs.jb_status%type,
		pv_job_status_msg in jobs.jb_status_msg%type);

	function get_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type) return number;

	procedure set_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_run_number in jobs.jb_last_run_no%type);

	-- Set the consunmer resource group.
	-- The following CRG are defined
	-- REAL_TIME
	-- HIGH_PRIORITY
	-- NORMAL
	-- LOW
	-- VERY_LOW
	procedure set_crg(pv_crg_name in varchar2);

	procedure html_email(
		p_to in varchar2,
		p_from in varchar2,
		p_subject in varchar2,
		p_text in varchar2 default null,
		p_html in varchar2 default null,
		p_smtp_hostname in varchar2,
		p_smtp_portnum in varchar2);

	procedure html_email(
		p_to in varchar2,
		p_from in varchar2,
		p_subject in varchar2,
		p_text in varchar2 default null,
		p_html in clob default null,
		p_smtp_hostname in varchar2,
		p_smtp_portnum in varchar2,
		p_login_user in varchar2 default null,
		p_login_pwd in varchar2 default null);

	-- added by Lalit Kalra	on 28th Sep 07
	-- to send email in text format	
   	procedure text_email(
        p_to            in varchar2,
        p_from          in varchar2,
        p_subject       in varchar2,
        p_text          in varchar2 default null,
        p_html          in clob default null,
        p_smtp_hostname in varchar2,
        p_smtp_portnum  in varchar2,
		p_login_user    in varchar2 default null,
        p_login_pwd     in varchar2 default null);

	--This function returns version information for this package
	function get_version return varchar2;

end pkg_util;
/
create or replace package body pkg_util as

	function get_setting(pv_setting_name in varchar2) return number is
		lv_value number;
	begin
		select /*+ result_cache */value
		into lv_value
		from db_settings s
		where upper(s.setting_name) = upper(pv_setting_name);

		return lv_value;
	exception
		when others then
			return - 1;
	end;

	function get_setting_s(pv_setting_name in varchar2) return varchar2 is
		lv_value db_settings.value%type;
	begin
		select /*+ result_cache */value
		into lv_value
		from db_settings s
		where upper(s.setting_name) = upper(pv_setting_name);

		return lv_value;
	exception
		when others then
			return null;
	end;

	function get_setting_d(pv_setting_name in varchar2) return date is
		lv_value date;
	begin
		select /*+ result_cache */to_date(value,'yyyymmddhh24miss')
		into lv_value
		from db_settings s
		where upper(s.setting_name) = upper(pv_setting_name);

		return lv_value;
	exception
		when others then
			return null;
	end;

	function is_numeric(pv_value in varchar2) return boolean is
		lv_test number;
	begin
		lv_test := to_number(pv_value);
		return true;
	exception
		when others then
			return false;
	end;

	--return date in 'to_date....' format
	function get_date_str(pv_dt_val in date) return varchar2 is
	begin
		return ' to_date (''' || to_char(pv_dt_val, 'yyyymmddhh24miss') || ''',''yyyymmddhh24miss'') ';
	end;

	-- set trace level
	procedure trace_level(
		 pv_trace_level in pls_integer) is
	begin
		null;
	end;

	-- get trace level, returns null if trace level is not set
	function trace_level return pls_integer is
	begin
		null;
	end;

	-- log trace messages
	procedure log_trc(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in varchar2,
		pv_trc_level in pls_integer default GC_TRC_ALL) is
	begin
		null;
	end;

	procedure log_err(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in varchar2,
		pv_err_sev in pls_integer default GC_ERR_CRITICAL,
		pv_upd in boolean default false) is
	begin
		null;
	end;
	--Log type: 0=errors,1 information, 2=performance statistics,3=debug information

	procedure log_msg(
		pv_job_num in number,
		pv_thread_id in job_log.jb_thread_id%type,
		pv_run_num in job_log.jl_run_number%type,
		pv_module in job_log.jl_module%type,
		pv_msg in job_log.jl_msg%type,
		pv_user_msg in varchar2 default null,
		pv_upd in boolean default false) is

		lv_update_count number := 0;
	begin

		if pv_upd = true then
			update job_log
			set jl_msg       = substr(pv_msg, 0, 2000),
				jl_msg_count = least(jl_msg_count + 1, 99999)
			where jb_number = pv_job_num
				  and jl_msg = pv_msg
				  and jb_thread_id = pv_thread_id
				  and jl_run_number = pv_run_num
				  and jl_module = pv_module;

			lv_update_count := sql%rowcount;

		end if;

		if lv_update_count = 0 or pv_upd = false then
			insert into job_log
				(jb_number,
				 jb_thread_id,
				 jl_run_number,
				 jl_module,
				 jl_log_dt,
				 jl_msg,
				 jl_msg_count)
			values
				(pv_job_num,
				 pv_thread_id,
				 pv_run_num,
				 substr(pv_module, 0, 64),
				 sysdate,
				 substr(pv_msg, 0, 2000),
				 1);
		end if;

		commit;

	end log_msg;

	procedure update_job(
		pv_job_num in number,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_job_name in jobs.jb_name%type,
		pv_job_status in jobs.jb_status%type,
		pv_job_status_msg in jobs.jb_status_msg%type) is

	begin

		if pv_job_status = 'R' then

			update jobs
			set jb_status      = pv_job_status,
				jb_last_run_no = decode(jb_last_run_no,
										99999,
										0,
										jb_last_run_no) + 1,
				jb_status_msg  = pv_job_status_msg,
				jb_status_dt   = sysdate
			where jb_number = pv_job_num
				  and jb_thread_id = pv_thread_id;

		else
			update jobs
			set jb_status     = pv_job_status,
				jb_status_msg = pv_job_status_msg,
				jb_status_dt  = sysdate
			where jb_number = pv_job_num
				  and jb_thread_id = pv_thread_id;

		end if;

		if sql%rowcount = 0 then

			insert into jobs
				(jb_number,
				 jb_thread_id,
				 jb_name,
				 jb_status,
				 jb_status_msg,
				 jb_status_dt,
				 jb_last_run_no)
			values
				(pv_job_num,
				 pv_thread_id,
				 pv_job_name,
				 pv_job_status,
				 pv_job_status_msg,
				 sysdate,
				 1);

		end if;

		commit;

	end update_job;

	function get_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type) return number is

		lv_run_num number := 0;
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
			when others then
				dbms_output.put_line(sqlcode || ' ' || sqlerrm);
		end;

		if lv_run_num > 99999 then
			lv_run_num := 0;
		end if;

		return lv_run_num;
	end;

	procedure set_run_num(
		pv_job_num in jobs.jb_number%type,
		pv_thread_id in jobs.jb_thread_id%type,
		pv_run_number in jobs.jb_last_run_no%type) is
	begin
		update jobs j
		set j.jb_last_run_no = least(pv_run_number,99999)
		where j.jb_number = pv_job_num
			  and j.jb_thread_id = pv_thread_id;
	end;

	procedure set_crg(pv_crg_name in varchar2) is
	begin
		null;
	end;

	-- PL/SQL procedure to send emails with file attachments
	procedure html_email(
		p_to in varchar2,
		p_from in varchar2,
		p_subject in varchar2,
		p_text in varchar2 default null,
		p_html in varchar2 default null,
		p_smtp_hostname in varchar2,
		p_smtp_portnum in varchar2) is

		lv_clob_html clob;
	begin
		lv_clob_html := p_html;
		html_email(p_to,
				   p_from,
				   p_subject,
				   p_text,
				   lv_clob_html,
				   p_smtp_hostname,
				   p_smtp_portnum);
	end;

	procedure html_email(
		p_to in varchar2,
		p_from in varchar2,
		p_subject in varchar2,
		p_text in varchar2 default null,
		p_html in clob default null,
		p_smtp_hostname in varchar2,
		p_smtp_portnum in varchar2,
		--Almiya: 16th Feb 2006. Added authentication
		p_login_user in varchar2 default null,
		p_login_pwd in varchar2 default null) is

		l_boundary varchar2(255) default 'a1b2c3d4e3f2g1';
		l_connection utl_smtp.connection;
		l_body_html clob := empty_clob; --This LOB will be the email message
		l_offset number;
		l_ammount number;
		l_temp varchar2(32767) default null;
		l_to varchar2(2000);
		n number(3);
		l_tmp varchar2(512);
	begin

		l_connection := utl_smtp.open_connection(p_smtp_hostname, p_smtp_portnum);
		utl_smtp.helo(l_connection, p_smtp_hostname);

		--Almiya: 16th Feb 2006. Added authentication
	/*	utl_smtp.command(l_connection, 'AUTH LOGIN');
		utl_smtp.command(l_connection, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_login_user))));
		utl_smtp.command(l_connection, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_login_pwd))));
	*/
		utl_smtp.mail(l_connection, p_from);
		--Almiya: 19th Nov 2005. Added multiple recipient support and CC'd
		--utl_smtp.rcpt( l_connection, p_to );
		l_to := p_to || ',';
		l_to := replace(l_to, ';', ',');
		loop
			exit when l_to is null;
			n := instr(l_to, ',');
			l_tmp := substr(l_to, 1, n - 1);
			l_to := substr(l_to, n + 1);
			--utl_smtp.rcpt(l_connection, l_tmp);
			--Almiya: 16th Feb 2006. On error resume next
			--utl_smtp.rcpt(l_connection, l_tmp);
			begin
				utl_smtp.rcpt(l_connection, l_tmp);
			exception
				when others then
					--ignore and proceed
					null;
					dbms_output.put_line('error:' || sqlerrm);
			end;
		end loop;

		l_temp := l_temp || 'MIME-Version: 1.0' || chr(13) || chr(10);
		l_temp := l_temp || 'To: ' || p_to || chr(13) || chr(10);
		l_temp := l_temp || 'From: ' || p_from || chr(13) || chr(10);
		l_temp := l_temp || 'Subject: ' || p_subject || chr(13) || chr(10);
		l_temp := l_temp || 'Reply-To: ' || p_from || chr(13) || chr(10);

		--Almiya: 19th Nov 2005. Following fix applied for outlook (added blank line i.e. utl_tcp.CRLF)
		-- See : http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:1739411218448

		--l_temp := l_temp || 'Content-Type: multipart/alternative; boundary=' ||
		--                     chr(34) || l_boundary ||  chr(34) || chr(13) ||
		--                     chr(10);
		l_temp := l_temp || 'Content-Type: multipart/alternative; boundary=' ||
				  chr(34) || l_boundary || chr(34) || chr(13) || chr(10) ||
				  utl_tcp.crlf;

		----------------------------------------------------
		-- Write the headers
		dbms_lob.createtemporary(l_body_html, false, 10);
		dbms_lob.write(l_body_html, length(l_temp), 1, l_temp);

		----------------------------------------------------
		-- Write the text boundary
		l_offset := dbms_lob.getlength(l_body_html) + 1;
		l_temp := '--' || l_boundary || chr(13) || chr(10);
		l_temp := l_temp || 'content-type: text/plain; charset=us-ascii' ||
				  chr(13) || chr(10) || chr(13) || chr(10);
		dbms_lob.write(l_body_html, length(l_temp), l_offset, l_temp);

		----------------------------------------------------
		-- Write the plain text portion of the email
		l_offset := dbms_lob.getlength(l_body_html) + 1;
		dbms_lob.write(l_body_html, length(p_text), l_offset, p_text);

		----------------------------------------------------
		-- Write the HTML boundary
		l_temp := chr(13) || chr(10) || chr(13) || chr(10) || '--' ||
				  l_boundary || chr(13) || chr(10);
		l_temp := l_temp || 'content-type: text/html;' || chr(13) ||
				  chr(10) || chr(13) || chr(10);
		l_offset := dbms_lob.getlength(l_body_html) + 1;
		dbms_lob.write(l_body_html, length(l_temp), l_offset, l_temp);

		----------------------------------------------------
		-- Write the HTML portion of the message
		l_offset := dbms_lob.getlength(l_body_html) + 1;
		dbms_lob.append(l_body_html, p_html);
		-- dbms_lob.write(l_body_html,length(p_html),l_offset,p_html);

		----------------------------------------------------
		-- Write the final html boundary
		l_temp := chr(13) || chr(10) || '--' || l_boundary || '--' ||
				  chr(13);
		l_offset := dbms_lob.getlength(l_body_html) + 1;
		dbms_lob.write(l_body_html, length(l_temp), l_offset, l_temp);

		----------------------------------------------------
		-- Send the email in 1900 byte chunks to UTL_SMTP
		l_offset := 1;
		l_ammount := 1900;
		utl_smtp.open_data(l_connection);
		while l_offset < dbms_lob.getlength(l_body_html) loop
			utl_smtp.write_data(l_connection, dbms_lob.substr(l_body_html, l_ammount, l_offset));
			l_offset := l_offset + l_ammount;
			l_ammount := least(1900, dbms_lob.getlength(l_body_html) - l_ammount);
		end loop;
		utl_smtp.close_data(l_connection);
		utl_smtp.quit(l_connection);
		dbms_lob.freetemporary(l_body_html);
	end;

	procedure text_email(
        p_to            in varchar2,
        p_from          in varchar2,
        p_subject       in varchar2,
        p_text          in varchar2 default null,
        p_html          in clob default null,
        p_smtp_hostname in varchar2,
        p_smtp_portnum  in varchar2,
		--Almiya: 16th Feb 2006. Added authentication
        p_login_user    in varchar2 default null,
        p_login_pwd     in varchar2 default null) is

        l_boundary      varchar2(255) default 'a1b2c3d4e3f2g1';
        l_connection    utl_smtp.connection;
        l_body_html     clob := empty_clob;  --This LOB will be the email message
        l_offset        number;
        l_ammount       number;
        l_temp          varchar2(32767) default null;
        l_to            varchar2(2000);
        n               number(3);
        l_tmp           varchar2(512);
    begin

        l_connection := utl_smtp.open_connection( p_smtp_hostname, p_smtp_portnum );
        utl_smtp.helo( l_connection, p_smtp_hostname );


		/* --Almiya: 16th Feb 2006. Added authentication
        utl_smtp.command(l_connection,'AUTH LOGIN');
        utl_smtp.command(l_connection,
            utl_raw.cast_to_varchar2 (
            utl_encode.base64_encode (
            utl_raw.cast_to_raw (p_login_user))));
        utl_smtp.command(l_connection,
            utl_raw.cast_to_varchar2 (
            utl_encode.base64_encode (
            utl_raw.cast_to_raw (p_login_pwd))));*/

		utl_smtp.mail( l_connection, p_from );
    	--Almiya: 19th Nov 2005. Added multiple recipient support and CC'd
        --utl_smtp.rcpt( l_connection, p_to );
        l_to := p_to || ',';
    	l_to := replace(l_to,';',',');
        loop
            exit when l_to is null;
            n := instr( l_to, ',');
            l_tmp := substr( l_to, 1, n-1 );
            l_to := substr( l_to, n+1 );
            --utl_smtp.rcpt(l_connection, l_tmp);
			--Almiya: 16th Feb 2006. On error resume next
            --utl_smtp.rcpt(l_connection, l_tmp);
            begin
                utl_smtp.rcpt(l_connection, l_tmp);
            exception
                when others then
                    --ignore and proceed
                    null;
                    dbms_output.put_line('error:'||sqlerrm);
            end;
        end loop;


        l_temp := l_temp || 'MIME-Version: 1.0' ||  chr(13) || chr(10);
        l_temp := l_temp || 'To: ' || p_to || chr(13) || chr(10);
        l_temp := l_temp || 'From: ' || p_from || chr(13) || chr(10);
        l_temp := l_temp || 'Subject: ' || p_subject || chr(13) || chr(10);
        l_temp := l_temp || 'Reply-To: ' || p_from ||  chr(13) || chr(10);


    	--Almiya: 19th Nov 2005. Following fix applied for outlook (added blank line i.e. utl_tcp.CRLF)
    	-- See : http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:1739411218448

        --l_temp := l_temp || 'Content-Type: multipart/alternative; boundary=' ||
        --                     chr(34) || l_boundary ||  chr(34) || chr(13) ||
        --                     chr(10);
        l_temp := l_temp || 'Content-Type: multipart/alternative; boundary=' ||
                             chr(34) || l_boundary ||  chr(34) || chr(13) ||
                             chr(10)||utl_tcp.CRLF;


        ----------------------------------------------------
        -- Write the headers
        dbms_lob.createtemporary( l_body_html, false, 10 );
        dbms_lob.write(l_body_html,length(l_temp),1,l_temp);


        ----------------------------------------------------
        -- Write the text boundary
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        l_temp   := '--' || l_boundary || chr(13)||chr(10);
        l_temp   := l_temp || 'content-type: text/plain; charset=us-ascii' ||
                      chr(13) || chr(10) || chr(13) || chr(10);
        dbms_lob.write(l_body_html,length(l_temp),l_offset,l_temp);

        ----------------------------------------------------
        -- Write the plain text portion of the email
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.write(l_body_html,length(p_text),l_offset,p_text);

        ----------------------------------------------------
        -- Write the HTML portion of the message
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.append(l_body_html, p_html);

		----------------------------------------------------
        -- Send the email in 1900 byte chunks to UTL_SMTP
        l_offset  := 1;
        l_ammount := 1900;
        utl_smtp.open_data(l_connection);
        while l_offset < dbms_lob.getlength(l_body_html) loop
            utl_smtp.write_data(l_connection,
                                dbms_lob.substr(l_body_html,l_ammount,l_offset));
            l_offset  := l_offset + l_ammount ;
            l_ammount := least(1900,dbms_lob.getlength(l_body_html) - l_ammount);
        end loop;
        utl_smtp.close_data(l_connection);
        utl_smtp.quit( l_connection );
        dbms_lob.freetemporary(l_body_html);
     END;

	function get_version return varchar2 is
	begin
		--Updated version 2.1.5 on 28/09/2007 (Lalit)
		--Added text_email procedure

		--almiya(27th June 2006): log_msg has severity and type as added paramaters (optional)
		-- added updated routines for logging and trace, including constants
		--Fixed get_settings functions
		-- removed redundant functions like exec_sql, drop_objects
		-- Moved job related routines to PKG_JOB_UTILS
		return '2.1.5';
	end;

end pkg_util;
/


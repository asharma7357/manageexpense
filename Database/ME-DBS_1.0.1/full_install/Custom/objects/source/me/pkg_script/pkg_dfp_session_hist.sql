prompt
prompt Creating package pkg_dfp_session_hist
prompt ==================================
prompt
create or replace package pkg_dfp_session_hist is

	--------------------------------------------------------------------------------
	---                                                                          ---
	---  Copyright © 2016-2021 Agilis International, Inc.  All rights reserved.  ---
	---                                                                          ---
	--- These scripts/source code and the contents of these files are protected  ---
	--- by copyright law and International treaties.  Unauthorized reproduction  ---
	--- or distribution of the scripts/source code or any portion of these       ---
	--- files, may result in severe civil and criminal penalties, and will be    ---
	--- prosecuted to the maximum extent possible under the law.                 ---
	---                                                                          ---
	--------------------------------------------------------------------------------

	--Description: Routine to fetch the Session History Details
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the Session Id.
	--	2) pv_time_frame
	--		parameter mode = IN
	--		description = will accept the Time frame for which the history is to be fetched i.e. 1d,1w,1m,6m,all.
	--	3) pv_rslt_limit
	--		parameter mode = IN
	--		description = will accept the Result Limit i.e. Top N rows.
	--	4) pa_dfp_session_dtl
	--		parameter mode = OUT
	--		description = will store the Session Details.
	--	5) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	6) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance:
	procedure get_session_hist(	pv_session_id in varchar2,
								pv_time_frame in varchar2 default '6m',
								pv_rslt_limit in number,
								pa_dfp_session_dtl out ty_dfp_session_dtl_tab,
								pv_status_cd out number,
								pv_status_msg out varchar2);

	--Description: Routine to fetch the Session History Details in bulk where multiple session id can be passed
	--Parameters:
	--	1) pa_dfp_session_param_tab
	--		parameter mode = IN
	--		description = will accept the Session Id.
	--	2) pa_dfp_session_dtl
	--		parameter mode = OUT
	--		description = will store the Session Details.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance:
	procedure get_session_hist_bulk(	pa_dfp_session_param_tab in ty_dfp_session_param_tab,
										pa_dfp_session_dtl out ty_dfp_session_dtl_tab,
										pv_status_cd out number,
										pv_status_msg out varchar2);
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_session_hist;
/

prompt
prompt Done

prompt
prompt Creating package body pkg_dfp_session_hist
prompt ==================================
prompt

create or replace package body pkg_dfp_session_hist is
	mc_jb_number	constant number := 1;
	mc_pkg_name		constant varchar2(100) := 'pkg_dfp_session_hist';

	procedure log_msg(	pv_module_name in varchar2,
						pv_msg in varchar2) is
	begin
		--TODO: have a standard job number/thread for non-job invoked processes (externally invoked, e.g. from web services and GUI)
		pkg_util.log_msg(mc_jb_number, 1, 0, mc_pkg_name || '.' || pv_module_name, pv_msg);
	end;

	--Description:	Logs the statistics to the DFP_LOG. The DE payload is supplied, and the routine will call
	-- 				pkg_dfp_ext.convert_log_tosqltype to get the sql type which is inserted into the log table
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	TBD
	procedure log_stats(pr_dfp_payload in out nocopy ty_dfp_payload) is
		lr_dfp_log	dfp_log%rowtype;
	begin
		pkg_dfp_ext.convert_log_tosqltype(pr_dfp_payload,lr_dfp_log);
		insert into dfp_log values lr_dfp_log;
		commit;
	exception
		when others then
			log_msg('log_stats', 'Error: '||sqlerrm||' for ref_num: '||nvl(pr_dfp_payload.dfp_log_data.ref_num,'<<null>>'));
	end log_stats;
	
	--Description: Routine to fetch the Session History Details
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the Session Id.
	--	2) pv_time_frame
	--		parameter mode = IN
	--		description = will accept the Time frame for which the history is to be fetched i.e. 1d,1w,1m,6m,all.
	--	3) pv_rslt_limit
	--		parameter mode = IN
	--		description = will accept the Result Limit i.e. Top N rows.
	--	4) pa_dfp_session_dtl
	--		parameter mode = OUT
	--		description = will store the Session Details.
	--	5) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	6) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance:
	procedure get_session_hist(	pv_session_id in varchar2,
								pv_time_frame in varchar2 default '6m',
								pv_rslt_limit in number,
								pa_dfp_session_dtl out ty_dfp_session_dtl_tab,
								pv_status_cd out number,
								pv_status_msg out varchar2)
	is
		lv_time_frame_value	number := substr(lower(pv_time_frame),1,length(pv_time_frame)-1);
		lv_skip_w			number(1) := 0;
		lv_skip_m			number(1) := 0;
		lv_week_rec_cnt		number := 0;
		lv_week_rec_cnt		number := 0;
		
		lv_time_frame_unit	char := substr(lower(pv_time_frame),-1);
		
		lv_master_device_id	varchar2(100 char);
		
		lv_start_dt			date;
		lv_end_dt			date := sysdate;
		
		lv_sql				clob;
	begin
		pv_status_cd := 0;
		pv_status_msg := 'Success';
		
		if lv_time_frame_unit = 'd' then
			lv_start_dt := trunc(sysdate) - lv_time_frame_value;
			lv_skip_w := 1;
			lv_skip_m := 1;
		elsif lv_time_frame_unit = 'w' then
			lv_start_dt := trunc(sysdate) - (7*lv_time_frame_value);
			lv_skip_m := 1;
		elsif lv_time_frame_unit = 'm' then
			lv_start_dt := add_months(trunc(sysdate),-lv_time_frame_value);
		end if;
		
		lv_sql := 'select	master_device_id'||chr(10);
		lv_sql := lv_sql||'from	(	select	master_device_id,'||chr(10);
		lv_sql := lv_sql||'					row_number() over (partition by master_device_id order by rec_dt desc) as seq_id'||chr(10);
		lv_sql := lv_sql||'			from	dfp_idx_pad_t1'||chr(10);
		lv_sql := lv_sql||'			where	session_id = :session_id'||chr(10);
		lv_sql := lv_sql||'		)'||chr(10);
		lv_sql := lv_sql||'where	seq_id = 1';
		
		execute immediate lv_sql into lv_master_device_id;
		
		lv_sql := 'with pad_data as (	select	master_device_id,session_id,rec_dt,user_agent_device_id,user_agent_os_id,user_agent_browser_id'||chr(10);
		lv_sql := lv_sql||'					from	dfp_idx_pad_t1'||chr(10);
		lv_sql := lv_sql||'					where	master_device_id = :master_device_id'||chr(10);
		
		if lv_time_frame_unit <> 'l' then
			lv_sql := lv_sql||'					and		rec_dt between :start_dt and :end_dt'||chr(10);
		end if;
		
		lv_sql := lv_sql||'					group by master_device_id,session_id,rec_dt,user_agent_device_id,user_agent_os_id,user_agent_browser_id'||chr(10);
		lv_sql := lv_sql||'					union all'||chr(10);
		lv_sql := lv_sql||'					select	master_device_id,session_id,rec_dt,user_agent_device_id,user_agent_os_id,user_agent_browser_id'||chr(10);
		lv_sql := lv_sql||'					from	dfp_idx_pad_hist'||chr(10);
		lv_sql := lv_sql||'					where	master_device_id = :master_device_id'||chr(10);
		
		if lv_time_frame_unit <> 'l' then
			lv_sql := lv_sql||'					and		rec_dt between :start_dt and :end_dt'||chr(10);
		end if;
		
		lv_sql := lv_sql||'					group by master_device_id,session_id,rec_dt,user_agent_device_id,user_agent_os_id,user_agent_browser_id'||chr(10);
		lv_sql := lv_sql||'				)'||chr(10);
		lv_sql := lv_sql||'select	ty_dfp_session_dtl(device_type,'||chr(10);
		lv_sql := lv_sql||'		device_os,'||chr(10);
		lv_sql := lv_sql||'		device_browser,'||chr(10);
		lv_sql := lv_sql||'		sum(tot_sess_last_24h) over () as tot_sess_last_24h,'||chr(10);
		lv_sql := lv_sql||'		sum(tot_sess_last_1w) over () as tot_sess_last_1w,'||chr(10);
		lv_sql := lv_sql||'		sum(tot_sess_last_1m) over () as tot_sess_last_1m,'||chr(10);
		lv_sql := lv_sql||'		sum(tot_sess_last_6m) over () as tot_sess_last_6m,'||chr(10);
		lv_sql := lv_sql||'		tot_sess,'||chr(10);
		lv_sql := lv_sql||'		session_id,'||chr(10);
		lv_sql := lv_sql||'		session_dt,null,null,null)'||chr(10);
		lv_sql := lv_sql||'from	(	select	(	select	case'||chr(10);
		lv_sql := lv_sql||'									when user_agent_device is null then ''System'''||chr(10);
		lv_sql := lv_sql||'									when user_agent_device like ''%MOBILE%'' then ''Mobile'''||chr(10);
		lv_sql := lv_sql||'									when user_agent_device like ''%TABLET%'' then ''Tablet'''||chr(10);
		lv_sql := lv_sql||'									else ''N/A'''||chr(10);
		lv_sql := lv_sql||'								end'||chr(10);
		lv_sql := lv_sql||'						from	dim_user_agent_device dim'||chr(10);
		lv_sql := lv_sql||'						where	dim.user_agent_device_id = pad.user_agent_device_id'||chr(10);
		lv_sql := lv_sql||'					) as device_type,'||chr(10);
		lv_sql := lv_sql||'					(	select	user_agent_device_os'||chr(10);
		lv_sql := lv_sql||'						from	dim_user_agent_os dim'||chr(10);
		lv_sql := lv_sql||'						where	dim.user_agent_os_id = pad.user_agent_os_id'||chr(10);
		lv_sql := lv_sql||'					) as device_os,'||chr(10);
		lv_sql := lv_sql||'					(	select	user_agent_browser'||chr(10);
		lv_sql := lv_sql||'						from	dim_user_agent_browser dim'||chr(10);
		lv_sql := lv_sql||'						where	dim.user_agent_browser_id = pad.user_agent_browser_id'||chr(10);
		lv_sql := lv_sql||'					) as device_browser,'||chr(10);
		lv_sql := lv_sql||'					case when rec_dt between trunc(:curr_dt)-1 and :curr_dt then 1 else 0 end as tot_sess_last_24h,'||chr(10);
		lv_sql := lv_sql||'					case when :frame_unit in (''w'',''m'',''l'') and rec_dt between trunc(:curr_dt)-7 and :curr_dt then 1 else 0 end as tot_sess_last_1w,'||chr(10);
		lv_sql := lv_sql||'					case when :frame_unit in (''m'',''l'') and rec_dt between add_months(trunc(:curr_dt),-1) and :curr_dt then 1 else 0 end as tot_sess_last_1m,'||chr(10);
		lv_sql := lv_sql||'					case when :frame_unit in (''m'',''l'') and rec_dt between add_months(trunc(:curr_dt),-6) and :curr_dt then 1 else 0 end as tot_sess_last_6m,'||chr(10);
		lv_sql := lv_sql||'					count(distinct session_id) over () as tot_sess,'||chr(10);
		lv_sql := lv_sql||'					session_id,'||chr(10);
		lv_sql := lv_sql||'					rec_dt as session_dt,'||chr(10);
		lv_sql := lv_sql||'					row_number() over (partition by master_device_id order by rec_dt desc) as seq_id'||chr(10);
		lv_sql := lv_sql||'			from	pad_data'||chr(10);
		lv_sql := lv_sql||'		)'||chr(10);
		lv_sql := lv_sql||'where	seq_id <= :rslt_limit'||chr(10);
		
		if lv_time_frame_unit <> 'l' then
			execute immediate lv_sql bulk collect into pa_dfp_session_dtl using lv_master_device_id,
																				lv_master_device_id,
																				lv_start_dt,lv_end_dt,
																				sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				pv_rslt_limit;
		else
			execute immediate lv_sql bulk collect into pa_dfp_session_dtl using lv_master_device_id,
																				lv_master_device_id,
																				sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				lv_time_frame_unit,sysdate,sysdate,
																				pv_rslt_limit;
		end if;
	exception
		when others then
			pv_status_cd := 1;
			pv_status_msg := substr(sqlerrm,1,300)||'('|| substr(dbms_utility.format_error_backtrace,1,600)||')';
	end get_session_hist;
	
	--Description: Routine to fetch the Session History Details in bulk where multiple session id can be passed
	--Parameters:
	--	1) pa_dfp_session_param_tab
	--		parameter mode = IN
	--		description = will accept the Session Id.
	--	2) pa_dfp_session_dtl
	--		parameter mode = OUT
	--		description = will store the Session Details.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance:
	procedure get_session_hist_bulk(	pa_dfp_session_param_tab in ty_dfp_session_param_tab,
										pa_dfp_session_dtl out ty_dfp_session_dtl_tab,
										pv_status_cd out number,
										pv_status_msg out varchar2)
	is
	begin
		for iParam in 1..pa_dfp_session_param_tab.count loop
			get_session_hist(	pv_session_id => pa_dfp_session_param_tab(iParam).session_id,
								pv_time_frame => pa_dfp_session_param_tab(iParam).time_frame,
								pv_rslt_limit => pa_dfp_session_param_tab(iParam).rslt_limit,
								pa_dfp_session_dtl => pa_dfp_session_dtl,
								pv_status_cd => pv_status_cd,
								pv_status_msg => pv_status_msg);
			if pv_status_cd = 1 then
				exit;
			end if;
		end loop;
	end get_session_hist_bulk;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(07-12-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.0';
	end;

end pkg_dfp_session_hist;
/


prompt
prompt Done

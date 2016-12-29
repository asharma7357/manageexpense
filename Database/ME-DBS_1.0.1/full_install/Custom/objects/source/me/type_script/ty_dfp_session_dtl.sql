prompt
prompt Create type TY_DFP_SESSION_DTL
prompt ==========================
prompt

create type ty_dfp_session_dtl as object(
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
	-- Description:
	-- Type for the DFP Current Session Details
	device_type			varchar2(100 char),
	device_os			varchar2(100 char),
	device_browser		varchar2(100 char),
	tot_sess_last_24h	number,
	tot_sess_last_1w	number,
	tot_sess_last_1m	number,
	tot_sess_last_6m	number,
	tot_sess			number,
	session_id			varchar2(100 char),
	session_dt			date,
	timezone			varchar2(100 char),
	region				varchar2(100 char),
	state				varchar2(100 char)
)
/

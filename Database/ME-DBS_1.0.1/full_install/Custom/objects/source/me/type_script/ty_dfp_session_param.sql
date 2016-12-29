prompt
prompt Create type TY_DFP_SESSION_PARAM
prompt ==========================
prompt

create type ty_dfp_session_param as object(
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
	-- Type for the DFP Session Parameters for which details are to be fetched
	session_id			varchar2(100 char),
	time_frame			varchar2(10 char),
	rslt_limit			number
)
/

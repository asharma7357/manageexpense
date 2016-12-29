prompt ================================
prompt Creating Type TY_DFP_MATCH_DTL
prompt ================================
create type ty_dfp_match_dtl as object(
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

	-- Author		:	Abhishek Sharma
	-- Created		:	04 November 2016
	-- Purpose		:	PlSQL Structure that stores the match details it is created as 
	--					plsql type is so that it can be encapsulated in the DE payload
	
	master_device_id	varchar2(100 char),
	ref_num				varchar2(100 char),
	rec_dt				date,
	tot_score			number
)
/


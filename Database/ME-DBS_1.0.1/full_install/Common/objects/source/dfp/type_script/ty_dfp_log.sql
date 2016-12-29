prompt ================================
prompt Creating Type TY_DFP_LOG
prompt ================================
create type ty_dfp_log as object(
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
	-- Created		:	21 September 2016
	-- Purpose		:	PlSQL Structure that maps to the table DFP_LOG - exactly identical
	--					the reason it is created as plsql type is so that it can be encapsulated
	--					in the DE payload
	
	master_device_id			varchar2(100 char),
	ref_num						varchar2(100 char),
	session_id					varchar2(100 char),
	req_ts						timestamp,
	tot_time					number,
	dim_id_time					number,
	idx_time					number,
	pq_tot_time					number,
	pq_pass_time				varchar2(100 char),
	pq_match_cnt				number,
	fq_eval_cnt					number,
	fq_match_cnt				number,
	fq_tot_time					number,
	fq_eval_time				varchar2(4000 char),
	fq_entropy_fetch_time		number,
	fq_rslt_load_time			number,
	req_load_time				number,
	pad_load_time				number,
	status_cd					number(5),
	status_msg					varchar2(2000 char)
)
/


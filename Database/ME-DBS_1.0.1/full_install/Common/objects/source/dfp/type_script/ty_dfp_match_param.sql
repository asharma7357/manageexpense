prompt ================================
prompt Creating Type TY_DFP_MATCH_PARAM
prompt ================================
create type ty_dfp_match_param is object (
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
	-- Purpose		:	PlSQL Structure that maps to the table DFP_IDX_PAD_T1 for selective columns
	
	master_device_id			varchar2(100 char),
	ref_num						varchar2(100 char),
	session_id					varchar2(100 char),
	rec_type					varchar2(100 char),
	rec_dt						date,
	user_agent_os				varchar2(30 char),
	user_agent_browser			varchar2(50 char),
	user_agent_engine			varchar2(30 char),
	user_agent_device			varchar2(30 char),
	cpu_arch					varchar2(30 char),
	canvas_fp					varchar2(30 char),
	http_head_accept			varchar2(100 char),
	content_encoding			varchar2(30 char),
	content_lang				varchar2(50 char),
	ip_address					varchar2(20 char),
	ip_address_octet			varchar2(20 char),
	os_fonts					varchar2(4000 char),
	browser_lang				varchar2(50 char),
	disp_color_depth			varchar2(20 char),
	disp_screen_res_ratio		number,
	timezone					varchar2(10 char),
	platform					varchar2(20 char),
	plugins						varchar2(400 char),
	use_of_local_storage		number(1),
	use_of_sess_storage			number(1),
	indexed_db					number(1),
	do_not_track				number(1),
	has_lied_langs				number(1),
	has_lied_os					number(1),
	has_lied_browser			number(1),
	webgl_vendor_renderer		varchar2(100 char),
	cookies_enabled				varchar2(10 char),
	touch_sup					number(1),
	connection_type				varchar2(20 char),
	webrtc_fp					varchar2(20 char),
	aud_codecs					varchar2(200 char),
	vid_codecs					varchar2(1000 char),
	constructor function ty_dfp_match_param return self as result);
/

prompt
prompt Create constructor for TY_DFP_MATCH_PARAM
prompt ======================================
create or replace type body ty_dfp_match_param as
	constructor function ty_dfp_match_param(self in out nocopy ty_dfp_match_param) return self as result
	as
	begin
		return;
	end;
end;
/

prompt
prompt Done.

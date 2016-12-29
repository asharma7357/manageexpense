prompt
prompt Creating Type TY_DFP_PQ_RSLT
prompt ============================
prompt
create type ty_dfp_pq_rslt as object(

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
	
	-- Description:
	-- Type for the PQ results with two additinal columns
	-- This type is identical to the PQ result table (DFP_RSLT_PQ_T1_L1)
	time_key					number,
	pass						number,
	pass_count					number,
	req_ref_num					varchar2(100 char),
	master_device_id			varchar2(100 char),
	ref_num						varchar2(100 char),
	session_id					varchar2(100 char),
	rec_type					varchar2(100 char),
	rec_dt						date,
	user_agent_os_id			number(10),
	user_agent_browser_id		number(10),
	user_agent_engine_id		number(10),
	user_agent_device_id		number(10),
	cpu_arch_id					number(10),
	canvas_fp					varchar2(30 char),
	http_head_accept_id			number(10),
	content_encoding_id			number(10),
	content_lang_id				number(10),
	ip_address					varchar2(20 char),
	ip_address_octet			varchar2(20 char),
	os_fonts_id					number(10),
	browser_lang_id				number(10),
	disp_color_depth			varchar2(20 char),
	disp_screen_res_ratio		number,
	timezone					varchar2(10 char),
	platform_id					number(10),
	plugins						varchar2(400 char),
	use_of_local_storage		number(1),
	use_of_sess_storage			number(1),
	indexed_db					number(1),
	do_not_track				number(1),
	has_lied_langs				number(1),
	has_lied_os					number(1),
	has_lied_browser			number(1),
	webgl_vendor_renderer_id	number(10),
	cookies_enabled				varchar2(10 char),
	touch_sup					number(1),
	connection_type				varchar2(20 char),
	webrtc_fp					varchar2(20 char),
	aud_codecs_id				number(10),
	vid_codecs_id				number(10))
/


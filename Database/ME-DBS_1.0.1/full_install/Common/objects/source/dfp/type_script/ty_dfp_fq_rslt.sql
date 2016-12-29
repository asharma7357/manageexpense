prompt
prompt Create type TY_DFP_FQ_RSLT
prompt ==========================
prompt

create type ty_dfp_fq_rslt as object(
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
	-- Type for the FQ results with two additinal columns
	-- This type is identical to the FQ result table (DFP_RSLT_FQ_T1)
	req_ref_num						varchar2(100 char),
	pad_ref_num						varchar2(100 char),
	pad_rec_type					varchar2(100 char),
	pad_rec_dt						date,
	tot_score						number(3),
	user_agent_os_id_score			number(3),
	user_agent_browser_id_score		number(3),
	user_agent_engine_id_score		number(3),
	user_agent_device_id_score		number(3),
	cpu_arch_id_score				number(3),
	canvas_fp_score					number(3),
	http_head_accept_id_score		number(3),
	content_encoding_id_score		number(3),
	content_lang_id_score			number(3),
	ip_address_score				number(3),
	ip_address_octet_score			number(3),
	os_fonts_id_score				number(3),
	browser_lang_id_score			number(3),
	disp_color_depth_score			number(3),
	disp_screen_res_ratio_score		number(3),
	timezone_score					number(3),
	platform_id_score				number(3),
	plugins_score					number(3),
	use_of_local_storage_score		number(3),
	use_of_sess_storage_score		number(3),
	indexed_db_score				number(3),
	do_not_track_score				number(3),
	has_lied_langs_score			number(3),
	has_lied_os_score				number(3),
	has_lied_browser_score			number(3),
	webgl_vendor_renderer_id_score	number(3),
	cookies_enabled_score			number(3),
	touch_sup_score					number(3),
	connection_type_score			number(3),
	webrtc_fp_score					number(3),
	aud_codecs_id_score				number(3),
	vid_codecs_id_score				number(3)
)
/

prompt
prompt Creating package PKG_DFP_API
prompt ==================================
prompt
create or replace package pkg_dfp_api is

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

	--Description: Performs aliasing match and returns details
	--Parameters:
	--	1) pr_dfp_match_param
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_process_time
	--		parameter mode = OUT
	--		description = will accept the process time.
	--	3) pv_req_timeout_thld
	--		parameter mode = OUT
	--		description = will accept the request timeout threshold.
	--	4) pv_master_device_id
	--		parameter mode = OUT
	--		description = will store the new MDI generated.
	--	5) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	6) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: With a PAD of 10 million rows, about 1 second per API call on a dual quad core machine with 16GB RAM
	procedure get_match_dfp(	pr_dfp_match_param in out ty_dfp_match_param,
								pv_process_time in number,
								pv_req_timeout_thld in number,
								pv_master_device_id out varchar2,
								pv_status_cd out number,
								pv_status_msg out varchar2);

	--Description:	Routine to store the request dataset into the staging and perform the matching algorithms and then generate MDI if the request MDI is null
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the session id of the request device.
	--	2) pv_master_device_id
	--		parameter mode = IN
	--		description = will accept the master device id is generated.
	--	3) pa_dfp_api
	--		parameter mode = IN
	--		description = will accept the DFP Attrbiutes list and values.
	--	4) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the process status code.
	--	5) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the process status message.
	--Performance:	None
	--Return: varchar2
	function func_dfp_api(	pv_session_id in varchar2,
							pv_master_device_id in varchar2,
							pa_dfp_api in ty_tbl_dfp_api,
							pv_status_cd out number,
							pv_status_msg out varchar2) return varchar2;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_api;
/

prompt
prompt Done

prompt
prompt Creating package body PKG_DFP_API
prompt ==================================
prompt

create or replace package body pkg_dfp_api is
	mc_jb_number	constant number := 1;
	mc_pkg_name		constant varchar2(100) := 'pkg_dfp_api';

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
	
	--Description:	Fetch the Dimension Key for the provided value for User Agent Os
	--Parameters:
	--	1) pv_user_agent_os
	--		parameter mode = IN
	--		description = will accept the user agent os.
	--Performance:	TBD
	function fetch_user_agent_os_id(pv_user_agent_os in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	user_agent_os_id into lv_id
		from	dim_user_agent_os
		where	user_agent_os = nvl(pv_user_agent_os,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_user_agent_os_id.nextval;
			insert into dim_user_agent_os(user_agent_os_id,user_agent_os) values (lv_id,pv_user_agent_os);
			commit;
			return lv_id;
	end fetch_user_agent_os_id;
	
	--Description:	Fetch the Dimension Key for the provided value for User Agent Browser
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_user_agent_browser_id(pv_user_agent_browser in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	user_agent_browser_id into lv_id 
		from	dim_user_agent_browser
		where	user_agent_browser = nvl(pv_user_agent_browser,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_user_agent_browser_id.nextval;
			insert into dim_user_agent_browser(user_agent_browser_id,user_agent_browser) values (lv_id,pv_user_agent_browser);
			commit;
			return lv_id;
	end fetch_user_agent_browser_id;
	
	--Description:	Fetch the Dimension Key for the provided value for User Agent Engine
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_user_agent_engine_id (pv_user_agent_engine in varchar2)return number deterministic
	as
		lv_id	number;
	begin
		select	user_agent_engine_id into lv_id
		from	dim_user_agent_engine
		where	user_agent_engine = nvl(pv_user_agent_engine,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_user_agent_engine_id.nextval;
			insert into dim_user_agent_engine(user_agent_engine_id,user_agent_engine) values (lv_id,pv_user_agent_engine);
			commit;
			return lv_id;
	end fetch_user_agent_engine_id;
	
	--Description:	Fetch the Dimension Key for the provided value for User Agent Device
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_user_agent_device_id(pv_user_agent_device in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	user_agent_device_id into lv_id
		from	dim_user_agent_device
		where	user_agent_device = nvl(pv_user_agent_device,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_user_agent_device_id.nextval;
			insert into dim_user_agent_device(user_agent_device_id,user_agent_device) values (lv_id,pv_user_agent_device);
			commit;
			return lv_id;
	end fetch_user_agent_device_id;
	
	--Description:	Fetch the Dimension Key for the provided value for CPU Arch
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_cpu_arch_id(pv_cpu_arch in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	cpu_arch_id into lv_id
		from	dim_cpu_arch
		where	cpu_arch = nvl(pv_cpu_arch,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_cpu_arch_id.nextval;
			insert into dim_cpu_arch(cpu_arch_id,cpu_arch) values (lv_id,pv_cpu_arch);
			commit;
			return lv_id;
	end fetch_cpu_arch_id;
	
	--Description:	Fetch the Dimension Key for the provided value for HTTP Head Accept
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_http_head_accept_id(pv_http_head_accept in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	http_head_accept_id into lv_id
		from	dim_http_head_accept
		where	http_head_accept = nvl(pv_http_head_accept,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_http_head_accept_id.nextval;
			insert into dim_http_head_accept(http_head_accept_id,http_head_accept) values (lv_id,pv_http_head_accept);
			commit;
			return lv_id;
	end fetch_http_head_accept_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Content Encoding
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_content_encoding_id(pv_content_encoding in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	content_encoding_id into lv_id
		from	dim_content_encoding
		where	content_encoding = nvl(pv_content_encoding,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_content_encoding_id.nextval;
			insert into dim_content_encoding(content_encoding_id,content_encoding) values (lv_id,pv_content_encoding);
			commit;
			return lv_id;
	end fetch_content_encoding_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Content Language
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_content_lang_id(pv_content_lang in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	content_lang_id into lv_id
		from	dim_content_lang
		where	content_lang = nvl(pv_content_lang,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_content_lang_id.nextval;
			insert into dim_content_lang(content_lang_id,content_lang) values (lv_id,pv_content_lang);
			commit;
			return lv_id;
	end fetch_content_lang_id;
	
	--Description:	Fetch the Dimension Key for the provided value for OS  fonts
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_os_fonts_id(pv_os_fonts in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	os_fonts_id into lv_id
		from	dim_os_fonts
		where	os_fonts = nvl(pv_os_fonts,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_os_fonts_id.nextval;
			insert into dim_os_fonts(os_fonts_id,os_fonts) values (lv_id,pv_os_fonts);
			commit;
			return lv_id;
	end fetch_os_fonts_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Browser Lang
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_browser_lang_id(pv_browser_lang in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	browser_lang_id into lv_id
		from	dim_browser_lang
		where	browser_lang = nvl(pv_browser_lang,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_browser_lang_id.nextval;
			insert into dim_browser_lang(browser_lang_id,browser_lang) values (lv_id,pv_browser_lang);
			commit;
			return lv_id;
	end fetch_browser_lang_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Platfrom
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_platform_id(pv_platform in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	platform_id into lv_id
		from	dim_platform
		where	platform = nvl(pv_platform,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_platform_id.nextval;
			insert into dim_platform(platform_id,platform) values (lv_id,pv_platform);
			commit;
			return lv_id;
	end fetch_platform_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Web GL Vendor/Renderer
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_webgl_vendor_renderer_id(pv_webgl_vendor_renderer in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	webgl_vendor_renderer_id into lv_id
		from	dim_webgl_vendor_renderer
		where	webgl_vendor_renderer = nvl(pv_webgl_vendor_renderer,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_webgl_vendor_renderer_id.nextval;
			insert into dim_webgl_vendor_renderer(webgl_vendor_renderer_id,webgl_vendor_renderer) values (lv_id,pv_webgl_vendor_renderer);
			commit;
			return lv_id;
	end fetch_webgl_vendor_renderer_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Audio Codecs
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_aud_codecs_id(pv_aud_codecs in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	aud_codecs_id into lv_id
		from	dim_aud_codecs
		where	aud_codecs = nvl(pv_aud_codecs,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_aud_codecs_id.nextval;
			insert into dim_aud_codecs(aud_codecs_id,aud_codecs) values (lv_id,pv_aud_codecs);
			commit;
			return lv_id;
	end fetch_aud_codecs_id;
	
	--Description:	Fetch the Dimension Key for the provided value for Video Codecs
	--Parameters: No parameters
	--Performance:	TBD
	function fetch_vid_codecs_id(pv_vid_codecs in varchar2) return number deterministic
	as
		lv_id	number;
	begin
		select	vid_codecs_id into lv_id
		from	dim_vid_codecs
		where	vid_codecs = nvl(pv_vid_codecs,-1);
		return lv_id;
	exception
		when no_data_found then
			lv_id := seq_vid_codecs_id.nextval;
			insert into dim_vid_codecs(vid_codecs_id,vid_codecs) values (lv_id,pv_vid_codecs);
			commit;
			return lv_id;
	end fetch_vid_codecs_id;

	--Description: Performs aliasing match and returns details
	--Parameters:
	--	1) pr_dfp_match_param
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_process_time
	--		parameter mode = OUT
	--		description = will accept the process time.
	--	3) pv_req_timeout_thld
	--		parameter mode = OUT
	--		description = will accept the request timeout threshold.
	--	4) pv_master_device_id
	--		parameter mode = OUT
	--		description = will store the new MDI generated.
	--	5) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	6) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: With a PAD of 10 million rows, about 1 second per API call on a dual quad core machine with 16GB RAM
	procedure get_match_dfp(	pr_dfp_match_param in out ty_dfp_match_param,
								pv_process_time in number,
								pv_req_timeout_thld in number,
								pv_master_device_id out varchar2,
								pv_status_cd out number,
								pv_status_msg out varchar2) is
		dummy_val		varchar2(2000);

		--lr_dfp_payload	ty_dfp_payload := ty_dfp_payload();
		lr_dfp_payload	ty_dfp_payload;
	begin
		pv_status_cd := 0;
		pv_status_msg := 'Success';
		
		lr_dfp_payload	:= ty_dfp_payload();
		
		--dfp log
		lr_dfp_payload.dfp_log_data.master_device_id := pr_dfp_match_param.master_device_id;
		lr_dfp_payload.dfp_log_data.ref_num := pr_dfp_match_param.ref_num;
		lr_dfp_payload.dfp_log_data.session_id := pr_dfp_match_param.session_id;
		lr_dfp_payload.dfp_log_data.req_ts := systimestamp;
		lr_dfp_payload.dfp_log_data.tot_time := dbms_utility.get_time;
		lr_dfp_payload.dfp_log_data.dim_id_time := null; --initialize the timer
		lr_dfp_payload.dfp_log_data.idx_time := null; --initialize the timer
		lr_dfp_payload.dfp_log_data.pq_tot_time := null; --
		lr_dfp_payload.dfp_log_data.pq_pass_time := null; --
		lr_dfp_payload.dfp_log_data.pq_match_cnt := 0; --
		lr_dfp_payload.dfp_log_data.fq_eval_cnt := 0;
		lr_dfp_payload.dfp_log_data.fq_match_cnt := 0;
		lr_dfp_payload.dfp_log_data.fq_tot_time := null;
		lr_dfp_payload.dfp_log_data.fq_eval_time := null;
		lr_dfp_payload.dfp_log_data.fq_entropy_fetch_time := null;
		lr_dfp_payload.dfp_log_data.fq_rslt_load_time := null;
		lr_dfp_payload.dfp_log_data.req_load_time := null;
		lr_dfp_payload.dfp_log_data.pad_load_time := null;
		lr_dfp_payload.dfp_log_data.status_cd := 0;
		lr_dfp_payload.dfp_log_data.status_msg := 'Success';

		--[(Abhishek Sharma : 17112016) : Assign the process time and Request timeout threshold value.]
		lr_dfp_payload.process_time := pv_process_time;
		lr_dfp_payload.req_timeout_thld := pv_req_timeout_thld;
/*
		pr_dfp_match_param.master_device_id := substr(trim(pr_dfp_match_param.master_device_id),1,pkg_util.get_setting('len_MASTER_DEVICE_ID'));
		pr_dfp_match_param.ref_num := substr(trim(pr_dfp_match_param.ref_num),1,pkg_util.get_setting('len_REF_NUM'));
		pr_dfp_match_param.session_id := substr(trim(pr_dfp_match_param.session_id),1,pkg_util.get_setting('len_SESSION_ID'));
		pr_dfp_match_param.rec_type := substr(trim(pr_dfp_match_param.rec_type),1,pkg_util.get_setting('len_REC_TYPE'));
		pr_dfp_match_param.rec_dt := pr_dfp_match_param.rec_dt;
		pr_dfp_match_param.user_agent := substr(trim(pr_dfp_match_param.user_agent),1,pkg_util.get_setting('len_USER_AGENT'));
		pr_dfp_match_param.user_agent_os := substr(trim(pr_dfp_match_param.user_agent_os),1,pkg_util.get_setting('len_USER_AGENT_OS'));
		pr_dfp_match_param.user_agent_browser := substr(trim(pr_dfp_match_param.user_agent_browser),1,pkg_util.get_setting('len_USER_AGENT_BROWSER'));
		pr_dfp_match_param.user_agent_engine := substr(trim(pr_dfp_match_param.user_agent_engine),1,pkg_util.get_setting('len_USER_AGENT_ENGINE'));
		pr_dfp_match_param.user_agent_device := substr(trim(pr_dfp_match_param.user_agent_device),1,pkg_util.get_setting('len_USER_AGENT_DEVICE'));
		pr_dfp_match_param.cpu_arch := substr(trim(pr_dfp_match_param.cpu_arch),1,pkg_util.get_setting('len_cpu_arch'));
		pr_dfp_match_param.canvas_fp := substr(trim(pr_dfp_match_param.canvas_fp),1,pkg_util.get_setting('len_canvas_fp'));
		pr_dfp_match_param.http_head_accept := substr(trim(pr_dfp_match_param.http_head_accept),1,pkg_util.get_setting('len_HTTP_HEAD_ACCEPT'));
		pr_dfp_match_param.content_encoding := substr(trim(pr_dfp_match_param.content_encoding),1,pkg_util.get_setting('len_CONTENT_ENCODING'));
		pr_dfp_match_param.content_lang := substr(trim(pr_dfp_match_param.content_lang),1,pkg_util.get_setting('len_CONTENT_LANG'));
		pr_dfp_match_param.ip_address := substr(trim(pr_dfp_match_param.ip_address),1,pkg_util.get_setting('len_IP_ADDRESS'));
		pr_dfp_match_param.ip_address_octet := substr(trim(pr_dfp_match_param.ip_address_octet),1,pkg_util.get_setting('len_IP_ADDRESS_OCTET'));
		pr_dfp_match_param.os_fonts := substr(trim(pr_dfp_match_param.os_fonts),1,pkg_util.get_setting('len_OS_FONTS'));
		pr_dfp_match_param.browser_fonts := substr(trim(pr_dfp_match_param.browser_fonts),1,pkg_util.get_setting('len_BROWSER_FONTS'));
		pr_dfp_match_param.browser_lang := substr(trim(pr_dfp_match_param.browser_lang),1,pkg_util.get_setting('len_BROWSER_LANG'));
		pr_dfp_match_param.screen_res := substr(trim(pr_dfp_match_param.screen_res),1,pkg_util.get_setting('len_SCREEN_RES'));
		pr_dfp_match_param.disp_color_depth := substr(trim(pr_dfp_match_param.disp_color_depth),1,pkg_util.get_setting('len_DISP_COLOR_DEPTH'));
		pr_dfp_match_param.disp_screen_res := substr(trim(pr_dfp_match_param.disp_screen_res),1,pkg_util.get_setting('len_DISP_SCREEN_RES'));
		pr_dfp_match_param.disp_avail_screen_res := substr(trim(pr_dfp_match_param.disp_avail_screen_res),1,pkg_util.get_setting('len_DISP_AVAIL_SCREEN_RES'));
		pr_dfp_match_param.disp_screen_res_ratio := substr(trim(pr_dfp_match_param.disp_screen_res_ratio),1,pkg_util.get_setting('len_DISP_SCREEN_RES_RATIO'));
		pr_dfp_match_param.timezone := substr(trim(pr_dfp_match_param.timezone),1,pkg_util.get_setting('len_TIMEZONE'));
		pr_dfp_match_param.platform := substr(trim(pr_dfp_match_param.platform),1,pkg_util.get_setting('len_PLATFORM'));
		pr_dfp_match_param.plugins := nvl(substr(trim(pr_dfp_match_param.plugins),1,pkg_util.get_setting('len_PLUGINS')),'-1');
		pr_dfp_match_param.use_of_local_storage := substr(trim(pr_dfp_match_param.use_of_local_storage),1,pkg_util.get_setting('len_USE_OF_LOCAL_STORAGE'));
		pr_dfp_match_param.use_of_sess_storage := substr(trim(pr_dfp_match_param.use_of_sess_storage),1,pkg_util.get_setting('len_USE_OF_SESS_STORAGE'));
		pr_dfp_match_param.do_not_track := substr(trim(pr_dfp_match_param.do_not_track),1,pkg_util.get_setting('len_DO_NOT_TRACK'));
		pr_dfp_match_param.has_lied_langs := substr(trim(pr_dfp_match_param.has_lied_langs),1,pkg_util.get_setting('len_HAS_LIED_LANGS'));
		pr_dfp_match_param.has_lied_os := substr(trim(pr_dfp_match_param.has_lied_os),1,pkg_util.get_setting('len_HAS_LIED_OS'));
		pr_dfp_match_param.has_lied_browser := substr(trim(pr_dfp_match_param.has_lied_browser),1,pkg_util.get_setting('len_HAS_LIED_BROWSER'));
		pr_dfp_match_param.webgl_vendor_renderer := substr(trim(pr_dfp_match_param.webgl_vendor_renderer),1,pkg_util.get_setting('len_WEBGL_VENDOR_RENDER'));
		pr_dfp_match_param.cookies_enabled := substr(trim(pr_dfp_match_param.cookies_enabled),1,pkg_util.get_setting('len_COOKIES_ENABLED'));
		pr_dfp_match_param.use_of_adblock := substr(trim(pr_dfp_match_param.use_of_adblock),1,pkg_util.get_setting('len_USE_OF_ADBLOCK'));
		pr_dfp_match_param.touch_sup := substr(trim(pr_dfp_match_param.touch_sup),1,pkg_util.get_setting('len_TOUCH_SUP'));
		pr_dfp_match_param.keyboard_lang := substr(trim(pr_dfp_match_param.keyboard_lang),1,pkg_util.get_setting('len_KEYBOARD_LANG'));
		pr_dfp_match_param.connection_type := substr(trim(pr_dfp_match_param.connection_type),1,pkg_util.get_setting('len_CONNECTION_TYPE'));
		pr_dfp_match_param.pass_protection := substr(trim(pr_dfp_match_param.pass_protection),1,pkg_util.get_setting('len_PASS_PROTECTION'));
		pr_dfp_match_param.multi_monitor := substr(trim(pr_dfp_match_param.multi_monitor),1,pkg_util.get_setting('len_MULTI_MONITOR'));
		pr_dfp_match_param.intrnl_hashtbl_impl := substr(trim(pr_dfp_match_param.intrnl_hashtbl_impl),1,pkg_util.get_setting('len_INTRNL_HASHTBL_IMPL'));
		pr_dfp_match_param.webrtc_fp := substr(trim(pr_dfp_match_param.webrtc_fp),1,pkg_util.get_setting('len_WEBRTC_FP'));
		pr_dfp_match_param.math_constants := substr(trim(pr_dfp_match_param.math_constants),1,pkg_util.get_setting('len_MATH_CONSTANTS'));
		pr_dfp_match_param.access_fp := substr(trim(pr_dfp_match_param.access_fp),1,pkg_util.get_setting('len_ACCESS_FP'));
		pr_dfp_match_param.camera_info := substr(trim(pr_dfp_match_param.camera_info),1,pkg_util.get_setting('len_CAMERA_INFO'));
		pr_dfp_match_param.drm_sup := substr(trim(pr_dfp_match_param.drm_sup),1,pkg_util.get_setting('len_DRM_SUP'));
		pr_dfp_match_param.accel_sup := substr(trim(pr_dfp_match_param.accel_sup),1,pkg_util.get_setting('len_ACCEL_SUP'));
		pr_dfp_match_param.virtual_keyboards := substr(trim(pr_dfp_match_param.virtual_keyboards),1,pkg_util.get_setting('len_VIRTUAL_KEYBOARDS'));
		pr_dfp_match_param.gesture_sup := substr(trim(pr_dfp_match_param.gesture_sup),1,pkg_util.get_setting('len_GESTURE_SUP'));
		pr_dfp_match_param.pixel_density := substr(trim(pr_dfp_match_param.pixel_density),1,pkg_util.get_setting('len_PIXEL_DENSITY'));
		pr_dfp_match_param.aud_codecs := substr(trim(pr_dfp_match_param.aud_codecs),1,pkg_util.get_setting('len_AUD_CODECS'));
		pr_dfp_match_param.vid_codecs := substr(trim(pr_dfp_match_param.vid_codecs),1,pkg_util.get_setting('len_VID_CODECS'));
		pr_dfp_match_param.audio_stack_fp := substr(trim(pr_dfp_match_param.audio_stack_fp),1,pkg_util.get_setting('len_AUDIO_STACK_FP'));
		pr_dfp_match_param.clock_skew := substr(trim(pr_dfp_match_param.clock_skew),1,pkg_util.get_setting('len_CLOCK_SKEW'));
		pr_dfp_match_param.clock_speed := substr(trim(pr_dfp_match_param.clock_speed),1,pkg_util.get_setting('len_CLOCK_SPEED'));
		pr_dfp_match_param.network_latency := substr(trim(pr_dfp_match_param.network_latency),1,pkg_util.get_setting('len_NETWORK_LATENCY'));
		pr_dfp_match_param.silverlight_ver := substr(trim(pr_dfp_match_param.silverlight_ver),1,pkg_util.get_setting('len_silverlight_ver'));
		
		--2) Cleanup the attributes
		pkg_dfp_ext.clean_payload(	pr_dfp_idx_pad_data => pr_dfp_match_param,
									pv_status_cd => lr_dfp_payload.dfp_log_data.status_cd,
									pv_status_msg => lr_dfp_payload.dfp_log_data.status_msg);

		if nvl(lr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			lr_dfp_payload.dfp_log_data.status_msg := 'Input cleanup error:' || nvl(lr_dfp_payload.dfp_log_data.status_msg,'<<null>>');
			goto write_log;
		end if;
	
		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		if (dbms_utility.get_time - pv_process_time) > pv_req_timeout_thld then
			lr_dfp_payload.dfp_log_data.status_msg := '[Timeout] : After Cleanup.';
			lr_dfp_payload.dfp_log_data.status_cd := 2;
			goto write_log;
		end if;

		--3) Validate the attributes
		pkg_dfp_ext.validate_payload(	pr_dfp_idx_pad_data => pr_dfp_match_param,
										pv_status_cd => lr_dfp_payload.dfp_log_data.status_cd,
										pv_status_msg => lr_dfp_payload.dfp_log_data.status_msg);

		if nvl(lr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			lr_dfp_payload.dfp_log_data.status_msg := 'Input validation error:' || nvl(lr_dfp_payload.dfp_log_data.status_msg,'<<null>>');
			goto write_log;
		end if;

		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		if (dbms_utility.get_time - lr_dfp_payload.process_time) > lr_dfp_payload.req_timeout_thld then
			lr_dfp_payload.dfp_log_data.status_msg := '[Timeout] : After Validation.';
			lr_dfp_payload.dfp_log_data.status_cd := 2;
			goto write_log;
		end if;
*/
		--4) Prepare the aliasing index data
		--for each of the attributes ensure that the max length is not breached
		lr_dfp_payload.dfp_idx_pad_data.master_device_id := pr_dfp_match_param.master_device_id;
		lr_dfp_payload.dfp_idx_pad_data.ref_num := pr_dfp_match_param.ref_num;
		lr_dfp_payload.dfp_idx_pad_data.session_id := pr_dfp_match_param.session_id;
		lr_dfp_payload.dfp_idx_pad_data.rec_type := pr_dfp_match_param.rec_type;
		lr_dfp_payload.dfp_idx_pad_data.rec_dt := pr_dfp_match_param.rec_dt;
		lr_dfp_payload.dfp_idx_pad_data.canvas_fp := pr_dfp_match_param.canvas_fp;
		lr_dfp_payload.dfp_idx_pad_data.ip_address := pr_dfp_match_param.ip_address;
		lr_dfp_payload.dfp_idx_pad_data.ip_address_octet := pr_dfp_match_param.ip_address_octet;
		lr_dfp_payload.dfp_idx_pad_data.disp_color_depth := pr_dfp_match_param.disp_color_depth;
		lr_dfp_payload.dfp_idx_pad_data.disp_screen_res_ratio := pr_dfp_match_param.disp_screen_res_ratio;
		lr_dfp_payload.dfp_idx_pad_data.timezone := pr_dfp_match_param.timezone;
		lr_dfp_payload.dfp_idx_pad_data.plugins := nvl(pr_dfp_match_param.plugins,'-1');
		lr_dfp_payload.dfp_idx_pad_data.use_of_local_storage := pr_dfp_match_param.use_of_local_storage;
		lr_dfp_payload.dfp_idx_pad_data.use_of_sess_storage := pr_dfp_match_param.use_of_sess_storage;
		lr_dfp_payload.dfp_idx_pad_data.do_not_track := pr_dfp_match_param.do_not_track;
		lr_dfp_payload.dfp_idx_pad_data.has_lied_langs := pr_dfp_match_param.has_lied_langs;
		lr_dfp_payload.dfp_idx_pad_data.has_lied_os := pr_dfp_match_param.has_lied_os;
		lr_dfp_payload.dfp_idx_pad_data.has_lied_browser := pr_dfp_match_param.has_lied_browser;
		lr_dfp_payload.dfp_idx_pad_data.cookies_enabled := pr_dfp_match_param.cookies_enabled;
		lr_dfp_payload.dfp_idx_pad_data.touch_sup := pr_dfp_match_param.touch_sup;
		lr_dfp_payload.dfp_idx_pad_data.connection_type := pr_dfp_match_param.connection_type;
		lr_dfp_payload.dfp_idx_pad_data.webrtc_fp := pr_dfp_match_param.webrtc_fp;
		
		--[(Abhishek Sharma : 30112016) : Fetch the dimension id for each dimension attribute.]
		lr_dfp_payload.dfp_log_data.dim_id_time := dbms_utility.get_time;
		lr_dfp_payload.dfp_idx_pad_data.user_agent_os_id := fetch_user_agent_os_id(pr_dfp_match_param.user_agent_os);
		lr_dfp_payload.dfp_idx_pad_data.user_agent_browser_id := fetch_user_agent_browser_id(pr_dfp_match_param.user_agent_browser);
		lr_dfp_payload.dfp_idx_pad_data.user_agent_engine_id := fetch_user_agent_engine_id(pr_dfp_match_param.user_agent_engine);
		lr_dfp_payload.dfp_idx_pad_data.user_agent_device_id := fetch_user_agent_device_id(pr_dfp_match_param.user_agent_device);
		lr_dfp_payload.dfp_idx_pad_data.cpu_arch_id := fetch_cpu_arch_id(pr_dfp_match_param.cpu_arch);
		lr_dfp_payload.dfp_idx_pad_data.http_head_accept_id := fetch_http_head_accept_id(pr_dfp_match_param.http_head_accept);
		lr_dfp_payload.dfp_idx_pad_data.content_encoding_id := fetch_content_encoding_id(pr_dfp_match_param.content_encoding);
		lr_dfp_payload.dfp_idx_pad_data.content_lang_id := fetch_content_lang_id(pr_dfp_match_param.content_lang);
		lr_dfp_payload.dfp_idx_pad_data.os_fonts_id := fetch_os_fonts_id(pr_dfp_match_param.os_fonts);
		lr_dfp_payload.dfp_idx_pad_data.browser_lang_id := fetch_browser_lang_id(pr_dfp_match_param.browser_lang);
		lr_dfp_payload.dfp_idx_pad_data.platform_id := fetch_platform_id(pr_dfp_match_param.platform);
		lr_dfp_payload.dfp_idx_pad_data.webgl_vendor_renderer_id := fetch_webgl_vendor_renderer_id(pr_dfp_match_param.webgl_vendor_renderer);
		lr_dfp_payload.dfp_idx_pad_data.aud_codecs_id := fetch_aud_codecs_id(pr_dfp_match_param.aud_codecs);
		lr_dfp_payload.dfp_idx_pad_data.vid_codecs_id := fetch_vid_codecs_id(pr_dfp_match_param.vid_codecs);
		lr_dfp_payload.dfp_log_data.dim_id_time := dbms_utility.get_time - lr_dfp_payload.dfp_log_data.dim_id_time;

		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		--5) Call the decision engine to process the payload
		pkg_dfp_processor.process_payload(	pr_dfp_payload => lr_dfp_payload);
	
		if nvl(lr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			goto write_log;
		end if;
	
		<<	write_log	>>
		
		--Return the MDI generated.
		pv_master_device_id := lr_dfp_payload.dfp_log_data.master_device_id;
		
		pv_status_cd := nvl(lr_dfp_payload.dfp_log_data.status_cd,0);
		pv_status_msg := lr_dfp_payload.dfp_log_data.status_msg;
		
		--6) Log the status and statistics
		lr_dfp_payload.dfp_log_data.tot_time := dbms_utility.get_time - lr_dfp_payload.dfp_log_data.tot_time;
		log_stats(lr_dfp_payload);
		commit;
	exception when others then
		lr_dfp_payload.dfp_log_data.status_cd := 1;
		lr_dfp_payload.dfp_log_data.status_msg := 'Unknown Error: ' || substr(sqlerrm,1,300)||'('|| substr(dbms_utility.format_error_backtrace,1,600)||')';

		pv_status_cd := lr_dfp_payload.dfp_log_data.status_cd;
		pv_status_msg := lr_dfp_payload.dfp_log_data.status_msg;
		
		log_msg('get_match', lr_dfp_payload.dfp_log_data.status_msg);
		log_stats(lr_dfp_payload);
		commit;
	end get_match_dfp;

	--Description:	Routine to store the request dataset into the staging and perform the matching algorithms and then generate MDI if the request MDI is null
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the session id of the request device.
	--	2) pv_master_device_id
	--		parameter mode = IN
	--		description = will accept the master device id is generated.
	--	3) pa_dfp_api
	--		parameter mode = IN
	--		description = will accept the DFP Attrbiutes list and values.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the process status code.
	--	3) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the process status message.
	--Performance:	None
	--Return: varchar2
	function func_dfp_api(	pv_session_id in varchar2,
							pv_master_device_id in varchar2,
							pa_dfp_api in ty_tbl_dfp_api,
							pv_status_cd out number,
							pv_status_msg out varchar2) return varchar2 as
		type lt_dfp_param is table of ty_dfp_match_param index by binary_integer;
		type lt_stg_dfp_api is table of stg_dfp_api%rowtype index by binary_integer;
		type lt_dfp_req_ui_log is table of dfp_req_ui_log%rowtype index by binary_integer;

		la_dfp_param			lt_dfp_param;
		
		la_stg_dfp_api			lt_stg_dfp_api;
		
		la_dfp_req_ui_log		lt_dfp_req_ui_log;
		
		lr_dfp_api_log			dfp_api_log%rowtype;

		lv_session_ts			timestamp := systimestamp;
		
		lv_key					varchar2(300 char);
		
		lv_value_start_ms		number;
		lv_value_end_ms			number;
		lv_req_timeout_thld		number := pkg_util.get_setting('REQ_TIMEOUT_THLD');
		lv_process_time			number;
		lv_stg_dfp_api_cnt		number := 1;
		lv_dfp_req_ui_log_cnt	number := 1;
		
		lv_master_device_id		stg_dfp_api.master_device_id%type;

		lr_dfp_api_data			stg_dfp_api%rowtype;

		lv_dfp_param			varchar2(4000 char);
		lv_dfp_col				varchar2(4000 char);
		lv_ins_col				varchar2(4000 char);
		lv_sql					clob;
		lv_ref_num				varchar2(100 char) := to_char(systimestamp,'rrrrmmddhh24missFF');
		
		procedure save_log as
		PRAGMA AUTONOMOUS_TRANSACTION;
		begin
			insert into dfp_api_log(
				master_device_id,
				ref_num,
				session_id,
				req_start_ts,
				req_end_ts,
				attrib_pass_cnt,
				status_cd,
				status_msg
			)
			values (
				lr_dfp_api_log.master_device_id,
				lr_dfp_api_log.ref_num,
				lr_dfp_api_log.session_id,
				lr_dfp_api_log.req_start_ts,
				lr_dfp_api_log.req_end_ts,
				lr_dfp_api_log.attrib_pass_cnt,
				lr_dfp_api_log.status_cd,
				lr_dfp_api_log.status_msg
			);
			commit;
		end save_log;
	begin
		--Set the log details.
		lr_dfp_api_log.master_device_id := pv_master_device_id;
		lr_dfp_api_log.ref_num := null;
		lr_dfp_api_log.session_id := pv_session_id;
		lr_dfp_api_log.req_start_ts := systimestamp;
		lr_dfp_api_log.req_end_ts := null;
		lr_dfp_api_log.attrib_pass_cnt := pa_dfp_api.count;
		lr_dfp_api_log.status_cd := 0;
		lr_dfp_api_log.status_msg := 'Success';
		
		--[(Abhishek Sharma : 07112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		lv_process_time := dbms_utility.get_time;
		
		pv_status_cd := 0;
		pv_status_msg := 'Success';

		--Start : [(Abhishek Sharma : 06122016) : Check if the current session id has been processed before or not.]
		pkg_dfp_ext.check_dup_session(	pv_session_id => pv_session_id,
									pv_status_cd => pv_status_cd,
									pv_status_msg => pv_status_msg);
		
		if pv_status_cd = 0 then
			--[(Abhishek Sharma : 02112016) : Store the data for attributes and re ui logging into seperate collections.]
			--[(Abhishek Sharma : 02112016) : Store the UI logging for the attribute value extraction.]
			--Store the dfp api attributes and values into the staging table.
			for iApi in 1..pa_dfp_api.count loop
				if pa_dfp_api(iApi).key not like '%StartTime%' or pa_dfp_api(iApi).key not like '%EndTime%' then
					la_stg_dfp_api(lv_stg_dfp_api_cnt).session_id := pv_session_id;
					la_stg_dfp_api(lv_stg_dfp_api_cnt).master_device_id := pv_master_device_id;
					la_stg_dfp_api(lv_stg_dfp_api_cnt).session_ts := lv_session_ts;
					la_stg_dfp_api(lv_stg_dfp_api_cnt).key := pa_dfp_api(iApi).key;
					la_stg_dfp_api(lv_stg_dfp_api_cnt).value := pa_dfp_api(iApi).value;
					lv_stg_dfp_api_cnt := lv_stg_dfp_api_cnt + 1;
				else
					lv_key := replace(substr(pa_dfp_api(iApi).key,1,instr(pa_dfp_api(iApi).key,'|')-1),'StartTime','');
				
					lv_value_start_ms := substr(pa_dfp_api(iApi).value,1,instr(pa_dfp_api(iApi).value,'|')-1);
					lv_value_end_ms := substr(pa_dfp_api(iApi).value,instr(pa_dfp_api(iApi).value,'|')+1);
				
					la_dfp_req_ui_log(lv_dfp_req_ui_log_cnt).ref_num := lv_ref_num;
					la_dfp_req_ui_log(lv_dfp_req_ui_log_cnt).session_id := pv_session_id;
					la_dfp_req_ui_log(lv_dfp_req_ui_log_cnt).attrib_name := lv_key; 
					la_dfp_req_ui_log(lv_dfp_req_ui_log_cnt).attrib_extract_start_ms := lv_value_start_ms;
					la_dfp_req_ui_log(lv_dfp_req_ui_log_cnt).attrib_extract_end_ms := lv_value_end_ms;
					lv_dfp_req_ui_log_cnt := lv_dfp_req_ui_log_cnt + 1;
					
				end if;
			end loop;
			
			--Store the DFP Attributes into the staging table
			forall iAttrib in 1..la_stg_dfp_api.count 
				insert into stg_dfp_api values la_stg_dfp_api(iAttrib);
			
			--Store the DFP Req UI Log
			forall iLog in 1..la_dfp_req_ui_log.count
				insert into dfp_req_ui_log(ref_num,session_id,attrib_name,attrib_extract_start_ms,attrib_extract_end_ms)
				values (la_dfp_req_ui_log(iLog).ref_num,la_dfp_req_ui_log(iLog).session_id,la_dfp_req_ui_log(iLog).attrib_name,la_dfp_req_ui_log(iLog).attrib_extract_start_ms,la_dfp_req_ui_log(iLog).attrib_extract_end_ms);
			
			if (dbms_utility.get_time - lv_process_time) < lv_req_timeout_thld then
		
				--Fetch the list of columns using the attributes and columnsof PAD
				select	listagg (''''||dam.attrib_name||''' as '||dam.column_name, ',') within group (order by utc.column_id) as attrib_name,
						listagg (case when utc.data_type = 'NUMBER' then 'decode('||dam.column_name||',''true'',0,1)' else dam.column_name end, ',') within group (order by utc.column_id) as cols,
						listagg (dam.column_name, ',') within group (order by utc.column_id) as ins_col
				into lv_dfp_param,lv_dfp_col,lv_ins_col
				from	dfp_attrib_map dam
						join user_tab_cols utc on (utc.column_name = dam.column_name and utc.table_name='DFP_REQ_ATTRIB');

				--[(Abhishek Sharma : 18102016) : Save the master device id being passed from the UI]
				-- Below logic is to be changed.
				lv_sql := 'insert into dfp_param_attrib (master_device_id,ref_num,session_id,rec_type,rec_dt,'||lv_ins_col||')'||chr(10);
				lv_sql := lv_sql||'select	:mdi as master_device_id,:ref_num as ref_num,session_id,:rec_type as rec_type,sysdate as rec_dt,'||lv_dfp_col||chr(10);
				lv_sql := lv_sql||'from	(	select	session_id,'||chr(10);
				lv_sql := lv_sql||'					key,'||chr(10);
				lv_sql := lv_sql||'					value'||chr(10);
				lv_sql := lv_sql||'			from	stg_dfp_api'||chr(10);
				lv_sql := lv_sql||'			where	session_id = :session_id'||chr(10);
				lv_sql := lv_sql||'			and		session_ts = :session_ts'||chr(10);
				lv_sql := lv_sql||'		)'||chr(10);
				lv_sql := lv_sql||'pivot(max(value) for key in ('||lv_dfp_param||'))';

				execute immediate lv_sql /*into lr_dfp_param */using pv_master_device_id,lv_ref_num,'D',pv_session_id,lv_session_ts;

				lv_sql := 'select	ty_dfp_match_param(	substr(trim(master_device_id),1,:len_master_device_id),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(ref_num),1,:len_ref_num),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(session_id),1,:len_session_id),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(rec_type),1,:len_rec_type),'||chr(10);
				lv_sql := lv_sql||'						rec_dt,'||chr(10);
				lv_sql := lv_sql||'						substr(trim(user_agent_os),1,:len_user_agent_os),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(user_agent_browser),1,:len_user_agent_browser),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(user_agent_engine),1,:len_user_agent_engine),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(user_agent_device),1,:len_user_agent_device),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(cpu_arch),1,:len_cpu_arch),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(canvas_fp),1,:len_canvas_fp),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(http_head_accept),1,:len_http_head_accept),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(content_encoding),1,:len_content_encoding),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(content_lang),1,:len_content_lang),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(ip_address),1,:len_ip_address),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(ip_address_octet),1,:len_ip_address_octet),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(os_fonts),1,:len_os_fonts),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(browser_lang),1,:len_browser_lang),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(disp_color_depth),1,:len_disp_color_depth),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(disp_screen_res_ratio),1,:len_disp_screen_res_ratio),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(timezone),1,:len_timezone),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(platform),1,:len_platform),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(plugins),1,:len_plugins),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(use_of_local_storage),1,:len_use_of_local_storage),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(use_of_sess_storage),1,:len_use_of_sess_storage),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(indexed_db),1,:len_indexed_db),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(do_not_track),1,:len_do_not_track),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(has_lied_langs),1,:len_has_lied_langs),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(has_lied_os),1,:len_has_lied_os),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(has_lied_browser),1,:len_has_lied_browser),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(webgl_vendor_renderer),1,:len_webgl_vendor_render),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(cookies_enabled),1,:len_cookies_enabled),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(touch_sup),1,:len_touch_sup),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(connection_type),1,:len_connection_type),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(webrtc_fp),1,:len_webrtc_fp),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(aud_codecs),1,:len_aud_codecs),'||chr(10);
				lv_sql := lv_sql||'						substr(trim(vid_codecs),1,:len_vid_codecs))'||chr(10);
				lv_sql := lv_sql||'from	dfp_param_attrib'||chr(10);
				lv_sql := lv_sql||'where	session_id = :session_id'||chr(10);
				lv_sql := lv_sql||'and		ref_num = :ref_num'||chr(10);
				
				execute immediate lv_sql bulk collect into la_dfp_param using	pkg_dfp_ext.gc_len_master_device_id,
																				pkg_dfp_ext.gc_len_ref_num,
																				pkg_dfp_ext.gc_len_session_id,
																				pkg_dfp_ext.gc_len_rec_type,
																				pkg_dfp_ext.gc_len_user_agent_os,
																				pkg_dfp_ext.gc_len_user_agent_browser,
																				pkg_dfp_ext.gc_len_user_agent_engine,
																				pkg_dfp_ext.gc_len_user_agent_device,
																				pkg_dfp_ext.gc_len_cpu_arch,
																				pkg_dfp_ext.gc_len_canvas_fp,
																				pkg_dfp_ext.gc_len_http_head_accept,
																				pkg_dfp_ext.gc_len_content_encoding,
																				pkg_dfp_ext.gc_len_content_lang,
																				pkg_dfp_ext.gc_len_ip_address,
																				pkg_dfp_ext.gc_len_ip_address_octet,
																				pkg_dfp_ext.gc_len_os_fonts,
																				pkg_dfp_ext.gc_len_browser_lang,
																				pkg_dfp_ext.gc_len_disp_color_depth,
																				pkg_dfp_ext.gc_len_disp_screen_res_ratio,
																				pkg_dfp_ext.gc_len_timezone,
																				pkg_dfp_ext.gc_len_platform,
																				pkg_dfp_ext.gc_len_plugins,
																				pkg_dfp_ext.gc_len_use_of_local_storage,
																				pkg_dfp_ext.gc_len_use_of_sess_storage,
																				pkg_dfp_ext.gc_len_indexed_db,
																				pkg_dfp_ext.gc_len_do_not_track,
																				pkg_dfp_ext.gc_len_has_lied_langs,
																				pkg_dfp_ext.gc_len_has_lied_os,
																				pkg_dfp_ext.gc_len_has_lied_browser,
																				pkg_dfp_ext.gc_len_webgl_vendor_renderer,
																				pkg_dfp_ext.gc_len_cookies_enabled,
																				pkg_dfp_ext.gc_len_touch_sup,
																				pkg_dfp_ext.gc_len_connection_type,
																				pkg_dfp_ext.gc_len_webrtc_fp,
																				pkg_dfp_ext.gc_len_aud_codecs,
																				pkg_dfp_ext.gc_len_vid_codecs,
																				pv_session_id,
																				lv_ref_num;

				-- Cleanup the attributes
				pkg_dfp_ext.clean_payload(	pr_dfp_idx_pad_data => la_dfp_param(1),
											pv_status_cd => pv_status_cd,
											pv_status_msg => pv_status_msg);

				if nvl(pv_status_cd, 0) > 0 then
					pv_status_msg := 'Input cleanup error:' || nvl(pv_status_msg,'<<null>>');
					lr_dfp_api_log.ref_num := lv_ref_num;
					lr_dfp_api_log.status_cd := 1;
					lr_dfp_api_log.status_msg := pv_status_msg;
					lr_dfp_api_log.req_end_ts := systimestamp;
					goto write_log;
				end if;
	
				-- Validate the attributes
				pkg_dfp_ext.validate_payload(	pr_dfp_idx_pad_data => la_dfp_param(1),
												pv_status_cd => pv_status_cd,
												pv_status_msg => pv_status_msg);

				if nvl(pv_status_cd, 0) > 0 then
					pv_status_msg := 'Input validation error:' || nvl(pv_status_msg,'<<null>>');
					lr_dfp_api_log.ref_num := lv_ref_num;
					lr_dfp_api_log.status_cd := 1;
					lr_dfp_api_log.status_msg := pv_status_msg;
					lr_dfp_api_log.req_end_ts := systimestamp;
					goto write_log;
				end if;

				--[(Abhishek Sharma : 07112016) : Passing parameters to handel the timeout of processing a request.]
				get_match_dfp(	pr_dfp_match_param => la_dfp_param(1),
								pv_process_time => lv_process_time,
								pv_req_timeout_thld => lv_req_timeout_thld,
								pv_master_device_id => lv_master_device_id,
								pv_status_cd => pv_status_cd,
								pv_status_msg => pv_status_msg);
				
				--Purge the current processed data.
				execute immediate 'delete dfp_param_attrib where session_id = :session_id and ref_num = :ref_num' using pv_session_id,lv_ref_num;
		
				lr_dfp_api_log.master_device_id := lv_master_device_id;
				lr_dfp_api_log.ref_num := lv_ref_num;
				lr_dfp_api_log.req_end_ts := systimestamp;
			else
				lr_dfp_api_log.master_device_id := null;
				lr_dfp_api_log.ref_num := lv_ref_num;
				lr_dfp_api_log.status_cd := 1;
				lr_dfp_api_log.status_msg := 'Process took '||lv_process_time||' centisec whereas total process should complete in '||lv_req_timeout_thld||' centisecs.';
				lr_dfp_api_log.req_end_ts := systimestamp;
			end if;
		else
			lr_dfp_api_log.status_cd := pv_status_cd;
			lr_dfp_api_log.status_msg := pv_status_msg;
			lr_dfp_api_log.req_end_ts := systimestamp;
		end if;
		--End : [(Abhishek Sharma : 06122016) : Check if the current session id has been processed before or not.]
		
		<<	write_log	>>
		
		--Save the log details
		save_log;
		
		commit;
		
		return lv_master_device_id;
	exception
		when others then
			rollback;
			
			pv_status_cd := 1;
			pv_status_msg := substr(sqlerrm,1,300)||'('|| substr(dbms_utility.format_error_backtrace,1,600)||')';
			log_msg('func_dfp_api', pv_status_msg);
			
			lr_dfp_api_log.master_device_id := null;
			lr_dfp_api_log.ref_num := lv_ref_num;
			lr_dfp_api_log.req_end_ts := systimestamp;
			lr_dfp_api_log.status_cd := pv_status_cd;
			lr_dfp_api_log.status_msg := pv_status_msg;
			
			--Save the log details
			save_log;
		
			return lr_dfp_api_log.master_device_id;
	end func_dfp_api;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(06-12-2016): Abhishek Sharma
		-- Version: 1.0.7
		-- Description: Following Changes are done:
		--	1) Routine : func_dfp_api
		--		1) Check if the current session id has been processed before or not.
		
		-- Created(30-11-2016): Abhishek Sharma
		-- Version: 1.0.6
		-- Description: Following Changes are done:
		--	1) New Routines are created:
		--		fetch_user_agent_os_id
		--		fetch_user_agent_browser_id
		--		fetch_user_agent_engine_id
		--		fetch_user_agent_device_id
		--		fetch_cpu_arch_id
		--		fetch_http_head_accept_id
		--		fetch_content_encoding_id
		--		fetch_content_lang_id
		--		fetch_os_fonts_id
		--		fetch_browser_fonts_id
		--		fetch_browser_lang_id
		--		fetch_screen_res_id
		--		fetch_disp_screen_res_id
		--		fetch_disp_avail_screen_res_id
		--		fetch_platform_id
		--		fetch_webgl_vendor_renderer_id
		--		fetch_aud_codecs_id
		--		fetch_vid_codecs_id

		-- Created(09-11-2016): Abhishek Sharma
		-- Version: 1.0.5
		-- Description: Following changes are made:
		--	1) Routine : log_stats
		--		1) Store the data into rowtype array and store the data into table.

		-- Created(07-11-2016): Abhishek Sharma
		-- Version: 1.0.4
		-- Description: Following changes are made:
		--	1) Routine : get_match_dfp
		--		1) Placed the MDI assignment logic from Process Payload to here.
		--	2) Routine : func_dfp_api
		--		1) Timeout logic to exit the processing when the configured timeout value exceeds.
		--		2) Passing parameters to handel the timeout of processing a request.

		-- Created(02-11-2016): Abhishek Sharma
		-- Version: 1.0.3
		-- Description: Following changes are made:
		--	1) Routine : proc_dfp_load_pad_supp
		--		1) The PAD Sync logic rectified by subtracting the dates i.e. PAD Rec Date and Current Date.
		--	2) Routine: func_dfp_api
		--		1) Store the UI logging for the attribute value extraction.

		-- Created(26-10-2016): Abhishek Sharma
		-- Version: 1.0.3
		-- Description: Following changes are made:
		--	1) Routine : func_dfp_api
		--		1) The total score checking should be greater than or equal instead of greater than.

		-- Created(20-10-2016): Abhishek Sharma
		-- Version: 1.0.2
		-- Description: Following changes are made:
		--	1) Routine : func_dfp_api
		--		1) The existing MDI will be fetched only when the FQ total score exceeds the defined threshold.
		--	2) Routine: proc_dfp_load_pad_supp
		--		1) Fetch the unqiue records based on the MDI and Ref Number

		-- Created(18-10-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description: Following changes are made:
		--	1) Routine : func_dfp_api
		--		1) Save the master device id being passed from the UI
		--		2) Set the updated date for the record being updated.
		--	2) Routine: proc_dfp_load_pad_supp
		--		1) Loading process to be based on the update date rather than rec date
		--		2) Loading process to be based on the update date rather than rec date and load only record where master device id is not null

		-- Created(17-10-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description: Following changes are made:
		--	1) Routine : proc_dfp_load_pad_supp
		--		Change: Insert log details when the min and max rec date is not null

		-- Created(02-08-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.7';
	end;

end pkg_dfp_api;
/


prompt
prompt Done

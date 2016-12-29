prompt
prompt Creating package pkg_dfp_fq
prompt =============================
prompt
create or replace package pkg_dfp_fq is
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

	-- Author  : Abhishek Sharma
	-- Created : 06-Oct-2016
	-- Purpose : Final Qualification Routines for dfp match

	type mt_dfp_entropy is table of dfp_entropy%rowtype index by binary_integer;
	
	--Description:	Routine to compare the Req and PAD records and return the individual score
	--Parameters:
	--	1) pv_req_attrib
	--		parameter mode = IN
	--		description = will accept the Request Content Lang.
	--	2) pv_pad_attrib
	--		parameter mode = IN
	--		description = will accept the PAD Content Lang.
	--Performance:	None
	function compare_exact(	pv_req_attrib in varchar2,
								pv_pad_attrib in varchar2) return number;

	--Description:	Computes details scores on two records (the pr_pad_rec is qualified by PQ stage)
	--Parameters:
	--	1) pr_req_rec
	--		parameter mode = IN
	--		description = will accept the Request dataset.
	--	2) pr_pad_rec
	--		parameter mode = IN
	--		description = will accept the PAD record set.
	--	3) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will accept the FQ result dataset.
	--Performance:	None
	procedure compute_attrib_scores(pr_req_rec in ty_dfp_idx_pad,
									pr_pad_rec in ty_dfp_pq_rslt,
									pr_fq_rslt in out nocopy ty_dfp_fq_rslt);

	--Description:	This routine is used to return the total score based on scores obtained for various attributes
	--Parameters:
	--	1) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will accept the FQ result dataset.
	--	2) pa_dfp_entropy
	--		parameter mode = IN
	--		description = will accept the entropy confgiured for each attribute.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure compute_total_score(	pr_fq_rslt in out nocopy ty_dfp_fq_rslt,
									pa_dfp_entropy in mt_dfp_entropy);

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_fq;
/

prompt
prompt Creating package body pkg_dfp_fq
prompt ==================================
prompt
create or replace package body pkg_dfp_fq is

	--Description:	Routine to compare the Req and PAD records and return the individual score
	--Parameters:
	--	1) pv_req_attrib
	--		parameter mode = IN
	--		description = will accept the Request Content Lang.
	--	2) pv_pad_attrib
	--		parameter mode = IN
	--		description = will accept the PAD Content Lang.
	--Performance:	None
	function compare_exact(	pv_req_attrib in varchar2,
								pv_pad_attrib in varchar2) return number is
	begin
		if (pv_req_attrib = pv_pad_attrib) then
			return 100;
		else
			return 0;
		end if;
	end compare_exact;

	--Description:	Routine to fetch the entropy value for the provided attribute name.
	--Parameters:
	--	1) pv_pad_col_name
	--		parameter mode = IN
	--		description = will accept the PAD column name
	--Performance:
	function entropy_value(pv_pad_col_name in varchar2) return number as
		lv_entropy_value	number := 0;
	begin
		select	nvl(pre_computed_entropy,calculated_entropy) into lv_entropy_value
		from	dfp_entropy
		where	column_name = upper(pv_pad_col_name);

		return lv_entropy_value;
	exception
		when no_data_found then
			return 0;
	end entropy_value;

	--Description:	Computes details scores on two records (the pr_pad_rec is qualified by PQ stage)
	--Parameters:
	--	1) pr_req_rec
	--		parameter mode = IN
	--		description = will accept the Request dataset.
	--	2) pr_pad_rec
	--		parameter mode = IN
	--		description = will accept the PAD record set.
	--	3) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will accept the FQ result dataset.
	--Performance:
	--  None
	procedure compute_attrib_scores(pr_req_rec in ty_dfp_idx_pad,
									pr_pad_rec in ty_dfp_pq_rslt,
									pr_fq_rslt in out nocopy ty_dfp_fq_rslt) is
	begin
		pr_fq_rslt.req_ref_num := pr_req_rec.ref_num;
		pr_fq_rslt.pad_ref_num := pr_pad_rec.ref_num;

		-- compare new conent language
		--if not pkg_util.get_setting('FQ_DISABLE_cpu_arch_id_score') = 1 then
			pr_fq_rslt.cpu_arch_id_score := compare_exact(pr_req_rec.cpu_arch_id,pr_pad_rec.cpu_arch_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_CANVAS_FP_SCORE') = 1 then
			pr_fq_rslt.canvas_fp_score := compare_exact(pr_req_rec.canvas_fp,pr_pad_rec.canvas_fp);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_http_head_accept_id_SCORE') = 1 then
			pr_fq_rslt.http_head_accept_id_score := compare_exact(pr_req_rec.http_head_accept_id,pr_pad_rec.http_head_accept_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_content_encoding_id_SCORE') = 1 then
			pr_fq_rslt.content_encoding_id_score := compare_exact(pr_req_rec.content_encoding_id,pr_pad_rec.content_encoding_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_content_lang_id_SCORE') = 1 then
			pr_fq_rslt.content_lang_id_score := compare_exact(pr_req_rec.content_lang_id,pr_pad_rec.content_lang_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_IP_ADDRESS_SCORE') = 1 then
			pr_fq_rslt.ip_address_score := compare_exact(pr_req_rec.ip_address,pr_pad_rec.ip_address);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_IP_ADDRESS_OCTET_SCORE') = 1 then
			pr_fq_rslt.ip_address_octet_score := compare_exact(pr_req_rec.ip_address_octet,pr_pad_rec.ip_address_octet);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_os_fonts_id_SCORE') = 1 then
			pr_fq_rslt.os_fonts_id_score := compare_exact(pr_req_rec.os_fonts_id,pr_pad_rec.os_fonts_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_browser_lang_id_SCORE') = 1 then
			pr_fq_rslt.browser_lang_id_score := compare_exact(pr_req_rec.browser_lang_id,pr_pad_rec.browser_lang_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_TIMEZONE_SCORE') = 1 then
			pr_fq_rslt.timezone_score := compare_exact(pr_req_rec.timezone,pr_pad_rec.timezone);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_platform_id_score') = 1 then
			pr_fq_rslt.platform_id_score := compare_exact(pr_req_rec.platform_id,pr_pad_rec.platform_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_PLUGINS_SCORE') = 1 then
			pr_fq_rslt.plugins_score := compare_exact(pr_req_rec.plugins,pr_pad_rec.plugins);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_USE_OF_LOCAL_STORAGE_SCORE') = 1 then
			pr_fq_rslt.use_of_local_storage_score := compare_exact(pr_req_rec.use_of_local_storage,pr_pad_rec.use_of_local_storage);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_USE_OF_SESS_STORAGE_SCORE') = 1 then
			pr_fq_rslt.use_of_sess_storage_score := compare_exact(pr_req_rec.use_of_sess_storage,pr_pad_rec.use_of_sess_storage);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_INDEXED_DB_SCORE') = 1 then
			pr_fq_rslt.indexed_db_score := compare_exact(pr_req_rec.indexed_db,pr_pad_rec.indexed_db);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_DO_NOT_TRACK_SCORE') = 1 then
			pr_fq_rslt.do_not_track_score := compare_exact(pr_req_rec.do_not_track,pr_pad_rec.do_not_track);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_HAS_LIED_LANGS_SCORE') = 1 then
			pr_fq_rslt.has_lied_langs_score := compare_exact(pr_req_rec.has_lied_langs,pr_pad_rec.has_lied_langs);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_HAS_LIED_OS_SCORE') = 1 then
			pr_fq_rslt.has_lied_os_score := compare_exact(pr_req_rec.has_lied_os,pr_pad_rec.has_lied_os);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_HAS_LIED_BROWSER_SCORE') = 1 then
			pr_fq_rslt.has_lied_browser_score := compare_exact(pr_req_rec.has_lied_browser,pr_pad_rec.has_lied_browser);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_webgl_vendor_renderer_id_score') = 1 then
			pr_fq_rslt.webgl_vendor_renderer_id_score := compare_exact(pr_req_rec.webgl_vendor_renderer_id,pr_pad_rec.webgl_vendor_renderer_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_COOKIES_ENABLED_SCORE') = 1 then
			pr_fq_rslt.cookies_enabled_score := compare_exact(pr_req_rec.cookies_enabled,pr_pad_rec.cookies_enabled);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_TOUCH_SUP_SCORE') = 1 then
			pr_fq_rslt.touch_sup_score := compare_exact(pr_req_rec.touch_sup,pr_pad_rec.touch_sup);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_CONNECTION_TYPE_SCORE') = 1 then
			pr_fq_rslt.connection_type_score := compare_exact(pr_req_rec.connection_type,pr_pad_rec.connection_type);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_WEBRTC_FP_SCORE') = 1 then
			pr_fq_rslt.webrtc_fp_score := compare_exact(pr_req_rec.webrtc_fp,pr_pad_rec.webrtc_fp);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_aud_codecs_id_score') = 1 then
			pr_fq_rslt.aud_codecs_id_score := compare_exact(pr_req_rec.aud_codecs_id,pr_pad_rec.aud_codecs_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_vid_codecs_id_score') = 1 then
			pr_fq_rslt.vid_codecs_id_score := compare_exact(pr_req_rec.vid_codecs_id,pr_pad_rec.vid_codecs_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_user_agent_os_id_score') = 1 then
			pr_fq_rslt.user_agent_os_id_score := compare_exact(pr_req_rec.user_agent_os_id,pr_pad_rec.user_agent_os_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_user_agent_browser_id_score') = 1 then
			pr_fq_rslt.user_agent_browser_id_score := compare_exact(pr_req_rec.user_agent_browser_id,pr_pad_rec.user_agent_browser_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_user_agent_engine_id_score') = 1 then
			pr_fq_rslt.user_agent_engine_id_score := compare_exact(pr_req_rec.user_agent_engine_id,pr_pad_rec.user_agent_engine_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_user_agent_device_id_score') = 1 then
			pr_fq_rslt.user_agent_device_id_score := compare_exact(pr_req_rec.user_agent_device_id,pr_pad_rec.user_agent_device_id);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_DISP_COLOR_DEPTH_SCORE') = 1 then
			pr_fq_rslt.disp_color_depth_score := compare_exact(pr_req_rec.disp_color_depth,pr_pad_rec.disp_color_depth);
		--end if;

		--if not pkg_util.get_setting('FQ_DISABLE_DISP_SCREEN_RES_RATIO_SCORE') = 1 then
			pr_fq_rslt.disp_screen_res_ratio_score := compare_exact(pr_req_rec.disp_screen_res_ratio,pr_pad_rec.disp_screen_res_ratio);
		--end if;

		--dbms_output.put_line('User Agent Score : '||pr_fq_rslt.user_agent_score);
	end compute_attrib_scores;

	--Description:	This routine is used to return the total score based on scores obtained for various attributes
	--Parameters:
	--	1) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will accept the FQ result dataset.
	--	2) pa_dfp_entropy
	--		parameter mode = IN
	--		description = will accept the entropy confgiured for each attribute.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure compute_total_score(	pr_fq_rslt in out nocopy ty_dfp_fq_rslt,
									pa_dfp_entropy in mt_dfp_entropy) is
		lv_score		number;
		lv_attrib_size	number := 1;

		la_cols			dbms_sql.varchar2_table;

		lv_attrib_names	varchar2(4000 char);

		la_attrib_dtl	pkg_fq_demo.gt_attrib_dtl;
	begin
		pr_fq_rslt.cpu_arch_id_score := nvl(pr_fq_rslt.cpu_arch_id_score,0);
		pr_fq_rslt.canvas_fp_score := nvl(pr_fq_rslt.canvas_fp_score,0);
		pr_fq_rslt.http_head_accept_id_score := nvl(pr_fq_rslt.http_head_accept_id_score,0);
		pr_fq_rslt.content_encoding_id_score := nvl(pr_fq_rslt.content_encoding_id_score,0);
		pr_fq_rslt.content_lang_id_score := nvl(pr_fq_rslt.content_lang_id_score,0);
		pr_fq_rslt.ip_address_score := nvl(pr_fq_rslt.ip_address_score,0);
		pr_fq_rslt.ip_address_octet_score := nvl(pr_fq_rslt.ip_address_octet_score,0);
		pr_fq_rslt.os_fonts_id_score := nvl(pr_fq_rslt.os_fonts_id_score,0);
		pr_fq_rslt.browser_lang_id_score := nvl(pr_fq_rslt.browser_lang_id_score,0);
		pr_fq_rslt.timezone_score := nvl(pr_fq_rslt.timezone_score,0);
		pr_fq_rslt.platform_id_score := nvl(pr_fq_rslt.platform_id_score,0);
		pr_fq_rslt.plugins_score := nvl(pr_fq_rslt.plugins_score,0);
		pr_fq_rslt.use_of_local_storage_score := nvl(pr_fq_rslt.use_of_local_storage_score,0);
		pr_fq_rslt.use_of_sess_storage_score := nvl(pr_fq_rslt.use_of_sess_storage_score,0);
		pr_fq_rslt.do_not_track_score := nvl(pr_fq_rslt.do_not_track_score,0);
		pr_fq_rslt.indexed_db_score := nvl(pr_fq_rslt.indexed_db_score,0);
		pr_fq_rslt.has_lied_langs_score := nvl(pr_fq_rslt.has_lied_langs_score,0);
		pr_fq_rslt.has_lied_os_score := nvl(pr_fq_rslt.has_lied_os_score,0);
		pr_fq_rslt.has_lied_browser_score := nvl(pr_fq_rslt.has_lied_browser_score,0);
		pr_fq_rslt.webgl_vendor_renderer_id_score := nvl(pr_fq_rslt.webgl_vendor_renderer_id_score,0);
		pr_fq_rslt.cookies_enabled_score := nvl(pr_fq_rslt.cookies_enabled_score,0);
		pr_fq_rslt.touch_sup_score := nvl(pr_fq_rslt.touch_sup_score,0);
		pr_fq_rslt.connection_type_score := nvl(pr_fq_rslt.connection_type_score,0);
		pr_fq_rslt.webrtc_fp_score := nvl(pr_fq_rslt.webrtc_fp_score,0);
		pr_fq_rslt.aud_codecs_id_score := nvl(pr_fq_rslt.aud_codecs_id_score,0);
		pr_fq_rslt.vid_codecs_id_score := nvl(pr_fq_rslt.vid_codecs_id_score,0);
		pr_fq_rslt.user_agent_os_id_score := nvl(pr_fq_rslt.user_agent_os_id_score,0);
		pr_fq_rslt.user_agent_browser_id_score := nvl(pr_fq_rslt.user_agent_browser_id_score,0);
		pr_fq_rslt.user_agent_engine_id_score := nvl(pr_fq_rslt.user_agent_engine_id_score,0);
		pr_fq_rslt.user_agent_device_id_score := nvl(pr_fq_rslt.user_agent_device_id_score,0);
		pr_fq_rslt.disp_color_depth_score := nvl(pr_fq_rslt.disp_color_depth_score,0);
		pr_fq_rslt.disp_screen_res_ratio_score := nvl(pr_fq_rslt.disp_screen_res_ratio_score,0);

		if pr_fq_rslt.cpu_arch_id_score > 0 then
			la_cols(la_cols.count+1) := 'CPU_ARCH';
		end if;

		if pr_fq_rslt.canvas_fp_score > 0 then
			la_cols(la_cols.count+1) := 'CANVAS_FP';
		end if;

		if pr_fq_rslt.http_head_accept_id_score > 0 then
			la_cols(la_cols.count+1) := 'HTTP_HEAD_ACCEPT_ID';
		end if;

		if pr_fq_rslt.content_encoding_id_score > 0 then
			la_cols(la_cols.count+1) := 'CONTENT_ENCODING_ID';
		end if;

		if pr_fq_rslt.content_lang_id_score > 0 then
			la_cols(la_cols.count+1) := 'CONTENT_LANG_ID';
		end if;

		if pr_fq_rslt.ip_address_score > 0 then
			la_cols(la_cols.count+1) := 'IP_ADDRESS';
		end if;

		if pr_fq_rslt.ip_address_octet_score > 0 then
			la_cols(la_cols.count+1) := 'IP_ADDRESS_OCTET';
		end if;

		if pr_fq_rslt.os_fonts_id_score > 0 then
			la_cols(la_cols.count+1) := 'OS_FONTS_ID';
		end if;

		if pr_fq_rslt.browser_lang_id_score > 0 then
			la_cols(la_cols.count+1) := 'BROWSER_LANG_ID';
		end if;

		if pr_fq_rslt.timezone_score > 0 then
			la_cols(la_cols.count+1) := 'TIMEZONE';
		end if;

		if pr_fq_rslt.platform_id_score > 0 then
			la_cols(la_cols.count+1) := 'PLATFORM_ID';
		end if;

		if pr_fq_rslt.plugins_score > 0 then
			la_cols(la_cols.count+1) := 'PLUGINS';
		end if;

		if pr_fq_rslt.use_of_local_storage_score > 0 then
			la_cols(la_cols.count+1) := 'USE_OF_LOCAL_STORAGE';
		end if;

		if pr_fq_rslt.use_of_sess_storage_score > 0 then
			la_cols(la_cols.count+1) := 'USE_OF_SESS_STORAGE';
		end if;

		if pr_fq_rslt.indexed_db_score > 0 then
			la_cols(la_cols.count+1) := 'INDEXED_DB';
		end if;

		if pr_fq_rslt.do_not_track_score > 0 then
			la_cols(la_cols.count+1) := 'DO_NOT_TRACK';
		end if;

		if pr_fq_rslt.has_lied_langs_score > 0 then
			la_cols(la_cols.count+1) := 'HAS_LIED_LANGS';
		end if;

		if pr_fq_rslt.has_lied_os_score > 0 then
			la_cols(la_cols.count+1) := 'HAS_LIED_OS';
		end if;

		if pr_fq_rslt.has_lied_browser_score > 0 then
			la_cols(la_cols.count+1) := 'HAS_LIED_BROWSER';
		end if;

		if pr_fq_rslt.webgl_vendor_renderer_id_score > 0 then
			la_cols(la_cols.count+1) := 'WEBGL_VENDOR_RENDERER';
		end if;

		if pr_fq_rslt.cookies_enabled_score > 0 then
			la_cols(la_cols.count+1) := 'COOKIES_ENABLED';
		end if;

		if pr_fq_rslt.touch_sup_score > 0 then
			la_cols(la_cols.count+1) := 'TOUCH_SUP';
		end if;

		if pr_fq_rslt.connection_type_score > 0 then
			la_cols(la_cols.count+1) := 'CONNECTION_TYPE';
		end if;

		if pr_fq_rslt.webrtc_fp_score > 0 then
			la_cols(la_cols.count+1) := 'WEBRTC_FP';
		end if;

		if pr_fq_rslt.aud_codecs_id_score > 0 then
			la_cols(la_cols.count+1) := 'VID_CODECS_ID';
		end if;

		if pr_fq_rslt.vid_codecs_id_score > 0 then
			la_cols(la_cols.count+1) := 'AUD_CODECS_ID';
		end if;

		if pr_fq_rslt.user_agent_os_id_score > 0 then
			la_cols(la_cols.count+1) := 'USER_AGENT_OS_ID';
		end if;

		if pr_fq_rslt.user_agent_browser_id_score > 0 then
			la_cols(la_cols.count+1) := 'USER_AGENT_BROWSER_ID';
		end if;

		if pr_fq_rslt.user_agent_engine_id_score > 0 then
			la_cols(la_cols.count+1) := 'USER_AGENT_ENGINE_ID';
		end if;

		if pr_fq_rslt.user_agent_device_id_score > 0 then
			la_cols(la_cols.count+1) := 'USER_AGENT_DEVICE_ID';
		end if;

		if pr_fq_rslt.disp_color_depth_score > 0 then
			la_cols(la_cols.count+1) := 'DISP_COLOR_DEPTH';
		end if;

		if pr_fq_rslt.disp_screen_res_ratio_score > 0 then
			la_cols(la_cols.count+1) := 'DISP_SCREEN_RES_RATIO';
		end if;

		--[(Abhishek Sharma : 02112016) : Fetch the list of Attributes along with their entropy values for the ones qualified with extact match.]
		for iCols in 1..la_cols.count loop
			for iEnt in 1..pa_dfp_entropy.count loop
				if la_cols(iCols) = pa_dfp_entropy(iEnt).column_name then
					la_attrib_dtl(lv_attrib_size).attrib_names := pa_dfp_entropy(iEnt).column_name;
					la_attrib_dtl(lv_attrib_size).attrib_type := null;
					la_attrib_dtl(lv_attrib_size).attrib_entropy := nvl(pa_dfp_entropy(iEnt).pre_computed_entropy,pa_dfp_entropy(iEnt).calculated_entropy);
					la_attrib_dtl(lv_attrib_size).match_flags := 1;
					lv_attrib_size := lv_attrib_size + 1;
					exit;
				end if;
			end loop;
		end loop;

		lv_score := pkg_fq_demo.calc_conditional_prob(pa_attrib_dtl => la_attrib_dtl);

		if lv_score > 100 then
			lv_score := 100;
		end if;
		pr_fq_rslt.tot_score  := trunc(lv_score);
	end compute_total_score;

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(02-11-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description:
		--	Routine: compute_total_score
		--		1) Fetch the list of Attributes along with their entropy values for the ones qualified with extact match.

		-- Created(06-08-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.1';
	end;
end pkg_dfp_fq;
/

prompt Done.

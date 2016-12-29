prompt
prompt Creating package pkg_dfp_ext
prompt ==================================
prompt
create or replace package pkg_dfp_ext is
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
	-- Created : 22-09-2016
	-- Purpose : The Device Fingerprinting Extensiblity package



	--Optimal batch size for a listener to retreive from the request queue.
	-- If null then the constant pkg_dfp_listener.mc_batch_size is used (default 1000)
	gc_lsnr_optml_batch_sz			constant number := 5; --Max # of records to read in one processing cycle
	
	--This will add a "nsd.ref_num != pad.ref_num" clause to the PQ sql.
	--For those configurations where PAD table is same as NSD table in batch mode DFPing
	--  this is ignored and relaced with "nsd.ref_num > pad.ref_num" to avoid the same pair
	--  being matched twice
	gc_pq_ref_num_inequality_chk	constant number(1) := 0; --0=false 1=true

	--Threshold on # of PQ results to be evaluated
	gc_pq_eval_cnt_thld				constant number := 200;

	--Threshold on max time in processing PQ results (in centi seconds, i.e. "100" = 1 second) - for each rectype !
	-- Increase 25 to 300
	gc_pq_eval_time_thld			constant number := 300; --i.e. do not spend more then 1/4th of second in the processing loop (for each rectype), exit earlier

	-- Assign the max length of the attrbiute allowed to be inserted in the DFP Pad.
	gc_len_master_device_id			constant number := 400;
	gc_len_ref_num					constant number := 400;
	gc_len_session_id				constant number := 400;
	gc_len_rec_type					constant number := 400;
	gc_len_user_agent_os			constant number := 120;
	gc_len_user_agent_browser		constant number := 200;
	gc_len_user_agent_engine		constant number := 120;
	gc_len_user_agent_device		constant number := 120;
	gc_len_cpu_arch					constant number := 120;
	gc_len_canvas_fp				constant number := 120;
	gc_len_http_head_accept			constant number := 400;
	gc_len_content_encoding			constant number := 120;
	gc_len_content_lang				constant number := 200;
	gc_len_ip_address				constant number := 80;
	gc_len_ip_address_octet			constant number := 80;
	gc_len_os_fonts					constant number := 4000;
	gc_len_browser_lang				constant number := 200;
	gc_len_disp_color_depth			constant number := 80;
	gc_len_disp_screen_res_ratio	constant number := 22;
	gc_len_timezone					constant number := 40;
	gc_len_platform					constant number := 80;
	gc_len_plugins					constant number := 1600;
	gc_len_use_of_local_storage		constant number := 1;
	gc_len_use_of_sess_storage		constant number := 1;
	gc_len_indexed_db				constant number := 1;
	gc_len_do_not_track				constant number := 1;
	gc_len_has_lied_langs			constant number := 1;
	gc_len_has_lied_os				constant number := 1;
	gc_len_has_lied_browser			constant number := 1;
	gc_len_webgl_vendor_renderer	constant number := 400;
	gc_len_cookies_enabled			constant number := 40;
	gc_len_touch_sup				constant number := 1;
	gc_len_connection_type			constant number := 80;
	gc_len_webrtc_fp				constant number := 80;
	gc_len_aud_codecs				constant number := 800;
	gc_len_vid_codecs				constant number := 4000;
	
	--Description:	For realtime aliaising, this routine is responsible for any cleanups (upper case conversion, validation),
	--				removing comma/dashes from ID/tax etc... that is required for the specific input.
	--				By default, the only cleanup that happend in PKG_DFP_API is trim for spaces, and substr for max length
	--				based on the max length defined in PKG_DFP_EXT.gc_maxlen* columns
	--Parameters:
	--	1) pr_dfp_idx_pad_data
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	3) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure clean_payload(pr_dfp_idx_pad_data in out nocopy ty_dfp_match_param,
							pv_status_cd out number,
							pv_status_msg out varchar2);
	
	--Description:	For realtime aliaising, this routine is responsible for any cleanups (upper case conversion, validation),
	--				removing comma/dashes from ID/tax etc... that is required for the specific input.
	--				By default, the only cleanup that happend in PKG_DFP_API is trim for spaces, and substr for max length
	--				based on the max length defined in PKG_DFP_EXT.gc_maxlen* columns
	--Parameters:
	--	1) pr_dfp_idx_pad_data
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	3) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure validate_payload(	pr_dfp_idx_pad_data in out nocopy ty_dfp_match_param,
								pv_status_cd out number,
								pv_status_msg out varchar2);
	
	--Description:	For realtime aliaising, called AFTER the data is indexed.
	--				This routine can customized to handle clean up of indexed data for corrupt/irregular data.
	--Parameters:
	--	1) pr_entity_rec
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_index_entity_info(	pr_entity_rec in out nocopy ty_dfp_idx_pad,
										pv_status_msg out varchar2,
										pv_status_cd out number);
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure pre_process_payload( pr_dfp_payload in out nocopy ty_dfp_payload);
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_process_payload( pr_dfp_payload in out nocopy ty_dfp_payload);
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_de_process_payload(pr_dfp_payload in out nocopy ty_dfp_payload);
	
	--Description:	Supply a customized hint for the PQ SQL. If null, a default hint is used
	--Parameters:
	--	1) pv_thread_id
	--		parameter mode = IN
	--		description = will accept the job thread id.
	--Performance:	TBD
	function get_pq_sql_hint(pv_thread_id in number) return varchar2;

	--Description:	Intercept to customize the output of pkg_dfp_pq.get_pq_sql. The SQL requrned by this routine is essentially a "insert into <result table> select a.rowid, b.rowid... from PAD a, NSD b where <match sql 1> and <match sql 2> etc.
	--Parameters:
	--	1) pv_pad_table
	--		parameter mode = IN
	--		description = will accept the pad table name.
	--	1) pv_nsd_table
	--		parameter mode = IN
	--		description = will accept the req global table name.
	--	1) pv_rslt_table
	--		parameter mode = IN
	--		description = will accept the result table name.
	--	1) pv_pass
	--		parameter mode = IN
	--		description = will accept the pass number.
	--	1) pv_sql
	--		parameter mode = IN OUT
	--		description = will accept and return the update sql.
	--Performance:	TBD
	procedure get_pq_sql(	pv_pad_table in varchar2,
							pv_nsd_table in varchar2,
							pv_rslt_table in varchar2,
							pv_pass in number,
							pv_sql in out varchar2);
	
	--Description:	Intercept to customize the output of pkg_DFP_pq.get_match_sql. This can be used to
	--				incroduce custom hints to the SQL. The function below build the where  clause for a specific
	--				attribute (identified by pv_nsd_grp_id/pv_pad_grp_id)
	--Parameters:
	--	1) pv_match_type
	--		parameter mode = IN
	--		description = will accept the match type of the attribute.
	--	1) pv_attrib_name
	--		parameter mode = IN
	--		description = will accept the name of the attribute.
	--	1) pv_column_name
	--		parameter mode = IN
	--		description = will accept the column corresponding to the attribute.
	--	1) pv_match_degree
	--		parameter mode = IN
	--		description = will accept the match degree of the attribute.
	--Performance:	None
	function get_match_sql(	pv_match_weight in varchar2,
							pv_attrib_name in varchar2,
							pv_column_name in varchar2,
							pv_match_degree in varchar2,
							pv_curr_match_sql in varchar2) return varchar2;
	
	--Description:	Extensibility routine to load the Request data into the global table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_req_into_gtt(	pr_dfp_payload in out nocopy ty_dfp_payload,
									pv_status_cd out number,
									pv_status_msg out varchar2);
		
	--Description:	Extensibility routine to load the Request data into the request table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_req_data(pr_dfp_payload in out nocopy ty_dfp_payload,
							pv_status_cd out number,
							pv_status_msg out varchar2);
		
	--Description:	For realtime DFPing, this routine can be customized to return the ref cursor that
	--				is used to process the results from PQ result table by PKG_DFP_API.
	--Parameters:
	--	1) pv_ref_num
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pc_pq_rslt
	--		parameter mode = OUT
	--		description = will store pq result sql.
	--Performance:	TBD
	procedure get_pq_rslt_cursor(	pv_ref_num in varchar2,
									pc_pq_rslt out sys_refcursor);
	
	--Description:	This routine can be customized to adjust atribute scoring (after they are scored in de processor) for example to apply blacklists, or perform supression etc...
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pr_pad_rec
	--		parameter mode = IN
	--		description = will store pad record dataset.
	--	2) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will store fq record dataset.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_attrib_scoring_adj(	pr_dfp_payload in ty_dfp_payload,
										pr_pad_rec in ty_dfp_pq_rslt,
										pr_fq_rslt in out nocopy ty_dfp_fq_rslt);

	--Description:	This routine can be customized to compute the total score from various attribute score
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will store fq record dataset.
	--	3) pv_handled_in_ext
	--		parameter mode = OUT
	--		description = will store handel ext.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure compute_fq_total_score(	pr_dfp_payload in ty_dfp_payload,
										pr_fq_rslt in out nocopy ty_dfp_fq_rslt,
										pv_handled_in_ext out boolean);
	
	--Description:	For realtime dfp, this can be used to customize the qualification criteria based on the scores obtained for various attributes and total score.
	--Parameters:
	--	1) pr_fq_rslt
	--		parameter mode = IN
	--		description = contains the attribute scores and the total score.
	--	2) pr_pq_rslt
	--		parameter mode = IN
	--		description = contains the PQ record (all the attributes of the matched PAD record)
	--	3) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store DFP payload attributes.
	--	4) pv_qldf_status
	--		parameter mode = OUT
	--		description = will store true or false.
	--	5) pv_handled_in_ext
	--		parameter mode = OUT
	--		description = will store handel ext.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure evaluate_scores_for_fq(	pr_fq_rslt in ty_dfp_fq_rslt,
										pr_pq_rslt in ty_dfp_pq_rslt,
										pr_dfp_payload in ty_dfp_payload,
										pv_qldf_status out boolean,
										pv_handled_in_ext out boolean);
	
	--Description:	Routine to return the record type of DFP_LOG
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the DFP Payload array.
	--	2) pr_dfp_log
	--		parameter mode = OUT
	--		description = will store the dfp_log array dataset
	--Performance:	None
	--Return: varchar2
	procedure convert_log_tosqltype(pr_dfp_payload in ty_dfp_payload,
									pr_dfp_log out dfp_log%rowtype);
	
	--Description:	Routine to generate new MDI if no existing MDI is allocated.
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the DFP Payload array.
	--Performance:	None
	--Return: varchar2
	procedure gen_mdi(pr_dfp_payload in out nocopy ty_dfp_payload);
	
	--Description:	Extensibility routine to load the Active Pad data into the pad table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_pad_data(pr_dfp_payload in out nocopy ty_dfp_payload,
							pv_status_cd out number,
							pv_status_msg out varchar2);
		
	--Description:	Extensibility routine to Check if the provided session id is avaliable in processed before or not.
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the current request session id.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure check_dup_session(pv_session_id in varchar2,
							pv_status_cd out number,
							pv_status_msg out varchar2);

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_ext;
/

prompt
prompt Creating package Body pkg_dfp_ext
prompt ==================================
prompt
create or replace package body pkg_dfp_ext is

	--Description:	For realtime aliaising, this routine is responsible for any cleanups (upper case conversion, validation),
	--				removing comma/dashes from ID/tax etc... that is required for the specific input.
	--				By default, the only cleanup that happend in PKG_DFP_API is trim for spaces, and substr for max length
	--				based on the max length defined in PKG_DFP_EXT.gc_maxlen* columns
	--Parameters:
	--	1) pr_dfp_idx_pad_data
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	3) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure clean_payload(pr_dfp_idx_pad_data in out nocopy ty_dfp_match_param,
							pv_status_cd out number,
							pv_status_msg out varchar2)
	is
	begin
		pv_status_cd := 0;
		pv_status_msg := 'Success';
		
		pr_dfp_idx_pad_data.master_device_id := upper(pr_dfp_idx_pad_data.master_device_id);
		pr_dfp_idx_pad_data.ref_num := upper(pr_dfp_idx_pad_data.ref_num);
		pr_dfp_idx_pad_data.session_id := upper(pr_dfp_idx_pad_data.session_id);
		pr_dfp_idx_pad_data.rec_type := upper(pr_dfp_idx_pad_data.rec_type);
		pr_dfp_idx_pad_data.user_agent_os := upper(pr_dfp_idx_pad_data.user_agent_os);
		pr_dfp_idx_pad_data.user_agent_browser := upper(pr_dfp_idx_pad_data.user_agent_browser);
		pr_dfp_idx_pad_data.user_agent_engine := upper(pr_dfp_idx_pad_data.user_agent_engine);
		pr_dfp_idx_pad_data.user_agent_device := upper(pr_dfp_idx_pad_data.user_agent_device);
		pr_dfp_idx_pad_data.cpu_arch := upper(pr_dfp_idx_pad_data.cpu_arch);
		pr_dfp_idx_pad_data.canvas_fp := upper(pr_dfp_idx_pad_data.canvas_fp);
		pr_dfp_idx_pad_data.http_head_accept := upper(pr_dfp_idx_pad_data.http_head_accept);
		pr_dfp_idx_pad_data.content_encoding := upper(pr_dfp_idx_pad_data.content_encoding);
		pr_dfp_idx_pad_data.content_lang := upper(pr_dfp_idx_pad_data.content_lang);
		pr_dfp_idx_pad_data.ip_address := upper(pr_dfp_idx_pad_data.ip_address);
		pr_dfp_idx_pad_data.ip_address_octet := upper(pr_dfp_idx_pad_data.ip_address_octet);
		pr_dfp_idx_pad_data.os_fonts := upper(pr_dfp_idx_pad_data.os_fonts);
		pr_dfp_idx_pad_data.browser_lang := upper(pr_dfp_idx_pad_data.browser_lang);
		pr_dfp_idx_pad_data.disp_color_depth := upper(pr_dfp_idx_pad_data.disp_color_depth);
		pr_dfp_idx_pad_data.disp_screen_res_ratio := upper(pr_dfp_idx_pad_data.disp_screen_res_ratio);
		pr_dfp_idx_pad_data.timezone := upper(pr_dfp_idx_pad_data.timezone);
		pr_dfp_idx_pad_data.platform := upper(pr_dfp_idx_pad_data.platform);
		pr_dfp_idx_pad_data.plugins := upper(pr_dfp_idx_pad_data.plugins);
		pr_dfp_idx_pad_data.use_of_local_storage := upper(pr_dfp_idx_pad_data.use_of_local_storage);
		pr_dfp_idx_pad_data.use_of_sess_storage := upper(pr_dfp_idx_pad_data.use_of_sess_storage);
		pr_dfp_idx_pad_data.do_not_track := upper(pr_dfp_idx_pad_data.do_not_track);
		pr_dfp_idx_pad_data.has_lied_langs := upper(pr_dfp_idx_pad_data.has_lied_langs);
		pr_dfp_idx_pad_data.has_lied_os := upper(pr_dfp_idx_pad_data.has_lied_os);
		pr_dfp_idx_pad_data.has_lied_browser := upper(pr_dfp_idx_pad_data.has_lied_browser);
		pr_dfp_idx_pad_data.webgl_vendor_renderer := upper(pr_dfp_idx_pad_data.webgl_vendor_renderer);
		pr_dfp_idx_pad_data.cookies_enabled := upper(pr_dfp_idx_pad_data.cookies_enabled);
		pr_dfp_idx_pad_data.touch_sup := upper(pr_dfp_idx_pad_data.touch_sup);
		pr_dfp_idx_pad_data.connection_type := upper(pr_dfp_idx_pad_data.connection_type);
		pr_dfp_idx_pad_data.webrtc_fp := upper(pr_dfp_idx_pad_data.webrtc_fp);
		pr_dfp_idx_pad_data.aud_codecs := upper(pr_dfp_idx_pad_data.aud_codecs);
		pr_dfp_idx_pad_data.vid_codecs := upper(pr_dfp_idx_pad_data.vid_codecs);
		
	exception
		when others then
			pv_status_cd := 1;
			pv_status_msg := sqlerrm;
	end clean_payload;
	
	--Description:	For realtime aliaising, this routine is responsible for any cleanups (upper case conversion, validation),
	--				removing comma/dashes from ID/tax etc... that is required for the specific input.
	--				By default, the only cleanup that happend in PKG_DFP_API is trim for spaces, and substr for max length
	--				based on the max length defined in PKG_DFP_EXT.gc_maxlen* columns
	--Parameters:
	--	1) pr_dfp_idx_pad_data
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	3) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--Performance: Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure validate_payload(	pr_dfp_idx_pad_data in out nocopy ty_dfp_match_param,
								pv_status_cd out number,
								pv_status_msg out varchar2)
	is
		lv_blacklist_msg	varchar2(3000 char);
	begin
		--check for null or all zero's
		if pr_dfp_idx_pad_data.ref_num is null or ltrim(trim(pr_dfp_idx_pad_data.ref_num),'0') is null then
			pv_status_msg := 'Invalid ref_num, expected unique value, received:'|| nvl(pr_dfp_idx_pad_data.ref_num,'<<null>>');
			pv_status_cd := 1;
		elsif pr_dfp_idx_pad_data.session_id is null or ltrim(trim(pr_dfp_idx_pad_data.session_id),'0') is null then
			pv_status_msg := 'Invalid Session Id, expected unique value, received:'|| nvl(pr_dfp_idx_pad_data.session_id,'<<null>>');
			pv_status_cd := 1;
		--[(Abhishek Sharma : 06122016) : Check if the Master Device Id is Blacklisted or not.]
		elsif pr_dfp_idx_pad_data.master_device_id is not null then
			begin
				select	reason_code,comments into pv_status_cd,pv_status_msg
				from	dfp_blacklist_mdi
				where	master_device_id = pr_dfp_idx_pad_data.master_device_id;
			exception
				when no_data_found then
					lv_blacklist_msg := null;
			end;
			
			if pv_status_msg is null then
				pv_status_msg := 'Existing MDI Request.';
				pv_status_cd := 1;
			end if;
		else
			pv_status_cd := 0;
		end if;
	end validate_payload;
	
	--Description:	For realtime aliaising, called AFTER the data is indexed.
	--				This routine can customized to handle clean up of indexed data for corrupt/irregular data.
	--Parameters:
	--	1) pr_entity_rec
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_msg
	--		parameter mode = OUT
	--		description = will accept the match status message.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will accept the match status code.
	--	4) pv_ignore_excl_list
	--		parameter mode = IN
	--		description = will accept the if exclusion list is to be ignored or not.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_index_entity_info(	pr_entity_rec in out nocopy ty_dfp_idx_pad,
										pv_status_msg out varchar2,
										pv_status_cd out number)
	is
	begin
		pv_status_cd := 0;
		pv_status_msg := 'Success';
	end post_index_entity_info;
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure pre_process_payload( pr_dfp_payload in out nocopy ty_dfp_payload)
	is
	begin
		null;
	end pre_process_payload;
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_process_payload( pr_dfp_payload in out nocopy ty_dfp_payload)
	is
	begin
		--Load the request data into the table dfp_idx_req_t1
		null;
	end post_process_payload;
	
	--Description:	Pre processing of the payload.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the parameters/column value for the DFP Pad.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_de_process_payload( pr_dfp_payload in out nocopy ty_dfp_payload)
	is
	begin
		null;
	end post_de_process_payload;
	
	--Description:	Supply a customized hint for the PQ SQL. If null, a default hint is used
	--Parameters:
	--	1) pv_thread_id
	--		parameter mode = IN
	--		description = will accept the job thread id.
	--Performance:	TBD
	function get_pq_sql_hint(pv_thread_id in number) return varchar2 is
		lv_sql_hint varchar2(2000);
	begin
		lv_sql_hint := '/*+ PARALLEL(a, '|| to_char(least(pkg_dfp_utils.get_system_cpu_count,gc_lsnr_optml_batch_sz)) || ') */';
		return lv_sql_hint;
	end get_pq_sql_hint;
	
	--Description:	Intercept to customize the output of pkg_dfp_pq.get_pq_sql. The SQL requrned by this routine is essentially a "insert into <result table> select a.rowid, b.rowid... from PAD a, NSD b where <match sql 1> and <match sql 2> etc.
	--Parameters:
	--	1) pv_pad_table
	--		parameter mode = IN
	--		description = will accept the pad table name.
	--	1) pv_nsd_table
	--		parameter mode = IN
	--		description = will accept the req global table name.
	--	1) pv_rslt_table
	--		parameter mode = IN
	--		description = will accept the result table name.
	--	1) pv_pass
	--		parameter mode = IN
	--		description = will accept the pass number.
	--	1) pv_sql
	--		parameter mode = IN OUT
	--		description = will accept and return the update sql.
	--Performance:	TBD
	procedure get_pq_sql(	pv_pad_table in varchar2,
							pv_nsd_table in varchar2,
							pv_rslt_table in varchar2,
							pv_pass in number,
							pv_sql in out varchar2) is
	begin
		null;
	end;

	--Description:	Intercept to customize the output of pkg_dfp_pq.get_match_sql. This can be used to
	--				incroduce custom hints to the SQL. The function below build the where  clause for a specific
	--				attribute (identified by pv_nsd_grp_id/pv_pad_grp_id)
	--Parameters:
	--	1) pv_match_weight
	--		parameter mode = IN
	--		description = will accept the match type of the attribute.
	--	1) pv_attrib_name
	--		parameter mode = IN
	--		description = will accept the name of the attribute.
	--	1) pv_column_name
	--		parameter mode = IN
	--		description = will accept the column corresponding to the attribute.
	--	1) pv_match_degree
	--		parameter mode = IN
	--		description = will accept the match degree of the attribute.
	--Performance:	None
	function get_match_sql(	pv_match_weight in varchar2,
							pv_attrib_name in varchar2,
							pv_column_name in varchar2,
							pv_match_degree in varchar2,
							pv_curr_match_sql in varchar2) return varchar2 is
	begin
		--Write custom code to modify the match SQL, or return a customized match SQL
		-- Note: This routine can also be used to temporarily debug/trace the output
		--If no customizations are required, then return the current match SQL as it is
		return pv_curr_match_sql;
	end get_match_sql;

	--Description:	Extensibility routine to load the Request data into the global table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_req_into_gtt(pr_dfp_payload in out nocopy ty_dfp_payload,
							pv_status_cd out number,
							pv_status_msg out varchar2) is
	begin
		--[(Abhishek Sharma : 07112016) : Assign the status code and message as per the previoud status only.]
		pv_status_cd := pr_dfp_payload.dfp_log_data.status_cd;
		pv_status_msg := pr_dfp_payload.dfp_log_data.status_msg;
		
		-- Load the req data before MDI generation
		--Truncate the gtt table
		execute immediate 'truncate table dfp_idx_req_t1_l1';

		--[(Abhishek Sharma : 23112016) : Performance changes.]
		-- Load the request data into dfp_idx_req_t1_l1 using 
		insert /*+ APPEND_VALUES */into dfp_idx_req_t1_l1 (
					master_device_id,
					ref_num,
					session_id,
					rec_type,
					rec_dt,
					user_agent_os_id,
					user_agent_browser_id,
					user_agent_engine_id,
					user_agent_device_id,
					cpu_arch_id,
					canvas_fp,
					http_head_accept_id,
					content_encoding_id,
					content_lang_id,
					ip_address,
					ip_address_octet,
					os_fonts_id,
					browser_lang_id,
					disp_color_depth,
					disp_screen_res_ratio,
					timezone,
					platform_id,
					plugins,
					use_of_local_storage,
					use_of_sess_storage,
					indexed_db,
					do_not_track,
					has_lied_langs,
					has_lied_os,
					has_lied_browser,
					webgl_vendor_renderer_id,
					cookies_enabled,
					touch_sup,
					connection_type,
					webrtc_fp,
					aud_codecs_id,
					vid_codecs_id
				)
		values (	pr_dfp_payload.dfp_idx_pad_data.master_device_id,
					pr_dfp_payload.dfp_idx_pad_data.ref_num,
					pr_dfp_payload.dfp_idx_pad_data.session_id,
					pr_dfp_payload.dfp_idx_pad_data.rec_type,
					pr_dfp_payload.dfp_idx_pad_data.rec_dt,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_os_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_browser_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_engine_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_device_id,
					pr_dfp_payload.dfp_idx_pad_data.cpu_arch_id,
					pr_dfp_payload.dfp_idx_pad_data.canvas_fp,
					pr_dfp_payload.dfp_idx_pad_data.http_head_accept_id,
					pr_dfp_payload.dfp_idx_pad_data.content_encoding_id,
					pr_dfp_payload.dfp_idx_pad_data.content_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.ip_address,
					pr_dfp_payload.dfp_idx_pad_data.ip_address_octet,
					pr_dfp_payload.dfp_idx_pad_data.os_fonts_id,
					pr_dfp_payload.dfp_idx_pad_data.browser_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.disp_color_depth,
					pr_dfp_payload.dfp_idx_pad_data.disp_screen_res_ratio,
					pr_dfp_payload.dfp_idx_pad_data.timezone,
					pr_dfp_payload.dfp_idx_pad_data.platform_id,
					pr_dfp_payload.dfp_idx_pad_data.plugins,
					pr_dfp_payload.dfp_idx_pad_data.use_of_local_storage,
					pr_dfp_payload.dfp_idx_pad_data.use_of_sess_storage,
					pr_dfp_payload.dfp_idx_pad_data.indexed_db,
					pr_dfp_payload.dfp_idx_pad_data.do_not_track,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_langs,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_os,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_browser,
					pr_dfp_payload.dfp_idx_pad_data.webgl_vendor_renderer_id,
					pr_dfp_payload.dfp_idx_pad_data.cookies_enabled,
					pr_dfp_payload.dfp_idx_pad_data.touch_sup,
					pr_dfp_payload.dfp_idx_pad_data.connection_type,
					pr_dfp_payload.dfp_idx_pad_data.webrtc_fp,
					pr_dfp_payload.dfp_idx_pad_data.aud_codecs_id,
					pr_dfp_payload.dfp_idx_pad_data.vid_codecs_id
			);
		commit;
	exception
		when others then
			pv_status_cd := 1;
			pv_status_msg := sqlerrm;
	end load_req_into_gtt;
		
	--Description:	Extensibility routine to load the Request data into the request table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_req_data(pr_dfp_payload in out nocopy ty_dfp_payload,
							pv_status_cd out number,
							pv_status_msg out varchar2) is
	begin
		--[(Abhishek Sharma : 07112016) : Assign the status code and message as per the previoud status only.]
		pv_status_cd := pr_dfp_payload.dfp_log_data.status_cd;
		pv_status_msg := pr_dfp_payload.dfp_log_data.status_msg;
		
		--[(Abhishek Sharma : 23112016) : Performance changes.]
		insert /*+ APPEND_VALUES */into dfp_idx_req_t1(
					master_device_id,
					ref_num,
					session_id,
					rec_type,
					rec_dt,
					user_agent_os_id,
					user_agent_browser_id,
					user_agent_engine_id,
					user_agent_device_id,
					cpu_arch_id,
					canvas_fp,
					http_head_accept_id,
					content_encoding_id,
					content_lang_id,
					ip_address,
					ip_address_octet,
					os_fonts_id,
					browser_lang_id,
					disp_color_depth,
					disp_screen_res_ratio,
					timezone,
					platform_id,
					plugins,
					use_of_local_storage,
					use_of_sess_storage,
					indexed_db,
					do_not_track,
					has_lied_langs,
					has_lied_os,
					has_lied_browser,
					webgl_vendor_renderer_id,
					cookies_enabled,
					touch_sup,
					connection_type,
					webrtc_fp,
					aud_codecs_id,
					vid_codecs_id,
					update_dt)
		values (	pr_dfp_payload.dfp_idx_pad_data.master_device_id,
					pr_dfp_payload.dfp_idx_pad_data.ref_num,
					pr_dfp_payload.dfp_idx_pad_data.session_id,
					pr_dfp_payload.dfp_idx_pad_data.rec_type,
					pr_dfp_payload.dfp_idx_pad_data.rec_dt,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_os_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_browser_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_engine_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_device_id,
					pr_dfp_payload.dfp_idx_pad_data.cpu_arch_id,
					pr_dfp_payload.dfp_idx_pad_data.canvas_fp,
					pr_dfp_payload.dfp_idx_pad_data.http_head_accept_id,
					pr_dfp_payload.dfp_idx_pad_data.content_encoding_id,
					pr_dfp_payload.dfp_idx_pad_data.content_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.ip_address,
					pr_dfp_payload.dfp_idx_pad_data.ip_address_octet,
					pr_dfp_payload.dfp_idx_pad_data.os_fonts_id,
					pr_dfp_payload.dfp_idx_pad_data.browser_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.disp_color_depth,
					pr_dfp_payload.dfp_idx_pad_data.disp_screen_res_ratio,
					pr_dfp_payload.dfp_idx_pad_data.timezone,
					pr_dfp_payload.dfp_idx_pad_data.platform_id,
					pr_dfp_payload.dfp_idx_pad_data.plugins,
					pr_dfp_payload.dfp_idx_pad_data.use_of_local_storage,
					pr_dfp_payload.dfp_idx_pad_data.use_of_sess_storage,
					pr_dfp_payload.dfp_idx_pad_data.indexed_db,
					pr_dfp_payload.dfp_idx_pad_data.do_not_track,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_langs,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_os,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_browser,
					pr_dfp_payload.dfp_idx_pad_data.webgl_vendor_renderer_id,
					pr_dfp_payload.dfp_idx_pad_data.cookies_enabled,
					pr_dfp_payload.dfp_idx_pad_data.touch_sup,
					pr_dfp_payload.dfp_idx_pad_data.connection_type,
					pr_dfp_payload.dfp_idx_pad_data.webrtc_fp,
					pr_dfp_payload.dfp_idx_pad_data.aud_codecs_id,
					pr_dfp_payload.dfp_idx_pad_data.vid_codecs_id,
					sysdate
				);
		commit;
	exception
		when others then
			pv_status_cd := 1;
			pv_status_msg := sqlerrm;
	end load_req_data;
		
	--Description:	For realtime DFPing, this routine can be customized to return the ref cursor that
	--				is used to process the results from PQ result table by PKG_DFP_API.
	--Parameters:
	--	1) pv_ref_num
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pc_pq_rslt
	--		parameter mode = OUT
	--		description = will store pq result sql.
	--Performance:	TBD
	procedure get_pq_rslt_cursor(	pv_ref_num in varchar2,
									pc_pq_rslt out sys_refcursor) is
		lv_sql			varchar2(10000);
		lv_idx_table	varchar2(100);
	begin
		--[(Abhishek Sharma : 23112016) : Performance changes.]
		lv_sql := 'with src_uniq as (	select	master_device_id,max(rowid) as any_row_id,count(*) as pass_count'||chr(10);
		lv_sql := lv_sql||'					from	dfp_rslt_pq_t1_l1'||chr(10);
		lv_sql := lv_sql||'					group by master_device_id'||chr(10);
		lv_sql := lv_sql||'				)'||chr(10);
		lv_sql := lv_sql||'select	ty_dfp_pq_rslt(	time_key,pass,'||chr(10);
		lv_sql := lv_sql||'						src_uniq.pass_count,req_ref_num,'||chr(10);
		lv_sql := lv_sql||'						pq.master_device_id,ref_num,'||chr(10);
		lv_sql := lv_sql||'						session_id,rec_type,'||chr(10);
		lv_sql := lv_sql||'						pq.rec_dt,'||chr(10);
		lv_sql := lv_sql||'						user_agent_os_id,user_agent_browser_id,'||chr(10);
		lv_sql := lv_sql||'						user_agent_engine_id,user_agent_device_id,'||chr(10);
		lv_sql := lv_sql||'						cpu_arch_id,canvas_fp,'||chr(10);
		lv_sql := lv_sql||'						http_head_accept_id,content_encoding_id,'||chr(10);
		lv_sql := lv_sql||'						content_lang_id,ip_address,'||chr(10);
		lv_sql := lv_sql||'						ip_address_octet,os_fonts_id,'||chr(10);
		lv_sql := lv_sql||'						browser_lang_id,'||chr(10);
		lv_sql := lv_sql||'						disp_color_depth,'||chr(10);
		lv_sql := lv_sql||'						disp_screen_res_ratio,timezone,'||chr(10);
		lv_sql := lv_sql||'						platform_id,plugins,'||chr(10);
		lv_sql := lv_sql||'						use_of_local_storage,use_of_sess_storage,indexed_db,'||chr(10);
		lv_sql := lv_sql||'						do_not_track,has_lied_langs,'||chr(10);
		lv_sql := lv_sql||'						has_lied_os,has_lied_browser,'||chr(10);
		lv_sql := lv_sql||'						webgl_vendor_renderer_id,cookies_enabled,'||chr(10);
		lv_sql := lv_sql||'						touch_sup,connection_type,'||chr(10);
		lv_sql := lv_sql||'						webrtc_fp,'||chr(10);
		lv_sql := lv_sql||'						aud_codecs_id,vid_codecs_id)'||chr(10);
		lv_sql := lv_sql||'from	dfp_rslt_pq_t1_l1 pq,'||chr(10);
		lv_sql := lv_sql||'		src_uniq'||chr(10);
		lv_sql := lv_sql||'where	pq.rowid = src_uniq.any_row_id '||chr(10);
		--lv_sql := lv_sql||'order by pq.rec_dt desc,pq.master_device_id';
		
		open pc_pq_rslt for lv_sql;
	end get_pq_rslt_cursor;
	
	--Description:	This routine can be customized to adjust atribute scoring (after they are scored in de processor) for example to apply blacklists, or perform supression etc...
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pr_pad_rec
	--		parameter mode = IN
	--		description = will store pad record dataset.
	--	3) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will store fq record dataset.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure post_attrib_scoring_adj(	pr_dfp_payload in ty_dfp_payload,
										pr_pad_rec in ty_dfp_pq_rslt,
										pr_fq_rslt in out nocopy ty_dfp_fq_rslt) is
	begin
		null;
	end post_attrib_scoring_adj;
	
	--Description:	This routine can be customized to compute the total score from various attribute score
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store the request ref number.
	--	2) pr_fq_rslt
	--		parameter mode = IN OUT
	--		description = will store fq record dataset.
	--	3) pv_handled_in_ext
	--		parameter mode = OUT
	--		description = will store handel ext.
	--Performance:
	--  Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure compute_fq_total_score(	pr_dfp_payload in ty_dfp_payload,
										pr_fq_rslt in out nocopy ty_dfp_fq_rslt,
										pv_handled_in_ext out boolean) is
		--lv_score		number;
		--lv_source_type	number(5);
		--lv_email_score	number(5) := 0;
	begin
		pv_handled_in_ext := false;
	--exception
	--	when others then
			--dbms_output.put_line(sqlerrm);
	end compute_fq_total_score;
	
	--Description:	For realtime dfp, this can be used to customize the qualification criteria based on the scores obtained for various attributes and total score.
	--Parameters:
	--	1) pr_fq_rslt
	--		parameter mode = IN
	--		description = contains the attribute scores and the total score.
	--	2) pr_pq_rslt
	--		parameter mode = IN
	--		description = contains the PQ record (all the attributes of the matched PAD record)
	--	3) pr_dfp_payload
	--		parameter mode = IN
	--		description = will store DFP payload attributes.
	--	4) pv_qldf_status
	--		parameter mode = OUT
	--		description = will store true or false.
	--	5) pv_handled_in_ext
	--		parameter mode = OUT
	--		description = will store handel ext.
	--Performance:	Realtime, DO NOT ADD ANY DB QUERIES HERE, ALL OPERATIONS SHOULD BE IN MEMORY
	procedure evaluate_scores_for_fq(	pr_fq_rslt in ty_dfp_fq_rslt,
										pr_pq_rslt in ty_dfp_pq_rslt,
										pr_dfp_payload in ty_dfp_payload,
										pv_qldf_status out boolean,
										pv_handled_in_ext out boolean) is
	begin
		pv_qldf_status := false;
	end evaluate_scores_for_fq;
	
	--Description:	Routine to return the record type of DFP_LOG
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the DFP Payload array.
	--	2) pr_dfp_log
	--		parameter mode = OUT
	--		description = will store the dfp_log array dataset
	--Performance:	None
	--Return: varchar2
	procedure convert_log_tosqltype(pr_dfp_payload in ty_dfp_payload,
									pr_dfp_log out dfp_log%rowtype) is
	begin
		pr_dfp_log.master_device_id := pr_dfp_payload.dfp_log_data.master_device_id;
		pr_dfp_log.ref_num := pr_dfp_payload.dfp_log_data.ref_num;
		pr_dfp_log.session_id := pr_dfp_payload.dfp_log_data.session_id;
		pr_dfp_log.req_ts := pr_dfp_payload.dfp_log_data.req_ts;
		pr_dfp_log.tot_time := pr_dfp_payload.dfp_log_data.tot_time;
		pr_dfp_log.dim_id_time := pr_dfp_payload.dfp_log_data.dim_id_time;
		pr_dfp_log.idx_time := pr_dfp_payload.dfp_log_data.idx_time;
		pr_dfp_log.pq_tot_time := pr_dfp_payload.dfp_log_data.pq_tot_time;
		pr_dfp_log.pq_pass_time := pr_dfp_payload.dfp_log_data.pq_pass_time;
		pr_dfp_log.pq_match_cnt := pr_dfp_payload.dfp_log_data.pq_match_cnt;
		pr_dfp_log.fq_eval_cnt := pr_dfp_payload.dfp_log_data.fq_eval_cnt;
		pr_dfp_log.fq_match_cnt := pr_dfp_payload.dfp_log_data.fq_match_cnt;
		pr_dfp_log.fq_tot_time := pr_dfp_payload.dfp_log_data.fq_tot_time;
		pr_dfp_log.fq_eval_time := pr_dfp_payload.dfp_log_data.fq_eval_time;
		pr_dfp_log.fq_entropy_fetch_time := pr_dfp_payload.dfp_log_data.fq_entropy_fetch_time;
		pr_dfp_log.fq_rslt_load_time := pr_dfp_payload.dfp_log_data.fq_rslt_load_time;
		pr_dfp_log.req_load_time := pr_dfp_payload.dfp_log_data.req_load_time;
		pr_dfp_log.pad_load_time := pr_dfp_payload.dfp_log_data.pad_load_time;
		pr_dfp_log.status_cd := pr_dfp_payload.dfp_log_data.status_cd;
		pr_dfp_log.status_msg := pr_dfp_payload.dfp_log_data.status_msg;
	end convert_log_tosqltype;
	
	--Description:	Routine to generate new MDI if no existing MDI is allocated.
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the DFP Payload array.
	--Performance:	None
	--Return: varchar2
	procedure gen_mdi(pr_dfp_payload in out nocopy ty_dfp_payload) is
	begin
		if pr_dfp_payload.dfp_idx_pad_data.master_device_id is null then
			pr_dfp_payload.dfp_idx_pad_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.ref_num;
			pr_dfp_payload.dfp_log_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.master_device_id;
			pr_dfp_payload.dfp_log_data.status_msg := '[Success] : New MDI generated for this request.';
			
			--[(Abhishek Sharma : 02122016) : Insert the new Master Device Id into MDI Master table]
			insert into dfp_mdi_mst(master_device_id) values (pr_dfp_payload.dfp_idx_pad_data.master_device_id);
			commit;
		else
			pr_dfp_payload.dfp_log_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.master_device_id;
			pr_dfp_payload.dfp_log_data.status_msg := '[Success] : Existing MDI allocated for this request.';
		end if;
	end gen_mdi;
	
	--Description:	Extensibility routine to load the Active Pad data into the pad table)
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN
	--		description = will accept the parameters/column value for the DFP Pad.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure load_pad_data(pr_dfp_payload in out nocopy ty_dfp_payload,
							pv_status_cd out number,
							pv_status_msg out varchar2) is
	begin
		pv_status_cd := pr_dfp_payload.dfp_log_data.status_cd;
		pv_status_msg := pr_dfp_payload.dfp_log_data.status_msg;
		
		insert /*+ APPEND_VALUES */into dfp_idx_pad_t1(
					master_device_id,
					ref_num,
					session_id,
					rec_type,
					rec_dt,
					user_agent_os_id,
					user_agent_browser_id,
					user_agent_engine_id,
					user_agent_device_id,
					cpu_arch_id,
					canvas_fp,
					http_head_accept_id,
					content_encoding_id,
					content_lang_id,
					ip_address,
					ip_address_octet,
					os_fonts_id,
					browser_lang_id,
					disp_color_depth,
					disp_screen_res_ratio,
					timezone,
					platform_id,
					plugins,
					use_of_local_storage,
					use_of_sess_storage,
					indexed_db,
					do_not_track,
					has_lied_langs,
					has_lied_os,
					has_lied_browser,
					webgl_vendor_renderer_id,
					cookies_enabled,
					touch_sup,
					connection_type,
					webrtc_fp,
					aud_codecs_id,
					vid_codecs_id)
		values (	pr_dfp_payload.dfp_idx_pad_data.master_device_id,
					pr_dfp_payload.dfp_idx_pad_data.ref_num,
					pr_dfp_payload.dfp_idx_pad_data.session_id,
					pr_dfp_payload.dfp_idx_pad_data.rec_type,
					pr_dfp_payload.dfp_idx_pad_data.rec_dt,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_os_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_browser_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_engine_id,
					pr_dfp_payload.dfp_idx_pad_data.user_agent_device_id,
					pr_dfp_payload.dfp_idx_pad_data.cpu_arch_id,
					pr_dfp_payload.dfp_idx_pad_data.canvas_fp,
					pr_dfp_payload.dfp_idx_pad_data.http_head_accept_id,
					pr_dfp_payload.dfp_idx_pad_data.content_encoding_id,
					pr_dfp_payload.dfp_idx_pad_data.content_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.ip_address,
					pr_dfp_payload.dfp_idx_pad_data.ip_address_octet,
					pr_dfp_payload.dfp_idx_pad_data.os_fonts_id,
					pr_dfp_payload.dfp_idx_pad_data.browser_lang_id,
					pr_dfp_payload.dfp_idx_pad_data.disp_color_depth,
					pr_dfp_payload.dfp_idx_pad_data.disp_screen_res_ratio,
					pr_dfp_payload.dfp_idx_pad_data.timezone,
					pr_dfp_payload.dfp_idx_pad_data.platform_id,
					pr_dfp_payload.dfp_idx_pad_data.plugins,
					pr_dfp_payload.dfp_idx_pad_data.use_of_local_storage,
					pr_dfp_payload.dfp_idx_pad_data.use_of_sess_storage,
					pr_dfp_payload.dfp_idx_pad_data.indexed_db,
					pr_dfp_payload.dfp_idx_pad_data.do_not_track,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_langs,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_os,
					pr_dfp_payload.dfp_idx_pad_data.has_lied_browser,
					pr_dfp_payload.dfp_idx_pad_data.webgl_vendor_renderer_id,
					pr_dfp_payload.dfp_idx_pad_data.cookies_enabled,
					pr_dfp_payload.dfp_idx_pad_data.touch_sup,
					pr_dfp_payload.dfp_idx_pad_data.connection_type,
					pr_dfp_payload.dfp_idx_pad_data.webrtc_fp,
					pr_dfp_payload.dfp_idx_pad_data.aud_codecs_id,
					pr_dfp_payload.dfp_idx_pad_data.vid_codecs_id
				);
		commit;
	exception
		when others then
			pv_status_cd := 1;
			pv_status_msg := sqlerrm;
	end load_pad_data;
	
	--Description:	Extensibility routine to Check if the provided session id is avaliable in processed before or not.
	--Parameters:
	--	1) pv_session_id
	--		parameter mode = IN
	--		description = will accept the current request session id.
	--	2) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the process status code.
	--	4) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the process status message.
	--Performance:	None
	procedure check_dup_session(pv_session_id in varchar2,
								pv_status_cd out number,
								pv_status_msg out varchar2)
	is
		lv_exist	number := 0;
	begin
		select	count(1) into lv_exist
		from	dfp_log
		where	session_id = pv_session_id;
		
		if lv_exist = 0 then
			pv_status_cd := 0;
			pv_status_msg := 'Success';
		else
			pv_status_cd := 1;
			pv_status_msg := 'Duplicate session Found!';
		end if;
	end check_dup_session;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(06-12-2016): Abhishek Sharma
		-- Version: 1.0.4
		-- Description: 
		--	1) Routine: validate_payload
		--		1) Check if the Master Device Id is Blacklisted or not.
		
		-- Created(23-11-2016): Abhishek Sharma
		-- Version: 1.0.3
		-- Description: 
		--	1) Routine : load_req_into_gtt
		--		1) Performance Changes.
		--	2) Routine : proc_dfp_load_pad_supp
		--		1) Performance Changes.
		--	3) Routine : get_pq_rslt_cursor
		--		1) Performance Changes.
		
		-- Created(07-11-2016): Abhishek Sharma
		-- Version: 1.0.2
		-- Description: 
		--	1) Routine : load_req_data
		--		1) Assign the status code and message as per the previoud status only.
		
		-- Created(04-11-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description: 
		--	1) Routine : load_req_data
		--		1) Load of the request to be performed before MDI generation and after MDI generation.
		
		-- Created(22-09-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.4';
	end get_version;
end pkg_dfp_ext;
/


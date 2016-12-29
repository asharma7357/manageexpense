prompt
prompt Creating package PKG_DFP_PROCESSOR
prompt =================================
prompt
create or replace package pkg_dfp_processor is

	--------------------------------------------------------------------------------
	---																			 ---
	---  Copyright © 2016-2021 Agilis International, Inc.  All rights reserved  ---
	---																			 ---
	--- These scripts/source code and the contents of these files are protected  ---
	--- by copyright law and International treaties.  Unauthorized reproduction  ---
	--- or distribution of the scripts/source code or any portion of these       ---
	--- files, may result in severe civil and criminal penalties, and will be    ---
	--- prosecuted to the maximum extent possible under the law.				 ---
	---																			 ---
	--------------------------------------------------------------------------------

	-- Author  : Abhishek Sharma
	-- Created : 26-09-2016
	-- Purpose : Device Fingerprinting 

	--Description:	Realtime routine for single record aliasing/decisioning. Called from PKG_DE_API
	--				to enqueue requests into aliaisng queue and read the response from response queue.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the DFP Payload array.
	--	2) pv_process_time
	--		parameter mode = OUT
	--		description = will accept the process time.
	--	3) pv_req_timeout_thld
	--		parameter mode = OUT
	--		description = will accept the request timeout threshold.
	--Performance:	Near-Realtime, less then 1 second most of the time
	procedure process_payload(	pr_dfp_payload in out nocopy ty_dfp_payload);

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_processor;
/

prompt
prompt Creating package body PKG_DFP_PROCESSOR
prompt ======================================
prompt
create or replace package body pkg_dfp_processor is
	
	mc_jb_number		constant number := 1;
	mc_pkg_name			constant varchar2(100) := 'PKG_DFP_PROCESSOR';

	procedure log_msg(	pv_module_name in varchar2,
						pv_msg in varchar2) is
	begin
		--TODO: have a standard job number/thread for non-job invoked processes (externally invoked, e.g. from web services and GUI)
		pkg_util.log_msg(mc_jb_number, 1, 0, mc_pkg_name || '.' || pv_module_name, pv_msg);
	end;

	procedure process_pq_results(pr_dfp_payload in out nocopy ty_dfp_payload) is
		lv_fq_start_time		number;
		lv_fq_step_start_time	number;
		lv_array_idx			number;
		lv_fq_cur_cnt			number := 0;
		lv_match_score_thld		number := pkg_util.get_setting('MATCH_SCORE_THLD');
		lv_pq_match_cnt_thld	number := pkg_util.get_setting('PQ_MATCH_CNT_THLD');
		
		lc_pq_rslt				sys_refcursor;
		
		lr_pq_rslt				ty_dfp_pq_rslt;
		lr_fq_rslt				ty_dfp_fq_rslt;
		lr_fq_rslt_null			ty_dfp_fq_rslt;
		
		lv_handled_in_ext		boolean;
		lv_qldf_status			boolean := true;
		
		la_fq_rslt				ty_dfp_fq_rslt_tab := ty_dfp_fq_rslt_tab();
		type lt_pq_rslt is table of ty_dfp_pq_rslt index by binary_integer;
		la_pq_rslt				lt_pq_rslt;
		
		la_dfp_entropy			pkg_dfp_fq.mt_dfp_entropy;
		
		lv_fq_ins_sql			clob;
		
		lv_pq_rslt_sql			clob;
	begin
		lv_fq_start_time := dbms_utility.get_time;
		
		pr_dfp_payload.dfp_log_data.fq_entropy_fetch_time := dbms_utility.get_time;
		--[(Abhishek Sharma : 02112016) : Fetch the data from the entropy table into a collection for further processing.]
		select	* bulk collect into la_dfp_entropy
		from	dfp_entropy;
		pr_dfp_payload.dfp_log_data.fq_entropy_fetch_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.fq_entropy_fetch_time;

		--Since this code is customized for each implementation, the actual logic is implemented in PKG_DFP_EXT (extensiblity)
		--which is customized for each implementation
		pkg_dfp_ext.get_pq_rslt_cursor(	pv_ref_num => pr_dfp_payload.dfp_log_data.ref_num,
										pc_pq_rslt => lc_pq_rslt);
		
		pr_dfp_payload.dfp_log_data.fq_eval_time := dbms_utility.get_time;
		loop
			fetch lc_pq_rslt into lr_pq_rslt;
			exit when lc_pq_rslt%notfound;
			
			lr_fq_rslt := ty_dfp_fq_rslt(	null,null,null,null,null,null,null,null,null,null,
											null,null,null,null,null,null,null,null,null,null,
											null,null,null,null,null,null,null,null,null,null,
											null,null,null,null,null,null,null);
			
			--[(Abhishek Sharma : 26102016) : Assign the Record type and Record Date as in the PQ result dataset.]
			lr_fq_rslt.pad_rec_type := lr_pq_rslt.rec_type;
			lr_fq_rslt.pad_rec_dt := lr_pq_rslt.rec_dt;
			
			begin
				lv_fq_step_start_time := dbms_utility.get_time;
				
				--compute the scores for various attributes
				pkg_dfp_fq.compute_attrib_scores(pr_dfp_payload.dfp_idx_pad_data, lr_pq_rslt, lr_fq_rslt);
				
				--optionally evaluate the attribute scores for supression/adjustments or blacklisting
				pkg_dfp_ext.post_attrib_scoring_adj(pr_dfp_payload, lr_pq_rslt, lr_fq_rslt);
				
				--compute the total score (from the attribute scores)
				--check if extensiblity will handle this
				pkg_dfp_ext.compute_fq_total_score(pr_dfp_payload, lr_fq_rslt, lv_handled_in_ext);

				if not lv_handled_in_ext or lr_fq_rslt.tot_score is null then
					--[(Abhishek Sharma : 02112016) : Pass the entropy configured for each PAD column]
					pkg_dfp_fq.compute_total_score(	pr_fq_rslt => lr_fq_rslt,
													pa_dfp_entropy => la_dfp_entropy);
				end if;

				--if the score exceeds the threshold then null in the routine.
				pkg_dfp_ext.evaluate_scores_for_fq(	lr_fq_rslt,
													lr_pq_rslt,
													pr_dfp_payload,
													lv_qldf_status,
													lv_handled_in_ext);
				
				-- [(Abhishek Sharma : 25102016) : Handeling of the boolean was not working.]
				if lv_handled_in_ext then
					null;
				else
					--TODO:
					lv_qldf_status := (lr_fq_rslt.tot_score >= lv_match_score_thld); 
				end if;

				if lv_qldf_status = true  then
					--1. update counters
					pr_dfp_payload.dfp_log_data.fq_match_cnt := nvl(pr_dfp_payload.dfp_log_data.fq_match_cnt, 0) + 1;

					--[(Abhishek Sharma : 18112016) : MDI assignment should be when the current tot_score is greater than previous but when current and previous is same then the rec_dt checking is to happen.]
					--[(Abhishek Sharma : 07112016) : Changed the logic of MDI generation.]
					--[(Abhishek Sharma : 02112016) : Fetch the MDI from the matched requests.]
					if pr_dfp_payload.dfp_match_dtl_data.tot_score is null then
						pr_dfp_payload.dfp_idx_pad_data.master_device_id := lr_pq_rslt.master_device_id;
						pr_dfp_payload.dfp_match_dtl_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.master_device_id;
					
						pr_dfp_payload.dfp_match_dtl_data.ref_num := lr_pq_rslt.ref_num;
						pr_dfp_payload.dfp_match_dtl_data.rec_dt := lr_pq_rslt.rec_dt;
						pr_dfp_payload.dfp_match_dtl_data.tot_score := lr_fq_rslt.tot_score;
					elsif lr_fq_rslt.tot_score >= pr_dfp_payload.dfp_match_dtl_data.tot_score then
						pr_dfp_payload.dfp_idx_pad_data.master_device_id := lr_pq_rslt.master_device_id;
						pr_dfp_payload.dfp_match_dtl_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.master_device_id;
					
						pr_dfp_payload.dfp_match_dtl_data.ref_num := lr_pq_rslt.ref_num;
						pr_dfp_payload.dfp_match_dtl_data.rec_dt := lr_pq_rslt.rec_dt;
						pr_dfp_payload.dfp_match_dtl_data.tot_score := lr_fq_rslt.tot_score;
					elsif lr_fq_rslt.tot_score = pr_dfp_payload.dfp_match_dtl_data.tot_score then
						--Check if the PAD Rec Date is greater than the previous record PAD Rec date or not
						if pr_dfp_payload.dfp_match_dtl_data.rec_dt < lr_pq_rslt.rec_dt then
							pr_dfp_payload.dfp_idx_pad_data.master_device_id := lr_pq_rslt.master_device_id;
							pr_dfp_payload.dfp_match_dtl_data.master_device_id := pr_dfp_payload.dfp_idx_pad_data.master_device_id;
							
							pr_dfp_payload.dfp_match_dtl_data.ref_num := lr_pq_rslt.ref_num;
							pr_dfp_payload.dfp_match_dtl_data.rec_dt := lr_pq_rslt.rec_dt;
							pr_dfp_payload.dfp_match_dtl_data.tot_score := lr_fq_rslt.tot_score;
						end if;
					end if;
					
					--2. add the result to a array
					lv_array_idx := nvl(lv_array_idx, 0) + 1;

					la_fq_rslt.extend;
					la_fq_rslt(lv_array_idx) := lr_fq_rslt;

					--3. Add the PQ result record to the de payload
					pr_dfp_payload.pq_rslt_tab_data.extend(1);
					
					pr_dfp_payload.pq_rslt_tab_data(pr_dfp_payload.pq_rslt_tab_data.count) := lr_pq_rslt;


					--4. Add the FQ result record to the de payload
					pr_dfp_payload.fq_rslt_tab_data.extend(1);
					pr_dfp_payload.fq_rslt_tab_data(pr_dfp_payload.fq_rslt_tab_data.count) := lr_fq_rslt;

					if la_fq_rslt.count >= lv_pq_match_cnt_thld then
						exit;
					end if;
				end if;
				
				lv_fq_cur_cnt := lv_fq_cur_cnt + 1;
			exception
				when others then
					null;
			end;

			pr_dfp_payload.dfp_log_data.fq_eval_cnt := nvl(pr_dfp_payload.dfp_log_data.fq_eval_cnt, 0) + 1;

			--check for limits
			if pr_dfp_payload.dfp_log_data.fq_eval_cnt >= pkg_dfp_ext.gc_pq_eval_cnt_thld then
				exit;
			end if;
			
			if (dbms_utility.get_time - lv_fq_start_time) >= pkg_dfp_ext.gc_pq_eval_time_thld then
				exit;
			end if;
		end loop;
		close lc_pq_rslt;
		
		pr_dfp_payload.dfp_log_data.fq_eval_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.fq_eval_time;
		
		--[(Abhishek Sharma : 08112016) : Assign the Ref Num to MDI when there is no FQ match.]
		pkg_dfp_ext.gen_mdi(pr_dfp_payload);
		
		--Set the start time for insert
		pr_dfp_payload.dfp_log_data.fq_rslt_load_time := dbms_utility.get_time;

		--[(Abhishek Sharma : 23112016) : Performance Changes.]
		lv_fq_ins_sql := 'insert /*+ APPEND_VALUES */into dfp_rslt_fq_t1 ('||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			req_ref_num,pad_ref_num,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			pad_rec_type,pad_rec_dt,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			tot_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			user_agent_os_id_score,user_agent_browser_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			user_agent_engine_id_score,user_agent_device_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			cpu_arch_id_score,canvas_fp_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			http_head_accept_id_score,content_encoding_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			content_lang_id_score,ip_address_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			ip_address_octet_score,os_fonts_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			browser_lang_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			disp_color_depth_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			disp_screen_res_ratio_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			timezone_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			platform_id_score,plugins_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			use_of_local_storage_score,use_of_sess_storage_score,indexed_db_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			do_not_track_score,has_lied_langs_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			has_lied_os_score,has_lied_browser_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			webgl_vendor_renderer_id_score,cookies_enabled_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			touch_sup_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			connection_type_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			webrtc_fp_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			aud_codecs_id_score,vid_codecs_id_score)'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'	values (:req_ref_num,:pad_ref_num,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:pad_rec_type,:pad_rec_dt,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:tot_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:user_agent_os_id_score,:user_agent_browser_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:user_agent_engine_id_score,:user_agent_device_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:cpu_arch_id_score,:canvas_fp_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:http_head_accept_id_score,:content_encoding_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:content_lang_id_score,:ip_address_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:ip_address_octet_score,:os_fonts_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:browser_lang_id_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:disp_color_depth_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:disp_screen_res_ratio_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:timezone_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:platform_id_score,:plugins_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:use_of_local_storage_score,:use_of_sess_storage_score,:indexed_db,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:do_not_track_score,:has_lied_langs_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:has_lied_os_score,:has_lied_browser_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:webgl_vendor_renderer_id_score,:cookies_enabled_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:touch_sup_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:connection_type_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:webrtc_fp_score,'||chr(10);
		lv_fq_ins_sql := lv_fq_ins_sql||'			:aud_codecs_id_score,:vid_codecs_id_score)'||chr(10);
		
		--insert final results
		forall i in 1..la_fq_rslt.count
			execute immediate lv_fq_ins_sql using la_fq_rslt(i).req_ref_num,la_fq_rslt(i).pad_ref_num,
					la_fq_rslt(i).pad_rec_type,la_fq_rslt(i).pad_rec_dt,
					la_fq_rslt(i).tot_score,
					la_fq_rslt(i).user_agent_os_id_score,la_fq_rslt(i).user_agent_browser_id_score,
					la_fq_rslt(i).user_agent_engine_id_score,la_fq_rslt(i).user_agent_device_id_score,
					la_fq_rslt(i).cpu_arch_id_score,la_fq_rslt(i).canvas_fp_score,
					la_fq_rslt(i).http_head_accept_id_score,la_fq_rslt(i).content_encoding_id_score,
					la_fq_rslt(i).content_lang_id_score,la_fq_rslt(i).ip_address_score,
					la_fq_rslt(i).ip_address_octet_score,la_fq_rslt(i).os_fonts_id_score,
					la_fq_rslt(i).browser_lang_id_score,
					la_fq_rslt(i).disp_color_depth_score,
					la_fq_rslt(i).disp_screen_res_ratio_score,
					la_fq_rslt(i).timezone_score,
					la_fq_rslt(i).platform_id_score,la_fq_rslt(i).plugins_score,
					la_fq_rslt(i).use_of_local_storage_score,la_fq_rslt(i).use_of_sess_storage_score,la_fq_rslt(i).indexed_db_score,
					la_fq_rslt(i).do_not_track_score,la_fq_rslt(i).has_lied_langs_score,
					la_fq_rslt(i).has_lied_os_score,la_fq_rslt(i).has_lied_browser_score,
					la_fq_rslt(i).webgl_vendor_renderer_id_score,la_fq_rslt(i).cookies_enabled_score,
					la_fq_rslt(i).touch_sup_score,
					la_fq_rslt(i).connection_type_score,
					la_fq_rslt(i).webrtc_fp_score,
					la_fq_rslt(i).aud_codecs_id_score,la_fq_rslt(i).vid_codecs_id_score;
		commit;
		
		--Set the final time for insert
		pr_dfp_payload.dfp_log_data.fq_rslt_load_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.fq_rslt_load_time;
		
		--the FQ time is computed in parent routine
		--pr_dfp_payload.dfp_log_data.fq_tot_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.fq_tot_time;
	end process_pq_results;

	--Description:	Realtime routine for single record aliasing/decisioning. Called from PKG_DE_API
	--				to enqueue requests into aliaisng queue and read the response from response queue.
	--Parameters:
	--	1) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the DFP Payload array.
	--	2) pv_process_time
	--		parameter mode = OUT
	--		description = will accept the process time.
	--	3) pv_req_timeout_thld
	--		parameter mode = OUT
	--		description = will accept the request timeout threshold.
	--Performance:	Near-Realtime, less then 1 second most of the time
	procedure process_payload(	pr_dfp_payload in out nocopy ty_dfp_payload)
	is
		la_pad_rec_type	dbms_sql.varchar2_table;
		la_pq_sql		dbms_sql.varchar2_table;
		lv_ins_count	number;
	begin
		pr_dfp_payload.dfp_log_data.status_cd := 0;
		pr_dfp_payload.dfp_log_data.status_msg := 'Success';
		
		--1) Pre-process the data through extensiblity routine
		pkg_dfp_ext.pre_process_payload(pr_dfp_payload); --put null in main routine
/*
		--2) Perform Indexing of aliasing data
		pr_dfp_payload.dfp_log_data.idx_time := dbms_utility.get_time;

		pkg_dfp_idx.index_entity_info(	pr_dfp_payload.dfp_idx_pad_data,
										pr_dfp_payload.dfp_log_data.status_msg,
										pr_dfp_payload.dfp_log_data.status_cd);

		pr_dfp_payload.dfp_log_data.idx_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.idx_time;
		
		if nvl(pr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			pr_dfp_payload.dfp_log_data.status_msg := 'Error indexing data:'|| to_char(pr_dfp_payload.dfp_log_data.status_cd) || '-' || pr_dfp_payload.dfp_log_data.status_msg;
			pr_dfp_payload.dfp_log_data.status_cd := 1;
		end if;

		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		if (dbms_utility.get_time - pv_process_time) > pv_req_timeout_thld then
			pr_dfp_payload.dfp_log_data.status_msg := '[Timeout] : After Index Entity Info.';
			pr_dfp_payload.dfp_log_data.status_cd := 1;
			
			goto write_log;
		end if;
*/
		-- 3) Routine to load the request data
		pkg_dfp_ext.load_req_into_gtt(	pr_dfp_payload => pr_dfp_payload,
										pv_status_cd => pr_dfp_payload.dfp_log_data.status_cd,
										pv_status_msg => pr_dfp_payload.dfp_log_data.status_msg);
		
		if nvl(pr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			pr_dfp_payload.dfp_log_data.status_msg := 'Error loading temp request data:'|| to_char(pr_dfp_payload.dfp_log_data.status_cd) || '-' || pr_dfp_payload.dfp_log_data.status_msg;
			pr_dfp_payload.dfp_log_data.status_cd := 1;
		end if;

		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		if (dbms_utility.get_time - pr_dfp_payload.process_time) > pr_dfp_payload.req_timeout_thld then
			pr_dfp_payload.dfp_log_data.status_msg := '[Timeout] : After Load Req data into GTT.';
			pr_dfp_payload.dfp_log_data.status_cd := 2;
			
			goto write_log;
		end if;
		
		--4) Post Qualification
		pr_dfp_payload.dfp_log_data.pq_tot_time := dbms_utility.get_time;
	
		--Call local routine for genertating pq sql
		begin
			la_pq_sql := pkg_dfp_pq.gen_pq_sql;
		exception
			when others then
				pr_dfp_payload.dfp_log_data.status_cd := 1;
				pr_dfp_payload.dfp_log_data.status_msg := 'Error generating pq sql : '||sqlerrm;
		end;
		
		--Call local routine for genertating pq results
		pkg_dfp_pq.gen_pq_results(	pa_pq_sql => la_pq_sql,
									pr_dfp_payload => pr_dfp_payload);
	
		pr_dfp_payload.dfp_log_data.pq_tot_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.pq_tot_time;

		if nvl(pr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			pr_dfp_payload.dfp_log_data.status_msg:= 'Error processing results: ' || nvl(pr_dfp_payload.dfp_log_data.status_msg,'<<null>>');

			goto write_log;
		end if;
	
		--[(Abhishek Sharma : 08112016) : Timeout logic to exit the processing when the configured timeout value exceeds.]
		if (dbms_utility.get_time - pr_dfp_payload.process_time) > pr_dfp_payload.req_timeout_thld then
			pr_dfp_payload.dfp_log_data.status_msg := '[Timeout] : After PQ.';
			pr_dfp_payload.dfp_log_data.status_cd := 2;
		
			goto write_log;
		end if;
	
		--5) Final Qualification
		pr_dfp_payload.dfp_log_data.fq_tot_time := dbms_utility.get_time;
	
		process_pq_results(	pr_dfp_payload => pr_dfp_payload);
		
		pr_dfp_payload.dfp_log_data.req_load_time := dbms_utility.get_time;
		
		-- 6) Routine to load the request data after MDI generation
		pkg_dfp_ext.load_req_data(	pr_dfp_payload => pr_dfp_payload,
									pv_status_cd => pr_dfp_payload.dfp_log_data.status_cd,
									pv_status_msg => pr_dfp_payload.dfp_log_data.status_msg);
		pr_dfp_payload.dfp_log_data.req_load_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.req_load_time;
	
		pr_dfp_payload.dfp_log_data.fq_tot_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.fq_tot_time;
	
		if nvl(pr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			pr_dfp_payload.dfp_log_data.status_msg := 'Error loading request data:'|| to_char(pr_dfp_payload.dfp_log_data.status_cd) || '-' || pr_dfp_payload.dfp_log_data.status_msg;
			pr_dfp_payload.dfp_log_data.status_cd := 1;
			
			goto write_log;
		end if;

		--7) Post-process the data through extensiblity routine
		pkg_dfp_ext.post_process_payload(pr_dfp_payload);
		
		--8) Routine to load the data into PAD
		pr_dfp_payload.dfp_log_data.pad_load_time := dbms_utility.get_time;
	
		pkg_dfp_ext.load_pad_data(	pr_dfp_payload => pr_dfp_payload,
									pv_status_cd => pr_dfp_payload.dfp_log_data.status_cd,
									pv_status_msg => pr_dfp_payload.dfp_log_data.status_msg);
		
		pr_dfp_payload.dfp_log_data.pad_load_time := dbms_utility.get_time - pr_dfp_payload.dfp_log_data.pad_load_time;
	
		if nvl(pr_dfp_payload.dfp_log_data.status_cd, 0) > 0 then
			pr_dfp_payload.dfp_log_data.status_msg := 'Error loading active pad data:'|| to_char(pr_dfp_payload.dfp_log_data.status_cd) || '-' || pr_dfp_payload.dfp_log_data.status_msg;
			pr_dfp_payload.dfp_log_data.status_cd := 1;
			
			goto write_log;
		end if;
		<<	write_log	>>
		null;
	end process_payload;

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(23-11-2016): Abhishek Sharma
		-- Version: 1.0.6
		-- Description:
		--	1) Routine: process_pq_results
		--		1) Performance Changes.
		
		-- Created(18-11-2016): Abhishek Sharma
		-- Version: 1.0.5
		-- Description:
		--	1) Routine: process_pq_results
		--		1) MDI assignment should be when the current tot_score is greater than previous but when current and previous is same then the rec_dt checking is to happen.
		
		-- Created(08-11-2016): Abhishek Sharma
		-- Version: 1.0.4
		-- Description:
		--	1) Routine: process_payload
		--		1) Timeout logic to exit the processing when the configured timeout value exceeds.
		
		-- Created(03-11-2016): Abhishek Sharma
		-- Version: 1.0.3
		-- Description:
		--	1) Routine: process_pq_results
		--		1) Store the MDI when there is only one record.
		
		-- Created(02-11-2016): Abhishek Sharma
		-- Version: 1.0.2
		-- Description:
		--	1) Routine: process_pq_results
		--		1) Fetch the data from the entropy table into a collection for further processing.
		--		2) Pass the entropy configured for each PAD column
		
		-- Created(26-09-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description:
		--	1) Routine: process_pq_results
		--		1) Assign the Record type and Record Date as in the PQ result dataset.
		
		-- Created(26-09-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description:
		--	1) Routine: process_pq_results
		--		1) Handeling of the boolean was not working.
		
		-- Created(26-09-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.6';
	end;

end pkg_dfp_processor;
/


prompt
prompt Creating package PKG_DFP_PQ
prompt =============================
prompt
create or replace package pkg_dfp_pq is

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
	-- Created : 10/03/03 3:06:04 PM
	-- Purpose : Routines related to Pre-Qualification Stage

	--Structure of the PQ Result table:
	--For realtime Aliasing, the PQ result table is as follows:
	--   Column        Type
	--   time_key      number(5)
	--   pass          number(5)
	--   nsd_ref_num   varchar2(15)
	--   pad_idx*      all columns from PAD index
	--Note: The PQ Result table is partitioned bu TIME_KEY (each time key corresponds to the minute in which the request was received)
	--it is further hash partitioned by nsd_ref_num (so each API can do a quick look up on the specific nsd_ref_num for which the
	-- API call was received, and using time key, the volume of data is further reduced.

	--For batch mode aliasing, the PQ result table is as follows:
	--   Column        Type
	--   pass          number(5)
	--   nsd_ref_num   varchar2(15) --rowid from NSD_IDX
	--   pad_ref_num   varchar2(15) --rowid from PAD_IDX

	type mr_pq_map_config is record (	cf_pass_number dfp_pq_config.cf_pass_number%type,
										cf_sub_pass_number dfp_pq_config.cf_sub_pass_number%type,
										cf_attrib_id dfp_pq_config.cf_attrib_id%type,
										attrib_name dfp_attrib_map.attrib_name%type,
										pad_column_name dfp_attrib_map.pad_column_name%type,
										cf_match_degree dfp_pq_config.cf_match_degree%type);

	type mt_pq_map_config is table of mr_pq_map_config index by binary_integer;

	--Description:`Returns the Pre-Qualification SQL (insert into <PQ result table> select PAD.PK, NSD.PK from PAD, NSD where <match clause>)
	--Parameters:
	--	1) pv_pass
	--		parameter mode = IN
	--		description = will accept the pass number.
	--	2) pa_pq_map_config
	--		parameter mode = IN
	--		description = will store the passes details.
	--	3) pv_sql
	--		parameter mode = OUT
	--		description = will store the sql for the passes.
	--	4) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the routine status code.
	--	5) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the routine status message.
	--Performance:	None
	procedure get_pq_sql(	pv_pass in number,
							pa_pq_map_config in mt_pq_map_config,
							pv_sql out varchar2,
							pv_status_cd out number,
							pv_status_msg out varchar2);

	--Description:	Routine to generate the PQ Results and store the same.
	--Parameters: no Parameters
	-- Return: dbms_sql.varchar2_table
	--Performance:	None
	function gen_pq_sql return dbms_sql.varchar2_table result_cache;

	--Description:	Routine to execute the PQ sql.
	--Parameters:
	--	1) pa_pq_sql
	--		parameter mode = IN
	--		description = will store the PQ sql for all the passes..

	--	2) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the DFP Payload array.
	--Performance:	None
	procedure gen_pq_results(	pa_pq_sql in dbms_sql.varchar2_table,
								pr_dfp_payload in out nocopy ty_dfp_payload);

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_pq;
/

prompt
prompt Creating package body PKG_DFP_PQ
prompt ==================================
prompt
create or replace package body pkg_dfp_pq is

	ma_pq_sql			dbms_sql.varchar2_table; --pre-populated array of PQ SQL criteria
	mv_pad_table		varchar2(32 char) := 'DFP_IDX_PAD_T1';
	mv_nsd_table		varchar2(32 char) := 'DFP_IDX_REQ_T1_L1';
	mv_pq_rslt_table	varchar2(32 char) := 'DFP_RSLT_PQ_T1_L1';

	--Description:	Routine to generate the sql for PQ.
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
	function get_match_sql(	pv_match_weight in varchar2 default 0,
							pv_attrib_name in varchar2,
							pv_column_name in varchar2,
							pv_match_degree in varchar2) return varchar2 is

		lv_sql varchar2(4000);

		--Description:`Routine create the sql for the attribute
		--Parameters:
		--	1) pv_rel_oper
		--		parameter mode = IN
		--		description = will accept the realtion operator to be applied.
		--	2) pv_pad_col_name
		--		parameter mode = IN
		--		description = will accept the attrbiute name.
		--	2) pv_not_null
		--		parameter mode = IN
		--		description = will accept if not null constraint is applicable or not.
		--Performance:	None
		procedure addsql(	pv_rel_oper in varchar2,
							pv_attrib_name in varchar2,
							pv_pad_col_name in varchar2,
							pv_not_null in boolean := false) is
		begin
			if pv_rel_oper is not null then
				lv_sql := lv_sql || ' ' || pv_rel_oper;
			end if;

			if pv_not_null then
				lv_sql := lv_sql || ' nvl( a.'||pv_column_name||',0)';
				lv_sql := lv_sql || ' =';
				lv_sql := lv_sql || ' nvl( b.'||pv_column_name||',0)';
			else
				lv_sql := lv_sql || ' a.'||pv_column_name;
				lv_sql := lv_sql || ' =';
				lv_sql := lv_sql || ' b.'||pv_column_name;
			end if;
		end addsql;

		--Description:`Routine to apply the opening brace in the sql.
		--Parameters:
		--	1) pv_rel_oper
		--		parameter mode = IN
		--		description = will accept the realtion operator to be applied.
		--Performance:	None
		procedure openbrace(pv_rel_oper in varchar2 := null) is
		begin
			lv_sql := lv_sql || ' ' || nvl(pv_rel_oper,' ') ||  '(';
		end openbrace;

		procedure closebrace is
		begin
			lv_sql := lv_sql || ' )';
		end closebrace;
	begin
		-------------New technique------------
		addsql(	pv_rel_oper => null,
				pv_attrib_name => pv_attrib_name,
				pv_pad_col_name => pv_column_name);

		--Almiya: Pass the generated SQL through the extensiblity routine
		return pkg_dfp_ext.get_match_sql(	pv_match_weight,
											pv_attrib_name,
											pv_column_name,
											pv_match_degree,
											lv_sql);

	end get_match_sql;

	--Description:`Returns the Pre-Qualification SQL (insert into <PQ result table> select PAD.PK, NSD.PK from PAD, NSD where <match clause>)
	--Parameters:
	--	1) pv_pass
	--		parameter mode = IN
	--		description = will accept the pass number.
	--	2) pa_pq_map_config
	--		parameter mode = IN
	--		description = will store the passes details.
	--	3) pv_sql
	--		parameter mode = OUT
	--		description = will store the sql for the passes.
	--	4) pv_status_cd
	--		parameter mode = OUT
	--		description = will store the routine status code.
	--	5) pv_status_msg
	--		parameter mode = OUT
	--		description = will store the routine status message.
	--Performance:	None
	procedure get_pq_sql(	pv_pass in number,
							pa_pq_map_config in mt_pq_map_config,
							pv_sql out varchar2,
							pv_status_cd out number,
							pv_status_msg out varchar2) is
		lv_prev_subpass		number(10);

		lv_sql_stmt			varchar2(30000);
		lv_match_sql		varchar2(30000);
		lv_sql_hint			varchar2(1000);
		lv_part_clause		varchar2(1000);
	begin
		pv_status_cd := 0;
		pv_status_msg := 'Success';

		for iPq in 1..pa_pq_map_config.count loop
			if pa_pq_map_config(iPq).cf_pass_number = pv_pass then
				if lv_prev_subpass is null then
					lv_match_sql := get_match_sql(	pv_attrib_name => pa_pq_map_config(iPq).attrib_name,
													pv_column_name => pa_pq_map_config(iPq).pad_column_name,
													pv_match_degree => pa_pq_map_config(iPq).cf_match_degree);
					lv_prev_subpass := pa_pq_map_config(iPq).cf_sub_pass_number;
				elsif lv_prev_subpass <> pa_pq_map_config(iPq).cf_sub_pass_number then
					lv_match_sql := lv_match_sql || ' and ' || get_match_sql(	pv_attrib_name => pa_pq_map_config(iPq).attrib_name,
																				pv_column_name => pa_pq_map_config(iPq).pad_column_name,
																				pv_match_degree => pa_pq_map_config(iPq).cf_match_degree);
					lv_prev_subpass := pa_pq_map_config(iPq).cf_sub_pass_number;
				else
					lv_match_sql := lv_match_sql || ' or ' || get_match_sql(pv_attrib_name => pa_pq_map_config(iPq).attrib_name,
																			pv_column_name => pa_pq_map_config(iPq).pad_column_name,
																			pv_match_degree => pa_pq_map_config(iPq).cf_match_degree);
				end if;
			end if;
		end loop;

		lv_sql_hint := pkg_dfp_ext.get_pq_sql_hint(1);
		if lv_sql_hint is null then
			lv_sql_hint := '/*+ PARALLEL(a, '|| to_char(pkg_dfp_utils.get_system_cpu_count) || ') */';
		end if;

		--[(Abhishek Sharma : 23112016) : Performance Changes.]
		lv_sql_stmt := 'insert /*+ append */into ' || mv_pq_rslt_table;

		lv_sql_stmt := lv_sql_stmt || ' select ' /*|| lv_sql_hint*/;
		lv_sql_stmt := lv_sql_stmt || to_char(sysdate,'mm') || ', ' || to_char(pv_pass) || ', a.ref_num, b.*';
		lv_sql_stmt := lv_sql_stmt || ' from '|| mv_nsd_table ||' a, '|| mv_pad_table ||' b where ';
		/*
		if mv_pad_table = mv_nsd_table then
			if mv_pad_table = mv_nsd_table then
				--if it is the same table (self join) then use rowid - faster
				lv_sql_stmt := lv_sql_stmt || ' a.rowid > b.rowid and ';
			else
				--else if it is the same table with one of them as partioned then use ref num
				lv_sql_stmt := lv_sql_stmt || ' a.REF_NUM > b.REF_NUM and ';
			end if;
		elsif pkg_dfp_ext.gc_pq_ref_num_inequality_chk <> 0 then
			--this check is only added if the flag is set in extensiblity package, default is false
			lv_sql_stmt := lv_sql_stmt || ' a.REF_NUM != b.REF_NUM and ';
		end if;
		*/
		lv_sql_stmt := lv_sql_stmt || lv_match_sql;

		if pkg_sqlgen.sql_valid(lv_sql_stmt,pv_status_msg) = false then
			pv_status_msg := 'Error validating PQ-SQL for pass '|| pv_pass || ':' || pv_status_msg;
			pv_status_cd := 1;
		end if;

		-- pass the generated SQL through the extensiblity routine
		pkg_dfp_ext.get_pq_sql(	mv_pad_table,
								mv_nsd_table,
								mv_pq_rslt_table,
								pv_pass,
								lv_sql_stmt);--lv_match_sql);

		pv_sql := lv_sql_stmt;
	exception
		when others then
			pv_status_cd := 1; --error
			pv_status_msg := 'Critical error while building PQ sql:'|| sqlerrm;
	end get_pq_sql;

	--Description:	Routine to generate the PQ Results and store the same.
	--Parameters: no Parameters
	--Return: dbms_sql.varchar2_table
	--Performance:	None
	function gen_pq_sql return dbms_sql.varchar2_table result_cache
	is
		la_pq_sql			dbms_sql.varchar2_table;
		la_pass_number		dbms_sql.varchar2_table;

		la_pq_map_config	mt_pq_map_config;

		lv_pq_sql			varchar2(4000 char);
		lv_pass_sql			varchar2(4000 char);
		lv_status_msg		varchar2(2000 char);
		
		lv_status_cd		number;
	begin
		--Fetch the configured passes to be processed
		select	cf_pass_number bulk collect into la_pass_number
		from	dfp_pq_config
		where	jb_thread_id = 1
		group by cf_pass_number
		order by cf_pass_number;

		select	/*+ use_hash(dpc dam) */
				dpc.cf_pass_number,
				dpc.cf_sub_pass_number,
				dpc.cf_attrib_id,
				dam.attrib_name,
				dam.pad_column_name,
				dpc.cf_match_degree
		bulk collect into la_pq_map_config
		from	dfp_pq_config dpc
				join dfp_attrib_map dam on (dpc.cf_attrib_id = dam.attrib_id)
		where	dpc.jb_thread_id = 1
		order by dpc.cf_pass_number,nvl(dpc.cf_sub_pass_number, 0);

		--For this dfp configuration, cache all the Pre-Qualification SQL upfront inmodule variables
		for iPass in 1..la_pass_number.count loop
			get_pq_sql(	pv_pass => la_pass_number(iPass),
						pa_pq_map_config => la_pq_map_config,
						pv_sql => lv_pq_sql,
						pv_status_cd => lv_status_cd,
						pv_status_msg => lv_status_msg);

			if lv_status_cd = 0 then
				la_pq_sql(la_pq_sql.count+1) := lv_pq_sql;
			else
				exit;
			end if;
		end loop;
		return la_pq_sql;
	end gen_pq_sql;

	--Description:	Routine to execute the PQ sql.
	--Parameters:
	--	1) pa_pq_sql
	--		parameter mode = IN
	--		description = will store the PQ sql for all the passes..
	--	2) pr_dfp_payload
	--		parameter mode = IN OUT
	--		description = will accept the DFP Payload array.
	--Performance:	None
	procedure gen_pq_results(	pa_pq_sql in dbms_sql.varchar2_table,
								pr_dfp_payload in out nocopy ty_dfp_payload) is
		lv_pass_time		number;
		lv_ins_count		number := 0;
		lv_tot_ins_count	number := 0;
		
		lv_sql				clob;
	begin
		pr_dfp_payload.dfp_log_data.status_cd := 0;
		pr_dfp_payload.dfp_log_data.status_msg := 'Success';

		--Purge the previous data in the PQ Result Table
		--delete from dfp_rslt_pq_t1_l1;

		for iSql in 1..pa_pq_sql.count loop
			lv_pass_time := dbms_utility.get_time;

			execute immediate pa_pq_sql(iSql);

			--[(Abhishek Sharma : 07112016) : Assign the PQ Match count.]
			lv_ins_count := sql%rowcount;

			commit;

			lv_tot_ins_count := lv_tot_ins_count + lv_ins_count;

			lv_pass_time := dbms_utility.get_time - lv_pass_time;

			if iSql = 1 then
				pr_dfp_payload.dfp_log_data.pq_pass_time := lv_pass_time||':'||lv_ins_count;
			else
				pr_dfp_payload.dfp_log_data.pq_pass_time := pr_dfp_payload.dfp_log_data.pq_pass_time||'|'||lv_pass_time||':'||lv_ins_count;
			end if;
		end loop;

		--[(Abhishek Sharma : 01122016) : Load the Historical PAD Data for qualified MDI into PQ result table.]
		insert into dfp_rslt_pq_t1_l1(
				time_key,pass,
				req_ref_num,master_device_id,
				ref_num,session_id,
				rec_type,rec_dt,
				user_agent_os_id,
				user_agent_browser_id,user_agent_engine_id,
				user_agent_device_id,cpu_arch_id,
				canvas_fp,http_head_accept_id,
				content_encoding_id,content_lang_id,
				ip_address,ip_address_octet,
				os_fonts_id,
				browser_lang_id,
				disp_color_depth,disp_screen_res_ratio,
				timezone,platform_id,
				plugins,use_of_local_storage,
				use_of_sess_storage,indexed_db,do_not_track,
				has_lied_langs,has_lied_os,
				has_lied_browser,webgl_vendor_renderer_id,
				cookies_enabled,
				touch_sup,
				connection_type,
				webrtc_fp,aud_codecs_id,
				vid_codecs_id
			)
		with multi_mdi_pq as (	select	time_key,
										req_ref_num,
										master_device_id
								from	(	select	time_key,
													req_ref_num,
													master_device_id,
													count(distinct master_device_id) over () as unique_mdi_count
											from	dfp_rslt_pq_t1_l1
										)
								where	unique_mdi_count > 1
							)
		select	/*+ use_hash(supp pad) */
				pq.time_key,0 as pass,
				pq.req_ref_num,supp.master_device_id,
				supp.ref_num,supp.session_id,
				supp.rec_type,supp.rec_dt,
				supp.user_agent_os_id,
				supp.user_agent_browser_id,supp.user_agent_engine_id,
				supp.user_agent_device_id,supp.cpu_arch_id,
				supp.canvas_fp,supp.http_head_accept_id,
				supp.content_encoding_id,supp.content_lang_id,
				supp.ip_address,supp.ip_address_octet,
				supp.os_fonts_id,
				supp.browser_lang_id,
				supp.disp_color_depth,supp.disp_screen_res_ratio,
				supp.timezone,supp.platform_id,
				supp.plugins,supp.use_of_local_storage,
				supp.use_of_sess_storage,supp.indexed_db,supp.do_not_track,
				supp.has_lied_langs,supp.has_lied_os,
				supp.has_lied_browser,supp.webgl_vendor_renderer_id,
				supp.cookies_enabled,
				supp.touch_sup,
				supp.connection_type,
				supp.webrtc_fp,supp.aud_codecs_id,
				supp.vid_codecs_id
		from	dfp_idx_pad_hist supp
				join multi_mdi_pq pq on (pq.master_device_id = supp.master_device_id);
		
		--[(Abhishek Sharma : 07112016) : Assign the PQ Match count.]
		pr_dfp_payload.dfp_log_data.pq_match_cnt := lv_tot_ins_count;
	exception
		when others then
			pr_dfp_payload.dfp_log_data.status_cd := 1;
			pr_dfp_payload.dfp_log_data.status_msg := 'gen_pq_results[Error] : '||substr(sqlerrm,1,300)||'('|| substr(dbms_utility.format_error_backtrace,1,600)||')';
	end gen_pq_results;

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(23-11-2016): Abhishek Sharma
		-- Version: 1.0.2
		-- Description:
		--	1) Routine : get_pq_sql
		--		1) Performance Changes.

		-- Created(07-11-2016): Abhishek Sharma
		-- Version: 1.0.1
		-- Description:
		--	1) Routine : gen_pq_results
		--		1) Assign the PQ Match count.

		-- Created(22-09-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.2';
	end;
end pkg_dfp_pq;
/

prompt
prompt Done

prompt
prompt Creating package pkg_dfp_idx
prompt ==================================
prompt
create or replace package pkg_dfp_idx is

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
	-- Created : 26-09-2016
	-- Purpose : Build the index for DFP match


	--Description:	For the supplied user agent information, this routine will compute the indexing attributes
	--Parameters:
	--	1) pv_user_agent
	--		parameter mode = IN
	--		description = will accept the user agent.
	--	1) pv_user_agent_idx
	--		parameter mode = OUT
	--		description = will return the user agent index value.
	--Performance:	None
	procedure index_user_agent(	pv_user_agent in varchar2,
								pv_user_agent_idx out number);

	--Description:	For the supplied ip address information, this routine will compute the indexing attributes
	--Parameters:
	--	1) pv_ip_address
	--		parameter mode = IN
	--		description = will accept the ip address.
	--	1) pv_ip_address_idx
	--		parameter mode = OUT
	--		description = will return the ip address index value.
	--Performance:	None
	procedure index_ip_address(	pv_ip_address in varchar2,
								pv_ip_address_idx out number);
	
	--Description:	This routine receives a record type which is identical to the PAD table without the index columns (i.e. derived columns) populated
	--				the routine will compute the index information using existing attributes in the record (name,addr,phone etc...) and populate the
	--				indexing columns (all columns named like 'DC_G...')
	--Parameters:
	--	1) pr_entity_rec
	--		parameter mode = IN
	--		description = will accept the entity record i.e. dfp pad data.
	--	2) pv_status_msg
	--		parameter mode = OUT
	--		description = will return the status message of the process.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will return the status code of the process.
	--Performance:
	--  Realtime, no database insert/update/deletes here
	procedure index_entity_info(pr_entity_rec in out nocopy ty_dfp_idx_pad,
								pv_status_msg out varchar2,
								pv_status_cd out number);

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;

end pkg_dfp_idx;
/


prompt
prompt Create Package body PKG_DFP_IDX
prompt =================================
prompt

create or replace package body pkg_dfp_idx is
	mv_ignore_excl_list boolean := false;
	
	-- > Each routine should have a standard header
	-- > Set to deterministic if applicable
	-- > Use PARALLEL_ENABLE if applicable
	-- > RESULT_CACHE with relies on ensures any change to the underlying table invalidate the result cache
	--     result_cache relies_on(<table_name>) IS
	-- > AUTHID [ {DEFINER  |  CURRENT_USER}  ]
	-- > Use anchored dayatypes (using %type or %rowtype)

	-- Descrption: The following program unit will generate the md5 has value of the message
	-- Parameters:
	--	1) pv_msg :-
	--		parameter mode = IN
	--		description = will accept the message.
	-- Return type: varchar2.
	function get_md5_hash(pv_data in long) return varchar2
	as
		lv_raw		RAW(32767) := utl_raw.cast_to_raw(pv_data);
	begin
		return dbms_crypto.hash(lv_raw,dbms_crypto.hash_md5);
	end get_md5_hash;
	
	--Description:	For the supplied user agent information, this routine will compute the indexing attributes
	--Parameters:
	--	1) pv_user_agent
	--		parameter mode = IN
	--		description = will accept the user agent.
	--	1) pv_idx1
	--		parameter mode = OUT
	--		description = will return the user agent index value.
	--Performance:	None
	procedure index_user_agent(	pv_user_agent in varchar2,
								pv_user_agent_idx out number)
	is
	begin
		--Fetch the md5 hash value
		pv_user_agent_idx := get_md5_hash(pv_user_agent);
	end index_user_agent;

	--Description:	For the supplied user agent information, this routine will compute the indexing attributes
	--Parameters:
	--	1) pv_user_agent
	--		parameter mode = IN
	--		description = will accept the user agent.
	--	1) pv_idx1
	--		parameter mode = OUT
	--		description = will return the user agent index value.
	--Performance:	None
	procedure index_ip_address(	pv_ip_address in varchar2,
								pv_ip_address_idx out number)
	is
	begin
		--Fetch the md5 hash value
		pv_ip_address_idx := get_md5_hash(pv_ip_address);
	end index_ip_address;

	--Description:	This routine receives a record type which is identical to the PAD table without the index columns (i.e. derived columns) populated
	--				the routine will compute the index information using existing attributes in the record (name,addr,phone etc...) and populate the
	--				indexing columns (all columns named like 'DC_G...')
	--Parameters:
	--	1) pr_entity_rec
	--		parameter mode = IN OUT
	--		description = will accept the entity record i.e. dfp pad data.
	--	2) pv_status_msg
	--		parameter mode = OUT
	--		description = will return the status message of the process.
	--	3) pv_status_cd
	--		parameter mode = OUT
	--		description = will return the status code of the process.
	--Performance:
	--  Realtime, no database insert/update/deletes here
	procedure index_entity_info(	pr_entity_rec in out nocopy ty_dfp_idx_pad,
									pv_status_msg out varchar2,
									pv_status_cd out number)
	is
		lv_handled_in_ext	boolean;
		lv_proc_stage		number := 1;
	begin
		--Stage1=user_agent
		lv_proc_stage := 1; --column group for name
		/*pkg_dfp_idx.index_user_agent(	pr_entity_rec.user_agent,
										pr_entity_rec.user_agent_idx);

		--Stage2=ip_address
		lv_proc_stage := 2; --column group for name
		pkg_dfp_idx.index_ip_address(	pr_entity_rec.ip_address,
										pr_entity_rec.ip_address_idx);

		--Pass the generated index though extensiblity routine for post processing*/
		pkg_dfp_ext.post_index_entity_info(	pr_entity_rec,
											pv_status_msg,
											pv_status_cd);

		pv_status_cd := 0; --success
	exception when others then
		pv_status_cd := lv_proc_stage;
		pv_status_msg := sqlerrm;
	end index_entity_info;

	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		-- Created(26-09-2016): Abhishek Sharma
		-- Version: 1.0.0
		-- Description: Initial Draft.
		return '1.0.0';
	end;


end pkg_dfp_idx;
/


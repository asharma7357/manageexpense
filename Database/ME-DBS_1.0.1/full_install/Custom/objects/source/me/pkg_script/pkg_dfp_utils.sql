prompt
prompt Creating package PKG_DFP_UTILS
prompt ================================
prompt
set define off;
create or replace package pkg_dfp_utils is

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
	-- Created : 04-Oct-2016
	-- Purpose : Utility routines for Device Fingerprinting

	--Note: Do not introduce any references to PKG_DFP_EXT from this package. This
	--will cause cyclical depdendency since this package is referred by the PKG_DFP_EXT 
	--for various utility routines

	gc_name constant number := 0;
	gc_addr constant number := 1;
	gc_phone constant number := 2;
	gc_ssn constant number := 3;

	--constants for the API types 
	gc_sum_api constant number := 1;
	gc_dtl_api constant number := 2;
	gc_dec_api constant number := 3;

	gc_tok_type_fname constant number := 1;
	gc_tok_type_lname constant number := 2;
	gc_tok_type_cmpny constant number := 3;

	--Description:	Returns the # of CPU count from oracle parameter "cpu_count" 
	--Parameters:	None
	--Performance:	TBD
	function get_system_cpu_count return number;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2;
end pkg_dfp_utils;
/

prompt
prompt Creating package body PKG_DFP_UTILS
prompt =====================================
prompt
create or replace package body pkg_dfp_utils is

	--constants------------------------
	mc_min_valid_name_length constant number := 2; --minimum length of a name to be considered valid in table AL_DIM_NAME_STATS
	mc_name_freq_thld_f constant number := 100; --AL_DIM_NAME_STATS, all names with frequency of occurance below this are ignored
	mc_name_freq_thld_m constant number := 100;
	mc_name_freq_thld_l constant number := 100;

	--Description:	Returns the # of CPU count from oracle parameter "cpu_count" 
	--Parameters:	None
	--Performance:	TBD
	function get_system_cpu_count return number is
		lv_cpu_count number;
	begin
		execute immediate 'select value from v$parameter where name = ''cpu_count''' into lv_cpu_count;

		if lv_cpu_count > 0 and lv_cpu_count < 64 then
			return lv_cpu_count;
		else
			return 1;
		end if;

	exception
		when others then
			return 1;
	end get_system_cpu_count;
	
	--Description:	Returns the vesion # of the package
	--Parameters:	None
	--Performance:	None
	--Return: varchar2
	function get_version return varchar2 is
	begin
		return '1.0.0';
	end;
end pkg_dfp_utils;
/

prompt
prompt Done.

prompt 
prompt Creating Type ty_dfp_payload ...
prompt

create or replace type ty_dfp_payload as object (
	--------------------------------------------------------------------------------
	---                                                                          ---
	---  Copyright © 2016-2021 Agilis International, Inc.  All rights reserved.  ---
	---                                                                          ---
	--- These scripts/source code and the contents of these files are protected  ---
	--- by copyright law and International treaties.  Unauthorized reproduction  ---
	--- or distribution of the scripts/source code or any portion of these       ---
	--- files, may result in severe civil and criminal penalties, and will be    ---
	--- prosecuted to the maximum extent dfpsible under the law.                 ---
	---                                                                          ---
	--------------------------------------------------------------------------------

	process_time				number,
	req_timeout_thld			number,
	dfp_log_data		ty_dfp_log,
	dfp_idx_pad_data	ty_dfp_idx_pad,
	dfp_match_dtl_data	ty_dfp_match_dtl,
	pq_rslt_tab_data	ty_dfp_pq_rslt_tab,
	fq_rslt_tab_data	ty_dfp_fq_rslt_tab,
	member function get_version return varchar2,

	constructor function ty_dfp_payload(self in out nocopy ty_dfp_payload) return self as result
);
/

create or replace type body ty_dfp_payload is
	--------------------------------------------------------------------------------
	---                                                                          ---
	---  Copyright © 2016-2021 Agilis International, Inc.  All rights reserved.  ---
	---                                                                          ---
	--- These scripts/source code and the contents of these files are protected  ---
	--- by copyright law and International treaties.  Unauthorized reproduction  ---
	--- or distribution of the scripts/source code or any portion of these       ---
	--- files, may result in severe civil and criminal penalties, and will be    ---
	--- prosecuted to the maximum extent dfpsible under the law.                 ---
	---                                                                          ---
	--------------------------------------------------------------------------------

	constructor function ty_dfp_payload(self in out nocopy ty_dfp_payload) return self as result is
	begin
		self.dfp_log_data := ty_dfp_log(null,null,null,null,null,null,null,null,null,null,
										null,null,null,null,null,null,null,null,null,null);

		self.dfp_idx_pad_data := ty_dfp_idx_pad(null,null,null,null,null,null,null,null,null,null,
												null,null,null,null,null,null,null,null,null,null,
												null,null,null,null,null,null,null,null,null,null,
												null,null,null,null,null,null,null);
		
		self.dfp_match_dtl_data := ty_dfp_match_dtl(null,null,null,null);
		
		self.pq_rslt_tab_data := ty_dfp_pq_rslt_tab();
		self.fq_rslt_tab_data := ty_dfp_fq_rslt_tab();
		return;
	end;

	member function get_version return varchar2 is
	begin
		------------------------change history------------------------------------------
		-- Update: <Version No>, <Version Date>
		-- Update By: <Name of the author(s)>
		-- Description: List of changes made in this version


		-- Update: 1.0.0, 21 September 2016
		-- Update By: Abhishek Sharma
		-- Description: Initial code
		------------------------end of change history-----------------------------------
		return '1.0.0';
	end;

end;
/


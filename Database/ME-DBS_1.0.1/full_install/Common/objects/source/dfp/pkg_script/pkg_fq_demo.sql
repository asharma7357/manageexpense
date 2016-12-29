prompt
prompt Create package PKG_FQ_DEMO
prompt ==========================
prompt

create or replace package pkg_fq_demo is

	type gr_attrib_dtl is record (	attrib_names varchar2(100 char),
									attrib_type varchar2(100 char),
									attrib_entropy number,
									match_flags number);
	
	type gt_attrib_dtl is table of gr_attrib_dtl index by binary_integer;
	
	--this function returns a probablity of two devices being the same
	--given the attributes that have matched and the entropy infomation 
	--of the attributes

	--the function below assumes variables are independent and therefore 
	--does not need contigency table. The only requirement is
	--1) List of all attributes (currently only matched attributes are used, in futrure
	-- non matches may also be used)
	--2) Attribute Type - 0=Ordinal, 1=Categorical. Most variables should be Categorical
	--   except values such as latency which is Ordinal.
	--3) Entropy - this is an array of same size as # of attributes with 1-1 mapping
	-- and the value should be calculated as
	--		select -1 * log(2, 1/total_uniq_values) from dual;
	-- Here total_uniq_values is the count in entire population. So, if the attribute is
	-- user_agent and there are 100 different values then the calculation will be
	-- 		select -1 * log(2, 1/100) from dual;
	--		6.6438
	--4) Match Flag is a boolean array of same size as attribute names with value
	--  0=not matched
	--  1=matched
	function calc_conditional_prob(
		pa_attrib_names dbms_sql.Varchar2_Table,
		pa_attrib_type dbms_sql.number_table,
		pv_attrib_entropy dbms_sql.number_table,
		pa_match_flags dbms_sql.number_table
		) return number;
		
	
	--This is a demo function that makes simple assumption that all variables are
	--independent and conditional probablities do not need to be calculated
	--This function is to be refined for a more accurate outcome.
	function calc_conditional_prob(	pa_attrib_dtl in gt_attrib_dtl) return number;

end pkg_fq_demo;
/

prompt
prompt Create package body PKG_FQ_DEMO
prompt ==========================
prompt
create or replace package body pkg_fq_demo is

	
	function ln_func(pv_val number) return number is
	begin
		--optimize
		if pv_val < exp(-6) then
			return 0;
		else
			return pv_val * ln(pv_val);
		end if;
	end;

	-- Calculates chi-squared statistic for contingency table.
	-- pa_matrix the contigency table
	-- pv_cols is the number of columns in matrix
	-- pv_rows is the number of rows in matrix
	-- pv_rows * pv_cols should be the length of the array pa_matrix
	-- pv_yates is yates correction to be used (0=false,1=true)
	function chi_val(
		pa_matrix in dbms_sql.Number_Table,
		pv_cols in number,
		pv_rows in number,
		pv_yates in number) return number is
		
		lv_chi_val number := 0;
		la_rtotal dbms_sql.number_table;
		la_ctotal dbms_sql.number_table;
		
		lv_n number := 0;
		lv_df number := 0;
		lv_yates number := pv_yates;
		lv_expect number;

		--Calculate chi-value for one cell in a contingency table.
		--pv_freq the observed frequency in the cell
		--pv_expected the expected frequency in the cell
		function chi_cell(
			pv1_freq in number, 
			pv1_expected in number,
			pv1_yates in number) return number is
			
			lc_yates_correction constant number := -0.5;
		begin
			if pv1_expected <= 0 then
				return 0;
			end if;
			
			--Return chi-value for the cell
    		return power(greatest(abs(pv1_freq - pv1_expected) + (pv1_yates * lc_yates_correction), 0),2) / pv1_expected;
		end;


	begin

		for lv_row in 1..pv_rows loop
			for lv_col in 1..pv_cols loop
				la_rtotal(lv_row) := la_rtotal(lv_row) + pa_matrix((lv_row * pv_cols) + lv_col);
				la_ctotal(lv_col) := la_rtotal(lv_row) + pa_matrix((lv_row * pv_cols) + lv_col);
				lv_n := lv_n + pa_matrix((lv_row * pv_cols) + lv_col);
			end loop;
		end loop;

		lv_df := (pv_rows - 1)*(pv_cols - 1);
		if (lv_df > 1 and lv_yates = 0) then
			lv_yates := 0;
		elsif (lv_df <= 0) then
			return 0;
		end if;

		for lv_row in 1..pv_rows loop
			if la_rtotal(lv_row) > 0 then
				for lv_col in 1..pv_cols loop
					if la_ctotal(lv_col) > 0 then
						lv_expect := la_ctotal(lv_col) * la_rtotal(lv_row) / lv_n;
						lv_chi_val := lv_chi_val + chi_cell(pa_matrix((lv_row * pv_cols) + lv_col), lv_expect, lv_yates);
					end if;
				end loop;
			end if;
		end loop;

		return lv_chi_val;
	end;

	--calc chi-squared probability for a given matrix.
	-- pa_matrix the contigency table
	-- pv_cols is the number of columns in matrix
	-- pv_rows is the number of rows in matrix
	-- pv_rows * pv_cols should be the length of the array pa_matrix
	-- pv_yates is yates correction to be used (0=false,1=true)
	function chi_sq_probability(
		pa_matrix in dbms_sql.Number_Table,
		pv_cols in number,
		pv_rows in number,
		pv_yates in number) return number is

		lv_df number := 0;
	begin
		lv_df := (pv_rows - 1)*(pv_cols - 1);

		return 0; --    return Statistics.chiSquaredProbability(chiVal(matrix, yates), df);
	end;

	-- Calculate conditional entropy of the rows given the columns.
	-- pa_matrix the contigency table
	-- pv_cols is the number of columns in matrix
	-- pv_rows is the number of rows in matrix
	function calc_ent_conditioned_on_cols(
		pa_matrix in dbms_sql.Number_Table,
		pv_cols in number,
		pv_rows in number) return number is

		lv_calc_ent number := 0;
		lv_col_total number := 0;
		lv_total number := 0;
	begin
    	for lv_col in 1..pv_cols loop
			lv_col_total := 0;
			for lv_row in 1..pv_rows loop
				lv_calc_ent := lv_calc_ent + ln_func(pa_matrix(lv_row * pv_cols) + lv_col);
				lv_col_total := lv_col_total + pa_matrix((lv_row * pv_cols) + lv_col);
			end loop;
			lv_calc_ent := lv_calc_ent - ln_func(lv_col_total);
			lv_total := lv_total + lv_col_total;
		end loop;

		if lv_total = 0 then
			return 0;
		else
			return lv_calc_ent * -1 / (lv_total * ln(2));
		end if;
	end;

	function calc_ent_conditioned_on_rows(
		pa_matrix in dbms_sql.Number_Table,
		pv_cols in number,
		pv_rows in number) return number is

		lv_calc_ent number := 0;
		lv_row_total number := 0;
		lv_total number := 0;
	begin
		for lv_row in 1..pv_rows loop
			lv_row_total := 0;
			for lv_col in 1..pv_cols loop
				lv_calc_ent := lv_calc_ent + ln_func(pa_matrix(lv_row * pv_cols) + lv_col);
				lv_row_total := lv_row_total + pa_matrix((lv_row * pv_cols) + lv_col);
			end loop;
			lv_calc_ent := lv_calc_ent - ln_func(lv_row_total);
			lv_total := lv_total + lv_row_total;
		end loop;

		if lv_total = 0 then
			return 0;
		else
			return lv_calc_ent * -1 / (lv_total * ln(2));
		end if;
	end;

	function get_ent_over_rows(
		pa_matrix in dbms_sql.Number_Table,
		pv_cols in number,
		pv_rows in number) return number is
		
		lv_calc_ent number := 0;
		lv_row_total number := 0;
		lv_total number := 0;
	begin	
		for lv_row in 1..pv_rows loop
			lv_row_total := 0;
			for lv_col in 1..pv_cols loop
				lv_row_total := lv_row_total + pa_matrix((lv_row * pv_cols) + lv_col);
			end loop;
			lv_calc_ent := lv_calc_ent - ln_func(lv_row_total);
			lv_total := lv_total + lv_row_total;
		end loop;

		if lv_total = 0 then
			return 0;
		else
			return (lv_calc_ent + ln_func(lv_total))/(lv_total * ln(2));
		end if;
	end;


	--This is a demo function that makes simple assumption that all variables are
	--independent and conditional probablities do not need to be calculated
	--This function is to be refined for a more accurate outcome.
	function calc_conditional_prob(
		pa_attrib_names dbms_sql.Varchar2_Table,
		pa_attrib_type dbms_sql.number_table,
		pv_attrib_entropy dbms_sql.number_table,
		pa_match_flags dbms_sql.number_table
		) return number is
		
		lv_calc_entropy number := 0; 
	begin
		for i in 1..pa_attrib_names.count loop
			if pa_match_flags(i) = 1 then
				lv_calc_entropy := lv_calc_entropy + pv_attrib_entropy(i);
			end if;
		end loop;
		return lv_calc_entropy;
	end;

	--This is a demo function that makes simple assumption that all variables are
	--independent and conditional probablities do not need to be calculated
	--This function is to be refined for a more accurate outcome.
	function calc_conditional_prob(	pa_attrib_dtl in gt_attrib_dtl) return number is
		lv_calc_entropy number := 0; 
	begin
		for i in 1..pa_attrib_dtl.count loop
			if pa_attrib_dtl(i).match_flags = 1 then
				lv_calc_entropy := lv_calc_entropy + pa_attrib_dtl(i).attrib_entropy;
			end if;
		end loop;
		return lv_calc_entropy;
	end;

end pkg_fq_demo;
/



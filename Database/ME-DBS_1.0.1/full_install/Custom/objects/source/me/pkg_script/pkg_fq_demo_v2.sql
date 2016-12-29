prompt
prompt Create package PKG_FQ_DEMO_V2
prompt ============================
prompt

create or replace package pkg_fq_demo_v2 is

	type gr_attrib_dtl is record (	attrib_names varchar2(100 char),
									attrib_type varchar2(100 char),
									attrib_entropy number,
									match_flags number);

	type gt_attrib_dtl is table of gr_attrib_dtl index by binary_integer;


	type gr_attrib_stats is record (
		attrib_a varchar2(100),
		attrib_b varchar2(100),
		attrib_a_val varchar2(4000),
		attrib_b_val varchar2(4000),
		stats number);

	type gt_attrib_stats is table of gr_attrib_stats index by binary_integer;

	function get_cont_tab(
		pv_table_name in varchar2, --table that has Device fingerprint data
		pa_attrib_names in dbms_sql.Varchar2_Table, --device fingerpeint attributes (exclude any ID or other non device attributes from this list, any nominal attributes are also to be excluded).
		pv_exclude_filter in varchar2 --optional where clause to exclude any records from the statistics collection
		) return gt_attrib_stats;

	function gamma_ln(
    	pv_x in binary_double) return binary_double;

	--test: select incomp_gamma(3, 5) from dual
	--0.184736755476202
	function incomp_gamma(
		pv_x in number,
		pv_a in number) return number;

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

end pkg_fq_demo_v2;
/

prompt
prompt Create package body PKG_FQ_DEMO_V2
prompt ============================
prompt

create or replace package body pkg_fq_demo_v2 is

	--given an input table, this function will return the statistics for the device fingerprint attributes and store it in a contingency table
	--the table should have the structure
	--create table dfp_attrib_ccont_stats(
	--col_a varchar2(100),
	--col_b
	function get_cont_tab(
		pv_table_name in varchar2, --table that has Device fingerprint data
		pa_attrib_names in dbms_sql.Varchar2_Table, --device fingerpeint attributes (exclude any ID or other non device attributes from this list, any nominal attributes are also to be excluded).
		pv_exclude_filter in varchar2 --optional where clause to exclude any records from the statistics collection
		) return gt_attrib_stats is

		lv_sql varchar2(4000);
		la_attrib_stats gt_attrib_stats;
		la_attrib_stats_tmp gt_attrib_stats;
	begin
		for i in 1..pa_attrib_names.count loop
			for j in i+1..pa_attrib_names.count loop
				--calculate the stats for this pair
				lv_sql := 'select '''|| pa_attrib_names(i) ||''' as col_a, ''' || pa_attrib_names(j) || ''' as col_b, '|| pa_attrib_names(i) ||' as col_a_val, ' || pa_attrib_names(j) || ' as col_b_val, count(*) as stat from ' || pv_table_name;
				if pv_exclude_filter is not null then
					lv_sql := lv_sql || ' where ' || pv_exclude_filter;
				end if;
				lv_sql := lv_sql || ' group by '|| pa_attrib_names(i) ||', '|| pa_attrib_names(j) ||'';
				execute immediate lv_sql bulk collect into la_attrib_stats_tmp;
				for k in 1..la_attrib_stats_tmp.count loop
					la_attrib_stats(la_attrib_stats.count) := la_attrib_stats_tmp(k);
				end loop;
			end loop;
		end loop;
		return la_attrib_stats;
	end;

	function ln_func(pv_val number) return number is
	begin
		--optimize
		if pv_val < exp(-6) then
			return 0;
		else
			return pv_val * ln(pv_val);
		end if;
	end;

	-- Calculate the natural logarithm of gamma function
	function gamma_ln(
    	pv_x in binary_double) return binary_double is

		lv_ser binary_double;
		lv_tmp binary_double;
	begin
		lv_tmp := pv_x + 5.5;
		lv_tmp :=(pv_x + 0.5) * ln(lv_tmp) - lv_tmp;
		lv_ser := 1.000000000190015;
		lv_ser := lv_ser + 76.18009172947146 /(pv_x + 1.0) ;
		lv_ser := lv_ser - 86.50532032941677 /(pv_x + 2.0) ;
		lv_ser := lv_ser + 24.01409824083091 /(pv_x + 3.0) ;
		lv_ser := lv_ser - 1.231739572450155 /(pv_x + 4.0) ;
		lv_ser := lv_ser + 1.208650973866179e-03 /(pv_x + 5.0) ;
		lv_ser := lv_ser - 5.395239384953e-06 /(pv_x + 6.0) ;
		return lv_tmp + ln(2.5066282746310005 * lv_ser / pv_x) ;
	end;


	-- Calculate incomplete gamma function
	-- To test:
	-- select pkg_name.incomp_gamma(4,3) from dual;
	function incomp_gamma(
		pv_x in number,
		pv_a in number) return number is

		lv_gam number;
		lv_b  number;
		lv_ap	number;
		lv_sum number;
		lv_del number;
		lv_a0	number;
		lv_a1	number;
		lv_b0	number;
		lv_b1	number;
		lv_fac number;
		lv_n  number;
		lv_g  number;
		lv_gold number;
		lv_ana	number;
		lv_anf	number;
	begin

		lv_b := pv_x;
		if pv_x=0 then
			lv_b:=0;
		end if;
		if pv_a=0 then
			lv_b:=1;
		end if;
		lv_gam := gamma_ln(pv_a);
		if pv_x < (pv_a + 1.0) then
			lv_ap := pv_a;
			lv_sum := 1/lv_ap;
			lv_del := lv_sum;
			while abs(lv_del)>=1e-12*abs(lv_sum) loop
				lv_ap := lv_ap + 1.0;
				lv_del:= pv_x * lv_del / lv_ap;
				lv_sum:= lv_sum + lv_del;
			end loop;
			lv_b := lv_sum * exp( -pv_x + pv_a*ln(pv_x)-lv_gam);
		else
			lv_a0 := 1.0;
			lv_a1 := pv_x;
			lv_b0 := 0.0;
			lv_b1 := lv_a0;
			lv_fac:= 1.0;
			lv_n	:= 1.0;
			lv_g	:= lv_b1;
			lv_gold:=lv_b0;
			while abs(lv_g-lv_gold)>=1e-12*abs(lv_g) loop
				lv_gold:= lv_g;
				lv_ana := lv_n-pv_a;
				lv_a0	:= (lv_a1+lv_a0*lv_ana)*lv_fac;
				lv_b0	:= (lv_b1+lv_b0*lv_ana)*lv_fac;
				lv_anf := lv_n*lv_fac;
				lv_a1	:= pv_x * lv_a0 + lv_anf * lv_a1;
				lv_b1	:= pv_x * lv_b0 + lv_anf * lv_b1;
				lv_fac := 1/lv_a1;
				lv_g  := lv_b1 * lv_fac;
				lv_n  := lv_n + 1.0;
			end loop;
			lv_b := 1.0 - exp(-pv_x + pv_a*ln(pv_x) - lv_gam) * lv_g;
		end if;
		return lv_b;
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

		lv_df number := 0; --degrees of freedom
		lv_chi_val number := 0;
	begin
		lv_df := (pv_rows - 1)*(pv_cols - 1);

		--chi-squared probability is that the chi-squared variate
		--will be greater than x for the given degrees of freedom
		lv_chi_val := chi_val(pa_matrix, pv_cols, pv_rows, pv_yates);
		if( lv_chi_val < 0 or lv_df < 1) then
			return 0;
		else
			return incomp_gamma(lv_df/2, lv_chi_val/2);
		end if;
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

end pkg_fq_demo_v2;
/

prompt
prompt Done.

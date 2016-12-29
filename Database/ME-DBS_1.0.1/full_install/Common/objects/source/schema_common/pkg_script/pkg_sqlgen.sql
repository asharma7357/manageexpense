prompt
prompt Creating package PKG_SQLGEN
prompt ===========================
prompt
create or replace package pkg_sqlgen is

--------------------------------------------------------------------------------
---                                                                          ---
---  Copyright ¿ 2005-2006 Agilis International, Inc.  All rights reserved.  ---
---                                                                          ---
--- These scripts/source code and the contents of these files are protected  ---
--- by copyright law and International treaties.  Unauthorized reproduction  ---
--- or distribution of the scripts/source code or any portion of these       ---
--- files, may result in severe civil and criminal penalties, and will be    ---
--- prosecuted to the maximum extent possible under the law.                 ---
---                                                                          ---
--------------------------------------------------------------------------------


	function get_table_desc(pv_table_name in varchar2) return dbms_sql.desc_tab;

	function is_number(pv_value in varchar2) return boolean;

	--data type = 1 or data type = 96 :Varchar2
	--data type = 12 then :Date
	--data type = 2 then :Number
	function get_datatype(
		pv_attrib_name in varchar2,
		pa_tab_cols in dbms_sql.desc_tab) return number;

	--set pv_char_conversion= true if explicit conversion of number to varchar is required
	procedure format_attribute(
		pv_attrib_name in out varchar2,
		pv_attrib_value in out varchar2,
		pv_relational_op in out varchar2,
		pv_case_sensitive in boolean,
		pv_data_type in number,
		pv_char_conversion in boolean default false);

	procedure format_attribute1(
		pv_src_attrib_name in out varchar2,
		pv_src_data_type in number,
		pv_dst_attrib_name in out varchar2,
		pv_dst_data_type in number,
		pv_relational_op in out varchar2,
		pv_case_sensitive in boolean,
		pv_char_conversion in boolean default false);

	--this function will format a SQL stmt where both the src operand is table attributes
	--and it is matched with a literal
	-- for example: column_name = value
	function get_sql_clause(
		pa_tab_cols in dbms_sql.desc_tab,
		pv_attribute_name in varchar2,
		pv_relational_op in varchar2,
		pv_attribute_value in varchar2,
		pv_case_sensitive in boolean default true) return varchar2;

	--this function will format a SQL stmt where both the operand are table attributes
	-- for example: column_name = column_name
	function get_sql_clause1(
		pa_src_tab_cols in dbms_sql.desc_tab,
		pv_src_attrib_name in varchar2,
		pv_relational_op in varchar2,
		pa_dst_tab_cols in dbms_sql.desc_tab,
		pv_dst_attrib_name in varchar2,
		pv_case_sensitive in boolean default true) return varchar2;

	--concat multiple clauses
	procedure append_to_main_clause(
		pv_sql_clause in out varchar2,
		pv_append_clause in varchar2,
		pv_rel_op in varchar2 default 'and',
		pv_add_braces in boolean default false);

	--this function will ensure that the sql stmt is syntactically
	--valid and if not return a error message
	function sql_valid(
		pv_sql_stmt in varchar2,
		pv_status_msg out varchar2) return boolean;

	   
  -- Function returns comma separated string enclosed with single quotes
  function put_quotes_with_comma(var1 varchar2) return varchar2;
   
	--This function returns version information for this package
	function get_version return varchar2;

end pkg_sqlgen;
/

prompt
prompt Creating package Body PKG_SQLGEN
prompt ================================
prompt
create or replace package body pkg_sqlgen is



	function get_table_desc(pv_table_name in varchar2) return dbms_sql.desc_tab is
		lv_cur numeric;
		lv_count numeric;
		lv_stmt varchar2(2000);
		la_tab_cols dbms_sql.desc_tab;
	begin
		lv_stmt := 'select * from '||pv_table_name;
		lv_cur := dbms_sql.open_cursor;
		dbms_sql.parse(lv_cur,lv_stmt,dbms_sql.native);
		dbms_sql.describe_columns(lv_cur,lv_count,la_tab_cols);
		dbms_sql.close_cursor(lv_cur);
		return la_tab_cols;
	end;
	
	function put_quotes_with_comma(var1 varchar2) return varchar2 is
     var2 varchar2(100) := null;
     prev_pos number(5):= 0;
     next_pos number(5):= 0;
  begin
      loop
          next_pos := instr(var1,',',prev_pos+1);
          if next_pos = 0 then
             var2 := var2||''''||upper(substr(var1,prev_pos+1))||'''';
          else
             var2 := var2||''''||upper(substr(var1,prev_pos+1,next_pos-prev_pos-1))||''''||',';
             prev_pos := next_pos;
          end if;
          exit when next_pos = 0;
      end loop;
      return var2;
   end;
   
	function is_number(pv_value in varchar2) return boolean is
		lv_dummy numeric;
	begin
		lv_dummy := to_number(pv_value);
		return true;
	exception
		when others then
			return false;
	end;

	function is_date(pv_value in varchar2) return boolean is
		lv_dummy date;
	begin
		lv_dummy := to_date(pv_value,'yyyymmddhh24miss');
		return true;
	exception
		when others then
			return false;
	end;

	--This function returns true if a sql expression value evaluates
	--correctly as date. For example "sysdate-10" or "add_months(sysdate, 3)"
	function is_date_expression(pv_value in varchar2) return boolean is
		lv_dummy date;
	begin
		execute immediate 'select '||pv_value||' from dual' into lv_dummy;
		return true;
	exception
		when others then
			return false;
	end;

	--data type = 1 or data type = 96 :Varchar2
	--data type = 12 then :Date
	--data type = 2 then :Number
	function get_datatype(
		pv_attrib_name in varchar2,
		pa_tab_cols in dbms_sql.desc_tab) return number is
		lv_col_id numeric;
	begin
		--get data type of attribute from tab_cols ( index- by  table )
		for lv_col_id in 1..pa_tab_cols.last loop
			if pa_tab_cols(lv_col_id).col_name = upper(pv_attrib_name) then
				return pa_tab_cols(lv_col_id).col_type;
				exit;
			end if;
		end loop;
		return -1;
	exception
		when others then
			return -1;
	end;

	function put_quotes(pv_value in varchar2) return varchar2 is
	begin
		return ''''||replace(pv_value,'''','''''''')||'''';
	end;

	function has_wildcard(pv_value in varchar2) return boolean is
	begin
		if instr(pv_value,'%') > 0 or
			instr(pv_value,'_') > 0 then
			return true;
		else
			return false;
		end if;
	end;

	--pv_case_sensitive = 0 :case_sensitive false
	--pv_case_sensitive = 1 :case_sensitive true
	--set pv_char_conversion= true if explicit conversion of number to varchar is required
	procedure format_attribute(
		pv_attrib_name in out varchar2,
		pv_attrib_value in out varchar2,
		pv_relational_op in out varchar2,
		pv_case_sensitive in boolean,
		pv_data_type in number,
		pv_char_conversion in boolean default false) is

	begin
		if pv_data_type = 1 or pv_data_type = 96 then  --varchar2
			--Note if the attribute value is numeric, then do not put upper to attribute name
			--as it will slow down the query and avoid index
			if pv_case_sensitive = false and is_number(pv_attrib_value) = false --case_sensitive false
					and upper(pv_relational_op) not in ('IS NULL', 'IS NOT NULL ','IN','NOT IN') then -- if rel operator is null/not null than ignore
				pv_attrib_value := put_quotes(pv_attrib_value);
				pv_attrib_value := upper(pv_attrib_value);
				pv_attrib_name := 'upper('||pv_attrib_name||')';
			elsif upper(pv_relational_op) not in ('IS NULL', 'IS NOT NULL ','IN','NOT IN') then
				pv_attrib_value := put_quotes(pv_attrib_value);
      elsif upper(pv_relational_op) in ('IN','NOT IN') then
        pv_attrib_name  := 'upper('||pv_attrib_name||')';
        pv_attrib_value := ' ('||put_quotes_with_comma(pv_attrib_value)||')';  
			end if;
		elsif pv_data_type = 12 then         --date
			if length(pv_attrib_value) = 14 then
				if is_date(pv_attrib_value) = false then
					if not is_date_expression(pv_attrib_value) then
						raise_application_error(-20000,'Invalid Date format for '||pv_attrib_name||' [yyyymmddhh24miss]: '||pv_attrib_value);
					end if;
				else
					pv_attrib_value := 'to_date('''||pv_attrib_value||''',''yyyymmddhh24miss'')';
				end if;
			else
				if not is_date_expression(pv_attrib_value) then
					raise_application_error(-20000,'Invalid Date format/expression for '||pv_attrib_name||' [yyyymmddhh24miss]: '||pv_attrib_value);
				end if;
			end if;
		elsif pv_data_type = 2 then          --number
			if has_wildcard(pv_attrib_value) and upper(pv_relational_op) not in ('IN','NOT IN') then
				pv_attrib_value := put_quotes(pv_attrib_value);
				pv_attrib_name := 'to_char('||pv_attrib_name||')';
				if pv_relational_op = '=' then
					pv_relational_op := 'like';
				elsif pv_relational_op = '!=' or pv_relational_op = '<>' then
					pv_relational_op := 'not like';
				elsif upper(pv_relational_op) = 'LIKE' or  upper(pv_relational_op) = 'NOT LIKE' then
					null;
				else
					raise_application_error(-20000,'Invalid relational operator with wildcards for attribute '||pv_attrib_name);
				end if;
			elsif pv_char_conversion = true and upper(pv_relational_op) not in ('IN','NOT IN')then
				pv_attrib_value := put_quotes(pv_attrib_value);
				pv_attrib_name := 'to_char('||pv_attrib_name||')';
      elsif upper(pv_relational_op) in ('IN','NOT IN') then
        pv_attrib_value := ' ('||pv_attrib_value||')';  
			else
				if is_number(pv_attrib_value) = false then
					raise_application_error(-20000,'Invalid Number for attribute '||pv_attrib_name||': '||nvl(pv_attrib_value,'<<null>>'));
				end if;
			end if;
		end if;
	end;

	--pv_case_sensitive = 0 :case_sensitive false
	--pv_case_sensitive = 1 :case_sensitive true
	--set pv_char_conversion= true if explicit conversion of number to varchar is required
	procedure format_attribute1(
		pv_src_attrib_name in out varchar2,
		pv_src_data_type in number,
		pv_dst_attrib_name in out varchar2,
		pv_dst_data_type in number,
		pv_relational_op in out varchar2,
		pv_case_sensitive in boolean,
		pv_char_conversion in boolean default false) is

	begin
		--check for datatype mismatch
		if pv_src_data_type <> pv_dst_data_type then
			if (pv_dst_data_type=1 or pv_dst_data_type=96) and
				(pv_src_data_type=1 or pv_src_data_type=96) then
				null; --both a strings
			else
				raise_application_error(-20000,'Data type mismatch for attribute '||pv_src_attrib_name);
			end if;
		end if;
		if pv_src_data_type = 1 or pv_src_data_type = 96 then  --varchar2
			if pv_case_sensitive = false then --case_sensitive false
				pv_src_attrib_name := 'upper('||pv_src_attrib_name||')';
				pv_dst_attrib_name := 'upper('||pv_dst_attrib_name||')';
			end if;
		elsif pv_src_data_type = 12 then         --date
			null;
		elsif pv_src_data_type = 2 then          --number
			null;
		end if;
	end;

	function get_sql_clause(
		pa_tab_cols in dbms_sql.desc_tab,
		pv_attribute_name in varchar2,
		pv_relational_op in varchar2,
		pv_attribute_value in varchar2,
		pv_case_sensitive in boolean default true) return varchar2 is

		lv_sql_clause varchar2(4000);
		lv_attribute_name varchar2(1000);
		lv_db_attrib_name varchar2(1000);
		lv_attribute_value varchar2(1000);
		lv_relational_op varchar2(1000);
		lv_data_type number(2);
	begin
		lv_sql_clause := '';
		lv_attribute_name := pv_attribute_name;
		lv_relational_op := pv_relational_op;
		lv_attribute_value := pv_attribute_value;
		dbms_output.put_line('Attribute name: '||pv_attribute_name);
		lv_db_attrib_name := substr(pv_attribute_name,instr(pv_attribute_name,'.')+1);
		lv_data_type := get_datatype(lv_db_attrib_name,pa_tab_cols);
		if lv_data_type = -1 then
			raise_application_error(-20000,'Unidentified Attribute '||lv_db_attrib_name);
		end if;
		dbms_output.put_line('Data Type: '||lv_data_type);
		format_attribute(lv_attribute_name,
				lv_attribute_value,lv_relational_op,pv_case_sensitive,lv_data_type);
		lv_sql_clause := lv_attribute_name||' '||lv_relational_op||' '||lv_attribute_value;
		dbms_output.put_line('SQL clause: '||lv_sql_clause);
		return lv_sql_clause;
	end;

	function get_sql_clause1(
		pa_src_tab_cols in dbms_sql.desc_tab,
		pv_src_attrib_name in varchar2,
		pv_relational_op in varchar2,
		pa_dst_tab_cols in dbms_sql.desc_tab,
		pv_dst_attrib_name in varchar2,
		pv_case_sensitive in boolean default true) return varchar2 is

		lv_sql_clause varchar2(4000);
		lv_src_attrib_name varchar2(1000);
		lv_src_db_attrib_name varchar2(1000);
		lv_src_data_type number(2);
		lv_dst_attrib_name varchar2(1000);
		lv_dst_db_attrib_name varchar2(1000);
		lv_dst_data_type number(2);
		lv_relational_op varchar2(1000);
	begin
		lv_sql_clause := '';
		lv_src_attrib_name := pv_src_attrib_name;
		lv_src_db_attrib_name := substr(lv_src_attrib_name,instr(lv_src_attrib_name,'.')+1);
		lv_src_data_type := get_datatype(lv_src_attrib_name,pa_src_tab_cols);
		if lv_src_data_type = -1 then
			raise_application_error(-20000,'Unidentified Attribute '||lv_src_attrib_name||'['||lv_src_db_attrib_name||']');
		end if;
		lv_dst_attrib_name := pv_dst_attrib_name;
		lv_dst_db_attrib_name := substr(lv_dst_attrib_name,instr(lv_dst_attrib_name,'.')+1);
		lv_dst_data_type := get_datatype(lv_dst_attrib_name,pa_dst_tab_cols);
		if lv_dst_data_type = -1 then
			raise_application_error(-20000,'Unidentified Attribute '||lv_dst_attrib_name||'['||lv_dst_db_attrib_name||']');
		end if;
		lv_relational_op := pv_relational_op;

		format_attribute1(lv_src_attrib_name,lv_src_data_type,
			lv_dst_attrib_name,lv_dst_data_type,lv_relational_op,pv_case_sensitive);

		lv_sql_clause := lv_src_attrib_name||' '||lv_relational_op||' '||lv_dst_attrib_name;
		dbms_output.put_line('SQL clause: '||lv_sql_clause);
		return lv_sql_clause;
	end;

	procedure append_to_main_clause(
		pv_sql_clause in out varchar2,
		pv_append_clause in varchar2,
		pv_rel_op in varchar2 default 'and',
		pv_add_braces in boolean default false) is

		lv_append_clause varchar2(500);
	begin
		if pv_append_clause is not null or trim(pv_append_clause) <> '' then
			if pv_add_braces = true then
				lv_append_clause := '('||pv_append_clause||')';
			else
				lv_append_clause := pv_append_clause;
			end if;
			if pv_sql_clause is not null or trim(pv_sql_clause) <> '' then
				if pv_rel_op = 'null' then
					pv_sql_clause := pv_sql_clause||' '||lv_append_clause;
				else
					pv_sql_clause := pv_sql_clause||' '||pv_rel_op||' '||lv_append_clause;
				end if;
			else
				pv_sql_clause := lv_append_clause;
			end if;
		end if;
	end append_to_main_clause;

	--this function will ensure that the where clause is syntactically
	--valid and if not return a error message
	function sql_valid(
		pv_sql_stmt in varchar2,
		pv_status_msg out varchar2) return boolean is

		lv_cur numeric;
	begin
		--use dynamic sql to parse the statement and
		--report errors if any
		lv_cur := dbms_sql.open_cursor;
		dbms_sql.parse(lv_cur,pv_sql_stmt,dbms_sql.native);
		dbms_sql.close_cursor(lv_cur);
		return true; --all's fine
	exception
		when others then
			dbms_sql.close_cursor(lv_cur);
			pv_status_msg := sqlerrm;
			return false;
	end sql_valid;

	function get_version return varchar2 is
	begin

		-- Author  : Sanjay Almiya
		-- Created : 1st Jan 2003
		-- Purpose : Generic SQL generator routines

		--Note: This is a common package and NO DEPENDENCIES should be introduced
		--in this package on any local object. Any errors will be raise, or returned
		--back as status, but no logging to any table is performed
		--Run the SQL below to verify dependencies:
		--select * from DBA_DEPENDENCIES where name like '%SQLGEN%'

		--Last modified: 30th Aug 2006
		--2.1.2 (Almiya)
		--Added support for date attributes values as function expression
		--which evaluate to date values
		--For example in the where clause "SVC_INSTALL_DT < sysdate-10"
		-- "sysdate-10" is a function which is a valid date expression

		return '2.1.2';
	end;

end pkg_sqlgen;
/
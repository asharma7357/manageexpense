-- **************************************
--
-- SYNONYMS USE IN DFP_ADMIN...
-- **************************************

prompt
prompt Creating synonym from DFP
prompt ================================================
prompt

set serveroutput on

declare
	lv_dfp_pos_flag	varchar2(10) := '#DFP_POS_SINGLE_INSTANCE';
	lv_db_pos_name	varchar2(30) := '#DFP_POS_DBLINK_NAME';
	
	la_pos_obj		dbms_sql.varchar2_table;

begin
	#NMPOS_COMMENT_ST
	begin
		la_pos_obj(1)	:= 'al_ws_req';
		la_pos_obj(2)	:= 'al_pos_log';
		la_pos_obj(3)	:= 'al_rslt_fq_t1';
		
		for i in 1..la_pos_obj.count loop
			if lv_dfp_pos_flag = 'N' then
				execute immediate 'create or replace synonym '||la_pos_obj(i)||' for '||la_pos_obj(i)||'@'||lv_db_pos_name;
			else
				execute immediate 'create or replace synonym '||la_pos_obj(i)||' for #POS_SCHEMA_USERNAME.'||la_pos_obj(i);
			end if;
		end loop;
	exception
		when others then
			dbms_output.put_line('Error to create POS synonyms: '||sqlerrm);
	end;
	#NMPOS_COMMENT_ED
	null;
end;
/

prompt Done.

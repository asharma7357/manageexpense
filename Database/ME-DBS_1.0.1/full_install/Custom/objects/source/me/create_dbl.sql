-- **************************************************
--
-- DATABASE LINKS USE IN DFP_ADMIN...
-- This script creates the DB link to communicate pos schema with DFP.
--
-- **************************************************
prompt
prompt Create database link #DFP_POS_DBLINK_NAME for DFP SCHEMA
prompt ==================================
prompt

set feedback off
set serveroutput on

declare
	-- DFP schema
	lv_dfp_db_name	varchar2(30)	:= '#DFP_POS_DBLINK_NAME';
	lv_pos_username	varchar2(100)	:= '#POS_SCHEMA_USERNAME';
	lv_pos_userpass	varchar2(100)	:= '#POS_SCHEMA_USER_PWD';
	lv_pos_host		varchar2(10000)	:= '#POS_SCHEMA_CONN_STR';
	lv_dfp_pos_flag	varchar2(10)	:= '#DFP_POS_SINGLE_INSTANCE';
	
	lv_not_exist	exception;
	pragma exception_init(lv_not_exist,-02024);
begin
	#NMPOS_COMMENT_ST
	-- Create db link on dfp schema if dfp and pos schema both are on different instance
	begin
		if lv_dfp_pos_flag = 'N' then
			-- Drop the database link
			begin
				execute immediate 'drop database link '||lv_dfp_db_name;
			exception
				when lv_not_exist then
					null;
			end;

			-- Create the database link
			execute immediate 'create database link '||lv_dfp_db_name||' connect to '||lv_pos_username||' identified by '||lv_pos_userpass||' using '''||lv_pos_host||'''';
		end if;
	exception
		when others then
			dbms_output.put_line('Error: '||sqlerrm);
	end;
	#NMPOS_COMMENT_ED
	null;
end;
/

prompt
prompt Done

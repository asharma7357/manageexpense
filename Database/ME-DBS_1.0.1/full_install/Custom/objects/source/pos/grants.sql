prompt
prompt Grant script
prompt =============
prompt

declare
	la_pos_object		dbms_sql.varchar2_table;
	lv_dfp_pos_flag		varchar2(10) := '#DFP_POS_SINGLE_INSTANCE';
begin

	la_pos_object(1) := 'AL_WS_REQ';
	la_pos_object(2) := 'AL_POS_LOG';
	la_pos_object(3) := 'AL_RSLT_FQ_T1';

	begin
		if lv_dfp_pos_flag = 'Y' then
			dbms_output.put_line('');
			dbms_output.put_line('Providing grants to DFP SCHEMA');
			dbms_output.put_line('================================');
			dbms_output.put_line('');
			for i in 1..la_pos_object.count loop
				execute immediate 'grant select on '||la_pos_object(i)||' to #DFP_SCHEMA_USERNAME with grant option';
			end loop;
			dbms_output.put_line('Done.');
		end if;
	exception
		when others then
			dbms_output.put_line('Error granting EVT table: '||sqlerrm);
	end;
end;
/
prompt
prompt Done.

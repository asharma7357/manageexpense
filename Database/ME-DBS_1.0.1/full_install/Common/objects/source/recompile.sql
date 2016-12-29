prompt Re-compiling invalid objects
set serveroutput on
declare
	lv_user varchar2(100);
begin
	select user into lv_user from dual;
	dbms_utility.compile_schema(lv_user);
exception
	when others then
		begin
			dbms_output.put_line(' Recompilation failed : ' || substr(SQLERRM,1,200));
		exception
			when others then
				null;
		end;
end;
/
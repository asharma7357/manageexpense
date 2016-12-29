prompt
prompt Create Type TY_PROD_DTL
prompt =======================
prompt
create type ty_dfp_api is object (	key varchar2(100 char),
									value varchar2(4000 char),
									constructor function ty_dfp_api return self as result);
/

prompt
prompt Create Constructor TY_PROD_DTL
prompt ==============================
prompt
create or replace type body ty_dfp_api as
	constructor function ty_dfp_api(self in out nocopy ty_dfp_api) return self as result
	as
	begin
		return;
	end;
end;
/

prompt
prompt Done.

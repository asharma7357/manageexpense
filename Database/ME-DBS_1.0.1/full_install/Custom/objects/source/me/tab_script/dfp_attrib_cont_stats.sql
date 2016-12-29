prompt
prompt Creating table DFP_ATTRIB_CONT_STATS
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_ATTRIB_CONT_STATS purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_ATTRIB_CONT_STATS (
							COL_A		VARCHAR2(100 char),
							COL_B		VARCHAR2(100 char),
							COL_A_VAL	VARCHAR2(4000 char),
							COL_B_VAL	VARCHAR2(4000 char),
							STAT		NUMBER
						)
						tablespace #TBS_DFP_DATA
						pctfree 10
						initrans 1
						maxtrans 255
						nologging
						storage (
							initial 64K
							next 256K
							minextents 1
							maxextents unlimited
							pctincrease 0
						)';
end;
/


prompt
prompt Done.

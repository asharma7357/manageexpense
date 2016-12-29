prompt
prompt Creating table DFP_ENTROPY_HIST
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_ENTROPY_HIST purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_ENTROPY_HIST (
							COLUMN_NAME				VARCHAR2(30 BYTE),
							PRE_COMPUTED_ENTROPY	NUMBER(9,4),
							CALCULATED_ENTROPY		NUMBER(9,4),
							INSERT_DT				DATE,
							UPDATE_DT				DATE,
							HIST_INSERT_DT			DATE
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

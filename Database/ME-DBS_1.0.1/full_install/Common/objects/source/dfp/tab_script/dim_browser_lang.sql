prompt
prompt Creating table DIM_BROWSER_LANG
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DIM_BROWSER_LANG purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DIM_BROWSER_LANG (
							BROWSER_LANG_ID	NUMBER(10),
							BROWSER_LANG	VARCHAR2(50 CHAR),
							EFF_FROM_DT		DATE,
							EFF_TO_DT		DATE,
							UPDATE_DT		DATE
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
	
	execute immediate 'alter table DIM_BROWSER_LANG add constraint DIM_BROWSER_LANG_PK primary key (BROWSER_LANG_ID)
						using index
						tablespace #TBS_DFP_IDX
						pctfree 10
						initrans 2
						maxtrans 255
						storage
						(
							initial 64K
							next 256K
							minextents 1
							maxextents unlimited
							pctincrease 0
						)';
	
	execute immediate 'create index DIM_BROWSER_LANG_IDX1 on DIM_BROWSER_LANG(BROWSER_LANG)
						tablespace #TBS_DFP_IDX
						pctfree 10
						initrans 2
						maxtrans 255
						storage
						(
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

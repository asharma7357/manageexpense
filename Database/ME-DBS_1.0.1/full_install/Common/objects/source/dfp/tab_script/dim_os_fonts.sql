prompt
prompt Creating table DIM_OS_FONTS
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DIM_OS_FONTS purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DIM_OS_FONTS (
							OS_FONTS_ID		NUMBER(10),
							OS_FONTS		VARCHAR2(3000 CHAR),
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
	
	execute immediate 'alter table DIM_OS_FONTS add constraint DIM_OS_FONTS_PK primary key (OS_FONTS_ID)
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
	
	execute immediate 'create index DIM_OS_FONTS_IDX1 on DIM_OS_FONTS (OS_FONTS)
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

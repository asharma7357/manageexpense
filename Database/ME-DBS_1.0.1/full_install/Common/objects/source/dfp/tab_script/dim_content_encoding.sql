prompt
prompt Creating table DIM_CONTENT_ENCODING
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DIM_CONTENT_ENCODING purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DIM_CONTENT_ENCODING (
							CONTENT_ENCODING_ID	NUMBER(10),
							CONTENT_ENCODING	VARCHAR2(30 CHAR),
							EFF_FROM_DT			DATE,
							EFF_TO_DT			DATE,
							UPDATE_DT			DATE
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
	
	execute immediate 'alter table DIM_CONTENT_ENCODING add constraint DIM_CONTENT_ENCODING_PK primary key (CONTENT_ENCODING_ID)
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
	
	execute immediate 'create index DIM_CONTENT_ENCODING_IDX1 on DIM_CONTENT_ENCODING(CONTENT_ENCODING)
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

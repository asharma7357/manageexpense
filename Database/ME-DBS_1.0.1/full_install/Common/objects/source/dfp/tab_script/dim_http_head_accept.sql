prompt
prompt Creating table DIM_HTTP_HEAD_ACCEPT
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DIM_HTTP_HEAD_ACCEPT purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DIM_HTTP_HEAD_ACCEPT (
							HTTP_HEAD_ACCEPT_ID	NUMBER(10),
							HTTP_HEAD_ACCEPT	VARCHAR2(100 CHAR),
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
	
	execute immediate 'alter table DIM_HTTP_HEAD_ACCEPT add constraint DIM_HTTP_HEAD_ACCEPT_PK primary key (HTTP_HEAD_ACCEPT_ID)
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
	
	execute immediate 'create index DIM_HTTP_HEAD_ACCEPT_IDX1 on DIM_HTTP_HEAD_ACCEPT (HTTP_HEAD_ACCEPT)
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

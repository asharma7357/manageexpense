prompt
prompt Creating table DFP_MDI_MST
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_MDI_MST purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_MDI_MST (
							MASTER_DEVICE_ID	VARCHAR2(100 CHAR) NOT NULL,
							INSERT_DT			DATE DEFAULT SYSDATE NOT NULL
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
	
	execute immediate 'alter table DFP_MDI_MST add constraint DFP_MDI_MST_PK primary key (MASTER_DEVICE_ID)
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
	
	execute immediate 'comment on column DFP_MDI_MST.MASTER_DEVICE_ID is ''Master Device Id''';
	
end;
/


prompt
prompt Done.

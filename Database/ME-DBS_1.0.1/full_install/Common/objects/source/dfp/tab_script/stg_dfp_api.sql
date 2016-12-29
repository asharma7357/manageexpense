prompt
prompt Creating table STG_DFP_API
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table STG_DFP_API purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table STG_DFP_API (
							SESSION_ID			VARCHAR2(100 CHAR),
							MASTER_DEVICE_ID 	VARCHAR2(100 CHAR),
							SESSION_TS			TIMESTAMP,
							KEY 				VARCHAR2(100 CHAR),
							VALUE				VARCHAR2(4000 CHAR)
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
	
	execute immediate 'comment on column STG_DFP_API.SESSION_ID is ''UI Session Id.''';
	execute immediate 'comment on column STG_DFP_API.MASTER_DEVICE_ID is ''Master Device Id.''';
	execute immediate 'comment on column STG_DFP_API.SESSION_TS is ''Session Date and Time i.e. systimestamp.''';
	execute immediate 'comment on column STG_DFP_API.KEY is ''Name of the attribute for which the value will be provided.''';
	execute immediate 'comment on column STG_DFP_API.VALUE is ''Value of the Key attributed.''';
end;
/


prompt
prompt Done.

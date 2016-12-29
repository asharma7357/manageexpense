prompt
prompt Creating table DFP_BLACKLIST_MDI
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_BLACKLIST_MDI purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_BLACKLIST_MDI (
							MASTER_DEVICE_ID		VARCHAR2(100 CHAR) NOT NULL,
							COMMENTS				VARCHAR2(3000 CHAR) NOT NULL,
							REASON_CODE				VARCHAR2(100 CHAR) NOT NULL,
							REASON_CODE_COMMENTS	VARCHAR2(100 CHAR) NOT NULL,
							INSERT_DT				DATE NOT NULL
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
	
	execute immediate 'comment on column DFP_BLACKLIST_MDI.MASTER_DEVICE_ID is ''Master Device Id.''';
	execute immediate 'comment on column DFP_BLACKLIST_MDI.COMMENTS is ''Comments.''';
	execute immediate 'comment on column DFP_BLACKLIST_MDI.REASON_CODE is ''Reason Code.''';
	execute immediate 'comment on column DFP_BLACKLIST_MDI.INSERT_DT is ''Record Insert Date and Time.''';
end;
/


prompt
prompt Done.

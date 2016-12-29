prompt
prompt Creating table DFP_REQ_UI_LOG
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_REQ_UI_LOG purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_REQ_UI_LOG (
							REF_NUM						VARCHAR2(100 CHAR),
							SESSION_ID					VARCHAR2(100 CHAR),
							ATTRIB_NAME					VARCHAR2(200 CHAR),
							ATTRIB_EXTRACT_START_MS		NUMBER,
							ATTRIB_EXTRACT_END_MS		NUMBER,
							ATTRIB_EXTRACT_TOT_TIME		VARCHAR2(300) generated always as ((ATTRIB_EXTRACT_END_MS - ATTRIB_EXTRACT_START_MS)||'' MILLISECONDS.'')
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
	
	execute immediate 'comment on column DFP_REQ_UI_LOG.REF_NUM is ''TimeStamp( As unique Identifier).''';
	execute immediate 'comment on column DFP_REQ_UI_LOG.SESSION_ID is ''Generated by Java.''';
	execute immediate 'comment on column DFP_REQ_UI_LOG.ATTRIB_NAME is ''Number of atrrbutes passed.''';
	execute immediate 'comment on column DFP_REQ_UI_LOG.ATTRIB_EXTRACT_START_MS is ''Attribute Value Extract Start Milliseconds.''';
	execute immediate 'comment on column DFP_REQ_UI_LOG.ATTRIB_EXTRACT_END_MS is ''Attribute Value Extract Start Milliseconds.''';
	execute immediate 'comment on column DFP_REQ_UI_LOG.ATTRIB_EXTRACT_TOT_TIME is ''Total Milliseconds Time.''';
end;
/


prompt
prompt Done.

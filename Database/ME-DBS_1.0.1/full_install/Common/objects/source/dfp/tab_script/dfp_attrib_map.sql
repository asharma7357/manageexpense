prompt
prompt Creating table DFP_ATTRIB_MAP
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_ATTRIB_MAP purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_ATTRIB_MAP (
							COLUMN_ID			NUMBER NOT NULL,
							ATTRIB_ID			NUMBER NOT NULL,
							COLUMN_NAME			VARCHAR2(32 CHAR) NOT NULL,
							PAD_COLUMN_NAME		VARCHAR2(32 CHAR) NOT NULL,
							ATTRIB_NAME			VARCHAR2(100 CHAR) NOT NULL,
							ATTRIB_DISP_NAME	VARCHAR2(250 CHAR) NOT NULL,
							ATTRIB_DESC			VARCHAR2(4000 CHAR) NOT NULL,
							BROWSER_SUPP		VARCHAR2(100 CHAR) NOT NULL,
							ACTIVE_FLAG			NUMBER(1) NOT NULL,
							PASS_APP_FLAG		NUMBER(1) NOT NULL
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
	
	execute immediate 'alter table DFP_ATTRIB_MAP add constraint DFP_ATTRIB_MAP_PK primary key (ATTRIB_ID)
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
	
	execute immediate 'alter table DFP_ATTRIB_MAP add constraint DFP_ATTRIB_MAP_CHECK1 check (ACTIVE_FLAG in (0,1))';
	execute immediate 'alter table DFP_ATTRIB_MAP add constraint DFP_ATTRIB_MAP_CHECK2 check (PASS_APP_FLAG in (0,1))';
	
	
	execute immediate 'comment on column DFP_ATTRIB_MAP.ATTRIB_ID is ''Attribute Unique Id.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.COLUMN_ID is ''Attribute Sequence Id.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.COLUMN_NAME is ''Name of the column in Request.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.PAD_COLUMN_NAME is ''Name of the column in PAD.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.ATTRIB_NAME is ''Attribute name passed by UI.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.ATTRIB_DISP_NAME is ''Attribute display name.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.ATTRIB_DESC is ''Description of Attribute name.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.BROWSER_SUPP is ''List of browser support (| seperated) the attribute.''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.ACTIVE_FLAG is ''Attribute is used in DFP i.e. 0-No/1-Yes''';
	execute immediate 'comment on column DFP_ATTRIB_MAP.ACTIVE_FLAG is ''Attribute is applicable for Passes or not i.e. 0-No/1-Yes''';
end;
/


prompt
prompt Done.

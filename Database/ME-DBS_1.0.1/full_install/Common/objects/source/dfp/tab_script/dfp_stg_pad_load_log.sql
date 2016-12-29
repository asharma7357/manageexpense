prompt
prompt Creating table DFP_STG_PAD_LOAD_LOG
prompt ===================================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_STG_PAD_LOAD_LOG purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_STG_PAD_LOAD_LOG (
							MIN_UPDATE_DT		DATE,
							MAX_UPDATE_DT		DATE,
							START_TS			TIMESTAMP NOT NULL,
							END_TS				TIMESTAMP NOT NULL,
							TOT_TIME_TAKEN		VARCHAR2(300) generated always as (extract(hour from (END_TS-START_TS))||'' hours and ''||extract(minute from (END_TS-START_TS))||'' minute and ''||extract(second from (END_TS-START_TS))||'' seconds.''),
							PAD_LOAD_CNT		NUMBER NOT NULL,
							PAD_SUPP_LOAD_CNT	NUMBER NOT NULL,
							STATUS_CD			NUMBER(1) NOT NULL,
							STATUS_MSG			VARCHAR2(2000 CHAR)
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
	
	execute immediate 'alter table DFP_STG_PAD_LOAD_LOG add constraint DFP_STG_PAD_LOAD_LOG_CHECK1 check (STATUS_CD in (0,1))';
	
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.MIN_UPDATE_DT is ''Minimum Update date''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.MAX_UPDATE_DT is ''Maximum Update date''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.START_TS is ''Process Start Date and Time.''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.END_TS is ''Process End Date and Time.''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.TOT_TIME_TAKEN is ''Total Time Taken by the process to complete''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.PAD_LOAD_CNT is ''Records inserted in the PAD''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.PAD_SUPP_LOAD_CNT is ''Records inserted in the PAD Supp''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.STATUS_CD is ''Status Code of the process i.e. 0-Success/1-Error''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG.STATUS_MSG is ''Status message based on the status code.''';
end;
/


prompt
prompt Done.

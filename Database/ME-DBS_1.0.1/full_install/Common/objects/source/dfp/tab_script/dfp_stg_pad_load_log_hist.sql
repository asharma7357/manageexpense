prompt
prompt Creating table DFP_STG_PAD_LOAD_LOG_HIST
prompt ===================================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_STG_PAD_LOAD_LOG_HIST purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_STG_PAD_LOAD_LOG_HIST (
							MIN_UPDATE_DT		DATE,
							MAX_UPDATE_DT		DATE,
							START_TS			TIMESTAMP NOT NULL,
							END_TS				TIMESTAMP NOT NULL,
							TOT_TIME_TAKEN		VARCHAR2(300),
							PAD_LOAD_CNT		NUMBER NOT NULL,
							PAD_SUPP_LOAD_CNT	NUMBER NOT NULL,
							STATUS_CD			NUMBER(1) NOT NULL,
							STATUS_MSG			VARCHAR2(2000 CHAR),
							INSERT_TS			TIMESTAMP
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
	
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.MIN_UPDATE_DT is ''Minimum Update date''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.MAX_UPDATE_DT is ''Maximum Update date''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.START_TS is ''Process Start Date and Time.''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.END_TS is ''Process End Date and Time.''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.TOT_TIME_TAKEN is ''Total Time Taken by the process to complete''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.PAD_LOAD_CNT is ''Records inserted in the PAD''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.PAD_SUPP_LOAD_CNT is ''Records inserted in the PAD Supp''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.STATUS_CD is ''Status Code of the process i.e. 0-Success/1-Error''';
	execute immediate 'comment on column DFP_STG_PAD_LOAD_LOG_HIST.STATUS_MSG is ''Status message based on the status code.''';
end;
/


prompt
prompt Done.

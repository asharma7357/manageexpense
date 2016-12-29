prompt
prompt Creating table DFP_PQ_CONFIG
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_PQ_CONFIG purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_PQ_CONFIG (
						JB_THREAD_ID		NUMBER(5,0) NOT NULL,
						CF_PASS_NUMBER		NUMBER(5,0)	NOT NULL,
						CF_ATTRIB_ID		NUMBER(2,0)	NOT NULL,
						CF_MATCH_DEGREE		VARCHAR2(1 CHAR) NOT NULL,
						CF_SUB_PASS_NUMBER	NUMBER(5,0)
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
	
	execute immediate 'alter table DFP_PQ_CONFIG add constraint DFP_PQ_CONFIG_PK1 primary key (JB_THREAD_ID,CF_PASS_NUMBER,CF_ATTRIB_ID)
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
	execute immediate 'alter table DFP_PQ_CONFIG add constraint DFP_PQ_CONFIG_CHK1 check (CF_MATCH_DEGREE IN (''S'',''R''))';
	execute immediate 'alter table DFP_PQ_CONFIG add constraint DFP_PQ_CONFIG_FK FOREIGN KEY (CF_ATTRIB_ID) REFERENCES DFP_ATTRIB_MAP (ATTRIB_ID)';
	
	execute immediate 'comment on column DFP_PQ_CONFIG.JB_THREAD_ID is ''Job thread id.''';
	execute immediate 'comment on column DFP_PQ_CONFIG.CF_PASS_NUMBER is ''Multiple passes correspond to "or" in SQL. Each pass can have multiple rows which are "and" in sql.''';
	execute immediate 'comment on column DFP_PQ_CONFIG.CF_MATCH_DEGREE is ''S = Strict Match and R= Relaxed Match ''';
	execute immediate 'comment on column DFP_PQ_CONFIG.CF_SUB_PASS_NUMBER is ''If null then this group is common to all subpasses''';
end;
/


prompt
prompt Done.

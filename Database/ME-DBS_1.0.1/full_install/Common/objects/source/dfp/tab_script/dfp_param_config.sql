prompt
prompt Creating table DFP_PARAM_CONFIG
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_PARAM_CONFIG purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_PARAM_CONFIG (
							PARAM_NAME	VARCHAR2(100 CHAR),
							PARAM_TYPE	NUMBER(1)
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
	
	execute immediate 'comment on column DFP_PARAM_CONFIG.PARAM_NAME is ''Name of the field mentioned in dfp_idx_pad_t1.''';
	execute immediate 'comment on column DFP_PARAM_CONFIG.PARAM_TYPE is ''1-Volatile, 0-Non-volatile.''';
end;
/


prompt
prompt Done.

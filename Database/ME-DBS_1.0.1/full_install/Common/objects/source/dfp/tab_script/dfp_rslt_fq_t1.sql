prompt
prompt Creating table DFP_RSLT_FQ_T1
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_RSLT_FQ_T1 purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_RSLT_FQ_T1 (
							REQ_REF_NUM						VARCHAR2(100 CHAR),
							PAD_REF_NUM						VARCHAR2(100 CHAR),
							PAD_REC_TYPE					VARCHAR2(100 CHAR),
							PAD_REC_DT						DATE,
							TOT_SCORE						NUMBER(3),
							USER_AGENT_OS_ID_SCORE			NUMBER(3),
							USER_AGENT_BROWSER_ID_SCORE		NUMBER(3),
							USER_AGENT_ENGINE_ID_SCORE		NUMBER(3),
							USER_AGENT_DEVICE_ID_SCORE		NUMBER(3),
							CPU_ARCH_ID_SCORE				NUMBER(3),
							CANVAS_FP_SCORE					NUMBER(3),
							HTTP_HEAD_ACCEPT_ID_SCORE		NUMBER(3),
							CONTENT_ENCODING_ID_SCORE		NUMBER(3),
							CONTENT_LANG_ID_SCORE			NUMBER(3),
							IP_ADDRESS_SCORE				NUMBER(3),
							IP_ADDRESS_OCTET_SCORE			NUMBER(3),
							OS_FONTS_ID_SCORE				NUMBER(3),
							BROWSER_LANG_ID_SCORE			NUMBER(3),
							DISP_COLOR_DEPTH_SCORE			NUMBER(3),
							DISP_SCREEN_RES_RATIO_SCORE		NUMBER(3),
							TIMEZONE_SCORE					NUMBER(3),
							PLATFORM_ID_SCORE				NUMBER(3),
							PLUGINS_SCORE					NUMBER(3),
							USE_OF_LOCAL_STORAGE_SCORE		NUMBER(3),
							USE_OF_SESS_STORAGE_SCORE		NUMBER(3),
							INDEXED_DB_SCORE				NUMBER(3),
							DO_NOT_TRACK_SCORE				NUMBER(3),
							HAS_LIED_LANGS_SCORE			NUMBER(3),
							HAS_LIED_OS_SCORE				NUMBER(3),
							HAS_LIED_BROWSER_SCORE			NUMBER(3),
							WEBGL_VENDOR_RENDERER_ID_SCORE	NUMBER(3),
							COOKIES_ENABLED_SCORE			NUMBER(3),
							TOUCH_SUP_SCORE					NUMBER(3),
							CONNECTION_TYPE_SCORE			NUMBER(3),
							WEBRTC_FP_SCORE					NUMBER(3),
							AUD_CODECS_ID_SCORE				NUMBER(3),
							VID_CODECS_ID_SCORE				NUMBER(3)
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
	
	execute immediate 'comment on column DFP_RSLT_FQ_T1.REQ_REF_NUM is ''Request Reference Number.''';
	execute immediate 'comment on column DFP_RSLT_FQ_T1.PAD_REF_NUM is ''Pad Reference Number.''';
	execute immediate 'comment on column DFP_RSLT_FQ_T1.PAD_REC_TYPE is ''Pad Record Type.''';
	execute immediate 'comment on column DFP_RSLT_FQ_T1.PAD_REC_DT is ''PAD Record Date and time.''';
	execute immediate 'comment on column DFP_RSLT_FQ_T1.TOT_SCORE is ''Total Score.''';
exception
	when others then
		dbms_output.put_line(sqlerrm);
end;
/


prompt
prompt Done.

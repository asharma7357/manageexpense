prompt
prompt Creating table DFP_IDX_REQ_T1
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_IDX_REQ_T1 purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_IDX_REQ_T1 (
							MASTER_DEVICE_ID			VARCHAR2(100 CHAR),
							REF_NUM						VARCHAR2(100 CHAR),
							SESSION_ID					VARCHAR2(100 CHAR),
							REC_TYPE					VARCHAR2(100 CHAR),
							REC_DT						DATE,
							USER_AGENT_OS_ID			NUMBER(10),
							USER_AGENT_BROWSER_ID		NUMBER(10),
							USER_AGENT_ENGINE_ID		NUMBER(10),
							USER_AGENT_DEVICE_ID		NUMBER(10),
							CPU_ARCH_ID					NUMBER(10),
							CANVAS_FP					VARCHAR2(30 CHAR),
							HTTP_HEAD_ACCEPT_ID			NUMBER(10),
							CONTENT_ENCODING_ID			NUMBER(10),
							CONTENT_LANG_ID				NUMBER(10),
							IP_ADDRESS					VARCHAR2(20 CHAR),
							IP_ADDRESS_OCTET			VARCHAR2(20 CHAR),
							OS_FONTS_ID					NUMBER(10),
							BROWSER_LANG_ID				NUMBER(10),
							DISP_COLOR_DEPTH			VARCHAR2(20 CHAR),
							DISP_SCREEN_RES_RATIO		NUMBER,
							TIMEZONE					VARCHAR2(10 CHAR),
							PLATFORM_ID					NUMBER(10),
							PLUGINS						VARCHAR2(400 CHAR),
							USE_OF_LOCAL_STORAGE		NUMBER(1),
							USE_OF_SESS_STORAGE			NUMBER(1),
							INDEXED_DB					NUMBER(1),
							DO_NOT_TRACK				NUMBER(1),
							HAS_LIED_LANGS				NUMBER(1),
							HAS_LIED_OS					NUMBER(1),
							HAS_LIED_BROWSER			NUMBER(1),
							WEBGL_VENDOR_RENDERER_ID	NUMBER(10),
							COOKIES_ENABLED				VARCHAR2(10 CHAR),
							TOUCH_SUP					NUMBER(1),
							CONNECTION_TYPE				VARCHAR2(20 CHAR),
							WEBRTC_FP					VARCHAR2(20 CHAR),
							AUD_CODECS_ID				NUMBER(10),
							VID_CODECS_ID				NUMBER(10),
							UPDATE_DT					DATE
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
end;
/


prompt
prompt Done.

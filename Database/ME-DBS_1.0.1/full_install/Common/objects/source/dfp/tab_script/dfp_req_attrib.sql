prompt
prompt Creating table DFP_REQ_ATTRIB
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name		VARCHAR2(100);
begin
	begin
		execute immediate 'drop table DFP_REQ_ATTRIB purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table DFP_REQ_ATTRIB (
							MASTER_DEVICE_ID			VARCHAR2(100 CHAR),
							REF_NUM						VARCHAR2(100 CHAR),
							SESSION_ID					VARCHAR2(100 CHAR),
							REC_TYPE					VARCHAR2(100 CHAR),
							REC_DT						DATE,
							USER_AGENT_OS				VARCHAR2(1000 CHAR),
							USER_AGENT_BROWSER			VARCHAR2(1000 CHAR),
							USER_AGENT_ENGINE			VARCHAR2(1000 CHAR),
							USER_AGENT_DEVICE			VARCHAR2(1000 CHAR),
							CPU_ARCH					VARCHAR2(4000 CHAR),
							CANVAS_FP					VARCHAR2(4000 CHAR),
							HTTP_HEAD_ACCEPT			VARCHAR2(4000 CHAR),
							CONTENT_ENCODING			VARCHAR2(4000 CHAR),
							CONTENT_LANG				VARCHAR2(4000 CHAR),
							IP_ADDRESS					VARCHAR2(4000 CHAR),
							IP_ADDRESS_OCTET			VARCHAR2(4000 CHAR),
							OS_FONTS					VARCHAR2(4000 CHAR),
							BROWSER_LANG				VARCHAR2(4000 CHAR),
							DISP_COLOR_DEPTH			VARCHAR2(1000 CHAR),
							DISP_SCREEN_RES_RATIO		NUMBER,
							TIMEZONE					VARCHAR2(4000 CHAR),
							PLATFORM					VARCHAR2(4000 CHAR),
							PLUGINS						VARCHAR2(4000 CHAR),
							USE_OF_LOCAL_STORAGE		NUMBER(1),
							USE_OF_SESS_STORAGE			NUMBER(1),
							INDEXED_DB					NUMBER(1),
							DO_NOT_TRACK				NUMBER(1),
							HAS_LIED_LANGS				NUMBER(1),
							HAS_LIED_OS					NUMBER(1),
							HAS_LIED_BROWSER			NUMBER(1),
							WEBGL_VENDOR_RENDERER		VARCHAR2(4000 CHAR),
							COOKIES_ENABLED				VARCHAR2(4000 CHAR),
							TOUCH_SUP					NUMBER(1),
							CONNECTION_TYPE				VARCHAR2(4000 CHAR),
							WEBRTC_FP					VARCHAR2(4000 CHAR),
							AUD_CODECS					VARCHAR2(4000 CHAR),
							VID_CODECS					VARCHAR2(4000 CHAR)
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

prompt
prompt Creating table DFP_IDX_PAD_HIST
prompt ============================
prompt

declare
	lv_tbl exception;
	pragma exception_init(lv_tbl,-00942);
	lv_part_name	varchar2(100);
begin
	begin
		execute immediate 'drop table DFP_IDX_PAD_HIST purge';
	exception
		when lv_tbl then
			null;
	end;

	execute immediate 'create table dfp_idx_pad_hist (
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
							VID_CODECS_ID				NUMBER(10)
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
	
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK FOREIGN KEY (MASTER_DEVICE_ID) REFERENCES DFP_MDI_MST (MASTER_DEVICE_ID)';
	
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK1 FOREIGN KEY (USER_AGENT_OS_ID) REFERENCES DIM_USER_AGENT_OS (USER_AGENT_OS_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK2 FOREIGN KEY (USER_AGENT_BROWSER_ID) REFERENCES DIM_USER_AGENT_BROWSER (USER_AGENT_BROWSER_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK3 FOREIGN KEY (USER_AGENT_ENGINE_ID) REFERENCES DIM_USER_AGENT_ENGINE (USER_AGENT_ENGINE_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK4 FOREIGN KEY (USER_AGENT_DEVICE_ID) REFERENCES DIM_USER_AGENT_DEVICE (USER_AGENT_DEVICE_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK5 FOREIGN KEY (CPU_ARCH_ID) REFERENCES DIM_CPU_ARCH (CPU_ARCH_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK6 FOREIGN KEY (HTTP_HEAD_ACCEPT_ID) REFERENCES DIM_HTTP_HEAD_ACCEPT (HTTP_HEAD_ACCEPT_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK7 FOREIGN KEY (CONTENT_ENCODING_ID) REFERENCES DIM_CONTENT_ENCODING (CONTENT_ENCODING_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK8 FOREIGN KEY (CONTENT_LANG_ID) REFERENCES DIM_CONTENT_LANG (CONTENT_LANG_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK9 FOREIGN KEY (OS_FONTS_ID) REFERENCES DIM_OS_FONTS (OS_FONTS_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK10 FOREIGN KEY (BROWSER_LANG_ID) REFERENCES DIM_BROWSER_LANG (BROWSER_LANG_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK11 FOREIGN KEY (PLATFORM_ID) REFERENCES DIM_PLATFORM (PLATFORM_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK12 FOREIGN KEY (WEBGL_VENDOR_RENDERER_ID) REFERENCES DIM_WEBGL_VENDOR_RENDERER (WEBGL_VENDOR_RENDERER_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK13 FOREIGN KEY (AUD_CODECS_ID) REFERENCES DIM_AUD_CODECS (AUD_CODECS_ID)';
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_FK14 FOREIGN KEY (VID_CODECS_ID) REFERENCES DIM_VID_CODECS (VID_CODECS_ID)';
	
	execute immediate 'alter table DFP_IDX_PAD_HIST add constraint DFP_IDX_PAD_HIST_UK1 UNIQUE (SESSION_ID)';
	
	execute immediate 'comment on column DFP_IDX_PAD_HIST.MASTER_DEVICE_ID is ''Master Device Id''';
	execute immediate 'comment on column DFP_IDX_PAD_HIST.REF_NUM is ''Session_id +TimeStamp( As unique Identifier)''';
	execute immediate 'comment on column DFP_IDX_PAD_HIST.SESSION_ID is ''Generated by Java''';
	execute immediate 'comment on column DFP_IDX_PAD_HIST.REC_TYPE is ''Optional''';
	execute immediate 'comment on column DFP_IDX_PAD_HIST.REC_DT is ''sysdate''';
	
end;
/


prompt
prompt Done.

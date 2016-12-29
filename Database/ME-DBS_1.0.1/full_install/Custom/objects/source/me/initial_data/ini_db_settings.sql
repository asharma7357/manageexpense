prompt Loading DB_SETTINGS...

SET DEFINE OFF;

Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('PAD_SYNC_INTERVAL','N','0.0','DFP PAD SYNCHRONIZATION INTERVAL');

Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('PQ_MATCH_CNT_THLD','N','50.0','PQ Match Count Threshold');

Insert into db_settings (SETTING_NAME, DATA_TYPE, VALUE, DESCRIPTION) values ('MATCH_SCORE_THLD','N','40','Individual Score threshold for each dfp request source');

Insert into db_settings (SETTING_NAME, DATA_TYPE, VALUE, DESCRIPTION) values ('REQ_TIMEOUT_THLD','N','3000','Request timeout in Centiseconds');

insert into db_settings (SETTING_NAME, DATA_TYPE, VALUE, DESCRIPTION) values ('DFP_PAD_PURGE_START_TIME','N','00','DFP Pad Purging Start Time Hour');
insert into db_settings (SETTING_NAME, DATA_TYPE, VALUE, DESCRIPTION) values ('DFP_PAD_PURGE_END_TIME','N','23','DFP Pad Purging End Time Hour');

insert into db_settings (SETTING_NAME, DATA_TYPE, VALUE, DESCRIPTION) values ('DFP_HIST_PAD_RETENTION','N','6','No. of Months data to be purged from DFP Historical PAD.');

Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USER_AGENT_SCORE','N','0.0','Enable or disable Final Score computation for User Agent (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_BROWSER_NAME_SCORE','N','0.0','Enable or disable Final Score computation for Browser Name (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_OPERATING_SYS_SCORE','N','0.0','Enable or disable Final Score computation for Operating Sys (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_HTTP_HEAD_ACCEPT_SCORE','N','0.0','Enable or disable Final Score computation for Http Head Accept (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CONTENT_ENCODING_SCORE','N','0.0','Enable or disable Final Score computation for Content Encoding (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CONTENT_LANG_SCORE','N','0.0','Enable or disable Final Score computation for Content Lang (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_IP_ADDRESS_SCORE','N','0.0','Enable or disable Final Score computation for Ip Address (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_IP_ADDRESS_OCTET_SCORE','N','0.0','Enable or disable Final Score computation for Ip Address Octet (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_OS_FONTS_SCORE','N','0.0','Enable or disable Final Score computation for Os Fonts (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_BROWSER_LANG_SCORE','N','0.0','Enable or disable Final Score computation for Browser Lang (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_SCREEN_RES_SCORE','N','0.0','Enable or disable Final Score computation for Screen Res (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_TIMEZONE_SCORE','N','0.0','Enable or disable Final Score computation for Timezone (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_PLATFORM_SCORE','N','0.0','Enable or disable Final Score computation for Platform (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_PLUGINS_SCORE','N','0.0','Enable or disable Final Score computation for Plugins (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USE_OF_LOCAL_STORAGE_SCORE','N','0.0','Enable or disable Final Score computation for Use Of Local Storage (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USE_OF_SESS_STORAGE_SCORE','N','0.0','Enable or disable Final Score computation for Use Of Sess Storage (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DO_NOT_TRACK_SCORE','N','0.0','Enable or disable Final Score computation for Do Not Track (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_HAS_LIED_LANGS_SCORE','N','0.0','Enable or disable Final Score computation for Has Lied Langs (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_HAS_LIED_OS_SCORE','N','0.0','Enable or disable Final Score computation for Has Lied Os (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_HAS_LIED_BROWSER_SCORE','N','0.0','Enable or disable Final Score computation for Has Lied Browser (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_WEBGL_VENDOR_RENDERER_SCORE','N','0.0','Enable or disable Final Score computation for Webgl Vendor Renderer (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_COOKIES_ENABLED_SCORE','N','0.0','Enable or disable Final Score computation for Cookies Enabled (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USE_OF_ADBLOCK_SCORE','N','0.0','Enable or disable Final Score computation for Use Of Adblock (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_TOUCH_SUP_SCORE','N','0.0','Enable or disable Final Score computation for Touch Sup (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_KEYBOARD_LANG_SCORE','N','0.0','Enable or disable Final Score computation for Keyboard Lang (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CONNECTION_TYPE_SCORE','N','0.0','Enable or disable Final Score computation for Connection Type (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_PASS_PROTECTION_SCORE','N','0.0','Enable or disable Final Score computation for Pass Protection (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_MULTI_MONITOR_SCORE','N','0.0','Enable or disable Final Score computation for Multi Monitor (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_INTRNL_HASHTBL_IMPL_SCORE','N','0.0','Enable or disable Final Score computation for Intrnl Hashtbl Impl (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_WEBRTC_FP_SCORE','N','0.0','Enable or disable Final Score computation for Webrtc Fp (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_MATH_CONSTANTS_SCORE','N','0.0','Enable or disable Final Score computation for Math Constants (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_ACCESS_FP_SCORE','N','0.0','Enable or disable Final Score computation for Access Fp (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CAMERA_INFO_SCORE','N','0.0','Enable or disable Final Score computation for Camera Info (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DRM_SUP_SCORE','N','0.0','Enable or disable Final Score computation for Drm Sup (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_ACCEL_SUP_SCORE','N','0.0','Enable or disable Final Score computation for Accel Sup (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_VIRTUAL_KEYBOARDS_SCORE','N','0.0','Enable or disable Final Score computation for Virtual Keyboards (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_GESTURE_SUP_SCORE','N','0.0','Enable or disable Final Score computation for Gesture Sup (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_PIXEL_DENSITY_SCORE','N','0.0','Enable or disable Final Score computation for Pixel Density (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_AUD_CODECS_SCORE','N','0.0','Enable or disable Final Score computation for Aud Codecs (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_VID_CODECS_SCORE','N','0.0','Enable or disable Final Score computation for Vid Codecs (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_AUDIO_STACK_FP_SCORE','N','0.0','Enable or disable Final Score computation for Audio Stack Fp (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CLOCK_SKEW_SCORE','N','0.0','Enable or disable Final Score computation for Clock Skew (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_CLOCK_SPEED_SCORE','N','0.0','Enable or disable Final Score computation for Clock Speed (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_NETWORK_LATENCY_SCORE','N','0.0','Enable or disable Final Score computation for Network Latency (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_SLIVERLIGHT_VER_SCORE','N','0.0','Enable or disable Final Score computation for Sliverlight Ver (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USER_AGENT_OS_SCORE','N','0.0','Enable or disable Final Score computation for Os Useragent (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USER_AGENT_BROWSER_SCORE','N','0.0','Enable or disable Final Score computation for Browser Useragent (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USER_AGENT_ENGINE_SCORE','N','0.0','Enable or disable Final Score computation for Engine Useragent (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_USER_AGENT_DEVICE_SCORE','N','0.0','Enable or disable Final Score computation for Device Useragent (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_BROWSER_FONTS_SCORE','N','0.0','Enable or disable Final Score computation for Browser Fonts (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DISP_COLOR_DEPTH_SCORE','N','0.0','Enable or disable Final Score computation for Disp Color Depth (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DISP_SCREEN_RES_SCORE','N','0.0','Enable or disable Final Score computation for Disp Screen Res (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DISP_AVAIL_SCREEN_RES_SCORE','N','0.0','Enable or disable Final Score computation for Disp Avail Screen Res (0=false 1=true)');
Insert into DB_SETTINGS (SETTING_NAME,DATA_TYPE,VALUE,DESCRIPTION) values ('FQ_DISABLE_DISP_SCREEN_RES_RATIO_SCORE','N','0.0','Enable or disable Final Score computation for Disp Screen Res Ratio (0=false 1=true)');

commit;

prompt Done.

prompt
prompt Create Sequences
prompt ================
prompt

declare
	lv_max_id	number;
begin
	begin
		select max(user_agent_os_id)+1 into lv_max_id from dim_user_agent_os;
		execute immediate 'CREATE SEQUENCE seq_user_agent_os_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_user_agent_os_id : '||sqlerrm);
	end;

	begin
		select max(user_agent_browser_id)+1 into lv_max_id from dim_user_agent_browser;
		execute immediate 'CREATE SEQUENCE seq_user_agent_browser_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_user_agent_browser_id : '||sqlerrm);
	end;

	begin
		select max(user_agent_engine_id)+1 into lv_max_id from dim_user_agent_engine;
		execute immediate 'CREATE SEQUENCE seq_user_agent_engine_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_user_agent_engine_id : '||sqlerrm);
	end;

	begin
		select max(user_agent_device_id)+1 into lv_max_id from dim_user_agent_device;
		execute immediate 'CREATE SEQUENCE seq_user_agent_device_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_user_agent_device_id : '||sqlerrm);
	end;

	begin
		select max(cpu_arch_id)+1 into lv_max_id from dim_cpu_arch;
		execute immediate 'CREATE SEQUENCE seq_cpu_arch_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_cpu_arch_id : '||sqlerrm);
	end;

	begin
		select max(http_head_accept_id)+1 into lv_max_id from dim_http_head_accept;
		execute immediate 'CREATE SEQUENCE seq_http_head_accept_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_http_head_accept_id : '||sqlerrm);
	end;

	begin
		select max(content_encoding_id)+1 into lv_max_id from dim_content_encoding;
		execute immediate 'CREATE SEQUENCE seq_content_encoding_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_content_encoding_id : '||sqlerrm);
	end;

	begin
		select max(content_lang_id)+1 into lv_max_id from dim_content_lang;
		execute immediate 'CREATE SEQUENCE seq_content_lang_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_content_lang_id : '||sqlerrm);
	end;

	begin
		select max(os_fonts_id)+1 into lv_max_id from dim_os_fonts;
		execute immediate 'CREATE SEQUENCE seq_os_fonts_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_os_fonts_id : '||sqlerrm);
	end;

	begin
		select max(browser_lang_id)+1 into lv_max_id from dim_browser_lang;
		execute immediate 'CREATE SEQUENCE seq_browser_lang_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_browser_lang_id : '||sqlerrm);
	end;

	begin
		select max(platform_id)+1 into lv_max_id from dim_platform;
		execute immediate 'CREATE SEQUENCE seq_platform_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_platform_id : '||sqlerrm);
	end;

	begin
		select max(webgl_vendor_renderer_id)+1 into lv_max_id from dim_webgl_vendor_renderer;
		execute immediate 'CREATE SEQUENCE seq_webgl_vendor_renderer_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_webgl_vendor_renderer_id : '||sqlerrm);
	end;

	begin
		select max(aud_codecs_id)+1 into lv_max_id from dim_aud_codecs;
		execute immediate 'CREATE SEQUENCE seq_aud_codecs_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_aud_codecs_id : '||sqlerrm);
	end;

	begin
		select max(vid_codecs_id)+1 into lv_max_id from dim_vid_codecs;
		execute immediate 'CREATE SEQUENCE seq_vid_codecs_id MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH '||lv_max_id||' CACHE 100 NOORDER  NOCYCLE';
	exception
		when others then
			dbms_output.put_line('seq_vid_codecs_id : '||sqlerrm);
	end;
end;
/

prompt Done.

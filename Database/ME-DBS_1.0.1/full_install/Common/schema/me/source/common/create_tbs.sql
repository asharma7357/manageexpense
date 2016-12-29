---------------------------------------
-- Tablespace for common object 
---------------------------------------
prompt
prompt Creating tablespaces 
prompt ================================
prompt

set serveroutput on

declare

	lv_sql 				varchar2(1000);
	lv_tbs_size 		varchar2(50);
	lv_max_tbs_size		number(3)		:= 30; -- max threshold size
	lv_db_file_cnt		number(10);
	lv_big_tblspace		varchar2(1) 	:= 'Y';
	i 					number(10)  	:= 1;
	lv_db_file_size		number(10);
	lv_cal_db_file_sz	number(10);
	
	
	type tr_tb_spaces is record(
								tbs_name  varchar2(200),
								tbs_size  varchar2(200),	
								data_file varchar2(200)
								);
	type ta_tb_spaces is table of tr_tb_spaces index by pls_integer;
	la_tb_spaces ta_tb_spaces;
	

begin
		--Description:
		-- 1) To create the big tablespace if the flag value is Y and tablespace size is more than 30 GB.
		-- 2) if the tablespace size is in KB and MB then create a single data file in a tablespace.
		-- 3) if the tablsespace size if more than 30 GB then create multiple data files in a tablespace of max size 30.
		
		la_tb_spaces(1).tbs_name := '#TBS_COMMON_DAT_NAME';
		la_tb_spaces(1).tbs_size := '#TBS_COMMON_DAT_SIZE';
		la_tb_spaces(1).data_file := '#TBS_DAT_BASE/#TBS_COMMON_DAT_NAME';
		
		
		la_tb_spaces(2).tbs_name := '#TBS_COMMON_IDX_NAME';
		la_tb_spaces(2).tbs_size := '#TBS_COMMON_IDX_SIZE';
		la_tb_spaces(2).data_file := '#TBS_IDX_BASE/#TBS_COMMON_IDX_NAME';
		
		for k in 1..la_tb_spaces.count
		loop
			
			--Creating tablespace #TBS_COMMON_IDX_NAME
			dbms_output.put_line('Creating tablespace ' || la_tb_spaces(k).tbs_name);
			
			begin
				lv_tbs_size := 	la_tb_spaces(k).tbs_size;
				if (lv_big_tblspace = upper('#IS_BIG_TBL_SPACE') and upper(substr(lv_tbs_size,-1,1)) = 'G' and to_number(substr(lv_tbs_size,1,length(lv_tbs_size)-1)) > lv_max_tbs_size )
				  or upper(substr(lv_tbs_size,-1,1)) in ('M', 'K')
				then

					if upper(substr(lv_tbs_size,-1,1)) in ('M', 'K') then
						lv_sql := ' CREATE TABLESPACE ' || la_tb_spaces(k).tbs_name;
					else
						lv_sql := ' CREATE BIGFILE TABLESPACE ' || la_tb_spaces(k).tbs_name;
					end if;	
					lv_sql := lv_sql || ' DATAFILE ''' || la_tb_spaces(k).data_file || '.dbf'' SIZE ' || la_tb_spaces(k).tbs_size;
					lv_sql := lv_sql || ' EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M';
					lv_sql := lv_sql || ' SEGMENT SPACE MANAGEMENT AUTO';
					execute immediate lv_sql;
				else

					lv_db_file_size := to_number(substr(lv_tbs_size,1,length(lv_tbs_size)-1));
					lv_db_file_cnt  := ceil(lv_db_file_size/lv_max_tbs_size);

					i := 1;
					while i <=  lv_db_file_cnt and lv_db_file_size > 0
					loop				

						if lv_db_file_size > lv_max_tbs_size then
							lv_cal_db_file_sz := lv_max_tbs_size;
						else
							lv_cal_db_file_sz := lv_db_file_size;
						end if;

						if i = 1 then
							lv_sql := 'CREATE  TABLESPACE ' || la_tb_spaces(k).tbs_name;
							lv_sql := lv_sql || ' DATAFILE ''' || la_tb_spaces(k).data_file || '0' || i || '.dbf'' SIZE ' || lv_cal_db_file_sz || 'g ';
							lv_sql := lv_sql || ' EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M';
							lv_sql := lv_sql || ' SEGMENT SPACE MANAGEMENT AUTO';				
						else
							lv_sql := 'ALTER  TABLESPACE ' || la_tb_spaces(k).tbs_name;
							lv_sql := lv_sql || ' ADD DATAFILE ''' || la_tb_spaces(k).data_file || '0' || i || '.dbf'' SIZE ' || lv_cal_db_file_sz || 'g ';
						end if;
						execute immediate lv_sql;

						lv_db_file_size := lv_db_file_size - lv_max_tbs_size;
						i := i + 1;
					end loop;
				end if;
			exception
				when others then
					dbms_output.put_line('Error to create tablespace ' || la_tb_spaces(k).tbs_name || ': ' || sqlerrm);
					null;
			end;		
	end loop;
end;
/
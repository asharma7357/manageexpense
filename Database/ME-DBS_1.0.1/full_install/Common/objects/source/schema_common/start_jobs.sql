prompt
prompt Create Data Purger job
prompt ========================
prompt

declare
  i integer;
begin
  sys.dbms_job.submit(job => i,
                      what => 'pkg_data_purger.run_data_purger(1);',
                      next_date => sysdate+1440,
                      interval => 'sysdate + (4/24)');
  commit;
end;
/


prompt
prompt Create Partition Manager job
prompt ========================
prompt

declare
	i integer;
begin
  sys.dbms_job.submit(job => i,
                      what => 'pkg_part_mgr.run_part_mgr;',
                      next_date => sysdate +1440,
                      interval => 'sysdate + (2/1440)');
  commit;
end;
/

set serveroutput off

prompt
prompt done.

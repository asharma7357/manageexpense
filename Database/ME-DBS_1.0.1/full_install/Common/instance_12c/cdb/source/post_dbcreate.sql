connect SYS/#SYS_PASSWORD as SYSDBA
set echo on
spool #SOURCE_PATH/instance_12c/cdb/log/post_dbcreate.log
shutdown immediate;
connect SYS/#SYS_PASSWORD as SYSDBA
startup mount pfile='#SOURCE_PATH/instance_12c/cdb/install/init.ora';
alter database open;
connect SYS/#SYS_PASSWORD as SYSDBA
set echo on
create spfile='#INSTALL_BASE/data001/#DB_CONTAINER_NAME/spfile#DB_CONTAINER_NAME.ora' FROM pfile='#SOURCE_PATH/instance_12c/cdb/install/init.ora';
create spfile='#ORACLE_HOME/dbs/spfile#DB_CONTAINER_NAME.ora' FROM pfile='#SOURCE_PATH/instance_12c/cdb/install/init.ora';
create pfile='#ORACLE_HOME/dbs/init.ora' from spfile;
shutdown immediate;
connect SYS/#SYS_PASSWORD as SYSDBA
startup 
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
spool off
exit
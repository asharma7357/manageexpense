connect SYS/#SYS_PASSWORD as SYSDBA
set echo on
spool #SOURCE_PATH/instance/log/xdb_protocol.log
@#ORACLE_HOME/rdbms/admin/catqm.sql #SYS_PASSWORD SYSAUX TEMP NO;
@#ORACLE_HOME/rdbms/admin/utlmail.sql
@#ORACLE_HOME/rdbms/admin/prvtmail.plb
connect SYS/#SYS_PASSWORD as SYSDBA
spool off
exit

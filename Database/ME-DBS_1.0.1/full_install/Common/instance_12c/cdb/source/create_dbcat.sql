connect SYS/#SYS_PASSWORD as SYSDBA
set echo on
spool #SOURCE_PATH/instance_12c/cdb/log/create_dbcat.log
@#ORACLE_HOME/rdbms/admin/catalog.sql;
@#ORACLE_HOME/rdbms/admin/catblock.sql;
@#ORACLE_HOME/rdbms/admin/catproc.sql;
@#ORACLE_HOME/rdbms/admin/catoctk.sql;
@#ORACLE_HOME/rdbms/admin/owminst.plb;
connect SYSTEM/#SYS_PASSWORD
@#ORACLE_HOME/sqlplus/admin/pupbld.sql;
connect SYSTEM/#SYS_PASSWORD
set echo on
spool #SOURCE_PATH/instance_12c/cdb/log/sqlPlusHelp.log
@#ORACLE_HOME/sqlplus/admin/help/hlpbld.sql helpus.sql;
connect SYS/#SYS_PASSWORD as SYSDBA
@#ORACLE_HOME/rdbms/admin/catcdb.sql; 
spool off
exit;

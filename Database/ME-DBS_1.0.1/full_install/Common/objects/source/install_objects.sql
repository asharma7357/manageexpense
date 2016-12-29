--TODO
--1. Grants to user APP_USER not factored
--2. Add new blade script not created

-- NOTES:
-- 1.install_common.sql script is used to install common objects (Common/objects/source/schema_common) which
-- 	 includes create_objects.sql, initial_data.sql and start_jobs.sql scripts.
-- 2.NAM schema is not part of this implementation

spool #SOURCE_PATH/objects/log/common_objects#NETMIND_VER.log

set serveroutput on;
clear screen;
clear buffer;

prompt Installing the database objects
prompt DFP database version: #NETMIND_VER
prompt Please Wait.....

#DFP_COMMENT_ST------DFP Comment Starts or Just the RPT installation
prompt Removing existing installation of DFP schema objects (stage 1)

---DFP START
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Common/drop_objects.sql
---DFP END
#DFP_COMMENT_ED

#DFP_COMMENT_ST
---DFP START
prompt Starting installation of DFP schema objects (stage 2)
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Common/dfp/create_dbl.sql
@#SOURCE_PATH/objects/install/Common/install_common.sql
@#SOURCE_PATH/objects/install/Common/set_install_start.sql
@#SOURCE_PATH/objects/install/Common/dfp/grants.sql
---DFP END
#DFP_COMMENT_ED


#DFP_COMMENT_ST
---DFP START
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Common/dfp/preq.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_dir.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_type.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_tbl.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_queue.sql
---DFP END
#DFP_COMMENT_ED

#DFP_COMMENT_ST
connect #DFP_SYS_USERNAME/#DFP_SYS_USER_PWD@#DFP_CONNECT_STRING as sysdba;
@#SOURCE_PATH/objects/install/Common/dfp/grant_queue.sql

prompt Creating queues in DFP Schema (stage 3)
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Common/dfp/create_queue_subs.sql

prompt Continue with the installation of DFP schema objects (stage 4)
@#SOURCE_PATH/objects/install/Common/dfp/create_fnc.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_prc.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_syn.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_viw.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_pkg.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_trg.sql
@#SOURCE_PATH/objects/install/Common/dfp/initial_data.sql
@#SOURCE_PATH/objects/install/Common/dfp/create_seq.sql
@#SOURCE_PATH/objects/install/Common/dfp/start_jobs.sql
@#SOURCE_PATH/objects/install/Common/set_install_end.sql

#DFP_COMMENT_ED------DFP Comment End

prompt DFP Common database objects installed sucessfully...

spool off

-
/* Custom Object Creation */

--TODO
--1. Grants to user APP_USER not factored
--2. Add new blade script not created

------- Add custom Installation comment Start ------------
spool #SOURCE_PATH/objects/log/custom_objects#NETMIND_VER.log


set serveroutput on;
clear screen;
clear buffer;

prompt Customizing the database objects for the client

#DFP_COMMENT_ST

prompt DFP database version: #NETMIND_VER
prompt Please Wait.....
prompt Starting installation of DFP schema objects (stage 5)
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Custom/install_common.sql

prompt Starting installation of DFP schema objects (stage 6)
@#SOURCE_PATH/objects/install/Custom/dfp/preq.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_dir.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_seq.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_type.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_tbl.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_fnc.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_prc.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_dbl.sql

#DFP_COMMENT_ED

#NMPOS_COMMENT_ST
prompt Provide grants to POS object to DFP (stage 7)
connect #POS_SCHEMA_USERNAME/#POS_SCHEMA_USER_PWD@#POS_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Custom/pos/grants.sql
#NMPOS_COMMENT_ED


#DFP_COMMENT_ST
prompt Continue installation of DFP schema objects (stage 8)
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Custom/dfp/create_syn.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_viw.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_pkg.sql
@#SOURCE_PATH/objects/install/Custom/dfp/create_trg.sql
@#SOURCE_PATH/objects/install/Custom/dfp/initial_data.sql
@#SOURCE_PATH/objects/install/Custom/dfp/start_jobs.sql
#DFP_COMMENT_ED

connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;

#DFP_COMMENT_ST
prompt Compiling DFP Schema invalid objects
connect #DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING;
@#SOURCE_PATH/objects/install/Custom/recompile.sql
#DFP_COMMENT_ED

prompt DFP Custom database objects installed sucessfully...

spool off

exit;

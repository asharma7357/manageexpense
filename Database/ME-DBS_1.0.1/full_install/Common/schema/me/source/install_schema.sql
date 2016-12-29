-------------------------------------------------------------------
-- Note: This is a shared file across multiple schemas
-- No dependency on a specific schema should be introduced here
-------------------------------------------------------------------

spool #SOURCE_PATH/schema/#SCHEMA_KEY/log/#SCHEMA_KEY_schema.log

clear screen;
clear buffer;

prompt Creating the #SCHEMA_KEY schema......
prompt Please Wait.....

----------------------------------
-- schema creation script
----------------------------------
connect #INSTALL_USERNAME/#INSTALL_USER_PWD@#CONNECT_STRING as sysdba;

#TBS_COMMENT@#SOURCE_PATH/schema/#SCHEMA_KEY/install/create_tbs.sql
--Install common schema tablespace
#TBS_COMMENT@#SOURCE_PATH/schema/#SCHEMA_KEY/install/common/create_tbs.sql

@#SOURCE_PATH/schema/#SCHEMA_KEY/install/create_usr.sql

prompt #SCHEMA_KEY schema created sucessfully..

spool off

exit;

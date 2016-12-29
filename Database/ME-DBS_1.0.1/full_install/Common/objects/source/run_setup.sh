echo `cd #ORACLE_HOME/bin`
sqlplus "#DFP_SCHEMA_USERNAME/#DFP_SCHEMA_USER_PWD@#DFP_CONNECT_STRING" @#SOURCE_PATH/objects/install/Common/install_objects.sql

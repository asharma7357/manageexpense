echo `cd #ORACLE_HOME/bin`

if  [ "N" == "#ASM_FILESYSTEM" ] || [ "n" == "#ASM_FILESYSTEM" ];
then
	mkdir -p #TBS_DAT_BASE
	mkdir -p #TBS_IDX_BASE
	sqlplus "#INSTALL_USERNAME/#INSTALL_USER_PWD@#CONNECT_STRING as sysdba" @#SOURCE_PATH/schema/#SCHEMA_KEY/install/install_schema.sql
fi

if  [ "Y" == "#ASM_FILESYSTEM" ] || [ "y" == "#ASM_FILESYSTEM" ];
then
	sqlplus "#INSTALL_USERNAME/#INSTALL_USER_PWD@#CONNECT_STRING as sysdba" @#SOURCE_PATH/schema/#SCHEMA_KEY/install/install_asm_schema.sql
fi
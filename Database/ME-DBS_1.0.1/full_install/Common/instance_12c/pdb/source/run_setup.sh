if [ ! -d #INSTALL_BASE/data001/nmpdb01 ];		
then
	mkdir -p #INSTALL_BASE/data001/#PDB_DATABASE_NAME
fi 
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/pdb/install/create_pdb.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/pdb/install/xdb_protocol.sql

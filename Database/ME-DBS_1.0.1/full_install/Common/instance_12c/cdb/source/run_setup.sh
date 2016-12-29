#!/bin/sh
if [ #EMBEDDED_DATABASE == yes ];then
	chmod 777 -R #SOURCE_PATH
	if [ ! -d #SOURCE_PATH/instance_12c/cdb/log ];then		
		mkdir -p #SOURCE_PATH/instance_12c/cdb/log
	fi

	if [ -e #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log ];then
		rm #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
	fi
	echo "############################################################" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
	echo "#                	DB Log                             #" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
	echo "############################################################" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
	chmod 777 #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log

	if [ -e /etc/oratab ];then
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo "oracle alredy installed" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo "Insctance installation is continued ..........................."
		export ORACLE_HOME=#ORACLE_HOME
	else
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		echo "Installing Oracle please wait .................................."
		if [ -e #SOURCE_PATH/../../oradb/runInstaller ];then
			echo "Oracle dump file already extrected" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
		else
			if [ -e #SOURCE_PATH/../../oradb/oradb.zip ];then
				cd #SOURCE_PATH/../../oradb/
				#unzip #SOURCE_PATH/../../oradb/oradb.zip
				unzip oradb.zip
				cd #SOURCE_PATH/instance_12c/cdb
				chmod -R 777 #SOURCE_PATH/../../oradb/
			else
				echo "Oracle dump file not found " >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
				echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
				echo #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
				echo "DB installation is terminated" >> #SOURCE_PATH/instance_12c/cdb/log/dbinstall.log
				exit
			fi
		fi

		echo "Please enter the root user password"
		su - root -c "#SOURCE_PATH/instance_12c/cdb/install/db_pre.sh"
		find #SOURCE_PATH/instance_12c/cdb/log -name dbinstall.log | xargs grep "DB installation is terminated"
		if [ $? -eq 0 ];then
			exit
		fi
		
		export PATH=/usr/sbin:$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin/:$PATH
		export ORACLE_UNQNAME=#DB_CONTAINER_NAME
		export ORACLE_BASE=#ORACLE_BASE
		export ORACLE_HOME=#ORACLE_HOME
		export ORACLE_SID=#DB_CONTAINER_NAME
		export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
		export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;
		echo 'export PATH=/usr/sbin:$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin/:$PATH' >> ~/.bash_profile
		echo "export ORACLE_UNQNAME=#DB_CONTAINER_NAME" >> ~/.bash_profile
		echo 'export ORACLE_BASE=#ORACLE_BASE' >> ~/.bash_profile 
		echo 'export ORACLE_HOME=#ORACLE_HOME' >> ~/.bash_profile  
		echo 'export ORACLE_SID=#DB_CONTAINER_NAME' >> ~/.bash_profile
		echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;' >> ~/.bash_profile
		echo 'export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;' >> ~/.bash_profile
		source ~/.bash_profile
	fi
fi
source ~/.bash_profile


if [ ! -d #DIAGNOSTIC_DEST ];		
then
	mkdir -p #DIAGNOSTIC_DEST
fi 

if [ ! -d #DIAGNOSTIC_DEST/alert ];		
then
	mkdir -p #DIAGNOSTIC_DEST/alert
fi 

if [ ! -d #DIAGNOSTIC_DEST/incident ];		
then
	mkdir -p #DIAGNOSTIC_DEST/incident
fi 

if [ ! -d #DIAGNOSTIC_DEST/incpkg ];		
then
	mkdir -p #DIAGNOSTIC_DEST/incpkg
fi 

if [ ! -d #DIAGNOSTIC_DEST/trace ];		
then
	mkdir -p #DIAGNOSTIC_DEST/trace
fi 

if [ ! -d #DIAGNOSTIC_DEST/dpdump ];		
then
	mkdir -p #DIAGNOSTIC_DEST/dpdump
fi 

if [ ! -d #DIAGNOSTIC_DEST/diag ];		
then
	mkdir -p #DIAGNOSTIC_DEST/diag
fi

if [ ! -d #INSTALL_BASE/data001 ];		
then
	mkdir -p #INSTALL_BASE/data001/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/data002 ];		
then
	mkdir -p #INSTALL_BASE/data002/#DB_CONTAINER_NAME
fi

if [ ! -d #INSTALL_BASE/data003 ];		
then
	mkdir -p #INSTALL_BASE/data003/#DB_CONTAINER_NAME
fi


if [ ! -d #INSTALL_BASE/data001/#DB_CONTAINER_SEED_NAME ];		
then
	mkdir -p #INSTALL_BASE/data001/#DB_CONTAINER_SEED_NAME
fi 

if [ ! -d #INSTALL_BASE/data002/#DB_CONTAINER_SEED_NAME ];		
then
	mkdir -p #INSTALL_BASE/data002/#DB_CONTAINER_SEED_NAME
fi

if [ ! -d #INSTALL_BASE/data003/#DB_CONTAINER_SEED_NAME ];		
then
	mkdir -p #INSTALL_BASE/data003/#DB_CONTAINER_NAME/#DB_CONTAINER_SEED_NAME

fi

if [ ! -d #INSTALL_BASE/dbfra001 ];		
then
	mkdir -p #INSTALL_BASE/dbfra001/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/arch001 ];		
then
	mkdir -p #INSTALL_BASE/arch001/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/redo001 ];		
then
	mkdir -p #INSTALL_BASE/redo001/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/redo002 ];		
then
	mkdir -p #INSTALL_BASE/redo002/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/redo003 ];		
then
	mkdir -p #INSTALL_BASE/redo003/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/temp001 ];		
then
	mkdir -p #INSTALL_BASE/temp001/#DB_CONTAINER_NAME
fi 

if [ ! -d #INSTALL_BASE/dbmaint001 ];		
then
	mkdir -p #INSTALL_BASE/dbmaint001/#DB_CONTAINER_NAME
fi 

export ORACLE_SID=#DB_CONTAINER_NAME

echo Add this entry in the oratab: #DB_CONTAINER_NAME:#ORACLE_HOME:Y
#echo "#DB_CONTAINER_NAME:#ORACLE_HOME:Y" >> /etc/oratab
#ORACLE_HOME/bin/orapwd file=#INSTALL_BASE/data001/#DB_CONTAINER_NAME/orapw#DB_CONTAINER_NAME password=#SYS_PASSWORD force=y
cp #INSTALL_BASE/data001/#DB_CONTAINER_NAME/orapw#DB_CONTAINER_NAME #ORACLE_HOME/dbs/
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/cdb/install/create_db.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/cdb/install/create_dbfiles.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/cdb/install/create_dbcat.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/cdb/install/xdb_protocol.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance_12c/cdb/install/post_dbcreate.sql

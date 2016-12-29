#!/bin/sh
if [ #EMBEDDED_DATABASE == yes ];then
	chmod 777 -R #SOURCE_PATH
	if [ ! -d #SOURCE_PATH/instance/log ];then		
		mkdir -p #SOURCE_PATH/instance/log
	fi

	if [ -e #SOURCE_PATH/instance/log/dbinstall.log ];then
		rm #SOURCE_PATH/instance/log/dbinstall.log
	fi
	echo "############################################################" >> #SOURCE_PATH/instance/log/dbinstall.log
	echo "#                	DB Log                             #" >> #SOURCE_PATH/instance/log/dbinstall.log
	echo "############################################################" >> #SOURCE_PATH/instance/log/dbinstall.log
	chmod 777 #SOURCE_PATH/instance/log/dbinstall.log

	if [ -e /etc/oratab ];then
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo "oracle alredy installed" >> #SOURCE_PATH/instance/log/dbinstall.log
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo "Insctance installation is continued ..........................."
		export ORACLE_HOME=#ORACLE_HOME
	else
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo #SOURCE_PATH/instance/log/dbinstall.log
		echo "Installing Oracle please wait .................................."
		if [ -e #SOURCE_PATH/../../oradb/runInstaller ];then
			echo "Oracle dump file already extrected" >> #SOURCE_PATH/instance/log/dbinstall.log
		else
			if [ -e #SOURCE_PATH/../../oradb/oradb.zip ];then
				cd #SOURCE_PATH/../../oradb/
				#unzip #SOURCE_PATH/../../oradb/oradb.zip
				unzip oradb.zip
				cd #SOURCE_PATH/instance
				chmod -R 777 #SOURCE_PATH/../../oradb/
			else
				echo "Oracle dump file not found " >> #SOURCE_PATH/instance/log/dbinstall.log
				echo #SOURCE_PATH/instance/log/dbinstall.log
				echo #SOURCE_PATH/instance/log/dbinstall.log
				echo "DB installation is terminated" >> #SOURCE_PATH/instance/log/dbinstall.log
				exit
			fi
		fi

		echo "Please enter the root user password"
		su - root -c "#SOURCE_PATH/instance/install/db_pre.sh"
		find #SOURCE_PATH/instance/log -name dbinstall.log | xargs grep "DB installation is terminated"
		if [ $? -eq 0 ];then
			exit
		fi
		export ORACLE_HOME=#ORACLE_BASE/oracle/product/10.2.0/db_1
		export PATH=$PATH:$ORACLE_HOME/bin
		export LD_LIBRARY_PATH=$ORACLE_HOME/lib
		echo "export ORACLE_HOME=#ORACLE_BASE/oracle/product/10.2.0/db_1" >> ~/.bash_profile
		echo 'export PATH=$PATH:$ORACLE_HOME/bin' >> ~/.bash_profile 
		source ~/.bash_profile
	fi
fi
source ~/.bash_profile

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/adump ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/adump
fi

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/bdump ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/bdump
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/cdump ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/cdump
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/dpdump ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/dpdump
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/pfile ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/pfile
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/udump ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/udump
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/flash_recovery_area ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/flash_recovery_area
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/agilis ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/agilis
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/dbs ];	
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/dbs
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/data ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/data
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/index ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/index
fi 

if [ ! -d #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/arch ];		
then
	mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME/dbs/arch
fi 

#if [ ! -d #ORACLE_HOME/dbs ];		
#then
#	mkdir #ORACLE_HOME/dbs
#fi 

export ORACLE_SID=#DB_INSTANCE_NAME

echo Add this entry in the oratab: #DB_INSTANCE_NAME:#ORACLE_HOME:Y
#echo "#DB_INSTANCE_NAME:#ORACLE_HOME:Y" >> /etc/oratab
#ORACLE_HOME/bin/orapwd file=#ORACLE_HOME/dbs/orapw#DB_INSTANCE_NAME password=#SYS_PASSWORD force=y

#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance/install/create_db.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance/install/create_dbfiles.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance/install/create_dbcat.sql
#ORACLE_HOME/bin/sqlplus /nolog @#SOURCE_PATH/instance/install/post_dbcreate.sql

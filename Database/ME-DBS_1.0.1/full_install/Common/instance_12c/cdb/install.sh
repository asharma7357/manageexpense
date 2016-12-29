## ***********************************************************************************
## install.sh
## 
## Pass two paramerters
## 
## First parameter is source path where the common directory is located. This parameter will have the same value as allocated
## to SOURCE_PATH tag in custom directory (For example- /home/oracle/Src).
## It is also the start of the path where subdirectories to be searched are located.
##
## Second parameter is the only name of the specific configuration file present in custom directoty 
## which provides the required database details that needs to be installed (For example-mpe_instance.cfg)
##
##
## ***********************************************************************************
##

if [ $# -ne 2 ];
then
	echo +
	echo "1. First parameter should be source path (Like: /home/oracle/Src)."
	echo "2. Second parameter should the name of configuration file (like: mpe_instance.cfg)"
	echo +
else
	mkdir -p $1/instance_12c/cdb
	mkdir -p $1/instance_12c/cdb/log
	mkdir -p $1/instance_12c/cdb/install
	rm -rf $1/instance_12c/cdb/install/*

	DB_VER=`grep "s/#ORACLE_VERSION" $1/Custom/instance_12c/cdb/$2 | cut -d/ -f3 | cut -d. -f1`
	  cp $1/Common/instance_12c/cdb/source/init12.ora $1/Common/instance_12c/cdb/source/init.ora
	  cp $1/Common/instance_12c/cdb/source/run_setup12.sh $1/Common/instance_12c/cdb/source/run_setup.sh
	
	cp -R $1/Common/instance_12c/cdb/source/* $1/instance_12c/cdb/install
	dos2unix  replace_tags.sh 
	source replace_tags.sh $1/instance_12c/cdb/install/ $1/Custom/instance_12c/cdb/$2 
	dos2unix  $1/instance_12c/cdb/install/run_setup.sh 
	source $1/instance_12c/cdb/install/run_setup.sh
	mv $1/Common/instance_12c/cdb/*.log  $1/instance_12c/cdb/log
	mv $1/Common/instance_12c/cdb/*.lst  $1/instance_12c/cdb/log

fi
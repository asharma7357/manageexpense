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
	mkdir $1/instance_12c/pdb
	mkdir $1/instance_12c/pdb/log
	mkdir $1/instance_12c/pdb/install
	rm -rf $1/instance_12c/pdb/install/*

	DB_VER=`grep "s/#ORACLE_VERSION" $1/Custom/instance_12c/pdb/$2 | cut -d/ -f3 | cut -d. -f1`
	cp -R $1/Common/instance_12c/pdb/source/* $1/instance_12c/pdb/install
	dos2unix  replace_tags.sh 
	source replace_tags.sh $1/instance_12c/pdb/install/ $1/Custom/instance_12c/pdb/$2 
	dos2unix  $1/instance_12c/pdb/install/run_setup.sh 
	source $1/instance_12c/pdb/install/run_setup.sh
fi
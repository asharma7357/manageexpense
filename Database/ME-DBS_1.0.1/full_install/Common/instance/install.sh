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
	echo "1. First parameter should the name of configuration file (like: mpe_instance.cfg)"
	echo +
else
	mkdir $1/instance
	mkdir $1/instance/log
	mkdir $1/instance/install
	rm -rf $1/instance/install/*

	DB_VER=`grep "s/#ORACLE_VERSION" $1/Custom/instance/$2 | cut -d/ -f3 | cut -d. -f1`
	if [ $DB_VER -gt 10 ];
	then
	  cp $1/Common/instance/source/init11.ora $1/Common/instance/source/init.ora
	  cp $1/Common/instance/source/run_setup11.sh $1/Common/instance/source/run_setup.sh
	else
	  cp $1/Common/instance/source/init10.ora $1/Common/instance/source/init.ora
	  cp $1/Common/instance/source/run_setup10.sh $1/Common/instance/source/run_setup.sh
	fi
	cp -R $1/Common/instance/source/* $1/instance/install
	dos2unix  replace_tags.sh 
	source replace_tags.sh $1/instance/install/ $1/Custom/instance/$2 
	dos2unix  $1/instance/install/run_setup.sh 
	source $1/instance/install/run_setup.sh
fi

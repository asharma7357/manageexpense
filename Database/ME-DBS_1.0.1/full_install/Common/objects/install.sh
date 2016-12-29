## ***********************************************************************************
## install.sh
## 
## Pass two paramerters
## 
## First parameter is source path where the common directory is located. It is also the start of the path 
## where subdirectories to be searched are located (For example- /home/oracle/Src).
## 
##
## Second parameter is the only name of the specific configuration file present in custom directoty 
## which provides the required objects details that needs to be installed (For example-objects.cfg)
##
##
## ***********************************************************************************
##

if [ $# -ne 2 ]; 
then
	echo +
	echo "1. First parameter should be source path where the Common and Custom directory is located (Like: /home/oracle/Src)."
	echo "2. Second parameter should the name of configuration file (like: objects.cfg)"
	echo +
else
	mkdir $1/objects
	mkdir $1/objects/install
	mkdir $1/objects/install/Common
	mkdir $1/objects/install/Custom
	mkdir $1/objects/log
	
	rm -rf $1/objects/install/Common/*
	rm -rf $1/objects/install/Custom/*

	cp -R $1/Common/objects/source/* $1/objects/install/Common
	cp -R $1/Custom/objects/source/* $1/objects/install/Custom

	dos2unix replace_tags.sh
	
	source replace_tags.sh $1/objects/install/Common $1/Custom/objects/$2
	source replace_tags.sh $1/objects/install/Custom $1/Custom/objects/$2
	
	dos2unix $1/objects/install/Common/run_setup.sh
	source $1/objects/install/Common/run_setup.sh
fi

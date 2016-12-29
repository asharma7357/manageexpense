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
## which provides the required schema details that needs to be installed (For example-schema.cfg)
##
##
## ***********************************************************************************
##

if [ $# -ne 2 ]; 
then
	echo +
	echo "1. First parameter should be source path (Like: /home/oracle/Src)."
	echo "2. Second parameter should the name of configuration file (like: schema.cfg)"
	echo +
else

	mkdir $1/schema
	mkdir $1/schema/me
	mkdir $1/schema/me/log
	mkdir $1/schema/me/install
	rm -rf $1/schema/me/install/*

	cp -R $1/Common/schema/me/source/* $1/schema/me/install

	dos2unix replace_tags.sh
	source replace_tags.sh $1/schema/me/install/ $1/Custom/schema/me/$2
	dos2unix $1/schema/me/install/run_setup.sh
	source $1/schema/me/install/run_setup.sh
fi

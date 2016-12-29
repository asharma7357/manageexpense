#p1=`pwd`
echo "############################################################" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#                                                          #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#                 Database installation Log                #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#                                                          #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "############################################################" >>#SOURCE_PATH/instance/log/dbinstall.log

ORACLE_BASE=#ORACLE_BASE
ORACLE_SID=db_1
if [ -e #SOURCE_PATH/../../oradb/runInstaller ];then
	cd #SOURCE_PATH/../../oradb/
	if [ -e #SOURCE_PATH/instance/install/dbresponce.rsp ];then
	DISPLAY=192.168.4.189:10.0
	export DISPLAY
	#SOURCE_PATH/../../oradb/runInstaller -silent -noconfig -responseFile "#SOURCE_PATH/instance/install/dbresponce.rsp" >>#SOURCE_PATH/instance/log/dbinstall.log
	
	while : 
	do
	i=`expr $i \+ 1`
	find #SOURCE_PATH/instance/log -name dbinstall.log | xargs grep "Failed"
	if [ $? -eq 0 ];then
		
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
		exit
	else
		find #SOURCE_PATH/instance/log -name dbinstall.log | xargs grep "Setup successful"
		if [ $? -eq 0 ];then
			#echo pass
			break
		fi
		find #SOURCE_PATH/instance/log -name dbinstall.log | xargs grep "SEVERE:OUI-"
		if [ $? -eq 0 ];then
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
			exit
		fi
		if [ "$i" -le "1800" ];then
			echo Installing DB ..............
		else
			echo Oracle is not installed please check the log file
			echo "Oracle installation is terminated please check out above errors" >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
			exit
		fi

	fi
	
sleep 2
done

	#chmod 777 -R #ORACLE_BASE/oracle/product/10.2.0/db_1/bin
	#chmod 777 -R #ORACLE_BASE/oracle/product/10.2.0/
	echo "permission granted to opt directory" >>#SOURCE_PATH/instance/log/dbinstall.log
	echo "export ORACLE_HOME=#ORACLE_BASE/oracle/product/10.2.0/db_1" >>/home/oracle/.bash_profile
	echo 'export PATH=$PATH:$ORACLE_HOME/bin' >>/home/oracle/.bash_profile
	cd ~
	. ./.bash_profile
	else
	echo >>#SOURCE_PATH/instance/log/dbinstall.log 
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo "Response file not found" >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
	exit
	fi
else
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo "oracle dump zip file not found" >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
	exit
fi





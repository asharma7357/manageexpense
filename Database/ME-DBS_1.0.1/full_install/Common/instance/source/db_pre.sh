#!/bin/sh
#p1=`pwd`

echo "############################################################" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#                                                          #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#      Database Pre installation verification Log          #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "#                                                          #" >>#SOURCE_PATH/instance/log/dbinstall.log
echo "############################################################" >>#SOURCE_PATH/instance/log/dbinstall.log



	vbit=`getconf LONG_BIT`
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	echo >>#SOURCE_PATH/instance/log/dbinstall.log
	#echo "It is $vbit server"

	if [ $vbit == 32 ];then
		rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' binutils compat-db \
		compat-libstdc++-296 \
		control-center \
		gcc \
		gcc-c++ \
		glibc \
		glibc-common \
		gnome-libs \
		libstdc++ \
		libstdc++-devel \
		make \
		pdksh \
		sysstat \
		xscreensaver  \
		glibc-devel \
		libaio- \
		setarch > #SOURCE_PATH/instance/log/rpmver.log
		
	else
		rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' binutils compat-db \
		control-center \
		gcc \
		gcc-c++ \
		glibc \
		glibc-common \
		gnome-libs \
		libstdc++ \
		libstdc++-devel \
		make \
		pdksh \
		sysstat \
		xscreensaver \
		libaio \
		libaio-devel \
		make > #SOURCE_PATH/instance/log/rpmver.log 
	
	fi

	find #SOURCE_PATH/instance/log -name rpmver.log | xargs grep "is not installed" >>#SOURCE_PATH/instance/log/dbinstall.log
	
	if [ $? -eq 0 ];then
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo "required rpm not installed please check above log " >>#SOURCE_PATH/instance/log/dbinstall.log
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo >>#SOURCE_PATH/instance/log/dbinstall.log
		echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
		exit 
	else
		# RAM info.
		#vram=`grep MemTotal /proc/meminfo | cut -f1,4 -dk`
		#vram1=`echo cut $vram | cut -b15,16,17,18,19,20,21,22,23,24`
 		#vramb=`expr $vram1 \* 1024`
		#vramd=`expr $vramb \/ 2`

				vram=`grep MemTotal /proc/meminfo | cut -f1,4 -dk`
		vram1=`echo cut $vram | cut -b15,16,17,18,19,20,21,22,23,24`
		vramb=`echo "scale=2;$vram1/ 1048576" | bc`
		vramb1=`expr $vram1 \* 1024`
		#echo $vramb
		vramr=`echo "($vramb + 0.99)/1" | bc`
		vramr1=`echo "$vramr* 1073741824" | bc`
		vramd=`echo "$vramr1/ 2" | bc`
		
		
		# Swap space info.
		vsw=`grep SwapTotal /proc/meminfo | cut -f1,4 -dk`
		vsw1=`echo cut $vsw | cut -b16,17,18,19,20,21,22,23,24,25`
		vswb=`expr $vsw1 \* 1024`
		
		
		if [ "$vramb1" -le "4294967296" ];then
			sw1=`echo "$vramr1* 2" | bc`
			#echo swap space $sw1 first
		elif [ "$vramb1" -le "8589934592" ];then
			sw1=`echo "$vramr1* 1.5" | bc`
			#echo swap space $sw1 second
		else
			sw1=$vramr1
			#echo swap space $sw1 thired
		fi
		
			#echo sw1=$sw1
			#echo vswb=$vswb
		if [ "$vswb" -lt "$sw1" ];then
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "WARNING ?...........swap space is low" >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "Expected swap space $sw1 bytes" >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "Current swap space $vswb bytes" >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo >>#SOURCE_PATH/instance/log/dbinstall.log
			echo "DB installation is terminated" >>#SOURCE_PATH/instance/log/dbinstall.log
			exit
		else
			find /etc -name group | xargs grep "oinstall"
			if [ $? -eq 0 ];then
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo "oinsatll group already exist" >>#SOURCE_PATH/instance/log/dbinstall.log
			else
				/usr/sbin/groupadd oinstall
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo "oinstall group is created" >>#SOURCE_PATH/instance/log/dbinstall.log
			fi
		
			find /etc -name group | xargs grep "dba"
			if [ $? -eq 0 ];then
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				echo "dba group already exist" >>#SOURCE_PATH/instance/log/dbinstall.log
			else
				/usr/sbin/groupadd dba
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				echo "dba group is created" >>#SOURCE_PATH/instance/log/dbinstall.log
			fi

			find /etc -name group | xargs grep "oper"
			if [ $? -eq 0 ];then
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 				
				echo "oper group already exist" >>#SOURCE_PATH/instance/log/dbinstall.log
			else
				/usr/sbin/groupadd oper
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				echo "oper group is created" >>#SOURCE_PATH/instance/log/dbinstall.log
			fi

			find /etc -name passwd | xargs grep "oracle"
			if [ $? -eq 0 ];then
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				echo "oracle user already exist" >>#SOURCE_PATH/instance/log/dbinstall.log
				/usr/sbin/usermod -g oinstall -G dba,oper oracle
			else
				
				/usr/sbin/useradd -g oinstall -G dba,oper oracle
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 				
				echo "oracle user is created" >>#SOURCE_PATH/instance/log/dbinstall.log
			fi
			
			echo ora123 | passwd --stdin oracle
			
			#echo 536870912 >  /proc/sys/kernel/shmmax
			echo $vramd >  /proc/sys/kernel/shmmax
			echo 250 32000 100 128 > /proc/sys/kernel/sem
			ulimit -n 65536
			echo 1024 65000 > /proc/sys/net/ipv4/ip_local_port_range
			ulimit -u 16384
			echo 262144 > /proc/sys/net/core/rmem_default
			echo 262144 > /proc/sys/net/core/rmem_max
			echo 262144 > /proc/sys/net/core/wmem_default
			echo 262144 > /proc/sys/net/core/wmem_max

			echo "kernel.shmall = 2097152" >>/etc/sysctl.conf
			echo "kernel.shmmax = $vramd" >>/etc/sysctl.conf    
			echo "kernel.shmmni = 4096" >>/etc/sysctl.conf
			echo "kernel.sem = 250 32000 100 128" >>/etc/sysctl.conf
			echo "net.ipv4.ip_local_port_range = 1024 65000" >>/etc/sysctl.conf
			echo "net.core.rmem_default = 262144" >>/etc/sysctl.conf
			echo "net.core.rmem_max = 262144" >>/etc/sysctl.conf	
			echo "net.core.wmem_default = 262144" >>/etc/sysctl.conf
			echo "net.core.wmem_max = 262144" >>/etc/sysctl.conf


			echo "oracle              soft    nproc   2047" >> /etc/security/limits.conf
			echo "oracle              hard    nproc   16384" >> /etc/security/limits.conf
			echo "oracle              soft    nofile  1024" >> /etc/security/limits.conf
			echo "oracle              hard    nofile  65536" >> /etc/security/limits.conf

			echo "session    required     /lib/security/pam_limits.so" >> /etc/pam.d/login
			echo "session    required     pam_limits.so" >> /etc/pam.d/login

			echo 'if [ $USER = "oracle" ]; then' >> /etc/profile
        		echo 'if [ $SHELL = "/bin/ksh" ]; then'>> /etc/profile
              	echo "ulimit -p 16384" >> /etc/profile
	              echo "ulimit -n 65536" >> /etc/profile
       	 	echo "else" >> /etc/profile
             		echo "ulimit -u 16384 -n 65536" >> /etc/profile
	        	echo "fi" >> /etc/profile
			echo "fi" >> /etc/profile

			echo "umask 022" >> /home/oracle/.bash_profile
		
			mkdir -p /opt/oracle
			chown -R oracle:oinstall /opt
			chmod -R 777 /opt
			
			mkdir -p #INSTALL_BASE/#DB_INSTANCE_NAME
			chown -R oracle:oinstall  #INSTALL_BASE/#DB_INSTANCE_NAME
			chmod -R 777  #INSTALL_BASE/#DB_INSTANCE_NAME
			
			
			if [ -e #ORACLE_BASE/oracle/flash_recovery_area ];then
				echo >>#SOURCE_PATH/instance/log/dbinstall.log
				echo "Flash_recovery_area already created" >>#SOURCE_PATH/instance/log/dbinstall.log 
			else
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				echo >>#SOURCE_PATH/instance/log/dbinstall.log 
				
				mkdir -p #ORACLE_BASE/oracle/flash_recovery_area
				chown -R oracle:oinstall  #ORACLE_BASE/oracle/flash_recovery_area
				chmod -R 777 #ORACLE_BASE/oracle/flash_recovery_area
				echo "Flash recovery area is created" >>#SOURCE_PATH/instance/log/dbinstall.log
			fi
		fi
   	 fi  
	chown -R oracle:oinstall #ORACLE_BASE
	chmod -R 777 /home/#OS_USER_NAME
	su - oracle -c "#SOURCE_PATH/instance/install/ora_inst.sh"
 
	find #SOURCE_PATH/instance/log -name dbinstall.log | xargs grep "Setup successful"
	if [ $? -eq 0 ];then
		/usr/sbin/usermod -g oinstall -G dba,oper #OS_USER_NAME
		/home/oracle/oraInventory/orainstRoot.sh >>#SOURCE_PATH/instance/log/dbinstall.log
		echo "#ORACLE_BASE/oracle/product/10.2.0/db_1/bin" | #ORACLE_BASE/oracle/product/10.2.0/db_1/root.sh >>#SOURCE_PATH/instance/log/dbinstall.log
		#echo 'export ORACLE_HOME=#ORACLE_BASE/oracle/product/10.2.0/db_1' >>/home/#OS_USER_NAME/.bash_profile
		#echo 'export PATH=$PATH:$ORACLE_HOME/bin' >>/home/#OS_USER_NAME/.bash_profile
		chmod 777 -R #ORACLE_BASE/oracle 
		
	fi



if [ -e #SOURCE_PATH/instance/log/rpmver.log ];then
	rm #SOURCE_PATH/instance/log/rpmver.log
fi
    





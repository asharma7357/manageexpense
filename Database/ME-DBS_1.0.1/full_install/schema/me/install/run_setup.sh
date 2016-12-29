echo `cd /u01/app/oracle/product/12.1.0.2/db_1/bin`

if  [ "N" == "N" ] || [ "n" == "N" ];
then
	mkdir -p /u01/app/oracle/product/12.1.0.2/db_1/dbs
	mkdir -p /u01/app/oracle/product/12.1.0.2/db_1/dbs
	sqlplus "sys/Abhishek1276@pdb12c as sysdba" @/home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/install/install_schema.sql
fi

if  [ "Y" == "N" ] || [ "y" == "N" ];
then
	sqlplus "sys/Abhishek1276@pdb12c as sysdba" @/home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/install/install_asm_schema.sql
fi
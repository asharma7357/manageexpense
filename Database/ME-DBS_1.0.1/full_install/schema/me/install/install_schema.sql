-------------------------------------------------------------------
-- Note: This is a shared file across multiple schemas
-- No dependency on a specific schema should be introduced here
-------------------------------------------------------------------

spool /home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/log/me_schema.log

clear screen;
clear buffer;

prompt Creating the me schema......
prompt Please Wait.....

----------------------------------
-- schema creation script
----------------------------------
connect sys/Abhishek1276@pdb12c as sysdba;

 @/home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/install/create_tbs.sql
--Install common schema tablespace
 @/home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/install/common/create_tbs.sql

@/home/oracle/GitHub/manageexpense/Database/ME-DBS_1.0.1/full_install/schema/me/install/create_usr.sql

prompt me schema created sucessfully..

spool off

exit;

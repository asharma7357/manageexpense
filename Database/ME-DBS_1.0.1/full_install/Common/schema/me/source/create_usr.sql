-- ************************************************
--
-- CREATE DATABASE USERS
--
-- ************************************************

prompt
prompt Creating USER #APP_USERNAME
prompt ========================
prompt
CREATE USER #APP_USERNAME
    IDENTIFIED BY #APP_USER_PWD 
    DEFAULT TABLESPACE #TBS_COMMON_DAT_NAME
    TEMPORARY TABLESPACE temp;

-- Grant/Revoke role privileges 
grant resource to #APP_USERNAME;
grant connect to #APP_USERNAME;

prompt
prompt Creating USER #SCHEMA_USERNAME
prompt ========================
prompt
CREATE USER #SCHEMA_USERNAME
    IDENTIFIED BY #SCHEMA_USER_PWD
    DEFAULT TABLESPACE #TBS_COMMON_DAT_NAME
    TEMPORARY TABLESPACE temp;

alter user #SCHEMA_USERNAME quota unlimited on #TBS_COMMON_DAT_NAME;
alter user #SCHEMA_USERNAME quota unlimited on #TBS_COMMON_IDX_NAME;
alter user #SCHEMA_USERNAME quota unlimited on #TBS_DFP_DAT_NAME;
alter user #SCHEMA_USERNAME quota unlimited on #TBS_DFP_IDX_NAME;

-- Grant/Revoke role privileges 
grant create database link to #SCHEMA_USERNAME;
grant create operator to #SCHEMA_USERNAME;
grant create procedure to #SCHEMA_USERNAME;
grant create profile to #SCHEMA_USERNAME;
grant create public database link to #SCHEMA_USERNAME;
grant create public synonym to #SCHEMA_USERNAME;
grant create type to #SCHEMA_USERNAME;
grant create session to #SCHEMA_USERNAME;
grant create sequence to #SCHEMA_USERNAME;
grant create synonym to #SCHEMA_USERNAME;
grant create table to #SCHEMA_USERNAME;
grant create trigger to #SCHEMA_USERNAME;
grant create view to #SCHEMA_USERNAME;
grant create any view to #SCHEMA_USERNAME;
grant create any directory to #SCHEMA_USERNAME;
grant debug connect session to #SCHEMA_USERNAME;

grant select any dictionary to #SCHEMA_USERNAME;
-- grant select any table to #SCHEMA_USERNAME;

grant query rewrite to #SCHEMA_USERNAME;

grant execute any procedure  to #SCHEMA_USERNAME;
grant execute any type to #SCHEMA_USERNAME;
grant execute on dbms_lock to #SCHEMA_USERNAME;

grant alter session to #SCHEMA_USERNAME;
grant alter session to #SCHEMA_USERNAME;

grant unlimited tablespace to #SCHEMA_USERNAME;

grant drop public database link to #SCHEMA_USERNAME;
-- grant drop any table to #SCHEMA_USERNAME;
grant drop public synonym to #SCHEMA_USERNAME;

-- grant delete any table to #SCHEMA_USERNAME;
grant all on dbms_crypto to #SCHEMA_USERNAME;

--grant specific to queuing
grant aq_administrator_role to #SCHEMA_USERNAME identified by #SCHEMA_USER_PWD;
grant execute on dbms_aq to #SCHEMA_USERNAME;
grant execute on dbms_aqadm to #SCHEMA_USERNAME;

grant SCHEDULER_ADMIN TO #SCHEMA_USERNAME;
grant all on DBMS_ISCHED to #SCHEMA_USERNAME;
grant all on DBMS_SCHEDULER to #SCHEMA_USERNAME;


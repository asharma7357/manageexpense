-- ************************************************
--
-- CREATE DATABASE USERS
--
-- ************************************************

prompt
prompt Creating USER me_user
prompt ========================
prompt
CREATE USER me_user
    IDENTIFIED BY me_user 
    DEFAULT TABLESPACE me_common_data
    TEMPORARY TABLESPACE temp;

-- Grant/Revoke role privileges 
grant resource to me_user;
grant connect to me_user;

prompt
prompt Creating USER me_schema
prompt ========================
prompt
CREATE USER me_schema
    IDENTIFIED BY me_schema
    DEFAULT TABLESPACE me_common_data
    TEMPORARY TABLESPACE temp;

alter user me_schema quota unlimited on me_common_data;
alter user me_schema quota unlimited on me_common_index;
alter user me_schema quota unlimited on me_data;
alter user me_schema quota unlimited on me_index;

-- Grant/Revoke role privileges 
grant create database link to me_schema;
grant create operator to me_schema;
grant create procedure to me_schema;
grant create profile to me_schema;
grant create public database link to me_schema;
grant create public synonym to me_schema;
grant create type to me_schema;
grant create session to me_schema;
grant create sequence to me_schema;
grant create synonym to me_schema;
grant create table to me_schema;
grant create trigger to me_schema;
grant create view to me_schema;
grant create any view to me_schema;
grant create any directory to me_schema;
grant debug connect session to me_schema;

grant select any dictionary to me_schema;
-- grant select any table to me_schema;

grant query rewrite to me_schema;

grant execute any procedure  to me_schema;
grant execute any type to me_schema;
grant execute on dbms_lock to me_schema;

grant alter session to me_schema;
grant alter session to me_schema;

grant unlimited tablespace to me_schema;

grant drop public database link to me_schema;
-- grant drop any table to me_schema;
grant drop public synonym to me_schema;

-- grant delete any table to me_schema;
grant all on dbms_crypto to me_schema;

--grant specific to queuing
grant aq_administrator_role to me_schema identified by me_schema;
grant execute on dbms_aq to me_schema;
grant execute on dbms_aqadm to me_schema;

grant SCHEDULER_ADMIN TO me_schema;
grant all on DBMS_ISCHED to me_schema;
grant all on DBMS_SCHEDULER to me_schema;


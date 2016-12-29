prompt
prompt Creating table PG_PURGER_CONFIG
prompt ===============================
prompt
create table PG_PURGER_CONFIG
(
  CF_TABLE_GROUP   NUMBER(10) not null,
  CF_TABLE_ID      NUMBER(10) not null,
  CF_TABLE_NAME    VARCHAR2(200) not null,
  CF_PRG_CLAUSE    VARCHAR2(2000) not null,
  CF_PRG_BKP_TABLE VARCHAR2(30),
  CF_PRG_FREQ      VARCHAR2(1) not null,
  CF_PRG_INTVL     NUMBER(5) not null,
  CF_PRG_LAST_RUN  DATE not null,
  CF_PRG_NEXT_RUN  DATE not null,
  CF_PRG_BKP_FILE  VARCHAR2(1)
)
tablespace #TBS_COMMON_DAT_NAME
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 1M
    next 1M
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Add comments to the table 
comment on table PG_PURGER_CONFIG
  is 'this table stores the configuration information related to the purger process';
-- Add comments to the columns 
comment on column PG_PURGER_CONFIG.CF_TABLE_GROUP
  is 'It contains unique id for a purge task. Each task comprising of multiple tables';
comment on column PG_PURGER_CONFIG.CF_TABLE_ID
  is 'This column is the id of a table within a group of tables that are part of table group';
comment on column PG_PURGER_CONFIG.CF_TABLE_NAME
  is 'The name of the table from which the data is going to be purged ';
comment on column PG_PURGER_CONFIG.CF_PRG_CLAUSE
  is 'Where clause of the query specifying the row set that needs to be purged.';
comment on column PG_PURGER_CONFIG.CF_PRG_BKP_TABLE
  is 'The name of the table where the purged data is stored as backup. If this field is not                                                  null then the data needs to be moved from the main table to the table name specified in this field and                                                           then deleted from the main table else the data is directly deleted from the main table without backing it up. ';
comment on column PG_PURGER_CONFIG.CF_PRG_FREQ
  is ' Valid values are H-Hourly,D-Daily,M=Monthly,W=Weekly. This field specifies the frequency based upon which the purger process is going to delete the records fro respective tables.';
comment on column PG_PURGER_CONFIG.CF_PRG_INTVL
  is 'Enter the interval here. For example if frequency=H and interval=5, then purger will run every 5 hours. The last run is the start date for this computation.';
comment on column PG_PURGER_CONFIG.CF_PRG_LAST_RUN
  is 'Specifies the last run date of purger process
';
comment on column PG_PURGER_CONFIG.CF_PRG_NEXT_RUN
  is 'Specifies the next run date of purer process';
comment on column PG_PURGER_CONFIG.CF_PRG_BKP_FILE
  is 'Value values can be Y or N. This indicates whether backup is taken in file or not';
-- Create/Recreate check constraints 
alter table PG_PURGER_CONFIG
  add constraint CF_PRG_FREQ_CHK
  check (CF_PRG_FREQ in ('H','D','M','W'));

prompt
prompt Creating table PG_PURGER_LOG
prompt ============================
prompt
create table PG_PURGER_LOG
(
  LG_TABLE_ID        NUMBER(10),
  LG_TABLE_GROUP     NUMBER(10),
  LG_TABLE_NAME      VARCHAR2(200),
  LG_PRG_RUN_DATE    DATE,
  LG_BCK_TIME        NUMBER(10),
  LG_BCK_RECORDS_CNT NUMBER(20),
  LG_PRG_TIME        NUMBER(10),
  LG_PRG_RECORDS_CNT NUMBER(20),
  LG_PRG_ERROR       VARCHAR2(3000)
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
-- Add comments to the columns 
comment on column PG_PURGER_LOG.LG_TABLE_ID
  is 'It contains unique id corresponding to a purger process';
comment on column PG_PURGER_LOG.LG_TABLE_GROUP
  is 'It contains group id corresponding to which the table belongs';
comment on column PG_PURGER_LOG.LG_TABLE_NAME
  is 'It contains the name of the table being purged';
comment on column PG_PURGER_LOG.LG_PRG_RUN_DATE
  is 'The date on which the purger process was run';
comment on column PG_PURGER_LOG.LG_BCK_TIME
  is 'Time taken to run the backup SQL (in centi seconds)';
comment on column PG_PURGER_LOG.LG_BCK_RECORDS_CNT
  is '# of records moved to backup';
comment on column PG_PURGER_LOG.LG_PRG_TIME
  is 'Time taken to run the purge SQL (in centi seconds)';
comment on column PG_PURGER_LOG.LG_PRG_RECORDS_CNT
  is '# of records purged';
comment on column PG_PURGER_LOG.LG_PRG_ERROR
  is 'If any error occured while the table rows were being deleted';

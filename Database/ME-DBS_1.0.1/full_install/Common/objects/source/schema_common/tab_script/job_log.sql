prompt
prompt Creating table JOB_LOG
prompt ======================
prompt

-- Create table
create table JOB_LOG
(
  JB_NUMBER     NUMBER(5),
  JB_THREAD_ID  NUMBER(5) default 0,
  JL_RUN_NUMBER NUMBER(5) default 0,
  JL_MODULE     VARCHAR2(64) not null,
  JL_LOG_DT     DATE,
  JL_MSG        VARCHAR2(2000) not null,
  JL_MSG_COUNT  NUMBER(5) default 0,
  JL_SEVERITY   NUMBER(1) default 0,
  JL_TYPE       NUMBER(1) default 0,
  JL_USER_MSG       VARCHAR2(200),
  JL_USER_MSG_COUNT VARCHAR2(200) 
)
tablespace #TBS_COMMON_DAT_NAME
  pctfree 10
  pctused 40
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
comment on column JOB_LOG.JB_NUMBER
  is 'Job Number - Referenced from JOB table, if 0 then it is for foreground errors(not scheduled jobs)';
comment on column JOB_LOG.JB_THREAD_ID
  is 'Job Thread ID, multiple threads for one job - Referenced from JOB table';
comment on column JOB_LOG.JL_RUN_NUMBER
  is 'Job Run number - Number of times a particular job executed';
comment on column JOB_LOG.JL_MODULE
  is 'Module Name';
comment on column JOB_LOG.JL_LOG_DT
  is 'Log Date';
comment on column JOB_LOG.JL_MSG
  is 'Message description';
comment on column JOB_LOG.JL_MSG_COUNT
  is '# of times this exact error was fired on same run #';
comment on column JOB_LOG.JL_SEVERITY
  is 'Severity of error, 0=warnings,9=critical';
comment on column JOB_LOG.JL_TYPE
  is 'Log type: 0=errors,1 information, 2=performance statistics,3=debug information';
-- Create/Recreate primary, unique and foreign key constraints 
--alter table JOB_LOG  add constraint JL_FK1 foreign key (JB_NUMBER, JB_THREAD_ID)  references JOBS (JB_NUMBER, JB_THREAD_ID);


-- Create/Recreate check constraints 
alter table JOB_LOG
  add constraint JOB_LOG_CHK1
  check (JL_SEVERITY between 0 and 9);

prompt
prompt Creating table JOBS
prompt ===================
prompt

-- Create table
create table JOBS
(
  JB_NUMBER      NUMBER(5) not null,
  JB_THREAD_ID   NUMBER(5) default 0 not null,
  JB_NAME        VARCHAR2(32) not null,
  JB_TYPE        VARCHAR2(32),
  JB_STATUS      VARCHAR2(1) not null,
  JB_STATUS_MSG  VARCHAR2(1000),
  JB_STATUS_DT   DATE,
  JB_LAST_RUN_NO NUMBER(5)
)
tablespace #TBS_COMMON_DAT_NAME
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 512K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );

-- Add comments to the columns 
comment on column JOBS.JB_NUMBER
  is 'Unique job number for each background job. 0 is reserved for errors from non-job invoked processes';
comment on column JOBS.JB_THREAD_ID
  is 'Unique thread id (if multiple threads for one job are scheduled)';
comment on column JOBS.JB_STATUS
  is 'Status R=Running,S=Stopped, E=Error';

-- Create/Recreate primary, unique and foreign key constraints 
alter table JOBS
  add constraint JOBS_PK1 primary key (JB_NUMBER, JB_THREAD_ID)
  using index 
  tablespace #TBS_COMMON_IDX_NAME
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 64K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );

-- Create/Recreate check constraints 
alter table JOBS
  add constraint JB_CHK1
  check (JB_STATUS in ('S','R','E'));
 

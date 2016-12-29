prompt
prompt Creating table PARTITION_SETTINGS
prompt =================================
prompt
create table PARTITION_SETTINGS
(
  TABLE_OWNER    VARCHAR2(30) not null,
  TABLE_NAME     VARCHAR2(30) not null,
  CURR_PART      VARCHAR2(30) not null,
  CURR_TBSP      VARCHAR2(30) not null,
  NEXT_PART      VARCHAR2(30) not null,
  NEXT_TBSP      VARCHAR2(30) not null,
  LAST_SWITCH_DT DATE not null,
  NEXT_SWITCH_DT DATE not null,
  MAX_TBSP_NUM   NUMBER(3) not null,
  MIN_TBSP_NUM   NUMBER(3) not null,
  PART_TYPE      VARCHAR2(10) not null,
  PART_RANGE     NUMBER(6) not null,
  PART_DAYS      NUMBER(5) not null,
  ANALYZE_METHOD VARCHAR2(30) default 'ESTIMATE' not null,
  ANALYZE_DELAY  NUMBER(5) default 60
)
tablespace #TBS_COMMON_DAT_NAME
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 64K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
comment on column PARTITION_SETTINGS.TABLE_OWNER
  is 'Oracle user schema in which the table is created';
comment on column PARTITION_SETTINGS.CURR_PART
  is 'The name current partition';
comment on column PARTITION_SETTINGS.CURR_TBSP
  is 'Tablespace assigned to current partition';
comment on column PARTITION_SETTINGS.NEXT_TBSP
  is 'Tablespace assigned to next partition - auto populated';
comment on column PARTITION_SETTINGS.MAX_TBSP_NUM
  is 'If the partitions are spread across multiple tablespaces then the suffix of the tablespace identifies the sequence. This is the start number';
comment on column PARTITION_SETTINGS.MIN_TBSP_NUM
  is 'The max number in tablespace suffix ';
comment on column PARTITION_SETTINGS.ANALYZE_METHOD
  is 'Analyze method (COMPUTE or ESTIMATE), Null value implies no analyze';
comment on column PARTITION_SETTINGS.ANALYZE_DELAY
  is 'Delay in minutes after which the PKG_PART_MGR will automatically analyze the table. ';
alter table PARTITION_SETTINGS
  add constraint PARTITION_SETTINGS_PK primary key (TABLE_OWNER, TABLE_NAME)
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
alter table PARTITION_SETTINGS
  add constraint PARTITION_SETTINGS_CHK1
  check (part_type ='TIME_KEY' or part_type = 'DATE');


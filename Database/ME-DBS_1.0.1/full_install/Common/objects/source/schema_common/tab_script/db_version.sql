prompt
prompt Creating table DB_VERSION
prompt =========================
prompt

-- Create table
create table DB_VERSION
(
  COMPONENT_NAME VARCHAR2(100),
  VERSION        VARCHAR2(10),
  INSTALL_DT     DATE,
  STATUS         VARCHAR2(200),
  REMARKS        VARCHAR2(1000)
)
tablespace #TBS_COMMON_DAT_NAME
  pctfree 10
  pctused 40
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

-- Add comments to the table 
comment on table DB_VERSION
  is 'For the database component, the status of COMPLETED means the database installation has completed.';


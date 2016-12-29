prompt
prompt Creating table DB_SETTINGS
prompt =========================
prompt

-- Create table
create table DB_SETTINGS
(
  SETTING_NAME   VARCHAR2(100) not null,
  DATA_TYPE      VARCHAR2(1) not null,
  VALUE          VARCHAR2(2000),
  DESCRIPTION    VARCHAR2(1000)
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
comment on table DB_SETTINGS
  is 'Settings for the database component - do not modify';

comment on column DB_SETTINGS.DATA_TYPE
  is 'D=Date,V=Varchar2,N=Number';

alter table DB_SETTINGS
  add constraint DB_SETTINGS_CHK1
  check (DATA_TYPE in ('D','V','N'));

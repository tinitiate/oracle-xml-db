-- Create table
create table MQ_MSG_RIBBON_CONFIG
(
  mq_msg_app_id   NUMBER(20) not null,
  start_timestamp TIMESTAMP(6),
  end_timestamp   TIMESTAMP(6),
  app_name        VARCHAR2(1000),
  enviroment      VARCHAR2(1000),
  node            VARCHAR2(1000),
  add_dtime       DATE default sysdate not null,
  add_user_id     VARCHAR2(30) not null,
  upd_dtime       DATE default sysdate not null,
  upd_user_id     VARCHAR2(30) not null
);

-- Create/Recreate primary, unique and foreign key constraints 
alter table MQ_MSG_RIBBON_CONFIG
  add constraint PK_MQ_MSG_RIBBON_CONFIG primary key (MQ_MSG_APP_ID);


-- Create table
create table MQ_MSG_RIBBON_DTL_CONFIG
(
  mq_msg_dtl_id      NUMBER(20) not null,
  mq_msg_app_id      NUMBER(20),
  message_type       VARCHAR2(1000),
  communication_type VARCHAR2(1000),
  add_dtime          DATE default sysdate not null,
  add_user_id        VARCHAR2(30) not null,
  upd_dtime          DATE default sysdate not null,
  upd_user_id        VARCHAR2(30) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table MQ_MSG_RIBBON_DTL_CONFIG
  add constraint PK_MQ_MSG_RIBBON_DTL_CONFIG primary key (MQ_MSG_DTL_ID);

-- Create table
create table MQ_MSG_RIBBON_CMD_CONFIG
(
  mq_msg_cmd_id  NUMBER(20) not null,
  mq_msg_dtl_id  NUMBER(20),
  mq_msg_app_id  NUMBER(20),
  command_type   VARCHAR2(1000),
  property_name  VARCHAR2(1000),
  property_value VARCHAR2(1000),
  add_dtime      DATE default sysdate not null,
  add_user_id    VARCHAR2(30) not null,
  upd_dtime      DATE default sysdate not null,
  upd_user_id    VARCHAR2(30) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table MQ_MSG_RIBBON_CMD_CONFIG
  add constraint PK_MQ_MSG_RIBBON_CMD_CONFIG primary key (MQ_MSG_CMD_ID);
  

drop table CMN_ROLE_PRODUCT;
drop table CMN_ROLE_BRPM;
drop table CMN_ROLE_BSA;
drop table CMN_USER_APP;
drop table CMN_LOG;
drop table CMN_DETAIL_LOG;
drop table  CMN_APP_INFO; 
drop table  CMN_SERVERS_INFO; 
drop table  CMN_ENVIRONMENT; 
drop table  CMN_APP_GROUP; 
drop table  CMN_APP_GROUP_SERVER; 
drop table  CMN_APP_GROUP_SERVICE; 
drop table  CMN_APP_OS_USER; 
drop table  FIELD_TYPE_INFO;
drop table  TOOL_BOX_INFO; 
drop table  TOOL_BOX_PARAM_INFO; 
drop table  TOOL_BOX_SERVER_INFO; 
drop table TOOL_BOX_EXTEND_ATTRI;
drop table  TOOL_BOX_SCRIPT_INFO; 
drop table  TOOL_BOX_DESC_INFO;
drop table  TOOL_BOX_EVENT_GROUP_INFO; 
drop table  TOOL_BOX_KEY_WORD_INFO;
drop table OCC_TOOL_BOX_FILES;
drop table TOOL_BOX_FILES;

drop table  CHECK_JOB_INFO; 
drop table  CHECK_JOB_TEMPLATE; 
drop table  CHECK_JOB_SERVER; 
drop table  CHECK_JOB_TIMER; 

drop table  DPLY_REQUEST_INFO;
﻿drop table DPLY_EXECUTE_STATUS;
drop table DPLY_JOB_INFO;
drop table DPLY_JOB_SCRIPT_INFO;
drop table DPLY_JOB_BLPACKAGE_INFO;
drop table MONITOR_WARNING_INFO;
drop table MONITOR_POLICY_CONFIG;
drop table MONITOR_EVENT_TYPE_CONFIG;
drop table CHECK_ITEM_INFO;
drop table CHECK_ITEM_NSH_INFO;
drop table CHECK_ITEM_SCRIPT_INFO;
drop table CHECK_JOB_LOG_INFO;
drop table  REQUESTS; 
drop table STEPS;
drop table DPLY_PARAM_INFO;
drop table BUSINESS_ALARM_RELATION;
drop table BUSINESS_FIELD_DATA_INFO;
drop table BUSINESS_KEY_WORD_RELATION;
drop table BUSINESS_IMPACT_INFO;


drop table APPLICATION_PROCESS_RECORDS;
drop table APPLICATION_SYSTEM_AUTH;
drop table OCCAS_SERVERS_INFO;



CREATE TABLE CMN_APP_INFO 
   (	  
    APPSYS_CODE	VARCHAR2(10)  NOT NULL,
    APPSYS_NAME	VARCHAR2(100),  
    SYSA	VARCHAR2(64),
    SYSB	VARCHAR2(64),
    APPA	VARCHAR2(64),
    APPB	VARCHAR2(64),
    DEVELOP	VARCHAR2(64),
    FLAG	VARCHAR2(64),
    DEPART	VARCHAR2(1024),
    FUWU	VARCHAR2(64),
    ANQUAN	VARCHAR2(64),
    JIBIE	VARCHAR2(64),
    MANAGER	VARCHAR2(64),
    APP_OUTLINE	VARCHAR2(2000),
    APP_TYPE	VARCHAR2(64),
    HEXIN_JIBIE	VARCHAR2(64),
    ZHONGYAO_JIBIE	VARCHAR2(64),
    GUANJIAN_JIBIE	VARCHAR2(64),
    GROUPNAME	VARCHAR2(100),
    AOP_FLAG	CHAR(1),
    LAST_SCAN_TIME	TIMESTAMP,
    DELETE_FLAG	CHAR(1)  NOT NULL,
    UPDATE_TIME TIMESTAMP NOT NULL,
    UPDATE_BEFORE_RECORD VARCHAR2(2000),
    PRIMARY KEY (APPSYS_CODE) 
);
/*==============================================================*/
/* Table: DPLY_EXECUTE_STATUS                                               */
/*==============================================================*/
-- Create table
create table DPLY_EXECUTE_STATUS
(
  ENTRY_ID                 VARCHAR2(40) not null,
  APPSYS_CODE          VARCHAR2(10) not null,
  USER_ID                  VARCHAR2(20) not null,
  EXECUTE_START_TIME      TIMESTAMP,
  EXECUTE_END_TIME         TIMESTAMP,
  MOVE_STATUS               VARCHAR2(11) not null,
  OPERATE_TYPE          VARCHAR2(50) not null,
  OPERATE_SOURCE          VARCHAR2(100) not null,
  OPERATE_LOG          VARCHAR2(1000)
);
-- Create/Recreate primary, unique and foreign key constraints
alter table DPLY_EXECUTE_STATUS
  add constraint PK_DPLY_EXECUTE_STATUS primary key (ENTRY_ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
/*==============================================================*/
/* Table: CMN_ROLE_PRODUCT                                               */
/*==============================================================*/
-- Create table
create table CMN_ROLE_PRODUCT
(
  PRO_ROLE_ID VARCHAR2(50) not null,
  PRO_ROLE_NAME VARCHAR2(100) not null,
  PRO_ROLE_DESC VARCHAR2(200),
  PRO_ROLE_TYPE CHAR(1) not null,
  PRO_ROLE_ISRELATION_APP NUMBER(1) default 0 not null,
  PRO_ROLE_ACTION VARCHAR2(200)
);
-- Add comments to the table 
comment on table CMN_ROLE_PRODUCT
  is '产品角色列表';
-- Add comments to the columns 
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_ID
  is '产品角色ID';
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_NAME
  is '产品角色名称';
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_DESC
  is '产品角色描述';
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_ACTION
  is '产品角色类型0:BRPM,1:BBSA';
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_ISRELATION_APP
  is 'BSA产品角色是否需要关联系统0:不关联,1:关联';
comment on column CMN_ROLE_PRODUCT.PRO_ROLE_TYPE
  is '产品角色操作';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_ROLE_PRODUCT
  add constraint CMN_ROLE_PRODUCT primary key (PRO_ROLE_ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
/*==============================================================*/
/* Table: CMN_ROLE_BRPM                                               */
/*==============================================================*/
-- Create table
create table CMN_ROLE_BRPM
(
  ROLE_ID VARCHAR2(50) not null,
  PRO_ROLE_ID VARCHAR2(50) not null
);
-- Add comments to the table 
comment on table CMN_ROLE_BRPM
  is '角色映射关系表';
-- Add comments to the columns 
comment on column CMN_ROLE_BRPM.ROLE_ID
  is '平台角色ID';
comment on column CMN_ROLE_BRPM.PRO_ROLE_ID
  is '映射BRPM角色ID';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_ROLE_BRPM
  add constraint CMN_ROLE_BRPM primary key (ROLE_ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CMN_ROLE_BRPM
  add constraint ROLE_BRPM foreign key (ROLE_ID)
  references JEDA_ROLE (ROLE_ID);
alter table CMN_ROLE_BRPM
  add constraint ROLE_BRPM2 foreign key (PRO_ROLE_ID)
  references CMN_ROLE_PRODUCT (PRO_ROLE_ID);
 
/*==============================================================*/
/* Table: CMN_ROLE_BSA                                               */
/*==============================================================*/
-- Create table
create table CMN_ROLE_BSA
(
  ROLE_ID VARCHAR2(50) not null,
  PRO_ROLE_ID VARCHAR2(50) not null
);
-- Add comments to the table 
comment on table CMN_ROLE_BSA
  is '角色映射关系表';
-- Add comments to the columns 
comment on column CMN_ROLE_BSA.ROLE_ID
  is '平台角色ID';
comment on column CMN_ROLE_BSA.PRO_ROLE_ID
  is '映射BSA角色ID';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_ROLE_BSA
  add constraint CMN_ROLE_BSA primary key (ROLE_ID, PRO_ROLE_ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CMN_ROLE_BSA
  add constraint ROLE_BSA foreign key (ROLE_ID)
  references JEDA_ROLE (ROLE_ID);
alter table CMN_ROLE_BSA
  add constraint ROLE_BSA2 foreign key (PRO_ROLE_ID)
  references CMN_ROLE_PRODUCT (PRO_ROLE_ID);

/*==============================================================*/
/* Table: CMN_USER_APP                                               */
/*==============================================================*/
-- Create table
create table CMN_USER_APP
(
  USER_ID VARCHAR2(50) not null,
  APPSYS_CODE VARCHAR2(50) not null,
  APP_TYPE CHAR(1),
  DPLY_FLAG   CHAR(1),
  CHECK_FLAG  CHAR(1),
  TOOL_FLAG   CHAR(1)
);
-- Add comments to the table 
comment on table CMN_USER_APP
  is '用户系统关系表';
-- Add comments to the columns 
comment on column CMN_USER_APP.USER_ID
  is '平台用户ID';
comment on column CMN_USER_APP.APPSYS_CODE
  is '应用系统代码';
comment on column CMN_USER_APP.APP_TYPE
  is '同步类型'; 
comment on column CMN_USER_APP.DPLY_FLAG
  is '1：具有应用发布权限  0：没有应用发布权限';
comment on column CMN_USER_APP.CHECK_FLAG
  is '1：具有巡检权限  0：没有巡检权限';
comment on column CMN_USER_APP.TOOL_FLAG
  is '1：具有工具箱权限  0：没有工具箱权限';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_USER_APP
  add constraint CMN_USER_APP primary key (USER_ID, APPSYS_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CMN_USER_APP
  add constraint USER_APP foreign key (USER_ID)
  references JEDA_USER (USER_ID);
alter table CMN_USER_APP
  add constraint USER_APP2 foreign key (APPSYS_CODE)
  references CMN_APP_INFO (APPSYS_CODE);

CREATE TABLE CMN_LOG 
   (	  
LOG_JNL_NO	NUMBER	NOT NULL,
APPSYS_CODE	VARCHAR2(10)	NOT NULL,
LOG_RESOURCE_TYPE	CHAR(1)	NOT NULL,
REQUEST_NAME	VARCHAR2(100)	NOT NULL,
LOG_TYPE	CHAR(1)	NOT NULL,
EXEC_STATUS	CHAR(1)	NOT NULL,
EXEC_DATE	VARCHAR2(8)	NOT NULL,
EXEC_START_TIME	TIMESTAMP	NOT NULL,
EXEC_COMPLETED_TIME	TIMESTAMP,	
EXEC_CREATED_TIME	TIMESTAMP,	
EXEC_UPDATED_TIME	TIMESTAMP,	
AUTHORIZED_USER	VARCHAR2(50),	
PLATFORM_USER	VARCHAR2(50)	NOT NULL,
EVENT_ID VARCHAR2(255),
    PRIMARY KEY (LOG_JNL_NO)
);

CREATE TABLE CMN_DETAIL_LOG 
   (	  
LOG_JNL_NO	NUMBER	NOT NULL,
DETAIL_LOG_SEQ	INTEGER	NOT NULL,
APPSYS_CODE	VARCHAR2(10)	NOT NULL,
STEP_NAME	VARCHAR2(100)	NOT NULL,
JOB_NAME	VARCHAR2(150)	NOT NULL,
EXEC_SERVER_IP	VARCHAR2(20),	
LOG_TYPE	CHAR(1)	NOT NULL,
EXEC_STATUS	CHAR(1)	NOT NULL,
EXEC_DATE	VARCHAR2(8)	NOT NULL,
EXEC_START_TIME	TIMESTAMP	NOT NULL,
EXEC_COMPLETED_TIME	TIMESTAMP	NOT NULL,
EXEC_CREATED_TIME	TIMESTAMP,	
EXEC_UPDATED_TIME	TIMESTAMP,	
RESULTS_PATH	VARCHAR2(200),	
EXEC_CMD	VARCHAR2(500),	
    PRIMARY KEY (LOG_JNL_NO,DETAIL_LOG_SEQ)
);

CREATE TABLE CMN_SERVERS_INFO 
(	  
    SERVER_IP	VARCHAR2(20)       NOT NULL,
    SERVER_NAME	VARCHAR2(30),
    APPSYS_CODE	VARCHAR2(10) NOT NULL,
    BSA_AGENT_FLAG	CHAR(1)    NOT NULL,
    FLOATING_IP	VARCHAR2(200),
    SERVER_ROLE	VARCHAR2(20),
    SERVER_USE	VARCHAR2(20),
    MACHINEROOM_POSITION	VARCHAR2(30),
    OS_TYPE	VARCHAR2(100),
    MW_TYPE VARCHAR2(30),
    DB_TYPE VARCHAR2(30),
    COLLECTION_STATE VARCHAR2(10),
    ATTR_FLAG CHAR(1),
    ENVIRONMENT_TYPE	VARCHAR2(30),
    DATA_TYPE	CHAR(1),
    DELETE_FLAG	CHAR(1)  NOT NULL,
    UPDATE_TIME TIMESTAMP NOT NULL,
    UPDATE_BEFORE_RECORD VARCHAR2(500),
    PRIMARY KEY (SERVER_IP,APPSYS_CODE)
);

CREATE TABLE CMN_ENVIRONMENT 
(	  
    APPSYS_CODE	VARCHAR2(10)	NOT NULL,
    ENVIRONMENT_CODE	VARCHAR2(30)	NOT NULL,
    ENVIRONMENT_NAME	VARCHAR2(100),	
    ENVIRONMENT_TYPE	CHAR(1)	NOT NULL,
    DESCRIBE	VARCHAR2(50),	
    DELETE_FLAG	CHAR(1)	NOT NULL,
    PRIMARY KEY (APPSYS_CODE,ENVIRONMENT_CODE)
);

CREATE TABLE CMN_APP_GROUP 
(	  
    APPSYS_CODE	VARCHAR2(10)	NOT NULL,
    SERVER_GROUP	VARCHAR2(20)	NOT NULL,
    ENVIRONMENT_CODE	VARCHAR2(30)	NOT NULL,
    SERVER_USE	CHAR(1),	
    SHARE_STORE_FLAG	CHAR(1),
    FLOAT_IP	VARCHAR2(20),	
    DELETE_FLAG	CHAR(1)	NOT NULL,
    PRIMARY KEY (APPSYS_CODE,SERVER_GROUP,ENVIRONMENT_CODE)
);

CREATE TABLE CMN_APP_GROUP_SERVER 
(	  
    APPSYS_CODE	VARCHAR2(10)	NOT NULL,
    SERVER_GROUP	VARCHAR2(20)	NOT NULL,
    SERVER_IP	VARCHAR2(20)	NOT NULL,
    ENVIRONMENT_CODE	VARCHAR2(30)	NOT NULL,
    DELETE_FLAG	CHAR(1)	NOT NULL,	
    PRIMARY KEY (APPSYS_CODE,SERVER_GROUP,SERVER_IP,ENVIRONMENT_CODE)
);

CREATE TABLE CMN_APP_GROUP_SERVICE
(
    APPSYS_CODE	VARCHAR2(10)	NOT NULL,
    SERVICE_NAME	VARCHAR2(50)	NOT NULL,
    SERVER_GROUP	VARCHAR2(20),
    PRIMARY KEY (APPSYS_CODE,SERVICE_NAME)
);

create table IAM_STATUS
(
  STATUS NUMBER(1) default 0 not null,
      PRIMARY KEY (STATUS)
);

CREATE TABLE CMN_APP_OS_USER 
(	  
    APPSYS_CODE	VARCHAR2(10)	NOT NULL,
    USER_ID	VARCHAR2(20)	NOT NULL,
    SERVER_IP	VARCHAR2(20)	NOT NULL,
    OS_USER	VARCHAR2(30)	NOT NULL,
    DATA_TYPE CHAR(1),
    DELETE_FLAG	CHAR(1)	NOT NULL,	
    UPDATE_TIME TIMESTAMP NOT NULL,
    UPDATE_BEFORE_RECORD VARCHAR2(100),
    PRIMARY KEY (APPSYS_CODE,USER_ID,SERVER_IP,OS_USER)
);

/*==============================================================*/
/* Table: FIELD_TYPE_INFO分类管理表                                               */
/*==============================================================*/
-- Create table
CREATE TABLE FIELD_TYPE_INFO
(	  
    FIELD_ID	NUMBER	NOT NULL,
    FIELD_TYPE_DIRECTION	VARCHAR2(100),
    FIELD_TYPE_ONE	VARCHAR2(100)	NOT NULL,
    FIELD_TYPE_TWO	VARCHAR2(100),
    FIELD_TYPE_THREE	VARCHAR2(100),
    COMMENTS 	VARCHAR2(100),
    FILED_CREATOR	  VARCHAR2(100),
    FILED_CREATED  TIMESTAMP,
    FILED_MODIFIER  VARCHAR2(100),
    FILED_MODIFIED  TIMESTAMP,
    PRIMARY KEY (FIELD_ID)
);

/*==============================================================*/
/* Table: TOOL_BOX_INFO工具箱管理信息表                                         */
/*==============================================================*/
-- Create table

CREATE TABLE TOOL_BOX_INFO 
(	  
   "TOOL_CODE" VARCHAR2(100 BYTE) NOT NULL  , 
	"APPSYS_CODE" VARCHAR2(10 BYTE) NOT NULL  , 
	"TOOL_NAME" VARCHAR2(100 BYTE), 
	"TOOL_DESC" VARCHAR2(1000 BYTE), 
	"AUTHORIZE_LEVEL_TYPE" CHAR(1 BYTE) NOT NULL  , 
	"FIELD_TYPE_ONE" VARCHAR2(100 BYTE) NOT NULL  , 
	"FIELD_TYPE_TWO" VARCHAR2(100 BYTE), 
	"FIELD_TYPE_THREE" VARCHAR2(100 BYTE), 
	"TOOL_AUTHORIZE_FLAG" CHAR(1 BYTE) NOT NULL  , 
	"TOOL_TYPE" CHAR(1 BYTE) NOT NULL  ,
	"TOOL_CREATOR" VARCHAR2(6 BYTE), 
	"TOOL_MODIFIER" VARCHAR2(6 BYTE), 
	"TOOL_CREATED_TIME" TIMESTAMP (6), 
	"TOOL_UPDATED_TIME" TIMESTAMP (6), 
	"DELETE_FLAG" CHAR(1 BYTE) NOT NULL  
);
alter table TOOL_BOX_INFO
  add constraint PK_TOOL_BOX_INFO primary key (TOOL_CODE,APPSYS_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
 

CREATE TABLE TOOL_BOX_PARAM_INFO
(	  
APPSYS_CODE	VARCHAR2(10)	NOT NULL,
TOOL_CODE	VARCHAR2(100)	NOT NULL,
PARAM_NAME	VARCHAR2(20)	NOT NULL,
PARAM_TYPE	CHAR(1),	
PARAM_LENGTH	NUMBER(4),	
PARAM_FORMAT	VARCHAR2(30),	
PARAM_DEFAULT_VALUE	VARCHAR2(100),	
PARAM_DESC	VARCHAR2(100),
    PRIMARY KEY (APPSYS_CODE,TOOL_CODE,PARAM_NAME)
);

CREATE TABLE TOOL_BOX_SERVER_INFO 
(	  
APPSYS_CODE	VARCHAR2(10)	NOT NULL,
TOOL_CODE	VARCHAR2(100)	NOT NULL,
SERVER_IP	VARCHAR2(20)	NOT NULL,
SERVER_ROUTE	VARCHAR2(100),	
OS_USER	VARCHAR2(30),
    PRIMARY KEY (APPSYS_CODE,TOOL_CODE,SERVER_IP)
);


create table TOOL_BOX_EXTEND_ATTRI
(
  TOOL_CODE          VARCHAR2(100) not null,
  TOOL_STATUS        CHAR(1),
  TOOL_RETURNREASONS VARCHAR2(500),
  TOOL_RECEIVED_USER VARCHAR2(6),
  TOOL_RECEIVED_TIME TIMESTAMP(6),
  PRIMARY KEY (TOOL_CODE)
);


  CREATE TABLE  TOOL_BOX_SCRIPT_INFO  
   (	"TOOL_CODE" VARCHAR2(100 BYTE) NOT NULL , 
	"SHELL_NAME" VARCHAR2(50 BYTE), 
	"SERVER_GROUP" VARCHAR2(20 BYTE), 
	"GROUP_SERVER_FLAG" CHAR(1 BYTE), 
	"OS_USER_FLAG" CHAR(1 BYTE), 
	"OS_USER" VARCHAR2(30 BYTE), 
	"OS_TYPE" CHAR(1 BYTE), 
	"POSITION_TYPE" CHAR(1 BYTE), 
	"TOOL_CHARSET" CHAR(1 BYTE)
   );
   
   alter table TOOL_BOX_SCRIPT_INFO
  add constraint PK_TOOL_BOX_SCRIPT_INFO primary key (TOOL_CODE )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  
  
 CREATE TABLE  TOOL_BOX_DESC_INFO  
   (	"TOOL_CODE" VARCHAR2(100 BYTE) NOT NULL , 
	    "TOOL_CONTENT" CLOB
	 ）;


   alter table TOOL_BOX_DESC_INFO
  add constraint PK_TOOL_BOX_DESC_INFO primary key (TOOL_CODE )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  
     
	 CREATE TABLE  TOOL_BOX_EVENT_GROUP_INFO  
   (	"TOOL_CODE" VARCHAR2(100 BYTE) NOT NULL , 
	    "EVENT_GROUP" VARCHAR2(1500)
	 ）;
	 
	    alter table TOOL_BOX_EVENT_GROUP_INFO
  add constraint PK_TOOL_BOX_EVENT_GROUP_INFO primary key (TOOL_CODE,EVENT_GROUP )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
	
	 
  
 CREATE TABLE  TOOL_BOX_KEY_WORD_INFO  
   (	"TOOL_CODE" VARCHAR2(100 BYTE) NOT NULL , 
	    "SUMMARYCN" VARCHAR2(500)
	);
	 
	    alter table TOOL_BOX_KEY_WORD_INFO
  add constraint PK_TOOL_BOX_KEY_WORD_INFO primary key (TOOL_CODE,SUMMARYCN )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


CREATE TABLE OCC_TOOL_BOX_FILES
(	  

TOOL_CODE	VARCHAR2(100)	NOT NULL,
FILE_ID	VARCHAR2(40)	NOT NULL,
FILE_CONTENT	BLOB,	
FILE_NAME	VARCHAR2(100),	
FILE_TYPE	VARCHAR2(30)
);

  alter table OCC_TOOL_BOX_FILES
  add constraint PK_OCC_TOOL_BOX_FILES primary key (TOOL_CODE,FILE_ID )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

CREATE TABLE TOOL_BOX_FILES
(	  

TOOL_CODE	VARCHAR2(100)	NOT NULL,
FILE_ID	VARCHAR2(40)	NOT NULL,
FILE_CONTENT	BLOB,	
FILE_NAME	VARCHAR2(100),	
FILE_TYPE	VARCHAR2(30),	
    PRIMARY KEY (TOOL_CODE,FILE_ID)
);

 alter table TOOL_BOX_FILES
  add constraint PK_TOOL_BOX_FILES primary key (TOOL_CODE,FILE_ID )
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );





--巡检 begin
CREATE TABLE CHECK_JOB_INFO 
(	  
  APPSYS_CODE          VARCHAR2(10) not null,
  JOB_CODE             NUMBER(8) not null,
  CHECK_TYPE           CHAR(1) not null,
  AUTHORIZE_LEVEL_TYPE CHAR(1) not null,
  FIELD_TYPE           VARCHAR2(20) not null,
  JOB_NAME             VARCHAR2(60) not null,
  JOB_PATH             VARCHAR2(100) not null,
  JOB_TYPE             VARCHAR2(1) not null,
  JOB_DESC             VARCHAR2(600),
  TOOL_STATUS          CHAR(1) not null,
  FRONTLINE_FLAG       CHAR(1) not null,
  AUTHORIZE_FLAG       CHAR(1) not null,
  DELETE_FLAG          CHAR(1) not null,
  TOOL_CREATOR         VARCHAR2(10),
  SCRIPT_NAME          VARCHAR2(100),
  EXEC_PATH            VARCHAR2(100),
  EXEC_USER            VARCHAR2(20),
  EXEC_USER_GROUP      VARCHAR2(60),
  LANGUAGE_TYPE        VARCHAR2(20),
  SERVER_TARGET_TYPE   CHAR(1)


);
-- Add comments to the table
comment on table CHECK_JOB_INFO
  is '巡检作业信息表';
  comment on column CHECK_JOB_INFO.SERVER_TARGET_TYPE
  is '巡检目标，0：服务器、1：智能组';
-- Create/Recreate primary, unique and foreign key constraints
alter table CHECK_JOB_INFO
  add constraint PK_CHECK_JOB_INFO primary key (APPSYS_CODE,JOB_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table CHECK_JOB_TEMPLATE
(
  APPSYS_CODE   VARCHAR2(10) not null,
  JOB_CODE      NUMBER(8) not null,
  TEMPLATE_PATH VARCHAR2(100) not null,
  TEMPLATE_NAME VARCHAR2(30) not null
);
comment on table CHECK_JOB_TEMPLATE
  is '作业模板关系表';
-- Create/Recreate primary, unique and foreign key constraints
alter table CHECK_JOB_TEMPLATE
  add constraint PK_CHECK_JOB_TEMPLATE primary key (APPSYS_CODE, JOB_CODE, TEMPLATE_PATH, TEMPLATE_NAME)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table CHECK_JOB_TIMER
(
  APPSYS_CODE           VARCHAR2(10) not null,
  JOB_CODE              INTEGER not null,
  TIMER_CODE            INTEGER not null,
  EXEC_FREQUENCY_TYPE   CHAR(1) not null,
  EXEC_START_DATE       VARCHAR2(10),
  EXEC_START_TIME       VARCHAR2(8) not null,
  WEEK1_FLAG            CHAR(1),
  WEEK2_FLAG            CHAR(1),
  WEEK3_FLAG            CHAR(1),
  WEEK4_FLAG            CHAR(1),
  WEEK5_FLAG            CHAR(1),
  WEEK6_FLAG            CHAR(1),
  WEEK7_FLAG            CHAR(1),
  MONTH_DAYS            INTEGER,
  INTERVAL_WEEKS        INTEGER,
  INTERVAL_DAYS         INTEGER,
  INTERVAL_HOURS        INTEGER,
  INTERVAL_MINUTES      INTEGER,
  EXEC_PRIORITY         VARCHAR2(10),
  EXEC_NOTICE_MAIL_LIST VARCHAR2(1000),
  MAIL_SUCCESS_FLAG     CHAR(1),
  MAIL_FAILURE_FLAG     CHAR(1),
  MAIL_CANCEL_FLAG      CHAR(1),
  EXEC_NOTICE_SNMP_LIST VARCHAR2(1000),
  SNMP_STATUS_VALUE     INTEGER
);
comment on table CHECK_JOB_TIMER
  is '作业自动执行时间表';
-- Create/Recreate primary, unique and foreign key constraints
alter table CHECK_JOB_TIMER
  add constraint PK_CHECK_JOB_TIMER primary key (APPSYS_CODE, JOB_CODE, TIMER_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table CHECK_JOB_SERVER
(
  APPSYS_CODE VARCHAR2(10) not null,
  JOB_CODE    NUMBER(8) not null,
  SERVER_PATH VARCHAR2(100) not null,
  SERVER_NAME VARCHAR2(60) not null
);
comment on table CHECK_JOB_SERVER
  is '作业服务器关系表';
-- Create/Recreate primary, unique and foreign key constraints
alter table CHECK_JOB_SERVER
  add constraint PK_CHECK_JOB_SERVER primary key (APPSYS_CODE, SERVER_PATH, JOB_CODE, SERVER_NAME)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
--巡检 end


CREATE TABLE DPLY_REQUEST_INFO 
(	  
APPSYS_CODE	VARCHAR2(10)	NOT NULL,
REQUEST_CODE	VARCHAR2(50)	NOT NULL,
PLAN_DEPLOY_DATE	CHAR(8),
DEPLOY_CODE	VARCHAR2(11),	
REQUEST_NAME	VARCHAR2(50),	
ENVIRONMENT	VARCHAR2(20),	
DESCRIBE	VARCHAR2(300),	
TURN_SWITCH	CHAR(1),	
EXEC_STATUS	CHAR(1)	NOT NULL,
PLAN_START_TIME	CHAR(4),	
PLAN_END_TIME	CHAR(4),	
REAL_START_DATE	TIMESTAMP,	
REAL_END_DATE	TIMESTAMP,	
EXPORT_USER	 VARCHAR2(6),	
IMPORT_USER	VARCHAR2(6),	
    PRIMARY KEY (APPSYS_CODE,REQUEST_CODE)
);

/*==============================================================*/
/* Table: DPLY_JOB_INFO应用发布作业信息表                  */
/*==============================================================*/
-- Create table
create table DPLY_JOB_INFO
(
  APPSYS_CODE           VARCHAR2(10) not null,
  JOB_NAME              VARCHAR2(200) not null,
  JOB_TYPE              NUMBER(1) not null,
  JOB_PATH              VARCHAR2(200) not null,
  JOB_PARENT_GROUP      VARCHAR2(50) not null,
  NSH_BLPACKAGE_NAME VARCHAR2(200) not null,
  JOB_CREATOR           VARCHAR2(50),
  JOB_CREATED           TIMESTAMP(6),
  JOB_MODIFIER          VARCHAR2(50),
  JOB_MODIFIED          TIMESTAMP(6),
    PRIMARY KEY (APPSYS_CODE, JOB_NAME, JOB_TYPE, JOB_PARENT_GROUP, NSH_BLPACKAGE_NAME)
);

/*==============================================================*/
/* Table: DPLY_JOB_SCRIPT_INFO应用发布NSH脚本信息表                  */
/*==============================================================*/
-- Create table
create table DPLY_JOB_SCRIPT_INFO
(
  APPSYS_CODE           VARCHAR2(10) not null,
  NSH_SCRIPT_NAME VARCHAR2(200) not null,
  NSH_SCRIPT_PATH VARCHAR2(200),
  JOB_PARENT_GROUP      VARCHAR2(50) not null,
  SCRIPT_NAME           VARCHAR2(200) not null,
  SCRIPT_PATH           VARCHAR2(200),
  PARAM_NAME            VARCHAR2(100) not null,
  PARAM_TYPE            NUMBER(1),
  PARAM_VALUE           VARCHAR2(200),
    PRIMARY KEY (APPSYS_CODE, NSH_SCRIPT_NAME, JOB_PARENT_GROUP, SCRIPT_NAME, PARAM_NAME)
);

/*==============================================================*/
/* Table: DPLY_JOB_BLPACKAGE_INFO应用发布BLPackage信息表     */
/*==============================================================*/
-- Create table
create table DPLY_JOB_BLPACKAGE_INFO
(
  APPSYS_CODE           VARCHAR2(10) not null,
  BLPACKAGE_NAME 	VARCHAR2(200) not null,
  BLPACKAGE_PATH 	VARCHAR2(200),
  JOB_PARENT_GROUP      VARCHAR2(50) not null,
  SOFTLINK_SCRIPT_NAME  VARCHAR2(200) not null,
  SOFTLINK_SCRIPT_PATH  VARCHAR2(200),
  	PRIMARY KEY (APPSYS_CODE, BLPACKAGE_NAME, JOB_PARENT_GROUP, SOFTLINK_SCRIPT_NAME)
);

/*==============================================================*/
/* Table: MONITOR_WARNING_INFO监控告警信息表     */
/*==============================================================*/
-- Create table
create table MONITOR_WARNING_INFO
(
  EVENT_ID           VARCHAR2(255) not null,
  CUSTOMERSEVERITY   NUMBER(2),
  DEVICE_ID          VARCHAR2(255),
  DEVICE_IP          VARCHAR2(64),
  ALARM_OBJECT        VARCHAR2(255),
  COMPONENTTYPE      VARCHAR2(32),
  COMPONENT          VARCHAR2(32),
  SUBCOMPONENT       VARCHAR2(32),
  SUMMARYCN          VARCHAR2(255),
  EVENTSTATUS        NUMBER(2),
  FIRST_TIME         TIMESTAMP(6),
  LAST_TIME          TIMESTAMP(6),
  ALARM_INSTANCE      VARCHAR2(255),
  APPNAME            VARCHAR2(255),
  MANAGEBYCENTER     NUMBER(1),
  MANAGEBYUSER       VARCHAR2(64),
  MANAGETIMEEXCEED   VARCHAR2(64),
  MANAGETIME         TIMESTAMP(6),
  MAINTAINSTATUS     NUMBER(1),
  REPEAT_NUMBER      NUMBER(4),
  MGTORG             VARCHAR2(64),
  ORGNAME            VARCHAR2(64),
  EVENT_GROUP        VARCHAR2(255),
  MONITOR_TOOL       VARCHAR2(255),
  IS_TICKET          VARCHAR2(64),
  N_TICKETID         VARCHAR2(64),
  UMP_ID             VARCHAR2(255),
  CAUSE_EFFECT       VARCHAR2(64),
  PARENT_EVENT_ID    VARCHAR2(255),
  HANDLE_STATUS      VARCHAR2(64),
  HANDLE_USER        VARCHAR2(64),
  HANDLE_TIME_EXCEED VARCHAR2(64),
  CLOSE_TIME         TIMESTAMP(6),
  RESULT_SUMMARY     VARCHAR2(500),
  MATCH_TOOLS_MESSAGE VARCHAR2(10),
  ALARM_RECEIVED_TIME DATE DEFAULT SYSDATE,
      PRIMARY KEY (EVENT_ID)
);

/*==============================================================*/
/* Table: MONITOR_POLICY_CONFIG监控策略配置表     */
/*==============================================================*/
-- Create table
create table MONITOR_POLICY_CONFIG
(
  APPSYS_CODE       VARCHAR2(10) not null,
  APPSYS_NAME       VARCHAR2(100) not null,
  POLICY_TYPE_ONE   VARCHAR2(50) not null,
  POLICY_TYPE_TWO   VARCHAR2(50) not null,
  POLICY_TYPE_THREE VARCHAR2(50) not null,
  POLICY_OLD_NAME   VARCHAR2(255) not null,
  POLICY_NAME       VARCHAR2(255) not null,
  POLICY_CODE       VARCHAR2(255) not null,
  POLICY_DATA_SOURCE   NUMBER(1) not null,
      PRIMARY KEY (APPSYS_CODE,POLICY_TYPE_ONE,POLICY_TYPE_TWO,POLICY_TYPE_THREE,POLICY_OLD_NAME,POLICY_CODE)
);

/*==============================================================*/
/* Table: MONITOR_EVENT_TYPE_CONFIG监控事件分类配置表     */
/*==============================================================*/
-- Create table
create table MONITOR_EVENT_TYPE_CONFIG
(
  COMPONENT_TYPE           VARCHAR2(256) not null,
  COMPONENT       				VARCHAR2(256) not null,
  SUB_COMPONENT       		VARCHAR2(256) not null,
      PRIMARY KEY (COMPONENT_TYPE,COMPONENT,SUB_COMPONENT)
);
/*==============================================================*/
/* Table: CHECK_ITEM_INFO巡检初始化表     */
/*==============================================================*/
-- Create table
create table CHECK_ITEM_INFO
(
  CHECK_ITEM_CODE         VARCHAR2(100) not null,
  CHECK_ITEM_NAME         VARCHAR2(100) not null,
  OS_TYPE                 CHAR(1) not null,
  FIELD_TYPE              VARCHAR2(20) not null,
  CHECK_OBJECT            VARCHAR2(20) not null,
  ALLINIT_NSH_SCRIPT_NAME VARCHAR2(200) not null,
  ALLINIT_NSH_SCRIPT_PATH VARCHAR2(200) not null,
  SCRIPT_CREATOR          VARCHAR2(50),
  SCRIPT_CREATED          TIMESTAMP(6),
  SCRIPT_MODIFIER         VARCHAR2(50),
  SCRIPT_MODIFIED         TIMESTAMP(6),
  CHECK_ITEM_DESC         VARCHAR2(500)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table CHECK_ITEM_INFO
  add primary key (CHECK_ITEM_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  /*==============================================================*/
/* Table: CHECK_ITEM_NSH_INFO     */
/*==============================================================*/
-- Create table
  create table CHECK_ITEM_NSH_INFO
(
  CHECK_ITEM_CODE  VARCHAR2(100) not null,
  ITEM_SCRIPT_NAME VARCHAR2(200) not null,
  ITEM_SCRIPT_PATH VARCHAR2(200) not null
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table CHECK_ITEM_NSH_INFO
  add primary key (CHECK_ITEM_CODE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
    /*==============================================================*/
/* Table: CHECK_ITEM_SCRIPT_INFO     */
/*==============================================================*/
-- Create table
  create table CHECK_ITEM_SCRIPT_INFO
(
  CHECK_ITEM_CODE VARCHAR2(100) not null,
  SCRIPT_TYPE     VARCHAR2(20) not null,
  SCRIPT_NAME     VARCHAR2(200) not null,
  SCRIPT_PATH     VARCHAR2(200) not null
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table CHECK_ITEM_SCRIPT_INFO
  add primary key (CHECK_ITEM_CODE, SCRIPT_TYPE)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
/*==============================================================*/
/* Table: CHECK_JOB_INFO     */
/*==============================================================*/
-- Create table
 create table CHECK_JOB_LOG_INFO
(
  GU_ID              VARCHAR2(50) not null,
  JOB_RUN_ID         VARCHAR2(50),
  SCRIPT_NAME        VARCHAR2(50),
  CHECK_JOB_NAME     VARCHAR2(100),
  JOB_RUN_DBKEY      VARCHAR2(100),
  JOB_DBKEY          VARCHAR2(100),
  CHECK_JOB_PATH     VARCHAR2(100),
  CHECK_JOB_STATUS   VARCHAR2(50),
  CHECK_JOB_EXECUTER VARCHAR2(50),
  JOB_START_TIME     TIMESTAMP(6),
  JOB_END_TIME       TIMESTAMP(6),
  JOB_LOG_PATH       VARCHAR2(200),
  JOB_TYPE           VARCHAR2(10)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table CHECK_JOB_LOG_INFO
  add primary key (GU_ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  /*==============================================================*/
/* Index: REQUESTS                                              */
/*==============================================================*/
 create table REQUESTS
(
  ID              NUMBER(38) not null,
  NAME            VARCHAR2(255) not null,
  APP             VARCHAR2(255) not null,
  ENVIRONMENT     VARCHAR2(255) not null,
  BRPM_REQUEST_ID NUMBER(38),
  CREATED_AT      TIMESTAMP(6),
  UPDATED_AT      TIMESTAMP(6)
);
-- Create/Recreate primary, unique and foreign key constraints
alter table REQUESTS
  add constraint PK_REQUESTS primary key (ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
/*==============================================================*/
/* Index: STEPS                                                 */
/*==============================================================*/
create table STEPS
(
  ID                            NUMBER(38) not null,
  POSITION                      NUMBER(38) not null,
  REQUEST_ID                    NUMBER(38) not null,
  NAME                          VARCHAR2(255) not null,
  DIFFERENT_LEVEL_FROM_PREVIOUS NUMBER(1) not null,
  SERVICE_CODE                  VARCHAR2(255) ,
  SERVERS                       VARCHAR2(500),
  COMPONENT                     VARCHAR2(255) ,
  MANUAL                        NUMBER(1) not null,
  OWNER                         VARCHAR2(6) not null,
  AUTO_JOB_NAME                 VARCHAR2(255),
  CREATE_STATUS                 VARCHAR2(50),
  OPERATE_LOG                   VARCHAR2(1000),
  CREATED_AT                    DATE,
  UPDATED_AT                    DATE
);
-- Create/Recreate primary, unique and foreign key constraints
alter table STEPS
  add constraint PK_STEPS primary key (ID)
  using index 
  tablespace MAOP_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
    -- Create table
  create table CMN_USER_ENV
(
  USER_ID VARCHAR2(50) not null,
  ENV     VARCHAR2(50) not null
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  /*==============================================================*/
/* TALBE: BUSINESS_ALARM_RELATION 业务影响与告警关系表                                         */
/*==============================================================*/
  -- Create table
create table BUSINESS_ALARM_RELATION
(
  BUSINESS_ID NUMBER(8) not null,
  APPSYS_CODE VARCHAR2(254) not null,
  EVENT_GROUP VARCHAR2(1500)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255;
-- Add comments to the columns 
comment on column BUSINESS_ALARM_RELATION.BUSINESS_ID
  is '业务ID';
comment on column BUSINESS_ALARM_RELATION.APPSYS_CODE
  is '应用系统编号';
comment on column BUSINESS_ALARM_RELATION.EVENT_GROUP
  is '告警策略编码';

-- Create/Recreate primary, unique and foreign key constraints 
alter table BUSINESS_ALARM_RELATION
  add constraint BUSINESS_ALARM_RELATION_PK primary key (BUSINESS_ID)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

  /*==============================================================*/
/* TALBE: BUSINESS_FIELD_DATA_INFO 业务影响数据保留表                                         */
/*==============================================================*/

-- Create table
create table BUSINESS_FIELD_DATA_INFO
(
  EVENT_ID                VARCHAR2(255) not null,
  BUSINESS_ID             NUMBER(8) not null,
  APPSYS_CODE             VARCHAR2(254) not null,
  BUSINESS_IMPACT_TYPE    VARCHAR2(100) not null,
  BUSINESS_IMPACT_LEVEL   CHAR(1) not null,
  BUSINESS_IMPACT_CONTENT VARCHAR2(1000),
  DIAGNOSTIC_STATUS       CHAR(1)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table BUSINESS_FIELD_DATA_INFO
  add constraint BUSINESS_FIELD_DATA_INFO_PK primary key (EVENT_ID, BUSINESS_ID)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


  /*==============================================================*/
/* TALBE: BUSINESS_IMPACT_INFO 业务影响 表                                         */
/*==============================================================*/

-- Create table
create table BUSINESS_IMPACT_INFO
(
  ID                      NUMBER(8) not null,
  APPSYS_CODE             VARCHAR2(254) not null,
  BUSINESS_IMPACT_TYPE    VARCHAR2(100) not null,
  BUSINESS_IMPACT_LEVEL   VARCHAR2(10),
  BUSINESS_IMPACT_CONTENT VARCHAR2(1000)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column BUSINESS_IMPACT_INFO.APPSYS_CODE
  is '应用系统编号';
comment on column BUSINESS_IMPACT_INFO.BUSINESS_IMPACT_TYPE
  is '业务影响分类';
comment on column BUSINESS_IMPACT_INFO.BUSINESS_IMPACT_LEVEL
  is '业务影响级别';
comment on column BUSINESS_IMPACT_INFO.BUSINESS_IMPACT_CONTENT
  is '业务影响内容';
-- Create/Recreate primary, unique and foreign key constraints 
alter table BUSINESS_IMPACT_INFO
  add constraint BUSINESS_IMPACT_INFO_PK primary key (ID)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


  /*==============================================================*/
/* TALBE: BUSINESS_KEY_WORD_RELATION 业务影响 关键字表                                         */
/*==============================================================*/

-- Create table
create table BUSINESS_KEY_WORD_RELATION
(
  BUSINESS_ID    NUMBER(8) not null,
  APPSYS_CODE    VARCHAR2(254) not null,
  ALARM_KEY_WORD VARCHAR2(1500)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column BUSINESS_KEY_WORD_RELATION.APPSYS_CODE
  is '应用系统';
comment on column BUSINESS_KEY_WORD_RELATION.ALARM_KEY_WORD
  is '告警关键字';


-- Create/Recreate primary, unique and foreign key constraints 
alter table BUSINESS_KEY_WORD_RELATION
  add constraint BUSINESS_KEY_WORD_RELATION_PK primary key (BUSINESS_ID)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

--删除表CMN_USER_APP的外键USER_APP2
alter table CMN_USER_APP drop constraint USER_APP2 ;

-- Create table CMN_APP_INFO_ITSM
create table CMN_APP_INFO_ITSM
(
  SYSTEMCODE           VARCHAR2(254) not null,
  SYSTEMNAME           VARCHAR2(254) not null,
  EAPSSYSTEMNAME       VARCHAR2(254),
  ENGLISHCODE          VARCHAR2(254),
  AFFECTSYSTEM         VARCHAR2(254),
  BRANCH               VARCHAR2(254),
  KEY                  VARCHAR2(254),
  STATUS               VARCHAR2(254),
  SECURITYLEVEL        VARCHAR2(254),
  SCOPE                VARCHAR2(254),
  SYSTEMPRO            VARCHAR2(254),
  ONLINEDATE           TIMESTAMP(6),
  OUTLINEDATE          TIMESTAMP(6),
  SERVERLEVEL          VARCHAR2(254),
  SYSTEMLEVEL          VARCHAR2(254),
  ISIMPORTANT          VARCHAR2(254),
  ISKEY                VARCHAR2(254),
  ISCORESYETEM         VARCHAR2(254),
  CBRCIMPORTANTSYSTEM  VARCHAR2(254),
  APPLICATEOPERATE     VARCHAR2(254),
  OUTSOURCINGMARK      VARCHAR2(254),
  NETWORKDOMAIN        VARCHAR2(254),
  TEAM                 VARCHAR2(254),
  OPERATEMANAGER       VARCHAR2(254),
  APPLICATEMANAGERA    VARCHAR2(254),
  APPLICATEMANAGERB    VARCHAR2(254),
  SYSTEMMANAGERA       VARCHAR2(254),
  SYSTEMMANAGERB       VARCHAR2(254),
  NETWORKMANAGERA      VARCHAR2(254),
  NETWORKMANAGERB      VARCHAR2(254),
  DBA                  VARCHAR2(254),
  MIDDLEWAREMANAGER    VARCHAR2(254),
  STOREMANAGER         VARCHAR2(254),
  PM                   VARCHAR2(254),
  BUSINESSDEPARTMENT   VARCHAR2(254),
  BUSINESSMANAGER      VARCHAR2(254),
  SERVICESUPPORTER     VARCHAR2(254),
  ISTESTCENTER         VARCHAR2(254),
  ALLOTTESTMANAGER     VARCHAR2(254),
  DELIVERYTESTMANAGER  VARCHAR2(254),
  QUALITYMANAGER       VARCHAR2(254),
  PERFORMANCETESTMANAG VARCHAR2(254),
  TRANSFERCOEFFICIENT  VARCHAR2(254),
  STAGE                VARCHAR2(254),
  BUSINESSINTRODUCTION VARCHAR2(3000)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    next 1
    minextents 1
    maxextents unlimited
  );
comment on table CMN_APP_INFO_ITSM
  is 'ITSM同步应用系统信息';
comment on column CMN_APP_INFO_ITSM.SYSTEMCODE
  is '系统编号';
comment on column CMN_APP_INFO_ITSM.SYSTEMNAME
  is '系统名称';
comment on column CMN_APP_INFO_ITSM.EAPSSYSTEMNAME
  is 'EAPS系统名称';
comment on column CMN_APP_INFO_ITSM.ENGLISHCODE
  is '英文简称';
comment on column CMN_APP_INFO_ITSM.AFFECTSYSTEM
  is '受影响系统';
comment on column CMN_APP_INFO_ITSM.BRANCH
  is '所属分行';
comment on column CMN_APP_INFO_ITSM.KEY
  is '关键度';
comment on column CMN_APP_INFO_ITSM.STATUS
  is '状态';
comment on column CMN_APP_INFO_ITSM.SECURITYLEVEL
  is '安全定级';
comment on column CMN_APP_INFO_ITSM.SCOPE
  is '使用范围';
comment on column CMN_APP_INFO_ITSM.SYSTEMPRO
  is '系统RPO';
comment on column CMN_APP_INFO_ITSM.ONLINEDATE
  is '系统上线时间';
comment on column CMN_APP_INFO_ITSM.OUTLINEDATE
  is '系统下线时间';
comment on column CMN_APP_INFO_ITSM.SERVERLEVEL
  is '服务级别';
comment on column CMN_APP_INFO_ITSM.SYSTEMLEVEL
  is '系统级别';
comment on column CMN_APP_INFO_ITSM.ISIMPORTANT
  is '是否重要系统';
comment on column CMN_APP_INFO_ITSM.ISKEY
  is '对外关键系统';
comment on column CMN_APP_INFO_ITSM.ISCORESYETEM
  is '是否核心重要系统';
comment on column CMN_APP_INFO_ITSM.CBRCIMPORTANTSYSTEM
  is '银监会报送重要系统';
comment on column CMN_APP_INFO_ITSM.APPLICATEOPERATE
  is '是否应用接管';
comment on column CMN_APP_INFO_ITSM.OUTSOURCINGMARK
  is '应用外包参与标志';
comment on column CMN_APP_INFO_ITSM.NETWORKDOMAIN
  is '所属网络域';
comment on column CMN_APP_INFO_ITSM.TEAM
  is '应用团队组别';
comment on column CMN_APP_INFO_ITSM.OPERATEMANAGER
  is '运维经理';
comment on column CMN_APP_INFO_ITSM.APPLICATEMANAGERA
  is '应用管理员A';
comment on column CMN_APP_INFO_ITSM.APPLICATEMANAGERB
  is '应用管理员B';
comment on column CMN_APP_INFO_ITSM.SYSTEMMANAGERA
  is '系统管理员A';
comment on column CMN_APP_INFO_ITSM.SYSTEMMANAGERB
  is '系统管理员B';
comment on column CMN_APP_INFO_ITSM.NETWORKMANAGERA
  is '网络管理员A';
comment on column CMN_APP_INFO_ITSM.NETWORKMANAGERB
  is '网络管理员B';
comment on column CMN_APP_INFO_ITSM.DBA
  is 'DBA管理员';
comment on column CMN_APP_INFO_ITSM.MIDDLEWAREMANAGER
  is '中间件管理员';
comment on column CMN_APP_INFO_ITSM.STOREMANAGER
  is '存储管理员';
comment on column CMN_APP_INFO_ITSM.PM
  is '项目负责人';
comment on column CMN_APP_INFO_ITSM.BUSINESSDEPARTMENT
  is '业务主管部门';
comment on column CMN_APP_INFO_ITSM.BUSINESSMANAGER
  is '业务负责人';
comment on column CMN_APP_INFO_ITSM.SERVICESUPPORTER
  is '服务支持人';
comment on column CMN_APP_INFO_ITSM.ISTESTCENTER
  is '是否测试中心接管';
comment on column CMN_APP_INFO_ITSM.ALLOTTESTMANAGER
  is '分配测试经理';
comment on column CMN_APP_INFO_ITSM.DELIVERYTESTMANAGER
  is '交付测试经理';
comment on column CMN_APP_INFO_ITSM.QUALITYMANAGER
  is '质量经理';
comment on column CMN_APP_INFO_ITSM.PERFORMANCETESTMANAG
  is '性能测试经理';
comment on column CMN_APP_INFO_ITSM.TRANSFERCOEFFICIENT
  is '功能表转化系数';
comment on column CMN_APP_INFO_ITSM.STAGE
  is '所处阶段';
comment on column CMN_APP_INFO_ITSM.BUSINESSINTRODUCTION
  is '业务功能介绍';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_APP_INFO_ITSM
  add constraint PK_CMN_APP_INFO_ITSM primary key (SYSTEMCODE)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
 -- Create table CMN_APP_CONF
create table CMN_APP_CONF
(
  ITSM_APPSYS_CODE     VARCHAR2(254) not null,
  MAOP_APPSYS_CODE     VARCHAR2(254) not null,
  AOP_FLAG             CHAR(1),
  LAST_SCAN_TIME       TIMESTAMP(6),
  DELETE_FLAG          CHAR(1),
  UPDATE_TIME          TIMESTAMP(6),
  UPDATE_BEFORE_RECORD VARCHAR2(3000)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    next 8
    minextents 1
    maxextents unlimited
  );
comment on table CMN_APP_CONF
  is 'ITSM同步应用系统附加配置表';
comment on column CMN_APP_CONF.ITSM_APPSYS_CODE
  is 'ITSM平台系统编号';
comment on column CMN_APP_CONF.MAOP_APPSYS_CODE
  is 'MAOP平台系统编号';
comment on column CMN_APP_CONF.AOP_FLAG
  is '自动化平台上线标示';
comment on column CMN_APP_CONF.LAST_SCAN_TIME
  is '上次扫描时间';
comment on column CMN_APP_CONF.DELETE_FLAG
  is '删除标示';
comment on column CMN_APP_CONF.UPDATE_TIME
  is '更新时间';
comment on column CMN_APP_CONF.UPDATE_BEFORE_RECORD
  is '更新前纪录';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CMN_APP_CONF
  add constraint KEY_CMN_APP_CONF primary key (ITSM_APPSYS_CODE)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- create view view v_cmn_app_info
-- 上线环境 conf.online_env as online_env（注：提交多环境代码时，视图中需增加该字段）
create or replace view v_cmn_app_info as
(
select info."SYSTEMCODE",info."SYSTEMNAME" as appsys_name,info."AFFECTSYSTEM" as systemname,info."EAPSSYSTEMNAME",info."ENGLISHCODE",info."AFFECTSYSTEM",info."BRANCH",info."KEY",info."STATUS",info."SECURITYLEVEL",info."SCOPE",info."SYSTEMPRO",info."ONLINEDATE",info."OUTLINEDATE",info."SERVERLEVEL",info."SYSTEMLEVEL",info."ISIMPORTANT",info."ISKEY",info."ISCORESYETEM",info."CBRCIMPORTANTSYSTEM",info."APPLICATEOPERATE",info."OUTSOURCINGMARK",info."NETWORKDOMAIN",info."TEAM",info."OPERATEMANAGER",info."APPLICATEMANAGERA",info."APPLICATEMANAGERB",info."SYSTEMMANAGERA",info."SYSTEMMANAGERB",info."NETWORKMANAGERA",info."NETWORKMANAGERB",info."DBA",info."MIDDLEWAREMANAGER",info."STOREMANAGER",info."PM",info."BUSINESSDEPARTMENT",info."BUSINESSMANAGER",info."SERVICESUPPORTER",info."ISTESTCENTER",info."ALLOTTESTMANAGER",info."DELIVERYTESTMANAGER",info."QUALITYMANAGER",info."PERFORMANCETESTMANAG",info."TRANSFERCOEFFICIENT",info."STAGE",info."BUSINESSINTRODUCTION" ,
       conf.maop_appsys_code as appsys_code,
       conf.aop_flag as aop_flag,
       conf.last_scan_time as last_scan_time,
       conf.delete_flag as delete_flag,
       conf.update_time as update_time,
       conf.update_before_record as update_before_record,
       conf.online_env as online_env,
       conf.sync_type as sync_type
from  cmn_app_info_itsm info ,cmn_app_conf conf
where conf.itsm_appsys_code = info.systemcode
);

-- Create table
create table DPLY_PARAM_INFO
(
  DPLY_PARAM_CODE  VARCHAR2(100) not null,
  IMPORTANCE_LEVEL VARCHAR2(100) not null,
  APPSYS_CODE      VARCHAR2(100) not null,
  INSTANCE_VALUE   VARCHAR2(100)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table DPLY_PARAM_INFO
  add primary key (DPLY_PARAM_CODE, IMPORTANCE_LEVEL, APPSYS_CODE)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
  
  
  -- Create table
create table APPLICATION_PROCESS_RECORDS
(
  RECORD_ID           VARCHAR2(30) not null,
  SUBJECT_INFO        VARCHAR2(50) not null,
  HANDLED_USER        VARCHAR2(30),
  COMPLETED_TIME      TIMESTAMP(6),
  APPLICATION_USER    VARCHAR2(30) not null,
  APPLICATION_TIME    TIMESTAMP(6) not null,
  CURRENT_STATE       VARCHAR2(20) not null,
  APPLICATION_REASONS VARCHAR2(2000),
  PROCESS_DESCRIPTION VARCHAR2(2000),
  DELETE_FLAG         CHAR(1),
  HANDLED_TIME        TIMESTAMP(6),
  COMPLETED_USER      VARCHAR2(30)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column APPLICATION_PROCESS_RECORDS.RECORD_ID
  is '流水号';
comment on column APPLICATION_PROCESS_RECORDS.SUBJECT_INFO
  is '主题信息';
comment on column APPLICATION_PROCESS_RECORDS.HANDLED_USER
  is '处理人';
comment on column APPLICATION_PROCESS_RECORDS.COMPLETED_TIME
  is '完成时间';
comment on column APPLICATION_PROCESS_RECORDS.APPLICATION_USER
  is '申请人';
comment on column APPLICATION_PROCESS_RECORDS.APPLICATION_TIME
  is '申请时间';
comment on column APPLICATION_PROCESS_RECORDS.CURRENT_STATE
  is '当前状态';
comment on column APPLICATION_PROCESS_RECORDS.APPLICATION_REASONS
  is '申请原因';
comment on column APPLICATION_PROCESS_RECORDS.PROCESS_DESCRIPTION
  is '流程描述';
comment on column APPLICATION_PROCESS_RECORDS.DELETE_FLAG
  is '删除标示';
-- Create/Recreate primary, unique and foreign key constraints 
alter table APPLICATION_PROCESS_RECORDS
  add constraint APPLICATION_PROCESS_RECOR_PK primary key (RECORD_ID)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


-- Create table
create table APPLICATION_SYSTEM_AUTH
(
  RECORD_ID                VARCHAR2(30),
  APPLICATION_USER         VARCHAR2(30),
  APPSYS_CODE              VARCHAR2(20),
  APPLICATION_AUTY_DPLY    CHAR(1),
  APPLICATION_AUTH_TOOLBOX CHAR(1),
  APPLICATION_AUTH_CHECK   CHAR(1)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column APPLICATION_SYSTEM_AUTH.RECORD_ID
  is '申请单号';
comment on column APPLICATION_SYSTEM_AUTH.APPLICATION_USER
  is '用户';
comment on column APPLICATION_SYSTEM_AUTH.APPSYS_CODE
  is '系统';
comment on column APPLICATION_SYSTEM_AUTH.APPLICATION_AUTY_DPLY
  is '应用发布权限';
comment on column APPLICATION_SYSTEM_AUTH.APPLICATION_AUTH_TOOLBOX
  is '工具箱权限';
comment on column APPLICATION_SYSTEM_AUTH.APPLICATION_AUTH_CHECK
  is '巡检权限';


-- Create table
create table OCCAS_SERVERS_INFO
(
  RECORD_ID            VARCHAR2(30) not null,
  SERVER_IP            VARCHAR2(20) not null,
  SERVER_NAME          VARCHAR2(30),
  APPSYS_CODE          VARCHAR2(10) not null,
  BSA_AGENT_FLAG       CHAR(1),
  FLOATING_IP          VARCHAR2(200),
  SERVER_ROLE          VARCHAR2(20),
  SERVER_USE           VARCHAR2(20),
  MACHINEROOM_POSITION VARCHAR2(30),
  OS_TYPE              VARCHAR2(100),
  ENVIRONMENT_TYPE     VARCHAR2(30),
  DATA_TYPE            CHAR(1),
  DELETE_FLAG          CHAR(1),
  UPDATE_TIME          TIMESTAMP(6),
  UPDATE_BEFORE_RECORD VARCHAR2(500),
  MW_TYPE              VARCHAR2(30),
  DB_TYPE              VARCHAR2(30),
  COLLECTION_STATE     VARCHAR2(10),
  ATTR_FLAG            CHAR(1)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 256K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table OCCAS_SERVERS_INFO
  add primary key (RECORD_ID, APPSYS_CODE, SERVER_IP)
  using index 
  tablespace MAOP
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

  
  -- Create table
  create table SUGGESTION_BOX
(
  SBOX_ID NUMBER NOT NULL PRIMARY KEY,
  SBOX_INITIATOR VARCHAR2(10) NOT NULL,
  SBOX_VALUE VARCHAR2(1000) NOT NULL,
  SBOX_TIME TIMESTAMP(6) NOT NULL,
  SBOX_STATENUM VARCHAR2(10) NOT NULL,
  SBOX_CONFIRM_USER VARCHAR2(10),
  SBOX_CONFIRM_TIME TIMESTAMP(6),
  SBOX_REJECT_USER VARCHAR2(10),
  SBOX_REJECT_TIME TIMESTAMP(6)
)
tablespace MAOP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

  
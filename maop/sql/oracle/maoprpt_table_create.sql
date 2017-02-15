
drop view V_CMN_APP_SERVER;
  CREATE OR REPLACE FORCE VIEW MAOPRPT.V_CMN_APP_SERVER (SERVER_GROUP, SERVER_IP, APPSYS_CODE, SERVER_NAME, BSA_AGENT_FLAG, FLOATING_IP, SERVER_ROLE, SERVER_USE, MACHINEROOM_POSITION, OS_TYPE, ENVIRONMENT_TYPE, DATA_TYPE, DELETE_FLAG, UPDATE_TIME, UPDATE_BEFORE_RECORD, MW_TYPE, DB_TYPE, COLLECTION_STATE, ATTR_FLAG) AS 
  select DISTINCT t1.server_group ,
    t2.SERVER_IP,
    t2.APPSYS_CODE,
    t2.SERVER_NAME,
    t2.BSA_AGENT_FLAG ,
    t2.FLOATING_IP,
    t2.SERVER_ROLE ,
    t2.SERVER_USE ,
    t2.MACHINEROOM_POSITION ,
    t2.OS_TYPE ,
    t2.ENVIRONMENT_TYPE ,
    t2.DATA_TYPE ,
    t2.DELETE_FLAG ,
    t2.UPDATE_TIME ,
    t2.UPDATE_BEFORE_RECORD ,
    t2.MW_TYPE ,
    t2.DB_TYPE ,
    t2.COLLECTION_STATE ,
    t2.ATTR_FLAG
  from cmn_app_group_server@DB_JEDA_LINK t1
  LEFT join cmn_servers_info@DB_JEDA_LINK t2
  on t1.appsys_code   =t2.appsys_code
  and t1.server_ip    =t2.server_ip
  where t1.delete_flag='0'
  and t2.delete_flag  ='0';

drop view v_cmn_app_info ;
drop table CHECK_COMPLIANCE_RESULT_INFO;

/*========================10.200.36.221DEV环境START=================*/
/*==============================================================*/
/* DBLINK: DB_BBSA_LINK BBSA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_BBSA_LINK
  connect to BLADELOGIC identified BY BLADELOGIC
  using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.220)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/*==============================================================*/
/* DBLINK: DB_JEDA_LINK JEDA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_JEDA_LINK
  connect to MAOP identified BY maop
using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.220)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/**********************10.200.36.221DEV环境END******************/


/*========================10.200.36.192DEV环境START=================*/
/*==============================================================*/
/* DBLINK: DB_BBSA_LINK BBSA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_BBSA_LINK
  connect to BLADELOGIC identified BY BLADELOGIC
  using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.222)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/*==============================================================*/
/* DBLINK: DB_JEDA_LINK JEDA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_JEDA_LINK
  connect to MAOP identified BY maop
using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.222)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/**********************10.200.36.192DEV环境END******************/


/*========================10.200.36.225DEV环境START=================*/
/*==============================================================*/
/* DBLINK: DB_BBSA_LINK BBSA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_BBSA_LINK
  connect to BLADELOGIC identified BY BLADELOGIC
  using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.87)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/*==============================================================*/
/* DBLINK: DB_JEDA_LINK JEDA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_JEDA_LINK
  connect to MAOP identified BY maop
using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.200.36.87)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/**********************10.200.36.225DEV环境END******************/


/**********************10.1.7.135PROD环境START*******************/
/*==============================================================*/
/* DBLINK: DB_BBSA_LINK BBSA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_BBSA_LINK
  connect to BLADELOGIC identified BY BLADELOGIC
  using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.7.135)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';

/*==============================================================*/
/* DBLINK: DB_JEDA_LINK JEDA数据库LINK                  */
/*==============================================================*/
-- Create database link 
create database link DB_JEDA_LINK
  connect to MAOP identified BY maop
  using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.7.135)(PORT = 1521))
)
  (CONNECT_DATA =
      (SID = MAOP)
      (SERVER = DEDICATED)
  )
)';
/**********************10.1.7.135生产环境END*******************/


/*==============================================================*/
/* Table: CHECK_COMPLIANCE_BATCH_CONFIG合规巡检数据批量同步配置表 */
/*==============================================================*/
-- Create table
create table CHECK_COMPLIANCE_BATCH_CONFIG
(
  LAST_SYNCHRONIZE_TIME TIMESTAMP(6) not null
);
comment on table CHECK_COMPLIANCE_BATCH_CONFIG is '合规巡检数据批量同步配置';
comment on column CHECK_COMPLIANCE_BATCH_CONFIG.LAST_SYNCHRONIZE_TIME
  is '最后同步时间 YYYYMMDD HH:MM:SS';

/*==============================================================*/
/* Table: CHECK_COMPLIANCE_RESULT_INFO 合规巡检结果详细表 */
/*==============================================================*/
-- Create table
create table CHECK_COMPLIANCE_RESULT_INFO
(
   APPSYS_CODE                VARCHAR2(10) not null,
  JOB_CODE_JEDA              NUMBER(8) not null,
  JOB_ID                     NUMBER(38) not null,
  JOB_NAME_BSA               VARCHAR2(30) not null,
  JOB_PATH                   VARCHAR2(100) not null,
  TEMPLATE_ID                NUMBER(38) not null,
  TEMPLATE_NAME              VARCHAR2(30) not null,
  TEMPLATE_PATH              VARCHAR2(100) not null,
  RULE_NAME                  VARCHAR2(255) not null,
  RULE_STRING                VARCHAR2(2000) not null,
  EXTEND_OBJECT              VARCHAR2(255),
  SERVER_NAME                VARCHAR2(30) not null,
  SERVER_IP                  VARCHAR2(20) not null,
  OS_NAME                    VARCHAR2(255),
  RESULT_ID                  NUMBER(38) not null,
  IS_CONSISTENT              NUMBER(1) not null,
  IS_INCONSISTENT            NUMBER(1) not null,
  RULE_RESULT_STRING         VARCHAR2(2000),
  SUB_ITEM_DETAIL            VARCHAR2(1000);
  RULE_DATE                  TIMESTAMP(6) not null,
  START_DATETIME             TIMESTAMP(6) not null,
  END_DATETIME               TIMESTAMP(6) not null,
  JOB_IS_ERRORS              NUMBER(1) not null,
  JOB_ERRORS_MESSAGE         VARCHAR2(4000),
  INCONSISTENT_HANDLE_DESC   VARCHAR2(1000),
  INCONSISTENT_HANDLE_STATUS NUMBER(1),
  INCONSISTENT_HANDLE_RESULT VARCHAR2(1000),
  INCONSISTENT_HANDLE_DATE   TIMESTAMP(6),
  INCONSISTENT_HANDLE_USER   VARCHAR2(100),
  DATE_CREATED               TIMESTAMP(6) not null
)
tablespace MAOPRPT;
comment on table CHECK_COMPLIANCE_RESULT_INFO
  is '合规巡检结果详细表';
-- Create/Recreate primary, unique and foreign key constraints
alter table CHECK_COMPLIANCE_RESULT_INFO
  add constraint PK_CHECK_COMPLIANCE_RESULT primary key (APPSYS_CODE, JOB_CODE_JEDA, JOB_NAME_BSA, JOB_PATH, TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_PATH, RULE_NAME, RULE_STRING, SERVER_NAME, SERVER_IP, RESULT_ID, JOB_ID)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* VIEW: v_cmn_servers_info JEDA服务器表视图            */
/*==============================================================*/
-- Create View
create or replace view v_cmn_servers_info as
select t.SERVER_IP,
       t.SERVER_NAME,
       t.APPSYS_CODE,
       t.BSA_AGENT_FLAG,
       t.FLOATING_IP,
       t.SERVER_ROLE,
       t.SERVER_USE,
       t.MACHINEROOM_POSITION,
       t.OS_TYPE,
       t.ENVIRONMENT_TYPE,
       t.DELETE_FLAG,
       t.UPDATE_TIME,
       t.UPDATE_BEFORE_RECORD
from cmn_servers_info@DB_JEDA_LINK t;

/*==============================================================*/
/* VIEW: v_check_job_jeda_info JEDA巡检作业信息表视图                 */
/*==============================================================*/
-- Create View
create or replace view v_check_job_info as
select t.APPSYS_CODE,
  t.JOB_CODE,
  t.CHECK_TYPE,
  t.AUTHORIZE_LEVEL_TYPE,
  t.FIELD_TYPE,
  t.JOB_NAME,
  t.JOB_PATH,
  t.JOB_TYPE,
  t.JOB_DESC,
  t.TOOL_STATUS,
  t.FRONTLINE_FLAG,
  t.AUTHORIZE_FLAG,
  t.DELETE_FLAG,
  t.TOOL_CREATOR,
  t.SCRIPT_NAME,
  t.EXEC_PATH,
  t.EXEC_USER,
  t.EXEC_USER_GROUP,
  t.LANGUAGE_TYPE
from CHECK_JOB_INFO@DB_JEDA_LINK t;
/*==============================================================*/
/* VIEW: v_check_job_bsa_info JEDABSA巡检作业信息表视图          */
/*==============================================================*/
-- Create View
create or replace view v_check_job_template as
select t.APPSYS_CODE,
       t.JOB_CODE,
       t.TEMPLATE_NAME,
       t.TEMPLATE_PATH
from CHECK_JOB_TEMPLATE@DB_JEDA_LINK t;

/*==============================================================*/
/* VIEW: v_compliance_result_for_maopBSA合规巡检结果视图            */
/*==============================================================*/
-- Create View
create or replace view v_compliance_result_for_maop
(job_id, job_name, full_path, template_id, template_name, result_id, run_id, job_start_time, job_end_time, job_is_errors, job_errors_message, component_id, component_version_id, component_name, device_name, ip_address, os_id, os_name, compliance_rule_id, rule_name, rule_string, compliance_rule_result_id, is_consistent, is_inconsistent, rule_check_date, rule_result_string)
as
select t.job_id as job_id, --作业编号
                t.name as job_name, --作业名称
                t.path as path, --作业的全路径
                template.template_id as template_id,  --模板ID
                template.name as template_name,  --模板名称
                job_result.result_id, --作业执行结果ID
                job_result.job_run_id as run_id, --作业执行结果的执行编号                job_run.start_time as job_start_time,--作业的执行开始日期                job_run.end_time as job_end_time,--作业的执行结束日期                job_run.is_errors as job_is_errors, --作业执行结果状态                case
         when job_run.is_errors = 1 then
          to_char((select to_char(substr(wm_concat(to_char(job_run_event.message)),0,4000))
             from job_run_event@DB_BBSA_LINK job_run_event
            where job_run.job_run_id = job_run_event.job_run_id
              and job_run.job_version_id = job_run_event.job_version_id
              and job_run_event.event_type_id != -2
    group by job_run_event.job_id,job_run_event.job_run_id))
         else
          to_char('')
       end as job_errors_message,
                --progress_status.name as job_status,  --作业执行过程状态                --job_run_event.event_type_id as job_run_event_type, --作业中多个事件作业执行结果状态                --job_run_event.message as job_run_message, --作业中多个事件作业执行结果信息                result_component.component_id, --组件编号
                result_component.component_version_id,  --组件版本号                component.name as component_name, --组件名称
                device.name as device_name, --主机名                device.ip_address as ip_address, --主机IP
                os.os_id as os_id, --操作系统id
                os.name as os_name, --操作系统名称
                rule_result.compliance_rule_id,  --巡检项编号                compliance_rule.name as rule_name, --合规规则名称
                compliance_rule.rule_string as rule_string, --巡检项的合规规则 合规时显示                rule_result.compliance_rule_result_id, --必要值                rule_result.is_consistent, --合规值（1为合规）
                rule_result.is_inconsistent, --不合规值（1为不合规）                rule_result.result_date as rule_check_date, --巡检项的巡检时间点                rule_result.rule_result_string --巡检结果（合规时为空，不合规时为不合规结果）
  from (select job.job_id,job.job_version_id,job.name,blgroup.path
  from job@DB_BBSA_LINK job,
       object_type@DB_BBSA_LINK job_type,
       (select level,
               sys_connect_by_path(t.name, '/') as path,
               t.name,
               t.group_id,
               t.parent_group_id
          from blgroup@DB_BBSA_LINK t
         start with t.name = 'Jobs'
        connect by prior t.group_id = t.parent_group_id) blgroup
 where job.object_type_id = job_type.object_type_id
   and job.is_latest_version = 1
   and job.is_deleted = 0
   and job_type.name = 'Compliance Job'
   and blgroup.group_id = job.group_id) t,
       job_result@DB_BBSA_LINK job_result,
       job_run@DB_BBSA_LINK job_run,
       --job_run_event@DB_BBSA_LINK job_run_event,
       --progress_status@DB_BBSA_LINK progress_status,
       job_result_component@DB_BBSA_LINK result_component,
       component@DB_BBSA_LINK component,
       template@DB_BBSA_LINK template,
       device@DB_BBSA_LINK device,
       os@DB_BBSA_LINK os,
       compliance_rule_result@DB_BBSA_LINK rule_result,
       compliance_rule@DB_BBSA_LINK compliance_rule,
       JOB_RESULT_CR_GROUP_RESULT@DB_BBSA_LINK JOB_RESULT_CR_GROUP_RESULT,
       COMP_RULE_GROUP_RULE_RESULT@DB_BBSA_LINK COMP_RULE_GROUP_RULE_RESULT
 where job_result.result_id = result_component.result_id
   and result_component.component_id = component.component_id
   and result_component.component_version_id = component.component_version_id
   and component.device_id = device.device_id
   and device.os_id = os.os_id
   and component.template_id = template.template_id
   and component.template_version_id = template.template_version_id
   and component.component_id = rule_result.component_id
   and rule_result.compliance_rule_id = compliance_rule.compliance_rule_id
   and compliance_rule.is_latest_version = 1
   --and job_run.progress_status_id = progress_status.progress_status_id
   --and job_run.job_run_id = job_run_event.job_run_id
   --and job_run.job_version_id = job_run_event.job_version_id
   and job_result.job_run_id = job_run.job_run_id
   and job_result.job_version_id = job_run.job_version_id
   and t.job_version_id = job_result.job_version_id
   and t.job_id = job_result.job_id
            and COMP_RULE_GROUP_RULE_RESULT.COMPLIANCE_RULE_RESULT_ID = rule_result.COMPLIANCE_RULE_RESULT_ID
   and JOB_RESULT_CR_GROUP_RESULT.CR_GROUP_RESULT_ID = COMP_RULE_GROUP_RULE_RESULT.CR_GROUP_RESULT_ID
   and JOB_RESULT_CR_GROUP_RESULT.RESULT_ID = job_result.result_id
   and job_result.is_deleted = 0
   and result_component.is_deleted = 0
   and component.is_deleted = 0
   and compliance_rule.is_deleted = 0
   and component.is_valid = 1;
  
/*==============================================================*/
/* VIEW: v_cmn_app_info 应用视图            */
/*==============================================================*/
-- Create View
create or replace view v_cmn_app_info as
select * from V_CMN_APP_INFO@DB_JEDA_LINK;

-- 报表定制 begin
drop table JEDA_COLUMN;
/*==============================================================*/
/* Table: JEDA_COLUMN 查询字段表 */
/*==============================================================*/
-- Create table
create table JEDA_COLUMN
(
  COLUMN_CODE    NUMBER(8) not null,
  COLUMN_EN_NAME VARCHAR2(100),
  COLUMN_CH_NAME VARCHAR2(200),
  COLUMN_DESC    VARCHAR2(500),
  DELETE_FLAG    VARCHAR2(1),
  IS_TRANS       VARCHAR2(1),
  DIC_CODE       VARCHAR2(50)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_COLUMN
  add constraint PK_JEDA_REPORT_COLUMN primary key (COLUMN_CODE)
  using index 
  tablespace MAOPRPT;

drop table JEDA_EXCEL_TEMPLATE;
/*==============================================================*/
/* Table: JEDA_EXCEL_TEMPLATE 报表Excel导出模板关联表 */
/*==============================================================*/
-- Create table
create table JEDA_EXCEL_TEMPLATE
(
  TEMPLATE_CODE    NUMBER(8) not null,
  REPORT_CODE      NUMBER(8),
  TEMPLATE_EN_NAME VARCHAR2(100),
  TEMPLATE_CH_NAME VARCHAR2(200),
  START_ROW_NUM    INTEGER,
  START_COL_NUM    INTEGER,
  DELETE_FLAG      VARCHAR2(1)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_EXCEL_TEMPLATE
  add constraint PK_JEDA_EXCEL_TEMPLATE primary key (TEMPLATE_CODE)
  using index 
  tablespace MAOPRPT;

drop table JEDA_REPORT;
/*==============================================================*/
/* Table: JEDA_REPORT 报表定制表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT
(
  REPORT_CODE     NUMBER(8) not null,
  REPORT_TYPE     VARCHAR2(1),
  REPORT_NAME     VARCHAR2(100),
  REPORT_DESC     VARCHAR2(600),
  REPORT_SQL      CLOB,
  REPORT_CREATOR  VARCHAR2(6),
  REPORT_CREATED  TIMESTAMP(6),
  REPORT_MODIFIER VARCHAR2(6),
  REPORT_MODIFIED TIMESTAMP(6),
  DELETE_FLAG     VARCHAR2(1)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT
  add constraint PK_JEDA_REPORT primary key (REPORT_CODE)
  using index 
  tablespace MAOPRPT;  
  
drop table JEDA_REPORT_COLUMN;
/*==============================================================*/
/* Table: JEDA_REPORT_COLUMN 报表字段关联表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT_COLUMN
(
  COLUMN_CODE   NUMBER(8) not null,
  REPORT_CODE   NUMBER(8) not null,
  IS_VISIBLE    VARCHAR2(1),
  DEFAULT_VALUE VARCHAR2(200),
  COLUMN_WIDTH  VARCHAR2(6),
  COLUMN_SORT   VARCHAR2(3)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT_COLUMN
  add constraint PK_JEDA_REPORT_COLUMNS primary key (COLUMN_CODE, REPORT_CODE)
  using index 
  tablespace MAOPRPT;

drop table JEDA_REPORT_MENU;
/*==============================================================*/
/* Table: JEDA_REPORT_MENU 报表菜单关联表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT_MENU
(
  REPORT_CODE NUMBER(8) not null,
  PARENT_MENU VARCHAR2(60) not null
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT_MENU
  add constraint PK_JEDA_REPORT_MENU primary key (REPORT_CODE, PARENT_MENU)
  using index 
  tablespace MAOPRPT;

drop table JEDA_REPORT_PARAM;
/*==============================================================*/
/* Table: JEDA_REPORT_PARAM 报表参数表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT_PARAM
(
  PARAM_CODE    NUMBER(8) not null,
  REPORT_CODE   NUMBER(8),
  PARAM_EN_NAME VARCHAR2(100),
  PARAM_CH_NAME VARCHAR2(200),
  PARAM_TYPE    VARCHAR2(30),
  DEFAULT_VALUE VARCHAR2(200),
  DIC_CODE      VARCHAR2(50),
  DELETE_FLAG   VARCHAR2(1)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT_PARAM
  add constraint PK_JEDA_REPORT_PARAM primary key (PARAM_CODE)
  using index 
  tablespace MAOPRPT;
  
drop table JEDA_REPORT_ROLE;
/*==============================================================*/
/* Table: JEDA_REPORT_ROLE 报表角色关联表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT_ROLE
(
  REPORT_CODE NUMBER(8) not null,
  ROLE_CODE   VARCHAR2(50) not null
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT_ROLE
  add constraint PK_JEDA_REPORT_ROLE primary key (REPORT_CODE, ROLE_CODE)
  using index 
  tablespace MAOPRPT;
  
drop table JEDA_REPORT_RULE;
/*==============================================================*/
/* Table: JEDA_REPORT_RULE 报表规则关联表 */
/*==============================================================*/
-- Create table
create table JEDA_REPORT_RULE
(
  REPORT_CODE NUMBER(8) not null,
  RULE_CODE   NUMBER(8) not null
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_REPORT_RULE
  add constraint PK_JEDA_REPORT_RULE primary key (REPORT_CODE, RULE_CODE)
  using index 
  tablespace MAOPRPT;

drop table JEDA_RULE;
/*==============================================================*/
/* Table: JEDA_RULE 报表规则表 */
/*==============================================================*/
-- Create table
create table JEDA_RULE
(
  RULE_CODE     NUMBER(8) not null,
  RULE_EN_NAME  VARCHAR2(100),
  RULE_CH_NAME  VARCHAR2(200),
  RULE_DESC     VARCHAR2(600),
  RULE_CONTENT  VARCHAR2(2000),
  RULE_CREATOR  VARCHAR2(6),
  RULE_CREATED  TIMESTAMP(6),
  RULE_MODIFIER VARCHAR2(6),
  RULE_MODIFIED TIMESTAMP(6),
  DELETE_FLAG   VARCHAR2(1)
)
tablespace MAOPRPT;
-- Create/Recreate primary, unique and foreign key constraints 
alter table JEDA_RULE
  add constraint PK_JEDA_RULE primary key (RULE_CODE)
  using index 
  tablespace MAOPRPT;
  
-- Create sequence JEDA_COLUMN_SEQ
create sequence JEDA_COLUMN_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 100
cycle;

-- Create sequence JEDA_PARAM_SEQ
create sequence JEDA_PARAM_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 100
cycle;

-- Create sequence JEDA_REPORT_SEQ
create sequence JEDA_REPORT_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 100
cycle;

-- Create sequence JEDA_ROLE_SEQ
create sequence JEDA_ROLE_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 100
cycle;

-- Create sequence JEDA_TEMPLATE_SEQ
create sequence JEDA_TEMPLATE_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 100
cycle;
  
-- 报表定制 end

/*==============================================================*/
/* Table: CAP_THRESHOLD_ACQ 容量阀值配置信息表 */
/*==============================================================*/
-- Create table
prompt Created on 2014年4月9日 by user
set feedback off
set define off
drop table CAP_THRESHOLD_ACQ;
prompt Creating CAP_THRESHOLD_ACQ...
create table CAP_THRESHOLD_ACQ
(
  APL_CODE             	VARCHAR2(10) not null,
  CAPATICY_TYPE        	CHAR(1) not null,
  THRESHOLD_TYPE       	CHAR(1) not null,
  THRESHOLD_ITEM       	VARCHAR2(50) not null,
  BUSI_DEMAND          	VARCHAR2(300),
  THRESHOLD            	VARCHAR2(20) not null,
  THRESHOLD_DATE       	VARCHAR2(8) not null,
  THRESHOLD_FROM       	VARCHAR2(50) not null,
  THRESHOLD_CHECK_FALG 	CHAR(1),
  THRESHOLD_EXPLAIN    	VARCHAR2(300),
  ADDITIONAL_EXPLAIN   	VARCHAR2(300),
  THRESHOLD_CREATOR		VARCHAR2(50),
  THRESHOLD_CREATED     TIMESTAMP(6),
  THRESHOLD_MODIFIER    VARCHAR2(50),
  THRESHOLD_MODIFIED    TIMESTAMP(6)
)
tablespace MAOPRPT;
-- Add comments to the table 
comment on table CAP_THRESHOLD_ACQ
  is '容量阀值采集表';
-- Add comments to the columns
comment on column CAP_THRESHOLD_ACQ.APL_CODE
  is '系统编号';
comment on column CAP_THRESHOLD_ACQ.CAPATICY_TYPE
  is '容量类型.1:应用类, 2:系统类, 3:网络类';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_TYPE
  is '阀值类型.1.联机类, 2:批量类, 3:操作系统, 4:数据库, 5:中间件, 6:网络层, 7: web层, 8:其他';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_ITEM
  is '阀值科目名称';
comment on column CAP_THRESHOLD_ACQ.BUSI_DEMAND
  is '业务要求';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD
  is '阀值';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_DATE
  is '阀值获取日期';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_FROM
  is '阀值来源';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_CHECK_FALG
  is '阀值是否可检测,0：否、1：是';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_EXPLAIN
  is '阀值简要说明';
comment on column CAP_THRESHOLD_ACQ.ADDITIONAL_EXPLAIN
  is '补充说明';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_CREATOR
  is '阀值创建者';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_CREATED
  is '阀值创建时间';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_MODIFIER
  is '阀值修改者';
comment on column CAP_THRESHOLD_ACQ.THRESHOLD_MODIFIED
  is '阀值修改时间';
-- Create/Recreate primary, unique and foreign key constraints
alter table CAP_THRESHOLD_ACQ
  add constraint PK_RPT_APP_THRESHOLD primary key (APL_CODE, THRESHOLD_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: CAP_THRESHOLD_CHK_RESULT 容量阀值检查结果表 */
/*==============================================================*/
-- Create table
prompt Created on 2014年4月9日 by user
set feedback off
set define off
drop table CAP_THRESHOLD_CHK_RESULT;
prompt Creating CAP_THRESHOLD_CHK_RESULT...
create table CAP_THRESHOLD_CHK_RESULT
(
  APL_CODE             		VARCHAR2(10) not null,
  ITEM_CD_APP       		VARCHAR2(50) not null,
  DATETIME   				VARCHAR2(18) not null,
  ITEM_VALUE       			VARCHAR2(50) not null,
  EXCEED_THRESHOLD_PERCENT	VARCHAR2(20),
  THRESHOLD            		VARCHAR2(20) not null,
  THRESHOLD_DATE       		VARCHAR2(8),
  THRESHOLD_CREATOR			VARCHAR2(50),
  THRESHOLD_CREATED     	TIMESTAMP(6),
  THRESHOLD_MODIFIER    	VARCHAR2(50),
  THRESHOLD_MODIFIED    	TIMESTAMP(6)
)
tablespace MAOPRPT;
-- Add comments to the table 
comment on table CAP_THRESHOLD_CHK_RESULT
  is '容量阀值检查结果表';
-- Add comments to the columns
comment on column CAP_THRESHOLD_CHK_RESULT.APL_CODE
  is '系统编号';
comment on column CAP_THRESHOLD_CHK_RESULT.ITEM_CD_APP
  is '指标科目编码';
comment on column CAP_THRESHOLD_CHK_RESULT.DATETIME
  is '指标数据时间：yyyymmdd hh:mi:ss、yyyymmdd hh:mi:ss、yyyymmdd、yyyymm、yyyy';
comment on column CAP_THRESHOLD_CHK_RESULT.ITEM_VALUE
  is '指标科目数值';
comment on column CAP_THRESHOLD_CHK_RESULT.EXCEED_THRESHOLD_PERCENT
  is '指标数值超阀值占比';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD
  is '阀值';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD_DATE
  is '阀值获取日期';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD_CREATOR
  is '阀值创建者';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD_CREATED
  is '阀值创建时间';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD_MODIFIER
  is '阀值修改者';
comment on column CAP_THRESHOLD_CHK_RESULT.THRESHOLD_MODIFIED
  is '阀值修改时间';
-- Create/Recreate primary, unique and foreign key constraints
alter table CAP_THRESHOLD_CHK_RESULT
  add constraint PK_CAP_THRESHOLD_CHK_RESULT primary key (APL_CODE, ITEM_CD_APP, DATETIME)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_ITEM_BASE  一二级基础指标字典表*/
/*==============================================================*/
-- Create table
drop table RPT_ITEM_BASE;
prompt Creating RPT_ITEM_BASE...
create table RPT_ITEM_BASE
(
  ITEM_CD             	VARCHAR2(50) not null,
  PARENT_ITEM_CD      	VARCHAR2(50) not null,
  ITEM_NAME           	VARCHAR2(200),
  RELATION_TABLENAME  	VARCHAR2(200),
  ITEM_CREATOR    		VARCHAR2(50),
  ITEM_CREATED     		TIMESTAMP(6),
  ITEM_MODIFIER    	 	VARCHAR2(50),
  ITEM_MODIFIED     	TIMESTAMP(6)
)
tablespace MAOPRPT;
-- Add comments to the columns
comment on table RPT_ITEM_BASE
  is '一二级基础指标字典表';
comment on column RPT_ITEM_BASE.ITEM_CD
  is '指标编码';
comment on column RPT_ITEM_BASE.PARENT_ITEM_CD
  is '上级指标编码';
comment on column RPT_ITEM_BASE.ITEM_NAME
  is '指标名称';
comment on column RPT_ITEM_BASE.RELATION_TABLENAME
  is '指标所属表名称';
comment on column RPT_ITEM_BASE.ITEM_CREATOR
  is '指标创建者';
comment on column RPT_ITEM_BASE.ITEM_CREATED
  is '指标创建时间';
comment on column RPT_ITEM_BASE.ITEM_MODIFIER
  is '指标修改者';
comment on column RPT_ITEM_BASE.ITEM_MODIFIED
  is '指标修改时间';
-- Create/Recreate primary, unique and foreign key constraints 
alter table RPT_ITEM_BASE
  add constraint PK_RPT_ITEM_BASE primary key (ITEM_CD, PARENT_ITEM_CD)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_ITEM_APP  应用三级指标字典表*/
/*==============================================================*/
-- Create table
drop table RPT_ITEM_APP;
prompt Creating RPT_ITEM_APP...
create table RPT_ITEM_APP
(
  APL_CODE     				VARCHAR2(10) not null,
  ITEM_CD_LVL1  			VARCHAR2(60) not null,
  ITEM_CD_LVL2   			VARCHAR2(60) not null,
  ITEM_CD_APP  				VARCHAR2(60) not null,
  ITEM_APP_NAME    			VARCHAR2(200),
  ITEM_APP_STSTCS_PEAK_FLAG	CHAR(1) default 0 not null,
  EXPRESSION      			VARCHAR2(1000),
  ITEM_CREATOR    			VARCHAR2(50),
  ITEM_CREATED     			TIMESTAMP(6),
  ITEM_MODIFIER    	 		VARCHAR2(50),
  ITEM_MODIFIED     		TIMESTAMP(6)
)
tablespace MAOPRPT;
comment on table RPT_ITEM_APP
  is '应用三级指标字典表';
comment on column RPT_ITEM_APP.APL_CODE
  is '应用系统编号';
comment on column RPT_ITEM_APP.ITEM_CD_LVL1
  is '一级指标编码';
comment on column RPT_ITEM_APP.ITEM_CD_LVL2
  is '二级指标编码';
comment on column RPT_ITEM_APP.ITEM_CD_APP
  is '巡检指标编码';
comment on column RPT_ITEM_APP.ITEM_APP_NAME
  is '巡检指标名称';
comment on column RPT_ITEM_APP.ITEM_APP_STSTCS_PEAK_FLAG
  is '巡检指标是否统计峰值标识';
comment on column RPT_ITEM_APP.EXPRESSION
  is '巡检指标计算表达式';
comment on column RPT_ITEM_APP.ITEM_CREATOR
  is '巡检指标创建者';
comment on column RPT_ITEM_APP.ITEM_CREATED
  is '巡检指标创建时间';
comment on column RPT_ITEM_APP.ITEM_MODIFIER
  is '巡检指标修改者';
comment on column RPT_ITEM_APP.ITEM_MODIFIED
  is '巡检指标修改时间';
alter table RPT_ITEM_APP
  add constraint PK_RPT_ITEM_APP primary key (APL_CODE, ITEM_CD_APP)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: APL_ANALYZE  应用报表分析结果表*/
/*==============================================================*/
-- Create table
drop table APL_ANALYZE;
prompt Creating APL_ANALYZE...
create table APL_ANALYZE
(
  APL_CODE     VARCHAR2(10) not null,
  TRANS_DATE   VARCHAR2(10) not null,
  ANA_ITEM     VARCHAR2(100) not null,
  EXE_ANA_DESC VARCHAR2(1000),
  STATUS       CHAR(1) default 1 not null,
  ANA_USER     VARCHAR2(10),
  REV_USER     VARCHAR2(10),
  END_DATE     VARCHAR2(8),
  FILE_PATH    VARCHAR2(100),
  TRANS_TIME   VARCHAR2(10) not null,
  HANDLE_STATE CHAR(1)
)
tablespace MAOPRPT;
comment on table APL_ANALYZE
  is '应用系统运行分析表';
comment on column APL_ANALYZE.APL_CODE
  is '应用系统编号';
comment on column APL_ANALYZE.TRANS_DATE
  is '交易日期';
comment on column APL_ANALYZE.ANA_ITEM
  is '分析科目';
comment on column APL_ANALYZE.EXE_ANA_DESC
  is '运行情况分析描述';
comment on column APL_ANALYZE.STATUS
  is '运行状态，1：正常、2：异常';
comment on column APL_ANALYZE.ANA_USER
  is '分析人';
comment on column APL_ANALYZE.REV_USER
  is '审核人';
comment on column APL_ANALYZE.END_DATE
  is '完成日期';
comment on column APL_ANALYZE.FILE_PATH
  is '附件路径文件名';
comment on column APL_ANALYZE.TRANS_TIME
  is '交易时间';
comment on column APL_ANALYZE.HANDLE_STATE
  is '处理状态，0：未处理、1：正常、2：异常';
alter table APL_ANALYZE
  add constraint PK_APL_ANALYZE primary key (APL_CODE, TRANS_DATE, ANA_ITEM, TRANS_TIME)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: BATCH_TRANS 应用批量执行统计表 */
/*==============================================================*/
-- Create table
drop table BATCH_TRANS;
prompt Creating BATCH_TRANS...
create table BATCH_TRANS
(
  APL_CODE         VARCHAR2(10) not null,
  BATCH_DATE       CHAR(8) not null,
  BATCH_NAME       VARCHAR2(300) not null,
  BATCH_START_TIME CHAR(20),
  BATCH_END_TIME   CHAR(20),
  BATCH_EXE_TIME   VARCHAR2(5),
  END_FLG          CHAR(1),
  COMMENTS         VARCHAR2(100)
)
tablespace MAOPRPT; 
comment on table BATCH_TRANS
  is '应用批量执行统计表';
comment on column BATCH_TRANS.APL_CODE
  is '应用系统编号';
comment on column BATCH_TRANS.BATCH_DATE
  is '交易日期';
comment on column BATCH_TRANS.BATCH_NAME
  is '批量名称';
comment on column BATCH_TRANS.BATCH_START_TIME
  is '批量开始时间';
comment on column BATCH_TRANS.BATCH_END_TIME
  is '批量结束时间';
comment on column BATCH_TRANS.BATCH_EXE_TIME
  is '批量执行时间';
comment on column BATCH_TRANS.END_FLG
  is '正常结束标志';
comment on column BATCH_TRANS.COMMENTS
  is '备注';
alter table BATCH_TRANS
  add constraint PK_BATCH_TRANS primary key (APL_CODE, BATCH_DATE, BATCH_NAME)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: DATE_TRANS  日交易量统计表*/
/*==============================================================*/
-- Create table
drop table DATE_TRANS;
prompt Creating DATE_TRANS...
create table DATE_TRANS
(
  APL_CODE     		VARCHAR2(10) not null,
  TRANS_DATE   		VARCHAR2(8) not null,
  COUNT_ITEM   		VARCHAR2(300) not null,
  COUNT_AMOUNT 		VARCHAR2(18),
  DATASOURCE_FLAG 	CHAR(1) default 0 not null
)
tablespace MAOPRPT;
comment on table DATE_TRANS
  is '日交易量统计表';
comment on column DATE_TRANS.APL_CODE
  is '应用系统编号';
comment on column DATE_TRANS.TRANS_DATE
  is '交易日期';
comment on column DATE_TRANS.COUNT_ITEM
  is '统计科目';
comment on column DATE_TRANS.COUNT_AMOUNT
  is '统计数值';
comment on column DATE_TRANS.DATASOURCE_FLAG
  is '统计数据来源：0:sqlldr直接导入；1：表达式批量计算所得';
alter table DATE_TRANS
  add constraint PK_DATE_TRANS primary key (APL_CODE, TRANS_DATE, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: DATE_TRANS_TIME  日交易量多批次统计表*/
/*==============================================================*/
-- Create table
drop table DATE_TRANS_TIMES;
prompt Creating DATE_TRANS_TIMES...
create table DATE_TRANS_TIMES
(
  APL_CODE     		VARCHAR2(10) not null,
  TRANS_DATE   		VARCHAR2(8) not null,
  TRANS_TIME   		VARCHAR2(5) not null,
  COUNT_ITEM   		VARCHAR2(300) not null,
  COUNT_AMOUNT 		VARCHAR2(18),
  DATASOURCE_FLAG 	CHAR(1) default 0 not null
)
tablespace MAOPRPT;
comment on table DATE_TRANS_TIMES
  is '日交易量多批次统计表';
comment on column DATE_TRANS_TIMES.APL_CODE
  is '应用系统编号';
comment on column DATE_TRANS_TIMES.TRANS_DATE
  is '交易日期';
comment on column DATE_TRANS_TIMES.TRANS_TIME
  is '交易时间';
comment on column DATE_TRANS_TIMES.COUNT_ITEM
  is '统计科目';
comment on column DATE_TRANS_TIMES.COUNT_AMOUNT
  is '统计数值';
comment on column DATE_TRANS_TIMES.DATASOURCE_FLAG
  is '统计数据来源：0:sqlldr直接导入；1：表达式批量计算所得';
alter table DATE_TRANS_TIMES
  add constraint PK_DATE_TRANS_TIMES primary key (APL_CODE, TRANS_DATE, TRANS_TIME, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: FIVE_MIN_TRANS  五分钟交易量统计表*/
/*==============================================================*/
-- Create table
drop table FIVE_MIN_TRANS;
prompt Creating FIVE_MIN_TRANS...
create table FIVE_MIN_TRANS
(
  APL_CODE     VARCHAR2(10) not null,
  TRANS_DATE   CHAR(8) not null,
  TRANS_NAME   VARCHAR2(300) not null,
  MIN_POINT    VARCHAR2(5) not null,
  COUNT_AMOUNT VARCHAR2(10)
)
partition by range (TRANS_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table FIVE_MIN_TRANS
  is '五分钟交易量统计表';
alter table FIVE_MIN_TRANS
  add constraint PK_FIVE_MIN_TRANS primary key (APL_CODE, TRANS_DATE, TRANS_NAME, MIN_POINT)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_FIVE_MIN_TRANS_01 on FIVE_MIN_TRANS (APL_CODE, TRANS_DATE, MIN_POINT)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: FIVE_MIN_TRANS_AVE_MON 五分钟交易量月平均值 */
/*==============================================================*/
-- Create table
drop table FIVE_MIN_TRANS_AVE_MON;
prompt Creating FIVE_MIN_TRANS_AVE_MON...
create table FIVE_MIN_TRANS_AVE_MON
(
  APL_CODE     VARCHAR2(10) not null,
  TRANS_MONTH  CHAR(6) not null,
  TRANS_NAME   VARCHAR2(300) not null,
  MIN_POINT    CHAR(5) not null,
  HOLIDAY_FLAG CHAR(1) not null,
  COUNT_AMOUNT VARCHAR2(10)
)
tablespace MAOPRPT;
comment on table FIVE_MIN_TRANS_AVE_MON
  is '五分钟交易量月平均值统计表';
comment on column FIVE_MIN_TRANS_AVE_MON.APL_CODE
  is '应用系统编号';
comment on column FIVE_MIN_TRANS_AVE_MON.TRANS_MONTH
  is '交易月份';
comment on column FIVE_MIN_TRANS_AVE_MON.TRANS_NAME
  is '交易名称';
comment on column FIVE_MIN_TRANS_AVE_MON.MIN_POINT
  is '五分钟时间段';
comment on column FIVE_MIN_TRANS_AVE_MON.HOLIDAY_FLAG
  is '休日区分';
comment on column FIVE_MIN_TRANS_AVE_MON.COUNT_AMOUNT
  is '交易量';
alter table FIVE_MIN_TRANS_AVE_MON
  add constraint PK_FIVE_MIN_TRANS_AVE_MON primary key (APL_CODE, TRANS_MONTH, TRANS_NAME, MIN_POINT, HOLIDAY_FLAG)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: HOURS_TRANS 小时交易量统计表 */
/*==============================================================*/
-- Create table
drop table HOURS_TRANS;
prompt Creating HOURS_TRANS...
create table HOURS_TRANS
(
  APL_CODE        	VARCHAR2(10) not null,
  TRANS_DATE      	VARCHAR2(8) not null,
  COUNT_HOUR_TIME 	VARCHAR2(2) not null,
  COUNT_ITEM   		VARCHAR2(300) not null,
  COUNT_AMOUNT    	VARCHAR2(18)
)
tablespace MAOPRPT;
comment on table HOURS_TRANS
  is '小时交易量统计表';
comment on column HOURS_TRANS.APL_CODE
  is '应用系统编号';
comment on column HOURS_TRANS.TRANS_DATE
  is '交易日期';
comment on column HOURS_TRANS.COUNT_HOUR_TIME
  is '统计小时';
comment on column HOURS_TRANS.COUNT_ITEM
  is '统计科目';
comment on column HOURS_TRANS.COUNT_AMOUNT
  is '统计数值';
alter table HOURS_TRANS
  add constraint PK_HOURS_TRANS primary key (APL_CODE, TRANS_DATE, COUNT_HOUR_TIME, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: MONTH_RESOURCE 资源使用月统计表 */
/*==============================================================*/
-- Create table
drop table MONTH_RESOURCE;
prompt Creating MONTH_RESOURCE...
create table MONTH_RESOURCE
(
  APL_CODE            VARCHAR2(10) not null,
  COUNT_MONTH         CHAR(6) not null,
  SRV_CODE            VARCHAR2(50) not null,
  CPU_PEAK            VARCHAR2(5),
  CPU_ONLINE_PEAK_AVG VARCHAR2(5),
  CPU_BATCH_PEAK_AVG  VARCHAR2(5),
  MEM_PEAK            VARCHAR2(5),
  MEM_ONLINE_PEAK_AVG VARCHAR2(5),
  MEM_BATCH_PEAK_AVG  VARCHAR2(5),
  IO_PEAK             VARCHAR2(5),
  IO_ONLINE_PEAK_AVG  VARCHAR2(5),
  IO_BATCH_PEAK_AVG   VARCHAR2(5)
)
tablespace MAOPRPT;
comment on table MONTH_RESOURCE
  is '资源使用月统计表';
comment on column MONTH_RESOURCE.APL_CODE
  is '应用系统编号';
comment on column MONTH_RESOURCE.COUNT_MONTH
  is '统计月份';
comment on column MONTH_RESOURCE.SRV_CODE
  is '服务器编号（IP）';
comment on column MONTH_RESOURCE.CPU_PEAK
  is 'CPU月峰值';
comment on column MONTH_RESOURCE.CPU_ONLINE_PEAK_AVG
  is 'CPU联机峰值月均值';
comment on column MONTH_RESOURCE.CPU_BATCH_PEAK_AVG
  is 'CPU批量峰值月均值';
comment on column MONTH_RESOURCE.MEM_PEAK
  is '内存月峰值';
comment on column MONTH_RESOURCE.MEM_ONLINE_PEAK_AVG
  is '内存联机峰值月均值';
comment on column MONTH_RESOURCE.MEM_BATCH_PEAK_AVG
  is '内存批量峰值月均值';
comment on column MONTH_RESOURCE.IO_PEAK
  is 'IO月峰值';
comment on column MONTH_RESOURCE.IO_ONLINE_PEAK_AVG
  is 'IO联机峰值月均值';
comment on column MONTH_RESOURCE.IO_BATCH_PEAK_AVG
  is 'IO批量峰值月均值';
alter table MONTH_RESOURCE
  add constraint PK_MONTH_RESOURCE primary key (APL_CODE, COUNT_MONTH, SRV_CODE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: TIMES_TRANS 天分钟和秒交易情况统计表 */
/*==============================================================*/
-- Create table
drop table TIMES_TRANS;
prompt Creating TIMES_TRANS...
create table TIMES_TRANS
(
  APL_CODE     VARCHAR2(10) not null,
  TRANS_DATE   VARCHAR2(8) not null,
  COUNT_ITEM   VARCHAR2(300) not null,
  COUNT_AMOUNT VARCHAR2(18)
)
tablespace MAOPRPT;
comment on table TIMES_TRANS
  is '天分钟和秒交易情况统计表';
comment on column TIMES_TRANS.APL_CODE
  is '应用系统编号';
comment on column TIMES_TRANS.TRANS_DATE
  is '交易日期';
comment on column TIMES_TRANS.COUNT_ITEM
  is '统计科目';
comment on column TIMES_TRANS.COUNT_AMOUNT
  is '统计数值';
alter table TIMES_TRANS
  add constraint PK_TIMES_TRANS primary key (APL_CODE, TRANS_DATE, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: MONTH_TIMES_TRANS 分钟和秒交易量峰值月统计表 */
/*==============================================================*/
-- Create table
drop table MONTH_TIMES_TRANS;
prompt Creating MONTH_TIMES_TRANS...
create table MONTH_TIMES_TRANS
(
  APL_CODE    VARCHAR2(10) not null,
  PEAK_DATE   VARCHAR2(8) not null,
  PEAK_VALUE  VARCHAR2(20),
  COUNT_MONTH VARCHAR2(6) not null,
  PEAK_ITEM   VARCHAR2(50) not null
)
tablespace MAOPRPT;
comment on table MONTH_TIMES_TRANS
  is '分钟和秒交易量峰值月统计表';
comment on column MONTH_TIMES_TRANS.APL_CODE
  is '应用系统编号';
comment on column MONTH_TIMES_TRANS.PEAK_DATE
  is '交易日期';
comment on column MONTH_TIMES_TRANS.PEAK_VALUE
  is '科目名对应的值';
comment on column MONTH_TIMES_TRANS.COUNT_MONTH
  is '统计月份';
comment on column MONTH_TIMES_TRANS.PEAK_ITEM
  is '科目名';
alter table MONTH_TIMES_TRANS
  add constraint PK_MONTH_TIMES_TRANS primary key (APL_CODE, COUNT_MONTH, PEAK_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;
alter table MONTH_TIMES_TRANS
  add constraint FK_MONTH_TIMES_TRANS foreign key (APL_CODE, PEAK_DATE, PEAK_ITEM)
  references TIMES_TRANS (APL_CODE, TRANS_DATE, COUNT_ITEM);

/*==============================================================*/
/* Table: MONTH_TRAN 交易量月统计表 */
/*==============================================================*/
-- Create table
drop table MONTH_TRAN;
prompt Creating MONTH_TRAN...
create table MONTH_TRAN
(
  APL_CODE          VARCHAR2(10) not null,
  COUNT_MONTH       VARCHAR2(6) not null,
  DAY_AVG_TRANS     VARCHAR2(18),
  WORKDAY_AVG_TRANS VARCHAR2(18),
  HOLIDAY_AVG_TRANS VARCHAR2(18),
  MONTH_PEAK_TRANS  VARCHAR2(18),
  MONTH_TOTAL_TRANS VARCHAR2(18)
)
tablespace MAOPRPT;
comment on table MONTH_TRAN
  is '交易量月统计表';
comment on column MONTH_TRAN.APL_CODE
  is '应用系统编号';
comment on column MONTH_TRAN.COUNT_MONTH
  is '统计月份';
comment on column MONTH_TRAN.DAY_AVG_TRANS
  is '日均交易量';
comment on column MONTH_TRAN.WORKDAY_AVG_TRANS
  is '工作日日均交易量';
comment on column MONTH_TRAN.HOLIDAY_AVG_TRANS
  is '休息日日均交易量';
comment on column MONTH_TRAN.MONTH_PEAK_TRANS
  is '月峰值交易量';
comment on column MONTH_TRAN.MONTH_TOTAL_TRANS
  is '月总交易量';
alter table MONTH_TRAN
  add constraint PK_MONTH_TRAN primary key (APL_CODE, COUNT_MONTH)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: MULT_TRANS  多科目数据表*/
/*==============================================================*/
-- Create table
drop table MULT_TRANS;
prompt Creating MULT_TRANS...
create table MULT_TRANS
(
  APL_CODE   	VARCHAR2(10) not null,
  TRANS_DATE 	VARCHAR2(8) not null,
  DATA_NUM   	NUMBER(4) not null,
  COUNT_ITEM 	VARCHAR2(1000) not null,
  COUNT_VALUE 	VARCHAR2(1000) not null
)
tablespace MAOPRPT;
comment on table MULT_TRANS
  is '多科目数据表';
comment on column MULT_TRANS.APL_CODE
  is '应用系统编号';
comment on column MULT_TRANS.TRANS_DATE
  is '交易日期';
comment on column MULT_TRANS.DATA_NUM
  is '数据行号';
comment on column MULT_TRANS.COUNT_ITEM
  is '统计科目';
comment on column MULT_TRANS.COUNT_VALUE
  is '统计数值';
alter table MULT_TRANS
  add constraint PK_MULT_TRANS primary key (APL_CODE, TRANS_DATE, DATA_NUM, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: MULT_TRANS_ORIGINAL  多科目原始数据表*/
/*==============================================================*/
-- Create table
drop table MULT_TRANS_ORIGINAL;
prompt Creating MULT_TRANS_ORIGINAL...
create table MULT_TRANS_ORIGINAL
(
  APL_CODE   	VARCHAR2(10) not null,
  TRANS_DATE 	VARCHAR2(8) not null,
  DATA_NUM   	NUMBER(4) not null,
  COUNT_ITEM 	VARCHAR2(1000) not null
)
tablespace MAOPRPT;
comment on table MULT_TRANS_ORIGINAL
  is '多科目原始数据表';
comment on column MULT_TRANS_ORIGINAL.APL_CODE
  is '应用系统编号';
comment on column MULT_TRANS_ORIGINAL.TRANS_DATE
  is '交易日期';
comment on column MULT_TRANS_ORIGINAL.DATA_NUM
  is '数据行号';
comment on column MULT_TRANS_ORIGINAL.COUNT_ITEM
  is '统计科目';
alter table MULT_TRANS_ORIGINAL
  add constraint PK_MULT_TRANS_ORIGINAL primary key (APL_CODE, TRANS_DATE, DATA_NUM, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: NET_RESRC 五分钟网络资源统计表 */
/*==============================================================*/
-- Create table
drop table NET_RESRC;
prompt Creating NET_RESRC...
create table NET_RESRC
(
  APL_CODE      VARCHAR2(10) not null,
  SRV_CODE      VARCHAR2(20) not null,
  MONITOR_ITEM  VARCHAR2(30) not null,
  MONITOR_DATE  VARCHAR2(8) not null,
  MONITOR_TIME  VARCHAR2(5) not null,
  MONITOR_VALUE VARCHAR2(12)
)
partition by range (MONITOR_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201602 values less than ('20160201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201603 values less than ('20160301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201604 values less than ('20160401')
    tablespace MAOPRPT,
	partition ORD_ACT_PART201605 values less than ('20160501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201606 values less than ('20160601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201607 values less than ('20160701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201608 values less than ('20160801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201609 values less than ('20160901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201610 values less than ('20161001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201611 values less than ('20161101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201612 values less than ('20161201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201701 values less than ('20170101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table NET_RESRC
  is '五分钟网络资源统计表';
comment on column NET_RESRC.APL_CODE
  is '应用系统编号';
comment on column NET_RESRC.SRV_CODE
  is '服务器编号（IP）';
comment on column NET_RESRC.MONITOR_ITEM
  is '监控科目';
comment on column NET_RESRC.MONITOR_DATE
  is '监控日期';
comment on column NET_RESRC.MONITOR_TIME
  is '五分钟监控时间点';
comment on column NET_RESRC.MONITOR_VALUE
  is '实时监控值';
alter table NET_RESRC
  add constraint PK_NET_RESRC primary key (APL_CODE, SRV_CODE, MONITOR_ITEM, MONITOR_DATE, MONITOR_TIME)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_NET_RESRC_01 on NET_RESRC (APL_CODE, MONITOR_DATE, MONITOR_TIME)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: PEAK_ITEM 峰值统计信息表 */
/*==============================================================*/
-- Create table
drop table PEAK_ITEM;
prompt Creating PEAK_ITEM...
create table PEAK_ITEM
(
  APL_CODE   		VARCHAR2(10) not null,
  COUNT_ITEM 		VARCHAR2(300) not null,
  PEAK_DATE  		VARCHAR2(8) not null,
  PEAK_VALUE 		VARCHAR2(18),
  PEAK_PRE_DATE 	VARCHAR2(8),
  PEAK_PRE_VALUE 	VARCHAR2(18),
  PEAK_GROWTH_RATE 	VARCHAR2(18)
)
tablespace MAOPRPT;
comment on table PEAK_ITEM
  is '系统峰值统计表';
comment on column PEAK_ITEM.APL_CODE
  is '应用系统编号';
comment on column PEAK_ITEM.COUNT_ITEM
  is '统计科目';
comment on column PEAK_ITEM.PEAK_DATE
  is '峰值发生日期';
comment on column PEAK_ITEM.PEAK_VALUE
  is '峰值';
comment on column PEAK_ITEM.PEAK_PRE_DATE
  is '峰值上次发生日期';
comment on column PEAK_ITEM.PEAK_PRE_VALUE
  is '峰值上次数值';
comment on column PEAK_ITEM.PEAK_GROWTH_RATE
  is '峰值环比增长率:(本期指标值-上期指标值)/上期指标值*100%';
alter table PEAK_ITEM
  add constraint PK_PEAK_ITEM primary key (APL_CODE, COUNT_ITEM, PEAK_DATE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_CHART_CONF 报表图表配置表 */
/*==============================================================*/
-- Create table
drop table RPT_CHART_CONF;
prompt Creating RPT_CHART_CONF...
create table RPT_CHART_CONF
(
  APL_CODE             VARCHAR2(10) not null,
  REPORT_TYPE          CHAR(1) not null,
  SHEET_NAME           VARCHAR2(200) not null,
  CHART_TYPE           CHAR(1) not null,
  CHART_NAME           VARCHAR2(300) not null,
  CHART_SEQ            NUMBER(2) not null,
  ITEM_LIST            VARCHAR2(2000) not null,
  CHART_YAXIS_TITLE    VARCHAR2(100),
  CHART_YAXIS_MINVAL   NUMBER(12,4),
  CHART_YAXIS_MAXVAL   NUMBER(12,4),
  CHART_YAXIS_INTERVAL NUMBER(12,4),
  CHART_YAXIS_UNIT     VARCHAR2(10),
  CHART_YAXIS_POSITION CHAR(1) default 0 not null
)
tablespace MAOPRPT;
comment on table RPT_CHART_CONF
  is '报表图表配置表';
comment on column RPT_CHART_CONF.APL_CODE
  is '应用系统编号';
comment on column RPT_CHART_CONF.REPORT_TYPE
  is '报表类型';
comment on column RPT_CHART_CONF.SHEET_NAME
  is '日报SHEET名';
comment on column RPT_CHART_CONF.CHART_TYPE
  is '图表类型';
comment on column RPT_CHART_CONF.CHART_NAME
  is '图表名称';
comment on column RPT_CHART_CONF.CHART_SEQ
  is '图表顺序号';
comment on column RPT_CHART_CONF.ITEM_LIST
  is '科目列表';
comment on column RPT_CHART_CONF.CHART_YAXIS_TITLE
  is '图表Y轴标题';
comment on column RPT_CHART_CONF.CHART_YAXIS_MINVAL
  is '图表Y轴最小值';
comment on column RPT_CHART_CONF.CHART_YAXIS_MAXVAL
  is '图表Y轴最大值';
comment on column RPT_CHART_CONF.CHART_YAXIS_INTERVAL
  is '图表Y轴间隔';
comment on column RPT_CHART_CONF.CHART_YAXIS_UNIT
  is '图表Y轴单位';
comment on column RPT_CHART_CONF.CHART_YAXIS_POSITION
  is '图表Y轴位置. 0:左; 1:右';
alter table RPT_CHART_CONF
  add constraint PK_RPT_CHART_CONF primary key (APL_CODE, REPORT_TYPE, SHEET_NAME, CHART_TYPE, CHART_NAME, CHART_SEQ, CHART_YAXIS_POSITION)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_CHART_CONF_MULT 报表图表配置表_多科目关系配置 */
/*==============================================================*/
-- Create table
drop table RPT_CHART_CONF_MULT;
prompt Creating RPT_CHART_CONF_MULT...
create table RPT_CHART_CONF_MULT
(
  APL_CODE           	VARCHAR2(10) not null,
  SHEET_NAME         	VARCHAR2(100) not null,
  ITEM_VAL_COL       	VARCHAR2(100) not null,
  ITEM_NAME_COL      	VARCHAR2(100) not null,
  SEPARATE_ROWNUM    	NUMBER(4),
  SEPARATE_THRESHOLD 	NUMBER(8,4),
  RESERVE3           	VARCHAR2(50),
  CHART_NAME         	VARCHAR2(300) not null,
  CHART_TYPE         	CHAR(1) not null,
  REPORT_TYPE        	CHAR(1) not null,
  CHART_SEQ          	NUMBER(2) not null
)
tablespace MAOPRPT;
comment on table RPT_CHART_CONF_MULT
  is '报表图表配置表_多科目关系配置';
comment on column RPT_CHART_CONF_MULT.APL_CODE
  is '应用系统编号';
comment on column RPT_CHART_CONF_MULT.SHEET_NAME
  is '日报SHEET名';
comment on column RPT_CHART_CONF_MULT.ITEM_VAL_COL
  is '科目值科目';
comment on column RPT_CHART_CONF_MULT.ITEM_NAME_COL
  is '科目值科目所对应名称科目';
comment on column RPT_CHART_CONF_MULT.SEPARATE_ROWNUM
  is '分割起始行号';
comment on column RPT_CHART_CONF_MULT.SEPARATE_THRESHOLD
  is '分割阀值';
comment on column RPT_CHART_CONF_MULT.RESERVE3
  is '备注3';
comment on column RPT_CHART_CONF_MULT.CHART_NAME
  is '图表名称';
comment on column RPT_CHART_CONF_MULT.CHART_TYPE
  is '图表类型';
comment on column RPT_CHART_CONF_MULT.REPORT_TYPE
  is '报表类型';
comment on column RPT_CHART_CONF_MULT.CHART_SEQ
  is '图表序号';
alter table RPT_CHART_CONF_MULT
  add constraint PK_RPT_CHART_CONF_MULT primary key (APL_CODE, REPORT_TYPE, SHEET_NAME, CHART_TYPE, CHART_NAME, CHART_SEQ)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_ITEM_CONF 应用巡检报表科目配置表*/
/*==============================================================*/
-- Create table
drop table RPT_ITEM_CONF;
prompt Creating RPT_ITEM_CONF...
create table RPT_ITEM_CONF
(
  APL_CODE        	VARCHAR2(10) not null,
  REPORT_TYPE     	CHAR(1) not null,
  SHEET_NAME      	VARCHAR2(100) not null,
  ITEM_CD       	VARCHAR2(300) not null,
  ITEM_SEQ        	NUMBER(2),
  EXPRESSION      	VARCHAR2(1000),
  EXPRESSION_UNIT 	VARCHAR2(10),
  GROUP_PARENT    	VARCHAR2(200),
  SHEET_SEQ       	NUMBER(2)
)
tablespace MAOPRPT;
comment on table RPT_ITEM_CONF
  is '报表科目配置表';
comment on column RPT_ITEM_CONF.APL_CODE
  is '应用系统编号';
comment on column RPT_ITEM_CONF.REPORT_TYPE
  is '报表类型';
comment on column RPT_ITEM_CONF.SHEET_NAME
  is '报表SHEET名称';
comment on column RPT_ITEM_CONF.ITEM_CD
  is '指标编码';
comment on column RPT_ITEM_CONF.ITEM_SEQ
  is '指标序号';
comment on column RPT_ITEM_CONF.EXPRESSION
  is '指标计算公式';
comment on column RPT_ITEM_CONF.EXPRESSION_UNIT
  is '指标计算公式单位';
comment on column RPT_ITEM_CONF.GROUP_PARENT
  is '分组标题名';
comment on column RPT_ITEM_CONF.SHEET_SEQ
  is '报表SHEET顺序号';
alter table RPT_ITEM_CONF
  add constraint PK_RPT_ITEM_CONF primary key (APL_CODE, REPORT_TYPE, SHEET_NAME, ITEM_CD)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: SERVER_CONF 服务器基础配置信息表 */
/*==============================================================*/
-- Create table
drop table SERVER_CONF;
prompt Creating SERVER_CONF...
create table SERVER_CONF
(
  SRV_CODE      VARCHAR2(50) not null,
  LOAD_MODE     CHAR(1),
  APL_CODE      VARCHAR2(10) not null,
  SER_CLASS     CHAR(1),
  SER_NAME      VARCHAR2(100),
  MEM_CONF      VARCHAR2(100),
  CPU_CONF      VARCHAR2(100),
  DISK_CONF     VARCHAR2(100),
  IP_ADDRESS    VARCHAR2(15),
  FLOAT_ADDRESS VARCHAR2(15),
  AUTO_CAPTURE  CHAR(1) default 1
)
tablespace MAOPRPT;
comment on table SERVER_CONF
  is '服务器配置管理表';
comment on column SERVER_CONF.SRV_CODE
  is '服务器编号';
comment on column SERVER_CONF.LOAD_MODE
  is '负载方式 0:主机 1:备机 2:F5';
comment on column SERVER_CONF.APL_CODE
  is '应用系统编号';
comment on column SERVER_CONF.SER_CLASS
  is '服务器分类 1:Web 2:APP 3:DB';
comment on column SERVER_CONF.SER_NAME
  is '服务器名称';
comment on column SERVER_CONF.MEM_CONF
  is '内存配置';
comment on column SERVER_CONF.CPU_CONF
  is 'CPU配置';
comment on column SERVER_CONF.DISK_CONF
  is '硬盘配置';
comment on column SERVER_CONF.IP_ADDRESS
  is 'IP地址';
comment on column SERVER_CONF.FLOAT_ADDRESS
  is '浮动IP地址';
comment on column SERVER_CONF.AUTO_CAPTURE
  is '自动获取系统资源标识.0:自动;';
alter table SERVER_CONF
  add constraint PK_SERVER_APL primary key (SRV_CODE, APL_CODE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: SYS_DATE 系统假日信息表 */
/*==============================================================*/
-- Create table
drop table SYS_DATE;
prompt Creating SYS_DATE...
create table SYS_DATE
(
  SYS_DATE     CHAR(8) not null,
  HOLIDAY_FLAG CHAR(1) default 1 not null
)
tablespace MAOPRPT;
comment on column SYS_DATE.HOLIDAY_FLAG
  is '1:工作日、2:周末、3:法定假日';
alter table SYS_DATE
  add constraint PK_SYS_DATE primary key (SYS_DATE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: SYS_RESRC 系统资源信息表 */
/*==============================================================*/
-- Create table
drop table SYS_RESRC;
prompt Creating SYS_RESRC...
create table SYS_RESRC
(
  APL_CODE     VARCHAR2(10) not null,
  TRANS_DATE   VARCHAR2(8) not null,
  SRV_CODE     VARCHAR2(50) not null,
  MIN_POINT    VARCHAR2(5) not null,
  CPU_PERCENT  VARCHAR2(8),
  MEM_PERCENT  VARCHAR2(8),
  DISK_PERCENT VARCHAR2(8)
)
partition by range (TRANS_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201602 values less than ('20160201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201603 values less than ('20160301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201604 values less than ('20160401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201605 values less than ('20160501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201606 values less than ('20160601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201607 values less than ('20160701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201608 values less than ('20160801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201609 values less than ('20160901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201610 values less than ('20161001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201611 values less than ('20161101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201612 values less than ('20161201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201701 values less than ('20170101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table SYS_RESRC
  is '五分钟系统资源统计表';
comment on column SYS_RESRC.APL_CODE
  is '应用系统编号';
comment on column SYS_RESRC.TRANS_DATE
  is '交易日期';
comment on column SYS_RESRC.SRV_CODE
  is '服务器编号（IP）';
comment on column SYS_RESRC.MIN_POINT
  is '五分钟统计时间点';
comment on column SYS_RESRC.CPU_PERCENT
  is 'cpu百分比';
comment on column SYS_RESRC.MEM_PERCENT
  is '内存百分比';
comment on column SYS_RESRC.DISK_PERCENT
  is '磁盘IO百分比';
alter table SYS_RESRC
  add constraint PK_SYS_RESRC primary key (APL_CODE, TRANS_DATE, SRV_CODE, MIN_POINT)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_SYS_RESRC_01 on SYS_RESRC (APL_CODE, TRANS_DATE, MIN_POINT, SRV_CODE)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: SYS_RESRC_STSTCS_ITEMS 系统资源统计口径 */
/*==============================================================*/
-- Create table
drop table SYS_RESRC_STSTCS_ITEMS;
prompt Creating SYS_RESRC_STSTCS_ITEMS...
create table SYS_RESRC_STSTCS_ITEMS
(
  APL_CODE     VARCHAR2(10) not null,
  HOSTS_TYPE   CHAR(1) not null,
  ACTIVE_HOSTS VARCHAR2(200),
  HOSTS        VARCHAR2(200)
)
tablespace MAOPRPT;
comment on table SYS_RESRC_STSTCS_ITEMS
  is '系统资源统计口径';
comment on column SYS_RESRC_STSTCS_ITEMS.APL_CODE
  is '系统编号';
comment on column SYS_RESRC_STSTCS_ITEMS.HOSTS_TYPE
  is '统计的服务器类型';
comment on column SYS_RESRC_STSTCS_ITEMS.ACTIVE_HOSTS
  is '当前使用的机器群';
comment on column SYS_RESRC_STSTCS_ITEMS.HOSTS
  is '统计的机器群';
alter table SYS_RESRC_STSTCS_ITEMS
  add constraint PK_SYS_RESRC_STSTCS_ITEMS primary key (APL_CODE, HOSTS_TYPE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: SYS_RESRC_TRANS 系统资源与交易量对照表 */
/*==============================================================*/
-- Create table
drop table SYS_RESRC_TRANS;
prompt Creating SYS_RESRC_TRANS...
create table SYS_RESRC_TRANS
(
  APL_CODE  VARCHAR2(10) not null,
  TRAN_NAME VARCHAR2(300) not null,
  SRV_TYPE  CHAR(1) not null,
  SRV_CODE  VARCHAR2(50) not null
)
tablespace MAOPRPT;
comment on table SYS_RESRC_TRANS
  is '系统资源与交易量对照表';
comment on column SYS_RESRC_TRANS.APL_CODE
  is '应用系统编号';
comment on column SYS_RESRC_TRANS.TRAN_NAME
  is '交易名称';
comment on column SYS_RESRC_TRANS.SRV_TYPE
  is '服务器分类';
comment on column SYS_RESRC_TRANS.SRV_CODE
  is '服务器编号（IP）';
alter table SYS_RESRC_TRANS
  add constraint PK_SYS_RESRC_TRANS primary key (APL_CODE, TRAN_NAME, SRV_TYPE, SRV_CODE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: TIMES_TRANS_CONF TPM、TPS关联指标配置信息表 */
/*==============================================================*/
-- Create table
drop table TIMES_TRANS_CONF;
prompt Creating TIMES_TRANS_CONF...
create table TIMES_TRANS_CONF
(
  APL_CODE     VARCHAR2(10) not null,
  COUNT_ITEM   VARCHAR2(30) not null,
  RELATED_ITEM VARCHAR2(100),
  TYPE         CHAR(1) not null
)
tablespace MAOPRPT;
comment on table TIMES_TRANS_CONF
  is '分钟和秒交易量科目配置';
comment on column TIMES_TRANS_CONF.APL_CODE
  is '系统编号';
comment on column TIMES_TRANS_CONF.COUNT_ITEM
  is '统计科目名';
comment on column TIMES_TRANS_CONF.RELATED_ITEM
  is '关联的科目名, 多个科目以逗号隔开';
comment on column TIMES_TRANS_CONF.TYPE
  is '类型:1为分钟,2为秒钟';
alter table TIMES_TRANS_CONF
  add constraint PK_TIMES_TRANS_CONF primary key (APL_CODE, COUNT_ITEM)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: RPT_DATASOURCE_CONF 数据采集源配置 */
/*==============================================================*/
-- Create table
drop table RPT_DATASOURCE_CONF;
prompt Creating RPT_DATASOURCE_CONF...
create table RPT_DATASOURCE_CONF
(
  APL_CODE   VARCHAR2(10) not null,
  DATA_TYPE  CHAR(1) not null,
  DATASOURCE VARCHAR2(10) not null
)
tablespace MAOPRPT;
comment on table RPT_DATASOURCE_CONF
  is '服务器配置管理表';
comment on column RPT_DATASOURCE_CONF.APL_CODE
  is '应用系统编号';
comment on column RPT_DATASOURCE_CONF.DATA_TYPE
  is '采集数据类型：0：WEBLOGIC、1：TUXDO、2：SYSTEM';
comment on column RPT_DATASOURCE_CONF.DATASOURCE
  is '数据源地址，类型0：jmx、mw、nagos、类型1：暂无、类型2：smdb';
-- Create/Recreate primary, unique and foreign key constraints
alter table RPT_DATASOURCE_CONF
  add constraint PK_RPT_DATASOURCE_CONF primary key (APL_CODE, DATA_TYPE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEBLOGIC_CONF WEBLOGIC服务器名配置信息表 */
/*==============================================================*/
-- Create table
drop table WEBLOGIC_CONF;
prompt Creating WEBLOGIC_CONF...
create table WEBLOGIC_CONF
(
  APL_CODE       		VARCHAR2(10) not null,
  IP_ADDRESS     		VARCHAR2(15) not null,
  SERVER_NAME    		VARCHAR2(50) not null,
  SERVER_JDBC_NAME    	VARCHAR2(100),
  WEBLOGIC_FLG   		CHAR(1) default 1 not null,
  CLUSTER_SERVER 		VARCHAR2(30),
  WEBLOGIC_PORT  		VARCHAR2(5) not null
)
tablespace MAOPRPT;
comment on table WEBLOGIC_CONF
  is '服务器配置管理表';
comment on column WEBLOGIC_CONF.APL_CODE
  is '应用系统编号';
comment on column WEBLOGIC_CONF.IP_ADDRESS
  is 'IP地址';
comment on column WEBLOGIC_CONF.SERVER_NAME
  is '服务名';
comment on column WEBLOGIC_CONF.SERVER_JDBC_NAME
  is '服务JDBC名，多个jdbc以逗号分隔';
comment on column WEBLOGIC_CONF.WEBLOGIC_FLG
  is 'WebLogic导出数据标识: 0为导出, 1为不导出';
comment on column WEBLOGIC_CONF.CLUSTER_SERVER
  is '集群服务名';
comment on column WEBLOGIC_CONF.WEBLOGIC_PORT
  is '端口号';
alter table WEBLOGIC_CONF
  add constraint PK_WEBLOGIC_CONF primary key (APL_CODE, IP_ADDRESS, WEBLOGIC_PORT, SERVER_NAME)
  using index
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEB_JDBC WEBLOGIC JDBC信息表 */
/*==============================================================*/
-- Create table
drop table WEB_JDBC;
prompt Creating WEB_JDBC...
create table WEB_JDBC
(
  APL_CODE        VARCHAR2(10) not null,
  SRV_CODE        VARCHAR2(50) not null,
  WEBLOGIC_SERVER VARCHAR2(30) not null,
  MONITOR_DATE    CHAR(8) not null,
  MONITOR_TIME    VARCHAR2(8) not null,
  JDBC_NAME       VARCHAR2(30) not null,
  CAPACITY        VARCHAR2(4),
  ACTIVE_HIGH     VARCHAR2(4),
  WAITING_HIGH    VARCHAR2(4),
  CURRENT_ACTIVE  VARCHAR2(4),
  CURRENT_WAITING VARCHAR2(4),
  WEBLOGIC_PORT   VARCHAR2(6) not null
)
partition by range (MONITOR_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201602 values less than ('20160201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201603 values less than ('20160301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201604 values less than ('20160401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201605 values less than ('20160501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201606 values less than ('20160601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201607 values less than ('20160701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201608 values less than ('20160801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201609 values less than ('20160901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201610 values less than ('20161001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201611 values less than ('20161101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201612 values less than ('20161201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201701 values less than ('20170101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table WEB_JDBC
  is 'Weblogic数据库连接池资源统计表';
alter table WEB_JDBC
  add constraint PK_WEB_JDBC primary key (APL_CODE, SRV_CODE, WEBLOGIC_SERVER, MONITOR_DATE, MONITOR_TIME, JDBC_NAME, WEBLOGIC_PORT)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_JDBC_01 on WEB_JDBC (APL_CODE, MONITOR_DATE, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_JDBC_02 on WEB_JDBC (APL_CODE, MONITOR_DATE, MONITOR_TIME, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_JDBC_03 on WEB_JDBC (APL_CODE, MONITOR_DATE)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEB_MEMORY WEBLOGIC内存信息表 */
/*==============================================================*/
-- Create table
drop table WEB_MEMORY;
prompt Creating WEB_MEMORY...
create table WEB_MEMORY
(
  APL_CODE        VARCHAR2(10) not null,
  SRV_CODE        VARCHAR2(50) not null,
  WEBLOGIC_SERVER VARCHAR2(30) not null,
  MONITOR_DATE    CHAR(8) not null,
  MONITOR_TIME    VARCHAR2(8) not null,
  TOTAL_MEMORY    VARCHAR2(10),
  IDLE_MEMORY     VARCHAR2(10),
  USED_MEMORY     VARCHAR2(10),
  MEMORY_RATE     VARCHAR2(4),
  WEBLOGIC_PORT   VARCHAR2(6) not null
)
partition by range (MONITOR_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201602 values less than ('20160201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201603 values less than ('20160301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201604 values less than ('20160401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201605 values less than ('20160501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201606 values less than ('20160601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201607 values less than ('20160701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201608 values less than ('20160801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201609 values less than ('20160901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201610 values less than ('20161001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201611 values less than ('20161101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201612 values less than ('20161201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201701 values less than ('20170101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table WEB_MEMORY
  is 'Weblogic内存资源统计表';
comment on column WEB_MEMORY.APL_CODE
  is '应用系统编号';
comment on column WEB_MEMORY.SRV_CODE
  is '服务器编号（IP）';
comment on column WEB_MEMORY.WEBLOGIC_SERVER
  is 'WebLogic服务名称';
comment on column WEB_MEMORY.MONITOR_DATE
  is '监控日期';
comment on column WEB_MEMORY.MONITOR_TIME
  is '监控时间点';
comment on column WEB_MEMORY.TOTAL_MEMORY
  is '总内存量';
comment on column WEB_MEMORY.IDLE_MEMORY
  is '空闲内存量';
comment on column WEB_MEMORY.USED_MEMORY
  is '使用内存量';
comment on column WEB_MEMORY.MEMORY_RATE
  is '内存使用率';
comment on column WEB_MEMORY.WEBLOGIC_PORT
  is 'weblogic服务端口';
alter table WEB_MEMORY
  add constraint PK_WEB_MEMORY primary key (APL_CODE, SRV_CODE, WEBLOGIC_SERVER, MONITOR_DATE, MONITOR_TIME, WEBLOGIC_PORT)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_MEMORY_01 on WEB_MEMORY (APL_CODE, MONITOR_DATE, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_MEMORY_02 on WEB_MEMORY (APL_CODE, MONITOR_DATE, MONITOR_TIME, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_MEMORY_03 on WEB_MEMORY (APL_CODE, MONITOR_DATE)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEB_QUEUE WEBLOGIC队列信息表 */
/*==============================================================*/
-- Create table
drop table WEB_QUEUE;
prompt Creating WEB_QUEUE...
create table WEB_QUEUE
(
  APL_CODE        VARCHAR2(10) not null,
  SRV_CODE        VARCHAR2(50) not null,
  WEBLOGIC_SERVER VARCHAR2(30) not null,
  MONITOR_DATE    CHAR(8) not null,
  MONITOR_TIME    VARCHAR2(8) not null,
  TOTAL_QUEUE     VARCHAR2(4),
  IDLE_QUEUE      VARCHAR2(4),
  USED_QUEUE      VARCHAR2(4),
  WEBLOGIC_PORT   VARCHAR2(6) not null
)
partition by range (MONITOR_DATE)
(
  partition ORD_ACT_PART201501 values less than ('20150101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201502 values less than ('20150201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201503 values less than ('20150301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201504 values less than ('20150401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201505 values less than ('20150501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201506 values less than ('20150601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201507 values less than ('20150701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201508 values less than ('20150801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201509 values less than ('20150901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201510 values less than ('20151001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201511 values less than ('20151101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201512 values less than ('20151201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201601 values less than ('20160101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201602 values less than ('20160201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201603 values less than ('20160301')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201604 values less than ('20160401')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201605 values less than ('20160501')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201606 values less than ('20160601')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201607 values less than ('20160701')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201608 values less than ('20160801')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201609 values less than ('20160901')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201610 values less than ('20161001')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201611 values less than ('20161101')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201612 values less than ('20161201')
    tablespace MAOPRPT,
  partition ORD_ACT_PART201701 values less than ('20170101')
    tablespace MAOPRPT,
  partition ORD_ACT_PARTMAX values less than (MAXVALUE)
    tablespace MAOPRPT
);
comment on table WEB_QUEUE
  is 'Weblogic队列资源统计表';
comment on column WEB_QUEUE.APL_CODE
  is '应用系统编号';
comment on column WEB_QUEUE.SRV_CODE
  is '服务器编号（IP）';
comment on column WEB_QUEUE.WEBLOGIC_SERVER
  is 'WebLogic服务名称';
comment on column WEB_QUEUE.MONITOR_DATE
  is '监控日期';
comment on column WEB_QUEUE.MONITOR_TIME
  is '监控时间点';
comment on column WEB_QUEUE.TOTAL_QUEUE
  is '总队列数';
comment on column WEB_QUEUE.IDLE_QUEUE
  is '空闲队列数';
comment on column WEB_QUEUE.USED_QUEUE
  is '使用队列数';
comment on column WEB_QUEUE.WEBLOGIC_PORT
  is 'weblogic服务端口';
alter table WEB_QUEUE
  add constraint PK_WEB_QUEUE primary key (APL_CODE, SRV_CODE, WEBLOGIC_SERVER, MONITOR_DATE, MONITOR_TIME, WEBLOGIC_PORT)
  using index 
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_QUEUE_01 on WEB_QUEUE (APL_CODE, MONITOR_DATE, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_QUEUE_02 on WEB_QUEUE (APL_CODE, MONITOR_DATE, MONITOR_TIME, SRV_CODE)
  tablespace MAOPRPT_INDEX;
create index INDEX_WEB_QUEUE_03 on WEB_QUEUE (APL_CODE, MONITOR_DATE)
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEEK_RESOURCE 周系统资源统计表 */
/*==============================================================*/
-- Create table
drop table WEEK_RESOURCE;
prompt Creating WEEK_RESOURCE...
create table WEEK_RESOURCE
(
  APL_CODE            VARCHAR2(10) not null,
  COUNT_WEEK          CHAR(8) not null,
  SRV_CODE            VARCHAR2(50) not null,
  CPU_PEAK            VARCHAR2(5),
  CPU_ONLINE_PEAK_AVG VARCHAR2(5),
  CPU_BATCH_PEAK_AVG  VARCHAR2(5),
  MEM_PEAK            VARCHAR2(5),
  MEM_ONLINE_PEAK_AVG VARCHAR2(5),
  MEM_BATCH_PEAK_AVG  VARCHAR2(5),
  IO_PEAK             VARCHAR2(5),
  IO_ONLINE_PEAK_AVG  VARCHAR2(5),
  IO_BATCH_PEAK_AVG   VARCHAR2(5),
  REVISE_FLAG         CHAR(1) default 0 not null
)
tablespace MAOPRPT;
comment on table WEEK_RESOURCE
  is '资源使用周统计表';
comment on column WEEK_RESOURCE.APL_CODE
  is '应用系统编号';
comment on column WEEK_RESOURCE.COUNT_WEEK
  is '统计周开始日';
comment on column WEEK_RESOURCE.SRV_CODE
  is '服务器编号(IP)';
comment on column WEEK_RESOURCE.CPU_PEAK
  is 'CPU峰值(周)';
comment on column WEEK_RESOURCE.CPU_ONLINE_PEAK_AVG
  is 'CPU联机峰值均值(周)';
comment on column WEEK_RESOURCE.CPU_BATCH_PEAK_AVG
  is 'CPU批量峰值均值(周)';
comment on column WEEK_RESOURCE.MEM_PEAK
  is '内存峰值(周)';
comment on column WEEK_RESOURCE.MEM_ONLINE_PEAK_AVG
  is '内存联机峰值均值(周)';
comment on column WEEK_RESOURCE.MEM_BATCH_PEAK_AVG
  is '内存批量峰值均值(周)';
comment on column WEEK_RESOURCE.IO_PEAK
  is 'IO峰值(周)';
comment on column WEEK_RESOURCE.IO_ONLINE_PEAK_AVG
  is 'IO联机峰值均值(周)';
comment on column WEEK_RESOURCE.IO_BATCH_PEAK_AVG
  is 'IO批量峰值均值(周)';
comment on column WEEK_RESOURCE.REVISE_FLAG
  is '修订标识. 0 : 未修订  1 : 已修订';
alter table WEEK_RESOURCE
  add constraint PK_WEEK_RESOURCE primary key (APL_CODE, COUNT_WEEK, SRV_CODE)
  using index 
  tablespace MAOPRPT_INDEX;

/*==============================================================*/
/* Table: WEEK_TRAN 周交易统计表 */
/*==============================================================*/
-- Create table
drop table WEEK_TRAN;
prompt Creating WEEK_TRAN...
create table WEEK_TRAN
(
  APL_CODE         VARCHAR2(10) not null,
  COUNT_WEEK       CHAR(8) not null,
  WEEK_TOTAL_TRANS VARCHAR2(18),
  WEEK_PEAK_TRANS  VARCHAR2(18)
)
tablespace MAOPRPT;
comment on table WEEK_TRAN
  is '交易量周统计表';
comment on column WEEK_TRAN.APL_CODE
  is '应用系统编号';
comment on column WEEK_TRAN.COUNT_WEEK
  is '统计周开始日';
comment on column WEEK_TRAN.WEEK_TOTAL_TRANS
  is '周总交易量';
comment on column WEEK_TRAN.WEEK_PEAK_TRANS
  is '周峰值交易量';
alter table WEEK_TRAN
  add constraint PK_WEEK_TRAN primary key (APL_CODE, COUNT_WEEK)
  using index 
  tablespace MAOPRPT_INDEX;

prompt Loading SERVER_CONF...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-7', '0', 'EPAY', '3', 'IBL860-7', null, null, null, '10.1.41.37', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-006', '0', 'NEXCH', '1', 'BL685-006', null, null, null, '10.1.44.33', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840EPR', '0', 'CEMB', '2', 'APP-S41.5', null, null, null, '10.1.41.5', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-007', '0', 'NEXCH', '1', 'BL685-007', null, null, null, '10.1.44.34', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P4', '0', 'IFTS', '2', 'P5954P4', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD5pp5', '0', 'CAMS', '3', 'SD5pp5', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD6pp5', '2', 'CAMS', '2', 'SD6pp5', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD8pp5', '2', 'CAMS', '2', 'SD8pp5', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840APJ', '0', 'CASS', '2', 'APP-S3.3', null, null, null, '10.1.3.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-254', '2', 'KTRADE', '1', 'WEB-J97.76', null, null, null, '10.1.97.76', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('DL580-027', '1', 'CCDSS', '2', 'DL580-027', null, null, null, '10.1.48.191', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-008', '0', 'NEXCH', '1', 'BL685-008', null, null, null, '10.1.44.35', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860DPE', '0', 'NPORT', '3', 'RX860DPE', null, null, null, '10.1.10.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5951P4', '0', 'IFTS', '2', 'P5951P4', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-128', '0', 'IAM', '2', 'BL685-128', null, null, null, '10.1.90.45', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74040P1', '0', 'FDS', '4', 'P74040P1', null, null, null, '10.1.20.50', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL460-039', '1', 'OAS', '3', '120-BL460-039-JXQ', '4G', '2C', null, '10.1.188.120', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('dl580-035', '1', 'CCR', '1', '个人征信WEB服务器', '8G', '16C', '400G', '10.1.48.140', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-017', '2', 'NBANK', '2', 'APP-143', null, null, null, '10.1.44.143', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870032', '1', 'CECM', '3', 'BL870032', '64G', '8C', '500G', '10.1.8.216', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74016P1', '0', 'IFTS', '2', 'P74016P1', null, null, null, '10.1.8.204', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-20', '2', 'NBANK', '2', 'IBL860-20', '32', '8', null, '10.1.44.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII8P1', '0', 'NPORT', '3', 'SDII8P1', null, null, null, '10.1.10.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870023', '0', 'CCS', '3', 'WFDB-S40.18', null, null, null, '10.1.40.18', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-32', '2', 'NBANK', '2', 'IBL860-32', '32', '8', null, '10.1.44.57', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-60', '2', 'NBANK', '2', 'IBL860-60', '32', '8', null, '10.1.44.54', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-023', '2', 'NBANK', '2', 'IBL860-023', '32', '8', null, '10.1.44.55', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-43', '2', 'NBANK', '2', 'IBL860-43', '32', '8', null, '10.1.44.40', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-148', '2', 'NBANK', '1', 'web-143', null, null, null, '10.1.97.143', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-149', '2', 'NBANK', '1', 'web-145', null, null, null, '10.1.97.145', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-137', '2', 'NBANK', '1', 'web-146', null, null, null, '10.1.97.146', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-150', '2', 'NBANK', '1', 'web-131', null, null, null, '10.1.97.131', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-138', '2', 'NBANK', '1', 'web-132', null, null, null, '10.1.97.132', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5953P4', '0', 'IFTS', '2', 'P5953P4', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74018P1', '0', 'IFTS', '2', 'P74018P1', null, null, null, '10.1.8.205', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74015P1', '0', 'IFTS', '2', 'P74015P1', null, null, null, '10.1.8.177', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-57', '2', 'NBANK', '2', 'IBL860-57', '32', '8', null, '10.1.44.52', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-63', '2', 'NBANK', '2', 'IBL860-63', '32', '8', null, '10.1.44.56', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74017P1', '0', 'IFTS', '2', 'P74017P1', null, null, null, '10.1.8.178', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-72', '2', 'NBANK', '2', 'IBL860-72', '32', '8', null, '10.1.44.58', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-191', '2', 'NBANK', '1', 'web-137', null, null, null, '10.1.97.137', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74030P1', '0', 'ETRM', '3', 'P74030P1', null, null, null, '10.1.41.125', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-153', '2', 'NBANK', '1', 'web-135', null, null, null, '10.1.97.135', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685659', '0', 'OACMS', '2', '105-BL685659', null, null, null, '10.1.188.105', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5952P1', '0', 'EBMP', '2', 'P5952P1', null, null, null, '10.1.96.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685658', '0', 'OACMS', '2', '106-BL685658', null, null, null, '10.1.188.106', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-3', '2', 'NBANK', '2', 'APP-131', null, null, null, '10.1.44.131', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-45', '2', 'NBANK', '2', 'APP-132', null, null, null, '10.1.44.132', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-6', '2', 'NBANK', '2', 'APP-133', null, null, null, '10.1.44.133', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-47', '2', 'NBANK', '2', 'APP-134', null, null, null, '10.1.44.134', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-10', '2', 'NBANK', '2', 'APP-135', null, null, null, '10.1.44.135', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-51', '2', 'NBANK', '2', 'APP-136', null, null, null, '10.1.44.136', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-13', '2', 'NBANK', '2', 'APP-137', null, null, null, '10.1.44.137', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-53', '2', 'NBANK', '2', 'APP-138', null, null, null, '10.1.44.138', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-8', '2', 'NBANK', '2', 'APP-139', null, null, null, '10.1.44.139', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-27', '2', 'NBANK', '2', 'APP-140', null, null, null, '10.1.44.140', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-029', '2', 'NBANK', '2', 'APP-141', null, null, null, '10.1.44.141', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-069', '2', 'NBANK', '2', 'APP-142', null, null, null, '10.1.44.142', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-151', '2', 'NBANK', '1', 'web-139', null, null, null, '10.1.97.139', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-144', '2', 'NBANK', '1', 'web-140', null, null, null, '10.1.97.140', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-156', '2', 'NBANK', '1', 'web-141', null, null, null, '10.1.97.141', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-177', '2', 'NBANK', '1', 'web-142', null, null, null, '10.1.97.142', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII1pp1', '0', 'NBANK', '3', 'DB-22', null, null, null, '10.1.41.22', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII2pp1', '1', 'NBANK', '3', 'DB-23', null, null, null, '10.1.41.23', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII3pp1', '1', 'NBANK', '3', 'DB-24', null, null, null, '10.1.41.24', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII4pp1', '1', 'NBANK', '3', 'DB-25', null, null, null, '10.1.41.25', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7406P1', '0', 'ETRM', '3', 'P7406P1', null, null, null, '10.1.41.124', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('DE-PE6650-014', '0', 'CRDS', '1', 'DE-PE6650-014', '8G', '8C', '210G', '10.1.88.67', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-505', '0', 'ETRM', '2', 'bl685-505', null, null, null, '10.1.44.233', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-80', '0', 'GTS', '2', 'BL680-80', null, null, null, '10.1.20.10', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-81', '0', 'GTS', '2', 'BL680-81', null, null, null, '10.1.20.11', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5703P4', '0', 'OTP', '2', 'P5703P4', null, null, null, '10.1.20.24', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-047', '0', 'ESSC', '2', '10.1.10.58', null, null, null, '10.1.10.58', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD24pp3', '0', 'EPAMS', '3', 'SD24pp3', null, null, null, '10.1.201.12', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-162', '0', 'ESSC', '2', '10.1.44.1', null, null, null, '10.1.44.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-163', '0', 'ESSC', '2', '10.1.44.2', null, null, null, '10.1.44.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-037', '0', 'ESSC', '2', '10.1.44.20', null, null, null, '10.1.44.20', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-038', '0', 'ESSC', '2', '10.1.44.21', null, null, null, '10.1.44.21', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74042P1', '0', 'FDS', '4', 'P74042P1', null, null, null, '10.1.20.51', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl680-048', '0', 'ESSC', '2', '10.1.10.59', null, null, null, '10.1.10.59', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P1', '0', 'EBMP', '2', 'P5954P1', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860126', '0', 'SEAL', '3', null, null, null, null, '10.1.5.127', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD7pp0', '0', 'ECAS', '2', '备机1', '128', '64c', '300G*2', '10.1.8.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8411PI', '0', 'VBV', '3', 'APP+DB-S3.103', null, null, null, '10.1.3.101', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7804P4', '2', 'IBCARMS', '2', 'P7804P4', '48G', '8C', '300', '10.1.48.115', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74041P1', '0', 'FDS', '4', 'P74041P1', null, null, null, '10.1.20.48', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD5pp0', '0', 'ECAS', '2', '灾备备机', '128G', '64', '300G*2', '10.1.8.13', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840DPR', '0', 'CEMB', '2', 'APP-J41.4', null, null, null, '10.1.41.4', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('sd15pp1', '0', 'ECIF', '3', 'DB1', null, null, null, '10.1.41.8', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('sd16pp1', '0', 'ECIF', '3', 'DB2', null, null, null, '10.1.41.9', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD15pp2', '0', 'ECIF', '2', '应用1', null, null, null, '10.1.44.18', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD16pp2', '0', 'ECIF', '2', '应用2', null, null, null, '10.1.44.19', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD2pp7', '0', 'FUND', '2', 'SD2pp7', null, null, null, '10.1.8.62', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD4pp7', '0', 'FUND', '2', 'SD4pp7', null, null, null, '10.1.8.9', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD5pp7', '0', 'GTS', '3', 'SD5pp7', null, null, null, '10.1.10.71', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD18pp2', '0', 'ECIF', '2', '应用3', null, null, null, '10.1.48.24', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-1', '2', 'NBANK', '2', 'IBL860-1', '32', '8', null, '10.1.44.59', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7401P3', '0', 'EBIC', '2', 'P7401P3', null, null, null, ' 10.1.44.86', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7402P3', '0', 'EBIC', '2', 'P7402P3', null, null, null, '10.1.44.87', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7403P3', '0', 'EBIC', '2', 'P7403P3', null, null, null, '10.1.44.88', null, '0');
commit;
prompt 100 records committed...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7404P3', '0', 'EBIC', '2', 'P7404P3', null, null, null, '10.1.44.89', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-179', '0', 'EBIC', '2', 'BL685-179', null, null, null, '10.1.48.71', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7402P2', '0', 'EBIC', '3', 'P7402P2', null, null, null, '10.1.41.45', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-176', '0', 'EBIC', '3', 'BL685-176', null, null, null, '10.1.48.65', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5703P3', '0', 'OTP', '3', 'P5703P3', null, null, null, '10.1.8.158', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD18pp4', '1', 'PLMS', '3', 'SD18pp4', null, null, null, '10.1.10.39', '10.1.10.41', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('sd14pp7', '0', 'SSTF', '2', '国际结算', null, null, null, '10.1.89.51', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860016', '0', 'KTRADE', '2', 'APP-S44.109', '32', '32', '300', '10.1.44.109', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860066', '0', 'GSALE', '2', 'BL860066', null, null, null, '10.1.44.118', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7403P1', '0', 'EBPP', '2', 'POS收单', null, null, null, '10.1.84.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8412PR', '0', 'CEMB', '2', 'APP-J41.72', null, null, null, '10.1.41.72', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-64', '0', 'ORM', '2', 'BL680-64', '16G', '16C', '130G', '10.1.88.118', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860143', '0', 'CAIS', '2', 'HP-IBL860-143', null, null, null, '10.1.44.123', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD24pp1', '1', 'PLMS', '2', 'SD24pp1', '64', '12C', '2G', '10.1.88.13', '10.1.88.15', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-287', '2', 'BCRM', '2', 'bl685-287', '16', '32', '260', '10.1.88.158', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685448', '1', 'CAIS', '1', 'HP-BL685-448', null, null, null, '10.1.48.124', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860036', '1', 'CAIS', '2', 'HP-IBL860-036', null, null, null, '10.1.44.124', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860052', '0', 'CAIS', '3', 'HP-IBL860-052', null, null, null, '10.1.41.77', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860144', '1', 'CAIS', '3', 'HP-IBL860-144', null, null, null, '10.1.41.78', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-168', '0', 'MSG', '2', 'SALE-APP-S26.28', null, null, null, '10.1.26.28', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870018', '0', 'PCRM', '3', 'A库备机', null, '32', null, '10.1.10.105', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-541', '0', 'CRRS', '1', 'web端主机', '32', '4', '600', '10.1.48.152', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('cebweb3.100', '0', 'INTRA', '3', 'cebweb3.100', null, null, null, '10.1.188.100', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5701P4', '0', 'OTP', '2', 'P5701P4', null, null, null, '10.1.20.32', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860106', '0', 'CRRS', '3', 'DB备机', null, '32', null, '10.1.41.89', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5951P5', '1', 'OAS', '3', '200-P5951P5-JXQ', '16G', '4C', null, '10.1.188.200', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-032', '0', 'OAS', '2', '7-BL680-032-JXQ', null, null, null, '10.1.188.7', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-039', '0', 'PLR', '2', 'HP-BL685039', '16g', '4c', '300G', '10.1.48.68', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-255', '2', 'KTRADE', '1', 'WEB-J97.78', null, null, null, '10.1.97.78', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('dl580-007', '1', 'OAS', '2', '6-dl580-007-SD', null, null, null, '10.1.188.6', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-161', '0', 'RWA', '2', 'BL685-161', '32G', '4C', '300G', '10.1.48.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-141', '0', 'OACMS', '2', 'BL680-141', null, null, null, '10.1.188.107', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('DL580-035', '0', '1104', '2', 'DL580-035', null, null, null, '10.1.48.140', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685657', '2', 'FREEQUERY', '1', 'web端服务器', '64G', '4C', '2*600G', '10.1.48.192', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-160', '0', 'RWA', '2', 'BL685-160', '32G', '4C', '300G', '10.1.48.51', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-028', '0', 'ANTI', '1', '反洗钱web主机', '16G', '32C', '280G', '10.1.48.138', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-648', '2', 'FREEQUERY', '1', 'web端服务器', '64G', '4C', '2*600G', '10.1.48.193', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp3', '0', 'CAMS', '3', 'SD19pp3', null, null, null, '10.1.10.87', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL460-022', '0', 'CAMS', '1', 'BL460-022', null, null, null, '10.1.89.12', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860165', '0', 'CECM', '2', 'BL860165', '24G', '8C', '500G', '10.1.88.34', '10.1.88.40', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870031', '1', 'CECM', '3', 'BL870031', '64G', '8C', '500G', '10.1.8.215', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74013P1', '0', 'IBMS', '3', 'DB-S10.97', null, null, null, '10.1.10.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('dl380-066', '0', 'CAFCS', '2', 'APP主机', null, '2', null, '10.1.48.120', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-106', '0', 'IBMS', '2', 'APP-J88.58', null, null, null, '10.1.88.57', '10.1.88.57', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-408', '2', 'KTRADE', '1', 'WEB-S97.79', null, null, null, '10.1.97.79', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl680-066', '0', 'FCI', '2', 'bl680-066', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8409PH', '1', 'CCDSS', '3', 'RP8409PH', null, null, null, '10.1.10.4', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL680-029', '0', 'CCDSS', '2', 'HP-BL680-029', null, null, null, '10.1.48.224', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('service.cebbank.com', '0', 'OM', '3', 'service.cebbank.com', null, null, null, '10.1.88.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840DPU', '1', 'SUMMIT', '3', 'RP840DPU', null, null, null, '10.1.8.26', '10.1.8.25', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII15P1', '0', 'NPORT', '3', 'SDII15P1', null, null, null, '10.1.10.85', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870020', '0', 'PCRM', '1', '对私CRM服务器主机', null, null, null, '10.1.88.196', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('XYK', '0', 'OACMS', '3', ' 119-XYK-SD-CMS', null, null, null, '10.1.188.119', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-531', '0', 'ECM', '1', 'bl685-531', null, null, null, '10.1.5.142', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-576', '1', 'ECM', '1', '批量', null, null, null, '10.1.5.162', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P75022P1', '0', 'EBIP', '1', '通信服务器65', null, null, null, '10.1.96.65', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P75024P1', '0', 'EBIP', '1', '通信服务器68', null, null, null, '10.1.9.68', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7801P1', '0', 'EBIP', '2', '应用服务器132', null, null, null, '10.1.8.132', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7804P1', '0', 'EBIP', '2', '应用服务器94', null, null, null, '10.1.8.94', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860EPH', '0', 'NEXCH', '3', 'RX860EPH', null, null, null, '10.1.41.19', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P75016P2', '0', 'EBIS', '4', 'P75016P2', null, null, null, '10.254.253.19', '10.254.253.22', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P9', '0', 'GOLD', '2', 'P5954P9', null, null, null, '10.1.8.56', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74014P2', '0', 'EBIS', '1', 'P74014P2', null, null, null, '10.1.3.27', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-145', '0', 'EBPP', '1', 'BL685-145', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870022', '0', 'CCS', '3', 'WFDB-J40.19', null, null, null, '10.1.40.19', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860128', '0', 'CCS', '3', 'WFDB-J40.20', null, null, null, '10.1.40.20', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII11p2', '0', 'FUND', '3', 'SDII11p2', null, null, null, '10.1.8.47', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-574', '1', 'ECM', '1', 'bl685-574', null, null, null, '10.1.5.147', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7502P2', '1', 'EBIS', '4', 'P7502P2', null, null, null, '10.254.253.17', '10.254.253.22', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860022', '1', 'KTRADE', '2', 'APP-S44.110', null, null, null, '10.1.44.110', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860068', '1', 'KTRADE', '2', 'APP-J44.113', null, null, null, '10.1.44.113', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-454', '2', 'KTRADE', '1', 'WEB-S97.80', null, null, null, '10.1.97.80', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-257', '0', 'KTRADE', '1', 'WEB-J97.90', null, null, null, '10.1.97.90', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-273', '1', 'KTRADE', '1', 'WEB-J97.91', null, null, null, '10.1.97.91', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-264', '0', 'BOP', '2', 'APP-S44.177', null, null, null, '10.1.44.177', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-482', '0', 'BOP', '2', 'APP-J44.178', null, null, null, '10.1.44.178', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-483', '0', 'BOP', '2', 'APP-J44.179', null, null, null, '10.1.44.179', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74033P1', '1', 'BOP', '3', 'DB-S41.69', null, null, null, '10.1.41.69', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74034P1', '1', 'BOP', '3', 'DB-J41.71', null, null, null, '10.1.41.71', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-347', '0', 'BOP', '1', 'WEB-S97.95', null, null, null, '10.1.97.95', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-469', '0', 'BOP', '1', 'WEB-J97.96', null, null, null, '10.1.97.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-470', '0', 'BOP', '1', 'WEB-J97.97', null, null, null, '10.1.97.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-432', '0', 'BOP', '1', 'WEB-S3.40', null, null, null, '10.1.3.40', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-485', '1', 'BOP', '1', 'WEB-J3.41', null, null, null, '10.1.3.41', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('x3650-10', '0', 'MSG', '1', 'MAS-S26.23', null, null, null, '10.1.26.23', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('x3650-12', '1', 'MSG', '1', 'MAS-J26.24', null, null, null, '10.1.26.24', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('x3650-11', '1', 'MSG', '1', 'MAS-S26.26', null, null, null, '10.1.26.26', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-057', '2', 'NBANK', '2', 'APP-144', null, null, null, '10.1.44.144', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-020', '2', 'NBANK', '2', 'APP-145', null, null, null, '10.1.44.145', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-060', '2', 'NBANK', '2', 'APP-146', null, null, null, '10.1.44.146', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-101', '2', 'NBANK', '2', 'APP-147', null, null, null, '10.1.44.147', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-100', '2', 'NBANK', '2', 'APP-148', null, null, null, '10.1.44.148', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-103', '2', 'NBANK', '2', 'APP-149', null, null, null, '10.1.44.149', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-102', '2', 'NBANK', '2', 'APP-150', null, null, null, '10.1.44.150', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860125', '2', 'NBANK', '2', 'APP-151', null, null, null, '10.1.44.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860D2', '2', 'NBANK', '2', 'APP-152', null, null, null, '10.1.44.152', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860127', '2', 'NBANK', '2', 'APP-153', null, null, null, '10.1.44.153', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860D4', '2', 'NBANK', '2', 'APP-154', null, null, null, '10.1.44.154', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-439', '2', 'NBANK', '1', 'web-147', null, null, null, '10.1.97.147', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-303', '2', 'NBANK', '1', 'web-148', null, null, null, '10.1.97.148', null, '0');
commit;
prompt 200 records committed...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-297', '2', 'NBANK', '1', 'web-149', null, null, null, '10.1.97.149', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-309', '2', 'NBANK', '1', 'web-150', null, null, null, '10.1.97.150', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-522', '2', 'NBANK', '1', 'web-151', null, null, null, '10.1.97.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-305', '2', 'NBANK', '1', 'web-152', null, null, null, '10.1.97.152', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-348', '2', 'NBANK', '1', 'web-153', null, null, null, '10.1.97.153', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-471', '2', 'NBANK', '1', 'web-154', null, null, null, '10.1.97.154', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8616P3', '0', 'CCS', '2', 'WF-S48.4', '32G', '8C', '280G', '10.1.48.4', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860CPH', '0', 'NEXCH', '3', 'RX860CPH', null, null, null, '10.1.41.17', '10.1.41.15', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860075', '0', 'BEMS', '2', null, null, null, null, '10.1.88.49', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD11pp6', '0', 'CCS', '2', 'AG-J40.7', '32G', '8C', '280G', '10.1.40.7', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870017', '0', 'PCRM', '3', 'O库主机', null, '32', null, '10.1.8.168', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860EPI', '1', 'SAS', '2', 'APP备机', null, '4', null, '10.1.240.29', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860062', '0', 'BEMS', '2', null, null, null, null, '10.1.88.49', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860055', '0', 'BEMS', '3', null, null, null, null, '10.1.8.138', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860070', '0', 'BEMS', '3', null, null, null, null, '10.1.8.138', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD14pp5', '0', 'CCS', '2', 'AG-S40.8', '32G', '8C', '280G', '10.1.40.8', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD16pp5', '0', 'CCS', '2', 'AG-J40.9', '32G', '8C', '280G', '10.1.40.9', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-155', '0', 'CCS', '1', 'CSR-J48.1', '32G', '4C', '270G', '10.1.48.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-156', '0', 'CCS', '1', 'CSR-S48.2', '32G', '4C', '270G', '10.1.48.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-157', '0', 'CCS', '1', 'CSR-J48.3', '32G', '4C', '270G', '10.1.48.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8603P5', '0', 'ORM', '3', 'RX8603P5', '32G', '8C', '110G', '10.1.10.54', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840EPU', '0', 'SUMMIT', '3', 'RP840EPU', '8G', '8C', null, '10.1.8.24', '10.1.8.25', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860203', '0', 'EPAY', '2', 'BL860203', null, null, null, '10.1.3.37', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870006', '0', 'MSG', '2', 'APP+DB-J26.25', null, null, null, '10.1.26.25', '10.1.26.208', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870013', '0', 'CASS', '3', 'DB-S41.64', null, null, null, '10.1.41.64', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870003', '0', 'BCRM', '3', 'BL870003', '80', '32C', '320', '10.1.10.94', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870007', '1', 'BCRM', '3', 'BL870007', '80', '32C', '320', '10.1.10.95', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P2', '0', 'STQD', '2', 'APP-S89.130', null, '8C', null, '10.1.89.133', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5951P6', '0', 'STQD', '2', 'APP-J89.131', null, '8C', null, '10.1.89.131', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P11', '0', 'STQD', '3', 'DB-S41.43', null, '8C', null, '10.1.41.43', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5952P2', '0', 'STQD', '3', 'DB-J41.42', null, '8C', null, '10.1.41.42', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870012', '0', 'CASS', '3', 'DB-J41.65', null, null, null, '10.1.41.65', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-167', '0', 'MSG', '2', 'SALE-APP-J26.29', null, null, null, '10.1.26.29', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870001', '1', 'ANTI', '3', 'BL870001', '32G', '16C', '278G', '10.1.10.34', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860APC', '0', 'QCT', '3', 'DB2', null, null, null, '10.1.41.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8609PD', '0', 'QCT', '2', 'APP1', null, null, null, '10.1.48.13', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860074', '0', 'IPAD', '2', '应用+DB', null, null, null, '10.1.48.117', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-032', '1', '1104', '2', 'HP-BL685-032', null, null, null, '10.1.48.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-204', '0', 'EPAY', '2', 'IBL860-204', null, null, null, '10.1.3.36', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-048', '1', 'INTRA', '2', 'BL685-048', null, null, null, '10.1.188.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('cebweb4.101', '1', 'INTRA', '3', 'cebweb4.101', null, null, null, '10.1.188.101', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-166', '0', 'CEMB', '1', 'EWP-S97.27', null, null, null, '10.1.97.27', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-292', '0', 'CEMB', '1', 'WEB-S97.51', null, null, null, '10.1.97.51', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-295', '0', 'CEMB', '1', 'WEB-J97.54', null, null, null, '10.1.97.54', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-061', '0', 'SIDS', '2', 'BL680-061', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685135', '0', 'FTS', '2', 'BL685135', null, null, null, '10.1.74.17', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5702P3', '0', 'OTP', '2', 'P5702P3', null, null, null, '10.1.20.33', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5701P3', '0', 'OTP', '3', 'P5701P3', null, null, null, '10.1.8.166', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-585', '1', 'CRRS', '1', 'web端备机', '32', '4', '600', '10.1.48.153', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860107', '0', 'CRRS', '3', 'DB主机', null, '32', null, '10.1.41.88', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5953P5', '0', 'OAS', '3', '201-P5953P5-SD', '16G', '4C', null, '10.1.188.201', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-072', '0', 'OAS', '2', '18-BL685-072-JXQ', '16G', '4C', null, '10.1.188.18', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5952P7', '0', 'OAS', '3', '202-P5952P7-JXQ', '8G', '4C', null, '10.1.188.202', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL460-038', '0', 'OAS', '3', '55-BL460-038-SD', '4G', '2C', null, '10.1.188.55', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-164', '1', 'OAS', '2', '19-BL685-164-SD', '16G', '4C', null, '10.1.188.19', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('XYK2', '1', 'OAS', '3', '112-XYK2-JXQ', null, null, null, '10.1.188.112', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('XYK', '0', 'OAS', '3', '119-XYK-SD', null, null, null, '10.1.188.119', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('N139', '1', 'MIS', '1', 'web端备机', '8', '16', '410', '10.1.48.40', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-033', '0', 'RHDJZ', '2', 'APP备机', null, '32', null, '10.1.48.93', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8412P1', '1', 'MIS', '1', '中文语义APP备机', '16', '8', '62', '10.1.48.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-041', '1', 'PLR', '2', 'HP-BL685041', '16G', '4C', '300G', '10.1.48.69', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870019', '0', 'PCRM', '3', 'A库主机', null, '32', null, '10.1.10.104', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD7pp5', '0', 'CAMS', '3', 'SD7pp5', null, null, null, '10.1.10.48', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685002', '0', 'FTS', '2', 'BL685002', null, null, null, '10.1.74.16', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-142', '1', 'OACMS', '2', '108-BL680-142', null, null, null, '10.1.188.108', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860CPI', '0', 'SAS', '2', 'APP主机', null, '4', null, '10.1.240.27', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl680-067', '0', 'FCI', '2', 'bl680-067', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860067', '0', 'KTRADE', '2', 'APP-J44.112', null, null, null, '10.1.44.112', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-032', '0', 'CCR', '1', '个人征认主机服务', '16G', '32C', '280G', '10.1.48.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP840APH', '0', 'CCDSS', '3', 'RP840APH', null, null, null, '10.1.10.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860096', '0', 'SEAL', '3', null, null, null, null, '10.1.5.126', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII9P1', '0', 'NPORT', '3', 'SDII9P1', null, null, null, '10.1.10.52', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-034', '0', 'DMDOC', '2', 'BL685-034', null, null, null, '10.1.48.137', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('DL580-015', '1', 'DMDOC', '2', 'DL580-015', null, null, null, '10.1.48.43', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('vbv-trt', '0', 'VBV', '3', 'APP+DB-J3.100', null, null, null, '10.1.3.101', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD10pp6', '0', 'CCS', '2', 'AG-S40.6', '32G', '8C', '280G', '10.1.40.6', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-104', '0', 'CCS', '1', 'CSR-S48.16', '32G', '4C', '270G', '10.1.48.16', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-105', '0', 'CCS', '1', 'CSR-S48.17', '32G', '4C', '270G', '10.1.48.17', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-098', '0', 'CCS', '1', 'CSR-J48.18', '32G', '4C', '270G', '10.1.48.18', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-W02', '0', 'CCS', '1', 'CSR-W48.1', '32G', '4C', '270G', '10.226.48.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-W03', '0', 'CCS', '1', 'CSR-W48.2', '32G', '4C', '270G', '10.226.48.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-W04', '0', 'CCS', '1', 'CSR-W48.3', '32G', '4C', '270G', '10.226.48.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-W05', '0', 'CCS', '1', 'CSR-W48.4', '32G', '4C', '270G', '10.226.48.4', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5703P2', '0', 'CCS', '3', 'CTIDB-S138.91', '16G', '4C', '280G', '10.1.138.91', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5701P2', '0', 'CCS', '3', 'CTIDB-J138.93', '16G', '4C', '280G', '10.1.138.93', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5703P1', '0', 'CCS', '2', 'CTI-S138.94', '16G', '4C', '280G', '10.1.138.94', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5704P1', '0', 'CCS', '2', 'CTI-S138.95', '16G', '4C', '280G', '10.1.138.95', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5701P1', '0', 'CCS', '2', 'CTI-J138.96', '16G', '4C', '280G', '10.1.138.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5702P1', '0', 'CCS', '2', 'CTI-J138.97', '16G', '4C', '280G', '10.1.138.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-252', '0', 'EPAY', '2', 'IBL860-252', null, null, null, '10.1.3.38', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-48', '0', 'EPAY', '3', 'IBL860-48', null, null, null, '10.1.41.40', '10.1.41.40', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL870-040', '0', 'EPAY', '3', 'IBL870-040', null, null, null, '10.1.41.105', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-555', '0', 'EMAP', '2', 'bl685-555', null, null, null, '10.1.44.198', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-128', '0', 'EMAP', '1', 'BL680-128', null, null, null, '10.1.97.98', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-006', '0', 'FRS', '2', 'BL660-006', null, null, null, '10.1.20.54', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-529', '0', 'ECM', '1', 'bl685-529', null, null, null, '10.1.5.141', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-573', '1', 'ECM', '1', 'bl685-573', null, null, null, '10.1.5.146', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5951P1', '0', 'GOLD', '2', 'P5951P1', null, null, null, '10.1.8.117', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8603P7', '0', 'CCS', '3', 'AGDB-S40.1', '64G', '16C', '1030G', '10.1.40.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8604P7', '0', 'CCS', '3', 'AGDB-J40.2', '64G', '16C', '1030G', '10.1.40.2', null, '0');
commit;
prompt 300 records committed...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8605P7', '0', 'CCS', '3', 'AGDB-S40.3', '64G', '16C', '1030G', '10.1.40.3', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8606P7', '0', 'CCS', '3', 'AGDB-J40.15', '64G', '16C', '1030G', '10.1.40.15', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860185', '0', 'CCR', '3', '个人征信DB服务器', '64G', '8', '1.5T', '10.1.20.74', '10.1.20.76', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8606P8', '0', 'CCS', '2', 'WF-J48.5', '32G', '8C', '280G', '10.1.48.5', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD13pp8', '0', 'CCS', '2', 'WF-S48.73', '32G', '8C', '280G', '10.1.48.73', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD15pp8', '0', 'CCS', '2', 'WF-J48.74', '32G', '8C', '280G', '10.1.48.74', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp7', '0', 'CCS', '3', 'KMDB-S138.61', '32G', '8C', '500G', '10.1.138.61', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD18pp7', '0', 'CCS', '3', 'KMDB-J138.62', '32G', '8C', '500G', '10.1.138.62', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-57', '0', 'CCS', '2', 'KM-S138.65', '8G', '4C', '73G', '10.1.138.65', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-106', '0', 'CCS', '2', 'KM-J138.66', '8G', '4C', '73G', '10.1.138.66', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SIPServerBJ01', '0', 'CCS', '2', 'SIP-J139.102', null, null, null, '10.1.139.102', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SIPServerBJ02', '0', 'CCS', '2', 'SIP-J139.103', null, null, null, '10.1.139.103', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('ResourceManagerBJ01', '0', 'CCS', '2', 'RM-J139.111', null, null, null, '10.1.139.111', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('ResourceManagerBJ02', '0', 'CCS', '2', 'RM-J139.112', null, null, null, '10.1.139.112', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('MCPBJ01', '0', 'CCS', '2', 'MCP-J139.120', null, null, null, '10.1.139.120', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('MCPBJ02', '0', 'CCS', '2', 'MCP-J139.121', null, null, null, '10.1.139.121', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('MCPBJ03', '0', 'CCS', '2', 'MCP-J139.122', null, null, null, '10.1.139.122', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-103', '0', 'CCS', '2', 'FAX-S139.35', null, null, null, '10.1.139.35', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-185', '0', 'CCS', '2', 'FAX-J139.135', null, null, null, '10.1.139.135', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-102', '0', 'CCS', '2', 'TTS-S139.41', null, null, null, '10.1.139.41', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl680-076', '0', 'ESSC', '2', '10.1.10.108', null, null, null, '10.1.10.108', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-099', '0', 'CCS', '2', 'GVP-J48.164', null, null, null, '10.1.48.164', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-100', '0', 'CCS', '2', 'GVP-J48.165', null, null, null, '10.1.48.165', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-101', '0', 'CCS', '2', 'GVP-J48.166', null, null, null, '10.1.48.166', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL890002', '0', 'FTS', '3', 'BL890002', null, null, null, '10.1.74.13', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860DPH', '0', 'NEXCH', '3', 'RX860DPH', null, null, null, '10.1.41.18', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-007', '0', 'FRS', '2', 'BL660-007', null, null, null, '10.1.20.55', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-073', '2', 'CCS', '2', 'TTS-J139.141', null, null, null, '10.1.139.141', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-012', '0', 'FRS', '2', 'BL660-012', null, null, null, '10.1.20.56', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-013', '0', 'FRS', '2', 'BL660-013', null, null, null, '10.1.20.57', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-004', '0', 'FRS', '3', 'BL660-004', null, null, null, '10.1.10.135', '10.1.10.133', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL660-011', '0', 'FRS', '3', 'BL660-011', null, null, null, '10.1.10.134', '10.1.10.133', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870056', '0', 'GTS', '3', 'BL870056', null, null, null, '10.1.10.66', '10.1.10.70', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860186', '1', 'CCR', '3', '个人征信DB服务器', '64G', '8', '1.5T', '10.1.20.75', '10.1.20.76', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685523', '0', 'MSG', '2', 'IM-APP-S3.46', null, null, null, '10.1.3.46', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685495', '1', 'MSG', '2', 'IM-APP-J3.47', null, null, null, '10.1.3.47', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-288', '2', 'BCRM', '2', 'bl685-288', '16', '32', '260', '10.1.88.157', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685344', '0', 'CAIS', '1', 'HP-BL685-344', null, null, null, '10.1.48.125', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD25pp2', '0', 'AWP', '2', 'SD25pp2', null, null, null, '10.1.88.221', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD24pp2', '0', 'AWP', '2', 'SD24pp2', null, null, null, '10.1.88.220', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870028', '0', 'TAS', '3', 'BL870028', null, null, null, '10.1.8.57', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-346', '0', 'BOP', '1', 'WEB-S97.94', '32G', '4C', null, '10.1.97.94', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74031P1', '0', 'BOP', '3', 'DB-S41.68', '32G', '4C', null, '10.1.41.68', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-407', '0', 'BOP', '2', 'APP-S44.176', '64G', '4C', null, '10.1.44.176', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870004', '0', 'ANTI', '3', 'BL870001', '32G', '16C', '278G', '10.1.10.33', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74032P1', '1', 'BOP', '3', 'DB-J41.70', '32G', '4C', null, '10.1.41.70', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5951P2', '0', 'EBMP', '2', 'P5951P2', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-032', '0', 'MDS', '2', 'web端主机', null, '32', null, '10.1.48.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8609PC', '0', 'QCT', '3', 'DB1', null, null, null, '10.1.41.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860APD', '0', 'QCT', '2', 'APP2', null, null, null, '10.1.48.14', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-047', '0', 'INTRA', '2', 'BL685-047', null, null, null, '10.1.188.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-13', '0', 'PLDM', '2', 'BL680-13', '8G', '16', '136G', '10.1.88.16', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-17', '1', 'PLDM', '2', 'BL680-17', '8G', '16C', null, '10.1.88.17', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-533', '0', 'ECM', '1', 'bl685-533', null, null, null, '10.1.5.144', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-079', '0', 'CEMB', '1', 'EWP-J97.28', null, null, null, '10.1.97.28', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-293', '0', 'CEMB', '1', 'WEB-J97.52', null, null, null, '10.1.97.52', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-294', '0', 'CEMB', '1', 'WEB-S97.53', null, null, null, '10.1.97.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-60', '0', 'SIDS', '2', 'BL680-60', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('VBV-SHD', '0', 'VBV', '3', 'APP+DB-J3.102', null, null, null, '10.1.3.101', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5954P10', '1', 'OAS', '3', '20-P5954P10-SD', '8G', '4C', null, '10.1.188.20', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8411P1', '0', 'MIS', '1', '中文语义APP主机', '16', '8', '62', '10.1.48.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-158', '1', 'RWA', '2', ' HP-BL685-158', '32G', '4C', '300G', '10.1.48.52', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-159', '1', 'RWA', '2', 'HP-BL685-159', '32G', '4C', '300G', '10.1.48.54', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-027', '0', 'RHDJZ', '2', 'APP主机', null, '32', null, '10.1.48.223', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp1', '0', 'CAMS', '2', 'SD19pp1', null, null, null, '10.1.10.86', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL460-32', '0', 'CAMS', '1', 'BL460-32', null, null, null, '10.1.89.13', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870016', '0', 'PCRM', '3', 'O库备机', null, '32', null, '10.1.8.169', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('dl380-067', '1', 'CAFCS', '2', 'APP备机', null, '2', null, '10.1.48.122', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74014P1', '0', 'IBMS', '3', 'DB-J10.98', null, null, null, '10.1.10.98', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-277', '0', 'IBMS', '2', 'APP-S88.59', null, null, null, '10.1.88.59', '10.1.88.57', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5952P6', '0', 'GOLD', '2', 'P5952P6', null, null, null, '10.1.8.55', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('DL580-035', '1', 'MDS', '2', 'web端备机', null, '32', null, '10.1.48.140', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-027', '0', 'RHZFBB', '2', 'web端主机', null, '32', null, '10.1.48.223', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-033', '1', 'RHZFBB', '2', 'web端备机', null, '32', null, '10.1.48.93', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870014', '0', 'PLDM', '3', 'BL870014', null, null, null, '10.1.10.103', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74027P1', '0', 'ETRM', '3', 'P74027P1', null, null, null, '10.1.41.112', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74029P1', '0', 'ETRM', '3', 'P74029P1', null, null, null, '10.1.41.120', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-451', '0', 'ETRM', '2', 'bl685-451', null, null, null, '10.1.44.232', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8405PD', '0', 'ECM', '3', '数据库服务器', null, null, null, '10.1.5.155', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8405PE', '1', 'ECM', '2', '应用服务器', null, null, null, '10.1.5.135', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-65', '1', 'ORM', '2', 'BL680-65', '16G', '16C ', '130G ', '10.1.88.119', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-600', '0', 'BCS', '3', 'BL685-600', '16G', '32C', '300G', '10.1.88.106', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('n139', '1', 'ANTI', '1', '反洗钱WEB备机', '16G', '8C', '400G', '10.1.48.40', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860166', '1', 'CECM', '2', 'BL860166', '24G', '8C', '500G', '10.1.88.35', '10.1.88.40', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74028P1', '0', 'ETRM', '3', 'P74028P1', null, null, null, '10.1.41.123', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SEAL-APP-TRT-1', '0', 'SEAL', '2', null, null, null, null, '10.1.5.129', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('ECM-SEAL-SHD-1', '0', 'SEAL', '2', null, null, null, null, '10.1.5.128', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-467', '0', 'ETRM', '2', 'bl685-467', null, null, null, '10.1.44.234', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-468', '0', 'ETRM', '2', 'bl685-468', null, null, null, '10.1.44.235', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860097', '0', 'SEAL', '3', null, null, null, null, '10.1.5.125', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870021', '1', 'PCRM', '1', '对私CRM服务器备机', null, null, null, '10.1.88.194', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD25pp3', '0', 'EPAMS', '3', 'SD25pp3', null, null, null, '10.1.201.10', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD25pp4', '0', 'EPAMS', '3', 'SD25pp4', null, null, null, '10.1.201.11', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl680-045', '0', 'ESSC', '2', '10.1.10.107', null, null, null, '10.1.10.107', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870027', '0', 'TAS', '3', 'BL870027', null, null, null, '10.1.8.57', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD25pp1', '0', 'PLMS', '2', 'SD25pp1', null, null, null, '10.1.88.14', '10.1.88.15', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD14pp6', '0', 'FUND', '2', 'SD14pp6', null, null, null, '10.1.8.122', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('sd13pp1', '0', 'ECIF', '3', 'DB1', null, null, null, '10.1.41.6', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870015', '1', 'PLDM', '3', 'BL870015', null, null, null, '10.1.10.102', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-263', '0', 'ETRM', '2', 'bl685-263', null, null, null, '10.1.44.221', '10.1.44.220', '0');
commit;
prompt 400 records committed...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7405P1', '0', 'ETRM', '3', 'P7405P1', null, null, null, '10.1.41.116', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-575', '1', 'ECM', '1', 'bl685-575', null, null, null, '10.1.5.145', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-244', '0', 'ETRM', '2', 'bl685-244', null, null, null, '10.1.44.225', '10.1.44.224', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-243', '0', 'ETRM', '2', 'bl685-243', null, null, null, '10.1.44.229', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-242', '0', 'ETRM', '2', 'bl685-242', null, null, null, '10.1.44.218', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD5pp6', '0', 'GTS', '3', 'SD5pp6', null, null, null, '10.1.10.65', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD6pp7', '0', 'GTS', '3', 'SD6pp7', null, null, null, '10.1.10.72', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8409PJ', '0', 'CASS', '2', 'APP-J3.2', null, null, null, '10.1.3.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-530', '0', 'ECM', '1', 'bl685-530', null, null, null, '10.1.5.143', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBAPP01', '0', 'NPORT', '2', 'CEBWEB04', '8G', '4C', '200G', '10.1.20.67', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBAPP02', '0', 'NPORT', '2', 'CEBAPP02', '8G', '4C', '200G', '10.1.20.68', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBAPP04', '0', 'NPORT', '2', 'CEBAPP04', '8G', '4C', '200G', '10.1.20.70', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD1pp7', '0', 'TAS', '2', 'SD1pp7', null, null, null, '10.1.8.56', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-142', '2', 'NBANK', '1', 'web-136', null, null, null, '10.1.97.136', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-141', '2', 'NBANK', '1', 'web-134', null, null, null, '10.1.97.134', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-118', '0', 'EPAMS', '2', '企业年金', null, null, null, '10.1.44.75', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-119', '0', 'EPAMS', '2', '企业年金', null, null, null, '10.1.48.59', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-121', '0', 'EPAMS', '2', '企业年金', null, null, null, '10.1.48.58', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-122', '0', 'EPAMS', '2', '企业年金', null, null, null, '10.1.44.74', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P75023P1', '0', 'EBIP', '1', '通信服务器67', null, null, null, '10.1.96.67', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-577', '1', 'ECM', '1', 'bl685-577', null, null, null, '10.1.5.148', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITPROD2', '0', 'SUMMIT', '2', 'SUMMITPROD2', null, null, null, '10.1.88.78', '10.1.88.79', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8404PD', '1', 'ECM', '3', '数据库服务器', null, null, null, '10.1.5.154', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8407PD', '0', 'ECM', '3', '数据库服务器', null, null, null, '10.1.5.157', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8404PE', '1', 'ECM', '2', '应用服务器', null, null, null, '10.1.5.134', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8407PE', '1', 'ECM', '2', '应用服务器', null, null, null, '10.1.5.137', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-216', '1', 'EFACT', '1', 'WEB服务器', null, null, null, '10.1.48.84', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860021-33', '0', 'EFACT', '2', 'APP+DB浮动IP', null, null, null, '10.1.44.98', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860021', '1', 'EFACT', '2', 'APP+DB服务器', null, null, null, '10.1.44.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8604P5', '1', 'ORM', '3', 'RX8604P5', '32G ', '8C', '110G', '10.1.10.56', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7802P1', '0', 'EBIP', '2', '应用服务器92', null, null, null, '10.1.8.92', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8616P1', '0', 'NPORT', '3', 'RX8616P1', null, null, null, '10.1.10.85', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD8pp0', '0', 'ECAS', '2', '主机1', '128', '64c', '300G*2', '10.1.8.1', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-554', '0', 'BCS', '2', 'BL685-554', '16G', '32C', '300G', '10.1.88.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-116', '0', 'ESSC', '2', 'BL685-116', null, null, null, '10.1.8.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8405PR', '0', 'CEMB', '2', 'APP-S41.73', null, null, null, '10.1.41.73', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('service1.cebbank.com', '1', 'OM', '3', 'service1.cebbank.com', null, null, null, '10.1.88.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-117', '0', 'ESSC', '2', 'BL685-117', null, null, null, '10.1.8.97', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP4440-2', '2', 'NBANK', '2', 'RP4440-2', null, null, null, '10.1.8.33', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP4440-3', '2', 'NBANK', '2', 'RP4440-3', null, null, null, '10.1.8.173', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP4440-7', '2', 'NBANK', '2', 'RP4440-7', null, null, null, '10.1.8.32', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP4440-8', '2', 'NBANK', '2', 'RP4440-8', null, null, null, '10.1.8.30', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('WIN-60SG05GINA7', '0', 'CRDM', '1', 'PC Server BL680', '16G', '4C', '3*300G', '10.1.48.154', '10.1.48.156', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD11pp9', '2', 'NBANK', '2', 'SD11pp9', null, null, null, '10.1.8.8', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-110', '0', 'ESSC', '2', 'BL685-110', null, null, null, '10.1.8.98', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860BPE', '0', 'NPORT', '3', 'RX860BPE', null, null, null, '10.1.10.52', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD7pp6', '0', 'GTS', '3', 'SD7pp6', null, null, null, '10.1.10.67', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-111', '0', 'ESSC', '2', 'BL685-111', null, null, null, '10.1.8.99', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-558', '1', 'ISP', '1', '创新服务平台备机', null, null, null, '10.1.48.170', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-44', '0', 'EPAY', '2', 'IBL860-44', null, null, null, '10.1.3.34', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-4', '0', 'EPAY', '2', 'IBL860-4', null, null, null, '10.1.3.33', '10.1.3.6', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('XYK2', '1', 'OACMS', '3', ' 112-XYK-SD-CMS', null, null, null, '10.1.188.112', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD13pp2', '0', 'ECIF', '2', '应用1', null, null, null, '10.1.44.16', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD14pp2', '0', 'ECIF', '2', '应用2', null, null, null, '10.1.44.17', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('sd14pp1', '0', 'ECIF', '3', 'DB2', null, null, null, '10.1.41.7', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870005', '0', 'MSG', '2', 'APP+DB-J26.8', null, null, null, '10.1.26.8', '10.1.26.208', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-532', '0', 'ECM', '1', '批量', null, null, null, '10.1.5.161', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBAPP03', '0', 'NPORT', '2', 'CEBAPP03', '8G', '4C', '200G', '10.1.20.69', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-2', '0', 'EPAY', '2', 'IBL860-2', null, null, null, '10.1.3.32', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P75021P1', '0', 'EBIP', '1', '通信服务器64', null, null, null, '10.1.96.64', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7803P1', '0', 'EBIP', '2', '应用服务器134', null, null, null, '10.1.8.134', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBWEB01', '0', 'NPORT', '1', 'CEBWEB01', null, null, null, '10.1.97.101', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBWEB02', '0', 'NPORT', '1', 'CEBWEB02', null, null, null, '10.1.97.102', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBWEB03', '0', 'NPORT', '1', 'CEBWEB03', null, null, null, '10.1.97.103', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('CEBWEB04', '0', 'NPORT', '1', 'CEBWEB04', null, null, null, '10.1.97.104', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-146', '1', 'IAM', '2', 'BL680-146', null, null, null, '10.1.90.37', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-132', '1', 'IAM', '2', 'BL680-132', null, null, null, '10.1.90.36', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-143', '0', 'IAM', '2', 'BL680-143', null, null, null, '10.1.90.32', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-144', '0', 'IAM', '2', 'BL680-144', null, null, null, '10.1.90.33', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8605P9', '0', 'IAM', '2', 'RX8605P9', null, null, null, '10.1.90.34', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX8606P9', '0', 'IAM', '2', 'RX8606P9', null, null, null, '10.1.90.38', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD8pp6', '0', 'GTS', '3', 'SD8pp6', null, null, null, '10.1.10.68', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5704P3', '0', 'OTP', '2', 'P5704P3', null, null, null, '10.1.20.25', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5704P4', '1', 'OTP', '3', 'P5704P4', null, null, null, '10.1.8.151', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5702P4', '0', 'OTP', '3', 'P5702P4', null, null, null, '10.1.8.152 ', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-547', '0', 'JCDC', '2', 'bl685-547', null, null, null, '10.254.253.28', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-606', '0', 'ISP', '1', null, null, null, null, '10.1.48.172', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-217', '0', 'EFACT', '1', 'WEB服务器', null, null, null, '10.1.48.85', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860033', '0', 'EFACT', '2', 'APP+DB服务器', null, null, null, '10.1.44.96', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5953P2', '0', 'EBMP', '2', 'P5953P2', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-594', '0', 'JCDC', '2', 'bl685-594', null, null, null, '10.254.253.29', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITBACK', '1', 'SUMMIT', '2', 'SUMMITBACK', null, null, null, '10.1.88.77', '10.1.88.76', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-601', '0', 'EMAP', '2', 'bl685-601', null, null, null, '10.1.44.199', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7402P1', '0', 'EBPP', '2', 'POS收单', null, null, null, '10.1.84.4', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-101', '0', 'EMAP', '1', 'BL680-101', null, null, null, '10.1.97.99', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-89', '0', 'GTS', '2', 'BL680-89', null, null, null, '10.1.20.16', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-259', '0', 'SUMMIT', '2', 'BL685-259', null, null, null, '10.1.3.13', '10.1.3.20', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD8pp7', '0', 'GTS', '3', 'SD8pp7', null, null, null, '10.1.10.74', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-260', '1', 'SUMMIT', '2', 'HP-BL685-260', null, null, null, '10.1.3.14', '10.1.3.20', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITBACK2', '1', 'SUMMIT', '2', 'SUMMITBACK2', null, null, null, '10.1.88.80', '10.1.88.79', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860077', '0', 'GSALE', '2', 'BL860077', null, null, null, '10.1.44.117', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp4', '0', 'PLMS', '3', 'SD19pp4', null, null, null, '10.1.10.40', '10.1.10.41', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7803P4', '2', 'IBCARMS', '3', 'P7803P4', '48G', '8C', '300G', '10.1.48.114', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITPROD', '0', 'SUMMIT', '2', 'summitprod', '64G', '16C', '146G', '10.1.88.76', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD6pp0', '0', 'ECAS', '2', '灾备主机', '128G', '64', '300G*2', '10.1.8.11', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITBACK3', '1', 'SUMMIT', '2', 'SUMMITBACK3', null, null, null, '10.1.88.87', '10.1.88.86', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7502P1', '1', 'FCS', '2', 'APPDB2', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7501P1', '0', 'FCS', '2', 'APPDB1', null, null, null, null, null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD1pp8', '0', 'NBANK', '3', 'SD1pp8', null, null, null, '10.1.8.171', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-82', '0', 'GTS', '2', 'BL680-82', null, null, null, '10.1.20.17', null, '0');
commit;
prompt 500 records committed...
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SUMMITPROD3', '0', 'SUMMIT', '2', 'SUMMITPROD3', null, null, null, '10.1.88.85', '10.1.88.86', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SDII10p2', '0', 'FUND', '3', 'SDII10p2', null, null, null, '10.1.8.45', '10.1.8.122', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P5953P1', '0', 'GOLD', '2', 'P5953P1', null, null, null, '10.1.8.116', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp2', '0', 'ECIF', '2', '应用3', null, null, null, '10.1.48.23', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-125', '0', 'CEMB', '1', 'EWP-J97.26', '16', '4', '600', '10.1.97.26', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('HP-BL685-126', '0', 'CEMB', '1', 'EWP-S97.25', '16', '4', '600', '10.1.97.25', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values (' BL685-503', '1', 'CRDM', '1', 'PC Server BL680', '16G', '4C', '2*300G', '10.1.48.155', '10.1.48.156', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD13pp6', '0', 'FUND', '2', 'SD13pp6', '16G', '4C', null, '10.1.8.121', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860139', '0', 'CRDM', '4', '小型机 HPitanium', '32G', '8C', '2*300G', '10.1.41.102', '10.1.41.104', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD6pp6', '0', 'GTS', '3', 'SD6pp6', null, null, null, '10.1.10.66', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL860140', '1', 'CRDM', '4', '小型机 HPitanium', '32G', '8C', '2*300G', '10.1.41.103', '10.1.41.104', '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-588', '0', 'BCS', '2', 'BL685-588', '16G', '32C', '300G', '10.1.88.53', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-143', '2', 'NBANK', '1', 'web-138', null, null, null, '10.1.97.138', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-152', '2', 'NBANK', '1', 'web-133', null, null, null, '10.1.97.133', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7401P1', '0', 'EBPP', '2', 'POS收单系统', null, null, null, '10.1.84.2', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD19pp5', '0', 'AWP', '3', 'SD19pp5', null, null, null, '10.1.10.38', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD18pp3', '0', 'AWP', '3', 'SD18pp3', null, null, null, '10.1.10.37', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP8407PS', '0', 'REPORT', '2', 'RP8407PS', null, null, null, '10.1.7.28', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-543', '0', 'BCS', '3', 'bl685-543', '16G', '32C', '300G', '10.1.88.106', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P74039P1', '0', 'FDS', '4', 'P74039P1', null, null, null, '10.1.20.47', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('bl685-266', '2', 'KTRADE', '1', 'WEB-S97.77', '32', '4', '300', '10.1.97.77', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('IBL860-11', '0', 'EPAY', '3', 'IBL860-11', '32', '8', '300', '10.1.41.38', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RX860BPH', '0', 'NEXCH', '3', 'RX860BPH', null, null, null, '10.1.41.15', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('P7404P1', '0', 'EBPP', '2', 'POS收单', null, null, null, '10.1.84.5', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL870002', '0', 'MSG', '2', 'APP+DB-S26.20', null, null, null, '10.1.26.20', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-005', '0', 'NEXCH', '1', 'BL685-005', null, null, null, '10.1.44.32', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD4pp8', '2', 'NBANK', '3', 'SD4pp8', '8', '10C', '300G', '10.1.8.102', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('RP4440-1', '2', 'NBANK', '2', 'RP4440-1', '8', '6C', '200G', '10.1.8.74', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-129', '0', 'IAM', '2', 'BL685-129', null, null, null, '10.1.90.44', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL685-136', '2', 'NBANK', '1', 'web-144', null, null, null, '10.1.97.144', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('SD7pp7', '0', 'GTS', '3', 'SD7pp7', null, null, null, '10.1.10.73', null, '0');
insert into SERVER_CONF (SRV_CODE, LOAD_MODE, APL_CODE, SER_CLASS, SER_NAME, MEM_CONF, CPU_CONF, DISK_CONF, IP_ADDRESS, FLOAT_ADDRESS, AUTO_CAPTURE)
values ('BL680-77', '0', 'GTS', '2', 'BL680-77', null, null, null, '10.1.20.7', null, '0');
commit;
prompt 532 records loaded
prompt Loading SYS_DATE...
prompt Table is empty
prompt Loading SYS_RESRC...
prompt Table is empty
prompt Loading SYS_RESRC_STSTCS_ITEMS...
prompt Table is empty
prompt Loading SYS_RESRC_TRANS...
prompt Table is empty
prompt Loading TIMES_TRANS_CONF...
prompt Table is empty
prompt Loading TRAN_ITEM...
prompt Table is empty
prompt Loading WEBLOGIC_CONF...
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('VBV', '10.1.3.101', 'ACS', '0', 'ACS', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRDS', '10.1.88.67', 'myserver', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('GSALE', '10.1.44.118', 'appserver', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.72', 'MbankServer', '0', 'MbankServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.73', 'MClientServer', '0', 'MClientServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.73', 'MbankServer', '0', 'MbankServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_03', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_01', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_02', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_cache', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CASS', '10.1.3.1', 'AdminServer', '0', 'AdminServer_base', '17101');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.6', 'Server61', '0', 'SD10pp6', '9083');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.6', 'Server62', '0', 'SD10pp6', '9084');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.7', 'Server71', '0', 'SD10pp6', '9083');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.7', 'Server72', '0', 'SD10pp6', '9084');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CECM', '10.1.88.40', 'AppServer2', '0', 'AppServer2', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CECM', '10.1.88.40', 'AppServer3', '0', 'AppServer3', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.4', 'MClientServer', '0', 'MClientServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.5', 'MClientServer', '0', 'MClientServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.4', 'MbankServer', '0', 'MbankServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.88', 'ICSlave2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.65', 'DPServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.89', 'ICSlave2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.70', 'AMCAdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.70', 'AMCManagedServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.87', 'ICAdmin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.86', 'ICSlave1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.71', 'AMCAdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.86', 'ICAdmin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.71', 'AMCManagedServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.141', 'WebServer1', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.141', 'SvcServer1', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EFACT', '10.1.44.98', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EFACT', '10.1.44.98', 'Server-nfs', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'eprkServer2_1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'eprkServer1_1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'eprkServer2_2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'csgServer2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.44.74', 'eprkServer1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'SzServer1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'eprkServer1_2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'csgServer1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('GOLD', '10.1.8.117', 'mktserver1', '0', 'mktserver1', '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('GOLD', '10.1.8.117', 'appserver', '0', 'appserver', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('GOLD', '10.1.8.117', 'mktserver2', '0', 'mktserver2', '16104');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.37', 'portal', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.37', 'AdminServer_portal', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.37', 'AdminServer_server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.32', 'casp', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.32', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.33', 'portal', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.33', 'server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.36', 'iamemergency', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.36', 'casp', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'B2EServer', '0', 'B2EServer', '16102');
commit;
prompt 100 records committed...
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.59', 'EACServer', '0', 'EACServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.57', 'EACServer', '0', 'EACServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.141', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.114', 'cfim_server1', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.114', 'cfim_server2', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.114', 'tokenm_server1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.114', 'tokenm_ag_server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'cfim_server1', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'cfim_server2', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'cfim_server3', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'tokenm_server1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'tokenm_ag_server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBCARMS', '10.1.48.115', 'tokenm_server_sch', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.144', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.143', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.146', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.33', 'exchServer', '0', 'exchServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.34', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.33', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.32', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.32', 'exchServer', '0', 'exchServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.35', 'exchServer', '0', 'exchServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.35', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NEXCH', '10.1.44.34', 'exchServer', '0', 'exchServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.1', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.2', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.3', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.4', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OTP', '10.1.20.25', 'ESS', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OTP', '10.1.20.25', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OTP', '10.1.20.24', 'ESS', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OTP', '10.1.20.24', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms4', '0', 'plms4', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms5', '0', 'plms5', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms6', '0', 'plms6', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms1', '0', 'plms1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms2', '0', 'plms2', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLMS', '10.1.88.15', 'plms3', '0', 'plms3', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('REPORT', '10.1.7.28', 'myserver', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('REPORT', '10.1.7.28', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('VBV', '10.1.3.101', 'examplesServer', '0', 'examplesServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.68', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.68', 'BiofficeServer', '0', 'BiofficeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.69', 'BiofficeServer', '0', 'BiofficeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.69', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRRS', '10.1.48.152', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRRS', '10.1.48.153', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'DAServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'SunConsoleServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'SunDMServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'SunIASServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBMS', '10.1.88.57', 'ibServer', '0', 'ibServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.32', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.32', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.41.40', 'EpayOutBServer', '0', 'EpayOutBServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('MSG', '10.1.26.208', 'emdapp', '0', 'emdapp', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('MSG', '10.1.26.208', 'EmdServer', '0', 'EmdServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCS', '10.1.88.53', 'BcsServer2', '0', 'BcsServer2', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('FREEQUERY', '10.1.48.192', 'FreequeryServer02', '0', 'FreequeryServer02', '17101');
commit;
prompt 200 records committed...
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('FREEQUERY', '10.1.48.192', 'IndexServer', '0', 'IndexServer', '17101');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.8', 'Server81', '0', 'SD10pp6', '9083');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLDM', '10.1.88.16', 'BiofficeServer', '0', 'BiofficeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLDM', '10.1.88.17', 'BiofficeServer', '0', 'BiofficeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLDM', '10.1.88.16', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLDM', '10.1.88.17', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.105', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.107', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.105', 'CmsServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.107', 'cmsServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.105', 'ArchServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('OACMS', '10.1.188.107', 'archivesServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('INTRA', '10.1.188.2', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('INTRA', '10.1.188.2', 'intraServer', '0', 'intraServer', '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('INTRA', '10.1.188.3', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('INTRA', '10.1.188.3', 'intraServer', '0', 'intraServer', '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BOP', '10.1.44.176', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BOP', '10.1.44.176', 'BatchServer176', '0', 'BatchServer176', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BOP', '10.1.44.176', 'ConsoleServer176', '0', 'ConsoleServer176', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BOP', '10.1.44.176', 'MCAServer176', '0', 'MCAServer176', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BOP', '10.1.44.176', 'MCMServer176', '0', 'MCMServer176', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'SunConsoleServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'SunDMServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'DAServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'SunIASServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('QCT', '10.1.48.14', 'qct_app_server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('QCT', '10.1.48.14', 'qct_server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ANTI', '10.1.48.138', 'myserver', '0', 'myserver103', '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.32', 'iamemergency', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CASS', '10.1.3.1', 'AdminServer', '0', 'AdminServer_web', '17102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverA1', '0', 'dgocrm_serverA1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverA2', '0', 'dgocrm_serverA2', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverA3', '0', 'dgocrm_serverA3', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverB1', '0', 'dgocrm_serverB1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverB2', '0', 'dgocrm_serverB2', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCRM', '10.1.88.158', 'dgocrm_serverB3', '0', 'dgocrm_serverB3', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('VBV', '10.1.3.101', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('VBV', '10.1.3.101', 'vbvserver', '0', 'vbvserver', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRRS', '10.1.48.152', 'Crrs2Sever', '0', 'Crrs2Sever', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.4', 'AdminServer', '0', 'SD13pp8', '7701');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.124', 'SunECMConsoleServer', '0', ' ', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CAIS', '10.1.48.125', 'SunECMConsoleServer', '0', ' ', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.142', 'SvcServer2', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.142', 'WebServer2', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.143', 'SvcServer3', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.143', 'WebServer3', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.144', 'SvcServer4', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.144', 'WebServer4', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.145', 'SvcServer5', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.145', 'WebServer5', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.146', 'SvcServer6', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.146', 'WebServer6', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.147', 'SvcServer7', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.147', 'WebServer7', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.148', 'SvcServer8', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ECM', '10.1.5.148', 'WebServer8', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCS', '10.1.88.53', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('FREEQUERY', '10.1.48.192', 'AdminServer', '0', 'FreequeryServerClust', '17101');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('FREEQUERY', '10.1.48.193', 'AdminServer', '0', 'FreequeryServerClust', '17101');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.8', 'Server82', '0', 'SD10pp6', '9084');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.9', 'Server91', '0', 'SD10pp6', '9083');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.40.9', 'Server92', '0', 'SD10pp6', '9084');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.1', 'ManagedServer1-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.1', 'ManagedServer1-2', '0', 'BL680-156', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.16', 'ManagedServer5-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.16', 'ManagedServer5-2', '0', 'BL680-156', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.164', 'GVPServer164-1', '0', 'bl685-099', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.164', 'GVPServer164-2', '0', 'bl685-099', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.17', 'ManagedServer6-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.17', 'ManagedServer6-2', '0', 'BL680-156', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.18', 'ManagedServer4-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.2', 'ManagedServer2-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.3', 'ManagedServer3-1', '0', 'BL680-156', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.3', 'ManagedServer3-2', '0', 'BL680-156', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.5', 'server2-1', '0', 'SD13pp8', '7703');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.73', 'server3-1', '0', 'SD13pp8', '7703');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.4', 'server1-2', '0', 'SD13pp8', '7705');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.5', 'server2-2', '0', 'SD13pp8', '7705');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.4', 'server1-1', '0', 'SD13pp8', '7703');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.73', 'server3-2', '0', 'SD13pp8', '7705');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.74', 'server4-2', '0', 'SD13pp8', '7705');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.74', 'server4-1', '0', 'SD13pp8', '7703');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.1', 'ManagedServer1-1', '0', 'BL685-W02', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.1', 'ManagedServer1-2', '0', 'BL685-W02', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.2', 'ManagedServer2-1', '0', 'BL685-W02', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.2', 'ManagedServer2-2', '0', 'BL685-W02', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.3', 'ManagedServer3-1', '0', 'BL685-W02', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.3', 'ManagedServer3-2', '0', 'BL685-W02', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.4', 'ManagedServer4-1', '0', 'BL685-W02', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.226.48.4', 'ManagedServer4-2', '0', 'BL685-W02', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRDM', '10.1.48.154', 'bi_server1', '0', 'bi_server1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CRDM', '10.1.48.155', 'bi_server1', '0', 'bi_server1', '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.67', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('STQD', '10.1.89.133', 'AppServer', '0', 'AppServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('STQD', '10.1.89.133', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_04', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_05', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'awp_ms_06', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.69', 'IndexServer', '0', 'IndexServer', '16102');
commit;
prompt 300 records committed...
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PLR', '10.1.48.69', 'ScheduletaskServer', '0', 'ScheduletaskServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('RWA', '10.1.48.51', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('RWA', '10.1.48.51', 'RWAServer', '0', 'RWAServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('RWA', '10.1.48.52', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('RWA', '10.1.48.52', 'RWAServer', '0', 'RWAServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.72', 'MClientServer', '0', 'MClientServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('AWP', '10.1.88.220', 'proxyserver', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.68', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.69', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.70', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CASS', '10.1.3.1', 'cassbaseServer', '0', 'cassbaseServer', '7001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.67', 'NportServer1', '0', 'NportServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CECM', '10.1.88.40', 'AppServer1', '0', 'AppServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.5', 'MbankServer', '0', 'MbankServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.48.65', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EBIC', '10.1.44.87', 'ICSlave1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.68', 'NportServer1', '0', 'NportServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.69', 'NportServer1', '0', 'NportServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NPORT', '10.1.20.70', 'NportServer1', '0', 'NportServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.48.58', 'SzServer2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.44.74', 'Admin', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAMS', '10.1.44.74', 'eprkServer2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.37', 'server', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.33', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IAM', '10.1.90.36', 'AdminServer_casp', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.135', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.136', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.137', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'MgmtServer', '0', 'MgmtServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.145', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.40', 'EACServer', '0', 'EACServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.132', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCDSS', '10.1.48.224', 'myserver', '0', 'myserver', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCDSS', '10.1.48.191', 'myserver', '0', 'myserver', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('DMDOC', '10.1.48.137', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('DMDOC', '10.1.48.43', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('IBMS', '10.1.88.57', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ANTI', '10.1.48.138', 'myserver', '0', 'myserver102', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CECM', '10.1.88.40', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CASS', '10.1.3.1', 'casswebServer', '0', 'casswebServer', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ORM', '10.1.88.118', 'oprisk1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('1104', '10.1.48.151', 'myserver', '0', 'myserver', '16104');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('1104', '10.1.48.140', 'myserver', '0', null, '16104');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCR', '10.1.48.151', 'myserver', '0', 'myserver', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.133', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.140', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.142', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.138', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.131', 'MgmtServer', '0', 'MgmtServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.139', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.58', 'EACServer', '0', 'EACServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.134', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'AppServer1', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'AppServer2', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'AppServer3', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'AdminServer', '0', null, '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'WTCAppServer', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('PCRM', '10.1.88.195', 'WTCAdminServer', '0', null, '16103');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ETRM', '10.1.44.218', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ETRM', '10.1.44.218', 'oaam_server_server1', '0', 'oaam_server_server1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ETRM', '10.1.44.232', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ETRM', '10.1.44.232', 'oaam_server_server1', '0', 'oaam_server_server1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.73', 'MPServer', '0', 'MPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.72', 'MPServer', '0', 'MPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.5', 'MPServer', '0', 'MPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CEMB', '10.1.41.4', 'MPServer', '0', 'MPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.33', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.34', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.36', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.37', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.38', 'EpayInServer', '0', 'EpayInServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.33', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.38', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.37', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.36', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('EPAY', '10.1.3.34', 'EpayOutServer', '0', 'EpayOutServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.165', 'GVPServer165-1', '0', 'bl685-099', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.165', 'GVPServer165-2', '0', 'bl685-099', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.166', 'GVPServer166-1', '0', 'bl685-099', '8001');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('CCS', '10.1.48.166', 'GVPServer166-2', '0', 'bl685-099', '8002');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.147', 'THPServer', '0', 'THPServer', '16102');
commit;
prompt 400 records committed...
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.148', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.149', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.150', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('ISP', '10.1.48.172', 'IspServer', '0', 'IspServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('BCS', '10.1.88.53', 'BcsServer1', '0', 'BcsServer1', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.151', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.152', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.153', 'THPServer', '0', 'THPServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'AdminServer', '0', 'AdminServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'AgreePayServer', '0', 'AgreePayServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'B2EServer', '0', 'B2EServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'EntServer', '0', 'EntServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'KtradeServer', '0', 'KtradeServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'PerServer', '0', 'PerServer', '16102');
insert into WEBLOGIC_CONF (APL_CODE, IP_ADDRESS, SERVER_NAME, WEBLOGIC_FLG, CLUSTER_SERVER, WEBLOGIC_PORT)
values ('NBANK', '10.1.44.154', 'THPServer', '0', 'THPServer', '16102');
commit;
set feedback on
set define on
prompt Done.



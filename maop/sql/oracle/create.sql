/*==============================================================*/
/* DBMS name:      ORACLE Version 10gR2                         */
/* Created on:     2011/4/11 11:11:03                           */
/*==============================================================*/


alter table JEDA_FIELD
   drop constraint FUNCTION_FIELD;

alter table JEDA_FUNCTION
   drop constraint FUNCTION_MODULE;

alter table JEDA_MENU
   drop constraint MENU_PARENT;

alter table JEDA_PERMISSION
   drop constraint ITEM_PERMISSION;

alter table JEDA_PERMISSION
   drop constraint PERMISSION_FIELD;

alter table JEDA_PERMISSION_ORG
   drop constraint PERMISSION_ORG;

alter table JEDA_PERMISSION_ORG
   drop constraint PERMISSION_ORG2;

alter table JEDA_PERMISSION_USER
   drop constraint PERMISSION_USER;

alter table JEDA_PERMISSION_USER
   drop constraint PERMISSION_USER2;

alter table JEDA_PORTLET_LOCATION
   drop constraint PORTLET_LOCATION_POR;

alter table JEDA_PORTLET_LOCATION
   drop constraint POSITION_PORTLET_LOC;

alter table JEDA_POSITION_ORG
   drop constraint POSITION_ORG;

alter table JEDA_POSITION_ORG
   drop constraint POSITION_ORG2;

alter table JEDA_POSITION_PL
   drop constraint POSITION_PL;

alter table JEDA_POSITION_PL
   drop constraint POSITION_PL2;

alter table JEDA_ROLE_FUNCTION
   drop constraint ROLE_FUNCTION;

alter table JEDA_ROLE_FUNCTION
   drop constraint ROLE_FUNCTION2;

alter table JEDA_ROLE_MENU
   drop constraint ROLE_MENU;

alter table JEDA_ROLE_MENU
   drop constraint ROLE_MENU2;

alter table JEDA_ROLE_PERMISSION
   drop constraint ROLE_PERMISSION;

alter table JEDA_ROLE_PERMISSION
   drop constraint ROLE_PERMISSION2;

alter table JEDA_ROLE_POSITION
   drop constraint ROLE_POSITION;

alter table JEDA_ROLE_POSITION
   drop constraint ROLE_POSITION2;

alter table JEDA_ROLE_USER
   drop constraint ROLE_USER;

alter table JEDA_ROLE_USER
   drop constraint ROLE_USER2;

alter table JEDA_SUB_ITEM
   drop constraint ITEM_SUBITEM;

alter table JEDA_USER
   drop constraint POSITION_USER;

alter table JEDA_USER
   drop constraint USER_ORG;

drop index FK_FUNCTION_FIELD;

drop table JEDA_FIELD cascade constraints;

drop index FK_FUNCTION_MODULE;

drop table JEDA_FUNCTION cascade constraints;

drop table JEDA_ITEM cascade constraints;

drop index FK_MENU_PARENT;

drop table JEDA_MENU cascade constraints;

drop table JEDA_MODULE cascade constraints;

drop table JEDA_ORG cascade constraints;

drop index FK_PERMISSION_FIELD;

drop index FK_ITEM_PERMISSION;

drop table JEDA_PERMISSION cascade constraints;

drop index FK_PERMISSION_ORG2;

drop index FK_PERMISSION_ORG;

drop table JEDA_PERMISSION_ORG cascade constraints;

drop index FK_PERMISSION_USER2;

drop index FK_PERMISSION_USER;

drop table JEDA_PERMISSION_USER cascade constraints;

drop table JEDA_PORTLET cascade constraints;

drop index FK_POSITION_PORTLET_LOCATION;

drop index FK_PORTLET_LOCATION_PORTLET;

drop table JEDA_PORTLET_LOCATION cascade constraints;

drop table JEDA_POSITION cascade constraints;

drop table JEDA_POSITION_LEVEL cascade constraints;

drop index FK_POSITION_ORG2;

drop index FK_POSITION_ORG;

drop table JEDA_POSITION_ORG cascade constraints;

drop index FK_POSITION_PL2;

drop index FK_POSITION_PL;

drop table JEDA_POSITION_PL cascade constraints;

drop table JEDA_PROPERTY cascade constraints;

drop table JEDA_ROLE cascade constraints;

drop index FK_ROLE_FUNCTION2;

drop index FK_ROLE_FUNCTION;

drop table JEDA_ROLE_FUNCTION cascade constraints;

drop index FK_ROLE_MENU2;

drop index FK_ROLE_MENU;

drop table JEDA_ROLE_MENU cascade constraints;

drop index FK_ROLE_PERMISSION2;

drop index FK_ROLE_PERMISSION;

drop table JEDA_ROLE_PERMISSION cascade constraints;

drop index FK_ROLE_POSITION2;

drop index FK_ROLE_POSITION;

drop table JEDA_ROLE_POSITION cascade constraints;

drop index FK_ROLE_USER2;

drop index FK_ROLE_USER;

drop table JEDA_ROLE_USER cascade constraints;

drop table JEDA_SEQUENCES cascade constraints;

drop index FK_ITEM_SUBITEM;

drop table JEDA_SUB_ITEM cascade constraints;

drop index FK_POSITION_USER;

drop index FK_USER_ORG;

drop table JEDA_USER cascade constraints;

/*==============================================================*/
/* Table: JEDA_FIELD                                            */
/*==============================================================*/
create table JEDA_FIELD  (
   FIELD_ID             NUMBER(9)                       not null,
   FUNCTION_ID          VARCHAR2(50),
   FIELD_CODE           VARCHAR2(50),
   FIELD_NAME           VARCHAR2(100),
   FIELD_TYPE           VARCHAR2(10),
   FIELD_READ_ONLY      SMALLINT,
   FIELD_VERSION        INTEGER                        default 0,
   FIELD_ORDER          INTEGER,
   FIELD_CREATOR        VARCHAR2(50),
   FIELD_CREATED        TIMESTAMP,
   FIELD_MODIFIER       VARCHAR2(50),
   FIELD_MODIFIED       TIMESTAMP,
   constraint PK_JEDA_FIELD primary key (FIELD_ID)
);

comment on table JEDA_FIELD is
'字段';

comment on column JEDA_FIELD.FIELD_ID is
'字段ID';

comment on column JEDA_FIELD.FUNCTION_ID is
'功能ID';

comment on column JEDA_FIELD.FIELD_CODE is
'字段编码';

comment on column JEDA_FIELD.FIELD_NAME is
'字段名称';

comment on column JEDA_FIELD.FIELD_TYPE is
'字段类型';

comment on column JEDA_FIELD.FIELD_READ_ONLY is
'只读数据';

comment on column JEDA_FIELD.FIELD_VERSION is
'字段数据版本';

comment on column JEDA_FIELD.FIELD_ORDER is
'字段顺序';

comment on column JEDA_FIELD.FIELD_CREATOR is
'字段创建用户';

comment on column JEDA_FIELD.FIELD_CREATED is
'字段创建时间';

comment on column JEDA_FIELD.FIELD_MODIFIER is
'字段修改用户';

comment on column JEDA_FIELD.FIELD_MODIFIED is
'字段修改时间';

/*==============================================================*/
/* Index: FK_FUNCTION_FIELD                                     */
/*==============================================================*/
create index FK_FUNCTION_FIELD on JEDA_FIELD (
   FUNCTION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_FUNCTION                                         */
/*==============================================================*/
create table JEDA_FUNCTION  (
   FUNCTION_ID          VARCHAR2(50)                    not null,
   MODULE_ID            VARCHAR2(50),
   FUNCTION_NAME        VARCHAR2(100),
   FUNCTION_URL         VARCHAR2(500),
   FUNCTION_TYPE        VARCHAR2(50),
   FUNCTION_HAS_PERMISSION SMALLINT                       default 0,
   FUNCTION_ORDER       INTEGER                        default 0,
   FUNCTION_READ_ONLY   SMALLINT,
   FUNCTION_VERSION     INTEGER                        default 0,
   FUNCTION_ACCESS_DOMAIN_IP VARCHAR2(500),
   FUNCTION_CREATOR     VARCHAR2(50),
   FUNCTION_CREATED     TIMESTAMP,
   FUNCTION_MODIFIER    VARCHAR2(50),
   FUNCTION_MODIFIED    TIMESTAMP,
   constraint PK_JEDA_FUNCTION primary key (FUNCTION_ID)
);

comment on table JEDA_FUNCTION is
'功能';

comment on column JEDA_FUNCTION.FUNCTION_ID is
'功能ID';

comment on column JEDA_FUNCTION.MODULE_ID is
'模块ID';

comment on column JEDA_FUNCTION.FUNCTION_NAME is
'功能名称';

comment on column JEDA_FUNCTION.FUNCTION_URL is
'功能地址';

comment on column JEDA_FUNCTION.FUNCTION_TYPE is
'菜单功能|页面功能|...';

comment on column JEDA_FUNCTION.FUNCTION_HAS_PERMISSION is
'可配权限';

comment on column JEDA_FUNCTION.FUNCTION_ORDER is
'功能顺序';

comment on column JEDA_FUNCTION.FUNCTION_READ_ONLY is
'功能只读数据';

comment on column JEDA_FUNCTION.FUNCTION_VERSION is
'功能数据版本';

comment on column JEDA_FUNCTION.FUNCTION_ACCESS_DOMAIN_IP is
'域访问控制IP，逗号分隔，可写子网掩码';

comment on column JEDA_FUNCTION.FUNCTION_CREATOR is
'功能创建者';

comment on column JEDA_FUNCTION.FUNCTION_CREATED is
'功能创建时间';

comment on column JEDA_FUNCTION.FUNCTION_MODIFIER is
'功能修改者';

comment on column JEDA_FUNCTION.FUNCTION_MODIFIED is
'功能修改时间';

/*==============================================================*/
/* Index: FK_FUNCTION_MODULE                                    */
/*==============================================================*/
create index FK_FUNCTION_MODULE on JEDA_FUNCTION (
   MODULE_ID ASC
);

/*==============================================================*/
/* Table: JEDA_ITEM                                             */
/*==============================================================*/
create table JEDA_ITEM  (
   ITEM_ID              VARCHAR2(50)                    not null,
   ITEM_NAME            VARCHAR2(100),
   ITEM_DESCRIPTION     VARCHAR2(500),
   ITEM_IS_PERMISSION   SMALLINT,
   ITEM_ORDER           INTEGER                        default 0,
   ITEM_READ_ONLY       SMALLINT,
   ITEM_CREATOR         VARCHAR2(50),
   ITEM_CREATED         TIMESTAMP,
   ITEM_MODIFIER        VARCHAR2(50),
   ITEM_MODIFIED        TIMESTAMP,
   ITEM_VERSION         INTEGER                        default 0,
   constraint PK_JEDA_ITEM primary key (ITEM_ID)
);

comment on table JEDA_ITEM is
'数据主项';

comment on column JEDA_ITEM.ITEM_ID is
'数据主项ID';

comment on column JEDA_ITEM.ITEM_NAME is
'数据主项名称';

comment on column JEDA_ITEM.ITEM_DESCRIPTION is
'数据主项描述';

comment on column JEDA_ITEM.ITEM_IS_PERMISSION is
'是字典权限';

comment on column JEDA_ITEM.ITEM_ORDER is
'数据主项顺序';

comment on column JEDA_ITEM.ITEM_READ_ONLY is
'数据主项只读数据';

comment on column JEDA_ITEM.ITEM_CREATOR is
'数据主项创建者';

comment on column JEDA_ITEM.ITEM_CREATED is
'数据主项创建时间';

comment on column JEDA_ITEM.ITEM_MODIFIER is
'数据主项修改者';

comment on column JEDA_ITEM.ITEM_MODIFIED is
'数据主项修改时间';

comment on column JEDA_ITEM.ITEM_VERSION is
'数据主项数据版本';

/*==============================================================*/
/* Table: JEDA_MENU                                             */
/*==============================================================*/
create table JEDA_MENU  (
   MENU_ID              VARCHAR2(50)                    not null,
   PARENT_MENU_ID       VARCHAR2(50),
   MENU_NAME            VARCHAR2(100),
   MENU_URL             VARCHAR2(500),
   MENU_DESCRIPTION     VARCHAR2(1000),
   MENU_IFRAME          SMALLINT,
   MENU_ICON            VARCHAR2(50),
   MENU_ORDER           INTEGER                        default 0,
   MENU_READ_ONLY       SMALLINT,
   MENU_OPEN_IN_HOME    SMALLINT                       default 0,
   MENU_VERSION         INTEGER                        default 0,
   MENU_CREATOR         VARCHAR2(50),
   MENU_CREATED         TIMESTAMP,
   MENU_MODIFIER        VARCHAR2(50),
   MENU_MODIFIED        TIMESTAMP,
   constraint PK_JEDA_MENU primary key (MENU_ID)
);

comment on table JEDA_MENU is
'菜单';

comment on column JEDA_MENU.MENU_ID is
'菜单ID';

comment on column JEDA_MENU.PARENT_MENU_ID is
'菜单ID';

comment on column JEDA_MENU.MENU_NAME is
'菜单名称';

comment on column JEDA_MENU.MENU_URL is
'菜单地址';

comment on column JEDA_MENU.MENU_DESCRIPTION is
'菜单描述';

comment on column JEDA_MENU.MENU_IFRAME is
'嵌入页面';

comment on column JEDA_MENU.MENU_ICON is
'菜单图标';

comment on column JEDA_MENU.MENU_ORDER is
'菜单顺序';

comment on column JEDA_MENU.MENU_READ_ONLY is
'菜单只读数据';

comment on column JEDA_MENU.MENU_OPEN_IN_HOME is
'是否主页中打开';

comment on column JEDA_MENU.MENU_VERSION is
'菜单数据版本';

comment on column JEDA_MENU.MENU_CREATOR is
'菜单创建者';

comment on column JEDA_MENU.MENU_CREATED is
'菜单创建时间';

comment on column JEDA_MENU.MENU_MODIFIER is
'菜单修改者';

comment on column JEDA_MENU.MENU_MODIFIED is
'菜单修改时间';

/*==============================================================*/
/* Index: FK_MENU_PARENT                                        */
/*==============================================================*/
create index FK_MENU_PARENT on JEDA_MENU (
   PARENT_MENU_ID ASC
);

/*==============================================================*/
/* Table: JEDA_MODULE                                           */
/*==============================================================*/
create table JEDA_MODULE  (
   MODULE_ID            VARCHAR2(50)                    not null,
   MODULE_NAME          VARCHAR2(100),
   MODULE_DESCRIPTION   VARCHAR2(500),
   MODULE_ORDER         INTEGER                        default 0,
   MODULE_READ_ONLY     SMALLINT,
   MODULE_VERSION       INTEGER                        default 0,
   MODULE_CREATOR       VARCHAR2(50),
   MODULE_CREATED       TIMESTAMP,
   MODULE_MODIFIER      VARCHAR2(50),
   MODULE_MODIFIED      TIMESTAMP,
   constraint PK_JEDA_MODULE primary key (MODULE_ID)
);

comment on table JEDA_MODULE is
'模块';

comment on column JEDA_MODULE.MODULE_ID is
'模块ID';

comment on column JEDA_MODULE.MODULE_NAME is
'模块名称';

comment on column JEDA_MODULE.MODULE_DESCRIPTION is
'模块描述';

comment on column JEDA_MODULE.MODULE_ORDER is
'模块顺序';

comment on column JEDA_MODULE.MODULE_READ_ONLY is
'模块只读数据';

comment on column JEDA_MODULE.MODULE_VERSION is
'模块数据版本';

comment on column JEDA_MODULE.MODULE_CREATOR is
'模块创建者';

comment on column JEDA_MODULE.MODULE_CREATED is
'模块创建时间';

comment on column JEDA_MODULE.MODULE_MODIFIER is
'模块修改者';

comment on column JEDA_MODULE.MODULE_MODIFIED is
'模块修改时间';

/*==============================================================*/
/* Table: JEDA_ORG                                              */
/*==============================================================*/
create table JEDA_ORG  (
   ORG_ID               VARCHAR2(50)                    not null,
   ORG_NAME             VARCHAR2(100),
   PARENT_ORG_ID        VARCHAR2(50),
   ORG_DESCRIPTION      VARCHAR2(500),
   ORG_TEL              VARCHAR2(50),
   ORG_ADDRESS          VARCHAR2(500),
   ORG_CONTACT          VARCHAR2(50),
   ORG_PATH             VARCHAR2(500),
   ORG_LEVEL            VARCHAR2(10),
   ORG_ENABLED          SMALLINT,
   ORG_TYPE             VARCHAR2(50),
   ORG_PROPERTY         VARCHAR2(50),
   ORG_ORDER            INTEGER                        default 0,
   ORG_VERSION          INTEGER                        default 0,
   ORG_CREATOR          VARCHAR2(50),
   ORG_CREATED          TIMESTAMP,
   ORG_MODIFIER         VARCHAR2(50),
   ORG_MODIFIED         TIMESTAMP,
   constraint PK_JEDA_ORG primary key (ORG_ID)
);

comment on column JEDA_ORG.ORG_ID is
'机构ID';

comment on column JEDA_ORG.ORG_NAME is
'机构名称';

comment on column JEDA_ORG.PARENT_ORG_ID is
'上级机构ID';

comment on column JEDA_ORG.ORG_DESCRIPTION is
'机构描述';

comment on column JEDA_ORG.ORG_TEL is
'机构电话';

comment on column JEDA_ORG.ORG_ADDRESS is
'机构地址';

comment on column JEDA_ORG.ORG_CONTACT is
'机构联系人';

comment on column JEDA_ORG.ORG_PATH is
'机构路径';

comment on column JEDA_ORG.ORG_LEVEL is
'机构等级';

comment on column JEDA_ORG.ORG_ENABLED is
'机构启用标志';

comment on column JEDA_ORG.ORG_TYPE is
'机构类型';

comment on column JEDA_ORG.ORG_PROPERTY is
'机构属性';

comment on column JEDA_ORG.ORG_ORDER is
'机构顺序';

comment on column JEDA_ORG.ORG_VERSION is
'机构数据版本';

comment on column JEDA_ORG.ORG_CREATOR is
'机构创建者';

comment on column JEDA_ORG.ORG_CREATED is
'机构创建时间';

comment on column JEDA_ORG.ORG_MODIFIER is
'机构修改者';

comment on column JEDA_ORG.ORG_MODIFIED is
'机构修改时间';

/*==============================================================*/
/* Table: JEDA_PERMISSION                                       */
/*==============================================================*/
create table JEDA_PERMISSION  (
   PERMISSION_ID        VARCHAR2(50)                    not null,
   FIELD_ID             NUMBER(9),
   SUB_ITEM_ID          VARCHAR2(50),
   PERMISSION_NAME      VARCHAR2(100),
   PERMISSION_TYPE      VARCHAR2(50),
   PERMISSION_EXPRESSION VARCHAR2(500),
   PERMISSION_USER_TYPE VARCHAR2(50),
   PERMISSION_ORG_TYPE  VARCHAR2(50),
   PERMISSION_FIELD_VALUE VARCHAR2(100),
   PERMISSION_DESCRIPTION VARCHAR2(500),
   PERMISSION_ORDER     INTEGER                        default 0,
   PERMISSION_READ_ONLY SMALLINT,
   PERMISSION_VERSION   INTEGER                        default 0,
   PERMISSION_CREATOR   VARCHAR2(50),
   PERMISSION_CREATED   TIMESTAMP,
   PERMISSION_MODIFIER  VARCHAR2(50),
   PERMISSION_MODIFIED  TIMESTAMP,
   constraint PK_JEDA_PERMISSION primary key (PERMISSION_ID)
);

comment on table JEDA_PERMISSION is
'权限';

comment on column JEDA_PERMISSION.PERMISSION_ID is
'权限ID';

comment on column JEDA_PERMISSION.FIELD_ID is
'字段ID';

comment on column JEDA_PERMISSION.SUB_ITEM_ID is
'数据子项ID';

comment on column JEDA_PERMISSION.PERMISSION_NAME is
'权限名称';

comment on column JEDA_PERMISSION.PERMISSION_TYPE is
'字典权限|用户权限|其他权限';

comment on column JEDA_PERMISSION.PERMISSION_EXPRESSION is
'权限表达式';

comment on column JEDA_PERMISSION.PERMISSION_USER_TYPE is
'用户权限类型';

comment on column JEDA_PERMISSION.PERMISSION_ORG_TYPE is
'机构权限类型';

comment on column JEDA_PERMISSION.PERMISSION_FIELD_VALUE is
'权限字段数值';

comment on column JEDA_PERMISSION.PERMISSION_DESCRIPTION is
'权限描述';

comment on column JEDA_PERMISSION.PERMISSION_ORDER is
'权限顺序';

comment on column JEDA_PERMISSION.PERMISSION_READ_ONLY is
'权限只读数据';

comment on column JEDA_PERMISSION.PERMISSION_VERSION is
'权限数据版本';

comment on column JEDA_PERMISSION.PERMISSION_CREATOR is
'权限创建者';

comment on column JEDA_PERMISSION.PERMISSION_CREATED is
'权限创建时间';

comment on column JEDA_PERMISSION.PERMISSION_MODIFIER is
'权限修改者';

comment on column JEDA_PERMISSION.PERMISSION_MODIFIED is
'权限修改时间';

/*==============================================================*/
/* Index: FK_ITEM_PERMISSION                                    */
/*==============================================================*/
create index FK_ITEM_PERMISSION on JEDA_PERMISSION (
   SUB_ITEM_ID ASC
);

/*==============================================================*/
/* Index: FK_PERMISSION_FIELD                                   */
/*==============================================================*/
create index FK_PERMISSION_FIELD on JEDA_PERMISSION (
   FIELD_ID ASC
);

/*==============================================================*/
/* Table: JEDA_PERMISSION_ORG                                   */
/*==============================================================*/
create table JEDA_PERMISSION_ORG  (
   ORG_ID               VARCHAR2(50)                    not null,
   PERMISSION_ID        VARCHAR2(50)                    not null,
   constraint PK_JEDA_PERMISSION_ORG primary key (ORG_ID, PERMISSION_ID)
);

comment on table JEDA_PERMISSION_ORG is
'权限机构关联';

comment on column JEDA_PERMISSION_ORG.ORG_ID is
'机构ID';

comment on column JEDA_PERMISSION_ORG.PERMISSION_ID is
'权限ID';

/*==============================================================*/
/* Index: FK_PERMISSION_ORG                                     */
/*==============================================================*/
create index FK_PERMISSION_ORG on JEDA_PERMISSION_ORG (
   ORG_ID ASC
);

/*==============================================================*/
/* Index: FK_PERMISSION_ORG2                                    */
/*==============================================================*/
create index FK_PERMISSION_ORG2 on JEDA_PERMISSION_ORG (
   PERMISSION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_PERMISSION_USER                                  */
/*==============================================================*/
create table JEDA_PERMISSION_USER  (
   PERMISSION_ID        VARCHAR2(50)                    not null,
   USER_ID              VARCHAR2(50)                    not null,
   constraint PK_JEDA_PERMISSION_USER primary key (PERMISSION_ID, USER_ID)
);

comment on table JEDA_PERMISSION_USER is
'权限用户关联';

comment on column JEDA_PERMISSION_USER.PERMISSION_ID is
'权限ID';

comment on column JEDA_PERMISSION_USER.USER_ID is
'用户ID';

/*==============================================================*/
/* Index: FK_PERMISSION_USER                                    */
/*==============================================================*/
create index FK_PERMISSION_USER on JEDA_PERMISSION_USER (
   PERMISSION_ID ASC
);

/*==============================================================*/
/* Index: FK_PERMISSION_USER2                                   */
/*==============================================================*/
create index FK_PERMISSION_USER2 on JEDA_PERMISSION_USER (
   USER_ID ASC
);

/*==============================================================*/
/* Table: JEDA_PORTLET                                          */
/*==============================================================*/
create table JEDA_PORTLET  (
   PORTLET_ID           VARCHAR2(50)                    not null,
   PORTLET_TITLE        VARCHAR2(100),
   PORTLET_URL          VARCHAR2(100),
   PORTLET_DESCRIPTION  VARCHAR2(500),
   PORTLET_ORDER        INTEGER,
   PORTLET_CREATOR      VARCHAR2(50),
   PORTLET_CREATED      TIMESTAMP,
   PORTLET_MODIFIER     VARCHAR2(50),
   PORTLET_MODIFIED     TIMESTAMP,
   PORTLET_VERSION      INTEGER,
   constraint PK_JEDA_PORTLET primary key (PORTLET_ID)
);

comment on table JEDA_PORTLET is
'门户应用';

comment on column JEDA_PORTLET.PORTLET_ID is
'门户应用ID';

comment on column JEDA_PORTLET.PORTLET_TITLE is
'门户应用标题';

comment on column JEDA_PORTLET.PORTLET_URL is
'门户应用地址';

comment on column JEDA_PORTLET.PORTLET_DESCRIPTION is
'门户应用描述';

comment on column JEDA_PORTLET.PORTLET_ORDER is
'门户应用顺序';

comment on column JEDA_PORTLET.PORTLET_CREATOR is
'门户应用创建用户';

comment on column JEDA_PORTLET.PORTLET_CREATED is
'门户应用创建时间';

comment on column JEDA_PORTLET.PORTLET_MODIFIER is
'门户应用修改用户';

comment on column JEDA_PORTLET.PORTLET_MODIFIED is
'门户应用修改时间';

comment on column JEDA_PORTLET.PORTLET_VERSION is
'门户应用数据版本';

/*==============================================================*/
/* Table: JEDA_PORTLET_LOCATION                                 */
/*==============================================================*/
create table JEDA_PORTLET_LOCATION  (
   PORTLET_LOCATION_ID  INTEGER                         not null,
   PORTLET_ID           VARCHAR2(50),
   POSITION_ID          VARCHAR2(50),
   PORTLET_LOCATION_ROW INTEGER,
   PORTLET_LOCATION_COLUMN INTEGER,
   PORTLET_LOCATION_ORDER INTEGER,
   PORTLET_LOCATION_CREATOR VARCHAR2(50),
   PORTLET_LOCATION_CREATED TIMESTAMP,
   PORTLET_LOCATION_MODIFIER VARCHAR2(50),
   PORTLET_LOCATION_MODIFIED TIMESTAMP,
   PORTLET_LOCATION_VERSION INTEGER,
   constraint PK_JEDA_PORTLET_LOCATION primary key (PORTLET_LOCATION_ID)
);

comment on table JEDA_PORTLET_LOCATION is
'门户应用位置';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_ID is
'门户应用位置ID';

comment on column JEDA_PORTLET_LOCATION.PORTLET_ID is
'门户应用ID';

comment on column JEDA_PORTLET_LOCATION.POSITION_ID is
'岗位ID';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_ROW is
'门户应用位置行数';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_COLUMN is
'门户应用位置列数';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_ORDER is
'门户应用位置顺序';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_CREATOR is
'门户应用位置创建用户';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_CREATED is
'门户应用位置创建时间';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_MODIFIER is
'门户应用位置修改用户';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_MODIFIED is
'门户应用位置修改时间';

comment on column JEDA_PORTLET_LOCATION.PORTLET_LOCATION_VERSION is
'门户应用位置数据版本';

/*==============================================================*/
/* Index: FK_PORTLET_LOCATION_PORTLET                           */
/*==============================================================*/
create index FK_PORTLET_LOCATION_PORTLET on JEDA_PORTLET_LOCATION (
   PORTLET_ID ASC
);

/*==============================================================*/
/* Index: FK_POSITION_PORTLET_LOCATION                          */
/*==============================================================*/
create index FK_POSITION_PORTLET_LOCATION on JEDA_PORTLET_LOCATION (
   POSITION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_POSITION                                         */
/*==============================================================*/
create table JEDA_POSITION  (
   POSITION_ID          VARCHAR2(50)                    not null,
   POSITION_NAME        VARCHAR2(100),
   POSITION_DESCRIPTION VARCHAR2(500),
   POSITION_TYPE        VARCHAR2(50),
   POSITION_ORDER       INTEGER                        default 0,
   POSITION_VERSION     INTEGER                        default 0,
   POSITION_CREATOR     VARCHAR2(50),
   POSITION_CREATED     TIMESTAMP,
   POSITION_MODIFIER    VARCHAR2(50),
   POSITION_MODIFIED    TIMESTAMP,
   constraint PK_JEDA_POSITION primary key (POSITION_ID)
);

comment on table JEDA_POSITION is
'岗位';

comment on column JEDA_POSITION.POSITION_ID is
'岗位ID';

comment on column JEDA_POSITION.POSITION_NAME is
'岗位名称';

comment on column JEDA_POSITION.POSITION_DESCRIPTION is
'岗位描述';

comment on column JEDA_POSITION.POSITION_TYPE is
'岗位类型';

comment on column JEDA_POSITION.POSITION_ORDER is
'岗位顺序';

comment on column JEDA_POSITION.POSITION_VERSION is
'岗位数据版本';

comment on column JEDA_POSITION.POSITION_CREATOR is
'岗位创建者';

comment on column JEDA_POSITION.POSITION_CREATED is
'岗位创建时间';

comment on column JEDA_POSITION.POSITION_MODIFIER is
'岗位修改者';

comment on column JEDA_POSITION.POSITION_MODIFIED is
'岗位修改时间';

/*==============================================================*/
/* Table: JEDA_POSITION_LEVEL                                   */
/*==============================================================*/
create table JEDA_POSITION_LEVEL  (
   PL_ID                VARCHAR2(50)                    not null,
   PL_NAME              VARCHAR2(100),
   PL_VALUE             VARCHAR2(50),
   constraint PK_JEDA_POSITION_LEVEL primary key (PL_ID)
);

comment on table JEDA_POSITION_LEVEL is
'岗位级别';

comment on column JEDA_POSITION_LEVEL.PL_ID is
'岗位级别ID';

comment on column JEDA_POSITION_LEVEL.PL_NAME is
'岗位级别名称';

comment on column JEDA_POSITION_LEVEL.PL_VALUE is
'岗位级别数值';

/*==============================================================*/
/* Table: JEDA_POSITION_ORG                                     */
/*==============================================================*/
create table JEDA_POSITION_ORG  (
   ORG_ID               VARCHAR2(50)                    not null,
   POSITION_ID          VARCHAR2(50)                    not null,
   constraint PK_JEDA_POSITION_ORG primary key (ORG_ID, POSITION_ID)
);

comment on table JEDA_POSITION_ORG is
'岗位机构关联';

comment on column JEDA_POSITION_ORG.ORG_ID is
'机构ID';

comment on column JEDA_POSITION_ORG.POSITION_ID is
'岗位ID';

/*==============================================================*/
/* Index: FK_POSITION_ORG                                       */
/*==============================================================*/
create index FK_POSITION_ORG on JEDA_POSITION_ORG (
   ORG_ID ASC
);

/*==============================================================*/
/* Index: FK_POSITION_ORG2                                      */
/*==============================================================*/
create index FK_POSITION_ORG2 on JEDA_POSITION_ORG (
   POSITION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_POSITION_PL                                      */
/*==============================================================*/
create table JEDA_POSITION_PL  (
   POSITION_ID          VARCHAR2(50)                    not null,
   PL_ID                VARCHAR2(50)                    not null,
   constraint PK_JEDA_POSITION_PL primary key (POSITION_ID, PL_ID)
);

comment on table JEDA_POSITION_PL is
'岗位与岗位级别关联';

comment on column JEDA_POSITION_PL.POSITION_ID is
'岗位ID';

comment on column JEDA_POSITION_PL.PL_ID is
'岗位级别ID';

/*==============================================================*/
/* Index: FK_POSITION_PL                                        */
/*==============================================================*/
create index FK_POSITION_PL on JEDA_POSITION_PL (
   POSITION_ID ASC
);

/*==============================================================*/
/* Index: FK_POSITION_PL2                                       */
/*==============================================================*/
create index FK_POSITION_PL2 on JEDA_POSITION_PL (
   PL_ID ASC
);

/*==============================================================*/
/* Table: JEDA_PROPERTY                                         */
/*==============================================================*/
create table JEDA_PROPERTY  (
   PROPERTY_ID          INTEGER                         not null,
   PROPERTY_VERSION     INTEGER                        default 0,
   PROPERTY_TAB_SIZE    INTEGER,
   PROPERTY_FILE_ROOT   VARCHAR2(100),
   PROPERTY_COPYRIGHT   VARCHAR2(50),
   PROPERTY_APP_TITLE   VARCHAR2(50),
   PROPERTY_TREE_MENU	SMALLINT						default 1,
   constraint PK_JEDA_PROPERTY primary key (PROPERTY_ID)
);

comment on table JEDA_PROPERTY is
'系统属性';

comment on column JEDA_PROPERTY.PROPERTY_ID is
'属性ID';

comment on column JEDA_PROPERTY.PROPERTY_VERSION is
'属性数据版本';

comment on column JEDA_PROPERTY.PROPERTY_TAB_SIZE is
'标签数量';

comment on column JEDA_PROPERTY.PROPERTY_FILE_ROOT is
'文件根路径';

comment on column JEDA_PROPERTY.PROPERTY_COPYRIGHT is
'版权信息';

comment on column JEDA_PROPERTY.PROPERTY_APP_TITLE is
'系统名称';

/*==============================================================*/
/* Table: JEDA_ROLE                                             */
/*==============================================================*/
create table JEDA_ROLE  (
   ROLE_ID              VARCHAR2(50)                    not null,
   ROLE_NAME            VARCHAR2(100),
   ROLE_DESCRIPTION     VARCHAR2(500),
   ROLE_TYPE            VARCHAR2(50),
   ROLE_ORDER           INTEGER                        default 0,
   ROLE_READ_ONLY       SMALLINT,
   ROLE_VERSION         INTEGER                        default 0,
   ROLE_CREATOR         VARCHAR2(50),
   ROLE_CREATED         TIMESTAMP,
   ROLE_MODIFIER        VARCHAR2(50),
   ROLE_MODIFIED        TIMESTAMP,
   constraint PK_JEDA_ROLE primary key (ROLE_ID)
);

comment on table JEDA_ROLE is
'角色';

comment on column JEDA_ROLE.ROLE_ID is
'角色ID';

comment on column JEDA_ROLE.ROLE_NAME is
'角色名称';

comment on column JEDA_ROLE.ROLE_DESCRIPTION is
'角色描述';

comment on column JEDA_ROLE.ROLE_TYPE is
'角色类型';

comment on column JEDA_ROLE.ROLE_ORDER is
'角色顺序';

comment on column JEDA_ROLE.ROLE_READ_ONLY is
'角色只读数据';

comment on column JEDA_ROLE.ROLE_VERSION is
'角色数据版本';

comment on column JEDA_ROLE.ROLE_CREATOR is
'角色创建者';

comment on column JEDA_ROLE.ROLE_CREATED is
'角色创建时间';

comment on column JEDA_ROLE.ROLE_MODIFIER is
'角色修改者';

comment on column JEDA_ROLE.ROLE_MODIFIED is
'角色修改时间';

/*==============================================================*/
/* Table: JEDA_ROLE_FUNCTION                                    */
/*==============================================================*/
create table JEDA_ROLE_FUNCTION  (
   ROLE_ID              VARCHAR2(50)                    not null,
   FUNCTION_ID          VARCHAR2(50)                    not null,
   constraint PK_JEDA_ROLE_FUNCTION primary key (ROLE_ID, FUNCTION_ID)
);

comment on table JEDA_ROLE_FUNCTION is
'角色功能关联';

comment on column JEDA_ROLE_FUNCTION.ROLE_ID is
'角色ID';

comment on column JEDA_ROLE_FUNCTION.FUNCTION_ID is
'功能ID';

/*==============================================================*/
/* Index: FK_ROLE_FUNCTION                                      */
/*==============================================================*/
create index FK_ROLE_FUNCTION on JEDA_ROLE_FUNCTION (
   ROLE_ID ASC
);

/*==============================================================*/
/* Index: FK_ROLE_FUNCTION2                                     */
/*==============================================================*/
create index FK_ROLE_FUNCTION2 on JEDA_ROLE_FUNCTION (
   FUNCTION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_ROLE_MENU                                        */
/*==============================================================*/
create table JEDA_ROLE_MENU  (
   ROLE_ID              VARCHAR2(50)                    not null,
   MENU_ID              VARCHAR2(50)                    not null,
   constraint PK_JEDA_ROLE_MENU primary key (ROLE_ID, MENU_ID)
);

comment on table JEDA_ROLE_MENU is
'角色菜单关联';

comment on column JEDA_ROLE_MENU.ROLE_ID is
'角色ID';

comment on column JEDA_ROLE_MENU.MENU_ID is
'菜单ID';

/*==============================================================*/
/* Index: FK_ROLE_MENU                                          */
/*==============================================================*/
create index FK_ROLE_MENU on JEDA_ROLE_MENU (
   ROLE_ID ASC
);

/*==============================================================*/
/* Index: FK_ROLE_MENU2                                         */
/*==============================================================*/
create index FK_ROLE_MENU2 on JEDA_ROLE_MENU (
   MENU_ID ASC
);

/*==============================================================*/
/* Table: JEDA_ROLE_PERMISSION                                  */
/*==============================================================*/
create table JEDA_ROLE_PERMISSION  (
   ROLE_ID              VARCHAR2(50)                    not null,
   PERMISSION_ID        VARCHAR2(50)                    not null,
   constraint PK_JEDA_ROLE_PERMISSION primary key (ROLE_ID, PERMISSION_ID)
);

comment on table JEDA_ROLE_PERMISSION is
'角色权限关联';

comment on column JEDA_ROLE_PERMISSION.ROLE_ID is
'角色ID';

comment on column JEDA_ROLE_PERMISSION.PERMISSION_ID is
'权限ID';

/*==============================================================*/
/* Index: FK_ROLE_PERMISSION                                    */
/*==============================================================*/
create index FK_ROLE_PERMISSION on JEDA_ROLE_PERMISSION (
   ROLE_ID ASC
);

/*==============================================================*/
/* Index: FK_ROLE_PERMISSION2                                   */
/*==============================================================*/
create index FK_ROLE_PERMISSION2 on JEDA_ROLE_PERMISSION (
   PERMISSION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_ROLE_POSITION                                    */
/*==============================================================*/
create table JEDA_ROLE_POSITION  (
   ROLE_ID              VARCHAR2(50)                    not null,
   POSITION_ID          VARCHAR2(50)                    not null,
   constraint PK_JEDA_ROLE_POSITION primary key (ROLE_ID, POSITION_ID)
);

comment on table JEDA_ROLE_POSITION is
'角色岗位关联';

comment on column JEDA_ROLE_POSITION.ROLE_ID is
'角色ID';

comment on column JEDA_ROLE_POSITION.POSITION_ID is
'岗位ID';

/*==============================================================*/
/* Index: FK_ROLE_POSITION                                      */
/*==============================================================*/
create index FK_ROLE_POSITION on JEDA_ROLE_POSITION (
   ROLE_ID ASC
);

/*==============================================================*/
/* Index: FK_ROLE_POSITION2                                     */
/*==============================================================*/
create index FK_ROLE_POSITION2 on JEDA_ROLE_POSITION (
   POSITION_ID ASC
);

/*==============================================================*/
/* Table: JEDA_ROLE_USER                                        */
/*==============================================================*/
create table JEDA_ROLE_USER  (
   USER_ID              VARCHAR2(50)                    not null,
   ROLE_ID              VARCHAR2(50)                    not null,
   constraint PK_JEDA_ROLE_USER primary key (USER_ID, ROLE_ID)
);

comment on table JEDA_ROLE_USER is
'角色用户关联';

comment on column JEDA_ROLE_USER.USER_ID is
'用户ID';

comment on column JEDA_ROLE_USER.ROLE_ID is
'角色ID';

/*==============================================================*/
/* Index: FK_ROLE_USER                                          */
/*==============================================================*/
create index FK_ROLE_USER on JEDA_ROLE_USER (
   USER_ID ASC
);

/*==============================================================*/
/* Index: FK_ROLE_USER2                                         */
/*==============================================================*/
create index FK_ROLE_USER2 on JEDA_ROLE_USER (
   ROLE_ID ASC
);

/*==============================================================*/
/* Table: JEDA_SEQUENCES                                        */
/*==============================================================*/
create table JEDA_SEQUENCES  (
   SEQUENCE_NAME        VARCHAR2(100)                   not null,
   NEXT_VAL             NUMBER(19),
   constraint PK_JEDA_SEQUENCES primary key (SEQUENCE_NAME)
);

comment on table JEDA_SEQUENCES is
'业务主键';

comment on column JEDA_SEQUENCES.SEQUENCE_NAME is
'主键名称';

comment on column JEDA_SEQUENCES.NEXT_VAL is
'下个数值';

/*==============================================================*/
/* Table: JEDA_SUB_ITEM                                         */
/*==============================================================*/
create table JEDA_SUB_ITEM  (
   SUB_ITEM_ID          VARCHAR2(50)                    not null,
   ITEM_ID              VARCHAR2(50),
   SUB_ITEM_NAME        VARCHAR2(100),
   SUB_ITEM_VALUE       VARCHAR2(100),
   SUB_ITEM_CASCADE     SMALLINT,
   SUB_ITEM_DESCRIPTION VARCHAR2(500),
   SUB_ITEM_ORDER       INTEGER                        default 0,
   SUB_ITEM_CREATOR     VARCHAR2(50),
   SUB_ITEM_CREATED     TIMESTAMP,
   SUB_ITEM_MODIFIER    VARCHAR2(50),
   SUB_ITEM_MODIFIED    TIMESTAMP,
   SUB_ITEM_VERSION     INTEGER                        default 0,
   constraint PK_JEDA_SUB_ITEM primary key (SUB_ITEM_ID)
);

comment on table JEDA_SUB_ITEM is
'数据子项';

comment on column JEDA_SUB_ITEM.SUB_ITEM_ID is
'数据子项ID';

comment on column JEDA_SUB_ITEM.ITEM_ID is
'数据主项ID';

comment on column JEDA_SUB_ITEM.SUB_ITEM_NAME is
'数据子项名称';

comment on column JEDA_SUB_ITEM.SUB_ITEM_VALUE is
'数据子项值';

comment on column JEDA_SUB_ITEM.SUB_ITEM_CASCADE is
'级联字典';

comment on column JEDA_SUB_ITEM.SUB_ITEM_DESCRIPTION is
'数据子项描述';

comment on column JEDA_SUB_ITEM.SUB_ITEM_ORDER is
'数据子项顺序';

comment on column JEDA_SUB_ITEM.SUB_ITEM_CREATOR is
'数据子项创建者';

comment on column JEDA_SUB_ITEM.SUB_ITEM_CREATED is
'数据子项创建时间';

comment on column JEDA_SUB_ITEM.SUB_ITEM_MODIFIER is
'数据子项修改者';

comment on column JEDA_SUB_ITEM.SUB_ITEM_MODIFIED is
'数据子项修改时间';

comment on column JEDA_SUB_ITEM.SUB_ITEM_VERSION is
'数据子项数据版本';

/*==============================================================*/
/* Index: FK_ITEM_SUBITEM                                       */
/*==============================================================*/
create index FK_ITEM_SUBITEM on JEDA_SUB_ITEM (
   ITEM_ID ASC
);

/*==============================================================*/
/* Table: JEDA_USER                                             */
/*==============================================================*/
create table JEDA_USER  (
   USER_ID              VARCHAR2(50)                    not null,
   POSITION_ID          VARCHAR2(50),
   ORG_ID               VARCHAR2(50),
   USER_NAME            VARCHAR2(100),
   USER_PASSWORD        VARCHAR2(100),
   USER_ID_NO           VARCHAR2(50),
   USER_GENDER          VARCHAR2(1),
   USER_EMAIL           VARCHAR2(100),
   USER_BIRTHDAY        DATE,
   USER_ADDRESS         VARCHAR2(500),
   USER_POST            VARCHAR2(50),
   USER_TEL             VARCHAR2(50),
   USER_MOBILE          VARCHAR2(50),
   USER_DESCRIPTION     VARCHAR2(500),
   USER_ENABLED         SMALLINT,
   USER_LOCKED          SMALLINT,
   USER_ACCOUNT_NONEXPIRED SMALLINT,
   USER_ACCOUNT_NONLOCKED SMALLINT,
   USER_CREDENTIALS_NONEXPIRED SMALLINT,
   USER_ORDER           INTEGER                        default 0,
   USER_VERSION         INTEGER                        default 0,
   USER_CREATOR         VARCHAR2(50),
   USER_CREATED         TIMESTAMP,
   USER_MODIFIER        VARCHAR2(50),
   USER_MODIFIED        TIMESTAMP,
   constraint PK_JEDA_USER primary key (USER_ID)
);

comment on column JEDA_USER.USER_ID is
'用户ID';

comment on column JEDA_USER.POSITION_ID is
'岗位ID';

comment on column JEDA_USER.ORG_ID is
'机构ID';

comment on column JEDA_USER.USER_NAME is
'用户姓名';

comment on column JEDA_USER.USER_PASSWORD is
'用户密码';

comment on column JEDA_USER.USER_ID_NO is
'用户身份证号';

comment on column JEDA_USER.USER_GENDER is
'用户性别';

comment on column JEDA_USER.USER_EMAIL is
'用户邮件地址';

comment on column JEDA_USER.USER_BIRTHDAY is
'用户生日';

comment on column JEDA_USER.USER_ADDRESS is
'用户地址';

comment on column JEDA_USER.USER_POST is
'用户邮编';

comment on column JEDA_USER.USER_TEL is
'用户电话';

comment on column JEDA_USER.USER_MOBILE is
'用户手机';

comment on column JEDA_USER.USER_DESCRIPTION is
'用户描述';

comment on column JEDA_USER.USER_ENABLED is
'帐户已启用';

comment on column JEDA_USER.USER_LOCKED is
'锁定标志';

comment on column JEDA_USER.USER_ACCOUNT_NONEXPIRED is
'帐户未过期';

comment on column JEDA_USER.USER_ACCOUNT_NONLOCKED is
'帐户未锁定';

comment on column JEDA_USER.USER_CREDENTIALS_NONEXPIRED is
'凭证未过期';

comment on column JEDA_USER.USER_ORDER is
'用户顺序';

comment on column JEDA_USER.USER_VERSION is
'用户数据版本';

comment on column JEDA_USER.USER_CREATOR is
'用户创建者';

comment on column JEDA_USER.USER_CREATED is
'用户创建时间';

comment on column JEDA_USER.USER_MODIFIER is
'用户修改者';

comment on column JEDA_USER.USER_MODIFIED is
'用户修改时间';

/*==============================================================*/
/* Index: FK_USER_ORG                                           */
/*==============================================================*/
create index FK_USER_ORG on JEDA_USER (
   ORG_ID ASC
);

/*==============================================================*/
/* Index: FK_POSITION_USER                                      */
/*==============================================================*/
create index FK_POSITION_USER on JEDA_USER (
   POSITION_ID ASC
);

alter table JEDA_FIELD
   add constraint FUNCTION_FIELD foreign key (FUNCTION_ID)
      references JEDA_FUNCTION (FUNCTION_ID);

alter table JEDA_FUNCTION
   add constraint FUNCTION_MODULE foreign key (MODULE_ID)
      references JEDA_MODULE (MODULE_ID);

alter table JEDA_MENU
   add constraint MENU_PARENT foreign key (PARENT_MENU_ID)
      references JEDA_MENU (MENU_ID);

alter table JEDA_PERMISSION
   add constraint ITEM_PERMISSION foreign key (SUB_ITEM_ID)
      references JEDA_SUB_ITEM (SUB_ITEM_ID);

alter table JEDA_PERMISSION
   add constraint PERMISSION_FIELD foreign key (FIELD_ID)
      references JEDA_FIELD (FIELD_ID);

alter table JEDA_PERMISSION_ORG
   add constraint PERMISSION_ORG foreign key (ORG_ID)
      references JEDA_ORG (ORG_ID);

alter table JEDA_PERMISSION_ORG
   add constraint PERMISSION_ORG2 foreign key (PERMISSION_ID)
      references JEDA_PERMISSION (PERMISSION_ID);

alter table JEDA_PERMISSION_USER
   add constraint PERMISSION_USER foreign key (PERMISSION_ID)
      references JEDA_PERMISSION (PERMISSION_ID);

alter table JEDA_PERMISSION_USER
   add constraint PERMISSION_USER2 foreign key (USER_ID)
      references JEDA_USER (USER_ID);

alter table JEDA_PORTLET_LOCATION
   add constraint PORTLET_LOCATION_POR foreign key (PORTLET_ID)
      references JEDA_PORTLET (PORTLET_ID);

alter table JEDA_PORTLET_LOCATION
   add constraint POSITION_PORTLET_LOC foreign key (POSITION_ID)
      references JEDA_POSITION (POSITION_ID);

alter table JEDA_POSITION_ORG
   add constraint POSITION_ORG foreign key (ORG_ID)
      references JEDA_ORG (ORG_ID);

alter table JEDA_POSITION_ORG
   add constraint POSITION_ORG2 foreign key (POSITION_ID)
      references JEDA_POSITION (POSITION_ID);

alter table JEDA_POSITION_PL
   add constraint POSITION_PL foreign key (POSITION_ID)
      references JEDA_POSITION (POSITION_ID);

alter table JEDA_POSITION_PL
   add constraint POSITION_PL2 foreign key (PL_ID)
      references JEDA_POSITION_LEVEL (PL_ID);

alter table JEDA_ROLE_FUNCTION
   add constraint ROLE_FUNCTION foreign key (ROLE_ID)
      references JEDA_ROLE (ROLE_ID);

alter table JEDA_ROLE_FUNCTION
   add constraint ROLE_FUNCTION2 foreign key (FUNCTION_ID)
      references JEDA_FUNCTION (FUNCTION_ID);

alter table JEDA_ROLE_MENU
   add constraint ROLE_MENU foreign key (ROLE_ID)
      references JEDA_ROLE (ROLE_ID);

alter table JEDA_ROLE_MENU
   add constraint ROLE_MENU2 foreign key (MENU_ID)
      references JEDA_MENU (MENU_ID);

alter table JEDA_ROLE_PERMISSION
   add constraint ROLE_PERMISSION foreign key (ROLE_ID)
      references JEDA_ROLE (ROLE_ID);

alter table JEDA_ROLE_PERMISSION
   add constraint ROLE_PERMISSION2 foreign key (PERMISSION_ID)
      references JEDA_PERMISSION (PERMISSION_ID);

alter table JEDA_ROLE_POSITION
   add constraint ROLE_POSITION foreign key (ROLE_ID)
      references JEDA_ROLE (ROLE_ID);

alter table JEDA_ROLE_POSITION
   add constraint ROLE_POSITION2 foreign key (POSITION_ID)
      references JEDA_POSITION (POSITION_ID);

alter table JEDA_ROLE_USER
   add constraint ROLE_USER foreign key (USER_ID)
      references JEDA_USER (USER_ID);

alter table JEDA_ROLE_USER
   add constraint ROLE_USER2 foreign key (ROLE_ID)
      references JEDA_ROLE (ROLE_ID);

alter table JEDA_SUB_ITEM
   add constraint ITEM_SUBITEM foreign key (ITEM_ID)
      references JEDA_ITEM (ITEM_ID);

alter table JEDA_USER
   add constraint POSITION_USER foreign key (POSITION_ID)
      references JEDA_POSITION (POSITION_ID);

alter table JEDA_USER
   add constraint USER_ORG foreign key (ORG_ID)
      references JEDA_ORG (ORG_ID);


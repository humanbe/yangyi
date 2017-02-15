<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<%
   String policy_old_name = request.getParameter("POLICY_OLD_NAME");
   String policy_code=request.getParameter("POLICY_CODE");
  
%>
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache" />
<title>运维自动化操作管理平台</title>
<link rel="SHORTCUT ICON" href="${ctx}/static/favicon.ico" />
<%@ include file="/include/extjs.libs.jsp"%>
<%@ include file="/include/jquery.libs.jsp"%>
<%@ include file="/include/highcharts.libs.jsp"%>
<%@ include file="/include/justgage.libs.jsp"%>
<script src="${ctx}/static/scripts/extjs/examples/ux/TabCloseMenu.js" type="text/javascript">
<!--
	//required for FF3 and Opera
//-->
</script>
<style type="text/css">
	.fontStyle{
		font-weight:bold;
		color:red;
	}
</style>
</head>
<body>
<%@ include file="/include/jeda.js.lib.jsp"%>
<script type="text/javascript">
Ext.onReady(function(){
	
	var tool_statusStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	tool_statusStore.load();
	
	this.tool_authorize_flagStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	this.tool_authorize_flagStore.load();

	
	var ServerGroupStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	 ServerGroupStore.load();

	var authorize_level_typeStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	 authorize_level_typeStore.load();
	var os_typeStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	 os_typeStore.load();
	var position_typeStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/TOOL_POSITION_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			 position_typeStore.load();
	

	var os_user_flagStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/TOOLBOX_OS_USER_FLAG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	 os_user_flagStore.load();
	
	var server_group_flag = new Ext.data.JsonStore({
		url : '${ctx}/${frameworkPath}/item/GROUP_SERVER_FLAG/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	 server_group_flag.load();
	
	var toolcharsetStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/TOOL_CHARSET/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	 toolcharsetStore.load();

	 var appsys_Store =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
			listeners : {
				load : function(store){
					if(store.getCount() == 0){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.system.no.authorize" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING
						});
					}
				}
			}
		});
		 appsys_Store.load(); 
		var userStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/jobdesign/getUsers',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['username','name'])
		});
		 userStore.load();
	
		
	
	var gridStore = new Ext.data.JsonStore(
			{
				
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${appPath}/ToolBoxController/AlarmViewtoolListindex',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'tool_code', 'appsys_code',
							'tool_name', 'tool_desc',
							'server_group','authorize_level_type',
							'field_type_one','field_type_two',
							'field_type_three','os_type',
							'position_type','tool_upload', 
							'tool_authorize_flag',
							'tool_creator', 'shell_name',
							'os_user','os_user_flag',
							'group_server_flag','tool_charset'
				],
				remoteSort : false,
				sortInfo : {
					field : 'appsys_code',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100,
					policy_old_name:'<%=policy_old_name%>',
					policy_code:'<%=policy_code%>'
				}
			});

	// 加载列表数据
	gridStore.load();
var grid = new Ext.grid.GridPanel(
		{
			title:'策略匹配工具列表',
			renderTo : 'toolBoxAlarmViewtoolList',
			region : 'center',
			border : false,
			loadMask : true,
			height: window.screen.height * 0.82,
			width:  window.screen.width * 0.95,
			autoScroll : true,
			//title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : false,
				getRowClass : function(record, rowIndex, rowParams, store){
					if(record.data.importantSeq =="1"){
						return 'x-grid-back-SandyBrown';
					}
					if((rowIndex + 1) % 2 === 0){
						return 'x-gridTran-row-alt';
					}
				}
			},
			store : gridStore,
			// 列定义

			columns : [
					new Ext.grid.RowNumberer(),
					
					{
						header :'<fmt:message key="toolbox.appsys_code" />',
						dataIndex : 'appsys_code',
						renderer :  appsys_Storeone,
						scope : this,
						sortable : true
					},
					
					{
						header :  '<fmt:message key="toolbox.tool_name" />',
						dataIndex : 'tool_name',
						width:200,
						sortable : true
					},
					{
						header : '<fmt:message key="toolbox.os_type" />',
						dataIndex : 'os_type',
						renderer :  os_typeone,
						scope : this,
						sortable : true
					},
					{
						header : '<fmt:message key="toolbox.field_type_one" />',
						dataIndex : 'field_type_one',
						scope : this,
						sortable : true

					},
					{
						header : '<fmt:message key="toolbox.field_type_two" />',
						dataIndex : 'field_type_two',
						scope : this,
						sortable : true

					},
					{
						header : '<fmt:message key="toolbox.field_type_three" />',
						dataIndex : 'field_type_three',
						scope : this,
						sortable : true

					},
					{

						header : '<fmt:message key="toolbox.tool_code" />',
						dataIndex : 'tool_code',
						sortable : true

					},
					{
						header : '<fmt:message key="toolbox.server_group" />',
						dataIndex : 'server_group',
						renderer :  ServerGroupone,
						scope : this,
						sortable : true

					},
					{
						header : '<fmt:message key="toolbox.position_type" />',
						dataIndex : 'position_type',
						renderer :  position_typeone,
						scope : this,
						sortable : true
					},
					 
					{
						header :  '<fmt:message key="toolbox.shell_name" />',
						dataIndex : 'shell_name',
						sortable : true
					},
					{
						header : '<fmt:message key="toolbox.authorize_level_type" />',
						dataIndex : 'authorize_level_type',
						renderer :  authorize_level_typeone,
						scope : this,
						sortable : true

					},
					{
						header :  '<fmt:message key="toolbox.os_user_flag" />',
						dataIndex : 'os_user_flag',
						renderer :  os_user_flagone,
						scope : this,
						sortable : true

					},
					{
						header :  '<fmt:message key="toolbox.group_server_flag" />',
						dataIndex : 'group_server_flag',
						renderer :  server_group_flagone,
						scope : this,
						sortable : true

					},
					{
						header : '<fmt:message key="toolbox.os_user" />',
						dataIndex : 'os_user',
						sortable : true
					},{
						header :'<fmt:message key="toolbox.tool_authorize_flag" />',
						dataIndex : 'tool_authorize_flag',
						renderer :  tool_authorize_flagone,
						scope : this,
						sortable : true
					},
					{
						header :  '<fmt:message key="toolbox.tool_charset" />',
						dataIndex : 'tool_charset',
						renderer :  tool_charsetone,
						scope : this,
						sortable : true

					},{
						header : '<fmt:message key="toolbox.tool_creator" />',
						dataIndex : 'tool_creator',
						renderer :  userStoreValue,
						scope : this,
						sortable : true
					},{
						header : '<fmt:message key="toolbox.tool_desc" />',
						dataIndex : 'tool_desc',
						sortable : true
					}
					 ],
					// 定义按钮工具条
						tbar : new Ext.Toolbar(
								{
									items : [
									         
									]
								}),
					 bbar : new Ext.PagingToolbar({
							store : gridStore,
							displayInfo : true,
							pageSize : 100
						})
		});
		
function tool_statusone(value) {

	var index = tool_statusStore.find('value', value);

	if (index == -1) {
		return value;
	} else {
		return tool_statusStore.getAt(index).get('name');
	}
};

function tool_authorize_flagone(value) {

	var index = tool_authorize_flagStore.find('value', value);

	if (index == -1) {
		return value;
	} else {
		return tool_authorize_flagStore.getAt(index).get('name');
	}
};


 
function  ServerGroupone(value) {

	var index =  ServerGroupStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  ServerGroupStore.getAt(index).get('name');
	}
};
function  authorize_level_typeone(value) {
	var index =  authorize_level_typeStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  authorize_level_typeStore.getAt(index).get('name');
	}
};
function  os_typeone(value) {
	var index =  os_typeStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  os_typeStore.getAt(index).get('name');
	}
};

function position_typeone(value) {
	var index =  position_typeStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  position_typeStore.getAt(index).get('name');
	}
};


function os_user_flagone(value) {

	var index =  os_user_flagStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  os_user_flagStore.getAt(index).get('name');
	}
};
function server_group_flagone(value) {

	var index =  server_group_flag.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  server_group_flag.getAt(index).get('name');
	}
};
function tool_charsetone(value) {

	var index =  toolcharsetStore.find('value', value);
	if (index == -1) {
		return value;
	} else {
		return  toolcharsetStore.getAt(index).get('name');
	}
};
function appsys_Storeone(value) {

	var index =  appsys_Store.find('appsysCode', value);
	if (index == -1) {
		return value;
	} else {
		return  appsys_Store.getAt(index).get('appsysName');
	}
};
function  userStoreValue(value) {
	var index =  userStore.find('username', value);
	if (index == -1) {
		return value;
	} else {
		return  userStore.getAt(index).get('name');
	}
};

});
</script>
<div id="toolBoxAlarmViewtoolList"  style="height: window.screen.height; width:window.screen.width"></div>
</body>
</html>


<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var eventIdStore = new Ext.data.Store(
			{
				proxy : new Ext.data.HttpProxy(
						{
							url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
							method : 'GET',
							disableCaching : true
						}),
				reader : new Ext.data.JsonReader({}, [ 'appsysCode','appsysName' ]),
				listeners : {
					load : function(store) {
						if (store.getCount() == 0) {
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
	var eventlogType = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/LOG_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	//日志来源
	var eventlogResourceType = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/LOG_RESOURCE_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	//定义列表
	toolbox_eventLogList = Ext.extend(Ext.Panel,
					{
						gridStore : null,// 数据列表数据源
						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
							eventlogResourceType.load();
							eventlogType.load();
							eventIdStore.load();
							Ext.apply(this, cfg);
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/dplysystemlog/eventlogindex',
													disableCaching : false
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'logJnlNo', 'execDate',
												'appsysCode','event_id',
												'logResourceType',
												'requestName', 'logType',
												'execStatus', 'execStartTime',
												'execCompletedTime',
												'execCreatedTime',
												'execUpdatedTime',
												'authorizedUser',
												'platformUser' ],
										remoteSort : true,
										sortInfo : {
											field : 'logJnlNo',
											direction : 'desc'
										},
										baseParams : {
											start : 0,
											limit : 100,
											event_id :'${param.event_id}'
										}
									});
							this.gridStore.load();
							// 实例化数据列表组件
							this.grid = new Ext.grid.GridPanel(
									{
										//id : '',
										region : 'center',
										border : false,
										loadMask : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										store : this.gridStore,
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												{
													header : '<fmt:message key="property.logJnlNo" />',
													dataIndex : 'logJnlNo',
													sortable : true,
													width : 200,
													hidden : true
												},{
													header : '<fmt:message key="toolbox.alarm_event_id" />',
													dataIndex : 'event_id',
													sortable : true,
													width : 200,
													hidden : true
												},
												{
													header : '<fmt:message key="property.execDate" />',
													dataIndex : 'execDate',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.appSys" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.logResourceType" />',
													dataIndex : 'logResourceType',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '1':
															return '自动化平台';
														case '2':
															return 'BRPM';
														case '3':
															return 'BSA';
														}
													}
												},
												{
													header : '<fmt:message key="property.requestName" />',
													dataIndex : 'requestName',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.logType" />',
													dataIndex : 'logType',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '1':
															return '应用发布';
														case '2':
															return '工具箱';
														case '3':
															return '自动巡检';
														}
													}
												},
												{
													header : '<fmt:message key="property.execStatus" />',
													dataIndex : 'execStatus',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '0':
															return '正常';
														case '1':
															return '平台异常';
														case '2':
															return 'BRPM异常';
														case '3':
															return 'BSA异常';
														}
													}
												},
												{
													header : '<fmt:message key="property.execStartTime" />',
													dataIndex : 'execStartTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execCompletedTime" />',
													dataIndex : 'execCompletedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execCreatedTime" />',
													dataIndex : 'execCreatedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execUpdatedTime" />',
													dataIndex : 'execUpdatedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.authorizedUser" />',
													dataIndex : 'authorizedUser',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.platformUser" />',
													dataIndex : 'platformUser',
													sortable : true,
													width : 200
												} ],
										// 定义按钮工具条
										tbar : new Ext.Toolbar({
											items : [ '-' ]
										}),
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
											displayInfo : true,
											pageSize : 100
										}),
										listeners : {
											scope : this,
											// 行双击事件：打开数据查看页面
											rowdblclick : this.doView
										}
									});
							// 实例化查询表单
						
							// 设置基类属性
							toolbox_eventLogList.superclass.constructor.call(this,
									{
										layout : 'border',
										border : false,
										items : [  this.grid ]
									});
						},
						// 查询事件
						doFind : function() {
							Ext.apply(this.grid.getStore().baseParams,this.form.getForm().getValues());
							this.grid.getStore().load();
						},// 重置查询表单
						doReset : function() {
							this.form.getForm().reset();
						},
						doExport : function() {
							window.location = '${ctx}/${managePath}/dplysystemlog/export.xls';
						},
						doView : function() {
							var record = this.grid.getSelectionModel().getSelected();
							var params = {
								logJnlNo : record.get('logJnlNo')
							};
							app.loadWindow('${ctx}/${managePath}/dplysystemlog/view',params);
						}
					});
	var toolbox_eventLogList = new toolbox_eventLogList();
</script>

<script type="text/javascript">
	Ext.getCmp("EVENTLOG").add(toolbox_eventLogList);
	Ext.getCmp("EVENTLOG").doLayout();
</script>


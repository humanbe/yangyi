<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var logsysIdsStore = new Ext.data.Store(
			{
				proxy : new Ext.data.HttpProxy(
						{
							url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
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
	var logType = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/LOG_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	//日志来源
	var logResourceType = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/LOG_RESOURCE_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	//定义列表
	DplySystemLogList = Ext.extend(Ext.Panel,
					{
						gridStore : null,// 数据列表数据源
						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
							logResourceType.load();
							logType.load();
							logsysIdsStore.load();
							Ext.apply(this, cfg);
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/dplysystemlog/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'logJnlNo', 'execDate',
												'appsysCode',
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
											limit : 100
										}
									});
							this.gridStore.load();
							// 实例化数据列表组件
							this.grid = new Ext.grid.GridPanel(
									{
										id : 'DplySystemLogIndexListGridPanelIndex',
										region : 'center',
										border : false,
										loadMask : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										store : this.gridStore,
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												{
													header : '<fmt:message key="property.logJnlNo" />',
													dataIndex : 'logJnlNo',
													sortable : true,
													hidden : true
												},
												{
													header : '<fmt:message key="property.execDate" />',
													dataIndex : 'execDate',
													sortable : true
												},
												{
													header : '<fmt:message key="property.appSys" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 200,
													renderer : this.logAppsys_Store
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
													renderer :this.logTypeone
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
													width : 150
												},
												{
													header : '<fmt:message key="property.execCompletedTime" />',
													dataIndex : 'execCompletedTime',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.execCreatedTime" />',
													dataIndex : 'execCreatedTime',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.execUpdatedTime" />',
													dataIndex : 'execUpdatedTime',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.authorizedUser" />',
													dataIndex : 'authorizedUser',
													sortable : true,
													width : 100
												},
												{
													header : '<fmt:message key="property.platformUser" />',
													dataIndex : 'platformUser',
													sortable : true,
													width : 100
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
							this.form = new Ext.FormPanel(
									{
										region : 'east',
										title : '<fmt:message key="button.find" />',
										labelAlign : 'right',
										labelWidth : 80,
										buttonAlign : 'center',
										frame : true,
										split : true,
										width : 250,
										minSize : 250,
										maxSize : 250,
										autoScroll : true,
										collapsible : true,
										collapseMode : 'mini',
										border : false,
										defaults : {
											anchor : '100%',
											msgTarget : 'side'
										},
										// 定义查询表单组件
										items : [
												{
													xtype : 'combo',
													fieldLabel : '<fmt:message key="property.appSys" />',
													id : 'DplySystemLogIndexAplCode',
													displayField : 'appsysName',
													valueField : 'appsysCode',
													hiddenName : 'appsysCode',
													typeAhead : true,
													//forceSelection : true,
													store : logsysIdsStore,
													tabIndex : this.tabIndex++,
													mode : 'local',
													triggerAction : 'all',
													editable : true,
													allowBlank : true,
													listeners : {
														scope : this,
														 beforequery : function(e){
															var combo = e.combo;
															combo.collapse();
															 if(!e.forceAll){
																var input = e.query.toUpperCase();
																var regExp = new RegExp('.*' + input + '.*');
																combo.store.filterBy(function(record, id){
																	var text = record.get(combo.displayField);
																	return regExp.test(text);
																}); 
																combo.restrictHeight();
																combo.expand();
																return false;
															} 
														}
													}
												},
												{
													xtype : 'datefield',
													fieldLabel : '<fmt:message key="property.execStartTime" />',
													name : 'execStartTime',
													format : 'Ymd'
												},
												{
													xtype : 'datefield',
													fieldLabel : '<fmt:message key="property.execCompletedTime" />',
													name : 'execCompletedTime',
													format : 'Ymd'
												},
												{
													xtype : 'combo',
													fieldLabel : '<fmt:message key="property.logType" />',
													id : 'DplySystemLogIndexLogType',
													hiddenName : 'logType',
													displayField : 'name',
													valueField : 'value',
													typeAhead : true,
													forceSelection : true,
													store : logType,
													tabIndex : this.tabIndex++,
													mode : 'local',
													triggerAction : 'all',
													editable : true
												},
												{
													xtype : 'combo',
													fieldLabel : '<fmt:message key="property.logResourceType" />',
													id : 'DplySystemLogIndexLogResourceType',
													hiddenName : 'logResourceType',
													displayField : 'name',
													valueField : 'value',
													typeAhead : true,
													forceSelection : true,
													store : logResourceType,
													tabIndex : this.tabIndex++,
													mode : 'local',
													triggerAction : 'all',
													editable : true
												} ],
										// 定义查询表单按钮
										buttons : [
												{
													text : '<fmt:message key="button.ok" />',
													iconCls : 'button-ok',
													scope : this,
													handler : this.doFind
												},
												{
													text : '<fmt:message key="button.reset" />',
													iconCls : 'button-reset',
													scope : this,
													handler : this.doReset
												} ]
									});
							// 设置基类属性
							DplySystemLogList.superclass.constructor.call(this,
									{
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
									});
						},
						logAppsys_Store : function(value) {
							var index = logsysIdsStore.find('appsysCode', value);
							if (index == -1) {
								return value;
							} else {
								return logsysIdsStore.getAt(index).get('appsysName');
							}
						},
						logTypeone : function(value) {
							var index = logType.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return logType.getAt(index).get('name');
							}
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
	var DplySystemLogList = new DplySystemLogList();
</script>
<sec:authorize access="hasRole('SYSTEM_LOG_EXP')">
<script type="text/javascript">
	DplySystemLogList.grid.getTopToolbar().add({
		iconCls : 'button-export',
		text : '<fmt:message key="button.export" />',
		scope : DplySystemLogList,
		handler : DplySystemLogList.doExport
	}, '-');
</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("DplySystemLog").add(DplySystemLogList);
	Ext.getCmp("DplySystemLog").doLayout();
</script>


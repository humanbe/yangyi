<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var binFilePath=null;
	var setFilePath=null;
	var initFilePath=null;
	var checkParamgridForm=null;
	var ssriptDeployGridPanel = null;
	ScriptUploadForm = Ext.extend(Ext.FormPanel,
					{
						tabIndex : 0,// 查询表单组件Tab键顺序						flag : true,
						tabIndex : 0,// Tab键顺序						constructor : function(cfg) {
							// 构造方法							Ext.apply(this, cfg);
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止							Ext.getDoc().on('keydown',function(e) {
												if (e.getKey() == 8
														&& e.getTarget().type == 'text'
														&& !e.getTarget().readOnly) {
												} else if (e.getKey() == 8
														&& e.getTarget().type == 'textarea'
														&& !e.getTarget().readOnly) {
												} else if (e.getKey() == 8) {
													e.preventDefault();
												}
											});
							csm = new Ext.grid.CheckboxSelectionModel();
							csm3 = new Ext.grid.CheckboxSelectionModel();
							//必选参数数据源
						 	this.checkInitPanelStore = new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									url : '${ctx}/${managePath}/scriptExec/queryInit',
									disableCaching : true
								}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'scriptType'],
								pruneModifiedRecords : true,
								baseParams : {
									start : 0,
									limit : 20,
									osType :'${param.osType}',
									checkItemCode:'${param.checkItemCode}'
								}
							}); 
						 	this.checkInitPanelStore.load();
						 
						 	ssriptDeployGridPanel = new Ext.Panel(
									{
										title : '服务器',
										buttonAlign : 'center',
										frame : true,
										autoScroll : false,
										labelAlign : 'center',
										labelWidth : 100,
										height : 35,
										border : false,
										defaults : {
											anchor : '75%',
											msgTarget : 'side'
										},
										layout : 'form',
										// 定义查询表单组件
										items : [ {
											layout : 'column',
											fieldLabel : '<fmt:message key="property.serverIp" />',
											items : [
													{
														xtype : 'textfield',
														width : 500,
														id : 'execInput',
														name : 'serverIp'
													},
													{
														xtype : 'button',
														text : '<fmt:message key="button.ok" />',
														scope : this,
														iconCls : 'button-ok',
														handler : this.doFind
													} ,{
														xtype : 'textfield',
														id : 'scriptExecValueId',
														hiddenName : 'scriptDeployValue',
														name : 'scriptDeployValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},{
														xtype : 'textfield',
														id : 'execValueId',
														hiddenName : 'deployValue',
														name : 'deployValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},{
														xtype : 'textfield',
														id : 'execBinScriptNameId',
														hiddenName : 'binScriptName',
														name : 'binScriptName',
														tabIndex : this.tabIndex++,
														hidden : true
													},{
														xtype : 'textfield',
														id : 'execOsTypesId',
														hiddenName : 'osTypes',
														name : 'osTypes',
														tabIndex : this.tabIndex++,
														hidden : true
													},{
														xtype : 'textfield',
														id : 'execFieldTypesId',
														hiddenName : 'fieldTypes',
														name : 'fieldTypes',
														tabIndex : this.tabIndex++,
														hidden : true
													}]
										} ]
									});
						 	//可选参数数据源fieldTypes
							this.serverIpPanelStore = new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									url : '${ctx}/${managePath}/scriptExec/queryServerIp',
									disableCaching : true
								}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'appsysName', 
										'serverName' ,'serverIp'],
								pruneModifiedRecords : true,		
								remoteSort : false,
								sortInfo : {
									field : 'appsysName',
									direction : 'ASC'
								}, 
								baseParams : {
									start : 0,
									limit : 20,
									osType :'${param.osType}',
									serverIp : ''
								}
							}); 
							this.serverIpPanelStore.load();
							//必选参数
							  this.checkInitPanel = new Ext.grid.EditorGridPanel({
										id : 'ParamgridFormid',
										region : 'center', 
										border : true,
										height : 110,
										loadMask : true,
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										defaults : {
											anchor : '100%',
											msgTarget : 'side'
										},
										store : this.checkInitPanelStore,
										frame : true,
										sm:csm,
										// 列定义
										columns : [ new Ext.grid.RowNumberer(),csm,
										{
											header :  '初始化项',
											dataIndex : 'scriptType',
											allowBlank : false
										}
										]
									}); 
							//可选参数
							  serverIpPanel = new Ext.grid.EditorGridPanel({
									region : 'center', 
									border : true,
									height : 440,
									loadMask : true,
									columnLines : true,
									viewConfig : {
										forceFit : true
									},
									defaults : {
										anchor : '100%',
										msgTarget : 'side'
									},
									store : this.serverIpPanelStore,
									frame : true,
									sm:csm3,
									// 列定义
									columns : [ new Ext.grid.RowNumberer(),csm3,
									{
										header :  '应用系统',
										name : 'appsysName',
										sortable : true,
										dataIndex : 'appsysName',
										allowBlank : false
									},  {
										header :'主机名',
										sortable : true,
										name : 'serverName',
										dataIndex : 'serverName'
									},{
										header :  '服务器',
										name : 'serverIp',
										sortable : true,
										dataIndex : 'serverIp',
										allowBlank : false
									}]
								}); 
							this.uploadForm = new Ext.Panel(
									{
										items : [ {
											
											layout : 'form',
											autoHeight : true,
											autoScroll : true,
											labelAlign : 'right',
											border : false,
											items : [ {
												layout : 'column',
												items : [
														{
															labelAlign : 'right',
															border : false,
															items : [ssriptDeployGridPanel,
																	this.checkInitPanel,
																	serverIpPanel ]
														} ]
											} ]
										} ]
									});
							// 设置基类属性							ScriptUploadForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/scriptExec/create',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.uploadForm],
												// 定义按钮grid
								       			buttons : [{
								       				text : '执行',
								       				iconCls : 'button-start',
								       				tabIndex : this.tabIndex++,
								       				formBind : true,
								       				scope : this,
								       				handler : this.doSave
								       			},{
								       				text : '<fmt:message key="button.cancel" />',
								       				iconCls : 'button-cancel',
								       				formBind : true,
								       				scope : this,
								       				handler : this.doCancel
								       			}] 
											});
						},
						// 保存操作
						doSave : function() {
							var initrecords = this.checkInitPanel.getSelectionModel().getSelections();
							if (initrecords == '') {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '请选择初始化项',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
								return false;
							}
							var serversrecords = serverIpPanel.getSelectionModel().getSelections();
							if (serversrecords == '') {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '请选择服务器',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
								return false;
							}
							var paramJson = [];
							var jsonServer = [];
							var records = this.checkInitPanel.getSelectionModel().getSelections();
							for ( var i = 0; i < records.length; i++) {
								scriptType = records[i].get('scriptType');
								paramJson.push(scriptType);
							}
							Ext.getCmp('scriptExecValueId').setValue(Ext.util.JSON.encode(paramJson));
							
							var record = serverIpPanel.getSelectionModel().getSelections();
							for ( var i = 0; i < record.length; i++) {
								serverIp = record[i].get('serverIp');
								jsonServer.push(serverIp);
							}
							Ext.getCmp('execValueId').setValue(Ext.util.JSON.encode(jsonServer));
							var binScriptName='${param.binScriptName}';
							Ext.getCmp('execBinScriptNameId').setValue(binScriptName);
							var osTypes='${param.osType}';
							Ext.getCmp('execOsTypesId').setValue(osTypes);
							var fieldTypes='${param.fieldType}';
							Ext.getCmp('execFieldTypesId').setValue(fieldTypes);
							scriptUploadForm.getForm().submit(
									{
										scope : scriptUploadForm,
										timeout : 1000000, 
										success : scriptUploadForm.saveSuccess,
										failure : scriptUploadForm.saveFailure,
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.saving" />'
									});
						},
						// Grid查询事件
						doFind : function() {
							Ext.apply(this.serverIpPanelStore.baseParams, {
								serverIp : Ext.getCmp('execInput').getValue()
							});
							serverIpPanel.getStore().load();
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('add_scriptExec');
						},
						// 保存成功回调
						saveSuccess : function(form, action) {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.successful" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200,
										fn : function() {
											app.closeTab('add_scriptExec');
											var list = Ext.getCmp(
													"SCRIPT_DEPLOY").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab('SCRIPT_DEPLOY','<fmt:message key="button.view" /><fmt:message key="function" />',
															'${ctx}/${managePath}/scriptExec/index');
										}
									});
						},
						// 保存失败回调
						saveFailure : function(form, action) {
							var error = decodeURIComponent(action.result.error);
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});
	var scriptUploadForm = new ScriptUploadForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_scriptExec").add(scriptUploadForm);
	// 刷新Tab页布局
	Ext.getCmp("add_scriptExec").doLayout();
</script>
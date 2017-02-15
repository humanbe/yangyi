<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var execos_typeStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var execSysIdsStore = new Ext.data.Store(
			{
				proxy : new Ext.data.HttpProxy(
						{
							url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
							method : 'GET',
							disableCaching : true
						}),
				reader : new Ext.data.JsonReader({}, [ 'appsysCode',
						'appsysName' ]),
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
	var cmnenvTree = null;
	var cmnenvGridform = null;
	var serverIpPanel = null;
	var jobName = '${param.checkJobName}';
	ExecAllForm = Ext.extend(Ext.FormPanel,{
						gridform : null,
						gridStore : null,// 数据列表数据源
						Panel : null,// 查询表单组件
						tree : null,// 树形组件
						treeform : null,
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						grid : null,
						flag : true,
						tabIndex : 0,// Tab键顺序
						constructor : function(cfg) {
							// 构造方法
							Ext.apply(this, cfg);
							execos_typeStore.load();
							execSysIdsStore.load();
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止
							csm = new Ext.grid.CheckboxSelectionModel();
							Ext.getDoc().on('keydown',function(e) {
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
							csmServer = new Ext.grid.CheckboxSelectionModel();
							// 实例化树形功能菜单
							this.treeLoader = new Ext.tree.TreeLoader(
									{
										requestMethod : 'POST',
										dataUrl : '${ctx}/${managePath}/scriptExec/queryScript',
										baseParams : {
											osType : ''
										}
									});
							// 定义树形组件
							cmnenvTree = new Ext.tree.TreePanel({
								id : 'scriptExecAllTree',
								title : '巡检项',
								xtype : 'treepanel',
								border : false,
								split : true,
								frame : true,
								height : 585,
								autoScroll : true,
								root : new Ext.tree.AsyncTreeNode({
									text : '初始化项',
									draggable : false,
									iconCls : 'node-root',
									id : 'TREE_ROOT_NODE'
								}),
								loader : this.treeLoader,
								listeners : {
									'checkchange' : function(node, checked) {
										if (checked) {
											if (node.parentNode.id != 'TREE_ROOT_NODE') {
												node.bubble(function(n) {
													if (n.getUI().isChecked()) {
														if (!n.parentNode.getUI().isChecked()) {
															n.parentNode.getUI().toggleCheck();
														}
													}
												});
											}
										} else {
											node.eachChild(function(child) {
												child.getUI().toggleCheck(checked);
												child.fireEvent('checkchange', child, checked);
											});
										}
									},load : function(n) {
										cmnenvTree.expandAll();
									}
								}
							});
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
									osType :'',
									serverIp : '',
									appsysCode : ''
								}
							}); 
							this.serverIpPanelStore.load();
							cmnenvGridform = new Ext.Panel(
									{
										labelAlign : 'right',
										labelWidth : 80,
										height : 90,
										buttonAlign : 'center',
										frame : true,
										autoScroll : true,
										labelAlign : 'center',
										labelWidth : 100,
										border : false,
										defaults : {
											anchor : '100%',
											msgTarget : 'side'
										},
										layout : 'form',
										// 定义查询表单组件
										items : [ {
											layout:'column',
											items:[{
											     columnWidth:.5,
											     layout:'form',
											     items:[
													{
														xtype : 'combo',
														fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
														displayField : 'appsysName',
														valueField : 'appsysCode',
														hiddenName : 'appsysCode',
														id : 'execAppsysCode',
														width : 140,
														typeAhead : true,
														//forceSelection : true,
														store : execSysIdsStore,
														tabIndex : this.tabIndex++,
														mode : 'local',
														triggerAction : 'all',
														editable : true,
														allowBlank : true,
														listeners : {
															'beforequery' : function(e) {
																var combo = e.combo;
																combo.collapse();
																if (!e.forceAll) {
																	var input = e.query.toUpperCase();
																	var regExp = new RegExp('.*' + input + '.*');
																	combo.store.filterBy(function(record,id) {
																				var text = record.get(combo.displayField);
																				return regExp.test(text);
																			});
																	combo.restrictHeight();
																	combo.expand();
																	return false;
																}
															}
														}
													}]
											},{
											     columnWidth:.5,
											     layout:'form',
											     items:[
													{
														xtype : 'textfield',
														fieldLabel :'服务器',
														width : 120,
														id : 'execInput',
														name : 'serverIp'

													}]
											} ,{
												xtype : 'textfield',
												id : 'checkInitId',
												hiddenName : 'checkInitValue',
												name : 'checkInitValue',
												tabIndex : this.tabIndex++,
												hidden : true
											},{
												xtype : 'textfield',
												id : 'serverId',
												hiddenName : 'serverValue',
												name : 'serverValue',
												tabIndex : this.tabIndex++,
												hidden : true
											},{
												xtype : 'textfield',
												id : 'execOsTypesId',
												hiddenName : 'execOsType',
												name : 'execOsType',
												tabIndex : this.tabIndex++,
												hidden : true
											}]
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
							 serverIpPanel = new Ext.grid.EditorGridPanel({
									region : 'center', 
									border : true,
									height : 600,
									loadMask : true,
									frame : true,
									columnLines : true,
									viewConfig : {
										forceFit : true
									},
									defaults : {
										anchor : '100%',
										msgTarget : 'side'
									},
									store : this.serverIpPanelStore,
									sm:csm,
									// 列定义
									columns : [ new Ext.grid.RowNumberer(),csm,
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
							// 实例化参数数据列表组件
							this.firstPanel = new Ext.Panel(
									{
										items : [ {
											title : '查询',
											layout : 'form',
											height : 570,
											labelAlign : 'right',
											border : false,
											items : [ {
												items : [ {
													labelAlign : 'right',
													border : false,
													items : [ cmnenvGridform,
													          serverIpPanel ]
												} ]
											} ]
										} ]
									});

							this.threePanel = new Ext.Panel(
									{
										items : [ {
											layout : 'form',
											autoScroll : true,
											labelAlign : 'right',
											border : true,
											items : [
													{
														layout : 'column',
														border : false,
														iconCls : 'menu-node-change',
														items : [ {
															columnWidth : .75,
															layout : 'form',
															defaults : {
																anchor : '100%'
															},
															border : false,
															labelAlign : 'right',
															items : [ {
																xtype : 'combo',
																fieldLabel : '<font color=red>*</font>&nbsp;操作系统',
																id : 'exec_osType',
																emptyText : '<fmt:message key="job.select_please" />',
																store : execos_typeStore,
																displayField : 'name',
																valueField : 'value',
																hiddenName : '',
																mode : 'local',
																typeAhead : true,
																triggerAction : 'all',
																allowBlank : false,
																editable : false, //输入 索引
																tabIndex : this.tabIndex++,
																listeners : {
																	scope : this,'beforequery' : function(e) {
																		var combo = e.combo;
																		combo.collapse();
																		if (!e.forceAll) {
																			var input = e.query.toUpperCase();
																			var regExp = new RegExp('.*' + input + '.*');
																			combo.store.filterBy(function(record,id) {
																						var text = record.get(combo.displayField);
																						return regExp.test(text);
																					});
																			combo.restrictHeight();
																			combo.expand();
																			return false;
																		}
																	},
																	select : function(combo,record,index) {
																		 Ext.getCmp('execInput').setValue('');
																		 Ext.getCmp('execAppsysCode').setValue('');
																		Ext.apply(this.treeLoader.baseParams,{osType : Ext.getCmp('exec_osType').getValue()});
																		cmnenvTree.expandAll();
																		var treeRoot = Ext.getCmp("scriptExecAllTree").getRootNode();
																		//重新加载树形菜单
																		treeRoot.reload();
																		//完全展开树形菜单
																		Ext.getCmp("scriptExecAllTree").root.expand();
																		this.serverIpPanelStore.baseParams.osType = Ext.getCmp('exec_osType').getValue();
																		this.serverIpPanelStore.reload();
																	}
																}
															} ]
														} ]
													},
													{
														layout : 'column',
														items : [
																{
																	columnWidth : .45,
																	labelAlign : 'right',
																	//frame : true,
																	border : true,
																	items : [ cmnenvTree ]
																},
																{
																	columnWidth : .55,
																	border : true,
																	frame : true,
																	labelAlign : 'right',
																	items : [ this.firstPanel ]
																} ]
													} ]
										} ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												cmnenvTree.getRootNode().reload();
												this.gridStore.reload();
											}
										}
									});
							// 设置基类属性
							ExecAllForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/scriptExec/execall',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.threePanel ],
												// 定义按钮grid
								       			buttons : [{
								       				text : '执行',
								       				iconCls : 'button-start',
								       				tabIndex : this.tabIndex++,
								       				formBind : true,
								       				scope : this,
								       				handler : this.doSave
								       			}] 
											});
						},
						// 保存操作 checkItemName
						doSave : function() {
							 var check = Ext.getCmp('scriptExecAllTree').getChecked();
							if (check == '') {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '请选择初始化项',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
								return false;
							} 
							
							var nodes = Ext.getCmp('scriptExecAllTree').getChecked();
							var json = new Array();
				    		var check='';
				    		var init='';
					    	for(var t=0 ; t<nodes.length ; t++){
								if(nodes[t].leaf != true){
									check=nodes[t].text;
									for(var j=0 ; j<nodes.length ; j++){
										if(nodes[j].leaf == true && nodes[j].attributes.checkItemName == check){
											init+='|+|'+nodes[j].attributes.scriptType;
										}
									}
								json.push(check  + init);
								}
					    	}
					    	Ext.getCmp('checkInitId').setValue(Ext.util.JSON.encode(json));
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
							var jsonServer = [];
						 var record = serverIpPanel.getSelectionModel().getSelections();
							for ( var i = 0; i < record.length; i++) {
								serverIp = record[i].get('serverIp');
								jsonServer.push(serverIp);
							}
							Ext.getCmp('serverId').setValue(Ext.util.JSON.encode(jsonServer)); 
							
							var execOsType=Ext.getCmp('exec_osType').getValue();
							Ext.getCmp('execOsTypesId').setValue(execOsType);
							execAllForm.getForm().submit(
									{
										scope : execAllForm,
										timeout : 100000000, 
										success : execAllForm.saveSuccess,
										failure : execAllForm.saveFailure,
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.saving" />'
									});
						},
						doFind : function() {
							Ext.apply(this.serverIpPanelStore.baseParams, {
								serverIp : Ext.getCmp('execInput').getValue()
							});
							Ext.apply(this.serverIpPanelStore.baseParams, {
								appsysCode : Ext.getCmp('execAppsysCode').getValue()
							});
							serverIpPanel.getStore().load();
						},
						// 重置查询表单
						doReset : function() {
							Ext.getCmp('execAppsysCode').setValue('');
							Ext.getCmp('execInput').setValue('');
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('add_CmnEnvironment1');
						},
						// 保存成功回调
						saveSuccess : function(form, action) {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.successful" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200
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
	var execAllForm = new ExecAllForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("EXEC_ALL").add(execAllForm);
	// 刷新Tab页布局
	Ext.getCmp("EXEC_ALL").doLayout();
</script>
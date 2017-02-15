<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var tc = null;
	var ac = null;
	var sg = null;
	var pc = null;
	var treeNode = null;
	var groupName = null;
	var ids = new Array();
	var cmnenvTree = null;
	var cmnenvParamGrid = null;
	var cmnenvGrid = null;
	var cmnenvPanel = null;
	var cmnenvGridform = null;
	var ParamgridStore;
	var cmnenvGroupStore = null;
	var envcodeInfoStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var serverUseStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/APP_PATTERN/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	serverUseStore.load();
	var shareStoreFlagStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/SHARE_STORE_FLAG/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	shareStoreFlagStore.load();
	EnvCreateForm = Ext.extend(Ext.FormPanel,
					{
						gridform : null,
						gridStore : null,// 数据列表数据源						Panel : null,// 查询表单组件
						tree : null,// 树形组件
						treeform : null,
						tabIndex : 0,// 查询表单组件Tab键顺序						csm : null,// 数据列表选择框组件						grid : null,
						flag : true,
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
							csmServer = new Ext.grid.CheckboxSelectionModel();
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									url : '${ctx}/${managePath}/cmnenvironment/ipIndex',
									disableCaching : true
								}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'serverIp' ],
								remoteSort : true,
								sortInfo : {
									field : 'serverIp',
									direction : 'ASC'
								},
								baseParams : {
									start : 0,
									appsysCode : '',
									serverIp : '',
									limit : 50
								},
								listeners : {
									load : function(store) {
										if (store.getCount() == 0) {
											Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.serverIsNull" />',
														minWidth : 200,
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.WARNING
													});
										}
									}
								}
							});
							cmnenvGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});

							this.envsysIdsStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
													method : 'GET',
													disableCaching : true
												}),
										reader : new Ext.data.JsonReader({}, ['appsysCode', 'appsysName' ]),
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

							this.envsysIdsStore.load();
							envcodeInfoStore.load();
							this.environmentTypeStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/cmnenvironment/queryENV',
													method : 'GET',
													disableCaching : true
												}),
										reader : new Ext.data.JsonReader({}, ['NAME','ENV'])
									});
							this.environmentTypeStore.load();
							cmnenvGroupStore.load();
							csm = new Ext.grid.CheckboxSelectionModel();
							csm2 = new Ext.grid.CheckboxSelectionModel({handleMouseDown : Ext.emptyFn});
							// 实例化树形功能菜单
							this.treeLoader = new Ext.tree.TreeLoader(
									{
										requestMethod : 'POST',
										dataUrl : '${ctx}/${managePath}/cmnenvironment/queryCreateTree',
										baseParams : {
											appsysCode : '',
											environmentCode : ''
										},
										listeners : {
											scope : this,
											load : function(tree, node) {
												var records = cmnenvParamGrid.getSelectionModel().getSelections();
												groupName = new Array();
												for ( var i = 0; i < records.length; i++) {
													var s = records[i].get('value');
													groupName.push(s);
												}
												if (groupName == '') {
													cmnenvTree.getRootNode().removeAll();
												}
												var equalFlag = false;
												var delTreeNode = [];
												for ( var i = 0; i < cmnenvTree.getRootNode().childNodes.length; i++) {
													equalFlag = false;
													for ( var j = 0; j < groupName.length; j++) {
														if (cmnenvTree.getRootNode().childNodes[i].text == groupName[j]) {
															equalFlag = true;
														}
													}
													if (!equalFlag) {
														cmnenvTree.getRootNode().childNodes[i].cascade(function(_node) {
																	cmnenvTree.getRootNode().childNodes[i].removeChild(_node);
																});
														delTreeNode.push(cmnenvTree.getRootNode().childNodes[i]);
													}
												}
												Ext.each(delTreeNode, function(delNode) {
													cmnenvTree.getRootNode().removeChild(delNode);
												});
												for ( var i = 0; i < ids.length; i++) {
													var existNode = cmnenvTree.getRootNode().findChild('text',ids[i]);
													if (!existNode) {
														treeNode = new Ext.tree.TreeNode(
																{
																	text : ids[i],
																	checked : false,
																	iconCls : 'node-treenode',
																	isType : true
																});
														cmnenvTree.getRootNode().appendChild(treeNode);
													}
												}
												cmnenvTree.expandAll();
											}
										}
									});

							this.treeLoader.on('beforeload', function(loader,node) {
								//使用查询条件系统代码文本框时用								loader.baseParams.appsysCode = Ext.getCmp("envappsys_Code").getValue();
								loader.baseParams.environmentCode = Ext.getCmp("environmentCode").getValue();
							}, this);
							// 定义树形组件
							cmnenvTree = new Ext.tree.TreePanel(
									{
										id : 'ServersDistributionTree_aa',
										xtype : 'treepanel',
										border : false,
										split : true,
										autoScroll : true,
										root : new Ext.tree.AsyncTreeNode(
												{
													text : '<fmt:message key="property.serversdistribution" />',
													draggable : false,
													iconCls : 'node-root',
													id : 'TREE_ROOT_NODE'
												}),
										loader : this.treeLoader,
										// 定义树形组件监听事件
										listeners : {
											scope : this,
											load : function(n) {
												cmnenvTree.expandAll();
											}/* ,
											'checkchange' : function(node,checked) {
												if (node.parentNode != null) {
													node.cascade(function(node) {
																node.attributes.checked = checked;
																node.ui.checkbox.checked = checked;
															});
													var pNode = node.parentNode;
													if (pNode == cmnenvTree.getRootNode())
														return;
													if (checked) {
														var cb = pNode.ui.checkbox;
														if (cb) {
															cb.checked = checked;
															cb.defaultChecked = checked;
														}
														pNode.attributes.checked = checked;
													} else {
														var _miss = false;
														for ( var i = 0; i < pNode.childNodes.length; i++) {
															if (pNode.childNodes[i].attributes.checked != checked) {
																_miss = true;
															}
														}
														if (!_miss) {
															pNode.ui.toggleCheck(checked);
															pNode.attributes.checked = checked;
														}
													}
												}
											}*/
										} 
									});

							//参数数据源							ParamgridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/cmnenvironment/findGroup',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'appsysCode', 'serverGroup',
												'environmentCode', 'serverUse',
												'shareStoreFlag', 'floatIp' ],
										pruneModifiedRecords : true,
										remoteSort : true,
										sortInfo : {
											field : 'serverGroup',
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											appsysCode : 'appsysCode',
											limit : 30
										}
									});
							// 实例化参数数据列表组件							cmnenvgroup = new Ext.grid.ColumnModel([
											new Ext.grid.RowNumberer(),
											csm2,
											{
												header : '<fmt:message key="property.groupname" />',
												dataIndex : 'value',
												name : 'serverGroup',
												id : 'serverGroup',
												hiddenName : 'serverGroup',
												renderer : this.groupNames,
												sortable : true,
												width : 100
											},
											{
												header : '<fmt:message key="property.serverUse" />',
												dataIndex : 'serverUse',
												name : 'serverUse',
												id : 'createServerUseId',
												renderer : this.serverUse,
												editor : new Ext.grid.GridEditor(
														new Ext.form.ComboBox(
																{
																	typeAhead : true,
																	triggerAction : 'all',
																	hiddenName : 'serverUse',
																	mode : 'local',
																	store : serverUseStore,
																	displayField : 'name',
																	valueField : 'value',
																	editable : true,
																	allowBlank : false
																})),
												sortable : true,
												hidden : false,
												width : 100
											},
											{
												header : '<fmt:message key="property.shareStoreFlag" />',
												dataIndex : 'shareStoreFlag',
												name : 'shareStoreFlag',
												id : 'createShareStoreFlagId',
												renderer : this.shareFlag,
												editor : new Ext.grid.GridEditor(
														new Ext.form.ComboBox(
																{
																	typeAhead : true,
																	triggerAction : 'all',
																	hiddenName : 'shareStoreFlag',
																	mode : 'local',
																	store : shareStoreFlagStore,
																	displayField : 'name',
																	valueField : 'value',
																	editable : true,
																	allowBlank : false
																})),
												sortable : true,
												hidden : false,
												width : 100
											},
											{
												header : '<fmt:message key="property.floatIp" />',
												dataIndex : 'floatIp',
												name : 'floatIp',
												id : 'CreateFloatIpId',
												editor : new Ext.grid.GridEditor(new Ext.form.TextField({})),
												sortable : true,
												hidden : false,
												width : 100
											} ]);

							cmnenvParamGrid = new Ext.grid.EditorGridPanel(
									{
										id : 'envParamPanel',
										region : 'center',
										border : false,
										height : 675,
										width : 1060,
										loadMask : true,
										title : '<fmt:message key="property.serverGroup" />',
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										store : cmnenvGroupStore,
										sm : csm2,
										cm : cmnenvgroup,
										bbar : new Ext.PagingToolbar({
											store : cmnenvGroupStore,
											displayInfo : true,
											pageSize : 20
										}),
										// 定义数据列表监听事件
										listeners : {
											scope : this,
											'cellclick' : function(grid,rowIndex, columnIndex, e) {
												ids = [];
												if (cmnenvParamGrid.getSelectionModel().getCount() > 0) {
													var records = cmnenvParamGrid.getSelectionModel().getSelections();
													for ( var i = 0; i < records.length; i++) {
														ids[i] = records[i].get('name');
													}
												}
											}
										}
									});
							//定义中间移入移出按钮
							cmnenvPanel = new Ext.Panel(
									{
										id : 'ServersDistributionFindPanel_aa',
										region : 'center',
										labelAlign : 'right',
										labelWidth : 100,
										buttonAlign : 'center',
										height : 640,
										frame : true,
										split : true,
										autoScroll : true,
										border : false,
										xtype : 'button',
										layout : {
											type : 'vbox',
											padding : '5',
											pack : 'center',
											align : 'center'
										},
										items : [
												{
													xtype : 'button',
													text : '<fmt:message key="button.moveIn" />',
													scope : this,
													handler : this.ShiftIn
												},
												{
													xtype : 'button',
													text : '<fmt:message key="button.moveOut" />  ',
													scope : this,
													handler : this.ShiftOut
												} ]
									});
							//定义grid查询表单
							cmnenvGridform = new Ext.Panel(
									{
										id : 'ServersDistributionFindgridFormPanel_aa3',
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
														id : 'inputip',
														name : 'serverIp'
													},
													{
														xtype : 'button',
														text : '<fmt:message key="button.ok" />',
														scope : this,
														iconCls : 'button-ok',
														handler : this.doFind
													} ]
										} ]
									});
							// 实例化数据列表组件							cmnenvGrid = new Ext.grid.GridPanel(
							{
								id : 'ServersDistributionListGridPanel_aa',
								border : false,
								loadMask : true,
								height : 605,
								autoWidth : true,
								title : '<fmt:message key="title.list" />',
								columnLines : true,
								viewConfig : {
									forceFit : true
								},
								store : this.gridStore,
								sm : csm,
								columns : [new Ext.grid.RowNumberer(),csm,{
									header : '<fmt:message key="property.serverIp" />',
									dataIndex : 'serverIp',
									sortable : true
								}],
								// 定义分页工具条								bbar : new Ext.PagingToolbar({
									store : this.gridStore,
									displayInfo : true,
									pageSize : 50
								})
							});
							this.firstPanel = new Ext.Panel(
									{
										title : '<fmt:message key="title.env" />',
										items : [ {
											layout : 'form',
											defaults : {
												anchor : '70%'
											},
											border : false,
											labelAlign : 'center',
											items : [
													{
														xtype : 'combo',
														store : this.envsysIdsStore,
														fieldLabel : '<fmt:message key="property.appsysCode" />',
														id : 'envappsys_Code',
														name : 'appsysCode',
														displayField : 'appsysName',
														valueField : 'appsysCode',
														hiddenName : 'appsysCode',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : true,
														maxLength : 50,
														tabIndex : this.tabIndex++,
														allowBlank : false,
														typeAhead : true,
														listeners : {
															scope : this,
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
															},
															select : function(combo,record,index) {
																ParamgridStore.baseParams.appsysCode = combo.value;
																this.gridStore.baseParams.appsysCode = combo.value;
																var environmentCode = Ext.getCmp('environmentCode');//环境编号
																var environmentType = Ext.getCmp('environment_Type').getValue();
																if (environmentType != '') {
																	environmentCode.setValue(appsysCode + '_'+combo.value+ '_' + 'ENV');
																	ParamgridStore.baseParams.environmentCode = Ext.getCmp('environmentCode').getValue();
																	ParamgridStore.reload();
																	Ext.apply(this.treeLoader.baseParams,{
																						appsysCode : Ext.getCmp('envappsys_Code').getValue(),
																						environmentCode : Ext.getCmp('environment_Type').getValue()
																					});
																}
															}
														}
													},
													{
														xtype : 'combo',
														store : this.environmentTypeStore,
														fieldLabel : "<fmt:message key="property.environmentType" />",
														id : 'environment_Type',
														name : 'environmentType',
														valueField : 'ENV',
														displayField : 'NAME',
														hiddenName : 'environmentType',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														tabIndex : this.tabIndex++,
														listeners : {
															scope : this,
															select : function(
																	combo,
																	record,
																	index) {
																var environmentCode = Ext.getCmp('environmentCode');//环境编号
																environmentCode.setValue('');
																var appsysCode = Ext.getCmp('envappsys_Code').getValue();//应用系统
																if (appsysCode != '') {
																	environmentCode.setValue(appsysCode + '_'+combo.value+ '_' + 'ENV');
																	ParamgridStore.baseParams.environmentCode = Ext.getCmp('environmentCode').getValue();
																	ParamgridStore.reload();
																	Ext.apply(this.treeLoader.baseParams,{
																						appsysCode : Ext.getCmp('envappsys_Code').getValue(),
																						environmentCode : Ext.getCmp('environment_Type').getValue()
																					});
																}
															}
														}
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.environmentCode" />',
														id : 'environmentCode',
														name : 'environmentCode',
														maxLength : 200,
														tabIndex : this.tabIndex++,
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.environmentName" />',
														id : 'environmentName',
														name : 'environmentName',
														maxLength : 200,
														tabIndex : this.tabIndex++
													},

													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.describe" />',
														name : 'describe',
														maxLength : 200,
														height : 120,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														id : 'groupValueId',
														name : 'groupValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'serverValueId',
														name : 'serverValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'ValueId',
														name : 'Value',
														tabIndex : this.tabIndex++,
														hidden : true
													} ]
										} ]

									});
							this.secondPanel = new Ext.Panel(
									{
										items : [ cmnenvParamGrid ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												ids = [];
												var records = cmnenvParamGrid.getSelectionModel().getSelections();
												for ( var i = 0; i < records.length; i++) {
													ids[i] = records[i].get('name');
												}
											}
										}
									});
							this.threePanel = new Ext.Panel(
									{
										items : [ {
											title : '<fmt:message key="title.server" />',
											layout : 'form',
											height : 700,
											autoScroll : true,
											labelAlign : 'right',
											border : false,
											items : [ {
												layout : 'column',
												items : [
														{
															columnWidth : .45,
															labelAlign : 'right',
															border : false,
															items : [
																	cmnenvGridform,
																	cmnenvGrid ]
														},
														{
															columnWidth : .1,
															border : false,
															labelAlign : 'right',
															items : [ cmnenvPanel ]
														},
														{
															columnWidth : .45,
															border : false,
															labelAlign : 'right',
															items : [ cmnenvTree ]
														} ]
											} ]
										} ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												cmnenvTree.getRootNode().reload();
												//this.gridStore.baseParams.appsysCode = Ext.getCmp('envappsys_Code');
												this.gridStore.reload();
											}
										}
									});
							var i = 0;
							function cardHandler(direction) {
								if (direction == -1) {
									i--;
									if (i < 0) {
										i = 0;
									}
								}
								if (direction == 1) {
									i++;
									if (i > 2) {
										i = 2;
										return false;
									}
								}
								var btnNext = Ext.getCmp("cerate-move-next");
								var btnPrev = Ext.getCmp("cerate-move-prev");
								var btnSave = Ext.getCmp("cerate-move-save");
								if (i == 0) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.disable();
								}
								if (i == 1) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.enable();
									if (Ext.getCmp('envappsys_Code').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.appSysCodeNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
									if (Ext.getCmp('environment_Type').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.environmentTypeNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
								}
								if (i == 2) {
									var records = cmnenvParamGrid.getSelectionModel().getSelections();
									if (records == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.serverGroupNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 1;
									}

									var m = cmnenvParamGrid.getSelectionModel().getSelections();
									for ( var j = 0; j < m.length; j++) {
										var record = m[j];
										var floatIp = record.get('floatIp');
										var shareStoreFlag = record.get('shareStoreFlag');
										var serverUse = record.get('serverUse');
										if (Ext.getCmp('environment_Type').getValue() == 4) {
											if (serverUse == null || serverUse == "") {
												Ext.Msg.show({
															title : '<fmt:message key="message.title" />',
															msg : '<fmt:message key="message.serverUseNotNull" />',
															buttons : Ext.MessageBox.OK,
															icon : Ext.MessageBox.INFO,
															minWidth : 200
														});
												return i = 1;
											}
											if (shareStoreFlag == null || shareStoreFlag == "") {
												Ext.Msg.show({
															title : '<fmt:message key="message.title" />',
															msg : '<fmt:message key="message.shareStoreFlagNotNull" />',
															buttons : Ext.MessageBox.OK,
															icon : Ext.MessageBox.INFO,
															minWidth : 200
														});
												return i = 1;
											}
											if (serverUse == 1 && floatIp == null || floatIp == "") {
												Ext.Msg.show({
															title : '<fmt:message key="message.title" />',
															msg : '<fmt:message key="message.floatIpNotNull" />',
															buttons : Ext.MessageBox.OK,
															icon : Ext.MessageBox.INFO,
															minWidth : 200
														});
												return i = 1;
											}
											if (serverUse == 2 && floatIp == null || floatIp == "") {
												Ext.Msg.show({
															title : '<fmt:message key="message.title" />',
															msg : '<fmt:message key="message.floatIpNotNull" />',
															buttons : Ext.MessageBox.OK,
															icon : Ext.MessageBox.INFO,
															minWidth : 200
														});
												return i = 1;
											}
										}
									}
									btnSave.show();
									btnNext.disable();
									btnPrev.enable();
								}
								this.cardPanel.getLayout().setActiveItem(i);
							};
							//CARD总面板  
							this.cardPanel = new Ext.Panel(
									{
										renderTo : document.body,
										height : 700,
										width : 700,
										layout : 'card',
										layoutConfig : {
											deferredRender : true
										},
										activeItem : 0,
										tbar : ['-',
												{
													id : 'cerate-move-prev',
													iconCls : 'button-previous',
													text : '<fmt:message key="button.previous" />',
													handler : cardHandler.createDelegate(this,[ -1 ])
												},
												'-',
												{
													id : 'cerate-move-save',
													iconCls : 'button-save',
													text : '<fmt:message key="button.save" />',
													hidden : true,
													handler : this.doSave
												},
												'-',
												{
													id : 'cerate-move-next',
													iconCls : 'button-next',
													text : '<fmt:message key="button.next" />',
													handler : cardHandler
															.createDelegate(
																	this, [ 1 ])
												} ],
										items : [ this.firstPanel,
												this.secondPanel,
												this.threePanel ]
									});
							// 设置基类属性							EnvCreateForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/cmnenvironment/create',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.cardPanel ]
											});
						},
						//移入事件
						ShiftIn : function() {
							var Nodes = cmnenvTree.getChecked();
							if (cmnenvGrid.getSelectionModel().getCount()>0 && Nodes!=null && Nodes.length==1 && Nodes[0]!=cmnenvTree.getRootNode()) {
								var records = cmnenvGrid.getSelectionModel().getSelections();
								var snode = Nodes[0];
								if(snode.text.indexOf('.')==-1){
									for ( var i = 0; i < records.length; i++) {
										var exists = false;
										snode.eachChild(function(node) {
											if (records[i].get('serverIp') == node.text) {
												exists = true;
												return false;
											}
										});
										if (!exists) {
											snode.leaf = false,
											snode.appendChild(new Ext.tree.TreeNode(
											{
												iconCls : 'node-treenode',
												checked : false,
												text : records[i].get('serverIp')
											}));
										}
									}
								}
								cmnenvTree.expandAll();
							} else {
								Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.select.one.at.least" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
							}
						},
						//移出事件
						ShiftOut : function() {
							var Node = cmnenvTree.getSelectionModel().getSelectedNode();
							var node = cmnenvTree.getChecked();
							if (node != null) {
								Ext.each(node, function(item) {
									if (!item.attributes.isType) {
										item.remove();
									}
								});
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.at.least" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						},
						// 保存操作
						doSave : function() {
							var root = cmnenvTree.getRootNode();
							var json = new Array();
							root.cascade(function(n) {
								if (n.attributes.isType) {
									n.eachChild(function(item) {
									var index = cmnenvGroupStore.find('name', n.text);
									json.push(item.text + '|+|' + cmnenvGroupStore.getAt(index).get('value'));
									});
								}
							});
							if(json==''){
								Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.ServerIpIsNull" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});	
								return false;
							}
							Ext.getCmp('serverValueId').setValue(Ext.util.JSON.encode(json));
							//分组信息  envappsys_Code
							var serverGroup = '';
							var serverUse = '';
							var shareStoreFlag = '';
							var floatIp = '';
							var jsonServer = [];
							var records = cmnenvParamGrid.getSelectionModel().getSelections();
							for ( var i = 0; i < records.length; i++) {
								var index = cmnenvGroupStore.find('name', records[i].get('name'));
								serverGroup =cmnenvGroupStore.getAt(index).get('value');
								serverUse = records[i].get('serverUse');
								shareStoreFlag = records[i].get('shareStoreFlag');
								floatIp = records[i].get('floatIp');
								if (serverUse == null) {serverUse = " "};
								if (shareStoreFlag == null) {shareStoreFlag = " "};
								if (floatIp == null) {floatIp = " "};
								jsonServer.push(serverGroup + "|+|" + serverUse + "|+|" + shareStoreFlag + "|+|" + floatIp);
							}
							Ext.getCmp('groupValueId').setValue(Ext.util.JSON.encode(jsonServer));
							envCreateForm.getForm().submit(
											{
												scope : envCreateForm,
												success : envCreateForm.saveSuccess,
												failure : envCreateForm.saveFailure,
												waitTitle : '<fmt:message key="message.wait" />',
												waitMsg : '<fmt:message key="message.saving" />'
											});
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('add_CmnEnvironment');
						},
						// Grid查询事件
						doFind : function() {
							Ext.apply(this.gridStore.baseParams, {
								serverIp : Ext.getCmp('inputip').getValue()
							});
							Ext.apply(this.gridStore.baseParams, {
								appsysCode : Ext.getCmp('envappsys_Code').getValue()
							});
							cmnenvGrid.getStore().load();
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
											app.closeTab('add_CmnEnvironment');
											var list = Ext.getCmp(
													"CmnEnvironment").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab(
															'CmnEnvironment',
															'<fmt:message key="button.view" /><fmt:message key="function" />',
															'${ctx}/${managePath}/cmnenvironment/index');
										}
									});
						},
						// 保存失败回调
						saveFailure : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						},
						// 删除事件
						doDelete : function() {
							if (cmnenvParamGrid.getSelectionModel().getCount() > 0) {
								var records = cmnenvParamGrid.getSelectionModel().getSelections();
								var groupValue;
								var group;
								for ( var i = 0; i < records.length; i++) {
									Ext.getCmp('envParamPanel').store.remove(records[i]);
									groupValue = records[i].get('serverGroup');
									group = this.group_one(groupValue);
									Ext.each(cmnenvTree.getRootNode().childNodes,
													function(node) {
														if (node.text == group) {
															node.remove();
														}
													});
								}
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.at.least" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						},
						// 删除成功回调方法
						deleteSuccess : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});

							} else if (Ext.decode(response.responseText).success == true) {
								cmnenvGrid.getStore().reload();// 重新加载数据源								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.successful" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO
										});
							}
							this.ParamgridStore.reload();
						},
						//键值对
						serverUse : function(value) {
							var index = serverUseStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return serverUseStore.getAt(index).get('name');
							}
						},
						shareFlag : function(value) {
							var index = shareStoreFlagStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return shareStoreFlagStore.getAt(index).get('name');
							}
						},
						group_one : function(value) {
							var index = envcodeInfoStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return envcodeInfoStore.getAt(index).get('name');
							}
						},
						groupNames : function(value) {
							var index = cmnenvGroupStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return cmnenvGroupStore.getAt(index).get('name');
							}
						},
						// 删除失败回调方法
						deleteFailure : function() {
							app.mask.hide();
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.delete.failed" />',
										minWidth : 200,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});
	var envCreateForm = new EnvCreateForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_CmnEnvironment").add(envCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("add_CmnEnvironment").doLayout();
</script>
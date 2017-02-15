<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//组件列表字段信息
	/* var fieldsServer = Ext.data.Record.create([
	 {name: 'appsysCode', mapping : 'appsysCode', type : 'string'}, 
	 {name: 'serverGroup', mapping : 'serverGroup', type : 'string'},
	 ]); */
	//定义新建表单
	var tc = null;
	var ac = null;
	var sg = null;
	var pc = null;
	var edittreeNode = null;
	var editids = new Array();
	var groupName = null;
	var cmnenveditTree = null;
	var cmnenveditParamGrid = null;
	var cmneditGrid = null;
	var cmneditGridForm = null;
	var cmneditPanel = null;
	var serverchild = null;
	var paramgridStore;
	var editenvcodeInfoStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});

	var editserverUseStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/APP_PATTERN/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	editserverUseStore.load();
	var editshareStoreFlagStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/SHARE_STORE_FLAG/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	editshareStoreFlagStore.load();
	EditEnvForm = Ext.extend(Ext.FormPanel,
			{
						gridform : null,
						gridStoreEdit : null,// 数据列表数据源
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
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止
							Ext.getDoc().on('keydown',function(e) {
												if (e.getKey() == 8 && e.getTarget().type == 'text' && !e.getTarget().readOnly) {
												} else if (e.getKey() == 8 && e.getTarget().type == 'textarea' && !e.getTarget().readOnly) {
												} else if (e.getKey() == 8 && e.getTarget().type == 'combo' && !e.getTarget().readOnly) {
												} else if (e.getKey() == 8) {
													e.preventDefault();
												}
											});
							csmServer = new Ext.grid.CheckboxSelectionModel();
							// 实例化数据列表数据源
							this.gridStoreEdit = new Ext.data.JsonStore(
									{
										id : '------',
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
							this.editenvsysIdsStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
													method : 'GET',
													disableCaching : true
												}),
										reader : new Ext.data.JsonReader({}, ['appsysCode', 'appsysName' ])
									});
							this.editenvsysIdsStore.load();
							editenvcodeInfoStore.load();
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
							csm = new Ext.grid.CheckboxSelectionModel({
								handleMouseDown : Ext.emptyFn
							});
							csm2 = new Ext.grid.CheckboxSelectionModel({
								handleMouseDown : Ext.emptyFn
							});
							// 实例化树形功能菜单

							this.treeLoader = new Ext.tree.TreeLoader(
									{
										requestMethod : 'POST',
										dataUrl : '${ctx}/${managePath}/cmnenvironment/queryTree',
										baseParams : {
											appsysCode : '',
											environmentCode : ''
										},
										listeners : {
											scope : this,
											load : function(tree, node) {
												var records = cmnenveditParamGrid.getSelectionModel().getSelections();
												groupName = new Array();
												for ( var i = 0; i < records.length; i++) {
													var s = this.group_one(records[i].get('serverGroup'));
													groupName.push(s);
												}
												if (groupName == '') {
													cmnenveditTree.getRootNode().removeAll();
												}
												var equalFlag = false;
												var delTreeNode = [];
												for ( var i = 0; i < cmnenveditTree.getRootNode().childNodes.length; i++) {
													equalFlag = false;
													for ( var j = 0; j < groupName.length; j++) {
														if (cmnenveditTree.getRootNode().childNodes[i].text == groupName[j]) {
															equalFlag = true;
														}
													}
													if (!equalFlag) {
														cmnenveditTree.getRootNode().childNodes[i].cascade(function(_node) {
																	cmnenveditTree.getRootNode().childNodes[i].removeChild(_node);
																});
														delTreeNode.push(cmnenveditTree.getRootNode().childNodes[i]);
													}
												}
												Ext.each(delTreeNode, function(delNode) {
													cmnenveditTree.getRootNode().removeChild(delNode);
												});
												for ( var i = 0; i < editids.length; i++) {
													var existNode = cmnenveditTree.getRootNode().findChild('text',editids[i]);
													if (!existNode) {
														edittreeNode = new Ext.tree.TreeNode(
																{
																	text : editids[i],
																	checked : false,
																	iconCls : 'node-treenode',
																	isType : true
																});
														cmnenveditTree.getRootNode().appendChild(edittreeNode);
													}
												}
												cmnenveditTree.expandAll();
											}
										}
									});
							this.treeLoader.on('beforeload', function(loader,node) {
								//使用查询条件系统代码文本框时用
								loader.baseParams.appsysCode = Ext.getCmp("appsys_Code1").getValue();
								loader.baseParams.environmentCode = Ext.getCmp("environmentCode1").getValue();
							}, this);
							// 定义树形组件
							cmnenveditTree = new Ext.tree.TreePanel(
									{
										id : 'ServersDistributionTree_aa1',
										xtype : 'treepanel',
										border : false,
										split : true,
										autoScroll : true,
										root : new Ext.tree.AsyncTreeNode(
												{
													text : '<fmt:message key="property.serversdistribution" />',
													draggable : false,
													iconCls : 'node-root',
													id : 'TREE_ROOT_NODE1'
												}),
										tools : [ {
											id : 'refresh',
											scope : this,
											handler : function() {
												var selectedNodePath = null;
												if (cmnenveditTree.getSelectionModel().getSelectedNode() != null) {
													selectedNodePath = cmnenveditTree.getSelectionModel().getSelectedNode().getPath();
												}
												cmnenveditTree.root.reload();
												cmnenveditTree.expandAll();
												if (selectedNodePath != null) {
													cmnenveditTree.selectPath(selectedNodePath);
												}
											}
										} ],
										loader : this.treeLoader,
										// 定义树形组件监听事件
										listeners : {
											scope : this,
											load : function(n) {
												cmnenveditTree.expandAll();
											}/* ,
											'checkchange' : function(node,checked) {
												if (node.parentNode != null) {
													node.cascade(function(node) {
																node.attributes.checked = checked;
																node.ui.checkbox.checked = checked;
															});
													var pNode = node.parentNode;
													if (pNode == cmnenveditTree.getRootNode())
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
											} */
										}
									});
							//参数数据源
							paramgridStore = new Ext.data.JsonStore(
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
												'shareStoreFlag', 'floatIp',
												'checked' ],
										pruneModifiedRecords : true,
										remoteSort : true,
										sortInfo : {
											field : 'serverGroup',
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											appsysCode : 'appsysCode',
											environmentCode : 'environmentCode',
											limit : 30
										}
									});
							// 默认选中数据
							paramgridStore.on('load', function(store) {
								var records = store.query('checked', true).getRange();
								cmnenveditParamGrid.getSelectionModel().selectRecords(records, false);
							}, this, {
								delay : 100
							});
							// 加载列表数据
							paramgridStore.load();
							// 实例化参数数据列表组件
							editcmnenvgroup = new Ext.grid.ColumnModel(
									[
											new Ext.grid.RowNumberer(),
											csm2,
											{
												header : '<fmt:message key="property.groupname" />',
												dataIndex : 'serverGroup',
												name : 'serverGroup',
												hiddenName : 'serverGroup',
												sortable : true,
												width : 100
											},
											{
												header : '<fmt:message key="property.serverUse" />',
												dataIndex : 'serverUse',
												name : 'serverUse',
												renderer : this.serverUse,
												editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
																	typeAhead : true,
																	triggerAction : 'all',
																	hiddenName : 'serverUse',
																	mode : 'local',
																	store : editserverUseStore,
																	displayField : 'name',
																	valueField : 'value',
																	editable : true,
																	allowBlank : true
																})),
												sortable : true,
												hidden : false,
												width : 100
											},
											{
												header : '<fmt:message key="property.shareStoreFlag" />',
												dataIndex : 'shareStoreFlag',
												name : 'shareStoreFlag',
												renderer : this.shareFlag,
												editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
																	typeAhead : true,
																	triggerAction : 'all',
																	hiddenName : 'shareStoreFlag',
																	mode : 'local',
																	store : editshareStoreFlagStore,
																	displayField : 'name',
																	valueField : 'value',
																	editable : true,
																	allowBlank : true
																})),
												sortable : true,
												hidden : false,
												width : 100
											},
											{
												header : '<fmt:message key="property.floatIp" />',
												dataIndex : 'floatIp',
												name : 'floatIp',
												editor : new Ext.grid.GridEditor(new Ext.form.TextField({})),
												sortable : true,
												hidden : false,
												width : 100
											} ]);
							cmnenveditParamGrid = new Ext.grid.EditorGridPanel({
										id : 'editEnvParamPanel',
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
										store : paramgridStore,
										sm : csm2,
										cm : editcmnenvgroup,
										bbar : new Ext.PagingToolbar({
											store : paramgridStore,
											displayInfo : true,
											pageSize : 20
										}),
										// 定义数据列表监听事件
										listeners : {
											scope : this,
											'cellclick' : function(grid,
													rowIndex, columnIndex, e) {
												editids = [];
												if (cmnenveditParamGrid.getSelectionModel().getCount() > 0) {
													var records = cmnenveditParamGrid.getSelectionModel().getSelections();
													for ( var i = 0; i < records.length; i++) {
														editids[i] = this.group_one(records[i].get('serverGroup'));
													}
												}
											}
										}
									});
							//定义中间移入移出按钮
							cmneditPanel = new Ext.Panel({
										id : 'ServersDistributionFindPanel_aa1',
										region : 'center',
										labelAlign : 'right',
										labelWidth : 100,
										buttonAlign : 'center',
										height : 640,
										frame : true,
										split : true,
										border : false,
										autoScroll : true,
										xtype : 'button',
										layout : {
											type : 'vbox',
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
													text : '<fmt:message key="button.moveOut" />',
													scope : this,
													handler : this.ShiftOut
												} ]
									});
							//定义grid查询表单
							cmneditGridForm = new Ext.Panel({
										id : 'ServersDistributionFindgridFormPanel_aa1',
										buttonAlign : 'center',
										frame : true,
										autoScroll : false,
										labelAlign : 'center',
										labelWidth : 100,
										height : 30,
										defaults : {
											anchor : '75%',
											msgTarget : 'side'
										},
										layout : 'form',
										// 定义查询表单组件
										items : [{
											layout : 'column',
											fieldLabel : '<fmt:message key="property.serverIp" />',
											items : [{
														xtype : 'textfield',
														id : 'inputip1',
														name : 'serverIp'
													},
													{
														xtype : 'button',
														text : '<fmt:message key="button.ok" />',
														scope : this,
														iconCls : 'button-ok',
														handler : this.doFind
													}]
										}]
									});
							// 实例化数据列表组件							cmneditGrid = new Ext.grid.GridPanel({
										id : 'ServersDistributionListGridPanel_oo',
										height : 610,
										width : 475,
										autoWidth : true,
										border : false,
										loadMask : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										store : this.gridStoreEdit,
										sm : csm,
										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												{
													header : '<fmt:message key="property.serverIp" />',
													dataIndex : 'serverIp',
													sortable : true
												} ],
										bbar : new Ext.PagingToolbar({
											store : this.gridStoreEdit,
											displayInfo : true,
											pageSize : 20
										})
									});

							this.firstPanel = new Ext.Panel({
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
														store : this.editenvsysIdsStore,
														fieldLabel : '<fmt:message key="property.appsysCode" />',
														id : 'appsys_Code1',
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
														readOnly : true,
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
																paramgridStore.baseParams.appsysCode = combo.value;
																this.gridStoreEdit.baseParams.appsysCode = combo.value;
																paramgridStore.reload();
																var environmentCode = Ext.getCmp('environmentCode1');//环境编号
																environmentCode.setValue('');
																var environmentType = Ext.getCmp('environment_Type1').getValue();//环境类型
																if (environmentType != '') {
																	switch (environmentType) {
																	case '1':
																		environmentCode.setValue(combo.value + '_DEV' + '_' + 'ENV');
																		break;
																	case '2':
																		environmentCode.setValue(combo.value + '_QA' + '_' + 'ENV');
																		break;
																	case '3':
																		environmentCode.setValue(combo.value + '_PROV' + '_' + 'ENV');
																		break;
																	case '4':
																		environmentCode.setValue(combo.value + '_PROD' + '_' + 'ENV');
																		break;
																	}
																}
															}
														}
													},
													{
														xtype : 'combo',
														store : this.environmentTypeStore,
														fieldLabel : "<fmt:message key="property.environmentType" />",
														id : 'environment_Type1',
														name : 'environmentType',
														valueField : 'ENV',
														displayField : 'NAME',
														hiddenName : 'environmentType',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														readOnly : true,
														tabIndex : this.tabIndex++,
														listeners : {
															select : function(combo,record,index) {
																var environmentCode = Ext.getCmp('environmentCode1');//环境编号
																environmentCode.setValue('');
																var appsysCode = Ext.getCmp('appsys_Code1').getValue();//应用系统
																if (appsysCode != '') {
																	switch (combo.value) {
																	case '1':
																		environmentCode.setValue(appsysCode + '_DEV' + '_' + 'ENV');
																		break;
																	case '2':
																		environmentCode.setValue(appsysCode + '_QA' + '_' + 'ENV');
																		break;
																	case '3':
																		environmentCode.setValue(appsysCode + '_PROV' + '_' + 'ENV');
																		break;
																	case '4':
																		environmentCode.setValue(appsysCode + '_PROD' + '_' + 'ENV');
																		break;
																	}
																}
															}
														}
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.environmentCode" />',
														id : 'environmentCode1',
														name : 'environmentCode',
														maxLength : 200,
														tabIndex : this.tabIndex++,
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.environmentName" />',
														id : 'environmentName1',
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
														id : 'groupValueId1',
														name : 'groupValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'serverValueId1',
														name : 'serverValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'ValueId1',
														name : 'Value',
														tabIndex : this.tabIndex++,
														hidden : true
													} ]
										} ]
									});
							this.secondPanel = new Ext.Panel({
										items : [ cmnenveditParamGrid ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												editids = [];
												var records = cmnenveditParamGrid.getSelectionModel().getSelections();
												for ( var i = 0; i < records.length; i++) {
													editids[i] = this.group_one(records[i].get('serverGroup'));
												}
											}
										}
									});
							this.threePanel = new Ext.Panel({
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
															border : false,
															labelAlign : 'right',
															items : [cmneditGridForm,
																	cmneditGrid ]
														},
														{
															columnWidth : .1,
															border : false,
															labelAlign : 'right',
															items : [ cmneditPanel ]
														},
														{
															columnWidth : .45,
															border : false,
															labelAlign : 'right',
															items : [ cmnenveditTree ]
														} ]
											} ]
										} ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												cmnenveditTree.getRootNode().reload();
												this.gridStoreEdit.reload();
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
								var btnNext = Ext.getCmp("move-next");
								var btnPrev = Ext.getCmp("move-prev");
								var btnSave = Ext.getCmp("move-save");
								if (i == 0) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.disable();
								}
								if (i == 1) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.enable();
								}
								if (i == 2) {
									var records = cmnenveditParamGrid.getSelectionModel().getSelections();
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
									var m = cmnenveditParamGrid.getSelectionModel().getSelections();
									for ( var j = 0; j < m.length; j++) {
										var record = m[j];
										var floatIp = record.get('floatIp');
										var shareStoreFlag = record.get('shareStoreFlag');
										var serverUse = record.get('serverUse');
										if (Ext.getCmp('environment_Type1').getValue() == 4) {
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
											deferredRender : false,
											renderHidden : true
										},
										activeItem : 0,
										tbar : ['-',
												{
													id : 'move-prev',
													iconCls : 'button-previous',
													text : '<fmt:message key="button.previous" />',
													handler : cardHandler.createDelegate(this,[ -1 ])
												},
												'-',
												{
													id : 'move-save',
													text : '<fmt:message key="button.save" />',
													iconCls : 'button-save',
													hidden : true,
													handler : this.doSave
												},
												'-',
												{
													id : 'move-next',
													iconCls : 'button-next',
													text : '<fmt:message key="button.next" />',
													handler : cardHandler.createDelegate(this, [ 1 ])
												} ],
										items : [ this.firstPanel,
												this.secondPanel,
												this.threePanel ]
									});
							// 设置基类属性

							EditEnvForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/cmnenvironment/edit/${param.appsysCode}/${param.environmentCode}',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.cardPanel ]
											});
							// 加载表单数据
							this.form.load({
										url : '${ctx}/${managePath}/cmnenvironment/findEnv/${param.appsysCode}/${param.environmentCode}',
										method : 'GET',
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.loading" />',
										scope : this,
										success : this.loadSuccess,
										failure : this.loadFailure
									});
						},
						loadSuccess : function(form, action) {
							Ext.apply(paramgridStore.baseParams, {
								appsysCode : Ext.getCmp('appsys_Code1').getValue()
							});
							Ext.apply(paramgridStore.baseParams, {
								environmentCode : Ext.getCmp('environmentCode1').getValue()
							});
							Ext.apply(this.gridStoreEdit.baseParams, {
								appsysCode : Ext.getCmp('appsys_Code1').getValue()
							});
							paramgridStore.reload();
							cmnenveditTree.expandAll();
						},
						//移入事件
						ShiftIn : function() {
							var Nodes = cmnenveditTree.getChecked();
							if (cmneditGrid.getSelectionModel().getCount() > 0 && Nodes != null && Nodes.length == 1 && Nodes[0] != cmnenveditTree.getRootNode()) {
								var records = cmneditGrid.getSelectionModel().getSelections();
								var snode = Nodes[0];
								if (snode.text.indexOf('.') == -1) {
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
								cmnenveditTree.expandAll();
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.at.least" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
							/* 				var Node = cmnenveditTree.getChecked();
											if (cmneditGrid.getSelectionModel().getCount() > 0 && Node != null && Node != cmnenveditTree.getRootNode() && Node.attributes.isType) {
												var records = cmneditGrid.getSelectionModel().getSelections();
												var snode = cmnenveditTree.getSelectionModel().getSelectedNode();
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
												cmnenveditTree.expandAll();
											} else {
												Ext.Msg.show({
															title : '<fmt:message key="message.title" />',
															msg : '<fmt:message key="message.select.one.at.least" />',
															minWidth : 200,
															buttons : Ext.MessageBox.OK,
															icon : Ext.MessageBox.ERROR
														});
											} */
						},
						//移出事件
						ShiftOut : function() {
							var Node = cmnenveditTree.getSelectionModel().getSelectedNode();
							var node = cmnenveditTree.getChecked();
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
							var root = cmnenveditTree.getRootNode();
							var json = new Array();
							root.cascade(function(n) {
								if (n.attributes.isType) {
									n.eachChild(function(item) {
										var index = editenvcodeInfoStore.find('name', n.text);
										json.push(item.text + '|+|' + editenvcodeInfoStore.getAt(index).get('value'));
									});
								}
							});
							if (json == ''||null==json) {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.ServerIpIsNull" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
								return false;
							}
							Ext.getCmp('serverValueId1').setValue(Ext.util.JSON.encode(json));
							//分组信息
							var serverGroup = '';
							var serverUse = '';
							var shareStoreFlag = '';
							var floatIp = '';
							var jsonServer = [];
							var records = cmnenveditParamGrid.getSelectionModel().getSelections();
							for ( var i = 0; i < records.length; i++) {
								var index = editenvcodeInfoStore.find('name',records[i].get('serverGroup'));
								serverGroup = editenvcodeInfoStore.getAt(index).get('value');
								serverUse = records[i].get('serverUse');
								shareStoreFlag = records[i].get('shareStoreFlag');
								floatIp = records[i].get('floatIp');
								if (serverUse == null || serverUse == '') {
									serverUse = " ";
								}
								if (shareStoreFlag == null || shareStoreFlag == '') {
									shareStoreFlag = " ";
								}
								if (floatIp == null || floatIp == '') {
									floatIp = " ";
								}
								jsonServer.push(serverGroup + "|+|" + serverUse + "|+|" + shareStoreFlag + "|+|" + floatIp);
							}
							Ext.getCmp('ValueId1').setValue(Ext.util.JSON.encode(jsonServer));
							editEnvForm.getForm().submit(
											{
												scope : editEnvForm,
												success : editEnvForm.saveSuccess,
												failure : editEnvForm.saveFailure,
												waitTitle : '<fmt:message key="message.wait" />',
												waitMsg : '<fmt:message key="message.saving" />'
											});
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('edit_CmnEnvironment');
						},
						// Grid查询事件
						doFind : function() {
							Ext.apply(this.gridStoreEdit.baseParams, {
								serverIp : Ext.getCmp('inputip1').getValue()
							});
							Ext.apply(this.gridStoreEdit.baseParams, {
								appsysCode : Ext.getCmp('appsys_Code1').getValue()
							});
							cmneditGrid.getStore().load();
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
											app.closeTab('edit_CmnEnvironment');
											var list = Ext.getCmp("CmnEnvironment").get(0);
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
							if (cmnenveditParamGrid.getSelectionModel().getCount() > 0) {
								var records = cmnenveditParamGrid.getSelectionModel().getSelections();
								var groupValue;
								var group;
								for ( var i = 0; i < records.length; i++) {
									Ext.getCmp('editEnvParamPanel').store.remove(records[i]);
									groupValue = records[i].get('serverGroup');
									group = this.group_one(groupValue);
									Ext.each(
													cmnenveditTree.getRootNode().childNodes,
													function(node) {
														if (node.text == group) {
															node.remove();
														}
													});
									cmnenveditTree.expandAll();
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
								cmneditGrid.getStore().reload();// 重新加载数据源
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.successful" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO
										});
							}
							paramgridStore.reload();
						},
						//键值对
						serverUse : function(value) {
							var index = editserverUseStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return editserverUseStore.getAt(index).get('name');
							}
						},
						shareFlag : function(value) {
							var index = editshareStoreFlagStore.find('value',value);
							if (index == -1) {
								return value;
							} else {
								return editshareStoreFlagStore.getAt(index).get('name');
							}
						},
						group_one : function(value) {
							var index = editenvcodeInfoStore.find('value',value);
							if (index == -1) {
								return value;
							} else {
								return editenvcodeInfoStore.getAt(index).get('name');
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
	var editEnvForm = new EditEnvForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("edit_CmnEnvironment").add(editEnvForm);
	// 刷新Tab页布局
	Ext.getCmp("edit_CmnEnvironment").doLayout();
</script>
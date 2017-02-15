<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var nshGroupNameStore;
	var groupGridForm=null;
	var nshGroupStore=null;
	var nfsStore=null;
	var groupParamGrid=null;
	var nshGroup =null;
	NshGroupCreateTestForm = Ext.extend(Ext.FormPanel,
					{
						Panel : null,// 查询表单组件
						tree : null,// 树形组件
						tabIndex : 0,// 查询表单组件Tab键顺序						grid : null,
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
							//查询系统代码
							this.nshJonsysIdsStore = new Ext.data.Store(
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

							this.nshJonsysIdsStore.load();
							this.os_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.os_typeStore.load();
							nshGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							nshGroupStore.load();
							nfsStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/NFS_FLAG/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							nfsStore.load();
							//服务名数据源
							nshGroupNameStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/nshjob/queryjobParentGroup',
													method : 'GET',
													disableCaching : true
												}),
												baseParams : {
													appsysCode : ''
												},
										reader : new Ext.data.JsonReader({}, [ 'groupName' ]),
										listeners : {
											load : function(store) {
												if (store.getCount() == 0) {
													Ext.Msg.show({
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="message.system.no.jobParentGroup" />',
																minWidth : 200,
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.WARNING
															});
												}
											}
										}
									});
							csm3 = new Ext.grid.CheckboxSelectionModel();
							
							  nshGroup = new Ext.grid.ColumnModel(
										[
												new Ext.grid.RowNumberer(),
												csm3,
												{
													header : '<fmt:message key="property.groupname" />',
													dataIndex : 'groupName',
													name : 'groupName',
													id : 'groupNameId',
													displayField : 'groupName',
													valueField : 'groupName',
													hiddenName : 'groupName',
													editor : new Ext.grid.GridEditor(
				          									new Ext.form.TextField({allowBlank:false})
				  									),
													sortable : true,
													width : 60
												},
												{
													header : '<fmt:message key="propertyGroup.serverGroup" />',
													dataIndex : 'serverGroup',
													name : 'serverGroup',
													editor : new Ext.grid.GridEditor(
															new Ext.form.ComboBox(
																	{
																		typeAhead : true,
																		triggerAction : 'all',
																		hiddenName : 'serverGroup',
																		mode : 'local',
																		store : nshGroupStore,
																		displayField : 'name',
																		valueField : 'name',
																		editable : false,
																		allowBlank : false
																	})),
													sortable : true,
													hidden : false,
													width : 60
												},{
													header : '操作系统类型',
													dataIndex : 'osType',
													name : 'osType',
													editor : new Ext.grid.GridEditor(
															new Ext.form.ComboBox(
																	{
																		typeAhead : true,
																		triggerAction : 'all',
																		hiddenName : 'osType',
																		mode : 'local',
																		store : this.os_typeStore,
																		displayField : 'name',
																		valueField : 'name',
																		editable : false,
																		allowBlank : false
																	})),
													sortable : true,
													hidden : false,
													width : 60
												},{
													header : 'NFS标示',
													dataIndex : 'nfsFlag',
													name : 'nfsFlag',
													editor : new Ext.grid.GridEditor(
															new Ext.form.ComboBox(
																	{
																		typeAhead : true,
																		triggerAction : 'all',
																		hiddenName : 'nfsFlag',
																		mode : 'local',
																		store : nfsStore,
																		displayField : 'name',
																		valueField : 'name',
																		editable : false,
																		allowBlank : false
																	})),
													sortable : true,
													hidden : false,
													width : 60
												}
												]);
							  
								groupParamGrid = new Ext.grid.EditorGridPanel(
										{
											id : 'envParamPanel',
											region : 'center',
											border : false,
											height : 675,
											anchor : '100%',
											loadMask : true,
											title : '<fmt:message key="title.appGroup" /> ',
											columnLines : true,
											viewConfig : {
												forceFit : true
											},
											store : nshGroupNameStore,
											sm : csm3,
											cm : nshGroup
										});
							//第一个页切内容
							this.firstPanel = new Ext.Panel(
									{
										title : '<fmt:message key="title.find" />',
										items : [{
												region : 'south',
												layout:'form',
												style : 'margin-left:20px;margin-top:10px;margin-bottom:10px', 
												items : [{
													xtype : 'combo',
													anchor : '70%',
													store : this.nshJonsysIdsStore,
													fieldLabel : '<fmt:message key="property.appsysCode" />',
													id : 'nshGroupappsys_Code',
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
														}
													}
												},{
													xtype : 'textfield',
													anchor : '70%',
													fieldLabel : '环境名称',
													id : 'nshEditEnvironmentNameId',
													name : 'environmentCode',
													hiddenName : 'environmentCode',
													value :'开发环境',
													readOnly : true,
													tabIndex : this.tabIndex++
												}]
											},{     
													anchor : '100%',
													region : 'center',
													layout:'form',
													items : [groupParamGrid]			
											},{
												xtype : 'textfield',
												id : 'groupValueId',
												hiddenName : 'groupValue',
												name : 'groupValue',
												tabIndex : this.tabIndex++,
												hidden : true
											}]
									});
							var nshGroup = Ext.data.Record.create([
							                       				   {xtype : 'textfield',name : 'groupName',editable : true},
							                       				   {xtype : 'combo',name: 'serverGroup',hiddenName : 'serverGroup',store : nshGroupStore,valueField : 'value',displayField : 'name',editable : false},
							                       				   {xtype : 'combo',name: 'nfsFlag',hiddenName : 'nfsFlag',store : nfsStore,valueField : 'value',displayField : 'name',editable : false},
							                       				   {xtype : 'combo',name: 'osType',hiddenName : 'osType',store : this.os_typeStore,valueField : 'value',displayField : 'name',editable : false}
							                       				   ]);
							//第二个页切内容
							this.secondPanel = new Ext.Panel(
									{ });
							//第三个页切内容
							 this.threePanel = new Ext.Panel(
									{
										
									}); 
							//向导式开发按钮
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
								var btnNext = Ext.getCmp("nshGroup-move-next");
								var btnPrev = Ext.getCmp("nshGroup-move-prev");
								var btnSave = Ext.getCmp("nshGroup-move-save");
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
										tbar : [
												'-',
												/* {
													id : 'nshGroup-move-prev',
													iconCls : 'button-previous',
													text : '<fmt:message key="button.previous" />',
													handler : cardHandler.createDelegate(this,[ -1 ])
												} */
												{
													id : 'nshGroup-move-create',
													iconCls : 'button-add',
													text : '<fmt:message key="button.createGroup" />',
													hidden : false,
													handler : function() {
														groupParamGrid.getStore().insert(0,new nshGroup({}));
														groupParamGrid.startEditing(0,0);
													}
												},
												'-',
												{
													id : 'nshGroup-move-delete',
													iconCls : 'button-delete',
													text : '<fmt:message key="button.delete" />',
													hidden : false,
													handler :function() {
														var grouprecords=groupParamGrid.getSelectionModel().getSelections();
														groupParamGrid.getStore().remove(grouprecords);
													}

												},
												'-',{
													id : 'nshGroup-move-save',
													iconCls : 'button-save',
													text : '<fmt:message key="button.save" />',
													hidden : false,
													handler : this.doSave
												}
											/* ,
												'-',
												{
													id : 'nshGroup-move-next',
													iconCls : 'button-next',
													text : '<fmt:message key="button.next" />',
													handler : cardHandler.createDelegate(this, [ 1 ])
												} */ ],
										items : [ this.firstPanel/* ,
										          this.secondPanel,
												this.threePanel  */]
									});
							// 设置基类属性							NshGroupCreateTestForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/nshjob/groupCreate',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.cardPanel ]
											});
						},
						// 保存操作
						doSave : function() {
							if (Ext.getCmp('nshGroupappsys_Code').getValue() == '') {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.appSysCodeNotNull" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
								return false;
							}
							var storeParam = nshGroupNameStore;
							var m = storeParam.getModifiedRecords();
							//参数验证
							  for(var i=0;i<m.length;i++){
								var record=m[i];
								var fields=record.fields.keys;
								for(var j=0;j<4;j++){
									var name=fields[j];
									check_value=record.data[name];
									if(check_value==null||check_value==""){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="property.groupNotNull"/>',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										});
										return false;
									}
								}
							} ; 
							
							if(groupParamGrid.getStore().getCount() == 0){
								Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.createServerGroup" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING
								});
								return false;
							}
							var groupParam = [];
							Ext.each(nshGroupNameStore.getModifiedRecords(), function(item) {
								groupParam.push(item.data);
							}); 
							Ext.getCmp('groupValueId').setValue( Ext.util.JSON.encode(groupParam));
									//表单提交
									nshGroupCreateTestForm.getForm().submit(
													{
														scope : nshGroupCreateTestForm,
														success : nshGroupCreateTestForm.saveSuccess,
														failure : nshGroupCreateTestForm.saveFailure,
														waitTitle : '<fmt:message key="message.wait" />',
														waitMsg : '<fmt:message key="message.saving" />'
													});
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
											app.closeTab('add_group');
											var list = Ext.getCmp(
													"DplyGroup").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab('DplyGroup','<fmt:message key="button.view" /><fmt:message key="function" />',
															'${ctx}/${managePath}/nshjob/groupIndex');
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
	var nshGroupCreateTestForm = new NshGroupCreateTestForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_group").add(nshGroupCreateTestForm);
	// 刷新Tab页布局
	Ext.getCmp("add_group").doLayout();
</script>
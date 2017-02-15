<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var nshgroupName= '${param.serverGroup}';
	var nshEditGroupNameStore;
	var editgroupGridForm=null;
	var nsheditGroupStore=null;
	var editgroupParamGrid=null;
	var nshGroupEdit =null;
	var nshjobgridStore ;
	var nfsStore;
	NshGroupEditTestForm = Ext.extend(Ext.FormPanel,
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
							nsheditGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							nsheditGroupStore.load();
							nfsStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/NFS_FLAG/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							nfsStore.load();
							nshjobgridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'GET',
													url : '${ctx}/${managePath}/nshjob/queryNR/${param.appsysCode}/${param.serverGroup}',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields :  [ 'appsysCode', 'serverGroup',
													'groupName','serviceName','nfsFlag','osType' ],
										pruneModifiedRecords : true,
										remoteSort : true,
										sortInfo : {
											field : 'serverGroup',
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											limit : 30
										}
									});
							
							nshjobgridStore.load();
							//服务名数据源
							nshEditGroupNameStore = new Ext.data.Store(
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
							
							  nshGroupEdit = new Ext.grid.ColumnModel(
										[
												new Ext.grid.RowNumberer(),
												csm3,
												{
													header : '<fmt:message key="property.groupname" />',
													dataIndex : 'groupName',
													name : 'groupName',
													id : 'editgroupNameId',
													displayField : 'groupName',
													valueField : 'groupName',
													hiddenName : 'groupName',
													editor : new Ext.grid.GridEditor(
				          									new Ext.form.TextField({allowBlank:false})
				  									),
													sortable : true,
													width : 100
												},
												{
													header : '<fmt:message key="propertyGroup.serverGroup" />',
													dataIndex : 'serverGroup',
													name : 'serverGroup',
													id : 'editserverGroupId',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														
														return nshgroupName;
													}, 
				     								readOnly : true,
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
												},
												{
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
												},{
													header : '<fmt:message key="property.sericeName" />',
													dataIndex : 'serviceName',
													name : 'serviceName',
													displayField : 'serviceName',
													valueField : 'serviceName',
													hiddenName : 'serviceName',
													sortable : true,
													width : 60,
													hidden : true
												}
												]);
							  
								editgroupParamGrid = new Ext.grid.EditorGridPanel(
										{
											id : 'nshGroupPanel',
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
											store : nshjobgridStore,
											sm : csm3,
											cm : nshGroupEdit,
											listeners : {
												//编辑前完成后处理事件
												'beforeedit' : function(e) {
													 if(e.field == 'groupName'){
													var appsysCodes='${param.appsysCode}';
													var serviceNames=e.record.get('groupName');
															Ext.Ajax.request({
																method : 'POST',
																url : '${ctx}/${managePath}/nshjob/queryGroupExist',
																scope : this,
																success : function(response){
																	var responseData = Ext.util.JSON.decode(response.responseText).data;
																	if(responseData == 'false'){
																		e.cancel = false;
																	}else{
																		e.cancel = true;
																		Ext.Msg.show({
																			title : '<fmt:message key="message.title" />',
																			msg : '<fmt:message key="message.editFail" />',
																			buttons : Ext.MessageBox.OK,
																			icon : Ext.MessageBox.ERROR
																		});
																	}
																},
																failure : function(response){
																	var error = response.responseText.error;
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																},
																params : {
																	appsysCodes : appsysCodes,
																	serviceNames : serviceNames
																}
															})
														} 
													}
											    }
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
													id : 'nshEditGroupappsys_Code',
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
													readOnly : true
												},{
													xtype : 'textfield',
													anchor : '70%',
													fieldLabel : '环境名称',
													id : 'nshGroupEditEnvironmentNameId',
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
													items : [editgroupParamGrid]			
											},{
												xtype : 'textfield',
												id : 'editgroupValueId',
												hiddenName : 'groupValue',
												name : 'groupValue',
												tabIndex : this.tabIndex++,
												hidden : true
											},{
												xtype : 'textfield',
												id : 'nameValueId',
												hiddenName : 'nameValue',
												name : 'nameValue',
												tabIndex : this.tabIndex++,
												hidden : true
											},{
												xtype : 'textfield',
												id : 'ValueId',
												hiddenName : 'Value',
												name : 'Value',
												tabIndex : this.tabIndex++,
												hidden : true
											}]
									});
							var nshGroup = Ext.data.Record.create([
							                       				   {xtype : 'textfield',name : 'groupName',editable : true},
							                       				   {xtype : 'textfield',name: 'serverGroup',hiddenName : 'serverGroup'},
							                       				   {xtype : 'combo',name: 'nfsFlag',hiddenName : 'nfsFlag',store : nfsStore,valueField : 'value',displayField : 'name',editable : false},
							                       				{xtype : 'combo',name: 'osType',hiddenName : 'osType',store : this.os_typeStore,valueField : 'value',displayField : 'name',editable : false}
							                       				   ]);
					
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
								var btnNext = Ext.getCmp("nsheditGroup-move-next");
								var btnPrev = Ext.getCmp("nsheditGroup-move-prev");
								var btnSave = Ext.getCmp("nsheditGroup-move-save");
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
												{
													id : 'nsheditGroup-move-create',
													iconCls : 'button-add',
													text : '<fmt:message key="button.createGroup" />',
													hidden : false,
													handler : function() {
														editgroupParamGrid.getStore().insert(0,new nshGroup({}));
														editgroupParamGrid.startEditing(0,0);
													}
												},
												'-',
												{
													id : 'nsheditGroup-move-delete',
													iconCls : 'button-delete',
													text : '<fmt:message key="button.delete" />',
													hidden : false,
													handler :function() {
														var grouprecords=editgroupParamGrid.getSelectionModel().getSelections();
														var a='';
														var appsysCodes='${param.appsysCode}';
														for(var i=0;i<grouprecords.length;i++){
															 a =grouprecords[i].get('groupName');
																Ext.Ajax.request({
																	method : 'POST',
																	url : '${ctx}/${managePath}/nshjob/queryGroupExist',
																	scope : this,
																	success : function(response){
																		var responseData = Ext.util.JSON.decode(response.responseText).data;
																		if(responseData == 'false'){
																			editgroupParamGrid.getStore().remove(grouprecords);
																		}else{
																			Ext.Msg.show({
																				title : '<fmt:message key="message.title" />',
																				msg : '<fmt:message key="message.deleteFail" />',
																				buttons : Ext.MessageBox.OK,
																				icon : Ext.MessageBox.ERROR
																			});
																		}
																	},
																	failure : function(response){
																		var error = response.responseText.error;
																		Ext.Msg.show({
																			title : '<fmt:message key="message.title" />',
																			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
																			buttons : Ext.MessageBox.OK,
																			icon : Ext.MessageBox.ERROR
																		});
																	},
																	params : {
																		appsysCodes : appsysCodes,
																		serviceNames : a
																	}
																})
														}
													}
												},
												'-',{
													id : 'nsheditGroup-move-save',
													iconCls : 'button-save',
													text : '<fmt:message key="button.save" />',
													hidden : false,
													handler : this.doSave
												}
											 ],
										items : [ this.firstPanel]
									});
							// 设置基类属性							NshGroupEditTestForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/nshjob/groupEdit',
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
							      url : '${ctx}/${managePath}/nshjob/queryNR/${param.appsysCode}/${param.serverGroup}',
							      method : 'GET',
							      waitTitle : '<fmt:message key="message.wait" />',
							      waitMsg : '<fmt:message key="message.loading" />',
							      scope : this,
							      success : this.loadSuccess,
							      failure : this.loadFailure
							     }); 
						},
						loadSuccess : function(form, action) {
							Ext.getCmp('nshEditGroupappsys_Code').setValue('${param.appsysCode}');
						},
						// 保存操作
						doSave : function() {
							var storeParam = nshjobgridStore;
							
							var m = storeParam.getModifiedRecords();
							//参数验证
							  for(var i=0;i<m.length;i++){
								var record=m[i];
								var fields=record.fields.keys;
								for(var j=0;j<4;j++){
									if(j==1){}else{
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
								}
							} ; 
							
							var groupParam = [];
							Ext.each(editgroupParamGrid.getStore().getModifiedRecords(), function(item) {
								if(item.data.serviceName!='' && item.data.groupName!=item.data.serviceName){
								groupParam.push(item.data.serviceName);
								}
							}); 
							Ext.getCmp('editgroupValueId').setValue( Ext.util.JSON.encode(groupParam));
							
							var jsonParam = [];
							editgroupParamGrid.getStore().each(function(item) {
								jsonParam.push(item.data);
							});
							
							Ext.getCmp('nameValueId').setValue( Ext.util.JSON.encode(jsonParam));
							Ext.getCmp('ValueId').setValue( Ext.util.JSON.encode(nshgroupName));
									//表单提交  nshgroupName
									nshGroupEditTestForm.getForm().submit(
													{
														scope : nshGroupEditTestForm,
														success : nshGroupEditTestForm.saveSuccess,
														failure : nshGroupEditTestForm.saveFailure,
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
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});
	var nshGroupEditTestForm = new NshGroupEditTestForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("edit_NshGroup").add(nshGroupEditTestForm);
	// 刷新Tab页布局
	Ext.getCmp("edit_NshGroup").doLayout();
</script>
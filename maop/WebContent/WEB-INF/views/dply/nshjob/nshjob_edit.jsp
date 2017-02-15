<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var editgroupName = null;
	var editgroupNameStore;
	var nshJobFilePath = null;
	var editCheckParamgridForm = null;
	var checkParamgridFormStore;
	NshJobEditTestForm = Ext.extend(
					Ext.FormPanel,
					{
						Panel : null,// 查询表单组件
						tree : null,// 树形组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						grid : null,
						flag : true,
						tabIndex : 0,// Tab键顺序
						constructor : function(cfg) {
							// 构造方法
							Ext.apply(this, cfg);
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止
							Ext.getDoc().on('keydown',
											function(e) {
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
							this.scriptTypeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SCRIPT_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.scriptTypeStore.load();
							//服务名数据源
							editgroupNameStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/nshjob/queryjobParentGroup',
													method : 'GET',
													disableCaching : true
												}),
										baseParams : {
											appsysCode : '',
											envCode : ''
										},
										reader : new Ext.data.JsonReader({},[ 'groupName' ]),
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
							//必选参数数据源
							this.ParamgridFormStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/nshjob/generalParam',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'paramName', 'describe',
												'result', 'serverExist' ],
										pruneModifiedRecords : true,
										baseParams : {
											start : 0,
											limit : 20,
											jobGroupName : '',
											appsysCode : '',
											envName :''
										}
									});
							//可选参数数据源
							checkParamgridFormStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/nshjob/checkedCheckParam',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'checkparamName',
												'property', 'checked' ],
										pruneModifiedRecords : true,
										remoteSort : false,
										sortInfo : {
											field : 'checkparamName',
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											limit : 20,
											jobGroupName : '',
											appsysCode : '',
											scriptBlpackageName : '',
											envName :''

										}
									});

							csm3 = new Ext.grid.CheckboxSelectionModel();
							//必选参数
							this.ParamgridForm = new Ext.grid.EditorGridPanel(
									{
										id : 'editParamgridFormid',
										region : 'center',
										border : true,
										height : 250,
										loadMask : true,
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										defaults : {
											anchor : '60%',
											msgTarget : 'side'
										},
										store : this.ParamgridFormStore,
										frame : true,
										// 列定义
										columns : [
												{
													header : '<fmt:message key="property.param_name" />',
													dataIndex : 'paramName',
													allowBlank : false
												},
												{
													header : '<fmt:message key="property.param_describe" />',
													id : 'editParavalueid',
													dataIndex : 'describe'
												},
												{
													header : '<fmt:message key="property.check_result" />',
													dataIndex : 'result',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case 'Y':
															return '成功';
														case 'N':
															return '<span style="color: red;font-weight: bold;">' + '失败' + '</span>';
														}
													}
												},
												{
													header : '<fmt:message key="property.server_exist" />',
													id : 'paravalueid1',
													dataIndex : 'serverExist',
													hidden : true
												} ]
									});
							//可选参数
							editCheckParamgridForm = new Ext.grid.EditorGridPanel(
									{
										id : 'editCheckParamgridFormid',
										title : '<fmt:message key="title.checkParam" />',
										region : 'center',
										border : true,
										height : 400,
										loadMask : true,
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										defaults : {
											anchor : '60%',
											msgTarget : 'side'
										},
										store : checkParamgridFormStore,
										frame : true,
										sm : csm3,
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												csm3,
												{
													header : '<fmt:message key="property.param_name" />',
													name : 'checkparamName',
													sortable : true,
													dataIndex : 'checkparamName',
													allowBlank : false
												},
												{
													header : '<fmt:message key="property.property" />',
													name : 'property',
													sortable : true,
													dataIndex : 'property'
												} ],
										tools : [ {
											id : 'refresh',
											scope : this,
											handler : function() {
												Ext.apply(checkParamgridFormStore.baseParams,
																{
																	appsysCode : Ext.getCmp('nshEditappsys_Code').getValue()
																});
												Ext.apply(checkParamgridFormStore.baseParams,
																{
																	jobGroupName : Ext.getCmp('editjobParentGroupId').getValue()
																});
												Ext.apply(checkParamgridFormStore.baseParams,
														{
													envName : Ext.getCmp('editEnvironmentNameId').getValue()
														});
												checkParamgridFormStore.load();
											}
										} ]
									});
							//第一个页切内容
							this.firstPanel = new Ext.Panel(
									{
										title : '<fmt:message key="title.job" />',
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
														store : this.nshJonsysIdsStore,
														fieldLabel : '<fmt:message key="property.appsysCode" />',
														id : 'nshEditappsys_Code',
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
													},
													{
														xtype : 'combo',
														store : editgroupNameStore,
														fieldLabel : '<fmt:message key="property.jobParentGroup" />',
														id : 'editjobParentGroupId',
														name : 'jobParentGroup',
														displayField : 'groupName',
														valueField : 'groupName',
														hiddenName : 'jobParentGroup',
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
														maxLength : 200,
														fieldLabel : '环境名称',
														id : 'editEnvironmentNameId',
														name : 'environmentCode',
														hiddenName : 'environmentCode',
														value :'开发环境',
														readOnly : true,
														tabIndex : this.tabIndex++
													},{
														xtype : 'textfield',
														fieldLabel : '操作系统类型',
														name : 'osType',
														hiddenName : 'osType',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.scriptName" />',
														id : 'editscriptBlpackageNameId',
														name : 'scriptBlpackageName',
														hiddenName : 'scriptBlpackageName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'combo',
														store : this.scriptTypeStore,
														id : 'editScriptTypeId',
														fieldLabel : "<fmt:message key="property.scriptType" />",
														name : 'scriptType',
														valueField : 'name',
														displayField : 'name',
														hiddenName : 'scriptType',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														tabIndex : this.tabIndex++,
														listeners : {
															scope : this,
															select : function(combo,record,index) {
																var value = combo.value;
																Ext.getCmp('edittypeValueId').setValue(value);
															}
														}
													},
													{
														xtype : 'fileuploadfield',
														fieldLabel : '<fmt:message key="property.upload" />',
														id : 'editnshJobCreatefileID',
														name : 'shPath',
														hiddenName : 'shPath',
														buttonText : '<fmt:message key="property.glance" />',
														editable : true,
														buttonCfg : {
															iconCls : 'upload-icon'
														}
													},
													{
														xtype : 'radiogroup',
														fieldLabel : '查看脚本',
														items : [
																{
																	boxLabel : '是',
																	name : 'checked',
																	inputValue : 'true'
																},
																{
																	checked : true,
																	boxLabel : '否',
																	name : 'checked',
																	id : 'ckeckedFalse',
																	inputValue : 'false'
																} ]
													},
													{
														xtype : 'textfield',
														id : 'editnshValueId',
														hiddenName : 'nshValue',
														name : 'nshValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'editparamValueId',
														hiddenName : 'paramValue',
														name : 'paramValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'edittypeValueId',
														hiddenName : 'typeValue',
														name : 'typeValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'editpathValueId',
														hiddenName : 'pathValue',
														name : 'pathValue',
														tabIndex : this.tabIndex++,
														hidden : true
													} ]
										} ]
									});
							//第二个页切内容
							this.secondPanel = new Ext.Panel({

								title : '<fmt:message key="title.script" />',
								items : [ {
									id : 'editsecondPanel',
									layout : 'form',
									defaults : {
										anchor : '90%'
									},
									border : false,
									items : [ {
										xtype : 'textarea',
										id : 'editScript',
										name : 'script',
										height : 580,
										width : 500,
										readOnly : true,
										tabIndex : this.tabIndex++
									} ]
								} ]
							});
							//第三个页切内容
							this.threePanel = new Ext.Panel(
									{
										items : [ {
											title : '<fmt:message key="title.generalParam" />',
											layout : 'form',
											height : 700,
											autoScroll : true,
											labelAlign : 'center',
											border : false,
											items : [ {
												layout : 'column',
												items : [ {
													labelAlign : 'center',
													border : false,
													items : [
															this.ParamgridForm,
															editCheckParamgridForm ]
												} ]
											} ]
										} ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												// 默认选中数据
												var records;
												setTimeout(
														function() {
											  		  		records = checkParamgridFormStore.query('checked', true).getRange();
														}, 5000);
												setTimeout(
														function() {
															editCheckParamgridForm.getSelectionModel().selectRecords(records,false);
														}, 5000);
											}
										}
									});
							//向导式开发按钮
							var i = 0;
							function cardHandler(direction) {
								if (direction == -1) {
									i--;
									if (i == 1) {
										if (Ext.getCmp('ckeckedFalse')
												.getValue()) {
											i = 0;
										}
									}
									if (i < 0) {
										i = 0;
									}
								}
								if (direction == 1) {
									i++;
									var nshJobFilePath = Ext.getCmp('editnshJobCreatefileID').getValue();
									if (Ext.getCmp('ckeckedFalse').getValue()) {
										var nshJobFilePrefix = nshJobFilePath.substring(nshJobFilePath.lastIndexOf('\\') + 1);
										if ( nshJobFilePrefix != null && nshJobFilePrefix != '' && nshJobFilePrefix != Ext.getCmp('editscriptBlpackageNameId').getValue()) {
											Ext.Msg.show({
														title : '<fmt:message key="message.title"/>',
														msg : '<fmt:message key="nshjob.shError"/>',
														fn : function() {
															Ext.getCmp("editnshJobCreatefileID").focus(true);
														},
														buttons : Ext.Msg.OK,
														icon : Ext.MessageBox.WARNING
													});
											return i = 0;
										}
										if (i == 1) {
											i = 2;
										}
									}
									if (i > 2) {
										i = 2;
										return false;
									}
								}
								var btnNext = Ext.getCmp("nshedit-move-next");
								var btnPrev = Ext.getCmp("nshedit-move-prev");
								var btnSave = Ext.getCmp("nshedit-move-save");
								if (i == 0) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.disable();
								}

								if (i == 1) {
									var nshJobFilePath = Ext.getCmp('editnshJobCreatefileID').getValue();
									if (nshJobFilePath != '') {
										var nshJobFilePrefix = nshJobFilePath.substring(nshJobFilePath.lastIndexOf('\\') + 1);
										if (nshJobFilePrefix != Ext.getCmp('editscriptBlpackageNameId').getValue()) {
											Ext.Msg.show({
														title : '<fmt:message key="message.title"/>',
														msg : '<fmt:message key="nshjob.shError"/>',
														fn : function() {
															Ext.getCmp("editnshJobCreatefileID").focus(true);
														},
														buttons : Ext.Msg.OK,
														icon : Ext.MessageBox.WARNING
													});
											return i = 0;
										}
										if (nshJobFilePath != '' && Ext.getCmp('editScriptTypeId').getValue() == '') {
											Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.chooseScriptType" />',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.INFO,
														minWidth : 200
													});
											return i = 0;
										}
										Ext.getCmp('editScript').setValue('');
										nshJobEditTestForm.getForm().submit(
														{
															url : '${ctx}/${managePath}/nshjob/view',
															scope : nshJobEditTestForm,
															success : nshJobEditTestForm.Success
														});
									} else {
										if (Ext.getCmp('editScriptTypeId').getValue() == '') {
											Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.chooseScriptType" />',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.INFO,
														minWidth : 200
													});
											return i = 0;
										}
										if (Ext.getCmp('editScript').getValue() == undefined || Ext.getCmp('editScript').getValue() == '') {
											var envCode = encodeURIComponent(Ext.getCmp('editEnvironmentNameId').getValue());
											nshJobEditTestForm.getForm().submit(
															{
																url : '${ctx}/${managePath}/nshjob/fileView',
																//url : '${ctx}/${managePath}/nshjob/fileView',
																scope : nshJobEditTestForm,
																success : nshJobEditTestForm.Success,
																method : 'POST',
																params : {
																	envCode : envCode
																}
															});
											app.mask.show();
										}
									}
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
							}
							;
							//CARD总面板  
							this.cardPanel = new Ext.Panel(
									{
										renderTo : document.body,
										id : 'nshJobCardPanelId',
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
													id : 'nshedit-move-prev',
													iconCls : 'button-previous',
													text : '<fmt:message key="button.previous" />',
													handler : cardHandler.createDelegate(this,[ -1 ])
												},
												'-',
												{
													id : 'nshedit-move-save',
													iconCls : 'button-save',
													text : '<fmt:message key="button.save" />',
													hidden : true,
													handler : this.doSave
												},
												'-',
												{
													id : 'nshedit-move-next',
													iconCls : 'button-next',
													text : '<fmt:message key="button.next" />',
													handler : cardHandler.createDelegate(this, [ 1 ])
												} ],
										items : [ this.firstPanel,
												this.secondPanel,
												this.threePanel ]
									});
							// 设置基类属性
							NshJobEditTestForm.superclass.constructor.call(
											this,
											{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/nshjob/edit',
												fileUpload : true,
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
										url : '${ctx}/${managePath}/nshjob/queryNsh/${param.appsysCode}/${param.jobParentGroup}/${param.scriptBlpackageName}/${param.jobName}',
										method : 'GET',
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.loading" />',
										scope : this,
										success : this.loadSuccess,
										failure : this.loadFailure
									});
						},
						loadSuccess : function(form, action) {
							
							Ext.apply(this.ParamgridFormStore.baseParams, {
								appsysCode : Ext.getCmp('nshEditappsys_Code').getValue()
							});
							Ext.apply(this.ParamgridFormStore.baseParams, {
								jobGroupName : Ext.getCmp('editjobParentGroupId').getValue()
							});
							Ext.apply(this.ParamgridFormStore.baseParams, {
								envName : Ext.getCmp('editEnvironmentNameId').getValue()
							});
							Ext.apply(checkParamgridFormStore.baseParams,
									{
										appsysCode : Ext.getCmp('nshEditappsys_Code').getValue()
									});
							Ext.apply(checkParamgridFormStore.baseParams,
									{
										jobGroupName : Ext.getCmp('editjobParentGroupId').getValue()
									});
							Ext.apply(checkParamgridFormStore.baseParams,
									{
										scriptBlpackageName : Ext.getCmp('editscriptBlpackageNameId').getValue()
									});
							Ext.apply(checkParamgridFormStore.baseParams,
									{
										envName : Ext.getCmp('editEnvironmentNameId').getValue()
									});
							this.ParamgridFormStore.reload();
							checkParamgridFormStore.reload();
						},
						// 保存操作
						doSave : function() { //将选中的数据传到后台执行
							var checkParam = '';
							var checkProperty = '';
							var jsonServer = [];
							var paramJson = [];
							var pathJson = [];
							var records = editCheckParamgridForm.getSelectionModel().getSelections();
							for ( var i = 0; i < records.length; i++) {
								checkParam = records[i].get('checkparamName');
								checkProperty = records[i].get('property');
								jsonServer.push(checkParam + "|+|" + checkProperty);
							}
							Ext.getCmp('editnshValueId').setValue(Ext.util.JSON.encode(jsonServer));
							var storeLength = Ext.getCmp('editParamgridFormid').getStore().getCount();
							for ( var i = 0; i < storeLength; i++) {
								var name = Ext.getCmp('editParamgridFormid').getStore().data.items[i].data.paramName;
								paramJson.push(name)
							}
							Ext.getCmp('editparamValueId').setValue(Ext.util.JSON.encode(paramJson));
							Ext.getCmp('editpathValueId').setValue(Ext.getCmp('editnshJobCreatefileID').getValue());
							//表单提交
							nshJobEditTestForm.getForm().submit(
											{
												scope : nshJobEditTestForm,
												success : nshJobEditTestForm.saveSuccess,
												failure : nshJobEditTestForm.saveFailure,
												waitTitle : '<fmt:message key="message.wait" />',
												waitMsg : '<fmt:message key="message.saving" />'
											});
						},
						// 向大文本内中放数据
						Success : function(form, action) {
							app.mask.hide();
							var data = decodeURIComponent(action.result.data);
							var scriptNr = Ext.getCmp('editScript').setValue(data);
							var bottom = this.getHeight();
							this.body.scroll("b", bottom, true);
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
											app.closeTab('add_NshJob');
											var list = Ext.getCmp("DplyNshJob").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab(
															'DplyNshJob',
															'<fmt:message key="button.view" /><fmt:message key="function" />',
															'${ctx}/${managePath}/nshjob/index');
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
	var nshJobEditTestForm = new NshJobEditTestForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("edit_NshJob").add(nshJobEditTestForm);
	// 刷新Tab页布局
	Ext.getCmp("edit_NshJob").doLayout();
</script>
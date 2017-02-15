<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var groupName = null;
	var paramform=null;
	var groupNameStore;
	var nshJobFilePath=null;
	var checkParamgridForm=null;
	NshJobCreateTestForm = Ext.extend(Ext.FormPanel,
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
							this.scriptTypeStore = new Ext.data.JsonStore({
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/SCRIPT_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.scriptTypeStore.load();
							//服务名数据源
							groupNameStore = new Ext.data.Store(
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
							//必选参数数据源
						 	this.ParamgridFormStore = new Ext.data.JsonStore({
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
										'result' , 'serverExist'],
								pruneModifiedRecords : true,
								baseParams : {
									start : 0,
									limit : 20,
									jobGroupName :'',
									appsysCode:'',
									envName : ''
								}
							}); 
							
						 	//可选参数数据源
							this.checkParamgridFormStore = new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									url : '${ctx}/${managePath}/nshjob/checkParam',
									disableCaching : true
								}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'checkparamName', 
										'property' ],
								pruneModifiedRecords : true,		
								remoteSort : false,
								sortInfo : {
									field : 'checkparamName',
									direction : 'ASC'
								}, 
								baseParams : {
									start : 0,
									limit : 20,
									jobGroupName :'',
									appsysCode:'',
									envName : ''
									
								}
							}); 
							csm3 = new Ext.grid.CheckboxSelectionModel();
							//必选参数
							  this.ParamgridForm = new Ext.grid.EditorGridPanel({
										id : 'ParamgridFormid',
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
											header :  '<fmt:message key="property.param_name" />',
											dataIndex : 'paramName',
											allowBlank : false
										}, {
											header : '<fmt:message key="property.param_describe" />',
											id : 'paravalueid',
											dataIndex : 'describe'
										}, {
											header :'<fmt:message key="property.check_result" />',
											dataIndex : 'result',
											renderer : function(value,metadata, record,rowIndex, colIndex,store) {
												switch (value) {
												case 'Y':
													return '成功';
												case 'N':
													return '<span style="color: red;font-weight: bold;">'+ '参数不存在,请先创建该参数' +'</span>';
												}
											}
										},{
											header : '<fmt:message key="property.server_exist" />',
											id : 'paravalueid0',
											dataIndex : 'serverExist',
											hidden : true
										}
										]
									}); 
							//可选参数
							  checkParamgridForm = new Ext.grid.EditorGridPanel({
									id : 'chevkParamgridFormid',
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
									store : this.checkParamgridFormStore,
									frame : true,
									sm:csm3,
									// 列定义
									columns : [ new Ext.grid.RowNumberer(),csm3,
									{
										header :  '<fmt:message key="property.param_name" />',
										name : 'checkparamName',
										sortable : true,
										dataIndex : 'checkparamName',
										allowBlank : false
									},  {
										header :'<fmt:message key="property.property" />',
										sortable : true,
										name : 'property',
										dataIndex : 'property'
									}],
									tools : [ {
										id : 'refresh',
										scope : this,
										handler : function() {
											this.checkParamgridFormStore.reload();
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
														id : 'nshappsys_Code',
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
																Ext.getCmp('jobParentGroupId').setValue('');
																groupNameStore.baseParams.appsysCode = combo.value;
																groupNameStore.baseParams.envCode = encodeURIComponent(Ext.getCmp('environmentNameId').getValue());
																this.ParamgridFormStore.baseParams.appsysCode = combo.value;
																this.checkParamgridFormStore.baseParams.appsysCode = combo.value;
																var environmentCode = Ext.getCmp('environmentCode2');//环境编号
																groupNameStore.reload();
															}
														}
													},
													{
														xtype : 'combo',
														store : groupNameStore,
														fieldLabel : '<fmt:message key="property.jobParentGroup" />',
														id : 'jobParentGroupId',
														name : 'jobParentGroup',
														displayField : 'groupName',
														valueField : 'groupName',
														hiddenName : 'jobParentGroup',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														maxLength : 50,
														tabIndex : this.tabIndex++,
														allowBlank : false,
														typeAhead : true,
														listeners : {
															scope : this,
															/* 'beforequery' : function(e) {
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
															}, */
															select : function(combo,record,index) {
																this.ParamgridFormStore.baseParams.jobGroupName = combo.value;
																this.checkParamgridFormStore.baseParams.jobGroupName = combo.value;
																this.ParamgridFormStore.baseParams.envName = Ext.getCmp('environmentNameId').getValue();
																this.checkParamgridFormStore.baseParams.envName = Ext.getCmp('environmentNameId').getValue();
																this.ParamgridFormStore.reload();
																this.checkParamgridFormStore.reload();
																
																var appsysCode=Ext.getCmp('nshappsys_Code').getValue();
																var serviceName=Ext.getCmp('jobParentGroupId').getValue();
																Ext.Ajax.request({
																	url : '${ctx}/${managePath}/nshjob/queryosType',
																	method : 'POST',
																	callback : this.updateData,
																	scope : this,
																	params : {
																		appsysCode : appsysCode,
																		serviceName : serviceName
																	}
																}); 
															}
														}
													},{
														xtype : 'textfield',
														maxLength : 200,
														fieldLabel : '环境名称',
														id : 'environmentNameId',
														name : 'environmentCode',
														hiddenName : 'environmentCode',
														value :'开发环境',
														readOnly : true,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														fieldLabel : '操作系统类型',
														id : 'osTypeId',
														name : 'osType',
														hiddenName : 'osType',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="property.scriptName" />',
														id : 'scriptBlpackageNameId',
														name : 'scriptBlpackageName',
														hiddenName : 'scriptBlpackageName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},

													{
														xtype : 'fileuploadfield',
														fieldLabel:'<fmt:message key="property.upload" />',
														id : 'nshJobCreatefileID',
														name : 'shPath',
														hiddenName : 'shPath',
														buttonText : '<fmt:message key="property.glance" />',
														editable : true ,
														buttonCfg: {
															iconCls: 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField, path) {
																nshJobFilePath=path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																var script=Ext.getCmp('scriptBlpackageNameId');
																script.setValue(scriptName);
															}
														}
													},{
														xtype : 'combo',
														store : this.scriptTypeStore,
														fieldLabel : "<fmt:message key="property.scriptType" />",
														id : 'scriptTypeId',
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
																Ext.getCmp('typeValueId').setValue(value);
															}
														}
													},
													{
														xtype : 'textfield',
														id : 'nshValueId',
														hiddenName : 'nshValue',
														name : 'nshValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'paramValueId',
														hiddenName : 'paramValue',
														name : 'paramValue',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'typeValueId',
														hiddenName : 'typeValue',
														name : 'typeValue',
														tabIndex : this.tabIndex++,
														hidden : true
													}
													]
										} ]
									});
							//第二个页切内容
							this.secondPanel = new Ext.Panel(
									{

										title : '<fmt:message key="title.script" />',
										items : [ {
											id : 'firstPanel3',
											layout : 'form',
											defaults : {
												anchor : '90%'
											},
											border : false,
											items : [ {
												xtype : 'textarea',
												id : 'script',
												name : 'script',
												height : 580,
												width : 500,
												readOnly : true,
												tabIndex : this.tabIndex++
											}  ]
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
												items : [
														{
															labelAlign : 'center',
															border : false,
															items : [
																	this.ParamgridForm,
																	checkParamgridForm ]
														}]
											} ]
										} ]
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
								var btnNext = Ext.getCmp("nshcerate-move-next");
								var btnPrev = Ext.getCmp("nshcerate-move-prev");
								var btnSave = Ext.getCmp("nshcerate-move-save");
								if (i == 0) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.disable();
								}
								if (i == 1) {
									btnSave.hide();
									btnNext.enable();
									btnPrev.enable();
									if (Ext.getCmp('nshappsys_Code').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.appSysCodeNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
									if (Ext.getCmp('jobParentGroupId').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.groupNameNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
									if (Ext.getCmp('nshJobCreatefileID').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.nshJobFileNotNull" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
									var scriptName=Ext.getCmp('scriptBlpackageNameId').getValue();
									var a = [];
									a=scriptName.split("_");
									if(scriptName.split("_").length<3){
										Ext.Msg.show({
											title : '<fmt:message key="message.title"/>',
											msg :'脚本命名不规范',
											fn : function() {
												Ext.getCmp("nshJobCreatefileID").focus(true);
											},
											buttons : Ext.Msg.OK,
											icon : Ext.MessageBox.WARNING
										});
										return i = 0;
									}
									if(a[0]!=Ext.getCmp('nshappsys_Code').getValue()){
										Ext.Msg.show({
											title : '<fmt:message key="message.title"/>',
											msg :'脚本命名不规范',
											fn : function() {
												Ext.getCmp("nshJobCreatefileID").focus(true);
											},
											buttons : Ext.Msg.OK,
											icon : Ext.MessageBox.WARNING
										});
										return i = 0;
									}
									if(a[1]!=Ext.getCmp('jobParentGroupId').getValue()){
										Ext.Msg.show({
											title : '<fmt:message key="message.title"/>',
											msg :'脚本命名不规范',
											fn : function() {
												Ext.getCmp("nshJobCreatefileID").focus(true);
											},
											buttons : Ext.Msg.OK,
											icon : Ext.MessageBox.WARNING
										});
										return i = 0;
									}
									var nshJobFilePath = Ext.getCmp('nshJobCreatefileID').getValue();
									var nshJobFilePrefix = nshJobFilePath.substring(nshJobFilePath.lastIndexOf('.') );
							 		if(Ext.getCmp('osTypeId').getValue()=='WINDOWS'){
										if( nshJobFilePrefix.toLowerCase() != '.bat' && nshJobFilePrefix.toLowerCase() != '.vbs' && nshJobFilePrefix.toLowerCase() != '.pl'){
											Ext.Msg.show({
												title : '<fmt:message key="message.title"/>',
												msg :'请上传.bat,.vbs或.pl脚本',
												fn : function() {
													Ext.getCmp("nshJobCreatefileID").focus(true);
												},
												buttons : Ext.Msg.OK,
												icon : Ext.MessageBox.WARNING
											});
											return i = 0;
										}
									}
									else{ 
										if( nshJobFilePrefix.toLowerCase() != '.sh' ){
											Ext.Msg.show({
												title : '<fmt:message key="message.title"/>',
												msg :'<fmt:message key="nshjob.upload_check_sh"/>',
												fn : function() {
													Ext.getCmp("nshJobCreatefileID").focus(true);
												},
												buttons : Ext.Msg.OK,
												icon : Ext.MessageBox.WARNING
											});
											return i = 0;
											
										}  
									}	
									if (Ext.getCmp('scriptTypeId').getValue() == '') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.chooseScriptType" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return i = 0;
									}
									nshJobCreateTestForm.getForm().submit(
											{
												url : '${ctx}/${managePath}/nshjob/view',
												scope : nshJobCreateTestForm,
												success : nshJobCreateTestForm.Success
											});
									
								
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
													id : 'nshcerate-move-prev',
													iconCls : 'button-previous',
													text : '<fmt:message key="button.previous" />',
													handler : cardHandler.createDelegate(this,[ -1 ])
												},
												'-',
												{
													id : 'nshcerate-move-save',
													iconCls : 'button-save',
													text : '<fmt:message key="button.save" />',
													hidden : true,
													handler : this.doSave
												},
												'-',
												{
													id : 'nshcerate-move-next',
													iconCls : 'button-next',
													text : '<fmt:message key="button.next" />',
													handler : cardHandler.createDelegate(this, [ 1 ])
												} ],
										items : [ this.firstPanel,
										          this.secondPanel,
												this.threePanel ]
									});
							// 设置基类属性							NshJobCreateTestForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/nshjob/create',
												fileUpload : true, 
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.cardPanel ]
											});
						},
						//向大文本(脚本内容)中加数据
						updateData : function(options, success, response) {
							if (success) {
								var data = decodeURIComponent(Ext.decode(response.responseText).data[0].OS_TYPE);
								var scriptNr=Ext.getCmp('osTypeId').setValue(data);
								var bottom = this.getHeight();
								this.body.scroll("b", bottom, true);
							}
						},
						// 保存操作
						doSave : function() {
							var appsysCodes=Ext.getCmp('nshappsys_Code').getValue();
							var jobParentGroups=Ext.getCmp('jobParentGroupId').getValue();
							var scriptBlpackageNames=Ext.getCmp('scriptBlpackageNameId').getValue();
							Ext.Ajax.request({
								method : 'POST',
								url : '${ctx}/${managePath}/nshjob/queryExist',
								scope : this,
								success : function(response){
									var responseData = Ext.util.JSON.decode(response.responseText).data;
									if(responseData == 'false'){
									//保存验证
									 if (Ext.getCmp('ParamgridFormid').getStore().data.items[0].data.serverExist == 'N') {
										Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.checkServerProperty" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
										return false;
									} 
									 if (Ext.getCmp('ParamgridFormid').getStore().data.items[0].data.result == 'N') {
											Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '参数不存在,请先创建该参数',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.INFO,
														minWidth : 200
													});
											return false;
										} 
									//将选中的数据传到后台执行
									var checkParam='';
									var checkProperty='';
									var jsonServer = [];
									var paramJson=[];
									var records = checkParamgridForm.getSelectionModel().getSelections();
									for ( var i = 0; i < records.length; i++) {
										checkParam = records[i].get('checkparamName');
										checkProperty = records[i].get('property');
										jsonServer.push(checkParam + "|+|" + checkProperty);
									}
									Ext.getCmp('nshValueId').setValue(Ext.util.JSON.encode(jsonServer));
									
									var storeLength=Ext.getCmp('ParamgridFormid').getStore().getCount();
									for ( var i = 0; i < storeLength; i++) {
										var name=Ext.getCmp('ParamgridFormid').getStore().data.items[i].data.paramName;
										paramJson.push(name)
									}
									Ext.getCmp('paramValueId').setValue(Ext.util.JSON.encode(paramJson));
									//表单提交
									nshJobCreateTestForm.getForm().submit(
													{
														scope : nshJobCreateTestForm,
														success : nshJobCreateTestForm.saveSuccess,
														failure : nshJobCreateTestForm.saveFailure,
														waitTitle : '<fmt:message key="message.wait" />',
														waitMsg : '<fmt:message key="message.saving" />'
													});
									}else{
										Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.exist" />',
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
									jobParentGroups : jobParentGroups,
									scriptBlpackageNames : scriptBlpackageNames
								}
							});
							
						},
						// 向大文本内中放数据
						Success : function(form, action) {
							var data = decodeURIComponent(action.result.data);
							var scriptNr=Ext.getCmp('script').setValue(data);
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
											var list = Ext.getCmp(
													"DplyNshJob").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab('DplyNshJob','<fmt:message key="button.view" /><fmt:message key="function" />',
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
	var nshJobCreateTestForm = new NshJobCreateTestForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_NshJob").add(nshJobCreateTestForm);
	// 刷新Tab页布局
	Ext.getCmp("add_NshJob").doLayout();
</script>
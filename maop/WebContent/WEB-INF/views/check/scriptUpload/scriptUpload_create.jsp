<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var binFilePath=null;
	var setFilePath=null;
	var initFilePath=null;
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
							//专业领域分类
							this.fieldTypeStore = new Ext.data.JsonStore({
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/CHECK_FIELD_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.fieldTypeStore.load();
							//操作系统类型
							this.os_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_OS_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
									this.os_typeStore.load();
							this.field_type_oneStore = new Ext.data.Store(
									{
										proxy: new Ext.data.HttpProxy({
											url : '${ctx}/${managePath}/scriptUpload/getFieldTypeone', 
											method: 'POST'
										}),
										reader: new Ext.data.JsonReader({}, ['field_type_two'])
									});
							this.field_type_oneStore.load();
							this.field_type_oneStore.on('beforeload', function(loader,node) {
								//使用查询条件系统代码文本框时用
								loader.baseParams.fieldType = Ext.getCmp("field_type_uploadId").getValue();
							}, this);
							csm3 = new Ext.grid.CheckboxSelectionModel();
							this.uploadForm = new Ext.Panel(
									{
										title : '脚本上传',
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
												store : this.os_typeStore,
												fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.osType" />',
												emptyText : '<fmt:message key="job.select_please" />' ,
												//name : 'osType',
												valueField : 'value',
												displayField : 'name',
												hiddenName : 'osType',
												mode : 'local',
												triggerAction : 'all',
												forceSelection : true,
												editable : false,
												allowBlank : false,
												tabIndex : this.tabIndex++
												},{
													xtype : 'combo',
													fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.field" />',
													emptyText : '<fmt:message key="job.select_please" />' ,
													hiddenName : 'fieldType',
													id : 'field_type_uploadId',
													store : this.fieldTypeStore,
													displayField : 'name',
													valueField : 'value',
													mode: 'local',
													typeAhead: true,
								                    triggerAction: 'all',
								                    editable : false,  
								                    allowBlank : false,
													tabIndex : this.tabIndex++,
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
														 },
													select : function(combo,record,index) {
														this.field_type_oneStore.reload();
														}
													}
												},{
													xtype : 'combo',
													fieldLabel : '<font color=red>*</font>&nbsp;巡检分类',
													emptyText : '<fmt:message key="job.select_please" />' ,
													hiddenName : 'checkObject',
													id : 'jobDesign_fieldTypeOne_create',
													store : this.field_type_oneStore,
													displayField : 'field_type_two',
													valueField : 'field_type_two',
													mode: 'local',
													typeAhead: true,
								                    triggerAction: 'all',
								                    editable : false,  
								                    allowBlank : false,
													tabIndex : this.tabIndex++
												},{
														xtype : 'textfield',
														fieldLabel : '<font color=red>*</font>&nbsp;巡检项名称',
														emptyText : '请填写' ,
														id : 'checkNameId',
														name : 'checkItemName',
														hiddenName : 'checkItemName',
														maxLength : 200,
														readOnly : false,
														allowBlank : false,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'fileuploadfield',
														fieldLabel:'<font color=red>*</font>&nbsp;巡检脚本',
														id : 'binScriptID',
														name : 'binScriptPath',
														hiddenName : 'binScriptPath',
														buttonText : '浏览',
														editable : true ,
														allowBlank : false,
														buttonCfg: {
															iconCls: 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField, path) {
																binFilePath=path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																var binName=scriptName.substring(scriptName.lastIndexOf("_")+1, scriptName.indexOf("."));
																if(binName!='check'){
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '请上传bin脚本',
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																	Ext.getCmp('binScriptID').reset();
																	return false;
																}
																var script=Ext.getCmp('binScriptNameId');
																script.setValue(scriptName);
															}
														}
													},{
														xtype : 'textfield',
														fieldLabel : '巡检脚本名称',
														id : 'binScriptNameId',
														name : 'binScriptName',
														hiddenName : 'binScriptName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},{
														xtype : 'fileuploadfield',
														fieldLabel:'配置生成脚本',
														id : 'setScriptId',
														name : 'setScriptPath',
														hiddenName : 'setScriptPath',
														buttonText : '浏览',
														editable : true ,
														buttonCfg: {
															iconCls: 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField, path) {
																setFilePath=path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																var setName=scriptName.substring(scriptName.lastIndexOf("_")+1, scriptName.indexOf("."));
																if(setName!='set'){
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '请上传set脚本',
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																	Ext.getCmp('setScriptId').reset();
																	Ext.getCmp('setScriptNameId').setValue("");
																	return false;
																}
																var script=Ext.getCmp('setScriptNameId');
																script.setValue(scriptName);
															}
														}
													},{
														xtype : 'textfield',
														fieldLabel : '配置生成脚本名称',
														id : 'setScriptNameId',
														name : 'setScriptName',
														hiddenName : 'setScriptName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},{
														xtype : 'fileuploadfield',
														fieldLabel:'初始化脚本',
														id : 'initScriptID',
														name : 'initScriptPath',
														hiddenName : 'initScriptPath',
														buttonText : '浏览',
														editable : true ,
														buttonCfg: {
															iconCls: 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField, path) {
																initFilePath=path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																var initName=scriptName.substring(scriptName.lastIndexOf("_")+1, scriptName.indexOf("."));
																if(initName!='init'){
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '请上传init脚本',
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																	Ext.getCmp('initScriptID').reset();
																	Ext.getCmp('initScriptNameId').setValue("");
																	return false;
																}
																var script=Ext.getCmp('initScriptNameId');
																script.setValue(scriptName);
															}
														}
													},{
														xtype : 'textfield',
														fieldLabel : '初始化脚本名称',
														id : 'initScriptNameId',
														name : 'initScriptName',
														hiddenName : 'initScriptName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},{
														xtype : 'textfield',
														fieldLabel : '巡检项描述',
														name : 'checkItemDesc',
														maxLength : 200,
														height : 120,
														tabIndex : this.tabIndex++
													}]
										} ]
									});
							// 设置基类属性							ScriptUploadForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/scriptUpload/create',
												fileUpload : true, 
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.uploadForm],
												// 定义按钮grid
								       			buttons : [{
								       				text : '<fmt:message key="button.save" />',
								       				iconCls : 'button-save',
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
							scriptUploadForm.getForm().submit(
									{
										scope : scriptUploadForm,
										success : scriptUploadForm.saveSuccess,
										failure : scriptUploadForm.saveFailure,
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.saving" />'
									});
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('add_scriptUpload');
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
											app.closeTab('add_scriptUpload');
											var list = Ext.getCmp(
													"SCRIPT_UPLOAD").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab('SCRIPT_UPLOAD','<fmt:message key="button.view" /><fmt:message key="function" />',
															'${ctx}/${managePath}/scriptUpload/index');
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
	Ext.getCmp("add_scriptUpload").add(scriptUploadForm);
	// 刷新Tab页布局
	Ext.getCmp("add_scriptUpload").doLayout();
</script>
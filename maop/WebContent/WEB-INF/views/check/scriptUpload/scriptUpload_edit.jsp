<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var editgroupName = null;
	var editgroupNameStore;
	var binScriptFilePath = null;
	var editCheckParamgridForm = null;
	var paramBinScript = '${param.binScriptName}';
	var paramSetScript = '${param.setScriptName}';
	var paramInitScript = '${param.initScriptName}';
	editScriptUploadForm = Ext.extend(Ext.FormPanel,
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
							Ext.getDoc().on('keydown',function(e) {
												if (e.getKey() == 8 && e.getTarget().type == 'text' && !e.getTarget().readOnly) {
												} else if (e.getKey() == 8 && e.getTarget().type == 'textarea' && !e.getTarget().readOnly) {
												} else if (e.getKey() == 8) {
													e.preventDefault();
												}
											});
							//专业领域分类
							this.fieldTypeStore = new Ext.data.JsonStore(
									{
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
										url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.os_typeStore.load();
							this.field_type_oneStore = new Ext.data.Store(
									{
										proxy : new Ext.data.HttpProxy(
												{
													url : '${ctx}/${managePath}/scriptUpload/getFieldTypeone',
													method : 'POST'
												}),
										reader : new Ext.data.JsonReader({},[ 'field_type_two' ])
									});
							this.field_type_oneStore.load();
							this.field_type_oneStore.on('beforeload', function(loader, node) {
								//使用查询条件系统代码文本框时用
								loader.baseParams.fieldType = Ext.getCmp("editField_type_uploadId").getValue();
							}, this);
							csm3 = new Ext.grid.CheckboxSelectionModel();
							//第一个页切内容
							this.editScriptUpload = new Ext.Panel(
									{
										title : '修改脚本',
										items : [ {
											buttonAlign : 'center',
											frame : true,
											autoScroll : true,
											labelAlign : 'center',
											labelWidth : 100,
											defaults : {
												anchor : '75%'
											},
											layout : 'form',
											items : [
													{
														xtype : 'combo',
														store : this.os_typeStore,
														fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.osType" />',
														emptyText : '<fmt:message key="job.select_please" />',
														name : 'osType',
														valueField : 'value',
														displayField : 'name',
														hiddenName : 'osType',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : true,
														maxLength : 50,
														tabIndex : this.tabIndex++,
														typeAhead : true,
														readOnly : true
													},
													{
														xtype : 'combo',
														fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.field" />',
														emptyText : '<fmt:message key="job.select_please" />',
														hiddenName : 'fieldType',
														id : 'editField_type_uploadId',
														store : this.fieldTypeStore,
														displayField : 'name',
														valueField : 'value',
														mode : 'local',
														typeAhead : true,
														triggerAction : 'all',
														editable : false,
														tabIndex : this.tabIndex++,
														typeAhead : true,
														readOnly : true
													},
													{
														xtype : 'combo',
														fieldLabel : '<font color=red>*</font>&nbsp;巡检分类',
														emptyText : '<fmt:message key="job.select_please" />',
														name : 'checkObject',
														hiddenName : 'checkObject',
														id : 'jobDesign_fieldTypeOne_edit',
														store : this.field_type_oneStore,
														displayField : 'field_type_two',
														valueField : 'field_type_two',
														mode : 'local',
														typeAhead : true,
														triggerAction : 'all',
														editable : false,
														tabIndex : this.tabIndex++,
														typeAhead : true,
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '<font color=red>*</font>&nbsp;巡检项名称',
														emptyText : '请填写',
														id : 'editCheckNameId',
														name : 'checkItemName',
														hiddenName : 'checkItemName',
														maxLength : 200,
														readOnly : false,
														allowBlank : false,
														tabIndex : this.tabIndex++,
														typeAhead : true
													},
													{
														xtype : 'fileuploadfield',
														fieldLabel : '巡检脚本',
														id : 'editBinScriptId',
														name : 'binScriptPath',
														hiddenName : 'binScriptPath',
														buttonText : '浏览',
														editable : true,
														buttonCfg : {
															iconCls : 'upload-icon'
														}
													},
													{
														xtype : 'textfield',
														fieldLabel : '巡检脚本名称',
														id : 'editBinScriptNameId',
														name : 'binScriptName',
														hiddenName : 'binScriptName',
														maxLength : 200,
														readOnly : true,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'fileuploadfield',
														fieldLabel : '配置生成脚本',
														id : 'editSetScriptId',
														name : 'setScriptPath',
														hiddenName : 'setScriptPath',
														buttonText : '浏览',
														editable : true,
														buttonCfg : {
															iconCls : 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField,path) {
																setFilePath = path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																var setName=scriptName.substring(scriptName.lastIndexOf("_")+1, scriptName.indexOf("."));
																if(setName!='set'){
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '请上传set脚本',
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																	Ext.getCmp('editSetScriptId').reset();
																	Ext.getCmp('editInitScriptNameId').setValue("");
																	return false;
																}
																var script = Ext.getCmp('editSetScriptNameId');
																script.setValue(scriptName);
															}
														}
													},
													 {
														items : [ {
															xtype : 'compositefield',
															items : [
																	{
																		xtype : 'displayfield',
																		value : '&nbsp;配置生成脚本名称:'
																	},
																	{
																		xtype : 'textfield',
																		layout : 'form',
																		width : 535,
																		id : 'editSetScriptNameId',
																		name : 'setScriptName',
																		hiddenName : 'setScriptName',
																		maxLength : 200,
																		readOnly : true,
																		tabIndex : this.tabIndex++
																	} ,
																	{
																		xtype : 'button',
																		text : '<fmt:message key="button.delete" />',
																		scope : this,
																		iconCls : 'button-delete',
																		handler : this.doDelete
																	}  ]
														} ]
													}, 
													{
														xtype : 'fileuploadfield',
														fieldLabel : '初始化脚本',
														id : 'editInitScriptId',
														name : 'initScriptPath',
														hiddenName : 'initScriptPath',
														buttonText : '浏览',
														editable : true,
														buttonCfg : {
															iconCls : 'upload-icon'
														},
														listeners : {
															scope : this,
															'fileselected' : function(fileField,path) {
																initFilePath = path;
																var scriptName = path.substring(path.lastIndexOf('\\') + 1);
																
																var initName=scriptName.substring(scriptName.lastIndexOf("_")+1, scriptName.indexOf("."));
																if(initName!='init'){
																	Ext.Msg.show({
																		title : '<fmt:message key="message.title" />',
																		msg : '请上传init脚本',
																		buttons : Ext.MessageBox.OK,
																		icon : Ext.MessageBox.ERROR
																	});
																	Ext.getCmp('editInitScriptNameId').setValue("");
																	Ext.getCmp('editInitScriptId').reset();
																	return false;
																}
																var script = Ext.getCmp('editInitScriptNameId');
																script.setValue(scriptName);
															}
														}
													},
													{
														items : [ {
															xtype : 'compositefield',
															items : [
																	{
																		xtype : 'displayfield',
																		value : '&nbsp;&nbsp;初始化脚本名称:&nbsp;&nbsp;'
																	},
																	{
																		xtype : 'textfield',
																		layout : 'form',
																		width : 535,
																		id : 'editInitScriptNameId',
																		name : 'initScriptName',
																		hiddenName : 'initScriptName',
																		maxLength : 200,
																		readOnly : true,
																		tabIndex : this.tabIndex++
																	},
																	{
																		xtype : 'button',
																		text : '<fmt:message key="button.delete" />',
																		scope : this,
																		iconCls : 'button-delete',
																		handler : this.doFind
																	} ]
														} ]
													},
													{
														xtype : 'textfield',
														fieldLabel : '巡检项描述',
														name : 'checkItemDesc',
														maxLength : 200,
														height : 120,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														id : 'editValueId',
														name : 'Value',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'editParamId',
														name : 'param',
														tabIndex : this.tabIndex++,
														hidden : true
													},
													{
														xtype : 'textfield',
														id : 'editPathId',
														name : 'path',
														tabIndex : this.tabIndex++,
														hidden : true
													} ]
										} ]
									});
							// 设置基类属性
							editScriptUploadForm.superclass.constructor.call(this,
											{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/scriptUpload/edit',
												fileUpload : true,
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [ this.editScriptUpload ],
												// 定义按钮grid
												buttons : [
														{
															text : '<fmt:message key="button.save" />',
															iconCls : 'button-save',
															tabIndex : this.tabIndex++,
															scope : this,
															handler : this.doSave
														},
														{
															text : '<fmt:message key="button.cancel" />',
															iconCls : 'button-cancel',
															scope : this,
															handler : this.doCancel
														} ]
											});
							// 加载表单数据
							this.form.load({
										url : '${ctx}/${managePath}/scriptUpload/query/${param.osType}/${param.binScriptName}/${param.fieldType}',
										method : 'GET',
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.loading" />',
										scope : this,
										success : this.loadSuccess,
										failure : this.loadFailure
									});
						},
						doFind : function() {
							Ext.getCmp('editInitScriptNameId').setValue("");
							Ext.getCmp('editInitScriptId').reset();
						},
						doDelete : function() {
							Ext.getCmp('editSetScriptNameId').setValue("");
							Ext.getCmp('editSetScriptId').reset();
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('edit_scriptUpload');
						},
						// 保存操作
						doSave : function() {
							var binScriptFilePath = Ext.getCmp('editBinScriptId').getValue();
							if (binScriptFilePath != '') {
								var binScriptFilePrefix = binScriptFilePath.substring(binScriptFilePath.lastIndexOf('\\') + 1);
								if (binScriptFilePrefix != Ext.getCmp('editBinScriptNameId').getValue()) {
									Ext.Msg.show({
												title : '<fmt:message key="message.title"/>',
												msg : '上传的巡检脚本与原文件不同,请重新上传',
												fn : function() {
													Ext.getCmp( "editnshJobCreatefileID").focus(true);
												},
												buttons : Ext.Msg.OK,
												icon : Ext.MessageBox.WARNING
											});
								}
							}
							var jsonServer = [];
							var binScriptName = Ext.getCmp('editBinScriptNameId').getValue();
							var initScriptName = Ext.getCmp('editInitScriptNameId').getValue();
							var setScriptName = Ext.getCmp('editSetScriptNameId').getValue();
							if (binScriptName == null || binScriptName == '') {
								binScriptName = " ";
							}
							if (initScriptName == null || initScriptName == '') {
								initScriptName = " ";
							}
							if (setScriptName == null || setScriptName == '') {
								setScriptName = " ";
							}
							jsonServer.push(binScriptName + "|+|" + setScriptName + "|+|" + initScriptName);
							Ext.getCmp('editValueId').setValue(Ext.util.JSON.encode(jsonServer));
							var paramServer = [];
							if (paramBinScript == null || paramBinScript == '') {
								paramBinScript = " ";
							}
							if (paramSetScript == null || paramSetScript == '') {
								paramSetScript = " ";
							}
							if (paramInitScript == null || paramInitScript == '') {
								paramInitScript = " ";
							}
							paramServer.push(paramBinScript + "|+|" + paramSetScript + "|+|" + paramInitScript);
							Ext.getCmp('editParamId').setValue(Ext.util.JSON.encode(paramServer));
							var pathJson = [];
							var binScriptPath = Ext.getCmp('editBinScriptId').getValue();
							var initScriptPath = Ext.getCmp('editSetScriptId').getValue();
							var setScriptPath = Ext.getCmp('editInitScriptId').getValue();
							if (binScriptPath == null || binScriptPath == '') {
								binScriptPath = " ";
							}
							if (initScriptPath == null || initScriptPath == '') {
								initScriptPath = " ";
							}
							if (setScriptPath == null || setScriptPath == '') {
								setScriptPath = " ";
							}
							pathJson.push(binScriptPath + "|+|" + initScriptPath + "|+|" + setScriptPath);
							Ext.getCmp('editPathId').setValue(Ext.util.JSON.encode(pathJson));

							//表单提交
							editscriptUploadForm.getForm().submit(
											{
												scope : editscriptUploadForm,
												success : editscriptUploadForm.saveSuccess,
												failure : editscriptUploadForm.saveFailure,
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
											app.closeTab('edit_scriptUpload');
											var list = Ext.getCmp(
													"SCRIPT_UPLOAD").get(0);
											if (list != null) {
												list.grid.getStore().reload();
											}
											app.loadTab(
															'SCRIPT_UPLOAD',
															'<fmt:message key="button.view" /><fmt:message key="function" />',
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
	var editscriptUploadForm = new editScriptUploadForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("edit_scriptUpload").add(editscriptUploadForm);
	// 刷新Tab页布局
	Ext.getCmp("edit_scriptUpload").doLayout();
</script>
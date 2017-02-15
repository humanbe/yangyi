<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//容量风险分类
	var jobTypeStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/JOB_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var grinshgridStore	;
	var os_typeStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	//定义列表
	ScriptUploadIndexList = Ext.extend(Ext.Panel,
					{
						nshgridStore : null,// 数据列表数据源						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序						csm : null,// 数据列表选择框组件						constructor : function(cfg) {// 构造方法							jobTypeStore.load();
							Ext.apply(this, cfg);
							// 实例化数据列表选择框组件							csm = new Ext.grid.CheckboxSelectionModel();
							//专业领域分类
							this.fieldTypeStore = new Ext.data.JsonStore({
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/CHECK_FIELD_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.fieldTypeStore.load();
							os_typeStore.load();
							// 实例化数据列表数据源
							this.nshgridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/scriptUpload/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'osType','fieldType','checkItemName','binScriptName', 'setScriptName',
												'initScriptName'],
										remoteSort : true,
										sortInfo : {
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											limit : 100
										}
									});
							this.nshgridStore.load();
							// 实例化数据列表组件							this.grid = new Ext.grid.GridPanel(
									{
										region : 'center',
										border : false,
										loadMask : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										store : this.nshgridStore,
										sm : csm,
										// 列定义										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												{
													header : '<fmt:message key="property.osType" />',
													dataIndex : 'osType',
													sortable : true,
													renderer : this.OsType
												},
												{
													header : '<fmt:message key="property.fieldType" />',
													dataIndex : 'fieldType',
													sortable : true
												},
												{
													header : '<fmt:message key="property.checkItemName" />',
													dataIndex : 'checkItemName',
													sortable : true,
													width : 100
												},
												{
													header : '<fmt:message key="property.binScriptName" />',
													dataIndex : 'binScriptName',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.setScriptName" />',
													dataIndex : 'setScriptName',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.initScriptName" />',
													dataIndex : 'initScriptName',
													sortable : true,
													width : 200
												} ],
										// 定义按钮工具条
										tbar : new Ext.Toolbar({
											items : [ '-' ]
										}),
										// 定义分页工具条										bbar : new Ext.PagingToolbar({
											store : this.nshgridStore,
											displayInfo : true,
											pageSize : 100
										})
									});
							// 实例化查询表单							this.form = new Ext.FormPanel(
									{
										region : 'east',
										title : '<fmt:message key="button.find" />',
										labelAlign : 'right',
										labelWidth : 80,
										buttonAlign : 'center',
										frame : true,
										split : true,
										width : 250,
										minSize : 200,
										maxSize : 300,
										autoScroll : true,
										collapsible : true,
										collapseMode : 'mini',
										border : false,
										defaults : {
											anchor : '100%',
											msgTarget : 'side'
										},
										// 定义查询表单组件
										items : [
										         {
													xtype : 'combo',
													fieldLabel : '操作系统类型',
													displayField : 'name',
													valueField : 'value',
													hiddenName : 'osType',
													typeAhead : true,
													//forceSelection : true,
													store : os_typeStore,
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
												},
												{
													xtype : 'combo',
													fieldLabel : '专业领域分类',
													displayField : 'name',
													valueField : 'value',
													hiddenName : 'fieldType',
													typeAhead : true,
													//forceSelection : true,
													store : this.fieldTypeStore,
													tabIndex : this.tabIndex++,
													mode : 'local',
													triggerAction : 'all',
													editable : true,
													allowBlank : true
												},{
												xtype : 'textfield',
												fieldLabel : '脚本名称',
												name : 'scriptName',
												maxLength : 30 ,
												tabIndex : this.tabIndex++
												}],
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
							// 设置基类属性							ScriptUploadIndexList.superclass.constructor.call(this, {
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
									});
						},
						OsType : function(value) {
							var index = os_typeStore.find('value', value);
							if (index == -1) {
								return name;
							} else {
								return os_typeStore.getAt(index).get('name');
							}
						},
						// 查询事件
						doFind : function() {
							Ext.apply(this.grid.getStore().baseParams,
									this.form.getForm().getValues());
							this.grid.getStore().load();
						},
						// 重置查询表单
						doReset : function() {
							this.form.getForm().reset();
						},
						// 新建事件
						doCreate : function() {
							app.loadTab('add_scriptUpload','<fmt:message key="property.scriptUploadCreate" />',
											'${ctx}/${managePath}/scriptUpload/create');
						},
						// 编辑事件
						doEdit : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
										osType : record.get('osType'),
										fieldType : record.get('fieldType'),
										binScriptName : record.get('binScriptName'),
										setScriptName : record.get('setScriptName'),
										initScriptName : record.get('initScriptName')
								};
								app.loadTab('edit_scriptUpload','<fmt:message key="property.nshJobEdit" />',
												'${ctx}/${managePath}/scriptUpload/edit',params);
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.only" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						},
						// 删除事件
						doDelete : function() {
							if (this.grid.getSelectionModel().getCount() > 0) {
								var records = this.grid.getSelectionModel()
										.getSelections();
								var osTypes = new Array();
								var fieldTypes = new Array();
								var binScriptNames = new Array();
								var setScriptNames = new Array();
								var initScriptNames = new Array();
								for ( var i = 0; i < records.length; i++) {
									osTypes[i] = records[i].get('osType');
									fieldTypes[i] = records[i].get('fieldType');
									binScriptNames[i] = records[i].get('binScriptName');
									setScriptNames[i] = records[i].get('setScriptName');
									initScriptNames[i] = records[i].get('initScriptName');
								}
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.confirm.to.delete" />',
											buttons : Ext.MessageBox.OKCANCEL,
											icon : Ext.MessageBox.QUESTION,
											minWidth : 200,
											scope : this,
											fn : function(buttonId) {
												if (buttonId == 'ok') {
													app.mask.show();
													Ext.Ajax.request({
																url : '${ctx}/${managePath}/scriptUpload/delete',
																timeout : 10000000,
																scope : this,
																success : this.deleteSuccess,
																failure : this.deleteFailure,
																params : {
																	osTypes : osTypes,
																	fieldTypes : fieldTypes,
																	binScriptNames : binScriptNames,
																	setScriptNames : setScriptNames,
																	initScriptNames : initScriptNames,
																	_method : 'delete'
																}
															});
												}
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
								this.grid.getStore().reload();// 重新加载数据源
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.successful" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO
										});
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

	var scriptUploadIndexList = new ScriptUploadIndexList();
</script>
<sec:authorize access="hasRole('CHECK_INIT_CREATE')">
	<script type="text/javascript">
		scriptUploadIndexList.grid.getTopToolbar().add({
			iconCls : 'button-add',
			text : '<fmt:message key="button.create" />',
			scope : scriptUploadIndexList,
			handler : scriptUploadIndexList.doCreate
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('CHECK_INIT_EDIT')">
	<script type="text/javascript">
		scriptUploadIndexList.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '<fmt:message key="button.edit" />',
			scope : scriptUploadIndexList,
			handler : scriptUploadIndexList.doEdit
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('CHECK_INIT_DELETE')">
	<script type="text/javascript">
		scriptUploadIndexList.grid.getTopToolbar().add({
			iconCls : 'button-delete',
			text : '<fmt:message key="button.delete" />',
			scope : scriptUploadIndexList,
			handler : scriptUploadIndexList.doDelete
		}, '-');
	</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("SCRIPT_UPLOAD").add(scriptUploadIndexList);
	Ext.getCmp("SCRIPT_UPLOAD").doLayout();
</script>

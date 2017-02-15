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
	var grinshgridStore;
	var os_typeStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	//定义列表
	ScriptDeployIndexList = Ext.extend(Ext.Panel,
					{
						nshgridStore : null,// 数据列表数据源
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
						jobTypeStore.load();
						Ext.apply(this, cfg);
						// 实例化数据列表选择框组件
						csm = new Ext.grid.CheckboxSelectionModel();
						//专业领域分类
							this.fieldTypeStore = new Ext.data.JsonStore(
									{
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
													url : '${ctx}/${managePath}/scriptDeploy/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'osType', 'fieldType','checkItemCode',
												'checkItemName',
												'binScriptName',
												'setScriptName',
												'initScriptName' ],
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
							// 实例化数据列表组件

							this.grid = new Ext.grid.GridPanel(
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
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												{
													header : '<fmt:message key="property.osType" />',
													dataIndex : 'osType',
													sortable : true,
													renderer : this.OsType
												},
												{
													header : '<fmt:message key="property.osType" />',
													dataIndex : 'checkItemCode',
													sortable : true,
													hidden : true
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
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.nshgridStore,
											displayInfo : true,
											pageSize : 100
										})
									});

							// 实例化查询表单

							this.form = new Ext.FormPanel(
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
												}, {
													xtype : 'textfield',
													fieldLabel : '巡检项名称',
													name : 'checkItemName',
													maxLength : 30,
													tabIndex : this.tabIndex++
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
							// 设置基类属性
							ScriptDeployIndexList.superclass.constructor.call(this, {
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
							Ext.apply(this.grid.getStore().baseParams,this.form.getForm().getValues());
							this.grid.getStore().load();
						},
						// 重置查询表单
						doReset : function() {
							this.form.getForm().reset();
						},
						// 新建事件
						doExe : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
										osType : record.get('osType'),
										checkItemCode : record.get('checkItemCode'),
										binScriptName : record.get('binScriptName'),
										fieldType : record.get('fieldType')
								};
								app.loadTab('add_scriptDeploy','下发',
										'${ctx}/${managePath}/scriptDeploy/deploy',params);
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.only" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						}
					});

	var scriptDeployIndexList = new ScriptDeployIndexList();
</script>
<sec:authorize access="hasRole('CHECK_INIT_DEPLOY')">
	<script type="text/javascript">
		scriptDeployIndexList.grid.getTopToolbar().add({
			iconCls : 'button-start',
			text : '下发',
			scope : scriptDeployIndexList,
			handler : scriptDeployIndexList.doExe
		}, '-');
	</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("SCRIPT_DEPLOY").add(scriptDeployIndexList);
	Ext.getCmp("SCRIPT_DEPLOY").doLayout();
</script>

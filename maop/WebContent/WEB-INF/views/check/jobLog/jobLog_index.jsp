<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//容量风险分类
	var checkLogTypeStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/CHECK_LOG_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var grinshgridStore	;
	var checkJobStatusStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/CHECK_JOB_STATUS/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
	//定义列表
	ScriptUploadIndexList = Ext.extend(Ext.Panel,
					{
						nshgridStore : null,// 数据列表数据源						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序						csm : null,// 数据列表选择框组件						constructor : function(cfg) {// 构造方法							checkLogTypeStore.load();
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
							checkJobStatusStore.load();
							// 实例化数据列表数据源
							this.nshgridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/jobLog/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'checkJobName','scriptName','jobType','checkJobStatus', 'checkJobExecuter',
												'jobStartTime','jobEndTime'],
										remoteSort : true,
										sortInfo : {
											field : 'checkJobName',
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
													header : '作业名称',
													dataIndex : 'checkJobName',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.scriptName" />',
													dataIndex : 'scriptName',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.jobType" />',
													dataIndex : 'jobType',
													sortable : true,
													width : 140,
													renderer : this.checkJobType
												},
												{
													header : '作业状态',
													dataIndex : 'checkJobStatus',
													sortable : true,
													width : 80
												},
												{
													header : '执行人',
													dataIndex : 'checkJobExecuter',
													sortable : true,
													width : 70
												},
												{
													header : '作业开始时间',
													dataIndex : 'jobStartTime',
													sortable : true,
													width : 200
												},
												{
													header : '作业结束时间',
													dataIndex : 'jobEndTime',
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
										}),
										listeners : {
											scope : this,
											// 行双击事件：打开数据查看页面
											rowdblclick : this.doView
										}
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
												xtype : 'textfield',
												fieldLabel : '作业名称',
												name : 'checkJobName',
												maxLength : 30 ,
												tabIndex : this.tabIndex++
												},{
													xtype : 'combo',
													fieldLabel : '作业状态',
													displayField : 'name',
													valueField : 'name',
													hiddenName : 'checkJobStatus',
													typeAhead : true,
													//forceSelection : true,
													store : checkJobStatusStore,
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
													fieldLabel : '作业类型',
													displayField : 'name',
													valueField : 'value',
													hiddenName : 'jobType',
													typeAhead : true,
													//forceSelection : true,
													store : checkLogTypeStore,
													tabIndex : this.tabIndex++,
													mode : 'local',
													triggerAction : 'all',
													editable : true,
													allowBlank : true
												},
												{
													xtype : 'datefield',
													fieldLabel : '<fmt:message key="property.execStartTime" />',
													name : 'jobStartTime',
													format : 'Ymd'
												},
												{
													xtype : 'datefield',
													fieldLabel : '<fmt:message key="property.execCompletedTime" />',
													name : 'jobEndTime',
													format : 'Ymd'
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
						
						checkJobType : function(value) {
							var index = checkLogTypeStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return checkLogTypeStore.getAt(index).get('name');
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
						doView : function() {
						 	var record = this.grid.getSelectionModel().getSelected();
							var params = {
								checkJobName : record.get('checkJobName')
							}; 
							app.loadTab('add_CmnEnvironment1','详细日志',
									'${ctx}/${managePath}/jobLog/view' ,params );
							//app.loadWindow('${ctx}/${managePath}/dplysystemlog/view',params);
						}
					});

	var scriptUploadIndexList = new ScriptUploadIndexList();
</script>
<script type="text/javascript">
	Ext.getCmp("JOB_LOG").add(scriptUploadIndexList);
	Ext.getCmp("JOB_LOG").doLayout();
</script>

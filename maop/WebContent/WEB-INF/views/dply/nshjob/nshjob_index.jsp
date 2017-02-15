<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var nshindexsysIdsStore = new Ext.data.Store(
			{
				proxy : new Ext.data.HttpProxy(
						{
							url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
							method : 'GET',
							disableCaching : true
						}),
				reader : new Ext.data.JsonReader({}, [ 'appsysCode',
						'appsysName' ]),
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
	//容量风险分类
	var jobTypeStore = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/JOB_TYPE/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var grinshgridStore	;
	/* var mask = new Ext.LoadMask(Ext.getBody(), {
		msg : '进行中，请稍候...',
		removeMask : true
	}); */
	//定义列表
	NshJobIndexList = Ext.extend(Ext.Panel,
					{
						nshgridStore : null,// 数据列表数据源
						//grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
							nshindexsysIdsStore.load();
							jobTypeStore.load();
							Ext.apply(this, cfg);
							// 实例化数据列表选择框组件
							csm = new Ext.grid.CheckboxSelectionModel();
							// 实例化数据列表数据源
							this.nshgridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/nshjob/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'appsysCode',
												'jobName',
												'jobType',
												'jobPath', 'jobParentGroup',
												'scriptBlpackageName', 'jobCreator','jobCreated','jobModifier','jobModified'],
										remoteSort : true,
										sortInfo : {
											field : 'appsysCode',
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
										id : 'NshJobIndexListGridPanel',
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
													header : '<fmt:message key="property.appSys" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 150,
													renderer : this.nshAppsys_Store
												},
												{
													header : '<fmt:message key="property.jobParentGroup" />',
													dataIndex : 'jobParentGroup',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.jobNames" />',
													dataIndex : 'jobName',
													sortable : true,
													width : 100
												},
												{
													header : '<fmt:message key="property.jobType" />',
													dataIndex : 'jobType',
													sortable : true,
													width : 150,
													hidden : true
												},
												{
													header : '<fmt:message key="property.scriptBlpackageName" />',
													dataIndex : 'scriptBlpackageName',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.jobCreator" />',
													dataIndex : 'jobCreator',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.jobCreated" />',
													dataIndex : 'jobCreated',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.jobModifier" />',
													dataIndex : 'jobModifier',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.jobModified" />',
													dataIndex : 'jobModified',
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
										minSize : 300,
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
													fieldLabel : '<fmt:message key="property.appSys" />',
													id : 'nshAppsysCodeId',
													displayField : 'appsysName',
													valueField : 'appsysCode',
													hiddenName : 'appsysCode',
													typeAhead : true,
													//forceSelection : true,
													store : nshindexsysIdsStore,
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
													store : jobTypeStore,
													fieldLabel : "<fmt:message key="property.jobType" />",
													name : 'jobType',
													valueField : 'value',
													displayField : 'name',
													hiddenName : 'jobType',
													mode : 'local',
													triggerAction : 'all',
													forceSelection : true,
													editable : false,
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
							NshJobIndexList.superclass.constructor.call(this, {
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
									});
						},
						nshAppsys_Store : function(value) {
							var index = nshindexsysIdsStore.find('appsysCode', value);
							if (index == -1) {
								return value;
							} else {
								return nshindexsysIdsStore.getAt(index).get('appsysName');
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
							app.loadTab('add_NshJob','<fmt:message key="property.nshJobCreate" />',
											'${ctx}/${managePath}/nshjob/create');
						},
						// 编辑事件
						doEdit : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
									appsysCode : record.get('appsysCode'),
									jobParentGroup : record.get('jobParentGroup'),
									scriptBlpackageName : record.get('scriptBlpackageName'),
									jobName  : record.get('jobName')
								};
								var jobname = record.get('jobName').substring(record.get('jobName').lastIndexOf('_') );
								if( jobname.toLowerCase() == '_allfiles' ){
									Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.canNotEdit" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200
									});
									return false;
								}  
								app.loadTab('edit_NshJob','<fmt:message key="property.nshJobEdit" />',
												'${ctx}/${managePath}/nshjob/edit',params);
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
							if (this.grid.getSelectionModel().getCount() >0) {
								var records = this.grid.getSelectionModel()
										.getSelections();
								var appsysCodes = new Array();
								var jobParentGroups = new Array();
								var scriptBlpackageNames = new Array();
								var jobNames = new Array();
								
								if(this.grid.getSelectionModel().getCount() ==1){
									
								for ( var i = 0; i < records.length; i++) {
									appsysCodes[i] = records[i].get('appsysCode');
									jobParentGroups[i] = records[i].get('jobParentGroup');
									scriptBlpackageNames[i] = records[i].get('scriptBlpackageName');
									jobNames[i] = records[i].get('jobName');
									var jobName = jobNames[i].substring(jobNames[i].lastIndexOf('_') );
									if( jobName.toLowerCase() == '_allfiles' ){
										Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.canNotDelete" />,所有人工构建作业删除后，会自动删除ALLFILES作业。',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
										return false;
									} 
								}
								}else{
									var k=0;
									for ( var i = 0; i < records.length; i++) {
										var jobName = records[i].get('jobName').substring(records[i].get('jobName').lastIndexOf('_') );
										if( jobName.toLowerCase() != '_allfiles' ){
											appsysCodes[k] = records[i].get('appsysCode');
											jobParentGroups[k] = records[i].get('jobParentGroup');
											scriptBlpackageNames[k] = records[i].get('scriptBlpackageName');
											jobNames[k] = records[i].get('jobName');
											k++;
										} 
									}
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
																url : '${ctx}/${managePath}/nshjob/delete',
																timeout : 10000000,
																scope : this,
																success : this.deleteSuccess,
																failure : this.deleteFailure,
																params : {
																	appsysCodes : appsysCodes,
																	jobParentGroups : jobParentGroups,
																	scriptBlpackageNames : scriptBlpackageNames,
																	jobNames : jobNames,
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

	var nshJobIndexList = new NshJobIndexList();
</script>
<sec:authorize access="hasRole('RELEASE_CREATE')">
	<script type="text/javascript">
		nshJobIndexList.grid.getTopToolbar().add({
			iconCls : 'button-add',
			text : '<fmt:message key="button.create" />',
			scope : nshJobIndexList,
			handler : nshJobIndexList.doCreate
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('RELEASE_EDIT')">
	<script type="text/javascript">
		nshJobIndexList.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '<fmt:message key="button.edit" />',
			scope : nshJobIndexList,
			handler : nshJobIndexList.doEdit
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('RELEASE_DELETE')">
	<script type="text/javascript">
		nshJobIndexList.grid.getTopToolbar().add({
			iconCls : 'button-delete',
			text : '<fmt:message key="button.delete" />',
			scope : nshJobIndexList,
			handler : nshJobIndexList.doDelete
		}, '-');
	</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("DplyNshJob").add(nshJobIndexList);
	Ext.getCmp("DplyNshJob").doLayout();
</script>

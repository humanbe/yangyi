<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var envindexsysIdsStore = new Ext.data.Store(
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
	var environmentTypeStore = new Ext.data.Store({
		proxy : new Ext.data.HttpProxy(
				{
					url : '${ctx}/${managePath}/cmnenvironment/queryENV',
					method : 'GET',
					disableCaching : true
				}),
		reader : new Ext.data.JsonReader({}, [ 'NAME','ENV' ])
	});
	var gridStore;
	var mask = new Ext.LoadMask(Ext.getBody(), {
		msg : '进行中，请稍候...',
		removeMask : true
	});
	//定义列表
	CmnEnvironmentIndexList = Ext.extend(Ext.Panel,
					{
						gridStore : null,// 数据列表数据源
						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
							envindexsysIdsStore.load();
							environmentTypeStore.load();
							Ext.apply(this, cfg);
							// 实例化数据列表选择框组件
							csm = new Ext.grid.CheckboxSelectionModel();
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/cmnenvironment/index',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'appsysCode',
												'environmentCode',
												'environmentName',
												'environmentType', 'describe',
												'deleteFlag' ],
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
							this.gridStore.load();
							// 实例化数据列表组件
							this.grid = new Ext.grid.GridPanel(
									{
										id : 'CmnEnvironmentIndexListGridPanel',
										region : 'center',
										border : false,
										loadMask : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										store : this.gridStore,
										sm : csm,
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												{
													header : '<fmt:message key="toolbox.appsys_code" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 150,
													renderer : this.envAppsys_Store
												},
												{
													header : '<fmt:message key="property.environmentCode" />',
													dataIndex : 'environmentCode',
													sortable : true,
													width : 100
												},
												{
													header : '<fmt:message key="property.environmentName" />',
													dataIndex : 'environmentName',
													sortable : true,
													width : 150
												},
												{
													header : '<fmt:message key="property.environmentType" />',
													dataIndex : 'environmentType',
													sortable : true,
													width : 120
												},
												{
													header : '<fmt:message key="property.describe" />',
													dataIndex : 'describe',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.deleteFlag" />',
													dataIndex : 'deleteFlag',
													sortable : true,
													width : 200,
													hidden : true
												} ],
										// 定义按钮工具条
										tbar : new Ext.Toolbar({
											items : [ '-' ]
										}),
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
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
													fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
													displayField : 'appsysName',
													valueField : 'appsysCode',
													hiddenName : 'appsysCode',
													typeAhead : true,
													//forceSelection : true,
													store : envindexsysIdsStore,
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
													store : environmentTypeStore,
													fieldLabel : "<fmt:message key="property.environmentType" />",
													name : 'environmentType',
													valueField : 'NAME',
													displayField : 'NAME',
													hiddenName : 'environmentType',
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
							CmnEnvironmentIndexList.superclass.constructor.call(this, {
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
									});
						},
						envAppsys_Store : function(value) {

							var index = envindexsysIdsStore.find('appsysCode', value);
							if (index == -1) {
								return value;
							} else {
								return envindexsysIdsStore.getAt(index).get('appsysName');
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
							app.loadTab('add_CmnEnvironment','<fmt:message key="property.cmnenvironmentCreate" />',
											'${ctx}/${managePath}/cmnenvironment/create');

						},
						
						doAppCheckEdit : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
									appsysCode : record.get('appsysCode'),
									environmentCode : record.get('environmentCode')

								};
								app.loadTab('APP_CHECK_DESIGN','应用巡检配置',
												'${ctx}/${managePath}/appcheckdesign/app_check_design',params);
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.only" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						},
						// 编辑事件
						doEdit : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
									appsysCode : record.get('appsysCode'),
									environmentCode : record.get('environmentCode')

								};
								app.loadTab('edit_CmnEnvironment','<fmt:message key="property.cmnenvironmentEdit" />',
												'${ctx}/${managePath}/cmnenvironment/edit',params);
							} else {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.select.one.only" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							}
						},
						// BRPM同步
						doBrpm : function() {
							if (this.grid.getSelectionModel().getCount() > 0) {
								var records = this.grid.getSelectionModel().getSelections();
								var environmentCodes = new Array();
								var appsysCodes = new Array();
								var json = [];
								for ( var i = 0; i < records.length; i++) {
									environmentCodes[i] = records[i].get('environmentCode');
									appsysCodes[i] = records[i].get('appsysCode');
									json.push(environmentCodes[i] + '|+|' + appsysCodes[i]);
								}
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.confirm.to.brpm1" />',
											buttons : Ext.MessageBox.OKCANCEL,
											icon : Ext.MessageBox.QUESTION,
											timeout : 300000,
											minWidth : 200,
											scope : this,
											fn : function(btn) {
												if (btn == 'ok') {
													app.mask.show();
													Ext.Ajax.request({
																url : '${ctx}/${managePath}/cmnenvironment/synbrpm',
																method : 'POST',
																scope : this,
																timeout : 300000,
																success : this.sysSuccess,
																failure : this.sysFailure,
																disableCaching : true,
																params : {
																	data : Ext.util.JSON.encode(json)
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
						doWan : function() {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.confirm.to.brpm" />',
										buttons : Ext.MessageBox.OKCANCEL,
										icon : Ext.MessageBox.QUESTION,
										minWidth : 200,
										scope : this,
										fn : function(btn) {
											if (btn == 'ok') {
												app.mask.show();
												Ext.Ajax.request({
															url : '${ctx}/${managePath}/cmnenvironment/synenv',
															method : 'POST',
															scope : this,
															success : this.sysSuccess,
															failure : this.sysFailure,
															disableCaching : true
														});
											}
										}
									});
						}, 
						doBsa : function() {
							if (this.grid.getSelectionModel().getCount() > 0) {
								var records = this.grid.getSelectionModel().getSelections();
								var environmentCodes = new Array();
								var appsysCodes = new Array();
								var json = [];
								for ( var i = 0; i < records.length; i++) {
									environmentCodes[i] = records[i].get('environmentCode');
									appsysCodes[i] = records[i].get('appsysCode');
									json.push(environmentCodes[i] + '|+|' + appsysCodes[i]);
								}

								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.confirm.to.bsa" />',
											buttons : Ext.MessageBox.OKCANCEL,
											icon : Ext.MessageBox.QUESTION,
											timeout : 300000,
											minWidth : 200,
											scope : this,
											fn : function(btn) {
												if (btn == 'ok') {
													app.mask.show();
													Ext.Ajax.request({
																url : '${ctx}/${managePath}/cmnenvironment/synbsa',
																method : 'POST',
																scope : this,
																success : this.sysSuccess,
																failure : this.sysFailure,
																disableCaching : true,
																params : {
																	data : Ext.util.JSON.encode(json)
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
						// 删除事件
						doDelete : function() {
							if (this.grid.getSelectionModel().getCount() > 0) {
								var records = this.grid.getSelectionModel()
										.getSelections();
								var appsysCodes = new Array();
								var environmentCodes = new Array();
								for ( var i = 0; i < records.length; i++) {
									appsysCodes[i] = records[i].get('appsysCode');
									environmentCodes[i] = records[i].get('environmentCode');
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
																url : '${ctx}/${managePath}/cmnenvironment/delete',
																scope : this,
																success : this.deleteSuccess,
																failure : this.deleteFailure,
																params : {
																	appsysCodes : appsysCodes,
																	environmentCodes : environmentCodes,
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
						},
						doExport : function() {
							window.location = '${ctx}/${managePath}/batchovertimeana/export.xls';
						},
						//保存成功回调
						exportSuccess : function(form, action) {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.successful" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO
									});
						},
						// 保存失败回调
						exportFailure : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						},
						//保存成功
						sysSuccess : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							} else if (Ext.decode(response.responseText).success == true) {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.sys.successful" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO
										});
							}
						},
						// 保存失败回调
						sysFailure : function(form, action) {
							app.mask.hide();
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});

	var cmnEnvironmentIndexList = new CmnEnvironmentIndexList();
</script>
<sec:authorize access="hasRole('ENV_CREATE')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-add',
			text : '<fmt:message key="button.create" />',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doCreate
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('ENV_EDIT')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '<fmt:message key="button.edit" />',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doEdit
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('ENV_DELETE')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-delete',
			text : '<fmt:message key="button.delete" />',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doDelete
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('RELEASE_BRPM_SYNC')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-sync',
			text : '<fmt:message key="button.brpm" />',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doBrpm
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('RELEASE_BSA_SYNC')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-sync',
			text : '<fmt:message key="button.bsa" />',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doBsa
		}, '-');
	</script>
</sec:authorize>

<sec:authorize access="hasRole('APP_CHECK_DESIGN')">
	<script type="text/javascript">
		cmnEnvironmentIndexList.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '应用巡检配置',
			scope : cmnEnvironmentIndexList,
			handler : cmnEnvironmentIndexList.doAppCheckEdit
		
		}, '-');
	</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("CmnEnvironment").add(cmnEnvironmentIndexList);
	Ext.getCmp("CmnEnvironment").doLayout();
</script>
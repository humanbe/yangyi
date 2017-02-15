<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var groupSysIdsStore = new Ext.data.Store(
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
	var groupType = new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
	});
	var groupGridStore;
	var mask1 = new Ext.LoadMask(Ext.getBody(), {
		msg : '进行中，请稍候...',
		removeMask : true
	});
	//定义列表
	groupIndexList = Ext.extend(Ext.Panel,
					{
						groupGridStore : null,// 数据列表数据源
						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单组件Tab键顺序
						csm : null,// 数据列表选择框组件
						constructor : function(cfg) {// 构造方法
							groupSysIdsStore.load();
							groupType.load();
							Ext.apply(this, cfg);
							// 实例化数据列表选择框组件
							csm = new Ext.grid.CheckboxSelectionModel();
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/nshjob/groupIndex',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'appsysCode',
												'serviceName',
												'serverGroup'],
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
										id : 'groupIndexListGridPanel',
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
													header : '<fmt:message key="property.appSys" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 250,
													renderer : this.nshGroupAppsys_Store
												},
												{
													header : '<fmt:message key="property.sericeName" />',
													dataIndex : 'serviceName',
													sortable : true,
													width : 250
												},
												{
													header : '<fmt:message key="propertyGroup.serverGroup" />',
													dataIndex : 'serverGroup',
													sortable : true,
													width : 200/* ,
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '1':
															return 'WEB';
														case '2':
															return 'APP';
														case '3':
															return 'DB';
														}
													}
				 */								}],
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
										id : 'nshGroupIndexFindFormPanel',
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
													id : 'groupAppsyscodeId',
													displayField : 'appsysName',
													valueField : 'appsysCode',
													hiddenName : 'appsysCode',
													typeAhead : true,
													//forceSelection : true,
													store : groupSysIdsStore,
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
													store : groupType,
													fieldLabel : "<fmt:message key="property.serverGroup" />",
													name : 'serverGroup',
													valueField : 'value',
													displayField : 'name',
													hiddenName : 'serverGroup',
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
							groupIndexList.superclass.constructor.call(this, {
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
									});
						},
						nshGroupAppsys_Store : function(value) {
							var index = groupSysIdsStore.find('appsysCode', value);
							if (index == -1) {
								return value;
							} else {
								return groupSysIdsStore.getAt(index).get('appsysName');
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
							app.loadTab('add_group','<fmt:message key="property.groupCreate" />',
											'${ctx}/${managePath}/nshjob/groupCreate');
						},
						// 编辑事件
						doEdit : function() {
							if (this.grid.getSelectionModel().getCount() == 1) {
								var record = this.grid.getSelectionModel().getSelected();
								var params = {
									appsysCode : record.get('appsysCode'),
									serverGroup : record.get('serverGroup')
								};
								app.loadTab('edit_NshGroup','<fmt:message key="property.nshGroupEdit" />',
												'${ctx}/${managePath}/nshjob/groupEdit',params);
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

	var groupindexList = new groupIndexList();
</script>
<sec:authorize access="hasRole('RELEASE_CREATE')">
	<script type="text/javascript">
		groupindexList.grid.getTopToolbar().add({
			iconCls : 'button-add',
			text : '<fmt:message key="button.create" />',
			scope : groupindexList,
			handler : groupindexList.doCreate
		}, '-');
	</script>
</sec:authorize>
<sec:authorize access="hasRole('RELEASE_EDIT')">
	<script type="text/javascript">
		groupindexList.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '<fmt:message key="button.edit" />',
			scope : groupindexList,
			handler : groupindexList.doEdit
		}, '-');
	</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("DplyGroup").add(groupindexList);
	Ext.getCmp("DplyGroup").doLayout();
</script>

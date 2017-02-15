<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义列表
AppChangeProgressDetail = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/appchangemanage/progressDetail',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['aplCode', 'changeMonth', 'changeDate' , 'eapsCode', 'changeName', 
			          	 'changeGrantNo', 'dplyLocation', 'planStartDate', 'planStartTime', 
			          	 'actualStartTime', 'planEndDate', 'planEndTime', 'actualEndDate',
			          	 'actualEndTime', 'endFlag', 'develop', 'changeType', 'changeTable', 
			             'lastRebootDate', 'nowRebootTime', 'rebootExecInfo', 'verifyInfo',
			             'operation', 'maintainTomo', 'reviewer', 'appA', 'appChangeId'],
			baseParams : {
				changeMonth : '${param.changeMonth}',
				aplCodes : '${param.aplCodes}',
				status : decodeURIComponent('${param.status}'),
				progress : decodeURIComponent('${param.progress}')
			}
		});
		this.gridStore.load();

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), 
				{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', sortable : true},
				{header : '<fmt:message key="property.changeMonth" />', dataIndex : 'changeMonth', sortable : true},
				{header : '<fmt:message key="property.changeDate" />', dataIndex : 'changeDate', sortable : true},
				{header : '<fmt:message key="property.changeCode" />', dataIndex : 'eapsCode', sortable : true},
				{header : '<fmt:message key="property.changeName" />', dataIndex : 'changeName', sortable : true},
				{header : '<fmt:message key="property.changeGrantNo" />', dataIndex : 'changeGrantNo', sortable : true},
				{header : '<fmt:message key="property.dplyLocation" />', dataIndex : 'dplyLocation', sortable : true},
				{header : '<fmt:message key="property.planStartDate" />', dataIndex : 'planStartDate', sortable : true},
				{header : '<fmt:message key="property.planStartTime" />', dataIndex : 'planStartTime', sortable : true},
				{header : '<fmt:message key="property.actualStartTime" />', dataIndex : 'actualStartTime', sortable : true},
				{header : '<fmt:message key="property.planEndDate" />', dataIndex : 'planEndDate', sortable : true},
				{header : '<fmt:message key="property.planEndTime" />', dataIndex : 'planEndTime', sortable : true},
				{header : '<fmt:message key="property.actualEndDate" />', dataIndex : 'actualEndDate', sortable : true},
				{header : '<fmt:message key="property.actualEndTime" />', dataIndex : 'actualEndTime', sortable : true},
				{header : '<fmt:message key="property.endFlag" />', dataIndex : 'endFlag', sortable : true},
				{header : '<fmt:message key="property.appadminidA" />', dataIndex : 'appA', sortable : true},
				{header : '<fmt:message key="property.projectChangeLeader" />', dataIndex : 'develop', sortable : true},
				{header : '<fmt:message key="property.changeType" />', dataIndex : 'changeType', sortable : true},
				{header : '<fmt:message key="property.changeTable" />', dataIndex : 'changeTable', sortable : true},
				{header : '<fmt:message key="property.lastRebootDate" />', dataIndex : 'lastRebootDate', sortable : true},
				{header : '<fmt:message key="property.nowRebootTime" />', dataIndex : 'nowRebootTime', sortable : true},
				{header : '<fmt:message key="property.rebootExecInfo" />', dataIndex : 'rebootExecInfo', sortable : true},
				{header : '<fmt:message key="property.verifyInfo" />', dataIndex : 'verifyInfo', sortable : true},
				{header : '<fmt:message key="property.operation" />', dataIndex : 'operation', sortable : true},
				{header : '<fmt:message key="property.maintainTomo" />', dataIndex : 'maintainTomo', sortable : true},
				{header : '<fmt:message key="property.reviewer" />', dataIndex : 'reviewer', sortable : true}
	  		],
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});

		// 设置基类属性		AppChangeProgressDetail.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [this.grid ]
		});
	},
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			appChangeId: record.get('appChangeId')
		};
		var tab = Ext.getCmp("view_AppChangeManage");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.appChangeInfo" />');
		}
		app.loadTab('view_AppChangeManage', 
				'<fmt:message key="button.view" /><fmt:message key="property.appChangeInfo" />', 
				'${ctx}/${managePath}/appchangemanage/view', 
				params);
	}
});

Ext.getCmp("view_AppChangeManageProgressDetail").add(new AppChangeProgressDetail());
Ext.getCmp("view_AppChangeManageProgressDetail").doLayout();
</script>

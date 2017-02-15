<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplCodesStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/monitorwarn/queryAplCodes',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['aplCode'])
});
//定义列表
MonitorWarnList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		aplCodesStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/monitorwarn/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['aplCode', 'changeDate', 'monitorEffectContent', 'deviceName', 
			             'ipAddress', 'explainDevice', 'explainMonitorPlatform', 'explainMonitorTool',
			             'explainMonitorScreen', 'effectStartTime', 'effectEndTime'],
			remoteSort : true,
			sortInfo : {
				field : 'aplCode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			},
			listeners : {
				'load' : function(store){
					if(store.getCount() > 0){
						Ext.getCmp('MonitorWarnIndexExcel').enable();
					}else{
						Ext.getCmp('MonitorWarnIndexExcel').disable();
					}
				}
			}
		});

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'MonitorWarnListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', sortable : true},
				{header : '<fmt:message key="property.changeDate" />', dataIndex : 'changeDate', sortable : true},
				{header : '<fmt:message key="property.monitorEffectContent" />', dataIndex : 'monitorEffectContent', sortable : true},
				{header : '<fmt:message key="property.deviceName" />', dataIndex : 'deviceName', sortable : true},
				{header : '<fmt:message key="property.ipAddress" />', dataIndex : 'ipAddress', sortable : true},
				{header : '<fmt:message key="property.explainDevice" />', dataIndex : 'explainDevice', sortable : true},
				{header : '<fmt:message key="property.explainMonitorPlatform" />', dataIndex : 'explainMonitorPlatform', sortable : true},
				{header : '<fmt:message key="property.explainMonitorTool" />', dataIndex : 'explainMonitorTool', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '不忽略告警';
							case '1' : return '忽略告警';
						}
					}
				},
				{header : '<fmt:message key="property.explainMonitorScreen" />', dataIndex : 'explainMonitorScreen', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '不忽略告警';
							case '1' : return '忽略告警';
						}
					}
				},
				{header : '<fmt:message key="property.effectStartTime" />', dataIndex : 'effectStartTime', sortable : true},
				{header : '<fmt:message key="property.effectEndTime" />', dataIndex : 'effectEndTime', sortable : true}
	  		],
	  		
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					id : 'MonitorWarnIndexExcel',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					disabled : true,
					handler : this.doExportXLS
				} ]
			}),
			
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});

		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'MonitorWarnFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 110,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
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
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					store : aplCodesStore,
					displayField : 'aplCode',
					name : 'apl_code',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.changeMonth" />',
					plugins: 'monthPickerPlugin',
					format :'Ym',
					name : 'change_date'
				}
			],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			} ]
		});

		// 设置基类属性		MonitorWarnList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
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
	// 新建事件
	doCreate : function() {
		app.loadTab('add_MonitorWarn', 
				'<fmt:message key="button.create" /><fmt:message key="property.monitorWarnInfo" />', 
				'${ctx}/${managePath}/monitorwarn/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			aplCode : record.get('aplCode'),
			changeDate : record.get('changeDate')
		};
		var tab = Ext.getCmp("view_MonitorWarn");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.monitorWarnInfo" />');
		}
		app.loadTab('view_MonitorWarn', 
				'<fmt:message key="button.view" /><fmt:message key="property.monitorWarnInfo" />', 
				'${ctx}/${managePath}/monitorwarn/view', 
				params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				aplCode : record.get('aplCode'),
				changeDate : record.get('changeDate')
			};
			app.loadTab('edit_MonitorWarn', 
					'<fmt:message key="button.edit" /><fmt:message key="property.monitorWarnInfo" />', 
					'${ctx}/${managePath}/monitorwarn/edit', 
					params);
		} else {
			Ext.Msg.show( {
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
			var records = this.grid.getSelectionModel().getSelections();
			var aplCodes = new Array();
			var changeDates = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i] = records[i].get('aplCode');
				changeDates[i] = records[i].get('changeDate');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.delete" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${managePath}/monitorwarn/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodes : aplCodes,
								changeDates : changeDates,
								_method : 'delete'
							}
						});

					}
				}
			});
		} else {
			Ext.Msg.show( {
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
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();// 重新加载数据源
			Ext.Msg.show( {
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
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.delete.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/monitorwarn/excel.xls';
	},
	//保存成功回调
	exportSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO
		});
	},
	// 保存失败回调
	exportFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

var monitorWarnList = new MonitorWarnList();
</script>

<script type="text/javascript">
monitorWarnList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : monitorWarnList,
	handler : monitorWarnList.doCreate
	},'-');
</script>
<script type="text/javascript">
monitorWarnList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : monitorWarnList,
	handler : monitorWarnList.doEdit
	},'-');
</script>
<script type="text/javascript">
monitorWarnList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : monitorWarnList,
	handler : monitorWarnList.doDelete
	},'-');
</script>
<script type="text/javascript">
Ext.getCmp("MgrMonitorWarnIndex").add(monitorWarnList);
Ext.getCmp("MgrMonitorWarnIndex").doLayout();
</script>

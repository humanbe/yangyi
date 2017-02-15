<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
Ext.apply(Ext.form.VTypes, {
    daterange : function(val, field) {
        var date = field.parseDate(val);

        if(!date){
            return false;
        }
        if (field.startDateField) {
            var start = Ext.getCmp(field.startDateField);
            if (!start.maxValue || (date.getTime() != start.maxValue.getTime())) {
                start.setMaxValue(date);
                start.validate();
            }
        }
        else if (field.endDateField) {
            var end = Ext.getCmp(field.endDateField);
            if (!end.minValue || (date.getTime() != end.minValue.getTime())) {
                end.setMinValue(date);
                end.validate();
            }
        }
        
        return true;
    }
});



var aplCodesStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appchangemanage/queryAplCodes',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['aplCode'])
});
//定义列表
AppChangeManageList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
		aplCodesStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/appchangemanage/index',
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
			remoteSort : true,
			sortInfo : {
				field : 'aplCode, changeMonth',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			},
			listeners : {
				'load' : function(store){
					if(store.getCount() > 0){
						Ext.getCmp('AppChangeManageIndexExcel').enable();
					}else{
						Ext.getCmp('AppChangeManageIndexExcel').disable();
					}
				}
			}
		});

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'AppChangeManageListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
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
				{header : '<fmt:message key="property.endFlag" />', dataIndex : 'endFlag', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '否';
							case '1' : return '是';
							case '2' : return '部分';
						}
					}
				},
				{header : '<fmt:message key="property.appadminidA" />', dataIndex : 'appA', sortable : true},
				{header : '<fmt:message key="property.projectChangeLeader" />', dataIndex : 'develop', sortable : true},
				{header : '<fmt:message key="property.changeType" />', dataIndex : 'changeType', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '1' : return '常规投产';
							case '2' : return '临时投产';
							case '3' : return '临时操作';
							case '4' : return '紧急修复';
						}
					}
				},
				{header : '<fmt:message key="property.changeTable" />', dataIndex : 'changeTable', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '否';
							case '1' : return '是';
							case '2' : return '已归档';
						}
					}
				},
				{header : '<fmt:message key="property.lastRebootDate" />', dataIndex : 'lastRebootDate', sortable : true},
				{header : '<fmt:message key="property.nowRebootTime" />', dataIndex : 'nowRebootTime', sortable : true},
				{header : '<fmt:message key="property.rebootExecInfo" />', dataIndex : 'rebootExecInfo', sortable : true},
				{header : '<fmt:message key="property.verifyInfo" />', dataIndex : 'verifyInfo', sortable : true},
				{header : '<fmt:message key="property.operation" />', dataIndex : 'operation', sortable : true},
				{header : '<fmt:message key="property.maintainTomo" />', dataIndex : 'maintainTomo', sortable : true},
				{header : '<fmt:message key="property.reviewer" />', dataIndex : 'reviewer', sortable : true}
	  		],
	  		
			// 定义按钮工具条
				items : [ '-' ]
			}),
			
			// 定义分页工具条
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					id : 'AppChangeManageIndexExcel',
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

		// 实例化查询表单
			id : 'AppChangeManageFindFormPanel',
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
					name : 'aplCode',
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
					name : 'changeMonth'
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.operation" />',
					name : 'operation'
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.maintainTomo" />',
					name : 'maintainTomo'
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.fromDate" />',
					id : 'AppChangeManageStartDate',
					name : 'changeDateStart',
				
					format : 'Ymd',
					endDateField : 'AppChangeManageEndDate',
					vtype : 'daterange'
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.toDate" />',
					id : 'AppChangeManageEndDate',
					name : 'changeDateEnd',
				
					startDateField : 'AppChangeManageStartDate',
					vtype : 'daterange',
					format : 'Ymd'
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

		// 设置基类属性
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
		app.loadTab('add_AppChangeManage', '<fmt:message key="button.create" /><fmt:message key="property.appChangeInfo" />', '${ctx}/${managePath}/appchangemanage/create');
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
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				appChangeId: record.get('appChangeId')
			};
			app.loadTab('edit_AppChangeManage', '<fmt:message key="button.edit" /><fmt:message key="property.appChangeInfo" />', '${ctx}/${managePath}/appchangemanage/edit', params);
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
			var appChangeIds = new Array();
			for ( var i = 0; i < records.length; i++) {
				appChangeIds[i] = records[i].get('appChangeId');
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
							url : '${ctx}/${managePath}/appchangemanage/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								appChangeIds : appChangeIds,
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
		window.location = '${ctx}/${managePath}/appchangemanage/excel.xls';
	}
});

var appChangeManageList = new AppChangeManageList();
</script>

<script type="text/javascript">
appChangeManageList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : appChangeManageList,
	handler : appChangeManageList.doCreate
	},'-');
</script>
<script type="text/javascript">
appChangeManageList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : appChangeManageList,
	handler : appChangeManageList.doEdit
	},'-');
</script>
<script type="text/javascript">
appChangeManageList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : appChangeManageList,
	handler : appChangeManageList.doDelete
	},'-');
</script>
<script type="text/javascript">
Ext.getCmp("MgrAppChangeManageIndex").add(appChangeManageList);
Ext.getCmp("MgrAppChangeManageIndex").doLayout();
</script>
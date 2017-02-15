<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize = 100;
var sysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appconfigmanage/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
});

var busiSysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/busipersonnelmanage/querySysIds',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysId'])
});

//定义列表
BusiPersonnelManageList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	constructor : function(cfg) {
		sysIdsStore.load();
		busiSysIdsStore.load();
		// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/busipersonnelmanage/index',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['sysId', 'sequence','bpName', 'department','mobile', 'phone', 'email'],
			remoteSort : true,
			sortInfo : {
				field : 'sysId',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			},
			listeners : {
				'load' : function(store, records, opt){
					if(store.getCount() > 0){
						Ext.getCmp('BusiPersonnelManageExport').enable();
					}else{
						Ext.getCmp('BusiPersonnelManageExport').disable();
					}
				}
			}
		});

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'BusiPersonnelManageListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				getRowClass : function(record, rowIndex, rowParams, store){   
					if((rowIndex + 1) % 2 === 0){   
						return 'x-gridSys-row-alt';
					}   
				}
			},
			store : this.gridStore,
			// 列定义			columns : [ new Ext.grid.RowNumberer(),
				{
					header : '<fmt:message key="property.appsyscd" />',
					dataIndex : 'sysId',
					sortable : true,
					width : 80
				},
				{
					header : '<fmt:message key="property.sequence" />',
					dataIndex : 'sequence',
					sortable : true
				},
				{
					header : '<fmt:message key="property.bpName" />',
					dataIndex : 'bpName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.department" />',
					dataIndex : 'department',
					sortable : true
				},
				{
					header : '<fmt:message key="property.mobile" />',
					dataIndex : 'mobile',
					sortable : true
				},
				{
					header : '<fmt:message key="property.phone" />',
					dataIndex : 'phone',
					sortable : true
				},
				{
					header : '<fmt:message key="property.email" />',
					dataIndex : 'email',
					sortable : true
				}
	  		],
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true,
				pageSize : pageSize,
				buttons : [ '-', {
					id : 'BusiPersonnelManageExport',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				}]
			})/* ,
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			} */
		});
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'BusiPersonnelManageFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 105,
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
					store : busiSysIdsStore,
					displayField : 'sysId',
					name : 'sysId',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
			    },
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : sysIdsStore,
					displayField : 'sysName',
					name : 'sysName',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}
			],
			// 定义查询表单按钮
			buttons : [{
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			}]
		});

		// 设置基类属性		BusiPersonnelManageList.superclass.constructor.call(this, {
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
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/busipersonnelmanage/excel.xls';
	}
});

var busiPersonnelManageList = new BusiPersonnelManageList();

Ext.getCmp("MgrBusiPersonnelInfoIndex").add(busiPersonnelManageList);
Ext.getCmp("MgrBusiPersonnelInfoIndex").doLayout();
</script>

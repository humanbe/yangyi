<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
/*
typeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${appPath}/demo/callInside/EPAY0006/EPAY',
	root : 'data'
});
typeStore.load();
*/


//定义列表
FlashDemoList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件

	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 实例化数据列表选择框组件
		

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/demo/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
				'tranid',
				'appsystemid',
				'chnlno',
				'outtrancode',
				'trancode',
				'tranname', 
				'trantime', 
				'serviceid', 
				'busimoduelname', 
				'busimoduelcode', 
				'higouttrancode',
				'outserivcesid',
				'outtrancode',
				'commprotocol'
			],
			remoteSort : true,
			sortInfo : {
				field : 'appsystemid',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 20
			}
		});

		// 加载列表数据
		//this.gridStore.load();
		
		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'FlashDemoListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), 
				{
				header : '<fmt:message key="button.flow" />',
				align : 'center',
				width : 50,
				renderer: this.renderWorkFlowColumn
				},
				{
					header : '<fmt:message key="property.tranid" />',
					dataIndex : 'tranid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appsystemid" />',
					dataIndex : 'appsystemid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.chnlno" />',
					dataIndex : 'chnlno',
					sortable : true
				},
				{
					header : '<fmt:message key="property.outtrancode" />',
					dataIndex : 'outtrancode',
					sortable : true
				},
				{
					header : '<fmt:message key="property.trancode" />',
					dataIndex : 'trancode',
					sortable : true
				},
				{
					header : '<fmt:message key="property.tranname" />',
					dataIndex : 'tranname',
					sortable : true
				},
				{
					header : '<fmt:message key="property.trantime" />',
					dataIndex : 'trantime',
					sortable : true
				},
				{
					header : '<fmt:message key="property.serviceid" />',
					dataIndex : 'serviceid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.busimoduelname" />',
					dataIndex : 'busimoduelname',
					sortable : true
				},
				{
					header : '<fmt:message key="property.busimoduelcode" />',
					dataIndex : 'busimoduelcode',
					sortable : true
				},
				{
					header : '<fmt:message key="property.higouttrancode" />',
					dataIndex : 'higouttrancode',
					sortable : true
				}
	  		],
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				cellclick : function(grid, rowIndex, columnIndex, e) {
					var record = grid.getSelectionModel().getSelected();
					var params = {
						//appSystemId : record.data.appsystemid,
						//outTrancode : record.data.chnlno,
						tranId : record.data.tranid
					};
					switch (columnIndex) {
						case 1:
							app.loadTab('FlashDemo1','<fmt:message key="button.view" />'+ record.data.appsystemid + '-' + record.data.outtrancode + '流程','${ctx}/${appPath}/demo/flash', params);
							break;
						default:
							break;
					}
					
				}
			}
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			id : 'FlashDemoFindFormPanel',
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
					fieldLabel : '<fmt:message key="property.appsystemid" />',
					name : 'appsystemid',
					tabIndex : this.tabIndex++,
					allowBlank : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.chnlno" />',
					name : 'chnlno',
					tabIndex : this.tabIndex++,
					allowBlank : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.outtrancode" />',
					name : 'outtrancode',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}
			],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doReset
			} ]
		});

		// 设置基类属性
		FlashDemoList.superclass.constructor.call(this, {
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
	// 查看列 数据载入 
	renderWorkFlowColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		return '<a href="#"><img src="${ctx}/static/style/images/menu/field.png"></img></a>';
	}
});

Ext.getCmp("FlashDemoIndex").add(new FlashDemoList());
Ext.getCmp("FlashDemoIndex").doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize = 100;
var usernameSerilNoStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/membermanage/queryUsernameSerilNos',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['userName','serilNo'])
});

var groupNameStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/membermanage/queryGroupNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['groupName'])
});

var sexStore = new Ext.data.SimpleStore({
	fields :['sex'],
	data :[['男'], ['女']]
});

var outSourcingFlagStore = new Ext.data.SimpleStore({
	fields : ['outSourcingFlagValue', 'outSourcingFlagDisplay'],
	data : [['2','是'], ['1', '不是']]
});

//定义列表
MemberManageList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {
		usernameSerilNoStore.load();
		groupNameStore.load();
		// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/membermanage/index',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['userId', 'userName','sex', 'mobile', 'phone', 
			          	'otherContact', 'email', 'serilNo', 'groupName', 'teamName', 
			          	'disasterRecoverPriority', 'securityRank', 'groupName',
			          	'takeOverFlag','outSourcingFlag'],
			remoteSort : true,
			sortInfo : {
				field : 'userId',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			},
			listeners : {
				'load' : function(store, records, opt){
					if(store.getCount() > 0){
						Ext.getCmp('MemberManageExport').enable();
					}else{
						Ext.getCmp('MemberManageExport').disable();
					}
				}
			}
		});

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'MemberManageListGridPanel',
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
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm,
				{
					header : '<fmt:message key="property.userId" />',
					dataIndex : 'userId',
					sortable : true,
					width : 80
				},
				{
					header : '<fmt:message key="property.userName" />',
					dataIndex : 'userName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.sex" />',
					dataIndex : 'sex',
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
					header : '<fmt:message key="property.otherContact" />',
					dataIndex : 'otherContact',
					sortable : true
				},
				{
					header : '<fmt:message key="property.email" />',
					dataIndex : 'email',
					sortable : true
				},
				{
					header : '<fmt:message key="property.serilNo" />',
					dataIndex : 'serilNo',
					sortable : true
				},
				{
					header : '<fmt:message key="property.groupName" />',
					dataIndex : 'groupName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.teamName" />',
					dataIndex : 'teamName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isOutSourcing" />',
					dataIndex : 'outSourcingFlag',
					sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value == '2'){
							return '是';
						}	
					}
				}
	  		],
	  		tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true,
				pageSize : pageSize,
				buttons : [ '-', {
					id : 'MemberManageExport',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				}]
			}),
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'MemberManageFindFormPanel',
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
					fieldLabel : '<fmt:message key="property.userName" />',
					store : usernameSerilNoStore,
					displayField : 'userName',
					name : 'userName',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.serilNo" />',
					name:'serilNo',
					store : usernameSerilNoStore,
					displayField : 'serilNo',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.sex" />',
					name:'sex',
					store : sexStore,
					displayField : 'sex',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.groupName" />',
					name :'groupName',
					store : groupNameStore,
					displayField : 'groupName',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.isOutSourcing" />',
					hiddenName :'outSourcingFlag',
					store : outSourcingFlagStore,
					displayField : 'outSourcingFlagDisplay',
					valueField :'outSourcingFlagValue',
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

		// 设置基类属性		MemberManageList.superclass.constructor.call(this, {
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
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			userId : record.get('userId')
		};
		var tab = Ext.getCmp("view_MemberInfo");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.memberInfo" />');
		}
		app.loadTab('view_MemberInfo', 
				'<fmt:message key="button.view" /><fmt:message key="property.memberInfo" />', 
				'${ctx}/${managePath}/membermanage/view', 
				params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				userId : record.get('userId')
			};
			app.loadTab('edit_MemberInfo', 
					'<fmt:message key="button.edit" /><fmt:message key="property.memberInfo" />', 
					'${ctx}/${managePath}/membermanage/edit', 
					params);
		} else {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/membermanage/excel.xls';
	}
});

var memberManageList = new MemberManageList();
memberManageList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : memberManageList,
	handler : memberManageList.doEdit
	},'-');
Ext.getCmp("MgrMemberInfoIndex").add(memberManageList);
Ext.getCmp("MgrMemberInfoIndex").doLayout();
</script>

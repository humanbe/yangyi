<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义列表
AddressBookInfoList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);

		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/addressbookinfo/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
				'adminname', 
				'admintype', 
				'mobile', 
				'phone', 
				'email', 
				'remark', 
				'adminid' 
			],
			remoteSort : true,
			sortInfo : {
				field : 'adminid',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 20
			}
		});

		// 加载列表数据
//		this.gridStore.load();

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'AddressBookInfoListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), csm, 
				{
					header : '<fmt:message key="portlet.url" />',
					dataIndex : 'adminname',
					sortable : true
				},
				{
					header : 'admintype',
					dataIndex : 'admintype',
					sortable : true
				},
				{
					header : 'mobile',
					dataIndex : 'mobile',
					sortable : true
				},
				{
					header : 'phone',
					dataIndex : 'phone',
					sortable : true
				},
				{
					header : 'email',
					dataIndex : 'email',
					sortable : true
				},
				{
					header : 'remark',
					dataIndex : 'remark',
					sortable : true
				},
				{
					header : 'adminid',
					dataIndex : 'adminid',
					hidden : true
				}
	  		],
	  		/*
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-', {
					iconCls : 'button-add',
					text : '<fmt:message key="button.create" />',
					scope : this,
					handler : this.doCreate
				}, '-', {
					iconCls : 'button-edit',
					text : '<fmt:message key="button.edit" />',
					scope : this,
					handler : this.doEdit
				}, '-', {
					iconCls : 'button-delete',
					text : '<fmt:message key="button.delete" />',
					scope : this,
					handler : this.doDelete
				}, '-' ]
			}),
			*/
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			id : 'AddressBookInfoFindFormPanel',
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
					fieldLabel : 'adminname',
					name : 'adminname',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'admintype',
					name : 'admintype',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'mobile',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'phone',
					name : 'phone',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'email',
					name : 'email',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'remark',
					name : 'remark',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'adminid',
					name : 'adminid',
					tabIndex : this.tabIndex++,
					allowBlank : false
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
		AddressBookInfoList.superclass.constructor.call(this, {
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
			id : record.get('addminid')
		};
		app.loadTab('view_AddressBookInfo', '<fmt:message key="button.view" /><fmt:message key="AddressBookInfo" />', '${ctx}/${appPath}/addressbookinfo/view', params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('add_AddressBookInfo', '<fmt:message key="button.create" /><fmt:message key="AddressBookInfo" />', '${ctx}/${appPath}/addressbookinfo/create');
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				id : record.get('addminid')
			};
			app.loadTab('edit_AddressBookInfo', '<fmt:message key="button.edit" /><fmt:message key="AddressBookInfo" />', '${ctx}/${appPath}/addressbookinfo/edit', params);
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
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('addminid');
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
							url : '${ctx}/${appPath}/addressbookinfo/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								addminids : ids,
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
	}
});
Ext.getCmp("AddressBookInfoIndex").add(new AddressBookInfoList());
Ext.getCmp("AddressBookInfoIndex").doLayout();
</script>

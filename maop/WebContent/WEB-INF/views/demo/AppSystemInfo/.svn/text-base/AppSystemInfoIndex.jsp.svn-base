<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义列表
AppSystemInfoList = Ext.extend(Ext.Panel, {
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
				url : '${ctx}/${appPath}/appsysteminfo/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
				'appsystemname', 
				'issysflag', 
				'appsystemtype', 
				'appsystemtime', 
				'meno', 
				'appadminidA', 
				'sysadminidA', 
				'appadminidB', 
				'sysadminidB', 
				'bmanagerid', 
				'cmanagerid', 
				'busicontact1id', 
				'busicontact2id', 
				'reserve1', 
				'reserve2', 
				'appsystemid',
				'adminname',
				'admintype',
				'mobile',
				'phone',
				'email'
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
//		this.gridStore.load();

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'AppSystemInfoListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), csm, 
				{
					header : '<fmt:message key="property.appsystemid" />',
					dataIndex : 'appsystemid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appsystemname" />',
					dataIndex : 'appsystemname',
					sortable : true
				},
				{
					header : '<fmt:message key="property.issysflag" />',
					dataIndex : 'issysflag',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appsystemtype" />',
					dataIndex : 'appsystemtype',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appsystemtime" />',
					dataIndex : 'appsystemtime',
					sortable : true
				}
				,
				{
					header : '<fmt:message key="property.meno" />',
					dataIndex : 'meno',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appadminidA" />',
					dataIndex : 'appadminidA',
					sortable : true
				},
				{
					header : '<fmt:message key="property.sysadminidA" />',
					dataIndex : 'sysadminidA',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appadminidB" />',
					dataIndex : 'appadminidB',
					sortable : true
				},
				{
					header : '<fmt:message key="property.sysadminidB" />',
					dataIndex : 'sysadminidB',
					sortable : true
				},
				{
					header : '<fmt:message key="property.bmanagerid" />',
					dataIndex : 'bmanagerid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.cmanagerid" />',
					dataIndex : 'cmanagerid',
					sortable : true
				},
				{
					header : '<fmt:message key="property.busicontact1id" />',
					dataIndex : 'busicontact1id',
					sortable : true
				},
				{
					header : '<fmt:message key="property.busicontact2id" />',
					dataIndex : 'busicontact2id',
					sortable : true
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
			id : 'AppSystemInfoFindFormPanel',
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
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsystemtype" />',
					name : 'appsystemtype',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsystemtime" />',
					name : 'appsystemtime',
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
		AppSystemInfoList.superclass.constructor.call(this, {
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
			id : record.get('appsystemid')
		};
		app.loadTab('view_AppSystemInfo', '<fmt:message key="button.view" /><fmt:message key="AppSystemInfo" />', '${ctx}/${appPath}/appsysteminfo/view', params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('add_AppSystemInfo', '<fmt:message key="button.create" /><fmt:message key="AppSystemInfo" />', '${ctx}/${appPath}/appsysteminfo/create');
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				id : record.get('appsystemid')
			};
			app.loadTab('edit_AppSystemInfo', '<fmt:message key="button.edit" /><fmt:message key="AppSystemInfo" />', '${ctx}/${appPath}/appsysteminfo/edit', params);
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
				ids[i] = records[i].get('appsystemid');
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
							url : '${ctx}/${appPath}/appsysteminfo/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								appsystemids : ids,
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
Ext.getCmp("AppSystemInfoIndex").add(new AppSystemInfoList());
Ext.getCmp("AppSystemInfoIndex").doLayout();
</script>

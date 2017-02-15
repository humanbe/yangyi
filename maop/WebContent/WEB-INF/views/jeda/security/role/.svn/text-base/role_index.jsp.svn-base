<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义角色列表
	RoleList = Ext.extend(Ext.Panel, {
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
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${frameworkPath}/role/index',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'id', 'name', 'description', 'order', 'creator', 'created', 'modifier', 'modified' ],
				remoteSort : true,
				sortInfo : {
					field : 'order',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 20
				}
			});

			// 加载列表数据
			this.gridStore.load();

			// 实例化数据列表组件
			this.grid = new Ext.grid.GridPanel({
				id : 'roleListGridPanel',
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
				autoExpandColumn : 'name',
				columns : [ new Ext.grid.RowNumberer(), csm, {
					header : '<fmt:message key="role.id" />',
					dataIndex : 'id',
					sortable : true
				}, {
					id : 'name',
					header : '<fmt:message key="role.name" />',
					dataIndex : 'name',
					sortable : true
				}, {
					header : '<fmt:message key="role.description" />',
					dataIndex : 'description',
					sortable : true
				}, {
					header : '<fmt:message key="column.order" />',
					dataIndex : 'order',
					width : 20,
					align : 'center',
					sortable : true
				}, {
					header : '<fmt:message key="user" />',
					dataIndex : 'id',
					width : 22,
					align : 'center',
					renderer : this.renderUserColumn
				}, {
					header : '<fmt:message key="menu" />',
					dataIndex : 'id',
					width : 20,
					align : 'center',
					renderer : this.renderMenuColumn
				}, {
					header : '<fmt:message key="function" />',
					dataIndex : 'id',
					width : 20,
					align : 'center',
					renderer : this.renderFunctionColumn
				}, {
					header : '<fmt:message key="permission" />',
					dataIndex : 'id',
					width : 20,
					align : 'center',
					renderer : this.renderPermissionColumn
				}, {
					header : '<fmt:message key="brpmrole" />',
					dataIndex : 'id',
					width : 38,
					align : 'center',
					renderer : this.renderBrpmRoleColumn
				}, {
					header : '<fmt:message key="bsarole" />',
					dataIndex : 'id',
					width : 35,
					align : 'center',
					renderer : this.renderBsaRoleColumn
				}, {
					header : '<fmt:message key="column.creator" />',
					dataIndex : 'creator',
					align : 'center',
					sortable : true,
					hidden : true
				}, {
					header : '<fmt:message key="column.created" />',
					dataIndex : 'created',
					align : 'center',
					sortable : true,
					hidden : true
				}, {
					header : '<fmt:message key="column.modifier" />',
					dataIndex : 'modifier',
					align : 'center',
					sortable : true,
					hidden : true
				}, {
					header : '<fmt:message key="column.modified" />',
					dataIndex : 'modified',
					align : 'center',
					sortable : true,
					hidden : true
				} ],
				tbar : new Ext.Toolbar({
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
				bbar : new Ext.PagingToolbar({
					store : this.gridStore,
					displayInfo : true,
					buttons : [ '-', {
						iconCls : 'button-excel',
						tooltip : '<fmt:message key="button.excel" />',
						handler : function() {
							window.location = '${ctx}/${frameworkPath}/role/excel.xls?' + Ext.getCmp("roleFindFormPanel").form.getValues(true);
						}
					}]
				}),
				// 定义数据列表监听事件
				listeners : {
					scope : this,
					// 行双击事件：打开数据查看页面
					rowdblclick : this.doView,
					cellclick : function(grid, rowIndex, columnIndex, e) {
						var record = grid.getSelectionModel().getSelected();
						var params = {
							role : record.data.id
						};
						switch (columnIndex) {
						case 6:
							app.loadWindow('${ctx}/${frameworkPath}/role/user', params);
							break;
						case 7:
							app.loadWindow('${ctx}/${frameworkPath}/role/menu', params);
							break;
						case 8:
							app.loadWindow('${ctx}/${frameworkPath}/role/function', params);
							break;
						case 9:
							app.loadWindow('${ctx}/${frameworkPath}/role/permission', params);
							break;
						case 10:
							app.loadWindow('${ctx}/${frameworkPath}/role/brpmrole', params);
							break;
						case 11:
							app.loadWindow('${ctx}/${frameworkPath}/role/bsarole', params);
							break;
						default:
							break;
						}
					}
				}
			});

			// 实例化查询表单
			this.form = new Ext.FormPanel({
				id : 'roleFindFormPanel',
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
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="role.name" />',
					name : 'name',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="role.description" />',
					name : 'description',
					tabIndex : this.tabIndex++
				} ],
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
			RoleList.superclass.constructor.call(this, {
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
				id : record.get('id')
			};
			app.loadTab('view_role', '<fmt:message key="button.view" /><fmt:message key="role" />', '${ctx}/${frameworkPath}/role/view', params);
		},
		// 新建事件
		doCreate : function() {
			app.loadTab('add_role', '<fmt:message key="button.create" /><fmt:message key="role" />', '${ctx}/${frameworkPath}/role/create');
		},
		// 编辑事件
		doEdit : function() {
			if (this.grid.getSelectionModel().getCount() == 1) {
				var record = this.grid.getSelectionModel().getSelected();
				var params = {
					id : record.get('id')
				};
				app.loadTab('edit_role', '<fmt:message key="button.edit" /><fmt:message key="role" />', '${ctx}/${frameworkPath}/role/edit', params);
			} else {
				Ext.Msg.show({
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
					ids[i] = records[i].get('id');
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
								url : '${ctx}/${frameworkPath}/role/delete',
								scope : this,
								success : this.deleteSuccess,
								failure : this.deleteFailure,
								params : {
									ids : ids,
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
		renderUserColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/user_key.png"></img></a>';
		},
		renderMenuColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/menu_key.png"></img></a>';
		},
		renderFunctionColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/app_key.png"></img></a>';
		},
		renderPermissionColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/database_key.png"></img></a>';
		},
		renderBrpmRoleColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/group_key.png"></img></a>';
		},
		renderBsaRoleColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/group_key.png"></img></a>';
		}
	});

	Ext.getCmp("ROLE_LIST").add(new RoleList());
	Ext.getCmp("ROLE_LIST").doLayout();
</script>

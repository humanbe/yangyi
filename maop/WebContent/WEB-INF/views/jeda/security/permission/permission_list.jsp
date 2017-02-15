<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	PermissionList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源
		functionStore : null, // 功能数据源
		typeStore : null, // 类型数据源
		userTypeStore : null, // 用户类型数据源
		orgTypeStore : null, // 机构类型数据源
		grid : null,// 数据列表组件
		form : null,// 查询表单组件
		tree : null,// 树形组件
		tabIndex : 0,// 查询表单组件Tab键顺序
		csm : null,// 数据列表选择框组件
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 实例化数据列表选择框组件
			csm = new Ext.grid.CheckboxSelectionModel();

			// 实例化类型数据源
			this.typeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.typeStore.load();// 加载类型数据

			// 实例化用户权限类型数据源
			this.userTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_USER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.userTypeStore.load();// 加载用户权限类型数据
			
			// 实例化机构权限类型数据源
			this.orgTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_ORG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.orgTypeStore.load();// 加载机构权限类型数据

			this.functionStore = new Ext.data.JsonStore({
				url : '${ctx}/${frameworkPath}/function/get',
				root : 'data',
				fields : [ 'id', 'name' ]
			});
			this.functionStore.load();

			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${frameworkPath}/permission/list',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'id', 'name', 'functionId', 'functionName','item','subitem', 'type', 'userType', 'orgType', 'expression', 'order', 'creator', 'created', 'modifier', 'modified' ],
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
			// 加载数据源的数据
			this.gridStore.load();

			// 实例化数据列表组件
			this.grid = new Ext.grid.GridPanel({
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
					header : '<fmt:message key="permission.id" />',
					dataIndex : 'id',
					hidden : true
				}, {
					id : 'name',
					header : '<fmt:message key="permission.name" />',
					dataIndex : 'name',
					width : 50,
					sortable : true
				}, {
					header : '<fmt:message key="permission.function" />',
					dataIndex : 'functionName',
					width : 80,
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.type" />',
					dataIndex : 'type',
					width : 70,
					renderer : this.renderTypeColumn,
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.user.type" />',
					dataIndex : 'userType',
					renderer : this.renderUserTypeColumn,
					scope : this,
					width : 50,
					sortable : true
				}, {
					header : '<fmt:message key="permission.org.type" />',
					dataIndex : 'orgType',
					renderer : this.renderOrgTypeColumn,
					scope : this,
					width : 50,
					sortable : true
				}, {
					header : '<fmt:message key="permission.item" />',
					dataIndex : 'item',
					width : 50,
					sortable : true
				}, {
					header : '<fmt:message key="permission.subitem" />',
					dataIndex : 'subitem',
					width : 50,
					sortable : true
				}, {
					header : '<fmt:message key="permission.expression" />',
					dataIndex : 'expression',
					width : 250,
					hidden : true,
					sortable : true
				}, {
					header : '<fmt:message key="column.order" />',
					dataIndex : 'order',
					width : 50,
					sortable : true
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
				// 定义按钮工具条
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
				// 定义分页工具条
				bbar : new Ext.PagingToolbar({
					store : this.gridStore,
					displayInfo : true,
					buttons : [ '-', {
						iconCls : 'button-excel',
						tooltip : '<fmt:message key="button.excel" />',
						scope : this,
						handler : function() {
							window.location = '${ctx}/${frameworkPath}/permission/excel.xls?' + this.form.getForm().getValues(true);
						}
					} ]
				}),
				// 定义数据列表监听事件
				listeners : {
					scope : this,
					// 行双击事件：打开数据查看页面
					rowdblclick : this.doView
				}
			});

			// 实例化查询表单
			this.form = new Ext.FormPanel({
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
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="permission.name" />',
					name : 'name',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="permission.expression" />',
					name : 'expression',
					tabIndex : this.tabIndex++
				} ],
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

			// 定义树形组件
			this.tree = new Ext.tree.TreePanel({
				xtype : 'treepanel',
				border : false,
				split : true,
				width : 200,
				minSize : 150,
				maxSize : 250,
				autoScroll : true,
				collapseMode : 'mini',
				region : 'west',
				root : new Ext.tree.AsyncTreeNode({
					text : '<fmt:message key="function" />',
					draggable : false,
					iconCls : 'node-root',
					id : 'TREE_ROOT_NODE'
				}),
				tools : [ {
					id : 'refresh',
					scope : this,
					handler : function() {
						var selectedNodePath = null;
						if (this.tree.getSelectionModel().getSelectedNode() != null) {
							selectedNodePath = this.tree.getSelectionModel().getSelectedNode().getPath();
						}
						this.tree.root.reload();
						this.tree.root.expand();
						//this.tree.expandAll();
						if (selectedNodePath != null) {
							this.tree.selectPath(selectedNodePath);
						}
					}
				} ],
				loader : new Ext.tree.TreeLoader({
					requestMethod : 'GET',
					dataUrl : '${ctx}/${frameworkPath}/permission/function'
				}),
				// 定义树形组件监听事件
				listeners : {
					scope : this,
					// 点击树节点,刷新列表数据
					click : this.doFilter
				}
			});

			this.tree.root.expand();

			// 设置基类属性
			PermissionList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ this.tree, this.grid, this.form ]
			});
		},
		// 过滤列表数据
		doFilter : function(node) {
			if (!node.isLeaf() || node.attributes.category == 'module') {
				return;
			} else {
				this.gridStore.load({
					params : {
						functionId : node.id
					}
				});
			}
		},
		doFind : function() {
			Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
			this.grid.getStore().load();
		},
		doReset : function() {
			this.form.getForm().reset();
		},
		// 查看事件
		doView : function() {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				id : record.get("id"),
				functionId : record.get("functionId")
			};
			app.loadTab('PERMISSION_VIEW', '<fmt:message key="button.view" /><fmt:message key="permission" />', '${ctx}/${frameworkPath}/permission/view', params);
		},
		// 新建事件
		doCreate : function() {
			var selectedNode = this.tree.getSelectionModel().getSelectedNode();
			if (selectedNode == null || selectedNode.attributes.category == 'module') {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="permission.error.select.function" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
				return false;
			}
			var params = {
				functionId : selectedNode.id
			};
			app.loadTab('PERMISSION_CREATE', '<fmt:message key="button.create" /><fmt:message key="permission" />', '${ctx}/${frameworkPath}/permission/create', params);
		},
		// 编辑事件
		doEdit : function() {
			var grid = this.grid;
			if (grid.getSelectionModel().getCount() == 1) {
				var record = grid.getSelectionModel().getSelected();
				var params = {
					id : record.get("id"),
					functionId : record.get("functionId")
				};
				app.loadTab('PERMISSION_EDIT', '<fmt:message key="button.edit" /><fmt:message key="permission" />', '${ctx}/${frameworkPath}/permission/edit', params);
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
			var grid = this.grid;
			if (grid.getSelectionModel().getCount() > 0) {
				var records = grid.getSelectionModel().getSelections();
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
								scope : this,
								url : '${ctx}/${frameworkPath}/permission/delete',
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
		// 删除成功回调
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
				this.grid.getStore().reload();
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.delete.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		// 删除失败回调
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
		renderTypeColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			var index = this.typeStore.find('value', value);
			if (index == -1) {
			} else {
				return this.typeStore.getAt(index).get('name');
			}
		},
		renderUserTypeColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			var index = this.userTypeStore.find('value', value);
			if (index == -1) {
			} else {
				return this.userTypeStore.getAt(index).get('name');
			}
		},
		renderOrgTypeColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			var index = this.orgTypeStore.find('value', value);
			if (index == -1) {
			} else {
				return this.orgTypeStore.getAt(index).get('name');
			}
		}
	});
	Ext.getCmp("PERMISSION_LIST").add(new PermissionList());
	Ext.getCmp("PERMISSION_LIST").doLayout();
</script>
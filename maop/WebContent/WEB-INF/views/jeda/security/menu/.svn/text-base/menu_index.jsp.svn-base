<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	MenuList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源
		grid : null,// 数据列表组件
		form : null,// 查询表单组件
		tree : null,// 树形组件
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
					url : '${ctx}/${frameworkPath}/menu/index',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'id', 'name', 'url', 'order', 'creator', 'created', 'modifier', 'modified' ],
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
				id : 'menuListGridPanel',
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
					header : '<fmt:message key="menu.id" />',
					dataIndex : 'id',
					sortable : true
				}, {
					id : 'name',
					header : '<fmt:message key="menu.name" />',
					dataIndex : 'name',
					sortable : true
				}, {
					header : '<fmt:message key="menu.url" />',
					dataIndex : 'url',
					sortable : true
				}, {
					header : '<fmt:message key="column.order" />',
					dataIndex : 'order',
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
						handler : this.doExportXLS
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
				id : 'menuFindFormPanel',
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
					fieldLabel : '<fmt:message key="menu.name" />',
					name : 'name',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.url" />',
					name : 'url',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="menu.description" />',
					name : 'description',
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
				id : 'menuTree',
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
					text : '<fmt:message key="menu" />',
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
					dataUrl : '${ctx}/${frameworkPath}/menu/children'
				}),
				// 定义树形组件监听事件
				listeners : {
					scope : this,
					// 点击树节点,刷新列表数据
					click : this.doFilter
				}
			});

			this.tree.root.expand();
			//this.tree.expandAll();

			// 设置基类属性
			MenuList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ this.tree, this.form, this.grid ]
			});
		},
		// 过滤列表数据
		doFilter : function(node) {
			if (node.isLeaf()) {
				this.gridStore.removeAll();
			}
			Ext.apply(this.gridStore.baseParams, {
				parent : node.id
			});
			this.gridStore.load();
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
		// 导出Excel文件
		doExportXLS : function() {
			window.location = '${ctx}/${frameworkPath}/menu/excel.xls?' + Ext.getCmp("menuFindFormPanel").form.getValues(true);
		},
		// 查看事件
		doView : function() {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				id : record.get('id')
			};
			app.loadTab('view_menu', '<fmt:message key="button.view" /><fmt:message key="menu" />', '${ctx}/${frameworkPath}/menu/view', params);
		},
		// 新建事件
		doCreate : function() {
			if (this.tree.getSelectionModel().getSelectedNode() == null) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.select.one.node" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
				return false;
			}
			var params = {
				parent : this.tree.getSelectionModel().getSelectedNode().id
			};
			app.loadTab('add_menu', '<fmt:message key="button.create" /><fmt:message key="menu" />', '${ctx}/${frameworkPath}/menu/create', params);
		},
		// 编辑事件
		doEdit : function() {
			if (this.grid.getSelectionModel().getCount() == 1) {
				var record = this.grid.getSelectionModel().getSelected();
				var params = {
					id : record.get('id')
				};
				app.loadTab('edit_menu', '<fmt:message key="button.edit" /><fmt:message key="menu" />', '${ctx}/${frameworkPath}/menu/edit', params);
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
								url : '${ctx}/${frameworkPath}/menu/delete',
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
				var selectedNodePath = null;
				if (this.tree.getSelectionModel().getSelectedNode() != null) {
					selectedNodePath = this.tree.getSelectionModel().getSelectedNode().getPath();
				}
				this.tree.root.reload();
				//this.tree.expandAll();
				if (selectedNodePath != null) {
					this.tree.selectPath(selectedNodePath);
				}
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
		}
	});

	Ext.getCmp("MENU_LIST").add(new MenuList());
	Ext.getCmp("MENU_LIST").doLayout();
</script>

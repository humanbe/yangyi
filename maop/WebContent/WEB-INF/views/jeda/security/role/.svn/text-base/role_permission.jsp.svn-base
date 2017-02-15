<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	RolePermission = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源
		userTypeStore : null, // 功能数据源
		orgTypeStore : null, // 功能数据源
		typeStore : null, // 类型数据源
		grid : null,// 数据列表组件
		tree : null,// 树形组件
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

			// 实例化类型数据源
			this.userTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_USER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.userTypeStore.load();// 加载类型数据

			// 实例化机构类型数据源
			this.orgTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_ORG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.orgTypeStore.load();// 加载机构类型数据

			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'GET',
					url : '${ctx}/${frameworkPath}/role/permission/${param.role}',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'id', 'name', 'functionName', 'userType', 'orgType', 'item', 'subitem', 'checked', 'type', 'expression', 'order' ]
			});

			// 默认选中数据
			this.gridStore.on('load', function(store) {
				var records = store.query('checked', true).getRange();
				this.grid.getSelectionModel().selectRecords(records, false);
			}, this, {
				delay : 300
			});

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
					sortable : true
				}, {
					header : '<fmt:message key="permission.function" />',
					dataIndex : 'functionName',
					sortable : true
				}, {
					header : '<fmt:message key="permission.type" />',
					dataIndex : 'type',
					renderer : this.renderTypeColumn,
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.user.type" />',
					dataIndex : 'userType',
					renderer : this.renderUserTypeColumn,
					align : 'center',
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.org.type" />',
					dataIndex : 'orgType',
					renderer : this.renderOrgTypeColumn,
					align : 'center',
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.item" />',
					dataIndex : 'item',
					renderer : this.renderItemColumn,
					align : 'center',
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="permission.subitem" />',
					dataIndex : 'subitem',
					renderer : this.renderSubItemColumn,
					align : 'center',
					scope : this,
					sortable : true
				}, {
					header : '<fmt:message key="column.order" />',
					dataIndex : 'order',
					sortable : true
				} ],
				tbar : new Ext.Toolbar({
					items : [ '-', {
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						scope : this,
						handler : this.doSave
					}, '-' ]
				})
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
			//this.tree.expandAll();

			// 设置基类属性
			RolePermission.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ this.tree, this.grid ]
			});

			// 加载列表数据
			this.gridStore.load();
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
		// 保存事件
		doSave : function() {
			var records = this.grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get("id");
			}
			var functionId = '';
			if (this.tree.getSelectionModel().getSelectedNode() != null) {
				functionId = this.tree.getSelectionModel().getSelectedNode().id;
			}

			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/role/permission',
				method : 'POST',
				success : this.saveSuccess,
				failure : this.saveFailure,
				params : {
					functionId : functionId,
					roleId : '${param.role}',
					permissionIds : ids
				}
			});
		},
		saveSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		saveFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" />',
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
			if (value == null) {
				return "-";
			}
			var index = this.userTypeStore.find('value', value);
			if (index == -1) {
			} else {
				var userType = this.userTypeStore.getAt(index).get('name');
				metadata.attr = 'ext:qtitle=""' + ' ext:qtip="' + userType + '"';
				return userType;
			}
		},
		renderOrgTypeColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			if (value == null) {
				return "-";
			}
			var index = this.orgTypeStore.find('value', value);
			if (index == -1) {
			} else {
				var orgType = this.orgTypeStore.getAt(index).get('name');
				metadata.attr = 'ext:qtitle=""' + ' ext:qtip="' + orgType + '"';
				return orgType;
			}
		},
		renderItemColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			if (value == null) {
				return "-";
			} else {
				return value;
			}
		},
		renderSubItemColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			if (value == null) {
				return "-";
			} else {
				return value;
			}
		}
	});

	app.window.get(0).add(new RolePermission());
	app.window.get(0).doLayout();
</script>

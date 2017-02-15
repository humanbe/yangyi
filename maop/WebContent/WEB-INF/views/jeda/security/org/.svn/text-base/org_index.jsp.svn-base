<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义列表
OrgList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	categoryStore : null, // 类型数据源
	propertyStore : null, // 属性数据源
	enabledStore : null,// 是否启用数据源
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
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${frameworkPath}/org/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'id', 'name', 'rank', 'contact', 'address', 'category', 'property', 'order', 'enabled', 'creator', 'created', 'modifier', 'modified' ],
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

		this.categoryStore = new Ext.data.JsonStore( {
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/ORG_CATEGORY/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.categoryStore.load();// 加载类型数据

		// 实例化属性数据源
		this.propertyStore = new Ext.data.JsonStore( {
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/ORG_PROPERTY/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.propertyStore.load();// 加载属性数据

		// 实例化启用数据源
		this.enabledStore = new Ext.data.JsonStore( {
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/COMMON_YESNO/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.enabledStore.load();// 加载启用数据

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
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
				header : '<fmt:message key="org.id" />',
				dataIndex : 'id',
				sortable : true
			}, {
				id : 'name',
				header : '<fmt:message key="org.name" />',
				dataIndex : 'name',
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="org.contact" />',
				dataIndex : 'contact',
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="org.address" />',
				dataIndex : 'address',
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="org.category" />',
				dataIndex : 'category',
				renderer : this.renderCategoryColumn,
				scope : this,
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="org.property" />',
				dataIndex : 'property',
				renderer : this.renderPropertyColumn,
				scope : this,
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="org.rank" />',
				dataIndex : 'rank',
				align : 'center',
				width : 30,
				sortable : true
			}, {
				header : '<fmt:message key="column.order" />',
				dataIndex : 'order',
				align : 'center',
				width : 30,
				sortable : true
			}, {
				header : '<fmt:message key="org.enabled" />',
				dataIndex : 'enabled',
				renderer : this.renderEnabled,
				align : 'center',
				width : 30,
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
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
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
		this.form = new Ext.FormPanel( {
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
				fieldLabel : '<fmt:message key="org.id" />',
				name : 'id',
				tabIndex : this.tabIndex++
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.name" />',
				name : 'name',
				tabIndex : this.tabIndex++
			}, {
				xtype : 'combo',
				store : this.categoryStore,
				fieldLabel : '<fmt:message key="org.category" />',
				name : 'category',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'category',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
				tabIndex : this.tabIndex++
			}, {
				xtype : 'combo',
				store : this.propertyStore,
				fieldLabel : '<fmt:message key="org.property" />',
				name : 'property',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'property',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
				tabIndex : this.tabIndex++
			}, {
				xtype : 'combo',
				store : this.enabledStore,
				fieldLabel : '<fmt:message key="org.enabled" />',
				name : 'enabled',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'enabled',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
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
		this.tree = new Ext.tree.TreePanel( {
			xtype : 'treepanel',
			border : false,
			split : true,
			width : 200,
			minSize : 150,
			maxSize : 250,
			autoScroll : true,
			collapseMode : 'mini',
			region : 'west',
			//rootVisible : false,
			root : new Ext.tree.AsyncTreeNode( {
				text : '<sec:authentication property="principal.org.name"/>',
				draggable : false,
				iconCls : 'node-root',
				id : '<sec:authentication property="principal.org.id"/>'
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
			loader : new Ext.tree.TreeLoader( {
				requestMethod : 'GET',
				dataUrl : '${ctx}/${frameworkPath}/org/children'
			}),
			// 定义树形组件监听事件
			listeners : {
				scope : this,
				// 点击树节点,刷新列表数据
				click : this.doFilter
			}
		});

		//this.tree.getRootNode().expand(false, false, function() { this.tree.getRootNode().expandChildNodes(false); },this);
		this.tree.getRootNode().expand(1);

		// 设置基类属性
		OrgList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.tree, this.form, this.grid ]
		});
	},
	// 过滤列表数据
	doFilter : function(node) {
		if (node.isLeaf()) {
			return;
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
		window.location = '${ctx}/${frameworkPath}/org/excel.xls?' + this.form.getForm().getValues(true);
	},
	doEnable : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('id');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.enable" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${frameworkPath}/org/enable',
							scope : this,
							success : this.operationSuccess,
							failure : this.operationFailure,
							params : {
								ids : ids
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
	doDisable : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('id');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.disable" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${frameworkPath}/org/disable',
							scope : this,
							success : this.operationSuccess,
							failure : this.operationFailure,
							params : {
								ids : ids
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
	operationSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:' + error,
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
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.operation.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	operationFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.operation.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			id : record.get('id')
		};
		app.loadTab('view_org', '<fmt:message key="button.view" /><fmt:message key="org" />', '${ctx}/${frameworkPath}/org/view', params);
	},
	// 新建事件
	doCreate : function() {
		if (this.tree.getSelectionModel().getSelectedNode() == null) {
			Ext.Msg.show( {
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
		app.loadTab('add_org', '<fmt:message key="button.create" /><fmt:message key="org" />', '${ctx}/${frameworkPath}/org/create', params);
	},
	// 编辑事件
	doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				id : record.get('id')
			};
			app.loadTab('edit_org', '<fmt:message key="button.edit" /><fmt:message key="org" />', '${ctx}/${frameworkPath}/org/edit', params);
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
				if (records[i].get('enabled') == true) {
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="error.constraint.deletable.org" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
					return false;
				}
				ids[i] = records[i].get('id');
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
							url : '${ctx}/${frameworkPath}/org/delete',
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
			var selectedNodePath = null;
			if (this.tree.getSelectionModel().getSelectedNode() != null) {
				selectedNodePath = this.tree.getSelectionModel().getSelectedNode().getPath();
			}
			this.tree.root.reload();
			this.tree.expandAll();
			if (selectedNodePath != null) {
				this.tree.selectPath(selectedNodePath);
			}
			this.grid.getStore().reload();
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
	renderEnabled : function(value, metadata, record, rowIndex, colIndex, store) {
		if (value) {
			return '<span style="color: green;font-weight: bold;"><fmt:message key="common.yes" /></span>';
		} else {
			return '<span style="color: red;font-weight: bold;"><fmt:message key="common.no" /></span>';
		}
	},
	renderCategoryColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		var index = this.categoryStore.find('value', value);
		if (index == -1) {
		} else {
			return this.categoryStore.getAt(index).get('name');
		}
	},
	renderPropertyColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		var index = this.propertyStore.find('value', value);
		if (index == -1) {
		} else {
			return this.propertyStore.getAt(index).get('name');
		}
	}
});

var orgList = new OrgList( {
	id : 'orgList'
});
</script>
<sec:authorize access="hasRole('ORG_CREATE')">
	<script type="text/javascript">
	orgList.grid.getTopToolbar().add( {
		iconCls : 'button-add',
		text : '<fmt:message key="button.create" />',
		scope : orgList,
		handler : orgList.doCreate
	}, '-');
	</script>
</sec:authorize>

<sec:authorize access="hasRole('ORG_EDIT')">
	<script type="text/javascript">
	orgList.grid.getTopToolbar().add( {
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : orgList,
		handler : orgList.doEdit
	}, '-');
	</script>
</sec:authorize>

<sec:authorize access="hasRole('ORG_DELETE')">
	<script type="text/javascript">
	orgList.grid.getTopToolbar().add( {
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : orgList,
		handler : orgList.doDelete
	}, '-');
	</script>
</sec:authorize>


<sec:authorize access="hasRole('ORG_ENABLE')">
	<script type="text/javascript">
	orgList.grid.getTopToolbar().add( {
		iconCls : 'button-enabled',
		text : '<fmt:message key="button.enable" />',
		scope : orgList,
		handler : orgList.doEnable
	}, '-');
	</script>
</sec:authorize>


<sec:authorize access="hasRole('ORG_DISABLE')">
	<script type="text/javascript">
	orgList.grid.getTopToolbar().add( {
		iconCls : 'button-disabled',
		text : '<fmt:message key="button.disable" />',
		scope : orgList,
		handler : orgList.doDisable
	}, '-');
	</script>
</sec:authorize>

<script type="text/javascript">
Ext.onReady(function(){
	Ext.getCmp("ORG_LIST").add(orgList);
	Ext.getCmp("ORG_LIST").doLayout();
});
</script>
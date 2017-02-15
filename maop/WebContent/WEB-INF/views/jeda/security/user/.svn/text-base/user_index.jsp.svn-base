<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	UserList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源

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
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${frameworkPath}/user/index',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'username', 'name', 'email', 'positionname', 'enabled', 'org', 'orgname', 'order', 'creator', 'created', 'modifier', 'modified' ],
				remoteSort : true,
				sortInfo : {
					field : 'order, u.username',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 20
				}
			});

			// 加载列表数据
			this.gridStore.load();

			// 实例化启用数据源
			this.enabledStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/COMMON_YESNO/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.enabledStore.load();// 加载启用数据

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
					header : '<fmt:message key="user.username" />',
					dataIndex : 'username',
					align : 'center',
					sortable : true
				}, {
					id : 'name',
					header : '<fmt:message key="user.name" />',
					dataIndex : 'name',
					align : 'center',
					sortable : true
				}, {
					header : '<fmt:message key="user.email" />',
					dataIndex : 'email',
					align : 'center',
					sortable : true,
					vtype : 'email'
				}, {
					header : '<fmt:message key="user.position" />',
					dataIndex : 'positionname',
					align : 'center',
					sortable : true
				}, {
					header : '<fmt:message key="user.enabled" />',
					dataIndex : 'enabled',
					width : 50,
					align : 'center',
					renderer : this.renderEnabledColumn,
					sortable : true
				}, {
					header : '<fmt:message key="user.org" />',
					dataIndex : 'orgname',
					align : 'center',
					sortable : true
				}, {
					header : '<fmt:message key="column.order" />',
					dataIndex : 'order',
					width : 50,
					align : 'center',
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
						iconCls : 'button-reset-password',
						text : '<fmt:message key="button.reset.password" />',
						scope : this,
						handler : this.doResetPassword
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
					rowdblclick : this.doView,
					cellclick : function(grid, rowIndex, columnIndex, e) {
						var record = grid.getSelectionModel().getSelected();
						var fieldId = grid.getColumnModel().getColumnId(columnIndex);
						var params = {
							username : record.data.username
						};
						switch (columnIndex) {
						case 13:
							if(fieldId != 'usersystem'){
								app.loadWindow('${ctx}/${frameworkPath}/user/role', params);
							}else{
								app.loadWindow('${ctx}/${frameworkPath}/user/app', params);
							}
							break;
						case 14:
							app.loadWindow('${ctx}/${frameworkPath}/user/app', params);
							break;
						case 15:
							app.loadWindow('${ctx}/${frameworkPath}/user/env', params);
							break;
						default:
							break;
						}
					}
				}
			});

			// 实例化查询表单

			this.form = new Ext.FormPanel({
				region : 'east',
				title : '<fmt:message key="button.find" />',
				defaultType : 'textfield',
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
					fieldLabel : '<fmt:message key="user.username" />',
					name : 'username',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.name" />',
					name : 'name',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.email" />',
					name : 'email',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="user.birthday" />',
					name : 'birthday',
					format : 'Y-m-d',
					tabIndex : this.tabIndex++,
					editable : false
				}, {
					fieldLabel : '<fmt:message key="user.tel" />',
					name : 'tel',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.mobile" />',
					name : 'mobile',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					store : this.enabledStore,
					fieldLabel : '<fmt:message key="user.enabled" />',
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
				loader : new Ext.tree.TreeLoader({
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

			this.tree.root.expand();
			//this.tree.expandAll();

			// 设置基类属性

			UserList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ this.tree, this.form, this.grid ]
			});
		},
		// 渲染角色列
		renderRoleColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/group_key.png"></img></a>';
		},
		// 渲染系统列
		renderSystemColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/menu/system.bmp"></img></a>';
		},
		// 渲染系统列

		renderEnvColumn : function(value, metadata, record, rowIndex, colIndex, store) {
			return '<a href="#"><img src="${ctx}/static/style/images/button/service.bmp"></img></a>';
		},
		// 渲染启用标志列
		renderEnabledColumn : function(enabled) {
			if (enabled) {
				return '<span style="color: green;font-weight: bold;"><fmt:message key="common.yes" /></span>';
			} else {
				return '<span style="color: red;font-weight: bold;"><fmt:message key="common.no" /></span>';
			}
		},
		// 过滤列表数据
		doFilter : function(node) {
			Ext.apply(this.gridStore.baseParams, {
				org : node.id
			});
			this.gridStore.load();
		},
		// 重置密码
		doResetPassword : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
				}
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.reset.password" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${frameworkPath}/user/resetpassword',
								scope : this,
								success : this.resetPasswordSuccess,
								failure : this.resetPasswordFailure,
								params : {
									usernames : usernames
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
		// 重置密码成功回调方法
		resetPasswordSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				var defaultPassword = Ext.decode(response.responseText).defaultPassword;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.operation.successful" />' + '<br>' + '<fmt:message key="user.defaultPassword" />' + ':' + defaultPassword,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		// 重置密码失败回调方法
		resetPasswordFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.operation.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 查询事件
		doFind : function() {
			Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
			Ext.apply(this.grid.getStore().baseParams, {
				enabled : this.form.getForm().findField('enabled').getValue()
			});
			if (this.tree.getSelectionModel().getSelectedNode() != null) {
				Ext.apply(this.grid.getStore().baseParams, {
					org : this.tree.getSelectionModel().getSelectedNode().id
				});
			}
			this.grid.getStore().load();
			this.grid.getStore().baseParams = {};
		},
		// 重置查询表单
		doReset : function() {
			this.form.getForm().reset();
		},
		// 查看事件
		doView : function() {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				username : record.get('username')
			};
			app.loadTab('USER_VIEW', '<fmt:message key="button.view" /><fmt:message key="user" />', '${ctx}/${frameworkPath}/user/view', params);
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
				org : this.tree.getSelectionModel().getSelectedNode().id
			};
			app.loadTab('USER_CREATE', '<fmt:message key="button.create" /><fmt:message key="user" />', '${ctx}/${frameworkPath}/user/create', params);
		},
		// 编辑事件
		doEdit : function() {
			if (this.grid.getSelectionModel().getCount() == 1) {
				var record = this.grid.getSelectionModel().getSelected();
				var params = {
					username : record.get("username"),
					org : record.get("org")
				};
				app.loadTab('USER_EDIT', '<fmt:message key="button.edit" /><fmt:message key="user" />', '${ctx}/${frameworkPath}/user/edit', params);
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
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
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
								url : '${ctx}/${frameworkPath}/user/delete',
								scope : this,
								success : this.deleteSuccess,
								failure : this.deleteFailure,
								params : {
									usernames : usernames,
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
		},
		// 导出xls事件
		doExportXLS : function() {
			window.location = '${ctx}/${frameworkPath}/user/excel.xls?' + this.form.getForm().getValues(true);
		},
		// 用户启用
		doEnable : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
				}
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.enable" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${frameworkPath}/user/enable',
								scope : this,
								success : this.operationSuccess,
								failure : this.operationFailure,
								params : {
									usernames : usernames
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
		// 用户停用
		doDisable : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
				}
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.disable" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${frameworkPath}/user/disable',
								scope : this,
								success : this.operationSuccess,
								failure : this.operationFailure,
								params : {
									usernames : usernames
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
		// brpm用户同步
		doSyncBrpm : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
				}
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.sync" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${frameworkPath}/user/syncDply',
								scope : this,
								timeout : 300000,
								success : this.syncOperationSuccess,
								failure : this.syncOperationFailure,
								params : {
									usernames : usernames
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
		// bsa用户同步
		doSyncBsa : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var usernames = new Array();
				for ( var i = 0; i < records.length; i++) {
					usernames[i] = records[i].get('username');
				}
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.sync" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${frameworkPath}/user/syncCheck',
								scope : this,
								timeout : 300000,
								success : this.syncOperationSuccess,
								failure : this.syncOperationFailure,
								params : {
									usernames : usernames
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
		syncOperationSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				var userNum = Ext.decode(response.responseText).userNum;
				var syncNum = Ext.decode(response.responseText).syncNum;
				var errNum = Ext.decode(response.responseText).errNum;
				var checkMsg = Ext.decode(response.responseText).checkMsg;
				this.grid.getStore().reload();
				if(checkMsg != ""){
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.operation.failed" />'+'<br>'
								+'<fmt:message key="message.import.successful.sync.count" />'
								+userNum+'&nbsp;&nbsp&nbsp;&nbsp'
								+'<fmt:message key="message.import.successful.sync.number" />'
								+syncNum+'&nbsp;&nbsp&nbsp;&nbsp'
								+'<fmt:message key="message.import.successful.sync.errnum" />'
								+errNum+'<br>'
								+'<fmt:message key="message.import.successful.sync.checkmsg" />'+'<br>'
								+checkMsg,
						minWidth : 450,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
				}else{
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.operation.successful" />'+'<br>'
								+'<fmt:message key="message.import.successful.sync.count" />'
								+userNum+'&nbsp;&nbsp'
								+'<fmt:message key="message.import.successful.sync.number" />'
								+syncNum+'&nbsp;&nbsp'
								+'<fmt:message key="message.import.successful.sync.errnum" />'
								+errNum,
						minWidth : 450,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
				}
			}
		},
		syncOperationFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.operation.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		operationSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				this.grid.getStore().reload();
				Ext.Msg.show({
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
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.operation.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
	var userList = new UserList();
</script>

<sec:authorize access="hasRole('USER_ROLE')">
	<script type="text/javascript">
	var config = userList.grid.getColumnModel().config;
	config.push({
		header : '<fmt:message key="role" />',
		dataIndex : 'username',
		align : 'center',
		scope : userList,
		renderer : userList.renderRoleColumn
	});
	userList.grid.reconfigure(userList.gridStore, new Ext.grid.ColumnModel(config));
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_SYSTEM')">
<script type="text/javascript">
	var config = userList.grid.getColumnModel().config;
	config.push({
		header : '系统',
		id : 'usersystem',
		dataIndex : 'username',
		align : 'center',
		scope : userList,
		renderer : userList.renderSystemColumn
	});
	userList.grid.reconfigure(userList.gridStore, new Ext.grid.ColumnModel(config));
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_ENV')">
<script type="text/javascript">
	var config = userList.grid.getColumnModel().config;
	config.push({
		header : '环境',
		id : 'userenv',
		dataIndex : 'username',
		align : 'center',
		scope : userList,
		renderer : userList.renderEnvColumn
	});
	userList.grid.reconfigure(userList.gridStore, new Ext.grid.ColumnModel(config));
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_DELETE')">
	<script type="text/javascript">
	userList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : userList,
		handler : userList.doDelete
	});
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_ENABLE')">
	<script type="text/javascript">
	userList.grid.getTopToolbar().add({
		iconCls : 'button-enabled',
		text : '<fmt:message key="button.enable" />',
		scope : userList,
		handler : userList.doEnable
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_DISABLE')">
	<script type="text/javascript">
	userList.grid.getTopToolbar().add({
		iconCls : 'button-disabled',
		text : '<fmt:message key="button.disable" />',
		scope : userList,
		handler : userList.doDisable
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_SYNC')">
	<script type="text/javascript">
	userList.grid.getTopToolbar().add({
		iconCls : 'button-sync',
		text : '应用发布同步',
		scope : userList,
		handler : userList.doSyncBrpm
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('USER_SYNC')">
	<script type="text/javascript">
	userList.grid.getTopToolbar().add({
		iconCls : 'button-sync',
		text : '巡检同步',
		scope : userList,
		handler : userList.doSyncBsa
	}, '-');
</script>
</sec:authorize>

<script type="text/javascript">
	Ext.getCmp("USER_LIST").add(userList);
	Ext.getCmp("USER_LIST").doLayout();
</script>

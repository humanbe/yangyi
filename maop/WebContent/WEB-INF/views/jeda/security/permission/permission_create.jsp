<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var MainFieldSet = Ext.extend(Ext.form.FieldSet, {
		fieldStore : null, // 字段数据源
		typeStore : null, // 类型数据源
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);
			// 实例化字段数据源
			this.fieldStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/field/function/${param.functionId}',
				root : 'data',
				fields : [ 'id', 'name' ]
			});
			this.fieldStore.load();// 加载字段数据

			// 实例化类型数据源
			this.typeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name', 'cascade' ]
			});
			this.typeStore.load();// 加载类型数据

			MainFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="permission.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'combo',
					store : this.fieldStore,
					fieldLabel : '<fmt:message key="function.field" />',
					name : 'field',
					valueField : 'id',
					displayField : 'name',
					hiddenName : 'field',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false,
					listeners : {
						scope : this,
						select : function(combo, record, index) {
							//this.getForm().findField('fieldVariable').setValue(record.data.id);
						}
					}
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'combo',
					store : this.typeStore,
					fieldLabel : '<fmt:message key="permission.type" />',
					name : 'type',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'hidden',
					name : 'function',
					value : '${param.functionId}',
					hidden : true
				} ]
			});
		}
	});

	var OrgFieldSet = Ext.extend(Ext.form.FieldSet, {
		orgTypeStore : null, // 功能数据源
		uncheckedOrgs : null,
		checkedOrgs : null,
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			this.uncheckedOrgs = new Array();
			this.checkedOrgs = new Array();

			// 实例化机构类型数据源
			this.orgTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_ORG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.orgTypeStore.load();// 加载机构类型数据

			OrgFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'combo',
					store : this.orgTypeStore,
					fieldLabel : '<fmt:message key="permission.org.type" />',
					name : 'orgType',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'orgType',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo, record, index) {
							switch (record.data.value) {
							case '4': {
								this.findByType('treepanel')[0].show();
								break;
							}
							default: {
								this.findByType('treepanel')[0].hide();
								break;
							}
							}
						}
					}
				}, {
					xtype : 'treepanel',
					fieldLabel : '<fmt:message key="org" />',
					name : 'org',
					height : 200,
					autoScroll : true,
					margins : '0 0 0 5',
					hidden : true,
					root : new Ext.tree.AsyncTreeNode({
						text : '<sec:authentication property="principal.org.name"/>',
						draggable : false,
						iconCls : 'node-root',
						id : '<sec:authentication property="principal.org.id"/>'
					}),
					loader : new Ext.tree.TreeLoader({
						requestMethod : 'GET',
						dataUrl : '${ctx}/${frameworkPath}/permission/org'
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.getRootNode().expand(1);
						},
						checkchange : function(node, checked) {
							if (checked) {
								this.checkedOrgs.push(node.id);
								this.uncheckedOrgs.remove(node.id);
							} else {
								this.uncheckedOrgs.push(node.id);
								this.checkedOrgs.remove(node.id);
							}
						}
					}
				} ]
			});
		}
	});
	var UserFieldSet = Ext.extend(Ext.form.FieldSet, {
		userTypeStore : null, // 功能数据源
		uncheckedUsers : null,
		checkedUsers : null,
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			this.uncheckedUsers = new Array();
			this.checkedUsers = new Array();

			// 实例化类型数据源
			this.userTypeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/PERMISSION_TYPE_USER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.userTypeStore.load();// 加载类型数据

			UserFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'combo',
					store : this.userTypeStore,
					fieldLabel : '<fmt:message key="permission.user.type" />',
					name : 'userType',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'userType',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo, record, index) {
							switch (record.data.value) {
							case '2': {
								this.findByType('treepanel')[0].show();
								break;
							}
							default: {
								this.findByType('treepanel')[0].hide();
								break;
							}
							}
						}
					}
				}, {
					xtype : 'treepanel',
					fieldLabel : '<fmt:message key="user" />',
					name : 'org',
					hidden : true,
					height : 200,
					autoScroll : true,
					root : new Ext.tree.AsyncTreeNode({
						text : '<sec:authentication property="principal.org.name"/>',
						draggable : false,
						iconCls : 'node-root',
						id : '<sec:authentication property="principal.org.id"/>'
					}),
					loader : new Ext.tree.TreeLoader({
						requestMethod : 'GET',
						dataUrl : '${ctx}/${frameworkPath}/permission/user'
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.getRootNode().expand(1);
						},
						checkchange : function(node, checked) {
							if (checked) {
								this.checkedUsers.push(node.id);
								this.uncheckedUsers.remove(node.id);
							} else {
								this.uncheckedUsers.push(node.id);
								this.checkedUsers.remove(node.id);
							}

						}
					}
				} ]
			});
		}
	});

	var ItemFieldSet = Ext.extend(Ext.form.FieldSet, {
		itemStore : null, // 数据项数据源
		subitemStore : null, // 数据子项数据源
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			// 实例化数据项数据源
			this.itemStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/permission',
				root : 'data',
				fields : [ 'id', 'name' ]
			});
			this.itemStore.load();// 加载数据项数据

			// 实例化数据子项数据源
			this.subitemStore = new Ext.data.JsonStore({
				autoDestroy : true,
				proxy : new Ext.data.HttpProxy({
					method : 'GET',
					url : '${ctx}/${frameworkPath}/item/sub'
				}),
				root : 'data',
				fields : [ 'value', 'name', 'id' ]
			});
			ItemFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'combo',
					store : this.itemStore,
					fieldLabel : '<fmt:message key="permission.item" />',
					name : 'item',
					valueField : 'id',
					displayField : 'name',
					hiddenName : 'item',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo, record, index) {
							this.subitemStore.load({
								params : {
									itemId : record.data.id
								}
							});// 加载数据子项数据
						}
					}
				}, {
					xtype : 'combo',
					store : this.subitemStore,
					fieldLabel : '<fmt:message key="permission.subitem" />',
					name : 'subitem',
					valueField : 'id',
					displayField : 'name',
					hiddenName : 'subitem',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				} ]
			});
		}
	});
	var ConstantFieldSet = Ext.extend(Ext.form.FieldSet, {
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			ConstantFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="permission.field.value" />',
					name : 'fieldValue',
					tabIndex : this.tabIndex++,
					allowBlank : false
				} ]
			});
		}
	});
	//定义新建表单
	PermissionCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0, // Tab键顺序
		mainFieldSet : null,
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			this.mainFieldSet = new MainFieldSet();

			this.mainFieldSet.findByType('combo')[1].on('select', function(combo, record, index) {
				switch (record.data.value) {
				case 'PERMISSION_TYPE_USER': {
					this.findByType('panel')[0].removeAll();
					this.findByType('panel')[0].add(new UserFieldSet());
					this.findByType('panel')[0].doLayout();
					break;
				}
				case 'PERMISSION_TYPE_ORG': {
					this.findByType('panel')[0].removeAll();
					this.findByType('panel')[0].add(new OrgFieldSet());
					this.findByType('panel')[0].doLayout();
					break;
				}
				case 'PERMISSION_TYPE_ITEM': {
					this.findByType('panel')[0].removeAll();
					this.findByType('panel')[0].add(new ItemFieldSet());
					this.findByType('panel')[0].doLayout();
					break;
				}
				case 'PERMISSION_TYPE_CONSTANT': {
					this.findByType('panel')[0].removeAll();
					this.findByType('panel')[0].add(new ConstantFieldSet());
					this.findByType('panel')[0].doLayout();
					break;
				}
				default: {

				}
				}
			}, this);

			// 设置基类属性
			PermissionCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/permission/create',
				monitorValid : true,
				items : [ this.mainFieldSet, {
					xtype : 'panel'
				} ],
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : this.doSave
				}, {
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					handler : this.doCancel
				} ]
			});
		},
		// 保存操作
		doSave : function() {
			var params = {
				checkedUsers : this.findByType('panel')[0].get(0).checkedUsers,
				uncheckedUsers : this.findByType('panel')[0].get(0).uncheckedUsers,
				checkedOrgs : this.findByType('panel')[0].get(0).checkedOrgs,
				uncheckedOrgs : this.findByType('panel')[0].get(0).uncheckedOrgs
			};
			this.getForm().submit({
				scope : this,
				params : params,
				success : this.saveSuccess,// 保存成功回调函数
				failure : this.saveFailure,// 保存失败回调函数
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('PERMISSION_CREATE');
		},
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {

					app.closeTab('PERMISSION_CREATE');
					var list = Ext.getCmp("PERMISSION_LIST").get(0);

					if (list != null) {
						list.grid.getStore().reload();
					}
					var params = {
						id : action.result.id,
						functionId : '${param.functionId}'
					};

					app.loadTab('PERMISSION_VIEW', '<fmt:message key="button.view" /><fmt:message key="permission" />', '${ctx}/${frameworkPath}/permission/view', params);
				}
			});

		},
		// 保存失败回调
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});

	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("PERMISSION_CREATE").add(new PermissionCreateForm());
	// 刷新Tab页布局
	Ext.getCmp("PERMISSION_CREATE").doLayout();
</script>

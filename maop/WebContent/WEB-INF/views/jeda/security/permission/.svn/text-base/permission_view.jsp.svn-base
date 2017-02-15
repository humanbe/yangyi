<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var MainViewFieldSet = Ext.extend(Ext.form.FieldSet, {
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

			MainViewFieldSet.superclass.constructor.call(this, {
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				border : false,
				items : [ {
					xtype : 'hidden',
					name : 'id',
					hidden : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="permission.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					readOnly : true
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
					readOnly : true
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					readOnly : true
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
					readOnly : true,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'hidden',
					name : 'version',
					hidden : true
				} ]
			});
		}
	});

	var OrgViewFieldSet = Ext.extend(Ext.form.FieldSet, {
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

			OrgViewFieldSet.superclass.constructor.call(this, {
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
					readOnly : true
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
						dataUrl : '${ctx}/${frameworkPath}/permission/${param.id}/org'
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.getRootNode().expand(1);
						}
					}
				} ]
			});
		}
	});
	var UserViewFieldSet = Ext.extend(Ext.form.FieldSet, {
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

			UserViewFieldSet.superclass.constructor.call(this, {
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
					readOnly : true
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
						dataUrl : '${ctx}/${frameworkPath}/permission/user',
						baseParams : {
							permissionId : '${param.id}'
						}
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.getRootNode().expand(1);
						}
					}
				} ],
				listeners : {
					show : function(fieldSet) {
						if (fieldSet.findByType('combo')[0].getValue() == 2) {
							this.findByType('treepanel')[0].show();
						}
					}
				}
			});
		}
	});

	var ItemViewFieldSet = Ext.extend(Ext.form.FieldSet, {
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

			ItemViewFieldSet.superclass.constructor.call(this, {
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
					readOnly : true
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
					readOnly : true,
					tabIndex : this.tabIndex++
				} ]
			});
		}
	});
	var ConstantViewFieldSet = Ext.extend(Ext.form.FieldSet, {
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			ConstantViewFieldSet.superclass.constructor.call(this, {
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
					readOnly : true
				} ]
			});
		}
	});
	//定义表单
	PermissionViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0, // Tab键顺序
		mainFieldSet : null,
		userFieldSet : null,
		orgFieldSet : null,
		itemFieldSet : null,
		constantFieldSet : null,
		constructor : function(cfg) { // 构造方法
			Ext.apply(this, cfg);

			this.mainFieldSet = new MainViewFieldSet();
			this.userFieldSet = new UserViewFieldSet();
			this.orgFieldSet = new OrgViewFieldSet();
			this.itemFieldSet = new ItemViewFieldSet();
			this.constantFieldSet = new ConstantViewFieldSet();
			this.userFieldSet.setVisible(false);
			this.orgFieldSet.setVisible(false);
			this.itemFieldSet.setVisible(false);
			this.constantFieldSet.setVisible(false);

			// 设置基类属性
			PermissionViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/permission/edit',
				monitorValid : true,
				items : [ this.mainFieldSet, {
					xtype : 'panel',
					items : [ this.userFieldSet, this.orgFieldSet, this.itemFieldSet, this.constantFieldSet ]
				} ],
				buttons : [ {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doClose
				} ]
			});
			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/permission/view/${param.id}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess
			});
		},
		// 关闭操作
		doClose : function() {
			app.closeTab('PERMISSION_VIEW');
		},
		// 数据加载失败回调
		loadFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		loadSuccess : function(form, action) {
			switch (action.result.data.type) {
			case 'PERMISSION_TYPE_USER': {
				this.findByType('panel')[0].remove(this.orgFieldSet);
				this.findByType('panel')[0].remove(this.itemFieldSet);
				this.findByType('panel')[0].remove(this.constantFieldSet);
				this.findByType('panel')[0].get(0).setVisible(true);
				this.findByType('panel')[0].doLayout();
				break;
			}
			case 'PERMISSION_TYPE_ORG': {
				this.findByType('panel')[0].remove(this.userFieldSet);
				this.findByType('panel')[0].remove(this.itemFieldSet);
				this.findByType('panel')[0].remove(this.constantFieldSet);
				this.findByType('panel')[0].get(0).setVisible(true);
				if (this.findByType('panel')[0].get(0).findByType('combo')[0].getValue() == '4') {
					this.findByType('panel')[0].get(0).findByType('treepanel')[0].setVisible(true);
				}
				this.findByType('panel')[0].doLayout();
				break;
			}
			case 'PERMISSION_TYPE_ITEM': {
				this.findByType('panel')[0].remove(this.userFieldSet);
				this.findByType('panel')[0].remove(this.orgFieldSet);
				this.findByType('panel')[0].remove(this.constantFieldSet);
				this.findByType('panel')[0].get(0).setVisible(true);
				this.findByType('panel')[0].get(0).subitemStore.load({
					params : {
						itemId : action.result.data.item
					},
					callback : function(records, options, success) {
						this.findByType('panel')[0].get(0).findByType('combo')[1].setValue(action.result.data.subitem);
					},
					scope : this
				});// 加载数据项数据

				this.findByType('panel')[0].doLayout();
				break;
			}
			case 'PERMISSION_TYPE_CONSTANT': {
				this.findByType('panel')[0].remove(this.userFieldSet);
				this.findByType('panel')[0].remove(this.orgFieldSet);
				this.findByType('panel')[0].remove(this.itemFieldSet);
				this.findByType('panel')[0].get(0).setVisible(true);
				this.findByType('panel')[0].doLayout();
				break;
			}
			default: {
				break;
			}
			}
		}
	});

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("PERMISSION_VIEW").add(new PermissionViewForm());
	// 刷新Tab页布局
	Ext.getCmp("PERMISSION_VIEW").doLayout();
</script>
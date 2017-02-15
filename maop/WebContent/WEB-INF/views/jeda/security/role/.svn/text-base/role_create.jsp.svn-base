<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义角色新建表单
	RoleCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		typeStore : null,
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 实例化类型数据源
			this.typeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/ROLE_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.typeStore.load();// 加载类型数据
			// 设置基类属性
			RoleCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/role/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				// 定义表单组件
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="role.id" />',
					name : 'id',
					vtype : 'alphanum',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="role.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'combo',
					store : this.typeStore,
					fieldLabel : '<fmt:message key="role.type" />',
					name : 'type',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="role.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					allowBlank : true
				} ],
				// 定义按钮
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
			this.getForm().submit({
				scope : this,
				success : this.saveSuccess,// 保存成功回调函数
				failure : this.saveFailure,// 保存失败回调函数
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('add_role');
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
					app.closeTab('add_role');// 关闭新建页面
					var grid = Ext.getCmp("roleListGridPanel");// 获取列表组件
					// 若列表组件未被关闭,则刷新其数据源
					if (grid != null) {
						grid.getStore().reload();
					}
					var params = {
						id : action.result.id
					};
					// 打开查看页面
					app.loadTab('view_role', '<fmt:message key="button.view" /><fmt:message key="role" />', '${ctx}/${frameworkPath}/role/view', params);
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

	// 实例化角色新建表单,并加入到Tab页中
	Ext.getCmp("add_role").add(new RoleCreateForm());
	// 刷新Tab页布局
	Ext.getCmp("add_role").doLayout();
</script>
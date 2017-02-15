<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义功能新建表单
	FunctionCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		moduleStore : null,//模块数据源
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 实例化模块数据源
			this.moduleStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/module/get',
				root : 'data',
				fields : [ 'id', 'name' ]
			});
			this.moduleStore.load();// 加载模块数据

			// 设置基类属性
			FunctionCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/function/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				// 定义表单组件
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="function.id" />',
					name : 'id',
					vtype : 'alphanum',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="function.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'combo',
					store : this.moduleStore,
					fieldLabel : '<fmt:message key="function.module" />',
					name : 'module',
					valueField : 'id',
					displayField : 'name',
					hiddenName : 'module',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="function.url" />',
					name : 'url',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="function.has.permission" />',
					name : 'hasPermission',
					tabIndex : this.tabIndex++
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
					scope : this,
					handler : this.doCancel
				} ]
			});
		},
		// 保存操作
		doSave : function() {
			this.getForm().submit({
				scope : this,
				success : this.saveSuccess,
				failure : this.saveFailure,
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		//取消操作
		doCancel : function() {
			app.closeTab('FUNCTION_CREATE');
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
					app.closeTab('FUNCTION_CREATE');
					var list = Ext.getCmp("FUNCTION_LIST").get(0);
					if (list != null) {
						list.grid.getStore().reload();
					}
					var params = {
						id : action.result.id
					};
					app.loadTab('FUNCTION_VIEW', '<fmt:message key="button.view" /><fmt:message key="function" />', '${ctx}/${frameworkPath}/function/view', params);
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
	// 实例化功能新建表单,并加入到Tab页中
	Ext.getCmp("FUNCTION_CREATE").add(new FunctionCreateForm());
	// 刷新Tab页布局
	Ext.getCmp("FUNCTION_CREATE").doLayout();
</script>

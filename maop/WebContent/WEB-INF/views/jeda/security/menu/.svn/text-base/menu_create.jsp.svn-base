<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	MenuCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 设置基类属性
			MenuCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/menu/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.id" />',
					name : 'id',
					vtype : 'alphanum',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.url" />',
					name : 'url',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="menu.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="menu.iframe" />',
					name : 'iframe',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="menu.open.in.home" />',
					name : 'openInHome',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'hidden',
					name : 'parent',
					value : '${param.parent}',
					hidden : true
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
		// 取消操作
		doCancel : function() {
			app.closeTab('add_menu');
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
					app.closeTab('add_menu');
					var grid = Ext.getCmp("menuListGridPanel");
					if (grid != null) {
						grid.getStore().reload();
					}
					var params = {
						id : action.result.id
					};
					app.loadTab('view_menu', '<fmt:message key="button.view" /><fmt:message key="menu" />', '${ctx}/${frameworkPath}/menu/view', params);
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

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("add_menu").add(new MenuCreateForm());
	// 刷新Tab页布局
	Ext.getCmp("add_menu").doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义修改表单
	PropertyEditForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			PropertyEditForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				labelWidth : 150,
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/config/property/edit/${param.id}',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				// 定义表单组件
				items : [ {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="property.tabSize" />',
					name : 'tabSize',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.fileRoot" />',
					name : 'fileRoot',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.copyright" />',
					name : 'copyright',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appTitle" />',
					name : 'appTitle',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="property.treeMenu" />',
					name : 'treeMenu',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'hidden',
					name : '_treeMenu',
					hidden : true
				}, {
					xtype : 'hidden',
					name : 'version',
					hidden : true
				} ],
				// 定义表单按钮
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : this.doSave
				} ]
			});
			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/config/property/find',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure
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
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
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
				icon : Ext.MessageBox.INFO
			});
		}
	});

	// 实例化修改表单,并加入到Tab页中
	Ext.getCmp("PROPERTY_EDIT").add(new PropertyEditForm());
	// 刷新Tab页布局
	Ext.getCmp("PROPERTY_EDIT").doLayout();
</script>

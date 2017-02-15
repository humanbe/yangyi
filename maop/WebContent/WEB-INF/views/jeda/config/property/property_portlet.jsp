<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义修改表单
	PropertyPortlet = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			PropertyPortlet.superclass.constructor.call(this, {
				labelAlign : 'right',
				labelWidth : 120,
				buttonAlign : 'center',
				autoScroll : true,
				defaults : {
					anchor : '95%',
					msgTarget : 'side'
				},
				monitorValid : true,
				// 定义表单组件
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.tabSize" />',
					name : 'tabSize',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.fileRoot" />',
					name : 'fileRoot',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.copyright" />',
					name : 'copyright',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appTitle" />',
					name : 'appTitle',
					tabIndex : this.tabIndex++,
					readOnly : true
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

	// 实例化门户首页的应用实例
	if (Ext.getCmp("PORTAL_PROPERTY_PORTLET") != null && Ext.getCmp("PORTAL_PROPERTY_PORTLET").findById("PORTAL-PROPERTY-PORTLET") == null) {
		Ext.getCmp("PORTAL_PROPERTY_PORTLET").add(new PropertyPortlet({
			id : 'PORTAL-PROPERTY-PORTLET'
		}));
		Ext.getCmp("PORTAL_PROPERTY_PORTLET").doLayout();
	}
	// 实例化岗位设置门户应用的实例
	else if (Ext.getCmp("POSITION_PROPERTY_PORTLET") != null) {
		Ext.getCmp("POSITION_PROPERTY_PORTLET").add(new PropertyPortlet());
		Ext.getCmp("POSITION_PROPERTY_PORTLET").doLayout();
	}
</script>

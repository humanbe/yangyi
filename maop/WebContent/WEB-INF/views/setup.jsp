<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	Ext.apply(Ext.form.VTypes, {
		comfirmPwd : function(val, field) {
			if (field.compare) {
				var password = Ext.getCmp(field.compare);
				return (val == password.getValue());
			}
			return true;
		},
		comfirmPwdText : '<fmt:message key="message.password.mismatch" />!'
	});
	var SetupForm = Ext.extend(Ext.TabPanel, {
		tabIndex : 0,
		personalInfoTab : null,
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			this.personalInfoTab = new Ext.FormPanel({
				title : '<fmt:message key="application.setup.changepassword" />',
				frame : true,
				labelAlign : 'right',
				autoScroll : true,
				border : false,
				defaultType : 'textfield',
				url : '${ctx}/${frameworkPath}/user/changepassword',
				defaults : {
					anchor : '90%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					inputType : 'password',
					fieldLabel : '<fmt:message key="application.setup.current.password" />',
					name : 'currentPassword',
					allowBlank : false
				}, new Ext.ux.PasswordMeter({
					inputType : 'password',
					fieldLabel : '<fmt:message key="application.setup.new.password" />',
					id : 'newPassword',
					name : 'newPassword',
					allowBlank : false
				}), {
					inputType : 'password',
					fieldLabel : '<fmt:message key="application.setup.comfirm.password" />',
					name : 'confirmPassword',
					vtype : 'comfirmPwd',
					compare : 'newPassword',
					allowBlank : false
				} ],
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : function() {
						this.personalInfoTab.getForm().submit({
							success : this.saveSuccess,
							failure : this.saveFailure,
							waitTitle : '<fmt:message key="message.wait" />',
							waitMsg : '<fmt:message key="message.saving" />'
						});
					}
				}, {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					handler : function() {
						app.closeWindow();
					}
				} ]
			});
			// 设置基类属性
			SetupForm.superclass.constructor.call(this, {
				activeTab : 0,
				border : false,
				items : [ this.personalInfoTab ]
			});
		},
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
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
	app.window.get(0).add(new SetupForm());
	app.window.get(0).doLayout();
</script>
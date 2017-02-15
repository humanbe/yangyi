<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义修改表单
	sboxAddSuggestionPanel = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		form:null,
		constructor : function(cfg) {// 构造方法
			// 设置基类属性
			sboxAddSuggestionPanel.superclass.constructor.call(this, {
				title : '<fmt:message key="sbox" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${frameworkPath}/config/sbox/suggestionAdd',
				defaults : {
					anchor : '85%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [ {
							    xtype : 'textarea',
								fieldLabel : '<fmt:message key="sbox.sbox_input" />',
								height:220,
								name : 'sbox_value',
								allowBlank : false
							} 
						],
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					formBind : true,
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
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					app.closeWindow();// 关闭新建页面
					Ext.getCmp("sBoxInfo").getStore().reload();
				}
			});

		},
		// 保存失败回调
		saveFailure : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.too_long" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		},
		doCancel:function(){
			app.closeWindow();
		}
	});

	var sboxAddSuggestionPanel = new sboxAddSuggestionPanel();
	app.window.get(0).add(sboxAddSuggestionPanel);
	app.window.get(0).doLayout();
</script>

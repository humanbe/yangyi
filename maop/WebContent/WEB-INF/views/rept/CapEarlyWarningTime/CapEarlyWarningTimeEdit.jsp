<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
CapEarlyWarningTimeEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性		CapEarlyWarningTimeEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/capearlywarningtime/edit/${param.aplCode}/${param.busiKeyDate}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.aplCode" />',
					name : 'aplCode',
					tabIndex : this.tabIndex++,
					allowBlank : false,
					disabled : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.busiKeyDate" />',
					name : 'busiKeyDate',
					allowBlank : false,
					disabled : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.summaryDesc" />',
					name : 'summaryDesc',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.riskDesc" />',
					name : 'riskDesc',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.handleTactics" />',
					name : 'handleTactics',
					maxLength : 500,
					height : 80,
					allowBlank : true
				}
	 		],
			// 定义按钮
			buttons : [ {
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				formBind : true,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				handler : this.doCancel
			} ]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/capearlywarningtime/view/${param.aplCode}/${param.busiKeyDate}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure
		});
	},
	// 保存操作
	doSave : function() {
		this.getForm().submit( {
			scope : this,
			success : this.saveSuccess,
			failure : this.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	// 取消操作
	doCancel : function() {
		app.closeTab('edit_CapEarlyWarningTime');
	},
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				var params = {
					aplCode : '${param.aplCode}',
					busiKeyDate : '${param.busiKeyDate}'
				};
				app.closeTab('edit_CapEarlyWarningTime');
				var grid = Ext.getCmp("CapEarlyWarningTimeListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_CapEarlyWarningTime', '<fmt:message key="button.view" /><fmt:message key="property.capearlywarningtime" />', '${ctx}/${managePath}/capearlywarningtime/view', params);
			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});
// 实例化新建表单,并加入到Tab页中
Ext.getCmp("edit_CapEarlyWarningTime").add(new CapEarlyWarningTimeEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_CapEarlyWarningTime").doLayout();
</script>
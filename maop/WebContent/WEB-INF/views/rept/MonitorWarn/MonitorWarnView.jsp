<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
MonitorWarnViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		MonitorWarnViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					name : 'aplCode',
					readOnly : true
				},
				{
					xtype : 'textfield',
					name : 'changeDate',
					fieldLabel : '<fmt:message key="property.changeDate" />',
					allowBlank : false,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.monitorEffectContent" />',
					name : 'monitorEffectContent',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.deviceName" />',
					name : 'deviceName',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					name : 'ipAddress',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainDevice" />',
					name : 'explainDevice',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainMonitorPlatform" />',
					name : 'explainMonitorPlatform',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainMonitorTool" />',
					name : 'explainMonitorTool',
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('不忽略告警');break;
							case '1' : this.setRawValue('忽略告警');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainMonitorScreen" />',
					name : 'explainMonitorScreen',
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('不忽略告警');break;
							case '1' : this.setRawValue('忽略告警');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.effectStartTime" />',
					name : 'effectStartTime',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.effectEndTime" />',
					name : 'effectEndTime',
					readOnly : true
				}
			],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				scope : this,
				handler : this.doClose
			} ]
		});
		
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/monitorwarn/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				changeDate : '${param.changeDate}'
			},
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	// 关闭操作
	doClose : function() {
		app.closeTab('view_MonitorWarn');
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
Ext.getCmp("view_MonitorWarn").add(new MonitorWarnViewForm());
// 刷新Tab页布局
Ext.getCmp("view_MonitorWarn").doLayout();
</script>
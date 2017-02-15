<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var warnStore = new Ext.data.SimpleStore({
	fields : ['monitorWarnValue', 'monitorWarnDisplay'],
	data : [['1', '忽略告警'], ['0', '不忽略告警']]
});
MonitorWarnEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 设置基类属性
		MonitorWarnEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/monitorwarn/edit/${param.aplCode}/${param.changeDate}',
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
					disabled : true
				},
				{
					xtype : 'textfield',
					name : 'changeDate',
					fieldLabel : '<fmt:message key="property.changeDate" />',
					disabled : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.monitorEffectContent" />',
					maxLength : 20,
					name : 'monitorEffectContent'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.deviceName" />',
					maxLength : 10,
					name : 'deviceName'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					maxLength : 15,
					name : 'ipAddress'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainDevice" />',
					maxLength : 50,
					name : 'explainDevice'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.explainMonitorPlatform" />',
					maxLength : 50,
					name : 'explainMonitorPlatform'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.explainMonitorTool" />',
					store : warnStore,
					displayField : 'monitorWarnDisplay',
					valueField : 'monitorWarnValue',
					hiddenName : 'explainMonitorTool',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.explainMonitorScreen" />',
					store : warnStore,
					displayField : 'monitorWarnDisplay',
					valueField : 'monitorWarnValue',
					hiddenName : 'explainMonitorScreen',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'timefield',
					fieldLabel : '<fmt:message key="property.effectStartTime" />',
					name : 'effectStartTime',
					format : 'H:i',
					increment : 30
				},
				{
					xtype : 'timefield',
					fieldLabel : '<fmt:message key="property.effectEndTime" />',
					name : 'effectEndTime',
					format : 'H:i',
					increment : 30
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
			url : '${ctx}/${managePath}/monitorwarn/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				changeDate : '${param.changeDate}'
			},
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
		app.closeTab('edit_MonitorWarn');
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
					changeDate : '${param.changeDate}'
				};
				app.closeTab('edit_MonitorWarn');
				var grid = Ext.getCmp("MonitorWarnListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_MonitorWarn', 
						'<fmt:message key="button.view" /><fmt:message key="property.monitorWarnInfo" />', 
						'${ctx}/${managePath}/monitorwarn/view', 
						params);
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
Ext.getCmp("edit_MonitorWarn").add(new MonitorWarnEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_MonitorWarn").doLayout();
</script>
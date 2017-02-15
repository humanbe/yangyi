<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var sysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appconfigmanage/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
});

var warnStore = new Ext.data.SimpleStore({
	fields : ['monitorWarnValue', 'monitorWarnDisplay'],
	data : [['1', '忽略告警'], ['0', '不忽略告警']]
});

//定义新建表单
MonitorWarnCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysIdsStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		MonitorWarnCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/monitorwarn/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font> <fmt:message key="property.appsystemname" />',
					store : sysIdsStore,
					displayField : 'sysName',
					valueField : 'sysId',
					hiddenName : 'aplCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					selectOnFocus : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						 'beforequery' : function(e){
							var combo = e.combo;
							combo.collapse();
							 if(!e.forceAll){
								var input = e.query.toUpperCase();
								var regExp = new RegExp('.*' + input + '.*');
								combo.store.filterBy(function(record, id){
									var text = record.get(combo.displayField);
									return regExp.test(text);
								}); 
								combo.restrictHeight();
								combo.expand();
								return false;
							} 
						},
						'select' : function(combo, record, index){
							var form = this.getForm();
							var changeDate = form.findField('changeDate').getValue();
							form.findField('effectStartTime').setValue();
							form.findField('effectEndTime').setValue();
							if(changeDate != ''){
								changeDate = Ext.util.Format.date(changeDate, 'Ymd');
								var effectTimeStore = new Ext.data.Store({
									proxy: new Ext.data.HttpProxy({
										url : '${ctx}/${managePath}/monitorwarn/queryEffectTime?aplCode=' + record.data.sysId.substring(4) + '&changeDate=' + changeDate,
										method : 'GET',
										disableCaching : true
									}),
									reader : new Ext.data.JsonReader({}, ['planStartTime','planEndTime'])
								});
								effectTimeStore.load();
								effectTimeStore.on('load', function(){
									form.findField('effectStartTime').setValue(effectTimeStore.getAt(0).data.planStartTime);
									form.findField('effectEndTime').setValue(effectTimeStore.getAt(0).data.planEndTime);
								});
							}
						}
					}
				},
				{
					xtype : 'datefield',
					name : 'changeDate',
					fieldLabel : '<font color=red>*</font> <fmt:message key="property.changeDate" />',
					allowBlank : false,
					value : new Date(),
					format : 'Ymd'
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
	},
	// 保存操作
	doSave : function() {
		var aplCode = this.getForm().findField('aplCode').getValue().substring(4);
		this.getForm().findField('aplCode').setValue(aplCode);
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
		app.closeTab('add_MonitorWarn');
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
				app.closeTab('add_MonitorWarn');
				var grid = Ext.getCmp("MonitorWarnListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					changeDate : action.result.changeDate
				};
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
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("add_MonitorWarn").add(new MonitorWarnCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_MonitorWarn").doLayout();

</script>
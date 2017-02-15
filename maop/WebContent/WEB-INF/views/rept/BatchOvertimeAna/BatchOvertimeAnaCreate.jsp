<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var overtimeFlagStore = new Ext.data.SimpleStore({
	fields : ['overtimeFlagValue', 'overtimeFlagDisplay'],
	data : [['0', '否'], ['1', '是']]
});

//容量风险分类
var capaRiskTypeStore = new Ext.data.ArrayStore({
    fields: ['capaRiskTypeValue', 'capaRiskTypeDisplay'],
    data : [['1', '业务容量'],
            	['2', '应用容量'],
            	['3', '资源容量']]});

//定义新建表单
BatchOvertimeAnaCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
	
		var sysIdsStore = new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/capearlywarningtime/querySystemIDAndNames',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
		});
		sysIdsStore.load();
		
		// 设置基类属性		BatchOvertimeAnaCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/batchovertimeana/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
	{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.jobName" />',
					name : 'jobName'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appSysCd" />',
					emptyText : '<fmt:message key="message.select.one.only" />',
					store : sysIdsStore,
					displayField : 'sysName',
					valueField : 'sysId',
					hiddenName : 'appSysCd',
					mode : 'local',
					typeAhead : true,
					forceSelection : true,
					triggerAction : 'all',
					allowBlank : false,
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
						}
					}
				}, 
				{
					xtype : 'datetimefield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					dateFormat :'Ymd',
					timeFormat : 'H:i:s'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.overtimeFlag" />',
					store : overtimeFlagStore,
					displayField : 'overtimeFlagDisplay',
					valueField : 'overtimeFlagValue',
					editable : false,
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					hiddenName : 'overtimeFlag'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.capaRiskType" />',
					store : capaRiskTypeStore,
					displayField : 'capaRiskTypeDisplay',
					valueField : 'capaRiskTypeValue',
					editable : false, 
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					hiddenName : 'capaRiskType'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.jobDesc" />',
					name : 'jobDesc',
					format : 'Ymd',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.jobEffect" />',
					name : 'jobEffect',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.errorCauseAna" />',
					name : 'errorCauseAna',
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
		app.closeTab('add_BatchOvertimeAna');
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
				app.closeTab('add_BatchOvertimeAna');
				var grid = Ext.getCmp("BatchOvertimeAnaListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
						jobName : action.result.jobName,
						errorTime : action.result.errorTime
				};
				app.loadTab('view_BatchOvertimeAna', 
						'<fmt:message key="button.view" /><fmt:message key="property.batchovertimeana" />', 
						'${ctx}/${managePath}/batchovertimeana/view', params);
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
Ext.getCmp("add_BatchOvertimeAna").add(new BatchOvertimeAnaCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_BatchOvertimeAna").doLayout();
</script>
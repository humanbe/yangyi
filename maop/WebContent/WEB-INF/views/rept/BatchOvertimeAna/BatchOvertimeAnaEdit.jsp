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
BatchOvertimeAnaEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性		BatchOvertimeAnaEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/batchovertimeana/edit/${param.jobName}/${param.errorTime}',
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
					name : 'jobName',
					tabIndex : this.tabIndex++,
					allowBlank : false,
					disabled : true
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					emptyText : '<fmt:message key="message.select.one.only" />',
					store : sysIdsStore,
					displayField : 'sysName',
					valueField : 'sysId',
					hiddenName : 'appSysCd',
					mode : 'local',
					typeAhead : true,
					forceSelection : true,
					triggerAction : 'all',
					allowBlank : true,
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
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					allowBlank : false,
					disabled : true
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
					hiddenName : 'overtimeFlag',
					allowBlank : true
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
					hiddenName : 'capaRiskType',
					allowBlank : true
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
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/batchovertimeana/view',
			method : 'POST',
			params : {
				jobName : '${param.jobName}',
				errorTime : '${param.errorTime}'
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
		app.closeTab('edit_BatchOvertimeAna');
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
						jobName : '${param.jobName}',
					errorTime : '${param.errorTime}'
				};
				app.closeTab('edit_BatchOvertimeAna');
				var grid = Ext.getCmp("BatchOvertimeAnaListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_BatchOvertimeAna', '<fmt:message key="button.view" /><fmt:message key="property.batchovertimeana" />', '${ctx}/${managePath}/batchovertimeana/view', params);
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
Ext.getCmp("edit_BatchOvertimeAna").add(new BatchOvertimeAnaEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_BatchOvertimeAna").doLayout();
</script>
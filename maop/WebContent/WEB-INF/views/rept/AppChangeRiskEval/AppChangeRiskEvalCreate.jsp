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

var changeRiskEvalStore = new Ext.data.SimpleStore({
	fields : ['changeRiskEvalValue', 'changeRiskEvalDisplay'],
	data : [['1', '低'], ['2', '中'], ['3', '高']]
});
//定义新建表单
AppChangeRiskEvalCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		sysIdsStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性		AppChangeRiskEvalCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/appchangeriskeval/create',
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
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
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
					xtype : 'datefield',
					name : 'changeDate',
					fieldLabel : '<font color=red>*</font> <fmt:message key="property.changeDate" />',
					allowBlank : false,
					value : new Date(),
					format : 'Ymd'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.changeRiskEval" />',
					store : changeRiskEvalStore, 
					displayField : 'changeRiskEvalDisplay',
					valueField : 'changeRiskEvalValue',
					hiddenName : 'changeRiskEval',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.stopServiceTime" />',
					maxLength : 30,
					name : 'stopServiceTime'
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.primaryChangeRisk" />',
					name : 'primaryChangeRisk',
					height : 150
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.riskHandleMethod" />',
					name : 'riskHandleMethod',
					height : 150
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.other" />',
					maxLength : 50,
					name : 'other'
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
		app.closeTab('add_AppChangeRiskEval');
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
				app.closeTab('add_AppChangeRiskEval');
				var grid = Ext.getCmp("AppChangeRiskEvalListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					changeDate : action.result.changeDate
				};
				app.loadTab('view_AppChangeRiskEval', 
						'<fmt:message key="button.view" /><fmt:message key="property.appChangeRiskEval" />', 
						'${ctx}/${managePath}/appchangeriskeval/view', 
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
Ext.getCmp("add_AppChangeRiskEval").add(new AppChangeRiskEvalCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_AppChangeRiskEval").doLayout();

</script>
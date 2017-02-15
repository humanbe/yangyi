<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var changeRiskEvalStore = new Ext.data.SimpleStore({
	fields : ['changeRiskEvalValue', 'changeRiskEvalDisplay'],
	data : [['1', '低'], ['2', '中'], ['3', '高']]
});
AppChangeRiskEvalEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 设置基类属性
		AppChangeRiskEvalEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/appchangeriskeval/edit/${param.aplCode}/${param.changeDate}',
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
					name : 'stopServiceTime',
					maxLength : 30,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.primaryChangeRisk" />',
					name : 'primaryChangeRisk',
					height : 150,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.riskHandleMethod" />',
					name : 'riskHandleMethod',
					height : 150,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.other" />',
					name : 'other',
					maxLength : 50,
					tabIndex : this.tabIndex++
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
			url : '${ctx}/${managePath}/appchangeriskeval/view',
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
		app.closeTab('edit_AppChangeRiskEval');
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
				app.closeTab('edit_AppChangeRiskEval');
				var grid = Ext.getCmp("AppChangeRiskEvalListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
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
Ext.getCmp("edit_AppChangeRiskEval").add(new AppChangeRiskEvalEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_AppChangeRiskEval").doLayout();
</script>
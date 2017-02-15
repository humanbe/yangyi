<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AppChangeRiskEvalViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		AppChangeRiskEvalViewForm.superclass.constructor.call(this, {
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
					fieldLabel : '<fmt:message key="property.changeRiskEval" />',
					name : 'changeRiskEval',
					setValue : function(value){
						switch(value){
							case '1' : this.setRawValue('低');break;
							case '2' : this.setRawValue('中');break;
							case '3' : this.setRawValue('高');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.stopServiceTime" />',
					name : 'stopServiceTime',
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.primaryChangeRisk" />',
					name : 'primaryChangeRisk',
					height : 150,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.riskHandleMethod" />',
					name : 'riskHandleMethod',
					height : 150,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.other" />',
					name : 'other',
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
			url : '${ctx}/${managePath}/appchangeriskeval/view',
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
		app.closeTab('view_AppChangeRiskEval');
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
Ext.getCmp("view_AppChangeRiskEval").add(new AppChangeRiskEvalViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AppChangeRiskEval").doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AppChangeSummaryViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		AppChangeSummaryViewForm.superclass.constructor.call(this, {
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
					fieldLabel : '<fmt:message key="property.time" />',
					name : 'time',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.type" />',
					name : 'type',
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.phenomenon" />',
					name : 'phenomenon',
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.cause" />',
					name : 'cause',
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.handleMethod" />',
					name : 'handleMethod',
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.improveMethod" />',
					name : 'improveMethod',
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
			url : '${ctx}/${managePath}/appchangesummary/view',
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
		app.closeTab('view_AppChangeSummary');
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
Ext.getCmp("view_AppChangeSummary").add(new AppChangeSummaryViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AppChangeSummary").doLayout();
</script>
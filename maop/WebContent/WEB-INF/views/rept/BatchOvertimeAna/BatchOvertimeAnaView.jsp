<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
BatchOvertimeAnaViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性		BatchOvertimeAnaViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
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
					fieldLabel : '<fmt:message key="property.jobName" />',
					name : 'jobName',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appSysCd" />',
					name : 'appSysCd',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.jobDesc" />',
					name : 'jobDesc',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.overtimeFlag" />',
					name : 'overtimeFlag',
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('否');break;
							case '1' : this.setRawValue('是');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.capaRiskType" />',
					name : 'capaRiskType',
					setValue : function(value){
						switch(value){
							case '1' : this.setRawValue('业务容量');break;
							case '2' : this.setRawValue('应用容量');break;
							case '3' : this.setRawValue('资源容量');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.jobEffect" />',
					name : 'jobEffect',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.errorCauseAna" />',
					name : 'errorCauseAna',
					height : 80,
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
			url : '${ctx}/${managePath}/batchovertimeana/view',
			method : 'POST',
			params : {
				jobName : '${param.jobName}',
				errorTime : '${param.errorTime}'
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
		app.closeTab('view_BatchOvertimeAna');
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
Ext.getCmp("view_BatchOvertimeAna").add(new BatchOvertimeAnaViewForm());
// 刷新Tab页布局
Ext.getCmp("view_BatchOvertimeAna").doLayout();
</script>
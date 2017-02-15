<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
TypicalCapaAnaViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性		TypicalCapaAnaViewForm.superclass.constructor.call(this, {
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
					fieldLabel : '<fmt:message key="property.sysseqnum" />',
					name : 'sysseqnum',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appSysCd" />',
					name : 'appSysCd',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.riskType" />',
					name : 'riskType',
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
					fieldLabel : '<fmt:message key="property.workorderSubject" />',
					name : 'workorderSubject',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.caseCause" />',
					name : 'caseCause',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.handleMethod" />',
					name : 'handleMethod',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.optimizePlan" />',
					name : 'optimizePlan',
					height : 80,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.caseAna" />',
					name : 'caseAna',
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
			url : '${ctx}/${managePath}/typicalcapaana/view',
			method : 'POST',
			params : {
				sysseqnum : '${param.sysseqnum}'
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
		app.closeTab('view_TypicalCapaAnaView');
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
Ext.getCmp("view_TypicalCapaAnaView").add(new TypicalCapaAnaViewForm());
// 刷新Tab页布局
Ext.getCmp("view_TypicalCapaAnaView").doLayout();
</script>
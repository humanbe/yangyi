<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
WeblogicConfManageViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		// 设置基类属性		WeblogicConfManageViewForm.superclass.constructor.call(this, {
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
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					name : 'ipAddress',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serverName" />',
					name : 'serverName',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '服务JDBC名称',
					name : 'serverJdbcName',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.weblogicFlg" />',
					name : 'weblogicFlg',
					readOnly : true,
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('定时导入');break;
							case '1' : this.setRawValue('不导入');break;
						}
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.clusterServer" />',
					name : 'clusterServer',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.weblogicPort" />',
					name : 'weblogicPort',
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
			url : '${ctx}/${managePath}/weblogicconfmanage/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				ipAddress : '${param.ipAddress}',
				serverName : '${param.serverName}',
				serverJdbcName : '${param.serverJdbcName}',
				weblogicPort : '${param.weblogicPort}'
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
		app.closeTab('view_WeblogicConfManage');
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
Ext.getCmp("view_WeblogicConfManage").add(new WeblogicConfManageViewForm());
// 刷新Tab页布局
Ext.getCmp("view_WeblogicConfManage").doLayout();
</script>
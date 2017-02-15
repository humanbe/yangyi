<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var weblogicFlgStore = new Ext.data.SimpleStore({
	fields : ['weblogicFlgDisplay', 'weblogicFlgValue'],
	data : [['定时导入', '0'], ['不导入', '1']]
});
WeblogicConfEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		// 设置基类属性		WeblogicConfEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/weblogicconfmanage/edit/${param.aplCode}/${param.ipAddress}/${param.serverName}/${param.weblogicPort}',
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
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					disabled : true,
					name : 'ipAddress'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.weblogicServer" />',
					disabled : true,
					name : 'serverName'
				},
				{
					xtype : 'textfield',
					fieldLabel : '服务JDBC名称',
					name : 'serverJdbcName',
					emptyText : '多个jdbc以逗号分隔'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.weblogicFlg" />',
					hiddenName : 'weblogicFlg',
					store : weblogicFlgStore,
					displayField : 'weblogicFlgDisplay',
					valueField : 'weblogicFlgValue',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.clusterServer" />',
					maxLength : 20,
					allowBlank : false,
					name : 'clusterServer'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.weblogicPort" />',
					disabled : true,
					name : 'weblogicPort'
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
			url : '${ctx}/${managePath}/weblogicconfmanage/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				ipAddress : '${param.ipAddress}',
				serverName : '${param.serverName}',
				weblogicPort : '${param.weblogicPort}'
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
		app.closeWindow();
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
				app.closeWindow();
				Ext.getCmp("WeblogicConfGridPanel").getStore().reload();
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

//实例化新建表单,并加入到Tab页中
app.window.get(0).add(new WeblogicConfEditForm());
//刷新Tab页布局
app.window.get(0).doLayout();
</script>
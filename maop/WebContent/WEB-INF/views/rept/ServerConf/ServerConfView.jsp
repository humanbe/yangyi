<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var serverGroupStoreView = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
ServerConfViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		serverGroupStoreView.load();
		// 设置基类属性		ServerConfViewForm.superclass.constructor.call(this, {
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
					fieldLabel : '<fmt:message key="property.srvCode" />',
					name : 'srvCode',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.loadMode" />',
					name : 'loadMode',
					readOnly : true,
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('主机');break;
							case '1' : this.setRawValue('备机');break;
							case '2' : this.setRawValue('F5');break;
						}
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serClass" />',
					name : 'serClass',
					readOnly : true,
					setValue : function(value){
						var displayVal = value;
						serverGroupStoreView.each(function(item){
							if(item.data.value == value){
								displayVal = item.data.name;
								return true;
							}
						});
						this.setRawValue(displayVal);
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serName" />',
					readOnly : true,
					name : 'serName'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.memConf" />',
					readOnly : true,
					name : 'memConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.cpuConf" />',
					readOnly : true,
					name : 'cpuConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.diskConf" />',
					readOnly : true,
					name : 'diskConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					readOnly : true,
					name : 'ipAddress'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.floatAddress" />',
					readOnly : true,
					name : 'floatAddress'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.autoCapture" />',
					name : 'autoCapture',
					readOnly : true,
					setValue : function(value){
						switch(value){
							case '0' : this.setRawValue('自动获取');break;
							case '1' : this.setRawValue('不自动获取');break;
						}
					}
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
			url : '${ctx}/${managePath}/serverconf/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				srvCode : '${param.srvCode}'
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
		app.closeTab('view_ServerConf');
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
Ext.getCmp("view_ServerConf").add(new ServerConfViewForm());
// 刷新Tab页布局
Ext.getCmp("view_ServerConf").doLayout();
</script>
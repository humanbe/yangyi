<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var sysAplNameStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
}); 

var weblogicFlgStore = new Ext.data.SimpleStore({
	fields : ['weblogicFlgDisplay', 'weblogicFlgValue'],
	data : [['定时导入', '0'], ['不导入', '1']]
});
//定义新建表单
WeblogicConfCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性

				//服务器用户
		this.serverIps = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/appcheckdesign/getServerIps', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['serverip']),
			baseParams:{
				aplCode : '${param.aplCode}'
			}
		});
		this.serverIps.load();
		WeblogicConfCreateForm.superclass.constructor.call(this, {
			title : 'Weblogic配置新建',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/weblogicconfmanage/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [
				{
					xtype : 'combo',
					id:'appcheck_weblogicCreate',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : sysAplNameStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'aplCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					readOnly:true,
					selectOnFocus : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
					}
				},
				{
					
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					store : this.serverIps,
					displayField : 'serverip',
					valueField : 'serverip',
					hiddenName : 'ipAddress',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					selectOnFocus : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++
					
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.weblogicServer" />',
					maxLength : 20,
					allowBlank : false,
					name : 'serverName'
				},
				{
					xtype : 'textfield',
					fieldLabel : '服务JDBC名称',
					maxLength : 20,
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
                    allowBlank : false,
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
					maxLength : 5,
					allowBlank : false,
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
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				handler : this.doCancel
			}  ]
		});
	}
	 ,
	// 重置查询表单
	doReset : function() {
		this.getForm().reset();
		Ext.getCmp("appcheck_weblogicCreate").setValue('${param.aplCode}');
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
	} 
});

// 实例化新建表单,并加入到Tab页中
app.window.get(0).add(new WeblogicConfCreateForm());
// 刷新Tab页布局
app.window.get(0).doLayout();
Ext.getCmp("appcheck_weblogicCreate").setValue('${param.aplCode}');

</script>
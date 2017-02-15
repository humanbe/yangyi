<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var loadModeStore = new Ext.data.SimpleStore({
	fields : ['loadModeDisplay', 'loadModeValue'],
	data : [['主机', '0'], ['备机', '1'],['F5', '2']]
});

var serverGroupStoreEdit = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var autoCaptureStore = new Ext.data.SimpleStore({
	fields : ['autoCaptureDisplay', 'autoCaptureValue'],
	data : [['自动获取', '0'], ['不自动获取', '1']]
});

ServerConfEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		serverGroupStoreEdit.load();
		// 设置基类属性		ServerConfEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/serverconf/edit/${param.aplCode}/${param.srvCode}',
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
					disabled : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.srvCode" />',
					name : 'srvCode',
					disabled : true
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.loadMode" />',
					hiddenName : 'loadMode',
					store : loadModeStore,
					displayField : 'loadModeDisplay',
					valueField : 'loadModeValue',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.serClass" />',
					hiddenName : 'serClass',
					store : serverGroupStoreEdit,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serName" />',
					maxLength : 20,
					allowBlank : true,
					name : 'serName'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.memConf" />',
					maxLength : 100,
					allowBlank : true,
					name : 'memConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.cpuConf" />',
					maxLength : 100,
					allowBlank : true,
					name : 'cpuConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.diskConf" />',
					maxLength : 100,
					allowBlank : true,
					name : 'diskConf'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					maxLength : 15,
					allowBlank : true,
					name : 'ipAddress'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.floatAddress" />',
					maxLength : 15,
					allowBlank : true,
					name : 'floatAddress'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.autoCapture" />',
					hiddenName : 'autoCapture',
					store : autoCaptureStore,
					displayField : 'autoCaptureDisplay',
					valueField : 'autoCaptureValue',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
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
			url : '${ctx}/${managePath}/serverconf/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				srvCode : '${param.srvCode}'
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
		app.closeTab('edit_ServerConf');
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
					srvCode : '${param.srvCode}'
				};
				app.closeTab('edit_ServerConf');
				var grid = Ext.getCmp("ServerConfListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_ServerConf', 
						'<fmt:message key="button.view" /><fmt:message key="property.serverConfInfo" />', 
						'${ctx}/${managePath}/serverconf/view', 
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
Ext.getCmp("edit_ServerConf").add(new ServerConfEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_ServerConf").doLayout();
</script>
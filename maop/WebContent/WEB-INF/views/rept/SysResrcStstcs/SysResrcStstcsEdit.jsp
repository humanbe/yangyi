<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var activeHostsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/rptdatainterface/queryServers?aplCode=${param.aplCode}' ,
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['srvCode'])
});

var archTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

SysResrcStstcsEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		activeHostsStore.load();
		archTypeStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		SysResrcStstcsEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/sysresrcststcs/edit/${param.aplCode}/${param.hostsType}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.aplCode" />',
					name : 'aplCode',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.serClass" />',
					hiddenName : 'hostsType',
					typeAhead : true,
					displayField : 'name',
					valueField : 'value',
					store : archTypeStore,
					mode : 'local',
					allowBlank : false,
					editable : false,
					triggerAction : 'all' ,
					readOnly : true 
				},
				{
					xtype : 'lovcombo',
					fieldLabel : '<fmt:message key="property.activeHosts" />',
					tabIndex : this.tabIndex++,
					width : 300,
					hideOnSelect : false,
					maxHeight : 200,
					hiddenName : 'activeHosts',
					displayField : 'srvCode',
					valueField : 'srvCode',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					allowBlank : false,
					store : activeHostsStore,
					triggerAction : 'all',
					mode : 'local',
					disabled : false,
					beforeBlur : function(){},
					listeners : {
						scope : this
					}
				},
				{
					xtype : 'lovcombo',
					fieldLabel : '<fmt:message key="property.statisticalHosts" />',
					tabIndex : this.tabIndex++,
					width : 300,
					hideOnSelect : false,
					maxHeight : 200,
					hiddenName : 'hosts',
					displayField : 'srvCode',
					valueField : 'srvCode',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					allowBlank : false,
					store : activeHostsStore,
					triggerAction : 'all',
					mode : 'local',
					disabled : false,
					beforeBlur : function(){},
					listeners : {
						scope : this
					}
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
			url : '${ctx}/${managePath}/sysresrcststcs/view',
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			params : {
				aplCode : '${param.aplCode}',
				hostsType : '${param.hostsType}'
			},
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
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
		app.closeTab('edit_SysResrcStstcs');
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
					hostsType : '${param.hostsType}'
				};
				app.closeTab('edit_SysResrcStstcs');
				var grid = Ext.getCmp("SysResrcStstcsListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_SysResrcStstcs', '<fmt:message key="button.view" /><fmt:message key="property.StstcsItems" />', '${ctx}/${managePath}/sysresrcststcs/view', params);
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
Ext.getCmp("edit_SysResrcStstcs").add(new SysResrcStstcsEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_SysResrcStstcs").doLayout();
</script>
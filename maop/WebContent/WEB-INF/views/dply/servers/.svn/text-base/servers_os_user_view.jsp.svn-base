<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var SerVerViewStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
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

SerVerViewStore.load();

var serversOsUserUserViewIdStore = new Ext.data.Store(
		{
			proxy : new Ext.data.HttpProxy(
					{
						method : 'POST',
						url : '${ctx}/${managePath}/serverssynchronous/findUserId'
					}),
					reader: new Ext.data.JsonReader({}, ['userId','name']),
			baseParams : {
				appsys_code:'${param.appsysCode}'
			}
		});
		
serversOsUserUserViewIdStore.load()	;
	//定义新建表单
	ServersOsUserViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 实例化性别数据源

		
			// 设置基类属性

			ServersOsUserViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				//url :'${ctx}/${managePath}/serverssynchronous/editOsUuser',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsysCode" />',
					store : SerVerViewStore,
					valueField : 'appsysCode',
					displayField : 'appsysName',
					name : 'appsysCode',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
				    readOnly:true,
					tabIndex : this.tabIndex++
				},{
					fieldLabel : '<fmt:message key="property.serverIp" />',
					name : 'serverIp',
					tabIndex : this.tabIndex++,
					readOnly:true,
					allowBlank : false
				}, {
					fieldLabel : '<fmt:message key="property.osUser" />',
					name : 'osUser',
					tabIndex : this.tabIndex++,
					readOnly:true,
					allowBlank : false
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.userId" />',
					store : serversOsUserUserViewIdStore,
					valueField : 'userId',
					displayField : 'name',
					name : 'userId',
					mode: 'local',
					readOnly:true,
					forceSelection : true,
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				} ],
				buttons : [{
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
			
			
			// 加载表单数据
		 	this.load({
				url : '${ctx}/${managePath}/serverssynchronous/viewOsuser',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					osUser:'${param.osUser}',
					appsysCode:'${param.appsysCode}',
					serverIp:'${param.serverIp}',
					userId:'${param.userId}'
				}
			}); 
		},
		// 保存操作
		doSave : function() {
			this.getForm().submit({
				scope : this,
				success : this.saveSuccess,// 保存成功回调函数
				failure : this.saveFailure,// 保存失败回调函数
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('SERVEROSUSER_VIEW');
		},
		
		// 保存失败回调
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 数据加载失败回调
		loadFailure : function(form, action) {
			app.mask.hide();
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 数据加载成功回调
		loadSuccess : function(form, action) {
			app.mask.hide();
		}
	});

	var ServersOsUserViewForm = new ServersOsUserViewForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SERVEROSUSER_VIEW").add(ServersOsUserViewForm);
	// 刷新Tab页布局
	Ext.getCmp("SERVEROSUSER_VIEW").doLayout();
</script>
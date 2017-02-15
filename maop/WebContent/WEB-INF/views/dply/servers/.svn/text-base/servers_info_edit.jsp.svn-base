<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var SerVersEditStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
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

SerVersEditStore.load();
	//定义新建表单
	ServersEditForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 实例化性别数据源

		this.os_typeStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/SERVER_OS_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.os_typeStore.load();
		this.mw_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/MW_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.mw_typeStore.load();
		this.db_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/DB_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.db_typeStore.load();
		this.collectionStateStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/COLLECTION_STATE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.collectionStateStore.load();
			// 设置基类属性

			ServersEditForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url :'${ctx}/${managePath}/serverssynchronous/editServer',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsysCode" />',
					store : SerVersEditStore,
					displayField : 'appsysCode',
					name : 'appsysCode',
					mode: 'local',
					typeAhead: true,
					readOnly:true,
					style  : 'background : #F0F0F0' ,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},{
					fieldLabel : '<fmt:message key="property.serverIp" />',
					name : 'serverIp',
					readOnly:true,
					style  : 'background : #F0F0F0' ,
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					fieldLabel : '<fmt:message key="property.serverName" />',
					name : 'serverName',
					tabIndex : this.tabIndex++
					
				},
				{
					xtype : 'combo',
					store : this.os_typeStore,
					fieldLabel : '<fmt:message key="property.osType" />',
					name : 'osType',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'osType',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++
				},
				
				{
					xtype :'lovcombo',
					 fieldLabel : '<fmt:message key="property.mwType" />',
					 tabIndex : this.tabIndex++,
					width:300,
					hideOnSelect:false,
					maxHeight:200,
					typeAhead : true,
					forceSelection  : true,
					hiddenName : 'mwType',
					valueField : 'value',
					displayField : 'name',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					store :this.mw_typeStore,
					triggerAction:'all',
					mode:'local',
					beforeBlur:function(){}//重写该方法为空方法，解决失去焦点时被清空的bug（由于选多个会以逗号分割，getValue时获取不到导致）
				},
				{
					xtype :'lovcombo',
					 fieldLabel : '<fmt:message key="property.dbType" />',
					 tabIndex : this.tabIndex++,
					width:300,
					hideOnSelect:false,
					maxHeight:200,
					typeAhead : true,
					forceSelection  : true,
					hiddenName : 'dbType',
					valueField : 'value',
					displayField : 'name',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					store :this.db_typeStore,
					triggerAction:'all',
					mode:'local',
					beforeBlur:function(){}//重写该方法为空方法，解决失去焦点时被清空的bug（由于选多个会以逗号分割，getValue时获取不到导致）
				},
				
				{
					xtype : 'combo',
					store : this.collectionStateStore,
					fieldLabel : '<fmt:message key="property.collectionState" />',
					name : 'collectionState',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'collectionState',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++
				},
				 {
					fieldLabel : '<fmt:message key="property.floatingIp" />',
					name : 'floatingIp',
					tabIndex : this.tabIndex++
					
					
				},{
					fieldLabel : '<fmt:message key="property.serverRole" />',
					name : 'serverRole',
					tabIndex : this.tabIndex++
					
				},{
					fieldLabel : '<fmt:message key="property.bsaAgentFlag" />',
					name : 'bsaAgentFlag',
					tabIndex : this.tabIndex++,
					hidden:true
					
				},{
					fieldLabel : '<fmt:message key="property.attrFlag" />',
					name : 'attrFlag',
					tabIndex : this.tabIndex++,
					hidden:true
					
				}, {
					fieldLabel : '<fmt:message key="property.serverUse" />',
					name : 'serverUse',
					tabIndex : this.tabIndex++
					
				},{
					fieldLabel :'<fmt:message key="property.machineroomPosition" />',
					name : 'machineroomPosition',
					tabIndex : this.tabIndex++
					
				}, {
					fieldLabel :'<fmt:message key="property.environmentType" />',
					name : 'environmentType',
					tabIndex : this.tabIndex++,
					hidden:true
					
					
				},
				 {
					fieldLabel :'<fmt:message key="property.dataType" />',
					name : 'dataType',
					tabIndex : this.tabIndex++,
					hidden:true,
					value:'H',
					readOnly:true,
					allowBlank : false
					
				}],
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : this.doSave
				}, {
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
			
			
			// 加载表单数据
		 	this.load({
				url : '${ctx}/${managePath}/serverssynchronous/viewServer',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params:{
					
					appsysCode:'${param.appsysCode}',
					serverIp:'${param.serverIp}'
					
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
			app.closeTab('SERVER_EDIT');
		},
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					app.closeTab('SERVER_EDIT');// 关闭新建页面
					 Ext.getCmp("serversTypeListGridPanel").getStore().reload();
				}
			});

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

	var ServersEditForm = new ServersEditForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SERVER_EDIT").add(ServersEditForm);
	// 刷新Tab页布局
	Ext.getCmp("SERVER_EDIT").doLayout();
</script>
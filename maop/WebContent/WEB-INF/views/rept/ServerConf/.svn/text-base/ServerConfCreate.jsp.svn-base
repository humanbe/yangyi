<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var sysAplNameStore = new Ext.data.Store({
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

var loadModeStore = new Ext.data.SimpleStore({
	fields : ['loadModeDisplay', 'loadModeValue'],
	data : [['主机', '0'], ['备机', '1'],['F5', '2']]
});

var serverGroupStoreCreate = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var autoCaptureStore = new Ext.data.SimpleStore({
	fields : ['autoCaptureDisplay', 'autoCaptureValue'],
	data : [['自动获取', '0'], ['不自动获取', '1']]
});

//定义新建表单
ServerConfCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法		sysAplNameStore.load();
		serverGroupStoreCreate.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		ServerConfCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/serverconf/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : sysAplNameStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'aplCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					selectOnFocus : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						 'beforequery' : function(e){
							var combo = e.combo;
							combo.collapse();
							 if(!e.forceAll){
								var input = e.query.toUpperCase();
								var regExp = new RegExp('.*' + input + '.*');
								combo.store.filterBy(function(record, id){
									var text = record.get(combo.displayField);
									return regExp.test(text);
								}); 
								combo.restrictHeight();
								combo.expand();
								return false;
							} 
						}
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.srvCode" />',
					name : 'srvCode',
					allowBlank : false,
					maxLength : 50
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
					store : serverGroupStoreCreate,
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
			buttons : [{
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
			} ]
		});
	},
	// 重置查询表单
	doReset : function() {
		this.getForm().reset();
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
		app.closeTab('add_ServerConf');
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
				app.closeTab('add_ServerConf');
				var grid = Ext.getCmp("ServerConfListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					srvCode : action.result.srvCode
				};
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
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("add_ServerConf").add(new ServerConfCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_ServerConf").doLayout();

</script>
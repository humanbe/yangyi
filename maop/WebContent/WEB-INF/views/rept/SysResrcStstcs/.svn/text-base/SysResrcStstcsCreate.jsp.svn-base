<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	
//获取系统代码列表数据
var aplCodeStore =  new Ext.data.Store({
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

var archTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var activeHostsStore = new Ext.data.Store();
//定义新建表单
SysResrcStstcsCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		aplCodeStore.load();
		archTypeStore.load();
		// 设置基类属性
		SysResrcStstcsCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/sysresrcststcs/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					hiddenName : 'aplCode',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					emptyText : '<fmt:message key="message.select.one.only" />',
					typeAhead : true,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					store : aplCodeStore,
					mode : 'local',
					allowBlank : false,
					triggerAction : 'all',
					listeners : {
						 scope : this,
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
						},
						select : function(combo, record, index){
							var form = this.getForm();
							if(activeHostsStore != null){
								form.findField('activeHosts').clearValue();
								form.findField('hosts').clearValue();
							}
							
							activeHostsStore = new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/rptdatainterface/queryServers?aplCode=' + combo.value ,
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['srvCode'])
							});
							
							activeHostsStore.on('load', function(){
								form.findField('activeHosts').store = activeHostsStore;
								form.findField('activeHosts').bindStore(activeHostsStore);
								form.findField('hosts').store = activeHostsStore;
								form.findField('hosts').bindStore(activeHostsStore);
								if(activeHostsStore.getCount() == 0){
									Ext.Msg.show({
										title : '<fmt:message key="message.title"/>',
										msg : '<fmt:message key="message.host.not.found"/>',
										fn : function() {
											form.findField('aplCode').reset();
											form.findField('aplCode').focus();
										},
										buttons : Ext.Msg.OK,
										icon : Ext.MessageBox.INFO
									});
								}
							});
							activeHostsStore.load();
						}
					}
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
					triggerAction : 'all'
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
		app.closeTab('add_SysResrcStstcs');
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
				app.closeTab('add_SysResrcStstcs');
				var grid = Ext.getCmp("SysResrcStstcsListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					hostsType : action.result.hostsType
				};
				
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
	}
});

//计算字符串字节数
function countByteLength(value){
	var len = 0;
	var ch;
	for(var i = 0; i < value.length; i++){
		ch = value.charAt(i);
		len++;
		if(escape(ch).length > 4)
        {
	         //中文字符的长度经编码之后大于4
	         len++;
         }
	}
	return len;
}

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("add_SysResrcStstcs").add(new SysResrcStstcsCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_SysResrcStstcs").doLayout();

</script>
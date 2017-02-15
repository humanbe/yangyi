<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var SerVerStore = new Ext.data.Store({
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
SerVerStore.load();
//服务器数据源
var serversOsUserServerIpStore = new Ext.data.Store(
{
	proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${managePath}/serverssynchronous/findip'
			}),
			reader: new Ext.data.JsonReader({}, ['serverIp']),
	baseParams : {
	}
});


var serversOsUserUserIdStore = new Ext.data.Store(
{
	proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${managePath}/serverssynchronous/findUserId'
			}),
			reader: new Ext.data.JsonReader({}, ['userId','name']),
	baseParams : {
	}
});

var serversOsUserStore = new Ext.data.Store(
		{
			proxy : new Ext.data.HttpProxy(
					{
						method : 'POST',
						url : '${ctx}/${managePath}/serverssynchronous/findOsUser'
					}),
					reader: new Ext.data.JsonReader({}, ['osUser']),
			baseParams : {
			}
		});

	//定义新建表单
	ServersOsUserCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 实例化性别数据源
            


		
			// 设置基类属性

			ServersOsUserCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url :'${ctx}/${managePath}/serverssynchronous/createOsUser',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
					store : SerVerStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					name : 'appsysCode',
					hiddenName:'appsysCode',
					mode: 'local',
					forceSelection : true,
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						 beforequery : function(e){
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
					select : function(obj) {
						Ext.getCmp('serverOsUserServerIpID').setValue('');
						Ext.getCmp('serverOsUserUserIdID').setValue('');
						Ext.getCmp('serverOsUserID').setValue('');
						serversOsUserServerIpStore.baseParams.appsys_code =obj.value ;
						serversOsUserServerIpStore.reload();
						
						serversOsUserStore.baseParams.appsys_code =obj.value ;
						serversOsUserStore.reload();
						
						serversOsUserUserIdStore.baseParams.appsys_code =obj.value ;
						serversOsUserUserIdStore.reload();
					 }
					}
				},
				/* {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.serverIp" />',
					store : serversOsUserServerIpStore,
					id:'serverOsUserServerIpID',
					displayField : 'serverIp',
					name : 'serverIp',
					mode: 'local',
					forceSelection : true,
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, */
				{
					xtype :'lovcombo',
					id:'serverOsUserServerIpID',
					 fieldLabel : '<fmt:message key="property.serverIp" />',
					 tabIndex : this.tabIndex++,
					width:300,
					hideOnSelect:false,
					maxHeight:200,
					typeAhead : true,
					forceSelection  : true,
					hiddenName : 'serverIp',
					displayField : 'serverIp',
					valueField : 'serverIp',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					store :serversOsUserServerIpStore,
					triggerAction:'all',
					mode:'local',
					beforeBlur:function(){}//重写该方法为空方法，解决失去焦点时被清空的bug（由于选多个会以逗号分割，getValue时获取不到导致）
				},
				 {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.osUser" />',
					store : serversOsUserStore,
					id:'serverOsUserID',
					displayField : 'osUser',
					name : 'osUser',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, /* {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.userId" />',
					id:'serverOsUserUserIdID',
					store : serversOsUserUserIdStore,
					valueField : 'userId',
					displayField : 'name',
					name : 'userId',
					hiddenName:'userId',
					mode: 'local',
					forceSelection : true,
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, */{
					xtype :'lovcombo',
					id:'serverOsUserUserIdID',
					 fieldLabel : '<fmt:message key="property.userId" />',
					 tabIndex : this.tabIndex++,
					width:300,
					hideOnSelect:false,
					maxHeight:200,
					typeAhead : true,
					forceSelection  : true,
					hiddenName : 'userId',
					displayField : 'name',
					valueField : 'userId',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					store :serversOsUserUserIdStore,
					triggerAction:'all',
					mode:'local',
					beforeBlur:function(){}//重写该方法为空方法，解决失去焦点时被清空的bug（由于选多个会以逗号分割，getValue时获取不到导致）
				}
				],
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
			app.closeTab('SERVEROSUSER_CREATE');
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
					app.closeTab('SERVEROSUSER_CREATE');// 关闭新建页面
					 Ext.getCmp("osUserListGridPanel").getStore().reload();
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
		}
	});

	var ServersOsUserCreateForm = new ServersOsUserCreateForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SERVEROSUSER_CREATE").add(ServersOsUserCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("SERVEROSUSER_CREATE").doLayout();
</script>
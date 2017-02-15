<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplCodesStore =  new Ext.data.Store({
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
aplCodesStore.load();
	//定义新建表单
	SysResrcTransCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			//禁止IE的backspace键(退格键)，但输入文本框时不禁止

			Ext.getDoc().on('keydown',function(e) {
								if (e.getKey() == 8
										&& e.getTarget().type == 'text'
										&& !e.getTarget().readOnly) {

								} else if (e.getKey() == 8
										&& e.getTarget().type == 'textarea'
										&& !e.getTarget().readOnly) {

								} else if (e.getKey() == 8) {
									e.preventDefault();
								}
							});
			// 实例化数据源
		  this.SRV_CODEStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itembaseconf/getsrvCode',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['value','name'])
		});
		  this.TRAN_NAMEtore =  new Ext.data.Store({
				proxy: new Ext.data.HttpProxy({
					url : '${ctx}/${managePath}/itembaseconf/getTransName',
					method : 'GET',
					disableCaching : true
				}),
				reader : new Ext.data.JsonReader({}, ['value','name'])
			});
	
		  this.serverGroupStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			
			this.serverGroupStore.load();
			// 设置基类属性

			SysResrcTransCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${managePath}/itembaseconf/SysResrcTransConf_create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [ 
							{
								xtype : 'combo',
								id:'sysresrctrans_aplcode',
								fieldLabel : '<fmt:message key="property.appsyscd" />',
								store : aplCodesStore,
								displayField : 'appsysName',
								valueField : 'appsysCode',
								name : 'aplCode',
								hiddenName : 'aplCode',
								mode: 'local',
								typeAhead: true,
								scope : this ,
							    triggerAction: 'all',
								tabIndex : this.tabIndex++,
								listeners : {
									scope : this ,
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
									} ,
									select :function(obj){
										this.TRAN_NAMEtore.baseParams={
												aplCode : obj.value 
										} 
										this.TRAN_NAMEtore.load();
										
										Ext.getCmp('sysresrctrans_server_class').setValue("");
										Ext.getCmp('sysresrctrans_server_code').setValue("");
										Ext.getCmp('sysresrctrans_trans_name').setValue("");
										
									}
								}
							},
							
							{
								xtype : 'combo',
								id:'sysresrctrans_server_class',
								store : this.serverGroupStore ,
								fieldLabel : '服务器分类',
								name : 'srvType',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'srvType',
								mode : 'local',
								triggerAction : 'all',
								forceSelection : true,
								editable : false,
								scope : this ,
								allowBlank : false,
								tabIndex : this.tabIndex++,
								allowBlank : false,
								listeners : {
									scope : this ,
									select : function(obj){
										this.SRV_CODEStore.baseParams = {
												aplCode :  Ext.getCmp('sysresrctrans_aplcode').getValue(),
												srvType : obj.value
										}
										this.SRV_CODEStore.load();
										Ext.getCmp('sysresrctrans_server_code').setValue("");
									}
								}
							},
							{
								xtype : 'lovcombo',
								id :'sysresrctrans_server_code',
								store : this.SRV_CODEStore,
								fieldLabel : '服务器编号（IP）',
								name : 'srvCode',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'srvCode',
								mode : 'local',
								triggerAction : 'all',
								forceSelection : true,
								editable : false,
								allowBlank : false,
								tabIndex : this.tabIndex++,
								allowBlank : false,
								listeners : {
								},
								beforeBlur:function(){}
							} ,
							{
							xtype : 'combo',
							id:'sysresrctrans_trans_name',
							store : this.TRAN_NAMEtore ,
							fieldLabel : '交易名称',
							name : 'tranName',
							valueField : 'value',
							displayField : 'name',
							hiddenName : 'tranName',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							editable : false,
							scope : this ,
							allowBlank : false,
							tabIndex : this.tabIndex++,
							allowBlank : false
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
			app.closeTab('SYSRESRCTRANS_CREATE');
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
					app.closeTab('SYSRESRCTRANS_CREATE');// 关闭新建页面
					 Ext.getCmp("SysResrcTransListGridPanel").getStore().reload();
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

	var SysResrcTransCreateForm = new SysResrcTransCreateForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SYSRESRCTRANS_CREATE").add(SysResrcTransCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("SYSRESRCTRANS_CREATE").doLayout();
</script>
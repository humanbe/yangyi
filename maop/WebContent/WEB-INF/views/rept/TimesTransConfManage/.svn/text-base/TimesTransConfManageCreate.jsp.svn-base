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

var timesTransTypeStore = new Ext.data.SimpleStore({
	fields : ['timesTransTypeDisplay', 'timesTransTypeValue'],
	data : [['分钟', 1], ['秒钟', 2]]
});

var itemsStore = new Ext.data.Store();

//定义新建表单
TimesTransConfManageCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性		TimesTransConfManageCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/timestransconfmanage/create',
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
						'select' : function(combo, record, index){
							var form = this.getForm();
							if(itemsStore != null){
								form.findField('countItem').clearValue();
								form.findField('relatedItem').clearValue();
							}
							itemsStore = new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/timestransconfmanage/queryLatestItems?aplCode=' + record.get('aplCode'),
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['countItem'])
							});
							
							itemsStore.on('load', function(){
								form.findField('countItem').store = itemsStore;
								form.findField('countItem').bindStore(itemsStore);
								form.findField('relatedItem').store = itemsStore;
								form.findField('relatedItem').bindStore(itemsStore);
								if(itemsStore.getCount() == 0){
									Ext.Msg.show({
										title : '<fmt:message key="message.title"/>',
										msg : '<fmt:message key="message.item.not.found"/>',
										fn : function() {
											form.findField('aplCode').reset();
											form.findField('aplCode').focus();
										},
										buttons : Ext.Msg.OK,
										icon : Ext.MessageBox.INFO
									});
								}
							});
							itemsStore.load();
						}
					}
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.countItem" />',
					hiddenName : 'countItem',
					store : itemsStore,
					displayField : 'countItem',
					valueField : 'countItem',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'lovcombo',
					fieldLabel : '<fmt:message key="property.relatedItem" />',
					tabIndex : this.tabIndex++,
					width : 300,
					hideOnSelect : false,
					maxHeight : 200,
					hiddenName : 'relatedItem',
					displayField : 'countItem',
					valueField : 'countItem',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					allowBlank : false,
					store : itemsStore,
					triggerAction : 'all',
					mode : 'local',
					disabled : false,
					beforeBlur : function(){}
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.type.trans" />',
					hiddenName : 'type',
					store : timesTransTypeStore,
					displayField : 'timesTransTypeDisplay',
					valueField : 'timesTransTypeValue',
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
		app.closeTab('add_TimesTransConfManage');
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
				app.closeTab('add_TimesTransConfManage');
				var grid = Ext.getCmp("TimesTransConfManageListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					countItem : encodeURIComponent(action.result.countItem)
				};
				app.loadTab('view_TimesTransConfManage', 
						'<fmt:message key="button.view" /><fmt:message key="property.timesTransConfInfo" />', 
						'${ctx}/${managePath}/timestransconfmanage/view', 
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
Ext.getCmp("add_TimesTransConfManage").add(new TimesTransConfManageCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_TimesTransConfManage").doLayout();

</script>
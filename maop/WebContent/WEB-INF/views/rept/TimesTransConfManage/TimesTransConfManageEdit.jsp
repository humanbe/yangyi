<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var timesTransTypeStore = new Ext.data.SimpleStore({
	fields : ['timesTransTypeDisplay', 'timesTransTypeValue'],
	data : [['分钟', 1], ['秒钟', 2]]
});

var itemsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/timestransconfmanage/queryLatestItems?aplCode=${param.aplCode}',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['countItem'])
});

TimesTransConfManageEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		itemsStore.load();
		// 设置基类属性		TimesTransConfManageEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/timestransconfmanage/edit/${param.aplCode}/'+ encodeURIComponent('${param.countItem}'),
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
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.countItem" />',
					disabled : true,
					name : 'countItem',
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
					beforeBlur : function(){},
					tabIndex : this.tabIndex++
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
			url : '${ctx}/${managePath}/timestransconfmanage/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				countItem : decodeURIComponent('${param.countItem}')
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
		app.closeTab('edit_TimesTransConfManage');
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
					countItem : '${param.countItem}'
				};
				app.closeTab('edit_TimesTransConfManage');
				var grid = Ext.getCmp("TimesTransConfManageListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
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
Ext.getCmp("edit_TimesTransConfManage").add(new TimesTransConfManageEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_TimesTransConfManage").doLayout();
</script>
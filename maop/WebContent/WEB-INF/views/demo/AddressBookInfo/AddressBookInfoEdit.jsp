<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AddressBookInfoEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		AddressBookInfoEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/addressbookinfo/edit/${param.id}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
				    xtype : 'textfield',
					fieldLabel : 'adminname',
					name : 'adminname',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'admintype',
					name : 'admintype',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'mobile',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'phone',
					name : 'phone',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'email',
					name : 'email',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : 'remark',
					name : 'remark',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'addminid',
					name : 'addminid',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}	
	 		],
			// 定义按钮
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
				handler : this.doCancel
			} ]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${appPath}/addressbookinfo/view/${param.id}',
			method : 'GET',
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
		app.closeTab('edit_AddressBookInfo');
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
					id : '${param.id}'
				};
				app.closeTab('edit_AddressBookInfo');
				var grid = Ext.getCmp("AddressBookInfoListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_AddressBookInfo', '<fmt:message key="button.view" /><fmt:message key="AddressBookInfo" />', '${ctx}/${appPath}/addressbookinfo/view', params);
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
Ext.getCmp("edit_AddressBookInfo").add(new AddressBookInfoEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_AddressBookInfo").doLayout();
</script>
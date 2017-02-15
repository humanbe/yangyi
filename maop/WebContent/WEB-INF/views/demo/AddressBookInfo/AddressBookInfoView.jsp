<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AddressBookInfoViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		AddressBookInfoViewForm.superclass.constructor.call(this, {
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
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'admintype',
					name : 'admintype',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'mobile',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'phone',
					name : 'phone',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'email',
					name : 'email',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'remark',
					name : 'remark',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'addminid',
					name : 'addminid',
					tabIndex : this.tabIndex++,
					readOnly : true
				}
			],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			} ]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${appPath}/addressbookinfo/view/${param.id}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	// 关闭操作
	doClose : function() {
		app.closeTab('view_AddressBookInfo');
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
Ext.getCmp("view_AddressBookInfo").add(new AddressBookInfoViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AddressBookInfo").doLayout();
</script>
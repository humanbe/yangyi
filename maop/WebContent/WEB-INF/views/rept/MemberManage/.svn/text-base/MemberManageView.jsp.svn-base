<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
MemberInfoViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		MemberInfoViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 140,
			buttonAlign : 'center',
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
					fieldLabel : '<fmt:message key="property.userId" />',
					name : 'userId',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.userName" />',
					name : 'userName',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
				    xtype : 'combo',
					fieldLabel : '<fmt:message key="property.sex" />',
					name : 'sex',
					store : sexStore,
					displayField : 'sex',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.mobile" />',
					name : 'mobile',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.phone" />',
					name : 'phone',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.otherContact" />',
					name : 'otherContact',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.email" />',
					name : 'email',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serilNo" />',
					name : 'serilNo',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.groupName" />',
					name : 'groupName',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.teamName" />',
					name : 'teamName',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.isOutSourcing" />',
					name : 'outSourcingFlag',
					setValue : function(value){
						switch(value){
							case '2' : this.setRawValue('是');break;
						}
					},
					readOnly : true
				}
			],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				scope : this,
				handler : this.doClose
			} ]
		});
		
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/membermanage/view',
			params : {userId : '${param.userId}'},
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	// 关闭操作
	doClose : function() {
		app.closeTab('view_MemberInfo');
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
Ext.getCmp("view_MemberInfo").add(new MemberInfoViewForm());
// 刷新Tab页布局
Ext.getCmp("view_MemberInfo").doLayout();
</script>
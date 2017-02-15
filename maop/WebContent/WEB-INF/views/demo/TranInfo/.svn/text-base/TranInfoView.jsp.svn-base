<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
TranInfoViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		TranInfoViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/traninfo/edit/${param.id}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
						xtype : 'textfield',
						fieldLabel : '<fmt:message key="property.tranid" />',
						name : 'tranid',
						tabIndex : this.tabIndex++,
						readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsystemid" />',
					name : 'appsystemid',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.chnlno" />',
					name : 'chnlno',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.outtrancode" />',
					name : 'outtrancode',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.trancode" />',
					name : 'trancode',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.tranname" />',
					name : 'tranname',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.trantime" />',
					name : 'trantime',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serviceid" />',
					name : 'serviceid',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.busimoduelname" />',
					name : 'busimoduelname',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.busimoduelcode" />',
					name : 'busimoduelcode',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.higouttrancode" />',
					name : 'higouttrancode',
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
			url : '${ctx}/${appPath}/traninfo/view/${param.id}',
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
		app.closeTab('view_TranInfo');
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
Ext.getCmp("view_TranInfo").add(new TranInfoViewForm());
// 刷新Tab页布局
Ext.getCmp("view_TranInfo").doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义新建表单
TranInfoCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
	
		// 设置基类属性
		TranInfoCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/traninfo/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemid',
					name : 'appsystemid',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'chnlno',
					name : 'chnlno',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'outtrancode',
					name : 'outtrancode',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'trancode',
					name : 'trancode',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'tranname',
					name : 'tranname',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'trantime',
					name : 'trantime',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'serviceid',
					name : 'serviceid',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busimoduelname',
					name : 'busimoduelname',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busimoduelcode',
					name : 'busimoduelcode',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'higouttrancode',
					name : 'higouttrancode',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'callway',
					name : 'callway',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'numberfield',
					fieldLabel : 'callnum',
					name : 'callnum',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'condition',
					name : 'condition',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve',
					name : 'reserve',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve1',
					name : 'reserve1',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve2',
					name : 'reserve2',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve3',
					name : 'reserve3',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'tranid',
					name : 'tranid',
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
		app.closeTab('add_TranInfo');
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
				app.closeTab('add_TranInfo');
				var grid = Ext.getCmp("TranInfoListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					id : action.result.tranid
				};
				app.loadTab('view_TranInfo', '<fmt:message key="button.view" /><fmt:message key="TranInfo" />', '${ctx}/${appPath}/traninfo/view', params);
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
Ext.getCmp("add_TranInfo").add(new TranInfoCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_TranInfo").doLayout();

</script>
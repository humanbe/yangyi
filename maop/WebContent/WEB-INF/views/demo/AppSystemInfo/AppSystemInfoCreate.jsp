<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义新建表单
AppSystemInfoCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
	
		// 设置基类属性
		AppSystemInfoCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/appsysteminfo/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemname',
					name : 'appsystemname',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'issysflag',
					name : 'issysflag',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemtype',
					name : 'appsystemtype',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemtime',
					name : 'appsystemtime',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'meno',
					name : 'meno',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appadminidA',
					name : 'appadminidA',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'sysadminidA',
					name : 'sysadminidA',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appadminidB',
					name : 'appadminidB',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'sysadminidB',
					name : 'sysadminidB',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'bmanagerid',
					name : 'bmanagerid',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'cmanagerid',
					name : 'cmanagerid',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busicontact1id',
					name : 'busicontact1id',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busicontact2id',
					name : 'busicontact2id',
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
					fieldLabel : 'appsystemid',
					name : 'appsystemid',
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
		app.closeTab('add_AppSystemInfo');
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
				app.closeTab('add_AppSystemInfo');
				var grid = Ext.getCmp("AppSystemInfoListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					id : action.result.appsystemid
				};
				app.loadTab('view_AppSystemInfo', '<fmt:message key="button.view" /><fmt:message key="AppSystemInfo" />', '${ctx}/${appPath}/appsysteminfo/view', params);
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
Ext.getCmp("add_AppSystemInfo").add(new AppSystemInfoCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_AppSystemInfo").doLayout();

</script>
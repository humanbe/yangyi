<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AppSystemInfoViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
		// 设置基类属性
		AppSystemInfoViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/appsysteminfo/edit/${param.id}',
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
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'issysflag',
					name : 'issysflag',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemtype',
					name : 'appsystemtype',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemtime',
					name : 'appsystemtime',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'meno',
					name : 'meno',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appadminidA',
					name : 'appadminidA',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'sysadminidA',
					name : 'sysadminidA',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appadminidB',
					name : 'appadminidB',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'sysadminidB',
					name : 'sysadminidB',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'bmanagerid',
					name : 'bmanagerid',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'cmanagerid',
					name : 'cmanagerid',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busicontact1id',
					name : 'busicontact1id',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'busicontact2id',
					name : 'busicontact2id',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve1',
					name : 'reserve1',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'reserve2',
					name : 'reserve2',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'appsystemid',
					name : 'appsystemid',
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
			url : '${ctx}/${appPath}/appsysteminfo/view/${param.id}',
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
		app.closeTab('view_AppSystemInfo');
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
Ext.getCmp("view_AppSystemInfo").add(new AppSystemInfoViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AppSystemInfo").doLayout();
</script>
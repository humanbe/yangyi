<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var outSourcingFlagStore = new Ext.data.SimpleStore({
	fields : ['outSourcingFlagValue', 'outSourcingFlagDisplay'],
	data : [['2','是'], ['1', '不是']]
});
var sexStore = new Ext.data.SimpleStore({
	fields :['sex'],
	data :[['男'], ['女']]
});
var groupNameStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/membermanage/queryGroupNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['groupName'])
});
MemberInfoEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		groupNameStore.load();
		// 设置基类属性
		MemberInfoEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 140,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/membermanage/edit/${param.userId}',
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
					allowBlank : false,
					disabled : true
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.userName" />',
					name : 'userName',
					tabIndex : this.tabIndex++,
					allowBlank : false,
					maxLength : 64
				},
				{
				    xtype : 'combo',
					fieldLabel : '<fmt:message key="property.sex" />',
					name : 'sex',
					store : sexStore,
					displayField : 'sex',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.mobile" />',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					vtype : 'alphanum',
					maskRe : /[0-9]/,
					maxLength : 15,
					allowBlank : false
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.phone" />',
					tabIndex : this.tabIndex++,
					maxLength : 64,
					name : 'phone'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.otherContact" />',
					tabIndex : this.tabIndex++,
					maxLength : 64,
					name : 'otherContact'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.email" />',
					tabIndex : this.tabIndex++,
					vtype : 'email',
					maxLength : 64,
					name : 'email'
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serilNo" />',
					tabIndex : this.tabIndex++,
					name : 'serilNo',
					maxLength : 64,
					vtype : 'alphanum',
					allowBlank : false
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.groupName" />',
					tabIndex : this.tabIndex++,
					name : 'groupName',
					allowBlank : false,
					store : groupNameStore,
					displayField : 'groupName',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.teamName" />',
					tabIndex : this.tabIndex++,
					name : 'teamName',
					maxLength : 100
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.isOutSourcing" />',
					store : outSourcingFlagStore,
					tabIndex : this.tabIndex++,
					displayField : 'outSourcingFlagDisplay',
					valueField : 'outSourcingFlagValue',
					hiddenName : 'outSourcingFlag',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all'
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
			url : '${ctx}/${managePath}/membermanage/view',
			params : {userId : '${param.userId}'},
			method : 'POST',
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
		app.closeTab('edit_MemberInfo');
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
					userId : '${param.userId}'
				};
				app.closeTab('edit_MemberInfo');
				var grid = Ext.getCmp("MemberInfoListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_MemberInfo', 
						'<fmt:message key="button.view" /><fmt:message key="property.memberInfo" />', 
						'${ctx}/${managePath}/membermanage/view', params);
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
Ext.getCmp("edit_MemberInfo").add(new MemberInfoEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_MemberInfo").doLayout();
</script>
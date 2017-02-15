<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义新建表单
SubItemEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 设置基类属性
		SubItemEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${frameworkPath}/subitem/edit/${param.id}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			items : [ {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="subitem.name" />',
				name : 'name',
				tabIndex : this.tabIndex++,
				allowBlank : false
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="subitem.value" />',
				name : 'value',
				tabIndex : this.tabIndex++,
				allowBlank : false
			}, {
				xtype : 'numberfield',
				fieldLabel : '<fmt:message key="column.order" />',
				name : 'order',
				tabIndex : this.tabIndex++,
				allowBlank : true
			}, {
				xtype : 'hidden',
				name : 'parent',
				hidden : true
			}, {
				xtype : 'hidden',
				name : 'version',
				hidden : true
			} ],
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
				scope : this,
				handler : this.doCancel
			} ]
		});

		this.load( {
			url : '${ctx}/${frameworkPath}/subitem/view/${param.id}',
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
		var params = {
			parent : '${param.parent}'
		};
		app.loadWindow("${ctx}/${frameworkPath}/subitem/list", params);
	},
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				var grid = Ext.getCmp("SubItemList");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					parent : '${param.parent}'
				};
				app.loadWindow("${ctx}/${frameworkPath}/subitem/list", params);
			}
		});

	},
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

app.window.get(0).add(new SubItemEditForm());
app.window.get(0).doLayout();
</script>
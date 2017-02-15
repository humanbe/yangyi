<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	MenuViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 设置基类属性
			MenuViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.id" />',
					name : 'id',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="menu.url" />',
					name : 'url',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="menu.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="menu.iframe" />',
					name : 'iframe',
					tabIndex : this.tabIndex++,
					disabled : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="menu.open.in.home" />',
					name : 'openInHome',
					tabIndex : this.tabIndex++,
					disabled : true
				} ],
				buttons : [ {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doClose
				} ]
			});

			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/menu/view/${param.id}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				success : this.loadSuccess,
				failure : this.loadFailure
			});
		},
		// 关闭操作
		doClose : function() {
			app.closeTab('view_menu');
		},
		// 数据加载失败回调
		loadFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 数据加载成功回调
		loadSuccess : function(form, action) {
		}
	});

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("view_menu").add(new MenuViewForm());
	// 刷新Tab页布局
	Ext.getCmp("view_menu").doLayout();
</script>

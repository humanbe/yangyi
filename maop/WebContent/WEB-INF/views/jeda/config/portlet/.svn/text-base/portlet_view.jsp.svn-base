<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义查看表单
	PortletViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			PortletViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				// 定义表单组件
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="portlet.title" />',
					name : 'title',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="portlet.url" />',
					name : 'url',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					readOnly : true
				} ],
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
			this.load({
				url : '${ctx}/${frameworkPath}/portlet/view/${param.id}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure
			});
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
		// 关闭操作
		doClose : function() {
			app.closeTab('PORTLET_VIEW');
		}
	});

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("PORTLET_VIEW").add(new PortletViewForm());
	// 刷新Tab页布局
	Ext.getCmp("PORTLET_VIEW").doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var tabIndex = 1;
	var menuEditFormPanel = new Ext.FormPanel({
		id : 'menuEditFormPanel',
		title : '<fmt:message key="title.form" />',
		renderTo : 'menuEditForm',
		labelAlign : 'right',
		buttonAlign : 'center',
		frame : true,
		height : Ext.get("menuEditForm").getHeight(),
		autoScroll : true,
		url : '${ctx}/${frameworkPath}/menu/edit/${param.id}',
		defaults : {
			anchor : '80%',
			msgTarget : 'side'
		},
		monitorValid : true,
		items : [ {
			xtype : 'textfield',
			fieldLabel : '<fmt:message key="menu.id" />',
			name : 'id',
			tabIndex : tabIndex++,
			readOnly : true
		}, {
			xtype : 'textfield',
			fieldLabel : '<fmt:message key="menu.name" />',
			name : 'name',
			tabIndex : tabIndex++,
			allowBlank : false
		}, {
			xtype : 'textfield',
			fieldLabel : '<fmt:message key="menu.url" />',
			name : 'url',
			tabIndex : tabIndex++,
			allowBlank : true
		}, {
			xtype : 'textarea',
			fieldLabel : '<fmt:message key="menu.description" />',
			name : 'description',
			tabIndex : tabIndex++,
			allowBlank : true
		}, {
			xtype : 'numberfield',
			fieldLabel : '<fmt:message key="column.order" />',
			name : 'order',
			tabIndex : tabIndex++,
			allowBlank : true
		}, {
			xtype : 'checkbox',
			fieldLabel : '<fmt:message key="menu.iframe" />',
			name : 'iframe',
			inputValue : 'true',
			tabIndex : this.tabIndex++
		}, {
			xtype : 'checkbox',
			fieldLabel : '<fmt:message key="menu.open.in.home" />',
			name : 'openInHome',
			inputValue : 'true',
			tabIndex : this.tabIndex++
		}, {
			xtype : 'hidden',
			name : 'parent',
			value : '${param.parent}',
			hidden : true
		}, {
			xtype : 'hidden',
			name : '_iframe',
			hidden : true
		}, {
			xtype : 'hidden',
			name : '_openInHome',
			hidden : true
		}, {
			xtype : 'hidden',
			name : 'version',
			hidden : true
		} ],
		buttons : [ {
			text : '<fmt:message key="button.save" />',
			iconCls : 'button-save',
			tabIndex : tabIndex++,
			formBind : true,
			handler : function() {
				Ext.getCmp('menuEditFormPanel').getForm().submit({
					success : saveSuccess,
					failure : saveFailure,
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.saving" />'
				});
			}
		}, {
			text : '<fmt:message key="button.cancel" />',
			iconCls : 'button-cancel',
			tabIndex : tabIndex++,
			handler : function() {
				app.closeTab('edit_menu');
			}
		} ]
	});
	menuEditFormPanel.load({
		url : '${ctx}/${frameworkPath}/menu/view/${param.id}',
		method : 'GET',
		waitTitle : '<fmt:message key="message.wait" />',
		waitMsg : '<fmt:message key="message.loading" />',
		failure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
	function saveSuccess(form, action) {
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				var params = {
					id : '${param.id}'
				};
				app.closeTab('edit_menu');
				var selectedNodePath = null;
				if (Ext.getCmp("menuTree").getSelectionModel().getSelectedNode() != null) {
					selectedNodePath = Ext.getCmp("menuTree").getSelectionModel().getSelectedNode().getPath();
				}
				Ext.getCmp("menuListGridPanel").getStore().reload();
				Ext.getCmp("menuTree").root.reload();
				//Ext.getCmp("menuTree").expandAll();
				if (selectedNodePath != null) {
					Ext.getCmp("menuTree").selectPath(selectedNodePath);
				}
				app.loadTab('view_menu', '<fmt:message key="button.view" /><fmt:message key="menu" />', '${ctx}/${frameworkPath}/menu/view', params);
			}
		});

	}

	function saveFailure(form, action) {
		var error = action.result.error;
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO
		});
	}
</script>
<div id="menuEditForm" style="height: 100%;"></div>
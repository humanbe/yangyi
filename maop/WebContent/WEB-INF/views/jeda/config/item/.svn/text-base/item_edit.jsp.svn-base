<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<div id="itemEditForm" style="height: 100%;"></div>
<script type="text/javascript">
var tabIndex = 1;
var itemEditFormPanel = new Ext.FormPanel( {
	id : 'itemEditFormPanel',
	title : '<fmt:message key="title.form" />',
	renderTo : 'itemEditForm',
	labelAlign : 'right',
	buttonAlign : 'center',
	frame : true,
	height : Ext.get("itemEditForm").getHeight(),
	autoScroll : true,
	url : '${ctx}/${frameworkPath}/item/edit/${param.id}',
	defaults : {
		anchor : '80%',
		msgTarget : 'side'
	},
	monitorValid : true,
	items : [ {
		xtype : 'textfield',
		fieldLabel : '<fmt:message key="item.id" />',
		name : 'id',
		tabIndex : tabIndex++,
		readOnly : true
	}, {
		xtype : 'textfield',
		fieldLabel : '<fmt:message key="item.name" />',
		name : 'name',
		tabIndex : tabIndex++,
		allowBlank : false
	}, {
		xtype : 'numberfield',
		fieldLabel : '<fmt:message key="column.order" />',
		name : 'order',
		tabIndex : tabIndex++,
		allowBlank : true
	}, {
		xtype : 'textarea',
		fieldLabel : '<fmt:message key="item.description" />',
		name : 'description',
		tabIndex : tabIndex++,
		allowBlank : true
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
			Ext.getCmp('itemEditFormPanel').getForm().submit( {
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
			app.closeTab('edit_item');
		}
	} ]
});
itemEditFormPanel.load( {
	url : '${ctx}/${frameworkPath}/item/view/${param.id}',
	method : 'GET',
	waitTitle : '<fmt:message key="message.wait" />',
	waitMsg : '<fmt:message key="message.loading" />',
	failure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});
function saveSuccess(form, action) {
	Ext.Msg.show( {
		title : '<fmt:message key="message.title" />',
		msg : '<fmt:message key="message.save.successful" />',
		buttons : Ext.MessageBox.OK,
		icon : Ext.MessageBox.INFO,
		minWidth : 200,
		fn : function (){
			var params = {
				id : '${param.id}'
			};
			app.closeTab('edit_item');
			Ext.getCmp("itemListGridPanel").getStore().reload();
			app.loadTab('view_item', '<fmt:message key="button.view" /><fmt:message key="item" />', '${ctx}/${frameworkPath}/item/view', params);
		}
	});
	
}

function saveFailure(form, action) {
	var error = action.result.error;
	Ext.Msg.show( {
		title : '<fmt:message key="message.title" />',
		msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
		buttons : Ext.MessageBox.OK,
		icon : Ext.MessageBox.INFO
	});
}
</script>
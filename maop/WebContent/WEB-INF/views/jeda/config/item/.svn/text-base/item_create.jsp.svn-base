<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<div id="itemCreateForm" style="height: 100%;"></div>
<script type="text/javascript">
var tabIndex = 1;

var itemCreateFormPanel = new Ext.FormPanel( {
	id : 'itemCreateFormPanel',
	title : '<fmt:message key="title.form" />',
	renderTo : 'itemCreateForm',
	labelAlign : 'right',
	buttonAlign : 'center',
	frame : true,
	height : Ext.get("itemCreateForm").getHeight(),
	autoScroll : true,
	url : '${ctx}/${frameworkPath}/item/create',
	defaults : {
		anchor : '80%',
		msgTarget : 'side'
	},
	monitorValid : true,
	items : [ {
		xtype : 'textfield',
		fieldLabel : '<fmt:message key="item.id" />',
		name : 'id',
		vtype : 'alphanum',
		tabIndex : tabIndex++,
		allowBlank : false
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
	} ],
	buttons : [ {
		text : '<fmt:message key="button.save" />',
		iconCls : 'button-save',
		tabIndex : tabIndex++,
		formBind : true,
		handler : function() {
			Ext.getCmp('itemCreateFormPanel').getForm().submit( {
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
			app.closeTab('add_item');
		}
	} ]
});
function saveSuccess(form, action) {
	Ext.Msg.show( {
		title : '<fmt:message key="message.title" />',
		msg : '<fmt:message key="message.save.successful" />',
		buttons : Ext.MessageBox.OK,
		icon : Ext.MessageBox.INFO,
		minWidth : 200,
		fn : function (){
			app.closeTab('add_item');
			Ext.getCmp("itemListGridPanel").getStore().reload();
			var params = {
				id : action.result.id
			};
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
		icon : Ext.MessageBox.ERROR
	});
}
</script>
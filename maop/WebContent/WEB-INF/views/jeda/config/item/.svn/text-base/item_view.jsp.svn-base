<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var tabIndex = 1;
var itemViewFormPanel = new Ext.FormPanel( {
	id : 'itemViewFormPanel',
	title : '<fmt:message key="title.form" />',
	renderTo : 'itemViewForm',
	labelAlign : 'right',
	buttonAlign : 'center',
	frame : true,
	height : Ext.get("itemViewForm").getHeight(),
	autoScroll : true,
	defaults : {
		anchor : '80%',
		msgTarget : 'side'
	},
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
		readOnly : true
	}, {
		xtype : 'textfield',
		fieldLabel : '<fmt:message key="column.order" />',
		name : 'order',
		tabIndex : tabIndex++,
		readOnly : true
	}, {
		xtype : 'textarea',
		fieldLabel : '<fmt:message key="item.description" />',
		name : 'description',
		tabIndex : tabIndex++,
		readOnly : true
	} ],
	buttons : [ {
		text : '<fmt:message key="button.close" />',
		iconCls : 'button-close',
		tabIndex : tabIndex++,
		handler : function() {
			app.closeTab('view_item');
		}
	} ]
});
itemViewFormPanel.load( {
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
</script>
<div id="itemViewForm" style="height: 100%;"></div>
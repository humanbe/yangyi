<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><fmt:message key="title.logout" /></title>
<%@ include file="/include/extjs.libs.jsp"%>
</head>
<body>
<fmt:message key="title.logout" var="i18n_title_logout" />
<fmt:message key="message.logged.out" var="i18n_message_logged_out" />
<fmt:message key="button.relogin" var="i18n_button_relogin" />
<script type="text/javascript">
	Ext.onReady(function() {
		Ext.BLANK_IMAGE_URL = 'static/scripts/extjs/resources/images/default/s.gif';
		Ext.QuickTips.init();

		var logout = new Ext.FormPanel( {
			id : 'logoutForm',
			labelAlign : "right",
			labelWidth : 75,
			padding : '5 5 5 5',
			title : '${i18n_title_logout}',
			items : [ {
				xtype : 'label',
				contentEl : 'logout-msg'
			} ]
		});

		var window = new Ext.Window( {
			layout : 'fit',
			height : 150,
			width : 350,
			closable : false,
			resizable : false,
			draggable : false,
			items : [ logout ]
		});
		window.show();
	});
</script>
<div id="logout-msg" style="font-size: 12px;">${i18n_message_logged_out}<a href="${ctx}/login">${i18n_button_relogin}</a></div>
</body>
</html>
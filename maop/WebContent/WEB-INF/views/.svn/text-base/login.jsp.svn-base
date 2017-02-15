<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>
<link rel="SHORTCUT ICON" href="${ctx}/static/favicon.ico" />
<%@ include file="/include/extjs.libs.jsp"%>
<script src="${ctx}/static/scripts/extjs/examples/ux/statusbar/StatusBar.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
</head>
<body>
<script type="text/javascript">
if (self != top) {
	window.parent.document.location.href = document.location.href;
}

Ext.onReady(function() {

	Ext.BLANK_IMAGE_URL = '${ctx}/static/scripts/extjs/resources/images/default/s.gif';
	Ext.QuickTips.init();

	var loginFormPanel = new Ext.FormPanel( {
		id : 'loginForm',
		columnWidth : .75,
		defaultType : 'textfield',
		labelAlign : "right",
		labelWidth : 50,
		padding : '5 5 5 5',
		border : false,
		defaults : {
			width : 150,
			msgTarget : 'side'
		},
		monitorValid : true,
		keys : [ {
			key : [ 10, 13 ],
			fn : login
		} ],
		onSubmit : Ext.emptyFn,
		submit : function() {
			this.getEl().dom.action = "j_spring_security_check";
			this.getEl().dom.submit();
		},
		items : [ {
			fieldLabel : '<fmt:message key="user.username" />',
			name : 'j_username',
			cls : 'input-username',
			emptyText : '<fmt:message key="user.username" />',
			//value:'admin',
			allowBlank : false
		}, {
			inputType : 'password',
			fieldLabel : '<fmt:message key="user.password" />',
			name : 'j_password',
			cls : 'input-password',
			//value:'admin',
			allowBlank : false
		} ],
		buttons : [ {
			text : '<fmt:message key="button.submit" />',
			formBind : true,
			iconCls : 'button-ok',
			handler : login
		}, {
			text : '<fmt:message key="button.reset" />',
			iconCls : 'button-reset',
			handler : function() {
				loginFormPanel.getForm().reset();
			}
		} ]
	});

	var loginPanel = new Ext.Panel( {
		title : '<fmt:message key="title.login" />',
		width : 350,
		autoHeight : true,
		layout : 'column',
		border : false,
		items : [ {
			xtype : 'box',
			columnWidth : .25,
			html : '<img src="${ctx}/static/style/images/sec/user.png"></img>'
		}, loginFormPanel ],
		bbar : new Ext.ux.StatusBar( {
			id : 'statusbar',
			defaultText : '<fmt:message key="message.ready" />'
		})
	});

	function login() {
		Ext.getCmp('statusbar').setStatus( {
			text : '<fmt:message key="message.logging.in" />'
		});
		Ext.getCmp("loginForm").getForm().submit();
	}

	var window = new Ext.Window( {
		layout : 'fit',
		autoHeight : true,
		width : 350,
		closable : false,
		resizable : false,
		draggable : false,
		items : loginPanel
	});
	window.show();

	if ('${param.error}' == 'true') {
		Ext.getCmp('statusbar').setStatus( {
			text : "${sessionScope['SPRING_SECURITY_LAST_EXCEPTION'].message}",
			iconCls : '',
			clear : true
		});
	}
});
</script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache" />
<title></title>
<link rel="SHORTCUT ICON" href="${ctx}/static/favicon.ico" />
<%@ include file="/include/extjs.libs.jsp"%>
<%@ include file="/include/jquery.libs.jsp"%>
<%@ include file="/include/highcharts.libs.jsp"%>
<%@ include file="/include/justgage.libs.jsp"%>
<script src="${ctx}/static/scripts/extjs/examples/ux/TabCloseMenu.js" type="text/javascript">
<!--
	//required for FF3 and Opera
//-->
</script>
<style type="text/css">
	.fontStyle{
		font-weight:bold;
		color:red;
	}
</style>
</head>
<body>
<%@ include file="/include/jeda.js.lib.jsp"%>
<script type="text/javascript">
	Application = Ext.extend(Ext.Viewport, {
		mask : new Ext.LoadMask(Ext.getBody(), {
			msg : '<fmt:message key="message.wait" />'
		}),
		window : null,
		header : null,
		vNav : null,
		hNav : null,
		tabs : null,
		paramStore : null,
		maxtabs : null,
		statusBar : null,
		homeTab : null,
		portalTab : null,
		centerPanel : null,
		loadTab : function(id, title, url, params, iframe, openInHome) {
			this.tabs.loadTab(id, title, url, params, iframe, openInHome);
		},
		loadTabTool : function(id, title, url, params, iframe, openInHome) {
			this.tabs.loadTabTool(id, title, url, params, iframe, openInHome);
		},
		loadTabEvent : function(id, title, url, params, iframe, openInHome) {
			this.tabs.loadTabEvent(id, title, url, params, iframe, openInHome);
		},
		closeTab : function(id) {
			var tab = this.tabs.getComponent(id);
			if (tab) {
				this.tabs.remove(tab);
			}
		},
		loadWindow : function(url, params) {
			if (this.window) {
				this.window.doLoad({
					url : url,
					params : params
				});
			}
		},
		closeWindow : function() {
			if (this.window) {
				this.window.doClose();
			}
		},
		loadSetup : function() {
			this.loadWindow('${ctx}/setup');
		},
		hideVNav : function() {
			this.vNav.hide();
			this.doLayout();
		},
		hideHNav : function() {
			this.hNav.hide();
		},
		constructor : function() {
	
			//初始化顶部面板.
			this.header = new Jeda.ui.Header();
			//初始化页签容器.
			this.tabs = new Jeda.ui.TabContainer({
				app : this
			});
			this.hNav = new Jeda.ui.HorizontalNavigator();
	
			this.centerPanel = new Ext.Panel({
				region : 'center',
				layout : 'fit',
				items : this.tabs,
				tbar : this.hNav
			});
			//初始化导航面板.
			this.vNav = new Jeda.ui.VerticalNavigator({
				app : this
			});
			//初始化门户页签面板.
			this.portalTab = new Jeda.ui.DashboardTab({
				title : '<fmt:message key="title.home" />'
			
			});
			//初始化固定页签面板.
			this.homeTab = new Jeda.ui.Tab({
				id : 'HOME',
				title : '<fmt:message key="title.portal" />'
			});
			this.tabs.add(this.portalTab);
			//this.tabs.add(this.homeTab);
	
			this.tabs.setActiveTab(0);
	
			var userInfo = '<fmt:message key="application.logged.user" />&nbsp;:&nbsp;';
			userInfo += '<sec:authentication property="principal.name"/>[<sec:authentication property="principal.username"/>]';
			userInfo += '&nbsp;&nbsp;|&nbsp;&nbsp;';
			userInfo += '<fmt:message key="user.org" />&nbsp;:&nbsp;<sec:authentication property="principal.org.name"/>';
			userInfo += '&nbsp;&nbsp;|&nbsp;&nbsp;';
			userInfo += '<fmt:message key="role" />&nbsp;:&nbsp;<sec:authentication property="principal.roles[0].name"/>';
			userInfo += '&nbsp;&nbsp;|&nbsp;&nbsp;';
			userInfo += '<fmt:message key="application.remote.address" />&nbsp;:&nbsp;<c:out value="${pageContext.request.remoteAddr}"/>';
	
			//初始化底部面板.
			this.statusBar = new Jeda.ui.StatusBar({
				userInfo : userInfo
			});
	
			Application.superclass.constructor.call(this, {
				layout : 'fit',
				items : [ {
					xtype : 'panel',
					layout : 'border',
					border : false,
					items : [ this.header, this.vNav, this.centerPanel ],
					bbar : this.statusBar
				} ]
			});
	
			this.window = new Jeda.ui.Window();
	
			this.paramStore = new Jeda.data.GlobalParamStore({
				app : this
			});
			this.paramStore.load();
		}
	});

	var app;
	var taskRunner;

	Ext.onReady(function() {
		Ext.BLANK_IMAGE_URL = '${ctx}/static/scripts/extjs/resources/images/default/s.gif';
		Ext.QuickTips.init();
		Ext.state.Manager.setProvider(new Ext.state.CookieProvider());

		app = new Application();
		taskRunner = new Ext.util.TaskRunner();

	});

	function setup() {
		app.loadWindow('setup');
	}
</script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
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
			hideVMenu : function() {
				this.vNav.hide();
				this.doLayout();
			},
			hideHMenu : function() {
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
					title : '<fmt:message key="title.portal" />'
				});
				//初始化固定页签面板.
				this.homeTab = new Jeda.ui.Tab({
					id : 'HOME',
					title : '<fmt:message key="title.home" />'
				});
				this.tabs.add(this.portalTab);
				this.tabs.add(this.homeTab);

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
	</script>
</body>
</html>
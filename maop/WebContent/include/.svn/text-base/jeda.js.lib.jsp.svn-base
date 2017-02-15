<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	/**
	 * 
	 */
	Ext.ns('Jeda.ui');

	Jeda.ui.IFrame = Ext.extend(Ext.BoxComponent, {
		onRender : function(ct, position) {
			this.el = ct.createChild({
				tag : 'iframe',
				id : 'iframe-' + this.id,
				frameBorder : 0,
				src : this.url
			});
		}
	});

	/**
	 * 首页底部状态条.
	 */
	Jeda.ui.StatusBar = Ext.extend(Ext.ux.StatusBar, {
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			var clock = new Ext.Toolbar.TextItem('');
			Jeda.ui.StatusBar.superclass.constructor.call(this, {
				defaultText : cfg.userInfo,
				/* items : [clock, '-'], */
				items : [clock],
				listeners : {
					render: {
		                fn: function(){
		                    Ext.fly(clock.getEl().parent()).addClass('x-status-text-panel').createChild({cls:'spacer'});
		                    var aWeek = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
		                    //定期更新时间
		                    Ext.TaskMgr.start({
		                        run : function() {
		                         Ext.fly(clock.getEl()).update(new Date().format('Y-m-d H:i:s') + '  '
		                           + aWeek[new Date().getDay()]);
		                        },
		                        interval : 1000
		                       });
		                },
		                delay: 100
		            }
				}
			});
		}
	});

	/**
	 * 窗口组件.
	 */
	Jeda.ui.Window = Ext.extend(Ext.Window, {
		windowGroup : null,
		modal : null,
		closeAction : null,
		height : null,
		width : null,
		minimizable :null,
		resizable :null,
		autoDestroy : true,
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			this.windowGroup = new Ext.WindowGroup();
			this.windowGroup.zseed = 7000;
			// 设置基类属性

			Jeda.ui.Window.superclass.constructor.call(this, {
				layout : 'fit',
				plain : true,
				constrain :false,
				resizable :this.modal == null ? false : true,
				modal : this.modal == null ? true : false,
				autoDestroy : true,
				autoScroll : true,
				height : this.height == null ? document.body.clientHeight * 0.5 : document.body.clientHeight * 0.8,
				width : this.width == null ? document.body.clientWidth * 0.5 : document.body.clientWidth * 0.7,
				closeAction : this.closeAction == null? 'hide':'close',
				maximizable : true,
				minimizable : this.minimizable == null ? false : true,
				manager : this.windowGroup,
				items : [ {
					autoScroll : true,
					layout : 'fit',
					border : false
				} ]
			});
		},
		doLoad : function(cfg) {
			this.removeAll();
			this.add({
				id : "window",
				autoScroll : true,
				layout : 'fit',
				border : false,
				autoLoad : {
					url : cfg.url,
					params : cfg.params,
					discardUrl : false,
					nocache : true,
					timeout : 3000,
					method : 'GET',
					scripts : true
				}
			});
			this.doLayout();
			if (!this.isVisible()) {
				this.show();
			}
		},
		doClose : function() {
			this.removeAll();
			this.hide();
		}
	});

	/**
	 * 首页顶部面板.
	 */
	Jeda.ui.Header = Ext.extend(Ext.Panel, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.Header.superclass.constructor.call(this, {
				region : 'north',
				frame : true,
				border : false,
				height : 58,
				margins : '0 0 0 0',
				autoScroll : true,
				autoLoad : {
					url : 'header',
					scripts : true
				}
			});
		}

	});

	/**
	 * 首页横向导航面板.
	 */
	Jeda.ui.HorizontalNavigator = Ext.extend(Ext.Toolbar, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.HorizontalNavigator.superclass.constructor.call(this, {
				border : false
			});
		},
		renderMenu : function(pid) {
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/menu/nav',
				method : 'GET',
				callback : function(options, success, response) {
					if (success) {
						var menus = Ext.decode(response.responseText);
						for ( var i = 0; i < menus.length; i++) {
							if (menus[i].leaf == false) {
								var button = new Ext.Button({
									text : menus[i].text,
									iconCls : menus[i].iconCls,
									menu : new Jeda.ui.Menu({
										menuid : menus[i].id
									})
								});
							} else {
								var button = new Ext.Button({
									text : menus[i].text,
									iconCls : menus[i].iconCls
								});
							}
							this.add('-');
							this.add(button);
						}
						this.add('-');
					} else {
					}
					this.doLayout();
				},
				params : {
					node : pid
				},
				scope : this
			});
		},
		loadMenu : function(options, success, response) {
			if (success) {
				var menus = Ext.decode(response.responseText);
				for ( var i = 0; i < menus.length; i++) {
					if (menus[i].leaf == false) {
						var button = new Ext.Button({
							text : menus[i].text,
							iconCls : menus[i].iconCls,
							menu : new Jeda.ui.Menu({
								menuid : menus[i].id
							})
						});
					} else {
						var button = new Ext.Button({
							text : menus[i].text,
							iconCls : menus[i].iconCls
						});
					}
					this.add('-');
					this.add(button);
				}
				this.add('-');
			} else {
			}
			this.doLayout();
		}
	});

	/**
	 * 菜单组件.
	 */
	Jeda.ui.Menu = Ext.extend(Ext.menu.Menu, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.Menu.superclass.constructor.call(this, {});
			this.addMenu(this, cfg.menuid, this);
		},
		addMenu : function(p, id, menu) {
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/menu/nav',
				method : 'GET',
				callback : function(options, success, response) {
					if (success) {
						var menus = Ext.decode(response.responseText);
						for ( var i = 0; i < menus.length; i++) {
							var item = new Ext.menu.Item({
								text : menus[i].text,
								iconCls : menus[i].iconCls,
								menu : menus[i].leaf == true ? null : new Jeda.ui.Menu({
									menuid : menus[i].id
								}),
								handler : function(b, e) {
									if (this.leaf == true) {
										app.tabs.loadTab(this.id, this.text, this.link, null, this.iframe, this.openInHome);
									}
								},
								scope : menus[i]
							});
							this.addItem(item);
						}
						this.doLayout();
					}
				},
				params : {
					node : id
				},
				scope : p
			});
		}
	});

	/**
	 * 首页纵向导航面板.
	 */
	Jeda.ui.VerticalNavigator = Ext.extend(Ext.Panel, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.VerticalNavigator.superclass.constructor.call(this, {
				layout : 'accordion',
				region : 'west',
				width : 200,
				minSize : 150,
				maxSize : 250,
				split : true,
				autoScroll : true,
				collapsible : true,
				collapseMode : 'mini',
				margins : '0 0 0 5',
				border : false,
				items : []
			});
		},
		treeClick : function(node) {
			if (!node.isLeaf()) {
				return false;
			}
			app.tabs.loadTab(node.id, node.text, node.attributes.link, null, node.attributes.iframe, node.attributes.openInHome);
		},
		tabChange : function(tabs, tab) {
			for ( var i = 0; i < app.vNav.items.length; i++) {
				var node = app.vNav.get(i).getNodeById(tab.id);
				if (node) {
					app.vNav.get(i).expand(true);
					app.vNav.get(i).getSelectionModel().select(node);
				} else {
					app.vNav.get(i).getSelectionModel().clearSelections();
				}
			}
		},
		loadMenu : function(options, success, response) {
			if (success) {
				var accordions = Ext.decode(response.responseText);
				var nav;
				for ( var i = 0; i < accordions.length; i++) {
					nav = new Ext.tree.TreePanel({
						title : accordions[i].text,
						iconCls : accordions[i].iconCls,
						rootVisible : false,
						autoScroll : true,
						root : new Ext.tree.AsyncTreeNode({
							text : '<fmt:message key="title.nav" />',
							draggable : false,
							id : accordions[i].id
						}),
						loader : new Ext.tree.TreeLoader({
							requestMethod : 'GET',
							dataUrl : '${ctx}/${frameworkPath}/menu/nav'
						})
					});
					nav.on('click', this.treeClick, this);
					this.add(nav);
				}
				this.doLayout();
				nav.addClass()
				app.tabs.on('tabchange', this.tabChange, this);
			} else {
			}
		}
	});

	/**
	 * 首页仪表盘标签面板.
	 */
	Jeda.ui.DashboardTab = Ext.extend(Ext.Panel, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.DashboardTab.superclass.constructor.call(this, {
				id : 'PORTAL',
				title : cfg.title,
				frame : true,
				border : false,
				autoScroll : true,
				autoLoad : {
					url : 'portal',
					scripts : true
				}
			});
		}
	});

	/**
	 * 首页标签面板.
	 */
	Jeda.ui.Tab = Ext.extend(Ext.Panel, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.Tab.superclass.constructor.call(this, {
				id : this.id,
				title : this.title,
				autoScroll : true,
				layout : 'fit',
				border : false,
				closable : this.closable ? true : false
			});
		},
		doLoad : function() {
			this.load({
				url : this.url,
				params : this.params,
				method : 'GET',
				discardUrl : false,
				nocache : true,
				timeout : 3000,
				scripts : true
			});
		}
	});

	/**
	 * 首页标签容器面板.
	 */
	Jeda.ui.TabContainer = Ext.extend(Ext.TabPanel, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.ui.TabContainer.superclass.constructor.call(this, {
				enableTabScroll : true,
				activeTab : 0,
				margins : '0 5 0 0',
				border : false,
				items : [],
				plugins : new Ext.ux.TabCloseMenu({
					closeTabText : '<fmt:message key="button.tab.close" />',
					closeOtherTabsText : '<fmt:message key="button.tab.close.other" />',
					closeAllTabsText : '<fmt:message key="button.tab.close.all" />'
				}),
				listeners : {
				// beforeremove : function() {}
				}
			});
		},
		loadTab : function(id, title, url, params, iframe, openInHome) {
			var tab = this.getComponent(id);
			if (!tab) {
				var panel = new Jeda.ui.Tab({
					id : id,
					title : title,
					url : url,
					params : params,
					closable : !openInHome
				});
				if (openInHome) {
					this.remove(this.tabs.get(1), true);
					tab = this.insert(1, panel);
				} else {
					if (this.items.length >= app.maxtabs) {
						Ext.Msg.show({
							title : '<fmt:message key="error.title" />',
							msg : '<fmt:message key="message.tabs.limit" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return false;
					} else {
						tab = this.add(panel);
					}
				}
				this.setActiveTab(tab);
				if (iframe) {
					tab.add(new Jeda.ui.IFrame({
						id : id + "panel",
						url : url
					}));
					tab.doLayout();
				}
			} else {
				Ext.apply(tab, {
					id : id,
					title : title,
					url : url,
					params : params
				});
				tab.removeAll();
			}
			this.setActiveTab(tab);
			tab.doLoad();
		},
		//--------------------------------------------------------------------------------------------------------
		//仅限工具箱使用
		loadTabTool : function(id, title, url, params, iframe, openInHome) {
			var tab = this.getComponent(id);
			
			if (!tab) {
				var panel = new Jeda.ui.Tab({
					id : id,
					title : title,
					url : url,
					params : params,
					closable : !openInHome,
					listeners : {
						scope : this,
						'activate' : function(panel) {
							if(typeof Ext.getCmp(id+'VIEW')!='undefined'){
								if(typeof Ext.getCmp(id+'VIEW').window.get(0)!='undefined'){
									if(Ext.getCmp(id+'VIEW').window.get(0).getId().indexOf("ext-comp")==-1){
								Ext.getCmp(id+'VIEW').window.show();
									}
								}
							}
						},
						'deactivate' : function(panel) {
							if(typeof Ext.getCmp(id+'VIEW')!='undefined'){
								
								Ext.getCmp(id+'VIEW').window.hide();								
							}
						}
						}
				});
				if (openInHome) {
					this.remove(this.tabs.get(1), true);
					tab = this.insert(1, panel);
				} else {
					if (this.items.length >= app.maxtabs) {
						Ext.Msg.show({
							title : '<fmt:message key="error.title" />',
							msg : '<fmt:message key="message.tabs.limit" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return false;
					} else {
						tab = this.add(panel);
					}
				}
				this.setActiveTab(tab);
				if (iframe) {
					tab.add(new Jeda.ui.IFrame({
						id : id + "panel",
						url : url
					}));
					tab.doLayout();
				}
			} else {
				Ext.apply(tab, {
					id : id,
					title : title,
					url : url,
					params : params
				});
				tab.removeAll();
			}
			this.setActiveTab(tab);
			tab.doLoad();
		},
		//--------------------------------------------------------------------------------------------------------------
		//仅限工具箱使用
		loadTabEvent : function(id, title, url, params, iframe, openInHome) {
			var tab = this.getComponent(id);
			
			if (!tab) {
				var panel = new Jeda.ui.Tab({
					id : id,
					title : title,
					url : url,
					params : params,
					closable : !openInHome ,
					listeners : {
						scope : this,
						'activate' : function(panel) {
							if(typeof Ext.getCmp(id+'tools')!='undefined'){
								if(typeof Ext.getCmp(id+'tools').window.get(0)!='undefined'){
									if(Ext.getCmp(id+'tools').window.get(0).getId().indexOf("ext-comp")==-1){
										
								Ext.getCmp(id+'tools').window.show();
								
									
									}
								}
							}
						},
						'deactivate' : function(panel) {
							if(typeof Ext.getCmp(id+'tools')!='undefined'){
								if(typeof Ext.getCmp(id+'tools').window.get(0)!='undefined'){
									if(Ext.getCmp(id+'tools').window.get(0).getId().indexOf("ext-comp")==-1){
										 Ext.getCmp(id+'tools').window.get(0).get(0).setActiveTab(0);
									   }
									}
								Ext.getCmp(id+'tools').window.hide();
								
							 }
						  }
						} 
				});
				if (openInHome) {
					this.remove(this.tabs.get(1), true);
					tab = this.insert(1, panel);
				} else {
					if (this.items.length >= app.maxtabs) {
						Ext.Msg.show({
							title : '<fmt:message key="error.title" />',
							msg : '<fmt:message key="message.tabs.limit" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return false;
					} else {
						tab = this.add(panel);
					}
				}
				this.setActiveTab(tab);
				if (iframe) {
					tab.add(new Jeda.ui.IFrame({
						id : id + "panel",
						url : url
					}));
					tab.doLayout();
				}
			} else {
				Ext.apply(tab, {
					id : id,
					title : title,
					url : url,
					params : params
				});
				tab.removeAll(true);
			}
			this.setActiveTab(tab);
			tab.doLoad();
		}
		//------------------------------------------------------------------------------------------------------------
	});

	Ext.ns('Jeda.data');

	/**
	 * 全局参数数据源.
	 */
	Jeda.data.GlobalParamStore = Ext.extend(Ext.data.JsonStore, {
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			Jeda.data.GlobalParamStore.superclass.constructor.call(this, {
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/config/property',
				root : 'data',
				fields : [ 'tabSize', 'copyright', 'appTitle', 'treeMenu' ]
			});
		},
		listeners : {
			load : function(store, records, options) {
				//初始化最大允许打开标签数量
				app.maxtabs = store.getAt(0).get('tabSize');
				app.statusBar.addText('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&copy;&nbsp;' + store.getAt(0).get('copyright'));
				app.statusBar.doLayout();
				Ext.getDoc().set({
					'title' : store.getAt(0).get('appTitle')
				});
				if (store.getAt(0).get('treeMenu') == true) {
					Ext.Ajax.request({
						url : '${ctx}/${frameworkPath}/menu/nav',
						method : 'GET',
						callback : app.vNav.loadMenu,
						params : {
							node : ''
						},
						scope : app.vNav
					});
					app.hideHNav();
				} else {
					Ext.Ajax.request({
						url : '${ctx}/${frameworkPath}/menu/nav',
						method : 'GET',
						callback : app.hNav.loadMenu,
						params : {
							node : ''
						},
						scope : app.hNav
					});
					app.hideVNav();

				}

			}
		}
	});

	Ext.util.Observable.observeClass(Ext.data.Connection);
	Ext.data.Connection.on('requestexception', function(connection, response, options) {
		switch (response.status) {
		case 403:
			Ext.Msg.show({
				title : '<fmt:message key="error.title" />',
				msg : '<fmt:message key="error.access.denied" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			this.tabs.getActiveTab().update(response.responseText);
			break;
		case 4031:
			Ext.Msg.show({
				title : '<fmt:message key="error.title" />',
				msg : '<fmt:message key="error.domain.access.denied" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			this.tabs.getActiveTab().update(response.responseText);
			break;
		case 404:
			Ext.Msg.show({
				title : '<fmt:message key="error.title" />',
				msg : '<fmt:message key="error.resource.not.found" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			this.closeTab(this.tabs.getActiveTab());
			break;
		case 500:
			Ext.Msg.show({
				title : '<fmt:message key="error.title" />',
				msg : '<fmt:message key="error.internal.server.error" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			this.closeTab(this.tabs.getActiveTab());
			break;
		}
	}, this);
	Ext.data.Connection.on('requestcomplete', function(connection, response, options) {
		if (response && response.getResponseHeader && response.getResponseHeader('session_timeout')) {
			Ext.Msg.show({
				title : '<fmt:message key="error.title" />',
				msg : '<fmt:message key="error.session.invalidate" />.<fmt:message key="button.relogin" />?',
				buttons : Ext.MessageBox.YESNO,
				icon : Ext.MessageBox.WARNING,
				closable : false,
				fn : function(buttonId, text, opt) {
					if (buttonId == 'yes') {
						window.location.href = '${ctx}/login';
					} else if (buttonId == 'no') {
						window.location.href = '${ctx}/logout';
					}
				}
			});
		}
	}, this);
</script>

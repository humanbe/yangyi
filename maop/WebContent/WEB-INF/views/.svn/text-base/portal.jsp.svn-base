<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	PortalHome = Ext.extend(Ext.ux.Portal, {
		constructor : function(cfg) {
			Ext.apply(this, cfg);
			PortalHome.superclass.constructor.call(this, {
				items : [ {
					columnWidth : .33,
					style : 'padding:10px 0px 10px 10px',
					items : []
				}, {
					columnWidth : .33,
					style : 'padding:10px 0px 10px 10px',
					items : []
				}, {
					columnWidth : .33,
					style : 'padding:10px 0px 10px 10px',
					items : []
				} ],
				listeners : {
					'drop' : function(e) {
					}
				}
			});
			this.loadLayout();
		},
		loadLayout : function() {
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/portletlocation/layout',
				params : {
					positionId : '<sec:authentication property="principal.position.id"/>'
				},
				method : 'GET',
				callback : this.renderLayout,
				scope : this
			});
		},
		renderLayout : function(options, success, response) {
			if (success) {
				var layouts = Ext.decode(response.responseText).data;
				var portlet;
				for ( var i = 0; i < layouts.length; i++) {
					portlet = new Ext.ux.Portlet({
						id : 'PORTAL_' + layouts[i].id,
						title : layouts[i].title,
						autoScroll : true,
						height : 250,
						tools : [ {
							id : 'refresh',
							handler : function() {
								Ext.getCmp(layouts[i].id).getUpdater().refresh();
							}
						}, {
							id : 'close',
							handler : function(e, target, panel) {
								panel.ownerCt.remove(panel, true);
							}
						} ],
						autoLoad : {
							url : layouts[i].url,
							scripts : true
						}
					});
					this.items.get(layouts[i].column).add(portlet);
				}
				this.doLayout();
			}
		}
	});

	// 实例化,并加入到TAB页中
	Ext.getCmp("PORTAL").add(new PortalHome());
	// 刷新布局
	Ext.getCmp("PORTAL").doLayout();
</script>

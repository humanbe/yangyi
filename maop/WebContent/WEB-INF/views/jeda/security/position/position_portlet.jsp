<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	PositionPortlet = Ext.extend(Ext.ux.Portal, {
		constructor : function(cfg) {
			Ext.apply(this, cfg);
			PositionPortlet.superclass.constructor.call(this, {
				tbar : new Ext.Toolbar({
					items : [ '-', {
						iconCls : 'button-import',
						text : '<fmt:message key="button.import" />',
						handler : this.showPortletAddWindow,
						scope : this
					}, '-', {
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						handler : this.saveLayout,
						scope : this
					} ]
				}),
				items : [ {
					columnWidth : .33,
					style : 'padding:10px 0 10px 10px',
					items : []
				}, {
					columnWidth : .33,
					style : 'padding:10px 0 10px 10px',
					items : []
				}, {
					columnWidth : .33,
					style : 'padding:10px 0 10px 10px',
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
					positionId : '${param.positionId}'
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
						id : 'POSITION_' + layouts[i].id,
						title : layouts[i].title,
						autoScroll : true,
						height : 200,
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
		},
		showPortletAddWindow : function() {
			var params = {
				positionId : '${param.positionId}'
			};
			app.loadWindow('${ctx}/${frameworkPath}/portlet/import', params);
		},
		addPortlet : function() {

		},
		saveLayout : function() {
			app.mask.show();
			var ids = new Array();
			var cols = new Array();
			var rows = new Array();
			var col;
			var x = 0;
			for ( var i = 0; i < this.items.length; i++) {
				col = this.items.get(i).items.length;
				for ( var j = 0; j < col; j++) {
					var id = this.items.get(i).items.get(j).id;
					ids[x] = id.substring(9, id.length);
					cols[x] = i;
					rows[x] = j;
					x++;
				}
			}
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/portletlocation/save',
				method : 'POST',
				success : this.saveSuccess,
				failure : this.saveFailure,
				params : {
					rows : rows,
					columns : cols,
					ids : ids,
					positionId : '${param.positionId}'
				},
				scope : this
			});
		},
		saveSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				createFailure();
				return false;
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		saveFailure : function() {
			app.mask.hide();
		}

	});

	app.window.get(0).add(new PositionPortlet());
	app.window.get(0).doLayout();
</script>
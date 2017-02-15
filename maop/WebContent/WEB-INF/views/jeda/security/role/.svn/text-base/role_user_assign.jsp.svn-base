<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	RoleUserAssignTree = Ext.extend(Ext.tree.TreePanel, {
		unchecked : null,
		checked : null,
		constructor : function(cfg) {

			Ext.apply(this, cfg);
			this.unchecked = new Array();
			this.checked = new Array();

			RoleUserAssignTree.superclass.constructor.call(this, {
				autoScroll : true,
				margins : '0 0 0 5',
				root : new Ext.tree.AsyncTreeNode({
					text : '<sec:authentication property="principal.org.name"/>',
					draggable : false,
					iconCls : 'node-root',
					id : '<sec:authentication property="principal.org.id"/>'
				}),
				tools : [ {
					id : 'refresh',
					scope : this,
					handler : function() {
						this.root.reload();
						this.expandAll();
					}
				} ],
				loader : new Ext.tree.TreeLoader({
					requestMethod : 'GET',
					dataUrl : '${ctx}/${frameworkPath}/role/user/${param.role}'
				}),
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.grantUser
				}, {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					handler : function() {
						app.closeWindow();
					}
				} ],
				listeners : {
					'checkchange' : function(node, checked) {
						if (checked) {
							if (this.checked.indexOf(node.id) == -1 && this.unchecked.indexOf(node.id) == -1) {
								this.checked.push(node.id);
							}
						} else {
							if (this.unchecked.indexOf(node.id) == -1 && this.checked.indexOf(node.id) == -1) {
								this.unchecked.push(node.id);
							}
						}

					}
				}
			});
			//this.expandAll();
			//展开一级
			this.getRootNode().expand(1);
		},
		grantUser : function() {
			app.mask.show();
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/role/user',
				success : this.assignSuccess,
				failure : this.assignFailure,
				params : {
					checked : this.checked,
					unchecked : this.unchecked,
					role : '${param.role}'
				}
			});
		},

		assignSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		assignFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});

	app.window.get(0).add(new RoleUserAssignTree());
	app.window.get(0).doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	RoleMenuAssignTree = Ext.extend(Ext.tree.TreePanel, {
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 设置基类属性
			RoleMenuAssignTree.superclass.constructor.call(this, {
				autoScroll : true,
				margins : '0 0 0 5',
				root : new Ext.tree.AsyncTreeNode({
					text : '<fmt:message key="menu" />',
					draggable : false,
					iconCls : 'node-root',
					id : 'TREE_ROOT_NODE'
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
					dataUrl : '${ctx}/${frameworkPath}/role/menu/${param.role}'
				}),
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.grantMenu
				}, {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					scope : this,
					handler : function() {
						app.closeWindow();
					}
				} ],
				listeners : {
					'checkchange' : function(node, checked) {
						if (checked) {
							if (node.parentNode.id != 'TREE_ROOT_NODE') {
								node.bubble(function(n) {
									if (n.getUI().isChecked()) {
										if (!n.parentNode.getUI().isChecked()) {
											n.parentNode.getUI().toggleCheck();
										}
									}
								});
							}
						} else {
							node.eachChild(function(child) {
								child.getUI().toggleCheck(checked);
								child.fireEvent('checkchange', child, checked);
							});
						}
					}
				}
			});
			this.expandAll();
		},
		grantMenu : function() {
			app.mask.show();
			var nodes = this.getChecked('id');
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/role/menu',
				scope : this,
				success : this.assignSuccess,
				failure : this.assignFailure,
				params : {
					menus : nodes,
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

	app.window.get(0).add(new RoleMenuAssignTree());
	app.window.get(0).doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	RoleFunction = Ext.extend(Ext.tree.TreePanel, {
		unchecked : null,
		checked : null,
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
		
			this.unchecked = new Array();
			this.checked = new Array();

			// 设置基类属性
			RoleFunction.superclass.constructor.call(this, {
				autoScroll : true,
				margins : '0 0 0 5',
				root : new Ext.tree.AsyncTreeNode({
					text : '<fmt:message key="function" />',
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
					dataUrl : '${ctx}/${frameworkPath}/role/function/${param.role}'
				}),
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.doSave
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
		},
		doSave : function() {
			app.mask.show();
			var nodes = this.getChecked('id');
			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/role/function',
				scope : this,
				success : this.saveSuccess,
				failure : this.saveFailure,
				params : {
					checked : this.checked,
					unchecked : this.unchecked,
					role : '${param.role}'
				}
			});
		},
		saveSuccess : function(response, options) {
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
		saveFailure : function() {
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

	app.window.get(0).add(new RoleFunction());
	app.window.get(0).doLayout();
</script>
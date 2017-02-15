<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	PathMenuAssignTree = Ext.extend(Ext.tree.TreePanel, {
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			PathMenuAssignTree.superclass.constructor.call(this, {
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
						this.root.expand();
					}
				} ],
				loader : new Ext.tree.TreeLoader({
					requestMethod : 'GET',
					dataUrl : '${ctx}/${appPath}/jedarpt/getShowPathTree'
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
				} ]
			});
			//this.expandAll(); //全部展开
			this.root.expand(); //只展开根节点
		},
		// 保存
		doSave : function() {
			var nodes = this.getChecked();
			var code = '';
			var name = '';
			if(nodes.length == 1){
				var node = nodes[0];
				code = node.id ;
				name = '['+node.text+']' ;
				// 最多取到目录树的第五层
				var par1 = node.parentNode;
				if(par1!=this.getRootNode()){
					name = '['+par1.text+']'+'--'+name ;
					var par2 = par1.parentNode;
					if(par2!=this.getRootNode()){
						name = '['+par2.text+']'+'--'+name ;
						var par3 = par2.parentNode;
						if(par3!=this.getRootNode()){
							name = '['+par3.text+']'+'--'+name ;
							var par4 = par3.parentNode;
							if(par4!=this.getRootNode()){
								name = '['+par4.text+']'+'--'+name ;
							}
						}
					}
				}
				Ext.getCmp('parent_menu_name_edit').setValue(name);
				Ext.getCmp('parent_menu_code_edit').setValue(code);
				app.closeWindow();
			}else {
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '请选择一个节点！',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
		    	});
			}
		}
	});

	app.window.get(0).add(new PathMenuAssignTree());
	app.window.get(0).doLayout();
</script>

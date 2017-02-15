<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义数据子项列表
SubItemList = Ext.extend(Ext.grid.GridPanel, {
	gridStore : null,// 数据列表数据源
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);

		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${frameworkPath}/subitem/list',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'id', 'name', 'value', 'order', 'creator', 'created', 'modifier', 'modified' ],
			remoteSort : true,
			sortInfo : {
				field : 'order',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 20,
				parent : '${param.parent}'
			}
		});

		// 加载数据源的数据
		this.gridStore.load();

		// 设置基类属性
		SubItemList.superclass.constructor.call(this, {
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm, {
				header : '<fmt:message key="subitem.id" />',
				dataIndex : 'id',
				hidden : true
			}, {
				id : 'name',
				header : '<fmt:message key="subitem.name" />',
				dataIndex : 'name',
				sortable : true
			}, {
				header : '<fmt:message key="subitem.value" />',
				dataIndex : 'value',
				sortable : true
			}, {
				header : '<fmt:message key="column.order" />',
				dataIndex : 'order',
				sortable : true
			}, {
				header : '<fmt:message key="column.creator" />',
				dataIndex : 'creator',
				align : 'center',
				sortable : true,
				hidden : true
			}, {
				header : '<fmt:message key="column.created" />',
				dataIndex : 'created',
				align : 'center',
				sortable : true,
				hidden : true
			}, {
				header : '<fmt:message key="column.modifier" />',
				dataIndex : 'modifier',
				align : 'center',
				sortable : true,
				hidden : true
			}, {
				header : '<fmt:message key="column.modified" />',
				dataIndex : 'modified',
				align : 'center',
				sortable : true,
				hidden : true
			} ],
			tbar : new Ext.Toolbar( {
				items : [ '-', {
					iconCls : 'button-add',
					text : '<fmt:message key="button.create" />',
					scope : this,
					handler : this.doCreate
				}, '-', {
					iconCls : 'button-edit',
					text : '<fmt:message key="button.edit" />',
					scope : this,
					handler : this.doEdit
				}, '-', {
					iconCls : 'button-delete',
					text : '<fmt:message key="button.delete" />',
					scope : this,
					handler : this.doDelete
				}, '-' ]
			}),
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true
			})
		});

	},
	// 新建事件
	doCreate : function() {
		var params = {
			parent : '${param.parent}'
		};
		app.loadWindow('${ctx}/${frameworkPath}/subitem/create', params);
	},

	// 编辑事件
	doEdit : function() {
		if (this.getSelectionModel().getCount() == 1) {
			var record = this.getSelectionModel().getSelected();
			var params = {
				id : record.get("id"),
				parent : '${param.parent}'
			};
			app.loadWindow('${ctx}/${frameworkPath}/subitem/edit', params);
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			return false;
		}
	},
	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.delete.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 删除成功回调方法
	deleteSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			this.getStore().reload();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	// 删除事件
	doDelete : function() {
		if (this.getSelectionModel().getCount() > 0) {
			var records = this.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get("id");
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.delete" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${frameworkPath}/subitem/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								ids : ids,
								_method : 'delete'
							}
						});

					}
				}
			});
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			return false;
		}
	}
});

app.window.get(0).add(new SubItemList({
	id : 'SubItemList'
}));
app.window.get(0).doLayout();
</script>


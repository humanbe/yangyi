<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<fmt:message key="button.find" var="i18n_button_find" />
<script type="text/javascript">

var grid = null ;
var form = null ;
var rowIndex = '${param.rowIndex}'; 
var oldValue = '${param.oldValue}'; 

//定义数据项列表
ItemList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	csmSubItem : null,
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();
		csmSubItem = new Ext.grid.CheckboxSelectionModel();

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${frameworkPath}/item/rptParam',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'id', 'name', 'description', 'order', 'creator', 'created', 'modifier', 'modified' ],
			remoteSort : true,
			sortInfo : {
			},
			baseParams : {
			}
		});
		// 默认选中数据
		this.gridStore.on('load', function(store) {
    		store.each(function(item) {
				if(item.get('id') == oldValue){
					grid.getSelectionModel().selectRecords(item,false);
				}
			}); 
		});
		
		this.gridStore.load();

		// 实例化数据列表组件
		grid = new Ext.grid.GridPanel({
			border : false,
			loadMask : true,
			height : 330 ,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm, {
				header : '<fmt:message key="item.id" />',
				dataIndex : 'id',
				align : 'center',
				sortable : true
			}, {
				id : 'name',
				header : '<fmt:message key="item.name" />',
				dataIndex : 'name',
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="item.description" />',
				dataIndex : 'description',
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="column.order" />',
				dataIndex : 'order',
				width : 50,
				align : 'center',
				sortable : true
			}, {
				header : '<fmt:message key="item.subitem" />',
				dataIndex : 'id',
				width : 50,
				align : 'center',
				scope : this,
				renderer : this.operation
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
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.doSave
				}, '-', {
					text : '<fmt:message key="button.cancel" />',
       				iconCls : 'button-cancel',
					scope : this,
					handler : this.doCancel
				}]
			})
		});

		// 实例化查询表单
		form = new Ext.FormPanel( {
			labelAlign : 'right',
			labelWidth : 80,
			frame : true,
			split : true,
			autoScroll : true,
			border : false,
			items : [{
                layout: 'column',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
                items: [{
                	columnWidth:.7,
                	layout: 'form',
                	defaults: {anchor : '100%'},
                	items : [{
                		xtype : 'textfield',
    					fieldLabel : '<fmt:message key="item.name" />',
    					name : 'name',
    					tabIndex : this.tabIndex++
                	}]
                },{
					columnWidth:.1,
					layout: 'form',
                	defaults: {anchor : '100%'},
                	items : [{
                   		xtype : 'button',
       					text : '查询',
       					tabIndex : this.tabIndex++,
       					listeners : {
       						click : function(b, e) {
       							Ext.apply(grid.getStore().baseParams, form.getForm().getValues());
       							grid.getStore().load();
       					    }
       					}
                	}]
				},{
					columnWidth:.1,
					layout: 'form',
                	defaults: {anchor : '100%'},
                	items : [{
                		xtype : 'button',
    					text : '重置',
    					tabIndex : this.tabIndex++,
    					listeners : {
       						click : function(b, e) {
       							form.getForm().reset();
       					    }
       					}
                	}]
				}]
			}]
		});

		// 设置基类属性
		ItemList.superclass.constructor.call(this, {
			layout : 'form',
			border : false,
			items : [form, grid ]
		});
	},
	// 配置
	operation : function(id) {
		return "<a href=\"javascript:subitem('" + id + "');\" class=\"link-config\">" + '<fmt:message key="button.config" />' + "</a>";
	},
	
	// 保存操作
	doSave : function() {
		var val = ''; //数据字典默认值
		var records = grid.getSelectionModel().getSelections();
		var length = records.length ;
		if(length > 1){
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '请选择一条数据！',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR,
				minWidth : 200
			}); 
			return false;
		}else{
			if(length == 1){
				val = records[0].get('id');
			}
		}
		Ext.getCmp('param_edit_grid_edit').getStore().getAt(rowIndex).set('dic_code',val);
		app.closeWindow();
	},
	
	// 取消操作
	doCancel : function() {
		app.closeWindow();
	}
});

function subitem(id) {
	// 实例化数据列表数据源
	var gridStoreSubItem = new Ext.data.JsonStore( {
		proxy : new Ext.data.HttpProxy( {
			method : 'POST',
			url : '${ctx}/${frameworkPath}/subitem/rptParam',
			disableCaching : false
		}),
		autoDestroy : true,
		root : 'data',
		fields : [ 'id', 'name', 'value', 'order', 'creator', 'created', 'modifier', 'modified' ],
		remoteSort : true,
		baseParams : {
			parent : id
		}
	});

	// 加载数据源的数据
	gridStoreSubItem.load();
	
	var SubItem_Show_Win = new Ext.Window({
		title : '配置项',
		layout:'form',
		width:450,
		height:260,
		plain:true,
		modal : true,
		closable : true,
		resizable : false,
		draggable : true,
		closeAction :'close',
		items : new Ext.grid.GridPanel({
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			height : 230,
			viewConfig : {
				forceFit : true
			},
			store : gridStoreSubItem,
			sm : csmSubItem,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(),/*  csmSubItem,  */{
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
			}]
		})
	});
	SubItem_Show_Win.show();
}

app.window.get(0).add(new ItemList());
app.window.get(0).doLayout();
</script>
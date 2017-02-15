<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplCodesStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
});
//定义列表
TimesTransConfManageList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
		aplCodesStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/timestransconfmanage/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['aplCode', 'countItem', 'relatedItem', 'type'],
			remoteSort : true,
			sortInfo : {
				field : 'aplCode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			},
			listeners : {
				'load' : function(store){
					if(store.getCount() > 0){
						Ext.getCmp('TimesTransConfManageIndexExcel').enable();
					}else{
						Ext.getCmp('TimesTransConfManageIndexExcel').disable();
					}
				}
			}
		});

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'TimesTransConfManageListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
				{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', sortable : true},
				//{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', renderer : this.appsysStoreValue,sortable : true},
				{header : '<fmt:message key="property.countItem" />', dataIndex : 'countItem', sortable : true},
				{header : '<fmt:message key="property.relatedItem" />', dataIndex : 'relatedItem', sortable : true},
				{header : '<fmt:message key="property.type.trans" />', dataIndex : 'type', sortable : true}
	  		],
	  		
			// 定义按钮工具条
				items : [ '-' ]
			}),
			
			// 定义分页工具条
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					id : 'TimesTransConfManageIndexExcel',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					disabled : true,
					handler : this.doExportXLS
				} ]
			}),
			
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});

		// 实例化查询表单
			id : 'TimesTransConfManageFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 60,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					store : aplCodesStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					name : 'aplCode',
					hiddenName : 'aplCode',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this ,
						beforequery : function(e){
							var combo = e.combo;
							combo.collapse();
							 if(!e.forceAll){
								var input = e.query.toUpperCase();
								var regExp = new RegExp('.*' + input + '.*');
								combo.store.filterBy(function(record, id){
									var text = record.get(combo.displayField);
									return regExp.test(text);
								}); 
								combo.restrictHeight();
								combo.expand();
								return false;
							} 
						} 
					}
				}
			],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			} ]
		});

		// 设置基类属性
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	appsysStoreValue : function(value) {
		var index = aplCodesStore.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return aplCodesStore.getAt(index).get('appsysName');
		}
	},
	
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('add_TimesTransConfManage', '<fmt:message key="button.create" /><fmt:message key="property.timesTransConfInfo" />', '${ctx}/${managePath}/timestransconfmanage/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			aplCode : record.get('aplCode'),
			countItem : encodeURIComponent(record.get('countItem'))
		};
		var tab = Ext.getCmp("view_TimesTransConfManage");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.timesTransConfInfo" />');
		}
		app.loadTab('view_TimesTransConfManage', 
				'<fmt:message key="button.view" /><fmt:message key="property.timesTransConfInfo" />', 
				'${ctx}/${managePath}/timestransconfmanage/view', 
				params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				aplCode : record.get('aplCode'),
				countItem : encodeURIComponent(record.get('countItem'))
			};
			app.loadTab('edit_TimesTransConfManage', '<fmt:message key="button.edit" /><fmt:message key="property.timesTransConfInfo" />', '${ctx}/${managePath}/timestransconfmanage/edit', params);
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 删除事件
	doDelete : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel().getSelections();
			var aplCodes = new Array();
			var countItems = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i] = records[i].get('aplCode');
				countItems[i] = records[i].get('countItem');
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
							url : '${ctx}/${managePath}/timestransconfmanage/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodes : aplCodes,
								countItems : countItems,
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
		}
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
			this.grid.getStore().reload();// 重新加载数据源
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
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
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/timestransconfmanage/excel.xls';
	}
});

var timesTransConfManageList = new TimesTransConfManageList();
</script>

<script type="text/javascript">
timesTransConfManageList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : timesTransConfManageList,
	handler : timesTransConfManageList.doCreate
	},'-');
</script>
<script type="text/javascript">
timesTransConfManageList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : timesTransConfManageList,
	handler : timesTransConfManageList.doEdit
	},'-');
</script>
<script type="text/javascript">
timesTransConfManageList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : timesTransConfManageList,
	handler : timesTransConfManageList.doDelete
	},'-');
</script>
<script type="text/javascript">
Ext.getCmp("MgrTimesTransConfManageIndex").add(timesTransConfManageList);
Ext.getCmp("MgrTimesTransConfManageIndex").doLayout();
</script>
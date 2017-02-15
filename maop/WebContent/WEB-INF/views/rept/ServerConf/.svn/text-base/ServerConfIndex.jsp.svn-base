<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplCodesStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
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

var serverGroupStoreIndex = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

//定义列表
ServerConfList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		aplCodesStore.load();
		serverGroupStoreIndex.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/serverconf/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['aplCode', 'srvCode', 'loadMode', 'serClass', 
			          'serName', 'memConf', 'cpuConf', 'diskConf',
			          'ipAddress', 'floatAddress', 'autoCapture'],
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
						Ext.getCmp('ServerConfIndexExcel').enable();
					}else{
						Ext.getCmp('ServerConfIndexExcel').disable();
					}
				}
			}
		});

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'ServerConfListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode',sortable : true},
				//{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', renderer : this.appsysStoreValue,sortable : true},
				{header : '<fmt:message key="property.srvCode" />', dataIndex : 'srvCode', sortable : true},
				{header : '<fmt:message key="property.loadMode" />', dataIndex : 'loadMode', sortable : true},
				{header : '<fmt:message key="property.serClass" />', dataIndex : 'serClass', sortable : true, 
					renderer : function(value){
						var total = serverGroupStoreIndex.getCount();
						for(var i = 0 ;i < total ;i++ ){
							if(value == serverGroupStoreIndex.getAt(i).get('value')){
								return serverGroupStoreIndex.getAt(i).get('name');
							}
						 }
						return value;
					}	
				},
				{header : '<fmt:message key="property.serName" />', dataIndex : 'serName', sortable : true},
				{header : '<fmt:message key="property.memConf" />', dataIndex : 'memConf', sortable : true},
				{header : '<fmt:message key="property.cpuConf" />', dataIndex : 'cpuConf', sortable : true},
				{header : '<fmt:message key="property.diskConf" />', dataIndex : 'diskConf', sortable : true},
				{header : '<fmt:message key="property.ipAddress" />', dataIndex : 'ipAddress', sortable : true},
				{header : '<fmt:message key="property.floatAddress" />', dataIndex : 'floatAddress', sortable : true},
				{header : '<fmt:message key="property.autoCapture" />', dataIndex : 'autoCapture', sortable : true}
	  		],
	  		
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					id : 'ServerConfIndexExcel',
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

		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'ServerConfFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 110,
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
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.srvCode" />',
					name : 'srvCode'
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					name : 'ipAddress'
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

		// 设置基类属性		ServerConfList.superclass.constructor.call(this, {
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
		app.loadTab('add_ServerConf', '<fmt:message key="button.create" /><fmt:message key="property.serverConfInfo" />', '${ctx}/${managePath}/serverconf/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			aplCode : record.get('aplCode'),
			srvCode : record.get('srvCode')
		};
		var tab = Ext.getCmp("view_ServerConf");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.serverConfInfo" />');
		}
		app.loadTab('view_ServerConf', 
				'<fmt:message key="button.view" /><fmt:message key="property.serverConfInfo" />', 
				'${ctx}/${managePath}/serverconf/view', 
				params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
					aplCode : record.get('aplCode'),
					srvCode : record.get('srvCode')
			};
			app.loadTab('edit_ServerConf', '<fmt:message key="button.edit" /><fmt:message key="property.serverConfInfo" />', '${ctx}/${managePath}/serverconf/edit', params);
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
			var srvCodes = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i] = records[i].get('aplCode');
				srvCodes[i] = records[i].get('srvCode');
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
							url : '${ctx}/${managePath}/serverconf/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodes : aplCodes,
								srvCodes : srvCodes,
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
		window.location = '${ctx}/${managePath}/serverconf/excel.xls';
	}
});

var ServerConfList = new ServerConfList();
</script>

<script type="text/javascript">
ServerConfList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : ServerConfList,
	handler : ServerConfList.doCreate
	},'-');
</script>
<script type="text/javascript">
ServerConfList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : ServerConfList,
	handler : ServerConfList.doEdit
	},'-');
</script>
<script type="text/javascript">
ServerConfList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : ServerConfList,
	handler : ServerConfList.doDelete
	},'-');
</script>
<script type="text/javascript">
Ext.getCmp("MgrServerConfIndex").add(ServerConfList);
Ext.getCmp("MgrServerConfIndex").doLayout();
</script>

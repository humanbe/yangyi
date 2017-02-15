<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//应用系统
var appsysStoreForCheck =  new Ext.data.Store({
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

var capacityTypeStore = new Ext.data.SimpleStore({
	fields :['capacityTypeDisplay', 'capacityTypeValue'],
	data : [['应用类', '1'], ['系统类', '2'], ['网络类', '3']]
});

var thresholdTypeStore = new Ext.data.SimpleStore({
	fields :['thresholdTypeDisplay', 'thresholdTypeValue'],
	data : [['联机', '1'], ['批量', '2'], ['操作系统', '3'], ['数据库', '4'], 
	        ['中间件', '5'], ['网络层', '6'], ['web层', '7'], ['其他', '8']]
});

//定义列表
CapThresholdAcqList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();
		
		this.userStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/jobdesign/getUsers',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['username','name'])
		});
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/capthresholdacq/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['aplCode', 'capacityType', 'thresholdType', 'thresholdItem','thresholdItemName', 
			          	'busiDemand', 'threshold', 'thresholdDate', 
			          	'thresholdFrom', 'thresholdCheckFlag', 'thresholdExplain', 'thresholdCreator', 
			          	'thresholdCreated', 'thresholdModifier', 'thresholdModified','additionalExplain'],
			remoteSort : true,
			sortInfo : {
				field : 'aplCode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		
		appsysStoreForCheck.load();
		this.userStore.load();
		
		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel({
			id : 'CapThresholdAcqListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode', sortable : true},
				{header : '<fmt:message key="property.capacityType" />', dataIndex : 'capacityType', sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '1': return '应用类';
							case '2': return '系统类';
							case '3': return '网络类';
						}
					}
				},
				{header : '<fmt:message key="property.thresholdType" />', dataIndex : 'thresholdType', sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '1': return '联机';
							case '2': return '批量';
							case '3': return '操作系统';
							case '4': return '数据库';
							case '5': return '中间件';
							case '6': return '网络层';
							case '7': return 'web层';
							case '8': return '其他';
						}
					}
				},
				{header : '<fmt:message key="property.thresholdItem" />', dataIndex : 'thresholdItem', sortable : true},
				{header : '<fmt:message key="property.thresholdItemName" />', dataIndex : 'thresholdItemName', width: 160, sortable : true},
				{header : '<fmt:message key="property.busiDemand" />', dataIndex : 'busiDemand', sortable : true},
				{header : '<fmt:message key="property.threshold" />', dataIndex : 'threshold', sortable : true},
				{header : '<fmt:message key="property.thresholdDate" />', dataIndex : 'thresholdDate', sortable : true},
				{header : '<fmt:message key="property.thresholdFrom" />', dataIndex : 'thresholdFrom', sortable : true},
				{header : '<fmt:message key="property.thresholdCheckFlag" />', dataIndex : 'thresholdCheckFlag', sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '否';
							case '1' : return '是';
						}
					}
				},
				{header : '<fmt:message key="property.thresholdExplain" />', dataIndex : 'thresholdExplain', sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, Store){
						var title = '<fmt:message key="property.thresholdExplain" />';
					    var tip = record.get('thresholdExplain');
					    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
					    //return the display text:
					    return tip;    	
					}
				},
				{header : '<fmt:message key="property.thresholdCreator" />', dataIndex : 'thresholdCreator', sortable : true,
					renderer : this.userStoreValue,
					scope : this
				},
				{header : '<fmt:message key="property.thresholdCreated" />', dataIndex : 'thresholdCreated', sortable : true,
					renderer : function(value){
						if(Ext.isEmpty(value)){
							return '';
						}else{
							return Ext.util.Format.date(new Date(value),'Y-m-d H:i:s');
						}
					}
				},
				{header : '<fmt:message key="property.thresholdModifier" />', dataIndex : 'thresholdModifier', sortable : true,
					renderer : this.userStoreValue,
					scope : this
				},
				{header : '<fmt:message key="property.thresholdModified" />', dataIndex : 'thresholdModified', sortable : true,
					renderer : function(value){
						if(Ext.isEmpty(value)){
							return '';
						}else{
							return Ext.util.Format.date(new Date(value),'Y-m-d H:i:s');
						}
					}
				},
				{header : '<fmt:message key="property.additionalExplain" />', dataIndex : 'additionalExplain', sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, Store){
						var title = '<fmt:message key="property.additionalExplain" />';
					    var tip = record.get('additionalExplain');
					    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';
					    //return the display text:
					    return tip;
					}
				}
	  		],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100
			}),
			
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});

		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'CapThresholdAcqFindFormPanel',
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
			items : [{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					store : appsysStoreForCheck,
					displayField : 'appsysName',
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
				    xtype : 'combo',
					fieldLabel : '<fmt:message key="property.thresholdType" />',
					store : thresholdTypeStore,
					displayField : 'thresholdTypeDisplay',
					valueField : 'thresholdTypeValue',
					hiddenName : 'thresholdType',
					mode: 'local',
					typeAhead: true,
					editable : false, 
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
				    xtype : 'combo',
					fieldLabel : '<fmt:message key="property.capacityType" />',
					store : capacityTypeStore,
					displayField : 'capacityTypeDisplay',
					valueField : 'capacityTypeValue',
					hiddenName : 'capacityType',
					mode: 'local',
					typeAhead: true,
					editable : false, 
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdItem" />',
					name : 'thresholdItem'
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdItemName" />',
					name : 'thresholdItemName'
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

		// 设置基类属性		CapThresholdAcqList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	userStoreValue : function(value) {
		var index = this.userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return value + '(' +this.userStore.getAt(index).get('name') + ')';
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
		app.loadTab('add_CapThresholdAcq', '<fmt:message key="button.create" /><fmt:message key="property.capThresholdAcqInfo" />', '${ctx}/${managePath}/capthresholdacq/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			aplCode : record.get('aplCode'),
			thresholdItem : encodeURIComponent(record.get('thresholdItem'))
		};
		var tab = Ext.getCmp("view_CapThresholdAcq");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.capThresholdAcqInfo" />');
		}
		app.loadTab('view_CapThresholdAcq', 
				'<fmt:message key="button.view" /><fmt:message key="property.capThresholdAcqInfo" />', 
				'${ctx}/${managePath}/capthresholdacq/view', 
				params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
					aplCode : record.get('aplCode'),
					thresholdItem : encodeURIComponent(record.get('thresholdItem'))
			};
			app.loadTab('edit_CapThresholdAcq', '<fmt:message key="button.edit" /><fmt:message key="property.capThresholdAcqInfo" />', '${ctx}/${managePath}/capthresholdacq/edit', params);
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
			var thresholdItems = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i] = records[i].get('aplCode');
				thresholdItems[i] = records[i].get('thresholdItem');
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
							url : '${ctx}/${managePath}/capthresholdacq/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodes : aplCodes,
								thresholdItems : thresholdItems,
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
			this.grid.getStore().reload();// 重新加载数据源			Ext.Msg.show( {
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
	//导出
	doExport : function(){
		window.location = '${ctx}/${managePath}/capthresholdacq/export.xls';
	},
	//保存成功回调
	exportSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO
		});
	},
	// 保存失败回调
	exportFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

var capThresholdAcqList = new CapThresholdAcqList();
</script>

<sec:authorize access="hasRole('THRESHOLD_CREATE')">
<script type="text/javascript">
capThresholdAcqList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : capThresholdAcqList,
	handler : capThresholdAcqList.doCreate
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('THRESHOLD_EDIT')">
<script type="text/javascript">
capThresholdAcqList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : capThresholdAcqList,
	handler : capThresholdAcqList.doEdit
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('THRESHOLD_DELETE')">
<script type="text/javascript">
capThresholdAcqList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : capThresholdAcqList,
	handler : capThresholdAcqList.doDelete
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
capThresholdAcqList.grid.getTopToolbar().add({
	iconCls : 'button-export',
	text : '<fmt:message key="button.export" />',
	scope : capThresholdAcqList,
	handler : capThresholdAcqList.doExport
	},'-');
</script>

<script type="text/javascript">
Ext.getCmp("MgrCapThresholdAcqIndex").add(capThresholdAcqList);
Ext.getCmp("MgrCapThresholdAcqIndex").doLayout();
</script>

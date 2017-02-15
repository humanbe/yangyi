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
aplCodesStore.load();
//定义列表
SysResrcTransList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止
		Ext.getDoc().on('keydown',function(e) {
							if (e.getKey() == 8
									&& e.getTarget().type == 'text'
									&& !e.getTarget().readOnly) {

							} else if (e.getKey() == 8
									&& e.getTarget().type == 'textarea'
									&& !e.getTarget().readOnly) {

							} else if (e.getKey() == 8) {
								e.preventDefault();
							}
						});
	
		
		this.serverGroupStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/ARCH_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		
		this.serverGroupStore.load();
		
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${managePath}/itembaseconf/getSysResrcTransConfList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'APL_CODE',
			           'TRAN_NAME',
			           'SRV_TYPE',
			           'SRV_CODE'],
			remoteSort : true,
			sortInfo : {
				field : 'APL_CODE',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//加载数据源
		this.gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			id : 'SysResrcTransListGridPanel',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), csm, 
			            {
						header : '系统编码', 
						dataIndex : 'APL_CODE',
						scope : this,
						sortable : true
					}, {
						header : '交易名称',
						dataIndex : 'TRAN_NAME',
						sortable : true
					},{
						header : '服务器分类', 
						dataIndex : 'SRV_TYPE',
						sortable : true,
						scope : this,
						renderer : this.serverGroupStoreValue
					},{
						header : '服务器编号（IP）',
						dataIndex : 'SRV_CODE',
						sortable : true
					}
				
	  		],
	  		
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-' ]
			}),
			// 定义数据列表监听事件
			listeners : {

			}
		
		});

		// 实例化查询表单 
		this.form = new Ext.FormPanel( {
			
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
							name : 'APL_CODE',
							hiddenName : 'APL_CODE',
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
							store : this.serverGroupStore ,
							fieldLabel : '服务器分类',
							name : 'SRV_TYPE',
							valueField : 'value',
							displayField : 'name',
							hiddenName : 'SRV_TYPE',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							editable : false,
							allowBlank : false,
							tabIndex : this.tabIndex++,
							allowBlank : false,
							listeners : {
							}
						},
						{
						    xtype : 'textfield',
							fieldLabel : '服务器编号（IP）',
							name : 'SRV_CODE'
						},
						{
						    xtype : 'textfield',
							fieldLabel : '交易名称',
							name : 'TRAN_NAME'
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
		SysResrcTransList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form,
			          this.grid ]
		});
	},
	
	serverGroupStoreValue : function(value) {
		var index = this.serverGroupStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return this.serverGroupStore.getAt(index).get('name');
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
		app.loadTab('SYSRESRCTRANS_CREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${managePath}/itembaseconf/SysResrcTrans_create');

	},
	
	// 删除事件
	doDelete : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel()
					.getSelections();
			
			var APL_CODES = new Array();
			var TRAN_NAMES= new Array();
			var SRV_TYPES = new Array();
			var SRV_CODES = new Array();
			for ( var i = 0; i < records.length; i++) {
				APL_CODES[i] = records[i].get("APL_CODE");
				TRAN_NAMES[i] =  encodeURIComponent(records[i].get("TRAN_NAME"));
				SRV_TYPES[i] = records[i].get("SRV_TYPE");
				SRV_CODES[i] = records[i].get("SRV_CODE");
				
				
			}

			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.confirm.to.delete" />',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								app.mask.show();

								Ext.Ajax.request({
											url : '${ctx}/${managePath}/itembaseconf/SysResrcTrans_delete',
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												APL_CODES : APL_CODES,
												TRAN_NAMES : TRAN_NAMES,
												SRV_TYPES : SRV_TYPES,
												SRV_CODES :SRV_CODES,
												_method : 'delete'
											}
										});
							}
						}
					});
		} else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.at.least" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}
	},

	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg
				.show({
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
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:'
								+ error,
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();// 重新加载数据源

			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.successful" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
		}
	}
	
});

var SysResrcTransList = new SysResrcTransList();

</script>

<%-- <sec:authorize access="hasRole('')"> --%>
<script type="text/javascript">
SysResrcTransList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : SysResrcTransList,
	handler : SysResrcTransList.doCreate
	},'-');
</script>
<%-- </sec:authorize> --%>


<%-- <sec:authorize access="hasRole('')"> --%>
	<script type="text/javascript">
	SysResrcTransList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : SysResrcTransList,
		handler : SysResrcTransList.doDelete
	}, '-');
</script>
<%-- </sec:authorize> --%>


<script type="text/javascript">
Ext.getCmp("SYSRESRCTRANS_INFO").add(SysResrcTransList);
Ext.getCmp("SYSRESRCTRANS_INFO").doLayout();
</script>

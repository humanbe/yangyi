<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize = 100;
var sysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appcapariskgrade/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
});
var sysAsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appcapariskgrade/querySystemAdminAs',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysA'])
});
var sysBsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appcapariskgrade/querySystemAdminBs',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysB'])
});
var appAsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appcapariskgrade/queryAppAdminAs',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appA', 'groupName'])
});
var appBsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appcapariskgrade/queryAppAdminBs',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appB'])
});
var groupNameStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/membermanage/queryGroupNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['groupName'])
});
var sysStatusStore = new Ext.data.SimpleStore({
	fields :['sysStatus'],
	data :[['待下线'], ['使用中'], ['未上线'], ['已下线']]
});
var appTypeStore = new Ext.data.ArrayStore({
    fields: ['valueField', 'displayField'],
    data : [ 	['1', '平稳形'],
            	['2', '震荡形']
            ]
});
var disasterRecoverStore = new Ext.data.SimpleStore({
	fields :['disasterRecoverPriority'],
	data :[['A'], ['B'], ['C']]
});
//定义列表
AppCapaRiskGradeList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {
		sysIdsStore.load();
		sysAsStore.load();
		sysBsStore.load();
		appAsStore.load();
		appBsStore.load();
		groupNameStore.load();
		// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/appcapariskgrade/index',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['sysId', 'sysName', 'operationsManager', 'sysA', 'sysB', 'appA', 
			          	'appB', 'projectLeader', 'sysStatus', 'department', 'serviceTime', 
			          	'disasterRecoverPriority', 'securityRank', 'groupName', 'takeOverFlag',
			          	'coreRank', 'importantRank', 'hingeRank', 'outSourcingFlag','appType',
			          	'appOutline','evaluateMonth','evaluateResult','levelCauseDesc'],
			remoteSort : true,
			sortInfo : {
				field : 'sysId',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			},
			listeners : {
				'load' : function(store, records, opt){
					if(store.getCount() > 0){
						Ext.getCmp('AppCapaRiskGradeExport').enable();
					}else{
						Ext.getCmp('AppCapaRiskGradeExport').disable();
					}
				}
			}
		});
		
		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'AppCapaRiskGradeListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				getRowClass : function(record, rowIndex, rowParams, store){   
					if((rowIndex + 1) % 2 === 0){   
						return 'x-gridSys-row-alt';
					}   
				}
			},
			store : this.gridStore,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), 
				{
					header : '<fmt:message key="property.appsyscd" />',
					dataIndex : 'sysId',
					sortable : true,
					width : 80
				},
				{
					header : '<fmt:message key="property.appsystemname" />',
					dataIndex : 'sysName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.operationsManager" />',
					dataIndex : 'operationsManager',
					sortable : true
				},
				{
					header : '<fmt:message key="property.sysadminidA" />',
					dataIndex : 'sysA',
					sortable : true
				},
				{
					header : '<fmt:message key="property.sysadminidB" />',
					dataIndex : 'sysB',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appadminidA" />',
					dataIndex : 'appA',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appadminidB" />',
					dataIndex : 'appB',
					sortable : true
				},
				{
					header : '<fmt:message key="property.projectLeader" />',
					dataIndex : 'projectLeader',
					sortable : true
				},
				{
					header : '<fmt:message key="property.systemStatus" />',
					dataIndex : 'sysStatus',
					sortable : true
				},
				{
					header : '<fmt:message key="property.department" />',
					dataIndex : 'department',
					sortable : true
				},
				{
					header : '<fmt:message key="property.serviceTime" />',
					dataIndex : 'serviceTime',
					sortable : true
				},
				{
					header : '<fmt:message key="property.disasterRecoverPriority" />',
					dataIndex : 'disasterRecoverPriority',
					sortable : true
				},
				{
					header : '<fmt:message key="property.securityRank" />',
					dataIndex : 'securityRank',
					sortable : true
				},
				{
					header : '<fmt:message key="property.groupName" />',
					dataIndex : 'groupName',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isTakeOver" />',
					dataIndex : 'takeOverFlag',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isCoreSystem" />',
					dataIndex : 'coreRank',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isImportantSystem" />',
					dataIndex : 'importantRank',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isHingeSystem" />',
					dataIndex : 'hingeRank',
					sortable : true
				},
				{
					header : '<fmt:message key="property.isOutSourcing" />',
					dataIndex : 'outSourcingFlag',
					sortable : true
				},
				{
					header : '<fmt:message key="property.appType" />',
					dataIndex : 'appType',
					sortable : true/*,
					renderer : function(value) {
						switch(value){
						case '1' : return  "平稳形"; break;
						case '2' : return  "震荡形";break;
						default : return value;
						}
					}*/
				}/*,
				{
					header : '<fmt:message key="property.appOutline" />',
					dataIndex : 'appOutline',
					sortable : true
				}*/,
				{
					header : '<fmt:message key="property.evaluateMonth" />',
					dataIndex : 'evaluateMonth',
					sortable : true
				},
				{
					header : '<fmt:message key="property.evaluateResult" />',
					dataIndex : 'evaluateResult',
					sortable : true
				},
				{
					header : '<fmt:message key="property.levelCauseDesc" />',
					dataIndex : 'levelCauseDesc',
					sortable : true
				}
	  		],
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : pageSize,
				buttons : [ '-', {
					id : 'AppCapaRiskGradeExport',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				} ]
			})
		});
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'AppCapaRiskGradeFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 105,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 350,
			minSize : 350,
			maxSize : 350,
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
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : sysIdsStore,
					displayField : 'sysName',
					name : 'sysName',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						 'beforequery' : function(e){
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
					fieldLabel : '<fmt:message key="property.sysadminidA" />',
					name:'sysA',
					store : sysAsStore,
					displayField : 'sysA',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.sysadminidB" />',
					name:'sysB',
					store : sysBsStore,
					displayField : 'sysB',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appadminidA" />',
					name:'appA',
					store : appAsStore,
					displayField : 'appA',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appadminidB" />',
					name:'appB',
					store : appBsStore,
					displayField : 'appB',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.systemStatus" />',
					store : sysStatusStore,
					displayField : 'sysStatus',
					hiddenName :'sysStatus',
					editable: false,
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appType" />',
					store : appTypeStore,
					displayField : 'displayField',
					valueField : 'valueField',
					hiddenName :'appType',
					editable: false,
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.disasterRecoverPriority" />',
					store : disasterRecoverStore,
					displayField : 'disasterRecoverPriority',
					hiddenName:'disasterRecoverPriority',
					editable: false,
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.groupName" />',
					name :'groupName',
					store : groupNameStore,
					displayField : 'groupName',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					tabIndex : this.tabIndex++
				}, {
		            xtype: 'checkboxgroup',
		            inputType : 'text',
		            fieldLabel : '<fmt:message key="property.systemAttributes" />',
		            autoHeight: true,
		            items: [{
		            	checked: false,
		            	id :'AppCapaRiskGradeCoreRank',
		                boxLabel: '<fmt:message key="property.core" />',
		                name: 'coreRank',
		                inputValue: '是'
		            } , {
		            	checked: false,
		                boxLabel: '<fmt:message key="property.important" />',
		                id : 'AppCapaRiskGradeCoreRankImportantRank',
		                name: 'importantRank',
		                inputValue: '是'
		            }, {
		            	checked: false,
		                boxLabel: '<fmt:message key="property.hinge" />',
		                id :'AppCapaRiskGradeCoreRankHingeRank',
		                name: 'hingeRank',
		                inputValue: '是'
		            }, {
		            	checked: false,
		                boxLabel: '<fmt:message key="property.outSourcing" />',
		                id : 'AppCapaRiskGradeCoreRankOutSourcingFlag',
		                name: 'outSourcingFlag',
		                inputValue: '是'
		            } ]
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

		// 设置基类属性		AppCapaRiskGradeList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().baseParams.coreRank  = Ext.getCmp('AppCapaRiskGradeCoreRank').getValue() ? '是' : null;
		this.grid.getStore().baseParams.importantRank  = Ext.getCmp('AppCapaRiskGradeCoreRankImportantRank').getValue() ? '是' : null;
		this.grid.getStore().baseParams.hingeRank  = Ext.getCmp('AppCapaRiskGradeCoreRankHingeRank').getValue() ? '是' : null;
		this.grid.getStore().baseParams.outSourcingFlag  = Ext.getCmp('AppCapaRiskGradeCoreRankOutSourcingFlag').getValue() ? '是' : null;
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/appcapariskgrade/excel.xls';
	}
});

Ext.getCmp("MgrAppCapaRiskGradeIndex").add(new AppCapaRiskGradeList());
Ext.getCmp("MgrAppCapaRiskGradeIndex").doLayout();
</script>

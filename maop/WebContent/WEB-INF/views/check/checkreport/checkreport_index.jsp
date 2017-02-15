<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//应用系统
var appsysStore =  new Ext.data.Store({
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
//日报检查项运行状态
var runStatueStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/DAYRPT_RUN_STATUE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

//定义列表
CheckReportList = Ext.extend(Ext.Panel, {
	id : 'CheckReportList',
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel({});
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止		Ext.getDoc().on('keydown',function(e) {
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
		appsysStore.load();
		runStatueStore.load();
		
		
		this.HandStore = new Ext.data.ArrayStore({
		    fields: ['value', 'name'],
		    data : [    ['0', '未分析'],
		            	['1', '已分析'],
		            	['2', '全部']
		            ]
		});
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/checkreport/checkQueryList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'APLCODE',
						'APLNAME', 
						'TRANSDATE',
						'TRANSTIME',
						'TOTAL',
						'UNHANDLE',
						'USUAL',
						'UNUSUAL',
						'UNHANDLESTATE'
					],
			remoteSort : true ,
			baseParams : {
				start : 0,
				limit : 100,
				unhandle_state:0
			}
		});
		// 加载列表数据
		this.gridStore.load();
		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel({
			title : '<fmt:message key="title.list" />',
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), /* csm, */ {
				header : '系统编号',
				dataIndex : 'APLCODE',
				scope : this,
				sortable : false
			},{
				header : '系统名称',
				dataIndex : 'APLNAME',
				sortable : false,
				hidden : false 
			},{
				header : '巡检日期',
				dataIndex : 'TRANSDATE',
				scope : this,
				sortable : false
			},{
				header : '巡检时间',
				dataIndex : 'TRANSTIME',
				scope : this,
				hidden : true ,
				sortable : false
			} ,{
				header : '巡检报告数',
				dataIndex : 'TOTAL',
				scope : this,
				sortable : false
			},{
				header : '未分析报告数', 
				dataIndex : 'UNHANDLE',
				renderer : this.changeMoveStatusValue,
				scope : this,
				sortable : false
			},{
				header : '超阀值报告数', 
				dataIndex : 'UNUSUAL',
				renderer : this.changeMoveStatusValue,
				scope : this,
				sortable : false
			}],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}), 
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doAnalyse
			}
		});
		
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 80,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 250,
			minSize : 200,
			maxSize : 300,
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
					store : appsysStore,
					fieldLabel : '<fmt:message key="job.appsys_code" />',
					name : 'APLCODE' ,
					valueField : 'appsysCode',
					displayField : 'appsysName',
					hiddenName : 'APLCODE',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
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
				},{
					xtype : 'datefield',
					fieldLabel : '巡检日期',
					id:'',
					name : 'TRANSDATE',
					format : 'Ymd',
					editable : false ,
					value : new Date().add(Date.DAY, -1)
				},{
					xtype : 'combo',
					anchor : '100%',
					fieldLabel : '分析状态',
					displayField : 'name',
					valueField : 'value',
					name : 'unhandle_state',
					hiddenName : 'unhandle_state' ,
					value : '0',
					store : this.HandStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {}
       	 		}
			],
			// 定义查询表单按钮
			buttons : [{
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doFind 
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doReset
			}]
		});

		// 设置基类属性		CheckReportList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
		
	},
	 
	//分析
	doAnalyse : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() == 1) {
			var record = grid.getSelectionModel().getSelected();
			var params = {
				aplCode : encodeURIComponent(record.get('APLCODE')),
				aplName : encodeURIComponent(record.get('APLNAME')),
				transDate : encodeURIComponent(record.get('TRANSDATE')),
				transTime : encodeURIComponent(record.get('TRANSTIME'))
			};
			app.loadTab('CHECK_REPORT_ANALYSE', '巡检结果分析', '${ctx}/${appPath}/checkreport/analyse', params);
		} else {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().baseParams.unhandle_state=this.form.getForm().findField('unhandle_state').getValue();
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 未分析报告数大于0时，字体为红色
	changeMoveStatusValue : function(value, metadata, record, rowIndex, colIndex, store) {
		if(value>0){
			return '<span style="color:red;">' + value + '</span>';
		}else{
			return value;
		}
	}
});

var checkReportList = new CheckReportList();
</script>

<sec:authorize access="hasRole('APP_CHECK_ANALYSE')">
<script type="text/javascript">
checkReportList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '分析',
	scope : checkReportList,
	handler : checkReportList.doAnalyse
	},'-');
</script>
</sec:authorize>


<script type="text/javascript">
	Ext.getCmp("CHECK_REPORT_INDEX").add(checkReportList);
	Ext.getCmp("CHECK_REPORT_INDEX").doLayout();
	var handle=function(){
    	checkReportList.gridStore.reload();
		
	};
	Ext.getCmp("CHECK_REPORT_INDEX").on('activate',handle);
	
</script>

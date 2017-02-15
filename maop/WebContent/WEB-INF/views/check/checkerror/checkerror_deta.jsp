<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//var checkerrorstatus='6'; //未解决（1-未处理   2-已完成(已解决) 3-处理中   4-正常   5-异常   6-未解决   7-全部）
var ServerName = decodeURIComponent('${param.ServerName}');
var appsysCode = decodeURIComponent('${param.appsysCode}');
var appsysCode_ip = decodeURIComponent('${param.appsysCode_ip}');
var checkstatus = '';
if('${param.checkstatus}' != ''){
	checkstatus = decodeURIComponent('${param.checkstatus}');
}

var fieldsStatus = Ext.data.Record.create([
	{name: 'value', mapping : 'value', type : 'string'}, 
	{name: 'name', mapping : 'name', type : 'string'}
]);

var appsysStore_errorDetail =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});

var RuleNameStore_errorDetail =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/checkerror/queryRuleName',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['RuleName'])
});

//常规巡检：1  临时巡检：2
var checkTypeStore_errorDetail = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_AUTHORIZE_LEVEL_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

//巡检子项
var subItemDetailStore_errorDetail = new Ext.data.SimpleStore({
	fields :['name', 'value'],
	data : [['OK', 'OK'], ['FALSE', 'FALSE'], ['NONE', 'NONE'], ['NOSCRIPT', 'NOSCRIPT']]
});

//定义列表
JobList = Ext.extend(Ext.Panel, {
	id : 'CheckErrorDetailList',
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		this.checkStatusStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/INCONSISTENT_HANDLE_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ],
			listeners : {
				load : function(store){
					if(store.getCount()>0){
						var allStatus = new Array();
						allStatus.push(new fieldsStatus({value:'7',name:'<fmt:message key="job.all" />'}));
						store.add(allStatus);
					}
				}
			}
		});
		this.checkStatusStore.load();
		appsysStore_errorDetail.load();
		/* appsysStore_errorDetail.on('load',function(store){
			//隐藏系统 主机名称 查询条件
			if(store.getCount()==1){
				Ext.getCmp('check_error_checkType').hide();
				Ext.getCmp('check_error_server').hide();
			}
		}); */
		
		RuleNameStore_errorDetail.load();
		checkTypeStore_errorDetail.load();
		
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel({});
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/checkerror/oneDetail',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'appsysCode',
						'appsysCode_ip',
						'checkType',
						'ServerName',
						'ServerIp',
						'StartDatetime',
						'RuleName',
						'RuleString',
						'ExtendObject',
						'InconsistentHandleStatus',
						'RuleResultString',
						'subItemDetail',
						'isConsistent'
					],
			remoteSort : true,
			sortInfo : {
				field : 'StartDatetime',
				direction : 'DESC'
			},
			baseParams : {
				start : 0,
				limit : 20,
				ServerName:ServerName,
				appsysCode:appsysCode,
				appsysCode_ip:appsysCode_ip,
				queryAppsys:'',
				queryServer:'',
				LastDate : '${param.LastDate}',
				FlucDatetime :'${param.FlucDatetime}',
				checkDate:'${param.checkDate}'
			}
		});
		// 加载列表数据
		this.gridStore.load();
		
		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel({
			title : '<fmt:message key="title.list" />',
			id:'checkerrordetaId',
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : false
			},
			store : this.gridStore,
			sm : csm,
			//autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm,{
				header : '作业关联的应用系统',
				dataIndex : 'appsysCode',
				renderer : this.appsysStore_errorDetailValue,
				hidden : true ,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="job.appsys_code" />',
				dataIndex : 'appsysCode_ip',
				renderer : this.appsysStore_errorDetailValue,
				scope : this,
				sortable : true
			},{
				header : '巡检方式',
				dataIndex : 'checkType',
				renderer : this.checkTypeValue,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.ServerName" />',
				dataIndex : 'ServerName',
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.ServerIp" />',
				width : 90,
				dataIndex : 'ServerIp',
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.StartDatetime" />', 
				width : 120,
				dataIndex : 'StartDatetime',
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.RuleName" />',
				dataIndex : 'RuleName',
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.RuleString" />',
				dataIndex : 'RuleString',
				hidden : true,
				scope : this,
				sortable : true
			},{
				header : '巡检子项',
				width : 180,
				dataIndex : 'subItemDetail',
				scope : this,
				sortable : true,
				renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
				    var title = "巡检子项：";
				    var tip = record.get('subItemDetail');
				    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
				    if(record.get('isConsistent') == 0){
						metadata.css='x-grid-back-red';
				    }
				    return tip;
				}
			},{
				header : '<fmt:message key="property.InconsistentHandleStatus" />',
				dataIndex : 'InconsistentHandleStatus',
				renderer : this.checkStatusStoreValue,
				scope : this,
				sortable : true/* ,
				renderer : function(value, metadata, record, rowIndex, colIndex, store){
					if(value == 0){
						metadata.css='x-grid-back-red';
						return value;
					}else {
						return value;
					}
				} */
			}],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true
				
			})/* ,
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				rowdblclick : this.doView
			} */
		});
		
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'JobdesignTest',
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
			items : [/* {
				xtype : 'combo',
				store : appsysStore_errorDetail,
				fieldLabel : '<fmt:message key="job.appsys_code" />',
				name : 'appsysCode' ,
				id : 'check_error_appsysCode',
				valueField : 'appsysCode',
				displayField : 'appsysName',
				hiddenName : 'appsysCode',
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
			}, */{
				xtype : 'combo',
				store : checkTypeStore_errorDetail,
				fieldLabel : '巡检方式',
				id : 'check_error_checkType',
				valueField : 'value',
				displayField : 'name',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++
			},{
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="property.ServerName" />',
				id:'check_error_server',
				name : 'ServerName',
				maxLength : 30 ,
				tabIndex : this.tabIndex++
			},{
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="property.ServerIp" />',
				name : 'ServerIp',
				maxLength : 30 ,
				tabIndex : this.tabIndex++
			},{
			 	xtype : 'combo',
				fieldLabel : '<fmt:message key="property.InconsistentHandleStatus" />',
				store : this.checkStatusStore,
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'InconsistentHandleStatus',
				id : 'checkstatusId_detail',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++
			},{
				xtype : 'combo',
				store : subItemDetailStore_errorDetail,
				fieldLabel : '巡检子项',
				id : 'check_error_subItemDetail',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'subItemDetail',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++
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
		// 设置基类属性		JobList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	appsysStore_errorDetailValue : function(value) {
		var index = appsysStore_errorDetail.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return appsysStore_errorDetail.getAt(index).get('appsysName');
		}
	},
	checkStatusStoreValue : function(value,metadata) {
		var index = this.checkStatusStore.find('value', value);
		if (index == -1) {
			return value;
		} else if (value == 1){
			metadata.css='x-grid-back-red';
			return this.checkStatusStore.getAt(index).get('name');
		}else if (value == 2){
			metadata.css='x-grid-back-lightgreen';
			return this.checkStatusStore.getAt(index).get('name');
		}else if (value == 3){
			metadata.css='x-grid-back-yellow';
			return this.checkStatusStore.getAt(index).get('name');
		}else {
			return this.checkStatusStore.getAt(index).get('name');
		}
	},
	checkTypeValue : function(value) {
		var index = checkTypeStore_errorDetail.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return checkTypeStore_errorDetail.getAt(index).get('name');
		}
	},
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		//var app = Ext.getCmp('check_error_appsysCode').getValue() ;
		var checkType = Ext.getCmp('check_error_checkType').getValue() ;
		var server = Ext.getCmp('check_error_server').getValue() ;
		//this.gridStore.baseParams.queryAppsys=decodeURIComponent(app);
		this.gridStore.baseParams.queryCheckType=decodeURIComponent(checkType);
		this.gridStore.baseParams.queryServer=decodeURIComponent(server);
		this.gridStore.baseParams.appsysCode=appsysCode;
		this.gridStore.baseParams.ServerName=ServerName;
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 查看事件
	/* doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
				ServerName : record.get('ServerName'),
				InconsistentHandleStatus : record.get('InconsistentHandleStatus'),
				StartDatetime : record.get('StartDatetime'),
				RuleName:encodeURIComponent(record.get('RuleName'))
		};
		if(record.get('InconsistentHandleStatus')!='4'){
			//app.loadWindow('${ctx}/${appPath}/checkerror/edithand',params);
			app.loadTab('CHECK_ERROR_HANDLE', '錯誤解决', '${ctx}/${appPath}/checkerror/edithand', params);
		}
	}, */
	
	// 错误处理
	doHandle : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() > 1) { //批量处理
			var records = grid.getSelectionModel().getSelections();
			var ServerNames = [];//主机名称
			var AppsysCodes = [];//系统名称(作业关联的应用系统)
			var AppsysCodes_ip = [];//系统名称(IP关联的应用系统)
			var StartDatetimes = []; //检查时间
			var InconsistentHandleStatus = [];
			var RuleNames = [];  //检查项
			var logNames = [];  
			for ( var i = 0; i < records.length; i++) {
				ServerNames.push(records[i].get('ServerName'));
				AppsysCodes.push(records[i].get('appsysCode'));
				AppsysCodes_ip.push(records[i].get('appsysCode_ip'));
				StartDatetimes.push((records[i].get('StartDatetime')).replace('-','').replace('-',''));
				InconsistentHandleStatus.push(records[i].get('InconsistentHandleStatus'));
				RuleNames.push(records[i].get('RuleName'));
				logNames.push(records[i].get('RuleName')+'|+|'+records[i].get('subItemDetail'));
			};
			var params = {
					ServerName : encodeURIComponent(ServerNames),
					AppsysCode : encodeURIComponent(AppsysCodes),
					AppsysCode_ip : encodeURIComponent(AppsysCodes_ip),
					StartDatetime : encodeURIComponent(StartDatetimes),
					RuleName : encodeURIComponent(RuleNames),
					appsysCode : '${param.appsysCode}',
					appsysCodeIP : '${param.appsysCode_ip}',
					serverName : '${param.ServerName}',
					LastDate : '${param.LastDate}',
					FlucDatetime :'${param.FlucDatetime}',
					checkDate :'${param.checkDate}',
					checkstatus : '${param.checkstatus}',
					logName : encodeURIComponent(logNames)
			}; 
			var flag=false;
			for(var j=0;j<InconsistentHandleStatus.length;j++){
				if(InconsistentHandleStatus[j]=='2' || InconsistentHandleStatus[j]=='4'){
					flag=true;
				}
			}
			if(flag){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.not.select.has" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}else{
				  //app.loadWindow('${ctx}/${appPath}/checkerror/entr',params);
				app.loadTab('CHECK_ERROR_BATCH_HANDLE', '<fmt:message key="job.error_handle_batch" />', '${ctx}/${appPath}/checkerror/entr', params);
			}	
		}else if(grid.getSelectionModel().getCount()==1){ //单个处理
			var record = grid.getSelectionModel().getSelected();
			var params = {
				ServerName : encodeURIComponent(record.get('ServerName')),
				StartDatetime : (record.get('StartDatetime')).replace('-','').replace('-',''),
				RuleName:encodeURIComponent(record.get('RuleName')),
				appsysCode_ip : encodeURIComponent(record.get('appsysCode_ip')),
				serverName : '${param.ServerName}',
				appsysCode : '${param.appsysCode}',
				appsysCodeIP : '${param.appsysCode_ip}',
				LastDate : '${param.LastDate}',
				FlucDatetime :'${param.FlucDatetime}',
				checkDate :'${param.checkDate}',
				checkstatus : '${param.checkstatus}',
				ruleResultString : record.get('subItemDetail')
			};
			if(record.get('InconsistentHandleStatus')!='2' && record.get('InconsistentHandleStatus')!='4'  ){
				//app.loadWindow('${ctx}/${appPath}/checkerror/edithand',params);
				app.loadTab('CHECK_ERROR_HANDLE', '<fmt:message key="job.error_handle_single" />', '${ctx}/${appPath}/checkerror/edithand', params);
			}else{
				var params2 = {
					ServerName : encodeURIComponent(record.get('ServerName')),
					InconsistentHandleStatus : record.get('InconsistentHandleStatus'),
					StartDatetime : (record.get('StartDatetime')).replace('-','').replace('-',''),
					RuleName:encodeURIComponent(record.get('RuleName')),
					appsysCode_ip : encodeURIComponent(record.get('appsysCode_ip')),
					serverName : '${param.ServerName}',
					appsysCode : '${param.appsysCode}',
					appsysCodeIP : '${param.appsysCode_ip}',
					LastDate : '${param.LastDate}',
					FlucDatetime :'${param.FlucDatetime}',
					checkDate :'${param.checkDate}',
					checkstatus : '${param.checkstatus}',
					ruleResultString : record.get('subItemDetail')
				};
				if(record.get('InconsistentHandleStatus')!='4'){
					app.loadTab('CHECK_ERROR_HANDLE', '<fmt:message key="job.error_handle_single" />', '${ctx}/${appPath}/checkerror/edithand', params2);
				}else{
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="job.normalNoHandle" />', 
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
				}
			} 
		}else if(grid.getSelectionModel().getCount()==0){
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	}
});
var jobList = new JobList();


</script>

<sec:authorize access="hasRole('CHECK_ERROR_HANDLE')">
<script type="text/javascript">
jobList.grid.getTopToolbar().add({
	iconCls : 'button-ok',
	text : '<fmt:message key="job.error_handle" />',
	scope : jobList,
	handler : jobList.doHandle
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
	Ext.getCmp("CHECK_ERROR_DETA").add(jobList);
	Ext.getCmp("CHECK_ERROR_DETA").doLayout();
	Ext.getCmp("CHECK_ERROR_DETA").on('close',function(){
		Ext.getCmp("checkErrorList").gridStore.reload();
	});
</script>

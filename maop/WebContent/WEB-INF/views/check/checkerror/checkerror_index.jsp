<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var checkerrorstatus='5';
var checkDate = new Date().format('Y-m-d') ;
var StartDatetime;
var FlucDatetime;
var resetStartTime;
var resetFlucTime;

var fieldsTime = Ext.data.Record.create([
	{name: 'StartDatetime', mapping : 'StartDatetime', type : 'string'}, 
	{name: 'FlucDatetime', mapping : 'FlucDatetime', type : 'string'}
]);
var fieldsStatus = Ext.data.Record.create([
	{name: 'value', mapping : 'value', type : 'string'}, 
	{name: 'name', mapping : 'name', type : 'string'}
]);

//常规巡检：1  临时巡检：2
var checkTypeStore_errorIndex = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_AUTHORIZE_LEVEL_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
                                       
var appsysStore_errorIndex =  new Ext.data.Store({
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
var dateStore_errorIndex_errorIndex =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/checkerror/queryCheckDate',
		method : 'POST',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['StartDatetime','FlucDatetime']),
	listeners : {
		load : function(store){
			if(store.getCount()>0){
				var lastTime = store.data.items[0].data.StartDatetime;
				var lastFlucTime = store.data.items[0].data.FlucDatetime;
				if(checkDate == new Date().format('Y-m-d')){
					resetStartTime = lastTime;
					resetFlucTime = lastFlucTime;
				}
				Ext.getCmp('StartDateid').setValue(lastTime);
				Ext.getCmp('FlucDateid').setValue(lastFlucTime);
				StartDatetime = lastTime;
				FlucDatetime = lastFlucTime;
				var allTimes = new Array();
				allTimes.push(new fieldsTime({StartDatetime:'<fmt:message key="job.all" />',FlucDatetime:'all'}));
				store.add(allTimes);
			}else{
				Ext.getCmp('StartDateid').setValue('');
				Ext.getCmp('FlucDateid').setValue('');
			}
		}
	}
});
var dateStore_errorIndex_errorIndexValue = function(value) {
	var index = dateStore_errorIndex_errorIndex.find('StartDatetime', value);
	if (index == -1) {
		return value;
	} else {
		return dateStore_errorIndex_errorIndex.getAt(index).get('FlucDatetime');
	}
};

var hostcheckstatusStore_errorIndex = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ],
	listeners : {
		load : function(store){
			if(store.getCount()>0){
				var allStatus = new Array();
				allStatus.push(new fieldsStatus({value:'',name:'<fmt:message key="job.all" />'}));
				store.add(allStatus);
			}
		}
	}
});

//定义列表
CheckErrorList = Ext.extend(Ext.Panel, {
	id : 'checkErrorList',
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		//实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel({});
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
		appsysStore_errorIndex.load();
		hostcheckstatusStore_errorIndex.load();
		dateStore_errorIndex_errorIndex.load();
		checkTypeStore_errorIndex.load();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/checkerror/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'appsysCode',
						'checkType',
						'appsysCode_ip',
						'ServerName', 
						'ServerIp',
						'InconsistentHandleStatus',
						'normal',
						'error',
						'total',
						'StartDatetime',
						'jobStartTime',
						'checkstatus'
					],
			remoteSort : true ,
			sortInfo : {
				field : 'ServerIp',
				direction : 'DESC'
			}, 
			baseParams : {
				start : 0,
				limit : 20
			},
			listeners : {
				'load' : function(store, records, opt){
					 Ext.getCmp('checkstatusId').setValue(checkerrorstatus);
				}
			}
		});
		// 加载列表数据
		this.gridStore.on('beforeload',function(store){
			 this.gridStore.baseParams.checkstatus=checkerrorstatus;
			 this.gridStore.baseParams.checkDate=checkDate;
			 this.gridStore.baseParams.StartDatetime=StartDatetime;
			 this.gridStore.baseParams.FlucDatetime=FlucDatetime;
		},this); 
		this.gridStore.load();
		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel({
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
			columns : [ new Ext.grid.RowNumberer(), csm, {
				header : '作业所属应用系统',
				dataIndex : 'appsysCode',
				renderer : this.appsysStore_errorIndexValue,
				hidden : true ,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="job.appsys_code" />',
				dataIndex : 'appsysCode_ip',
				renderer : this.appsysStore_errorIndexValue,
				scope : this,
				sortable : true
			},{
				header : '巡检方式',
				dataIndex : 'checkType',
				renderer : this.checkType_errorIndex_errorIndexValue,
				width : 70 ,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.ServerName" />',
				dataIndex : 'ServerName',
				sortable : true,
				hidden : false 
			},{
				header : '<fmt:message key="property.ServerIp" />',
				dataIndex : 'ServerIp',
				width : 90 ,
				scope : this,
				sortable : true
			} ,{
				header : '<fmt:message key="property.total" />',
				dataIndex : 'total',
				width : 65 ,
				scope : this,
				sortable : false
			},{
				header : '<fmt:message key="property.normal" />',
				dataIndex : 'normal',
				width : 65 ,
				scope : this,
				sortable : false
			},{
				header : '<fmt:message key="property.error" />',
				dataIndex : 'error',
				width : 65 ,
				scope : this,
				sortable : false,
				renderer : function(value, metadata, record, rowIndex, colIndex, store){
					if(value > 0){
						metadata.css='x-grid-back-red';
						return value;
					}else {
						return value;
					}
				}
			},{
				header : '<fmt:message key="property.StartDatetime" />', 
				dataIndex : 'StartDatetime',
				width : 70 ,
				scope : this,
				sortable : true,
				hidden : true
			},{
				header : '作业开始时间', 
				dataIndex : 'jobStartTime',
				width : 70 ,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="property.checkstatus" />',
				dataIndex : 'checkstatus',
				renderer : this.hostcheckstutas_errorIndexValue,
				width : 65 ,
				scope : this,
				sortable : false
			}],
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true
			})
		});
		
		// 实例化查询表单
		this.form = new Ext.FormPanel( {
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
					store : appsysStore_errorIndex,
					fieldLabel : '<fmt:message key="job.appsys_code" />',
					name : 'appsysCode' ,
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
					store : checkTypeStore_errorIndex,
					fieldLabel : '巡检方式',
					valueField : 'value',
					displayField : 'name',
					name : 'checkType',
					hiddenName : 'checkType',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ServerName" />',
					name : 'ServerName',
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.ServerIp" />',
					name : 'ServerIp',
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="job.check_date" />',
					id:'checkDateId',
					name : 'checkDate',
					format : 'Y-m-d',
					value : new Date().format('Y-m-d'),
					listeners : {
						//编辑完成后处理事件
						select : function(obj) {
							 checkDate = obj.value;
							 dateStore_errorIndex_errorIndex.baseParams.checkDate=obj.value.replace('-','').replace('-','');
							 dateStore_errorIndex_errorIndex.reload();
						}
					}
				},{
					xtype : 'combo',
					id:'StartDateid',
					store : dateStore_errorIndex_errorIndex,
					fieldLabel : '<fmt:message key="job.check_time" />',
					valueField : 'StartDatetime',
					displayField : 'StartDatetime',
					hiddenName :'StartDatetime',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++,
                    listeners : {
						//编辑完成后处理事件
						select : function(obj) {
							var t = dateStore_errorIndex_errorIndexValue(obj.value);
							Ext.getCmp('FlucDateid').setValue(t);
							StartDatetime = obj.value;
							FlucDatetime = t;
						}
					}
				},{
					xtype : 'textfield',
					id:'FlucDateid',
					name : 'FlucDatetime',
					hidden:true,
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					store : hostcheckstatusStore_errorIndex,
					id:'checkstatusId',
					fieldLabel : '<fmt:message key="property.checkstatus" />',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'checkstatus',
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

		// 设置基类属性
		CheckErrorList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
		
	},
	 
	appsysStore_errorIndexValue : function(value) {
		var index = appsysStore_errorIndex.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return appsysStore_errorIndex.getAt(index).get('appsysName');
		}
	},
	hostcheckstutas_errorIndexValue : function(value,metadata) {
		var index = hostcheckstatusStore_errorIndex.find('value', value);
		if (index == -1) {
			return value;
		}else if (value == 1){
			metadata.css='x-grid-back-red';
			return hostcheckstatusStore_errorIndex.getAt(index).get('name');
		}else if (value == 2){
			metadata.css='x-grid-back-lightgreen';
			return hostcheckstatusStore_errorIndex.getAt(index).get('name');
		}else if (value == 3){
			metadata.css='x-grid-back-yellow';
			return hostcheckstatusStore_errorIndex.getAt(index).get('name');
		}else {
			return hostcheckstatusStore_errorIndex.getAt(index).get('name');
		}
	},
	checkType_errorIndex_errorIndexValue : function(value) {
		var index = checkTypeStore_errorIndex.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return checkTypeStore_errorIndex.getAt(index).get('name');
		}
	},
	
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		checkerrorstatus=Ext.getCmp('checkstatusId').getValue();
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
		Ext.getCmp('checkstatusId').setValue('5');
		Ext.getCmp('checkDateId').setValue(new Date().format('Y-m-d'));
		Ext.getCmp('StartDateid').setValue(resetStartTime);
		Ext.getCmp('FlucDateid').setValue(resetFlucTime);
		checkDate = new Date().format('Y-m-d') ;
		StartDatetime = resetStartTime ;
		FlucDatetime = resetFlucTime ;
	},
	// 明细
	doDeta : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() > 0) {
			var records = grid.getSelectionModel().getSelections();
			var ServerNames = [];
			var appsysCodes = [];
			var appsysCodes_ip = [];
			var FlucDatetime = Ext.getCmp('FlucDateid').getValue();
			var LastDate = Ext.getCmp('StartDateid').getValue();
			var checkDate=Ext.util.Format.date(Ext.getCmp('checkDateId').getValue(),'Y-m-d');
			var checkState = Ext.getCmp('checkstatusId').getValue();
			for ( var i = 0; i < records.length; i++) {
				ServerNames.push(records[i].get('ServerName'));
				appsysCodes.push(records[i].get('appsysCode'));
				appsysCodes_ip.push(records[i].get('appsysCode_ip'));
			};
			var params = {
					ServerName : encodeURIComponent(ServerNames),
					appsysCode : encodeURIComponent(appsysCodes),
					appsysCode_ip : encodeURIComponent(appsysCodes_ip),
					LastDate : encodeURIComponent(LastDate),
					FlucDatetime :encodeURIComponent(FlucDatetime),
					checkDate :encodeURIComponent(checkDate),
					checkstatus : encodeURIComponent(checkState)
			}; 
			app.loadTab('CHECK_ERROR_DETA', '<fmt:message key="job.error" /><fmt:message key="property.detailed" />', '${ctx}/${appPath}/checkerror/oneDetail', params);
		}else if(grid.getSelectionModel().getCount() == 0){
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 执行结果同步事件
	doSynchronize : function() {
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.confirm.to.syn" />',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(buttonId) {
				if (buttonId == 'ok') {
					app.mask.show();
					Ext.Ajax.request({
						scope : this,
						url : '${ctx}/${appPath}/checkerror/synCheckResultInfo',
						method:'POST',
						timeout : 7200000,  //600000即10分钟
						success : this.synSuccess,
						failure : this.synFailure
					});
				}
			}
		});
	},
	// 同步成功回调
	synSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.failed" />! <fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			var info = Ext.decode(response.responseText).info;
			var nums = info.split("#");
			var success = nums[0];
			var fail = nums[1];
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '同步完成!'+'<br>'
					+'同步成功: '+success+'&nbsp;<fmt:message key="job.data.unit" />'+'<br>'
					+'同步失败: '+fail+'&nbsp;<fmt:message key="job.data.unit" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
			this.grid.getStore().reload();
		}
	},
	// 同步失败回调
	synFailure : function() {
		app.mask.hide();
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.sys.failed" />!',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

var checkErrorList = new CheckErrorList();
</script>

<sec:authorize access="hasRole('CHECK_ERROR_HANDLE')">
<script type="text/javascript">
checkErrorList.grid.getTopToolbar().add({
	iconCls : 'button-refresh',
	text : '<fmt:message key="job.synCheckResult" />',
	scope : checkErrorList,
	handler : checkErrorList.doSynchronize
	},'-');
checkErrorList.grid.getTopToolbar().add({
	iconCls : 'button-viewBatchRel',
	text : '<fmt:message key="property.detailed" />',
	scope : checkErrorList,
	handler : checkErrorList.doDeta
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
	Ext.getCmp("CHECK_ERROR_INDEX").add(checkErrorList);
	Ext.getCmp("CHECK_ERROR_INDEX").doLayout();
</script>

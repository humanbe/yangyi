<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
Ext.apply(Ext.form.VTypes, {
    daterange : function(val, field) {
        var date = field.parseDate(val);

        if(!date){
            return false;
        }
        if (field.startDateField) {
            var start = Ext.getCmp(field.startDateField);
            if (!start.maxValue || (date.getTime() != start.maxValue.getTime())) {
                start.setMaxValue(date);
                start.validate();
            }
        }
        else if (field.endDateField) {
            var end = Ext.getCmp(field.endDateField);
            if (!end.minValue || (date.getTime() != end.minValue.getTime())) {
                end.setMinValue(date);
                end.validate();
            }
        }
        
        return true;
    }
});

var requestFunStore2 = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/REQUEST_FUN/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var turnSwitchStore2 = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/TURN_SWITCH/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var execStatusStore2 = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/EXEC_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

this.envRequestAuthorizeStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/dplyrequestinfo/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
this.envRequestAuthorizeStroe.load(); 

var sysIdsStore2 = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
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

	//定义功能列表
	DplyRequestAuthorizeList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源		grid : null,// 数据列表组件
		form : null,// 查询表单组件
		tabIndex : 0,// 查询表单组件Tab键顺序		csm : null,// 数据列表选择框组件
		constructor : function(cfg) {// 构造方法			Ext.apply(this, cfg);
			turnSwitchStore2.load();
			execStatusStore2.load();
			sysIdsStore2.load();
			requestFunStore2.load();
			// 实例化数据列表选择框组件			csm = new Ext.grid.CheckboxSelectionModel();

			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${managePath}/dplyrequestinfo/authorize_index',
					disableCaching : true
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'appSysCode', 'requestCode', 'planDeployDate', 'deployCode', 'environment',
				           'requestName', 'trunSwitch', 'execStatus', 'planStartTime', 
				           'planEndTime', 'realStartDate', 'realEndDate','requestStatus' ],
				remoteSort : true,
				sortInfo : {
					field : 'trunSwitch',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100
				},
				listeners : {
					'load' : function(store, records, opt){
						if(store.getCount() > 0){
							Ext.getCmp('request_index_excel2').enable();
						}else{
							Ext.getCmp('request_index_excel2').disable();
						}
					}
				}
			});
			// 加载数据源的数据
			this.gridStore.load();
			
			// 实例化数据列表组件			this.grid = new Ext.grid.GridPanel({
				region : 'center',
				border : false,
				loadMask : true,
				title : '<fmt:message key="title.list" />',
				store : this.gridStore,
				sm : csm,
				columns : [ new Ext.grid.RowNumberer(), csm, {
					header : '<fmt:message key="dplyRequestInfo.appSysCd" />',
					dataIndex : 'appSysCode',
					width : 140,
					sortable : true,
					renderer : this.reqAppsys_Store
				}, {
					header : '<fmt:message key="dplyRequestInfo.deployCode" />',
					dataIndex : 'deployCode',
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.requestFun" />',
					dataIndex : 'requestStatus',
					sortable : true,
					align : 'center',
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value == 'REQ'){
							return '发布请求';
						}
						if(value == 'REQRST'){
							return '回退请求';
						}
					}
				},{
					header : '<fmt:message key="dplyRequestInfo.requestCode" />',
					dataIndex : 'requestCode',
					width : 160,
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.requestName" />',
					dataIndex : 'requestName',
					width : 160,
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.environment" />', 
					dataIndex : 'environment',
					renderer:this.RequestEnvironmentStoreone, 
					sortable : true, width : 200
				}, {
					header : '<fmt:message key="dplyRequestInfo.trunSwitch" />',
					dataIndex : 'trunSwitch',
					sortable : true,
					align : 'center',
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value == '1'){
							return '<img src="${ctx}/static/style/images/button/confirm.png"></img>';
						}else{
							return '<img src="${ctx}/static/style/images/button/delete.png"></img>';
						}
					}
				}, {
					header : '<fmt:message key="dplyRequestInfo.execStatus" />',
					dataIndex : 'execStatus',
					sortable : true,
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						var name = '';
						execStatusStore2.each(function(item){
							if(value == item.data.value){
								name = item.data.name;
								return false;
							}
						});
						return name;
					}
				}, {
					header : '<fmt:message key="dplyRequestInfo.planDeployDate" />',
					dataIndex : 'planDeployDate',
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.planStartTime" />',
					dataIndex : 'planStartTime',
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.planEndTime" />',
					dataIndex : 'planEndTime',
					sortable : true
				}, {
					header : '<fmt:message key="dplyRequestInfo.realStartTime" />',
					dataIndex : 'realStartDate',
					width : 160,
					sortable : true,
					renderer : function(value){
						var jsonDateValue;
						if(Ext.isEmpty(value)){
							return '';
						}else if(Ext.isEmpty(value.time)){
							jsonDateValue = new Date(value);
						}else{
							jsonDateValue = new Date(value.time);
						}
						return jsonDateValue.format('Y-m-d H:i:s');
					}
				}, {
					header : '<fmt:message key="dplyRequestInfo.realEndTime" />',
					dataIndex : 'realEndDate',
					width : 160,
					sortable : true,
					renderer : function(value){
						var jsonDateValue;
						if(Ext.isEmpty(value)){
							return '';
						}else if(Ext.isEmpty(value.time)){
							jsonDateValue = new Date(value);
						}else{
							jsonDateValue = new Date(value.time);
						}
						return jsonDateValue.format('Y-m-d H:i:s');
					}
				} ],
				// 定义按钮工具条				tbar : new Ext.Toolbar({
					items : []
				}),
				// 定义分页工具条				bbar : new Ext.PagingToolbar({
					store : this.gridStore,
					displayInfo : true,
					pageSize : 100,
					buttons : [ '-', {
						iconCls : 'button-excel',
						id : 'request_index_excel2',
						tooltip : '<fmt:message key="button.excel" />',
						scope : this,
						disabled : true,
						handler : function() {
							window.location = '${ctx}/${managePath}/dplyrequestinfo/excelAuthorize.xls';
						}
					} ]
				})
			});

			// 实例化查询表单			this.form = new Ext.FormPanel({
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
					fieldLabel:'<fmt:message key="dplyRequestInfo.appSysCd" />',
					store : sysIdsStore2,
					name : 'appSysCode',
					id:'RequestAuthorizeApp',
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'appSysCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select :function(){
							envRequestAuthorizeStroe.reload();
						},
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
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.environment" />',
					store : envRequestAuthorizeStroe,
					name : 'environment',
					//id:'envid',
					hiddenName : 'environment',
					displayField : 'envName',
					valueField : 'env',
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true,
					allowBlank : true,
					emptyText : '请选择环境...',
					//anchor : '50%',
					listeners : {
						select : function(combo, record, index){
							var envid = combo.value;
							var appsyscd = envid.substring(0, envid.indexOf('_'));
							Ext.getCmp("RequestAuthorizeApp").setValue(appsyscd);
						},
						expand:function(combo){
							var appsyscdValue = Ext.getCmp('RequestAuthorizeApp').getValue();
							if(appsyscdValue != ''){
								envRequestAuthorizeStroe.filter('env', appsyscdValue + '_', false, true);
							}
						}
					}
	            }, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="dplyRequestInfo.deployCode" />',
					name : 'deployCode',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="dplyRequestInfo.planDeployDate" />',
					name : 'planDeployDate',
					format : 'Ymd',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="dplyRequestInfo.deployMonth" />',
					plugins :'monthPickerPlugin', 
					name : 'deployMonth',
					format : 'Ym',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.requestFun" />',
					hiddenName : 'requestStatus',
					displayField : 'name',
					valueField : 'value',
					typeAhead : true,
					forceSelection  : true,
					store : requestFunStore2,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : false,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.execStatus" />',
					hiddenName : 'execStatus',
					displayField : 'name',
					valueField : 'value',
					typeAhead : true,
					forceSelection  : true,
					store : execStatusStore2,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : false,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.authorizeStatus" />',
					hiddenName : 'trunSwitch',
					displayField : 'name',
					valueField : 'value',
					typeAhead : true,
					forceSelection  : true,
					store : turnSwitchStore2,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : false,
					tabIndex : this.tabIndex++
				} 
				],
				// 定义查询表单按钮
				buttons : [ {
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
				} ]
			});
			
			// 设置基类属性			DplyRequestAuthorizeList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ this.form, this.grid ]
			});
		},
		doFind : function() {
			Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
			this.grid.getStore().load();
		},
		doReset : function() {
			this.form.getForm().reset();
		},
		
		
		// 启动事件
		doAuthorize : function() {
			if(this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				
				for ( var i = 0; i < records.length; i++) {
					if(records[i].get('planDeployDate') == null 
							|| records[i].get('planStartTime') == null 
							|| records[i].get('planEndTime') == null){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.authorize.failed.without.schedule" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return;
					}
					
					if(records[i].get('trunSwitch') == 1){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.re-authorize.forbidden" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return;
					}
				}
				
				var appSysCodes = new Array();
				var requestCodes = new Array();
				var environment = new Array();

				for ( var i = 0; i < records.length; i++) {
					appSysCodes[i] = records[i].get('appSysCode');
					requestCodes[i] = records[i].get('requestCode');
					environment[i] = records[i].get('environment');

				}
				
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.authorize" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${managePath}/dplyrequestinfo/updateSwitchOn',
								scope : this,
								method : 'POST',
								success : this.switchOnSuccess,
								failure : this.switchOnFailure,
								params : {
									appSysCodes : appSysCodes,
									requestCodes : requestCodes,
									environment : environment
								}
							});

						}
					}
				});
			}else{
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.select.one.at.least" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
			
		},

		
		
		
		switchOnSuccess : function(response, options){
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.switch.on.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				this.grid.getStore().reload();// 重新加载数据源
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.switch.on.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		switchOnFailure : function(){
			app.mask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.switch.on.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
	

		doNotAuthorize : function() {
			if(this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				
				
				var appSysCodes = new Array();
				var requestCodes = new Array();
				var environment = new Array();

				for ( var i = 0; i < records.length; i++) {
					appSysCodes[i] = records[i].get('appSysCode');
					requestCodes[i] = records[i].get('requestCode');
					environment[i] = records[i].get('environment');

				}
				
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.confirm.to.cancel.authorize" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${managePath}/dplyrequestinfo/updateSwitchOff',
								scope : this,
								method : 'POST',
								success : this.switchOffSuccess,
								failure : this.switchOffFailure,
								params : {
									appSysCodes : appSysCodes,
									requestCodes : requestCodes,
									environment : environment
								}
							});

						}
					}
				});
			}else{
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.select.one.at.least" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
			
		},
		switchOffSuccess : function(response, options){
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.switch.off.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				this.grid.getStore().reload();// 重新加载数据源

				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.switch.off.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		switchOffFailure : function(){
			app.mask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.switch.off.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		
		
		reqAppsys_Store : function(value) {

			var index = sysIdsStore2.find('appsysCode', value);
			if (index == -1) {
				return value;
			} else {
				return sysIdsStore2.getAt(index).get('appsysName');
			}
		},
		
		
		RequestEnvironmentStoreone : function(value) {
			if(value==''){
				return value;
			}
			var elist = value.split('_');
			var env = elist[1];
			if(env=='DEV'){
				return '开发('+value+')';
			}else if(env=='QA'){
				return '测试('+value+')';
			}else if(env=='PROV'){
				return '验证('+value+')';
			}else if(env=='PROD'){
				return '生产('+value+')';
			}else {
				return value;
			}
		}
	});
	
	

	
	var runner = new Ext.util.TaskRunner();
	var DplyRequestAuthorizeList = new DplyRequestAuthorizeList();
	var synReqStatusTask = {
			run : function(){
				DplyRequestAuthorizeList.gridStore.reload();				
			},
			interval : 300000
	};
	runner.start(synReqStatusTask);
	
</script>

<sec:authorize access="hasRole('DPLY_REQUEST_AUTHORIZE')">
 <script type="text/javascript">
 DplyRequestAuthorizeList.grid.getTopToolbar().add( {
	iconCls : 'button-confirm',
	text : '<fmt:message key="button.authorize" />',
	scope : DplyRequestAuthorizeList,
	handler : DplyRequestAuthorizeList.doAuthorize
   },'-');
</script> 
</sec:authorize>
<sec:authorize access="hasRole('DPLY_REQUEST_AUTHORIZE_CANCEL')">
 <script type="text/javascript">
 DplyRequestAuthorizeList.grid.getTopToolbar().add( {
	iconCls : 'button-confirm',
	text : '<fmt:message key="button.authorize.cancel" />',
	scope : DplyRequestAuthorizeList,
	handler : DplyRequestAuthorizeList.doNotAuthorize
   },'-');
</script> 
</sec:authorize>


<script type="text/javascript">
	Ext.getCmp("DplyRequestAuthorizeIndex").add(DplyRequestAuthorizeList);
	Ext.getCmp("DplyRequestAuthorizeIndex").doLayout();
	Ext.getCmp("DplyRequestAuthorizeIndex").on('destroy', function(){
		runner.stop(synReqStatusTask);	
	});
</script>
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

var turnSwitchStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/TURN_SWITCH/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var execStatusStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/EXEC_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var requestFunStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/REQUEST_FUN/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var sysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
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
this.envRequestStartStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/dplyrequestinfo/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
this.envRequestStartStroe.load(); 
	//定义功能列表
	DplyRequestInfoList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源		grid : null,// 数据列表组件
		form : null,// 查询表单组件
		tabIndex : 0,// 查询表单组件Tab键顺序		csm : null,// 数据列表选择框组件
		constructor : function(cfg) {// 构造方法			Ext.apply(this, cfg);
			turnSwitchStore.load();
			execStatusStore.load();
			sysIdsStore.load();
			requestFunStore.load();
			// 实例化数据列表选择框组件			csm = new Ext.grid.CheckboxSelectionModel();

			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${managePath}/dplyrequestinfo/index',
					disableCaching : true
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'appSysCode', 'requestCode','environment', 'planDeployDate', 'deployCode', 
				           'requestName', 'trunSwitch', 'execStatus', 'planStartTime', 
				           'planEndTime', 'realStartDate', 'realEndDate','requestStatus','autostart' ],
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
							Ext.getCmp('request_index_excel').enable();
						}else{
							Ext.getCmp('request_index_excel').disable();
						}
					}
				}
			});
			// 加载数据源的数据
			//this.gridStore.load();

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
				}, {
					header : '<fmt:message key="dplyRequestInfo.environment" />', 
					dataIndex : 'environment',
					renderer:this.RequestEnvironmentStoreone, 
					sortable : true, width : 200
				}, {
					header : '<fmt:message key="dplyRequestInfo.requestName" />',
					dataIndex : 'requestName',
					width : 160,
					sortable : true
				},{
					header : '<fmt:message key="dplyRequestInfo.requestCode" />',
					dataIndex : 'requestCode',
					width : 160,
					sortable : true
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
						execStatusStore.each(function(item){
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
					header : '<fmt:message key="dplyRequestInfo.autostart" />',
					dataIndex : 'autostart',
					sortable : true,
					align : 'center',
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value == '1'){
							return '是';
						}
						if(value == '0'){
							return '否';
						}
					}
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
					items : [/* {
						iconCls : 'button-sync',
						text : '<fmt:message key="button.synrequest" />',
						scope : this,
						handler : this.doSynRequests
					}, '-' */]
				}),
				// 定义分页工具条				bbar : new Ext.PagingToolbar({
					store : this.gridStore,
					displayInfo : true,
					pageSize : 100,
					buttons : [ '-', {
						iconCls : 'button-excel',
						id : 'request_index_excel',
						tooltip : '<fmt:message key="button.excel" />',
						scope : this,
						disabled : true,
						handler : function() {
							window.location = '${ctx}/${managePath}/dplyrequestinfo/excelOn.xls';
						}
					} ]
				})
			});

			// 实例化查询表单			this.form = new Ext.FormPanel({
				id : 'dplyRequestInfoFormPanel',
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
					store : sysIdsStore,
					name : 'appSysCode',
					id:'RequestStartApp',
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
							envRequestStartStroe.reload();
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
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.environment" />',
					store : envRequestStartStroe,
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
							Ext.getCmp("RequestStartApp").setValue(appsyscd);
						},
						expand:function(combo){
							var appsyscdValue = Ext.getCmp('RequestStartApp').getValue();
							if(appsyscdValue != ''){
								envRequestStartStroe.filter('env', appsyscdValue + '_', false, true);
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
					store : requestFunStore,
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
					store : execStatusStore,
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
					store : turnSwitchStore,
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
			// 设置基类属性			DplyRequestInfoList.superclass.constructor.call(this, {
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
		// 排期事件
		doPlan : function() {
			if(this.grid.getSelectionModel().getCount() != 1) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.select.one.only" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR,
					minWidth : 200
				});
				return;
			}
			
			var dplyReqRecord = this.grid.getSelectionModel().getSelected();
			
			if(dplyReqRecord.get('trunSwitch') == '1') {
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.schedule.failed.with.authorized.request" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
				return;
			}
			
			var form = Ext.getCmp('updateArrangeForm').getForm();
			form.reset();
			
			form.findField('appSysCode').setValue(dplyReqRecord.get('appSysCode'));
			form.findField('requestCode').setValue(dplyReqRecord.get('requestCode'));
			form.findField('environment').setValue(dplyReqRecord.get('environment'));
			form.findField('deployCode').setValue(dplyReqRecord.get('deployCode'));
			arrangeWin.show();
		},
		// 更新成功回调
		updateArrangeSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					var list = Ext.getCmp("DplyRequestInfoIndex").get(0);
					if (list != null) {
						list.grid.getStore().reload();
					}
					
					arrangeWin.hide();
				}
			});

		},
		// 更新失败回调
		updateArrangeFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 删除事件
		doDelete : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				var appSysCds = new Array();
				var requestCodes = new Array();
				for ( var i = 0; i < records.length; i++) {
					appSysCds[i] = records[i].get('appSysCode');
					requestCodes[i] = records[i].get('requestCode');
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
												url : '${ctx}/${managePath}/dplyrequestinfo/delete',
												scope : this,
												success : this.deleteSuccess,
												failure : this.deleteFailure,
												params : {
													appSysCds : appSysCds,
													requestCodes : requestCodes,
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
		// 删除成功回调方法
		deleteSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
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
		},
		// 删除失败回调方法
		deleteFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.failed" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		},
		// 执行事件
		doExecute : function() {
			
			if(this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel().getSelections();
				
				var correctSelect = true;
				var unableList = '';
				Ext.each(records, function(item){
					if(item.get('trunSwitch') != 1){
						correctSelect = false;
						return false;
					}
					switch(item.get('execStatus')){
						case '1' : break;
						case '2' : break;
						case '3' : 
						case '4' : 
						case '5' : 
							unableList += item.get('requestCode') + ",";
							break;
					}
				});
				if(!correctSelect){
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.records.include.unopen" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
					return;
				}
				if(unableList != ''){
					unableList = unableList.substring(0, unableList.length - 1);
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : unableList + "该状态禁止执行",
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
					return;
				}
				//后台时间校验
			/* 	for(var i = 0; i < records.length; i++){
					var deployDt = Date.parseDate(records[i].get('planDeployDate') + records[i].get('planStartTime'), 'YmdHi');
					if(new Date().getTime() < deployDt.getTime()){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.execute.failed.before.schedule.time" />',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return;
					}
				} */
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
					msg : '<fmt:message key="message.confirm.to.execute" />',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${managePath}/dplyrequestinfo/executeRequests',
								scope : this,
								method : 'POST',
								success : this.startSuccess,
								failure : this.startFailure,
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
		startSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '执行启动失败<fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
			var count = Ext.decode(response.responseText).count;
			if(count > 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.start.execute.successful"/><font size=2 color=red >' + count + '</font><fmt:message key="dplyRequestInfo"/>',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					minWidth : 200
				});
				this.gridStore.reload();
			}else{
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.invalid.requests" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR,
					minWidth : 200
				});
			}
			}

		},
		startFailure : function(){
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.start.execute.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		doReopen : function(){
			if(this.grid.getSelectionModel().getCount() == 0) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.select.one.at.least" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
				return;
			}
			
			var records = this.grid.getSelectionModel().getSelections();
			
			for ( var i = 0; i < records.length; i++) {
				if(records[i].get('execStatus') != '4' 
						&& records[i].get('execStatus') != '5'){
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.request.status.reopen.not.allow" />',
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
			
			Ext.Ajax.request({
				url : '${ctx}/${managePath}/dplyrequestinfo/reopenRequests',
				method : 'POST',
				scope : this,
				success : this.reopenSuccess,
				failure : this.reopenFailure,
				params : {
					appSysCodes : appSysCodes,
					requestCodes : requestCodes,
					environment : environment

				}
			});
		},
		reopenSuccess : function(form, action){
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.reopen.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this,
				fn : function() {
					this.gridStore.reload();
				}
			});
		},
		reopenFailure : function(form, action){
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.reopen.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		reqAppsys_Store : function(value) {

			var index = sysIdsStore.find('appsysCode', value);
			if (index == -1) {
				return value;
			} else {
				return sysIdsStore.getAt(index).get('appsysName');
			}
		},
		doSynRequests : function(){
			var form = Ext.getCmp('synBrpmReqForm').getForm();
			form.reset();
			synOptWin.show();
		},
		synRequestsSuccess : function(form, action){
			//var msg = Ext.util.JSON.decode(response.responseText).success;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<font color=red><fmt:message key="message.synchronize.successful" /></font><br>' + action.result.requestCodes + '<br>',//action.result.requestCodes
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					var list = Ext.getCmp("DplyRequestInfoIndex").get(0);
					if (list != null) {
						list.grid.getStore().reload();
					}
					
					synOptWin.hide();
				}
			});
		},
		synRequestsFailure : function(form, action){
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.synchronize.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		
		doAuthorizeByPhone : function(){
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
								url : '${ctx}/${managePath}/dplyrequestinfo/updateSwitchOnByPhone',
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
		},
	    doExport : function(){
	    
			var records = this.grid.getSelectionModel().getSelections();
			var requestids = new Array();

			if(records.length==0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.dply.export.excel" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						
					}
					
				});
			}else{
				var flag =false;
				for(var i=0;i<records.length;i++){
					if(records[0].get('appSysCode')!=records[i].get('appSysCode')){
						flag=true;
					};
					
				};
				
				if(flag){
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '不允许多个系统一起导出!',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.WARNING,
						minWidth : 200,
						scope : this
						
					});
					return;
				}
				
				var appcode=records[0].get('appSysCode');
				for ( var i = 0; i < records.length; i++) {
					requestids[i] = records[i].get('requestCode')+"@"+records[i].get('environment');
				}
				window.location = '${ctx}/${managePath}/excelexportrequest/downloadControlTemplet.xls?requestids='+encodeURI(requestids)+'&&appsys_code='+appcode; 
			 }
			}
			
	});
	var dplyRequestInfoList = new DplyRequestInfoList();
	//同步请求窗口
	if(!synOptWin){
		var synOptWin = new Ext.Window({
			title:'<fmt:message key="button.synrequest" />',
			layout:'fit',
			width:300,
			height:150,
			plain:true,
			modal : true,
			closable : true,
			resizable : false,
			draggable : true,
			closeAction : 'hide',

			items : new Ext.form.FormPanel({
				id:'synBrpmReqForm',
			 	url : '${ctx}/${managePath}/dplyrequestinfo/synBrpmCurMonthReqInfos',
				buttonAlign : 'center',
				labelAlign : 'right',
			    labelWidth : 110,
				frame : true, 
				monitorValid : true,
				defaultType:'datefield',
			    layout: 'form',
				timeout : 1800000,

				items:[{
					fieldLabel:'<fmt:message key="dplyRequestInfo.plannedStartDate" />',
					id : 'plannedStartDate',
					name : 'plannedStartDate',
					format : 'Ymd',
					allowBlank : false,
					endDateField : 'plannedEndDate',
					vtype : 'daterange',
					 width : 140 
				}, {
					fieldLabel:'<fmt:message key="dplyRequestInfo.plannedEndDate" />',
					id : 'plannedEndDate',
					name : 'plannedEndDate',
					format : 'Ymd',
					allowBlank : false,
					startDateField : 'plannedStartDate',
					vtype : 'daterange',
					width : 140
				}],
				buttons : [ {
					text : '<fmt:message key="button.synrequest" />',
					formBind : true,
					scope : this,
				    handler : function(){
							Ext.getCmp('synBrpmReqForm').getForm().submit({
								success : dplyRequestInfoList.synRequestsSuccess,
								failure : dplyRequestInfoList.synRequestsFailure,
								waitTitle : '<fmt:message key="message.wait" />',
								waitMsg : '<fmt:message key="message.saving" />'
							});
						}
				} ],
				listeners : {
					render : function(){
						this.getForm().findField('plannedStartDate').setValue(new Date().add(Date.MONTH, -1));
						this.getForm().findField('plannedEndDate').setValue(new Date());
					}
				}
			})
		});				
	}
	//排期窗口
	var arrangeWin = new Ext.Window({
		title:'<fmt:message key="button.plan" />',
		layout:'fit',
		width:400,
		height:280,
		plain:true,
		modal : true,
		closable : true,
		resizable : false,
		draggable : true,
		closeAction : 'hide',
		items : new Ext.form.FormPanel({
		 	id:'updateArrangeForm',
		 	url : '${ctx}/${managePath}/dplyrequestinfo/updateArrange',
		 	timeout : 300000,
			buttonAlign : 'center',
			labelAlign : 'right',
			lableWidth : 15,
			frame : true,
			monitorValid : true,
			defaultType:'textfield',
			items:[{
				fieldLabel:'<fmt:message key="dplyRequestInfo.appSyCode" />',
				name : 'appSysCode',
				readOnly : true,
				hidden : true
			}, {
				fieldLabel:'</font><fmt:message key="dplyRequestInfo.requestCode" />',
				name : 'requestCode',
				readOnly : true,
				width : 250
			}, {
				fieldLabel:'<fmt:message key="dplyRequestInfo.environment" />',
				name : 'environment',
				readOnly : true,
				width : 250
			}, {
				fieldLabel:'<font color=red>*</font><fmt:message key="dplyRequestInfo.deployCode" />',
				name : 'deployCode',
				allowBlank : false,
				maxLength:11,
				width : 250
			}, {
				xtype : 'datefield',
				fieldLabel:'<font color=red>*</font><fmt:message key="dplyRequestInfo.planDeployDate" />',
				name : 'planDeployDate',
				format : 'Ymd',
				allowBlank : false,
				width : 250
			}, {
				xtype : 'timefield',
				fieldLabel:'<font color=red>*</font><fmt:message key="dplyRequestInfo.planStartTime" />',
				name : 'planStartTime',
				format : 'Hi',
				increment : 30,
				allowBlank : false,
				width : 250
			}, {
				xtype : 'timefield',
				fieldLabel:'<font color=red>*</font><fmt:message key="dplyRequestInfo.planEndTime" />',
				name : 'planEndTime',
				format : 'Hi',
				increment : 30,
				allowBlank : false,
				width : 250
			},{
				xtype: 'radiogroup',
				disabled : true,
		     	fieldLabel: '<font color=red>*</font><fmt:message key="dplyRequestInfo.autostart" />',
		     	anchor:'55%',
		     	items: [
		               {boxLabel: '<fmt:message key="dplyRequestInfo.autostart.auto" />', name: 'autostart', inputValue: 'true'},
		               {boxLabel: '<fmt:message key="dplyRequestInfo.autostart.manual" />', name: 'autostart', inputValue: 'false', checked: true}
		         ]
			}],
			buttons : [{
				text : '<fmt:message key="button.submit" />',
				formBind : true,
				iconCls : 'button-ok',
				scope : this,
				handler : function(){
					Ext.getCmp('updateArrangeForm').getForm().submit({
						success : dplyRequestInfoList.updateArrangeSuccess,
						failure : dplyRequestInfoList.updateArrangeFailure,
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.saving" />'
					});
				}
			}]
		})
	});
	
	var runner = new Ext.util.TaskRunner();
	var dplyRequestInfoList = new DplyRequestInfoList();
	var synReqStatusTask = {
			run : function(){
				dplyRequestInfoList.gridStore.reload();				
			},
			interval : 300000
	};
	runner.start(synReqStatusTask);
	
</script>
<sec:authorize access="hasRole('REQ_SYN')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
	iconCls : 'button-sync',
	text : '<fmt:message key="button.synrequest" />',
	scope : dplyRequestInfoList,
	handler : dplyRequestInfoList.doSynRequests
   },'-');
</script> 
</sec:authorize>

<sec:authorize access="hasRole('REQ_SCDL')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
		iconCls : 'button-plan',
		text : '<fmt:message key="button.plan" />',
		scope : dplyRequestInfoList,
		handler : dplyRequestInfoList.doPlan
	},'-');
</script> 
</sec:authorize>

<sec:authorize access="hasRole('REQ_DELETE')">
	<script type="text/javascript">
	dplyRequestInfoList.grid.getTopToolbar().add({
			iconCls : 'button-delete',
			text : '<fmt:message key="button.delete" />',
			scope : dplyRequestInfoList,
			handler : dplyRequestInfoList.doDelete
		}, '-');
	</script>
</sec:authorize>

<sec:authorize access="hasRole('REQ_EXE')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
		iconCls : 'button-start',
		text : '<fmt:message key="button.execute" />',
		scope : dplyRequestInfoList,
		handler : dplyRequestInfoList.doExecute
	},'-');
</script> 
</sec:authorize>

<sec:authorize access="hasRole('REQ_REOPEN')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
		iconCls : 'button-reopen',
		text : '<fmt:message key="button.reopen" />',
		scope : dplyRequestInfoList,
		handler : dplyRequestInfoList.doReopen
	},'-');
</script> 
</sec:authorize>

<sec:authorize access="hasRole('CONTROL_EXCEL')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
		iconCls : 'button-excel',
		text : '实施控制表',
		scope : dplyRequestInfoList,
		handler : dplyRequestInfoList.doExport
	},'-');
</script> 
</sec:authorize>
<sec:authorize access="hasRole('DPLY_REQUEST_AUTHORIZE_PHONE')">
 <script type="text/javascript">
 dplyRequestInfoList.grid.getTopToolbar().add( {
	iconCls : 'button-confirm',
	text : '电话授权',
	scope : dplyRequestInfoList,
	handler : dplyRequestInfoList.doAuthorizeByPhone
   },'-');
</script> 
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("DplyRequestInfoIndex").add(dplyRequestInfoList);
	Ext.getCmp("DplyRequestInfoIndex").doLayout();
	Ext.getCmp("DplyRequestInfoIndex").on('destroy', function(){
		runner.stop(synReqStatusTask);	
	});
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var serverNames = decodeURIComponent('${param.ServerName}').split(',');
var appsysCodes = decodeURIComponent('${param.AppsysCode}').split(',');
var appsysCodes_ip = decodeURIComponent('${param.AppsysCode_ip}').split(',');
var checkTimes = decodeURIComponent('${param.StartDatetime}').split(',');
var ruleNames = decodeURIComponent('${param.RuleName}').split(','); 
var logNames = decodeURIComponent('${param.logName}').split(','); 
//应用系统
var appsysStore_errorEntr =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});
appsysStore_errorEntr.load();
//登录用户
var checkEntruserNameStore_errorEntr =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		method : 'POST',
		url : '${ctx}/${appPath}/checkerror/getUserName',
		disableCaching : false
	}),
	reader: new Ext.data.JsonReader({}, ['UName'])
});
checkEntruserNameStore_errorEntr.load();
//处理状态
var checkEntrStatusStore_errorEntr = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/INCONSISTENT_HANDLE_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
checkEntrStatusStore_errorEntr.load();
checkEntrStatusStore_errorEntr.on('load',function(store){
	store.removeAt(3);
	Ext.getCmp('checkUser_batch').setValue(checkEntruserNameStore_errorEntr.data.items[0].data.UName);
});
//常用方法
var checkmrthodStore_errorEntr = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_COMMONLY_METHOD/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
checkmrthodStore_errorEntr.load();

//单个处理单的错误日志等基本信息 	var DetailLog = Ext.extend(Ext.Panel, {
		
		server : null,
		row : 0,
		task : null,
		constructor : function(cfg) {// 构造方法
			
			Ext.apply(this, cfg);
			// 设置基类属性

			DetailLog.superclass.constructor.call(this, {
			
				layout : 'fit',
				bodyStyle : 'background-color : black',
				//autoScroll : true,
				
				items : [{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="property.InconsistentShellLog" />',
					id : this.logId,
					style  : 'background : #F0F0F0' , 
					readOnly : true,
					tabIndex : this.tabIndex++
				} ]
			});
		}
	}); 
	
	
SingleErrorInfo = Ext.extend(Ext.Panel, {
	ServerName : null,
	StartDatetime : null,
	RuleName : null,
	logs : null,
	RecordNum : null,
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 设置基类属性		var logItems = [];
		var detailLogs=this.logs.split(';');
		for(var n = 0; n < detailLogs.length; n++){
	 		logItems.push({
				title : detailLogs[n].substring(0,detailLogs[n].indexOf('='))+'.log',
				autoScroll : true,
				//closable : true,
				layout : 'fit',
				items : [  new DetailLog({
					logId : detailLogs[n].substring(0,detailLogs[n].indexOf('='))+'.log'+this.RecordNum
				}) ]
			}); 
			
		} 
		/* items.push({
			title : ruleResultString[i].substring(0,ruleResultString[i].indexOf('='))+'.log',
			autoScroll : true,
			//closable : true,
			layout : 'fit',
			items : [ new DetailLog({
				logId : ruleResultString[i].substring(0,ruleResultString[i].indexOf('='))+'.log'
			})]
		}); */
		
		SingleErrorInfo.superclass.constructor.call(this, {
			id :'SingleErrorInfoId',
			layout : 'fit',
			autoScroll : false,
			items : [{
				layout:'column',
				frame : true ,
				items:[{
				     columnWidth:.5,
				     layout:'form',
				     items:[{
				    	 	xtype : 'textfield',
							fieldLabel : '<fmt:message key="property.ServerName" />',
							width : '100%',
							name : 'ServerName_hand_batch',
							id:'check_server_name_batch_'+this.RecordNum,
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							width : '100%',
							fieldLabel : '<fmt:message key="property.StartDatetime" />',
							name : 'StartDatetime_hand_batch',
							id:'check_start_time_batch_'+this.RecordNum,
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						}]
				},{
				     columnWidth:.5,
				     layout:'form',
				     items:[{
							xtype : 'textfield',
							fieldLabel : '作业关联的应用系统',
							width : '100%',
							name : 'appsysCode_hand_batch',
							id:'check_appsys_code_batch_'+this.RecordNum,
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							hidden : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							fieldLabel : '<fmt:message key="job.appsys_code" />',
							width : '100%',
							name : 'appsysCode_hand_batch_ip',
							id:'check_appsys_code_batch_ip_'+this.RecordNum,
							//value : appsysCodes_ip[this.RecordNum],
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							fieldLabel :  '<fmt:message key="property.RuleName" />',
							name : 'RuleName_hand_batch',
							id:'check_rule_name_batch_'+this.RecordNum,
							width : '100%',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						}]
				},{
					columnWidth:1,
					layout:'form',
					items:[
					     {
					    region : 'center',
						xtype : 'tabpanel',
						fieldLabel : '<fmt:message key="property.InconsistentShellLog" />',
						enableTabScroll : true,
						allowDomMove : true ,
						activeTab : 0,
						deferredRender:false,
						forceLayout : true,
						frame : true ,
						height : 250,
						items : [logItems]
						}, {
						xtype : 'textfield',
						hidden : true,
						name : 'ExtendObject',
						id:'check_extend_object_batch_'+this.RecordNum,
						tabIndex : this.tabIndex++
					}]
				}]
			}]
		});
		this.on('render', function() {
			this.requestData();
		});
	},
	requestData : function() {
		Ext.Ajax.request({
			url : '${ctx}/${appPath}/checkerror/hand',
			method : 'POST',
			scope : this,
			params : {
				ServerName : this.ServerName,
				StartDatetime : this.StartDatetime,
				RuleName : this.RuleName
			},
			callback : this.loadSuccess
		});
	}, 
	//加载成功
	loadSuccess : function(options, success, response) {
		var serverName ;
		var appsysCode ;
		var startDatetime ;
		var ruleName ;
		var extendObject ;
		if (success) {
			/* 根据系统编号获取系统名称 --------------begin  */
			var appsys_name ;
			var appsys_id = appsysCodes_ip[this.RecordNum];
			var index = appsysStore_errorEntr.find('appsysCode', appsys_id);
			if (index == -1) {
				appsys_name = appsys_id;
			} else {
				appsys_name = appsysStore_errorEntr.getAt(index).get('appsysName');
			}
			Ext.getCmp('check_appsys_code_batch_ip_'+this.RecordNum).setValue(appsys_name);
			/* 根据系统编号获取系统名称 --------------end  */
			var data = Ext.decode(response.responseText).data;
			serverName = data.ServerName;
			appsysCode = data.appsysCode;
			startDatetime = data.StartDatetime;
			ruleName = data.RuleName;
			extendObject = data.ExtendObject;
			Ext.getCmp('check_server_name_batch_'+this.RecordNum).setValue(serverName);
			Ext.getCmp('check_appsys_code_batch_'+this.RecordNum).setValue(appsysCode);
			Ext.getCmp('check_start_time_batch_'+this.RecordNum).setValue(startDatetime);
			Ext.getCmp('check_rule_name_batch_'+this.RecordNum).setValue(ruleName);
			Ext.getCmp('check_extend_object_batch_'+this.RecordNum).setValue(extendObject);
		var paramLog=this.logs.split(';');
		for(var t=0;t<paramLog.length;t++){
				Ext.Ajax.request({
					url : '${ctx}/${appPath}/checkerror/getLogByServerAndTimeAndExtend',
					scope : this,
					params : {
						serverName : serverName,
						startTime : startDatetime,
						extendObject : extendObject,
						log : paramLog[t].substring(0,paramLog[t].indexOf('='))+'.log'
					},
					success : function(resp,opts){
						var respText = Ext.util.JSON.decode(resp.responseText);
						var info = '' ;
						if(respText.info){
							info = respText.info;
						}
						if(info!=''){
							Ext.getCmp(respText.id+this.RecordNum).setValue(info);
						}
					}
				});
			}
		}
	}
});				

//定义表单
ErrorBatchHandForm = Ext.extend(Ext.FormPanel,{
		gridStore : null,// 数据列表数据源		constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		var items = [];
		
		for(var i = 0; i < logNames.length; i++){
			items.push({
				title : logNames[i].substring(0,logNames[i].indexOf('|+|')),
				autoScroll : true,
				closable : true ,//默认为false.true时页签可关闭
				layout : 'fit',
				items : [ new SingleErrorInfo({
					ServerName : serverNames[i],
					StartDatetime : checkTimes[i],
					RuleName : logNames[i].substring(0,logNames[i].indexOf('|+|')),
					RecordNum : i,
					logs : logNames[i].substring(logNames[i].indexOf('|+|')+3)
				})]
			});
			
			
		}
		
		ErrorBatchHandForm.superclass.constructor.call(this, {
			id : 'checkHand',
			region : 'center',
			labelAlign : 'right',
			buttonAlign : 'center',
			monitorValid : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/checkerror/edithand/${param.ServerName}/${param.StartDatetime}',
			collapseMode : 'mini',
			frame:'form',
			border : false,
			defaults : {
				anchor : '96%',
				msgTarget : 'side'
			},
		    // 定义表单组件
		    items : [{
		    	layout : 'form',
	    		frame : true ,
	    		style : 'margin-left:40px', 
	            items : [{
		 				region : 'center',
						xtype : 'tabpanel',
						enableTabScroll : true,
						allowDomMove : true ,
						activeTab : 0,
						deferredRender:false,
						forceLayout : true,
						frame : true ,
						height : 250,
						items : [items]
				},{
						region : 'south',
						layout:'form',
						items : [{
							xtype : 'textarea',
							fieldLabel : '<fmt:message key="property.InconsistentHandleDesc" />',
							id:'handleDesc_batch',
							name : 'InconsistentHandleDesc',
							maxLength : 200,
							height : 80,
							width : '100%',
							tabIndex : this.tabIndex++
						},{
							xtype : 'combo',
							store : checkmrthodStore_errorEntr,
							fieldLabel :  '<fmt:message key="job.common_handle_method" />',
							anchor : '100%',
							valueField : 'name',
							displayField : 'name',
							id:'mrthodId_batch',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							tabIndex : this.tabIndex++,
							listeners : {
								//编辑完成后处理事件
								select : function(obj) {
									var t =Ext.getCmp('mrthodId_batch').getValue();
									Ext.getCmp('handleResult_batch').setValue(t);
								}
						   }
						},{
							xtype : 'textarea',
							fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.InconsistentHandleResult" />',
							name : 'InconsistentHandleResult',
							id:'handleResult_batch',
							allowBlank : false,
							maxLength : 200,
							height : 80,
							width : '100%',
							tabIndex : this.tabIndex++
						},{
							layout:'column',
							items:[{
							     columnWidth:.50, 
							     layout:'form',
							     items:[{
										xtype : 'combo',
										anchor : '100%',
										store : checkEntrStatusStore_errorEntr,
										fieldLabel :  '<font color=red>*</font>&nbsp;<fmt:message key="property.InconsistentHandleStatus" />',
										name : 'InconsistentHandleStatus',
										id : 'handleState_batch',
										valueField : 'value',
										displayField : 'name',
										allowBlank : false,
										hiddenName : 'InconsistentHandleStatus',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										tabIndex : this.tabIndex++
									}]
							 },{
							     columnWidth:.50,
							     layout:'form',
							     items:[{
									xtype : 'textfield',
									fieldLabel :'<fmt:message key="property.InconsistentHandleUser" />',
									id:'checkUser_batch',
									width : '100%',
									name : 'InconsistentHandleUser',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									tabIndex : this.tabIndex++
								}]
							}]
						}]
					}]
		        }],
				// 定义查询表单按钮
				buttons : [{
					text : '<fmt:message key="button.save" />',
					id : 'checkerror_entr_save',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					scope : this,
					formBind : true,
					handler : this.doSave
				}, {
					text : '<fmt:message key="button.reset" />',
					iconCls : 'button-reset',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doReset
				}]
			});
		},
		// 保存操作
		doSave : function() {
			var InconsistentHandleResult=Ext.getCmp("handleResult_batch").getValue();
			var InconsistentHandleDesc=Ext.getCmp("handleDesc_batch").getValue();
			var HandleState=Ext.getCmp("handleState_batch").getValue(); 
			var serverNamesArr = new Array() ;
			var checkTimesArr = new Array() ;
			var appsysCodesArr = new Array() ;
			var ruleNamesArr = new Array() ;
			var args1 = document.getElementsByName('ServerName_hand_batch');
			if(args1.length>0){
				for(var t=0 ; t<args1.length ; t++){
					serverNamesArr.push(args1[t].value);
				}
			}
			var args2 = document.getElementsByName('StartDatetime_hand_batch');
			if(args2.length>0){
				for(var t=0 ; t<args2.length ; t++){
					checkTimesArr.push(args2[t].value);
				}
			}
			var args3 = document.getElementsByName('appsysCode_hand_batch');
			if(args3.length>0){
				for(var t=0 ; t<args3.length ; t++){
					appsysCodesArr.push(args3[t].value);
				}
			}
			var args4 = document.getElementsByName('RuleName_hand_batch');
			if(args4.length>0){
				for(var t=0 ; t<args4.length ; t++){
					ruleNamesArr.push(args4[t].value);
				}
			}
			if(serverNamesArr==null || serverNamesArr.length==0){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '巡检项不可为空！',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}else{
				Ext.Ajax.request({
					url : '${ctx}/${appPath}/checkerror/editEntr',
					method : 'POST',
					scope : this,
					success : this.saveSuccess,
					failure : this.saveFailure,
					disableCaching : true,
					params : {
						ServerName:serverNamesArr,
						StartDatetime:checkTimesArr,
						AppsysCode:appsysCodesArr,
						RuleName:ruleNamesArr,
						HandleState:HandleState,
						Result:InconsistentHandleResult,
						Desc:InconsistentHandleDesc
					}
				});
			}
		},
		// 重置表单
		doReset : function() {
			this.form.getForm().reset();
		},
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					app.closeTab('CHECK_ERROR_BATCH_HANDLE');
					var list = Ext.getCmp("CHECK_ERROR_DETA").get(0);
					if (list != null) {
						list.grid.getStore().reload();
					}
					var params = {
							ServerName : '${param.serverName}',
							appsysCode : '${param.appsysCode}',
							appsysCode_ip : '${param.appsysCodeIP}',
							LastDate : '${param.LastDate}',
							FlucDatetime :'${param.FlucDatetime}',
							checkDate :'${param.checkDate}',
							checkstatus : '${param.checkstatus}'
					}; 
					app.loadTab('CHECK_ERROR_DETA', '<fmt:message key="job.error" /><fmt:message key="property.detailed" />', '${ctx}/${appPath}/checkerror/oneDetail', params);
				}
			});
		},
		// 保存失败回调
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
	/* app.window.get(0).add(new ErrorBatchHandForm());
	app.window.get(0).doLayout(); */
	
	var errorBatchHandForm = new ErrorBatchHandForm();
	Ext.getCmp("CHECK_ERROR_BATCH_HANDLE").add(errorBatchHandForm);
	Ext.getCmp("CHECK_ERROR_BATCH_HANDLE").doLayout();
</script>



<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var serverNameParam = decodeURIComponent('${param.ServerName}') ;
	var ruleNameParam = decodeURIComponent('${param.RuleName}') ; 
	//登录用户
	var checkuserNameStore =  new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			method : 'POST',
			url : '${ctx}/${appPath}/checkerror/getUserName',
			disableCaching : false
		}),
		reader: new Ext.data.JsonReader({}, ['UName'])
	});
	checkuserNameStore.load();
	var ruleResultStrings  ='${param.ruleResultString}';
	var ruleResultString = [];
	ruleResultString=ruleResultStrings.split(';');
	var DetailLog = Ext.extend(Ext.Panel, {
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
	//定义表单
	ErrorHandleForm = Ext.extend(Ext.FormPanel,{
		gridStore : null,// 数据列表数据源
		constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		var items = [];
		for(var i = 0; i < ruleResultString.length; i++){
			items.push({
				title : ruleResultString[i].substring(0,ruleResultString[i].indexOf('='))+'.log',
				autoScroll : true,
				//closable : true,
				layout : 'fit',
				items : [ new DetailLog({
					logId : ruleResultString[i].substring(0,ruleResultString[i].indexOf('='))+'.log'
				})]
			});
			
		} 
		this.checkmrthodStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_COMMONLY_METHOD/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.checkmrthodStore.load();
		//处理状态
		this.checkStatusStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/INCONSISTENT_HANDLE_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.checkStatusStore.load();
		this.checkStatusStore.on('load',function(store){
			store.removeAt(3);
		});
		//应用系统
		this.appsysStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
		});
		this.appsysStore.load();
		ErrorHandleForm.superclass.constructor.call(this, {
			id : 'checkHand',
			region : 'center',
			labelAlign : 'right',
			buttonAlign : 'center',
			autoScroll : true,
			url : '${ctx}/${appPath}/checkerror/edithand/'+serverNameParam+'/${param.StartDatetime}/'+ruleNameParam,
			collapseMode : 'mini',
			frame:'form',
			monitorValid : true,
			border : false,
			defaults : {
				anchor : '90%',
				msgTarget : 'side'
			},
			// 定义表单组件
			items : [{
				layout:'column',
				items:[{
				     columnWidth:.5,
				     layout:'form',
				     items:[{
				    	 	xtype : 'textfield',
							fieldLabel : '<fmt:message key="property.ServerName" />',
							width : '100%',
							name : 'ServerName',
							id:'check_server_name',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							width : '100%',
							fieldLabel : '<fmt:message key="property.StartDatetime" />',
							name : 'StartDatetime',
							id:'check_start_time',
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
							name : 'appsysCode',
							id : 'check_error_handle_appsys',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							hidden : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							fieldLabel : '<fmt:message key="job.appsys_code" />',
							width : '100%',
							id : 'check_error_handle_appsys_ip',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							fieldLabel :  '<fmt:message key="property.RuleName" />',
							name : 'RuleName',
							width : '100%',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						}]
				}]
			},{
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
				items : [items]
			},{
				xtype : 'textarea',
				fieldLabel : '<fmt:message key="property.InconsistentHandleDesc" />',
				id:'HandleDescID',
				name : 'InconsistentHandleDesc',
				/* allowBlank : false, */
				height : 80,
				tabIndex : this.tabIndex++
			},{
				xtype : 'combo',
				store : this.checkmrthodStore,
				fieldLabel :  '<fmt:message key="job.common_handle_method" />',
				valueField : 'name',
				displayField : 'name',
				id:'mrthodId',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				tabIndex : this.tabIndex++,
				listeners : {
					//编辑完成后处理事件
					select : function(obj) {
						var t =Ext.getCmp('mrthodId').getValue();
						Ext.getCmp('HandleResultID').setValue(t);
					}
			   }
			},{
				xtype : 'textarea',
				fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.InconsistentHandleResult" />',
				id:'HandleResultID',
				name : 'InconsistentHandleResult',
				allowBlank : false,
				height : 80,
				tabIndex : this.tabIndex++
			},{
			     layout:'form',
			     items:[{
			    	xtype : 'combo',
			    	anchor : '51.2%',
					store : this.checkStatusStore,
					fieldLabel :  '<font color=red>*</font>&nbsp;<fmt:message key="property.InconsistentHandleStatus" />',
					name : 'InconsistentHandleStatus',
					id : 'handleStatus',
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
				layout:'column',
				items:[{
				     columnWidth:.52,
				     layout:'form',
				     id : 'check_error_handle_user',
				     items:[{
							xtype : 'textfield',
							fieldLabel :'<fmt:message key="property.InconsistentHandleUser" />',
							id:'checkUser',
							width : '98%',
							name : 'InconsistentHandleUser',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
						}]
				},{
				     columnWidth:.48,
				     layout:'form',
				     id : 'check_error_handle_time',
				     items:[{xtype : 'label'},{
							xtype : 'textfield',
							width : '100%',
							fieldLabel : '<fmt:message key="property.InconsistentHandleDate" />',
							name : 'InconsistentHandleDate',
							id : 'check_error_handleTime',
							style  : 'background : #F0F0F0' , 
							readOnly : true,
							tabIndex : this.tabIndex++
					 }]
				},{
					xtype : 'textfield',
					hidden : true,
					name : 'ExtendObject',
					id:'check_extend_object',
					tabIndex : this.tabIndex++
				}]
			} ],
			// 定义查询表单按钮
			buttons : [{
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				id:'saveId',
				formBind : true, 
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doReset
			}]
		});
		
		
		// 加载表单数据
		this.load({
			url : '${ctx}/${appPath}/checkerror/hand',
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			params : {
				ServerName : serverNameParam,
				StartDatetime : '${param.StartDatetime}',
				RuleName:ruleNameParam
			},
			success : this.loadSuccess
		});
		
		},
		//加载成功
		loadSuccess : function(form, action) {
			/* 根据系统编号获取系统名称 --------------begin  */
			var appsys_name ;
			var appsys_id = decodeURIComponent('${param.appsysCode_ip}');
			var index = this.appsysStore.find('appsysCode', appsys_id);
			if (index == -1) {
				appsys_name = appsys_id;
			} else {
				appsys_name = this.appsysStore.getAt(index).get('appsysName');
			}
			Ext.getCmp('check_error_handle_appsys_ip').setValue(appsys_name);
			/* 根据系统编号获取系统名称 --------------end  */
			Ext.getCmp('checkUser').setValue(checkuserNameStore.data.items[0].data.UName);
			/* 获取日志信息----begin */
			var serverName = Ext.getCmp('check_server_name').getValue();
			var checkStartTime = Ext.getCmp('check_start_time').getValue();
			var extendObject = Ext.getCmp('check_extend_object').getValue();
			for(var j = 0; j < ruleResultString.length; j++){
			Ext.Ajax.request({
				url : '${ctx}/${appPath}/checkerror/getLogByServerAndTimeAndExtend',
				scope : this,
				params : {
					serverName : serverName,
					startTime : checkStartTime,
					extendObject : extendObject,
					log : ruleResultString[j].substring(0,ruleResultString[j].indexOf('='))+'.log'
				},
				success : function(resp,opts){
					var respText = Ext.util.JSON.decode(resp.responseText);
					var info = '' ;
					if(respText.info){
						info = respText.info;
						
					}
					if(info!=''){
						Ext.getCmp(respText.id).setValue(info);
					}
				}
			});
			}
			/* 获取日志信息----end */
			InconsistentHandleStatus='${param.InconsistentHandleStatus}';
			if(InconsistentHandleStatus=='2' ){
				Ext.getCmp('saveId').disable();
				Ext.getCmp('HandleDescID').disable();
				Ext.getCmp('HandleResultID').disable();
				Ext.getCmp('mrthodId').hide();
				Ext.getCmp('handleStatus').disable();
			}
			if(Ext.getCmp('handleStatus').getValue()=='1'){ //未处理

				Ext.getCmp('check_error_handle_time').hide();
				Ext.getCmp('check_error_handle_user').hide();
			}
		},
	
		// 保存操作
		doSave : function() {
			var appsysCode=Ext.getCmp("check_error_handle_appsys").getValue();
			var InconsistentHandleDesc=Ext.getCmp("HandleDescID").getValue();
			var InconsistentHandleResult=Ext.getCmp("HandleResultID").getValue();
			var HandleState=Ext.getCmp("handleStatus").getValue();
			Ext.Ajax.request({
				url : '${ctx}/${appPath}/checkerror/edithand',
				method : 'POST',
				scope : this,
				success : this.saveSuccess,
				failure : this.saveFailure,
				disableCaching : true,
				params : {
					ServerName:serverNameParam,
					StartDatetime:'${param.StartDatetime}',
					RuleName:ruleNameParam,
					AppsysCode:appsysCode,
					HandleState:HandleState,
					Result:InconsistentHandleResult,
					Desc:InconsistentHandleDesc
				}
			});
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
					app.closeTab('CHECK_ERROR_HANDLE');
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
	/* app.window.get(0).add(new jobdesignViewForm());
	app.window.get(0).doLayout(); */
	var errorHandleForm = new ErrorHandleForm();
	Ext.getCmp("CHECK_ERROR_HANDLE").add(errorHandleForm);
	Ext.getCmp("CHECK_ERROR_HANDLE").doLayout();
</script>


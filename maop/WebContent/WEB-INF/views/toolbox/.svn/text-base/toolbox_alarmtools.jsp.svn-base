<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var Alarm_usercode="no";
var AlarmDyn_tool_code;
var AlarmDyn_appsys_code;
var AlarmDyn_tool_name;
var AlarmDyn_os_type;
var AlarmDyn_osUser;
var AlarmDyn_shell_name;
var AlarmDyn_tool_type;
var Alarm_event_id;
var Alarm_device_ip;
var Alarm_tool_type;
//登录用户
var Alarm_userNameStore =  new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			method : 'POST',
			url : '${ctx}/${appPath}/ToolBoxController/getUserName',
			disableCaching : false
		}),
		reader: new Ext.data.JsonReader({}, ['UName','RoleName','UId'])
		
	});
	Alarm_userNameStore.load();
//授权用户

	var Alarm_DynuserStore = new Ext.data.Store({
		proxy : new Ext.data.HttpProxy(
				{
					method : 'POST',
					url : '${ctx}/${appPath}/ToolBoxController/getDyn_user',
					disableCaching : false
				}),
		reader: new Ext.data.JsonReader({}, ['dynUser','name']),
		baseParams : {
			
		}
		
	});
 function Diagnostic(event_id){
	 
	 var grid = Ext.getCmp(event_id+"Alarmtoolspanelid");
	 var record = grid.getSelectionModel().getSelected();
	 
	 AlarmDyn_tool_code = record.get('tool_code');
	 AlarmDyn_appsys_code = record.get('appsys_code');
	 AlarmDyn_osUser = record.get('os_user');
	 AlarmDyn_os_type=  record.get('os_type');
	 AlarmDyn_tool_name=record.get('tool_name');
	 AlarmDyn_shell_name= record.get('shell_name');
	 Alarm_event_id=event_id;
	 Alarm_device_ip=record.get('device_ip');
	 Alarm_tool_type=record.get('tool_type');
	 if(record.get('tool_status')!=2){

			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '工具没有接收，没有使用权',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.WARNING,
				minWidth : 200
			});
			return false ;
	 }
	
		
	if(0==record.data.tool_authorize_flag){
		
		var tool_code   = record.get('tool_code');
		var tool_name =  record.get('tool_name');
		var device_ip  = record.get('device_ip');
			var params = {
					tool_code   : record.get('tool_code'),
					appsys_code : record.get('appsys_code'),
					os_type     : record.get('os_type'),
					usercode    : Alarm_usercode, 
					event_id    : event_id,
					device_ip    : device_ip
				};
			if(record.get('tool_type')==1){
				
				AlarmTabspanel.loadTabAlarmTool(event_id,event_id+tool_code+'AlarmExe',tool_name+'<fmt:message key="toolbox.tool_exc" />','${ctx}/${appPath}/ToolBoxAlarmController/AlarmExc',
						params);
			}
			if(record.get('tool_type')==2){
				
				AlarmTabspanel.loadTabAlarmTool(event_id,event_id+tool_code+'AlarmExe',tool_name+'<fmt:message key="toolbox.tool_exc" />','${ctx}/${appPath}/ToolBoxAlarmController/AlarmExcDesc',
						params);
			}
				
		
	}else if(1==record.data.tool_authorize_flag){
	
	 Alarm_DynuserStore.baseParams.appsys_code =  AlarmDyn_appsys_code; 
	 Alarm_DynuserStore.load();
	
	
	//动态授权
	  var Alarm_Dyn_Win = new Ext.Window({
		title:'<fmt:message key="toolbox.tool_Dynamic_password_check" />', 
		id: '${param.event_id}'+'Alarm_Dyn_WinID',
		layout:'form',
		width:350,
		height:160,
		plain:true,
		modal : true,
		closable : true,
		resizable : false,
		draggable : true,
		closeAction :'close',
		items : new Ext.form.FormPanel({
			buttonAlign : 'center',
			labelAlign : 'right',
			lableWidth : 15,
			frame : true,
			monitorValid : true,
			defaults : {
				anchor : '90%',
				msgTarget : 'side'
			},
			items:[{
				xtype : 'combo',
				store : Alarm_DynuserStore,
				fieldLabel : '<fmt:message key="toolbox.tool_Authorized_account" />',
				name : 'usercode',
				id : '${param.event_id}'+'usercodeID',
				valueField : 'dynUser',
				displayField : 'name',
				hiddenName : 'usercode',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++,
				allowBlank : false
			},
			{
				xtype : 'textfield',
				inputType : 'password',
				fieldLabel :'静态密码', 
				id:'${param.event_id}'+'pinCodeID',
				name : 'pinCode',
				tabIndex : this.tabIndex++,
				allowBlank : false
			},
			{
				xtype : 'textfield',
				inputType : 'password',
				fieldLabel :'<fmt:message key="toolbox.tool_dynamic_password" />', 
				id:'${param.event_id}'+'dynpasswordID',
				name : 'dynpassword',
				tabIndex : this.tabIndex++,
				allowBlank : false

			}],
			buttons : [{
					text :'<fmt:message key="toolbox.submit" />', 
					iconCls : 'button-save',
					formBind : true,
					tabIndex : this.tabIndex++,
					scope : this,
					handler : Alarmtools.doIsDynPassword
				},{
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					handler : Alarmtools.doDynCancel

				} ]
		})
	});
	Alarm_Dyn_Win.show();
}


} 
  AlarmTabspanel=Ext.extend(Ext.TabPanel,{
	  id:'${param.event_id}'+'toolslist',
	    tabs : null,
	  loadTabAlarmTool : function(event_id,id, title, url, params, iframe, openInHome) {
		  
		  this.id=event_id+'toolslist';
		
		  //var tab = this.getComponent(id);
		  	var tab;
		  	tab = Ext.getCmp(id);
		  	if(tab) {
		  		tab.destroy();
		  		tab = Ext.getCmp(id);
		  	}
			if (!tab) {
				var panel = new Jeda.ui.Tab({
					id : id,
					title : title,
					url : url,
					params : params,
					closable : !openInHome ,
					listeners : {
						scope : this,
						'activate' : function(panel) {
							if(typeof Ext.getCmp(id+'VIEW')!='undefined'){
								if(typeof Ext.getCmp(id+'VIEW').window.get(0)!='undefined'){
									if(Ext.getCmp(id+'VIEW').window.get(0).getId().indexOf("ext-comp")==-1){
								Ext.getCmp(id+'VIEW').window.show();
									}
								}
							}
						},
						'deactivate' : function(panel) {
							if(typeof Ext.getCmp(id+'VIEW')!='undefined'){
								Ext.getCmp(id+'VIEW').window.hide();								
							}
							
						}
						} 
				});
				 if (openInHome) {
					 Ext.getCmp(this.id).remove( Ext.getCmp(this.id).tabs.get(1), true);
					tab =  Ext.getCmp(this.id).insert(1, panel);
				} else {
					if ( Ext.getCmp(this.id).items.length >= 10) {
						Ext.Msg.show({
							title : '<fmt:message key="error.title" />',
							msg : '<fmt:message key="message.tabs.limit" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
						return false;
					} else {
						tab =  Ext.getCmp(this.id).add(panel);
					}
				} 
				this.setActiveTab(tab);
				if (iframe) {
					tab.add(new Jeda.ui.IFrame({
						id : id + "panel",
						url : url
					}));
					tab.doLayout();
				}
			} else {
				Ext.apply(tab, {
					id : id,
					title : title,
					url : url,
					params : params
				});
				tab.removeAll();
			}
			 Ext.getCmp(this.id).setActiveTab(tab);
			tab.doLoad();
		
		},
		
		
		closeTab : function(id) {
			var tab =  Ext.getCmp(this.id).tabs.getComponent(id);
			if (tab) {
				 Ext.getCmp(this.id).tabs.remove(tab);
			}
		}
		
 } ); 
 

	Alarmtoolspanel = Ext.extend(
					Ext.Panel,
					{
						gridStore : null,// 数据列表数据源						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单      组件Tab键顺序						csm : null,// 数据列表选择框组件						constructor : function(cfg) {// 构造方法							Ext.apply(this, cfg);
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止
							/* Ext.getDoc().on('keydown',function(e) {
												if (e.getKey() == 8
														&& e.getTarget().type == 'text'
														&& !e.getTarget().readOnly) {

												} else if (e.getKey() == 8
														&& e.getTarget().type == 'textarea'
														&& !e.getTarget().readOnly) {

												} else if (e.getKey() == 8) {
													e.preventDefault();
												}
											}); */
							
							this.tool_statusStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_statusStore.load();
							this.tool_authorize_flagStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_authorize_flagStore.load();

							this.ServerGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.ServerGroupStore.load();
							this.authorize_level_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.authorize_level_typeStore.load();
							
							this.tool_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_typeStore.load();

							 this.appsys_Store =  new Ext.data.Store({
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
								this.appsys_Store.load(); 
							
							this.userStore =  new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/jobdesign/getUsers',
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['username','name'])
							});
							this.userStore.load();

							
							// 实例化数据列表选择框组件
							csm = new Ext.grid.CheckboxSelectionModel();

							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${appPath}/ToolBoxAlarmController/alarmtoolsindex',
													disableCaching : false
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'tool_code', 'appsys_code',
												'tool_name', 'server_group',
												'authorize_level_type',
												'field_type_one','field_type_two',
												'field_type_three','os_type',
												'position_type', 'tool_authorize_flag',
												'shell_name','os_user','event_id',
												'device_ip','alarmobject',
												'tool_status','tool_returnreasons',
												'componenttype','component',
												'alarminstance','summarycn','tool_type',
												'event_id'
										],
										remoteSort : true,
										sortInfo : {
											field : 'appsys_code',
											direction : 'ASC'
										},
										baseParams : {
											start : 0,
											limit : 100,
											event_id:'${param.event_id}',
											device_ip:'${param.device_ip}'
											
										},
										listeners : {
										'load' : function(store){
											if(store.getCount() == 0){
												Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '没有相应的匹配工具',
													minWidth : 200,
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO
												});
											}
										}
										}
									});

							// 加载列表数据
							this.gridStore.load();
							// 实例化数据列表组件
							this.grid = new Ext.grid.GridPanel(
									{
										id : '${param.event_id}'+'Alarmtoolspanelid',
										
										region : 'center',
										border : false,
										loadMask : true,
										autoScroll : true,
										autoWeight : true,
										
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										store : this.gridStore,
										sm : csm,
										// 列定义
										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												 {

													header : '<fmt:message key="toolbox.alarm_event_id" />',
													align : 'center',
													dataIndex : 'event_id'
												 },
												
												 {
													 
												     header : '<fmt:message key="toolbox.diagnostic" />',
												     align : 'center',
												     renderer: this.renderDiagnosticDesc
												 },
												{
													header :'<fmt:message key="toolbox.appsys_code" />',
													dataIndex : 'appsys_code',
													renderer : this.appsys_Storeone,
													scope : this,
													sortable : true
												},
												{

													header : '<fmt:message key="toolbox.tool_name" />',
													dataIndex : 'tool_name',
													sortable : true

												},
												{
													header : '<fmt:message key="toolbox.shell_name" />',
													dataIndex : 'shell_name',
													sortable : true
												},
												 {

													header : '<fmt:message key="toolbox.alarm_device_ip" />',
													align : 'center',
													dataIndex : 'device_ip'
												 },
												{
													header :'<fmt:message key="toolbox.tool_authorize_flag" />',
													dataIndex : 'tool_authorize_flag',
													renderer : this.tool_authorize_flagone,
													scope : this,
													sortable : true
												},
												{
													header : '<fmt:message key="toolbox.field_type_one" />',
													dataIndex : 'field_type_one',
													scope : this,
													sortable : true

												},
												{
													header : '<fmt:message key="toolbox.field_type_two" />',
													dataIndex : 'field_type_two',
													scope : this,
													sortable : true

												},
												{
													header : '<fmt:message key="toolbox.field_type_three" />',
													dataIndex : 'field_type_three',
													scope : this,
													sortable : true

												}
												,
												{
													header : '<fmt:message key="toolbox.tool_status" />',
													dataIndex : 'tool_status',
													renderer : this.tool_statusone,
													scope : this,
													sortable : true

												},{
													header :'<fmt:message key="toolbox.tool_type" />',
													dataIndex : 'tool_type',
													renderer : this.toolType_Storeone,
													scope : this,
													sortable : true
												}/*,{
													header : '<fmt:message key="toolbox.tool_returnreasons" />',
													dataIndex : 'tool_returnreasons',
													sortable : true
												}
													{

													header : '<fmt:message key="toolbox.alarm_object" />',
													dataIndex : 'alarmobject',
													sortable : true

												},{
													header : '<fmt:message key="toolbox.alarm_componenttype" />',
													dataIndex : 'componenttype',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_component" />',
													dataIndex : 'component',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.server_ip" />',
													align : 'center',
													dataIndex : 'server_ip'
													
												}, {
													header : '<fmt:message key="toolbox.alarm_subcomponent" />',
													dataIndex : 'subcomponent',
													sortable : true
												}, {
													header : '<fmt:message key="toolbox.alarm_summarycn" />',
													dataIndex : 'summarycn',
													sortable : true
												}
												 ,{
													header : '<fmt:message key="toolbox.alarm_alarm_instance" />',
													dataIndex : 'alarminstance',
													sortable : true
												}, 
												
												{

													header : '<fmt:message key="toolbox.tool_code" />',
													dataIndex : 'tool_code',
													hidden:true,
													sortable : true

												},
												 {
													header : '<fmt:message key="toolbox.os_user" />',
													dataIndex : 'os_user',
													sortable : true
												}, */],
										// 定义按钮工具条										tbar : new Ext.Toolbar(
												{
													items : [
													         
													]
												}),
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
											displayInfo : true,
											pageSize : 100
										})
									});
							// 设置基类属性
							Alarmtoolspanel.superclass.constructor.call(this,
									{
								
										title:'${param.event_id}'+'匹配工具列表',
										layout : 'border',
										border : false,
										items : [  this.grid ]
									});
						},
						
						appsys_Storeone : function(value) {

							var index = this.appsys_Store.find('appsysCode', value);
							if (index == -1) {
								return value;
							} else {
								return this.appsys_Store.getAt(index).get('appsysName');
							}
						},
						
						toolType_Storeone : function(value) {

							var index = this.tool_typeStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return this.tool_typeStore.getAt(index).get('name');
							}
						},
						appsys_Storeone2 : function(value) {

							var index = this.appsys_Store.find('appsysName', value);
							if (index == -1) {
								return value;
							} else {
								return this.appsys_Store.getAt(index).get('appsysCode');
							}
						},
						authorize_level_typeone : function(value) {
							var index = this.authorize_level_typeStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return this.authorize_level_typeStore.getAt(index).get('name');
							}
						},
						tool_statusone : function(value) {

							var index = this.tool_statusStore.find('value', value);

							if (index == -1) {
								return value;
							} else {
								return this.tool_statusStore.getAt(index).get('name');
							}
						},
						tool_authorize_flagone : function(value) {

							var index = this.tool_authorize_flagStore.find('value', value);

							if (index == -1) {
								return value;
							} else {
								return this.tool_authorize_flagStore.getAt(index).get('name');
							}
						},
						 renderDiagnosticDesc : function(value, metadata, record, rowIndex, colIndex, store) {
							
							var event_id=record.get('event_id');
							 var str ="<input type='button' value= '执行' onclick = javascript:Diagnostic("+event_id+") >";
						     return str ;
						 },
						 renderevent_id: function(value, metadata, record, rowIndex, colIndex, store) {
							 
							  return '${param.event_id}' ;
							 },
					 
						//动态口令
						 doDynCancel : function() { 
							 Ext.getCmp('${param.event_id}'+'Alarm_Dyn_WinID').close();
							},
						doIsDynPassword : function() {
							//当前用户id
						    var Loaduser= Alarm_userNameStore.data.items[0].data.UName;
																
								if(Ext.getCmp('${param.event_id}'+'usercodeID').getValue()==Loaduser){
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '不允许当前用户对自己授权',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200
									});
								}else{
									AlarmDyn_user=Ext.getCmp('${param.event_id}'+'usercodeID').getValue();
									Ext.Ajax.request({
										method : 'POST',
										url : '${ctx}/${appPath}/ToolBoxController/isdynpassword',
										scope : this,
										success : Alarmtools.saveDynSuccess,
										params : {
											usercode : Ext.getCmp('${param.event_id}'+'usercodeID').getValue(),
											dynpassword : Ext.getCmp('${param.event_id}'+'dynpasswordID').getValue(),
											pinCode : Ext.getCmp('${param.event_id}'+'pinCodeID').getValue()
											
										}
									});
									
								}
							},
							// 验证成功回调
							saveDynSuccess : function(response, options) {
							
									
								if (Ext.decode(response.responseText).success == false) {
									var error = Ext.decode(response.responseText).error;
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="toolbox.checked.failed" /><fmt:message key="error.code" />:' + error,
										minWidth : 200,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
										
									});
								} else if (Ext.decode(response.responseText).success == true) {
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="toolbox.checked.successful" />',
										minWidth : 200,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										fn:function(btn){
											Ext.getCmp('${param.event_id}'+'Alarm_Dyn_WinID').close();
											var params = {
													//工具
													tool_code : AlarmDyn_tool_code ,
													appsys_code :AlarmDyn_appsys_code ,
													usercode : AlarmDyn_user,
													os_type : AlarmDyn_os_type,
													event_id    : Alarm_event_id,
													device_ip : Alarm_device_ip
													
											};
											
											if(Alarm_tool_type==1){
												AlarmTabspanel.loadTabAlarmTool(Alarm_event_id,Alarm_event_id+AlarmDyn_tool_code+'AlarmExe',AlarmDyn_tool_name+'<fmt:message key="toolbox.tool_exc" />','${ctx}/${appPath}/ToolBoxAlarmController/AlarmExc',params); 
											}
											if(Alarm_tool_type==2){
												
												AlarmTabspanel.loadTabAlarmTool(Alarm_event_id,Alarm_event_id+AlarmDyn_tool_code+'AlarmExe',AlarmDyn_tool_name+'<fmt:message key="toolbox.tool_exc" />','${ctx}/${appPath}/ToolBoxAlarmController/AlarmExcDesc',
														params);
											}
									 
										}
									});
								}
									
							}
						
					});
	var  Alarmtools=new Alarmtoolspanel();
	var AlarmTabspanel =new AlarmTabspanel();
	AlarmTabspanel.add(Alarmtools);
	AlarmTabspanel.setActiveTab(0);
	</script>
	
	<script type="text/javascript">
	var alarmwin=Ext.getCmp('${param.event_id}'+'tools');
	 Ext.getCmp('${param.event_id}'+'tools').window.get(0).add(AlarmTabspanel);
	   Ext.getCmp('${param.event_id}'+'tools').window.get(0).doLayout(); 
	    var handler = function(){
	    	Ext.getCmp('${param.event_id}'+'tools').destroy();
	    	Ext.getCmp('${param.event_id}'+'toolslist').destroy();
		   Ext.getCmp('${param.event_id}'+'toolslist').un('close', handler);
		};
		 Ext.getCmp('${param.event_id}'+'toolslist').on('close', handler); 
		 Ext.getCmp('${param.event_id}'+'toolslist').on('resizable', function(){
			 
		 }
); 
	/* Ext.getCmp("ALARM_TOOLS").add(Alarmtools);
	Ext.getCmp("ALARM_TOOLS").doLayout(); */
</script>

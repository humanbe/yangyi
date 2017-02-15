<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var alarmtreatedstarttime="";
var alarmtreatedstoptime="";

var Treated_componentStore;
var Treated_subcomponentStore;
//查看关联软件日志信息
function Alarmtreated_tools_logInfo(){
	var grid = Ext.getCmp("Alarmtreatedpanelid");
    var record = grid.getSelectionModel().getSelected();
    var params = {
   		event_id : record.data.event_id
 	};
 	//如果标签页存在,重载页面
 	var tab = Ext.getCmp("EVENTLOG");
 	if(tab){
 	}
 	app.loadTab('EVENTLOG' ,'<fmt:message key="toolbox.Tool_log" />','${ctx}/${appPath}/ToolBoxAlarmController/eventlog', params);
}

function DescView(){
	var grid = Ext.getCmp("Alarmtreatedpanelid");
	var record = grid.getSelectionModel().getSelected();
	var params = {
		event_id : record.data.event_id
	};
	app.loadWindow('${ctx}/${appPath}/ToolBoxAlarmController/alarmDescView', params);
}

var treated_handle_statusStore = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/HANDLE_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
	});
treated_handle_statusStore.load();

var treated_componenttype = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/COMPONENTTYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
treated_componenttype.load();
var treated_component = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/COMPONENT/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
treated_component.load();
var treated_subcomponent = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/SUBCOMPONENT/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
treated_subcomponent.load();
	
Alarmtreatedpanel = Ext.extend(
			Ext.Panel,
			{
				gridStore : null,// 数据列表数据源				grid : null,// 数据列表组件
				form : null,// 查询表单组件
				tabIndex : 0,// 查询表单      组件Tab键顺序				csm : null,// 数据列表选择框组件				constructor : function(cfg) {// 构造方法					Ext.apply(this, cfg);
					//禁止IE的backspace键(退格键)，但输入文本框时不禁止					Ext.getDoc().on('keydown',function(e) {
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

					//一级分类					this.Treated_componenttypeStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${appPath}/ToolBoxAlarmController/getEventone', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['componenttype'])
					});
					this.Treated_componenttypeStore.load();
					
					//二级分类
					Treated_componentStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${appPath}/ToolBoxAlarmController/getEventtwo', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['component'])
						
					});
					Treated_componentStore.on('beforeload',function(){
						Treated_componentStore.baseParams.componenttype = Ext.getCmp("AlarmTreatedcomponenttype").getValue();
					},this); 
					//三级分类
					Treated_subcomponentStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${appPath}/ToolBoxAlarmController/getEventthree', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['subcomponent'])
						
					});
					Treated_subcomponentStore.on('beforeload',function(){
						Treated_subcomponentStore.baseParams.componenttype = Ext.getCmp("AlarmTreatedcomponenttype").getValue();
						Treated_subcomponentStore.baseParams.component = Ext.getCmp("AlarmTreatedcomponent").getValue();
					},this); 
					
					this.EventStatusStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/EVENTSTATUS/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
					this.EventStatusStore.load();
					
					this.ManageByCenterStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/MANAGEBYCENTER/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
					this.ManageByCenterStore.load();
					
					this.MaintainStatusStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/MAINTAINSTATUS/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
					this.MaintainStatusStore.load();
					
					this.alarm_levelStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/ALARM_LEVEL/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
					this.alarm_levelStore.load();
					
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

					this.appsys_Store =  new Ext.data.Store({
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${appPath}/ToolBoxAlarmController/querySystemIDAndNamesForAlarm',
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
					
					// 实例化数据列表选择框组件					csm = new Ext.grid.CheckboxSelectionModel();

					// 实例化数据列表数据源
					this.gridStore = new Ext.data.JsonStore(
					{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								url : '${ctx}/${appPath}/ToolBoxAlarmController/treatedindex',
								disableCaching : false
							}),
							autoDestroy : true,
							root : 'data',
							totalProperty : 'count',
							fields : [ 'event_id', 'customerseverity',
										'device_id', 'device_ip',
										'alarmobject','componenttype',
										'component','subcomponent',
										'summarycn','eventstatus', 
										
										'first_time', 'last_time','shell_name',
										'instance','appname',
										'managebycenter','managebyuser', 
										'managetimeexceed', 'managetime',
										'maintainstatus','repeat_number',
										
										'mgtorg','orgname',
										'event_group','monitor_tool',
										'is_ticket','n_ticketid', 
										'ump_id', 'cause_effect',
										'parent_event_id','handle_status',
										
										'handle_user','handle_time_exceed',
										'close_time','result_summary'
								],
								remoteSort : false,
								sortInfo : {
									field : 'event_id',
									direction : 'ASC'
								},
								baseParams : {
									start : 0,
									limit : 100,
									AlarmTreatedStartTime: alarmtreatedstarttime,
									AlarmTreatedCompletedTime : alarmtreatedstoptime
								}
							});

							// 加载列表数据
							this.gridStore.load();
							// 实例化数据列表组件							this.grid = new Ext.grid.GridPanel(
									{
										id : 'Alarmtreatedpanelid',
										region : 'center',
										border : false,
										loadMask : true,
										autoScroll : true,
										autoWeight : true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										enableColumnHide:false,
										enableHdMenu : false, 
										store : this.gridStore,
										sm : csm,
										// 列定义										columns : [
												new Ext.grid.RowNumberer(),
												csm,
												{  
													header : '<fmt:message key="toolbox.View_log" />',
													align : 'center',
												    renderer: this.toolbox_viewlog
												},/* {
												    header : '<fmt:message key="toolbox.Alarm_information_desc" />',
												    align : 'center',
												    renderer: this.renderDescView
												}, */
												{
													header : '<fmt:message key="toolbox.alarm_event_id" />',
													dataIndex : 'event_id',
													sortable : true,
													renderer: this.viewEdit
												},
												{
													header : '<fmt:message key="toolbox.alarm_customerseverity" />',
													dataIndex : 'customerseverity',
													renderer: this.alarm_levelStoreone,
													scope : this,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_appname" />',
													dataIndex : 'appname',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_device_ip" />',
													dataIndex : 'device_ip',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_componenttype" />',
													dataIndex : 'componenttype',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_summarycn" />',
													dataIndex : 'summarycn',
													width:250,
													sortable : true,
													renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
													    //build the qtip:    
													    var title = "详细摘要：";
													    var tip = record.get('summarycn');    
													    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

													    //return the display text:    
													    var displayText =  record.get('summarycn') ;    
													    return displayText;    

													}
												},{
													header : '<fmt:message key="toolbox.alarm_first_time" />',
													dataIndex : 'first_time',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_last_time" />',
													dataIndex : 'last_time',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_repeat_number" />',
													dataIndex : 'repeat_number',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_orgname" />',
													dataIndex : 'orgname',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_mgtorg" />',
													dataIndex : 'mgtorg',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_component" />',
													dataIndex : 'component',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_subcomponent" />',
													dataIndex : 'subcomponent',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_event_group" />',
													dataIndex : 'event_group',
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_result_summary" />',
													dataIndex : 'result_summary',
													sortable : true
												},/* {
													header : '<fmt:message key="toolbox.match_tools_message" />',
													dataIndex : 'match_tools_message',
													sortable : true
												}, */{
													header : '<fmt:message key="toolbox.alarm_received_time" />',
													dataIndex : 'alarm_received_time',
													sortable : true
												}
												//以下字段不显示
												,{
													header : '<fmt:message key="toolbox.alarm_device_id" />',
													dataIndex : 'device_id',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_object" />',
													dataIndex : 'alarmobject',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_eventstatus" />',
													dataIndex : 'eventstatus',
													renderer: this.EventStatusStoreone,
													scope : this,
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_instance" />',
													dataIndex : 'alarminstance',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_managebycenter" />',
													dataIndex : 'managebycenter',
													renderer: this.ManageByCenterStoreone,
													scope : this,
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_managebyuser" />',
													dataIndex : 'managebyuser',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_managetimeexceed" />',
													dataIndex : 'managetimeexceed',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_managetime" />',
													dataIndex : 'managetime',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_maintainstatus" />',
													dataIndex : 'maintainstatus',
													renderer: this.MaintainStatusStoreone,
													scope : this,
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_monitor_tool" />',
													dataIndex : 'monitor_tool',
													hidden : true ,
													sortable : true
												},
												{
													header : '<fmt:message key="toolbox.alarm_is_ticket" />',
													dataIndex : 'is_ticket',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_n_ticketid" />',
													dataIndex : 'n_ticketid',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_ump_id" />',
													dataIndex : 'ump_id',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_cause_effect" />',
													dataIndex : 'cause_effect',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_parent_event_id" />',
													dataIndex : 'parent_event_id',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_handle_status" />',
													dataIndex : 'handle_status',
													renderer: this.ignored_handle_statusStoreone,
													scope : this,
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_handle_user" />',
													dataIndex : 'handle_user',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_handle_time_exceed" />',
													dataIndex : 'handle_time_exceed',
													hidden : true ,
													sortable : true
												},{
													header : '<fmt:message key="toolbox.alarm_close_time" />',
													dataIndex : 'close_time',
													hidden : true ,
													sortable : true
												}
									    ],
										// 定义分页工具条										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
											displayInfo : true,
											pageSize : 100
										})
									});
							this.form = new Ext.FormPanel(
									{
										id : 'AlarmtreatedFormIndex',
										region : 'east',
										title : '<fmt:message key="button.find" />',
										labelAlign : 'right',
										labelWidth : 100,
										buttonAlign : 'center',
										frame : true,
										split : true,
										width : 270,
										minSize : 270,
										maxSize : 300,
										autoScroll : true,
										collapsible : true,
										collapseMode : 'mini',
										border : false,
										defaults : {
											anchor : '90%',
											msgTarget : 'side'
										},
										// 定义查询表单组件
										items : [
												{
													xtype : 'combo',
													store : this.appsys_Store,
													fieldLabel :  '<fmt:message key="toolbox.appsys_code" />',
													name : 'appname',
													valueField : 'appsysName',
													displayField : 'appsysName',
													hiddenName : 'appname',
													mode : 'local',
													triggerAction : 'all',
													forceSelection : true,
													editable : true,
													tabIndex : this.tabIndex++,
													emptyText : '请选择系统代码...',
													listeners : {
														scope : this,
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
													xtype : 'datefield',
													id:'AlarmTreatedStartTimeID',
													fieldLabel : '<fmt:message key="property.execStartTime" />',
													name : 'AlarmTreatedStartTime',
													format : 'Ymd'
												},
												{
													xtype : 'datefield',
													id:'AlarmTreatedCompletedTimeID',
													fieldLabel : '<fmt:message key="property.execCompletedTime" />',
													name : 'AlarmTreatedCompletedTime',
													format : 'Ymd'
												},
												{xtype : 'combo',
													id:'AlarmTreatedcomponenttype',
													store :this.Treated_componenttypeStore,
													fieldLabel :  '<fmt:message key="toolbox.alarm_componenttype" />',
													name : 'componenttype',
													valueField : 'componenttype',
													displayField : 'componenttype',
													hiddenName : 'componenttype',
													mode : 'local',
													triggerAction : 'all',
													forceSelection : true,
													editable : true,
													tabIndex : this.tabIndex++,
													listeners : {
														//编辑完成后处理事件

														select : function(obj) {
															Ext.getCmp("AlarmTreatedcomponent").setValue('');
															Ext.getCmp("AlarmTreatedsubcomponent").setValue('');
															Treated_componentStore.load();
														}
													}
													},
													{xtype : 'combo',
														id:'AlarmTreatedcomponent',
														store : Treated_componentStore,
														fieldLabel :  '<fmt:message key="toolbox.alarm_component" />',
														name : 'component',
														valueField : 'component',
														displayField : 'component',
														hiddenName : 'component',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : true,
														tabIndex : this.tabIndex++,
														listeners : {
															//编辑完成后处理事件

															select : function(obj) {
																Ext.getCmp("AlarmTreatedsubcomponent").setValue('');
																Treated_subcomponentStore.load();
															}
														}
														},
														{xtype : 'combo',
															id:'AlarmTreatedsubcomponent',
															store : Treated_subcomponentStore,
															fieldLabel :  '<fmt:message key="toolbox.alarm_subcomponent" />',
															name : 'subcomponent',
															valueField : 'subcomponent',
															displayField : 'subcomponent',
															hiddenName : 'subcomponent',
															mode : 'local',
															triggerAction : 'all',
															forceSelection : true,
															editable : true,
															tabIndex : this.tabIndex++
															},
															{
																xtype : 'textfield',
																fieldLabel :  '<fmt:message key="toolbox.alarm_event_id" />',
																name : 'event_id',
																tabIndex : this.tabIndex++

															},
															{   xtype : 'combo',
																store :  this.alarm_levelStore,
																fieldLabel :  '<fmt:message key="toolbox.alarm_customerseverity" />',
																name : 'customerseverity',
																valueField : 'value',
																displayField : 'name',
																hiddenName : 'customerseverity',
																mode : 'local',
																triggerAction : 'all',
																forceSelection : true,
																editable : true,
																tabIndex : this.tabIndex++
																}

												

										],

										// 定义查询表单按钮
										buttons : [
												{
													text : '<fmt:message key="button.ok" />',
													iconCls : 'button-ok',
													tabIndex : this.tabIndex++,
													scope : this,
													handler : this.doFind
												},
												{
													text : '<fmt:message key="button.reset" />',
													iconCls : 'button-reset',
													tabIndex : this.tabIndex++,
													scope : this,
													handler : this.doReset
												} ]
									});
							// 设置基类属性
							Alarmtreatedpanel.superclass.constructor.call(this,
									{
										layout : 'border',
										border : false,
										items : [ this.form, this.grid ]
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
						
						treated_handle_statusStoreone: function(value) {
						var index = treated_handle_statusStore.find('value', value);
						if (index == -1) {
							return value;
						} else {
							return treated_handle_statusStore.getAt(index).get('name');
						}
					},
					
					EventStatusStoreone : function(value) {

						var index = this.EventStatusStore.find('value', value);
						if (index == -1) {
							return value;
						} else {
							return this.EventStatusStore.getAt(index).get('name');
						}
					},
					ManageByCenterStoreone : function(value) {

						var index = this.ManageByCenterStore.find('value', value);
						if (index == -1) {
							return value;
						} else {
							return this.ManageByCenterStore.getAt(index).get('name');
						}
					},
					MaintainStatusStoreone : function(value) {

						var index = this.MaintainStatusStore.find('value', value);
						if (index == -1) {
							return value;
						} else {
							return this.MaintainStatusStore.getAt(index).get('name');
						}
					},
					alarm_levelStoreone : function(value) {

						var index = this.alarm_levelStore.find('value', value);
						if (index == -1) {
							return value;
						} else {
							var as=this.alarm_levelStore.getAt(index).get('name');
							return as;
						}
					},
					
					viewEdit : function(value) {
						return '<a href="javascript:DescView()"><font color=green>'+value+'</font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
					
				   },
						
						 // 查看日志
						 toolbox_viewlog : function(value, metadata, record, rowIndex, colIndex, store) {
						  return '<a href="javascript:Alarmtreated_tools_logInfo()"><font color=red><fmt:message key="toolbox.View_log" /></font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
						 },
						 renderDescView : function(value, metadata, record, rowIndex, colIndex, store) {
							  return '<a href="javascript:DescView()"><font color=green><fmt:message key="toolbox.Alarm_information_desc" /></font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
							 },
						
						// 查询事件
						doFind : function() {
							Ext.apply(this.grid.getStore().baseParams,
									this.form.getForm().getValues());
							this.grid.getStore().on('beforeload',function(){
								//使用查询条件系统代码文本框时用
								this.grid.getStore().baseParams.AlarmTreatedStartTime =Ext.util.Format.date(Ext.getCmp("AlarmTreatedStartTimeID").getValue(),'Ymd');
								this.grid.getStore().baseParams.AlarmTreatedCompletedTime =Ext.util.Format.date(Ext.getCmp("AlarmTreatedCompletedTimeID").getValue(),'Ymd');
								},this); 
							this.grid.getStore().load();
						},
						// 重置查询表单
						doReset : function() {
							this.form.getForm().reset();
						}
						
						
					});
	
	var  Alarmtreated=new Alarmtreatedpanel();
	
	</script>

	<script type="text/javascript">
  
	Ext.getCmp("ALARM_TREATED").add(Alarmtreated);
	Ext.getCmp("ALARM_TREATED").doLayout();
</script>

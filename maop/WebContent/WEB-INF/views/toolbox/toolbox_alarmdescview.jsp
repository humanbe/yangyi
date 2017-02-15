<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var alarmView_handle_statusStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/HANDLE_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
alarmView_handle_statusStore.load();

var alarmView_componenttype = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/COMPONENTTYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
alarmView_componenttype.load();
var alarmView_component = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/COMPONENT/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
alarmView_component.load();
var alarmView_subcomponent = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/SUBCOMPONENT/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
alarmView_subcomponent.load();
alarmView = Ext.extend(Ext.Panel, {
	row : 0,// Tab键顺序
	
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性
                          this.alarm_levelVStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/ALARM_LEVEL/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.alarm_levelVStore.load();
					
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
			this.form = new Ext.FormPanel({
										buttonAlign : 'center',
										labelAlign : 'right',
										lableWidth : 15,
										autoHeight : true,
										frame : true,
										monitorValid : true,
										defaults : {
											anchor : '90%',
											msgTarget : 'side'
										},
										items :  [{
											layout:'column',
											items:[{
											     columnWidth:.5,
											     layout:'form',
											     items:[{
														xtype : 'textfield',
														fieldLabel :'<fmt:message key="toolbox.alarm_event_id" />',
														name : 'event_id',
														width:160,
														readOnly:true,
														tabIndex : this.tabIndex++
													

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_device_ip" />',
														readOnly:true,
														name : 'device_ip',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_componenttype" />',
														readOnly:true,
														name : 'componenttype',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_subcomponent" />',
														readOnly:true,
														name : 'subcomponent',
														tabIndex : this.tabIndex++

													},
													{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_first_time" />',
														readOnly:true,
														name : 'first_time',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_orgname" />',
														readOnly:true,
														name : 'orgname',
														tabIndex : this.tabIndex++
														

													}]
											},{
											     columnWidth:.5,
											     layout:'form',
											    
											     items:[{
														xtype : 'combo',
														
														store : this.alarm_levelVStore,
														fieldLabel : '<fmt:message key="toolbox.alarm_customerseverity" />',
														width:160,
														name : 'customerseverity',
														valueField : 'value',
														displayField : 'name',
														hiddenName : 'customerseverity',
														readOnly:true,
														tabIndex : this.tabIndex++
														
													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_appname" />',
														readOnly:true,
														name : 'appname',
														tabIndex : this.tabIndex++
														

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_component" />',
														readOnly:true,
														name : 'component',
														tabIndex : this.tabIndex++
														//allowBlank : false

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_last_time" />',
														readOnly:true,
														name : 'last_time',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_event_group" />',
														readOnly:true,
														name : 'event_group',
														tabIndex : this.tabIndex++

													},
													{
														xtype : 'textfield',
														width:160,
														fieldLabel :'<fmt:message key="toolbox.alarm_mgtorg" />',
														readOnly:true,
														name : 'mgtorg',
														tabIndex : this.tabIndex++

													}]
											}]
										},{
											xtype : 'textarea',
											fieldLabel : '<fmt:message key="toolbox.alarm_summarycn" />',
											name : 'summarycn',
											height : 65,
											maxLength:500,
											tabIndex : this.tabIndex++

										},{
											xtype : 'textarea',
											fieldLabel : '<fmt:message key="toolbox.alarm_result_summary" />',
											name : 'result_summary',
											height : 90,
											maxLength:500,
											tabIndex : this.tabIndex++

										}/* ,{
											 xtype: 'grid',
								              //  ds: ds,
								                cm: colModel,
								                sm:csm,
								                autoExpandColumn: 'company',
								                height: 350,
								                title:'Company Data',
								                border: true,
								                listeners: {
								                    viewready: function(g) {
								                    } // Allow rows to be rendered.
								                }
										} */ ]
											
									});
			
			
			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore(
			{
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${appPath}/ToolBoxAlarmController/alarm_business_data',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
			fields : ['event_id', 'business_id',
			          'appsys_code', 'business_impact_type',
						'business_impact_level', 
						'business_impact_content',
						'diagnostic_status','math_tool_num'
				],
				remoteSort : false,
				sortInfo : {
					field : 'business_impact_level',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100,
					event_id:'${param.event_id}'
					
				}
			});

			// 加载列表数据
			this.gridStore.load();
			
			this.grid = new Ext.grid.GridPanel(
					{
						border : true,
						height : 225,
						loadMask : true,
						region : 'center',
						border : false,
						loadMask : true,
						autoScroll : true,
						autoWeight : true,
						//autoHeight : true,
						title : '业务影响列表',
						columnLines : true,
						viewConfig : {
							forceFit : false
						},
						defaults : {
							//anchor : '90%',
							msgTarget : 'side'
						},
						enableColumnHide:false,
						enableHdMenu : false, 
						store : this.gridStore,
						// 列定义
						columns : [
							new Ext.grid.RowNumberer(),
							
							{
								header : '<fmt:message key="toolbox.alarm_event_id" />',
								dataIndex : 'event_id',
								sortable : true
							},
							{
								header : '<fmt:message key="toolbox.business_id" />',
								dataIndex : 'business_id',
								sortable : true
							},{
								header :'<fmt:message key="toolbox.appsys_code" />',
								dataIndex : 'appsys_code',
								renderer : this.appsys_Storeone,
								scope : this,
								sortable : true
							},{
								header : '<fmt:message key="toolbox.business_impact_type" />',
								dataIndex : 'business_impact_type',
								sortable : true
							},{
								header : '<fmt:message key="toolbox.business_impact_content" />',
								dataIndex : 'business_impact_content',
								sortable : true,
								renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
								    //build the qtip:    
								    var title = "详细内容：";
								    var tip = record.get('business_impact_content');    
								    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

								    //return the display text:    
								    var displayText =  record.get('business_impact_content') ;    
								    return displayText;    

								}
							},{
								header : '<fmt:message key="toolbox.business_impact_level" />',
								dataIndex : 'business_impact_level',
								sortable : true,
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '最高级' : return '<span style="color:red;">最高级</span>' ;
										case '高级' : return '<span style="color:orange;">高级</span>';
										case '中级' : return '<span style="color:brown;">中级</span>';
										case '低级' : return '<span style="color:black;">低级</span>';
									}
								}
							},{
								header : '<fmt:message key="toolbox.diagnostic_status" />',
								dataIndex : 'diagnostic_status',
								hidden:true,
								sortable : true
							},{
								header : '匹配工具数',
								dataIndex : 'math_tool_num',
								hidden:true,
								sortable : true
							}

						
					 	],
						// 定义按钮工具条
						tbar : new Ext.Toolbar(
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
			
			
			this.panelOne = new Ext.Panel({  
	            layout:'column',
	            autoScroll: true,
	            border:false,
	            items:[{
	                layout: 'form',
	                defaults: {anchor : '100%'},
	                border:false,
	                autoScroll : true,
	                labelAlign : 'right',
	                items: [ this.form ,this.grid]
	            }]
		    }); 
			
			
		
		alarmView.superclass.constructor.call(this, {
			layout : 'fit',
			buttonAlign : 'center',
			autoScroll : true,
			items : [this.panelOne ],
			buttons : [{
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose

			} ]
		});
		this.form.load(
				{
					url : '${ctx}/${appPath}/ToolBoxAlarmController/editview',
					method : 'POST',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					success : this.loadSuccess,
					failure : this.loadFailure,
					params:{
						event_id :'${param.event_id}'
					}
				}
				);
		
	},
	appsys_Storeone : function(value) {

		var index = this.appsys_Store.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return this.appsys_Store.getAt(index).get('appsysName');
		}
	},
	doClose : function() {
		 app.closeWindow();
		 
		}


});
var alarmView = new alarmView();

app.window.get(0).add(alarmView);
app.window.get(0).doLayout();
</script>
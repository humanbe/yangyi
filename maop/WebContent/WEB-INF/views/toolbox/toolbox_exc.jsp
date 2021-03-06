<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

	var NUM;
	//服务器列表字段信息	var fieldsServer = Ext.data.Record.create([
		{name: 'server_route', mapping : 'server_route', type : 'string'}, 
		{name: 'server_ip', mapping : 'server_ip', type : 'string'}
	]);
	
	//定义列表
	toolBoxExc = Ext.extend(Ext.Panel,
					{
						id:'${param.tool_code}'+'EXEVIEW',
						window : null,
						csmMoveServers:null,
						tool_gridMoveServers:null,
						formUser:null,
						selectIP:null,
						tabIndex : 0,// 查询表单组件Tab键顺序
						
						constructor : function(cfg) {// 构造方法							Ext.apply(this, cfg);
							this.csmMoveServers = new Ext.grid.CheckboxSelectionModel();
							this.csmMovedServers = new Ext.grid.CheckboxSelectionModel();
							
							
							
							this.position_typeStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOL_POSITION_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.position_typeStore.load();
							this.server_group_flag = new Ext.data.JsonStore({
								url : '${ctx}/${frameworkPath}/item/GROUP_SERVER_FLAG/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.server_group_flag.load();
							this.ServerGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.ServerGroupStore.load();
							this.os_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.os_typeStore.load();
							this.toolcharsetStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_CHARSET/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.toolcharsetStore.load();
							this.NUMstore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/NUM/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.NUMstore.load();
							this.appsys_Store =  new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])/* ,
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
								} */
							});
							this.appsys_Store.load();
							this.os_user_flagStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOLBOX_OS_USER_FLAG/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.os_user_flagStore.load();
							
							this.getOsuser_Store = new Ext.data.Store(
							{
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/ToolBoxController/getOs_user', 
									method: 'POST'
								}),
								reader: new Ext.data.JsonReader({}, ['osUser']),
								baseParams:{
									appsys_code : '${param.appsys_code}'
								}
							});
						//	this.getOsuser_Store.load();
							
							this.ParamTypeStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/PARAM_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.ParamTypeStore.load();

							this.ParamgridExcStore = new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									url : '${ctx}/${appPath}/ToolBoxParamController/view',
									disableCaching : false
								}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'tool_code', 'appsys_code',
										'param_name', 'param_desc',
										'param_type', 
										'param_length', 'param_format',
										'param_value',
										'param_default_value' ],
								pruneModifiedRecords : true,
								baseParams : {
									start : 0,
									limit : 20,
									tool_code :'${param.tool_code}',
									appsys_code:'${param.appsys_code}'
									
								}
							});

							// 加载列表数据
							this.ParamgridExcStore.load();
							csm = new Ext.grid.CheckboxSelectionModel();
							
							// 定义左侧可选服务器组件--------------------------------------begin
							this.tool_gridMoveServerStore=new Ext.data.JsonStore({
								proxy : new Ext.data.HttpProxy( {
									method : 'POST',
									url : '${ctx}/${appPath}/ToolBoxServerController/view',
									disableCaching : false
								}),
							    autoDestroy : true,
								root : 'data3',
								totalProperty : 'count',
								fields : [ 'appsys_code','server_route', 'os_user','server_ip','server_name' ],
									pruneModifiedRecords : true,
									remoteSort : true,
									baseParams : {
										start : 0,
										limit : 20,
										tool_code :'${param.tool_code}',
										appsys_code:'${param.appsys_code}',
										os_type:'${param.os_type}',
										ip : '',
										app: ''
										
									}
							});
							
							this.tool_gridMoveServerStore.load(); 
							
							
							this.tool_gridMoveServers = new Ext.grid.GridPanel({
								id : 'moveServersGrid'+'${param.tool_code}',
								height : 250 ,
								loadMask : true,
								frame : true,
								title : '<fmt:message key="toolbox.selectable_server" />',
								region : 'center',
								border : false,
								autoScroll : true,
								columnLines : true,
								viewConfig : {
									forceFit : true
								},
								/* hideHeaders:true,  */
								store : this.tool_gridMoveServerStore,
								autoExpandColumn : 'name',
								sm : this.csmMoveServers,   
								columns : [this.csmMoveServers,  
					            {
									//header : '<fmt:message key="toolbox.server_route" />',
									dataIndex : 'server_route',
									hidden : true,   
									hideable : false 
								},{
									//header : '<fmt:message key="toolbox.os_user" />',
									name:'os_user',
									dataIndex : 'os_user',
									hidden : true,   
									hideable : false 
								},{
									header : '<fmt:message key="toolbox.server_ip" />',
									dataIndex : 'server_ip',
									sortable : true
								},{
									header : '<fmt:message key="property.serverName" />',
									dataIndex : 'server_name',
									sortable : true
								}],
								
								
								// 定义数据列表监听事件
								listeners : {
									scope : this,
									// 行双击移入事件
									rowdblclick : function(row,rowIndex,e){
										var curRow = this.tool_gridMoveServerStore.getAt(rowIndex);
										var server_route = curRow.get("server_route");
										var os_user = curRow.get("os_user");
										var server_ip = curRow.get("server_ip");
										var notEqualFlag = true;
										this.excgridMovedServers.getStore().each(function(rightRecord){
											if(server_route==rightRecord.data.server_route && os_user==rightRecord.data.os_user
													&& server_ip==rightRecord.data.server_ip){
												notEqualFlag = false;
											}
										},this);
										if(notEqualFlag){
											this.excgridMovedServers.store.add(curRow);
										}
										var ips = [] ;
										this.excgridMovedServers.getStore().each(function(rightRecord){
									    		ips.push(rightRecord.get('server_ip'));
									    	
										},this);
										
								    	this.getOsuser_Store.baseParams.serverips = ips; 
								    	this.getOsuser_Store.reload();
								    	
								    	Ext.getCmp('osUserID'+'${param.tool_code}').setValue("");
									}
								},
								tbar : new Ext.Toolbar( {
									items : [  '-' , {
										xtype : 'combo',
										id:'appsys_code_tbarExe'+'${param.tool_code}',
										width:130,
										fieldLabel : '<fmt:message key="property.appsystemname" />',
										store :this.appsys_Store,
										name : 'appsysName',
										valueField : 'appsysCode',
										displayField : 'appsysName',
										hiddenName : 'appsys_code',
										mode: 'local',
										forceSelection : true,
										emptyText : '选择系统代码',
										typeAhead: true,
										hidden :  '${param.appsys_code}'!='COMMON'?true:false,
									    triggerAction: 'all',
										tabIndex : this.tabIndex++,
										listeners : {
											 'beforequery' : function(e){
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
												}/* ,
												'select' : function(obj){
													var store = Ext.getCmp('moveServersGrid'+'${param.tool_code}').getStore();
													store.baseParams.app=obj.value;
													alert(obj.value);
													//store.reload();											
												} */
										}
									},'-',{
										xtype : 'textfield',
										width:90,
										fieldLabel : '<fmt:message key="property.serverIp" />',
										name : 'Ip',
										emptyText : '服务器IP',
										tabIndex : this.tabIndex++,
										listeners : {
											
											'change': function(obj,newvalue,oldvalue) {
												var store = Ext.getCmp('moveServersGrid'+'${param.tool_code}').getStore();
												store.baseParams.ip=newvalue;
												
												//store.reload();	
												}
											}
										},'-',{
											text : '查询',
											iconCls : 'button-ok',
											scope : this,
											handler : this.findIp
										}
										
									]
								})
							}); 
							// 定义左侧可选服务器组件--------------------------------------end
							
							// 定义中间移入移出按钮------------------------------------------begin
							this.Panel = new Ext.Panel({
								//id : 'serverPanel',
								height : 250 ,
								labelAlign : 'right',
								buttonAlign : 'center',
								frame : true,
								split : true,
								defaults:{margins:'0 0 10 0'},
								xtype:'button',
						        layout: {
						        	type:'vbox',
						        	padding:'10',
						        	pack:'center',
						        	align:'center' 
						        },
						        
						        items:[{
						             xtype:'button',
						             width : 40 ,
						             height : 25 ,
						             text: '<fmt:message key="toolbox.shift_in" />',
						             scope : this,
						 			 handler : this.serverShiftIn
						         },{
						             xtype:'button',
						             width : 40 ,
						             height : 25 ,
						             text: '<fmt:message key="toolbox.shift_out" />',
						             scope : this,
						             handler : this.serverShiftOut
						         }]
							});
							// 定义中间移入移出按钮------------------------------------------end
							
							// 定义组件页签右侧列表组件--------------------------------------begin
							this.gridMovedServersStore=new Ext.data.JsonStore({
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'appsys_code','server_route', 'os_user','server_ip','server_name'],
								remoteSort : true,
								baseParams : {
									start : 0,
									limit : 10
								}
							});
							this.excgridMovedServers = new Ext.grid.GridPanel({
								id : 'movedServersGrid'+'${param.tool_code}',
								height : 250,
								loadMask : true,
								frame : true,
								title :'<fmt:message key="toolbox.selected_server" />',
								region : 'center',
								border : false,
								autoScroll : true,
								columnLines : true,
								viewConfig : {
									forceFit : true
								},
								/* hideHeaders:true,  */
								store : this.gridMovedServersStore,
								autoExpandColumn : 'name',
								sm : this.csmMovedServers, 
								columns : [this.csmMovedServers, 
								           {
									header : '<fmt:message key="toolbox.server_route" />',
									dataIndex : 'server_route',
									hidden : true
								},{
									header : '<fmt:message key="toolbox.os_user" />',
									dataIndex : 'os_user',
									hidden : true
								},{
									header : '<fmt:message key="toolbox.server_ip" />',
									dataIndex : 'server_ip'
								},{
									header : '<fmt:message key="property.serverName" />',
									dataIndex : 'server_name',
									sortable : true,
									hidden : true
								}],
								tbar : ['-'],
								// 定义数据列表监听事件
								listeners : {
									scope : this,
									// 行双击移出事件
									rowdblclick : function(row,rowIndex,e){
									
										var curRow = this.gridMovedServersStore.getAt(rowIndex);
										this.excgridMovedServers.store.remove(curRow);
										var ips = [] ;
										this.excgridMovedServers.getStore().each(function(rightRecord){
									    		ips.push(rightRecord.get('server_ip'));
										},this);
										
								    	this.getOsuser_Store.baseParams.serverips = ips; 
								    	this.getOsuser_Store.reload();
								    	Ext.getCmp('osUserID'+'${param.tool_code}').setValue("");
									}
								}
							}); 
							// 定义组件页签右侧列表组件--------------------------------------end
                             
						
							this.tool_gridMoveServerStore.on('load',function(){
								//获取指定服务器用户
								
								var server_record=this.tool_gridMoveServers.getStore().getAt(0);
								
								if( typeof server_record !='undefined'){
								var Server_osUser=server_record.data['os_user'];
								
								    Ext.getCmp('server_os_user'+'${param.tool_code}').setValue(Server_osUser);
                               
								}
								},this);
							this.form = new Ext.FormPanel({
										//id : 'formedit',
										title : '<fmt:message key="toolbox.tool_properties" />',
										region : 'north',
										labelAlign : 'right',
										labelWidth : 160,
										defaults:{margins:'10 0 10 0'},
										buttonAlign : 'center',
										frame : false,
										split : false,
										autoScroll : true,
										collapsible : true,
										collapseMode : 'mini',
										border : false,
										url : '${ctx}/${appPath}/ToolBoxController/edit',
										defaults : {
											anchor : '86%',
											msgTarget : 'side'
										},
										monitorValid : false,
										// 定义表单组件
										items : [{
											layout:'column',
											items:[{
											     columnWidth:.5,
											     layout:'form',
											     items:[{
														xtype : 'combo',
														store : this.appsys_Store,
														fieldLabel :'<fmt:message key="toolbox.appsys_code" />',
														id:'appsys_code_Exe'+'${param.tool_code}',
														name : 'appsys_code',
														valueField : 'appsysCode',
														displayField : 'appsysName',
														hiddenName : 'appsys_code',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														tabIndex : this.tabIndex++,
														anchor : '100%',
														allowBlank : false
												    },{
														xtype : 'textfield',
														id : 'tool_nameid'+'${param.tool_code}',
														fieldLabel : '<fmt:message key="toolbox.tool_name" />',
														style  : 'background : #F0F0F0' , 
														name : 'tool_name',
														anchor : '100%',
														readOnly : true,
														tabIndex : this.tabIndex++,
														allowBlank : false

													},{
														xtype : 'textfield',
														fieldLabel :'<fmt:message key="toolbox.shell_name" />',
														name : 'shell_name',
														id : 'shell_name_exc'+'${param.tool_code}',
														tabIndex : this.tabIndex++,
														readOnly : true,
														anchor : '100%',
														style  : 'background : #F0F0F0' , 
														allowBlank : false
													},{
														xtype : 'combo',
														store : this.os_user_flagStore,
														fieldLabel : '<fmt:message key="toolbox.os_user_flag" />',
														id:'os_user_flagExc'+'${param.tool_code}',
														name : 'os_user_flag',
														valueField : 'value',
														displayField : 'name',
														hiddenName : 'os_user_flag',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														hidden:false,
														readOnly : true,
														anchor : '100%',
														style  : 'background : #F0F0F0' , 
														editable : false,
														tabIndex : this.tabIndex++
													},{
			    										xtype : 'combo',
			    										store : this.server_group_flag,
			    										fieldLabel :'<fmt:message key="toolbox.group_server_flag" />',
			    										id:'group_server_flag_Exc'+'${param.tool_code}',
			    										name : 'group_server_flag',
			    										valueField : 'value',
			    										displayField : 'name',
			    										hiddenName : 'group_server_flag',
			    										mode : 'local',
			    										anchor : '100%',
			    										triggerAction : 'all',
			    										forceSelection : true,
			    										hidden:true,
			    										style  : 'background : #F0F0F0' , 
			    										editable : false,
			    										tabIndex : this.tabIndex++
			    										
			    									},
			    									
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="toolbox.os_user" />',
														id:'group_os_user'+'${param.tool_code}',
														name : 'os_user',
														anchor : '100%',
														readOnly : true,
														style  : 'background : #F0F0F0' , 
														//hidden:true,
														tabIndex : this.tabIndex++
													
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="toolbox.os_user" />',
														id:'server_os_user'+'${param.tool_code}',
														name : 'os_user',
														readOnly : true,
														anchor : '100%',
														//emptyText:Server_osUser,
														//hidden:true,
														tabIndex : this.tabIndex++
													
													}]
											},{
											     columnWidth:.5,
											     layout:'form',
											    
											     items:[{
														xtype : 'combo',
														store : this.os_typeStore,
														fieldLabel :'<fmt:message key="toolbox.os_type" />',
														name : 'os_type',
														id:'os_type_exc'+'${param.tool_code}',
														valueField : 'value',
														displayField : 'name',
														hiddenName : 'os_type',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														editable : false,
														readOnly:true,
														anchor : '100%',
														style  : 'background : #F0F0F0' , 
														//hidden:true,
														tabIndex : this.tabIndex++,
														allowBlank : false
													},{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="toolbox.field_type_one" />',
														name : 'field_type_one',
														//hidden:true,
														tabIndex : this.tabIndex++,
														anchor : '100%',
														style  : 'background : #F0F0F0' , 
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
														name : 'field_type_two',
														//hidden:true,
														tabIndex : this.tabIndex++,
														anchor : '100%',
														style  : 'background : #F0F0F0' , 
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
														name : 'field_type_three',
														//hidden:true,
														tabIndex : this.tabIndex++,
														style  : 'background : #F0F0F0' , 
														anchor : '100%',
														readOnly : true
													}]
											}]
										},{
    										xtype : 'combo',
    										store : this.ServerGroupStore,
    										fieldLabel :'<fmt:message key="toolbox.server_group" />',
    										id:'server_group_Exc'+'${param.tool_code}',
    										name : 'server_group',
    										valueField : 'value',
    										displayField : 'name',
    										hiddenName : 'server_group',
    										mode : 'local',
    										triggerAction : 'all',
    										forceSelection : true,
    										editable : false,
    										style  : 'background : #F0F0F0' , 
    										hidden:true,
    										tabIndex : this.tabIndex++,
    										allowBlank : false
    										 
    									},{
											xtype : 'textfield',
											id : 'tool_codeid'+'${param.tool_code}',
											fieldLabel : '<fmt:message key="toolbox.tool_code" />',
											name : 'tool_code',
											hidden:true,
											style  : 'background : #F0F0F0' , 
											tabIndex : this.tabIndex++,
											readOnly : true,
											allowBlank : false
										},{
											xtype : 'combo',
											store : this.position_typeStore,
											fieldLabel : '<fmt:message key="toolbox.position_type" />',
											name : 'position_type',
											id:'position_type_exc'+'${param.tool_code}',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'position_type',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											readOnly : true,
											style  : 'background : #F0F0F0' , 
											hidden:true,
											tabIndex : this.tabIndex++,
											allowBlank : false
										},{
											xtype : 'htmleditor',
											fieldLabel :'<fmt:message key="toolbox.tool_desc" />',
											name : 'tool_desc',
											
											enableSourceEdit:false,
											enableFontSize:false,
											enableAlignments:false,
											enableFont:false,
											enableLists:false,
											enableColors:false,
											enableFormat : false,	
											enableLinks:false,
											height : 120,
											maxLength:660,
											readOnly:true,
											tabIndex : this.tabIndex++

										},
										{
											xtype : 'combo',
											store : this.toolcharsetStore,
											fieldLabel : '<fmt:message key="toolbox.tool_charset" />',
											id:'tool_charset_Exc'+'${param.tool_code}',
											name : 'tool_charset',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'tool_charset',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											hidden:true,
											tabIndex : this.tabIndex++,
											allowBlank : false
										} ]
											
											
										

							});
							
							// 加载表单数据
							this.form.load({
								url : '${ctx}/${appPath}/ToolBoxController/dblview',
								method : 'POST',
								waitTitle : '<fmt:message key="message.wait" />',
								waitMsg : '<fmt:message key="message.loading" />',
								scope : this,
								success : this.loadSuccess,
								failure : this.loadFailure,
								params:{
									tool_code :'${param.tool_code}',
									appsys_code:'${param.appsys_code}'
								}
							});
							
							var param_edit = new Ext.form.TextField({maxLength:100});

							// 实例化数据列表组件							this.ParamgridExc = new Ext.grid.EditorGridPanel({
										//id : 'toolBoxParampanelid',
										region : 'center', 
										border : true,
										height:120,
										loadMask : true,
										columnLines : true,
										viewConfig : {
											forceFit : true
										},
										defaults : {
											anchor : '85%',
											msgTarget : 'side'/* ,
											bodyStyle:'padding-left:60px' */
										},
									
										store : this.ParamgridExcStore,
										frame : true,
										// 列定义										columns : [ 
										{
											header :  '<fmt:message key="toolbox.param_name" />',
											dataIndex : 'param_name',
											allowBlank : false
										}, {
											header : '<fmt:message key="toolbox.param_default_value" />',
											
											dataIndex : 'param_value',
											editor : param_edit
										}, {
											header : '<fmt:message key="toolbox.param_default_value" />',
											dataIndex : 'param_default_value',
											hidden : true,
		          							hideable : false
										},{
											header :'<fmt:message key="toolbox.param_format" />',
											dataIndex : 'param_format'
										},{
											header :'<fmt:message key="toolbox.param_desc" />',
											width:200,
											dataIndex : 'param_desc',
											renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
											    //build the qtip:    
											    var title = "详细描述：";
											    var tip = record.get('param_desc');    
											    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

											    //return the display text:    
											    var displayText =  record.get('param_desc') ;    
											    return displayText;    

											}
											
										}, {
											header : '<fmt:message key="toolbox.param_type" />',
											dataIndex : 'param_type',
											renderer : this.ParamTypeone,
											hidden : true ,
											scope : this
										}, {
											header :'<fmt:message key="toolbox.param_length" />',
											dataIndex : 'param_length',
											hidden : true 
										}],

										// 定义数据列表监听事件
										listeners : {
											'afteredit' : function(e) {
												if(e.field == 'param_value'){
													var putVal = e.record.get('param_value');
													
													if(e.record.get('param_type')==2){
														if(putVal.search(/^\d+$/)==-1){
															Ext.Msg.show( {
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="toolbox.input_correct_integer" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.WARNING,
																minWidth : 200
															}); 
															e.record.set('param_value',"");
															e.record.set('param_default_value',"");
														}
														e.record.set('param_default_value',putVal);
													}
													//日期YYYYMMDD
													if(e.record.get('param_type')==3){
														  var isdate = new RegExp("^(?:(?!0000)[0-9]{4}(?:(?:0?[1-9]|1[0-2])(?:0?[1-9]|1[0-9]|2[0-8])|(?:0?[13-9]|1[0-2])(?:29|30)|(?:0?[13578]|1[02])31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)0?229)$");

														if(!isdate.test(putVal)){
															Ext.Msg.show( {
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="toolbox.input_correct_date" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.WARNING,
																minWidth : 200
															}); 
															e.record.set('param_value',"");
															e.record.set('param_default_value',"");
														} 
														e.record.set('param_default_value',putVal);
													}
													//时间HHMM
													if(e.record.get('param_type')==4){
														var istime = new RegExp("^\[0-2]{1}\[0-4]{1}\[0-5]{1}\[0-9]{1}$");
														if(!istime.test(putVal)){
															Ext.Msg.show( {
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="toolbox.input_correct_time" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.WARNING,
																minWidth : 200
															}); 
															e.record.set('param_value',"");
															e.record.set('param_default_value',"");
														}
														e.record.set('param_default_value',putVal);
													}
													if(e.record.get('param_type')==5){
														
														var isIp=new RegExp("^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$");
										    			if(!isIp.test(putVal)){
										    				Ext.Msg.show( {
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="toolbox.toolinput_correct_ip" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.WARNING,
																minWidth : 200
															}); 
														e.record.set('param_value',"");
														e.record.set('param_default_value',"");
										    		}
										    			e.record.set('param_default_value',putVal);
												}
													if(e.record.get('param_type')==6){		
														e.record.set('param_value',"******");
														e.record.set('param_default_value',putVal);
												  }
													if(e.record.get('param_type')==1){		
														
														e.record.set('param_default_value',putVal);
												  }
													if(e.record.get('param_type')!=6){
														e.record.set('param_default_value',e.record.get('param_value'));
														}
												};
												
										}
										}
									});
							this.formUser = new Ext.FormPanel({
								region : 'north',
								labelAlign : 'right',
								labelWidth : 160,
								buttonAlign : 'center',
								collapseMode : 'mini',
								border : false,
								defaults : {
									anchor : '86%',
									msgTarget : 'side'
								},
								monitorValid : false,
								// 定义表单组件
								items : [{
									xtype : 'combo',
									store : this.getOsuser_Store,
									fieldLabel : '<fmt:message key="toolbox.os_user" />',
									id:'osUserID'+'${param.tool_code}',
									name : 'osUser',
									valueField : 'osUser',
									displayField : 'osUser',
									hiddenName : 'osUser',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++,
									listeners : {
										//编辑完成后处理事件
										select : function(obj) {
											if('1'==Ext.getCmp('os_user_flagExc'+'${param.tool_code}').getValue()){
												Ext.Msg.show( {
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="toolbox.check_Exc_osuser" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.INFO,
													minWidth : 200
												});
												Ext.getCmp('osUserID'+'${param.tool_code}').setValue("");
											}
										}
									}
							    }]
					});
							
	//重新Windows窗口方法
				this.window=new Jeda.ui.Window({
					
					plain : true,
					 modal:false,
					 resizable : false,
					 closeAction : 'close',
					 closable : true,
					 doLoad : function(cfg) {
							this.removeAll();
							this.add({
								id : 'window'+'${param.tool_code}',
							//	title : Ext.getCmp('tool_nameid'+'${param.tool_code}').getValue(),
								autoScroll : true,
								layout : 'fit',
								border : false,
								autoLoad : {
									url : cfg.url,
									params : cfg.params,
									discardUrl : false,
									nocache : true,
									timeout : 3000,
									method : 'GET',
									scripts : true
								}
							});
							this.doLayout();
							if (!this.isVisible()) {
								this.show();
							}
						}
				});
					
						// 设置基类属性						toolBoxExc.superclass.constructor.call(this,{
							layout : 'form',
							border : false,
							buttonAlign : 'center',
							frame : true,
							autoScroll : true,
							monitorValid : true,
							defaults : {
								anchor : '100%',
								msgTarget : 'side'
							},
							items : [ this.form,{
					                    	layout:'column',
							                border : true ,
							                items:[{
							                    columnWidth:.16,  
							                    layout: 'form',
							           			labelWidth:160,
							           			labelAlign : 'right',
							                    border : false,
							                    items : [{
							                    	xtype: 'label',
							        	         	fieldLabel: '<fmt:message key="toolbox.select_server" />'
							        	         }]
							                },{
							                    columnWidth:.3,  
							                    border : false,
							                    defaults : { flex : 1 },
							                    layoutConfig : { align : 'stretch' },
							                    items : [this.tool_gridMoveServers]
							                },{
							                    columnWidth:.1,
							                    border:false,
							                    labelAlign : 'right',
							                    items: [this.Panel]
							                } ,{
							                    columnWidth:.3,
							                    border:false,
							                    layout: 'form',
							                    defaults : { flex : 1 },
							                    layoutConfig : { align : 'stretch' },
							                    items: [this.excgridMovedServers] 
							                }]
					                    },{
					                    	layout:'column',
							                border : true ,
							                items:[{
							                	columnWidth:.16,  
							                    layout: 'form',
							           			labelWidth:160,
							           			labelAlign : 'right',
							                    border : false,
							                    items : [{
							                    	xtype: 'label',
							        	         	fieldLabel:'<fmt:message key="toolbox.param_input" />'
							        	         }]
							                },{
							                    columnWidth:.7,  
							                    layout:'form',
							                    border : false,
							                    defaults : { flex : 1 },
							                    layoutConfig : { align : 'stretch' },
							                    items : [this.ParamgridExc]
							                }]
					                    },this.formUser
						    ],
						    
							// 定义按钮
							buttons : [{
								text :'<fmt:message key="toolbox.tool_exc" />',
								iconCls : 'button-save',
								tabIndex : this.tabIndex++,
								scope : this,
								handler : this.doExc
							},{
								text : '<fmt:message key="button.cancel" />',
								iconCls : 'button-cancel',
								tabIndex : this.tabIndex++,
								handler : this.doCancel

							}]
							
						});
						},

						doExc : function() {
							//获取已选择的服务器----begin
							var records = this.excgridMovedServers.getStore();
							var servermaps = [];
							records.each(function(item) {
								servermaps.push(item.data);
							});
							
							var serverips=Ext.util.JSON.encode(servermaps);
							//获取已选择的服务器----end
							
							var paramStoreServer = this.ParamgridExc.getStore();
							
							var jsonParamExc = [];
							paramStoreServer.each(function(item) {
								jsonParamExc.push(item.data);
							});
							var params = {
								//工具
								toolcode : Ext.getCmp('tool_codeid'+'${param.tool_code}').getValue(),
								appsyscode : Ext.getCmp('appsys_code_Exe'+'${param.tool_code}').getValue(),
								shellname : Ext.getCmp('shell_name_exc'+'${param.tool_code}').getValue(),
								position_type: Ext.getCmp('position_type_exc'+'${param.tool_code}').getValue(),
								os_type: Ext.getCmp('os_type_exc'+'${param.tool_code}').getValue(),
								//用户
								group_osuser : Ext.getCmp('group_os_user'+'${param.tool_code}').getValue(),
								osuser:Ext.getCmp('osUserID'+'${param.tool_code}').getValue(),
								usercode:'${param.usercode}',
								event_id :'${param.event_id}',
								//参数
								serverGroup:Ext.getCmp('server_group_Exc'+'${param.tool_code}').getValue(),
								toolcharset:Ext.getCmp('tool_charset_Exc'+'${param.tool_code}').getValue(),
								paramdata : encodeURIComponent(Ext.util.JSON.encode(jsonParamExc)),
								serverips : encodeURIComponent(serverips)
							};
							
							var serversize = 0;
							if(servermaps!=""){
								serversize = serverips.split('},{').length ;
							}
							var sname=Ext.getCmp('shell_name_exc'+'${param.tool_code}').getValue();
							var shname=sname.substring(sname.lastIndexOf('.') + 1);	
						    if(shname.toLowerCase() == 'sh'&&Ext.getCmp('os_user_flagExc'+'${param.tool_code}').getValue()==0&&Ext.getCmp('osUserID'+'${param.tool_code}').getValue()==""){

								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.select_osuser" />',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									minWidth : 200
								});
								return false ;
						    }
						     
						    if(this.ParamgridExc.getStore().getCount() > 0){
						    	var flag=true;
						    	this.ParamgridExc.getStore().each(function(record){
						    		if(record.get('param_value')==null||record.get('param_value').trim()==""){
						    			Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '参数值不可为空',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										});
						    			flag =false ;
						    		}
									
								},this);
						    	if(flag==false) return;
							} 
						
						 
								
				            NUM=this.NUMone("1");
							if (serversize>0 && serversize <= NUM) {
								//app.loadWindow('${ctx}/${appPath}/ToolBoxController/exction',params); 
								  this.window.doLoad({
									url : '${ctx}/${appPath}/ToolBoxController/exction',
									params : params
								});  
							} else {
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.select_again" />'+NUM+'<fmt:message key="toolbox.num_server" />',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									minWidth : 200
								});
							}
						},
						
						
						position_typeone : function(value) {
							var index = this.position_typeStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return this.position_typeStore.getAt(index).get('name');
							}
						},
						
						NUMone : function(value) {
							var index = this.NUMstore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return this.NUMstore.getAt(index).get('name');
							}
						},
						ParamTypeone : function(value) {
							var index = this.ParamTypeStore.find('value', value);
							if (index == -1) {
								return value;
							} else {
								return this.ParamTypeStore.getAt(index).get('name');
							}
						},

						// 查询事件
						findIp : function() {
							Ext.getCmp('moveServersGrid'+'${param.tool_code}').getStore().baseParams.app=Ext.getCmp('appsys_code_tbarExe'+'${param.tool_code}').getValue();
							Ext.getCmp('moveServersGrid'+'${param.tool_code}').getStore().reload();
							
							
						},
						// 数据加载失败回调
						loadFailureServer : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:'
												+ error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						},
						// 数据加载失败回调
						loadFailure : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						},
						loadSuccess : function(form, action) {
							var sname=Ext.getCmp('shell_name_exc'+'${param.tool_code}').getValue();
							var shname=sname.substring(sname.lastIndexOf('.') + 1);	
						    if(shname.toLowerCase() != 'bat'){
							
							if(Ext.getCmp('os_user_flagExc'+'${param.tool_code}').getValue()==0){
								Ext.getCmp('os_user_flagExc'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('group_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('server_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('osUserID'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(true);
							};
							if(Ext.getCmp('os_user_flagExc'+'${param.tool_code}').getValue()==1&&Ext.getCmp('group_server_flag_Exc'+'${param.tool_code}').getValue()==1){
								Ext.getCmp('os_user_flagExc'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('server_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('group_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('osUserID'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
							};
							if(Ext.getCmp('os_user_flagExc'+'${param.tool_code}').getValue()==1&&Ext.getCmp('group_server_flag_Exc'+'${param.tool_code}').getValue()==2){
								Ext.getCmp('os_user_flagExc'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('server_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('group_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('osUserID'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
							}
						    }else{
						    	Ext.getCmp('group_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('server_os_user'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('osUserID'+'${param.tool_code}').el.up('.x-form-item').setDisplayed(false);
						    }
						},
						// 关闭操作
						doCancel : function() {
							app.closeTab('${param.tool_code}'+'EXE');
						},
						//服务器移入事件						serverShiftIn : function() {
							/* var records =this.tool_gridMoveServers.getSelectionModel().getSelections();
					    	if(this.excgridMovedServers.store.getCount()!=0){
								this.excgridMovedServers.store.removeAll();
								this.excgridMovedServers.store.add(records);
					    	}else{
					    		this.excgridMovedServers.store.add(records);
					    	} */
							var records =this.tool_gridMoveServers.getSelectionModel().getSelections();
					    		var notEqualFlag = true;
					    		Ext.each(records,function(leftRecord){
					    			Ext.getCmp('movedServersGrid'+'${param.tool_code}').getStore().each(function(rightRecord){
					    				if(leftRecord.data.server_ip == rightRecord.data.server_ip){
					    					notEqualFlag = false;
					    				}
					    			},this);
					    			if(notEqualFlag){
					    				Ext.getCmp('movedServersGrid'+'${param.tool_code}').getStore().add(leftRecord);
					    			}
					    			notEqualFlag = true;
					    		});
					    	var ips = [] ;
							this.excgridMovedServers.getStore().each(function(rightRecord){
						    		ips.push(rightRecord.get('server_ip'));
							},this);
					    	this.getOsuser_Store.baseParams.serverips = ips; 
					    	this.getOsuser_Store.reload();
					    	Ext.getCmp('osUserID'+'${param.tool_code}').setValue("");
						},
						//服务器移出事件						serverShiftOut : function() {
							var records = this.excgridMovedServers.getSelectionModel().getSelections();
							for(var i = 0; i<records.length; i++) {
								this.excgridMovedServers.store.remove(records[i]);
							}
							var ips = [] ;
							this.excgridMovedServers.getStore().each(function(rightRecord){
						    		ips.push(rightRecord.get('server_ip'));
							},this);
					    	this.getOsuser_Store.baseParams.serverips = ips; 
					    	this.getOsuser_Store.reload();
					    	Ext.getCmp('osUserID'+'${param.tool_code}').setValue("");
						}
					});
var toolBoxExe=new toolBoxExc();
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp('${param.tool_code}'+'EXE').add(toolBoxExe);
	// 刷新Tab页布局
	Ext.getCmp('${param.tool_code}'+'EXE').doLayout();
	toolBoxExe.on('beforedestroy',function(){
		
		Ext.getCmp('${param.tool_code}'+'EXEVIEW').window.close();
	},this);
	
</script>
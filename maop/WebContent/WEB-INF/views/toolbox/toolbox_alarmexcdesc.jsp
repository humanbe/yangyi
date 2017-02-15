0<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	var NUM;

	//服务器列表字段信息	var fieldsServer = Ext.data.Record.create([
		{name: 'server_route', mapping : 'server_route', type : 'string'}, 
		{name: 'server_ip', mapping : 'server_ip', type : 'string'}
	]);
	

	//查看关联软件日志信息
	function dowmload_file_exc(id){
	 window.location = '${ctx}/${appPath}/ToolBoxController/downloadFilesById.file?file_id='+id;
	}
	//查看关联软件日志信息
	function dowmload_file_exc2(){
	 var grid = Ext.getCmp("alarm_tool_box_exc_FILES");
	 var record = grid.getSelectionModel().getSelected();
			var tool_code = record.data.tool_code;
			var file_id= record.data.file_id;
			var file_type= record.data.file_type;
			var file_name= record.data.file_name;
			
	 
	 window.location = '${ctx}/${appPath}/ToolBoxController/downloadFiles.file?tool_code='+tool_code+'&file_id='+file_id+'&file_type='+file_type+'&file_name='+encodeURI(encodeURI(file_name));
	}
	//定义列表
	toolBoxAlarmExe = Ext.extend(Ext.Panel,
					{
						id:'${param.event_id}'+'${param.tool_code}'+'AlarmExeVIEW',
						window : null,
						
						tabIndex : 0,// 查询表单组件Tab键顺序
						
						constructor : function(cfg) {// 构造方法							Ext.apply(this, cfg);
							
							
							this.tool_statusStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_statusStore.load();
							this.tool_typeStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_typeStore.load();
						
							
							this.tool_authorize_flagStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.tool_authorize_flagStore.load();
							
							this.authorize_level_typeStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.authorize_level_typeStore.load();
							
						
							this.tool_stausStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
							this.tool_stausStore.load();
							
							
						
							this.appsys_Store =  new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForTool',
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
							
							
							//一级分类
							this.tool_field_type_oneStore = new Ext.data.Store(
							{
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
									method: 'POST'
								}),
								reader: new Ext.data.JsonReader({}, ['field_type_one'])
								
							});
							this.tool_field_type_oneStore.load();
								
										
										this.Form = new Ext.FormPanel({

											buttonAlign : 'center',
											labelAlign : 'right',
											lableWidth : 15,
											autoHeight: false,
											frame : true,
											monitorValid : true,
											defaults : {
												anchor : '90%',
												msgTarget : 'side'
											},
											items :  [ {
												layout:'column',
												items:[{
												     columnWidth:.5,
												     layout:'form',
								          	  
								                items : [ {
												xtype : 'combo',
												store : this.appsys_Store,
												fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
						     					name : 'appsys_code',
												valueField : 'appsysCode',
												displayField : 'appsysName',
												hiddenName : 'appsys_code',
												mode : 'local',
												triggerAction : 'all',
												forceSelection : true,
												width:260,
												style  : 'background : #F0F0F0' , 
												readOnly:true,
												tabIndex : this.tabIndex++,
												allowBlank : false,
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
											xtype : 'textfield',
											fieldLabel : '<fmt:message key="toolbox.tool_code" />',
											name : 'tool_code',
											maxLength:80,
											readOnly:true,
											hidden:true,
											style  : 'background : #F0F0F0' , 
											tabIndex : this.tabIndex++,
											allowBlank : false
										},
										
										{
											xtype : 'combo',
											store : this.authorize_level_typeStore,
											fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
											name : 'authorize_level_type',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'authorize_level_type',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											width:260,
											readOnly:true,
											viewable : false,
											allowBlank : false,
											tabIndex : this.tabIndex++
										},{
											xtype : 'combo',
											store : this.tool_authorize_flagStore,
											fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
											name : 'tool_authorize_flag',
											valueField : 'value',
											displayField : 'name',
											width:260,
											hiddenName : 'tool_authorize_flag',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											viewable : false,
											readOnly:true,
											tabIndex : this.tabIndex++,
											allowBlank : false
										},{
											xtype : 'textfield',
											fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
											name : 'tool_name',
											width:260,
											maxLength:100,
											readOnly:true,
											tabIndex : this.tabIndex++,
											allowBlank : false
										}]
												},{
												     columnWidth:.5,
												     layout:'form',
												    
												     items:[{
															xtype : 'combo',
															store : this.tool_field_type_oneStore,
															fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
															name : 'field_type_one',
															valueField : 'field_type_one',
															displayField : 'field_type_one',
															hiddenName : 'field_type_one',
															mode : 'local',
															triggerAction : 'all',
															forceSelection : true,
															viewable : false,
															readOnly:true,
															width:260,
															tabIndex : this.tabIndex++,
															allowBlank : false
														},
														{
															xtype : 'combo',
															store : this.tool_field_type_oneStore,
															fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
															name : 'field_type_two',
															valueField : 'field_type_two',
															displayField : 'field_type_two',
															hiddenName : 'field_type_two',
															mode : 'local',
															triggerAction : 'all',
															forceSelection : true,
															readOnly:true,
															width:260,
															viewable : false,
															tabIndex : this.tabIndex++
														},
														{
															xtype : 'combo',
															store : this.tool_field_type_oneStore,
															fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
															name : 'field_type_three',
															valueField : 'field_type_three',
															displayField : 'field_type_three',
															hiddenName : 'field_type_three',
															mode : 'local',
															triggerAction : 'all',
															readOnly:true,
															forceSelection : true,
															width:260,
															viewable : false,
															tabIndex : this.tabIndex++
														},{
															xtype : 'combo',
															store : this.tool_typeStore,
															fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
															name : 'tool_type',
															valueField : 'value',
															displayField : 'name',
															hiddenName : 'tool_type',
															mode : 'local',
															readOnly:true,
															width:260,
															triggerAction : 'all',
															forceSelection : true,
															viewable : false,
															tabIndex : this.tabIndex++,
															allowBlank : false
														}]
												}]
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

									},{
						            	xtype : 'textarea',
						            	id:'tool_content'+'${param.event_id}'+'${param.tool_code}',
										fieldLabel : '<fmt:message key="toolbox.tool_desc" />',
										name : 'tool_content',
										hidden:true
						            }
						            
						             ]
								 
											
								});
										
										// 加载表单数据
										this.Form.load({
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
								
										
										this.panel=new Ext.Panel({
											id:'panel'+'${param.event_id}'+'${param.tool_code}',
											title: '执行步骤',
											html: ''
										});
										
										// 实例化数据列表数据源
										this.gridStore = new Ext.data.JsonStore(
										{
											proxy : new Ext.data.HttpProxy(
													{
														method : 'POST',
														url : '${ctx}/${appPath}/ToolBoxController/tool_box_files',
														disableCaching : false
													}),
											autoDestroy : true,
											root : 'data',
											totalProperty : 'count',
										fields : [ 'tool_code','file_id', 
													'file_type', 
													'file_name'
											],
											remoteSort : false,
											sortInfo : {
												field : 'file_name',
												direction : 'ASC'
											},
											baseParams : {
												start : 0,
												limit : 100,
												tool_code:'${param.tool_code}'
												
											}
										});

										// 加载列表数据
										this.gridStore.load();
										csm = new Ext.grid.CheckboxSelectionModel();
										this.grid = new Ext.grid.GridPanel(
												{
													id:'alarm_tool_box_exc_FILES',
													border : true,
													height : 225,
													loadMask : true,
													region : 'center',
													border : false,
													loadMask : true,
													autoScroll : true,
													autoWeight : true,
													title : '附件列表',
													columnLines : true,
													frame:true,
													viewConfig : {
														forceFit : false
													},
													defaults : {
														anchor : '90%',
														msgTarget : 'side'
													},
													enableColumnHide:false,
													enableHdMenu : false, 
													store : this.gridStore,
													sm : csm,
													// 列定义

													columns : [
														new Ext.grid.RowNumberer(),
														csm,
														{
															header : '工具编号',
															dataIndex : 'tool_code',
															sortable : true,
															hidden:true
														},{
															header : '附件ID',
															dataIndex : 'file_id',
															sortable : true,
															hidden:true
														},{
															header : '附件名称',
															dataIndex : 'file_name',
															width:200,
															sortable : true
														},{
															header : '附件类型',
															dataIndex : 'file_type',
															
															sortable : true
														},{
															header : '下载',
															sortable : true,
															 renderer: this.download
														}
													
												 	],
													// 定义按钮工具条

													tbar : new Ext.Toolbar(
													{
														items : []
															}),
													// 定义分页工具条


													bbar : new Ext.PagingToolbar({
														store : this.gridStore,
														displayInfo : true,
														pageSize : 100
													})
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
								id : 'alarmwindow'+'${param.event_id}'+'${param.tool_code}',
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
					
						// 设置基类属性						toolBoxAlarmExe.superclass.constructor.call(this,{
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
							items : [  this.Form,{
								items:[
								       
								       this.panel
								       ]},this.grid 
							],
							  
							// 定义按钮
							buttons : []
							
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
							var p =Ext.getCmp('panel'+'${param.event_id}'+'${param.tool_code}');
							var tc=Ext.getCmp('tool_content'+'${param.event_id}'+'${param.tool_code}').getValue();
							p.body.update(tc);
						},
						download : function(value, metadata, record, rowIndex, colIndex, store) {
							  return '<a href="javascript:dowmload_file_exc2()"><font color=red>下载</font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
							 }
						
						
					});
var toolBoxAlarmExe=new toolBoxAlarmExe();
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp('${param.event_id}'+'${param.tool_code}'+'AlarmExe').add(toolBoxAlarmExe);
	// 刷新Tab页布局
	Ext.getCmp('${param.event_id}'+'${param.tool_code}'+'AlarmExe').doLayout();
	Ext.getCmp('${param.event_id}'+'${param.tool_code}'+'AlarmExe').on('beforedestroy',function(){
		
		Ext.getCmp('${param.event_id}'+'${param.tool_code}'+'AlarmExeVIEW').window.close();
	},this);
</script>
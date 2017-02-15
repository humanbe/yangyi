<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	ToolBoxViewTestPanel = Ext.extend(Ext.Panel,{
		tabIndex : 0,// 查询表单组件Tab键顺序		form :null,
		Servergrid:null,
		Paramgrid:null,
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			//禁止IE的backspace键(退格键)，但输入文本框时不禁止			Ext.getDoc().on(
							'keydown',
							function(e) {
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

			this.field_type_oneStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['field_type_one'])
						
					});
					this.field_type_oneStore.load();
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
			this.os_typeStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/OS_TYPE/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.os_typeStore.load();
			this.position_typeStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/TOOL_POSITION_TYPE/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.position_typeStore.load();
			this.tool_stausStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.tool_stausStore.load();
			this.os_user_flagStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/TOOLBOX_OS_USER_FLAG/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.os_user_flagStore.load();
			this.ParamTypeStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/PARAM_TYPE/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.ParamTypeStore.load();
			
			this.userStore =  new Ext.data.Store({
				proxy: new Ext.data.HttpProxy({
					url : '${ctx}/${appPath}/jobdesign/getUsers',
					method : 'GET',
					disableCaching : true
				}),
				reader : new Ext.data.JsonReader({}, ['username','name'])
			});
			this.userStore.load();
			
			this.server_group_flag = new Ext.data.JsonStore({
				url : '${ctx}/${frameworkPath}/item/GROUP_SERVER_FLAG/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.server_group_flag.load();
			this.toolcharsetStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/TOOL_CHARSET/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			this.toolcharsetStore.load();
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

			this.ParamgridStore = new Ext.data.JsonStore(
					{
						proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									//timeout : 1000000,
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
						remoteSort : true,
						sortInfo : {
						
							field : 'tool_code',
							direction : 'ASC'
						},
						baseParams : {
							start : 0,
							limit : 20,
							tool_code:'${param.tool_code}',
							appsys_code:'${param.appsys_code}'
						}
					});
			
			

			this.ServergridStore = new Ext.data.JsonStore(
					{
						proxy : new Ext.data.HttpProxy(
								{
									method : 'POST',
									
									url : '${ctx}/${appPath}/ToolBoxServerController/viewEdit',
									disableCaching : false
								}),
						autoDestroy : true,
						root : 'data',
						totalProperty : 'count',
						fields : [ 'tool_code', 'appsys_code',
								'server_route', 'server_ip' ,
								'os_user','checked'],
						pruneModifiedRecords : true,
						remoteSort : true,
						sortInfo : {
							field : 'tool_code',
							direction : 'ASC'
						},
						baseParams : {
							start : 0,
							limit : 1000,
							tool_code:'${param.tool_code}',
							appsys_code:'${param.appsys_code}',
							os_type :'${param.os_type}',
							server_group:'${param.server_group}'
						}
					});
			// 加载列表数据
			this.ParamgridStore.load();
			this.ServergridStore.load();


			csm = new Ext.grid.CheckboxSelectionModel();
			csm2 = new Ext.grid.CheckboxSelectionModel();
			
			this.form2 = new Ext.FormPanel(
					{
						title :  '匹配关键字',
						region : 'north',
						labelAlign : 'center',
						fileUpload : true,
						labelWidth : 150,
						height : 400,
						buttonAlign : 'center',
						frame : true,
						split : false,
						autoScroll : true,
						collapsible : true,
						collapseMode : 'mini',
						border : false,
						defaults : {
							anchor : '80%',
							msgTarget : 'side'
						},
						monitorValid : false,
						// 定义表单组件
						items : [{
							xtype : 'textarea',
							fieldLabel :'告警信息关键字',
							name : 'summarycn',
							height : 60,
							readOnly:true,
							tabIndex : this.tabIndex++
						}
						, 
						/* {
							xtype : 'textarea',
							fieldLabel : '<fmt:message key="toolbox.alarm_instance" />',
							name : 'alarminstance',
							readOnly:true,
							height : 60,
							tabIndex : this.tabIndex++
						} */{
							xtype : 'treepanel',
							fieldLabel : '告警策略名称',
							height : 260,
							frame : true,
							readOnly:true,
							autoScroll: true,
							margins : '0 0 0 5',
							root : new Ext.tree.AsyncTreeNode({
								text : '${param.appsys_code}',
								draggable : false,
								iconCls : 'node-root'
								
							}),
							loader : new Ext.tree.TreeLoader({
								requestMethod : 'POST',
								dataUrl : '${ctx}/${appPath}/ToolBoxController/getEventGroupTree',
								baseParams:{
									appsys_code:'${param.appsys_code}',
									tool_code:'${param.tool_code}'
								}
							}),
							listeners : {
								scope : this,
								afterrender : function(tree) {
									tree.expandAll();
								},
								'checkchange': function(node, checked){
							          if (node.parentNode != null) {
							                 node.cascade(function(node){
								                 node.attributes.checked = checked;
								                 node.ui.checkbox.checked = checked;
								              });
								              var pNode_1 = node.parentNode; //分组目录
								              if(pNode_1 == Ext.getCmp('policy_EditID').getRootNode()) return;
								              if(checked){
									             var cb_1 = pNode_1.ui.checkbox; 
									             if(cb_1){
										         	cb_1.checked = checked; 
										         	cb_1.defaultChecked = checked; 
										     	}
									             pNode_1.attributes.checked=checked;
									          }else{
										    	var _miss=false; 
										     	for(var i=0;i<pNode_1.childNodes.length;i++){
											  		if(pNode_1.childNodes[i].attributes.checked!=checked){
												 		_miss=true;
											    	}
										      	}
												if(!_miss){
													pNode_1.ui.toggleCheck(checked); 
													pNode_1.attributes.checked=checked; 
										     	}
										  	}
								            // 三级目录
								            if (pNode_1.parentNode != null) {
									            var pNode_2 = pNode_1.parentNode; 
									            if(pNode_2 == Ext.getCmp('policy_EditID').getRootNode()) return;
									            if(checked){
										            var cb_2 = pNode_2.ui.checkbox; 
										            if(cb_2){
											         	cb_2.checked = checked; 
											         	cb_2.defaultChecked = checked; 
											     	}
										            pNode_2.attributes.checked=checked;
										        }else{
											    	var _miss=false; 
											     	for(var i=0;i<pNode_2.childNodes.length;i++){
												  		if(pNode_2.childNodes[i].attributes.checked!=checked){
													 		_miss=true;
												    	}
											      	}
													if(!_miss){
														pNode_2.ui.toggleCheck(checked); 
														pNode_2.attributes.checked=checked; 
											     	}
											  } 
									          // 四级目录
									          if (pNode_2.parentNode != null) {
										            var pNode_3 = pNode_2.parentNode; 
										            if(pNode_3 == Ext.getCmp('policy_EditID').getRootNode()) return;
										            if(checked){
											            var cb_3 = pNode_3.ui.checkbox; 
											            if(cb_3){
												         	cb_3.checked = checked; 
												         	cb_3.defaultChecked = checked; 
												     	}
											            pNode_3.attributes.checked=checked;
											        }else{
												    	var _miss=false; 
												     	for(var i=0;i<pNode_3.childNodes.length;i++){
													  		if(pNode_3.childNodes[i].attributes.checked!=checked){
														 		_miss=true;
													    	}
												      	}
														if(!_miss){
															pNode_3.ui.toggleCheck(checked); 
															pNode_3.attributes.checked=checked; 
												     	}
												    }
											   }  
										   } 
									   }
								 }
							}
					}]
					});
			
			// 加载表单数据
			this.form2.load({
						url : '${ctx}/${appPath}/ToolBoxController/dblview',
						method : 'POST',
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.loading" />',
						scope : this,
						failure : this.loadFailure,
						params:{
							tool_code :'${param.tool_code}',
							appsys_code:'${param.appsys_code}'
						}
					});
			this.form = new Ext.FormPanel(
					{
						title :  '<fmt:message key="toolbox.tool_properties" />',
						region : 'north',
						labelAlign : 'center',
						fileUpload : true,
						labelWidth : 150,
						height : 400,
						buttonAlign : 'center',
						frame : true,
						split : false,
						autoScroll : true,
						collapsible : true,
						collapseMode : 'mini',
						border : false,
						url : '${ctx}/${appPath}/ToolBoxController/edit',
						defaults : {
							anchor : '80%',
							msgTarget : 'side'
						},
						monitorValid : false,
						// 定义表单组件
						items : [
						         {
							xtype : 'combo',
							store : this.appsys_Store,
							fieldLabel :  '<fmt:message key="toolbox.appsys_code" />',
							name : 'appsys_code',
							valueField : 'appsysCode',
							displayField : 'appsysName',
							hiddenName : 'appsys_code',
							readOnly:true,
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							editable : false,
							tabIndex : this.tabIndex++,
							allowBlank : false

					     	},

								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="toolbox.tool_code" />',
									name : 'tool_code',
									readOnly:true,
									tabIndex : this.tabIndex++,
									allowBlank : false
								},

								
								{
									xtype : 'textfield',
									fieldLabel :  '<fmt:message key="toolbox.shell_name" />',
									name : 'shell_name',
									readOnly:true,
									tabIndex : this.tabIndex++,
									allowBlank : false

								},
								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="toolbox.tool_name" />',
									readOnly:true,
									name : 'tool_name',
									tabIndex : this.tabIndex++,
									allowBlank : false

								},

								

								{
									xtype : 'combo',
									store : this.ServerGroupStore,
									fieldLabel : '<fmt:message key="toolbox.server_group" />',
									name : 'server_group',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'server_group',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'combo',
									store : this.os_typeStore,
									fieldLabel : '<fmt:message key="toolbox.os_type" />',
									name : 'os_type',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'os_type',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'combo',
									store : this.os_user_flagStore,
									fieldLabel : '<fmt:message key="toolbox.os_user_flag" />',
									name : 'os_user_flag',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'os_user_flag',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++
									
								},
								{
									xtype : 'combo',
									store : this.server_group_flag,
									fieldLabel :'<fmt:message key="toolbox.group_server_flag" />',
									name : 'group_server_flag',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'group_server_flag',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'textfield',
									fieldLabel :'<fmt:message key="toolbox.os_user" />',
									name : 'os_user',
									readOnly:true,
									maxLength:10,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'combo',
									store : this.authorize_level_typeStore,
									fieldLabel :  '<fmt:message key="toolbox.authorize_level_type" />',
									name : 'authorize_level_type',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'authorize_level_type',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="toolbox.field_type_one" />',
									name : 'field_type_one',
									//hidden:true,
									tabIndex : this.tabIndex++,
									readOnly : true
																	
								},
								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
									name : 'field_type_two',
									//hidden:true,
									tabIndex : this.tabIndex++,
									readOnly : true

								},
								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
									name : 'field_type_three',
									//hidden:true,
									tabIndex : this.tabIndex++,
									readOnly : true

								},
							
								{
									xtype : 'combo',
									store : this.tool_authorize_flagStore,
									fieldLabel : '<fmt:message key="toolbox.tool_authorize_flag" />',
									name : 'tool_authorize_flag',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_authorize_flag',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									readOnly:true,
									editable : false,
									tabIndex : this.tabIndex++
								},

								{
									xtype : 'combo',
									store : this.position_typeStore,
									id : 'toolboxView_position_typeID',
									fieldLabel :  '<fmt:message key="toolbox.position_type" />',
									name : 'position_type',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'position_type',
									mode : 'local',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++

								},
								 {
									xtype : 'combo',
									store : this.userStore,
									fieldLabel : '<fmt:message key="toolbox.tool_creator" />',
									name : 'tool_creator',
									valueField : 'username',
									displayField : 'name',
									hiddenName : 'tool_creator',
									mode : 'local',
									triggerAction : 'all',
									readOnly:true,
									forceSelection : true,
									editable : false,
									readOnly:true,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'combo',
									store : this.toolcharsetStore,
									fieldLabel : '<fmt:message key="toolbox.tool_charset" />',
									name : 'tool_charset',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_charset',
									mode : 'local',
									triggerAction : 'all',
									readOnly:true,
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++
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
									xtype : 'combo',
									store : this.tool_statusStore,
									fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_status" />',
									name : 'tool_status',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_status',
									mode : 'local',
									triggerAction : 'all',
									readOnly:true,
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++,
									allowBlank : false
								},
								{
									xtype : 'textarea',
									fieldLabel :'<fmt:message key="toolbox.tool_returnreasons" />',
									name : 'tool_returnreasons',
									readOnly:true,
									height : 50,
									maxLength:200,
									tabIndex : this.tabIndex++

								},
								{
									xtype : 'textfield',
									name : 'paramValue',
									tabIndex : this.tabIndex++,
									hidden : true
								} ,
								
								{
									xtype : 'textfield',
									name : 'serverValue',
									hidden : true,
									tabIndex : this.tabIndex++
								}]

					});
			// 加载表单数据
			this.form.load({
						url : '${ctx}/${appPath}/ToolBoxController/dblview',
						method : 'POST',
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.loading" />',
						scope : this,
						failure : this.loadFailure,
						params:{
							tool_code :'${param.tool_code}',
							appsys_code:'${param.appsys_code}'
						}
					});

			
			var param_name = new Ext.form.TextField();
			var param_length = new Ext.form.TextField();
			var param_format = new Ext.form.TextField();
			var param_value = new Ext.form.TextField();
			var param_desc = new Ext.form.TextField();
			var server_route = new Ext.form.TextField();
			var server_user = new Ext.form.TextField();
			var server_ip = new Ext.form.TextField({
				allowBlank : false
			});
			
			var param_type = new Ext.form.ComboBox({
				typeAhead : true,
				triggerAction : 'all',
				hiddenName : 'param_type',
				mode : 'local',
				store : this.ParamTypeStore,
				displayField : 'name',
				valueField : 'value'

			});

		


			this.Paramgrid = new Ext.grid.GridPanel(
					{
						region : 'center',
						border : false,
						loadMask : true,
						height : 300,
						title : '<fmt:message key="toolbox.tool_param" />',
						columnLines : true,
						viewConfig : {
							forceFit : true
						},
						store : this.ParamgridStore,
						sm : csm,
						// 列定义

						columns : [
						new Ext.grid.RowNumberer(),
						csm,

						
						 {
							header :  '<fmt:message key="toolbox.param_name" />',
							dataIndex : 'param_name',
							editor : param_name,
							allowBlank : false,
							sortable : true
						},{
							header : '<fmt:message key="toolbox.param_type" />',
							dataIndex : 'param_type',
							width:50,
							renderer : this.ParamTypeone,
							editor : param_type,
							scope : this,
							sortable : true

						}, {
							header : '<fmt:message key="toolbox.param_length" />',
							dataIndex : 'param_length',
							width:50,
							editor : param_length,
							sortable : true

						}, {
							header : '<fmt:message key="toolbox.param_format" />',
							dataIndex : 'param_format',
							editor : param_format,
							sortable : true

						},  {
							header : '<fmt:message key="toolbox.param_default_value" />',
							dataIndex : 'param_value',
							editor : param_value,
							readonly : true,
							sortable : true
						} ,{
							header :  '<fmt:message key="toolbox.param_desc" />',
							dataIndex : 'param_desc',
							width:200,
							editor : param_desc,
							sortable : true
						} ],
						
						// 定义分页工具条
						bbar : new Ext.PagingToolbar({
							store : this.ParamgridStore,
							displayInfo : true,
							pageSize : 100
						})

					});

			// 实例化数据列表组件

			this.Servergrid = new Ext.grid.GridPanel(
					{
						region : 'center',
						border : false,
						loadMask : true,

						title : '<fmt:message key="toolbox.server" />',
						columnLines : true,
						viewConfig : {
							forceFit : true
						},
						store : this.ServergridStore,
						sm : csm2,
						columns : [
						new Ext.grid.RowNumberer(),
						csm2,

						 {
							header : '<fmt:message key="toolbox.server_ip" />',
							dataIndex : 'server_ip',
							editor : server_ip,
							sortable : true,
							allowBlank : false
						}, {
							header : '<fmt:message key="toolbox.server_route" />',
							dataIndex : 'server_route',
							editor : server_route,
							sortable : true
						}, {
							header : '<fmt:message key="toolbox.os_user" />',
							dataIndex : 'os_user',
							editor : server_user,
							sortable : true
						} ],
						
						 listeners : {
								//编辑完成后处理事件

								scope : this,
								'activate' : function(panel) {
									// 默认选中数据
									var records = this.ServergridStore.query('checked', true).getRange();
					                setTimeout(function(){
					                	panel.getSelectionModel().selectRecords(records, false);
					                }, 500);
								} 
							},
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.ServergridStore,
							displayInfo : true,
							pageSize : 100
						})

					});

			this.script = new Ext.Panel(
					{

						title : '<fmt:message key="title.script" />',
						items : [ {
							
							layout : 'form',
							defaults : {
								anchor : '90%'
							},
							border : false,
							items : [ {
								xtype : 'textarea',
								id : 'toolView_scriptID',
								name : 'script',
								height : 580,
								width : 500,
								style  : 'font-family:宋体;font-size:15px' , 
								readOnly : true,
								tabIndex : this.tabIndex++
							}  ]
						} ],
						listeners : {
							//编辑完成后处理事件

							scope : this,
							'activate' : function(panel) {
								
								if(Ext.getCmp('toolView_scriptID').getValue()==undefined||Ext.getCmp('toolView_scriptID').getValue()==''){
								if(Ext.getCmp('toolboxView_position_typeID').getValue()==1){
									// 默认选中数据
									scope : this,
									this.form.getForm().submit({
									url : '${ctx}/${appPath}/ToolBoxController/ftpScript',
									scope : this,
									success : this.Success
							
							})
							}
								}
							}
						}
					});
			// 设置基类属性

			ToolBoxViewTestPanel.superclass.constructor.call(
							this,
							{
								layout : 'form',
								border : false,
								buttonAlign : 'center',
								frame : true,
								autoScroll : true,
								defaults : {
									anchor : '100%',
									msgTarget : 'side'
								},
								
								monitorValid : true,

								items : [ {
									xtype : 'tabpanel',
									plain : true,
									forceLayout : true,
									autoScroll : false,
									enableTabScroll : true,
									defaults : {
										anchor : '80%'
									},
									activeTab : 0,
									height : 650,
									deferredRender : false,
									defaults : {
										bodyStyle : 'padding:10px'
									},
									items : [ this.form,
									          this.script,
									          this.Paramgrid ,
											this.Servergrid,
											this.form2]
								}

								],
								

								// 定义按钮
									buttons : [
									{
										text : '<fmt:message key="button.close" />',
										iconCls : 'button-close',
										tabIndex : this.tabIndex++,
										formBind : true,
										scope : this,
										handler : this.doClose
									}
									 ]
							});

		},
		ParamTypeone : function(value) {

			var index = this.ParamTypeStore.find('value', value);
			if (index == -1) {
				return value;
			} else {
				return this.ParamTypeStore.getAt(index).get('name');
			}
		},

		// 取消操作
		doClose : function() {
			app.closeTab('TOOLBOX_VIEW');
		},
		
		// 向大文本内中放数据

		Success : function(form, action) {
			var data = decodeURIComponent(action.result.data);
			var scriptNr=Ext.getCmp('toolView_scriptID').setValue(data);
			var bottom = this.getHeight();
			this.body.scroll("b", bottom, true);
		}
						
					});
			
		
			
		var	ToolBoxViewTestPanel=new ToolBoxViewTestPanel();

	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("TOOLBOX_VIEW").add(ToolBoxViewTestPanel);
	// 刷新Tab页布局
	Ext.getCmp("TOOLBOX_VIEW").doLayout();
</script>
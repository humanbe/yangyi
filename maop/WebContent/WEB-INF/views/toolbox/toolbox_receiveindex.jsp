<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var Ret_tool_codes;
var field_type_twoStore_receiveindex;
var field_type_threeStore_receiveindex;

	toolBoxReceivepanel = Ext.extend(
			Ext.Panel,
			{
				gridStore : null,// 数据列表数据源
				grid : null,// 数据列表组件
				form : null,// 查询表单组件
				tabIndex : 0,// 查询表单      组件Tab键顺序
				csm : null,// 数据列表选择框组件
				constructor : function(cfg) {// 构造方法
					Ext.apply(this, cfg);
					//禁止IE的backspace键(退格键)，但输入文本框时不禁止

					Ext.getDoc().on('keydown',function(e) {
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
					
					this.tool_typeStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
					this.tool_typeStore.load();
					
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

					this.os_user_flagStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOLBOX_OS_USER_FLAG/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
					this.os_user_flagStore.load();
					
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
					
					this.field_type_oneStore = new Ext.data.Store(
							{
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
									method: 'POST'
								}),
								reader: new Ext.data.JsonReader({}, ['field_type_one'])
								
							});
					this.field_type_oneStore.load();
					
					
					field_type_twoStore_receiveindex = new Ext.data.Store(
							{
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
									method: 'POST'
								}),
								reader: new Ext.data.JsonReader({}, ['field_type_two'])
								
							});
					field_type_twoStore_receiveindex.on('beforeload',function(){
						field_type_twoStore_receiveindex.baseParams.field_type_one = Ext.getCmp("field_type_one_receiveindexID").getValue();
							},this); 
					//field_type_twoStore_receiveindex.load();
					
					
					field_type_threeStore_index = new Ext.data.Store(
							{
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
									method: 'POST'
								}),
								reader: new Ext.data.JsonReader({}, ['field_type_three'])
								
							});
					field_type_threeStore_index.on('beforeload',function(){
						field_type_threeStore_index.baseParams.field_type_one = Ext.getCmp("field_type_one_receiveindexID").getValue();
						field_type_threeStore_index.baseParams.field_type_two = Ext.getCmp("field_type_two_receiveindexID").getValue();
							},this); 
					//field_type_threeStore_index.load(); 
					
					// 实例化数据列表选择框组件

					csm = new Ext.grid.CheckboxSelectionModel();

					// 实例化数据列表数据源
					this.gridStore = new Ext.data.JsonStore(
							{
								proxy : new Ext.data.HttpProxy(
										{
											method : 'POST',
											url : '${ctx}/${appPath}/ToolBoxController/frontlineindex',
											disableCaching : false
										}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : [ 'tool_code', 'appsys_code',
										'tool_name', 'tool_desc',
										'server_group','authorize_level_type',
										'field_type_one','field_type_two',
										'field_type_three','os_type',
										'position_type','tool_upload', 
										'tool_authorize_flag',
										'tool_creator', 'shell_name',
										'os_user','os_user_flag',
										'tool_status','tool_returnreasons',
										'group_server_flag','tool_charset','tool_modifier',
										'tool_created_time','tool_updated_time','tool_received_time',
										'tool_received_user','tool_type'
								],
								remoteSort : false,
								sortInfo : {
									field : 'appsys_code',
									direction : 'ASC'
								},
								baseParams : {
									start : 0,
									limit : 100
								}
							});

					// 加载列表数据
					this.gridStore.load();
					// 实例化数据列表组件

					this.grid = new Ext.grid.GridPanel(
							{
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
								store : this.gridStore,
								sm : csm,
								// 列定义

								columns : [
										new Ext.grid.RowNumberer(),
										csm,

										{
											header :'<fmt:message key="toolbox.appsys_code" />',
											dataIndex : 'appsys_code',
											renderer : this.appsys_Storeone,
											width:150,
											scope : this,
											sortable : true
										},
										{
											header :  '<fmt:message key="toolbox.tool_name" />',
											dataIndex : 'tool_name',
											width:200,
											sortable : true
										},
										{
											header : '<fmt:message key="toolbox.os_type" />',
											dataIndex : 'os_type',
											renderer : this.os_typeone,
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

										},
										
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
										} ,{
											header : '<fmt:message key="toolbox.tool_returnreasons" />',
											dataIndex : 'tool_returnreasons',
											sortable : true
										},
										{

											header : '<fmt:message key="toolbox.tool_code" />',
											dataIndex : 'tool_code',
											sortable : true

										},
										{
											header : '<fmt:message key="toolbox.server_group" />',
											dataIndex : 'server_group',
											renderer : this.ServerGroupone,
											scope : this,
											sortable : true

										},
										{
											header : '<fmt:message key="toolbox.position_type" />',
											dataIndex : 'position_type',
											renderer : this.position_typeone,
											scope : this,
											sortable : true
										},
										 {
											header : '<fmt:message key="toolbox.tool_creator" />',
											dataIndex : 'tool_creator',
											renderer : this.userStoreValue,
											scope : this,
											hidden: true,
											sortable : true
										},
										{
											header :  '<fmt:message key="toolbox.shell_name" />',
											dataIndex : 'shell_name',
											sortable : true
										},
										
										{
											header : '<fmt:message key="toolbox.authorize_level_type" />',
											dataIndex : 'authorize_level_type',
											renderer : this.authorize_level_typeone,
											scope : this,
											sortable : true

										},
										{
											header :  '<fmt:message key="toolbox.os_user_flag" />',
											dataIndex : 'os_user_flag',
											renderer : this.os_user_flagone,
											hidden: true,
											scope : this,
											sortable : true

										},
										{
											header :  '<fmt:message key="toolbox.group_server_flag" />',
											dataIndex : 'group_server_flag',
											renderer : this.server_group_flagone,
											scope : this,
											sortable : true

										},
										
										{
											header : '<fmt:message key="toolbox.os_user" />',
											dataIndex : 'os_user',
											hidden: true,
											sortable : true
										},
										{
											header :'<fmt:message key="toolbox.tool_authorize_flag" />',
											dataIndex : 'tool_authorize_flag',
											renderer : this.tool_authorize_flagone,
											scope : this,
											hidden: true,
											sortable : true

										},
										{
											header :  '<fmt:message key="toolbox.tool_charset" />',
											dataIndex : 'tool_charset',
											renderer : this.tool_charsetone,
											scope : this,
											hidden: true,
											sortable : true

										},
										 {
											header : '<fmt:message key="toolbox.tool_creator" />',
											dataIndex : 'tool_creator',
											renderer : this.userStoreValue,
											scope : this,
											sortable : true
										},{
											header : '<fmt:message key="toolbox.tool_created_time" />',
											dataIndex : 'tool_created_time',
											sortable : true
										},{
											header : '<fmt:message key="toolbox.tool_modifier" />',
											dataIndex : 'tool_modifier',
											renderer : this.userStoreValue,
											scope : this,
											sortable : true
										} ,{
											header : '<fmt:message key="toolbox.tool_updated_time" />',
											dataIndex : 'tool_updated_time',
											sortable : true
										},{
											header : '<fmt:message key="toolbox.tool_received_user" />',
											dataIndex : 'tool_received_user',
											renderer : this.userStoreValue,
											scope : this,
											sortable : true
										} ,{
											header : '<fmt:message key="toolbox.tool_received_time" />',
											dataIndex : 'tool_received_time',
											sortable : true
										} ],
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
								}),
								// 定义数据列表监听事件
								listeners : {
									scope : this,
									// 行双击事件：打开数据查看页面
									rowdblclick : this.doView

								}
							});
					this.form = new Ext.FormPanel(
							{
								region : 'east',
								title : '<fmt:message key="button.find" />',
								labelAlign : 'right',
								labelWidth : 100,
								buttonAlign : 'center',
								frame : true,
								split : true,
								width : 280,
								minSize : 280,
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
											name : 'appsys_code',
											valueField : 'appsysCode',
											displayField : 'appsysName',
											hiddenName : 'appsys_code',
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
											xtype : 'combo',
											store : this.tool_statusStore,
											fieldLabel :'<fmt:message key="toolbox.tool_status" />',
											name : 'tool_status',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'tool_status',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++

										},

										{
											xtype : 'textfield',
											fieldLabel :  '<fmt:message key="toolbox.shell_name" />',
											name : 'shell_name',
											tabIndex : this.tabIndex++

										},
										{
											xtype : 'textfield',
											fieldLabel :  '<fmt:message key="toolbox.tool_name" />',
											name : 'tool_name',
											tabIndex : this.tabIndex++

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
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
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
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++

										},

										{
											xtype : 'combo',
											store : this.field_type_oneStore,
											fieldLabel : '<fmt:message key="toolbox.field_type_one" />',
											id : 'field_type_one_receiveindexID',
											name : 'field_type_one',
											valueField : 'field_type_one',
											displayField : 'field_type_one',
											hiddenName : 'field_type_one',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++,
											listeners : {
												//编辑完成后处理事件

												select : function(obj) {
													field_type_twoStore_receiveindex.load();
												}
											}

										},
										{
											xtype : 'combo',
											store : field_type_twoStore_receiveindex,
											fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
											id:'field_type_two_receiveindexID',
											name : 'field_type_two',
											valueField : 'field_type_two',
											displayField : 'field_type_two',
											hiddenName : 'field_type_two',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++,
											listeners : {
												//编辑完成后处理事件

												select : function(obj) {
													field_type_threeStore_index.load();
												}
											}

										},
										{
											xtype : 'combo',
											store : field_type_threeStore_index,
											fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
											name : 'field_type_three',
											valueField : 'field_type_three',
											displayField : 'field_type_three',
											hiddenName : 'field_type_three',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++

										},
										{
											xtype : 'combo',
											store : this.os_typeStore,
											fieldLabel :  '<fmt:message key="toolbox.os_type" />',
											name : 'os_type',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'os_type',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++

										},
										 {
											xtype : 'combo',
											store : this.tool_authorize_flagStore,
											fieldLabel :'<fmt:message key="toolbox.tool_authorize_flag" />',
											name : 'tool_authorize_flag',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'tool_authorize_flag',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
											tabIndex : this.tabIndex++

										},
										 {
											xtype : 'combo',
											id:'tool_type_receiveindexID',
											store : this.tool_typeStore,
											fieldLabel :'<fmt:message key="toolbox.tool_type" />',
											name : 'tool_type',
											valueField : 'value',
											displayField : 'name',
											hiddenName : 'tool_type',
											mode : 'local',
											triggerAction : 'all',
											forceSelection : true,
											editable : false,
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
					
					
					this.formTree = new Ext.FormPanel(
							{
								region : 'west',
								title : '工具分类',
								labelAlign : 'right',
								labelWidth : 100,
								buttonAlign : 'center',
								frame : true,
								split : true,
								width : 200,
								minSize : 200,
								maxSize : 250,
								autoScroll : true,
								collapsible : true,
								collapseMode : 'mini',
								border : false,
								defaults : {
									anchor : '100%',
									msgTarget : 'side'
								},
								// 定义查询表单组件
								items : [

								{
									xtype : 'treepanel',
									fieldLabel : '', 
									height : 660,
									frame : true,
									autoScroll: true,
									margins : '0 0 0 5',
									root : new Ext.tree.AsyncTreeNode({
										text : '工具',
										draggable : false,
										iconCls : 'node-root'
										//,id : 'rootId'
									}),
									loader : new Ext.tree.TreeLoader({
										requestMethod : 'POST',
										dataUrl : '${ctx}/${appPath}/ToolBoxController/getToolTree2',
										baseParams:{
										}
									}),
									listeners : {
										scope : this,
										afterrender : function(tree) {
											tree.expandAll();
										},
										'click' : function(node) {
											if(node.parentNode!=null){
											
											if(node.isLeaf()){
											this.form.getForm().reset();
												if(node.parentNode.text.indexOf("脚本")!=-1){
													Ext.getCmp("tool_type_receiveindexID").setValue('1');
												}else{
													Ext.getCmp("tool_type_receiveindexID").setValue('2');
												}
												
												var value =node.text.split("(")[0];
												Ext.getCmp("field_type_one_receiveindexID").setValue(value);
												field_type_twoStore_receiveindex.load();
												Ext.apply(this.grid.getStore().baseParams,
														this.form.getForm().getValues());
												this.grid.getStore().load();
											}else{
												if(node.text.indexOf("脚本")!=-1){
													this.form.getForm().reset();
													Ext.getCmp("tool_type_receiveindexID").setValue('1');
													field_type_twoStore_receiveindex.load();
													Ext.apply(this.grid.getStore().baseParams,
															this.form.getForm().getValues());
													this.grid.getStore().load();
												}else{
													this.form.getForm().reset();
													Ext.getCmp("tool_type_receiveindexID").setValue('2');
													field_type_twoStore_receiveindex.load();
													Ext.apply(this.grid.getStore().baseParams,
															this.form.getForm().getValues());
													this.grid.getStore().load();
												}
											}
										}else{
											this.form.getForm().reset();
											Ext.apply(this.grid.getStore().baseParams,
													this.form.getForm().getValues());
											this.grid.getStore().load();
										}
									}
								}	
								}
								],

								// 定义查询表单按钮
								buttons : []
							});
					// 设置基类属性

					toolBoxReceivepanel.superclass.constructor.call(this,
							{
								layout : 'border',
								border : false,
								items : [ this.formTree,this.form, this.grid ]
							});
				},

				tool_authorize_flagone : function(value) {

					var index = this.tool_authorize_flagStore.find('value', value);

					if (index == -1) {
						return value;
					} else {
						return this.tool_authorize_flagStore.getAt(index).get('name');
					}
				},
				ServerGroupone : function(value) {

					var index = this.ServerGroupStore.find('value', value);
					if (index == -1) {
						return value;
					} else {
						return this.ServerGroupStore.getAt(index).get('name');
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
				os_typeone : function(value) {
					var index = this.os_typeStore.find('value', value);
					if (index == -1) {
						return value;
					} else {
						return this.os_typeStore.getAt(index).get('name');
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
				

				os_user_flagone : function(value) {

					var index = this.os_user_flagStore.find('value', value);
					if (index == -1) {
						return value;
					} else {
						return this.os_user_flagStore.getAt(index).get('name');
					}
				},
				server_group_flagone : function(value) {

					var index = this.server_group_flag.find('value', value);
					if (index == -1) {
						return value;
					} else {
						return this.server_group_flag.getAt(index).get('name');
					}
				},
				tool_charsetone : function(value) {

					var index = this.toolcharsetStore.find('value', value);
					if (index == -1) {
						return value;
					} else {
						return this.toolcharsetStore.getAt(index).get('name');
					}
				},
				appsys_Storeone : function(value) {

					var index = this.appsys_Store.find('appsysCode', value);
					if (index == -1) {
						return value;
					} else {
						return this.appsys_Store.getAt(index).get('appsysName');
					}
				},
				userStoreValue : function(value) {
					var index = this.userStore.find('username', value);
					if (index == -1) {
						return value;
					} else {
						return this.userStore.getAt(index).get('name');
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
				tool_statusone : function(value) {

					var index = this.tool_statusStore.find('value', value);

					if (index == -1) {
						return value;
					} else {
						return this.tool_statusStore.getAt(index).get('name');
					}
				},
				
				// 新建事件
				doCreate : function() {
					app.loadTab('TOOLBOX_CREATE',
									'<fmt:message key="button.create" />',
									'${ctx}/${appPath}/ToolBoxController/create');

				},
				// 查询事件
				doFind : function() {
					Ext.apply(this.grid.getStore().baseParams,
							this.form.getForm().getValues());
					this.grid.getStore().load();
					
				},
				// 重置查询表单
				doReset : function() {
					this.form.getForm().reset();
				},
				// 查看事件
				doView : function() {
					var record = this.grid.getSelectionModel()
							.getSelected();
					var params = {
						tool_code : record.get('tool_code'),
						appsys_code : record.get('appsys_code'),
						os_type : record.get('os_type'),
						server_group:record.get('server_group')
					};
					
					if( record.get('tool_type')==1){
						app.loadTab('TOOLBOX_VIEW','<fmt:message key="button.view" />',
								'${ctx}/${appPath}/ToolBoxController/dblview',params);
					}
					if( record.get('tool_type')==2){
						app.loadTab(
								'TOOL_BOX_VIEWDESC_INFO',
								'<fmt:message key="button.view" />',
								'${ctx}/${appPath}/ToolBoxController/dblviewDesc',
								params);
					}
					/* app.loadTab('TOOLBOX_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
									'${ctx}/${appPath}/ToolBoxController/view',params); */
				},
				
				doReceived : function() {
				if (this.grid.getSelectionModel().getCount() > 0) {
					var records = this.grid.getSelectionModel().getSelections();
					var tool_codes = new Array();
					var flag =true;
					for ( var i = 0; i < records.length; i++) {
						if(records[i].get('tool_status')!="1"){
							flag=false;
						}
						tool_codes[i] = records[i].get('tool_code');
					}

					if(flag){
					Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '确认接收？',
								buttons : Ext.MessageBox.OKCANCEL,
								icon : Ext.MessageBox.QUESTION,
								minWidth : 200,
								scope : this,
								fn : function(buttonId) {
									if (buttonId == 'ok') {
										app.mask.show();

										Ext.Ajax.request({
													method : 'POST',
													url : '${ctx}/${appPath}/ToolBoxController/received',
													scope : this,
													success : this.receivedSuccess,
													failure : this.receivedFailure,
													params : {
														tool_codes : tool_codes
														
													}
												});
									}
								}
							});
					}else{
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '工具状态不全部是【待接受】',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
					};
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

			// 删除失败回调方法
			receivedFailure : function() {
				app.mask.hide();
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '接收失败',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
			},
			// 删除成功回调方法
			receivedSuccess : function(response, options) {
				app.mask.hide();
				if (Ext.decode(response.responseText).success == false) {
					var error = Ext.decode(response.responseText).error;
					Ext.Msg
							.show({
								title : '<fmt:message key="message.title" />',
								msg : '接收失败'+'<fmt:message key="error.code" />:'
										+ error,
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
				} else if (Ext.decode(response.responseText).success == true) {
					this.grid.getStore().reload();// 重新加载数据源

					Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '接收成功！',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.INFO
							});
				}
			},
			
			doCancelReturn : function() {
				Return_Win.close();
				app.loadTab(
						'TOOLBOX_RECEIVEINDEX',
						'工具接受',
						'${ctx}/${appPath}/ToolBoxController/receiveindex');
			},
			
			doReturn : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel()
						.getSelections();
				Ret_tool_codes = new Array();
				var flag2 =true;
				for ( var i = 0; i < records.length; i++) {
					if(records[i].get('tool_status')!="1"){
						flag2=false;
					}
					Ret_tool_codes[i] = records[i].get('tool_code');
				}
				
				if(flag2){
					Return_Win.show();
				}else{
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '工具状态不全部是【待接受】',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
				}
				
			} else {
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.select.one.at.least" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						})
			}
		},

		doSaveReturn : function() {
			
			Ext.Ajax.request({
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxController/returned',	
				scope : this,
				success : toolBoxReceiveindex.returnSuccess,
				failure : toolBoxReceiveindex.returnFailure,
				params : {
					
					tool_codes : Ret_tool_codes,
					tool_returnreasons: Ext.getCmp('tool_returnreasons_update').getValue()
				}
			});
			
			},
		
		returnFailure : function(form, action) {
			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'+ error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
			
		},
		
		returnSuccess : function(response, options) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					Return_Win.close();
						app.loadTab(
								'TOOLBOX_RECEIVEINDEX',
								'工具接受',
								'${ctx}/${appPath}/ToolBoxController/receiveindex');
					
				}
		   }); 
		},
		/**一线接收工具编辑函数*/
		doEdit:function(){
			var record = this.grid.getSelectionModel()
			.getSelected();
	        var params = {
		    tool_code : record.get('tool_code'),
		    appsys_code : record.get('appsys_code')
			
			};
				 app.loadWindow('${ctx}/${appPath}/ToolBoxController/front_edit',params); 
			}
		
						
  });						
				

	
	var  toolBoxReceiveindex=new toolBoxReceivepanel();

	var Return_Win = new Ext.Window({
		title:'<fmt:message key="toolbox.tool_returnreasons" />',
		layout:'form',
		width:450,
		height:150,
		plain:true,
		modal : false,
		closable : false,
		resizable : false,
		draggable : true,
		closeAction :'close',
		items : new Ext.form.FormPanel({
			buttonAlign : 'center',
			labelAlign : 'right',
			lableWidth : 15,
			frame : true,
			monitorValid : true,
			
			items:[
			
			{
				xtype : 'textarea',
				id : 'tool_returnreasons_update',
				fieldLabel : '<fmt:message key="toolbox.tool_returnreasons" />',
				name : 'tool_returnreasons',
				height : 60,
				width:250,
				maxLength:500,
				tabIndex : this.tabIndex++
			}],
			buttons : [{
					text :'退回',
  					iconCls : 'button-save',
  					tabIndex : this.tabIndex++,
  					formBind : true,
  					scope : this,
  					handler : toolBoxReceiveindex.doSaveReturn
  				},{
  					text : '<fmt:message key="button.cancel" />',
  					iconCls : 'button-cancel',
  					tabIndex : this.tabIndex++,
  					handler : toolBoxReceiveindex.doCancelReturn

  				} ]
		})
	});
	
	</script>

<sec:authorize access="hasRole('TOOL_RECEIVE')">
	<script type="text/javascript">
	toolBoxReceiveindex.grid.getTopToolbar().add({
		iconCls : 'button-start',
		text : '接收工具',
		scope : toolBoxReceiveindex,
		handler : toolBoxReceiveindex.doReceived
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('TOOL_RECEIVE')">
	<script type="text/javascript">
	toolBoxReceiveindex.grid.getTopToolbar().add({
		iconCls : 'button-deploy',
		text :  '退回工具',
		scope : toolBoxReceiveindex,
		handler : toolBoxReceiveindex.doReturn
	}, '-');
</script>
</sec:authorize>

<!--添加“修改按钮”  -->
<sec:authorize access="hasRole('FRONT_TOOL_EDIT')">
	<script type="text/javascriptFF">
	toolBoxReceiveindex.grid.getTopToolbar().add({
		iconCls:'button-edit',
		text:'一线描述',
		scope:toolBoxReceiveindex,
		handler:toolBoxReceiveindex.doEdit
	});
	</script>
</sec:authorize>

	<script type="text/javascript">
  
	Ext.getCmp("TOOLBOX_RECEIVEINDEX").add(toolBoxReceiveindex);
	Ext.getCmp("TOOLBOX_RECEIVEINDEX").doLayout();
</script>

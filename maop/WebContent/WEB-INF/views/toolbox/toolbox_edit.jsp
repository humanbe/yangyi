<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var ParamgridEdit;
var ServergridEdit;
var ServerStore;
var ServerStoreone;
var server_group_edit;
var Os_type_edit;
var appsys_code_edit='${param.appsys_code}';
var tool_getGroupEditStore;
var tool_GroupOsuserEditStore;
var tool_getOsuserEdit_Store;
var edit_field_type_twoStore;
var edit_field_type_threeStore;
var edit_field_type_one= decodeURIComponent('${param.field_type_one}') ;
var edit_field_type_two= decodeURIComponent('${param.field_type_two}') ;
var tool_btnSave_edit = Ext.getCmp("tool_move-save_edit");  
var env = '<fmt:message key="exportServer.toolpath" />';
var ProdFlag=(env.indexOf("PROD")==-1);

var osFlag=(appsys_code_edit=='COMMON');
var sty;
if(osFlag){
	sty='background : #F0F0F0';
}else{
	sty='';
}

	//定义列表
	ToolBox_editPanel = Ext.extend(Ext.FormPanel,{
		tabIndex : 0,// 查询表单组件Tab键顺序
		form :null,
		server_cm:null,
		check_value:null,
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
			}
			 else if (e.getKey() == 8) {
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
		tool_getOsuserEdit_Store = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getServerOs_user', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['osUser']),
			baseParams : {
				appsys_code : appsys_code_edit
			}
		});
		tool_getOsuserEdit_Store.load();
		tool_getGroupEditStore = new Ext.data.Store({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxController/findGroup',
				disableCaching : false
			}),
			reader: new Ext.data.JsonReader({}, ['value','serverGroup']),
			baseParams : {
				appsys_code : appsys_code_edit
			}
		});
		tool_getGroupEditStore.reload();
		tool_getGroupEditStore.on('beforeload',function(){
		//使用查询条件系统代码文本框时用
		tool_getGroupEditStore.baseParams.appsys_code ='${param.appsys_code}';
		},this); 
		tool_GroupOsuserEditStore = new Ext.data.Store({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxController/getGroupOsuser',
				disableCaching : false
			}),
			reader: new Ext.data.JsonReader({}, ['osUser']),
			baseParams : {
				appsys_code : appsys_code_edit
			}
		});
		tool_GroupOsuserEditStore.load();
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
							icon : Ext.MessageBox.INFO
						});
					}
				}
			}
		});
		this.appsys_Store.load();
		//一级分类
		this.field_type_oneStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_one'])
		});
		this.field_type_oneStore.load();
		//二级分类
		edit_field_type_twoStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_two']),
			baseParams : {
				field_type_one : edit_field_type_one
			}
		});
		edit_field_type_twoStore.load();
		//三级分类
		edit_field_type_threeStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_three']),
	    	baseParams : {
	    		field_type_one : edit_field_type_one,
	    		field_type_two : edit_field_type_two
		       }
		});
		edit_field_type_threeStore.load();
		this.ParamgridStore = new Ext.data.JsonStore(
		{
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
					'param_name', 
					'param_type', 
					'param_length', 'param_format',
					'param_value','param_default_value','param_desc' ],
			pruneModifiedRecords : true,
			remoteSort : false,
			sortInfo : {
				field : 'tool_code',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 20,
				tool_code :'${param.tool_code}',
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
			remoteSort : false,
			sortInfo : {
				field : 'tool_code',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 1000,
				tool_code :'${param.tool_code}',
				appsys_code:'${param.appsys_code}',
				os_type :'${param.os_type}',
				server_group:'${param.server_group}'
				
			}
		});
		// 加载列表数据
		this.ParamgridStore.load();

		csm = new Ext.grid.CheckboxSelectionModel();
		csm2 = new Ext.grid.CheckboxSelectionModel();
		
	    param_cm=new Ext.grid.ColumnModel([new Ext.grid.RowNumberer(),csm,
		{
			header : '<fmt:message key="toolbox.param_name" />',
			dataIndex : 'param_name',
			editor : new Ext.grid.GridEditor(
					new Ext.form.TextField({allowBlank:false,maxLength:20})
		    ),
			allowBlank : false,
			sortable : true
		},{
			header : '<fmt:message key="toolbox.param_type" />',
			dataIndex : 'param_type',
			renderer : this.ParamTypeone,
			width:50,
			editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
				typeAhead : true,
				triggerAction : 'all',
				hiddenName : 'param_type',
				mode : 'local',
				store : this.ParamTypeStore,
				displayField : 'name',
				valueField : 'value',
				editable : false
			})),
			scope : this,
			sortable : true
		},{
			header :  '<fmt:message key="toolbox.param_length" />',
			dataIndex : 'param_length',
			width:50,
			editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:4})
			),
			sortable : true
		},{
			header :  '<fmt:message key="toolbox.param_format" />',
			dataIndex : 'param_format',
		    editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:30})
			),  
			sortable : true
		},{
			header : '<fmt:message key="toolbox.param_default_value" />',
			dataIndex : 'param_value',
			editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:100})
			),
			sortable : true
		},{
			header : '<fmt:message key="toolbox.param_default_value" />',
			dataIndex : 'param_default_value',
			hidden : true,
			hideable : false 
			
		},  {
			header :'<fmt:message key="toolbox.param_desc" />',
			dataIndex : 'param_desc',
			width:200,
			editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:100})
			),
			sortable : true
		}
        ]);
		var param_model = Ext.data.Record.create([
				   { xtype : 'textfield',name : 'param_name'},
				   {xtype : 'combo',name: 'param_type',hiddenName : 'param_type',store : this.ParamTypeStore,valueField : 'value',displayField : 'name',editable : false},
				   { xtype : 'textfield', name: 'param_length'},
				   {  xtype : 'textfield',name:'param_format'},
				   {xtype : 'textfield',name:'param_value'},
				   {xtype : 'textfield',name:'param_default_value'},
				   {xtype : 'textfield',name:'param_desc'}
		]);

	   //服务器
	   server_cm=new Ext.grid.ColumnModel([new Ext.grid.RowNumberer(),csm2,
 					   {
 							header : '<fmt:message key="toolbox.server_ip" />',
 							dataIndex : 'server_ip',
 							sortable : true
 							
 						}, {
 							header :'<fmt:message key="toolbox.server_route" />',
 							dataIndex : 'server_route',
 							editor : new Ext.grid.GridEditor(
   									new Ext.form.TextField({maxLength:100})
							),
 							sortable : true
 						}, {
 							header :'<fmt:message key="toolbox.os_user" />',
 							dataIndex : 'os_user',
 							id:'server_OsuserEditID',
 							editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
   								//typeAhead : true,
   								triggerAction : 'all',
   								//hiddenName : 'os_user',
   								mode : 'local',
   								store :tool_getOsuserEdit_Store,
   								displayField : 'osUser',
   								valueField : 'osUser',
   								maxLength:30,
   								editable : ProdFlag
   							})),
 							sortable : true
 						}]); 


			ParamgridEdit = new Ext.grid.EditorGridPanel(
					{
						id : 'toolBoxParampanelid_edit',
						region : 'center',
						border : false,
						loadMask : true,
						height : 645,
						title : '<fmt:message key="toolbox.tool_param" />',
						columnLines : true,
						viewConfig : {
							forceFit : true
						},
						store : this.ParamgridStore,
						sm : csm,
						// 列定义

						cm : param_cm,
						// 定义按钮工具条

						tbar : new Ext.Toolbar({
						 items : [
								 {
									iconCls : 'button-add',
									text : '<fmt:message key="button.create" />',
									scope : this,
									handler : function() {
										ParamgridEdit.getStore().insert(0,new param_model({}));
										ParamgridEdit.startEditing(0,0);
									}
								 },
								 {
										iconCls : 'button-delete',
										text : '<fmt:message key="button.delete" />',
										scope : this,
										handler :function() {
											var param_records=ParamgridEdit.getSelectionModel().getSelections();
											ParamgridEdit.getStore().remove(param_records);
										}

								 }]
								}),
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.ParamgridStore,
							displayInfo : true,
							pageSize : 20
						}),
						// 定义数据列表监听事件
						listeners : {
							
							//编辑前完成后处理事件
							'beforeedit' : function(e) {
								
								
						    },
						  //编辑后完成后处理事件
							'afteredit' : function(e) {
							
								if(e.field == 'param_name'){
									var p_name = e.record.get('param_name');
									var len=ParamgridEdit.getStore().data.items.length;
									var check_param_name=0;
									for(var i=0;i<len;i++){
										if(ParamgridEdit.getStore().data.items[i].data.param_name==p_name)
											check_param_name++;
									}
									if(check_param_name>1){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '参数名称重复',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										}); 
										e.record.set('param_name',"");
									}
							      };
							  	if(e.field == 'param_length'){
							           var p_length=e.record.get("param_length");
										if(p_length.search(/^\d+$/)==-1&&p_length!=""){
											Ext.Msg.show( {
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="toolbox.input_correct_length" />',
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.WARNING,
												minWidth : 200
											}); 
											e.record.set('param_length',"");
										
									}
										
										if(e.record.get('param_length').trim().length>0 && e.record.get('param_value').trim().length>0){
											var def_val_len = e.record.get('param_value').length;
											var length=e.record.get('param_length');
											if(def_val_len>length){
												Ext.Msg.show( {
													title : '<fmt:message key="message.title" />',
													msg :'<fmt:message key="toolbox.input_correct_value_len" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.WARNING,
													minWidth : 200
												}); 
											e.record.set('param_value',"");
											e.record.set('param_default_value',"");
											   }
											
											  }	
							  	};
							      
								if(e.field == 'param_value'){
									if( e.record.get('param_value').trim()!=""){
									var putVal = e.record.get('param_value');
									if(e.record.get('param_type')==2){
										if(putVal.search(/^\d+$/)==-1){
											Ext.Msg.show( {
												title : '<fmt:message key="message.title" />',
												msg :  '<fmt:message key="toolbox.input_correct_integer" />',
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
										var istime = new RegExp("^\([0-1][0-9]|[2][0-4])\[0-5]{1}\[0-9]{1}$");
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
									
								if(!(e.record.get('param_length')==""||e.record.get('param_length')==undefined)){
								var def_val_len = e.record.get('param_value').length;
								var length=e.record.get('param_length');
								if(def_val_len>length){
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg :'<fmt:message key="toolbox.input_correct_value_len" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.WARNING,
										minWidth : 200
									}); 
								e.record.set('param_value',"");
								e.record.set('param_default_value',"");
								   }
								  }
									
									}else{
										e.record.set('param_value',"");
									e.record.set('param_default_value',"");
									}
								};
								
								
								
							    if(e.field == 'param_type'){
								if(e.record.get('param_type')==1){
									e.record.set("param_format",'<fmt:message key="toolbox.character" />');
									e.record.set("param_length","100");
								}
								if(e.record.get('param_type')==2){
									e.record.set('param_format','<fmt:message key="toolbox.integer" />');
									e.record.set("param_length","8");
								}
								if(e.record.get('param_type')==3){
									e.record.set('param_format',"YYYYMMDD");
									e.record.set("param_length","8");
								}
								if(e.record.get('param_type')==4){
									e.record.set('param_format',"HHMM");
									e.record.set("param_length","4");
								}
								if(e.record.get('param_type')==5){
									e.record.set('param_format',"100.100.100.100");
									e.record.set("param_length","15");
								}
								if(e.record.get('param_type')==6){
									e.record.set("param_format",'<fmt:message key="toolbox.character" />');
									e.record.set("param_length","100");
								}
								
								
								if(e.record.get('param_value').trim().length>0){
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
							}
							if(e.record.get('param_type')==6){
									 
									e.record.set('param_value',"");
									e.record.set('param_default_value',"");
					    		
							}
							if(e.record.get('param_type')==1&&"******"==putVal){
								e.record.set('param_value',"");
								e.record.set('param_default_value',"");
				    		
						}
								}
								
								if(e.record.get('param_length').trim().length>0&&e.record.get('param_value').trim().length>0){
									var def_val_len = e.record.get('param_value').length;
									var length=e.record.get('param_length');
									if(def_val_len>length){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg :'<fmt:message key="toolbox.input_correct_value_len" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										}); 
									e.record.set('param_value',"");
									e.record.set('param_default_value',"");
									   }
									  }
							} ;
							if(e.field == 'param_desc'){
								var p_desc = e.record.get('param_desc');
								var space = /^(\s+)|(\s+$)/g;
								p_desc=p_desc.replace(space,"");
								e.record.set('param_desc',p_desc);
				    			};
							if(e.field == 'param_name'){
								var p_name = e.record.get('param_name');
								var space = /^(\s+)|(\s+$)/g;
								p_name=p_name.replace(space,"");
								e.record.set('param_name',p_name);
				    			};
				 			Ext.getCmp('toolBoxParampanelid_edit').enable();
						  }
						}
					});

			// 实例化数据列表组件


			ServergridEdit = new Ext.grid.EditorGridPanel(
					{
						id : 'toolBoxServeredit_edit',
						region : 'center',
						border : false,
						loadMask : true,
						height : 645,
						title : '<fmt:message key="toolbox.server" />',
						columnLines : true,
						viewConfig : {
							forceFit : true
						},
						store : this.ServergridStore,
						sm : csm2,
						cm: server_cm,
						// 定义按钮工具条

						tbar : new Ext.Toolbar({
						
								}),
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.ServergridStore,
							displayInfo : true,
							pageSize : 10000
						}), 
						// 定义数据列表监听事件
						listeners : {
							//编辑前完成后处理事件
							'beforeedit' : function(e) {
								if(e.field == 'os_user'){
									
									tool_getOsuserEdit_Store.baseParams.serverips=e.record.get('server_ip');
									tool_getOsuserEdit_Store.reload();
								}
								
							
							},
							//编辑完成后处理事件

							'afteredit' : function(e) {
								if(e.field == 'server_ip'){
									 var s_ip = e.record.get('server_ip');
									var re=/^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/;
					    			if(!s_ip.match(re)){
					    				Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg :  '<fmt:message key="toolbox.toolinput_correct_ip" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										}); 
										e.record.set('server_ip',"");
					    			}
							};
							
							if(e.field == 'os_user'){
							var s_user = e.record.get('os_user');
							var space = /^(\s+)|(\s+$)/g;
							s_user=s_user.replace(space,"");
							e.record.set('os_user',s_user);
							
							var val=s_user.toLowerCase();
							if(val.trim()=="root"){
								Ext.Msg.show({
									title : '<fmt:message key="message.title"/>',
									msg : 'root用户不可手动输入，请联系平台管理员在操作用户信息添加',
									buttons : Ext.Msg.OK,
									icon : Ext.MessageBox.WARNING
								});
								e.record.set('os_user',"");
							}
			    			}
							
								Ext.getCmp('toolBoxServeredit_edit').enable();
							          }
						    }

					  });
			
			
			this.fivePanel = new Ext.Panel({
				
	              title:'匹配关键字',
				  frame : true,
				  split : false,
				  collapseMode : 'mini',
                  layout:'column',
                  border:false,
                  iconCls : 'menu-node-change',
                  layout: 'form',
                  defaults: {anchor:'90%'},
                  border:false,
                  labelWidth : 150,
                  labelAlign : 'right',
                  items : [{
						xtype : 'textfield',
						fieldLabel :'告警策略名称',
						name:'event_group',
						id : 'event_group_editID',
					    hidden:true,
						tabIndex : this.tabIndex++
					},
					{
						xtype : 'textarea',
						fieldLabel :'告警信息关键字',
						id : 'summarycn_editID',
						name : 'summarycn',
						height : 60,
						maxLength:500,
						tabIndex : this.tabIndex++
					}, 
					{
						xtype : 'label',
						text: '(匹配规则说明: &表示与; |表示或)',
						style : 'margin-left:160;color:red'
					},
					{
						xtype : 'treepanel',
						fieldLabel : '告警策略名称',
						id: 'policy_EditID',
						height : 300,
						frame : true,
						autoScroll: true,
						/* margins : '0 0 0 5', */
						root : new Ext.tree.AsyncTreeNode({
							text : '${param.appsys_code}',
							draggable : false,
							iconCls : 'node-root',
							id : 'EditrootId'
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
								//tree.getRootNode().expand(); 
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
				}],
				listeners : {

					scope : this,
					'activate' : function(panel) {
						setTimeout(function(){
							tool_btnSave_edit.show();
		                }, 2000);
					} 
				}
                 
		    
		});
			
			this.secondPanel = new Ext.Panel(
					{

						title : '<fmt:message key="title.script" />',
						buttonAlign :'center',
						items : [ {
							
							layout : 'form',
							
							defaults : {
								anchor : '90%'
							},
							border : false,
							items : [ {
								xtype : 'textarea',
								id : 'toolEdit_scriptID',
								name : 'script',
								height : 580,
								width : 500,
								style  : 'font-family:宋体;font-size:15px' , 
								readOnly : true,
								tabIndex : this.tabIndex++
							}  ]
						}],
						// 定义按钮
						tbar : [{
							text :'下载当前脚本',
							iconCls : 'button-download-excel',
							tabIndex : this.tabIndex++,
							scope : this,
							handler : this.downLoadScript
						},'--',{
							text : '查看历史版本',
							iconCls : 'button-search',
							tabIndex : this.tabIndex++,
							handler : this.checkhistoryScript

						}]
					});
			
			this.firstPanel = new Ext.Panel({
	              title:'<fmt:message key="toolbox.tool_properties" />',
	              layout:'column',
	              border:false,
	              autoScroll : true,
	              defaults:{bodyStyle:'padding-left:60px;padding-top:20px'},
	              iconCls : 'menu-node-change',
                  items:[{
                	  columnWidth:1,
                      layout: 'form',
                      defaults: {anchor : '80%'},
                      labelWidth : 160 ,
                      border:false,
                      labelAlign : 'right',
                      items : [{
										xtype : 'combo',
										store : this.appsys_Store,
										fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
										id:'appsys_code_editID',
										name : 'appsys_code',
										valueField : 'appsysCode',
										displayField : 'appsysName',
										hiddenName : 'appsys_code',
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false,
										listeners : {
											//编辑完成后处理事件
											select : function(obj) {
												tool_getGroupEditStore.load();
												ServerStore.load();
											}
										 }

									},
									{
										xtype : 'textfield',
										//id : 'tool_code_edit',
										fieldLabel : '<fmt:message key="toolbox.tool_code" />',
										name : 'tool_code',
										maxLength:80,
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										tabIndex : this.tabIndex++,
										allowBlank : false
									},{
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
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false
									},
									{
										xtype : 'combo',
										store : this.field_type_oneStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
										id:'field_type_oneid_edit',
										name : 'field_type_one',
										valueField : 'field_type_one',
										displayField : 'field_type_one',
										hiddenName : 'field_type_one',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false,
										listeners : {
											//编辑完成后处理事件



											select : function(obj) {
												edit_field_type_twoStore.baseParams.field_type_one =obj.value;
												edit_field_type_twoStore.load();
												Ext.getCmp('field_type_twoid_edit').setValue("");
												Ext.getCmp('field_type_threeid_edit').setValue("");
												Ext.getCmp('field_type_twoid_edit').el.up('.x-form-item').setDisplayed(true);
												Ext.getCmp('field_type_threeid_edit').el.up('.x-form-item').setDisplayed(false);
											}
										}
									},
									{
										xtype : 'combo',
										store : edit_field_type_twoStore,
										fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
										name : 'field_type_two',
										id: 'field_type_twoid_edit',
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
												edit_field_type_threeStore.baseParams.field_type_one =Ext.getCmp('field_type_oneid_edit').getValue();
												edit_field_type_threeStore.baseParams.field_type_two =obj.value;
												edit_field_type_threeStore.reload();
												Ext.getCmp('field_type_threeid_edit').setValue("");
												Ext.getCmp('field_type_threeid_edit').el.up('.x-form-item').setDisplayed(true);
												
											}
										}
									},
									{
										xtype : 'combo',
										store : edit_field_type_threeStore,
										fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
										name : 'field_type_three',
										id : 'field_type_threeid_edit',
										valueField : 'field_type_three',
										displayField : 'field_type_three',
										hiddenName : 'field_type_three',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++
									},{
										xtype : 'combo',
										store : this.tool_authorize_flagStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
										name : 'tool_authorize_flag',
										id:'tool_authorize_flag_editID',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'tool_authorize_flag',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false
									},

									{
										xtype : 'combo',
										store : this.tool_typeStore,
										fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
										name : 'tool_type',
										id:'tool_type_editID',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'tool_type',
										mode : 'local',
										style  : 'background : #F0F0F0' , 
										triggerAction : 'all',
										readOnly:true,
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false
									},
									{
										xtype : 'textfield',
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
										id:'tool_nameEditID',
										maxLength:100,
										name : 'tool_name',
										tabIndex : this.tabIndex++,
										allowBlank : false
									},
									{
										xtype : 'combo',
										store : tool_getGroupEditStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.server_group" />',
										id:'server_group_editID',
										name : 'server_group',
										valueField : 'value',
										displayField :'serverGroup' ,
										hiddenName : 'server_group',
										mode : 'local',
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
									 	listeners : {
											//编辑完成后处理事件
											select : function(obj) {
												ServerStore.load();
											}
										}
									},{
										xtype : 'combo',
										store : this.os_typeStore,
										fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_type" />',
										name : 'os_type',
										id:'os_type_editID',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'os_type',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										readOnly:osFlag,
										style  : sty , 
										
										tabIndex : this.tabIndex++,
										allowBlank : false
									},
									

									{
										xtype : 'combo',
										store : this.os_user_flagStore,
										fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_user_flag" />',
										id:'os_user_flag_edit',
										name : 'os_user_flag',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'os_user_flag',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										listeners : {
											//编辑完成后处理事件


											select : function(obj) {
												
												if('1'==obj.value){
													tool_GroupOsuserEditStore.load();
													Ext.getCmp('group_server_flag_edit').el.up('.x-form-item').setDisplayed(true);
												}else{
													Ext.getCmp('group_server_flag_edit').setValue("");
													Ext.getCmp('os_userId_edit').setValue("");
													Ext.getCmp('group_server_flag_edit').el.up('.x-form-item').setDisplayed(false);
													Ext.getCmp('os_userId_edit').el.up('.x-form-item',9).setDisplayed(false);
												};
											}
										}
									},
									{
										xtype : 'combo',
										store : this.server_group_flag,
										fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.group_server_flag" />',
										id:'group_server_flag_edit',
										name : 'group_server_flag',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'group_server_flag',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										listeners : {
											//编辑完成后处理事件

											 select : function(obj) {
												if('1'==obj.value){
													
													tool_GroupOsuserEditStore.reload();
													Ext.getCmp('os_userId_edit').el.up('.x-form-item').setDisplayed(true);
													
												}else{
													
													if(appsys_code_edit!='COMMON'){
													Ext.getCmp('os_userId_edit').setValue("");
													Ext.getCmp('os_userId_edit').el.up('.x-form-item').setDisplayed(false);
												}else{
													Ext.Msg.show({
														title : '<fmt:message key="message.title"/>',
														msg : '通用工具不能指定服务器',
														buttons : Ext.Msg.OK,
														icon : Ext.MessageBox.WARNING
													});
													obj.setValue('1');
													tool_GroupOsuserEditStore.reload();
													Ext.getCmp('os_userId_edit').el.up('.x-form-item').setDisplayed(true);
												}
												};
											} 
										}

									},
									{
										xtype : 'combo',
										store : tool_GroupOsuserEditStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_user" />',
										id:'os_userId_edit',
										name : 'os_user',
										valueField : 'osUser',
										displayField : 'osUser',
										hiddenName : 'os_user',
										mode : 'local',
										triggerAction : 'all',
										//forceSelection : true,
										editable : ProdFlag,
										tabIndex : this.tabIndex++,
										listeners : {
											//编辑完成后处理事件
											
											'keyup': function(obj) {
												var val=Ext.get('os_userId_edit').dom.value.toLowerCase();
												if(val.trim()=="root"){
													Ext.Msg.show({
														title : '<fmt:message key="message.title"/>',
														msg : 'root'+'用户不可手动输入，请联系平台管理员在操作用户信息添加',
														buttons : Ext.Msg.OK,
														icon : Ext.MessageBox.WARNING
													});
													Ext.getCmp('os_userId_edit').setValue("");
												}
											}
										}
									},
									
									
									{
										xtype : 'combo',
										store : this.position_typeStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.position_type" />',
										id:'position_type_edit',
										name : 'position_type',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'position_type',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false,
										listeners : {
											//编辑完成后处理事件

											select : function(obj) {
												if('1'==obj.value){
													
														Ext.getCmp('tool_upload_edit').el.up('.x-form-item').setDisplayed(true);
													
												}else{
													if(appsys_code_edit!="COMMON"){
													Ext.getCmp('tool_upload_edit').reset();
													Ext.getCmp('tool_upload_edit').el.up('.x-form-item').setDisplayed(false);
													}else{
														Ext.Msg.show({
															title : '<fmt:message key="message.title"/>',
															msg : '通用工具不能存放在被管服务器',
															buttons : Ext.Msg.OK,
															icon : Ext.MessageBox.WARNING
														});
														obj.setValue('1');
														Ext.getCmp('tool_upload_edit').reset();
													}
													
												};
											}
										}
									},
									{
										xtype : 'textfield',
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.shell_name" />',
										id:'shell_name_edit',
										name : 'shell_name',
										maxLength:50,
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										tabIndex : this.tabIndex++
									},
									 {
										xtype : 'fileuploadfield',
										fieldLabel:'<fmt:message key="toolbox.upload" />',
										name : 'tool_upload',
										id : 'tool_upload_edit',
										buttonText : '<fmt:message key="toolbox.glance" />',
										text:'...'
									}, 
									
									
									{
										xtype : 'combo',
										store : this.toolcharsetStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_charset" />',
										name : 'tool_charset',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'tool_charset',
										mode : 'local',
										triggerAction : 'all',
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false,
										listeners : {
											
											select : function(obj) {
												if(Ext.getCmp('toolEdit_scriptID').getValue()==undefined||Ext.getCmp('toolEdit_scriptID').getValue()==''){
												
												}else{
													Ext.getCmp('toolEdit_scriptID').setValue('');
												}
												}
											
										}
									},
									
									{
										xtype : 'textarea',
										fieldLabel :'<fmt:message key="toolbox.tool_desc" />',
										name : 'tool_desc',
										height : 60,
										maxLength:660,
										tabIndex : this.tabIndex++

									},{
										//一线接收工具描述
										xtype:'textarea',
										fieldLabel:'一线接收工具描述',
										name:'front_tool_desc',
										autoScroll : true,
										height:60,
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										maxLength:660,
										tabIndex:this.tabIndex++
									},{
										xtype : 'combo',
										id : 'tool_status_edit',
										store : this.tool_statusStore,
										fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_status" />',
										name : 'tool_status',
										valueField : 'value',
										displayField : 'name',
										hiddenName : 'tool_status',
										mode : 'local',
										triggerAction : 'all',
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										forceSelection : true,
										editable : false,
										tabIndex : this.tabIndex++,
										allowBlank : false
									},
									{
										xtype : 'textarea',
										id : 'tool_returnreasons_edit',
										fieldLabel :'<fmt:message key="toolbox.tool_returnreasons" />',
										name : 'tool_returnreasons',
										readOnly:true,
										style  : 'background : #F0F0F0' , 
										height : 50,
										maxLength:200,
										tabIndex : this.tabIndex++

									},
									{
										xtype : 'textfield',
										fieldLabel :'<fmt:message key="toolbox.tool_creator" />',
										name : 'tool_creator',
										hidden : true,
										tabIndex : this.tabIndex++

									},
									{
										xtype : 'textfield',
										fieldLabel :'<fmt:message key="toolbox.tool_modifier" />',
										name : 'tool_modifier',
										hidden : true,
										tabIndex : this.tabIndex++

									},
									{
										xtype : 'datefield',
										fieldLabel :'<fmt:message key="toolbox.tool_created_time" />',
										name : 'tool_created_time',
										hidden : true,
									    format : 'Y-m-d H:i:s',
										tabIndex : this.tabIndex++

									},
									{
										xtype : 'datefield',
										fieldLabel :'<fmt:message key="toolbox.tool_updated_time" />',
										name : 'tool_updated_time',
										format : 'Y-m-d H:i:s',
										hidden : true,
										tabIndex : this.tabIndex++

									},
									{
										xtype : 'textfield',
										id : 'paramValueId_edit',
										name : 'paramValue',
										tabIndex : this.tabIndex++,
										hidden : true
									} ,
									{
										xtype : 'textfield',
										id : 'serverValueId_edit',
										name : 'serverValue',
										tabIndex : this.tabIndex++,
										hidden : true
									} ]
				
                  }]
		    
		});
		
		 this.threePanel = new Ext.Panel({  
				items : [ParamgridEdit]
				
		    });
		 this.fourPanel = new Ext.Panel({
			 items : [ServergridEdit],
			 listeners : {
					//编辑完成后处理事件

					scope : this,
					'activate' : function(panel) {
						// 默认选中数据
						var records = this.ServergridStore.query('checked', true).getRange();
					
		                setTimeout(function(){
		                	ServergridEdit.getSelectionModel().selectRecords(records, false);
		                	
		                	if(Ext.getCmp('os_user_flag_edit').getValue()==0||Ext.getCmp('group_server_flag_edit').getValue()==1){
		                		records[0].set('os_user',"");
		                	}
		                }, 500);
					} 
				}
		    });
		 
		 var i = 0;  
		    function cardHandler(direction) {  
		        if (direction == -1) {  
		            i--;  
		            if (i < 0) {  
		                i = 0;  
		            }  
		            if(i==1){
		            	 if(Ext.getCmp('position_type_edit').getValue()==2){
				            	 i=0;
				            }
		            }
		        }  
		        if (direction == 1) {  
		            i++; 
		            if(i==1){
		            	 if(Ext.getCmp('position_type_edit').getValue()==2){
				            	 i=2;
				            }
		            }
		            if (i > 4) {  
		                i = 4;  
		                return false;  
		            }  
		        }  
		        var tool_btnNext_edit = Ext.getCmp("tool_move-next_edit");  
		        var tool_btnPrev_edit = Ext.getCmp("tool_move-prev_edit");  
		         tool_btnSave_edit = Ext.getCmp("tool_move-save_edit");  
		        if (i == 0) {  
		        	tool_btnSave_edit.hide();  
		            tool_btnNext_edit.enable();  
		            tool_btnPrev_edit.disable();  
		        }  
		        if (i == 1) {
		        	tool_btnSave_edit.hide();
					tool_btnNext_edit.enable();
					tool_btnPrev_edit.enable();
						
					if (Ext.getCmp('tool_nameEditID').getValue() == '') {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="toolbox.tool_name_space" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.WARNING,
										minWidth : 200
									});
							return i = 0;
						}
					if(Ext.getCmp('os_user_flag_edit').getValue() ==1&&Ext.getCmp('group_server_flag_edit').getValue()==''){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="toolbox.form_check_groupserver" />',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						});
						return i = 0;
						
					}
						
					if(Ext.getCmp('os_user_flag_edit').getValue() ==1&&Ext.getCmp('group_server_flag_edit').getValue()==1&&
					   Ext.getCmp('os_userId_edit').getValue()==''){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="toolbox.form_check_groupOsuser" />',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						});
						return i = 0;
					}
					
					var toolFilePath = Ext.getCmp('tool_upload_edit').getValue();
					var sname=Ext.getCmp('shell_name_edit').getValue();
					if(toolFilePath.indexOf(sname)==-1 && toolFilePath.length>0){
						Ext.getCmp('tool_upload_edit').reset();
						Ext.Msg.show({
							title : '<fmt:message key="message.title"/>',
							msg : '<fmt:message key="toolbox.shellname_check_same"/>',
							fn : function() {
								Ext.getCmp("tool_upload_edit").focus(true);
							},
							buttons : Ext.Msg.OK,
							icon : Ext.MessageBox.WARNING
						});
						return i = 0;
					} 
					var shname=sname.substring(sname.lastIndexOf('.') + 1);
					if(shname.toLowerCase()=='bat'&&Ext.getCmp('os_user_flag_edit').getValue()==1){
						Ext.Msg.show({
							title : '<fmt:message key="message.title"/>',
							msg : 'bat脚本不需指定操作用户',
							buttons : Ext.Msg.OK,
							icon : Ext.MessageBox.WARNING
						});
						return i = 0;
					}
					if(Ext.getCmp('position_type_edit').getValue()==1){
					if(toolFilePath!=''){
						toolBox_editPanel.getForm().submit({
							url : '${ctx}/${appPath}/ToolBoxController/getScript',
							scope : toolBox_editPanel,
							success : toolBox_editPanel.Success
					});
					}else{
						if(Ext.getCmp('toolEdit_scriptID').getValue()==undefined||Ext.getCmp('toolEdit_scriptID').getValue()==''){
						// 默认选中数据
						toolBox_editPanel.getForm().submit({
						url : '${ctx}/${appPath}/ToolBoxController/ftpScript',
						scope : toolBox_editPanel,
						success : toolBox_editPanel.Success
						
					});
						}
					}
				}else{
					var warn="被管服务器存放脚本,暂不支持查看,下载功能" ;
					Ext.getCmp('toolEdit_scriptID').setValue(warn);
				}
		        }
		        if(i== 2){
		        	    tool_btnSave_edit.hide();
						tool_btnNext_edit.enable();
						tool_btnPrev_edit.enable();
		        }
		       
		        if (i == 3) {  
		            //参数值

					var storeParam = ParamgridEdit.getStore();
					var m = storeParam.getModifiedRecords();
					//参数验证
					  for(var k=0;k<m.length;k++){
						var record=m[k];
						var fields=record.fields.keys;
						for(var j=0;j<1;j++){
							var name=fields[j];
							check_value=record.data[name];
							if(check_value==null||check_value==""){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.param_check_space"/>',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
								return i = 2;
							}
						}
					} 
					
					    tool_btnSave_edit.hide();  
						tool_btnNext_edit.enable();
						tool_btnPrev_edit.enable();
				 
		            
		        }  
		        
		        if (i == 4) {  
		            //参数值
				   
				   // tool_btnSave_edit.hide();  
		            tool_btnNext_edit.disable();  
		            tool_btnPrev_edit.enable(); 
		            
		        } 
		        this.cardPanel.getLayout().setActiveItem(i);  
		    };  
		 //CARD总面板  
	    this.cardPanel = new Ext.Panel({  
	        renderTo: document.body,  
	        height: 670,  
	        width: 670,  
	        layout: 'card',
	        layoutConfig :{
	        	deferredRender : true
	        },
	        activeItem: 0,  
	        tbar: ['-', {  
	            id: 'tool_move-prev_edit',  
	            iconCls : 'button-previous',
				text : '<fmt:message key="job.stepBefore" />',  
	            disabled:true,
	            handler: cardHandler.createDelegate(this, [-1])  
	        },'-',
	        {  
	            id: 'tool_move-save_edit',  
	            iconCls : 'button-save',
				text : '<fmt:message key="button.save" />',
	            hidden: true,  
	            handler:this.doSave
	        },'-',  
	        {  
	            id: 'tool_move-next_edit',  
	            iconCls : 'button-next',
				text : '<fmt:message key="job.stepNext" />',
	            handler: cardHandler.createDelegate(this, [1])  
	        }],  
	        items: [this.firstPanel, this.secondPanel,this.threePanel,this.fourPanel,this.fivePanel ]  
	    });

			// 设置基类属性
			ToolBox_editPanel.superclass.constructor.call(this,{
					 title : '<fmt:message key="title.form" />',
		                labelAlign : 'right',
		                buttonAlign : 'center',
		                fileUpload : true, 
		                frame : true,
		                autoScroll : true,
						layout : 'form',
						border : false,
						buttonAlign : 'center',
						url : '${ctx}/${appPath}/ToolBoxController/edit',
						defaults : {
							anchor : '100%',
							msgTarget : 'side'
						},
						monitorValid : true,

						items : [this.cardPanel]
							});
			// 加载表单数据
			this.form.load({
						url : '${ctx}/${appPath}/ToolBoxController/view',
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
		                 },
                 		// 保存操作  
						doSave : function() {

							var nodes = Ext.getCmp('policy_EditID').getChecked();
					    	var EventGroupInfos = '';
					    	for(var t=0 ; t<nodes.length ; t++){
								if(nodes[t].leaf == true){
									var py=nodes[t].text;
									var len=py.indexOf('(');
									EventGroupInfos=EventGroupInfos+"|"+py.substring(0,len).trim() ;
								}
					    	}
					    	if(EventGroupInfos!=''){
					    		EventGroupInfos=EventGroupInfos.substring(1);
					    	}
					    	
					    	Ext.getCmp('event_group_editID').setValue(EventGroupInfos);
						
							//上传   判断上传脚本名与原脚本名一致

							  var toolFilePath = Ext.getCmp('tool_upload_edit').getValue();
							  var sname=Ext.getCmp('shell_name_edit').getValue();
							if(toolFilePath.indexOf(sname)==-1 && toolFilePath.length>0){
								Ext.Msg.show({
									title : '<fmt:message key="message.title"/>',
									msg : '<fmt:message key="toolbox.shellname_check_same"/>',
									fn : function() {
										Ext.getCmp("tool_upload_edit").focus(true);
									},
									buttons : Ext.Msg.OK,
									icon : Ext.MessageBox.WARNING
								});
								return false;
							} 
							
							
							var storeParam = ParamgridEdit.getStore();
							var m = storeParam.getModifiedRecords();
							//参数验证
							  for(var i=0;i<m.length;i++){
								var record=m[i];
								var fields=record.fields.keys;
								for(var j=0;j<1;j++){
									var name=fields[j];
									check_value=record.data[name];
									if(check_value==null||check_value==""){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="toolbox.param_check_space"/>',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										});
										return ;
									}
								}
							} ; 
							
						
							var jsonParam = [];
							storeParam.each(function(item) {
								jsonParam.push(item.data);
							});
							Ext.getCmp("paramValueId_edit").setValue( Ext.util.JSON.encode(jsonParam));
							//服务器验证

							
							var a='';
							var b='';
							var c='';
							var jsonServer = [];
							var sm = ServergridEdit.getSelectionModel().getSelections();
							for(var i=0;i<sm.length;i++){
								 a =sm[i].get('server_ip');
								 b =sm[i].get('server_route');
								 c =sm[i].get('os_user');							
							
								  if(b==null||b==''){b=" ";};
								 if(c==null||c==''){c=" ";}; 
								jsonServer.push(a+"|+|"+b+"|+|"+c);
							}	
							
							Ext.getCmp("serverValueId_edit").setValue( Ext.util.JSON.encode(jsonServer));
							if(sm.length==0&&appsys_code_edit!="COMMON"){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.server_check"/>',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
								return false ;
							};
							if(sm.length!=1&&Ext.getCmp('group_server_flag_edit').getValue()==2){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.server_check_one"/>',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
								return false ;
							};
							 if(Ext.getCmp('position_type_edit').getValue()==2){
									var w=0;
									for(var i=0;i<sm.length;i++){
										if(!(sm[i].get('server_route')!="")||sm[i].get('server_route')==null){
											w++;		
										};
										if(w>0){
											Ext.Msg.show({
												title : '<fmt:message key="message.title"/>',
												msg : '<fmt:message key="toolbox.server_route_check"/>',
												buttons : Ext.Msg.OK,
												icon : Ext.MessageBox.WARNING
											});
											return false ;
										};
									 }
									};
							 if(Ext.getCmp('position_type_edit').getValue()==1){
									var w=0;
									for(var i=0;i<sm.length;i++){
										
										if(!(sm[i].get('server_route')==""||sm[i].get('server_route')==null)){
											w++;		
										};
										if(w>0){
											Ext.Msg.show({
												title : '<fmt:message key="message.title"/>',
												msg : '<fmt:message key="toolbox.shell_BSA_check"/>',
												buttons : Ext.Msg.OK,
												icon : Ext.MessageBox.WARNING
											});
											return false ;
										};
									 }
									}
							 

							 //用户判断
						    if(Ext.getCmp('group_server_flag_edit').getValue()==1 ){
								var w=0;
							 for(var i=0;i<sm.length;i++){
							if(!(sm[i].get('os_user')==""||sm[i].get('os_user')==null)){
								w++;		
							};
							if(w>0){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="toolbox.osuser_check_double"/>',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
								return false;
							  }
							 }
							};
							//用户判断
						    if(Ext.getCmp('os_user_flag_edit').getValue()==0){
								var w=0;
							 for(var i=0;i<sm.length;i++){
							if(!(sm[i].get('os_user')==""||sm[i].get('os_user')==null)){
								w++;		
							};
							if(w>0){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg :'<fmt:message key="toolbox.osuser_check_flag"/>',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
								return false;
							  }
							 }
							};
						
						
							if((Ext.getCmp('os_userId_edit').getValue()==null||Ext.getCmp('os_userId_edit').getValue()=="")&&Ext.getCmp('os_user_flag_edit').getValue()==1){
								var w=0;
								for(var i=0;i<sm.length;i++){
									if(sm[i].get('os_user')==""||sm[i].get('os_user')==null){
										w++;		
									};
									if(w>0){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="toolbox.osuser_check_space"/>',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.WARNING,
											minWidth : 200
										});
										return false ;
									};
								};
							} 
							
							if(appsys_code_edit=='COMMON'){
								 jsonServer = [];
								Ext.getCmp("serverValueId_edit").setValue( Ext.util.JSON.encode(jsonServer));
							}
							
				 toolBox_editPanel.getForm().submit(
						{
							scope : toolBox_editPanel,
							success : toolBox_editPanel.saveSuccess,
							failure : toolBox_editPanel.saveFailure,
							waitTitle : '<fmt:message key="message.wait" />',
							waitMsg : '<fmt:message key="message.saving" />'
						});  
							
						},

		//保存失败
		saveFailure : function(form, action) {

			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'
								+ error,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
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
							app.closeTab('TOOLBOX_EDIT');
							Ext.getCmp("toolBoxpanelid").getStore().reload();
							Ext.getCmp("toolBoxExcid").getStore().reload();
						}
			}); 

		},
		
		downLoadScript : function(){
			if(Ext.getCmp('position_type_edit').getValue()==1){
				window.location = '${ctx}/${appPath}/ToolBoxController/downloadfile.file?appsys_code=${param.appsys_code}&os_type=${param.os_type}&server_group=${param.server_group}&shell_name=${param.shell_name}';
			}else{
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '工具脚本存放在被管理服务器上,不可下载',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
			

		},
		
		downLoadHistoryScript :function(){
			
			
			var nodes = Ext.getCmp('historyscriptId').getChecked();
	    	var ScriptInfos = '';
	    	for(var t=0 ; t<nodes.length ; t++){
				if(nodes[t].leaf == true){
					ScriptInfos=ScriptInfos+"|"+nodes[t].text ;
				}
	    	}
	    	if(ScriptInfos!=''){
	    		ScriptInfos=ScriptInfos.substring(1);
	    	}
	    	if(nodes.length>0&&nodes.length<6){
	    		window.location = '${ctx}/${appPath}/ToolBoxController/downloadhistory.file?appsys_code=${param.appsys_code}&tool_code=${param.tool_code}&ScriptInfos='+ScriptInfos;
	    	}else{
	    		Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '请选择不超过5个历史脚本文件',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
	    	}
	    	
			
		},
		
		checkhistoryScript : function(){
			if(Ext.getCmp('position_type_edit').getValue()==1){
				historyScript.show();
			}else{
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '工具脚本存放在被管理服务器上,不可下载',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
			
		},

		
		frontLine_flagone : function(value) {

			var index = this.frontLine_flagStore.find('value', value);

			if (index == -1) {
				return value;
			} else {
				return this.frontLine_flagStore.getAt(index).get('name');
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
		tool_stausone : function(value) {

			var index = this.tool_stausStore.find('value', value);
			if (index == -1) {
				return value;
			} else {
				return this.tool_stausStore.getAt(index).get('name');
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
		ParamTypeone : function(value) {

			var index = this.ParamTypeStore.find('value', value);
			if (index == -1) {
				return value;
			} else {
				return this.ParamTypeStore.getAt(index).get('name');
			}
		},
		Success : function(form, action) {
			var data = decodeURIComponent(action.result.data);
			var scriptNr=Ext.getCmp('toolEdit_scriptID').setValue(data);
			var bottom = this.getHeight();
			this.body.scroll("b", bottom, true);
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
				if(Ext.getCmp('os_user_flag_edit').getValue()==0){
					Ext.getCmp('group_server_flag_edit').el.up('.x-form-item').setDisplayed(false);
					Ext.getCmp('os_userId_edit').el.up('.x-form-item').setDisplayed(false);
				};
				if(Ext.getCmp('os_user_flag_edit').getValue()==1&&Ext.getCmp('group_server_flag_edit').getValue()==2){
					Ext.getCmp('group_server_flag_edit').el.up('.x-form-item').setDisplayed(true);
					Ext.getCmp('os_userId_edit').el.up('.x-form-item').setDisplayed(false);
				};
				if(Ext.getCmp('position_type_edit').getValue()==2){
					Ext.getCmp('tool_upload_edit').el.up('.x-form-item').setDisplayed(false);
				};
				if(Ext.getCmp('appsys_code_editID').getValue()=="COMMON"){
					Ext.getCmp('server_group_editID').el.up('.x-form-item').setDisplayed(false);
				};
				
				if(null==Ext.getCmp('field_type_twoid_edit').getValue()||Ext.getCmp('field_type_twoid_edit').getValue()==""){
				Ext.getCmp('field_type_twoid_edit').el.up('.x-form-item').setDisplayed(false);
				Ext.getCmp('field_type_threeid_edit').el.up('.x-form-item').setDisplayed(false);
				}else{
					
				if(null==Ext.getCmp('field_type_threeid_edit').getValue()||Ext.getCmp('field_type_threeid_edit').getValue()==""){
					Ext.getCmp('field_type_threeid_edit').el.up('.x-form-item').setDisplayed(false);
					}
				};
				
				if(Ext.getCmp('tool_status_edit').getValue()!='3'){
					Ext.getCmp('tool_returnreasons_edit').el.up('.x-form-item').setDisplayed(false);
					}
				
				
				  this.ServergridStore.on('load', function(store) {
					  var records = this.ServergridStore.query('checked', true).getRange();
						ServergridEdit.getSelectionModel().selectRecords(records, false);
					}, this, {
						delay : 2000
					}); 
				    this.ServergridStore.load();
				
			},
		// 关闭操作
		doCancel : function() {
			app.closeTab('TOOLBOX_EDIT');
		      },
	    doCancelhistoryScript : function() {
	    	historyScript.hide();
	      }
	 });
	
	

	var toolBox_editPanel=new ToolBox_editPanel();
	
	var  historyScript = new Ext.Window({
		title:'历史脚本',
		layout:'form',
		width:450,
		height:350,
		plain:true,
		modal : true,
		closable : false,
		resizable : false,
		draggable : true,
		closeAction :'hide',
		items : new Ext.form.FormPanel({
			buttonAlign : 'center',
			labelAlign : 'right',
			lableWidth : 15,
			frame : true,
			monitorValid : true,
			
			items:[{
					xtype : 'treepanel',
					//fieldLabel : '', 
					id: 'historyscriptId',
					height : 260,
					frame : true,
					autoScroll: true,
					margins : '0 0 0 5',
					root : new Ext.tree.AsyncTreeNode({
						text : '${param.appsys_code}',
						draggable : false,
						iconCls : 'node-root',
						id : 'hSrootId'
					}),
					loader : new Ext.tree.TreeLoader({
						requestMethod : 'POST',
						dataUrl : '${ctx}/${appPath}/ToolBoxController/getHistoryScript',
						baseParams:{
							appsys_code:'${param.appsys_code}',
							tool_code:'${param.tool_code}',
							shell_name :'${param.shell_name}'
						}
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.expandAll();
						}
						
					}
			}],
			buttons : [{
					text :'下载',
  					iconCls : 'button-download-excel',
  					tabIndex : this.tabIndex++,
  					formBind : true,
  					scope : this,
  					handler : toolBox_editPanel.downLoadHistoryScript
  				},{
  					text : '<fmt:message key="button.cancel" />',
  					iconCls : 'button-cancel',
  					tabIndex : this.tabIndex++,
  					handler : toolBox_editPanel.doCancelhistoryScript

  				} ]
		})
	});
	
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("TOOLBOX_EDIT").add(toolBox_editPanel);
	// 刷新Tab页布局
	Ext.getCmp("TOOLBOX_EDIT").doLayout();


</script>
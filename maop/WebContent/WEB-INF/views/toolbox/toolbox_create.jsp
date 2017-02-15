<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
    var ServergridStore;
    var tool_getGroupStore;
    var tool_GroupOsuserStore;
    var tool_server_group;
    var tool_appsys_code;
    var tool_os_type;
    var tool_getOsuser_Store;
    var tool_ParamgridStore;
    var tool_field_type_twoStore;
    var tool_field_type_threeStore;
    var tool_Servergrid;
    var  Createparamgrid;
    var env = '<fmt:message key="exportServer.path" />';
    var ProdFlag=(env.indexOf("PROD")==-1);
	ToolBoxCreateTestForm = Ext.extend(Ext.FormPanel, {
		flag :true,
		tabIndex : 0,
		form:null,
		param_cm:null,
		server_cm:null,
		paramgrid:null,
		
		constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		csmServer = new Ext.grid.CheckboxSelectionModel();
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止		Ext.getDoc().on('keydown',function(e) {
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
		//数据字典
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
		this.tool_typeStore.on('load',function(){
			Ext.getCmp('tool_typeID').setValue('${param.tool_type}');
		},this); 
		
		this.tool_authorize_flagStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_authorize_flagStore.load();
		this.tool_authorize_flagStore.on('load',function(){
			Ext.getCmp('tool_authorize_flagID').setValue('${param.tool_authorize_flag}');
		},this); 
		
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
		this.authorize_level_typeStore.on('load',function(){
			Ext.getCmp('authorize_level_typeID').setValue('${param.authorize_level_type}');
		},this); 
		
		
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
		this.os_user_flagStore.on('load',function(){
			if('${param.appsys_code}'=="COMMON"){
				Ext.getCmp('os_user_flagID').setValue('1');
					
			}
		},this);
		this.toolcharsetStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/TOOL_CHARSET/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.toolcharsetStore.load();
		//服务器用户		tool_getOsuser_Store = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getServerOs_user', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['osUser']),
			baseParams:{
				appsys_code : tool_appsys_code
			}
		});
		tool_getOsuser_Store.load();
		tool_getOsuser_Store.on('beforeload',function(){
			//使用查询条件系统代码文本框时用			tool_getOsuser_Store.baseParams.appsys_code = Ext.getCmp("appsys_codeID").getValue();
		},this); 
		tool_getGroupStore = new Ext.data.Store({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxController/findGroup',
				disableCaching : false
			}),
			reader: new Ext.data.JsonReader({}, ['value','serverGroup']),
			baseParams : {
				appsys_code : tool_appsys_code
			}
		});
		tool_getGroupStore.load();
		tool_getGroupStore.on('beforeload',function(){
			//使用查询条件系统代码文本框时用			tool_getGroupStore.baseParams.appsys_code = Ext.getCmp("appsys_codeID").getValue();
		},this); 
		//组用户		tool_GroupOsuserStore = new Ext.data.Store({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxController/getGroupOsuser',
				disableCaching : false
			}),
			reader: new Ext.data.JsonReader({}, ['osUser']),
			baseParams : {
				appsys_code : tool_appsys_code
			}
		});
		tool_GroupOsuserStore.load();
		tool_GroupOsuserStore.on('beforeload',function(){
			tool_GroupOsuserStore.baseParams.appsys_code = Ext.getCmp("appsys_codeID").getValue();
		},this); 
		
		this.ParamTypeStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/PARAM_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.ParamTypeStore.load();
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
		
		this.appsys_Store.on('load',function(){
			Ext.getCmp('appsys_codeID').setValue('${param.appsys_code}');
			ServergridStore.load();
			tool_getGroupStore.load();
			tool_GroupOsuserStore.load();
			Ext.getCmp('os_userID').setValue("");
			Ext.getCmp('server_groupID').setValue("");
			if('${param.appsys_code}'=="COMMON"){
				Ext.getCmp('server_groupID').el.up('.x-form-item').setDisplayed(false);
				Ext.getCmp('os_typeID').setValue("");
				//Ext.getCmp('os_user_flagID').setValue('1');
				Ext.getCmp('group_server_flagID').el.up('.x-form-item').setDisplayed(true);
				//Ext.getCmp('group_server_flagID').setValue('1');
				Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(true);
				Ext.getCmp('os_userID').setValue('root');
				
				Ext.getCmp('position_typeID').setValue('');
				
			}else{
				Ext.getCmp('server_groupID').el.up('.x-form-item').setDisplayed(true);
			}
		},this); 
		
		this.toolbox_createtreeloader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/ToolBoxController/getEventGroupTree'
		});
		this.toolbox_createtree = new Ext.tree.TreePanel({
			xtype : 'treepanel',
			fieldLabel : '告警策略名称',
			id: 'policy_CreateID',
			height : 350,
			frame : true,
			autoScroll: true,
			root : new Ext.tree.AsyncTreeNode({
				draggable : false,
				iconCls : 'node-root',
				id : 'CreateRootId'
			}),
			loader : this.toolbox_createtreeloader,
			listeners : {
				scope : this,
				'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode_1 = node.parentNode; //分组目录
				              if(pNode_1 == this.toolbox_createtree.getRootNode()) return;
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
					            if(pNode_2 == this.toolbox_createtree.getRootNode()) return;
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
						            if(pNode_3 == this.toolbox_createtree.getRootNode()) return;
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
		});
		
		 
		this.server_group_flag = new Ext.data.JsonStore({
			url : '${ctx}/${frameworkPath}/item/GROUP_SERVER_FLAG/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.server_group_flag.load();
		this.server_group_flag.on('load',function(){
			if('${param.appsys_code}'=="COMMON"){
				Ext.getCmp('group_server_flagID').setValue('1');
			}
		},this); 
		//一级分类		this.tool_field_type_oneStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_one'])
			
		});
		this.tool_field_type_oneStore.load();
		//二级分类
		tool_field_type_twoStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_two'])
			
		});
		tool_field_type_twoStore.on('beforeload',function(){
			tool_field_type_twoStore.baseParams.field_type_one = Ext.getCmp("field_type_oneID").getValue();
		},this); 
		//三级分类
		tool_field_type_threeStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_three'])
			
		});
		tool_field_type_threeStore.on('beforeload',function(){
			tool_field_type_threeStore.baseParams.field_type_one = Ext.getCmp("field_type_oneID").getValue();
			tool_field_type_threeStore.baseParams.field_type_two = Ext.getCmp("field_type_twoID").getValue();
		},this); 
		//复选框
		csm = new Ext.grid.CheckboxSelectionModel();
		csm2 = new Ext.grid.CheckboxSelectionModel();
		//参数数据源		tool_ParamgridStore = new Ext.data.JsonStore(
		{
			proxy : new Ext.data.HttpProxy(
					{
						method : 'POST',
						url : '${ctx}/${appPath}/ToolBoxParamController/createparam',
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
			remoteSort : false,
			sortInfo : {
				field : 'tool_code',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//服务器数据源
		ServergridStore = new Ext.data.JsonStore(
		{
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/ToolBoxServerController/findip',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data3',
			totalProperty : 'count',
			fields : [ 'tool_code', 'appsys_code',
					'server_route', 'server_ip' ],
			pruneModifiedRecords : true,
			remoteSort : true,
			
			baseParams : {
				start : 0,
				limit : 10000,
				server_group: tool_server_group,
				appsys_code : tool_appsys_code,
				os_type : tool_os_type
				
			}
		});
		ServergridStore.on('beforeload',function(){
			//使用查询条件系统代码文本框时用			ServergridStore.baseParams.server_group = Ext.getCmp("server_groupID").getValue();
			ServergridStore.baseParams.appsys_code = Ext.getCmp("appsys_codeID").getValue();
			ServergridStore.baseParams.os_type = Ext.getCmp("os_typeID").getValue();
		},this); 
		// 加载列表数据
		tool_ParamgridStore.load();
	    editor_param=new Ext.grid.GridEditor(
			new Ext.form.TextField({allowBlank:false})
		);
	    param_cm=new Ext.grid.ColumnModel([new Ext.grid.RowNumberer(),
		                    						csm,
          						
          						 {
          							header : '<fmt:message key="toolbox.param_name" />',
          							dataIndex : 'param_name',
          							editor : new Ext.grid.GridEditor(
          									new Ext.form.TextField({allowBlank:false,maxLength:20})
  									),
          							allowBlank : false,
          							sortable : true
          						},  {
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
          						}, {
          							header :  '<fmt:message key="toolbox.param_length" />',
          							dataIndex : 'param_length',
          							width:50,
          							editor : new Ext.grid.GridEditor(
          									new Ext.form.TextField({maxLength:4})
  									),
          							sortable : true
          						}, {
          							header :  '<fmt:message key="toolbox.param_format" />',
          							dataIndex : 'param_format',
          							  editor : new Ext.grid.GridEditor(
          									new Ext.form.TextField({maxLength:30})
  									),
  									 sortable : true

          						},  {
          							header : '<fmt:message key="toolbox.param_default_value" />',
          							dataIndex : 'param_value',
          							editor : new Ext.grid.GridEditor(
          									new Ext.form.TextField({maxLength:100})
  									),
          							sortable : true
          						}, {
          							header : '<fmt:message key="toolbox.param_default_value" />',
          							dataIndex : 'param_default_value',
          							hidden : true,
          							hideable : false
          						}, {
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
				   {xtype : 'combo',name: 'param_type',hiddenName : 'param_type',store : this.flag2Store,valueField : 'value',displayField : 'name',editable : false},
				   { xtype : 'textfield', name: 'param_length'},
				   {  xtype : 'textfield',name:'param_format'},
				   {xtype : 'textfield',name:'param_value'},
				   {xtype : 'textfield',name:'param_default_value'},
				   {xtype : 'textfield',name:'param_desc'}]);
		//服务器
			  server_cm=new Ext.grid.ColumnModel([new Ext.grid.RowNumberer(),
	                    						csm2,
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
	                    							editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
	                      								triggerAction : 'all',
	                      								mode : 'local',
	                      								store :tool_getOsuser_Store,
	                      								displayField : 'osUser',
	                      								valueField : 'osUser',
	                      								maxLength:30,
	                      								allowBlank : false,
	                      								editable : ProdFlag
	                      							})
	                      							),
	                    							sortable : true
	                    						}]); 

	
		// 实例化参数数据列表组件		Createparamgrid = new Ext.grid.EditorGridPanel({
				id : 'toolBoxParamFormID',
				region : 'center',
				border : false,
				loadMask : true,
				height:645,
				title : '<fmt:message key="toolbox.tool_param" />',
				columnLines : true,
				viewConfig : {
					forceFit : true
				},
				store : tool_ParamgridStore,
				sm : csm,
				cm : param_cm,
						// 定义按钮工具条						tbar : new Ext.Toolbar({
							items : [{
									iconCls : 'button-add',
									text : '<fmt:message key="button.create" />',
									scope : this,
									handler : function() {
										Createparamgrid.getStore().insert(0,new param_model({}));
										Createparamgrid.startEditing(0,0);
									}
							 },{
									iconCls : 'button-delete',
									text : '<fmt:message key="button.delete" />',
									scope : this,
									handler :function() {
										var paramC_records=Createparamgrid.getSelectionModel().getSelections();
										Createparamgrid.getStore().remove(paramC_records);
									}
							 }]
						}),
						listeners : {
							//编辑完成后处理事件							'afteredit' : function(e) {
								if(e.field == 'param_name'){
									var p_name = e.record.get('param_name');
									var len=Createparamgrid.getStore().data.items.length;
									var check_param_name=0;
									for(var i=0;i<len;i++){
										if(Createparamgrid.getStore().data.items[i].data.param_name==p_name)
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
									if( e.record.get('param_value')!=""){
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
						    			e.record.set('param_default_value',"");
										e.record.set('param_value',"");
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
									}	
								};
								if(e.field == 'param_value'){
									if(e.record.get('param_length').trim().length>0){
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
								e.record.set('param_default_value',e.record.get('param_value'));
								 }
								}
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
								e.record.set('param_value',"");
								var putVal = e.record.get('param_value');
								
								if(e.record.get('param_value').trim().length>0){
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
				 			
									Ext.getCmp('toolBoxParamFormID').enable();
							}
						}

			});

			// 实例化服务器数据列表组件
			tool_Servergrid = new Ext.grid.EditorGridPanel({
				id : 'toolBoxServerFormID',
				region : 'center',
				border : false,
				loadMask : true,
                height:645,
				title : '<fmt:message key="toolbox.server" />',
				columnLines : true,
				viewConfig : {
					forceFit : true
				},
				store : ServergridStore,
				sm : csm2,
				cm: server_cm,
				// 定义按钮工具条				tbar : new Ext.Toolbar({items:[]}),
				// 定义分页工具条				bbar : new Ext.PagingToolbar({
					store : ServergridStore,
					displayInfo : true,
					pageSize : 10000
				}),
				// 定义数据列表监听事件
				listeners : {
					//编辑前完成后处理事件
					'beforeedit' : function(e) {
						if(e.field == 'os_user'){
							tool_getOsuser_Store.baseParams.serverips=e.record.get('server_ip');
							tool_getOsuser_Store.reload();
						}
						 if(Ext.getCmp('position_typeID').getValue()==1||Ext.getCmp('position_typeID').getValue()==""){
							if(e.field == 'server_route'){
								e.cancel = true;
							}
						}
						if(Ext.getCmp('os_user_flagID').getValue()==0||Ext.getCmp('os_user_flagID').getValue()=="" || Ext.getCmp('group_server_flagID').getValue()==1|| Ext.getCmp('group_server_flagID').getValue()==""){
							if(e.field == 'os_user'){
								e.cancel = true;
							}
						}
				    },
					//编辑完成后处理事件					'afteredit' : function(e) {
						if(e.field == 'server_route'){
							var s_route = e.record.get('server_route');
							var space = /^(\s+)|(\s+$)/g;
							s_route=s_route.replace(space,"");
							e.record.set('server_route',s_route);
							
							
			    			}
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
						Ext.getCmp('toolBoxServerFormID').enable();
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
                      defaults: {anchor:'85%'},
                      border:false,
                      labelWidth : 210,
	                  items : [{
								xtype : 'textfield',
								fieldLabel :'告警策略名称',
								name:'event_group',
								id : 'event_group_createID',
								hidden:true,
								tabIndex : this.tabIndex++
							},{
								xtype : 'textarea',
								fieldLabel :'告警信息关键字',
								id : 'summarycnID',
								name : 'summarycn',
								height : 80,
								maxLength:500,
								tabIndex : this.tabIndex++
							}, {
								xtype : 'label',
								text: '(匹配规则说明: &表示与; |表示或)',
								style : 'margin-left:220;color:red'
							},
							this.toolbox_createtree
					    ],
    					listeners : {
    						scope : this,
    						'activate' : function(panel) {
    							var appsys_codeID = Ext.getCmp('appsys_codeID').getValue() ;
    							this.toolbox_createtreeloader.baseParams.appsys_code = appsys_codeID;
    							this.toolbox_createtreeloader.baseParams.tool_code = '';
    							this.toolbox_createtree.getRootNode().setText(appsys_codeID);
    							this.toolbox_createtreeloader.load(this.toolbox_createtree.getRootNode(), function(n){
    								n.expand();
    							});
    						}
    					}
			});
			
			this.secondPanel = new Ext.Panel(
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
								id : 'toolCtrate_scriptID',
								name : 'script',
								style  : 'font-family:宋体;font-size:15px' , 
								height : 580,
								width : 500,
								readOnly : true,
								tabIndex : this.tabIndex++
							}  ]
						} ]
					});
			
			this.firstPanel = new Ext.Panel({
	              title:'<fmt:message key="toolbox.tool_properties" />',
	              layout:'column',
	              border:false,
	              defaults:{bodyStyle:'padding-left:60px;padding-top:40px'},
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
							fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
							id:'appsys_codeID',
							name : 'appsys_code',
							valueField : 'appsysCode',
							displayField : 'appsysName',
							hiddenName : 'appsys_code',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							//editable : false,
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
									
								},
								//编辑完成后处理事件								select : function(obj) {
									ServergridStore.load();
									tool_getGroupStore.load();
									tool_GroupOsuserStore.load();
									Ext.getCmp('os_userID').setValue("");
									Ext.getCmp('server_groupID').setValue("");
									if(obj.value=="COMMON"){
										Ext.getCmp('server_groupID').el.up('.x-form-item').setDisplayed(false);
										Ext.getCmp('os_typeID').setValue("");
										Ext.getCmp('os_user_flagID').setValue('1');
										Ext.getCmp('group_server_flagID').el.up('.x-form-item').setDisplayed(true);
										Ext.getCmp('group_server_flagID').setValue('1');
										Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(true);
										Ext.getCmp('os_userID').setValue('root');
										
										Ext.getCmp('position_typeID').setValue('');
										
									}else{
										Ext.getCmp('server_groupID').el.up('.x-form-item').setDisplayed(true);
									}
									
								}
							 }
					},{
						xtype : 'combo',
						store : this.authorize_level_typeStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
						name : 'authorize_level_type',
						id:'authorize_level_typeID',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'authorize_level_type',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						editable : false,
						tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						store : this.tool_field_type_oneStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
						name : 'field_type_one',
						id:'field_type_oneID',
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
								 tool_field_type_twoStore.load();
								Ext.getCmp('field_type_twoID').setValue("");
								Ext.getCmp('field_type_threeID').setValue("");
								Ext.getCmp('field_type_twoID').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('field_type_threeID').el.up('.x-form-item').setDisplayed(false);
							}
						}
					},
					{
						xtype : 'combo',
						store : tool_field_type_twoStore,
						fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
						name : 'field_type_two',
						id:'field_type_twoID',
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
								tool_field_type_threeStore.load();
								Ext.getCmp('field_type_threeID').setValue("");
								Ext.getCmp('field_type_threeID').el.up('.x-form-item').setDisplayed(true);
								
							}
						}
					},
					{
						xtype : 'combo',
						store :tool_field_type_threeStore,
						fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
						name : 'field_type_three',
						id:'field_type_threeID',
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
						fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
						name : 'tool_authorize_flag',
						id:'tool_authorize_flagID',
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
						id:'tool_typeID',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'tool_type',
						mode : 'local',
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
						name : 'tool_name',
						id:'tool_nameID',
						maxLength:100,
						tabIndex : this.tabIndex++,
						allowBlank : false
					},{
						xtype : 'combo',
						store : tool_getGroupStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.server_group" />',
						id:'server_groupID',
						name : 'server_group',
						valueField : 'value',
						displayField :'serverGroup',
						hiddenName : 'server_group',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						editable : false,
						tabIndex : this.tabIndex++,
					 	listeners : {
							//编辑完成后处理事件							select : function(obj) {
								ServergridStore.load();
							}
						}
					},{
						xtype : 'combo',
						store : this.os_typeStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_type" />',
						name : 'os_type',
						id:'os_typeID',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'os_type',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						editable : false,
						tabIndex : this.tabIndex++,
						allowBlank : false,
						listeners : {
							//编辑完成后处理事件
							select : function(obj) {
								ServergridStore.load();
							}
						 }
					},{
						xtype : 'combo',
						store : this.os_user_flagStore,
						fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_user_flag" />',
						id:'os_user_flagID',
						name : 'os_user_flag',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'os_user_flag',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						editable : false,
						tabIndex : this.tabIndex++,
						allowBlank : false,
						listeners : {
							//编辑完成后处理事件							select : function(obj) {
								if('1'==obj.value){
									Ext.getCmp('group_server_flagID').el.up('.x-form-item').setDisplayed(true);
								}else{
									Ext.getCmp('group_server_flagID').setValue("");
									Ext.getCmp('os_userID').setValue("");
									Ext.getCmp('group_server_flagID').el.up('.x-form-item').setDisplayed(false);
							    	Ext.getCmp('os_userID').el.up('.x-form-item',9).setDisplayed(false);
								};
							}
						}
					},{
						xtype : 'combo',
						store : this.server_group_flag,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.group_server_flag" />',
						id:'group_server_flagID',
						name : 'group_server_flag',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'group_server_flag',
						mode : 'local',
						triggerAction : 'all',
						editable : false,
						forceSelection : true,
						tabIndex : this.tabIndex++,
						listeners : {
							//编辑完成后处理事件							select : function(obj) {
								if('1'==obj.value){
									Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(true);
								}else{
									if(Ext.getCmp('appsys_codeID').getValue()!="COMMON"){
									Ext.getCmp('os_userID').setValue("");
									Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(false);
									}else{
										Ext.Msg.show({
											title : '<fmt:message key="message.title"/>',
											msg : '通用工具不能指定服务器',
											buttons : Ext.Msg.OK,
											icon : Ext.MessageBox.WARNING
										});
										obj.setValue('1');
										Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(true);
									}
								}
							}
						}
					},
					{
						xtype : 'combo',
						store : tool_GroupOsuserStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.os_user" />',
						id:'os_userID',
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
												var val=Ext.get('os_userID').dom.value.toLowerCase();
												if(val.trim()=="root"){
													Ext.Msg.show({
														title : '<fmt:message key="message.title"/>',
														msg : 'root用户不可手动输入，请联系平台管理员在操作用户信息添加',
														buttons : Ext.Msg.OK,
														icon : Ext.MessageBox.WARNING
													});
													Ext.getCmp('os_userID').setValue("");
												}
											}
						}
					},
					
					{
						xtype : 'combo',
						store : this.position_typeStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.position_type" />',
						name : 'position_type',
						id:'position_typeID',
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
							//编辑完成后处理事件							select : function(obj) {
								if('1'==obj.value){

										Ext.getCmp('tool_uploadCreatefileID').el.up('.x-form-item').setDisplayed(true);
										Ext.getCmp('shell_nameID').el.up('.x-form-item').setDisplayed(false);
										Ext.getCmp('shell_nameID').setValue("");
								}else{
									if(Ext.getCmp('appsys_codeID').getValue()!="COMMON"){
									Ext.getCmp('shell_nameID').el.up('.x-form-item').setDisplayed(true);
									Ext.getCmp('tool_uploadCreatefileID').el.up('.x-form-item').setDisplayed(false);
									Ext.getCmp('tool_uploadCreatefileID').reset();
									}else{
										Ext.Msg.show({
											title : '<fmt:message key="message.title"/>',
											msg : '通用工具不能存放在被管服务器',
											buttons : Ext.Msg.OK,
											icon : Ext.MessageBox.WARNING
										});
										obj.setValue('1');
										Ext.getCmp('tool_uploadCreatefileID').el.up('.x-form-item').setDisplayed(true);
										Ext.getCmp('shell_nameID').el.up('.x-form-item').setDisplayed(false);
										Ext.getCmp('shell_nameID').setValue("");
									}
								};
							}
						}
					},
					{
						xtype : 'textfield',
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.shell_name" />',
						id:'shell_nameID',
						name : 'shell_name',
						emptyText:'例如:test.sh',
						regex : /^[A-Za-z0-9_.]*$/,
						regexText : '脚本名称只能由字母、数字、下划线组成！',
						maxLength:50,
						tabIndex : this.tabIndex++
					},{
						xtype : 'fileuploadfield',
						fieldLabel:'<fmt:message key="toolbox.upload" />',
						name : 'tool_upload',
						id : 'tool_uploadCreatefileID',
						buttonText : '<fmt:message key="toolbox.glance" />',
						editable : true ,
						buttonCfg: {
							iconCls: 'upload-icon'
						}
					},
					{
						xtype : 'combo',
						store : this.toolcharsetStore,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_charset" />',
						name : 'tool_charset',
						id:'tool_charsetID',
						valueField : 'value',
						displayField : 'name',
						hiddenName : 'tool_charset',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						editable : false,
						tabIndex : this.tabIndex++,
						allowBlank : false
					},
					{
						xtype : 'textarea',
						fieldLabel : '<fmt:message key="toolbox.tool_desc" />',
						name : 'tool_desc',
						height : 60,
						maxLength:660,
						tabIndex : this.tabIndex++
					}, 
					{
						xtype : 'textfield',
						id : 'paramValueID',
						name : 'paramValue',
						tabIndex : this.tabIndex++,
						hidden : true
					},{
						xtype : 'textfield',
						id : 'serverValueID',
						name : 'serverValue',
						tabIndex : this.tabIndex++,
						hidden : true
					}]
                  }]
			 });
			
			 this.threePanel = new Ext.Panel({  
					items : [Createparamgrid]
		     });
			 this.fourPanel = new Ext.Panel({
				    items : [tool_Servergrid]
			 });
			 
			 var i = 0;  
			    function cardHandler(direction) {  
			        if (direction == -1) {  
			            i--;  
			            if (i < 0) {  
			                i = 0;  
			            }
			            if(i==1){
			            	 if(Ext.getCmp('position_typeID').getValue()==2){
					            	 i=0;
					            }
			            }
			           
			        }  
			        if (direction == 1) {  
			            i++; 
			            if(i==1){
			            	 if(Ext.getCmp('position_typeID').getValue()==2){
					            	 i=2;
					            }
			            }
			            if (i > 4) {  
			                i = 4;  
			                return false;  
			            }  
			        }  
			       
			        var btnNext = Ext.getCmp("tool_move-next_create");  
			        var btnPrev = Ext.getCmp("tool_move-prev_create");  
			        var btnSave = Ext.getCmp("tool_move-save_create");  
			        if (i == 0) {  
			            btnSave.hide();  
			            btnNext.enable();  
			            btnPrev.disable();  
			        }  
			        if (i == 1) {
						btnSave.hide();
						btnNext.enable();
						btnPrev.enable();
						if (Ext.getCmp('appsys_codeID').getValue() == ''||Ext.getCmp('tool_nameID').getValue() == ''||
							Ext.getCmp('authorize_level_typeID').getValue() == ''||
							Ext.getCmp('field_type_oneID').getValue() == ''||Ext.getCmp('os_typeID').getValue() == ''||
							Ext.getCmp('position_typeID').getValue() == ''||
							Ext.getCmp('os_user_flagID').getValue() == ''||Ext.getCmp('tool_charsetID').getValue() == ''||
							Ext.getCmp('tool_authorize_flagID').getValue() == '') {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="toolbox.form_check_space" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.WARNING,
										minWidth : 200
									});
							return i = 0;
						}
						if(!(Ext.getCmp('appsys_codeID').getValue()=="COMMON")&&Ext.getCmp('server_groupID').getValue() ==''){
							
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="toolbox.server_group_select" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.WARNING,
								minWidth : 200
							});
					return i = 0;
						}
							
						if(Ext.getCmp('os_user_flagID').getValue() ==1&&Ext.getCmp('group_server_flagID').getValue()==''){
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="toolbox.form_check_groupserver" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.WARNING,
								minWidth : 200
							});
							return i = 0;
							
						}
							
						if(Ext.getCmp('os_user_flagID').getValue() ==1&&Ext.getCmp('group_server_flagID').getValue()==1&&
						   Ext.getCmp('os_userID').getValue()==''){
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="toolbox.form_check_groupOsuser" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.WARNING,
								minWidth : 200
							});
							return i = 0;
						}
							
						var toolFilePath = Ext.getCmp('tool_uploadCreatefileID').getValue();
						var toolFilePrefix = toolFilePath.substring(toolFilePath.lastIndexOf('.') + 1);
					/* 	if(!( toolFilePrefix.toLowerCase() == 'bat' || toolFilePrefix.toLowerCase() == 'sh')&& Ext.getCmp('position_typeID').getValue()==1 ){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg :'<fmt:message key="toolbox.upload_check_sh"/>',
								fn : function() {
									Ext.getCmp("tool_uploadCreatefileID").focus(true);
								},
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.WARNING
							});
							return i = 0;
							
						}   */
						var sname=Ext.getCmp('shell_nameID').getValue();
						var shname=sname.substring(sname.lastIndexOf('.') + 1);
						/* if(!(shname.toLowerCase() == 'bat' ||shname.toLowerCase() == 'sh')&&Ext.getCmp('position_typeID').getValue()==2){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : '<fmt:message key="toolbox.upload_check_space"/>',
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.WARNING
							});
							return i = 0;
						} */
						if(shname.toLowerCase()=='bat'&&Ext.getCmp('os_user_flagID').getValue()==1){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : 'bat脚本不需指定操作用户',
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.WARNING
							});
							return i = 0;
						}
						if(toolFilePath!=''){
							ToolBoxCreateForm.getForm().submit({
								url : '${ctx}/${appPath}/ToolBoxController/getScript',
								scope : ToolBoxCreateForm,
								success : ToolBoxCreateForm.Success
						});
						}
							
					} 
			        if (i ==2) {
			        	  btnSave.hide(); 
				            btnNext.enable();  
				            btnPrev.enable(); 
			        }
			        if (i == 3) {  
			            //参数值
						var storeParam = tool_ParamgridStore;
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
					    btnSave.show();  
			            btnNext.enable();  
			            btnPrev.enable(); 
			        }
			        if (i == 4) { 
						btnSave.show();  
			            btnNext.disable();  
			            btnPrev.enable(); 
			        }
			        this.cardPanel.getLayout().setActiveItem(i);  
			    };  
			//CARD总面板  
		    this.cardPanel = new Ext.Panel({  
		        renderTo: document.body,  
		        height: 670,  
		        layout: 'card',
		        layoutConfig :{
		        	deferredRender : true
		        },
		        activeItem: 0,  
		        tbar: ['-', {  
		            id: 'tool_move-prev_create',  
		            iconCls : 'button-previous',
		            disabled : true ,
					text : '<fmt:message key="job.stepBefore" />',  
		            handler: cardHandler.createDelegate(this, [-1])  
		        },'-',
		        {  
		            id: 'tool_move-save_create',  
		            iconCls : 'button-save',
					text : '<fmt:message key="button.save" />',
		            hidden: true,  
		            handler:this.doSave
		        },'-',  
		        {  
		            id: 'tool_move-next_create',  
		            iconCls : 'button-next',
					text : '<fmt:message key="job.stepNext" />',
		            handler: cardHandler.createDelegate(this, [1])  
		        }],  
		        items: [this.firstPanel,this.secondPanel, this.threePanel,this.fourPanel,this.fivePanel ]  
		    });
			// 设置基类属性			ToolBoxCreateTestForm.superclass.constructor.call(this,{
                title : '<fmt:message key="title.form" />',
                labelAlign : 'right',
                buttonAlign : 'center',
                fileUpload : true, 
                frame : true,
                autoScroll : true,
				layout : 'form',
				border : false,
				buttonAlign : 'center',
				url : '${ctx}/${appPath}/ToolBoxController/create',
				defaults : {
					anchor : '100%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [  this.cardPanel]
			});
		},
		// 保存操作
		doSave : function() {
			var nodes = Ext.getCmp('policy_CreateID').getChecked();
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
	    	
	    	Ext.getCmp('event_group_createID').setValue(EventGroupInfos);
		
			//参数值			var storeParam = tool_ParamgridStore;
			var modified = storeParam.getModifiedRecords(); 
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
			Ext.each(modified, function(item) {
				jsonParam.push(item.data);
			}); 
			Ext.getCmp('paramValueID').setValue( Ext.util.JSON.encode(jsonParam));
			//服务器
			var a='';
			var b='';
			var c='';
			var jsonServer = [];
			var sm = tool_Servergrid.getSelectionModel().getSelections();
			for(var i=0;i<sm.length;i++){
				 a =sm[i].get('server_ip');
				 b =sm[i].get('server_route');
				 c =sm[i].get('os_user');							
			
				  if(b==null||b==''){b=" ";};
				 if(c==null||c==''){c=" ";}; 
				jsonServer.push(a+"|+|"+b+"|+|"+c);
			}	
			if(sm.length==0&&Ext.getCmp('appsys_codeID').getValue()!="COMMON"){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="toolbox.server_check"/>',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING,
					minWidth : 200
				});
				return false ;
			};
			if(sm.length!=1&&Ext.getCmp('group_server_flagID').getValue()==2){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="toolbox.server_check_one"/>',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING,
					minWidth : 200
				});
				return false ;
			};
			 if(Ext.getCmp('position_typeID').getValue()==2){
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
			 if(Ext.getCmp('position_typeID').getValue()==1){
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
			if( Ext.getCmp('os_user_flagID').getValue()==0 || Ext.getCmp('group_server_flagID').getValue()==1||Ext.getCmp('os_userID').getValue().length!=0){
				var w=0;
				for(var i=0;i<sm.length;i++){
					if(!(sm[i].get('os_user')==""||sm[i].get('os_user')==null)){
						w++;		
					};
					if(w>0){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg :  '<fmt:message key="toolbox.osuser_check_double"/>',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						});
						return false ;
					};
				};
			}
			if( !(Ext.getCmp('os_userID').getValue().length!=0)&&Ext.getCmp('os_user_flagID').getValue()==1){
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
			if(Ext.getCmp('appsys_codeID').getValue()=="COMMON"){
				 jsonServer = [];
			}
			Ext.getCmp('serverValueID').setValue(Ext.util.JSON.encode(jsonServer));
			
			
			ToolBoxCreateForm.getForm().submit({
				scope : ToolBoxCreateForm,
				success : ToolBoxCreateForm.saveSuccess,
				failure : ToolBoxCreateForm.saveFailure,
				 waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />' 
			});  
		},
		
		// 取消操作
		doCancel : function() {
			app.closeTab('TOOLBOX_CREATE');
		},
		// 重置查询表单
		doReset : function() {
			this.formServer.getForm().reset();
		},
		//键值对
		authorize_leve_typelone : function(value) {

			var index = this.authorize_level_typeStore.find('value', value);

			if (index == -1) {
				return value;
			} else {
				return this.authorize_level_typeStore.getAt(index).get('name');
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
		
		getServerGroupone : function(value) {

			var index = this.ServerGroupStore.find('serverGroup', value);
			if (index == -1) {
				return value;
			} else {
				return this.ServerGroupone('serverGroup');
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
		ParamTypeone : function(value) {
			var index = this.ParamTypeStore.find('value', value);
			if (index == -1) {
				return value;
			} else {
				return this.ParamTypeStore.getAt(index).get('name');
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

		// 向大文本内中放数据

		Success : function(form, action) {
			var data = decodeURIComponent(action.result.data);
			var scriptNr=Ext.getCmp('toolCtrate_scriptID').setValue(data);
			var bottom = this.getHeight();
			this.body.scroll("b", bottom, true);
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
							app.closeTab('TOOLBOX_CREATE');
							Ext.getCmp("toolBoxpanelid").getStore().reload();
							
					}
			}); 
		},
		// 保存失败回调
		saveFailure : function(form, action) {
			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'+ error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});

	var ToolBoxCreateForm=new ToolBoxCreateTestForm();
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("TOOLBOX_CREATE").add(ToolBoxCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("TOOLBOX_CREATE").doLayout();
	Ext.getCmp('tool_uploadCreatefileID').el.up('.x-form-item').setDisplayed(false);
	Ext.getCmp('group_server_flagID').el.up('.x-form-item').setDisplayed(false);
	Ext.getCmp('os_userID').el.up('.x-form-item').setDisplayed(false);
	Ext.getCmp('shell_nameID').el.up('.x-form-item').setDisplayed(false);
	
	Ext.getCmp('field_type_oneID').setValue(decodeURIComponent('${param.field_type_one}'));
	 tool_field_type_twoStore.load();
	   
	if('${param.field_type_two}'==''){
		//Ext.getCmp('field_type_twoID').el.up('.x-form-item').setDisplayed(false);
		Ext.getCmp('field_type_threeID').el.up('.x-form-item').setDisplayed(false);
	}else{
		Ext.getCmp('field_type_twoID').setValue(decodeURIComponent('${param.field_type_two}'));
		tool_field_type_threeStore.load();
	}
	if('${param.field_type_three}'==''){
		
	}else{
		Ext.getCmp('field_type_threeID').setValue(decodeURIComponent('${param.field_type_three}'));
	}
	
	
	
	
</script>
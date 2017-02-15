<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">



var gridStore;
var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
	
});
var SersysIdsStore = new Ext.data.Store({
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
/* var SersysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});  */ 
//定义列表
ServersSynchronousList = Ext.extend(Ext.Panel, {
	//gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		
		this. bsaAgentFlagStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/BSA_AGENT_FLAG/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
		this.bsaAgentFlagStore.load();
		
		this.Os_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/SERVER_OS_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.Os_typeStore.load();
	
		this.Data_typeStore = new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/DATA_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
		this.Data_typeStore.load();

		SersysIdsStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/serverssynchronous/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'serverIp','serverName','appsysCode','bsaAgentFlag','floatingIp','osType','mwType','dbType','collectionState','machineroomPosition',
			           'appPattern','serverUse','environmentType','serverRole','dataType','appsysCodeHide','serverIpHide'],
			remoteSort : true,
			sortInfo : {
				field : 'serverIp',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//加载数据源
		//gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			id : 'serversTypeListGridPanel',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : false
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="property.serverIp" />', dataIndex : 'serverIp', sortable : true},
				{header : '<fmt:message key="property.serverName" />', dataIndex : 'serverName', sortable : true},
				{header : '<fmt:message key="toolbox.appsys_code" />', dataIndex : 'appsysCode', sortable : true, renderer : this.serAppsys_Store},
				{header : '<fmt:message key="property.bsaAgentFlag" />', dataIndex : 'bsaAgentFlag', sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '未安装';
							case '1' : return '已经安装';
						
						}
					}
				},
				//{header : '<fmt:message key="property.serverGroup" />', dataIndex : 'serverGroup', sortable : true},
				{header : '<fmt:message key="property.floatingIp" />', dataIndex : 'floatingIp', sortable : true},
				{header : '<fmt:message key="property.osType" />', dataIndex : 'osType', sortable : true },
				{header : '<fmt:message key="property.mwType" />', dataIndex : 'mwType', sortable : true },
				{header : '<fmt:message key="property.dbType" />', dataIndex : 'dbType', sortable : true },
				{header : '<fmt:message key="property.collectionState" />', dataIndex : 'collectionState', sortable : true },
				{header : '<fmt:message key="property.environmentType" />', dataIndex : 'environmentType', sortable : true },
				{header : '<fmt:message key="property.machineroomPosition" />', dataIndex : 'machineroomPosition', sortable : true},
				{header : '<fmt:message key="property.serverRole" />', dataIndex : 'serverRole', sortable : true },
				{header : '<fmt:message key="property.serverUse" />', dataIndex : 'serverUse', sortable : true },
				{header : '<fmt:message key="property.dataType" />', dataIndex : 'dataType', sortable : true   , 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value.indexOf('A') != -1){
							return value.replace('A','自动同步');
						}
						if(value.indexOf('H') != -1){
							return value.replace('H','手工维护');
						}
					}   
				},
				{header : '<fmt:message key="property.appsysCode" />', dataIndex : 'appsysCodeHide', sortable : true,hidden: true,hideable : false},
				{header : '<fmt:message key="property.serverIp" />', dataIndex : 'serverIpHide', sortable : true,hidden: true,hideable : false}
	  		],
	  		
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				} ]
			})
		
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			id : 'serverssyncFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 110,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
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
					xtype : 'combo',
					fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
					store : SersysIdsStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'appsysCode',
					mode: 'local',
					typeAhead: true,
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
							}
					}
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serverIp" />',
					name : 'serverIp'
				},{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.machineroomPosition" />',
					name : 'machineroomPosition'
				},{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.osType" />',
					store : this.Os_typeStore,
					valueField : 'value',
					displayField : 'name',
					hiddenName :'osType',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				},{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serverUse" />',
					name : 'serverUse'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.bsaAgentFlag" />',
					store : this.bsaAgentFlagStore,
					valueField : 'value',
					displayField : 'name',
					hiddenName :'bsaAgentFlag',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.dataType" />',
					store : this.Data_typeStore,
					valueField : 'value',
					displayField : 'name',
					hiddenName :'dataType',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				}/* , 
				{
					xtype: 'checkboxgroup',
		         	fieldLabel: '<fmt:message key="property.bsaAgentFlag" />',
		         	anchor:'100%',
		         	items: [
		                {boxLabel: '未安装', name: 'bsaAgentFlag', checked:true ,value:'0'},
		                {boxLabel: '已安装', name: 'bsaAgentFlag', checked:true ,value:'1'}
			        ]
			 	}
				 */
			],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			} ]
		});

		// 设置基类属性
		ServersSynchronousList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	serAppsys_Store : function(value) {
		var index = SersysIdsStore.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return SersysIdsStore.getAt(index).get('appsysName');
		}
	},
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 配置管理信息获取
	doConf : function() {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.confirm.to.brpm" />',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(btn) {
				if(btn == 'ok'){
					app.mask.show();
				Ext.Ajax.request({
					url : '${ctx}/${managePath}/serverssynchronous/syncFromConfManagement',
					method : 'POST',
					scope : this,
					success : this.sysSuccess,
					disableCaching : true
				});
				}
			}
		});

	},
	// 配置管理信息获取
	doSynServer : function() {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.confirm.to.doSynServer" />',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(btn) {
				if(btn == 'ok'){
				Ext.Ajax.request({
					url : '${ctx}/${managePath}/serverssynchronous/syncSmartGroup',
					method : 'POST'
				});
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '操作成功',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.QUESTION
					});
				}
			}
		});

	},
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/serverssynchronous/servers_excel.xls';
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '没有数据,不可导出',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
		
	},
	// 删除事件
	doApply : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel()
					.getSelections();
			var serverIps = new Array();
			var appsysCodes = new Array();
			var json = [];
			for ( var i = 0; i < records.length; i++) {
				serverIps[i] = records[i].get('serverIpHide');
				appsysCodes[i] = records[i].get('appsysCodeHide');
				json.push(serverIps[i] + '|+|' + appsysCodes[i]);
			}
		/* 	Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.confirm.to.delete" />',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								app.mask.show();
								Ext.Ajax.request({
											url : '${ctx}/${managePath}/serverssynchronous/agentApply',
											timeout : 10000000,
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												serverIps : serverIps,
												appsysCodes : appsysCodes
											}
										});
							}
						}
					}); */
					var params = {
						data : Ext.util.JSON.encode(json)
					}
					app.loadWindow('${ctx}/${managePath}/serverssynchronous/apply',params);
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
	// BSA自动发现
	doAgent : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel().getSelections();
			var serverIps = new Array();
			var appsysCodes = new Array();
			var json = [];
			for ( var i = 0; i < records.length; i++) {
				serverIps[i] = records[i].get('serverIp');
				appsysCodes[i] = records[i].get('appsysCode');
				json.push(serverIps[i] + '|+|' + appsysCodes[i]);
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.agent" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(btn) {
					if(btn == 'ok'){
						app.mask.show();
						Ext.Ajax.request({
							url : '${ctx}/${managePath}/serverssynchronous/agent',
							timeout:6000000,
							method : 'POST',
							scope : this,
							success : this.agentSuccess,
							failure : this.sysFailure,
							disableCaching : true,
							params : {
								data : Ext.util.JSON.encode(json)
							}/*  ,
							 success : function(response, option) {
								var json = response.responseText;
								var json_response = Ext.util.JSON.decode(json);
								  app.mask.hide();
								  alert(json_response.agentInfo)
								  if(json_response.agentInfo!=''){
									Ext.Msg.show({
										title:'服务器',
										msg:json_response.agentInfo,
										buttons : Ext.MessageBox.OK,
										width:200,
										icon:Ext.MessageBox.INFO,
										fn:function(btn){
											if(btn =='ok'){
												gridStore.load();
											}
										}
									});
								  }
							}   */
						});
					}
				}
			});
		}else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	
	//同步成功
 	sysSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.successful" /><br>'+decodeURIComponent(Ext.decode(response.responseText).error),
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					
					if(btn =='ok'){
						gridStore.load();
						var params = {
								Path : encodeURI(decodeURIComponent(Ext.decode(response.responseText).Path))
							};
						
							if ("0"!=Ext.decode(response.responseText).errNum) {
								app.loadWindow('${ctx}/${managePath}/serverssynchronous/errorlist',params);
							}
					}
				}
			});
		}
	} ,
	sysFailure:function(response, options) {
		
		var error = Ext.decode(response.responseText).error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
			
		});
	},
	agentSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.agent.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			
				var json = response.responseText;
				var json_response = Ext.util.JSON.decode(json);
				  app.mask.hide();
				  if(json_response.agentInfo!=''){
					Ext.Msg.show({
						title:'服务器',
						msg:json_response.agentInfo,
						buttons : Ext.MessageBox.OK,
						width:200,
						icon:Ext.MessageBox.INFO,
						fn:function(btn){
							if(btn =='ok'){
								gridStore.load();
							}
						}
					});
				  }
			
		}
	},
	// 修改事件
	doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			
			var record = this.grid.getSelectionModel().getSelected();
			if(record.data.dataType=="H"){
			var params = {
					
					appsysCode : record.data.appsysCodeHide,
					serverIp :record.data.serverIpHide
					
			};
			app.loadTab(
							'SERVER_EDIT',
							'<fmt:message key="button.edit" />',
							'${ctx}/${managePath}/serverssynchronous/editServersInfo',
							params);
			
			}else{
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '自动同步，不可修改',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
		} else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.only" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}
	},
	//新建审批流程--------------------------------------------------------------------------------------------------------
	doCreate : function() {
		           var params = {};
					app.loadWindow('${ctx}/${managePath}/ApplicationProcess/create',params);

				},
	
	
	 doImport : function(){
		dialog = new Ext.ux.UploadDialog.Dialog({
			url : '${ctx}/${managePath}/common/upload',
			title: '<fmt:message key="button.upload"/>' ,   
			post_var_name:'uploadServerFiles',//这里是自己定义的，默认的名字叫file  
			width : 450,
			height : 300,
			minWidth : 450,
			minHeight : 300,
			draggable : true,
			resizable : true,
			//autoCreate: true,
			constraintoviewport: true,
			permitted_extensions:['xls','xlsx'],
			modal: true,
			reset_on_hide: false,
			allow_close_on_upload: false,    //关闭上传窗口是否仍然上传文件   
			upload_autostart: false     //是否自动上传文件   

		});    
		dialog.show(); 
		dialog.on( 'uploadsuccess' , onUploadServerSuccess); //定义上传成功回调函数
		//dialog.on( 'uploadcomplete' , onUploadComplete); //定义上传完成回调函数
	}, 
	doExportserversXLS : function(){
		window.location = '${ctx}/${managePath}/serverssynchronous/downloadserverImport.file';
	}
	
	
});

var serversSynchronousList = new ServersSynchronousList();

//文件上传成功后的回调函数
onUploadServerSuccess = function(dialog, filename, resp_data, record){
	dialog.hide(); 
	app.mask.show();
	Ext.Ajax.request({
		url : "${ctx}/${managePath}/serverssynchronous/importServers",
		params : {
			filePath : resp_data.filePath
		},
		method : 'POST',
		scope : this,
		timeout : 99999999,
		success : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.import.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					width : 400,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.import.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
				gridStore.reload();
			}
		},
		failure : function(response) {
			app.mask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
};
</script>

<sec:authorize access="hasRole('SERVER_SYN')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-sync',
	text : '<fmt:message key="button.doConf" />',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doConf
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SERVER_SYN')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-sync',
	text : '巡检服务器更新',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doSynServer
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYSTEM_AGENT_CHECK')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-detect',
	text : '<fmt:message key="button.agent" />',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doAgent
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SERVER_EDIT')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '编辑',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doEdit
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SERVER_IMPORT')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-excel',
	text : '服务器<fmt:message key="button.import" />',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doImport
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('SERVER_APPLY')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-excel',
	text : '服务器<fmt:message key="button.import" />申请',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doCreate
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SERVER_APPLY')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-download-excel',
	text : '下载导入模板',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doExportserversXLS
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SERVER_APPLY')">
<script type="text/javascript">
serversSynchronousList.grid.getTopToolbar().add({
	iconCls : 'button-sync',
	text : '代理安装申请',
	scope : serversSynchronousList,
	handler : serversSynchronousList.doApply
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
Ext.getCmp("MarServersSynchronous").add(serversSynchronousList);
Ext.getCmp("MarServersSynchronous").doLayout();
</script>

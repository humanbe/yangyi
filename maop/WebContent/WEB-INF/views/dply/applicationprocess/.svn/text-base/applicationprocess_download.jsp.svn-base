<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var Loaduser2;
var Back_record_ids;
var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
	
});
 
//定义列表
ApplicationProcess = Ext.extend(Ext.Panel, {
	//gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	gridStore:null,
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();
		
		
		this.subject_info = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/SUBJECT_INFO/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.subject_info.load();
		this.process_status = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/PROCESS_STATUS/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.process_status.load();
		
		this.OsUserUserIdStore = new Ext.data.Store(
				{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								url : '${ctx}/${managePath}/ApplicationProcess/findUserId'
							}),
							reader: new Ext.data.JsonReader({}, ['userId','name'])
				});
		this.OsUserUserIdStore.load();
		
		
		//登录用户
		var userNameStore2 =  new Ext.data.Store({
				proxy: new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${managePath}/ApplicationProcess/getUserName',
					disableCaching : false
				}),
				reader: new Ext.data.JsonReader({}, ['UName','RoleName','UId'])
				
			});
			userNameStore2.load();
			userNameStore2.on('load',function(){
				//当前用户
				 Loaduser2= userNameStore2.data.items[0].data.UName; 
			},this);
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/ApplicationProcess/downloadIndex',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'record_id','subject_info','handled_user','application_user','current_state',
			           'order_consuming_time','completed_time','application_time','application_reasons',
			           'process_description'],
			remoteSort : true,
			sortInfo : {
				field : 'application_time',
				direction : 'DESC'
			},
			baseParams : {
				start : 0,
				limit : 100
				//,status: '1'
			}
		});
		//加载数据源
		this.gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			//id : '',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : false
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
			            {header : '<fmt:message key="application.record_id" />', dataIndex : 'record_id', sortable : true,width: 200},
						{header : '<fmt:message key="application.subject_info" />', dataIndex : 'subject_info',width: 150, sortable : true,renderer:this.subject_infoone,scope : this},
							
						{header : '<fmt:message key="application.current_state" />', dataIndex : 'current_state', sortable : true,renderer:this.process_statusone,scope : this},
						{header : '<fmt:message key="application.order_consuming_time" />', dataIndex : 'order_consuming_time', sortable : true },
						{header : '<fmt:message key="application.application_user" />', dataIndex : 'application_user', sortable : true ,scope : this, renderer:this.OsUserUserIdStoreone },
						{header : '<fmt:message key="application.application_reasons" />', dataIndex : 'application_reasons', sortable : true,width: 200 ,
							renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
							    //build the qtip:    
							    var title = '<fmt:message key="application.application_reasons" />';
							    var tip = record.get('application_reasons');    
							    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

							    //return the display text:    
							    var displayText =  record.get('application_reasons') ;    
							    return displayText;    

							}},
						{header : '<fmt:message key="application.handled_user" />', dataIndex : 'handled_user', sortable : true ,scope : this},
						{header : '<fmt:message key="application.completed_user" />', dataIndex : 'completed_user', sortable : true ,scope : this},
						{header : '<fmt:message key="application.application_time" />', dataIndex : 'application_time', sortable : true,width: 130 },
						{header : '<fmt:message key="application.handled_time" />', dataIndex : 'handled_time', sortable : true ,width: 130},
						{header : '<fmt:message key="application.completed_time" />', dataIndex : 'completed_time', sortable : true ,width: 130},
						{header : '<fmt:message key="application.process_description" />', dataIndex : 'process_description', sortable : true,width: 250, hidden:true,
							renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
							    //build the qtip:    
							    var title ='<fmt:message key="application.process_description" />';
							    var tip = record.get('process_description');
							    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

							    //return the display text:    
							    var displayText =  record.get('process_description') ;    
							    return displayText;    
							}
						}],
	  		
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-' ]
			})
		
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
		//	id :,
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 70,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 250,
			minSize : 230,
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
			items : [ {
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="application.application_user" />',
					name : 'application_user'
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="application.handled_user" />',
					name : 'handled_user'
				},{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="application.current_state" />',
					store : this.process_status,
					valueField : 'value',
					displayField : 'name',
					hiddenName :'current_state',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    tabIndex : this.tabIndex++
				}
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
		ApplicationProcess.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
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
	subject_infoone : function(value) {

		var index = this.subject_info.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return this.subject_info.getAt(index).get('name');
		}
	},
	process_statusone : function(value) {

		var index = this.process_status.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return this.process_status.getAt(index).get('name');
		}
	},
	doDownload : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel()
					.getSelections();
			var recordIds = new Array();
			var json = [];
			for ( var i = 0; i < records.length; i++) {
				recordIds[i] = records[i].get('record_id');
			}
		
			window.location = '${ctx}/${managePath}/ApplicationProcess/servers_download.xls?recordIds='+recordIds+'';
					
				
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
	OsUserUserIdStoreone : function(userId) {

		var index = this.OsUserUserIdStore.find('userId', userId);
		if (index == -1) {
			return userId;
		} else {
			return this.OsUserUserIdStore.getAt(index).get('name');
		}
	}
});
var applicationProcess = new ApplicationProcess();
</script>
<sec:authorize access="hasRole('PROCESS_DOWNLOAD')">
<script type="text/javascript">
applicationProcess.grid.getTopToolbar().add({
	text : '下载代理安装列表',
	iconCls : 'button-download-excel',
	scope : applicationProcess,
	handler : applicationProcess.doDownload
	},'-');
</script>
</sec:authorize>
<script type="text/javascript">
Ext.getCmp("APPLICATIONPROCESS_DOWNLOAD").add(applicationProcess);
Ext.getCmp("APPLICATIONPROCESS_DOWNLOAD").doLayout();
</script>

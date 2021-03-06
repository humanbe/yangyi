<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var mvToolsimport ;
var miToolsimport ;
var mvToolsimportGrid ;
var mvToolsimportGridStore ;
 
var toolboximportmask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
});

var ftpGettools = function(){
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${appPath}/ToolBoxController/ftpgettools',	
		scope : this,
		success:function(){
			importToolsStore.load();
		},
		disableCaching : true
	});
};
ftpGettools();

var importToolsStore = new Ext.data.JsonStore( {
		proxy : new Ext.data.HttpProxy(
				{
					method : 'POST',
					url : '${ctx}/${appPath}/ToolBoxController/getToolslist',
					timeout : 300000,
					disableCaching : true
						}),
					    root : 'data',
						fields : ['appsys_code','tool_code','tool_type','tool_name','file_name'],
						remoteSort : false,
						sortInfo : {
							field : 'tool_type',
							direction : 'ASC'
						},
						baseParams : {
							start : 0,
							limit : 1000
						}
						
	});


//定义新建表单
ToolboxExportForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		
	
		mvToolsimport = new Ext.grid.CheckboxSelectionModel();
		miToolsimport = new Ext.grid.CheckboxSelectionModel();

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
		this.tool_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_typeStore.load();
		//可选择的请求
		this.dsFromTranImport = new Ext.grid.GridPanel({
			id : 'mvImExport', 
			height : 565 ,
			loadMask : true,
			frame : true,
			title : '可选择的工具',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : importToolsStore,
			autoExpandColumn : 'name',
			sm : mvToolsimport,   
			columns : [new Ext.grid.RowNumberer(),
			          mvToolsimport,{
				header :'<fmt:message key="toolbox.appsys_code" />',
				dataIndex : 'appsys_code',
				renderer : this.appsys_Storeone,
				scope : this,
				sortable : true
	    	},{
				header : '<fmt:message key="toolbox.tool_code" />',
				name:'tool_code',
				dataIndex : 'tool_code',
				sortable : true
		    },{
				header :  '<fmt:message key="toolbox.tool_name" />',
				dataIndex : 'tool_name',
				//hidden:true,
				width:200, 
				sortable : true
			},{
				header :'<fmt:message key="toolbox.tool_type" />',
				dataIndex : 'tool_type',
				renderer : this.toolType_Storeone,
				scope : this,
				sortable : true
			},{
				header : '文件名称',
				name:'file_name',
				hidden:true,
				dataIndex : 'file_name',
				sortable : true
		    } ],
		    
		    
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移入事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = importToolsStore.getAt(rowIndex);
					var appsys_code = curRow.get("appsys_code");
					var tool_code = curRow.get("tool_code");
					var notEqualFlag = true;
					mvToolsimportGrid.getStore().each(function(rightRecord){
						if(appsys_code==rightRecord.data.appsys_code && tool_code==rightRecord.data.tool_code){
							notEqualFlag = false;
						}
					},this);
					if(notEqualFlag){
						mvToolsimportGrid.store.add(curRow);
					}
				}
			}
		});
		//移入移出操作面板
		this.panel = new Ext.Panel({
			height : 565 ,
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
		         text: '<fmt:message key="job.movein" />>>',
		         scope : this,
				 handler : this.requestShiftIn
		     },{
		         xtype:'button',
		         width : 40 ,
		         height : 25 ,
		         text: '<<<fmt:message key="job.moveout" />',
		         scope : this,
		         handler : this.requestShiftOut
		     }]
		}); 
		//已选择的工具		mvToolsimportGridStore=new Ext.data.JsonStore({
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['appsys_code','tool_code','tool_type','tool_name','file_name'],
			remoteSort : true
		});
		mvToolsimportGrid = new Ext.grid.GridPanel({
			id : 'selectedToolimport',
			height : 565 ,
			loadMask : true,
			frame : true,
			title :'<fmt:message key="toolbox.tool_selected" />',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			
			store : mvToolsimportGridStore,
			autoExpandColumn : 'name',
			sm : miToolsimport,   
			columns : [new Ext.grid.RowNumberer(),
			           miToolsimport,
			           {
							header :'<fmt:message key="toolbox.appsys_code" />',
							dataIndex : 'appsys_code',
							renderer : this.appsys_Storeone,
							scope : this,
							sortable : true
				    	},{
							header : '<fmt:message key="toolbox.tool_code" />',
							name:'tool_code',
							//hidden:true,
							dataIndex : 'tool_code',
							sortable : true
					    },{
							header :  '<fmt:message key="toolbox.tool_name" />',
							dataIndex : 'tool_name',
							//hidden:true,
							width:200, 
							sortable : true
						},{
							header :'<fmt:message key="toolbox.tool_type" />',
							dataIndex : 'tool_type',
							renderer : this.toolType_Storeone,
							scope : this,
							sortable : true
						},{
							header : '文件名称',
							name:'file_name',
							hidden:true,
							dataIndex : 'file_name',
							sortable : true
					    }],
			
			
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = mvToolsimportGridStore.getAt(rowIndex);
					mvToolsimportGrid.store.remove(curRow);
				}
			}
		}); 
		
		// 设置基类属性		ToolboxExportForm.superclass.constructor.call(this, {
			title : '<fmt:message key="toolbox.tool_import" />',
			labelAlign : 'right',
			labelWidth : 150,
			buttonAlign : 'center',
			frame : true,
			timeout : 300,
			autoScroll : true,
			url : '${ctx}/${managePath}/moveimport/import',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
		    items:[{
		        	/* columnWidth : .5,
		            xtype: 'fieldset', */
		            layout : 'form',
		            border : true,
					buttonAlign : 'center',
		            autoHeight : true,
		            items : [ {
						xtype : 'combo',
						fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
						store : this.appsys_Store,
						name : 'appsys_code',
						id:'appsys_code_importid',
						hiddenName : 'appsys_code',
						displayField : 'appsysName',
						valueField : 'appsysCode',
						typeAhead : true,
						forceSelection  : true,
						tabIndex : this.tabIndex++,
						mode : 'local',
						triggerAction : 'all',
						editable : true,
						allowBlank : true,
						emptyText : '请选择系统代码...',
						anchor : '75%',
						 listeners:{
							select:function(obj){
								importToolsStore.load(); //重新加载可选请求								//mvToolsimportGrid.store.removeAll(); //清空已选请求							},
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
			            xtype: 'fieldset',
			            title: '<fmt:message key="toolbox.tool_selection" />',
			            items: [{
		                    	layout:'column',
				                border : true ,
				                items:[{
				                    columnWidth:.45,  
				                    border : false,
				                    defaults : { flex : 1 },
				                    layoutConfig : { align : 'stretch' },
				                    items : [this.dsFromTranImport]
				                },{
				                    columnWidth:.1,
				                    border:false,
				                    labelAlign : 'right',
				                    items: [this.panel]
				                } ,{
				                    columnWidth:.45,
				                    border:false,
				                    defaults : { flex : 1 },
				                    layoutConfig : { align : 'stretch' },
				                    items: [mvToolsimportGrid] 
				                }]
						}]
			        }
           		],// 定义按钮
       			buttons : [{
       				text :  '<fmt:message key="toolbox.import" />',
       				iconCls : 'button-import',
       				tabIndex : this.tabIndex++,
       				formBind : true,
       				scope : this,
       				handler : this.doExport
       			},{
       				text :  '<fmt:message key="toolbox.reset" />',
       				iconCls : 'button-reset',
       				formBind : true,
       				scope : this,
       				handler : this.doReset
       			}] }
			] 
		});
	},
	
	toolType_Storeone : function(value) {

		var index = this.tool_typeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return this.tool_typeStore.getAt(index).get('name');
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

	
	// 请求移入事件
	requestShiftIn : function() {
		var records =this.dsFromTranImport.getSelectionModel().getSelections();
		var notEqualFlag = true;
		Ext.each(records,function(leftRecord){
			mvToolsimportGrid.getStore().each(function(rightRecord){
				if(leftRecord.data.tool_code == rightRecord.data.tool_code){
					notEqualFlag = false;
				}
			},this);
			if(notEqualFlag){
				mvToolsimportGrid.store.add(leftRecord);
			}
			notEqualFlag = true;
		});
	},
	// 请求移出事件
	requestShiftOut : function() {
		var records = mvToolsimportGrid.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			mvToolsimportGrid.store.remove(records[i]);
		}
	},
	
	
	// 导入
	doExport : function() {
		if (mvToolsimportGrid.getStore().getCount() > 0) {
			
			var tool_codes = new Array();
			var appsys_codes = new Array();
			var tool_types = new Array();
			var tool_names = new Array();
			var file_names = new Array();
			mvToolsimportGrid.getStore().each(function(record){
				
				tool_codes.push(record.get('tool_code'));
				appsys_codes.push(record.get('appsys_code'));
				tool_types.push(record.get('tool_type'));
				tool_names.push(record.get('tool_name'));
				file_names.push(record.get('file_name'));
			},this);
		
		
			 Ext.Msg.show({
						title : '<fmt:message key="toolbox.import" />',
						msg : '已存在的工具再次导入后，工具状态将改为【未交接】，需重新交接给一线，<fmt:message key="toolbox.import_confirm" />',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								toolboximportmask.show();

								Ext.Ajax.request({
									        method : 'POST',
											url : '${ctx}/${appPath}/ToolBoxController/importtools',
											scope : this,
											timeout:600000,
											success : this.importSuccess,
											failure : this.importFailure,
											params : {
												tool_codes : tool_codes,
												appsys_codes : appsys_codes,
												tool_types : tool_types,
												tool_names : tool_names,
												file_names : file_names
											}
										});
							}
						}
					});
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
	

	doReset : function() {
		this.getForm().reset();
		importToolsStore.reload();
	},
	
	importSuccess : function(response, options) {
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			toolboximportmask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.failed" />!<fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}else if (Ext.decode(response.responseText).success == true) {
			toolboximportmask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					if(btn =='ok'){
						mvToolsimportGridStore.removeAll();
						importToolsStore.reload();
						
					}
				}
			});
		}
	} ,
	
	importFailure : function() {
		toolboximportmask.hide();
		Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg :  '<fmt:message key="message.import.failed" />!',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("TOOLBOX_IMPORT").add(new ToolboxExportForm());
// 刷新Tab页布局
Ext.getCmp("TOOLBOX_IMPORT").doLayout();
importToolsStore.on('beforeload',function(){
	this.baseParams = {
		appsys_code:Ext.getCmp('appsys_code_importid').getValue()
	};
});
</script>
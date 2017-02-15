<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var mvExportCsmMoveRequests ;
var mvExportCsmMovedRequests ;
var mvExportDsFromTraned ;
var mvExportDsFromTranedStroe ;
var envExportStroe;
var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
});

var mvExportDsFromTranStroe = new Ext.data.JsonStore( {
    proxy : new Ext.data.HttpProxy({
    	method : 'POST',
		url : '${ctx}/${managePath}/moveexport/getRequest',
		disableCaching : true
	}),
    root : 'RequestInfo',
	fields : ['reqId','reqName'],
	listeners : {
		loadexception:function(){
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '请求加载失败!',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			app.mask.hide();
		},
		/* beforeload:function(store, options){
			app.mask.show();
		}, */
		load:function(store,  records,  options){
			app.mask.hide();
		}
	}
});
 
this.cmnAppInfoMoveExportStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});
this.cmnAppInfoMoveExportStroe.load(); 
 
envExportStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/moveimport/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
envExportStroe.on('beforeload',function(){
	envExportStroe.baseParams.appsysCode = Ext.getCmp("appsys_code_export").getValue();
},this);
//this.envExportStroe.load(); 
 
//定义新建表单
MoveExportForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		mvExportCsmMoveRequests = new Ext.grid.CheckboxSelectionModel();
		mvExportCsmMovedRequests = new Ext.grid.CheckboxSelectionModel();
		
		//可选择的请求
		this.dsFromTran = new Ext.grid.GridPanel({
			id : 'mvExportDsFromTranGrid', 
			height : 360 ,
			loadMask : true,
			frame : true,
			title : '可选择的请求',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			/* hideHeaders:true,  */
			store : mvExportDsFromTranStroe,
			autoExpandColumn : 'name',
			sm : mvExportCsmMoveRequests,   
			columns : [mvExportCsmMoveRequests,{
				dataIndex : 'reqId',
				hidden : true,   
				hideable : false 
			},{
				header : '请求名称',
				dataIndex : 'reqName',
				hideable : true 
			}]
		});
		//移入移出操作面板
		this.panel = new Ext.Panel({
			height : 360 ,
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
		//已选择的请求
		mvExportDsFromTranedStroe=new Ext.data.JsonStore({
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['reqId','reqName'],
			remoteSort : true
		});
		mvExportDsFromTraned = new Ext.grid.GridPanel({
			id : 'mvExportDsFromTranedGrid',
			height : 360 ,
			loadMask : true,
			frame : true,
			title :'已选择的请求',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			/* hideHeaders:true,  */
			store : mvExportDsFromTranedStroe,
			autoExpandColumn : 'name',
			sm : mvExportCsmMovedRequests,   
			columns : [mvExportCsmMovedRequests,{
				dataIndex : 'reqId',
				hidden : true,   
				hideable : false 
			},{
				header : '请求名称',
				dataIndex : 'reqName',
				hideable : true 
			}]
		}); 
		
		// 设置基类属性
		MoveExportForm.superclass.constructor.call(this, {
			title : '资源导出',//<fmt:message key="title.form" />
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			timeout : 300,
			autoScroll : true,
			url : '${ctx}/${managePath}/moveexport/dplyExport',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
		    items:[{
		        	columnWidth : .5,
		            xtype: 'fieldset',
		            layout : 'form',
		            border : true,
					labelWidth : 70,
					buttonAlign : 'center',
		            autoHeight : true,
		            items : [ {
						xtype : 'combo',
						fieldLabel : '系统代码',
						store : cmnAppInfoMoveExportStroe,
						name : 'appsys_code',
						id:'appsys_code_export',
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
						anchor : '50%',
						listeners:{
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
							select:function(combo, record, index){
								//mvExportDsFromTranStroe.load(); //重新加载可选请求
								//mvExportDsFromTraned.store.removeAll(); //清空已选请求
								
								//Ext.getCmp('envExpId').clearValue();
								//envExportStroe.filter('env', combo.value + '_' , false, true);
								var appsyscd = combo.value;
								//var appsyscd = envid.substring(0, envid.indexOf('_'));
								Ext.getCmp("appsys_code_export").setValue(appsyscd);
								envExportStroe.load();
							}
						}
		            },
		            {
						xtype : 'combo',
						fieldLabel : '导出环境',
						store : envExportStroe,
						name : 'env2',
						id:'envExpId',
						hiddenName : 'env2',
						displayField : 'envName',
						valueField : 'env',
						tabIndex : this.tabIndex++,
						mode : 'local',
						triggerAction : 'all',
						editable : true,
						allowBlank : true,
						emptyText : '请选择环境...',
						anchor : '50%',
						listeners : {
							select : function(combo, record, index){
								var envExpId = combo.value;
								var appsyscd = envExpId.substring(0, envExpId.indexOf('_'));
								Ext.getCmp("appsys_code_export").setValue(appsyscd);
							},
							expand:function(combo){
								var appsyscdValue = Ext.getCmp('appsys_code_export').getValue();
								if(appsyscdValue != ''){
									envExportStroe.filter('env', appsyscdValue + '_', false, true);
								}
							}
							,
							select:function(obj){
								mvExportDsFromTranStroe.load(); //重新加载可选请求
								mvExportDsFromTraned.store.removeAll(); //清空已选请求
								
								
							}
						}
		            },
			        {
						title : '选择资源',
			        	xtype : "fieldset",
		                fieldLabel : '',
				        border : true,
						layout : 'column', 
						labelAlign : 'right',
						columnWidth : 1,
			            items:[{
							xtype : 'checkboxgroup',
							name : 'brpms',
							id : 'brpmsid',
							fieldLabel : '',
			                items: [{
				                boxLabel: '发布请求资源',
				                name: 'brpm3',
				                id: 'brpm3',
				                inputValue: 3
				            },{
				                boxLabel: '发布作业资源',
				                name: 'bsa',//script
				                id: 'bsa',//script
				                inputValue: 1
				            }]
			            }]
			        },{
			            xtype: 'fieldset',
			            title: '请求选择',
			            items: [{
		                    	layout:'column',
				                border : true ,
				                items:[{
				                    columnWidth:.45,  
				                    border : false,
				                    defaults : { flex : 1 },
				                    layoutConfig : { align : 'stretch' },
				                    items : [this.dsFromTran]
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
				                    items: [mvExportDsFromTraned] 
				                }]
						}]
			        }
           		],// 定义按钮
       			buttons : [{
       				text : '导出',
       				iconCls : 'button-export',
       				tabIndex : this.tabIndex++,
       				formBind : true,
       				scope : this,
       				handler : this.doExport
       			},{
       				text : '重置',
       				iconCls : 'button-reset',
       				formBind : true,
       				scope : this,
       				handler : this.doReset
       			}] }
			] 
		});
	},
	
	// 请求移入事件
	requestShiftIn : function() {
		var records =this.dsFromTran.getSelectionModel().getSelections();
    	if(mvExportDsFromTraned.store.getCount()!=0){
    		mvExportDsFromTraned.store.removeAll();
    		mvExportDsFromTraned.store.add(records);
    	}else{
    		mvExportDsFromTraned.store.add(records);
    	}
	},
	// 请求移出事件
	requestShiftOut : function() {
		var records = mvExportDsFromTraned.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			mvExportDsFromTraned.store.remove(records[i]);
		}
	},
	// 导出操作
	doExport : function() {
		var brpm = '';
		if(Ext.getCmp('brpm3').getValue()==true){
			brpm += '3,';
		}
		var bsa = '';
		if(Ext.getCmp('bsa').getValue()==true){
			bsa += '1';
		}
		var appsys_code = Ext.getCmp('appsys_code_export').getValue();
    	var storeRequests = mvExportDsFromTraned.getStore();
		var tranItemS = '' ;
		var request = '' ;
		storeRequests.each(function(item) {
			request = item.get('reqId') ;
			tranItemS += request+',' ; 
		});
		if(tranItemS!=''){
			tranItemS = tranItemS.substring(0,tranItemS.length-1);
		}
		if(appsys_code==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.export.appsys.code" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		var env2 = Ext.getCmp('envExpId').getValue();
		if(env2==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.env" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		if(brpm==''&&bsa==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.export.request.job" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		if(brpm!=''&&tranItemS==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.export.candidate.request" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		if(brpm!=''){ 
			Ext.Ajax.request({
				url : '${ctx}/${managePath}/moveexport/allappDbCheck',
				method : 'POST',
				scope : this,
				disableCaching : true,
				params : {
					appsys_code : appsys_code,
					tranItemS : tranItemS,
					brpm : brpm
				},
				success : function(response){ 
					var allappDbCheckFlag = Ext.util.JSON.decode(response.responseText).success;
					var allappDbCheckMsg = '';
					if(allappDbCheckFlag == ''){
						allappDbCheckMsg = '确定导出？';
					}else{
						allappDbCheckMsg = allappDbCheckFlag;
					}
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : allappDbCheckMsg,
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								//app.mask.show();
								Ext.Ajax.request({
									scope : this,
									disableCaching : true,
									//timeout : 7200000, //2小时
									url : '${ctx}/${managePath}/moveexport/dplyExport',
									params : {
										appsys_code : appsys_code,
										env : env2,
										tranItemS : tranItemS,
										brpm : brpm,  
										bsa : bsa
									}, 
									success : function(response){
										var checkflag = Ext.util.JSON.decode(response.responseText).success;
										if(checkflag == 'mulUserDplySingSysCheck'){
											Ext.Msg.show({
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.ERROR
											});
										}else if(checkflag == 'singUserDplyMulSysCheck'){
											Ext.Msg.show({
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.ERROR
											});
										}
									} 
								});
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.export.status" />',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.Info
								});
							}
						}
					});
				  } 
			});
		 }else{
			 Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '确定导出？',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						//app.mask.show();
						Ext.Ajax.request({
							scope : this,
							disableCaching : true,
							//timeout : 7200000, //2小时
							url : '${ctx}/${managePath}/moveexport/dplyExport',
							params : {
								appsys_code : appsys_code,
								env : env2,
								tranItemS : tranItemS,
								brpm : brpm,  
								bsa : bsa
							}, 
							success : function(response){
								var checkflag = Ext.util.JSON.decode(response.responseText).success;
								if(checkflag == 'mulUserDplySingSysCheck'){
									Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
								}else if(checkflag == 'singUserDplyMulSysCheck'){
									Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
								}
							} 
						});
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.export.status" />',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.Info
						});
					}
				}
			});
		 }
	},
	doReset : function() {
		this.getForm().reset();
	}
});
	/* Ext.Msg.show( {
	title : '<fmt:message key="message.title" />',
	msg : '<fmt:message key="message.export.status" />',
	buttons : Ext.MessageBox.OK,
	icon : Ext.MessageBox.Info
	});   */


// 实例化新建表单,并加入到Tab页中
Ext.getCmp("CONFIG_MSG_EXPORT").add(new MoveExportForm());
// 刷新Tab页布局
Ext.getCmp("CONFIG_MSG_EXPORT").doLayout();

mvExportDsFromTranStroe.on('beforeload',function(){
	this.baseParams = {
		appsys_code:Ext.getCmp('appsys_code_export').getValue(),
		envExpId:Ext.getCmp('envExpId').getValue()
	};
});
</script>
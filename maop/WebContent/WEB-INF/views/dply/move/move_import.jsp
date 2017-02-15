<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var mvImportCsmMoveRequests;
var mvImportCsmMovedRequests;
var mvImportDsFromTraned;
var mvImportDsFromTranedStroe;
var envExportStroe;
var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
});

var mvImportDsFromTranStroe = new Ext.data.JsonStore( {
    proxy : new Ext.data.HttpProxy({
    	method : 'POST',
		url : '${ctx}/${managePath}/moveimport/getRequest',
		timeout : 300000,
		disableCaching : true
	}),
    root : 'RequestInfo',
	fields : ['reqId','reqName'],
	listeners : {
		loadexception:function(){
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '待导入的请求资源不存在，请联系开发中心确认！',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR,
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
 
this.cmnAppInfoMoveImportStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});
this.cmnAppInfoMoveImportStroe.load(); 
 
envImportStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/moveimport/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
envImportStroe.on('beforeload',function(){
	envImportStroe.baseParams.appsysCode = Ext.getCmp("appsys_code2_import").getValue();
},this); 
//this.envImportStroe.load(); 



envExportStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/moveimport/queryExpEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['envExp','envNameExp'])//
});
envExportStroe.on('beforeload',function(){
	envExportStroe.baseParams.env = Ext.getCmp("envid").getValue();
},this); 
	
//定义新建表单
MoveImportForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序 
	constructor : function(cfg) {// 构造方法 
	Ext.apply(this, cfg);
	
	mvImportCsmMoveRequests = new Ext.grid.CheckboxSelectionModel();
	mvImportCsmMovedRequests = new Ext.grid.CheckboxSelectionModel();
	
	//可选择的请求	this.dsFromTran = new Ext.grid.GridPanel({
		id : 'mvImportDsFromTranGrid', 
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
		store : mvImportDsFromTranStroe,
		autoExpandColumn : 'name',
		sm : mvImportCsmMoveRequests,   
		columns : [mvImportCsmMoveRequests,{
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
	//已选择的请求	mvImportDsFromTranedStroe=new Ext.data.JsonStore({
		autoDestroy : true,
		root : 'data',
		totalProperty : 'count',
		fields : ['reqId','reqName'],
		remoteSort : true
	});
	mvImportDsFromTraned = new Ext.grid.GridPanel({
		id : 'mvImportDsFromTranedGrid',
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
		store : mvImportDsFromTranedStroe,
		autoExpandColumn : 'name',
		sm : mvImportCsmMovedRequests,   
		columns : [mvImportCsmMovedRequests,{
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
	MoveImportForm.superclass.constructor.call(this, {
		title : '资源导入',//<fmt:message key="title.form" />
		labelAlign : 'right',
		labelWidth : 155,
		buttonAlign : 'center',
		frame : true,
		timeout : 300,
		autoScroll : true,
		url : '${ctx}/${managePath}/moveimport/dplyImport',
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
					store : cmnAppInfoMoveImportStroe,
					name : 'appsys_code2',
					id:'appsys_code2_import',
					hiddenName : 'appsys_code2',
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

							/* Ext.getCmp('envid').clearValue();
							envImportStroe.filter('env', combo.value + '_' , false, true); */
							var appsyscd = combo.value;
							//var appsyscd = envid.substring(0, envid.indexOf('_'));
							Ext.getCmp("appsys_code2_import").setValue(appsyscd);
							envImportStroe.load();
						}
					}
	            },
	            {
					xtype : 'combo',
					fieldLabel : '导入环境',
					store : envImportStroe,
					name : 'env2',
					id:'envid',
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
							var envid = combo.value;
							var appsyscd = envid.substring(0, envid.indexOf('_'));
							Ext.getCmp("appsys_code2_import").setValue(appsyscd);
							envExportStroe.load();
						}/* ,
						expand:function(combo){
							var appsyscdValue = Ext.getCmp('appsys_code2_import').getValue();
							if(appsyscdValue != ''){
								envImportStroe.filter('env', appsyscdValue + '_', false, true);
							}
						} */
					}
	            },
	            {
					xtype : 'combo',
					fieldLabel : '导出环境',
					store : envExportStroe,
					name : 'envExp2',
					id:'envid2',
					hiddenName : 'envExp2',
					displayField : 'envNameExp',
					valueField : 'envExp',
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true,
					allowBlank : true,
					emptyText : '请选择环境...',
					anchor : '50%',
					listeners : {
						select : function(combo, record, index){
							/* var envid2 = combo.value;
							var appsyscd = envid2.substring(0, envid2.indexOf('_'));
							Ext.getCmp("appsys_code2_import").setValue(appsyscd); */
							mvImportDsFromTranStroe.reload(); //重新加载可选请求
							mvImportDsFromTraned.store.removeAll(); //清空已选请求
						}/* ,  
						expand:function(combo){
							alert(1);
							var envidValue = Ext.getCmp('envid').getValue();
							alert(envidValue);
							if(envidValue != ''){
								envExportStroe.filter('env', envidValue + '_', false, true);
							}
						} */
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
						fieldLabel : 'BRPM资源',
		                items: [{
			                boxLabel: '发布请求资源',
			                name: 'brpm21',
			                id: 'brpm21',
			                inputValue: 3
			            },{
			                boxLabel: '发布作业资源',
			                name: 'bsa21',//script
			                id: 'bsa21',//script
			                inputValue: 1
			            }]							    
		            }]
	            },
	            {
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
		                    items: [mvImportDsFromTraned] 
		                }]
					}]
	            }],
           		// 定义按钮
       			buttons : [{
       				text : '导入',
       				iconCls : 'button-import',
       				tabIndex : this.tabIndex++,
       				formBind : true,
       				scope : this,
       				handler : this.doImport
       			},{
       				text : '重置',
       				iconCls : 'button-reset',
       				formBind : true,
       				scope : this,
       				handler : this.doReset
       			}]}
			] 
		});
	},
	
	// 请求移入事件
	requestShiftIn : function() {
		var records =this.dsFromTran.getSelectionModel().getSelections();
    	if(mvImportDsFromTraned.store.getCount()!=0){
    		mvImportDsFromTraned.store.removeAll();
    		mvImportDsFromTraned.store.add(records);
    	}else{
    		mvImportDsFromTraned.store.add(records);
    	}
	},
	// 请求移出事件
	requestShiftOut : function() {
		var records = mvImportDsFromTraned.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			mvImportDsFromTraned.store.remove(records[i]);
		}
	},
	
	// 保存操作
	doImport : function() {
		var brpm2 = '' ;
		if(Ext.getCmp('brpm21').getValue()==true){
			brpm2 += '3,2,1';
		}
		
		var bsa2 = '';
		if(Ext.getCmp('bsa21').getValue()==true){
			bsa2 += '1';
			}
		
		var appsys_code2 = Ext.getCmp('appsys_code2_import').getValue(); 
		var storeRequests = mvImportDsFromTraned.getStore();
		var tranItemS2 = '' ;
		var request = '' ;
		storeRequests.each(function(item) {
			request = item.get('reqId') ;
			tranItemS2 += request+',' ; 
		});
		if(tranItemS2!=''){
			tranItemS2 = tranItemS2.substring(0,tranItemS2.length-1);
		}
		if(appsys_code2==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.appsys.code" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		var env2 = Ext.getCmp('envid').getValue();
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
		var envExp2 = Ext.getCmp('envid2').getValue();
		if(envExp2==''){
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
		if(brpm2==''&&bsa2==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.request.job" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		if(brpm2!=''&&tranItemS2==''){
			 Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.candidate.request" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			return ;
		}
		
		if(Ext.getCmp('bsa21').getValue()==true){
			var appsys_code2 = Ext.getCmp('appsys_code2_import').getValue(); 
			
			Ext.Ajax.request({
				url : '${ctx}/${managePath}/moveimport/bsaCheck',
				method : 'POST',
				scope : this,
				disableCaching : true,
				params : {
					appsys_code2 : appsys_code2,
					envExp : envExp2
				},
				 success : function(response){
					var flag = Ext.util.JSON.decode(response.responseText).success;
					if(flag=='error'){

						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '未找到发布作业资源文件，请确认是否已导出发布作业资源！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200,
							scope : this
						});
						return ;
					}else{

						if(brpm2!=''){ 
							Ext.Ajax.request({
								url : '${ctx}/${managePath}/moveimport/allappDbCheck',
								method : 'POST',
								scope : this,
								disableCaching : true,
								params : {
									appsys_code2 : appsys_code2,
									//env : env2,
									envExp : envExp2,
									tranItemS2 : tranItemS2,
									brpm2 : brpm2//,  
									//bsa2 : bsa2
								},
								 success : function(response){
									var allappDbCheckFlag = Ext.util.JSON.decode(response.responseText).success;
									var allappDbCheckMsg = '';
									if(allappDbCheckFlag == ''){
										allappDbCheckMsg = '确定导入？';
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
													url : '${ctx}/${managePath}/moveimport/dplyImport',
													params : {
														appsys_code2 : appsys_code2,
														env : env2,
														envExp : envExp2,
														tranItemS2 : tranItemS2,
														brpm2 : brpm2,  
														bsa2 : bsa2
													}, 
													success : function(response){
														var checkflag = Ext.util.JSON.decode(response.responseText).success;
														if(checkflag == 'mulUserImpSingSysCheck'){
															Ext.Msg.show({
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.ERROR
															});
														}else if(checkflag == 'singUserImpMulSysCheck'){
															Ext.Msg.show({
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.ERROR
															});
														}else if(checkflag == 'envCheck'){
															Ext.Msg.show({
																title : '<fmt:message key="message.title" />',
																msg : '<fmt:message key="message.import.env.status" />',
																buttons : Ext.MessageBox.OK,
																icon : Ext.MessageBox.ERROR
															});
														}
													} 
												});
												Ext.Msg.show( {
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.import.status" />',
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
								msg : '确定导入？',
								buttons : Ext.MessageBox.OKCANCEL,
								icon : Ext.MessageBox.QUESTION,
								minWidth : 200,
								scope : this,
								fn : function(buttonId) {
									if (buttonId == 'ok') {
										Ext.Ajax.request({
											scope : this,
											disableCaching : true,
											url : '${ctx}/${managePath}/moveimport/dplyImport',
											params : {
												appsys_code2 : appsys_code2,
												env : env2,
												envExp : envExp2,
												tranItemS2 : tranItemS2,
												brpm2 : brpm2,  
												bsa2 : bsa2
											}, 
											success : function(response){
												var checkflag = Ext.util.JSON.decode(response.responseText).success;
												if(checkflag == 'mulUserImpSingSysCheck'){
													Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.ERROR
													});
												}else if(checkflag == 'singUserImpMulSysCheck'){
													Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.ERROR
													});
												}else if(checkflag == 'envCheck'){
													Ext.Msg.show({
														title : '<fmt:message key="message.title" />',
														msg : '<fmt:message key="message.import.env.status" />',
														buttons : Ext.MessageBox.OK,
														icon : Ext.MessageBox.ERROR
													});
												}
											} 
										});
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.import.status" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.Info
										});
									}
								}
							});
						}
					}
				 }
			});
			
		
		}else{


			if(brpm2!=''){ 
				Ext.Ajax.request({
					url : '${ctx}/${managePath}/moveimport/allappDbCheck',
					method : 'POST',
					scope : this,
					disableCaching : true,
					params : {
						appsys_code2 : appsys_code2,
						//env : env2,
						envExp : envExp2,
						tranItemS2 : tranItemS2,
						brpm2 : brpm2//,  
						//bsa2 : bsa2
					},
					 success : function(response){
						var allappDbCheckFlag = Ext.util.JSON.decode(response.responseText).success;
						var allappDbCheckMsg = '';
						if(allappDbCheckFlag == ''){
							allappDbCheckMsg = '确定导入？';
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
										url : '${ctx}/${managePath}/moveimport/dplyImport',
										params : {
											appsys_code2 : appsys_code2,
											env : env2,
											envExp : envExp2,
											tranItemS2 : tranItemS2,
											brpm2 : brpm2,  
											bsa2 : bsa2
										}, 
										success : function(response){
											var checkflag = Ext.util.JSON.decode(response.responseText).success;
											if(checkflag == 'mulUserImpSingSysCheck'){
												Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.ERROR
												});
											}else if(checkflag == 'singUserImpMulSysCheck'){
												Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.ERROR
												});
											}else if(checkflag == 'envCheck'){
												Ext.Msg.show({
													title : '<fmt:message key="message.title" />',
													msg : '<fmt:message key="message.import.env.status" />',
													buttons : Ext.MessageBox.OK,
													icon : Ext.MessageBox.ERROR
												});
											}
										} 
									});
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.import.status" />',
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
					msg : '确定导入？',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							Ext.Ajax.request({
								scope : this,
								disableCaching : true,
								url : '${ctx}/${managePath}/moveimport/dplyImport',
								params : {
									appsys_code2 : appsys_code2,
									env : env2,
									envExp : envExp2,
									tranItemS2 : tranItemS2,
									brpm2 : brpm2,  
									bsa2 : bsa2
								}, 
								success : function(response){
									var checkflag = Ext.util.JSON.decode(response.responseText).success;
									if(checkflag == 'mulUserImpSingSysCheck'){
										Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.dply.mulUser.SingSys.status" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
									}else if(checkflag == 'singUserImpMulSysCheck'){
										Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.dply.singUser.MulSys.status" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
									}else if(checkflag == 'envCheck'){
										Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.import.env.status" />',
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
									}
								} 
							});
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.import.status" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.Info
							});
						}
					}
				});
			}
		}
		
	
		
		
	},

	doReset : function() {
		this.getForm().reset();
	},
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" />!<fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	
	importSuccess : function(response, options) {
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.failed" />!<fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}else if (Ext.decode(response.responseText).success == true) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					if(btn =='ok'){
						mask.hide();
						gridStore.load();
					}
				}
			});
		}
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("CONFIG_MSG_IMPORT").add(new MoveImportForm());
// 刷新Tab页布局
Ext.getCmp("CONFIG_MSG_IMPORT").doLayout();

mvImportDsFromTranStroe.on('beforeload',function(){
	this.baseParams = {
		appsys_code2:Ext.getCmp('appsys_code2_import').getValue(),
		env2:Ext.getCmp('envid2').getValue()
	};
});
</script>
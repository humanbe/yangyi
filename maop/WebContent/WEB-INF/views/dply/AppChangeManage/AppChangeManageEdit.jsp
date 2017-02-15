<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var sysIdsStore = new Ext.data.Store({
	proxy : new Ext.data.HttpProxy(
			{
				url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
				method : 'GET',
				disableCaching : true
			}),
	reader : new Ext.data.JsonReader({}, [ 'appsysCode',
			'appsysName' ]),
	listeners : {
		load : function(store) {
			if (store.getCount() == 0) {
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

var endFlagStore = new Ext.data.SimpleStore({
	fields :['endFlagDisplay', 'endFlagValue'],
	data : [['是', '1'], ['否', '2'], ['部分', '3']]
});

var changeTypeStore = new Ext.data.SimpleStore({
	fields : ['changeTypeDisplay', 'changeTypeValue'],
	data : [['常规投产', '1'], ['临时投产', '2'], ['临时操作', '3'], ['紧急修复', '4']]
});

var changeTableStore = new Ext.data.SimpleStore({
	fields : ['changeTableDisplay', 'changeTableValue'],
	data : [['否', '0'], ['是', '1'], ['已归档', '2']]
});

var warnStore = new Ext.data.SimpleStore({
	fields : ['monitorWarnValue', 'monitorWarnDisplay'],
	data : [['1', '忽略告警'], ['0', '不忽略告警']]
});

var changeRiskEvalStore = new Ext.data.SimpleStore({
	fields : ['changeRiskEvalValue', 'changeRiskEvalDisplay'],
	data : [['1', '低'], ['2', '中'], ['3', '高']]
});

AppChangeManageEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		sysIdsStore.load();
		
		csm = new Ext.grid.CheckboxSelectionModel();
		this.arrangeStore = new Ext.data.JsonStore(
				{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								
								url : '${ctx}/${managePath}/appchangemanage/arrange_request',
								disableCaching : false
							}),
					autoDestroy : true,
					root : 'data',
					totalProperty : 'count',
					fields : [ 'appSysCode', 'requestCode','environment', 'planDeployDate', 'deployCode', 
					           'requestName', 'trunSwitch', 'execStatus', 'planStartTime', 
					           'planEndTime', 'realStartDate', 'realEndDate','requestStatus','autostart','checked'],
					pruneModifiedRecords : true,
					remoteSort : false,
					sortInfo : {
						field : 'requestCode',
						direction : 'ASC'
					},
					baseParams : {
						start : 0,
						limit : 1000,
						appsysCode :'',
						changeDate:''
						
					}
				});
		
		
              arrangeEditGrid = new Ext.grid.EditorGridPanel(
				{
					region : 'center',
					border : false,
					loadMask : true,
					height:440,
					columnLines : true,
					viewConfig : {
						forceFit : true
					},
					store : this.arrangeStore,
					sm : csm,
					columns : [
					new Ext.grid.RowNumberer(),
					csm,

					 {
						header : '<fmt:message key="dplyRequestInfo.appSysCd" />',
						dataIndex : 'appSysCode',
						hidden: true 
						
					}, {
						header : '<fmt:message key="dplyRequestInfo.requestCode" />',
						dataIndex : 'requestCode',
						editable : false,
						sortable : true,
						width : 200
					}, {
						header : '<fmt:message key="dplyRequestInfo.environment" />',
						dataIndex : 'environment',
						editable : false,
						sortable : true
					},{
 							header :'<fmt:message key="dplyRequestInfo.deployCode" />',
 							dataIndex : 'deployCode',
 							editable : false,
 							sortable : true
 						}, {
 							header :'<fmt:message key="dplyRequestInfo.planDeployDate" />',
 							dataIndex : 'planDeployDate',
 							editor : new Ext.grid.GridEditor(
 									new Ext.form.DateField({maxLength:8,
 										                   format : 'Ymd'
															})
 						    ),
 							sortable : true
 						}, {
 							header :'<fmt:message key="dplyRequestInfo.planStartTime" />',
 							dataIndex : 'planStartTime',
 							editor : new Ext.grid.GridEditor(
 									new Ext.form.TimeField({maxLength:4,
 										                    increment: 30,
 										                   format : 'Hi'
															})
 						    ),	
 						  
 							sortable : true
 						}, {
 							header :'<fmt:message key="dplyRequestInfo.planEndTime" />',
 							dataIndex : 'planEndTime',
 							editor : new Ext.grid.GridEditor(
 									new Ext.form.TimeField({maxLength:4,
						                    increment: 30,
						                   format : 'Hi'
										})
 						    ),
 						   
 							sortable : true
 						} ],
 							listeners : {
 								'afteredit' : function(e) {
 									if(e.field == 'planDeployDate'){
 										var myrdate = e.record.get('planDeployDate');
 										var d=	myrdate.format('Ymd');//日期
 										e.record.set('planDeployDate',d);
 									}
 								}
 							},
 						
					// 定义分页工具条


					bbar : new Ext.PagingToolbar({
						store : this.arrangeStore,
						displayInfo : true,
						pageSize : 1000
					})

				});
		// 设置基类属性
		AppChangeManageEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'left',
			labelWidth : 135,
			bodyStyle : 'padding : 0, 100px, 0, 100px;',
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/appchangemanage/edit/${param.appChangeId}',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
			    {
			    	xtype : 'combo',
			    	id : 'appsysCode_Edit',
			    	fieldLabel : '<fmt:message key="property.appsyscd" />',
					store : sysIdsStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'aplCode',
					readOnly : true
				},{
					xtype : 'textfield',
					name : 'requests_create',
					hidden : true
				}, {
					xtype : 'datefield',
					name : 'changeMonth',
					fieldLabel : '<font color=red>*</font> <fmt:message key="property.changeMonth" />',
					allowBlank : false,
					plugins :'monthPickerPlugin',
					format : 'Ym'
				}, {
					xtype : 'datefield',
					fieldLabel : '<font color=red>*</font> <fmt:message key="property.changeDate" />',
					name : 'changeDate',
					format : 'Ymd',
					allowBlank : false
				}, {
					xtype : 'datefield',
					name : 'oldChangeDate',
					format : 'Ymd',
					hidden : true,
					value : '${param.planStartDate}'
				}, {
		            xtype:'tabpanel',
		            id : 'tabEdit',
		            forceLayout : true,
		            plain:true,
		            autoScroll:true,
		            enableTabScroll:true,
		            activeTab: 0,
		            height:440,
		            deferredRender: false,
		            defaults:{bodyStyle:'padding:10px'},
		            items:[{
		            	title:'<fmt:message key="property.appChangeInfo"/>',
		                layout:'column',
		                iconCls : 'menu-node-change',
		                border:false,
		                items:[{
		                    columnWidth:.5,
		                    layout: 'form',
		                    defaults: {anchor : '98%'},
		                    border:false,
		                    labelAlign : 'right',
		                    defaultType : 'textfield', 
		                    items: [{
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.changeCode" />',
								name : 'eapsCode',
								vtype : 'alphanum',
								vtypeText : "该输入项只能包含数字",
								maskRe : /[0-9]/,
								allowBlank : false,
								maxLength : 10
							},
							{
								fieldLabel : '<fmt:message key="property.changeName" />',
								maxLength : 50,
								name : 'changeName'
							},
							{
								fieldLabel : '<fmt:message key="property.changeGrantNo" />',
								maxLength : 50,
								name : 'changeGrantNo'
							},
							{
								fieldLabel : '<fmt:message key="property.dplyLocation" />',
								maxLength : 20,
								name : 'dplyLocation'
							},
							{
								xtype : 'datefield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.planStartDate" />',
								name : 'planStartDate',
								format : 'Ymd',
								allowBlank : false
							},
							{
								xtype : 'timefield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.planStartTime" />',
								name : 'planStartTime',
								format : 'H:i',
								increment : 30,
								allowBlank : false
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.actualStartTime" />',
								name : 'actualStartTime',
								format : 'H:i',
								increment : 30
								
							},
							{
								xtype : 'datefield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.planEndDate" />',
								name : 'planEndDate',
								format : 'Ymd',
								allowBlank : false
							},
							{
								xtype : 'timefield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.planEndTime" />',
								name : 'planEndTime',
								format : 'H:i',
								increment : 30,
								allowBlank : false
							},
							{
								xtype : 'datefield',
								fieldLabel : '<fmt:message key="property.actualEndDate" />',
								name : 'actualEndDate',
								format : 'Ymd'
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.actualEndTime" />',
								name : 'actualEndTime',
								format : 'H:i',
								increment : 30
							},
							{
								xtype : 'combo',
								fieldLabel : '<fmt:message key="property.endFlag" />',
								hiddenName : 'endFlag',
								store : endFlagStore,
								displayField : 'endFlagDisplay',
								valueField : 'endFlagValue',
								mode: 'local',
								typeAhead: true,
			                    triggerAction: 'all',
			                    editable : false,
								tabIndex : this.tabIndex++
							},
							{
								fieldLabel : '<fmt:message key="property.projectChangeLeader" />',
								maxLength : 10,
								name : 'develop'
							}]
		                },{
		                    columnWidth:.5,
		                    layout: 'form',
		                    border:false,
		                    defaultType : 'textfield',
		                    defaults: {anchor : '98%'},
		                    labelAlign : 'right',
		                    items: [
							{
								xtype : 'combo',
								fieldLabel : '<fmt:message key="property.changeType" />',
								hiddenName : 'changeType',
								store : changeTypeStore,
								displayField : 'changeTypeDisplay',
								valueField : 'changeTypeValue',
								mode: 'local',
								typeAhead: true,
			                    triggerAction: 'all',
			                    editable : false,
								tabIndex : this.tabIndex++
							},
							{
								xtype : 'combo',
								fieldLabel : '<fmt:message key="property.changeTable" />',
								hiddenName : 'changeTable',
								store : changeTableStore,
								displayField : 'changeTableDisplay',
								valueField : 'changeTableValue',
								mode: 'local',
								typeAhead: true,
			                    triggerAction: 'all',
			                    editable : false,
								tabIndex : this.tabIndex++
							},
							{
								xtype : 'datefield',
								fieldLabel : '<fmt:message key="property.lastRebootDate" />',
								name : 'lastRebootDate',
								format : 'Ymd'
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.nowRebootTime" />',
								name : 'nowRebootTime',
								format : 'H:i',
								increment : 30
							},
							{
								fieldLabel : '<fmt:message key="property.rebootExecInfo" />',
								maxLength : 20,
								name : 'rebootExecInfo'
							},
							{
								fieldLabel : '<fmt:message key="property.verifyInfo" />',
								maxLength : 40,
								name : 'verifyInfo'
							},
							{
								xtype : 'textfield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.operationId" />',
								maxLength : 6,
								name : 'operationId',
								vtype : 'alphanum',
								vtypeText : "该输入项只能包含小写字母（w）和数字",
								maskRe : /[w0-9]/,
								allowBlank : false
							},
							{
								xtype : 'textfield',
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.operation" />',
								maxLength : 10,
								name : 'operation',
								allowBlank : false
							},
							{
								xtype : 'textfield',
								fieldLabel : '<fmt:message key="property.operationTel" />',
								maxLength : 50,
								name : 'operationTel'
							},
							{
								fieldLabel : '<fmt:message key="property.maintainTomo" />',
								maxLength : 10,
								name : 'maintainTomo'
							},
							{
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.reviewerId" />',
								maxLength : 6,
								name : 'reviewerId',
								vtype : 'alphanum',
								vtypeText : "该输入项只能包含小写字母（w）和数字",
								maskRe : /[w0-9]/,
								allowBlank : false
							},
							{
								fieldLabel : '<font color=red>*</font> <fmt:message key="property.reviewer" />',
								maxLength : 10,
								name : 'reviewer',
								allowBlank : false
							},
							{
								fieldLabel : '<fmt:message key="property.reviewerTel" />',
								maxLength : 50,
								name : 'reviewerTel'
							}]
		                }]
		            }, 
		            {
		            	title : '<fmt:message key="property.appChangeRiskEval"/>',
		                layout:'form',
		                labelAlign : 'right',
		                iconCls : 'menu-node-risk',
	                    border:false,
	                    items: [{
	                    	layout:'column',
			                border:false,
			                items:[{
			                    columnWidth:.5,
			                    layout: 'form',
			                    defaults: {anchor : '98%'},
			                    border:false,
			                    labelAlign : 'right',
			                    defaultType : 'textfield', 
			                    items: [{
			    					xtype : 'combo',
			    					fieldLabel : '<fmt:message key="property.changeRiskEval" />',
			    					store : changeRiskEvalStore, 
			    					displayField : 'changeRiskEvalDisplay',
			    					valueField : 'changeRiskEvalValue',
			    					hiddenName : 'changeRiskEval',
			    					mode: 'local',
			    					typeAhead: true,
			    					editable : false,
			    				    triggerAction: 'all',
			    					tabIndex : this.tabIndex++
			    				},
			    				{
			    					xtype : 'textarea',
			    					fieldLabel : '<fmt:message key="property.primaryChangeRisk" />',
			    					name : 'primaryChangeRisk',
			    					height : 120
			    				}, 
			    				{
			    					xtype : 'textfield',
			    					fieldLabel : '<fmt:message key="property.other" />',
			    					maxLength : 50,
			    					name : 'other'
			    				}]
			                },{
			                    columnWidth:.5,
			                    layout: 'form',
			                    defaults: {anchor : '98%'},
			                    border:false,
			                    labelAlign : 'right',
			                    defaultType : 'textfield', 
			                    items: [{
			    					xtype : 'textfield',
			    					fieldLabel : '<fmt:message key="property.stopServiceTime" />',
			    					maxLength : 30,
			    					name : 'stopServiceTime'
			    				},
			    				{
			    					xtype : 'textarea',
			    					fieldLabel : '<fmt:message key="property.riskHandleMethod" />',
			    					name : 'riskHandleMethod',
			    					height : 120
			    				}]
			                }]
	                    }]
		            },
		            {
		            	title : '<fmt:message key="property.appChangeSummary"/>',
		                layout:'form',
		                labelAlign : 'right',
		                iconCls : 'menu-node-trouble',
	                    border:false,
	                    items: [{
	                    	layout:'column',
			                border:false,
			                items:[{
			                    columnWidth:.5,
			                    layout: 'form',
			                    defaults: {anchor : '98%'},
			                    border:false,
			                    labelAlign : 'right',
			                    defaultType : 'textfield', 
			                    items: [{
									xtype : 'datetimefield',
									fieldLabel : '<fmt:message key="property.time" />',
									name : 'time',
									dateFormat :'Ymd',
									timeFormat : 'H:i:s'
								},
								{
									xtype : 'textarea',
									fieldLabel : '<fmt:message key="property.phenomenon" />',
									name : 'phenomenon',
			    					height : 120
								},
								{
									xtype : 'textarea',
									fieldLabel : '<fmt:message key="property.handleMethod" />',
									name : 'handleMethod',
			    					height : 120
								}]
			                },{
			                    columnWidth:.5,
			                    layout: 'form',
			                    defaults: {anchor : '98%'},
			                    border:false,
			                    labelAlign : 'right',
			                    defaultType : 'textfield', 
			                    items: [{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="property.type" />',
									maxLength : 30,
									name : 'type'
								}, {
									xtype : 'textarea',
									fieldLabel : '<fmt:message key="property.cause" />',
									name : 'cause',
			    					height : 120
								},
								{
									xtype : 'textarea',
									fieldLabel : '<fmt:message key="property.improveMethod" />',
									name : 'improveMethod',
			    					height : 120
								}]
			                }]
	                    }]
		            },
		            {
		            	title : '<fmt:message key="property.monitorWarnInfo"/>',
			            layout:'column',
			            labelAlign : 'right',
			            iconCls : 'menu-node-warn',
		                border:false,
		                items:[{
		                    columnWidth:.5,
		                    layout: 'form',
		                    border:false,
		                    defaults: {anchor : '98%'},
		                    items: [{
								xtype : 'textfield',
								fieldLabel : '<fmt:message key="property.monitorEffectContent" />',
								maxLength : 20,
								name : 'monitorEffectContent'
							},
							{
								xtype : 'textfield',
								fieldLabel : '<fmt:message key="property.deviceName" />',
								maxLength : 10,
								name : 'deviceName'
							},
							{
								xtype : 'textarea',
								fieldLabel : '<fmt:message key="property.ipAddress" />',
								maxLength : 500,
								name : 'ipAddress'
							},
							{
								xtype : 'textfield',
								fieldLabel : '<fmt:message key="property.explainDevice" />',
								maxLength : 50,
								name : 'explainDevice'
							},
							{
								xtype : 'textfield',
								fieldLabel : '<fmt:message key="property.explainMonitorPlatform" />',
								maxLength : 50,
								name : 'explainMonitorPlatform'
							},
							{
		    					xtype : 'combo',
		    					fieldLabel : '<fmt:message key="property.explainMonitorTool" />',
		    					store : warnStore,
		    					displayField : 'monitorWarnDisplay',
		    					valueField : 'monitorWarnValue',
		    					hiddenName : 'explainMonitorTool',
		    					mode: 'local',
		    					typeAhead: true,
		    					editable : false,
		    				    triggerAction: 'all',
		    					tabIndex : this.tabIndex++
		    				}]
		                },{
		                    columnWidth:.5,
		                    layout: 'form',
		                    border:false,
		                    defaults: {anchor : '98%'},
		                    items: [
		    				{
		    					xtype : 'combo',
		    					fieldLabel : '<fmt:message key="property.explainMonitorScreen" />',
		    					store : warnStore,
		    					displayField : 'monitorWarnDisplay',
		    					valueField : 'monitorWarnValue',
		    					hiddenName : 'explainMonitorScreen',
		    					mode: 'local',
		    					typeAhead: true,
		    					editable : false,
		    				    triggerAction: 'all',
		    					tabIndex : this.tabIndex++
		    				},
							{
								xtype : 'datefield',
								fieldLabel : '<fmt:message key="property.effectStartDate" />',
								name : 'effectStartDate',
								format : 'Ymd'
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.effectStartTime" />',
								name : 'effectStartTime',
								format : 'H:i',
								increment : 30
							},
							{
								xtype : 'datefield',
								fieldLabel : '<fmt:message key="property.effectEndDate" />',
								name : 'effectEndDate',
								format : 'Ymd'
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.effectEndTime" />',
								name : 'effectEndTime',
								format : 'H:i',
								increment : 30
							}]
		                }]
		            },{
		            	title:'自动化请求排期 ',
		            	id : 'sortEdit',
		            	iconCls : 'button-plan',
		            	layout: 'form',
		            	height:440,
		            	 items: [arrangeEditGrid],
		            	 scope : this,	
						 listeners : {
								//编辑完成后处理事件
								scope : this,
								'activate' : function(panel) {
									
									this.arrangeStore.baseParams.appsysCode=this.getForm().findField('aplCode').getValue();
									this.arrangeStore.baseParams.changeDate=this.getForm().findField('changeDate').getValue().format('Ymd');
									this.arrangeStore.load();
									this.arrangeStore.on('load',function(){
										
										var myr=this.getForm().findField('planStartDate').getValue();
										if(myr!=''||myr!=null){
											myr=	myr.format('Ymd');//日期
										}
									var code=	this.getForm().findField('eapsCode').getValue(); //投产编号
									var planStartTime=	this.getForm().findField('planStartTime').getValue().replace(':',''); //排期开始时间
									var planEndTime=	this.getForm().findField('planEndTime').getValue().replace(':',''); //排期结束时间
										this.arrangeStore.each(function(item) {
												item.set('deployCode',code);
											
											if(item.data['planDeployDate']==null||item.data['planDeployDate']==''){
												item.set('planDeployDate',myr);
											}
											if(item.data['planStartTime']==null||item.data['planStartTime']==''){
												item.set('planStartTime',planStartTime);
											}
											if(item.data['planEndTime']==null||item.data['planEndTime']==''){
												item.set('planEndTime',planEndTime);
											}
											
										});
										
										// 默认选中数据
										var records = this.arrangeStore.query('checked', true).getRange();
						                setTimeout(function(){
						                	arrangeEditGrid.getSelectionModel().selectRecords(records, false);
						                }, 500);
									}, this);
									
								} 
							}
		            }]
		        }
	 		],
			// 定义按钮
			buttons : [ {
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				formBind : true,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				handler : this.doCancel
			} ]
		});

		// 加载表单数据
		this.load({
			url : '${ctx}/${managePath}/appchangemanage/view',
			method : 'POST',
			params : {
				appChangeId: '${param.appChangeId}'
			},
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success: function(){
				Ext.Ajax.request({
					method : 'POST',
					url:'${ctx}/${managePath}/appchangemanage/hide',	
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					disableCaching:true,
					params : {
						appsysCode : '${param.appsysCode}'
					},
					success: function(response) {
						var data = Ext.decode(response.responseText).data;
						if(1 != data){
							Ext.getCmp('tabEdit').hideTabStripItem('sortEdit');
						}
					}, 
					failure : function(form, action) {
						var error = action.result.error;
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
					}
				});
			}
		});
	},

	// 保存操作
	doSave : function() {
		
		var a='';
		var b='';
		var c='';
		var d='';
		var e='';
		var f='';
		var jsonRequests = [];
		var sm =arrangeEditGrid.getSelectionModel().getSelections();
		for(var i=0;i<sm.length;i++){
		
			 a =sm[i].get('deployCode');
			 b =sm[i].get('planDeployDate');
			 c =sm[i].get('planStartTime');							
			 d =sm[i].get('planEndTime');
			 e =sm[i].get('environment');
			 f =sm[i].get('requestCode');
			  if(b==null||b==''||c==null||c==''||d==null||d==''){
				  Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '选择的排期请求有空值,请确认!',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.WARNING
					});
				  return;
			  };
			  jsonRequests.push(a+"|+|"+b+"|+|"+c+"|+|"+d+"|+|"+e+"|+|"+f);
		}			
			
			this.getForm().findField('requests_create').setValue(Ext.util.JSON.encode(jsonRequests));

		this.getForm().submit({
			scope : this,
			success : this.saveSuccess,
			failure : this.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	// 取消操作
	doCancel : function() {
		app.closeTab('edit_AppChangeManage');
	},
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			scope : this,
			fn : function() {
				var params = {
					appChangeId: '${param.appChangeId}'
				};
				app.closeTab('edit_AppChangeManage');
				var grid = Ext.getCmp("AppChangeManageListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 数据加载成功回调
	loadSuccess : function(form, action) {},
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("edit_AppChangeManage").add(new AppChangeManageEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_AppChangeManage").doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var warnStore = new Ext.data.SimpleStore({
	fields : ['monitorWarnValue', 'monitorWarnDisplay'],
	data : [['1', '忽略告警'], ['0', '不忽略告警']]
});

var changeRiskEvalStore = new Ext.data.SimpleStore({
	fields : ['changeRiskEvalValue', 'changeRiskEvalDisplay'],
	data : [['1', '低'], ['2', '中'], ['3', '高']]
});

AppChangeManageViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
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
						appsysCode :'${param.aplCode}',
						changeDate:'${param.changeDate}'
						
					}
				});
		this.arrangeStore.load();
		this.arrangeStore.on('load',function(){
			var records = this.arrangeStore.query('checked', true).getRange();
            setTimeout(function(){
            	arrangeViewGrid.getSelectionModel().selectRecords(records, false);
            }, 2000);
		}, this);
		
		  arrangeViewGrid = new Ext.grid.EditorGridPanel(
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
						// 定义分页工具条


						bbar : new Ext.PagingToolbar({
							store : this.arrangeStore,
							displayInfo : true,
							pageSize : 1000
						})

					});
		// 设置基类属性
		AppChangeManageViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'left',
			labelWidth : 135,
			bodyStyle : 'padding : 0, 100px, 0, 100px;',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [{
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="property.appsyscd" />',
				name : 'aplCode',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="property.changeMonth" />',
				name : 'changeMonth',
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="property.changeDate" />',
				name : 'changeDate',
				readOnly : true
			}, {
	            xtype:'tabpanel',
	            id:'appChangeTabpanel',
	            plain:true,
	            autoScroll:true,
	            enableTabScroll:true,
	            activeTab: 0,
	            height:440,
	            deferredRender : false,
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
							fieldLabel : '<fmt:message key="property.changeCode" />',
							name : 'eapsCode',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.changeName" />',
							readOnly : true,
							name : 'changeName'
						},
						{
							fieldLabel : '<fmt:message key="property.changeGrantNo" />',
							maxLength : 50,
							name : 'changeGrantNo'
						},
						{
							fieldLabel : '<fmt:message key="property.dplyLocation" />',
							readOnly : true,
							name : 'dplyLocation'
						},
						{
							fieldLabel : '<fmt:message key="property.planStartDate" />',
							name : 'planStartDate',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.planStartTime" />',
							name : 'planStartTime',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.actualStartTime" />',
							name : 'actualStartTime',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.planEndDate" />',
							name : 'planEndDate',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.planEndTime" />',
							name : 'planEndTime',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.actualEndDate" />',
							name : 'actualEndDate',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.actualEndTime" />',
							name : 'actualEndTime',
							readOnly : true
						},
						{
	    					fieldLabel : '<fmt:message key="property.endFlag" />',
	    					name : 'endFlag',
	    					readOnly : true,
	    					setValue : function(value){
	    						switch(value){
	    							case '1' : this.setRawValue('是');break;
	    							case '2' : this.setRawValue('否');break;
	    							case '3' : this.setRawValue('部分');break;
	    						}
	    					}
						},
						{
							fieldLabel : '<fmt:message key="property.projectChangeLeader" />',
							name : 'develop',
							readOnly : true
						}]
	                }, {
	                    columnWidth:.5,
	                    layout: 'form',
	                    border:false,
	                    defaultType : 'textfield',
	                    defaults: {anchor : '98%'},
	                    labelAlign : 'right',
	                    items: [
						{
							fieldLabel : '<fmt:message key="property.changeType" />',
							name : 'changeType',
							readOnly : true,
							setValue : function(value){
								switch(value){
									case '1' : this.setRawValue('常规投产');break;
									case '2' : this.setRawValue('临时投产');break;
									case '3' : this.setRawValue('临时操作');break;
									case '4' : this.setRawValue('紧急修复');break;
								}
							}
						},
						{
							fieldLabel : '<fmt:message key="property.changeTable" />',
							name : 'changeTable',
							readOnly : true,
							setValue : function(value){
								switch(value){
									case '0' : this.setRawValue('否');break;
									case '1' : this.setRawValue('是');break;
									case '2' : this.setRawValue('已归档');break;
								}
							}
						},
						{
							fieldLabel : '<fmt:message key="property.lastRebootDate" />',
							name : 'lastRebootDate',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.nowRebootTime" />',
							name : 'nowRebootTime',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.rebootExecInfo" />',
							name : 'rebootExecInfo',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.verifyInfo" />',
							name : 'verifyInfo',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.operationId" />',
							name : 'operationId',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.operation" />',
							name : 'operation',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.operationTel" />',
							name : 'operationTel',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.maintainTomo" />',
							name : 'maintainTomo',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.reviewerId" />',
							maxLength : 10,
							name : 'reviewerId'
						},
						{
							fieldLabel : '<fmt:message key="property.reviewer" />',
							maxLength : 10,
							name : 'reviewer'
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
		    					readOnly : true
		    				},
		    				{
		    					xtype : 'textarea',
		    					fieldLabel : '<fmt:message key="property.primaryChangeRisk" />',
		    					name : 'primaryChangeRisk',
		    					height : 120,
		    					readOnly : true
		    				}, 
		    				{
		    					fieldLabel : '<fmt:message key="property.other" />',
		    					name : 'other',
		    					readOnly : true
		    				}]
		                },{
		                    columnWidth:.5,
		                    layout: 'form',
		                    defaults: {anchor : '98%'},
		                    border:false,
		                    labelAlign : 'right',
		                    defaultType : 'textfield', 
		                    items: [{
		    					fieldLabel : '<fmt:message key="property.stopServiceTime" />',
		    					name : 'stopServiceTime',
		    					readOnly : true
		    				},
		    				{
		    					xtype : 'textarea',
		    					fieldLabel : '<fmt:message key="property.riskHandleMethod" />',
		    					name : 'riskHandleMethod',
		    					height : 120,
		    					readOnly : true
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
		    					fieldLabel : '<fmt:message key="property.time" />',
		    					name : 'time',
		    					readOnly : true
							},
							{
								xtype : 'textarea',
								fieldLabel : '<fmt:message key="property.phenomenon" />',
								name : 'phenomenon',
								height : 120,
								readOnly : true
							},
							{
								xtype : 'textarea',
								fieldLabel : '<fmt:message key="property.handleMethod" />',
								name : 'handleMethod',
								readOnly : true,
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
		    					fieldLabel : '<fmt:message key="property.type" />',
		    					name : 'type',
		    					readOnly : true
							}, {
								xtype : 'textarea',
								fieldLabel : '<fmt:message key="property.cause" />',
								name : 'cause',
								readOnly : true,
		    					height : 120
							},
							{
								xtype : 'textarea',
								fieldLabel : '<fmt:message key="property.improveMethod" />',
								name : 'improveMethod',
								readOnly : true,
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
	                    defaultType : 'textfield', 
	                    defaults: {anchor : '98%'},
	                    items: [{
	    					fieldLabel : '<fmt:message key="property.monitorEffectContent" />',
	    					name : 'monitorEffectContent',
	    					readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.deviceName" />',
							name : 'deviceName',
							readOnly : true
						},
						{
							xtype : 'textarea',
							fieldLabel : '<fmt:message key="property.ipAddress" />',
							name : 'ipAddress',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.explainDevice" />',
							name : 'explainDevice',
							readOnly : true
						},
						{
							fieldLabel : '<fmt:message key="property.explainMonitorPlatform" />',
							name : 'explainMonitorPlatform',
							readOnly : true
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
	    					readOnly : true
	    				}]
	                },{
	                    columnWidth:.5,
	                    layout: 'form',
	                    border:false,
	                    defaultType : 'textfield', 
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
	    					readOnly : true
	    				},
						{
							fieldLabel : '<fmt:message key="property.effectStartDate" />',
							name : 'effectStartDate',
							readOnly : true
						},
	    				{
	    					fieldLabel : '<fmt:message key="property.effectStartTime" />',
	    					name : 'effectStartTime',
	    					readOnly : true
	    				},
						{
							fieldLabel : '<fmt:message key="property.effectEndDate" />',
							name : 'effectEndDate',
							readOnly : true
						},
	    				{
	    					fieldLabel : '<fmt:message key="property.effectEndTime" />',
	    					name : 'effectEndTime',
	    					readOnly : true
	    				}]
	                }]
	            },{
	            	title:'自动化请求排期 ',
	            	id : 'sortView',
	            	iconCls : 'button-plan',
	            	layout: 'form',
	            	height:440,
	            	 items: [arrangeViewGrid],
	            	 scope : this,	
					 listeners : {
						}
	            }]
	        }],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				scope : this,
				handler : this.doClose
			} ]
		});
		
		// 加载表单数据
		this.load({
			url : '${ctx}/${managePath}/appchangemanage/view',
			method : 'POST',
			params : {
				/* aplCode : '${param.aplCode}',
				planStartDate : '${param.planStartDate}' */
				appChangeId : '${param.appChangeId}'
			},
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure ,
		    success: function(){
				Ext.Ajax.request({
					method : 'POST',
					url:'${ctx}/${managePath}/appchangemanage/hide',	
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					disableCaching:true,
					params : {
						appsysCode : '${param.aplCode}'
					},
					success: function(response) {
						
						var data = Ext.decode(response.responseText).data;
						if(1 != data){
							Ext.getCmp('appChangeTabpanel').hideTabStripItem('sortView');
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
	// 关闭操作
	doClose : function() {
		app.closeTab('view_AppChangeManage');
	},
	loadSuccess : function(form, action){
		/* var changeDate = this.getForm().findField('changeDate');
		if(changeDate.getValue() == ''){
			changeDate.setValue(this.getForm().findField('planStartDate').getValue());
		} */
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
	}
	
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("view_AppChangeManage").add(new AppChangeManageViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AppChangeManage").doLayout();
</script>
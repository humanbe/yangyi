<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
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
		// 设置基类属性
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
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					name : 'aplCode',
					readOnly : true
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
		            forceLayout : true,
		            plain:true,
		            autoScroll:true,
		            enableTabScroll:true,
		            activeTab: 0,
		            height:340,
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
								fieldLabel : '<fmt:message key="property.changeCode" />',
								name : 'eapsCode',
								maxLength : 50
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
							}]
		                },{
		                    columnWidth:.5,
		                    layout: 'form',
		                    border:false,
		                    defaultType : 'textfield',
		                    defaults: {anchor : '98%'},
		                    labelAlign : 'right',
		                    items: [{
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
							},
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
								fieldLabel : '<fmt:message key="property.operation" />',
								maxLength : 10,
								name : 'operation'
							},
							{
								fieldLabel : '<fmt:message key="property.maintainTomo" />',
								maxLength : 10,
								name : 'maintainTomo'
							},
							{
								fieldLabel : '<fmt:message key="property.reviewer" />',
								maxLength : 10,
								name : 'reviewer'
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
							}]
		                },{
		                    columnWidth:.5,
		                    layout: 'form',
		                    border:false,
		                    defaults: {anchor : '98%'},
		                    items: [{
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
		    				},
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
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.effectStartTime" />',
								name : 'effectStartTime',
								format : 'H:i',
								increment : 30
							},
							{
								xtype : 'timefield',
								fieldLabel : '<fmt:message key="property.effectEndTime" />',
								name : 'effectEndTime',
								format : 'H:i',
								increment : 30
							}]
		                }]
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
		this.load( {
			url : '${ctx}/${managePath}/appchangemanage/view',
			method : 'POST',
			params : {
				appChangeId: '${param.appChangeId}'
			},
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure
		});
	},
	// 保存操作
	doSave : function() {
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
				app.loadTab('view_AppChangeManage', 
						'<fmt:message key="button.view" /><fmt:message key="property.appChangeInfo" />', 
						'${ctx}/${managePath}/appchangemanage/view', 
						params);
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
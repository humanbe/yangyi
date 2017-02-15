<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义新建表单
AplAnalyzeCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
	
		//获取应用系统运行分析状态
	    var aplAnalyzeCreateStatusStore = new Ext.data.ArrayStore({
	        fields: ['valueField', 'displayField'],
	        data : [['0', '正常'],
	                	['1', '异常']
	                ]
	    });
	
		//获取系统代码列表数据
		var aplAnalyzeCreateAplCodeStore = new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
				method : 'GET'
			}),
			reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
		});
		aplAnalyzeCreateAplCodeStore.load();
		
		//获取应用运行分析科目数据
		var aplAnalyzeCreateItemsStore;
		
		// 设置基类属性		AplAnalyzeCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 150,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/aplanalyze/create',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '应用系统编号',
					id : 'AplAnalyzeCreateAplCode',
					hiddenName : 'aplCode',
					tabIndex : this.tabIndex++,
					displayField : 'displayField',
					valueField : 'valueField',
					typeAhead : true,
					forceSelection  : true,
					store : aplAnalyzeAplCodeStore,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : false,
					allowBlank : false,
			        emptyText:'请选择应用系统编号...',
					listeners : {
						select : function(combo, record, index){
							Ext.getCmp("AplAnalyzeCreateAnaItem").clearValue();
							var aplCode = combo.value;
							var transDate = Ext.util.Format.date(Ext.getCmp("AplAnalyzeCreateTransDate").getValue(),'Ymd');
							if(transDate != ''){
								//获取应用运行分析科目数据
								aplAnalyzeCreateItemsStore = new Ext.data.Store({
									proxy: new Ext.data.HttpProxy({
										url: '${ctx}/${managePath}/aplanalyze/browseAplAnalyzeItemList?aplCode='+ aplCode + "&transDate="+ transDate,
										method : 'GET'
									}),
									reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
								});
								aplAnalyzeCreateItemsStore.load();
								Ext.getCmp("AplAnalyzeCreateAnaItem").store = aplAnalyzeCreateItemsStore;
								Ext.getCmp("AplAnalyzeCreateAnaItem").bindStore(aplAnalyzeCreateItemsStore);
							}
						}
					}
				},
				{
					xtype : 'datefield',
					fieldLabel : '交易日期',
					id : 'AplAnalyzeCreateTransDate',
					tabIndex : this.tabIndex++,
					name : 'transDate',
					format : 'Ymd',
					editable : false,
					allowBlank : false,
			        emptyText:'请选择交易日期...',
					listeners : {
						select : function(dateField, date){
							var aplCode = Ext.getCmp("AplAnalyzeCreateAplCode").getValue();
							var transDate = Ext.util.Format.date(date,'Ymd');
							if(aplCode != ''){
								//获取应用运行分析科目数据
								aplAnalyzeCreateItemsStore = new Ext.data.Store({
									proxy: new Ext.data.HttpProxy({
										url: '${ctx}/${managePath}/aplanalyze/browseAplAnalyzeItemList?aplCode='+ aplCode + "&transDate="+ transDate,
										method : 'GET'
									}),
									reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
								});
								aplAnalyzeCreateItemsStore.load();
								Ext.getCmp("AplAnalyzeCreateAnaItem").store = aplAnalyzeCreateItemsStore;
								Ext.getCmp("AplAnalyzeCreateAnaItem").bindStore(aplAnalyzeCreateItemsStore);
							}
						}
					}
				},
				{
					xtype : 'combo',
					fieldLabel : '分析科目',
					id : 'AplAnalyzeCreateAnaItem',
					hiddenName : 'anaItem',
					tabIndex : this.tabIndex++,
					displayField : 'displayField',
					valueField : 'valueField',
					typeAhead : true,
					store : null,
					forceSelection  : true,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					allowBlank : false,
			        emptyText:'请先选择系统编号及交易日期后再选择分析科目...',
					editable : false
				},
				{
					xtype : 'textarea',
					fieldLabel : '运行情况分析',
					id : 'AplAnalyzeCreateExeAnaDesc',
					name : 'exeAnaDesc',
					maxLength : 400,
					height : 100
				},
				{
					xtype : 'combo',
					fieldLabel : '状态',
					id : 'AplAnalyzeCreateStatus',
					hiddenName : 'status',
					store: aplAnalyzeCreateStatusStore,
			        displayField:'displayField',
			        valueField : 'valueField',
			        typeAhead: true,
			        mode: 'local',
			        forceSelection: true,
			        triggerAction: 'all',
					allowBlank : false,
			        emptyText:'请选择状态...',
			        selectOnFocus:true,
					editable : false
				},
				{
					xtype : 'textfield',
					fieldLabel : '分析人',
					id : 'AplAnalyzeCreateAnaUser',
					name : 'anaUser'
				},
				{
					xtype : 'textfield',
					fieldLabel : '审核人',
					id : 'AplAnalyzeCreateRevUser',
					name : 'revUser'
				},
				{
					xtype : 'datefield',
					fieldLabel : '完成日期',
					id : 'AplAnalyzeCreateEndDate',
					tabIndex : this.tabIndex++,
					name : 'endDate',
					format : 'Ymd',
					editable : false
				},
				{
					xtype : 'textfield',
					fieldLabel : '附件路径文件名',
					id : 'AplAnalyzeCreateFilePath',
					tabIndex : this.tabIndex++,
					name : 'filePath'
				}
	  		],
			// 定义按钮
			buttons : [ {
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				tabIndex : this.tabIndex++,
				handler : this.doCancel
			} ]
		});
	},
	// 保存操作
	doSave : function() {
		this.getForm().submit( {
			scope : this,
			success : this.saveSuccess,
			failure : this.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	// 取消操作
	doCancel : function() {
		app.closeTab('add_AplAnalyze');
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
				app.closeTab('add_AplAnalyze');
				var grid = Ext.getCmp("AplAnalyzeListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					transDate : action.result.transDate,
					anaItem : encodeURIComponent(action.result.anaItem)
				};
				//如果标签页存在,重载页面
				var tab = Ext.getCmp("view_AplAnalyze");
				if(tab){
					tab.setTitle('<fmt:message key="button.view" />' + action.result.aplCode +'系统(' + action.result.anaItem + ")运行分析");
				}
				app.loadTab('view_AplAnalyze', 
						'<fmt:message key="button.view" />' + action.result.aplCode +'系统(' + action.result.anaItem + ")运行分析", 
						'${ctx}/${managePath}/aplanalyze/view', params);
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
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("add_AplAnalyze").add(new AplAnalyzeCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_AplAnalyze").doLayout();
</script>
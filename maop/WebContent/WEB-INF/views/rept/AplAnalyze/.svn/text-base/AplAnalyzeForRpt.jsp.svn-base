<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplAnalyzeForRptAnaItemNum;
var aplAnalyzeForRptDynamicItem = [];
var appWindowHeight;
var appWindowWidth;
AplAnalyzeForRptForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
	
		//获取应用系统运行分析状态	    var aplAnalyzeEditStatusStore = new Ext.data.ArrayStore({
	        fields: ['valueField', 'displayField'],
	        data : [['0', '正常'],
	                	['1', '异常']
	                ]
	    });
		//获取应用运行分析科目数据
		Ext.Ajax.request({
			method : 'POST',
			url : '${ctx}/${managePath}/aplanalyze/getAnaItemsNum',
			params: {aplCode : '${param.aplCode}',
				reportType : '${param.reportType}',
				endDate : '${param.endDate}'
			},
			disableCaching : true,	//禁止缓存
			async : false, //同步请求
			success : function(response,option){
				var text = response.responseText;
				aplAnalyzeForRptAnaItemNum = Ext.util.JSON.decode(Ext.util.JSON.decode(text).anaItemNum);
				for(var i = 0; i < aplAnalyzeForRptAnaItemNum ; i++){
					aplAnalyzeForRptDynamicItem.push({
			            xtype: 'compositefield',
			            fieldLabel: (i+1),
			            labelSeparator : '.',
			            combineErrors: false,
			            items: [{
			                xtype: 'displayfield',
			                name : 'anaItem'+i,
			                id : 'AplAnalyzeForRptAnaItem'+i,
			               	width: 200,
			                readOnly : true
			            },{
			                xtype: 'displayfield',
			                value: '运行状态: '
			            },{
							xtype : 'combo',
							fieldLabel : '状态',
							id : 'AplAnalyzeForRptStatus'+i,
							hiddenName : 'status'+i,
							store: aplAnalyzeEditStatusStore,
						    displayField:'displayField',
						    valueField : 'valueField',
						    typeAhead: true,
						    mode: 'local',
						    forceSelection: true,
						    triggerAction: 'all',
							allowBlank : false,
						    emptyText:'请选择状态...',
						    selectOnFocus:true,
			               	width: 100,
							editable : false
						}]
			        	},{
			                xtype: 'textarea',
			                name : 'exeAnaDesc'+i,
			                id : 'AplAnalyzeForRptExeAnaDesc'+i,
			                width: 800,
			                height : 50
			            	});
				}
			},
			// 请求失败时
			failure : function(response){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '在读取动态数据时发生错误，请重新刷新后，再打开菜单再试!',
					fn : function() {
						Ext.getCmp("DayRptManageIndexAplCode").focus();
					},
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.INFO
				});
			},
			callback : function(options,success,response){
			}
		});
		// 设置基类属性		AplAnalyzeForRptForm.superclass.constructor.call(this, {
			title : '运行情况分析维护',
			labelAlign : 'right',
			labelWidth : 120,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/aplanalyze/editForAplAna',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [
			     {
			         xtype: 'fieldset',
			         id : 'AplAnalyzeForRptFieldset1',
		             border : true,
		             frame : true,
		             header : true,
			         collapsible: false,
			         items: [
							{
					            xtype: 'compositefield',
					            combineErrors: false,
								fieldLabel : '应用系统编号',
					            items: [{
									xtype : 'textfield',
									id : 'AplAnalyzeForRptAplCode',
									name : 'aplCode',
					               	width: 200,
									readOnly : true,
									disabled : true
								},{
					                xtype: 'displayfield',
					                value: '交易日期: '
					            },{
										xtype : 'datefield',
										fieldLabel : '交易日期',
										tabIndex : this.tabIndex++,
										id : 'AplAnalyzeForRptTransDate',
										name : 'transDate',
				    					format : 'Ymd',
						               	width: 200,
										readOnly : true,
										disabled : true
					            	},{
						                xtype: 'displayfield',
						                value: '分析人: '
						            },
						        	 {
				    					xtype : 'textfield',
				    					fieldLabel : '分析人',
				    					id : 'AplAnalyzeForRptAnaUser',
				    					name : 'anaUser',
							            width: 200,
										readOnly : true,
										disabled : true
				    				}]
					        },
							{
					            xtype: 'compositefield',
					            combineErrors: false,
								fieldLabel : '审核人',
					            items: [{
			    					xtype : 'textfield',
			    					fieldLabel : '审核人',
			    					id : 'AplAnalyzeForRptRevUser',
			    					name : 'revUser',
					               	width: 200
			    				},{
					                xtype: 'displayfield',
					                value: '完成日期: '
					            },
			    				{
			    					xtype : 'datefield',
			    					fieldLabel : '完成日期',
			    					id : 'AplAnalyzeForRptEndDate',
			    					name : 'endDate',
					               	width: 200,
			    					format : 'Ymd',
									readOnly : true,
									disabled : true
			                	}]
					        }]
				},
	            {
	                xtype: 'fieldset',
			         id : 'AplAnalyzeForRptFieldset2',
	                border : true,
	                collapsible: false,
		            header : true,
	                items: []
	            }
	 		],
			// 定义按钮
			buttons : [{
				text : '加载常用数据',
				iconCls : 'button-load',
				formBind : true,
				scope : this,
				disabled : true,
				handler : this.doLoad
			},{
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
		Ext.each(aplAnalyzeForRptDynamicItem, function(item){
	 		Ext.getCmp("AplAnalyzeForRptFieldset2").add(item);
		});
		// 加载表单数据
		this.load({
			url : '${ctx}/${managePath}/aplanalyze/viewForAplAna',
			params : {aplCode : '${param.aplCode}' , reportType : '${param.reportType}', endDate : '${param.endDate}'},
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			sucess : this.loadSuccess,
			failure : this.loadFailure
		});
	},
	doLoad : function() {
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/aplanalyze/loadLatest',
			params : {
				aplCode : this.getForm().findField('aplCode').getValue(),
				reportType : '${param.reportType}',
				endDate : Ext.util.Format.date(this.getForm().findField('endDate').getValue(),'Ymd')
				},
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		if(error == null){
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '找不到历史记录',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.WARNING
			});
		}else{
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 数据加载失败回调
	loadSuccess : function(form, action) {
	},
	// 保存操作
	doSave : function() {
		var anaDesc;
		for(var i = 0; i < aplAnalyzeForRptAnaItemNum; i++){
			anaDesc = Ext.getCmp("AplAnalyzeForRptExeAnaDesc"+i).getValue();
			if(countByteLength(anaDesc) > 200){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '运行情况分析描述<fmt:message key="error.input.over.length"/>50',
					fn : function() {
						Ext.getCmp("AplAnalyzeForRptExeAnaDesc"+i).focus(true);
					},
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.INFO
				});
				return false;
			}
		}
		
		var aplCode = Ext.getCmp("AplAnalyzeForRptAplCode").getValue().trim();
		var transDate = Ext.util.Format.date(Ext.getCmp("AplAnalyzeForRptTransDate").getValue(),'Ymd');
		var anaUser = Ext.getCmp("AplAnalyzeForRptAnaUser").getValue().trim();
		var revUser = Ext.getCmp("AplAnalyzeForRptRevUser").getValue().trim();
		var endDate = Ext.util.Format.date(Ext.getCmp("AplAnalyzeForRptEndDate").getValue(),'Ymd');
		var anaInfo = [];
		for(var i = 0; i < aplAnalyzeForRptAnaItemNum; i++){
			var anaItem = Ext.getCmp("AplAnalyzeForRptAnaItem"+i).getValue().trim();
			var status = Ext.getCmp("AplAnalyzeForRptStatus"+i).getValue().trim();
			var anaDesc = Ext.getCmp("AplAnalyzeForRptExeAnaDesc"+i).getValue().trim();
			anaInfo.push(anaItem + "|+|" + status + "|+|" + anaDesc);
		}
		
		this.getForm().submit( {
			scope : this,
			params : {aplCodeParam : aplCode , 
						transDateParam : transDate, 
						anaUserParam : anaUser , 
						revUserParam : revUser , 
						endDateParam : endDate , 
						anaInfoParam : anaInfo},
			success : this.saveSuccess,
			failure : this.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	// 取消操作
	doCancel : function() {
		/*
		app.window.setWidth(appWindowWidth);
		app.window.setHeight(appWindowHeight);
		app.window.center(); 
		app.closeWindow();
		*/
		app.closeTab('APL_ANALYZE');
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
				/*
				app.window.setWidth(appWindowWidth);
				app.window.setHeight(appWindowHeight);
				app.window.center(); 
				app.closeWindow();
				*/
				app.closeTab('APL_ANALYZE');
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

//计算字符串字节数
function countByteLength(value){
	var len = 0;
	var ch;
	for(var i = 0; i < value.length; i++){
		ch = value.charAt(i);
		len++;
		if(escape(ch).length > 4)
        {
	         //中文字符的长度经编码之后大于4
	         len++;
         }
	}
	return len;
}
/*
appWindowHeight  = app.window.getHeight();
appWindowWidth  = app.window.getWidth();
app.window.setWidth(1050);
app.window.setHeight(600);
app.window.get(0).doLayout();
app.window.center();
app.window.get(0).add(new AplAnalyzeForRptForm());
app.window.get(0).doLayout();
*/
Ext.getCmp("APL_ANALYZE").add(new AplAnalyzeForRptForm());
Ext.getCmp("APL_ANALYZE").doLayout();
</script>
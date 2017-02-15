<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AplAnalyzeViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
	
		// 设置基类属性		AplAnalyzeViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 150,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'textfield',
					fieldLabel : '应用系统编号',
					name : 'aplCode',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '交易日期',
					name : 'transDate',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '分析科目',
					name : 'anaItem',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '运行情况分析',
					name : 'exeAnaDesc',
					height : 100,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '状态',
					name : 'status',
					readOnly : true,
					setValue : function(value){
						switch(value){
						case '0' : this.setRawValue("正常"); break;
						case '1' : this.setRawValue("异常"); break;
						}
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '分析人',
					name : 'anaUser',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '审核人',
					name : 'revUser',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '完成日期',
					name : 'endDate',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '附件路径文件名',
					name : 'filePath',
					readOnly : true
				}
			],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			} ]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/aplanalyze/view',
			params : {aplCode : '${param.aplCode}' , transDate : '${param.transDate}', anaItem : decodeURIComponent('${param.anaItem}')},
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	// 关闭操作
	doClose : function() {
		app.closeTab('view_AplAnalyze');
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
Ext.getCmp("view_AplAnalyze").add(new AplAnalyzeViewForm());
// 刷新Tab页布局
Ext.getCmp("view_AplAnalyze").doLayout();
</script>
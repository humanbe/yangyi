<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
AplAnalyzeEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
	
		//获取应用系统运行分析状态
	    var aplAnalyzeEditStatusStore = new Ext.data.ArrayStore({
	        fields: ['valueField', 'displayField'],
	        data : [['0', '正常'],
	                	['1', '异常']
	                ]
	    });
	
		// 设置基类属性		AplAnalyzeEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 150,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/aplanalyze/edit/${param.aplCode}/${param.transDate}/'+encodeURIComponent('${param.anaItem}'),
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
					id : 'AplAnalyzeEditAplCode',
					name : 'aplCode',
					readOnly : true,
					disabled : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '交易日期',
					tabIndex : this.tabIndex++,
					id : 'AplAnalyzeEditTransDate',
					name : 'transDate',
					allowBlank : false,
					readOnly : true,
					disabled : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '分析科目',
					id : 'AplAnalyzeEditAnaItem',
					name : 'anaItem',
					readOnly : true,
					disabled : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '运行情况分析',
					id : 'AplAnalyzeEditExeAnaDesc',
					name : 'exeAnaDesc',
					height : 100
				},
				{
					xtype : 'combo',
					fieldLabel : '状态',
					id : 'AplAnalyzeEditStatus',
					hiddenName : 'status',
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
					editable : false
				},
				{
					xtype : 'textfield',
					fieldLabel : '分析人',
					id : 'AplAnalyzeEditAnaUser',
					name : 'anaUser'
				},
				{
					xtype : 'textfield',
					fieldLabel : '审核人',
					id : 'AplAnalyzeEditRevUser',
					name : 'revUser'
				},
				{
					xtype : 'textfield',
					fieldLabel : '完成日期',
					id : 'AplAnalyzeEditEndDate',
					name : 'endDate'
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
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/aplanalyze/view',
			params : {aplCode : '${param.aplCode}' , transDate : '${param.transDate}', anaItem : decodeURIComponent('${param.anaItem}')},
			method : 'POST',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure
		});
	},
	// 保存操作
	doSave : function() {
		var anaDesc = Ext.getCmp("AplAnalyzeEditExeAnaDesc").getValue();
		if(countByteLength(anaDesc) > 200){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '运行情况分析描述<fmt:message key="error.input.over.length"/>50',
				fn : function() {
					Ext.getCmp("AplAnalyzeEditExeAnaDesc").focus(true);
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			return false;
		}
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
		app.closeTab('edit_AplAnalyze');
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
				var params = {
					aplCode : '${param.aplCode}',
					transDate : '${param.transDate}',
					anaItem : '${param.anaItem}'
				};
				app.closeTab('edit_AplAnalyze');
				var grid = Ext.getCmp("AplAnalyzeListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				//如果标签页存在,重载页面
				var tab = Ext.getCmp("view_AplAnalyze");
				if(tab){
					tab.setTitle('<fmt:message key="button.view" />' + '${param.aplCode}' + '系统(' + decodeURIComponent('${param.anaItem}')  + ")运行分析");
				}
				app.loadTab('view_AplAnalyze', 
						'<fmt:message key="button.view" />' + '${param.aplCode}' + '系统(' + decodeURIComponent('${param.anaItem}')  + ")运行分析", 
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

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("edit_AplAnalyze").add(new AplAnalyzeEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_AplAnalyze").doLayout();
</script>
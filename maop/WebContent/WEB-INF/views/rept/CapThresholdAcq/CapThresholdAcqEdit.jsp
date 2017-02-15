<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var capCheckFlagStore = new Ext.data.SimpleStore({
	fields : ['checkFlagDisplay', 'checkFlagValue'],
	data : [['否', '0'], ['是', '1']]
});
CapThresholdAcqEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 设置基类属性		CapThresholdAcqEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			url : '${ctx}/${managePath}/capthresholdacq/edit/${param.aplCode}/'+ encodeURIComponent('${param.thresholdItem}'),
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
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					name : 'aplCode',
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					name : 'capacityType',
					fieldLabel : '<fmt:message key="property.capacityType" />',
					setValue : function(value){
						switch(value){
							case '1': this.setRawValue('应用类');break;
							case '2': this.setRawValue('系统类');break;
							case '3': this.setRawValue('网络类');break;
						}
					},
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					name : 'thresholdType',
					fieldLabel : '<fmt:message key="property.thresholdType" />',
					setValue : function(value){
						switch(value){
							case '1': this.setRawValue('联机');break;
							case '2': this.setRawValue('批量');break;
							case '3': this.setRawValue('操作系统');break;
							case '4': this.setRawValue('数据库');break;
							case '5': this.setRawValue('中间件');break;
							case '6': this.setRawValue('网络层');break;
							case '7': this.setRawValue('web层');break;
							case '8': this.setRawValue('其他');break;
						}
					},
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdItem" />',
					name : 'thresholdItem',
					disabled : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.busiDemand" />',
					name : 'busiDemand',
					maxLength : 150,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.threshold" />',
					name : 'threshold',
					maxLength : 20,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.thresholdDate" />',
					name : 'thresholdDate',
					format : 'Ymd',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdFrom" />',
					name : 'thresholdFrom',
					maxLength : 150,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.thresholdCheckFlag" />',
					store : capCheckFlagStore,
					displayField : 'checkFlagDisplay',
					valueField : 'checkFlagValue',
					hiddenName : 'thresholdCheckFlag',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdExplain" />',
					name : 'thresholdExplain',
					maxLength : 150,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.additionalExplain" />',
					name : 'additionalExplain',
					maxLength : 150,
					tabIndex : this.tabIndex++
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
			url : '${ctx}/${managePath}/capthresholdacq/view',
			method : 'POST',
			params : {
				aplCode : '${param.aplCode}',
				thresholdItem : decodeURIComponent('${param.thresholdItem}')
			},
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure
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
		app.closeTab('edit_CapThresholdAcq');
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
					thresholdItem : '${param.thresholdItem}'
				};
				app.closeTab('edit_CapThresholdAcq');
				var grid = Ext.getCmp("CapThresholdAcqListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_CapThresholdAcq', 
						'<fmt:message key="button.view" /><fmt:message key="property.capThresholdAcqInfo" />', 
						'${ctx}/${managePath}/capthresholdacq/view', 
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
Ext.getCmp("edit_CapThresholdAcq").add(new CapThresholdAcqEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_CapThresholdAcq").doLayout();
</script>
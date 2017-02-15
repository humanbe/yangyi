<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/jobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});
userStore.load();
CapThresholdAcqViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	// 构造方法
	constructor : function(cfg) {

		Ext.apply(this, cfg);
		
		// 设置基类属性		CapThresholdAcqViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			scope : this,
			monitorValid : true,
			// 定义表单组件
			items : [
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.appsyscd" />',
					name : 'aplCode',
					tabIndex : this.tabIndex++,
					readOnly : true
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
					readOnly : true
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
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdItem" />',
					name : 'thresholdItem',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.busiDemand" />',
					name : 'busiDemand',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.threshold" />',
					name : 'threshold',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdDate" />',
					name : 'thresholdDate',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdFrom" />',
					name : 'thresholdFrom',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdCheckFlag" />',
					name : 'thresholdCheckFlag',
					setValue : function(value){
						switch(value){
							case '0': this.setRawValue('否');break;
							case '1': this.setRawValue('是');break;
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdExplain" />',
					name : 'thresholdExplain',
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdCreator" />',
					name : 'thresholdCreator',
					setValue : this.userStoreValue,
					scope : this,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdCreated" />',
					name : 'thresholdCreated',
					setValue : function(value){
						if(Ext.isEmpty(value)){
							this.setRawValue('');
						}else{
							this.setRawValue(Ext.util.Format.date(new Date(value),'Y-m-d H:i:s'));
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdModifier" />',
					name : 'thresholdModifier',
					setValue : this.userStoreValue,
					scope : this,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.thresholdModified" />',
					name : 'thresholdModified',
					setValue : function(value){
						if(Ext.isEmpty(value)){
							this.setRawValue('');
						}else{
							this.setRawValue(Ext.util.Format.date(new Date(value),'Y-m-d H:i:s'));
						}
					},
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.additionalExplain" />',
					name : 'additionalExplain',
					readOnly : true
				}
			],
			// 定义表单按钮
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				scope : this,
				handler : this.doClose
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
			failure : this.loadFailure,
			success : this.loadSuccess
		});
	},
	userStoreValue : function(value) {
		var index = userStore.find('username', value);
		if (index == -1) {
			this.setRawValue('');
		} else {
			this.setRawValue(value + '(' + userStore.getAt(index).get('name') + ')');
		}
	},
	// 关闭操作
	doClose : function() {
		app.closeTab('view_CapThresholdAcq');
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
Ext.getCmp("view_CapThresholdAcq").add(new CapThresholdAcqViewForm());
// 刷新Tab页布局
Ext.getCmp("view_CapThresholdAcq").doLayout();
</script>
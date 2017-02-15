<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//获取系统代码列表数据
var aplCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});


//定义新建表单
RptMultTransFrom = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		aplCodeStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		RptMultTransFrom.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/rptdatainterface/importDatasource',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : aplCodeStore,
					hiddenName : 'aplCode',
					displayField : 'displayField',
					valueField : 'valueField',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					selectOnFocus : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						 scope : this,
						 'beforequery' : function(e){
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
						}
					}
				},
				{
					xtype : 'datefield',
					fieldLabel : '当前日期',
					name : 'Date',
					allowBlank : false,
					format :'Ymd',
					value : new Date().add(Date.MONTH,0),
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					name : 'sysSrvJson',
					value : '[]',
					hidden : true
				}
	  		],
			// 定义按钮
			buttons : [ {
				text : '导入',
				iconCls : 'button-import',
				formBind : true,
				scope : this,
				handler : this.doImport
			}]
		});
	},
	// 保存操作
	doImport : function() {
		this.getForm().submit({
			scope : this,
			success : this.importSuccess,
			failure : this.importFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.submiting" />'
		});
	},
	// 保存成功回调
	importSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '导入成功',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200
		});

	},
	// 保存失败回调
	importFailure : function(form, action) {
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
Ext.getCmp("MgrRptDatasource").add(new RptMultTransFrom());
// 刷新Tab页布局
Ext.getCmp("MgrRptDatasource").doLayout();

</script>
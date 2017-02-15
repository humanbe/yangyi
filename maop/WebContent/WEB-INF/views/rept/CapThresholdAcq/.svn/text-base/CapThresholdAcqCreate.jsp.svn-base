<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//应用系统
var appsysStoreForCheck =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
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

var capacityTypeStore = new Ext.data.SimpleStore({
	fields :['capacityTypeDisplay', 'capacityTypeValue'],
	data : [['应用类', '1'], ['系统类', '2'], ['网络类', '3']]
});

var thresholdTypeStore = new Ext.data.SimpleStore({
	fields :['thresholdTypeDisplay', 'thresholdTypeValue'],
	data : [['联机', '1'], ['批量', '2'], ['操作系统', '3'], ['数据库', '4'], 
	        ['中间件', '5'], ['网络层', '6'], ['web层', '7'], ['其他', '8']]
});

var checkFlagStore = new Ext.data.SimpleStore({
	fields : ['checkFlagDisplay', 'checkFlagValue'],
	data : [['否', '0'], ['是', '1']]
});

//科目一级分类
rptItemConfIndexItemLevel1Store = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptItemLevel1',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});
rptItemConfIndexItemLevel1Store.on('load',function(){
	Ext.getCmp('CapThresholdAcqCreateItemLevel1').bindStore(rptItemConfIndexItemLevel1Store);
});

//科目二级分类
rptItemConfIndexItemLevel2Store = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptItemLevel2',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});
rptItemConfIndexItemLevel2Store.on('load',function(){
	Ext.getCmp('CapThresholdAcqCreateItemLevel2').bindStore(rptItemConfIndexItemLevel2Store);
});

//科目三级分类
rptItemConfIndexItemLevel3Store = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptItemLevel3',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});
rptItemConfIndexItemLevel3Store.on('load',function(){
	Ext.getCmp('CapThresholdAcqCreateItemLevel3').bindStore(rptItemConfIndexItemLevel3Store);
});

//定义新建表单
CapThresholdAcqCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		appsysStoreForCheck.load();
		Ext.apply(this, cfg);
		
		// 设置基类属性		CapThresholdAcqCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/capthresholdacq/create',
			defaults : {
				anchor : '90%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					id :'CapThresholdAcqCreateAplCode',
					store : appsysStoreForCheck,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'aplCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++,
					scope : this,
					listeners : {
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
						},
						'select' : function(combo, record, index){
							Ext.getCmp('CapThresholdAcqCreateItemLevel1').setRawValue('');
							Ext.getCmp('CapThresholdAcqCreateItemLevel2').setRawValue('');
							Ext.getCmp('CapThresholdAcqCreateItemLevel3').setRawValue('');
							
							rptItemConfIndexItemLevel1Store.baseParams={
	            					appsysCode : encodeURIComponent(Ext.getCmp('CapThresholdAcqCreateAplCode').getValue())
							};
							rptItemConfIndexItemLevel1Store.load();
						}
					}
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.capacityType" />',
					store : capacityTypeStore,
					displayField : 'capacityTypeDisplay',
					valueField : 'capacityTypeValue',
					hiddenName : 'capacityType',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.thresholdType" />',
					store : thresholdTypeStore,
					displayField : 'thresholdTypeDisplay',
					valueField : 'thresholdTypeValue',
					hiddenName : 'thresholdType',
					mode: 'local',
					typeAhead: true,
					editable : false,
				    triggerAction: 'all',
					allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
	            	xtype : 'combo',
					fieldLabel : '一级指标',
					id :'CapThresholdAcqCreateItemLevel1',
					displayField : 'displayField',
					valueField : 'valueField',
					store : rptItemConfIndexItemLevel1Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(combo, record, index) {
							Ext.getCmp('CapThresholdAcqCreateItemLevel2').setRawValue('');
							Ext.getCmp('CapThresholdAcqCreateItemLevel3').setRawValue('');
							//科目二级分类
	            			rptItemConfIndexItemLevel2Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('CapThresholdAcqCreateAplCode').getValue()),
            					itemLevel1 : encodeURIComponent(combo.getValue())
							};
	            			rptItemConfIndexItemLevel2Store.load();
						}
					}
               	},
				{
	            	xtype : 'combo',
					fieldLabel : '二级指标',
					id :'CapThresholdAcqCreateItemLevel2',
					displayField : 'displayField',
					valueField : 'valueField',
					store : rptItemConfIndexItemLevel2Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(combo, record, index) {
							Ext.getCmp('CapThresholdAcqCreateItemLevel3').setRawValue('');
							//科目三级分类
	            			rptItemConfIndexItemLevel3Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('CapThresholdAcqCreateAplCode').getValue()),
	            				itemLevel1 : encodeURIComponent(Ext.getCmp('CapThresholdAcqCreateItemLevel1').getValue()),
	            				itemLevel2 : encodeURIComponent(combo.getValue())
							};
	            			rptItemConfIndexItemLevel3Store.load();
						}
					}
               	},
				{
	            	xtype : 'combo',
					fieldLabel : '应用巡检指标',
					id :'CapThresholdAcqCreateItemLevel3',
					displayField : 'displayField',
					valueField : 'valueField',
					store : rptItemConfIndexItemLevel3Store,
					hiddenName : 'thresholdItem',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
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
					vtype : 'alphanum',
					maskRe : /[0-9]/,
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
					store : checkFlagStore,
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
			buttons : [{
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
		app.closeTab('add_CapThresholdAcq');
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
				app.closeTab('add_CapThresholdAcq');
				var grid = Ext.getCmp("CapThresholdAcqListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				var params = {
					aplCode : action.result.aplCode,
					capacityType : action.result.capacityType,
					thresholdType : action.result.thresholdType,
					thresholdItem : encodeURIComponent(action.result.thresholdItem),
					thresholdSubItem : encodeURIComponent(action.result.thresholdSubItem)
				};
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
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("add_CapThresholdAcq").add(new CapThresholdAcqCreateForm());
// 刷新Tab页布局
Ext.getCmp("add_CapThresholdAcq").doLayout();

</script>
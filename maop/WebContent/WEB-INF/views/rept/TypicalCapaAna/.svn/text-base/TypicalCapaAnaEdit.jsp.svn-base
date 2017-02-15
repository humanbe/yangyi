<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//容量风险分类
	var typicalCapaAnaStore = new Ext.data.ArrayStore({
    fields: ['typicalCapaAnaValue', 'typicalCapaAnaDisplay'],
    data : [['1', '业务容量'],
            	['2', '应用容量'],
            	['3', '资源容量']]});
            	
	var typicalCapaAnaEditSysIdsStore = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			url : '${ctx}/${managePath}/capearlywarningtime/querySystemIDAndNames',
			method : 'GET',
			disableCaching : true
		}),
		reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
	});
TypicalCapaAnaEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		typicalCapaAnaEditSysIdsStore.load();
		
		// 设置基类属性		TypicalCapaAnaEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/typicalcapaana/edit/${param.sysseqnum}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [ 
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.sysseqnum" />',
					name : 'sysseqnum',
					allowBlank : false,
					disabled : true
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appSysCd" />',
					emptyText : '<fmt:message key="message.select.one.only" />',
					store : typicalCapaAnaEditSysIdsStore,
					displayField : 'sysName',
					valueField : 'sysId',
					hiddenName : 'appSysCd',
					mode : 'local',
					typeAhead : true,
					forceSelection : true,
					triggerAction : 'all',
					allowBlank : true,
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
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					allowBlank : false,
					disabled : true
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.riskType" />',
					store : typicalCapaAnaStore,
					displayField : 'typicalCapaAnaDisplay',
					valueField : 'typicalCapaAnaValue',
					editable : false,
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
					hiddenName : 'riskType',
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.workorderSubject" />',
					name : 'workorderSubject',
					format : 'Ymd',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.caseCause" />',
					name : 'caseCause',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.handleMethod" />',
					name : 'handleMethod',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.optimizePlan" />',
					name : 'optimizePlan',
					maxLength : 500,
					height : 80,
					allowBlank : true
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.caseAna" />',
					name : 'caseAna',
					maxLength : 500,
					height : 80,
					allowBlank : true
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
		url : '${ctx}/${managePath}/typicalcapaana/view',
		method : 'POST',
		params : {
			sysseqnum : '${param.sysseqnum}'
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
		app.closeTab('edit_TypicalCapaAna');
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
						sysseqnum : '${param.sysseqnum}'
				};
				app.closeTab('edit_TypicalCapaAna');
				var grid = Ext.getCmp("TypicalCapaAnaListGridPanel");
				if (grid != null) {
					grid.getStore().reload();
				}
				app.loadTab('view_TypicalCapaAnaView', 
						'<fmt:message key="button.view" /><fmt:message key="property.typicalcapaana" />', 
						'${ctx}/${managePath}/typicalcapaana/view', params);
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
Ext.getCmp("edit_TypicalCapaAna").add(new TypicalCapaAnaEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_TypicalCapaAna").doLayout();
</script>
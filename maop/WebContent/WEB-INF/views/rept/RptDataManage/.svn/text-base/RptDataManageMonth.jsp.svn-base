<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
Ext.apply(Ext.form.VTypes, {
    daterange : function(val, field) {
        var date = field.parseDate(val);

        if(!date){
            return false;
        }
        if (field.startDateField) {
            var start = Ext.getCmp(field.startDateField);
            if (!start.maxValue || (date.getTime() != start.maxValue.getTime())) {
                start.setMaxValue(date);
                start.validate();
            }
        }
        else if (field.endDateField) {
            var end = Ext.getCmp(field.endDateField);
            if (!end.minValue || (date.getTime() != end.minValue.getTime())) {
                end.setMinValue(date);
                end.validate();
            }
        }
        
        return true;
    }
});

var sysAplNameStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/rptdatainterface/querySysAplNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['aplCode', 'aplAllName'])
});

var typeStore = new Ext.data.SimpleStore({
	fields : ['monthTypeDisplay', 'monthTypeValue'],
	data : [['交易量月统计', 1], ['系统资源使用月统计', 2], ['分钟和秒交易量峰值月统计', 3]]
});

var timesTransTypeStore = new Ext.data.SimpleStore({
	fields : ['timesTransTypeDisplay', 'timesTransTypeValue'],
	data : [['分钟交易量', 1], ['秒钟交易量', 2]]
});

//定义新建表单
RptDataMonthForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		RptDataMonthForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/rptdatainterface/importMonth',
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
					store : sysAplNameStore,
					displayField : 'aplAllName',
					valueField : 'aplCode',
					hiddenName : 'aplCode',
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
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.type.statistics" />',
					hiddenName : 'monthType',
					store : typeStore,
					displayField : 'monthTypeDisplay',
					valueField : 'monthTypeValue',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
                    allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo, record, index){
							var timesTransType = this.getForm().findField('timesTransType');
							if(index == 2){
								timesTransType.show();
								if(timesTransType.getValue() == ''){
									timesTransType.setValue(typeStore.getAt(0).get('monthTypeValue'));
								}
							}else{
								timesTransType.hide();
							}
						}
					}
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.type.trans" />',
					hiddenName : 'timesTransType',
					store : timesTransTypeStore,
					displayField : 'timesTransTypeDisplay',
					valueField : 'timesTransTypeValue',
					mode: 'local',
					value : 1,
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
                   	hidden : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.fromMonth" />',
					id : 'RptDataMonthStartMonth',
					name : 'startMonth',
					allowBlank : false,
					plugins: 'monthPickerPlugin',
					format :'Ym',
					endDateField : 'RptDataMonthEndMonth',
					vtype : 'daterange',
					value : new Date().add(Date.MONTH, -1),
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.toMonth" />',
					id : 'RptDataMonthEndMonth',
					name : 'endMonth',
					allowBlank : false,
					startDateField : 'RptDataMonthStartMonth',
					vtype : 'daterange',
					plugins: 'monthPickerPlugin',
					format :'Ym',
					value : new Date().add(Date.MONTH, -1),
					tabIndex : this.tabIndex++
				}
	  		],
			// 定义按钮
			buttons : [ {
				text : '<fmt:message key="button.import" />',
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
		var rows = action.result.rows;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.import.success.rows" />:' + rows,
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
Ext.getCmp("MgrRptDataMonth").add(new RptDataMonthForm());
// 刷新Tab页布局
Ext.getCmp("MgrRptDataMonth").doLayout();

</script>
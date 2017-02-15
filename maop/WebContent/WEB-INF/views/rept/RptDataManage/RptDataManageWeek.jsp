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
	fields : ['weekTypeDisplay', 'weekTypeValue'],
	data : [['交易量周统计', 1], ['系统资源使用周统计', 2]]
});

//定义新建表单
RptDataWeekForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		RptDataWeekForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/rptdatainterface/importWeek',
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
					hiddenName : 'weekType',
					store : typeStore,
					displayField : 'weekTypeDisplay',
					valueField : 'weekTypeValue',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,
                    allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.fromDate" />',
					id : 'RptDataWeekStartDate',
					name : 'startDate',
					allowBlank : false,
					format :'Ymd',
					endDateField : 'RptDataWeekEndDate',
					vtype : 'daterange',
					disabledDays : [0, 2, 3, 4, 5, 6],
					value : new Date().add(Date.DAY, 1 - 7 - new Date().getDay()),
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.toDate" />',
					id : 'RptDataWeekEndDate',
					name : 'endDate',
					allowBlank : false,
					startDateField : 'RptDataWeekStartDate',
					vtype : 'daterange',
					format :'Ymd',
					disabledDays : [1, 2, 3, 4, 5, 6],
					value : new Date().add(Date.DAY, - new Date().getDay()),
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
Ext.getCmp("MgrRptDataWeek").add(new RptDataWeekForm());
// 刷新Tab页布局
Ext.getCmp("MgrRptDataWeek").doLayout();

</script>
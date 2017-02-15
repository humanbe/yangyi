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
</script>
<sec:authorize access="hasRole('MONITOR_DATA_ALL_IMPORT')">
<script type="text/javascript">
sysAplNameStore.on('load',function(){
	var sysAplNameRecord = Ext.data.Record.create([
		{name: 'aplCode', mapping: 'aplCode'},
		{name: 'aplAllName', mapping: 'aplAllName'}
	]);
	var record = new sysAplNameRecord({
		aplCode : 'ALL',
		aplAllName : '<fmt:message key="property.all" />'
	});
	sysAplNameStore.insert(0, record);
});
</script>
</sec:authorize>
<script type="text/javascript">
var sourceStore = new Ext.data.SimpleStore({
	fields :['name', 'value'],
	data : [['监控', 1], ['中间件', 2]]
});


var sysIpStore = new Ext.data.Store();

//定义新建表单
RptDataWeblogicForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		RptDataWeblogicForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			timeout : 300,
			autoScroll : true,
			url : '${ctx}/${managePath}/rptdatainterface/importWeblogic',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [
				{
					id : 'WeblogicAplNameCombo',
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
						},
						select : function(combo, record, index){
							var form = this.getForm();
							if(sysIpStore != null){
								form.findField('ipAddresses').clearValue();
							}
							
							if(index == 0 && combo.value == 'ALL'){
								form.findField('ipAddresses').allowBlank = true;
								form.findField('ipAddresses').hide();
								return;
							}else{
								form.findField('ipAddresses').allowBlank = false;
								form.findField('ipAddresses').show();
							}
							
							sysIpStore = new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/rptdatainterface/queryConfigIps?aplCode=' + combo.value ,
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['ipAddress'])
							});
							
							sysIpStore.on('load', function(){
								form.findField('ipAddresses').store = sysIpStore;
								form.findField('ipAddresses').bindStore(sysIpStore);
								if(sysIpStore.getCount() == 0){
									Ext.Msg.show({
										title : '<fmt:message key="message.title"/>',
										msg : '<fmt:message key="message.ip.not.found"/>',
										fn : function() {
											form.findField('aplCode').reset();
											form.findField('aplCode').focus();
										},
										buttons : Ext.Msg.OK,
										icon : Ext.MessageBox.INFO
									});
								}
							});
							sysIpStore.load();
						}
					}
				}, 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.datasource" />',
					store : sourceStore,
					displayField : 'name',
					valueField : 'value',
					hiddenName : 'sourceType',
					mode: 'local',
					typeAhead: true,
					selectOnFocus : true,
				    triggerAction: 'all',
				    editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'lovcombo',
					fieldLabel : '<fmt:message key="property.ipAddress" />',
					tabIndex : this.tabIndex++,
					width : 300,
					hideOnSelect : false,
					maxHeight : 200,
					hiddenName : 'ipAddresses',
					displayField : 'ipAddress',
					valueField : 'ipAddress',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					allowBlank : false,
					store : sysIpStore,
					triggerAction : 'all',
					mode : 'local',
					disabled : false,
					beforeBlur : function(){},
					listeners : {
						scope : this
					}
				},
				{
					xtype : 'checkboxgroup',
					fieldLabel : '<fmt:message key="property.type" />',
		            items: [{
		                autoHeight: true,
		                defaultType: 'checkbox', 
		                items: [{
			            	checked: true,
			                boxLabel: '<fmt:message key="property.jdbc" />',
			                name: 'jdbc',
			                inputValue: 4
			            }, {
			            	checked: true,
			                boxLabel: '<fmt:message key="property.memory" />',
			                name: 'memory',
			                inputValue: 2
			            }, {
			            	checked: true,
			                boxLabel: '<fmt:message key="property.queue" />',
			                name: 'queue',
			                inputValue: 1
			            }]
		            }]
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.fromDate" />',
					id : 'RptDataWeblogicStartDate',
					name : 'startDate',
					allowBlank : false,
					format : 'Ymd',
					endDateField : 'RptDataWeblogicEndDate',
					vtype : 'daterange',
					value : new Date().add(Date.DAY, -1)
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.toDate" />',
					id : 'RptDataWeblogicEndDate',
					name : 'endDate',
					allowBlank : false,
					startDateField : 'RptDataWeblogicStartDate',
					vtype : 'daterange',
					format : 'Ymd',
					value : new Date().add(Date.DAY, -1)
				},
				{
					xtype : 'textfield',
					name : 'type',
					hidden : true
				},
				{
					xtype : 'textfield',
					name : 'jsonArray',
					value : '[]',
					hidden : true
				}
	  		],
			// 定义按钮
			buttons : [{
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
		var form = this.getForm();
		var typeVal = 0;
		var jdbcCb = form.findField('jdbc');
		var memoryCb = form.findField('memory');
		var queueCb = form.findField('queue');
		if(jdbcCb.getValue()){
			typeVal += jdbcCb.inputValue;
		}
		if(memoryCb.getValue()){
			typeVal += memoryCb.inputValue;
		}
		if(queueCb.getValue()){
			typeVal += queueCb.inputValue;
		}
		
		if(typeVal == 0){
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.type" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200
			});
			return;
		}
		
		var days = (form.findField('endDate').getValue() - form.findField('startDate').getValue())/(3600*24*1000);
		if(days > 31){
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.cannot.over.31.days" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200
			});
			return;
		}
		
		form.findField('type').setValue(typeVal);
		
		var aplCode = form.findField('aplCode').getValue();
		if(aplCode != 'ALL'){
			var ipAddress = form.findField('ipAddresses').getValue();
			var ipAddressArr = ipAddress.split(',');
			var jsonArray = [];
			Ext.each(ipAddressArr, function(item){
				jsonArray.push({'system' : aplCode, 'ip' : item});
			});
			form.findField('jsonArray').setValue(Ext.util.JSON.encode(jsonArray));
		}
		
		form.submit({
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
			msg : '<fmt:message key="message.submit.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200
		});

	},
	// 保存失败回调
	importFailure : function(form, action) {
		switch (action.failureType) {
	        case Ext.form.Action.CONNECT_FAILURE:
	        	Ext.Msg.show({
	    			title : '<fmt:message key="message.title" />',
	    			msg : '<fmt:message key="message.request.timeout" />',
	    			buttons : Ext.MessageBox.OK,
	    			icon : Ext.MessageBox.ERROR
	    		});
	            break;
	        case Ext.form.Action.SERVER_INVALID:
	        	var error = action.result.error;
	    		Ext.Msg.show({
	    			title : '<fmt:message key="message.title" />',
	    			msg : '<fmt:message key="message.import.failed" /><fmt:message key="error.code" />:' + error,
	    			buttons : Ext.MessageBox.OK,
	    			icon : Ext.MessageBox.ERROR
	    		});
   		}
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("MgrRptDataWeblogic").add(new RptDataWeblogicForm());
// 刷新Tab页布局
Ext.getCmp("MgrRptDataWeblogic").doLayout();

</script>
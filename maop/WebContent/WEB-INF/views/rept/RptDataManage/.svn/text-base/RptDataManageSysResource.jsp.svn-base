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

var sysSrvStore = new Ext.data.Store();

//定义新建表单
RptDataSysResrcForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		sysAplNameStore.load();
		Ext.apply(this, cfg);
		// 设置基类属性
		RptDataSysResrcForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 155,
			buttonAlign : 'center',
			frame : true,
			timeout : 300,
			autoScroll : true,
			url : '${ctx}/${managePath}/rptdatainterface/importSysResource',
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
						},
						select : function(combo, record, index){
							var form = this.getForm();
							if(sysSrvStore != null){
								form.findField('srvCodes').clearValue();
							}
							
							if(index == 0 && combo.value == 'ALL'){
								form.findField('srvCodes').allowBlank = true;
								form.findField('srvCodes').hide();
								return;
							}else{
								form.findField('srvCodes').allowBlank = false;
								form.findField('srvCodes').show();
							}
							
							sysSrvStore = new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${managePath}/rptdatainterface/queryServers?aplCode=' + combo.value ,
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['srvCode'])
							});
							
							sysSrvStore.on('load', function(){
								form.findField('srvCodes').store = sysSrvStore;
								form.findField('srvCodes').bindStore(sysSrvStore);
								if(sysSrvStore.getCount() == 0){
									Ext.Msg.show({
										title : '<fmt:message key="message.title"/>',
										msg : '<fmt:message key="message.host.not.found"/>',
										fn : function() {
											form.findField('aplCode').reset();
											form.findField('aplCode').focus();
										},
										buttons : Ext.Msg.OK,
										icon : Ext.MessageBox.INFO
									});
								}
							});
							sysSrvStore.load();
						}
					}
				},
				{
					xtype : 'lovcombo',
					fieldLabel : '<fmt:message key="property.srvCode" />',
					tabIndex : this.tabIndex++,
					width : 300,
					hideOnSelect : false,
					maxHeight : 200,
					hiddenName : 'srvCodes',
					displayField : 'srvCode',
					valueField : 'srvCode',
					typeAhead : true,
					forceSelection  : true,
					editable : false,
					allowBlank : false,
					store : sysSrvStore,
					triggerAction : 'all',
					mode : 'local',
					disabled : false,
					beforeBlur : function(){},
					listeners : {
						scope : this
					}
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.fromDate" />',
					id : 'RptDataSysResrcStartDate',
					name : 'startDate',
					allowBlank : false,
					format : 'Ymd',
					endDateField : 'RptDataSysResrcEndDate',
					vtype : 'daterange',
					value : new Date().add(Date.DAY, -1)
				},
				{
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.toDate" />',
					id : 'RptDataSysResrcEndDate',
					name : 'endDate',
					allowBlank : false,
					startDateField : 'RptDataSysResrcStartDate',
					vtype : 'daterange',
					format : 'Ymd',
					value : new Date().add(Date.DAY, -1)
				},
				{
					xtype : 'textfield',
					name : 'sysSrvJson',
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
		
		var aplCode = form.findField('aplCode').getValue();
		if(aplCode != 'ALL'){
			var srvCodes = form.findField('srvCodes').getValue();
			var srvCodeArr = srvCodes.split(',');
			
			var sysSrvJson = [];
			Ext.each(srvCodeArr, function(item){
				sysSrvJson.push({'aplCode' : aplCode, 'srvCode' : item});
			});
			
			form.findField('sysSrvJson').setValue(Ext.util.JSON.encode(sysSrvJson));
		}
		/* Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '已发起导入！',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.Info
		}); */
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
		//var rows = action.result.rows;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.submit.successful" />:',//message.import.success.rows + rows
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
Ext.getCmp("MgrRptDataSysResource").add(new RptDataSysResrcForm());
// 刷新Tab页布局
Ext.getCmp("MgrRptDataSysResource").doLayout();

</script>
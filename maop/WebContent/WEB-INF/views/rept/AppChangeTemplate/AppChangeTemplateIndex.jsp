<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//待选系统列表数据源
var toBeSelectedStore = new Ext.data.ArrayStore({
	fields: ['aplCode']
});
//已选系统列表数据源
var selectedStore = new Ext.data.ArrayStore({
	fields: ['aplCode']
});
//待选系统记录
var toBeSelectedRecords = [];

AppChangeTemplateExport = Ext.extend(Ext.Panel, {
	form : null,// 查询表单组件
	tabIndex : 0,// 表单组件Tab键顺序	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
	
		this.form = new Ext.FormPanel({
			region : 'center',
			title : '下载应用变更情况汇总',
			frame : true,
			width : 250,
			bodyStyle: 'padding: 10px 20px 0 20px',
			autoHeight: true,
			labelAlign : 'right',
			labelWidth: 190,
			animCollapse : true,
			monitorValid : true,
			defaults: {
            	anchor: '90%',
            	allowBlank: false,
            	msgTarget: 'side'
        	},
        	items : [{
				xtype : 'datefield',
				name : 'changeMonth',
				fieldLabel : '<fmt:message key="property.changeMonth" />',
				plugins: 'monthPickerPlugin',
				allowBlank : false,
				value : new Date(),
				maxValue : new Date(),
				format : 'Ym'
			}],
			buttonAlign : 'center',
			buttons : [{
				text : '<fmt:message key="button.download" />',
				iconCls : 'button-download-excel',
				formBind : true,
				scope : this ,
				handler : this.doDownload
			}]
		});
		// 设置基类属性
		AppChangeTemplateExport.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form ]
		});
	},
	doDownload : function(){
		var changeMonth = Ext.util.Format.date(this.form.getForm().findField('changeMonth').getValue(), 'Ym');
		var aplCodeStore = new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url: '${ctx}/${managePath}/appchangemanage/queryAplCodes4ChangeMonth?changeMonth=' + changeMonth,
				method : 'GET'
			}),
			reader: new Ext.data.JsonReader({}, ['aplCode'])
		});
		
		aplCodeStore.load();
		aplCodeStore.on('load', function(){
			if(aplCodeStore.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '没有数据可导出!',
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.INFO
				});
				return;
			}
			//重新初始化数据源
			toBeSelectedStore.removeAll();
			//清空已选
			selectedStore.removeAll();
			aplCodeStore.each(function(item){
				selectedStore.add(item);
			});
		
			var isForm = new Ext.form.FormPanel({
				autoWidth : true,
				layout : 'form',
				animCollapse : true,
				frame : true,
				bodyStyle: 'padding:10px;',
				items:[{
	   		 		xtype: 'itemselector',
	    			name: 'aplCodes',
	    			id : 'AppChangeTemplateIndexItemSelector',
	    			fieldLabel: '选择要导出的系统代码',
	    			imagePath: '${ctx}/static/scripts/extjs/examples/ux/images',
	    			multiselects: [{
	        			width: 220,
	        			height: 180,
	        			legend:'待选系统',
	        			store: toBeSelectedStore,
	                    displayField: 'aplCode',
	                    valueField : 'aplCode'
	    			}, {
	       				width: 220,
	        			height: 180,
	        			legend:'已选系统',
	        			store: selectedStore,
	                    displayField: 'aplCode',
	                    valueField : 'aplCode',
	        			tbar:[{
	            			text: '清除',
	            			handler:function(){
	                			isForm.getForm().findField('aplCodes').reset();
	            			}
	        			}]
	    			}]
				}],
				buttonAlign:'right',
				buttons: [{
	    			text: '确定',
	    			handler: function(){
	        			if(isForm.getForm().isValid()){
	        				var toStoreCount = Ext.getCmp('AppChangeTemplateIndexItemSelector').toStore.getCount();
	        				if(toStoreCount == 0){
	        					Ext.Msg.show({
	        						title : '<fmt:message key="message.title"/>',
	        						msg : '请至少选择1条数据!',
	        						buttons : Ext.Msg.OK,
	        						icon : Ext.MessageBox.WARNING
	        					});
	        					return;
	        				}
	        				
	        				var aplCodes = isForm.getForm().findField('aplCodes').getValue();
	        				exportCallWin.close();
	        				
	        				window.location = '${ctx}/${managePath}/appchangetemplate/excel.xls?aplCodes=' + aplCodes + '&changeMonth=' + changeMonth;
	        			}
	    			}
				}, {
	    			text: '取消',
	    			handler: function(){
	        			exportCallWin.close();
	    			}
				}]
			});
			
			var exportCallWin = new Ext.Window({
				title  :'设置导出条件',
				animCollapse:true,
				modal : true,
				width : 620,
				collapsible : false,
				resizable : true,
				draggable : true,
				//closable : false,
				closeAction :'close',
				items:[isForm]
			});
			exportCallWin.show();
		});
	}
});

Ext.getCmp("MgrAppChangeTemplateIndex").add(new AppChangeTemplateExport());
Ext.getCmp("MgrAppChangeTemplateIndex").doLayout();
</script>

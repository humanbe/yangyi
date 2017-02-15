<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize=100;
var typicalCapaAnaSysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/capearlywarningtime/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['sysId','sysName'])
});
//容量风险分类
var typicalCapaAnaRiskType = new Ext.data.ArrayStore({
    fields: ['valueField', 'displayField'],
    data : [['1', '业务容量'],
            	['2', '应用容量'],
            	['3', '资源容量']
            ]
});
//定义列表
TypicalCapaAnaIndexList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	
	constructor : function(cfg) {// 构造方法
		
		typicalCapaAnaSysIdsStore.load();

		Ext.apply(this, cfg);

		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/typicalcapaana/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['sysseqnum', 'appSysCd', 'errorTime', 'riskType', 'workorderSubject', 'caseCause','handleMethod','optimizePlan','caseAna', 'sysName'],
			remoteSort : true,
			sortInfo : {
				field : 'sysseqnum',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			}
		});

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'TypicalCapaAnaIndexListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : false
			},
			store : this.gridStore,
			sm : csm,
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="property.sysseqnum" />', dataIndex : 'sysseqnum', sortable : true, width : 150},
				{header : '<fmt:message key="property.appSysCd" />', dataIndex : 'appSysCd', sortable : true, width : 100},
				{header : '<fmt:message key="property.sysName" />', dataIndex : 'sysName', sortable : true, width : 150},
				{header : '<fmt:message key="property.errorTime" />', dataIndex : 'errorTime', sortable : true, width : 120},
				{header : '<fmt:message key="property.riskType" />', dataIndex : 'riskType', sortable : true ,renderer : this.changeRiskFlag},
				{header : '<fmt:message key="property.workorderSubject" />', dataIndex : 'workorderSubject', sortable : true, width : 200},
				{header : '<fmt:message key="property.caseCause" />', dataIndex : 'caseCause', sortable : true, width : 200},
				{header : '<fmt:message key="property.handleMethod" />', dataIndex : 'handleMethod', sortable : true, width : 200},
				{header : '<fmt:message key="property.optimizePlan" />', dataIndex : 'optimizePlan', sortable : true, width : 200},
				{header : '<fmt:message key="property.caseAna" />', dataIndex : 'caseAna', sortable : true, width : 200}
	  		],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler : this.doExportXLS
				} ]
			}),
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'TypicalCapaAnaIndexFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 80,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 300,
			minSize : 300,
			maxSize : 300,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appSysCd" />',
					id : 'TypicalCapaAnaIndexAplCode',
					displayField : 'sysName',
					valueField : 'sysId',
					hiddenName : 'appSysCd',
					typeAhead : true,
					forceSelection  : true,
					store : typicalCapaAnaSysIdsStore,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true,
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
					fieldLabel : '<fmt:message key="property.sysseqnum" />',
					name : 'sysseqnum'
				},
				{
				    xtype : 'datefield',
					fieldLabel : '<fmt:message key="property.errorTime" />',
					name : 'errorTime',
					format : 'Ymd'
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.riskType" />',
					id : 'TypicalCapaAnaIndexRiskType',
					hiddenName : 'riskType',
					displayField : 'displayField',
					valueField : 'valueField',
					typeAhead : true,
					forceSelection  : true,
					store : typicalCapaAnaRiskType,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true
				}
			],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			} ]
		});
		// 设置基类属性		TypicalCapaAnaIndexList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	changeRiskFlag : function(value, metadata, record, rowIndex, colIndex, store) {
		var rtnVal='';
		switch(value){
			case '1': 
				rtnVal = '业务容量';
				break;
			case '2':
				rtnVal = '应用容量';
				break;
			case '3':
				rtnVal = '资源容量';
				break;
			default:
				break;
		}
		return rtnVal;
	},
	// 查询事件
	doFind : function() {
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('add_TypicalCapaAna', 
				'<fmt:message key="button.create" /><fmt:message key="property.typicalcapaana" />', 
				'${ctx}/${managePath}/typicalcapaana/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
				sysseqnum : record.get('sysseqnum')
		};
		var tab = Ext.getCmp("view_TypicalCapaAnaView");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.typicalcapaana" />');
		}
		app.loadTab('view_TypicalCapaAnaView', 
				'<fmt:message key="button.view" /><fmt:message key="property.typicalcapaana" />', 
				'${ctx}/${managePath}/typicalcapaana/view', params);
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
					sysseqnum : record.get('sysseqnum')
			};
			app.loadTab('edit_TypicalCapaAna', '<fmt:message key="button.edit" /><fmt:message key="property.typicalcapaana" />', '${ctx}/${managePath}/typicalcapaana/edit', params);
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 删除事件
	doDelete : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel().getSelections();
			var sysseqnums = new Array();
			for ( var i = 0; i < records.length; i++) {
				sysseqnums[i] = records[i].get('sysseqnum');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.delete" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${managePath}/typicalcapaana/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								sysseqnums : sysseqnums,
								_method : 'delete'
							}
						});

					}
				}
			});
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 删除成功回调方法
	deleteSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();// 重新加载数据源
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.delete.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${managePath}/typicalcapaana/excel.xls?' + encodeURI(this.form.getForm().getValues(true));
	},
	doImport : function(){
		var dialog = new Ext.ux.UploadDialog.Dialog({
			url : '${ctx}/${managePath}/common/upload',
			title: '<fmt:message key="button.upload"/>' ,   
			post_var_name:'uploadFiles',//这里是自己定义的，默认的名字叫file  
			width : 450,
			height : 300,
			minWidth : 450,
			minHeight : 300,
			draggable : true,
			resizable : true,
			//autoCreate: true,
			constraintoviewport: true,
			permitted_extensions:['dat', 'DAT'],
			modal: true,
			reset_on_hide: false,
			allow_close_on_upload: false,    //关闭上传窗口是否仍然上传文件   
			upload_autostart: false     //是否自动上传文件   

		});    
		dialog.show(); 
		dialog.on( 'uploadsuccess' , onUploadCapEarlyWarningTimeSuccess); //定义上传成功回调函数
		//dialog.on( 'uploadcomplete' , onUploadComplete); //定义上传完成回调函数
	},
	doExport : function(){
		window.location = '${ctx}/${managePath}/typicalcapaana/export.xls';
	},
	//保存成功回调
	exportSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO
		});
	},
	// 保存失败回调
	exportFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

//文件上传成功后的回调函数
onUploadCapEarlyWarningTimeSuccess = function(dialog, filename, resp_data, record){
	dialog.hide();
	app.mask.show();
	Ext.Ajax.request({
		url : "${ctx}/${managePath}/typicalcapaana/importTypicalCapaAnasByFile",
		params : {
			filePath : resp_data.filePath
		},
		method : "POST",
		scope : this,
		timeout : 99999999,
		success : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.import.failed" /><fmt:message key="error.code" />:<br>' + error,
					minWidth : 300,
					width : 450,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.import.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					fn : function(){
						Ext.getCmp('TypicalCapaAnaIndexListGridPanel').store.load();
					}
				});
			}
		},
		failure : function(response) {
			app.mask.hide();
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});   
};
	var typicalCapaAnaIndexList = new TypicalCapaAnaIndexList();
</script>
<script type="text/javascript">
typicalCapaAnaIndexList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : typicalCapaAnaIndexList,
	handler : typicalCapaAnaIndexList.doCreate
	},'-');
</script>
<script type="text/javascript">
typicalCapaAnaIndexList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : typicalCapaAnaIndexList,
	handler : typicalCapaAnaIndexList.doEdit
	},'-');
</script>
<script type="text/javascript">
typicalCapaAnaIndexList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : typicalCapaAnaIndexList,
	handler : typicalCapaAnaIndexList.doDelete
	},'-');
</script>
<script type="text/javascript">
typicalCapaAnaIndexList.grid.getTopToolbar().add({
	iconCls : 'button-import',
	text : '<fmt:message key="button.import" />',
	scope : typicalCapaAnaIndexList,
	handler : typicalCapaAnaIndexList.doImport
	},'-');
</script>
<script type="text/javascript">
typicalCapaAnaIndexList.grid.getTopToolbar().add({
	iconCls : 'button-export',
	text : '<fmt:message key="button.export" />',
	scope : typicalCapaAnaIndexList,
	handler : typicalCapaAnaIndexList.doExport
	},'-');
</script>
<script type="text/javascript">
Ext.getCmp("MgrTypicalCapaAnaIndex").add(typicalCapaAnaIndexList);
Ext.getCmp("MgrTypicalCapaAnaIndex").doLayout();
</script>

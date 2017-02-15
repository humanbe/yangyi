<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize = 100;
//获取系统代码列表数据
var aplAnalyzeAplCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});
//定义列表
AplAnalyzeList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		
		//加载系统代码数据
		aplAnalyzeAplCodeStore.load();
	
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/aplanalyze/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
				'aplCode',
				'transDate',
				'anaItem',
				'exeAnaDesc',
				'status',
				'anaUser',
				'revUser',
				'endDate',
				'filePath'
			],
			remoteSort : true,
			sortInfo : {
				field : 'aplCode,transDate,anaItem',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			}
		});

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'AplAnalyzeListGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			viewConfig : {
				forceFit : false,
				getRowClass : function(record, rowIndex, rowParams, store){   
					if((rowIndex + 1) % 2 === 0){   
						return 'x-gridServe-row-alt';
					}   
				}
			},
			// 列定义			columns : [ new Ext.grid.RowNumberer(), csm, 
			    {
					header : '应用系统编号',
					dataIndex : 'aplCode',
					sortable : true,
					width : 100
				},
				{
					header : '交易日期',
					dataIndex : 'transDate',
					sortable : true,
					width : 100
				},
				{
					header : '分析科目',
					dataIndex : 'anaItem',
					sortable : true,
					width : 200
				},
				{
					header : '运行情况分析描述',
					dataIndex : 'exeAnaDesc',
					sortable : true,
					width : 250
				},
				{
					header : '状态',
					dataIndex : 'status',
					sortable : true,
					width : 60,
					renderer : this.changeValue
				},
				{
					header : '分析人',
					dataIndex : 'anaUser',
					sortable : true,
					width : 80
				},
				{
					header : '审核人',
					dataIndex : 'revUser',
					sortable : true,
					width : 80
				},
				{
					header : '完成日期',
					dataIndex : 'endDate',
					sortable : true,
					width : 100
				},
				{
					header : '附件文件路径名',
					dataIndex : 'filePath',
					sortable : true,
					width : 100
				}
	  		],
	  		
	  	// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ,
					{
						iconCls : 'button-add',
						text : '<fmt:message key="button.create" />',
						scope : this,
						handler : this.doCreate
					},'-',
					{
						iconCls : 'button-edit',
						text : '<fmt:message key="button.edit" />',
						scope : this,
						handler : this.doEdit
					},'-',
					{
						iconCls : 'button-delete',
						text : '<fmt:message key="button.delete" />',
						scope : this,
						handler : this.doDelete
					},'-']
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize  : pageSize,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler : this.doExportXLS
				} ]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			id : 'AplAnalyzeFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 105,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [ 
				{
				    xtype : 'combo',
					fieldLabel : '应用系统编号',    //'<fmt:message key="property.appsyscd" />',
					hiddenName : 'aplCode',
					tabIndex : this.tabIndex++,
					displayField : 'displayField',
					valueField : 'valueField',
					typeAhead : true,
					forceSelection  : true,
					store : aplAnalyzeAplCodeStore,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : false
				},
				{
				    xtype : 'datefield',
					fieldLabel : '交易日期',
					name : 'transDate',
					format : 'Ymd',
					editable : false
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
		// 设置基类属性		AplAnalyzeList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	changeValue : function(value) {
		switch(value){
			case '0' : return  '正常';break;    //'<fmt:message key="common.no" />'; break;
			case '1' : return '<span style="color:red;">' + '异常' + '</span>';break;     //'<fmt:message key="common.yes" />';break;
			default : return value;
		}
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
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
			aplCode : record.get('aplCode'),
			transDate : record.get('transDate'),
			anaItem : encodeURIComponent(record.get('anaItem'))
		};
		//如果标签页存在,重载页面
		var tab = Ext.getCmp("view_AplAnalyze");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" />' + record.data.aplCode +'系统(' + record.data.anaItem + ")运行分析");
		}
		app.loadTab('view_AplAnalyze', 
				'<fmt:message key="button.view" />' + record.data.aplCode +'系统(' + record.data.anaItem + ")运行分析", 
				'${ctx}/${managePath}/aplanalyze/view', 
				params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('add_AplAnalyze', 
				'<fmt:message key="button.create" />应用系统运行科目分析', 
				'${ctx}/${managePath}/aplanalyze/create');
	},
	// 编辑事件
    doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var params = {
				aplCode : record.get('aplCode'),
				transDate : record.get('transDate'),
				anaItem : encodeURIComponent(record.get('anaItem'))
			};
			//如果标签页存在,重载页面
			var tab = Ext.getCmp("edit_AplAnalyze");
			if(tab){
				tab.setTitle('<fmt:message key="button.edit" />' + record.data.aplCode +'系统(' + record.data.anaItem + ")运行分析");
			}
			app.loadTab('edit_AplAnalyze', 
					'<fmt:message key="button.edit" />' + record.data.aplCode +'系统(' + record.data.anaItem + ")运行分析", 
					'${ctx}/${managePath}/aplanalyze/edit', 
					params);
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
			var aplCodes = new Array();
			var transDates = new Array();
			var anaItems = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i] = records[i].get('aplCode'),
				transDates[i] = records[i].get('transDate'),
				anaItems[i] = records[i].get('anaItem')
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
							url : '${ctx}/${managePath}/aplanalyze/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodes : aplCodes,
								transDates : transDates,
								anaItems : anaItems,
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
		window.location = '${ctx}/${managePath}/aplanalyze/excel.xls?' + encodeURI(this.form.getForm().getValues(true));
	}
});
var aplAnalyzeList = new AplAnalyzeList();
Ext.getCmp("APL_ANALYZE").add(aplAnalyzeList);
Ext.getCmp("APL_ANALYZE").doLayout();
</script>

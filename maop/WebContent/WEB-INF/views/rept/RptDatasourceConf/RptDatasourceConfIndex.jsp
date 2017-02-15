<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var datasourceStore;
//定义列表
DataSourceForm = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止

		Ext.getDoc().on('keydown',function(e) {
							if (e.getKey() == 8
									&& e.getTarget().type == 'text'
									&& !e.getTarget().readOnly) {

							} else if (e.getKey() == 8
									&& e.getTarget().type == 'textarea'
									&& !e.getTarget().readOnly) {

							} else if (e.getKey() == 8) {
								e.preventDefault();
							}
						});

		
		//获取系统代码列表数据
		this.sysIdsStore = new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
				method : 'GET'
			}),
			reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
		});
		this.sysIdsStore.load();
		
		//数据字典
		datasourceStore= new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/DATASOURCE_CONF/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		datasourceStore.load();
		
		this.sourceStore = new Ext.data.Store(
				{
					proxy: new Ext.data.HttpProxy({
						url : '${ctx}/${managePath}/rptdatasourceconf/getDatasource', 
						method: 'POST'
					}),
					reader: new Ext.data.JsonReader({}, ['value','name'])
				});
				this.sourceStore.load();
				this.sourceStore.on('beforeload', function(loader,node) {
					//使用查询条件系统代码文本框时用
					loader.baseParams.dataType = Ext.getCmp("dataTypeId").getValue();
				}, this);
				
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${managePath}/rptdatasourceconf/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'aplCode','dataType','datasource'],
			remoteSort : true,
			sortInfo : {
				field : 'field_type_direction',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//加载数据源
		this.gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			id : 'DataSourceGridPanelId',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), csm,      
				{header : '应用系统编号', dataIndex : 'aplCode', sortable : true},
				{header : '采集数据类型', dataIndex : 'dataType', renderer:this.dataTypeStore , sortable : true},
				{header : '数据源地址', dataIndex : 'datasource', sortable : true}
	  		
	  		],
	  		
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-' ]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView

			}
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 110,
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
					fieldLabel : '应用系统编号',
					store : this.sysIdsStore,
					hiddenName : 'aplCode',
					displayField : 'displayField',
					valueField : 'valueField',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,	
				    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						 beforequery : function(e){
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
					store : datasourceStore,
					id : 'dataTypeId',
					fieldLabel : '采集数据类型',
					name : 'dataType',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'dataType',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo,record,index) {
							this.sourceStore.reload();
						}
					}
				},
				{
					xtype : 'combo',
					store : this.sourceStore,
					fieldLabel : '数据源地址',
					name : 'datasource',
					valueField : 'value',
					displayField : 'value',
					hiddenName : 'datasource',
					mode : 'local',
					triggerAction : 'all',
					//forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
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

		// 设置基类属性
		DataSourceForm.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
 	dataTypeStore : function(value) {
		 var index = datasourceStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return datasourceStore.getAt(index).get('name');
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
	// 新建事件
	doCreate : function() {
		app.loadTab('DATASOURCE_CREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${managePath}/rptdatasourceconf/create');
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel()
				.getSelected();
		var params = {
				aplCode : record.get("aplCode"),
				dataType : record.get("dataType")
		};
		app.loadTab('DATASOURCE_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
				'${ctx}/${managePath}/rptdatasourceconf/view',params);
	},
	// 修改事件
	doEdit : function() {
		
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel()
					.getSelected();
			var params = {
					aplCode : record.get("aplCode"),
					dataType : record.get("dataType")
			};
			app.loadTab(
							'DATASOURCE_EDIT',
							'<fmt:message key="button.edit" />',
							'${ctx}/${managePath}/rptdatasourceconf/edit',
							params);
		} else {
			Ext.Msg.show({
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
			var records = this.grid.getSelectionModel()
					.getSelections();
			
			var aplCodes = new Array();
			var dataTypes = new Array();
			for ( var i = 0; i < records.length; i++) {
				aplCodes[i]= records[i].get("aplCode");
				dataTypes[i]= records[i].get("dataType");
			}

			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.confirm.to.delete" />',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								app.mask.show();
								Ext.Ajax.request({
											url : '${ctx}/${managePath}/rptdatasourceconf/delete',
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												aplCodes : aplCodes,
												dataTypes : dataTypes,
												_method : 'delete'
											}
										});
							}
						}
					});
		} else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.at.least" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}
	},

	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg
				.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.delete.failed" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
	},
	// 删除成功回调方法
	deleteSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:'
								+ error,
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();// 重新加载数据源

			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.successful" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
		}
	}
	
	
	
	
});

var DataSourceForm = new DataSourceForm();
</script>

<%-- <sec:authorize access="hasRole('FIELDTYPE_CREATE')"> --%>
<script type="text/javascript">
DataSourceForm.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : DataSourceForm,
	handler : DataSourceForm.doCreate
	},'-');
</script>
<%-- </sec:authorize> --%>

<%--  <sec:authorize access="hasRole('FIELDTYPE_EDIT')"> --%>
	<script type="text/javascript">
	DataSourceForm.grid.getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : DataSourceForm,
		handler : DataSourceForm.doEdit
	}, '-');
</script>
<%-- </sec:authorize>  --%>



<%-- <sec:authorize access="hasRole('FIELDTYPE_DELETE')"> --%>
	<script type="text/javascript">
	DataSourceForm.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : DataSourceForm,
		handler : DataSourceForm.doDelete
	}, '-');
</script>
<%-- </sec:authorize> --%>


<script type="text/javascript">
Ext.getCmp("REP_DATARESOURCE_CONF").add(DataSourceForm);
Ext.getCmp("REP_DATARESOURCE_CONF").doLayout();
</script>

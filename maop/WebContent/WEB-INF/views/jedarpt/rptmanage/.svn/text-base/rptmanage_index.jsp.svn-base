<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var rptTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/REPORT_TYPES/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/appjobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});


//定义列表
RptInfoList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件		csm = new Ext.grid.CheckboxSelectionModel({
			//singleSelect : true , //一次只能选中一条记录		});
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
		
		rptTypeStore.load();
		userStore.load();
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jedarpt/getJedaRptList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'report_code',
						'report_type',
						'report_name',
						'report_desc',
						'report_sql',
						'creator',
						'created',
						'modifier',
						'modified'
					],
			remoteSort : true,
			sortInfo : {
				field : 'report_code',
				dir : 'DESC'
			},
			baseParams : {
				start : 0,
				limit : 20
			}
		});
		// 加载列表数据
		this.gridStore.load();
		
		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel({
			title : '<fmt:message key="title.list" />',
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm, {
				//header : '<fmt:message key="job_code" />',
				header : '编号',
				dataIndex : 'report_code',
				sortable : true,
				hidden : true,  //隐藏该列
				hideable : false //不显示在排序列表中
			},{
				header : '报表名称',
				dataIndex : 'report_name',
				width : 150,
				scope : this,
				sortable : true
			},{
				header : '报表描述',
				dataIndex : 'report_desc',
				width : 200,
				sortable : true,
				hidden : false 
			},{
				header : '报表分类',
				dataIndex : 'report_type',
				renderer : this.rptTypeValue,
				scope : this,
				sortable : true
			},{
				header : '创建人',
				dataIndex : 'creator',
				renderer : this.userStoreValue,
				scope : this,
				sortable : true
			},{
				header : '创建时间',
				dataIndex : 'created',
				scope : this,
				sortable : true
			},{
				header : '修改人',
				dataIndex : 'modifier',
				renderer : this.userStoreValue,
				scope : this,
				sortable : true
			},{
				header : '修改时间',
				dataIndex : 'modified',
				scope : this,
				sortable : true
			}],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				rowdblclick : this.doView
			}
		});
		
		// 实例化查询表单		this.form = new Ext.FormPanel( {
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 80,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 250,
			minSize : 200,
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
					fieldLabel : '报表分类',
					store : rptTypeStore,
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'report_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '报表名称',
					name : 'report_name',
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textarea',
					fieldLabel : '报表描述',
					name : 'report_desc',
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				}
			],
			// 定义查询表单按钮
			buttons : [{
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doReset
			}]
		});

		// 设置基类属性		RptInfoList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	rptTypeValue : function(value) {
		var index = rptTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return rptTypeStore.getAt(index).get('name');
		}
	},
	
	userStoreValue : function(value) {
		var index = userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return userStore.getAt(index).get('name');
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
				reportId : record.get('report_code')
		};
		app.loadTab('JEDA_REPORT_VIEW', '查看报表', '${ctx}/${appPath}/jedarpt/view', params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('JEDA_REPORT_CREATE', '定制新报表', '${ctx}/${appPath}/jedarpt/create');
	},
	// 编辑事件
	doEdit : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() == 1) {
			var record = grid.getSelectionModel().getSelected();
			var params = {
				reportId : record.get('report_code')
			};
			app.loadTab('JEDA_REPORT_EDIT', '修改报表', '${ctx}/${appPath}/jedarpt/edit', params);
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
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() > 0) {
			var records = grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('report_code');
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
							scope : this,
							timeout : 7200000, //2小时
							url : '${ctx}/${appPath}/jedarpt/delete',
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								reportIds : ids,
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
	// 删除成功回调
	deleteSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	// 删除失败回调
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.delete.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
	
});
var rptInfoList = new RptInfoList();
</script>

<sec:authorize access="hasRole('JEDA_RPT_CREATE')">
<script type="text/javascript">
rptInfoList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : rptInfoList,
	handler : rptInfoList.doCreate
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('JEDA_RPT_EDIT')">
<script type="text/javascript">
rptInfoList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : rptInfoList,
	handler : rptInfoList.doEdit
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('JEDA_RPT_DELETE')">
<script type="text/javascript">
rptInfoList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : rptInfoList ,
	handler : rptInfoList.doDelete 
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
	Ext.getCmp("JEDA_REPORT_MANAGE").add(rptInfoList);
	Ext.getCmp("JEDA_REPORT_MANAGE").doLayout();
</script>

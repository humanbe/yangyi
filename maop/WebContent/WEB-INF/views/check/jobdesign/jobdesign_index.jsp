<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var toolStatusStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/JOB_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var checkTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var authorizeLeverTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_AUTHORIZE_LEVEL_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var fieldTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_FIELD_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var frontlineFlagStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/JOB_FRONTLINE_FLAG/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/jobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});

var appsysStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
});

//定义列表
JobInfoList = Ext.extend(Ext.Panel, {
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
		
		toolStatusStore.load();
		checkTypeStore.load();
		authorizeLeverTypeStore.load();
		fieldTypeStore.load();
		frontlineFlagStore.load();
		userStore.load();
		appsysStore.load();
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getJobInfoList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'appsys_code',
						'job_code', 
						'check_type',
						'authorize_lever_type',
						'field_type',
						'job_path',
						'job_name',
						'job_desc',
						'tool_status',
						'frontline_flag',
						'authorize_flag',
						'delete_flag',
						'tool_creator'
					],
			remoteSort : true,
			sortInfo : {
				field : 'appsys_code',
				direction : 'ASC'
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
				header : '<fmt:message key="job_code" />',
				dataIndex : 'job_code',
				sortable : true,
				hidden : true,  //隐藏该列
				hideable : false //不显示在排序列表中
			},{
				header : '<fmt:message key="job.appsys_code" />',
				dataIndex : 'appsys_code',
				renderer : this.appsysStoreValue,
				scope : this,
				hidden : true,
				sortable : true
			},{
				header : '<fmt:message key="job" /><fmt:message key="job.name" />',
				dataIndex : 'job_name',
				sortable : true,
				hidden : false 
			},{
				header : '<fmt:message key="job.desc" />',
				dataIndex : 'job_desc',
				sortable : true,
				hidden : false 
			},{
				header : '<fmt:message key="job.status" />',
				dataIndex : 'tool_status',
				renderer : this.toolStatusValue,
				scope : this,
				hidden : true,
				sortable : true
			},{
				header : '<fmt:message key="job.type" />',
				dataIndex : 'check_type',
				width : 60,
				renderer : this.checkTypeValue,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="job.authorize_lever_type" />', //巡检方式
				dataIndex : 'authorize_lever_type',
				width : 60,
				renderer : this.authorizeLeverTypeValue,
				scope : this,
				hidden : true,
				sortable : true
			},{
				header : '<fmt:message key="job.field_type" />',
				dataIndex : 'field_type',
				width : 70,
				renderer : this.fieldTypeValue,
				scope : this,
				sortable : true
			},{
				header : '<fmt:message key="job.frontline_flag" />',
				dataIndex : 'frontline_flag',
				renderer : this.frontlineFlagValue,
				scope : this,
				hidden : true ,
				sortable : true
			},{
				header : '<fmt:message key="job.creator" />',
				dataIndex : 'tool_creator',
				width : 45,
				renderer : this.userStoreValue,
				scope : this,
				sortable : true
			}],
			// 定义按钮工具条			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler : function() {
						window.location = '${ctx}/${appPath}/jobdesign/excel.xls?' + encodeURI(this.form.getForm().getValues(true));
					}
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
			/* id : 'TaskConfFindFormPanel', */
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
			items : [/* {
					xtype : 'combo',
					store : appsysStore,
					fieldLabel : '<fmt:message key="job.appsys_code" />',
					name : 'appsys_code' ,
					valueField : 'appsysCode',
					displayField : 'appsysName',
					hiddenName : 'appsys_code',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++,
					//emptyText : '请选择系统代码...',
					listeners : {
						scope : this ,
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
				}, {
					xtype : 'combo',
					store : authorizeLeverTypeStore,
					fieldLabel : '<fmt:message key="job.authorize_lever_type" />', //巡检方式：常规巡检
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'authorize_lever_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
				},*/{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job" /><fmt:message key="job.name" />',
					name : 'job_name',
					maxLength : 30 ,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : checkTypeStore,
					fieldLabel : '<fmt:message key="job.type" />',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'check_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : fieldTypeStore,
					fieldLabel : '<fmt:message key="job.field_type" />',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'field_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
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

		// 设置基类属性		JobInfoList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	toolStatusValue : function(value) {
		var index = toolStatusStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return toolStatusStore.getAt(index).get('name');
		}
	},
	checkTypeValue : function(value) {
		var index = checkTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return checkTypeStore.getAt(index).get('name');
		}
	},
	authorizeLeverTypeValue : function(value) {
		var index = authorizeLeverTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return authorizeLeverTypeStore.getAt(index).get('name');
		}
	},
	fieldTypeValue : function(value) {
		var index = fieldTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return fieldTypeStore.getAt(index).get('name');
		}
	},
	frontlineFlagValue : function(value) {
		var index = frontlineFlagStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return frontlineFlagStore.getAt(index).get('name');
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
	appsysStoreValue : function(value) {
		var index = appsysStore.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return appsysStore.getAt(index).get('appsysName');
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
			jobid : record.get('job_code')
		};
		app.loadTab('JOB_DESIGN_VIEW', '<fmt:message key="button.view" /><fmt:message key="sysjob" />', '${ctx}/${appPath}/jobdesign/view', params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('JOB_DESIGN_CREATE', '<fmt:message key="button.create" /><fmt:message key="sysjob" />', '${ctx}/${appPath}/jobdesign/create');
	},
	// 编辑事件
	doEdit : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() == 1) {
			var record = grid.getSelectionModel().getSelected();
			var params = {
				jobid : record.get('job_code')
			};
			app.loadTab('JOB_DESIGN_EDIT', '<fmt:message key="button.edit" /><fmt:message key="sysjob" />', '${ctx}/${appPath}/jobdesign/edit', params);
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
				ids[i] = records[i].get('job_code');
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
							url : '${ctx}/${appPath}/jobdesign/delete',
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								jobids : ids,
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
var jobInfoList = new JobInfoList();
</script>

<sec:authorize access="hasRole('CHECK_CREATE')">
<script type="text/javascript">
jobInfoList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : jobInfoList,
	handler : jobInfoList.doCreate
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('CHECK_EDIT')">
<script type="text/javascript">
jobInfoList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : jobInfoList,
	handler : jobInfoList.doEdit
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('CHECK_DELETE')">
<script type="text/javascript">
jobInfoList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : jobInfoList,
	handler : jobInfoList.doDelete
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
	Ext.getCmp("JOB_DESIGN_INDEX").add(jobInfoList);
	Ext.getCmp("JOB_DESIGN_INDEX").doLayout();
</script>

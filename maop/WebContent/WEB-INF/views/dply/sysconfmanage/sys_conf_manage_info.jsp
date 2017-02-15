<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">




var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
	
});

//定义列表
SysconfmanageList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	sysConfTypeStore : null,
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		this.userStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/jobdesign/getUserIdNames',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['username','name'])
		});
		this.userStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件      //数据字典
		this.sysConfTypeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/SYS_CONF_MANAGE_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
							});
		this.sysConfTypeStore.load();
		
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/sysconfmanage/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'sys_conf_id','sys_conf_code','sys_conf_name','sys_conf_value',
			           'sys_conf_type','sys_conf_desc','creator','modifier',
			           'created_time','modifiled_time'],
			remoteSort : true,
			sortInfo : {
				field : 'sys_conf_id',
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
			id: 'sysconfmanage_index',
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
				{header : '系统配置ID', dataIndex : 'sys_conf_id',scope : this,sortable : true,hidden:true},
				{header : '系统配置编码', dataIndex : 'sys_conf_code', sortable : true},
				{header : '系统配置名称', dataIndex : 'sys_conf_name', sortable : true},
				{header : '系统配置值', dataIndex : 'sys_conf_value', sortable : true,scope : this},
				{header : '系统配置类型', dataIndex : 'sys_conf_type', sortable : true ,renderer :this.sysConfTypeone ,scope : this},
				{header : '系统配置描述', dataIndex : 'sys_conf_desc', sortable : true },
				{header : '创建人', dataIndex : 'creator', sortable : true },
				{header : '创建时间', dataIndex : 'created_time', sortable : true },
				{header : '修改人', dataIndex : 'modifier', sortable : true },
				{header : '修改时间', dataIndex : 'modifiled_time', sortable : true }
				
	  		
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
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				} ]
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
					fieldLabel : '系统配置类型',
					store : this.sysConfTypeStore,
					displayField : 'name',
					valueField : 'value',
					name : 'sys_conf_type',
					hiddenName:'sys_conf_type',
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
				    xtype : 'textfield',
					fieldLabel : '系统配置编码',
					name : 'sys_conf_code'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置名称',
					name : 'sys_conf_name'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置值',
					name : 'sys_conf_value'
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
		SysconfmanageList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	userStoreone : function(value) {

		var index = this.userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return this.userStore.getAt(index).get('name');
		}
	},
	sysConfTypeone : function(value) {

		var index = this.sysConfTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return this.sysConfTypeStore.getAt(index).get('name');
		}
	},
	
	
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/sysconfmanage/sysconfmanageexcel.xls';
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '没有数据,不可导出',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
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
		app.loadTab('SYS_CONF_MANAGE_CREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${managePath}/sysconfmanage/create');

	},
	
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel()
				.getSelected();
		var params = {
				sys_conf_id :record.data.sys_conf_id
		};
		app.loadTab('SYS_CONF_MANAGE_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
				'${ctx}/${managePath}/sysconfmanage/view',params);
	},
	// 修改事件
	doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel()
					.getSelected();
			var params = {
					sys_conf_id :record.data.sys_conf_id
			};
			app.loadTab(
							'SYS_CONF_MANAGE_EDIT',
							'<fmt:message key="button.edit" />',
							'${ctx}/${managePath}/sysconfmanage/edit',
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
			
			var sys_conf_ids=new Array();
			for ( var i = 0; i < records.length; i++) {
				sys_conf_ids[i]= records[i].data.sys_conf_id;
			}

			Ext.Msg
					.show({
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
											url : '${ctx}/${managePath}/sysconfmanage/delete',
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												sys_conf_ids : sys_conf_ids,
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

var sysconfmanageList = new SysconfmanageList();
</script>

<sec:authorize access="hasRole('SYS_CONF_MANAGE_CREATE')">
<script type="text/javascript">
sysconfmanageList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : sysconfmanageList,
	handler : sysconfmanageList.doCreate
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYS_CONF_MANAGE_EDIT')">
	<script type="text/javascript">
	sysconfmanageList.grid.getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : sysconfmanageList,
		handler : sysconfmanageList.doEdit
	}, '-');
</script>
</sec:authorize> 



<sec:authorize access="hasRole('SYS_CONF_MANAGE_DELETE')">
	<script type="text/javascript">
	sysconfmanageList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : sysconfmanageList,
		handler : sysconfmanageList.doDelete
	}, '-');
</script>
</sec:authorize>


<script type="text/javascript">
Ext.getCmp("SYS_CONF_MANAGE_INFO").add(sysconfmanageList);
Ext.getCmp("SYS_CONF_MANAGE_INFO").doLayout();
</script>

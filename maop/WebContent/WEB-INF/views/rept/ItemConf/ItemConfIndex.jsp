<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var getLvl1Store_Index;
var getLvl2Store_Index;
var getLvl3Store_Index;
//授权应用系统
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



//用户
var userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/appjobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});


//定义列表
ItemConfList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件

	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel({});
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
		
		appsysStore.load();
		userStore.load();
		
		//一级分类

		getLvl1Store_Index = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itemconf/getLvl1Store', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['value','name'])
		});
		//二级分类
		getLvl2Store_Index = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itemconf/getLvl2Store', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['value','name'])
		});
		//三级分类
		getLvl3Store_Index = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itemconf/getLvl3Store', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['value','name'])
		});
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/itemconf/getItemConfList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'apl_code',
						'item_cd_app',
						'item_cd_lvl1',
						'item_cd_lvl2',
						'item_cd_lvl1_name',
						'item_cd_lvl2_name',
						'item_app_name',
						'item_app_ststcs_peak_flag',
						'expression',
						'item_creator',
						'item_created',
						'item_modifier',
						'item_modified'
					],
			remoteSort : true,
			sortInfo : {
				field : 'apl_code',
				dir : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 50
			}
		});
		// 加载列表数据
		this.gridStore.load();
		
		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel({
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
				header : '应用系统',
				dataIndex : 'apl_code',
				renderer : this.appsysStoreValue,
				scope : this,
				sortable : true
			},{
				header : '一级分类',
				dataIndex : 'item_cd_lvl1',
				hidden:true,
				scope : this,
				sortable : true
			}
			,{
				header : '一级分类名称',
				dataIndex : 'item_cd_lvl1_name',
				scope : this,
				sortable : true
			},{
				header : '二级分类',
				dataIndex : 'item_cd_lvl2',
				scope : this,
				hidden:true,
				sortable : true
			},{
				header : '二级分类名称',
				dataIndex : 'item_cd_lvl2_name',
				scope : this,
				sortable : true
			},{
				header : '科目编码',
				dataIndex : 'item_cd_app',
				sortable : true
			},{
				header : '科目名称',
				dataIndex : 'item_app_name',
				sortable : true
			},{
				header : '巡检指标是否统计峰值标识',
				dataIndex : 'item_app_ststcs_peak_flag',
				scope : this,
				sortable : true,
				renderer : function(value){
					if(value==0){
						return '否';
					}else{
						return '是';
					}
				}
			},{
				header : '计算式',
				dataIndex : 'expression',
				scope : this,
				//hidden : true,
				sortable : true
			},{
				header : '创建人',
				dataIndex : 'item_creator',
				renderer : this.userStoreValue,
				scope : this,
				hidden : true,
				sortable : true
			},{
				header : '创建时间',
				dataIndex : 'item_created',
				hidden : true,
				scope : this,
				sortable : true
			},{
				header : '修改人',
				dataIndex : 'item_modifier',
				renderer : this.userStoreValue,
				hidden : true,
				scope : this,
				sortable : true
			},{
				header : '修改时间',
				dataIndex : 'item_modified',
				hidden : true,
				scope : this,
				sortable : true
			}],
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true,
				pageSize : 50,
				items : [ '-',{
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				               } ]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				rowdblclick : this.doView
			}
		});
		
		// 实例化查询表单
		this.form = new Ext.FormPanel( {
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
					id: 'apl_code_index',
					store : appsysStore,
					fieldLabel : '应用系统',
					name : 'apl_code' ,
					valueField : 'appsysCode',
					displayField : 'appsysName',
					hiddenName : 'apl_code',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++,
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
					,
					select : function(obj) {
						getLvl1Store_Index.baseParams.aplCode =obj.value;
						getLvl1Store_Index.load();
						Ext.getCmp('item_cd_lvl1_index').setValue("");
						Ext.getCmp('item_cd_lvl2_index').setValue("");
						Ext.getCmp('item_cd_lvl3_index').setValue("");
					}	
				}
			},{
					xtype : 'combo',
					store : getLvl1Store_Index,
					fieldLabel : '一级分类',
					id:'item_cd_lvl1_index',
					name : 'item_cd_lvl1',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'item_cd_lvl1',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false,
					listeners : {
						//编辑完成后处理事件



						select : function(obj) {
							getLvl2Store_Index.baseParams.aplCode=Ext.getCmp('apl_code_index').getValue();
							getLvl2Store_Index.baseParams.item_cd_lvl1 =obj.value;
							getLvl2Store_Index.load();
							Ext.getCmp('item_cd_lvl2_index').setValue("");
							Ext.getCmp('item_cd_lvl3_index').setValue("");
						}
					}
				},
				{
					xtype : 'combo',
					store : getLvl2Store_Index,
					fieldLabel : '二级分类',
					name : 'item_cd_lvl2',
					id: 'item_cd_lvl2_index',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'item_cd_lvl2',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						//编辑完成后处理事件


						select : function(obj) {
							getLvl3Store_Index.baseParams.aplCode=Ext.getCmp('apl_code_index').getValue();
							getLvl3Store_Index.baseParams.item_cd_lvl1 =Ext.getCmp('item_cd_lvl1_index').getValue();
							getLvl3Store_Index.baseParams.item_cd_lvl2 =Ext.getCmp('item_cd_lvl2_index').getValue();
							getLvl3Store_Index.reload();
							Ext.getCmp('item_cd_lvl3_index').setValue("");
							
						}
					}
				},
				{
					xtype : 'combo',
					store : getLvl3Store_Index,
					fieldLabel : '科目',
					name : 'item_cd_app',
					id : 'item_cd_lvl3_index',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'item_cd_app',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
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

		// 设置基类属性
		ItemConfList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	appsysStoreValue : function(value) {
		var index = appsysStore.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return appsysStore.getAt(index).get('appsysName');
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
		var apl_code = record.get('apl_code');
		var item_cd_lvl1 = record.get('item_cd_lvl1');
		var item_cd_lvl2 = record.get('item_cd_lvl2');
		var item_cd_app = record.get('item_cd_app');
		var param = apl_code+','+item_cd_lvl1+','+item_cd_lvl2+','+item_cd_app ;
		var params = {
				keys : encodeURIComponent(param)
		};
		app.loadTab('ITEM_CONF_VIEW', '查看科目', '${ctx}/${managePath}/itemconf/view', params);
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('ITEM_CONF_CREATE', '新建科目', '${ctx}/${managePath}/itemconf/create');
	},
	// 编辑事件
	doEdit : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() == 1) {
			var record = grid.getSelectionModel().getSelected();
			var apl_code = record.get('apl_code');
			var item_cd_lvl1 = record.get('item_cd_lvl1');
			var item_cd_lvl2 = record.get('item_cd_lvl2');
			var item_cd_app = record.get('item_cd_app');
			var param = apl_code+','+item_cd_lvl1+','+item_cd_lvl2+','+item_cd_app ;
			var params = {
					keys : encodeURIComponent(param)
			};
			app.loadTab('ITEM_CONF_EDIT', '修改科目', '${ctx}/${managePath}/itemconf/edit', params);
		} else {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	doExportXLS : function(){
		window.location = '${ctx}/${managePath}/itemconf/downloadxls.file';
	},
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/itemconf/excel.xls';
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
	// 删除事件
	doDelete : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() > 0) {
			var records = grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('apl_code')+'#'+records[i].get('item_cd_lvl1')+'#'+records[i].get('item_cd_lvl2')+'#'+records[i].get('item_cd_app');
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
							timeout : 3600000, //1小时
							url : '${ctx}/${managePath}/itemconf/delete',
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								keys : ids,
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
	},

doImport : function(){
	dialog = new Ext.ux.UploadDialog.Dialog({
		url : '${ctx}/${managePath}/common/upload',
		title: '<fmt:message key="button.upload"/>' ,   
		post_var_name:'uploadItemConfFiles',//这里是自己定义的，默认的名字叫file  
		width : 450,
		height : 300,
		minWidth : 450,
		minHeight : 300,
		draggable : true,
		resizable : true,
		//autoCreate: true,
		constraintoviewport: true,
		permitted_extensions:['xls','xlsx'],
		modal: true,
		reset_on_hide: false,
		allow_close_on_upload: false,    //关闭上传窗口是否仍然上传文件   
		upload_autostart: false     //是否自动上传文件   

	});    
	dialog.show(); 
	dialog.on( 'uploadsuccess' , onUploadItemConfSuccess); //定义上传成功回调函数
}




});

var itemConfList = new ItemConfList();

//文件上传成功后的回调函数
onUploadItemConfSuccess = function(dialog, filename, resp_data, record){
dialog.hide(); 
app.mask.show();
Ext.Ajax.request({
	url : "${ctx}/${managePath}/itemconf/importItemAPP",
	params : {
		filePath : resp_data.filePath
	},
	method : 'POST',
	scope : this,
	timeout : 99999999,
	success : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				width : 400,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.import.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
			itemConfList.grid.store.reload();
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


</script>

<sec:authorize access="hasRole('ITEM_CONF_CREATE')">
<script type="text/javascript">
itemConfList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : itemConfList,
	handler : itemConfList.doCreate
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('ITEM_CONF_EDIT')">
<script type="text/javascript">
itemConfList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : itemConfList,
	handler : itemConfList.doEdit
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('ITEM_CONF_DELETE')">
<script type="text/javascript">
itemConfList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : itemConfList ,
	handler : itemConfList.doDelete 
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('ITEM_CONF_IMPORT')">
<script type="text/javascript">
itemConfList.grid.getTopToolbar().add({
	iconCls : 'button-excel',
	text : '科目信息<fmt:message key="button.import" />',
	scope : itemConfList,
	handler : itemConfList.doImport
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('ITEM_CONF_IMPORT')">
<script type="text/javascript">
itemConfList.grid.getTopToolbar().add({
	iconCls : 'button-download-excel',
	text : '下载导入模板',
	scope : itemConfList,
	handler : itemConfList.doExportXLS
	},'-');
</script>
</sec:authorize>
<script type="text/javascript">
	Ext.getCmp("ITEM_CONF_INDEX").add(itemConfList);
	Ext.getCmp("ITEM_CONF_INDEX").doLayout();
</script>

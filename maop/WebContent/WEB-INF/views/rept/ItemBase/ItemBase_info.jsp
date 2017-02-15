<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//定义列表
ItemBaseList = Ext.extend(Ext.Panel, {
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
	
		this.getItemparentCdStore = new Ext.data.Store(
				{
					proxy: new Ext.data.HttpProxy({
						url : '${ctx}/${managePath}/itembaseconf/getItemparentCd', 
						method: 'POST'
					}),
					reader: new Ext.data.JsonReader({}, ['value','name'])
				});
				this.getItemparentCdStore .load();
		 this.userStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/appjobdesign/getUsers',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['username','name'])
		});
		// 实例化数据列表选择框组件		this.userStore.load();
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${managePath}/itembaseconf/getItemBaseConfList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'item_cd','parent_item_cd',
			           'item_name',
			           'relation_tablename',
			           'item_creator',
						'item_created',
						'item_modifier',
						'item_modified'],
			remoteSort : true,
			sortInfo : {
				field : 'item_cd',
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
			id : 'ItemBaseListGridPanel',
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
			            {
						header : '父科目编码', 
						dataIndex : 'parent_item_cd',
						scope : this,
						sortable : true
					}, {
						header : '科目编码',
						dataIndex : 'item_cd',
						sortable : true
					},{
						header : '科目名称', 
						dataIndex : 'item_name',
						sortable : true
					},{
						header : '关联表名',
						dataIndex : 'relation_tablename',
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
				} 
				
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
				buttons : [ '-',{
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				}  ]
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
						    xtype : 'textfield',
							fieldLabel : '科目编码',
							name : 'item_cd'
						} ,
						{
							xtype : 'combo',
							store : this.getItemparentCdStore ,
							fieldLabel : '父科目编码',
							name : 'parent_item_cd',
							valueField : 'value',
							displayField : 'name',
							hiddenName : 'parent_item_cd',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							editable : false,
							allowBlank : false,
							tabIndex : this.tabIndex++,
							allowBlank : false,
							listeners : {
							}
						},
						{
						    xtype : 'textfield',
							fieldLabel : '科目名称',
							name : 'item_name'
						} ,
						{
						    xtype : 'textfield',
							fieldLabel : '关联表名',
							name : 'relation_tablename'
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
		ItemBaseList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	userStoreValue : function(value) {
		var index = this.userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return this.userStore.getAt(index).get('name');
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
		app.loadTab('ITEMBASE_CREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${managePath}/itembaseconf/create');

	},
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/itembaseconf/excel.xls';
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
	
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel()
				.getSelected();
		var params = {
				item_cd : record.get("item_cd"),
				parent_item_cd : record.get("parent_item_cd")
				
		};
		app.loadTab('ITEMBASE_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
				'${ctx}/${managePath}/itembaseconf/view',params);
	},
	// 修改事件
	doEdit : function() {
		
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel()
					.getSelected();
			var params = {
					item_cd:record.get("item_cd"),
					parent_item_cd : record.get("parent_item_cd")
			};
			app.loadTab(
							'ITEMBASE_EDIT',
							'<fmt:message key="button.edit" />',
							'${ctx}/${managePath}/itembaseconf/edit',
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
			
			var Ids = new Array();
			var parent_Ids= new Array();
			for ( var i = 0; i < records.length; i++) {
				Ids[i]= records[i].get("item_cd");
				parent_Ids[i]= records[i].get("parent_item_cd");
				
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
											url : '${ctx}/${managePath}/itembaseconf/delete',
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												item_cds : Ids,
												parent_Ids :parent_Ids,
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
	},
	doExportXLS : function(){
		window.location = '${ctx}/${managePath}/itembaseconf/downloadxls.file';
	},
	
	 doImport : function(){
		dialog = new Ext.ux.UploadDialog.Dialog({
			url : '${ctx}/${managePath}/common/upload',
			title: '<fmt:message key="button.upload"/>' ,   
			post_var_name:'uploadServerFiles',//这里是自己定义的，默认的名字叫file  
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
		dialog.on( 'uploadsuccess' , onUploadItemBaseSuccess); //定义上传成功回调函数
		//dialog.on( 'uploadcomplete' , onUploadComplete); //定义上传完成回调函数
	}
	
	
	
	
});

var ItemBaseList = new ItemBaseList();

//文件上传成功后的回调函数
onUploadServerSuccess = function(dialog, filename, resp_data, record){
	dialog.hide(); 
	app.mask.show();
	Ext.Ajax.request({
		url : "${ctx}/${managePath}/itembaseconf/importItemBaseConf",
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
				ItemBaseList.grid.store.reload();
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

<%-- <sec:authorize access="hasRole('ITEMBASE_CREATE')"> --%>
<script type="text/javascript">
ItemBaseList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : ItemBaseList,
	handler : ItemBaseList.doCreate
	},'-');
</script>
<%-- </sec:authorize> --%>

<%--  <sec:authorize access="hasRole('ITEMBASE_EDIT')"> --%>
	<script type="text/javascript">
	ItemBaseList.grid.getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : ItemBaseList,
		handler : ItemBaseList.doEdit
	}, '-');
</script>
<%-- </sec:authorize>  --%>



<%-- <sec:authorize access="hasRole('ITEMBASE_DELETE')"> --%>
	<script type="text/javascript">
	ItemBaseList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : ItemBaseList,
		handler : ItemBaseList.doDelete
	}, '-');
</script>
<%-- </sec:authorize> --%>

<%--<sec:authorize access="hasRole('SERVER_APPLY')">--%>
<script type="text/javascript">
ItemBaseList.grid.getTopToolbar().add({
	iconCls : 'button-download-excel',
	text : '下载导入模板',
	scope : ItemBaseList,
	handler : ItemBaseList.doExportXLS
	},'-');
</script>
<%--</sec:authorize>--%>

<%--<sec:authorize access="hasRole('SERVER_APPLY')">--%>
<script type="text/javascript">
ItemBaseList.grid.getTopToolbar().add({
	iconCls : 'button-excel',
	text : '科目基础信息<fmt:message key="button.import" />',
	scope : ItemBaseList,
	handler : ItemBaseList.doImport
	},'-');
</script>
<%--</sec:authorize>--%>

<script type="text/javascript">
Ext.getCmp("ITEMBASE_INFO").add(ItemBaseList);
Ext.getCmp("ITEMBASE_INFO").doLayout();
</script>

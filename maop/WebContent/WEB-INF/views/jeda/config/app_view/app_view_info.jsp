<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//定义列表
AppViewList = Ext.extend(Ext.Panel, {

	constructor : function(cfg) {// 构造方法
		//Ext.apply(this, cfg);
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止
				
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件

		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${frameworkPath}/config/app_view/avtype',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields:['aview_rel_id','aview_desc','avd_id','avd_rel_id', 'avd_simpdesc','avd_descdetail', 'avd_type','aview_oper','aview_time'],
			remoteSort : true,
			sortInfo : {
				field : 'aview_rel_id',
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
			id : 'AppViewListGridPanel',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			stripRows:true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义

			columns : [ new Ext.grid.RowNumberer(), csm,  
			            {header : '序号', dataIndex : 'aview_rel_id', sortable : true},
						{header : '功能描述', dataIndex : 'aview_desc', sortable : true},
						{header : '概括描述', dataIndex : 'avd_simpdesc', sortable : true},
						{header : '详细描述', dataIndex : 'avd_descdetail', sortable : true},
						{header : '功能类型', dataIndex : 'avd_type', sortable : true},
						{header : '发布人员', dataIndex : 'aview_oper', sortable : true},
						{header:'发布时间',dataIndex:'aview_time',sortable:true}
						
	  		
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
			labelWidth : 80,//相应的缩短标签宽度可以增加文本框宽度
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
				anchor : '95%',
				msgTarget : 'side'
			},
	 		// 定义查询表单组件
			items : [ {
			    xtype:'numberfield',
			    fieldLabel:'序号',
			    name:'aview_id',
			    id:'aview_id',
				hidden:true
			    
			},{
				xtype:'textfield',
				fieldLabel : '名称',								
				name : 'aview_name',
				id:'aview_name',
				hidden:true
			},
			{
				xtype:'textfield',
				fieldLabel : '功能描述',								
				name : 'aview_desc',
				id:'aview_desc'
			},{
				xtype:'textfield',
				fieldLabel:'发布人员',
				name:'aview_oper',
				id:'aview_oper'
			},{
				xtype:'combo',
				fieldLabel : '功能类型',								
				name : 'avd_type',
				store:new Ext.data.SimpleStore({
					fields:['value','text'],
					data:[['1','工具箱'],['2','日常巡检'],['3','应用发布']]
				}),
				//emptyText:'请选择',
				mode:'local',
				triggerAction:'all',
				valueField:'value',
				displayField:'text',
				editable : false,
				allowBlank : false,
				id :'avd_type'
			},{
				xtype : 'datefield',
				fieldLabel : '发布日期',
				format:'Y-m',
				editable:false,
				name : 'aview_time',
				id:'aview_time'
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

	 	AppViewList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items :[ this.form, this.grid ]
		});
	}, //constructor end
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${frameworkPath}/config/app_view/aViewExcel.xls';
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
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},  
	// 新建事件
	  doCreate : function() {
			  app.loadTab('APP_VIEW_MAINCREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${frameworkPath}/config/app_view/aViewMainCreate');
	}, 
	
	// 查看事件
	  doView : function() {
		var record = this.grid.getSelectionModel()
				.getSelected();
		var params = {
				avd_id:record.get("avd_id"),
				avd_rel_id:record.get("avd_rel_id")
		};
		//loadTab()的第一个参数定义一个id
		app.loadTab('APP_VIEW_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
				'${ctx}/${frameworkPath}/config/app_view/aViewView',params);
	}, 
	// 修改事件
	  doEdit : function() {
		  if (this.grid.getSelectionModel().getCount() == 1) {
			  var record = this.grid.getSelectionModel()
				.getSelected();
		      var params = {
			     avd_id:record.get("avd_id"),
			     avd_rel_id:record.get("avd_rel_id")
			     
		        };
		      app.loadTab('APP_VIEW_MAINEDIT','<fmt:message key="button.edit" /><fmt:message key="title.list" />',
						'${ctx}/${frameworkPath}/config/app_view/aViewMainEdit',params);
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
			
			var avd_Ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				avd_Ids[i]= records[i].get("avd_id");
			}
			var rel_Ids = new Array();
			for(var i = 0;i<records.length;i++){
				rel_Ids[i] = records[i].get("aview_rel_id");
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
									url : '${ctx}/${frameworkPath}/config/app_view/aViewDelete',
									scope : this,
									success : this.deleteSuccess,
									failure : this.deleteFailure,
									params : {
										avd_ids : avd_Ids,
										rel_ids : rel_Ids,
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

var AppViewList = new AppViewList();
</script>

<%-- <sec:authorize access="hasRole('AVIEW_CREATE')"> --%>
<script type="text/javascript">
AppViewList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : AppViewList,
	handler : AppViewList.doCreate
	},'-');
</script>
<%-- </sec:authorize> --%>

<%--  <sec:authorize access="hasRole('AVIEW_EDIT')"> --%>
	<script type="text/javascript">
	AppViewList.grid.getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : AppViewList,
		handler : AppViewList.doEdit
	}, '-');
</script>
<%-- </sec:authorize>  --%>



<%-- <sec:authorize access="hasRole('AVIEW_DELETE')"> --%>
	<script type="text/javascript">
	AppViewList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : AppViewList,
		handler : AppViewList.doDelete
	}, '-');
</script>
<%-- </sec:authorize> --%>

<script type="text/javascript">
Ext.getCmp("APPVIEW").add(AppViewList);
Ext.getCmp("APPVIEW").doLayout();
</script>

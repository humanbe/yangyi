<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

	//定义列表
	AppViewMainEdit = Ext.extend(Ext.Panel,
					{
						id:'APPVIEWCREATE',
						
						Form:null,
						
						tabIndex : 0,// 查询表单组件Tab键顺序

						
						constructor : function(cfg) {// 构造方法
							Ext.apply(this, cfg);
				
							
							this.Form = new Ext.FormPanel({

								buttonAlign : 'center',
								labelAlign : 'right',
								lableWidth : 15,
								autoHeight: false,
								frame : true,
								monitorValid : true,
								url : '${ctx}/${frameworkPath}/config/app_view/aViewMainEdit',
								defaults : {
									anchor : '90%',
									msgTarget : 'side'
								},
								items :  [{
									xtype : 'textfield',
									fieldLabel : '关联序号',
									name : 'aview_rel_id',
									id : 'app_view_main',
									hidden : true,
									value:'${param.avd_rel_id}',
									readOnly:true,
									style  : 'background : #F0F0F0' 
								},{
									xtype : 'textfield',
									fieldLabel : '功能名称',
									name : 'aview_name'
								},{
									xtype : 'textarea',
									fieldLabel : '功能描述',
									height : 60,
									name : 'aview_desc'
								},{
									xtype : 'textfield',
									fieldLabel : '发布人员',
									name : 'aview_oper'
								},{
									xtype : 'datefield',
									fieldLabel : '发布时间',
									format : 'Y-m-d', 
									editable:false,
									name : 'aview_time'
								}]
					 
								
					});
							
						  	// 加载表单数据
							this.Form.load({
							    url : '${ctx}/${frameworkPath}/config/app_view/aViewView',
								method : 'POST',
								waitTitle : '<fmt:message key="message.wait" />',
								waitMsg : '<fmt:message key="message.loading" />',
								scope : this,
								success : this.loadSuccess,
								failure : this.loadFailure,
								params:{
									avd_rel_id : '${param.avd_rel_id}',
									avd_id : '${param.avd_id}'
									//tool_code :'${param.tool_code}',
									//appsys_code:'${param.appsys_code}'
								}
							}); 
 			
						
							// 实例化数据列表数据源
							this.gridStore = new Ext.data.JsonStore(
							{
								proxy : new Ext.data.HttpProxy(
										{
											method : 'POST',
											url : '${ctx}/${frameworkPath}/config/app_view/tableFind',
											disableCaching : false
										}),
								autoDestroy : true,
								root : 'data',
								totalProperty : 'count',
								fields : ['avd_id','avd_rel_id','avd_simpdesc','avd_descdetail','avd_type'],
								remoteSort : false,
								sortInfo : {
									field : 'avd_id',
									direction : 'ASC'
								},
								baseParams : {
									start : 0,
									limit : 100,
									aview_rel_id : Ext.getCmp("app_view_main").getValue() //'${param.avd_rel_id}'
									
								}
							});

							// 加载列表数据
							this.gridStore.load();
							csm = new Ext.grid.CheckboxSelectionModel();
							this.grid = new Ext.grid.GridPanel(
									{
										id:'app_main_grid',
										border : true,
										//height : 225,
										loadMask : true,
										region : 'center',
										border : false,
										loadMask : true,
										autoHeight:true,
										autoScroll : true,
										autoWeight : true,
										title : '从表信息',
										columnLines : true,
										frame:true,
										viewConfig : {
											forceFit : true
										},
										defaults : {
											anchor : '90%',
											msgTarget : 'side'
										},
										enableColumnHide:false,
										enableHdMenu : false, 
										store : this.gridStore,
										sm : csm,


										columns : [
											new Ext.grid.RowNumberer(),
											csm,
											/* {
												header : '从表序号',
												dataIndex : 'avd_id',
												sortable : true
											},{
												header : '从表关联序号',
												dataIndex : 'avd_rel_id',
												sortable : true
											}, */{
												header : '概括描述',
												dataIndex : 'avd_simpdesc',
												//width : 100,
												sortable : true
											},{
												header : '详细描述',
												dataIndex : 'avd_descdetail',
												//width : 100,
												sortable : true
											},{
												header : '工具类型',
												dataIndex : 'avd_type',
												sortable : true
											}
									 	],
									 	
										// 定义按钮工具条
										tbar : new Ext.Toolbar(
										{
											items : ['-' ]
												}),
												
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
											displayInfo : true,
											pageSize : 100
										})
									});
						
							 this.panel = new Ext.Panel({  
					            layout:'column',
					            autoScroll: true,
					            border:false,
					            items:[{
					                layout: 'form',
					                defaults: {anchor : '100%'},
					                border:false,
					                autoScroll : true,
					                labelAlign : 'right',
					                items: [ this.Form ,this.grid]
					            }]
						    });  
							
						// 设置基类属性
						AppViewMainEdit.superclass.constructor.call(this,{
							layout : 'form',
							border : false,
							buttonAlign : 'center',
							frame : true,
							autoScroll : true,
							monitorValid : true,
							defaults : {
								anchor : '100%',
								msgTarget : 'side'
							},
							items : [ this.panel],
						    
							// 定义按钮
							buttons : [{
								text : '<fmt:message key="button.save" />',
								iconCls : 'button-save',
								tabIndex : this.tabIndex++,
								handler : this.doSave
							},{
								text : '<fmt:message key="button.cancel" />',
								iconCls : 'button-cancel',
								tabIndex : this.tabIndex++,
								handler : this.doCancel

							}]
							
						});
						},
						
						doSave : function(){
							
							if(0 != AppViewMainEdit.gridStore.getCount())
							{
								AppViewMainEdit.Form.getForm().submit({
									scope : AppViewMainEdit,
									success : AppViewMainEdit.saveSuccess,// 保存成功回调函数
									failure : AppViewMainEdit.saveFailure,// 保存失败回调函数
									waitTitle : '<fmt:message key="message.wait" />',
									waitMsg : '<fmt:message key="message.saving" />'
							 	});
							}else
								{
								
								 Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '保存时，从表中应至少有一条对应信息！',
									buttons : Ext.MessageBox.OKCANCEL,
									icon : Ext.MessageBox.WARNING});
								} 
						},
						// 关闭操作
						doCancel : function() {
							app.closeTab('APP_VIEW_MAINEDIT');
							Ext.getCmp("AppViewListGridPanel").getStore().reload();
						},
						doCreate : function(){
							var params = {
								    rel_id:Ext.getCmp('app_view_main').getValue()
							        };
							app.loadWindow('${ctx}/${frameworkPath}/config/app_view/aViewCreate',params);
						},
						doEdit : function(){
							if (this.grid.getSelectionModel().getCount() == 1) {
								  var record = this.grid.getSelectionModel()
									.getSelected();
							      var params = {
								     avd_id: record.get("avd_id"),
								     avd_rel_id: record.get("avd_rel_id"),
								     avd_simpdesc: record.get("avd_simpdesc"),
								     avd_descdetail: record.get("avd_descdetail"),
								     avd_type : record.get("avd_type")
							      };
							      //弹窗的形式修改信息
							      app.loadWindow('${ctx}/${frameworkPath}/config/app_view/aViewEdit', params);
							  } else {
									Ext.Msg.show({
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="message.select.one.only" />',
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.ERROR
											});
								}
							
						},
						doDelete : function(){
							if(this.gridStore.getCount() == 1){
								
							}
							
							if (this.grid.getSelectionModel().getCount() > 0) {
								var records = this.grid.getSelectionModel()
										.getSelections();
								
								var avd_Ids = new Array();
								for ( var i = 0; i < records.length; i++) {
									avd_Ids[i]= records[i].get("avd_id");
								}
								var rel_Ids = new Array();
								for(var i = 0;i<records.length;i++){
									rel_Ids[i] = records[i].get("avd_rel_id");
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
												url : '${ctx}/${frameworkPath}/config/app_view/aViewSubDelete',
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
						} ,
						
						// 保存成功回调
						saveSuccess : function(form, action) {
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.save.successful" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.INFO,
								minWidth : 200,
								fn : function() {
									app.closeTab("APP_VIEW_MAINEDIT");
								 Ext.getCmp("AppViewListGridPanel").getStore().reload();
								}
							});

						},
						// 保存失败回调
						saveFailure : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						},
						// 数据加载失败回调
						loadFailure : function(form, action) {
							var error = action.result.error;
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						},
						loadSuccess : function(form, action) {	
						
						},
						
						download : function(value, metadata, record, rowIndex, colIndex, store) {
							  return '<a href="javascript:dowmload_file_exc2()"><font color=red>下载</font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
							 }

					});
	var AppViewMainEdit=new AppViewMainEdit();
	</script>
	
	<%-- <sec:authorize access="hasRole('AVIEW_SUBCREATE')"> --%>
	<script type="text/javascript">
	AppViewMainEdit.grid.getTopToolbar().add({
		iconCls : 'button-add',
		text : '<fmt:message key="button.add" />',
		scope : AppViewMainEdit,
		handler : AppViewMainEdit.doCreate
		},'-');
	</script>
	<%-- </sec:authorize> --%>

	<%--  <sec:authorize access="hasRole('AVIEW_SUBEDIT')"> --%>
		<script type="text/javascript">
		
		AppViewMainEdit.grid.getTopToolbar().add({
			iconCls : 'button-edit',
			text : '<fmt:message key="button.edit" />',
			scope : AppViewMainEdit,
			handler : AppViewMainEdit.doEdit
		}, '-');
	</script>
	<%-- </sec:authorize>  --%>



	<%-- <sec:authorize access="hasRole('AVIEW_SUBDELETE')"> --%>
		<script type="text/javascript">
		AppViewMainEdit.grid.getTopToolbar().add({
			iconCls : 'button-delete',
			text : '<fmt:message key="button.delete" />',
			scope : AppViewMainEdit,
			handler : AppViewMainEdit.doDelete
		}, '-');
	</script>
	<%-- </sec:authorize> --%>
<script>

	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp('APP_VIEW_MAINEDIT').add(AppViewMainEdit);
	// 刷新Tab页布局
	Ext.getCmp('APP_VIEW_MAINEDIT').doLayout();	
</script>
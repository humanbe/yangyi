<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var loadModeStore = new Ext.data.SimpleStore({
	fields : ['loadModeDisplay', 'loadModeValue'],
	data : [['主机', '0'], ['备机', '1'],['F5', '2']]
});
var autoCaptureStore = new Ext.data.SimpleStore({
	fields : ['autoCaptureDisplay', 'autoCaptureValue'],
	data : [['自动获取', '0'], ['不自动获取', '1']]
});
	//定义列表
	AppCheckDesignPanel = Ext.extend(Ext.Panel,{
		tabIndex : 0,// 查询表单组件Tab键顺序
		Servergrid:null,
		Weblogicgrid : null,
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			//禁止IE的backspace键(退格键)，但输入文本框时不禁止
			Ext.getDoc().on(
							'keydown',
							function(e) {
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

			
			
			this.checkFlagStore = new Ext.data.SimpleStore({
				fields : ['value'],
				data : [['是'], ['否' ] ]
			});
			
			this.appsys_Store =  new Ext.data.Store({
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
			this.appsys_Store.load();

			this.WeblogicgridStore = new Ext.data.JsonStore(
					{
						proxy : new Ext.data.HttpProxy({
							method : 'POST',
							url : '${ctx}/${managePath}/appcheckdesign/weblogic_index',
							disableCaching : false
						}),
						autoDestroy : true,
						root : 'data',
						totalProperty : 'count',
						fields : ['appsys_code','server_name','server_ip','server_group','aplCode', 'ipAddress', 'serverName', 'weblogicFlg', 'clusterServer', 'weblogicPort','serverJdbcName'],
						remoteSort : true,
						sortInfo : {
							field : 'aplCode',
							direction : 'ASC'
						},
						baseParams : {
							aplCode: '${param.appsysCode}',
							start : 0,
							limit : 100
						},
						listeners : {
							'load' : function(store){
							}
						}});
			
			
			var server_record = Ext.data.Record.create([
					                     				{name: 'srvCode'},
					                     				{name: '_id', type: 'int'},
					                     				{name: '_is_leaf', type: 'bool'},
					                     				{name: '_parent', type: 'auto'},
					                     				{name: 'serClass', type: 'string'},
					                     				
					                     				{name: 'appsys_code', type:'string'},
					                     			 	{name: 'server_ip', type:'string'},
					                     			 	{name: 'server_name',type :'string'},
					                     			 	{name: 'serve_group',type :'string'},
					                     			 	{name: 'ipAddress', type:'string'},
					                     			 	{name: 'loadMode', type:'string'},
					                     			 	{name: 'serName',type :'string'},
					                     			 	{name: 'memConf',type :'string'},
					                     			 	{name: 'cpuConf',type :'string'},
					                     			 	{name: 'diskConf',type :'string'},
					                     			 	{name: 'ipAddress',type :'string'},
					                     			 	{name: 'floatAddress',type :'string'},
					                     			 	{name: 'autoCapture',type :'string'},
					                     			 	{name: 'checkflag',type :'string'}
					                     			]);
			// 实例化数据列表数据源
			this.ServergridStore =  new Ext.ux.maximgb.tg.AdjacencyListStore({
		    	proxy : new Ext.data.HttpProxy(
		    		new Ext.data.Connection({
						timeout : 120000,
						url : '${ctx}/${managePath}/appcheckdesign/server_index',
						method : 'POST'
					})
		    	),
		    	baseParams : {
		    		aplCode: '${param.appsysCode}',
		    		environmentCode : '${param.environmentCode}'
				},
				reader: new Ext.data.JsonReader({
					id: '_id',
					root: 'data',
					totalProperty: 'count',
					successProperty: 'success'
				}, server_record),
				pruneModifiedRecords : true,
				listeners : {
					load : function(store){
						if(store.getCount() == 0){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : '<fmt:message key="message.no.data"/>',
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.WARNING
							});
						}else{
						}
					}
				}
		    });
			
			

			this.WeblogicgridStore.load();
			this.ServergridStore.load();
			
			//全部展开treegrid
		    this.ServergridStore.on("load",function(e){
		    	e.expandAll();
		    }); 
			
			csm = new Ext.grid.CheckboxSelectionModel();
			csm2 = new Ext.grid.CheckboxSelectionModel();

			this.Weblogicgrid = new Ext.grid.GridPanel(
					{
						region : 'center',
						id:'WeblogicConfGridPanel',
						border : false,
						loadMask : true,
						height : 300,
						title : 'Weblogic配置',
						columnLines : true,
						viewConfig : {
							forceFit : true
						},
						store : this.WeblogicgridStore,
						sm : csm,
						// 列定义
						columns : [ new Ext.grid.RowNumberer(), csm, 
									{header : '<fmt:message key="property.appsyscd" />', dataIndex : 'aplCode',sortable : true},
									{header : '<fmt:message key="property.ipAddress" />', dataIndex : 'ipAddress', sortable : true},
									{header : '<fmt:message key="property.weblogicServer" />', dataIndex : 'serverName', sortable : true},
									{header : '服务JDBC名称', dataIndex : 'serverJdbcName', sortable : true},
									{header : '<fmt:message key="property.weblogicFlg" />', dataIndex : 'weblogicFlg', sortable : true},
									{header : '<fmt:message key="property.clusterServer" />', dataIndex : 'clusterServer', sortable : true},
									{header : '<fmt:message key="property.weblogicPort" />', dataIndex : 'weblogicPort', sortable : true}
						  		],
						  		
						  	// 定义按钮工具条
								tbar : new Ext.Toolbar({
									items : []
								}),
						
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.WeblogicgridStore,
							displayInfo : true,
							pageSize : 200
						})

					});

		
			this.Servergrid = new Ext.ux.maximgb.tg.EditorGridPanel({
					
						region : 'center',
						border : false,
						loadMask : true,
						title : '服务器配置',
						master_column_id : 'srvCode',
					      
				      	//autoHeight : true,
				    	height : 700,
				      	columnLines : true,
						animCollapse : true,
						viewConfig : {
							forceFit : true
						},
						store : this.ServergridStore,
						sm : csm2,
						columns : [ new Ext.grid.RowNumberer(),
									{id: 'srvCode',header : '<fmt:message key="property.srvCode" />', dataIndex : 'srvCode', sortable : true,width:200},
									
									{header : '应用系统', dataIndex : 'appsys_code', sortable : true,hidden:true},
									{header : '服务器名称', dataIndex : 'server_name', sortable : true},
									{header : '服务器ip', dataIndex : 'server_ip', sortable : true,hidden:true},
									{header : '服务器分组', dataIndex : 'server_group', sortable : true,hidden:true},
									
									{header : '<fmt:message key="property.loadMode" />', dataIndex : 'loadMode', sortable : true , 
										editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
											typeAhead : true,
											triggerAction : 'all',
											hiddenName : 'flag',
											mode : 'local',
											store : loadModeStore,
											displayField : 'loadModeDisplay',
											valueField : 'loadModeValue',
											editable : false
										} )),
										renderer : this.loadModeStoreOne	},
									{header : '<fmt:message key="property.serClass" />', dataIndex : 'serClass', sortable : true,hidden:true},
									//{header : '<fmt:message key="property.serName" />', dataIndex : 'serName', sortable : true, editor : new Ext.form.TextField()},
									{header : '<fmt:message key="property.memConf" />', dataIndex : 'memConf', sortable : true, editor : new Ext.form.TextField(),hidden:true},
									{header : '<fmt:message key="property.cpuConf" />', dataIndex : 'cpuConf', sortable : true, editor : new Ext.form.TextField(),hidden:true},
									{header : '<fmt:message key="property.diskConf" />', dataIndex : 'diskConf', sortable : true, editor : new Ext.form.TextField(),hidden:true},
									//{header : '<fmt:message key="property.ipAddress" />', dataIndex : 'ipAddress', sortable : true},
									{header : '<fmt:message key="property.floatAddress" />', dataIndex : 'floatAddress', sortable : true},
									{header : '<fmt:message key="property.autoCapture" />', dataIndex : 'autoCapture', sortable : true, 
										editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
											typeAhead : true,
											triggerAction : 'all',
											hiddenName : 'flag',
											mode : 'local',
											store : autoCaptureStore,
											displayField : 'autoCaptureDisplay',
											valueField : 'autoCaptureValue',
											editable : false
										} )),
										renderer : this.autoCaptureStoreOne	
										},
										{header : '是否用于应用巡检', dataIndex : 'checkflag', sortable : true, 
											editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
												typeAhead : true,
												triggerAction : 'all',
												hiddenName : 'flag',
												mode : 'local',
												store : this.checkFlagStore,
												displayField : 'value',
												valueField : 'value',
												editable : false,
												allowBlank : false
											} ))
											}
									
						  		],
						
						 listeners : {
								//编辑完成后处理事件
								scope : this,
								'beforeedit' : function(e){
									if(!e.record.get('_is_leaf') ||null== e.record.get('checkflag')||''==e.record.get('checkflag')){
										e.cancel = true;
									}
								} 
							},
							
							// 定义按钮工具条
							tbar : new Ext.Toolbar({
								items : []
							}),
						// 定义分页工具条
						bbar : new Ext.PagingToolbar({
							store : this.ServergridStore,
							displayInfo : true,
							pageSize : 100
						})

					});



			AppCheckDesignPanel.superclass.constructor.call(
							this,
							{
								layout : 'form',
								border : false,
								buttonAlign : 'center',
								frame : true,
								autoScroll : true,
								defaults : {
									anchor : '100%',
									msgTarget : 'side'
								},
								
								monitorValid : true,

								items : [ {
									xtype : 'tabpanel',
									plain : true,
									forceLayout : true,
									autoScroll : false,
									enableTabScroll : true,
									defaults : {
										anchor : '80%'
									},
									activeTab : 0,
									height : 650,
									deferredRender : false,
									defaults : {
										bodyStyle : 'padding:10px'
									},
									items : [  this.Servergrid,
									           
									          this.Weblogicgrid 
											
											 ]
								}

								],
								

								// 定义按钮
									buttons : [
									{
										text : '<fmt:message key="button.close" />',
										iconCls : 'button-close',
										tabIndex : this.tabIndex++,
										formBind : true,
										scope : this,
										handler : this.doClose
									}
									 ]
							});

		},
		
		autoCaptureStoreOne : function(value) {

			var index = autoCaptureStore.find('autoCaptureValue', value);
			if (index == -1) {
				return value;
			} else {
				return autoCaptureStore.getAt(index).get('autoCaptureDisplay');
			}
		},
		loadModeStoreOne : function(value) {

			var index = loadModeStore.find('loadModeValue', value);
			if (index == -1) {
				return value;
			} else {
				return loadModeStore.getAt(index).get('loadModeDisplay');
			}
		},
		// 取消操作
		doClose : function() {
			app.closeTab('APP_CHECK_DESIGN');
		},
		// 保存操作
		doSaveServer : function() {
			app.mask.show();
			var serverValues = [];
			var modified = this.ServergridStore.getModifiedRecords();
			
			if(modified.length == 0){
				app.mask.hide();
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '<fmt:message key="message.no.data.to.save"/>',
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.WARNING
				});
				
				return;
			}
			
			Ext.each(modified, function(item){
				serverValues.push(item.data);
			});
			Ext.Ajax.request({
				url : '${ctx}/${managePath}/appcheckdesign/saveServer',
				scope : this,
				method : 'POST',
				success : this.saveServerSuccess,
				failure : this.saveServerFailure,
				params : {
					serverValues : Ext.util.JSON.encode(serverValues) 
				}
			});
		},
		saveServerSuccess : function(form, action) {
			app.mask.hide();
			this.ServergridStore.commitChanges();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				
				minWidth : 200,
				scope : this
			});
			this.ServergridStore.rejectChanges();
			this.ServergridStore.reload();
			
			

		},
		saveServerFailure : function(form, action) {
			app.mask.hide();
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		doCreateWeblogic : function() {
			var params = {
					aplCode: '${param.appsysCode}'
				};
				app.loadWindow('${ctx}/${managePath}/appcheckdesign/createWeblogic', params);
		},
		// 编辑事件
	    doEditWeblogic : function() {
			if (this.Weblogicgrid.getSelectionModel().getCount() == 1) {
				var record = this.Weblogicgrid.getSelectionModel().getSelected();
				var params = {
					aplCode : record.get('aplCode'),
					ipAddress : record.get('ipAddress'),
					serverName : record.get('serverName'),
					weblogicPort : record.get('weblogicPort')
				};
				app.loadWindow('${ctx}/${managePath}/appcheckdesign/editWeblogic', params);
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
		doDeleteWeblogic : function() {
			if (this.Weblogicgrid.getSelectionModel().getCount() > 0) {
				var records = this.Weblogicgrid.getSelectionModel().getSelections();
				var aplCodes = new Array();
				var ipAddresses = new Array();
				var serverNames = new Array();
				var weblogicPorts = new Array();
				for ( var i = 0; i < records.length; i++) {
					aplCodes[i] = records[i].get('aplCode');
					ipAddresses[i] = records[i].get('ipAddress');
					serverNames[i] = records[i].get('serverName');
					weblogicPorts[i] = records[i].get('weblogicPort');
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
								url : '${ctx}/${managePath}/weblogicconfmanage/delete',
								scope : this,
								success : this.deleteSuccess,
								failure : this.deleteFailure,
								params : {
									aplCodes : aplCodes,
									ipAddresses : ipAddresses,
									serverNames : serverNames,
									weblogicPorts : weblogicPorts,
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
				this.Weblogicgrid.getStore().reload();// 重新加载数据源

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
		}
		
		});
			
		
			
		var	appCheckDesignPanel=new AppCheckDesignPanel();
		</script>
		<sec:authorize access="hasRole('APP_CHECK_SERVER_SAVE')">
		<script type="text/javascript">
		appCheckDesignPanel.Servergrid.getTopToolbar().add({
			iconCls : 'button-save',
			text : '<fmt:message key="button.save" />-服务器信息',
			scope : appCheckDesignPanel,
			handler : appCheckDesignPanel.doSaveServer
			},'-');
		</script>
		</sec:authorize>
		

	<script type="text/javascript">
appCheckDesignPanel.Weblogicgrid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.create" />',
	scope : appCheckDesignPanel,
	handler : appCheckDesignPanel.doCreateWeblogic
	},'-');
</script>
<script type="text/javascript">
appCheckDesignPanel.Weblogicgrid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : appCheckDesignPanel,
	handler : appCheckDesignPanel.doEditWeblogic
	},'-');
</script>
<script type="text/javascript">
appCheckDesignPanel.Weblogicgrid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : appCheckDesignPanel,
	handler : appCheckDesignPanel.doDeleteWeblogic
	},'-');
</script>	
		
		
		
		<script type="text/javascript">
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("APP_CHECK_DESIGN").add(appCheckDesignPanel);
	// 刷新Tab页布局
	Ext.getCmp("APP_CHECK_DESIGN").doLayout();
</script>
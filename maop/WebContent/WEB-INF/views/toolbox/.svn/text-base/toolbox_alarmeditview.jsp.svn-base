<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

		alarmEditview = Ext.extend(Ext.Panel, {
			id:'${param.event_id}'+'tools',
			row : 0,// Tab键顺序			window : null,
			constructor : function(cfg) {
				Ext.apply(this, cfg);
				// 设置基类属性		
				
		  this.alarm_levelStore = new Ext.data.JsonStore(
						{
							autoDestroy : true,
							url : '${ctx}/${frameworkPath}/item/ALARM_LEVEL/sub',
							root : 'data',
							fields : [ 'value', 'name' ]
						});
		 this.alarm_levelStore.load();

		 this.appsys_Store =  new Ext.data.Store({
				proxy: new Ext.data.HttpProxy({
					url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
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
			//重新Windows窗口方法
		
			this.window=new Jeda.ui.Window({
			
				plain : true,
				 modal:false,
				 resizable : true,
				 closeAction : 'close',
				 closable : true,
				 height : document.body.clientHeight * 0.8,
				 width : document.body.clientWidth * 0.7,
				 doLoad : function(cfg) {
						this.removeAll();
						this.add({
							id : 'window'+'${param.event_id}',
							//title : '${param.event_id}',
							autoScroll : true,
							layout : 'fit',
							border : false,
							autoLoad : {
								url : cfg.url,
								params : cfg.params,
								discardUrl : false,
								nocache : true,
								timeout : 3000,
								method : 'GET',
								scripts : true
							}
						});
						this.doLayout();
						if (!this.isVisible()) {
						
							this.show();
						}
					}
			});
				
			
			this.form = new Ext.FormPanel({
										buttonAlign : 'center',
										labelAlign : 'right',
										lableWidth : 15,
										 autoScroll: true,
										autoHeight : true,
										url : '${ctx}/${appPath}/ToolBoxAlarmController/editDesc',
										frame : true,
										monitorValid : true,
										defaults : {
											anchor : '80%',
											msgTarget : 'side'
										},
										items : [{
											layout:'column',
											items:[{
											     columnWidth:.5,
											     layout:'form',
											     items:[{
														xtype : 'textfield',
														fieldLabel :'<fmt:message key="toolbox.alarm_event_id" />',
														name : 'event_id',
														anchor:'100%',
														style  : 'background : #F0F0F0' , 
														readOnly:true,
														tabIndex : this.tabIndex++
													

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_device_ip" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'device_ip',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_componenttype" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'componenttype',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_subcomponent" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'subcomponent',
														tabIndex : this.tabIndex++

													},
													{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_first_time" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'first_time',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_orgname" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'orgname',
														tabIndex : this.tabIndex++
														

													}]
											},{
											     columnWidth:.5,
											     layout:'form',
											    
											     items:[{
														xtype : 'combo',
														
														store : this.alarm_levelStore,
														fieldLabel : '<fmt:message key="toolbox.alarm_customerseverity" />',
														anchor:'100%',
														name : 'customerseverity',
														valueField : 'value',
														displayField : 'name',
														hiddenName : 'customerseverity',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														tabIndex : this.tabIndex++
														
													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_appname" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'appname',
														tabIndex : this.tabIndex++
														

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_component" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'component',
														tabIndex : this.tabIndex++
														//allowBlank : false

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_last_time" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'last_time',
														tabIndex : this.tabIndex++

													},{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_event_group" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'event_group',
														tabIndex : this.tabIndex++

													},
													{
														xtype : 'textfield',
														anchor:'100%',
														fieldLabel :'<fmt:message key="toolbox.alarm_mgtorg" />',
														readOnly:true,
														style  : 'background : #F0F0F0' , 
														name : 'mgtorg',
														tabIndex : this.tabIndex++

													}]
											}]
										},{
											xtype : 'textarea',
											fieldLabel : '<fmt:message key="toolbox.alarm_summarycn" />',
											name : 'summarycn',
											readOnly:true,
											style  : 'background : #F0F0F0' , 
											height : 100,
											maxLength:500,
											tabIndex : this.tabIndex++

										},{
											xtype : 'textarea',
											fieldLabel : '<fmt:message key="toolbox.alarm_result_summary" />',
											id:'${param.event_id}'+'alarmedit_alarm_result_summaryID',
											name : 'result_summary',
											height : 150,
											maxLength:500,
											tabIndex : this.tabIndex++

										} ],
										buttons : [
										      {
												text :'<fmt:message key="toolbox.diagnostic" />',
												iconCls : 'button-save',
												formBind : true,
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doDict
											},	
										     {
												text :'<fmt:message key="toolbox.Ignore" />',
												iconCls : 'button-save',
												formBind : true,
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doUpdateIgnored
											},{
												text :'完成处理', 
												iconCls : 'button-save',
												formBind : true,
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doSave
											},{
												text : '<fmt:message key="button.cancel" />',
												iconCls : 'button-cancel',
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doCancel

											} ]
											
									});
		
			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore(
			{
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${appPath}/ToolBoxAlarmController/alarm_business',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
			fields : [ 'id','appsys_code', 'business_impact_type',
						'business_impact_level', 
						'business_impact_content',
						'diagnostic_status','math_tool_num'
				],
				remoteSort : false,
				sortInfo : {
					field : 'business_impact_level',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100,
					event_id:'${param.event_id}'
					
				}
			});

			// 加载列表数据
			this.gridStore.load();
			
			this.grid = new Ext.grid.GridPanel(
					{
						border : true,
						height : 225,
						loadMask : true,
						region : 'center',
						border : false,
						loadMask : true,
						autoScroll : true,
						autoWeight : true,
						//autoHeight : true,
						title : '业务影响列表',
						columnLines : true,
						viewConfig : {
							forceFit : false
						},
						defaults : {
							//anchor : '90%',
							msgTarget : 'side'
						},
						enableColumnHide:false,
						enableHdMenu : false, 
						store : this.gridStore,
						// 列定义
						columns : [
							new Ext.grid.RowNumberer(),
							
							{
								header : '<fmt:message key="toolbox.id" />',
								dataIndex : 'id',
								sortable : true
							},{
								header :'<fmt:message key="toolbox.appsys_code" />',
								dataIndex : 'appsys_code',
								renderer : this.appsys_Storeone,
								scope : this,
								sortable : true
							},{
								header : '<fmt:message key="toolbox.business_impact_type" />',
								dataIndex : 'business_impact_type',
								sortable : true
							},{
								header : '<fmt:message key="toolbox.business_impact_content" />',
								dataIndex : 'business_impact_content',
								width:200,
								sortable : true,
								renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
								    //build the qtip:    
								    var title = "详细内容：";
								    var tip = record.get('business_impact_content');    
								    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

								    //return the display text:    
								    var displayText =  record.get('business_impact_content') ;    
								    return displayText;    

								}
							},{
								header : '<fmt:message key="toolbox.business_impact_level" />',
								dataIndex : 'business_impact_level',
								sortable : true,
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '最高级' : return '<span style="color:red;">最高级</span>' ;
										case '高级' : return '<span style="color:orange;">高级</span>';
										case '中级' : return '<span style="color:brown;">中级</span>';
										case '低级' : return '<span style="color:black;">低级</span>';
									}
								}
							},{
								header : '<fmt:message key="toolbox.diagnostic_status" />',
								dataIndex : 'diagnostic_status',
								hidden:true,
								sortable : true
							},{
								header : '匹配工具数',
								dataIndex : 'math_tool_num',
								hidden:true,
								sortable : true
							}

						
					 	],
						// 定义按钮工具条
						tbar : new Ext.Toolbar(
								{
									items : [
									         
									]
								}),
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.gridStore,
							displayInfo : true,
							pageSize : 100
						})
					});
			
			
			this.panelOne = new Ext.Panel({  
	            layout:'column',
	            autoScroll: true,
	            border:false,
	            items:[{
	                layout: 'form',
	                defaults: {anchor : '100%'},
	                border:false,
	                autoScroll : true,
	                labelAlign : 'right',
	                items: [ this.form ,this.grid]
	            }]
		    }); 
		alarmEditview.superclass.constructor.call(this, {
			layout : 'fit',
			autoScroll : true,
			items : [this.panelOne]
		});
		this.form.load(
				{
					url : '${ctx}/${appPath}/ToolBoxAlarmController/editview',
					method : 'POST',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					success : this.loadSuccess,
					failure : this.loadFailure,
					params:{
						event_id :'${param.event_id}'
					}
				}
				);
		
	},
	 doCancel : function() {
		
		 app.closeTab('${param.event_id}');
		},
		

		
	doSave : function() {
		
		
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="toolbox.is_handle_event" />',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(buttonId) {
				if (buttonId == 'ok') {
					app.mask.show();
				 var  storeBusiness=this.grid.getStore();
					var jsonBusiness = [];
					storeBusiness.each(function(item) {
						jsonBusiness.push(item.data);
					});
					 Ext.Ajax.request({
							method : 'POST',
							url : '${ctx}/${appPath}/ToolBoxAlarmController/editDesc',
							scope : this,
							success : this.saveSuccess,
							failure : this.saveFailure,
							params : {
								event_id :'${param.event_id}',
								result_summary :Ext.getCmp('${param.event_id}'+'alarmedit_alarm_result_summaryID').getValue(),
								jsonBusiness: Ext.util.JSON.encode(jsonBusiness)
							}
						}); 
				}
			}
		});
		
				
			/* 	alarmEditview.form.getForm().submit({
						scope : alarmEditview,
						success : alarmEditview.saveSuccess, // 保存成功回调函数
						failure : alarmEditview.saveFailure, // 保存失败回调函数
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.saving" />'
					}); */
			
		},
		appsys_Storeone : function(value) {

			var index = this.appsys_Store.find('appsysCode', value);
			if (index == -1) {
				return value;
			} else {
				return this.appsys_Store.getAt(index).get('appsysName');
			}
		},
		
		saveSuccess : function(form, action) {
			app.mask.hide();
			 Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					minWidth : 200,
					fn : function() {
						app.closeTab('${param.event_id}');
						Ext.getCmp('Alarmuntreatedpanelid').getStore().reload(); 
						
					}
			}); 
		
		},
		// 保存失败回调
		saveFailure : function(form, action) {
			app.mask.hide();
			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'+ error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		
		// 忽略事件
		doUpdateIgnored : function() {

				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="toolbox.is_Ignore_event" />',
							buttons : Ext.MessageBox.OKCANCEL,
							icon : Ext.MessageBox.QUESTION,
							minWidth : 200,
							scope : this,
							fn : function(buttonId) {
								if (buttonId == 'ok') {
									app.mask.show();
									Ext.Ajax.request({
												url : '${ctx}/${appPath}/ToolBoxAlarmController/doIgnored',
												method:'POST',
												scope : this,
												success : this.updataIgnoredSuccess,
												failure : this.updataIgnoredFailure,
												params : {
													event_id :'${param.event_id}'
													
												}
											});
								}
							}
						});
			
		},// 修改失败回调方法
		updataIgnoredFailure : function() {
			app.mask.hide();
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="toolbox.Ignore_Failure" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		},
		// 修改成功回调方法
		updataIgnoredSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="toolbox.Ignore_Failure" />'
									+ error,
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="toolbox.Ignore_Sucess" />', 
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.INFO,
							fn : function() {
								app.closeTab('${param.event_id}');
								Ext.getCmp("Alarmuntreatedpanelid").getStore().reload();
							}
						});
				
			}
		},
		//诊断工具列表
		doDict : function() {
			 var params = {
			 		 event_id :'${param.event_id}',
			 		device_ip :'${param.device_ip}'
			 		 
			};
			this.window.doLoad({
				url : '${ctx}/${appPath}/ToolBoxAlarmController/alarmtools',
				params : params
			});
		}
		

});

var alarmEditview = new alarmEditview();
Ext.getCmp('${param.event_id}').add(alarmEditview);
Ext.getCmp('${param.event_id}').doLayout();

Ext.getCmp('${param.event_id}').on('beforedestroy',function(){ 
	Ext.getCmp('${param.event_id}'+'tools').window.close();
},this);

</script>
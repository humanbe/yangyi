<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var	 serverPanel = null;
var mask = new Ext.LoadMask(Ext.getBody(), {
	msg : '进行中，请稍候...',
	removeMask : true
});
	JobExcuteServerForm = Ext.extend(Ext.FormPanel,{
						row : 0,// Tab键顺序
						csmMovedServers : null,
						csmMoveServers : null,
					constructor : function(cfg) {
						csmMovedServers = new Ext.grid.CheckboxSelectionModel();
						csmMoveServers = new Ext.grid.CheckboxSelectionModel();
							Ext.apply(this, cfg);
							// 定义左侧可选服务器组件--------------------------------------begin
							this.jobDesignServerStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${appPath}/jobexcute/getServer',
													disableCaching : false
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'serverName',
												'bsaAgentFlag', 'floatingIp',
												'deleteFlag', 'osType',
												'appsysCode', 'serverIp' ],
										pruneModifiedRecords : true,
										sortInfo : {
											field : 'osType',
											direction : 'ASC'
										},
										remoteSort : true,
										baseParams : {
											start : 0,
											limit : 20,
											serverIp: ''
										}
									});
							this.jobDesignServerStore.reload();
							this.jobDesignMoveServers = new Ext.grid.GridPanel(
									{
										id : 'jobDesignMoveServersGrid',
										height : 340,
										loadMask : true,
										frame : true,
										title : '<fmt:message key="toolbox.selectable_server" />',
										region : 'center',
										border : false,
										autoScroll : true,
										autoWidth : true,
										columnLines : true,
										viewConfig : {
											forceFit : false
										},
										/* hideHeaders:true,  */
										store : this.jobDesignServerStore,
										//autoExpandColumn : 'name',
										sm : csmMovedServers,
										columns : [
												csmMovedServers,
												{
													header : '操作系统类型',
													dataIndex : 'osType',
													sortable : true,
													width : 58
												},
												{
													header : '系统代码',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 58
												},
												{
													header : '<fmt:message key="toolbox.server_ip" />',
													dataIndex : 'serverIp',
													sortable : true,
													width : 100
												} ],

										// 定义数据列表监听事件
										listeners : {
											scope : this,
											// 行双击移入事件
											rowdblclick : function(row,rowIndex, e) {
												var curRow = this.jobDesignServerStore.getAt(rowIndex);
												var osType = curRow.get("osType");
												var appsysCode = curRow.get("appsysCode");
												var serverIp = curRow.get("serverIp");
												var notEqualFlag = true;
												this.jobDesignExcgridMovedServers.getStore().each(
																function(rightRecord) {
																	if (osType == rightRecord.data.osType && appsysCode == rightRecord.data.appsysCode && serverIp == rightRecord.data.serverIp) {
																		notEqualFlag = false;
																	}
																}, this);
												if (notEqualFlag) {
													this.jobDesignExcgridMovedServers.store.add(curRow);
												}

											}
										},
										tbar : new Ext.Toolbar(
												{
													items : ['-',
															{
																xtype : 'textfield',
																width : 180,
																fieldLabel : '<fmt:message key="property.serverIp" />',
																id : 'serverIpId',
																name : 'Ip',
																emptyText : '服务器IP',
																tabIndex : this.tabIndex++
															},'-',
															{
																text : '查询',
																iconCls : 'button-ok',
																scope : this,
																handler : this.findIp
															}

													]
												})
									});
							// 定义左侧可选服务器组件--------------------------------------end

							// 定义中间移入移出按钮------------------------------------------begin
							this.Panel = new Ext.Panel(
									{
										//id : 'serverPanel',
										height : 340,
										labelAlign : 'right',
										buttonAlign : 'center',
										autoWidth  : false,
										frame : true,
										split : true,
										defaults : {
											margins : '0 0 10 0'
										},
										xtype : 'button',
										layout : {
											type : 'vbox',
											padding : '10',
											pack : 'center',
											align : 'center'
										},
										items : [
												{
													xtype : 'button',
													width : 40,
													height : 25,
													text : '<fmt:message key="toolbox.shift_in" />',
													scope : this,
													handler : this.serverShiftIn
												},
												{
													xtype : 'button',
													width : 40,
													height : 25,
													text : '<fmt:message key="toolbox.shift_out" />',
													scope : this,
													handler : this.serverShiftOut
												} ]
									});
							// 定义中间移入移出按钮------------------------------------------end

							// 定义组件页签右侧列表组件--------------------------------------begin
							this.gridMovedServersStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy( {
											method : 'POST',
											url : '${ctx}/${appPath}/jobexcute/getCheckedServer/${param.job_code}',
											disableCaching : false
										}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'osType','appsysCode', 'serverIp'],
										remoteSort : true,
										baseParams : {
											start : 0,
											limit : 10
										}
									});
							this.gridMovedServersStore.load();
							this.jobDesignExcgridMovedServers = new Ext.grid.GridPanel(
									{
										id : 'jobDesignExcgridMovedServersGrid',
										height : 340,
										region : 'center',
										border : false,
										frame : true,
										autoScroll : true,
										//autoHeight : true,
										//autoWidth  : true,
										viewConfig: {
									        forceFit: true
									    },
										loadMask : true,
										stripeRows: true,
										title : '已选择的服务器',
										columnLines : true,
										closeable : true,
										store : this.gridMovedServersStore,
										//autoExpandColumn : 'serverIp',
										sm : csmMoveServers,
										columns : [
												csmMoveServers,
												{
													header : '操作系统类型',
													dataIndex : 'osType',
													sortable : true,
													width : 58
												},
												{
													header : '系统代码',
													dataIndex : 'appsysCode',
													sortable : true,
													hidden : true,
													width : 58
												},
												{
													//id : 'serverIp',
													header : '<fmt:message key="toolbox.server_ip" />',
													dataIndex : 'serverIp',
													sortable : true,
													width : 100
												} ],
										// 定义数据列表监听事件
										listeners : {
											scope : this,
											// 行双击移出事件
											rowdblclick : function(row,rowIndex, e) {
												var curRow = this.gridMovedServersStore.getAt(rowIndex);
												this.jobDesignExcgridMovedServers.store.remove(curRow);
											}
										}
									});

						
							JobExcuteServerForm.superclass.constructor.call(this, {
									labelAlign : 'right',
									buttonAlign : 'center',
									hight : 400,
									frame : true,
									autoScroll : true,
									method : 'POST',
									//url : '${ctx}/${appPath}/jobdesign/create',
									defaults : {
										anchor : '100%',
										msgTarget : 'side'
									},
									monitorValid : true,
									items : [{
										layout:'column',
						                border : true ,
										items :[{
						                    columnWidth:.425,  
						                    border : false,
						                    defaults : { flex : 1 },
						                    layoutConfig : { align : 'stretch' },
						                    items : [this.jobDesignMoveServers]
						                },{
						                    columnWidth:.15,
						                    border:false,
						                    labelAlign : 'right',
						                    items: [this.Panel]
						                } ,{
						                    columnWidth:.425,
						                    border:false,
						                  	defaults : {  flex : 1  },
						                    layoutConfig : { align : 'stretch' },
						                    items: [this.jobDesignExcgridMovedServers] 
						                }] 
									}],
									// 定义查询表单按钮
									buttons : [{
										text : '执行',
										iconCls : 'button-ok',
										tabIndex : this.tabIndex++,
										scope : this,
										handler : this.doExe
									}]
							});
						},
						findIp : function() {
							Ext.getCmp('jobDesignMoveServersGrid').getStore().baseParams.serverIp=Ext.getCmp('serverIpId').getValue();
							Ext.getCmp('jobDesignMoveServersGrid').getStore().reload();
						},
						doExe : function() {
							var storeServer = this.jobDesignExcgridMovedServers.getStore();
				    		var jsonServer = [];
				    		storeServer.each(function(item) {
				    			jsonServer.push(item.data);
				    		});
							app.mask.show();
				    		app.closeWindow();
							Ext.Ajax.request({
										url : '${ctx}/${appPath}/jobexcute/exeJob',
										method : 'POST',
										scope : this,
										success : this.sysSuccess,
										failure : this.sysFailure,
										disableCaching : true,
										params : {
											data : Ext.util.JSON.encode(jsonServer),
											jobCode : '${param.job_code}'
										}
									});
							
						},
						sysSuccess : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.excute.failed" /><fmt:message key="error.code" />:' + error,
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
							} else if (Ext.decode(response.responseText).success == true) {
								Ext.Msg.show({
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="job.doSuccess" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO
										});
							}
						},
						// 保存失败回调
						sysFailure : function(form, action) {
							app.mask.hide();
							var error = action.result.error;
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.excute.failed" /><fmt:message key="error.code" />:' + error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						},
						//服务器移入事件
						serverShiftIn : function() {
							var records =this.jobDesignMoveServers.getSelectionModel().getSelections();
					    		var notEqualFlag = true;
					    		Ext.each(records,function(leftRecord){
					    			Ext.getCmp('jobDesignExcgridMovedServersGrid').getStore().each(function(rightRecord){
					    				if(leftRecord.data.serverIp == rightRecord.data.serverIp){
					    					notEqualFlag = false;
					    				}
					    			},this);
					    			if(notEqualFlag){
					    				Ext.getCmp('jobDesignExcgridMovedServersGrid').getStore().add(leftRecord);
					    			}
					    			notEqualFlag = true;
					    		});
					    	
						},
						//服务器移出事件
						serverShiftOut : function() {
							var records = this.jobDesignExcgridMovedServers.getSelectionModel().getSelections();
							for(var i = 0; i<records.length; i++) {
								this.jobDesignExcgridMovedServers.store.remove(records[i]);
							}
						},
						//保存成功回调
						saveSuccess : function(form, action) {
							Ext.Msg
									.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.successful" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200,
										fn : function() {
											app.closeWindow();
										}
									});
						},
						// 保存失败回调
						saveFailure : function(form, action) {
							var error = decodeURIComponent(action.result.error);
							Ext.Msg
									.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'
												+ error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});
	app.window.get(0).add(new JobExcuteServerForm());
	app.window.get(0).doLayout();
</script>
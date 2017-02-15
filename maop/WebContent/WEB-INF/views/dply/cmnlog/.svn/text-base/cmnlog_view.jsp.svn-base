<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	DplySystemLogViewForm = Ext.extend(Ext.Panel,
					{
						tabIndex : 0,// Tab键顺序
						gridStore : null,// 数据列表数据源
						constructor : function(cfg) {// 构造方法
							Ext.apply(this, cfg);
							this.gridStore = new Ext.data.JsonStore(
									{
										proxy : new Ext.data.HttpProxy(
												{
													method : 'POST',
													url : '${ctx}/${managePath}/dplysystemlog/view',
													disableCaching : true
												}),
										autoDestroy : true,
										root : 'data',
										totalProperty : 'count',
										fields : [ 'logJnlNo', 'execDate',
												'detailLogSeq', 'appsysCode',
												'stepName', 'jobName',
												'execServerIp', 'logType',
												'execStatus', 'execStartTime',
												'execCompletedTime',
												'execCreatedTime',
												'execUpdatedTime',
												'resultsPath' ],
										remoteSort : true,
										sortInfo : {
										    field : 'detailLogSeq',
										    direction : 'ASC'
										}, 
										baseParams : {
											start : 0,
											limit : 50,
											logJnlNo : '${param.logJnlNo}'
										}
									});
							this.gridStore.load();
							this.grid = new Ext.grid.GridPanel(
									{
										id : 'DplySystemLogIndexListGridPanel',
										region : 'center',
										border : false,
										autoScroll : true,
										autoWeight : true,
										viewConfig: {
									        forceFit: false
									    },
										loadMask : true,
										stripeRows: true,
										title : '<fmt:message key="title.list" />',
										columnLines : true,
										closeable : true,
										store : this.gridStore,
										columns : [
												new Ext.grid.RowNumberer(),
												{
													header : '<fmt:message key="property.detailLogSeq" />',
													dataIndex : 'detailLogSeq',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execDate" />',
													dataIndex : 'execDate',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.appSys" />',
													dataIndex : 'appsysCode',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.stepName" />',
													dataIndex : 'stepName',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.jobName" />',
													dataIndex : 'jobName',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execServerIp" />',
													dataIndex : 'execServerIp',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.logType" />',
													dataIndex : 'logType',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '1':
															return '应用发布';
														case '2':
															return '工具箱';
														case '3':
															return '自动巡检';
														}
													}
												},
												{
													header : '<fmt:message key="property.execStatus" />',
													dataIndex : 'execStatus',
													renderer : function(value,metadata, record,rowIndex, colIndex,store) {
														switch (value) {
														case '0':
															return '正常';
														case '1':
															return '平台异常';
														case '2':
															return 'BRPM异常';
														case '3':
															return 'BSA异常';
														}
													}
												},
												{
													header : '<fmt:message key="property.execStartTime" />',
													dataIndex : 'execStartTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execCompletedTime" />',
													dataIndex : 'execCompletedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execCreatedTime" />',
													dataIndex : 'execCreatedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.execUpdatedTime" />',
													dataIndex : 'execUpdatedTime',
													sortable : true,
													width : 200
												},
												{
													header : '<fmt:message key="property.resultsPath" />',
													dataIndex : 'resultsPath',
													sortable : true,
													width : 200
												} ],
										listeners : {
											scope : this,
											// 行双击事件：打开数据查看页面
											rowdblclick : this.doView
										},
										// 定义分页工具条
										bbar : new Ext.PagingToolbar({
											store : this.gridStore,
											displayInfo : true,
											pageSize : 20
										})
									});
							// 设置基类属性
							DplySystemLogViewForm.superclass.constructor.call(this, {
								layout : 'border',
								border : false,
								monitorValid : true,
								// 定义表单组件
								items : [ this.grid ]
							});
						},
						doView : function() {
							var record = this.grid.getSelectionModel().getSelected();
							var params = {
								resultsPath : encodeURI(record.get('resultsPath')),
								logJnlNo : '${param.logJnlNo}'
							};
							if (record.get('resultsPath') != null) {
								app.loadWindow('${ctx}/${managePath}/dplysystemlog/detail',params);
							}
						}
					});
	app.window.get(0).add(new DplySystemLogViewForm());
	app.window.get(0).doLayout();
</script>


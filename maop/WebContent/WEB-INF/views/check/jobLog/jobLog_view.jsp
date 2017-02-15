<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var tc = null;
	var ac = null;
	var sg = null;
	var pc = null;
	var treeNode = null;
	var groupName = null;
	var ids = new Array();
	var cmnenvTree = null;
	var cmnenvParamGrid = null;
	var cmnenvGrid = null;
	var ParamgridStore;
	var cmnenvGroupStore = null;
	var jobName='${param.checkJobName}';
	ToolBoxCreateTestForm = Ext.extend(Ext.FormPanel,
					{
						gridform : null,
						gridStore : null,// 数据列表数据源						Panel : null,// 查询表单组件
						tree : null,// 树形组件
						treeform : null,
						tabIndex : 0,// 查询表单组件Tab键顺序						csm : null,// 数据列表选择框组件						grid : null,
						flag : true,
						tabIndex : 0,// Tab键顺序						constructor : function(cfg) {
							// 构造方法							Ext.apply(this, cfg);
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止							Ext.getDoc().on('keydown',function(e) {
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
							csmServer = new Ext.grid.CheckboxSelectionModel();
							// 实例化树形功能菜单							this.treeLoader = new Ext.tree.TreeLoader(
									{
										requestMethod : 'POST',
										dataUrl : '${ctx}/${managePath}/jobLog/queryTree',
										baseParams : {
											jobName : '${param.checkJobName}'
										}
									});
							// 定义树形组件
							cmnenvTree = new Ext.tree.TreePanel(
									{
										id : 'ServersDistributionTree_aa',
										xtype : 'treepanel',
										border : false,
										split : true,
										frame : true,
										height : 610,
										autoScroll : true,
										root : new Ext.tree.AsyncTreeNode(
												{
													text : '${param.checkJobName}',
													draggable : false,
													iconCls : 'node-root',
													id : 'TREE_ROOT_NODE'
												}),
										loader : this.treeLoader,
										// 定义树形组件监听事件
										listeners : {
											scope : this,
											load : function(n) {
												cmnenvTree.expandAll();
											},
											click : function(n) {
												if(n.leaf == true){
													var server = n.text;
													this.form.load({
														url : '${ctx}/${managePath}/jobLog/queryServerLog/${param.checkJobName}',
														method : 'GET',
														waitTitle : '<fmt:message key="message.wait" />',
														waitMsg : '<fmt:message key="message.loading" />',
														scope : this,
														params : {
															server : server
														},
														success : this.loadSuccess,
														failure : this.loadFailure
													});
												}
											}
										} 
									});
							// 实例化参数数据列表组件							this.firstPanel = new Ext.Panel(
									{
										items : [ {
											layout : 'form',
											defaults : {
												anchor : '95%'
											},
											border : true,
											labelAlign : 'center',
											items : [
													{
														xtype : 'textfield',
														fieldLabel : '作业名称',
														id : 'checkjobNameId',
														name : 'checkJobName',
														maxLength : 500,
														tabIndex : this.tabIndex++,
														readOnly : true
													},
													{
														xtype : 'textfield',
														fieldLabel : '开始时间',
														name : 'jobStartTime',
														maxLength : 200,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														fieldLabel : '结束时间',
														name : 'jobEndTime',
														maxLength : 200,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textfield',
														fieldLabel : '执行状态',
														name : 'checkJobStatus',
														maxLength : 200,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'textarea',
														fieldLabel : '详细日志',
														name : 'detailJob',
														height : 490,
														tabIndex : this.tabIndex++
													}]
										} ]
									});
							this.threePanel = new Ext.Panel(
									{
										items : [ {
											title : '日志信息',
											layout : 'form',
											autoScroll : true,
											labelAlign : 'right',
											border : true,
											items : [ {
												layout : 'column',
												items : [
														{
															columnWidth : .35,
															labelAlign : 'right',
															frame : true,
															border : true,
															items : [ cmnenvTree ]
														},
														{
															columnWidth : .65,
															border : true,
															frame : true,
															labelAlign : 'right',
															items : [ this.firstPanel ]
														} ]
											} ]
										} ],
										listeners : {
											scope : this,
											'activate' : function(panel) {
												cmnenvTree.getRootNode().reload();
												this.gridStore.reload();
											}
										}
									});
							// 设置基类属性							ToolBoxCreateTestForm.superclass.constructor.call(this,{
												labelAlign : 'right',
												buttonAlign : 'center',
												frame : true,
												autoScroll : true,
												url : '${ctx}/${managePath}/cmnenvironment/create',
												defaults : {
													anchor : '100%',
													msgTarget : 'side'
												},
												monitorValid : true,
												// 定义表单组件
												items : [this.threePanel ]
											});
							// 加载表单数据
							this.form.load({
										url : '${ctx}/${managePath}/jobLog/queryLog/${param.checkJobName}',
										method : 'GET',
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.loading" />',
										scope : this,
										success : this.loadSuccess,
										failure : this.loadFailure
									});
						},
						// 取消操作
						doCancel : function() {
							app.closeTab('add_CmnEnvironment1');
						}
					});
	var toolBoxCreateTestForm = new ToolBoxCreateTestForm();
</script>
<script>
	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_CmnEnvironment1").add(toolBoxCreateTestForm);
	// 刷新Tab页布局
	Ext.getCmp("add_CmnEnvironment1").doLayout();
</script>
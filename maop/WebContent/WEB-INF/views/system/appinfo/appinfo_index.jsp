<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//应用系统下拉菜单
var APPsysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
}); 
//系统状态

var systemStatusStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemStatus',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['statusValue','statusName'])
}); 
//自动化上线标示
var aopFlagStore = new Ext.data.ArrayStore({
    fields: ['aopFlag', 'displayField'],
    data : [ 	['0', '未上线'],
            	['1', '已上线']
            ]
});
//是  否
var yesOrNotore = new Ext.data.ArrayStore({
    fields: ['valueField', 'displayField'],
    data : [ 	['是', '是'],
            	['否', '否']
            ]
});
//上线环境
var onlineEnvStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/SYSTEM_ENVIRONMENT/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
onlineEnvStore.load();

var appCheckedRecords;
var appsyscdsAuthapply;

var gridStore;
//定义列表
AppInfoList = Ext.extend(Ext.Panel, {
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序

	csm : null,// 数据列表选择框组件

	constructor : function(cfg) {// 构造方法

		APPsysIdsStore.load();
		systemStatusStore.load();
	
		Ext.apply(this, cfg);
		// 禁止IE的backspace键(退格键)，但输入文本框时不禁止


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
		// 实例化数据列表选择框组件

		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/appInfo/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['systemcode', 'systemname', 'eapssystemname', 'englishcode', 'affectsystem', 
			          'branch', 'key', 'status', 'securitylevel', 'scope', 
			          'systempro', 'onlinedate', 'outlinedate', 'serverlevel', 'systemlevel', 
			          'isimportant', 'iskey', 'iscoresyetem', 'cbrcimportantsystem', 'applicateoperate', 
			          'outsourcingmark', 'networkdomain', 'team', 'operatemanager', 'applicatemanagerA', 
			          'applicatemanagerB', 'systemmanagerA', 'systemmanagerB', 'networkmanagerA', 'networkmanagerB', 
			          'DBA', 'middlewaremanager', 'storemanager', 'PM', 'businessdepartment', 
			          'businessmanager', 'servicesupporter', 'istestcenter', 'allottestmanager', 'deliverytestmanager', 
			          'qualitymanager', 'performancetestmanag', 'transfercoefficient', 'stage', 'businessintroduction',
			          'appsysCode', 'aopFlag', 'lastScanTime', 'deleteFlag', 'updateTime','onlineEnv','syncType','appsysName'
			          ],
			remoteSort : true,
			sortInfo : {
				field : 'systemcode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//加载数据源

		gridStore.load();
		gridStore.on('load',function(store,records,options){
			var checkedRecords = [];
			Ext.each(appCheckedRecords,function(item){
				Ext.each(records,function(record){
					if(item.get('appsysCode') == record.get('appsysCode')){
						checkedRecords.push(record);
					}
				});
			});
			Ext.getCmp('appInfoListGridPanel').getSelectionModel().selectRecords(checkedRecords);
		});
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			id : 'appInfoListGridPanel',
			region : 'center',
			border : false,
			
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(),csm, 
				{   header : '<fmt:message key="property.aopFlag" />',
					dataIndex : 'aopFlag', 
					sortable : true, 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						switch(value){
							case '0' : return '未上线';
							case '1' : return '已上线';
						}
					}
				}, 
				{
					header : '上线环境',
					dataIndex : 'onlineEnv',
					sortable : true
				},
				{
					header : 'MAOP系统编码',
					dataIndex : 'appsysCode',
					sortable : true
				},
				{
					header : 'ITSM系统编号',
					dataIndex : 'systemcode',
					sortable : true
				},
				{
					header : '系统名称',
					dataIndex : 'appsysName',
					sortable : true
				},
				{
					header : 'EAPS系统名称',
					dataIndex : 'eapssystemname',
					sortable : true
				},
				{
					header : '英文简称',
					dataIndex : 'englishcode',
					sortable : true
				},
				{
					header : '受影响系统',
					dataIndex : 'affectsystem',
					sortable : true
				},
				{
					header : '所属分行',
					dataIndex : 'branch',
					sortable : true
				},
				{
					header : '关键度',
					dataIndex : 'key',
					sortable : true
				},
				{
					header : '状态',
					dataIndex : 'status',
					sortable : true
				},
				{
					header : '安全定级',
					dataIndex : 'securitylevel',
					sortable : true
				},
				{
					header : '使用范围',
					dataIndex : 'scope',
					sortable : true
				},
				{
					header : '系统RPO',
					dataIndex : 'systempro',
					sortable : true
				},
				{
					header : '系统上线时间',
					dataIndex : 'onlinedate',
					sortable : true
				},
				{
					header : '系统下线时间',
					dataIndex : 'outlinedate',
					sortable : true
				},
				{
					header : '服务级别',
					dataIndex : 'serverlevel',
					sortable : true
				},
				{
					header : '系统级别',
					dataIndex : 'systemlevel',
					sortable : true
				},
				{
					header : '是否重要系统',
					dataIndex : 'isimportant',
					sortable : true
				},
				{
					header : '对外关键系统',
					dataIndex : 'iskey',
					sortable : true
				},
				{
					header : '是否核心重要系统',
					dataIndex : 'iscoresyetem',
					sortable : true
				},
				{
					header : '银监会报送重要系统',
					dataIndex : 'cbrcimportantsystem',
					sortable : true
				},
				{
					header : '是否应用接管',
					dataIndex : 'applicateoperate',
					sortable : true
				},
				{
					header : '应用外包参与标志',
					dataIndex : 'outsourcingmark',
					sortable : true
				},
				{
					header : '所属网络域',
					dataIndex : 'networkdomain',
					sortable : true
				},
				{
					header : '应用团队组别',
					dataIndex : 'team',
					sortable : true
				},
				{
					header : '运维经理',
					dataIndex : 'operatemanager',
					sortable : true
				},
				{
					header : '应用管理员A',
					dataIndex : 'applicatemanagerA',
					sortable : true
				},
				{
					header : '应用管理员B',
					dataIndex : 'applicatemanagerB',
					sortable : true
				},
				{
					header : '系统管理员A',
					dataIndex : 'systemmanagerA',
					sortable : true
				},
				{
					header : '系统管理员B',
					dataIndex : 'systemmanagerB',
					sortable : true
				},
				{
					header : '网络管理员A',
					dataIndex : 'networkmanagerA',
					sortable : true
				},
				{
					header : '网络管理员B',
					dataIndex : 'networkmanagerB',
					sortable : true
				},
				{
					header : 'DBA管理员',
					dataIndex : 'DBA',
					sortable : true
				},
				{
					header : '中间件管理员',
					dataIndex : 'middlewaremanager',
					sortable : true
				},
				{
					header : '存储管理员',
					dataIndex : 'storemanager',
					sortable : true
				},
				{
					header : '项目负责人',
					dataIndex : 'PM',
					sortable : true
				},
				{
					header : '业务主管部门',
					dataIndex : 'businessdepartment',
					sortable : true
				},
				{
					header : '业务负责人',
					dataIndex : 'businessmanager',
					sortable : true
				},
				{
					header : '服务支持人',
					dataIndex : 'servicesupporter',
					sortable : true
				},
				{
					header : '是否测试中心接管',
					dataIndex : 'istestcenter',
					sortable : true
				},
				{
					header : '分配测试经理',
					dataIndex : 'allottestmanager',
					sortable : true
				},
				{
					header : '交付测试经理',
					dataIndex : 'deliverytestmanager',
					sortable : true
				},
				{
					header : '质量经理',
					dataIndex : 'qualitymanager',
					sortable : true
				},
				{
					header : '性能测试经理',
					dataIndex : 'performancetestmanag',
					sortable : true
				},
				{
					header : '功能表转化系数',
					dataIndex : 'transfercoefficient',
					sortable : true
				},
				{
					header : '所处阶段',
					dataIndex : 'stage',
					sortable : true
				},
				{
					header : '业务功能介绍',
					dataIndex : 'businessintroduction',
					sortable : true
				},
				{
					header : '更新时间',
					dataIndex : 'updateTime',
					sortable : true
				},
				{
					header : '<fmt:message key="property.lastScanTime" />',
					dataIndex : 'lastScanTime',
					sortable : true
				}
	  		],
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : gridStore,
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
			id : 'appInfoFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 115,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 350,
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
						xtype : 'textfield',
						fieldLabel : '系统编号',
						name :'systemcode',
		                tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '系统名称',
						store : APPsysIdsStore,
						displayField : 'appsysName',
						valueField : 'appsysCode',
						name : 'appsysCode',
						hiddenName : 'appsysCode',
						mode: 'local',
						typeAhead: true,
					    triggerAction: 'all',
						tabIndex : this.tabIndex++,
						listeners : {
							 'beforequery' : function(e){
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
						xtype : 'combo',
						fieldLabel : '<fmt:message key="property.aopFlag" />',
						store : aopFlagStore,
						displayField : 'displayField',
						valueField : 'aopFlag',
						hiddenName :'aopFlag',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '自动化上线环境',
						store : onlineEnvStore,
						displayField : 'name',
						valueField : 'value',
						hiddenName :'onlineEnv',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '是否重要系统',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'isimportant',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '对外关键系统',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'iskey',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '是否应用接管',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'applicateoperate',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '是否核心重要系统',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'iscoresyetem',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '是否测试中心接管',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'istestcenter',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '银监会报送重要系统',
						store : yesOrNotore,
						displayField : 'displayField',
						valueField : 'valueField',
						hiddenName :'cbrcimportantsystem',
						editable: false,
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
	                    tabIndex : this.tabIndex++
					},{
						xtype : 'combo',
						fieldLabel : '状态',
						store : systemStatusStore,
						displayField : 'statusName',
						valueField : 'statusValue',
						name:'status',
						hiddenName:'status',
						mode: 'local',
						typeAhead: true,
	                    triggerAction: 'all',
						tabIndex : this.tabIndex++
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
		AppInfoList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	//同步成功
	sysSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();
			
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.successful" />!<br>'+decodeURIComponent(Ext.decode(response.responseText).error),
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					
					if(btn =='ok'){
						gridStore.load();
						var params = {
								Path : encodeURI(decodeURIComponent(Ext.decode(response.responseText).Path))
							};
						
							if ("0"!=Ext.decode(response.responseText).errNum) {
								app.loadWindow('${ctx}/${managePath}/serverssynchronous/errorlist',params);
							}
					}
				}
			});
			
		}
	},
	//同步失败
	sysFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.sys.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 查询事件
	doFind : function() {
		appCheckedRecords = [];
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	}, 	
	// 编辑事件
	doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel().getSelected();
			var systemcode = record.get('systemcode');
			if(systemcode.indexOf('>')>0){
				systemcode = systemcode.substring(systemcode.indexOf('>')+1,systemcode.indexOf('</span>'));
			}
			var params = {
				systemcode : encodeURIComponent(systemcode)
			};
			app.loadTab('APP_INFO_EDIT', '修改系统信息', '${ctx}/${managePath}/appInfo/edit', params);
		} else {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.only" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var systemcode = record.get('systemcode');
		if(systemcode.indexOf('>')>0){
			systemcode = systemcode.substring(systemcode.indexOf('>')+1,systemcode.indexOf('</span>'));
		}
		var params = {
			systemcode : systemcode
		};
		app.loadTab('APP_INFO_VIEW', '查看系统信息', '${ctx}/${managePath}/appInfo/view', params);
	},
	
	// 删除事件
	doDelete : function() {
		var grid = this.grid;
		if (grid.getSelectionModel().getCount() > 0) {
			var records = grid.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get('systemcode');
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
							timeout : 3600000, 
							url : '${ctx}/${managePath}/appInfo/delete',
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								systemcodes : ids,
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
	
	// 路书同步
	doSrb : function() {
		app.mask.show();
		Ext.Ajax.request({
			method : 'POST',
			url : '${ctx}/${managePath}/appInfo/getSyncFlagForXml',
			timeout : 1800000,
			scope : this,
			success : function(response,opts){
				app.mask.hide();
				if (Ext.decode(response.responseText).success == false) {
					var error = Ext.decode(response.responseText).error;
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
						
					});
				} else if (Ext.decode(response.responseText).success == true) {
					var respText = Ext.util.JSON.decode(response.responseText);
					var numbers = respText.synNumbers;
					if(numbers != ''){
						var nums = numbers.split('#');	
						var markNum = nums[0];
						var analyzeNum = nums[1];
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '同步文件中标识记录数：'+markNum+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;实际记录数：'+analyzeNum+'<br>确认同步？',
							buttons : Ext.MessageBox.OKCANCEL,
							icon : Ext.MessageBox.QUESTION,
							minWidth : 400,
							scope : this,
							fn : function(btn) {
								if(btn == 'ok'){
									app.mask.show();
									Ext.Ajax.request({
										url : '${ctx}/${managePath}/appInfo/importsystem',
										timeout : 1800000,
										method : 'POST',
										scope : this,
										success : this.sysSuccess,
										failure : this.sysFailure,
										disableCaching : true
									});
								}
							}
						});
					}else{
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '可同步的数据为空！',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
					}
				}
			},
			failure : function(resp,opts){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '文件解析失败！',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
		});
	},	
	
	DownFlagSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.DownFlag.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.DownFlag.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					if(btn =='ok'){
						gridStore.load(); 
					}
				}
			});
		}
	} ,
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/appInfo/app_excel.xls';
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
	// 下线设定
	doDownline : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			appCheckedRecords = this.grid.getSelectionModel().getSelections();
			var appsyscds = new Array();
			for ( var i = 0; i < appCheckedRecords.length; i++) {
				appsyscds[i] = appCheckedRecords[i].get('appsysCode');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.downflag" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(btn) {
					if(btn == 'ok'){
					app.mask.show();
					Ext.Ajax.request({
						url : '${ctx}/${managePath}/appInfo/aopdownline',
						timeout:300000,
						method : 'POST',
						scope : this,
						success : this.DownFlagSuccess,
						disableCaching : true,
						params : {
							appsyscd:appsyscds
						}
					
					});
					}
				}
			});
		}else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
		
	},
	// 上线设定
    doFlag : function() {
		if (this.grid.getSelectionModel().getCount() == 0 ) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}else if (this.grid.getSelectionModel().getCount() > 5) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.five.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}else{
			appCheckedRecords = this.grid.getSelectionModel().getSelections();
			var appsyscds = new Array();
			for ( var i = 0; i < appCheckedRecords.length; i++) {
				appsyscds[i] = appCheckedRecords[i].get('appsysCode');
			}
			var params = {
				appsyscd : encodeURIComponent(appsyscds)
			};
			app.loadWindow('${ctx}/${managePath}/appInfo/confOnlineEnvWindow', params);
		}
	},
	doAuthapply : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			appCheckedRecords = this.grid.getSelectionModel().getSelections();
			appsyscdsAuthapply = new Array();
			var aopFlag = 1;
			for ( var i = 0; i < appCheckedRecords.length; i++) {
				appsyscdsAuthapply[i] = appCheckedRecords[i].get('appsysCode');
				if(appCheckedRecords[i].get('aopFlag')=='0'){
					aopFlag = 0;
					break;
				}

			}
			var form = Ext.getCmp('systemAuthApplyForm').getForm();
			form.reset();
			
			/* form.findField('appSysCode').setValue(dplyReqRecord.get('appSysCode'));
			form.findField('requestCode').setValue(dplyReqRecord.get('requestCode'));
			form.findField('environment').setValue(dplyReqRecord.get('environment'));
			form.findField('deployCode').setValue(dplyReqRecord.get('deployCode')); */
			if(aopFlag=='0'){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '未上线的应用系统不能做权限申请！',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}else{
				systemAuthApplyWin.show();
			}
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
	// 更新成功回调
	systemAuthApplySuccess : function(form, action) {
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				var list = Ext.getCmp("MgrAppSystemInfoIndex").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				systemAuthApplyWin.hide();
			}
		});

	},
	// 更新失败回调
	systemAuthApplyFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

var appInfoList = new AppInfoList();

var systemAuthApplyWin = new Ext.Window({
	title:'<fmt:message key="button.authapply" />',
	layout:'fit',
	width:400,
	height:280,
	plain:true,
	modal : true,
	closable : true,
	resizable : false,
	draggable : true,
	closeAction : 'hide',
	items : new Ext.form.FormPanel({
	 	id:'systemAuthApplyForm',
	 	url : '${ctx}/${managePath}/appInfo/systemAuthApply',
	 	timeout : 300000,
		buttonAlign : 'center',
		labelAlign : 'right',
		lableWidth : 15,
		frame : true,
		monitorValid : true,
		defaultType:'textfield',
		items:[{
			xtype : 'checkboxgroup',
			name : 'systemAuths',
			//id : 'brpmsid',
			fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="application.systemAuth" />',
			allowBlank:false,
            items: [{
                boxLabel: '<fmt:message key="application.systemAuthDply" />',
                name: 'systemAuth',
                //id: 'systemAuthDply',
                inputValue: 3
            },{
                boxLabel: '<fmt:message key="application.systemAuthToolbox" />',
                name: 'systemAuth',
                //id: 'systemAuthToolbox',
                inputValue: 2
            },{
                boxLabel: '<fmt:message key="application.systemAuthCheck" />',
                name: 'systemAuth',
                //id: 'systemAuthCheck',
                inputValue: 1
            }]
        },{
			xtype : 'textarea',
			fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="application.application_reasons" />',
			name : 'application_reasons',
			height : 150,
			width:250,
			tabIndex : this.tabIndex++,
			allowBlank:false
		}

		
		],
		buttons : [{
			text : '<fmt:message key="button.submit" />',
			formBind : true,
			iconCls : 'button-ok',
			scope : this,
			handler : function(){
				var systemAuth = '';
				var application_reasons = '';

				Ext.getCmp('systemAuthApplyForm').getForm().submit({
					params : {
						appsyscd : appsyscdsAuthapply,
						systemAuth : systemAuth,
						application_reasons : application_reasons
					},
					success : appInfoList.systemAuthApplySuccess,
					failure : appInfoList.systemAuthApplyFailure,
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.saving" />'
				});
			}
		}]
	})
});

</script>
<sec:authorize access="hasRole('SYSTEM_APP_SYN')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-sync',
	text : '<fmt:message key="button.srb" />',
	scope : appInfoList,
	handler : appInfoList.doSrb
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYSTEM_APP_EDIT')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-edit',
	text : '<fmt:message key="button.edit" />',
	scope : appInfoList,
	handler : appInfoList.doEdit
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYSTEM_APP_DELETE')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-delete',
	text : '<fmt:message key="button.delete" />',
	scope : appInfoList,
	handler : appInfoList.doDelete
	},'-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYSTEM_AOP_FLAG')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-online',
	text : '<fmt:message key="button.flag" />',
	scope : appInfoList,
	handler : appInfoList.doFlag
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('SYSTEM_DOWN_LINE')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-online',
	text : '<fmt:message key="button.downline" />',
	scope : appInfoList,
	handler : appInfoList.doDownline
	},'-');
</script>
</sec:authorize>
<sec:authorize access="hasRole('SYSTEM_AUTH_APPLY')">
<script type="text/javascript">
appInfoList.grid.getTopToolbar().add({
	iconCls : 'button-authapply',
	text : '<fmt:message key="button.authapply" />',
	scope : appInfoList,
	handler : appInfoList.doAuthapply
	},'-');
</script>
</sec:authorize>
<script type="text/javascript">
Ext.getCmp("MgrAppSystemInfoIndex").add(appInfoList);
Ext.getCmp("MgrAppSystemInfoIndex").doLayout();
</script>

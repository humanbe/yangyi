<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//换页最大值
var pageSize = 100;
//父页面传值
var aplCode = decodeURIComponent('${param.aplCode}');
var aplName = decodeURIComponent('${param.aplName}');
var transDate = decodeURIComponent('${param.transDate}');
var transTime = decodeURIComponent('${param.transTime}');

//日报检查项运行状态
var runStatueStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/DAYRPT_RUN_STATUE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
//用户信息
var userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/appjobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});

var handleStateStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/HANDLE_STATE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
handleStateStore.load();
//定义新建表单
CheckRoportDetailForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	panel : null, // 模板页签 - 移入移出按钮
	csm : null,// 模板页签 - 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		csm = new Ext.grid.CheckboxSelectionModel();
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止		Ext.getDoc().on('keydown',function(e) {
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
		runStatueStore.load();
		userStore.load();

		this.gridStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/checkreport/getCountDetailList',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [  'APLCODE',
						'TRANSDATE',
						'TRANSTIME',
						'ANAITEM',
						'STATUS',
						'EXEANADESC',
						'ANAUSER',
						'HANDLESTATE'
					],
			remoteSort : true,
			baseParams : {
				start : 0,
				limit : pageSize,
				aplCode : aplCode,
				transDate : transDate,
				transTime : transTime
			}
		});
		this.gridStore.load();
		this.grid = new Ext.grid.GridPanel({
			height : 630 ,
			frame : true,
			autoScroll : true,
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,  //注意：不能删，否则列表前的复选框不可操作
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(),/*  csm, */
            {
				header : '分析项',
				width : 55,
				dataIndex : 'ANAITEM',
				sortable : false
			}
			,{
				header : '运行状态',
				width : 17 ,
				dataIndex : 'STATUS',
				renderer : this.runStatueStoreValue,
				scope : this,
				sortable : false
			},{
				header : '分析状态',
				width : 17 ,
				dataIndex : 'HANDLESTATE',
				renderer : this.handleStateStoreone,
				scope : this,
				sortable : false
			},{
				header : '分析说明',
				dataIndex : 'EXEANADESC',
				sortable : false
			},{
				header : '分析人',
				width : 15,
				dataIndex : 'ANAUSER',
				renderer : this.userStoreValue,
				sortable : false
			}], 
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridStore,
				displayInfo : true
			})
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
		// 设置基类属性		CheckRoportDetailForm.superclass.constructor.call(this, {
			labelAlign : 'right',
		 	labelWidth : 120, 
			buttonAlign : 'center',
			frame : true, 
			timeout : 1800000, 
			autoScroll : true,
			defaults : {
				anchor : '95%',
				msgTarget : 'side'
			}, 
			monitorValid : true,
			// 定义表单组件
		    items:[{
		    	layout:'column',
		    	bodyStyle:'padding-top:10px',
				items:[{
				     columnWidth:.5,
				     layout:'form',
				     items:[{
				    	 	xtype : 'textfield',
							fieldLabel : '系统编号',
							value : aplCode,
							readOnly : true, 
							anchor : '85%',
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							fieldLabel : '系统名称',
							value : aplName,
							readOnly : true, 
							anchor : '85%',
							tabIndex : this.tabIndex++
						}]
				},{
				     columnWidth:.5,
				     layout:'form',
				     anchor : '95%',
				     items:[{
				    	 xtype : 'textfield',
						    //style  : 'background : #F0F0F0' ,
							readOnly : true, 
							fieldLabel : '巡检日期',
							value : transDate,
							anchor : '85%',
							tabIndex : this.tabIndex++
						},{
							xtype : 'textfield',
							readOnly : true, 
							fieldLabel : '巡检时间',
							value : transTime,
							anchor : '85%',
							tabIndex : this.tabIndex++
						}]
				}]
	    	},{
				layout : 'column',
				items:[{
					columnWidth:.06
				},{
	                columnWidth:.94,
	                layout: 'form',
	                defaults: {anchor : '100%'},
	                border:false,
	                labelAlign : 'right',
	                items: [this.grid]
				}]
			}],
			// 定义按钮grid
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			}]
		})
	},
	runStatueStoreValue : function(value) {
		var index = runStatueStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return runStatueStore.getAt(index).get('name');
		}
	},
	
	handleStateStoreone :function(value) {
		var index = handleStateStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return handleStateStore.getAt(index).get('name');
		}
	},
	//显示分析人名称
	userStoreValue : function(value) {
		var index = userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return userStore.getAt(index).get('name');
		}
	},
	//关闭操作
	doClose : function() {
		app.closeTab('CHECK_REPORT_COUNT_DETAIL');
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("CHECK_REPORT_COUNT_DETAIL").add(new CheckRoportDetailForm());
// 刷新Tab页布局
Ext.getCmp("CHECK_REPORT_COUNT_DETAIL").doLayout();
</script>
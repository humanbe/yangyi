<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<script type="text/javascript">
//定义列表
var MonitorIndexList = Ext.extend(Ext.Panel, {
	id : 'monitorIndex',
	// 构造方法
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		reloadGridStore();
		MonitorIndexList.superclass.constructor.call(this, {
			layout:'form',
			border:false,
			items:[updatedChart,
                   {
					xtype : 'tabpanel',
					plain : true,
					forceLayout : true,
					autoScroll : false,
					enableTabScroll : true,
					defaults : {
						anchor : '90%'
					},
					activeTab : 0,
					deferredRender : false,
					defaults : {
						bodyStyle : 'padding:10px'
					},
					items : [
					         queueGrid ,successGrid,
					         executingGrid, failedGrid]
				}/* ,
			{
				layout : 'vbox',
				region:'center',
				border : false,
				defaults : { flex : 1 },
				layoutConfig : { align : 'stretch' },
				items : [
				 {
					layout : 'hbox',
					border : false,
					defaults : { flex : 1 },
					layoutConfig : { align : 'stretch' },
				    items:[queueGrid ,successGrid ]
				}, {
					layout : 'hbox',
					border : false,
					defaults : { flex : 1 },
					layoutConfig : { align : 'stretch' },
					items:[executingGrid, failedGrid]
				}]
			} */]
		});
	}
	// 渲染启用标志列
	/* renderEnabledColumn : function() {
		alert('0000');
			return '<span style="color: red;font-weight: bold;"><fmt:message key="common.yes" /></span>';
	} */
});
//系统-字段信息
var sysFields = Ext.data.Record.create([
	{name:'appsysName', mapping:'appsysName', type:'string'},
	{name:'requestName', mapping:'requestName', type:'string'},
	{name:'reqStatus', mapping:'reqStatus', type:'string'},
	{name:'planStartTime', mapping:'planStartTime', type:'string'},
	{name:'exeStartTime', mapping:'exeStartTime', type:'string'},
	{name:'exeCompletedTime', mapping:'exeCompletedTime', type:'string'},
	{name:'planCompletedTime', mapping:'planCompletedTime', type:'string'},
	{name:'workFinishTime', mapping:'workFinishTime', type:'string'},
	{name:'overTime', mapping:'overTime', type:'string'},
	{name:'countDown', mapping:'countDown', type:'string'},
	{name:'finsihPernect', mapping:'finsihPernect', type:'string'},
	{name:'stepRunningNum', mapping:'stepRunningNum', type:'string'}
]);

//就绪系统-列信息	
		var	syscols = [ new Ext.grid.RowNumberer(), 
		   	         {
			header : '<fmt:message key="property.requestName" />',
			dataIndex : 'requestName',
			align : 'center',
			width : 150,
			sortable : true,
			renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
			    var title = "请求名称：";
			    var tip = record.get('requestName');
			    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
			    return tip;
			}
		},{
				header : '<fmt:message key="property.appsysname" />',
				dataIndex : 'appsysName',
				align : 'center',
				width : 200,
				sortable : true
			},  {
				header : '<fmt:message key="property.planStartTime" />',
				
				dataIndex : 'planStartTime',
				align : 'center',
				width : 150,
				sortable : true
				},
				{
					header : '<fmt:message key="property.countDown" />',
					dataIndex : 'countDown',
					align : 'center',
					width : 200,
					renderer : function(value) {
						return '<span style="color: red;font-weight: bold;">'+ value +'</span>';
				    },
					sortable : true
					}];

//已成功系统-列信息

var successcols = [ new Ext.grid.RowNumberer(),
	{
		header : '<fmt:message key="property.appsysname" />',
		dataIndex : 'appsysName',
		align : 'center',
		width : 200,
		sortable : true
	}, {
		header : '<fmt:message key="property.requestName" />',
		dataIndex : 'requestName',
		align : 'center',
		width : 150,
		sortable : true,
		renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
		    var title = "请求名称：";
		    var tip = record.get('requestName');
		    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
		    return tip;
		}
	},{
		header : '<fmt:message key="property.exeStartTime" />',
		dataIndex : 'exeStartTime',
		align : 'center',
		width : 150,
		sortable : true
	}, 
	 {
		header : '<fmt:message key="property.planCompletedTime" />',
		dataIndex : 'planCompletedTime',
		align : 'center',
		width : 150,
		sortable : true
	},{
		header : '<fmt:message key="property.exeCompletedTime" />',
		dataIndex : 'exeCompletedTime',
		align : 'center',
		width : 150,
		sortable : true
	},{
		header : '<fmt:message key="property.overTime" />',
		dataIndex : 'overTime',
		align : 'center',
		renderer : function(value, metadata, record, rowIndex, colIndex, store){
			if(value == '1'){
				value = '是';
				metadata.css = 'fontStyle';
			}else{
				value = '否';
			}
			return value;
    	}
	}];
//执行中系统-列信息var execols = [ new Ext.grid.RowNumberer(),
	 {
		header : '<fmt:message key="property.requestName" />',
		dataIndex : 'requestName',
		align : 'center',
		width : 100,
		sortable : true,
		renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
		    var title = "请求名称：";
		    var tip = record.get('requestName');
		    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
		    return tip;
		}
	}, {
		header : '<fmt:message key="property.appsysname" />',
		dataIndex : 'appsysName',
		align : 'center',
		width : 200,
		sortable : true
	},{
		header : '完成占比',
		dataIndex : 'finsihPernect',
		align : 'center',
		width : 100,
		sortable : true
	}, {
		header : '步骤名称',
		dataIndex : 'reqStatus',
		align : 'center',
		width : 150,
		sortable : true,
		renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
		    var title = "步骤名称：";
		    var tip = record.get('reqStatus');
		    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
		    return tip;
		}
	}, {
		header : '步骤并发数',
		dataIndex : 'stepRunningNum',
		align : 'center',
		width : 100,
		sortable : true
	}, {
		header : '<fmt:message key="property.exeStartTime" />',
		dataIndex : 'exeStartTime',
		align : 'center',
		width : 100,
		sortable : true
	}, {
		header : '<fmt:message key="property.planCompletedTime" />',
		dataIndex : 'planCompletedTime',
		align : 'center',
		width : 100,
		sortable : true
	} ,{
		header : '<fmt:message key="property.overTime" />',
		dataIndex : 'overTime',
		align : 'center',
		renderer : function(value, metadata, record, rowIndex, colIndex, store){
			if(value == '1'){
				value = '是';
				metadata.css = 'fontStyle';
			}else{
				value = '否';
			}
			return value;
    	}
	} ];
//失败的系统-列信息var failedcols = [ new Ext.grid.RowNumberer(),
	 {
		header : '<fmt:message key="property.requestName" />',
		dataIndex : 'requestName',
		align : 'center',
		width : 100,
		sortable : true,
		renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
		    var title = "请求名称：";
		    var tip = record.get('requestName');
		    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
		    return tip;
		}
	},{
		header : '<fmt:message key="property.appsysname" />',
		dataIndex : 'appsysName',
		align : 'center',
		width : 200,
		sortable : true
	},{
		header : '步骤名称',
		dataIndex : 'reqStatus',
		align : 'center',
		width : 150,
		sortable : true,
		renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
		    var title = "步骤名称：";
		    var tip = record.get('reqStatus');
		    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
		    return tip;
		}
	},
	{
		header : '<fmt:message key="property.exeStartTime" />',
		dataIndex : 'exeStartTime',
		align : 'center',
		width : 100,
		sortable : true
	}];
//已就绪系统数据源
var waitingStore = new Ext.data.JsonStore({
	proxy : new Ext.data.HttpProxy({
		method : 'POST',
		timeout : 600000,
		url : '${ctx}/${appPath}/monitor/findReadySysByReqStatus',
		disableCaching : true
	}),
	autoDestroy : true,
	root : 'data',
	fields : sysFields,
	remoteSort : true,
	baseParams : {
		reqStatus : 2
	}
});
//正在执行的系统的数据源var executingStore = new Ext.data.JsonStore({
	proxy : new Ext.data.HttpProxy( {
		method : 'POST',
		timeout : 600000,
		url : '${ctx}/${appPath}/monitor/findExeSysByExecStatus',
		disableCaching : true
	}),
	autoDestroy : true,
	root : 'data',
	fields : sysFields,
	remoteSort : true,
	baseParams : {
		reqStatus : 3
	}
}); 
//已完成的系统的数据源
var finishedStore = new Ext.data.JsonStore({
	proxy : new Ext.data.HttpProxy( {
		method : 'POST',
		timeout : 600000,
		url : '${ctx}/${appPath}/monitor/findSuccessSysByExecStatus',
		disableCaching : true
	}),
	autoDestroy : true,
	root : 'data',
	fields : sysFields,
	remoteSort : true,
	baseParams : {
		reqStatus : 7
	}
}); 
//已失败的系统的数据源
 var failedStore = new Ext.data.JsonStore({
	proxy : new Ext.data.HttpProxy( {
		method : 'POST',
		timeout : 600000,
		url : '${ctx}/${appPath}/monitor/findfailedSysByExecStatus',
		disableCaching : true
	}),
	autoDestroy : true,
	root : 'data',
	fields : sysFields,
	remoteSort : true,
	baseParams : {
		reqStatus : 4
	}
}); 
//对应当前Grid, 弹出系统的任务步骤窗口时使用
var currentGrid;
//系统执行状态, 弹出系统的任务步骤窗口时使用
var executeStatus;
//已就绪的系统表格
var queueGrid = new Ext.grid.GridPanel({
	id : 'queueListGridPanel',
	stripeRows: true,
	border : false,
	enableHdMenu  : false,
	height :500,
	bodyStyle: 'background:grey; padding:0 1px 0 0;',
	store : waitingStore,
	columns : syscols,
	title :'<fmt:message key="property.system.queue"/>',
	listeners : {
		'click' : function(){
			currentGrid = queueGrid;
			reqStatus = 2;
		}
	}
});
//已完成的系统表格
 var successGrid = new Ext.grid.GridPanel({
	id : 'successListGridPanel',
	stripeRows: true,
	border : false,
	enableHdMenu  : false,
	height :500,
	store : finishedStore,
	columns : successcols,
	title :'<fmt:message key="property.system.success"/>',
	listeners : {
		'click' : function(){
			currentGrid = successGrid;
			reqStatus = 7;
		}
	}
}); 
//正在执行的系统表格var executingGrid = new Ext.grid.GridPanel({
	id : 'executingListGridPanel',
	stripeRows: true,
	border : false,
	enableHdMenu  : false,
	height :500,
	bodyStyle: 'background:grey; padding:0 1px 0 0;',
	store : executingStore,
	columns : execols,
	title :'<fmt:message key="property.system.executing"/>',
	listeners : {
		'click' : function(){
			currentGrid = executingGrid;
			reqStatus = 3;
		}
	}
}); 
//已失败的系统表格
var failedGrid = new Ext.grid.GridPanel({
	id : 'failedListGridPanel',
	stripeRows: true,
	border : false,
	enableHdMenu  : false,
	height :500,
	store : failedStore,
	columns : failedcols,
	title :'<fmt:message key="property.system.failed"/>',
	listeners : {
		'click' : function(){
			currentGrid = failedGrid;
			reqStatus = 5;
		}
	}
});
//系统进度仪表盘var sysGage = new JustGage({
	    id: "sysGage", 
	    value: 0, 
	    min: 0,
	    max: waitingStore.getCount(),
	    title: '<fmt:message key="property.process.system"/>',
	    label: "%"
	  });
//任务进度仪表盘 var taskGage = new JustGage({
    id: "taskGage", 
    value: 0, 
    min: 0,
    max: 100,
    title: '<fmt:message key="property.process.job"/>',
    label: "%"
   
  }); 
//步骤进度仪表盘 
var stepGage = new JustGage({
    id: "stepGage", 
    value: 0,
    min: 0,
    max: 100,
    title: '<fmt:message key="property.process.step"/>',
    label: "%"
  });
//仪表盘面板var updatedChart = new Ext.Panel({
	id:'updatedChart',
	split: true,
	region:'north',
    height: 260,
    minSize: 260,
    maxSize: 260,
    contentEl : 'meterMonitor',
    collapsible: true,
    //collapsed: true,
    margins: '0 0 0 0'
});
//任务执行器var runner = new Ext.util.TaskRunner();
//延迟任务函数
var delayFn = new Ext.util.DelayedTask();
taskRunner.stopAll();
//定时更新仪表盘任务var updateProcessTask = {
		run : function(){
			GenerateProcess.run(
					'${ctx}/${appPath}/monitor/findSuccessSysByExecStatus?date=' + new Date(), 
					function(){
					},
					function(){
						reloadGridStore();
					}
			);
		},
		interval : 60000
};
//表格数据更新器function reloadGridStore(){
	waitingStore.reload();
	executingStore.reload();
	finishedStore.reload();
	failedStore.reload(); 
}
//更新进度条仪表盘等的数据请求器var GenerateProcess = function(){
	return {
		run : function(url,resume,cb){
			Ext.Ajax.request({
				url : url,
				scope : this,
				method : 'POST',
				timeout : 600000,
				disableCaching : true,
				success : function(response, options){
					var obj = Ext.decode(response.responseText);
					 if (obj.success == true) {
						 var sysPercent = obj.sysFinishNums/obj.sysWhole;
						 var requestPercent = obj.requestFinishNums/obj.requestWhole;
						 var stepPercent = obj.stepFinishNums/obj.stepWhole;
						 
						 sysGage.refresh(Math.round(100*(sysPercent)));
						 taskGage.refresh(Math.round(100*(requestPercent)));
						 stepGage.refresh(Math.round(100*(stepPercent)));
						
						  document.getElementById("marquee_schedule").innerHTML = '系统进度：计划发布系统<span style="color: red;font-weight: bold;">'+obj.sysWhole+'</span>个 '+'已完成系统<span style="color: red;font-weight: bold;">'+obj.sysFinishNums+'</span>个 '+'正在执行系统<span style="color: red;font-weight: bold;">'+obj.runAppnum+'</span>个 ';
						  /* if(obj.sysFinishNums == obj.sysWhole || obj.execCount == 0){
							 (function(){
								 sysGage.refresh(0);
								 taskGage.refresh(0);
								 stepGage.refresh(0);
							 }).defer(1000);
						 }    */
							cb();
					 }
				},
				failure: function(){  
				    Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="error.request.failed"/>',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					}); 
				} 
			});
			
		}
	};
}();
Ext.getCmp("REQ_SCHEDULE").add(new MonitorIndexList());
Ext.getCmp("REQ_SCHEDULE").doLayout();
taskRunner.start(updateProcessTask);	
Ext.getCmp("REQ_SCHEDULE").on('destroy', function(){
	if(updateProcessTask){
		taskRunner.stop(updateProcessTask);
	}
});

</script>

<div id="meterMonitor">
 <%--<marquee id="marquee_schedule" hspace=180 width=600  style="border:0px dotted #CC0066" scrollamount=3 ></marquee> --%>
	<h1 id="marquee_schedule" align="center"></h1>
	<div id="sysGage" style="width:300px;height:220px;margin: 1em;float:left;border: 1px soild #202020;box-shadow: 0px 0px 15px #101010;border-radius: 8px;"></div>
    <div id="taskGage" style="width:300px; height:220px;margin: 1em;float:left;border: 1px soild #202020;box-shadow: 0px 0px 15px #101010;border-radius: 8px;"></div>
    <div id="stepGage" style="width:300px; height:220px;margin: 1em;float:left;border: 1px soild #202020;box-shadow: 0px 0px 15px #101010;border-radius: 8px;"></div>
    <div id="container" style="width: 150px; height: 220px; margin: 0 auto"></div>
</div>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var delButNumOnce = 100 ; //删除按钮序号 - 一次
var delButNumDaily = 100 ; //删除按钮序号 - 每天
var delButNumMonthly = 100 ; //删除按钮序号 - 每月

var panelOne = null ;
var panelTwo = null ;
var panelThree = null ;
var panelFour = null ;
var panelFive = null ;
var serverPanel = null ;
var gridServer = null ;
var treeServer = null ;
//优先级和邮件配置
var priority = '' ;
var emailList = '' ;
var emailSuccess = '' ;
var emailFailure = '' ;
var emailCancel = '' ;
var jobId = '${param.jobid}';
//时间表处理   一次
var responseDataOnce = null; 
//时间表处理   每天
var responseDataDaily = null;
//时间表处理   每周
var responseDataWeekly = null;
//时间表处理   每月
var responseDataMonthly = null;
//时间表处理   时间间隔
var responseDataInterval = null;

var commonCheck = 'COMMON_CHECK'; // BSA通用模板目录名称
var serverRootName = 'ALLSERVERS' ; //服务器目录树根节点名称
var commonJobAppSys = 'COMMON'; //常规作业对应的应用系统

//组件列表字段信息
var fieldsServer = Ext.data.Record.create([
	{name: 'group_path', mapping : 'group_path', type : 'string'}, 
	{name: 'group_name', mapping : 'group_name', type : 'string'}
]);
//模板列表字段信息
var fieldsTemplate = Ext.data.Record.create([
	{name: 'template_group', mapping : 'template_group', type : 'string'}, 
	{name: 'template_name', mapping : 'template_name', type : 'string'}
]);
 
//定于通知邮件列表输入类型
Ext.apply(Ext.form.VTypes, {
    emailList:  function(v) {
    	if(v != ''){
    		var isemail = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    		var num = 0;
    		var vlist = v.split(';');
    		var listSize = vlist.length ;
    		for(var i=0 ; i<listSize ; i++){
    			if(isemail.test(vlist[i])){
    				num++ ;
    			}
    		}
    		return (num == listSize);
    	}
    	return true;
    },
	emailListText: '<fmt:message key="job.mailError" />!'
});

//作业时间表   一次
var fieldset1 = new Ext.form.FieldSet({
     // labelAlign: 'top',
	 title: '',
     autoHeight:true,
     // defaults: {width: 700}, 
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
			xtype:'checkbox',
			fieldLabel: '',
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.timer_once" />',
			name: 'exec_freq_type',
			id: 'type_once_edit',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_edit',
         items: [{
			xtype:'datefield',
			format:'y-m-d',
			id:'once_date_edit',
			minValue : new Date(),
			fieldLabel:'<fmt:message key="job.timer_date" />',
			editable : false,
			value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
			anchor:'88%'
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
	 	labelWidth:40,
	 	id : 'once_times_edit' ,
        items: [{
			xtype:'timefield',
			anchor:'97%',
			id : 'once_time_edit' ,
			fieldLabel:'<fmt:message key="job.timer_time" />',
			format:'H:i:s',
			maxValue:'23:59 PM',
			minValue:'0:00 AM',
			value : new Date().format('Y-m-d H:i:s').substring(11) ,
			increment:30  //间隔30分钟
		}]
    },{   //增加
        columnWidth:.1,
        layout: 'form',
		labelWidth:20,
		id : 'buttons_edit_once',
        items: [{
				xtype:'button',
				iconCls : 'row-add',
	  			text:'<fmt:message key="job.add" />',
	  			height : 20 ,
	  			listeners:{
	  				click:function(){
	  					delButNumOnce++ ;
	  					//增加日期序号列
	  					var df = new Ext.form.DateField({
		  					format:'y-m-d',
		  					fieldLabel: '<fmt:message key="job.timer_date" />',
		  					id:'once_date_edit_'+delButNumOnce,
		  					editable : false ,
		  					minValue : new Date(),
		  					value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
		  					anchor:'88%'
	  					});
	  					Ext.getCmp('once_dates_edit').items.add(delButNumOnce,df);
	  					Ext.getCmp('once_dates_edit').doLayout(); 
	  					
	  					//增加时间列	  					var tf = new Ext.form.TimeField({
		  			  		anchor:'97%',
		  					id:'once_time_edit_'+delButNumOnce,
		  					fieldLabel:'<fmt:message key="job.timer_time" />',
		  					format:'H:i:s',
		  					maxValue:'23:59 PM',
		  					minValue:'0:00 AM',
		  					value : new Date().format('Y-m-d H:i:s').substring(11) ,
		  					increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('once_times_edit').items.add(delButNumOnce,tf);
	  					Ext.getCmp('once_times_edit').doLayout(); 
	  					
	  					//增加删除按钮列	  					var bt = new Ext.Button({
	  						iconCls : 'row-delete',
	  						text:'<fmt:message key="button.delete" />',
	  						height : 20 ,
	  						id : 'buttons_edit_once_'+delButNumOnce,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(18);
	  								Ext.getCmp('once_dates_edit').remove(size);
	  			  					Ext.getCmp('once_dates_edit').doLayout(); 
		  			  				Ext.getCmp('once_times_edit').remove(size);
	  			  					Ext.getCmp('once_times_edit').doLayout(); 
	  			  					Ext.getCmp('buttons_edit_once').remove(size);
	  			  					Ext.getCmp('buttons_edit_once').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_edit_once').items.add(delButNumOnce,bt);
	  					Ext.getCmp('buttons_edit_once').doLayout(); 
	  				}
	  			}
		  }]
	}]
}); 

//作业时间表   每天
var fieldset2 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    layout:'column',
    items:[{
        columnWidth:.15,
        layout: 'form',
		labelWidth:25,
        items: [{
			xtype:'checkbox',
			fieldLabel: '',
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.timer_daily" />',
			name: 'exec_freq_type',
			id: 'type_daily_edit',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_edit' ,
        items: [{
			xtype:'timefield',
  			anchor:'98%',
  			id : 'daily_time_edit' ,
  			fieldLabel:'<fmt:message key="job.timer_time" />',
  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
  			format:'H:i:s',
  			maxValue:'23:59 PM',
  			minValue:'0:00 AM',
  			increment:30  //间隔30分钟
		  }]
	},{ //增加
        columnWidth:.25,
        layout: 'form',
		labelWidth:20,
		id : 'buttons_edit_daily',
        items: [{
				xtype:'button',
				iconCls : 'row-add',
	  			text:'<fmt:message key="job.add" />',
	  			height : 20 ,
	  			listeners:{
	  				click:function(){
	  					delButNumDaily++ ;
	  					//增加时间列
	  					var tdTime = new Ext.form.TimeField({
	  						anchor:'98%',
	  			  			id:'daily_time_edit_'+delButNumDaily,
	  			  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			  			format:'H:i:s',
	  			  			maxValue:'23:59 PM',
	  			  			minValue:'0:00 AM',
	  			  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			  			increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('daily_times_edit').items.add(delButNumDaily,tdTime);
	  					Ext.getCmp('daily_times_edit').doLayout(); 
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						iconCls : 'row-delete',
	  						text:'<fmt:message key="button.delete" />',
	  						height : 20 ,
	  						id : 'buttons_edit__daily_'+delButNumDaily,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(20);
	  								Ext.getCmp('daily_times_edit').remove(size);
	  			  					Ext.getCmp('daily_times_edit').doLayout(); 
	  			  					Ext.getCmp('buttons_edit_daily').remove(size);
	  			  					Ext.getCmp('buttons_edit_daily').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_edit_daily').items.add(delButNumDaily,bt);
	  					Ext.getCmp('buttons_edit_daily').doLayout(); 
	  				}
	  			}
		  }]
	}]
});

//作业时间表   每周
var fieldset3 = new Ext.form.FieldSet({
	 title: '',
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
				xtype:'checkbox',
				fieldLabel: '',
				labelSeparator: '',
				boxLabel: '<fmt:message key="job.timer.weekly" />',
				name: 'exec_freq_type',
				id:'type_weekly_edit',
				inputValue: '3'
			}]
      },{
    	  columnWidth:.4,
    	  layout: 'form',
 		  labelWidth:60,
          items: [{
        		anchor:'88%',
				xtype:'spinnerfield',
				fieldLabel: '<fmt:message key="job.interval_weeks" />',
				name: 'interval_weeks',
				id : 'interval_weeks_edit' ,
				minValue : 1 ,
				maxValue : 52 ,
				value : 1 
		  }]
	  },{
          layout: 'form',
          columnWidth:.45,
 		  labelWidth:40,
          items: [{
        	 	xtype:'timefield',
	  			anchor:'75%',
	  			id : 'weekly_time_edit' ,
	  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			format:'H:i:s',
	  			maxValue:'23:59 PM',
	  			minValue:'0:00 AM',
	  			increment:30  //间隔30分钟
		}]
 	 }]
});

//作业时间表   每周-星期
var fieldsetWeeks = new Ext.form.FieldSet({
	 id : 'weeks_edit' ,
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.12,
         layout: 'form',
		 labelWidth:100,
         items: []
 	},{
         columnWidth:.88,
         layout: 'form',
		 labelWidth:165,
         items: [{
				xtype: 'checkboxgroup',
				id: 'checkboxgroup',
	         	fieldLabel: '<fmt:message key="job.days_in" />',
	         	anchor:'85%',
	         	items: [
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_edit'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_edit' },
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_edit'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_edit'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_edit'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_edit'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_edit'}
		        ]
		}]
 	}]
}); 

//作业时间表   每月
var fieldset4 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    layout:'column',
    items:[{
        columnWidth:.15,
        layout: 'form',
		labelWidth:25,
        items: [{
			xtype:'checkbox',
			fieldLabel: '',
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.monthly" />',
			name: 'exec_freq_type',
			id:'type_monthly_edit',
			inputValue: '4'
		}]
    },{
        columnWidth:.4,
        layout: 'form',
		labelWidth:60,
        items: [{
        	xtype:'spinnerfield',
        	anchor:'88%',
        	name: 'month_day',
        	id : 'month_day_edit' ,
			fieldLabel: '<fmt:message key="job.day_sort" />',
			minValue : 1 ,
			maxValue : 31 ,
			value : 1 
		  }]
	},{
        columnWidth:.45,
        layout: 'form',
		labelWidth:40,
        items: [{
        	xtype:'timefield',
			anchor:'75%',
			id : 'monthly_time_edit' ,
			fieldLabel:'<fmt:message key="job.timer_time" />',
			value : new Date().format('Y-m-d H:i:s').substring(11) ,
			format:'H:i:s',
			maxValue:'23:59 PM',
			minValue:'0:00 AM',
			increment:30  //间隔30分钟
		}]
    }]
});

//作业时间表   时间间隔
var fieldset5 = new Ext.form.FieldSet({
	 title: '',
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
			xtype:'checkbox',
			fieldLabel: '',
			//labelSeparator: '',
			boxLabel: '<fmt:message key="job.interval" />',
			name: 'exec_freq_type',
			id:'type_interval_edit',
			inputValue: '5'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
         items: [{
			xtype:'datefield',
			format:'y-m-d',
			minValue : new Date(),
			fieldLabel: '<fmt:message key="job.timer_date" />',
			value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
			id : 'interval_date_edit' ,
			editable : false,
			anchor:'88%'
		  }]
	},{
         columnWidth:.45,
         layout: 'form',
		 labelWidth:40,
         items: [{
        	xtype:'timefield',
 			anchor:'75%',
 			id : 'interval_time_edit' ,
 			fieldLabel:'<fmt:message key="job.timer_time" />',
 			value : new Date().format('Y-m-d H:i:s').substring(11) ,
 			format:'H:i:s',
 			maxValue:'23:59 PM',
 			minValue:'0:00 AM',
 			increment:30  //间隔30分钟
		}]
     }]
}); 

//作业时间表   时间间隔-重复间隔
var fieldsetInervalGaps = new Ext.form.FieldSet({
	 title: '',
	 id : 'interval_gap_edit' ,
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.22,
         layout: 'form',
		 labelWidth:300,
         items: []
 	},{
         columnWidth:.6,
         layout: 'form',
         items: [{
        	 xtype: 'spinnerfield',	
        	 anchor : '70%',
        	 fieldLabel: '<fmt:message key="job.repeat_day" /> &nbsp;&nbsp;&nbsp;<fmt:message key="job.days" />',
        	 name : 'interval_days',
        	 id : 'interval_day_edit',
        	 minValue : 0 ,
        	 maxValue : 365 ,
        	 value : 0 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_edit',
	       	 minValue : 0 ,
	       	 maxValue : 24 ,
	       	 value : 1
	     },{
	       	 xtype: 'spinnerfield',
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_edit',
	       	 minValue : 0 ,
	       	 maxValue : 59 ,
	       	 value : 0 
	     }]
 	}]
});

//作业时间表   时区
var fieldset6 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    labelWidth:100,
    items:[{
			xtype:'combo',
			fieldLabel: '时区',
			name: 'timezoneSelect',
			anchor:'95%'
		  }]
});

//作业时间表   优先级var fieldset7 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    labelWidth:80,
    items: [{
		xtype: 'radiogroup',
     	fieldLabel: '<fmt:message key="job.priority" />&nbsp;&nbsp;',
     	anchor:'55%',
     	id : 'jobDesign_priorrity_edit',
     	items: [
     	       {boxLabel: '<fmt:message key="job.lowest" />', name: 'exec_priority', id: 'LOWEST_edit', inputValue: 'LOWEST'},
               {boxLabel: '<fmt:message key="job.low" />', name: 'exec_priority', id: 'LOW_edit', inputValue: 'LOW'},
               {boxLabel: '<fmt:message key="job.normal" />', name: 'exec_priority', id: 'NORMAL_edit', inputValue: 'NORMAL'},
               {boxLabel: '<fmt:message key="job.high" />', name: 'exec_priority', id: 'HIGH_edit', inputValue: 'HIGH'},
               {boxLabel: '<fmt:message key="job.critical" />', name: 'exec_priority', id: 'CRITICAL_edit', inputValue: 'CRITICAL'}
         ]
	}]
}); 

//获取下拉菜单数据
var checkTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var authorizeLevelTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_AUTHORIZE_LEVEL_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var fieldTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/CHECK_FIELD_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var toolStatusStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/JOB_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var frontlineFlagStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/JOB_FRONTLINE_FLAG/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var authorizeFlagStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/JOB_AUTHORIZE_FLAG/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
var appsysStore = new Ext.data.Store({
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

JobDesignEditForm = Ext.extend(Ext.FormPanel, {
	PanelServer : null, // 组件页签 - 表单组件
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
	
	PanelTemplate : null, // 模板页签 - 表单组件
    gridTemplate :null,   // 列表组件 - 列表组件
	treeTemplate : null,  // 树形组件 - 树形组件
	
	csmServer : null,  // 组件页签 - 数据列表选择框组件	csmTemplate : null,// 模板页签 - 数据列表选择框组件	csmMovedServers : null,
	csmMoveServers : null,
	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
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
		csmServer = new Ext.grid.CheckboxSelectionModel();
		csmTemplate = new Ext.grid.CheckboxSelectionModel();
		csmMovedServers = new Ext.grid.CheckboxSelectionModel();
		csmMoveServers = new Ext.grid.CheckboxSelectionModel();
		//serverStore.load();
		checkTypeStore.load();
		authorizeLevelTypeStore.load();
		fieldTypeStore.load();
		toolStatusStore.load();
		frontlineFlagStore.load();
		authorizeFlagStore.load();
		appsysStore.load();
		
		// 定义组件页签左侧树形组件------------------------------------begin
		this.treeServerLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/jobdesign/getServerTreeForEdit'
		}); 
		treeServer = new Ext.tree.TreePanel({
			id : 'serverTree_edit',
			title : "<fmt:message key="job.select" /><fmt:message key="job.servers" />",
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : serverRootName,
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_SERVER_edit'
			}),
			loader : this.treeServerLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 treeServer.expandAll();  //展开所有节点					 /* treeServer.root.expand();  //展开根节点 */
					 if(!treeServer.root.hasChildNodes()){
						 Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.job.serverIsNull" />',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.INFO
							});
					 }else{
						 //设定grid中的智能组信息
						 var serverInfos = new Array();
						 treeServer.root.eachChild(function(typeNode) {
							typeNode.eachChild(function(serverNode){
								serverInfos.push(new fieldsServer({group_path:'/'+serverRootName+'/'+typeNode.text,group_name:serverNode.text}));
							});
						 });
				    	 if(gridServer.store.getCount()!=0){
							gridServer.store.removeAll();
							gridServer.store.add(serverInfos);
				    	 }else{
				    		gridServer.store.add(serverInfos);
	    		    	 }  
					 }
				 }
			}
		});
		// 定义组件页签树形组件----------------------------------------end
	
		// 定义组件页签右侧列表组件--------------------------------------begin
		this.gridServerStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getJobServer/${param.jobid}',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'appsys_code', 
						'job_code', 
						'server_path',
						'server_name'
					],
			remoteSort : true,
			sortInfo : {
				field : 'server_name',
				direction : 'ASC'
			},
			baseParams : {
				/* start : 0,
				limit : 20 */
			}
		});
		this.gridServerStore.load();
		gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid_edit',
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.servers" />',
			region : 'center',
			border : false,
			columnLines : true,
			autoScroll : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridServerStore,
			autoExpandColumn : 'name',
			sm : csmServer,  //注意：不能删，否则列表前的复选框不可操作
			columns : [ new Ext.grid.RowNumberer(), /* csmServer, */
            {
				header : '智能组名称',
				dataIndex : 'group_name'
			},{
				header : '智能组路径',
				dataIndex : 'group_path'

			}]/* ,
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridServerStore,
				displayInfo : true,
				pageSize : 20
			}) */
		}); 
		// 定义组件页签右侧列表组件--------------------------------------end
		
		// 定义模板页签左侧树形组件----------------------------------------begin
		this.treeTemplateLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/jobdesign/getTemplateTreeForEdit'
		});
		this.treeTemplate = new Ext.tree.TreePanel({
			id : 'templateTree_edit',
			title : "<fmt:message key='job.select' /><fmt:message key='job.template' />",
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.template" />',
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_TEMPLATE_edit'
			}),
			loader : this.treeTemplateLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.treeTemplate.expandAll();  //展开所有节点 
					 /* this.treeTemplate.root.expand();  //展开根节点 */
					 if(!this.treeTemplate.root.hasChildNodes()){
						 Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.job.templateIsNull" />',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.INFO
							});
					 }
				 },
				 'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode_1 = node.parentNode; //分组目录
				              if(pNode_1 == this.treeTemplate.getRootNode()) return;
				              if(checked){
					             var cb_1 = pNode_1.ui.checkbox; 
					             if(cb_1){
						         	cb_1.checked = checked; 
						         	cb_1.defaultChecked = checked; 
						     	}
					             pNode_1.attributes.checked=checked;
					          }else{
						    	var _miss=false; 
						     	for(var i=0;i<pNode_1.childNodes.length;i++){
							  		if(pNode_1.childNodes[i].attributes.checked!=checked){
								 		_miss=true;
							    	}
						      	}
								if(!_miss){
									pNode_1.ui.toggleCheck(checked); 
									pNode_1.attributes.checked=checked; 
						     	}
						  	}
				            // 应用系统目录/COMMON_CHECK目录
				            if (pNode_1.parentNode != null) {
					            var pNode_2 = pNode_1.parentNode; 
					            if(pNode_2 == this.treeTemplate.getRootNode()) return;
					            if(checked){
						            var cb_2 = pNode_2.ui.checkbox; 
						            if(cb_2){
							         	cb_2.checked = checked; 
							         	cb_2.defaultChecked = checked; 
							     	}
						            pNode_2.attributes.checked=checked;
						        }else{
							    	var _miss=false; 
							     	for(var i=0;i<pNode_2.childNodes.length;i++){
								  		if(pNode_2.childNodes[i].attributes.checked!=checked){
									 		_miss=true;
								    	}
							      	}
									if(!_miss){
										pNode_2.ui.toggleCheck(checked); 
										pNode_2.attributes.checked=checked; 
							     	}
							  } 
					          // CHECK目录
					          if (pNode_2.parentNode != null) {
						            var pNode_3 = pNode_2.parentNode; 
						            if(pNode_3 == this.treeTemplate.getRootNode()) return;
						            if(checked){
							            var cb_3 = pNode_3.ui.checkbox; 
							            if(cb_3){
								         	cb_3.checked = checked; 
								         	cb_3.defaultChecked = checked; 
								     	}
							            pNode_3.attributes.checked=checked;
							        }else{
								    	var _miss=false; 
								     	for(var i=0;i<pNode_3.childNodes.length;i++){
									  		if(pNode_3.childNodes[i].attributes.checked!=checked){
										 		_miss=true;
									    	}
								      	}
										if(!_miss){
											pNode_3.ui.toggleCheck(checked); 
											pNode_3.attributes.checked=checked; 
								     	}
								    }
							   }  
						   } 
					   }
				 }
			}
		});
		// 定义模板页签树形组件----------------------------------------end
		
		// 定义模板页签的中间移入移出按钮---------------------------begin
		this.PanelTemplate = new Ext.Panel({
			id : 'templatePanel_edit',
			width : '12%',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			split : true,
			xtype:'button',
            layout: {
            	type:'vbox',
            	padding:'10',
            	pack:'center',
            	align:'center' 
            },
        	defaults:{margins:'0 0 10 0'},
            items:[{
                 xtype:'button',
                 width : 40 ,
                 height : 25 ,
                 text: '<fmt:message key="job.movein" />>>',
                 scope : this,
     			 handler : this.templateShiftIn
             },{
                 xtype:'button',
                 width : 40 ,
                 height : 25 ,
                 text: '<<<fmt:message key="job.moveout" /> ',
                 scope : this,
                 handler : this.templateShiftOut
             }]
		});
		// 定义模板页签的中间移入移出按钮---------------------------end
		
		// 定义模板页签右侧列表组件--------------------------------------begin
		this.gridTemplateStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getJobTemplate/${param.jobid}',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'appsys_code', 
						'job_code', 
						'template_group',
						'template_name'
					],
			remoteSort : true,
			/* sortInfo : {
				field : 'tamplate_name',
				direction : 'ASC'
			}, */
			baseParams : {
				/* start : 0,
				limit : 1 */
			}
		});
		this.gridTemplateStore.load();
		this.gridTemplate = new Ext.grid.GridPanel({
			id : 'templateGrid_edit',
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.template" />',
			region : 'center',
			border : false,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridTemplateStore,
			autoExpandColumn : 'name',
			sm : csmTemplate,  //注意：不能删，否则列表前的复选框不可操作
			columns : [ new Ext.grid.RowNumberer(), csmTemplate, 
            {
				header : '<fmt:message key="job.template" /><fmt:message key="job.name" />',
				dataIndex : 'template_name'
			},{
				header : '<fmt:message key="job.template" /><fmt:message key="job.path" />',
				dataIndex : 'template_group'
			}],
			/* // 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridTemplateStore,
				displayInfo : true,
				pageSize : 1
			}), */
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = this.gridTemplateStore.getAt(rowIndex);
					this.gridTemplate.store.remove(curRow);
				}
			}
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
		//各个页签
		panelOne = new Ext.Panel({  
			title:'<fmt:message key="job" /><fmt:message key="job.define" />',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:110px;padding-top:40px'},
            iconCls : 'menu-node-change',
            items:[{
                columnWidth:.85,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
                items: [{
                    xtype : 'textfield',
					fieldLabel : '巡检对象',
					style  : 'background : #F0F0F0' , 
				    id : 'server_target_typeID_edit',
					name : 'server_target_type',
					hiddenName : 'server_target_type',
					readOnly : true ,
					setValue : function(value){
						switch(value){
							case '0': this.setRawValue('服务器');break;
							case '1': this.setRawValue('智能组');break;
						}
					},
					tabIndex : this.tabIndex++ 
				},{
                    xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.appsys_code" />',
				    id : 'jobdesign_appsysCode_edit',
					hidden : true , 
					name : 'appsys_code',
					hiddenName : 'appsys_code',
					tabIndex : this.tabIndex++ 
				},{
					xtype : 'combo',
					style  : 'background : #F0F0F0' ,
					fieldLabel : '<fmt:message key="job.authorize" />',
					valueField : 'value',
					displayField : 'name',
					name : 'authorize_lever_type',
					hiddenName : 'authorize_lever_type' ,
					id : "jobDesign_authorize_lever_type_edit",
					store : authorizeLevelTypeStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					readOnly : true ,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(obj) {
							var val = obj.getValue() ;
							if('1'==val){ //常规巡检
								//Ext.getCmp('jobDesign_frontline_flag_edit').el.up('.x-form-item').setDisplayed(false);
								//Ext.getCmp('jobDesign_frontline_flag_edit').setValue("0");
								Ext.getCmp('jobdesign_appsysCode_edit').setValue(commonJobAppSys);
							}
							if('2'==val){
								//Ext.getCmp('jobDesign_frontline_flag_edit').el.up('.x-form-item').setDisplayed(true);
								//Ext.getCmp('jobDesign_frontline_flag_edit').readOnly=false;
								Ext.getCmp('jobdesign_appsysCode_edit').setValue(commonJobAppSys);
							}
						}
					}
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.code_jeda" />',
					name : 'job_code',
					id : 'jobCode_edit' ,
					tabIndex : this.tabIndex++,
					hidden : true
				},{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' ,
					readOnly : true,
					fieldLabel : '<fmt:message key="job" /><fmt:message key="job.name" />',
					name : 'job_name',
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.type" />',
					valueField : 'value',
					displayField : 'name',
					name : 'check_type',
					id : 'jobDesign_checkType_edit',
					hiddenName : 'check_type' ,
					store : checkTypeStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="job.field" />',
					valueField : 'value',
					displayField : 'name',
					name : 'field_type',
					hiddenName : 'field_type' ,
					id : 'jobDesign_fieldType_edit' ,
					store : fieldTypeStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="job.desc" />',
					name : 'job_desc',
					id : 'jobDesign_jobDesc_edit',
					height : 60,
					maxLength : 100 ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.status" />',
					valueField : 'value',
					displayField : 'name',
					name : 'tool_status',
					hiddenName : 'tool_status' ,
					store : toolStatusStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					hidden : true ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.frontline_flag" />',
					valueField : 'value',
					displayField : 'name',
					name : 'frontline_flag',
					id : 'jobDesign_frontline_flag_edit',
					hiddenName : 'frontline_flag',
					store : frontlineFlagStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					hidden : true ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.authorize_flag" />',
					valueField : 'value',
					displayField : 'name',
					name : 'authorize_flag',
					hiddenName : 'authorize_flag' ,
					store : authorizeFlagStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					hidden : true,
					editable : true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					id : 'jobDesign_creatorId_edit',
					tabIndex : this.tabIndex++,
					hidden : true,
					readOnly : true
				},{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					id : 'jobDesign_creatorName_edit',
					tabIndex : this.tabIndex++,
					readOnly : true
				},
				{
					xtype : 'textfield',
					fieldLabel : 'IPs',
					hidden : true, 
					id : 'servers_edit',
					name : 'servers'
				},{
					xtype : 'textfield',
					fieldLabel : 'templates',
					hidden : true, 
					id : 'templates_edit',
					name : 'templates'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerOnceVals_edit'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerDailyVals_edit'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerWeeklyVals_edit'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerMonthlyVals_edit'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerIntervalVals_edit'
				}]
            }]
	    });  
	    panelTwo = new Ext.Panel({  
	    	title : '<fmt:message key="job.template" />',
            layout : 'hbox',
			region:'center',
			border : false,
			defaults : { flex : 1 },
			layoutConfig : { align : 'stretch' },
			items : [this.treeTemplate,this.PanelTemplate, this.gridTemplate],
            listeners : {
				scope : this,
				'activate' : function(panel) {
					var treeTemplateRoot = Ext.getCmp("templateTree_edit").getRootNode();
					this.treeTemplateLoader.baseParams.fieldType = Ext.getCmp('jobDesign_fieldType_edit').getValue();
					this.treeTemplateLoader.baseParams.jobCode = Ext.getCmp('jobCode_edit').getValue();
					//重新加载树形菜单
					treeTemplateRoot.reload();
					//完全展开树形菜单
					Ext.getCmp("templateTree_edit").root.expand();
				}
			}
	    });  
	    panelThree = new Ext.Panel({  
	    	title : '<fmt:message key="job.servers" />',
	    	layout : 'hbox',
			region:'center',
			border : false,
			defaults : { flex : 1 },
			layoutConfig : { align : 'stretch' },
			items : [treeServer,gridServer],
			listeners : {
				scope : this,
				'activate' : function(panel) {
					//清除智能组信息
					if(gridServer.store.getCount()!=0){
						gridServer.store.removeAll();
			    	}
					var storeTemplate = this.gridTemplate.getStore();
		    		var jsonTemplate = [];
		    		storeTemplate.each(function(item) {
		    			jsonTemplate.push(item.data);
		    		});
					var treeRoot = Ext.getCmp("serverTree_edit").getRootNode();
					this.treeServerLoader.baseParams.templates =  Ext.util.JSON.encode(jsonTemplate);
					this.treeServerLoader.baseParams.fieldType = Ext.getCmp('jobDesign_fieldType_edit').getValue();
					//重新加载树形菜单
					treeRoot.reload();
					//完全展开树形菜单
					Ext.getCmp("serverTree_edit").root.expand();
				}
			}
	    }); 
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    // 定义左侧可选服务器组件--------------------------------------begin
		this.jobDesignServerStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getServer',
				disableCaching : false
			}),
		    autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'serverName','bsaAgentFlag','floatingIp','deleteFlag','osType','appsysCode', 'serverIp' ],
				pruneModifiedRecords : true,
				sortInfo : {
					field : 'osType',
					direction : 'ASC'
				},
				remoteSort : true,
				baseParams : {
					start : 0,
					limit : 20,
					osType :'',
					serverIp: ''
				}
		});
		
		this.jobDesignMoveServers = new Ext.grid.GridPanel({
			id : 'jobDesignMoveServersGridEdit',
			height : 250 ,
			loadMask : true,
			frame : true,
			title : '<fmt:message key="toolbox.selectable_server" />',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			/* hideHeaders:true,  */
			store : this.jobDesignServerStore,
			autoExpandColumn : 'name',
			sm : csmMovedServers,   
			columns : [csmMovedServers,  
            {
				header : '操作系统类型',
				dataIndex : 'osType',
				sortable : true
			},{
				header : '系统代码',
				dataIndex : 'appsysCode',
				sortable : true
			},{
				header : '<fmt:message key="toolbox.server_ip" />',
				dataIndex : 'serverIp',
				sortable : true
			}],
			
			
			// 定义数据列表监听事件
			listeners : { 
				scope : this,
				// 行双击移入事件

				rowdblclick : function(row,rowIndex,e){
					var curRow = this.jobDesignServerStore.getAt(rowIndex);
					var osType = curRow.get("osType");
					var appsysCode = curRow.get("appsysCode");
					var serverIp = curRow.get("serverIp");
					var notEqualFlag = true;
					this.jobDesignExcgridMovedServers.getStore().each(function(rightRecord){
						if(osType==rightRecord.data.osType && appsysCode==rightRecord.data.appsysCode
								&& serverIp==rightRecord.data.serverIp){
							notEqualFlag = false;
						}
					},this);
					if(notEqualFlag){
						this.jobDesignExcgridMovedServers.store.add(curRow);
					}
					
				} 
			},
			tbar : new Ext.Toolbar( {
				items : [  '-',{
					xtype : 'textfield',
					width:200,
					fieldLabel : '<fmt:message key="property.serverIp" />',
					id : 'serverIpId',
					name : 'Ip',
					emptyText : '服务器IP',
					tabIndex : this.tabIndex++
					},'-',{
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
		this.Panel = new Ext.Panel({
			//id : 'serverPanel',
			height : 250 ,
			width : '12%',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			split : true,
			defaults:{margins:'0 0 10 0'},
			xtype:'button',
	        layout: {
	        	type:'vbox',
	        	padding:'10',
	        	pack:'center',
	        	align:'center' 
	        },
	        
	        items:[{
	             xtype:'button',
	             width : 40 ,
	             height : 25 ,
	             text: '<fmt:message key="toolbox.shift_in" />',
	             scope : this ,
	 			 handler : this.serverShiftIn 
	         },{
	             xtype:'button',
	             width : 40 ,
	             height : 25 ,
	             text: '<fmt:message key="toolbox.shift_out" />',
	             scope : this ,
	             handler : this.serverShiftOut 
	         }]
		});
		// 定义中间移入移出按钮------------------------------------------end
		
		// 定义组件页签右侧列表组件--------------------------------------begin
		this.gridMovedServersStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getCheckedServer/${param.jobid}',
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
		this.jobDesignExcgridMovedServers = new Ext.grid.GridPanel({
			id : 'jobDesignExcgridMovedServersGridEdit',
			height : 250,
			loadMask : true,
			frame : true,
			title :'<fmt:message key="toolbox.selected_server" />',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			/* hideHeaders:true,  */
			store : this.gridMovedServersStore,
			autoExpandColumn : 'name',
			sm : csmMoveServers, 
			columns : [csmMoveServers, 
			           {
				header : '操作系统类型',
				dataIndex : 'osType',
				sortable : true
			},{
				header : '系统代码',
				dataIndex : 'appsysCode',
				sortable : true
			},{
				header : '<fmt:message key="toolbox.server_ip" />',
				dataIndex : 'serverIp',
				sortable : true
			}],
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = this.gridMovedServersStore.getAt(rowIndex);
					this.jobDesignExcgridMovedServers.store.remove(curRow);
				}
			}
		}); 
		// 定义组件页签右侧列表组件--------------------------------------end
		    serverPanel = new Ext.Panel({  
		    	title : '服务器',
	            layout : 'hbox',
				region:'center',
				border : false,
				defaults : { flex : 1 },
				layoutConfig : { align : 'stretch' },
				items : [this.jobDesignMoveServers,this.Panel,this.jobDesignExcgridMovedServers]
		    });  
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    panelFour = new Ext.Panel({ 
	    	title:'<fmt:message key="job.timer" />',
        	id:'jobDesign_timer_edit',
            autoScroll : true , 
            border:false,
            frame : true,
            iconCls : 'menu-node-change',
            layout: 'form',
            bodyStyle : 'padding : 0, 30px, 0, 30px;',
            defaults: {anchor:'97.5%'},
            border:false,
            labelAlign : 'right',
            items: [ fieldset1, fieldset2,{
                	layout:'column',
                 	xtype: 'fieldset',
  			        title: '',
  	                autoHeight: true,
  	                defaults: {
  	                    columnWidth: 1,
  	                    border: false
  	                },         
  			        items: [fieldset3,fieldsetWeeks]
                },   fieldset4,{
                	layout:'column',
                 	xtype: 'fieldset',
  			        title: '',
  	                autoHeight: true,
  	                defaults: {
  	                    columnWidth: 1,
  	                    border: false
  	                },         
  			        items: [fieldset5,fieldsetInervalGaps]
                },fieldset7 
		    ]           
	    });
		/* panelFive = new Ext.Panel({ 
			title:'<fmt:message key="job.notify_conf" />',
        	id:'jobDesign_mailConf_edit',
            layout:'form', 
            autoScroll : true , 
            labelAlign : 'right',
            defaults:{bodyStyle:'padding-top:10px'}, 
            iconCls : 'menu-node-trouble',
            border:false,
            items: [{
            	layout:'column',
             	xtype: 'fieldset',
		        title: '<fmt:message key="job.run_notice" />',
                autoHeight: true,
                defaults: {
                    columnWidth: 1,
                    border: false
                },         
		        items: [{
		        	layout:'column', 
					items:[{
						columnWidth : .08 , 
						items : [{ 
							xtype : 'label'
					    }]
					},{
						columnWidth : .92 , 
						layout : 'form',
						items: [{
			                xtype : 'textfield',
			                vtype : 'emailList',  
			                compare : 'emailListText',
			                anchor : '90%',
			                fieldLabel: '<fmt:message key="job.mail_list" />',
			             	maxLength : 1000,
			                name: 'exec_notice_mail_list',
			                id:'jobDesign_mail_list_edit'
			            }, {
			            	xtype: 'checkbox',
			                fieldLabel: '<fmt:message key="job.status_val" />',
			                boxLabel: '<fmt:message key="job.success" />',
			                inputValue : '2',
			                id:'mail_success_edit',
			                name: 'mail_success_flag'
			            }, {
			            	xtype: 'checkbox',
			                fieldLabel: '',
			                labelSeparator: '',
			                boxLabel: '<fmt:message key="job.failure" />',
			                inputValue : '4',
			                id:'mail_failure_edit',
			                name: 'mail_failure_flag'
			            }, {
			            	xtype: 'checkbox',
			                fieldLabel: '',
			                labelSeparator: '',
			                boxLabel: '<fmt:message key="job.cancel" />',
			                inputValue : '8',
			                id:'mail_cancel_edit',
			                name: 'mail_cancel_flag'
			            }]
					}]
		        }]
            }]
	    }); */
		
		var i = 0;   //面板序号
	    function cardHandler(direction) {  
	        if (direction == -1) {  
	            i--;  
	            if (i < 0) {  
	                i = 0;  
	            }  
	        }  
	        if (direction == 1) {  
	            i++;  
	            if (i > 3) {  
	                i = 3;  
	                return false;  
	            }  
	        }  
	        var btnPrev = Ext.getCmp("jobDesign_movePrev_edit");  
	        var btnSave = Ext.getCmp("jobDesign_moveSave_edit");  
	        var btnNext = Ext.getCmp("jobDesign_moveNext_edit");  
	        if (i == 0) { 
	            btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.disable(); 
	        }  
	        if(i == 1){
				if (Ext.getCmp('jobDesign_checkType_edit').getValue() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobType.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var jobDesc = Ext.getCmp('jobDesign_jobDesc_edit').getValue();
				if (jobDesc.length>100) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobDesc.overlength" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				var authorizeLeverType = Ext.getCmp('jobDesign_authorize_lever_type_edit').getValue() ;
				if (authorizeLeverType == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.authorizeLever.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if(Ext.getCmp('server_target_typeID_edit').getValue()=='服务器'){
					Ext.getCmp('jobDesign_cardPanel_edit').items.add(2,serverPanel);
  					Ext.getCmp('jobDesign_cardPanel_edit').doLayout(); 
				}
			 	if(Ext.getCmp('server_target_typeID_edit').getValue()=='智能组'){
					Ext.getCmp('jobDesign_cardPanel_edit').items.add(2,panelThree);
  					Ext.getCmp('jobDesign_cardPanel_edit').doLayout(); 
				} 
			 	
				if(authorizeLeverType == '1'){ //常规巡巡检
					Ext.getCmp('jobDesign_cardPanel_edit').items.add(3,panelFour);
					//Ext.getCmp('jobDesign_cardPanel_edit').items.add(4,panelFive);
  					Ext.getCmp('jobDesign_cardPanel_edit').doLayout(); 
				}
				if(authorizeLeverType == '2'){ //临时巡巡检
					Ext.getCmp('jobDesign_cardPanel_edit').items.remove(3);
					//Ext.getCmp('jobDesign_cardPanel_edit').items.remove(4);
  					Ext.getCmp('jobDesign_cardPanel_edit').doLayout(); 
				}
				btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.enable(); 
	        }
	        if(i == 2){
	        	var flagTemplate = false ; //模板不为空标志	    		var storeTemplate = this.gridTemplate.getStore();
	    		var jsonTemplate = [];
	    		storeTemplate.each(function(item) {
	    			jsonTemplate.push(item.data);
	    		});
	    		if(jsonTemplate!=null && jsonTemplate.length>0){
	    			Ext.getCmp("templates_edit").setValue( Ext.util.JSON.encode(jsonTemplate));
	    			flagTemplate = true ;
	    		}
	    		if(!flagTemplate){
	    			Ext.Msg.show( {
	    				title : '<fmt:message key="message.title" />',
	    				msg : '<fmt:message key="job.select_please" /><fmt:message key="job.template" />!',
	    				buttons : Ext.MessageBox.OK,
	    				icon : Ext.MessageBox.INFO,
	    				minWidth : 200
	    			}); 
	    			return i = 1;
	    		}
	    		
	    		var storeTemplate1 = this.gridTemplate.getStore();
	    		var jsonTemplate1 = [];
	    		storeTemplate1.each(function(item) {
	    			jsonTemplate1.push(item.data.template_name);
	    		});
				this.jobDesignServerStore.baseParams.osType =  Ext.util.JSON.encode(jsonTemplate1);
    			this.jobDesignServerStore.reload();  
    			this.gridMovedServersStore.load();
	    		
	    		
	    		var authorizeLeverType = Ext.getCmp('jobDesign_authorize_lever_type_edit').getValue() ;
	    		if(authorizeLeverType == '1'){ //常规巡检
	    			btnSave.hide();  
		            btnNext.enable();  
		            btnPrev.enable();
	    		}else{ //临时巡检
	    			btnSave.show();  
		            btnNext.disable();   
		            btnPrev.enable();
	    		}
	        }
	        if(i == 3){
	        	var flagServer = false ; //组件不为空标志	    		var storeServer = gridServer.getStore();
	    		var jsonServer = [];
	    		if(Ext.getCmp('server_target_typeID_edit').getValue()=='服务器'){
	    			this.gridMovedServersStore.each(function(item) {
		    			jsonServer.push(item.data);
		    		});
		    		if(jsonServer!=null && jsonServer.length>0){
		    			Ext.getCmp("servers_edit").setValue( Ext.util.JSON.encode(jsonServer));
		    			flagServer = true ;
		    		}
		    		if(!flagServer){
		    			Ext.Msg.show( {
		    				title : '<fmt:message key="message.title" />',
		    				msg : '<fmt:message key="job.select_please" /><fmt:message key="job.servers" />!',
		    				buttons : Ext.MessageBox.OK,
		    				icon : Ext.MessageBox.INFO,
		    				minWidth : 200
		    			}); 
		    			return i = 2;
		    		} 
	    		}
	    		
	    		
	    		if(Ext.getCmp('server_target_typeID_edit').getValue()=='智能组'){
		    		storeServer.each(function(item) {
		    			jsonServer.push(item.data);
		    		});
		    		if(jsonServer!=null && jsonServer.length>0){
		    			Ext.getCmp("servers_edit").setValue( Ext.util.JSON.encode(jsonServer));
		    			flagServer = true ;
		    		}
		    		if(!flagServer){
		    			Ext.Msg.show( {
		    				title : '<fmt:message key="message.title" />',
		    				msg : '<fmt:message key="job.select_please" /><fmt:message key="job.servers" />!',
		    				buttons : Ext.MessageBox.OK,
		    				icon : Ext.MessageBox.INFO,
		    				minWidth : 200
		    			}); 
		    			return i = 2;
		    		}
	    		}
	    		btnSave.show();  
	            btnNext.disable();  
	            btnPrev.enable();
	        }
	        this.cardPanel.getLayout().setActiveItem(i);  
	    };  
		//CARD总面板  
		this.cardPanel = new Ext.Panel({
			id : 'jobDesign_cardPanel_edit',
			renderTo : document.body,
			height : 700,
			width : 600,
			layout : 'card',
			layoutConfig : {
				deferredRender : true
			},
			activeItem : 0,
			tbar : ['-',{
						id : 'jobDesign_movePrev_edit',
						iconCls : 'button-previous',
						text : '<fmt:message key="job.stepBefore" />',
						disabled : true ,
						handler : cardHandler.createDelegate(this,[ -1 ])
					},'-',{
						id : 'jobDesign_moveSave_edit',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						hidden : true,
						handler : this.doSave
					},'-',{
						id : 'jobDesign_moveNext_edit',
						iconCls : 'button-next',
						text : '<fmt:message key="job.stepNext" />',
						handler : cardHandler.createDelegate(this, [ 1 ])
					} ],
			items : [panelOne,panelTwo/* ,panelThree */]
		});
		
		// 设置基类属性		JobDesignEditForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180 ,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/jobdesign/edit/${param.jobid}',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [{
				layout : 'fit',
				items :[this.cardPanel] 
			}]
		});

		// 加载表单数据
		this.load( {
			url : '${ctx}/${appPath}/jobdesign/view/${param.jobid}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			success : this.loadSuccess,
			failure : this.loadFailure
		});
	},
	
	//模板移入事件
	templateShiftIn : function() {
    	var nodes = this.treeTemplate.getChecked();
    	var templateInfos = new Array();
    	for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){
				var par = nodes[t].parentNode;
				var grandPar = nodes[t].parentNode.parentNode;
				var path = "/"+grandPar.text+"/"+par.text;
				if(grandPar.text!=commonCheck){
					var up = grandPar.parentNode;
					path = "/"+ up.text + path;
				}
		    	templateInfos.push(new fieldsTemplate({template_group:path,template_name:nodes[t].text}));
			}
    	}
    	if(this.gridTemplate.store.getCount()!=0){
			this.gridTemplate.store.removeAll();
			this.gridTemplate.store.add(templateInfos);
    	}else{
    		this.gridTemplate.store.add(templateInfos);
    	}
	},
	//模板移出事件
	templateShiftOut : function() {
		var records = this.gridTemplate.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			this.gridTemplate.store.remove(records[i]);
		}
	},
	
	// 取消操作
	doCancel : function() {
		app.closeTab('JOB_DESIGN_EDIT');
	},
	
	// 保存操作
	doSave : function() {
		var authorizeLeverType = Ext.getCmp('jobDesign_authorize_lever_type_edit').getValue() ;
		if(authorizeLeverType == '1'){ //常规巡巡检
			var arrayOnce = [] ;  //时间表参数数组(多参数间用&连接) 一次
    		var arrayDaily = [] ; //时间表参数数组(多参数间用&连接) 每天
    		var arrayWeekly = [] ;
    		var arrayMonthly = [] ;
    		var arrayInterval = [] ;
   			var currentTime = new Date().format('Y-m-d H:i:s');
   			currentTime = currentTime.replace(/-/g, '').replace(/ /g, '').replace(/:/g, '') ;
   			var execDateTime = '' ;
   			var execDate = '' ;
   			var execTime = '' ;
   			var freqFlag = false ;
   			var once = Ext.getCmp('type_once_edit').getValue();
   			var	daily = Ext.getCmp('type_daily_edit').getValue();
   			var	weekly = Ext.getCmp('type_weekly_edit').getValue();		
   			var	monthly = Ext.getCmp('type_monthly_edit').getValue();
   			var	interval = Ext.getCmp('type_interval_edit').getValue();
   			if(once){
   				freqFlag = true ;
   				if(Ext.getCmp('once_date_edit').getValue() != ''){
   					execDate = Ext.getCmp('once_date_edit').getValue().format('Y-m-d');
   				}
   				if(execDate == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					}); 
   					return false ;
   				}
   				execTime = Ext.getCmp('once_time_edit').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空，请输入合法的时间

   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				execDateTime = execDate.replace(/-/g, '')+ execTime.replace(/:/g, '') ;
   				if(execDateTime-currentTime < 0){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeOver" />!', //执行时间不能早于当前时间
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				arrayOnce.push(execDate+" "+execTime);
   				//插入增加时间表数据
   				for(var t=0 ; t<=delButNumOnce ; t++){
   					var addDateValue = '';
   					var addTimeValue = '';
   					if(Ext.getCmp('once_date_edit_'+t)){
   						addDateValue = Ext.getCmp('once_date_edit_'+t).getValue().format('Y-m-d');
   					}
   					if(Ext.getCmp('once_time_edit_'+t)){
   						addTimeValue = Ext.getCmp('once_time_edit_'+t).getValue();
   						if(addTimeValue != ''){
   							execDateTime = addDateValue.replace(/-/g, '')+ addTimeValue.replace(/:/g, '') ;
   							if(execDateTime-currentTime < 0){
   								Ext.Msg.show( {
   									title : '<fmt:message key="message.title" />',
   									msg : '<fmt:message key="job.timeOver" />!', //执行时间不能早于当前时间
   									buttons : Ext.MessageBox.OK,
   									icon : Ext.MessageBox.INFO,
   									minWidth : 200
   								});
   								return false ;
   							}
   							arrayOnce.push(addDateValue+" "+addTimeValue);
   						}else{
   							Ext.Msg.show( {
   								title : '<fmt:message key="message.title" />',
   								msg : '<fmt:message key="job.timeError" />!', //时间不能为空，请输入合法的时间

   								buttons : Ext.MessageBox.OK,
   								icon : Ext.MessageBox.INFO,
   								minWidth : 200
   							});
   							return false ; 
   						}
   					}
   				}
   			}
   			if(daily){
   				freqFlag = true ;
   				execTime = Ext.getCmp('daily_time_edit').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				var dateValue = new Date().format('Y-m-d') ;
   				arrayDaily.push(dateValue+' '+execTime);
   				//插入增加时间表数据
   				for(var t=0 ; t<=delButNumDaily ; t++){
   					if(Ext.getCmp('daily_time_edit_'+t)){
   						var addValue = Ext.getCmp('daily_time_edit_'+t).getValue();
   						if(addValue != ''){
   							arrayDaily.push(dateValue+' '+addValue);
   						}else{
   							Ext.Msg.show( {
   								title : '<fmt:message key="message.title" />',
   								msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   								buttons : Ext.MessageBox.OK,
   								icon : Ext.MessageBox.INFO,
   								minWidth : 200
   							});
   							return false ;
   						}
   					}
   				}
   			}
   			if(weekly){
   				freqFlag = true ;
   				execTime = Ext.getCmp('weekly_time_edit').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				var daysOfWeek = Ext.getCmp('interval_weeks_edit').getValue() ; //周间隔数
   				var mon = Ext.getCmp('mon_edit').getValue();
   				var tus = Ext.getCmp('tus_edit').getValue();
   				var wen = Ext.getCmp('wen_edit').getValue();
   				var thu = Ext.getCmp('thu_edit').getValue();
   				var fri = Ext.getCmp('fri_edit').getValue();
   				var sat = Ext.getCmp('sat_edit').getValue();
   				var sun = Ext.getCmp('sun_edit').getValue();
   				if(!mon && !tus && !wen && !thu && !fri && !sat && !sun){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.execWeekNull" />!', //请勾选每周的执行星期
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				var weekFreq = 0 ; //执行频率
   				if(mon){
   					weekFreq = weekFreq +2 ;
   				}
   				if(tus){
   					weekFreq = weekFreq +4 ;
   				}
   				if(wen){
   					weekFreq = weekFreq +8 ;
   				}
   				if(thu){
   					weekFreq = weekFreq +16 ;
   				}
   				if(fri){
   					weekFreq = weekFreq +32 ;
   				}
   				if(sat){
   					weekFreq = weekFreq +64 ;
   				}
   				if(sun){
   					weekFreq = weekFreq +1 ;
   				}
   				arrayWeekly.push(new Date().format('Y-m-d')+' '+execTime+'&'+daysOfWeek+'&'+weekFreq);
   			}
   			if(monthly){
   				freqFlag = true ;
   				if(Ext.getCmp('monthly_time_edit')){
   					execTime = Ext.getCmp('monthly_time_edit').getValue() ;
   				}
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				var daysOfMonth = Ext.getCmp('month_day_edit').getValue() ;
   				arrayMonthly.push(new Date().format('Y-m-d')+' '+execTime+'&'+daysOfMonth);
   			}
   			if(interval){
   				freqFlag = true ;
   				if(Ext.getCmp('interval_date_edit').getValue() != ''){
   					execDate = Ext.getCmp('interval_date_edit').getValue().format('Y-m-d');
   				}
   				if(execDate == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				execTime = Ext.getCmp('interval_time_edit').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				execDateTime = execDate.replace(/-/g, '')+ execTime.replace(/:/g, '') ;
   				if(execDateTime-currentTime < 0){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeOver" />!', //执行时间不能早于当前时间
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false ;
   				}
   				var days = Ext.getCmp('interval_day_edit').getValue();
   				var hours = Ext.getCmp('interval_hour_edit').getValue();
   				var mins = Ext.getCmp('interval_min_edit').getValue();
   				arrayInterval.push(execDate+' '+execTime+'&'+days+'&'+hours+'&'+mins);
   			}
   	        if(!freqFlag){
   	        	Ext.Msg.show( {
   					title : '<fmt:message key="message.title" />',
   					msg : '<fmt:message key="job.execFreqNull" />!',
   					buttons : Ext.MessageBox.OK,
   					icon : Ext.MessageBox.INFO,
   					minWidth : 200
   				});
   				return false ;
   	        }
   	        //优先级
			var lowest = Ext.getCmp('LOWEST_edit').getValue();
			var low = Ext.getCmp('LOW_edit').getValue();
			var normal = Ext.getCmp('NORMAL_edit').getValue();
			var high = Ext.getCmp('HIGH_edit').getValue();
			var critical = Ext.getCmp('CRITICAL_edit').getValue();
			if(!lowest && !low && !normal && !high && !critical){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="job.priorityNull" />!', //请选择优先级
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					minWidth : 200
				});
				return false ;
			}
    		Ext.getCmp("timerOnceVals_edit").setValue(arrayOnce);
    		Ext.getCmp("timerDailyVals_edit").setValue(arrayDaily);
    		Ext.getCmp("timerWeeklyVals_edit").setValue(arrayWeekly);
    		Ext.getCmp("timerMonthlyVals_edit").setValue(arrayMonthly);
    		Ext.getCmp("timerIntervalVals_edit").setValue(arrayInterval);
		}else{
			var flagServer = false ; //组件不为空标志			var storeServer = gridServer.getStore();
			var jsonServer = [];
			if(Ext.getCmp('server_target_typeID_edit').getValue()=='服务器'){
				Ext.getCmp('jobDesignExcgridMovedServersGridEdit').getStore().each(function(item) {
	    			jsonServer.push(item.data);
	    		});
	    		if(jsonServer!=null && jsonServer.length>0){
	    			Ext.getCmp("servers_edit").setValue( Ext.util.JSON.encode(jsonServer));
	    			flagServer = true ;
	    		}
	    		if(!flagServer){
	    			Ext.Msg.show( {
	    				title : '<fmt:message key="message.title" />',
	    				msg : '<fmt:message key="job.select_please" /><fmt:message key="job.servers" />!',
	    				buttons : Ext.MessageBox.OK,
	    				icon : Ext.MessageBox.INFO,
	    				minWidth : 200
	    			}); 
	    			return i = 2;
	    		}
			}
			if(Ext.getCmp('server_target_typeID_edit').getValue()=='智能组'){
				storeServer.each(function(item) {
					jsonServer.push(item.data);
				});
				if(jsonServer!=null && jsonServer.length>0){
					Ext.getCmp("servers_edit").setValue( Ext.util.JSON.encode(jsonServer));
					flagServer = true ;
				}
				if(!flagServer){
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="job.select_please" /><fmt:message key="job.servers" />!',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return false ;
				}
			}
		}
		//提交表单
		jdef.getForm().submit({
			scope : jdef,
			timeout : 1800000, //半小时
			success : jdef.saveSuccess,
			failure : jdef.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				app.closeTab('JOB_DESIGN_EDIT');
				var list = Ext.getCmp("JOB_DESIGN_INDEX").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				app.loadTab('JOB_DESIGN_INDEX', '<fmt:message key="sysjob" />', '${ctx}/${appPath}/jobdesign/index');
			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	
	// 数据加载成功回调
	loadSuccess : function(form, action) {
		var type = Ext.getCmp('jobDesign_authorize_lever_type_edit').getValue();
		if(type=='1'){
			Ext.getCmp('jobDesign_frontline_flag_edit').el.up('.x-form-item').setDisplayed(false);
			Ext.getCmp('jobDesign_frontline_flag_edit').setValue("0");
		}
		//一次		responseDataOnce = action.result.dataOnce; 
		//每天
		responseDataDaily = action.result.dataDaily;
		//每周
		responseDataWeekly = action.result.dataWeekly;
		//每月
		responseDataMonthly = action.result.dataMonthly;
		//时间间隔
		responseDataInterval = action.result.dataInterval;
		//时间表处理   一次		var sizeOnce = responseDataOnce.length ;
		if(sizeOnce>0){
			Ext.getCmp('type_once_edit').setValue(1) ;
			Ext.getCmp('once_date_edit').setValue(responseDataOnce[0]['exec_start_date']);
			Ext.getCmp('once_time_edit').setValue(responseDataOnce[0]['exec_start_time']);
			priority = responseDataOnce[0]['exec_priority'];
			emailList = responseDataOnce[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataOnce[0]['mail_success_flag']; 
			emailFailure = responseDataOnce[0]['mail_failure_flag']; 
			emailCancel = responseDataOnce[0]['mail_cancel_flag']; 
		}
		if(sizeOnce > 1){
			for(var t=1 ; t<responseDataOnce.length ; t++){
				delButNumOnce++ ;
				//增加日期序号列
				var df = new Ext.form.DateField({
 					format:'y-m-d',
 					fieldLabel: '<fmt:message key="job.timer_date" />',
 					id:'once_date_edit_'+delButNumOnce,
 					editable : false ,
 					minValue : new Date(),
 					value : responseDataOnce[t]['exec_start_date'] ,
 					anchor:'88%'
				});
				Ext.getCmp('once_dates_edit').items.add(delButNumOnce,df);
				Ext.getCmp('once_dates_edit').doLayout(); 
				//增加时间列
				var tf = new Ext.form.TimeField({
 			  		anchor:'97%',
 					id:'once_time_edit_'+delButNumOnce,
 					fieldLabel:'<fmt:message key="job.timer_time" />',
 					format:'H:i:s',
 					maxValue:'23:59 PM',
 					minValue:'0:00 AM',
 					value : responseDataOnce[t]['exec_start_time'] ,
 					increment:30  //间隔30分钟
				});
				Ext.getCmp('once_times_edit').items.add(delButNumOnce,tf);
				Ext.getCmp('once_times_edit').doLayout(); 
				//增加删除按钮列
				var bt = new Ext.Button({
					iconCls : 'row-delete',
					text:'<fmt:message key="button.delete" />',
					height : 20 ,
					id : 'buttons_edit_once_'+delButNumOnce,
					style : 'margin-top:5px',
					listeners:{
						click:function(bt){
							var size = bt.getId().substring(18);
							Ext.getCmp('once_dates_edit').remove(size);
		  					Ext.getCmp('once_dates_edit').doLayout(); 
 			  				Ext.getCmp('once_times_edit').remove(size);
		  					Ext.getCmp('once_times_edit').doLayout(); 
		  					Ext.getCmp('buttons_edit_once').remove(size);
		  					Ext.getCmp('buttons_edit_once').doLayout();
						}
					}
				});
				Ext.getCmp('buttons_edit_once').items.add(delButNumOnce,bt);
				Ext.getCmp('buttons_edit_once').doLayout(); 
			}
		}
		//时间表处理   每天
		var sizeDaily = responseDataDaily.length ;
		if(sizeDaily>0){
			Ext.getCmp('type_daily_edit').setValue(1) ;
			Ext.getCmp('daily_time_edit').setValue(responseDataDaily[0]['exec_start_time']);
			priority = responseDataDaily[0]['exec_priority'];
			emailList = responseDataDaily[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataDaily[0]['mail_success_flag']; 
			emailFailure = responseDataDaily[0]['mail_failure_flag']; 
			emailCancel = responseDataDaily[0]['mail_cancel_flag']; 
		}
		if(sizeDaily > 1){
			for(var t=1 ; t<responseDataDaily.length ; t++){
				delButNumDaily++ ;
				//增加时间列
				var tdTime = new Ext.form.TimeField({
					anchor:'98%',
		  			id:'daily_time_edit_'+delButNumDaily,
		  			fieldLabel:'<fmt:message key="job.timer_time" />',
		  			format:'H:i:s',
		  			maxValue:'23:59 PM',
		  			minValue:'0:00 AM',
		  			value : responseDataDaily[t]['exec_start_time'] ,
		  			increment:30  //间隔30分钟
				});
				Ext.getCmp('daily_times_edit').items.add(delButNumDaily,tdTime);
				Ext.getCmp('daily_times_edit').doLayout(); 
				//增加删除按钮列
				var bt = new Ext.Button({
					iconCls : 'row-delete',
					text:'<fmt:message key="button.delete" />',
					height : 20 ,
					id : 'buttons_edit_daily_'+delButNumDaily,
					style : 'margin-top:5px',
					listeners:{
						click:function(bt){
							var size = bt.getId().substring(20);
							Ext.getCmp('daily_times_edit').remove(size);
		  					Ext.getCmp('daily_times_edit').doLayout(); 
		  					Ext.getCmp('buttons_edit_daily').remove(size);
		  					Ext.getCmp('buttons_edit_daily').doLayout();
						}
					}
				});
				Ext.getCmp('buttons_edit_daily').items.add(delButNumDaily,bt);
				Ext.getCmp('buttons_edit_daily').doLayout(); 
			}
		}
		//时间表处理   每周
		var sizeWeekly = responseDataWeekly.length ;
		if(sizeWeekly>0){
			Ext.getCmp('type_weekly_edit').setValue(1) ;
			Ext.getCmp('interval_weeks_edit').setValue(responseDataWeekly[0]['interval_weeks']);
			Ext.getCmp('weekly_time_edit').setValue(responseDataWeekly[0]['exec_start_time']);  
			Ext.getCmp('checkboxgroup').on('render', function(){
				Ext.getCmp('mon_edit').setValue(responseDataWeekly[0]['week1_flag']);
				Ext.getCmp('tus_edit').setValue(responseDataWeekly[0]['week2_flag']);
				Ext.getCmp('wen_edit').setValue(responseDataWeekly[0]['week3_flag']);
				Ext.getCmp('thu_edit').setValue(responseDataWeekly[0]['week4_flag']); 
				Ext.getCmp('fri_edit').setValue(responseDataWeekly[0]['week5_flag']);
				Ext.getCmp('sat_edit').setValue(responseDataWeekly[0]['week6_flag']);
				Ext.getCmp('sun_edit').setValue(responseDataWeekly[0]['week7_flag']);
			});
			priority = responseDataWeekly[0]['exec_priority'];
			emailList = responseDataWeekly[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataWeekly[0]['mail_success_flag']; 
			emailFailure = responseDataWeekly[0]['mail_failure_flag']; 
			emailCancel = responseDataWeekly[0]['mail_cancel_flag']; 
		}  
		//时间表处理   每月
		var sizeMonthly = responseDataMonthly.length ;
		if(sizeMonthly>0){
			Ext.getCmp('type_monthly_edit').setValue(1) ;
			Ext.getCmp('month_day_edit').setValue(responseDataMonthly[0]['month_days']);
			Ext.getCmp('monthly_time_edit').setValue(responseDataMonthly[0]['exec_start_time']);
			priority = responseDataMonthly[0]['exec_priority'];
			emailList = responseDataMonthly[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataMonthly[0]['mail_success_flag']; 
			emailFailure = responseDataMonthly[0]['mail_failure_flag']; 
			emailCancel = responseDataMonthly[0]['mail_cancel_flag']; 
		} 
		//时间表处理   时间间隔
		var sizeInterval = responseDataInterval.length ;
		if(sizeInterval>0){
			Ext.getCmp('type_interval_edit').setValue(1) ;
			Ext.getCmp('interval_date_edit').setValue(responseDataInterval[0]['exec_start_date']);
			Ext.getCmp('interval_time_edit').setValue(responseDataInterval[0]['exec_start_time']);
			Ext.getCmp('interval_day_edit').setValue(responseDataInterval[0]['interval_days']);
			Ext.getCmp('interval_hour_edit').setValue(responseDataInterval[0]['interval_hours']);
			Ext.getCmp('interval_min_edit').setValue(responseDataInterval[0]['interval_minutes']);
			priority = responseDataInterval[0]['exec_priority'];
			emailList = responseDataInterval[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataInterval[0]['mail_success_flag']; 
			emailFailure = responseDataInterval[0]['mail_failure_flag']; 
			emailCancel = responseDataInterval[0]['mail_cancel_flag']; 
		}
		Ext.getCmp('jobDesign_priorrity_edit').setValue(priority);
		var userId = Ext.getCmp('jobDesign_creatorId_edit').getValue();
		Ext.Ajax.request({
			url : '${ctx}/${appPath}/jobdesign/getNameByUsername',
			scope : this,
			params : {
				username : userId
			},
			success : function(resp,opts){
				var respText = Ext.util.JSON.decode(resp.responseText);
				var info = '' ;
				if(respText.info){
					info = respText.info;
				}
				if(info!=''){
					Ext.getCmp('jobDesign_creatorName_edit').setValue(info.name);
				}
			}
		});
	},
	findIp : function() {
		Ext.getCmp('jobDesignMoveServersGridEdit').getStore().baseParams.serverIp=Ext.getCmp('serverIpId').getValue();
		Ext.getCmp('jobDesignMoveServersGridEdit').getStore().reload();
	},//服务器移入事件
	serverShiftIn : function() {
		var records =this.jobDesignMoveServers.getSelectionModel().getSelections();
    		var notEqualFlag = true;
    		Ext.each(records,function(leftRecord){
    			Ext.getCmp('jobDesignExcgridMovedServersGridEdit').getStore().each(function(rightRecord){
    				if(leftRecord.data.serverIp == rightRecord.data.serverIp){
    					notEqualFlag = false;
    				}
    			},this);
    			if(notEqualFlag){
    				Ext.getCmp('jobDesignExcgridMovedServersGridEdit').getStore().add(leftRecord);
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
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

var jdef = new JobDesignEditForm();
// 实例化新建表单,并加入到Tab页中
Ext.getCmp("JOB_DESIGN_EDIT").add(jdef);
// 刷新Tab页布局
Ext.getCmp("JOB_DESIGN_EDIT").doLayout();
</script>
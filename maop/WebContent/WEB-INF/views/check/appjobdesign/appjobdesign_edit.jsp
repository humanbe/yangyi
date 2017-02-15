<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	import="com.nantian.jeda.security.util.SecurityUtils"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
<% String userEmail = new SecurityUtils().getUser().getEmail() ;%>
var delButNumOnce = 100 ; //删除按钮序号 - 一次var delButNumDaily = 100 ; //删除按钮序号 - 每天
var delButNumMonthly = 100 ; //删除按钮序号 - 每月

var panelOne = null ;
var panelTwo = null ;
var panelThree = null ;
var panelFour = null ;
var panelFive = null ;

var gridServer = null ;
var treeServer = null ;
//优先级和邮件配置
var priority = '' ;
var emailList = '' ;
var emailSuccess = '' ;
var emailFailure = '' ;
var emailCancel = '' ;
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

//组件列表字段信息
var fieldsServer = Ext.data.Record.create([
	{name: 'server_path', mapping : 'server_path', type : 'string'}, 
	{name: 'server_name', mapping : 'server_name', type : 'string'}
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

//作业时间表   一次var fieldset1 = new Ext.form.FieldSet({
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
			id: 'type_once_edit_appjob',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_edit_appjob',
         items: [{
			xtype:'datefield',
			format:'y-m-d',
			id:'once_date_edit_appjob',
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
	 	id : 'once_times_edit_appjob' ,
        items: [{
			xtype:'timefield',
			anchor:'97%',
			id : 'once_time_edit_appjob' ,
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
		id : 'buttons_edit_once_appjob',
        items: [{
				xtype:'button',
				iconCls : 'row-add',
	  			text:'<fmt:message key="job.add" />',
	  			height : 20 ,
	  			listeners:{
	  				click:function(){
	  					delButNumOnce++ ;
	  					//增加日期序号列	  					var df = new Ext.form.DateField({
		  					format:'y-m-d',
		  					fieldLabel: '<fmt:message key="job.timer_date" />',
		  					id:'once_date_edit_appjob_'+delButNumOnce,
		  					editable : false ,
		  					minValue : new Date(),
		  					value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
		  					anchor:'88%'
	  					});
	  					Ext.getCmp('once_dates_edit_appjob').items.add(delButNumOnce,df);
	  					Ext.getCmp('once_dates_edit_appjob').doLayout(); 
	  					
	  					//增加时间列	  					var tf = new Ext.form.TimeField({
		  			  		anchor:'97%',
		  					id:'once_time_edit_appjob_'+delButNumOnce,
		  					fieldLabel:'<fmt:message key="job.timer_time" />',
		  					format:'H:i:s',
		  					maxValue:'23:59 PM',
		  					minValue:'0:00 AM',
		  					value : new Date().format('Y-m-d H:i:s').substring(11) ,
		  					increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('once_times_edit_appjob').items.add(delButNumOnce,tf);
	  					Ext.getCmp('once_times_edit_appjob').doLayout(); 
	  					
	  					//增加删除按钮列	  					var bt = new Ext.Button({
	  						iconCls : 'row-delete',
	  						text:'<fmt:message key="button.delete" />',
	  						height : 20 ,
	  						id : 'buttons_edit_once_appjob_'+delButNumOnce,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(25);
	  								Ext.getCmp('once_dates_edit_appjob').remove(size);
	  			  					Ext.getCmp('once_dates_edit_appjob').doLayout(); 
		  			  				Ext.getCmp('once_times_edit_appjob').remove(size);
	  			  					Ext.getCmp('once_times_edit_appjob').doLayout(); 
	  			  					Ext.getCmp('buttons_edit_once_appjob').remove(size);
	  			  					Ext.getCmp('buttons_edit_once_appjob').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_edit_once_appjob').items.add(delButNumOnce,bt);
	  					Ext.getCmp('buttons_edit_once_appjob').doLayout(); 
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
			id: 'type_daily_edit_appjob',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_edit_appjob' ,
        items: [{
			xtype:'timefield',
  			anchor:'98%',
  			id : 'daily_time_edit_appjob' ,
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
		id : 'buttons_edit_daily_appjob',
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
	  			  			id:'daily_time_edit_appjob_'+delButNumDaily,
	  			  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			  			format:'H:i:s',
	  			  			maxValue:'23:59 PM',
	  			  			minValue:'0:00 AM',
	  			  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			  			increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('daily_times_edit_appjob').items.add(delButNumDaily,tdTime);
	  					Ext.getCmp('daily_times_edit_appjob').doLayout(); 
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						iconCls : 'row-delete',
	  						text:'<fmt:message key="button.delete" />',
	  						height : 20 ,
	  						id : 'buttons_edit_daily_appjob_'+delButNumDaily,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(26);
	  								Ext.getCmp('daily_times_edit_appjob').remove(size);
	  			  					Ext.getCmp('daily_times_edit_appjob').doLayout(); 
	  			  					Ext.getCmp('buttons_edit_daily_appjob').remove(size);
	  			  					Ext.getCmp('buttons_edit_daily_appjob').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_edit_daily_appjob').items.add(delButNumDaily,bt);
	  					Ext.getCmp('buttons_edit_daily_appjob').doLayout(); 
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
				id:'type_weekly_edit_appjob',
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
				id : 'interval_weeks_edit_appjob' ,
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
	  			id : 'weekly_time_edit_appjob' ,
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
	 id : 'weeks_edit_appjob' ,
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
				id: 'checkboxgroup_appjob',
	         	fieldLabel: '<fmt:message key="job.days_in" />',
	         	anchor:'85%',
	         	items: [
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_edit_appjob'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_edit_appjob' },
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_edit_appjob'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_edit_appjob'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_edit_appjob'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_edit_appjob'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_edit_appjob'}
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
			id:'type_monthly_edit_appjob',
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
        	id : 'month_day_edit_appjob' ,
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
			id : 'monthly_time_edit_appjob' ,
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
			id:'type_interval_edit_appjob',
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
			id : 'interval_date_edit_appjob' ,
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
 			id : 'interval_time_edit_appjob' ,
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
	 id : 'interval_gap_edit_appjob' ,
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
        	 id : 'interval_day_edit_appjob',
        	 minValue : 0 ,
        	 maxValue : 365 ,
        	 value : 0 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_edit_appjob',
	       	 minValue : 0 ,
	       	 maxValue : 24 ,
	       	 value : 1
	     },{
	       	 xtype: 'spinnerfield',
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_edit_appjob',
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
     	id : 'priorrity_edit_appjob',
     	items: [
     	       {boxLabel: '<fmt:message key="job.lowest" />', name: 'exec_priority', id: 'LOWEST_edit_appjob', inputValue: 'LOWEST'},
               {boxLabel: '<fmt:message key="job.low" />', name: 'exec_priority', id: 'LOW_edit_appjob', inputValue: 'LOW'},
               {boxLabel: '<fmt:message key="job.normal" />', name: 'exec_priority', id: 'NORMAL_edit_appjob', inputValue: 'NORMAL'},
               {boxLabel: '<fmt:message key="job.high" />', name: 'exec_priority', id: 'HIGH_edit_appjob', inputValue: 'HIGH'},
               {boxLabel: '<fmt:message key="job.critical" />', name: 'exec_priority', id: 'CRITICAL_edit_appjob', inputValue: 'CRITICAL'}
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
	url : '${ctx}/${frameworkPath}/item/APP_CHECK_AUTHORIZE_LEVEL_TYPE/sub',
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
var languageTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/SCRIPT_TYPE/sub',
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

AppJobDesignEditForm = Ext.extend(Ext.FormPanel, {
	PanelServer : null, // 组件页签 - 表单组件
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
	csmServer : null,  // 组件页签 - 数据列表选择框组件	tabIndex : 0,// Tab键顺序	constructor : function(cfg) {// 构造方法
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
		
		checkTypeStore.load();
		authorizeLevelTypeStore.load();
		fieldTypeStore.load();
		toolStatusStore.load();
		frontlineFlagStore.load();
		authorizeFlagStore.load();
		languageTypeStore.load();
		appsysStore.load();
		
		// 定义组件页签左侧树形组件------------------------------------begin
		this.treeServerLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/appjobdesign/getServerTreeForEdit'
		}); 
		treeServer = new Ext.tree.TreePanel({
			id : 'serverTree_edit_appjob',
			title : '<fmt:message key="job.select" />服务器',
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.servers" />',
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_SERVER_edit_appjob'
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
					 }
				 },
				 'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode = node.parentNode;
				              if(pNode == treeServer.getRootNode()) return;
				              if(checked){
					             var cb = pNode.ui.checkbox; 
					             if(cb){
						         	cb.checked = checked; 
						         	cb.defaultChecked = checked; 
						     	}
						    	pNode.attributes.checked=checked;
					          }else{
						    	var _miss=false; 
						     	for(var i=0;i<pNode.childNodes.length;i++){
							  		if(pNode.childNodes[i].attributes.checked!=checked){
								 		_miss=true;
							    	}
						      	}
								if(!_miss){
							   		pNode.ui.toggleCheck(checked); 
							     	pNode.attributes.checked=checked; 
						     	}
						  	}
					    }
				 }
			}
		});
		// 定义组件页签树形组件----------------------------------------end
	
		// 定义组件页签的中间移入移出按钮------------------------------------------begin
		this.PanelServer = new Ext.Panel({
			id : 'serverPanel_edit_appjob',
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
                 text: '<fmt:message key="job.movein" />>>',
                 scope : this,
     			 handler : this.serverShiftIn
             },{
                 xtype:'button',
                 width : 40 ,
                 height : 25 ,
                 text: '<<<fmt:message key="job.moveout" />',
                 scope : this,
                 handler : this.serverShiftOut
             }]
		});
		// 定义组件页签的中间移入移出按钮------------------------------------------end
		
		// 定义组件页签右侧列表组件--------------------------------------begin
		this.gridServerStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/appjobdesign/getJobServer/${param.jobid}',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [
						'appsys_code', 
						'job_code', 
						'server_path',
						'server_name'
					],
			remoteSort : true,
			sortInfo : {
				/* field : 'server_name',
				direction : 'ASC' */
			},
			baseParams : {
				/* start : 0,
				limit : 20 */
			}
		});
		this.gridServerStore.load();
		gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid_edit_appjob',
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.selected" />服务器',
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
			columns : [ new Ext.grid.RowNumberer(), csmServer,
            {
				header : '<fmt:message key="job.server_ip" />',
				dataIndex : 'server_name'
			},{
				header : '<fmt:message key="job.server_group" />',
				dataIndex : 'server_path'

			}],
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = this.gridServerStore.getAt(rowIndex);
					gridServer.store.remove(curRow);
				}
			}
		}); 
		// 定义组件页签右侧列表组件--------------------------------------end
		
		// 定义模板页签左侧树形组件----------------------------------------begin
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
                	xtype : 'combo',
                	style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="job.appsys_code" />',
					store : appsysStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'appsys_code',
					id : 'appsysCode_edit_appjob',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    readOnly : true 
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.code_jeda" />',
					name : 'job_code',
					id : 'jobCode_edit_appjob' ,
					tabIndex : this.tabIndex++,
					hidden : true
				},{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' ,
					readOnly : true,
					fieldLabel : '<fmt:message key="job" /><fmt:message key="job.name" />',
					name : 'job_name',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="job.type" />',
					valueField : 'value',
					displayField : 'name',
					name : 'check_type',
					id : 'checkType_edit_appjob',
					hiddenName : 'check_type' ,
					store : checkTypeStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					readOnly : true,
					hidden : true ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.authorize" />',
					valueField : 'value',
					displayField : 'name',
					name : 'authorize_lever_type',
					hiddenName : 'authorize_lever_type' ,
					id : "authorize_lever_type_edit_appjob",
					store : authorizeLevelTypeStore,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(obj) {
							var val = obj.getValue() ;
							if('1'==val){
								Ext.getCmp('frontline_flag_edit_appjob').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('frontline_flag_edit_appjob').setValue("0");
							}
							if('2'==val){
								Ext.getCmp('frontline_flag_edit_appjob').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('frontline_flag_edit_appjob').readOnly=false;
							}
						}
					}
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="job.desc" />',
					name : 'job_desc',
					id : 'jobDesc_edit_appjob',
					height : 60,
					maxLength : 400 ,
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
					id : 'frontline_flag_edit_appjob',
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
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					id : 'creatorId_edit_appjob',
					tabIndex : this.tabIndex++,
					hidden : true,
					readOnly : true
				},
				
				
				{
					xtype : 'textfield',
					fieldLabel : 'IPs',
					hidden : true, 
					id : 'serverips_edit_appjob',
					name : 'serverips'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerOnceVals_edit_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerDailyVals_edit_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerWeeklyVals_edit_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerMonthlyVals_edit_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerIntervalVals_edit_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'local_shName_edit'
				},
				{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.scriptName" />',
					id : 'scriptName_edit_appjob',
					name : 'script_name',
					hiddenName : 'script_name',
					maxLength : 200,
					readOnly : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'fileuploadfield',
					fieldLabel:'<fmt:message key="property.upload" />',
					id : 'shFile_edit_appjob',
					name : '',
					hiddenName : '',
					buttonText : '<fmt:message key="property.glance" />',
					editable : true ,
					buttonCfg: {
						iconCls: 'upload-icon'
					}
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行路径',
					id : 'execPath_edit_appjob',
					name : 'exec_path',
					maxLength : 200,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行用户',
					id : 'execUser_edit_appjob',
					name : 'exec_user',
					maxLength : 20,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行用户组',
					id : 'execUserGroup_edit_appjob',
					name : 'exec_user_group',
					maxLength : 20,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : languageTypeStore,
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.scriptType" />',
					id : 'languageTypeId_edit_appjob',
					name : 'language_type',
					hiddenName : 'language_type',
					displayField : 'name',
					valueField : 'name',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'radiogroup',
					fieldLabel : '查看脚本',
					items : [
							{
								boxLabel : '是',
								name : 'checked',
								inputValue : 'true'
							},
							{
								checked : true,
								boxLabel : '否',
								name : 'checked',
								id : 'appckeckedFalse',
								inputValue : 'false'
							} ]
				},
				{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					id : 'creatorName_edit_appjob',
					tabIndex : this.tabIndex++,
					readOnly : true
				}]
            }]
	    });  
		//第二个页签
		panelTwo = new Ext.Panel({
			title : '<fmt:message key="title.script" />',
			items : [{
				layout : 'form',
				defaults : {
					anchor : '90%'
				},
				border : false,
				items : [{
					xtype : 'textarea',
					id : 'script_edit_appjob',
					name : 'script_appjob',
					height : 615,
					readOnly : true,
					tabIndex : this.tabIndex++
				}]
			}],
			// 定义按钮
			tbar : [{
				text :'下载当前脚本',
				iconCls : 'button-download-excel',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.downLoadScript
			}]
		});
	    panelThree = new Ext.Panel({  
	    	title : '<fmt:message key="job.servers" />',
	    	layout : 'hbox',
			region:'center',
			border : false,
			defaults : { flex : 1 },
			layoutConfig : { align : 'stretch' },
			items : [treeServer,this.PanelServer,gridServer],
			listeners : {
				scope : this,
				'activate' : function(panel) {
					Ext.apply(this.treeServerLoader.baseParams, {appsysCode:Ext.getCmp('appsysCode_edit_appjob').getValue(), jobCode:Ext.getCmp('jobCode_edit_appjob').getValue()});
					treeServer.root.reload();
				}
			}
	    }); 
	    panelFour = new Ext.Panel({ 
	    	title:'<fmt:message key="job.timer" />',
        	id:'timer_edit_appjob',
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
		panelFive = new Ext.Panel({ 
			title:'<fmt:message key="job.notify_conf" />',
        	id:'mailConf_edit_appjob',
            layout:'form', 
            autoScroll : true , 
            labelAlign : 'right',
            defaults:{bodyStyle:'padding-top:10px'}, 
            iconCls : 'menu-node-trouble',
            border:false,
            height : 672,
            frame:true,
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
							columnWidth : .02 , 
							items : [{ 
							xtype : 'label'
						    }]
						},{
							columnWidth : .9 , 
							layout : 'form',
							items: [{
								xtype : 'textfield',
				                vtype : 'emailList',  
				                compare : 'emailListText',
				                anchor : '90%',
				                fieldLabel: '<fmt:message key="job.mail_list" />',
				             	maxLength : 1000,
				                name: 'exec_notice_mail_list',
				                id:'mail_list_edit_appjob'
				            }, {
				            	xtype: 'checkbox',
				                fieldLabel: '<fmt:message key="job.status_val" />',
				                boxLabel: '<fmt:message key="job.success" />',
				                inputValue : '2',
				                checked: true,
				                name: 'mail_success_flag',
				                id:'mail_success_edit_appjob'
				            }, {
				            	xtype: 'checkbox',
				                fieldLabel: '',
				                labelSeparator: '',
				                boxLabel: '<fmt:message key="job.failure" />',
				                inputValue : '4',
				                id:'mail_failure_edit_appjob',
				                name: 'mail_failure_flag'
				            }, {
				            	xtype: 'checkbox',
				                fieldLabel: '',
				                labelSeparator: '',
				                boxLabel: '<fmt:message key="job.cancel" />',
				                inputValue : '8',
				                id:'mail_cancel_edit_appjob',
				                name: 'mail_cancel_flag'
				            }]
						}]
			        }]
            }]
			
	    });
		
		var i = 0;   //面板序号
	    function cardHandler(direction) {  
	        if (direction == -1) {  
	            i--;  
	            if (i == 1) {
					if (Ext.getCmp('appckeckedFalse')
							.getValue()) {
						 i --;
					}
				}
	            if (i < 0) {  
	                i = 0;  
	            }  
	        }  
	        if (direction == 1) {  
	            i++;  
				if (Ext.getCmp('appckeckedFalse').getValue()) {
					if (i == 1) {
						 i++;
					}
				}
	            if (i > 4) {  
	                i = 4;  
	                return false;  
	            }  
	        }  
	        var btnPrev = Ext.getCmp("movePrev_edit_appjob");  
	        var btnSave = Ext.getCmp("moveSave_edit_appjob");  
	        var btnNext = Ext.getCmp("moveNext_edit_appjob");  
	        if (i == 0) { 
	            btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.disable(); 
	        }  
	        if(i == 1){
				var jobDesc = Ext.getCmp('jobDesc_edit_appjob').getValue();
				if (jobDesc.length>400) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobDesc.overlength" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				if (Ext.getCmp('checkType_edit_appjob').getValue() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobType.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var authorizeLeverType = Ext.getCmp('authorize_lever_type_edit_appjob').getValue() ;
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
				var scriptName = Ext.getCmp('scriptName_edit_appjob').getValue() ;
				if (scriptName == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '脚本名称不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if (scriptName.length>100) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '脚本名称超长',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				var execPath = Ext.getCmp('execPath_edit_appjob').getValue() ;
				if (execPath == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行路径不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if (execPath.length>100) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行路径超长',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				var execUser = Ext.getCmp('execUser_edit_appjob').getValue() ;
				if (execUser == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if (execUser.length>20) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户超长',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				var execUserGroup = Ext.getCmp('execUserGroup_edit_appjob').getValue() ;
				if (execUserGroup == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户组不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if (execUserGroup.length>60) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户组超长',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					}); 
					return i = 0;
				}
				var languageType = Ext.getCmp('languageTypeId_edit_appjob').getValue() ;
				if (languageType == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '脚本编码不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
                //上传脚本验证				
				var appcheckJobFilePath = Ext.getCmp('shFile_edit_appjob').getValue();
				if(appcheckJobFilePath!=''){
					var nshJobFilePrefix = appcheckJobFilePath.substring(appcheckJobFilePath.lastIndexOf('\\')+1);
					var shName = Ext.getCmp('scriptName_edit_appjob').getValue();
					if( nshJobFilePrefix != shName){
						Ext.Msg.show({
							title : '<fmt:message key="message.title"/>',
							msg :'<fmt:message key="nshjob.shError"/>',
							fn : function() {
								Ext.getCmp("shFile_edit_appjob").setValue('');
								Ext.getCmp("shFile_edit_appjob").focus(true);
								},
							buttons : Ext.Msg.OK,
							icon : Ext.MessageBox.WARNING
							});
						return i = 0;
					}else{
						Ext.getCmp('local_shName_edit').setValue(shName);
					}
					//读取上传脚本信息
					ajdef.getForm().submit(
					{
						url : '${ctx}/${appPath}/appjobdesign/showShData',
						scope : ajdef,
						success : ajdef.showScriptSuccess
					});
				}else{
					if('undefined'==Ext.getCmp('script_edit_appjob').getValue() ||null==Ext.getCmp('script_edit_appjob').getValue()||Ext.getCmp('script_edit_appjob').getValue()==''){
						ajdef.getForm().submit(
								{
									url : '${ctx}/${appPath}/appjobdesign/showShDataFromBsa',
									scope : ajdef,
									success : ajdef.showScriptSuccess
								});
								/* Ext.getCmp('script_edit_appjob').setValue(''); */
								app.mask.show();
					}
					
				}
				
				var execPath = Ext.getCmp('execPath_edit_appjob').getValue() ;
				if (execPath == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行路径不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var execUser = Ext.getCmp('execUser_edit_appjob').getValue() ;
				if (execUser == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var execUserGroup = Ext.getCmp('execUserGroup_edit_appjob').getValue() ;
				if (execUserGroup == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '执行用户组不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var languageType = Ext.getCmp('languageTypeId_edit_appjob').getValue() ;
				if (languageType == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '脚本编码不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				
				btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.enable();
	        }
	        if(i == 2){
	        	 
	        	var authorizeLeverType = Ext.getCmp('authorize_lever_type_edit_appjob').getValue() ;
	        	if(authorizeLeverType == '1'){ //常规巡巡检
					Ext.getCmp('cardPanel_edit_appjob').items.add(3,panelFour);
					Ext.getCmp('cardPanel_edit_appjob').items.add(4,panelFive);
  					Ext.getCmp('cardPanel_edit_appjob').doLayout(); 
				}
				if(authorizeLeverType == '2'){ //临时巡巡检
					Ext.getCmp('cardPanel_edit_appjob').items.remove(3);
					Ext.getCmp('cardPanel_edit_appjob').items.remove(4);
  					Ext.getCmp('cardPanel_edit_appjob').doLayout(); 
				}
				if(authorizeLeverType == '1'){ //常规巡巡检
					btnSave.hide();  
		            btnNext.enable();  
		            btnPrev.enable(); 
				}else{
					btnSave.show();  
		            btnNext.disable();  
		            btnPrev.enable();
				}
	        }
	        if(i == 3){
				var flagServer = false ; //组件不为空标志
	    		var storeServer = gridServer.getStore();
	    		var jsonServer = [];
	    		storeServer.each(function(item) {
	    			jsonServer.push(item.data);
	    		});
	    		if(jsonServer!=null && jsonServer.length>0){
	    			Ext.getCmp("serverips_edit_appjob").setValue( Ext.util.JSON.encode(jsonServer));
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
				btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.enable(); 
	        }
	        if (i == 4) {  
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
	   			var once = Ext.getCmp('type_once_edit_appjob').getValue();
	   			var	daily = Ext.getCmp('type_daily_edit_appjob').getValue();
	   			var	weekly = Ext.getCmp('type_weekly_edit_appjob').getValue();		
	   			var	monthly = Ext.getCmp('type_monthly_edit_appjob').getValue();
	   			var	interval = Ext.getCmp('type_interval_edit_appjob').getValue();
	   			if(once){
	   				freqFlag = true ;
	   				if(Ext.getCmp('once_date_edit_appjob').getValue() != ''){
	   					execDate = Ext.getCmp('once_date_edit_appjob').getValue().format('Y-m-d');
	   				}
	   				if(execDate == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					}); 
	   					return i = 3;
	   				}
	   				execTime = Ext.getCmp('once_time_edit_appjob').getValue() ;
	   				if(execTime == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空，请输入合法的时间
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
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
	   					return i = 3;
	   				}
	   				arrayOnce.push(execDate+" "+execTime);
	   				//插入增加时间表数据
	   				for(var t=0 ; t<=delButNumOnce ; t++){
	   					var addDateValue = '';
	   					var addTimeValue = '';
	   					if(Ext.getCmp('once_date_edit_appjob_'+t)){
	   						addDateValue = Ext.getCmp('once_date_edit_appjob_'+t).getValue().format('Y-m-d');
	   					}
	   					if(Ext.getCmp('once_time_edit_appjob_'+t)){
	   						addTimeValue = Ext.getCmp('once_time_edit_appjob_'+t).getValue();
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
	   								return i = 3;
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
	   							return i = 3;
	   						}
	   					}
	   				}
	   			}
	   			if(daily){
	   				freqFlag = true ;
	   				execTime = Ext.getCmp('daily_time_edit_appjob').getValue() ;
	   				if(execTime == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
	   				}
	   				var dateValue = new Date().format('Y-m-d') ;
	   				arrayDaily.push(dateValue+' '+execTime);
	   				//插入增加时间表数据
	   				for(var t=0 ; t<=delButNumDaily ; t++){
	   					if(Ext.getCmp('daily_time_edit_appjob_'+t)){
	   						var addValue = Ext.getCmp('daily_time_edit_appjob_'+t).getValue();
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
	   							return i = 3;
	   						}
	   					}
	   				}
	   			}
	   			if(weekly){
	   				freqFlag = true ;
	   				execTime = Ext.getCmp('weekly_time_edit_appjob').getValue() ;
	   				if(execTime == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
	   				}
	   				var daysOfWeek = Ext.getCmp('interval_weeks_edit_appjob').getValue() ; //周间隔数
	   				var mon = Ext.getCmp('mon_edit_appjob').getValue();
	   				var tus = Ext.getCmp('tus_edit_appjob').getValue();
	   				var wen = Ext.getCmp('wen_edit_appjob').getValue();
	   				var thu = Ext.getCmp('thu_edit_appjob').getValue();
	   				var fri = Ext.getCmp('fri_edit_appjob').getValue();
	   				var sat = Ext.getCmp('sat_edit_appjob').getValue();
	   				var sun = Ext.getCmp('sun_edit_appjob').getValue();
	   				if(!mon && !tus && !wen && !thu && !fri && !sat && !sun){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.execWeekNull" />!', //请勾选每周的执行星期
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
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
	   				if(Ext.getCmp('monthly_time_edit_appjob')){
	   					execTime = Ext.getCmp('monthly_time_edit_appjob').getValue() ;
	   				}
	   				if(execTime == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
	   				}
	   				var daysOfMonth = Ext.getCmp('month_day_edit_appjob').getValue() ;
	   				arrayMonthly.push(new Date().format('Y-m-d')+' '+execTime+'&'+daysOfMonth);
	   			}
	   			if(interval){
	   				freqFlag = true ;
	   				if(Ext.getCmp('interval_date_edit_appjob').getValue() != ''){
	   					execDate = Ext.getCmp('interval_date_edit_appjob').getValue().format('Y-m-d');
	   				}
	   				if(execDate == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
	   				}
	   				execTime = Ext.getCmp('interval_time_edit_appjob').getValue() ;
	   				if(execTime == ''){
	   					Ext.Msg.show( {
	   						title : '<fmt:message key="message.title" />',
	   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
	   						buttons : Ext.MessageBox.OK,
	   						icon : Ext.MessageBox.INFO,
	   						minWidth : 200
	   					});
	   					return i = 3;
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
	   					return i = 3;
	   				}
	   				var days = Ext.getCmp('interval_day_edit_appjob').getValue();
	   				var hours = Ext.getCmp('interval_hour_edit_appjob').getValue();
	   				var mins = Ext.getCmp('interval_min_edit_appjob').getValue();
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
	   	        	return i = 3;
	   	        }
	   	     	//优先级
				var lowest = Ext.getCmp('LOWEST_edit_appjob').getValue();
				var low = Ext.getCmp('LOW_edit_appjob').getValue();
				var normal = Ext.getCmp('NORMAL_edit_appjob').getValue();
				var high = Ext.getCmp('HIGH_edit_appjob').getValue();
				var critical = Ext.getCmp('CRITICAL_edit_appjob').getValue();
				if(!lowest && !low && !normal && !high && !critical){
					Ext.Msg.show( {
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="job.priorityNull" />!', //请选择优先级

						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i=3 ;
				}

				Ext.getCmp("timerOnceVals_edit_appjob").setValue(arrayOnce);
	    		Ext.getCmp("timerDailyVals_edit_appjob").setValue(arrayDaily);
	    		Ext.getCmp("timerWeeklyVals_edit_appjob").setValue(arrayWeekly);
	    		Ext.getCmp("timerMonthlyVals_edit_appjob").setValue(arrayMonthly);
	    		Ext.getCmp("timerIntervalVals_edit_appjob").setValue(arrayInterval);
	        	btnSave.show();  
	            btnNext.disable();  
	            btnPrev.enable();
	        }  
	        this.cardPanel.getLayout().setActiveItem(i);  
	    };  
		//CARD总面板  
		this.cardPanel = new Ext.Panel({
			id : 'cardPanel_edit_appjob',
			renderTo : document.body,
			height : 700,
			width : 600,
			layout : 'card',
			layoutConfig : {
				deferredRender : true
			},
			activeItem : 0,
			tbar : ['-',{
						id : 'movePrev_edit_appjob',
						iconCls : 'button-previous',
						text : '<fmt:message key="job.stepBefore" />',
						disabled : true ,
						handler : cardHandler.createDelegate(this,[ -1 ])
					},'-',{
						id : 'moveSave_edit_appjob',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						hidden : true,
						handler : this.doSave
					},'-',{
						id : 'moveNext_edit_appjob',
						iconCls : 'button-next',
						text : '<fmt:message key="job.stepNext" />',
						handler : cardHandler.createDelegate(this, [ 1 ])
					} ],
			items : [panelOne,panelTwo,panelThree]
		});
		
		// 设置基类属性		AppJobDesignEditForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180 ,
			buttonAlign : 'center',
			fileUpload : true, //有文件上传时，该属性必写
			frame : true,
			autoScroll : true,
			url : '${ctx}/${appPath}/appjobdesign/edit/${param.jobid}',
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
			url : '${ctx}/${appPath}/appjobdesign/view/${param.jobid}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			success : this.loadSuccess,
			failure : this.loadFailure
		});
	},
	
	//组件移入事件
	serverShiftIn : function() {
		var nodes = treeServer.getChecked();
    	var serverInfos = new Array();
    	for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){
		    	serverInfos.push(new fieldsServer({server_path:nodes[t].parentNode.text,server_name:nodes[t].text}));
			}
    	}
    	if(gridServer.store.getCount()!=0){
			gridServer.store.removeAll();
			gridServer.store.add(serverInfos);
    	}else{
    		gridServer.store.add(serverInfos);
    	}
	},

	//组件移出事件
	serverShiftOut : function() {
		var records = gridServer.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			gridServer.store.remove(records[i]);
		}
	},
	
	//模板移入事件
	templateShiftIn : function() {
		var nodes = this.treeTemplate.getChecked();
    	var templateInfos = new Array();
    	for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){
				var par = nodes[t].parentNode;
				var grandPar = nodes[t].parentNode.parentNode;
		    	templateInfos.push(new fieldsTemplate({template_group:grandPar.text+"/"+par.text,template_name:nodes[t].text}));
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
	
	//显示脚本信息
	showScriptSuccess : function(form, action) {
		app.mask.hide();
		var data = decodeURIComponent(action.result.data);
		Ext.getCmp('script_edit_appjob').setValue(data);
		var bottom = this.getHeight();
		this.body.scroll("b", bottom, true);
	},
	
	// 保存操作
	doSave : function() {
		var authorizeLeverType = Ext.getCmp('authorize_lever_type_edit_appjob').getValue() ;
		if(authorizeLeverType == '1'){ //常规巡巡检
			//通知配置
    		var mails = Ext.getCmp('mail_list_edit_appjob').getValue();
    		if(mails != ''){
        		var isemail = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        		var num = 0;
        		var mailList = mails.split(';');
        		var listSize = mailList.length ;
        		for(var i=0 ; i<listSize ; i++){
        			if(isemail.test(mailList[i])){
        				num++ ;
        			}
        		}
        		if(num!=listSize){
        			Ext.Msg.show( {
    					title : '<fmt:message key="message.title" />',
    					msg : '<fmt:message key="job.mailError" />!',
    					buttons : Ext.MessageBox.OK,
    					icon : Ext.MessageBox.INFO,
    					minWidth : 200
    				});
    				return false ;
        		}
        		var success = Ext.getCmp('mail_success_edit_appjob').getValue();
        		var failure = Ext.getCmp('mail_failure_edit_appjob').getValue();
        		var cancel = Ext.getCmp('mail_cancel_edit_appjob').getValue();
        		if(!success && !failure && !cancel){
    				Ext.Msg.show( {
    					title : '<fmt:message key="message.title" />',
    					msg : '<fmt:message key="job.mail_status_null" />!',
    					buttons : Ext.MessageBox.OK,
    					icon : Ext.MessageBox.INFO,
    					minWidth : 200
    				});
    				return false ;
    			}
        	}
		}else{
			var flagServer = false ; //组件不为空标志			var storeServer = gridServer.getStore();
			var jsonServer = [];
			storeServer.each(function(item) {
				jsonServer.push(item.data);
			});
			if(jsonServer!=null && jsonServer.length>0){
				Ext.getCmp("serverips_edit_appjob").setValue( Ext.util.JSON.encode(jsonServer));
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
		//提交表单
		ajdef.getForm().submit({
			scope : ajdef,
			timeout : 1800000, //半小时
			success : ajdef.saveSuccess,
			failure : ajdef.saveFailure,
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
				app.closeTab('APP_JOB_DESIGN_EDIT');
				var list = Ext.getCmp("APP_JOB_DESIGN_INDEX").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				app.loadTab('APP_JOB_DESIGN_INDEX', '<fmt:message key="button.view" /><fmt:message key="function" />', '${ctx}/${appPath}/appjobdesign/index');
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
		var type = Ext.getCmp('authorize_lever_type_edit_appjob').getValue();
		if(type=='1'){  //常规巡检
			Ext.getCmp('frontline_flag_edit_appjob').el.up('.x-form-item').setDisplayed(false);
			Ext.getCmp('frontline_flag_edit_appjob').setValue("0");
			//一次
			responseDataOnce = action.result.dataOnce; 
			//每天
			responseDataDaily = action.result.dataDaily;
			//每周
			responseDataWeekly = action.result.dataWeekly;
			//每月
			responseDataMonthly = action.result.dataMonthly;
			//时间间隔
			responseDataInterval = action.result.dataInterval;
			//时间表处理   一次
			var sizeOnce = responseDataOnce.length ;
			if(sizeOnce>0){
				Ext.getCmp('type_once_edit_appjob').setValue(1) ;
				Ext.getCmp('once_date_edit_appjob').setValue(responseDataOnce[0]['exec_start_date']);
				Ext.getCmp('once_time_edit_appjob').setValue(responseDataOnce[0]['exec_start_time']);
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
	 					id:'once_date_edit_appjob_'+delButNumOnce,
	 					editable : false ,
	 					minValue : new Date(),
	 					value : responseDataOnce[t]['exec_start_date'] ,
	 					anchor:'88%'
					});
					Ext.getCmp('once_dates_edit_appjob').items.add(delButNumOnce,df);
					Ext.getCmp('once_dates_edit_appjob').doLayout(); 
					//增加时间列
					var tf = new Ext.form.TimeField({
	 			  		anchor:'97%',
	 					id:'once_time_edit_appjob_'+delButNumOnce,
	 					fieldLabel:'<fmt:message key="job.timer_time" />',
	 					format:'H:i:s',
	 					maxValue:'23:59 PM',
	 					minValue:'0:00 AM',
	 					value : responseDataOnce[t]['exec_start_time'] ,
	 					increment:30  //间隔30分钟
					});
					Ext.getCmp('once_times_edit_appjob').items.add(delButNumOnce,tf);
					Ext.getCmp('once_times_edit_appjob').doLayout(); 
					//增加删除按钮列
					var bt = new Ext.Button({
						iconCls : 'row-delete',
						text:'<fmt:message key="button.delete" />',
						height : 20 ,
						id : 'buttons_edit_once_appjob_'+delButNumOnce,
						style : 'margin-top:5px',
						listeners:{
							click:function(bt){
								var size = bt.getId().substring(25);
								Ext.getCmp('once_dates_edit_appjob').remove(size);
			  					Ext.getCmp('once_dates_edit_appjob').doLayout(); 
	 			  				Ext.getCmp('once_times_edit_appjob').remove(size);
			  					Ext.getCmp('once_times_edit_appjob').doLayout(); 
			  					Ext.getCmp('buttons_edit_once_appjob').remove(size);
			  					Ext.getCmp('buttons_edit_once_appjob').doLayout();
							}
						}
					});
					Ext.getCmp('buttons_edit_once_appjob').items.add(delButNumOnce,bt);
					Ext.getCmp('buttons_edit_once_appjob').doLayout(); 
				}
			}
			//时间表处理   每天
			var sizeDaily = responseDataDaily.length ;
			if(sizeDaily>0){
				Ext.getCmp('type_daily_edit_appjob').setValue(1) ;
				Ext.getCmp('daily_time_edit_appjob').setValue(responseDataDaily[0]['exec_start_time']);
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
			  			id:'daily_time_edit_appjob_'+delButNumDaily,
			  			fieldLabel:'<fmt:message key="job.timer_time" />',
			  			format:'H:i:s',
			  			maxValue:'23:59 PM',
			  			minValue:'0:00 AM',
			  			value : responseDataDaily[t]['exec_start_time'] ,
			  			increment:30  //间隔30分钟
					});
					Ext.getCmp('daily_times_edit_appjob').items.add(delButNumDaily,tdTime);
					Ext.getCmp('daily_times_edit_appjob').doLayout(); 
					//增加删除按钮列

					var bt = new Ext.Button({
						iconCls : 'row-delete',
						text:'<fmt:message key="button.delete" />',
						height : 20 ,
						id : 'buttons_edit_daily_appjob_'+delButNumDaily,
						style : 'margin-top:5px',
						listeners:{
							click:function(bt){
								var size = bt.getId().substring(26);
								Ext.getCmp('daily_times_edit_appjob').remove(size);
			  					Ext.getCmp('daily_times_edit_appjob').doLayout(); 
			  					Ext.getCmp('buttons_edit_daily_appjob').remove(size);
			  					Ext.getCmp('buttons_edit_daily_appjob').doLayout();
							}
						}
					});
					Ext.getCmp('buttons_edit_daily_appjob').items.add(delButNumDaily,bt);
					Ext.getCmp('buttons_edit_daily_appjob').doLayout(); 
				}
			}
			//时间表处理   每周
			var sizeWeekly = responseDataWeekly.length ;
			if(sizeWeekly>0){
				Ext.getCmp('type_weekly_edit_appjob').setValue(1) ;
				Ext.getCmp('interval_weeks_edit_appjob').setValue(responseDataWeekly[0]['interval_weeks']);
				Ext.getCmp('weekly_time_edit_appjob').setValue(responseDataWeekly[0]['exec_start_time']);  
				Ext.getCmp('checkboxgroup_appjob').on('render', function(){
					Ext.getCmp('mon_edit_appjob').setValue(responseDataWeekly[0]['week1_flag']);
					Ext.getCmp('tus_edit_appjob').setValue(responseDataWeekly[0]['week2_flag']);
					Ext.getCmp('wen_edit_appjob').setValue(responseDataWeekly[0]['week3_flag']);
					Ext.getCmp('thu_edit_appjob').setValue(responseDataWeekly[0]['week4_flag']); 
					Ext.getCmp('fri_edit_appjob').setValue(responseDataWeekly[0]['week5_flag']);
					Ext.getCmp('sat_edit_appjob').setValue(responseDataWeekly[0]['week6_flag']);
					Ext.getCmp('sun_edit_appjob').setValue(responseDataWeekly[0]['week7_flag']);
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
				Ext.getCmp('type_monthly_edit_appjob').setValue(1) ;
				Ext.getCmp('month_day_edit_appjob').setValue(responseDataMonthly[0]['month_days']);
				Ext.getCmp('monthly_time_edit_appjob').setValue(responseDataMonthly[0]['exec_start_time']);
				priority = responseDataMonthly[0]['exec_priority'];
				emailList = responseDataMonthly[0]['exec_notice_mail_list']; 
				emailSuccess = responseDataMonthly[0]['mail_success_flag']; 
				emailFailure = responseDataMonthly[0]['mail_failure_flag']; 
				emailCancel = responseDataMonthly[0]['mail_cancel_flag']; 
			} 
			//时间表处理   时间间隔
			var sizeInterval = responseDataInterval.length ;
			if(sizeInterval>0){
				Ext.getCmp('type_interval_edit_appjob').setValue(1) ;
				Ext.getCmp('interval_date_edit_appjob').setValue(responseDataInterval[0]['exec_start_date']);
				Ext.getCmp('interval_time_edit_appjob').setValue(responseDataInterval[0]['exec_start_time']);
				Ext.getCmp('interval_day_edit_appjob').setValue(responseDataInterval[0]['interval_days']);
				Ext.getCmp('interval_hour_edit_appjob').setValue(responseDataInterval[0]['interval_hours']);
				Ext.getCmp('interval_min_edit_appjob').setValue(responseDataInterval[0]['interval_minutes']);
				priority = responseDataInterval[0]['exec_priority'];
				emailList = responseDataInterval[0]['exec_notice_mail_list']; 
				emailSuccess = responseDataInterval[0]['mail_success_flag']; 
				emailFailure = responseDataInterval[0]['mail_failure_flag']; 
				emailCancel = responseDataInterval[0]['mail_cancel_flag']; 
			}
			Ext.getCmp('priorrity_edit_appjob').setValue(priority);
			Ext.getCmp('mail_list_edit_appjob').setValue(emailList); 
			Ext.getCmp('mail_success_edit_appjob').setValue(emailSuccess); 
			Ext.getCmp('mail_failure_edit_appjob').setValue(emailFailure); 
			Ext.getCmp('mail_cancel_edit_appjob').setValue(emailCancel);
		}else{ //临时巡检
			Ext.getCmp('priorrity_edit_appjob').setValue('NORMAL');
			Ext.getCmp('mail_list_edit_appjob').setValue('<%=userEmail%>'); 
			Ext.getCmp('mail_success_edit_appjob').setValue(0); 
			Ext.getCmp('mail_failure_edit_appjob').setValue(1); 
			Ext.getCmp('mail_cancel_edit_appjob').setValue(1);
		}
		//创建人
		var userId = Ext.getCmp('creatorId_edit_appjob').getValue();
		Ext.Ajax.request({
			url : '${ctx}/${appPath}/appjobdesign/getNameByUsername',
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
					Ext.getCmp('creatorName_edit_appjob').setValue(info.name);
				}
			}
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
	// 下载当前脚本
	downLoadScript : function(){
		var appcheckJobFilePath = Ext.getCmp('shFile_edit_appjob').getValue();
		if(appcheckJobFilePath!=''){  //新脚本
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '本地上传的新脚本不需要下载！',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}else{
			window.location = '${ctx}/${appPath}/appjobdesign/downloadfile.file?jobid=${param.jobid}';
		}
	}
	
});

var ajdef = new AppJobDesignEditForm();
// 实例化新建表单,并加入到Tab页中
Ext.getCmp("APP_JOB_DESIGN_EDIT").add(ajdef);
// 刷新Tab页布局
Ext.getCmp("APP_JOB_DESIGN_EDIT").doLayout();
</script>
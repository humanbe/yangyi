<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" 
         import="com.nantian.jeda.security.util.SecurityUtils"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
<% String userEmail = new SecurityUtils().getUser().getEmail() ;%>
var delButNumOnce = 0 ; //删除按钮序号 - 一次
var delButNumDaily = 0 ; //删除按钮序号- 每天
var delButNumMonthly = 0 ; //删除按钮序号 - 每月

var panelOne = null ;
var panelTwo = null ;
var panelThree = null ;
var panelFour = null ;
var panelFive = null ;
var serverPanel = null ;

var commonCheck = 'COMMON_CHECK'; // BSA通用模板目录名称
var serverRootName = 'ALLSERVERS' ; //服务器目录树根节点名称

var commonJobAppSys = 'COMMON'; //常规作业对应的应用系统


var gridServer = null ;
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
var serverStore = new Ext.data.SimpleStore({
	fields : ['value', 'name'],
	data : [['0', '服务器']]
});
var checkObject = Ext.data.Record.create([
                                         	{name: 'name', mapping : 'name', type : 'string'}, 
                                         	{name: 'value', mapping : 'value', type : 'string'}
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
     //labelAlign: 'top',
	 title: '',
     autoHeight:true,
     //defaults: {width: 800},
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
			id: 'type_once',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_create',
         items: [{
			xtype:'datefield',
			format:'y-m-d',
			fieldLabel: '<fmt:message key="job.timer_date" />',
			id : 'once_date_create' ,
			editable : false ,
			minValue : new Date(),
			value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
			anchor:'88%'
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
	 	labelWidth:40,
	 	id:'once_times_create',
        items: [{
			xtype:'timefield',
			anchor:'97%',
			id : 'once_time_create' ,
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
		id : 'buttons_create_once',
        items: [{
				xtype:'button',
				iconCls : 'row-add',
	  			text:'<fmt:message key="job.add" />',
	  			height : 20 ,
	  			listeners:{
	  				click:function(){
	  					delButNumOnce = delButNumOnce + 1 ;
	  					//增加日期序号列
	  					var df = new Ext.form.DateField({
		  					format:'y-m-d',
		  					fieldLabel: '<fmt:message key="job.timer_date" />',
		  					id:'once_date_create_'+delButNumOnce,
		  					editable : false ,
		  					minValue : new Date(),
		  					value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
		  					anchor:'88%'
	  					});
	  					Ext.getCmp('once_dates_create').items.add(delButNumOnce,df);
	  					Ext.getCmp('once_dates_create').doLayout(); 
	  					
	  					//增加时间列
	  					var tf = new Ext.form.TimeField({
		  			  		anchor:'97%',
		  					id:'once_time_create_'+delButNumOnce,
		  					fieldLabel:'<fmt:message key="job.timer_time" />',
		  					format:'H:i:s',
		  					maxValue:'23:59 PM',
		  					minValue:'0:00 AM',
		  					value : new Date().format('Y-m-d H:i:s').substring(11) ,
		  					increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('once_times_create').items.add(delButNumOnce,tf);
	  					Ext.getCmp('once_times_create').doLayout(); 
	  					
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						text:'<fmt:message key="button.delete" />',
	  						iconCls : 'row-delete',
	  						height : 20 ,
	  						id : 'buttons_create_once_'+delButNumOnce,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(20);
	  								Ext.getCmp('once_dates_create').remove(size);
	  			  					Ext.getCmp('once_dates_create').doLayout(); 
		  			  				Ext.getCmp('once_times_create').remove(size);
	  			  					Ext.getCmp('once_times_create').doLayout(); 
	  			  					Ext.getCmp('buttons_create_once').remove(size);
	  			  					Ext.getCmp('buttons_create_once').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_create_once').items.add(delButNumOnce,bt);
	  					Ext.getCmp('buttons_create_once').doLayout(); 
	  				}
	  			}
		  }]
	} ]
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
			id: 'type_daily',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_create' ,
        items: [{
				xtype:'timefield',
	  			anchor:'98%',
	  			id : 'daily_time_create' ,
	  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			format:'H:i:s',
	  			maxValue:'23:59 PM',
	  			minValue:'0:00 AM',
	  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			increment:30  //间隔30分钟
		  }]
	},{
        columnWidth:.25,
        layout: 'form',
		labelWidth:20,
		id : 'buttons_create_daily',
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
	  			  			/* name : 'daily_time_create_val', */
	  			  			id:'daily_time_create_'+delButNumDaily,
	  			  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			  			format:'H:i:s',
	  			  			maxValue:'23:59 PM',
	  			  			minValue:'0:00 AM',
	  			  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			  			increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('daily_times_create').items.add(delButNumDaily,tdTime);
	  					Ext.getCmp('daily_times_create').doLayout(); 
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						text:'<fmt:message key="button.delete" />',
	  						iconCls : 'row-delete',
	  						height : 20 ,
	  						id : 'buttons_create__daily_'+delButNumDaily,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(22);
	  								Ext.getCmp('daily_times_create').remove(size);
	  			  					Ext.getCmp('daily_times_create').doLayout(); 
	  			  					Ext.getCmp('buttons_create_daily').remove(size);
	  			  					Ext.getCmp('buttons_create_daily').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_create_daily').items.add(delButNumDaily,bt);
	  					Ext.getCmp('buttons_create_daily').doLayout(); 
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
				id:'type_weekly',
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
				id : 'interval_weeks_create' ,
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
	  			id : 'weekly_time_create' ,
	  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			format:'H:i:s',
	  			maxValue:'23:59 PM',
	  			minValue:'0:00 AM',
	  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			increment:30  //间隔30分钟
		}]
 	 }]
});

//作业时间表   每周-星期
var fieldsetWeeks = new Ext.form.FieldSet({
	 title: '',
	 id : 'weeks_create' ,
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
	         	fieldLabel: '<fmt:message key="job.days_in" />',
	         	anchor:'85%',
	         	items: [
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_create' , value:'2'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_create' , value:'4'},
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_create' , value:'8'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_create' , value:'16'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_create' ,  value:'32'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_create' , /* checked:true ,  */value:'64'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_create' ,/*  checked:true , */value:'1'}
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
			id:'type_monthly',
			inputValue: '4'
		}]
    },{
        columnWidth:.4,
        layout: 'form',
		labelWidth:60,
		id:'monthly_days_create',
        items: [{
        	xtype:'spinnerfield',
        	anchor:'88%',
        	name: 'month_day',
        	id : 'month_day_create' ,
			fieldLabel: '<fmt:message key="job.day_sort" />',
			minValue : 1 ,
			maxValue : 31 ,
			value : 1 
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
		labelWidth:40,
		id:'monthly_times_create',
        items: [{
        	xtype:'timefield',
			anchor:'97%',
			id : 'monthly_time_create' ,
			fieldLabel:'<fmt:message key="job.timer_time" />',
			format:'H:i:s',
			maxValue:'23:59 PM',
			minValue:'0:00 AM',
			value : new Date().format('Y-m-d H:i:s').substring(11) ,
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
			boxLabel: '<fmt:message key="job.interval" />',
			name: 'exec_freq_type',
			id:'type_interval',
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
			value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
			fieldLabel: '<fmt:message key="job.timer_date" />',
			id : 'interval_date_create' ,
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
 			id : 'interval_time_create' ,
 			fieldLabel:'<fmt:message key="job.timer_time" />',
 			format:'H:i:s',
 			maxValue:'23:59 PM',
 			minValue:'0:00 AM',
 			value : new Date().format('Y-m-d H:i:s').substring(11) ,
 			increment:30  //间隔30分钟
		}]
     }]
}); 

//作业时间表   时间间隔-重复间隔
var fieldsetInervalGaps = new Ext.form.FieldSet({
	 title: '',
	 id : 'interval_gap_create' ,
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
        	 id : 'interval_day_create',
        	 minValue : 0 ,
        	 maxValue : 365 ,
        	 value : 0 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_create',
	       	 minValue : 0 ,
	       	 maxValue : 24 ,
	       	 value : 1
	     },{
	       	 xtype: 'spinnerfield',
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_create',
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

//作业时间表   优先级
var fieldset7 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    labelWidth:80,
    items: [{
		xtype: 'radiogroup',
     	fieldLabel: '<fmt:message key="job.priority" />&nbsp;&nbsp;',
     	anchor:'55%',
     	items: [
     	       {boxLabel: '<fmt:message key="job.lowest" />', name: 'exec_priority', inputValue: 'LOWEST'},
               {boxLabel: '<fmt:message key="job.low" />', name: 'exec_priority', inputValue: 'LOW'},
               {boxLabel: '<fmt:message key="job.normal" />', name: 'exec_priority', inputValue: 'NORMAL', checked: true},
               {boxLabel: '<fmt:message key="job.high" />', name: 'exec_priority', inputValue: 'HIGH'},
               {boxLabel: '<fmt:message key="job.critical" />', name: 'exec_priority', inputValue: 'CRITICAL'}
         ]
	}]
});  

//定义新建表单
JobInfoCreateForm = Ext.extend(Ext.FormPanel, {
	PanelServer : null, // 组件页签 - 表单组件 
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
	PanelTemplate : null, // 模板页签 - 表单组件 
    gridTemplate :null,   // 列表组件 - 列表组件
	treeTemplate : null,  // 树形组件 - 树形组件
	csmServer : null,  // 组件页签 - 数据列表选择框组件	csmMovedServers : null,
	csmMoveServers : null,
	csmTemplate : null,// 模板页签 - 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		csmServer = new Ext.grid.CheckboxSelectionModel();
		csmTemplate = new Ext.grid.CheckboxSelectionModel();
		csmMovedServers = new Ext.grid.CheckboxSelectionModel();
		csmMoveServers = new Ext.grid.CheckboxSelectionModel();
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止
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
		
		// 定义组件页签树形组件----------------------------------------begin
		this.treeServerLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/jobdesign/getServerTree'
		});
		this.treeServer = new Ext.tree.TreePanel({
			id : 'serverTree',
			title : '智能组服务器预览',
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : serverRootName,
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_SERVER'
			}),
			loader : this.treeServerLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.treeServer.expandAll();  //展开所有节点					 /* this.treeServer.root.expand();  //展开根节点 */
					 if(!this.treeServer.root.hasChildNodes()){
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
						 this.treeServer.root.eachChild(function(typeNode) {
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
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [ 'server_group', 'server_ip' ],
			remoteSort : true,
			sortInfo : {
				/* field : 'server_ip',
				direction : 'ASC' */
			},
			baseParams : {
				/* start : 0,
				limit : 20 */
			}
		});
		gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid',
			loadMask : true,
			frame : true,
			title : '已关联的智能组',
			region : 'center',
			border : false,
			autoScroll : true,
			columnLines : true,
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
			dataUrl : '${ctx}/${appPath}/jobdesign/getTemplateTree'
		});
		this.treeTemplate = new Ext.tree.TreePanel({
			id : 'templateTree',
			title : "<fmt:message key="job.select" /><fmt:message key="job.template" />",
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.template" />',
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_TEMPLATE'
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
		/* this.treeTemplate.root.expand();  */ 
		// 定义模板页签树形组件----------------------------------------end
		
		// 定义模板页签的中间移入移出按钮---------------------------begin
		this.PanelTemplate = new Ext.Panel({
			id : 'templatePanel',
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
                 text: '<<<fmt:message key="job.moveout" />',
                 scope : this,
                 handler : this.templateShiftOut
             }]
		});
		// 定义模板页签的中间移入移出按钮---------------------------end
		
		// 定义模板页签右侧列表组件--------------------------------------begin
		this.gridTemplateStore=new Ext.data.JsonStore({
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [ 'template_group', 'template_name' ],
			remoteSort : true,
			sortInfo : {
				/* field : 'template_name',
				direction : 'ASC' */
			},
			baseParams : {
				/* start : 0,
				limit : 20 */
			}
		});
		this.gridTemplate = new Ext.grid.GridPanel({
			id : 'templateGrid',
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.template" />',
			autoScroll : true,
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridTemplateStore,
			/* hideHeaders:true, //隐藏表头 */
			sm : csmTemplate,  //注意：不能删，否则列表前的复选框不可操作
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csmTemplate,
            {
				header : '<fmt:message key="job.template" /><fmt:message key="job.name" />',
				dataIndex : 'template_name'
			},{
				header : '<fmt:message key="job.template" /><fmt:message key="job.path" /> ',
				dataIndex : 'template_group'
			}],
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件				rowdblclick : function(row,rowIndex,e){
					var curRow = this.gridTemplateStore.getAt(rowIndex);
					this.gridTemplate.store.remove(curRow);
				}
			}/* ,
			// 定义分页工具条			bbar : new Ext.PagingToolbar({
				store : this.gridTemplateStore,
				displayInfo : true,
				pageSize : 20
			})  */
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
		//获取下拉菜单数据
		this.checkTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.checkTypeStore.load();
		this.authorizeLevelTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_AUTHORIZE_LEVEL_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.authorizeLevelTypeStore.load();
		this.fieldTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_FIELD_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.fieldTypeStore.load();
		this.toolStatusStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/JOB_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.toolStatusStore.load();
		this.frontlineFlagStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/JOB_FRONTLINE_FLAG/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.frontlineFlagStore.load();
		this.authorizeFlagStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/JOB_AUTHORIZE_FLAG/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.authorizeFlagStore.load();
		
		// 主页面应用系统信息----------------------------------begin
	    this.appsysStore = new Ext.data.Store({
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
		this.appsysStore.load(); 
		// 主页面应用系统信息----------------------------------end
		
		//各个页签
		panelOne = new Ext.Panel({  
			title:'<fmt:message key="job" /><fmt:message key="job.define" />',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:110px;padding-top:100px'},
            iconCls : 'menu-node-change',
            items:[{
                columnWidth:.85,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
                items: [{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;巡检对象',
				    id : 'server_target_typeID',
				    hiddenName : 'server_target_type',
				    store : serverStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    allowBlank : false,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.authorize" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'authorize_lever_type',
					id : 'jobDesign_authorize_lever_type_create',
					store : this.authorizeLevelTypeStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(obj) {
							Ext.getCmp('jobDesign_frontline_flag_create').setValue("0");
							var val = obj.getValue() ;
							if('1'==val){ //常规作业
								Ext.getCmp('jobDesign_frontline_flag_create').el.up('.x-form-item').setDisplayed(false);
								Ext.getCmp('jobdesign_appsysCode_create').setValue(commonJobAppSys);
							}
							if('2'==val){
								Ext.getCmp('jobDesign_frontline_flag_create').el.up('.x-form-item').setDisplayed(true);
								Ext.getCmp('jobdesign_appsysCode_create').setValue(commonJobAppSys);
							};
						}
					}
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.appsys_code" />',
				    id : 'jobdesign_appsysCode_create',
					hidden : true , 
					name : 'appsys_code',
					hiddenName : 'appsys_code',
					tabIndex : this.tabIndex++ 
				},
                {
                	xtype:'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job" /><fmt:message key="job.name" />',
					name : 'job_name',
					id : 'jobDesign_jobName_create',
					emptyText : '命名规范示例：OS_LINUX_HEALTH' ,
					maxLength : 30,
					allowBlank : false
				},
				{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.type" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'check_type',
					id : 'jobDesign_checkType_create',
					store : this.checkTypeStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.field" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'field_type',
					id : 'jobDesign_fieldType_create',
					store : this.fieldTypeStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    allowBlank : false,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="job.desc" />',
					height : 60,
					maxLength : 100 ,
					name : 'job_desc',
					id : 'jobDesign_jobDesc_create'
				},
				{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.status" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'tool_status',
					store : this.toolStatusStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    hidden : true ,
                    hiddenValue : 2 , //默认为：已发布
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.frontline_flag" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'frontline_flag',
					id : 'jobDesign_frontline_flag_create',
					store : this.frontlineFlagStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false, 
                    allowBlank : false,
                    hiddenValue : 1,
                    hidden : true ,
					tabIndex : this.tabIndex++
				},
				{   //是否需要授权					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.authorize_flag" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'authorize_flag',
					store : this.authorizeFlagStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false,  
                    hidden : true,
                    hiddenValue : 0,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					hidden : true
				},
				{
					xtype : 'textfield',
					hidden : true, 
					id : 'servers'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'templates'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerOnceVals'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerDailyVals'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerWeeklyVals'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerMonthlyVals'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerIntervalVals'
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
			items : [this.treeTemplate,this.PanelTemplate,this.gridTemplate],
            listeners : {
				scope : this,
				'activate' : function(panel) {
					var treeTemplateRoot = Ext.getCmp("templateTree").getRootNode();
					this.treeTemplateLoader.baseParams.fieldType = Ext.getCmp('jobDesign_fieldType_create').getValue();
					//重新加载树形菜单
					treeTemplateRoot.reload();
					//完全展开树形菜单
					Ext.getCmp("templateTree").root.expand();
				}
			}
	    });  
	
		
		//this.jobDesignServerStore.load(); 
		
	    panelThree = new Ext.Panel({  
	    	title : '<fmt:message key="job.servers" />',
	    	layout : 'hbox',
			region:'center',
			border : false,
			defaults : { flex : 1 },
			layoutConfig : { align : 'stretch' },
			items : [this.treeServer,gridServer],
			listeners : {
				scope : this,
				'activate' : function(panel) {
					var storeTemplate = this.gridTemplate.getStore();
		    		var jsonTemplate = [];
		    		storeTemplate.each(function(item) {
		    			jsonTemplate.push(item.data);
		    		});
					var treeRoot = Ext.getCmp("serverTree").getRootNode();
					this.treeServerLoader.baseParams.templates =  Ext.util.JSON.encode(jsonTemplate);
					this.treeServerLoader.baseParams.fieldType = Ext.getCmp('jobDesign_fieldType_create').getValue();
					//重新加载树形菜单
					treeRoot.reload();
					
					//完全展开树形菜单
					Ext.getCmp("serverTree").root.expand();
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
			id : 'jobDesignMoveServersGrid',
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
			id : 'jobDesignExcgridMovedServersGrid',
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
        	id:'jobDesign_timer_create',
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
		var i = 0;  
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
	        var btnPrev = Ext.getCmp("jobDesign_movePrev_create");  
	        var btnSave = Ext.getCmp("jobDesign_moveSave_create");  
	        var btnNext = Ext.getCmp("jobDesign_moveNext_create");  
	        if (i == 0) {  
	            btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.disable(); 
	        }  
	        if(i == 1){
	            var jobName = Ext.getCmp('jobDesign_jobName_create').getValue();
				if (jobName == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobName.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				if (jobName.length>30) {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobName.overlength" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});  
					return i = 0;
				}
				var jobDesc = Ext.getCmp('jobDesign_jobDesc_create').getValue();
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
				if (Ext.getCmp('jobDesign_checkType_create').getValue() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobType.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var authorizeLeverType = Ext.getCmp('jobDesign_authorize_lever_type_create').getValue() ;
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
				//alert(Ext.getCmp('server_target_typeID').getValue()) 0
				if(Ext.getCmp('server_target_typeID').getValue()=='0'){
					Ext.getCmp('jobDesign_cardPanel_create').items.add(2,serverPanel);
  					Ext.getCmp('jobDesign_cardPanel_create').doLayout(); 
				}
			 	if(Ext.getCmp('server_target_typeID').getValue()=='1'){
					Ext.getCmp('jobDesign_cardPanel_create').items.add(2,panelThree);
  					Ext.getCmp('jobDesign_cardPanel_create').doLayout(); 
				} 
				if(authorizeLeverType == '1'){ //常规巡巡检
					Ext.getCmp('jobDesign_cardPanel_create').items.add(4,panelFour);
  					Ext.getCmp('jobDesign_cardPanel_create').doLayout(); 
				}
				if(authorizeLeverType == '2'){ //临时巡巡检
					Ext.getCmp('jobDesign_cardPanel_create').items.remove(4);
  					Ext.getCmp('jobDesign_cardPanel_create').doLayout(); 
				}
				
				if (Ext.getCmp('jobDesign_fieldType_create').getValue() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.fieldType.notNull" />',
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
	            var flagTemplate = false ; //模板不为空标志	    		var storeTemplate = this.gridTemplate.getStore();
	    		var jsonTemplate = [];
	    		storeTemplate.each(function(item) {
	    			jsonTemplate.push(item.data);
	    		});
	    		
	    	 	if(jsonTemplate!=null && jsonTemplate.length>0){
	    			Ext.getCmp("templates").setValue( Ext.util.JSON.encode(jsonTemplate));
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
	    		
	    		
	    		
	    		var authorizeLeverType = Ext.getCmp('jobDesign_authorize_lever_type_create').getValue() ;
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
	    		if(Ext.getCmp('server_target_typeID').getValue()=='1'){
		    		storeServer.each(function(item) {
		    			jsonServer.push(item.data);
		    		});
		    		if(jsonServer!=null && jsonServer.length>0){
		    			Ext.getCmp("servers").setValue( Ext.util.JSON.encode(jsonServer));
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
	    		if(Ext.getCmp('server_target_typeID').getValue()=='0'){
	    			this.gridMovedServersStore.each(function(item) {
		    			jsonServer.push(item.data);
		    		});
		    		if(jsonServer!=null && jsonServer.length>0){
		    			Ext.getCmp("servers").setValue( Ext.util.JSON.encode(jsonServer));
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
			id : 'jobDesign_cardPanel_create',
			renderTo : document.body,
			height : 700,
			width : 600,
			layout : 'card',
			layoutConfig : {
				deferredRender : true
			},
			activeItem : 0,
			tbar : ['-',{
						id : 'jobDesign_movePrev_create',
						iconCls : 'button-previous',
						text : '<fmt:message key="job.stepBefore" />',
						disabled : true ,
						handler : cardHandler.createDelegate(this,[ -1 ])
					},'-',{
						id : 'jobDesign_moveSave_create',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						hidden : true,
						handler : this.doSave
					},'-',{
						id : 'jobDesign_moveNext_create',
						iconCls : 'button-next',
						text : '<fmt:message key="job.stepNext" />',
						handler : cardHandler.createDelegate(this, [ 1 ])
					} ],
			items : [panelOne,panelTwo/* ,serverPanel,panelThree */]
		});
		
		// 设置基类属性		JobInfoCreateForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180 ,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			method : 'POST',
			url : '${ctx}/${appPath}/jobdesign/create',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			items : [{
				layout : 'fit',
				items :[this.cardPanel] 
			}]
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
	
	// 保存操作
	doSave : function() {
		var autLeverType = Ext.getCmp('jobDesign_authorize_lever_type_create').getValue();
        if(autLeverType=='2'){ //临时巡检
        	//组件不为空        	var flagServer = false ; 
        	var storeServer = gridServer.getStore();
    		var jsonServer = [];
    		if(Ext.getCmp('server_target_typeID').getValue()=='1'){
	    		storeServer.each(function(item) {
	    			jsonServer.push(item.data);
	    		});
	    		if(jsonServer!=null && jsonServer.length>0){
	    			Ext.getCmp("servers").setValue( Ext.util.JSON.encode(jsonServer));
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
    		if(Ext.getCmp('server_target_typeID').getValue()=='0'){
    			Ext.getCmp('jobDesignExcgridMovedServersGrid').getStore().each(function(item) {
	    			jsonServer.push(item.data);
	    		});
	    		if(jsonServer!=null && jsonServer.length>0){
	    			Ext.getCmp("servers").setValue( Ext.util.JSON.encode(jsonServer));
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
        }else{ //常规巡检
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
   			var once = Ext.getCmp('type_once').getValue();
   			var	daily = Ext.getCmp('type_daily').getValue();
   			var	weekly = Ext.getCmp('type_weekly').getValue();		
   			var	monthly = Ext.getCmp('type_monthly').getValue();
   			var	interval = Ext.getCmp('type_interval').getValue();
   			if(once){
   				freqFlag = true ;
   				if(Ext.getCmp('once_date_create').getValue() != ''){
   					execDate = Ext.getCmp('once_date_create').getValue().format('Y-m-d');
   				}
   				if(execDate == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					}); 
   					return false;
   				}
   				execTime = Ext.getCmp('once_time_create').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空，请输入合法的时间

   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
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
   					return false;
   				}
   				arrayOnce.push(execDate+" "+execTime);
   				//插入增加时间表数据
   				for(var t=0 ; t<=delButNumOnce ; t++){
   					var addDateValue = '';
   					var addTimeValue = '';
   					if(Ext.getCmp('once_date_create_'+t)){
   						addDateValue = Ext.getCmp('once_date_create_'+t).getValue().format('Y-m-d');
   					}
   					if(Ext.getCmp('once_time_create_'+t)){
   						addTimeValue = Ext.getCmp('once_time_create_'+t).getValue();
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
   								return false;
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
   							return false;
   						}
   					}
   				}
   			}
   			if(daily){
   				freqFlag = true ;
   				execTime = Ext.getCmp('daily_time_create').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
   				}
   				var dateValue = new Date().format('Y-m-d') ;
   				arrayDaily.push(dateValue+' '+execTime);
   				//插入增加时间表数据
   				for(var t=0 ; t<=delButNumDaily ; t++){
   					if(Ext.getCmp('daily_time_create_'+t)){
   						var addValue = Ext.getCmp('daily_time_create_'+t).getValue();
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
   							return false;
   						}
   					}
   				}
   			}
   			if(weekly){
   				freqFlag = true ;
   				execTime = Ext.getCmp('weekly_time_create').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
   				}
   				var daysOfWeek = Ext.getCmp('interval_weeks_create').getValue() ; //周间隔数
   				var mon = Ext.getCmp('mon_create').getValue();
   				var tus = Ext.getCmp('tus_create').getValue();
   				var wen = Ext.getCmp('wen_create').getValue();
   				var thu = Ext.getCmp('thu_create').getValue();
   				var fri = Ext.getCmp('fri_create').getValue();
   				var sat = Ext.getCmp('sat_create').getValue();
   				var sun = Ext.getCmp('sun_create').getValue();
   				if(!mon && !tus && !wen && !thu && !fri && !sat && !sun){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.execWeekNull" />!', //请勾选每周的执行星期
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
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
   				if(Ext.getCmp('monthly_time_create')){
   					execTime = Ext.getCmp('monthly_time_create').getValue() ;
   				}
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
   				}
   				var daysOfMonth = Ext.getCmp('month_day_create').getValue() ;
   				arrayMonthly.push(new Date().format('Y-m-d')+' '+execTime+'&'+daysOfMonth);
   			}
   			if(interval){
   				freqFlag = true ;
   				if(Ext.getCmp('interval_date_create').getValue() != ''){
   					execDate = Ext.getCmp('interval_date_create').getValue().format('Y-m-d');
   				}
   				if(execDate == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.dateError" />!', //日期不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
   				}
   				execTime = Ext.getCmp('interval_time_create').getValue() ;
   				if(execTime == ''){
   					Ext.Msg.show( {
   						title : '<fmt:message key="message.title" />',
   						msg : '<fmt:message key="job.timeError" />!', //时间不能为空
   						buttons : Ext.MessageBox.OK,
   						icon : Ext.MessageBox.INFO,
   						minWidth : 200
   					});
   					return false;
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
   					return false;
   				}
   				var days = Ext.getCmp('interval_day_create').getValue();
   				var hours = Ext.getCmp('interval_hour_create').getValue();
   				var mins = Ext.getCmp('interval_min_create').getValue();
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
   	        	return false;
   	        }
    		Ext.getCmp("timerOnceVals").setValue(arrayOnce);
    		Ext.getCmp("timerDailyVals").setValue(arrayDaily);
    		Ext.getCmp("timerWeeklyVals").setValue(arrayWeekly);
    		Ext.getCmp("timerMonthlyVals").setValue(arrayMonthly);
    		Ext.getCmp("timerIntervalVals").setValue(arrayInterval);
        }
		//提交表单
		jicf.getForm().submit({
			scope : jicf,
			timeout : 1800000, //半小时			success : jicf.saveSuccess,
			failure : jicf.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	findIp : function() {
		Ext.getCmp('jobDesignMoveServersGrid').getStore().baseParams.serverIp=Ext.getCmp('serverIpId').getValue();
		Ext.getCmp('jobDesignMoveServersGrid').getStore().reload();
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
	// 取消操作
	doCancel : function() {
		app.closeTab('JOB_DESIGN_CREATE');
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
				app.closeTab('JOB_DESIGN_CREATE');
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
	}
	
});
var jicf = new JobInfoCreateForm();
//实例化新建表单,并加入到Tab页中
Ext.getCmp("JOB_DESIGN_CREATE").add(jicf);
//刷新Tab页布局
Ext.getCmp("JOB_DESIGN_CREATE").doLayout();

</script>
<sec:authorize access="hasRole('CHECK_OBJECT')">
	<script type="text/javascript">
 	var checkObjects = new Array();
	checkObjects.push(new checkObject({value:'1',name:'智能组'}));
	serverStore.add(checkObjects) 
	</script>
</sec:authorize>
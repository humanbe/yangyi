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
var gridServer = null ;

//组件列表字段信息
var fieldsServer = Ext.data.Record.create([
	{name: 'server_group', mapping : 'server_group', type : 'string'}, 
	{name: 'server_ip', mapping : 'server_ip', type : 'string'}
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
			id: 'type_once_appjob',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_create_appjob',
         items: [{
			xtype:'datefield',
			format:'y-m-d',
			fieldLabel: '<fmt:message key="job.timer_date" />',
			id : 'once_date_create_appjob' ,
			editable : false ,
			minValue : new Date(),
			value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
			anchor:'88%'
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
	 	labelWidth:40,
	 	id:'once_times_create_appjob',
        items: [{
			xtype:'timefield',
			anchor:'97%',
			id : 'once_time_create_appjob' ,
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
		id : 'buttons_create_once_appjob',
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
		  					id:'once_date_create_appjob_'+delButNumOnce,
		  					editable : false ,
		  					minValue : new Date(),
		  					value : new Date().format('Y-m-d H:i:s').substring(2,10) ,
		  					anchor:'88%'
	  					});
	  					Ext.getCmp('once_dates_create_appjob').items.add(delButNumOnce,df);
	  					Ext.getCmp('once_dates_create_appjob').doLayout(); 
	  					
	  					//增加时间列
	  					var tf = new Ext.form.TimeField({
		  			  		anchor:'97%',
		  					id:'once_time_create_appjob_'+delButNumOnce,
		  					fieldLabel:'<fmt:message key="job.timer_time" />',
		  					format:'H:i:s',
		  					maxValue:'23:59 PM',
		  					minValue:'0:00 AM',
		  					value : new Date().format('Y-m-d H:i:s').substring(11) ,
		  					increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('once_times_create_appjob').items.add(delButNumOnce,tf);
	  					Ext.getCmp('once_times_create_appjob').doLayout(); 
	  					
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						text:'<fmt:message key="button.delete" />',
	  						iconCls : 'row-delete',
	  						height : 20 ,
	  						id : 'buttons_create_once_appjob_'+delButNumOnce,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(27);
	  								Ext.getCmp('once_dates_create_appjob').remove(size);
	  			  					Ext.getCmp('once_dates_create_appjob').doLayout(); 
		  			  				Ext.getCmp('once_times_create_appjob').remove(size);
	  			  					Ext.getCmp('once_times_create_appjob').doLayout(); 
	  			  					Ext.getCmp('buttons_create_once_appjob').remove(size);
	  			  					Ext.getCmp('buttons_create_once_appjob').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_create_once_appjob').items.add(delButNumOnce,bt);
	  					Ext.getCmp('buttons_create_once_appjob').doLayout(); 
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
			id: 'type_daily_appjob',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_create_appjob' ,
        items: [{
				xtype:'timefield',
	  			anchor:'98%',
	  			id : 'daily_time_create_appjob' ,
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
		id : 'buttons_create_daily_appjob',
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
	  			  			id:'daily_time_create_appjob_'+delButNumDaily,
	  			  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			  			format:'H:i:s',
	  			  			maxValue:'23:59 PM',
	  			  			minValue:'0:00 AM',
	  			  			value : new Date().format('Y-m-d H:i:s').substring(11) ,
	  			  			increment:30  //间隔30分钟
	  					});
	  					Ext.getCmp('daily_times_create_appjob').items.add(delButNumDaily,tdTime);
	  					Ext.getCmp('daily_times_create_appjob').doLayout(); 
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						text:'<fmt:message key="button.delete" />',
	  						iconCls : 'row-delete',
	  						height : 20 ,
	  						id : 'buttons_create_daily_appjob_'+delButNumDaily,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(28);
	  								Ext.getCmp('daily_times_create_appjob').remove(size);
	  			  					Ext.getCmp('daily_times_create_appjob').doLayout(); 
	  			  					Ext.getCmp('buttons_create_daily_appjob').remove(size);
	  			  					Ext.getCmp('buttons_create_daily_appjob').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('buttons_create_daily_appjob').items.add(delButNumDaily,bt);
	  					Ext.getCmp('buttons_create_daily_appjob').doLayout(); 
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
				id:'type_weekly_appjob',
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
				id : 'interval_weeks_create_appjob' ,
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
	  			id : 'weekly_time_create_appjob' ,
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
	 id : 'weeks_create_appjob' ,
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
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_create_appjob' , value:'2'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_create_appjob' , value:'4'},
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_create_appjob' , value:'8'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_create_appjob' , value:'16'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_create_appjob' ,  value:'32'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_create_appjob' , /* checked:true ,  */value:'64'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_create_appjob' ,/*  checked:true , */value:'1'}
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
			id:'type_monthly_appjob',
			inputValue: '4'
		}]
    },{
        columnWidth:.4,
        layout: 'form',
		labelWidth:60,
		id:'monthly_days_create_appjob',
        items: [{
        	xtype:'spinnerfield',
        	anchor:'88%',
        	name: 'month_day',
        	id : 'month_day_create_appjob' ,
			fieldLabel: '<fmt:message key="job.day_sort" />',
			minValue : 1 ,
			maxValue : 31 ,
			value : 1 
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
		labelWidth:40,
		id:'monthly_times_create_appjob',
        items: [{
        	xtype:'timefield',
			anchor:'97%',
			id : 'monthly_time_create_appjob' ,
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
			//labelSeparator: '',
			boxLabel: '<fmt:message key="job.interval" />',
			name: 'exec_freq_type',
			id:'type_interval_appjob',
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
			id : 'interval_date_create_appjob' ,
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
 			id : 'interval_time_create_appjob' ,
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
	 id : 'interval_gap_create_appjob' ,
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
        	 id : 'interval_day_create_appjob',
        	 minValue : 0 ,
        	 maxValue : 365 ,
        	 value : 0 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_create_appjob',
	       	 minValue : 0 ,
	       	 maxValue : 24 ,
	       	 value : 1
	     },{
	       	 xtype: 'spinnerfield',
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_create_appjob',
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
AppJobInfoCreateForm = Ext.extend(Ext.FormPanel, {
	PanelServer : null, // 组件页签 - 表单组件 
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
	
	PanelTemplate : null, // 模板页签 - 表单组件 
    gridTemplate :null,   // 列表组件 - 列表组件
	treeTemplate : null,  // 树形组件 - 树形组件
	
	csmServer : null,  // 组件页签 - 数据列表选择框组件
	csmTemplate : null,// 模板页签 - 数据列表选择框组件
	
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		csmServer = new Ext.grid.CheckboxSelectionModel();
		csmTemplate = new Ext.grid.CheckboxSelectionModel();
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
			dataUrl : '${ctx}/${appPath}/appjobdesign/getServerTree'
		});
		this.treeServer = new Ext.tree.TreePanel({
			id : 'serverTree_appjob',
			title : "<fmt:message key="job.select" /><fmt:message key="job.servers" />",
			//layout : 'fit' ,
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.servers" />',
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_SERVER_appjob'
			}),
			loader : this.treeServerLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.treeServer.expandAll();  //展开所有节点
					 /* this.treeServer.root.expand();  //展开根节点 */
					 if(!this.treeServer.root.hasChildNodes()){
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
				              if(pNode == this.treeServer.getRootNode()) return;
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
			id : 'serverPanel_appjob',
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
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'server_group', 'server_ip' ],
			remoteSort : true,
			sortInfo : {
				field : 'server_ip',
				direction : 'ASC'
			},
			baseParams : {
				/* start : 0,
				limit : 100 */
			}
		});
		gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid_appjob',
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.servers" />',
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
			columns : [ new Ext.grid.RowNumberer(), csmServer,
            {
				header : '<fmt:message key="job.server_ip" />',
				dataIndex : 'server_ip'
			},{
				header : '<fmt:message key="job.server_group" />',
				dataIndex : 'server_group'
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
			url : '${ctx}/${frameworkPath}/item/APP_CHECK_AUTHORIZE_LEVEL_TYPE/sub',
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
		this.languageTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/SCRIPT_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.languageTypeStore.load();
		
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
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.appsys_code" />',
				    id : 'appsysCode_create_appjob',
					emptyText : '<fmt:message key="job.select_please" />' , 
					store : this.appsysStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					hiddenName : 'appsys_code',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    allowBlank : false,
                    editable : true,  //输入 索引
                    forceSelection : true,
					tabIndex : this.tabIndex++ ,
					listeners : {
						scope : this,
						beforequery : function(e){
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
                	xtype:'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job" /><fmt:message key="job.name" />',
					name : 'job_name',
					id : 'jobName_create_appjob',
					maxLength : 30,
					allowBlank : false,
					listeners : {
						change : function() {
							var appsysCode = Ext.getCmp('appsysCode_create_appjob').getValue();
							var jobName = Ext.getCmp('jobName_create_appjob').getValue();
							Ext.Ajax.request({
								scope : this,
								timeout : 1800000, 
								method : 'POST',
								url : '${ctx}/${appPath}/appjobdesign/isJobRepeat',
								params : {
									appsysCode : appsysCode,
									jobName : jobName
								},
								success : function(response){
									if(Ext.decode(response.responseText).success == true){
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '重复的作业名称:'+jobName,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											minWidth : 200
										});
										Ext.getCmp('jobName_create_appjob').setValue('');
									}
						       } 
				           });
						}
					}
				},
				{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.type" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					id : 'checkType_create_appjob',
					name : 'check_type',
					value : '1',
					hidden : true ,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.authorize" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'authorize_lever_type',
					id : 'authorize_lever_type_create_appjob',
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
							Ext.getCmp('frontline_flag_create_appjob').setValue("0");
							var val = obj.getValue() ;
							if('1'==val){
								Ext.getCmp('frontline_flag_create_appjob').el.up('.x-form-item').setDisplayed(false);
							}
							if('2'==val){
								Ext.getCmp('frontline_flag_create_appjob').el.up('.x-form-item').setDisplayed(true);
							};
						}
					}
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.field" />',
					name : 'field_type',
					id : 'fieldType_create_appjob',
					value : 'APP',
					hidden : true
				} ,{
					xtype : 'textfield',
					fieldLabel : '作业类型',
					hiddenName : 'job_type',
					id : 'jobType_create_appjob',
					value : '2',
					hidden : true
				},{
					xtype : 'textfield',
					fieldLabel : '删除标示',
					hiddenName : 'delete_flag',
					id : 'delete_flag_create_appjob',
					value : '0',
					hidden : true
				},{
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="job.desc" />',
					height : 60,
					maxLength : 400 ,
					name : 'job_desc',
					id : 'jobDesc_create_appjob'
				},{
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
				},{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="job.frontline_flag" />',
					emptyText : '<fmt:message key="job.select_please" />' ,
					hiddenName : 'frontline_flag',
					id : 'frontline_flag_create_appjob',
					store : this.frontlineFlagStore,
					displayField : 'name',
					valueField : 'value',
					mode: 'local',
					typeAhead: true,
                    triggerAction: 'all',
                    editable : false, 
                    allowBlank : false,
                    hidden : true ,
                    hiddenValue : 1,
					tabIndex : this.tabIndex++
				},{ //是否需要授权
					xtype : 'combo',
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
				},{
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="job.creator" />',
					name : 'tool_creator' ,
					hidden : true
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'serverips_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerOnceVals_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerDailyVals_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerWeeklyVals_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerMonthlyVals_appjob'
				},{
					xtype : 'textfield',
					hidden : true, 
					id : 'timerIntervalVals_appjob'
				},
				{
					xtype : 'textfield',
					style  : 'background : #F0F0F0' , 
					fieldLabel : '<fmt:message key="property.scriptName" />',
					id : 'scriptName_create_appjob',
					name : 'script_name',
					hiddenName : 'script_name',
					maxLength : 200,
					readOnly : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'fileuploadfield',
					fieldLabel:'<font color=red>*</font>&nbsp;<fmt:message key="property.upload" />',
					id : '',
					name : '',
					hiddenName : '',
					buttonText : '<fmt:message key="property.glance" />',
					editable : true ,
					buttonCfg: {
						iconCls: 'upload-icon'
					},
					listeners : {
						scope : this,
						'fileselected' : function(fileField, path) {
							nshJobFilePath=path;
							var scriptName = path.substring(path.lastIndexOf('\\') + 1);
							Ext.getCmp('scriptName_create_appjob').setValue(scriptName);
						}
					}
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行路径',
					id : 'execPath_create_appjob',
					name : 'exec_path',
					maxLength : 200,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行用户',
					id : 'execUser_create_appjob',
					name : 'exec_user',
					maxLength : 20,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;执行用户组',
					id : 'execUserGroup_create_appjob',
					name : 'exec_user_group',
					maxLength : 20,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : this.languageTypeStore,
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="property.scriptType" />',
					id : 'languageTypeId_create_appjob',
					name : 'language_type',
					hiddenName : 'language_type',
					displayField : 'name',
					valueField : 'name',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++
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
					id : 'script_appjob',
					name : 'script_appjob',
					height : 645,
					readOnly : true,
					tabIndex : this.tabIndex++
				}]
			}]
		});
	    panelThree = new Ext.Panel({  
	    	title : '<fmt:message key="job.servers" />',
	    	layout : 'hbox',
			region:'center',
			border : false,
			defaults : { flex : 1 },
			layoutConfig : { align : 'stretch' },
			items : [this.treeServer,this.PanelServer,gridServer],
			listeners : {
				scope : this,
				'activate' : function(panel) {
					var treeRoot = Ext.getCmp("serverTree_appjob").getRootNode();
					this.treeServerLoader.baseParams.appsysCode = Ext.getCmp('appsysCode_create_appjob').getValue();
					//重新加载树形菜单
					treeRoot.reload();
					//完全展开树形菜单
					Ext.getCmp("serverTree_appjob").root.expand();
				}
			}
	    }); 
	    panelFour = new Ext.Panel({ 
	    	title:'<fmt:message key="job.timer" />',
        	id:'timer_create_appjob',
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
                }, fieldset4,{
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
			title : '<fmt:message key="job.notify_conf" />',
            layout:'form', 
            id:'mailConf_create_appjob',
            autoScroll : true , 
            labelAlign : 'right',
            defaults:{bodyStyle:'padding-left:110px;padding-top:40px'},
            iconCls : 'menu-node-trouble',
            border:false,
            items: [{
            	xtype : 'label'
             },{
                xtype : 'textfield',
                vtype : 'emailList',  
                compare : 'emailListText', 
                anchor : '90%',
                fieldLabel: '<fmt:message key="job.mail_list" />',
                name: 'exec_notice_mail_list',
                maxLength : 1000,
                value : '<%=userEmail%>',
                id:'mail_list_create_appjob'
            }, {
               	xtype: 'checkbox',
                fieldLabel: '<fmt:message key="job.status_val" />',
                boxLabel: '<fmt:message key="job.success" />',
                inputValue : '2',
                id:'mail_success_create_appjob',
                name: 'mail_success_flag'
            }, {
            	xtype: 'checkbox',
                fieldLabel: '',
                labelSeparator: '',
                boxLabel: '<fmt:message key="job.failure" />',
                inputValue : '4',
                checked: true,
                name: 'mail_failure_flag',
                id:'mail_failure_create_appjob'
            }, {
            	xtype: 'checkbox',
                checked: true, 
                fieldLabel: '',
                boxLabel: '<fmt:message key="job.cancel" />',
                inputValue : '8',
                name: 'mail_cancel_flag',
                id:'mail_cancel_create_appjob'
            }]
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
	            if (i > 4) {  
	                i = 4;  
	                return false;  
	            }  
	        }  
	        var btnPrev = Ext.getCmp("movePrev_create_appjob");  
	        var btnSave = Ext.getCmp("moveSave_create_appjob");  
	        var btnNext = Ext.getCmp("moveNext_create_appjob");  
	        if (i == 0) {  
	            btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.disable(); 
	        }  
	        if(i == 1){
	        	var appsysCode =  Ext.getCmp('appsysCode_create_appjob').getValue();
	            if (appsysCode == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobAppSys.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
	            var jobName = Ext.getCmp('jobName_create_appjob').getValue();
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
				var jobDesc = Ext.getCmp('jobDesc_create_appjob').getValue();
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
				if (Ext.getCmp('checkType_create_appjob').getValue() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.jobType.notNull" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				var authorizeLeverType = Ext.getCmp('authorize_lever_type_create_appjob').getValue() ;
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
				
				var scriptName = Ext.getCmp('scriptName_create_appjob').getValue() ;
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
				var execPath = Ext.getCmp('execPath_create_appjob').getValue() ;
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
				var execUser = Ext.getCmp('execUser_create_appjob').getValue() ;
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
				var execUserGroup = Ext.getCmp('execUserGroup_create_appjob').getValue() ;
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
				var languageType = Ext.getCmp('languageTypeId_create_appjob').getValue() ;
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
				//读取上传脚本信息
				jicf.getForm().submit(
				{
					url : '${ctx}/${appPath}/appjobdesign/showShData',
					scope : jicf,
					success : jicf.showScriptSuccess
				});
				if(authorizeLeverType == '1'){ //常规巡巡检
					Ext.getCmp('cardPanel_create_appjob').items.add(3,panelFour);
					Ext.getCmp('cardPanel_create_appjob').items.add(4,panelFive);
  					Ext.getCmp('cardPanel_create_appjob').doLayout(); 
				}
				if(authorizeLeverType == '2'){ //临时巡巡检
					Ext.getCmp('cardPanel_create_appjob').items.remove(3);
					Ext.getCmp('cardPanel_create_appjob').items.remove(4);
  					Ext.getCmp('cardPanel_create_appjob').doLayout(); 
				}
				btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.enable();
	        }
	        if(i == 2){
	        	var authorizeLeverType = Ext.getCmp('authorize_lever_type_create_appjob').getValue() ;
				if(authorizeLeverType == '1'){ //常规巡巡检
					btnSave.hide();  
		            btnNext.enable();  
		            btnPrev.enable(); 
				}
				if(authorizeLeverType == '2'){ //临时巡巡检
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
	    			Ext.getCmp("serverips_appjob").setValue( Ext.util.JSON.encode(jsonServer));
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
	   			var once = Ext.getCmp('type_once_appjob').getValue();
	   			var	daily = Ext.getCmp('type_daily_appjob').getValue();
	   			var	weekly = Ext.getCmp('type_weekly_appjob').getValue();		
	   			var	monthly = Ext.getCmp('type_monthly_appjob').getValue();
	   			var	interval = Ext.getCmp('type_interval_appjob').getValue();
	   			if(once){
	   				freqFlag = true ;
	   				if(Ext.getCmp('once_date_create_appjob').getValue() != ''){
	   					execDate = Ext.getCmp('once_date_create_appjob').getValue().format('Y-m-d');
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
	   				execTime = Ext.getCmp('once_time_create_appjob').getValue() ;
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
	   					if(Ext.getCmp('once_date_create_appjob_'+t)){
	   						addDateValue = Ext.getCmp('once_date_create_appjob_'+t).getValue().format('Y-m-d');
	   					}
	   					if(Ext.getCmp('once_time_create_appjob_'+t)){
	   						addTimeValue = Ext.getCmp('once_time_create_appjob_'+t).getValue();
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
	   				execTime = Ext.getCmp('daily_time_create_appjob').getValue() ;
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
	   					if(Ext.getCmp('daily_time_create_appjob_'+t)){
	   						var addValue = Ext.getCmp('daily_time_create_appjob_'+t).getValue();
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
	   				execTime = Ext.getCmp('weekly_time_create_appjob').getValue() ;
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
	   				var daysOfWeek = Ext.getCmp('interval_weeks_create_appjob').getValue() ; //周间隔数
	   				var mon = Ext.getCmp('mon_create_appjob').getValue();
	   				var tus = Ext.getCmp('tus_create_appjob').getValue();
	   				var wen = Ext.getCmp('wen_create_appjob').getValue();
	   				var thu = Ext.getCmp('thu_create_appjob').getValue();
	   				var fri = Ext.getCmp('fri_create_appjob').getValue();
	   				var sat = Ext.getCmp('sat_create_appjob').getValue();
	   				var sun = Ext.getCmp('sun_create_appjob').getValue();
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
	   				if(Ext.getCmp('monthly_time_create_appjob')){
	   					execTime = Ext.getCmp('monthly_time_create_appjob').getValue() ;
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
	   				var daysOfMonth = Ext.getCmp('month_day_create_appjob').getValue() ;
	   				arrayMonthly.push(new Date().format('Y-m-d')+' '+execTime+'&'+daysOfMonth);
	   			}
	   			if(interval){
	   				freqFlag = true ;
	   				if(Ext.getCmp('interval_date_create_appjob').getValue() != ''){
	   					execDate = Ext.getCmp('interval_date_create_appjob').getValue().format('Y-m-d');
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
	   				execTime = Ext.getCmp('interval_time_create_appjob').getValue() ;
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
	   				var days = Ext.getCmp('interval_day_create_appjob').getValue();
	   				var hours = Ext.getCmp('interval_hour_create_appjob').getValue();
	   				var mins = Ext.getCmp('interval_min_create_appjob').getValue();
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
	    		Ext.getCmp("timerOnceVals_appjob").setValue(arrayOnce);
	    		Ext.getCmp("timerDailyVals_appjob").setValue(arrayDaily);
	    		Ext.getCmp("timerWeeklyVals_appjob").setValue(arrayWeekly);
	    		Ext.getCmp("timerMonthlyVals_appjob").setValue(arrayMonthly);
	    		Ext.getCmp("timerIntervalVals_appjob").setValue(arrayInterval);
	        	
	    		btnSave.show();  
	            btnNext.disable();  
	            btnPrev.enable();
	        }  
	        this.cardPanel.getLayout().setActiveItem(i);  
	    };  
	    //CARD总面板  
		this.cardPanel = new Ext.Panel({
			id : 'cardPanel_create_appjob',
			renderTo : document.body,
			height : 700,
			width : 600,
			layout : 'card',
			layoutConfig : {
				deferredRender : true
			},
			activeItem : 0,
			tbar : ['-',{
						id : 'movePrev_create_appjob',
						iconCls : 'button-previous',
						text : '<fmt:message key="job.stepBefore" />',
						disabled : true ,
						handler : cardHandler.createDelegate(this,[ -1 ])
					},'-',{
						id : 'moveSave_create_appjob',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						hidden : true,
						handler : this.doSave
					},'-',{
						id : 'moveNext_create_appjob',
						iconCls : 'button-next',
						text : '<fmt:message key="job.stepNext" />',
						handler : cardHandler.createDelegate(this, [ 1 ])
					} ],
			items : [panelOne,panelTwo,panelThree]
		});
		
		// 设置基类属性
		AppJobInfoCreateForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180 ,
			fileUpload : true, //有文件上传时，该属性必写
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			method : 'POST',
			url : '${ctx}/${appPath}/appjobdesign/create',
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
    
	//组件移入事件
	serverShiftIn : function() {
		var nodes = this.treeServer.getChecked();
    	var serverInfos = new Array();
    	for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){
		    	serverInfos.push(new fieldsServer({server_group:nodes[t].parentNode.text,server_ip:nodes[t].text}));
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

	//显示脚本信息
	showScriptSuccess : function(form, action) {
		var data = decodeURIComponent(action.result.data);
		Ext.getCmp('script_appjob').setValue(data);
		var bottom = this.getHeight();
		this.body.scroll("b", bottom, true);
	},
	
	
	//保存操作
	doSave : function() {
		var autLeverType = Ext.getCmp('authorize_lever_type_create_appjob').getValue();
        if(autLeverType=='2'){ //临时巡检
    		//组件不为空
        	var flagServer = false ; 
        	var storeServer = gridServer.getStore();
    		var jsonServer = [];
    		storeServer.each(function(item) {
    			jsonServer.push(item.data);
    		});
    		if(jsonServer!=null && jsonServer.length>0){
    			Ext.getCmp("serverips_appjob").setValue( Ext.util.JSON.encode(jsonServer));
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
    			return false;
    		}
        }else{ //常规巡检
        	//通知配置
    		var mails = Ext.getCmp('mail_list_create_appjob').getValue();
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
        		var success = Ext.getCmp('mail_success_create_appjob').getValue();
        		var failure = Ext.getCmp('mail_failure_create_appjob').getValue();
        		var cancel = Ext.getCmp('mail_cancel_create_appjob').getValue();
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
        } 
		//提交表单
		jicf.getForm().submit({
			scope : jicf,
			timeout : 1800000, //半小时
			success : jicf.saveSuccess,
			failure : jicf.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	
	// 取消操作
	doCancel : function() {
		app.closeTab('APP_JOB_DESIGN_CREATE');
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
				app.closeTab('APP_JOB_DESIGN_CREATE');
				var list = Ext.getCmp("APP_JOB_DESIGN_INDEX").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				app.loadTab('APP_JOB_DESIGN_INDEX', '<fmt:message key="appjob" />', '${ctx}/${appPath}/appjobdesign/index');
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
var jicf = new AppJobInfoCreateForm();

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("APP_JOB_DESIGN_CREATE").add(jicf);
// 刷新Tab页布局
Ext.getCmp("APP_JOB_DESIGN_CREATE").doLayout();

</script>
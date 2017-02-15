<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var delButNumOnce = 100 ; //删除按钮序号 - 一次
var delButNumDaily = 100 ; //删除按钮序号 - 每天
var delButNumMonthly = 100 ; //删除按钮序号 - 每月

//作业时间表   一次
var fieldset1 = new Ext.form.FieldSet({
	 title: '',
     autoHeight:true,
     /* defaults: {width: 700}, */ 
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
			xtype:'checkbox',
			fieldLabel: '',
			disabled:true,
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.timer_once" />',
			name: 'exec_freq_type',
			id: 'type_once_view_appjob',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_view_appjob',
         items: [{
			xtype:'datefield',
			disabled:true,
			format:'y-m-d',
			id:'once_date_view_appjob',
			minValue : new Date(),
			fieldLabel:'<fmt:message key="job.timer_date" />',
			editable : false,
			anchor:'88%'
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
	 	labelWidth:40,
	 	id : 'once_times_view_appjob' ,
        items: [{
			xtype:'timefield',
			disabled:true,
			anchor:'97%',
			id : 'once_time_view_appjob' ,
			fieldLabel:'<fmt:message key="job.timer_time" />',
			format:'H:i:s',
			maxValue:'23:59 PM',
			minValue:'0:00 AM',
			increment:30  //间隔30分钟
		}]
    }]
}); 

//作业时间表   每天
var fieldset2 = new Ext.form.FieldSet({
    // labelAlign: 'top',
 	title: '',
    autoHeight:true,
    layout:'column',
    items:[{
        columnWidth:.15,
        layout: 'form',
		labelWidth:25,
        items: [{
			xtype:'checkbox',
			disabled : true,
			fieldLabel: '',
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.timer_daily" />',
			name: 'exec_freq_type',
			id: 'type_daily_view_appjob',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_view_appjob' ,
        items: [{
			xtype:'timefield',
			disabled : true,
  			anchor:'98%',
  			id : 'daily_time_view_appjob' ,
  			fieldLabel:'<fmt:message key="job.timer_time" />',
  			format:'H:i:s',
  			maxValue:'23:59 PM',
  			minValue:'0:00 AM',
  			increment:30  //间隔30分钟
		  }]
	}]
});

//作业时间表   每周
var fieldset3 = new Ext.form.FieldSet({
    // labelAlign: 'top',
	 title: '',
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
				xtype:'checkbox',
				disabled : true,
				fieldLabel: '',
				labelSeparator: '',
				boxLabel: '<fmt:message key="job.timer.weekly" />',
				name: 'exec_freq_type',
				id:'type_weekly_view_appjob',
				inputValue: '3'
			}]
      },{
    	  columnWidth:.4,
    	  layout: 'form',
 		  labelWidth:60,
          items: [{
        		anchor:'88%',
        		disabled : true,
				xtype:'spinnerfield',
				fieldLabel: '<fmt:message key="job.interval_weeks" />',
				name: 'interval_weeks',
				id : 'interval_weeks_view_appjob' ,
				minValue : 1 ,
				maxValue : 52 
		  }]
	  },{
          layout: 'form',
          columnWidth:.45,
 		  labelWidth:40,
          items: [{
        	 	xtype:'timefield',
        	 	disabled : true,
	  			anchor:'75%',
	  			id : 'weekly_time_view_appjob' ,
	  			fieldLabel:'<fmt:message key="job.timer_time" />',
	  			format:'H:i:s',
	  			maxValue:'23:59 PM',
	  			minValue:'0:00 AM',
	  			increment:30  //间隔30分钟
		}]
 	 }]
});

//作业时间表   每周-星期
var fieldsetWeeks = new Ext.form.FieldSet({
	 title: '',
	 id : 'weeks_view_appjob' ,
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
				disabled : true,
	         	fieldLabel: '<fmt:message key="job.days_in" />',
	         	anchor:'85%',
	         	items: [
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_view_appjob',value:'2'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_view_appjob' ,value:'4'},
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_view_appjob',value:'8'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_view_appjob', value:'16'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_view_appjob',value:'32'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_view_appjob',value:'64'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_view_appjob', value:'1'}
		        ]
		}]
 	}]
}); 

//作业时间表   每月
var fieldset4 = new Ext.form.FieldSet({
    // labelAlign: 'top',
 	title: '',
    autoHeight:true,
    layout:'column',
    items:[{
        columnWidth:.15,
        layout: 'form',
		labelWidth:25,
        items: [{
			xtype:'checkbox',
			disabled : true,
			fieldLabel: '',
			labelSeparator: '',
			boxLabel: '<fmt:message key="job.monthly" />',
			name: 'exec_freq_type',
			id:'type_monthly_view_appjob',
			inputValue: '4'
		}]
    },{
        columnWidth:.4,
        layout: 'form',
		labelWidth:60,
        items: [{
        	xtype:'spinnerfield',
        	disabled : true,
        	anchor:'88%',
        	name: 'month_day',
        	id : 'month_day_view_appjob' ,
			fieldLabel: '<fmt:message key="job.day_sort" />',
			minValue : 1 ,
			maxValue : 31 
		  }]
	},{
        columnWidth:.45,
        layout: 'form',
		labelWidth:40,
        items: [{
        	xtype:'timefield',
        	disabled : true,
			anchor:'75%',
			id : 'monthly_time_view_appjob' ,
			fieldLabel:'<fmt:message key="job.timer_time" />',
			format:'H:i:s',
			maxValue:'23:59 PM',
			minValue:'0:00 AM',
			increment:30  //间隔30分钟
		}]
    }]
});

//作业时间表   时间间隔
var fieldset5 = new Ext.form.FieldSet({
     // labelAlign: 'top',
	 title: '',
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.15,
         layout: 'form',
		 labelWidth:25,
         items: [{
			xtype:'checkbox',
			disabled : true,
			fieldLabel: '',
			//labelSeparator: '',
			boxLabel: '<fmt:message key="job.interval" />',
			name: 'exec_freq_type',
			id:'type_interval_view_appjob',
			inputValue: '5'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
         items: [{
			xtype:'datefield',
			disabled : true,
			format:'y-m-d',
			minValue : new Date(),
			fieldLabel: '<fmt:message key="job.timer_date" />',
			id : 'interval_date_view_appjob' ,
			editable : false,
			anchor:'88%'
		  }]
	},{
         columnWidth:.45,
         layout: 'form',
		 labelWidth:40,
         items: [{
        	xtype:'timefield',
        	disabled : true,
 			anchor:'75%',
 			id : 'interval_time_view_appjob' ,
 			fieldLabel:'<fmt:message key="job.timer_time" />',
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
	 id : 'interval_gap_view_appjob' ,
     autoHeight:true,
     layout:'column',
     items:[{
         columnWidth:.22,
         layout: 'form',
		 labelWidth:300,
         items: []
 	},{
         columnWidth:.78,
         layout: 'form',
         items: [{
        	 xtype: 'spinnerfield',	
        	 disabled : true,
        	 anchor : '70%',
        	 fieldLabel: '<fmt:message key="job.repeat_day" /> &nbsp;&nbsp;&nbsp;<fmt:message key="job.days" />',
        	 name : 'interval_days',
        	 id : 'interval_day_view_appjob',
        	 minValue : 0 ,
        	 maxValue : 365 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 disabled : true,
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_view_appjob',
	       	 minValue : 0 ,
	       	 maxValue : 24 
	     },{
	       	 xtype: 'spinnerfield',
	         disabled : true,
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_view_appjob',
	       	 minValue : 0 ,
	       	 maxValue : 59 
	     }]
 	}]
});

//作业时间表   优先级
var fieldset7 = new Ext.form.FieldSet({
 	title: '',
    autoHeight:true,
    labelWidth:80,
    items: [{
		xtype: 'radiogroup',
		disabled : true,
     	fieldLabel: '<fmt:message key="job.priority" />&nbsp;&nbsp;',
     	anchor:'55%',
     	id : 'priorrity_view_appjob',
     	items: [
     	       {boxLabel: '<fmt:message key="job.lowest" />', name: 'exec_priority', id: 'LOWEST_view_appjob', inputValue: 'LOWEST'},
               {boxLabel: '<fmt:message key="job.low" />', name: 'exec_priority', id: 'LOW_view_appjob', inputValue: 'LOW'},
               {boxLabel: '<fmt:message key="job.normal" />', name: 'exec_priority', id: 'NORMAL_view_appjob', inputValue: 'NORMAL'},
               {boxLabel: '<fmt:message key="job.high" />', name: 'exec_priority', id: 'HIGH_view_appjob', inputValue: 'HIGH'},
               {boxLabel: '<fmt:message key="job.critical" />', name: 'exec_priority', id: 'CRITICAL_view_appjob', inputValue: 'CRITICAL'}
         ]
	}]
}); 

JobDesignViewForm = Ext.extend(Ext.FormPanel, {
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
	csmServer : null,  // 组件页签 - 数据列表选择框组件
	
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
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
		csmServer = new Ext.grid.CheckboxSelectionModel();
		
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
		
		// 定义组件页签左侧树形组件------------------------------------begin
		this.treeServerLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/appjobdesign/getServerTreeForEdit'
		}); 
		this.treeServer = new Ext.tree.TreePanel({
			id : 'serverTree_view_appjob',
			title : '<fmt:message key="job.select" />服务器',
			height : 638 ,
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.server" />',
				draggable : false,
				iconCls : 'node-root'
			}),
			loader : this.treeServerLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.treeServer.expandAll();  //展开所有节点
					 /* this.treeServer.root.expand();  //展开根节点 */
				 }
			}
		});
		// 定义组件页签树形组件----------------------------------------end
	
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
		this.gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid_view_appjob',
			height : 638 ,
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
			columns : [ new Ext.grid.RowNumberer(),/*  csmServer, */
            {
				header : '<fmt:message key="job.server_ip" />',
				width : 220,
				dataIndex : 'server_name'
			},{
				header : '<fmt:message key="job.server_group" />',
				width : 220,
				dataIndex : 'server_path'

			}]
		}); 
		// 定义组件页签右侧列表组件--------------------------------------end
		//this.treeServer.root.expand();
		
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
		
		// 设置基类属性
		JobDesignViewForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			buttonAlign : 'center',
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
		            xtype:'tabpanel',
		            plain:true,
		            forceLayout : true,
		            autoScroll:true,
		            enableTabScroll:true,
		            activeTab: 0,
		            deferredRender: false,
		            items:[{
		            	title:'<fmt:message key="job" /><fmt:message key="job.define" />',
		                layout:'column',
		                frame : true,
		                height:668,
		                defaults:{bodyStyle:'padding-left:110px;padding-top:40px'},
		                border:false,
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
									id : 'appsys_code_view_appjob',
									mode: 'local',
									typeAhead: true,
				                    triggerAction: 'all',
				                    readOnly : true 
								},{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="job.code_jeda" />',
									name : 'job_code',
									id : 'jobCode_view_appjob' ,
									tabIndex : this.tabIndex++,
									hidden : true
								},{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									fieldLabel : '<fmt:message key="job" /><fmt:message key="job.name" />',
									name : 'job_name',
									tabIndex : this.tabIndex++,
									readOnly : true
								},
								{
									xtype : 'combo',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="job.type" />',
									valueField : 'value',
									displayField : 'name',
									name : 'check_type',
									hiddenName : 'check_type' ,
									store : this.checkTypeStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									hidden : true ,
									tabIndex : this.tabIndex++
								}, 
								{
									xtype : 'combo',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="job.authorize" />',
									valueField : 'value',
									displayField : 'name',
									name : 'authorize_lever_type',
									hiddenName : 'authorize_lever_type' ,
									id : 'authorize_lever_type_view_appjob',
									store : this.authorizeLevelTypeStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'textarea',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="job.desc" />',
									name : 'job_desc',
									height : 60,
									maxLength : 100 ,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'combo',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="job.frontline_flag" />',
									valueField : 'value',
									displayField : 'name',
									name : 'frontline_flag',
									id : 'frontline_flag_view_appjob',
									hiddenName : 'frontline_flag',
									store : this.frontlineFlagStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									hidden : true ,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'combo',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="job.authorize_flag" />',
									valueField : 'value',
									displayField : 'name',
									name : 'authorize_flag',
									hiddenName : 'authorize_flag' ,
									store : this.authorizeFlagStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									hidden : true,
									editable : true,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									fieldLabel : '<fmt:message key="property.scriptName" />',
									id : 'scriptName_view_appjob',
									name : 'script_name',
									hiddenName : 'script_name',
									maxLength : 200,
									readOnly : true,
									tabIndex : this.tabIndex++
								},{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '执行路径',
									id : 'execPath_view_appjob',
									name : 'exec_path',
									maxLength : 200,
									tabIndex : this.tabIndex++
								},{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '执行用户',
									id : 'execUser_view_appjob',
									name : 'exec_user',
									tabIndex : this.tabIndex++
								}, {
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '执行用户组',
									id : 'execUserGroup_view_appjob',
									name : 'exec_user_group',
									tabIndex : this.tabIndex++
								}, {
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									readOnly : true,
									fieldLabel : '<fmt:message key="property.scriptType" />',
									id : 'languageTypeId_view_appjob',
									name : 'language_type',
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="job.creator" />',
									name : 'tool_creator' ,
									id : 'creatorId_view_appjob',
									tabIndex : this.tabIndex++,
									hidden : true,
									readOnly : true
								},
								{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									fieldLabel : '<fmt:message key="job.creator" />',
									name : 'tool_creator' ,
									id : 'creatorName_view_appjob',
									tabIndex : this.tabIndex++,
									readOnly : true
								}
						]}
		            ]}, 
		            {
		            	title : '<fmt:message key="title.script" />',
		    			items : [{
		    				layout : 'form',
		    				defaults : {
		    					anchor : '90%'
		    				},
		    				border : false,
		    				items : [{
		    					xtype : 'textarea',
		    					id : 'script_view_appjob',
		    					name : 'script_appjob',
		    					height : 645,
		    					readOnly : true,
		    					tabIndex : this.tabIndex++
		    				}]
		    			}]
		    			
		            },
		            {
		            	title : '<fmt:message key="job.servers" />',
		                layout:'form',
		                autoScroll : true ,
		                labelAlign : 'right',
		                iconCls : 'menu-node-trouble',
	                    border:false,
	                    items: [{
	                    	layout:'column',
			                border : true ,
			                height : 668 ,
			                items:[{
			                    columnWidth:.5,  
			                    border : false,
			                    defaults : { flex : 1 },
			                    layoutConfig : { align : 'stretch' },
			                    defaults:{bodyStyle:'padding-left:10px;padding-top:5px'},
			                    items : [this.treeServer]
			                },{
			                    columnWidth:.5,
			                    border:false,
			                    labelAlign : 'right',
			                    items: [this.gridServer]
			                }]
	                    }] 
		            },
		            {
		            	title:'<fmt:message key="job.timer" />',
		            	id:'timer_view_appjob',
		                autoScroll : true , 
		                border:false,
		                frame : true,
		                /* height : 620,  */
		                iconCls : 'menu-node-change',
		                layout: 'form',
		                bodyStyle : 'padding : 0, 30px, 0, 30px;',
		                defaults: {anchor:'97.5%'},
		                border:false,
		                labelAlign : 'right',
		                items:[{
		                    columnWidth:.8,
		                    layout: 'form',
		                    defaults: {anchor : '100%'},
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
		                }]
		            } , {
		            	title:'<fmt:message key="job.notify_conf" />',
		            	id:'mailConf_view_appjob',
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
          	                    anchor : '98%',
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
          							columnWidth : .98 , 
          							layout : 'form',
          							items: [{
          				                xtype : 'textfield',
          				                style  : 'background : #F0F0F0' , 
  										readOnly : true,
          				                compare : 'emailListText',
          				                //anchor : '98%',
          				                width : 650,
          				                fieldLabel: '<fmt:message key="job.mail_list" />',
          				             	maxLength : 1000,
          				                name: 'exec_notice_mail_list',
          				                id:'mail_list_view_appjob'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '<fmt:message key="job.status_val" />',
          				                boxLabel: '<fmt:message key="job.success" />',
          				                inputValue : '2',
          				                id:'mail_success_view_appjob',
          				                name: 'mail_success_flag'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '',
          				                labelSeparator: '',
          				                boxLabel: '<fmt:message key="job.failure" />',
          				                inputValue : '4',
          				                id:'mail_failure_view_appjob',
          				                name: 'mail_failure_flag'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '',
          				                labelSeparator: '',
          				                boxLabel: '<fmt:message key="job.cancel" />',
          				                inputValue : '8',
          				                id:'mail_cancel_view_appjob',
          				                name: 'mail_cancel_flag'
          				            }]
          						}]
          			        }]
	                    }]
		            }
		        ]}
	  		],
			// 定义按钮grid
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			}]
		});

		// 加载表单数据
		this.load( {
			url : '${ctx}/${appPath}/appjobdesign/view/${param.jobid}',
			method : 'GET',
			//waitTitle : '<fmt:message key="message.wait" />',
			//waitMsg : '<fmt:message key="message.loading" />', 
			scope : this,
			success : this.loadSuccess,
			failure : this.loadFailure
		});
	},
	

	
	// 数据加载成功回调
	loadSuccess : function(form, action) {
		app.mask.show(); //请稍后		this.getForm().submit(
		{
			url : '${ctx}/${appPath}/appjobdesign/showShDataFromBsa',
			scope : this,
			timeout : 1800000,
			success : function(form, action) {
				app.mask.hide();
				var data = decodeURIComponent(action.result.data);
				Ext.getCmp('script_view_appjob').setValue(data);
				var bottom = this.getHeight();
				this.body.scroll("b", bottom, true);
			}
				//this.showScriptSuccess
		});
		
		//常规巡检 临时巡检的字段处理
		var checkType = Ext.getCmp('authorize_lever_type_view_appjob').getValue();
		if(checkType == '1'){
			//Ext.getCmp('frontline_flag_view_appjob').readOnly=true;
			Ext.getCmp('timer_view_appjob').enable();
			Ext.getCmp('mailConf_view_appjob').enable();
		}else{
			Ext.getCmp('timer_view_appjob').disable();
			Ext.getCmp('mailConf_view_appjob').disable();
		}
		//服务器处理
		Ext.apply(this.treeServerLoader.baseParams, {appsysCode:Ext.getCmp('appsys_code_view_appjob').getValue(), jobCode:Ext.getCmp('jobCode_view_appjob').getValue(),isView:'1'});
		this.treeServer.root.reload();
		//优先级和邮件配置
		var priority = '' ;
		var emailList = '' ;
		var emailSuccess = '' ;
		var emailFailure = '' ;
		var emailCancel = '' ;
		//时间表处理   一次
		var responseDataOnce = action.result.dataOnce; 
		var sizeOnce = responseDataOnce.length ;
		if(sizeOnce>0){
			Ext.getCmp('type_once_view_appjob').setValue(1) ;
			Ext.getCmp('once_date_view_appjob').setValue(responseDataOnce[0]['exec_start_date']);
			Ext.getCmp('once_time_view_appjob').setValue(responseDataOnce[0]['exec_start_time']);
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
 					id:'once_date_view_appjob_'+delButNumOnce,
 					disabled : true,
 					editable : false ,
 					minValue : new Date(),
 					value : responseDataOnce[t]['exec_start_date'] ,
 					anchor:'88%'
				});
				Ext.getCmp('once_dates_view_appjob').items.add(delButNumOnce,df);
				Ext.getCmp('once_dates_view_appjob').doLayout(); 
				//增加时间列
				var tf = new Ext.form.TimeField({
 			  		anchor:'97%',
 			  		disabled : true,
 					id:'once_time_view_appjob_'+delButNumOnce,
 					fieldLabel:'<fmt:message key="job.timer_time" />',
 					format:'H:i:s',
 					maxValue:'23:59 PM',
 					minValue:'0:00 AM',
 					value : responseDataOnce[t]['exec_start_time'] ,
 					increment:30  //间隔30分钟
				});
				Ext.getCmp('once_times_view_appjob').items.add(delButNumOnce,tf);
				Ext.getCmp('once_times_view_appjob').doLayout(); 
			}
		}
		//时间表处理   每天
		var responseDataDaily = action.result.dataDaily;
		var sizeDaily = responseDataDaily.length ;
		if(sizeDaily>0){
			Ext.getCmp('type_daily_view_appjob').setValue(1) ;
			Ext.getCmp('daily_time_view_appjob').setValue(responseDataDaily[0]['exec_start_time']);
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
					disabled : true,
		  			id:'daily_time_view_appjob_'+delButNumDaily,
		  			fieldLabel:'<fmt:message key="job.timer_time" />',
		  			format:'H:i:s',
		  			maxValue:'23:59 PM',
		  			minValue:'0:00 AM',
		  			value : responseDataDaily[t]['exec_start_time'] ,
		  			increment:30  //间隔30分钟
				});
				Ext.getCmp('daily_times_view_appjob').items.add(delButNumDaily,tdTime);
				Ext.getCmp('daily_times_view_appjob').doLayout(); 
			}
		}
		//时间表处理   每周
		var responseDataWeekly = action.result.dataWeekly;
		var sizeWeekly = responseDataWeekly.length ;
		if(sizeWeekly>0){
			Ext.getCmp('type_weekly_view_appjob').setValue(1) ;
			Ext.getCmp('interval_weeks_view_appjob').setValue(responseDataWeekly[0]['interval_weeks']);
			Ext.getCmp('weekly_time_view_appjob').setValue(responseDataWeekly[0]['exec_start_time']);
			Ext.getCmp('mon_view_appjob').setValue(responseDataWeekly[0]['week1_flag']);
			Ext.getCmp('tus_view_appjob').setValue(responseDataWeekly[0]['week2_flag']);
			Ext.getCmp('wen_view_appjob').setValue(responseDataWeekly[0]['week3_flag']);
			Ext.getCmp('thu_view_appjob').setValue(responseDataWeekly[0]['week4_flag']);
			Ext.getCmp('fri_view_appjob').setValue(responseDataWeekly[0]['week5_flag']);
			Ext.getCmp('sat_view_appjob').setValue(responseDataWeekly[0]['week6_flag']);
			Ext.getCmp('sun_view_appjob').setValue(responseDataWeekly[0]['week7_flag']);
			priority = responseDataWeekly[0]['exec_priority'];
			emailList = responseDataWeekly[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataWeekly[0]['mail_success_flag']; 
			emailFailure = responseDataWeekly[0]['mail_failure_flag']; 
			emailCancel = responseDataWeekly[0]['mail_cancel_flag']; 
		}
		//时间表处理   每月
		var responseDataMonthly = action.result.dataMonthly;
		var sizeMonthly = responseDataMonthly.length ;
		if(sizeMonthly>0){
			Ext.getCmp('type_monthly_view_appjob').setValue(1) ;
			Ext.getCmp('month_day_view_appjob').setValue(responseDataMonthly[0]['month_days']);
			Ext.getCmp('monthly_time_view_appjob').setValue(responseDataMonthly[0]['exec_start_time']);
			priority = responseDataMonthly[0]['exec_priority'];
			emailList = responseDataMonthly[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataMonthly[0]['mail_success_flag']; 
			emailFailure = responseDataMonthly[0]['mail_failure_flag']; 
			emailCancel = responseDataMonthly[0]['mail_cancel_flag']; 
		}
		//时间表处理   时间间隔
		var responseDataInterval = action.result.dataInterval;
		var sizeInterval = responseDataInterval.length ;
		if(sizeInterval>0){
			Ext.getCmp('type_interval_view_appjob').setValue(1) ;
			Ext.getCmp('interval_date_view_appjob').setValue(responseDataInterval[0]['exec_start_date']);
			Ext.getCmp('interval_time_view_appjob').setValue(responseDataInterval[0]['exec_start_time']);
			Ext.getCmp('interval_day_view_appjob').setValue(responseDataInterval[0]['interval_days']);
			Ext.getCmp('interval_hour_view_appjob').setValue(responseDataInterval[0]['interval_hours']);
			Ext.getCmp('interval_min_view_appjob').setValue(responseDataInterval[0]['interval_minutes']);
			priority = responseDataInterval[0]['exec_priority'];
			emailList = responseDataInterval[0]['exec_notice_mail_list']; 
			emailSuccess = responseDataInterval[0]['mail_success_flag']; 
			emailFailure = responseDataInterval[0]['mail_failure_flag']; 
			emailCancel = responseDataInterval[0]['mail_cancel_flag']; 
		}
		/*优先级和邮件配置*/
		Ext.getCmp('priorrity_view_appjob').setValue(priority);
		Ext.getCmp('mail_list_view_appjob').setValue(emailList); 
		Ext.getCmp('mail_success_view_appjob').setValue(emailSuccess); 
		Ext.getCmp('mail_failure_view_appjob').setValue(emailFailure); 
		Ext.getCmp('mail_cancel_view_appjob').setValue(emailCancel); 
		var userId = Ext.getCmp('creatorId_view_appjob').getValue();
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
					Ext.getCmp('creatorName_view_appjob').setValue(info.name);
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
	//关闭操作
	doClose : function() {
		app.closeTab('APP_JOB_DESIGN_VIEW');
	}
	
});

//实例化新建表单,并加入到Tab页中
Ext.getCmp("APP_JOB_DESIGN_VIEW").add(new JobDesignViewForm());
// 刷新Tab页布局
Ext.getCmp("APP_JOB_DESIGN_VIEW").doLayout();
</script>
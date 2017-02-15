<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var delButNumOnce = 100 ; //删除按钮序号 - 一次
var delButNumDaily = 100 ; //删除按钮序号 - 每天
var delButNumMonthly = 100 ; //删除按钮序号 - 每月
var jsonTemplate = [];

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
			id: 'type_once_view',
			inputValue: '1'
		}]
     },{
         columnWidth:.4,
         layout: 'form',
		 labelWidth:60,
		 id:'once_dates_view',
         items: [{
			xtype:'datefield',
			disabled:true,
			format:'y-m-d',
			id:'once_date_view',
			minValue : new Date(),
			fieldLabel:'<fmt:message key="job.timer_date" />',
			editable : false,
			anchor:'88%'
		  }]
	},{
        columnWidth:.35,
        layout: 'form',
	 	labelWidth:40,
	 	id : 'once_times_view' ,
        items: [{
			xtype:'timefield',
			disabled:true,
			anchor:'97%',
			id : 'once_time_view' ,
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
			id: 'type_daily_view',
			inputValue: '2'
		}]
    },{
        columnWidth:.6,
        layout: 'form',
		labelWidth:60,
		id : 'daily_times_view' ,
        items: [{
			xtype:'timefield',
			disabled : true,
  			anchor:'98%',
  			id : 'daily_time_view' ,
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
				id:'type_weekly_view',
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
				id : 'interval_weeks_view' ,
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
	  			id : 'weekly_time_view' ,
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
	 id : 'weeks_view' ,
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
	                {boxLabel: '<fmt:message key="job.monday" />', name: 'week1_flag', id:'mon_view',value:'2'},
	                {boxLabel: '<fmt:message key="job.tuesday" />', name: 'week2_flag', id:'tus_view' ,value:'4'},
	                {boxLabel: '<fmt:message key="job.wednesday" />', name: 'week3_flag', id:'wen_view',value:'8'},
	                {boxLabel: '<fmt:message key="job.thursday" />', name: 'week4_flag', id:'thu_view', value:'16'},
	                {boxLabel: '<fmt:message key="job.friday" />', name: 'week5_flag', id:'fri_view',value:'32'},
	                {boxLabel: '<fmt:message key="job.saturday" />', name: 'week6_flag', id:'sat_view',value:'64'},
	                {boxLabel: '<fmt:message key="job.sunday" />', name: 'week7_flag', id:'sun_view', value:'1'}
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
			id:'type_monthly_view',
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
        	id : 'month_day_view' ,
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
			id : 'monthly_time_view' ,
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
			id:'type_interval_view',
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
			id : 'interval_date_view' ,
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
 			id : 'interval_time_view' ,
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
	 id : 'interval_gap_view' ,
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
        	 id : 'interval_day_view',
        	 minValue : 0 ,
        	 maxValue : 365 
 	     },{
	       	 xtype: 'spinnerfield',	
	       	 disabled : true,
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.hour" />',
	       	 name : 'interval_hours',
	       	 id : 'interval_hour_view',
	       	 minValue : 0 ,
	       	 maxValue : 24 
	     },{
	       	 xtype: 'spinnerfield',
	         disabled : true,
	       	 anchor : '70%',
	       	 fieldLabel: '<fmt:message key="job.minute" />' ,
	       	 name : 'interval_minutes',
	       	 id : 'interval_min_view',
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
     	id : 'jobDesign_priorrity_view',
     	items: [
     	       {boxLabel: '<fmt:message key="job.lowest" />', name: 'exec_priority', id: 'LOWEST_view', inputValue: 'LOWEST'},
               {boxLabel: '<fmt:message key="job.low" />', name: 'exec_priority', id: 'LOW_view', inputValue: 'LOW'},
               {boxLabel: '<fmt:message key="job.normal" />', name: 'exec_priority', id: 'NORMAL_view', inputValue: 'NORMAL'},
               {boxLabel: '<fmt:message key="job.high" />', name: 'exec_priority', id: 'HIGH_view', inputValue: 'HIGH'},
               {boxLabel: '<fmt:message key="job.critical" />', name: 'exec_priority', id: 'CRITICAL_view', inputValue: 'CRITICAL'}
         ]
	}]
}); 

JobDesignViewForm = Ext.extend(Ext.FormPanel, {
    gridServer :null,   // 组件页签 - 列表组件
	treeServer : null,  // 组件页签 - 树形组件
    gridTemplate :null,   // 列表组件 - 列表组件
	treeTemplate : null,  // 树形组件 - 树形组件
	
	csmServer : null,  // 组件页签 - 数据列表选择框组件
	csmTemplate : null,// 模板页签 - 数据列表选择框组件
	
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
		csmTemplate = new Ext.grid.CheckboxSelectionModel();
		
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
		
		// 定义组件页签左侧树形组件------------------------------------begin
		this.treeServerLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/jobdesign/getServerTreeForEdit'
		}); 
		this.treeServer = new Ext.tree.TreePanel({
			id : 'serverTree_view',
			title : '<fmt:message key="job.select" /><fmt:message key="job.server" />',
			height : 628 ,
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
				url : '${ctx}/${appPath}/jobdesign/getJobServer/${param.jobid}',
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
				limit : 20  */
			}
		});
		this.gridServerStore.load();
		this.gridServer = new Ext.grid.GridPanel({
			id : 'serverGrid_view',
			height : 628 ,
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.server" />',
			region : 'center',
			border : false,
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
				dataIndex : 'server_name',
				width : 240 /* ,
				sortable : true */
			},{
				header : '智能组路径',
				width : 240 ,
				dataIndex : 'server_path'
			}]/* ,
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridServerStore,
				displayInfo : true,
				pageSize : 20
			}) */
		}); 
		// 定义组件页签右侧列表组件--------------------------------------end
		//this.treeServer.root.expand();
		
		// 定义模板页签左侧树形组件----------------------------------------begin
		this.treeTemplateLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/jobdesign/getTemplateTreeForEdit'
		});
		this.treeTemplate = new Ext.tree.TreePanel({
			id : 'templateTree_view',
			title : "<fmt:message key='job.select' /><fmt:message key='job.template' />",
			height : 628 , 
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.template" />',
				draggable : false,
				iconCls : 'node-root',
				id : 'TREE_ROOT_NODE_TEMPLATE_view'
			}),
			loader : this.treeTemplateLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.treeTemplate.expandAll();  //展开所有节点 
					/*  this.treeTemplate.root.expand();  //展开根节点  */
				 }
			}
		});
		// 定义模板页签树形组件----------------------------------------end
		
		// 定义模板页签右侧列表组件--------------------------------------begin
		this.gridTemplateStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jobdesign/getJobTemplate/${param.jobid}',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [
						'appsys_code', 
						'job_code', 
						'template_group',
						'template_name'
					],
			remoteSort : true,
			sortInfo : {
				/* field : 'tamplate_name',
				direction : 'ASC' */
			},
			baseParams : {
				/* start : 0,
				limit : 20 */
			}
		});
		this.gridTemplateStore.load();
		this.gridTemplate = new Ext.grid.GridPanel({
			id : 'templateGrid_view',
			height : 628 ,
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
			columns : [ new Ext.grid.RowNumberer(), /* csmTemplate, */
            {
				header : '<fmt:message key="job.template" /><fmt:message key="job.name" />',
				width : 240 ,
				dataIndex : 'template_name'
			},{
				
				header : '<fmt:message key="job.template" /><fmt:message key="job.path" />',
				width : 240 ,
				dataIndex : 'template_group'
			}]/* ,
			// 定义分页工具条
			bbar : new Ext.PagingToolbar({
				store : this.gridTemplateStore,
				displayInfo : true,
				pageSize : 20
			}) */
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
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
			url : '${ctx}/${appPath}/jobdesign/edit/${param.jobid}',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [{
		            xtype:'tabpanel',
		            //plain:true,
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
		                defaults:{bodyStyle:'padding-left:110px;padding-top:60px'},
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
									id : 'appsys_code_view',
									mode: 'local',
									typeAhead: true,
				                    triggerAction: 'all',
				                    hidden : true ,
				                    readOnly : true 
								},{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="job.code_jeda" />',
									name : 'job_code',
									id : 'jobCode_view' ,
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
									id : "jobDesign_authorize_lever_type_view",
									store : this.authorizeLevelTypeStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'combo',
									style  : 'background : #F0F0F0' , 
									fieldLabel : '<fmt:message key="job.field" />',
									valueField : 'value',
									displayField : 'name',
									name : 'field_type',
									hiddenName : 'field_type' ,
									id : 'jobDesign_fieldType_view',
									store : this.fieldTypeStore,
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++,
									readOnly : true
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
									fieldLabel : '<fmt:message key="job.status" />',
									valueField : 'value',
									displayField : 'name',
									name : 'tool_status',
									hiddenName : 'tool_status' ,
									store : this.toolStatusStore,
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
									fieldLabel : '<fmt:message key="job.frontline_flag" />',
									valueField : 'value',
									displayField : 'name',
									name : 'frontline_flag',
									id : 'jobDesign_frontline_flag_view',
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
								},{
									xtype : 'textfield',
									fieldLabel : '<fmt:message key="job.creator" />',
									name : 'tool_creator' ,
									id : 'jobDesign_creatorId_view',
									tabIndex : this.tabIndex++,
									hidden : true,
									readOnly : true
								},
								{
									xtype : 'textfield',
									style  : 'background : #F0F0F0' , 
									fieldLabel : '<fmt:message key="job.creator" />',
									name : 'tool_creator' ,
									id : 'jobDesign_creatorName_view',
									tabIndex : this.tabIndex++,
									readOnly : true
								}
						]}
		            ]}, 
		            {
		            	title : '<fmt:message key="job.template" />',
						height : 660,
		                layout:'form',
		                autoScroll : true ,
		                labelAlign : 'right',
		                iconCls : 'menu-node-trouble',
	                    border:false,
	                    items: [{
	                    	layout:'column',
			                border : true ,
			                items:[{
			                    columnWidth:.5,  
			                    border : false,
			                    defaults : { flex : 1 },
			                    layoutConfig : { align : 'stretch' },
			                    defaults:{bodyStyle:'padding-left:30px;padding-top:10px'},
			                    items : [this.treeTemplate]
			                },{
			                    columnWidth:.5,
			                    border:false,
			                    labelAlign : 'right',
			                    items: [this.gridTemplate]
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
			                height : 660 ,
			                items:[{
			                    columnWidth:.5,  
			                    border : false,
			                    defaults : { flex : 1 },
			                    layoutConfig : { align : 'stretch' },
			                    defaults:{bodyStyle:'padding-left:30px;padding-top:10px'},
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
		            	id:'jobDesign_timer_view',
		                autoScroll : true , 
		                border:false,
		                frame : true,
		                iconCls : 'menu-node-change',
		                layout: 'form',
		                bodyStyle : 'padding : 10px, 30px, 0, 30px;',
		                border:false,
		                labelAlign : 'right',
		                items:[{
		                    columnWidth:.8,
		                    layout: 'form',
		                    defaults: {anchor : '100%'},
		                    height : 630, 
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
		            } /* , {
		            	title:'<fmt:message key="job.notify_conf" />',
		            	id:'jobDesign_mailConf_view',
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
          				                style  : 'background : #F0F0F0' , 
  										readOnly : true,
          				                compare : 'emailListText',
          				                anchor : '82%',
          				                fieldLabel: '<fmt:message key="job.mail_list" />',
          				             	maxLength : 1000,
          				                name: 'exec_notice_mail_list',
          				                id:'jobDesign_mail_list_view'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '<fmt:message key="job.status_val" />',
          				                boxLabel: '<fmt:message key="job.success" />',
          				                inputValue : '2',
          				                id:'mail_success_view',
          				                name: 'mail_success_flag'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '',
          				                labelSeparator: '',
          				                boxLabel: '<fmt:message key="job.failure" />',
          				                inputValue : '4',
          				                id:'mail_failure_view',
          				                name: 'mail_failure_flag'
          				            }, {
          				            	xtype: 'checkbox',
          				            	disabled : true,
          				                fieldLabel: '',
          				                labelSeparator: '',
          				                boxLabel: '<fmt:message key="job.cancel" />',
          				                inputValue : '8',
          				                id:'mail_cancel_view',
          				                name: 'mail_cancel_flag'
          				            }]
          						}]
          			        }]
	                    }]
		            } */
		        ]}
	  		],
			// 定义按钮grid
			buttons : [{
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			}]
		});

		//加载表单数据
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
	
	//数据加载成功回调
	loadSuccess : function(form, action) {
		//常规巡检 临时巡检的字段处理
		var checkType = Ext.getCmp('jobDesign_authorize_lever_type_view').getValue();
		if(checkType == '1'){
			Ext.getCmp('jobDesign_frontline_flag_view').readOnly=true;
		}else{
			Ext.getCmp('jobDesign_timer_view').disable();
			//Ext.getCmp('jobDesign_mailConf_view').disable(); //通知配置页签
		}
		//模板  服务器处理
		Ext.apply(this.treeTemplateLoader.baseParams, {fieldType:Ext.getCmp('jobDesign_fieldType_view').getValue(), jobCode:Ext.getCmp('jobCode_view').getValue(),isView:'1'});
		Ext.apply(this.treeServerLoader.baseParams, {fieldType:Ext.getCmp('jobDesign_fieldType_view').getValue(),jobCode:Ext.getCmp('jobCode_view').getValue(),isView:'1'});
		this.treeTemplate.root.reload();
		this.treeServer.root.reload();
		//优先级和邮件配置
		var priority = '' ;
		//时间表处理   一次
		var responseDataOnce = action.result.dataOnce; 
		var sizeOnce = responseDataOnce.length ;
		if(sizeOnce>0){
			Ext.getCmp('type_once_view').setValue(1) ;
			Ext.getCmp('once_date_view').setValue(responseDataOnce[0]['exec_start_date']);
			Ext.getCmp('once_time_view').setValue(responseDataOnce[0]['exec_start_time']);
			priority = responseDataOnce[0]['exec_priority'];
		}
		if(sizeOnce > 1){
			for(var t=1 ; t<responseDataOnce.length ; t++){
				delButNumOnce++ ;
				//增加日期序号列
				var df = new Ext.form.DateField({
 					format:'y-m-d',
 					fieldLabel: '<fmt:message key="job.timer_date" />',
 					id:'once_date_view_'+delButNumOnce,
 					disabled : true,
 					editable : false ,
 					minValue : new Date(),
 					value : responseDataOnce[t]['exec_start_date'] ,
 					anchor:'88%'
				});
				Ext.getCmp('once_dates_view').items.add(delButNumOnce,df);
				Ext.getCmp('once_dates_view').doLayout(); 
				//增加时间列
				var tf = new Ext.form.TimeField({
 			  		anchor:'97%',
 			  		disabled : true,
 					id:'once_time_view_'+delButNumOnce,
 					fieldLabel:'<fmt:message key="job.timer_time" />',
 					format:'H:i:s',
 					maxValue:'23:59 PM',
 					minValue:'0:00 AM',
 					value : responseDataOnce[t]['exec_start_time'] ,
 					increment:30  //间隔30分钟
				});
				Ext.getCmp('once_times_view').items.add(delButNumOnce,tf);
				Ext.getCmp('once_times_view').doLayout(); 
			}
		}
		//时间表处理   每天
		var responseDataDaily = action.result.dataDaily;
		var sizeDaily = responseDataDaily.length ;
		if(sizeDaily>0){
			Ext.getCmp('type_daily_view').setValue(1) ;
			Ext.getCmp('daily_time_view').setValue(responseDataDaily[0]['exec_start_time']);
			priority = responseDataDaily[0]['exec_priority'];
		}
		if(sizeDaily > 1){
			for(var t=1 ; t<responseDataDaily.length ; t++){
				delButNumDaily++ ;
				//增加时间列
				var tdTime = new Ext.form.TimeField({
					anchor:'98%',
					disabled : true,
		  			id:'daily_time_view_'+delButNumDaily,
		  			fieldLabel:'<fmt:message key="job.timer_time" />',
		  			format:'H:i:s',
		  			maxValue:'23:59 PM',
		  			minValue:'0:00 AM',
		  			value : responseDataDaily[t]['exec_start_time'] ,
		  			increment:30  //间隔30分钟
				});
				Ext.getCmp('daily_times_view').items.add(delButNumDaily,tdTime);
				Ext.getCmp('daily_times_view').doLayout(); 
			}
		}
		//时间表处理   每周
		var responseDataWeekly = action.result.dataWeekly;
		var sizeWeekly = responseDataWeekly.length ;
		if(sizeWeekly>0){
			Ext.getCmp('type_weekly_view').setValue(1) ;
			Ext.getCmp('interval_weeks_view').setValue(responseDataWeekly[0]['interval_weeks']);
			Ext.getCmp('weekly_time_view').setValue(responseDataWeekly[0]['exec_start_time']);
			Ext.getCmp('mon_view').setValue(responseDataWeekly[0]['week1_flag']);
			Ext.getCmp('tus_view').setValue(responseDataWeekly[0]['week2_flag']);
			Ext.getCmp('wen_view').setValue(responseDataWeekly[0]['week3_flag']);
			Ext.getCmp('thu_view').setValue(responseDataWeekly[0]['week4_flag']);
			Ext.getCmp('fri_view').setValue(responseDataWeekly[0]['week5_flag']);
			Ext.getCmp('sat_view').setValue(responseDataWeekly[0]['week6_flag']);
			Ext.getCmp('sun_view').setValue(responseDataWeekly[0]['week7_flag']);
			priority = responseDataWeekly[0]['exec_priority'];
		}
		//时间表处理   每月
		var responseDataMonthly = action.result.dataMonthly;
		var sizeMonthly = responseDataMonthly.length ;
		if(sizeMonthly>0){
			Ext.getCmp('type_monthly_view').setValue(1) ;
			Ext.getCmp('month_day_view').setValue(responseDataMonthly[0]['month_days']);
			Ext.getCmp('monthly_time_view').setValue(responseDataMonthly[0]['exec_start_time']);
			priority = responseDataMonthly[0]['exec_priority'];
		}
		//时间表处理   时间间隔
		var responseDataInterval = action.result.dataInterval;
		var sizeInterval = responseDataInterval.length ;
		if(sizeInterval>0){
			Ext.getCmp('type_interval_view').setValue(1) ;
			Ext.getCmp('interval_date_view').setValue(responseDataInterval[0]['exec_start_date']);
			Ext.getCmp('interval_time_view').setValue(responseDataInterval[0]['exec_start_time']);
			Ext.getCmp('interval_day_view').setValue(responseDataInterval[0]['interval_days']);
			Ext.getCmp('interval_hour_view').setValue(responseDataInterval[0]['interval_hours']);
			Ext.getCmp('interval_min_view').setValue(responseDataInterval[0]['interval_minutes']);
			priority = responseDataInterval[0]['exec_priority'];
		}
		/*优先级和邮件配置*/
		Ext.getCmp('jobDesign_priorrity_view').setValue(priority);
		var userId = Ext.getCmp('jobDesign_creatorId_view').getValue();
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
					Ext.getCmp('jobDesign_creatorName_view').setValue(info.name);
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
		app.closeTab('JOB_DESIGN_VIEW');
	}
});

//实例化新建表单,并加入到Tab页中
Ext.getCmp("JOB_DESIGN_VIEW").add(new JobDesignViewForm());
// 刷新Tab页布局
Ext.getCmp("JOB_DESIGN_VIEW").doLayout();
</script>
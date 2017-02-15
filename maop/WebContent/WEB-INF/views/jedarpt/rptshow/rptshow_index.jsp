<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<%
  String reportId = request.getParameter("ID");
%>

<script type="text/javascript">
var reportId='<%=reportId%>'; //菜单编号
var pageSize = 100; //分页最多显示记录条数
var rptShowIndexGridStore; //列表数据源
//var rptShowIndexGrid = null; //列表
//var rptShowIndexForm = null; //查询表单
var rptShowIndexFormItems; //查询表单items
var rptShowIndexDsFields;  //列表数据源fields
var rptShowIndexCmItems;   //列元素
var rptShowIndexGridCol;   //列对象
//var chartPanel;  //图表

//var columnChart ; //柱形图
//var pieChart ; //饼状图
//应用系统信息(未删除、已上线的所有应用系统编号及名称)
/* 
 var appsysStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames4NoDelHasAop',
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
appsysStore.load();   
*/

//图表定制数据字典
var rptColsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/jedarptshow/getRepColsStoreByReportCode',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['value','name']),
	baseParams : {reportId : reportId}
});
rptColsStore.load();

//加载动态数据字典
	method : 'POST',
	url : '${ctx}/${appPath}/jedarptshow/getDicItems',
	params : {reportId : reportId},
	disableCaching : true,	//禁止缓存
	async : false, //同步请求
	success : function(resp,opts){
		var respText = Ext.util.JSON.decode(resp.responseText);
		if(respText.dicItems){
			dicItems = respText.dicItems;
		}
	}
});
for(var t=0 ; t<dicItems.length ; t++){
	var item = dicItems[t] ;
	eval("var store_"+item+";");
	eval("store_"+item+" = new Ext.data.JsonStore({autoDestroy : true,url : '${ctx}/${frameworkPath}/item/"+item+"/sub',root : 'data',fields : [ 'value', 'name' ]});");
	eval("store_"+item+".load();");
}


//实例化数据列表数据源
rptShowIndexGridStore = new Ext.data.JsonStore( {
	proxy : new Ext.data.HttpProxy( {
		method : 'POST',
		url : '${ctx}/${appPath}/jedarptshow/getReportInfoList',
		disableCaching : true,
		timeout : 999999
	}),
	autoDestroy : true,
	root : 'data',
	totalProperty : 'count',
	fields : [],
	remoteSort : true,
	sortInfo : {
		field : '',
		direction : 'ASC'
	},
	baseParams : {
		start : 0,
		limit : pageSize,
		reportId : reportId
	}
});



//页面初始化
	var report_id=reportId;
	//加载动态查询表单
	//加载动态列表
	//重新配置store动态fields
	rptShowIndexCreateStore();
	//重新配置rptShowIndexGrid的store、columns、bbar
	rptShowIndexReconfigureGird();
	//配置Store参数 
	Ext.apply(Ext.getCmp('rptShowIndexGrid'+report_id).getStore().baseParams, Ext.getCmp('rptShowIndexForm'+report_id).getForm().getFieldValues());
	//加载数据源
	
};

//定义列表
JeadReportList = Ext.extend(Ext.Panel, {
	tabIndex : 0, // 查询表单组件Tab键顺序
	chartPanel:null,
	constructor : function(cfg) {// 构造方法
		// 实例化数据列表选择框组件
		// 禁止IE的backspace键(退格键)，但输入文本框时不禁止
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
		this.chartPanel = new Ext.Panel({
			id:'report_show_charts'+reportId,
			title : '图表展示',
			split: false,
			region:'south',
			height : 350,
		    minSize: 350,
		    maxSize: 450,
		    collapsed : true,
		   // collapsible: false,
		    margins: '0 0 0 0',
			frame : true,
			autoScroll : true,
			collapsible : true,
			animCollapse : true,
			collapseMode : 'mini' ,
			items : [{
		         xtype:'tabpanel',
		         plain:true,
		         forceLayout : true,
		         autoScroll:true,
		         enableTabScroll:true,
		         activeTab: 0,
		         height: 450 ,
		         deferredRender: false,
		         items:[{
			         	 title:'柱形图',
			             layout:'form',
			             border:false,
			             defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
			             items: [{
			                 columnWidth:.96,
			                 layout: 'form',
			                 defaults: {anchor : '100%'},
			                 border:false,
			                 labelAlign : 'right',
			                 items: [{	
			                	 columnWidth:.96,
			                     layout: 'column',
			                     defaults: {anchor : '100%'},
			                     border:false,
			                     labelAlign : 'right',
			                     items: [{
			                     	columnWidth:.3,
			                     	layout: 'form',
			                     	defaults: {anchor : '100%'},
			                     	labelWidth : 110 ,
			                     	items : [{
			 	    					xtype : 'combo',
			 	    					store : rptColsStore,
			 	    					valueField : 'value',
				    					displayField : 'name',
				    					id : 'jedarpt_groupItem_'+reportId,
				    					mode : 'local',
				    					triggerAction : 'all',
				    					forceSelection : true,
				    					editable : true,
			 	    					fieldLabel : '<font color=red>*</font>&nbsp;统计科目分组',
			 	    					tabIndex : this.tabIndex++ 
			                     	}]
			     				},{
			     					columnWidth:.3,
			     					layout: 'form',
			     					defaults: {anchor : '100%'},
			     					labelWidth : 110 ,
			     					items : [{
			 	    					xtype : 'combo',
			 	    					store : rptColsStore,
			 	    					valueField : 'value',
				    					displayField : 'name',
				    					id : 'jedarpt_xItem_'+reportId,
				    					mode : 'local',
				    					triggerAction : 'all',
				    					forceSelection : true,
				    					editable : true,
			 	    					fieldLabel : '&nbsp;&nbsp;<font color=red>*</font>&nbsp;统计科目名称',
			 	    					tabIndex : this.tabIndex++ 
			                     	}]
			     				},{
			     					columnWidth:.3,
			     					layout: 'form',
			     					defaults: {anchor : '100%'},
			     					labelWidth : 100 ,
			     					items : [{
			 	    					xtype : 'combo',
			 	    					store : rptColsStore,
			 	    					valueField : 'value',
				    					displayField : 'name',
				    					id : 'jedarpt_yItem_'+reportId,
				    					mode : 'local',
				    					triggerAction : 'all',
				    					forceSelection : true,
				    					editable : true,
			 	    					fieldLabel : '<font color=red>*</font>&nbsp;统计科目值',
			 	    					tabIndex : this.tabIndex++ 
			                     	}]
			     				},{
			     					columnWidth:.02,
			     					layout: 'form',
			     					items : []
			     				},{
			     					columnWidth:.04,
			     					layout: 'form',
			     					items : [{
			 	    					xtype : 'button',
			 	    					text : '查看',
			 	    					scope : this,
			 	    					handler : function(){
			 	    						var id=this.chartPanel.getId().substring(18);
			 	    						rptColumnChartCreate(id);
			 	    					}
			                     	}]
			     				}]
			                 }]
			             }],
			             contentEl: 'rptColumnChart'+reportId
			       },
			       {
				      	title : '饼状图',
				        layout:'form',
						defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
				        border:false,
				        items: [{
			                 columnWidth:.96,
			                 layout: 'form',
			                 defaults: {anchor : '100%'},
			                 border:false,
			                 labelAlign : 'right',
			                 items: [{	
			                	 columnWidth:.96,
			                     layout: 'column',
			                     defaults: {anchor : '100%'},
			                     border:false,
			                     labelAlign : 'right',
			                     items: [{
			                     	columnWidth:.3,
			                     	layout: 'form',
			                     	defaults: {anchor : '100%'},
			                     	items : [{
			 	    					xtype : 'combo',
			 	    					store : rptColsStore,
			 	    					valueField : 'name',
				    					displayField : 'name',
				    					id : 'jedarpt_nameItem_'+reportId,
				    					mode : 'local',
				    					triggerAction : 'all',
				    					forceSelection : true,
				    					editable : true,
			 	    					fieldLabel : '<font color=red>*</font>&nbsp;统计科目名称',
			 	    					tabIndex : this.tabIndex++ 
			                     	}]
			     				},{
			     					columnWidth:.3,
			     					layout: 'form',
			     					defaults: {anchor : '100%'},
			     					items : [{
			 	    					xtype : 'combo',
			 	    					store : rptColsStore,
			 	    					valueField : 'name',
				    					displayField : 'name',
				    					id : 'jedarpt_valueItem_'+reportId,
				    					mode : 'local',
				    					triggerAction : 'all',
				    					forceSelection : true,
				    					editable : true,
			 	    					fieldLabel : '&nbsp;&nbsp;<font color=red>*</font>&nbsp;统计科目值',
			 	    					tabIndex : this.tabIndex++ 
			                     	}]
			     				},{
			     					columnWidth:.3,
			     					layout: 'form',
			     					defaults: {anchor : '100%'},
			     					labelWidth : 120 ,
			     					items : [{
			 	    					xtype : 'textfield',
				    					id : 'jedarpt_percision_'+reportId,
			 	    					fieldLabel : '&nbsp;&nbsp;<font color=red>*</font>&nbsp;保留小数点位数',
			 	    					tabIndex : this.tabIndex++,
			 	    					emptyText : '2',
				    					listeners : {
				    						'change' : function(textField,newValue,oldValue) {
				    							if(newValue.search(/^\d+$/)==-1){
				    								Ext.Msg.show( {
				    									title : '<fmt:message key="message.title" />',
				    									msg :  '[保留小数点位数]必须是正整数，默认值为2！',
				    									buttons : Ext.MessageBox.OK,
				    									icon : Ext.MessageBox.WARNING,
				    									minWidth : 200
				    								}); 
				    								Ext.getCmp('jedarpt_percision_'+reportId).setValue('2');
				    							}
				    						}
				    					} 
			                     	}]
			     				},{
			     					columnWidth:.02,
			     					layout: 'form',
			     					items : []
			     				},{
			     					columnWidth:.04,
			     					layout: 'form',
			     					items : [{
			 	    					xtype : 'button',
			 	    					text : '查看',
			 	    					scope : this,
			 	    					handler : function(){
			 	    						var id=this.chartPanel.getId().substring(18);
			 	    						rptPieChartCreate(id);
			 	    					}
			                     	}]
			     				}]
			                 }]
			             }],
			             contentEl: 'rptPieChart'+reportId
			      }]
			}]
		});
		
		this.rptShowIndexGrid = new Ext.grid.GridPanel({
			id:'rptShowIndexGrid'+reportId,
			title : '<fmt:message key="title.list" />',
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
		    view: new Ext.ux.grid.BufferView({
			    rowHeight: 20,
			    scrollDelay: false,
				fix : true,
				forceFit : false,
				getRowClass : function(record, rowIndex, rowParams, store){
					if(record.data.holidayFlag == 2){
						return 'x-gridHoliday-Orange';
					}
					if(record.data.statisticalFlag == 1){
						return 'x-gridStatistical-lightskyblue';
					}
					if((rowIndex + 1) % 2 == 0){
						return 'x-gridTran-row-alt';
					}
				}
		    }),
			store : rptShowIndexGridStore,
			// 列定义
			cm : new Ext.grid.ColumnModel([{header : '',sortable : true}]),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : rptShowIndexGridStore,
				displayInfo : true,
				pageSize  : pageSize,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					text : '导出excel',
					//disabled : true,
					scope : this,
					handler : function() {
						var id=this.rptShowIndexGrid.getId().substring(16);
						window.location = '${ctx}/${appPath}/jedarptshow/excel.xls?reportId='+id;
					}
				}]
			}),
			listeners : {
				scope : this,
				'render' : function(){
					var id=this.rptShowIndexGrid.getId().substring(16);
					setTimeout(function(){
						rptShowIndexGridStore.baseParams.reportId=id;
			        	rptShowIndexGridStore.load();
			        }, 500);
				}
			}
		});
		
		//实例化查询表单
		this.rptShowIndexForm = new Ext.FormPanel( {
			id:'rptShowIndexForm'+reportId,
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 80,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 250,
			minSize : 200,
			maxSize : 300,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [],
			// 定义查询表单按钮
			buttons : [{
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : function(){
					//配置Store参数 
					Ext.apply(this.rptShowIndexGrid.getStore().baseParams,this.rptShowIndexForm.getForm().getFieldValues());
					//加载数据源
					this.rptShowIndexGrid.getStore().load();
				}
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : function() {
					this.rptShowIndexForm.getForm().reset();
				}
			}]
		});
		init();
		
		// 设置基类属性
			layout : 'border',
			border : false,
			autoScroll : true,
			items : [this.rptShowIndexForm,this.rptShowIndexGrid,this.chartPanel]
		});
	}
});

//获取动态列名及数据源字段列表
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${appPath}/jedarptshow/getCols',
		params: {reportId : reportId},
		disableCaching : true,	//禁止缓存
		async : false, //同步请求
		success : function(response,option){
			var text = response.responseText;
			rptShowIndexCmItems = Ext.util.JSON.decode(Ext.util.JSON.decode(text).columnModel);
			rptShowIndexDsFields = Ext.util.JSON.decode(Ext.util.JSON.decode(text).fieldsNames);
			rptShowIndexGridCols = new Ext.grid.ColumnModel(rptShowIndexCmItems);
		},
		failure : function(response){
		}
	});
}
//重新实例化数据源对象，为了解决动态fields替换问题
function rptShowIndexCreateStore(){
	// 实例化数据列表数据源
	rptShowIndexGridStore = new Ext.data.JsonStore({
		proxy : new Ext.data.HttpProxy( {
			method : 'POST',
			url : '${ctx}/${appPath}/jedarptshow/getReportInfoList',
			disableCaching : false,
			timeout : 999999
		}),
		autoDestroy : true,
		root : 'data',
		totalProperty : 'count',
		fields : rptShowIndexDsFields,
		remoteSort : true,
		sortInfo : {
			field : '',
			direction : 'ASC'
		},
		baseParams : {
			start : 0,
			limit : pageSize,
			reportId : reportId
		}
	});
}
//重新配置rptShowIndexGrid的store、columns、bbar
function rptShowIndexReconfigureGird(sheetName){
	Ext.getCmp('rptShowIndexGrid'+reportId).colModel = rptShowIndexGridCols;
	Ext.getCmp('rptShowIndexGrid'+reportId).reconfigure(rptShowIndexGridStore, Ext.getCmp('rptShowIndexGrid'+reportId).colModel);
	//重新绑定bbar的store到新实例化的数据源
}
//获取动态查询表单
	Ext.Ajax.request({
		scope : this,
		method : 'POST',
		url : '${ctx}/${appPath}/jedarptshow/getFormItems',
		params: {reportId : reportId},
		disableCaching : true,	//禁止缓存
		async : false, //同步请求
		success : function(response,option){
			var text = response.responseText;
			if(text!=''){
				if(Ext.util.JSON.decode(text).formItems){
					Ext.getCmp('rptShowIndexForm'+reportId).add(Ext.util.JSON.decode(Ext.util.JSON.decode(text).formItems));
				}
			}
		},
		failure : function(response){
		}
	});
}

//动态创建柱形图
function rptColumnChartCreate(id){
	reportId=id;
	var groupItem = Ext.getCmp('jedarpt_groupItem_'+reportId).getValue();
	var xItem = Ext.getCmp('jedarpt_xItem_'+reportId).getValue();
	var yItem = Ext.getCmp('jedarpt_yItem_'+reportId).getValue();
	
	//获取动态图表
		method : 'POST',
		url : '${ctx}/${appPath}/jedarptshow/getColumnChart',
		disableCaching : true, //禁止缓存
		params: { 
			reportId: reportId,
			groupItem : groupItem,
			xItem : xItem,
			yItem : yItem
		},
		async : false, //同步请求
		success : function(response){
			
			var responseData = response.responseText;
			
			var columnChartOptionJson = Ext.util.JSON.decode(Ext.util.JSON.decode(responseData).columnChartOptionJson);
			//var data = '{"columnChartOptionJson":{"chartTitle":"柱形图测试 ","subtitleOption":"","yAxisTitle":"百分比 ","xCategories":"201501,201502,201503","seriesOptions":[{name:"工具箱一",data:[75,20,30]},{name:"工具箱二",data:[30,40,65]},{name:"工具箱三",data:[20,30,50]},{name:"工具箱四",data:[10,50,80]}] }}';
			//var columnChartOptionJson = Ext.util.JSON.decode(data).columnChartOptionJson;
			var columnChart = new Highcharts.Chart({ 
				 chart: { 
				 	type: 'column' ,
				 	renderTo: 'rptColumnChart'+reportId,
	                margin: [ 50, 50, 1080, 0]
				 }, 
				 title: {
					 text : columnChartOptionJson.chartTitle,
	                 style:{//样式
	                    cursor: 'pointer',
	                    color: 'red',
	                    fontSize: '20px'
	                 }
				 },
				 credits: { //设置右下角的标记Highcharts.com字样
	            	enabled :false //不显示
	             },
				 xAxis: { 
				 	categories : columnChartOptionJson.xCategories.split(",") , 
	                labels: {
	                    //rotation: -45, //倾斜45度角
	                    //align: 'right',
	                    style: {
	                        fontSize: '13px',
	                        fontFamily: 'Verdana, sans-serif'
	                    }
	                }  
				 }, 
				 yAxis: { 
					 min: 0, 
					 title: {
						 text : columnChartOptionJson.yAxisTitle
					 }
				 }, 
				 /* tooltip: { 
					 headerFormat: '<span style="font-size:10px">{point.key}</span><table>',	 
					 pointFormat: '<tr><td width=60px style="color:{series.color};padding:0;font-size:10px">{series.name}: </td>' + 
					  			'<td style="padding:0;font-size:10px"><b>{point.y} </b></td></tr>', 
					 footerFormat: '</table>', 
					 shared: true, 
					 useHTML: true 
				 },  */
				 legend: {
	                layout: 'vertical',
	                backgroundColor: '#FFFFFF',
	                align: 'left',
	                verticalAlign: 'top',
	                x: 80,
	                y: 30,
	                floating: true,
	                shadow: true
	            }, 
				 plotOptions: { 
					 column: { 
						 pointPadding: 0.2, 
						 borderWidth: 0 /* , //多个柱形图向上层叠
						 stacking: 'normal',
		                 color: "red",
		                 borderWidth: 1,
	                	 shadow: false,
	                     dataLabels: {
	                        enabled: true,
	                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
	                     }  */
					 } 
				 }, 
				 series: columnChartOptionJson.seriesOptions
			}); 
		}
	});
}

//动态创建饼状图
function rptPieChartCreate(id){
	reportId=id;
	var nameItem = Ext.getCmp('jedarpt_nameItem_'+reportId).getValue();
	var valueItem = Ext.getCmp('jedarpt_valueItem_'+reportId).getValue();
	var percision = Ext.getCmp('jedarpt_percision_'+reportId).getValue();
	if(percision == ''){
		percision = '2';  //默认保留两位小数点
	}
	//获取动态图表
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${appPath}/jedarptshow/getPieChart',
		disableCaching : true, //禁止缓存
		params: { 
			reportId: reportId,
			nameItem : nameItem,
			valueItem : valueItem,
			percision : percision
		},
		async : false, //同步请求
		success : function(response){
			var responseData = response.responseText;
			var pieChartOptionJson = Ext.util.JSON.decode(Ext.util.JSON.decode(responseData).pieChartOptionJson);
			
			var pieChart = new Highcharts.Chart({ 
				chart: {
	                renderTo: 'rptPieChart'+reportId,
	                plotBackgroundColor: null,
	                plotBorderWidth: null,
	                plotShadow: false
	            },
	            title: {
					text : pieChartOptionJson.chartTitle,
	                style:{//样式
	                    cursor: 'pointer',
	                    color: 'red',
	                    fontSize: '20px'
	                }
				},
				credits: { //设置右下角的标记Highcharts.com字样
	            	enabled :false //不显示
	            },
	            tooltip: {
	        	    pointFormat: '{series.name}: <b>{point.percentage}%</b>',
	            	percentageDecimals: percision 
	            },
	            plotOptions: {
	                pie: {
	                    allowPointSelect: true,
	                    cursor: 'pointer',
	                    dataLabels: {
	                        enabled: true,
	                        color: '#000000',
	                        connectorColor: '#000000',
	                        formatter: function() {
	                            return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage, percision) +' %';
	                        }
	                    }
	                }
	            },
	            series: [{
	                type: 'pie',
	                name: pieChartOptionJson.seriesName,
	                data: pieChartOptionJson.seriesData
	            }]
	        });
		 }
	}); 
}


var jedaReportList = new JeadReportList();
</script>

<script type="text/javascript">
	Ext.getCmp(reportId).add(jedaReportList);
	Ext.getCmp(reportId).doLayout();
	Ext.getCmp('report_show_charts'+reportId).collapse(true);
</script>
<div id="rptColumnChart<%=reportId%>" style="min-width:310px; height:360px; margin:0 auto"></div> 
<div id="rptPieChart<%=reportId%>" style="min-width:310px; height:360px; margin:0 auto"></div> 
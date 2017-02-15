<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	var StepForm = Ext.extend(Ext.Panel, {
		//tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {
			Ext.apply(this, cfg);

			var centerPanel = new Ext.Panel({
				id : 'DayRptManageIndexCenterPanel',
				title : '图表展示',
				split : false,
				region : 'center',
				height : 400,
				minSize : 400,
				maxSize : 400,
				collapsible : false,
				margins : '0 0 0 0',
				frame : false,
				autoScroll : true,
				collapsible : true,
				animCollapse : true,
				collapseMode : 'mini',
				contentEl : 'stepcontainer'
			});
			StepForm.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [ centerPanel ]
			});

		}
	});
	//定时更新仪表盘任务

	var stepUpdateProcessTask = {
		run : function() {
			Ext.Ajax.request({
				method : 'POST',
				url : '${ctx}/${appPath}/monitor/stepMonitor',
				disableCaching : true, //禁止缓存
				params : {},
				async : false, //同步请求
				success : function(response) {
					var responseData = response.responseText;
					var tmp = eval("("+ Ext.util.JSON.decode(responseData).data + ")");
					var xAxisDataOptions = tmp.xAxisDataOptions;
					var successDateOptions = tmp.successDateOptions;
					var failedDateOptions = tmp.failedDateOptions;

					var num =successDateOptions.length;
					if(num<16){
						 document.getElementById("stepcontainer").style.height= '500px';

					}else{
						 document.getElementById("stepcontainer").style.height=num*30+'px';
					}
					var chart = new Highcharts.Chart({
						chart : {
							renderTo : 'stepcontainer',
							type : 'bar'
						},
						title : {
							text : ''
						},
						xAxis : {
							categories : xAxisDataOptions,
							labels :{
								//rotation : -30
							}
						},
						yAxis : {
							min : 0,
							title : {
								text : ''
							},
							labels: {
							formatter : function() {
									return this.value + '%'
								}
							}
						},
						legend: {
			                backgroundColor: '#FFFFFF',
			                reversed: true
			            },
						tooltip : {
							formatter : function() {
								return  this.x+ ' ' + this.series.name + ': ' + this.y + ' (' + Math.round(this.percentage) + '%)';
							}
						},
						
						plotOptions : {
							/* column : {
								stacking : 'percent',
								 pointWidth :30
							} */
						series: {                  
						    stacking: 'percent',
						    pointWidth :20
						}                          
						},
						series : [ {
							name : '未完',
							 color:'#CD8753',
							data : failedDateOptions
						}, {
							name : '已经完成',
							color:'#1E90FF',
							data : successDateOptions
						} ]
					});
				}
			});
		},
		interval : 60000
	};
	Ext.getCmp("STEP_SCHEDULE").add(new StepForm());
	Ext.getCmp("STEP_SCHEDULE").doLayout();
	taskRunner.start(stepUpdateProcessTask);
	Ext.getCmp("STEP_SCHEDULE").on('destroy', function() {
		if (stepUpdateProcessTask) {
			taskRunner.stop(stepUpdateProcessTask);
		}
	});
</script>
<div id="stepmeterMonitor">
	<div id="stepcontainer"
		style=" min-width:600px; margin: 50px"></div>
</div>

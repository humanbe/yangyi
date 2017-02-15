<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var aplCode = decodeURIComponent('${param.aplCode}');
var aplName = decodeURIComponent('${param.aplName}');
var transDate = decodeURIComponent('${param.transDate}');
var transTime = decodeURIComponent('${param.transTime}');

// 换页最大值
var pageSize = 100;
var subSheetNames = [];
//保存创建的图表对象
var dayRptManageIndexChartsArr = [];
//用于gridstore的fields
var dayRptManageIndexDsFields_analyse;
//用于grid的ColmunModel
var dayRptManageIndexGridCols_analyse;
var dayRptManageIndexCmItems_analyse;
//定义数据源
var dayRptManageIndexGridStore_analyse;
//定义数据列表组件
var dayRptManageIndexGrid_analyse;
//定义树形数据源
var dayRptManageIndexTreeLoader_analyse;
//定义treePanel
var dayRptManageIndexTreePanel_analyse;
//定义查询表单
var dayRptManageIndexForm_analyse;
//初始页面显示默认31天的趋势图（昨天往前推30天），调用创建图表方法
var dayRptManageIndexCurrentDate = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -1),'Ymd');
var dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -31),'Ymd');
var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -7),'Ymd');
//数据列表组件的分组header数组存储
var dayRptManageIndexColumnHeaderGroupList_analyse;
//数据列表组件的分组header组合数
var dayRptManageIndexColumnHeaderGroupColspan_analyse;
//数据列表组件的初始分组表头
var dayRptManageIndexColumnHeaderGroup_analyse = new Ext.ux.grid.ColumnHeaderGroup({
	rows: []
});
//定义分析表单
var dayRptAnalyseForm_analyse;

//获取系统代码列表数据
var aplCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});

//日报检查项运行状态
var runStatueStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/DAYRPT_RUN_STATUE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

var handleStateStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/HANDLE_STATE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});

//	动态创建图表的方法
function dayRptManageIndexCreateChart_analyse(aplCodeParm,reportTypeParm,sheetNameParm,startDateParm,endDateParm,subSheetNameParm){
	//重新执行查新操作时，清空图表数据，防止导出上次查询的图表数据
	dayRptManageIndexChartsArr = [];
	//获取动态图表
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${managePath}/dayrptmanage/getCharts',
		disableCaching : true, //禁止缓存
		params: { aplCode: aplCodeParm,
					reportType : reportTypeParm,
					sheetName : sheetNameParm,
					startDate : startDateParm,
					endDate : endDateParm,
					subSheetName : subSheetNameParm},
		async : false, //同步请求
		success : function(response){
			var responseData = response.responseText;
			//循环动态创建div
			var dayRptManageIndexRptDivCount = 0;
			Ext.iterate(Ext.util.JSON.decode(responseData).chartOptionJson, function(chartKey, chartContent){
				dayRptManageIndexRptDivCount++;
			});
			if(dayRptManageIndexRptDivCount != 0){
				dynamicCreateRptChartDiv_analyse(dayRptManageIndexRptDivCount,sheetNameParm);
			}
			//循环创建chart
			dayRptManageIndexRptDivCount = 0;//初始化
			Ext.iterate(Ext.util.JSON.decode(responseData).chartOptionJson, function(chartKey, chartContent){
				//返回的图表数据
				var tmp = eval("(" + chartContent + ")");
				// 图表分支判断
				switch (tmp.chartType) {
					case "1": //趋势图
						/* 测试数据
						var data = '{"chartOptionJson":{"titleOption":"网银最近31天日交易情况","subtitleOption":"","yAxisTitleOption":"交易量","xCategoriesOptions":"20121222,20121223,20121224,20121225,20121226,20121227,20121228,20121229,20121230,20121231,20130101,20130102,20130103,20130104,20130105,20130106,20130107,20130108,20130109,20130110,20130111,20130112,20130113,20130114,20130115","seriesOptions":[{name:"对公账务总交易量",data:[16503,8476,185563,190861,194827,200964,226599,42525,17628,182300,12508,12634,16595,181965,150596,125568,159684,162081,154530,167117,167232,17691,8574,177294,181443]},{name:"银企通账务总交易量",data:[521754,513927,579580,584925,601922,629367,619374,510145,509470,591881,442709,433423,425601,518284,646653,643773,636818,632494,637504,632122,626555,558530,552797,631062,663037]},{name:"对私账务总交易量",data:[400630,378657,588858,602857,538627,550542,573540,423925,357865,556492,402430,369262,371727,613448,539524,480924,510559,503880,493895,547007,512794,353398,326613,554464,646024]},{name:"对私查询交易量",data:[206190,205479,340380,350875,360210,368177,425676,270713,227117,351117,274729,249742,252960,436880,364698,325370,359635,338031,335790,349692,322136,214341,213629,411181,562462]},{name:"实时交易总量",data:[1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000]},{name:"系统失败交易量",data:[1214,895,3189,2728,2456,4684,7637,198,344,1307,376,810,166,2546,5595,840,958,2069,3281,1042,1082,761,974,13092,28916]}]}}'
						var tmp = Ext.util.JSON.decode(data).chartOptionJson;
						*/
						// 编辑chart图表配置项
						var chartType;
						var xAxisData = [];
						var plotOptionsData;
						var toolTipData;
						// 趋势图的X轴坐标科目
						var xCategoriesOptions = tmp.xCategoriesOptions.split(",");
						if(sheetNameParm.indexOf("系统资源使用率图表") != -1){
							chartType = 'spline';
							xAxisData.push({
				            	type: 'datetime',
				            	labels:{
				            		formatter:function(){
				            			return Highcharts.dateFormat('%H:%M', this.value);
				            		}
				            	}
				            });
							plotOptionsData = {
				                spline: {
				                    lineWidth: 2,
				                    states: {
				                        hover: {
				                            lineWidth: 4
				                        }
				                    },
				                    marker: {
				                        enabled: false,
				                        states: {
				                            hover: {
				                                enabled: true,
				                                symbol: 'circle',
				                                radius: 5,
				                                lineWidth: 1
				                            }
				                        }
				                    },
				                    pointInterval: 300000, // 5分钟
				                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 07, 06, 00)
				                }
				            };
							toolTipData = {
									crosshairs: true,
				 	                formatter: function() {
				 	                	var unit;
				 	                	if(tmp.toolTipUnit){
					 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
				 	                	}	
				 	                	return ''+
				 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
				 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
				 	                }
				 	         };
						}else if(sheetNameParm.indexOf("当日网络资源使用情况") != -1 ){
							chartType = 'spline';
							xAxisData.push({
				            	type: 'datetime',
				            	labels:{
				            		formatter:function(){
				            			return Highcharts.dateFormat('%H:%M', this.value);
				            		}
				            	}
				            });
							plotOptionsData = {
				                spline: {
				                    lineWidth: 2,
				                    states: {
				                        hover: {
				                            lineWidth: 4
				                        }
				                    },
				                    marker: {
				                        enabled: false,
				                        states: {
				                            hover: {
				                                enabled: true,
				                                symbol: 'circle',
				                                radius: 5,
				                                lineWidth: 1
				                            }
				                        }
				                    },
				                    pointInterval: 300000, // 5分钟
				                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 00, 01, 00)
				                }
				            };
							toolTipData = {
									crosshairs: true,
				 	                formatter: function() {
				 	                	var unit;
				 	                	if(tmp.toolTipUnit){
					 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
				 	                	}	
				 	                	return ''+
				 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
				 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
				 	                }
				 	         };
						}else if(sheetNameParm.indexOf("当日weblogic使用情况") != -1 ){
							chartType = 'spline';
							xAxisData.push({
				            	type: 'datetime',
				            	labels:{
				            		formatter:function(){
				            			return Highcharts.dateFormat('%H:%M', this.value);
				            		}
				            	}
				            });
							plotOptionsData = {
				                spline: {
				                    lineWidth: 2,
				                    states: {
				                        hover: {
				                            lineWidth: 4
				                        }
				                    },
				                    marker: {
				                        enabled: false,
				                        states: {
				                            hover: {
				                                enabled: true,
				                                symbol: 'circle',
				                                radius: 5,
				                                lineWidth: 1
				                            }
				                        }
				                    },
				                    pointInterval: 300000, // 5分钟
				                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 00, 01, 00)
				                }
				            };
							toolTipData = {
									crosshairs: true,
				 	                formatter: function() {
				 	                	var unit;
				 	                	if(tmp.toolTipUnit){
					 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
				 	                	}	
				 	                	return ''+
				 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
				 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
				 	                }
				 	         };
						}else if(sheetNameParm.indexOf("实时分小时累计交易情况") != -1 ){
							chartType = 'spline';
							xAxisData.push({
				            	type: 'datetime',
				            	labels:{
				            		formatter:function(){
				            			return Highcharts.dateFormat('%H:%M', this.value);
				            		}
				            	}
				            });
							plotOptionsData = {
				                spline: {
				                    lineWidth: 2,
				                    states: {
				                        hover: {
				                            lineWidth: 4
				                        }
				                    },
				                    marker: {
				                        enabled: false,
				                        states: {
				                            hover: {
				                                enabled: true,
				                                symbol: 'circle',
				                                radius: 5,
				                                lineWidth: 1
				                            }
				                        }
				                    },
				                    pointInterval: 3600000, // 小时
				                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 01, 00, 00)
				                }
				            };
							toolTipData = {
									crosshairs: true,
				 	                formatter: function() {
				 	                	var unit;
				 	                	if(tmp.toolTipUnit){
					 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
				 	                	}	
				 	                	return ''+
				 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
				 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
				 	                }
				 	         };
						}else{
							chartType = 'line';
							xAxisData.push({
				                categories: xCategoriesOptions,
				                alternateGridColor: '#DCDCDC', //间隔显示不同颜色
				                gridLineWidth :0, //图表网格线0代表无，数字越大线越粗
				                labels: {  //X轴的标签（下面的说明）
				                    align: "right",              //位置
				                    enabled: true,               	//是否显示
				                    //formatter: ,
				                   	rotation: -60/* ,                 //旋转,效果就是影响标签的显示方向
				                    //staggerLines: 4,          //标签的交错显示（上、下）
				                    //step: 2,                      //标签的相隔显示的步长
				                    //style:{},
				                    x: 10       */               		//偏移量，默认两个都是0
				                }
				            });
							plotOptionsData = {
				                spline: {
				                    lineWidth: 2,
				                    states: {
				                        hover: {
				                            lineWidth: 3
				                        }
				                    },
				                    marker: {
				                        enabled: false,
				                        states: {
				                            hover: {
				                                enabled: true,
				                                symbol: 'circle',
				                                radius: 5,
				                                lineWidth: 1
				                            }
				                        }
				                    }
				                }
				            };
							toolTipData = {
									crosshairs: true,
				 	                formatter: function() {
				 	                	var unit;
				 	                	if(tmp.toolTipUnit){
					 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
				 	                	}	
				 	                	return ''+
				 	                        this.x + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
				 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
				 	                }
				 	         };
						}
						// 标题
						var titleOption = tmp.titleOption;
						// 对应的科目名及科目值
						var seriesOptions = [];
						for (var k = 0; k < tmp.seriesOptions.length; k++) {
							seriesOptions[k] = {
								name:tmp.seriesOptions[k].name,
								data:tmp.seriesOptions[k].data,
								yAxis:tmp.seriesOptions[k].yAxis
							};
						}
						var yAxisData = [];
						//左
						Ext.each(tmp.yAxisOptions.yAxis, function(item){
							yAxisData.push({
				 				title: {
				                    text: item.yAxisTitle=="null"?'':item.yAxisTitle
				                },
				 			    labels: {
				 			        formatter: function() {
				 			        	var labelVal;
				 			       		switch (item.yAxisUnit) {
				 						case '百':
				 							labelVal =  this.value/100 + item.yAxisUnit;
				 							break;
				 						case '千':
				 							labelVal = this.value/1000 + item.yAxisUnit;
				 							break;
				 						case '万':
				 							labelVal =  this.value/10000 + item.yAxisUnit;
				 							break;
				 						case '十万':
				 							labelVal = this.value/100000 + item.yAxisUnit;
				 							break;
				 						case '百万':
				 							labelVal = this.value/1000000 + item.yAxisUnit;
				 							break;
				 						default :
				 							labelVal = this.value + (item.yAxisUnit=="null"?'':item.yAxisUnit);
				 							break;
				 			        	}
				 			            return labelVal;
				 			        },
				 			        style: {
				 			            color: '#4572A7'
				 			        }
				 			    },
				                plotLines: [{
				                    value: 0,
				                    width: 1,
				                    color: '#000000'
				                }],
				                min :item.yAxisMinval,
				                max :item.yAxisMaxval,
				                tickInterval :item.yAxisInterval,
				                opposite: item.yAxisPosition == 1 ? true : false
				 			});
						});
						// 创建chart图表对象
				        chartKey = new Highcharts.Chart({
				            chart: {
				                renderTo: 'datRptContainer_analyse' + dayRptManageIndexRptDivCount,
				                type: chartType//,
				                //marginRight: 150,
				                //marginBottom: 65
				            },
				            title: {//标题
				                text: titleOption ,/*
				                align: 'center',//水平方向（left, right, center）
				                floating: false,//是否浮动显示
				                x: -20, //center //水平偏移量 
				                y: 10//y:垂直偏移量 */
				                style:{                //样式
				                    cursor: 'pointer',
				                    color: 'red',
				                    fontSize: '20px'
				                }
				            },
				            credits: { ////设置右下角的标记Highcharts.com字样
				            	enabled :false/* , //是否显示
				            	position: {           //显示的位置                   
				                    align: 'right',
				                    x: 0
				                },
				                text: "nantian.com", //显示的文字
				                style:{                //样式
				                    cursor: 'pointer',
				                    color: 'blue',
				                    fontSize: '12px'
				                },
				                href: 'http://www.nantiansoftware.com/' //路径 */
				            },
				            xAxis: xAxisData,
				            yAxis: yAxisData,
				            tooltip: toolTipData,
				            plotOptions : plotOptionsData,
				            legend: {
				                layout: 'vertical',
				                align: 'right',
				                verticalAlign: 'top',
				                y: 100,
				                borderWidth: 1,            //边框宽度
				                backgroundColor: '#FFFFFF',//背景颜色
				                //borderColor: 'red'			//边框颜色
				                borderRadius:5,        //边框圆角,此属性会导致servlet下载图片异常
				                //enabled: false          //是否显示图例说明
				                //floating:true           //是否浮动显示(效果就是会不会显示到图中)
				                //itemHiddenStyle: {color: 'red'}
				                itemHoverStyle: {color: 'red',fontSize: '13px'}  //鼠标放到某一图例说明上，文字颜色的变化颜色
				                //itemStyle:  {color: 'red'}   //图例说明的样式
				                //itemWidth: 150                  //图例说明的宽度
				                //labelFormatter: function() { return this.value}       //默认(return this.name)
				                //lineHeight: 1000             //没看出明显效果
				                //margin: 20
				                //reversed:true                //图例说明的顺序（是否反向）
				                //shadow:true,                  //阴影
				                //style: {color:'black'}
				                //symbolPadding: 100           //标志（线）跟文字的距离
				                //symbolWidth: 100             //标志的宽
				                //width:140
				            },
				            series: seriesOptions
				        });
						break;
					case "2": //柱状图

						var xCategoriesOptions = tmp.xCategoriesOptions.split(",");
						// 标题
						var titleOption = tmp.titleOption;
						// 对应的科目名及科目值

						var seriesOptions = [];
						for (var k = 0; k < tmp.seriesOptions.length; k++) {
							seriesOptions[k] = {
								name:tmp.seriesOptions[k].name,
								data:tmp.seriesOptions[k].data,
								yAxis:tmp.seriesOptions[k].yAxis,
								dataLabels: {
				                    enabled: true,
				                    rotation: -90,
				                    color: '#FFFFFF',
				                    align: 'right',
				                    x: 4,
				                    y: 10,
				                    style: {
				                        fontSize: '13px',
				                        fontFamily: 'Verdana, sans-serif'
				                    }
				                }
							};
						}
						var yAxisData = [];
						Ext.each(tmp.yAxisOptions.yAxis, function(item){
							yAxisData.push({
				 				title: {
				                    text: item.yAxisTitle=="null"?'':item.yAxisTitle
				                },
				 			    labels: {
				 			        formatter: function() {
				 			        	var labelVal;
				 			       		switch (item.yAxisUnit) {
				 						case '百':
				 							labelVal =  this.value/100 + item.yAxisUnit;
				 							break;
				 						case '千':
				 							labelVal = this.value/1000 + item.yAxisUnit;
				 							break;
				 						case '万':
				 							labelVal =  this.value/10000 + item.yAxisUnit;
				 							break;
				 						case '十万':
				 							labelVal = this.value/100000 + item.yAxisUnit;
				 							break;
				 						case '百万':
				 							labelVal = this.value/1000000 + item.yAxisUnit;
				 							break;
				 						default :
				 							labelVal = this.value + (item.yAxisUnit=="null"?'':item.yAxisUnit);
				 							break;
				 			        	}
				 			            return labelVal;
				 			        },
				 			        style: {
				 			            color: '#4572A7'
				 			        }
				 			    },
				                plotLines: [{
				                    value: 0,
				                    width: 1,
				                    color: '#000000'
				                }],
				                min :item.yAxisMinval,
				                max :item.yAxisMaxval,
				                tickInterval :item.yAxisInterval,
				                opposite: item.yAxisPosition == 1 ? true : false
				 			});
						});
						chartKey = new Highcharts.Chart({
				            chart: {
				            	renderTo: 'datRptContainer_analyse' + dayRptManageIndexRptDivCount,
				                type: 'column',
				                margin: [ 50, 50, 100, 80]
				            },
				            title: {
				                text: titleOption
				            },
				            xAxis: {
				                categories: xCategoriesOptions,
				                labels: {
				                    rotation: -45,
				                    align: 'right',
				                    style: {
				                        fontSize: '13px',
				                        fontFamily: 'Verdana, sans-serif'
				                    }
				                }
				            },
				            yAxis: yAxisData,
				            legend: {
				                enabled: false
				            },
				            credits: {
				            	enabled :false
				            },
				            tooltip: {
				                formatter: function() {
				                    return '<b>'+ this.x +'</b><br/>' + Highcharts.numberFormat(this.y, 2);
				                }
				            },
				            plotOptions: {
				                column: {
				                    stacking: 'normal',
				                    color: "red",
				                    borderWidth: 1,
			                		shadow: false,
				                    dataLabels: {
				                        enabled: true,
				                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
				                    }
				                }
				            },
				            series: seriesOptions
				        });
						break;
					case "3": //饼图
						var seriesOptions = [];
						for (var k = 0; k < tmp.seriesOptions.length; k++) {
							var type;
							switch(tmp.seriesOptions[k].type){
								case 1 : type = 'spline';break; 
								case 2 : type = 'column';break;
								case 3 : type = 'pie';break;
								default : type = 'line';break;
							}
							seriesOptions[k] = {
								name:tmp.seriesOptions[k].name,
								data:tmp.seriesOptions[k].data,
								type:type,
								yAxis:tmp.seriesOptions[k].yAxis
							};
						}
						chartKey = new Highcharts.Chart({
				            chart: {
				                renderTo: 'datRptContainer_analyse' + dayRptManageIndexRptDivCount,
				                plotBackgroundColor: null,
				                plotBorderWidth: null,
				                plotShadow: false
				            },
				            title: {
				                text: tmp.titleOption,
				                style:{//样式
				                    cursor: 'pointer',
				                    color: 'red',
				                    fontSize: '20px'
				                }
				            },
				            credits: { ////设置右下角的标记Highcharts.com字样
				            	enabled :false
				            },
				            tooltip: {
				        	    pointFormat: '{series.name}: <b>{point.percentage}%</b>',
				            	percentageDecimals: 1
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
				                            return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage, 2) +' %';
				                        }
				                    }
				                }
				            },
				            series: seriesOptions
				        });
						break;
					case "4": //条形图
						break;
				}
				//保存创建的chart对象，用于导出功能
		        dayRptManageIndexChartsArr.push(chartKey);
				//计数-对应div的id
				dayRptManageIndexRptDivCount++;
			});
		}
	});
}

//获取动态列名及数据源字段列表

function dayRptManageIndexCreateGridColAndDsfields_analyse(aplCodeParm, reportTypeParm, sheetNameParm, endDateParm,subSheetNameParm){
	//var  jsonstr = "{'columnModel':[{header : '对公账务总交易量',dataIndex : 'item1',sortable : true}],'fieldsNames':[{name : 'item1'}]}";
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${managePath}/dayrptmanage/getCols',
		params: {aplCode : aplCodeParm,
			reportType : reportTypeParm,
			sheetName : sheetNameParm,
			endDate : endDateParm,
			subSheetName  : subSheetNameParm},
		disableCaching : true,	//禁止缓存
		async : false, //同步请求
		success : function(response,option){
			var text = response.responseText;
			dayRptManageIndexCmItems_analyse = Ext.util.JSON.decode(Ext.util.JSON.decode(text).columnModel);
			dayRptManageIndexDsFields_analyse = Ext.util.JSON.decode(Ext.util.JSON.decode(text).fieldsNames);
			dayRptManageIndexGridCols_analyse = new Ext.grid.ColumnModel(dayRptManageIndexCmItems_analyse);
			dayRptManageIndexColumnHeaderGroupList_analyse = Ext.util.JSON.decode(text).columnHeaderGroupList;
			dayRptManageIndexColumnHeaderGroupColspan_analyse = Ext.util.JSON.decode(text).columnHeaderGroupColspan;
		},
		// 请求失败时
		failure : function(response){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '在读取动态数据时发生错误，请重新刷新后，再打开菜单再试!',
				fn : function() {
					Ext.getCmp("DayRptManageIndexAplCode_analyse").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		},
		callback : function(options,success,response){
		}
	});
}
//	重新实例化数据源对象，为了解决动态fields替换问题
function dayRptManageIndexCreateStore_analyse(){
	// 实例化数据列表数据源
	dayRptManageIndexGridStore_analyse = new Ext.data.JsonStore({
		proxy : new Ext.data.HttpProxy( {
			method : 'POST',
			url : '${ctx}/${managePath}/dayrptmanage/index',
			disableCaching : true
		}),
		autoDestroy : true,
		root : 'data',
		totalProperty : 'count',
		fields : dayRptManageIndexDsFields_analyse,
		remoteSort : true,
		sortInfo : {
			field : 'appsyscd',
			direction : 'ASC'
		},
		baseParams : {
			start : 0,
			limit : pageSize
		}
	});
	dayRptManageIndexGridStore_analyse.on("load",function(){
		if(dayRptManageIndexGridStore_analyse.getTotalCount() != 0){
			var aplCode = Ext.getCmp('DayRptManageIndexAplCode_analyse').getValue().trim();
			var reportType = Ext.getCmp('DayRptManageIndexReportType_analyse').getValue().trim();
			var startTime = Ext.util.Format.date(Ext.getCmp('DayRptManageIndexStartTime_analyse').getValue(),'Ymd');
			var endTime = Ext.util.Format.date(Ext.getCmp('DayRptManageIndexEndTime_analyse').getValue(),'Ymd');
			var subSheetName = Ext.getCmp('DayRptManageIndexSubSheetName_analyse').getValue().trim();
			//启用bbar
			dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(false);
			//创建图表
			dynamicDelRptChartDiv_analyse();
			dayRptManageIndexCreateChart_analyse(aplCode,reportType,Ext.getCmp("DayRptManageIndexSheetName_analyse").getValue().trim(),startTime,endTime,subSheetName);
		}else{
			//未查询到数据时，清除上次查询的图表div对象
			dynamicDelRptChartDiv_analyse();
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '无此时间段数据，请重新设定日报日期!',
				fn : function() {
					Ext.getCmp("DayRptManageIndexEndTime_analyse").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			//数据不存在时，清空图表数据，防止导出上次查询的图表数据
			dayRptManageIndexChartsArr = [];
		}
	});
}
//	重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugins
function dayRptManageIndexReconfigureGird_analyse(sheetName){
	dayRptManageIndexGrid_analyse.colModel = dayRptManageIndexGridCols_analyse;
	var groupRow = [];
	switch (sheetName.split("(",1)[0]) {
		case '最近31天日交易情况': 
			break;
		case '最近7天分小时交易情况': 
		case '最近7天日批量执行情况': 
		case '最近31天分钟和秒交易情况':
		case '最近31天日批量执行情况':
		case '系统资源使用率图表':
		case '实时分小时累计交易情况':
			groupRow.push({
		        header: '',
		        align: 'center',
		        colspan: 2
		    });
			Ext.each(dayRptManageIndexColumnHeaderGroupList_analyse, function(val){
				groupRow.push({
		            header: val,
		            align: 'center',
		            colspan: dayRptManageIndexColumnHeaderGroupColspan_analyse
		        });
			});
			break;
		case '当日网络资源使用情况':
		case '当日weblogic使用情况':
		case '最近31天日网络资源使用情况':
		case '最近31天日weblogic使用情况':
			 groupRow.push({
		        header: null,
		        align: 'center',
		        colspan: 1
		    }); 
			Ext.each(dayRptManageIndexColumnHeaderGroupList_analyse, function(val){
				if(val.childNum != 0){
					groupRow.push({
			            header: val.columnsHeader,
			            align: 'center',
			            colspan: val.childNum
			        });
				}
			});
			break;
	}
	dayRptManageIndexGrid_analyse.colModel['rows'] = [groupRow];
	dayRptManageIndexGrid_analyse.reconfigure(dayRptManageIndexGridStore_analyse, dayRptManageIndexGrid_analyse.colModel);
	//	重新绑定bbar的store到新实例化的数据源
	dayRptManageIndexGrid_analyse.getBottomToolbar().bind(dayRptManageIndexGridStore_analyse);
}

//	动态创建图表所用div对象
function dynamicCreateRptChartDiv_analyse(divCount,sheetName){
	if(divCount == '' || divCount == 0){
		Ext.Msg.show({
			title : '<fmt:message key="message.title"/>',
			msg : '未配置图表展示内容，请先到图表配置页面进行配置!',
			fn : function() {
				Ext.getCmp("DayRptManageIndexAplCode_analyse").focus();
			},
			buttons : Ext.Msg.OK,
			icon : Ext.MessageBox.INFO
		});
	}else{
		dynamicDelRptChartDiv_analyse();
		//增大宽度显示图像
		if(sheetName=='系统资源使用率图表')	document.getElementById("datRptContainer_analyse").style.width = '100%';
		for(var i=0; i<divCount; i++){
			if(document.getElementById("datRptContainer_analyse"+i) == null){
				var newLineNode='';
				var newDivNode = document.createElement("div");
				newDivNode.setAttribute("id","datRptContainer_analyse"+i);
				newDivNode.style.width="100%";
				if(divCount != 1){
					newLineNode = document.createElement("HR");
					newLineNode.style.filter="alpha(opacity=100,finishopacity=100,style=1)";
					newLineNode.width="100%";
					newLineNode.color="#987cb9";
					newLineNode.size=3;
					//newDivNode.style.border="1px solid black";
					newDivNode.style.height="290px";
				}else{
					newDivNode.style.border="";
					newDivNode.style.height="360px";
				}
				document.getElementById("datRptContainer_analyse").appendChild(newDivNode);
				if(newLineNode != '') document.getElementById("datRptContainer_analyse").appendChild(newLineNode);
			}
		}
	}
}
//动态删除存在的div对象
function dynamicDelRptChartDiv_analyse(){
	document.getElementById("datRptContainer_analyse").innerHTML = '';
	//恢复显示图像默认宽度比例
	document.getElementById("datRptContainer_analyse").style.width = '100%';
}

//定义列表
DayRptManageIndex_analyse = Ext.extend(Ext.Panel, {
		tabIndex : 0,// 查询表单组件Tab键顺序
		dayRptManageIndexForm_analyse : null,
		// 构造方法
		constructor : function(cfg) {
		Ext.apply(this, cfg);
		//加载系统代码数据
		aplCodeStore.load();
		//加载运行状态
		runStatueStore.load();
		handleStateStore.load();
		// 实例化数据列表数据源
		dayRptManageIndexGridStore_analyse = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/dayrptmanage/index',
				disableCaching : true,
				timeout : 999999
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [],
			remoteSort : true,
			sortInfo : {
				field : 'appsyscd',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			}
		});
		
		// 实例化数据列表组件
		//dayRptManageIndexGridCols_analyse = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer(),{header : '日期',dataIndex : 'item1',sortable : true},{header : '对公账务总交易量',dataIndex : 'item2',sortable : true},{header : '银企通账务总交易量',dataIndex : 'item3',sortable : true},{header : '对私账务总交易量',dataIndex : 'item4',sortable : true},{header : '对私查询交易量',dataIndex : 'item5',sortable : true},{header : '实时交易总量',dataIndex : 'item6',sortable : true}]);
		dayRptManageIndexGrid_analyse = new Ext.grid.GridPanel({
			id : 'DayRptManageIndexGridPanel_analyse',
			title : '巡检数据',
			region : 'south',
			height : 250,
			border : false,
		    minSize: 300,
		    maxSize: 300,
			loadMask : true,
			columnLines : true,
			autoScroll : true,
			//collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
		    view: new Ext.ux.grid.BufferView({
			    // custom row height
			    rowHeight: 20,
			    // render rows as they come into viewable area.
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
			store : dayRptManageIndexGridStore_analyse,
			// 列定义
			cm : new Ext.grid.ColumnModel([{header : '',sortable : true}]),
			plugins : dayRptManageIndexColumnHeaderGroup_analyse,
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : dayRptManageIndexGridStore_analyse,
				displayInfo : true,
				pageSize  : pageSize,
				buttons : [ '-', {
					id : 'DayRptManageIndexGridExportButton_analyse',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					text : '导出excel',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				}]
			})
		});
		
		//	实例化查询表单
		dayRptManageIndexForm_analyse = new Ext.FormPanel({
			id : 'DayRptManageIndexFormPanel_analyse',
			hidden: true,
			title : '条件',
			region:'east',
			frame : true,
			split : true,
			//autoHeight: true,
			labelAlign : 'right',
			labelWidth: 55,
			width : 280,
			height : 250,
			minSize : 280,
			maxSize : 280,
			autoScroll : true,
			collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
			defaults: {
            	anchor: '98%',
            	allowBlank: false,
            	msgTarget: 'side'
        	},
			items : [{
				xtype : 'textfield',
				fieldLabel : '系统代码',
				id : 'DayRptManageIndexAplCode_analyse',
				hiddenName : 'aplCode',
				value : aplCode ,
				tabIndex : this.tabIndex++,
				readOnly : true ,
				hidden : true ,
				listeners : {/* 
					'beforerender' : function(){
						//设置默认初始查询日期
						Ext.getCmp("DayRptManageIndexEndTime_analyse").setValue(transDate);
						//若重新输入树形菜单的系统代码，则初始化查询表单的sheetName字段，待重新点击功能菜单后再设定该值，防止数据查询时参数值错误
						Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue('');
						//获取树形菜单的根节点
						var _treeRoot = dayRptManageIndexTreePanel_analyse.getRootNode();
						if(Ext.getCmp("DayRptManageIndexAplCode_analyse").getValue().trim() != ''){
							//清空div对象、图表数组数据、gridsotre数据
							dynamicDelRptChartDiv_analyse();
							dayRptManageIndexChartsArr =[];
							dayRptManageIndexGrid_analyse.getStore().removeAll();
							//禁用bbar
							dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
							//重新加载树形菜单
							_treeRoot.reload();
							//完全展开树形菜单
							//_treeRoot.expandAll();
							dayRptManageIndexTreePanel_analyse.expandAll();

							
						}else{
							// 当树形的系统代码删除为空时，清空树形菜单
							_treeRoot.removeAll();
						}
					}
				 */}
			},{
				xtype : 'textfield',
				fieldLabel : '系统代码',
				id : 'DayRptManageIndexAplName_analyse',
				name : 'aplName',
				value : aplName ,
				readOnly : true ,
				tabIndex : this.tabIndex++
			},{
			    xtype : 'datefield',
				fieldLabel : '日报日期',
				id : 'DayRptManageIndexEndTime_analyse',
				name : 'endDate',
				value : transDate,
				format : 'Ymd',
				readOnly : true ,
				tabIndex : this.tabIndex++,
				listeners : {/* 
					'beforerender' : function(){
						var sheetName = Ext.getCmp("DayRptManageIndexSheetName_analyse").getValue();
						if(sheetName == '最近7天分小时交易情况'){
							var agoDate7 = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -6),'Ymd');
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(agoDate7);
						}else if(sheetName == '实时分小时累计交易情况'){
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(transDate);
						}else{
							var agoDate30 = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -30),'Ymd');
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(agoDate30);
						}
					} */
				}
			},{
			    xtype : 'datefield',
				fieldLabel : '起始日期',
				id : 'DayRptManageIndexStartTime_analyse',
				name : 'startDate',
				tabIndex : this.tabIndex++,
				allowBlank : false,
				format : 'Ymd',
				editable : false,
				emptyText : '请输入起始日期',
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '功能名称',
				id : 'DayRptManageIndexSheetName_analyse',
				name : 'sheetName',
				tabIndex : this.tabIndex++,
				allowBlank : false,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '报表类型',
				id : 'DayRptManageIndexReportType_analyse',
				name : 'reportType',
				value : '1',
				tabIndex : this.tabIndex++,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '子功能名称',
				id : 'DayRptManageIndexSubSheetName_analyse',
				name : 'subSheetName',
				tabIndex : this.tabIndex++,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '导出时清空图片流缓存标识',
				id : 'ClearByteArrayOutputStreamFlag_analyse',
				name : 'clearFlag',
				tabIndex : this.tabIndex++,
				hidden : true
			}],
			listeners : {
				'beforerender' : function(){
					
					//设置默认初始查询日期
					Ext.getCmp("DayRptManageIndexEndTime_analyse").setValue(transDate);
					//若重新输入树形菜单的系统代码，则初始化查询表单的sheetName字段，待重新点击功能菜单后再设定该值，防止数据查询时参数值错误

					Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue('');
					//获取树形菜单的根节点
					var _treeRoot = dayRptManageIndexTreePanel_analyse.getRootNode();
					if(Ext.getCmp("DayRptManageIndexAplCode_analyse").getValue().trim() != ''){
						//清空div对象、图表数组数据、gridsotre数据
						dynamicDelRptChartDiv_analyse();
						dayRptManageIndexChartsArr =[];
						dayRptManageIndexGrid_analyse.getStore().removeAll();
						//禁用bbar
						dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
						//重新加载树形菜单
						_treeRoot.reload();
						//完全展开树形菜单
						//_treeRoot.expandAll();
						dayRptManageIndexTreePanel_analyse.expandAll();

						
					}else{
						// 当树形的系统代码删除为空时，清空树形菜单
						_treeRoot.removeAll();
					}
					

					var sheetName = Ext.getCmp("DayRptManageIndexSheetName_analyse").getValue();
					if(sheetName == '最近7天分小时交易情况'){
						var agoDate7 = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -6),'Ymd');
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(agoDate7);
					}else if(sheetName == '实时分小时累计交易情况'){
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(transDate);
					}else{
						var agoDate30 = Ext.util.Format.date(new Date(Date.parseDate(transDate,'Ymd')).add(Date.DAY, -30),'Ymd');
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(agoDate30);
					}
				}
			}
		});
		// 实例化树形功能菜单
		dayRptManageIndexTreeLoader_analyse = new Ext.tree.TreeLoader({
			dataUrl : '${ctx}/${managePath}/dayrptmanage/browseTreeDataForAnalyse',
			requestMethod  : 'POST',
			clearOnLoad : true,
			autoLoad : false,
			baseParams : {
				aplCode : aplCode,
				reportType : '1'
			}
		});
		var root = new Ext.tree.AsyncTreeNode({
			id : 'treeRoot_analyse',
			text :  aplName+'('+transDate+')',
			leaf : true,
			draggable : false,
			iconCls : 'node-root',
			listeners : {
			      'load' : function(node) {/* 
			      		node.leaf = false;//置成false否则下面的方法始终为false
			    	 	if(node.hasChildNodes()){
			    	 		Ext.getCmp("DayRptManageIndexExportAllExcel_analyse").setDisabled(false);//全量导出按钮可用
			    	 	}else{
			    	 		Ext.getCmp("DayRptManageIndexExportAllExcel_analyse").setDisabled(true);//全量导出按钮不可用
			    	 	} */
				  }
			}
		});
	
		//实例化分析表单
		dayRptAnalyseForm_analyse = new Ext.FormPanel({
			id : 'DayRptAnalyseFormPanel_analyse',
			title : '分析',
			region:'center',
			frame : true,
			split : true,
			height : 250,
			labelAlign : 'right',
			labelWidth: 60,
			autoScroll : true,
			collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
			defaults: {
            	anchor: '95%',
            	msgTarget: 'side'
        	},
			items : [{
				xtype : 'textfield',
				fieldLabel : '分析项',
				id : 'DayRpt_analyseItem_analyse',
				name: '',
				tabIndex : this.tabIndex++,
				readOnly : true 
			},
			{
				layout:'column',
				items:[{
				     columnWidth:.4,
				     layout:'form',
          	  
                items : [{
    				xtype : 'combo',
    				fieldLabel : '运行状态',
    				id : 'DayRpt_runState_analyse',
    				hiddenName : '',
    				displayField : 'name',
    				valueField : 'value',
    				typeAhead : true,
    				forceSelection  : true,
    				store : runStatueStore,
    				tabIndex : this.tabIndex++,
    				mode : 'local',
    				readOnly:true,
    				triggerAction : 'all',
    				editable : true
    			}]
				},{
				     columnWidth:.6,
				     layout:'form',
				    
				     items:[ {
							xtype : 'combo',
							fieldLabel : '处理状态',
							id : 'DayRpt_handleState_analyse',
							hiddenName : '',
							displayField : 'name',
							valueField : 'value',
							typeAhead : true,
							forceSelection  : true,
							store : handleStateStore,
							tabIndex : this.tabIndex++,
							mode : 'local',
							hidden:true,
							triggerAction : 'all',
							editable : true
						},{
						 	xtype : 'radiogroup',
							fieldLabel : '处理状态',
							
							items : [
									{
										boxLabel : '正常',
										id:'DayRpt_handleState_analyse_1',
										name : 'checked',
										inputValue : 'true',
										listeners:{
											'check' : function(obj){
												if(Ext.getCmp('DayRpt_handleState_analyse_1').getValue()==true){
													Ext.getCmp('DayRpt_handleState_analyse').setValue('1');
												}else{
													Ext.getCmp('DayRpt_handleState_analyse').setValue('2');
												}
												}
											}
									},
									{
										boxLabel : '异常',
										id:'DayRpt_handleState_analyse_2',
										name : 'checked',
										inputValue : 'false'
									} ]
						
						}]
				}]
                }
			,{
			    xtype : 'textarea',
				fieldLabel : '分析结果',
				height : 80 ,
				id : 'DayRpt_analyseResult_analyse',
				tabIndex : this.tabIndex++,
				emptyText : '请输入文本...'
			}],
			// 定义查询表单按钮
			buttonAlign : 'center',
			// 定义查询表单按钮
			buttons : [ {
				text : '上一项',
				iconCls : '',
				scope : this,
				handler : this.showBeforeItem
			}, {
				text : '下一项',
				iconCls : '',
				scope : this,
				handler : this.showNextItem
			}]
		});
		
		var centerPanel_analyse = new Ext.Panel({
			id:'DayRptManageIndexCenterPanel_analyse',
			title : '巡检图表',
			region : 'center',
			height : 250,
			border : false,
		    minSize: 400,
		    maxSize: 400,
			loadMask : true,
			columnLines : true,
			autoScroll : true,
			//collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
			contentEl: 'datRptContainer_analyse'
		});
		
		/* var southPanel = new Ext.Panel({
			region:'south',
			layout : 'border',
			height : 500 ,
			items : [centerPanel_analyse,dayRptManageIndexGrid_analyse]
		}); */
		
		dayRptManageIndexTreePanel_analyse = new Ext.tree.TreePanel({
			id : "DayRptManageIndexTreePanel_analyse",
			title : "巡检项",
			region : 'west',
			width : 330,
			height : 250,
			minSize : 300,
			maxSize : 350,
			//autoHeight : true,
            //enableDD:true,
			rootVisible : true,//根节点是否可见			split : true,
			lines : true,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			loader : dayRptManageIndexTreeLoader_analyse,
			root : root,
			tools : [{
				id : 'refresh',
				scope : this,
				handler : function() {
					var selectedNodePath = null;
					if (dayRptManageIndexTreePanel_analyse.getSelectionModel().getSelectedNode() != null) {
						selectedNodePath = dayRptManageIndexTreePanel_analyse.getSelectionModel().getSelectedNode().getPath();
					}
					dayRptManageIndexTreePanel_analyse.root.reload();
					dayRptManageIndexTreePanel_analyse.root.expand();
					if (selectedNodePath != null) {
						dayRptManageIndexTreePanel_analyse.selectPath(selectedNodePath);
					}
				}
			}],
			tbar :[/* {
				xtype: 'displayfield',
				value : '<table border="0" width="140"><tr><td align="left"><font style="color:DimGray;align:right;font-weight:bold;">全量导出=></font></td></tr></table>'
			},'->','-',{
				id : "DayRptManageIndexExportAllExcel_analyse",
				iconCls : 'button-excel',
				tooltip : '<fmt:message key="button.excel" />',
				scope : this,
				handler : this.doExportAll,
				disabled : true
			} */],
			listeners:{
				'load' : function(){
					var transDateLoad = decodeURIComponent('${param.transDate}');
					//点击第一个分析科目------------------begin
					var _treeRoot = dayRptManageIndexTreePanel_analyse.getRootNode();
					var node ; //下一个叶子节点
					var anaItem = '' ; //分析科目
					node = _treeRoot.item(0);
					//选中该节点
					//node.select(); //IE报错：Ext.fly()为空或不是对象，firefox正常
					/* var tree = Ext.getCmp('DayRptManageIndexTreePanel_analyse');
					tree.getSelectionModel().select(node); 
					tree.fireEvent('select',node); */
					
					//清除所有选中的复选框
					var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
					Ext.each(selNodes, function(_node){
						_node.attributes.checked = false;
						_node.ui.checkbox.checked = false;
					}); 
					if(node.isLeaf()==false){
						if(node.parentNode==tree.getRootNode()){
							node = node.item(0);
						}
						//勾选 begin
						state = true;
						node.cascade(function(childNode){
							 if(childNode.getDepth()>2){
								 childNode.attributes.checked=state;
								 childNode.ui.checkbox.checked=state;
							 }
			            });
			            //勾选 end
						var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
						subSheetNames = [];
						sheetName = '';
						Ext.each(selNodes, function(_node){
							if(_node.leaf == true){
			                   subSheetNames.push(_node.attributes.subSheetName);
			                   sheetName = _node.attributes.sheetName;
							}
						});
			            Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetNames);
			            Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
					}
					
					if(node.parentNode != _treeRoot){
						anaItem = node.parentNode.text+'_'+node.text;
					}else{
						anaItem = node.text;
					}
					Ext.getCmp("DayRpt_analyseItem_analyse").setValue(anaItem);
					//加载分析结果数据
					Ext.Ajax.request({
						url : '${ctx}/${appPath}/checkreport/showAnalyseData',
						scope : this,
						params : {
							aplCode : aplCode,
							transDate : transDateLoad,
							transTime : transTime,
							anaItem : anaItem
						},
						success : function(resp,opts){
							var respText = Ext.util.JSON.decode(resp.responseText);
							var status = '1' ;
							var exeAnaDesc = '' ;
							if(respText.status){
								status = respText.status;
							}
							if(respText.exeAnaDesc){
								exeAnaDesc = respText.exeAnaDesc;
							}
							
							var handleState='1';
							if(respText.handleState){
								handleState = respText.handleState;
							}
							if(handleState!=''){
								Ext.getCmp('DayRpt_handleState_analyse').setValue(handleState);
								
								if( handleState=='1'){
									Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
									Ext.getCmp('DayRpt_handleState_analyse_2').setValue(false);
								
							}else{
								Ext.getCmp('DayRpt_handleState_analyse_1').setValue(false);
								Ext.getCmp('DayRpt_handleState_analyse_2').setValue(true);
							 }
							}
							if(status!=''){
								Ext.getCmp('DayRpt_runState_analyse').setValue(status);
							}
							if(exeAnaDesc!=''){
								Ext.getCmp('DayRpt_analyseResult_analyse').setValue(exeAnaDesc);
							}
						}
					});
					
					var sheetName;
					var subSheetName;
					var reportType;
					//Ext.getCmp("DayRptManageIndexTreePanel_analyse").collapse();//自动隐藏树形菜单
					//禁用bbar
					dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
					
					reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
					if(node.text.indexOf("(") != -1){
						if(node.attributes.sysRes == true){
							//系统资源子节点
							sheetName = node.attributes.sheetName;
							subSheetName = node.attributes.subSheetName;
						}else{
							sheetName = node.text;
							subSheetName = node.text.split("(")[1].split(")")[0];
						}
						//设置点击的功能菜单名到查询表单中的隐藏项目
						Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
						Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
					}else{
						if(node.attributes.sysRes == true){
							//系统资源子节点
							sheetName = node.attributes.sheetName;
							subSheetName = Ext.getCmp("DayRptManageIndexSubSheetName_analyse").getValue().trim();
						}else{
							sheetName = node.text;
							subSheetName = '';
						}
						//设置点击的功能菜单名到查询表单中的隐藏项目
						Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
						Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
					}
					//点击非根节点
					if(sheetName != '日报功能列表' && node.leaf == true){
						switch (sheetName) {
						case '最近7天分小时交易情况': 
							var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateLoad,'Ymd')).add(Date.DAY, -7),'Ymd');
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
							break;
						case '实时分小时累计交易情况':
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateLoad,'Ymd'));
							break;
						default:
							dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateLoad,'Ymd')).add(Date.DAY, -31),'Ymd');
							Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
							break;
						}
						if(sheetName != '运行情况总结'){
							//获取动态列名及数据源字段列表
							dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateLoad,subSheetName);
							//创建sotre为了重新配置store动态fields
							dayRptManageIndexCreateStore_analyse();
							//重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugins
							dayRptManageIndexReconfigureGird_analyse(sheetName);
							//配置Store参数
							//Ext.apply(dayRptManageIndexGridStore_analyse.baseParams, dayRptManageIndexForm_analyse.getForm().getValues());
							var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
							dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
							dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
							dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
							dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
							dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateLoad;
							dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
							//加载
							dayRptManageIndexGridStore_analyse.reload();
						}else{
							if(Ext.util.Format.date(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue(),'Ymd')==''){
								Ext.getCmp("DayRptManageIndexEndTime_analyse").setValue(endDate);
							}else{
								endDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue(),'Ymd');
							}
							reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
							var params = {
									aplCode : aplCode,
									reportType : reportType,
									endDate : endDate
								};
							//app.loadWindow('${ctx}/${managePath}/aplanalyze/forrpt', params); //弹出页面方式
							//如果标签页存在,重载页面
							var tab = Ext.getCmp("APL_ANALYZE");
							if(tab){
								tab.setTitle("应用系统运行分析");
							}
							app.loadTab('APL_ANALYZE', "应用系统运行分析", '${ctx}/${managePath}/aplanalyze/forrpt', params);
						} 
					}
					//点击第一个分析科目------------------end
				},
					
				click : function(node){
					var tree = Ext.getCmp('DayRptManageIndexTreePanel_analyse');
					if(node.isLeaf()==false && node.parentNode==tree.getRootNode()){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '请选择叶子节点进行分析！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
				    	});
					}else{
						var transDateClick = decodeURIComponent('${param.transDate}');
						//清除以前的分析数据
						Ext.getCmp("DayRpt_analyseItem_analyse").setValue('');
						
						Ext.getCmp('DayRpt_handleState_analyse').setValue('1');
						Ext.getCmp('DayRpt_analyseResult_analyse').setValue('');
						var aplCode = Ext.getCmp('DayRptManageIndexAplCode_analyse').getValue();
						if((node.isLeaf()==false && node.parentNode==tree.getRootNode()) || node.getDepth()>2){
						}else{ //显示分析数据
							var itemName ;
							if(node.parentNode != Ext.getCmp('DayRptManageIndexTreePanel_analyse').getRootNode()){
								itemName = node.parentNode.text+'_'+node.text;
							}else{
								itemName = node.text;
							}
							Ext.getCmp("DayRpt_analyseItem_analyse").setValue(itemName);
							//加载分析结果数据
							var anaItem = itemName;
							Ext.Ajax.request({
								url : '${ctx}/${appPath}/checkreport/showAnalyseData',
								scope : this,
								params : {
									aplCode : aplCode,
									transDate : transDateClick,
									transTime : transTime,
									anaItem : anaItem
								},
								success : function(resp,opts){
									var respText = Ext.util.JSON.decode(resp.responseText);
									var status = '1' ;
									var handleState = '1' ;
									var exeAnaDesc = '' ;
									if(respText.status){
										status = respText.status;
									}
									if(respText.exeAnaDesc){
										exeAnaDesc = respText.exeAnaDesc;
									}
									if(respText.handleState){
										handleState = respText.handleState;
									}
									if(handleState!=''){
										Ext.getCmp('DayRpt_handleState_analyse').setValue(handleState);
										
										if( handleState=='1'){
											Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
											Ext.getCmp('DayRpt_handleState_analyse_2').setValue(false);
									}else{
										Ext.getCmp('DayRpt_handleState_analyse_1').setValue(false);
										Ext.getCmp('DayRpt_handleState_analyse_2').setValue(true);
									 }
									}
									if(status!=''){
										Ext.getCmp('DayRpt_runState_analyse').setValue(status);
										
									}
									if(exeAnaDesc!=''){
										Ext.getCmp('DayRpt_analyseResult_analyse').setValue(exeAnaDesc);
									}
								}
							});
						}
						//清除所有选中的复选框
						var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
						Ext.each(selNodes, function(_node){
							_node.attributes.checked = false;
							_node.ui.checkbox.checked = false;
						}); 
						if(node.isLeaf()==false){
							if(node.parentNode==tree.getRootNode()){
								node = node.item(0);
							}
							//勾选 begin
							state = true;
							node.cascade(function(childNode){
								 if(childNode.getDepth()>2){
									 childNode.attributes.checked=state;
									 childNode.ui.checkbox.checked=state;
								 }
				            });
				            //勾选 end
							var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
							subSheetNames = [];
							sheetName = '';
							Ext.each(selNodes, function(_node){
								if(_node.leaf == true){
				                   subSheetNames.push(_node.attributes.subSheetName);
				                   sheetName = _node.attributes.sheetName;
								}
							});
				            Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetNames);
				            Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
						}
						var sheetName;
						var subSheetName;
						var reportType;
						//Ext.getCmp("DayRptManageIndexTreePanel_analyse").collapse();//自动隐藏树形菜单
						//禁用bbar
						dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
						reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
						if(node.text.indexOf("(") != -1){
							if(node.attributes.sysRes == true){
								//系统资源子节点
								sheetName = node.attributes.sheetName;
								subSheetName = node.attributes.subSheetName;
							}else{
								sheetName = node.text;
								subSheetName = node.text.split("(")[1].split(")")[0];
							}
							//设置点击的功能菜单名到查询表单中的隐藏项目
							Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
							Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
						}else{
							if(node.attributes.sysRes == true){
								//系统资源子节点
								sheetName = node.attributes.sheetName;
								subSheetName = Ext.getCmp("DayRptManageIndexSubSheetName_analyse").getValue().trim();
							}else{
								sheetName = node.text;
								subSheetName = '';
							}
							//设置点击的功能菜单名到查询表单中的隐藏项目
							Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
							Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
						}
						//点击非根节点
						if(sheetName != '日报功能列表' && node.leaf == true){
							switch (sheetName) {
								case '最近7天分小时交易情况': 
									var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateClick,'Ymd')).add(Date.DAY, -7),'Ymd');
									Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
									break;
								case '实时分小时累计交易情况':
									Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateClick,'Ymd'));
									break;
								default:
									dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateClick,'Ymd')).add(Date.DAY, -31),'Ymd');
									Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
									break;
							}
							if(sheetName != '运行情况总结'){
								//获取动态列名及数据源字段列表
								dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateClick,subSheetName);
								//创建sotre为了重新配置store动态fields
								dayRptManageIndexCreateStore_analyse();
								//重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugins
								dayRptManageIndexReconfigureGird_analyse(sheetName);
								//配置Store参数
								//Ext.apply(dayRptManageIndexGridStore_analyse.baseParams, dayRptManageIndexForm_analyse.getForm().getValues());
								var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
								dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
								dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
								dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
								dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
								dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateClick;
								dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
								//加载
								dayRptManageIndexGridStore_analyse.reload();
							}else{
								reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
								var params = {
										aplCode : aplCode,
										reportType : reportType,
										endDate : transDateClick
									};
								//app.loadWindow('${ctx}/${managePath}/aplanalyze/forrpt', params); //弹出页面方式
								//如果标签页存在,重载页面
								var tab = Ext.getCmp("APL_ANALYZE");
								if(tab){
									tab.setTitle("应用系统运行分析");
								}
								app.loadTab('APL_ANALYZE', "应用系统运行分析", '${ctx}/${managePath}/aplanalyze/forrpt', params);
							} 
						}else if(node.getDepth()==2){
							var sheetName = Ext.getCmp('DayRptManageIndexSheetName_analyse').getValue().trim();
							var subSheetName = Ext.getCmp('DayRptManageIndexSubSheetName_analyse').getValue().trim();
							var reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
							if(sheetName == ''){
								Ext.Msg.show({
									title : '<fmt:message key="message.title"/>',
									msg : '请先选择功能菜单列表的某项功能!',
									fn : function() {
										Ext.getCmp("DayRptManageIndexTreePanel_analyse").focus();
									},
									buttons : Ext.Msg.OK,
									icon : Ext.MessageBox.INFO
								});
							}else{
								switch (sheetName) {
									case '最近7天分小时交易情况': 
										var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateClick,'Ymd')).add(Date.DAY, -7),'Ymd');
										Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
										break;
									case '实时分小时累计交易情况':
										Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateClick,'Ymd'));
										break;
									default:
										dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateClick,'Ymd')).add(Date.DAY, -31),'Ymd');
										Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
										break;
									}
									dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateClick, subSheetName);
									// 创建sotre为了重新配置store动态fields
									dayRptManageIndexCreateStore_analyse();
									// 重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugin
									dayRptManageIndexReconfigureGird_analyse(sheetName);
									// 配置Store参数
									//Ext.apply(dayRptManageIndexGrid_analyse.getStore().baseParams, dayRptManageIndexForm_analyse.getForm().getValues());
									var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
									dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
									dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
									dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
									dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
									dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateClick;
									dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
									// 加载
									//dayRptManageIndexGridStore_analyse.reload();
									dayRptManageIndexGrid_analyse.getStore().load({callback : function(o,option,success) {
							            if (success == false){
						    				Ext.Msg.show({
						    					title : '<fmt:message key="message.title" />',
						    					msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:<br>' + 
						    					"查询失败，请查看控制台日志文件或者联系系统管理员！",
						    					minWidth : 300,
						    					width : 450,
						    					buttons : Ext.MessageBox.OK,
						    					icon : Ext.MessageBox.ERROR
						    				});
						                }
									}});
						    }
					    }
					}
				}
			}
		});
		dayRptManageIndexTreeLoader_analyse.on('beforeload',function(loader,node){
			//使用树形菜单系统代码文本框时用
			//loader.baseParams.aplCode = Ext.getCmp("DayRptManageIndexTreeAplCode_analyse").getValue();
			//使用查询条件系统代码文本框时用
			loader.baseParams.aplCode = Ext.getCmp("DayRptManageIndexAplCode_analyse").getValue();
		},this);
		// 给树形菜单的系统代码输入文本框增加键盘升起事件（处理输入字符自动变大写）
		//Ext.getCmp("DayRptManageIndexTreeAplCode_analyse").on('keyup', this.doTreeKeyUp, this, {
		//	stopEvent : true
		//});
		
		
		var tabpanel = new Ext.TabPanel({
			region:'center',
	         plain:true,
	         forceLayout : true,
	         autoScroll:true,
	         enableTabScroll:true,
	         activeTab: 0,
	         //height:440,
	         deferredRender: false,
	         defaults:{bodyStyle:'padding:10px'},
	         items:[dayRptManageIndexGrid_analyse,centerPanel_analyse]
	         });
		var northpanel = new Ext.Panel({
			region:'north',
			layout : 'border',
	         plain:true,
	         height : 200,
	         forceLayout : true,
	         autoScroll:true,
	         enableTabScroll:true,
	         deferredRender: false,
	         defaults:{bodyStyle:'padding:10px'},
	         items:[dayRptManageIndexForm_analyse,dayRptAnalyseForm_analyse,dayRptManageIndexTreePanel_analyse]
	         });
		
		
		
		
		
		// 设置基类属性
		DayRptManageIndex_analyse.superclass.constructor.call(this, {
			layout : 'fit',
			border : false,
			items : [new Ext.Panel({
				layout : 'border',
				 autoScroll:true,
				  items:[tabpanel,northpanel]})
			         ]
		
		});
	},
	// 查询事件
	doFind : function() {
		var sheetName = Ext.getCmp('DayRptManageIndexSheetName_analyse').getValue().trim();
		var subSheetName = Ext.getCmp('DayRptManageIndexSubSheetName_analyse').getValue().trim();
		var reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
		var transDateFind = decodeURIComponent('${param.transDate}');
		if(sheetName == ''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '请先选择功能菜单列表的某项功能!',
				fn : function() {
					Ext.getCmp("DayRptManageIndexTreePanel_analyse").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		}else{
			switch (sheetName) {
				case '最近7天分小时交易情况': 
					var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateFind,'Ymd')).add(Date.DAY, -7),'Ymd');
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
					break;
				case '实时分小时累计交易情况':
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateFind,'Ymd'));
					break;
				default:
					 dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateFind,'Ymd')).add(Date.DAY, -31),'Ymd');
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
					break;
			}
			dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateFind, subSheetName);
			// 创建sotre为了重新配置store动态fields
			dayRptManageIndexCreateStore_analyse();
			// 重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugin
			dayRptManageIndexReconfigureGird_analyse(sheetName);
			// 配置Store参数
			var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
			dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
			dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
			dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
			dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
			dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateFind;
			dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
			// 加载
			dayRptManageIndexGrid_analyse.getStore().load({callback : function(o,option,success) {
	            if (success == false){
    				Ext.Msg.show( {
    					title : '<fmt:message key="message.title" />',
    					msg : '<fmt:message key="message.operation.failed" /><fmt:message key="error.code" />:<br>' + 
    					"查询失败，请查看控制台日志文件或者联系系统管理员！",
    					minWidth : 300,
    					width : 450,
    					buttons : Ext.MessageBox.OK,
    					icon : Ext.MessageBox.ERROR
    				});
	            }
			}});
		}
	},
	// 重置查询表单
	doReset : function() {
		dayRptManageIndexForm_analyse.getForm().reset();
	},
/* 	doExportAll : function(){
		var aplCode = Ext.getCmp('DayRptManageIndexAplCode_analyse').getValue().trim();
		var reportType = Ext.getCmp('DayRptManageIndexReportType_analyse').getValue().trim();
		var endTime = Ext.util.Format.date(Ext.getCmp('DayRptManageIndexEndTime_analyse').getValue(),'Ymd');
		Ext.Ajax.request({
			method : 'POST',
			url : '${ctx}/${managePath}/dayrptmanage/getAllReport',
			disableCaching : true, //禁止缓存
			params: { aplCode: aplCode,
						reportType : reportType,
						endDate : endTime},
			async : false, //同步请求
			success : function(response){
				var responseData = response.responseText;
				var svbCount = 0;
				Ext.iterate(Ext.util.JSON.decode(responseData).chartsMap, function(sheetNameKey, charts){
					Ext.iterate(charts, function(chartKey, chartContent){
		                setTimeout(function(){
		                	//返回的图表数据

							var tmp = eval("(" + chartContent + ")");
							// 编辑chart图表配置项

							var chartType;
							var xAxisData = [];
							var plotOptionsData;
							var toolTipData;
							// 趋势图的X轴坐标科目

							var xCategoriesOptions = tmp.xCategoriesOptions.split(",");
							if(sheetNameKey.indexOf("系统资源使用率图表") != -1){
								chartType = 'spline';
								xAxisData.push({
					            	type: 'datetime',
					            	labels:{
					            		formatter:function(){
					            			return Highcharts.dateFormat('%H:%M', this.value);
					            		}
					            	}
					            });
								plotOptionsData = {
					                spline: {
					                    lineWidth: 2,
					                    states: {
					                        hover: {
					                            lineWidth: 4
					                        }
					                    },
					                    marker: {
					                        enabled: false,
					                        states: {
					                            hover: {
					                                enabled: true,
					                                symbol: 'circle',
					                                radius: 5,
					                                lineWidth: 1
					                            }
					                        }
					                    },
					                    pointInterval: 300000, // 5分钟
					                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 07, 06, 00)
					                }
					            };
								toolTipData = {
										crosshairs: true,
					 	                formatter: function() {
					 	                	var unit;
					 	                	if(tmp.toolTipUnit){
						 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
					 	                	}	
					 	                	return ''+
					 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
					 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
					 	                }
					 	         };
							}else if(sheetNameKey.indexOf("当日网络资源使用情况") != -1 ){
								chartType = 'spline';
								xAxisData.push({
					            	type: 'datetime',
					            	labels:{
					            		formatter:function(){
					            			return Highcharts.dateFormat('%H:%M', this.value);
					            		}
					            	}
					            });
								plotOptionsData = {
					                spline: {
					                    lineWidth: 2,
					                    states: {
					                        hover: {
					                            lineWidth: 4
					                        }
					                    },
					                    marker: {
					                        enabled: false,
					                        states: {
					                            hover: {
					                                enabled: true,
					                                symbol: 'circle',
					                                radius: 5,
					                                lineWidth: 1
					                            }
					                        }
					                    },
					                    pointInterval: 300000, // 5分钟
					                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 00, 01, 00)
					                }
					            };
								toolTipData = {
										crosshairs: true,
					 	                formatter: function() {
					 	                	var unit;
					 	                	if(tmp.toolTipUnit){
						 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
					 	                	}	
					 	                	return ''+
					 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
					 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
					 	                }
					 	         };
							}else if(sheetNameKey.indexOf("当日weblogic使用情况") != -1 ){
								chartType = 'spline';
								xAxisData.push({
					            	type: 'datetime',
					            	labels:{
					            		formatter:function(){
					            			return Highcharts.dateFormat('%H:%M', this.value);
					            		}
					            	}
					            });
								plotOptionsData = {
					                spline: {
					                    lineWidth: 2,
					                    states: {
					                        hover: {
					                            lineWidth: 4
					                        }
					                    },
					                    marker: {
					                        enabled: false,
					                        states: {
					                            hover: {
					                                enabled: true,
					                                symbol: 'circle',
					                                radius: 5,
					                                lineWidth: 1
					                            }
					                        }
					                    },
					                    pointInterval: 300000, // 5分钟
					                    pointStart: Date.UTC(Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getFullYear(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getMonth(), Ext.getCmp("DayRptManageIndexEndTime_analyse").getValue().getDate(), 00, 01, 00)
					                }
					            };
								toolTipData = {
										crosshairs: true,
					 	                formatter: function() {
					 	                	var unit;
					 	                	if(tmp.toolTipUnit){
						 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
					 	                	}	
					 	                	return ''+
					 	                		Highcharts.dateFormat('%Y-%m-%d %H:%M:00', this.x) + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
					 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
					 	                }
					 	         };
							}else{
								chartType = 'line';
								xAxisData.push({
					                categories: xCategoriesOptions,
					                alternateGridColor: '#DCDCDC', //间隔显示不同颜色.
					                gridLineWidth :0, //图表网格线0代表无，数字越大线越粗.
					                labels: {  //X轴的标签（下面的说明）.
					                    align: "right",              //位置.
					                    enabled: true,               	//是否显示.
					                    rotation: -60
					                }
					            });
								plotOptionsData = {
					                spline: {
					                    lineWidth: 2,
					                    states: {
					                        hover: {
					                            lineWidth: 3
					                        }
					                    },
					                    marker: {
					                        enabled: false,
					                        states: {
					                            hover: {
					                                enabled: true,
					                                symbol: 'circle',
					                                radius: 5,
					                                lineWidth: 1
					                            }
					                        }
					                    }
					                }
					            };
								toolTipData = {
										crosshairs: true,
					 	                formatter: function() {
					 	                	var unit;
					 	                	if(tmp.toolTipUnit){
						 	                	unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
					 	                	}	
					 	                	return ''+
					 	                        this.x + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
					 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
					 	                }
					 	         };
							}
							// 标题
							var titleOption = tmp.titleOption;
							// 对应的科目名及科目值
							var seriesOptions = [];
							for (var k = 0; k < tmp.seriesOptions.length; k++) {
								seriesOptions[k] = {
									name:tmp.seriesOptions[k].name,
									data:tmp.seriesOptions[k].data,
									yAxis:tmp.seriesOptions[k].yAxis
								};
							}
							var yAxisData = [];
							//左
							Ext.each(tmp.yAxisOptions.yAxis, function(item){
								yAxisData.push({
					 				title: {
					                    text: item.yAxisTitle=="null"?'':item.yAxisTitle
					                },
					 			    labels: {
					 			        formatter: function() {
					 			        	var labelVal;
					 			       		switch (item.yAxisUnit) {
					 						case '百':
					 							labelVal =  this.value/100 + item.yAxisUnit;
					 							break;
					 						case '千':
					 							labelVal = this.value/1000 + item.yAxisUnit;
					 							break;
					 						case '万':
					 							labelVal =  this.value/10000 + item.yAxisUnit;
					 							break;
					 						case '十万':
					 							labelVal = this.value/100000 + item.yAxisUnit;
					 							break;
					 						case '百万':
					 							labelVal = this.value/1000000 + item.yAxisUnit;
					 							break;
					 						default :
					 							labelVal = this.value + (item.yAxisUnit=="null"?'':item.yAxisUnit);
					 							break;
					 			        	}
					 			            return labelVal;
					 			        },
					 			        style: {
					 			            color: '#4572A7'
					 			        }
					 			    },
					                plotLines: [{
					                    value: 0,
					                    width: 1,
					                    color: '#000000'
					                }],
					                min :item.yAxisMinval,
					                max :item.yAxisMaxval,
					                tickInterval :item.yAxisInterval,
					                opposite: item.yAxisPosition == 1 ? true : false
					 			});
							});
							// 创建chart图表对象
					        chartKey = new Highcharts.Chart({
					            chart: {
					            	renderTo: 'datRptContainerHidden',
					                type: chartType
					            },
					            title: {//标题
					                text: titleOption ,
					                style:{                //样式
					                    cursor: 'pointer',
					                    color: 'red',
					                    fontSize: '20px'
					                }
					            },
					            credits: { ////设置右下角的标记Highcharts.com字样
					            	enabled :false
					            },
					            xAxis: xAxisData,
					            yAxis: yAxisData,
					            tooltip: toolTipData,
					            plotOptions : plotOptionsData,
					            legend: {
					                layout: 'vertical',
					                align: 'right',
					                verticalAlign: 'top',
					                y: 100,
					                borderWidth: 1,            //边框宽度
					                backgroundColor: '#FFFFFF',//背景颜色
					                borderRadius:5,        //边框圆角,此属性会导致servlet下载图片异常
					                itemHoverStyle: {color: 'red',fontSize: '13px'}  //鼠标放到某一图例说明上，文字颜色的变化颜色
					            },
					            series: seriesOptions
					        });
					        // 获取图片SVG信息
							var svg = chartKey.getSVG();
							// 生成页面Highcharts图表图片数据到字节流，用于图片写入EXCEL
							Ext.Ajax.request({
								method : 'POST',
								url : '${ctx}/${managePath}/dayrptmanage/exportChartPic',
								params: {
											sheetName : sheetNameKey,
											subSheetName : "",
											type : 'image/jpeg', 	// 目前仅支持 'image/jpeg'
											svg : svg,
											count : svbCount
											},
								disableCaching : true,		// 禁止缓存
								async : false,		// 同步请求
								success : function(response,option){		// 请求成功
									var obj = Ext.decode(response.responseText);
								},
								failure : function(response){		// 请求失败
									Ext.Msg.show({
										title : '<fmt:message key="message.title"/>',
										msg : '导出失败，请重试或联系系统管理员!',
										fn : function() {
											Ext.getCmp("DayRptManageIndexExportAllExcel_analyse").focus();
										},
										buttons : Ext.Msg.OK,
										icon : Ext.MessageBox.INFO
									});
								},
								// 回调函数
								callback : function(options,success,response){
								}
							});
							svbCount++;
		                }, 10);
					})
				});
				var picCount = 0;
				Ext.iterate(Ext.util.JSON.decode(responseData).chartsMap, function(sheetNameKey, charts){
					Ext.iterate(charts, function(chartKey, chartContent){
						picCount++;
					});
				});
                setTimeout(function(){
					//导出excel
					window.location = '${ctx}/${managePath}/dayrptmanage/excelAll.xls?' + encodeURI(dayRptManageIndexForm_analyse.getForm().getValues(true));
                }, picCount*3000);
			},
			failure : function(response){		// 请求失败
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '导出失败，请重试或联系系统管理员!',
					fn : function() {
						Ext.getCmp("DayRptManageIndexExportAllExcel_analyse").focus();
					},
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.INFO
				});
			},
			// 回调函数
			callback : function(options,success,response){
			}
		});
	}, */
	// 导出查询数据xls事件
	doExportXLS : function() {
		if(dayRptManageIndexChartsArr == ''){
			//只有数据没有图表的导出,设置标识为true用于清除上次查询保存在session中的图片字节流数据
			Ext.getCmp("ClearByteArrayOutputStreamFlag_analyse").setValue('true');
		}else{
			// 导出数据和图表
			Ext.getCmp("ClearByteArrayOutputStreamFlag_analyse").setValue('false');
			var count = 0;
			var sheetName = Ext.getCmp("DayRptManageIndexSheetName_analyse").getValue().trim();
			var subSheetName = Ext.getCmp("DayRptManageIndexSubSheetName_analyse").getValue().trim();
			Ext.each(dayRptManageIndexChartsArr, function(rptChart){
				if(rptChart == undefined){
					Ext.Msg.show({
						title : '<fmt:message key="message.title"/>',
						msg : '请先选择日报功能菜单进行查询后再执行导出操作!',
						fn : function() {
							Ext.getCmp("DayRptManageIndexAplCode_analyse").focus();
						},
						buttons : Ext.Msg.OK,
						icon : Ext.MessageBox.INFO
					});
				}else{
					// 获取图片SVG信息
					var svg = rptChart.getSVG();
					// 生成页面Highcharts图表图片数据到字节流，用于图片写入EXCEL
					Ext.Ajax.request({
						method : 'POST',
						url : '${ctx}/${managePath}/dayrptmanage/exportChartPic',
						params: {
									sheetName : sheetName,
									subSheetName : subSheetName,
									type : 'image/jpeg', 	// 目前仅支持 'image/jpeg'
									svg : svg,
									count : count
									},
						disableCaching : true,		// 禁止缓存
						async : false,		// 同步请求
						success : function(response,option){		// 请求成功
							var obj = Ext.decode(response.responseText);
						},
						failure : function(response){		// 请求失败
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : '导出失败，请重试!',
								fn : function() {
									Ext.getCmp("DayRptManageIndexGridExportButton_analyse").focus();
								},
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.INFO
							});
						},
						// 回调函数
						callback : function(options,success,response){
						}
					});
				}
				count++;
			});
		}
		//导出excel
		window.location = '${ctx}/${managePath}/dayrptmanage/excel.xls?' + encodeURI(dayRptManageIndexForm_analyse.getForm().getValues(true));
	},
	
	//下一项
	showNextItem : function() {
		
		if(Ext.getCmp('DayRpt_handleState_analyse').getValue()==2&&Ext.getCmp('DayRpt_analyseResult_analyse').getValue().trim()==''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '处理异常,分析结果不可为空!',
				fn : function() {
					
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			return ;
		};
		if(Ext.getCmp('DayRpt_runState_analyse').getValue()==2&&Ext.getCmp('DayRpt_analyseResult_analyse').getValue().trim()==''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '运行异常,分析结果不可为空!',
				fn : function() {
					
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			
		}else{

			var tree = Ext.getCmp('DayRptManageIndexTreePanel_analyse');
			var checkedNode = tree.getSelectionModel().getSelectedNode();
			
			var node ; //下一个叶子节点

			var curNum = -1 ; //当前节点的索引

			var transDateNext = decodeURIComponent('${param.transDate}'); //交易日期
			var anaItem = '' ; //分析科目
			var status = '1' ; //运行状态

			var exeAnaDesc = '' ; //分析描述
			
			if(checkedNode==null){
				checkedNode = tree.getRootNode().item(0);
			}
			if((checkedNode.isLeaf()==false && checkedNode.parentNode==tree.getRootNode())){
			}else{
				//保存当前分析结果数据
				if(checkedNode.parentNode != tree.getRootNode()){
					anaItem = checkedNode.parentNode.text+'_'+checkedNode.text;
				}else{
					anaItem = checkedNode.text;
				}
				status = Ext.getCmp('DayRpt_runState_analyse').getValue();
				exeAnaDesc = Ext.getCmp('DayRpt_analyseResult_analyse').getValue();
				handleState=Ext.getCmp('DayRpt_handleState_analyse').getValue();
				Ext.Ajax.request({
					url : '${ctx}/${appPath}/checkreport/saveAnalyseData',
					scope : this,
					params : {
						aplCode : aplCode,
						transDate : transDateNext,
						transTime : transTime,
						anaItem : anaItem,
						status : status,
						exeAnaDesc : exeAnaDesc,
						handleState : handleState
					}
				});
			}
			
			//清除以前的分析数据

			if(!(checkedNode.isLast()==true&&checkedNode.isLeaf()==true)){
				Ext.getCmp('DayRpt_handleState_analyse').setValue('1');
				Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
				Ext.getCmp('DayRpt_analyseResult_analyse').setValue('');
			}else if(!(checkedNode.isLast()==true && checkedNode.parentNode!=tree.getRootNode())){
				Ext.getCmp('DayRpt_handleState_analyse').setValue('1');
				Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
				Ext.getCmp('DayRpt_analyseResult_analyse').setValue('');
			}
				
			
			curNum = checkedNode.parentNode.indexOf(checkedNode);
			//该节点是最后一个子节点，并且其父节点也是最后一个子节点
			if(checkedNode.isLeaf()==false && checkedNode.parentNode==tree.getRootNode()){
				node = checkedNode.item(0);
			}else if(checkedNode.isLast()==true && checkedNode.parentNode.isLast()==true && checkedNode.parentNode!=tree.getRootNode()){ 
				node= checkedNode;
				//node = checkedNode.parentNode.parentNode.item(0);
			}else if(checkedNode.isLast()==true && checkedNode.parentNode==tree.getRootNode()){ 
				node= checkedNode;
				// node = checkedNode.parentNode.item(0);
			}else{
				node = checkedNode.parentNode.item(curNum+1);
			}
			if(node.isLeaf()==false && node.getDepth()==1){
				if(checkedNode.isLeaf()==true){
					node = node.item(0);
				}else{
					node = node.parentNode.item(curNum+1);
				}
			}
			if(node.getDepth()==2 ){ //系统资源使用率图表

				//清除所有选中的复选框
				var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
				Ext.each(selNodes, function(_node){
					_node.attributes.checked = false;
					_node.ui.checkbox.checked = false;
				}); 
				//勾选所有子节点
				if (node.parentNode != null) {
					 state = true;
					 node.cascade(function(childNode){
						 if(childNode.getDepth()>2){
							 childNode.attributes.checked=state;
							 childNode.ui.checkbox.checked=state;
			                 return true;
						 }
		             });
			    }
				selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
				subSheetNames = [];
				sheetName = '';
				Ext.each(selNodes, function(_node){
					if(_node.leaf == true){
	                   subSheetNames.push(_node.attributes.subSheetName);
	                   sheetName = _node.attributes.sheetName;
					}
				});
	            Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetNames);
	            Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
			}
			//选中该节点

			node.select();
			//展开图表
			//Ext.getCmp("DayRptManageIndexCenterPanel_analyse").expand();
			if(node.parentNode != tree.getRootNode()){
				anaItem = node.parentNode.text+'_'+node.text;
			}else{
				anaItem = node.text;
			}
			Ext.getCmp("DayRpt_analyseItem_analyse").setValue(anaItem);
			//加载分析结果数据
			Ext.Ajax.request({
				url : '${ctx}/${appPath}/checkreport/showAnalyseData',
				scope : this,
				params : {
					aplCode : aplCode,
					transDate : transDateNext,
					transTime : transTime,
					anaItem : anaItem
				},
				success : function(resp,opts){
					var respText = Ext.util.JSON.decode(resp.responseText);
					var handleState='1';
					var status = '1' ;
					var exeAnaDesc = '' ;
					if(respText.status){
						status = respText.status;
					}
					if(respText.exeAnaDesc){
						exeAnaDesc = respText.exeAnaDesc;
					}
					if(respText.handleState){
						handleState = respText.handleState;
					}
					if(handleState!=''){
						Ext.getCmp('DayRpt_handleState_analyse').setValue(handleState);
						
						if( handleState=='1'){
							Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
							Ext.getCmp('DayRpt_handleState_analyse_2').setValue(false);
					}else{
						Ext.getCmp('DayRpt_handleState_analyse_1').setValue(false);
						Ext.getCmp('DayRpt_handleState_analyse_2').setValue(true);
				    	}
					}
					if(status!=''){
						Ext.getCmp('DayRpt_runState_analyse').setValue(status);
					}
					if(exeAnaDesc!=''){
						Ext.getCmp('DayRpt_analyseResult_analyse').setValue(exeAnaDesc);
					}
				}
			});
			
			var sheetName;
			var subSheetName;
			var reportType;
			//Ext.getCmp("DayRptManageIndexTreePanel_analyse").collapse();//自动隐藏树形菜单
			//禁用bbar
			dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
			reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
			if(node.text.indexOf("(") != -1){
				if(node.attributes.sysRes == true){
					//系统资源子节点

					sheetName = node.attributes.sheetName;
					subSheetName = node.attributes.subSheetName;
				}else{
					sheetName = node.text;
					subSheetName = node.text.split("(")[1].split(")")[0];
				}
				//设置点击的功能菜单名到查询表单中的隐藏项目

				Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
				Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
			}else{
				if(node.attributes.sysRes == true){
					//系统资源子节点

					sheetName = node.attributes.sheetName;
					subSheetName = Ext.getCmp("DayRptManageIndexSubSheetName_analyse").getValue().trim();
				}else{
					sheetName = node.text;
					subSheetName = '';
				}
				//设置点击的功能菜单名到查询表单中的隐藏项目

				Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
				Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
			}
			//点击非根节点
			if(sheetName != '日报功能列表' && node.leaf == true){
				switch (sheetName) {
					case '最近7天分小时交易情况': 
						var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateNext,'Ymd')).add(Date.DAY, -7),'Ymd');
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
						break;
					case '实时分小时累计交易情况':
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateNext,'Ymd'));
						break;
					default:
						dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateNext,'Ymd')).add(Date.DAY, -31),'Ymd');
						Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
						break;
				}
				if(sheetName != '运行情况总结'){
					//获取动态列名及数据源字段列表

					dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateNext,subSheetName);
					//创建sotre为了重新配置store动态fields
					dayRptManageIndexCreateStore_analyse();
					//重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugins
					dayRptManageIndexReconfigureGird_analyse(sheetName);
					//配置Store参数
					//Ext.apply(dayRptManageIndexGridStore_analyse.baseParams, dayRptManageIndexForm_analyse.getForm().getValues());
					var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
					dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
					dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
					dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
					dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
					dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateNext;
					dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
					//加载
					dayRptManageIndexGridStore_analyse.reload();
				}else{
					reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
					var params = {
							aplCode : aplCode,
							reportType : reportType,
							endDate : transDateNext
						};
					//app.loadWindow('${ctx}/${managePath}/aplanalyze/forrpt', params); //弹出页面方式
					//如果标签页存在,重载页面
					var tab = Ext.getCmp("APL_ANALYZE");
					if(tab){
						tab.setTitle("应用系统运行分析");
					}
					app.loadTab('APL_ANALYZE', "应用系统运行分析", '${ctx}/${managePath}/aplanalyze/forrpt', params);
				} 
			}
			if(node.getDepth()==2){
				dayRptManageIndex_analyse.doFind();
			}
		}
	},
	//上一项
	showBeforeItem : function() {
		if(Ext.getCmp('DayRpt_handleState_analyse').getValue()==2&&Ext.getCmp('DayRpt_analyseResult_analyse').getValue().trim()==''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '处理异常,分析结果不可为空!',
				fn : function() {
					
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			return ;
		};

		if(Ext.getCmp('DayRpt_runState_analyse').getValue()==2&&Ext.getCmp('DayRpt_analyseResult_analyse').getValue().trim()==''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '运行异常,分析结果不可为空!',
				fn : function() {
					
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			
		}else{
		var tree = Ext.getCmp('DayRptManageIndexTreePanel_analyse');
		var checkedNode = tree.getSelectionModel().getSelectedNode();
		
		var node = null ; //上一个叶子节点
		var curNum = -1 ; //当前节点的索引
		var transDateBefore = decodeURIComponent('${param.transDate}'); //交易日期
		var anaItem = '' ; //分析科目
		var status = '1' ; //运行状态
		var exeAnaDesc = '' ; //分析描述
		
		if(checkedNode==null){
			checkedNode = tree.getRootNode().item(0) ;
		}
		if(checkedNode.isLeaf()==false && checkedNode.parentNode==tree.getRootNode()){
		}else{
			//保存当前分析结果数据
			aplCode = Ext.getCmp('DayRptManageIndexAplCode_analyse').getValue();
			if(checkedNode.parentNode != tree.getRootNode()){
				anaItem = checkedNode.parentNode.text+'_'+checkedNode.text;
			}else{
				anaItem = checkedNode.text;
			}
			status = Ext.getCmp('DayRpt_runState_analyse').getValue();
			exeAnaDesc = Ext.getCmp('DayRpt_analyseResult_analyse').getValue();
			handleState=Ext.getCmp('DayRpt_handleState_analyse').getValue();
			Ext.Ajax.request({
				url : '${ctx}/${appPath}/checkreport/saveAnalyseData',
				scope : this,
				params : {
					aplCode : aplCode,
					transDate : transDateBefore,
					transTime : transTime,
					anaItem : anaItem,
					status : status,
					exeAnaDesc : exeAnaDesc,
					handleState : handleState
				}
			});
		}
		//清除以前的分析数据       if(!(checkedNode.isFirst()==true&&checkedNode.parentNode==tree.getRootNode())){
    	   Ext.getCmp('DayRpt_handleState_analyse').setValue('1');
    	   Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
   		Ext.getCmp('DayRpt_analyseResult_analyse').setValue('');
       }
		
		//清除所有选中的复选框
		var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
		Ext.each(selNodes, function(_node){
			_node.attributes.checked = false;
			_node.ui.checkbox.checked = false;
		}); 
		
		curNum = checkedNode.parentNode.indexOf(checkedNode);
		if(checkedNode.isFirst()==true){  //该节点是第一个子节点
			if(checkedNode.parentNode==tree.getRootNode()){ //选中节点是目录树的第一个节点
				return false;
				/* (checkedNode.parentNode).eachChild(function(childNode) {
					if (childNode.isLast()==true) {
						node = childNode ;
						return false;
					}
				}); */
			}else if(checkedNode.parentNode.isLeaf()==false){ //父节点不是叶子节点				var parNode = checkedNode.parentNode;
			    var parNum = parNode.parentNode.indexOf(parNode);
				node = parNode.parentNode.item(parNum-1);
			}
		}else{
			node = checkedNode.parentNode.item(curNum-1);
		}
		if(node.isLeaf()==false || node.getDepth()==2){ //该节点不是叶子节点
			if(checkedNode == null ){
				node.eachChild(function(childNode) {
					if (childNode.isLast()==true) {
						node = childNode ;
						return false;
					}
				});
			}else{
				if(checkedNode.isLeaf()==true){
					node.eachChild(function(childNode) {
						if (childNode.isLast()==true) {
							node = childNode ;
							return false;
						}
					});
				}else{
					node = checkedNode.parentNode.item(curNum-1);
				}
			}
		
			//清除所有选中的复选框
			var selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
			Ext.each(selNodes, function(_node){
				_node.attributes.checked = false;
				_node.ui.checkbox.checked = false;
			}); 
			//勾选所有子节点
			 node.cascade(function(childNode){
				 if(childNode.getDepth()>2){
					 childNode.attributes.checked=true;
					 childNode.ui.checkbox.checked=true;
	                 return true;
				 }
             });
			
			selNodes = dayRptManageIndexTreePanel_analyse.getChecked();
			subSheetNames = [];
			sheetName = '';
			Ext.each(selNodes, function(_node){
				if(_node.leaf == true){
                   subSheetNames.push(_node.attributes.subSheetName);
                   sheetName = _node.attributes.sheetName;
				}
			});
            Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetNames);
            Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
		}
		//选中该节点
		node.select();
		//展开图表
		//Ext.getCmp("DayRptManageIndexCenterPanel_analyse").expand();
		if(node.parentNode != tree.getRootNode()){
			anaItem = node.parentNode.text+'_'+node.text;
		}else{
			anaItem = node.text;
		}
		Ext.getCmp("DayRpt_analyseItem_analyse").setValue(anaItem);
		//加载分析结果数据
		Ext.Ajax.request({
			url : '${ctx}/${appPath}/checkreport/showAnalyseData',
			scope : this,
			params : {
				aplCode : aplCode,
				transDate : transDateBefore,
				transTime : transTime,
				anaItem : anaItem
			},
			success : function(resp,opts){
				var respText = Ext.util.JSON.decode(resp.responseText);
				
				var status = '1' ;
				var exeAnaDesc = '' ;
				if(respText.status){
					status = respText.status;
				}
				if(respText.exeAnaDesc){
					exeAnaDesc = respText.exeAnaDesc;
				}
				var handleState='1';
				if(respText.handleState){
					handleState = respText.handleState;
				}
				
				if(handleState!=''){
					Ext.getCmp('DayRpt_handleState_analyse').setValue(handleState);
					if( handleState=='1'){
						Ext.getCmp('DayRpt_handleState_analyse_1').setValue(true);
						Ext.getCmp('DayRpt_handleState_analyse_2').setValue(false);
				}else{
					Ext.getCmp('DayRpt_handleState_analyse_1').setValue(false);
					Ext.getCmp('DayRpt_handleState_analyse_2').setValue(true);
				}
				}
				if(status!=''){
					Ext.getCmp('DayRpt_runState_analyse').setValue(status);
				}
				if(exeAnaDesc!=''){
					Ext.getCmp('DayRpt_analyseResult_analyse').setValue(exeAnaDesc);
				}
			}
		});
		
		var sheetName;
		var subSheetName;
		var reportType;
		//Ext.getCmp("DayRptManageIndexTreePanel_analyse").collapse();//自动隐藏树形菜单
		//禁用bbar
		dayRptManageIndexGrid_analyse.getBottomToolbar().setDisabled(true);
		reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
		if(node.text.indexOf("(") != -1){
			if(node.attributes.sysRes == true){
				//系统资源子节点
				sheetName = node.attributes.sheetName;
				subSheetName = node.attributes.subSheetName;
			}else{
				sheetName = node.text;
				subSheetName = node.text.split("(")[1].split(")")[0];
			}
			//设置点击的功能菜单名到查询表单中的隐藏项目
			Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
			Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
		}else{
			if(node.attributes.sysRes == true){
				//系统资源子节点
				sheetName = node.attributes.sheetName;
				subSheetName = Ext.getCmp("DayRptManageIndexSubSheetName_analyse").getValue().trim();
			}else{
				sheetName = node.text;
				subSheetName = '';
			}
			//设置点击的功能菜单名到查询表单中的隐藏项目
			Ext.getCmp("DayRptManageIndexSheetName_analyse").setValue(sheetName);
			Ext.getCmp("DayRptManageIndexSubSheetName_analyse").setValue(subSheetName);
		}
		//点击非根节点
		if(sheetName != '日报功能列表' && node.leaf == true){
			switch (sheetName) {
				case '最近7天分小时交易情况': 
					var dayRptManageIndex7AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateBefore,'Ymd')).add(Date.DAY, -7),'Ymd');
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex7AgoDate);
					break;
				case '实时分小时累计交易情况':
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(Date.parseDate(transDateBefore,'Ymd'));
					break;
				default:
					dayRptManageIndex31AgoDate = Ext.util.Format.date(new Date(Date.parseDate(transDateBefore,'Ymd')).add(Date.DAY, -31),'Ymd');
					Ext.getCmp("DayRptManageIndexStartTime_analyse").setValue(dayRptManageIndex31AgoDate);
					break;
			}
			if(sheetName != '运行情况总结'){
				//获取动态列名及数据源字段列表
				dayRptManageIndexCreateGridColAndDsfields_analyse(aplCode, reportType, sheetName, transDateBefore,subSheetName);
				//创建sotre为了重新配置store动态fields
				dayRptManageIndexCreateStore_analyse();
				//重新配置dayRptManageIndexGrid的store、columns、bbar、groupplugins
				dayRptManageIndexReconfigureGird_analyse(sheetName);
				//配置Store参数
				//Ext.apply(dayRptManageIndexGridStore_analyse.baseParams, dayRptManageIndexForm_analyse.getForm().getValues());
				var startDate = Ext.util.Format.date(Ext.getCmp("DayRptManageIndexStartTime_analyse").getValue(),'Ymd');
				dayRptManageIndexGridStore_analyse.baseParams.aplCode=aplCode;
				dayRptManageIndexGridStore_analyse.baseParams.reportType=reportType;
				dayRptManageIndexGridStore_analyse.baseParams.sheetName=sheetName;
				dayRptManageIndexGridStore_analyse.baseParams.startDate=startDate;
				dayRptManageIndexGridStore_analyse.baseParams.endDate=transDateBefore;
				dayRptManageIndexGridStore_analyse.baseParams.subSheetName=subSheetName;
				//加载
				dayRptManageIndexGridStore_analyse.reload();
			}else{
				reportType = Ext.getCmp("DayRptManageIndexReportType_analyse").getValue().trim();
				var params = {
						aplCode : aplCode,
						reportType : reportType,
						endDate : transDateBefore
					};
				//app.loadWindow('${ctx}/${managePath}/aplanalyze/forrpt', params); //弹出页面方式
				//如果标签页存在,重载页面
				var tab = Ext.getCmp("APL_ANALYZE");
				if(tab){
					tab.setTitle("应用系统运行分析");
				}
				app.loadTab('APL_ANALYZE', "应用系统运行分析", '${ctx}/${managePath}/aplanalyze/forrpt', params);
			} 
		}
		if(node.getDepth()==2){
			dayRptManageIndex_analyse.doFind();
		}
		}
	}
});
var dayRptManageIndex_analyse = new DayRptManageIndex_analyse();
</script>
<script type="text/javascript">
Ext.getCmp("CHECK_REPORT_ANALYSE").add(dayRptManageIndex_analyse);
Ext.getCmp("CHECK_REPORT_ANALYSE").doLayout();
</script>
<div id="datRptContainer_analyse">
</div>
<div id="datRptContainerHidden" style="display:none;height:360px;width:800px;">
</div>

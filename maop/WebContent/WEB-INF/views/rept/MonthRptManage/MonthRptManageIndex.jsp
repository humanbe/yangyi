<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
// 换页最大值var pageSize = 500;
var subSheetNames = [];
//保存创建的图表对象var monthRptManageIndexChartsArr = [];
//用于gridstore的fields
var monthRptManageIndexDsFields;
//用于grid的ColmunModel
var monthRptManageIndexGridCols;
var monthRptManageIndexCmItems;
//定义数据源var monthRptManageIndexGridStore;
//定义数据列表组件
var monthRptManageIndexGrid;
//定义树形数据源var monthRptManageIndexTreeLoader;
//定义treePanel
var monthRptManageIndexTreePanel;
//定义查询表单
var monthRptManageIndexForm;
//数据列表组件的分组header数组存储
var monthRptManageIndexColumnHeaderGroupList;
//数据列表组件的分组header组合数var monthRptManageIndexColumnHeaderGroupColspan;
//数据列表组件的初始分组表头var monthRptManageIndexColumnHeaderGroup = new Ext.ux.grid.ColumnHeaderGroup({
	rows: []
});

//获取系统代码列表数据
var aplCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});

//	动态创建图表的方法
function monthRptManageIndexCreateChart(aplCodeParm, reportTypeParm, sheetNameParm, monthParm, subSheetNameParm){
	//重新执行查新操作时，清空图表数据，防止导出上次查询的图表数据
	monthRptManageIndexChartsArr = [];
	//获取动态图表	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${managePath}/monthrptmanage/getCharts',
		disableCaching : true, //禁止缓存
		params: { 
			aplCode: aplCodeParm,
			reportType : reportTypeParm,
			sheetName : sheetNameParm,
			month : monthParm, 
			subSheetName : subSheetNameParm
		},
		async : false, //同步请求
		success : function(response){
			var responseData = response.responseText;
			//循环动态创建div
			var monthRptManageIndexRptDivCount = 0;
			Ext.iterate(Ext.util.JSON.decode(responseData).chartOptionJson, function(chartKey, chartContent){
				monthRptManageIndexRptDivCount++;
			});
			if(monthRptManageIndexRptDivCount != 0){
				dynamicCreateRptChartDiv(monthRptManageIndexRptDivCount,sheetNameParm);
			}
			//循环创建chart
			monthRptManageIndexRptDivCount = 0;//初始化
			
			Ext.iterate(Ext.util.JSON.decode(responseData).chartOptionJson, function(chartKey, chartContent){
				//返回的图表数据				var tmp = eval("(" + chartContent + ")");
				// 图表分支判断
				var xAxisData = [];
				var plotOptionsData;
				var toolTipData;
				// 趋势图的X轴坐标科目
				var xCategoriesOptions = tmp.xCategoriesOptions.split(",");
				xAxisData.push({
	                categories: xCategoriesOptions,
	                alternateGridColor: '#F2F2F2', //间隔显示不同颜色
	                gridLineWidth :0, //图表网格线0代表无，数字越大线越粗
	                labels: {  //X轴的标签（下面的说明）
	                    align: "right",              //位置
	                    enabled: true,               	//是否显示
	                   	rotation: -60               //旋转,效果就是影响标签的显示方向
	                }
	            });
				plotOptionsData = {
					spline: {
		                marker: {
		                	enable: false
		                }
		            },
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
	            };
				toolTipData = {
						crosshairs: true,
						pointFormat: '{series.name}: <b>{point.percentage}%</b>',
		            	percentageDecimals: 1,
	 	                formatter: function() {
	 	                	var unit;
		 	                if(tmp.toolTipUnit){
			 	                unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
		 	                }	
	 	                    if (this.point.name) { // the pie chart
	 	                    	return '' + '<b>'+ this.point.name + '</b>: ' +': '+ this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);
	 	                    }else{
		 	                	return ''+
		 	                        this.x + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
		 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
	 	                    }
	 	                }
	 	         };

				// 标题
				var titleOption = tmp.titleOption;
				// 对应的科目名及科目值
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
				var yAxisData = [];
				//左
				Ext.each(tmp.yAxisOptions.yAxis, function(item){
					yAxisData.push({
		 				title: {
		                    text: item.yAxisTitle
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
		                renderTo: 'monthRptContainer' + monthRptManageIndexRptDivCount
		            },
		            title: {//标题
		                text: titleOption
		            },
		            credits: { //设置右下角的标记Highcharts.com字样
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
				
				//保存创建的chart对象，用于导出功能		        monthRptManageIndexChartsArr.push(chartKey);
				//计数-对应div的id
				monthRptManageIndexRptDivCount++;
			});
		}
	});
}

//获取动态列名及数据源字段列表function monthRptManageIndexCreateGridColAndDsfields(aplCodeParm, reportTypeParm, sheetNameParm, subSheetNameParm){
	Ext.Ajax.request({
		method : 'POST',
		url : '${ctx}/${managePath}/monthrptmanage/getCols',
		params: {
			aplCode : aplCodeParm,
			reportType : reportTypeParm,
			sheetName : sheetNameParm,
			subSheetName  : subSheetNameParm},
		disableCaching : true,	//禁止缓存
		async : false, //同步请求
		success : function(response,option){
			var text = response.responseText;
			monthRptManageIndexCmItems = Ext.util.JSON.decode(Ext.util.JSON.decode(text).columnModel);
			monthRptManageIndexDsFields = Ext.util.JSON.decode(Ext.util.JSON.decode(text).fieldsNames);
			monthRptManageIndexGridCols = new Ext.grid.ColumnModel(monthRptManageIndexCmItems);
			monthRptManageIndexColumnHeaderGroupList = Ext.util.JSON.decode(text).columnHeaderGroupList;
			monthRptManageIndexColumnHeaderGroupColspan = Ext.util.JSON.decode(text).columnHeaderGroupColspan;
		},
		// 请求失败时
		failure : function(response){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '在读取动态数据时发生错误，请重新刷新后，再打开菜单再试!',
				fn : function() {
					Ext.getCmp("MonthRptManageIndexAplCode").focus();
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
function monthRptManageIndexCreateStore(){
	// 实例化数据列表数据源
	monthRptManageIndexGridStore = new Ext.data.JsonStore({
		proxy : new Ext.data.HttpProxy( {
			method : 'POST',
			url : '${ctx}/${managePath}/monthrptmanage/index',
			disableCaching : true
		}),
		autoDestroy : true,
		root : 'data',
		totalProperty : 'count',
		fields : monthRptManageIndexDsFields,
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
	monthRptManageIndexGridStore.on("load",function(){
		if(monthRptManageIndexGridStore.getTotalCount() != 0){
			var aplCode = Ext.getCmp('MonthRptManageIndexAplCode').getValue().trim();
			var reportType = Ext.getCmp('MonthRptManageIndexReportType').getValue().trim();
			var sheetName = Ext.getCmp("MonthRptManageIndexSheetName").getValue().trim();
			var month = Ext.util.Format.date(Ext.getCmp('MonthRptManageIndexMonth').getValue(), 'Ym');
			var subSheetName = Ext.getCmp('MonthRptManageIndexSubSheetName').getValue().trim();
			//启用bbar
			monthRptManageIndexGrid.getBottomToolbar().setDisabled(false);
			//创建图表
			dynamicDelRptChartDiv();
			monthRptManageIndexCreateChart(aplCode, reportType, sheetName, month, subSheetName);
		}else{
			//未查询到数据时，清除上次查询的图表div对象
			dynamicDelRptChartDiv();
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '无此时间段数据，请重新设定月份!',
				fn : function() {
					Ext.getCmp("MonthRptManageIndexMonth").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			//数据不存在时，清空图表数据，防止导出上次查询的图表数据			monthRptManageIndexChartsArr = [];
		}
	});
}
//	重新配置monthRptManageIndexGrid的store、columns、bbar、groupplugins
function monthRptManageIndexReconfigureGird(sheetName){
	monthRptManageIndexGrid.colModel = monthRptManageIndexGridCols;
	var groupRow = [];
	switch (sheetName.split("(",1)[0]) {
		case '当月日批量执行情况':
			groupRow.push({
		        header: '',
		        align: 'center',
		        colspan: 2
		    });
			Ext.each(monthRptManageIndexColumnHeaderGroupList, function(val){
				groupRow.push({
		            header: val,
		            align: 'center',
		            colspan: monthRptManageIndexColumnHeaderGroupColspan
		        });
			});
			break;
		case '当月日网络资源使用情况':
		case '当月weblogic使用情况':
			 groupRow.push({
		        header: null,
		        align: 'center',
		        colspan: 1
		    }); 
			Ext.each(monthRptManageIndexColumnHeaderGroupList, function(val){
				groupRow.push({
		            header: val.columnsHeader,
		            align: 'center',
		            colspan: val.childNum
		        });
			});
			break;
	}
	monthRptManageIndexGrid.colModel['rows'] = [groupRow];
	monthRptManageIndexGrid.reconfigure(monthRptManageIndexGridStore, monthRptManageIndexGrid.colModel);
	//	重新绑定bbar的store到新实例化的数据源	monthRptManageIndexGrid.getBottomToolbar().bind(monthRptManageIndexGridStore);
}

//	动态创建图表所用div对象
function dynamicCreateRptChartDiv(divCount,sheetName){
	if(divCount == '' || divCount == 0){
		Ext.Msg.show({
			title : '<fmt:message key="message.title"/>',
			msg : '未配置图表展示内容，请先到图表配置页面进行配置!',
			fn : function() {
				Ext.getCmp("MonthRptManageIndexAplCode").focus();
			},
			buttons : Ext.Msg.OK,
			icon : Ext.MessageBox.INFO
		});
	}else{
		dynamicDelRptChartDiv();
		//增大宽度显示图像
		if(sheetName=='系统资源使用率图表')	document.getElementById("monthRptContainer").style.width = '100%';
		for(var i=0; i<divCount; i++){
			if(document.getElementById("monthRptContainer"+i) == null){
				var newDivNode = document.createElement("div");
				newDivNode.setAttribute("id","monthRptContainer"+i);
				newDivNode.style.width="100%";
				newDivNode.style.height="380px";
				document.getElementById("monthRptContainer").appendChild(newDivNode);
			}
		}
	}
}
//动态删除存在的div对象
function dynamicDelRptChartDiv(){
	document.getElementById("monthRptContainer").innerHTML = '';
	//恢复显示图像默认宽度比例
	document.getElementById("monthRptContainer").style.width = '100%';
}

//定义列表
MonthRptManageIndex = Ext.extend(Ext.Panel, {
		tabIndex : 0,// 查询表单组件Tab键顺序		monthRptManageIndexForm : null,
		// 构造方法		constructor : function(cfg) {
		Ext.apply(this, cfg);
		//加载系统代码数据
		aplCodeStore.load();
		// 实例化数据列表数据源
		monthRptManageIndexGridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/monthrptmanage/index',
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
		
		// 实例化数据列表组件		monthRptManageIndexGrid = new Ext.grid.GridPanel({
			id : 'MonthRptManageIndexGridPanel',
			title : '<fmt:message key="title.list" />',
			region : 'center',
			border : false,
			height : 300,
		    minSize: 300,
		    maxSize: 300,
			loadMask : true,
			columnLines : true,
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
			store : monthRptManageIndexGridStore,
			// 列定义			cm : new Ext.grid.ColumnModel([{header : '',sortable : true}]),
			plugins : monthRptManageIndexColumnHeaderGroup,
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : monthRptManageIndexGridStore,
				displayInfo : true,
				pageSize  : pageSize,
				buttons : [ '-', {
					id : 'MonthRptManageIndexGridExportButton',
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					text : '导出excel',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				}]
			})
		});
	
		//	实例化查询表单		monthRptManageIndexForm = new Ext.FormPanel({
			id : 'MonthRptManageIndexFormPanel',
			title : '<fmt:message key="button.find" />',
			region:'east',
			frame : true,
			split : true,
			//autoHeight: true,
			height : 210,
			labelAlign : 'right',
			labelWidth: 55,
			width : 270,
			minSize : 270,
			maxSize : 270,
			autoScroll : true,
			collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
			defaults: {
            	anchor: '92%',
            	allowBlank: false,
            	msgTarget: 'side'
        	},
			items : [{
				xtype : 'combo',
				fieldLabel : '系统代码',
				id : 'MonthRptManageIndexAplCode',
				hiddenName : 'aplCode',
				displayField : 'displayField',
				valueField : 'valueField',
				typeAhead : true,
				forceSelection  : true,
				store : aplCodeStore,
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true,
				allowBlank : false,
				emptyText : '请选择系统代码',
				listeners : {
					select : function(combo, record, index){
						//若重新输入树形菜单的系统代码，则初始化查询表单的sheetName字段，待重新点击功能菜单后再设定该值，防止数据查询时参数值错误						Ext.getCmp("MonthRptManageIndexSheetName").setValue('');
						//获取树形菜单的根节点
						var _treeRoot = monthRptManageIndexTreePanel.getRootNode();
						if(Ext.getCmp("MonthRptManageIndexAplCode").getValue().trim() != ''){
							//清空div对象、图表数组数据、gridsotre数据
							dynamicDelRptChartDiv();
							monthRptManageIndexChartsArr =[];
							monthRptManageIndexGrid.getStore().removeAll();
							//禁用bbar
							monthRptManageIndexGrid.getBottomToolbar().setDisabled(true);
							//重新加载树形菜单
							_treeRoot.reload();
							//完全展开树形菜单
							monthRptManageIndexTreePanel.expandAll();
						}else{
							// 当树形的系统代码删除为空时，清空树形菜单
							_treeRoot.removeAll();
						}
					}
				}
			},{
			    xtype : 'datefield',
				fieldLabel : '月份',
				id : 'MonthRptManageIndexMonth',
				name : 'month',
				tabIndex : this.tabIndex++,
				allowBlank : false,
				plugins: 'monthPickerPlugin',
				format : 'Ym',
				value : new Date().add(Date.MONTH, -1),
				editable : false,
				emptyText : '请输入月份'
			},{
			    xtype : 'textfield',
				fieldLabel : '功能名称',
				id : 'MonthRptManageIndexSheetName',
				name : 'sheetName',
				tabIndex : this.tabIndex++,
				allowBlank : false,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '报表类型',
				id : 'MonthRptManageIndexReportType',
				name : 'reportType',
				value : '3',
				tabIndex : this.tabIndex++,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '子功能名称',
				id : 'MonthRptManageIndexSubSheetName',
				name : 'subSheetName',
				tabIndex : this.tabIndex++,
				hidden : true
			},{
			    xtype : 'textfield',
				fieldLabel : '导出时清空图片流缓存标识',
				id : 'MonthRptClearByteFlag',
				name : 'clearFlag',
				tabIndex : this.tabIndex++,
				hidden : true
			}],
			// 定义查询表单按钮
			buttonAlign : 'center',
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			}, {
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			} ]
		});
		// 实例化树形功能菜单		monthRptManageIndexTreeLoader = new Ext.tree.TreeLoader({
			dataUrl : '${ctx}/${managePath}/monthrptmanage/browseTreeData',
			requestMethod  : 'POST',
			clearOnLoad : true,
			autoLoad : false,
			baseParams : {
				reportType : '3'
			}
		});
		var root = new Ext.tree.AsyncTreeNode({
			text : '月报功能列表',
			leaf : true,
			draggable : false,
			iconCls : 'node-root',
			listeners : {
				load : function(node){
					node.leaf = false;
					if(node.hasChildNodes()){
						Ext.getCmp('MonthRptManageIndexExportAllExcel').enable();
					}else{
						Ext.getCmp('MonthRptManageIndexExportAllExcel').disable();
					}
				}
			}
		});
		monthRptManageIndexTreePanel = new Ext.tree.TreePanel({
			id : "MonthRptManageIndexTreePanel",
			title : "功能菜单",
			region : 'west',
			height : 210,
			width : 270,
			minSize : 270,
			maxSize : 270,
			rootVisible : true,//根节点是否可见			split : true,
			lines : true,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			loader : monthRptManageIndexTreeLoader,
			root : root,
			tools : [{
				id : 'refresh',
				scope : this,
				handler : function() {
					var selectedNodePath = null;
					if (monthRptManageIndexTreePanel.getSelectionModel().getSelectedNode() != null) {
						selectedNodePath = monthRptManageIndexTreePanel.getSelectionModel().getSelectedNode().getPath();
					}
					monthRptManageIndexTreePanel.root.reload();
					monthRptManageIndexTreePanel.root.expand();
					if (selectedNodePath != null) {
						monthRptManageIndexTreePanel.selectPath(selectedNodePath);
					}
				}
			}],
			tbar :['->', '-', {
				id : 'MonthRptManageIndexExportAllExcel',
				iconCls : 'button-excel',
				tooltip : '<fmt:message key="button.excel" />',
				scope : this,
				handler : this.doExportAll,
				disabled : true
			},'-',{
				id : 'MonthRptManageIndexExportAllWord',
				iconCls : 'button-word',
				tooltip : '<fmt:message key="button.word" />',
				scope : this,
				handler : this.doExportAll,
				disabled : true
			},'-',{
				id : 'MonthRptManageIndexExportAllPDF',
				iconCls : 'button-pdf',
				tooltip : '<fmt:message key="button.pdf" />',
				scope : this,
				handler : this.doExportAll,
				disabled : true
			}],
			listeners:{
				click : function(node){
					var sheetName; 
					var subSheetName;
					//禁用bbar
					monthRptManageIndexGrid.getBottomToolbar().setDisabled(true);
					//清除所有选中的复选框
					var selNodes = monthRptManageIndexTreePanel.getChecked();
					Ext.each(selNodes, function(_node){
						_node.attributes.checked = false;
						_node.ui.checkbox.checked = false;
					});
					aplCode = Ext.getCmp("MonthRptManageIndexAplCode").getValue().trim();
					reportType = Ext.getCmp("MonthRptManageIndexReportType").getValue().trim();
					if(node.text.indexOf("(") != -1){
						if(node.attributes.sysRes == true){
							 //系统资源子节点							sheetName = node.attributes.sheetName;
							subSheetName = node.attributes.subSheetName;
						}else{
							sheetName = node.text;
							subSheetName = node.text.split("(")[1].split(")")[0];
						}
						//设置点击的功能菜单名到查询表单中的隐藏项目						Ext.getCmp("MonthRptManageIndexSheetName").setValue(sheetName);
						Ext.getCmp("MonthRptManageIndexSubSheetName").setValue(subSheetName);
					}else{
						sheetName = node.text;
						subSheetName = '';
						//设置点击的功能菜单名到查询表单中的隐藏项目						Ext.getCmp("MonthRptManageIndexSheetName").setValue(sheetName);
						Ext.getCmp("MonthRptManageIndexSubSheetName").setValue(subSheetName);
					}
					//	点击非根节点
					if(sheetName != '月报功能列表' && node.leaf == true){
						//获取动态列名及数据源字段列表
						monthRptManageIndexCreateGridColAndDsfields(aplCode, reportType, sheetName, subSheetName);
						// 创建sotre为了重新配置store动态fields
						monthRptManageIndexCreateStore();
						// 重新配置monthRptMamonthRptdexGrid的store、columns、bbar、groupplugins
						monthRptManageIndexReconfigureGird(sheetName);
						// 配置Store参数
						Ext.apply(monthRptManageIndexGrid.getStore().baseParams, monthRptManageIndexForm.getForm().getValues());
						// 加载
						monthRptManageIndexGrid.getStore().load();
					}							
				}
			}
		});
		monthRptManageIndexTreeLoader.on('beforeload',function(loader,node){
			//使用查询条件系统代码文本框时用			loader.baseParams.aplCode = Ext.getCmp("MonthRptManageIndexAplCode").getValue();
		},this);
		
		var centerPanel = new Ext.Panel({
			id:'MonthRptManageIndexCenterPanel',
			title : '图表展示',
			split: false,
			region:'south',
		    height: 420,
		    minSize: 420,
		    maxSize: 420,
		    collapsible: false,
		    margins: '0 0 0 0',
			frame : true,
			autoScroll : true,
			collapsible : true,
			animCollapse : true,
			collapseMode : 'mini',
			contentEl: 'monthRptContainer'
		});
		// 设置基类属性		MonthRptManageIndex.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [centerPanel,monthRptManageIndexGrid,monthRptManageIndexTreePanel,monthRptManageIndexForm]
		});
	},
	// 查询事件
	doFind : function() {
		var aplCode = Ext.getCmp('MonthRptManageIndexAplCode').getValue().trim();
		var sheetName = Ext.getCmp('MonthRptManageIndexSheetName').getValue().trim();
		var subSheetName = Ext.getCmp('MonthRptManageIndexSubSheetName').getValue().trim();
		var reportType = Ext.getCmp("MonthRptManageIndexReportType").getValue().trim();
		var month = Ext.getCmp('MonthRptManageIndexMonth').getValue();
		if(aplCode == ''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '请先选择系统代码查询功能菜单列表!',
				fn : function() {
					Ext.getCmp("MonthRptManageIndexAplCode").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		}else if(sheetName == ''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '请先选择功能菜单列表的某项功能!',
				fn : function() {
					Ext.getCmp("MonthRptManageIndexTreePanel").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		}else if(month == ''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '请输入月份查询条件!',
				fn : function() {
					Ext.getCmp("MonthRptManageIndexMonth").focus();
				},
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		}else{
			monthRptManageIndexCreateGridColAndDsfields(aplCode, reportType, sheetName, subSheetName);
			// 创建sotre为了重新配置store动态fields
			monthRptManageIndexCreateStore();
			// 重新配置monthRptManageIndexGrid的store、columns、bbar、groupplugin
			monthRptManageIndexReconfigureGird(sheetName);
			// 配置Store参数
			Ext.apply(monthRptManageIndexGrid.getStore().baseParams, monthRptManageIndexForm.getForm().getValues());
			// 加载
			monthRptManageIndexGrid.getStore().load({callback : function(o,option,success) {
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
		monthRptManageIndexForm.getForm().reset();
	},
	doExportAll : function(){
		var tree = new Ext.tree.TreePanel({
	        height: 350,
	        width: 340,
	        useArrows:true,
	        autoScroll:true,
	        animate:true,
	        containerScroll: true,
	        rootVisible: true,
	        loader : monthRptManageIndexTreeLoader,
			root : new Ext.tree.AsyncTreeNode({
				text : '月报功能列表',
				draggable : false,
				iconCls : 'node-root'
			}),
	        listeners: {
	            'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode = node.parentNode;
				              if(pNode == tree.getRootNode()) return;
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
	            },
	            beforeappend : function(tree, node, childNode ) {
	            	childNode.attributes.checked = false;
	            }
	        },
	        buttons: [{
	        	text : '<fmt:message key="button.selectAll" />',
	        	scope : this,
	        	handler : function(){
	        		tree.getRootNode().cascade(function(node){
	        			if(node.parentNode != null){
		                 	node.attributes.checked = true;
			                node.ui.checkbox.checked = true;
	        			}
		            });
	        	}
	        }, {
	        	text : '<fmt:message key="button.deselectAll" />',
	        	scope : this,
	        	handler : function(){
	        		tree.getRootNode().cascade(function(node){
	        			if(node.parentNode != null){
		                 	node.attributes.checked = false;
			                node.ui.checkbox.checked = false;
	        			}
		            });
	        	}
	        }, {
	            text: '<fmt:message key="button.export" />',
	            scope : this,
	            handler: function(){
	            	if(tree.getChecked().length == 0){
	            		Ext.Msg.show( {
	        				title : '<fmt:message key="message.title" />',
	        				msg : '<fmt:message key="message.select.one.only" />',
	        				buttons : Ext.MessageBox.OK,
	        				icon : Ext.MessageBox.ERROR
	        			});
	            		return;
	            	}
	            	exportCallWin.hide();
	                var msg = '', selNodes = tree.getChecked();
	                var monthResrcNode = tree.getRootNode().findChild('text', '最近13个月系统资源使用率');
	                var dayResrcNode = tree.getRootNode().findChild('text', '当月系统资源使用率');
	                Ext.each(selNodes, function(node){
	                	if(!node.hasChildNodes()){
		                    if(msg.length > 0){
		                        msg += ',';
		                    }
		                    
		                    if(node.isAncestor(monthResrcNode)){
		                    	msg += monthResrcNode.text +'(' + node.text.substring( node.text.indexOf('(') + 1, node.text.indexOf(')')) + ')';
		                    }else if(node.isAncestor(dayResrcNode)){
		                    	msg += dayResrcNode.text +'(' + node.text.substring( node.text.indexOf('(') + 1, node.text.indexOf(')')) + ')';
		                    }else{
			                    msg += node.text;
		                    }
	                	}
	                });
	                
	                var aplCode = monthRptManageIndexForm.getForm().findField('aplCode').getValue();
	                var reportType = monthRptManageIndexForm.getForm().findField('reportType').getValue();
	                var month = Ext.util.Format.date(monthRptManageIndexForm.getForm().findField('month').getValue(), 'Ym');
	                Ext.Ajax.request({
	        			method : 'POST',
	        			url : '${ctx}/${managePath}/monthrptmanage/getSelectedMonthReport',
	        			disableCaching : true, //禁止缓存
	        			params: { 
	        				aplCode: aplCode,
	        				reportType : reportType,
	        				month : month,
	        				sheetNames : msg
	        			},
	        			async : false, //同步请求
	        			success : function(response){
	        				var responseData = response.responseText;
	        				var svbCount = 0;
	        				if(Ext.util.JSON.decode(responseData).withoutChart){
	        					Ext.Msg.show({
	        						title : '<fmt:message key="message.title"/>',
									msg : '没有可导出的图表, 请先配置图表!',
									buttons : Ext.Msg.OK,
									icon : Ext.MessageBox.INFO
	        					});
	        					return;
	        				}
	        				Ext.iterate(Ext.util.JSON.decode(responseData).chartsMap, function(sheetNameKey, charts){
	        					Ext.iterate(charts, function(chartKey, chartContent){
	        		                setTimeout(function(){
	        		                	//返回的图表数据
	        							var tmp = eval("(" + chartContent + ")");
	        							// 编辑chart图表配置项
	        							var xAxisData = [];
	        							var plotOptionsData;
	        							var toolTipData;
	        							// 趋势图的X轴坐标科目
	        							var xCategoriesOptions = tmp.xCategoriesOptions.split(",");
	    								
	    								xAxisData.push({
	    					                categories: xCategoriesOptions,
	    					                alternateGridColor: '#F2F2F2', //间隔显示不同颜色
	    					                gridLineWidth :0, //图表网格线0代表无，数字越大线越粗
	    					                labels: {  //X轴的标签（下面的说明）
	    					                    align: "right",              //位置
	    					                    enabled: true,               	//是否显示
	    					                    rotation: -60
	    					                }
	    					            });
	    								plotOptionsData = {
	    										spline: {
	    							                marker: {
	    							                	enable: false
	    							                }
	    							            },
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
	    						            };
	    								toolTipData = {
	    										crosshairs: true,
	    										pointFormat: '{series.name}: <b>{point.percentage}%</b>',
	    						            	percentageDecimals: 1,
	    					 	                formatter: function() {
	    					 	                	var unit;
	    						 	                if(tmp.toolTipUnit){
	    							 	                unit = Ext.util.JSON.decode(tmp.toolTipUnit)[this.series.name];
	    						 	                }	
	    					 	                    if (this.point.name) { // the pie chart
	    					 	                    	return '' + '<b>'+ this.point.name + '</b>: ' +': '+ this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);
	    					 	                    }else{
	    						 	                	return ''+
	    						 	                        this.x + '<br/><span style="color:' + this.series.color + '">' + this.series.name + '</span>: ' + 
	    						 	                        this.y +' '+ (typeof(unit) == 'undefined'?'' : unit);	
	    					 	                    }
	    					 	                }
	    					 	         };
	        							
	        							// 标题
	        							var titleOption = tmp.titleOption;
	        							// 对应的科目名及科目值
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
	        					            	renderTo: 'monthRptContainerHidden'
	        					            },
	        					            title: {//标题
	        					                text: titleOption /* ,
	        					                style:{                //样式
	        					                    cursor: 'pointer',
	        					                    color: 'red',
	        					                    fontSize: '20px'
	        					                } */
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
	        								url : '${ctx}/${managePath}/monthrptmanage/exportChartPic',
	        								params: {
	        									sheetName : sheetNameKey,
												type : 'image/jpeg', 	// 目前仅支持 'image/jpeg'
												svg : svg,
												count : svbCount
	        								},
	        								disableCaching : true,		// 禁止缓存
	        								async : false,		// 同步请求
	        								success : function(response,option){	},
	        								failure : function(response){		// 请求失败
	        									Ext.Msg.show({
	        										title : '<fmt:message key="message.title"/>',
	        										msg : '导出失败，请重试!',
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
	        					});
	        				});
	        				var picCount = 0;
	        				Ext.iterate(Ext.util.JSON.decode(responseData).chartsMap, function(sheetNameKey, charts){
	        					Ext.iterate(charts, function(chartKey, chartContent){
	        						picCount++;
	        					});
	        				});
	                        setTimeout(function(){
	        					//导出excel
	        					window.location = '${ctx}/${managePath}/monthrptmanage/excelSelected.xls?' + encodeURI(monthRptManageIndexForm.getForm().getValues(true));
	                        }, picCount*3000);
	        			}
	                });
	            }
	        }]
	    });
		tree.getRootNode().expand(true);
		var exportCallWin = new Ext.Window({
			title  :'请选择...',
			animCollapse:true,
			modal : true,
			width : 355,
			collapsible : false,
			resizable : false,
			draggable : true,
			//closable : false,
			closeAction :'close',
			items:[tree]
		});
		exportCallWin.show();
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		if(monthRptManageIndexChartsArr == ''){
			//只有数据没有图表的导出,设置标识为true用于清除上次查询保存在session中的图片字节流数据			Ext.getCmp("MonthRptClearByteFlag").setValue('true');
		}else{
			// 导出数据和图表			Ext.getCmp("MonthRptClearByteFlag").setValue('false');
			var sheetName = monthRptManageIndexForm.getForm().findField('sheetName').getValue();
			var count = 0;
			Ext.each(monthRptManageIndexChartsArr, function(rptChart){
				if(rptChart == undefined){
					Ext.Msg.show({
						title : '<fmt:message key="message.title"/>',
						msg : '请先选择月报功能菜单进行查询后再执行导出操作!',
						fn : function() {
							Ext.getCmp("MonthRptManageIndexAplCode").focus();
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
						url : '${ctx}/${managePath}/monthrptmanage/exportChartPic',
						params: {
							sheetName : sheetName,
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
		window.location = '${ctx}/${managePath}/monthrptmanage/excel.xls?' + encodeURI(monthRptManageIndexForm.getForm().getValues(true));
	}
});
var monthRptManageIndex = new MonthRptManageIndex();
</script>
<script type="text/javascript">
Ext.getCmp("MONTH_REP_MANAGE").add(monthRptManageIndex);
Ext.getCmp("MONTH_REP_MANAGE").doLayout();
</script>
<div id="monthRptContainer">
</div>
<div id="monthRptContainerHidden" style="display:none;height:380px;width:800px;">
</div>

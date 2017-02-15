<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
// 换页最大值var pageSize = 100;
//图表变量
var weekMangeChart = [];
//导出文件的系统代码var aplCode;
//导出文件的服务代码var srvCode;
//导出文件的开始时间var startDate;

var aplCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/weekrptmanage/browseWeekRptAplCode',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});

var srvCodeStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/weekrptmanage/browseWeekRptSrvCode',
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['aplCode', 'valueField', 'displayField'])
});
//待选服务器列表数据源
var toBeSelectedStore = new Ext.data.ArrayStore({
	fields: ['aplCode', 'valueField', 'displayField']
});
//已选服务器列表数据源
var selectedStore = new Ext.data.ArrayStore({
	fields: ['valueField', 'displayField']
});
//待选服务器记录
var toBeSelectedRecords = [];
//存放页面显示的报表图片
var showChartSvg;
 
function createChart(aplCode, reportType, startDate, srvCodes, sheetName, isExport){
	 Ext.Ajax.request({
 		method : 'POST',
 		url : '${ctx}/${managePath}/weekrptmanage/getChartData',
 		disableCaching : true, //禁止缓存
 		params: {
 			aplCode : aplCode,
 			reportType : reportType,
 			startDate : startDate,
 			srvCodes : srvCodes,
 			sheetName : sheetName
 		},
 		async : false, //同步请求
 		success : function(response){
 			var jsonArray = Ext.util.JSON.decode(response.responseText);
 			var containerIndex = 0;
 			
 			//清空div层的图像
 			if(jsonArray.length == 0){
 				document.getElementById('weekRptContainer').innerHTML = '';
 				weekMangeChart = [];
 				return ;
 			} 				
 			
 			for(var i = 0; i < jsonArray.length; i++){
 				var titleData;
 	 			var xAxisData = [];
 	 			var yAxisData = [];
 	 			var toolTipData;
 	 			var seriesData = [];
 	 			
 	 			containerIndex = i;
 	 			if(isExport){
 	 				containerIndex ++;
 					if(jsonArray[i].srvCode == srvCode){
 						//直接添加页面的报表图片, 不需要重新生成
 						if(showChartSvg) weekMangeChart.push(showChartSvg);
 						continue;
 					}
 	 			}
 	 			
 	 			 if(!document.getElementById('weekRptContainer' + containerIndex)){
 	 				var newDivNode = document.createElement('div');
 					newDivNode.setAttribute('id','weekRptContainer' + containerIndex );
 					newDivNode.style.width = '100%';
 					newDivNode.style.height = '375';
 					if(isExport) newDivNode.style.display = 'none';
 					
 					document.getElementById('weekRptContainer').appendChild(newDivNode);
 	 			 }
 				
	 			//报表标题
	 			titleData = {
	 			        text: jsonArray[i].titleData
	 			};
				//报表X轴	 			xAxisData.push({
	 			     categories: jsonArray[i].xCategories.split(','),
	 			     labels: {
	 						align: 'right',
	 				        enabled: true,
	 				        rotation: -30
	 					}                            
	 			 });
				//报表Y轴	 			yAxisData.push({
	 			     labels: {
	 			         formatter: function() {
	 			             return this.value +'%';
	 			         },
	 			         style: {
	 			             color: '#89A54E'
	 			         }
	 			     },
	 			     title: {
	 			         text: '使用率百分比',
	 			         style: {
	 			             color: '#89A54E'
	 			         }
	 			     },
	 			     min: 0,
	 			     max: 100,
	 			     tickInterval : 10
	 			 }); 
	 			 
	 			yAxisData.push({
	 			    gridLineWidth: 0,
	 			    title: {
	 			        text: '交易量笔数',
	 			        style: {
	 			            color: '#4572A7'
	 			        }
	 			    },
	 			    labels: {
	 			        formatter: function() {
	 			            return this.value/10000 +' 万';
	 			        },
	 			        style: {
	 			            color: '#4572A7'
	 			        }
	 			    },
	 			    opposite: true,
	 			    tickInterval : 1500000
	 			});
	 			//鼠标悬停时的提示工具
	 			var tip = jsonArray[i].toolTipUnit;
	 			toolTipData = {
	 	                formatter: function() {
	 	                	var unit = Ext.util.JSON.decode(tip)[this.series.name];
	 	                	
	 	                	return ''+
	 	                        this.x + '<br/><span style="color:'+this.series.color+'">'+this.series.name+'</span>: '+ 
	 	                        this.y +' '+ (typeof(unit)=='undefined'?'' : unit);
	 	                }
	 	            };
	 			 //报表各系列图表的数据
	 			 for(var j = 0; j < jsonArray[i].seriesData.length; j++){
	 				 seriesData.push({
	 					 name : jsonArray[i].seriesData[j].name,
	 					 type : jsonArray[i].seriesData[j].type,
	 					 yAxis : jsonArray[i].seriesData[j].yAxis,
	 					 data : jsonArray[i].seriesData[j].data
	 				 });
	 			 }
	 			 //增大宽度显示图像
	 			if(!isExport) document.getElementById("weekRptContainer").style.width = '1260px';
	 			 //创建报表图
	 			 var chart = new Highcharts.Chart({
						chart: {
							renderTo: 'weekRptContainer' + containerIndex,
							zoomType: 'xy'
						},
						title: titleData,
			            xAxis: xAxisData,
			            yAxis: yAxisData,
			            credits: {
			            	enabled: false
			            },
			            tooltip : toolTipData,
			            legend: {
			                layout: 'vertical',
			                align: 'right',
			                verticalAlign: 'top',
			                backgroundColor: '#FFFFFF',
				            y: 100
			            },
			            series: seriesData
			    });
	 			 
	 			if(!isExport){
	 				showChartSvg = {'srvCode':jsonArray[i].srvCode, 'chart':chart.getSVG()};
	 			}
				weekMangeChart.push({'srvCode':jsonArray[i].srvCode, 'chart':chart.getSVG()});
				//还原层对象宽度比例				if(!isExport) document.getElementById("weekRptContainer").style.width = '100%';
 			}
 			
			
 		}
 	}); 
 }
    	
//获取动态图标数据列名var weekRptManageIndexGridCols;
var weekRptManageIndexDsFields;
var weekRptManageIndexCmItems;

Ext.Ajax.request({
	method : 'POST',
	url : '${ctx}/${managePath}/weekrptmanage/getColumns',
	params: {
		aplCode : 'NBANK',
		reportType:'2',
		sheetName:'系统资源使用率图表'
	},
	disableCaching : true,	//禁止缓存
	async : false, //同步请求
	success : function(response,option){
		var text = response.responseText;
		weekRptManageIndexCmItems = Ext.util.JSON.decode(Ext.util.JSON.decode(text).columnModel);
		weekRptManageIndexDsFields = Ext.util.JSON.decode(Ext.util.JSON.decode(text).fieldsNames);
		weekRptManageIndexGridCols = new Ext.grid.ColumnModel(weekRptManageIndexCmItems);
	},
	// 请求失败时	failure : function(response){
		Ext.Msg.show({
			title : '<fmt:message key="message.title"/>',
			msg : '在读取动态数据时发生错误，请重试!',
			fn : function() {
				Ext.getCmp("WeekRptManageIndexAplCode").focus();
			},
			buttons : Ext.Msg.OK,
			icon : Ext.MessageBox.INFO
		});
	},
	callback : function(options, success, response){
	}
});

//定义列表
WeekRptManageIndex = Ext.extend(Ext.Panel, {
	tabIndex : 0,// 查询表单组件Tab键顺序	form : null,
	grid : null,
	gridStore : null,
	// 构造方法	constructor : function(cfg) {
		Ext.apply(this, cfg);
		
		aplCodeStore.load();
		srvCodeStore.load();
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${managePath}/weekrptmanage/index',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : weekRptManageIndexDsFields,
			pruneModifiedRecords : true,
			remoteSort : true,
			sortInfo : {
				field : 'aplCode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : pageSize
			}
		});
		this.gridStore.on('load', function(){
			Ext.getCmp('WeekRptManageIndexGridPanelExportXls').enable();
			Ext.getCmp('WeekRptManageIndexGridPanelSave').disable();
			var aplCode = Ext.getCmp('WeekRptManageIndexAplCode').getValue().trim();
			var reportType = Ext.getCmp('WeekRptManageIndexReportType').getValue().trim();
			var srvCode = Ext.getCmp('WeekRptManageIndexSrvCode').getValue().trim();
			var startDate = Ext.util.Format.date(Ext.getCmp('WeekRptManageIndexStartDate').getValue(),'Ymd');
			createChart(aplCode, reportType, startDate, srvCode, '系统资源使用率图表', false);
			toBeSelectedRecords = [];
			srvCodeStore.each(function(item){
				toBeSelectedRecords.push(item);
			});
		});
		
		// 实例化数据列表组件		this.grid = new Ext.grid.EditorGridPanel({
			id : 'WeekRptManageIndexGridPanel',
			region : 'center',
			border : false,
			frame : true,
			loadMask : true,
			clicksToEdit : 1,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : false,
				getRowClass : function(record, rowIndex, rowParams, store){
					if(record.data.reviseFlag == '1'){
						return 'x-grid-back-SandyBrown';
					}
					if((rowIndex + 1) % 2 === 0){
						return 'x-gridTran-row-alt';
					}
				}
			},
			height : 295,
			store : this.gridStore,
			// 列定义			cm : weekRptManageIndexGridCols,
			// 定义分页工具条			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize  : pageSize,
				buttons : [ '-', {
					iconCls : 'button-save',
					id : 'WeekRptManageIndexGridPanelSave',
					tooltip : '<fmt:message key="button.save" />',
					text : '保存',
					disabled : true,
					scope : this,
					handler : this.doSave
				}, {
					iconCls : 'button-excel',
					id : 'WeekRptManageIndexGridPanelExportXls',
					tooltip : '<fmt:message key="button.excel" />',
					text : '导出excel',
					disabled : true,
					scope : this,
					handler : this.doExportXLS
				}]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				'beforeedit' : function(e){
					//上周的允许修改
					if(Ext.util.Format.date(new Date().add(Date.DAY, 1 - 7 - new Date().getDay()),'Ymd') != e.record.get('countWeekValue')){
						e.cancel = true;
					}else{
						var count = 0;
						Ext.iterate(e.record.data, function(name, value){
							if(value == null){
								count ++;
							}
						});
						if(count >= 9) e.cancel = true;
					}
					
				},
				//编辑完成后处理事件				'afteredit' : function(e){
					Ext.getCmp('WeekRptManageIndexGridPanelSave').enable();
				}
			}
		});
	
		this.form = new Ext.FormPanel({
			id : 'WeekRptManageIndexFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 105,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults: {
            	anchor: '100%',
            	allowBlank: false,
            	msgTarget: 'side'
        	},
			items : [{
				xtype : 'combo',
				fieldLabel : '系统代码',
				id : 'WeekRptManageIndexAplCode',
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
				listeners : {
					select : function(combo, record, index){
						Ext.getCmp('WeekRptManageIndexSrvCode').clearValue();
						srvCodeStore.filter('aplCode', combo.value, false, true);
						
						if(srvCodeStore.getCount() == 0){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : '不存在对应的服务器编号',
								fn : function() {
									Ext.getCmp('WeekRptManageIndexAplCode').setValue();
									Ext.getCmp("WeekRptManageIndexAplCode").focus();
									srvCodeStore.load();
								},
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.INFO
							});
						}
					}
				}
			}, {
			    xtype : 'textfield',
				fieldLabel : '报表类型',
				id : 'WeekRptManageIndexReportType',
				name : 'reportType',
				value : '2',
				hidden : true
			}, {
			    xtype : 'textfield',
				fieldLabel : 'sheet名称',
				id : 'WeekRptManageIndexSheetName',
				name : 'sheetName',
				value : '系统资源使用率图表',
				hidden : true
			}, {
				xtype : 'combo',
				fieldLabel : '服务器编号',
				id : 'WeekRptManageIndexSrvCode',
				hiddenName : 'srvCode',
				displayField : 'displayField',
				valueField : 'valueField',
				typeAhead : true,
				forceSelection  : true,
				store : srvCodeStore,
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true,
				allowBlank : false,
				listeners: {
					select : function(combo, record, index){
						Ext.getCmp("WeekRptManageIndexAplCode").setValue(record.get('aplCode'));
					},
					expand:function(combo){
						var aplCode = Ext.getCmp('WeekRptManageIndexAplCode').getValue();
						if(aplCode != ''){
							srvCodeStore.filter('aplCode', aplCode, false, true);
						}
					}
				}
			}, {
			    xtype : 'datefield',
				fieldLabel : '起始日期',
				id : 'WeekRptManageIndexStartDate',
				name : 'startDate',
				disabledDays : [0, 2, 3, 4, 5, 6],
				tabIndex : this.tabIndex++,
				allowBlank : false,
				format : 'Ymd',
				editable : false,
				value : new Date().add(Date.DAY, 1 - 30 * 7-new Date().getDay()),//30周前的周一
				emptyText : '请输入起始日期'
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
		
		var centerPanel = new Ext.Panel({
			id:'WeekRptManageIndexCenterPanel',
			title : '系统资源使用率图表',
			split: false,
			region:'south',
		   // height: 400,
		    minSize: 160,
		    maxSize: 400,
		    collapsible: true,
		    margins: '0 0 0 0',
			frame : true,
			autoScroll : true,
			contentEl: 'weekRptContainer'
		});
		
		// 设置基类属性		WeekRptManageIndex.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [centerPanel, this.grid, this.form]
		});
	},
	
	// 查询事件
	doFind : function() {
		aplCode = Ext.getCmp('WeekRptManageIndexAplCode').getValue().trim();
		srvCode = Ext.getCmp('WeekRptManageIndexSrvCode').getValue().trim();
		startDate = Ext.util.Format.date(Ext.getCmp('WeekRptManageIndexStartDate').getValue(),'Ymd');
		
		if(aplCode == '' || startDate == '' || srvCode == ''){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '查询条件必须全部录入!',
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
		}else{
			Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
			this.grid.getStore().load();
		}
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		if(this.grid.getStore().getCount() == 0){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '没有数据可导出!',
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.INFO
			});
			return;
		}
		//重新初始化数据源
		toBeSelectedStore.removeAll();
		//清空已选
		selectedStore.removeAll();
		Ext.each(toBeSelectedRecords, function(item){
			if(item.get('valueField').trim() == srvCode){
				selectedStore.add(item);
			}else{
				toBeSelectedStore.add(item);
			}
		});
		//标签
		var fieldLbl = '';
		for(var i = 0; i < aplCodeStore.getCount(); i++){
			var record = aplCodeStore.getAt(i);
			if(record.get('valueField') == aplCode){
				fieldLbl = record.get('displayField');
				break;
			}
		}
		
		var isForm = new Ext.form.FormPanel({
			autoWidth : true,
			layout : 'form',
			animCollapse : true,
			frame : true,
			bodyStyle: 'padding:10px;',
			items:[{
   		 		xtype: 'itemselector',
    			name: 'srvCodes',
    			id : 'WeekRptManageIndexItemSelector',
    			fieldLabel: fieldLbl,
    			imagePath: '${ctx}/static/scripts/extjs/examples/ux/images',
    			multiselects: [{
        			width: 220,
        			height: 180,
        			legend:'待选服务器',
        			store: toBeSelectedStore,
                    displayField: 'displayField',
                    valueField: 'valueField'
    			}, {
       				width: 220,
        			height: 180,
        			legend:'已选服务器',
        			store: selectedStore,
                    displayField: 'displayField',
                    valueField: 'valueField',
        			tbar:[{
            			text: '清除',
            			handler:function(){
                			isForm.getForm().findField('srvCodes').reset();
            			}
        			}]
    			}]
			}],
			buttonAlign:'right',
			buttons: [{
    			text: '确定',
    			handler: function(){
        			if(isForm.getForm().isValid()){
        				var toStoreCount = Ext.getCmp('WeekRptManageIndexItemSelector').toStore.getCount();
        				if(toStoreCount == 0){
        					Ext.Msg.show({
        						title : '<fmt:message key="message.title"/>',
        						msg : '请至少选中1条数据!',
        						buttons : Ext.Msg.OK,
        						icon : Ext.MessageBox.WARNING
        					});
        					return;
        				}else if(toStoreCount > 5){
        					Ext.Msg.show({
        						title : '<fmt:message key="message.title"/>',
        						msg : '至多选中5条数据!',
        						buttons : Ext.Msg.OK,
        						icon : Ext.MessageBox.WARNING
        					});
        					return;
        				}
        				
        				var reportType = Ext.getCmp('WeekRptManageIndexReportType').getValue().trim();
        				var srvCodes = isForm.getForm().findField('srvCodes').getValue();
        				exportCallWin.close();
        				var svgs = [];
        				weekMangeChart = [];
        				createChart(aplCode, reportType, startDate, srvCodes, '系统资源使用率图表', true);
        				
        				Ext.Ajax.request({
        					method : 'POST',
        					url : '${ctx}/${managePath}/weekrptmanage/transformSvgDat',
        					params : {
        						svg : Ext.util.JSON.encode(weekMangeChart),
        						imgType : 'image/jpeg'
        					},
        					disableCaching : true,	// 禁止缓存
        					async : false
        				});
        				window.location = '${ctx}/${managePath}/weekrptmanage/excel.xls?' 
        						+ 'srvCodes=' + srvCodes + '&aplCode=' + aplCode + '&startDate=' + startDate 
        								+ '&reportType=2&sheetName='+encodeURI(encodeURI('系统资源使用率图表'));
        			}
    			}
			}, {
    			text: '取消',
    			handler: function(){
        			exportCallWin.close();
    			}
			}]
		});
		
		var exportCallWin = new Ext.Window({
			title  :'设置导出条件',
			animCollapse:true,
			modal : true,
			width : 620,
			collapsible : false,
			resizable : true,
			draggable : true,
			//closable : false,
			closeAction :'close',
			items:[isForm]
		});
		exportCallWin.show();
		
	},
	//保存修改的数据
	doSave : function(){
		var store = this.gridStore;
		var modified = store.getModifiedRecords();
		var json = [];
		
		if(modified.length == 0){
			Ext.Msg.show({
				title : '<fmt:message key="message.title"/>',
				msg : '没有数据可保存!',
				buttons : Ext.Msg.OK,
				icon : Ext.MessageBox.WARNING
			});
			return;
		}
		
		Ext.each(modified, function(item){
			json.push(item.data);
		});
		
		Ext.Ajax.request({
			method : 'POST',
			url : '${ctx}/${managePath}/weekrptmanage/edit',
			params : {
				data : Ext.util.JSON.encode(json),
				aplCode : aplCode,
				srvCode : srvCode
			},
			success : function(response, option){
				var success = Ext.util.JSON.decode(response.responseText).success;
				if(success){
					Ext.Msg.show({
						title : '<fmt:message key="message.title"/>',
						msg : '保存成功',
						fn : function(){
							store.reload();
						},
						buttons : Ext.Msg.OK,
						icon : Ext.MessageBox.INFO
					});
				}else{
					Ext.Msg.show({
						title : '<fmt:message key="message.title"/>',
						msg : '保存失败',
						buttons : Ext.Msg.OK,
						icon : Ext.MessageBox.ERROR
					});
				}
			},
			failure : function(){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '保存失败',
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
		});
	}
});

var weekRptManageIndex = new WeekRptManageIndex();
</script>
<script type="text/javascript">
Ext.getCmp("WEEK_REP_MANAGE").add(weekRptManageIndex);
Ext.getCmp("WEEK_REP_MANAGE").doLayout();
</script>
<div id="weekRptContainer" style="min-width: 400px; width:100%; height: 375px; margin: 0 auto"></div>
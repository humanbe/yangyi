<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//定义列表
ErrorList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
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

		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${managePath}/serverssynchronous/errorlistdata',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'errorRownumber','errorType','errorData' ],
			remoteSort : true,
			sortInfo : {
				
			},
			baseParams : {
				start : 0,
				limit : 100,
				Path: '${param.Path}'
			
			}
		});
		//加载数据源
		this.gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), 
			    {header : '错误行数', dataIndex : 'errorRownumber', sortable : true},       
				{header : '错误类型', dataIndex : 'errorType', sortable : true,
					renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
					    //build the qtip:    
					    var title = "详细描述";
					    var tip = record.get('errorType');    
					    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

					    //return the display text:    
					    var displayText =  record.get('errorType') ;    
					    return displayText;    

					}
			    },
				{header : '错误数据', dataIndex : 'errorData', sortable : true,
			    	renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
					    //build the qtip:    
					    var title = "详细描述";
					    var tip = record.get('errorData');    
					    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    

					    //return the display text:    
					    var displayText =  record.get('errorData') ;    
					    return displayText;    

					}		
				}
	  		
	  		],
	  		
			
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				}  ]
			}),
			// 定义数据列表监听事件
			listeners : {
			}
		
		});

		

		// 设置基类属性
		ErrorList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [  this.grid ]
		});
	},
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/serverssynchronous/error_excel.xls';
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '没有数据,不可导出',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	}
	
	
});

var  errorList= new ErrorList();
</script>


<script type="text/javascript">
app.window.get(0).add(errorList);
app.window.get(0).doLayout();
</script>

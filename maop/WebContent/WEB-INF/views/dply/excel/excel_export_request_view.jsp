<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//定义角色分配列表
ExcelExportRequestViewList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	//csm : null,// 数据列表选择框组件
	grid:null,
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);

		 // 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/excelexportrequest/view',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
            totalProperty : 'count',
			fields : [ 'id','position','requestId','name','component','serviceCode',
			           'differentLevelFromPrevious','manual','autoJobName','userName'
			           ],
           remoteSort : true,
            sortInfo : {
				field : 'position',
				direction : 'ASC'
			},
            baseParams : {
                start : 0,
                limit : 100,
                requestsId : '${param.requestsId}'
            }
		});
		
		
		// 加载列表数据
		this.gridStore.load();
		 
		this.grid = new Ext.grid.GridPanel( {
            region : 'center',
            border : false,
            loadMask : true,
            title : '<fmt:message key="title.list" />',
            columnLines : true,
            viewConfig : {
                forceFit : false
            },
            store : this.gridStore,
            // 列定义
			//sm : csm,

            columns : [ new Ext.grid.RowNumberer(),
                        
                        {header : '<fmt:message key="dplyRequestInfo.serviceCode" />', dataIndex : 'serviceCode', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.stepName" />', dataIndex : 'name', sortable : true, width : 150},
                        {header : '<fmt:message key="dplyRequestInfo.component" />', dataIndex : 'component', sortable : true, width : 150},
                        {header : '<fmt:message key="dplyRequestInfo.manual" />', dataIndex : 'manual', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.differentLevelFromPrevious" />', dataIndex : 'differentLevelFromPrevious', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.owner" />', dataIndex : 'userName', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.autoJobName" />', dataIndex : 'autoJobName', sortable : true, width : 150}
                        ],
           
            // 定义分页工具条
            bbar : new Ext.PagingToolbar( {
                store : this.gridStore,
                displayInfo : true ,
                pageSize : 100 
            })
        });
		ExcelExportRequestViewList.superclass.constructor.call(this, {
            layout : 'border',
            border : false,
            items : [  this.grid ]
        });
		

		
	}
});

app.window.get(0).add(new ExcelExportRequestViewList());
app.window.get(0).doLayout();
</script>

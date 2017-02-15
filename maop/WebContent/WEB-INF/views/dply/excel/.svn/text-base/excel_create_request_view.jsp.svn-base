<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

this.StepTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/STPE_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.StepTypeStore.load();

this.StepParallelStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/STPE_PARALLEL/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.StepParallelStore.load();

//定义角色分配列表
ExcelCreateRequestViewList = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源
	//csm : null,// 数据列表选择框组件
	grid:null,
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);

		 // 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/excelcreaterequest/view',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'data',
            totalProperty : 'count',
			fields : [ 'id','position','requestId','name','differentLevelFromPrevious',
			           'serviceCode','servers','component','manual','owner','autoJobName',
			           'createStatus','operateLog','createdAt','updatedAt'],
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
                        {
							header : '<fmt:message key="dplyRequestInfo.requestStatus" />',
							dataIndex : 'createStatus',
							sortable : true,
							align : 'center',
							width : 50,
							renderer : function(value, metadata, record, rowIndex, colIndex, store){
								if(value == '完成'){
									return '<img src="${ctx}/static/style/images/button/confirm.png" alt="完成"></img>';
								}else if(value == '失败'){
									return '<img src="${ctx}/static/style/images/button/close.png" alt="失败"></img>';
								}else if(value == '进行中'){
									return '<img src="${ctx}/static/style/images/button/running.gif" alt="进行中"></img>';
								}else if(value == '等待'){
									return '<img src="${ctx}/static/style/images/button/lock.png" alt="等待"></img>';
								}else {
									return value;
								}
							}
						},
                        {header : '<fmt:message key="dplyRequestInfo.serviceCode" />', dataIndex : 'serviceCode', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.stepName" />', dataIndex : 'name', sortable : true, width : 150},
                        {header : '<fmt:message key="dplyRequestInfo.component" />', dataIndex : 'component', sortable : true, width : 150},
                        {header : '<fmt:message key="dplyRequestInfo.manual" />', dataIndex : 'manual',renderer:this.StepTypeStoreone, sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.differentLevelFromPrevious" />', dataIndex : 'differentLevelFromPrevious',renderer:this.StepParallelStoreone, sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.owner" />', dataIndex : 'owner', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.autoJobName" />', dataIndex : 'autoJobName', sortable : true, width : 150},
                        //{header : '<fmt:message key="dplyRequestInfo.createStatus" />', dataIndex : 'createStatus', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.operateLog" />', dataIndex : 'operateLog', sortable : true, width : 200}
                        ],
            // 定义分页工具条
            bbar : new Ext.PagingToolbar( {
                store : this.gridStore,
                displayInfo : true ,
                pageSize : 100 
            })
        });
		ExcelCreateRequestViewList.superclass.constructor.call(this, {
            layout : 'border',
            border : false,
            items : [  this.grid ]
        });
	},
    
	StepTypeStoreone : function(value) {

		var index = StepTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return StepTypeStore.getAt(index).get('name');
		}
	},
	StepParallelStoreone : function(value) {

		var index = StepParallelStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return StepParallelStore.getAt(index).get('name');
		}
	}
});

app.window.get(0).add(new ExcelCreateRequestViewList());
app.window.get(0).doLayout();
</script>

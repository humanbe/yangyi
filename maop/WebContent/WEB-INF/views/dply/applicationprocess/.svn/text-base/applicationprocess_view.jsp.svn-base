<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var apflag=('${param.subject_info}'=='2');
applicationprocess_view = Ext.extend(Ext.FormPanel, {
	row : 0,// Tab键顺序
	
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性
        this.OsUserUserIdStore = new Ext.data.Store(
				{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								url : '${ctx}/${managePath}/ApplicationProcess/findUserId'
							}),
							reader: new Ext.data.JsonReader({}, ['userId','name'])
				});
		this.OsUserUserIdStore.load();      
		
			
			// 实例化数据列表数据源
		 	this.gridStore = new Ext.data.JsonStore(
			{
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${managePath}/ApplicationProcess/viewdata',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
			fields : ['record_id','serverIp','serverName','appsysCode','bsaAgentFlag','floatingIp','osType','mwType','dbType','collectionState','machineroomPosition',
			           'appPattern','serverUse','environmentType','serverRole','dataType'],
				remoteSort : false,
				sortInfo : {
					field : 'serverIp',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100,
					record_id:'${param.record_id}'
					
				}
			});

			// 加载列表数据
			this.gridStore.load();
			
			this.grid = new Ext.grid.GridPanel(
					{
						border : true,
						height : 515,
						loadMask : true,
						region : 'center',
						border : false,
						loadMask : true,
						autoScroll : true,
						autoWeight : true,
						//autoHeight : true,
						title : '申请详细',
						columnLines : true,
						viewConfig : {
							forceFit : false
						},
						defaults : {
							anchor : '90%',
							msgTarget : 'side'
						},
						enableColumnHide:false,
						enableHdMenu : false, 
						store : this.gridStore,
						// 列定义
						columns : [
							new Ext.grid.RowNumberer(),
							{header : '<fmt:message key="application.record_id" />', dataIndex : 'record_id', sortable : true},
							{header : '<fmt:message key="property.serverIp" />', dataIndex : 'serverIp', sortable : true},
							{header : '<fmt:message key="property.serverName" />', dataIndex : 'serverName', sortable : true,hidden:apflag},
							{header : '<fmt:message key="toolbox.appsys_code" />', dataIndex : 'appsysCode', sortable : true, renderer : this.serAppsys_Store},
							{header : '<fmt:message key="property.bsaAgentFlag" />', dataIndex : 'bsaAgentFlag', sortable : true,hidden:apflag, 
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '0' : return '未安装';
										case '1' : return '已经安装';
									
									}
								}
							},
							//{header : '<fmt:message key="property.serverGroup" />', dataIndex : 'serverGroup', sortable : true},
							{header : '<fmt:message key="property.floatingIp" />', dataIndex : 'floatingIp', sortable : true,hidden:apflag},
							{header : '<fmt:message key="property.osType" />', dataIndex : 'osType', sortable : true,hidden:apflag },
							{header : '<fmt:message key="property.mwType" />', dataIndex : 'mwType', sortable : true ,hidden:apflag},
							{header : '<fmt:message key="property.dbType" />', dataIndex : 'dbType', sortable : true ,hidden:apflag},
							{header : '<fmt:message key="property.collectionState" />', dataIndex : 'collectionState', sortable : true,hidden:apflag },
							{header : '<fmt:message key="property.environmentType" />', dataIndex : 'environmentType', sortable : true ,hidden:apflag},
							{header : '<fmt:message key="property.machineroomPosition" />', dataIndex : 'machineroomPosition', sortable : true,hidden:apflag},
							{header : '<fmt:message key="property.serverRole" />', dataIndex : 'serverRole', sortable : true ,hidden:apflag},
							{header : '<fmt:message key="property.serverUse" />', dataIndex : 'serverUse', sortable : true ,hidden:apflag}
							

						
					 	],
						// 定义按钮工具条
						tbar : new Ext.Toolbar(
								{
									items : [
									         
									]
								}),
						// 定义分页工具条

						bbar : new Ext.PagingToolbar({
							store : this.gridStore,
							displayInfo : true,
							pageSize : 100
						})
					});
		
			 
			
		
		applicationprocess_view.superclass.constructor.call(this, {
			
				layout : 'border',
				border : false,
				items : [ this.grid ]
			
		});
		
			 
			
		
	}

	


});
var applicationprocess_view = new applicationprocess_view();
/* // 实例化新建表单,并加入到Tab页中
Ext.getCmp("PROCESS_VIEW").add(applicationprocess_view);
// 刷新Tab页布局
Ext.getCmp("PROCESS_VIEW").doLayout(); */

</script>



<script type="text/javascript">
app.window.get(0).add(applicationprocess_view);
app.window.get(0).doLayout();
</script>

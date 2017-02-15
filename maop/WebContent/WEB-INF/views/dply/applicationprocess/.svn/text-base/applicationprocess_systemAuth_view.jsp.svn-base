<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var apflag=('${param.subject_info}'=='2');
applicationsystemauth_view = Ext.extend(Ext.FormPanel, {
	row : 0,// Tab键顺序
	
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性
        /* this.OsUserUserIdStore = new Ext.data.Store(
				{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								url : '${ctx}/${managePath}/ApplicationProcess/findUserId'
							}),
							reader: new Ext.data.JsonReader({}, ['userId','name'])
				});
		this.OsUserUserIdStore.load(); */      
		
			
			// 实例化数据列表数据源
		 	this.gridStore = new Ext.data.JsonStore(
			{
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${managePath}/ApplicationProcess/systemAuthView',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',

			fields : ['record_id','userName','applicationUser','appsysName','appsysCode','applicationAuthDply','applicationAuthToolbox','applicationAuthCheck'],
				remoteSort : false,
				/* sortInfo : {
					field : 'serverIp',
					direction : 'ASC'
				}, */
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
						title : '<fmt:message key="application.detail" />',
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
							//userName,applicationUser,appsysName,appsysCode,applicationAuthDply,applicationAuthToolbox,applicationAuthCheck

							{header : '<fmt:message key="application.record_id" />', dataIndex : 'record_id', sortable : true, width : 180},
							{header : '<fmt:message key="application.systemAuth.userName" />', dataIndex : 'userName', sortable : true, width : 100},
							{header : '<fmt:message key="application.systemAuth.appsysName" />', dataIndex : 'appsysName', sortable : true, renderer : this.serAppsys_Store, width : 200},
							{header : '<fmt:message key="application.systemAuthDply" />', dataIndex : 'applicationAuthDply', sortable : true, 
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '0' : return '<img src="${ctx}/static/style/images/button/close.png" alt="未申请"></img>';
										case '1' : return '<img src="${ctx}/static/style/images/button/confirm.png" alt="已申请"></img>';
									
									}
								}
							},{header : '<fmt:message key="application.systemAuthToolbox" />', dataIndex : 'applicationAuthToolbox', sortable : true,
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '0' : return '<img src="${ctx}/static/style/images/button/close.png" alt="未申请"></img>';
										case '1' : return '<img src="${ctx}/static/style/images/button/confirm.png" alt="已申请"></img>';
										
									}
								}
							},{header : '<fmt:message key="application.systemAuthCheck" />', dataIndex : 'applicationAuthCheck', sortable : true,
								renderer : function(value, metadata, record, rowIndex, colIndex, store){
									switch(value){
										case '0' : return '<img src="${ctx}/static/style/images/button/close.png" alt="未申请"></img>';
										case '1' : return '<img src="${ctx}/static/style/images/button/confirm.png" alt="已申请"></img>';
										
									}
								}
							}
							

						
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
		
			 
			
		
		applicationsystemauth_view.superclass.constructor.call(this, {
			
				layout : 'border',
				border : false,
				items : [ this.grid ]
			
		});
		
			 
			
		
	}

	


});
var applicationsystemauth_view = new applicationsystemauth_view();
/* // 实例化新建表单,并加入到Tab页中
Ext.getCmp("PROCESS_VIEW").add(applicationsystemauth_view);
// 刷新Tab页布局
Ext.getCmp("PROCESS_VIEW").doLayout(); */

</script>



<script type="text/javascript">
app.window.get(0).add(applicationsystemauth_view);
app.window.get(0).doLayout();
</script>

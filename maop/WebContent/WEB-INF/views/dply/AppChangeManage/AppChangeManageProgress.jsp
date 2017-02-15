<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义列表
AppChangeManageProgress = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/appchangemanage/progress',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : ['changeMonth', 'status', 'progress', 'statistical', 'aplCodes'],
			baseParams : {
				changeMonth : Ext.util.Format.date(new Date(), 'Ym')
			}
		});
		this.gridStore.load();

		// 实例化数据列表组件		this.grid = new Ext.grid.GridPanel( {
			id : 'AppChangeManageProgressGridPanel',
			region : 'center',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : this.gridStore,
			viewConfig : {
				forceFit : true
			},
			// 列定义			columns : [ new Ext.grid.RowNumberer(),
				{header : '<fmt:message key="property.changeMonth" />', dataIndex : 'changeMonth'},
				{header : '<fmt:message key="property.status" />', dataIndex : 'status'},
				{header : '<fmt:message key="property.progress" />', dataIndex : 'progress'},
				{header : '<fmt:message key="property.statistical" />', dataIndex : 'statistical', 
					renderer : function(value){
						return '<a href="javascript:doViewDetailInfo()">'+value+'</a>';
					}
				},
				{header : '<fmt:message key="property.aplCode" />', dataIndex : 'aplCodes'}
	  		],
	  		
			// 定义按钮工具条			tbar : new Ext.Toolbar({
				items : [' ', {
					id : 'progressChangeMonth',
				    xtype : 'datefield',
				    width : 80,
				    emptyText : '<fmt:message key="property.changeMonth" />',
					text : '<fmt:message key="button.create" />',
					plugins: 'monthPickerPlugin',
					format :'Ym',
					value : new Date(),
					name : 'changeMonth'
				}, {
					scope : this,
					text : '<fmt:message key="button.statistical" />',
					handler : this.doFind
				}]
			})
		});

		// 设置基类属性		AppChangeManageProgress.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [this.grid ]
		});
	},
	// 查询事件
	doFind : function() {
		this.grid.getStore().baseParams.changeMonth = Ext.util.Format.date(Ext.getCmp('progressChangeMonth').getValue(), 'Ym');
		this.grid.getStore().load();
	}
});

function doViewDetailInfo(){
	var grid = Ext.getCmp('AppChangeManageProgressGridPanel');
	var record = grid.getSelectionModel().getSelected();
	var params = {
			changeMonth : record.get('changeMonth'),
			aplCodes : record.get('aplCodes'),
			status : encodeURIComponent(record.get('status')),
			progress : encodeURIComponent(record.get('progress'))
		};
		var tab = Ext.getCmp("view_AppChangeManageProgressDetail");
		if(tab){
			tab.setTitle('<fmt:message key="button.view" /><fmt:message key="property.appChangeInfo" /><fmt:message key="title.list" />');
		}
		app.loadTab('view_AppChangeManageProgressDetail', 
				'<fmt:message key="button.view" /><fmt:message key="property.appChangeInfo" /><fmt:message key="title.list" />', 
				'${ctx}/${managePath}/appchangemanage/progressDetail', 
				params);
};

Ext.getCmp("MgrAppChangeManageProgress").add(new AppChangeManageProgress());
Ext.getCmp("MgrAppChangeManageProgress").doLayout();
</script>

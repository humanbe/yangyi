<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">



var gridStore;
var mask = new Ext.LoadMask(Ext.getBody(),{
	msg:'进行中，请稍候...',
	removeMask :true
	
});
var SerappsysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
});
/* var SersysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});   */
//定义列表
OsUserList = Ext.extend(Ext.Panel, {
	//gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		this.userStore =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/jobdesign/getUserIdNames',
				method : 'GET',
				disableCaching : true
			}),
			reader : new Ext.data.JsonReader({}, ['username','name'])
		});
		this.userStore.load();
		this. bsaAgentFlagStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/BSA_AGENT_FLAG/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
		this.bsaAgentFlagStore.load();
		SerappsysIdsStore.load();
		Ext.apply(this, cfg);
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url : '${ctx}/${managePath}/serverssynchronous/osuser',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'appsysCode','serverIp','osUser','userId','dataType','appsysCodeHide','serverIpHide','osUserHide','userIdHide'],
			remoteSort : true,
			sortInfo : {
				field : 'appsysCode',
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 100
			}
		});
		//加载数据源
		//gridStore.load();
		// 实例化数据列表组件

		this.grid = new Ext.grid.GridPanel( {
			id : 'osUserListGridPanel',
			region : 'center',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			store : gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(), csm, 
				{header : '<fmt:message key="toolbox.appsys_code" />', dataIndex : 'appsysCode', renderer:this.SerappsysIdsStoreone,scope : this,sortable : true},
				{header : '<fmt:message key="property.serverIp" />', dataIndex : 'serverIp', sortable : true},
				{header : '<fmt:message key="property.osUser" />', dataIndex : 'osUser', sortable : true},
				{header : '<fmt:message key="property.userId" />', dataIndex : 'userId', sortable : true,renderer : this.userStoreone,scope : this},
				{header : '<fmt:message key="property.dataType" />', dataIndex : 'dataType', sortable : true   , 
					renderer : function(value, metadata, record, rowIndex, colIndex, store){
						if(value.indexOf('A') != -1){
							return value.replace('A','自动同步');
						}
						if(value.indexOf('H') != -1){
							return value.replace('H','手工维护');
						}
					}   
				},
				{header : '<fmt:message key="property.appsysCode" />', dataIndex : 'appsysCodeHide', sortable : true,hidden: true},
				{header : '<fmt:message key="property.serverIp" />', dataIndex : 'serverIpHide', sortable : true,hidden: true},
				{header : '<fmt:message key="property.osUser" />', dataIndex : 'osUserHide', sortable : true,hidden: true},
				{header : '<fmt:message key="property.userId" />', dataIndex : 'userIdHide', sortable : true,hidden: true}
				
	  		
	  		],
	  		
			// 定义按钮工具条
			tbar : new Ext.Toolbar( {
				items : [ '-' ]
			}),
			// 定义分页工具条
			bbar : new Ext.PagingToolbar( {
				store : gridStore,
				displayInfo : true,
				pageSize : 100,
				buttons : [ '-', {
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				} ]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView

			}
		
		});

		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			id : 'serversosuserFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 110,
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
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [ 
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
					store : SerappsysIdsStore,
					displayField : 'appsysName',
					valueField : 'appsysCode',
					name : 'appsysCode',
					hiddenName:'appsysCode',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						 beforequery : function(e){
							var combo = e.combo;
							combo.collapse();
							 if(!e.forceAll){
								var input = e.query.toUpperCase();
								var regExp = new RegExp('.*' + input + '.*');
								combo.store.filterBy(function(record, id){
									var text = record.get(combo.displayField);
									return regExp.test(text);
								}); 
								combo.restrictHeight();
								combo.expand();
								return false;
							   }
						 }
					}
				},
				{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.serverIp" />',
					name : 'serverIp'
				},{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.osUser" />',
					name : 'osUser'
				},{
				    xtype : 'textfield',
					fieldLabel : '<fmt:message key="property.userId" />',
					name : 'userId'
				}
			],
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

		// 设置基类属性
		OsUserList.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ this.form, this.grid ]
		});
	},
	
	SerappsysIdsStoreone : function(value) {

		var index = SerappsysIdsStore.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return SerappsysIdsStore.getAt(index).get('appsysName');
		}
	},
	
	userStoreone : function(value) {

		var index = this.userStore.find('username', value);
		if (index == -1) {
			return value;
		} else {
			return this.userStore.getAt(index).get('name');
		}
	},
	
	
	
	doExcel : function() {
		if(this.grid.getStore().getCount()>0){
			window.location = '${ctx}/${managePath}/serverssynchronous/osuser_excel.xls';
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '没有数据,不可导出',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
		
	},
	// 查询事件
	doFind : function() {
		//alert(this.form.getForm().getValues())
		Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
		this.grid.getStore().load();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 新建事件
	doCreate : function() {
		app.loadTab('SERVEROSUSER_CREATE',
						'<fmt:message key="button.create" />',
						'${ctx}/${managePath}/serverssynchronous/createOsUser');

	},
	
	// 查看事件
	doView : function() {
		var record = this.grid.getSelectionModel()
				.getSelected();
		var params = {
				osUser : record.data.osUserHide,
				appsysCode : record.data.appsysCodeHide,
				serverIp :record.data.serverIpHide,
				userId :record.data.userIdHide
		};
		app.loadTab('SERVEROSUSER_VIEW','<fmt:message key="button.view" /><fmt:message key="title.list" />',
				'${ctx}/${managePath}/serverssynchronous/viewOsUuser',params);
	},
	// 修改事件
	doEdit : function() {
		if (this.grid.getSelectionModel().getCount() == 1) {
			var record = this.grid.getSelectionModel()
					.getSelected();
			var params = {
					osUser : record.data.osUserHide,
					appsysCode : record.data.appsysCodeHide,
					serverIp :record.data.serverIpHide,
					userId :record.data.userIdHide
			};
			app.loadTab(
							'SERVEROSUSER_EDIT',
							'<fmt:message key="button.edit" />',
							'${ctx}/${managePath}/serverssynchronous/editOsUuser',
							params);
		} else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.only" />',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}
	},
	
	
	// sump信息获取
	doSump : function() {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.confirm.to.brpm" />',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(btn) {
				if(btn == 'ok'){
					app.mask.show();
				Ext.Ajax.request({
					url : '${ctx}/${managePath}/serverssynchronous/sump',
					method : 'POST',
					scope : this,
					timeout : 1800000 ,
					success : this.sysSuccess,
					disableCaching : true
					
				});
				}
			}
		});

	},
	
	
	//同步成功
 	sysSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			var message = Ext.decode(response.responseText).message;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.sys.successful" />'+'<br>'+decodeURIComponent(Ext.decode(response.responseText).error) + message,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					if(btn =='ok'){
						gridStore.load();
						var params = {
								Path : encodeURI(decodeURIComponent(Ext.decode(response.responseText).Path))
							};
							if ("0"!=Ext.decode(response.responseText).errNum) {
								app.loadWindow('${ctx}/${managePath}/serverssynchronous/errorlist',params);
							}
					}
				}
			});
		}
	},
	// 删除事件
	doDelete : function() {
		if (this.grid.getSelectionModel().getCount() > 0) {
			var records = this.grid.getSelectionModel()
					.getSelections();
			
			var osUsers = new Array();
			var appsysCodes = new Array();
			var serverIps = new Array();
			var userIds=new Array();
			for ( var i = 0; i < records.length; i++) {
				osUsers[i]= records[i].data.osUserHide;
				appsysCodes[i]= records[i].data.appsysCodeHide;
				serverIps[i]= records[i].data.serverIpHide;
				userIds[i]= records[i].data.userIdHide;
			}

			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.confirm.to.delete" />',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								app.mask.show();

								Ext.Ajax.request({
											url : '${ctx}/${managePath}/serverssynchronous/deleteOsUser',
											scope : this,
											success : this.deleteSuccess,
											failure : this.deleteFailure,
											params : {
												osUsers : osUsers,
												appsysCodes : appsysCodes,
												serverIps : serverIps,
												userIds : userIds,
												_method : 'delete'
											}
										});
							}
						}
					});
		} else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.at.least" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}
	},

	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg
				.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.delete.failed" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
	},
	// 删除成功回调方法
	deleteSuccess : function(response, options) {
		
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:'
								+ error,
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		} else if (Ext.decode(response.responseText).success == true) {
			this.grid.getStore().reload();// 重新加载数据源			
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.successful" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
		}
	}
	
	
	
	
});

var osUserList = new OsUserList();
</script>

<sec:authorize access="hasRole('OSUSER_CREATE')">
<script type="text/javascript">
osUserList.grid.getTopToolbar().add({
	iconCls : 'button-add',
	text : '<fmt:message key="button.add" />',
	scope : osUserList,
	handler : osUserList.doCreate
	},'-');
</script>
</sec:authorize>

<%-- <sec:authorize access="hasRole('OSUSER_EDIT')">
	<script type="text/javascript">
	osUserList.grid.getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="button.edit" />',
		scope : osUserList,
		handler : osUserList.doEdit
	}, '-');
</script>
</sec:authorize> --%>



<sec:authorize access="hasRole('OSUSER_DELETE')">
	<script type="text/javascript">
	osUserList.grid.getTopToolbar().add({
		iconCls : 'button-delete',
		text : '<fmt:message key="button.delete" />',
		scope : osUserList,
		handler : osUserList.doDelete
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SYSTEM_SUMP_SYNC')">
<script type="text/javascript">
osUserList.grid.getTopToolbar().add({
	iconCls : 'button-sync',
	text : '<fmt:message key="button.doSump" />',
	scope : osUserList,
	handler : osUserList.doSump
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
Ext.getCmp("MarOsUser").add(osUserList);
Ext.getCmp("MarOsUser").doLayout();
</script>

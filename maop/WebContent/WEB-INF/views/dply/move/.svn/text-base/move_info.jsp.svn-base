<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var dplyExcuteStatusAppsysCodeStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});
dplyExcuteStatusAppsysCodeStroe.load(); 

this.sysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
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
this.sysIdsStore.load();

this.envRequestStartStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/dplyrequestinfo/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
this.envRequestStartStroe.load(); 

this.moveStatusStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/MOVE_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.moveStatusStore.load();

this.operateTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/OPERATE_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.operateTypeStore.load();

this.operateSourceStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/OPERATE_SOURCE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.operateSourceStore.load(); 

var grid ;
setInterval(function(){
	grid.getStore().reload();
}, 20000);

//定义列表
DplyExcuteStatusList = Ext.extend(Ext.Panel, {
    gridStore : null,// 数据列表数据源
    form : null,// 查询表单组件
    tabIndex : 0,// 查询表单组件Tab键顺序
    csm : null,// 数据列表选择框组件
    constructor : function(cfg) {// 构造方法
		csm = new Ext.grid.CheckboxSelectionModel();
        Ext.apply(this, cfg);
        // 实例化数据列表数据源
        this.gridStore = new Ext.data.JsonStore( {
            proxy : new Ext.data.HttpProxy( {
                method : 'POST',
                url : '${ctx}/${managePath}/moveexport/info',
                disableCaching : false
            }),
            autoDestroy : true,
            root : 'data',
            totalProperty : 'count',
            fields : ['entryId','appsysCode','userId','excuteStartTime','excuteEndTime','moveStatus','operateType','operateSource','operateLog','environment'],
            remoteSort : true,
            baseParams : {
                start : 0,
                limit : 100
            }
        });
        this.gridStore.load(); 
        // 实例化数据列表组件
        grid = new Ext.grid.GridPanel( {
            id : 'DplySystemLogIndexListGridPanel',
            region : 'center',
            border : false,
            loadMask : true,
            title : '<fmt:message key="title.list" />',
            columnLines : true,
            viewConfig : {
                forceFit : false
            },
            store : this.gridStore,
            // 列定义			sm : csm,
            columns : [ new Ext.grid.RowNumberer(),csm,
                        {
							header : '<fmt:message key="dplyRequestInfo.requestStatus" />',
							dataIndex : 'moveStatus',
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
                        {header : '<fmt:message key="message.excute.status.entryId" />', dataIndex : 'entryId', sortable : true,hidden : true},
                        {header : '<fmt:message key="message.excute.status.operateSource" />', dataIndex : 'operateSource', sortable : true, width : 200},
                        {header : '<fmt:message key="dplyRequestInfo.environment" />', dataIndex : 'environment',renderer:this.RequestEnvironmentStoreone, sortable : true, width : 200}, 
                        {header : '<fmt:message key="message.excute.status.operateType" />', dataIndex : 'operateType', sortable :  true},
                        {header : '<fmt:message key="message.excute.status.operateLog" />', dataIndex : 'operateLog', sortable : true, width : 200},
                        {header : '<fmt:message key="message.excute.status.appsysCode" />', dataIndex : 'appsysCode', renderer:this.dplyExcuteStatusAppsysCodeStroeone,scope : this,sortable : true, width : 200},
                        {header : '<fmt:message key="message.excute.status.userId" />', dataIndex : 'userId', sortable : true},
                        {header : '<fmt:message key="message.excute.status.excuteStartTime" />', dataIndex : 'excuteStartTime', sortable : true, width : 200},
                        {header : '<fmt:message key="message.excute.status.excuteEndTime" />', dataIndex : 'excuteEndTime', sortable :  true,width : 200}
                        ],
            // 定义按钮工具条
            tbar : new Ext.Toolbar( {
                items : [ '-' ]
            }),
            // 定义分页工具条
            bbar : new Ext.PagingToolbar( {
                store : this.gridStore,
                displayInfo : true ,
                pageSize : 100 
            }),
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			} 
        });
        // 实例化查询表单
        this.form = new Ext.FormPanel( {
            id : 'DplyExcuteStatusIndexFindFormPanel',
            region : 'east',
            title : '<fmt:message key="button.find" />',
            labelAlign : 'right',
            labelWidth : 80,
            buttonAlign : 'center',
            frame : true,
            split : true,
            width : 250,
            minSize : 250,
            maxSize : 250,
            autoScroll : true,
            collapsible : true,
            collapseMode : 'mini',
            border : false,
            defaults : {
                anchor : '100%',
                msgTarget : 'side'
            },
            // 定义查询表单组件
            items : [/* {
				xtype : 'combo',
				fieldLabel : '系统代码',
				store : dplyExcuteStatusAppsysCodeStroe,
				name : 'appsysCode',
				//id:'DplyExcuteStatusAppsysCode',
				hiddenName : 'appsysCode',
				displayField : 'appsysName',
				valueField : 'appsysCode',
				typeAhead : true,
				forceSelection  : true,
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true,
				allowBlank : true,
				emptyText : '请选择系统代码...',
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
           	}, */
           	{
				xtype : 'combo',
				fieldLabel:'<fmt:message key="dplyRequestInfo.appSysCd" />',
				store : sysIdsStore,
				name : 'appsysCode',
				id:'DplyExcuteStatusAppsysCode',
				displayField : 'appsysName',
				valueField : 'appsysCode',
				hiddenName : 'appsysCode',			
				mode: 'local',
				typeAhead: true,
				forceSelection : true,
			    triggerAction: 'all',
				allowBlank : false,
				tabIndex : this.tabIndex++,
				emptyText : '请选择系统代码...',
				listeners : {
					scope : this,
					select :function(){
						envRequestStartStroe.reload();
					},
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
				xtype : 'combo',
				fieldLabel : '<fmt:message key="dplyRequestInfo.environment" />',
				store : envRequestStartStroe,
				name : 'environment',
				hiddenName : 'environment',
				displayField : 'envName',
				valueField : 'env',
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true,
				allowBlank : true,
				emptyText : '请选择环境...',
				listeners : {
					select : function(combo, record, index){
						var envid = combo.value;
						var appsyscd = envid.substring(0, envid.indexOf('_'));
						Ext.getCmp("DplyExcuteStatusAppsysCode").setValue(appsyscd);
					},
					expand:function(combo){
						var appsyscdValue = Ext.getCmp('DplyExcuteStatusAppsysCode').getValue();
						if(appsyscdValue != ''){
							envRequestStartStroe.filter('env', appsyscdValue + '_', false, true);
						}
					}
				}
            },
           	{
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="message.excute.status.userId" />',
				name : 'userId',
				tabIndex : this.tabIndex++
			},
           	{
				xtype : 'datetimefield',
				fieldLabel : '<fmt:message key="message.excute.status.excuteStartTime" />',
				name : 'excuteStartTime',
				dateFormat :'Ymd',
				editable : false,
				timeFormat : 'H:i:s'
			},
			{
				xtype : 'datetimefield',
				fieldLabel : '<fmt:message key="message.excute.status.excuteEndTime" />',
				name : 'excuteEndTime',
				dateFormat :'Ymd',
				editable : false,
				timeFormat : 'H:i:s'
			}, 
               {
				xtype : 'combo',
				fieldLabel : '<fmt:message key="message.excute.status.moveStatus" />',
				id : 'DplyExcuteStatusMoveStatus',
				hiddenName : 'moveStatus',
				displayField : 'name',
				valueField : 'value',
				typeAhead : true,
				forceSelection  : true,
				store : moveStatusStore,
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true
			},
            {
				xtype : 'combo',
				fieldLabel : '<fmt:message key="message.excute.status.operateType" />',
				id : 'DplyExcuteStatusOperateType',
				hiddenName : 'operateType',
				displayField : 'name',
				valueField : 'value',
				typeAhead : true,
				forceSelection  : true,
				store : operateTypeStore,
				tabIndex : this.tabIndex++,
				mode : 'local',
				triggerAction : 'all',
				editable : true
			}], 
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
        // 设置基类属性        DplyExcuteStatusList.superclass.constructor.call(this, {
            layout : 'border',
            border : false,
            items : [  this.form,grid ]
        });
    },
    dplyExcuteStatusAppsysCodeStroeone : function(value) {
		var index = dplyExcuteStatusAppsysCodeStroe.find('appsysCode', value);
		if (index == -1) {
			return value;
		} else {
			return dplyExcuteStatusAppsysCodeStroe.getAt(index).get('appsysName');
		}
	},
	RequestEnvironmentStoreone : function(value) {
		if(value==''){
			return value;
		}
		var elist = value.split('_');
		var env = elist[1];
		if(env=='DEV'){
			return '开发('+value+')';
		}else if(env=='QA'){
			return '测试('+value+')';
		}else if(env=='PROV'){
			return '验证('+value+')';
		}else if(env=='PROD'){
			return '生产('+value+')';
		}else {
			return value;
		}
	},
    // 查询事件
    doFind : function() {
        Ext.apply(grid.getStore().baseParams, this.form.getForm().getValues());
        grid.getStore().load();
    },// 重置查询表单
    doReset : function() {
        this.form.getForm().reset();
    },
    doExport : function(){
        window.location = '${ctx}/${managePath}/moveexport/export.xls';//dplysystemlog
    },
    doView : function() {
		var record = grid.getSelectionModel().getSelected();
		var params = {
				entryId : record.get('entryId')
		};
		app.loadWindow('${ctx}/${managePath}/moveexport/view', params);
	} ,
	doEdit : function(){
		if (grid.getSelectionModel().getCount() > 0) {
			var records = grid.getSelectionModel().getSelections();
			var entryId = new Array();
			for ( var i = 0; i < records.length; i++) {
				entryId[i] = records[i].get('entryId');
			}
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="button.DplyExcuteStatus.edit.check" />',//<fmt:message key="button.DplyExcuteStatus.edit" />
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request({
							url : '${ctx}/${managePath}/moveexport/edit',
							scope : this,
							success : this.editSuccess,
							failure : this.editFailure,
							params : {
								entryId : entryId
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
	editFailure : function() {
		app.mask.hide();
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.DplyExcuteStatus.edit.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 删除成功回调方法
	editSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.DplyExcuteStatus.edit.failed" /><fmt:message key="error.code" />:'
								+ error,
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		} else if (Ext.decode(response.responseText).success == true) {
			grid.getStore().reload();// 重新加载数据源
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.DplyExcuteStatus.edit.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	changeMoveStatusValue : function(value, metadata, record, rowIndex, colIndex, store) {
		if(value == '完成'){
			return '<span style="color:blue;">' + value + '</span>';
			//metadata.css='x-grid-back-red';
			//return value;
		}else if(value == '失败'){
			return '<span style="color:red;">' + value + '</span>';
			//metadata.css='x-grid-back-red';
			//return value;
		}else if(value == '进行中'){
			return '<span style="color:green;">' + value + '</span>';
			//metadata.css='x-grid-back-red';
			//return value;
		}else if(value == '等待'){
			return '<span style="color:green;">' + value + '</span>';
			//metadata.css='x-grid-back-red';
			//return value;
		}else{
			return value;
		}
	}
});

    var DplyExcuteStatusList = new DplyExcuteStatusList();
    
</script>
<sec:authorize access="hasRole('DPLY_EXECUTE_STATUS_EDIT')">
<script type="text/javascript">
grid.getTopToolbar().add( {
	iconCls : 'button-edit',
	text : '<fmt:message key="button.DplyExcuteStatus.edit" />',
	scope : DplyExcuteStatusList,
	handler : DplyExcuteStatusList.doEdit
   },'-');
</script> 
</sec:authorize>
<script type="text/javascript">
Ext.getCmp("DplyExcuteStatus").add(DplyExcuteStatusList);
Ext.getCmp("DplyExcuteStatus").doLayout();
</script>


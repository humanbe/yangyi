<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var dplyFlag = 'dplyFlag';
var checkFlag = 'checkFlag';
var toolFlag = 'toolFlag';
var csm;
//应用系统查询下拉菜单
var userAppAssignAPPsysIdsStore = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNames4NoDelHasAop',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});

//复选框选中事件
function setChecked(rowIndex,type){
	var grid = Ext.getCmp('userAppAssignGridPanel');
	var record = grid.getStore().getAt(rowIndex);
	record.set(type,'1');
};
//复选框取消选中事件
function setUnChecked(rowIndex,type){
	var grid = Ext.getCmp('userAppAssignGridPanel');
	var record = grid.getStore().getAt(rowIndex);
	record.set(type,'0');
};

//定义角色分配列表
AppAssignList = Ext.extend(Ext.grid.GridPanel, {
	gridStore : null,// 数据列表数据源
	csm : null,// 数据列表选择框组件
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		userAppAssignAPPsysIdsStore.load();
		// 实例化数据列表选择框组件
		csm = new Ext.grid.CheckboxSelectionModel({
			handleMouseDown : Ext.emptyFn,
			listeners : {
				//复选框被取消选中时触发
				'rowdeselect' : function(selectionModel,rowIndex,record) {
					record.set('dplyFlag','0');
					record.set('checkFlag','0');
					record.set('toolFlag','0');
				}
			}
		});

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'GET',
				url : '${ctx}/${frameworkPath}/user/app/${param.username}',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'apps',
			fields : [ 'id','appsysCode','name','checked','appType','dplyFlag','checkFlag','toolFlag']
		});

		// 默认选中数据
	    this.gridStore.on('load', function(store) {
			var records = store.query('checked', true).getRange();
			this.getSelectionModel().selectRecords(records, false);
		}, this, {
			delay : 500
		}); 
		
	    // 复选框被选中时触发事件
	    this.gridStore.on('load', function(store) {
			csm.on('rowselect', function(selectionModel,rowIndex,record) {
				record.set('dplyFlag','1');
				record.set('checkFlag','1');
				record.set('toolFlag','1');
			}, this, {
				delay : 500
			});
		}, this, {
			delay : 500
		});

		// 设置基类属性
		AppAssignList.superclass.constructor.call(this, {
			id : 'userAppAssignGridPanel',	
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : csm,

			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(),csm, {
				header : '<fmt:message key="property.appsyscd" />',
				dataIndex : 'id',
				hidden : true
			}, {
				header : '<fmt:message key="property.appsyscd" />',
				dataIndex : 'appsysCode',
				width : 100,
				sortable : true
			}, {
				id : 'name',
				header : '<fmt:message key="property.appsystemname" />',
				dataIndex : 'name',
				width : 240,
				sortable : true
			}, {
				header : '同步系统类型',
				dataIndex : 'appType',
				width : 80,
				sortable : true
			}, {
				header : '应用发布',
				dataIndex : 'dplyFlag',
				align : 'center',
				scope : this,
				renderer : this.renderDplyColumn
			}, {
				header : '巡检',
				dataIndex : 'checkFlag',
				align : 'center',
				scope : this,
				renderer : this.renderCheckColumn
			}, {
				header : '工具箱',
				dataIndex : 'toolFlag',
				align : 'center',
				scope : this,
				renderer : this.renderToolColumn
			}],
			tbar : new Ext.Toolbar( {
				items : [ '-', {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.assignApp
				}, '-' , {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="property.appsystemname" />',
					store : userAppAssignAPPsysIdsStore,
					displayField : 'appsysName',
					name : 'appsysName',
					mode: 'local',
					typeAhead: true,
				    triggerAction: 'all',
					tabIndex : this.tabIndex++,
					listeners : {
						 'beforequery' : function(e){
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
							},
							'select' : function(combo, record, index){
								var store = Ext.getCmp('userAppAssignGridPanel').getStore();
								var rowNum = 0;
								for(var i = 0; i < store.getCount(); i++){
									if(record.get('appsysName').indexOf(store.getAt(i).get('name')) != -1){
										rowNum = i;
										break;
									}
								}
								Ext.getCmp('userAppAssignGridPanel').getView().focusRow(rowNum);
								Ext.getCmp('userAppAssignGridPanel').getView().getRow(rowNum).style.backgroundColor='#FFD700';
							}
					}
				}]
			})
		});

		// 加载列表数据
		this.gridStore.load();
	},
	
	// 渲染应用发布列
	renderDplyColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		if(value!=null && value=='1'){
			return '<input type="checkbox" style="height:13px" checked onclick="setUnChecked('+rowIndex +','+dplyFlag+')" />';
		}else{
			return '<input type="checkbox" style="height:13px" onclick="setChecked('+rowIndex +','+dplyFlag+')" />';
		}
	},
	// 渲染巡检列
	renderCheckColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		if(value!=null && value=='1'){
			return '<input type="checkbox" style="height:13px" checked onclick="setUnChecked('+rowIndex +','+checkFlag+')" />';
		}else{
			return '<input type="checkbox" style="height:13px" onclick="setChecked('+rowIndex +','+checkFlag+')" />';
		}
	},
	// 渲染工具箱列
	renderToolColumn : function(value, metadata, record, rowIndex, colIndex, store) {
		if(value!=null && value=='1'){
			return '<input type="checkbox" style="height:13px" checked onclick="setUnChecked('+rowIndex +','+toolFlag+')" />';
		}else{
			return '<input type="checkbox" style="height:13px" onclick="setChecked('+rowIndex +','+toolFlag+')" />';
		}
	},
	
	// 关联资源信息
	assignApp : function() {
		app.mask.show();
		var ids = new Array();
		var dplyFlags = new Array();
		var checkFlags = new Array();
		var toolFlags = new Array();
		this.gridStore.each(function(item) {
			
			var dplyFlag = item.data.dplyFlag ;
			var checkFlag = item.data.checkFlag ;
			var toolFlag = item.data.toolFlag ;
			if(dplyFlag==1 || checkFlag==1 || toolFlag==1 ){
				
				ids.push(item.data.id);
				if(dplyFlag!=null && dplyFlag!=''){
					dplyFlags.push(dplyFlag);
				}else{
					dplyFlags.push("0");
				}
				
				if(checkFlag!=null && checkFlag!=''){
					checkFlags.push(checkFlag);
				}else{
					checkFlags.push("0");
				}
				if(toolFlag!=null && toolFlag!=''){
					toolFlags.push(toolFlag);
				}else{
					toolFlags.push("0");
				}
				
			}
			
		});
		Ext.Ajax.request( {
			url : '${ctx}/${frameworkPath}/user/apps',
			timeout : 999999,
			method : 'POST',
			scope : this,
			success : this.assignSuccess,
			failure : this.assignFailure,
			params : {
				username : '${param.username}',
				ids : ids,
				dplyFlags : dplyFlags,
				checkFlags : checkFlags,
				toolFlags : toolFlags
			}
		});
	},
	// 关联资源操作成功回调方法
	assignSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} else if (Ext.decode(response.responseText).success == true) {
			var checkMsg = Ext.decode(response.responseText).checkMsg;
			//Ext.getCmp('userAppAssignGridPanel').getStore().reload();
			if(checkMsg != ""){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />'+'<br>'
							+'<fmt:message key="message.import.successful.sync.checkmsg" />'+'<br>' //详细信息
							+checkMsg,
					minWidth : 450,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}else{
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		}
	},
	assignFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

app.window.get(0).add(new AppAssignList());
app.window.get(0).doLayout();
</script>

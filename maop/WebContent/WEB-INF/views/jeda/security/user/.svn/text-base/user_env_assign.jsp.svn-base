<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//定义角色分配列表
EnvAssignList = Ext.extend(Ext.grid.GridPanel, {
	gridStore : null,// 数据列表数据源
	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);

		//userEnvAssignAPPsysIdsStore.load();
		
		// 实例化数据列表选择框组件		this.csm = new Ext.grid.CheckboxSelectionModel({handleMouseDown : Ext.emptyFn});

		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'GET',
				url : '${ctx}/${frameworkPath}/user/env/${param.username}',
				disableCaching : true
			}),
			autoDestroy : true,
			root : 'envs',
			fields : [ 'id','envName', 'checked']
		});

		// 默认选中数据
		this.gridStore.on('load', function(store) {
			var records = store.query('checked', true).getRange();
			this.getSelectionModel().selectRecords(records, false);
		}, this, {
			delay : 500
		}); 

		// 设置基类属性
		EnvAssignList.superclass.constructor.call(this, {
			id : 'userEnvAssignGridPanel',
			border : false,
			loadMask : true,
			title : '<fmt:message key="title.list" />',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			sm : this.csm,

			autoExpandColumn : 'envName',
			columns : [ new Ext.grid.RowNumberer(), this.csm,  {
				header : 'id',
				dataIndex : 'id',
				hidden : true
			},  {
				header : '环境',
				dataIndex : 'envName',
				width : 100,
				sortable : true
			}],
			tbar : new Ext.Toolbar( {
				items : [ '-', {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					scope : this,
					handler : this.assignEnv
				}/* , '-' , {
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
									if(record.get('appsysName') == store.getAt(i).get('name')){
										rowNum = i;
										break;
									}
								}
								Ext.getCmp('userAppAssignGridPanel').getView().focusRow(rowNum);
								Ext.getCmp('userAppAssignGridPanel').getView().getRow(rowNum).style.backgroundColor='#FFD700';
							}
					}
				} */]
			})
		});

		// 加载列表数据
		this.gridStore.load();
	} ,
	// 关联资源信息
	assignEnv : function() {
		app.mask.show();
		var records = this.getSelectionModel().getSelections();
		var ids = new Array();
		for ( var i = 0; i < records.length; i++) {
			ids[i] = records[i].get("id");
		}

		Ext.Ajax.request( {
			url : '${ctx}/${frameworkPath}/user/envs',
			method : 'POST',
			scope : this,
			success : this.assignSuccess,
			failure : this.assignFailure,
			params : {
				username : '${param.username}',
				ids : ids
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
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
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

app.window.get(0).add(new EnvAssignList());
app.window.get(0).doLayout();
</script>

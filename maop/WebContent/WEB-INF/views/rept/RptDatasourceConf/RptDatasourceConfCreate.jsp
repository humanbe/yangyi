<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	DataSourceCreatForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
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
			
			//获取系统代码列表数据
			this.sysIdsStore = new Ext.data.Store({
				proxy: new Ext.data.HttpProxy({
					url: '${ctx}/${managePath}/dayrptmanage/browseDayRptAplCode',
					method : 'GET'
				}),
				reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
			});
			this.sysIdsStore.load();
			
			//数据字典
			this.datasourceStore= new Ext.data.JsonStore(
			{
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/DATASOURCE_CONF/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.datasourceStore.load();
			
			this.sourceStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${managePath}/rptdatasourceconf/getDatasource', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['value','name'])
					});
					this.sourceStore.load();
					this.sourceStore.on('beforeload', function(loader,node) {
						//使用查询条件系统代码文本框时用

						loader.baseParams.dataType = Ext.getCmp("cerateDataTypeId").getValue();
					}, this);
		
			// 设置基类属性
			DataSourceCreatForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${managePath}/rptdatasourceconf/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [ 
							{
								xtype : 'combo',
								fieldLabel : '应用系统编号',
								store : this.sysIdsStore,
								hiddenName : 'aplCode',
								displayField : 'displayField',
								valueField : 'valueField',
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
								xtype : 'combo',
								store : this.datasourceStore,
								id : 'cerateDataTypeId',
								fieldLabel : '采集数据类型',
								name : 'dataType',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'dataType',
								mode : 'local',
								typeAhead: true,
								triggerAction : 'all',
								forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								listeners : {
									scope : this,
									select : function(combo,record,index) {
										this.sourceStore.reload();
									}
								}
							},
							{
								xtype : 'combo',
								store : this.sourceStore,
								fieldLabel : '数据源地址',
								name : 'datasource',
								valueField : 'value',
								displayField : 'value',
								hiddenName : 'datasource',
								mode : 'local',
								typeAhead: true,
								forceSelection : true,
								triggerAction : 'all',
								editable : false,
								tabIndex : this.tabIndex++
							}
						],
				buttons : [ {
					text : '<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : this.doSave
				}, {
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
			
		
		},
		// 保存操作
		doSave : function() {
			this.getForm().submit({
				scope : this,
				success : this.saveSuccess,// 保存成功回调函数
				failure : this.saveFailure,// 保存失败回调函数
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('DATASOURCE_CREATE');
		},
		// 保存成功回调
		saveSuccess : function(form, action) {
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				fn : function() {
					app.closeTab('DATASOURCE_CREATE');// 关闭新建页面
					 Ext.getCmp("DataSourceGridPanelId").getStore().reload();
				}
			});

		},
		// 保存失败回调
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});

	var DataSourceCreatForm = new DataSourceCreatForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("DATASOURCE_CREATE").add(DataSourceCreatForm);
	// 刷新Tab页布局
	Ext.getCmp("DATASOURCE_CREATE").doLayout();
</script>
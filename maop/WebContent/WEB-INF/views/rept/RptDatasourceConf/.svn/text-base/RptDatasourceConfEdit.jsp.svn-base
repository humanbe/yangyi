<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	DataSourceViewForm = Ext.extend(Ext.FormPanel, {
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

						loader.baseParams.dataType = Ext.getCmp("editDataTypeId").getValue();
					}, this);
		
			// 设置基类属性
			DataSourceViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${managePath}/rptdatasourceconf/edit',
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
								readOnly : true,
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
								id : 'editDataTypeId',
								fieldLabel : '采集数据类型',
								name : 'dataType',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'dataType',
								mode : 'local',
								triggerAction : 'all',
								forceSelection : true,
								editable : true,
								tabIndex : this.tabIndex++,
								readOnly : true
							},
							{
								xtype : 'combo',
								id : 'editDatasourceId',
								store : this.sourceStore,
								fieldLabel : '数据源地址',
								name : 'datasource',
								valueField : 'value',
								displayField : 'value',
								hiddenName : 'datasource',
								mode : 'local',
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
				},  {
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
		 	this.load({
				url : '${ctx}/${managePath}/rptdatasourceconf/view',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					aplCode:'${param.aplCode}',
					dataType:'${param.dataType}'
				}
			}); 
		
		},// 保存操作
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
			app.closeTab('DATASOURCE_EDIT');
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
					app.closeTab('DATASOURCE_EDIT');// 关闭新建页面
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
		},
		// 数据加载失败回调
		loadFailure : function(form, action) {
			app.mask.hide();
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		// 数据加载成功回调
		loadSuccess : function(form, action) {
			this.sourceStore.baseParams.dataType = '${param.dataType}';
			this.sourceStore.reload();
			app.mask.hide();
		}
	});

	var DataSourceViewForm = new DataSourceViewForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("DATASOURCE_EDIT").add(DataSourceViewForm);
	// 刷新Tab页布局
	Ext.getCmp("DATASOURCE_EDIT").doLayout();
</script>
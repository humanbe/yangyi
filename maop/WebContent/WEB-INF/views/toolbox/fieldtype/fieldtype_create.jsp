<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	var field_type_oneStore ;
	FieldTypeCreateForm = Ext.extend(Ext.FormPanel, {
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
			// 实例化性别数据源
		this.field_type_directionStore= new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/FIELD_TYPE_DIRECTION/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.field_type_directionStore.load();
		
		field_type_oneStore = new Ext.data.Store(
				{
					proxy: new Ext.data.HttpProxy({
						url : '${ctx}/${appPath}/FieldTypeController/getFieldTypeone', 
						method: 'POST'
					}),
					reader: new Ext.data.JsonReader({}, ['field_type_one'])
				});
				field_type_oneStore.load();
				field_type_oneStore.on('beforeload', function(loader,node) {
					//使用查询条件系统代码文本框时用
					loader.baseParams.fieldType = Ext.getCmp("field_type_directionId").getValue();
				}, this);
				this.field_type_twoStore = new Ext.data.Store(
						{
							proxy: new Ext.data.HttpProxy({
								url : '${ctx}/${appPath}/FieldTypeController/getFieldTypetwo', 
								method: 'POST'
							}),
							reader: new Ext.data.JsonReader({}, ['field_type_two'])
						});
				this.field_type_twoStore.load();	
				this.field_type_twoStore.on('beforeload', function(loader,node) {
					//使用查询条件系统代码文本框时用
					loader.baseParams.fieldType = Ext.getCmp("field_type_directionId").getValue();
				}, this);
			// 设置基类属性

			FieldTypeCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${appPath}/FieldTypeController/fieldtypeCreate',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [ 
							{
								xtype : 'combo',
								fieldLabel : '分类方向',
								store : this.field_type_directionStore,
								displayField : 'name',
								valueField : 'value',
								id : 'field_type_directionId',
								name : 'field_type_direction',
								hiddenName:'field_type_direction',
								mode: 'local',
								editable : false,
								typeAhead: true,
								forceSelection : true,
							    triggerAction: 'all',
								tabIndex : this.tabIndex++,
								allowBlank : false,
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
									 },
								select : function(combo,record,index) {
									field_type_oneStore.reload();
									this.field_type_twoStore.reload();
									}
								}
							},
							{
								xtype : 'combo',
								store : field_type_oneStore,
								fieldLabel : '<fmt:message key="toolbox.field_type_one" />',
								name : 'field_type_one',
								valueField : 'field_type_one',
								displayField : 'field_type_one',
								hiddenName : 'field_type_one',
								mode : 'local',
								triggerAction : 'all',
								//forceSelection : true,
								editable : true,
								tabIndex : this.tabIndex++,
								allowBlank : false
							},
							{
								xtype : 'combo',
								store : this.field_type_twoStore,
								fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
								name : 'field_type_two',
								valueField : 'field_type_two',
								displayField : 'field_type_two',
								hiddenName : 'field_type_two',
								mode : 'local',
								triggerAction : 'all',
								//forceSelection : true,
								editable : true,
								tabIndex : this.tabIndex++
							},{
							    xtype : 'textfield',
								fieldLabel :  '<fmt:message key="toolbox.field_type_three" />',
								name : 'field_type_three'
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
			app.closeTab('FIELDTYPE_CREATE');
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
					app.closeTab('FIELDTYPE_CREATE');// 关闭新建页面
					 Ext.getCmp("FieldTypeListGridPanel").getStore().reload();
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

	var FieldTypeCreateForm = new FieldTypeCreateForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("FIELDTYPE_CREATE").add(FieldTypeCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("FIELDTYPE_CREATE").doLayout();
</script>
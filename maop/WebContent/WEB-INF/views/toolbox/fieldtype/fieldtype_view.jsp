<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	FieldTypeViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 实例化性别数据源
		this.field_type_directionStore= new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/FIELD_TYPE_DIRECTION/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.field_type_directionStore.load();
		
		
			// 设置基类属性

			FieldTypeViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
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
								name : 'field_type_direction',
								hiddenName:'field_type_direction',
								mode: 'local',
								typeAhead: true,
								readOnly:true,
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
								fieldLabel : '一级分类',
								readOnly:true,
								name : 'field_type_one'
							},{
							    xtype : 'textfield',
								fieldLabel : '二级分类',
								readOnly:true,
								name : 'field_type_two'
							},{
							    xtype : 'textfield',
								fieldLabel : '三级分类',
								readOnly:true,
								name : 'field_type_three'
							} 
						],
				buttons : [  {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});

			// 加载表单数据
		 	this.load({
				url : '${ctx}/${appPath}/FieldTypeController/fieldtypeView',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					
					field_id:'${param.field_id}'
				}
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
			app.closeTab('FIELDTYPE_VIEW');
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
					app.closeTab('FIELDTYPE_VIEW');// 关闭新建页面
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
			app.mask.hide();
		}
	});

	var FieldTypeViewForm = new FieldTypeViewForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("FIELDTYPE_VIEW").add(FieldTypeViewForm);
	// 刷新Tab页布局
	Ext.getCmp("FIELDTYPE_VIEW").doLayout();
</script>
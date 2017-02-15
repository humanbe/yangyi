<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	AppViewEditForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			
			Ext.apply(this, cfg);
			// 实例化性别数据源
			// 设置基类属性

			AppViewEditForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				url : '${ctx}/${frameworkPath}/config/app_view/aViewEdit',
				autoScroll : true,
				defaults : {
					anchor : '90%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [{
					xtype:'textfield',
					hidden:true,
					name:'avd_id',
					value:'${param.avd_id}'
				},{
					xtype:'textfield',
					hidden:true,
					name:'avd_rel_id',
					value:'${param.avd_rel_id}'
				},
				{
					xtype:'combo',
					fieldLabel : '功能类型',								
					name : 'avd_type',
					store:new Ext.data.SimpleStore({
						fields:['value','text'],
						data:[['1','工具箱'],['2','日常巡检'],['3','应用发布']]
					}),
					emptyText:'请选择',
					mode:'local',
					triggerAction:'all',
					valueField:'value',
					displayField:'text',
					editable : false,
					allowBlank : false
				},{
					xtype:'textarea',
					fieldLabel:'概述',
					name:'avd_simpdesc',
					id:'avd_simpdesc',
					hieght:100
				},{
					xtype:'textarea',
					fieldLabel:'详述',
					name:'avd_descdetail',
					id:'avd_descdetail',
					height:200,
					autoScroll : true
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

			// 加载表单数据
		 	this.load({
				url : '${ctx}/${frameworkPath}/config/app_view/aViewSubView',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					avd_id:'${param.avd_id}',
					avd_rel_id:'${param.avd_rel_id}'
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
			app.closeWindow();
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
					app.closeWindow();
				 Ext.getCmp("AppViewListGridPanel").getStore().reload();
				 Ext.getCmp("app_main_grid").getStore().reload();
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

	var AppViewEditForm = new AppViewEditForm();
</script>
<script type="text/javascript">
	app.window.get(0).add(AppViewEditForm);
	app.window.get(0).doLayout();
</script>
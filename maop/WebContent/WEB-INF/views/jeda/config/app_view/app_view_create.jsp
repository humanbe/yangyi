<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var subTableSeq='';

	//定义新建表单
	AppViewCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			
			Ext.apply(this, cfg);
			// 实例化性别数据源
			// 设置基类属性
			this.SubSeq = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${frameworkPath}/config/app_view/subSeqFind', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['avd_id'])
						
					});
					this.SubSeq.load();
					this.SubSeq.on('load',function(){
						subTableSeq=this.SubSeq.data.items[0].data.avd_id;
						Ext.getCmp("avd_id_create").setValue(subTableSeq);
					},this); 
					
	
			AppViewCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				url : '${ctx}/${frameworkPath}/config/app_view/aViewCreate',
				autoScroll : true,
				defaults : {
					anchor : '95%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [{
					xtype:'textfield',
					hidden:true,
					name:'avd_id',
					id:'avd_id_create'
				},{
					xtype:'textfield',
					hidden:true,
					name:'avd_rel_id',
					id : 'avd_rel_id_create',
					value:'${param.rel_id}'
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
					allowBlank : false,
					id :'avd_type_create'
				},{
					xtype:'textarea',
					fieldLabel:'概述',
					name:'avd_simpdesc',
					id:'avd_simpdesc_create',
					hieght:100
				},{
					xtype:'textarea',
					fieldLabel:'详述',
					name:'avd_descdetail',
					id:'avd_descdetail_create',
					height:200
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
					
					 Ext.getCmp("app_main_grid").getStore().reload();
					 Ext.getCmp("AppViewListGridPanel").getStore().reload();
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

	var AppViewCreateForm = new AppViewCreateForm();
</script>
<script type="text/javascript">
	app.window.get(0).add(AppViewCreateForm);
	app.window.get(0).doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	AppViewViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			
			Ext.apply(this, cfg);
			// 实例化性别数据源
			// 设置基类属性

			AppViewViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '70%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [{
					xtype:'textfield',
					fieldLabel : '名称',								
					name : 'aview_name',
					readOnly:true,
					style  : 'background : #F0F0F0' 
				},
				{
					xtype : 'textfield',
					fieldLabel : '发布人员',
					name : 'aview_oper',
					readOnly:true,
					style  : 'background : #F0F0F0'
				},{
					xtype:'textfield',
					fieldLabel : '功能类型',								
					name : 'avd_type',
					readOnly:true,
					style  : 'background : #F0F0F0' 
				},{
					xtype:'textfield',
					fieldLabel:'发布时间',
					name:'aview_time',
					readOnly:true,
					style  : 'background : #F0F0F0'
				},{
					xtype:'textarea',
					fieldLabel:'概述',
					name:'avd_simpdesc',
					hieght:100,
					readOnly:true,
					style  : 'background : #F0F0F0'
				},{
					xtype:'textarea',
					fieldLabel:'详述',
					name:'avd_descdetail',
					height:200,
					autoScroll : true,
					readOnly:true,
					style  : 'background : #F0F0F0'
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
				url : '${ctx}/${frameworkPath}/config/app_view/aViewView',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					avd_rel_id:'${param.avd_rel_id}',
					avd_id:'${param.avd_id}'
				}
			}); 
		},

		// 取消操作
		doCancel : function() {
			app.closeTab('APP_VIEW_VIEW');
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

	var AppViewViewForm = new AppViewViewForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("APP_VIEW_VIEW").add(AppViewViewForm);
	// 刷新Tab页布局
	Ext.getCmp("APP_VIEW_VIEW").doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	AppViewShow = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			
			Ext.apply(this, cfg);
			// 实例化性别数据源
			// 设置基类属性

			AppViewShow.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '95%',
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
					autoScroll : true,
					height:200,
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
				url : '${ctx}/${frameworkPath}/config/app_view/aViewDetail',
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
			app.closeWindow();
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

	var AppViewShow = new AppViewShow();
</script>
<script type="text/javascript">
	app.window.get(0).add(AppViewShow);
	app.window.get(0).doLayout();
</script>
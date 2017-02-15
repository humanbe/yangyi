<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

	//定义新建表单
	SysConfManageCreate = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 实例化性别数据源
             //数据字典
		this.sysConfTypeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/SYS_CONF_MANAGE_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
							});
		this.sysConfTypeStore.load();
		
			// 设置基类属性
			SysConfManageCreate.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url :'${ctx}/${managePath}/sysconfmanage/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [{
					xtype : 'combo',
					fieldLabel : '系统配置类型',
					store : this.sysConfTypeStore,
					displayField : 'name',
					valueField : 'value',
					name : 'sys_conf_type',
					hiddenName:'sys_conf_type',
					mode: 'local',
					typeAhead: true,
					forceSelection : true,
					allowBlank : false,
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
					fieldLabel : '系统配置编码',
					allowBlank : false,
					name : 'sys_conf_code'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置名称',
					allowBlank : false,
					name : 'sys_conf_name'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置值',
					allowBlank : false,
					name : 'sys_conf_value'
				},{
					xtype : 'textarea',
					fieldLabel :'系统配置描述',
					name : 'sys_conf_desc',
					height : 60,
					maxLength:500,
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
			app.closeTab('SYS_CONF_MANAGE_CREATE');
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
					app.closeTab('SYS_CONF_MANAGE_CREATE');// 关闭新建页面
					 Ext.getCmp("sysconfmanage_index").getStore().reload();
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

	var SysConfManageCreate = new SysConfManageCreate();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SYS_CONF_MANAGE_CREATE").add(SysConfManageCreate);
	// 刷新Tab页布局
	Ext.getCmp("SYS_CONF_MANAGE_CREATE").doLayout();
</script>
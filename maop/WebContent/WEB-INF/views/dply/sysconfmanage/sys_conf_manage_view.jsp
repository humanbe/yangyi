<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	SysConfManageView = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 实例化性别数据源

		this.sysConfTypeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/SYS_CONF_MANAGE_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
							});
		this.sysConfTypeStore.load();
			// 设置基类属性

			SysConfManageView.superclass.constructor.call(this, {
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
				items : [{
				    xtype : 'textfield',
					fieldLabel : '系统配置id',
					name : 'sys_conf_id',
					hidden: true
				},
				         {
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
					name : 'sys_conf_code'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置名称',
					name : 'sys_conf_name'
				},{
				    xtype : 'textfield',
					fieldLabel : '系统配置值',
					name : 'sys_conf_value'
				},{
					xtype : 'textarea',
					fieldLabel :'系统配置描述',
					name : 'sys_conf_desc',
					height : 60,
					maxLength:500,
					tabIndex : this.tabIndex++
				},{
				    xtype : 'textfield',
					fieldLabel : '创建人',
					name : 'creator',
					hidden: true
				},{
				    xtype : 'textfield',
					fieldLabel : '创建时间',
					name : 'created_time',
					hidden: true
				},{
				    xtype : 'textfield',
					fieldLabel : '修改人',
					name : 'modifier',
					hidden: true
				},{
				    xtype : 'textfield',
					fieldLabel : '修改时间',
					name : 'modifiled_time',
					hidden: true
				}],
				buttons : [{
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
			
			
			// 加载表单数据
		 	this.load({
				url : '${ctx}/${managePath}/sysconfmanage/view',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					sys_conf_id:'${param.sys_conf_id}'
				}
			}); 
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('SYS_CONF_MANAGE_VIEW');
		},
		// 数据加载成功回调
		loadSuccess : function(form, action) {
			app.mask.hide();
		}
	});

	var SysConfManageView = new SysConfManageView();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("SYS_CONF_MANAGE_VIEW").add(SysConfManageView);
	// 刷新Tab页布局
	Ext.getCmp("SYS_CONF_MANAGE_VIEW").doLayout();
</script>
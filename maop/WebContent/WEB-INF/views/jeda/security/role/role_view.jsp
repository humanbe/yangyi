<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	RoleViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		typeStore : null,
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 实例化类型数据源
			this.typeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/ROLE_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.typeStore.load();// 加载类型数据

			// 设置基类属性
			RoleViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="role.id" />',
					name : 'id',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="role.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'combo',
					store : this.typeStore,
					fieldLabel : '<fmt:message key="role.type" />',
					name : 'type',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="role.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					readOnly : true
				} ],
				buttons : [ {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doClose
				} ]
			});

			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/role/view/${param.id}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				success : this.loadSuccess,
				failure : this.loadFailure
			});
		},
		// 关闭操作
		doClose : function() {
			app.closeTab('view_role');
		},
		// 数据加载失败回调
		loadFailure : function(form, action) {
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
		}
	});

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("view_role").add(new RoleViewForm());
	// 刷新Tab页布局
	Ext.getCmp("view_role").doLayout();
</script>

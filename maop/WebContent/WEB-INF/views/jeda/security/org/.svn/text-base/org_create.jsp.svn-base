<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	OrgCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		categoryStore : null, // 类型数据源
		propertyStore : null, // 属性数据源
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 实例化类型数据源
			this.categoryStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/ORG_CATEGORY/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.categoryStore.load();// 加载类型数据

			// 实例化属性数据源
			this.propertyStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/ORG_PROPERTY/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.propertyStore.load();// 加载属性数据

			// 设置基类属性
			OrgCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/org/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="org.id" />',
					name : 'id',
					regex : /^[0-9]*$/,
					regexText : '<fmt:message key="error.input.number.only" />',
					minLength : 4,
					maxLength : 4,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="org.name" />',
					name : 'name',
					maxLength : 100,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="org.description" />',
					name : 'description',
					maxLength : 1000,
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="org.contact" />',
					name : 'contact',
					maxLength : 50,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="org.tel" />',
					name : 'tel',
					maxLength : 50,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="org.address" />',
					name : 'address',
					maxLength : 500,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'combo',
					store : this.categoryStore,
					fieldLabel : '<fmt:message key="org.category" />',
					name : 'category',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'category',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					store : this.propertyStore,
					fieldLabel : '<fmt:message key="org.property" />',
					name : 'property',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'property',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					maxLength : 10,
					allowBlank : true
				}, {
					xtype : 'hidden',
					name : 'enabled',
					value : true,
					hidden : true
				}, {
					xtype : 'hidden',
					name : 'parent',
					value : '${param.parent}',
					hidden : true
				} ],
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
			app.closeTab('add_org');
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
					app.closeTab('add_org');// 关闭新建页面
					var orgList = Ext.getCmp("orgList");// 获取列表组件
					// 若未被关闭,则刷新其数据源
					if (orgList != null) {
						orgList.grid.getStore().reload();
						var selectedNodePath = orgList.tree.getSelectionModel().getSelectedNode().getPath();
						orgList.tree.root.reload();
						//orgList.tree.expandAll();
						orgList.tree.selectPath(selectedNodePath);
					}
					var params = {
						id : action.result.id
					};

					// 打开查看页面
					app.loadTab('view_org', '<fmt:message key="button.view" /><fmt:message key="org" />', '${ctx}/${frameworkPath}/org/view', params);
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

	// 实例化新建表单,并加入到Tab页中
	Ext.getCmp("add_org").add(new OrgCreateForm());
	// 刷新Tab页布局
	Ext.getCmp("add_org").doLayout();
</script>

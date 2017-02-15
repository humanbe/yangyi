<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//编辑表单
OrgEditForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	categoryStore : null, // 类型数据源
	propertyStore : null, // 属性数据源
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		this.categoryStore = new Ext.data.JsonStore( {
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/ORG_CATEGORY/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.categoryStore.load();// 加载类型数据

		// 实例化属性数据源
		this.propertyStore = new Ext.data.JsonStore( {
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/ORG_PROPERTY/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.propertyStore.load();// 加载属性数据

		// 设置基类属性
		OrgEditForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${frameworkPath}/org/edit/${param.id}',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			items : [ {
				xtype : 'numberfield',
				fieldLabel : '<fmt:message key="org.id" />',
				name : 'id',
				tabIndex : this.tabIndex++,
				readOnly : true
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
				fieldLabel : '<fmt:message key="org.rank" />',
				name : 'rank',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'numberfield',
				fieldLabel : '<fmt:message key="column.order" />',
				name : 'order',
				maxLength : 10,
				tabIndex : this.tabIndex++,
				allowBlank : true
			}, {
				xtype : 'hidden',
				name : 'parent',
				value : '${param.parent}',
				hidden : true
			}, {
				xtype : 'hidden',
				name : 'version',
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

		// 加载表单数据
		this.load( {
			url : '${ctx}/${frameworkPath}/org/view/${param.id}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			failure : this.loadFailure
		});
	},
	// 保存操作
	doSave : function() {
		this.getForm().submit( {
			scope : this,
			success : this.saveSuccess,
			failure : this.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	// 取消操作
	doCancel : function() {
		app.closeTab('edit_org');
	},
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				app.closeTab('edit_org');
				var orgList = Ext.getCmp("orgList");

				if (orgList != null) {
					orgList.grid.getStore().reload();
					orgList.tree.root.reload();
					//orgList.tree.expandAll();
					var selectedNode = orgList.tree.getSelectionModel().getSelectedNode();
					if (selectedNode != null) {
						orgList.tree.selectPath(selectedNode.getPath());
					}
				}
				var params = {
					id : '${param.id}'
				};
				app.loadTab('view_org', '<fmt:message key="button.view" /><fmt:message key="org" />', '${ctx}/${frameworkPath}/org/view', params);

			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
});

//实例化编辑表单,并加入到Tab页中
Ext.getCmp("edit_org").add(new OrgEditForm());
// 刷新Tab页布局
Ext.getCmp("edit_org").doLayout();
</script>

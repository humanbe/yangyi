<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
OrgViewForm = Ext.extend(Ext.FormPanel, {
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
		OrgViewForm.superclass.constructor.call(this, {
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
				fieldLabel : '<fmt:message key="org.id" />',
				name : 'id',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.name" />',
				name : 'name',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textarea',
				fieldLabel : '<fmt:message key="org.description" />',
				name : 'description',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.contact" />',
				name : 'contact',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.tel" />',
				name : 'tel',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.address" />',
				name : 'address',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.category" />',
				name : 'category',
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'textfield',
				fieldLabel : '<fmt:message key="org.property" />',
				name : 'property',
				tabIndex : this.tabIndex++,
				readOnly : true
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
				tabIndex : this.tabIndex++,
				readOnly : true
			}, {
				xtype : 'checkbox',
				fieldLabel : '<fmt:message key="org.enabled" />',
				name : 'enabled',
				tabIndex : this.tabIndex++,
				disabled : true
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
		this.load( {
			url : '${ctx}/${frameworkPath}/org/view/${param.id}',
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
		app.closeTab('view_org');
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
	},
	// 数据加载成功回调
	loadSuccess : function(form, action) {
		var category = form.findField('category');
		var index = this.categoryStore.find('value', category.getValue());
		if (index == -1) {

		} else {
			category.setValue(this.categoryStore.getAt(index).get('name'));
		}

		var property = form.findField('property');
		var index = this.propertyStore.find('value', property.getValue());
		if (index == -1) {

		} else {
			property.setValue(this.propertyStore.getAt(index).get('name'));
		}
	}
});

// 实例化查看表单,并加入到Tab页中
Ext.getCmp("view_org").add(new OrgViewForm());
// 刷新Tab页布局
Ext.getCmp("view_org").doLayout();
</script>

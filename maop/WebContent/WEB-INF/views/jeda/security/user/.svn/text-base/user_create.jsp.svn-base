<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义新建表单
	UserCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		genderStore : null, // 性别数据源
		roleStore : null, // 角色数据源
		positionStore : null, // 岗位数据源
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 实例化性别数据源
			this.genderStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/USER_GENDER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.genderStore.load();// 加载性别数据

			this.positionStore = new Ext.data.JsonStore({
				autoDestroy : true,
				proxy : new Ext.data.HttpProxy({
					method : 'GET',
					url : '${ctx}/${frameworkPath}/user/position'
				}),
				root : 'data',
				fields : [ 'ID', 'NAME' ]
			});
			this.positionStore.load({
				params : {
					org : '${param.org}'
				}
			});// 加载岗位数据

			// 设置基类属性
			UserCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/user/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					fieldLabel : '<fmt:message key="user.username" />',
					name : 'username',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					fieldLabel : '<fmt:message key="user.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					fieldLabel : '<fmt:message key="user.defaultPassword" />',
					name : 'password',
					tabIndex : this.tabIndex++,
					readOnly : true,
					disabled : true,
					value : 'ceb1234'
				}, {
					xtype : 'combo',
					store : this.genderStore,
					fieldLabel : '<fmt:message key="user.gender" />',
					name : 'gender',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'gender',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					fieldLabel : '<fmt:message key="user.email" />',
					name : 'email',
					tabIndex : this.tabIndex++,
					allowBlank : false,
					vtype : 'email'
				}, {
					fieldLabel : '<fmt:message key="user.identity" />',
					name : 'identity',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'datefield',
					fieldLabel : '<fmt:message key="user.birthday" />',
					name : 'birthday',
					format : 'Y-m-d',
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					fieldLabel : '<fmt:message key="user.tel" />',
					name : 'tel',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					fieldLabel : '<fmt:message key="user.mobile" />',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					fieldLabel : '<fmt:message key="user.address" />',
					name : 'address',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					fieldLabel : '<fmt:message key="user.post" />',
					name : 'post',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					fieldLabel : 'QQ',
					name : 'qq',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="user.position" />',
					store : this.positionStore,
					name : 'position',
					valueField : 'ID',
					displayField : 'NAME',
					hiddenName : 'position',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="user.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="user.enabled" />',
					name : 'enabled',
					checked : true,
					tabIndex : this.tabIndex++
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'hidden',
					name : 'org',
					value : '${param.org}',
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
			app.closeTab('USER_CREATE');
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
					app.closeTab('USER_CREATE');// 关闭新建页面
					var list = Ext.getCmp("USER_LIST").get(0);// 获取列表组件
					// 若列表组件未被关闭,则刷新其数据源
					if (list != null) {
						list.findByType('grid')[0].getStore().reload();
					}
					var params = {
						username : action.result.username
					};
					// 打开查看页面
					app.loadTab('USER_VIEW', '<fmt:message key="button.view" /><fmt:message key="user" />', '${ctx}/${frameworkPath}/user/view', params);
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

	var userCreateForm = new UserCreateForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("USER_CREATE").add(userCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("USER_CREATE").doLayout();
</script>
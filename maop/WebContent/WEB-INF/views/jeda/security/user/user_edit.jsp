<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	UserEditForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		genderStore : null, // 性别数据源
		positionStore : null, //岗位数据源
		roleStore : null, // 数据源
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			this.genderStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/USER_GENDER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.genderStore.load();// 加载性别数据

			this.positionStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'GET',
					url : '${ctx}/${frameworkPath}/user/position'
				}),
				autoDestroy : true,
				root : 'data',
				fields : [ 'ID', 'NAME' ]
			});
			this.positionStore.load({
				params : {
					org : '${param.org}'
				}
			});// 加载岗位数据
			this.positionStore.on('load',function(store){
				// 加载表单数据
				userEditForm.load({
					url : '${ctx}/${frameworkPath}/user/view/${param.username}',
					method : 'GET',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : userEditForm,
					failure : userEditForm.loadFailure,
					success : userEditForm.loadSuccess
				});
			});
			

			// 设置基类属性
			UserEditForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/user/edit/${param.username}',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					fieldLabel : '<fmt:message key="user.username" />',
					name : 'username',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
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
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.email" />',
					name : 'email',
					tabIndex : this.tabIndex++,
					allowBlank : false
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
					editable : true,
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.tel" />',
					name : 'tel',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.mobile" />',
					name : 'mobile',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.address" />',
					name : 'address',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : '<fmt:message key="user.post" />',
					name : 'post',
					tabIndex : this.tabIndex++
				}, {
					fieldLabel : 'QQ',
					name : 'qq',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'treeField',
					name : 'orgName',
					fieldLabel : '<fmt:message key="user.org" />',
					listHeight : 60,
					readOnly : false,
					hiddenName : 'org',
					valueField : 'id',
					displayField : 'text',
					treeRootConfig : {
						text : '<sec:authentication property="principal.org.name"/>',
						draggable : false,
						id : '<sec:authentication property="principal.org.id"/>'
					},
					dataUrl : '${ctx}/${frameworkPath}/org/children',
					listeners : {
						scope : this,
						select : function(node) {
							this.positionStore.load({
								params : {
									org : node.getValue()
								}
							});// 加载岗位数据
							this.getForm().findField('position').setValue('');
						}
					}
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
					tabIndex : this.tabIndex++
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++
				}, {
					xtype : 'hidden',
					name : '_enabled',
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
				}]
			});
			app.mask.show();
	/*
			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/user/view/${param.username}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess
			});
	*/
		},
		// 保存操作
		doSave : function() {
			this.getForm().submit({
				scope : this,
				success : this.saveSuccess,
				failure : this.saveFailure,
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('USER_EDIT');
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
					var params = {
						username : '${param.username}'
					};
					app.closeTab('USER_EDIT');
					var list = Ext.getCmp("USER_LIST").get(0);// 获取列表组件
					if (list != null) {
						list.findByType('grid')[0].getStore().reload();
					}
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

	var userEditForm = new UserEditForm();
</script>

<script type="text/javascript">
	// 实例化编辑表单,并加入到Tab页中
	Ext.getCmp("USER_EDIT").add(userEditForm);
	// 刷新Tab页布局
	Ext.getCmp("USER_EDIT").doLayout();
</script>
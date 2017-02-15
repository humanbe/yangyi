<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	UserViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		genderStore : null, // 性别数据源
		roleStore : null, // 数据源
		employmentFormStore : null, // 用工性质数据源
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			this.genderStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/USER_GENDER/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.genderStore.load();// 加载性别数据

			// 实例化角色数据源
			this.roleStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/user/role/${param.username}',
				root : 'roles',
				fields : [ 'id', 'name', 'checked' ]
			});
			this.roleStore.load({
				scope : this,
				callback : function(records, option, success) {
					if (records.length > 0) {
						var items = new Array();
						for ( var i = 0; i < records.length; i++) {
							items[i] = new Ext.form.Checkbox({
								boxLabel : records[i].get('name'),
								name : 'role',
								inputValue : records[i].get('id'),
								checked : records[i].get('checked'),
								disabled : true
							});
						}
						this.add({
							xtype : 'checkboxgroup',
							fieldLabel : '<fmt:message key="role" />',
							name : 'roles',
							columns : 5,
							items : items,
							tabIndex : this.tabIndex++
						});
					}
				}
			});// 加载角色数据

			// 设置基类属性
			UserViewForm.superclass.constructor.call(this, {
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
				items : [ {
					fieldLabel : '<fmt:message key="user.username" />',
					name : 'username',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.gender" />',
					name : 'gender',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.email" />',
					name : 'email',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.identity" />',
					name : 'identity',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.birthday" />',
					name : 'birthday',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.employment.date" />',
					name : 'employmentDate',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.tel" />',
					name : 'tel',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.mobile" />',
					name : 'mobile',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.address" />',
					name : 'address',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.post" />',
					name : 'post',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : 'QQ',
					name : 'qq',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.org" />',
					name : 'orgName',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="user.position" />',
					name : 'positionname',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="user.description" />',
					name : 'description',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					readOnly : true
				}, {
					xtype : 'checkbox',
					fieldLabel : '<fmt:message key="user.enabled" />',
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
			this.load({
				url : '${ctx}/${frameworkPath}/user/view/${param.username}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess
			});
		},
		// 关闭操作
		doClose : function() {
			app.closeTab('USER_VIEW');
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
			var index = -1;
			var gender = form.findField('gender');
			index = this.genderStore.find('value', gender.getValue());
			if (index == -1) {

			} else {
				gender.setValue(this.genderStore.getAt(index).get('name'));
			}
		}
	});

	// 实例化查看表单,并加入到Tab页中
	Ext.getCmp("USER_VIEW").add(new UserViewForm());
	// 刷新Tab页布局
	Ext.getCmp("USER_VIEW").doLayout();
</script>

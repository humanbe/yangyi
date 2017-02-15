<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义编辑表单
	PositionEditForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序
		levelStore : null, // 功能数据源
		typeStore : null, // 类型数据源
		positionLevels : null, //岗位级别数据
		uncheckedOrgs : null, //取消选择的机构
		checkedOrgs : null, //选择的机构
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			this.uncheckedOrgs = new Array();
			this.checkedOrgs = new Array();

			this.levelStore = new Ext.data.JsonStore({
				url : '${ctx}/${frameworkPath}/positionlevel/${param.id}/get',
				root : 'data',
				fields : [ 'id', 'name', 'checked' ]
			});

			this.levelStore.load({
				scope : this,
				callback : function(records, option, success) {
					this.positionLevels = new Array();
					for ( var i = 0; i < records.length; i++) {
						this.positionLevels[i] = new Ext.form.Checkbox({
							boxLabel : records[i].get('name'),
							name : 'positionLevel',
							inputValue : records[i].get('id'),
							checked : records[i].get('checked')
						});
					}
					this.add({
						xtype : 'checkboxgroup',
						fieldLabel : '<fmt:message key="position.level" />',
						name : 'positionLevels',
						columns : 15,
						hidden : true,
						items : this.positionLevels
					});
				}
			});
			// 实例化类型数据源
			this.typeStore = new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/POSITION_TYPE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.typeStore.load();// 加载类型数据

			// 设置基类属性
			PositionEditForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url : '${ctx}/${frameworkPath}/position/edit/${param.id}',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items : [ {
					xtype : 'textfield',
					fieldLabel : '<fmt:message key="position.name" />',
					name : 'name',
					tabIndex : this.tabIndex++,
					allowBlank : false
				}, {
					xtype : 'combo',
					store : this.typeStore,
					fieldLabel : '<fmt:message key="position.type" />',
					name : 'type',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++,
					listeners : {
						scope : this,
						select : function(combo, record, index) {
							if (record.data.value == '0') {
								this.getForm().findField('positionLevels').hide();
								this.findByType('treepanel')[0].hide();
							} else if (record.data.value == '1') {
								this.getForm().findField('positionLevels').hide();
								this.findByType('treepanel')[0].getRootNode().reload();
								this.findByType('treepanel')[0].show();
							} else if (record.data.value == '2') {
								this.getForm().findField('positionLevels').show();
								this.findByType('treepanel')[0].hide();
							}
						}
					}
				}, {
					xtype : 'numberfield',
					fieldLabel : '<fmt:message key="column.order" />',
					name : 'order',
					tabIndex : this.tabIndex++,
					allowBlank : true
				}, {
					xtype : 'treepanel',
					fieldLabel : '<fmt:message key="position.name" />',
					name : 'org',
					height : 100,
					autoScroll : true,
					hidden : true,
					margins : '0 0 0 5',
					root : new Ext.tree.AsyncTreeNode({
						text : '<sec:authentication property="principal.org.name"/>',
						draggable : false,
						iconCls : 'node-root',
						id : '<sec:authentication property="principal.org.id"/>'
					}),
					loader : new Ext.tree.TreeLoader({
						requestMethod : 'GET',
						dataUrl : '${ctx}/${frameworkPath}/position/${param.id}/org'
					}),
					listeners : {
						scope : this,
						afterrender : function(tree) {
							tree.getRootNode().expand(1);
						},
						checkchange : function(node, checked) {
							if (checked) {
								if (this.checkedOrgs.indexOf(node.id) == -1 && this.uncheckedOrgs.indexOf(node.id) == -1) {
									this.checkedOrgs.push(node.id);
								}
							} else {
								if (this.uncheckedOrgs.indexOf(node.id) == -1 && this.checkedOrgs.indexOf(node.id) == -1) {
									this.uncheckedOrgs.push(node.id);
								}
							}

						}
					}
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
					handler : this.doCancel
				} ]
			});

			// 加载表单数据
			this.load({
				url : '${ctx}/${frameworkPath}/position/view/${param.id}',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess
			});
		},
		// 保存操作
		doSave : function() {
			this.getForm().submit({
				scope : this,
				params : {
					checkedOrgs : this.checkedOrgs,
					uncheckedOrgs : this.uncheckedOrgs
				},
				success : this.saveSuccess,
				failure : this.saveFailure,
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		},
		// 取消操作
		doCancel : function() {
			app.closeTab('POSITION_EDIT');
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
						id : '${param.id}'
					};
					app.closeTab('POSITION_EDIT');
					var list = Ext.getCmp("POSITION_LIST").get(0);
					if (list != null) {
						list.grid.getStore().reload();
					}
					app.loadTab('POSITION_VIEW', '<fmt:message key="button.view" /><fmt:message key="position" />', '${ctx}/${frameworkPath}/position/view', params);
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
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		loadSuccess : function(form, action) {
			if (form.findField('type').getValue() == '1') {
				this.findByType('treepanel')[0].show();
			} else if (form.findField('type').getValue() == '2') {
				form.findField('positionLevels').show();
			}
		}
	});

	// 实例化编辑表单,并加入到Tab页中
	Ext.getCmp("POSITION_EDIT").add(new PositionEditForm());
	// 刷新Tab页布局
	Ext.getCmp("POSITION_EDIT").doLayout();
</script>

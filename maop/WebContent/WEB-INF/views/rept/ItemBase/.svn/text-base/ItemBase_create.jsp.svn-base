<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

	//定义新建表单
	ItemBaseCreateForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			//禁止IE的backspace键(退格键)，但输入文本框时不禁止

			Ext.getDoc().on('keydown',function(e) {
								if (e.getKey() == 8
										&& e.getTarget().type == 'text'
										&& !e.getTarget().readOnly) {

								} else if (e.getKey() == 8
										&& e.getTarget().type == 'textarea'
										&& !e.getTarget().readOnly) {

								} else if (e.getKey() == 8) {
									e.preventDefault();
								}
							});
			// 实例化性别数据源
			
			 this.RptBaseConf_tablenameStore =new Ext.data.JsonStore({
				autoDestroy : true,
				url : '${ctx}/${frameworkPath}/item/RPT_ITEM_BASE_TABLE/sub',
				root : 'data',
				fields : [ 'value', 'name' ]
			});
			this.RptBaseConf_tablenameStore.load();			this.getItemparentCdStore = new Ext.data.Store(
				{
					proxy: new Ext.data.HttpProxy({
						url : '${ctx}/${managePath}/itembaseconf/getItemparentCd', 
						method: 'POST'
					}),
					reader: new Ext.data.JsonReader({}, ['value','name'])
				});
				this.getItemparentCdStore .load();
	
			// 设置基类属性

			ItemBaseCreateForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				url:'${ctx}/${managePath}/itembaseconf/create',
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [ 
							{
							    xtype : 'textfield',
								fieldLabel : '<font color=red>*</font>&nbsp;科目编码',
								allowBlank: false,
								name : 'item_cd'
							} ,
							{
								xtype : 'combo',
								store : this.getItemparentCdStore ,
								fieldLabel : '父科目编码',
								name : 'parent_item_cd',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'parent_item_cd',
								mode : 'local',
								triggerAction : 'all',
								forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								listeners : {
								}
							},
							{
							    xtype : 'textfield',
								fieldLabel : '<font color=red>*</font>&nbsp;科目名称',
								allowBlank: false,
								name : 'item_name'
							},{
								xtype : 'lovcombo',
								store : this.RptBaseConf_tablenameStore,
								fieldLabel : '关联表名',
								name : 'relation_tablename',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'relation_tablename',
								mode : 'local',
								triggerAction : 'all',
								forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								listeners : {
								},
								beforeBlur:function(){}
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
			app.closeTab('ITEMBASE_CREATE');
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
					app.closeTab('ITEMBASE_CREATE');// 关闭新建页面
					 Ext.getCmp("ItemBaseListGridPanel").getStore().reload();
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

	var ItemBaseCreateForm = new ItemBaseCreateForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("ITEMBASE_CREATE").add(ItemBaseCreateForm);
	// 刷新Tab页布局
	Ext.getCmp("ITEMBASE_CREATE").doLayout();
</script>
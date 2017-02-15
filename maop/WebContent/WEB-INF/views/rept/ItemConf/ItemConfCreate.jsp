<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var getLvl1Store_Create;
var getLvl2Store_Create;
//授权应用系统
var appsysStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
});
appsysStore.load();



//定义新建表单
ItemConfCreateForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		//一级分类

		 this.item_app_ststcs_peak_flagStore =new Ext.data.JsonStore({
		autoDestroy : true,
		url : '${ctx}/${frameworkPath}/item/JOB_AUTHORIZE_FLAG/sub',
		root : 'data',
		fields : [ 'value', 'name' ]
		});
		this.item_app_ststcs_peak_flagStore.load();
		this.item_app_ststcs_peak_flagStore.on('load',function(){
			Ext.getCmp("item_app_ststcs_peak_flag_create").setValue("0");
		});
		getLvl1Store_Create = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itemconf/getLvl1StoreCreate', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['value','name'])
		});
		getLvl1Store_Create.load();
		//二级分类
		getLvl2Store_Create = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/itemconf/getLvl2StoreCreate', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['value','name'])
		});
		// 设置基类属性		ItemConfCreateForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/itemconf/create',
			bodyStyle : 'padding-left:100px;padding-bottom:0px;padding-top:50px;padding-right:0px;',
			defaults : {
				anchor : '80%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items:[{
				xtype : 'combo',
				id: 'apl_code_create',
				store : appsysStore,
				fieldLabel : '<font color=red>*</font>&nbsp;应用系统',
				name : 'apl_code' ,
				valueField : 'appsysCode',
				displayField : 'appsysName',
				hiddenName : 'apl_code',
				mode : 'local',
				emptyText : '必填项',
				allowBlank : false,
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++,
				listeners : {
					scope : this ,
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
						}; 
					}
				
			}
		},{
				xtype : 'combo',
				store : getLvl1Store_Create,
				fieldLabel : '<font color=red>*</font>&nbsp;一级分类',
				id:'item_cd_lvl1_create',
				name : 'item_cd_lvl1',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'item_cd_lvl1',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
				emptyText : '必填项',
				allowBlank : false,
				tabIndex : this.tabIndex++,
				allowBlank : false,
				listeners : {
					//编辑完成后处理事件



					select : function(obj) {
						getLvl2Store_Create.baseParams.item_cd_lvl1 =obj.value;
						getLvl2Store_Create.load();
						Ext.getCmp('item_cd_lvl2_create').setValue("");
					}
				}
			},
			{
				xtype : 'combo',
				store : getLvl2Store_Create,
				fieldLabel : '<font color=red>*</font>&nbsp;二级分类',
				name : 'item_cd_lvl2',
				id: 'item_cd_lvl2_create',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'item_cd_lvl2',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
				emptyText : '必填项',
				allowBlank : false,
				tabIndex : this.tabIndex++,
				listeners : {
				}
			},
			{
				xtype : 'textfield',
				fieldLabel : '科目编码',
				name : 'item_cd_app',
				tabIndex : this.tabIndex++,
				maxLength : 40
				
			},
			{
				xtype : 'textfield',
				fieldLabel : '<font color=red>*</font>&nbsp;科目名称',
				name : 'item_app_name',
				tabIndex : this.tabIndex++,
				maxLength : 40,
				emptyText : '必填项',
				allowBlank : false
			},
			{
				xtype : 'combo',
				id:'item_app_ststcs_peak_flag_create',
				fieldLabel : '统计峰值标识',
				store : this.item_app_ststcs_peak_flagStore,
				displayField : 'name',
				valueField : 'value',
				name : 'item_app_ststcs_peak_flag',
				hiddenName : 'item_app_ststcs_peak_flag',
				mode: 'local',
				typeAhead: true,
                triggerAction: 'all',
                allowBlank : false,
                editable : true,  //输入 索引
                forceSelection : true,
				tabIndex : this.tabIndex++
			},
			{
				xtype:'textarea',
				fieldLabel : '计算式',
				name : 'expression',
				height : 75,
				maxLength : 150,
				tabIndex : this.tabIndex++
			}],
			// 定义按钮
			buttons : [{
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
			}]
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
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				app.closeTab('ITEM_CONF_CREATE');
				var list = Ext.getCmp("ITEM_CONF_INDEX").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				app.loadTab('ITEM_CONF_INDEX', '三级科目配置', '${ctx}/${managePath}/itemconf/index');
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
	// 取消操作
	doCancel : function() {
		app.closeTab('ITEM_CONF_CREATE');
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("ITEM_CONF_CREATE").add(new ItemConfCreateForm());
// 刷新Tab页布局
Ext.getCmp("ITEM_CONF_CREATE").doLayout();

</script>
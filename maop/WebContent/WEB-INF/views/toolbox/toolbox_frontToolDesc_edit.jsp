<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

Front_Tool_Desc__EditDescInfo= Ext.extend(Ext.FormPanel, {
	gridStore : null,// 数据列表数据源
	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序
	csm : null,// 数据列表选择框组件
    defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性

		//数据字典
	 	this.tool_statusStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
		this.tool_statusStore.load();
		this.tool_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_typeStore.load();
	
		
		this.tool_authorize_flagStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_authorize_flagStore.load();
		
		this.authorize_level_typeStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.authorize_level_typeStore.load();
		
	
		this.tool_stausStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.tool_stausStore.load();
		
		
	
		this.appsys_Store =  new Ext.data.Store({
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForTool',
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
		this.appsys_Store.load();
		
		
		//一级分类

		this.tool_field_type_oneStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_one'])
			
		});
		this.tool_field_type_oneStore.load();
	
		Front_Tool_Desc__EditDescInfo.superclass.constructor.call(this, {
			title : '<fmt:message key="front_tool_desc" />',
			labelAlign : 'right',
			buttonAlign : 'center',
			renderTo:document.body,
			autoHeight: false,
			width:800,
			height:600,
			frame : true,
			monitorValid : true,
			defaults : {
				anchor : '90%',
				msgTarget : 'side'
			},
			url:'${ctx}/${appPath}/ToolBoxController/frontToolDesc_edit',
			autoScroll : true,
			monitorValid : true,
			items :  [ {
				layout:'column',
				items:[{
				     columnWidth:.5,
				     layout:'form',
                items : [ {
				xtype : 'combo',
				store : this.appsys_Store,
				fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
				id:'appsys_codeview_DESCID',
				name : 'appsys_code',
				valueField : 'appsysCode',
				displayField : 'appsysName',
				hiddenName : 'appsys_code',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				anchor:'100%',
				style  : 'background : #F0F0F0' , 
				readOnly:true,
				tabIndex : this.tabIndex++,
				allowBlank : false,
				 listeners : {
					
						scope : this,
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
							} 
						
					}
				 } 
		},
		{
			xtype : 'textfield',
			id : 'tool_code_view',
			fieldLabel : '<fmt:message key="toolbox.tool_code" />',
			name : 'tool_code',
			maxLength:80,
			readOnly:true,
			hidden:true,
			style  : 'background : #F0F0F0' , 
			tabIndex : this.tabIndex++,
			allowBlank : false
		},
		
		{
			xtype : 'combo',
			store : this.authorize_level_typeStore,
			fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
			name : 'authorize_level_type',
			id:'authorize_level_typeview_DESCID',
			valueField : 'value',
			displayField : 'name',
			hiddenName : 'authorize_level_type',
			mode : 'local',
			triggerAction : 'all',
			forceSelection : true,
			anchor:'100%',
			readOnly:true,
			viewable : false,
			allowBlank : false,
			tabIndex : this.tabIndex++
		},{
			xtype : 'combo',
			store : this.tool_authorize_flagStore,
			fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
			name : 'tool_authorize_flag',
			id:'tool_authorize_flagview_DESCID',
			valueField : 'value',
			displayField : 'name',
			anchor:'100%',
			hiddenName : 'tool_authorize_flag',
			mode : 'local',
			triggerAction : 'all',
			forceSelection : true,
			viewable : false,
			readOnly:true,
			tabIndex : this.tabIndex++,
			allowBlank : false
		},{
			xtype : 'textfield',
			fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
			name : 'tool_name',
			id:'tool_nameview_DESCID' ,
			anchor:'100%',
			maxLength:100,
			readOnly:true,
			tabIndex : this.tabIndex++,
			allowBlank : false
		}]
				},{
				     columnWidth:.5,
				     layout:'form',
				    
				     items:[{
							xtype : 'combo',
							store : this.tool_field_type_oneStore,
							fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
							name : 'field_type_one',
							id:'field_type_oneview_DESCID',
							valueField : 'field_type_one',
							displayField : 'field_type_one',
							hiddenName : 'field_type_one',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							viewable : false,
							readOnly:true,
							anchor:'100%',
							tabIndex : this.tabIndex++,
							allowBlank : false
						},
						{
							xtype : 'combo',
							store : this.tool_field_type_oneStore,
							fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
							name : 'field_type_two',
							id:'field_type_twoview_DESCID',
							valueField : 'field_type_two',
							displayField : 'field_type_two',
							hiddenName : 'field_type_two',
							mode : 'local',
							triggerAction : 'all',
							forceSelection : true,
							readOnly:true,
							anchor:'100%',
							viewable : false,
							tabIndex : this.tabIndex++
						},
						{
							xtype : 'combo',
							store : this.tool_field_type_oneStore,
							fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
							name : 'field_type_three',
							id:'field_type_threeview_DESCID',
							valueField : 'field_type_three',
							displayField : 'field_type_three',
							hiddenName : 'field_type_three',
							mode : 'local',
							triggerAction : 'all',
							readOnly:true,
							forceSelection : true,
							anchor:'100%',
							viewable : false,
							tabIndex : this.tabIndex++
						},{
							xtype : 'combo',
							store : this.tool_typeStore,
							fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
							name : 'tool_type',
							id:'tool_typeview_DESCID',
							valueField : 'value',
							displayField : 'name',
							hiddenName : 'tool_type',
							mode : 'local',
							readOnly:true,
							anchor:'100%',
							triggerAction : 'all',
							forceSelection : true,
							viewable : false,
							tabIndex : this.tabIndex++,
							allowBlank : false
						}]
				}]
    },{
    	
			xtype : 'textarea',
			fieldLabel : '<fmt:message key="toolbox.tool_desc" />',
			name : 'tool_desc',
			height : 100,
			maxLength:660,
			readOnly:true,
			anchor:'90%',
			tabIndex : this.tabIndex++
		 
    },{
		xtype : 'textarea',
		fieldLabel :'<fmt:message key="front_tool_desc" />',
		name : 'front_tool_desc',
		readOnly:false,
		style  : 'background : #F0F0F0' , 
		height : 100,
		maxLength:660,
		anchor:'90%',
		tabIndex : this.tabIndex++

	}],
			buttons : [ {
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				formBind : true,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				scope : this,
				handler : this.doCancel
			} ]
		});

		// 加载表单数据
		this.form.load({
					url : '${ctx}/${appPath}/ToolBoxController/view',
					method : 'POST',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					
					params:{
						tool_code :'${param.tool_code}',
						appsys_code:'${param.appsys_code}'
					}
				});
	},
	doCancel : function() {
		app.closeWindow();
	},
	doSave : function() {
		this.getForm().submit({
			scope : this,
			success : this.saveSuccess,// 保存成功回调函数
			failure : this.saveFailure,// 保存失败回调函数
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
			 app.closeWindow();// 关闭新建页面
			 Ext.getCmp("Front_Tool_Desc__EditDescInfo").getStore().reload();
			}
		});

	},
	// 保存失败回调
	saveFailure : function(form, action) {
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '保存失败',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
   
});
var Front_Tool_Desc__EditDescInfo = new Front_Tool_Desc__EditDescInfo();
app.window.get(0).add(Front_Tool_Desc__EditDescInfo);
app.window.get(0).doLayout();
</script>

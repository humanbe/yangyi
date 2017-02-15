<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var appsys_code_front_edit='${param.appsys_code}';

var front_edit_field_type_twoStore;
var front_edit_field_type_threeStore;
var front_edit_field_type_one= decodeURIComponent('${param.field_type_one}') ;
var front_edit_field_type_two= decodeURIComponent('${param.field_type_two}') ;

var env = '<fmt:message key="exportServer.toolpath" />';
var ProdFlag=(env.indexOf("PROD")==-1);

 var front_osFlag=(appsys_code_front_edit=='COMMON');
var sty;
if(front_osFlag){
	sty='background : #F0F0F0';
}else{
	sty='';
} 
 
	//定义列表
	ToolBox_editPanel = Ext.extend(Ext.FormPanel,{
		tabIndex : 0,// 查询表单组件Tab键顺序
		form:null,
		constructor : function(cfg) {// 构造方法

		Ext.apply(this, cfg);
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止

		Ext.getDoc().on('keydown',function(e) {
			if (e.getKey() == 8
					&& e.getTarget().type == 'text'
					&& !e.getTarget().readOnly) {
			} else if (e.getKey() == 8
					&& e.getTarget().type == 'textarea'
					&& !e.getTarget().readOnly) {
			}
			 else if (e.getKey() == 8) {
				e.preventDefault();
			} 
		});
		
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
							icon : Ext.MessageBox.INFO
						});
					}
				}
			}
		});
		this.appsys_Store.load();
		//一级分类

		this.front_field_type_oneStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_one'])
		});
		this.front_field_type_oneStore.load();
		//二级分类
		front_edit_field_type_twoStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_two']),
			baseParams : {
				field_type_one : front_edit_field_type_one
			}
		});
		front_edit_field_type_twoStore.load();
		//三级分类
		front_edit_field_type_threeStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_three']),
	    	baseParams : {
	    		field_type_one : front_edit_field_type_one,
	    		field_type_two : front_edit_field_type_two
		       }
		});
		front_edit_field_type_threeStore.load();
		 
			// 设置基类属性

			ToolBox_editPanel.superclass.constructor.call(this,{
						title:'<fmt:message key="toolbox.tool_properties" />', 
						buttonAlign : 'center',
						labelAlign : 'right',
						lableWidth : 15,
						autoHeight: false,
						autoScroll : true,
						frame : true,
						monitorValid : true,
						border : false,
						defaults : {
							anchor : '100%',
							msgTarget : 'side'
						},
						monitorValid : true,
						items:[{
						  layout:'column',
						  items:[{
							columnWidth:.5,
							layout:'form',
							items:[{
								xtype : 'combo',
								id:'appsys_code_front_edit',
								store : this.appsys_Store,
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
								name : 'appsys_code',
								valueField : 'appsysCode',
								displayField : 'appsysName',
								hiddenName : 'appsys_code',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' , 
								mode : 'local',
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								allowBlank : false
							},{
								xtype : 'textfield',
								id:'tool_code_front_edit',
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_code" />',
								name : 'tool_code',
								maxLength:80,
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' , 
								tabIndex : this.tabIndex++,
								allowBlank : false
							},{
								xtype : 'combo',
								store : this.authorize_level_typeStore,
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
								name : 'authorize_level_type',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'authorize_level_type',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								mode : 'local',
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								allowBlank : false
							},{
								xtype : 'combo',
								store : this.tool_authorize_flagStore,
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
								name : 'tool_authorize_flag',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'tool_authorize_flag',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								mode : 'local',
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								allowBlank : false
							},{
								xtype : 'textfield',
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
								maxLength:100,
								name : 'tool_name',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								tabIndex : this.tabIndex++,
								allowBlank : false
							}]
							},{
							 columnWidth:.5,
							 layout:'form',
							items:[{
								xtype : 'combo',
								store : this.front_field_type_oneStore,
								fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
								name : 'field_type_one',
								valueField : 'field_type_one',
								displayField : 'field_type_one',
								hiddenName : 'field_type_one',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								mode : 'local',
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								allowBlank : false
							},{
								xtype : 'combo',
								store : front_edit_field_type_twoStore,
								fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
								name : 'field_type_two',
								valueField : 'field_type_two',
								displayField : 'field_type_two',
								hiddenName : 'field_type_two',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								mode : 'local',
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++
								},{
								xtype : 'combo',
								store : front_edit_field_type_threeStore,
								fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
								name : 'field_type_three',
								valueField : 'field_type_three',
								displayField : 'field_type_three',
								hiddenName : 'field_type_three',
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								mode : 'local',
								triggerAction : 'all',
								//forceSelection : true,
								//editable : false,
								tabIndex : this.tabIndex++
								},{
								xtype : 'combo',
								store : this.tool_typeStore,
								fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
								name : 'tool_type',
								valueField : 'value',
								displayField : 'name',
								hiddenName : 'tool_type',
								anchor:'100%',
								readOnly:true,
								mode : 'local',
								style  : 'background : #F0F0F0' , 
								//triggerAction : 'all',
								//forceSelection : true,
								editable : false,
								tabIndex : this.tabIndex++,
								allowBlank : false
								}]
							}]
								},{
								xtype : 'textarea',
								fieldLabel :'<fmt:message key="toolbox.tool_desc" />',
								name : 'tool_desc',
								height : 80,
								anchor:'100%',
								readOnly:true,
								style  : 'background : #F0F0F0' ,
								maxLength:660,
								tabIndex : this.tabIndex++
			
								},{
								//一线接收工具描述
								xtype:'textarea',
								id :'front_tool_desc_front_edit',
								fieldLabel:'一线工具描述',
								name:'front_tool_desc',
								height:80,
								autoScroll : true,
								anchor:'100%',
								maxLength:660,
								tabIndex:this.tabIndex++
							}],

		                buttons:[
							{
							text : '<fmt:message key="button.save" />',
							iconCls : 'button-save',
							tabIndex : this.tabIndex++,
							handler : this.doSave
							}] 
						});
			// 加载表单数据
			this.form.load({
						url : '${ctx}/${appPath}/ToolBoxController/front_view',
						method : 'POST',
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.loading" />',
						scope : this,
						success : this.loadSuccess,
						failure : this.loadFailure,
						params:{
							tool_code :'${param.tool_code}',
							appsys_code:'${param.appsys_code}'
						}
					});
		          },
                 		// 保存操作  
				doSave : function() {
					  Ext.Ajax.request({
						method : 'POST',
						url : '${ctx}/${appPath}/ToolBoxController/front_edit',
						scope : toolBox_editPanel,
						success : toolBox_editPanel.saveSuccess,
						failure : toolBox_editPanel.saveFailure,
						params : {
							tool_code :Ext.getCmp('tool_code_front_edit').getValue(),
							appsys_code : Ext.getCmp('appsys_code_front_edit').getValue(),
							front_tool_desc :Ext.getCmp('front_tool_desc_front_edit').getValue()
						}
					});   
					
					  /* ToolBox_editPanel.getForm().submit({
						scope : ToolBox_editPanel,
						success : ToolBox_editPanel.saveSuccess,// 保存成功回调函数
						failure : ToolBox_editPanel.saveFailure,// 保存失败回调函数
						waitTitle : '<fmt:message key="message.wait" />',
						waitMsg : '<fmt:message key="message.saving" />'
						    });   */	 		
					},
		//保存失败
		saveFailure : function(form, action) {

			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'
								+ error,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
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
							app.closeWindow();
						}
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
			},
			loadSuccess : function(form, action) {
				
			}
	
	 });
	
	var toolBox_editPanel=new ToolBox_editPanel();
	
	// 实例化新建表单,并加入到Tab页中
	app.window.get(0).add(toolBox_editPanel);
	// 刷新Tab页布局
	app.window.get(0).doLayout();
</script>

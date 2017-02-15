<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

applicationprocess_create = Ext.extend(Ext.FormPanel, {
	row : 0,// Tab键顺序
	
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性/* 
        this.OsUserUserIdStore = new Ext.data.Store(
				{
					proxy : new Ext.data.HttpProxy(
							{
								method : 'POST',
								url : '${ctx}/${managePath}/ApplicationProcess/findUserId'
							}),
							reader: new Ext.data.JsonReader({}, ['userId','name'])
				});
		this.OsUserUserIdStore.load();      */ 
		
		
		applicationprocess_create.superclass.constructor.call(this, {

			buttonAlign : 'center',
			labelAlign : 'right',
			lableWidth : 15,
			 fileUpload : true, 
			//autoHeight : true,
			//height:300,
			frame : true,
			monitorValid : true,
			url : '${ctx}/${managePath}/ApplicationProcess/create',
			defaults : {
				anchor : '90%',
				msgTarget : 'side'
			},
			items :  [/* {
				xtype : 'combo',
				
				store : this.OsUserUserIdStore,
				fieldLabel : '<font color=red>*</font>&nbsp;审批人',
				width:160,
				name : 'handled_user',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'handled_user',
				tabIndex : this.tabIndex++,
				allowBlank:false
				
			}, */{
				xtype : 'textarea',
				fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="application.application_reasons" />',
				name : 'application_reasons',
				height : 150,
				tabIndex : this.tabIndex++,
				allowBlank:false

			},{
				xtype : 'textfield',
				fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="application.current_state" />',
				name : 'current_state',
				id:'current_stateID',
				hidden: true,
				tabIndex : this.tabIndex++
			},{
				xtype : 'fileuploadfield',
				fieldLabel:'<font color=red>*</font>&nbsp;服务器信息文件上传',
				id : 'application_uploadCreatefileID',
				buttonText : '<fmt:message key="toolbox.glance" />',
				editable : true ,
				buttonCfg: {
					iconCls: 'upload-icon'
				},
				allowBlank:false,
				listeners : {
					scope : this,
					'fileselected' : function(fileField, path) {
						initFilePath=path;
						var script = path.substring(path.lastIndexOf('\.') + 1);
						if(!(script=='xls'||script=='xlsx')){
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '请上传excel文件,后缀[xls][xlsx]',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
							Ext.getCmp('application_uploadCreatefileID').reset();
							return false;
						}
						
					}
				}

			}],
			buttons : [
			           /* {
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : this.doSave
			},  */
			{
				text : '<fmt:message key="button.submit" />',
				iconCls : 'button-ok',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : this.doSubmit
			} ]	
		});
		
			 
			
		
	},

	
	// 保存操作
	doSubmit : function() {
	Ext.getCmp('current_stateID').setValue('1');
	
	this.getForm().submit({
		scope : this,
		success : this.saveSuccess,
		failure : this.saveFailure,
		 waitTitle : '<fmt:message key="message.wait" />',
		waitMsg : '<fmt:message key="message.saving" />' 
	});
},
//保存成功回调
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
// 保存失败回调
saveFailure : function(form, action) {
	var error = decodeURIComponent(action.result.error);
	Ext.Msg.show({
		title : '<fmt:message key="message.title" />',
		msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'+ error,
		buttons : Ext.MessageBox.OK,
		icon : Ext.MessageBox.ERROR
	});
}
	


});
var applicationprocess_create = new applicationprocess_create();
/* // 实例化新建表单,并加入到Tab页中
Ext.getCmp("ASI_CREATE").add(applicationprocess_create);
// 刷新Tab页布局
Ext.getCmp("ASI_CREATE").doLayout(); */

</script>

<script type="text/javascript">
app.window.get(0).add(applicationprocess_create);
app.window.get(0).doLayout();
</script>
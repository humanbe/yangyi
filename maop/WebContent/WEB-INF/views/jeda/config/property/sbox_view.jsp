<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<script type="text/javascript">
var  sbox_allStateStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/SBOX_ALLSTATE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
sbox_allStateStore.load();

var userStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/jobdesign/getUsers',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['username','name'])
});
userStore.load();
    //定义所选信息展示列表
	ShowSelectedSuggestionWindow = Ext.extend(Ext.FormPanel, {
		form : null,// 查询表单组件
		tabIndex : 0,// 查询表单组件Tab键顺序
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

								} else if (e.getKey() == 8) {
									e.preventDefault();
								}
							});
			ShowSelectedSuggestionWindow.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				layout:'form',
				frame : true,
				items :[  {
							xtype : 'textfield',
							fieldLabel : '<fmt:message key="sbox.sbox_id" />',
							hidden:true,
							width:420,
							name : 'sbox_id'
						},{
							xtype:'textarea',
							fieldLabel:'<fmt:message key="sbox.sbox_value" />',
							readOnly:true,
							width:420,
							name:'sbox_value'
						},{
							fieldLabel:'<fmt:message key="sbox.sbox_initiator" />',
							width:420,
							readOnly:true,
							name:'sbox_initiator'
							
						},{
							fieldLabel:'<fmt:message key="sbox.sbox_state" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_statenum',
				    		renderer:function(value){
				    			var index = sbox_allStateStore.find('value', value);
								if (index == -1) {
									return value;
								} else {
									return sbox_allStateStore.getAt(index).get('name');
								}
								
				    		}
						},{ 
							fieldLabel:'<fmt:message key="sbox.sbox_time" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_time'
						},{ 
							fieldLabel:'<fmt:message key="sbox.sbox_confirm_user" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_confirm_user'
						},{ 
							fieldLabel:'<fmt:message key="sbox.sbox_confirm_time" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_confirm_time'
						},{ 
							fieldLabel:'<fmt:message key="sbox.sbox_reject_user" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_reject_user'
						},{ 
							fieldLabel:'<fmt:message key="sbox.sbox_reject_time" />',
				    		width:420,
				    		readOnly:true,
				    		name:'sbox_reject_time'
						}],
				buttons : [ {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-cancel',
					scope : this,
					handler : this.doCancel
				} ]
			});

			// 加载表单数据
		 	this.load({
				url : '${ctx}/${frameworkPath}/config/sbox/view',
				method : 'GET',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					sbox_id:'${param.sbox_id}'
				}
			});  
		 } ,
		// 取消操作
		doCancel : function() {
			app.closeWindow();
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
		}
		
	});

	var ShowSelectedSuggestionWindow = new ShowSelectedSuggestionWindow();
</script>
<script type="text/javascript">
	app.window.get(0).add(ShowSelectedSuggestionWindow);
	app.window.get(0).doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
    
    //定义保存所选建议编号的数组
	var sbox_allState = new Array();
	//数据字典 , 用于加载意见箱状态
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
	//定义信息展示列表
	SBoxInfoList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源
		grid : null,// 数据列表组件
		csm : null,// 数据列表选择框组件	
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
			
			
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore( {
			 proxy : new Ext.data.HttpProxy({
				method : 'POST',
				url :  '${ctx}/${frameworkPath}/config/sbox/getSboxInfo',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'sbox_id','sbox_value','sbox_initiator','sbox_statenum','sbox_time','sbox_confirm_user','sbox_confirm_time','sbox_reject_user','sbox_reject_time'], 
			remoteSort : true,
			sortInfo : {
				field :  'sbox_state' ,
				direction : 'ASC'
			},
			baseParams : {
				start : 0,
				limit : 6
			} 
		});
		this.gridStore.load(); 
		//加载数据源
		
		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel({
			id:'sBoxInfo',
			border : false,
			viewConfig:{
				forceFit : true
			},
			loadMask : true,
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [csm,   
			    {
					header : '<fmt:message key="sbox.sbox_id" />', 
					dataIndex : 'sbox_id',
					hidden:true
				},
				{
					header : '<fmt:message key="sbox.sbox_value" />',
					dataIndex : 'sbox_value',
					width:400 ,
					renderer:function(v,metadata,record){ 
						metadata.attr="ext:qtip="+v; 
						return v;
						} 
						
				},
				{
					header : '<fmt:message key="sbox.sbox_initiator" />', 
					dataIndex : 'sbox_initiator',
					scope:SBoxInfoList,
					renderer:function(value) {
						var index = userStore.find('username', value);			
						 if (index == -1) {
							return value;
						} else {
							return userStore.getAt(index).get('name');
						} 
					}
					
				},
				{
					header : '<fmt:message key="sbox.sbox_state" />',
					dataIndex : 'sbox_statenum'
					
				},
				{
					header : '<fmt:message key="sbox.sbox_time" />', 
					dataIndex : 'sbox_time',
					hidden:true
				},
				{
					header : '<fmt:message key="sbox.sbox_confirm_user" />', 
					dataIndex : 'sbox_confirm_user',
					hidden:true
				}	,
				{
					header : '<fmt:message key="sbox.sbox_confirm_time" />', 
					dataIndex : 'sbox_confirm_time',
					hidden:true
				}	,
				{
					header : '<fmt:message key="sbox.sbox_reject_user" />', 
					dataIndex : 'sbox_reject_user',
					hidden:true
				}	,
				{
					header : '<fmt:message key="sbox.sbox_reject_time" />', 
					dataIndex : 'sbox_reject_time',
					hidden:true
				}	
	  		] ,		
			// 定义按钮工具条
				tbar : new Ext.Toolbar( {
				items : ['-']
			}),
			// 定义分页工具条
		 	bbar : new Ext.PagingToolbar( {
				store : this.gridStore,
				displayInfo : false,
				pageSize : 6,
				buttons : [ '-' ,{
					iconCls : 'button-excel',
					tooltip : '<fmt:message key="button.excel" />',
					scope : this,
					handler :this.doExcel
				}]
			}),
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			}
		});
		// 设置基类属性
	
		SBoxInfoList.superclass.constructor.call(this, {
			layout : 'fit',
			height:210,
			id:'sbox',
			border : false,
			items : [ this.grid ]
		});
	},
	 
	//意见添加事件
	doAdd:function(){
		var params='';
		app.loadWindow('${ctx}/${frameworkPath}/config/sbox/addSuggestion',params);
	},
	//意见驳回事件
	doReject:function(){
		 if (Ext.getCmp("sBoxInfo").getSelectionModel().getCount() > 0) {
				var records =Ext.getCmp("sBoxInfo").getSelectionModel()
						.getSelections();
				var sbox_ids = new Array();
				 for ( var i = 0; i < records.length; i++) {
					sbox_ids[i] = records[i].get('sbox_id');
				} 
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '确定要执行驳回操作吗？？',
							buttons : Ext.MessageBox.OKCANCEL,
							icon : Ext.MessageBox.QUESTION,
							minWidth : 200,
							scope : this,
							fn : function(buttonId) {
								if (buttonId == 'ok') {
									app.mask.show();
									Ext.Ajax.request({
												method : 'POST',
												url : '${ctx}/${frameworkPath}/config/sbox/editState',
												scope : SBoxInfoList,
												success :  Ext.getCmp("sbox").sboxStateSuccess,
												failure :  Ext.getCmp("sbox").sboxStatefailure,
												params : {
													sbox_ids : sbox_ids,
													state_id:"4"
												}
											});
								}
							}
						}); 
			 }  else {
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.select.one.at.least" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
			}  
	},
	//意见确认事件
	doConfirm:function(){
		 if (Ext.getCmp("sBoxInfo").getSelectionModel().getCount() > 0) {
			var records =Ext.getCmp("sBoxInfo").getSelectionModel()
					.getSelections();
			var sbox_ids = new Array();
			 for ( var i = 0; i < records.length; i++) {
				sbox_ids[i] = records[i].get('sbox_id');
			} 
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '确定要将状态修改为确认吗？？',
						buttons : Ext.MessageBox.OKCANCEL,
						icon : Ext.MessageBox.QUESTION,
						minWidth : 200,
						scope : this,
						fn : function(buttonId) {
							if (buttonId == 'ok') {
								app.mask.show();

								Ext.Ajax.request({
											method : 'POST',
											url : '${ctx}/${frameworkPath}/config/sbox/editState',
											scope : SBoxInfoList,
											success :  Ext.getCmp("sbox").sboxStateSuccess,
											failure :  Ext.getCmp("sbox").sboxStatefailure,
											params : {
												sbox_ids : sbox_ids,
												state_id:"2"
											}
										});
							}
						}
					}); 
		 }  else {
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.select.one.at.least" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		}  
	},
	//意见状态修改事件
	doStateEdit:function(){
		if (Ext.getCmp("sBoxInfo").getSelectionModel().getCount() > 0) {
			var records = Ext.getCmp("sBoxInfo").getSelectionModel().getSelections();
		
			 for ( var i = 0; i < records.length; i++) {
				sbox_allState[i] = records[i].get('sbox_id');
			} 
			sbox_allState_Win.show();
						}else {
							Ext.Msg.show({
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.select.one.at.least" />',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
				}
	},
	// 查看事件
	doView : function() {
		 var record = this.grid.getSelectionModel()
		.getSelected();
		 var params = {
				sbox_id:record.get('sbox_id') 
			};
		 app.loadWindow('${ctx}/${frameworkPath}/config/sbox/showSelectedSuggestion',params); 	
	},
	doExcel:function(){
		if(this.grid.getStore().getCount()>0){
			
			window.location = '${ctx}/${frameworkPath}/config/sbox/sbox_excel.xls';
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '没有数据,不可导出',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
		
	},
	//意见状态操作成功的回调
	sboxStateSuccess: function(response, options) {
		app.mask.hide();
			Ext.getCmp("sBoxInfo").getStore().reload();// 重新加载数据源
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '操作已成功！',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
		
	},
	//意见状态操作失败的回调
	sboxStatefailure: function(response, options) {
		app.mask.hide();
		var error = Ext.decode(response.responseText).error;
		Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '操作失败'+'<fmt:message key="error.code" />:'
							+ error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
	},
	//修改意见状态事件
	doSaveState:function(){
		if(!Ext.getCmp('sboxAllState').getValue()==""){	
			Ext.Ajax.request({
				method : 'POST',
				url : '${ctx}/${frameworkPath}/config/sbox/editState',	
				scope : SBoxInfoList,
				success :  Ext.getCmp("sbox").sboxSaveSuccess,
				failure :  Ext.getCmp("sbox").sboxStatefailure,
				params : {
					sbox_ids:sbox_allState,
					state_id: Ext.getCmp('sboxAllState').getValue()
				}
			});
			}else{
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="toolbox.tool_authorize_level_not_empty" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					minWidth : 200
				});
			} 
	
	},
	//意见修改操作成功回调
	sboxSaveSuccess: function(response, options) {
		    sbox_allState_Win.hide();
			Ext.getCmp("sBoxInfo").getStore().reload();// 重新加载数据源
			Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '操作已成功！',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO
					});
		
	},
	//关闭意见修改窗口事件
	doCancel:function(){
		  sbox_allState_Win.hide();
	}

});
var sboxInfo=new SBoxInfoList();
//修改意见状态的窗口
var sbox_allState_Win = new Ext.Window({
	title:'<fmt:message key="sbox.sbox_state_edit" />',
	layout:'form',
	width:350,
	height:120,
	plain:true,
	modal : true,
	closable : false,
	resizable : false,
	draggable : true,
	closeAction :'close', 
	items : new Ext.form.FormPanel({
		buttonAlign : 'center',
		labelAlign : 'right',
		lableWidth : 15,
		frame : true,
		monitorValid : true,
		items:[{
			xtype : 'combo',
			store : sbox_allStateStore,
			fieldLabel : '选择状态',
			name : 'sbox_state',
			id : 'sboxAllState',
			valueField : 'value',
			displayField : 'name',
			hiddenName : 'sbox_state', 
			mode : 'local',
			triggerAction : 'all',
			forceSelection : true,
			editable : false,
			tabIndex : this.tabIndex++,
			allowBlank : false
		}],
		buttons : [{
				text :'<fmt:message key="button.save" />',
					iconCls : 'button-save',
					tabIndex : this.tabIndex++,
					formBind : true,
					scope : this,
					handler : sboxInfo.doSaveState
				},{
					text : '<fmt:message key="button.cancel" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					handler : sboxInfo.doCancel

				} ]
	})
});
Ext.QuickTips.init();

</script>  

<script>
 // 实例化门户首页的应用实例
 if (Ext.getCmp("PORTAL_SBOX") != null && Ext.getCmp("PORTAL_SBOX").findById("PORTAL-PROPERTY-SBOX") == null) {
	Ext.getCmp("PORTAL_SBOX").add(new SBoxInfoList({
		id : 'PORTAL-PROPERTY-SBOX'
	}));
	Ext.getCmp("PORTAL_SBOX").doLayout();
}
// 实例化岗位设置门户应用的实例
else  if (Ext.getCmp("POSITION_SBOX") != null) {
	Ext.getCmp("POSITION_SBOX").add(new SBoxInfoList());
	Ext.getCmp("POSITION_SBOX").doLayout();
} 
 Ext.getCmp("sBoxInfo").getStore().reload();
 
</script>

<sec:authorize access="hasRole('SBOX_ADD')"> 
	<script type="text/javascript">
	Ext.getCmp("sBoxInfo").getTopToolbar().add({
		iconCls : 'button-add',
		text : '<fmt:message key="sbox.add" />',
		scope : this,
		handler : sboxInfo.doAdd
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SBOX_REJECT')"> 
	<script type="text/javascript">
	Ext.getCmp("sBoxInfo").getTopToolbar().add({	
		iconCls : 'button-return',
		text : '<fmt:message key="sbox.reject" />',
		scope : this,
		handler : sboxInfo.doReject
	}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SBOX_CONFIRM')"> 
	<script type="text/javascript">
	Ext.getCmp("sBoxInfo").getTopToolbar().add({
		iconCls : 'button-ok',
		text : '<fmt:message key="sbox.confirm" />',
		scope : this,
		handler : sboxInfo.doConfirm
		}, '-');
</script>
</sec:authorize>

<sec:authorize access="hasRole('SBOX_STATE_EDIT')"> 
	<script type="text/javascript">
	Ext.getCmp("sBoxInfo").getTopToolbar().add({
		iconCls : 'button-edit',
		text : '<fmt:message key="sbox.edit" />',
		scope : this,
		handler : sboxInfo.doStateEdit
	}, '-');
</script>
</sec:authorize>
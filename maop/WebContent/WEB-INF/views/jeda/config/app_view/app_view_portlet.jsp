<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	var aView = function(){
		Ext.Ajax.request({
			method : 'POST',
			url:'${ctx}/${frameworkPath}/config/app_view/aViewFind',	
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			diasbleCaching:true,
			params : {
				aview_time : 1
			},
			success: function(response) {
				var data = Ext.decode(response.responseText).data;
				//var data = decodeURIComponent(action.result.data);
			  	var avp =Ext.getCmp('APP_VIEW_PANEL');			
				avp.body.update(data); 
			},
			failure : function(form, action) {
				var error = action.result.error;
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
		});
	};
	
	 function show_detail(avd_rel_id , avd_id){
		
			var params =({
				avd_id:avd_id,
				avd_rel_id : avd_rel_id
			});
			app.loadWindow('${ctx}/${frameworkPath}/config/app_view/aViewDetail',params);
				
	} 
	 
	 
	appViewPortlet = Ext.extend(Ext.Panel, {
		id:'APP_VIEW_PORTLET',
		tabIndex : 0,
		constructor:function(cfg){
			Ext.apply(this,cfg);

			/*展示内容的panel*/
			this.panel=new Ext.Panel({
				id:'APP_VIEW_PANEL',
				border:false,
				frame:false,
				height:190,
				autoScroll : false,
				html:''
			});
			
			/*组件的集合*/
			 this.panelGather = new Ext.Panel({
				border:false,
				frame:false,
				autoScroll:false,
				items:[{
					layout:'form',
					defaults:{anchor:'100%'},
					border:false,
					items:[this.panel]
				}]
				
			}); 
			
			appViewPortlet.superclass.constructor.call(this,{
				layout:'form',
				border:false,
				frame:false,
				height:212,
				autoScroll:false,
				monitorValid:true,
				defaults:{
					anchor:'100%',
					msgTarget:'side'
				},
				items:[this.panelGather,
				       {
					layout : 'form',
					labelWidth : 155,
					defaults:{
						anchor:'0,15'
					},
					items:[{
				       xtype:'combo',
				       name:'portlet_combo',
				       id:'portlet_combo',
				       store : new Ext.data.SimpleStore({
				    	   fields : ['value','text'],
				    	   data :[['1','一个月之内'],['2','二个月之内'],['3','三个月之内'],['6','六个月之内']]
				       }),
					    emptyText:'默认为一个月之内的信息',
						mode:'local',
						triggerAction:'all',
						valueField:'value',
						displayField:'text',
						editable : false,
						allowBlank : false,
						listeners : {
							select : function(obj){
								Ext.Ajax.request({
									method : 'POST',
									url:'${ctx}/${frameworkPath}/config/app_view/aViewFind',	
									waitTitle : '<fmt:message key="message.wait" />',
									waitMsg : '<fmt:message key="message.loading" />',
									scope : this,
									diasbleCaching:true,
									params : {
										aview_time : Ext.getCmp('portlet_combo').getValue()
									},
									success: function(response) {
										var data = Ext.decode(response.responseText).data;
									  	var avp =Ext.getCmp('APP_VIEW_PANEL');			
										avp.body.update(data); 
									},
									failure : function(form, action) {
										var error = action.result.error;
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
									}
								});
							}
						}
				       }]
				}]
			});
			aView();
		} ,
		
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
		//数据成功回调
		loadSuccess : function(form, action) {	
			var data = decodeURIComponent(action.result.data);
			alert(data);
		  	var avp =Ext.getCmp('APP_VIEW_PANEL');			
			avp.body.update(data); 
		} 

	});
	
	// 实例化门户首页的应用实例
	if (Ext.getCmp("PORTAL_APP_VIEW_PORTLET") != null && Ext.getCmp("PORTAL_APP_VIEW_PORTLET").findById("PORTAL-APP-VIEW-PORTLET") == null) {
		Ext.getCmp("PORTAL_APP_VIEW_PORTLET").add(new appViewPortlet({
			id : 'PORTAL-APP-VIEW-PORTLET'
		}));
		Ext.getCmp("PORTAL_APP_VIEW_PORTLET").doLayout();
	}
	// 实例化岗位设置门户应用的实例
	else if (Ext.getCmp("POSITION_APP_VIEW_PORTLET") != null) {
		Ext.getCmp("POSITION_APP_VIEW_PORTLET").add(new appViewPortlet());
		Ext.getCmp("POSITION_APP_VIEW_PORTLET").doLayout();
	}
</script>

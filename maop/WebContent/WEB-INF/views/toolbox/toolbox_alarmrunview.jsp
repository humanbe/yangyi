<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var tabActive;
//var task;
    var exc = function(){
		Ext.Ajax.request({
			method : 'POST',
			url : '${ctx}/${appPath}/ToolBoxController/run',	
			scope : this,
			disableCaching : true,
			params : {
				appsyscode:'${param.appsyscode}',
				toolcode:'${param.toolcode}',
				serverips:'${param.serverips}',
				shellname:'${param.shellname}',
				position_type:'${param.position_type}',
				os_type:'${param.os_type}',
				usercode:'${param.usercode}',
				event_id :'${param.event_id}',
				paramdata :'${param.paramdata}',
				osuser:'${param.osuser}',
				group_osuser:'${param.group_osuser}',
				serverGroup :'${param.serverGroup}',
				toolcharset:'${param.toolcharset}'
			}
		});
	};
	
	ToolBoxRun = Ext.extend(Ext.Panel, {
		server : null,
		row : 0,
		task : null,
		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			// 设置基类属性

			ToolBoxRun.superclass.constructor.call(this, {
				layout : 'fit',
				bodyStyle : 'background-color : black',
				autoScroll : true,
				items : []
			});
			this.task = {
				run : function() {
					this.requestData();
				},
				scope : this,
				interval : 2500
			};
			this.on('render', function() {
				Ext.TaskMgr.start(this.task);
			}, this, {
				delay : 500
			}); 
			this.on('destroy', function() {
				Ext.TaskMgr.stop(this.task);
			}, this);
			
		},
		requestData : function() {
			Ext.Ajax.request({
						url : '${ctx}/${appPath}/ToolBoxController/runview',
						method : 'POST',
						callback : this.updateData,
						scope : this,
						params : {
							server:this.server,
							row:this.row,
							shellname:'${param.shellname}'
						}
			});
		},
		updateData : function(options, success, response) {
			if (success) {
				var data = Ext.decode(response.responseText).data;

				for ( var i = 0; i < data.length; i++) {
					Ext.DomHelper.append(this.body, {
						cn : '<font style=\"font-weight: bold;font-size:15px;color:green;line-height:17px\">' + data[i].info + '</font>'
					});
				}
				this.row += data.length;
				var bottom = this.getHeight();
				if(data.length>0){
				this.body.scroll("b", bottom, true);
				}
			}
		}
	});				

	ToolBoxViewRun = Ext.extend(Ext.Panel, {
		// 构造方法
		id:'${param.event_id}'+'${param.toolcode}'+'alarmrunviewID',
		//title:'${param.toolcode}',
		constructor : function(cfg) {
			var serverInfos = Ext.util.JSON.decode(decodeURIComponent('${param.serverips}'));
			Ext.apply(this, cfg);
			var items = [];
			for(var i = 0; i < serverInfos.length; i++){
				items.push({
					title : serverInfos[i].server_ip,
					autoScroll : true,
					//closable : true,
					layout : 'fit',
					items : [ new ToolBoxRun({
						server : serverInfos[i].server_ip
					})]
				});
				
			} 
			//定义
			ToolBoxViewRun.superclass.constructor.call(this, {
				
				//modal : true ,
				closeAction : 'hide',
				width : 600,
				minWidth : 350,
				layout : 'border',
				autoDestroy :false,
				autoScroll : false,
				bodyStyle : 'padding: 5px;',
				items : [ {
					region : 'center',
					xtype : 'tabpanel',
					enableTabScroll : true,
					activeTab : 0,
					deferredRender:false,
					forceLayout : true,
					frame : true ,
					items : [items]
				} ]/* ,
				listeners : {
					scope : this,
					'beforedestroy':function(){
						return false;
					},
					'destroy':function(){
					}
				} */
				
			});
			exc(); 
			 
		}
	          
	});
	
	var runView = new ToolBoxViewRun();
 	var win= Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'AlarmExeVIEW');
   Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'AlarmExeVIEW').window.get(0).add(runView);
   Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'AlarmExeVIEW').window.get(0).doLayout();  
	var handler = function(){
		
		Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'alarmrunviewID').destroy();
		Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'AlarmExeVIEW').window.un('close', handler);
	};
	Ext.getCmp('${param.event_id}'+'${param.toolcode}'+'AlarmExeVIEW').window.on('close', handler);
</script>


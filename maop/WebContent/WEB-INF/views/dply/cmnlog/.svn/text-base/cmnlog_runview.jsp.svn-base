<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义控制台面板
	CmnLogView = Ext.extend(Ext.Panel, {
		row : 0,// Tab键顺序
		task : null,
		// 构造方法
		constructor : function(cfg) {
			Ext.apply(this, cfg);
			// 设置基类属性
			CmnLogView.superclass.constructor.call(this, {
				layout : 'fit',
				autoScroll : true,
				items : [],
				buttons : [ {
					text : '<fmt:message key="button.return" />',
					iconCls : 'button-cancel',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				} ]
			});
			Ext.Ajax.request({
				url : '${ctx}/${managePath}/dplysystemlog/detail',
				method : 'POST',
				callback : this.updateData,
				scope : this,
				params : {
					resultsPath : '${param.resultsPath}'
				}
			});
		},
		updateData : function(options, success, response) {
			if (success) {
				var data = Ext.decode(response.responseText).data;
				for ( var i = 0; i < data.length; i++) {
					Ext.DomHelper.append(this.body, {
						cn : '<font style=\"font-weight: bold;\">'
								+ data[i].info + '</font>' 
					});
				}
				var bottom = this.getHeight();
				this.body.scroll("b", bottom, true);
			}
		},
		doCancel : function() {
			var params = {
				logJnlNo : '${param.logJnlNo}'
			};
			app.loadWindow('${ctx}/${managePath}/dplysystemlog/view', params);
		}
	});
	var cmnLogView = new CmnLogView();
</script>
<script type="text/javascript">
	//构造Window
	var createLogFileWindow = new Ext.Window({
		title : '<fmt:message key="property.seeLog" />',
		animCollapse : true,
		modal : true,
		width : 800,
		height : 500,
		autoScroll : true,
		collapsible : false,
		resizable : false,
		draggable : true,
		closeAction : 'close',
		closeable : true,
		items : [ cmnLogView ]
	});
	app.window.get(0).add(cmnLogView);
	app.window.get(0).doLayout();
</script>

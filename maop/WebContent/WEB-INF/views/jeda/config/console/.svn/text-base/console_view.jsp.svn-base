<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义控制台面板
	ConsoleView = Ext.extend(Ext.Panel, {
		row : 0,// Tab键顺序
		task : null,
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 设置基类属性
			ConsoleView.superclass.constructor.call(this, {
				layout : 'fit',
				autoScroll : true,
				items : []
			});
			this.task = {
				run : function() {
					this.requestData();
				},
				scope : this,
				interval : 5000
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
				url : '${frameworkPath}/console/view/' + this.row,
				method : 'GET',
				callback : this.updateData,
				scope : this
			});
		},
		updateData : function(options, success, response) {
			if (success) {
				var data = Ext.decode(response.responseText).data;

				for ( var i = 0; i < data.length; i++) {
					Ext.DomHelper.append(this.body, {
						cn : '<font style=\"font-weight: bold;\">' + data[i].info + '</font>'
					});

				}
				this.row += data.length;
				var bottom = this.getHeight(); 
				this.body.scroll("b", bottom, true);  
			}
		}
	});

	// 实例化控制台面板,并加入到Tab页中
	Ext.getCmp("CONSOLE_VIEW").add(new ConsoleView());
	// 刷新Tab页布局
	Ext.getCmp("CONSOLE_VIEW").doLayout();
</script>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义列表
	DplyExcuteStatusViewForm = Ext.extend(Ext.Panel,
			{
		tabIndex : 0,// Tab键顺序

		gridStore : null,// 数据列表数据源

		constructor : function(cfg) {// 构造方法

			Ext.apply(this, cfg);
			this.form = new Ext.FormPanel({
				id : 'DplyExcuteStatusViewID',
				title : '<fmt:message key="message.excute.status.operateLog" />',
				region : 'north',
				height:600,
				labelWidth:1,
				buttonAlign : 'center',
				frame : false,
				split : false,
				autoScroll : true,
				collapsible : true,
				collapseMode : 'mini',
				border : false,
				
				defaults : {
					anchor : '98%',
					msgTarget : 'side'
				},
				monitorValid : false,
				// 定义表单组件
				items : [
				{
					xtype : 'textarea',
					name : 'operateLog',
					height : 360,
					tabIndex : this.tabIndex++
				}]

	});
			// 加载表单数据
		    this.form.load({
				url : '${ctx}/${managePath}/moveexport/view',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				params:{
					entryId :'${param.entryId}'
				}
			});  
			
			// 设置基类属性

			DplyExcuteStatusViewForm.superclass.constructor.call(this, {
				layout : 'form',
				border : false,
				monitorValid : true,
				// 定义表单组件
				items : [ this.form ]
			});
		}
		
	});
	app.window.get(0).add(new DplyExcuteStatusViewForm());
	app.window.get(0).doLayout();
</script>


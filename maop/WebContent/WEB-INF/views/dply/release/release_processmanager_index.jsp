<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<% request.getSession().setAttribute("brpmLoginFlag", "true"); 
%>
<script type="text/javascript">
//定义列表
ReleaseProcessManagerIndex = Ext.extend(Ext.Panel, {
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		
		
		var ReleaseProcessPanel = new Ext.Panel({
			split : false,
			margins : '0 0 0 0',
			frame : false,
			 height: 700,
			//autoScroll : true,
			  html:'<iframe scrolling="auto" width="100%" height="100%" src="'+'<fmt:message key="brpm.accessAddress" />'+'"><iframe>'
		});
		// 设置基类属性		ReleaseProcessManagerIndex.superclass.constructor.call(this, {
			
            //title:'发布流程管理',
            layout : 'fit',
            border : false,
            height: 700,
			items : [ ReleaseProcessPanel ]
		}
		);
	}
});
var releaseProcessManagerIndex = new ReleaseProcessManagerIndex();

Ext.getCmp("RELEASE_PROCESS_MANAGER").add(releaseProcessManagerIndex);
Ext.getCmp("RELEASE_PROCESS_MANAGER").doLayout();
</script>

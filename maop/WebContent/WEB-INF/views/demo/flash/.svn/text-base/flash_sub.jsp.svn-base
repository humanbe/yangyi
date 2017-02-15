<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

Ext.ux.WorkFlow.URL = "${ctx}/static/style/flash/workflow.swf";
Ext.ux.WorkFlow.INSTALL_URL = "${ctx}/static/style/flash/playerProductInstall.swf";

//实例化类型数据源
/*
typeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${appPath}/demo/callInside/EPAY0006/EPAY',
	root : 'data'
});
typeStore.load();
*/

// 加载类型数据
var flashSubPanel = new Ext.Panel( {
	layout : 'fit',
	animCollapse: false,
	items : {
		xtype : 'workflow',
		flashVars : {
			appSystemID: "${param.appSystemId}",
			outTrancode : "${param.outTrancode}",
			url : "${ctx}/${appPath}/demo/view/"
		}
	}
});

Ext.getCmp("FlashSubPanel").add(flashSubPanel);
Ext.getCmp("FlashSubPanel").doLayout();

</script>
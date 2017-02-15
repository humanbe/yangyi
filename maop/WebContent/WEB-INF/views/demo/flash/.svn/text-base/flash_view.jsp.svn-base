<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//打开并发序列
function openParallelWorkFlow(appSystemId,outTrancode){ //-----------------------------------flash中调用的方法
	var params = {
			appSystemId : appSystemId,
			outTrancode : outTrancode
	};
	app.loadTab('FlashSubPanel','<fmt:message key="button.view" />'+ appSystemId + '-' + outTrancode + '子流程','${ctx}/${appPath}/demo/flashsub', params);
}


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
var flashPanel = new Ext.Panel( {
	layout : 'fit',
	animCollapse: false,
	items : {
		xtype : 'workflow',
		flashVars : {
			//appSystemID: "${param.appSystemId}",
			//outTrancode : "${param.outTrancode}",
			tranId : "${param.tranId}",
			url : "${ctx}/${appPath}/demo/view/"
		}
	}
});

Ext.getCmp("FlashDemo1").add(flashPanel);
Ext.getCmp("FlashDemo1").doLayout();

</script>
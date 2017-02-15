<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<div id="herderId" style="width: 100%; height: 100%">
	<div style="width: 30%; height: 100%; float: left">
		<img src="${ctx}/static/style/images/logo.png" />
	</div>
	<div style="width: 50%; height: 100%; float: left">
		<!--<div id="currentTimeDiv"  style="height: 100%;border : 1px solid #FFF;font-size:25px;font-family:宋体;text-align:center">-->
		<div id="currentEnvDiv"  style="margin:4px 0 0 0;height:25px;font-size:30px;font-family:隶书;text-align:center;font-weight:bold;color:#FFD700">
		<script type="text/javascript">
		
		var env = '';
		Ext.Ajax.request({
			url : '${ctx}/${frameworkPath}/subitem/getPlatformEnv',
			method : 'POST',
			scope : this,
			async : false, //同步请求
			success : function(resp,opts){
				var respText = Ext.util.JSON.decode(resp.responseText);
				if(respText.info){
					env = respText.info;
				}
			}
		});
		var currentEnv = new Ext.Toolbar.TextItem('运维自动化操作管理平台('+env+'环境)');
		var north = new Ext.Panel({
			   region:"center",
			   // contentEl和autoHeight用来将top.html中图片嵌入到index.html中			   renderTo:"currentEnvDiv",
			   autoHeight:true,
			   margins : "0 0 0 0",// 一个panel的上右左下的边距
			   border:false,
			   items : [currentEnv]
		});
		</script>
		</div>
	</div>
	
	<div style="width: 10%; height: 100%; float: right;">
		<div id="themeSelector">
		<script type="text/javascript">
			var themes = [ 
			               		['深蓝色','darkblue']
			];
	
			var themeStore = new Ext.data.ArrayStore({
				fields : [ 'name', 'value' ],
				data : themes
			});
			var themeSelector = new Ext.form.ComboBox({
				renderTo : 'themeSelector',
				width : 100,
				store : themeStore,
				mode : 'local',
				fieldLabel : '<fmt:message key="application.theme" />',
				emptyText : '<fmt:message key="message.change.theme" />',
				triggerAction : 'all',
				forceSelection : true,
				editable : false,
				valueField : 'value',
				displayField : 'name',
				value : Ext.state.Manager.get("themeName")
			});
			themeSelector.on('select', function(combo, record, index) {
				switchTheme(record.get('value'));
				Ext.state.Manager.set("themeValue", record.get('value'));
				Ext.state.Manager.set("themeName", record.get('name'));
			}, this);
	
			
			//切换主题
			switchTheme(Ext.state.Manager.get("themeValue"));
			
			//指定初始主题、否则为默认default 蓝色blue主题
			document.getElementById("herderId").style.backgroundImage = "url(${ctx}/static/scripts/extjs/resources/images/darkblue/panel/light-hd.gif)";
			Ext.util.CSS.swapStyleSheet('theme', 'static/scripts/extjs/resources/css/xtheme-darkblue.css');
			
			//切换主题
			function switchTheme(theme) {
				if(theme=='darkblue'){
					document.getElementById("herderId").style.backgroundImage = "url(${ctx}/static/scripts/extjs/resources/images/darkblue/panel/light-hd.gif)";
				}else{
					document.getElementById("herderId").style.backgroundImage = "none";
				}
				var themeUrl = 'static/scripts/extjs/resources/css/xtheme-' + theme + '.css';
				Ext.util.CSS.swapStyleSheet('theme', themeUrl);
			}
			
			function logout(){
				Ext.Ajax.request({
					method : 'GET',
					url : '${ctx}/${managePath}/iamstatus/getStatus',
					disableCaching : true,	//禁止缓存
					async : false, //同步请求
					success : function(response,option){
						var text = response.responseText;
						var state = Ext.util.JSON.decode(text).iamStatus;
						if(state == '0'){//正常模式
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '当前页面正试图关闭选项卡, 是否关闭此选项卡?',
								buttons : Ext.MessageBox.OKCANCEL,
								icon : Ext.MessageBox.QUESTION,
								minWidth : 200,
								scope : this,
								fn : function(buttonId) {
									if (buttonId == 'ok') {
										window.opener = null;
										window.open('', '_self');
										window.close();
									}
								}
							});
						}else if(state == '1'){//应急模式							window.location.href="j_spring_security_logout";
						}
					},
					// 请求失败时
					failure : function(response){
						Ext.Msg.show({
							title : '<fmt:message key="message.title"/>',
							msg : '系统应急状态判定请求失败，请重试或联系系统管理员!',
							fn : function() {
								Ext.getCmp("button").focus();
							},
							buttons : Ext.Msg.OK,
							icon : Ext.MessageBox.INFO
						});
					},
					callback : function(options,success,response){
					}
				});
			}
			
		</script>
		</div>
		<a href="${ctx}/?locale=zh_CN"><img title="<fmt:message key="button.cn"/>" src="${ctx}/static/style/images/link/cn.png"></a>&nbsp; 
		<a href="${ctx}/?locale=en_US"><img title="<fmt:message key="button.us"/>" src="${ctx}/static/style/images/link/us.png"></a>&nbsp; 
		<a href="javascript:app.loadSetup();"><img title="<fmt:message key="button.setup"/>" src="${ctx}/static/style/images/link/setup.png" /></a>&nbsp; 
		<a href="javascript:logout()"><img title="<fmt:message key="button.logout"/>" src="${ctx}/static/style/images/sec/logout.png" /></a>&nbsp;
	</div>
</div>
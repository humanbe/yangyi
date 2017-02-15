<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
//业务影响配置展现树
var impactConfTree;
//根节点var root;
//展现树的异步加载器var treeLoader;
//右键非叶子节点弹出的menu
var levelContextMenu;
//右键叶子节点弹出的menu
var leafContextMenu;
//新建调用链表选项
var createItem;
//删除选项
var deleteItem;
//每页显示的记录数
var pageSize = 100;

//影响分类下拉菜单
this.impactTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/BUSINESS_IMPACT_TYPE/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.impactTypeStore.load();
//影响级别下拉菜单
this.impactLevelStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/BUSINESS_IMPACT_LEVEL/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.impactLevelStore.load();
//应用系统下拉菜单
var appsysStoreForTool =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForTool',
		method : 'GET',
		disableCaching : true
	}),
	reader : new Ext.data.JsonReader({}, ['appsysCode','appsysName']),
	listeners : {
		load : function(store){
			if(store.getCount() == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.system.no.authorize" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
	}
});
appsysStoreForTool.load();

//重新加载告警关键字、告警策略
var reloadAlarmAndKeywordForm = function(appsysCode,businessConfId){
	//重新加载告警关键字
	Ext.Ajax.request({
		url : '${ctx}/${appPath}/ToolBoxAlarmController/getImpactKeyWord',
		scope : this,
		params : {
			appsysCode : appsysCode,
			businessConfId : businessConfId
		},
		success : function(resp,opts){
			var respText = Ext.util.JSON.decode(resp.responseText);
			if(respText.keyWord){
				Ext.getCmp('alarmKeyWord').setValue(respText.keyWord);
			}else{
				Ext.getCmp('alarmKeyWord').setValue('');
			}
		}
	});
	//重新加载告警策略配置树
	var alarmConfTree = Ext.getCmp('alarmConfTree') ;
	alarmConfTree.loader.baseParams.appsysCode = appsysCode;
	alarmConfTree.loader.baseParams.businessConfId = businessConfId;
	alarmConfTree.getRootNode().reload();
	alarmConfTree.expandAll();
};

//定义页面对象
ImpactConfPanel = Ext.extend(Ext.Panel, {
	form : null,
	tabIndex : 0,// 查询表单组件Tab键顺序
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
	
		treeLoader = new Ext.tree.TreeLoader({    
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/ToolBoxAlarmController/getImpactConfTree',
			baseParams : {
				appsys_code : '' ,
				business_impact_type : '' ,
				business_impact_level : ''
			}
		});
		
		treeLoader.on('load', function(tree, load, res){
			//如果查询结果为空，显示'没有数据'
			if(!impactConfTree.getRootNode().hasChildNodes()){
				impactConfTree.getRootNode().setText('主目录(<span style="color:#0099FF">没有数据</span>)');
			}
		});
		
		root = new Ext.tree.AsyncTreeNode({
			id : 'treeRoot',
			text : '主目录',
			draggable : false,
			leaf : false,
			cls : 'folder',
			iconCls : 'node-root'
		});
		
		/********右键菜单选项*******/
		createItem = new Ext.menu.Item({
			text : '<fmt:message key="button.create" />', 
			iconCls : 'button-add', 
			handler : this.doCreate
		});
		deleteItem = new Ext.menu.Item({
			text : '<fmt:message key="button.delete" />', 
			iconCls : 'button-delete', 
			handler : this.doDelete
		});
		
		/********右键菜单*******/
		//倒数第二个节点（业务影响级别）增加'右键增加'功能
		levelContextMenu = new Ext.menu.Menu({id : 'levelContextMenu'});
		//levelContextMenu.add(createItem);
		//叶子节点增加'右键删除'功能
		leafContextMenu = new Ext.menu.Menu({id:'leafContextMenu'});
		//leafContextMenu.add(deleteItem);
		
		//业务影响配置目录树
		impactConfTree = new Ext.tree.TreePanel({
			region : 'center',
			xtype : 'treepanel',
			id : 'impactConfInfoTree',
			title : '工具箱告警业务影响配置树',
			width : 330,
			minSize : 330,
			maxSize : 330,
			split : true,
			autoScroll : true,
			/* collapsible=true collapseMode='mini',则可以隐藏该页面模块 */
			loader : treeLoader,
			root : root,
			bodyStyle : 'padding-left:20px;padding-top:2px',
			listeners : {
				scope : this,
				'contextmenu' :function(node, e){
                    node.select();
                    e.preventDefault();
                    try{
                    	if(node.leaf==true && leafContextMenu.items.length > 0){
                    		leafContextMenu.showAt(e.getXY());
                    	}else if(node.getDepth()==3 && levelContextMenu.items.length > 0){
                    		levelContextMenu.showAt(e.getXY());
                    	}
                    }catch(e){
                    }
                },
				'load' : function(n){
					//隐藏告警关键字、告警策略配置页面信息
					Ext.getCmp('alarmKeyWord').setVisible(false);
					Ext.getCmp('alarmConfTree').setVisible(false);
					Ext.getCmp('impact_conf_alarm_save').setVisible(false);
					Ext.getCmp('impact_conf_alarm_reset').setVisible(false);
					//展开根节点下的所有子节点 
					impactConfTree.expandAll();  
				},
				'click' : function(node){
					scop : this ;
					if(node.leaf == true){
						//显示告警关键字、告警策略配置页面信息
						//Ext.getCmp('alarmConfTree').el.up('.x-form-item').setDisplayed(true);
						Ext.getCmp('alarmKeyWord').setVisible(true);
						Ext.getCmp('alarmConfTree').setVisible(true);
						Ext.getCmp('impact_conf_alarm_save').setVisible(true);
						Ext.getCmp('impact_conf_alarm_reset').setVisible(true);
						//业务影响配置编号
						var businessConfId = node.id;
						//系统编码
						var appsysCode = node.parentNode.parentNode.parentNode.id;
						reloadAlarmAndKeywordForm(appsysCode,businessConfId);
					}else{
						//隐藏告警关键字、告警策略配置页面信息
						Ext.getCmp('alarmKeyWord').setVisible(false);
						Ext.getCmp('alarmConfTree').setVisible(false);
						Ext.getCmp('impact_conf_alarm_save').setVisible(false);
						Ext.getCmp('impact_conf_alarm_reset').setVisible(false);
					}
				},
                'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode_1 = node.parentNode; //影响级别目录
				              if(pNode_1 == impactConfTree.getRootNode()) return;
				              if(checked){
					             var cb_1 = pNode_1.ui.checkbox; 
					             if(cb_1){
						         	cb_1.checked = checked; 
						         	cb_1.defaultChecked = checked; 
						     	}
					             pNode_1.attributes.checked=checked;
					          }else{
						    	var _miss=false; 
						     	for(var i=0;i<pNode_1.childNodes.length;i++){
							  		if(pNode_1.childNodes[i].attributes.checked!=checked){
								 		_miss=true;
							    	}
						      	}
								if(!_miss){
									pNode_1.ui.toggleCheck(checked); 
									pNode_1.attributes.checked=checked; 
						     	}
						  	}
				            //影响分类目录
				            if (pNode_1.parentNode != null) {
					            var pNode_2 = pNode_1.parentNode; 
					            if(pNode_2 == impactConfTree.getRootNode()) return;
					            if(checked){
						            var cb_2 = pNode_2.ui.checkbox; 
						            if(cb_2){
							         	cb_2.checked = checked; 
							         	cb_2.defaultChecked = checked; 
							     	}
						            pNode_2.attributes.checked=checked;
						        }else{
							    	var _miss=false; 
							     	for(var i=0;i<pNode_2.childNodes.length;i++){
								  		if(pNode_2.childNodes[i].attributes.checked!=checked){
									 		_miss=true;
								    	}
							      	}
									if(!_miss){
										pNode_2.ui.toggleCheck(checked); 
										pNode_2.attributes.checked=checked; 
							     	}
							  } 
						   } 
					   }
				 }
			},
			tbar :new Ext.Toolbar( {
				items : ['-',{
					iconCls : 'button-excel',
					text : '<fmt:message key="button.excel" />',
					scope : this,
					handler : this.doExportXLS
				}, '-']
			})
		});
		impactConfTree.root.expand(); //展开根节点
		
		// 实例化查询表单
		this.form = new Ext.FormPanel( {
			id : 'impactConfFindFormPanel',
			region : 'east',
			title : '<fmt:message key="button.find" />',
			labelAlign : 'right',
			labelWidth : 80,
			buttonAlign : 'center',
			frame : true,
			split : true,
			width : 280,
			minSize : 280,
			maxSize : 280,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			collapsed : false,
			border : false,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			// 定义查询表单组件
			items : [{
				xtype : 'combo',
				store : appsysStoreForTool,
				fieldLabel : '应用系统名称',
				valueField : 'appsysCode',
				displayField : 'appsysName',
				name : 'appsys_code' ,
				hiddenName : 'appsys_code',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++,
				listeners : {
					scope : this ,
					beforequery : function(e){
						var combo = e.combo;
						combo.collapse();
						 if(!e.forceAll){
							var input = e.query.toUpperCase();
							var regExp = new RegExp('.*' + input + '.*');
							combo.store.filterBy(function(record, id){
								var text = record.get(combo.displayField);
								return regExp.test(text);
							}); 
							combo.restrictHeight();
							combo.expand();
							return false;
						} 
					} 
				}
			},{
				xtype : 'combo',
				store : impactTypeStore,
				fieldLabel : '业务影响分类',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'business_impact_type',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++
			},{
				xtype : 'combo',
				store : impactLevelStore,
				fieldLabel : '业务影响级别',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'business_impact_level',
				mode : 'local',
				triggerAction : 'all',
				forceSelection : true,
				editable : true,
				tabIndex : this.tabIndex++
			}],
			// 定义查询表单按钮
			buttons : [ {
				text : '<fmt:message key="button.ok" />',
				iconCls : 'button-ok',
				scope : this,
				handler : this.doFind
			},{
				text : '<fmt:message key="button.reset" />',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doReset
			}]
		});
		
		// 实例化配置表单
		this.formConf = new Ext.FormPanel( {
			id : 'impactConfConfFormPanel',
			region : 'south',
			title : '配置',
			labelAlign : 'right',
			labelWidth : 120,
			buttonAlign : 'center',
			frame : true, //true：页面底色可变为灰色   false:白色
			split : true,
			height : 350,
			autoScroll : true,
			collapsible : true,
			collapseMode : 'mini',
			border : false,
			defaults : {
				anchor : '99%',
				msgTarget : 'side'
			},
			
			items : [{
				xtype : 'textarea',
				fieldLabel :'告警信息关键字',
				id : 'alarmKeyWord',
				name : 'summarycn',
				height : 60,
				tabIndex : this.tabIndex++
			},{
				xtype : 'treepanel',
				id : 'alarmConfTree',
				fieldLabel : '告警策略名称',
				height : 200,
				frame : true,
				autoScroll: true,
				margins : '0 0 0 5',
				root : new Ext.tree.AsyncTreeNode({
					text : '主目录',
					draggable : false,
					iconCls : 'node-root'
					
				}),
				loader : new Ext.tree.TreeLoader({
					requestMethod : 'POST',
					dataUrl : '${ctx}/${appPath}/ToolBoxAlarmController/buildImpactEventConfTree',
					baseParams:{
						appsysCode:'',
						businessConfId:''
					}
				}),
				listeners : {
					scope : this,
					afterrender : function(tree) {
						tree.expandAll();
					},
					'checkchange': function(node, checked){
				          if (node.parentNode != null) {
				                 node.cascade(function(node){
					                 node.attributes.checked = checked;
					                 node.ui.checkbox.checked = checked;
					              });
					              var pNode_1 = node.parentNode; //分组目录
					              if(pNode_1 == Ext.getCmp('alarmConfTree').getRootNode()) return;
					              if(checked){
						             var cb_1 = pNode_1.ui.checkbox; 
						             if(cb_1){
							         	cb_1.checked = checked; 
							         	cb_1.defaultChecked = checked; 
							     	}
						             pNode_1.attributes.checked=checked;
						          }else{
							    	var _miss=false; 
							     	for(var i=0;i<pNode_1.childNodes.length;i++){
								  		if(pNode_1.childNodes[i].attributes.checked!=checked){
									 		_miss=true;
								    	}
							      	}
									if(!_miss){
										pNode_1.ui.toggleCheck(checked); 
										pNode_1.attributes.checked=checked; 
							     	}
							  	}
					            // 三级目录
					            if (pNode_1.parentNode != null) {
						            var pNode_2 = pNode_1.parentNode; 
						            if(pNode_2 == Ext.getCmp('alarmConfTree').getRootNode()) return;
						            if(checked){
							            var cb_2 = pNode_2.ui.checkbox; 
							            if(cb_2){
								         	cb_2.checked = checked; 
								         	cb_2.defaultChecked = checked; 
								     	}
							            pNode_2.attributes.checked=checked;
							        }else{
								    	var _miss=false; 
								     	for(var i=0;i<pNode_2.childNodes.length;i++){
									  		if(pNode_2.childNodes[i].attributes.checked!=checked){
										 		_miss=true;
									    	}
								      	}
										if(!_miss){
											pNode_2.ui.toggleCheck(checked); 
											pNode_2.attributes.checked=checked; 
								     	}
								  } 
						          // 四级目录
						          if (pNode_2.parentNode != null) {
							            var pNode_3 = pNode_2.parentNode; 
							            if(pNode_3 == Ext.getCmp('alarmConfTree').getRootNode()) return;
							            if(checked){
								            var cb_3 = pNode_3.ui.checkbox; 
								            if(cb_3){
									         	cb_3.checked = checked; 
									         	cb_3.defaultChecked = checked; 
									     	}
								            pNode_3.attributes.checked=checked;
								        }else{
									    	var _miss=false; 
									     	for(var i=0;i<pNode_3.childNodes.length;i++){
										  		if(pNode_3.childNodes[i].attributes.checked!=checked){
											 		_miss=true;
										    	}
									      	}
											if(!_miss){
												pNode_3.ui.toggleCheck(checked); 
												pNode_3.attributes.checked=checked; 
									     	}
									    }
								   }  
							   } 
						   }
					 }
				}
		    }],
			// 定义按钮
			buttons : [{
				text : '<fmt:message key="button.save" />',
				id : 'impact_conf_alarm_save',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doSaveConf
			}, {
				text : '<fmt:message key="button.reset" />',
				id : 'impact_conf_alarm_reset',
				iconCls : 'button-reset',
				scope : this,
				handler : this.doResetConf
			}]
		});
		
		// 设置基类属性		ImpactConfPanel.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			autoScroll : true,
			items : [impactConfTree,this.form,this.formConf]
		});
	},
	
	// 保存告警策略、告警关键字配置信息
	doSaveConf : function(){
		//业务影响配置树选中节点
		var selectNode = impactConfTree.getSelectionModel().getSelectedNode();
		var businessConfId = selectNode.id;
		var appsysCode = selectNode.parentNode.parentNode.parentNode.id;
		//关键字
		var keyword = Ext.getCmp('alarmKeyWord').getValue();
		//告警策略数组
		var event_group = '';
		var nodes = Ext.getCmp('alarmConfTree').getChecked();
		for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){ //只处理叶子节点
				var group = nodes[t].text ;
				event_group = event_group + '|' + (group.substring(0,group.indexOf('(')).trim());
			}
    	}
		if(event_group != ''){
			event_group = event_group.substring(1);
		}
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '确认保存？',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(buttonId) {
				if (buttonId == 'ok') {
					app.mask.show();
					Ext.Ajax.request({
						url : '${ctx}/${appPath}/ToolBoxAlarmController/saveBusinessAlarmAndKeyword',
						scope : this,
						params : {
							appsys_code : appsysCode,
							businessConfId : businessConfId,
							event_group : event_group,
							keyword : keyword
						},
						success : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
							} else if (Ext.decode(response.responseText).success == true) {
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.save.successful" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									fn : function(){
										reloadAlarmAndKeywordForm(appsysCode,businessConfId);
									}
								});
							}
						},
						failure : function() {
							app.mask.hide();
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.save.failed" />',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						}
					});
				}
			}
		});
	},
	
	//重置告警关键字、告警策略
	doResetConf : function(){
		//业务影响配置树选中节点
		var selectNode = impactConfTree.getSelectionModel().getSelectedNode();
		var businessConfId = selectNode.id;
		var appsysCode = selectNode.parentNode.parentNode.parentNode.id;
		reloadAlarmAndKeywordForm(appsysCode,businessConfId);
	},
	
	// 创建新的配置信息
	doCreate : function(){
		var node = impactConfTree.getSelectionModel().getSelectedNode();
		var impactlevel = node.text;
		var impactType = node.parentNode.text;
		var appsysCode = node.parentNode.parentNode.id;
		var params = {
				appsys_code : encodeURIComponent(appsysCode),
				business_impact_type : encodeURIComponent(impactType),
				business_impact_level : encodeURIComponent(impactlevel)
		};
		app.loadWindow('${ctx}/${appPath}/ToolBoxAlarmController/addImpactConfWindow', params);
	},
	
	// 单个删除
	doDelete : function(){
		var node = impactConfTree.getSelectionModel().getSelectedNode();
		//业务影响配置编号
		var businessConfId = node.id;
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '确认删除？',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(buttonId) {
				if (buttonId == 'ok') {
					app.mask.show();
					Ext.Ajax.request({
						url : '${ctx}/${appPath}/ToolBoxAlarmController/deleteImpactConf',
						scope : this,
						params : {
							businessConfId : businessConfId,
							_method : 'delete'
						},
						success : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
							} else if (Ext.decode(response.responseText).success == true) {
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.delete.successful" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									fn : function(){
										Ext.apply(impactConfTree.loader.baseParams, Ext.getCmp('impactConfFindFormPanel').getForm().getValues());
										impactConfTree.getRootNode().reload();
										impactConfTree.expandAll();
									}
								});
							}
						},
						failure : function() {
							app.mask.hide();
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.delete.failed" />',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						}
					});
					
				}
			}
		});
	},
	
	// 根据勾选复选框进行批量删除
	doMultDelete : function(){
		//业务影响配置编号数组[businessConfId]
		var businessConfIds = [];
		var businessConfId ; 
		var nodes = impactConfTree.getChecked();
		if(nodes.length>0){
			for(var t=0 ; t<nodes.length ; t++){
				if(nodes[t].leaf == true){ //只处理叶子节点
					businessConfId = nodes[t].id;
					businessConfIds.push(businessConfId);
				}
	    	}
			if(businessConfIds!=null && businessConfIds.length>0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '确认删除？',
					buttons : Ext.MessageBox.OKCANCEL,
					icon : Ext.MessageBox.QUESTION,
					minWidth : 200,
					scope : this,
					fn : function(buttonId) {
						if (buttonId == 'ok') {
							app.mask.show();
							Ext.Ajax.request({
								url : '${ctx}/${appPath}/ToolBoxAlarmController/multDeleteImpactConf',
								scope : this,
								params : {
									businessConfIds : businessConfIds
								},
								success : function(response, options) {
									app.mask.hide();
									if (Ext.decode(response.responseText).success == false) {
										var error = Ext.decode(response.responseText).error;
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:' + error,
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.ERROR
										});
									} else if (Ext.decode(response.responseText).success == true) {
										Ext.Msg.show( {
											title : '<fmt:message key="message.title" />',
											msg : '<fmt:message key="message.delete.successful" />',
											minWidth : 200,
											buttons : Ext.MessageBox.OK,
											icon : Ext.MessageBox.INFO,
											fn : function(){
												//关闭窗口
												app.closeWindow();
												//父页面重新加载数据
												var impactConfInfoTree = Ext.getCmp('impactConfInfoTree');
												Ext.apply(impactConfInfoTree.loader.baseParams,Ext.getCmp('impactConfFindFormPanel').getForm().getValues());
												impactConfInfoTree.getRootNode().reload();
												impactConfInfoTree.expandAll();
											}
										});
									}
								},
								failure : function() {
									app.mask.hide();
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.delete.failed" />',
										minWidth : 200,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
								}
							});
							
						}
					}
				});
			}else{
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '请至少勾选一个叶子节点！',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			}
		}else{
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '请勾选需要删除的节点！',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 查询调用链表
	doFind : function() {
		Ext.apply(impactConfTree.loader.baseParams, this.form.getForm().getValues());
		//重新加载树形菜单
		impactConfTree.getRootNode().reload();
		//完全展开树形菜单
		impactConfTree.expandAll();
	},
	// 重置查询表单
	doReset : function() {
		this.form.getForm().reset();
	},
	// 导出查询数据xls事件
	doExportXLS : function() {
		window.location = '${ctx}/${appPath}/ToolBoxAlarmController/excel.xls?' + encodeURI(Ext.getCmp('impactConfFindFormPanel').getForm().getValues(true));
	}
});

var newImpactConfTree = new ImpactConfPanel();
</script>

<sec:authorize access="hasRole('TOOL_IMPACT_CONF_CREATE')">
<script type="text/javascript">
levelContextMenu.add(createItem);
</script>
</sec:authorize>

<sec:authorize access="hasRole('TOOL_IMPACT_CONF_DELETE')">
<script type="text/javascript">
leafContextMenu.add(deleteItem);
</script>
</sec:authorize>

<sec:authorize access="hasRole('TOOL_IMPACT_CONF_DELETE')">
<script type="text/javascript">
impactConfTree.getTopToolbar().add({
	iconCls : 'button-delete',
	id : 'treeDelete',
	text : '<fmt:message key="button.delete" />',
	scope : newImpactConfTree,
	handler : newImpactConfTree.doMultDelete
	},'-');
</script>
</sec:authorize>

<script type="text/javascript">
Ext.getCmp("BUSINESS_IMPACT_CONF").add(newImpactConfTree);
Ext.getCmp("BUSINESS_IMPACT_CONF").doLayout();
</script>
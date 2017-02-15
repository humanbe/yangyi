<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var keywords_field_type_one= '${param.field_type_one}' ;
var keywords_field_type_two= '${param.field_type_two}' ;
var keywords_field_type_twoStore;
var keywords_field_type_threeStore;
	tookboxKeyword = Ext.extend(
					Ext.Panel,
					{
						gridStore : null,// 数据列表数据源						grid : null,// 数据列表组件
						form : null,// 查询表单组件
						tabIndex : 0,// 查询表单      组件Tab键顺序						csm : null,// 数据列表选择框组件						constructor : function(cfg) {// 构造方法							Ext.apply(this, cfg);
							//禁止IE的backspace键(退格键)，但输入文本框时不禁止
							Ext.getDoc().on('keydown',function(e) {
												if (e.getKey() == 8
														&& e.getTarget().type == 'text'
														&& !e.getTarget().readOnly) {

												} else if (e.getKey() == 8
														&& e.getTarget().type == 'textarea'
														&& !e.getTarget().readOnly) {

												} else if (e.getKey() == 8) {
													e.preventDefault();
												}
											});

						

							this.ServerGroupStore = new Ext.data.JsonStore(
									{
										autoDestroy : true,
										url : '${ctx}/${frameworkPath}/item/SERVER_GROUP/sub',
										root : 'data',
										fields : [ 'value', 'name' ]
									});
							this.ServerGroupStore.load();


							 this.appsys_Store =  new Ext.data.Store({
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
								this.appsys_Store.load(); 
							
							this.userStore =  new Ext.data.Store({
								proxy: new Ext.data.HttpProxy({
									url : '${ctx}/${appPath}/jobdesign/getUsers',
									method : 'GET',
									disableCaching : true
								}),
								reader : new Ext.data.JsonReader({}, ['username','name'])
							});
							this.userStore.load();

							this.field_type_oneStore = new Ext.data.Store(
									{
										proxy: new Ext.data.HttpProxy({
											url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
											method: 'POST'
										}),
										reader: new Ext.data.JsonReader({}, ['field_type_one'])
										
									});
									this.field_type_oneStore.load();
									//二级分类
									keywords_field_type_twoStore = new Ext.data.Store(
											{
												proxy: new Ext.data.HttpProxy({
													url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
													method: 'POST'
												}),
												reader: new Ext.data.JsonReader({}, ['field_type_two']),
												baseParams : {
													field_type_one : keywords_field_type_one
												}
											});
									keywords_field_type_twoStore.load();
									
									//三级分类
									keywords_field_type_threeStore = new Ext.data.Store(
											{
												proxy: new Ext.data.HttpProxy({
													url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
													method: 'POST'
												}),
												reader: new Ext.data.JsonReader({}, ['field_type_three']),
										    	baseParams : {
										    		field_type_one : keywords_field_type_one,
										    		field_type_two : keywords_field_type_two
											       }
											});
									keywords_field_type_threeStore.load();
									

							this.form = new Ext.FormPanel(
									{
										 id : 'KeywordsFormIndex',
										 region : 'center',
										 frame : true,
										 split : false,
										 collapseMode : 'mini',
										 autoScroll: true,
						                 autoWidth :true,
						                 border:false,
						                 iconCls : 'menu-node-change',
						                 buttonAlign : 'center',
						                 defaults: {anchor : '90%'},
						                 border:false,
						                 labelAlign : 'right',
						                 labelWidth  : 150,
										// 定义查询表单组件
										items : [ {
											layout:'column',
											items:[{
											     columnWidth:.5,
											     layout:'form',
							          	  
							                items : [{
												xtype : 'combo',
												store : this.appsys_Store,
												fieldLabel : '<fmt:message key="toolbox.appsys_code" />',
												name : 'appsys_code',
												valueField : 'appsysCode',
												displayField : 'appsysName',
												hiddenName : 'appsys_code',
												readOnly:true,
												mode : 'local',
												triggerAction : 'all',
												forceSelection : true,
												editable : false,
												anchor:'100%',
												disabled:true,
												tabIndex : this.tabIndex++

											},

											{
												xtype : 'textfield',
												fieldLabel : '<fmt:message key="toolbox.tool_code" />',
												name : 'tool_code',
												id:'tool_code_keywordsID',
												maxLength:80,
												anchor:'100%',
												readOnly:true,
												disabled:true,
												tabIndex : this.tabIndex++,
												allowBlank : false
											},								
											{
												xtype : 'textfield',
												fieldLabel : '<fmt:message key="toolbox.tool_name" />',
												name : 'tool_name',
												tabIndex : this.tabIndex++,
												readOnly:true,
												anchor:'100%',
												disabled:true,
												allowBlank : false

											}]
											},{
											     columnWidth:.5,
											     layout:'form',
											    
											     items:[{

														xtype : 'combo',
														store : this.field_type_oneStore,
														fieldLabel : '<fmt:message key="toolbox.field_type_one" />',
														name : 'field_type_one',
														valueField : 'field_type_one',
														displayField : 'field_type_one',
														hiddenName : 'field_type_one',
														mode : 'local',
														triggerAction : 'all',
														anchor:'100%',
														forceSelection : true,
														editable : false,
														disabled:true,
														tabIndex : this.tabIndex++,
														allowBlank : false
													},
													{
														xtype : 'combo',
														store : keywords_field_type_twoStore,
														fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
														name : 'field_type_two',
														valueField : 'field_type_two',
														displayField : 'field_type_two',
														hiddenName : 'field_type_two',
														mode : 'local',
														triggerAction : 'all',
														forceSelection : true,
														anchor:'100%',
														editable : false,
														disabled:true,
														tabIndex : this.tabIndex++
													},
													{
														xtype : 'combo',
														store : keywords_field_type_threeStore,
														fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
														name : 'field_type_three',
														valueField : 'field_type_three',
														displayField : 'field_type_three',
														hiddenName : 'field_type_three',
														mode : 'local',
														triggerAction : 'all',
														anchor:'100%',
														forceSelection : true,
														editable : false,
														disabled:true,
														tabIndex : this.tabIndex++
													}]
											}]
					            },{
													xtype : 'textarea',
													fieldLabel :'<fmt:message key="toolbox.tool_desc" />',
													name : 'tool_desc',
													height : 60,
													
													maxLength:200,
													disabled:true,
													tabIndex : this.tabIndex++
												},

												{
												xtype : 'treepanel',
												fieldLabel : '<fmt:message key="toolbox.alarm_policy_name" />', 
												id: 'policy_KeywordID',
												height : 260,
												frame : true,
												autoScroll: true,
												margins : '0 0 0 5',
												root : new Ext.tree.AsyncTreeNode({
													text : '${param.appsys_code}',
													draggable : false,
													iconCls : 'node-root' 
													//id : 'keyrootId'
												}),
												loader : new Ext.tree.TreeLoader({
													requestMethod : 'POST',
													dataUrl : '${ctx}/${appPath}/ToolBoxController/getEventGroupTree',
													baseParams:{
														appsys_code:'${param.appsys_code}',
														tool_code:'${param.tool_code}'
													}
												}),
												listeners : {
													scope : this,
													afterrender : function(tree) {
														tree.expandAll();
														//tree.getRootNode().expand(); 
													},
													
													'checkchange': function(node, checked){
												          if (node.parentNode != null) {
												                 node.cascade(function(node){
													                 node.attributes.checked = checked;
													                 node.ui.checkbox.checked = checked;
													              });
													              var pNode_1 = node.parentNode; //分组目录
													              if(pNode_1 == Ext.getCmp('policy_KeywordID').getRootNode()) return;
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
														            if(pNode_2 == Ext.getCmp('policy_KeywordID').getRootNode()) return;
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
															            if(pNode_3 == Ext.getCmp('policy_KeywordID').getRootNode()) return;
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
										},{
											xtype : 'textfield',
											fieldLabel :'<fmt:message key="toolbox.alarm_policy_name" />', 
											name:'event_group',
											anchor : '100%',
											id : 'event_group_keywordID',
											hidden:true,
											tabIndex : this.tabIndex++
										},
										{
											xtype : 'textarea',
							 				fieldLabel :'<fmt:message key="toolbox.alarm_keyword" />', 
											
											id : 'summarycn_keywordID',
											name : 'summarycn',
											height : 200,
											height : 100,
											maxLength:500,
											tabIndex : this.tabIndex++
										}, 
										{
											xtype : 'label',
											anchor : '100%',
											text:  '(匹配规则说明: &表示与; |表示或)',
											style : 'margin-left:160;background:#F0F0F0;color:red'
										}],
										buttons : [{
												text :'<fmt:message key="toolbox.submit" />', 
												iconCls : 'button-save',
												formBind : true,
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doSave
											},{
												text : '<fmt:message key="button.cancel" />',
												iconCls : 'button-cancel',
												tabIndex : this.tabIndex++,
												scope : this,
												handler : this.doCancel

											} ]
									});
							
							
							
							// 加载表单数据
							this.form.load({
										url : '${ctx}/${appPath}/ToolBoxController/view',
										method : 'POST',
										waitTitle : '<fmt:message key="message.wait" />',
										waitMsg : '<fmt:message key="message.loading" />',
										scope : this,
										params:{
											tool_code :'${param.tool_code}',
											appsys_code:'${param.appsys_code}'
										}
									});
							// 设置基类属性
							tookboxKeyword.superclass.constructor.call(this,
									{
										title : '<fmt:message key="toolbox.Matching_monitoring_information" />', 
										layout : 'border',
										border : false,
										items : [ this.form ]
									});
						},
						
						doCancel : function(){
							app.closeTab('TOOLBOX_KEYWORDS');
						},
						doSave : function() { 
							
							var nodes = Ext.getCmp('policy_KeywordID').getChecked();
					    	var EventGroupInfos = '';
					    	for(var t=0 ; t<nodes.length ; t++){
								if(nodes[t].leaf == true){
									var py=nodes[t].text;
									var len=py.indexOf('(');
									EventGroupInfos=EventGroupInfos+"|"+py.substring(0,len).trim() ;
								}
					    	}
					    	if(EventGroupInfos!=''){
					    		EventGroupInfos=EventGroupInfos.substring(1);
					    	}
					    	if(EventGroupInfos.length<1000){
					    		Ext.getCmp('event_group_keywordID').setValue(EventGroupInfos);
					    		Ext.Ajax.request({
									method : 'POST',
									url : '${ctx}/${appPath}/ToolBoxAlarmController/editkeywords',
									scope : this,
									success : this.saveSuccess,
									failure : this.saveFailure,
									params : {
										tool_code :Ext.getCmp('tool_code_keywordsID').getValue(),
										event_group : Ext.getCmp('event_group_keywordID').getValue(),
										summarycn :Ext.getCmp('summarycn_keywordID').getValue() //,
									}
								}); 
					    	}else{
					    		Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '策略太多，超出数据库策略最大值1500',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
					    	}
					    	
							  
									
								},
					
								//保存失败
								saveFailure : function(form, action) {

									var error = decodeURIComponent(action.result.error);
									Ext.Msg.show({
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'
														+ error,
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.ERROR
											});
								},
								
								// 保存成功回调
								saveSuccess : function(form, action) {

									 Ext.Msg.show({
												title : '<fmt:message key="message.title" />',
												msg : '<fmt:message key="message.save.successful" />',
												buttons : Ext.MessageBox.OK,
												icon : Ext.MessageBox.INFO,
												minWidth : 200,
												fn : function() {
													app.closeTab('TOOLBOX_KEYWORDS');
													Ext.getCmp("toolBoxpanelid").getStore().reload();
												}
									}); 
								}
					});
	var  Keywords=new tookboxKeyword();
	</script>

	<script type="text/javascript">
  
	Ext.getCmp("TOOLBOX_KEYWORDS").add(Keywords);
	Ext.getCmp("TOOLBOX_KEYWORDS").doLayout();
</script>

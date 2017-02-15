<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

Tool_box_viewDesc_Info= Ext.extend(Ext.FormPanel, {
	row : 0,// Tab键顺序    form: null,
    defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性
		//数据字典
	 	this.tool_statusStore = new Ext.data.JsonStore(
							{
								autoDestroy : true,
								url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
								root : 'data',
								fields : [ 'value', 'name' ]
							});
		this.tool_statusStore.load();
		this.tool_typeStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_TYPE/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_typeStore.load();
	
		
		this.tool_authorize_flagStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_authorize_flagStore.load();
		
		this.authorize_level_typeStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.authorize_level_typeStore.load();
		
	
		this.tool_stausStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/TOOL_STATUS/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.tool_stausStore.load();
		
		
	
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
		
		
		//一级分类
		this.tool_field_type_oneStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTone', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_one'])
			
		});
		this.tool_field_type_oneStore.load();
	

		this.form = new Ext.FormPanel({
					buttonAlign : 'center',
					labelAlign : 'right',
					lableWidth : 15,
					autoHeight: false,
					frame : true,
					monitorValid : true,
					defaults : {
						anchor : '90%',
						msgTarget : 'side'
					},
					items :  [ {
						layout:'column',
						items:[{
						     columnWidth:.5,
						     layout:'form',
		          	  
		                items : [ {
						xtype : 'combo',
						store : this.appsys_Store,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
						id:'appsys_codeview_DESCID',
     					name : 'appsys_code',
						valueField : 'appsysCode',
						displayField : 'appsysName',
						hiddenName : 'appsys_code',
						mode : 'local',
						triggerAction : 'all',
						forceSelection : true,
						anchor:'100%',
						style  : 'background : #F0F0F0' , 
						readOnly:true,
						tabIndex : this.tabIndex++,
						allowBlank : false,
						 listeners : {
							
								scope : this,
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
				},
				{
					xtype : 'textfield',
					id : 'tool_code_view',
					fieldLabel : '<fmt:message key="toolbox.tool_code" />',
					name : 'tool_code',
					maxLength:80,
					readOnly:true,
					hidden:true,
					style  : 'background : #F0F0F0' , 
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				
				{
					xtype : 'combo',
					store : this.authorize_level_typeStore,
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
					name : 'authorize_level_type',
					id:'authorize_level_typeview_DESCID',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'authorize_level_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					anchor:'100%',
					readOnly:true,
					viewable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : this.tool_authorize_flagStore,
					fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
					name : 'tool_authorize_flag',
					id:'tool_authorize_flagview_DESCID',
					valueField : 'value',
					displayField : 'name',
					anchor:'100%',
					hiddenName : 'tool_authorize_flag',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					viewable : false,
					readOnly:true,
					tabIndex : this.tabIndex++,
					allowBlank : false
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
					name : 'tool_name',
					id:'tool_nameview_DESCID' ,
					anchor:'100%',
					maxLength:100,
					readOnly:true,
					tabIndex : this.tabIndex++,
					allowBlank : false
				}]
						},{
						     columnWidth:.5,
						     layout:'form',
						    
						     items:[{
									xtype : 'combo',
									store : this.tool_field_type_oneStore,
									fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.field_type_one" />',
									name : 'field_type_one',
									id:'field_type_oneview_DESCID',
									valueField : 'field_type_one',
									displayField : 'field_type_one',
									hiddenName : 'field_type_one',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									viewable : false,
									readOnly:true,
									anchor:'100%',
									tabIndex : this.tabIndex++,
									allowBlank : false
								},
								{
									xtype : 'combo',
									store : this.tool_field_type_oneStore,
									fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
									name : 'field_type_two',
									id:'field_type_twoview_DESCID',
									valueField : 'field_type_two',
									displayField : 'field_type_two',
									hiddenName : 'field_type_two',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									readOnly:true,
									anchor:'100%',
									viewable : false,
									tabIndex : this.tabIndex++
								},
								{
									xtype : 'combo',
									store : this.tool_field_type_oneStore,
									fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
									name : 'field_type_three',
									id:'field_type_threeview_DESCID',
									valueField : 'field_type_three',
									displayField : 'field_type_three',
									hiddenName : 'field_type_three',
									mode : 'local',
									triggerAction : 'all',
									readOnly:true,
									forceSelection : true,
									anchor:'100%',
									viewable : false,
									tabIndex : this.tabIndex++
								},{
									xtype : 'combo',
									store : this.tool_typeStore,
									fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
									name : 'tool_type',
									id:'tool_typeview_DESCID',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_type',
									mode : 'local',
									readOnly:true,
									anchor:'100%',
									triggerAction : 'all',
									forceSelection : true,
									viewable : false,
									tabIndex : this.tabIndex++,
									allowBlank : false
								}]
						}]
            },{
            	
            	xtype : 'htmleditor',
				fieldLabel :'<fmt:message key="toolbox.tool_desc" />',
				name : 'tool_desc',
				enableSourceEdit:false,
				enableFontSize:false,
				enableAlignments:false,
				enableFont:false,
				enableLists:false,
				enableColors:false,
				enableFormat : false,	
				enableLinks:false,
				height : 120,
				maxLength:660,
				readOnly:true,
				tabIndex : this.tabIndex++
				 
            },{
				xtype : 'combo',
				store : this.tool_statusStore,
				fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_status" />',
				name : 'tool_status',
				valueField : 'value',
				displayField : 'name',
				hiddenName : 'tool_status',
				mode : 'local',
				triggerAction : 'all',
				readOnly:true,
				style  : 'background : #F0F0F0' , 
				forceSelection : true,
				editable : false,
				anchor:'90%',
				tabIndex : this.tabIndex++,
				allowBlank : false
			},
			{
				xtype : 'textarea',
				fieldLabel :'<fmt:message key="toolbox.tool_returnreasons" />',
				name : 'tool_returnreasons',
				readOnly:true,
				style  : 'background : #F0F0F0' , 
				height : 50,
				maxLength:200,
				anchor:'90%',
				readOnly:true,
				tabIndex : this.tabIndex++

			},
			{
				xtype : 'textfield',
				fieldLabel :'<fmt:message key="toolbox.tool_creator" />',
				name : 'tool_creator',
				anchor:'90%',
				readOnly:true,
				tabIndex : this.tabIndex++

			},
			{
				xtype : 'textfield',
				fieldLabel :'<fmt:message key="toolbox.tool_modifier" />',
				name : 'tool_modifier',
				anchor:'90%',
				readOnly:true,
				tabIndex : this.tabIndex++

			},
			{
				xtype : 'datefield',
				fieldLabel :'<fmt:message key="toolbox.tool_created_time" />',
				name : 'tool_created_time',
			    format : 'Y-m-d H:i:s',
			    anchor:'90%',
			    readOnly:true,
				tabIndex : this.tabIndex++

			},
			{
				xtype : 'datefield',
				fieldLabel :'<fmt:message key="toolbox.tool_updated_time" />',
				name : 'tool_updated_time',
				format : 'Y-m-d H:i:s',
				anchor:'90%',
				readOnly:true,
				tabIndex : this.tabIndex++

			}
             ]
		 });
		

		

		this.fivePanel = new Ext.Panel({
			
              title:'匹配关键字',
			  frame : true,
			  split : false,
			  collapseMode : 'mini',
              layout:'column',
              border:false,
              readOnly:true,
              iconCls : 'menu-node-change',
              layout: 'form',
              defaults: {anchor:'90%'},
              border:false,
              labelWidth : 150,
              labelAlign : 'right',
              items : [{
					xtype : 'textfield',
					fieldLabel :'告警策略名称',
					name:'event_group',
					readOnly:true,
					id : 'event_group_view_DESCID',
				    hidden:true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textarea',
					fieldLabel :'告警信息关键字',
					name : 'summarycn',
					readOnly:true,
					height : 60,
					tabIndex : this.tabIndex++
				}, 
				{
					xtype : 'label',
					text: '(匹配规则说明: &表示与; |表示或)',
					style : 'margin-left:160;color:red'
				},
				{
					xtype : 'treepanel',
					fieldLabel : '告警策略名称',
					id: 'policy_view_DESCID',
					height : 300,
					frame : true,
					autoScroll: true,
					
					root : new Ext.tree.AsyncTreeNode({
						text : '${param.appsys_code}',
						draggable : false,
						iconCls : 'node-root'
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
						},
						
						
						'checkchange': function(node, checked){
					          if (node.parentNode != null) {
					                 node.cascade(function(node){
						                 node.attributes.checked = checked;
						                 node.ui.checkbox.checked = checked;
						              });
						              var pNode_1 = node.parentNode; //分组目录
						              if(pNode_1 == Ext.getCmp('policy_view_DESCID').getRootNode()) return;
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
							            if(pNode_2 == Ext.getCmp('policy_view_DESCID').getRootNode()) return;
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
								            if(pNode_3 == Ext.getCmp('policy_view_DESCID').getRootNode()) return;
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
			}]
             
	    
	} );
		 var i = 0;  
		    function cardHandler(direction) {  
		        if (direction == -1) {  
		            i--;  
		            if (i < 0) {  
		                i = 0;  
		            }
		           
		           
		        }  
		        if (direction == 1) {  
		            i++; 
		           
		            if (i > 1) {  
		                i = 1;  
		                return false;  
		            }  
		        }  
		       
		        var btnNext = Ext.getCmp("tool_move-next_viewDesc");  
		        var btnPrev = Ext.getCmp("tool_move-prev_viewDesc");  
		       var  btnSave_viewDesc = Ext.getCmp("tool_move-save_viewDesc");  
		        if (i == 0) {  
		        	btnSave_viewDesc.enable(); 
		            btnNext.enable();  
		            btnPrev.disable();  
		        }  
		        if (i == 1) {
		           
		        	btnSave_viewDesc.enable();
					 btnNext.disable();  
			         btnPrev.enable(); 
				} 
		        this.cardPanel.getLayout().setActiveItem(i);  
		    };  
		//CARD总面板  
	    this.cardPanel = new Ext.Panel({  
	        renderTo: document.body,  
	        height: 670,  
	        layout: 'card',
	        layoutConfig :{
	        	deferredRender : true
	        },
	        activeItem: 0,  
	        tbar: ['-', {  
	            id: 'tool_move-prev_viewDesc',  
	            iconCls : 'button-previous',
	            disabled : true ,
				text : '<fmt:message key="job.stepBefore" />',  
	            handler: cardHandler.createDelegate(this, [-1]) 
	        },'-',
	        {  
	            id: 'tool_move-save_viewDesc',  
	            iconCls : 'button-close',
				text : '<fmt:message key="button.close" />',
	            handler:this.doClose
	        },'-',  
	        {  
	            id: 'tool_move-next_viewDesc',  
	            iconCls : 'button-next',
				text : '<fmt:message key="job.stepNext" />',
	            handler: cardHandler.createDelegate(this, [1])  
	        }],  
	        items: [this.form,this.fivePanel ]  
	    });
		// 设置基类属性
		Tool_box_viewDesc_Info.superclass.constructor.call(this,{
            title : '<fmt:message key="title.form" />',
            labelAlign : 'right',
            buttonAlign : 'center',
            frame : true,
            autoScroll : true,
			layout : 'form',
			border : false,
			buttonAlign : 'center',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			items : [  this.cardPanel]
		});
		// 加载表单数据
		this.form.load({
					url : '${ctx}/${appPath}/ToolBoxController/dblview',
					method : 'POST',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					
					params:{
						tool_code :'${param.tool_code}',
						appsys_code:'${param.appsys_code}'
					}
				});
		
	},
    // 取消操作
	doClose : function() {
		app.closeTab('TOOL_BOX_VIEWDESC_INFO');
	}
		


});
var tool_box_viewDesc_Info = new Tool_box_viewDesc_Info();

Ext.getCmp("TOOL_BOX_VIEWDESC_INFO").add(tool_box_viewDesc_Info);
Ext.getCmp("TOOL_BOX_VIEWDESC_INFO").doLayout();

</script>
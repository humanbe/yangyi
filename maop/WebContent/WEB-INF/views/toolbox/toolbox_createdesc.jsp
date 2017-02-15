<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var field_type_twoStore_desc;
var field_type_threeStore_desc;
var toolcode_desc='';



var OccfileListStore = new Ext.data.Store(
{
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/ToolBoxController/getOccFileList', 
		method: 'POST'
	}),
	reader: new Ext.data.JsonReader({}, ['file_id','file_name'])
	
});
OccfileListStore.on('beforeload',function(){
	OccfileListStore.baseParams.tool_code =toolcode_desc;
},this); 

   
//-------------------------------htmleditor------------------------------------
var htmleditorCreateDesc = Ext.extend(Ext.form.HtmlEditor, {

	addImage : function() {
	   var editor = this;
	   if (Ext.isIE) {
       	var doc = editor.getDoc();
       	var range =doc.selection.createRange();
       	var value =range.text;
       	if(range.text.length==0){
       		Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '请选择文字',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.WARNING
			});
       		return;
       	}
      var  	obj = editor;
      var  oldval= obj.getValue();
      editor.insertAtCursor("|+|"+value+"|+|");
	   }
	   
	   var tool_creatDesc_form = new Ext.FormPanel({
	    region : 'center',
	    labelWidth : 55,
	    bodyStyle : 'padding:5px 5px 0',
	    autoScroll : true,
	    border : false,
	    items : [{
	    	xtype : 'combo',
	    	id: 'toolbox_createdesc_fujianId',
	    	name:'fujian',
	    	hiddenName :'fujian',
			store : OccfileListStore,
	       fieldLabel : '选择附件',
            valueField : 'file_id',
			displayField : 'file_name',
			mode : 'local',
	       editable : false,	       
	       height : 25,
	       anchor : '98%',
	       listeners : {
				
				scope : this,
				 beforequery : function(e){
					 Ext.getCmp("toolbox_createdesc_fujianId").store=OccfileListStore;
			}
		 }  
	      }],
	    buttons : [{
	     text : '链接',
	     type : 'submit',
	     handler : function(o) {
	    	 var fileId=  Ext.getCmp("toolbox_createdesc_fujianId").getValue();
	    	 if(fileId!=''){
	    	 var fileURL = "<a href=\"javascript:dowmload_file_exc(\'"+fileId+"\')\">"+value+"</a>";
	    	 var  val2= obj.getValue();
    	   var newval=val2.replace('|+|'+value+'|+|',fileURL);
    	   obj.setValue(newval);
    	   CREATE_fujian_win.close(this);
	     }else{
	    		 Ext.Msg.show({
	 				title : '<fmt:message key="message.title" />',
	 				msg : '请选择附件',
	 				minWidth : 200,
	 				buttons : Ext.MessageBox.OK,
	 				icon : Ext.MessageBox.WARNING
	 			});
	    	 }
	     }
	    }, {
	     text : '关闭',
	     type : 'submit',
	     handler : function() {
	    	 obj.setValue(oldval);
	    	 CREATE_fujian_win.close(this);
	       }
	    }]
	   });

	   var CREATE_fujian_win = new Ext.Window({
	      title : "附件选择",
	      width : 400,
	      height : 120,
	      modal : true,
	      border : false,
	      iconCls:'icon-uploadpic',
	      layout : "fit",
	      items : tool_creatDesc_form

	     });
	   CREATE_fujian_win.show();
	  
	},
	createToolbar : function(editor) {
		htmleditorCreateDesc.superclass.createToolbar.call(this, editor);
	   
	   this.tb.insertButton(16, {
			   text:'附件链接',
		      iconCls : "button-impage",
		      handler : this.addImage,
		      tooltip : "添加链接",
		      scope : this
		     });
	   
	}
	});
	
	Ext.reg('htmleditorCreateDesc', htmleditorCreateDesc);
//------------------------------------------------------------------------------




//查看关联软件日志信息
function dowmload_occfile(){
 var grid = Ext.getCmp("tool_box_crerate_FILES");
 var record = grid.getSelectionModel().getSelected();
		var tool_code = record.data.tool_code;
		var file_id= record.data.file_id;
		var file_type= record.data.file_type;
		var file_name= record.data.file_name;
		
 
 window.location = '${ctx}/${appPath}/ToolBoxController/downloadOccFiles.file?tool_code='+tool_code+'&file_id='+file_id+'&file_type='+file_type+'&file_name='+encodeURI(encodeURI(file_name));
}
Tool_box_Desc_Info= Ext.extend(Ext.FormPanel, {
	row : 0,// Tab键顺序    form: null,
    toolcode: null,
    defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
	constructor : function(cfg) {
		Ext.apply(this, cfg);
		// 设置基类属性
		//数据字典
		
		//toolcode
		

		this.toolcodeStore = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getDesc_toolcode', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['toolcode'])
			
		});
		this.toolcodeStore.load();
		this.toolcodeStore.on('load',function(){
			toolcode_desc=this.toolcodeStore.data.items[0].data.toolcode;
			
			OccfileListStore.load();
		},this); 
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
		this.tool_typeStore.on('load',function(){
			Ext.getCmp('tool_typeDESCID').setValue('${param.tool_type}');
		},this); 
		
		this.tool_authorize_flagStore = new Ext.data.JsonStore(
				{
					autoDestroy : true,
					url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
					root : 'data',
					fields : [ 'value', 'name' ]
				});
		this.tool_authorize_flagStore.load();
		this.tool_authorize_flagStore.on('load',function(){
			Ext.getCmp('tool_authorize_flagDESCID').setValue('${param.tool_authorize_flag}');
		},this); 
		
		
		
		this.authorize_level_typeStore = new Ext.data.JsonStore(
		{
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/AUTHORIZE_LEVEL_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.authorize_level_typeStore.load();
		this.authorize_level_typeStore.on('load',function(){
			Ext.getCmp('authorize_level_typeDESCID').setValue('${param.authorize_level_type}');
		},this); 
		
		
	
	
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
		
		this.appsys_Store.on('load',function(){
			Ext.getCmp('appsys_codeDESCID').setValue('${param.appsys_code}');
			
		},this); 
		
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
		//二级分类
		field_type_twoStore_desc = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_two'])
			
		});
		field_type_twoStore_desc.on('beforeload',function(){
			field_type_twoStore_desc.baseParams.field_type_one = Ext.getCmp("field_type_oneDESCID").getValue();
		},this); 
		//三级分类
		field_type_threeStore_desc = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_three'])
			
		});
		field_type_threeStore_desc.on('beforeload',function(){
			field_type_threeStore_desc.baseParams.field_type_one = Ext.getCmp("field_type_oneDESCID").getValue();
			field_type_threeStore_desc.baseParams.field_type_two = Ext.getCmp("field_type_twoDESCID").getValue();
		},this); 
          
          this.toolbox_createtreeloader = new Ext.tree.TreeLoader({
  			requestMethod : 'POST',
  			dataUrl : '${ctx}/${appPath}/ToolBoxController/getEventGroupTree'
  		});
		this.toolbox_createtree = new Ext.tree.TreePanel({
			xtype : 'treepanel',
			fieldLabel : '告警策略名称',
			id: 'policy_CreateDESCID',
			height : 350,
			frame : true,
			autoScroll: true,
			root : new Ext.tree.AsyncTreeNode({
				draggable : false,
				iconCls : 'node-root',
				id : 'CreateRootId' 
			}),
			loader : this.toolbox_createtreeloader,
			listeners : {
				scope : this ,
				'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode_1 = node.parentNode; //分组目录
				              if(pNode_1 == this.toolbox_createtree.getRootNode()) return;
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
					            if(pNode_2 == this.toolbox_createtree.getRootNode()) return;
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
						            if(pNode_3 == this.toolbox_createtree.getRootNode()) return;
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
		});						
		this.form = new Ext.FormPanel({
					buttonAlign : 'center',
					labelAlign : 'right',
					lableWidth : 15,
					autoHeight: false,
					frame : true,
					monitorValid : true,
					defaults : {
						anchor : '80%',
						msgTarget : 'side'
					},
					items :  [ {
						layout:'column',
						items:[{
						     columnWidth:.5,
						     layout:'form',
		          	  
		                items : [{
						xtype : 'combo',
						store : this.appsys_Store,
						fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.appsys_code" />',
						id:'appsys_codeDESCID',
     					name : 'appsys_code',
						valueField : 'appsysCode',
						displayField : 'appsysName',
						hiddenName : 'appsys_code',
						mode : 'local',
						anchor:'100%',
						triggerAction : 'all',
						forceSelection : true,
						//width:260,
						//editable : false,
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
					xtype : 'combo',
					store : this.authorize_level_typeStore,
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.authorize_level_type" />',
					name : 'authorize_level_type',
					id:'authorize_level_typeDESCID',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'authorize_level_type',
					mode : 'local',
					anchor:'100%',
					triggerAction : 'all',
					forceSelection : true,
					//wi//width:260,					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : this.tool_authorize_flagStore,
					fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
					name : 'tool_authorize_flag',
					id:'tool_authorize_flagDESCID',
					valueField : 'value',
					displayField : 'name',
					//width:260,
					hiddenName : 'tool_authorize_flag',
					mode : 'local',
					anchor:'100%',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
					name : 'tool_name',
					id:'tool_nameDESCID' ,
					//width:260,
					anchor:'100%',
					maxLength:100,
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
									id:'field_type_oneDESCID',
									valueField : 'field_type_one',
									displayField : 'field_type_one',
									hiddenName : 'field_type_one',
									mode : 'local',
									anchor:'100%',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									//width:260,
									tabIndex : this.tabIndex++,
									allowBlank : false,
									listeners : {
										//编辑完成后处理事件
										select : function(obj) {
											 field_type_twoStore_desc.load();
											Ext.getCmp('field_type_twoDESCID').setValue("");
											Ext.getCmp('field_type_threeDESCID').setValue("");
											//Ext.getCmp('field_type_twoDESCID').el.up('.x-form-item').setDisplayed(true);
											//Ext.getCmp('field_type_threeDESCID').el.up('.x-form-item').setDisplayed(false);
										}
									}
								},
								{
									xtype : 'combo',
									store : field_type_twoStore_desc,
									fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
									name : 'field_type_two',
									id:'field_type_twoDESCID',
									valueField : 'field_type_two',
									displayField : 'field_type_two',
									hiddenName : 'field_type_two',
									mode : 'local',
									anchor:'100%',
									triggerAction : 'all',
									forceSelection : true,
									//width:260,
									editable : false,
									tabIndex : this.tabIndex++,
									listeners : {
										//编辑完成后处理事件
										select : function(obj) {
											field_type_threeStore_desc.load();
											Ext.getCmp('field_type_threeDESCID').setValue("");
										//	Ext.getCmp('field_type_threeDESCID').el.up('.x-form-item').setDisplayed(true);
											
										}
									}
								},
								{
									xtype : 'combo',
									store :field_type_threeStore_desc,
									fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
									name : 'field_type_three',
									id:'field_type_threeDESCID',
									valueField : 'field_type_three',
									displayField : 'field_type_three',
									hiddenName : 'field_type_three',
									mode : 'local',
									anchor:'100%',
									triggerAction : 'all',
									forceSelection : true,
									//width:260,
									editable : false,
									tabIndex : this.tabIndex++
								},{
									xtype : 'combo',
									store : this.tool_typeStore,
									fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
									name : 'tool_type',
									id:'tool_typeDESCID',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_type',
									mode : 'local',
								//	width:260,
								anchor:'100%',
									readOnly:true,
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									tabIndex : this.tabIndex++,
									allowBlank : false
								}]
						}]
            },{
            	
					xtype : 'textarea',
					fieldLabel : '<fmt:message key="toolbox.tool_desc" />',
					name : 'tool_desc',
					height : 100,
					maxLength:660,
					anchor:'80%',
					tabIndex : this.tabIndex++
				 
            },{
                xtype:'htmleditorCreateDesc',
                id:'tool_contentDESCID',
                name : 'tool_content',
                fieldLabel:'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_content" />',
                enableSourceEdit:false,
                enableFormat :false,
                enableFontSize  :false,
                enableAlignments :false,
                enableFont :false,
                enableLists :false,
                enableColors :false,
                height:300,
                anchor:'80%'
                }
                ,{
					xtype : 'textfield',
					fieldLabel : 'tool_code',
					name : 'tool_code',
					id:'tool_codeDESCID' ,
					hidden:true
				}
             ],
            buttons : []
		 });
		

		this.fivePanel = new Ext.Panel({
	              title:'匹配关键字',
	              frame : true,
				  split : false,
				  collapseMode : 'mini',
                  layout:'column',
                  border:false,
                  iconCls : 'menu-node-change',
                  layout: 'form',
                  defaults: {anchor:'85%'},
                  border:false,
                  labelWidth : 210,
                  items : [{
							xtype : 'textfield',
							fieldLabel :'告警策略名称',
							name:'event_group',
							id : 'event_group_createDESCID',
							hidden:true,
							tabIndex : this.tabIndex++
						},{
							xtype : 'textarea',
							fieldLabel :'告警信息关键字',
							id : 'summarycnID',
							name : 'summarycn',
							height : 80,
							maxLength:500,
							tabIndex : this.tabIndex++
						}, {
							xtype : 'label',
							text: '(匹配规则说明: &表示与; |表示或)',
							style : 'margin-left:220;color:red'
						},
						this.toolbox_createtree
				    ],
					listeners : {
						scope : this,
						'activate' : function(panel) { 
							 var appsys_codeID = Ext.getCmp('appsys_codeDESCID').getValue() ;
							this.toolbox_createtreeloader.baseParams.appsys_code = appsys_codeID;
							this.toolbox_createtreeloader.baseParams.tool_code = '';
							this.toolbox_createtree.getRootNode().setText(appsys_codeID);
							this.toolbox_createtreeloader.load(this.toolbox_createtree.getRootNode(), function(n){
								n.expand();
							}); 
						}
					}
		});
		
		
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
		       
		        var btnNext = Ext.getCmp("tool_move-next_createDesc");  
		        var btnPrev = Ext.getCmp("tool_move-prev_createDesc");  
		        var btnSave = Ext.getCmp("tool_move-save_createDesc");  
		        if (i == 0) {  
		            btnSave.hide();  
		            btnNext.enable();  
		            btnPrev.disable();  
		        }  
		        if (i == 1) {
					if (Ext.getCmp('appsys_codeDESCID').getValue() == ''||
						Ext.getCmp('authorize_level_typeDESCID').getValue() == ''||
						Ext.getCmp('field_type_oneDESCID').getValue() == ''||
						Ext.getCmp('tool_typeDESCID').getValue() == ''||
						Ext.getCmp('tool_authorize_flagDESCID').getValue() == ''||
						Ext.getCmp('tool_contentDESCID').getValue().trim() == ''||
						Ext.getCmp('tool_contentDESCID').getValue().trim()=='<P>&nbsp;</P>') {
						Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '红星标示字段不允许为空',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
						return i = 0;
					}
					btnSave.show();  
		            btnNext.disable();  
		            btnPrev.enable(); 
					
				} 
		        this.cardPanel.getLayout().setActiveItem(i);  
		    };  
		    
			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore(
			{
				proxy : new Ext.data.HttpProxy(
						{
							method : 'POST',
							url : '${ctx}/${appPath}/ToolBoxController/tool_box_files_occ',
							disableCaching : false
						}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
			fields : [ 'tool_code','file_id', 
						'file_type', 
						'file_name'
				],
				remoteSort : false,
				sortInfo : {
					field : 'file_name',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 100,
					tool_code : ''
					
				}
			});
			this.gridStore.on('beforeload',function(){
				this.gridStore.baseParams.tool_code =toolcode_desc;
			},this); 
			
			csm = new Ext.grid.CheckboxSelectionModel();
			this.grid = new Ext.grid.GridPanel(
					{
						id:'tool_box_crerate_FILES',
						border : true,
						height : 225,
						loadMask : true,
						region : 'center',
						border : false,
						loadMask : true,
						autoScroll : true,
						autoWeight : true,
						//autoHeight : true,
						title : '附件列表',
						columnLines : true,
						viewConfig : {
							forceFit : false
						},
						defaults : {
							//anchor : '90%',
							msgTarget : 'side'
						},
						enableColumnHide:false,
						enableHdMenu : false, 
						store : this.gridStore,
						sm : csm,
						// 列定义

						columns : [
							new Ext.grid.RowNumberer(),
							csm,
							{
								header : '工具编号',
								dataIndex : 'tool_code',
								sortable : true,
								hidden:true
							},{
								header : '附件ID',
								dataIndex : 'file_id',
								sortable : true,
								hidden:true
							},{
								header : '附件名称',
								dataIndex : 'file_name',
								width:200,
								sortable : true
							},{
								header : '附件类型',
								dataIndex : 'file_type',
								sortable : true
							},{
								header : '下载',
								sortable : true,
								 renderer: this.download
							}
						
					 	],
						// 定义按钮工具条

						tbar : new Ext.Toolbar(
						{
							items : [ '-', {
								iconCls : 'button-add',
								text : '<fmt:message key="button.add" />',
								scope : this,
								handler : this.doAddFile
							}, '-',{
								iconCls : 'button-delete',
								text : '<fmt:message key="button.delete" />',
								scope : this,
								handler : this.doDelete
							}, '-' 
									         
									]
								}),
						// 定义分页工具条


						bbar : new Ext.PagingToolbar({
							store : this.gridStore,
							displayInfo : true,
							pageSize : 100
						})
					});
			
			
			this.panelOne = new Ext.Panel({  
	            layout:'column',
	            autoScroll: true,
	            border:false,
	            items:[{
	                layout: 'form',
	                defaults: {anchor : '100%'},
	                border:false,
	                autoScroll : true,
	                labelAlign : 'right',
	                items: [ this.form ,this.grid]
	            }]
		    }); 
			
		    
		    
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
	            id: 'tool_move-prev_createDesc',  
	            iconCls : 'button-previous',
	            disabled : true ,
				text : '<fmt:message key="job.stepBefore" />',  
	            handler: cardHandler.createDelegate(this, [-1])  
	        },'-',
	        {  
	            id: 'tool_move-save_createDesc',  
	            iconCls : 'button-save',
				text : '<fmt:message key="button.save" />',
	            hidden: true,  
	            handler:this.doSave
	        },'-',  
	        {  
	            id: 'tool_move-next_createDesc',  
	            iconCls : 'button-next',
				text : '<fmt:message key="job.stepNext" />',
	            handler: cardHandler.createDelegate(this, [1])  
	        }],  
	        items: [this.panelOne,this.fivePanel ]  
	    });
		// 设置基类属性
		Tool_box_Desc_Info.superclass.constructor.call(this,{
            title : '<fmt:message key="title.form" />',
            labelAlign : 'right',
            buttonAlign : 'center',
            frame : true,
            autoScroll : true,
            url : '${ctx}/${appPath}/ToolBoxController/createDesc',
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
		
		
	},
	
		doSave : function() {
			
			var nodes = Ext.getCmp('policy_CreateDESCID').getChecked();
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
	    	Ext.getCmp('event_group_createDESCID').setValue(EventGroupInfos);
	    	Ext.getCmp('tool_codeDESCID').setValue(toolcode_desc);
			
	    	tool_box_Desc_Info.getForm().submit({
	    		
				scope : tool_box_Desc_Info,
				success : tool_box_Desc_Info.saveSuccess,
				failure : tool_box_Desc_Info.saveFailure,
				 waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />' 
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
				app.closeTab('TOOL_BOX_DESC_INFO');// 关闭新建页面
			}
		});

	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	//添加附件
	doAddFile: function() {
		File_Create_Win.show();
	},
	
	doSaveFile : function() {
		var path=Ext.getCmp('tool_code_create_file_id').getValue();
		var file_type=path.substring(path.lastIndexOf('.')+1);
		var uploadPath= Ext.getCmp('tool_code_create_file_id').getValue();
		
		Ext.getCmp('createDesc_file_form').getForm().submit({
    		
			scope : tool_box_Desc_Info,
			success : tool_box_Desc_Info.saveSuccessFile,
			failure : tool_box_Desc_Info.saveFailureFile,
			 waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />' ,
			params : {
				
				tool_code: toolcode_desc,
				uploadPath: uploadPath ,
				file_type :file_type
			}
		});  
		
	},
		// 保存成功回调
		saveSuccessFile : function(form, action) {
			
			 Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO,
					minWidth : 200,
					fn : function() {
						File_Create_Win.hide();
						OccfileListStore.reload();
						 Ext.getCmp("tool_box_crerate_FILES").getStore().reload();
						 Ext.getCmp("tool_code_create_file_id").setValue("");
						 Ext.getCmp("tool_code_create_file_name").setValue("");
					}
			}); 
		},
		// 保存失败回调
		saveFailureFile : function(form, action) {
			var error = decodeURIComponent(action.result.error);
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'+ error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		} ,
		
		doCancelFile : function() {
			Ext.getCmp("tool_code_create_file_id").setValue("");
			 Ext.getCmp("tool_code_create_file_name").setValue("");
			File_Create_Win.hide();
		
		},
		//删除事件
		doDelete : function() {
			if (this.grid.getSelectionModel().getCount() > 0) {
				var records = this.grid.getSelectionModel()
						.getSelections();
				var tool_codes = new Array();
				var file_ids = new Array();
				for ( var i = 0; i < records.length; i++) {
					tool_codes[i] = records[i].get('tool_code');
					file_ids[i] = records[i].get('file_id');
				}

				Ext.Msg
						.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.confirm.to.delete" />',
							buttons : Ext.MessageBox.OKCANCEL,
							icon : Ext.MessageBox.QUESTION,
							minWidth : 200,
							scope : this,
							fn : function(buttonId) {
								if (buttonId == 'ok') {
									app.mask.show();

									Ext.Ajax.request({
												url : '${ctx}/${appPath}/ToolBoxController/deleteOccFile',
												scope : this,
												success : this.deleteSuccess,
												failure : this.deleteFailure,
												params : {
													tool_codes : tool_codes,
													file_ids : file_ids,
													_method : 'delete'
												}
											});
								}
							}
						});
			} else {
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.select.one.at.least" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
			}
		},

		// 删除失败回调方法
		deleteFailure : function() {
			app.mask.hide();
			Ext.Msg
					.show({
						title : '<fmt:message key="message.title" />',
						msg : '<fmt:message key="message.delete.failed" />',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.ERROR
					});
		},
		// 删除成功回调方法
		deleteSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg
						.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.delete.failed" /><fmt:message key="error.code" />:'
									+ error,
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.ERROR
						});
			} else if (Ext.decode(response.responseText).success == true) {
				this.grid.getStore().reload();// 重新加载数据源
				OccfileListStore.reload();
				Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="message.delete.successful" />',
							minWidth : 200,
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.INFO
						});
			}
		},
		 download : function(value, metadata, record, rowIndex, colIndex, store) {
			  return '<a href="javascript:dowmload_occfile()"><font color=red>下载</font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
			 }

});
					
var tool_box_Desc_Info = new Tool_box_Desc_Info();

//添加附件

var  create_desc_file_form=new Ext.form.FormPanel({
	id:'createDesc_file_form',
	fileUpload : true,
	buttonAlign : 'center',
	labelAlign : 'right',
	lableWidth : 15,
	url : '${ctx}/${appPath}/ToolBoxController/addOccFile',	
	frame : true,
	monitorValid : true,
	
	items:[
	       {xtype : 'textfield',
	     id : 'tool_code_create_file_name',
			fieldLabel : '附件名称',
			name : 'file_name',
			tabIndex : this.tabIndex++,
			allowBlank : false,
			anchor : '90%'
			
		},
			{
            xtype : 'fileuploadfield',
            id : 'tool_code_create_file_id',
            fieldLabel : '选择文件',
            name : 'file',
            allowBlank : false,
            blankText : '文件不能为空',
            height : 25,
            anchor : '90%',
            listeners : {
				scope : this,
				'fileselected' : function(fileField, path) {
					if(null==Ext.getCmp('tool_code_create_file_name').getValue()||Ext.getCmp('tool_code_create_file_name').getValue().trim()==""){
					var scriptName = path.substring(path.lastIndexOf('\\') + 1);
					var name=scriptName.substring(0,scriptName.lastIndexOf('\.'));
					Ext.getCmp('tool_code_create_file_name').setValue(name);
					}
				}
			}
        }],
	buttons : [{
			text :'<fmt:message key="button.save" />',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : tool_box_Desc_Info.doSaveFile
			},{
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				tabIndex : this.tabIndex++,
				handler : tool_box_Desc_Info.doCancelFile

			} ]
})
var File_Create_Win = new Ext.Window({
	title:'上传附件',
	layout:'form',
	fileUpload : true,
	width:300,
	height:130,
	plain:true,
	modal : true,
	closable : false,
	resizable : false,
	draggable : true,
	closeAction :'close',
	items : [create_desc_file_form]
});



Ext.getCmp("TOOL_BOX_DESC_INFO").add(tool_box_Desc_Info);
Ext.getCmp("TOOL_BOX_DESC_INFO").doLayout();

Ext.getCmp('field_type_oneDESCID').setValue(decodeURIComponent('${param.field_type_one}'));
field_type_twoStore_desc.load();
if('${param.field_type_two}'==''){
	
}else{
	Ext.getCmp('field_type_twoDESCID').setValue(decodeURIComponent('${param.field_type_two}'));
	field_type_threeStore_desc.load();
}
if('${param.field_type_three}'==''){
	
}else{
	Ext.getCmp('field_type_threeDESCID').setValue(decodeURIComponent('${param.field_type_three}'));
}

tool_box_Desc_Info.on('beforedestroy',function(){
	
	File_Create_Win.close();
},this);


</script>
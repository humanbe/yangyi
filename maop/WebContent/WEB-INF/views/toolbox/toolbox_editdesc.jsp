<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var editdesc_field_type_one= decodeURIComponent('${param.field_type_one}') ; 
var editdesc_field_type_two= decodeURIComponent('${param.field_type_two}') ;
var field_type_twoStore_editdesc;
var field_type_threeStore_editdesc;

var btnSave_editDesc = Ext.getCmp("tool_move-save_editDesc"); 




var fileListStore = new Ext.data.Store(
{
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${appPath}/ToolBoxController/getFileList', 
		method: 'POST'
	}),
	reader: new Ext.data.JsonReader({}, ['file_id','file_name']),
	
	baseParams : {
		tool_code : '${param.tool_code}'
	}
	
});
fileListStore.load();

   
//-------------------------------htmleditor------------------------------------
var HTMLEditorEditDesc = Ext.extend(Ext.form.HtmlEditor, {

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
	   
	   var imgform = new Ext.FormPanel({
	    region : 'center',
	    labelWidth : 55,
	    bodyStyle : 'padding:5px 5px 0',
	    autoScroll : true,
	    border : false,
	    items : [{
	    	xtype : 'combo',
	    	id: 'toolbox_editdesc_fujianId',
	    	name:'fujian',
	    	hiddenName :'fujian',
			store : fileListStore,
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
					 Ext.getCmp("toolbox_editdesc_fujianId").store=fileListStore;
			}
		 }  
	      }],
	    buttons : [{
	     text : '链接',
	     type : 'submit',
	     handler : function(o) {
	    	 var fileId=  Ext.getCmp("toolbox_editdesc_fujianId").getValue();
	    	 if(fileId!=''){
	    		 var fileURL = "<a href=\"javascript:dowmload_file_exc(\'"+fileId+"\')\">"+value+"</a>";
		    	 var  val2= obj.getValue();
	    	   var newval=val2.replace('|+|'+value+'|+|',fileURL);
	    	   obj.setValue(newval);
	    	   fujian_win.close(this);
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
	    	 fujian_win.close(this);
	       }
	    }]
	   });

	   var fujian_win = new Ext.Window({
	      title : "附件选择",
	      width : 400,
	      height : 120,
	      modal : true,
	      border : false,
	      iconCls:'icon-uploadpic',
	      layout : "fit",
	      items : imgform

	     });
	   fujian_win.show();
	  
	},
	createToolbar : function(editor) {
	   HTMLEditorEditDesc.superclass.createToolbar.call(this, editor);
	   
	   this.tb.insertButton(16, {
			   text:'附件链接',
		      iconCls : "button-impage",
		      handler : this.addImage,
		      tooltip : "添加链接",
		      scope : this
		     });
	   
	}
	});
	
	Ext.reg('HTMLEditorEditDesc', HTMLEditorEditDesc);
//------------------------------------------------------------------------------


//查看关联软件日志信息
function dowmload_file(){
 var grid = Ext.getCmp("tool_box_EDIT_FILES");
 var record = grid.getSelectionModel().getSelected();
		var tool_code = record.data.tool_code;
		var file_id= record.data.file_id;
		var file_type= record.data.file_type;
		var file_name= record.data.file_name;
		
 
 window.location = '${ctx}/${appPath}/ToolBoxController/downloadFiles.file?tool_code='+tool_code+'&file_id='+file_id+'&file_type='+file_type+'&file_name='+encodeURI(encodeURI(file_name));
}
Tool_box_EditDesc_Info= Ext.extend(Ext.FormPanel, {
	tabIndex : 0,
    form: null,
	csm : null,// 数据列表选择框组件
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
		
		
		//二级分类
		field_type_twoStore_editdesc = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTtwo', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_two']),
			baseParams : {
				field_type_one : editdesc_field_type_one
			}
		});
		field_type_twoStore_editdesc.load();
		//三级分类
		field_type_threeStore_editdesc = new Ext.data.Store(
		{
			proxy: new Ext.data.HttpProxy({
				url : '${ctx}/${appPath}/ToolBoxController/getFTthree', 
				method: 'POST'
			}),
			reader: new Ext.data.JsonReader({}, ['field_type_three']),
	    	baseParams : {
	    		field_type_one : editdesc_field_type_one,
	    		field_type_two : editdesc_field_type_two
		       }
		});
		field_type_threeStore_editdesc.load();
				
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
						id:'appsys_codeEDIT_DESCID',
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
					id : 'tool_code_editEDIT_DESCID',
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
					id:'authorize_level_typeEDIT_DESCID',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'authorize_level_type',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					anchor:'100%',
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++
				},{
					xtype : 'combo',
					store : this.tool_authorize_flagStore,
					fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_authorize_flag" />',
					name : 'tool_authorize_flag',
					id:'tool_authorize_flagEDIT_DESCID',
					valueField : 'value',
					displayField : 'name',
					anchor:'100%',
					hiddenName : 'tool_authorize_flag',
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					allowBlank : false
				},{
					xtype : 'textfield',
					fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_name" />',
					name : 'tool_name',
					id:'tool_nameEDIT_DESCID' ,
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
									id:'field_type_oneEDIT_DESCID',
									valueField : 'field_type_one',
									displayField : 'field_type_one',
									hiddenName : 'field_type_one',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									editable : false,
									anchor:'100%',
									tabIndex : this.tabIndex++,
									allowBlank : false,
									listeners : {
										//编辑完成后处理事件
										select : function(obj) {
											field_type_twoStore_editdesc.baseParams.field_type_one =obj.value;
											 field_type_twoStore_editdesc.load();
											Ext.getCmp('field_type_twoEDIT_DESCID').setValue("");
											Ext.getCmp('field_type_threeEDIT_DESCID').setValue("");
											//Ext.getCmp('field_type_twoEDIT_DESCID').el.up('.x-form-item').setDisplayed(true);
											//Ext.getCmp('field_type_threeEDIT_DESCID').el.up('.x-form-item').setDisplayed(false);
										}
									}
								},
								{
									xtype : 'combo',
									store : field_type_twoStore_editdesc,
									fieldLabel : '<fmt:message key="toolbox.field_type_two" />',
									name : 'field_type_two',
									id:'field_type_twoEDIT_DESCID',
									valueField : 'field_type_two',
									displayField : 'field_type_two',
									hiddenName : 'field_type_two',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									anchor:'100%',
									editable : false,
									tabIndex : this.tabIndex++,
									listeners : {
										//编辑完成后处理事件
										select : function(obj) {
											field_type_threeStore_editdesc.baseParams.field_type_one =Ext.getCmp('field_type_oneEDIT_DESCID').getValue();
											field_type_threeStore_editdesc.baseParams.field_type_two =obj.value;
											field_type_threeStore_editdesc.load();
											Ext.getCmp('field_type_threeEDIT_DESCID').setValue("");
											
										}
									}
								},
								{
									xtype : 'combo',
									store :field_type_threeStore_editdesc,
									fieldLabel : '<fmt:message key="toolbox.field_type_three" />',
									name : 'field_type_three',
									id:'field_type_threeEDIT_DESCID',
									valueField : 'field_type_three',
									displayField : 'field_type_three',
									hiddenName : 'field_type_three',
									mode : 'local',
									triggerAction : 'all',
									forceSelection : true,
									anchor:'100%',
									editable : false,
									tabIndex : this.tabIndex++
								},{
									xtype : 'combo',
									store : this.tool_typeStore,
									fieldLabel :'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_type" />',
									name : 'tool_type',
									id:'tool_typeEDIT_DESCID',
									valueField : 'value',
									displayField : 'name',
									hiddenName : 'tool_type',
									mode : 'local',
									anchor:'100%',
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
				//一线接收工具描述
				xtype:'textarea',
				fieldLabel:'一线工具描述',
				name:'front_tool_desc',
				height:100,
				autoScroll : true,
				readOnly:true,
				style  : 'background : #F0F0F0' , 
				maxLength:660,
				tabIndex:this.tabIndex++
			},{
                xtype:'HTMLEditorEditDesc',
                id:'tool_contentEDIT_DESCID',
                name : 'tool_content',
                fieldLabel:'<font color=red>*</font>&nbsp;<fmt:message key="toolbox.tool_content" />',
                enableSourceEdit: false,
                enableFormat :false,
                enableFontSize  :false,
                enableAlignments :false,
                enableFont :false,
                enableLists :false,
                enableColors :false,
                height:300,
                anchor:'80%'
                },
				{
					xtype : 'combo',
					id : 'tool_status_editDesc',
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
					anchor:'80%',
					tabIndex : this.tabIndex++,
					allowBlank : false
				},
				{
					xtype : 'textarea',
					id : 'tool_returnreasons_editDesc',
					fieldLabel :'<fmt:message key="toolbox.tool_returnreasons" />',
					name : 'tool_returnreasons',
					readOnly:true,
					style  : 'background : #F0F0F0' , 
					height : 50,
					maxLength:200,
					anchor:'80%',
					tabIndex : this.tabIndex++

				},
				{
					xtype : 'textfield',
					fieldLabel :'<fmt:message key="toolbox.tool_creator" />',
					name : 'tool_creator',
					hidden : true,
					tabIndex : this.tabIndex++

				},
				{
					xtype : 'textfield',
					fieldLabel :'<fmt:message key="toolbox.tool_modifier" />',
					name : 'tool_modifier',
					hidden : true,
					tabIndex : this.tabIndex++

				},
				{
					xtype : 'datefield',
					fieldLabel :'<fmt:message key="toolbox.tool_editd_time" />',
					name : 'tool_created_time',
					hidden : true,
				    format : 'Y-m-d H:i:s',
					tabIndex : this.tabIndex++

				},
				{
					xtype : 'datefield',
					fieldLabel :'<fmt:message key="toolbox.tool_updated_time" />',
					name : 'tool_updated_time',
					format : 'Y-m-d H:i:s',
					hidden : true,
					tabIndex : this.tabIndex++

				}
             ],
            buttons : []
		 });
		
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore(
		{
			proxy : new Ext.data.HttpProxy(
					{
						method : 'POST',
						url : '${ctx}/${appPath}/ToolBoxController/tool_box_files',
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
				tool_code:'${param.tool_code}'
				
			}
		});

		// 加载列表数据
		this.gridStore.load();
		csm = new Ext.grid.CheckboxSelectionModel();
		this.grid = new Ext.grid.GridPanel(
				{
					id:'tool_box_EDIT_FILES',
					border : true,
					height : 225,
					loadMask : true,
					region : 'center',
					border : false,
					loadMask : true,
					autoScroll : true,
					autoWeight : true,
					collapsible :true,
					animCollapse : true,
					collapseMode : 'mini',
					title : '附件列表',
					columnLines : true,
					viewConfig : {
						forceFit : false
					},
					defaults : {
						anchor : '90%',
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
							hidden : true,
							sortable : true
							
						},{
							header : '附件ID',
							dataIndex : 'file_id',
							hidden : false,
							sortable : true
							
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
		

		this.fivePanel = new Ext.Panel({
			
              title:'匹配关键字',
			  frame : true,
			  split : false,
			  collapseMode : 'mini',
              layout:'column',
              border:false,
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
					id : 'event_group_EDIT_DESCID',
				    hidden:true,
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'textarea',
					fieldLabel :'告警信息关键字',
					name : 'summarycn',
					height : 60,
					maxLength:500,
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
					id: 'policy_EDIT_DESCID',
					height : 300,
					frame : true,
					autoScroll: true,
					/* margins : '0 0 0 5', */
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
							//tree.getRootNode().expand(); 
						},
						
						'checkchange': function(node, checked){
					          if (node.parentNode != null) {
					                 node.cascade(function(node){
						                 node.attributes.checked = checked;
						                 node.ui.checkbox.checked = checked;
						              });
						              var pNode_1 = node.parentNode; //分组目录
						              if(pNode_1 == Ext.getCmp('policy_EDIT_DESCID').getRootNode()) return;
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
							            if(pNode_2 == Ext.getCmp('policy_EDIT_DESCID').getRootNode()) return;
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
								            if(pNode_3 == Ext.getCmp('policy_EDIT_DESCID').getRootNode()) return;
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
			listeners : {

				scope : this,
				'activate' : function(panel) {
					setTimeout(function(){
						btnSave_editDesc.show();
	                }, 2000);
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
		       
		        var btnNext = Ext.getCmp("tool_move-next_editDesc");  
		        var btnPrev = Ext.getCmp("tool_move-prev_editDesc");  
		        btnSave_editDesc = Ext.getCmp("tool_move-save_editDesc");  
		        if (i == 0) {  
		        	btnSave_editDesc.hide();  
		            btnNext.enable();  
		            btnPrev.disable();  
		        }  
		        if (i == 1) {
		           
					if (Ext.getCmp('appsys_codeEDIT_DESCID').getValue() == ''||
						Ext.getCmp('authorize_level_typeEDIT_DESCID').getValue() == ''||
						Ext.getCmp('field_type_oneEDIT_DESCID').getValue() == ''||
						Ext.getCmp('tool_typeEDIT_DESCID').getValue() == ''||
						Ext.getCmp('tool_authorize_flagEDIT_DESCID').getValue() == ''||
						Ext.getCmp('tool_contentEDIT_DESCID').getValue().trim() == ''||
						Ext.getCmp('tool_contentEDIT_DESCID').getValue().trim()=='<P>&nbsp;</P>') {
						Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '红星标示字段不允许为空',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								});
						return i = 0;
					}
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
	            id: 'tool_move-prev_editDesc',  
	            iconCls : 'button-previous',
	            disabled : true ,
				text : '<fmt:message key="job.stepBefore" />',  
	            handler: cardHandler.createDelegate(this, [-1])  
	        },'-',
	        {  
	            id: 'tool_move-save_editDesc',  
	            iconCls : 'button-save',
				text : '<fmt:message key="button.save" />',
	            hidden: true,  
	            handler:this.doSave
	        },'-',  
	        {  
	            id: 'tool_move-next_editDesc',  
	            iconCls : 'button-next',
				text : '<fmt:message key="job.stepNext" />',
	            handler: cardHandler.createDelegate(this, [1])  
	        }],  
	        items: [this.panelOne,this.fivePanel ]  
	    });
		
		

		// 设置基类属性
		Tool_box_EditDesc_Info.superclass.constructor.call(this,{
            title : '<fmt:message key="title.form" />',
            labelAlign : 'right',
            buttonAlign : 'center',
            frame : true,
            autoScroll : true,
            url : '${ctx}/${appPath}/ToolBoxController/editDesc',
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
					url : '${ctx}/${appPath}/ToolBoxController/view',
					method : 'POST',
					waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.loading" />',
					scope : this,
					success : this.loadSuccess,
					failure : this.loadFailure,
					params:{
						tool_code :'${param.tool_code}',
						appsys_code:'${param.appsys_code}'
					}
				});
		
	},
	
	// 数据加载失败回调
	loadFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.loading.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	loadSuccess : function(form, action) {
		
		
		if(Ext.getCmp('tool_status_editDesc').getValue()!='3'){
			Ext.getCmp('tool_returnreasons_editDesc').el.up('.x-form-item').setDisplayed(false);
			}
		
		
		
	},
	
	// 重置查询表单
	doSave : function() {
		var nodes = Ext.getCmp('policy_EDIT_DESCID').getChecked();
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
    	Ext.getCmp('event_group_EDIT_DESCID').setValue(EventGroupInfos);
	
		
    	tool_box_EditDesc_Info.getForm().submit({
    		
			scope : tool_box_EditDesc_Info,
			success : tool_box_EditDesc_Info.saveSuccess,
			failure : tool_box_EditDesc_Info.saveFailure,
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
				app.closeTab('TOOL_BOX_EDITDESC_INFO');// 关闭新建页面
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
		File_Win.show();
	},
	
		
			doSaveFile : function() {
				var path=Ext.getCmp('tool_code_edit_file_id').getValue();
				var file_type=path.substring(path.lastIndexOf('.')+1);
				var  tool_code=Ext.getCmp('tool_code_editEDIT_DESCID').getValue();
				var uploadPath= Ext.getCmp('tool_code_edit_file_id').getValue();
				Ext.getCmp('editDesc_file_form').getForm().submit({
		    		
					scope : tool_box_EditDesc_Info,
					success : tool_box_EditDesc_Info.saveSuccessFile,
					failure : tool_box_EditDesc_Info.saveFailureFile,
					 waitTitle : '<fmt:message key="message.wait" />',
					waitMsg : '<fmt:message key="message.saving" />' ,
					params : {
						
						tool_code:tool_code,
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
						File_Win.hide();
						fileListStore.reload();
						Ext.getCmp("tool_box_EDIT_FILES").getStore().reload();
						Ext.getCmp("tool_code_edit_file_id").setValue("");
						 Ext.getCmp("tool_code_edit_file_name").setValue("");
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
			Ext.getCmp("tool_code_edit_file_id").setValue("");
			 Ext.getCmp("tool_code_edit_file_name").setValue("");
			File_Win.hide();
		
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
												url : '${ctx}/${appPath}/ToolBoxController/deleteFile',
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
			  return '<a href="javascript:dowmload_file()"><font color=red>下载</font><img src="${ctx}/static/style/images/menu/property.bmp"></img></a>';
			 }

});
					

					
var tool_box_EditDesc_Info = new Tool_box_EditDesc_Info();	

var  edit_desc_file_form=new Ext.form.FormPanel({
	id:'editDesc_file_form',
	fileUpload : true,
	url : '${ctx}/${appPath}/ToolBoxController/addFile',
	buttonAlign : 'center',
	labelAlign : 'right',
	lableWidth : 15,
	frame : true,
	monitorValid : true,
	
	items:[
	       {xtype : 'textfield',
	     id : 'tool_code_edit_file_name',
			fieldLabel : '附件名称',
			name : 'file_name',
			tabIndex : this.tabIndex++,
			allowBlank : false,
			anchor : '90%'
			
		},{
            xtype : 'fileuploadfield',
            id : 'tool_code_edit_file_id',
            fieldLabel : '选择文件',
            name : 'file',
            allowBlank : false,
            blankText : '文件不能为空',
            height : 25,
            anchor : '90%',
            listeners : {
				scope : this,
				'fileselected' : function(fileField, path) {
					if(null==Ext.getCmp('tool_code_edit_file_name').getValue()||Ext.getCmp('tool_code_edit_file_name').getValue().trim()==""){
						var scriptName = path.substring(path.lastIndexOf('\\') + 1);
					var scriptName = path.substring(path.lastIndexOf('\\') + 1);
					var name=scriptName.substring(0,scriptName.lastIndexOf('\.'));
					Ext.getCmp('tool_code_edit_file_name').setValue(name);
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
				handler : tool_box_EditDesc_Info.doSaveFile
			},{
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				tabIndex : this.tabIndex++,
				handler : tool_box_EditDesc_Info.doCancelFile

			} ]
})
//添加附件
var File_Win = new Ext.Window({
	title:'上传附件',
	layout:'form',
	width:300,
	height:130,
    fileUpload : true,
	plain:true,
	modal : true,
	closable : false,
	resizable : false,
	draggable : true,
	closeAction :'close',
	items : [edit_desc_file_form]
});


Ext.getCmp("TOOL_BOX_EDITDESC_INFO").add(tool_box_EditDesc_Info);
Ext.getCmp("TOOL_BOX_EDITDESC_INFO").doLayout();

tool_box_EditDesc_Info.on('beforedestroy',function(){
	
	File_Win.close();
},this);


</script>






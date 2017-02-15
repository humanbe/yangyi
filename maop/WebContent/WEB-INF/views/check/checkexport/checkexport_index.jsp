<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//模板列表字段信息
var fieldsFile = Ext.data.Record.create([
	{name: 'file_group', mapping : 'file_group', type : 'string'}, 
	{name: 'file_name', mapping : 'file_name', type : 'string'}
]);

//定义新建表单
CheckFileExportForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	panel : null, // 模板页签 - 表单组件 
    grid :null,   // 列表组件 - 列表组件
	tree : null,  // 树形组件 - 树形组件
	csm : null,// 模板页签 - 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		csm = new Ext.grid.CheckboxSelectionModel();
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
		
		//导出文件类型
		this.exportFileTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_EXPORT_FILE_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.exportFileTypeStore.load();
		
		// 定义模板页签左侧树形组件----------------------------------------begin
		this.treeLoader = new Ext.tree.TreeLoader({
			requestMethod : 'POST',
			dataUrl : '${ctx}/${appPath}/checkexport/getFileTree',
			baseParams : {
				exportFileType : ''
			}
		});
		this.tree = new Ext.tree.TreePanel({
			id : 'check_export_fileTree',
			height : 635 ,
			title : '<fmt:message key="job.select" /><fmt:message key="job.file" />',
			frame : true, //显示边框
			xtype : 'treepanel',
			split : true,
			autoScroll : true,
			root : new Ext.tree.AsyncTreeNode({
				text : '<fmt:message key="job.catalog" />',
				draggable : false,
				iconCls : 'node-root'
			}),
			loader : this.treeLoader,
			// 定义树形组件监听事件
			listeners : {
				 scope : this,
				 load : function(n){
					 this.tree.expandAll();  //展开所有节点
					 /* this.tree.root.expand();  //展开根节点 */  
					 if(!this.tree.root.hasChildNodes()){
						 Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="job.exportabled.null" />',
								minWidth : 200,
								timeout : 1800000,  //600000即10分钟
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.INFO
						 });
					 }
				 },
				 'checkchange': function(node, checked){
			          if (node.parentNode != null) {
			                 node.cascade(function(node){
				                 node.attributes.checked = checked;
				                 node.ui.checkbox.checked = checked;
				              });
				              var pNode_1 = node.parentNode; //分组目录
				              if(pNode_1 == this.tree.getRootNode()) return;
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
				            //COMMON_CHECK目录
				            if (pNode_1.parentNode != null) {
					            var pNode_2 = pNode_1.parentNode; 
					            if(pNode_2 == this.tree.getRootNode()) return;
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
					          //CHECK目录
					          if (pNode_2.parentNode != null) {
						            var pNode_3 = pNode_2.parentNode; 
						            if(pNode_3 == this.tree.getRootNode()) return;
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
		// 定义模板页签树形组件----------------------------------------end
		
		// 定义模板页签的中间移入移出按钮---------------------------begin
		this.panel = new Ext.Panel({
			height : 635 ,
			labelAlign : 'center',
			buttonAlign : 'center',
			frame : true, 
			split : true,
			xtype:'button',
            layout: {
            	type:'vbox',
            	padding:'10',
            	pack:'center',
            	align:'center' 
            },
        	defaults:{margins:'0 0 10 0'},
            items:[{
                 xtype:'button',
                 width : 40 ,
                 height : 25 ,
                 text: '<fmt:message key="job.movein" />>>',
                 scope : this,
     			 handler : this.fileShiftIn
             },{
                 xtype:'button',
                 width : 40 ,
                 height : 25 ,
                 text: '<<<fmt:message key="job.moveout" />',
                 scope : this,
                 handler : this.fileShiftOut
             }]
		});
		// 定义模板页签的中间移入移出按钮---------------------------end
		
		// 定义模板页签右侧列表组件--------------------------------------begin
		this.gridStore=new Ext.data.JsonStore({
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [ 'file_group', 'file_name' ],
			remoteSort : true,
			/* sortInfo : {
				field : 'file_name',
				direction : 'ASC'
			}, */
			baseParams : {
				/* start : 0,
				limit : 100 */
			}
		});
		this.grid = new Ext.grid.GridPanel({
			height : 635 ,
			frame : true,
			title : '<fmt:message key="job.selected" /><fmt:message key="job.file" />',
			autoScroll : true,
			region : 'center',
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.gridStore,
			/* hideHeaders:true, //隐藏表头 */
			sm : csm,  //注意：不能删，否则列表前的复选框不可操作
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm,
            {
				header : '<fmt:message key="job.file" /><fmt:message key="job.name" />',
				dataIndex : 'file_name'
			},{
				header : '<fmt:message key="job.file" /><fmt:message key="job.path" /> ',
				dataIndex : 'file_group'
			}]
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
		// 设置基类属性		CheckFileExportForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180,
			buttonAlign : 'center',
			frame : true, 
			timeout : 300,
			autoScroll : true,
		    url : '${ctx}/${appPath}/checkexport/exportCheckFiles', 
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			}, 
			monitorValid : true,
			// 定义表单组件
		    items:[{
			    	layout:'column',
		            border:false,
		            iconCls : 'menu-node-change',
		            items:[{
		                columnWidth:.75,
		                layout: 'form',
		                defaults: {anchor : '100%'},
		                border:false,
		                labelAlign : 'right',
		                items: [{
		                	xtype : 'combo',
		                	fieldLabel : '<font color=red>*</font>&nbsp;<fmt:message key="job.file" />类型',
		    			    id : 'check_export_fileType',
		    				emptyText : '<fmt:message key="job.select_please" />' , 
		    				store : this.exportFileTypeStore,
		    				displayField : 'name',
		    				valueField : 'value',
		    				hiddenName : '',
							mode: 'local',
							typeAhead: true,
		                    triggerAction: 'all',
		                    allowBlank : false,
		                    editable : false,  //输入 索引
							tabIndex : this.tabIndex++ ,
							listeners : {
							   scope : this,
							   'beforequery' : function(e){
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
								},
								select : function(combo, record, index){
									this.grid.store.removeAll();
									var val = combo.value ;
									var fileType = '' ;
									if(val=='1'){
										fileType = 'template' ;
									}
									if(val=='2'){
										fileType = 'job' ;
									}
									if(val=='3'){
										fileType = 'extends' ;
									}
									Ext.getCmp("exportFileType").setValue(fileType); 
									var treeRoot = Ext.getCmp("check_export_fileTree").getRootNode();
									this.treeLoader.baseParams.exportFileType = fileType;
									//重新加载树形菜单
									treeRoot.reload();
									//完全展开树形菜单
									Ext.getCmp("check_export_fileTree").root.expand(); 
								}
							}
		                }]
		            }]
			    },{
		        	layout:'column',
		            border : true ,
		            items:[{
		                    columnWidth:.45,  
		                    border : false,
		                    layoutConfig : { align : 'stretch' },
		                    items : [this.tree]
		                },{
		                    columnWidth:.1,
		                    border:false,
		                    labelAlign : 'center',
		                    items: [this.panel]
		                } ,{
		                    columnWidth:.45,
		                    border:false,
		                    layoutConfig : { align : 'stretch' },
		                    items: [this.grid] 
		              }]
			    },{
					xtype : 'textfield',
					hidden : true, 
					id : 'exportFileType'
			    },{
					xtype : 'textfield',
					hidden : true, 
					id : 'exportFiles'
				}],
				// 定义按钮grid
       			buttons : [{
       				text : '<fmt:message key="toolbox.export" />',
       				iconCls : 'button-export',
       				tabIndex : this.tabIndex++,
       				formBind : true,
       				scope : this,
       				handler : this.doExport
       			},{
       				text : '<fmt:message key="button.cancel" />',
       				iconCls : 'button-cancel',
       				formBind : true,
       				scope : this,
       				handler : this.doCancel
       			}] 
			
		});
	},
	
	//文件移入事件
	fileShiftIn : function() {
		var nodes = this.tree.getChecked();
    	var fileInfos = new Array();
    	for(var t=0 ; t<nodes.length ; t++){
			if(nodes[t].leaf == true){
				var par = nodes[t].parentNode;
				var grandPar = par.parentNode;
				var path = grandPar.text+"/"+par.text;
				if(grandPar.text != 'COMMON_CHECK'){
					var grandParBefore = grandPar.parentNode;
					path = grandParBefore.text+'/'+path ;
				}
				path = '/'+path;
		    	fileInfos.push(new fieldsFile({file_group:path,file_name:nodes[t].text}));
			}
    	}
    	if(this.grid.store.getCount()!=0){
			this.grid.store.removeAll();
			this.grid.store.add(fileInfos);
    	}else{
    		this.grid.store.add(fileInfos);
    	}
	},
	//文件移出事件
	fileShiftOut : function() {
		var records = this.grid.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			this.grid.store.remove(records[i]);
		}
	},
	//导出操作
	doExport : function() {
		//导出文件不为空
    	var flagFiles = false ; 
    	var storeFiles = this.grid.getStore();
		var jsonFiles = [];
		storeFiles.each(function(item) {
			jsonFiles.push(item.data);
		});
		if(jsonFiles!=null && jsonFiles.length>0){
			Ext.getCmp("exportFiles").setValue( Ext.util.JSON.encode(jsonFiles));
			flagFiles = true ;
		}
		if(!flagFiles){
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="job.file.null" />!',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200
			}); 
			return false;
		}
		//提交表单
		this.getForm().submit({
			scope : this,
			timeout : 1800000, //半小时
			success : this.exportSuccess,
			failure : this.exportFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	//取消操作
	doCancel : function() {
		app.closeTab('CHECK_CONFIG_EXPORT');
	},
	//保存成功回调
	exportSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.export.successful" />!',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200
		});
	},
	//保存失败回调
	exportFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.export.failed" />!<fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
	
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("CHECK_CONFIG_EXPORT").add(new CheckFileExportForm());
// 刷新Tab页布局
Ext.getCmp("CHECK_CONFIG_EXPORT").doLayout();
</script>
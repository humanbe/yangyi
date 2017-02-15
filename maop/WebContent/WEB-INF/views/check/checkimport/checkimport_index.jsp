<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

//模板列表字段信息
var fieldsFile = Ext.data.Record.create([
	{name: 'file_group', mapping : 'file_group', type : 'string'}, 
	{name: 'file_name', mapping : 'file_name', type : 'string'}
]);

var grid ;
var gridStore;
var gridImportable;
var gridImportableStore;

//定义新建表单
CheckFileImportForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序	panel : null, // 模板页签 - 移入移出按钮
	csm : null,// 模板页签 - 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		csm = new Ext.grid.CheckboxSelectionModel();
		csm2 = new Ext.grid.CheckboxSelectionModel();
		//禁止IE的backspace键(退格键)，但输入文本框时不禁止		Ext.getDoc().on('keydown',function(e) {
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

		//导入文件类型
		this.importFileTypeStore = new Ext.data.JsonStore({
			autoDestroy : true,
			url : '${ctx}/${frameworkPath}/item/CHECK_EXPORT_FILE_TYPE/sub',
			root : 'data',
			fields : [ 'value', 'name' ]
		});
		this.importFileTypeStore.load();
        
		//可导入文件列表--------------------------------------begin
		gridImportableStore=new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/checkimport/getImportabledFiles',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [ 'file_group', 'file_name' ],
			remoteSort : true,
			sortInfo : {
				field : 'file_group',
				direction : 'ASC'
			},
			baseParams : {
				importFileType : '' 
			}
		}); 
		gridImportable = new Ext.grid.GridPanel({
			height : 635 ,
			loadMask : true,
			frame : true,
			title : '<fmt:message key="job.select" /><fmt:message key="job.file" />',
			region : 'center',
			border : false,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : gridImportableStore,
			autoExpandColumn : 'name',
			sm : csm,  //注意：不能删，否则列表前的复选框不可操作
			columns : [ new Ext.grid.RowNumberer(), csm, 
            {
				header : '<fmt:message key="job.file" /><fmt:message key="job.name" />',
				dataIndex : 'file_name'
			},{
				header : '<fmt:message key="job.file" /><fmt:message key="job.path" /> ',
				dataIndex : 'file_group'
			}],
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移入事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = gridImportableStore.getAt(rowIndex);
					var group = curRow.get("file_group");
					var name = curRow.get("file_name");
					var notEqualFlag = true;
					grid.getStore().each(function(rightRecord){
						if(name==rightRecord.data.file_name && group==rightRecord.data.file_group){
							notEqualFlag = false;
						}
					},this);
					if(notEqualFlag){
						grid.store.add(curRow);
					}
				}
			}
		});  
		//可导入文件列表--------------------------------------end
		
		//定义模板页签的中间移入移出按钮---------------------------begin
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
		gridStore=new Ext.data.JsonStore({
			autoDestroy : true,
			root : 'data',
			//totalProperty : 'count',
			fields : [ 'file_group', 'file_name' ],
			remoteSort : true,
			sortInfo : {
				/* field : 'file_group',
				direction : 'ASC' */
			},
			baseParams : {
			}
		});
		grid = new Ext.grid.GridPanel({
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
			store : gridStore,
			sm : csm2,  //注意：不能删，否则列表前的复选框不可操作
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csm2,
            {
				header : '<fmt:message key="job.file" /><fmt:message key="job.name" />',
				dataIndex : 'file_name'
			},{
				header : '<fmt:message key="job.file" /><fmt:message key="job.path" /> ',
				dataIndex : 'file_group'
			}],
			// 定义数据列表监听事件
			listeners : {
				scope : this,
				// 行双击移出事件
				rowdblclick : function(row,rowIndex,e){
					var curRow = gridStore.getAt(rowIndex);
					grid.store.remove(curRow);
				}
			}
		});
		// 定义模板页签右侧列表组件--------------------------------------end
		
		// 设置基类属性		CheckFileImportForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180,
			buttonAlign : 'center',
			frame : true, 
			timeout : 7200000, //2小时 
			autoScroll : true,
		    url : '${ctx}/${appPath}/checkimport/importCheckFiles', 
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
		    			    id : 'check_import_fileType',
		    				emptyText : '<fmt:message key="job.select_please" />' , 
		    				store : this.importFileTypeStore,
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
									Ext.getCmp("importFileType").setValue(fileType); 
									gridImportableStore.baseParams.importFileType = fileType;
									gridImportableStore.reload();
									grid.store.removeAll();
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
		                    items : [gridImportable]
		                },{
		                    columnWidth:.1,
		                    border:false,
		                    labelAlign : 'center',
		                    items: [this.panel]
		                } ,{
		                    columnWidth:.45,
		                    border:false,
		                    layoutConfig : { align : 'stretch' },
		                    items: [grid] 
		              }]
			    },{
					xtype : 'textfield',
					hidden : true, 
					id : 'importFileType'
			    },{
					xtype : 'textfield',
					hidden : true, 
					id : 'importFiles'
				}],
				// 定义按钮grid
       			buttons : [{
       				text : '<fmt:message key="toolbox.import" />',
       				iconCls : 'button-export',
       				tabIndex : this.tabIndex++,
       				formBind : true,
       				scope : this,
       				handler : this.doImport
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
		var records = gridImportable.getSelectionModel().getSelections();
		var notEqualFlag = true;
		Ext.each(records,function(leftRecord){
			grid.getStore().each(function(rightRecord){
				if(leftRecord.data.file_name==rightRecord.data.file_name && leftRecord.data.file_group==rightRecord.data.file_group){
					notEqualFlag = false;
				}
			},this);
			if(notEqualFlag){
				grid.store.add(leftRecord);
			}
			notEqualFlag = true;
		});
	},
	//文件移出事件
	fileShiftOut : function() {
		var records = grid.getSelectionModel().getSelections();
		for(var i = 0; i<records.length; i++) {
			grid.store.remove(records[i]);
		}
	},
	//导入操作
	doImport : function() {
		//导入文件不为空    	var flagFiles = false ; 
    	var storeFiles = grid.getStore();
		var jsonFiles = [];
		storeFiles.each(function(item) {
			jsonFiles.push(item.data);
		});
		if(jsonFiles!=null && jsonFiles.length>0){
			Ext.getCmp("importFiles").setValue( Ext.util.JSON.encode(jsonFiles));
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
			success : this.importSuccess,
			failure : this.importFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	//取消操作
	doCancel : function() {
		app.closeTab('CHECK_CONFIG_IMPORT');
	},
	//导入成功回调
	importSuccess : function(form, action) {
		var msg = '';
		if(+action.result.info==''){
			msg = '<fmt:message key="message.import.successful" />!';
		}else{
			msg = '<fmt:message key="message.import.successful" />!<br><fmt:message key="job.in" />:'+action.result.info+'<fmt:message key="job.exist" />!';
		}
		
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : msg,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200
		});
	},
	//导入失败回调
	importFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.import.failed" />!<fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	}
	
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("CHECK_CONFIG_IMPORT").add(new CheckFileImportForm());
// 刷新Tab页布局
Ext.getCmp("CHECK_CONFIG_IMPORT").doLayout();
</script>
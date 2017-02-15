<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" 
         import="com.nantian.jeda.security.util.SecurityUtils"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var panelOneCreate = null ;
var panelTwoCreate = null ;
var panelThreeCreate = null ;
var panelFourCreate = null ;

var parmEditGridCreate = null ; //报表参数
var columnEditGridCreate = null ; //报表字段
var reportRuleGridCreate = null ; //报表规则
var reportRoleGridCreate = null ; //报表角色

// 报表分类
var rptTypeStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/REPORT_TYPES/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
rptTypeStore.load();
// 报表参数类型
var paramTypeStore = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/REPORT_PARAM_TYPES/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
paramTypeStore.load();
// 是、否 
var yesNoStore = new Ext.data.JsonStore(
{
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/TOOL_AUTHORIZE_FLAG/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
yesNoStore.load();



// 定义新建表单
JedaRptCreateForm = Ext.extend(Ext.FormPanel, {
	
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		csm = new Ext.grid.CheckboxSelectionModel();
		csmRule = new Ext.grid.CheckboxSelectionModel();
		csmRole = new Ext.grid.CheckboxSelectionModel();
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
		
		// 报表参数  ---------------begin
		this.paramEditGridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/jedarpt/getReportParamList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			fields : ['param_en_name',
			          'param_ch_name',
			          'param_type',
			          'default_value',
			          'dic_code'
			          ],
			pruneModifiedRecords : true,
			remoteSort : false,
			baseParams : {}
		});
		this.paramEditGridStore.load();
		// 列定义
		param_cm=new Ext.grid.ColumnModel([/* csm, */{
				header : '参数名称',
				dataIndex : 'param_en_name',
			    editable : false,
				readOnly : true,
				renderer : function(value, metadata, record, rowIndex, colIndex, store) {
					return '<div style=background:#F0F0F0>' + value + '</div>';
				},
				sortable : true
			},{
				header : '参数别名',
				dataIndex : 'param_ch_name',
				editor : new Ext.grid.GridEditor(
					new Ext.form.TextField({
						allowBlank:false,
						maxLength:100
					})
			    ),
				sortable : true
			},{
				header :  '参数类型',
				dataIndex : 'param_type',
				editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
					typeAhead : true,
					triggerAction : 'all',
					hiddenName : 'param_type',
					mode : 'local',
					store : paramTypeStore,
					displayField : 'name',
					valueField : 'value',
					allowBlank:false,
					forceSelection : true,
					editable : true
				})),
				scope : this,
				renderer : this.paramTypeValue,
				sortable : true
			},{
				header :  '默认值',
				dataIndex : 'default_value',
			    editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:100})
				),  
				sortable : true
			},{
				header :'关联字典',
				dataIndex : 'dic_code',
				id : 'param_dic_item_create',
				width:200,
				editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:60})
				),
				sortable : true
			}
        ]);
		// 参数配置列表
		parmEditGridCreate = new Ext.grid.EditorGridPanel({
			id : 'param_edit_grid_create',
			region : 'center',
			border : true,
			height : 225,
			loadMask : true,
			title : '报表参数',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.paramEditGridStore,
			sm : csm,
			// 列定义
			cm : param_cm,
			// 定义数据列表监听事件
			listeners : {
				// 编辑前
				'beforeedit' : function(e) {
			    },
			    // 编辑后
				'afteredit' : function(e) {
			    },
			    cellclick : function(grid, rowIndex, columnIndex, e) {
			    	var oldValue = grid.getStore().getAt(rowIndex).get('param_dic_item_create');
					var params = {
						rowIndex : rowIndex ,
						oldValue : oldValue
					};
					switch (columnIndex) {
					case 4:
						app.loadWindow('${ctx}/${frameworkPath}/item/rptParam', params);
						break;
					default:
						break;
					}
				}
			    
			}
		});
		// 报表参数 ----------------------------end
		
		// 报表列配置 ---------------------------begin
		this.columnEditGridStore = new Ext.data.JsonStore({
			proxy : new Ext.data.HttpProxy(
			{
				method : 'POST',
				url : '${ctx}/${appPath}/jedarpt/getReportColumnList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			fields : ['column_en_name',
			          'column_ch_name',
			          'column_desc',
			          'column_width',
			          'is_visible',
			          'is_trans',
			          'dic_code',
			          'column_sort'
			          ],
			pruneModifiedRecords : true,
			remoteSort : false,
			baseParams : {}
		});
		this.columnEditGridStore.load();
		// 列定义
		column_cm=new Ext.grid.ColumnModel([/* csm, */{
				header : '字段名称',
				dataIndex : 'column_en_name',
				editable : false,
				readOnly : true,
				renderer : function(value, metadata, record, rowIndex, colIndex, store) {
					return '<div style=background:#F0F0F0>' + value + '</div>';
				},
				sortable : true
			},{
				header : '别名',
				dataIndex : 'column_ch_name',
				editor : new Ext.grid.GridEditor(
					new Ext.form.TextField({allowBlank:false,maxLength:100})
			    ),
				sortable : true
			},{
				header : '描述',
				dataIndex : 'column_desc',
				editor : new Ext.grid.GridEditor(
					new Ext.form.TextField({maxLength:300})
			    ),
				sortable : true
			},{
				header : '宽度',
				dataIndex : 'column_width',
				editor : new Ext.grid.GridEditor(
					new Ext.form.TextField({maxLength:6})
			    ),
				sortable : true
			},{
				header :  '是否显示',
				dataIndex : 'is_visible',
				editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
					typeAhead : true,
					triggerAction : 'all',
					hiddenName : 'is_visible',
					mode : 'local',
					store : yesNoStore,
					displayField : 'name',
					valueField : 'value',
					editable : false
				})),
				scope : this,
				renderer : this.yesNoValue,
				sortable : true
			},{
				header :  '是否关联转换',
				dataIndex : 'is_trans',
				editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
					typeAhead : true,
					triggerAction : 'all',
					hiddenName : 'is_trans',
					mode : 'local',
					store : yesNoStore,
					displayField : 'name',
					valueField : 'value',
					editable : false
				})),
				scope : this,
				renderer : this.yesNoValue,
				sortable : true
			},{
				header :'关联字典',
				dataIndex : 'dic_code',
				id : 'column_dic_item_create',
				width:200,
				editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:40})
				),
				sortable : true
			},{
				header :  '排序',
				dataIndex : 'column_sort',
			    editor : new Ext.grid.GridEditor(
					 new Ext.form.TextField({maxLength:3})
				),  
				sortable : true
			}
        ]);
		
		// 显示字段配置列表
		columnEditGridCreate = new Ext.grid.EditorGridPanel({
			id : 'column_edit_grid_create',
			region : 'center',
			border : true,
			height : 600,
			loadMask : true,
			title : '报表字段',
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.columnEditGridStore,
			sm : csm,
			// 列定义
			cm : column_cm,
			// 定义数据列表监听事件
			listeners : {
				//编辑前完成后处理事件
				'beforeedit' : function(e) {
			    },
			    //编辑后完成后处理事件
				'afteredit' : function(e) {
					var len = columnEditGridCreate.getStore().data.items.length;
					//字段排序验证
					if(e.field == 'column_sort'){
						var sort = e.record.get('column_sort');
						if(sort==null || sort==''){
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '排序不能为空！',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.WARNING,
								minWidth : 200
							}); 
						}else{
							var num1 = 0;
							for(var i=0;i<len;i++){
								if(columnEditGridCreate.getStore().data.items[i].data.column_sort==sort)
									num1++;
							}
							if(num1>1){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '排序重复，请重新输入！',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								}); 
								e.record.set('column_sort',"");
							}
						}
					}
					//字段别名验证
					if(e.field == 'column_ch_name'){
						var chName = e.record.get('column_ch_name');
						if(chName==null || chName==''){
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '别名不能为空！',
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.WARNING,
								minWidth : 200
							}); 
						}else{
							var num2 = 0;
							for(var m=0;m<len;m++){
								if(columnEditGridCreate.getStore().data.items[m].data.column_ch_name==chName)
									num2++;
							}
							if(num2>1){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '别名重复，请重新输入！',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								}); 
								e.record.set('column_ch_name','');
							}
						}
					}
			    },
			    cellclick : function(grid, rowIndex, columnIndex, e) {
			    	var oldValue = grid.getStore().getAt(rowIndex).get('column_dic_item_create');
					var params = {
						rowIndex : rowIndex ,
						oldValue : oldValue
					};
					switch (columnIndex) {
					case 6:
						app.loadWindow('${ctx}/${frameworkPath}/item/rptColumn', params);
						break;
					default:
						break;
					}
				}
			}
		});
		// 报表列配置 ---------------------------end
		
		// 报表规则 -----------------------------begin
		this.reportRuleStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jedarpt/getRuleList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			fields : [ 'rule_code', 
			           'rule_en_name', 
			           'rule_ch_name', 
			           'rule_desc', 
			           'rule_content', 
			           'creator', 
			           'created', 
			           'modifier', 
			           'modified', 
			           'delete_flag'],
			remoteSort : true,
			sortInfo : {
				field : 'rule_code',
				direction : 'DESC'
			},
			baseParams : {
				reportId : ''
			}
		});
		this.reportRuleStore.load();
		// 报表规则列表
		reportRuleGridCreate = new Ext.grid.EditorGridPanel({
			region : 'center',
			height : 700,
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.reportRuleStore,
			sm : csmRule,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csmRule, {
				header : '规则编号',
				dataIndex : 'rule_code',
				hidden : true
			},{
				header : '规则名称',
				dataIndex : 'rule_en_name'
			},{
				header : '规则别名',
				dataIndex : 'rule_ch_name'
			},{
				header : '规则描述',
				dataIndex : 'rule_desc'
			},{
				header : '规则内容',
				dataIndex : 'rule_content',
				renderer : function (data, metadata, record, rowIndex, columnIndex, store) {
				    var ruleName = record.get('rule_ch_name');    
					var title = '规则['+ruleName+']的内容：';
				    var tip = record.get('rule_content');    
				    metadata.attr = 'ext:qtitle="' + title + '"' + ' ext:qtip="' + tip + '"';    
				    var displayText =  record.get('rule_content') ;    
				    return displayText;    

				}
			}]
		});
		// 报表规则 -----------------------------end
		
		// 报表角色 -----------------------------end
		this.reportRoleGridStore = new Ext.data.JsonStore( {
			proxy : new Ext.data.HttpProxy( {
				method : 'POST',
				url : '${ctx}/${appPath}/jedarpt/getRoleList',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			totalProperty : 'count',
			fields : [
						'role_code',
						'role_name',
						'role_type',
						'role_desc',
						'role_order'
					],
			remoteSort : true,
			sortInfo : {
				field : 'role_order',
				direction : 'ASC'
			},
			baseParams : {
				reportId : ''
			}
		});
		this.reportRoleGridStore.load();
		// 实例化数据列表组件
		reportRoleGridCreate = new Ext.grid.GridPanel({
			region : 'center',
			height : 700,
			border : false,
			loadMask : true,
			columnLines : true,
			viewConfig : {
				forceFit : true
			},
			store : this.reportRoleGridStore,
			sm : csmRole,
			autoExpandColumn : 'name',
			columns : [ new Ext.grid.RowNumberer(), csmRole, {
				header : '角色编码',
				dataIndex : 'role_code'
			},{
				header : '角色名称',
				dataIndex : 'role_name'
			},{
				header : '角色类型',
				dataIndex : 'role_type'
			},{
				header : '角色描述',
				dataIndex : 'role_desc'
			},{
				header : '排序',
				dataIndex : 'role_order'
			}]
		});
		
		// 第一步
	 	panelOneCreate = new Ext.Panel({  
			title:'报表基本信息',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
            items:[{
                columnWidth:.96,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
                items: [
                {	columnWidth:.96,
                    layout: 'column',
                    defaults: {anchor : '100%'},
                    border:false,
                    labelWidth : 100 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '<font color=red>*</font>&nbsp;报表名称',
	    				    id : 'report_name_create',
	    					name : 'report_name',
	    					maxLength : 60 ,
	    					tabIndex : this.tabIndex++ 
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : []
    				}]
                },{	columnWidth:.96,
                    layout: 'column',
                    defaults: {anchor : '100%'},
                    border:false,
                    labelWidth : 100 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'column',
                    	defaults: {anchor : '100%'},
                    	items : [{
                        	columnWidth:.9,
                        	layout: 'form',
                        	defaults: {anchor : '100%'},
                        	items : [{
                        		xtype : 'textfield',
    	    					fieldLabel : '<font color=red>*</font>&nbsp;展现路径',
    	    				    id : 'parent_menu_name_create',
    	    					name : '',
    	    					readOnly : true,
    	    					tabIndex : this.tabIndex++ 
                        	},{
                        		xtype : 'textfield',
    	    					fieldLabel : '<font color=red>*</font>&nbsp;展现路径',
    	    				    id : 'parent_menu_code_create',
    	    					name : 'parent_menu',
    	    					hidden : true,
    	    					tabIndex : this.tabIndex++ 
                        	}]
        				},{
        					columnWidth:.1,
        					layout: 'form',
        					defaults: {anchor : '100%'},
        					items : [{
        						xtype : 'button',
        						text:'配置',
    	  						height : 15 ,
    	  						id : '',
    	  						name : '',
    	  						style : '',
    	  						listeners:{
    	  							click:function(bt){
    	  								var params = {};
    	  								app.loadWindow('${ctx}/${appPath}/jedarpt/getShowPath', params);
    	  							}
    	  						},
    	    					tabIndex : this.tabIndex++ 
        					}]
        				}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items: [{
    						xtype : 'combo',
	    					fieldLabel : '报表分类',
	    					store : rptTypeStore,
	    					valueField : 'value',
	    					displayField : 'name',
	    					hiddenName : 'report_type',
	    					mode : 'local',
	    					triggerAction : 'all',
	    					forceSelection : true,
	    					editable : true,
	    					tabIndex : this.tabIndex++ 
    					}]
    				}]
                },{
                	xtype:'textarea',
					fieldLabel : '报表描述',
					name : 'report_desc',
					id : '',
					height : 25,
					maxLength : 200,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textarea',
					fieldLabel : '<font color=red>*</font>&nbsp;查询SQL',
					name : 'report_sql',
					id : 'report_sql_create',
					height : 325,
					//maxLength : 6000 ,
					allowBlank : false,
					emptyText : '填写说明：\r\n'+
						'1.参数格式： col like #col#  ;\r\n'+
						'2.参数比较时，=换成like，进行模糊查询  ;\r\n'+
						'3.sql中的应用系统编号，必须写成as appsys_code，并且参数类型为：下拉框  ;\r\n'+
						'4.sql中的应用系统名称，必须写成as appsys_name，并且参数类型为：下拉框  ;\r\n'+
						"5.sql中日期参数会转成yyMMdd字符串格式，所以进行日期比较时需要to_char(t.col ,'yyyymmdd')  ;\r\n"+
						'6.多表查询时，表字段加上别名（t.col），查询字段也加上别名（as col01,不限中英文）;\r\n'+
						'7.数据库默认是maoprpt，跨数据库时表后面需要加上相应的DBLink，eg：CHECK_JOB_INFO@DB_JEDA_LINK ;\r\n'+
						"8.所有查询字段必须加别名 col as colAlias,且字段间的逗号换成'#,#''。eg: select t.a as a #,# t.b as b ...  ",
					listeners : {
						scope : this,
						'change' : function() {
							var sql = Ext.getCmp("report_sql_create").getValue();
							var params = [];
							var records = parmEditGridCreate.getStore();
							records.each(function(item) {
								params.push(item.data);
							});
							this.paramEditGridStore.baseParams.params = Ext.util.JSON.encode(params);
							this.paramEditGridStore.baseParams.sql = sql;
							this.paramEditGridStore.reload();
							this.columnEditGridStore.baseParams.sql = sql;
							this.columnEditGridStore.reload();
						}
					}
				},parmEditGridCreate]
            }]
	    });   
		
		// 第二步
	 	panelTwoCreate = new Ext.Panel({  
	 		title:'导出模板信息',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px;padding-buttom:10px'},
			items : {
				columnWidth:.96,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
    			labelWidth : 100 ,
                items: [{
					xtype : 'fileuploadfield',
					fieldLabel:'上传模板路径',
					id : 'template_path_load_create',
					name : '',
					hiddenName : '',
					buttonText : '<fmt:message key="property.glance" />',
					editable : true ,
					buttonCfg: {
						iconCls: 'upload-icon'
					},
					listeners : {
						scope : this,
						'fileselected' : function(fileField, path) {
							var fileType = path.substring(path.lastIndexOf('.') + 1);
							if(fileType=='xls' || fileType=='XLS'){
								Ext.getCmp('template_path_create').setValue(path);
								var templateName = path.substring(path.lastIndexOf('\\') + 1);
								Ext.getCmp('template_en_name_create').setValue(templateName);
								Ext.getCmp('start_row_num_create').setValue('1');
								Ext.getCmp('start_col_num_create').setValue('1');
							}else{
								Ext.getCmp('template_path_load_create').setValue('');
								Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '请上传xls格式的Excel文件！',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									minWidth : 200
								});
								return;
							}
						}
					}
				},{	
					columnWidth:.96,
                    layout: 'column',
                    defaults: {anchor : '100%'},
                    border:false,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '模板名称',
	    				    id : 'template_en_name_create',
	    					name : 'template_en_name',
	    					readOnly : true,
	    					tabIndex : this.tabIndex++ 
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '模板别名',
	    					id : 'template_ch_name_create',
	    					name : 'template_ch_name',
	    					hidden : true, //模板别名暂不启用
	    					tabIndex : this.tabIndex++
    					}]
    				}]
                },{	
                	columnWidth:.96,
                    layout: 'column',
                    defaults: {anchor : '100%'},
                    border:false,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '开始行号',
	    				    id : 'start_row_num_create',
	    					name : 'start_row_num',
	    					tabIndex : this.tabIndex++,
	    					listeners : {
	    						'change' : function(textField,newValue,oldValue) {
	    							if(newValue.search(/^\d+$/)==-1){
	    								Ext.Msg.show( {
	    									title : '<fmt:message key="message.title" />',
	    									msg :  '开始行号必须是数字格式,默认值为1！',
	    									buttons : Ext.MessageBox.OK,
	    									icon : Ext.MessageBox.WARNING,
	    									minWidth : 200
	    								}); 
	    								Ext.getCmp('start_row_num_create').setValue('1');
	    							}
	    						}
	    					}
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '开始列号',
	    					id : 'start_col_num_create',
	    					name : 'start_col_num',
	    					tabIndex : this.tabIndex++,
	    					listeners : {
	    						'change' : function(textField,newValue,oldValue) {
	    							if(newValue.search(/^\d+$/)==-1){
	    								Ext.Msg.show( {
	    									title : '<fmt:message key="message.title" />',
	    									msg :  '开始列号必须是数字格式,默认值为1！',
	    									buttons : Ext.MessageBox.OK,
	    									icon : Ext.MessageBox.WARNING,
	    									minWidth : 200
	    								}); 
	    								Ext.getCmp('start_col_num_create').setValue('1');
	    							}
	    						}
	    					}
    					}]
    				}]
                },columnEditGridCreate]
            },
			listeners : {
				scope : this,
				'activate' : function(panel) {
				}
			}
	    });
		
	 	// 第三步 - 定制报表规则
	 	panelThreeCreate = new Ext.Panel({  
	 		title : '规则制定',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
			items : reportRuleGridCreate,
			listeners : {
				scope : this,
				'activate' : function(panel) {
				}
			}
	    });  
	 	
	    // 第四步 - 角色授权
	 	panelFourCreate = new Ext.Panel({  
	 		title : '角色授权',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
			items : [reportRoleGridCreate,{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_params_create'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_columns_create'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_rules_create'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_roles_create'
			},{
				xtype : 'textfield',
				hidden : true, 
				name : 'template_path',
				id : 'template_path_create'
			}],
			listeners : {
				scope : this,
				'activate' : function(panel) {
				}
			}
	    });  
		
	   
	    //切换面板
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
	            if (i > 3) {  
	                i = 3;  
	                return false;  
	            }  
	        }  
	        var btnPrev = Ext.getCmp("jedaRpt_movePrev_create");  
	        var btnSave = Ext.getCmp("jedaRpt_moveSave_create");  
	        var btnNext = Ext.getCmp("jedaRpt_moveNext_create");  
	        if (i == 0) {  
	            btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.disable(); 
	        }  
	        if(i == 1){
				btnSave.hide();  
	            btnNext.enable();  
	            btnPrev.enable(); 
	            // 报表名称
	            var reportName = Ext.getCmp('report_name_create').getValue();
				if (reportName.trim() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '报表名称不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}else if(reportName.trim().length > 60){
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '报表名称超长，最多60位！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				// 展现路径
				var reportPath = Ext.getCmp('parent_menu_name_create').getValue();
				if (reportPath.trim() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '展现路径不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				// 查询SQL
				var reportSql = Ext.getCmp('report_sql_create').getValue();
				if (reportSql.trim() == '') {
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '查询SQL不能为空！',
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.INFO,
						minWidth : 200
					});
					return i = 0;
				}
				//报表参数
	    		var params = [];
				var records = parmEditGridCreate.getStore();
				records.each(function(item) {
					params.push(item.data);
					var enName = item.data.param_en_name ;
					var chName = item.data.param_ch_name ;
					var type = item.data.param_type ;
					if(enName==null || enName==''){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '参数名称不能为空！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.INFO,
							minWidth : 200
						});
						return i = 0;
					}
					if(chName==null || chName==''){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '参数别名不能为空！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.INFO,
							minWidth : 200
						});
						return i = 0;
					}
					if(type==null || type==''){
						Ext.Msg.show({
							title : '<fmt:message key="message.title" />',
							msg : '参数类型不能为空！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.INFO,
							minWidth : 200
						});
						return i = 0;
					}
	    		});
    			Ext.getCmp("report_params_create").setValue( Ext.util.JSON.encode(params));
	        }
	        if(i == 2){
    			btnSave.hide();  
	            btnNext.enable();   
	            btnPrev.enable();
				//报表字段
	    		var columns = [];
				var records = columnEditGridCreate.getStore();
				records.each(function(item) {
					columns.push(item.data);
					var sort = item.data.column_sort;
					if(sort==null || sort==''){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '排序不能为空！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						}); 
						return i = 1;
					}
					var chName = item.data.column_ch_name;
					if(chName==null || chName==''){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '别名不能为空！',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						}); 
						return i = 1;
					}
	    		});
    			Ext.getCmp("report_columns_create").setValue( Ext.util.JSON.encode(columns));
	        }
	        if(i == 3){
	    		btnSave.show();  
	            btnNext.disable();  
	            btnPrev.enable();
	        }
	        this.cardPanel.getLayout().setActiveItem(i);  
	    };    
	    //CARD总面板  
		this.cardPanel = new Ext.Panel({
			id : 'jedaRpt_cardPanel_create',
			renderTo : document.body,
			height : 700,
			width : 600,
			layout : 'card',
			layoutConfig : {
				deferredRender : true
			},
			activeItem : 0,
			tbar : ['-' ,{
						id : 'jedaRpt_movePrev_create',
						iconCls : 'button-previous',
						text : '<fmt:message key="job.stepBefore" />',
						disabled : true ,
						handler : cardHandler.createDelegate(this,[ -1 ])
					},'-',{
						id : 'jedaRpt_moveSave_create',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						hidden : true,
						handler : this.doSave
					},'-',{
						id : 'jedaRpt_moveNext_create',
						iconCls : 'button-next',
						text : '<fmt:message key="job.stepNext" />',
						handler : cardHandler.createDelegate(this, [ 1 ])
					}  ],
			items : [panelOneCreate,panelTwoCreate,panelThreeCreate,panelFourCreate]
		});
		
		// 设置基类属性		JedaRptCreateForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			labelWidth : 180 ,
			buttonAlign : 'center',
			fileUpload : true, //有文件上传时，该属性必写
			frame : true,
			autoScroll : true,
			method : 'POST',
			url : '${ctx}/${appPath}/jedarpt/create',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			items : [{
				layout : 'fit',
				items : [this.cardPanel] 
			}]
		});
		
	},
	
	// 1-是   0-否
	yesNoValue : function(value) {
		var index = yesNoStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return yesNoStore.getAt(index).get('name');
		}
	},
	
	// 参数类型
	paramTypeValue : function(value) {
		var index = paramTypeStore.find('value', value);
		if (index == -1) {
			return value;
		} else {
			return paramTypeStore.getAt(index).get('name');
		}
	},
	
	// 保存操作
	doSave : function() {
		// 报表规则
        var rules = [];
        var recordsRule = reportRuleGridCreate.getSelectionModel().getSelections();
        for(var i = 0; i<recordsRule.length; i++) {
			rules.push(recordsRule[i].get('rule_code'));
		}
		Ext.getCmp("report_rules_create").setValue(rules);
		// 报表角色
        var roles = [];
        var records = reportRoleGridCreate.getSelectionModel().getSelections();
        for(var i = 0; i<records.length; i++) {
			roles.push(records[i].get('role_code'));
		} 
		Ext.getCmp("report_roles_create").setValue(roles);
		
		// 提交表单
		jedaRpt.getForm().submit({
			scope : jedaRpt,
			timeout : 1800000, //半小时			success : jedaRpt.saveSuccess,
			failure : jedaRpt.saveFailure,
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.saving" />'
		});
	},
	
	// 保存成功回调
	saveSuccess : function(form, action) {
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.successful" />',
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.INFO,
			minWidth : 200,
			fn : function() {
				app.closeTab('JEDA_REPORT_CREATE');
				var list = Ext.getCmp("JEDA_REPORT_MANAGE").get(0);
				if (list != null) {
					list.grid.getStore().reload();
				}
				app.loadTab('JEDA_REPORT_MANAGE', '报表定制', '${ctx}/${appPath}/jedarpt/index');
			}
		});
	},
	// 保存失败回调
	saveFailure : function(form, action) {
		var error = action.result.error;
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
    	});
	} 
	
});
var jedaRpt = new JedaRptCreateForm();
//实例化新建表单,并加入到Tab页中
Ext.getCmp("JEDA_REPORT_CREATE").add(jedaRpt);
//刷新Tab页布局
Ext.getCmp("JEDA_REPORT_CREATE").doLayout();

</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" 
         import="com.nantian.jeda.security.util.SecurityUtils"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var panelOneView = null ;
var panelTwoView = null ;
var panelThreeView = null ;
var panelFourView = null ;

var parmEditGridView = null ; //报表参数
var columnEditGridView = null ; //报表字段
var reportRuleGridView = null ; //报表规则
var reportRoleGridView = null ; //报表角色

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
JedaRptViewForm = Ext.extend(Ext.FormPanel, {
	
	constructor : function(cfg) {// 构造方法
		Ext.apply(this, cfg);
		csm = new Ext.grid.CheckboxSelectionModel();
		csmRule = new Ext.grid.CheckboxSelectionModel({
			handleMouseDown : Ext.emptyFn //选中一行时复选框不勾上
			/* listeners : {
				'beforerowselect':function(SelectionModel,rowIndex,keepExidting,record){
					return false; //复选框不可勾选
				}
			} */
		});
		csmRole = new Ext.grid.CheckboxSelectionModel({
			handleMouseDown : Ext.emptyFn
			/* listeners : {
				'beforerowselect':function(SelectionModel,rowIndex,keepExidting,record){
					return false; //复选框不可勾选
				}
			} */
		});
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
			baseParams : {
				reportId : '${param.reportId}'
			}
		});
		this.paramEditGridStore.load();
		// 列定义
		param_cm=new Ext.grid.ColumnModel([/* csm, */{
				header : '参数名称',
				dataIndex : 'param_en_name',
			    editable : false,
				readOnly : true,
				sortable : true
			},{
				header : '参数别名',
				dataIndex : 'param_ch_name',
			    readOnly : true,
				sortable : true
			},{
				header :  '参数类型',
				dataIndex : 'param_type',
				scope : this,
				readOnly : true,
				renderer : this.paramTypeValue,
				sortable : true
			},{
				header :  '默认值',
				dataIndex : 'default_value',
				readOnly : true,
				sortable : true
			},{
				header :'关联字典',
				dataIndex : 'dic_code',
				id : 'param_dic_item_view',
				width:200,
				readOnly : true,
				sortable : true
			}
        ]);
		// 参数配置列表
		parmEditGridView = new Ext.grid.EditorGridPanel({
			id : 'param_edit_grid_view',
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
			cm : param_cm
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
			baseParams : {
				reportId : '${param.reportId}'
			}
		});
		this.columnEditGridStore.load();
		// 列定义
		column_cm=new Ext.grid.ColumnModel([/* csm, */{
				header : '字段名称',
				dataIndex : 'column_en_name',
				editable : false,
				readOnly : true,
				sortable : true
			},{
				header : '别名',
				dataIndex : 'column_ch_name',
			    readOnly : true,
				sortable : true
			},{
				header : '描述',
				dataIndex : 'column_desc',
			    readOnly : true,
				sortable : true
			},{
				header : '宽度',
				dataIndex : 'column_width',
			    readOnly : true,
				sortable : true
			},{
				header :  '是否显示',
				dataIndex : 'is_visible',
				scope : this,
				readOnly : true,
				renderer : this.yesNoValue,
				sortable : true
			},{
				header :  '是否关联转换',
				dataIndex : 'is_trans',
				scope : this,
				readOnly : true,
				renderer : this.yesNoValue,
				sortable : true
			},{
				header :'关联字典',
				dataIndex : 'dic_code',
				id : 'column_dic_item_view',
				width:200,
				readOnly : true,
				sortable : true
			},{
				header :  '排序',
				dataIndex : 'column_sort',
				readOnly : true,
				sortable : true
			}
        ]);
		
		// 显示字段配置列表
		columnEditGridView = new Ext.grid.EditorGridPanel({
			id : 'column_edit_grid_view',
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
			cm : column_cm
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
				reportId : '${param.reportId}'
			}
		});
		this.reportRuleStore.load();
		// 报表规则列表
		reportRuleGridView = new Ext.grid.EditorGridPanel({
			region : 'center',
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
			fields : [  'role_code',
						'role_name',
						'role_type',
						'role_desc',
						'role_order' ,
				        'checked'],
			remoteSort : true,
			sortInfo : {
				field : 'role_order',
				direction : 'ASC'
			},
			baseParams : {
				reportId : '${param.reportId}'
			}
		});
		this.reportRoleGridStore.on('load',function(store,records,options){
			var records = reportRoleGridView.getStore().query('checked', true).getRange();
	        setTimeout(function(){
	        	reportRoleGridView.getSelectionModel().selectRecords(records, false);
	        }, 500);
		});
		this.reportRoleGridStore.load();
		// 实例化数据列表组件
		reportRoleGridView = new Ext.grid.GridPanel({
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
	 	panelOneView = new Ext.Panel({  
			title:'报表基本信息',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px'},
            items:[{
                columnWidth:.99,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
                items: [
                {	columnWidth:.99,
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
	    					fieldLabel : '报表名称',
	    				    id : 'report_name_view',
	    					name : 'report_name',
	    					maxLength : 60 ,
	    					readOnly : true,
	    					tabIndex : this.tabIndex++ 
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : []
    				}]
                },{	columnWidth:.99,
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
    	    					fieldLabel : '展现路径',
    	    				    id : 'parent_menu_name_view',
    	    					name : '',
    	    					readOnly : true,
    	    					tabIndex : this.tabIndex++ 
                        	},{
                        		xtype : 'textfield',
    	    					fieldLabel : '展现路径',
    	    				    id : 'parent_menu_code_view',
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
    	  						disabled : true,
    	  						listeners:{
    	  							click:function(bt){
    	  								var params = {};
    	  								app.loadWindow('${ctx}/${appPath}/jedarpt/getShowPathForEdit', params);
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
	    					name : 'report_type',
	    					mode : 'local',
	    					triggerAction : 'all',
	    					forceSelection : true,
	    					editable : true,
	    					readOnly : true,
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
					readOnly : true,
					tabIndex : this.tabIndex++
				},{
					xtype : 'textarea',
					fieldLabel : '查询SQL',
					name : 'report_sql',
					id : 'report_sql_view',
					height : 325,
					//maxLength : 6000 ,
					readOnly : true,
					allowBlank : false
				},parmEditGridView]
            }]
	    });   
		
		// 第二步
	 	panelTwoView = new Ext.Panel({  
	 		title:'导出模板信息',
            layout:'column',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px;padding-buttom:10px'},
			items : {
				columnWidth:.99,
                layout: 'form',
                defaults: {anchor : '100%'},
                border:false,
                labelAlign : 'right',
    			labelWidth : 100 ,
                items: [{	
					columnWidth:.99,
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
	    				    id : 'template_en_name_view',
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
	    					id : 'template_ch_name_view',
	    					name : 'template_ch_name',
	    					hidden : true, //模板别名暂不启用
	    					tabIndex : this.tabIndex++
    					}]
    				}]
                },{	
                	columnWidth:.98,
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
	    				    id : 'start_row_num_view',
	    					name : 'start_row_num',
	    					readOnly : true,
	    					tabIndex : this.tabIndex++
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '开始列号',
	    					id : 'start_col_num_view',
	    					name : 'start_col_num',
	    					readOnly : true,
	    					tabIndex : this.tabIndex++
    					}]
    				}]
                },columnEditGridView]
            }
	    });
		
	 	// 第三步 - 定制报表规则
	 	panelThreeView = new Ext.Panel({  
	 		title : '规则制定',
            layout:'form',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px',anchor : '100%'},
			items : reportRuleGridView
	    });  
	 	
	    // 第四步 - 角色授权
	 	panelFourView = new Ext.Panel({  
	 		title : '角色授权',
            layout:'form',
            border:false,
            defaults:{bodyStyle:'padding-left:0px;padding-top:5px',anchor : '100%'},
			items : [reportRoleGridView,{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_params_view'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_columns_view'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_rules_view'
			},{
				xtype : 'textfield',
				hidden : true, 
				id : 'report_roles_view'
			},{
				xtype : 'textfield',
				hidden : true, 
				name : 'template_path',
				id : 'template_path_view'
			},{
				xtype : 'textfield',
				hidden : true, 
				name : 'report_code'
			}]
	    });  

	    // 设置基类属性		JedaRptViewForm.superclass.constructor.call(this, {
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			monitorValid : true,
			// 定义表单组件
			items : [{
	            xtype:'tabpanel',
	            height:700,
	            forceLayout : true,
	            autoScroll:true,
	            enableTabScroll:true,
	            activeTab: 0,
	            deferredRender: false,
	            items:[panelOneView,panelTwoView,panelThreeView,panelFourView]
			}],
			// 定义按钮grid
			buttons : [{
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			}]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${appPath}/jedarpt/view/${param.reportId}',
			method : 'GET',
			waitTitle : '<fmt:message key="message.wait" />',
			waitMsg : '<fmt:message key="message.loading" />',
			scope : this,
			timeout : 18000,
			success : this.loadSuccess,
			failure : this.loadFailure
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
	
	// 数据加载成功回调
	loadSuccess : function(form, action) {
		//展现路径
		var menuCode = Ext.getCmp('parent_menu_code_view').getValue();
		Ext.Ajax.request({
			url : '${ctx}/${appPath}/jedarpt/getPathByMenuCode',
			scope : this,
			params : {
				menuCode : menuCode
			},
			success : function(resp,opts){
				var respText = Ext.util.JSON.decode(resp.responseText);
				Ext.getCmp('parent_menu_name_view').setValue(respText.path);
			}
		});
		var rules = action.result.dataRules; 
		if(rules.length>0){
			var checkedRecords = [];
			var store = reportRuleGridView.getStore();
			for(var t=0 ; t<rules.length ; t++){
				store.each(function(item) {
					if(item.get('rule_code') == rules[t]['rule_code']){
						checkedRecords.push(item);
					}
				}); 
			}
			reportRuleGridView.getSelectionModel().selectRecords(checkedRecords);
		}
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
	//关闭操作
	doClose : function() {
		app.closeTab('JEDA_REPORT_VIEW');
	}
	
});
var jedaRptView = new JedaRptViewForm();
//实例化新建表单,并加入到Tab页中
Ext.getCmp("JEDA_REPORT_VIEW").add(jedaRptView);
//刷新Tab页布局
Ext.getCmp("JEDA_REPORT_VIEW").doLayout();

</script>
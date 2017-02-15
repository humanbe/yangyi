<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
var pageSize = 100;
var initItemNum =4;
var rptItemConfDynamicItem = [];
var rptItemConfform;
var pushItemNumber = [];
var popItemNumber = [];
var curCountNum = 0 ; //当前科目行数
var itemNameLevel1 = ''; //科目一级分类的默认值

//配置固定科目方法
function rptItemConfIndexFixedItemEdit(sheetName,dynamicCount){
	rptItemConfFixedItemNames = ['明细统计时间'];
	rptItemConfIndexSetVal(1,rptItemConfFixedItemNames);
	rptItemConfIndexSetStatus(1,true);
	setItemsVisible(true);//主机名是否可见
	
}
function setItemsVisible(visibleFlag){
	if(null==Ext.getCmp("RptItemConfIndexHostName").getValue()||Ext.getCmp("RptItemConfIndexHostName").getValue()==''){
		Ext.getCmp("RptItemConfIndexHostName6").setValue('');
	}
	Ext.getCmp("RptItemConfIndexHostName6").setVisible(visibleFlag);
	if(visibleFlag){
		Ext.getCmp("RptItemConfIndexHostName6").enable();
	}else{
		Ext.getCmp("RptItemConfIndexHostName6").disable();
	}
}
function rptItemConfIndexSetVal(itemCount, itemNames){
	for(var i = 0; i < itemCount; i ++){
		if(Ext.getCmp("RptItemConfIndexItemName" + (i + 1)) == undefined){
			rptItemConfEdit.doAddItem();
		}
		Ext.getCmp("RptItemConfIndexItemNameOne" + (i + 1)).setValue('ALL');
		Ext.getCmp("RptItemConfIndexItemNameTwo" + (i + 1)).setValue('ALL');
		Ext.getCmp("RptItemConfIndexItemName" + (i + 1)).setValue(itemNames[i]);
		
		Ext.getCmp("RptItemConfIndexItemNameTwoNAME" + (i + 1)).setValue('ALL');
		Ext.getCmp("RptItemConfIndexItemNameNAME" + (i + 1)).setValue(itemNames[i]);
		
		
		Ext.getCmp("RptItemConfIndexItemSeq" + (i + 1)).setValue(i + 1);
	}
}
function rptItemConfIndexSetStatus(itemCount, status){
	for(var i = 0; i < itemCount; i++){
		if(Ext.getCmp("RptItemConfIndexItemName" + (i + 1)) != undefined){
			Ext.getCmp("RptItemConfIndexItemNameOne" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexItemNameTwo" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexItemName" + (i + 1)).setDisabled(status);
			
			Ext.getCmp("RptItemConfIndexItemNameTwoNAME" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexItemNameNAME" + (i + 1)).setDisabled(status);
			
			Ext.getCmp("RptItemConfIndexItemSeq" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexExpression" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexExpressionUnit" + (i + 1)).setDisabled(status);
			Ext.getCmp("RptItemConfIndexGroupParent" + (i + 1)).setDisabled(status);
			if((i + 1) == 1){
				Ext.getCmp("RptItemConfIndexButton" + (i + 1)).setDisabled(status);
				Ext.getCmp("RptItemConfIndexButtonTwo" + (i + 1)).setDisabled(status);
			}
		}
	}
}

//获取系统代码列表数据
var rptItemConfAplCodeStore =  new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForCheck',
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

RptItemConfIndexItemLevel1Store.reload();
//科目二级分类
var RptItemConfIndexItemLevel2Store = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptItemLevel2',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});
//科目三级分类
var RptItemConfIndexItemLevel3Store = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url: '${ctx}/${managePath}/dayrptmanage/browseDayRptItemLevel3',
		method : 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['valueField', 'displayField'])
});

//定义列表
RptItemConfEdit = Ext.extend(Ext.Panel, {
	gridStore : null,// 数据列表数据源	grid : null,// 数据列表组件
	form : null,// 查询表单组件
	tabIndex : 0,// 查询表单组件Tab键顺序	csm : null,// 数据列表选择框组件	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
		//默认添加4个可编辑科目
		for(var i = 1; i <= initItemNum; i++){
			this.doPush(i);
		}
	    // create the data store
	    var record = Ext.data.Record.create([
	   		{name: 'combine'},
	     	{name: 'itemSeq', type: 'int'},
	     	{name: 'sheetSeq', type: 'int'},
	     	{name: 'sheetSeqForSetVal', type: 'string'},
	     	{name: 'expression', type: 'string'},
	     	{name: 'expressionUnit', type: 'string'},
	     	{name: 'groupParent', type: 'string'},
	     	{name: '_id', type: 'int'},
	     	{name: '_parent', type: 'auto'},
	     	{name: '_is_leaf', type: 'bool'},
	     	{name: 'dataGroupFlag', type: 'string'},
	     	{name: 'aplCode', type: 'string'},
	     	{name: 'reportType', type: 'string'},
	     	{name: 'sheetName', type: 'string'},
	     	{name: 'itemNameOne', type: 'string'},
	     	{name: 'itemNameTwo', type: 'string'},
	     	{name: 'itemName', type: 'string'}
	   	]);
	    
	    
	 
	    rptItemConfform = new Ext.FormPanel({
			id : 'RptItemConfEditFormPanel',
			title : '编辑',
			region:'center',
			frame : true,
			split : true,
			//autoHeight: true,
			//bodyStyle : 'overflow-x:scroll',
			bodyStyle : 'padding-left:0px;padding-bottom:0px;padding-top:0px;padding-right:0px;',
			labelAlign : 'right',
			buttonAlign : 'center',
			labelWidth: 55,
			/* width : 270,
			minSize : 270,
			maxSize : 270, */
			defaults: {
            	anchor: '100%',
            	msgTarget: 'qtip'
        	},
			monitorValid : true,
	     	autoScroll : true,
			items : [{
				xtype : "fieldset",
		        border : false,
				layout : 'column', 
				labelAlign : 'right',
				columnWidth : 1,
	            items:[{
				columnWidth : .2,
			    xtype: 'fieldset',
			    layout : 'form',
			    border : false,
				labelWidth : 60,
			    autoHeight : true,
			    items : [ {
				xtype : 'textfield',
				fieldLabel: '功能序号',
				id : 'RptItemConfIndexSheetSeq6',
				name : 'sheetSeq',
				maxLength : 2,
				vtype : 'alphanum',
				//maskRe : /[0-9]/,
				regex : /^[1-9]\d{0,1}$/,
				regexText   : '请输入非0开头的整数',
				emptyText : '可选',
					anchor : '100%'
				}]
			},
       		  {
        	columnWidth : .4,
            xtype: 'fieldset',
            layout : 'form',
            border : false,
			labelWidth : 60,
            autoHeight : true,
            items : [ {
			xtype : 'textfield',
			fieldLabel : '功能描述',
			id : 'RptItemConfIndexSubSheetNameV6',
			name : 'subSheetName',
			editable : true,
			allowBlank : true,
			emptyText : '可选',
			maxLength : 30,
			width : 90,
			anchor : '100%',
			hidden : false
		}]
		                },
		{
			columnWidth : .4,
            xtype: 'fieldset',
            layout : 'form',
            border : false,
			labelWidth : 60,
            autoHeight : true,
            items : [ {
			xtype : 'textfield',
			fieldLabel : '主机名/IP',
			id : 'RptItemConfIndexHostName6',
			name : 'hostName',
			editable : true,
			//allowBlank : false,
			emptyText : '可选',
			maxLength : 30,
			anchor : '100%',
			hidden : true
		}]
		}]
         },
						rptItemConfDynamicItem
			],
			// 定义按钮
			buttons : [ {
				iconCls : 'button-add',
				text : '添加科目',
				scope : this,
				handler : this.doAddItem
			},{
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : this.doSave
			},{
				text : '<fmt:message key="button.delete" />',
				iconCls : 'button-delete',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doDelete
			}, {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				scope : this,
				handler : this.doClose
			} ]
		});
		// 设置基类属性		RptItemConfEdit.superclass.constructor.call(this, {
			layout : 'border',
			border : false,
			items : [ rptItemConfform]
		});
	},
	// 增加科目表单
	doAddItem : function() {
		Ext.getCmp("RptItemConfEditFormPanel").add({
			xtype:"fieldset",
			border : false,
			id : 'RptItemConfIndexFieldSet' + (pushItemNumber.length + 1),
			layout : 'column',
			labelAlign : 'right',
			columnWidth : 1,
            height : 32,
			bodyStyle: 'padding-left:0px;padding-bottom:0px;padding-top:0px;padding-right:0px;',
            items:[{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                labelWidth : 55,
                height : 35,
                items : [{
	            	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '一级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameOne' + (pushItemNumber.length + 1),
					name : 'itemNameOne' + (pushItemNumber.length + 1),
					hiddenName : 'itemNameOne' + (pushItemNumber.length + 1),
					store : RptItemConfIndexItemLevel1Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(combo, record, index) {
							itemNameLevel1 = combo.getValue();
							//科目二级分类
	            			RptItemConfIndexItemLevel2Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('RptItemConfIndexAplCode').getValue()),
	            				itemLevel1 : encodeURIComponent(combo.getValue())
							};
	            			RptItemConfIndexItemLevel2Store.reload();
						}
					}
               }]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                labelWidth : 55,
                height : 35,
                items : [{
	            	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '二级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameTwoNAME' + (pushItemNumber.length + 1),
					store : RptItemConfIndexItemLevel2Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						beforequery : function(combo, record, index){
							var value1 = Ext.getCmp('RptItemConfIndexItemNameOne' + (pushItemNumber.length)).getValue();
							if(value1==''){
								RptItemConfIndexItemLevel2Store.removeAll() ;
							}
						},
						select : function(combo, record, index) {
							//科目三级分类
	            			RptItemConfIndexItemLevel3Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('RptItemConfIndexAplCode').getValue()),
	            				itemLevel1 : encodeURIComponent(itemNameLevel1),
	            				itemLevel2 : encodeURIComponent(combo.getValue())
							};
	            			RptItemConfIndexItemLevel3Store.reload();
	            			
	            			Ext.getCmp('RptItemConfIndexItemNameTwo' + (pushItemNumber.length)).setValue(combo.getValue());
						}
					}
               },{
	            	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '二级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameTwo' + (pushItemNumber.length + 1),
					name : 'itemNameTwo' + (pushItemNumber.length + 1),
					hiddenName : 'itemNameTwo' + (pushItemNumber.length + 1),
					store : RptItemConfIndexItemLevel2Store,
					hidden:true,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {}
               }]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                labelWidth : 32,
                height : 35,
                items : [{
					xtype : 'combo',
					width : 60,
					anchor : '100%',
					fieldLabel : '科目',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameNAME' + (pushItemNumber.length + 1),
					store : RptItemConfIndexItemLevel3Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						beforequery : function(combo, record, index) {
							var value1 = Ext.getCmp('RptItemConfIndexItemNameOne' + (pushItemNumber.length)).getValue();
							var value2 = Ext.getCmp('RptItemConfIndexItemNameTwoNAME' + (pushItemNumber.length)).getValue();
							if(value1=='' || value2==''){
								RptItemConfIndexItemLevel3Store.removeAll() ;
							}
						},
						select : function(combo, record, index){
							Ext.getCmp('RptItemConfIndexItemName' + (pushItemNumber.length)).setValue(combo.getValue());
						}
					}
       	 		},{
					xtype : 'combo',
					width : 110,
					anchor : '100%',
					fieldLabel : '科目',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemName' + (pushItemNumber.length + 1),
					name : 'itemName' + (pushItemNumber.length + 1),
					hiddenName : 'itemName' + (pushItemNumber.length + 1),
					hidden:true,
					store : RptItemConfIndexItemLevel3Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {}
       	 		}]
            },{
            	columnWidth : .06,
				id : 'RptItemConfIndexItemSeqSet' + (pushItemNumber.length + 1),
                xtype: 'fieldset',
                layout : 'form',
                border : false,
				labelWidth : 32,
                height : 35,
                items : [{
					xtype : 'textfield',
					fieldLabel: '序号',
					id : 'RptItemConfIndexItemSeq' + (pushItemNumber.length + 1),
					name : 'itemSeq' + (pushItemNumber.length + 1),
					maxLength : 2,
					vtype : 'alphanum',
					maskRe : /[0-9]/,
					regex : /^[1-9]\d{0,1}$/,
					regexText   : '请输入非0开头的整数',
					//allowBlank : false,
					emptyText : '必填',
					width : 30,
					anchor : '100%'
     			}]
            },{
            	columnWidth : .16,
				id : 'RptItemConfIndexExpressionSet' + (pushItemNumber.length + 1),
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 45,
                height : 35,
                items : [{
    				xtype : 'textfield',
					fieldLabel: '计算式',
    				id : 'RptItemConfIndexExpression' + (pushItemNumber.length + 1),
    				name : 'expression' + (pushItemNumber.length + 1),
    				width : 100,
    				maxLength : 600,
    				emptyText  : '可选',
					anchor : '100%'
         		}]
            },{
            	columnWidth : .04,
				id : 'RptItemConfIndexButtonSetTwo' +  (pushItemNumber.length + 1),
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                height : 35,
                items : [{
    				xtype : 'button',
    				id : 'RptItemConfIndexButtonTwo' +  (pushItemNumber.length + 1),
    				name : 'button2' +  (pushItemNumber.length + 1),
    				text : '编辑',
					anchor : '100%',
    				listeners : {
    					scope : this,
    					click : function(button, eventO)  {
    						curCountNum = pushItemNumber.length;
    						Return_Win2.show();
    					}
    				}
        		}]
            },{
            	columnWidth : .06,
				id : 'RptItemConfIndexExpressionUnitSet' + (pushItemNumber.length + 1),
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 32,
                height : 35,
                items : [{
    				xtype : 'textfield',
					fieldLabel: '单位',
    				id : 'RptItemConfIndexExpressionUnit' + (pushItemNumber.length + 1),
    				name : 'expressionUnit' + (pushItemNumber.length + 1),
    				width : 30,
    				maxLength : 10,
    				emptyText  : '可选',
					anchor : '100%'
         		}]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 45,
                height : 35,
                items : [{
					fieldLabel: '分组名',
 					xtype : 'textfield',
 					id : 'RptItemConfIndexGroupParent' + (pushItemNumber.length + 1),
 					name : 'groupParent' + (pushItemNumber.length + 1),
 					width : 80,
 					maxLength : 200,
 					emptyText  : '不同分组间以逗号分隔',
					anchor : '100%'
      			}]
            },{
            	columnWidth : .04,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                height : 35,
                items : [{
    				xtype : 'button',
    				id : 'RptItemConfIndexButton' + (pushItemNumber.length + 1),
    				name : 'button' + (pushItemNumber.length + 1),
    				text : '删除',
					anchor : '100%',
    				value : pushItemNumber.length + 1,
    				listeners : {
    					scope : this,
    					click : function(button, eventO)  {
    						this.doDelItem(button.value);
    					}
    				}
        		}]
            }]
		});
		this.doPush(pushItemNumber.length + 1);
		Ext.getCmp("RptItemConfEditFormPanel").doLayout();
	},
	// 删除查询表单
	doDelItem : function(delVal) {
		popItemNumber.push(delVal);
		rptItemConfDynamicItem.pop();
		var delItem = Ext.getCmp("RptItemConfIndexFieldSet" + delVal);
		rptItemConfform.remove(delItem,true);
		rptItemConfform.getForm().remove(delItem);
		rptItemConfform.doLayout();
		Ext.getCmp("RptItemConfEditFormPanel").remove(delItem);
	},
	// 重置查询表单
	doDynamicConfigItem : function(count) {
		this.doRemoveDynamicItem();//移除所有科目区域
		pushItemNumber = [];
		popItemNumber = [];
		rptItemConfDynamicItem = [];
		for(var i = 1; i <= count; i++){
			this.doPush(i);
		}
		Ext.getCmp("RptItemConfEditFormPanel").add(rptItemConfDynamicItem);
		Ext.getCmp("RptItemConfEditFormPanel").doLayout();
	},
	doRemoveDynamicItem : function(){
		var delItem;
		Ext.each(pushItemNumber, function(itemNum){
			if(popItemNumber.indexOf(itemNum) == -1){
				delItem = Ext.getCmp("RptItemConfIndexFieldSet"+itemNum);
				rptItemConfform.remove(delItem,true);
				rptItemConfform.getForm().remove(delItem);
			}
		});
	},
	//添加科目
	doPush : function(count){
		pushItemNumber.push(count);
		rptItemConfDynamicItem.push({
			xtype:"fieldset",
			border : false,
			id : 'RptItemConfIndexFieldSet' + count,
			layout : 'column',
			labelAlign : 'right',
			columnWidth : 1,
            height : 32,
			bodyStyle: 'padding-left:0px;padding-bottom:0px;padding-top:0px;padding-right:0px;',
            items:[{
            	columnWidth : .16,
				//id : 'RptItemConfIndexItemNameSetOne' + count,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                labelWidth : 55,
                height : 35,
                items : [{
                	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '一级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameOne' + count,
					name : 'itemNameOne' + count,
					hiddenName : 'itemNameOne' + count,
					store : RptItemConfIndexItemLevel1Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						select : function(combo, record, index) {
							//科目二级分类
	            			RptItemConfIndexItemLevel2Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('RptItemConfIndexAplCode').getValue()),
	            				itemLevel1 : encodeURIComponent(Ext.getCmp('RptItemConfIndexItemNameOne' + count).getValue())
							};
	            			RptItemConfIndexItemLevel2Store.load();
						}
					}
       	 		}]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                labelWidth : 55,
                height : 35,
                items : [{
                	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '二级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameTwoNAME' + count,
					store : RptItemConfIndexItemLevel2Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						beforequery : function(combo, record, index){
							var value1 = Ext.getCmp('RptItemConfIndexItemNameOne' + count).getValue();
							if(value1==''){
								RptItemConfIndexItemLevel2Store.removeAll() ;
							}
						},
						select : function(combo, record, index) {
							Ext.getCmp('RptItemConfIndexItemNameTwo' + count).setValue(combo.getValue());
							//科目三级分类
	            			RptItemConfIndexItemLevel3Store.baseParams={
            					appsysCode : encodeURIComponent(Ext.getCmp('RptItemConfIndexAplCode').getValue()),
	            				itemLevel1 : encodeURIComponent(Ext.getCmp('RptItemConfIndexItemNameOne' + count).getValue()),
	            				itemLevel2 : encodeURIComponent(Ext.getCmp('RptItemConfIndexItemNameTwoNAME' + count).getValue())
							};
	            			RptItemConfIndexItemLevel3Store.load();
	            			
	            			
						}
					}
       	 		},{
                	xtype : 'combo',
	            	width : 110,
					anchor : '100%',
					fieldLabel : '二级分类',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameTwo' + count,
					name : 'itemNameTwo' + count,
					hiddenName : 'itemNameTwo' + count,
					//hidden:true,
					store : RptItemConfIndexItemLevel2Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
					}
       	 		}]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                labelWidth : 32,
                height : 35,
                items : [{
					xtype : 'combo',
					width : 110,
					anchor : '100%',
					fieldLabel : '科目',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemNameNAME' + count,
					store : RptItemConfIndexItemLevel3Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
						beforequery : function(combo, record, index) {
							var value1 = Ext.getCmp('RptItemConfIndexItemNameOne' + count).getValue();
							var value2 = Ext.getCmp('RptItemConfIndexItemNameTwoNAME' + count).getValue();
							if(value1=='' || value2==''){
								RptItemConfIndexItemLevel3Store.removeAll() ;
							}
						},
						select : function(combo, record, index){
							Ext.getCmp('RptItemConfIndexItemName' + count).setValue(combo.getValue());
						}
					}
       	 		},{
					xtype : 'combo',
					width : 110,
					anchor : '100%',
					fieldLabel : '科目',
					displayField : 'displayField',
					valueField : 'valueField',
					id : 'RptItemConfIndexItemName' + count,
					name : 'itemName' + count,
					hiddenName : 'itemName' + count,
					hidden:true,
					store : RptItemConfIndexItemLevel3Store,
					mode : 'local',
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					tabIndex : this.tabIndex++,
					listeners : {
					}
       	 		}]
            },{
            	columnWidth : .06,
				id : 'RptItemConfIndexItemSeqSet' + count,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 32,
                height : 35,
                items : [{
					xtype : 'textfield',
					fieldLabel: '序号',
					id : 'RptItemConfIndexItemSeq' + count,
					name : 'itemSeq' + count,
					maxLength : 2,
					vtype : 'alphanum',
					//maskRe : /[0-9]/,
					regex : /^[1-9]\d{0,1}$/,
					regexText   : '请输入非0开头的整数',
					//allowBlank : false,
					emptyText : '必填',
					width : 30,
					anchor : '100%'
     			}]
            },{
            	columnWidth : .16,
				id : 'RptItemConfIndexExpressionSet' + count,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 45,
                height : 35,
                items : [{
    				xtype : 'textfield',
					fieldLabel: '计算式',
    				id : 'RptItemConfIndexExpression' + count,
    				name : 'expression' + count,
    				width : 100,
    				maxLength : 600,
    				emptyText  : '可选',
					anchor : '100%'
         		}]
            },{
            	columnWidth : .04,
				id : 'RptItemConfIndexButtonSetTwo' + count,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                height : 35,
                items : [{
    				xtype : 'button',
    				id : 'RptItemConfIndexButtonTwo' + count,
    				name : 'button2' + count,
    				text : '编辑',
					anchor : '100%',
    				listeners : {
    					scope : this,
    					click : function(button, eventO)  {
    						curCountNum = count;
    						Return_Win2.show();
    					}
    				}
        		}]
            },{
            	columnWidth : .06,
				id : 'RptItemConfIndexExpressionUnitSet' + count,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 32,
                height : 35,
                items : [{
    				xtype : 'textfield',
					fieldLabel: '单位',
    				id : 'RptItemConfIndexExpressionUnit' + count,
    				name : 'expressionUnit' + count,
    				width : 30,
    				maxLength : 10,
    				emptyText  : '可选',
					anchor : '100%'
         		}]
            },{
            	columnWidth : .16,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
				labelWidth : 45,
                height : 35,
                items : [{
					fieldLabel: '分组名',
 					xtype : 'textfield',
 					id : 'RptItemConfIndexGroupParent' + count,
 					name : 'groupParent' + count,
 					width : 80,
 					maxLength : 200,
 					emptyText  : '不同分组间以逗号分隔',
					anchor : '100%'
      			}]
            },{
            	columnWidth : .04,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                //autoHeight : true,
                height : 35,
                items : [{
    				xtype : 'button',
    				id : 'RptItemConfIndexButton' + count,
    				name : 'button' + count,
    				text : '删除',
					anchor : '100%',
    				value : count,
    				listeners : {
    					scope : this,
    					click : function(button, eventO)  {
    						this.doDelItem(button.value);
    					}
    				}
        		}]
            }]
		});
	},
	// 保存操作
	doSave : function() {
		var itemNameDataParam = [];
		var itemSeqs = [];
		var nullItemSeq = false;
		var repeatItemSeq = false;
		var aplCodeParam = Ext.getCmp("RptItemConfIndexAplCode").getValue().trim();
		var reportTypeParam = Ext.getCmp("RptItemConfIndexReportType").getValue().trim();
		var sheetNameParam = Ext.getCmp("RptItemConfIndexSheetName").getRawValue().trim();
		var sheetSeqParam = Ext.getCmp("RptItemConfIndexSheetSeq6").getValue().trim();
		var subSheetName = Ext.getCmp("RptItemConfIndexSubSheetNameV6").getValue().trim();
		var hostName = Ext.getCmp("RptItemConfIndexHostName6").getValue().trim();
		if(subSheetName != '' &&  hostName != ''){
			sheetNameParam = sheetNameParam + '(' + hostName + "_" + subSheetName + ')';
		}else if(subSheetName != '' ){
			sheetNameParam = sheetNameParam + '(' + subSheetName + ')';
		}else if(hostName != ''){
			sheetNameParam = sheetNameParam + '(' + hostName + ')';
		}
		Ext.each(pushItemNumber, function(itemNum){
			if(popItemNumber.indexOf(itemNum) == -1){
				var itemNameOne = Ext.getCmp("RptItemConfIndexItemNameOne"+itemNum).getValue().trim();
				var itemNameTwo = Ext.getCmp("RptItemConfIndexItemNameTwo"+itemNum).getValue().trim();
				var itemName = Ext.getCmp("RptItemConfIndexItemName"+itemNum).getValue().trim();
				var itemSeq = Ext.getCmp("RptItemConfIndexItemSeq"+itemNum).getValue().trim();
				if(itemName !=''){
					if(itemSeq !=''){
						Ext.each(itemSeqs, function(_itemSeq){
							if(itemSeq == _itemSeq){
								repeatItemSeq = true;
							}
						});
						itemSeqs.push(itemSeq);
						var expression = Ext.getCmp("RptItemConfIndexExpression"+itemNum).getValue().trim();
						var expressionUnit = Ext.getCmp("RptItemConfIndexExpressionUnit"+itemNum).getValue().trim();
						var groupParent = Ext.getCmp("RptItemConfIndexGroupParent"+itemNum).getValue().trim();
						itemNameDataParam.push(itemNameOne+"|+|"+itemNameTwo+"|+|"+itemName+"|+|"+itemSeq+"|+|"+expression+"|+|"+expressionUnit+"|+|"+groupParent);
					}else{
						nullItemSeq = true;
					}
				}
			}
		});
		if(nullItemSeq == false && repeatItemSeq == false){
			rptItemConfform.getForm().submit({
				url : '${ctx}/${managePath}/rptitemconf/editRptItem',
				params : {aplCodeParam : aplCodeParam,
							reportTypeParam : reportTypeParam,
							sheetNameParam : sheetNameParam,
							sheetSeqParam : sheetSeqParam,
							itemNameDataParam : itemNameDataParam
							},
				success : this.saveSuccess,
				failure : this.saveFailure,
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.saving" />'
			});
		}else{
			if(nullItemSeq == true){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '已录入科目的科目序号不允许为空，请检查！',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
			if(repeatItemSeq == true){
				Ext.Msg.show( {
					title : '<fmt:message key="message.title" />',
					msg : '已录入科目的科目序号不允许重复，请检查！',
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.WARNING
				});
			}
		}
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
				Ext.getCmp('RptItemConfList').window.close();
				Ext.getCmp("RptItemConfIndexGridPanel").getStore().reload();
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
	},
	// 删除事件
	doDelete : function() {
		var aplCodeParam = Ext.getCmp("RptItemConfIndexAplCode").getValue().trim();
		var reportTypeParam = Ext.getCmp("RptItemConfIndexReportType").getValue().trim();
		var sheetNameParam = Ext.getCmp("RptItemConfIndexSheetName").getRawValue().trim();
		var subSheetName = Ext.getCmp("RptItemConfIndexSubSheetNameV6").getValue().trim();
		var hostName = Ext.getCmp("RptItemConfIndexHostName6").getValue().trim();
		if(aplCodeParam !='' && sheetNameParam !=''){
			if(subSheetName != '' &&  hostName != ''){
				sheetNameParam = sheetNameParam + '(' + hostName + "_" + subSheetName + ')';
			}else if(subSheetName != '' ){
				sheetNameParam = sheetNameParam + '(' + subSheetName + ')';
			}else if(hostName != ''){
				sheetNameParam = sheetNameParam + '(' + hostName + ')';
			}
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.delete" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request( {
							url : '${ctx}/${managePath}/rptitemconf/delete',
							scope : this,
							success : this.deleteSuccess,
							failure : this.deleteFailure,
							params : {
								aplCodeParam : aplCodeParam, 
								reportTypeParam : reportTypeParam,
								sheetNameParam : sheetNameParam,
								_method : 'delete'
							}
						});

					}
				}
			});
		} else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	// 删除成功回调方法
	deleteSuccess : function(response, options) {
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
			Ext.getCmp('RptItemConfList').window.close();
			Ext.getCmp("RptItemConfIndexGridPanel").getStore().reload();// 重新加载数据源
			this.doClose();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.delete.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO
			});
		}
	},
	// 删除失败回调方法
	deleteFailure : function() {
		app.mask.hide();
		Ext.Msg.show( {
			title : '<fmt:message key="message.title" />',
			msg : '<fmt:message key="message.delete.failed" />',
			minWidth : 200,
			buttons : Ext.MessageBox.OK,
			icon : Ext.MessageBox.ERROR
		});
	},
	// 重置查询表单
	doClose : function() {
		Ext.getCmp('RptItemConfList').window.close();
	},
	
	
	
	doSaveReturn : function() {
		var putValue = Ext.getCmp('RptItemConfIndexExpression_edit').getValue();
		Ext.getCmp('RptItemConfIndexExpression' + curCountNum).setValue(putValue);
		Return_Win2.hide();
		
	}
});
								
var rptItemConfEdit = new RptItemConfEdit();
if(Return_Win2!=undefined){
	Return_Win2.destroy();
}

var Return_Win2 = new Ext.Window({
	layout:'form',
	width:720,
	//height:250,
	plain:true,
	autoScroll : true,
	modal : false,
	closable : true,
	resizable : false,
	draggable : true,
	closeAction :'hide',
	items : new Ext.form.FormPanel({
		buttonAlign : 'center',
		labelAlign : 'right',
		labelWidth : 20,
		frame : true,
		layout:'column',
		monitorValid : true,
		items:[
		       {columnWidth : .30,
               xtype: 'fieldset',
               layout : 'form',
               border : false,
               items : [
		       new Ext.Panel({
		    	   
			id:'itemcodetable',
			title: '编码表',
			frame:true, 
			html: ''
		     })
		       ]},{
            	columnWidth : .70,
                xtype: 'fieldset',
                layout : 'form',
                border : false,
                items : [
                  	 new Ext.Panel({
                  		frame:true, 
                  		title : '计算式',
                 	   items : [ {
			xtype : 'textarea',
			id : 'RptItemConfIndexExpression_edit',
			height : 160,
			width:440,
			maxLength:600,
			tabIndex : this.tabIndex++
			}]
                           })
		]
            }],
		buttons : [{
			text :'确定',
			iconCls : 'button-save',
			tabIndex : this.tabIndex++,
			formBind : true,
			scope : this,
			handler : rptItemConfEdit.doSaveReturn
		}]
	}),
	listeners : {
		show : function(){
			if(Ext.getCmp('RptItemConfIndexExpression' + curCountNum)){
				var oldValue = Ext.getCmp('RptItemConfIndexExpression' + curCountNum).getValue();
				Ext.getCmp('RptItemConfIndexExpression_edit').setValue(oldValue);
			}
			var itemcodetable="";
			for(var i = 1; i < pushItemNumber.length; i++){
				if(null!=Ext.getCmp("RptItemConfIndexItemNameOne" + pushItemNumber[i])&&""!=Ext.getCmp("RptItemConfIndexItemNameOne" + pushItemNumber[i])){
					var itemCd=Ext.getCmp("RptItemConfIndexItemName" + pushItemNumber[i]).getValue();
					
					var itemName=Ext.getCmp("RptItemConfIndexItemNameNAME" + pushItemNumber[i]).getRawValue();
					if(curCountNum!=pushItemNumber[i]){
						itemcodetable=itemcodetable+itemName +' : '+itemCd +'<br>';
					}
				}
				}
			Ext.getCmp('itemcodetable').body.update(itemcodetable);			
		}
	}
});		
	

Ext.getCmp('RptItemConfList').window.get(0).add(rptItemConfEdit);
Ext.getCmp('RptItemConfList').window.get(0).doLayout();
//app.window.get(0).add(rptItemConfEdit);
//app.window.get(0).doLayout();

Ext.getCmp("RptItemConfIndexSubSheetNameV6").setValue(Ext.getCmp("RptItemConfIndexSubSheetNameV").getValue());
	Ext.getCmp("RptItemConfIndexSheetSeq6").setValue(Ext.getCmp("RptItemConfIndexSheetSeq").getValue());
	Ext.getCmp("RptItemConfIndexHostName6").setValue(Ext.getCmp("RptItemConfIndexHostName").getValue());
if('${param.itemNameOnes}'==''){
	rptItemConfIndexFixedItemEdit(Ext.getCmp('RptItemConfIndexSheetName').getRawValue(),0);
}else{
	var Recountnum='${param.Recount}';
	var cnum=Recountnum-1;
	rptItemConfEdit.doDynamicConfigItem(cnum);
	rptItemConfIndexFixedItemEdit(Ext.getCmp('RptItemConfIndexSheetName').getRawValue(),Recountnum);
	
	var 		itemNameOnes= Ext.util.JSON.decode(decodeURIComponent('${param.itemNameOnes}'));
	var 	    itemNameTwos= Ext.util.JSON.decode(decodeURIComponent('${param.itemNameTwos}'));
	
	var 		itemNameOnesNAME= Ext.util.JSON.decode(decodeURIComponent('${param.itemNameOnesNAME}'));
	var 	    itemNameTwosNAME= Ext.util.JSON.decode(decodeURIComponent('${param.itemNameTwosNAME}'));
	
	var 		itemNames= Ext.util.JSON.decode(decodeURIComponent('${param.itemNames}'));
	
	var 	    combines= Ext.util.JSON.decode(decodeURIComponent('${param.combines}'));
	
	var 		itemSeqs= Ext.util.JSON.decode(decodeURIComponent('${param.itemSeqs}'));
	var 		expressions= Ext.util.JSON.decode('${param.expressions}') ;
	var 		expressionUnits= Ext.util.JSON.decode('${param.expressionUnits}')  ;
	var 		groupParents= Ext.util.JSON.decode(decodeURIComponent('${param.groupParents}'));
	
	for(var count = 1 ;count <cnum ;count++){
	Ext.getCmp("RptItemConfIndexItemNameOne" + (count+1)).setValue(itemNameOnes[count]);
	Ext.getCmp("RptItemConfIndexItemNameTwo" + (count+1)).setValue(itemNameTwos[count]);
	
	Ext.getCmp("RptItemConfIndexItemNameTwoNAME" + (count+1)).setValue(decodeURIComponent(itemNameTwosNAME[count]));
	Ext.getCmp("RptItemConfIndexItemNameNAME" + (count+1)).setValue(decodeURIComponent(combines[count]));
	
	Ext.getCmp("RptItemConfIndexItemName" + (count+1)).setValue(decodeURIComponent(itemNames[count]));
	Ext.getCmp("RptItemConfIndexItemSeq" + (count+1)).setValue(itemSeqs[count]);
	Ext.getCmp("RptItemConfIndexExpression" + (count+1)).setValue(expressions[count]);
	Ext.getCmp("RptItemConfIndexExpressionUnit" + (count+1)).setValue(expressionUnits[count]);
   Ext.getCmp("RptItemConfIndexGroupParent" + (count+1)).setValue(groupParents[count]);
	}
		
}


</script>

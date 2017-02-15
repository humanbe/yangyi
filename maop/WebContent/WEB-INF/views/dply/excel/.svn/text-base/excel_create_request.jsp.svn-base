<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


this.cmnAppInfoExcelCreateRequestStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['appsysCode','appsysName'])
});
this.cmnAppInfoExcelCreateRequestStroe.load(); 
 
this.envExcelCreateRequestStroe = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({
		url : '${ctx}/${managePath}/excelcreaterequest/queryEnv', 
		method: 'GET'
	}),
	reader: new Ext.data.JsonReader({}, ['env','envName'])
});
this.envExcelCreateRequestStroe.load(); 

this.ExcelCreateRequestStatusStore = new Ext.data.JsonStore({
	autoDestroy : true,
	url : '${ctx}/${frameworkPath}/item/EXCEL_CREATE_REQUEST_STATUS/sub',
	root : 'data',
	fields : [ 'value', 'name' ]
});
this.ExcelCreateRequestStatusStore.load();

//定义列表
ExcelCreateRequestList = Ext.extend(Ext.Panel, {
    gridStore : null,// 数据列表数据源
    grid : null,// 数据列表组件
    form : null,// 查询表单组件
    tabIndex : 0,// 查询表单组件Tab键顺序
    csm : null,// 数据列表选择框组件
    constructor : function(cfg) {// 构造方法
		csm = new Ext.grid.CheckboxSelectionModel();
        Ext.apply(this, cfg);
        // 实例化数据列表数据源
        this.gridStore = new Ext.data.JsonStore( {
            proxy : new Ext.data.HttpProxy( {
                method : 'POST',
                url : '${ctx}/${managePath}/excelcreaterequest/index',
                disableCaching : false
            }),
            autoDestroy : true,
            root : 'data',
            totalProperty : 'count',
            fields : ['requestId','name','app','environment','brpmRequestId','createdAt','updatedAt','stepNum','stepFinishNum','requestStatus'],
            remoteSort : true,
            sortInfo : {
				field : 'requestId',
				direction : 'DESC'
			},
            baseParams : {
                start : 0,
                limit : 100
            }
        });
        this.gridStore.load(); 
        // 实例化数据列表组件


        this.grid = new Ext.grid.GridPanel( {
            id : 'ExcelCreateRequestListGridPanel',
            region : 'center',
            border : false,
            loadMask : true,
            title : '<fmt:message key="title.list" />',
            columnLines : true,
            viewConfig : {
                forceFit : false
            },
            store : this.gridStore,
            // 列定义
			sm : csm,

            columns : [ new Ext.grid.RowNumberer(),csm,
                        //{header : 'id', dataIndex : 'id', sortable : true, width : 200,hidden : true},
                        {
        					header : '<fmt:message key="dplyRequestInfo.requestStatus" />',
        					dataIndex : 'requestStatus',
        					sortable : true,
        					align : 'center',
        					width : 50,
        					renderer : function(value, metadata, record, rowIndex, colIndex, store){
        						if(value == '完成'){
        							return '<img src="${ctx}/static/style/images/button/confirm.png" alt="完成"></img>';
        						}else if(value == '失败'){
        							return '<img src="${ctx}/static/style/images/button/close.png" alt="失败"></img>';
        						}else if(value == '进行中'){
        							return '<img src="${ctx}/static/style/images/button/running.gif" alt="进行中"></img>';
        						}else if(value == '等待'){
        							return '<img src="${ctx}/static/style/images/button/lock.png" alt="等待"></img>';
        						}else {
        							return value;
        						}
        					}
        				},
        				{header : '<fmt:message key="dplyRequestInfo.requestName" />', dataIndex : 'name', sortable : true, width : 200},
                        {header : '<fmt:message key="dplyRequestInfo.appSysCd" />', dataIndex : 'app', sortable :  true,width : 100},
                        {header : '<fmt:message key="dplyRequestInfo.environment" />', dataIndex : 'environment',renderer:this.RequestEnvironmentStoreone, sortable : true, width : 200},
                        {header : '<fmt:message key="dplyRequestInfo.stepNum" />', dataIndex : 'stepNum', sortable : true, width : 80},
                        {header : '<fmt:message key="dplyRequestInfo.stepFinishNum" />', dataIndex : 'stepFinishNum', sortable : true, width : 80}
                        //{header : '<fmt:message key="dplyRequestInfo.requestStatus" />', dataIndex : 'requestStatus', sortable : true, width : 80}, 
                        
                        ],
            // 定义按钮工具条

            tbar : new Ext.Toolbar( {
                items : [ '-' ]
            }),
            // 定义分页工具条

            bbar : new Ext.PagingToolbar( {
                store : this.gridStore,
                displayInfo : true ,
                pageSize : 100 
            }),
            
			listeners : {
				scope : this,
				// 行双击事件：打开数据查看页面
				rowdblclick : this.doView
			} 
        });

        // 实例化查询表单
        this.form = new Ext.FormPanel( {
            //id : 'ExcelCreateRequestIndexFindFormPanel',
            region : 'east',
            title : '<fmt:message key="button.find" />',
            labelAlign : 'right',
            labelWidth : 80,
            buttonAlign : 'center',
            frame : true,
            split : true,
            width : 250,
            minSize : 250,
            maxSize : 250,
            autoScroll : true,
            collapsible : true,
            collapseMode : 'mini',
            border : false,
            defaults : {
                anchor : '100%',
                msgTarget : 'side'
            },
            // 定义查询表单组件
            items : [ {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.appSysCd" />',
					store : cmnAppInfoExcelCreateRequestStroe,
					name : 'app',
					id:'ExcelCreateRequestApp',
					hiddenName : 'app',
					displayField : 'appsysName',
					valueField : 'appsysCode',
					typeAhead : true,
					forceSelection  : true,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true,
					allowBlank : true,
					emptyText : '请选择系统代码...',
					listeners:{
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
					fieldLabel : '<fmt:message key="dplyRequestInfo.requestName" />',
					name : 'name',
					tabIndex : this.tabIndex++
				},
				{
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.environment" />',
					store : envExcelCreateRequestStroe,
					name : 'environment',
					id:'envExcelId',
					hiddenName : 'environment',
					displayField : 'envName',
					valueField : 'env',
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true,
					allowBlank : true,
					emptyText : '请选择环境...',
					listeners : {
						select : function(combo, record, index){
							var envExcelId = combo.value;
							var appsyscd = envExcelId.substring(0, envExcelId.indexOf('_'));
							Ext.getCmp("ExcelCreateRequestApp").setValue(appsyscd);
						},
						expand:function(combo){
							var appsyscdValue = Ext.getCmp('ExcelCreateRequestApp').getValue();
							if(appsyscdValue != ''){
								envExcelCreateRequestStroe.filter('env', appsyscdValue + '_', false, true);
							}
						}
					}
	            }, 
                {
					xtype : 'combo',
					fieldLabel : '<fmt:message key="dplyRequestInfo.requestStatus" />',
					//id : 'ExcelCreateRequestStatus',
					hiddenName : 'requestStatus',
					displayField : 'name',
					valueField : 'value',
					typeAhead : true,
					forceSelection  : true,
					store : ExcelCreateRequestStatusStore,
					tabIndex : this.tabIndex++,
					mode : 'local',
					triggerAction : 'all',
					editable : true
				}
            ], 
            // 定义查询表单按钮
            buttons : [ {
                text : '<fmt:message key="button.ok" />',
                iconCls : 'button-ok',
                scope : this,
                handler : this.doFind
            }, {
                text : '<fmt:message key="button.reset" />',
                iconCls : 'button-reset',
                scope : this,
                handler : this.doReset
            } ]
        });
        // 设置基类属性


        ExcelCreateRequestList.superclass.constructor.call(this, {
            layout : 'border',
            border : false,
            items : [  this.form,this.grid ]
        });
    },
    
	RequestEnvironmentStoreone : function(value) {
		if(value==''){
			return value;
		}
		var elist = value.split('_');
		var env = elist[1];
		if(env=='DEV'){
			return '开发('+value+')';
		}else if(env=='QA'){
			return '测试('+value+')';
		}else if(env=='PROV'){
			return '验证('+value+')';
		}else if(env=='PROD'){
			return '生产('+value+')';
		}else {
			return value;
		}
	},
    // 查询事件
    doFind : function() {
        Ext.apply(this.grid.getStore().baseParams, this.form.getForm().getValues());
        this.grid.getStore().load();
    },// 重置查询表单
    doReset : function() {
        this.form.getForm().reset();
    },
	doUpload : function(){
		dialog = new Ext.ux.UploadDialog.Dialog({
			url : '${ctx}/${managePath}/common/upload',
			title: '<fmt:message key="button.upload"/>' ,   
			post_var_name:'uploadRequestsFiles',//这里是自己定义的，默认的名字叫file  
			width : 450,
			height : 300,
			minWidth : 450,
			minHeight : 300,
			draggable : true,
			resizable : true,
			//autoCreate: true,
			constraintoviewport: true,
			permitted_extensions:['xls','xlsx','xlsm'],
			modal: true,
			reset_on_hide: false,
			allow_close_on_upload: false,    //关闭上传窗口是否仍然上传文件   
			upload_autostart: false     //是否自动上传文件   

		});    
		dialog.show(); 
		dialog.on( 'uploadsuccess' , onUploadServerSuccess); //定义上传成功回调函数
	},
    doView : function() {
		var record = this.grid.getSelectionModel().getSelected();
		var params = {
				requestsId : record.get('requestId')
		};
		//alert(record.get('requestId'));
		app.loadWindow('${ctx}/${managePath}/excelcreaterequest/view', params);
	}
});

//文件上传成功后的回调函数
onUploadServerSuccess = function(dialog, filename, resp_data, record){
	dialog.hide(); 
	
	Ext.Ajax.request({
		url : '${ctx}/${managePath}/excelcreaterequest/allappDbCheck',
		params : {
			fileDbCheckPath : resp_data.filePath
		},
		method : 'POST',
		scope : this,
		disableCaching : true,
		//timeout : 99999999,
		success : function(response){ 
			var allappDbCheckFlag = Ext.util.JSON.decode(response.responseText).success;
			var allappDbCheckMsg = '';
			if(allappDbCheckFlag == ''){
				allappDbCheckMsg = '确定导入？';
			}else{
				allappDbCheckMsg = allappDbCheckFlag;
			}
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : allappDbCheckMsg,
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request({
							
							url : "${ctx}/${managePath}/excelcreaterequest/upload",
							params : {
								filePath : resp_data.filePath
							},
							method : 'POST',
							scope : this,
							timeout : 99999999,
							success : function(response, options) {
								app.mask.hide();
								if (Ext.decode(response.responseText).success == false) {
									var error = Ext.decode(response.responseText).error;
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.import.failed" /><fmt:message key="error.code" />:' + error,
										minWidth : 200,
										width : 400,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
								} else if (Ext.decode(response.responseText).success == true) {
									Ext.Msg.show( {
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.import.successful" />',
										minWidth : 200,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO
									});
									gridStore.reload();
								}
							},
							failure : function(response) {
								app.mask.hide();
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.import.failed" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
							}
						});
						
					}
				}
			});
			
			
		}
	});
	
};
    var ExcelCreateRequestList = new ExcelCreateRequestList();

   
</script>
<sec:authorize access="hasRole('DPLY_EXCEL_CREATE_REQUEST')">
 <script type="text/javascript">
 ExcelCreateRequestList.grid.getTopToolbar().add( {
	iconCls : 'button-excel',
	text : '导入发布流程',//<fmt:message key="button.ExcelCreateRequest.edit" />
	scope : ExcelCreateRequestList,
	handler : ExcelCreateRequestList.doUpload
   },'-');
</script> 
</sec:authorize>
<script type="text/javascript">
Ext.getCmp("ExcelCreateRequest").add(ExcelCreateRequestList);
Ext.getCmp("ExcelCreateRequest").doLayout();
</script>


<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var request_param_list_check = true;
	var sysIdsStore = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			url : '${ctx}/${managePath}/appInfo/querySystemIDAndNamesByUserForDply',
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
	//上线环境
	var onlineEnvStore = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			url : '${ctx}/${managePath}/appInfo/getEnvsByAppAndUser',
			method : 'GET',
			disableCaching : true
		}),
		reader : new Ext.data.JsonReader({}, ['value','name']),
		listeners : {
			load : function(store){
				if(store.getCount() == 0){
					Ext.Msg.show({
						title : '<fmt:message key="message.title" />',
						msg : '当前用户对该系统的环境权限为空，请进行系统环境授权！',
						minWidth : 200,
						buttons : Ext.MessageBox.OK,
						icon : Ext.MessageBox.WARNING
					});
				}
			}
		},
		baseParams : {
			appsysCode : ''
		}
	});

	var importanceLevelStore=null;
	//定义字段列表
	DplyRequestParamList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源		editorGridPanel : null,// 数据列表组件
		form : null,// 查询表单组件
		tabIndex : 0,// 查询表单组件Tab键顺序
		constructor : function(cfg) {// 构造方法			Ext.apply(this, cfg);
			sysIdsStore.load();
			
			var record = Ext.data.Record.create([
				{name: 'mixColumn'},
				{name: '_id', type: 'int'},
				{name: '_is_leaf', type: 'bool'},
				{name: '_parent', type: 'auto'},
				{name: 'name', type: 'string'},
			 	{name: 'value', type:'string'},
			 	{name: 'flag', type:'string'},
			 	{name: 'property',type :'string'},
			 	{name: 'instPath',type :'string'}
			]);
			// 实例化数据列表数据源
			this.gridStore =  new Ext.ux.maximgb.tg.AdjacencyListStore({
		    	proxy : new Ext.data.HttpProxy(
		    		new Ext.data.Connection({
						timeout : 120000,
						url : '${ctx}/${managePath}/dplyrequestinfo/loadParams',
						method : 'POST'
					})
		    	),
				reader: new Ext.data.JsonReader({
					id: '_id',
					root: 'data',
					totalProperty: 'count',
					successProperty: 'success'
				}, record),
				pruneModifiedRecords : true,
				listeners : {
					load : function(store){
						if(store.getCount() == 0){
							Ext.Msg.show({
								title : '<fmt:message key="message.title"/>',
								msg : '<fmt:message key="message.no.data"/>',
								buttons : Ext.Msg.OK,
								icon : Ext.MessageBox.WARNING
							});
							Ext.getCmp('request_param_excel').disable();
							Ext.getCmp('request_param_import').disable();
						}else{
							Ext.getCmp('request_param_excel').enable();
							Ext.getCmp('request_param_import').enable();
						}
					},
					loadexception: function(){
						Ext.Msg.show({
							title : '<fmt:message key="message.title"/>',
							msg : '<fmt:message key="message.load.params.failed"/>',
							buttons : Ext.Msg.OK,
							icon : Ext.MessageBox.ERROR
						});
					}
				}
		    });
         this.gridStore.on('load',function(store){
				if(request_param_list_check){
				
	        	 Ext.Ajax.request({
	     			url : "${ctx}/${managePath}/dplyrequestinfo/checkBSAParams",
	     			params : {
	     			},
	     			method : 'POST',
	     			scope : this,
	     			timeout : 99999999,
	     			success : function(response, options) {
	
	     				if (Ext.decode(response.responseText).success == false) {
	    					var error = Ext.decode(response.responseText).error;
	    					Ext.getCmp('request_param_list_ckeck_data').setValue(error);
	    					request_param_list_Win.show();
	    					/* Ext.Msg.show( {
	    						title : '<fmt:message key="message.title" />',
	    						msg :  error,
	    						minWidth : 200,
	    						width : 400,
	    						buttons : Ext.MessageBox.OK,
	    						icon : Ext.MessageBox.WARNING
	    					}); */
	    				}
	     			}
	        	 });
				}else{
					request_param_list_check = true;
				}
			});
			
			importanceLevelStore = new Ext.data.JsonStore(
					{
						autoDestroy : true,
						url : '${ctx}/${frameworkPath}/item/IMPORTANCE_LEVEL/sub',
						root : 'data',
						fields : [ 'value', 'name' ]
					});
			importanceLevelStore.load();
			// 实例化数据列表组件			this.editorGridPanel = new Ext.ux.maximgb.tg.EditorGridPanel({
				region : 'center',
				title : '<fmt:message key="title.list" /> ',
				animCollapse : true,
		      	master_column_id : 'dplyReqInfoParamMasterColId',
				border : false,
				viewConfig: {
			        forceFit: true
			    },
				loadMask : true,
		      	autoExpandColumn: 'dplyReqInfoParamMasterColId',
				store : this.gridStore,
				columns : [new Ext.grid.RowNumberer(),
				           {id : 'dplyReqInfoParamMasterColId', header : '<fmt:message key="dplyRequestInfo.paramTitle" />', dataIndex : 'name',renderer : this.changeStatusName}, 
				           {header : '<fmt:message key="dplyRequestInfo.paramName" />', dataIndex : 'property', hidden : true}, 
				           {dataIndex : 'instPath', hidden : true}, 
						   {header : '<fmt:message key="dplyRequestInfo.paramValue" />', dataIndex : 'value', editor : new Ext.form.TextField(),renderer : this.changeStatusValue},
						   {header : '重要度标示', 
							dataIndex : 'flag', 
							editor : new Ext.grid.GridEditor(new Ext.form.ComboBox({
										typeAhead : true,
										triggerAction : 'all',
										hiddenName : 'flag',
										mode : 'local',
										store : importanceLevelStore,
										displayField : 'name',
										valueField : 'name',
										editable : false,
										allowBlank : false
									})
							   ),
							renderer : this.changeMoveStatusValue}],
				// 定义按钮工具条				tbar : new Ext.Toolbar({
					items : [ '-', {
						id : 'requestSaveBtn',
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />' ,
						scope : this,
						disabled : true,
						handler : this.doUpdateInst
					}, '-', {
						id : 'requestRefreshBtn',
						iconCls : 'button-refresh',
						text : '<fmt:message key="button.refresh" />' ,
						scope : this,
						disabled : true,
						handler : function(){
							var modified = this.gridStore.getModifiedRecords();
							if(modified.length > 0){
								Ext.Msg.show({
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.confirm.to.reset" />',
									buttons : Ext.MessageBox.OKCANCEL,
									icon : Ext.MessageBox.QUESTION,
									minWidth : 200,
									scope : this,
									fn : function(buttonId) {
										if (buttonId == 'ok') {
											this.gridStore.rejectChanges();
											this.gridStore.reload();
											Ext.getCmp('requestSaveBtn').disable();
										}
									}
								});
							}else{
								this.gridStore.reload();
								Ext.getCmp('requestSaveBtn').disable();
							}
						}
					}, '-', {
						iconCls : 'button-excel',
						id : 'request_param_excel',
						text : '<fmt:message key="button.export" />',
						scope : this,
						disabled : true,
						handler : function() {
							window.location = '${ctx}/${managePath}/dplyrequestinfo/exportParams2Excel.xls';
						}
					}, '-', {
						iconCls : 'button-excel',
						id : 'request_param_import',
						text : '<fmt:message key="button.import" />',
						scope : this,
						disabled : true,
						handler : this.doImport
					}]
				}),
				listeners : {
					scope : this,
					// 编辑前后处理事件
					'beforeedit' : function(e){
						if(!e.record.get('_is_leaf') || e.record.get('mixColumn').indexOf('Class://SystemObject') != -1){
							e.cancel = true;
						}
					} ,
					//编辑完成后处理事件					'afteredit' : function(e){
						Ext.getCmp('requestSaveBtn').enable();
					}
				}
			});
			
			// 实例化查询表单
			this.form = new Ext.FormPanel({
				region : 'north',
				title : '<fmt:message key="button.find" />',
				labelAlign : 'right',
				labelWidth : 100,
				buttonAlign : 'center',
				frame : true,
				split : true,
				height : 70,
				minSize : 200,
				maxSize : 300,
				autoScroll : true,
				border : false,
				defaults : {
					anchor : '100%',
					msgTarget : 'side'
				},
				layout:'column',
				// 定义查询表单组件
				items : [{
	                columnWidth:.96,
	                layout: 'form',
	                defaults: {anchor : '100%'},
	                border:false,
	                labelAlign : 'right',
	                items: [{	
	                	columnWidth:.96,
	                    layout: 'column',
	                    defaults: {anchor : '100%'},
	                    border:false,
	                    labelAlign : 'right',
	                    items: [{
	                    	columnWidth:.5,
	                    	layout: 'form',
	                    	defaults: {anchor : '96%'},
	                    	items : [{
	                    		xtype : 'combo',
	        					fieldLabel:'<font color=red>*</font>&nbsp;<fmt:message key="dplyRequestInfo.appSysCd" />',
	        					store : sysIdsStore,
	        					displayField : 'appsysName',
	        					valueField : 'appsysCode',
	        					hiddenName : 'appSysCode',
	        					mode: 'local',
	        					typeAhead: true,
	        					forceSelection : true,
	        				    triggerAction: 'all',
	        					tabIndex : this.tabIndex++,
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
	        						} ,
	        						select : function(combo, record, index){
	        							onlineEnvStore.load({
        									params : {
        										appsysCode : combo.value
        									}
        								}); 
	        						}
	        					}
	                    	}]
	    				},{
	    					columnWidth:.5,
	    					layout: 'form',
	    					defaults: {anchor : '96%'},
	    					items : [{
	    						xtype : 'combo',
	        					fieldLabel:'<font color=red>*</font>&nbsp;上线环境',
	        					store : onlineEnvStore,
	        					displayField : 'name',
	        					valueField : 'value',
	        					hiddenName : 'onlineEnv',
	        					mode: 'local',
	        					typeAhead: true,
	        					forceSelection : true,
	        				    triggerAction: 'all',
	        					tabIndex : this.tabIndex++,
	        					listeners : {
	        						scope : this,
	        						select : function(combo, record, index){
	        							   request_param_list_check = false,
	        								Ext.apply(this.gridStore.baseParams, {
	        									appSysCode : this.form.getForm().findField('appSysCode').getValue(),
	        									env : this.form.getForm().findField('onlineEnv').getValue()
	        								});
	        								Ext.getCmp('requestSaveBtn').disable();
	        								Ext.getCmp('requestRefreshBtn').enable();
	        								this.gridStore.load({
	        									params : {
	        										appSysCode : this.form.getForm().findField('appSysCode').getValue(),
	        										env : this.form.getForm().findField('onlineEnv').getValue(),
	        										anode : null
	        									}
	        								});
	        								
	        						}
	        					}
	    					}]
	    				}]
	                }]
	            }]
			});

			// 设置基类属性			DplyRequestParamList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [this.form, this.editorGridPanel]
			});
		},
		// 保存操作
		doUpdateInst : function() {
			
			var propsValues = [];
			var modified = this.gridStore.getModifiedRecords();
			
			if(modified.length == 0){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '<fmt:message key="message.no.data.to.save"/>',
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.WARNING
				});
				return;
			}
			//用于记录修改信息内容
			var msg='<br />';
			
			Ext.each(modified, function(item){
				var path=item.data['instPath'];
				var alertValue=item.data['value'];
				if(alertValue=='')
					alertValue='空';
				path=path.substring(path.indexOf('CLASS_')+6, path.length);
				msg+="<pre>"+path+'/'+item.data['mixColumn']+' 的值改为:<br/>&nbsp;<font color=#FF6600>'
				+alertValue+"</font><br /></pre>";
				propsValues.push(item.data);	

			});

			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : msg,
				buttons : Ext.MessageBox.OKCANCEL,
				//icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				maxWidth : 2000,
				scope : this,
				fn : function(buttonId) {
					if (buttonId == 'ok') {
						app.mask.show();
						Ext.Ajax.request({
							url : '${ctx}/${managePath}/dplyrequestinfo/updatePropInstance',
							scope : this,
							method : 'POST',
							success :this.updateSuccess,
							failure : this.updateFailure,
							params : {
								propsValues : Ext.util.JSON.encode(propsValues),
								appSysCode : this.form.getForm().findField('appSysCode').getValue()
							}
						});
					}
				}
			});	
		},
		updateSuccess : function(form, action) {
			app.mask.hide();
			this.gridStore.commitChanges();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.successful" />',
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				minWidth : 200,
				scope : this
			});
			this.gridStore.rejectChanges();
			this.gridStore.reload();

		},
		updateFailure : function(form, action) {
			app.mask.hide();
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		},
		changeStatusName : function(value, metadata, record, rowIndex, colIndex, store) {
			  if(record.get('flag')=='是'){
					return '<span style="color:red;">' + value + '</span>';
				}else{
					return value;
				}  
			},
		changeStatusValue : function(value, metadata, record, rowIndex, colIndex, store) {
			  if(record.get('flag')=='是'){
					return '<span style="color:red;">' + value + '</span>';
				}else{
					return value;
				}  
			},
		changeMoveStatusValue : function(value, metadata, record, rowIndex, colIndex, store) {
			 if(value=='是'){
				
				return '<span style="color:red;">' + value + '</span>';
			}else{
				return value;
			} 
		},
		doImport : function(){
			dialog = new Ext.ux.UploadDialog.Dialog({
				url : '${ctx}/${managePath}/common/upload',
				title: '<fmt:message key="button.upload"/>' ,   
				post_var_name:'uploadFiles',//这里是自己定义的，默认的名字叫file  
				width : 450,
				height : 300,
				minWidth : 450,
				minHeight : 300,
				draggable : true,
				resizable : true,
				//autoCreate: true,
				constraintoviewport: true,
				permitted_extensions:['xls'],
				modal: true,
				reset_on_hide: false,
				allow_close_on_upload: false,    //关闭上传窗口是否仍然上传文件   
				upload_autostart: false     //是否自动上传文件   

			});    
			dialog.show(); 
			dialog.on( 'uploadsuccess' , onUploadSuccess); //定义上传成功回调函数
			//dialog.on( 'uploadcomplete' , onUploadComplete); //定义上传完成回调函数
		},
		doClose :function(){
			request_param_list_Win.hide();
			
		},
		doWindowClose:function(){
			alert_param_list_Win.hide();
		}
		
		
	});
	
	var requestParam = new DplyRequestParamList();
	
	//文件上传成功后的回调函数
	onUploadSuccess = function(dialog, filename, resp_data, record){
		dialog.hide(); 
		app.mask.show();
		Ext.Ajax.request({
			url : "${ctx}/${managePath}/dplyrequestinfo/importParams",
			params : {
				filePath : resp_data.filePath,
				appSysCode : requestParam.form.getForm().findField('appSysCode').getValue(),
				env : requestParam.form.getForm().findField('onlineEnv').getValue()
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
					requestParam.gridStore.rejectChanges();
					requestParam.gridStore.reload();
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
	};
	var  request_param_list_Win = new Ext.Window({
		layout:'form',
		title : 'BSA参数值为空字段',
		width:400,
		height:300,
		plain:true,
		modal : false,
		closable : true,
		resizable : false,
		draggable : true,
		closeAction :'hide',
		items :[ {
				xtype : 'textarea',
				id : 'request_param_list_ckeck_data',
				hideLabel :true,
				height : 220,
				width:380,
				readOnly:true,
				tabIndex : this.tabIndex++
				}]  ,
		
			buttons : [{
				text :'关闭',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : requestParam.doClose
			}]
		
	});	
	
	//修改字段信息显示窗口
	var alert_param_list_Win = new Ext.Window({
		layout:'form',
		title : '修改字段信息',
		width:400,
		height:300,
		plain:true,
		modal : false,
		closable : true,
		resizable : false,
		draggable : true,
		closeAction :'hide',
		items :[ {
				xtype : 'textarea',
				id : 'alert_param_list_data',
				hideLabel :true,
				height : 220,
				width:380,
				readOnly:true,
				tabIndex : this.tabIndex++
				}]  ,
		
			buttons : [{
				text :'关闭',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler:requestParam.doWindowClose
			}]
		
	});	
	
	Ext.getCmp("REQUEST_PARAM_LIST").add(requestParam);
	Ext.getCmp("REQUEST_PARAM_LIST").doLayout();
</script>
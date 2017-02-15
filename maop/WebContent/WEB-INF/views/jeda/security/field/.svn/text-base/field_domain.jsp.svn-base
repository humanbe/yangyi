<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义字段列表
	FieldList = Ext.extend(Ext.Panel, {
		gridStore : null,// 数据列表数据源
		grid : null,// 数据列表组件
		tabIndex : 0,// 查询表单组件Tab键顺序
		csm : null,// 数据列表选择框组件
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);
			// 实例化数据列表选择框组件
			csm = new Ext.grid.CheckboxSelectionModel();
			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'POST',
					url : '${ctx}/${frameworkPath}/field/domainList',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				totalProperty : 'count',
				fields : [ 'accessDomainIp' ],
				remoteSort : true,
				sortInfo : {
					field : 'accessDomainIp',
					direction : 'ASC'
				},
				baseParams : {
					start : 0,
					limit : 20
				}
			});
			// 加载数据源的数据
			this.gridStore.load({
				params : {
					functionId : '${param.functionId}'
				}
			});
			
			var regionIp = Ext.data.Record.create([{xtype : 'textfield',name : 'accessDomainIp',editable : true}]);
			this.region = new Ext.grid.ColumnModel(
						[new Ext.grid.RowNumberer(), csm,
								{
									dataIndex : 'accessDomainIp',
									name : 'accessDomainIp',
									displayField : 'accessDomainIp',
									valueField : 'accessDomainIp',
									hiddenName : 'accessDomainIp',
									editor : new Ext.grid.GridEditor(
          									new Ext.form.TextField({allowBlank:false})
  									),
									sortable : true,
									width : 100
								}]
						);
			// 实例化数据列表组件
			this.grid = new Ext.grid.EditorGridPanel({
				region : 'center',
				id : 'regionId',
				border : false,
				loadMask : true,
				title : '<fmt:message key="title.accessDomainIp" /> ',
				columnLines : true,
				viewConfig : {
					forceFit : true
				},
				store : this.gridStore,
				sm : csm,
				cm : this.region,
				tbar : new Ext.Toolbar({
					items : [ '-', {
						iconCls : 'button-add',
						text : '<fmt:message key="button.create" />',
						scope : this,
						handler :  function() {
							this.gridStore.insert(this.gridStore.getCount(), new regionIp({}));
						}
					}, '-', {
						iconCls : 'button-delete',
						text : '<fmt:message key="button.delete" />',
						scope : this,
						handler : function() {
							var grouprecords = this.grid.getSelectionModel().getSelections();
							this.gridStore.remove(grouprecords);
							this.grid.view.refresh();
						}
					}, '-', {
						iconCls : 'button-save',
						text : '<fmt:message key="button.save" />',
						scope : this,
						handler :  this.doSave
					}, '-']}),
				// 定义数据列表监听事件
				listeners : {
					scope : this,
					//编辑完成后处理事件					'afteredit' : function(e) {
						//验证输入的ip格式
						if(e.field == 'accessDomainIp'){
							var s_ip = e.record.get('accessDomainIp');
							var reHasMask=/^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])\/([1-9]{1}|1[0-9]{1}|2[0-9]{1}|3[0-2]{1})$/;
							var re=/^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$/;
							if(!s_ip.match(re) && !s_ip.match(reHasMask)){
			    				Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg :  '<fmt:message key="toolbox.input_correct_ip" />',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								}); 
								e.record.set('accessDomainIp',"");
			    		     }
				         }
						//验证输入的ip是否重复
						if(e.field == 'accessDomainIp'){
							var ip_name = e.record.get('accessDomainIp');
							var length=this.grid.getStore().data.items.length;
							var ip_param_name=0;
							for(var i=0;i<length;i++){
								if(this.grid.getStore().data.items[i].data.accessDomainIp==ip_name)
									ip_param_name++;
							}
							if(ip_param_name>1){
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '输入的ip重复',
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.WARNING,
									minWidth : 200
								}); 
								e.record.set('accessDomainIp',"");
							}
					      }
						
					}
				}
			});
			
			// 设置基类属性			FieldList.superclass.constructor.call(this, {
				layout : 'border',
				border : false,
				items : [this.grid]
			});
		},
		// 保存操作
		doSave : function() {
			Ext.getCmp('regionId').stopEditing();
			var fieldStoreParam = this.gridStore;
			var m = fieldStoreParam.getModifiedRecords();
			//参数验证
			  for(var k=0;k<m.length;k++){
				var record=m[k];
				var fields=record.fields.keys;
				for(var j=0;j<1;j++){
					var name=fields[j];
					check_value=record.data[name];
					if(check_value==null||check_value==""){
						Ext.Msg.show( {
							title : '<fmt:message key="message.title" />',
							msg : '<fmt:message key="field.param_check_space"/>',
							buttons : Ext.MessageBox.OK,
							icon : Ext.MessageBox.WARNING,
							minWidth : 200
						});
						return ;
					}
				}
			} 
			
			var domainIp = [];
			var modified = this.gridStore.getModifiedRecords();
			if(modified.length == 0 && this.gridStore.getCount() == this.gridStore.getTotalCount()){
				Ext.Msg.show({
					title : '<fmt:message key="message.title"/>',
					msg : '没有数据可保存!',
					buttons : Ext.Msg.OK,
					icon : Ext.MessageBox.WARNING
				});
				return;
			}
			
			var storeLength = this.gridStore.getCount();
			for ( var i = 0; i < storeLength; i++) {
				var name = this.gridStore.data.items[i].data.accessDomainIp;
				domainIp.push(name);
			}
			 Ext.Ajax.request({
				 url : '${ctx}/${frameworkPath}/field/saveDomain',
					method : 'POST',
					scope : this,
					timeout : 300000,
					success : this.saveSuccess,
					failure : this.saveFailure,
					params : {
						domainIp : domainIp,
						functionId : '${param.functionId}'
					}
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
				scope : this,
				fn : function() {
					this.gridStore.commitChanges();
					this.gridStore.reload();
				}
			});
		},
		saveFailure : function(form, action) {
			var error = action.result.error;
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});
	
	app.window.get(0).add(new FieldList());
	app.window.get(0).doLayout();
</script>
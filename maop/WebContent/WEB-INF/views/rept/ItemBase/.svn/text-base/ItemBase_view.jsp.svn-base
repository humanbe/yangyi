<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">


	//定义新建表单
	ItemBaseViewForm = Ext.extend(Ext.FormPanel, {
		tabIndex : 0,// Tab键顺序


		constructor : function(cfg) {// 构造方法


			Ext.apply(this, cfg);
		
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
			this.getItemparentCdStore = new Ext.data.Store(
					{
						proxy: new Ext.data.HttpProxy({
							url : '${ctx}/${managePath}/itembaseconf/getItemparentCd', 
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({}, ['value','name'])
					});
					this.getItemparentCdStore .load();
			// 设置基类属性 

			ItemBaseViewForm.superclass.constructor.call(this, {
				title : '<fmt:message key="title.form" />',
				defaultType : 'textfield',
				labelAlign : 'right',
				buttonAlign : 'center',
				frame : true,
				autoScroll : true,
				defaults : {
					anchor : '80%',
					msgTarget : 'side'
				},
				monitorValid : true,
				items :  [  {
				    xtype : 'textfield',
					fieldLabel : '科目编码',
					name : 'item_cd',
					readOnly:true,
					style  : 'background : #F0F0F0'
				} ,
				{
					xtype : 'combo',
					store : this.getItemparentCdStore ,
					fieldLabel : '父科目编码',
					name : 'parent_item_cd',
					valueField : 'value',
					displayField : 'name',
					hiddenName : 'parent_item_cd',
					mode : 'local',
					readOnly : true, 
					triggerAction : 'all',
					forceSelection : true,
					editable : false,
					allowBlank : false,
					tabIndex : this.tabIndex++,
					allowBlank : false,
					readOnly:true,
					style  : 'background : #F0F0F0',
					listeners : {
					}
				},
				{
				    xtype : 'textfield',
					fieldLabel : '科目名称',
					name : 'item_name',
					readOnly:true,
					style  : 'background : #F0F0F0'
				} ,
				{
				    xtype : 'textfield',
					fieldLabel : '关联表名',
					name : 'relation_tablename',
					readOnly:true,
					style  : 'background : #F0F0F0'
					} 
						],
				buttons : [   {
					text : '<fmt:message key="button.close" />',
					iconCls : 'button-close',
					tabIndex : this.tabIndex++,
					scope : this,
					handler : this.doCancel
				}]
			});

			// 加载表单数据
		 	this.load({
				url : '${ctx}/${managePath}/itembaseconf/view',
				method : 'POST',
				waitTitle : '<fmt:message key="message.wait" />',
				waitMsg : '<fmt:message key="message.loading" />',
				scope : this,
				failure : this.loadFailure,
				success : this.loadSuccess,
				params: {
					
					item_cd:'${param.item_cd}',
					parent_item_cd:'${param.parent_item_cd}'
				}
			}); 
		},
		
		
		// 取消操作
		doCancel : function() {
			app.closeTab('ITEMBASE_VIEW');
		}
		});

	var ItemBaseViewForm = new ItemBaseViewForm();
</script>
<script type="text/javascript">
	//实例化新建表单,并加入到Tab页中
	Ext.getCmp("ITEMBASE_VIEW").add(ItemBaseViewForm);
	// 刷新Tab页布局
	Ext.getCmp("ITEMBASE_VIEW").doLayout();
</script>
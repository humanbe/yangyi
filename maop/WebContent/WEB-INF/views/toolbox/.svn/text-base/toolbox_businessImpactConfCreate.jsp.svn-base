<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<script type="text/javascript">
//删除按钮开始行号
var deleteButtonNum = 1000 ;
//业务影响内容
var contentSet = new Ext.form.FieldSet({
	 frame : false ,
	 border : false ,
     autoHeight:true,
     layout:'column',
     items:[{
        columnWidth:.9,
        layout: 'form',
	 	labelWidth:80,
	 	id : 'impact_conf_contents_win_create' ,
        items: [{
			xtype:'textfield',
			fieldLabel:'业务影响内容',
			anchor:'100%',
			id : 'impact_conf_content_win_create' ,
			allowBlank : false
			
		}]
    },{   //增加
        columnWidth:.1,
        layout: 'form',
		labelWidth:20,
		id : 'impact_conf_content_win_create_buttons',
        items: [{
				xtype:'button',
				iconCls : 'row-add',
	  			text:'增加',
	  			height : 20 ,
	  			listeners:{
	  				click:function(){
	  					deleteButtonNum++ ;
	  					//增加时间列
	  					var tf = new Ext.form.TextField({
	  						xtype:'textfield',
	  						fieldLabel:'业务影响内容',
	  						anchor:'100%',
	  						id : 'impact_conf_content_win_create' +deleteButtonNum,
	  						allowBlank : false
	  					});
	  					Ext.getCmp('impact_conf_contents_win_create').items.add(deleteButtonNum,tf);
	  					Ext.getCmp('impact_conf_contents_win_create').doLayout(); 
	  					
	  					//增加删除按钮列
	  					var bt = new Ext.Button({
	  						iconCls : 'row-delete',
	  						text:'<fmt:message key="button.delete" />',
	  						height : 20 ,
	  						id : 'impact_conf_content_win_create_button_'+deleteButtonNum,
	  						style : 'margin-top:5px',
	  						listeners:{
	  							click:function(bt){
	  								var size = bt.getId().substring(38);
	  								Ext.getCmp('impact_conf_contents_win_create').remove(size);
	  			  					Ext.getCmp('impact_conf_contents_win_create').doLayout(); 
	  			  					Ext.getCmp('impact_conf_content_win_create_buttons').remove(size);
	  			  					Ext.getCmp('impact_conf_content_win_create_buttons').doLayout();
	  							}
	  						}
	  					});
	  					Ext.getCmp('impact_conf_content_win_create_buttons').items.add(deleteButtonNum,bt);
	  					Ext.getCmp('impact_conf_content_win_create_buttons').doLayout(); 
	  				}
	  			}
		  }]
	}]
}); 


ImpactConfCreateForm = Ext.extend(Ext.FormPanel, {
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
		
		// 设置基类属性
		ImpactConfCreateForm.superclass.constructor.call(this, {
			title : '工具箱告警业务影响内容',
			labelAlign : 'right',
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			monitorValid : true,
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			},
			
			// 定义表单组件
			items : [{
				layout : 'fit',
				items :[contentSet] 
			}],
			// 定义按钮
			buttons : [{
				text : '<fmt:message key="button.save" />',
				iconCls : 'button-save',
				tabIndex : this.tabIndex++,
				formBind : true,
				scope : this,
				handler : this.doSave
			}, {
				text : '<fmt:message key="button.cancel" />',
				iconCls : 'button-cancel',
				tabIndex : this.tabIndex++,
				handler : this.doCancel
			}]
		});
	},
	//保存
	doSave : function(){
		//存放业务影响内容数组
		var arrayContent = [] ;
		arrayContent.push(Ext.getCmp('impact_conf_content_win_create').getValue());
		for(var t=1000 ; t<=deleteButtonNum ; t++){
			if(Ext.getCmp('impact_conf_content_win_create'+t)){
				var addcontent = Ext.getCmp('impact_conf_content_win_create'+t).getValue();
				arrayContent.push(addcontent);
			}
		}
		Ext.Msg.show({
			title : '<fmt:message key="message.title" />',
			msg : '确认保存？',
			buttons : Ext.MessageBox.OKCANCEL,
			icon : Ext.MessageBox.QUESTION,
			minWidth : 200,
			scope : this,
			fn : function(buttonId) {
				if (buttonId == 'ok') {
					app.mask.show();
					Ext.Ajax.request({
						url : '${ctx}/${appPath}/ToolBoxAlarmController/saveImpactConf',
						scope : this,
						params : {
							appsys_code : decodeURIComponent('${param.appsys_code}'),
							business_impact_type : decodeURIComponent('${param.business_impact_type}'),
							business_impact_level : decodeURIComponent('${param.business_impact_level}'),
							business_impact_contents : arrayContent
						},
						success : function(response, options) {
							app.mask.hide();
							if (Ext.decode(response.responseText).success == false) {
								var error = Ext.decode(response.responseText).error;
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.ERROR
								});
							} else if (Ext.decode(response.responseText).success == true) {
								Ext.Msg.show( {
									title : '<fmt:message key="message.title" />',
									msg : '<fmt:message key="message.save.successful" />',
									minWidth : 200,
									buttons : Ext.MessageBox.OK,
									icon : Ext.MessageBox.INFO,
									fn : function(){
										//关闭窗口
										app.closeWindow();
										//父页面重新加载数据
										var impactConfInfoTree = Ext.getCmp('impactConfInfoTree');
										Ext.apply(impactConfInfoTree.loader.baseParams, Ext.getCmp('impactConfFindFormPanel').getForm().getValues());
										impactConfInfoTree.getRootNode().reload();
										impactConfInfoTree.expandAll();
									}
								});
							}
						},
						failure : function() {
							app.mask.hide();
							Ext.Msg.show( {
								title : '<fmt:message key="message.title" />',
								msg : '<fmt:message key="message.save.failed" />',
								minWidth : 200,
								buttons : Ext.MessageBox.OK,
								icon : Ext.MessageBox.ERROR
							});
						}
					});
					
				}
			}
		});
	},
	//取消
	doCancel : function(){
		app.closeWindow();
	}
});

</script>

<script type="text/javascript">
app.window.get(0).add(new ImpactConfCreateForm());
app.window.get(0).doLayout();
</script>
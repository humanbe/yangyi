<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<script type="text/javascript">

//系统上线环境配置
OnlineEnvConfForm = Ext.extend(Ext.FormPanel, {
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
		
		csm = new Ext.grid.CheckboxSelectionModel();
		// 实例化数据列表数据源
		this.gridStore = new Ext.data.JsonStore({
			autoDestroy : true,
			proxy : new Ext.data.HttpProxy({
				method : 'GET',
				url : '${ctx}/${frameworkPath}/item/SYSTEM_ENVIRONMENT/sub',
				disableCaching : false
			}),
			autoDestroy : true,
			root : 'data',
			fields : [ 'value', 'name' ]
		}); 
		// 默认选中数据
		/* this.gridStore.on('load', function(store) {
			var records = store.query('checked', true).getRange();
			cmnenveditParamGrid.getSelectionModel().selectRecords(records, false);
		}, this, {
			delay : 100
		}); */
		this.gridStore.load();

		// 实例化数据列表组件
		this.grid = new Ext.grid.GridPanel( {
			id : 'onlineEnvListGridPanel',
			region : 'center',
			hight : 600,
			border : false,
			loadMask : true,
			columnLines : true,
			store : this.gridStore,
			sm : csm,
			// 列定义
			columns : [ new Ext.grid.RowNumberer(),csm,{
				header : '环境编号',
				dataIndex : 'value',
				hidden : true
		    },{
				header : '环境名称',
				width : 500,
				dataIndex : 'name'
		    }],
		    tbar : new Ext.Toolbar( {
				items : [ '-',{
					iconCls : 'button-save',
					text : '<fmt:message key="button.save" />',
					scope : this,
					handler : this.doSave
				},'-']
			}) 
		});
		
		// 设置基类属性
		OnlineEnvConfForm.superclass.constructor.call(this, {
			title : '系统上线环境配置',
			layout : 'border',
			border : false,
			items : [ this.grid ]
		});
	},
	//保存
	doSave : function(){
		if (this.grid.getSelectionModel().getCount() > 0) {
			var envCheckedRecords = this.grid.getSelectionModel().getSelections();
			var onlineEnvs = new Array();
			for ( var i = 0; i < envCheckedRecords.length; i++) {
				onlineEnvs[i] = envCheckedRecords[i].get('value');
			}
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.confirm.to.flag" />',
				buttons : Ext.MessageBox.OKCANCEL,
				icon : Ext.MessageBox.QUESTION,
				minWidth : 200,
				scope : this,
				fn : function(btn) {
					if(btn == 'ok'){
						app.mask.show();
						Ext.Ajax.request({
							url : '${ctx}/${managePath}/appInfo/aopflag',
							timeout:300000,
							method : 'POST',
							scope : this,
							success : this.FlagSuccess,
							disableCaching : true,
							params : {
								appsyscd : decodeURIComponent('${param.appsyscd}'),
								onlineEnvs : onlineEnvs
							}
						});
					}
				} 
			});
		}else {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.select.one.at.least" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	},
	
	// 上线成功
	FlagSuccess : function(response, options) {
		app.mask.hide();
		if (Ext.decode(response.responseText).success == false) {
			var error = Ext.decode(response.responseText).error;
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.Flag.failed" /><fmt:message key="error.code" />:' + error,
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
				
			});
		} else if (Ext.decode(response.responseText).success == true) {
			Ext.Msg.show( {
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.Flag.successful" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.INFO,
				fn:function(btn){
					if(btn =='ok'){
						app.window.close();
						Ext.getCmp('appInfoListGridPanel').getStore().load();
					}
				}
			});
		}
	}
});

app.window.get(0).add(new OnlineEnvConfForm());
app.window.get(0).doLayout();
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	//定义岗位角色列表
	PositionRoleList = Ext.extend(Ext.grid.GridPanel, {
		gridStore : null,// 数据列表数据源
		csm : null,// 数据列表选择框组件
		constructor : function(cfg) {// 构造方法
			Ext.apply(this, cfg);

			// 实例化数据列表选择框组件
			this.csm = new Ext.grid.CheckboxSelectionModel();

			// 实例化数据列表数据源
			this.gridStore = new Ext.data.JsonStore({
				proxy : new Ext.data.HttpProxy({
					method : 'GET',
					url : '${ctx}/${frameworkPath}/position/${param.positionId}/role',
					disableCaching : false
				}),
				autoDestroy : true,
				root : 'data',
				fields : [ 'id', 'name', 'checked' ]
			});

			// 默认选中数据
			this.gridStore.on('load', function(store) {
				var records = store.query('checked', true).getRange();
				this.getSelectionModel().selectRecords(records, false);
			}, this, {
				delay : 300
			});

			// 设置基类属性
			PositionRoleList.superclass.constructor.call(this, {
				border : false,
				loadMask : true,
				title : '<fmt:message key="title.list" />',
				columnLines : true,
				viewConfig : {
					forceFit : true
				},
				store : this.gridStore,
				sm : this.csm,
				autoExpandColumn : 'name',
				columns : [ new Ext.grid.RowNumberer(), this.csm, {
					header : '<fmt:message key="role.id" />',
					dataIndex : 'id',
					hidden : true
				}, {
					id : 'name',
					header : '<fmt:message key="role.name" />',
					dataIndex : 'name',
					sortable : true
				} ],
				tbar : new Ext.Toolbar({
					items : [ '-', {
						text : '<fmt:message key="button.save" />',
						iconCls : 'button-save',
						scope : this,
						handler : this.doSave
					}, '-' ]
				})
			});

			// 加载列表数据
			this.gridStore.load();
		},
		doSave : function() {
			app.mask.show();
			var records = this.getSelectionModel().getSelections();
			var ids = new Array();
			for ( var i = 0; i < records.length; i++) {
				ids[i] = records[i].get("id");
			}

			Ext.Ajax.request({
				url : '${ctx}/${frameworkPath}/position/${param.positionId}/role',
				method : 'POST',
				nocache : true,
				scope : this,
				success : this.saveSuccess,
				failure : this.saveFailure,
				params : {
					ids : ids
				}
			});
		},
		// 保存成功回调
		saveSuccess : function(response, options) {
			app.mask.hide();
			if (Ext.decode(response.responseText).success == false) {
				var error = Ext.decode(response.responseText).error;
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:' + error,
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.ERROR
				});
			} else if (Ext.decode(response.responseText).success == true) {
				Ext.Msg.show({
					title : '<fmt:message key="message.title" />',
					msg : '<fmt:message key="message.save.successful" />',
					minWidth : 200,
					buttons : Ext.MessageBox.OK,
					icon : Ext.MessageBox.INFO
				});
			}
		},
		// 保存失败回调
		saveFailure : function() {
			app.mask.hide();
			Ext.Msg.show({
				title : '<fmt:message key="message.title" />',
				msg : '<fmt:message key="message.save.failed" />',
				minWidth : 200,
				buttons : Ext.MessageBox.OK,
				icon : Ext.MessageBox.ERROR
			});
		}
	});

	app.window.get(0).add(new PositionRoleList());
	app.window.get(0).doLayout();
</script>

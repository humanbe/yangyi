<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">
	AgentApplyForm = Ext.extend(
					Ext.FormPanel,
					{
						row : 0,// Tab键顺序

						constructor : function(cfg) {
							Ext.apply(this, cfg);
							// 设置基类属性
							AgentApplyForm.superclass.constructor.call(
											this,
											{

												buttonAlign : 'center',
												labelAlign : 'right',
												frame : true,
												monitorValid : true,
												url : '${ctx}/${managePath}/serverssynchronous/agentApply',
												
												defaults : {
													anchor : '90%'
												},
												items : [ {
													xtype : 'textarea',
													fieldLabel : '申请原因',
													id : 'descId',
													name : 'applyDesc',
													height : 205,
													maxLength : 500,
													tabIndex : this.tabIndex++,
													allowBlank : false

												},{
													xtype : 'textfield',
													id : 'serverId',
													hiddenName : 'Value',
													name : 'Value',
													tabIndex : this.tabIndex++,
													hidden : true
												},{
													xtype : 'textfield',
													id : 'valueId',
													hiddenName : 'descValue',
													name : 'descValue',
													tabIndex : this.tabIndex++,
													hidden : true
												} ],
												buttons : [ {
													text : '<fmt:message key="button.submit" />',
													iconCls : 'button-ok',
													tabIndex : this.tabIndex++,
													formBind : true,
													scope : this,
													handler : this.doSubmit
												} ]
											});
						},
						// 保存操作
						doSubmit : function() {
							var desc=Ext.getCmp('descId').getValue();
							Ext.getCmp('valueId').setValue(Ext.util.JSON.encode(desc));
							var servers=${param.data};
							Ext.getCmp('serverId').setValue(Ext.util.JSON.encode(servers));
							 this.getForm().submit(
											{
												scope : this,
												success : this.saveSuccess,
												failure : this.saveFailure,
												waitTitle : '<fmt:message key="message.wait" />',
												waitMsg : '<fmt:message key="message.saving" />'
											}); 
						},
						//保存成功回调
						saveSuccess : function(form, action) {
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.successful" />',
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.INFO,
										minWidth : 200,
										fn : function() {
											app.closeWindow();
										}
									});
						},
						// 保存失败回调
						saveFailure : function(form, action) {
							var error = decodeURIComponent(action.result.error);
							Ext.Msg.show({
										title : '<fmt:message key="message.title" />',
										msg : '<fmt:message key="message.save.failed" /><fmt:message key="error.code" />:'
												+ error,
										buttons : Ext.MessageBox.OK,
										icon : Ext.MessageBox.ERROR
									});
						}
					});
	app.window.get(0).add(new AgentApplyForm());
	app.window.get(0).doLayout();
</script>
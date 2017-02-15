<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<script type="text/javascript">

var systemcode = '${param.systemcode}';

//定义新建表单
AppInfoViewForm = Ext.extend(Ext.FormPanel, {
	tabIndex : 0,// Tab键顺序
	constructor : function(cfg) {// 构造方法		Ext.apply(this, cfg);
	
		// 设置基类属性		AppInfoViewForm.superclass.constructor.call(this, {
			title : '<fmt:message key="title.form" />',
			labelAlign : 'right',
			labelWidth : 120 ,
			buttonAlign : 'center',
			frame : true,
			autoScroll : true,
			url : '${ctx}/${managePath}/appInfo/view',
			//bodyStyle : 'padding-left:100px;padding-bottom:0px;padding-top:50px;padding-right:0px;',
			defaults : {
				anchor : '100%',
				msgTarget : 'side'
			}, 
			monitorValid : true,
			// 定义表单组件
			layout:'column',
			items:[{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '系统编号',
	    					name : 'systemcode',
	    					disabled : true
                    	}]
    				},{
    					columnWidth:.5,
    					layout: 'form',
    					defaults: {anchor : '100%'},
    					items : [{
    						xtype : 'textfield',
	    					fieldLabel : '系统名称',
	    					name : 'systemname',
	    					disabled : true
    					}]
    				}]
                }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : 'EAPS系统名称',
	    					name : 'eapssystemname',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '英文简称',
   	    					name : 'englishcode',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '受影响系统',
	    					name : 'affectsystem',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '所属分行',
   	    					name : 'branch',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '关键度',
	    					name : 'key',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '状态',
   	    					name : 'status',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '安全定级',
	    					name : 'securitylevel',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '使用范围',
   	    					name : 'scope',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '系统上线时间',
	    					name : 'onlinedate',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '系统下线时间',
   	    					name : 'outlinedate',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '服务级别',
	    					name : 'serverlevel',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '系统级别',
   	    					name : 'systemlevel',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '是否重要系统',
	    					name : 'isimportant',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '对外关键系统',
   	    					name : 'iskey',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '是否核心重要系统',
	    					name : 'iscoresyetem',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '银监会报送重要系统',
   	    					name : 'cbrcimportantsystem',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '是否应用接管',
	    					name : 'applicateoperate',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '应用外包参与标志',
   	    					name : 'outsourcingmark',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '所属网络域',
	    					name : 'networkdomain',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '应用团队组别',
   	    					name : 'team',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '运维经理',
	    					name : 'operatemanager',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '系统RPO',
   	    					name : 'systempro',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '应用管理员A',
	    					name : 'applicatemanagerA',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '应用管理员B',
   	    					name : 'applicatemanagerB',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '系统管理员A',
	    					name : 'systemmanagerA',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '系统管理员B',
   	    					name : 'systemmanagerB',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '网络管理员A',
	    					name : 'networkmanagerA',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '网络管理员B',
   	    					name : 'networkmanagerB',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : 'DBA管理员',
	    					name : 'DBA',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '中间件管理员',
   	    					name : 'middlewaremanager',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '存储管理员',
	    					name : 'storemanager',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '项目负责人',
   	    					name : 'PM',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '业务主管部门',
	    					name : 'businessdepartment',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '业务负责人',
   	    					name : 'businessmanager',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '服务支持人',
	    					name : 'servicesupporter',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '是否测试中心接管',
   	    					name : 'istestcenter',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '分配测试经理',
	    					name : 'allottestmanager',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '交付测试经理',
   	    					name : 'deliverytestmanager',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '质量经理',
	    					name : 'qualitymanager',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '性能测试经理',
   	    					name : 'performancetestmanag',
	    					disabled : true
       					}]
       				}]
               }]
            },{
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
                    labelWidth : 120 ,
                    labelAlign : 'right',
                    items: [{
                    	columnWidth:.5,
                    	layout: 'form',
                    	defaults: {anchor : '100%'},
                    	items : [{
	    					xtype : 'textfield',
	    					fieldLabel : '功能表转化系数',
	    					name : 'transfercoefficient',
	    					disabled : true
                    	}]
       				},{
       					columnWidth:.5,
       					layout: 'form',
       					defaults: {anchor : '100%'},
       					items : [{
       						xtype : 'textfield',
   	    					fieldLabel : '所处阶段',
   	    					name : 'stage',
	    					disabled : true
       					}]
       				}]
               }]
            },{
            	 columnWidth:.96,
                 layout: 'form',
                 defaults: {anchor : '100%'},
                 border:false,
                 labelAlign : 'right',
                 items: [{	
                	xtype : 'textarea',
					height : 60,
					fieldLabel : '业务功能介绍',
					name : 'businessintroduction',
					disabled : true
				}]
            }],
			// 定义按钮grid
			buttons : [ {
				text : '<fmt:message key="button.close" />',
				iconCls : 'button-close',
				tabIndex : this.tabIndex++,
				scope : this,
				handler : this.doClose
			}]
		});
		// 加载表单数据
		this.load( {
			url : '${ctx}/${managePath}/appInfo/view/'+systemcode,
			method : 'GET'
		});
	},
	//关闭操作
	doClose : function() {
		app.closeTab('APP_INFO_VIEW');
	}
});

// 实例化新建表单,并加入到Tab页中
Ext.getCmp("APP_INFO_VIEW").add(new AppInfoViewForm());
// 刷新Tab页布局
Ext.getCmp("APP_INFO_VIEW").doLayout();
</script>
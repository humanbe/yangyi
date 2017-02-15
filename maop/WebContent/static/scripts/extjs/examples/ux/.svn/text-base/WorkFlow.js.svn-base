 
Ext.ux.WorkFlow = Ext.extend(Ext.FlashComponent, {
	
	
	wmode: 'Opaque', // window  transparent  Opaque
	expressInstall: undefined,
	
    initComponent : function(){
		Ext.ux.WorkFlow.superclass.initComponent.call(this);
	
		if(!this.url){
            this.url = Ext.ux.WorkFlow.URL;
        }
		if(!this.expressInstall){
            this.expressInstall = Ext.ux.WorkFlow.INSTALL_URL;
        }
        this.addEvents(
            'beforerefresh',
            'refresh'
        );
    },

    onRender : function(){
    	Ext.ux.WorkFlow.superclass.onRender.apply(this, arguments);

        var params = Ext.apply({
        	allowFullScreen: true,
            allowScriptAccess: 'always',
            bgcolor: this.backgroundColor,
            wmode: this.wmode
        }, this.flashParams), vars = Ext.apply({
            allowedDomain: document.location.hostname
        }, this.flashVars);

        new swfobject.embedSWF(this.url, this.id, this.swfWidth, this.swfHeight, this.flashVersion,
            this.expressInstall, vars, params);

        this.swf = Ext.getDom(this.id);
        this.el = Ext.get(this.swf);
    },
    
    delayRefresh : function(){
        if(!this.refreshTask){
            this.refreshTask = new Ext.util.DelayedTask(this.refresh, this);
        }
        this.refreshTask.delay(this.refreshBuffer);
    },

    refresh : function(){
        if(this.fireEvent('beforerefresh', this) !== false){
            this.fireEvent('refresh', this);
        }
    },
    itemclick : function(){
    	
    },

    
    getFunctionRef : function(val){
        if(Ext.isFunction(val)){
            return {
                fn: val,
                scope: this
            };
        }else{
            return {
                fn: val.fn,
                scope: val.scope || this
            };
        }
    },

    onDestroy: function(){
        if (this.refreshTask && this.refreshTask.cancel){
            this.refreshTask.cancel();
        }
        Ext.ux.WorkFlow.superclass.onDestroy.call(this);

    }

});

Ext.ux.WorkFlow.URL = "";
Ext.ux.WorkFlow.INSTALL_URL = "";
Ext.reg('workflow', Ext.ux.WorkFlow);

var HTMLEditor = Ext.extend(Ext.form.HtmlEditor, {
addImage : function() {
   var editor = this;
   var imgform = new Ext.FormPanel({
    region : 'center',
    labelWidth : 55,
    frame : true,
    bodyStyle : 'padding:5px 5px 0',
    autoScroll : true,
    border : false,
    fileUpload : true,
    items : [{
       xtype : 'textfield',
       fieldLabel : '选择文件',
       name : 'userfile',
       id : 'userfile',
       inputType : 'file',
       allowBlank : false,
       blankText : '文件不能为空',
       height : 25,
       anchor : '98%'
      }],
    buttons : [{
     text : '上传',
     type : 'submit',
     handler : function() {
      var furl="";
      alert(imgform.form.findField('userfile').getValue())
      alert( 'flash/Test/addFileInNews')
      furl=imgform.form.findField('userfile').getValue();
      var type=furl.substring(furl.length-3).toLowerCase();
      var filename=furl.substring(furl.lastIndexOf("\\")+1);
      if (furl==""||furl==null) {return;}
      if(type!='jpg'&&type!='bmp'&&type!='gif'&&type!='png'){
       alert('仅支持jpg、bmp、gif、png格式的图片');
       return;
      }
      imgform.form.submit({
       url : 'flash/Test/addFileInNews',
       waitMsg : '正在上传......',
       waitTitle : '请等待',
       method : 'POST',
       params :{
    	   
       },
       success : function() {
    	  
        var element = document.createElement("img");
        element.src = "../UploadFile/"+filename;
        element.style.width="300px";
             element.style.height="200px";
        if (Ext.isIE) {
         editor.insertAtCursor(element.outerHTML);
        } else {
         var selection = editor.win.getSelection();
         if (!selection.isCollapsed) {
          selection.deleteFromDocument();
         }
         selection.getRangeAt(0).insertNode(element);
        }
        win.close();
       },
       failure : function(form, action) {
        form.reset();
        if (action.failureType == Ext.form.Action.SERVER_INVALID)
         Ext.MessageBox.alert('警告',
           '上传失败，仅支持jpg、bmp、gif、png格式的图片');
       
       }
      
      });
     }
    }, {
     text : '关闭',
     type : 'submit',
     handler : function() {
      win.close(this);
     }
    }]
   })

   var win = new Ext.Window({
      title : "上传图片",
      id : 'picwin',
      width : 400,
      height : 120,
      modal : true,
      border : false,
      iconCls:'icon-uploadpic',
      layout : "fit",
      items : imgform

     });
   win.show();
  
},//上传图片的扩展
addFile : function() {
   var editor = this;
   var fileform = new Ext.FormPanel({
    region : 'center',
    labelWidth : 55,
    frame : true,
    bodyStyle : 'padding:5px 5px 0',
    autoScroll : true,
    border : false,
    fileUpload : true,
    items : [{
       xtype : 'textfield',
       fieldLabel : '选择文件',
       name : 'userfile_F',
       id : 'userfile_F',
       inputType : 'file',
       allowBlank : false,
       blankText : '文件不能为空',
       height : 25,
       anchor : '98%'
      }],
    buttons : [{
     text : '上传',
     type : 'submit',
     handler : function() {
      var furl="";//文件物理地址
      var fname="";//文件名称
      furl=fileform.form.findField('userfile_F').getValue();
      var type=furl.substring(furl.length-3).toLowerCase();
      if (furl==""||furl==null) {return;}
      if(type!='doc'&&type!='xls'){
       alert('仅支持上传doc、xls格式的文件!');
       return;
      }
      fname=furl.substring(furl.lastIndexOf("\\")+1);
      fileform.form.submit({
       url : '/newsinfo.mvc/AddFiles_newsinfo',
       waitMsg : '正在上传......',
       waitTitle : '请等待',
       method : 'POST',
       success : function() {
        var element = document.createElement("a");
        element.href = "../UploadFile/"+fname;
        element.target = '_blank';
        element.innerHTML = fname;
        if (Ext.isIE) {
         editor.insertAtCursor(element.outerHTML);
        } else {
         var selection = editor.win.getSelection();
         if (!selection.isCollapsed) {
          selection.deleteFromDocument();
         }
         selection.getRangeAt(0).insertNode(element);
        }
        winFile.close();
       },
       failure : function() {
        form.reset();
        if (action.failureType == Ext.form.Action.SERVER_INVALID)
         Ext.MessageBox.alert('警告',
           '上传失败，仅支持上传doc、xls格式的文件!');
       
       }
      
      });
     }
    }, {
     text : '关闭',
     type : 'submit',
     handler : function() {
      winFile.close(this);
     }
    }]
   })

   var winFile = new Ext.Window({
      title : "上传附件",
      id : 'picwin',
      width : 400,
      height : 120,
      modal : true,
      border : false,
      layout : "fit",
      iconCls : 'icon-uploadfile',
      items : fileform

     });
   winFile.show();
  
},//上传附件的扩展
addflash : function() {
   var editor = this;
   var flashform = new Ext.FormPanel({
    region : 'center',
    labelWidth : 55,
    frame : true,
    bodyStyle : 'padding:5px 5px 0',
    autoScroll : true,
    border : false,
    items : [{
       xtype : 'textfield',
       fieldLabel : 'flash地址',
       name : 'userflash',
       id : 'userflash',
       allowBlank : false,
       blankText : 'http://',
       emptyText : 'http://',
       height : 25,
       anchor : '98%'
      }],
    buttons : [{
     text : '添加',
     type : 'submit',
     handler : function() {
      var furl="";//文件物理地址
      furl=flashform.form.findField('userflash').getValue();
      var type=furl.substring(furl.length-3).toLowerCase();
      if (furl==""||furl==null) {return;}
      if(type!='swf'&&type!='flv'){
       alert('非法格式，请检查！');
       return;
      }
      var element = document.createElement("embed");
      element.src = furl;
      element.type="application/x-shockwave-flash";
      element.quality="high";
      element.style.width="300px";
      element.style.height="200px";
      if(Ext.isIE) {
       editor.insertAtCursor(element.outerHTML);
      } else {
        var selection = editor.win.getSelection();
        if (!selection.isCollapsed) {
            selection.deleteFromDocument();
        }
        selection.getRangeAt(0).insertNode(element);
      }
      winflash.close();
     }
    }, {
     text : '关闭',
     type : 'submit',
     handler : function() {
      winflash.close(this);
     }
    }]
   })

   var winflash = new Ext.Window({
      title : "插入flash",
      id : 'flashwin',
      width : 400,
      height : 120,
      modal : true,
      border : false,
      layout : "fit",
      iconCls : 'icon-swf',
      items : flashform

     });
   winflash.show();
  
},//插入flash的扩展
addfilm : function() {
   var editor = this;
   var filmform = new Ext.FormPanel({
    region : 'center',
    labelWidth : 70,
    frame : true,
    bodyStyle : 'padding:5px 5px 0',
    autoScroll : true,
    border : false,
    items : [{
       xtype : 'textfield',
       fieldLabel : '多媒体地址',
       name : 'userfilm',
       id : 'userfilm',
       allowBlank : false,
       blankText : 'http://',
       emptyText : 'http://',
       height : 25,
       anchor : '98%'
      }],
    buttons : [{
     text : '添加',
     type : 'submit',
     handler : function() {
      var furl="";//文件物理地址
      var regImg = new RegExp(/\.(mp3|wav|wma|wmv|avi|mpg|asf|rm|rmvb)$/);
      var regrm=new RegExp(/\.(rm|rmvb)$/);
      furl=filmform.form.findField('userfilm').getValue();
      //var type=furl.substring(furl.length-3).toLowerCase();
      if (furl==""||furl==null) {return;}
      if(!furl.match(regImg)){
       alert('非法格式，请检查！系统支持：mp3,wav,wma,wmv,avi,mpg,asf,rm,rmvb');
       return;
      }
      var element = document.createElement("embed");
      element.src = furl;
      element.style.width="300px";
      element.style.height="200px";
      if(furl.match(regrm))
         element.type="audio/x-pn-realaudio-plugin";
      else
         element.type="video/x-ms-asf-plugin";
      element.loop="true";
      element.autostart="true";
      if(Ext.isIE) {
       editor.insertAtCursor(element.outerHTML);
      } else {
        var selection = editor.win.getSelection();
        if (!selection.isCollapsed) {
            selection.deleteFromDocument();
        }
        selection.getRangeAt(0).insertNode(element);
      }
      winfilm.close();
     }
    }, {
     text : '关闭',
     type : 'submit',
     handler : function() {
      winfilm.close(this);
     }
    }]
   })

   var winfilm = new Ext.Window({
      title : "插入多媒体",
      id : 'filmwin',
      width : 410,
      height : 120,
      modal : true,
      border : false,
      layout : "fit",
      iconCls : 'icon-film',
      items : filmform

     });
   winfilm.show();
  
},//插入过媒体的扩展
createToolbar : function(editor) {
   HTMLEditor.superclass.createToolbar.call(this, editor);
   this.tb.insertButton(16, {
     // cls : "button-import",
	   text:'图片',
      iconCls : "button-impage",
      handler : this.addImage,
      tooltip : "添加图片",
      scope : this
     });
   this.tb.insertButton(17, {
     // cls : "button-import",
	   text:'文件',
      iconCls : 'button-word',
      handler : this.addFile,
      tooltip : "添加文件",
      scope : this
     });
    /* this.tb.insertButton(18, {
      cls : "x-btn-icon",
      iconCls : 'icon-swf',
      handler : this.addflash,
      tooltip : "添加flash文件",
      scope : this
     });
     this.tb.insertButton(19, {
      cls : "x-btn-icon",
      iconCls : 'icon-film',
      handler : this.addfilm,
      tooltip : "添加多媒体文件",
      scope : this
     });
  this.tb.insertButton(20, {//插入层的扩展，即插入div
      cls : "x-btn-icon",
      iconCls : 'icon-div',
      handler : function() {
         var element = document.createElement("div");
         element.id="InsertDiv";
         element.style.backgroundColor="#FAFAFB";
         element.style.borderWidth="1px";
         element.style.borderStyle="solid";
         element.style.borderColor="#AECBE7";
         element.innerHTML="在此插入内容：<BR>";
         if(Ext.isIE) {
       editor.insertAtCursor(element.outerHTML);
      } else {
        var selection = editor.win.getSelection();
        if (!selection.isCollapsed) {
            selection.deleteFromDocument();
        }
        selection.getRangeAt(0).insertNode(element);
      }
      },
      tooltip : "添加div层",
      scope : this
     });
     this.tb.insertButton(21, { //插入横线的扩展
      cls : "x-btn-icon",
      iconCls : 'icon-hr',
      handler :function() {
         var element = document.createElement("HR");
         if(Ext.isIE) {
       editor.insertAtCursor(element.outerHTML);
      } else {
        var selection = editor.win.getSelection();
        if (!selection.isCollapsed) {
            selection.deleteFromDocument();
        }
        selection.getRangeAt(0).insertNode(element);
      }
      },
      tooltip : "添加横线",
      scope : this
     });*/
}
});
Ext.reg('CJ_starthtmleditor', HTMLEditor);


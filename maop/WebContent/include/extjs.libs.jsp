<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>

<!-- ExtJS -->
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/resources/css/ext-all.css"></link>
<script src="${ctx}/static/scripts/extjs/adapter/ext/ext-base.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/ext-all.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/src/locale/ext-lang-zh_CN.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<script src="${ctx}/static/scripts/extjs/examples/ux/statusbar/StatusBar.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<link rel="stylesheet" type="text/css" href="${ctx}/static/style/ext.css"></link>
<link rel="stylesheet" type="text/css" href="${ctx}/static/style/menu.css"></link>

<script src="${ctx}/static/scripts/extjs/examples/ux/TreeField.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<script src="${ctx}/static/scripts/extjs/examples/ux/Portal.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/examples/ux/PortalColumn.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/examples/ux/Portlet.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/passwordmeter/style/passwordmeter.css"></link>
<script src="${ctx}/static/scripts/extjs/examples/ux/passwordmeter/PasswordMeter.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<script src="${ctx}/static/scripts/extjs/examples/ux/WorkFlow.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/examples/ux/RowExpander.js" type="text/javascript"><!-- //required for FF3 and Opera --></script>

<link rel="stylesheet" type="text/css" href="${ctx}/static/style/Ext.ux.UploadDialog.css"></link>
<script type="text/javascript" src="${ctx}/static/scripts/uploaddialog/Ext.ux.UploadDialog.js"><!-- //required for FF3 and Opera --></script>
<script type="text/javascript" src="${ctx}/static/scripts/uploaddialog/locale/zh_CN.js"><!--// required for FF3 and Opera --></script>

<link rel="stylesheet" type="text/css" href="${ctx}/static/style/Spinner.css" />
<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/Spinner.js"><!-- //required for FF3 and Opera --></script>
<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/SpinnerField.js"><!--// required for FF3 and Opera --></script>

<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/RowEditor.js"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/style/RowEditor.css" />

<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/fileuploadfield/FileUploadField.js"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/style/fileuploadfield.css" />

<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/ItemSelector.js"><!--// required for FF3 and Opera --></script>
<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/MultiSelect.js"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/style/MultiSelect.css" />
<!-- 分组grid表头 扩展 -->
<script type="text/javascript" src="${ctx}/static/scripts/extjs/examples/ux/ColumnHeaderGroup.js"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/css/ColumnHeaderGroup.css" />

<!-- Ext.Ajax.request同步请求 只能放到此处，此jsp文件在index.jsp页面加载，因为若放到某个指定JSP页面开头，由于加载js需要时间的问题，使第一次打开指定页面时发生未加载完成js即发起request请求，则无法实现同步效果-->
<script type="text/javascript" src="${ctx}/static/scripts/extjs/ext-basex.js"></script>
<!-- 日期时间 扩展 -->
<script src="${ctx}/static/scripts/extjs/examples/ux/MonthPickerPlugin.js" type="text/javascript"><!--// required for FF3 and Opera --></script>
<script src="${ctx}/static/scripts/extjs/examples/ux/DateTimeField.js" type="text/javascript"><!--// required for FF3 and Opera --></script>

<!-- TreeGrid 扩展 -->
<script src="${ctx}/static/scripts/extjs/examples/ux/TreeGrid/TreeGrid.js" type="text/javascript"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/TreeGrid/css/TreeGrid.css" />
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/TreeGrid/css/TreeGridLevels.css" />

<!-- textfield maxLength属性支持对中文2位的计算 -->
<script src="${ctx}/static/scripts/extjs/examples/ux/TextFieldExtend.js" type="text/javascript"><!--// required for FF3 and Opera --></script>

<!-- LockingGridView 扩展(锁定指定列) -->
<script src="${ctx}/static/scripts/extjs/examples/ux/LockingGridView.js" type="text/javascript"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/css/LockingGridView.css" />

<!-- BufferView grid扩展(通过缓存延迟加载grid数据，解决页面显示多数据时分段从缓存取出，提高性能) -->
<script src="${ctx}/static/scripts/extjs/examples/ux/BufferView.js" type="text/javascript"><!--// required for FF3 and Opera --></script>

<!-- lovcombo grid扩展(多选下拉框) -->
<script src="${ctx}/static/scripts/extjs/examples/ux/lovcombo/Ext.ux.form.LovCombo.js" type="text/javascript"><!--// required for FF3 and Opera --></script>
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/css/Ext.ux.form.LovCombo.css" />


<!-- htmleditor扩展(上传文件) -->
<link rel="stylesheet" type="text/css" href="${ctx}/static/scripts/extjs/examples/ux/css/CJ_StarHtmlEditor.css" />


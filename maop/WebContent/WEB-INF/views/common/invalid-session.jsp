<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><fmt:message key="title.session.timeout" /></title>
</head>
<body>
<script type="text/javascript">
if (typeof Ext == 'undefined') {
	if (confirm('<fmt:message key="error.session.invalidate" />.<fmt:message key="button.relogin" />?')) {
		window.location.href = '${ctx}/login';
	} else {
		window.location.href = '${ctx}/logout';
	}
}
</script>

</body>
</html>

<%
    /* Copyright 2001-2003 Amarsoft, Inc. All Rights Reserved.
    * This software is the proprietary information of Amarsoft, Inc.
    * Use is subject to license terms.
    * Author: donghui 2014-2-26
    * Tester:
    *
    * Content: F5调用MAOP系统验证页面
    * Input Param:
    * Output param:
    *
    * History Log: 
    *      
    */
%>
<%@ page contentType="text/html; charset=GBK" %>
<%@ page language="java"
         errorPage="/not-found.jsp"
        %>
<%
   String sMaopflag="MAOPOK";
   request.setAttribute("MAOPFLAG",sMaopflag);
%>
<html>
<head>
</head>
<body >
<table border="0" width="100%" height="100%" cellspacing="0" cellpadding="0">
        <td><tr><font color=red><%=sMaopflag%></font></tr></td>
</table>
</body>
</html>
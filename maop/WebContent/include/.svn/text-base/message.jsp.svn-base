<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/include/taglibs.jsp"%>
<c:if test="${(!empty param.opt) && (!empty param.success)}">
	<div class="grid-message">
		<table>
			<tr>
				<c:choose>
					<c:when test="${param.success eq true}">
						<td>
							<img src="${ctx}/static/style/images/message/info.png">
						</td>
						<c:choose>
							<c:when test="${param.opt eq 'delete'}">
								<td>
									<fmt:message key="message.delete.successful" />
								</td>
							</c:when>
						</c:choose>
					</c:when>
					<c:otherwise>
						<td>
							<img src="${ctx}/static/style/images/message/error.png">
						</td>
						<c:choose>
							<c:when test="${param.opt eq 'delete'}">
								<td>
									<fmt:message key="message.delete.failed" />
								</td>
							</c:when>
						</c:choose>
						<c:choose>
							<c:when test="${param.opt eq 'create'}">
								<td>
									<fmt:message key="message.save.failed" />
								</td>
							</c:when>
						</c:choose>
					</c:otherwise>
				</c:choose>
			</tr>
		</table>
	</div>
</c:if>
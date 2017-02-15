package com.nantian.jeda.security.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.web.util.AntUrlPathMatcher;
import org.springframework.security.web.util.JedaIpAddressMatcher;
import org.springframework.security.web.util.UrlMatcher;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.nantian.common.util.CommonConst;
import com.nantian.component.log.Logger;
import com.nantian.jeda.common.model.Function;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.util.SecurityUtils;

public class TrailingSlashInterceptor extends HandlerInterceptorAdapter {

//	private static Logger logger = LoggerFactory
//			.getLogger(TrailingSlashInterceptor.class);
	/** 日志输出 */
	private static Logger logger = Logger.getLogger(TrailingSlashInterceptor.class);
	
	private UrlMatcher urlMatcher = new AntUrlPathMatcher();
	
	@Autowired
	private SecurityUtils securityUtils;

	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {

		HttpServletResponse httpResponse = (HttpServletResponse) response;

		String requestUri = request.getRequestURI();
		if (logger.isDebugEnable()) {
			logger.log("Common0002","request={" + requestUri + "}");
			logger.log("Common0002","contextRoot={" + request.getContextPath() + "}");
		}

		if (requestUri.endsWith("/")) {
			return true;
		} else if (requestUri.endsWith(request.getContextPath())) {
			response.setStatus(301);
			String redirectUrl = requestUri + "/";
			httpResponse.setHeader("Location", redirectUrl);
			httpResponse.setHeader("Connection", "close");
			logger.log("Common0001", "redirect to: {}" + redirectUrl);
			return false;
		} else if (requestUri.endsWith("login") || 
					requestUri.endsWith("logout") ||
					requestUri.endsWith("access-denied") || 
					requestUri.endsWith("header") || 
					requestUri.endsWith("internal-server-error") || 
					requestUri.endsWith("invalid-session") || 
					requestUri.endsWith("not-found")){
			//域安全控制，过滤此类请求URL
			return true;
		} else if(requestUri.endsWith(".gif") || 
					requestUri.endsWith(".png") || 
					requestUri.endsWith(".bmp") || 
					requestUri.endsWith(".css") || 
					requestUri.endsWith(".js")){
			//域安全控制，过滤此类请求URL
			return true;
		} else{
			String functionUrl = null;
			if(null != securityUtils && null != securityUtils.getUser() && null != securityUtils.getUser().getRoles()){
				for (Role role : securityUtils.getUser().getRoles()) {
					for (Function function : role.getFunctions()) {
						functionUrl = request.getContextPath() + function.getUrl();
						if(urlMatcher.pathMatchesUrl(functionUrl, requestUri)){
							if (logger.isDebugEnable()) {
								logger.log("Common0002","functionId=" + function.getId());
								logger.log("Common0002","functionName=" + function.getName());
								logger.log("Common0002","requestUri=" + requestUri);
							}
							if(StringUtils.isNotEmpty(function.getAccessDomainIp()) && StringUtils.isNotBlank(function.getAccessDomainIp())){
								for (String domainIp : function.getAccessDomainIp().split(CommonConst.STRING_COMMA)) {
									//if(new IpAddressMatcher(domainIp).matches(request)){
									if(new JedaIpAddressMatcher(domainIp).matches(request)){
										//域IP访问被接受
										return true;
									}
								}
								//域IP访问被拒绝
								response.setStatus(4031);
								return false;
							}
						}
					}
				}
			}
			//无域安全访问控制
			return true;
		}
	}
}

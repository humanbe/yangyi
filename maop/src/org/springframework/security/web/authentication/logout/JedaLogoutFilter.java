/* Copyright 2004, 2005, 2006 Acegi Technology Pty Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.security.web.authentication.logout;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.util.UrlUtils;
import org.springframework.util.Assert;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.GenericFilterBean;

import com.nantian.common.util.MyApplicationContextUtil;
import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.security.util.ItemProvider;

/**
 * Logs a principal out.
 * <p>
 * Polls a series of {@link LogoutHandler}s. The handlers should be specified in the order they are required.
 * Generally you will want to call logout handlers <code>TokenBasedRememberMeServices</code> and
 * <code>SecurityContextLogoutHandler</code> (in that order).
 * <p>
 * After logout, a redirect will be performed to the URL determined by either the configured
 * <tt>LogoutSuccessHandler</tt> or the <tt>logoutSuccessUrl</tt>, depending on which constructor was used.
 *
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 */
public class JedaLogoutFilter extends GenericFilterBean {

    //~ Instance fields ================================================================================================

    private String filterProcessesUrl = "/j_spring_security_logout";
    private List<LogoutHandler> handlers;
    private LogoutSuccessHandler logoutSuccessHandler;
    
    private String localLogoutSuccessUrl = null;//add by dh 20140414
    
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages; //add by dh 20140414
	
	@Autowired
	private ItemProvider itemProvider; //add by dh 20141010

    //~ Constructors ===================================================================================================

    /**
     * Constructor which takes a <tt>LogoutSuccessHandler</tt> instance to determine the target destination
     * after logging out. The list of <tt>LogoutHandler</tt>s are intended to perform the actual logout functionality
     * (such as clearing the security context, invalidating the session, etc.).
     */
    public JedaLogoutFilter(LogoutSuccessHandler logoutSuccessHandler, LogoutHandler... handlers) {
        Assert.notEmpty(handlers, "LogoutHandlers are required");
        this.handlers = Arrays.asList(handlers);
        Assert.notNull(logoutSuccessHandler, "logoutSuccessHandler cannot be null");
        this.logoutSuccessHandler = logoutSuccessHandler;
    }

    public JedaLogoutFilter(String logoutSuccessUrl, LogoutHandler... handlers) {
    	
		// add by donghui start 20141010
    	if(null == itemProvider){
    		itemProvider = (ItemProvider)MyApplicationContextUtil.springContext.getBean("itemProvider");
    	}
		List<SubItem> subItemList = itemProvider.getSubItemEntity("CAS_SERVER");
		for (SubItem subItem : subItemList) {
			if("IP".equalsIgnoreCase(subItem.getName().trim())) {
				logoutSuccessUrl = subItem.getValue() + "/logout";
			}
		}
		// add by donghui end 20141010
		
        Assert.notEmpty(handlers, "LogoutHandlers are required");
        this.handlers = Arrays.asList(handlers);
        Assert.isTrue(!StringUtils.hasLength(logoutSuccessUrl) ||
                UrlUtils.isValidRedirectUrl(logoutSuccessUrl), logoutSuccessUrl + " isn't a valid redirect URL");
        SimpleUrlLogoutSuccessHandler urlLogoutSuccessHandler = new SimpleUrlLogoutSuccessHandler();
        if (StringUtils.hasText(logoutSuccessUrl)) {
            urlLogoutSuccessHandler.setDefaultTargetUrl(logoutSuccessUrl);
            localLogoutSuccessUrl = logoutSuccessUrl;
        }
        logoutSuccessHandler = urlLogoutSuccessHandler;
    }

    //~ Methods ========================================================================================================

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        //add by dh start 20140414
        Object brpmLoginFlag = null;
        HttpSession session = request.getSession(false);
        if (session != null) {
        	brpmLoginFlag = session.getAttribute("brpmLoginFlag");
        }
        //add by dh end 20140414
        
        if (requiresLogout(request, response)) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();

            if (logger.isDebugEnabled()) {
                logger.debug("Logging out user '" + auth + "' and transferring to logout destination");
            }

            for (LogoutHandler handler : handlers) {
                handler.logout(request, response, auth);
            }
            
            // add by donghui start 20141010
        	if(null == itemProvider){
        		itemProvider = (ItemProvider)MyApplicationContextUtil.springContext.getBean("itemProvider");
        	}
    		List<SubItem> subItemList = itemProvider.getSubItemEntity("CAS_SERVER");
    		for (SubItem subItem : subItemList) {
    			if("IP".equalsIgnoreCase(subItem.getName().trim())) {
    				localLogoutSuccessUrl = subItem.getValue() + "/logout";
    			}
    		}
    		// add by donghui end 20141010
            
            //add by dh start 20140414
            if(null != brpmLoginFlag){
            	((SimpleUrlLogoutSuccessHandler)logoutSuccessHandler).setDefaultTargetUrl(localLogoutSuccessUrl + "?service=" + messages.getMessage("app.brpmlogout.uri"));
            }else{
            	((SimpleUrlLogoutSuccessHandler)logoutSuccessHandler).setDefaultTargetUrl(localLogoutSuccessUrl);
            }
            //add by dh end 20140414
            
            logoutSuccessHandler.onLogoutSuccess(request, response, auth);

            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Allow subclasses to modify when a logout should take place.
     *
     * @param request the request
     * @param response the response
     *
     * @return <code>true</code> if logout should occur, <code>false</code> otherwise
     */
    protected boolean requiresLogout(HttpServletRequest request, HttpServletResponse response) {
        String uri = request.getRequestURI();
        int pathParamIndex = uri.indexOf(';');

        if (pathParamIndex > 0) {
            // strip everything from the first semi-colon
            uri = uri.substring(0, pathParamIndex);
        }

        int queryParamIndex = uri.indexOf('?');

        if (queryParamIndex > 0) {
            // strip everything from the first question mark
            uri = uri.substring(0, queryParamIndex);
        }

        if ("".equals(request.getContextPath())) {
            return uri.endsWith(filterProcessesUrl);
        }

        return uri.endsWith(request.getContextPath() + filterProcessesUrl);
    }

    public void setFilterProcessesUrl(String filterProcessesUrl) {
        Assert.isTrue(UrlUtils.isValidRedirectUrl(filterProcessesUrl), filterProcessesUrl + " isn't a valid value for" +
                " 'filterProcessesUrl'");
        this.filterProcessesUrl = filterProcessesUrl;
    }

    protected String getFilterProcessesUrl() {
        return filterProcessesUrl;
    }
}

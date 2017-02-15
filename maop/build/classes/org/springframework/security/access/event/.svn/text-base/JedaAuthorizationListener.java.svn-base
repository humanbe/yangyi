/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package org.springframework.security.access.event;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.context.ApplicationListener;
import org.springframework.security.web.FilterInvocation;
import org.springframework.security.web.authentication.WebAuthenticationDetails;

import com.nantian.jeda.common.model.User;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class JedaAuthorizationListener implements ApplicationListener<AbstractAuthorizationEvent> {

	private static final Log logger = LogFactory.getLog(JedaAuthorizationListener.class);

	/**
	 * @param event
	 * @see org.springframework.context.ApplicationListener#onApplicationEvent(org.springframework.context.ApplicationEvent)
	 */
	@Override
	public void onApplicationEvent(AbstractAuthorizationEvent event) {
		if (event instanceof AuthorizedEvent) {
			String log = "";
			Object user = ((AuthorizedEvent) event).getAuthentication().getPrincipal();
			if (user instanceof User) {
				log += ((User) user).getName();
				log += "|" + ((User) user).getUsername();
			}
			Object details = ((AuthorizedEvent) event).getAuthentication().getDetails();
			if (details instanceof WebAuthenticationDetails) {
				log += "|" + ((WebAuthenticationDetails) details).getRemoteAddress();
			}
			log = "[" + log + "]" + " 访问 ";
			Object source = ((AuthorizedEvent) event).getSource();
			if (source instanceof FilterInvocation) {
				log += ((FilterInvocation) source).getFullRequestUrl();
			}

			logger.info(log);
		}
	}

}

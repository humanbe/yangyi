/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package org.springframework.security.authentication.event;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.context.ApplicationListener;
import org.springframework.security.web.authentication.WebAuthenticationDetails;

import com.nantian.jeda.common.model.User;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class JedaAuthenticationListener implements ApplicationListener<AbstractAuthenticationEvent> {

	private static final Log logger = LogFactory.getLog(JedaAuthenticationListener.class);

	/**
	 * @param event
	 * @see org.springframework.context.ApplicationListener#onApplicationEvent(org.springframework.context.ApplicationEvent)
	 */
	@Override
	public void onApplicationEvent(AbstractAuthenticationEvent event) {
		if (event instanceof InteractiveAuthenticationSuccessEvent) {
			String log = "";
			Object user = event.getAuthentication().getPrincipal();
			if (user instanceof User) {
				log += ((User) user).getName();
				log += "|" + ((User) user).getUsername();
			}
			Object details = event.getAuthentication().getDetails();
			if (details instanceof WebAuthenticationDetails) {
				log += "|" + ((WebAuthenticationDetails) details).getRemoteAddress();
			}
			log = "[" + log + "]" + " 登录. ";
			logger.info(log);

		}

		if (event instanceof JedaLogoutEvent) {
			if (event.getAuthentication() != null) {
				String log = "";
				Object user = event.getAuthentication().getPrincipal();
				if (user instanceof User) {
					log += ((User) user).getName();
					log += "|" + ((User) user).getUsername();
				}
				Object details = event.getAuthentication().getDetails();
				if (details instanceof WebAuthenticationDetails) {
					log += "|" + ((WebAuthenticationDetails) details).getRemoteAddress();
				}
				log = "[" + log + "]" + " 注销.";
				logger.info(log);
			}
		}

	}
}

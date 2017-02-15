/**
 * UserDetailsServiceImpl.java
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package org.springframework.security.core.userdetails;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;

import com.nantian.jeda.common.model.User;
import com.nantian.jeda.security.service.UserService;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class JedaUserDetailsService implements UserDetailsService {

	@Autowired
	private UserService userService;

	@Autowired
	private MessageSourceAccessor messages;

	/**
	 * 
	 * @param username
	 * @return
	 * @throws UsernameNotFoundException
	 * @throws DataAccessException
	 * @see org.springframework.security.core.userdetails.UserDetailsService#loadUserByUsername(java.lang.String)
	 */
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException, DataAccessException {
		User user = userService.loadByUsername(username);
		if (user == null) {
			throw new UsernameNotFoundException(messages.getMessage("user.not.found", new Object[] { username }), username);
		}
		return user;
	}

}

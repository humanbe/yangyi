/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.util;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;

import com.nantian.jeda.common.model.Permission;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.common.model.SecurityEntity;
import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.common.model.User;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Component
public class SecurityUtils {

	/** 日志输出 */
	final static Logger logger = LoggerFactory.getLogger(SecurityUtils.class);

	public final String ORG_ID = "#ORG_ID#";

	public final String ORG_PATH = "#ORG_PATH#";

	public final String USER_NAME = "#USER_NAME#";

	public User getUser() {
		Object obj = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		if (obj instanceof User) {
			return (User) obj;
		} else {
			return new User(obj.toString());
		}
	}

	/**
	 * 返回"用户名|姓名|IP"格式的字符串.
	 * 
	 * @return "用户名|姓名|IP"格式的字符串
	 */
	public String getUserFullName() {
		String str = getUser().getUsername() + "|" + getUser().getName();
		if (SecurityContextHolder.getContext().getAuthentication().getDetails() instanceof WebAuthenticationDetails) {
			str += "|" + ((WebAuthenticationDetails) SecurityContextHolder.getContext().getAuthentication().getDetails()).getRemoteAddress();
		}
		return str;
	}

	public void setCreateEntity(SecurityEntity entity) {
		Date date = new Date();
		entity.setCreated(date);
		entity.setCreator(getUser());
		entity.setModified(date);
		entity.setModifier(getUser());
	}

	public void setModifyEntity(SecurityEntity entity) {
		entity.setModified(new Date());
		entity.setModifier(getUser());
	}

	public Set<Permission> getPermissionByFunction(String function) {
		return getPermissionsByFunctionAndType(function, null);
	}

	public Set<Permission> getPermissionHqlByFunction(String function) {
		String hql = "";
		hql += getUserPermissionHqlByFunction(function) + "";
		hql += getItemPermissionHqlByFunction(function) + "";
		hql += getConstantPermissionHqlByFunction(function);
		return getPermissionsByFunctionAndType(function, null);
	}

	public Set<Permission> getUserPermissionByFunction(String function) {
		return getPermissionsByFunctionAndType(function, Permission.TYPE_USER);
	}

	public String getUserPermissionHqlByFunction(String function) {
		return getPermissionHqlByFunctionAndType(function, Permission.TYPE_USER);
	}

	public Set<Permission> getItemPermissionByFunction(String function) {
		return getPermissionsByFunctionAndType(function, Permission.TYPE_ITEM);
	}

	public String getItemPermissionHqlByFunction(String function) {
		return getPermissionHqlByFunctionAndType(function, Permission.TYPE_ITEM);
	}

	public Set<Permission> getConstantPermissionByFunction(String function) {
		return getPermissionsByFunctionAndType(function, Permission.TYPE_CONSTANT);
	}

	public Set<Permission> getConstantPermissionHqlByFunction(String function) {
		return getPermissionsByFunctionAndType(function, Permission.TYPE_CONSTANT);
	}

	private Set<Permission> getPermissionsByFunctionAndType(String function, String type) {
		Set<Permission> permissions = new HashSet<Permission>();
		for (Role role : getUser().getRoles()) {
			for (Permission permission : role.getPermissions()) {
				if (type == null) {
					permissions.add(permission);
				} else if (permission.getType().equals(type)) {
					permissions.add(permission);
				}
			}
		}
		return permissions;
	}

	private String getPermissionHqlByFunctionAndType(String function, String type) {
		List<String> hqls = new ArrayList<String>();
		for (Permission permission : getPermissionsByFunctionAndType(function, type)) {
			hqls.add(permission.getExpression());
		}
		return StringUtils.join(hqls, " or ");
	}

	public Set<SubItem> getPermissionItemByFunction(String function, String itemId) {
		Set<SubItem> subitems = new HashSet<SubItem>();
		Set<Permission> permissions = getItemPermissionByFunction(function);
		for (Permission permission : permissions) {
			if (permission.getSubitem().getParent().getId().equals(itemId)) {
				subitems.add(permission.getSubitem());
			}
		}
		return subitems;
	}
}

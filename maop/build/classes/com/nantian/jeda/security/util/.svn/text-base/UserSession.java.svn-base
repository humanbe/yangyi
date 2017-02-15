/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.util;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;

import com.nantian.jeda.common.model.Permission;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.common.model.SecurityEntity;
import com.nantian.jeda.common.model.User;

/**
 * @author daizhenzhong
 * 
 */
@Component
public class UserSession {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(UserSession.class);

	/**
	 * 返回当前登录用户数据对象.
	 * 
	 * @return 当前登录用户数据对象
	 */
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

	/**
	 * 为实体对象设置创建用户、创建时间、修改用户和修改时间.
	 * 
	 * @param entity 数据实体
	 */
	public void setCreateEntity(SecurityEntity entity) {
		Date date = new Date();
		entity.setCreated(date);
		entity.setCreator(getUser());
		entity.setModified(date);
		entity.setModifier(getUser());
	}

	/**
	 * 为实体对象设置修改用户和修改时间.
	 * 
	 * @param entity 数据实体
	 */
	public void setModifyEntity(SecurityEntity entity) {
		entity.setModified(new Date());
		entity.setModifier(getUser());
	}

	/**
	 * 返回当前登录用户的角色数据对象.
	 * 
	 * @return 当前登录用户的角色数据对象
	 */
	public Set<Role> getRole() {
		return getUser().getRoles();
	}

	/**
	 * 返回当前登录用户关联的权限数据对象.
	 * 
	 * @return 当前登录用户关联的权限数据对象
	 */
	public Set<Permission> getPermission() {
		if (getRole() != null && !getRole().isEmpty()) {
			Set<Permission> permissions = new HashSet<Permission>();
			for (Role role : getRole()) {
				permissions.addAll(role.getPermissions());
			}
			for (Permission permission : permissions) {// TODO 删除此处日志输出
				logger.debug("当前登录用户已被分配权限:[ " + permission.getExpression() + "]");
			}
			return permissions;
		} else {
			return null;
		}
	}
}

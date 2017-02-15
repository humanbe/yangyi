/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Permission;

/**
 * @author daizhenzhong
 * 
 */
@Component
public class PermissionProvider {

	/** 日志输出 */
	final static Logger logger = LoggerFactory.getLogger(PermissionProvider.class);

	/** 用户会话对象 */
	@Autowired
	private UserSession userSession;

	public final String ORG_ID = "#ORG_ID#";

	public final String ORG_PATH = "#ORG_PATH#";
	public final String HIGHER_ORGS = "#HIGHER_ORGS#";
	public final String USER_NAME = "#USER_NAME#";

	/**
	 * 根据功能ID查询权限实体.
	 * 
	 * @param functionId 功能ID
	 * @return
	 * @throws JEDAException
	 */
	public Set<Permission> getPermissionsByFunction(String functionId) throws JEDAException {
		return getPermissionsByFunctionAndType(functionId, null);
	}

	/**
	 * 根据功能ID查询用户类型权限实体.
	 * 
	 * @param functionId 功能ID
	 * @return 用户类型权限实体集合
	 * @throws JEDAException
	 */
	public Set<Permission> getUserPermissionByFunction(String functionId) throws JEDAException {
		return getPermissionsByFunctionAndType(functionId, Permission.TYPE_USER);
	}

	/**
	 * 根据功能ID查询机构类型权限实体.
	 * 
	 * @param functionId 功能ID
	 * @return 机构类型权限实体集合
	 * @throws JEDAException
	 */
	public Set<Permission> getOrgPermissionByFunction(String functionId) throws JEDAException {
		return getPermissionsByFunctionAndType(functionId, Permission.TYPE_ORG);
	}

	/**
	 * 根据功能ID查询字典类型权限实体.
	 * 
	 * @param functionId 功能ID
	 * @return 字典类型权限实体集合
	 * @throws JEDAException
	 */
	public Set<Permission> getItemPermissionByFunction(String functionId) throws JEDAException {
		return getPermissionsByFunctionAndType(functionId, Permission.TYPE_ITEM);
	}

	/**
	 * 根据功能ID查询数值类型权限实体.
	 * 
	 * @param functionId 功能ID
	 * @return 数值类型权限实体集合
	 * @throws JEDAException
	 */
	public Set<Permission> getConstantPermissionByFunction(String functionId) throws JEDAException {
		return getPermissionsByFunctionAndType(functionId, Permission.TYPE_CONSTANT);
	}

	/**
	 * 根据功能ID查询权限,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @return
	 * @throws JEDAException
	 */
	public String getPermissionHqlByFunction(String functionId) throws JEDAException {
		String hql = replaceVariable(getPermissionHqlByFunctionAndType(functionId, null), null);
		logger.info("当前登录用户在功能[" + functionId + "]中的权限HQL:[" + hql + "]");
		return hql;
	}

	/**
	 * 根据功能ID查询权限,根据字段映射关系替换相关变量,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @param fieldMap 字段映射关系
	 * @return
	 * @throws JEDAException
	 */
	public String getPermissionHqlByFunction(String functionId, Map<String, String> fieldMap) throws JEDAException {
		String hql = replaceVariable(getPermissionHqlByFunctionAndType(functionId, null), fieldMap);
		logger.info("当前登录用户在功能[" + functionId + "]中的权限HQL:[" + hql + "]");
		return hql;
	}

	/**
	 * 根据功能ID查询用户类型权限,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @return
	 * @throws JEDAException
	 */
	public String getUserPermissionHqlByFunction(String functionId) throws JEDAException {
		return getPermissionHqlByFunctionAndType(functionId, Permission.TYPE_USER);
	}

	/**
	 * 根据功能ID查询字典类型权限,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @return
	 * @throws JEDAException
	 */
	public String getItemPermissionHqlByFunction(String functionId) throws JEDAException {
		return getPermissionHqlByFunctionAndType(functionId, Permission.TYPE_ITEM);
	}

	/**
	 * 根据功能ID查询数值类型权限,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @return
	 * @throws JEDAException
	 */
	public String getConstantPermissionHqlByFunction(String functionId) throws JEDAException {
		return getPermissionHqlByFunctionAndType(functionId, Permission.TYPE_CONSTANT);
	}

	/**
	 * 替换HQL中的变量.
	 * 
	 * @param hql
	 * @param fieldMap
	 * @return
	 * @throws JEDAException
	 */
	private String replaceVariable(String hql, Map<String, String> fieldMap) throws JEDAException {
		if (fieldMap != null) {
			for (Map.Entry<String, String> entry : fieldMap.entrySet()) {
				hql = hql.replaceAll("@" + entry.getKey() + "@", entry.getValue());
			}

		}
		String[] ids = userSession.getUser().getOrg().getPath().split("\\|");
		hql = hql.replaceAll(ORG_ID, userSession.getUser().getOrg().getId().toString())
				.replaceAll(ORG_PATH, userSession.getUser().getOrg().getPath().toString())
				.replaceAll(USER_NAME, userSession.getUser().getUsername().toString())
				.replaceAll(HIGHER_ORGS, "'" + StringUtils.join(ids, "','") + "'").replaceAll("@", "");

		return hql.isEmpty() ? "" : " and " + hql;
	}

	/**
	 * 根据功能ID和权限类型查询权限实体.
	 * 
	 * @param functionId 功能ID
	 * @param type 权限类型
	 * @return 权限实体集合
	 * @throws JEDAException
	 */
	private Set<Permission> getPermissionsByFunctionAndType(String functionId, String type) throws JEDAException {
		if (functionId == null || functionId.isEmpty()) {
			throw new JEDAException("Function id can not be null!");
		}
		Set<Permission> permissions = new HashSet<Permission>();
		for (Permission permission : userSession.getPermission()) {
			if (functionId.equals(permission.getField().getFunction().getId())) {
				if (type == null) {
					permissions.add(permission);
				} else if (permission.getType().equals(type)) {
					permissions.add(permission);
				}
			}
		}
		for (Permission permission : permissions) {// TODO 删除此处日志输出
			logger.debug("当前登录用户在功能[" + functionId + "]中已被分配类型为[" + type + "]的权限:[" + permission.getExpression() + "]");
		}
		return permissions;
	}

	/**
	 * 根据功能ID和权限类型查询权限,并以HQL查询条件形式返回.
	 * 
	 * @param functionId 功能ID
	 * @param type 权限类型
	 * @return
	 * @throws JEDAException
	 */
	private String getPermissionHqlByFunctionAndType(String functionId, String type) throws JEDAException {
		if (functionId == null || functionId.isEmpty()) {
			throw new JEDAException("Function id can not be null!");
		}
		List<String> hqls = new ArrayList<String>();
		Map<String, Map<String, Set<Permission>>> typeMap = new HashMap<String, Map<String, Set<Permission>>>();
		for (Permission permission : getPermissionsByFunctionAndType(functionId, type)) {
			if (typeMap.containsKey(permission.getType())) {
				if (typeMap.get(permission.getType()).containsKey(permission.getField().getCode())) {
					typeMap.get(permission.getType()).get(permission.getField().getId()).add(permission);
				} else {
					Set<Permission> set = new HashSet<Permission>();
					set.add(permission);
					typeMap.get(permission.getType()).put(permission.getField().getCode(), set);
				}
			} else {
				Map<String, Set<Permission>> fieldMap = new HashMap<String, Set<Permission>>();
				Set<Permission> set = new HashSet<Permission>();
				set.add(permission);
				fieldMap.put(permission.getField().getCode(), set);
				typeMap.put(permission.getType(), fieldMap);
			}
		}

		for (Entry<String, Map<String, Set<Permission>>> entry : typeMap.entrySet()) {// TODO 删除此处日志输出
			for (Entry<String, Set<Permission>> e : entry.getValue().entrySet()) {
				for (Permission permission : e.getValue()) {
					logger.debug("当前登录用户在功能[" + functionId + "]中已被分配类型为[" + entry.getKey() + "]并且字段为[" + e.getKey() + "]的权限:["
							+ permission.getExpression() + "]");
				}
			}
		}

		if (type == null) {
			for (Entry<String, Map<String, Set<Permission>>> entry : typeMap.entrySet()) {
				getHqlByType(entry.getKey(), entry.getValue(), hqls);
			}
		} else {
			getHqlByType(type, typeMap.get(type), hqls);
		}

		return StringUtils.join(hqls, " and ");
	}

	/**
	 * 根据指定的权限类型,连接该类型中的权限,以HQL形式返回.
	 * 
	 * @param type
	 * @param fieldMap
	 * @return
	 */
	private List<String> getHqlByType(String type, Map<String, Set<Permission>> fieldMap, List<String> hqls) {
		if (type.equals(Permission.TYPE_USER)) {
			hqls.add(getHqlWithSameType(type, fieldMap, " or "));
		} else if (type.equals(Permission.TYPE_ORG)) {
			hqls.add(getHqlWithSameType(type, fieldMap, " or "));
		} else if (type.equals(Permission.TYPE_ITEM)) {
			hqls.add(getHqlWithSameType(type, fieldMap, " and "));
		} else if (type.equals(Permission.TYPE_CONSTANT)) {
			hqls.add(getHqlWithSameType(type, fieldMap, " and "));
		}

		return hqls;
	}

	/**
	 * 根据指定的连接关系(and|or),返回相同类型的权限连接而成的HQL.
	 * 
	 * @param type 权限类型
	 * @param fieldMap 权限类型-字段权限映射
	 * @param separator 连接关系
	 * @return
	 */
	private String getHqlWithSameType(String type, Map<String, Set<Permission>> fieldMap, String separator) {
		List<String> hqls = new ArrayList<String>();
		if (type.equals(Permission.TYPE_USER)) {
			for (Entry<String, Set<Permission>> entry : fieldMap.entrySet()) {
				hqls.add(getHqlWithSameTypeAndField(entry.getValue(), " or "));
			}
		} else if (type.equals(Permission.TYPE_ORG)) {
			for (Entry<String, Set<Permission>> entry : fieldMap.entrySet()) {
				hqls.add(getHqlWithSameTypeAndField(entry.getValue(), " or "));
			}
		} else if (type.equals(Permission.TYPE_ITEM)) {
			for (Entry<String, Set<Permission>> entry : fieldMap.entrySet()) {
				hqls.add(getHqlWithSameTypeAndField(entry.getValue(), " or "));
			}
		} else if (type.equals(Permission.TYPE_CONSTANT)) {
			for (Entry<String, Set<Permission>> entry : fieldMap.entrySet()) {
				hqls.add(getHqlWithSameTypeAndField(entry.getValue(), " and "));
			}
		}
		return StringUtils.join(hqls, separator);
	}

	/**
	 * 根据指定的连接关系(and|or),返回相同类型和字段的权限连接而成的HQL.
	 * 
	 * @param permissions 权限实体对象
	 * @param separator 连接关系
	 * @return
	 */
	private String getHqlWithSameTypeAndField(Set<Permission> permissions, String separator) {
		List<String> hqls = new ArrayList<String>();
		for (Permission permission : permissions) {
			hqls.add(permission.getExpression());
		}
		return StringUtils.join(hqls, separator);
	}
}

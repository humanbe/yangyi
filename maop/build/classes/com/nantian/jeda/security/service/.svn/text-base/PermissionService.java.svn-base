/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Permission;

/**
 * 权限服务
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class PermissionService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PermissionService.class);

	public Map<String, String> fields = new HashMap<String, String>();

	public PermissionService() {
		fields.put("name", FieldType.STRING);
		fields.put("expression", FieldType.STRING);

	}

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 保存.
	 * 
	 * @param permission
	 */
	@Transactional
	public void save(Permission permission) {
		getSession().save(permission);
	}

	public void evict(Permission permission) {
		getSession().evict(permission);

	}

	/**
	 * 更新.
	 * 
	 * @param permission
	 */
	@Transactional
	public void update(Permission permission) {
		getSession().saveOrUpdate(permission);
	}

	/**
	 * 合并.
	 * 
	 * @param permission
	 */
	@Transactional
	public void merge(Permission permission) {
		getSession().merge(permission);
	}

	/**
	 * 批量保存.
	 * 
	 * @param permission
	 */
	@Transactional
	public void save(Set<Permission> permissions) {
		for (Permission permission : permissions) {
			getSession().save(permission);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Permission.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param permission
	 */
	@Transactional
	public void delete(Permission permission) {
		getSession().delete(permission);
	}

	/**
	 * 返回列表数据数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count() {
		String hql = "select count(*) from Permission";
		Query query = getSession().createQuery(hql);
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询所有数据.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Permission> find() {
		return getSession().createQuery("from Permission").list();
	}

	/**
	 * 根据翻页、排序和其他参数查询记录.
	 * 
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find(Integer start, Integer limit, String sort, String dir, String functionId, Map<String, Object> params) {
		String hql = "select new map(p.id as id,p.name as name,p.field.function.id as functionId,p.field.function.name as functionName,p.type as type,p.userType as userType,p.orgType as orgType,si.name as subitem,i.name as item,p.expression as expression,p.order as order,"
				+ "p.creator.name as creator,p.created as created,p.modifier.name as modifier,p.modified as modified) "
				+ "from Permission p left join p.creator left join p.modifier left join p.subitem si left join si.parent i where 1=1 ";
		if (functionId != null) {
			hql += " and p.field.function.id = :functionId";
		}
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and p." + key + " like :" + key;
				} else {
					hql += " and p." + key + " = :" + key;
				}
			}
		}

		hql += " order by p." + sort + " " + dir;
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		if (functionId != null) {
			query.setString("functionId", functionId);
		}
		return query.list();
	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(String functionId, Map<String, Object> params) {
		String hql = "select count(*) from Permission where 1=1 ";
		if (functionId != null) {
			hql += " and field.function.id = :functionId";
		}
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		Query query = getSession().createQuery(hql);
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		if (functionId != null) {
			query.setString("functionId", functionId);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 根据ID查询.
	 * 
	 * @param id
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		return getSession()
				.createQuery(
						"select new map(p.id as id, p.name as name, p.field.id as field,p.field.function.id as function,p.type as type,p.userType as userType,p.orgType as orgType,si.id as subitem,i.id as item,p.fieldValue as fieldValue, p.expression as expression, p.description as description, p.order as order, p.version as version) from Permission p left join p.subitem si left join si.parent i where p.id =?")
				.setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	// private void deleteById(String id) {
	// getSession().createQuery("delete from Permission where id=?").setString(0, id).executeUpdate();
	// }

	/**
	 * 批量删除.
	 * 
	 * @param ids 主键数组
	 */
	@Transactional
	public void deleteByIds(Long[] ids) {
		for (Long id : ids) {
			// deleteById(id);
			getSession().delete(get(id));
		}
	}

	/**
	 * 根据查询所有权限,并附有是否已经与指定角色关联的信息.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param role
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> findByRoleAndFunction(String role, String functionId) {
		String hql = "select new map(p.id as id,p.name as name,p.field.id as field,p.field.function.name as functionName,p.type as type,";
		hql += "p.userType as userType,p.orgType as orgType,si.name as subitem,i.name as item,";
		hql += "p.expression as expression,p.order as order,";
		hql += "(case when (select count(*) from Role role inner join role.permissions permission where role.id=? and permission.id = p.id)>0 then true else false end ) as checked) ";
		hql += "from Permission p left join p.subitem si left join si.parent i where 1=1 ";
		if (functionId != null && !functionId.isEmpty()) {
			hql += " and p.field.function=? ";
		}
		hql += "order by p.order asc ";
		Query query = getSession().createQuery(hql).setString(0, role);
		if (functionId != null && !functionId.isEmpty()) {
			query.setString(1, functionId);
		}
		return query.list();
	}
}

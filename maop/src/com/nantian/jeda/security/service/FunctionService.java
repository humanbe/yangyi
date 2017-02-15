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

import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Function;

/**
 * 功能服务.
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class FunctionService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(FunctionService.class);

	public Map<String, String> fields = new HashMap<String, String>();

	public FunctionService() {
		fields.put("name", FieldType.STRING);
		fields.put("url", FieldType.STRING);

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
	 * @param function
	 */
	@Transactional
	public void save(Function function) {
		getSession().save(function);
	}

	/**
	 * 更新.
	 * 
	 * @param function
	 */
	@Transactional
	public void update(Function function) {
		getSession().update(function);
	}

	/**
	 * 批量保存.
	 * 
	 * @param function
	 */
	@Transactional
	public void save(Set<Function> functions) {
		for (Function function : functions) {
			getSession().save(function);
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
		return getSession().get(Function.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param function
	 */
	@Transactional
	public void delete(Function function) {
		getSession().delete(function);
	}

	/**
	 * 返回列表数据数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count() {
		String hql = "select count(*) from Function";
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
	public List<Function> find() {
		return getSession().createQuery("from Function f").list();
	}

	/**
	 * 查询所有数据.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Function> findMap() {
		return getSession().createQuery(
				"select new map(f.id as id,f.name as name,f.url as url,f.module.name as module,f.order as order,"
						+ "f.creator.name as creator,f.created as created,f.modifier.name as modifier,f.modified as modified) from Function f")
				.list();
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
	public List<Map<String, String>> find(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(f.id as id,f.name as name,f.url as url,f.hasPermission as hasPermission,f.module.name as module,f.order as order,"
				+ "f.creator.name as creator,f.created as created,f.modifier.name as modifier,f.modified as modified) "
				+ "from Function f left join f.creator left join f.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and f." + key + " like :" + key;
				} else {
					hql += " and f." + key + " = :" + key;
				}
			}
		}

		hql += " order by f." + sort + " " + dir;
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
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
	public Long count(Map<String, Object> params) {
		String hql = "select count(*) from Function where 1=1 ";
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
						"select new map(id as id, name as name, module.id as module, url as url, hasPermission as hasPermission, order as order, version as version) from Function where id =?")
				.setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Function where id=?").setString(0, id).executeUpdate();
	}

	/**
	 * 批量删除.
	 * 
	 * @param ids 主键数组
	 */
	@Transactional
	public void deleteByIds(String[] ids) {
		for (String id : ids) {
			deleteById(id);
		}
	}

	/**
	 * 根据查询所有功能,并附有是否已经与指定角色关联的信息.
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
	public List<Map<String, Object>> findModuleAndFunctionByRole(String node, String role) {
		String hql = "";
		if (node.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += "select new map(m.id as id,m.name as text,'node-module' as iconCls,(case when (select count(*) from Function f where f.module.id = m.id)>0 then false else true end) as leaf) from Module m order by m.order asc)";
			return getSession().createQuery(hql).list();
		} else {
			hql = "select new map(f.id as id,f.name as text,'node-function' as iconCls,(case when 1=1 then true end) as leaf,";
			hql += "(case when (select count(*) from Role role inner join role.functions function where role.id=:role and function.id = f.id)>0 then true else false end ) as checked) ";
			hql += "from Function f where f.module.id=:module order by f.order asc ";
			return getSession().createQuery(hql).setString("role", role).setString("module", node).list();
		}
	}

	/**
	 * 返回模块或者可配权限功能的树形数据.用于权限列表页面.
	 * 
	 * @param node 上级节点ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findModuleAndFunction(String node) {
		String hql = "";
		if (node.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += "select new map(m.id as id,m.name as text,'node-module' as iconCls,'module' as category,(case when (select count(*) from Function f where f.module.id = m.id and f.hasPermission = true)>0 then false else true end) as leaf) from Module m order by m.order asc)";
			return getSession().createQuery(hql).list();
		} else {
			hql = "select new map(f.id as id,f.name as text,'node-function' as iconCls,'function' as category,(case when 1=1 then true end) as leaf) ";
			hql += "from Function f where f.module.id=:module and f.hasPermission = true order by f.order asc ";
			return getSession().createQuery(hql).setString("module", node).list();
		}
	}
}

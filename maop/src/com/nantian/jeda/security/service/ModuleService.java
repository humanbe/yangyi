/**
 * 
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Module;

/**
 * @author daizhenzhong
 * 
 */
@Repository
public class ModuleService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ModuleService.class);

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法.初始化查询参数.
	 */
	public ModuleService() {
		fields.put("name", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param module
	 */
	@Transactional
	public void save(Module module) {
		getSession().save(module);
	}

	/**
	 * 更新.
	 * 
	 * @param module
	 */
	@Transactional
	public void update(Module module) {
		getSession().update(module);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Module.class, id);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		return getSession()
				.createQuery(
						"select new map(m.id as id,m.name as name,m.id as id,m.name as name,m.description as description,m.order as order,m.creator.name as creator,m.created as created,m.modifier.name as modifier,m.modified as modified,m.version as version) "
								+ "from Module m where m.id =? ").setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param module
	 */
	@Transactional
	public void delete(Module module) {
		getSession().delete(module);
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Module m where m.id=?").setString(0, id).executeUpdate();
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
		String hql = "select new map(m.id as id,m.name as name,m.description as description,m.order as order,m.creator.name as creator,m.created as created,m.modifier.name as modifier,m.modified as modified) "
				+ "from Module m left join m.creator left join m.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and m." + key + " like :" + key;
				} else {
					hql += " and m." + key + " = :" + key;
				}
			}
		}

		hql += " order by m." + sort + " " + dir;
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
		String hql = "select count(*) from Module where 1=1 ";
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

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find() {
		String hql = "select new map(m.id as id,m.name as name,m.description as description,m.order as order) "
				+ "from Module m order by m.order asc";
		Query query = getSession().createQuery(hql);
		return query.list();
	}

}

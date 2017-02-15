/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.config.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Portlet;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Service
@Repository
public class PortletService {

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	public PortletService() {
		fields.put("id", FieldType.STRING);
		fields.put("title", FieldType.STRING);
		fields.put("url", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param document
	 */
	@Transactional
	public void save(Portlet portlet) {
		getSession().save(portlet);
	}

	/**
	 * 批量保存.
	 * 
	 * @param portlets
	 */
	@Transactional
	public void save(Set<Portlet> portlets) {
		for (Portlet portlet : portlets) {
			getSession().save(portlet);
		}
	}

	/**
	 * 更新.
	 * 
	 * @param document
	 */
	@Transactional
	public void update(Portlet portlet) {
		getSession().update(portlet);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Portlet.class, id);
	}


	/**
	 * 查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		String hql = "select new map(p.id as id,p.title as title,p.url as url,p.version as version,p.order as order) from Portlet p where p.id =?";
		return getSession().createQuery(hql).setString(0, id).uniqueResult();
	}

	public boolean locationInUse(Integer row, Integer column) {
		return getSession().createQuery("from PositionLocation where row=? and column=?").setInteger(0, row).setInteger(1, column).list().size() > 0;
	}

	/**
	 * 删除.
	 * 
	 * @param document
	 */
	@Transactional
	public void delete(Portlet portlet) {
		getSession().delete(portlet);
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Portlet p where p.id=?").setString(0, id).executeUpdate();
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
	 * @param start 开始记录条数
	 * @param limit 返回记录条数
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> find(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(p.id as id,p.title as title,p.url as url,p.order as order) from Portlet p where 1=1 ";
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
		return query.list();
	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) {
		String hql = "select count(*) from Portlet where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		Query query = getSession().createQuery(hql);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询可用Portlet数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findAvaliable(Long positionId) {
		String hql = "select new map(p1.id as id,p1.title as title,p1.url as url,p1.order as order) from Portlet p1 where p1.id not in(select pl.portlet.id from PortletLocation pl where pl.position.id=?) ";

		hql += " order by p1.order asc";
		Query query = getSession().createQuery(hql);

		return query.setLong(0, positionId).list();
	}

	/**
	 * 查询可用Portlet数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countAvaliable(Long positionId) {
		String hql = "select count(*) from Portlet p1 where p1.id not in(select pl.portlet.id from PortletLocation pl where pl.position.id=?) ";
		Query query = getSession().createQuery(hql).setLong(0, positionId);
		return Long.valueOf(query.uniqueResult().toString());
	}
}

/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.ArrayList;
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

import com.nantian.common.util.CommonConst;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Field;
import com.nantian.jeda.common.model.Function;

/**
 * 字段服务.
 * 
 * @author daizhenzhong
 * 
 */
/**
 * @author user
 *
 */
@Repository
public class FieldService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(FieldService.class);

	public Map<String, String> fields = new HashMap<String, String>();

	public FieldService() {
		fields.put("id", FieldType.STRING);
		fields.put("name", FieldType.STRING);

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
	 * @param field
	 */
	@Transactional
	public void save(Field field) {
		getSession().save(field);
	}

	/**
	 * 更新.
	 * 
	 * @param field
	 */
	@Transactional
	public void update(Field field) {
		getSession().update(field);
	}

	/**
	 * 批量保存.
	 * 
	 * @param field
	 */
	@Transactional
	public void save(Set<Field> fields) {
		for (Field field : fields) {
			getSession().save(field);
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
		return getSession().get(Field.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param field
	 */
	@Transactional
	public void delete(Field field) {
		getSession().delete(field);
	}

	/**
	 * 返回列表数据数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count() {
		String hql = "select count(*) from Field";
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
	public List<Field> find() {
		return getSession().createQuery("from Field f").list();
	}

	/**
	 * 查询所有数据.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Field> findMap() {
		return getSession().createQuery(
				"select new map(f.id as id,f.code as code,f.name as name,f.url as url,f.module.name as module,f.order as order,"
						+ "f.creator.name as creator,f.created as created,f.modifier.name as modifier,f.modified as modified) from Field f").list();
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
	public List<Map<String, String>> findByFunction(Integer start, Integer limit, String sort, String dir, Map<String, Object> params,
			String functionId) {
		String hql = "select new map(f.id as id,f.code as code,f.name as name,f.type as type,f.function.id as function,f.order as order,"
				+ "f.creator.name as creator,f.created as created,f.modifier.name as modifier,f.modified as modified) "
				+ "from Field f left join f.creator left join f.modifier where f.function.id = :functionId and 1=1 ";
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
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit).setString("functionId", functionId);

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
	public Long countByFunction(Map<String, Object> params, String functionId) {
		String hql = "select count(*) from Field where function.id = :functionId and 1=1 ";
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		Query query = getSession().createQuery(hql).setString("functionId", functionId);
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	
	/**
	 * 查询ip域.
	 * @param functionId 功能主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public List<Map<String, String>> findDomainIps(String functionId) {
		Function function = (Function) getSession().createQuery("from Function f where f.id = :functionId")
														 .setString("functionId", functionId)
														 .uniqueResult();

		List<Map<String, String>> rtnList = new ArrayList<Map<String, String>>();
		Map<String, String> map = null;
		if(null != function.getAccessDomainIp()) {
			String []ip = function.getAccessDomainIp().split(",");
			for (int i = 0; i < ip.length; i++) {
				map = new HashMap<String, String>();
				map.put("accessDomainIp", ip[i]);
				rtnList.add(map);
			}	
		}
		return rtnList;
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
						"select new map(id as id, code as code,name as name, type as type, function.id as function, order as order, version as version) from Field where id =?")
				.setString(0, id).uniqueResult();
	}

	/**
	 * 根据功能ID查询.
	 * 
	 * @param functionId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> findByFunction(String functionId) {
		return getSession().createQuery("select new map(id as id, name as name) from Field where function.id =? order by order asc")
				.setString(0, functionId).list();
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Field where id=?").setString(0, id).executeUpdate();
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
	/**9
	 * 保存域ip
	 * 
	 * @param ids 主键数组
	 */
	public void saveDomainIps(String[] domainIp,String functionId) {
		StringBuilder domainIps=new StringBuilder();
		for(int i = 0; i < domainIp.length ;i++){
			domainIps.append(domainIp[i]);
			if(i != domainIp.length -1){
				domainIps.append(CommonConst.STRING_COMMA);
			}
		}
		String sql = "update jeda_function set function_access_domain_ip='"+domainIps+"' where function_id='"+functionId+"'";
		getSession().createSQLQuery(sql.toString()).executeUpdate();
	}
}

package com.nantian.demo.service;

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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.demo.vo.ServeInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">name</a>
 * 
 */
@Service
@Repository
@Transactional
public class ServeInfoService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ServeInfoService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法
	 */
	public ServeInfoService() {
		fields.put("appsystemid", FieldType.STRING);
		fields.put("serveid", FieldType.STRING);
		fields.put("servename", FieldType.STRING);
		fields.put("servenum", FieldType.STRING);
		fields.put("queuenmu", FieldType.STRING);
		fields.put("busimodule", FieldType.STRING);
		fields.put("higserviceid", FieldType.STRING);
		fields.put("isload", FieldType.STRING);
		fields.put("reserve", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ServeInfoVo serverinfo) {
		getSession().save(serverinfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(ServeInfoVo serverinfo) {
		getSession().update(serverinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ServeInfoVo> serverinfos) {
		for (ServeInfoVo serverinfo : serverinfos) {
			getSession().save(serverinfo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	public Object get(Serializable tranid) {
		return getSession().get(ServeInfoVo.class, tranid);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ServeInfoVo serverinfo) {
		getSession().delete(serverinfo);
	}

	/**
	 * 查询数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, String>> find(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("i.appsystemid as appsystemid,");
		hql.append("i.serveid as serveid,");
		hql.append("i.servename as servename,");
		hql.append("i.servenum as servenum,");
		hql.append("i.queuenum as queuenum,");
		hql.append("i.busimodule as busimodule,");
		hql.append("i.higserviceid as higserviceid,");
		hql.append("i.isload as isload,");
		hql.append("i.reserve as reserve,");
		hql.append("i.reserve1 as reserve1");
		hql.append(") from ServeInfoVo i where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and i." + key + " like :" + key);
				} else {
					hql.append(" and i." + key + " = :" + key);
				}
			}
		}
		
		// hql.append(" order by i." + sort + " " + dir);
		logger.error(hql.toString());
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from ServeInfoVo i where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and i." + key + " like :" + key);
				} else {
					hql.append(" and i." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());
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
	public Object findById(String appsystemid, String serveid) {

		System.out.println("appsystemid:"+appsystemid);
		System.out.println("serveid:"+serveid);
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("i.serveid as serveid,");
		hql.append("i.appsystemcd as appsystemcd,");
		hql.append("i.servecd as servecd,");
		hql.append("i.servename as servename,");
		hql.append("i.servenum as servenum,");
		hql.append("i.queuenum as queuenum,");
		hql.append("i.busimodule as busimodule,");
		hql.append("i.higserviceid as higserviceid,");
		hql.append("i.isload as isload,");
		hql.append("i.reserve as reserve,");
		hql.append("i.reserve1 as reserve1");
		hql.append(") from ServeInfoVo i where i.appsystemcd =? and i.serveid =?");

		return getSession().createQuery(hql.toString()).setString(0, appsystemid).setString(1, serveid)
				.uniqueResult();
	}

	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String tranid) {
		getSession().createQuery("delete from ServeInfoVo where tranid=?")
				.setString(0, tranid).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] tranids) {
		for (String tranid : tranids) {
			deleteById(tranid);
		}
	}

}

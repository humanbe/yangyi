//Service
//.java
/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
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

import com.nantian.demo.vo.TranInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">name</a>
 * 
 */
@Service
@Repository
@Transactional
public class TranInfoService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(TranInfoService.class);

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
	public TranInfoService() {
		fields.put("tranid", FieldType.STRING);
		fields.put("appsystemid", FieldType.STRING); 
		fields.put("chnlno", FieldType.STRING); 
		fields.put("outtrancode", FieldType.STRING); 
		fields.put("trancode", FieldType.STRING); 
		fields.put("tranname", FieldType.STRING); 
		fields.put("trantime", FieldType.STRING); 
		fields.put("serviceid", FieldType.STRING); 
		fields.put("busimoduelname", FieldType.STRING); 
		fields.put("busimoduelcode", FieldType.STRING); 
		fields.put("higouttrancode", FieldType.STRING); 
		fields.put("callway", FieldType.STRING); 
		fields.put("callnum", FieldType.INTEGER); 
		fields.put("condition", FieldType.STRING); 
		fields.put("reserve", FieldType.STRING); 
		fields.put("reserve1", FieldType.STRING); 
		fields.put("reserve2", FieldType.STRING); 
		fields.put("reserve3", FieldType.STRING); 
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(TranInfoVo traninfo) {
		getSession().save(traninfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(TranInfoVo traninfo) {
		getSession().update(traninfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<TranInfoVo> traninfos) {
		for (TranInfoVo traninfo : traninfos) {
			getSession().save(traninfo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	public Object get(Serializable tranid) {
		return getSession().get(TranInfoVo.class, tranid);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(TranInfoVo traninfo) {
		getSession().delete(traninfo);
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
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> find(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params) {
			
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append("i.appsystemid as appsystemid,");
 		hql.append("i.chnlno as chnlno,");
 		hql.append("i.outtrancode as outtrancode,");
 		hql.append("i.trancode as trancode,");
 		hql.append("i.tranname as tranname,");
 		hql.append("i.trantime as trantime,");
 		hql.append("i.serviceid as serviceid,");
 		hql.append("i.busimoduelname as busimoduelname,");
 		hql.append("i.busimoduelcode as busimoduelcode,");
 		hql.append("i.higouttrancode as higouttrancode,");
 		hql.append("i.callway as callway,");
 		hql.append("i.callnum as callnum,");
 		hql.append("i.condition as condition,");
 		hql.append("i.reserve as reserve,");
 		hql.append("i.reserve1 as reserve1,");
 		hql.append("i.reserve2 as reserve2,");
 		hql.append("i.reserve3 as reserve3,");
 		hql.append("i.tranid as tranid");
		hql.append(") from TranInfoVo i , CallInfoVo  r where 1=1 ");
		hql.append("and i.tranid=r.callId and r.headNode='1' ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and i." + key + " like :" + key);
				} else {
					hql.append(" and i." + key + " = :" + key);
				}
			}
		}

		//hql.append(" order by i." + sort + " " + dir);
		logger.error(hql.toString());
		Query query = getSession().createQuery(hql.toString()).setFirstResult(start).setMaxResults(limit);

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
		hql.append("select count(*) from TranInfoVo i where 1=1 ");
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
	public Object findById(String tranid) {
	
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append("i.appsystemid as appsystemid,");
 		hql.append("i.chnlno as chnlno,");
 		hql.append("i.outtrancode as outtrancode,");
 		hql.append("i.trancode as trancode,");
 		hql.append("i.tranname as tranname,");
 		hql.append("i.trantime as trantime,");
 		hql.append("i.serviceid as serviceid,");
 		hql.append("i.busimoduelname as busimoduelname,");
 		hql.append("i.busimoduelcode as busimoduelcode,");
 		hql.append("i.higouttrancode as higouttrancode,");
 		hql.append("i.callway as callway,");
 		hql.append("i.callnum as callnum,");
 		hql.append("i.condition as condition,");
 		hql.append("i.reserve as reserve,");
 		hql.append("i.reserve1 as reserve1,");
 		hql.append("i.reserve2 as reserve2,");
 		hql.append("i.reserve3 as reserve3,");
 		hql.append("i.tranid as tranid");
		hql.append(") from TranInfoVo i where i.tranid =? ");
		
		return getSession().createQuery(hql.toString())
				.setString(0, tranid).uniqueResult();
	}

	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String tranid) {
		getSession().createQuery("delete from TranInfoVo where tranid=?").setString(0, tranid).executeUpdate();
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


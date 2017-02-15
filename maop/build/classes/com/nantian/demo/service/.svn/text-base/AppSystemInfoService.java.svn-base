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

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.demo.vo.AppSystemInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">name</a>
 * 
 */
@Service
@Repository
@Transactional
public class AppSystemInfoService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppSystemInfoService.class);

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
	public AppSystemInfoService() {
		fields.put("appsystemid", FieldType.STRING);
		fields.put("appsystemname", FieldType.STRING);
		fields.put("issysflag", FieldType.STRING);
		fields.put("appsystemtype", FieldType.STRING);
		fields.put("appsystemtime", FieldType.STRING);
		fields.put("meno", FieldType.STRING);
		fields.put("appadminidA", FieldType.STRING);
		fields.put("sysadminidA", FieldType.STRING);
		fields.put("appadminidB", FieldType.STRING);
		fields.put("sysadminidB", FieldType.STRING);
		fields.put("bmanagerid", FieldType.STRING);
		fields.put("cmanagerid", FieldType.STRING);
		fields.put("busicontact1id", FieldType.STRING);
		fields.put("busicontact2id", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
		fields.put("reserve2", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(AppSystemInfoVo appsysteminfo) {
		getSession().save(appsysteminfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(AppSystemInfoVo appsysteminfo) {
		getSession().update(appsysteminfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<AppSystemInfoVo> appsysteminfos) {
		for (AppSystemInfoVo appsysteminfo : appsysteminfos) {
			getSession().save(appsysteminfo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	public Object get(Serializable appsystemid) {
		return getSession().get(AppSystemInfoVo.class, appsystemid);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(AppSystemInfoVo appsysteminfo) {
		getSession().delete(appsysteminfo);
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
	public List<Map<String, Object>> find(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("y.appsystemname as appsystemname,");
		hql.append("y.issysflag as issysflag,");
		hql.append("y.appsystemtype as appsystemtype,");
		hql.append("y.appsystemtime as appsystemtime,");
		hql.append("y.meno as meno,");
		hql.append("(select z.adminname from AddressBookInfoVo z where y.appadminidA=z.adminid) as appadminidA,");
		hql.append("y.sysadminidA as sysadminidA,");
		hql.append("y.appadminidB as appadminidB,");
		hql.append("y.sysadminidB as sysadminidB,");
		hql.append("y.bmanagerid as bmanagerid,");
		hql.append("y.cmanagerid as cmanagerid,");
		hql.append("y.busicontact1id as busicontact1id,");
		hql.append("y.busicontact2id as busicontact2id,");
		hql.append("y.reserve1 as reserve1,");
		hql.append("y.reserve2 as reserve2,");
		hql.append("y.appsystemid as appsystemid,");
		hql.append(") from AppSystemInfoVo y where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and y." + key + " like :" + key);
				} else {
					hql.append(" and y." + key + " = :" + key);
				}
			}
		}
		// hql.append(" order by y." + sort + " " + dir);
		logger.error(hql.toString());
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
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
	public List<Map<String, String>> findAdminname(Integer start,
			Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder sql = new StringBuilder();
		sql.append("select ");
		sql.append("y.appsystemname as appsystemname,");
		sql.append("y.issysflag as issysflag,");
		sql.append("y.appsystemtype as appsystemtype,");
		sql.append("y.appsystemtime as appsystemtime,");
		sql.append("y.meno as meno,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.appadminid_A=z.adminid) as appadminidA,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.sysadminid_A=z.adminid) as sysadminidA,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.appadminid_B=z.adminid) as appadminidB,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.sysadminid_B=z.adminid) as sysadminidB,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.bmanagerid=z.adminid) as bmanagerid,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.cmanagerid=z.adminid) as cmanagerid,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.busicontact1id=z.adminid) as busicontact1id,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.busicontact2id=z.adminid) as busicontact2id,");
		sql.append("y.reserve1 as reserve1,");
		sql.append("y.reserve2 as reserve2,");
		sql.append("y.appsystemid as appsystemid");
		sql.append(" from T_APP_SYSTEM_INFO y where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and y." + key + " like :" + key);
				} else {
					sql.append(" and y." + key + " = :" + key);
				}
			}
		}
		// hql.append(" order by y." + sort + " " + dir);
		logger.error(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
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
		hql.append("select count(*) from AppSystemInfoVo y where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and y." + key + " like :" + key);
				} else {
					hql.append(" and y." + key + " = :" + key);
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
	public Object findById1(String appsystemid) {

		StringBuilder sql = new StringBuilder();
		sql.append("select ");
		sql.append("y.appsystemname as appsystemname,");
		sql.append("y.issysflag as issysflag,");
		sql.append("y.appsystemtype as appsystemtype,");
		sql.append("y.appsystemtime as appsystemtime,");
		sql.append("y.meno as meno,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.appadminid_A=z.adminid) as appadminidA,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.sysadminid_A=z.adminid) as sysadminidA,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.appadminid_B=z.adminid) as appadminidB,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.sysadminid_B=z.adminid) as sysadminidB,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.bmanagerid=z.adminid) as bmanagerid,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.cmanagerid=z.adminid) as cmanagerid,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.busicontact1id=z.adminid) as busicontact1id,");
		sql.append("(select z.adminname from T_ADDRESS_BOOK_INFO z where y.busicontact2id=z.adminid) as busicontact2id,");
		sql.append("y.reserve1 as reserve1,");
		sql.append("y.reserve2 as reserve2,");
		sql.append("y.appsystemid as appsystemid");
		sql.append(" from T_APP_SYSTEM_INFO y where y.appsystemid =? ");

		return getSession().createSQLQuery(sql.toString())
				.setString(0, appsystemid).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

	}

	/**
	 * 根据ID查询.
	 * 
	 * @param id
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String appsystemid) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("y.appsystemname as appsystemname,");
		hql.append("y.issysflag as issysflag,");
		hql.append("y.appsystemtype as appsystemtype,");
		hql.append("y.appsystemtime as appsystemtime,");
		hql.append("y.meno as meno,");
		hql.append("y.appadminidA as appadminidA,");
		hql.append("y.sysadminidA as sysadminidA,");
		hql.append("y.appadminidB as appadminidB,");
		hql.append("y.sysadminidB as sysadminidB,");
		hql.append("y.bmanagerid as bmanagerid,");
		hql.append("y.cmanagerid as cmanagerid,");
		hql.append("y.busicontact1id as busicontact1id,");
		hql.append("y.busicontact2id as busicontact2id,");
		hql.append("y.reserve1 as reserve1,");
		hql.append("y.reserve2 as reserve2,");
		hql.append("y.appsystemid as appsystemid");
		hql.append(") from AppSystemInfoVo y where y.appsystemid =? ");

		return getSession().createQuery(hql.toString())
				.setString(0, appsystemid).uniqueResult();

	}
	
	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String appsystemid) {
		getSession()
				.createQuery("delete from AppSystemInfoVo where appsystemid=?")
				.setString(0, appsystemid).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] appsystemids) {
		for (String appsystemid : appsystemids) {
			deleteById(appsystemid);
		}
	}

}

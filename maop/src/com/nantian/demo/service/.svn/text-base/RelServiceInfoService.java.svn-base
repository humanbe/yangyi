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

import com.nantian.demo.vo.RelServiceInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">name</a>
 * 
 */
@Service
@Repository
@Transactional
public class RelServiceInfoService {
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
	public RelServiceInfoService() {
		fields.put("tranid", FieldType.STRING);
		fields.put("appsystemid", FieldType.STRING);
		fields.put("outappsystemid", FieldType.STRING);
		fields.put("outserivcesid", FieldType.STRING);
		fields.put("outtrancode", FieldType.STRING);
		fields.put("commprotocol", FieldType.STRING);
		fields.put("callway", FieldType.STRING);
		fields.put("callnum", FieldType.INTEGER);
		fields.put("condition", FieldType.STRING);
		fields.put("reserve", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
		fields.put("reserve2", FieldType.STRING);
		fields.put("isnide", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(RelServiceInfoVo relServiceinfo) {
		getSession().save(relServiceinfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(RelServiceInfoVo relServiceinfo) {
		getSession().update(relServiceinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<RelServiceInfoVo> relServiceinfos) {
		for (RelServiceInfoVo relServiceinfo : relServiceinfos) {
			getSession().save(relServiceinfo);
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
		return getSession().get(RelServiceInfoVo.class, tranid);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(RelServiceInfoVo relServiceinfo) {
		getSession().delete(relServiceinfo);
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
		hql.append("i.appsystemid as appsystemid,");
		hql.append("i.outappsystemid as outappsystemid,");
		hql.append("i.outserivcesid as outserivcesid,");
		hql.append("i.outtrancode as outtrancode,");
		hql.append("i.commprotocol as commprotocol,");
		hql.append("i.callway as callway,");
		hql.append("i.callnum as callnum,");
		hql.append("i.condition as condition,");
		hql.append("i.reserve as reserve,");
		hql.append("i.reserve1 as reserve1,");
		hql.append("i.reserve2 as reserve2,");
		hql.append("i.tranid as tranid,");
		hql.append("i.isnide as isnide");
		hql.append(") from RelServiceInfoVo i where 1=1 ");

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
	 * 服务调用关系.
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
	public List<Map<String, String>> findServe(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select ");
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
		hql.append("i.tranid as tranid,");
		hql.append("z.outserivcesid as serveid,");
		hql.append("x.servename as servename");
		hql.append(" from T_TRAN_INFO i, T_REL_SERVICE_INFO z, T_SERVE_INFO x where i.tranid in(select y.tranid ");
		hql.append(" from T_REL_SERVICE_INFO y where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and y." + key + " like :" + key);
				} else {
					hql.append(" and y." + key + " = :" + key);
				}
			}
		}
		hql.append(" ) and i.tranid = z.tranid and z.outappsystemid = x.appsystemid and z.outserivcesid = x.serveid");
		// hql.append(" order by i." + sort + " " + dir);
		logger.error(hql.toString());
		// Query query =
		// getSession().createQuery(hql.toString()).setFirstResult(start).setMaxResults(limit);
		Query query = getSession().createSQLQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
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
		hql.append("select count(*) from RelServiceInfoVo i where 1=1");
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
	 * 查询服务调用关系数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countServe(Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from TranInfoVo i where i.tranid in(select y.tranid ");
		hql.append(" from RelServiceInfoVo y where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and y." + key + " like :" + key);
				} else {
					hql.append(" and y." + key + " = :" + key);
				}
			}
		}
		hql.append(" ) ");
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
		hql.append("i.outappsystemid as outappsystemid,");
		hql.append("i.outserivcesid as outserivcesid,");
		hql.append("i.outtrancode as outtrancode,");
		hql.append("i.commprotocol as commprotocol,");
		hql.append("i.callway as callway,");
		hql.append("i.callnum as callnum,");
		hql.append("i.condition as condition,");
		hql.append("i.reserve as reserve,");
		hql.append("i.reserve1 as reserve1,");
		hql.append("i.reserve2 as reserve2,");
		hql.append("i.tranid as tranid,");
		hql.append("i.isnide as isnide");
		hql.append(") from RelServiceInfoVo i where i.tranid =? ");

		return getSession().createQuery(hql.toString()).setString(0, tranid)
				.uniqueResult();
	}

	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String tranid) {
		getSession().createQuery("delete from RelServiceInfoVo where tranid=?")
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

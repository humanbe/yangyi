package com.nantian.dply.service;

import java.sql.SQLException;
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

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.SysConfManageVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class SysConfManageService {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(SysConfManageService.class);

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
	public SysConfManageService() {
		fields.put("sys_conf_id", FieldType.STRING);
		fields.put("sys_conf_code", FieldType.STRING);
		fields.put("sys_conf_name", FieldType.STRING);
		fields.put("sys_conf_value", FieldType.STRING);
		fields.put("sys_conf_type", FieldType.STRING);
		fields.put("sys_conf_desc", FieldType.STRING);
		fields.put("creator", FieldType.STRING);
		fields.put("modifier", FieldType.STRING);
		fields.put("created_time", FieldType.TIMESTAMP);
		fields.put("modifiled_time", FieldType.TIMESTAMP);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(SysConfManageVo vo) {
		getSession().save(vo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(SysConfManageVo vo) {
		getSession().update(vo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<SysConfManageVo> vos) {
		for (SysConfManageVo vo : vos) {
			getSession().save(vo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	public Object get(String sys_conf_id) {
		return getSession().get(SysConfManageVo.class, sys_conf_id);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(SysConfManageVo vo) {
		getSession().delete(vo);
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
	public List<Map<String, Object>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ds.sys_conf_id as sys_conf_id,");
		hql.append("ds.sys_conf_code as sys_conf_code,");
		hql.append("ds.sys_conf_name as sys_conf_name,");
		hql.append("ds.sys_conf_value as sys_conf_value,");
		hql.append("ds.sys_conf_type as sys_conf_type,");
		hql.append("ds.sys_conf_desc as sys_conf_desc,");
		hql.append("ds.creator as creator,");
		hql.append("ds.modifier as modifier,");
		hql.append("to_char(ds.created_time,'yyyy-MM-dd hh24:mi:ss') as  created_time ,");
		hql.append("to_char(ds.modifiled_time,'yyyy-MM-dd hh24:mi:ss') as  modifiled_time  ");
		hql.append(") from SysConfManageVo ds where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ds." + key + " like :" + key);
				} else {
					hql.append(" and ds." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by ds." + sort + " " + dir);
		 
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
		hql.append("select count(*) from SysConfManageVo ds where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ds." + key + " like :" + key);
				} else {
					hql.append(" and ds." + key + " = :" + key);
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
	 * @param sys_conf_id
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String sys_conf_id) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ds.sys_conf_id as sys_conf_id,");
		hql.append("ds.sys_conf_code as sys_conf_code,");
		hql.append("ds.sys_conf_name as sys_conf_name,");
		hql.append("ds.sys_conf_value as sys_conf_value,");
		hql.append("ds.sys_conf_type as sys_conf_type,");
		hql.append("ds.sys_conf_desc as sys_conf_desc,");
		hql.append("ds.creator as creator,");
		hql.append("ds.modifier as modifier,");
		hql.append("to_char(ds.created_time,'yyyy-MM-dd hh24:mi:ss') as  created_time ,");
		hql.append("to_char(ds.modifiled_time,'yyyy-MM-dd hh24:mi:ss') as  modifiled_time  ");
		hql.append(") from SysConfManageVo ds where ds.sys_conf_id =?   ");

		return getSession().createQuery(hql.toString())
				.setString(0, sys_conf_id).uniqueResult();

	}
	
	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String sys_conf_id) {
		getSession()
				.createQuery("delete from SysConfManageVo ds where ds.sys_conf_id = ?")
				.setString(0, sys_conf_id).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] sys_conf_ids) {
		for (String sys_conf_id : sys_conf_ids) {
			deleteById(sys_conf_id);
		}
	}
	
	/**
	 * 查序列

	 * 
	 */
	
	public String findSys_conf_id()throws SQLException {
		String seq=	(String) getSession().createSQLQuery(
						"select to_char (SYS_CONF_SEQ.nextval) as \"sys_conf_id\" from dual")
						.uniqueResult();
		return seq;
	}

}///:~

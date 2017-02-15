package com.nantian.dply.service;

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

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.ServerInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ServerInfoService {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(ServerInfoService.class);

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
	public ServerInfoService() {
		fields.put("hostIp", FieldType.STRING);
		fields.put("hostName", FieldType.STRING);
		fields.put("osType", FieldType.STRING);
		fields.put("osVersion", FieldType.STRING);
		fields.put("environType", FieldType.STRING);
		fields.put("fileTransferType", FieldType.STRING);
		fields.put("fileTransferUser", FieldType.STRING);
		fields.put("fileTransferPswd", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ServerInfoVo serverinfo) {
		getSession().save(serverinfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(ServerInfoVo serverinfo) {
		getSession().update(serverinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ServerInfoVo> serverinfos) {
		for (ServerInfoVo serverinfo : serverinfos) {
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
	@Transactional(readOnly = true)
	public Object get(Serializable hostIp) {
		return getSession().get(ServerInfoVo.class, hostIp);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ServerInfoVo serverinfo) {
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
	public List<Map<String, Object>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ds.hostIp as hostIp,");
		hql.append("ds.hostName as hostName,");
		hql.append("ds.osType as osType,");
		hql.append("ds.osVersion as osVersion,");
		hql.append("ds.environType as environType,");
		hql.append("ds.fileTransferType as fileTransferType,");
		hql.append("ds.fileTransferUser as fileTransferUser,");
		hql.append("ds.fileTransferPswd as fileTransferPswd,");
		hql.append("ds.deleteFlag as deleteFlag ");
		hql.append(") from ServerInfoVo ds where 1=1 ");

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
		hql.append("select count(*) from ServerInfoVo ds where 1=1 ");
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
	 * @param hostip
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String hostIp) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ds.hostIp as hostIp,");
		hql.append("ds.hostName as hostName,");
		hql.append("ds.osType as osType,");
		hql.append("ds.osVersion as osVersion,");
		hql.append("ds.environType as environType,");
		hql.append("ds.fileTransferType as fileTransferType,");
		hql.append("ds.fileTransferUser as fileTransferUser,");
		hql.append("ds.fileTransferPswd as fileTransferPswd,");
		hql.append("ds.deleteFlag as deleteFlag ");
		hql.append(") from ServerInfoVo ds where ds.hostIp =? and ds.deleteFlag = '0' ");

		return getSession().createQuery(hql.toString())
				.setString(0, hostIp).uniqueResult();

	}
	
	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String hostIp) {
		getSession()
				.createQuery("delete from ServerInfoVo ds where ds.hostIp = ?")
				.setString(0, hostIp).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] hostips) {
		for (String _hostip : hostips) {
			deleteById(_hostip);
		}
	}

}///:~

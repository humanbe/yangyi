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

import com.nantian.demo.vo.AddressBookInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:name@nantian.com.cn">name</a>
 * 
 */
@Service
@Repository
@Transactional
public class AddressBookInfoService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AddressBookInfoService.class);

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
	public AddressBookInfoService() {
		fields.put("addminid", FieldType.STRING);
		fields.put("adminname", FieldType.STRING); 
		fields.put("admintype", FieldType.STRING); 
		fields.put("mobile", FieldType.STRING); 
		fields.put("phone", FieldType.STRING); 
		fields.put("email", FieldType.STRING); 
		fields.put("remark", FieldType.STRING); 
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(AddressBookInfoVo addressbookinfo) {
		getSession().save(addressbookinfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(AddressBookInfoVo addressbookinfo) {
		getSession().update(addressbookinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<AddressBookInfoVo> addressbookinfos) {
		for (AddressBookInfoVo addressbookinfo : addressbookinfos) {
			getSession().save(addressbookinfo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	public Object get(Serializable addminid) {
		return getSession().get(AddressBookInfoVo.class, addminid);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(AddressBookInfoVo addressbookinfo) {
		getSession().delete(addressbookinfo);
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
 		hql.append("e.adminname as adminname,");
 		hql.append("e.admintype as admintype,");
 		hql.append("e.mobile as mobile,");
 		hql.append("e.phone as phone,");
 		hql.append("e.email as email,");
 		hql.append("e.remark as remark,");
 		hql.append("e.adminid as adminid");
		hql.append(") from AddressBookInfoVo e where 1=1 ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
				}
			}
		}

		//hql.append(" order by e." + sort + " " + dir);
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
		hql.append("select count(*) from AddressBookInfoVo e where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
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
	public Object findById(String addminid) {
	
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append("e.adminname as adminname,");
 		hql.append("e.admintype as admintype,");
 		hql.append("e.mobile as mobile,");
 		hql.append("e.phone as phone,");
 		hql.append("e.email as email,");
 		hql.append("e.remark as remark,");
 		hql.append("e.adminid as adminid");
		hql.append(") from AddressBookInfoVo e where e.adminid =? ");
		
		return getSession().createQuery(hql.toString())
				.setString(0, addminid).uniqueResult();
	}

	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String addminid) {
		getSession().createQuery("delete from AddressBookInfoVo where addminid=?").setString(0, addminid).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] addminids) {
		for (String addminid : addminids) {
			deleteById(addminid);
		}
	}

}


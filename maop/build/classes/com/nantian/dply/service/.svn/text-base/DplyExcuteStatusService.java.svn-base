/**
 * Copyright 2012 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class DplyExcuteStatusService {
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(DplyExcuteStatusService.class);

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
	 * 构造方法
	 */
	public DplyExcuteStatusService() {
		fields.put("entryId", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param executeStatusInfo
	 */
	@Transactional
	public void save(DplyExcuteStatusVo executeStatusInfo) {
		getSession().save(executeStatusInfo);
	}

	/**
	 * 更新.
	 * 
	 * @param executeStatusInfo
	 */
	@Transactional
	public void update(DplyExcuteStatusVo executeStatusInfo) {
		getSession().update(executeStatusInfo);
	}
	
	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable entryId) {
		return getSession().get(DplyExcuteStatusVo.class, entryId);
	}
	
	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryById(String entryId) {
		StringBuilder hql = new StringBuilder();
		hql.append(" from DplyExcuteStatusVo t where t.entryId = :entryId ");
		return getSession().createQuery(hql.toString()).setString("entryId", entryId).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(DplyExcuteStatusVo executeStatusInfo) {
		getSession().delete(executeStatusInfo);
	}
	

}///:~

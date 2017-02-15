/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.config.service;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.common.model.PortletLocation;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Service
@Repository
public class PortletLocationService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PortletLocationService.class);

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
	 * @param item
	 */
	@Transactional
	public void save(PortletLocation portletLocation) {
		getSession().save(portletLocation);
	}

	/**
	 * 批量保存.
	 * 
	 * @param portlets
	 */
	@Transactional
	public void save(Set<PortletLocation> portletLocations) {
		for (PortletLocation portletLocation : portletLocations) {
			getSession().save(portletLocation);
		}
	}
	

	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findByPosition(Long positionId) {
		String hql = "select new map(p.row as row,p.column as column,p.portlet.url as url,p.portlet.title as title,p.portlet.id as id) from PortletLocation p where p.position.id =? order by p.row asc , p.column asc";
		return getSession().createQuery(hql).setLong(0, positionId).list();
	}

	@Transactional
	public void update(Set<PortletLocation> portletLocations, Long positionId) {
		getSession().createQuery("delete from PortletLocation where position.id=?").setLong(0, positionId).executeUpdate();
		for (PortletLocation portletLocation : portletLocations) {
			getSession().save(portletLocation);
		}
	}

}

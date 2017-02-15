/**
 * 
 */
package com.nantian.jeda.config.service;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.common.model.Property;

/**
 * @author daizhenzhong
 * 
 */
@Repository
public class PropertyService {

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 更新.
	 * 
	 * @param property
	 */
	@Transactional
	public void update(Property property) {
		getSession().update(property);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get() {
		return getSession().createQuery("from Property p where p.id = (select max(p2.id) from Property p2 )").uniqueResult();
	}

	/**
	 * 查询.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object find() {
		String hql = "select new map(p.id as id,p.tabSize as tabSize,p.fileRoot as fileRoot,p.copyright as copyright,p.appTitle as appTitle,p.treeMenu as treeMenu) from Property p where p.id = (select max(p2.id) from Property p2 )";
		return getSession().createQuery(hql).uniqueResult();
	}
}

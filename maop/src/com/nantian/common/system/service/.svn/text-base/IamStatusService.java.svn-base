package com.nantian.common.system.service;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class IamStatusService {
	/**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;

    public Session getSession() {
        return sessionFactory.getCurrentSession();
    }
    
	/**
	 * 查询.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Integer queryState() {
		return (Integer) getSession().createQuery("select t.status from IamStatusVo t ").setMaxResults(1).uniqueResult();
	}
	
	/**
	 * 更新.
	 * 
	 * @param status
	 */
	@Transactional
	public void updateStatus(int status) {
		getSession().createSQLQuery("update iam_status t set t.status = :status  where rownum=1 ")
						  .setInteger("status", status)
						  .executeUpdate();
	}
    
}

package com.nantian.rept.service;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;

/**
 * 交易量配置服务层
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
@Service
@Transactional
public class TransItemService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/**hibernate session factory*/
	@Resource(name = "sessionFactoryMaopRpt")
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public TransItemService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("countItem", FieldType.STRING);
	}
	
	/**
	 * 查询系统编号和系统名称的映射集合
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryAplCodeNmMap(){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append("	t.appsysCode as valueField, ")
			.append("	t.appsysCode||'('||s.systemname||')' as displayField) ")
			.append("from TransItemVo t, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append("order by t.aplCode ");
		
		return getSession().createQuery(hql.toString()).list();
	}
	
	/**
	 * 查询系统编号和系统名称的映射集合
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryAplCodeNmMapForRpt(){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append("	s.appsysCode as valueField, ")
			.append("	s.appsysCode||'('||s.systemname||')' as displayField) ")
			.append("from ViewAppInfoVo s ")
			.append("order by s.appsysCode ");
		
		return getSession().createQuery(hql.toString()).list();
	}
	
	
	/**
	 * 查询服务器编号和服务器名称的映射集合
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object querySrvCodeNmMap(){
		StringBuilder hql = new StringBuilder();
		
		hql.append("select distinct new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	s.srvCode as valueField, ")
			.append("	s.srvCode||'('||s.serName||')' as displayField) ")
			.append("from TransItemVo t , ServerConfVo s ")
			.append("where t.aplCode = s.aplCode ")
			.append("order by s.srvCode");
		
		return getSession().createQuery(hql.toString()).list();
	}
	
	/**
	 * 根据应用系统编号查询科目三级分类
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryItemLevel3MapForRpt(String appsysCode,String itemLevel1,String itemLevel2){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
		.append("	ra.item_cd_app as valueField, ")
		.append("	ra.item_app_name as displayField) ")
		.append(" from RptItemAppVo ra ")
	.append(" where  ra.apl_code=? and ra.item_cd_lvl1=?  and ra.item_cd_lvl2=? ");
		
		return getSession().createQuery(hql.toString()).setString(0,appsysCode).setString(1,itemLevel1).setString(2,itemLevel2).list();
	}
	
	/**
	 * 根据应用系统编号查询科目二级分类
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryItemLevel2MapForRpt(String appsysCode,String itemLevel1){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
		.append("	ra.item_cd_lvl2 as valueField, ")
		.append("	rb.item_name as displayField) ")
		.append(" from RptItemAppVo ra,RptItemBaseVo rb ")
		.append(" where ra.item_cd_lvl2=rb.item_cd and rb.parent_item_cd=ra.item_cd_lvl1 ")
	.append(" and  ra.apl_code=? and ra.item_cd_lvl1=? ");
		
		return getSession().createQuery(hql.toString()).setString(0,appsysCode).setString(1,itemLevel1).list();
	}
	
	/**
	 * 根据应用系统编号查询科目一级分类	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryItemLevel1MapForRpt(String appsysCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append("	ra.item_cd_lvl1 as valueField, ")
			.append("	rb.item_name as displayField) ")
			.append(" from RptItemAppVo ra,RptItemBaseVo rb ")
			.append(" where ra.item_cd_lvl1=rb.item_cd and rb.parent_item_cd='NULL' ")
		.append(" and  ra.apl_code=? ");
		return getSession().createQuery(hql.toString()).setString(0,appsysCode).list();
	}
}

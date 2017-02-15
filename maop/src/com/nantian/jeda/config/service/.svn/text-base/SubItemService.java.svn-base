/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.config.service;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.SubItem;

/**
 * @author daizhenzhong
 * 
 */
@Service
@Repository
public class SubItemService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(SubItemService.class);

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;
	
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	public SubItemService() {
		fields.put("name", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param subItem
	 */
	@Transactional
	public void save(SubItem subItem) {
		getSession().save(subItem);
	}

	/**
	 * 批量保存.
	 * 
	 * @param subItems
	 */
	@Transactional
	public void save(Set<SubItem> subItems) {
		for (SubItem subItem : subItems) {
			getSession().save(subItem);
		}
	}

	/**
	 * 更新
	 * 
	 * @param subItem
	 */
	@Transactional
	public void update(SubItem subItem) {
		getSession().update(subItem);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(SubItem.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param subItem
	 */
	@Transactional
	public void delete(SubItem subItem) {
		getSession().delete(subItem);
	}

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<SubItem> findSubItem(String parent, Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(si.id as id,si.name as name,si.value as value,si.order as order,"
				+ "si.creator.name as creator,si.created as created,si.modifier.name as modifier,si.modified as modified) "
				+ "from SubItem si left join si.creator left join si.modifier where si.parent.id=:parent";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				hql += " and si." + key + " like :" + key;
			}
		}

		hql += ((sort == null || dir == null) ? " order by si.order asc" : " order by si." + sort + " " + dir);
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);
		query.setString("parent", parent);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	/**
	 * 获取数据字典配置项_不分页
	 * @param parent
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<SubItem> findSubItemAssign(String parent,Map<String, Object> params) {
		String hql = "select new map(si.id as id,si.name as name,si.value as value,si.order as order,"
				+ "si.creator.name as creator,si.created as created,si.modifier.name as modifier,si.modified as modified) "
				+ "from SubItem si left join si.creator left join si.modifier where si.parent.id=:parent";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				hql += " and si." + key + " like :" + key;
			}
		}

		hql += " order by si.order asc" ;
		Query query = getSession().createQuery(hql);
		query.setString("parent", parent);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 
	 * @param parent
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long findCount(String parent, Map<String, Object> params) {
		String hql = "select count(*) from SubItem si where si.parent.id=:parent ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				hql += " and si." + key + " like :" + key;
			}
		}
		Query query = getSession().createQuery(hql).setString("parent", parent);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 
	 * @param id
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(Long id) {
		return getSession()
				.createQuery(
						"select new map(si.id as id,si.name as name,si.value as value,si.parent.id as parent,si.order as order,si.version as version) "
								+ "from SubItem si where si.id =?").setLong(0, id).uniqueResult();
	}

	/**
	 * 
	 * @param itemId
	 * @param subitemValue
	 * @return
	 */
	@Transactional
	public Object findSubItem(String itemId, String subitemValue) {
		return getSession().createQuery("from SubItem si where si.parent.id = :itemId and si.value = :subitemValue").setString("itemId", itemId)
				.setString("subitemValue", subitemValue).uniqueResult();
	}

	/**
	 * 
	 * @param id
	 */
	private void deleteById(Long id) {
		getSession().createQuery("delete from SubItem si where si.id=?").setLong(0, id).executeUpdate();
	}

	/**
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(Long[] ids) {
		for (Long id : ids) {
			deleteById(id);
		}
	}

	/**
	 * 根据字典主项ID查询.
	 * 
	 * @param itemId 字典主项ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<SubItem> findEntityByItem(String itemId) {
		return getSession()
				.createQuery(
						"select new SubItem(si.id as id,si.name as name,si.value as value) from SubItem si where si.parent.id=? order by si.order asc")
				.setString(0, itemId).list();
	}
	
	/**
	 * 根据字典子项名称获取子项值
	 * @param itemName 字典子项名称
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<SubItem> findEntityByItemName(String itemName) {
		return getSession()
				.createQuery(
						"select new SubItem(si.id as id,si.name as name,si.value as value) from SubItem si where si.name=?")
				.setString(0, itemName).list();
	}

	/**
	 * 根据字典主项ID查询.
	 * 
	 * @param itemId 字典主项ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findMapByItem(String itemId) {
		return getSession()
				.createQuery("select new map(si.id as id,si.name as name,si.value as value,si.cascade as cascade) from SubItem si where si.parent=? ")
				.setString(0, itemId).list();
	}
	
	/**
	 * 查询数据字典所有信息.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public Map<String, String> findMap() {
		List<Map<String, String>> itemList = new ArrayList<Map<String, String>>();
		Map<String,String> itemMap = new HashMap<String,String>();
		
		StringBuilder sql = new StringBuilder();
		sql.append("   select name as \"name\", value as \"value\"  from ( ")
           .append("   select T.ITEM_ID || T.SUB_ITEM_VALUE as name, T.SUB_ITEM_NAME as value from jeda_sub_item t) o");
		System.out.println(sql);
		 SQLQuery query = getSession().createSQLQuery(sql.toString());
		 itemList=query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
		for (Map<String, String> map : itemList) {
			itemMap.put(map.get("name") , map.get("value"));
		}
		return  itemMap;
	}
	
	/**
	 * 根据字典主项ID查询配置项值
	 * @param itemId 字典主项ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<String> getSubItemByParentId(String itemId){
		return getSession()
				.createQuery("select distinct si.value from SubItem si where si.parent=? ")
				.setString(0, itemId)
				.list();
	}
	
	/**
	 * 获取平台环境（如：开发、测试、验证、生产）
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<String> getPlatformEnv(String itemId) {
		return getSession()
				.createQuery("select distinct si.value from SubItem si where si.parent=? ")
				.setString(0, itemId)
				.list();
	}
}

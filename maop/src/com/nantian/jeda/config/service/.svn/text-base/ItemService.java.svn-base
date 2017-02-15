/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.config.service;

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
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Item;

/**
 * 数据项服务.
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class ItemService {

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	public ItemService() {
		fields.put("id", FieldType.STRING);
		fields.put("name", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param item
	 */
	@Transactional
	public void save(Item item) {
		getSession().save(item);
	}

	/**
	 * 批量保存.
	 * 
	 * @param items
	 */
	@Transactional
	public void save(Set<Item> items) {
		for (Item item : items) {
			getSession().save(item);
		}
	}

	/**
	 * 更新.
	 * 
	 * @param item
	 */
	@Transactional
	public void update(Item item) {
		getSession().update(item);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Item.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param item
	 */
	@Transactional
	public void delete(Item item) {
		getSession().delete(item);
	}

	/**
	 * 根据翻页、排序和其他参数查询记录.
	 * 
	 * @param start 开始记录条数

	 * @param limit 返回记录条数
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> find(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(i.id as id,i.name as name,i.description as description,i.order as order,"
				+ "i.creator.name as creator,i.created as created,i.modifier.name as modifier,i.modified as modified) "
				+ "from Item i left join i.creator left join i.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and i." + key + " like :" + key;
				} else {
					hql += " and i." + key + " = :" + key;
				}
			}
		}

		hql += " order by i." + sort + " " + dir;
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	/**
	 * 根据参数查询记录.
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findCheckList(Map<String, Object> params) {
		String hql = "select new map(i.id as id,i.name as name,i.description as description,i.order as order,"
				+ "i.creator.name as creator,i.created as created,i.modifier.name as modifier,i.modified as modified) "
				+ "from Item i left join i.creator left join i.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and i." + key + " like :" + key;
				} else {
					hql += " and i." + key + " = :" + key;
				}
			}
		}
		hql += " order by i.name desc";
		Query query = getSession().createQuery(hql);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) {
		String hql = "select count(*) from Item where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		Query query = getSession().createQuery(hql);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findSubs(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(si.parent.id as pid,si.parent.name as pname,si.parent.description as pdescription,si.parent.order as porder,si.name as name,si.value as value,si.order as order) "
				+ "from SubItem si where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and si.parent." + key + " like :" + key;
				} else {
					hql += " and si.parent." + key + " = :" + key;
				}
			}
		}

		hql += " order by si.parent." + sort + " " + dir;
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		String hql = "select new map(i.id as id,i.name as name,i.description as description,i.order as order,i.version as version) from Item i where i.id =?";
		return getSession().createQuery(hql).setString(0, id).uniqueResult();
	}

	/**
	 * 返回所有数据项.用于ComboBox选择.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findPermissionItems() {
		String hql = "select new map(i.id as id,i.name as name,i.description as description,i.order as order,i.version as version) from Item i where i.permission = true";
		return getSession().createQuery(hql).list();
	}

	/**
	 * 查询数据子项.
	 * 
	 * @param id 数据项ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getSubMap(String id) {
		return getSession()
				.createQuery("select new map(si.name as name,si.value as value,si.cascade as cascade) from SubItem si where si.parent.id =? order by si.order asc")
				.setString(0, id).list();
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from SubItem si where si.parent.id=?").setString(0, id).executeUpdate();
		getSession().createQuery("delete from Item i where i.id=?").setString(0, id).executeUpdate();
	}

	/**
	 * 批量删除.
	 * 
	 * @param ids 主键数组
	 */
	@Transactional
	public void deleteByIds(String[] ids) {
		for (String id : ids) {
			deleteById(id);
		}
	}
	
	/**
	 * 根据数据主项ID与数据子项名称，获取数据子项值
	 * @param itemId 数据主项ID
	 * @param subItemName 数据子项名称
	 */
	@Transactional
	public String getSubItemValueByItemIdAndSubItemName(String itemId,String subItemName) {
		String val = "";
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.sub_item_value as \"sub_item_value\" ")
		   .append(" from jeda_sub_item t " ) 
		   .append(" where t.item_id =:item_id  ")
		   .append(" and t.sub_item_name =:sub_item_name ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setString("item_id", itemId)
								  .setString("sub_item_name", subItemName);
		if(query.list()!=null && query.list().size()>0){
			if(query.list().get(0)!=null){
				val = query.list().get(0).toString();
			}
		}
		return val;
	}
}

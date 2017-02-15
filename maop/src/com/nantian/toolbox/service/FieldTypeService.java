package com.nantian.toolbox.service;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.toolbox.vo.FieldTypeInfoVo;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */

@Service
@Repository
@Transactional
public class FieldTypeService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(FieldTypeService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/** 国际化资源 */
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	
	}
	@Autowired
    private SecurityUtils securityUtils; 

	/**
	 * 构造方法
	 */
	public FieldTypeService() {
		fields.put("field_id", FieldType.INTEGER);
		fields.put("field_type_direction", FieldType.STRING);
		fields.put("field_type_one", FieldType.STRING);
		fields.put("field_type_two", FieldType.STRING);
		fields.put("field_type_three", FieldType.STRING);
		fields.put("comments", FieldType.STRING);
		fields.put("filed_creator", FieldType.STRING);
		fields.put("field_created", FieldType.TIMESTAMP);
		fields.put("field_modifier", FieldType.STRING);
		fields.put("field_modified", FieldType.TIMESTAMP);
		
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void saveOrUpdate(FieldTypeInfoVo fieldTypeInfo) {
		getSession().saveOrUpdate(fieldTypeInfo);
	}


	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(FieldTypeInfoVo fieldTypeInfo) {
		getSession().save(fieldTypeInfo);
	}

	
	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(FieldTypeInfoVo fieldTypeInfo) {
		getSession().update(fieldTypeInfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<FieldTypeInfoVo> fieldTypeInfos) {
		for (FieldTypeInfoVo fieldTypeInfo : fieldTypeInfos) {
			getSession().save(fieldTypeInfo);
		}
	}


	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(FieldTypeInfoVo fieldTypeInfo) {
		getSession().delete(fieldTypeInfo);
	}

	

	/**
	 * 查询数据库中所有fieldTypeInfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<FieldTypeInfoVo> queryAllfieldTypeInfo() throws SQLException{
		return getSession().createQuery("from FieldTypeInfoVo t").list();
	}
	
	
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryFieldTypeInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ft.field_id as field_id,");
		hql.append("ft.field_type_direction as field_type_direction,");
		hql.append("ft.field_type_one as field_type_one,");
		hql.append("ft.field_type_two as field_type_two,");
		hql.append("ft.field_type_three as field_type_three,");
		hql.append("ft.comments as comments,");
		hql.append("ft.filed_creator as filed_creator,");
		hql.append("ft.filed_created as filed_created,");
		hql.append("ft.filed_modifier as filed_modifier,");
		hql.append("ft.filed_modified as filed_modified");
		hql.append(") from FieldTypeInfoVo ft  where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ft." + key + " like :" + key);
				} else {
					hql.append(" and ft." + key + " = :" + key);
				}
			}
		}
		
		
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
	public Long count(Map<String, Object> params)throws SQLException  {
 
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct count(*) from  FieldTypeInfoVo ft where 1=1 "); 
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ft." + key + " like :" + key);
				} else {
					hql.append(" and ft." + key + " = :" + key);
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
	 * 删除
	 * @param field_id
	 */
	public void deletefieldType(Integer field_id)throws SQLException  {
		getSession()
				.createQuery("delete from FieldTypeInfoVo ft where ft.field_id=?  ")
				.setInteger(0, field_id).executeUpdate();
	}
	/**
	 * 删除
	 * @param field_id
	 */
	private void deleteById(Integer field_id)throws SQLException  {
		getSession()
				.createQuery("delete from FieldTypeInfoVo ft where ft.field_id=?")
				.setInteger(0, field_id).executeUpdate();
	}

	/**
	 * 批量删除
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(Integer[] field_ids) throws SQLException {
		for(int i = 0; i < field_ids.length;i++){ 
			deleteById(field_ids[i]);
		}
	}

	/**
	 * 查找信息
	 * @return
	 */
	public FieldTypeInfoVo queryAllfieldTypeInfo(Integer field_id) {
		
		return  (FieldTypeInfoVo)getSession()
				.createQuery("from FieldTypeInfoVo ft where ft.field_id =? ")
				.setInteger(0, field_id).uniqueResult();
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFieldTypeone(String fieldType)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_one as \"field_type_one\"");
		sql.append(" from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='"+fieldType+"' ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFieldTypetwo(String fieldType)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_two as \"field_type_two\"");
		sql.append(" from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='"+fieldType+"' ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

}

package com.nantian.rept.service;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

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
import com.nantian.rept.vo.RptDatasourceConfVo;
import com.nantian.toolbox.vo.FieldTypeInfoVo;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */

@Service
@Repository
@Transactional
public class RptDatasourceConfService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(RptDatasourceConfService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/** 国际化资源 */
	
	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;
	
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	
	}
	@Autowired
    private SecurityUtils securityUtils; 
	@Resource(name = "sessionFactory")
	private SessionFactory sessionFactoryMaop;
	
	public Session getMaopSession() {
		return sessionFactoryMaop.getCurrentSession();
	
	}
	/**
	 * 构造方法
	 */
	public RptDatasourceConfService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("dataType", FieldType.STRING);
		fields.put("datasource", FieldType.STRING);
		
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void saveOrUpdate(RptDatasourceConfVo rptDatasourceConfVo) {
		getSession().saveOrUpdate(rptDatasourceConfVo);
	}


	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(RptDatasourceConfVo rptDatasourceConfVo) {
		getSession().save(rptDatasourceConfVo);
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
	public List<Map<String, Object>> query(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("a.aplCode as aplCode,");
		hql.append("a.dataType as dataType,");
		hql.append("a.datasource as datasource");
		hql.append(") from RptDatasourceConfVo a  where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and a." + key + " like :" + key);
				} else {
					hql.append(" and a." + key + " = :" + key);
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
	 * @param aplCode 
	 * @param field_id
	 */
	private void deleteById(String aplCode, Integer dataType)throws SQLException  {
		getSession()
				.createQuery("delete from RptDatasourceConfVo ft where ft.aplCode=? and ft.dataType=? ")
				.setString(0, aplCode).setInteger(1, dataType).executeUpdate();
	}

	/**
	 * 批量删除
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(String[] aplCodes,Integer[] dataTypes) throws SQLException {
		for(int i = 0; i < aplCodes.length && i < dataTypes.length; i++){ 
			deleteById(aplCodes[i],dataTypes[i]);
		}
	}

	/**
	 * 查找信息
	 * @return
	 */
	public RptDatasourceConfVo queryAllfieldTypeInfo(String aplCode, Integer dataType) {
		
		return  (RptDatasourceConfVo)getSession()
				.createQuery("from RptDatasourceConfVo ft where  ft.aplCode=? and ft.dataType=?  ")
				.setString(0, aplCode).setInteger(1, dataType).uniqueResult();
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getDatasource(String fieldType)throws SQLException {
		StringBuilder sql = new StringBuilder();
		if(fieldType.equals("0")){
			sql.append("   select name as \"name\", value as \"value\"  from ( ")
			.append("   select T.SUB_ITEM_VALUE as name, T.SUB_ITEM_NAME as value from jeda_sub_item t where  t.item_id = 'WEBLOGIC_DATASOURCE') o");	
		}
		if(fieldType.equals("1")){
			sql.append("   select name as \"name\", value as \"value\"  from ( ")
			.append("   select T.SUB_ITEM_VALUE as name, T.SUB_ITEM_NAME as value from jeda_sub_item t where  t.item_id = 'SYSTEM_DATASOURCE') o");	
		}
		Query query = getMaopSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

}

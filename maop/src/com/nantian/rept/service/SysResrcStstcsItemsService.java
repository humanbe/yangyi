package com.nantian.rept.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.SysResrcStstcsItemsVo;

@Service
@Repository
@Transactional
public class SysResrcStstcsItemsService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	
	private Session getSession(){
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	public SysResrcStstcsItemsService (){
		fields.put("aplCode", FieldType.STRING);
		fields.put("hostsType", FieldType.STRING);
		fields.put("activeHosts", FieldType.STRING);
		fields.put("hosts", FieldType.STRING);
	}
	
	/**
	 * 保存数据
	 * @param ststcdItems 数据对象
	 */
	@Transactional
	public void save(SysResrcStstcsItemsVo ststcdItems) {
		getSession().save(ststcdItems);
		
	}

	/**
	 * 更新.
	 * @param ststcdItems
	 */
	@Transactional
	public void update(SysResrcStstcsItemsVo ststcdItems) {
		getSession().update(ststcdItems);
		
	}

	/**
	 * 批量删除
	 * @param aplCodes 系统编号数组
	 * @param hostsTypes 类型数组
	 */
	public void deleteByUnionKeys(String[] aplCodes, String[] hostsTypes) {
		for(int i = 0; i < aplCodes.length && i < hostsTypes.length; i++){
			deleteByUnionKey(aplCodes[i], hostsTypes[i]);
		}
	}
	
	/**
	 * 删除
	 * @param appChangeId 主键
	 */
	@Transactional
	public void deleteByUnionKey(String aplCode, String hostsType) {
		getSession().createQuery("delete from SysResrcStstcsItemsVo t where t.aplCode = :aplCode and t.hostsType = :hostsType")
						  .setString("aplCode", aplCode)
						  .setString("hostsType", hostsType)
						  .executeUpdate();
		
	}
	
	/**
	 * 查询系统资源统计口径
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @param request
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<SysResrcStstcsItemsVo> querySysResrcStstcsItemsList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	t.hostsType as hostsType, ")
			.append("	t.activeHosts as activeHosts, ")
			.append("	t.hosts as hosts) ")
			.append("from SysResrcStstcsItemsVo t ")
			.append("where 1=1 ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and t." + key + " like :" + key);
				} else {
					hql.append(" and t." + key + " = :" + key);
				}
			}
		}
		
		hql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(hql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("ststcsItemsList4Export", query.list().size());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}
	
	/**
	 * 根据主键查询
	 * @param aplCode
	 * @param hostsType
	 * @return
	 */
	@Transactional(readOnly = true)
	public SysResrcStstcsItemsVo querySysResrcStstcsItems(String aplCode, String hostsType){
		return (SysResrcStstcsItemsVo) getSession().createQuery(
				"from SysResrcStstcsItemsVo t where t.aplCode = :aplCode and t.hostsType = :hostsType")
																			.setString("aplCode", aplCode)
																			.setString("hostsType", hostsType)
																			.uniqueResult();
		
	}
	
	/**
	 * 查询所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAplCodes() {
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from SysResrcStstcsItemsVo t order by t.aplCode").list();
	}
	
	/**
	 * 查询系统编号和系统名称的映射集合
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryAplCodeNm(){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append("	s.appsysCode as valueField, ")
			.append("	s.appsysCode||'('||s.systemname||')' as displayField) ")
			.append("from AplSystemVo s ")
			.append("order by s.appsysCode ");
		
		return getSession().createQuery(hql.toString()).list();
	}

}

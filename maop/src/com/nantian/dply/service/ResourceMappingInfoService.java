package com.nantian.dply.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.ResourceMappingInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author donghui
 *
 */
@Service
@Repository
@Transactional
public class ResourceMappingInfoService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ResourceMappingInfoService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法	 */
	public ResourceMappingInfoService() {
		fields.put("appsysCode", FieldType.STRING);
		fields.put("subAppsysCode", FieldType.STRING);
		fields.put("hostIp", FieldType.STRING);
		fields.put("environmentId", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
		fields.put("reserve2", FieldType.STRING);
		fields.put("reserve3", FieldType.STRING);
		fields.put("reserve4", FieldType.STRING);
		fields.put("reserve5", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ResourceMappingInfoVo resourcemappinginfo) {
		getSession().save(resourcemappinginfo);
	}
	
	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(ResourceMappingInfoVo resourcemappinginfo) {
		getSession().update(resourcemappinginfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ResourceMappingInfoVo> resourcemappinginfos) {
		for (ResourceMappingInfoVo resourcemappinginfo : resourcemappinginfos) {
			getSession().save(resourcemappinginfo);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * 
	 * @param resourcemappinginfos
	 */
	@Transactional
	public void saveOrUpdate(List<ResourceMappingInfoVo> resourcemappinginfos) {
		for (ResourceMappingInfoVo resourcemappinginfo : resourcemappinginfos) {
			getSession().saveOrUpdate(resourcemappinginfo);
		}
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param appsysCode 应用系统编号
	 * @param subAppsysCode 子系统编号	 * @param hostIp地址
	 * @param environmentId 环境ID
	 * @return ResourceMappingInfoVo 实体
	 */
	@Transactional(readOnly = true)
	public ResourceMappingInfoVo findByUnionKey(String appsysCode, String subAppsysCode, String hostIP, String environmentId){
		return (ResourceMappingInfoVo) getSession().createQuery("from ResourceMappingInfoVo rmi where rmi.appsysCode = :appsysCode and rmi.subAppsysCode = :subAppsysCode and rmi.hostIp = :hostIp and rmi.environmentId = :environmentId ")
														 .setString("appsysCode", appsysCode)
														 .setString("subAppsysCode", subAppsysCode)
														 .setString("hostIp", hostIP)
														 .setString("environmentId", environmentId)
														 .uniqueResult();
	}

	/**
	 * 删除
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ResourceMappingInfoVo resourcemappinginfo) {
		getSession().delete(resourcemappinginfo);
	}

	/**
	 * 查询数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ResourceMappingInfoVo> queryAll(String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from ResourceMappingInfoVo drm where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and drm." + key + " like :" + key);
				} else {
					hql.append(" and drm." + key + " = :" + key);
				}
			}
		}
		 hql.append(" and deleteFlag = '0'");
		 hql.append(" order by drm." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	
}///:~

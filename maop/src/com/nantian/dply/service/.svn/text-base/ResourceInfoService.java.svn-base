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
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.ResourceInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class ResourceInfoService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ResourceInfoService.class);

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
	public ResourceInfoService() {
		fields.put("appsysCode", FieldType.STRING);
		fields.put("subAppsysCode", FieldType.STRING);
		fields.put("resourceId", FieldType.STRING);
		fields.put("resourcePath", FieldType.STRING);
		fields.put("version", FieldType.INTEGER);
		fields.put("entryId", FieldType.STRING);
		fields.put("fileSize", FieldType.INTEGER);
		fields.put("fileOwner", FieldType.STRING);
		fields.put("fileLimits", FieldType.STRING);
		fields.put("fileModifyTime", FieldType.STRING);
		fields.put("deployStatus", FieldType.STRING);
		fields.put("deployTime", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(ResourceInfoVo resourceinfo) {
		getSession().save(resourceinfo);
	}
	
	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void update(ResourceInfoVo resourceinfo) {
		getSession().update(resourceinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(Set<ResourceInfoVo> resourceinfos) {
		for (ResourceInfoVo resourceinfo : resourceinfos) {
			getSession().save(resourceinfo);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * 
	 * @param resourceinfos
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(List<ResourceInfoVo> resourceinfos) {
		for (ResourceInfoVo resourceinfo : resourceinfos) {
			getSession().saveOrUpdate(resourceinfo);
		}
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param appsysCode 应用系统编号
	 * @param subAppsysCode 子系统编号
	 * @param resourceId 资源ID
	 * @param resourcePath 资源路径
	 * @return ResourceInfoVo 实体
	 */
	@Transactional(value = "dply", propagation=Propagation.NOT_SUPPORTED)
	public ResourceInfoVo findByUnionKey(String appsysCode, String subAppsysCode, String resourceId, String resourcePath){
		return (ResourceInfoVo) getSession().createQuery("from ResourceInfoVo ri where ri.appsysCode = :appsysCode and ri.subAppsysCode = :subAppsysCode and ri.resourceId = :resourceId and ri.resourcePath = :resourcePath ")
														 .setString("appsysCode", appsysCode)
														 .setString("subAppsysCode", subAppsysCode)
														 .setString("resourceId", resourceId)
														 .setString("resourcePath", resourcePath)
														 .uniqueResult();
	}

	/**
	 * 删除
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void delete(ResourceInfoVo resourceinfo) {
		getSession().delete(resourceinfo);
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
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "dply", propagation=Propagation.NOT_SUPPORTED)
	public List<ResourceInfoVo> queryAll(String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from ResourceInfoVo ri where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ri." + key + " like :" + key);
				} else {
					hql.append(" and ri." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by ri." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	
}///:~

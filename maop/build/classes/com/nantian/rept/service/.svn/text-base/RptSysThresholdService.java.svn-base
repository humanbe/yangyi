package com.nantian.rept.service;

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

import com.nantian.common.util.CommonConst;
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.RptSysThresholdVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class RptSysThresholdService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptSysThresholdService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法	 */
	public RptSysThresholdService() {
		fields.put("capacityItem", FieldType.STRING);
		fields.put("capacityType", FieldType.STRING);
		fields.put("onlineBatchType", FieldType.STRING);
		fields.put("capacityThreshold", FieldType.INTEGER);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(RptSysThresholdVo rptSysThresholdVo) {
		getSession().save(rptSysThresholdVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(RptSysThresholdVo rptSysThresholdVo) {
		getSession().update(rptSysThresholdVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<RptSysThresholdVo> rptSysThresholdVos) {
		for (RptSysThresholdVo rptSysThresholdVo : rptSysThresholdVos) {
			getSession().save(rptSysThresholdVo);
		}
	}
	
	/**
	 * 批量保存或者更新	 * @param rptSysThresholdVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<RptSysThresholdVo> rptSysThresholdVos) {
		for (RptSysThresholdVo rptSysThresholdVo : rptSysThresholdVos) {
			getSession().saveOrUpdate(rptSysThresholdVo);
		}
	}
	
	/**
	 * 保存或者更新	 * @param rptSysThresholdVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(RptSysThresholdVo rptSysThresholdVo) {
			getSession().saveOrUpdate(rptSysThresholdVo);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param capacityItem 容量科目名称
	 * @param capacityType 容量管理类型
	 * @param onlineBatchType 联机批量类型
	 * @return RptSysThresholdVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public RptSysThresholdVo findByUnionKey(String capacityItem, String capacityType, String onlineBatchType){
		return (RptSysThresholdVo) getSession()
				.createQuery("from RptSysThresholdVo rs where rs.capacityItem=:capacityItem and rs.capacityType=:capacityType and rs.onlineBatchType=:onlineBatchType ")
				.setString("capacityItem", capacityItem)
				.setString("capacityType", capacityType)
				.setString("onlineBatchType", onlineBatchType)
				.uniqueResult();
	}
	
	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(RptSysThresholdVo rptSysThresholdVo) {
		getSession().delete(rptSysThresholdVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param capacityItems
	 * @param capacityTypes
	 * @param onlineBatchTypes
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] capacityItems, String[] capacityTypes, String[] onlineBatchTypes) {
		for (int i = 0; i < capacityItems.length; i++) {
			deleteById(capacityItems[i],capacityTypes[i],onlineBatchTypes[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String capacityItem, String capacityType, String onlineBatchType) {
		getSession().createQuery("delete from RptSysThresholdVo rs where rs.onlineBatchType=? and rs.capacityType=? and rs.onlineBatchType=? ")
			.setString(0, capacityItem)
			.setString(1, capacityType)
			.setString(2, onlineBatchType)
			.executeUpdate();
	}
	
	/**
	 * 查询数据(分页)
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptSysThresholdVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from RptSysThresholdVo rs where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rs." + key + " like :" + key);
				} else {
					hql.append(" and rs." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by rs." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询数据
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptSysThresholdVo> queryRptSysThresholdList(Map<String, Object> params){
		StringBuilder hql = new StringBuilder();
		hql.append("from RptSysThresholdVo rs where 1=1 ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rs." + key + " like :" + key);
				} else {
					hql.append(" and rs." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}
	
	/**
	 * 查询数据（map<key组合,value）
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public Map<String,Object> queryRptSysThresholdMap(){
		Map<String,Object> map = new HashMap<String,Object>();
		StringBuilder hql = new StringBuilder();
		
		hql.append("from RptSysThresholdVo rs where 1=1 ");
		Query query = getSession().createQuery(hql.toString());
		List<RptSysThresholdVo> list = query.list();
		
		//编辑map<key,value> = <容量科目名称_容量管理类型_联机批量类型,容量伐值>
		 for (RptSysThresholdVo _vo : list) {
			 map.put(_vo.getCapacityItem().concat(CommonConst.UNDERLINE)
					 										.concat(_vo.getCapacityType())
					 										.concat(CommonConst.UNDERLINE)
					 										.concat(_vo.getOnlineBatchType()), _vo.getCapacityThreshold());
		}
		 return map;
	}
	
	
}///:~

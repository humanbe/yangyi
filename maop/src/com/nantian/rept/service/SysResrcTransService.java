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

import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.SysResrcTransVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class SysResrcTransService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(SysResrcTransService.class);

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
	public SysResrcTransService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("tranName", FieldType.STRING);
		fields.put("srvType", FieldType.STRING);
		fields.put("srvCode", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(SysResrcTransVo sysResrcTransVo) {
		getSession().save(sysResrcTransVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(SysResrcTransVo sysResrcTransVo) {
		getSession().update(sysResrcTransVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<SysResrcTransVo> sysResrcTransVos) {
		for (SysResrcTransVo sysResrcTransVo : sysResrcTransVos) {
			getSession().save(sysResrcTransVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param sysResrcTransVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<SysResrcTransVo> sysResrcTransVos) {
		for (SysResrcTransVo sysResrcTransVo : sysResrcTransVos) {
			getSession().saveOrUpdate(sysResrcTransVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param sysResrcTransVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(SysResrcTransVo sysResrcTransVo) {
			getSession().saveOrUpdate(sysResrcTransVo);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param srvCode 服务器编号
	 * @return SysResrcVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public SysResrcTransVo findByPrimaryKey(String aplCode,String tranName,String srvType,String srvCode){
		return (SysResrcTransVo) getSession()
				.createQuery("from sysResrcVo sr where sr.aplCode=:aplCode and sr.tranName=:tranName and sr.srvType=:srvType and sr.srvCode=:srvCode")
				.setString("aplCode", aplCode)
				.setString("tranName", tranName)
				.setString("srvType", srvType)
				.setString("srvCode", srvCode)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(SysResrcTransVo sysResrcTransVo) {
		getSession().delete(sysResrcTransVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String primaryKey) {
		String[] arr = primaryKey.split(",");
		deleteById(arr[0],arr[1],arr[2],arr[3]);
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode,String tranName,String srvType,String srvCode) {
		getSession().createQuery("delete from SysResrcTransVo sr where sr.aplCode=? and sr.transDate=? and sr.srvCode=? and sr.minPoint=?")
			.setString(0, aplCode)
			.setString(1, tranName)
			.setString(2, srvType)
			.setString(3, srvCode)
			.executeUpdate();
	}

	/**
	 * 查询数据
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<SysResrcTransVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from SysResrcTransVo sr where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and sr." + key + " like :" + key);
					} else {
						hql.append(" and sr." + key + " = :" + key);
					}
			}
		}
		hql.append(" order by sr." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询系统资源与交易量对照表数据
	 * @param aplCode 应用系统编号
	 * @param srvCode 服务器编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<SysResrcTransVo> findRptSysResrcTrans(String aplCode, String srvType, String srvCode){
		StringBuilder hql = new StringBuilder();
		hql.append("from SysResrcTransVo sr where 1=1 ")
			.append(" and sr.aplCode = :aplCode ")
			.append(" and sr.srvType = :srvType ")
			.append(" and sr.srvCode = :srvCode ");
		
		return getSession().createQuery(hql.toString())
									 .setString("aplCode", aplCode)
									 .setString("srvType", srvType)
									 .setString("srvCode", srvCode)
									 .list();
	}
	
	
}///:~

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

import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.DateTransVo;
import com.nantian.rept.vo.SysDateVo;
/**
 * @author donghui
 *
 */
@Service
@Repository
public class SysDateService {
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
	public SysDateService() {
		fields.put("sysDate", FieldType.STRING);
		fields.put("holidayFlag", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(SysDateVo sysDateVo) {
		getSession().save(sysDateVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(SysDateVo sysDateVo) {
		getSession().update(sysDateVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<SysDateVo> sysDateVos) {
		for (SysDateVo sysDateVo : sysDateVos) {
			getSession().save(sysDateVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param sysDateVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<SysDateVo> sysDateVos) {
		for (SysDateVo sysDateVo : sysDateVos) {
			getSession().saveOrUpdate(sysDateVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param sysDateVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(SysDateVo sysDateVo) {
			getSession().saveOrUpdate(sysDateVo);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param sysDate 日期
	 * @return SysDateVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public SysDateVo findByPrimaryKey(String sysDate){
		return (SysDateVo) getSession()
				.createQuery("from SysDateVo sd where sd.sysDate=:sysDate ")
				.setString("sysDate", sysDate)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(SysDateVo sysDateVo) {
		getSession().delete(sysDateVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String primaryKey) {
			deleteById(primaryKey);
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String sysDate) {
		getSession().createQuery("delete from SysDateVo sd where sd.sysDate=?")
			.setString(0, sysDate)
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
	public List<SysDateVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from SysDateVo sd where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and sd." + key + " like :" + key);
					} else {
						hql.append(" and sd." + key + " = :" + key);
					}
			}
		}
		hql.append(" order by sd." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
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
	public Map<String,String> queryAllHoliday(String startDate, String endDate) {

		Map<String,String> dataMap = new HashMap<String,String>();
		StringBuilder hql = new StringBuilder();
		
		hql.append("select to_char(to_date(sd.sys_date, 'yyyymmdd'), 'yyyy-mm-dd') as sys_date, ")
			.append(" 			sd.holiday_flag ")
			.append("from SYS_DATE sd where 1=1 ")
			.append(" and sd.sys_date between :startDate and :endDate");
		
		Query query = getSession().createSQLQuery(hql.toString()).addEntity(SysDateVo.class);

		query.setString("startDate", startDate)
				.setString("endDate", endDate);
		
		//查询全量数据
		List<SysDateVo> list = query.list();
		// 编辑数据到MAP
		for (SysDateVo vo : list) {
			dataMap.put(vo.getSysDate(), vo.getHolidayFlag());
		}
		//返回
		return dataMap;
	}
	
	
}///:~

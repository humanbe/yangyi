package com.nantian.dply.service;

import java.io.Serializable;
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
import com.nantian.dply.vo.AppChangeSummaryVo;

@Service
@Repository
@Transactional
public class AppChangeSummaryService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public AppChangeSummaryService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("changeDate", FieldType.STRING);
		fields.put("time", FieldType.STRING);
		fields.put("type", FieldType.STRING);
		fields.put("phenomenon", FieldType.STRING);
		fields.put("cause", FieldType.STRING);
		fields.put("handleMethod", FieldType.STRING);
		fields.put("improveMethod", FieldType.STRING);
	}

	/**
	 * 根据主键查询
	 * @param appChangeId
	 * @return
	 */
	@Transactional(readOnly = true)
	public AppChangeSummaryVo get(Serializable appChangeId){
		return (AppChangeSummaryVo) getSession().get(AppChangeSummaryVo.class, appChangeId);
	}
	
	/**
	 * 保存数据
	 * @param summaryVo 数据对象
	 */
	@Transactional
	public void save(AppChangeSummaryVo summaryVo) {
		getSession().save(summaryVo);
		
	}

	/**
	 * 更新.
	 * @param appChnageRiskEvalVo
	 */
	@Transactional
	public void update(AppChangeSummaryVo appChnageRiskEvalVo) {
		getSession().update(appChnageRiskEvalVo);
		
	}

	/**
	 * 批量删除
	 * @param appChangeId 主键数组
	 */
	public void deleteByIds(Long[] appChangeIds) {
		for(int i = 0; i < appChangeIds.length; i++){
			deleteById(appChangeIds[i]);
		}
	}
	
	/**
	 * 删除
	 * @param appChangeId 主键
	 */
	@Transactional
	public void deleteById(Long appChangeId) {
		getSession().createQuery("delete from AppChangeSummaryVo t where t.appChangeId = :appChangeId")
						  .setLong("appChangeId", appChangeId)
						  .executeUpdate();
		
	}

	/**
	 * 查询变更问题汇总信息
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @param request 请求对象
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeSummaryList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	s.systemname as sysName, ")
			.append("	t.changeDate as changeDate, ")
			.append("	t.time as time, ")
			.append("	t.type as type, ")
			.append("	t.phenomenon as phenomenon, ")
			.append("	t.cause as cause, ")
			.append("	t.handleMethod as handleMethod, ")
			.append("	t.improveMethod as improveMethod) ")
			.append("from AppChangeSummaryVo t, ViewAppInfoVo s where t.aplCode = s.appsysCode ");
		
		for(String key : params.keySet()){
			if(fields.get(key).equals(FieldType.STRING)){
				hql.append(" and t." + key + " like :" + key);
			}else{
				hql.append(" and t." + key + " = :" + key);
			}
		}
		
		hql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(hql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("appChangeSummaryList4Export", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 根据系统编号和变更日期查询
	 * @param appChangeId 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public AppChangeSummaryVo queryAppChangeSummaryInfo(Long appChangeId) {
		return (AppChangeSummaryVo) getSession().createQuery("from AppChangeSummaryVo t where t.appChangeId = :appChangeId")
																		.setLong("appChangeId", appChangeId)
																		.uniqueResult();
	}

	/**
	 * 根据系统编号查询最近一次的数据
	 * @param aplCode
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeSummaryInfo(String aplCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.time as time, ")
			.append("	t.type as type, ")
			.append("	t.phenomenon as phenomenon, ")
			.append("	t.cause as cause, ")
			.append("	t.handleMethod as handleMethod, ")
			.append("	t.improveMethod as improveMethod) ")
			.append("from AppChangeSummaryVo t, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append(" 	and t.aplCode = :aplCode ")
			.append("	and to_date(t.changeDate, 'yyyymmdd') = ")
			.append("		(select max(to_date(ta.changeDate, 'yyyymmdd')) ")
			.append("		 from AppChangeSummaryVo ta where ta.aplCode = t.aplCode) ");
		return getSession().createQuery(hql.toString()).setString("aplCode", aplCode).uniqueResult();
	}

	/**
	 * 根据变更日期查询
	 * @param changeMonth 变更月份
	 * @param aplCodes 系统代码列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeSummaryList(String changeMonth, List<String> aplCodes) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	s.systemname as sysName, ")
			.append("	t.time as time, ")
			.append("	t.type as type, ")
			.append("	t.phenomenon as phenomenon, ")
			.append("	t.cause as cause, ")
			.append("	t.handleMethod as handleMethod, ")
			.append("	t.improveMethod as improveMethod) ")
			.append("from AppChangeSummaryVo t, AppChangeVo a, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append("	and a.appChangeId = t.appChangeId  ")
			.append("	and a.changeDate like :changeMonth ")
			.append("	and t.aplCode in (:aplCodes)")
			.append("order by t.aplCode ASC ");
		
		return getSession().createQuery(hql.toString()).setString("changeMonth", changeMonth + "%").setParameterList("aplCodes", aplCodes).list();
	}

	/**
	 * 查询所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAplCodes() {
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from AppChangeSummaryVo t order by t.aplCode").list();
	}

}

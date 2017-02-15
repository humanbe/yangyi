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

import com.nantian.dply.vo.AppChangeRiskEvalVo;
import com.nantian.jeda.FieldType;

@Service
@Repository
@Transactional
public class AppChangeRiskEvalService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public AppChangeRiskEvalService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("changeDate", FieldType.STRING);
		fields.put("changeRiskEval", FieldType.STRING);
		fields.put("stopServiceTime", FieldType.STRING);
		fields.put("primaryChangeRisk", FieldType.STRING);
		fields.put("riskHandleMethod", FieldType.STRING);
		fields.put("other", FieldType.STRING);
	}

	/**
	 * 根据主键查询
	 * @param appChangeId
	 * @return
	 */
	@Transactional(readOnly = true)
	public AppChangeRiskEvalVo get(Serializable appChangeId){
		return (AppChangeRiskEvalVo) getSession().get(AppChangeRiskEvalVo.class, appChangeId);
	}
	
	/**
	 * 保存数据
	 * @param riskEvalVo 数据对象
	 */
	@Transactional
	public void save(AppChangeRiskEvalVo riskEvalVo) {
		getSession().save(riskEvalVo);
	}

	/**
	 * 更新.
	 * @param vo
	 */
	@Transactional
	public void update(AppChangeRiskEvalVo vo){
		getSession().update(vo);
	}
	
	/**
	 * 查询应用变更风险评估信息列表
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @param request 请求对象
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeRiskEvalList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	s.systemname as sysName, ")
			.append("	a.eapsCode as eapsCode, ")
			.append("	a.changeName as changeName, ")
			.append("	s.applicatemanagerA as appA, ")
			.append("	t.changeDate as changeDate, ")
			.append("	t.changeRiskEval as changeRiskEval, ")
			.append("	(case t.changeRiskEval when '1' then '低' when '2' then '中' when '3' then '高' end) as changeRiskEvalDisplay, ")
			.append("	t.stopServiceTime as stopServiceTime, ")
			.append("	t.primaryChangeRisk as primaryChangeRisk, ")
			.append("	t.riskHandleMethod as riskHandleMethod, ")
			.append("	t.other as other) ")
			.append("from AppChangeRiskEvalVo t, AppChangeVo a, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append("	and a.aplCode = t.aplCode  ")
			.append("	and a.planStartDate = t.changeDate ");
		
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
		
		request.getSession().setAttribute("appChangeRiskEvalList4Export", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 根据系统编号和变更日期查询
	 * @param appChangeId 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public AppChangeRiskEvalVo queryAppChangeRiskEvalInfo(Long appChangeId) {
		return (AppChangeRiskEvalVo) getSession().createQuery("from AppChangeRiskEvalVo t where t.appChangeId = :appChangeId")
																		.setLong("appChangeId", appChangeId)
																		.uniqueResult();
	}
	
	/**
	 * 根据系统编号查询最近一次的数据
	 * @param aplCode
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeRiskEvalInfo(String aplCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.changeRiskEval as changeRiskEval, ")
			.append("	t.stopServiceTime as stopServiceTime, ")
			.append("	t.primaryChangeRisk as primaryChangeRisk, ")
			.append("	t.riskHandleMethod as riskHandleMethod, ")
			.append("	t.other as other) ")
			.append("from AppChangeRiskEvalVo t, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append(" 	and t.aplCode = :aplCode ")
			.append("	and to_date(t.changeDate, 'yyyymmdd') = ")
			.append("		(select max(to_date(ta.changeDate, 'yyyymmdd')) ")
			.append("		 from AppChangeRiskEvalVo ta where ta.aplCode = t.aplCode) ");
		return getSession().createQuery(hql.toString()).setString("aplCode", aplCode).uniqueResult();
	}

	/**
	 * 批量删除
	 * @param appChangeIds 主键数组
	 */
	@Transactional
	public void deleteByIds(Long[] appChangeIds) {
		for(int i = 0; i < appChangeIds.length; i++){
			deleteById(appChangeIds[i]);
		}
	}
	
	/**
	 * 删除
	 * @param appChangeId  主键
	 */
	public void deleteById(Long appChangeId) {
		getSession().createQuery("delete from AppChangeRiskEvalVo t where t.appChangeId = :appChangeId")
						  .setLong("appChangeId", appChangeId)
						  .executeUpdate();
		
	}

	/**
	 * 根据变更日期查询
	 * @param changeMonth 变更月份
	 * @param aplCodes 系统代码列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeRiskEvalList(String changeMonth, List<String> aplCodes) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	s.systemname as sysName, ")
			.append("	a.eapsCode as eapsCode, ")
			.append("	a.changeName as changeName, ")
			.append("	s.applicatemanagerA as appA, ")
			.append("	(case t.changeRiskEval when '1' then '低' when '2' then '中' when '3' then '高' end) as changeRiskEval, ")
			.append("	t.stopServiceTime as stopServiceTime, ")
			.append("	t.primaryChangeRisk as primaryChangeRisk, ")
			.append("	t.riskHandleMethod as riskHandleMethod, ")
			.append("	t.other as other) ")
			.append("from AppChangeRiskEvalVo t, AppChangeVo a, ViewAppInfoVo s ")
			.append("where t.aplCode = s.appsysCode ")
			.append("	and a.appChangeId = t.appChangeId ")
			.append("	and a.aplCode in (:aplCodes)  ")
			.append("	and a.changeDate like :changeMonth ")
			.append("order by t.aplCode ASC ");
		
		return getSession().createQuery(hql.toString()).setString("changeMonth", changeMonth + "%").setParameterList("aplCodes", aplCodes).list();
	}

	/**
	 * 查询所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAplCodes() {
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from AppChangeRiskEvalVo t order by t.aplCode").list();
	}

}

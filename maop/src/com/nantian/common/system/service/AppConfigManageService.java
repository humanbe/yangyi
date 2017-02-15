package com.nantian.common.system.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;

@Service
@Repository
@Transactional
public class AppConfigManageService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public AppConfigManageService(){
		fields.put("sysId", FieldType.STRING);
		fields.put("sysName", FieldType.STRING);
		fields.put("operationsManager", FieldType.STRING);
		fields.put("sysA", FieldType.STRING);
		fields.put("sysB", FieldType.STRING);
		fields.put("appA", FieldType.STRING);
		fields.put("appB", FieldType.STRING);
		fields.put("projectLeader", FieldType.STRING);
		fields.put("sysStatus", FieldType.STRING);
		fields.put("department", FieldType.STRING);
		fields.put("serviceTime", FieldType.STRING);
		fields.put("disasterRecoverPriority", FieldType.STRING);
		fields.put("securityRank", FieldType.STRING);
		fields.put("groupName", FieldType.STRING);
		fields.put("outSourcingFlag", FieldType.STRING);
		fields.put("coreRank", FieldType.STRING);
		fields.put("importantRank", FieldType.STRING);
		fields.put("hingeRank", FieldType.STRING);
		fields.put("appType", FieldType.STRING);
		fields.put("appOutline", FieldType.STRING);
	}
	
	/**
	 * 查询应用系统及管理员分配信息
	 * @param start 起始记录数	 * @param limit 限制记录数	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @return 应用系统及管理员分配信息映射集合
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> queryAppSystemInfo(int start, int limit, String sort, String dir, Map<String, Object> params, HttpServletRequest request){
		StringBuilder sql = new StringBuilder();
		sql.append("select * ")
			.append("from (select t.id as \"sysId\", ")
            .append("   				t.sysname as \"sysName\", ")
            .append("   				t.manager as \"operationsManager\", ")
            .append("   				t.sysa as \"sysA\", ")
            .append("   				t.sysb as \"sysB\", ")
            .append("   				t.appa as \"appA\", ")
            .append("   				t.appb as \"appB\", ")
            .append("   				t.develop as \"projectLeader\", ")
            .append("   				t.flag as \"sysStatus\", ")
            .append("   				t.depart as \"department\", ")
            .append("   				t.fuwu as \"serviceTime\", ")
            .append("   				t.anquan \"disasterRecoverPriority\", ")
            .append("   				t.jibie as \"securityRank\", ")
            .append("					t.app_outline as \"appOutline\", ")
            .append("					case when t.app_type='1' then '平稳形' when  t.app_type='2' then  '震荡形' end as \"appType\", ")
            .append("   				(select groupname from cmn_member where username = t.appa) as \"groupName\", ")
            .append("   				(select '是' from cmn_member where username = t.appa) as \"takeOverFlag\", ")
            .append("   				(select '是' ")
            .append("      					from cmn_app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.hexin_jibie is not null) as \"coreRank\", ")
            .append("   				(select '是' ")
            .append("      					from cmn_app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.zhongyao_jibie is not null) as \"importantRank\", ")
            .append("   				(select '是' ")
            .append("      					from cmn_app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.guanjian_jibie is not null) as \"hingeRank\", ")
            .append("       			(select '是' from cmn_member where username = t.appa and flag = 2) as \"outSourcingFlag\", ")
            .append(" 					(select to_char(to_date(co.evaluate_month,'yyyyMM'),'yyyyMM') from ( ")
            .append("                      select c.*,row_number() over(partition by c.apl_code order by c.evaluate_month desc) rn from cmn_cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"evaluateMonth\", ")
            .append(" 					(select co.evaluate_result from ( ")
            .append("                      select c.*,row_number() over(partition by c.apl_code order by c.evaluate_month desc) rn from cmn_cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"evaluateResult\", ")
            .append(" 					(select co.level_cause_desc from ( ")
            .append("                      select c.*,row_number() over(partition by c.apl_code order by c.evaluate_month desc) rn from cmn_cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"levelCauseDesc\" ")
            .append(" 		from cmn_liebiao t) s")
            .append(" where 1=1 ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and \"" + key + "\" like :" + key);
				} else {
					sql.append(" and \"" + key + "\" = :" + key);
				}
			}
		}
		
		sql.append(" order by \"" + sort + "\" " + dir);
		
		Query query = getSession().createSQLQuery(sql.toString())
												.addScalar("sysId", StringType.INSTANCE)
												.addScalar("sysName", StringType.INSTANCE)
												.addScalar("operationsManager", StringType.INSTANCE)
												.addScalar("sysA", StringType.INSTANCE)
												.addScalar("sysB", StringType.INSTANCE)
												.addScalar("appA", StringType.INSTANCE)
												.addScalar("appB", StringType.INSTANCE)
												.addScalar("projectLeader", StringType.INSTANCE)
												.addScalar("sysStatus", StringType.INSTANCE)
												.addScalar("department", StringType.INSTANCE)
												.addScalar("serviceTime", StringType.INSTANCE)
												.addScalar("disasterRecoverPriority", StringType.INSTANCE)
												.addScalar("securityRank", StringType.INSTANCE)
												.addScalar("appOutline", StringType.INSTANCE)
												.addScalar("appType", StringType.INSTANCE)
												.addScalar("groupName", StringType.INSTANCE)
												.addScalar("takeOverFlag", StringType.INSTANCE)
												.addScalar("coreRank", StringType.INSTANCE)
												.addScalar("importantRank", StringType.INSTANCE)
												.addScalar("hingeRank", StringType.INSTANCE)
												.addScalar("outSourcingFlag", StringType.INSTANCE)
												.addScalar("evaluateMonth", StringType.INSTANCE)
												.addScalar("evaluateResult", StringType.INSTANCE)
												.addScalar("levelCauseDesc", StringType.INSTANCE)
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		//保存为导出或统计总条数使用
		request.getSession().setAttribute("appSystemInfos4Export", query.list());
	
		return query.setMaxResults(limit).setFirstResult(start).list();
	}
	
	/**
	 * 查询应用系统所有的编号
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNames(){
		return getSession().createQuery("select new map(s.sysId as sysId, s.sysName as sysName) from SystemInfoVo s order by s.sysId").list();
	}
	
	/**
	 * 查询所有系统的系统管理员A角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemAdminAs(){
		return getSession().createQuery("select distinct new map(s.sysA as sysA) from SystemInfoVo s order by s.sysA").list();
	}
	
	/**
	 * 查询所有系统的系统管理员B角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemAdminBs(){
		return getSession().createQuery("select distinct new map(s.sysB as sysB) from SystemInfoVo s order by s.sysB").list();
	}
	
	/**
	 * 查询所有系统的应用管理员A角及对应的组别.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppAdminAs(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appa as \"appA\", ")
			.append("						(select m.groupname from cmn_member m where t.appa = m.username) as \"groupName\" ")
			.append("from cmn_liebiao t ")
			.append("order by t.appa ");
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询所有系统的应用管理员B角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppAdminBs(){
		return getSession().createQuery("select distinct new map(s.appB as appB) from SystemInfoVo s order by s.appB").list();
	}
	
	/**
	 * 查询人员信息的所有组别
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryGroupNames(){
		return getSession().createQuery("select distinct new map(m.groupName as groupName) from MemberVo m order by m.groupName").list();
	}
	
}

package com.nantian.dply.service;

import java.io.IOException;
import java.io.Serializable;
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.jdom2.JDOMException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.NoSuchMessageException;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.ServletRequestDataBinder;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.Constants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.dply.vo.AppChangeRiskEvalVo;
import com.nantian.dply.vo.AppChangeSummaryVo;
import com.nantian.dply.vo.AppChangeVo;
import com.nantian.dply.vo.DplyRequestInfoVo;
import com.nantian.dply.vo.MonitorWarnVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 * 
 */
@Service
@Repository
@Transactional
public class AppChangeService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactory;
	
	@Autowired
	private AppChangeRiskEvalService appChangeRiskEvalService;
	
	@Autowired
	private AppChangeSummaryService appChangeSummaryService;
	
	@Autowired
	private MonitorWarnService monitorWarnService;
	
	@Autowired
	private DplyRequestInfoService dplyRequestInfoService;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public AppChangeService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("changeMonth", FieldType.STRING);
		fields.put("changeDate", FieldType.STRING);
		fields.put("operation", FieldType.STRING);
		fields.put("maintainTomo", FieldType.STRING);
		fields.put("changeDateStart", FieldType.STRING);
		fields.put("changeDateEnd", FieldType.STRING);
	}
	
	/**
	 * 查询应用系统及管理员分配信息列表
	 * @param start 起始记录数	 * @param limit 限制记录数	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @param request 请求对象
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeList(Integer start, Integer limit, String sort,
			String dir, Map<String, Object> params, HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map( ")
			.append("	t.appChangeId as appChangeId, ")
			.append("	t.aplCode as aplCode, ")
			.append("	s.systemname as sysName, ")
			.append("	t.changeMonth as changeMonth, ")
			.append("	t.changeDate as changeDate, ")
			.append("	t.eapsCode as eapsCode, ")
			.append("	t.changeName as changeName, ")
			.append("	t.changeGrantNo as changeGrantNo, ")
			.append("	t.dplyLocation as dplyLocation, ")
			.append("	t.planStartDate as planStartDate, ")
			.append("	t.planStartTime as planStartTime, ")
			.append("	t.actualStartTime as actualStartTime, ")
			.append("	t.planEndDate as planEndDate, ")
			.append("	t.planEndTime as planEndTime, ")
			.append("	t.actualEndDate as actualEndDate, ")
			.append("	t.actualEndTime as actualEndTime, ")
			.append("	t.endFlag as endFlag, ")
			.append("	(case t.endFlag when '0' then '否' when '1' then '是' when '2' then '部分' end) as endFlagDisplay, ")
			.append("	s.applicatemanagerA as appA, ")
			.append("	t.develop as develop, ")
			.append("	t.changeType as changeType, ")
			.append("	(case t.changeType when '1' then '常规投产' when '2' then '临时投产'  ")
			.append("		when '3' then '临时操作' when '4' then '紧急修复' end) as changeTypeDisplay, ")
			.append("	t.changeTable as changeTable, ")
			.append("	(case t.changeTable when '0' then '否' when '1' then '是' when '2' then '已归档' end) as changeTableDisplay, ")
			.append("	t.lastRebootDate as lastRebootDate, ")
			.append("	t.nowRebootTime as nowRebootTime, ")
			.append("	t.rebootExecInfo as rebootExecInfo, ")
			.append("	t.verifyInfo as verifyInfo, ")
			.append("	t.operationId as operationId, ")
			.append("	t.operation as operation, ")
			.append("	t.operationTel as operationTel, ")
			.append("	t.maintainTomo as maintainTomo, ")
			.append("	t.reviewerId as reviewerId, ")
			.append("	t.reviewer as reviewer, ")
			.append("	t.reviewerTel as reviewerTel) ")
			.append("from AppChangeVo t, ViewAppInfoVo s where t.aplCode = s.appsysCode ");
		
		if(params.containsKey("changeDateStart") && params.containsKey("changeDateEnd")){
			hql.append(" and t.changeDate between :changeDateStart and :changeDateEnd");
			params.put("changeDateStart", params.get("changeDateStart").toString().replaceAll("%", ""));
			params.put("changeDateEnd", params.get("changeDateEnd").toString().replaceAll("%", ""));
		}else{
			if(params.containsKey("changeDateStart") && !params.containsKey("changeDateEnd")){
				hql.append(" and t.changeDate >= :changeDateStart");
				params.put("changeDateStart", params.get("changeDateStart").toString().replaceAll("%", ""));
			}else if(!params.containsKey("changeDateStart") && params.containsKey("changeDateEnd")){
				hql.append(" and t.changeDate <= :changeDateEnd");
				params.put("changeDateEnd", params.get("changeDateEnd").toString().replaceAll("%", ""));
			}
		}
		if (params.keySet().size() > 0) {
				for (String key : params.keySet()) {
					if(!key.equals("changeDateStart") && !key.equals("changeDateEnd") ){
						if (fields.get(key).equals(FieldType.STRING)) {
							hql.append(" and t." + key + " like :" + key);
						} else {
							hql.append(" and t." + key + " = :" + key);
						}
					}
				}
			}
		hql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(hql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("appChangeList4Export", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 根据id获取实体
	 * @param appChangeId
	 * @return
	 */
	@Transactional(readOnly = true)
	public AppChangeVo get(Serializable appChangeId){
		return (AppChangeVo) getSession().get(AppChangeVo.class, appChangeId);
	}
	
	/**
	 * 根据id查询
	 * @param appChangeId 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeMap(Long appChangeId) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	t.changeMonth as changeMonth, ")
			.append("	t.changeDate as changeDate, ")
			.append("	t.eapsCode as eapsCode, ")
			.append("	t.changeName as changeName, ")
			.append("	t.changeGrantNo as changeGrantNo, ")
			.append("	t.dplyLocation as dplyLocation, ")
			.append("	t.planStartDate as planStartDate, ")
			.append("	t.planStartTime as planStartTime, ")
			.append("	t.actualStartTime as actualStartTime, ")
			.append("	t.planEndDate as planEndDate, ")
			.append("	t.planEndTime as planEndTime, ")
			.append("	t.actualEndDate as actualEndDate, ")
			.append("	t.actualEndTime as actualEndTime, ")
			.append("	t.develop as develop, ")
			.append("	t.endFlag as endFlag, ")
			.append("	t.changeType as changeType, ")
			.append("	t.changeTable as changeTable, ")
			.append("	t.lastRebootDate as lastRebootDate, ")
			.append("	t.nowRebootTime as nowRebootTime, ")
			.append("	t.rebootExecInfo as rebootExecInfo, ")
			.append("	t.verifyInfo as verifyInfo, ")
			.append("	t.operationId as operationId, ")
			.append("	t.operation as operation, ")
			.append("	t.operationTel as operationTel, ")
			.append("	t.maintainTomo as maintainTomo, ")
			.append("	t.reviewerId as reviewerId, ")
			.append("	t.reviewer as reviewer, ")
			.append("	t.reviewerTel as reviewerTel, ")
			.append("	r.changeRiskEval as changeRiskEval, ")
			.append("	r.stopServiceTime as stopServiceTime, ")
			.append("	r.primaryChangeRisk as primaryChangeRisk, ")
			.append("	r.riskHandleMethod as riskHandleMethod, ")
			.append("	r.other as other, ")
			.append("	s.time as time, ")
			.append("	s.type as type, ")
			.append("	s.phenomenon as phenomenon, ")
			.append("	s.cause as cause, ")
			.append("	s.handleMethod as handleMethod, ")
			.append("	s.improveMethod as improveMethod, ")
			.append("	m.monitorEffectContent as monitorEffectContent, ")
			.append("	m.deviceName as deviceName, ")
			.append("	m.ipAddress as ipAddress, ")
			.append("	m.explainDevice as explainDevice, ")
			.append("	m.explainMonitorPlatform as explainMonitorPlatform, ")
			.append("	m.explainMonitorTool as explainMonitorTool, ")
			.append("	m.explainMonitorScreen as explainMonitorScreen, ")
			.append("	m.effectStartDate as effectStartDate, ")			
			.append("	m.effectStartTime as effectStartTime, ")
			.append("	m.effectEndDate as effectEndDate, ")
			.append("	m.effectEndTime as effectEndTime) ")
			.append("from AppChangeVo t left join t.riskEval r left join t.summary s left join t.monitorWarn m ")
			.append("where t.appChangeId=:appChangeId");
		
		return getSession().createQuery(hql.toString())
									.setLong("appChangeId", appChangeId)
									.uniqueResult();
	}
	
	/**
	 * 根据变更月份查询
	 * @param changeMonth 变更月份
	 * @param aplCodes 系统代码列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeList(String changeMonth, List<String> aplCodes){
		StringBuilder sql = new StringBuilder();
		sql.append("select ")
			.append("	t.app_change_id as \"appChangeId\", ")
			.append("	s.systemname as \"sysName\", ")
			.append("	t.apl_code as \"aplCode\", ")
			.append("	t.change_month as \"changeMonth\", ")
			.append("	t.change_date as \"changeDate\", ")
			.append("	t.eaps_code as \"eapsCode\", ")
			.append("	t.change_name as \"changeName\", ")
			.append("	t.change_grant_no as \"changeGrantNo\", ")
			.append("	t.dply_location as \"dplyLocation\", ")
			.append("	t.plan_start_date as \"planStartDate\", ")
			.append("	t.plan_start_time as \"planStartTime\", ")
			.append("	t.actual_start_time as \"actualStartTime\", ")
			.append("	t.plan_end_date as \"planEndDate\", ")
			.append("	t.plan_end_time as \"planEndTime\", ")
			.append("	t.actual_end_date as \"actualEndDate\", ")
			.append("	t.actual_end_time as \"actualEndTime\", ")
			.append("	(case t.end_flag when '0' then '否' when '1' then '是' when '2' then '部分' end) as \"endFlag\", ")
			.append("	s.applicatemanagerA as \"appA\", ")
			.append("	t.develop as \"develop\", ")
			.append("	(select r.rn from ( ")
			.append("		select rank() over(order by t.apl_code, t.app_change_id) as rn, t.app_change_id ")
			.append("		 from app_change_risk_eval t, app_change a ")
			.append("		where a.change_date like :changeMonth ")
			.append("		 and a.app_change_id = t.app_change_id ) r ")
			.append("	 where t.app_change_id = r.app_change_id ) as \"primaryChangeRiskLink\", ")
			.append("	(case t.change_type when '1' then '常规投产' when '2' then '临时投产'  ")
			.append("		when '3' then '临时操作' when '4' then '紧急修复' end) as \"changeType\", ")
			.append("	(case t.change_table when '0' then '否' when '1' then '是' when '2' then '已归档' end) as \"changeTable\", ")
			.append("	t.last_reboot_date as \"lastRebootDate\", ")
			.append("	t.now_reboot_time as \"nowRebootTime\", ")
			.append("	t.reboot_exec_info as \"rebootExecInfo\", ")
			.append("	t.verify_info as \"verifyInfo\", ")
			.append("	t.operation_id as \"operationId\", ")
			.append("	t.operation as \"operation\", ")
			.append("	t.operation_tel as \"operationTel\", ")
			.append("	t.maintain_tomo as \"maintainTomo\", ")
			.append("	t.reviewer_id as \"reviewerId\", ")
			.append("	t.reviewer as \"reviewer\", ")
			.append("	t.reviewer_tel as \"reviewerTel\" ")
			.append("from APP_CHANGE t, V_CMN_APP_INFO s ")
			.append("where t.apl_code = s.appsys_code and t.change_date like :changeMonth and t.apl_code in (:aplCodes) ")
			.append("order by t.apl_code, t.app_change_id ASC");
		
		return getSession().createSQLQuery(sql.toString())
									 .addScalar("appChangeId", StringType.INSTANCE)
									 .addScalar("sysName", StringType.INSTANCE)
									 .addScalar("aplCode", StringType.INSTANCE)
									 .addScalar("changeMonth", StringType.INSTANCE)
									 .addScalar("changeDate", StringType.INSTANCE)
									 .addScalar("eapsCode", StringType.INSTANCE)
									 .addScalar("changeName", StringType.INSTANCE)
									 .addScalar("changeGrantNo", StringType.INSTANCE)
									 .addScalar("dplyLocation", StringType.INSTANCE)
									 .addScalar("planStartDate", StringType.INSTANCE)
									 .addScalar("planStartTime", StringType.INSTANCE)
									 .addScalar("actualStartTime", StringType.INSTANCE)
									 .addScalar("planEndDate", StringType.INSTANCE)
									 .addScalar("planEndTime", StringType.INSTANCE)
									 .addScalar("actualEndDate", StringType.INSTANCE)
									 .addScalar("actualEndTime", StringType.INSTANCE)
									 .addScalar("endFlag", StringType.INSTANCE)
									 .addScalar("appA", StringType.INSTANCE)
									 .addScalar("develop", StringType.INSTANCE)
									 .addScalar("primaryChangeRiskLink", StringType.INSTANCE)
									 .addScalar("changeType", StringType.INSTANCE)
									 .addScalar("changeTable", StringType.INSTANCE)
									 .addScalar("lastRebootDate", StringType.INSTANCE)
									 .addScalar("nowRebootTime", StringType.INSTANCE)
									 .addScalar("rebootExecInfo", StringType.INSTANCE)
									 .addScalar("verifyInfo", StringType.INSTANCE)
									 .addScalar("operationId", StringType.INSTANCE)
									 .addScalar("operation", StringType.INSTANCE)
									 .addScalar("operationTel", StringType.INSTANCE)
									 .addScalar("maintainTomo", StringType.INSTANCE)
									 .addScalar("reviewerId", StringType.INSTANCE)
									 .addScalar("reviewer", StringType.INSTANCE)
									 .addScalar("reviewerTel", StringType.INSTANCE)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .setString("changeMonth", "%" + changeMonth + "%")
									 .setParameterList("aplCodes", aplCodes)
									 .list();
	}
	
	/**
	 * 根据变更月份查询
	 * @param changeMonth 变更月份
	 * @param aplCodes 系统代码列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeListForChangeCalendar(String changeMonth, List<String> aplCodes){
		StringBuilder sql = new StringBuilder();
		sql.append(" select ")
			.append(" o.changeName as \"changeName\", ")
			.append(" o.aplCode as \"aplCode\", ")
			.append(" o.sysName as \"sysName\", ")
			.append(" o.riskGrade as \"riskGrade\", ")
			.append(" o.changeType as \"changeType\", ")
			.append(" o.eapsCode as \"eapsCode\", ")
			.append(" o.reviewGrade as \"reviewGrade\", ")
			.append(" o.planStartTime as \"planStartTime\", ")
			.append(" o.planEndTime as \"planEndTime\", ")
			.append(" o.planDescription as \"planDescription\", ")
			.append(" o.operationOrReviewer as \"operationOrReviewer\", ")
			.append(" o.userId as \"userId\", ")
			.append(" o.userTel as \"userTel\" ")
			.append(" from ( ")
			.append(" select ")
				.append(" t1.change_name as changeName, ")
				.append(" t1.apl_code as aplCode, ")
				.append(" s.systemname as sysName, ")
				.append(" '一般' as riskGrade, ")
				.append(" '应用.常规一般应用变更.常规业务功能模块' as changeType, ")
				.append(" T1.EAPS_CODE as eapsCode, ")
				.append(" '团队级' as reviewGrade, ")
				.append(" to_char(to_date(T1.PLAN_START_DATE,'yyyyMMdd'),'yyyy-MM-dd') || ' ' || to_char(to_date(T1.PLAN_START_TIME,'hh24:Mi:ss'),'hh24:Mi:ss') as planStartTime, ")
				.append(" to_char(to_date(T1.PLAN_END_DATE,'yyyyMMdd'),'yyyy-MM-dd') || ' ' || to_char(to_date(T1.PLAN_END_TIME,'hh24:Mi:ss'),'hh24:Mi:ss') as planEndTime, ")
				.append(" '' as planDescription, ")
				.append(" T1.OPERATION || '(执行人)' as operationOrReviewer, ")
				.append(" T1.OPERATION_ID as userId, ")
				.append(" T1.OPERATION_TEL as userTel, ")
				.append(" '1' as orderNum ")
			.append(" from app_change t1, V_CMN_APP_INFO s ")
			.append(" where t1.apl_code = s.appsys_code ")
				.append(" and t1.change_date like :changeMonth ")
				.append(" and t1.apl_code in (:aplCodes) ")
			.append(" union all ")
			.append(" select t1.change_name, ")
				.append(" t1.apl_code as aplCode, ")
				.append(" s.systemname as sysName, ")
				.append(" '一般' as riskGrade, ")
				.append(" '应用.常规一般应用变更.常规业务功能模块' as changeType, ")
				.append(" T1.EAPS_CODE as eapsCode, ")
				.append(" '团队级' as reviewGrade, ")
				.append(" to_char(to_date(T1.PLAN_START_DATE,'yyyyMMdd'),'yyyy-MM-dd') || ' ' || to_char(to_date(T1.PLAN_START_TIME,'hh24:Mi:ss'),'hh24:Mi:ss') as planStartTime, ")
				.append(" to_char(to_date(T1.PLAN_END_DATE,'yyyyMMdd'),'yyyy-MM-dd') || ' ' || to_char(to_date(T1.PLAN_END_TIME,'hh24:Mi:ss'),'hh24:Mi:ss') as planEndTime, ")
				.append(" '' as planDescription, ")
				.append(" T1.REVIEWER || '(复核人)' as operationOrReviewer, ")
				.append(" T1.REVIEWER_ID as userId, ")
				.append(" T1.REVIEWER_TEL as userTel, ")
				.append(" '2' as orderNum ")
			.append(" from app_change t1, V_CMN_APP_INFO s ")
			.append(" where t1.apl_code = s.appsys_code ")
				.append(" and t1.change_date like :changeMonth ")
				.append(" and t1.apl_code in (:aplCodes) ")
			.append(" ) o  ")
			.append(" order by o.aplCode,o.sysName,o.eapsCode,o.planStartTime,o.planEndTime,o.orderNum ");
   
		return getSession().createSQLQuery(sql.toString())
									 .addScalar("changeName", StringType.INSTANCE)
									 .addScalar("aplCode", StringType.INSTANCE)
									 .addScalar("sysName", StringType.INSTANCE)
									 .addScalar("riskGrade", StringType.INSTANCE)
									 .addScalar("changeType", StringType.INSTANCE)
									 .addScalar("eapsCode", StringType.INSTANCE)
									 .addScalar("reviewGrade", StringType.INSTANCE)
									 .addScalar("planStartTime", StringType.INSTANCE)
									 .addScalar("planEndTime", StringType.INSTANCE)
									 .addScalar("planDescription", StringType.INSTANCE)
									 .addScalar("operationOrReviewer", StringType.INSTANCE)
									 .addScalar("userId", StringType.INSTANCE)
									 .addScalar("userTel", StringType.INSTANCE)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .setString("changeMonth", "%" + changeMonth + "%")
									 .setParameterList("aplCodes", aplCodes)
									 .list();
	}

	/**
	 * 保存数据
	 * @param appChangeInfo 数据对象
	 */
	@Transactional
	public void save(AppChangeVo appChangeInfo) {
		getSession().save(appChangeInfo);
	}
	
	/**
	 * 保存对象
	 * @param appChangeInfo
	 * @param riskEvalVo
	 * @param summaryVo
	 * @param monitorWarnVo
	 * @throws URISyntaxException 
	 * @throws JDOMException 
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws NoSuchMessageException 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void save(AppChangeVo appChangeInfo, AppChangeRiskEvalVo riskEvalVo,
			AppChangeSummaryVo summaryVo, MonitorWarnVo monitorWarnVo,List<DplyRequestInfoVo> list) throws NoSuchMessageException, BrpmInvocationException, IOException, JDOMException, URISyntaxException {
		
		if(riskEvalVo.isValid(riskEvalVo)){
			riskEvalVo.setAppChange(appChangeInfo);
			appChangeInfo.setRiskEval(riskEvalVo);
			getSession().save(riskEvalVo);
		}
		
		if(summaryVo.isValid(summaryVo)){
			summaryVo.setAppChange(appChangeInfo);
			appChangeInfo.setSummary(summaryVo);
			getSession().save(summaryVo);
		}
		
		if(monitorWarnVo.isValid(monitorWarnVo)){
			monitorWarnVo.setAppChange(appChangeInfo);
			appChangeInfo.setMonitorWarn(monitorWarnVo);
			getSession().save(monitorWarnVo);
		}
		getSession().save(appChangeInfo);
		
		for(DplyRequestInfoVo vo :list){
			dplyRequestInfoService.updateArrange(vo);
			}
	}
	
	/**
	 * 主键不变时事务保存或更新
	 * @param appChangeVo
	 * @param appChangeRiskEvalVo
	 * @param appChangeSummaryVo
	 * @param monitorWarnVo
	 * @param request
	 * @throws URISyntaxException 
	 * @throws JDOMException 
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws NoSuchMessageException 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void saveOrUpdate(AppChangeVo appChangeVo,
			AppChangeRiskEvalVo appChangeRiskEvalVo,
			AppChangeSummaryVo appChangeSummaryVo, MonitorWarnVo monitorWarnVo,
			HttpServletRequest request,
			List<DplyRequestInfoVo> list) throws NoSuchMessageException, BrpmInvocationException, IOException, JDOMException, URISyntaxException {
		ServletRequestDataBinder appChangeBinder = new ServletRequestDataBinder(appChangeVo);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		
		sdf.setLenient(false);
		appChangeBinder.registerCustomEditor(Date.class, new CustomDateEditor(sdf, true));
	    appChangeBinder.bind(request);
	    update(appChangeVo);
		
	    AppChangeRiskEvalVo rvo = appChangeVo.getRiskEval();
		if(appChangeRiskEvalVo.isValid(appChangeRiskEvalVo)){
			if(rvo == null){
				appChangeRiskEvalVo.setAppChange(appChangeVo);
				appChangeRiskEvalService.save(appChangeRiskEvalVo);
			}else{
				ServletRequestDataBinder binder = new ServletRequestDataBinder(rvo);
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
				
				dateFormat.setLenient(false);
				binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
				//操作流水保存更新前数据
			    binder.bind(request);
			    appChangeRiskEvalService.update(rvo);
			}
		}else if(rvo != null){
			appChangeRiskEvalService.deleteById(rvo.getAppChangeId());
		}
		
		AppChangeSummaryVo svo = appChangeVo.getSummary();
		if(appChangeSummaryVo.isValid(appChangeSummaryVo)){
			if(svo == null){
				appChangeSummaryVo.setAppChange(appChangeVo);
				appChangeSummaryService.save(appChangeSummaryVo);
			}else{
				ServletRequestDataBinder binder = new ServletRequestDataBinder(svo);
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
				
				dateFormat.setLenient(false);
				binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
				//操作流水保存更新前数据
			    binder.bind(request);
			    appChangeSummaryService.update(svo);
			}
		}else if(svo != null){
			appChangeSummaryService.deleteById(svo.getAppChangeId());
		}
		
		MonitorWarnVo mvo = appChangeVo.getMonitorWarn();
		if(monitorWarnVo.isValid(monitorWarnVo)){
			if(mvo == null){
				monitorWarnVo.setAppChange(appChangeVo);
				monitorWarnService.save(monitorWarnVo);
			}else{
				ServletRequestDataBinder binder = new ServletRequestDataBinder(mvo);
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
				
				dateFormat.setLenient(false);
				binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
				//操作流水保存更新前数据
			    binder.bind(request);
			    monitorWarnService.update(mvo);
			}
		}else if(mvo != null){
			monitorWarnService.deleteById(mvo.getAppChangeId());
		}
		for(DplyRequestInfoVo vo :list){
			dplyRequestInfoService.updateArrange(vo);
			}
		
	}
	
	/**
	 * 更新.
	 * @param vo
	 */
	@Transactional
	public void update(AppChangeVo vo){
		getSession().update(vo);
	}
	
	/**
	 * 查询所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAplCodes() {
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from AppChangeVo t order by t.aplCode").list();
	}

	/**
	 * 查询某变更月份所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAplCodes4ChangeMonth(String changeMonth) {
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from AppChangeVo t where t.changeMonth = :changeMonth order by t.aplCode")
									 .setString("changeMonth", changeMonth)
									 .list();
	}

	/**
	 * 通过查询最新的历史变更实例来返回常用属性的实例
	 * @param aplCode
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryLastestAppChangeInfo(String aplCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	si.appsysCode as aplCode, ")
			.append("	t.eapsCode as eapsCode, ")
			.append("	t.changeName as changeName, ")
			.append("	t.dplyLocation as dplyLocation, ")
			.append("	t.planStartTime as planStartTime, ")
			.append("	t.planEndTime as planEndTime, ")
			.append("	t.develop as develop, ")
			.append("	t.changeType as changeType, ")
			.append("	t.changeTable as changeTable, ")
			.append("	t.nowRebootTime as nowRebootTime, ")
			.append("	t.operationId as operationId, ")
			.append("	t.operation as operation, ")
			.append("	t.operationTel as operationTel, ")
			.append("	t.maintainTomo as maintainTomo, ")
			.append("	t.reviewerId as reviewerId, ")
			.append("	t.reviewer as reviewer, ")
			.append("	t.reviewerTel as reviewerTel, ")
			.append("	r.changeRiskEval as changeRiskEval, ")
			.append("	r.stopServiceTime as stopServiceTime, ")
			.append("	r.primaryChangeRisk as primaryChangeRisk, ")
			.append("	r.riskHandleMethod as riskHandleMethod, ")
			.append("	r.other as other, ")
			.append("	s.time as time, ")
			.append("	s.type as type, ")
			.append("	s.phenomenon as phenomenon, ")
			.append("	s.cause as cause, ")
			.append("	s.handleMethod as handleMethod, ")
			.append("	s.improveMethod as improveMethod, ")
			.append("	m.monitorEffectContent as monitorEffectContent, ")
			.append("	m.deviceName as deviceName, ")
			.append("	m.ipAddress as ipAddress, ")
			.append("	m.explainDevice as explainDevice, ")
			.append("	m.explainMonitorPlatform as explainMonitorPlatform, ")
			.append("	m.explainMonitorTool as explainMonitorTool, ")
			.append("	m.explainMonitorScreen as explainMonitorScreen, ")
			.append("	m.effectStartDate as effectStartDate, ")
			.append("	m.effectStartTime as effectStartTime, ")
			.append("	m.effectEndDate as effectEndDate, ")
			.append("	m.effectEndTime as effectEndTime) ")
			.append("from AppChangeVo t left join t.riskEval r left join t.summary s left join t.monitorWarn m, ViewAppInfoVo si ")
			.append("where t.aplCode = si.appsysCode ")
			.append(" 	and t.aplCode = :aplCode ")
			.append("	and t.appChangeId = ")
			.append("		(select max(appChangeId) ")
			.append("		 from AppChangeVo ta where ta.aplCode = t.aplCode) ");
		return getSession().createQuery(hql.toString()).setString("aplCode", aplCode).uniqueResult();
	}
	
	/**
	 * 查询投产时间
	 * @param aplCode
	 * @param changeDate
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryPlanTime(String aplCode, String changeDate) {
		return getSession().createQuery(
				"select new map(t.planStartTime as planStartTime, t.planEndTime as planEndTime) from AppChangeVo t where t.aplCode = :aplCode and t.planStartDate = :changeDate")
									.setString("aplCode", aplCode)
									.setString("changeDate", changeDate)
									.uniqueResult();
	}

	/**
	 * 批量删除
	 * @param appChangeIds
	 */
	@Transactional
	public void deleteByIds(Long[] appChangeIds) {
		for (Long id : appChangeIds) {
			deleteById(id);
		}
		
	}

	/**
	 * 删除
	 * @param id
	 */
	private void deleteById(Long id) {
		getSession().createQuery("delete from AppChangeVo where appChangeId=?").setLong(0, id).executeUpdate();
		
	}

	/**
	 * 按变更月份查询变更进度情况汇总
	 * @param changeMonth
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeProgress(String changeMonth) {
		StringBuilder sql = new StringBuilder();
		sql.append("select tmp.change_month as \"changeMonth\", ")
			.append("        tmp.status as \"status\",  ")
			.append("        tmp.progress as \"progress\",  ")
			.append("        count(*) as \"statistical\", ")
			.append("        wm_concat(apl_code) as \"aplCodes\" ")
			.append("   from (select p.apl_code, ")
			.append("                p.status, ")
			.append("                (case ")
			.append("                  when p.status = '未开始' and ")
			.append("                       sysdate <= ")
			.append("                       to_date(p.plan_start_date || p.plan_start_time, ")
			.append("                               'yyyymmddhh24:mi') then '正常进度' ")
			.append("                  when p.status = '未开始' and ")
			.append("                       sysdate > ")
			.append("                       to_date(p.plan_start_date || p.plan_start_time, ")
			.append("                               'yyyymmddhh24:mi') then '超出进度' ")
			.append("                  when p.status = '进行中' and ")
			.append("                       sysdate <= to_date(p.plan_end_date || p.plan_end_time, ")
			.append("                                          'yyyymmddhh24:mi') then '正常进度' ")
			.append("                  when p.status = '进行中' and ")
			.append("                       sysdate > to_date(p.plan_end_date || p.plan_end_time, ")
			.append("                                         'yyyymmddhh24:mi') then '超出进度' ")
			.append("                  when p.status = '已完成' and ")
			.append("                       to_date(p.actual_end_date || p.actual_end_time, ")
			.append("                               'yyyymmddhh24:mi') <= ")
			.append("                       to_date(p.plan_end_date || p.plan_end_time, ")
			.append("                               'yyyymmddhh24:mi') then '正常进度' ")
			.append("                  when p.status = '已完成' and ")
			.append("                       to_date(p.actual_end_date || p.actual_end_time, ")
			.append("                               'yyyymmddhh24:mi') > ")
			.append("                       to_date(p.plan_end_date || p.plan_end_time, ")
			.append("                               'yyyymmddhh24:mi') then '超出进度' ")
			.append("                end) as progress, ")
			.append("                p.change_month, ")
			.append("                p.plan_start_date, ")
			.append("                p.plan_start_time, ")
			.append("                p.plan_end_date, ")
			.append("                p.plan_end_time, ")
			.append("                p.actual_start_time, ")
			.append("                p.actual_end_date, ")
			.append("                p.actual_end_time ")
			.append("           from (select t.*, ")
			.append("                        (case ")
			.append("                          when t.actual_start_time is null then '未开始' ")
			.append("                          when t.actual_start_time is not null and ")
			.append("                               t.actual_end_time is null then '进行中' ")
			.append("                          when t.actual_start_time is not null and ")
			.append("                               t.actual_end_time is not null then '已完成' ")
			.append("                        end) as status ")
			.append("                   from app_change t ")
			.append("                  where t.change_month = :changeMonth ")
			.append("                  order by t.apl_code) p) tmp ")
			.append("  group by tmp.change_month,tmp.status, tmp.progress ")
			.append("  order by tmp.status, tmp.progress desc ");

		return getSession().createSQLQuery(sql.toString())
									.addScalar("changeMonth", StringType.INSTANCE)
									.addScalar("status", StringType.INSTANCE)
									.addScalar("progress", StringType.INSTANCE)
									.addScalar("statistical", StringType.INSTANCE)
									.addScalar("aplCodes", StringType.INSTANCE)
									.setString("changeMonth", changeMonth)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}

	/**
	 * 查询变更进度情况详细
	 * @param changeMonth 变更月份
	 * @param aplCodes 系统编码集
	 * @param status 状态
	 * @param progress 进度
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppChangeProgressDetail(String changeMonth,
			String aplCodes, String status, String progress) {
		StringBuilder sql = new StringBuilder();
		sql.append("select 	tmp.app_change_id as \"appChangeId\", ")
			.append("		  s.systemname as \"sysName\", ")
			.append("		  tmp.apl_code as \"aplCode\", ")
			.append("        tmp.change_month as \"changeMonth\", ")
			.append("        tmp.change_date as \"changeDate\", ")
			.append("        tmp.eaps_code as \"eapsCode\", ")
			.append("        tmp.change_name as \"changeName\", ")
			.append("        tmp.change_grant_no as \"changeGrantNo\", ")
			.append("        tmp.dply_location as \"dplyLocation\", ")
			.append("        tmp.plan_start_date as \"planStartDate\", ")
			.append("        tmp.plan_start_time as \"planStartTime\", ")
			.append("        tmp.actual_start_time as \"actualStartTime\", ")
			.append("        tmp.plan_end_date as \"planEndDate\", ")
			.append("        tmp.plan_end_time as \"planEndTime\", ")
			.append("        tmp.actual_end_date as \"actualEndDate\", ")
			.append("        tmp.actual_end_time as \"actualEndTime\", ")
			.append("        (case tmp.end_flag when '0' then '否' when '1' then '是' when '2' then '部分' end) as \"endFlag\", ")
			.append("        s.applicatemanagerA as \"appA\", ")
			.append("        tmp.develop as \"develop\", ")
			.append("        (case tmp.change_type when '1' then '常规投产' when '2' then '临时投产'  ")
			.append("          when '3' then '临时操作' when '4' then '紧急修复' end) as \"changeType\", ")
			.append("        (case tmp.change_table when '0' then '否' when '1' then '是' when '2' then '已归档' end) as \"changeTable\", ")
			.append("        tmp.last_reboot_date as \"lastRebootDate\", ")
			.append("        tmp.now_reboot_time as \"nowRebootTime\", ")
			.append("        tmp.reboot_exec_info as \"rebootExecInfo\", ")
			.append("        tmp.verify_info as \"verifyInfo\", ")
			.append("        tmp.operation_id as \"operationId\", ")
			.append("        tmp.operation as \"operation\", ")
			.append("        tmp.operation_tel as \"operationTel\", ")
			.append("        tmp.maintain_tomo as \"maintainTomo\", ")
			.append("        tmp.reviewer_id as \"reviewerId\", ")
			.append("        tmp.reviewer as \"reviewer\", ")
			.append("        tmp.reviewer_tel as \"reviewerTel\" ")
			.append("  from (select p.*,")
			.append("               (case")
			.append("                 when p.status = '未开始' and")
			.append("                      sysdate <=")
			.append("                      to_date(p.plan_start_date || p.plan_start_time,")
			.append("                              'yyyymmddhh24:mi') then '正常进度'")
			.append("                 when p.status = '未开始' and")
			.append("                      sysdate >")
			.append("                      to_date(p.plan_start_date || p.plan_start_time,")
			.append("                              'yyyymmddhh24:mi') then '超出进度'")
			.append("                 when p.status = '进行中' and")
			.append("                      sysdate <= to_date(p.plan_end_date || p.plan_end_time,")
			.append("                                         'yyyymmddhh24:mi') then '正常进度'")
			.append("                 when p.status = '进行中' and")
			.append("                      sysdate > to_date(p.plan_end_date || p.plan_end_time,")
			.append("                                        'yyyymmddhh24:mi') then '超出进度'")
			.append("                 when p.status = '已完成' and")
			.append("                      to_date(p.actual_end_date || p.actual_end_time,")
			.append("                              'yyyymmddhh24:mi') <=")
			.append("                      to_date(p.plan_end_date || p.plan_end_time,")
			.append("                              'yyyymmddhh24:mi') then '正常进度'")
			.append("                 when p.status = '已完成' and")
			.append("                      to_date(p.actual_end_date || p.actual_end_time,")
			.append("                              'yyyymmddhh24:mi') >")
			.append("                      to_date(p.plan_end_date || p.plan_end_time,")
			.append("                              'yyyymmddhh24:mi') then '超出进度'")
			.append("               end) as progress")
			.append("          from (select t.*,")
			.append("                       (case")
			.append("                         when t.actual_start_time is null then '未开始'")
			.append("                         when t.actual_start_time is not null and")
			.append("                              t.actual_end_time is null then '进行中'")
			.append("                         when t.actual_start_time is not null and")
			.append("                              t.actual_end_time is not null then '已完成'")
			.append("                       end) as status")
			.append("                  from app_change t")
			.append("                 where t.change_month = :changeMonth ")
			.append("                 order by t.apl_code) p) tmp, V_CMN_APP_INFO s ")
			.append(" where tmp.apl_code = s.appsys_code ")
			.append(" and tmp.status = :status and tmp.progress = :progress ")
			.append(" and tmp.apl_code in (:aplCodes) ")
			.append(" order by tmp.apl_code ");
		
		return getSession().createSQLQuery(sql.toString())
									 .addScalar("appChangeId", StringType.INSTANCE)
									 .addScalar("sysName", StringType.INSTANCE)
									 .addScalar("aplCode", StringType.INSTANCE)
									 .addScalar("changeMonth", StringType.INSTANCE)
									 .addScalar("changeDate", StringType.INSTANCE)
									 .addScalar("eapsCode", StringType.INSTANCE)
									 .addScalar("changeName", StringType.INSTANCE)
									 .addScalar("changeGrantNo", StringType.INSTANCE)
									 .addScalar("dplyLocation", StringType.INSTANCE)
									 .addScalar("planStartDate", StringType.INSTANCE)
									 .addScalar("planStartTime", StringType.INSTANCE)
									 .addScalar("actualStartTime", StringType.INSTANCE)
									 .addScalar("planEndDate", StringType.INSTANCE)
									 .addScalar("planEndTime", StringType.INSTANCE)
									 .addScalar("actualEndDate", StringType.INSTANCE)
									 .addScalar("actualEndTime", StringType.INSTANCE)
									 .addScalar("endFlag", StringType.INSTANCE)
									 .addScalar("appA", StringType.INSTANCE)
									 .addScalar("develop", StringType.INSTANCE)
									 .addScalar("changeType", StringType.INSTANCE)
									 .addScalar("changeTable", StringType.INSTANCE)
									 .addScalar("lastRebootDate", StringType.INSTANCE)
									 .addScalar("nowRebootTime", StringType.INSTANCE)
									 .addScalar("rebootExecInfo", StringType.INSTANCE)
									 .addScalar("verifyInfo", StringType.INSTANCE)
									 .addScalar("operationId", StringType.INSTANCE)
									 .addScalar("operation", StringType.INSTANCE)
									 .addScalar("operationTel", StringType.INSTANCE)
									 .addScalar("maintainTomo", StringType.INSTANCE)
									 .addScalar("reviewerId", StringType.INSTANCE)
									 .addScalar("reviewer", StringType.INSTANCE)
									 .addScalar("reviewerTel", StringType.INSTANCE)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .setString("changeMonth", changeMonth)
									 .setString("status", status)
									 .setString("progress", progress)
									 .setParameterList("aplCodes", Arrays.asList(aplCodes.split(",")))
									 .list();
	}
	
	
	
	
	/**
	 * 获取请求数据
	 * 
	 * @param appsysCode
	 *        应用系统
	 * @param changeDate
	 *        变更日期
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryRequestByAppCode(String appsysCode, String changeDate)throws SQLException  {

			StringBuilder sql = new StringBuilder();
			
	    	sql.append("select  o.appSysCode as \"appSysCode\",")
			.append("o.requestCode as \"requestCode\", ")
			.append(" o.planDeployDate as \"planDeployDate\", ")
			.append("o.deployCode as \"deployCode\", ")
			.append("o.requestName as \"requestName\", ")
			.append("o.environment as \"environment\", ")
			.append("o.trunSwitch as \"trunSwitch\", ")
			.append("o.execStatus as \"execStatus\", ")
			.append("o.planStartTime as \"planStartTime\", ")
			.append("o.planEndTime as \"planEndTime\", ")
			.append("o.realStartDate as \"realStartDate\", ")
			.append(" o.realEndDate as \"realEndDate\", ")
			.append(" o.autostart as \"autostart\", ")
			.append("(case when o.deployCode is not null  then 'true' else 'false' end) as \"checked\" , ")
			.append(" o.requestStatus as \"requestStatus\" ")
			.append(" from (  ")
			.append(" select b.appsys_code as appSysCode,  ")
			.append(" b.request_code as requestCode,")
			.append(" b.environment as environment,")
			.append(" b.plan_deploy_date as planDeployDate,")
			.append(" b.deploy_code as deployCode,")
			.append(" b.request_name as requestName,")
			.append("   b.turn_switch as trunSwitch,  ")
			.append("  b.exec_status as execStatus,  ")
			.append("  b.plan_start_time as planStartTime,  ")
			.append("  b.plan_end_time as planEndTime,  ")
			.append("  b.real_start_date as realStartDate,  ")
			.append("  b.real_end_date as realEndDate,  ")
			.append("  b.autostart as autostart,  ")
			.append("  substr(b.request_name,instr(b.request_name,'_',1,1)+1,instr(b.request_name,'_',1,2)-1-instr(b.request_name,'_',1,1))  as requestStatus ")
			.append(" from dply_request_info b) o where  o.appSysCode = :appsysCode and o.requestCode like ")
			.append("'%")
	    	.append(changeDate)
	    	.append("%'");
			Query query = getSession().createSQLQuery(sql.toString())
					.addScalar("appSysCode", StringType.INSTANCE)
					.addScalar("requestCode", StringType.INSTANCE)
					.addScalar("planDeployDate", StringType.INSTANCE)
					.addScalar("deployCode", StringType.INSTANCE)
					.addScalar("requestName", StringType.INSTANCE)
					.addScalar("environment", StringType.INSTANCE)
					.addScalar("trunSwitch", StringType.INSTANCE)
					.addScalar("execStatus", StringType.INSTANCE)
					.addScalar("planStartTime", StringType.INSTANCE)
					.addScalar("planEndTime", StringType.INSTANCE)
					.addScalar("realStartDate", TimestampType.INSTANCE)
					.addScalar("realEndDate", TimestampType.INSTANCE)
					.addScalar("requestStatus", StringType.INSTANCE)
					.addScalar("autostart", StringType.INSTANCE)
					.addScalar("checked", StringType.INSTANCE)
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			query.setString("appsysCode", appsysCode);
			return  query.list();
 
		
	}
	
	/**
	 * 获取请求数据
	 * 
	 * @param appsysCode
	 *        应用系统
	 * @param requestslist
	 *        请求列表
	 *        
	 * @return
	 */
	 @Transactional(readOnly = true)
	public List<DplyRequestInfoVo> getRequests(String appsys_code,
			List<String> requestslist) {
		List<DplyRequestInfoVo> list = new ArrayList<DplyRequestInfoVo>();
		
		for (String mapserver : requestslist) {
			
			String requestcode=ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[5]);
			String env=ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[4]);
			DplyRequestInfoVo vo= dplyRequestInfoService.queryDplyRequestInfo(appsys_code,requestcode,env);
	
			vo.setDeployCode(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[0]));
			vo.setPlanDeployDate(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[1]));
			vo.setPlanStartTime(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[2]));
			vo.setPlanEndTime(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[3]));
			list.add(vo);
		}
		return list;
	}

	 /**
	  * 
	  * @param appsysCode
	  * @param loginUser
	  * @return
	  */
	 @Transactional(readOnly = true)
	 public Object hide(String appsysCode, String loginUser){
		
		 return getSession().createSQLQuery("select cup.dply_flag from cmn_user_app cup " +
		 		"where cup.user_id = :loginUser and cup.appsys_code = :appsysCode")
				 .setString("loginUser", loginUser)
				 .setString("appsysCode", appsysCode)
				 .uniqueResult();
	 }
}

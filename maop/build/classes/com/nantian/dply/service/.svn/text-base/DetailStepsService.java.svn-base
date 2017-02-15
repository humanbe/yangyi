/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.service;

import java.io.IOException;
import java.io.Serializable;
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.log.Logger;
import com.nantian.dply.DplyConstants;
import com.nantian.dply.vo.JobDetailStepsVo;
import com.nantian.dply.vo.RequestDetailVo;
import com.nantian.dply.vo.RequestStepDetailVo;

/**
 * 进度展示
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class DetailStepsService {

	/**
	 * 日志输出
	 * 
	 */
	final Logger logger = Logger.getLogger(DetailStepsService.class);

	public Map<String, String> fields = new HashMap<String, String>();

	public DetailStepsService() {
		super();
	}

	/**
	 * HIBERNATE Session Factory.
	 * 
	 */
	@Autowired
	private SessionFactory sessionFactory;
	@Autowired
	ServersSynchronousService serversSynchronousService;
	/**
	 * BRPM调用接口
	 * 
	 */
	@Autowired
	private BrpmService brpmService;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 保存.
	 * 
	 * @param field
	 */
	@Transactional
	public void saveOrUpdate(RequestDetailVo requestDetail) {
		getSession().saveOrUpdate(requestDetail);
	}

	/**
	 * 保存.
	 * 
	 * @param field
	 */
	@Transactional
	public void saveOrUpdateStep(RequestStepDetailVo requestStepDetail) {
		getSession().saveOrUpdate(requestStepDetail);
	}

	/**
	 * 更新.
	 * 
	 * @param field
	 */
	@Transactional
	public void update(JobDetailStepsVo jobDetailSteps) {
		getSession().update(jobDetailSteps);
	}

	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(RequestDetailVo.class, id);
	}

	/**
	 * 批量保存.
	 * 
	 * @param field
	 */
	@Transactional
	public void save(Set<JobDetailStepsVo> jobDetailStepsSet) {
		for (JobDetailStepsVo jobDetailSteps : jobDetailStepsSet) {
			getSession().save(jobDetailSteps);
		}
	}

	/**
	 * 查询已经就绪的系统

	 * 
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws ParseException
	 * 
	 * @returnjsonMapList
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> findReadySysByReqStatus(String reqStatus) throws IOException, BrpmInvocationException, URISyntaxException,ParseException {
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append(" select t.appsys_code, b.request_name,b.request_state,to_char(b.scheduled_at,'yyyymmdd hh24:mi:ss') as scheduled_at,");
		requestSql.append(" substr(numtodsinterval((b.target_completion_at - to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')) * 24 * 60 * 60,'second'),'0','1') as flag,");
		requestSql.append(" substr(numtodsinterval((b.scheduled_at - to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')) * 24 * 60 * 60,'second'),'0','1') as flag2,");
		requestSql.append(" substr( numtodsinterval((b.scheduled_at-to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss'))* 24 * 60 * 60,'second'),'12','8' ) as estimate");
		requestSql.append(" from dply_request_info t, brpmdba.v_request_detail b");
		requestSql.append(" where t.request_name = b.request_name");
		requestSql.append(" and substr(b.request_name,instr(b.request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd'))");
		requestSql.append(" and t.plan_deploy_date is not null");
		requestSql.append(" and b.request_state='planned'");
		Query requestQuery = getSession().createSQLQuery(requestSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<HashMap<String,String>> list=requestQuery.list();
		for(int i=0;i<list.size();i++){
			Map<String, String> map = new HashMap<String, String>();
			String estimate = "";
			if(list.get(i).get("ESTIMATE")!=null && !("").equals(list.get(i).get("ESTIMATE"))){
				if(list.get(i).get("FLAG2").toString().equals("-")){
					estimate ="已到请求排期开始时间";
				}else{
					estimate = list.get(i).get("ESTIMATE").toString();
					}
				
			}
			map.put("reqStatus",list.get(i).get("REQUEST_STATE"));
			map.put("requestName", list.get(i).get("REQUEST_NAME"));
			
			if(list.get(i).get("SCHEDULED_AT")!=null && !("").equals(list.get(i).get("SCHEDULED_AT"))){
				map.put("planStartTime", list.get(i).get("SCHEDULED_AT").toString());
			}
			if(list.get(i).get("FLAG")!=null && !("").equals(list.get(i).get("FLAG"))){
				if(list.get(i).get("FLAG").toString().equals("-")){
						map.put("countDown", "请求已超时");
				 }else{
					 map.put("countDown", estimate);
				 }
			}
			String systemName=(String) querySystemName(list.get(i).get("APPSYS_CODE"));
			map.put("appsysName", systemName);
			jsonMapList.add(map);
		}
		return jsonMapList;
	}
	/*@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> findReadySysByReqStatus(String reqStatus) throws IOException, BrpmInvocationException, URISyntaxException,ParseException {
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		Map<String, String> map = null;
		Query query = null;
		Query requestQuery = null;
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(appsys_code,instr(appsys_code,'-')+1) as \"sysName\"").append("from v_cmn_app_info");
		query = getSession().createSQLQuery(sql.toString());
		List<String> list = query.list();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select request_name from dply_request_info where substr(request_name,instr(request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd')) and plan_deploy_date is not null");
		requestQuery = getSession().createSQLQuery(requestSql.toString());
		List<String> requestList = requestQuery.list();
		for (int j = 0; j < requestList.size(); j++) {
			String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + requestList.get(j) + "\" }}");
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element account : accounts) {
				map = new HashMap<String, String>();
				String requestId = account.getChildText("id");
				String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, requestId);
				Document requestDoc = JDOMParserUtil.xmlParse(requestXml);
				Element requestRoot = requestDoc.getRootElement();
				if (("2").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))) {
					map.put("reqStatus", DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")));
					map.put("requestName", account.getChildText("name"));
					String planStr = account.getChildText("scheduled-at");
					if (!planStr.equals("") && planStr.length() != 0) {
						planStr = planStr.substring(0, planStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
						map.put("planStartTime", planStr);
						SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd HH:mm:ss");
						String nowTime = df.format(new Date());
						Date now = df.parse(nowTime);
						Date date = df.parse(planStr);
						long l = date.getTime() - now.getTime();
						long day = l / (24 * 60 * 60 * 1000);
						long hour = (l / (60 * 60 * 1000) - day * 24);
						long min = ((l / (60 * 1000)) - day * 24 * 60 - hour * 60);
						long s = (l / 1000 - day * 24 * 60 * 60 - hour * 60 * 60 - min * 60);
						String h = Long.toString(hour);
						String f = Long.toString(min);
						String m = Long.toString(s);
						h = (h.length() > 1) ? h : "0" + h;
						f = (f.length() > 1) ? f : "0" + f;
						m = (m.length() > 1) ? m : "0" + m;
						String estimate="";
						if(day>0){
							estimate = "" + day + "天" + h + ":" + f + ":" + m;
						}else{
							estimate = h + ":" + f + ":" + m;
						}
						map.put("countDown", estimate);
					}
					String requestName = account.getChildText("name");
					if (!requestName.equals("") && requestName.length() != 0) {
						if (requestName.indexOf("_") >= 0) {
							requestName = requestName.substring(0,requestName.indexOf("_"));
							for (int i = 0; i < list.size(); i++) {
								if (list.get(i).equals(requestName)) {
									String id = list.get(i);
									StringBuilder nameSql = new StringBuilder();
									nameSql.append("select systemname as appsys_name from v_cmn_app_info where substr(appsys_code,instr(appsys_code,'-')+1)=:id");
									Query queryName = null;
									queryName = getSession().createSQLQuery(nameSql.toString()).setString("id",id);
									String name = queryName.uniqueResult().toString();
									map.put("appsysName", name);
								}
							}
						}
					}
					jsonMapList.add(map);
				}
			}
		}
		return jsonMapList;
	}
*/
	/**
	 * 查询系统名称
	 * 
	 * @throws IOException
	 * @throws ParseException
	 */
	@Transactional(readOnly = true)
	public Object querySystemName(String appsysCode)  {
		StringBuilder nameSql = new StringBuilder();
		nameSql.append("select systemname as appsys_name from v_cmn_app_info where appsys_code=:appsysCode");
		Query queryName = null;
		queryName = getSession().createSQLQuery(nameSql.toString()).setString("appsysCode",appsysCode);
		String name = queryName.uniqueResult().toString();
		return name;
	}
	
	/**
	 * 查询已经成功的系统

	 * 
	 * 
	 * @return jsonMapList
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws ParseException
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findSuccessSysByExecStatus(String reqStatus, HttpServletRequest request) throws IOException,BrpmInvocationException, URISyntaxException, ParseException {
		List<Map<String, Object>> jsonMapList = new ArrayList<Map<String, Object>>();
		Set<String> failedSet = new HashSet<String>();
		Set<String> allRequestSet = new HashSet<String>();
		Set<String> runSet = new HashSet<String>();
		request.getSession().removeAttribute("requestFinishNums");
		request.getSession().removeAttribute("requestWhole");
		request.getSession().removeAttribute("stepWhole");
		request.getSession().removeAttribute("stepFinishNums");
		request.getSession().removeAttribute("sysFinishNums");
		request.getSession().removeAttribute("sysWhole");
		StringBuilder sql = new StringBuilder();
		sql.append("select sum(b.step_executed_num) as stepFinishNums,sum(b.request_allstep_num) as stepWhole");
		sql.append(" from brpmdba.v_request_detail b,dply_request_info t");
		sql.append(" where t.request_name = b.request_name");
		sql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		sql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		sql.append(" and t.plan_deploy_date is not null ");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<HashMap<String,String>> list = query.list();
		if(list.size()>0){
			request.getSession().setAttribute("stepFinishNums", list.get(0).get("STEPFINISHNUMS"));
			request.getSession().setAttribute("stepWhole", list.get(0).get("STEPWHOLE"));
		}
		StringBuilder finishReqSql = new StringBuilder();
		finishReqSql.append("select count(*) from brpmdba.v_request_detail b,dply_request_info t");
		finishReqSql.append(" where t.request_name = b.request_name");
		finishReqSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		finishReqSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		finishReqSql.append(" and t.plan_deploy_date is not null");
		finishReqSql.append(" and b.request_state = 'complete'");
		Query finishReqQuery = getSession().createSQLQuery(finishReqSql.toString());
		//List<HashMap<String,String>> finishReqList = finishReqQuery.list();
		request.getSession().setAttribute("requestFinishNums",Long.valueOf(finishReqQuery.uniqueResult().toString()));
		
		StringBuilder wholeReqSql = new StringBuilder();
		wholeReqSql.append("select count(*) from brpmdba.v_request_detail b,dply_request_info t");
		wholeReqSql.append(" where t.request_name = b.request_name");
		wholeReqSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		wholeReqSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		wholeReqSql.append(" and t.plan_deploy_date is not null");
		Query wholeReqQuery = getSession().createSQLQuery(wholeReqSql.toString());
		//List<HashMap<String,String>> wholeReqList = wholeReqQuery.list();
		request.getSession().setAttribute("requestWhole", Long.valueOf(wholeReqQuery.uniqueResult().toString()));
		
		
		StringBuilder failAppsysNameSql = new StringBuilder();
		failAppsysNameSql.append("select distinct substr(b.request_name, 0,instr(b.request_name, '_')-1) as appsysName from brpmdba.v_request_detail b,dply_request_info t");
		failAppsysNameSql.append(" where t.request_name = b.request_name");
		failAppsysNameSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		failAppsysNameSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		failAppsysNameSql.append(" and t.plan_deploy_date is not null and b.request_state != 'complete'");
		Query failAppsysNameQuery = getSession().createSQLQuery(failAppsysNameSql.toString());
		List<String> failAppsysNameList = failAppsysNameQuery.list();
		for(int i=0;i<failAppsysNameList.size();i++){
			failedSet.add(failAppsysNameList.get(i));
		}

		StringBuilder wholeAppsysNameSql = new StringBuilder();
		wholeAppsysNameSql.append("select distinct substr(b.request_name, 0,instr(b.request_name, '_')-1) as appsysName from brpmdba.v_request_detail b,dply_request_info t");
		wholeAppsysNameSql.append(" where t.request_name = b.request_name");
		wholeAppsysNameSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		wholeAppsysNameSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		wholeAppsysNameSql.append(" and t.plan_deploy_date is not null ");
		Query wholeAppsysNameQuery = getSession().createSQLQuery(wholeAppsysNameSql.toString());
		List<String> wholeAppsysNameList = wholeAppsysNameQuery.list();
		for(int i=0;i<wholeAppsysNameList.size();i++){
			allRequestSet.add(wholeAppsysNameList.get(i));
		}
		allRequestSet.removeAll(failedSet);
		request.getSession().setAttribute("sysFinishNums", allRequestSet.size());
		request.getSession().setAttribute("sysWhole",failedSet.size() + allRequestSet.size());
		
		//正在进行中的系统统计
		StringBuilder runAppsysNameSql = new StringBuilder();
		runAppsysNameSql.append("select distinct substr(b.request_name, 0,instr(b.request_name, '_')-1) as appsysName from brpmdba.v_request_detail b,dply_request_info t");
		runAppsysNameSql.append(" where t.request_name = b.request_name");
		runAppsysNameSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
		runAppsysNameSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
		runAppsysNameSql.append(" and t.plan_deploy_date is not null and b.request_state = 'started'");
		Query runAppsysNameQuery = getSession().createSQLQuery(runAppsysNameSql.toString());
		List<String> runAppsysNameList = runAppsysNameQuery.list();
		for(int i=0;i<runAppsysNameList.size();i++){
			runSet.add(runAppsysNameList.get(i));
		}
		
		//正在进行中的系统统计
				StringBuilder run2AppsysNameSql = new StringBuilder();
				run2AppsysNameSql.append("select distinct substr(b.request_name, 0,instr(b.request_name, '_')-1) as appsysName from brpmdba.v_request_detail b,dply_request_info t");
				run2AppsysNameSql.append(" where t.request_name = b.request_name");
				run2AppsysNameSql.append(" and substr(b.request_name, instr(b.request_name, '_', 1, 2) + 1, 8) in");
				run2AppsysNameSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
				run2AppsysNameSql.append(" and t.plan_deploy_date is not null and b.request_state = 'complete'"  );
				run2AppsysNameSql.append(" and substr(b.request_name, 0,instr(b.request_name, '_')-1) in (  "  );
				run2AppsysNameSql.append("select distinct substr(b1.request_name, 0,instr(b1.request_name, '_')-1) as appsysName from brpmdba.v_request_detail b1,dply_request_info t1");
				run2AppsysNameSql.append(" where t1.request_name = b1.request_name");
				run2AppsysNameSql.append(" and substr(b1.request_name, instr(b1.request_name, '_', 1, 2) + 1, 8) in");
				run2AppsysNameSql.append(" (to_char(sysdate, 'yyyymmdd'), to_char(sysdate-1, 'yyyymmdd'))");
				run2AppsysNameSql.append(" and t1.plan_deploy_date is not null and b1.request_state = 'planned' )"  );
				Query run2AppsysNameQuery = getSession().createSQLQuery(run2AppsysNameSql.toString());
				List<String> run2AppsysNameList = run2AppsysNameQuery.list();
				for(int i=0;i<run2AppsysNameList.size();i++){
					runSet.add(run2AppsysNameList.get(i));
				}
		
				request.getSession().setAttribute("runAppnum", runSet.size());
		StringBuilder requestSql = new StringBuilder();
		requestSql.append(" select t.appsys_code, b.request_name,b.request_state,to_char(b.scheduled_at,'yyyymmdd hh24:mi:ss') as scheduled_at,");
		requestSql.append(" to_char(b.target_completion_at,'yyyymmdd hh24:mi:ss') as completion_at,");
		requestSql.append(" to_char(b.last_step_completed_at,'yyyymmdd hh24:mi:ss') as real_completion_at,");
		requestSql.append(" to_char(b.first_step_started_at,'yyyymmdd hh24:mi:ss') as started_at,");
		requestSql.append(" substr(numtodsinterval((b.target_completion_at - to_date(to_char(b.last_step_completed_at,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')) * 24 * 60 * 60,'second'),'0','1') as flag,");
		requestSql.append(" substr( numtodsinterval((b.scheduled_at-to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss'))* 24 * 60 * 60,'second'),'12','8' ) as estimate");
		requestSql.append(" from dply_request_info t, brpmdba.v_request_detail b");
		requestSql.append(" where t.request_name = b.request_name");
		requestSql.append(" and substr(b.request_name,instr(b.request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd'))");
		requestSql.append(" and t.plan_deploy_date is not null");
		requestSql.append(" and b.request_state='complete'");
		Query requestQuery = getSession().createSQLQuery(requestSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<HashMap<String,String>> reqList=requestQuery.list();
		for(int i=0;i<reqList.size();i++){
			String RequestName = reqList.get(i).get("REQUEST_NAME").toString().substring(0,reqList.get(i).get("REQUEST_NAME").toString().indexOf("_"));
			Map<String, Object> map = new HashMap<String, Object>();
			if(allRequestSet.size()>0){
				if(allRequestSet.contains(RequestName)){
					String systemName=(String) querySystemName(reqList.get(i).get("APPSYS_CODE"));
					map.put("appsysName", systemName);
					map.put("reqStatus", reqList.get(i).get("REQUEST_STATE"));
					map.put("requestName", reqList.get(i).get("REQUEST_NAME"));
					map.put("exeCompletedTime",reqList.get(i).get("REAL_COMPLETION_AT"));
					map.put("planCompletedTime", reqList.get(i).get("COMPLETION_AT"));
					map.put("exeStartTime", reqList.get(i).get("STARTED_AT"));
					if(reqList.get(i).get("FLAG")!=null && !("").equals(reqList.get(i).get("FLAG"))){
						if(reqList.get(i).get("FLAG").toString().equals("-")){
								map.put("overTime", "1");
						 }else{
							    map.put("overTime", "2");
						 }
					}	
					//allRequestSet.remove(RequestName);
					jsonMapList.add(map);
				}
				
			}
		}
		return jsonMapList;
	}
	/*@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findSuccessSysByExecStatus(String reqStatus, HttpServletRequest request) throws IOException,BrpmInvocationException, URISyntaxException, ParseException {
		List<Map<String, Object>> jsonMapList = new ArrayList<Map<String, Object>>();
		Set<String> failedSet = new HashSet<String>();
		Set<String> allRequestSet = new HashSet<String>();
		Map<String, Object> map = null;
		Query requestQuery = null;
		int requestFinishNums = 0;
		int stepFinishNums = 0;
		int stepWhole = 0;
		Query query = null;
		request.getSession().removeAttribute("requestFinishNums");
		request.getSession().removeAttribute("requestWhole");
		request.getSession().removeAttribute("stepWhole");
		request.getSession().removeAttribute("stepFinishNums");
		request.getSession().removeAttribute("sysFinishNums");
		request.getSession().removeAttribute("sysWhole");
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(appsys_code,instr(appsys_code,'-')+1) as \"sysName\"").append("from v_cmn_app_info");
		query = getSession().createSQLQuery(sql.toString());
		List<String> list = query.list();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select request_name from dply_request_info where substr(request_name,instr(request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd')) and plan_deploy_date is not null");
		requestQuery = getSession().createSQLQuery(requestSql.toString());
		List<String> requestList = requestQuery.list();
		String requestId = "";
		List<String> requestIdList = null;
		for (int j = 0; j < requestList.size(); j++) {
			String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + requestList.get(j)+ "\" }}");
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element account : accounts) {
				if ((null == account.getChildText("deleted-at") || ("").equals(account.getChildText("deleted-at"))) && null==account.getChild("request-template") ) {
					requestIdList = new ArrayList<String>();
					requestId = account.getChildText("id");
					requestIdList.add(requestId);
				}
			}
			for (int k = 0; k < requestIdList.size(); k++) {
				String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, requestIdList.get(k));
				Document requestDoc = JDOMParserUtil.xmlParse(requestXml);
				Element requestRoot = requestDoc.getRootElement();
				if (("7").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))) {
					requestFinishNums++;
				}
				List<Element> stepsRoot = requestRoot.getChild("steps").getChildren();
				for (Element stepRoot : stepsRoot) {
					String stepId = stepRoot.getChildText("id");
					String stepXml1 = brpmService.getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
					Document stepDoc1 = JDOMParserUtil.xmlParse(stepXml1);
					Element stepRoot1 = stepDoc1.getRootElement();
					if (stepRoot1.getChildText("should-execute").equals("true")) {
						stepWhole++;
					}
					if (("7").equals(DplyConstants.stepStateItem.getStepStateNum(stepRoot.getChildText("aasm-state")))) {
						stepFinishNums++;
					}
				}
				if (!("7").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))) {
					String failedRequestName = requestRoot.getChildText("name");
					if (failedRequestName.indexOf("_") >= 0) {
						failedRequestName = failedRequestName.substring(0,failedRequestName.indexOf("_"));
						failedSet.add(failedRequestName);
					}
				}
				String allRequestName = requestRoot.getChildText("name");
				if (allRequestName.indexOf("_") >= 0) {
					allRequestSet.add(allRequestName.substring(0,allRequestName.indexOf("_")));
				}
			}
		}
		// 完成的系统

		allRequestSet.removeAll(failedSet);
		// 成功系统的显示

		String successRequestName = "";
		List<Map<String, String>> requestMapList =  null;
		Map<String, String> requestMap = null;
		for (int j = 0; j < requestList.size(); j++) {
			String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + requestList.get(j) + "\" }}");
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			requestMap = new HashMap<String, String>();
			for (Element account : accounts) {
				if (null == account.getChildText("deleted-at") || ("").equals(account.getChildText("deleted-at"))) {
					requestMapList =  new ArrayList<Map<String,String>>();
					requestId = account.getChildText("id");
					successRequestName = account.getChildText("name");
					requestMap.put("id", requestId);
					requestMap.put("name", successRequestName);
					requestMapList.add(requestMap);
					}
			}
				for(Map<String, String> Map : requestMapList){
				if (Map.get("name").toString().indexOf("_") >= 0) {
					map = new HashMap<String, Object>();
					String RequestName = Map.get("name").toString().substring(0,successRequestName.indexOf("_"));
					if (allRequestSet.contains(RequestName)) {
					//	String requestId = account.getChildText("id");
						String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, Map.get("id").toString());
						Document requestDoc = JDOMParserUtil.xmlParse(requestXml);
						Element requestRoot = requestDoc.getRootElement();
						map.put("reqStatus", DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")));
						map.put("requestName", requestRoot.getChildText("name"));
						String completeStr = requestRoot.getChildText("completed-at");
						if (!completeStr.equals("") && completeStr.length() != 0) {
							completeStr = completeStr.substring(0, completeStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("exeCompletedTime", completeStr);
						}
						String planCompleteStr = requestRoot.getChildText("target-completion-at");
						if (!planCompleteStr.equals("") && planCompleteStr.length() != 0) {
							planCompleteStr = planCompleteStr.substring(0, planCompleteStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("planCompletedTime", planCompleteStr);
						}
						SimpleDateFormat sdr = new SimpleDateFormat("yyyyMMdd kk:mm:ss");
						Date dt1 = sdr.parse(completeStr);
						if (!planCompleteStr.equals("") && planCompleteStr.length() != 0) {
							Date dt2 = sdr.parse(planCompleteStr);
							if (dt1.getTime() > dt2.getTime()) {
								map.put("overTime", "1");
							} else {
								map.put("overTime", "2");
							}
						}
						String startStr = requestRoot.getChildText("started-at");
						if (!startStr.equals("") && startStr.length() != 0) {
							startStr = startStr.substring(0, startStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("exeStartTime", startStr);
						}
						String requestName = requestRoot.getChildText("name");
						if (!requestName.equals("") && requestName.length() != 0) {
							if (requestName.indexOf("_") >= 0) {
								requestName = requestName.substring(0,requestName.indexOf("_"));
								for (int i = 0; i < list.size(); i++) {
									if (list.get(i).equals(requestName)) {
										String id = list.get(i);
										StringBuilder nameSql = new StringBuilder();
										nameSql.append("select systemname as appsys_name from  v_cmn_app_info where substr(appsys_code,instr(appsys_code,'-')+1)=:id");
										Query queryName = null;
										queryName = getSession().createSQLQuery(nameSql.toString()).setString("id", id);
										String name = queryName.uniqueResult().toString();
										map.put("appsysName", name);
									}
								}
							}
						}
						jsonMapList.add(map);
					}
				}
			}
		}
		request.getSession().setAttribute("requestFinishNums",requestFinishNums);
		request.getSession().setAttribute("requestWhole", requestList.size());
		request.getSession().setAttribute("stepFinishNums", stepFinishNums);
		request.getSession().setAttribute("stepWhole", stepWhole);
		request.getSession().setAttribute("sysFinishNums", allRequestSet.size());
		request.getSession().setAttribute("sysWhole",failedSet.size() + allRequestSet.size());
		return jsonMapList;
	}*/

	/**
	 * 查询正在执行的系统

	 * 
	 * 
	 * @return jsonMapList
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws ParseException
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findExeSysByExecStatus(String reqStatus)throws IOException, BrpmInvocationException, URISyntaxException, ParseException {
		List<Map<String, Object>> jsonMapList = new ArrayList<Map<String, Object>>();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select t.appsys_code, b.request_name,b.request_state,to_char(b.scheduled_at,'yyyymmdd hh24:mi:ss') as scheduled_at,");
		requestSql.append(" to_char(b.target_completion_at,'yyyymmdd hh24:mi:ss') as completion_at,");
		requestSql.append(" to_char(b.last_step_completed_at,'yyyymmdd hh24:mi:ss') as real_completion_at,");
		requestSql.append(" to_char(b.first_step_started_at,'yyyymmdd hh24:mi:ss') as started_at,");
		requestSql.append(" b.step_executed_num || '/' || b.request_allstep_num as finishPernect,");
		requestSql.append(" substr(numtodsinterval((b.target_completion_at - to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')) * 24 * 60 * 60,'second'),'0','1') as flag,");
		requestSql.append(" substr( numtodsinterval((b.scheduled_at-to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss'))* 24 * 60 * 60,'second'),'12','8' ) as estimate");
		requestSql.append(" from maop.dply_request_info t, brpmdba.v_request_detail b");
		requestSql.append(" where t.request_name = b.request_name");
		requestSql.append(" and substr(b.request_name,instr(b.request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd'))");
		requestSql.append(" and t.plan_deploy_date is not null");
		requestSql.append(" and b.request_state='started'");
		Query requestQuery = getSession().createSQLQuery(requestSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<HashMap<String,String>> list=requestQuery.list();
		String crlf=System.getProperty("line.separator");
		for(int i=0;i<list.size();i++){
			StringBuilder stepSql = new StringBuilder();
			stepSql.append("select count(*) from brpmdba.v_request_step_detail t where t.REQUEST_NAME='"+list.get(i).get("REQUEST_NAME")+"' and t.step_state in ('in_process','ready')");
			Query stepQuery = getSession().createSQLQuery(stepSql.toString());
			
			StringBuilder stepNameSql = new StringBuilder();
			stepNameSql.append("select t.NAME from brpmdba.v_request_step_detail t where t.REQUEST_NAME='"+list.get(i).get("REQUEST_NAME")+"' and t.step_state in ('in_process','ready')");
			Query stepNameQuery = getSession().createSQLQuery(stepNameSql.toString()); 
			List<String> stepNameList = stepNameQuery.list();
			StringBuffer stepName = new StringBuffer();
			for(int j=0;j<stepNameList.size();j++){
				
				if(j==stepNameList.size()-1){
					stepName.append(stepNameList.get(j));
				}else{
					stepName.append(stepNameList.get(j)).append(",");
				}
			}
			//Long.valueOf(wholeReqQuery.uniqueResult().toString())
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("stepRunningNum",Long.valueOf(stepQuery.uniqueResult().toString()));
			map.put("finsihPernect",list.get(i).get("FINISHPERNECT"));
			String estimate = "";
			if(list.get(i).get("ESTIMATE")!=null && !("").equals(list.get(i).get("ESTIMATE"))){
				estimate = list.get(i).get("ESTIMATE").toString();
			}
			map.put("exeStartTime",list.get(i).get("STARTED_AT"));
			map.put("reqStatus",stepName.toString());
			map.put("planCompletedTime", list.get(i).get("COMPLETION_AT"));
			map.put("requestName", list.get(i).get("REQUEST_NAME"));
			if(list.get(i).get("SCHEDULED_AT")!=null && !("").equals(list.get(i).get("SCHEDULED_AT"))){
				map.put("planStartTime", list.get(i).get("SCHEDULED_AT").toString());
			}
			if(list.get(i).get("FLAG")!=null && !("").equals(list.get(i).get("FLAG"))){
				if(list.get(i).get("FLAG").toString().equals("-")){
						map.put("overTime", "1");
				 }else{
					 map.put("overTime", "2");
				 }
			}
			String systemName=(String) querySystemName(list.get(i).get("APPSYS_CODE"));
			map.put("appsysName", systemName);
			jsonMapList.add(map);
		}
		return jsonMapList;
	}
	/*public List<Map<String, String>> findExeSysByExecStatus(String reqStatus)throws IOException, BrpmInvocationException, URISyntaxException, ParseException {
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		Map<String, String> map = null;
		Query query = null;
		Query requestQuery = null;
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(appsys_code,instr(appsys_code,'-')+1) as \"sysName\"").append("from v_cmn_app_info");
		query = getSession().createSQLQuery(sql.toString());
		List<String> list = query.list();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select request_name from dply_request_info where substr(request_name,instr(request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd')) and plan_deploy_date is not null");
		requestQuery = getSession().createSQLQuery(requestSql.toString());
		List<String> requestList = requestQuery.list();
		for (int j = 0; j < requestList.size(); j++) {
			List<String> requestIdList = null;
			String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + requestList.get(j)+ "\" }}");
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element account : accounts) {
				if ((null == account.getChildText("deleted-at") || ("").equals(account.getChildText("deleted-at"))) && null == account.getChild("request-template") ) {
					requestIdList = new ArrayList<String>();
					String requestId = account.getChildText("id");
					requestIdList.add(requestId);
				}
			}
			for (int k = 0; k < requestIdList.size(); k++) {
				map = new HashMap<String, String>();
				String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, requestIdList.get(k));
				Document requestDoc = JDOMParserUtil.xmlParse(requestXml);
				Element requestRoot = requestDoc.getRootElement();
				List<Element> stepsRoot = requestRoot.getChild("steps").getChildren();
				for (Element stepRoot : stepsRoot) {
					if (("3").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))
							&& ("3").equals(DplyConstants.stepStateItem.getStepStateNum(stepRoot.getChildText("aasm-state")))
							|| ("3").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))
							&& ("2").equals(DplyConstants.stepStateItem.getStepStateNum(stepRoot.getChildText("aasm-state")))) {
						map.put("requestName", requestRoot.getChildText("name"));
						map.put("reqStatus", stepRoot.getChildText("name"));
						String startStr = requestRoot.getChildText("started-at");
						if (!startStr.equals("") && startStr.length() != 0) {
							startStr = startStr.substring(0, startStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("exeStartTime", startStr);
						}
						String planCompleteStr = requestRoot.getChildText("target-completion-at");
						if (!planCompleteStr.equals("") && planCompleteStr.length() != 0) {
							planCompleteStr = planCompleteStr.substring(0, planCompleteStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("planCompletedTime", planCompleteStr);
							SimpleDateFormat sdr = new SimpleDateFormat("yyyyMMdd kk:mm:ss");
							String now = sdr.format(new Date());
							Date dt1 = sdr.parse(now);
							if (!planCompleteStr.equals("") && planCompleteStr.length() != 0) {
								Date dt2 = sdr.parse(planCompleteStr);
								if (dt1.getTime() > dt2.getTime()) {
									map.put("overTime", "1");
								} else {
									map.put("overTime", "2");
								}
							}
						}
						String requestName = requestRoot.getChildText("name");
						if (!requestName.equals("") && requestName.length() != 0) {
							if (requestName.indexOf("_") >= 0) {
								requestName = requestName.substring(0,requestName.indexOf("_"));
								for (int i = 0; i < list.size(); i++) {
									if (list.get(i).equals(requestName)) {
										String id = list.get(i);
										StringBuilder nameSql = new StringBuilder();
										nameSql.append("select systemname as appsys_name from  v_cmn_app_info where substr(appsys_code,instr(appsys_code,'-')+1)=:id");
										Query queryName = null;
										queryName = getSession().createSQLQuery(nameSql.toString()).setString("id", id);
										String name = queryName.uniqueResult().toString();
										map.put("appsysName", name);
									}
								}
							}
						}
						jsonMapList.add(map);
					}
				}
			}
		}
		return jsonMapList;
	}
*/
	/**
	 * 查询已经失败的系统

	 * 
	 * 
	 * @return jsonMapList
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findfailedSysByExecStatus(String reqStatus)throws IOException, BrpmInvocationException, URISyntaxException {
		List<Map<String, Object>> jsonMapList = new ArrayList<Map<String, Object>>();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select t.appsys_code, b.request_name,b.request_state,to_char(b.scheduled_at,'yyyymmdd hh24:mi:ss') as scheduled_at,");
		requestSql.append(" to_char(b.target_completion_at,'yyyymmdd hh24:mi:ss') as completion_at,");
		requestSql.append(" to_char(b.last_step_completed_at,'yyyymmdd hh24:mi:ss') as real_completion_at,");
		requestSql.append(" to_char(b.first_step_started_at,'yyyymmdd hh24:mi:ss') as started_at,");
		requestSql.append(" b.step_executed_num || '/' || b.request_allstep_num as finishPernect,");
		requestSql.append(" substr(numtodsinterval((b.scheduled_at - to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')) * 24 * 60 * 60,'second'),'0','1') as flag,");
		requestSql.append(" substr( numtodsinterval((b.scheduled_at-to_date(to_char(sysdate,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss'))* 24 * 60 * 60,'second'),'12','8' ) as estimate");
		requestSql.append(" from maop.dply_request_info t, brpmdba.v_request_detail b");
		requestSql.append(" where t.request_name = b.request_name");
		requestSql.append(" and substr(b.request_name,instr(b.request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd'))");
		requestSql.append(" and t.plan_deploy_date is not null");
		requestSql.append(" and b.request_state='problem'");
		Query requestQuery = getSession().createSQLQuery(requestSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<HashMap<String,String>> list=requestQuery.list();
		for(int i=0;i<list.size();i++){
			StringBuilder stepNameSql = new StringBuilder();
			stepNameSql.append("select t.name from brpmdba.v_request_step_detail t where t.REQUEST_NAME='"+list.get(i).get("REQUEST_NAME")+"' and t.step_state='problem'");
			Query stepNameQuery = getSession().createSQLQuery(stepNameSql.toString()); 
			List<String> stepNameList = stepNameQuery.list();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("exeStartTime",list.get(i).get("STARTED_AT"));
			map.put("reqStatus",stepNameList.get(0));
			map.put("requestName", list.get(i).get("REQUEST_NAME"));
			String systemName=(String) querySystemName(list.get(i).get("APPSYS_CODE"));
			map.put("appsysName", systemName);
			jsonMapList.add(map);
		}
		return jsonMapList;
	}
	/*public List<Map<String, Object>> findfailedSysByExecStatus(String reqStatus)throws IOException, BrpmInvocationException, URISyntaxException {
		List<Map<String, Object>> jsonMapList = new ArrayList<Map<String, Object>>();
		Map<String, Object> map = null;
		Query query = null;
		Query requestQuery = null;
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(appsys_code,instr(appsys_code,'-')+1) from v_cmn_app_info");
		query = getSession().createSQLQuery(sql.toString());
		List<String> list = query.list();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append("select request_name from dply_request_info where substr(request_name,instr(request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd')) and plan_deploy_date is not null");
		requestQuery = getSession().createSQLQuery(requestSql.toString());
		List<String> requestList = requestQuery.list();
		String requestId = "";
		List<String> requestIdList = null;
		for (int j = 0; j < requestList.size(); j++) {
			String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + requestList.get(j) + "\" }}");
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element account : accounts) {
				if ((null == account.getChildText("deleted-at") || ("").equals(account.getChildText("deleted-at"))) && null==account.getChild("request-template") ) {
					requestIdList = new ArrayList<String>();
					requestId = account.getChildText("id");
					requestIdList.add(requestId);
				}
			}
			for (int m = 0; m < requestIdList.size(); m++) {
				map = new HashMap<String, Object>();
				String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, requestIdList.get(m));
				Document requestDoc = JDOMParserUtil.xmlParse(requestXml);
				Element requestRoot = requestDoc.getRootElement();
				List<Element> stepsRoot = requestRoot.getChild("steps").getChildren();
				for (Element stepRoot : stepsRoot) {
					if (("4").equals(DplyConstants.requestStateItem.getRequestStateNum(requestRoot.getChildText("aasm-state")))&& ("5").equals(DplyConstants.stepStateItem.getStepStateNum(stepRoot.getChildText("aasm-state")))) {
						map.put("requestName", requestRoot.getChildText("name"));
						map.put("reqStatus", stepRoot.getChildText("name"));
						String startStr = requestRoot.getChildText("started-at");
						if (!startStr.equals("") && startStr.length() != 0) {
							startStr = startStr.substring(0, startStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("exeStartTime", startStr);
						}
						String finishStr = stepRoot.getChildText("work-finished-at");
						if (!finishStr.equals("") && finishStr.length() != 0) {
							finishStr = finishStr.substring(0, finishStr.indexOf("+")).replaceAll("T", " ").replaceAll("-", "");
							map.put("workFinishTime", finishStr);
						}
						String requestName = requestRoot.getChildText("name");
						if (!requestName.equals("") && requestName.length() != 0) {
							if (requestName.indexOf("_") >= 0) {
								requestName = requestName.substring(0,requestName.indexOf("_"));
								for (int i = 0; i < list.size(); i++) {
									if (list.get(i).equals(requestName)) {
										String id = list.get(i);
										StringBuilder nameSql = new StringBuilder();
										nameSql.append("select systemname as appsys_name from  v_cmn_app_info where substr(appsys_code,instr(appsys_code,'-')+1)=:id");
										Query queryName = null;
										queryName = getSession().createSQLQuery(nameSql.toString()).setString("id", id);
										String name = queryName.uniqueResult().toString();
										map.put("appsysName", name);
									}
								}
							}
						}
						jsonMapList.add(map);
					}
				}
			}
		}
		return jsonMapList;
	}*/

	/**
	 * 查询步骤的进度

	 * 
	 * 
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object queryStep() throws IOException, BrpmInvocationException, URISyntaxException, SQLException {
		List<String> appsysCodeList = new ArrayList<String>();
		Query requestQuery = null;
		List<String> unfinishList = new ArrayList<String>();
		List<String> finsihList = new ArrayList<String>();
		StringBuilder requestSql = new StringBuilder();
		requestSql.append(" select to_char(wm_concat(t.request_name)) as \"requestName\",t.appsys_code as \"appsysCode\" from dply_request_info t ")
				  .append("where substr(request_name,instr(request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd')) and plan_deploy_date is not null")
				  .append(" group by t.appsys_code");
		requestQuery = getSession().createSQLQuery(requestSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> requestList = requestQuery.list();
		for (Map<String, Object> map : requestList) {
			String appsysCode = (String) map.get("appsysCode");
			String requestsName = (String) map.get("requestName");
			
			String appsysCodeName= serversSynchronousService.getAppName(appsysCode).get(0).get("appsys_name").toString();
			appsysCodeList.add(appsysCodeName);
			
			
			StringBuilder requestsSql = new StringBuilder();
			requestsSql.append("select sum(t.request_allstep_num) as  stepWhole, sum(t.step_executed_num) as stepFinishNums");
			requestsSql.append(" from brpmdba.v_request_detail t , maop.dply_request_info b");
			requestsSql.append(" where t.appsyscd = '"+appsysCode+"'");
			requestsSql.append(" and b.request_name=t.request_name ");
			requestsSql.append(" and substr(b.request_name,instr(b.request_name,'_',1,2)+1,8) in (to_char(sysdate,'yyyymmdd'),to_char(sysdate-1,'yyyymmdd'))");
			requestsSql.append(" and b.plan_deploy_date is not null");
			Query requestsQuery = getSession().createSQLQuery(requestsSql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			List<HashMap<String,String>> list=requestsQuery.list();
			if(list.size()>0){
				
				Object stepNum = list.get(0).get("STEPWHOLE");
				Object finishNum = list.get(0).get("STEPFINISHNUMS");
				int stepWhole =  Integer.parseInt(stepNum.toString()) ;
				int stepFinishNums = Integer.parseInt(finishNum.toString());
				int unfinishStep = stepWhole - stepFinishNums;
				finsihList.add(String.valueOf(stepFinishNums));
				unfinishList.add(String.valueOf(unfinishStep));
			}
			
			/*String[] requestName = requestsName.split(",");
			String requestId = "";
			List<String> requestIdList = new ArrayList<String>();
			for (int i = 0; i < requestName.length; i++) {
				String request = requestName[i];
				String requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" + request + "\" }}");
				Document doc = JDOMParserUtil.xmlParse(requestsXml);
				Element root = doc.getRootElement();
				List<Element> accounts = root.getChildren();
				for (Element account : accounts) {
					if ((null == account.getChildText("deleted-at") || ("").equals(account.getChildText("deleted-at"))) && null==account.getChild("request-template") ) {
						requestId = account.getChildText("id");
						requestIdList.add(requestId);
					}
				}
			}
			for (int i = 0; i < requestIdList.size(); i++) {
				String requestXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, requestIdList.get(i));
				Document requestdoc = JDOMParserUtil.xmlParse(requestXml);
				Element requestroot = requestdoc.getRootElement();
				List<Element> stepsRoot = requestroot.getChild("steps").getChildren();
				for (Element stepRoot : stepsRoot) {
					String stepId = stepRoot.getChildText("id");
					String stepXml1 = brpmService.getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
					Document stepDoc1 = JDOMParserUtil.xmlParse(stepXml1);
					Element stepRoot1 = stepDoc1.getRootElement();
					if (stepRoot1.getChildText("should-execute").equals("true")) {
						stepWhole++;
					}
					if (("7").equals(DplyConstants.stepStateItem.getStepStateNum(stepRoot1.getChildText("aasm-state")))) {
						stepFinishNums++;
					}
				}
				unfinishStep = stepWhole - stepFinishNums;
			}*/
			
		}
		StringBuilder xAxisDataOptions = new StringBuilder();
		xAxisDataOptions.append("{");
		xAxisDataOptions.append("\"xAxisDataOptions\":").append(CommonConst.BRACKET_LEFT);
		for (int j = 0; j < appsysCodeList.size(); j++) {
			xAxisDataOptions.append("\"").append("" + appsysCodeList.get(j) + "").append("\"");
			if (j != finsihList.size() - 1) {
				xAxisDataOptions.append(CommonConst.COMMA);
			}
		}
		xAxisDataOptions.append(CommonConst.BRACKET_RIGHT).append(CommonConst.COMMA);
		// 已经完成的步骤

		xAxisDataOptions.append("\"successDateOptions\":").append(CommonConst.BRACKET_LEFT);
		for (int k = 0; k < finsihList.size(); k++) {
			xAxisDataOptions.append(finsihList.get(k));
			if (k != finsihList.size() - 1) {
				xAxisDataOptions.append(CommonConst.COMMA);
			}
		}
		xAxisDataOptions.append(CommonConst.BRACKET_RIGHT).append(CommonConst.COMMA);
		// 未完成的步骤
		xAxisDataOptions.append("\"failedDateOptions\":").append(CommonConst.BRACKET_LEFT);
		for (int p = 0; p < unfinishList.size(); p++) {
			xAxisDataOptions.append(unfinishList.get(p));
			if (p != unfinishList.size() - 1) {
				xAxisDataOptions.append(CommonConst.COMMA);
			}
		}
		xAxisDataOptions.append(CommonConst.BRACKET_RIGHT);
		xAxisDataOptions.append("}");
		return xAxisDataOptions;
	}
}

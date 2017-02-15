package com.nantian.check.service;

import java.io.File;
import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.axis2.AxisFault;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnDetailLogVo;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 巡检作业设计service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class JobExcuteService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobExcuteService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	@Autowired
    private AppInfoService appInfoService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
//	@Autowired
//	private ScriptExecService scriptExecService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	public String frontFlag = "一线";
	
	/**
	 * 构造方法	 */
	public JobExcuteService() {
		fields.put("appsys_code", FieldType.STRING);
		fields.put("job_code", FieldType.INTEGER);
		fields.put("check_type",FieldType.STRING);
		fields.put("authorize_lever_type", FieldType.STRING); 
		fields.put("field_type", FieldType.STRING); 
		fields.put("job_path", FieldType.STRING); 
		fields.put("job_type", FieldType.STRING); 
		fields.put("job_name", FieldType.STRING); 
		fields.put("job_desc", FieldType.STRING); 
		fields.put("tool_status", FieldType.STRING); 
		fields.put("frontline_flag", FieldType.STRING); 
		fields.put("authorize_flag", FieldType.STRING); 
		fields.put("delete_flag", FieldType.STRING); 
		fields.put("tool_creator", FieldType.STRING); 
		//作业组件关联字段
		fields.put("server_group", FieldType.STRING);
		fields.put("server_ip", FieldType.STRING);
        //作业模板关联字段
		fields.put("template_group", FieldType.STRING);
		fields.put("template_name", FieldType.STRING);
		fields.put("server_target_type", FieldType.STRING);
		//作业时间表字段		fields.put("timer_code", FieldType.INTEGER);
		fields.put("exec_freq_type", FieldType.STRING);
		fields.put("exec_start_date", FieldType.STRING);
		fields.put("exec_start_time", FieldType.STRING);
		fields.put("week1_flag", FieldType.STRING);
		fields.put("week2_flag", FieldType.STRING);
		fields.put("week3_flag", FieldType.STRING);
		fields.put("week4_flag", FieldType.STRING);
		fields.put("week5_flag", FieldType.STRING);
		fields.put("week6_flag", FieldType.STRING);
		fields.put("week7_flag", FieldType.STRING);
		fields.put("interval_weeks", FieldType.INTEGER);
		fields.put("month_days", FieldType.INTEGER);
		fields.put("interval_days", FieldType.INTEGER);
		fields.put("interval_hours", FieldType.INTEGER);
		fields.put("interval_minutes", FieldType.INTEGER);
		fields.put("exec_priority", FieldType.STRING);
		fields.put("exec_notice_mail_list", FieldType.STRING);
		fields.put("mail_success_flag", FieldType.STRING);
		fields.put("mail_failure_flag", FieldType.STRING);
		fields.put("mail_cancel_flag", FieldType.STRING);
		
		fields.put("timerOnceVals", FieldType.STRING);
		fields.put("timerDailyVals", FieldType.STRING);
		fields.put("timerWeeklyVals", FieldType.STRING);
		fields.put("timerMonthlyVals", FieldType.STRING);
		fields.put("timerIntervalVals", FieldType.STRING);
	}
	
	/**
	 * 分页查询作业基本信息
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getJobInfoList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params) {
		//判断当前用户是否是一线		Set<Role> userRole = securityUtils.getUser().getRoles() ;
		boolean frontlineFlag= false;
		for (Role role : userRole) {
			if(role.getName().indexOf(frontFlag) != -1){
				frontlineFlag = true;
			}
		}
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.appsys_code as appsys_code,");
 		hql.append("e.job_code as job_code,");
 		hql.append("e.check_type as check_type,");
 		hql.append("e.authorize_lever_type as authorize_lever_type,");
 		hql.append("e.field_type as field_type,");
 		hql.append("e.job_name as job_name,");
 		hql.append("e.job_path as job_path,");
 		hql.append("e.job_desc as job_desc,");
 		hql.append("e.tool_status as tool_status,");
 		hql.append("e.frontline_flag as frontline_flag,");
 		hql.append("e.authorize_flag as authorize_flag,");
 		hql.append("e.delete_flag as delete_flag,");
 		hql.append("e.server_target_type as server_target_type,");
 		hql.append("e.tool_creator as tool_creator");
		hql.append(") from CheckJobInfoVo e where e.delete_flag=0 and e.job_type=1 and e.appsys_code in :sysList ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
				}
			}
		}
		if(frontlineFlag){
			hql.append(" and e.frontline_flag='1'");
		}
		if(sort!=null && !sort.equals("")){
			hql.append(" order by e." + sort );
			if(dir!=null && !dir.equals("")){
				hql.append(" " + dir );
			}else{
				hql.append(" desc");
			}
		}else{
			hql.append(" order by e.job_name");
		}
		logger.info(hql.toString());
		Query query = getSession().createQuery(hql.toString()).setFirstResult(start).setMaxResults(limit);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		return query.list();
	}
	/**
	 * 获取记录总数
	 * @param params
	 */
	@Transactional(readOnly = true)
	public Long countJobInfoList(Map<String, Object> params) {
		//判断当前用户是否是一线		Set<Role> userRole = securityUtils.getUser().getRoles() ;
		boolean frontlineFlag= false;
		for (Role role : userRole) {
			if(role.getName().indexOf(frontFlag) != -1){
				frontlineFlag = true;
			}
		}
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CheckJobInfoVo e where e.delete_flag=0 and e.job_type=1 and e.appsys_code in :sysList ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
				}
			}
		}
		if(frontlineFlag){
			hql.append(" and e.frontline_flag='1'");
		}
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 获取应用系统信息
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getAppsysInfoList() {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append("e.appsysCode as appsysId,");
 		hql.append("e.appsysName as appsysName");
		hql.append(") from CmnAppsysInfoVo e where 1=1 order by e.appsysCode asc");
		logger.info(hql.toString());
		Query query = getSession().createQuery(hql.toString());
		return query.list();
	}
	
	/**
	 * 根据作业编号获取作业信息
	 * @param jobid 作业编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, Object> getJobInfoById(Integer jobid) {
		StringBuilder sql = new StringBuilder();
		sql.append("select e.appsys_code as \"appsys_code\",")
		   .append(" e.job_code as \"job_code\",")
		   .append(" e.check_type as \"check_type\",")
		   .append(" e.authorize_level_type as \"authorize_lever_type\",")
		   .append(" e.field_type as \"field_type\",")
		   .append(" e.job_name as \"job_name\",")
		   .append(" e.job_path as \"job_path\",")
		   .append(" e.job_type as \"job_type\",")
		   .append(" e.job_desc as \"job_desc\",")
		   .append(" e.tool_status as \"tool_status\",")
		   .append(" e.frontline_flag as \"frontline_flag\",")
		   .append(" e.authorize_flag as \"authorize_flag\",")
		   .append(" e.delete_flag as \"delete_flag\",")
		   .append(" e.tool_creator as \"tool_creator\" ")
		   .append(" from check_job_info e ")
		   .append(" where e.job_code =:jobCode ") ;
		Query query = getSession().createSQLQuery(sql.toString())
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
		          .setInteger("jobCode", jobid);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	
	/**
	 * 根据主键查询.
	 * @param jobid 作业编号
	 * @return
	 */
	public Object getJobById(Serializable jobid) {
		return getSession().get(CheckJobInfoVo.class, jobid);
	}
	
	/**
	 * 根据DBKey批量执行巡检作业
	 * @param jobIds 作业编号数组
	 * @return 总个数+","+成功个数+","+失败个数
	 */
	@Transactional
	public String excuteJobByDBKeys(Integer[] jobCodes) throws AxisFault,Exception{
		String returnStr = "" ;
		int fail = 0 ;
		String failCode = "";
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		LoginServiceClient client;
		LoginUsingSessionCredentialResponse loginResponse;
		CLITunnelServiceClient cliClient = null;
		ExecuteCommandByParamListResponse cliResponse = null;
		client = new LoginServiceClient();
		loginResponse = client.getBsaCredential();
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		String jobDBKey = "" ;
		String jobPath ="" ;
		String jobName = "" ;
		//String scriptName = "" ;
		//String logType = "1" ; //日志类型：合规巡检作业
		for(Integer jobCode : jobCodes) {
			//JEDA作业对象
			CheckJobInfoVo cjjiv = (CheckJobInfoVo)getJobById(jobCode);
			//插入执行日志表			String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
			String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
			CmnLogVo cmnLog = new CmnLogVo(); 
			cmnLog.setAppsysCode(cjjiv.getAppsys_code());
			cmnLog.setLogResourceType("3"); //1:自动化平台、2：BRPM、3：BSA
			cmnLog.setRequestName(cjjiv.getJob_name()+"_execute");
			cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
			cmnLog.setExecStatus(logState);
			cmnLog.setExecDate(execdate);
			cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
			Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cmnLog.setExecCompletedTime(ts);
			cmnLog.setExecCreatedTime(ts);
			cmnLog.setExecUpdatedTime(ts);
			cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
			Long logJnlNo = cmnLogService.save(cmnLog);
			//BSA接口调用
			int m = 0 ; //BSA失败的作业个数
			String starttimedet = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
			jobPath = cjjiv.getJob_path();
			jobName = cjjiv.getJob_name();
			//scriptName = cjjiv.getScript_name();
			//根据路径和作业名称获取作业的DBKey
			if(!jobPath.equals("") && !jobName.equals("")){
				cliResponse = cliClient.executeCommandByParamList("ComplianceJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
				if(cliResponse.get_return().getSuccess()){
					jobDBKey = (String)cliResponse.get_return().getReturnValue();
				}else{
					logger.info("ComplianceJob:getDBKeyByGroupAndName执行失败！");
					logState = "3";
				}
			}
		    //根据作业DBKey执行作业
			if(!jobDBKey.equals("")){
				//等待执行结果
				cliResponse = cliClient.executeCommandByParamList("ComplianceJob", "executeJobAndWait", new String[]{jobDBKey});
				//不等待执行结果
				//cliResponse = cliClient.executeCommandByParamList("Job", "execute", new String[]{jobDBKey});
				if(!cliResponse.get_return().getSuccess()){
					m++;
					logger.info("Job:execute执行失败！");
					logState = "3";
				}else{
				}
				//保存作业执行日志信息
				//scriptExecService.saveJob(jobName,jobPath,scriptName,jobDBKey,logType);
			}else{
				m++;
				logger.info("jobDBKey为空！");
				logState = "3";
			}
			//插入详细日志表			CmnDetailLogVo cdlv = new CmnDetailLogVo();
			cdlv.setLogJnlNo(logJnlNo);
			cdlv.setDetailLogSeq("1");
			cdlv.setAppsysCode(cjjiv.getAppsys_code());
			cdlv.setStepName(cjjiv.getJob_name());
			cdlv.setJobName("--");
			cdlv.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
			cdlv.setExecStatus(logState);
			cdlv.setExecDate(execdate);
			cdlv.setExecStartTime(Timestamp.valueOf(starttimedet));
			Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cdlv.setExecCompletedTime(timestamp);
			cdlv.setExecCreatedTime(timestamp);
			cdlv.setExecUpdatedTime(timestamp);
			cmnDetailLogService.save(cdlv);
				
			if(m>0){
				fail++;
				failCode = failCode+jobCode+"、";
			}
			Timestamp endTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cmnLog.setExecCompletedTime(endTime);
			cmnLog.setExecUpdatedTime(endTime);
			cmnLogService.update(cmnLog);
		}
		returnStr = String.valueOf(jobCodes.length)+","+String.valueOf(jobCodes.length-fail)+","+String.valueOf(fail);
		if(!failCode.equals("")){
			failCode = failCode.substring(0,failCode.length()-1);
			returnStr = returnStr+","+failCode;
		}
		return returnStr;
	}
	
	/**
	 * 根据数据字典显示值获取数据库实际值	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public Map<String, String> findMap() {
		List<Map<String, String>> itemList = new ArrayList<Map<String, String>>();
		Map<String,String> itemMap = new HashMap<String,String>();
		StringBuilder sql = new StringBuilder();
		sql.append("  select name as \"name\", value as \"value\"  from ( ")
           .append("  select T.ITEM_ID || T.SUB_ITEM_VALUE as name, T.SUB_ITEM_NAME as value from jeda_sub_item t) o");
		SQLQuery query = getSession().createSQLQuery(sql.toString());
		itemList=query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
		for (Map<String, String> map : itemList) {
			itemMap.put(map.get("name") , map.get("value"));
		}
		return  itemMap;
	}

	public Object getServer(String serverIp, String sort,
			String dir) {
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.serverIp as \"serverIp\",")
		.append("o.serverName as \"serverName\",  ")
		.append("o.bsaAgentFlag as \"bsaAgentFlag\", ")
		.append("o.floatingIp as \"floatingIp\",  ")
		.append("o.osType as \"osType\", ")
		.append("o.appsysCode as \"appsysCode\", ")
		.append("o.deleteFlag as \"deleteFlag\" ")
		.append("from   ( SELECT SERVER_IP as serverIp,")
		.append("SERVER_NAME as serverName, ")
		.append("BSA_AGENT_FLAG as bsaAgentFlag,")
		.append("FLOATING_IP as floatingIp, ")
		.append("OS_TYPE as osType,")
		.append("APPSYS_CODE as appsysCode,")
		.append("DELETE_FLAG as deleteFlag ")
		.append("FROM CMN_SERVERS_INFO ) o where o.deleteFlag='0' and o.bsaAgentFlag='1' ");
		sql.append(" and o.appsysCode in :sysList");
		sql.append(" and o.serverIp like  '" + serverIp + "%'");
		sql.append(" order by o." + sort + " " + dir);
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		return query.list();
	}

	public Object getCheckedServer(Integer job_code) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.appsys_code as appsysCode,");
 		hql.append("e.server_path as osType,");
 		hql.append("e.server_name as serverIp");
		hql.append(") from CheckJobServerVo e where e.job_code=?");
		hql.append(" order by e.server_name");
		logger.info(hql.toString());
		//Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString()).setFirstResult(start).setMaxResults(limit);
		Query query = getSession().createQuery(hql.toString()).setString(0, job_code.toString());
		return query.list();
	}

	public void exeJob(List<Map<String, Object>> list, String jobCode) throws Exception {
		// TODO Auto-generated method stub
		StringBuffer server = new StringBuffer();
		for (Map<String, Object> mapprarm : list) {
			server.append(ComUtil.checkJSONNull(mapprarm.get("serverIp")));
			server.append(",");
		}
		StringBuilder sql = new StringBuilder();
		sql.append("select t.job_path,t.job_name  from check_job_info t where t.job_code="+jobCode+"");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> map=query.list();
		for(int i=0;i<map.size();i++){
			String dbKey=(String) groupComplianceJobDbKey(map.get(i).get("JOB_PATH"), map.get(i).get("JOB_NAME"));
			executeAgainstServers(dbKey, server.substring(0,server.lastIndexOf(",")).toString());
		}
	}
	/**
	 * ComplianceJob DbKey的获取
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object groupComplianceJobDbKey(String COMPJOB_GROUP,String COMPJOB_NAME) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("ComplianceJob","getDBKeyByGroupAndName",new String[] {COMPJOB_GROUP,COMPJOB_NAME});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * ComplianceJob 指定服务器执行作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object executeAgainstServers(String COMPJOB_DBKEY,String server) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","executeAgainstServers",new String[] {COMPJOB_DBKEY,server});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
}




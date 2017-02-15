package com.nantian.check.service;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.axis2.AxisFault;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnDetailLogVo;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 应用巡检作业设计service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class AppJobExcuteService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppJobExcuteService.class);

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
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	@Autowired
	private ScriptExecService scriptExecService;
	
	public String frontFlag = "一线";
	
	/**
	 * 构造方法	 */
	public AppJobExcuteService() {
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
		//应用巡检作业字段
		fields.put("script_name", FieldType.STRING);
		fields.put("exec_path", FieldType.STRING);
		fields.put("exec_user", FieldType.STRING);
		fields.put("exec_user_group", FieldType.STRING);
		fields.put("language_type", FieldType.STRING);
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
		   .append(" e.script_name as \"script_name\",")
 		   .append(" e.exec_path as \"exec_path\",")
 		   .append(" e.exec_user as \"exec_user\",")
 		   .append(" e.exec_user_group as \"exec_user_group\",")
 		   .append(" e.language_type as \"language_type\",")
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
		String scriptName = "" ;
		String logType = "1" ; //日志类型：合规巡检作业
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
			jobName= cjjiv.getJob_name();
			scriptName = cjjiv.getScript_name();
			//根据路径和作业名称获取作业的DBKey
			if(!jobPath.equals("") && !jobName.equals("")){
				cliResponse = cliClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
				if(cliResponse.get_return().getSuccess()){
					jobDBKey = (String)cliResponse.get_return().getReturnValue();
				}else{
					logger.info("NSHScriptJob:getDBKeyByGroupAndName执行失败！");
					logState = "3";
				}
			}
		    //根据作业DBKey执行作业
			if(!jobDBKey.equals("")){
				//不等待执行结果
				//cliResponse = cliClient.executeCommandByParamList("Job", "execute", new String[]{jobDBKey});
				//等待执行结果
				cliResponse = cliClient.executeCommandByParamList("NSHScriptJob", "executeJobAndWait", new String[]{jobDBKey});
				if(!cliResponse.get_return().getSuccess()){
					m++;
					logger.info("Job:execute执行失败！");
					logState = "3";
				}else{
				}
				//保存作业执行日志信息
				scriptExecService.saveJob(jobName,jobPath,scriptName,jobDBKey,logType);
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
	
}




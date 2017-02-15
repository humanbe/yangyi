package com.nantian.dply.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.RequestsVo;
import com.nantian.dply.vo.StepsVo;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;
@Service
public class ExcelCreateRequestService {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveBrpmExportService.class);
	public static Map<String,String> fields = new HashMap<String,String>();
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	private SecurityUtils securityUtils;
	/** BRPM调用接口 */
	@Autowired
	private BrpmService method;
 
	@Autowired
	private UserService userService;
	
	public Session getSession(){
		return sessionFactory.getCurrentSession();
	}

	/**
     * 构造方法
     */
    public ExcelCreateRequestService() {
        
    }
	
	/**
     * 查询数据
     * 
     * @param Integer start
     * @param Integer limit
     * @param String sort
     * @param String dir
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings({ "unchecked" })
    @Transactional(readOnly = true)
    public List<Map<String, String>> queryExcelCreateRequestService(Integer start, Integer limit, String sort, String dir, String name, String app, String environment, String requestStatus) {

        StringBuilder sql = new StringBuilder();
        sql.append(" select * from ( ")
        	.append(" select r.id as \"requestId\", ")
        	.append(" r.name as \"name\", ")
        	.append(" r.app as \"app\", ")
        	.append(" r.environment as \"environment\", ")
        	.append(" r.brpm_request_id as \"brpmRequestId\", ")
        	.append(" to_char(r.created_at, 'yyyymmdd hh24:mi:ss') as \"createdAt\", ")
        	.append(" to_char(r.updated_at, 'yyyymmdd hh24:mi:ss') as \"updatedAt\", ") 
        	.append(" (select count(*) from steps s where s.request_id = r.id) as \"stepNum\", ")
        	.append(" (select count(*) from steps s where s.request_id = r.id and s.create_status='完成') as \"stepFinishNum\", ")
        	.append(" case when (select count(*) from steps s where s.request_id = r.id and s.create_status='失败'）>0 then '失败' ")
        	.append("     when (select count(*) from steps s where s.request_id = r.id and s.create_status='完成'）=(select count(*) from steps s where s.request_id = r.id) then '完成' ")
        	.append("     when (select count(*) from steps s where s.request_id = r.id and s.create_status='等待'）=(select count(*) from steps s where s.request_id = r.id) then '等待' ")
        	.append("  else '进行中' ")
        	.append("  end")
        	.append("  as \"requestStatus\" ")
        	.append(" from requests r where r.app in (:sysList) and r.environment in (:envList) ")//r.app in :sysList
        	.append(" ) t where 1=1 ");
        
        if(null != name && name.length() > 0){
        	sql.append(" and t.\"name\" like '%" + name+"%'");
        }
        
        if(null != app && app.length() > 0){
        	sql.append(" and t.\"app\" = '" + app+"'");
        }
        
        if(null != environment && environment.length() > 0){
        	sql.append(" and t.\"environment\" = '" + environment+"'");
        }
        
        if(null != requestStatus && requestStatus.length() > 0){
        	sql.append(" and t.\"requestStatus\" = '" + requestStatus+"'");
        }
    	sql.append(" order by t.\"requestId\" DESC ");

        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult(start).setMaxResults(limit);
        
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		query.setParameterList("envList", userService.getPersonalEnvs());

        List<Map<String, String>> s=query.list();
        return s;
    }
    
    /**
     * 查询数据总数
     * 
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return Long
     */
    @Transactional(readOnly = true)
    public Long countExcelCreateRequestService(String name, String app, String environment, String requestStatus) {

    	StringBuilder sql = new StringBuilder();
    	/*sql.append("select count(*) ")
    	.append("from requests r where  r.app in :sysList ");*/

    	sql.append("select count(*) from (")
	    	.append("select r.id as \"requestId\",")
	    	.append("r.name as \"name\",")
	    	.append("r.app as \"app\",")
	    	.append("r.environment as \"environment\",")
	    	.append("r.brpm_request_id as \"brpmRequestId\",")
	    	.append("to_char(r.created_at, 'yyyymmdd hh24:mi:ss') as \"createdAt\",")
	    	.append("to_char(r.updated_at, 'yyyymmdd hh24:mi:ss') as \"updatedAt\",") 
	    	.append("(select count(*) from steps s where s.request_id = r.id) as \"stepNum\", ")
	    	.append("(select count(*) from steps s where s.request_id = r.id and s.create_status='完成') as \"stepFinishNum\", ")
	    	.append("case when (select count(*) from steps s where s.request_id = r.id and s.create_status='失败'）>0 then '失败'")
	    	.append("     when (select count(*) from steps s where s.request_id = r.id and s.create_status='完成'）=(select count(*) from steps s where s.request_id = r.id) then '完成'")
	    	.append("     when (select count(*) from steps s where s.request_id = r.id and s.create_status='等待'）=(select count(*) from steps s where s.request_id = r.id) then '等待'")
	    	.append("  else '进行中'")
	    	.append("  end")
	    	.append("  as \"requestStatus\"")
	    	.append(" from requests r where r.app in (:sysList) and r.environment in (:envList) ")//r.app in :sysList
	    	.append(" ) t where 1=1");
    
	    if(null != name && name.length() > 0){
	    	sql.append(" and t.\"name\" like '%" + name+"%'");
	    }
	    
	    if(null != app && app.length() > 0){
	    	sql.append(" and t.\"app\" = '" + app+"'");
	    }
	    
	    if(null != environment && environment.length() > 0){
	    	sql.append(" and t.\"environment\" = '" + environment+"'");
	    }
	    
	    if(null != requestStatus && requestStatus.length() > 0){
	    	sql.append(" and t.\"requestStatus\" = '" + requestStatus+"'");
	    }
        
	    Query query = getSession().createSQLQuery(sql.toString());
	    query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		query.setParameterList("envList", userService.getPersonalEnvs());

        return Long.valueOf(query.uniqueResult().toString());
    }
    
    /**
     * 查询数据
     * 
     * @param Integer start
     * @param Integer limit
     * @param String sort
     * @param String dir
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return List<Map<String, String>>
     */
	@Transactional(readOnly = true)
    public Object queryExcelCreateStepService(Integer start, Integer limit, String sort, String dir,Integer requestsId) {

        StringBuilder sql = new StringBuilder();
        sql.append("select s.id as \"id\",")
        	.append("s.position as \"position\",")
        	.append("s.request_id as \"requestId\",")
        	.append("s.name as \"name\",")
        	.append("s.different_level_from_previous as \"differentLevelFromPrevious\",")
        	.append("s.service_code as \"serviceCode\",")
        	.append("s.servers as \"servers\",")
        	.append("s.component as \"component\",")
        	.append("s.manual as \"manual\",")
        	.append("s.owner as \"owner\",")
        	.append("s.auto_job_name as \"autoJobName\",")
        	.append("s.create_status as \"createStatus\",")
        	.append("s.operate_log as \"operateLog\",")
        	.append("s.created_at as \"createdAt\",")
        	.append("s.updated_at as \"updatedAt\" ")
        	.append(" from steps s where s.request_id = '"+requestsId.toString()+"'")
        	.append(" order by s.position ASC ");
        return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult(start).setMaxResults(limit).list();
    }
    
    /**
     * 查询数据总数
     * 
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return Long
     */
    @Transactional(readOnly = true)
    public Long countExcelCreateStepService(Integer requestsId) {

    	StringBuilder sql = new StringBuilder();
    	sql.append("select count(*) ")
    		.append(" from steps s where s.request_id = "+requestsId);
	    Query query = getSession().createSQLQuery(sql.toString());
        return Long.valueOf(query.uniqueResult().toString());
    }
    
    /**
	 * 
	 * 查询登录用户关联应用系统信息列表
	 * 
	 * @param String userId
	 * 
	 * @return Object
	 * 
	 * 
	 */
    @Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUser(String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("select s.appsys_code as \"appsysCode\", ")
				.append(" s.systemname as \"appsysName\" ")
				.append(" from v_cmn_app_info s  ")
				.append(" where exists (select * from cmn_user_app u  ")
				.append(" where s.appsys_code = u.appsys_code ")
				.append(" and u.user_id = :userId)   and s.status = '使用中' and s.delete_flag=0 ")
				.append(" order by s.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * 
	 * @param String userId
	 * 
	 * @return Object
	 */
    @Transactional(readOnly = true)
	 public Object queryEnv(String userId) {
	  StringBuilder sql = new StringBuilder();
	  sql.append("select c.environment_code as \"env\", j.sub_item_name ||'('|| c.environment_code||')'  as \"envName\"" );
	  sql.append(" from cmn_environment c, jeda_sub_item j ,v_cmn_app_info s");
	  sql.append(" where exists (select * from cmn_user_app u " );
	  sql.append("where s.appsys_code = u.appsys_code and c.appsys_code = u.appsys_code  and c.appsys_code in :sysList");
	  sql.append(" and u.user_id = :userId )  and c.environment_type = j.sub_item_value and j.item_id='SYSTEM_ENVIRONMENT' and s.status = '使用中' and c.environment_code in :envList");
	  return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
	    .setParameterList("envList", userService.getPersonalEnvs())
	    .setParameterList("sysList", appInfoService.getPersonalSysListForDply())
	    .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();  
	 }
	
	@Transactional(readOnly = true)
	public String checkRequestsList(HSSFSheet sheet) throws IOException, BrpmInvocationException, URISyntaxException{
		
		
		String requestName = sheet.getRow(0).getCell(1).toString();
		String app = sheet.getRow(1).getCell(1).toString();
		String environment = null;
		if(sheet.getRow(2).getCell(1).toString().equals("开发")){
			environment = app+"_DEV_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("测试")){
			environment = app+"_QA_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("验证")){
			environment = app+"_PROV_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("生产")){
			environment = app+"_PROD_ENV";
		}
		List<String> envList = userService.getPersonalEnvs();
		String envs = "";
		if(envList.size()==1) {
			return "联机校验失败，该用户没有环境权限！(请联系平台管理员授权)";
		}else {
			for(int i=0;i<envList.size();i++){
				envs += envList.get(i);
			}
		}
		if(envs.indexOf(environment)==-1) return "联机校验失败，该用户没有"+sheet.getRow(2).getCell(1).toString()+"环境权限！(请联系平台管理员授权)";
		
		String msg = method.checkRequest(requestName,environment);
		
		if(!msg.equals("") || msg.length()!=0 ){
			return "联机校验失败，要新建的请求名已存在！";
		};
		
		
		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_APPS + " { \"filters\": { \"name\":\"" + app + "\" }}");
		String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + app + "\" }}");
		logger.log("BRPM0002", appsXml);
		if(appsXml==null)return "联机校验失败，新建请求要关联的应用不存在！";
		
		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_ENVIRONMENTS + " { \"filters\": { \"name\":\"" + environment + "\" }}");
		String environmentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS, "{ \"filters\": { \"name\":\"" + environment + "\" }}");
		logger.log("BRPM0002", environmentsXml);
		if(environmentsXml==null)return "联机校验失败，新建请求要关联的环境不存在！";
		
		

		return "true";
	}
	
	@Transactional
	public RequestsVo achieveRequestsList(HSSFSheet sheet) throws IOException{
		
		
		String requestName = sheet.getRow(0).getCell(1).toString();
		String app = sheet.getRow(1).getCell(1).toString();
		String environment = null;
		if(sheet.getRow(2).getCell(1).toString().equals("开发")){
			environment = app+"_DEV_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("测试")){
			environment = app+"_QA_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("验证")){
			environment = app+"_PROV_ENV";
		}
		if(sheet.getRow(2).getCell(1).toString().equals("生产")){
			environment = app+"_PROD_ENV";
		}

		
		Date date = new Date();
		Timestamp createdAt =new Timestamp(date.getTime());
		RequestsVo requestsVo = new RequestsVo();
		requestsVo.setName(requestName);
		requestsVo.setApp(app);
		requestsVo.setEnvironment(environment);
		requestsVo.setCreatedAt(createdAt);

		return requestsVo;
	}
	
	
	
	@Transactional
	public String checkStepsList(HSSFSheet sheet,RequestsVo requestsVo,Long requestId) throws IOException, BrpmInvocationException, URISyntaxException, Exception{
		
		
		String app = requestsVo.getApp();
		
		
		String serviceCode = null;
		String component = null;
		Long manual = null;
		String owner = null;
		String autoJobName = null;

		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userName")
				,messages.getMessage("bsa.userPassword")
				,messages.getMessage("bsa.authenticationType")
				,null
				,new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("bsa.truststoreFile"))
					.toString()
				,messages.getMessage("bsa.truststoreFilePassword"));
		loginResponse = loginClient.loginUsingUserCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		boolean b=false;
		boolean c=false;
		String reqName=sheet.getRow(0).getCell(1).toString();
		String s="";
		for(int i=5;;i++){
			if(null==sheet.getRow(i)||sheet.getRow(i).getCell(0).toString().equals(""))break;
			
			owner = sheet.getRow(i).getCell(6).toString();
			autoJobName = sheet.getRow(i).getCell(7).toString();
			if(sheet.getRow(i).getCell(4).toString().equals("自动化")){
				
				manual = 0L;
				if(null==sheet.getRow(i).getCell(3)||sheet.getRow(i).getCell(3).toString().equals("")){
					b=true;
					s=s+"自动化请求编号："+reqName+"的"+sheet.getRow(i).getCell(2).toString()+"步骤名称没有绑定组件。";
				
				}
				if(null==sheet.getRow(i).getCell(1)||sheet.getRow(i).getCell(1).toString().equals("")){
					c=true;
					s=s+"自动化的请求编号："+reqName+"的"+sheet.getRow(i).getCell(2).toString()+"服务编码不可为空。";
				
				}
			
			if(b||c){return s.toString();}else{
				serviceCode = sheet.getRow(i).getCell(1).toString();
				component = sheet.getRow(i).getCell(3).toString();
			}
			}
			if(sheet.getRow(i).getCell(4).toString().equals("人工")){
				manual = 1L;
			}
			
			
			logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_COMPONENTS + " { \"filters\": { \"name\":\"" + component + "\" }}");
			String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + component + "\" }}");
			logger.log("BRPM0002", componentsXml);
			if(manual==0&&componentsXml==null)return "联机校验失败，新建请求要关联的组件不存在！";

			logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_USER + " { \"filters\": { \"keyword\":\"" + owner + "\" }}");
			String usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"keyword\":\"" + owner + "\" }}");
			logger.log("BRPM0002", usersXml);
			if(usersXml==null)return "联机校验失败，新建请求要关联的用户不存在！";
			
			if(manual==0&&autoJobName!=null&&autoJobName.indexOf(CommonConst.DB_CHECK)==-1){
				String jobPath = messages.getMessage("bsa.deployPath").concat(requestsVo.getEnvironment().split("_")[1]).concat("/").concat(app).concat("/").concat(serviceCode);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{jobPath,autoJobName});
				String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,autoJobName});
				String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				if(DeployJobDBkey.equals("void")&&NSHScriptJob.equals("void")){
					return "联机校验失败，新建请求的自动化步骤要关联的自动化作业"+jobPath+"/"+autoJobName+"不存在！";
				}
			}
			
			
			
		}
		
		return "true";
			
	}	
	
	@Transactional
	public List<StepsVo> achieveStepsList(HSSFSheet sheet,RequestsVo requestsVo,Long requestId) throws IOException, BrpmInvocationException, URISyntaxException, Exception{
		
		Long position = null;
		String serviceCode = null;
		String stepName = null;
		String component = null;
		Long manual = null;
		Long differentLevelFromPrevious = null;
		String owner = null;
		String autoJobName = null;

		List<StepsVo> stepsList = new ArrayList<StepsVo>();
		StepsVo stepsVo=null;
		for(int i=5;;i++){
			if(null==sheet.getRow(i)||sheet.getRow(i).getCell(0).toString().equals(""))break;
			position = Long.valueOf(sheet.getRow(i).getCell(0).getStringCellValue());
			stepName = sheet.getRow(i).getCell(2).toString();
			
			if(sheet.getRow(i).getCell(4).toString().equals("自动化")){
				manual = 0L;
				serviceCode = sheet.getRow(i).getCell(1).toString();
				component = sheet.getRow(i).getCell(3).toString();
			}
			if(sheet.getRow(i).getCell(4).toString().equals("人工")){
				manual = 1L;
				if(null==sheet.getRow(i).getCell(1)){
					serviceCode ="";
					component = "";
				}else{
					serviceCode = sheet.getRow(i).getCell(1).toString();
					component = sheet.getRow(i).getCell(3).toString();
				}
				
			}
			
			if(sheet.getRow(i).getCell(5).toString().equals("否")){
				differentLevelFromPrevious = 1L;
			}
			if(sheet.getRow(i).getCell(5).toString().equals("是")){
				differentLevelFromPrevious = 0L;
			}
			owner = sheet.getRow(i).getCell(6).toString();
			autoJobName = sheet.getRow(i).getCell(7).toString();

			stepsVo = new StepsVo();
			stepsVo.setPosition(position);
			stepsVo.setServiceCode(serviceCode);
			stepsVo.setName(stepName);
			stepsVo.setComponent(component);
			stepsVo.setManual(manual);
			stepsVo.setDifferentLevelFromPrevious(differentLevelFromPrevious);
			stepsVo.setOwner(owner);
			stepsVo.setAutoJobName(autoJobName);
			stepsVo.setCreateStatus(CommonConst.MOVESTATUS_WAIT_CH);
			stepsVo.setRequestId(requestId);
			stepsList.add(stepsVo);
			
		}
		return stepsList;
	}
	
	/**
	 * 处理导入信息
	 */
	@Transactional
	public void saveStepsVo(List<StepsVo> stepsList) {
		for(int i=0;i<stepsList.size();i++){
			saveSteps(stepsList.get(i));
		}
	}
	
	/**
	 * 保存信息
	 */
	@Transactional
	public void saveSteps(StepsVo stepsVo) {
		getSession().save(stepsVo);		
	}
	/**
	 * 保存信息
	 */
	@Transactional
	public Long saveRequests(RequestsVo requestsVo) {
		return (Long)getSession().save(requestsVo);		
	}
	
	/**
     * 
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * 
     */
    @Transactional
	public void updateStepsRunningVo(Long requestId,String stepName,String createStatus){
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		getSession().createQuery(
			"update StepsVo s set s.createStatus = :createStatus,s.createdAt = :createdAt where s.requestId=:requestId and s.name=:name ")
				.setString("createStatus", createStatus)
				.setTimestamp("createdAt", tt)
				.setLong("requestId", requestId)
				.setString("name", stepName)
				.executeUpdate();
	}
    	
    /**
     * 
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * 
     */
    @Transactional
	public void updateStepsOkVo(Long requestId,String stepName,String createStatus){
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		getSession().createQuery(
			"update StepsVo s set s.createStatus = :createStatus,s.updatedAt = :updatedAt where s.requestId=:requestId and s.name=:name ")
				.setString("createStatus", createStatus)
				.setTimestamp("updatedAt", tt)
				.setLong("requestId", requestId)
				.setString("name", stepName)
				.executeUpdate();
	}
    
    /**
     * 
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * 
     */
    @Transactional
	public void updateStepsErrVo(Long requestId,String stepName,String createStatus,String operateLog){
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		getSession().createQuery(
			"update StepsVo s set s.createStatus = :createStatus,s.updatedAt = :updatedAt,s.operateLog = :operateLog where s.requestId=:requestId and s.name=:name ")
				.setString("createStatus", createStatus)
				.setTimestamp("updatedAt", tt)
				.setString("operateLog", operateLog)
				.setLong("requestId", requestId)
				.setString("name", stepName)
				.executeUpdate();
	}
    
	/**
	 * 保存信息
	 * @throws URISyntaxException 
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 */
    @Transactional
	public String createRequests(RequestsVo requestsVo) throws IOException, BrpmInvocationException, URISyntaxException {
		String requestName = requestsVo.getName();
		String app = requestsVo.getApp();
		String environment = requestsVo.getEnvironment();
		
		String usersXml;
		String requestor_id = "";
		
		String owner = securityUtils.getUser().getUsername();

		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_USER + " { \"filters\": { \"keyword\":\"" + owner + "\" }}");
		usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"keyword\":\"" + owner + "\" }}");
		logger.log("BRPM0002", usersXml);
		if(usersXml!=null){
			Document docUsers = JDOMParserUtil.xmlParse(usersXml);
			Element rootUsers = docUsers.getRootElement();
			requestor_id = rootUsers.getChild("user").getChildText("id");
		}
		
		StringBuffer requestXml = new StringBuffer();
		requestXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
			.append("<request>")
			.append("<name>")
			.append(requestName)
			.append("</name>")
			.append("<deployment_coordinator_id>")
			.append(requestor_id)
			.append("</deployment_coordinator_id>")
			.append("<requestor_id>")
			.append(requestor_id)
			.append("</requestor_id>")
			.append("<owner_id>")
			.append(requestor_id)
			.append("</owner_id>");
		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_ENVIRONMENTS + " { \"filters\": { \"name\":\"" + environment + "\" }}");
		String environmentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS, "{ \"filters\": { \"name\":\"" + environment + "\" }}");
		logger.log("BRPM0002", environmentsXml);
		if(environmentsXml!=null){
			Document docEnvironments = JDOMParserUtil.xmlParse(environmentsXml);
			Element rootEnvironments = docEnvironments.getRootElement();
			String id = rootEnvironments.getChild("environment").getChildText("id");
			requestXml.append("<environment_id>")
				.append(id)
				.append("</environment_id>");
		}
		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_APPS + " { \"filters\": { \"name\":\"" + app + "\" }}");
		String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + app + "\" }}");	
		logger.log("BRPM0002", appsXml);
		if(appsXml!=null){
			Document docApps = JDOMParserUtil.xmlParse(appsXml);
			Element rootApps = docApps.getRootElement();
			String id = rootApps.getChild("app").getChildText("id");	
			requestXml.append("<app_ids>")
				.append(id)
				.append("</app_ids>");
		}
		requestXml.append("</request>");
		logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_REQUSET +  " " + requestXml.toString());
		String requestNewXml = method.postMethod(BrpmConstants.KEYWORD_REQUSET,requestXml.toString());
		logger.log("BRPM0002", requestNewXml);
		return requestNewXml;
	
	}
	
	/**
	 * 处理导入信息
	 * @throws NoSuchMessageException 
	 * @throws URISyntaxException 
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 */
    @Transactional(readOnly=true,propagation=Propagation.NOT_SUPPORTED)
	public void createSteps(List<StepsVo> stepsList,String requestNewXml,RequestsVo requestsVo,Long requestId){
    	String app = requestsVo.getApp();
		String serviceCode = null;
		String stepName = null;
		String component = null;
		String component_id=null;
		Long manual = null;
		Long differentLevelFromPrevious = null;
		String owner = null;
		String autoJobName = null;
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
		for(int i=0;i<stepsList.size();i++){
			try{
				//position = stepsList.get(i).getPosition();
				serviceCode = stepsList.get(i).getServiceCode();
				stepName = stepsList.get(i).getName();
				component = stepsList.get(i).getComponent();
				manual = stepsList.get(i).getManual();
				differentLevelFromPrevious = stepsList.get(i).getDifferentLevelFromPrevious();
				owner = stepsList.get(i).getOwner();
				autoJobName = stepsList.get(i).getAutoJobName();
				
				updateStepsRunningVo(requestId,stepName, CommonConst.MOVESTATUS_RUNNING_CH);
				
				String usersXml;
				String requestor_id = "";
				
				logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_USER + " { \"filters\": { \"keyword\":\"" + owner + "\" }}");
				usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"keyword\":\"" + owner + "\" }}");
				logger.log("BRPM0002", usersXml);
				if(usersXml!=null){
					Document docUsers = JDOMParserUtil.xmlParse(usersXml);
					Element rootUsers = docUsers.getRootElement();
					requestor_id = rootUsers.getChild("user").getChildText("id");
				}
				
				
				StringBuilder stepXml = new StringBuilder();
				stepXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
					.append("<step>")
					.append("<name>")
					.append(stepName)
					.append("</name>");
				Document docRequests = JDOMParserUtil.xmlParse(requestNewXml);
				Element rootRequests = docRequests.getRootElement();		
				stepXml.append("<request_id>")
					.append(rootRequests.getChildText("id"))
					.append("</request_id>");
				String description = "";
				stepXml.append("<manual>")
					.append(manual)
					.append("</manual>");
				if (manual==0L) {
					
					stepXml.append("<script_id>")
						.append("10000")
						.append("</script_id>")
						.append("<script_type>BladelogicScript</script_type>");
					
				}
				stepXml.append("<owner_id>")
					.append(requestor_id)
					.append("</owner_id>");
				stepXml.append("<owner_type>")
					.append("User")
					.append("</owner_type>");
				
				logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_COMPONENTS + " { \"filters\": { \"name\":\"" + component + "\" }}");
				if(null==component||"".equals(component)){
					 component_id ="";
				}else{
					String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + component + "\" }}");
					logger.log("BRPM0002", componentsXml);
					Document docComponents = JDOMParserUtil.xmlParse(componentsXml);
					Element rootComponents = docComponents.getRootElement();
				     component_id = rootComponents.getChild("component").getChildText("id");
				}
				
				stepXml.append("<component_id>")
					.append(component_id)
					.append("</component_id>")
					.append("<installed_component_id>")
					.append(component_id)
					.append("</installed_component_id>");
				
				
				stepXml.append("<different_level_from_previous>")
					.append(differentLevelFromPrevious)
					.append("</different_level_from_previous>")
					.append("</step>");
				
				logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_STEPS +  " " + stepXml.toString());
				String postStepXml = method.postMethod(BrpmConstants.KEYWORD_STEPS,stepXml.toString());
				logger.log("BRPM0002", postStepXml);
				if (manual==0L) {
					Document docStepDoc = JDOMParserUtil.xmlParse(postStepXml);
					Element StepRoot = docStepDoc.getRootElement();
					String id = StepRoot.getChildText("id");
					//if(description.indexOf("#")!=-1){
					String jobPath = null;
					String jobName = null;
					if(autoJobName.indexOf(CommonConst.DB_CHECK)!=-1){
						jobPath = CommonConst.DB_CHECK_PATH;
						jobName = CommonConst.DB_CHECK;
						
					}else{
						jobPath = messages.getMessage("bsa.deployPath").concat(requestsVo.getEnvironment().split("_")[1]).concat("/").concat(app).concat("/").concat(serviceCode);
						jobName = autoJobName;
					}
						
						// 用户登录
						loginClient = new LoginServiceClient(
								messages.getMessage("bsa.userName")
								,messages.getMessage("bsa.userPassword")
								,messages.getMessage("bsa.authenticationType")
								,null
								,new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("bsa.truststoreFile"))
									.toString()
								,messages.getMessage("bsa.truststoreFilePassword"));
						loginResponse = loginClient.loginUsingUserCredential();
						
						CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
						
						executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
						String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
						
						executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
						String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
						//String brpmToBsaInfo = null;
						String jobType = null;
						if(DeployJobDBkey.equals("void")&&NSHScriptJob.equals("void")){
							//brpmToBsaInfo = "请求步骤".concat(stepName).concat("关联BSA作业").concat(jobPath).concat("/").concat(jobName).concat("失败,因为此作业不存在！");
							break;
						}else if(!DeployJobDBkey.equals("void")){
							jobType = "DeployJob";
						}else if(!NSHScriptJob.equals("void")){
							jobType = "NSHScriptJob";
						}
						
						executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(jobType,"getDBKeyByGroupAndName",new String[] { jobPath,jobName });
						String groupNameToDBKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
						
						executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupNameToDBKey",new String[] { jobPath });
						String groupNameToDBKey2 = (String) executeCommandByParamListResponse.get_return().getReturnValue();
						
						if(!groupNameToDBKey.equals("void")&&!groupNameToDBKey2.equals("void")){
							
							executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("GenericObject","getRESTfulURI",new String[] { groupNameToDBKey });
							String getRESTfulURI = (String) executeCommandByParamListResponse.get_return().getReturnValue();
							
							if(getRESTfulURI.lastIndexOf("/")!=-1){
								getRESTfulURI = getRESTfulURI.substring(getRESTfulURI.lastIndexOf("/")+1);
								logger.log("BRPM0001", "update steps and insert into step_script_arguments");
								method.scriptArguId(id,	groupNameToDBKey,getRESTfulURI, jobName,jobType);
							}
						}
					//}
				}
			
				updateStepsOkVo(requestId,stepName, CommonConst.MOVESTATUS_OK_CH);
			}catch(Exception e){
				updateStepsErrVo(requestId,stepName, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
				break;
			}
		}
	}
	
	
    @Transactional
	public String allappDbCheck(String filePath) throws IOException, BrpmInvocationException, URISyntaxException, Exception{
		
    	
    	File f = new File(filePath);
		InputStream in = null;
		in = new FileInputStream(f);
		HSSFWorkbook workbook =  new HSSFWorkbook(in);
		
		//String allappDbCheckMsg = "";
		boolean allappDbCheckFlag = false;

		HSSFSheet sheet = null;
		
		String requestName = null;
		//String app = null;
		//String environment = null;

		//String stepName = null;
		String autoJobName = null;
		String msg = "";
		for(int i=0;i<workbook.getNumberOfSheets();i++){
			sheet = workbook.getSheetAt(i);
			if(sheet.getSheetName().toString().indexOf("request")!=-1){
				requestName = sheet.getRow(0).getCell(1).toString();
				/*app = sheet.getRow(1).getCell(1).toString();
				if(sheet.getRow(2).getCell(1).toString().equals("开发")){
					environment = app+"_DEV_ENV";
				}
				if(sheet.getRow(2).getCell(1).toString().equals("测试")){
					environment = app+"_QA_ENV";
				}
				if(sheet.getRow(2).getCell(1).toString().equals("验证")){
					environment = app+"_PROV_ENV";
				}
				if(sheet.getRow(2).getCell(1).toString().equals("生产")){
					environment = app+"_PROD_ENV";
				}*/
				allappDbCheckFlag = false;

				for(int j=5;;j++){
					if(null==sheet.getRow(j)||sheet.getRow(j).getCell(0).toString().equals(""))break;
					
					//stepName = sheet.getRow(j).getCell(2).toString();
					autoJobName = sheet.getRow(j).getCell(7).toString();
					if(autoJobName.indexOf(CommonConst.DB_CHECK)!=-1){
						allappDbCheckFlag = true;break;
					}
				}
				if(allappDbCheckFlag == false){
					msg += "待构建请求" + requestName + "缺少" + CommonConst.DB_CHECK + "步骤！</br>";
				}
			}
		}
    	
		return msg;
	}
    
}

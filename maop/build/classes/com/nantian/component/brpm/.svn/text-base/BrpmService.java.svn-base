package com.nantian.component.brpm;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.log.Logger;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * BRPM Service类

 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 *
 */
@Service
@Repository
public class BrpmService {

	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryBrpm")
	private SessionFactory sessionFactoryBrpm;
	
	public Session getSession() {
		return sessionFactoryBrpm.getCurrentSession();
	}

	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactory")
	private SessionFactory sessionFactory;
	
	public Session getSession4Maop() {
		return sessionFactory.getCurrentSession();
	}
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/** 获取登陆的用户 */
	@Autowired
	 private SecurityUtils securityUtils; 
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(BrpmService.class);
	
	
	/**获取brpm数据
	 * @param keyward
	 * @throws Exception
	 */
	public String getMethod(String keyward)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
		    return HttpClientUtils.getMethod(url.toString());
	   }
	
	/**获取brpm数据
	 * @param keyward
	 * @throws Exception
	 */
	public String getMethodByFilter(String keyward, String filter)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
		    return HttpClientUtils.getMethod(url.toString(),filter);
	   }

	/**根据id查询数据
	 * @param keyward
	 * @param id
	 * @throws Exception 
	 */
	public String getMethodById(String keyward, String id)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(CommonConst.SLASH).append(id)
			.append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
	    return HttpClientUtils.getMethod(url.toString());
	}

	/**创建BRPM数据
	 * @param keyward
	 * @param content
	 * @throws Exception
	 */
	public String postMethod(String keyward, String content)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
	    return HttpClientUtils.postMethod(url.toString(), content);
	}

	/**更新BRPM数据
	 * 
	 * @param String keyward
	 * @param String id
	 * @param String content
	 * 
	 * @return String
	 * 
	 */
	public String putMethod(String keyward, String id, String content)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(CommonConst.SLASH).append(id)
			.append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
	    return HttpClientUtils.putMethod(url.toString(), content);
	}

	/**删除BRPM数据
	 * 
	 * @param String keyward
	 * @param String id
	 * 
	 * @return String
	 * 
	 */
	public String deleteMethod(String keyward, String id)
			throws IOException, BrpmInvocationException, URISyntaxException {
		StringBuilder url = new StringBuilder();
		url.append(messages.getMessage("brpm.accessAddress"))
			.append(BrpmConstants.KEYWORD_KEY_V).append(keyward).append(CommonConst.SLASH).append(id)
			.append(BrpmConstants.KEYWORD_KEY_TOKEN)
			.append(messages.getMessage("brpm.userToken"));
		
	    return HttpClientUtils.deleteMethod(url.toString());
	}
	
	/**关联BRPM应用与环境

	 * 
	 * @param String appId
	 * @param String envId
	 * @param String appName
	 * 
	 * @throws URISyntaxException 
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 * 
	 */
	@Transactional(rollbackFor=Exception.class,value = "brpm")
	public void  saveAppsEnviroment(String appId, String envId,String appName) throws IOException, BrpmInvocationException, URISyntaxException{
		String sql;
		sql = "insert into application_environments (id,app_id,environment_id, created_at, updated_at)  values (application_environments_seq.nextval,"+appId+", "+envId+", current_timestamp, current_timestamp)";
		getSession().createSQLQuery(sql).executeUpdate();
		
		String role=messages.getMessage("brpm.userName");
		sql = "select t.id from users t where t.login='"+role+"' ";
		Object userId = getSession().createSQLQuery(sql.toString()).uniqueResult();
		
		if(null != userId && !"".equals(userId.toString())){
			sql="select t.id  from assigned_apps t where t.user_id='"+userId+"' and t.app_id='"+appId+"'";
			Object assignedId = getSession().createSQLQuery(sql.toString()).uniqueResult();
			
			if(null != assignedId && !"".equals(assignedId.toString())){
				sql = "insert into assigned_environments (id,assigned_app_id,environment_id,role,created_at, updated_at)  values (assigned_environments_seq.nextval,"+assignedId+", "+envId+",'deployer', current_timestamp, current_timestamp)";
				getSession().createSQLQuery(sql).executeUpdate();
			}
		}

		String loginUser=securityUtils.getUser().getUsername();
		sql = "select t.id from users t where t.login='"+loginUser+"' ";
		Object loginUserId = getSession().createSQLQuery(sql.toString()).uniqueResult();
		
		if(null != loginUserId && !"".equals(loginUserId.toString())){
			sql="select t.id  from assigned_apps t where t.user_id='"+loginUserId+"' and t.app_id='"+appId+"'";
			 Object loginAssignedId = getSession().createSQLQuery(sql.toString()).uniqueResult();
			
			if(null != loginAssignedId && !"".equals(loginAssignedId.toString())){
				sql = "insert into assigned_environments (id,assigned_app_id,environment_id,role,created_at, updated_at)  values (assigned_environments_seq.nextval,"+loginAssignedId+", "+envId+",'deployer', current_timestamp, current_timestamp)";
				getSession().createSQLQuery(sql).executeUpdate();
			}
		}
	}
	
	/**关联BRPM应用与用户关系

	 * 
	 * @param String appId
	 * @param String envId
	 * @param String appName
	 * 
	 * 
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws URISyntaxException 
	 * 
	 */
	@Transactional( value = "brpm")
	public void  saveAssignedEnvironments(String appId,String envId,String appName) throws IOException, BrpmInvocationException, URISyntaxException{
		String sql;
		String appXml1 = getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\"" + appName + "\" }}");
		 List<String> userIdList=null;
			Document appdoc = JDOMParserUtil.xmlParse(appXml1);
			Element approot = appdoc.getRootElement();
			List<Element> appaccounts = approot.getChildren();
			userIdList=new ArrayList<String>();
			for (Element account : appaccounts) {
				List<Element> users = account.getChild("users").getChildren();
				for(Element user:users){
					String usersId=user.getChildText("id");
					sql="select t.id  from assigned_apps t where t.user_id='"+usersId+"' and t.app_id='"+appId+"'";
					Object loginAssignedId = getSession().createSQLQuery(sql.toString()).uniqueResult();
					userIdList.add(loginAssignedId.toString());
					}
			}
			for(int i=0;i<userIdList.size();i++){
				sql="select count(*) from assigned_environments t where t.assigned_app_id='"+userIdList.get(i)+"' and t.environment_id='"+envId+"'";
				Object exist=getSession().createSQLQuery(sql.toString()).uniqueResult();
				if(Long.valueOf(exist.toString()) == 0){
					sql = "insert into assigned_environments (id,assigned_app_id,environment_id,role,created_at, updated_at)  values (assigned_environments_seq.nextval,"+userIdList.get(i)+", "+envId+",'deployer', current_timestamp, current_timestamp)";
					getSession().createSQLQuery(sql).executeUpdate();
				}
			}
	}
	
	/**关联BRPM应用与用户关系

	 * @param userId
	 * @param appId
	 * 
	 */
	@Transactional( value = "brpm")
	public void  saveAssignedApps(String userId, String appId){
		StringBuilder sql = new StringBuilder();
		sql.append("select t.id  from assigned_apps t where t.user_id='")
			.append(userId)
			.append("' and t.app_id='")
			.append(appId).append("'");
		Object assignedId = getSession().createSQLQuery(sql.toString()).uniqueResult();
		if(null == assignedId){
			sql = new StringBuilder();
			sql.append(" insert into assigned_apps ")
			.append("  ( id, user_id, app_id, created_at, updated_at ) ")
			.append(" values ")
			.append("  ( ASSIGNED_APPS_SEQ.nextval,  ").append(userId).append(", ").append(appId).append(", current_timestamp, current_timestamp )");
			getSession().createSQLQuery(sql.toString()).executeUpdate();
		}
	}
	
	/**关联BRPM应用环境与用户关系

	 * 
	 * @param userId
	 * @param appId
	 * @param List<Element> environmentList
	 * 
	 */
	@Transactional( value = "brpm")
	public void  saveAssignedAppsEnvironments(String userId, String appId, List<Element> environmentList){
		String sql;
		sql="select t.id  from assigned_apps t where t.user_id='"+userId+"' and t.app_id='"+appId+"'";
		Object assignedId = getSession().createSQLQuery(sql.toString()).uniqueResult();
		
		for (Element element : environmentList) {
			if(null != assignedId && !"".equals(assignedId.toString())){
				
				sql="select t.id  from assigned_environments t where t.assigned_app_id='"+userId+"' and t.environment_id='"+element.getChildText("id")+"'";
				Object assignedEnvId = getSession().createSQLQuery(sql.toString()).uniqueResult();
				
				if(null == assignedEnvId){
					sql = "insert into assigned_environments (id,assigned_app_id,environment_id,role,created_at, updated_at)  values (assigned_environments_seq.nextval,"+assignedId+", "+element.getChildText("id")+",'deployer', current_timestamp, current_timestamp)";
					getSession().createSQLQuery(sql).executeUpdate();
				}
			}
		}
	}
	
	/**删除BRPM应用与用户关系

	 * 
	 * @param String userId
	 * 
	 */
	@Transactional( value = "brpm")
	public void  deleteAssignedApps(String userId){
		StringBuilder sql = new StringBuilder();
		sql.append(" delete from assigned_apps ")
			.append("  where user_id =:userId ");
		
		getSession().createSQLQuery(sql.toString())
						.setParameter("userId", userId)
					.executeUpdate();
	}
	
	
	/**
	 * 通过操作数据表的方式做步骤关联自动化作业
	 * 
	 * @param String stepId
	 * @param String groupNameToDBKey
	 * @param String getRESTfulURI
	 * @param String jobName
	 * @param String jobType
	 * 
	 */
	@Transactional( value = "brpm")
	public void scriptArguId(String stepId,String groupNameToDBKey,String getRESTfulURI,String jobName,String jobType){
		
		String objectType = null;
		
		if(jobType.equals("DeployJob") ){
			objectType = "PackageDeploy";
		}else {
			objectType = "NSHScriptJob";
		}
		
		String sql1 = "select id from scripts where name ='Baa execute job against'";
		Query query1 = getSession().createSQLQuery(sql1.toString());
		String scriptsId = query1.uniqueResult().toString();
		
		String sql2 = "select id from script_arguments where  script_id='"+scriptsId+"' and rownum=1 order by id";
		Query query2 = getSession().createSQLQuery(sql2.toString());
		String scriptArgusId = query2.uniqueResult().toString();
		
		String sql3 = "update steps set script_id='"+scriptsId+"', script_type='BMC Application Automation 8.2' where id='"+stepId+"'";
		getSession().createSQLQuery(sql3.toString()).executeUpdate();
		//String scriptArgusId = query3.uniqueResult().toString();

		String insSql1 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\""+objectType+"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql1.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		//groupNameToDBKey = groupNameToDBKey.substring(groupNameToDBKey.lastIndexOf(":")+1,groupNameToDBKey.lastIndexOf(":")+8);
		//String DBKey = "DBKey:SJobModelKeyImpl:"+groupNameToDBKey+"-1-2069703";
		getRESTfulURI = getRESTfulURI.substring(getRESTfulURI.lastIndexOf("/")+1);
		String insSql2 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\""+jobName+"|"+getRESTfulURI+"|"+groupNameToDBKey+"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql2.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql3 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"MapFromBRPMServers\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql3.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql4 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql4.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql5 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql5.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql6 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql6.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql7 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql7.toString()).executeUpdate();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		
		String insSql8 = "insert into step_script_arguments (id,step_id,script_argument_id,value,created_at,updated_at,script_argument_type) values(STEP_SCRIPT_ARGUMENTS_SEQ.nextval,"+stepId+","+scriptArgusId+",'[\"\"]',sysdate,sysdate,'ScriptArgument')";
		getSession().createSQLQuery(insSql8.toString()).executeUpdate();
	}
	
	/**
	 * 通过stepId获取自动化步骤所关联的bsa自动化作业的名字和路径

	 * 
	 * @param stepId
	 * 
	 * @throws Exception
	 * 
	 * @return String
	 */
	@Transactional(readOnly = true, value = "brpm")
	public String bsaJobPath(String stepId) throws Exception{
		
		String sql1 = "select id from scripts where name ='Baa execute job against'";
		Query query1 = getSession().createSQLQuery(sql1.toString());
		String scriptsId = query1.uniqueResult().toString();
		String sql2 = "select id from script_arguments where  script_id='"+scriptsId+"' and rownum=1 order by id";
		Query query2 = getSession().createSQLQuery(sql2.toString());
		String scriptArgusId = query2.uniqueResult().toString();
		scriptArgusId = new Integer(new Integer(scriptArgusId)+1).toString();
		String sql3 = "select value from step_script_arguments where step_id = "+stepId+" and script_argument_id="+scriptArgusId;
		Query query3 = getSession().createSQLQuery(sql3.toString());
		String value = "";
		String jobPath = "";
		if(query3.uniqueResult()!=null){
			value = query3.uniqueResult().toString();
			if(value.indexOf("[\"")!=-1&&value.indexOf("|")!=-1){
				value = value.substring(value.indexOf("[\"")+2, value.indexOf("|"));
			}
			String[] folder = value.split("_");
			if(folder.length>=3){
				jobPath = messages.getMessage("path.linux")+folder[0]+messages.getMessage("path.linux")+folder[1]+"#"+value;
			}
		}
		
		return jobPath;
	}
	
	
	
	
	/**
	 * 获取请求信息
	 * 
	 * @throws Exception
	 * 
	 * @return List
	 */
	@Transactional(readOnly = true, value = "brpm")
	public List getRequests() throws Exception{
		
		//String sql = "select id,name,to_char(updated_at,'yyyyMMdd') from requests where aasm_state!='deleted' and REQUEST_TEMPLATE_ID is null ";
		String sql = " select req.id,req.name,to_char(req.updated_at,'yyyyMMdd'),env.name as reqEnv from requests req, environments env where req.aasm_state!='deleted' and req.REQUEST_TEMPLATE_ID is null and req.environment_id=env.id ";
		
		Query query = getSession().createSQLQuery(sql.toString());

		return query.list();
	}
	
	/**
	 * 通过请求id获取步骤信息
	 * 
	 * @param String requestId
	 * 
	 * @throws Exception
	 * 
	 * @return List
	 */
	@Transactional(readOnly = true, value = "brpm")
	public List getSteps(String requestId) throws Exception{
		String sql = "select id,name from steps where request_id= '" + requestId + "' order by position " ;
		Query query = getSession().createSQLQuery(sql.toString());
		return query.list();
	}
	
	/**
     * 导出excel模板页面显示请求
     *
     * @param Integer start
     * @param Integer limit
     * @param String sort
     * @param String dir
     * @param String app
     * @param String name
     * @param String environment
     * @param String userName
     * 
     * @throws Exception
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "brpm")
	public List<Map<String, String>> queryExcelExportRequestService(Integer start, Integer limit, String sort, String dir,String app,String name,String environment,String userName) throws Exception{
		//id,name,environment,stepNum,userName,createdAt,updatedAt
    	StringBuilder sql = new StringBuilder();
    	sql.append(" select * from ( ")
		    .append("select id as \"id\",")
			.append("name as \"name\",")
			.append("(select a.name from APPS a,APPS_REQUESTS ar where r.id = ar.request_id and a.id = ar.app_id) as \"app\",")
			.append("(select e.name from environments e where e.id=r.ENVIRONMENT_ID) as \"environment\",")
			.append("(select count(*) from steps s where s.request_id=r.id) as \"stepNum\",")
			.append("(select u.first_name from users u where u.id=r.owner_id) as \"userName\", ")
			.append("to_char(r.created_at,'yyyyMMdd HH24:MM:DD') as \"createdAt\",")
			.append("to_char(r.updated_at,'yyyyMMdd HH24:MM:DD') as \"updatedAt\" ")
			.append(" from requests r where aasm_state!='deleted' and REQUEST_TEMPLATE_ID is null ")
			.append(" ) t where 1=1 and t.\"app\" in :sysList and t.\"environment\" in :envList ");//and t.app in :sysList

	 	if(null != name && name.length() > 0){
	    	sql.append(" and t.\"name\" like '%" + name+"%'");
	    }
	    
	    if(null != app && app.length() > 0){
	    	sql.append(" and t.\"app\" = '" + app+"'");
	    }
	    
	    if(null != environment && environment.length() > 0){
	    	sql.append(" and t.\"environment\" = '" + environment+"'");
	    }
	    
	    if(null != userName && userName.length() > 0){
	    	sql.append(" and t.\"userName\" = '" + userName+"'");
	    }
    	sql.append(" order by t.\"id\" DESC ");

		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult(start).setMaxResults(limit);
		query.setParameterList("sysList", getPersonalSysListForDply());
		query.setParameterList("envList", getPersonalEnvs());

		return query.list();
	}
	
	/**
     * 导出excel模板页面显示请求总数
     * 
     * @param String app
     * @param String name
     * @param String environment
     * @param String userName
     * 
     * @throws Exception
     * 
     * @return Long
     */
	@Transactional(readOnly = true, value = "brpm")
	public Long countExcelExportRequestService(String app,String name,String environment,String userName) throws Exception{
		
		StringBuilder sql = new StringBuilder();
    	sql.append(" select count(*) from ( ")
		    .append("select id as \"id\",")
			.append("name as \"name\",")
			.append("(select a.name from APPS a,APPS_REQUESTS ar where r.id = ar.request_id and a.id = ar.app_id) as \"app\",")
			.append("(select e.name from environments e where e.id=r.ENVIRONMENT_ID) as \"environment\",")
			.append("(select count(*) from steps s where s.request_id=r.id) as \"stepNum\",")
			.append("(select u.first_name from users u where u.id=r.owner_id) as \"userName\", ")
			.append("to_char(r.created_at,'yyyyMMdd HH24:MM:DD') as \"createdAt\",")
			.append("to_char(r.updated_at,'yyyyMMdd HH24:MM:DD') as \"updatedAt\" ")
			.append(" from requests r where aasm_state!='deleted' and REQUEST_TEMPLATE_ID is null ")
			.append(" ) t where 1=1 and t.\"app\" in :sysList and t.\"environment\" in :envList ");//and t.app in :sysList

	 	if(null != name && name.length() > 0){
	    	sql.append(" and t.\"name\" like '%" + name+"%'");
	    }
	    
	    if(null != app && app.length() > 0){
	    	sql.append(" and t.\"app\" = '" + app+"'");
	    }
	    
	    if(null != environment && environment.length() > 0){
	    	sql.append(" and t.\"environment\" = '" + environment+"'");
	    }
	    
	    if(null != userName && userName.length() > 0){
	    	sql.append(" and t.\"userName\" = '" + userName+"'");
	    }
    	//sql.append(" order by t.\"id\" DESC ");
		Query query = getSession().createSQLQuery(sql.toString());
		query.setParameterList("sysList", getPersonalSysListForDply());
		query.setParameterList("envList", getPersonalEnvs());

        return Long.valueOf(query.uniqueResult().toString());
	}
	
	 /**
     * 通过请求id查找步骤显示详情
     * 
     * @param Integer start
     * @param Integer limit
     * @param String sort
     * @param String dir
     * @param Integer requestsId
     * 
     * @throws Exception
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "brpm")
    public List<Map<String, String>> queryExcelExportStepService(Integer start, Integer limit, String sort, String dir,Integer requestsId) throws Exception{
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
        StringBuilder sql = new StringBuilder();
        sql.append("select s.id as \"id\", ")
	        .append("s.position as \"position\",")
	        .append("s.request_id as \"requestId\",")
	        .append("s.name as \"name\",")
	        .append("(select c.name from components c where c.id = s.component_id) as \"component\",")
	        .append("s.different_level_from_previous as \"differentLevelFromPrevious\",")
	        .append("s.manual as \"manual\",")
	        .append("(select u.first_name from users u where u.id=s.owner_id) as \"userName\" ")
	        //.append("(select ssa2.value from step_script_arguments ssa2 where ssa2.id = (select ssa.ID+1 from step_script_arguments ssa WHERE ssa.STEP_ID = s.id and rownum=1)) as \"autoJobName\" ")
	        .append(" from steps s where request_id="+requestsId)
	        .append(" order by s.position ASC ");
        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult(start).setMaxResults(limit);
		List<Map<String, String>> lis = query.list();//id,position,requestId,name,component,serviceCode,differentLevelFromPrevious,manual,autoJobName,userName
        for (Map<String, String> str : lis) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("id", String.valueOf(str.get("id")));
			map.put("position", String.valueOf(str.get("position")));
			map.put("requestId", String.valueOf(str.get("requestId")));
			map.put("name", String.valueOf(str.get("name")));
			
			if(str.get("component") != null){
				String serviceCode[] = String.valueOf(str.get("component")).split("_");
				map.put("serviceCode", serviceCode[1]);
				map.put("component", String.valueOf(str.get("component")));
			}else{
				map.put("serviceCode", "");
				map.put("component", "");
			}
			if(String.valueOf(str.get("differentLevelFromPrevious")).equals("1")){
				map.put("differentLevelFromPrevious", "否");
			}
			if(String.valueOf(str.get("differentLevelFromPrevious")).equals("0")){
				map.put("differentLevelFromPrevious", "是");
			}
			if(String.valueOf(str.get("manual")).equals("1")){
				map.put("manual", "人工");
				map.put("autoJobName", "");
			}
			if(String.valueOf(str.get("manual")).equals("0")){
				map.put("manual", "自动化");
		        String jobPath = bsaJobPath(String.valueOf(str.get("id")));
				if(jobPath.indexOf("#")!=-1){
					String autoJobName = jobPath.split("#")[1];//String.valueOf(str.get("autoJobName")).substring(2,String.valueOf(str.get("autoJobName")).indexOf("|"))
					map.put("autoJobName", autoJobName);
				}
			}
			map.put("userName", String.valueOf(str.get("userName")));
			jsonMapList.add(map);
		}
        return jsonMapList;
    }
    
    /**
     * 通过请求id查找步骤总数显示详情
     * 
     * @param Integer requestsId
     * 
     * @throws Exception 
     * 
     * @return Long
     */
	@Transactional(readOnly = true, value = "brpm")
    public Long countExcelExportStepService(Integer requestsId) throws Exception{

    	StringBuilder sql = new StringBuilder();
    	sql.append("select count(*) from (")
			.append("select s.id as \"id\", ")
		    .append("s.position as \"position\",")
		    .append("s.request_id as \"requestId\",")
		    .append("s.name as \"name\",")
		    .append("(select c.name from components c where c.id = s.component_id) as \"component\",")
		    .append("s.different_level_from_previous as \"differentLevelFromPrevious\",")
		    .append("s.manual as \"manual\",")
		    .append("(select u.first_name from users u where u.id=s.owner_id) as \"userName\",")
		    .append("(select ssa2.value from step_script_arguments ssa2 where ssa2.id = (select ssa.ID+1 from step_script_arguments ssa WHERE ssa.STEP_ID = s.id and rownum=1)) as \"autoJobName\" ")
		    .append(" from steps s where request_id="+requestsId)
		    .append(" )");
	    Query query = getSession().createSQLQuery(sql.toString());
        return Long.valueOf(query.uniqueResult().toString());
    }
	
	 /**
     * 通过请求id查找步骤导出到excel模板
     * 
     * @param Integer requestsId
     * 
     * @throws Exception 
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "brpm")
    public List<Map<String, String>> queryExcelExportStepService(String requestsId) throws Exception{
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
        StringBuilder sql = new StringBuilder();
        sql.append("select s.id as \"id\", ")
	        .append("s.position as \"position\",")
	        .append("s.request_id as \"requestId\",")
	        .append("s.name as \"name\",")
	        .append("(select c.name from components c where c.id = s.component_id) as \"component\",")
	        .append("s.different_level_from_previous as \"differentLevelFromPrevious\",")
	        .append("s.manual as \"manual\",")
	        .append("(select u.first_name from users u where u.id=s.owner_id) as \"userName\" ")
	        //.append("(select ssa2.value from step_script_arguments ssa2 where ssa2.id = (select ssa.ID+1 from step_script_arguments ssa WHERE ssa.STEP_ID = s.id and rownum=1)) as \"autoJobName\" ")
	        .append(" from steps s where request_id="+requestsId)
	        .append(" order by s.position ASC ");
        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);//.setFirstResult(start).setMaxResults(limit)
		List<Map<String, String>> lis = query.list();//id,position,requestId,name,component,serviceCode,differentLevelFromPrevious,manual,autoJobName,userName
        for (Map<String, String> str : lis) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("id", String.valueOf(str.get("id")));
			map.put("position", String.valueOf(str.get("position")));
			map.put("requestId", String.valueOf(str.get("requestId")));
			map.put("name", String.valueOf(str.get("name")));
			
			if(str.get("component") != null){
				String serviceCode[] = String.valueOf(str.get("component")).split("_");
				map.put("serviceCode", serviceCode[1]);
				map.put("component", String.valueOf(str.get("component")));
			}else{
				map.put("serviceCode", "");
				map.put("component", "");
			}
			if(String.valueOf(str.get("differentLevelFromPrevious")).equals("1")){
				map.put("differentLevelFromPrevious", "否");
			}
			if(String.valueOf(str.get("differentLevelFromPrevious")).equals("0")){
				map.put("differentLevelFromPrevious", "是");
			}
			if(String.valueOf(str.get("manual")).equals("1")){
				map.put("manual", "人工");
				map.put("autoJobName", "");
			}
			if(String.valueOf(str.get("manual")).equals("0")){
				map.put("manual", "自动化");
				String jobPath = bsaJobPath(String.valueOf(str.get("id")));
				if(jobPath.indexOf("#")!=-1){
					String autoJobName = jobPath.split("#")[1];//String.valueOf(str.get("autoJobName")).substring(2,String.valueOf(str.get("autoJobName")).indexOf("|"))
					map.put("autoJobName", autoJobName);
				}
			}
			map.put("userName", String.valueOf(str.get("userName")));
			jsonMapList.add(map);
		}
        return jsonMapList;
    }
	
	/**
     * 通过请求id查找步骤导出到excel模板
     * 
     * @param Integer requestsId
     * 
     * @throws Exception 
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "brpm")
    public List<Map<String, String>> queryUrgentDplyStepService(String requestsId,String env) throws Exception{
		
		String stepId = null;
		String stepXml = null;
		Document document = null;
		Element element = null;
		
		String componentId = null;
		//String componentName = null;
		String componentXml = null;
		
		List<Element> accounts = null;
		List<Element> accounts2 = null;
		//String componentNameHis = "";
		String[] serviceCode = null;
		String getFullyResolvedPropertyValue = null;
		String server = "";
		String autoJobName = "";
		String operateContent = "";
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
        StringBuilder sql = new StringBuilder();
        sql.append("select s.id as \"id\", ")
	        .append("s.position as \"position\",")
	        .append("s.request_id as \"requestId\",")
	        .append("s.name as \"name\",")
	        .append("(select c.name from components c where c.id = s.component_id) as \"component\", ")
	        //.append("s.different_level_from_previous as \"differentLevelFromPrevious\",")
	        .append("s.manual as \"manual\" ")
	        //.append("(select u.first_name from users u where u.id=s.owner_id) as \"userName\" ")
	        //.append("(select ssa2.value from step_script_arguments ssa2 where ssa2.id = (select ssa.ID+1 from step_script_arguments ssa WHERE ssa.STEP_ID = s.id and rownum=1)) as \"autoJobName\" ")
	        .append(" from steps s where request_id="+requestsId)
	        .append(" order by s.position ASC ");
      //position serviceCode name component server manual operateContent

        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);//.setFirstResult(start).setMaxResults(limit)
		List<Map<String, String>> lis = query.list();//id,position,requestId,name,component,serviceCode,differentLevelFromPrevious,manual,autoJobName,userName
        
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		for (Map<String, String> str : lis) {
        	
        	autoJobName = "";
        	server = "";
			operateContent = "";

			Map<String, String> map = new HashMap<String, String>();
			map.put("id", String.valueOf(str.get("id")));
			map.put("position", String.valueOf(str.get("position")));
			map.put("requestId", String.valueOf(str.get("requestId")));
			map.put("name", String.valueOf(str.get("name")));
			map.put("component", String.valueOf(str.get("component")));
			if(str.get("component") != null){
				serviceCode = String.valueOf(str.get("component")).split("_");
				map.put("serviceCode", serviceCode[1]);
			}else{
				map.put("serviceCode", "");
			}
			/*if(String.valueOf(str.get("differentLevelFromPrevious")).equals("1")){
				map.put("differentLevelFromPrevious", "否");
			}
			if(String.valueOf(str.get("differentLevelFromPrevious")).equals("0")){
				map.put("differentLevelFromPrevious", "是");
			}*/
			if(String.valueOf(str.get("manual")).equals("1")){
				map.put("manual", "人工");
				map.put("operateContent", "");
			}
			
			if(String.valueOf(str.get("manual")).equals("0")){
				String jobPath = bsaJobPath(String.valueOf(str.get("id")));
				if(jobPath.indexOf("#")!=-1){
					autoJobName = jobPath.split("#")[1];//String.valueOf(str.get("autoJobName")).substring(2,String.valueOf(str.get("autoJobName")).indexOf("|"))
					if(autoJobName.indexOf("ALLFILES")!=-1){
						map.put("manual", "人工");
					}else{
						map.put("manual", "自动化");
					}
				}else{
					map.put("manual", "自动化");
				}
			}
			
			
			stepId = String.valueOf(str.get("id"));
			stepXml=getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
			
			document = JDOMParserUtil.xmlParse(stepXml);
			element = document.getRootElement();

			
			if(element.getChild("component")!=null){
				componentId = element.getChild("component").getChildText("id");
				//componentName = element.getChild("component").getChildText("name");
				
				//if(componentNameHis.indexOf(componentName)==-1){
					//componentNameHis += componentName + ",";
					
					componentXml=getMethodById(BrpmConstants.KEYWORD_COMPONENTS, componentId);
					document = JDOMParserUtil.xmlParse(componentXml);
					element = document.getRootElement();
					accounts = element.getChild("installed-components").getChildren();

					for (Element account : accounts) {
						String envName = account.getChild("application-environment").getChild("environment").getChildText("name");
						if(envName.equals(env)){
							accounts2 = account.getChild("servers").getChildren();
							int size = accounts2.size();
							int i = 0;
							for (Element account2 : accounts2) {
								executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("Server", "getFullyResolvedPropertyValue", new String[]{account2.getChildText("name"),"ATTR_" + env.split("_")[0] + "_" + serviceCode[1]});
								cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
								getFullyResolvedPropertyValue = (String) executeCommandByParamListResponse.get_return().getReturnValue();
								if(getFullyResolvedPropertyValue.lastIndexOf("/")!=-1){
									getFullyResolvedPropertyValue = getFullyResolvedPropertyValue.substring(getFullyResolvedPropertyValue.lastIndexOf("/")+1);
								}
								if(size-1==i){
									server += account2.getChildText("name");
									if(!autoJobName.equals("")&&String.valueOf(str.get("manual")).equals("0")&&autoJobName.indexOf("ALLFILES")==-1){
										operateContent += account2.getChildText("name") + ": sh " + getFullyResolvedPropertyValue + ".sh " + autoJobName + ".sh";
									}
								}else {
									server += account2.getChildText("name") + "\r\n";
									if(!autoJobName.equals("")&&String.valueOf(str.get("manual")).equals("0")&&autoJobName.indexOf("ALLFILES")==-1){
										operateContent += account2.getChildText("name") + ": sh " + getFullyResolvedPropertyValue + ".sh " + autoJobName + ".sh" + "\r\n";
									}
								}
								i++;
								
							}
						}
					}
				//}
			}
			if(autoJobName.indexOf("ALLFILES")!=-1){
				operateContent = "获取" + env.split("_")[0] + "平台应急脚本";
			}

			map.put("server", server);
			map.put("operateContent", operateContent);
			
			//map.put("userName", String.valueOf(str.get("userName")));
			jsonMapList.add(map);
		}
        return jsonMapList;
    }
	
	/**
     * 通过请求id查找步骤导出到excel模板
     * 
     * @param Integer requestsId
     * 
     * @throws Exception 
     * 
     * @return List<Map<String, String>>
     */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "brpm")
    public List<Map<String, String>> queryExcelExportRequestService(String requestsId) throws Exception{
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
        StringBuilder sql = new StringBuilder();
        sql.append("select r.id as \"id\", ")
        	.append("name as \"name\",")
        	.append("(select a.name from APPS a,APPS_REQUESTS ar where r.id = ar.request_id and a.id = ar.app_id) as \"app\",")
        	.append("(select e.name from environments e where e.id=r.ENVIRONMENT_ID) as \"environment\" ")
	        .append(" from requests r where r.id="+requestsId)
	        .append(" order by r.id ASC ");
        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);//.setFirstResult(start).setMaxResults(limit)
		List<Map<String, String>> lis = query.list();//id,position,requestId,name,component,serviceCode,differentLevelFromPrevious,manual,autoJobName,userName
        for (Map<String, String> str : lis) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("id", String.valueOf(str.get("id")));
			map.put("name", String.valueOf(str.get("name")));
			String app = String.valueOf(str.get("app"));
			map.put("app", app);
			String environment = String.valueOf(str.get("environment")).split("_")[1];
			if(environment.equals("DEV")){
				environment = "开发";
			}
			if(environment.equals("QA")){
				environment = "测试";
			}
			if(environment.equals("PROV")){
				environment = "验证";
			}
			if(environment.equals("PROD")){
				environment = "生产";
			}
			map.put("environment", environment);
			jsonMapList.add(map);
		}
        return jsonMapList;
    }
	
	/**
     * 通过环境和请求名检索请求
     * 
     * @param String requestName
     * @param String environment
     * 
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws URISyntaxException 
	 * 
	 * @return String
     */
	@Transactional(readOnly = true, value = "brpm")
    public String checkRequest(String requestName,String environment) throws IOException, BrpmInvocationException, URISyntaxException{
		logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_REQUSET + " { \"filters\": { \"name\":\"" + requestName + "\" }}");
		String requestsXml = getMethodByFilter(BrpmConstants.KEYWORD_REQUSET, "{ \"filters\": { \"name\":\"" + requestName + "\" }}");
		logger.log("BRPM0002", requestsXml);
		String id = "";
		if(requestsXml!=null){
			Document doc = JDOMParserUtil.xmlParse(requestsXml);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element element : accounts) {
				if (element.getChild("environment").getChildText("name").equals(environment)) {
					Document docRequests = JDOMParserUtil.xmlParse(requestsXml);
					Element rootRequests = docRequests.getRootElement();
					id = rootRequests.getChild("request").getChildText("id");
				}
			}
		}
    	return id;
    }
	
	/**
	 * 获取当前用户的系统列表

	 * @return
	 */
	@Transactional(readOnly = true, value = "dply")
	@SuppressWarnings("unchecked")
	public List<String> getPersonalSysListForDply(){
    	List<String> sysList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select s.appsys_code as \"appsysCode\" ")
		.append(" from v_cmn_app_info s  ")
		.append(" where exists (select * from cmn_user_app u  ")
		.append(" where s.appsys_code = u.appsys_code ")
		.append(" and u.user_id = :userId ")
		.append(" and u.dply_flag = '1' ) ")
		.append(" and s.delete_flag = '0' ")
		.append(" order by s.appsys_code ");
		List<Map<String, Object>> list = getSession4Maop().createSQLQuery(sql.toString())
												.setString("userId", securityUtils.getUser().getUsername())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.list();
		
    	if(list == null || (list != null && list.size() == 0)){
    		sysList.add("");
    	}else{
    		sysList = new ArrayList<String>();
    		for (Map<String, Object> map : list) {
    			sysList.add(map.get("appsysCode").toString());
    		}
    	}
		
    	return sysList;
	}
	
	/**
	 * 获取当前用户的环境列表

	 * @return
	 */
	@Transactional(readOnly = true, value = "dply")
	@SuppressWarnings("unchecked")
	public List<String> getPersonalEnvs(){
    	List<String> envList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append(" select ce.environment_code as \"envCode\" from cmn_environment ce WHERE CE.environment_type IN (")
		.append(" select env.sub_item_value as id from jeda_sub_item env where item_id='SYSTEM_ENVIRONMENT' and ")
		.append(" (select count(*) from cmn_user_env ue  where ue.user_id=:userId and ue.env = env.sub_item_value)>0) ")
		.append(" order by ce.environment_code ");
		List<Map<String, Object>> list = getSession4Maop().createSQLQuery(sql.toString())
												.setString("userId", securityUtils.getUser().getUsername())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.list();
		
    	if(list == null || (list != null && list.size() == 0)){
    		envList.add("");
    	}else{
    		envList = new ArrayList<String>();
    		for (Map<String, Object> map : list) {
    			envList.add(map.get("envCode").toString());
    		}
    	}
		
    	return envList;
	}
	
	
}///:~

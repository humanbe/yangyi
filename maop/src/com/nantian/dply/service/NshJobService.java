package com.nantian.dply.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.apache.batik.css.engine.value.StringValue;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.service.ScriptUploadService;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.DateFunction;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.dply.DplyConstants;
import com.nantian.dply.service.MoveBsaImportService.Executor;
import com.nantian.dply.vo.AppGroupVo;
import com.nantian.dply.vo.CmnAppGroupServiceVo;
import com.nantian.dply.vo.CmnEnvironmentVo;
import com.nantian.dply.vo.DplyJobBlpackageInfoVo;
import com.nantian.dply.vo.DplyJobInfoVo;
import com.nantian.dply.vo.DplyJobScriptInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 应用系统环境管理
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class NshJobService {

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	private ScriptUploadService scriptUploadService;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
	private ThreadPoolTaskExecutor taskExcutor;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	/**
	 * 构造方法

	 */
	public NshJobService() {
		fields.put("appsysCode", FieldType.STRING);
		fields.put("jobName", FieldType.STRING);
		fields.put("jobType", FieldType.INTEGER);
		fields.put("jobParentGroup", FieldType.STRING);
		fields.put("scriptBlpackageName", FieldType.STRING);
		fields.put("jobPath", FieldType.STRING);
		fields.put("jobCreator", FieldType.STRING);
		fields.put("jobModifier", FieldType.STRING);
		fields.put("jobCreated", FieldType.TIMESTAMP);
		fields.put("jobModified", FieldType.TIMESTAMP);
		fields.put("serverGroup", FieldType.STRING);
	}

	/**
	 * 保存分组数据
	 * 
	 * @param AppGroupVo
	 *            应用系统资源
	 */

	@Transactional
	public void saveGroup(AppGroupVo appGroupVo) {
		appGroupVo.setDeleteFlage("0");
		getSession().save(appGroupVo);

	}

	/**
	 * 删除.
	 * 
	 * @param cmnEnvironmentVo
	 */
	@Transactional
	public void delete(CmnEnvironmentVo cmnEnvironmentVo) {
		getSession().delete(cmnEnvironmentVo);
	}

	/**
	 * 查询作业表数据

	 * 
	 * 
	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)
			throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.jobName as \"jobName\", ")
				.append(" o.jobType as \"jobType\", ")
				.append("o.jobPath as \"jobPath\", ")
				.append("o.jobParentGroup as \"jobParentGroup\", ")
				.append("o.scriptBlpackageName as \"scriptBlpackageName\", ")
				.append("o.jobCreator as \"jobCreator\", ")
				.append("to_char(o.jobCreated,'yyyymmdd hh:mi:ss') as \"jobCreated\", ")
				.append("o.jobModifier as \"jobModifier\", ")
				.append(" to_char(o.jobModified,'yyyymmdd hh:mi:ss') as \"jobModified\" ")
				.append(" from (  ")
				.append(" select max(b.appsys_code) as appsysCode,  ")
				.append(" max(b.job_name)as jobName,  ")
				.append(" max(b.job_path) as jobPath, ")
				.append(" max(b.job_parent_group) as jobParentGroup, ")
				.append(" max(b.job_type) as jobType,  ")
				.append(" max(b.job_creator) as jobCreator,  ")
				.append(" max(b.job_created) as jobCreated,  ")
				.append(" max(b.job_modifier) as jobModifier,  ")
				.append(" max(b.job_modified) as jobModified,  ")
				.append(" to_char(wm_concat(t.softlink_script_name)) as scriptBlpackageName  ")
				.append(" from dply_job_info b  ")
				.append(" left join dply_job_blpackage_info t on t.appsys_code = b.appsys_code and t.blpackage_name = b.nsh_blpackage_name  ")
				.append(" where b.job_type ='2'  ")
				.append(" group by t.blpackage_name ")
				.append(" union  ")
				.append(" select b.appsys_code,  ")
				.append(" b.job_name,b.job_path,")
				.append(" b.job_parent_group,b.job_type,  ")
				.append(" b.job_creator,b.job_created, ")
				.append(" b.job_modifier,b.job_modified,  ")
				.append(" b.nsh_blpackage_name  ")
				.append(" from dply_job_info b where b.job_type ='1') o where  o.appsysCode in :sysList  ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) throws SQLException {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from DplyJobInfoVo b where 1=1  and b.appsysCode in :sysList");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and b." + key + " like :" + key);
				} else {
					hql.append(" and b." + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询应用系统所有的分组服务名
	 * @param envCode 

	 * 
	 * @return
	 * @throws Exception
	 */
	@Transactional(readOnly = true)
	public Object queryjobParentGroup(String appsysCode, String envCode) throws Exception {
		Map<String, String> groupName = null;
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		
		List<Map<String, String>> nameList = new ArrayList<Map<String, String>>();
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("JobGroup","findAllGroupsByParentGroupName",new String[] { "/DEPLOY/"+envName+"/"+appsysCode+"" });
		String GroupNames = (String) jobParentGroupNames.get_return().getReturnValue();
		if (!GroupNames.equals("void")) {
			String[] GroupName = GroupNames.split("\n");
			List<String> list=new ArrayList<String>();
			for (int i = 0; i < GroupName.length; i++) {
				if(GroupName[i].length()-14>0){
				String yanzheng=GroupName[i].substring(GroupName[i].length()-14,GroupName[i].length());
				boolean ds = DateFunction.isDate(yanzheng);
				if("false".equals(ds)){
				list.add(GroupName[i]);
					}
				}else{
					list.add(GroupName[i]);
				}
			}
			list.remove("TOOLS");
			for(int j=0;j<list.size();j++){
			groupName = new HashMap<String, String>();
			groupName.put("groupName", list.get(j));
			nameList.add(groupName);
			}
		}
		return nameList;

	}


	/**
	 * 查看脚本内容
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryText(String nshJobFilePath,DplyJobInfoVo dplyJobInfoVo) throws Exception {
		int b;
		File file = new File(nshJobFilePath);
		FileInputStream in=new FileInputStream(file);
		StringBuilder Nr=new StringBuilder();
		InputStreamReader br = null;
		String type=dplyJobInfoVo.getTypeValue();
		if ("UTF-8".equals(type)) {
			br = new InputStreamReader(in,"utf-8");
		}
		if ("GBK".equals(type)) {
			br = new InputStreamReader(in,"GBK");
		}
		try {
			while ((b = br.read()) != -1) {
				Nr.append((char)b);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			br.close();
		}
		return Nr.toString();
	}
	/**
	 * 查看脚本内容
	 * @param envCode 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryShPath(DplyJobInfoVo dplyJobInfoVo, String envCode) throws AxisFault,SQLException, Exception {
		String appsysCode=dplyJobInfoVo.getAppsysCode();
		String serverName=dplyJobInfoVo.getJobParentGroup();
		String jobName = dplyJobInfoVo.getScriptBlpackageName();
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","getLocationByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/SCRIPTS",""+jobName+""});
		String bsaShPath = (String) jobParentGroupNames.get_return().getReturnValue();
		return bsaShPath;
	}

	/**
	 * 查看脚本内容
	 * @param envCode 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void exeJob(DplyJobInfoVo dplyJobInfoVo,String basShPath,String resultpath, String envCode) throws AxisFault,SQLException, Exception {
		String appsysCode=dplyJobInfoVo.getAppsysCode();
		String nshScriptName="DepotFilecopy.nsh";
		//替换脚本的位置
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		//创建替换脚本的作业文件夹名
		String jiaMing = "TOOLS";
		//替换脚本创建的作业名字
		String toolJobName = nshScriptName.substring(0,nshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		
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
		String nshToolsGroup=(String) jobGroupExists(appsysCode, jiaMing,envName);
		//存在该文件夹
		if(nshToolsGroup.equals("false")){
			createJobGroup(appsysCode, jiaMing,envName);
		}
		createToolJob(appsysCode,jiaMing,toolJobName,toolNshScriptPath,nshScriptName,bsaServer,envName);
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","0",""+basShPath+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","1",""+resultpath+""});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		//获取作业的DbKey
		String nshJobDbkey=(String) getNshJobDbKey(toolJobName, appsysCode, jiaMing,envName);
		//执行作业
		exceNshJob(nshJobDbkey);
		//删除作业
		deleteJob(appsysCode,jiaMing,toolJobName,envName);
	}
	/**
	 * 查看必选参数

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	public Object generalParam(String appsysCode, String jobGroupName,String envName)
			throws Exception {
		String envCode = "";
		if(envName.equals("开发环境")){
			envCode="DEV";
		}
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		List<Map<String, String>> param1 = new ArrayList<Map<String, String>>();
		Map<String, String> paramMap = new HashMap<String, String>();
		Map<String, String> paramMap2 = new HashMap<String, String>();
		Map<String, String> paramMap3 = new HashMap<String, String>();
		String execPath = "";
		String appUser = "";
		String appUserGroup = "";
		String ming = "";
		execPath = jobGroupName + "_" + "ExecPath";
		appUser = jobGroupName + "_" + "AppUser";
		appUserGroup = jobGroupName + "_" + "AppUserGroup";
		paramMap.put("paramName", execPath);
		paramMap.put("describe", "脚本执行路径");

		
		paramMap2.put("paramName", appUser);
		paramMap2.put("describe", "脚本执行用户");

		paramMap3.put("paramName", appUserGroup);
		paramMap3.put("describe", "脚本执行用户组");

		List<String> fuwuMing = (List<String>) queryMing(appsysCode, jobGroupName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
			String GroupNames = (String) listAllPropertyNames(appsysCode, ming);
			if (!GroupNames.equals("void")) {
				String[] GroupName = GroupNames.split("\n");
				List<String> paramList = new ArrayList<String>();
				for (int j = 0; j < GroupName.length; j++) {
					paramList.add(GroupName[j]);
				}
				if (paramList.contains(execPath)) {
					paramMap.put("result", "Y");
				} else {
					paramMap.put("result", "N");
				}
				if (paramList.contains(appUser)) {
					paramMap2.put("result", "Y");
				} else {
					paramMap2.put("result", "N");
				}
				if (paramList.contains(appUserGroup)) {
					paramMap3.put("result", "Y");
				} else {
					paramMap3.put("result", "N");
				}
			}
		}
		String serverProperty = "ATTR_"+envCode+"_" + appsysCode + "_" + ming;
		String serverExistNames =  (String) listAllServerPropertyNames();
		if (!serverExistNames.equals("void")) {
			String[] serverExistName = serverExistNames.split("\n");
			List<String> serverExistList = new ArrayList<String>();
			for (int j = 0; j < serverExistName.length; j++) {
				serverExistList.add(serverExistName[j]);
			}
			if (serverExistList.contains(serverProperty)) {
				paramMap.put("serverExist", "Y");
			} else {
				paramMap.put("serverExist", "N");
			}
		}
		List<String> list=queryOsType(appsysCode, jobGroupName);
		if(list.get(0).equals("WINDOWS")){
			param.add(paramMap);
		}else{
			param.add(paramMap);
			param.add(paramMap2);
			param.add(paramMap3);
		}
		return param;
	}
	
	/**
	 * 查看属性类的属性名称

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object listAllPropertyNames(String appsysCode, String jobGroupName)
			throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("PropertyClass",
						"listAllPropertyNames",new String[] { DplyConstants.PARAMSMETER_CLASS_PREFIX+ appsysCode + "/" + jobGroupName });
		String propertyNames = (String) jobParentGroupNames.get_return().getReturnValue();
		return propertyNames;

	}

	/**
	 * 查看可选参数

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	public Object checkParam(String appsysCode, String jobGroupName,String envName)
			throws Exception {
		String envCode="";
		if(envName.equals("开发环境")){
			envCode="DEV";
		}
		String luJing = "??TARGET.ATTR_"+envCode+"_";
		String execPath = "";
		String appUser = "";
		String appUserGroup = "";
        String ming="";
		execPath = jobGroupName + "_" + "ExecPath";
		appUser = jobGroupName + "_" + "AppUser";
		appUserGroup = jobGroupName + "_" + "AppUserGroup";
		List<String> paramList = new ArrayList<String>();
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		Map<String, String> paramMap = null;
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, jobGroupName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
			String GroupNames = (String) listAllPropertyNames(appsysCode, ming);
			if (!GroupNames.equals("void")) {
				String[] GroupName = GroupNames.split("\n");
				for (int j = 0; j < GroupName.length; j++) {
					paramList.add(GroupName[j]);
				}
			}
		}
		//select t.sub_item_name from  jeda_sub_item t where t.item_id='DPLY_FILTER_PARAMS'
		StringBuilder sql = new StringBuilder();
		sql.append("select t.sub_item_name from  jeda_sub_item t where t.item_id='DPLY_FILTER_PARAMS'" );
		Query query1 = getSession().createSQLQuery(sql.toString());
		List<String> filterParam=(List<String>) query1.list();		
		paramList.remove(execPath);
		paramList.remove(appUser);
		paramList.remove(appUserGroup);
		for (int m=0;m<filterParam.size();m++){
			paramList.remove(filterParam.get(m));
		}
		
		for (int i = 0; i < paramList.size(); i++) {
			paramMap = new HashMap<String, String>();
			paramMap.put("checkparamName", paramList.get(i));
			paramMap.put("property", luJing + appsysCode + "_" + ming + "." + paramList.get(i) + "??");
			
			param.add(paramMap);
		}
		return param;
	}
	/**
	 * 勾选可选参数

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	public Object checkedCheckParam(String appsysCode, String jobGroupName,String scriptBlpackageName,String envName)
			throws Exception {
		String envCode="";
		if(envName.equals("开发环境")){
			envCode="DEV";
		}
		StringBuilder sql = new StringBuilder();
		sql.append(" select o.paramName as \"paramName\"    ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.NSH_SCRIPT_NAME as scriptBlpackageName,")
				.append(" b.JOB_PARENT_GROUP as jobParentGroup,  ")
				.append(" b.SCRIPT_NAME as scriptName,  ")
				.append(" b.PARAM_NAME as paramName, ")
				.append(" b.NSH_SCRIPT_PATH as scriptBlpackagePath, ")
				.append(" b.SCRIPT_PATH as scriptPath, ")
				.append(" b.PARAM_TYPE as paramType, ")
				.append(" b.PARAM_VALUE as paramValue  ")
				.append(" from DPLY_JOB_SCRIPT_INFO b where b.appsys_code =:appsysCode and  b.JOB_PARENT_GROUP=:jobGroupName and b.SCRIPT_NAME=:scriptBlpackageName and b.param_type='2') o  ");
		Query query=  getSession().createSQLQuery(sql.toString())
				.setString("appsysCode", appsysCode)
				.setString("jobGroupName", jobGroupName)
				.setString("scriptBlpackageName", scriptBlpackageName);
		List<?> gouXuan = query.list();
		
		String luJing = "??TARGET.ATTR_"+envCode+"_";
		String execPath = "";
		String appUser = "";
		String appUserGroup = "";
        String ming="";
		execPath = jobGroupName + "_" + "ExecPath";
		appUser = jobGroupName + "_" + "AppUser";
		appUserGroup = jobGroupName + "_" + "AppUserGroup";
		List<String> paramList = new ArrayList<String>();
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		Map<String, String> paramMap = null;
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, jobGroupName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
			String GroupNames = (String) listAllPropertyNames(appsysCode, ming);
			if (!GroupNames.equals("void")) {
				String[] GroupName = GroupNames.split("\n");
				for (int j = 0; j < GroupName.length; j++) {
					paramList.add(GroupName[j]);
				}
			}
		}
		StringBuilder sql1 = new StringBuilder();
		sql1.append("select t.sub_item_name from  jeda_sub_item t where t.item_id='DPLY_FILTER_PARAMS'" );
		Query query1 = getSession().createSQLQuery(sql1.toString());
		List<String> filterParam=(List<String>) query1.list();	
		for (int m=0;m<filterParam.size();m++){
			paramList.remove(filterParam.get(m));
		}
		paramList.remove(execPath);
		paramList.remove(appUser);
		paramList.remove(appUserGroup);
		for(int j=0;j<gouXuan.size();j++){
			if(paramList.contains(gouXuan.get(j))){
				paramMap = new HashMap<String, String>();
				paramMap.put("checkparamName", (String) gouXuan.get(j));
				paramMap.put("property", luJing + appsysCode + "_" + ming + "." + gouXuan.get(j) + "??");
				paramMap.put("checked", "true");
				paramList.remove(gouXuan.get(j));
				param.add(paramMap);
			}
		}
		for (int i = 0; i < paramList.size(); i++) {
					paramMap = new HashMap<String, String>();
					paramMap.put("checkparamName", paramList.get(i));
					paramMap.put("property", luJing + appsysCode + "_" + ming + "." + paramList.get(i) + "??");
					paramMap.put("checked", "false");
					param.add(paramMap);
		}
		return param;
	}
	/**
	 * 新建保存
	 * @param shPath 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@Transactional(rollbackFor=Exception.class)
	public void save(DplyJobInfoVo dplyJobInfoVo, String shPath) throws AxisFault,SQLException, Exception {
		String checkParamJson = dplyJobInfoVo.getNshValue();
		String generalParamJson=dplyJobInfoVo.getParamValue();
		String serverName = dplyJobInfoVo.getJobParentGroup();
		String jobName = dplyJobInfoVo.getScriptBlpackageName();
		String appsysCode = dplyJobInfoVo.getAppsysCode();
		String envCode = dplyJobInfoVo.getEnvironmentCode();
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		String nshJia="NSHELLS";
		String shJia = "SCRIPTS";
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		String ip=messages.getMessage("systemServer.ip");
		String fileType="DEPOT_FILE_OBJECT";
		String bsaServer = messages.getMessage("bsa.ipAddress");
		String nshName=jobName.substring(0,jobName.indexOf(".")).concat(".nsh");
		String nshJobName=jobName.substring(0,jobName.indexOf("."));
		String nshFileType = "NSHSCRIPT";
		String blpackageType="BLPACKAGE";
		String blpackageName=appsysCode+"_"+serverName+"_"+"ALLFILES";
        String username = securityUtils.getUser().getUsername();
        StringBuilder sql = new StringBuilder();
		sql.append("select o.jobName as \"jobName\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.job_name as jobName,")
				.append("   b.job_type as jobType,  ")
				.append("  b.job_path as jobPath,  ")
				.append("  b.job_parent_group as jobParentGroup,  ")
				.append("  b.nsh_blpackage_name as scriptBlpackageName,  ")
				.append("  b.job_creator as jobCreator,  ")
				.append("  b.job_created as jobCreated,  ")
				.append("  b.job_modifier as jobModifier,  ")
				.append(" 	b.job_modified as jobModified  ")
				.append(" from DPLY_JOB_INFO b) o where  o.jobName =:blpackageName");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("blpackageName", blpackageName);
				List<Map> blpackageisExist = query.list();
				List<DplyJobInfoVo> jobInfoList = new ArrayList<DplyJobInfoVo>();
				DplyJobInfoVo jobInfoVo=new DplyJobInfoVo();
				jobInfoVo.setAppsysCode(appsysCode);
				jobInfoVo.setJobName(nshJobName);
				jobInfoVo.setJobParentGroup(serverName);
				jobInfoVo.setEnvironmentCode(envName);
				jobInfoVo.setJobType(1);
				jobInfoVo.setScriptBlpackageName(nshName);
				jobInfoVo.setJobPath("/DEPLOY/"+appsysCode+"/"+serverName);
				jobInfoVo.setJobCreator(username);
				Timestamp time=new Timestamp(System.currentTimeMillis());
				jobInfoVo.setJobCreated(time);
				jobInfoList.add(jobInfoVo);
				for (DplyJobInfoVo vo : jobInfoList) {
					getSession().save(vo);
				}
				if(blpackageisExist.size()==0){
					List<DplyJobInfoVo> jobInfoList1 = new ArrayList<DplyJobInfoVo>();
					DplyJobInfoVo jobInfoVo1=new DplyJobInfoVo();
					jobInfoVo1.setAppsysCode(appsysCode);
					jobInfoVo1.setJobName(blpackageName);
					jobInfoVo1.setJobParentGroup(serverName);
					jobInfoVo.setEnvironmentCode(envName);
					jobInfoVo1.setJobType(2);
					jobInfoVo1.setScriptBlpackageName(blpackageName);
					jobInfoVo1.setJobPath("/DEPLOY/"+appsysCode+"/"+serverName);
					jobInfoVo1.setJobCreator(username);
					Timestamp time1=new Timestamp(System.currentTimeMillis());
					jobInfoVo1.setJobCreated(time1);
					jobInfoList1.add(jobInfoVo1);
					for (DplyJobInfoVo vo3 : jobInfoList1) {
						getSession().save(vo3);
					}
				}
		List<DplyJobScriptInfoVo> jobScriptInfoList = new ArrayList<DplyJobScriptInfoVo>();
		String ming="";
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, serverName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
		}
		List<String> paramList1=new ArrayList<String>();
		JSONArray generalParam = JSONArray.fromObject(generalParamJson);
		List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
		for(int i=0;i<generalParamJsonList.size();i++){
			paramList1.add(generalParamJsonList.get(i));
		}
		DplyJobScriptInfoVo jobScriptInfoVo=null;
		for(int i=0;i<paramList1.size();i++){
			jobScriptInfoVo=new DplyJobScriptInfoVo();
			jobScriptInfoVo.setAppsysCode(appsysCode);
			jobScriptInfoVo.setJobParentGroup(serverName);
			jobScriptInfoVo.setScriptBlpackageName(nshName);
			jobScriptInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
			jobScriptInfoVo.setScriptName(jobName);
			jobScriptInfoVo.setScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
			jobScriptInfoVo.setParamName(paramList1.get(i));
			jobScriptInfoVo.setParamType(1);
			jobScriptInfoVo.setParamValue("??TARGET.ATTR_"+envName+"_" + appsysCode + "_" + ming + "." + paramList1.get(i) + "??");
			jobScriptInfoList.add(jobScriptInfoVo);
		}
		for (DplyJobScriptInfoVo vo1 : jobScriptInfoList) {
			getSession().save(vo1);
		}
		List<DplyJobScriptInfoVo> jobScriptInfoList1 = new ArrayList<DplyJobScriptInfoVo>();
		List<String> paramList2=new ArrayList<String>();
		JSONArray checkParam = JSONArray.fromObject(checkParamJson);
		List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkParam, String.class);
		for(int i=0;i<checkParamJsonList.size();i++){
			paramList2.add(checkParamJsonList.get(i));
		}
		for(int i=0;i<paramList2.size();i++){
			jobScriptInfoVo=new DplyJobScriptInfoVo();
			jobScriptInfoVo.setAppsysCode(appsysCode);
			jobScriptInfoVo.setJobParentGroup(serverName);
			jobScriptInfoVo.setScriptBlpackageName(nshName);
			jobScriptInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
			jobScriptInfoVo.setScriptName(jobName);
			jobScriptInfoVo.setScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
			jobScriptInfoVo.setParamName(ComUtil.checkNull(paramList2.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
			jobScriptInfoVo.setParamType(2);
			jobScriptInfoVo.setParamValue(ComUtil.checkNull(paramList2.get(i).split(Constants.SPLIT_SEPARATEOR)[1]));
			jobScriptInfoList1.add(jobScriptInfoVo);
		}
		for (DplyJobScriptInfoVo vo2 : jobScriptInfoList1) {
			getSession().save(vo2);
		}
		DplyJobBlpackageInfoVo jobBlpackageInfoVo=new DplyJobBlpackageInfoVo();
		jobBlpackageInfoVo.setAppsysCode(appsysCode);
		jobBlpackageInfoVo.setScriptBlpackageName(blpackageName);
		jobBlpackageInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
		jobBlpackageInfoVo.setJobParentGroup(serverName);
		jobBlpackageInfoVo.setSoftlinkScriptName(jobName);
		jobBlpackageInfoVo.setSoftlinkScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
		getSession().save(jobBlpackageInfoVo);
		String isExist=(String) groupExists(appsysCode,serverName,shJia,envName);
		if(isExist.equals("false")){
		createGroup(appsysCode, serverName, shJia,envName);
		groupApplyAclPolicy(appsysCode, serverName, shJia,envName);
		}
		addFileToDepot(appsysCode,serverName,shJia,jobName,Path,ip,envName);
		String shDbKey=(String) getFileDbKey(appsysCode, serverName, shJia, fileType, jobName,envName);
		applyAclPolicy(shDbKey,appsysCode,envName);
		String nshIsExist=(String) groupExists(appsysCode,serverName,nshJia,envName);
		if(nshIsExist.equals("false")){
			createGroup(appsysCode, serverName, nshJia,envName);
			groupApplyAclPolicy(appsysCode, serverName, nshJia,envName);
		}
			StringBuilder nfssql = new StringBuilder();
			nfssql.append("select t.nfs_flag from cmn_app_group_service t where t.appsys_code='"+appsysCode+"' and t.service_name='"+serverName+"'" );
			Query query1 = getSession().createSQLQuery(nfssql.toString());
			String nfsFlag=(String) query1.list().get(0);		
			Object nshNeiRong= null;
			String startCmdName="startCmdFile.txt";
			String endCmdName="endCmdFile.txt";
			String undoCmdName="undoCmdFile.txt";
			String startCmdPath="//"+ip+"/"+Path+"/"+startCmdName;
			String endCmdPath="//"+ip+"/"+Path+"/"+endCmdName;
			String undoCmdPath="//"+ip+"/"+Path+"/"+undoCmdName;
			List<String> list=queryOsType(appsysCode, serverName);
			if(nfsFlag.equals("是")){
				if(list.get(0).equals("WINDOWS")){
					nshNeiRong = nshWindowsText(checkParamJson, generalParamJson, jobName);
					createCmdFile(startCmdName,endCmdName,undoCmdName,shPath,appsysCode,ming,serverName,jobName,envName);
				}else{
					nshNeiRong = nfsNshText(checkParamJson, generalParamJson, jobName);
					createCmdFile(startCmdName,endCmdName,undoCmdName,shPath,appsysCode,ming,serverName,jobName,envName);
				}
			}else{
				if(list.get(0).equals("WINDOWS")){
					nshNeiRong = nshWindowsText(checkParamJson, generalParamJson, jobName);
				}else{
					nshNeiRong = nshText(checkParamJson, generalParamJson, jobName);
				}
			}
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			addNshToDepot(appsysCode,serverName,nshJia,nshName,Path,ip,envName);
			String nshDbKey=(String) getFileDbKey(appsysCode, serverName, nshJia, nshFileType, nshName,envName);
			applyAclPolicy(nshDbKey,appsysCode,envName);
			addParamToNshScript(appsysCode,serverName,nshJia,nshName,checkParamJson,generalParamJson,envName);
			createNshScriptJob(appsysCode,serverName,nshJia,nshName,nshJobName,envName);
			String nshJobDbkey=(String) getNshJobDbKey(nshJobName, appsysCode, serverName,envName);
			applyJobAclPolicy(nshJobDbkey, appsysCode,envName);
			String blpackagefileexist=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
			if(blpackagefileexist.equals("void")){
				String groupId=(String) groupNameToId(appsysCode,serverName,nshJia,envName);
				createBlpackage(blpackageName,groupId);
				String blpackageDbKey=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
				applyAclPolicy(blpackageDbKey,appsysCode,envName);
				if(nfsFlag.equals("是")){
					addExternalCmdToEnd(blpackageDbKey,"deleteshell",startCmdPath,undoCmdPath);
					importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
					addExternalCmdToEnd(blpackageDbKey,"modifypermission",endCmdPath,undoCmdPath);
				}else{
					importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
				}
				 String blpackageFileIsExist=(String) blpackageJobIsExist(appsysCode, serverName,blpackageName,envName);
				 if(blpackageFileIsExist.equals("void")){
				   String blpackageDbkey=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
				   String blpackageGroupId =(String) jobGroupId(appsysCode, serverName,envName);
				   createBlpackageJob(blpackageName,blpackageGroupId,blpackageDbkey,bsaServer);
				   String blpackageJobDbkey=(String)getBlpackageJobDbkey(appsysCode, serverName,blpackageName,envName);
				   applyJobAclPolicy(blpackageJobDbkey, appsysCode,envName);
				   String blpackageJobDbkey1=(String)getBlpackageJobDbkey(appsysCode, serverName,blpackageName,envName);
				   clearTargetServer(blpackageJobDbkey1,bsaServer);
				 }
			}
			else{
				String blpackageDbKey=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
				if(nfsFlag.equals("是")){
					addExternalCmdToEnd(blpackageDbKey,"deleteshell",startCmdPath,undoCmdPath);
					importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
					addExternalCmdToEnd(blpackageDbKey,"modifypermission",endCmdPath,undoCmdPath);
				}else{
					importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
				}
				 String blpackageFileIsExist=(String) blpackageJobIsExist(appsysCode, serverName,blpackageName,envName);
				 if(blpackageFileIsExist.equals("void")){
				   String blpackageDbkey=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
				   String blpackageGroupId =(String) jobGroupId(appsysCode, serverName,envName);
				   createBlpackageJob(blpackageName,blpackageGroupId,blpackageDbkey,bsaServer);
				   String blpackageJobDbkey=(String)getBlpackageJobDbkey(appsysCode, serverName,blpackageName,envName);
				   applyJobAclPolicy(blpackageJobDbkey, appsysCode,envName);
				   String blpackageJobDbkey1=(String)getBlpackageJobDbkey(appsysCode, serverName,blpackageName,envName);
				   clearTargetServer(blpackageJobDbkey1,bsaServer);
				 }
			}
	}

	/**
	 * 修改保存数据
	 * @throws Exception
	 * @throws JEDAException
	 */
	@Transactional(rollbackFor=Exception.class)
	public void edit(DplyJobInfoVo dplyJobInfoVo, String shPath) throws AxisFault,SQLException, Exception {
		String checkParamJson = dplyJobInfoVo.getNshValue();
		String generalParamJson=dplyJobInfoVo.getParamValue();
		String serverName = dplyJobInfoVo.getJobParentGroup();
		String uploadPath = dplyJobInfoVo.getPathValue();
		String jobName = dplyJobInfoVo.getScriptBlpackageName();
		String appsysCode = dplyJobInfoVo.getAppsysCode();
		String envCode = dplyJobInfoVo.getEnvironmentCode();
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		String nshJia="NSHELLS";
		String shJia = "SCRIPTS";
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		String ip=messages.getMessage("systemServer.ip");
		String bsaServer = messages.getMessage("bsa.ipAddress");
		String replaceNshScriptName = "NSHScriptUpload.nsh";
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		String jiaMing = "TOOLS";
		String nshJobToolName = replaceNshScriptName.substring(0,replaceNshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String nshName=jobName.substring(0,jobName.indexOf(".")).concat(".nsh");
		String nshwenjianPath="//"+ip+"/"+Path+"/"+nshName;
        String username = securityUtils.getUser().getUsername();
		String blpackageName=appsysCode+"_"+serverName+"_"+"ALLFILES";
      	Timestamp time=new Timestamp(System.currentTimeMillis());
      	String time0=time.toString();
      	String time1=time0.substring(0,time0.indexOf(".")).replace("-", "");
		String sqlJobInfo = "update dply_job_info set job_modifier = '"+username+"', job_modified = TO_TIMESTAMP('"+time1+"','yyyymmdd hh24:mi:ss') where appsys_code = '"+appsysCode+"' " +
				"and nsh_blpackage_name = '"+nshName+"' " +
						"and job_parent_group='"+serverName+"'" ;
		getSession().createSQLQuery(sqlJobInfo).executeUpdate();
		String sqlJobBlpackageInfo = "delete dply_job_blpackage_info where appsys_code = '"+appsysCode+"' and softlink_script_name = '"+jobName+"' and job_parent_group='"+serverName+"'" ;
		getSession().createSQLQuery(sqlJobBlpackageInfo).executeUpdate();
		String sqlJobScriptInfo = "delete dply_job_script_info where appsys_code = '"+appsysCode+"' and script_name = '"+jobName+"' and job_parent_group='"+serverName+"'" ;
		getSession().createSQLQuery(sqlJobScriptInfo).executeUpdate();
		String ming="";
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, serverName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
		}
		List<String> list=queryOsType(appsysCode, serverName);
		String nshToolsGroup=(String) jobGroupExists(appsysCode, jiaMing,envName);
		//存在该文件夹
		if(nshToolsGroup.equals("false")){
			createJobGroup(appsysCode, jiaMing,envName);
		}
		if(("").equals(uploadPath)){
			Object nshNeiRong;
			if(list.get(0).equals("WINDOWS")){
				nshNeiRong = nshWindowsText(checkParamJson, generalParamJson, jobName);
			}else{
				nshNeiRong = nshText(checkParamJson, generalParamJson, jobName);
			}
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			createToolJob(appsysCode,jiaMing,nshJobToolName,toolNshScriptPath,replaceNshScriptName,bsaServer,envName);
			addToolJobParam(nshwenjianPath,nshJobToolName,appsysCode,serverName,nshJia,jiaMing,nshName,envName);
			String nshJobDbkey=(String) getNshJobDbKey(nshJobToolName, appsysCode, jiaMing,envName);
			exceNshJob(nshJobDbkey);
			deleteJob(appsysCode,jiaMing,nshJobToolName,envName);
			clearNSHScriptParametersByGroupAndName(appsysCode,serverName,nshJia,nshName,envName);
			addParamToNshScript(appsysCode,serverName,nshJia,nshName,checkParamJson,generalParamJson,envName);
			}
		else{
			String fileType="DEPOT_FILE_OBJECT";
			String moveFileScript="MoveDepotFiletoagroup.nsh";
			String targetGroup="DUSTBIN";
			Object depot = depotGroupExists("/DEPLOY/"+envName+"/"+targetGroup+"");
			if(!depot.equals("true")){
				scriptUploadService.createGroup(targetGroup, "DEPLOY/"+envName+"");
			}
			String toolJobName1 = moveFileScript.substring(0,moveFileScript.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
			createToolJob(appsysCode,jiaMing,toolJobName1,toolNshScriptPath,moveFileScript,bsaServer,envName);
			addToolJobParam1(appsysCode, serverName, shJia, jobName, targetGroup, jiaMing, toolJobName1,envName);
			String nshJobDbkey1=(String) getNshJobDbKey(toolJobName1, appsysCode, jiaMing,envName);
			exceNshJob(nshJobDbkey1);
			deleteJob(appsysCode,jiaMing,toolJobName1,envName);
			addFileToDepot(appsysCode,serverName,shJia,jobName,Path,ip,envName);
			String shDbKey=(String) getFileDbKey(appsysCode, serverName, shJia, fileType, jobName,envName);
			applyAclPolicy(shDbKey,appsysCode,envName);
			
			
			
			StringBuilder sql = new StringBuilder();
			sql.append(" select o.softlinkScriptName as \"softlinkScriptName\"    ")
					.append(" from (  ")
					.append(" select b.appsys_code as appsysCode,  ")
					.append(" b.BLPACKAGE_NAME as scriptBlpackageName,")
					.append(" b.blpackage_path as scriptBlpackagePath,  ")
					.append(" b.job_parent_group as jobParentGroup,  ")
					.append(" b.softlink_script_name as softlinkScriptName, ")
					.append(" b.softlink_script_path as softlinkScriptPath ")
					.append(" from dply_job_blpackage_info b where b.appsys_code =:appsysCode and  b.job_parent_group=:jobParentGroup and b.BLPACKAGE_NAME=:blpackageName ) o  ");
			Query query=  getSession().createSQLQuery(sql.toString())
					.setString("appsysCode", appsysCode)
					.setString("jobParentGroup", serverName)
					.setString("blpackageName", blpackageName);
			List<String> gouXuan = (List<String>)query.list();
			String groupId=(String) groupNameToId(appsysCode,serverName,shJia,envName);
			createBlpackage(blpackageName,groupId);
			String blpackageType="BLPACKAGE";
			String blpackageDbKey=(String) getFileDbKey(appsysCode, serverName, shJia, blpackageType, blpackageName,envName);
			StringBuilder nfssql = new StringBuilder();
			nfssql.append("select t.nfs_flag from cmn_app_group_service t where t.appsys_code='"+appsysCode+"' and t.service_name='"+serverName+"'" );
			Query query1 = getSession().createSQLQuery(nfssql.toString());
			String nfsFlag=(String) query1.list().get(0);		
			String startCmdName="startCmdFile.txt";
			String endCmdName="endCmdFile.txt";
			String undoCmdName="undoCmdFile.txt";
			String startCmdPath="//"+ip+"/"+Path+"/"+startCmdName;
			String endCmdPath="//"+ip+"/"+Path+"/"+endCmdName;
			String undoCmdPath="//"+ip+"/"+Path+"/"+undoCmdName;
			for(int i=0;i<gouXuan.size();i++){
				if(nfsFlag.equals("是")){
					createCmdFile(startCmdName,endCmdName,undoCmdName,shPath,appsysCode,ming,serverName,(String) gouXuan.get(i),envName);
					addExternalCmdToEnd(blpackageDbKey,"deleteshell",startCmdPath,undoCmdPath);
					importDepotObjectToPackage(appsysCode, serverName, shJia,blpackageName,shJia,(String) gouXuan.get(i),fileType,envName);
					addExternalCmdToEnd(blpackageDbKey,"modifypermission",endCmdPath,undoCmdPath);
				}else{
					importDepotObjectToPackage(appsysCode, serverName, shJia,blpackageName,shJia,(String) gouXuan.get(i),fileType,envName);
				}
			}
			updateByName(appsysCode, serverName, shJia, nshJia, blpackageName,envName);
			deleteBlpackage(appsysCode, serverName, shJia,blpackageName,envName);
			createCmdFile(startCmdName,endCmdName,undoCmdName,shPath,appsysCode,ming,serverName,jobName,envName);
			String blpackageDbKey1=(String) getFileDbKey(appsysCode, serverName, nshJia, blpackageType, blpackageName,envName);
			if(nfsFlag.equals("是")){
				addExternalCmdToEnd(blpackageDbKey1,"deleteshell",startCmdPath,undoCmdPath);
				importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
				addExternalCmdToEnd(blpackageDbKey1,"modifypermission",endCmdPath,undoCmdPath);
			}else{
				importDepotObjectToPackage(appsysCode, serverName, nshJia,blpackageName,shJia,jobName,fileType,envName);
			}
			
			Object nshNeiRong = null;
			
			if(nfsFlag.equals("是")){
				if(list.get(0).equals("WINDOWS")){
					nshNeiRong = nshWindowsText(checkParamJson, generalParamJson, jobName);
				}else{
					nshNeiRong = nfsNshText(checkParamJson, generalParamJson, jobName);
				}
			}else{
				if(list.get(0).equals("WINDOWS")){
					nshNeiRong = nshWindowsText(checkParamJson, generalParamJson, jobName);
				}else{
					nshNeiRong = nshText(checkParamJson, generalParamJson, jobName);
				}
			}
				File file = new File(shPath);
				if(!file.exists()){
					file.mkdirs();
				}
				PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
				out.println(nshNeiRong);
				out.flush();
				out.close();
			createToolJob(appsysCode,jiaMing,nshJobToolName,toolNshScriptPath,replaceNshScriptName,bsaServer,envName);
			addToolJobParam(nshwenjianPath,nshJobToolName,appsysCode,serverName,nshJia,jiaMing,nshName,envName);
			String nshJobDbkey=(String) getNshJobDbKey(nshJobToolName, appsysCode, jiaMing,envName);
			exceNshJob(nshJobDbkey);
			deleteJob(appsysCode,jiaMing,nshJobToolName,envName);
			clearNSHScriptParametersByGroupAndName(appsysCode,serverName,nshJia,nshName,envName);
			addParamToNshScript(appsysCode,serverName,nshJia,nshName,checkParamJson,generalParamJson,envName);
		}
				List<DplyJobScriptInfoVo> jobScriptInfoList = new ArrayList<DplyJobScriptInfoVo>();
				List<String> paramList1=new ArrayList<String>();
				JSONArray generalParam = JSONArray.fromObject(generalParamJson);
				List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
				for(int i=0;i<generalParamJsonList.size();i++){
					paramList1.add(generalParamJsonList.get(i));
				}
				DplyJobScriptInfoVo jobScriptInfoVo=null;
				for(int i=0;i<paramList1.size();i++){
					jobScriptInfoVo=new DplyJobScriptInfoVo();
					jobScriptInfoVo.setAppsysCode(appsysCode);
					jobScriptInfoVo.setJobParentGroup(serverName);
					jobScriptInfoVo.setScriptBlpackageName(nshName);
					jobScriptInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
					jobScriptInfoVo.setScriptName(jobName);
					jobScriptInfoVo.setScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
					jobScriptInfoVo.setParamName(paramList1.get(i));
					jobScriptInfoVo.setParamType(1);
					jobScriptInfoVo.setParamValue("??TARGET.ATTR_"+envName+"_" + appsysCode + "_" + ming + "." + paramList1.get(i) + "??");
					jobScriptInfoList.add(jobScriptInfoVo);
				}
				for (DplyJobScriptInfoVo vo1 : jobScriptInfoList) {
					getSession().save(vo1);
				}
				List<DplyJobScriptInfoVo> jobScriptInfoList1 = new ArrayList<DplyJobScriptInfoVo>();
				List<String> paramList2=new ArrayList<String>();
				JSONArray checkParam = JSONArray.fromObject(checkParamJson);
				List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkParam, String.class);
				for(int i=0;i<checkParamJsonList.size();i++){
					paramList2.add(checkParamJsonList.get(i));
				}
				for(int i=0;i<paramList2.size();i++){
					jobScriptInfoVo=new DplyJobScriptInfoVo();
					jobScriptInfoVo.setAppsysCode(appsysCode);
					jobScriptInfoVo.setJobParentGroup(serverName);
					jobScriptInfoVo.setScriptBlpackageName(nshName);
					jobScriptInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
					jobScriptInfoVo.setScriptName(jobName);
					jobScriptInfoVo.setScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
					jobScriptInfoVo.setParamName(ComUtil.checkNull(paramList2.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
					jobScriptInfoVo.setParamType(2);
					jobScriptInfoVo.setParamValue(ComUtil.checkNull(paramList2.get(i).split(Constants.SPLIT_SEPARATEOR)[1]));
					jobScriptInfoList1.add(jobScriptInfoVo);
				}
				for (DplyJobScriptInfoVo vo2 : jobScriptInfoList1) {
					getSession().save(vo2);
				}
				DplyJobBlpackageInfoVo jobBlpackageInfoVo=new DplyJobBlpackageInfoVo();
				jobBlpackageInfoVo.setAppsysCode(appsysCode);
				jobBlpackageInfoVo.setScriptBlpackageName(blpackageName);
				jobBlpackageInfoVo.setScriptBlpackagePath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia);
				jobBlpackageInfoVo.setJobParentGroup(serverName);
				jobBlpackageInfoVo.setSoftlinkScriptName(jobName);
				jobBlpackageInfoVo.setSoftlinkScriptPath("/DEPLOY/"+appsysCode+"/"+serverName+"/"+shJia);
				getSession().save(jobBlpackageInfoVo);
	}

	/**
	 * 创建外部命令文件
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void createCmdFile(String startCmdName, String endCmdName,
			String undoCmdName, String shPath, String appsysCode, String ming,
			String serverName, String jobName, String envName) throws UnsupportedEncodingException, FileNotFoundException {
		// TODO Auto-generated method stub
		StringBuilder startCmd= new StringBuilder();
		String crlf=System.getProperty("line.separator");
		startCmd.append("cd ??TARGET.ATTR_"+envName+"_").append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_ExecPath??;").append(crlf);
		startCmd.append("if [ -f ").append(jobName).append(" ]").append(crlf);
		startCmd.append("then").append(crlf);
		startCmd.append("su - ??TARGET.ATTR_"+envName+"_").append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_AppUser?? -c \"cd ??TARGET.ATTR_"+envName+"_");
		startCmd.append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_ExecPath??;").append(" rm -f ").append(jobName).append("\"").append(crlf);
		startCmd.append("fi");
		File file = new File(shPath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(startCmdName)),"utf-8"));
		out.println(startCmd);
		out.flush();
		out.close();
		StringBuilder endCmd= new StringBuilder();
		endCmd.append("cd ??TARGET.ATTR_"+envName+"_").append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_ExecPath??;").append(crlf);
		endCmd.append("chmod 764 ").append(jobName).append(";").append(crlf);
		endCmd.append("chown ??TARGET.ATTR_"+envName+"_").append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_AppUser??:??TARGET.ATTR_"+envName+"_").append(appsysCode).append("_").append(ming).append(".").append(serverName).append("_AppUserGroup?? ").append(jobName);
		File file1 = new File(shPath);
		if(!file1.exists()){
			file1.mkdirs();
		}
		PrintWriter out1 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(endCmdName)),"utf-8"));
		out1.println(endCmd);
		out1.flush();
		out1.close();
		
		File file2 = new File(shPath);
		if(!file2.exists()){
			file2.mkdirs();
		}
		PrintWriter out2 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(undoCmdName)),"utf-8"));
		out2.println("");
		out2.flush();
		out2.close();
		
	}

	/**
	 * 删除多条数据
	 * @param shPath 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@Transactional(rollbackFor=Exception.class)
	public void deleteByIds(String[] appsysCodes, String[] jobParentGroups,
			String[] scriptBlpackageNames, String[] jobNames, String shPath) throws Exception {
		for (int i = 0; i < appsysCodes.length && i < jobParentGroups.length&& i < scriptBlpackageNames.length; i++) {
			deleteById(appsysCodes[i], jobParentGroups[i],scriptBlpackageNames[i], shPath);
		}		
	}
	/**
	 * 删除多单条数据

	 * @throws Exception
	 * @throws JEDAException
	 */
	@Transactional(rollbackFor=Exception.class)
	private void deleteById(String appsysCode, String jobParentGroup, String scriptBlpackageName, String shPath) throws AxisFault, SQLException, Exception {
		String moveFileScript="MoveDepotFiletoagroup.nsh";
		String targetGroup="DUSTBIN";
		String toolJobName = moveFileScript.substring(0,moveFileScript.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		String fileType="DEPOT_FILE_OBJECT";
		String shJia = "SCRIPTS";
		String nshJia="NSHELLS";
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		
		String ip=messages.getMessage("systemServer.ip");
		String blpackageType="BLPACKAGE";
		String nshName=scriptBlpackageName.substring(0,scriptBlpackageName.indexOf(".")).concat(".nsh");
		String nshJobName=scriptBlpackageName.substring(0,scriptBlpackageName.indexOf("."));
		
		StringBuilder scriptNamesql = new StringBuilder();
		scriptNamesql.append("select distinct b.script_name from dply_job_info t,dply_job_script_info b " );
		scriptNamesql.append(" where t.appsys_code=b.appsys_code and t.nsh_blpackage_name=b.nsh_script_name" );
		scriptNamesql.append(" and t.job_parent_group=b.job_parent_group and t.appsys_code='"+appsysCode+"' " );
		scriptNamesql.append(" and t.job_parent_group='"+jobParentGroup+"' and t.nsh_blpackage_name='"+scriptBlpackageName+"' " );
		Query query2 = getSession().createSQLQuery(scriptNamesql.toString());
		String scriptName=(String) query2.list().get(0);
		
		//String scriptName=scriptBlpackageName.substring(0,scriptBlpackageName.indexOf(".")).concat(".sh");
		String blpackageName=appsysCode+"_"+jobParentGroup+"_"+"ALLFILES";
		String jiaMing = "TOOLS";
		
		String bsaServer = messages.getMessage("bsa.ipAddress");
		String envJobInfo = "select t.environment_code from dply_job_info t where appsys_code = '"+appsysCode+"' " +
				"and nsh_blpackage_name = '"+nshName+"' " +
						"and job_parent_group='"+jobParentGroup+"'" ;
		Query envuery = getSession().createSQLQuery(envJobInfo.toString());
		List<String> envCode = (List<String>)envuery.list();
		String envName = null;
		for (int k = 0; k < envCode.size(); k++) {
			if(envCode.get(k).equals("DEV")){
				envName="DEV";
			}
		}
		
		String sqlJobInfo = "delete dply_job_info where appsys_code = '"+appsysCode+"' " +
				"and nsh_blpackage_name = '"+nshName+"' " +
						"and job_parent_group='"+jobParentGroup+"'" ;
		getSession().createSQLQuery(sqlJobInfo).executeUpdate();
		
		String sqlJobBlpackageInfo = "delete dply_job_blpackage_info where appsys_code = '"+appsysCode+"' and softlink_script_name = '"+scriptName+"' and job_parent_group='"+jobParentGroup+"'" ;
		getSession().createSQLQuery(sqlJobBlpackageInfo).executeUpdate();
		String sqlJobScriptInfo = "delete dply_job_script_info where appsys_code = '"+appsysCode+"' and script_name = '"+scriptName+"' and job_parent_group='"+jobParentGroup+"'" ;
		getSession().createSQLQuery(sqlJobScriptInfo).executeUpdate();
		StringBuilder sql = new StringBuilder();
		sql.append(" select o.softlinkScriptName as \"softlinkScriptName\"    ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.BLPACKAGE_NAME as scriptBlpackageName,")
				.append(" b.blpackage_path as scriptBlpackagePath,  ")
				.append(" b.job_parent_group as jobParentGroup,  ")
				.append(" b.softlink_script_name as softlinkScriptName, ")
				.append(" b.softlink_script_path as softlinkScriptPath ")
				.append(" from dply_job_blpackage_info b where b.appsys_code =:appsysCode and  b.job_parent_group=:jobParentGroup and b.BLPACKAGE_NAME=:blpackageName ) o  ");
		Query query=  getSession().createSQLQuery(sql.toString())
				.setString("appsysCode", appsysCode)
				.setString("jobParentGroup", jobParentGroup)
				.setString("blpackageName", blpackageName);
		List<String> gouXuan = (List<String>)query.list();
		
		String nshToolsGroup=(String) jobGroupExists(appsysCode, jiaMing,envName);
		if(nshToolsGroup.equals("false")){
			createJobGroup(appsysCode, jiaMing,envName);
		}
		String ming="";
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, jobParentGroup);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
		}
		if(gouXuan.size()==0){
			String sqlJobInfo1 = "delete dply_job_info where appsys_code = '"+appsysCode+"' " +
					"and nsh_blpackage_name = '"+blpackageName+"' " +
							"and job_parent_group='"+jobParentGroup+"'" ;
			getSession().createSQLQuery(sqlJobInfo1).executeUpdate();
			deleteShFile(appsysCode, jobParentGroup, shJia, scriptName,envName);
			deleteJob(appsysCode,jiaMing,toolJobName,envName);
			deleteNshFile(appsysCode,jobParentGroup,nshJia,nshName,envName);
			deleteNshJob(appsysCode,jobParentGroup,nshJobName,envName);
		}else{
			String groupId=(String) groupNameToId(appsysCode,jobParentGroup,shJia,envName);
			createBlpackage(blpackageName,groupId);
			String blpackageDbKey=(String) getFileDbKey(appsysCode, jobParentGroup, shJia, blpackageType, blpackageName,envName);
			StringBuilder nfssql = new StringBuilder();
			nfssql.append("select t.nfs_flag from cmn_app_group_service t where t.appsys_code='"+appsysCode+"' and t.service_name='"+jobParentGroup+"'" );
			Query query1 = getSession().createSQLQuery(nfssql.toString());
			String nfsFlag=(String) query1.list().get(0);		
			String startCmdName="startCmdFile.txt";
			String endCmdName="endCmdFile.txt";
			String undoCmdName="undoCmdFile.txt";
			String startCmdPath="//"+ip+"/"+Path+"/"+startCmdName;
			String endCmdPath="//"+ip+"/"+Path+"/"+endCmdName;
			String undoCmdPath="//"+ip+"/"+Path+"/"+undoCmdName;
			for(int i=0;i<gouXuan.size();i++){
				if(nfsFlag.equals("是")){
					createCmdFile(startCmdName,endCmdName,undoCmdName,shPath,appsysCode,ming,jobParentGroup,(String) gouXuan.get(i), envName);
					addExternalCmdToEnd(blpackageDbKey,"deleteshell",startCmdPath,undoCmdPath);
					importDepotObjectToPackage(appsysCode, jobParentGroup, shJia,blpackageName,shJia,(String) gouXuan.get(i),fileType,envName);
					addExternalCmdToEnd(blpackageDbKey,"modifypermission",endCmdPath,undoCmdPath);
				}else{
					 importDepotObjectToPackage(appsysCode, jobParentGroup, shJia,blpackageName,shJia,(String) gouXuan.get(i),fileType,envName);
				}
			}
			updateByName(appsysCode, jobParentGroup, shJia, nshJia, blpackageName,envName);
			deleteBlpackage(appsysCode, jobParentGroup, shJia,blpackageName,envName);
			createToolJob(appsysCode,jiaMing,toolJobName,toolNshScriptPath,moveFileScript,bsaServer,envName);
			addToolJobParam1(appsysCode, jobParentGroup, shJia, scriptName, targetGroup, jiaMing, toolJobName,envName);
			String nshJobDbkey=(String) getNshJobDbKey(toolJobName, appsysCode, jiaMing,envName);
			exceNshJob(nshJobDbkey);
			deleteJob(appsysCode,jiaMing,toolJobName,envName);
			deleteNshFile(appsysCode,jobParentGroup,nshJia,nshName,envName);
			deleteNshJob(appsysCode,jobParentGroup,nshJobName,envName);
		}
	}
	
	
	/**
	 * 添加外部命令

	 * @throws Exception
	 * @throws JEDAException
	 */
	private void addExternalCmdToEnd(String blpackageDbKey, String cmdName,
			String startCmdPath, String undoCmdPath) throws Exception{
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(File.separator).concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","addExternalCmdToEnd",new String[] {blpackageDbKey,cmdName,startCmdPath,undoCmdPath,"Abort"});
	
	}
	/**
	 * 删除Blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private void deleteBlpackage(String appsysCode, String jobParentGroup,
			String shJia, String blpackageName,String envName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(File.separator).concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","deleteBlPackageByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+shJia+"",""+blpackageName+""});
	}

	/**
	 * 查询数据库是否存在数据

	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryExist(String appsysCode,String jobParentGroup,String scriptBlpackageName) throws SQLException {
		String scriptBlpackageNames=scriptBlpackageName.substring(0,scriptBlpackageName.indexOf(".")).concat(".nsh");
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		Map<String, String> paramMap = null;
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.jobName as \"jobName\", ")
				.append(" o.jobType as \"jobType\", ")
				.append("o.jobPath as \"jobPath\", ")
				.append("o.jobParentGroup as \"jobParentGroup\", ")
				.append("o.scriptBlpackageName as \"scriptBlpackageName\", ")
				.append("o.jobCreator as \"jobCreator\", ")
				.append("o.jobCreated as \"jobCreated\", ")
				.append("o.jobModifier as \"jobModifier\", ")
				.append(" o.jobModified as \"jobModified\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.job_name as jobName,")
				.append("   b.job_type as jobType,  ")
				.append("  b.job_path as jobPath,  ")
				.append("  b.job_parent_group as jobParentGroup,  ")
				.append("  b.nsh_blpackage_name as scriptBlpackageName,  ")
				.append("  b.job_creator as jobCreator,  ")
				.append("  b.job_created as jobCreated,  ")
				.append("  b.job_modifier as jobModifier,  ")
				.append(" 	b.job_modified as jobModified  ")
				.append(" from DPLY_JOB_INFO b) o where  o.appsysCode =:appsysCode and  o.jobParentGroup=:jobParentGroup and o.scriptBlpackageName=:scriptBlpackageName");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("jobParentGroup", jobParentGroup)
				.setString("scriptBlpackageName", scriptBlpackageNames);
				List<Map> isExist = query.list();
				String exist="";
				if(isExist.size()>0){
					exist="true";
				}else{
					exist="false";
				}
				return exist;
	}
	/**
	 * 替换blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object updateByName(String appsysCode,String jobParentGroup,String shJia,String blpackageGroupName,String blpackageName,String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","updateByName",new String[] {""+blpackageName+"",""+blpackageName+"","/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+shJia+"","/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+blpackageGroupName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除.sh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object deleteShFile(String appsysCode,String jobParentGroup,String shJia,String scriptBlpackageName,String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DepotFile","deleteFileByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+shJia+"",""+scriptBlpackageName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除.nsh文件
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object deleteNshFile(String appsysCode,String jobParentGroup,String nshJia,String nshName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","deleteNSHScriptByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+nshJia+"",""+nshName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除nsh作业
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object deleteNshJob(String appsysCode,String jobParentGroup,String nshJobName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/",""+nshJobName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 清除blpackage作业中的服务器

	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object clearTargetServer(String blpackageJobDbkey, String bsaServer) throws Exception{
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("Job","clearTargetServer",new String[] {""+blpackageJobDbkey+"",""+bsaServer+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * blpackage包作业的Dbkey
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object getBlpackageJobDbkey(String appsysCode, String serverName,
			String blpackageName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DeployJob","getDBKeyByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"",""+blpackageName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建blpackage包作业

	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object createBlpackageJob(String blpackageName,String blpackageGroupId, String blpackageDbkey, String bsaServer) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DeployJob","createDeployJob",new String[] {""+blpackageName+"",""+blpackageGroupId+"",""+blpackageDbkey+"","0",""+bsaServer+"","false","true","false",
				"2","true","false","true","true","true","true","true","true","false","true","0","0","true","30","true","60","true","true","0"});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 获取作业文件夹的Id
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object jobGroupId(String appsysCode, String serverName,String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobGroup","groupNameToId",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 清除脚本中的参数内容
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object clearNSHScriptParametersByGroupAndName(String appsysCode,String serverName, String nshJia, String nshName, String envName)  throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","clearNSHScriptParametersByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+nshJia+"",""+nshName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	
	/**
	 * blpackage作业是否存在
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object blpackageJobIsExist(String appsysCode, String serverName,String blpackageName,String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DeployJob","getDBKeyByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"",""+blpackageName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 向blpackage中加入软连接
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void importDepotObjectToPackage(String appsysCode,String serverName, String blpackageGroupName, String blpackageName,String shJia, String jobName, String fileType,String envName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		String ming="";
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
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, serverName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
		}
		// 取得服务分组名

		String pathValue="??TARGET.ATTR_"+envName+"_"+appsysCode+"_"+ming+"."+serverName+"_ExecPath??/"+jobName+"";
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","importDepotObjectToPackage",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+blpackageGroupName+"",""+blpackageName+"","true","false","false","false","false","/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+shJia+"",""+jobName+"",""+fileType+"","Path",""+pathValue+"","NotRequired","NotRequired"});
	}
	
	/**
	 * 新建一个nshJob
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object createNshScriptJob(String appsysCode, String serverName,String nshJia, String nshName,String nshJobName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"",""+nshJobName+""," ","/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+nshJia+"",""+nshName+"","100"});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 取Depot文件夹的Id
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object groupNameToId(String appsysCode, String serverName,String blpackageGroupName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DepotGroup","groupNameToId",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+blpackageGroupName+""});
		String groupId = (String) serverPropertyNames.get_return().getReturnValue();
		return groupId;
	}
	
	
	/**
	 * 创建一个blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private void createBlpackage(String blpackageName,String groupId) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","createEmptyPackage",new String[] {""+blpackageName+""," ",""+groupId+""});
	}
	/**
	 * 新建一个nshJob
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object createBlpackage(String appsysCode, String serverName,String nshJia, String nshName,String nshJobName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/DEPLOY/"+appsysCode+"/"+serverName+"",""+nshJobName+""," ","/DEPLOY/"+appsysCode+"/"+serverName+"/"+nshJia+"",""+nshName+"","100"});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 给nsh脚本附加参数
	 * @param envName 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	private void addParamToNshScript(String appsysCode, String serverName,String nshJia, String nshName, String checkParamJson,String generalParamJson, String envName) throws Exception {
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
		String ming="";
		List<String> fuwuMing = (List<String>) queryMing(appsysCode, serverName);
		for (int i = 0; i < fuwuMing.size(); i++) {
			ming = fuwuMing.get(i);
		}
		List<String> paramList=new ArrayList<String>();
		JSONArray generalParam = JSONArray.fromObject(generalParamJson);
		List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
		for(int i=0;i<generalParamJsonList.size();i++){
			paramList.add(ComUtil.checkNull(generalParamJsonList.get(i)));
		}
		JSONArray checkparam = JSONArray.fromObject(checkParamJson);
		List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkparam, String.class);
		for(int i=0;i<checkParamJsonList.size();i++){
			paramList.add(ComUtil.checkNull(checkParamJsonList.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
		}
		for(int i=0;i<paramList.size();i++){
			String paramValue="??TARGET.ATTR_"+envName+"_"+appsysCode+"_" + ming + "." + paramList.get(i) + "??";
			// 取得服务分组名

			CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+nshJia+"",""+nshName+"",""+paramList.get(i)+""," ",""+paramValue+"","7"});
		}
	}
	
	/**
	 * 查看服务分组名所对应的分组

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryMing(String appsysCode,String jobGroupName) throws SQLException,Exception {
		StringBuilder sql = new StringBuilder();
		sql.append("select  b.serverGroup as \"serverGroup\"")
				.append("from  ( select server_group as serverGroup, ")
				.append(" o.appsys_code  as appsysCode, ")
				.append(" o.service_name  as sericeName")
				.append(" FROM cmn_app_group_service o) b where b.appsysCode=:appsysCode and b.sericeName=:jobGroupName");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("appsysCode", appsysCode)
				.setString("jobGroupName", jobGroupName);
		return query.list();
	}
	/**
	 * 写文件

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object nshText(String checkParamJson,String generalParamJson,String jobName) throws Exception {
		//["WEB_ExecPath","WEB_AppUser","WEB_AppUserGroup"]
		//["PUB_SubTip|+|??TARGET.ATTR_NEXCH_WEB.PUB_SubTip??","PUB_ProcessCount|+|??TARGET.ATTR_NEXCH_WEB.PUB_ProcessCount??","USER_CREATED|+|??TARGET.ATTR_NEXCH_WEB.USER_CREATED??"]
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		List<String> paramList=new ArrayList<String>();
		JSONArray generalParam = JSONArray.fromObject(generalParamJson);
		List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
		for(int i=0;i<generalParamJsonList.size();i++){
			String weiZhi=String.valueOf(i+1);
			paramList.add(ComUtil.checkNull(generalParamJsonList.get(i)));
			nshFile.append(generalParamJsonList.get(i)+"="+"$"+weiZhi).append(crlf);
		}
		nshFile.append("nexec -l -e \"cd ");
		nshFile.append("$").append(generalParamJsonList.get(0)).append(";");
		nshFile.append("chown ");
		nshFile.append("$").append(generalParamJsonList.get(1));
		for(int i=2;i<paramList.size();i++){
			nshFile.append(":").append("$").append(paramList.get(i)).append(" ");
		}
		nshFile.append(jobName).append(" ").append(";");
		nshFile.append("chmod").append(" ").append("a+x").append(" ").append(jobName).append("\"").append(crlf);
		nshFile.append("nexec -l -e su - ").append("$").append(generalParamJsonList.get(1)).append(" -c ").append("\"");
		JSONArray checkparam = JSONArray.fromObject(checkParamJson);
		List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkparam, String.class);
		for(int i=0;i<checkParamJsonList.size();i++){
			paramList.add(ComUtil.checkNull(checkParamJsonList.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
		}
		for(int i=0;i<paramList.size();i++){
			String canshuweizhi=String.valueOf(i+1);
			if(i<9){
			nshFile.append("export ").append(paramList.get(i)).append("=\\\"").append("$").append(canshuweizhi).append("\\\";");
			}
			if(i>8){
				nshFile.append("export ").append(paramList.get(i)).append("=\\\"").append("$").append("{").append(canshuweizhi).append("}").append("\\\";");
			}
		}
		nshFile.append("cd ").append("$").append(paramList.get(0)).append(" ").append(";");
		nshFile.append("sh ").append(jobName).append("\"").append(crlf);
		nshFile.append("if [ $? != 0 ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("exit 151").append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	
	/**
	 * windows写文件

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object nshWindowsText(String checkParamJson,String generalParamJson,String jobName) throws Exception {
		//["WEB_ExecPath","WEB_AppUser","WEB_AppUserGroup"]
		//["PUB_SubTip|+|??TARGET.ATTR_NEXCH_WEB.PUB_SubTip??","PUB_ProcessCount|+|??TARGET.ATTR_NEXCH_WEB.PUB_ProcessCount??","USER_CREATED|+|??TARGET.ATTR_NEXCH_WEB.USER_CREATED??"]
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		List<String> paramList=new ArrayList<String>();
		JSONArray generalParam = JSONArray.fromObject(generalParamJson);
		List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
		for(int i=0;i<generalParamJsonList.size();i++){
			String weiZhi=String.valueOf(i+1);
			paramList.add(ComUtil.checkNull(generalParamJsonList.get(i)));
			nshFile.append(generalParamJsonList.get(i)+"="+"$"+weiZhi).append(crlf);
			nshFile.append("Disk=`echo $"+generalParamJsonList.get(i)+"|awk -F ':' '{print $1}'` ").append(crlf);
		}
		nshFile.append("nexec -l -e cmd /c \"$Disk: && cd $").append(generalParamJsonList.get(0)).append(" &&");
		JSONArray checkparam = JSONArray.fromObject(checkParamJson);
		List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkparam, String.class);
		for(int i=0;i<checkParamJsonList.size();i++){
			paramList.add(ComUtil.checkNull(checkParamJsonList.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
		}
		for(int i=0;i<paramList.size();i++){
			String canshuweizhi=String.valueOf(i+1);
			if(i<9){
			nshFile.append(" set ").append(paramList.get(i)).append("=").append("$").append(canshuweizhi).append("&& ");
			}
			if(i>8){
				nshFile.append(" set  ").append(paramList.get(i)).append("=").append("$").append("{").append(canshuweizhi).append("}").append("&& ");
			}
		}
		nshFile.append(" ").append(jobName).append("\"").append(crlf);
		nshFile.append("if [ $? != 0 ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("exit 151").append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	/**
	 * 写文件

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object nfsNshText(String checkParamJson,String generalParamJson,String jobName) throws Exception {
		//["WEB_ExecPath","WEB_AppUser","WEB_AppUserGroup"]
		//["PUB_SubTip|+|??TARGET.ATTR_NEXCH_WEB.PUB_SubTip??","PUB_ProcessCount|+|??TARGET.ATTR_NEXCH_WEB.PUB_ProcessCount??","USER_CREATED|+|??TARGET.ATTR_NEXCH_WEB.USER_CREATED??"]
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		List<String> paramList=new ArrayList<String>();
		JSONArray generalParam = JSONArray.fromObject(generalParamJson);
		List<String> generalParamJsonList = (List<String>) JSONArray.toCollection(generalParam, String.class);
		for(int i=0;i<generalParamJsonList.size();i++){
			String weiZhi=String.valueOf(i+1);
			paramList.add(ComUtil.checkNull(generalParamJsonList.get(i)));
			nshFile.append(generalParamJsonList.get(i)+"="+"$"+weiZhi).append(crlf);
		}
		nshFile.append("nexec -l -e su - ").append("$").append(generalParamJsonList.get(1)).append(" -c ").append("\"");
		JSONArray checkparam = JSONArray.fromObject(checkParamJson);
		List<String> checkParamJsonList = (List<String>) JSONArray.toCollection(checkparam, String.class);
		for(int i=0;i<checkParamJsonList.size();i++){
			paramList.add(ComUtil.checkNull(checkParamJsonList.get(i).split(Constants.SPLIT_SEPARATEOR)[0]));
		}
		for(int i=0;i<paramList.size();i++){
			String canshuweizhi=String.valueOf(i+1);
			if(i<9){
			nshFile.append("export ").append(paramList.get(i)).append("=\\\"").append("$").append(canshuweizhi).append("\\\";");
			}
			if(i>8){
				nshFile.append("export ").append(paramList.get(i)).append("=\\\"").append("$").append("{").append(canshuweizhi).append("}").append("\\\";");
			}
		}
		nshFile.append("cd ").append("$").append(paramList.get(0)).append(" ").append(";");
		nshFile.append("sh ").append(jobName).append("\"").append(crlf);
		nshFile.append("if [ $? != 0 ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("exit 151").append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	/**
	 * 查看server属性名称

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object listAllServerPropertyNames() throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("PropertyClass","listAllPropertyNames",new String[] { DplyConstants.PARAMSMETER_SERVER_PREFIX });
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}

	/**
	 * 删除作业
	 * @param envName 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteJob(String appsysCode,String jiaMing,String toolJobName, String envName) throws Exception {
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

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 检查DEPOT文件夹是否存在
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object depotGroupExists(String groupName) throws Exception {
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

		CLITunnelServiceClient GroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("DepotGroup","groupExists",new String[] { groupName});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 检查DEPOT文件夹是否存在
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object groupExists(String appsysCode,String serverName,String shJia, String envName) throws Exception {
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

		CLITunnelServiceClient GroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("DepotGroup","groupExists",new String[] { "/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+shJia+""});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 检查JOB文件夹是否存在

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupExists(String appsysCode,String jiaMing,String envName) throws Exception {
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

		CLITunnelServiceClient GroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("JobGroup","groupExists",new String[] { "/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+""});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建DEPOT文件夹
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createGroup(String appsysCode,String serverName,String shJia, String envName) throws Exception {
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

		CLITunnelServiceClient createGroup = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] { ""+shJia+"","/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+""});
		String value = (String) result.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建JOB文件夹
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createJobGroup(String appsysCode,String jobJia, String envName) throws Exception {
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

		CLITunnelServiceClient createGroup = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("JobGroup","createGroupWithParentName",new String[] { ""+jobJia+"","/DEPLOY/"+envName+"/"+appsysCode+""});
		String value = (String) result.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 上传脚本.sh
	 * @param shJia 
	 * @param serverName 
	 * @param appsysCode 
	 * @param jobName 
	 * @param ip 
	 * @param path 
	 * @param ip 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object addFileToDepot(String appsysCode, String serverName, String shJia, String jobName, String path, String ip,String envName) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","addFileToDepot",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+shJia+"","//"+ip+"/"+path+"/"+jobName+"",""+jobName+""," "});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 上传nsh脚本
	 * @param shJia 
	 * @param serverName 
	 * @param appsysCode 
	 * @param jobName 
	 * @param ip 
	 * @param path 
	 * @param ip 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object addNshToDepot(String appsysCode, String serverName, String nshJia, String jobName, String path, String ip,String envName) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScript","addNSHScriptToDepotByGroupName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+nshJia+"","2","//"+ip+"/"+path+"/"+jobName+"",""+jobName+""," "});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 取文件的DbKey(Depot)
	 * @param envName 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getFileDbKey(String appsysCode,String serverName,String shJia,String fileType,String jobName, String envName) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","getDBKeyByTypeStringGroupAndName",new String[] { ""+fileType+"","/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+shJia+"",""+jobName+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 取NshJob的DbKey
	 * @param envName 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getNshJobDbKey(String toolJobName,String appsysCode,String jiaMing, String envName) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 执行NshJob
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object exceNshJob(String nshJobDbkey) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] {""+nshJobDbkey+""});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建TOOLS作业
	 * @param envName 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createToolJob(String appsysCode,String jiaMing,String toolJobName,String toolNshScriptPath,String toolNshScriptName,String bsaServer, String envName) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""," ",""+toolNshScriptPath+"",""+toolNshScriptName+"",""+bsaServer+"","100"});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 创建TOOLS作业附参数
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam(String wenjianPath,String toolJobName,String appsysCode,String serverName,String shJia,String jiaMing,String jobName, String envName) throws Exception {
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
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","0",""+wenjianPath+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","1",""+jobName+""});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","2","/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+shJia+" "});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		return DbKey;
	}
	/**
	 * 创建TOOLS作业附参数
	 * @param envName 

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam1(String appsysCode,String jobParentGroup,String shJia,String scriptName,String targetGroup,String jiaMing,String jobName, String envName) throws Exception {
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
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+jobName+""});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+jobName+"","0","/DEPLOY/"+envName+"/"+appsysCode+"/"+jobParentGroup+"/"+shJia+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+jobName+"","1",""+scriptName+""});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+jobName+"","2","/DEPLOY/"+targetGroup+""});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		return DbKey;
	}
	/**
	 * Depot文件夹附策略
	 * @param envName 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object groupApplyAclPolicy(String appsysCode,String serverName,String jiaMing, String envName) throws Exception {
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
		String ceLv="PLCY_"+envName+"_"+appsysCode+"_APPADMIN";
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotGroup","applyAclPolicy",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serverName+"/"+jiaMing+"",""+ceLv+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * JOB文件夹附策略
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupApplyAclPolicy(String appsysCode,String jiaMing) throws Exception {
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
		String ceLv="PLCY_"+appsysCode+"_APPADMIN";
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/DEPLOY/"+appsysCode+"/"+jiaMing+"",""+ceLv+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 文件附策略
	 * @param envName 

	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object applyAclPolicy( String shDbKey,String appsysCode, String envName) throws NoSuchMessageException, Exception {
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
		String ceLv="PLCY_"+envName+"_"+appsysCode+"_APPADMIN";
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","applyAclPolicy",new String[] {""+shDbKey+"",""+ceLv+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * job作业附策略
	 * @param envName 

	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object applyJobAclPolicy(String shDbKey,String appsysCode, String envName) throws NoSuchMessageException, Exception {
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
		String ceLv="PLCY_"+envName+"_"+appsysCode+"_APPADMIN";
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","applyAclPolicy",new String[] {""+shDbKey+"",""+ceLv+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 查询Nsh
	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryNsh(String appsysCode, String jobParentGroup,
			String scriptBlpackageName,String jobName) {
		List<String> list=queryOsType(appsysCode, jobParentGroup);
		String scrtiptName;
		if(list.get(0).equals("WINDOWS")){
			scrtiptName=jobName.concat(".bat");
		}else{
			scrtiptName=jobName.concat(".sh");
		}
		
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.blpackageName as \"blpackageName\", ")
				.append(" o.blpackagePath as \"blpackagePath\", ")
				.append("o.jobParentGroup as \"jobParentGroup\", ")
				.append("o.osType as \"osType\", ")
				.append("o.scriptBlpackageName as \"scriptBlpackageName\", ")
				.append("o.softlinkScriptPath as \"softlinkScriptPath\" ")
				.append(" from (  ")
				.append("  select b.appsys_code as appsysCode,  ")
				.append("  b.blpackage_name as blpackageName,")
				.append("  b.blpackage_path as blpackagePath,  ")
				.append("  t.os_type as osType,  ")
				.append("  b.job_parent_group as jobParentGroup,  ")
				.append("  b.softlink_script_name as scriptBlpackageName,  ")
				.append("  b.softlink_script_path as softlinkScriptPath  ")
				.append(" from dply_job_blpackage_info b ,cmn_app_group_service t where b.appsys_code=t.appsys_code and b.job_parent_group=t.service_name) o where  o.appsysCode =:appsysCode and  o.jobParentGroup=:jobParentGroup and o.scriptBlpackageName=:scriptBlpackageName ");
		return  getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("jobParentGroup", jobParentGroup)
				.setString("scriptBlpackageName", scrtiptName).uniqueResult();
		
	}
	/**
	 * 查询服务分组
	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryGroup(Integer start, Integer limit, String sort,
			String dir, Map<String, Object> params) throws SQLException,Exception{
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.serviceName as \"serviceName\", ")
				.append(" o.serverGroup as \"serverGroup\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" to_char(wm_concat(b.service_name)) as serviceName,")
				.append(" b.server_group as serverGroup  ")
				.append(" from cmn_app_group_service b group by b.appsys_code,b.server_group ) o where o.appsysCode in :sysList");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countGroup(Map<String, Object> params) throws SQLException,Exception {

		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.serviceName as \"serviceName\", ")
				.append(" o.serverGroup as \"serverGroup\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" to_char(wm_concat(b.service_name)) as serviceName,")
				.append(" b.server_group as serverGroup  ")
				.append(" from cmn_app_group_service b group by b.appsys_code,b.server_group ) o where o.appsysCode in :sysList");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return (long) query.list().size();
	}
	/**
	 * 服务分组保存
	 * 
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	@Transactional(rollbackFor=Exception.class)
	public void saveGroup(CmnAppGroupServiceVo cmnAppGroupServiceVo) throws AxisFault,SQLException,Exception {
		String appsysCode=cmnAppGroupServiceVo.getAppsysCode();
		String seviceName=cmnAppGroupServiceVo.getGroupValue();
		String envCode = cmnAppGroupServiceVo.getEnvironmentCode();
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		CmnAppGroupServiceVo appGroupSeviceVo=null;
		List<String> paramList=new ArrayList<String>();
 		JSONArray groupParam = JSONArray.fromObject(seviceName);
		List<Map<String, Object>> groupParamJsonList = (List<Map<String, Object>>) JSONArray.toCollection(groupParam, Map.class);	
		for (Map<String, Object> mapprarm : groupParamJsonList) {
			appGroupSeviceVo=new CmnAppGroupServiceVo();
			appGroupSeviceVo.setAppsysCode(appsysCode);
			appGroupSeviceVo.setServiceName((String) mapprarm.get("groupName"));
			appGroupSeviceVo.setServerGroup((String)mapprarm.get("serverGroup"));
			appGroupSeviceVo.setNfsFlag((String)mapprarm.get("nfsFlag"));
			appGroupSeviceVo.setOsType((String)mapprarm.get("osType"));
			appGroupSeviceVo.setEnvironmentCode(envName);
			getSession().save(appGroupSeviceVo);
			//添加depot文件夹

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
			String ceLv="PLCY_"+envName+"_"+appsysCode+"_APPADMIN";
			// 取得服务分组名

			CLITunnelServiceClient createGroup = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] { ""+(String) mapprarm.get("groupName")+"","/DEPLOY/"+envName+"/"+appsysCode+""});
			ExecuteCommandByParamListResponse jobParentGroupNames = createGroup.executeCommandByParamList("DepotGroup","applyAclPolicy",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+(String) mapprarm.get("groupName")+"",""+ceLv+""});
			// 取得服务分组名

			ExecuteCommandByParamListResponse result1 = createGroup.executeCommandByParamList("JobGroup","createGroupWithParentName",new String[] { ""+(String) mapprarm.get("groupName")+"","/DEPLOY/"+envName+"/"+appsysCode+""});
			ExecuteCommandByParamListResponse jobParentGroupNames1 = createGroup.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+(String) mapprarm.get("groupName")+"",""+ceLv+""});			
		}
	}

	/**
	 * 服务分组修改保存
	 * 
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	@Transactional(rollbackFor=Exception.class)
	public void editGroup(CmnAppGroupServiceVo cmnAppGroupServiceVo) throws AxisFault,SQLException,Exception {
		String appsysCode=cmnAppGroupServiceVo.getAppsysCode();
		String deleteName=cmnAppGroupServiceVo.getGroupValue().replace("\"", "");
		String seviceName=cmnAppGroupServiceVo.getNameValue();
		String groupName=cmnAppGroupServiceVo.getValue().replace("\"", "");
		String envCode = cmnAppGroupServiceVo.getEnvironmentCode();
		String envName=null;
		if(envCode.equals("开发环境")){
			envName="DEV";
		}
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
	
		JSONArray groupParam1 = JSONArray.fromObject(cmnAppGroupServiceVo.getNameValue());
		List<Map<String, Object>> groupParamJsonList1 = (List<Map<String, Object>>) JSONArray.toCollection(groupParam1, Map.class);
		if(groupParamJsonList1.size()==0){
			StringBuilder sql = new StringBuilder();
			sql.append(" select b.service_name from cmn_app_group_service b ")
					.append(" where b.appsys_code=:appsysCode and b.server_group=:groupName  ");
			Query query=  getSession().createSQLQuery(sql.toString())
					.setString("appsysCode", appsysCode)
					.setString("groupName", groupName);
			List<String> list=query.list();
			for(int i=0;i<list.size();i++){
				String sqlJobInfo1 = "delete cmn_app_group_service where appsys_code = '"+appsysCode+"' " +
						"and service_name = '"+list.get(i)+"'";
				getSession().createSQLQuery(sqlJobInfo1).executeUpdate();
				ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5001","/DEPLOY/" + appsysCode + "/"+list.get(i)+"" });
				ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5005","/DEPLOY/" + appsysCode + "/"+list.get(i)+"" });
			}
		}else{
		String sqlJobGroup="select b.service_name from cmn_app_group_service b where b.appsys_code="+appsysCode+" and b.server_group="+groupName+"";
		StringBuilder sql = new StringBuilder();
		sql.append(" select b.service_name from cmn_app_group_service b ")
				.append(" where b.appsys_code=:appsysCode and b.server_group=:groupName  ");
		Query query=  getSession().createSQLQuery(sql.toString())
				.setString("appsysCode", appsysCode)
				.setString("groupName", groupName);
		List<String> list=query.list();
		String sqlJobInfo1 = "delete cmn_app_group_service where appsys_code = '"+appsysCode+"' " +
				"and server_group = '"+groupName+"'";
		getSession().createSQLQuery(sqlJobInfo1).executeUpdate();
		CmnAppGroupServiceVo appGroupSeviceVo=null;
		List<String> paramList=new ArrayList<String>();
		JSONArray groupParam = JSONArray.fromObject(seviceName);
		List<Map<String, String>> groupParamJsonList = (List<Map<String, String>>) JSONArray.toCollection(groupParam, Map.class);	
		for (Map<String, String> mapprarm : groupParamJsonList) {
			appGroupSeviceVo=new CmnAppGroupServiceVo();
			appGroupSeviceVo.setAppsysCode(appsysCode);
			appGroupSeviceVo.setServiceName((String) mapprarm.get("groupName"));
			appGroupSeviceVo.setServerGroup(groupName);
			appGroupSeviceVo.setOsType((String)mapprarm.get("osType"));
			appGroupSeviceVo.setNfsFlag((String) mapprarm.get("nfsFlag"));
			appGroupSeviceVo.setEnvironmentCode(envName);
			getSession().save(appGroupSeviceVo);
			paramList.add((String) mapprarm.get("groupName"));
		}
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5001","/DEPLOY/"+envName+"/" + appsysCode + "/"+deleteName+"" });
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5005","/DEPLOY/"+envName+"/" + appsysCode + "/"+deleteName+"" });
		List<String> deleteList=new ArrayList<String>();
		List<String> addList=new ArrayList<String>();
		for(int j=0;j<list.size();j++){
			if(!paramList.contains(list.get(j))){
				deleteList.add(list.get(j));
			}
		}
		for(int k=0;k<deleteList.size();k++){
			ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5001","/DEPLOY/"+envName+"/" + appsysCode + "/"+deleteList.get(k)+"" });
			ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName.executeCommandByParamList("Group","deleteGroupByTypeAndQualifiedName",new String[] {"5005","/DEPLOY/"+envName+"/" + appsysCode + "/"+deleteList.get(k)+"" });
		}
		for(int t=0;t<paramList.size();t++){
			if(!list.contains(paramList.get(t))){
				addList.add(paramList.get(t));
			}
		}
		String ceLv="PLCY_"+envName+"_"+appsysCode+"_APPADMIN";
		for(int p=0;p<addList.size();p++){
			ExecuteCommandByParamListResponse result = jobParentGroupName.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] { ""+addList.get(p)+"","/DEPLOY/"+envName+"/"+appsysCode+""});
			ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName.executeCommandByParamList("DepotGroup","applyAclPolicy",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+addList.get(p)+"",""+ceLv+""});
			// 取得服务分组名

			ExecuteCommandByParamListResponse result1 = jobParentGroupName.executeCommandByParamList("JobGroup","createGroupWithParentName",new String[] { ""+addList.get(p)+"","/DEPLOY/"+envName+"/"+appsysCode+""});
			ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+addList.get(p)+"",""+ceLv+""});			
			}
		}
	}
	/**
	 * 查询grid中的内容
	 * 
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public Object queryNR(String appsysCode, String serverGroup) throws SQLException,Exception{
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.groupName as \"groupName\", ")
				.append("o.serviceName as \"serviceName\", ")
				.append("o.nfsFlag as \"nfsFlag\", ")
				.append("o.osType as \"osType\", ")
				.append(" o.serverGroup as \"serverGroup\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.os_type as osType,  ")
				.append(" b.service_name as groupName,")
				.append(" b.service_name as serviceName,")
				.append(" b.nfs_flag as nfsFlag,")
				.append(" b.server_group as serverGroup  ")
				.append(" from cmn_app_group_service b ) o where o.appsysCode in :sysList and o.appsysCode =:appsysCode and o.serverGroup=:serverGroup");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		   query.setString("appsysCode", appsysCode)
				.setString("serverGroup", serverGroup)
				.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return query.list();
	}

	/**
	 * 服务分组是否存在
	 * 
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public Object queryGroupExist(String appsysCodes, String serviceNames) throws SQLException,Exception{
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from DplyJobInfoVo b where 1=1  and b.appsysCode in :sysList and b.appsysCode=:appsysCode and b.jobParentGroup=:jobParentGroup");


		Query query = getSession().createQuery(hql.toString());
		query.setString("appsysCode", appsysCodes).setString("jobParentGroup", serviceNames).setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		Long.valueOf(query.uniqueResult().toString());
		String groupExist="";
		if(Long.valueOf(query.uniqueResult().toString())>0){
			groupExist="true";
		}else{
			groupExist="false";
		}
		return groupExist;
	}
	/**
	 * 查询操作系统类型
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public List<String> queryosType(String appsysCode, String serviceName) {
		// TODO Auto-generated method stub
		StringBuilder sql = new StringBuilder();
		sql.append("select t.os_type from cmn_app_group_service t where t.appsys_code='"+appsysCode+"' and t.service_name='"+serviceName+"'");
		Query query = (Query) getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	/**
	 * 查询操作系统类型
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public List<String> queryOsType(String appsysCode, String serviceName) {
		// TODO Auto-generated method stub
		StringBuilder sql = new StringBuilder();
		sql.append("select t.os_type from cmn_app_group_service t where t.appsys_code='"+appsysCode+"' and t.service_name='"+serviceName+"'");
		Query query = (Query) getSession().createSQLQuery(sql.toString());
		return query.list();
	}
	/**
	 * job作业附策略
	 * @param envCode 

	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object listJobGroup(String appsysCode, String envCode) throws NoSuchMessageException, Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("JobGroup","findAllGroupsByParentGroupName",new String[] { "/DEPLOY/"+envCode+"/" + appsysCode + "" });
		String group = (String) jobParentGroupNames.get_return().getReturnValue();
		return group;
	}
	/**
	 * 紧急下载脚本
	 * @param params
	 * @return
	 * @throws NoSuchMessageException 
	 * @throws Exception 
	*/
		public void downloadScript(String appsysCode,String path,String envCode) throws NoSuchMessageException, Exception {
			// TODO Auto-generated method stub
		//String ip="10.1.120.147";
		String envName=envCode;
		String ip=messages.getMessage("systemServer.ip");
	    String targetPath="";
		String crlf=System.getProperty("line.separator");
		String FilePath = path;
		StringBuffer scriptPathSb = new StringBuffer();
		 if(ComUtil.isWindows){
			 	path=path.replace(":", "").replace("\\", "/");
			}else{
				path=path.substring(1);
			}
		 targetPath="//"+ip+"/"+path;
		
		 String GroupNames = (String) listJobGroup(appsysCode,envName);
		 if (!GroupNames.equals("void")) {
				String[] GroupName = GroupNames.split("\n");
				List<String> list=new ArrayList<String>();
				for (int i = 0; i < GroupName.length; i++) {
					if(GroupName[i].length()-14>0){
					String yanzheng=GroupName[i].substring(GroupName[i].length()-14,GroupName[i].length());
					boolean ds = DateFunction.isDate(yanzheng);
					if("false".equals(ds)){
						list.add(GroupName[i].trim());
						}
					}else{
						list.add(GroupName[i].trim());
					}
				}
				list.remove("TOOLS");
				for(int i=0;i<list.size();i++){
					String scriptNames=(String) listAllByGroup(appsysCode,list.get(i),envName);
					String[] scriptName = scriptNames.split("\n");
					for (int j = 0; j < scriptName.length; j++) {
						if(scriptName[j].indexOf("MARKDELETE")==-1){
							String scriptPath=(String) getLocationByGroupAndName(appsysCode,list.get(i),scriptName[j],envName);
							if(!scriptPath.equals("void")){
								scriptPathSb.append(scriptPath);
								scriptPathSb.append(",");
								scriptPathSb.append(scriptName[j]);
								scriptPathSb.append(crlf);
							}
						}
					}
					
				}
				String username = securityUtils.getUser().getUsername();
				String textName = appsysCode.concat(username).concat(".txt");
				File file = new File(FilePath);
				if(!file.exists()){
					file.mkdirs();
				}
				PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(FilePath.concat(File.separator).concat(textName)),"utf-8"));
				out.println(scriptPathSb);
				out.flush();
				out.close();
				String bsaServer = messages.getMessage("bsa.ipAddress");
				String jiaMing="TOOLS";
				String nshToolsGroup=(String) jobGroupExists(appsysCode, jiaMing,envName);
				//存在该文件夹
				if(nshToolsGroup.equals("false")){
					createJobGroup(appsysCode, jiaMing,envName);
				}
				String downloadScriptName="BulkCopyDepotFiles.nsh";
				String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
				String toolJobName = downloadScriptName.substring(0,downloadScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
				createToolJob(appsysCode,jiaMing,toolJobName,toolNshScriptPath,downloadScriptName,bsaServer,envName);
				addToolJobParam2(appsysCode, jiaMing, toolJobName,textName,targetPath,envName);
				
				String nshJobDbkey=(String) getNshJobDbKey(toolJobName, appsysCode, jiaMing,envName);
				exceNshJob(nshJobDbkey);
				deleteJob(appsysCode,jiaMing,toolJobName,envName);
				File file1 = new File(FilePath.concat(File.separator).concat(textName));
				if(file1.exists()){
					file1.delete();
				}
		 	}
		 
		}
		private Object getLocationByGroupAndName(String appsysCode, String serviceName,
			String scriptName, String envName) throws Exception {
		// TODO Auto-generated method stub
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
			ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","getLocationByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serviceName+"/SCRIPTS",scriptName});
			String bsaShPath = (String) jobParentGroupNames.get_return().getReturnValue();
			return bsaShPath;
	}

		/**
		 * 执行NshJob
		 * @param envName 
		 * 
		 * @throws Exception
		 * @throws JEDAException
		 */
		public Object listAllByGroup(String appsysCode,String serviceName, String envName) throws Exception {
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

			CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
					res4Login.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","listAllByGroup",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+serviceName+"/SCRIPTS"});
			String value = (String) jobParentGroupNames.get_return().getReturnValue();
			return value;
		}
		
	
	/**
	 * 执行NshJob
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object exceNshJob1(String nshJobDbkey) throws Exception {
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

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","execute",new String[] {""+nshJobDbkey+""});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	
	private void addToolJobParam2(String appsysCode, String jiaMing,
			String toolJobName,  String textName, String targetPath, String envName) throws Exception {
		// TODO Auto-generated method stub
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
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+""});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","0",targetPath+"/"+textName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/DEPLOY/"+envName+"/"+appsysCode+"/"+jiaMing+"",""+toolJobName+"","1",targetPath});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();

	}
}
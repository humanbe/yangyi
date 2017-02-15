package com.nantian.check.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.CheckConstants;
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.StringUtil;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;

/**
 * 日志管理
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class JobLogService {

	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	@Autowired
	private ScriptExecService scriptExecService;
	@Autowired
	private ScriptUploadService scriptUploadService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	private AppInfoService appInfoService;

	/**
	 * 构造方法
	 */
	public JobLogService() {
		fields.put("checkJobName", FieldType.STRING);
		fields.put("scriptName", FieldType.STRING);
		fields.put("jobType", FieldType.STRING);
		fields.put("checkJobStatus", FieldType.STRING);
		fields.put("checkJobExecuter", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param batchOvertimeAnaVo
	 * @throws Exception
	 */
	@Transactional
	public void save(CheckItemInfoVo checkItemInfoVo) throws Exception {
		String deployValue = checkItemInfoVo.getDeployValue();
		String scriptDeployValue = checkItemInfoVo.getScriptDeployValue();
		List<String> list = new ArrayList<String>();
		JSONArray checkInit = JSONArray.fromObject(scriptDeployValue);
		List<String> checkInitList = (List<String>) JSONArray.toCollection(
				checkInit, String.class);
		if (scriptDeployValue.length() > 0) {
			for (String param : checkInitList) {
				list.add(param);
			}
		}
		List<String> ipList = new ArrayList<String>();
		JSONArray serverIp = JSONArray.fromObject(deployValue);
		List<String> serverIpList = (List<String>) JSONArray.toCollection(
				serverIp, String.class);
		if (deployValue.length() > 0) {
			for (String server : serverIpList) {
				ipList.add(server);
			}
		}
		StringBuffer sb = new StringBuffer();
		for (int i = 0; i < ipList.size(); i++) {
			if (i == ipList.size() - 1) {
				sb.append(ipList.get(i));
			} else {
				sb.append(ipList.get(i)).append(",");
			}
		}
		String binScirptName = checkItemInfoVo.getBinScriptName();
		String itemNshName = binScirptName.substring(0,
				binScirptName.indexOf(".")).concat("_item.nsh");

		String osType = scriptUploadService.getOstype(checkItemInfoVo
				.getOsTypes());
		String fieldType = checkItemInfoVo.getFieldTypes();
		String jobGroup = CheckConstants.ChenkGroupName + "/" + osType;
		String deployJobName = "DEPLOY_"
				+ itemNshName
						.substring(0, itemNshName.indexOf("."))
						.concat("_")
						.concat((new SimpleDateFormat("yyyyMMddHHmmss")
								.format(new Date())).toString());
		String itemNshGroup = CheckConstants.ChenkGroupName + "/" + osType
				+ "/" + fieldType + "/" + "ITEM";
		String jobDbKye = (String) createNshScriptJob(jobGroup, deployJobName,
				itemNshGroup, itemNshName);
		addTargetServers(jobDbKye, sb.toString());
		// Job - addTargetServer
		addJobParam(jobGroup, deployJobName, list);
		String jobDbKye1 = (String) scriptUploadService.getNshJobDbKey(
				jobGroup, deployJobName);
		scriptUploadService.exceNshJob(jobDbKye1);
		scriptExecService.saveJob(deployJobName, jobGroup, itemNshName,
				jobDbKye1, "2");
	}

	private Object addTargetServers(String jobDbKye, String serverIps)
			throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null, System
						.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName
				.executeCommandByParamList("Job", "addTargetServers",
						new String[] { jobDbKye, serverIps });
		String value = (String) serverPropertyNames.get_return()
				.getReturnValue();
		return value;
	}

	/**
	 * 创建TOOLS作业附参数
	 * 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addJobParam(String jobGroup, String jobName, List<String> list)
			throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null, System
						.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"clearNSHScriptParameterValuesByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName });
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "0",
								"??TARGET.IP_ADDRESS??" });
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "1",
								"??TARGET.CHECK_PushFile??" });
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "2",
								"??TARGET.CHECK_SYSPATH??" });

		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "3", "y" });
		ExecuteCommandByParamListResponse jobParentGroupNames5 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "4", "n" });
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName0
				.executeCommandByParamList("NSHScriptJob",
						"addNSHScriptParameterValueByGroupAndName",
						new String[] { "/" + jobGroup + "", jobName, "5",
								"??TARGET.CHECK_ExecuteCommonInitnsh??" });
		for (int i = 0; i < list.size(); i++) {
			if (list.get(i).equals("SET")) {
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"6", "y" });
			} else {
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"6", "n" });
			}
			if (list.get(i).equals("INIT")) {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"7", "y" });
			} else {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"7", "n" });
			}
			if (list.get(i).equals("BIN")) {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"8", "y" });
			} else {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0
						.executeCommandByParamList("NSHScriptJob",
								"addNSHScriptParameterValueByGroupAndName",
								new String[] { "/" + jobGroup + "", jobName,
										"8", "n" });
			}
		}
	}

	/**
	 * 新建一个nshJob
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unused")
	private Object createNshScriptJob(String jobGroup, String jobName,
			String scriptGroup, String scriptName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null, System
						.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName
				.executeCommandByParamList("NSHScriptJob",
						"createNSHScriptJob", new String[] {
								"/" + jobGroup + "", jobName, " ",
								"/" + scriptGroup + "", scriptName, "100" });
		String value = (String) serverPropertyNames.get_return()
				.getReturnValue();
		return value;
	}

	/**
	 * 查询作业表数据
	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @param jobEndTime 
	 * @param jobStartTime 
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params, String jobStartTime, String jobEndTime)
			throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select o.checkJobName as \"checkJobName\", ")
				.append("o.scriptName as \"scriptName\", ")
				.append("o.jobType as \"jobType\", ")
				.append("o.checkJobStatus as \"checkJobStatus\", ")
				.append("o.checkJobExecuter as \"checkJobExecuter\", ")
				.append("o.jobStartTime as \"jobStartTime\", ")
				.append("o.jobEndTime as \"jobEndTime\" from  ")
				.append("(select t.check_job_name as checkJobName, ")
				.append("t.script_name as scriptName, ")
				.append("t.job_type as jobType, ")
				.append("t.check_job_status as checkJobStatus,  ")
				.append("t.check_job_executer as checkJobExecuter, ")
				.append("to_char(t.job_start_time, 'yyyymmdd hh:mi:ss') as jobStartTime, ")
				.append("to_char(t.job_end_time, 'yyyymmdd hh:mi:ss') as jobEndTime ")
				.append(" from check_job_log_info t) o where 1=1");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		  if(null != jobStartTime && jobStartTime.length() > 0){
          	sql.append(" and o.jobStartTime >= to_char('" + jobStartTime + "')");
          }
          
          if(null != jobEndTime && jobEndTime.length() > 0){
          	sql.append(" and o.jobEndTime <= to_char('" + jobEndTime + "+1')");
          }
		sql.append(" order by " + sort + " " + dir);
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @param jobEndTime 
	 * @param jobStartTime 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params, String jobStartTime, String jobEndTime) throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append(
				"select count(*)  from ( select o.checkJobName as \"checkJobName\", ")
				.append("o.scriptName as \"scriptName\", ")
				.append("o.jobType as \"jobType\", ")
				.append("o.checkJobStatus as \"checkJobStatus\", ")
				.append("o.checkJobExecuter as \"checkJobExecuter\", ")
				.append("o.jobStartTime as \"jobStartTime\", ")
				.append("o.jobEndTime as \"jobEndTime\" from  ")
				.append("(select t.check_job_name as checkJobName, ")
				.append("t.script_name as scriptName, ")
				.append("t.job_type as jobType, ")
				.append("t.check_job_status as checkJobStatus,  ")
				.append("t.check_job_executer as checkJobExecuter, ")
				.append("to_char(t.job_start_time, 'yyyymmdd hh:mi:ss') as jobStartTime, ")
				.append("to_char(t.job_end_time, 'yyyymmdd hh:mi:ss') as jobEndTime ")
				.append(" from check_job_log_info t) o where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		 if(null != jobStartTime && jobStartTime.length() > 0){
	          	sql.append(" and o.jobStartTime >= to_char('" + jobStartTime + "')");
	          }
	          
	          if(null != jobEndTime && jobEndTime.length() > 0){
	          	sql.append(" and o.jobEndTime <= to_char('" + jobEndTime + "+1')");
	          }
		sql.append(" ) m");
		Query query = (Query) getSession().createSQLQuery(sql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询初始化项
	 * 
	 * @param params
	 * @return
	 */
	public Object queryInit(String osType, String checkItemCode) {
		StringBuilder sql = new StringBuilder();
		sql.append("select o.scriptType as \"scriptType\"  ")
				.append("from (select t.script_type as scriptType from check_item_script_info t ,check_item_info d where t.check_item_code=d.check_item_code and d.os_type='"
						+ osType
						+ "' and t.check_item_code='"
						+ checkItemCode
						+ "') o ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		return query.list();
	}

	/**
	 * 查询操作系统下的服务器
	 * @param serverIp
	 * @param params
	 * @return
	 * @throws SQLException
	 */
	public Object queryServerIp(String osType, String serverIp)
			throws SQLException {
		// TODO Auto-generated method stub

		String osTypeName = scriptUploadService.getOstype(osType);
		StringBuilder sql = new StringBuilder();
		sql.append("select d.appsysName as \"appsysName\",  ")
				.append("  d.serverName as \"serverName\" , ")
				.append("  d.appsysCode as \"appsysCode\" , ")
				.append(" d.serverIp as \"serverIp\" ")
				.append("from( select o.appsys_code as appsysCode ,o.systemname as appsysName, t.server_name as serverName, t.server_ip as serverIp from cmn_servers_info t ,v_cmn_app_info o where t.appsys_code=o.appsys_code and t.os_type='"
						+ osTypeName
						+ "' and t.bsa_agent_flag='1' and  t.delete_flag='0'");
		if (!"".equals(serverIp)) {
			sql.append(" and t.server_ip like '%" + serverIp + "%' ");
		}
		sql.append(") d where d.appsysCode in :sysList");
		Query query = getSession()
				.createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setParameterList("sysList",
						appInfoService.getPersonalSysListForCheck());
		return query.list();
	}

	/**
	 * 树下的父节点
	 * 
	 * @return
	 * @throws SQLException
	 */
	public List<String> queryTree() {
		// TODO Auto-generated method stub
		List<String> dataList = new ArrayList<String>();
		dataList.add("SUCCESS");
		dataList.add("ERROR");
		dataList.add("WARNING");
		dataList.add("NOT_RUN");
		return dataList;
	}

	/**
	 * 查询树状数据下的服务器(修改时)
	 * 
	 * @param dataList
	 * @param list
	 * @return
	 */
	public List<JSONObject> getJosnObjectForTree(List<String> dataList,
			List<Map<String, String>> list) {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject cjo = null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;

		for (int i = 0; i < dataList.size(); i++) {
			cjsonList = new ArrayList<JSONObject>();
			int j = 0;
			for (Map<String, String> scMap : list) {
				if (scMap.get("status").equals(dataList.get(i))) {
					j++;
				}
			}
			cjo = new JSONObject();
			cjo.put("text",
					dataList.get(i).concat("(").concat(String.valueOf(j))
							.concat(")"));
			cjo.put("iconCls", "node-treenode");
			cjo.put("isType", true);
			for (Map<String, String> scMap1 : list) {
				if (scMap1.get("status").equals(dataList.get(i))) {
					cjo1 = new JSONObject();
					cjo1.put("text", scMap1.get("server"));
					cjo1.put("iconCls", "node-treenode");
					cjo1.put("leaf", true);
					cjsonList.add(cjo1);
				}
			}
			if (cjo1 == null) {
				cjo.put("leaf", true);
			} else {
				cjo.put("leaf", false);
			}
			cjo.put("children", JSONArray.fromObject(cjsonList));

			sysJsonList.add(cjo);
		}

		return sysJsonList;
	}

	/**
	 * 取得作业下的服务器信息
	 * 
	 * @param dataList
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, String>> findServer(String jobName)
			throws Exception {
		StringBuilder sql = new StringBuilder();
		sql.append("select t.job_run_id from check_job_log_info t where t.check_job_name=:jobName ");
		Query query = getSession().createSQLQuery(sql.toString()).setString(
				"jobName", jobName);
		List<String> list = query.list();
		String servers = null;
		for (int i = 0; i < list.size(); i++) {
			servers = (String) getServersStatusByJobRun(list.get(i));
		}
		List<Map<String, String>> serverList = new ArrayList<Map<String, String>>();
		if (!servers.equals("void")) {
			String server = servers.substring(1, servers.length() - 1);
			String[] aa = server.split(",");
			Map<String, String> map = null;
			for (int i = 0; i < aa.length; i++) {
				map = new HashMap<String, String>();
				map.put("status",
						getServerStatus(aa[i].substring(aa[i].indexOf("=") + 1)));
				map.put("server",
						getServerNameById(aa[i].substring(
								aa[i].lastIndexOf(":") + 1, aa[i].indexOf("="))));
				serverList.add(map);
			}
		}
		return serverList;
	}

	/**
	 * 获取服务器执行状态 return HP-UX
	 * 
	 */
	@Transactional(readOnly = true)
	public String getServerStatus(String value) throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='SERVER_JOB_STATUS' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString()).setString(
				"sub_item_value", value);
		return query.list().get(0).toString();
	}

	/**
	 * 根据服务器id获得服务器名
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public String getServerNameById(String serverId) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null, System
						.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName
				.executeCommandByParamList("Server", "getServerNameById",
						new String[] { serverId });
		String value = (String) serverPropertyNames.get_return()
				.getReturnValue();
		return value;
	}

	/**
	 * 取得所有服务器状态
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getServersStatusByJobRun(String jobRunId) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null, System
						.getProperty("maop.root").concat(File.separator)
						+ messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(
				res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName
				.executeCommandByParamList("JobRun",
						"getServersStatusByJobRun", new String[] { jobRunId });
		String value = (String) serverPropertyNames.get_return()
				.getReturnValue();
		return value;
	}

	/**
	 * 查询日志信息
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Map<String, String> queryLog(String jobName, String server)
			throws Exception {
		// TODO Auto-generated method stub
		StringBuilder sql = new StringBuilder();
		sql.append("select o.checkJobName as \"checkJobName\", ")
				.append("o.scriptName as \"scriptName\", ")
				.append("o.jobType as \"jobType\", ")
				.append("o.checkJobStatus as \"checkJobStatus\", ")
				.append("o.checkJobExecuter as \"checkJobExecuter\", ")
				.append("o.jobLogPath as \"jobLogPath\", ")
				.append("o.jobStartTime as \"jobStartTime\", ")
				.append("o.jobEndTime as \"jobEndTime\" from  ")
				.append("(select t.check_job_name as checkJobName, ")
				.append("t.script_name as scriptName, ")
				.append("t.job_type as jobType, ")
				.append("t.check_job_status as checkJobStatus,  ")
				.append("t.check_job_executer as checkJobExecuter, ")
				.append("t.job_log_path as jobLogPath, ")
				.append("to_char(t.job_start_time, 'yyyymmdd hh:mi:ss') as jobStartTime, ")
				.append("to_char(t.job_end_time, 'yyyymmdd hh:mi:ss') as jobEndTime ")
				.append(" from check_job_log_info t) o where 1=1 and o.checkJobName=:jobName ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("jobName", jobName);
		List<Map<String, String>> list = query.list();
		HashMap<String, String> logMap = new HashMap<String, String>();
		String crlf = System.getProperty("line.separator");
		for (Map<String, String> map : list) {
			logMap.put("checkJobName", map.get("checkJobName"));
			logMap.put("jobStartTime", map.get("jobStartTime"));
			logMap.put("jobEndTime", map.get("jobEndTime"));
			logMap.put("checkJobStatus", map.get("checkJobStatus"));
			String path = map.get("jobLogPath");
			// String path="D:\\test\\OS_LINUX_COMPLIANCE.csv";
			File file = new File(path);
			int i = 0;
			List<Map<String, String>> linesMap = new ArrayList<Map<String, String>>();
			BufferedReader br = new BufferedReader(new FileReader(file));
			StringBuilder log = new StringBuilder();
			String typicalCapaAnaStr = "";
			String[] typicalCapaAnaArr = new String[Constants.SERVER_INFO_COLUMNS];
			try {
				while ((typicalCapaAnaStr = br.readLine()) != null) {
					typicalCapaAnaArr = typicalCapaAnaStr.split(
							Constants.SPLIT_SEPARATEOR, -1);
					if (map.get("jobType") != null && map.get("jobType").equals("1")) {
						if (typicalCapaAnaArr[0]
								.indexOf("-------------------------------------------------") != -1) {
							i++;
							continue;
						}
						if (typicalCapaAnaArr[0].indexOf("-------------------------------------------------") == -1 && i == 1) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
						}
						if (typicalCapaAnaArr[0].indexOf("-------------------------------------------------") == -1 && i == 2) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
						}
						if (i == 3) {
							break;
						}
					} else {
						if (typicalCapaAnaArr[0].indexOf("\"Run at") != -1) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
							log.append(crlf);
						}
					}
				}
			} catch (Exception e) {
				throw e;
			} finally {
				br.close();
			}
			logMap.put("detailJob", log.toString());
		}
		return logMap;
	}

	/**
	 * 查询服务器日志信息
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Map<String, String> queryServerLog(String jobName, String server,
			List<Map<String, String>> list) throws Exception {
		// TODO Auto-generated method stub
		StringBuilder sql = new StringBuilder();
		sql.append("select o.checkJobName as \"checkJobName\", ")
				.append("o.scriptName as \"scriptName\", ")
				.append("o.jobType as \"jobType\", ")
				.append("o.checkJobStatus as \"checkJobStatus\", ")
				.append("o.checkJobExecuter as \"checkJobExecuter\", ")
				.append("o.jobLogPath as \"jobLogPath\", ")
				.append("o.jobStartTime as \"jobStartTime\", ")
				.append("o.jobEndTime as \"jobEndTime\" from  ")
				.append("(select t.check_job_name as checkJobName, ")
				.append("t.script_name as scriptName, ")
				.append("t.job_type as jobType, ")
				.append("t.check_job_status as checkJobStatus,  ")
				.append("t.check_job_executer as checkJobExecuter, ")
				.append("t.job_log_path as jobLogPath, ")
				.append("to_char(t.job_start_time, 'yyyymmdd hh:mi:ss') as jobStartTime, ")
				.append("to_char(t.job_end_time, 'yyyymmdd hh:mi:ss') as jobEndTime ")
				.append(" from check_job_log_info t) o where 1=1 and o.checkJobName=:jobName ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("jobName", jobName);
		List<Map<String, String>> sqlList = query.list();
		HashMap<String, String> logMap = new HashMap<String, String>();
		String crlf = System.getProperty("line.separator");
		for (Map<String, String> map : sqlList) {
			logMap.put("checkJobName", map.get("checkJobName"));
			logMap.put("jobStartTime", map.get("jobStartTime"));
			logMap.put("jobEndTime", map.get("jobEndTime"));
			for (Map<String, String> scMap1 : list) {
				logMap.put("checkJobStatus", scMap1.get("status"));
			}
			String path = map.get("jobLogPath");
			// String path="D:\\test\\OS_LINUX_COMPLIANCE.csv";
			File file = new File(path);
			List<Map<String, String>> linesMap = new ArrayList<Map<String, String>>();
			BufferedReader br = new BufferedReader(new FileReader(file));
			StringBuilder log = new StringBuilder();
			String typicalCapaAnaStr = "";
			String[] typicalCapaAnaArr = new String[Constants.SERVER_INFO_COLUMNS];
			try {
				while ((typicalCapaAnaStr = br.readLine()) != null) {
					typicalCapaAnaArr = typicalCapaAnaStr.split(
							Constants.SPLIT_SEPARATEOR, -1);
					if (map.get("jobType") != null
							&& map.get("jobType").equals("1")) {
						if (typicalCapaAnaArr[0].indexOf("\",\"") != -1) {
							String a[] = typicalCapaAnaArr[0].split("\",\"");
							if (StringUtil.checkIp(a[1]) == true && !a[1].equals(server)) {
								break;
							}
						}
						if (typicalCapaAnaArr[0].indexOf(server) != -1) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
						}
						if (typicalCapaAnaArr[0].indexOf(server) == -1
								&& typicalCapaAnaArr[0].indexOf("\"") != -1) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
						}
					} else {
						if (typicalCapaAnaArr[0].indexOf(server + ",") != -1) {
							log.append(typicalCapaAnaStr);
							log.append(crlf);
							log.append(crlf);
						}
					}
				}
			} catch (Exception e) {
				throw e;
			} finally {
				br.close();
			}
			logMap.put("detailJob", log.toString());
		}
		return logMap;
	}
}

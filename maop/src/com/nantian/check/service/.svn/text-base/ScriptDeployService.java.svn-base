package com.nantian.check.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import net.sf.json.JSONArray;
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
import com.nantian.common.util.ComUtil;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
/**
 * 下发脚本
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class ScriptDeployService {

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
	@Autowired
	private SecurityUtils securityUtils; 
	/**
	 * 构造方法
	 */
	public ScriptDeployService() {
		fields.put("osType", FieldType.STRING);
		fields.put("checkItemCode", FieldType.STRING);
		fields.put("fieldType", FieldType.STRING);
		fields.put("scriptName", FieldType.STRING);
		fields.put("checkItemName", FieldType.STRING);
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
		List<String> checkInitList = (List<String>) JSONArray.toCollection(checkInit, String.class);
		if (scriptDeployValue.length() > 0) {
			for (String param : checkInitList) {
				list.add(param);
			}
		}
		List<String> ipList = new ArrayList<String>();
		JSONArray serverIp = JSONArray.fromObject(deployValue);
		List<String> serverIpList = (List<String>) JSONArray.toCollection(serverIp, String.class);
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
		String itemNshName = binScirptName.substring(0,binScirptName.indexOf(".")).concat("_item.nsh");
		String osType = scriptUploadService.getOstype(checkItemInfoVo.getOsTypes());
		String fieldType = checkItemInfoVo.getFieldTypes();
		String jobGroup = CheckConstants.ChenkGroupName + "/" + osType;
		String deployJobName = "DEPLOY_"+ itemNshName.substring(0, itemNshName.indexOf(".")).concat("_").concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String itemNshGroup = CheckConstants.ChenkGroupName + "/" + osType + "/" + fieldType + "/" + "ITEM";
		String jobDbKye = (String) createNshScriptJob(jobGroup, deployJobName, itemNshGroup, itemNshName);
		addTargetServers(jobDbKye, sb.toString());
		// Job - addTargetServer
		addJobParam(jobGroup, deployJobName, list);
		String jobDbKye1 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptUploadService.exceNshJob(jobDbKye1);
		String jobDbKye2 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptExecService.applyJobAclPolicy(jobDbKye2, CheckConstants.celv);
		String jobDbKye3 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptExecService.applyJobAclPolicy(jobDbKye3,CheckConstants.allSysadminCelv);
		scriptExecService.saveJob(deployJobName, jobGroup, itemNshName,jobDbKye1, "2");
	}

	private Object addTargetServers(String jobDbKye, String serverIps)
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
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("Job", "addTargetServers",new String[] { jobDbKye, serverIps });
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}

	/**
	 * 创建TOOLS作业附参数
	 * 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addJobParam(String jobGroup, String jobName, List<String> list) throws Exception {
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
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] { "/" + jobGroup + "", jobName });
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "0","??TARGET.IP_ADDRESS??" });
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "1","??TARGET.CHECK_PushFile??" });
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "2","??TARGET.CHECK_SYSPATH??" });
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "3", "y" });
		ExecuteCommandByParamListResponse jobParentGroupNames5 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "4", "n" });
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "5","??TARGET.CHECK_ExecuteCommonInitnsh??" });
		for (int i = 0; i < list.size(); i++) {
			if (list.get(i).equals("SET")) {
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName,"6", "y" });
				list.remove(i);
			} else {
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName,"6", "n" });
			}
		}
		if (list.size() > 0) {
			for (int i = 0; i < list.size(); i++) {
				if (list.get(i).equals("INIT")) {
					ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "7", "y" });
					list.remove(i);
				} else {
					ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "7", "n" });
				}
			}
		}
		if (list.size() > 0) {
			for (int i = 0; i < list.size(); i++) {
				if (list.get(i).equals("BIN")) {
					ExecuteCommandByParamListResponse jobParentGroupNames8 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "8", "y" });
				} else {
					ExecuteCommandByParamListResponse jobParentGroupNames8 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "8", "n" });
				}
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob", new String[] {"/" + jobGroup + "", jobName, " ","/" + scriptGroup + "", scriptName, "100" });
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}

	/**
	 * 查询作业表数据
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
			String sort, String dir, Map<String, Object> params) throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  m.osType as \"osType\",")
				.append(" m.checkItemCode as \"checkItemCode\", ")
				.append("m.fieldType as \"fieldType\", ")
				.append("m.checkItemName as \"checkItemName\", ")
				.append("m.scriptType as \"scriptType\", ")
				.append("m.scriptName as \"scriptName\" ")
				.append(" from (  ")
				.append(" select t.os_type as osType, t.check_item_code as checkItemCode, ")
				.append(" t.field_type as fieldType,  ")
				.append(" t.check_item_name as checkItemName, ")
				.append(" o.script_type as scriptType, ")
				.append(" o.script_name  as scriptName")
				.append(" from check_item_info t, check_item_script_info o  ")
				.append(" where t.check_item_code = o.check_item_code   order by t.check_item_code) m where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		Query query = (Query) getSession().createSQLQuery(sql.toString())
				.addScalar("osType", StringType.INSTANCE)
				.addScalar("checkItemCode", StringType.INSTANCE)
				.addScalar("fieldType", StringType.INSTANCE)
				.addScalar("checkItemName", StringType.INSTANCE)
				.addScalar("scriptType", StringType.INSTANCE)
				.addScalar("scriptName", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		List<HashMap<String, String>> list = query.list();
		HashMap<String, String> map = new HashMap<String, String>();
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		String oldCole = null;
		for (int i = 0; i < list.size(); i++) {
			if (i == 0) {
				oldCole = list.get(0).get("checkItemCode");
				map.put("checkItemCode", list.get(i).get("checkItemCode"));
				map.put("osType", list.get(i).get("osType"));
				map.put("fieldType", list.get(i).get("fieldType"));
				map.put("checkItemName", list.get(i).get("checkItemName"));
				if (list.get(i).get("scriptType").equals("BIN")) {
					map.put("binScriptName", list.get(i).get("scriptName"));
				}
				if (list.get(i).get("scriptType").equals("SET")) {
					map.put("setScriptName", list.get(i).get("scriptName"));
				}
				if (list.get(i).get("scriptType").equals("INIT")) {
					map.put("initScriptName", list.get(i).get("scriptName"));
				}
				param.add(map);
			} else {
				if (oldCole.equals(list.get(i).get("checkItemCode"))) {
					map.put("checkItemCode", list.get(i).get("checkItemCode"));
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if (list.get(i).get("scriptType").equals("BIN")) {
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if (list.get(i).get("scriptType").equals("SET")) {
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if (list.get(i).get("scriptType").equals("INIT")) {
						map.put("initScriptName", list.get(i).get("scriptName"));
					}
				} else {
					map = new HashMap<String, String>();
					oldCole = list.get(i).get("checkItemCode");
					map.put("checkItemCode", list.get(i).get("checkItemCode"));
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if (list.get(i).get("scriptType").equals("BIN")) {
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if (list.get(i).get("scriptType").equals("SET")) {
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if (list.get(i).get("scriptType").equals("INIT")) {
						map.put("initScriptName", list.get(i).get("scriptName"));
					}
					param.add(map);
				}
			}
		}
		return param;
	}

	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*)  from ( select  m.osType as \"osType\",")
				.append(" m.checkItemCode as \"checkItemCode\", ")
				.append("m.fieldType as \"fieldType\", ")
				.append("m.checkItemName as \"checkItemName\", ")
				.append("m.scriptType as \"scriptType\", ")
				.append("m.scriptName as \"scriptName\" ")
				.append(" from (  ")
				.append(" select t.os_type as osType, t.check_item_code as checkItemCode, ")
				.append(" t.field_type as fieldType,  ")
				.append(" t.check_item_name as checkItemName, ")
				.append(" o.script_type as scriptType, ")
				.append(" o.script_name  as scriptName")
				.append(" from check_item_info t, check_item_script_info o  ")
				.append(" where t.check_item_code = o.check_item_code and o.script_type='BIN') m where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" )");
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
		   .append("from (select t.script_type as scriptType from check_item_script_info t ,check_item_info d where t.check_item_code=d.check_item_code and d.os_type='"+ osType + "' and t.check_item_code='" + checkItemCode + "') o ");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

	/**
	 * 查询操作系统下的服务器
	 * 
	 * @param serverIp
	 * 
	 * @param params
	 * @return
	 * @throws SQLException
	 */
	public Object queryServerIp(String osType, String serverIp)
			throws SQLException {
		String osTypeName = scriptUploadService.getOstype(osType);
		StringBuilder sql = new StringBuilder();
		sql.append("select d.appsysName as \"appsysName\",  ")
		   .append("  d.serverName as \"serverName\" , ")
		   .append("  d.appsysCode as \"appsysCode\" , ")
		   .append(" d.serverIp as \"serverIp\" ")
		   .append("from( select o. appsys_code as appsysCode ,o.systemname as appsysName, t.server_name as serverName, t.server_ip as serverIp from cmn_servers_info t ,v_cmn_app_info o where t.appsys_code=o.appsys_code and t.os_type='"+ osTypeName + "' and t.bsa_agent_flag='1' and  t.delete_flag='0'");
		if (!"".equals(serverIp)) {
			sql.append(" and t.server_ip like '%" + serverIp + "%' ");
		}
		sql.append(") d where d.appsysCode in :sysList");
		Query query = getSession()
				.createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setParameterList("sysList",appInfoService.getPersonalSysListForCheck());
		return query.list();
	}
	/**
	 * 查询AllInit下的脚本
	 * 
	 * @param serverIp
	 * 
	 * @param params
	 * @return
	 * @throws SQLException
	 */
	public  List<Map<String, String>> queryAllinit(Integer start, Integer limit, String sort,
			String dir, Map<String, Object> params) {
		StringBuilder sql = new StringBuilder();
		sql.append("select d.osType as \"osType\",  ");
		sql.append("d.allinitNshScriptName as \"allinitNshScriptName\" from  ");
		sql.append("(select distinct t.os_type as osType ,t.allinit_nsh_script_name as allinitNshScriptName  from check_item_info t where 1=1");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					sql.append(" and t.os_type like '"+params.get(key)+"'"     );
			}
		}
		sql.append(") d");
		Query query = (Query) getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	/**
	 * 
	 * @throws SQLException
	 */
	public Object countAllinit(Map<String, Object> params) {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from (select distinct t.os_type from check_item_info t");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" where t.os_type like '"+params.get(key)+"'");	
				}
			}
		}
		sql.append(")");
		Query query = getSession().createSQLQuery(sql.toString());
		return Long.valueOf(query.uniqueResult().toString());
	}
	/**
	 * 总项初始化下发or执行
	 * @param flag 
	 * @throws SQLException
	 */
	public List<Map<String, String>> queryAllInit(String flag) {
		List<Map<String,String>> list=new ArrayList<Map<String,String>>();
		Map<String,String> map =new HashMap<String, String>();
		map.put("scriptType", "下发");
		Map<String,String> map1 =new HashMap<String, String>();
		map1.put("scriptType", "执行");
		if(flag.equals("n")){
			list.add(map1);
		}else{
			list.add(map);
			list.add(map1);
		}
		return list;
	}
	/**
	 * 总项初始化下发or执行
	 * @throws Exception 
	 * @throws SQLException
	 */
	public void execAllInit(CheckItemInfoVo checkItemInfoVo) throws Exception {
		// TODO Auto-generated method stub
		String crlf=System.getProperty("line.separator");
		String ip=messages.getMessage("systemServer.ip");
		String init = checkItemInfoVo.getInit();
		String allInitScriptName = checkItemInfoVo.getAllInitScriptName();
		String initServer = checkItemInfoVo.getInitServerIp();
		String osType = allInitScriptName.substring(allInitScriptName.indexOf("_")+1, allInitScriptName.indexOf("."));
		String path =System.getProperty("maop.root") +File.separator + "checkUpload" ;
		String filePath = path;
		
		
		StringBuffer binSb = new StringBuffer();
		StringBuffer setSb = new StringBuffer();
		StringBuffer initSb = new StringBuffer();
		
		StringBuilder sql = new StringBuilder();
		sql.append("select t.sub_item_value from jeda_sub_item t where t.item_id='CHECK_FIELD_TYPE' ");
		Query query = getSession().createSQLQuery(sql.toString());
		List<String> itemList = query.list();
		for(int i=0;i<itemList.size();i++){
			String binShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+itemList.get(i)+"/"+"BIN"+"/"+"SHELL";
			String binShGroupIsExist=(String) scriptUploadService.groupExists(binShGroup);
			if(!binShGroupIsExist.equals("false")){
				String binScriptNames=(String) listAllByGroup(binShGroup);
				String[] binScriptName = binScriptNames.split("\n");
				for (int j = 0; j < binScriptName.length; j++) {
					if(binScriptName[j].indexOf("MARKDELETE")==-1){
						String scriptPath=(String) getLocationByGroupAndName(binShGroup,binScriptName[j]);
						if(!scriptPath.equals("void")){
							binSb.append(scriptPath);
							binSb.append(";");
							binSb.append(binScriptName[j]);
							binSb.append(crlf);
						}
					}
				}
			}
			
			String setShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+itemList.get(i)+"/"+"SET"+"/"+"SHELL";
			String setShGroupIsExist=(String) scriptUploadService.groupExists(setShGroup);
			if(!setShGroupIsExist.equals("false")){
				String setScriptNames=(String) listAllByGroup(setShGroup);
				String[] setScriptName = setScriptNames.split("\n");
				for (int j = 0; j < setScriptName.length; j++) {
					if(setScriptName[j].indexOf("MARKDELETE")==-1){
						String scriptPath=(String) getLocationByGroupAndName(setShGroup,setScriptName[j]);
						if(!scriptPath.equals("void")){
							setSb.append(scriptPath);
							setSb.append(";");
							setSb.append(setScriptName[j]);
							setSb.append(crlf);
						}
					}
				}
			}
			
			String initShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+itemList.get(i)+"/"+"INIT"+"/"+"SHELL";
			String initShGroupIsExist=(String) scriptUploadService.groupExists(initShGroup);
			if(!initShGroupIsExist.equals("false")){
				String initScriptNames=(String) listAllByGroup(initShGroup);
				String[] initScriptName = initScriptNames.split("\n");
				for (int j = 0; j < initScriptName.length; j++) {
					if(initScriptName[j].indexOf("MARKDELETE")==-1){
						String scriptPath=(String) getLocationByGroupAndName(initShGroup,initScriptName[j]);
						if(!scriptPath.equals("void")){
							initSb.append(scriptPath);
							initSb.append(";");
							initSb.append(initScriptName[j]);
							initSb.append(crlf);
						}
					}
				}
			}
		}
	
		File file = new File(path);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath.concat(File.separator).concat("BinFileList.txt")),"utf-8"));
		out.println(binSb);
		out.flush();
		out.close();
		
		File file1 = new File(path);
		if(!file1.exists()){
			file1.mkdirs();
		}
		PrintWriter out1 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath.concat(File.separator).concat("SetFileList.txt")),"utf-8"));
		out1.println(setSb);
		out1.flush();
		out1.close();
		
		File file2 = new File(path);
		if(!file2.exists()){
			file2.mkdirs();
		}
		PrintWriter out2 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath.concat(File.separator).concat("InitFileList.txt")),"utf-8"));
		out2.println(initSb);
		out2.flush();
		out2.close();
		
		if(ComUtil.isWindows){
			path=path.replace(":", "").replace("\\", "/");
		}else{
			path=path.substring(1);
		}
		String binFilePath="//"+ip+"/"+path.concat(File.separator).concat("BinFileList.txt");
		String setFilePath="//"+ip+"/"+path.concat(File.separator).concat("SetFileList.txt");
		String initFilePath="//"+ip+"/"+path.concat(File.separator).concat("InitFileList.txt");
		
		
		List<String> list = new ArrayList<String>();
		JSONArray checkInit = JSONArray.fromObject(init);
		List<String> checkInitList = (List<String>) JSONArray.toCollection(checkInit, String.class);
		if (init.length() > 0) {
			for (String param : checkInitList) {
				list.add(param);
			}
		}
		List<String> ipList = new ArrayList<String>();
		JSONArray serverIp = JSONArray.fromObject(initServer);
		List<String> serverIpList = (List<String>) JSONArray.toCollection(serverIp, String.class);
		if (initServer.length() > 0) {
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
		
		
		String jobGroup = CheckConstants.ChenkGroupName + "/" + osType;
		String deployJobName = "ALLINIT_"+ allInitScriptName.substring(0, allInitScriptName.indexOf(".")).concat("_").concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String itemNshGroup = CheckConstants.ChenkGroupName + "/ALLINIT";
		String jobDbKye = (String) createNshScriptJob(jobGroup, deployJobName, itemNshGroup, allInitScriptName);
		addTargetServers(jobDbKye, sb.toString());
		// Job - addTargetServer
		addAllInitJobParam(jobGroup, deployJobName, list,binFilePath,setFilePath,initFilePath);
		String jobDbKye1 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptUploadService.exceNshJob(jobDbKye1);
		String jobDbKye2 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptExecService.applyJobAclPolicy(jobDbKye2, CheckConstants.celv);
		String jobDbKye3 = (String) scriptUploadService.getNshJobDbKey(jobGroup, deployJobName);
		scriptExecService.applyJobAclPolicy(jobDbKye3,CheckConstants.allSysadminCelv);
		scriptExecService.saveJob(deployJobName, jobGroup, allInitScriptName,jobDbKye1, "2");
		
		
		
		File file3 = new File(filePath.concat(File.separator).concat("BinFileList.txt"));
		if(file3.exists()){
			file3.delete();
		}
		
		File file4 = new File(filePath.concat(File.separator).concat("SetFileList.txt"));
		if(file4.exists()){
			file4.delete();
		}
		
		File file5 = new File(filePath.concat(File.separator).concat("InitFileList.txt"));
		if(file5.exists()){
			file5.delete();
		}
	}
	/**
	 * 获得文件路径
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object getLocationByGroupAndName(String groupName,
			String scriptName) throws Exception {
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
			ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","getLocationByGroupAndName",new String[] {"/"+groupName+"",scriptName});
			String bsaShPath = (String) jobParentGroupNames.get_return().getReturnValue();
			return bsaShPath;
	}

	
	/**
	 * 列出脚本
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object listAllByGroup(String groupName) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","listAllByGroup",new String[] {"/"+groupName+""});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * AllInit作业参数
	 * @param initFilePath 
	 * @param setFilePath 
	 * @param binFilePath 
	 * 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addAllInitJobParam(String jobGroup, String jobName, List<String> list, String binFilePath, String setFilePath, String initFilePath) throws Exception {
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
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] { "/" + jobGroup + "", jobName });
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "0","??TARGET.IP_ADDRESS??" });
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "1","??TARGET.CHECK_SYSPATH??" });
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "2","??TARGET.CHECK_PushFile??" });
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "3","??TARGET.CHECK_ExecuteCommonInitnsh??" });
		
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "4",binFilePath });
		ExecuteCommandByParamListResponse jobParentGroupNames5 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "5",setFilePath });
		ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "6",initFilePath });
		
		
		for (int i = 0; i < list.size(); i++) {
			if (list.get(i).equals("下发")) {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "7", "y" });
				list.remove(i);
			} else {
				ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName,"7", "n" });
			}
		}
		if (list.size() > 0) {
			for (int i = 0; i < list.size(); i++) {
				if (list.get(i).equals("执行")) {
					ExecuteCommandByParamListResponse jobParentGroupNames8 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "8", "y" });
				} else {
					ExecuteCommandByParamListResponse jobParentGroupNames8 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName, "8", "n" });
				}
			}
		}
		ExecuteCommandByParamListResponse jobParentGroupNames9 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "", jobName,"9", "y" });
		ExecuteCommandByParamListResponse jobParentGroupNames10 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "10", "y" });
		ExecuteCommandByParamListResponse jobParentGroupNames11 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] { "/" + jobGroup + "",jobName, "11", "y" });
	}
}

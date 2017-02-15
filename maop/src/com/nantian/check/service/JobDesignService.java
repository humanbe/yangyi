package com.nantian.check.service;

import java.io.File;
import java.io.Serializable;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

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
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.vo.CheckJobTemplateVo;
import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.check.vo.CheckJobServerVo;
import com.nantian.check.vo.CheckJobTimerVo;
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
public class JobDesignService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
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
	@Autowired
	private SecurityUtils securityUtils; 
	public String frontFlag = "一线";
	//BSA上智能组的根目录名称
	public String BSAServerName = "ALLSERVERS";
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	/**
	 * 构造方法	 */
	public JobDesignService() {
		fields.put("appsys_code", FieldType.STRING);
		fields.put("job_code", FieldType.INTEGER);
		fields.put("job_code_bsa", FieldType.STRING);
		fields.put("job_code", FieldType.INTEGER);
		fields.put("check_type",FieldType.STRING);
		fields.put("authorize_lever_type", FieldType.STRING); 
		fields.put("field_type", FieldType.STRING); 
		fields.put("job_path", FieldType.STRING); 
		fields.put("job_name", FieldType.STRING); 
		fields.put("job_name_bsa", FieldType.STRING); 
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
	 * 查询作业和组件IP关联信息
	 * @param jobid 作业编号
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getJobServerList(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.appsys_code as appsys_code,");
 		hql.append("e.job_code as job_code,");
 		hql.append("e.server_path as server_path,");
 		hql.append("e.server_name as server_name");
		hql.append(") from CheckJobServerVo e where e.job_code=?");
		hql.append(" order by e.server_name");
		logger.info(hql.toString());
		//Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString()).setFirstResult(start).setMaxResults(limit);
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.list();
	}
	/**
	 * 获取作业组件服务器的关联总记录数
	 * @param jobid 作业编号
	 */
	@Transactional(readOnly = true)
	public Long countJobServerList(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CheckJobServerVo e where e.job_code=? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 获取作业模板关联表信息
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getBsaJobInfoList(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.appsys_code as appsys_code,");
 		hql.append("e.job_code as job_code,");
 		hql.append("e.template_group as template_group,");
 		hql.append("e.template_name as template_name");
		hql.append(") from CheckJobTemplateVo e where e.job_code=? ");
		hql.append("order by e.template_name") ;
		logger.info(hql.toString());
		//Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString()).setFirstResult(start).setMaxResults(limit);
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.list();
	}
	/**
	 * 获取BSA作业总记录数
	 * @param jobid 作业编号
	 */
	@Transactional(readOnly = true)
	public Long countBsaJobInfoList(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CheckJobTemplateVo e where e.job_code=? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
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
		hql.append("select distinct new map(");
 		hql.append("e.appsysCode as appsysId,");
 		hql.append("e.appsysName as appsysName");
		hql.append(") from CmnAppsysInfoVo e where 1=1 order by e.appsysCode asc");
		logger.info(hql.toString());
		Query query = getSession().createQuery(hql.toString());
		return query.list();
	}
	
	/**
	 * 构建组件目录树	 * @param dataList 父节点列表	 * @param jobCode 作业编号
	 * @return
	 */
	public List<JSONObject> buildServerTree(List<Map<String, Object>> dataList,Integer jobCode,String isView) {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  cjo =  null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;
		String serverGroup = "" ; //服务器分组（OS/DB/WEB/APP）
		Map<String, String> itemMap = this.findMap();
		if(jobCode!=null){
			//获取该作业已绑定的组件IP信息
			List<Map<String,Object>> oldSrvers = getServersByJobCode(jobCode);
			for (Map<String,Object> map : dataList) {
				serverGroup = itemMap.get("SERVER_GROUP".concat(map.get("serverGroup").toString())) ;
				cjsonList = new ArrayList<JSONObject>();
				cjo = new JSONObject();
				cjo.put("text", serverGroup);
				cjo.put("iconCls", "node-module");
				cjo.put("isType", true);
				cjo.put("leaf", false);
				if(isView!=null && isView.equals("1")){
					cjo.put("disabled", true);
				}
				int t =0 ;
				String serverGroupOld = "" ; //组件IP所在分组				for(Map<String,Object> oldServer : oldSrvers){
					serverGroupOld = (String)oldServer.get("server_path") ;
					if(serverGroup.equals(serverGroupOld.substring(serverGroupOld.lastIndexOf("/")+1))){
						t = t+1 ;
					}
				}
				if(t>0){
					cjo.put("checked", true);
				}else{
					cjo.put("checked", false);
				}
				//获取该应用系统和服务器分组下的所有服务器IP
				List<Map<String,Object>> serverList = queryChildren(map.get("appsysCode").toString(),map.get("serverGroup").toString());
				for (Map<String,Object> scMap1 : serverList) {
					if(scMap1.get("serverIp")!=null ){
						cjo1 = new JSONObject();
						cjo1.put("text", scMap1.get("serverIp"));
						cjo1.put("iconCls", "node-leaf");
						cjo1.put("leaf", true);
						if(isView!=null && isView.equals("1")){
							cjo1.put("disabled", true);
						}
						int m =0 ;
						for(Map<String,Object> oldServer : oldSrvers){
							if((scMap1.get("serverIp")).equals(oldServer.get("server_name"))
									&& serverGroup.equals(oldServer.get("server_path"))){
								m = m+1 ;
							}
						}
						if(m>0){
							cjo1.put("checked", true);
						}else{
							cjo1.put("checked", false);
						}
						cjsonList.add(cjo1);
					}
				}
				cjo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(cjo);
			}
		}else{
			for (Map<String,Object> map : dataList) {
				serverGroup = itemMap.get("SERVER_GROUP".concat(map.get("serverGroup").toString())) ;
				cjsonList = new ArrayList<JSONObject>();
				cjo = new JSONObject();
				cjo.put("text",serverGroup);
				cjo.put("iconCls", "node-module");
				cjo.put("isType", true);
				cjo.put("leaf", false);
				cjo.put("checked", false); 
				//获取该应用系统和服务器分组下的所有服务器IP
				List<Map<String,Object>> serverList = queryChildren(map.get("appsysCode").toString(),map.get("serverGroup").toString());
				for (Map<String,Object> scMap1 : serverList) {
					if(scMap1.get("serverIp")!=null ){
						cjo1 = new JSONObject();
						cjo1.put("text", scMap1.get("serverIp"));
						cjo1.put("iconCls", "node-leaf");
						cjo1.put("leaf", true);
						cjo1.put("checked", false);
						cjsonList.add(cjo1);
					}
				}
				cjo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(cjo);
			}
		}
		return sysJsonList;
	}
	
	/**
	 * 构建组件目录树 -- 通用作业
	 * @param dataList 父节点列表	 * @param jobCode 作业编号
	 * @return
	 * @throws Exception 
	 * @throws SQLException 
	 * @throws AxisFault 
	 */
	@SuppressWarnings("unchecked")
	public List<JSONObject> buildServerTreeForCommonJob(String fieldType,Integer jobCode,String isView,String templates) 
			throws AxisFault, SQLException, Exception {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  cjo =  null;
		List<JSONObject> cjsonList = null; //职能组列表
		List<JSONObject> cjsonList2 = null; //服务器列表
		JSONObject cjo1 = null; //智能组对象
		JSONObject cjo2 = null; //服务器对象
		List<String> listTemplates = new ArrayList<String>(); //截取后的模板列表
		if(templates!=null && !templates.equals("")){
			JSONArray arrayTemplates = JSONArray.fromObject(templates);
			//将json格式的数据转换成list对象
			List<Map<String, Object>> listMap = null ; 
			listMap = (List<Map<String, Object>>) JSONArray.toCollection(arrayTemplates, Map.class);
			for(Map<String, Object> map : listMap){
				String templateName = ComUtil.checkJSONNull(map.get("template_name"));
				listTemplates.add(templateName.substring(0, templateName.lastIndexOf("_")));
			}
		}
		//查看页面的服务器目录树处理（此时template为空）
		if(isView!=null && isView.equals("1")){
		    List<Map<String, Object>> listMap = getTemplatesByJobCode(jobCode);
		    for(Map<String, Object> map : listMap){
				String templateName = ComUtil.checkJSONNull(map.get("template_name"));
				listTemplates.add(templateName.substring(0, templateName.lastIndexOf("_")));
			}
		}
		//获取BSA上该专业领域内的所有智能组
		String serverGroups = (String)listServerGroupsByFieldType(fieldType);
		cjsonList = new ArrayList<JSONObject>();
		cjo = new JSONObject();
		cjo.put("text",fieldType);
		cjo.put("iconCls", "node-module");
		cjo.put("isType", true);
		cjo.put("leaf", false);
		if(serverGroups!=null && !serverGroups.equals("void")){
			String[] groupList = serverGroups.split("\n");
			for (String group : groupList) {
				if(listTemplates.contains(group.toString())){
					cjsonList2 = new ArrayList<JSONObject>();
					cjo1 = new JSONObject();
					cjo1.put("text", group.toString());
					cjo1.put("iconCls", "node-module");
					cjo1.put("leaf", false);
					String servers = (String)listServersByGroupName(fieldType,group.toString());
					if(servers!=null && !servers.equals("void")){
						String[] serverList = servers.split("\n");
						for (String server : serverList) {
							cjo2 = new JSONObject();
							cjo2.put("text", server.toString());
							cjo2.put("iconCls", "node-leaf");
							cjo2.put("leaf", true);
							cjsonList2.add(cjo2);
						}
					}
					cjo1.put("children", JSONArray.fromObject(cjsonList2));
					cjsonList.add(cjo1);
				}
			}
		}
		cjo.put("children", JSONArray.fromObject(cjsonList));
		sysJsonList.add(cjo);
		return sysJsonList;
	}
	
	/**
	 * 获取模板CHECK目录树应用系统子节点
	 * @param appsysCode 应用系统编号
	 * @param loginResponse
	 * @return
	 */
	public String getTempSubNodeForAppByAppsys(String appsysCode,LoginUsingSessionCredentialResponse loginResponse) throws AxisFault,Exception{
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "listChildGroupsInGroup", new String[]{"/CHECK/"+appsysCode});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 获取模板COMMON_CHECK目录树应用系统子节点
	 * @param appsysCode 应用系统编号
	 * @param loginResponse
	 * @return
	 */
	public String getTempSubNodeForSysByAppsys(LoginUsingSessionCredentialResponse loginResponse) throws AxisFault,Exception {
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "listChildGroupsInGroup", new String[]{"/COMMON_CHECK"});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 构建模板目录树	 * @param appTemplateGroups CHECK目录应用系统子节点	 * @param commonTemplateGroups COMMON_CHECK目录二级节点
	 * @param appsysCode 作业编号
	 * @return
	 */
	public List<JSONObject> buildTemplateTree(String fieldType,Integer jobCode,String isView) throws AxisFault,Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		List<JSONObject> outJsonList = new ArrayList<JSONObject>();
		JSONObject  cjoSys =  null;
		JSONObject  secondItem =  null; //check目录
		List<JSONObject> cjsonListSys = null;
		JSONObject cjo1Sys = null;
		CLITunnelServiceClient cliClient = null;
		ExecuteCommandByParamListResponse cliResponse = null ;

		List<JSONObject> jsonListSys = new ArrayList<JSONObject>(); 
		int checkThirdSys = 0 ;
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		if(jobCode!=null){//修改页面  
			//获取该作业已绑定的模板信息			List<Map<String,Object>> oldTemplates = getTemplatesByJobCode(jobCode);
			//COMMON_CHECK目录
			int checkedLeafsSys = 0 ; //该父节点被勾选的子节点个数			cjsonListSys = new ArrayList<JSONObject>();
			cjoSys = new JSONObject();
			cjoSys.put("text",fieldType);
			cjoSys.put("iconCls", "node-module");
			cjoSys.put("isType", true);
			cjoSys.put("leaf", false);
			if(isView!=null && isView.equals("1")){
				cjoSys.put("disabled", true);
			}
			List<String> templatesSys = new ArrayList<String>();
			String templateSysId = "" ;
			cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "groupNameToId", new String[]{"/COMMON_CHECK/"+fieldType});
			if(cliResponse.get_return().getSuccess()){
				templateSysId = (String)cliResponse.get_return().getReturnValue();
				cliResponse = cliClient.executeCommandByParamList("Template", "listAllByGroup", new String[]{templateSysId}) ;
				String apiValSys = "";
				if(cliResponse.get_return().getSuccess()){
					apiValSys = (String)cliResponse.get_return().getReturnValue();
					if(apiValSys!=null && !apiValSys.equals("void")){
						String[] apiValStr = apiValSys.split("\n");
						for(int t=0 ; t<apiValStr.length ; t++){
							templatesSys.add(apiValStr[t]);
						}
						if(templatesSys!=null){
							for (int t=0 ; t<templatesSys.size() ; t++) {
								cjo1Sys = new JSONObject();
								cjo1Sys.put("text", templatesSys.get(t).toString());
								cjo1Sys.put("iconCls", "node-leaf");
								cjo1Sys.put("leaf", true);
								if(isView!=null && isView.equals("1")){
									cjo1Sys.put("disabled", true);
								}
								int m =0 ;
								for(Map<String,Object> oldTemplate : oldTemplates){
									if(oldTemplate.get("template_group").equals("/COMMON_CHECK/"+fieldType) && templatesSys.get(t).toString().equals(oldTemplate.get("template_name"))){
										m++;
									}
								}
								if(m>0){
									cjo1Sys.put("checked", true);
									checkedLeafsSys++ ;
								}else{
									cjo1Sys.put("checked", false);
								}
								cjsonListSys.add(cjo1Sys);
							}
						}
					}
				}
			}
			if(checkedLeafsSys > 0){
				cjoSys.put("checked", true);
				checkThirdSys++;
			}else{
				cjoSys.put("checked", false);
			}
			cjoSys.put("children", JSONArray.fromObject(cjsonListSys));
			jsonListSys.add(cjoSys);
			secondItem = new JSONObject();
			secondItem.put("text", "COMMON_CHECK");
			secondItem.put("iconCls", "node-module");
			secondItem.put("isType", true);
			secondItem.put("leaf", false);
			if(isView!=null && isView.equals("1")){
				secondItem.put("disabled", true);
			}
			if(checkThirdSys > 0){
				secondItem.put("checked", true); 
			}else{
				secondItem.put("checked", false); 
			}
			secondItem.put("children", JSONArray.fromObject(jsonListSys));
		}else{  //增加页面
			//COMMON_CHECK目录
			cjsonListSys = new ArrayList<JSONObject>();
			cjoSys = new JSONObject();
			cjoSys.put("text", fieldType);
			cjoSys.put("iconCls", "node-module");
			cjoSys.put("isType", true);
			cjoSys.put("leaf", false);
			cjoSys.put("checked", false); 
			cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "groupNameToId", new String[]{"/COMMON_CHECK/"+fieldType});
			String templateSysId = "";
			if(cliResponse.get_return().getSuccess()){
				templateSysId = (String)cliResponse.get_return().getReturnValue();
				cliResponse = cliClient.executeCommandByParamList("Template", "listAllByGroup", new String[]{templateSysId}) ;
				String apiSysVal = "";
				if(cliResponse.get_return().getSuccess()){
					apiSysVal = (String)cliResponse.get_return().getReturnValue();
					if(apiSysVal!=null && !apiSysVal.equals("void")){
						String[] apiSysValStr = apiSysVal.split("\n");
						List<String> templatesSys = new ArrayList<String>();
						for(int t=0 ; t<apiSysValStr.length ; t++){
							templatesSys.add(apiSysValStr[t]);
						}
						if(templatesSys!=null){
							for (int t=0 ; t<templatesSys.size() ; t++) {
								if(templatesSys.get(t).toString()!=null ){
									cjo1Sys = new JSONObject();
									cjo1Sys.put("text", templatesSys.get(t).toString());
									cjo1Sys.put("iconCls", "node-leaf");
									cjo1Sys.put("leaf", true);
									cjo1Sys.put("checked", false);
									cjsonListSys.add(cjo1Sys);
								}
							}
						}
					}
				}
			}
			cjoSys.put("children", JSONArray.fromObject(cjsonListSys));
			jsonListSys.add(cjoSys);
			secondItem = new JSONObject();
			secondItem.put("text", "COMMON_CHECK");
			secondItem.put("iconCls", "node-module");
			secondItem.put("isType", true);
			secondItem.put("leaf", false);
			secondItem.put("checked", false); 
			secondItem.put("children", JSONArray.fromObject(jsonListSys));
		}
		outJsonList.add(secondItem);
		return outJsonList;
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
		sql.append("select distinct e.appsys_code as \"appsys_code\",")
		   .append(" e.job_code as \"job_code\",")
		   .append(" e.server_target_type as \"server_target_type\",")
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
	 * 根据作业编号和执行频率获取时间表信息
	 * @param jobid 作业编号
	 * @param execFreqType 作业执行频率
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> getTimersByJobCodeAndFreq(Integer jobid,String execFreqType) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code as \"appsys_code\",")
		   .append(" t.job_code as \"job_code\",")
		   .append(" t.timer_code as \"timer_code\",")
		   .append(" t.exec_frequency_type as \"exec_freq_type\",")
		   .append(" t.exec_start_date as \"exec_start_date\",")
		   .append(" t.exec_start_time as \"exec_start_time\",")
		   .append(" t.week1_flag as \"week1_flag\",")
		   .append(" t.week2_flag as \"week2_flag\",")
		   .append(" t.week3_flag as \"week3_flag\",")
		   .append(" t.week4_flag as \"week4_flag\",")
		   .append(" t.week5_flag as \"week5_flag\",")
		   .append(" t.week6_flag as \"week6_flag\",")
		   .append(" t.week7_flag as \"week7_flag\",")
		   .append(" t.interval_weeks as \"interval_weeks\",")
		   .append(" t.month_days as \"month_days\",")
		   .append(" t.interval_days as \"interval_days\",")
		   .append(" t.interval_hours as \"interval_hours\",")
		   .append(" t.interval_minutes as \"interval_minutes\",")
		   .append(" t.exec_priority as \"exec_priority\",")
		   .append(" t.exec_notice_mail_list as \"exec_notice_mail_list\",")
		   .append(" t.mail_success_flag as \"mail_success_flag\",")
		   .append(" t.mail_failure_flag as \"mail_failure_flag\",")
		   .append(" t.mail_cancel_flag as \"mail_cancel_flag\"")
		   .append(" from check_job_timer t ")
		   .append(" where t.job_code=:jobCode and t.exec_frequency_type=:execFreqType") ;
		Query query = getSession().createSQLQuery(sql.toString())
	          					  .setInteger("jobCode", jobid)
		                          .setString("execFreqType", execFreqType)
		                          .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return (List<Map<String, Object>>) query.list();
	}
	
	/**
	 * 根据作业编号获取时间表信息
	 * @param jobid 作业编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> getTimersByJobCode(Integer jobid) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code as \"appsys_code\",")
		   .append(" t.job_code as \"job_code\",")
		   .append(" t.timer_code as \"timer_code\",")
		   .append(" t.exec_frequency_type as \"exec_freq_type\",")
		   .append(" t.exec_start_date as \"exec_start_date\",")
		   .append(" t.exec_start_time as \"exec_start_time\",")
		   .append(" t.week1_flag as \"week1_flag\",")
		   .append(" t.week2_flag as \"week2_flag\",")
		   .append(" t.week3_flag as \"week3_flag\",")
		   .append(" t.week4_flag as \"week4_flag\",")
		   .append(" t.week5_flag as \"week5_flag\",")
		   .append(" t.week6_flag as \"week6_flag\",")
		   .append(" t.week7_flag as \"week7_flag\",")
		   .append(" t.interval_weeks as \"interval_weeks\",")
		   .append(" t.month_days as \"month_days\",")
		   .append(" t.interval_days as \"interval_days\",")
		   .append(" t.interval_hours as \"interval_hours\",")
		   .append(" t.interval_minutes as \"interval_minutes\",")
		   .append(" t.exec_priority as \"exec_priority\",")
		   .append(" t.exec_notice_mail_list as \"exec_notice_mail_list\",")
		   .append(" t.mail_success_flag as \"mail_success_flag\",")
		   .append(" t.mail_failure_flag as \"mail_failure_flag\",")
		   .append(" t.mail_cancel_flag as \"mail_cancel_flag\"")
		   .append(" from check_job_timer t ")
		   .append(" where t.job_code=:jobCode ") ;
		Query query = getSession().createSQLQuery(sql.toString())
		                          .setInteger("jobCode", jobid)
		                          .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return (List<Map<String, Object>>) query.list();
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
	 * 保存作业基本信息
	 * @param checkJobInfo 作业基本信息实体
	 */
	@Transactional
	public void saveJobInfo(CheckJobInfoVo checkJobInfo) {
		getSession().save(checkJobInfo);
	}
	
	/**
	 * 保存作业基本信息
	 * @param checkJobTimer 作业时间表实体
	 */
	@Transactional
	public void saveJobTimer(CheckJobTimerVo checkJobTimer) {
		getSession().save(checkJobTimer);
	}

	/**
	 * 新建常规巡检作业
	 * @param checkJobInfo 作业基本信息实体
	 * @param templates 作业关联的巡检模板
	 * @param serverips 作业关联的组件服务器
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public String createCommonJob(CheckJobInfoVo checkJobInfo, String templates,String servers,CheckJobTimerVo checkJobTimer,
			String timersOnce,String timersDaily,String timersWeekly,String timersMonthly,String timersInterval) throws AxisFault,Exception{
		Date startDate = new Date();
		//巡检目标
		String serverType=checkJobInfo.getServer_target_type();
		//创建BSA作业目录
		addJobPath("COMMON",checkJobInfo.getField_type()); 
		//方法返回值
		String bsaFlag = "" ; 
		//作业路径
		String job_path = "/COMMON_CHECK/" + checkJobInfo.getField_type();
		//作业权限
		String jobAclPolicyApp = "PLCY_COMMON_SYSADMIN";
		//执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		String logState = "0" ; 
		//默认IP：BSA的IP地址
		String firstIP = messages.getMessage("bsa.ipAddress") ; 
		//作业路径节点id
		String groupId = "" ; 
		//模板的DBKey
		String templateKey = "" ; 
		
		checkJobInfo.setDelete_flag("0");
		checkJobInfo.setJob_path(job_path);
		checkJobInfo.setJob_type("1"); //作业类型 1-系统巡检 2-应用巡检
		String username = securityUtils.getUser().getUsername() ;  //用户账号
		if(username!=null && !username.equals("")){
			checkJobInfo.setTool_creator(username);
		}
		//作业时间表列表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		//作业组件实体列表
		List<CheckJobServerVo> checkJobServers = new ArrayList<CheckJobServerVo>();
		List<Map<String, Object>> listServers = null ;
		CheckJobServerVo jobServerVo = null;
		//作业模板实体列表
		List<CheckJobTemplateVo> checkJobTemplates = new ArrayList<CheckJobTemplateVo>();
		List<Map<String, Object>> listTemplates = null ;
		CheckJobTemplateVo jobTemplateVo = null;
		if(servers!=null && !servers.equals("")){
			//将json格式的数据转换成list对象
			JSONArray arrayServers = JSONArray.fromObject(servers);
			listServers = (List<Map<String, Object>>) JSONArray.toCollection(arrayServers, Map.class);
			for(Map<String, Object> map : listServers){
				jobServerVo = new CheckJobServerVo();
				jobServerVo.setAppsys_code(checkJobInfo.getAppsys_code());
				jobServerVo.setJob_code(checkJobInfo.getJob_code()); 
				if(serverType.equals("1")){
					jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("group_path")));
					jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("group_name")));
				}
				if(serverType.equals("0")){
					jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("osType")));
					jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("serverIp")));
				}
				checkJobServers.add(jobServerVo);
			}
		}
		if(templates!=null && !templates.equals("")){
			JSONArray arrayTemplates = JSONArray.fromObject(templates);
			//将json格式的数据转换成list对象
			listTemplates = (List<Map<String, Object>>) JSONArray.toCollection(arrayTemplates, Map.class);
			for(int t=0 ; t<listTemplates.size() ; t++){
				Map<String, Object> map = listTemplates.get(t);
				jobTemplateVo = new CheckJobTemplateVo();
				jobTemplateVo.setAppsys_code(checkJobInfo.getAppsys_code());
				jobTemplateVo.setJob_code(checkJobInfo.getJob_code()); 
 				jobTemplateVo.setTemplate_group(ComUtil.checkJSONNull(map.get("template_group")));
				jobTemplateVo.setTemplate_name(ComUtil.checkJSONNull(map.get("template_name")));
				checkJobTemplates.add(jobTemplateVo);
			}
		}
		//插入执行日志表		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(checkJobInfo.getAppsys_code());
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(checkJobInfo.getJob_name()+"_create");
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
		
		//获取作业路径id
		groupId = (String)jobGroupNameToId(job_path);
		//获取模板的DBKey
		CheckJobTemplateVo firstTemplate = checkJobTemplates.get(0);
		checkJobTemplates.remove(firstTemplate);
		templateKey = (String)getTemplateDBKeyByGroupAndName(firstTemplate.getTemplate_group(),firstTemplate.getTemplate_name());
		
		//判断该路径下是否存在相同名称的作业   - 根据路径和作业名称获取作业的DBKey
		String jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		if(!jobDBKey.equals("") && !jobDBKey.equals("void")){
			changeJobName(checkJobInfo.getJob_name(),job_path); //修改作业名称（在原名称的基础上增加后缀yyyyMMddhhmmss）		}
		//新建BSA巡检作业
		jobDBKey = (String)createComplianceJob(checkJobInfo.getJob_name(),String.valueOf(groupId),templateKey,firstIP);
		
		if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
			//作业增加时间表			checkJobTimers = handleJobTimers(checkJobInfo,checkJobTimer,timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
		}
		
		//作业授权 - 每次授权都需要重新获取作业的DBKey
        jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
        applyAclPolicyForJob(jobDBKey,jobAclPolicyApp);
		//作业关联多个模板
        addMoreTemplate(checkJobInfo,checkJobTemplates);
        //作业关联智能组        String DBKey = (String)addTargetGroupsForJob(checkJobInfo,checkJobServers);
        
		//BSA操作成功后执行JEDA相关数据的保存		if(DBKey!=null && !DBKey.equals("void")){
			//根据作业名称、作业路径获取作业信息
			Map<String, Object> map = getJobCodeByNameAndPath(checkJobInfo.getJob_name(),checkJobInfo.getJob_path());
			if(map!=null && !map.isEmpty() && map.size()>0){
				int jobCode = Integer.valueOf(map.get("job_code").toString());
				//通过存在同名作业，删之
				deleteJobById(jobCode,checkJobInfo.getJob_name(),new SimpleDateFormat("yyyyMMddhhmmss").format(new Date())); 
			}
			this.saveJobInfo(checkJobInfo);
			//插入作业、组件关联关系			if(checkJobServers!=null && checkJobServers.size()>0){
				List<CheckJobServerVo> jobServers = new ArrayList<CheckJobServerVo>();
				for(CheckJobServerVo serverGroup : checkJobServers){
					serverGroup.setJob_code(checkJobInfo.getJob_code());
					jobServers.add(serverGroup);
				}
				saveJobServers(jobServers);
			}
			//插入作业、模板关联关系			if(checkJobTemplates!=null && checkJobTemplates.size()>0){
				List<CheckJobTemplateVo> jobTemplates = new ArrayList<CheckJobTemplateVo>();
				for(CheckJobTemplateVo template : checkJobTemplates){
					template.setJob_code(checkJobInfo.getJob_code());
					jobTemplates.add(template);
				}
				firstTemplate.setJob_code(checkJobInfo.getJob_code());
				jobTemplates.add(firstTemplate);
				saveJobTemplates(jobTemplates);
			}else{
				List<CheckJobTemplateVo> template = new ArrayList<CheckJobTemplateVo>();
				firstTemplate.setJob_code(checkJobInfo.getJob_code());
				template.add(firstTemplate);
				saveJobTemplates(template);
			}
			if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
			//插入作业时间表
				if(checkJobTimers!=null && checkJobTimers.size()>0){
					for(CheckJobTimerVo timer : checkJobTimers){
						timer.setJob_code(checkJobInfo.getJob_code());
						saveJobTimer(timer);
					}
				}
			}	
			bsaFlag = "success" ;
		}
		//插入详细日志表
		Timestamp t = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		CmnDetailLogVo cdlv = new CmnDetailLogVo();
		cdlv.setLogJnlNo(logJnlNo);
		cdlv.setDetailLogSeq(String.valueOf(1));
		cdlv.setAppsysCode(checkJobInfo.getAppsys_code());
		cdlv.setStepName(checkJobInfo.getJob_name());
		cdlv.setJobName("--");
		cdlv.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cdlv.setExecStatus(logState);
		cdlv.setExecDate(execdate);
		cdlv.setExecStartTime(Timestamp.valueOf(starttime));
		cdlv.setExecCompletedTime(t);
		cdlv.setExecCreatedTime(t);
		cdlv.setExecUpdatedTime(t);
		cmnDetailLogService.save(cdlv);
		//修改日志记录结束时间
		cmnLog.setExecCompletedTime(t);
		cmnLog.setExecUpdatedTime(t);
		cmnLogService.update(cmnLog);
		return bsaFlag ;
	}
	
	/**
	 * 批量增加作业组件IP关联数据
	 * @param jobServerList 作业组件关系实体集合
	 * @return false : 失败; true : 成功
	 */
	@Transactional
	public boolean saveJobServers(List<CheckJobServerVo> jobServers) {
		int results = 0;
		for(CheckJobServerVo vo : jobServers){
			getSession().save(vo);
			results += 1 ;
		}
		if(results<jobServers.size()){
			return false ;
		}
		return true;
	}
	/**
	 * 批量增加BSA作业记录
	 * @param jobTemplateList 作业模板关系实体集合
	 * @return false : 失败; true : 成功
	 */
	@Transactional
	public boolean saveJobTemplates(List<CheckJobTemplateVo> jobTemplates) {
		int results = 0;
		for(CheckJobTemplateVo vo : jobTemplates){
			getSession().save(vo);
			results += 1 ;
		}
		if(results<jobTemplates.size()){
			return false ;
		}
		return true;
	}
	
	/**
	 * 修改作业基本信息
	 * @param checkJobJedaInfo 巡检作业实体
	 */
	@Transactional
	public void updateJobInfo(CheckJobInfoVo checkJobInfo) {
		getSession().update(checkJobInfo);
	}
	
	/**
	 * 修改系统巡检作业 - 常规作业
	 * @param checkJobInfo 巡检作业实体
	 * @param templates 作业关联的巡检模板
	 * @param servers 作业关联的组件服务器
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public String updateCommonJob(CheckJobInfoVo checkJobInfo, String templates,String servers,CheckJobTimerVo checkJobTimer
			,String timersOnce,String timersDaily,String timersWeekly,String timersMonthly,String timersInterval
			) throws AxisFault,Exception{
		Date startDate = new Date();
		//方法返回值		//巡检目标
		String serverType=checkJobInfo.getServer_target_type();
		String bsaFlag = "" ; 
		//执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		String logState = "0" ; 
		//作业组件实体列表
		List<CheckJobServerVo> checkJobServers = new ArrayList<CheckJobServerVo>();
		//作业时间表列表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		CheckJobServerVo jobServerVo = null;
		//作业模板实体列表
		List<CheckJobTemplateVo> checkJobTemplates = new ArrayList<CheckJobTemplateVo>();
		List<Map<String, Object>> listTemplates = null ;
		CheckJobTemplateVo jobTemplateVo = null;
		JSONArray arrayServers = JSONArray.fromObject(servers);
		//将json格式的数据转换成list对象
		List<Map<String, Object>> listServers = (List<Map<String, Object>>) JSONArray.toCollection(arrayServers, Map.class);
		for(Map<String, Object> map : listServers){
			jobServerVo = new CheckJobServerVo();
			jobServerVo.setAppsys_code(checkJobInfo.getAppsys_code());
			jobServerVo.setJob_code(checkJobInfo.getJob_code());  
			if(serverType.equals("1")){
				jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("group_path")));
				jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("group_name")));
			}
			if(serverType.equals("0")){
				jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("osType")));
				jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("serverIp")));
			}
			checkJobServers.add(jobServerVo);
		}
        //关联模板处理
		if(templates!=null && !templates.equals("")){
			JSONArray arrayTemplates = JSONArray.fromObject(templates);
			//将json格式的数据转换成list对象
			listTemplates = (List<Map<String, Object>>) JSONArray.toCollection(arrayTemplates, Map.class);
			for(int t=0 ; t<listTemplates.size() ; t++){
				Map<String, Object> map = listTemplates.get(t);
				String temGroup = ComUtil.checkJSONNull(map.get("template_group"));
				jobTemplateVo = new CheckJobTemplateVo();
				jobTemplateVo.setAppsys_code(checkJobInfo.getAppsys_code());
				jobTemplateVo.setJob_code(checkJobInfo.getJob_code()); 
				if(temGroup.indexOf("/COMMON_CHECK")>=0){
					jobTemplateVo.setTemplate_group(temGroup);
				}else{
					jobTemplateVo.setTemplate_group("/"+temGroup);
				}
				jobTemplateVo.setTemplate_name(ComUtil.checkJSONNull(map.get("template_name")));
				checkJobTemplates.add(jobTemplateVo);
			}
		}
		//插入执行日志表
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(checkJobInfo.getAppsys_code());
		cmnLog.setLogResourceType("1");  //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(checkJobInfo.getJob_name()+"_update");
		cmnLog.setLogType("3");  //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(new SecurityUtils().getUser().getUsername());
		Long logJnlNo = cmnLogService.save(cmnLog);
		
		//作业关联模板
		addMoreTemplateForUpdate(checkJobInfo ,checkJobTemplates);
		if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
			//作业时间表			checkJobTimers = handleJobTimers(checkJobInfo,checkJobTimer,timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
		}
		//作业关联智能组		String DBKey = (String)addTargetGroupsForJob(checkJobInfo,checkJobServers);
		
		//BSA操作成功后执行JEDA相关数据的保存
		if(!DBKey.equals("void")){
			this.updateJobInfo(checkJobInfo);
			deleteAllServers(checkJobInfo.getJob_code()); //删除以前的组件关联数据
			saveJobServers(checkJobServers);  //保存新的组件关联数据
			deleteAllTemplates(checkJobInfo.getJob_code()); //删除以前的模板关联数据
			saveJobTemplates(checkJobTemplates);  //保存新的模板关联数据
			deleteTimer(checkJobInfo.getJob_code()); //删除以前的时间表数据
			//插入作业时间表			if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
				if(checkJobTimers!=null && checkJobTimers.size()>0){
					for(CheckJobTimerVo cjtv : checkJobTimers){
						cjtv.setJob_code(checkJobInfo.getJob_code());
						saveJobTimer(cjtv);
					}
				}
			}
			bsaFlag = "success" ;
		}
		 //插入详细日志表
		CmnDetailLogVo cdlv = new CmnDetailLogVo();
		cdlv.setLogJnlNo(logJnlNo);
		cdlv.setDetailLogSeq("1");
		cdlv.setAppsysCode(checkJobInfo.getAppsys_code());
		cdlv.setStepName(checkJobInfo.getJob_name());
		cdlv.setJobName("--");
		cdlv.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cdlv.setExecStatus(logState);
		cdlv.setExecDate(execdate);
		cdlv.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cdlv.setExecCompletedTime(timestamp);
		cdlv.setExecCreatedTime(timestamp);
		cdlv.setExecUpdatedTime(timestamp);
		cmnDetailLogService.save(cdlv);
		//修改日志记录表
		Timestamp endTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(endTime);
		cmnLog.setExecUpdatedTime(endTime);
		cmnLogService.update(cmnLog);
		return bsaFlag ;
	}

	/**
	 * 根据作业编号删除关联的组件信息	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	public int deleteAllServers(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from CheckJobServerVo e where e.job_code=? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.executeUpdate();
	}
	
	/**
	 * 根据作业编号删除BSA作业信息
	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	public int deleteAllTemplates(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from CheckJobTemplateVo e where e.job_code=? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.executeUpdate();
	}
	
	/**
	 * 根据作业编号删除时间表信息	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	public int deleteTimer(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from CheckJobTimerVo e where e.job_code=? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.executeUpdate();
	}
	
	/**
	 * 根据作业编号获取组件IP信息
	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getServersByJobCode(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
		hql.append("e.appsys_code as appsys_code,");
 		hql.append("e.job_code as job_code,");
 		hql.append("e.server_path as server_path,");
 		hql.append("e.server_name as server_name");
		hql.append(") from CheckJobServerVo e where e.job_code =? order by e.server_name");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.list();
	}
	
	/**
	 * 根据作业编号获取模板信息
	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getTemplatesByJobCode(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
		hql.append("e.appsys_code as appsys_code,");
 		hql.append("e.job_code as job_code,");
 		hql.append("e.template_group as template_group,");
 		hql.append("e.template_name as template_name");
		hql.append(") from CheckJobTemplateVo e where e.job_code =? order by e.template_name");
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.list();
	}
	
	/**
	 * 根据作业编号获取模板信息
	 * @param jobid 作业编号
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public Map<String, Object> getJobCodeByNameAndPath(String jobName ,String jobPath) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct job.job_code as \"job_code\",")
		   .append(" job.job_name as \"job_name\",")
		   .append(" job.job_path as \"job_path\"")
		   .append(" from check_job_info job ")
		   .append(" where job.job_name=:jobName ") 
		   .append(" and job.job_path=:jobPath ")
		   .append(" and job.delete_flag=0 ");
		Query query = getSession().createSQLQuery(sql.toString())
		          .setString("jobName", jobName)
				  .setString("jobPath", jobPath)
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	/**
	 * 根据编号删除作业,删除标识置1
	 * @param job_name 
	 * @param jobid 作业编号
	 */
	public void deleteJobById(Integer jobId,String job_name,String dateStr) {
		getSession().createQuery("update CheckJobInfoVo e set e.delete_flag=1 , e.job_name='"+job_name.concat(dateStr)+"' where e.job_code=?").setString(0, jobId.toString()).executeUpdate();
	}
	
	/**
	 * 根据编号批量删除,删除标识置1
	 * @param jobIds 作业编号数组
	 * @throws Exception 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void deleteJobByIds(Integer[] jobIds) throws Exception {
		String dateStr = "";
		//临时作业路径
		String tempJobPath = "/SYSMANAGE/CHECKMANAGE";
		//临时作业名称
		String tempJobName = "tempComplianceJob";
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		for(int i=0;i<jobIds.length;i++) {
			String execdate = new SimpleDateFormat("yyyyMMdd").format(date) ;
			String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
			int jobId = jobIds[i];
			CheckJobInfoVo cjjiv = (CheckJobInfoVo) getJobById(jobId);
			//作业基本信息
			CheckJobInfoVo job = (CheckJobInfoVo) getJobById(jobId);
			String job_name = job.getJob_name();
			String job_path = job.getJob_path();
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			/*//清除作业时间表 - 不执行BSA作业删除，而只是修改作业名称时，需要清除作业时间表
			CLITunnelServiceClient cliClientCreatExportJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseCreatExportJob= cliClientCreatExportJob.executeCommandByParamList("ComplianceJob", "getDBKeyByGroupAndName", new String[]{job_path,job_name});
			cliClientCreatExportJob.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob);
			String jobDBkey=(String) cliResponseCreatExportJob.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientExportLink = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			cliClientExportLink.executeCommandByParamList("Job", "removeAllSchedules", new String[]{jobDBkey});*/
			
	        //删除BSA系统巡检作业
			date = new Date();
			dateStr = matter.format(date);
			tempJobName=tempJobName.concat("_").concat(dateStr);
			
			CLITunnelServiceClient cliClientCreatExportJob2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseCreatExportJob2= cliClientCreatExportJob2.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{tempJobPath,tempJobName,"","/SYSMANAGE/ComplianceJob","ComplianceJobDelete.nsh","3"});
			cliClientCreatExportJob2.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob2);
			String DBkey=(String) cliResponseCreatExportJob2.get_return().getReturnValue();

			CLITunnelServiceClient cliClientExportLinkServer3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseExportLinkServer3 = cliClientExportLinkServer3.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkey,messages.getMessage("bsa.ipAddress")});
			cliClientExportLinkServer3.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer3);
			
			CLITunnelServiceClient cliClientClean4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseClean4 = cliClientClean4.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{tempJobPath,tempJobName});
			cliClientClean4.ResponseCheck4ExecuteCommand(cliResponseClean4);
			
			CLITunnelServiceClient cliClientAdd6 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd6 = cliClientAdd6.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"0",job_path});
			cliClientAdd6.ResponseCheck4ExecuteCommand(cliResponseAdd6);
			
			CLITunnelServiceClient cliClientAdd8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd8 = cliClientAdd8.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"1",job_name});
			cliClientAdd8.ResponseCheck4ExecuteCommand(cliResponseAdd8);
			
			CLITunnelServiceClient cliClientExport7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseExport7 = cliClientExport7.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey});
			cliClientExport7.ResponseCheck4ExecuteCommand(cliResponseExport7);
			//删除临时脚本作业
			CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{tempJobPath,tempJobName});
			//执行删除操作
			deleteJobById(jobId,job_name,dateStr); 
			//日志处理
			CmnLogVo cmnLog = new CmnLogVo(); 
			cmnLog.setAppsysCode(cjjiv.getAppsys_code());
			cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
			cmnLog.setRequestName(cjjiv.getJob_name()+"_delete");
			cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
			cmnLog.setExecStatus(logState);
			cmnLog.setExecDate(execdate);
			cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
			Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cmnLog.setExecCompletedTime(ts);
			cmnLog.setExecCreatedTime(ts);
			cmnLog.setExecUpdatedTime(ts);
			cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
			cmnLogService.save(cmnLog);
		}
	}
	
	/**
	 * 调用nshell脚本修改作业名称
	 * @param job_name
	 * @param job_path
	 * @throws Exception
	 */
	public void changeJobName(String job_name,String job_path) throws Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		String tempJobPath = "/SYSMANAGE/CHECKMANAGE";
		//临时作业名称
		String dateStr = new SimpleDateFormat("yyyyMMddhhmmss").format(new Date());
		String tempJobName = "tempComplianceJob";
		tempJobName=tempJobName.concat("_").concat(dateStr);
		//创建临时脚本作业
		CLITunnelServiceClient cliClientCreatExportJob2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseCreatExportJob2= cliClientCreatExportJob2.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{tempJobPath,tempJobName,"","/SYSMANAGE/ComplianceJob","ComplianceJobSetName.nsh","3"});
		cliClientCreatExportJob2.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob2);
		String DBkey=(String) cliResponseCreatExportJob2.get_return().getReturnValue();

		CLITunnelServiceClient cliClientExportLinkServer3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExportLinkServer3 = cliClientExportLinkServer3.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkey,messages.getMessage("bsa.ipAddress")});
		cliClientExportLinkServer3.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer3);
		
		CLITunnelServiceClient cliClientClean4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseClean4 = cliClientClean4.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{tempJobPath,tempJobName});
		cliClientClean4.ResponseCheck4ExecuteCommand(cliResponseClean4);
		//设置参数
		CLITunnelServiceClient cliClientAdd6 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd6 = cliClientAdd6.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"0",job_path});
		cliClientAdd6.ResponseCheck4ExecuteCommand(cliResponseAdd6);
		
		CLITunnelServiceClient cliClientAdd8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd8 = cliClientAdd8.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"1",job_name});
		cliClientAdd8.ResponseCheck4ExecuteCommand(cliResponseAdd8);
		
		CLITunnelServiceClient cliClientAdd7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd7 = cliClientAdd7.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"2",job_name.concat(dateStr)});
		cliClientAdd7.ResponseCheck4ExecuteCommand(cliResponseAdd7);
		
		CLITunnelServiceClient cliClientExport7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExport7 = cliClientExport7.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey});
		cliClientExport7.ResponseCheck4ExecuteCommand(cliResponseExport7);
		//删除作业
		CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{tempJobPath,tempJobName});
	
		Map<String, Object> map = getJobCodeByNameAndPath(job_name,job_path);
		if(map!=null && !map.isEmpty() && map.size()>0){
			int jobCode = Integer.valueOf(map.get("job_code").toString());
			deleteJobById(jobCode,job_name,dateStr); 
		}
		
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
	
	/**
	 * 根据系统编号获取服务器分组信息	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServerGroupByAppCode(String appsysCode) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct appsys_code as \"appsysCode\",server_group as \"serverGroup\" from ( ")
		   .append(" select t.appsys_code,")
		   .append(" t.server_group")
		   .append(" from cmn_app_group t left join CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code)")
		   .append(" where t.appsys_code =:appsysCode");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("appsysCode", appsysCode);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取服务器分组信息	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryTree(String appsysCode) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct appsys_code as \"appsysCode\",server_group as \"serverGroup\" from ( ")
		.append(" select t.appsys_code , ")
		.append(" t.server_group ")
		.append(" from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code) " ) 
		.append(" where appsys_code =:appsysCode ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("appsysCode", appsysCode);
		return query.list();
	}

	/**
	 * 根据应用系统编号和服务器分组获取服务器信息	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryChildren(String appsysCode, String serverGroup) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct o.appsys_code as \"appsysCode\",")
		   .append("o.server_group as \"serverGroup\",")
		   .append("o.SERVER_IP as \"serverIp\" from ( ")
		   .append(" select t.appsys_code , s.SERVER_IP,t.server_group")
		   .append(" from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code ")
		   .append(" and t.appsys_code =:appsysCode and t.server_group =:serverGroup ) o,cmn_servers_info f ")
		   .append(" where o.SERVER_IP = f.SERVER_IP and f.delete_flag = '0' and BSA_AGENT_FLAG='1'");
		Query query = getSession().createSQLQuery(sql.toString())
				                  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				                  .setString("appsysCode", appsysCode)
				                  .setString("serverGroup", serverGroup);
		return query.list();
	}
	
	/**
	 * 根据应用系统编号和专业领域分类创建BSA上的作业目录,并授权
	 */
	public void addJobPath(String appsysCode , String fieldType) throws AxisFault,Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = null;
		ExecuteCommandByParamListResponse cliResponse = null ;
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		String job_path1 = "";
		String job_path2 = "";
		String job_path3 = "";
		//目录权限
		String jobAclPolicyAll = "PLCY_ALL_ROOT"; 
		String jobAclPolicy1 = ""; 
		String jobAclPolicy2 = ""; 
		if(appsysCode!=null && appsysCode.equals("COMMON")){ //通用工具系统
			jobAclPolicy1 = "PLCY_" + appsysCode + "_SYSADMIN";
			//判断COMMON目录是否存在
			job_path1 = "/COMMON_CHECK";
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "groupExists", new String[]{job_path1});
			if(cliResponse.get_return().getSuccess()){
				String flag = (String)cliResponse.get_return().getReturnValue();
				if(!Boolean.valueOf(flag)){ //目录不存在
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "createGroupWithParentName", new String[]{"COMMON_CHECK","/"});
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path1,jobAclPolicyAll});
				}
			}
			//判断COMMON下的分类目录是否存在
			job_path2 = job_path1 + "/" + fieldType;
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "groupExists", new String[]{job_path2});
			if(cliResponse.get_return().getSuccess()){
				String flag = (String)cliResponse.get_return().getReturnValue();
				if(!Boolean.valueOf(flag)){ //目录不存在
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "createGroupWithParentName", new String[]{fieldType,job_path1});
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path2,jobAclPolicy1});
				}
			}
		}else{
			jobAclPolicy1 = "PLCY_" + appsysCode + "_APPADMIN";
			jobAclPolicy2 = "PLCY_" + appsysCode + "_SYSADMIN";
			//判断CHECK目录是否存在
			job_path1 = "/CHECK";
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "groupExists", new String[]{job_path1});
			if(cliResponse.get_return().getSuccess()){
				String flag = (String)cliResponse.get_return().getReturnValue();
				if(!Boolean.valueOf(flag)){ //目录不存在
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "createGroupWithParentName", new String[]{"CHECK","/"});
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path1,jobAclPolicyAll});
				}
			}
			//判断CHECK下应用系统目录是否存在
			job_path2 =job_path1 + "/" + appsysCode;
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "groupExists", new String[]{job_path2});
			if(cliResponse.get_return().getSuccess()){
				String flag = (String)cliResponse.get_return().getReturnValue();
				if(!Boolean.valueOf(flag)){ //目录不存在
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "createGroupWithParentName", new String[]{appsysCode,job_path1});
					cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path2,jobAclPolicy1});
					cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path2,jobAclPolicy2});
				}
			}
			//判断应用系统下的分类目录是否存在
			job_path3 =job_path2 + "/" + fieldType;
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "groupExists", new String[]{job_path3});
			if(cliResponse.get_return().getSuccess()){
				String flag = (String)cliResponse.get_return().getReturnValue();
				if(!Boolean.valueOf(flag)){ //目录不存在
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "createGroupWithParentName", new String[]{fieldType,job_path2});
					if(fieldType.equals("APP")){ //存放应用巡检作业
						cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path3,jobAclPolicy1});
					}else{
						cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{job_path3,jobAclPolicy2});
					}
				}
			}
		}
	}
	

	/**
	 * 获取服务器所有的操作系统分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServerOsTypes() {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct os_type as \"serverGroup\" from cmn_servers_info t ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 根据操作系统获取服务器列表(未删除、已装BSA代理)
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServersByOsType(String osType) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct server_ip as \"serverIp\",os_type as \"serverGroup\" ")
		   .append("from cmn_servers_info t where os_type=:osType and delete_flag=0 and BSA_AGENT_FLAG=1" ) ;
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("osType", osType);
		return query.list();
	}
	
	/**
	 * 获取操作类型为空的所有服务器信息
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServersByNull() {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct server_ip as \"serverIp\",os_type as \"serverGroup\" ")
		   .append("from cmn_servers_info t where os_type is null and delete_flag=0 and BSA_AGENT_FLAG=1" ) ;
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 根据应用系统编号、专业领域分类、作业名称获取巡检作业信息
	 * @param appsysCode 应用系统编号
	 * @param fieldType 专业领域分类
	 * @param jobName 作业名称
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, Object> getJedaJobBySysAndFieldAndName(String appsysCode,String fieldType,String jobName){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct e.appsys_code as \"appsys_code\",")
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
		   .append(" where e.appsys_code =:appsysCode and e.field_type =:fieldType and e.job_name =:jobName and e.job_type=1 ") ;
		Query query = getSession().createSQLQuery(sql.toString())
						          .setString("appsysCode", appsysCode)
								  .setString("fieldType", fieldType)
								  .setString("jobName", jobName)
							  	  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	/**
	 * 构建组件目录树 -- 通用作业
	 * @param dataList 父节点列表
	 * @param jobCode 作业编号
	 * @return
	 */
	public List<JSONObject> buildServerTreeForCommonJob(List<Map<String, Object>> dataList,Integer jobCode,String isView) {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  cjo =  null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;
		String osType = "" ; 
		if(jobCode!=null){
			//获取该作业已绑定的组件IP信息
			List<Map<String,Object>> oldSrvers = getServersByJobCode(jobCode);
			for (Map<String,Object> map : dataList) {
				osType = map.get("serverGroup").toString() ;
				cjsonList = new ArrayList<JSONObject>();
				cjo = new JSONObject();
				cjo.put("text", osType);
				cjo.put("iconCls", "node-module");
				cjo.put("isType", true);
				cjo.put("leaf", false);
				if(isView!=null && isView.equals("1")){
					cjo.put("disabled", true);
				}
				int t =0 ;
				String serverGroupOld = "" ; //组件IP所在分组

				for(Map<String,Object> oldServer : oldSrvers){
					serverGroupOld = (String)oldServer.get("server_path") ;
					if(osType.equals(serverGroupOld.substring(serverGroupOld.lastIndexOf("/")+1))){
						t = t+1 ;
					}
				}
				if(t>0){
					cjo.put("checked", true);
				}else{
					cjo.put("checked", false);
				}
				//获取该操作系统下的所有服务器IP
				List<Map<String,Object>> serverList = getServersByOsType(osType);
				for (Map<String,Object> scMap1 : serverList) {
					if(scMap1.get("serverIp")!=null ){
						cjo1 = new JSONObject();
						cjo1.put("text", scMap1.get("serverIp"));
						cjo1.put("iconCls", "node-leaf");
						cjo1.put("leaf", true);
						if(isView!=null && isView.equals("1")){
							cjo1.put("disabled", true);
						}
						int m =0 ;
						for(Map<String,Object> oldServer : oldSrvers){
							if((scMap1.get("serverIp")).equals(oldServer.get("server_name")) 
									&& osType.equals(oldServer.get("server_path"))){
								m = m+1 ;
							}
						}
						if(m>0){
							cjo1.put("checked", true);
						}else{
							cjo1.put("checked", false);
						}
						cjsonList.add(cjo1);
					}
				}
				cjo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(cjo);
			}
		}else{
			for (Map<String,Object> map : dataList) {
				//该操作系统下的所有服务器IP
				List<Map<String,Object>> serverList = null;
				if(map.get("serverGroup")!=null && !(map.get("serverGroup").toString()).equals("null")
						&& !(map.get("serverGroup").toString()).equals("")){
					osType = map.get("serverGroup").toString() ; //操作系统类型
					serverList = getServersByOsType(osType);
				}else{
					osType = "OTHER";
					serverList = getServersByNull();
				}
				cjsonList = new ArrayList<JSONObject>();
				cjo = new JSONObject();
				cjo.put("text",osType);
				cjo.put("iconCls", "node-module");
				cjo.put("isType", true);
				cjo.put("leaf", false);
				cjo.put("checked", false); 
				for (Map<String,Object> scMap1 : serverList) {
					if(scMap1.get("serverIp")!=null ){
						cjo1 = new JSONObject();
						cjo1.put("text", scMap1.get("serverIp"));
						cjo1.put("iconCls", "node-leaf");
						cjo1.put("leaf", true);
						cjo1.put("checked", false);
						cjsonList.add(cjo1);
					}
				}
				cjo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(cjo);
			}
		}
		return sysJsonList;
	}
	
	/**
	 * 获取专业领域分类(OS/DB/MW)中的所有智能组
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object listServerGroupsByFieldType(String fieldType) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//获取分组下的子分组
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("ServerGroup","listChildGroupsInGroup",new String[] {"/"+BSAServerName+"/"+fieldType});
		String serverGroups = (String) response.get_return().getReturnValue();
		return serverGroups;
	}
	
	/**
	 * 获取分组内的所有服务器
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object listServersByGroupName(String fieldType,String groupName) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//获取分组内的所有服务器
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("Server","listServersInGroup",new String[] {"/"+BSAServerName+"/"+fieldType+"/"+groupName});
		String servers = (String) response.get_return().getReturnValue();
		return servers;
	}
	
	/**
	 * 根据路径获取ID
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupNameToId(String jobPath) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//获取路径id
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("JobGroup","groupNameToId",new String[] {jobPath});
		String groupId = (String) response.get_return().getReturnValue();
		return groupId;
	}
	
	/**
	 * 获取模板的BDkey
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getTemplateDBKeyByGroupAndName(String group,String name) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//获取模板DBKey
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("Template","getDBKeyByGroupAndName",new String[] {group,name});
		String templateDBKey = (String) response.get_return().getReturnValue();
		return templateDBKey;
	}
	
	
	/**
	 * 根据作业路径个作业名称获取作业的DBKey
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getJobDBKeyByGroupAndName(String jobPath,String jobName) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//获取作业DBKey
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("ComplianceJob","getDBKeyByGroupAndName",new String[] {jobPath,jobName});
		String jobDBKey = (String) response.get_return().getReturnValue();
		return jobDBKey;
	}
	
	/**
	 * 创建BSA合规作业
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createComplianceJob(String jobName,String groupId,String templateKey,String serverName) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//创建作业
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("ComplianceJob","createTemplateFilteredComplianceJob",
				new String[] {jobName,groupId,templateKey,serverName});
		String jobDBKey = (String) response.get_return().getReturnValue();
		return jobDBKey;
	}
	
	/**
	 * 新建作业时间表 - oneTime
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addOneTimeScheduleWithPriority(String jobDBKey,String timer,String priority) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//新增时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","addOneTimeScheduleWithPriority",new String[] {jobDBKey,timer,priority});
	}
	
	/**
	 * 新建作业时间表 - daily
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addDailyScheduleWithPriority(String jobDBKey,String timer,String priority) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//新增时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","addDailyScheduleWithPriority",new String[] {jobDBKey,timer,priority});
	}
	
	/**
	 * 新建作业时间表 - weekly
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addWeeklyScheduleWithPriority(String jobDBKey,String dateTime,String weekFreq,String daysOfWeek,String priority) 
			throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//新增时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","addWeeklyScheduleWithPriority",
				new String[] {jobDBKey,dateTime,weekFreq,daysOfWeek,priority});
	}
	
	/**
	 * 新建作业时间表 - monthly
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addMonthlyScheduleWithPriority(String jobDBKey,String dateTime,String daysOfMonth,String priority) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//新增时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","addMonthlyScheduleWithPriority",
				new String[] {jobDBKey,dateTime,daysOfMonth,priority});
	}
	
	/**
	 * 新建作业时间表 - interval
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void addIntervalSchedule(String jobDBKey,String dateTime,String days,String hours,String mins) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//新增时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","addIntervalSchedule",new String[] {jobDBKey,dateTime,days,hours,mins});
	}
	
	/**
	 * 作业授权
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void applyAclPolicyForJob(String jobDBKey,String jobAclPolicyApp) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//作业授权
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","applyAclPolicy",new String[] {jobDBKey,jobAclPolicyApp});
	}
	
	/**
	 * 清空作业时间表
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void removeAllSchedules(String jobDBKey) throws AxisFault,SQLException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//清空时间表
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		client.executeCommandByParamList("Job","removeAllSchedules",new String[] {jobDBKey});
	}
	
	/**
	 * 处理常规巡检作业时间表
	 * @throws Exception 
	 * @throws SQLException 
	 * @throws AxisFault 
	 */
	public List<CheckJobTimerVo> handleJobTimers(CheckJobInfoVo checkJobInfo,CheckJobTimerVo checkJobTimer,String timersOnce,
			String timersDaily,String timersWeekly,String timersMonthly,String timersInterval) throws AxisFault, SQLException, Exception{
		//作业时间表列表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		String priority = "NORMAL" ;
		if(checkJobTimer.getExec_priority()!=null){
			priority = checkJobTimer.getExec_priority();
		}
		String jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		removeAllSchedules(jobDBKey); //清空所有时间表
		jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		if(timersOnce!=null && !timersOnce.equals("")){
			String[] timers = timersOnce.split(",");
			String date = "" ;
			String time = "" ;
			for(String timer : timers){
				date = timer.substring(0, 10);
				time = timer.substring(11);
				CheckJobTimerVo cjtv = new CheckJobTimerVo();
				cjtv.setAppsys_code(checkJobInfo.getAppsys_code());
				cjtv.setJob_code(checkJobInfo.getJob_code());
				cjtv.setExec_freq_type("1");
				cjtv.setExec_start_date(date);
				cjtv.setExec_start_time(time);
				cjtv.setWeek1_flag("0");
				cjtv.setWeek2_flag("0");
				cjtv.setWeek3_flag("0");
				cjtv.setWeek4_flag("0");
				cjtv.setWeek5_flag("0");
				cjtv.setWeek6_flag("0");
				cjtv.setWeek7_flag("0");
				cjtv.setInterval_weeks(null);
				cjtv.setMonth_day(null);
				cjtv.setInterval_days(null);
				cjtv.setInterval_hours(null);
				cjtv.setInterval_minutes(null);
				cjtv.setExec_priority(priority);
				//邮件
				cjtv.setExec_notice_mail_list(null);
				cjtv.setMail_success_flag("0");
				cjtv.setMail_failure_flag("0");
				cjtv.setMail_cancel_flag("0");
				jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
				addOneTimeScheduleWithPriority(jobDBKey,timer,priority);
				checkJobTimers.add(cjtv);
			}
		}
		if(timersDaily!=null && !timersDaily.equals("")){
			String[] timers = timersDaily.split(",");
			String date = "" ;
			String time = "" ;
			for(String timer : timers){
				date = timer.substring(0, 10);
				time = timer.substring(11);
				CheckJobTimerVo cjtv = new CheckJobTimerVo();
				cjtv.setAppsys_code(checkJobInfo.getAppsys_code());
				cjtv.setJob_code(checkJobInfo.getJob_code());
				cjtv.setExec_freq_type("2");
				cjtv.setExec_start_date(date);
				cjtv.setExec_start_time(time);
				cjtv.setWeek1_flag("0");
				cjtv.setWeek2_flag("0");
				cjtv.setWeek3_flag("0");
				cjtv.setWeek4_flag("0");
				cjtv.setWeek5_flag("0");
				cjtv.setWeek6_flag("0");
				cjtv.setWeek7_flag("0");
				cjtv.setInterval_weeks(null);
				cjtv.setMonth_day(null);
				cjtv.setInterval_days(null);
				cjtv.setInterval_hours(null);
				cjtv.setInterval_minutes(null);
				cjtv.setExec_priority(priority);
				//邮件
				cjtv.setExec_notice_mail_list(null);
				cjtv.setMail_success_flag("0");
				cjtv.setMail_failure_flag("0");
				cjtv.setMail_cancel_flag("0");
				jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
				addDailyScheduleWithPriority(jobDBKey,timer,priority);
				checkJobTimers.add(cjtv);
			}
		}
		if(timersWeekly!=null && !timersWeekly.equals("")){
			String[] timers = timersWeekly.split(",");
			String date = "" ;
			String time = "" ;
			for(String timer : timers){
				String[] params = timer.split("&");
				String dateTime = params[0];
				String daysOfWeek = params[1];
				String weekFreq = params[2];
				date = dateTime.substring(0, 10);
				time = dateTime.substring(11);
				CheckJobTimerVo cjtv = new CheckJobTimerVo();
				cjtv.setAppsys_code(checkJobInfo.getAppsys_code());
				cjtv.setJob_code(checkJobInfo.getJob_code());
				cjtv.setExec_freq_type("3");
				cjtv.setExec_start_date(date);
				cjtv.setExec_start_time(time);
				cjtv.setWeek1_flag("0");
				cjtv.setWeek2_flag("0");
				cjtv.setWeek3_flag("0");
				cjtv.setWeek4_flag("0");
				cjtv.setWeek5_flag("0");
				cjtv.setWeek6_flag("0");
				cjtv.setWeek7_flag("0");
				if(checkJobTimer.getWeek1_flag()!=null && !checkJobTimer.getWeek1_flag().equals("")){
					cjtv.setWeek1_flag("1");
				}
				if(checkJobTimer.getWeek2_flag()!=null && !checkJobTimer.getWeek2_flag().equals("")){
					cjtv.setWeek2_flag("1");
				}
				if(checkJobTimer.getWeek3_flag()!=null && !checkJobTimer.getWeek3_flag().equals("")){
					cjtv.setWeek3_flag("1");
				}
				if(checkJobTimer.getWeek4_flag()!=null && !checkJobTimer.getWeek4_flag().equals("")){
					cjtv.setWeek4_flag("1");
				}
				if(checkJobTimer.getWeek5_flag()!=null && !checkJobTimer.getWeek5_flag().equals("")){
					cjtv.setWeek5_flag("1");
				}
				if(checkJobTimer.getWeek6_flag()!=null && !checkJobTimer.getWeek6_flag().equals("")){
					cjtv.setWeek6_flag("1");
				}
				if(checkJobTimer.getWeek7_flag()!=null && !checkJobTimer.getWeek7_flag().equals("")){
					cjtv.setWeek7_flag("1");
				}
				cjtv.setInterval_weeks(Integer.valueOf(daysOfWeek));
				cjtv.setMonth_day(null);
				cjtv.setInterval_days(null);
				cjtv.setInterval_hours(null);
				cjtv.setInterval_minutes(null);
				cjtv.setExec_priority(priority);
				//邮件
				cjtv.setExec_notice_mail_list(null);
				cjtv.setMail_success_flag("0");
				cjtv.setMail_failure_flag("0");
				cjtv.setMail_cancel_flag("0");
				jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
				addWeeklyScheduleWithPriority(jobDBKey,dateTime,weekFreq,daysOfWeek,priority);
				checkJobTimers.add(cjtv);
			}
		}
		if(timersMonthly!=null && !timersMonthly.equals("")){
			String[] timers = timersMonthly.split(",");
			String date = "" ;
			String time = "" ;
			for(String timer : timers){
				String[] params = timer.split("&");
				String dateTime = params[0];
				String daysOfMonth = params[1];
				date = dateTime.substring(0, 10);
				time = dateTime.substring(11);
				CheckJobTimerVo cjtv = new CheckJobTimerVo();
				cjtv.setAppsys_code(checkJobInfo.getAppsys_code());
				cjtv.setJob_code(checkJobInfo.getJob_code());
				cjtv.setExec_freq_type("4");
				cjtv.setExec_start_date(date);
				cjtv.setExec_start_time(time);
				cjtv.setWeek1_flag("0");
				cjtv.setWeek2_flag("0");
				cjtv.setWeek3_flag("0");
				cjtv.setWeek4_flag("0");
				cjtv.setWeek5_flag("0");
				cjtv.setWeek6_flag("0");
				cjtv.setWeek7_flag("0");
				cjtv.setInterval_weeks(null);
				cjtv.setMonth_day(Integer.valueOf(daysOfMonth));
				cjtv.setInterval_days(null);
				cjtv.setInterval_hours(null);
				cjtv.setInterval_minutes(null);
				cjtv.setExec_priority(priority);
				//邮件
				cjtv.setExec_notice_mail_list(null);
				cjtv.setMail_success_flag("0");
				cjtv.setMail_failure_flag("0");
				cjtv.setMail_cancel_flag("0");
				jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
				addMonthlyScheduleWithPriority(jobDBKey,dateTime,daysOfMonth,priority);
				checkJobTimers.add(cjtv);
			}
		}
		if(timersInterval!=null && !timersInterval.equals("")){
			String[] timers = timersInterval.split(",");
			String date = "" ;
			String time = "" ;
			for(String timer : timers){
				String[] params = timer.split("&");
				String dateTime = params[0];
				String days = params[1];
				String hours = params[2];
				String mins = params[3];
				date = dateTime.substring(0, 10);
				time = dateTime.substring(11);
				CheckJobTimerVo cjtv = new CheckJobTimerVo();
				cjtv.setAppsys_code(checkJobInfo.getAppsys_code());
				cjtv.setJob_code(checkJobInfo.getJob_code());
				cjtv.setExec_freq_type("5");
				cjtv.setExec_start_date(date);
				cjtv.setExec_start_time(time);
				cjtv.setWeek1_flag("0");
				cjtv.setWeek2_flag("0");
				cjtv.setWeek3_flag("0");
				cjtv.setWeek4_flag("0");
				cjtv.setWeek5_flag("0");
				cjtv.setWeek6_flag("0");
				cjtv.setWeek7_flag("0");
				cjtv.setInterval_weeks(null);
				cjtv.setMonth_day(null);
				cjtv.setInterval_days(Integer.valueOf(days));
				cjtv.setInterval_hours(Integer.valueOf(hours));
				cjtv.setInterval_minutes(Integer.valueOf(mins));
				cjtv.setExec_priority(priority);
				//邮件
				cjtv.setExec_notice_mail_list(null);
				cjtv.setMail_success_flag("0");
				cjtv.setMail_failure_flag("0");
				cjtv.setMail_cancel_flag("0");
				jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
				addIntervalSchedule(jobDBKey,dateTime,days,hours,mins);
				checkJobTimers.add(cjtv);
			}
		}
		return checkJobTimers;
	}
	
	/**
	 * 作业关联多个模板 - 新建 
	 * @param checkJobInfo
	 * @param checkJobTemplates
	 * @throws Exception
	 */
	public void addMoreTemplate(CheckJobInfoVo checkJobInfo , List<CheckJobTemplateVo> checkJobTemplates) throws Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		if(checkJobTemplates.size()!=0){
			for(int i=0;i<checkJobTemplates.size();i++){
				CheckJobTemplateVo cjbi2 = checkJobTemplates.get(i);
				String template_grop = cjbi2.getTemplate_group();
				String template_name= cjbi2.getTemplate_name();
				//临时作业路径
				String tempJobPath = "/SYSMANAGE/CHECKMANAGE";
				//临时作业名称
				Date date = new Date();
				SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
				String tempJobName = "tempComplianceJob";
				tempJobName=tempJobName.concat("_").concat(matter.format(date));
				//新建临时脚本作业
				CLITunnelServiceClient cliClientCreatExportJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseCreatExportJob = cliClientCreatExportJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
						new String[]{tempJobPath,tempJobName,"","/SYSMANAGE/ComplianceJob","ComplianceJobAddTemplate.nsh","4"});
				cliClientCreatExportJob.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob);
				String DBkeyCreatExportJob=(String) cliResponseCreatExportJob.get_return().getReturnValue();
				
				CLITunnelServiceClient cliClientExportLinkServer = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseExportLinkServer = cliClientExportLinkServer.executeCommandByParamList("Job", "addTargetServer", 
						new String[]{DBkeyCreatExportJob,messages.getMessage("bsa.ipAddress")});
				cliClientExportLinkServer.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer);
				 
				CLITunnelServiceClient cliClientClean = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseClean = cliClientClean.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
						new String[]{tempJobPath,tempJobName});
				cliClientClean.ResponseCheck4ExecuteCommand(cliResponseClean);
				//设置参数
				CLITunnelServiceClient cliClientAdd2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdd2.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{tempJobPath,tempJobName,"0",checkJobInfo.getJob_path()});
				cliClientAdd2.ResponseCheck4ExecuteCommand(cliResponseAdd2);
				
				CLITunnelServiceClient cliClientAdd3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd3 = cliClientAdd3.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{tempJobPath,tempJobName,"1",checkJobInfo.getJob_name()});
				cliClientAdd3.ResponseCheck4ExecuteCommand(cliResponseAdd3);
				
				CLITunnelServiceClient cliClientAdd4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd4 = cliClientAdd4.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{tempJobPath,tempJobName,"2",template_grop});
				cliClientAdd4.ResponseCheck4ExecuteCommand(cliResponseAdd4);
				
				CLITunnelServiceClient cliClientAdd5 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd5 = cliClientAdd5.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{tempJobPath,tempJobName,"3",template_name});
				cliClientAdd5.ResponseCheck4ExecuteCommand(cliResponseAdd5);
				//执行作业
				CLITunnelServiceClient cliClientExport = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseExport = cliClientExport.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", 
						new String[]{DBkeyCreatExportJob});
				cliClientExport.ResponseCheck4ExecuteCommand(cliResponseExport);
				//删除作业
				CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{tempJobPath,tempJobName});
			}
		}
	}
	
	/**
	 * 作业关联智能组
	 * @param checkJobInfo
	 * @param checkJobServers
	 * @throws Exception 
	 * @throws SQLException 
	 * @throws AxisFault 
	 */
	public Object addTargetGroupsForJob(CheckJobInfoVo checkJobInfo,List<CheckJobServerVo> checkJobServers) throws AxisFault, SQLException, Exception{
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		String groups = "" ;
		StringBuffer sb = new StringBuffer();
		String crlf=System.getProperty("line.separator");
		if(checkJobInfo.getServer_target_type().equals("1")){
			for(CheckJobServerVo checkJobServer:checkJobServers){
				groups = groups + "," + checkJobServer.getServer_path()+"/"+checkJobServer.getServer_name();
			}
			if(!groups.equals("")){
				groups = groups.substring(1);
			}
		}
		if(checkJobInfo.getServer_target_type().equals("0")){
			for(CheckJobServerVo checkJobServer:checkJobServers){
				String servers=checkJobServer.getServer_name();
				sb.append(servers).append(",");
			}
		}
		
		//作业关联智能组
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		String jobDBKey = (String)getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		ExecuteCommandByParamListResponse resp = client.executeCommandByParamList("Job","clearTargetGroups",new String[] {jobDBKey});
		jobDBKey = (String) resp.get_return().getReturnValue();
		ExecuteCommandByParamListResponse response1 = client.executeCommandByParamList("Job","clearTargetServers",new String[] {jobDBKey});
		jobDBKey = (String) response1.get_return().getReturnValue();
		String DBKey = "";
		if(checkJobInfo.getServer_target_type().equals("1")){
			ExecuteCommandByParamListResponse response = client.executeCommandByParamList("Job","addTargetGroups",new String[] {jobDBKey,groups});
			DBKey = (String) response.get_return().getReturnValue();
		}
		if(checkJobInfo.getServer_target_type().equals("0")){
			ExecuteCommandByParamListResponse response = client.executeCommandByParamList("Job","addTargetServers",new String[] {jobDBKey,sb.substring(0,sb.lastIndexOf(",")).toString()});
			DBKey = (String) response.get_return().getReturnValue();
		}
		return DBKey;
	}

	/**
	 * 作业关联多个模板 - 修改
	 * @param checkJobInfo
	 * @param checkJobTemplates
	 * @throws Exception
	 */
	public void addMoreTemplateForUpdate(CheckJobInfoVo checkJobInfo , List<CheckJobTemplateVo> checkJobTemplates) throws Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		//清除模板信息
		String tempTemplateName = "ComplianceJobClearTemplate"+"_"+matter.format(new Date()) ;
		CLITunnelServiceClient cliClientCreatExportJob2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseCreatExportJob2= cliClientCreatExportJob2.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{"/SYSMANAGE/CHECKMANAGE",tempTemplateName,"","/SYSMANAGE/ComplianceJob","ComplianceJobClearTemplate.nsh","2"});
		cliClientCreatExportJob2.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob2);
		String DBkeyCreatExportJob=(String) cliResponseCreatExportJob2.get_return().getReturnValue();

		CLITunnelServiceClient cliClientExportLinkServer3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExportLinkServer3 = cliClientExportLinkServer3.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkeyCreatExportJob,messages.getMessage("bsa.ipAddress")});
		cliClientExportLinkServer3.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer3);
		
		CLITunnelServiceClient cliClientClean4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseClean4 = cliClientClean4.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempTemplateName});
		cliClientClean4.ResponseCheck4ExecuteCommand(cliResponseClean4);
		cliResponseClean4.get_return().getReturnValue();
		
		CLITunnelServiceClient cliClientAdd6 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd6 = cliClientAdd6.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempTemplateName,"0",checkJobInfo.getJob_path()});
		cliClientAdd6.ResponseCheck4ExecuteCommand(cliResponseAdd6);
		cliResponseAdd6.get_return().getReturnValue();
		
		CLITunnelServiceClient cliClientAdd8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd8 = cliClientAdd8.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempTemplateName,"1",checkJobInfo.getJob_name()});
		cliClientAdd8.ResponseCheck4ExecuteCommand(cliResponseAdd8);
		cliResponseAdd8.get_return().getReturnValue();
		
		CLITunnelServiceClient cliClientExport7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExport7 = cliClientExport7.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkeyCreatExportJob});
		cliClientExport7.ResponseCheck4ExecuteCommand(cliResponseExport7);
		cliResponseExport7.get_return().getReturnValue();
		
		CLITunnelServiceClient cliClientExportJobDelete1 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliClientExportJobDelete1.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempTemplateName});
		
		//添加模板信息
		String tempJobName = "ComplianceJobAddTemplate"+"_"+matter.format(new Date()) ;
		CLITunnelServiceClient cliClientCreatExportJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseCreatExportJob = cliClientCreatExportJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName,"","/SYSMANAGE/ComplianceJob","ComplianceJobAddTemplate.nsh","4"});
		cliClientCreatExportJob.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob);
		String DBkeyCreatExportJob2=(String) cliResponseCreatExportJob.get_return().getReturnValue();

		CLITunnelServiceClient cliClientExportLinkServer = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExportLinkServer = cliClientExportLinkServer.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkeyCreatExportJob2,messages.getMessage("bsa.ipAddress")});
		cliClientExportLinkServer.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer);
		if(checkJobTemplates.size()!=0){
			for(int i=0;i<checkJobTemplates.size();i++){
				CheckJobTemplateVo cjbi2 = checkJobTemplates.get(i);
				String template_grop = cjbi2.getTemplate_group();
				String template_name= cjbi2.getTemplate_name();
				
				CLITunnelServiceClient cliClientClean = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseClean = cliClientClean.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName});
				cliClientClean.ResponseCheck4ExecuteCommand(cliResponseClean);
				
				CLITunnelServiceClient cliClientAdd2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdd2.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName,"0",checkJobInfo.getJob_path()});
				cliClientAdd2.ResponseCheck4ExecuteCommand(cliResponseAdd2);
				
				CLITunnelServiceClient cliClientAdd3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd3 = cliClientAdd3.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName,"1",checkJobInfo.getJob_name()});
				cliClientAdd3.ResponseCheck4ExecuteCommand(cliResponseAdd3);
				
				CLITunnelServiceClient cliClientAdd4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd4 = cliClientAdd4.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName,"2",template_grop});
				cliClientAdd4.ResponseCheck4ExecuteCommand(cliResponseAdd4);
				
				CLITunnelServiceClient cliClientAdd5 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseAdd5 = cliClientAdd5.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName,"3",template_name});
				cliClientAdd5.ResponseCheck4ExecuteCommand(cliResponseAdd5);
				
				CLITunnelServiceClient cliClientExport = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseExport = cliClientExport.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkeyCreatExportJob2});
				cliClientExport.ResponseCheck4ExecuteCommand(cliResponseExport);
			}
		}	
		CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{"/SYSMANAGE/CHECKMANAGE",tempJobName});
	}

	public Object getServer(String osType,String serverIp, String sort, String dir) {
		String[] osTypes= osType.replace("[", "").replace("]","").replace("\"", "").replace("\"","").split(",");
		List<String> osTypeList = new ArrayList<String>();
		for(int i=0;i<osTypes.length;i++){
			osTypeList.add(osTypes[i].substring(osTypes[i].indexOf("_")+1,osTypes[i].indexOf("_", osTypes[i].indexOf("_")+1)));
		}
		
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
		sql.append(" and o.osType in :osTypeList");
		sql.append(" and o.serverIp like  '" + serverIp + "%'");
		sql.append(" order by o." + sort + " " + dir);
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		;
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		query.setParameterList("osTypeList",osTypeList);
		return query.list();
	}

	public Object getCheckedServer(Integer jobid) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.appsys_code as appsysCode,");
 		hql.append("e.server_path as osType,");
 		hql.append("e.server_name as serverIp");
		hql.append(") from CheckJobServerVo e where e.job_code=?");
		hql.append(" order by e.server_name");
		logger.info(hql.toString());
		//Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString()).setFirstResult(start).setMaxResults(limit);
		Query query = getSession().createQuery(hql.toString()).setString(0, jobid.toString());
		return query.list();
	}
	

}




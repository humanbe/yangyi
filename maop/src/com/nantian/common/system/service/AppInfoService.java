package com.nantian.common.system.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.vo.AppConfVo;
import com.nantian.common.system.vo.AppInfoItsmVo;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.dply.service.ApplicationProcessService;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.ApplicationProcessRecordsVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.config.service.ItemService;
import com.nantian.jeda.security.util.SecurityUtils;

@Service
@Repository
@Transactional
public class AppInfoService {
	private static final String String = null;
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppInfoService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SecurityUtils securityUtils;
	
	@Autowired
	private SessionFactory sessionFactory;
	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;

	/** 国际化资源 */
	@Autowired
	private  MessageSourceAccessor messages;
	@Autowired
	private  ItemService itemService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	//[系统环境]数据字典主项名称
	public static String systemEnvs= "SYSTEM_ENVIRONMENT";
	
	//环境值与环境名称映射关系
	/*public static Map<String,String> envMap = new HashMap<String,String>();
	static{
		envMap.put("1", "DEV");
		envMap.put("2", "QA");
		envMap.put("3", "PROV");
		envMap.put("4", "PROD");
	}*/
	
	public AppInfoService(){
		fields.put("appsysCode", FieldType.STRING);
		fields.put("appsysName", FieldType.STRING);
		fields.put("sysA", FieldType.STRING);
		fields.put("sysB", FieldType.STRING);
		fields.put("appA", FieldType.STRING);
		fields.put("appB", FieldType.STRING);
		fields.put("projectLeader", FieldType.STRING);
		fields.put("sysStatus", FieldType.STRING);
		fields.put("department", FieldType.STRING);
		fields.put("serviceTime", FieldType.STRING);
		fields.put("disasterRecoverPriority", FieldType.STRING);
		fields.put("securityRank", FieldType.STRING);
		fields.put("operationsManager", FieldType.STRING);
		fields.put("appOutline", FieldType.STRING);
		fields.put("appType", FieldType.STRING);
		fields.put("hexinJibie", FieldType.STRING);
		fields.put("zhongyaoJibie", FieldType.STRING);
		fields.put("guanjianJibie", FieldType.STRING);
		fields.put("groupName", FieldType.STRING);
		fields.put("aopFlag", FieldType.STRING);
		fields.put("lastScanTime", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
		
		fields.put("systemcode", FieldType.STRING);
		fields.put("systemname", FieldType.STRING);
		fields.put("aopFlag", FieldType.STRING);
		fields.put("isimportant", FieldType.STRING);
		fields.put("iskey", FieldType.STRING);
		fields.put("applicateoperate", FieldType.STRING);
		fields.put("iscoresyetem", FieldType.STRING);
		fields.put("istestcenter", FieldType.STRING);
		fields.put("cbrcimportantsystem", FieldType.STRING);
		fields.put("status", FieldType.STRING);
		fields.put("onlineEnv", FieldType.STRING);
	}
	
	/**
	 * 查询应用系统信息
	 * @param start 起始记录数

	 * @param limit 限制记录数

	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @return 应用系统及管理员分配信息映射集合
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String,String>> queryAppSystemInfo(Integer start, Integer limit,String sort, String dir, 
			Map<String, Object> params,HttpServletRequest request) throws SQLException{
	    //展示列表数据
	    List<Map<String, String>> showList = null;
		StringBuilder hql = new StringBuilder();
		hql.append("select new map( ")
		   .append(" v.systemcode as systemcode,")
		   .append(" v.systemname as systemname,")
		   .append(" v.eapssystemname as eapssystemname,")
		   .append(" v.englishcode as englishcode,")
		   .append(" v.affectsystem as affectsystem,")
		   .append(" v.branch as branch,")
		   .append(" v.key as key,")
		   .append(" v.status as status,")
		   .append(" v.securitylevel as securitylevel,")
		   .append(" v.scope as scope,")
		   .append(" v.systempro as systempro,")
		   .append(" to_char(v.onlinedate,'yyyy-mm-dd hh24:mi:ss') as onlinedate,")
		   .append(" to_char(v.outlinedate,'yyyy-mm-dd hh24:mi:ss') as outlinedate,")
		   .append(" v.serverlevel as serverlevel,")
		   .append(" v.systemlevel as systemlevel,")
		   .append(" v.isimportant as isimportant,")
		   .append(" v.iskey as iskey,")
		   .append(" v.iscoresyetem as iscoresyetem,")
		   .append(" v.cbrcimportantsystem as cbrcimportantsystem,")
		   .append(" v.applicateoperate as applicateoperate,")
		   .append(" v.outsourcingmark as outsourcingmark,")
		   .append(" v.networkdomain as networkdomain,")
		   .append(" v.team as team,")
		   .append(" v.operatemanager as operatemanager,")
		   .append(" v.applicatemanagerA as applicatemanagerA,")
		   .append(" v.applicatemanagerB as applicatemanagerB,")
		   .append(" v.systemmanagerA as systemmanagerA,")
		   .append(" v.systemmanagerB as systemmanagerB,")
		   .append(" v.networkmanagerA as networkmanagerA,")
		   .append(" v.networkmanagerB as networkmanagerB,")
		   .append(" v.DBA as DBA,")
		   .append(" v.middlewaremanager as middlewaremanager,")
		   .append(" v.storemanager as storemanager,")
		   .append(" v.PM as PM,")
		   .append(" v.businessdepartment as businessdepartment,")
		   .append(" v.businessmanager as businessmanager,")
		   .append(" v.servicesupporter as servicesupporter,")
		   .append(" v.istestcenter as istestcenter,")
		   .append(" v.allottestmanager as allottestmanager,")
		   .append(" v.deliverytestmanager as deliverytestmanager,")
		   .append(" v.qualitymanager as qualitymanager,")
		   .append(" v.performancetestmanag as performancetestmanag,")
		   .append(" v.transfercoefficient as transfercoefficient,")
		   .append(" v.stage as stage,")
		   .append(" v.businessintroduction as businessintroduction,")
		   .append(" v.appsysName as appsysName,") //带|的系统名称
		   //配置表信息
		   .append(" v.appsysCode as appsysCode,")
		   .append(" v.aopFlag as aopFlag,")
		   .append(" v.onlineEnv as onlineEnv,")
		   .append(" v.syncType as syncType,")
		   .append(" to_char(v.lastScanTime,'yyyy-mm-dd hh24:mi:ss') as lastScanTime,")
		   .append(" v.deleteFlag as deleteFlag,")
		   .append(" to_char(v.updateTime,'yyyy-mm-dd hh24:mi:ss') as updateTime )")
		   .append(" from ViewAppInfoVo v ")
		   .append(" where v.deleteFlag='0'  ");
			for(String key : params.keySet()){
				if(fields.get(key).equals(FieldType.STRING)){
					hql.append(" and v." + key + " like :" + key);
				}else{
					hql.append(" and v." + key + " = :" + key);
				}
			}
			hql.append(" order by v." + sort + " " + dir);
			Query query = getSession().createQuery(hql.toString());
			if(params.size() > 0){
				query.setProperties(params);
			}
			logger.info(query.getQueryString());
		    //将未分页数据放入session,用于导出
			request.getSession().setAttribute("appInfoList4Export", query.list());
			//分页查询未删除的所有应用系统
			List<Map<String, String>> alllist=query.setMaxResults(limit).setFirstResult(start).list();
			//获取应用系统修改前的记录信息
			StringBuilder hqlupdate = new StringBuilder();
			hqlupdate.append("select new map( " )
					 .append(" v.systemcode as systemcode,")
					 .append(" v.appsysCode as appsysCode,")
					 .append(" to_char(v.updateTime ,'yyyymmdd ') as updateTime,")
					 .append(" v.updateBeforeRecord as updateBeforeRecord ) ")
					 .append(" from ViewAppInfoVo v ")
					 .append(" where to_char(v.updateTime,'yyyymmdd')=to_char(sysdate,'yyyymmdd')")
			         .append(" and v.deleteFlag='0' ");
			Query query2 = getSession().createQuery(hqlupdate.toString());
			List<Map<String, String>> updatelist =query2.list();
			//比较当前日期修改的系统数据信息
			showList = compareOldAndNewList(alllist,updatelist);
			return showList;
	}
	
	/**
	 * 根据编号获取应用系统信息
	 * @param systemCode 系统编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, Object> getAppInfoItsmById(String systemcode) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
		   .append(" v.systemcode as systemcode,")
		   .append(" v.systemname as systemname,")
		   .append(" v.eapssystemname as eapssystemname,")
		   .append(" v.englishcode as englishcode,")
		   .append(" v.affectsystem as affectsystem,")
		   .append(" v.branch as branch,")
		   .append(" v.key as key,")
		   .append(" v.status as status,")
		   .append(" v.securitylevel as securitylevel,")
		   .append(" v.scope as scope,")
		   .append(" v.systempro as systempro,")
		   .append(" to_char(v.onlinedate,'yyyy-mm-dd hh24:mi:ss') as onlinedate,")
		   .append(" to_char(v.outlinedate,'yyyy-mm-dd hh24:mi:ss') as outlinedate,")
		   .append(" v.serverlevel as serverlevel,")
		   .append(" v.systemlevel as systemlevel,")
		   .append(" v.isimportant as isimportant,")
		   .append(" v.iskey as iskey,")
		   .append(" v.iscoresyetem as iscoresyetem,")
		   .append(" v.cbrcimportantsystem as cbrcimportantsystem,")
		   .append(" v.applicateoperate as applicateoperate,")
		   .append(" v.outsourcingmark as outsourcingmark,")
		   .append(" v.networkdomain as networkdomain,")
		   .append(" v.team as team,")
		   .append(" v.operatemanager as operatemanager,")
		   .append(" v.applicatemanagerA as applicatemanagerA,")
		   .append(" v.applicatemanagerB as applicatemanagerB,")
		   .append(" v.systemmanagerA as systemmanagerA,")
		   .append(" v.systemmanagerB as systemmanagerB,")
		   .append(" v.networkmanagerA as networkmanagerA,")
		   .append(" v.networkmanagerB as networkmanagerB,")
		   .append(" v.DBA as DBA,")
		   .append(" v.middlewaremanager as middlewaremanager,")
		   .append(" v.storemanager as storemanager,")
		   .append(" v.PM as PM,")
		   .append(" v.businessdepartment as businessdepartment,")
		   .append(" v.businessmanager as businessmanager,")
		   .append(" v.servicesupporter as servicesupporter,")
		   .append(" v.istestcenter as istestcenter,")
		   .append(" v.allottestmanager as allottestmanager,")
		   .append(" v.deliverytestmanager as deliverytestmanager,")
		   .append(" v.qualitymanager as qualitymanager,")
		   .append(" v.performancetestmanag as performancetestmanag,")
		   .append(" v.transfercoefficient as transfercoefficient,")
		   .append(" v.stage as stage,")
		   .append(" v.businessintroduction as businessintroduction, ")
		   .append(" acv.maopAppsysCode as maopAppsysCode )")
		   .append(" from AppInfoItsmVo v,AppConfVo acv ")
		   .append(" where 1=1 ") 
		   .append(" and v.systemcode = acv.itsmAppsysCode ") 
		   .append(" and v.systemcode =:systemcode ") ;
		Query query = getSession().createQuery(hql.toString())
	          					  .setString("systemcode", systemcode);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	/**
	 * 修改应用系统基本信息
	 * @param appInfoItsm 
	 */
	@Transactional
	public void updateAppInfoItsm(AppInfoItsmVo appInfoItsm) {
		getSession().update(appInfoItsm);
	}
	
	/**
	 * 修改应用系统配置信息
	 * @param appConf 
	 */
	@Transactional
	public void updateAppConf(AppConfVo appConf) {
		getSession().update(appConf);
	}
	
	/**
	 * 删除应用系统信息,配置表删除标识置1
	 * @param systemcodes ITSM系统编号数组
	 * @throws Exception 
	 */
	public void deleteAppByIds(String[] systemcodes) throws Exception {
		for(int t=0 ; t<systemcodes.length ; t++){
			getSession().createQuery("delete from AppConfVo t where t.itsmAppsysCode=?").setString(0, systemcodes[t]).executeUpdate();
		}
	}
	
	/**
	 * 查询所有未删除的应用系统编号及名称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNames(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		  	.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
	}
	
	/**
	 * 查询未删除，已上线的所有应用系统编号及名称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNames4NoDelHasAop(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		  	.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where v.delete_flag != '1' ")
			.append(" and v.aop_flag = '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUser(String userId){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		  	.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId) ")
			.append(" and v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
									.setString("userId", userId)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表_应用发布权限列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUserForDply(String userId){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
	  		.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.dply_flag = '1') ")
			.append(" and v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
									.setString("userId", userId)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表_巡检权限列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUserForCheck(String userId){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
  			.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.check_flag = '1') ")
			.append(" and v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
									.setString("userId", userId)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表_工具箱权限列表

	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUserForTool(String userId){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
  			.append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.tool_flag = '1') ")
			.append(" and v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
									.setString("userId", userId)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询所有系统状态

	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemStatus(){
		return getSession().createQuery("select distinct new map(v.status as statusValue,v.status as statusName) from ViewAppInfoVo v order by v.status").list();
	}
	
	/**
	 * 上线设定
	 * @param appsyscd 
	 * @return
	 * @throws Exception 
	 */
	@SuppressWarnings("unused")
	@Transactional
	public void setAopflag(String appsyscd,String onlineEnvs) throws Exception{

		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		int appindex ;// “>”的位置
		int sysindex ;// “<”的位置
		String[] envs = onlineEnvs.split(",");
		//上线环境入库字段，环境间英文逗号分割
		String onlineEnvsStr = "" ;
		for(int t=0 ; t<envs.length ; t++){
			if(t == envs.length-1){
				onlineEnvsStr = onlineEnvsStr + envs[t] ;
			}else{
				onlineEnvsStr = onlineEnvsStr + envs[t] + "," ;
			}
		}
		//将环境1、2、3、4转换为DEV、QA、PROV、PROD
		/*for(int t=0 ; t<envs.length ; t++){
			for(String key : envMap.keySet()){
				if(envs[t].equals(key)){
					envs[t] = envMap.get(key);
				}
			}
		}*/
		
		if(appsyscd.indexOf(",")!=-1){
			String[] app = appsyscd.split(",");
			for(int i=0;i<app.length;i++){
				String syscode=app[i];
				if(app[i].contains("</span>")){
					 appindex = app[i].indexOf(">");
					 sysindex=app[i].lastIndexOf("<");
					syscode = app[i].substring(appindex+1, sysindex);
				}
				//用户登录
				loginClient = new LoginServiceClient(messages.getMessage("bsa.userNameRbac"), 
									messages.getMessage("bsa.userPassword"),
									messages.getMessage("bsa.authenticationType"), null,
									System.getProperty("maop.root")+File.separator + 	messages.getMessage("bsa.truststoreFile"),
									messages.getMessage("bsa.truststoreFilePassword"));
				res4Login = loginClient.loginUsingUserCredential();
				//设置用户角色
				aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(),null);
				aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac"));
				if(syscode.equals("COMMON")){
					//创建该系统角色COMMONSYSADMIN
                	CLITunnelServiceClient cliClientSYS = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                	ExecuteCommandByParamListResponse cliResponseSYS = cliClientSYS.executeCommandByParamList("RBACRole", "createRole", new String[]{""+syscode+"_SYSADMIN"," ","1"," "," "});
                	//给COMMONSYSADMIN角色授权
                	CLITunnelServiceClient cliClientsysAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                	ExecuteCommandByParamListResponse cliResponsesysAuth = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+syscode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
                	//分环境创建系统角色,并授权
                	/*for(String env : envs){
                    	//创建角色
                		CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                    	ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{syscode+"_"+env+"_SYSADMIN"," ","1"," "," "});
                    	//角色授权
                    	CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                    	ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuthEnv.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{syscode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
                	}*/
                	
            	  	//查询COMMONACL，模板是否存在   应该建TMPLT_"+syscode+"_SYSADMIN
					CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+syscode+"_SYSADMIN"});
					String commonACL = (String) cliResponse1.get_return().getReturnValue();
					
					if(!commonACL.equals("true")){
						//创建该系统的COMMONAPP策略模板
						CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClientappAclTMP.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+syscode+"_SYSADMIN"," "});
					}
					//给APP策略模板授权
					CLITunnelServiceClient cliClientappAclTMPPerAll = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPerAll.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
					
					CLITunnelServiceClient cliClientappAclTMPPer = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPer.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_SYSADMIN",""+syscode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
					
					//根据名字判断策略是否存在COMMON
					CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMP=cliClientappAclTMP.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+syscode+"_SYSADMIN"});
					String commonAclTMP=(String) cliResponseappAclTMP.get_return().getReturnValue();
					if(!commonAclTMP.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient2.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+syscode+"_SYSADMIN"});	
					}
					//给策略添加模板
					CLITunnelServiceClient cliClient3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient3.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN","TMPLT_"+syscode+"_SYSADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient4.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient5 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient5.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN",""+syscode+"_SYSADMIN","ACLPolicy.Read"});
					
					//分环境增加策略，并给策略增加模板及授权
					/*for(String env : envs){
						//查询COMMONACL，模板是否存在   应该建TMPLT_"+syscode+"_SYSADMIN
						CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN"});
						String common = (String) cliResponse.get_return().getReturnValue();
						if(!common.equals("true")){
							//创建该系统的COMMONAPP策略模板
							cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN"," "});
						}
						//给APP策略模板授权
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN","BLAdmins","AUTH_ADMINALL"});
						
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN",syscode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
						
						//增加策略
						CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN"});
						String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
						if(!commonAclTMPEnv.equals("true")){
							//创建策略
							CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN"});	
						}
						//给策略添加模板
						CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN","TMPLT_"+env+"_"+syscode+"_APPADMIN","false"});	
						//给ACL付权限
						CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
						
						CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN",syscode+"_"+env+"_SYSADMIN","ACLPolicy.Read"});
					}*/
				}else{
					//创建该系统角色COMMONSYSADMIN
            	    CLITunnelServiceClient cliClientSYS = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                	ExecuteCommandByParamListResponse cliResponseSYS = cliClientSYS.executeCommandByParamList("RBACRole", "createRole", new String[]{""+syscode+"_SYSADMIN"," ","1"," "," "});
                	//给COMMONSYSADMIN角色授权
                	CLITunnelServiceClient cliClientsysAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                	ExecuteCommandByParamListResponse cliResponsesysAuth = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+syscode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
                	//分环境创建系统角色,并授权
                	/*for(String env : envs){
                		//创建角色
                		CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                		ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{syscode+"_"+env+"_SYSADMIN"," ","1"," "," "});
                		//角色授权
                		CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
                		ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuthEnv.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{syscode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
                	}*/
                	
                	//查询COMMONACL，模板是否存在   应该建TMPLT_"+syscode+"_SYSADMIN
					CLITunnelServiceClient cliClient11 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse11 = cliClient11.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+syscode+"_SYSADMIN"});
					String commonACL = (String) cliResponse11.get_return().getReturnValue();
					if(!commonACL.equals("true")){
						//创建该系统的COMMONAPP策略模板
						CLITunnelServiceClient cliClientappAclTMP1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClientappAclTMP1.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+syscode+"_SYSADMIN"," "});
					}
						
					//给APP策略模板授权
					CLITunnelServiceClient cliClientappAclTMPPerAll1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPerAll1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
					
					CLITunnelServiceClient cliClientappAclTMPPer1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPer1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_SYSADMIN",""+syscode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
					
					//根据名字判断策略是否存在COMMON
					CLITunnelServiceClient cliClientappAclTMP1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMP1=cliClientappAclTMP1.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+syscode+"_SYSADMIN"});
					String commonAclTMP1=(String) cliResponseappAclTMP1.get_return().getReturnValue();
					if(!commonAclTMP1.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient2.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+syscode+"_SYSADMIN"});	
					}
						
					//给策略添加模板
					CLITunnelServiceClient cliClient31 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient31.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN","TMPLT_"+syscode+"_SYSADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient41 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient41.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient51 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient51.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_SYSADMIN",""+syscode+"_SYSADMIN","ACLPolicy.Read"});
					
					//分环境增加策略，并给策略增加模板及授权
					/*for(String env : envs){
						CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+syscode+"_SYSADMIN"});
						String common = (String) cliResponse1.get_return().getReturnValue();
						if(!common.equals("true")){
							//创建该系统的COMMONAPP策略模板
							cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient1.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+syscode+"_SYSADMIN"," "});
						}
							
						//给APP策略模板授权
						cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
						
						cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_SYSADMIN",syscode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
						
						//增加策略
						CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN"});
						String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
						if(!commonAclTMPEnv.equals("true")){
							//创建策略
							CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN"});	
						}
						//给策略添加模板
						CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN","TMPLT_"+env+"_"+syscode+"_SYSADMIN","false"});	
						//给ACL付权限
						CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
						
						CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_SYSADMIN",syscode+"_"+env+"_SYSADMIN","ACLPolicy.Read"});
					}*/
					
					//创建该系统角色APPADMIN
					CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("RBACRole", "createRole", new String[]{""+syscode+"_APPADMIN"," ","1"," "," "});
					//给角色授权
					CLITunnelServiceClient cliClientAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseAuth = cliClientAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+syscode+"_APPADMIN","AUTH_APPADMIN"});
					
					//分环境创建系统角色,并授权
					for(String env : envs){
						//创建角色
						CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{syscode+"_"+env+"_APPADMIN"," ","1"," "," "});
						//角色授权
						CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{syscode+"_"+env+"_APPADMIN","AUTH_APPADMIN"});	
					}
					
					//查询appACL，模板是否存在
					CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+syscode+"_APPADMIN"});
					String appACL = (String) cliResponse1.get_return().getReturnValue();
					if(!appACL.equals("true")){
						//创建该系统的APP策略模板
						CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClientappAclTMP.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+syscode+"_APPADMIN"," "});
					}
					//给APP策略模板授权
					CLITunnelServiceClient cliClientappAclTMPPerAll = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPerAll.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_APPADMIN","BLAdmins","AUTH_ADMINALL"});
					
					CLITunnelServiceClient cliClientappAclTMPPer = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMPPer.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+syscode+"_APPADMIN",""+syscode+"_APPADMIN","AUTH_APPADMIN"});
					
					//根据名字判断策略是否存在APP
					CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMP=cliClientappAclTMP.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+syscode+"_APPADMIN"});
					String appAclTMP=(String) cliResponseappAclTMP.get_return().getReturnValue();
					if(!appAclTMP.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient3.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+syscode+"_APPADMIN"});	
					}

					//给策略添加模板
					CLITunnelServiceClient cliClient5 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient5.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+syscode+"_APPADMIN","TMPLT_"+syscode+"_APPADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient7 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient7.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_APPADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient8 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient8.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+syscode+"_APPADMIN",""+syscode+"_APPADMIN","ACLPolicy.Read"});
				
					//分环境增加策略，并给策略增加模板及授权
					for(String env : envs){
						//查询appACL，模板是否存在
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliResponse = cliClient.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN"});
						String app9 = (String) cliResponse.get_return().getReturnValue();
						if(!app9.equals("true")){
							//创建该系统的APP策略模板
							cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN"," "});
						}
						//给APP策略模板授权
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN","BLAdmins","AUTH_ADMINALL"});
						
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+syscode+"_APPADMIN",syscode+"_"+env+"_APPADMIN","AUTH_APPADMIN"});
						
						
						//增加策略
						CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+syscode+"_APPADMIN"});
						String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
						if(!commonAclTMPEnv.equals("true")){
							//创建策略
							CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
							cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+syscode+"_APPADMIN"});	
						}
						//给策略添加模板
						CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+syscode+"_APPADMIN","TMPLT_"+env+"_"+syscode+"_APPADMIN","false"});	
						//给ACL付权限
						CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_APPADMIN","BLAdmins","ACLPolicy.*"});
						
						CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+syscode+"_APPADMIN",syscode+"_"+env+"_APPADMIN","ACLPolicy.Read"});
					}
				}
				String AppName=brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\""+syscode+"\" }}");
				if(AppName==null){
					brpmService.postMethod(BrpmConstants.KEYWORD_APPS, "<app><name>"+syscode+"</name></app>");
				}
				String sql="update cmn_app_conf set aop_flag='1' , online_env='" +onlineEnvsStr+"' where maop_appsys_code='"+syscode+"'  ";
				getSession().createSQLQuery(sql).executeUpdate();
				//应用系统创建属性类并赋权、创建服务器属性
				addPropertyForApp(syscode,envs);
			}
		}else{
			String appcode = appsyscd;
			if(appcode.contains("</span>")){
				appindex = appsyscd.indexOf(">");
				sysindex=appsyscd.lastIndexOf("<");
				appcode = appsyscd.substring(appindex+1, sysindex);
			}
			//用户登录
			loginClient = new LoginServiceClient(messages.getMessage("bsa.userNameRbac"), 
								messages.getMessage("bsa.userPassword"),
								messages.getMessage("bsa.authenticationType"), null,
								System.getProperty("maop.root")+File.separator+ 	messages.getMessage("bsa.truststoreFile"),
								messages.getMessage("bsa.truststoreFilePassword"));
			res4Login = loginClient.loginUsingUserCredential();
			//设置用户角色
			aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(),null);
			aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac"));
		
			if(appcode.equals("COMMON")){
				//创建该系统角色COMMONSYSADMIN
            	CLITunnelServiceClient cliClientSYS = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            	ExecuteCommandByParamListResponse cliResponseSYS = cliClientSYS.executeCommandByParamList("RBACRole", "createRole", new String[]{""+appcode+"_SYSADMIN"," ","1"," "," "});
            	//给COMMONSYSADMIN角色授权
            	CLITunnelServiceClient cliClientsysAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            	ExecuteCommandByParamListResponse cliResponsesysAuth = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+appcode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
        	  	
            	//分环境创建系统角色,并授权
            	/*for(String env : envs){
            		//创建角色
            		CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            		ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{appcode+"_"+env+"_SYSADMIN"," ","1"," "," "});
            		//角色授权
            		CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            		ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{appcode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
            	}*/
            	
            	//查询COMMONACL，模板是否存在
				CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+appcode+"_SYSADMIN"});
				String commonACL = (String) cliResponse1.get_return().getReturnValue();
				
				if(!commonACL.equals("true")){
					//创建该系统的COMMONAPP策略模板
					CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMP.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+appcode+"_SYSADMIN"," "});
				}
				//给APP策略模板授权
				CLITunnelServiceClient cliClientappAclTMPPerAll = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPerAll.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
				
				CLITunnelServiceClient cliClientappAclTMPPer = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPer.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_SYSADMIN",appcode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
				
				//根据名字判断策略是否存在COMMON
				CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseappAclTMP=cliClientappAclTMP.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+appcode+"_SYSADMIN"});
				String commonAclTMP=(String) cliResponseappAclTMP.get_return().getReturnValue();
				if(!commonAclTMP.equals("true")){
					//创建策略
					CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient2.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+appcode+"_SYSADMIN"});	
				}
				//给策略添加模板
				CLITunnelServiceClient cliClient3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient3.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN","TMPLT_"+appcode+"_SYSADMIN","false"});	
				
				//给ACL付权限
				CLITunnelServiceClient cliClient4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient4.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
				
				CLITunnelServiceClient cliClient5 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient5.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN",""+appcode+"_SYSADMIN","ACLPolicy.Read"});
			
				//分环境增加策略，并给策略增加模板及授权
				/*for(String env : envs){
					//查询COMMONACL，模板是否存在
					CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN"});
					String common = (String) cliResponse.get_return().getReturnValue();
					if(!common.equals("true")){
						//创建该系统的COMMONAPP策略模板
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN"," "});
					}
					//给APP策略模板授权
					cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
					
					cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN",appcode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
					
					//增加策略
					CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN"});
					String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
					if(!commonAclTMPEnv.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN"});	
					}
					//给策略添加模板
					CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN","TMPLT_"+env+"_"+appcode+"_SYSADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN",appcode+"_"+env+"_SYSADMIN","ACLPolicy.Read"});
				}*/
			}else{
				//创建该系统角色COMMONSYSADMIN
            	CLITunnelServiceClient cliClientSYS = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            	ExecuteCommandByParamListResponse cliResponseSYS = cliClientSYS.executeCommandByParamList("RBACRole", "createRole", new String[]{""+appcode+"_SYSADMIN"," ","1"," "," "});
            	//给COMMONSYSADMIN角色授权
            	CLITunnelServiceClient cliClientsysAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            	ExecuteCommandByParamListResponse cliResponsesysAuth = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+appcode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
            	
            	//分环境创建系统角色,并授权
            	/*for(String env : envs){
            		//创建角色
            		CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            		ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{appcode+"_"+env+"_SYSADMIN"," ","1"," "," "});
            		//角色授权
            		CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
            		ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{appcode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});	
            	}*/
            	
        	  	//查询COMMONACL，模板是否存在   应该建TMPLT_"+syscode+"_SYSADMIN
				CLITunnelServiceClient cliClient11 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse11 = cliClient11.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+appcode+"_SYSADMIN"});
				String commonACL = (String) cliResponse11.get_return().getReturnValue();
				if(!commonACL.equals("true")){
					//创建该系统的COMMONAPP策略模板
					CLITunnelServiceClient cliClientappAclTMP1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMP1.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+appcode+"_SYSADMIN"," "});
				}
				//给APP策略模板授权
				CLITunnelServiceClient cliClientappAclTMPPerAll1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPerAll1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
				
				CLITunnelServiceClient cliClientappAclTMPPer1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPer1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_SYSADMIN",""+appcode+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
				
				//根据名字判断策略是否存在COMMON
				CLITunnelServiceClient cliClientappAclTMP1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseappAclTMP1=cliClientappAclTMP1.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+appcode+"_SYSADMIN"});
				String commonAclTMP1=(String) cliResponseappAclTMP1.get_return().getReturnValue();
				if(!commonAclTMP1.equals("true")){
					//创建策略
					CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient2.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+appcode+"_SYSADMIN"});	
				}
				//给策略添加模板
				CLITunnelServiceClient cliClient31 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient31.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN","TMPLT_"+appcode+"_SYSADMIN","false"});	
				//给ACL付权限
				CLITunnelServiceClient cliClient41 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient41.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
				
				CLITunnelServiceClient cliClient51 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient51.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_SYSADMIN",""+appcode+"_SYSADMIN","ACLPolicy.Read"});
				
				//分环境增加策略，并给策略增加模板及授权
				/*for(String env : envs){
					CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN"});
					String common = (String) cliResponse.get_return().getReturnValue();
					if(!common.equals("true")){
						//创建该系统的COMMONAPP策略模板
						cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN"," "});
					}
					//给APP策略模板授权
					cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN","BLAdmins","AUTH_ADMINALL"});
					
					cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_SYSADMIN",appcode+"_"+env+"_SYSADMIN","AUTH_COMMON_SYSADMIN"});
					
					//增加策略
					CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN"});
					String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
					if(!commonAclTMPEnv.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN"});	
					}
					//给策略添加模板
					CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN","TMPLT_"+env+"_"+appcode+"_SYSADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_SYSADMIN",appcode+"_"+env+"_SYSADMIN","ACLPolicy.Read"});
				}*/
				
				//创建该系统角色
				CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient.executeCommandByParamList("RBACRole", "createRole", new String[]{""+appcode+"_APPADMIN"," ","1"," "," "});
				//给角色授权
				CLITunnelServiceClient cliClientAuth = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{""+appcode+"_APPADMIN","AUTH_APPADMIN"});
				
				//分环境创建系统角色,并授权
				for(String env : envs){
					//创建角色
					CLITunnelServiceClient cliClientSYSEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseSYSEnv = cliClientSYSEnv.executeCommandByParamList("RBACRole", "createRole", new String[]{appcode+"_"+env+"_APPADMIN"," ","1"," "," "});
					//角色授权
					CLITunnelServiceClient cliClientsysAuthEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponsesysAuthEnv = cliClientsysAuth.executeCommandByParamList("RBACRole", "addAuthProfileToRoleByName", new String[]{appcode+"_"+env+"_APPADMIN","AUTH_APPADMIN"});	
				}
				
				//查询appACL，模板是否存在
				CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+appcode+"_APPADMIN"});
				String appACL = (String) cliResponse1.get_return().getReturnValue();
				if(!appACL.equals("true")){
					//创建该系统的APP策略模板
					CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClientappAclTMP.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+appcode+"_APPADMIN"," "});
				}
				
				//给APP策略模板授权
				CLITunnelServiceClient cliClientappAclTMPPerAll = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPerAll.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_APPADMIN","BLAdmins","AUTH_ADMINALL"});
				
				CLITunnelServiceClient cliClientappAclTMPPer = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClientappAclTMPPer.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+appcode+"_APPADMIN",""+appcode+"_APPADMIN","AUTH_APPADMIN"});
				
				//根据名字判断策略是否存在APP
				CLITunnelServiceClient cliClientappAclTMP = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponseappAclTMP=cliClientappAclTMP.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+appcode+"_APPADMIN"});
				String appAclTMP=(String) cliResponseappAclTMP.get_return().getReturnValue();
				if(!appAclTMP.equals("true")){
					//创建策略
					CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient2.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+appcode+"_APPADMIN"});	
				}
				
				//给策略添加模板
				CLITunnelServiceClient cliClient3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient3.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+appcode+"_APPADMIN","TMPLT_"+appcode+"_APPADMIN","false"});	
				
				//给ACL付权限
				CLITunnelServiceClient cliClient4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient4.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_APPADMIN","BLAdmins","ACLPolicy.*"});
				
				CLITunnelServiceClient cliClient5 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
				cliClient5.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+appcode+"_APPADMIN",""+appcode+"_APPADMIN","ACLPolicy.Read"});
			
				//分环境增加策略，并给策略增加模板及授权
				for(String env : envs){
					//查询appACL，模板是否存在
					cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliResponse1 = cliClient1.executeCommandByParamList("BlAclTemplate", "templateExists", new String[]{"TMPLT_"+env+"_"+appcode+"_APPADMIN"});
					String app = (String) cliResponse1.get_return().getReturnValue();
					if(!app.equals("true")){
						//创建该系统的APP策略模板
						cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient1.executeCommandByParamList("BlAclTemplate", "createAclTemplate", new String[]{"TMPLT_"+env+"_"+appcode+"_APPADMIN"," "});
					}
					
					//给APP策略模板授权
					cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_APPADMIN","BLAdmins","AUTH_ADMINALL"});
					
					cliClient1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient1.executeCommandByParamList("BlAclTemplate", "addTemplatePermissionProfile", new String[]{"TMPLT_"+env+"_"+appcode+"_APPADMIN",appcode+"_"+env+"_APPADMIN","AUTH_APPADMIN"});
					
					//增加策略
					CLITunnelServiceClient cliClientappAclTMPEnv = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseappAclTMPEnv=cliClientappAclTMPEnv.executeCommandByParamList("BlAclPolicy", "nameToDBKey", new String[]{"PLCY_"+env+"_"+appcode+"_APPADMIN"});
					String commonAclTMPEnv=(String) cliResponseappAclTMPEnv.get_return().getReturnValue();
					if(!commonAclTMPEnv.equals("true")){
						//创建策略
						CLITunnelServiceClient cliClient2Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
						cliClient2Env.executeCommandByParamList("BlAclPolicy", "createAclPolicy", new String[]{"PLCY_"+env+"_"+appcode+"_APPADMIN"});	
					}
					//给策略添加模板
					CLITunnelServiceClient cliClient3Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient3Env.executeCommandByParamList("BlAclPolicy", "applyAclTemplateToPolicyPermission", new String[]{"PLCY_"+env+"_"+appcode+"_APPADMIN","TMPLT_"+env+"_"+appcode+"_APPADMIN","false"});	
					//给ACL付权限
					CLITunnelServiceClient cliClient4Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient4Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_APPADMIN","BLAdmins","ACLPolicy.*"});
					
					CLITunnelServiceClient cliClient5Env = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
					cliClient5Env.executeCommandByParamList("BlAclPolicy", "addPermission", new String[]{"PLCY_"+env+"_"+appcode+"_APPADMIN",appcode+"_"+env+"_APPADMIN","ACLPolicy.Read"});
				}
			}
			String AppName = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\""+appcode+"\" }}");
			if(AppName==null){
				brpmService.postMethod(BrpmConstants.KEYWORD_APPS, "<app><name>"+appcode+"</name></app>");
			}
			String sql2="update cmn_app_conf set aop_flag='1' , online_env='" +onlineEnvsStr+"' where maop_appsys_code='"+appcode+"'  ";
			getSession().createSQLQuery(sql2).executeUpdate();
			//应用系统创建属性类并赋权、创建服务器属性
			addPropertyForApp(appsyscd,envs);
		}
	}

	
	
	/**
	 * 根据用户信息查询系统.
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByUser(String user) {
		String hql = "select new map(t.appsysCode as id, t.appsysCode as appsysCode, t.systemname as name, "+ 
				"(select c.dplyFlag as dplyFlag from CmnUserAppVo c where c.userId=:username and c.appsysCode=t.appsysCode) as dplyFlag, " +
				"(select c.checkFlag as checkFlag from CmnUserAppVo c where c.userId=:username and c.appsysCode=t.appsysCode) as checkFlag, " +
				"(select c.toolFlag as toolFlag from CmnUserAppVo c where c.userId=:username and c.appsysCode=t.appsysCode) as toolFlag, " +
				"(case when (select count(*) from User user inner join user.apps app where user.username=:username and app.appsysCode = t.appsysCode)>0 then true else false end ) as checked, " +
				"(case when (select c.appType from CmnUserAppVo c where c.userId=:username and c.appsysCode=t.appsysCode)='H' then '手工' " +
				"	  when (select c.appType from CmnUserAppVo c where c.userId=:username and c.appsysCode=t.appsysCode)='A' then '自动' " +
				"     else '' end) as appType ) "
				+ " from ViewAppInfoVo t where t.aopFlag = '1' and t.deleteFlag = '0' order by t.appsysCode asc ";
		return getSession().createQuery(hql).setString("username", user).list();
	}


	/**
	 * 从ITSM同步系统信息
	 * @param synList 待同步的系统列表
	 * @param existList 已经存在的系统列表

	 * @return
	 * @throws InvocationTargetException 
	 * @throws IllegalAccessException 
	 * @throws NoSuchMethodException 
	 * @throws IllegalArgumentException 
	 * @throws SecurityException 
	 */
	//@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void syncApp(List<AppInfoItsmVo> synList, List<AppInfoItsmVo> existList) 
			throws SecurityException, IllegalArgumentException, NoSuchMethodException, IllegalAccessException, InvocationTargetException{
		//existList对应的系统配置信息列表
		List<AppConfVo> appConfExistList = new ArrayList<AppConfVo>();
		//synList对应的系统配置信息列表
		List<AppConfVo> appConfList = new ArrayList<AppConfVo>();
		
		Calendar cal = Calendar.getInstance();
		Long ss = cal.getTimeInMillis();
		Timestamp upTime = new Timestamp(ss);
		
		//处理existList关联的配置信息
		for(AppInfoItsmVo existApp : existList){
			AppConfVo conf = new AppConfVo();
			AppConfVo existConf = getAppConfByItsmCode(existApp.getSystemcode());
			if(existConf!=null){
				conf = existConf;
				//COMMON应用系统、人工维护系统不做逻辑删除
				if(!existConf.getMaopAppsysCode().equals("COMMON") && existConf.getSyncType()!=null && !existConf.getSyncType().equals("H")){
					conf.setDeleteFlag("1");
					//conf.setUpdateTime(upTime);
				}
			}else{
				String synSysCode = existApp.getSystemcode();
				conf.setItsmAppsysCode(synSysCode);
				String synEnglishCode = existApp.getEnglishcode();
				String synSysName = existApp.getSystemname();
				//英文简称不为空时，取英文简称
				if(synEnglishCode!=null && !synEnglishCode.equals("")){
					conf.setMaopAppsysCode(synEnglishCode);
				}else{
					Boolean b = false ;
					//英文简称为空时，截取系统名称|前面的英文简称
					if(synSysName!=null && !synSysName.equals("")){
						if(synSysName.indexOf("|")>0){
							conf.setMaopAppsysCode(synSysName.substring(0, synSysName.indexOf("|")));
							b = true ;
						}
					}
					//系统名称中不包含英文简称时，取系统编号
					if(!b){
						conf.setMaopAppsysCode(synSysCode);
					}
				}
				conf.setAopFlag("0");
				conf.setDeleteFlag("1");
				//conf.setUpdateTime(upTime);
				conf.setLastScanTime(null);
				conf.setUpdateBeforeRecord(null);
			}
			appConfExistList.add(conf);
		}
		
		//处理synList关联的配置信息
		for(int i=0 ; i<synList.size() ; i++){
			AppConfVo conf = new AppConfVo();
			AppInfoItsmVo synSystem = synList.get(i);
			String synSysCode = synSystem.getSystemcode(); //系统编号
			String synEnglishCode = synSystem.getEnglishcode(); //英文简称（对应MAOP平台的系统编码）
			String synSysName = synSystem.getSystemname(); //系统名称
			//第一次同步数据
			if(existList.size() == 0){
				conf.setItsmAppsysCode(synSysCode);
				//英文简称不为空时，取英文简称
				if(synEnglishCode!=null && !synEnglishCode.equals("")){
					conf.setMaopAppsysCode(synEnglishCode);
				}else{
					Boolean b = false ;
					//英文简称为空时，截取系统名称|前面的英文简称
					if(synSysName!=null && !synSysName.equals("")){
						if(synSysName.indexOf("|")>0){
							conf.setMaopAppsysCode(synSysName.substring(0, synSysName.indexOf("|")));
							b = true ;
						}
					}
					//系统名称中不包含英文简称时，取系统编号
					if(!b){
						conf.setMaopAppsysCode(synSysCode);
					}
				}
				conf.setSyncType("A"); //自动同步
				conf.setDeleteFlag("0");
				conf.setAopFlag("0");
				conf.setUpdateTime(upTime);
				conf.setLastScanTime(null);
				conf.setUpdateBeforeRecord(null);
			}else{
				Boolean b = true ; //同步数据是否是MOAP平台不存在的新数据
				for(AppInfoItsmVo existSystem : existList){
					if(synSysCode.equals(existSystem.getSystemcode())){ //已存在相同系统

						b = false;
						AppConfVo existConf = getAppConfByItsmCode(synSysCode);
						if(existConf!=null){
							conf = existConf;
							if(ComUtil.compareTwoObjects(synSystem,existSystem)){ //系统信息没有变化
								conf.setDeleteFlag("0");
								//conf.setUpdateTime(upTime);	
							}else{
								conf.setUpdateBeforeRecord(getExistRecordStr(existSystem));
								conf.setDeleteFlag("0");
								conf.setUpdateTime(upTime);	
							}
						}else{
							conf.setItsmAppsysCode(synSysCode);
							//英文简称不为空时，取英文简称
							if(synEnglishCode!=null && !synEnglishCode.equals("")){
								conf.setMaopAppsysCode(synEnglishCode);
							}else{
								Boolean flag = false ;
								//英文简称为空时，截取系统名称|前面的英文简称
								if(synSysName!=null && !synSysName.equals("")){
									if(synSysName.indexOf("|")>0){
										conf.setMaopAppsysCode(synSysName.substring(0, synSysName.indexOf("|")));
										flag = true ;
									}
								}
								//系统名称中不包含英文简称时，取系统编号
								if(!flag){
									conf.setMaopAppsysCode(synSysCode);
								}
							}
							conf.setSyncType("A"); //自动同步
							conf.setDeleteFlag("0");
							conf.setAopFlag("0");
							conf.setUpdateTime(upTime);
							conf.setLastScanTime(null);
							if(!synSystem.equals(existSystem)){ //系统信息有变化
								conf.setUpdateBeforeRecord(getExistRecordStr(existSystem));
							}else{
								conf.setUpdateBeforeRecord(null);
							}
						}
						break;
					}
				}
				if(b){ //配置新数据
					conf.setItsmAppsysCode(synSysCode);
					//英文简称不为空时，取英文简称
					if(synEnglishCode!=null && !synEnglishCode.equals("")){
						conf.setMaopAppsysCode(synEnglishCode);
					}else{
						Boolean flag = false ;
						//英文简称为空时，截取系统名称|前面的英文简称
						if(synSysName!=null && !synSysName.equals("")){
							if(synSysName.indexOf("|")>0){
								conf.setMaopAppsysCode(synSysName.substring(0, synSysName.indexOf("|")));
								flag = true ;
							}
						}
						//系统名称中不包含英文简称时，取系统编号
						if(!flag){
							conf.setMaopAppsysCode(synSysCode);
						}
					}
					conf.setSyncType("A"); //自动同步
					conf.setDeleteFlag("0");
					conf.setAopFlag("0");
					conf.setUpdateTime(upTime);
					conf.setLastScanTime(null);
					conf.setUpdateBeforeRecord(null);
				}
			}
			//将系统信息有修改的记录删除，只保存MAOP平台已存在系统中需要删除的记录
			for(AppConfVo appConfExist : appConfExistList){
				if(appConfExist.getItsmAppsysCode().equals(synSysCode)){
					appConfExistList.remove(appConfExist);
				}
				break;
			}
			appConfList.add(conf);
		}
		//修改existList对应的配置信息表
		for(AppConfVo existAppConf : appConfExistList){
			Object obj = getAppConfById(existAppConf.getItsmAppsysCode());
            if(obj!=null){
            	getSession().delete(obj);
            }
        	getSession().save(existAppConf);
		}
		//修改synList系统信息表及对应的配置信息表
		saveOrUpdate(synList,appConfList);
	}

	/**
	 * 处理系统信息
	 * @return
	 */
	private void saveOrUpdate(List<AppInfoItsmVo> appInfoList,List<AppConfVo> appConfList) {
		for(AppInfoItsmVo appInfo : appInfoList){
			Object obj = getAppInfoById(appInfo.getSystemcode());
            if(obj!=null){
            	getSession().delete(obj);
            }
        	getSession().save(appInfo);
			//getSession().saveOrUpdate(appInfo);
		}
		for(AppConfVo appConf : appConfList){
			Object obj = getAppConfById(appConf.getItsmAppsysCode());
            if(obj!=null){
            	getSession().delete(obj);
            }
        	getSession().save(appConf);
			//saveOrUpdateAppConf(appConf);
		}
	}
	
	/**
	 * 根据主键查询.
	 * @param systemCode ITSM同步系统编号
	 * @return
	 */
	public Object getAppInfoById(Serializable systemCode) {
		return getSession().get(AppInfoItsmVo.class, systemCode);
	}
	
	/**
	 * 根据主键查询系统配置信息
	 * @param itsmAppsysCode ITSM同步系统编号
	 * @return
	 */
	public Object getAppConfById(Serializable itsmAppsysCode) {
		return getSession().get(AppConfVo.class, itsmAppsysCode);
	}
	
	/**
	 * FTP获取文件
	 * @param customer
	 */
	@Transactional
	public void ftpGetFile(String filePath) throws FtpCmpException{
		//String host="10.1.7.28";
		//int port =21;
		//String user = "appdata";
		//String password = "appdataceb";
		String host=messages.getMessage("importServer.ipAdress.system");
		int port = (Integer.parseInt(messages.getMessage("importServer.port.system")));
		String user = messages.getMessage("importServer.user.system");
		String password=messages.getMessage("importServer.password.system");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		//系统当前日期
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		String apppicationInfo=messages.getMessage("importServer.systemFilePath").concat(CommonConst.SLASH).concat("sysInfo_").concat(strDate).concat(".xml");
        ftpFile.doGet(apppicationInfo, filePath, true,new StringBuffer());
		ftpLogin.disconnect();
	}
	
	/**
	 * 同步ITSM系统信息
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("static-access")
	@Transactional(readOnly = true , propagation=Propagation.NOT_SUPPORTED)
	public List<AppInfoItsmVo> readAppInfoVoFromFile(
			Long logJnlNo,StringBuilder errNum,StringBuilder Num,StringBuilder Path,HttpServletRequest request) 
					throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		int err=0;
		String crlf=System.getProperty("line.separator");
		String fileFoder= System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.interfaceFile");
		File foder = new File(fileFoder);
		//创建interface文件夹
		if(!foder.exists()){
			foder.mkdir();
		}
		//放入日志的错误信息
		StringBuilder errorInfo = new StringBuilder();
		//去重的ITSM系统编号
		List<String> synableCodeList = new ArrayList<String>();
		
		
		List<String> checkNames = new ArrayList<String>();
		AppInfoItsmVo vo =new AppInfoItsmVo();
		Field[] fs=vo.getClass().getDeclaredFields();
		for(Field f : fs){
			String name=f.getName();
			checkNames.add(name);
		}
		
		//解析xml文件，得到AppInfoItsmVo对象列表
		List<AppInfoItsmVo> apps = new ArrayList<AppInfoItsmVo>();
		String xml = (String)request.getSession().getAttribute("systemSynXml");
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			List<Element> recordInfos = root4.getChild("opdetail").getChildren("recordInfo");
			if(recordInfos!=null && recordInfos.size()>0){
				int t = 1 ;
				for (Element recordInfo : recordInfos) {
					t++; //记录数
					Boolean addFlag = true ; //是否添加实例
					List<Element> fieldInfos = recordInfo.getChildren("fieldInfo");
					//字段个数验证
					if(fieldInfos.size()!=Constants.APPINFO_COLUMNS){
						err++;
						errorInfo.append(">@>" + messages.getMessage("check.error.record", new Object[]{t}));
						errorInfo.append(">@>");
						//数据列数和表字段数不匹配
						errorInfo.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.APPINFO_COLUMNS)}));
						errorInfo.append(">@>系统同步XML文件中的第"+t+"条记录");
						errorInfo.append(crlf);
						addFlag = false;
					}
					
					if(addFlag){
						AppInfoItsmVo appInfoItsm = new AppInfoItsmVo();
						String systemcode = "" ; //系统编号
						for(Element fieldInfo : fieldInfos){
							//字段名称
							String fieldEnName = fieldInfo.getChildText("fieldEnName");
							//字段值
						    String fieldContent = fieldInfo.getChildText("fieldContent");
						    //系统编号取值
						    if(fieldEnName.equals("systemcode")){
						    	systemcode =  fieldContent;
						    }
							String firstLetter= fieldEnName.substring(0,1).toUpperCase();
						    String getMethodName="set"+firstLetter+fieldEnName.substring(1);
						    //日期时间类型数据
							if(fieldEnName.equals("onlinedate") || fieldEnName.equals("outlinedate")){
								Method getMethodDate = appInfoItsm.getClass().getMethod(getMethodName, Timestamp.class);
								if(fieldContent!=null && !fieldContent.equals("")){
									try{
										Date d = new Date(Long.valueOf(fieldContent));
										String date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(d);
										getMethodDate.invoke(appInfoItsm, Timestamp.valueOf(date));
									}catch(Exception e){
										logger.info("错误的日期格式："+fieldContent);
									}
								}
							}else{    //字符串类型数据
								if(checkNames.contains(fieldEnName)){
									Method getMethodStr = appInfoItsm.getClass().getMethod(getMethodName, String.class);
							    	getMethodStr.invoke(appInfoItsm, fieldContent);
								}
								
							}
						}
						if(!systemcode.equals("") && systemcode != null){
							if(appInfoItsm!=null &&appInfoItsm!=new AppInfoItsmVo()){
								//校验主键是否重复
								boolean repeat=CheckRepeatData(appInfoItsm.getSystemcode(),errorInfo,t,synableCodeList);
								if(!repeat){
									apps.add(appInfoItsm);
								}else{
									err++;
								}
							}
						}else{
							err++;
							errorInfo.append(">@>" + messages.getMessage("check.error.record", new Object[]{t}));
							errorInfo.append(">@>");
							errorInfo.append("字段值不合法");
							errorInfo.append(">@>系统编号为空");
							errorInfo.append(crlf);
						}
					}
				}
			}
		} 
		errNum.append(String.valueOf(err));
		
		//错误信息的日志处理
        if(errorInfo.length() > 0 ){
        	String logpath=ComUtil.writeLogFile(errorInfo.toString(), 0);
        	cmnDetailLogService.updateBydetailLog(logJnlNo, 1, logpath);
    		//更新脚步执行结束时间
    		cmnLogService.updateCMNLOGPaltForm(logJnlNo);
    		Path.append(logpath);
        }
        
        //格式正确的数据
        Num.append(String.valueOf(apps.size()));
		return apps;
	}

	/**
	 * 检查ITSM同步文件中的重复主键
	 * @param systemCode ITSM系统编号
	 * @param errorInfo 错误信息
	 * @param errorSort 错误记录排序个数
	 * @param synableCodeList 去重的ITSM系统编号
	 * @throws Exception
	 */
	public boolean CheckRepeatData(String systemCode,StringBuilder errorInfo, int errorSort, List<String> synableCodeList) {
		String crlf=System.getProperty("line.separator");
		boolean repeat = false;
		StringBuilder errMsg = new StringBuilder();
		if(!synableCodeList.contains(systemCode)){
			synableCodeList.add(systemCode);
		}else{
			errMsg.append(">@>存在主键重复数据,应用系统=[" + systemCode + "]");
			errMsg.append(">@>"+systemCode);
		}
		if(errMsg.length() != 0){
			repeat = true;
			if(errorSort > 0){
				errorInfo.append(">@>" + messages.getMessage("check.error.record", new Object[]{errorSort}));
			}
			errorInfo.append(errMsg.toString());
			errorInfo.append(crlf);
		}
		return repeat;
	}
	
	/**
	 * 获取当前用户的系统列表
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalSysList(){
    	List<String> sysList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select v.appsys_code as \"appsysCode\" ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId) ")
			.append(" and v.delete_flag = '0' ")
			.append(" order by v.appsys_code ");
		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
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
	 * 获取当前用户的系统列表_应用发布
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalSysListForDply(){
    	List<String> sysList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select v.appsys_code as \"appsysCode\" ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.dply_flag = '1') ")
			.append(" and v.delete_flag = '0' ")
			.append(" order by v.appsys_code ");
		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
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
	 * 获取当前用户的系统列表_巡检
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalSysListForCheck(){
    	List<String> sysList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select v.appsys_code as \"appsysCode\" ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.check_flag = '1') ")
			.append(" and v.delete_flag = '0' ")
			.append(" order by v.appsys_code ");
		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
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
	 * 获取当前用户的系统列表_工具箱

	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalSysListForTool(){
    	List<String> sysList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select v.appsys_code as \"appsysCode\" ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u  ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.tool_flag = '1') ")
			.append(" and v.delete_flag = '0' ")
			.append(" order by v.appsys_code ");
		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
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
	 * 下线设定
	 * @param appsyscd 
	 * @return
	 * @throws Exception 
	 */
	@Transactional
	public void setAopDownline(String appsyscd) throws Exception{
		//<span style="color:red">ACS</span>
		int appindex ;// “>”的位置
		int sysindex ;// “<”的位置
		String updateSql = null;
		String delSql = null;
		if(appsyscd.indexOf(",")!=-1){
			String[] app = appsyscd.split(",");
			for(int i=0;i<app.length;i++){
				String syscode=app[i];
				if(app[i].contains("</span>")){
					 appindex = app[i].indexOf(">");
					 sysindex=app[i].lastIndexOf("<");
					syscode = app[i].substring(appindex+1, sysindex);
				}
				updateSql="update cmn_app_conf set aop_flag='0' where maop_appsys_code='"+syscode+"'  ";
				getSession().createSQLQuery(updateSql).executeUpdate();
				
				//系统下线后删除用户赋予的系统权限
				delSql = "delete from cmn_user_app where appsys_code = '"+syscode+"'  ";
				getSession().createSQLQuery(delSql).executeUpdate();
			}
		}else{
			String appcode = appsyscd;
			//System.out.println(appcode);
			if(appcode.contains("</span>")){
				appindex = appsyscd.indexOf(">");
				sysindex=appsyscd.lastIndexOf("<");
				appcode = appsyscd.substring(appindex+1, sysindex);
			}
			updateSql="update cmn_app_conf set aop_flag='0' where maop_appsys_code='"+appcode+"'  ";
			getSession().createSQLQuery(updateSql).executeUpdate();
			
			//系统下线后删除用户赋予的系统权限
			delSql = "delete from cmn_user_app where appsys_code='"+appsyscd+"'  ";
			getSession().createSQLQuery(delSql).executeUpdate();
		}
	}
	
	/**
	 * 读取文件内容
	 * @param filePath 文件路径
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException 
	 */
	public static String readXmlFile(String filePath) 
			throws UnsupportedEncodingException, FileNotFoundException,IOException{
		Reader reader = new InputStreamReader(new FileInputStream(filePath),"utf-8");
		BufferedReader br = new BufferedReader(reader);
		String xmlLine = "";
		StringBuffer xml = new StringBuffer();
		while((xmlLine = br.readLine()) != null){
			xml = xml.append(xmlLine);
		}
		br.close();
		return xml.toString();
	}
	
    /**
     * 将应用系统对象拼成字符串	
     * @param existSystem MAOP平台已存在的应用系统
     * @return
     */
	public String getExistRecordStr(AppInfoItsmVo existSystem){
		StringBuffer sb = new StringBuffer();
		if(existSystem!=null){
			sb.append(existSystem.getSystemcode()+"|+|");
			sb.append(existSystem.getSystemname()+"|+|");
			sb.append(existSystem.getEapssystemname()+"|+|");
			sb.append(existSystem.getEnglishcode()+"|+|");
			sb.append(existSystem.getAffectsystem()+"|+|");
			sb.append(existSystem.getBranch()+"|+|");
			sb.append(existSystem.getKey()+"|+|");
			sb.append(existSystem.getStatus()+"|+|");
			sb.append(existSystem.getSecuritylevel()+"|+|");
			sb.append(existSystem.getScope()+"|+|");
			sb.append(existSystem.getSystempro()+"|+|");
			if(existSystem.getOnlinedate() != null){
				String onlineDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(existSystem.getOnlinedate());
				sb.append(onlineDate+"|+|");
			}else{
				sb.append("|+|");
			}
			if(existSystem.getOutlinedate() != null){
				String outlineDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(existSystem.getOutlinedate());
				sb.append(outlineDate+"|+|");
			}else{
				sb.append("|+|");
			}
			sb.append(existSystem.getServerlevel()+"|+|");
			sb.append(existSystem.getSystemlevel()+"|+|");
			sb.append(existSystem.getIsimportant()+"|+|");
			sb.append(existSystem.getIskey()+"|+|");
			sb.append(existSystem.getIscoresyetem()+"|+|");
			sb.append(existSystem.getCbrcimportantsystem()+"|+|");
			sb.append(existSystem.getApplicateoperate()+"|+|");
			sb.append(existSystem.getOutsourcingmark()+"|+|");
			sb.append(existSystem.getNetworkdomain()+"|+|");
			sb.append(existSystem.getTeam()+"|+|");
			sb.append(existSystem.getOperatemanager()+"|+|");
			sb.append(existSystem.getApplicatemanagerA()+"|+|");
			sb.append(existSystem.getApplicatemanagerB()+"|+|");
			sb.append(existSystem.getSystemmanagerA()+"|+|");
			sb.append(existSystem.getSystemmanagerB()+"|+|");
			sb.append(existSystem.getNetworkmanagerA()+"|+|");
			sb.append(existSystem.getNetworkmanagerB()+"|+|");
			sb.append(existSystem.getDBA()+"|+|");
			sb.append(existSystem.getMiddlewaremanager()+"|+|");
			sb.append(existSystem.getStoremanager()+"|+|");
			sb.append(existSystem.getPM()+"|+|");
			sb.append(existSystem.getBusinessdepartment()+"|+|");
			sb.append(existSystem.getBusinessmanager()+"|+|");
			sb.append(existSystem.getServicesupporter()+"|+|");
			sb.append(existSystem.getIstestcenter()+"|+|");
			sb.append(existSystem.getAllottestmanager()+"|+|");
			sb.append(existSystem.getDeliverytestmanager()+"|+|");
			sb.append(existSystem.getQualitymanager()+"|+|");
			sb.append(existSystem.getPerformancetestmanag()+"|+|");
			sb.append(existSystem.getTransfercoefficient()+"|+|");
			sb.append(existSystem.getStage()+"|+|");
			sb.append(existSystem.getBusinessintroduction());
		}
		return sb.toString();
	}
	
	/**
	 * 根据ITSM系统编号获取系统配置实例
	 * @param synSysCode
	 * @return
	 */
	public AppConfVo getAppConfByItsmCode(String synSysCode){
		return  (AppConfVo)getSession()
				.createQuery("from AppConfVo t where t.itsmAppsysCode = ? ")
				.setString(0, synSysCode).uniqueResult();
	}
	
	/**
	 * 比较修改前后的数据，将被修改处的字体变红
	 * @param alllist 修改后的数据列表
	 * @param updatelist 修改前的数据列表
	 * @return
	 */
	public List<Map<String,String>> compareOldAndNewList(List<Map<String,String>> alllist,List<Map<String,String>>updatelist){
		//遍历修改前的数据
		for(Map<String, String> updatemap :updatelist){
			Map<String, String > oldmap = new HashMap<String, String>();
			String updateRecord = ComUtil.checkNull(updatemap.get("updateBeforeRecord"));
			//获取修改前各字段值

			String[] oldRecord = updateRecord.split(Constants.SPLIT_SEPARATEOR);
		    //遍历最新数据

			for(Map<String, String> newmap :alllist){
				//新旧记录主键相同，并且存在修改

				if((updatemap.get("systemcode")).equals(newmap.get("systemcode")) && !updateRecord.equals("")){
					oldmap.put("systemcode",ComUtil.checkNull(oldRecord[0]));
					oldmap.put("systemname",ComUtil.checkNull(oldRecord[1]));
					oldmap.put("eapssystemname",ComUtil.checkNull(oldRecord[2]));
					oldmap.put("englishcode",ComUtil.checkNull(oldRecord[3]));
					oldmap.put("affectsystem",ComUtil.checkNull(oldRecord[4]));
					oldmap.put("branch",ComUtil.checkNull(oldRecord[5]));
					oldmap.put("key",ComUtil.checkNull(oldRecord[6]));
					oldmap.put("status",ComUtil.checkNull(oldRecord[7]));
					oldmap.put("securitylevel",ComUtil.checkNull(oldRecord[8]));
					oldmap.put("scope",ComUtil.checkNull(oldRecord[9]));
					oldmap.put("systempro",ComUtil.checkNull(oldRecord[10]));
					oldmap.put("onlinedate",ComUtil.checkNull(oldRecord[11]));
					oldmap.put("outlinedate",ComUtil.checkNull(oldRecord[12]));
					oldmap.put("serverlevel",ComUtil.checkNull(oldRecord[13]));
					oldmap.put("systemlevel",ComUtil.checkNull(oldRecord[14]));
					oldmap.put("isimportant",ComUtil.checkNull(oldRecord[15]));
					oldmap.put("iskey",ComUtil.checkNull(oldRecord[16]));
					oldmap.put("iscoresyetem",ComUtil.checkNull(oldRecord[17]));
					oldmap.put("cbrcimportantsystem",ComUtil.checkNull(oldRecord[18]));
					oldmap.put("applicateoperate",ComUtil.checkNull(oldRecord[19]));
					oldmap.put("outsourcingmark",ComUtil.checkNull(oldRecord[20]));
					oldmap.put("networkdomain",ComUtil.checkNull(oldRecord[21]));
					oldmap.put("team",ComUtil.checkNull(oldRecord[22]));
					oldmap.put("operatemanager",ComUtil.checkNull(oldRecord[23]));
					oldmap.put("applicatemanagerA",ComUtil.checkNull(oldRecord[24]));
					oldmap.put("applicatemanagerB",ComUtil.checkNull(oldRecord[25]));
					oldmap.put("systemmanagerA",ComUtil.checkNull(oldRecord[26]));
					oldmap.put("systemmanagerB",ComUtil.checkNull(oldRecord[27]));
					oldmap.put("networkmanagerA",ComUtil.checkNull(oldRecord[28]));
					oldmap.put("networkmanagerB",ComUtil.checkNull(oldRecord[29]));
					oldmap.put("DBA",ComUtil.checkNull(oldRecord[30]));
					oldmap.put("middlewaremanager",ComUtil.checkNull(oldRecord[31]));
					oldmap.put("storemanager",ComUtil.checkNull(oldRecord[32]));
					oldmap.put("PM",ComUtil.checkNull(oldRecord[33]));
					oldmap.put("businessdepartment",ComUtil.checkNull(oldRecord[34]));
					oldmap.put("businessmanager",ComUtil.checkNull(oldRecord[35]));
					oldmap.put("servicesupporter",ComUtil.checkNull(oldRecord[36]));
					oldmap.put("istestcenter",ComUtil.checkNull(oldRecord[37]));
					oldmap.put("allottestmanager",ComUtil.checkNull(oldRecord[38]));
					oldmap.put("deliverytestmanager",ComUtil.checkNull(oldRecord[39]));
					oldmap.put("qualitymanager",ComUtil.checkNull(oldRecord[40]));
					oldmap.put("performancetestmanag",ComUtil.checkNull(oldRecord[41]));
					oldmap.put("transfercoefficient",ComUtil.checkNull(oldRecord[42]));
					oldmap.put("stage",ComUtil.checkNull(oldRecord[43]));
					oldmap.put("businessintroduction",ComUtil.checkNull(oldRecord[44]));
					for(String key : oldmap.keySet()){
						if(!oldmap.get(key).equals(newmap.get(key))  ){
							newmap.put(key , "<span style=\"color:red\">" + ComUtil.checkNull(newmap.get(key))+ "</span>");
						}
					}
				}
				if((updatemap.get("systemcode")).equals(newmap.get("systemcode")) && updateRecord.equals("")){
					for(String key : newmap.keySet()){
						if(!key.equals("aopFlag") && !key.equals("lastScanTime") && !key.equals("appsysCode") && !key.equals("updateTime")){
							newmap.put(key , "<span style=\"color:red\">" + ComUtil.checkNull(newmap.get(key))+ "</span>");
						} 
					}
				}
			}	
		}
		return alllist;
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表,返回List
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String,String>> getSystemIDAndNamesByUserAndID(String userId,String appsysCode){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		    .append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId) ")
			.append(" and v.delete_flag != '1' ");
		if(appsysCode!=null && !appsysCode.equals("")){
			sql.append(" and v.appsys_code = '"+appsysCode+"'");
		}
		sql.append(" order by v.appsys_code ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表,返回List_工具箱
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String,String>> getSystemIDAndNamesByUserAndIDForTool(String userId,String appsysCode){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		    .append(" case when instr(v.systemname,v.appsys_code) <> 0 then v.systemname ")
		    .append(" else v.systemname || '（' || v.appsys_code || '）' end as \"appsysName\"  ")
			.append(" from v_cmn_app_info v  ")
			.append(" where exists (select * from cmn_user_app u ")
			.append(" where v.appsys_code = u.appsys_code ")
			.append(" and u.user_id = :userId ")
			.append(" and u.tool_flag = '1') ")
			.append(" and v.delete_flag != '1' ");
		if(appsysCode!=null && !appsysCode.equals("")){
			sql.append(" and v.appsys_code = '"+appsysCode+"'");
		}
		sql.append(" order by v.appsys_code ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 定时自动同步应用系统信息
	 * @throws Exception 
	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException 
	 * @throws DataException 
	 */
	public void autoSynAppInfo() throws DataException, UnsupportedEncodingException, FileNotFoundException, NoSuchMessageException, IOException, Exception{
		//获取数据字典中应用系统自动同步开关数值
		String onOff = "";
		onOff = itemService.getSubItemValueByItemIdAndSubItemName("ONOFF_SWITCH","autoSyn_appInfo");		
		if(onOff.equals("on")){ //开启自动同步
			//开始插入日志
		     Long logJnlNo = cmnLogService.logPaltformForAutoSyn(0,"admin");
			//详细日志开始
		   	cmnDetailLogService.saveBydetailLog(logJnlNo,0,"1");
			//读取文件信息
			List<AppInfoItsmVo> synList = readAppInfoVoFromFileForAutoSyn(logJnlNo);
			if(synList!=null && synList.size()>0){
				//查询数据库中所有信息
				List<AppInfoItsmVo> existList = queryAppinfo();
				//执行新建或修改
				syncApp(synList,existList);
			}
			//日志结束更新数据
			cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
			cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
		}
	}
	
	/**
	 * 查询数据库中所有系统信息

	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<AppInfoItsmVo> queryAppinfo() throws SQLException{
		return getSession().createQuery("from AppInfoItsmVo t").list();
	}
	
	
	@Autowired
	private ApplicationProcessService applicationProcessService;
	
	/**
	 * 系统权限申请
	 * @param appsyscd 
	 * @return
	 * @throws Exception 
	 */
	@Transactional
	public void saveSystemAuthApply(String[] appsyscd,String systemAuth,String application_reasons) throws Exception{
		Date startDate = new Date();
		String simpleDateFormat1 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String simpleDateFormat2 = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String simpleDateFormat3 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;

		String process_description =simpleDateFormat1+"<br>"+applicationProcessService.findbyUserId()+": 应用系统权限审批流程提交;";//流程描述
		String record_id ="APP_PERMISSON_"+simpleDateFormat2+"_"+applicationProcessService.findProcessSeq();//工单号
        
		ApplicationProcessRecordsVo applicationProcessRecordsVo = new ApplicationProcessRecordsVo();
		applicationProcessRecordsVo.setRecord_id(record_id);
		applicationProcessRecordsVo.setSubject_info("3");
		applicationProcessRecordsVo.setApplication_user(securityUtils.getUser().getUsername());
		applicationProcessRecordsVo.setApplication_time(Timestamp.valueOf(simpleDateFormat3.concat(".000").toString()));
		applicationProcessRecordsVo.setCurrent_state("1");
		applicationProcessRecordsVo.setApplication_reasons(application_reasons.substring(1));
		applicationProcessRecordsVo.setProcess_description(process_description);
		applicationProcessRecordsVo.setDelete_flag("0");		
		applicationProcessService.save(applicationProcessRecordsVo);
		
		String[] systemAuths = systemAuth.split(",");
		StringBuilder sql = null;
		String dply = null;
		String toobox = null;
		String check = null;
		for(int i=0;i<appsyscd.length;i++){
			sql = new StringBuilder();
			dply = "0";
			toobox = "0";
			check = "0";
			for(int j=1;j<systemAuths.length;j++){
				if(systemAuths[j].equals("3")){
					dply = "1";
				}else if(systemAuths[j].equals("2")){
					toobox = "1";
				}else if(systemAuths[j].equals("1")){
					check = "1";
				}
				
			}
			sql.append("insert into APPLICATION_SYSTEM_AUTH ")
				.append("(RECORD_ID,APPLICATION_USER,APPSYS_CODE,APPLICATION_AUTY_DPLY,APPLICATION_AUTH_TOOLBOX,APPLICATION_AUTH_CHECK)")
				.append("values ( '")
				.append(record_id)
				.append("' , '")
				.append(securityUtils.getUser().getUsername())
				.append("' , '")
				.append(appsyscd[i])
				.append("' , '")
				.append(dply)
				.append("' , '")
				.append(toobox)
				.append("' , '")
				.append(check)
				.append("')");
			getSession().createSQLQuery(sql.toString()).executeUpdate();
		}
	}
	
	/**
	 * 判断XML文件中标示的记录总数是否与文件相符
	 * @return String 文件标示总记录数#文件解析总记录数
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	@SuppressWarnings("static-access")
	public String getSyncFlagForXml(HttpServletRequest request) 
			throws FtpCmpException,FileNotFoundException,IOException{
		String nums = "" ;
		String fileFoder= System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.interfaceFile");
		File foder = new File(fileFoder);
		//创建interface文件夹
		if(!foder.exists()){
			foder.mkdir();
		}
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date); 
		/* 获取FTP文件 */
		//String filePath="D:\\sysInfo_20141205.xml"; //仅用于测试
		String filePath = System.getProperty("maop.root")  + File.separator + messages.getMessage("systemServer.interfaceFile") + File.separator +  "sysInfo_"+strDate+".xml";
		ftpGetFile(filePath);
		String xml = readXmlFile(filePath);
		//&进行转义
		xml = xml.replaceAll("&", "&amp;");
		request.getSession().setAttribute("systemSynXml",xml);
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			String totalNumber = root4.getChild("ophead").getChildText("systotal");
			List<Element> recordInfos = root4.getChild("opdetail").getChildren("recordInfo");
			nums = totalNumber.concat("#").concat(String.valueOf(recordInfos.size()));
		}
		return nums;
	}
	
	/**
	 * 同步ITSM系统信息
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("static-access")
	@Transactional(readOnly = true , propagation=Propagation.NOT_SUPPORTED)
	public List<AppInfoItsmVo> readAppInfoVoFromFileForAutoSyn(Long logJnlNo) 
			throws UnsupportedEncodingException, FtpCmpException,FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		String fileFoder= System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.interfaceFile");
		File foder = new File(fileFoder);
		//创建interface文件夹
		if(!foder.exists()){
			foder.mkdir();
		}
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		//获取FTP文件
		String filePath = System.getProperty("maop.root")  + File.separator + messages.getMessage("systemServer.interfaceFile") + File.separator +  "sysInfo_"+strDate+".xml";
		ftpGetFile(filePath);
		//放入日志的错误信息
		StringBuilder errorInfo = new StringBuilder();
		//去重的ITSM系统编号
		List<String> synableCodeList = new ArrayList<String>();
		
		String crlf=System.getProperty("line.separator");
		
		//解析xml文件，得到AppInfoItsmVo对象列表
		List<AppInfoItsmVo> apps = new ArrayList<AppInfoItsmVo>();
		String xml = readXmlFile(filePath);
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			String totalNumber = root4.getChild("ophead").getChildText("systotal");
			List<Element> recordInfos = root4.getChild("opdetail").getChildren("recordInfo");
			if(recordInfos!=null && recordInfos.size()>0){
				if(!totalNumber.equals("") && Integer.valueOf(totalNumber) != recordInfos.size()){
					errorInfo.append(">@>");
					errorInfo.append("0");
					errorInfo.append(">@>");
					errorInfo.append("文件配置不合法");
					errorInfo.append(">@>");
					errorInfo.append("文件标识总记录数与实际配置总数不相等");
					errorInfo.append(crlf);
				}else{
					int t = 1 ;
					for (Element recordInfo : recordInfos) {
						t++; //记录数
						Boolean addFlag = true ; //是否添加实例
						List<Element> fieldInfos = recordInfo.getChildren("fieldInfo");
						//字段个数验证
						if(fieldInfos.size()!=Constants.APPINFO_COLUMNS){
							addFlag = false;
							errorInfo.append(">@>" + messages.getMessage("check.error.record", new Object[]{t}));
							errorInfo.append(">@>");
							//数据列数和表字段数不匹配
							errorInfo.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.APPINFO_COLUMNS)}));
							errorInfo.append(">@>");
							errorInfo.append("系统同步XML文件中的第"+t+"条记录");
							errorInfo.append(crlf);
							addFlag = false;
						}
						if(addFlag){
							AppInfoItsmVo appInfoItsm = new AppInfoItsmVo();
							String systemcode = "" ; //系统编号
							for(Element fieldInfo : fieldInfos){
								//字段名称
								String fieldEnName = fieldInfo.getChildText("fieldEnName");
								//字段值
							    String fieldContent = fieldInfo.getChildText("fieldContent");
							    //系统编号取值
							    if(fieldEnName.equals("systemcode")){
							    	systemcode =  fieldContent;
							    }
								String firstLetter= fieldEnName.substring(0,1).toUpperCase();
							    String getMethodName="set"+firstLetter+fieldEnName.substring(1);
							    //日期时间类型数据
								if(fieldEnName.equals("onlinedate") || fieldEnName.equals("outlinedate")){
									Method getMethodDate = appInfoItsm.getClass().getMethod(getMethodName, Timestamp.class);
									if(fieldContent!=null && !fieldContent.equals("")){
										try{
											Date d = new Date(Long.valueOf(fieldContent));
											String dateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(d);
											getMethodDate.invoke(appInfoItsm, Timestamp.valueOf(dateTime));
										}catch(Exception e){
											logger.info("错误的日期格式："+fieldContent);
										}
									}
								}else{    //字符串类型数据
									Method getMethodStr = appInfoItsm.getClass().getMethod(getMethodName, String.class);
							    	getMethodStr.invoke(appInfoItsm, fieldContent);
								}
							}
							if(systemcode.equals("") || systemcode == null){
								errorInfo.append(">@>" + messages.getMessage("check.error.record", new Object[]{t}));
								errorInfo.append(">@>");
								errorInfo.append("字段值不合法");
								errorInfo.append(">@>系统编号为空");
								errorInfo.append(crlf);
							}
							if(appInfoItsm!=null &&appInfoItsm!=new AppInfoItsmVo()){
								//校验主键是否重复
								boolean repeat=CheckRepeatData(appInfoItsm.getSystemcode(),errorInfo,t,synableCodeList);
								if(!repeat){
									apps.add(appInfoItsm);
								}
							}
						}
					}
				}
			}
		}
		//错误信息的日志处理
        if(errorInfo.length() > 0 ){
        	String logpath=ComUtil.writeLogFile(errorInfo.toString(), 0);
        	cmnDetailLogService.updateBydetailLog(logJnlNo, 1, logpath);
    		//更新脚步执行结束时间
    		cmnLogService.updateCMNLOGPaltForm(logJnlNo);
        }
		return apps;
	}
	
	/**
	 * 应用系统创建属性类并赋权、创建服务器属性
	 * @param appsysCode 系统编号
	 * @throws Exception 
	 */
	public void addPropertyForApp(String appsysCode,String[] envs) throws Exception{
		//属性类根目录
		String rootPath = "Class://SystemObject";
		//内置属性类服务器目录主路径
		String serverPath = "Class://SystemObject/SERVER";
		//应用系统分组目录
		String[] groups = new String[3];
		groups[0] = "APP";
		groups[1] = "WEB";
		groups[2] = "DB";
		
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
		//授权
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
    	
		logger.info("创建应用系统对象目录并授权，开始");
		String propertyClassName = "CLASS_" + appsysCode;
		//创建应用系统对象目录
		ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassDefined", 
				new String[]{rootPath + "/" + propertyClassName});
		if(cliResponse.get_return().getSuccess()){
			String isExist = (String)cliResponse.get_return().getReturnValue();
			if(isExist.equals("false")){
				//创建目录 eg:Class://SystemObject CLASS_AMS ""
				cliResponse = cliClient.executeCommandByParamList("PropertyClass", "createSubClass", 
						new String[]{rootPath,propertyClassName,""});
			}
			//目录授权
			for(String env : envs){
				//eg:Class://SystemObject/CLASS_AMS PLCY_AMS_APPADMIN
				cliResponse = cliClient.executeCommandByParamList("PropertyClass", "applyAclPolicy", 
						new String[]{rootPath+"/"+propertyClassName,"PLCY_"+env+"_"+appsysCode+"_APPADMIN"});
			}
		}
		logger.info("创建应用系统对象目录并授权，结束");
		
		logger.info("创建应用系统对象分组目录并授权，开始");
		//创建应用系统对象分组目录
		for(String group : groups){
			cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassDefined", 
					new String[]{rootPath+"/"+propertyClassName+"/"+group});
			if(cliResponse.get_return().getSuccess()){
				String isExist = (String)cliResponse.get_return().getReturnValue();
				if(isExist.equals("false")){
					//创建分组目录 eg:Class://SystemObject/CLASS_AMS DB "DB"
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "createSubClass", 
							new String[]{rootPath+"/"+propertyClassName,group,group});
				}
				//分组目录授权
				for(String env : envs){
					//eg:Class://SystemObject/CLASS_AMS/DB PLCY_AMS_APPADMIN
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "applyAclPolicy", 
							new String[]{rootPath+"/"+propertyClassName+"/"+group,"PLCY_"+env+"_"+appsysCode+"_APPADMIN"});
				}
			}
		}
		logger.info("创建应用系统对象分组目录并授权，结束");
		
		logger.info("创建服务器属性，开始");
		//将应用系统内置属性导入内置属性类服务器目录
		cliResponse = cliClient.executeCommandByParamList("PropertyClass","isPropertyClassDefined",
				new String[]{serverPath});
		if(cliResponse.get_return().getSuccess()){
			String isExist = (String)cliResponse.get_return().getReturnValue();
			if(isExist.equals("true")){
				for(String group : groups){  
					for(String env : envs){
						String serverPropertyName = "ATTR_"+env+"_"+appsysCode+"_"+group;
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyDefined", 
								new String[]{serverPath,serverPropertyName});
						if(cliResponse.get_return().getSuccess()){
							String b = (String)cliResponse.get_return().getReturnValue();
							if(b.equals("false")){
								//eg:Class://SystemObject/Server ATTR_AMS_DB "" Class://SystemObject/CLASS_AMS/DB "true" "false" ""
								cliResponse = cliClient.executeCommandByParamList("PropertyClass", "addProperty", 
										new String[]{serverPath,serverPropertyName,"",
										"Class://SystemObject/CLASS_"+appsysCode+"/"+group,"true","false",""});
							}
						}
					}
				}
			}
		}
		logger.info("创建服务器属性，结束");
	}
	
	/**
	 * 根据系统编号和用户账号获取系统环境列表
	 * @param appsysCode MAOP平台系统内部码
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getEnvsByAppAndUser(String appsysCode){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.sub_item_id as \"id\", ");
		sql.append(" t.sub_item_name as \"name\", ");
		sql.append(" t.sub_item_value as \"value\" ");
		sql.append(" from jeda_sub_item t  ");
		sql.append(" where t.item_id = '"+systemEnvs+"'  ");
		sql.append(" and exists (select * from cmn_user_env ue ");
		sql.append(" where t.sub_item_value = ue.env ");
		sql.append(" and ue.user_id = :userId ) ");
		sql.append(" and exists (select * from cmn_app_conf ac ");
		sql.append(" where ac.maop_appsys_code = '" + appsysCode +"'");
		sql.append(" and instr(ac.online_env,t.sub_item_value) <> 0 )");
		return getSession().createSQLQuery(sql.toString())
				.setString("userId", securityUtils.getUser().getUsername())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
	}
	
}

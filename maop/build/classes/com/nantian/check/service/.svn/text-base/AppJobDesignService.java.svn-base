package com.nantian.check.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
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

import org.apache.axis2.AxisFault;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * 应用巡检作业设计service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class AppJobDesignService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppJobDesignService.class);
	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
    private AppInfoService appInfoService;
	@Autowired
	private SecurityUtils securityUtils; 
	@Autowired
	private JobDesignService jobDesignService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	public String frontFlag = "一线";
	//BSAdepot目录下巡检主目录
	public String checkPath="CHECK";
	//BSA存放nsh脚本的文件夹
	public String nshPath="NSHELLS";
	//BSA存放sh脚本的文件夹
	public String shPath = "SCRIPTS";
	//nsh文件的Dbkey类型
	public String nshFileType = "NSHSCRIPT";
	//.sh文件的Dbkey类型
	public String fileType="DEPOT_FILE_OBJECT";
	
	/**
	 * 构造方法
	 */
	public AppJobDesignService() {
		fields.put("appsys_code", FieldType.STRING);
		fields.put("job_code", FieldType.INTEGER);
		fields.put("check_type",FieldType.STRING);
		fields.put("authorize_lever_type", FieldType.STRING); 
		fields.put("field_type", FieldType.STRING); 
		fields.put("job_path", FieldType.STRING); 
		fields.put("job_type", FieldType.STRING); 
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
		fields.put("server_path", FieldType.STRING);
		fields.put("server_name", FieldType.STRING);
        //作业模板关联字段
		fields.put("template_group", FieldType.STRING);
		fields.put("template_name", FieldType.STRING);
		//作业时间表字段
		fields.put("timer_code", FieldType.INTEGER);
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
		
		//应用巡检作业字段
		fields.put("script_name", FieldType.STRING);
		fields.put("exec_path", FieldType.STRING);
		fields.put("exec_user", FieldType.STRING);
		fields.put("exec_user_group", FieldType.STRING);
		fields.put("language_type", FieldType.STRING);
	}
	
	/**
	 * 分页查询作业基本信息
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getJobInfoList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params) {
		//判断当前用户是否是一线
		Set<Role> userRole = securityUtils.getUser().getRoles() ;
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
 		hql.append("e.job_type as job_type,");
 		hql.append("e.tool_status as tool_status,");
 		hql.append("e.frontline_flag as frontline_flag,");
 		hql.append("e.authorize_flag as authorize_flag,");
 		hql.append("e.delete_flag as delete_flag,");
 		hql.append("e.script_name as script_name,");
 		hql.append("e.exec_path as exec_path,");
 		hql.append("e.exec_user as exec_user,");
 		hql.append("e.exec_user_group as exec_user_group,");
 		hql.append("e.language_type as language_type,");
 		hql.append("e.tool_creator as tool_creator");
		hql.append(") from CheckJobInfoVo e where e.delete_flag=0 and e.job_type=2 and e.appsys_code in :sysList ");
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
		//判断当前用户是否是一线
		Set<Role> userRole = securityUtils.getUser().getRoles() ;
		boolean frontlineFlag= false;
		for (Role role : userRole) {
			if(role.getName().indexOf(frontFlag) != -1){
				frontlineFlag = true;
			}
		}
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CheckJobInfoVo e where e.delete_flag=0 and e.job_type=2 and e.appsys_code in :sysList ");
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
	 * 保存作业基本信息、组件联信息、时间表信息
	 * @param checkJobInfo 作业基本信息实体
	 * @param serverips 作业关联的组件服务器
	 * @param checkJobTimer 作业关联的时间表基本信息
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public String createAppJob(CheckJobInfoVo checkJobInfo,String serverips,CheckJobTimerVo checkJobTimer,String timersOnce 
			,String timersDaily,String timersWeekly,String timersMonthly,String timersInterval,String shPathParam) throws AxisFault,Exception{
		Date startDate = new Date();
		String saveFlag = "" ; //保存状态
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		Boolean bsaSaveFlag = true ; //BSAAPI调用状态（为true时才执行JEDA的数据库操作）

		//设置基本属性
		String jobName = checkJobInfo.getJob_name();
		String scriptName = checkJobInfo.getScript_name();
		String appsysCode = checkJobInfo.getAppsys_code();
		String job_path = "/"+checkPath+"/"+appsysCode+"/"+checkJobInfo.getField_type();
		checkJobInfo.setDelete_flag("0");
		checkJobInfo.setJob_path(job_path);
		checkJobInfo.setJob_type("2"); //作业类型 1-系统巡检 2-应用巡检
		String username = securityUtils.getUser().getUsername() ;  //用户账号
		if(username!=null && !username.equals("")){
			checkJobInfo.setTool_creator(username);
		}
		
		/* ---------------- BSA创建nsh作业 begin --------------*/
		//如果.sh文件存在时替换脚本
		String toolNshScriptName = "DepotScriptUpload.nsh";
		//替换脚本的位置
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		//nsh脚本名字
		String nshName=scriptName.substring(0,scriptName.indexOf(".")).concat(".nsh");
		//创建替换脚本的临时作业文件夹名
		String tempPath = "TOOLS";
		//替换脚本创建的作业名字
		String toolJobName = toolNshScriptName.substring(0,toolNshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		//sh放到服务器中的路径
		String path="";
		if(ComUtil.isWindows){
			path=shPathParam.replace(":", "").replace("\\", "/");
		}else{
			path=shPathParam.substring(1);
		}
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		//给sh替换脚本附第一个参数(服务器文件存在的路径)
		String filePath="//"+ip+"/"+path;
		//构建depot目录下的check子目录
		Boolean b1 = createCheckPathForDepot(appsysCode);
		if(!b1){
			bsaSaveFlag = false ;
			logger.info("depot目录构建失败！");
		}
		//获取文件DbKey判断.sh文件是否存在
		String fileexist=(String) getFileDbKey(appsysCode, shPath, fileType, scriptName);
		//该文件夹不存在
		if(fileexist.equals("void")){
			//将.sh文件上传到bsa
			Boolean b2 = uploadShFileToBsa(appsysCode,scriptName,path,ip);
			if(!b2){
				bsaSaveFlag = false ;
				logger.info("sh文件上传失败！");
			}
		}else{
			//创建临时作业存放路路径
			String nshToolsGroup=(String)jobGroupExists(appsysCode, tempPath);
			if(nshToolsGroup.equals("false")){
				createJobGroup(appsysCode, tempPath);
			}
			//创建替换.sh脚本的临时作业
			String DbKey1 = (String)createToolJob(appsysCode,tempPath,toolJobName,toolNshScriptPath,toolNshScriptName,bsaServer);
			if(DbKey1.equals("void")){
				bsaSaveFlag = false ;
			}
			//给临时作业附参数
			String DbKey2 = (String)addToolJobParam(filePath,toolJobName,appsysCode,shPath,tempPath,scriptName);
			if(DbKey2.equals("void")){
				bsaSaveFlag = false ;
			}
			//获取临时作业的DbKey
			String nshJobDbkey=(String) getTempJobDbKey(toolJobName, appsysCode, tempPath);
			if(nshJobDbkey.equals("void")){
				bsaSaveFlag = false ;
			}
			//执行临时作业
			String DbKey3 = (String)exceNshJob(nshJobDbkey);
			if(DbKey3.equals("void")){
				bsaSaveFlag = false ;
			}
			//删除临时作业
			Boolean b3 = deleteTempJob(appsysCode,tempPath,toolJobName);
			if(!b3){
				bsaSaveFlag = false ;
			}
		}
		//取sh文件的DbKey
		String shDbKey=(String) getFileDbKey(appsysCode,shPath,fileType,scriptName);
		if(shDbKey.equals("void")){
			bsaSaveFlag = false ;
			logger.info("获取sh文件DBKey失败！");
		}
		//策略
		applyAclPolicy(shDbKey,appsysCode);
		//先写入一个nsh文件
		Object nshContent = writeNshText();
		File file = new File(shPathParam);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPathParam.concat(File.separator).concat(nshName)),"utf-8"));
		out.println(nshContent);
		out.flush();
		out.close();
		//把nsh文件添加到bsa
		uploadNshFileToBsa(appsysCode,nshName,path,ip);
		//nsh文件DbKey
		String nshDbKey=(String) getFileDbKey(appsysCode,nshPath,nshFileType, nshName);
		//策略
		applyAclPolicy(nshDbKey,appsysCode);
		
		//给nsh添加参数
		addParamToNshScript(appsysCode,nshName,checkJobInfo);
		//创建BSA作业存放目录
		jobDesignService.addJobPath(appsysCode,checkJobInfo.getField_type());
		//获取作业DBKey - 判断同名作业是否已存在,存在则先删除
		String nshJobDbkey = "";
		nshJobDbkey = (String)getNshJobDbKey(checkJobInfo.getJob_name(),checkJobInfo.getAppsys_code(),checkJobInfo.getField_type());
		if(!nshJobDbkey.equals("void")  && !nshJobDbkey.equals("")){
			deleteJobByGroupAndName(checkJobInfo.getAppsys_code(),checkJobInfo.getField_type(),checkJobInfo.getJob_name());
		}
		//新增nsh作业
		nshJobDbkey = (String) createNshScriptJob(appsysCode,nshName,jobName,checkJobInfo.getField_type());
		if(nshJobDbkey.equals("void") || nshJobDbkey.equals("")){
			bsaSaveFlag = false ;
			logger.info("nsh作业创建失败！");
		}
		//给作业附策略
		String DBKey5 = (String)applyJobAclPolicy(nshJobDbkey,appsysCode);
		if(DBKey5.equals("void")){
			bsaSaveFlag = false ;
			logger.info("nsh作业授权失败！");
		}
		/* ---------------- BSA创建nsh作业 end --------------*/
		
		/* ---------------- 给nsh作业增加目标服务器 begin -------------*/
		//作业组件实体列表
		List<CheckJobServerVo> checkJobServers = new ArrayList<CheckJobServerVo>();
		List<Map<String, Object>> listServers = null ;
		CheckJobServerVo jobServerVo = null;
		if(serverips!=null && !serverips.equals("")){
			//将json格式的数据转换成list对象
			JSONArray arrayServers = JSONArray.fromObject(serverips);
			listServers = (List<Map<String, Object>>) JSONArray.toCollection(arrayServers, Map.class);
			for(Map<String, Object> map : listServers){
				jobServerVo = new CheckJobServerVo();
				jobServerVo.setAppsys_code(checkJobInfo.getAppsys_code());
				jobServerVo.setJob_code(checkJobInfo.getJob_code()); 
				jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("server_group")));
				jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("server_ip")));
				checkJobServers.add(jobServerVo);
			}
		}
		String servers = "" ; 
		if(serverips!=null && serverips.length()>0){
			if(checkJobServers!=null && checkJobServers.size()>0){
				for(int i=0 ;i<checkJobServers.size() ;i++){
					CheckJobServerVo cjsv = checkJobServers.get(i);
					servers = servers + cjsv.getServer_name()+"," ;
				}
				servers = servers.substring(0,servers.length()-1);
			}
		}
		if(servers!=null && !servers.equals("")){
			String nshJobDbkey2 = (String)getNshJobDbKey(jobName,appsysCode,checkJobInfo.getField_type());
			Boolean b4 = addTargrtServers(nshJobDbkey2,servers);
			if(!b4){
				bsaSaveFlag = false ;
				logger.info("目标服务器增加失败！");
			}
		}
		/* ---------------- 给nsh作业增加目标服务器 end -------------*/
		
		//给nsh作业增加时间表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		checkJobTimers = addJobTimers(checkJobInfo,checkJobTimer,timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
		
		//BSA操作成功后执行JEDA相关数据的保存
		if(bsaSaveFlag){
			jobDesignService.saveJobInfo(checkJobInfo);
			//插入作业、组件关联关系
			if(checkJobServers!=null && checkJobServers.size()>0){
				List<CheckJobServerVo> jobServers = new ArrayList<CheckJobServerVo>();
				for(CheckJobServerVo cjsv : checkJobServers){
					cjsv.setJob_code(checkJobInfo.getJob_code());
					jobServers.add(cjsv);
				}
				jobDesignService.saveJobServers(jobServers);
			}
			//插入作业时间表
			if(checkJobTimers!=null && checkJobTimers.size()>0){
				for(CheckJobTimerVo cjtv : checkJobTimers){
					cjtv.setJob_code(checkJobInfo.getJob_code());
					jobDesignService.saveJobTimer(cjtv);
				}
			}
			saveFlag = "success" ;
		}
		
		//插入执行日志表
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(checkJobInfo.getAppsys_code());
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(checkJobInfo.getJob_name()+"_create");
		cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		String endTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(endTime) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		Long logJnlNo = cmnLogService.save(cmnLog);
		
		//插入详细日志表
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
		Timestamp timestamp = Timestamp.valueOf(endTime) ;
		cdlv.setExecCompletedTime(timestamp);
		cdlv.setExecCreatedTime(timestamp);
		cdlv.setExecUpdatedTime(timestamp);
		cmnDetailLogService.save(cdlv);
		return saveFlag;
	}
	
	/**
	 * 修改作业基本信息、时间表信息、组件关联信息(模板暂时不支持修改)
	 * @param checkJobInfo 作业基本信息
	 * @param checkJobTimer 作业时间表
	 * @param serverips 作业关联的目标服务器
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public String updateAppJob(CheckJobInfoVo checkJobInfo, String serverips,CheckJobTimerVo checkJobTimer
			,String timersOnce,String timersDaily,String timersWeekly,String timersMonthly
			,String timersInterval,String shPathParam,Boolean newSh) throws AxisFault,Exception{
		Date startDate = new Date();
		String saveFlag = "" ; //保存状态
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		Boolean bsaSaveFlag = true ; //BSAAPI调用状态（为true时才执行JEDA的数据库操作）

		//设置基本属性
		String jobName = checkJobInfo.getJob_name();
		String scriptName = checkJobInfo.getScript_name();
		String appsysCode = checkJobInfo.getAppsys_code(); 
		String job_path = checkJobInfo.getJob_path();
		
		//nsh脚本名字
		String nshName=scriptName.substring(0,scriptName.indexOf(".")).concat(".nsh");
		if(newSh){ //重新上传脚本
			//删除以前创建的nsh作业
			Boolean b = deleteNshJob(job_path,jobName);
			if(!b){
				bsaSaveFlag = false ;
				logger.info("nsh作业删除失败！"); 
			}
			/* ---------------- BSA创建nsh作业 begin --------------*/
			//如果.sh文件存在时替换脚本
			String toolNshScriptName = "DepotScriptUpload.nsh";
			//替换脚本的位置
			String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
			//创建替换脚本的临时作业文件夹名
			String tempPath = "TOOLS";
			//替换脚本创建的作业名字
			String toolJobName = toolNshScriptName.substring(0,toolNshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
			//bsa服务器的ip
			String bsaServer = messages.getMessage("bsa.ipAddress");
			//sh放到服务器中的路径
			String path="";
			if(ComUtil.isWindows){
				path=shPathParam.replace(":", "").replace("\\", "/");
			}else{
				path=shPathParam.substring(1);
			}
			//取服务器的ip
			String ip=messages.getMessage("systemServer.ip");
			//给sh替换脚本附第一个参数(服务器文件存在的路径)
			String filePath="//"+ip+"/"+path;
			//通过获取文件DbKey判断.sh文件是否存在
			String fileexist=(String) getFileDbKey(appsysCode, shPath, fileType, scriptName);
			if(fileexist.equals("void")){ //该文件不存在
				//将.sh文件上传到bsa
				Boolean b2 = uploadShFileToBsa(appsysCode,scriptName,path,ip);
				if(!b2){
					bsaSaveFlag = false ;
					logger.info("sh文件上传失败！");
				}
			}else{
				//创建临时作业存放路路径
				String nshToolsGroup=(String)jobGroupExists(appsysCode, tempPath);
				if(nshToolsGroup.equals("false")){
					createJobGroup(appsysCode, tempPath);
				}
				//创建替换.sh脚本的临时作业
				String DbKey1 = (String)createToolJob(appsysCode,tempPath,toolJobName,toolNshScriptPath,toolNshScriptName,bsaServer);
				if(DbKey1.equals("void")){
					bsaSaveFlag = false ;
				}
				//给临时作业附参数
				String DbKey2 = (String)addToolJobParam(filePath,toolJobName,appsysCode,shPath,tempPath,scriptName);
				if(DbKey2.equals("void")){
					bsaSaveFlag = false ;
				}
				//获取临时作业的DbKey
				String nshJobDbkey=(String) getTempJobDbKey(toolJobName, appsysCode, tempPath);
				if(nshJobDbkey.equals("void")){
					bsaSaveFlag = false ;
				}
				//执行临时作业
				String DbKey3 = (String)exceNshJob(nshJobDbkey);
				if(DbKey3.equals("void")){
					bsaSaveFlag = false ;
				}
				//删除临时作业
				Boolean b3 = deleteTempJob(appsysCode,tempPath,toolJobName);
				if(!b3){
					bsaSaveFlag = false ;
				}
			}
			//取sh文件的DbKey
			String shDbKey=(String) getFileDbKey(appsysCode,shPath,fileType,scriptName);
			if(shDbKey.equals("void")){
				bsaSaveFlag = false ;
				logger.info("获取sh文件DBKey失败！");
			}
			//策略
			applyAclPolicy(shDbKey,appsysCode);
			//先写入一个nsh文件
			Object nshContent = writeNshText();
			File file = new File(shPathParam);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPathParam.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshContent);
			out.flush();
			out.close();
			//把nsh文件添加到bsa
			uploadNshFileToBsa(appsysCode,nshName,path,ip);
			//nsh文件DbKey
			String nshDbKey=(String) getFileDbKey(appsysCode,nshPath,nshFileType, nshName);
			//策略
			applyAclPolicy(nshDbKey,appsysCode);
			
			//给nsh添加参数
			addParamToNshScript(appsysCode,nshName,checkJobInfo);
			//新增nsh作业
			String nshJobDbkey = (String) createNshScriptJob(appsysCode,nshName,jobName,checkJobInfo.getField_type());
			if(nshJobDbkey.equals("void")){
				bsaSaveFlag = false ;
				logger.info("nsh作业创建失败！");
			}
			//给作业附策略
			String DBKey5 = (String)applyJobAclPolicy(nshJobDbkey,appsysCode);
			if(DBKey5.equals("void")){
				bsaSaveFlag = false ;
				logger.info("nsh作业授权失败！");
			}
			/* ---------------- BSA创建nsh作业 end --------------*/
		}else{ //未重新上传脚本
			//给nsh添加参数
			addParamToNshScript(appsysCode,nshName,checkJobInfo);
		}
		
		/* ---------------- 给nsh作业增加目标服务器 begin -------------*/
		//作业组件实体列表
		List<CheckJobServerVo> checkJobServers = new ArrayList<CheckJobServerVo>();
		List<Map<String, Object>> listServers = null ;
		CheckJobServerVo jobServerVo = null;
		if(serverips!=null && !serverips.equals("")){
			//将json格式的数据转换成list对象
			JSONArray arrayServers = JSONArray.fromObject(serverips);
			listServers = (List<Map<String, Object>>) JSONArray.toCollection(arrayServers, Map.class);
			for(Map<String, Object> map : listServers){
				jobServerVo = new CheckJobServerVo();
				jobServerVo.setAppsys_code(checkJobInfo.getAppsys_code());
				jobServerVo.setJob_code(checkJobInfo.getJob_code()); 
				jobServerVo.setServer_path(ComUtil.checkJSONNull(map.get("server_path")));
				jobServerVo.setServer_name(ComUtil.checkJSONNull(map.get("server_name")));
				checkJobServers.add(jobServerVo);
			}
		}
		String servers = "" ; 
		if(serverips!=null && serverips.length()>0){
			if(checkJobServers!=null && checkJobServers.size()>0){
				for(int i=0 ;i<checkJobServers.size() ;i++){
					CheckJobServerVo cjsv = checkJobServers.get(i);
					servers = servers + cjsv.getServer_name()+"," ;
				}
				servers = servers.substring(0,servers.length()-1);
			}
		}
		if(servers!=null && !servers.equals("")){
			String nshJobDbkey1 = (String)getNshJobDbKey(jobName,appsysCode,checkJobInfo.getField_type());
			Boolean b1 = clearTargrtServers(nshJobDbkey1);
			if(!b1){
				bsaSaveFlag = false ;
				logger.info("清空目标服务器失败！");
			}
			String nshJobDbkey2 = (String)getNshJobDbKey(jobName,appsysCode,checkJobInfo.getField_type());
			Boolean b2 = addTargrtServers(nshJobDbkey2,servers);
			if(!b2){
				bsaSaveFlag = false ;
				logger.info("增加目标服务器失败！");
			}
		}
		/* ---------------- 给nsh作业增加目标服务器 end -------------*/
		
		//清空作业时间表
		String nshJobDbkey = (String)getNshJobDbKey(jobName,appsysCode,checkJobInfo.getField_type());
		Boolean b = clearJobTimers(nshJobDbkey);
		if(!b){
			bsaSaveFlag = false ;
			logger.info("清空作业时间表失败！");
		}
		//增加作业时间表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		checkJobTimers = addJobTimers(checkJobInfo,checkJobTimer,timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
		
		//BSA操作成功后执行JEDA相关数据的保存
		if(bsaSaveFlag){
			jobDesignService.updateJobInfo(checkJobInfo);
			//删除以前的组件关联数据
			jobDesignService.deleteAllServers(checkJobInfo.getJob_code()); 
			//插入作业、组件关联关系
			if(checkJobServers!=null && checkJobServers.size()>0){
				List<CheckJobServerVo> jobServers = new ArrayList<CheckJobServerVo>();
				for(CheckJobServerVo cjsv : checkJobServers){
					cjsv.setJob_code(checkJobInfo.getJob_code());
					jobServers.add(cjsv);
				}
				jobDesignService.saveJobServers(jobServers);
			}
			//删除以前的时间表数据
			jobDesignService.deleteTimer(checkJobInfo.getJob_code()); 
			//插入作业时间表
			if(checkJobTimers!=null && checkJobTimers.size()>0){
				for(CheckJobTimerVo cjtv : checkJobTimers){
					cjtv.setJob_code(checkJobInfo.getJob_code());
					jobDesignService.saveJobTimer(cjtv);
				}
			}
			saveFlag = "success" ;
		}
		
		//插入执行日志表
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(checkJobInfo.getAppsys_code());
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(checkJobInfo.getJob_name()+"_update");
		cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		String endTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(endTime) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		Long logJnlNo = cmnLogService.save(cmnLog);
		
		//插入详细日志表
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
		Timestamp timestamp = Timestamp.valueOf(endTime) ;
		cdlv.setExecCompletedTime(timestamp);
		cdlv.setExecCreatedTime(timestamp);
		cdlv.setExecUpdatedTime(timestamp);
		cmnDetailLogService.save(cdlv);

		return saveFlag ;
	}
	
	/**
	 * 读取上传脚本内容
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object readText(String nshJobFilePath,CheckJobInfoVo checkJobInfoVo) throws Exception {
		int b;
		File file = new File(nshJobFilePath);
		FileInputStream in=new FileInputStream(file);
		StringBuilder Nr=new StringBuilder();
		InputStreamReader br = null;
		String type=checkJobInfoVo.getLanguage_type();
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
	 * 构建DEPOT目录下的CHECK子目录并设定策略
	 * @param appsysCode 应用系统编号
	 * @throws Exception
	 * @throws JEDAException
	 */
	public boolean createCheckPathForDepot(String appsysCode) throws Exception {
		Boolean flag = true ;
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
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		String aclPolicyAll = "PLCY_ALL_ROOT"; 
		String aclPolicy = "PLCY_" + appsysCode + "_APPADMIN";
		//判断CHECK目录是否存在
		ExecuteCommandByParamListResponse group1 = client.executeCommandByParamList("DepotGroup","groupExists",new String[] {"/"+checkPath});
		String isExist1 = (String) group1.get_return().getReturnValue();
		if(isExist1.equals("false")){
			ExecuteCommandByParamListResponse cliResponse11 = client.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] {checkPath,"/"});
			if(!cliResponse11.get_return().getSuccess()){
				flag = false ;
			}
			ExecuteCommandByParamListResponse cliResponse12 = client.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{ "/"+checkPath,aclPolicyAll});
			if(!cliResponse12.get_return().getSuccess()){
				flag = false ;
			}
		}
		//判断CHECK下的应用系统目录是否存在
		ExecuteCommandByParamListResponse group2 = client.executeCommandByParamList("DepotGroup","groupExists",new String[] { "/"+checkPath+"/"+appsysCode});
		String isExist2 = (String) group2.get_return().getReturnValue();
		if(isExist2.equals("false")){
			ExecuteCommandByParamListResponse cliResponse21 = client.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] {appsysCode,"/"+checkPath});
			if(!cliResponse21.get_return().getSuccess()){
				flag = false ;
			}
			ExecuteCommandByParamListResponse cliResponse22 = client.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{ "/"+checkPath+"/"+appsysCode,aclPolicy});
			if(!cliResponse22.get_return().getSuccess()){
				flag = false ;
			}
		}
		//判断应用系统下的SCRIPTS目录是否存在
		ExecuteCommandByParamListResponse group3 = client.executeCommandByParamList("DepotGroup","groupExists",new String[] { "/"+checkPath+"/"+appsysCode+"/"+shPath});
		String isExist3 = (String) group3.get_return().getReturnValue();
		if(isExist3.equals("false")){
			ExecuteCommandByParamListResponse cliResponse31 = client.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] {shPath,"/"+checkPath+"/"+appsysCode});
			if(!cliResponse31.get_return().getSuccess()){
				flag = false ;
			}
			ExecuteCommandByParamListResponse cliResponse32 = client.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{ "/"+checkPath+"/"+appsysCode+"/"+shPath,aclPolicy});
			if(!cliResponse32.get_return().getSuccess()){
				flag = false ;
			}
		}
		//判断应用系统下的NSHELLS目录是否存在
		ExecuteCommandByParamListResponse group4 = client.executeCommandByParamList("DepotGroup","groupExists",new String[] { "/"+checkPath+"/"+appsysCode+"/"+nshPath});
		String isExist4 = (String) group4.get_return().getReturnValue();
		if(isExist4.equals("false")){
			ExecuteCommandByParamListResponse cliResponse41 = client.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] {nshPath,"/"+checkPath+"/"+appsysCode});
			if(!cliResponse41.get_return().getSuccess()){
				flag = false ;
			}
			ExecuteCommandByParamListResponse cliResponse42 = client.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{ "/"+checkPath+"/"+appsysCode+"/"+nshPath,aclPolicy});
			if(!cliResponse42.get_return().getSuccess()){
				flag = false ;
			}
		}
		return flag ;
	}
	
	/**
	 * 上传.sh脚本
	 * @param shJia 
	 * @param serverName 
	 * @param appsysCode 
	 * @param jobName 
	 * @param ip 
	 * @param path 
	 * @param ip 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Boolean uploadShFileToBsa(String appsysCode,String scriptName, String path, String ip) throws Exception {
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
		//上传
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = jobParentGroupName.executeCommandByParamList("DepotFile","addFileToDepot",new String[] {"/"+checkPath+"/"+appsysCode+"/"+shPath,"//"+ip+"/"+path+"/"+scriptName,scriptName," "});
		return cliResponse.get_return().getSuccess();
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
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object uploadNshFileToBsa(String appsysCode,String nshName,String path,String ip) throws Exception {
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
		//上传
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScript","addNSHScriptToDepotByGroupName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath+"","2","//"+ip+"/"+path+"/"+nshName+"",""+nshName+""," "});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 取sh文件的DbKey(Depot)
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getFileDbKey(String appsysCode,String filePath,String fileType,String fileName) throws Exception {
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
		// 取得服务分组名
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","getDBKeyByTypeStringGroupAndName",new String[] { fileType,"/"+checkPath+"/"+appsysCode+"/"+filePath,fileName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * DepotObject策略
	 * @throws NoSuchMessageException 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object applyAclPolicy( String shDbKey,String appsysCode) throws NoSuchMessageException, Exception {
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
		String plcy="PLCY_"+appsysCode+"_APPADMIN";
		//策略
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","applyAclPolicy",new String[] {""+shDbKey+"",""+plcy+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 新建一个nshJob
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object createNshScriptJob(String appsysCode,String nshName,String jobName,String fieldType) throws Exception {
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
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",
				new String[] {"/"+checkPath+"/"+appsysCode+"/"+fieldType,jobName," ","/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"3"});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 获取NshJob的DbKey
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getNshJobDbKey(String jobName,String appsysCode,String fieldType) throws Exception {
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
		//获取作业的BDKey
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",
				new String[] {"/"+checkPath+"/"+appsysCode+"/"+fieldType,jobName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 获取临时作业的DbKey
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getTempJobDbKey(String jobName,String appsysCode,String tempPath) throws Exception {
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
		//获取作业的BDKey
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",
				new String[] {"/CHECK/"+appsysCode+"/"+tempPath,jobName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * NSH作业附策略
	 * @throws NoSuchMessageException 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object applyJobAclPolicy(String shDbKey,String appsysCode) throws NoSuchMessageException, Exception {
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
		String plcy="PLCY_"+appsysCode+"_APPADMIN";
		//授权
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","applyAclPolicy",new String[] {shDbKey,plcy});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 写nsh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object writeNshText() throws Exception {
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		nshFile.append("SourceFilePath=$1").append(crlf);
		nshFile.append("FileName=$2").append(crlf);
		nshFile.append("Exec_Path=$3").append(crlf);
		nshFile.append("Exec_User=$4").append(crlf);
		nshFile.append("User_Group=$5").append(crlf);
		nshFile.append("APPSERVERIP=$6").append(crlf);
		nshFile.append("FtpServerIp=$7").append(crlf);
		nshFile.append("FtpUser=$8").append(crlf);
		nshFile.append("FtpPwd=$9").append(crlf);
		nshFile.append("FtpPath=$10").append(crlf);
		nshFile.append(crlf);
		nshFile.append("nsh -c \"//$APPSERVERIP/bbsa/blstorage/scripts/filepush.nsh $SourceFilePath $FileName $Exec_Path\"");
		nshFile.append(crlf);
		nshFile.append("nexec -l -e \"cd $Exec_Path;chown $Exec_User:$User_Group $FileName ;chmod a+x $FileName\"");
		nshFile.append(crlf);
		nshFile.append("nexec -l -e su - $Exec_User -c \"export FtpServerIp=$7;export FtpUser=$8;export FtpPwd=$9;export FtpPath=${10};cd $Exec_Path;sh $FileName\"");
		nshFile.append(crlf);
		nshFile.append("if [ $? != 0 ];");
		nshFile.append(crlf);
		nshFile.append("then");
		nshFile.append(crlf);
		nshFile.append("exit 151");
		nshFile.append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	/**
	 * 给nsh脚本附加参数值
	 * @throws Exception
	 * @throws JEDAException;
	 */
	private void addParamToNshScript(String appsysCode,String nshName,CheckJobInfoVo checkJobInfoVo) throws Exception {
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
		//参数取值
		String param1 = "/"+checkPath+"/"+appsysCode+"/"+shPath;
		String param2 = checkJobInfoVo.getScript_name();
		String param3 = checkJobInfoVo.getExec_path();
		String param4 = checkJobInfoVo.getExec_user();
		String param5 = checkJobInfoVo.getExec_user_group();
		String param6 = "??TARGET.ATTR_APPCHECK.AppServerIp??";
		String param7 = "??TARGET.ATTR_APPCHECK.FtpServerIp??";
		String param8 = "??TARGET.ATTR_APPCHECK.FtpUser??";
		String param9 = "??TARGET.ATTR_APPCHECK.FtpPwd??";
		String param10 = "??TARGET.ATTR_APPCHECK.FtpPath??";
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		//清空参数值
		cliClient.executeCommandByParamList("NSHScript","clearNSHScriptParametersByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName});
        //参数赋值
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"SourceFilePath"," ",param1,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"FileName"," "," ",param2,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"Exec_Path"," "," ",param3,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"Exec_User"," "," ",param4,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"User_Group"," "," ",param5,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"APPSERVERIP"," "," ",param6,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"FtpServerIp"," "," ",param7,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"FtpUser"," "," ",param8,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"FtpPwd"," "," ",param9,"7"});
		cliClient.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/"+nshPath,nshName,"FtpPath"," "," ",param10,"7"});
	}
	/**
	 * 创建TOOLS临时作业
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createToolJob(String appsysCode,String tempPath,String toolJobName,String toolNshScriptPath,String toolNshScriptName,String bsaServer) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName," ",toolNshScriptPath,toolNshScriptName,bsaServer,"10"});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 给临时作业附参数
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam(String filePath,String toolJobName,String appsysCode,String shPath,String tempPath,String jobName) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName});
		jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName,"0",filePath});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName,"1",jobName});
		jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName,"2","/"+checkPath+"/"+appsysCode+"/"+shPath});
		jobParentGroupNames2.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 执行NshJob
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] {nshJobDbkey});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 删除临时作业
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Boolean deleteTempJob(String appsysCode,String tempPath,String toolJobName) throws Exception {
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
		//删除
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName});
		return cliResponse.get_return().getSuccess();
	}
	
	/**
	 * 清除作业关联的目标服务器
	 * @param nshJobDbkey 作业BDKey
	 * @throws Exception
	 */
	public Boolean clearTargrtServers(String nshJobDBKey) throws Exception {
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
		//增加目标服务器
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("Job", "clearTargetServers", new String[]{nshJobDBKey});
		return cliResponse.get_return().getSuccess();
	}
	
	/**
	 * 作业增加目标服务器
	 * @param nshJobDbkey 作业BDKey
	 * @param servers 目标服务器
	 * @throws Exception
	 */
	public Boolean addTargrtServers(String nshJobDBkey,String servers) throws Exception {
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
		//增加目标服务器
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("Job", "addTargetServers",new String[]{nshJobDBkey,servers});
		return cliResponse.get_return().getSuccess();
	}
	
	/**
	 * 清除作业时间表
	 * @param nshJobDbkey 作业BDKey
	 * @throws Exception
	 */
	public Boolean clearJobTimers(String nshJobDBKey) throws Exception {
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
		//增加目标服务器
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("Job", "removeAllSchedules", new String[]{nshJobDBKey});
		return cliResponse.get_return().getSuccess();
	}
	
	/**
	 * 增加作业时间表
	 * @param nshJobDbkey 作业BDKey
	 * @param servers 目标服务器
	 * @throws Exception
	 * @throws JEDAException
	 */
	public List<CheckJobTimerVo> addJobTimers(CheckJobInfoVo checkJobInfo,CheckJobTimerVo checkJobTimer,String timersOnce 
			,String timersDaily,String timersWeekly,String timersMonthly,String timersInterval) throws Exception {
		//作业时间表列表
		List<CheckJobTimerVo> checkJobTimers = new ArrayList<CheckJobTimerVo>();
		
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
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		
		String priority = "" ; //执行优先级
		String recipient = "" ; //邮件地址
		Boolean mailflag = false ;
		if(checkJobTimer.getExec_priority()!=null){
			priority = checkJobTimer.getExec_priority();
		}
		if(checkJobTimer.getExec_notice_mail_list()!=null){
			recipient = checkJobTimer.getExec_notice_mail_list() ;
		}
		if(recipient!=null && !recipient.equals("")){
			mailflag = true ;
		}
		//获取作业DBKey
		String nshJobDbkey = (String)getNshJobDbKey(checkJobInfo.getJob_name(),checkJobInfo.getAppsys_code(),checkJobInfo.getField_type());
		//增加时间表
		if(checkJobInfo.getAuthorize_lever_type().equals("1")){ 
			if(timersOnce!=null && !timersOnce.equals("")){
				String[] timers = timersOnce.split(",");
				String date = "" ;
				String time = "" ;
				for(String timer : timers){
					int mailStatusVal = 0 ; //邮件状态值(BSA传值)
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
					if(mailflag){
						cjtv.setExec_notice_mail_list(recipient);
						if(checkJobTimer.getMail_success_flag()!=null && !checkJobTimer.getMail_success_flag().equals("")){
							cjtv.setMail_success_flag("1");
							mailStatusVal = mailStatusVal + 2 ;
						}
						if(checkJobTimer.getMail_failure_flag()!=null && !checkJobTimer.getMail_failure_flag().equals("")){
							cjtv.setMail_failure_flag("1");
							mailStatusVal = mailStatusVal + 4 ;
						}
						if(checkJobTimer.getMail_cancel_flag()!=null && !checkJobTimer.getMail_cancel_flag().equals("")){
							cjtv.setMail_cancel_flag("1");
							mailStatusVal = mailStatusVal + 8 ;
						}
						cliClient.executeCommandByParamList("Job", "addOneTimeScheduleWithEMailNotificationAndPriority",
								new String[]{nshJobDbkey,timer,recipient,String.valueOf(mailStatusVal),priority});
					}else{
						cliClient.executeCommandByParamList("Job", "addOneTimeScheduleWithPriority",
								new String[]{nshJobDbkey,timer,priority});
					}
					checkJobTimers.add(cjtv);
				}
			}
			if(timersDaily!=null && !timersDaily.equals("")){
				String[] timers = timersDaily.split(",");
				String date = "" ;
				String time = "" ;
				for(String timer : timers){
					int mailStatusVal = 0 ; //邮件状态值(BSA传值)
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
					if(mailflag){
						cjtv.setExec_notice_mail_list(recipient);
						if(checkJobTimer.getMail_success_flag()!=null && !checkJobTimer.getMail_success_flag().equals("")){
							cjtv.setMail_success_flag("1");
							mailStatusVal = mailStatusVal + 2 ;
						}
						if(checkJobTimer.getMail_failure_flag()!=null && !checkJobTimer.getMail_failure_flag().equals("")){
							cjtv.setMail_failure_flag("1");
							mailStatusVal = mailStatusVal + 4 ;
						}
						if(checkJobTimer.getMail_cancel_flag()!=null && !checkJobTimer.getMail_cancel_flag().equals("")){
							cjtv.setMail_cancel_flag("1");
							mailStatusVal = mailStatusVal + 8 ;
						}
						cliClient.executeCommandByParamList("Job", "addDailyScheduleWithEMailNotificationAndPriority",
								new String[]{nshJobDbkey,timer,recipient,String.valueOf(mailStatusVal),priority});
					}else{
						cliClient.executeCommandByParamList("Job", "addDailyScheduleWithPriority",
								new String[]{nshJobDbkey,timer,priority});
					}
					checkJobTimers.add(cjtv);
				}
			}
			if(timersWeekly!=null && !timersWeekly.equals("")){
				String[] timers = timersWeekly.split(",");
				String date = "" ;
				String time = "" ;
				for(String timer : timers){
					int mailStatusVal = 0 ; //邮件状态值(BSA传值)
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
					if(mailflag){
						cjtv.setExec_notice_mail_list(recipient);
						if(checkJobTimer.getMail_success_flag()!=null && !checkJobTimer.getMail_success_flag().equals("")){
							cjtv.setMail_success_flag("1");
							mailStatusVal = mailStatusVal + 2 ;
						}
						if(checkJobTimer.getMail_failure_flag()!=null && !checkJobTimer.getMail_failure_flag().equals("")){
							cjtv.setMail_failure_flag("1");
							mailStatusVal = mailStatusVal + 4 ;
						}
						if(checkJobTimer.getMail_cancel_flag()!=null && !checkJobTimer.getMail_cancel_flag().equals("")){
							cjtv.setMail_cancel_flag("1");
							mailStatusVal = mailStatusVal + 8 ;
						}
						cliClient.executeCommandByParamList("Job", "addWeeklyScheduleWithEMailNotificationAndPriority",
								new String[]{nshJobDbkey,dateTime,weekFreq,daysOfWeek,recipient,String.valueOf(mailStatusVal),priority});
					}else{
						cliClient.executeCommandByParamList("Job", "addWeeklyScheduleWithPriority",
								new String[]{nshJobDbkey,dateTime,weekFreq,daysOfWeek,priority});
					}
					checkJobTimers.add(cjtv);
				}
			}
			if(timersMonthly!=null && !timersMonthly.equals("")){
				String[] timers = timersMonthly.split(",");
				String date = "" ;
				String time = "" ;
				for(String timer : timers){
					int mailStatusVal = 0 ; //邮件状态值(BSA传值)
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
					if(mailflag){
						cjtv.setExec_notice_mail_list(recipient);
						if(checkJobTimer.getMail_success_flag()!=null && !checkJobTimer.getMail_success_flag().equals("")){
							cjtv.setMail_success_flag("1");
							mailStatusVal = mailStatusVal + 2 ;
						}
						if(checkJobTimer.getMail_failure_flag()!=null && !checkJobTimer.getMail_failure_flag().equals("")){
							cjtv.setMail_failure_flag("1");
							mailStatusVal = mailStatusVal + 4 ;
						}
						if(checkJobTimer.getMail_cancel_flag()!=null && !checkJobTimer.getMail_cancel_flag().equals("")){
							cjtv.setMail_cancel_flag("1");
							mailStatusVal = mailStatusVal + 8 ;
						}
						cliClient.executeCommandByParamList("Job", "addMonthlyScheduleWithEMailNotificationAndPriority",
								new String[]{nshJobDbkey,dateTime,daysOfMonth,recipient,String.valueOf(mailStatusVal),priority});
					}else{
						cliClient.executeCommandByParamList("Job", "addMonthlyScheduleWithPriority",
								new String[]{nshJobDbkey,dateTime,daysOfMonth,priority});
					}
					checkJobTimers.add(cjtv);
				}
			}
			if(timersInterval!=null && !timersInterval.equals("")){
				String[] timers = timersInterval.split(",");
				String date = "" ;
				String time = "" ;
				for(String timer : timers){
					int mailStatusVal = 0 ; //邮件状态值(BSA传值)
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
					if(mailflag){
						cjtv.setExec_notice_mail_list(recipient);
						if(checkJobTimer.getMail_success_flag()!=null && !checkJobTimer.getMail_success_flag().equals("")){
							cjtv.setMail_success_flag("1");
							mailStatusVal = mailStatusVal + 2 ;
						}
						if(checkJobTimer.getMail_failure_flag()!=null && !checkJobTimer.getMail_failure_flag().equals("")){
							cjtv.setMail_failure_flag("1");
							mailStatusVal = mailStatusVal + 4 ;
						}
						if(checkJobTimer.getMail_cancel_flag()!=null && !checkJobTimer.getMail_cancel_flag().equals("")){
							cjtv.setMail_cancel_flag("1");
							mailStatusVal = mailStatusVal + 8 ;
						}
						cliClient.executeCommandByParamList("Job", "addIntervalScheduleWithEMailNotification",
								new String[]{nshJobDbkey,dateTime,days,hours,mins,recipient,String.valueOf(mailStatusVal)});
					}else{
						cliClient.executeCommandByParamList("Job", "addIntervalSchedule",
								new String[]{nshJobDbkey,dateTime,days,hours,mins});
					}
					checkJobTimers.add(cjtv);
				}
			}
		}
		return checkJobTimers;
	}
	
	/**
	 * 根据编号批量删除,删除标识置1
	 * @param jobIds 作业编号数组
	 * @throws Exception 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void deleteJobByIds(Integer[] jobIds) throws Exception {
		String job_name = "";
		String job_path = "";
		String script_name = "";
		String appsys_code = "";
		Date date = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		for(int i=0;i<jobIds.length;i++) {
			String execdate = new SimpleDateFormat("yyyyMMdd").format(date) ;
			String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
			//作业基本信息
			int jobId = jobIds[i];
			CheckJobInfoVo job = (CheckJobInfoVo) jobDesignService.getJobById(jobId);
			job_name = job.getJob_name();
			job_path = job.getJob_path();
			script_name = job.getScript_name();
			appsys_code = job.getAppsys_code();
			//删除BSA上的脚本作业
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{job_path,job_name});
			//删除作业关联脚本
			deleteShFile("/"+checkPath+"/"+appsys_code+"/"+shPath,script_name);
			deleteNshFile("/"+checkPath+"/"+appsys_code+"/"+nshPath,script_name.replace(".sh", ".nsh"));
			//删除作业
			deleteJobById(jobId); 
			//日志处理
			CmnLogVo cmnLog = new CmnLogVo(); 
			cmnLog.setAppsysCode(job.getAppsys_code());
			cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
			cmnLog.setRequestName(job.getJob_name()+"_delete");
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
	 * 根据作业路径和名称删除BSA上的应用巡检作业
	 * @param appsysCode 系统编号
	 * @param fieldType 专业领域
	 * @param jobName 作业名称
	 * @throws Exception 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "dply")
	public void deleteJobByGroupAndName(String appsysCode,String fieldType,String jobName) throws Exception {
		
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
		//删除BSA作业
		CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",
				new String[] {"/"+checkPath+"/"+appsysCode+"/"+fieldType,jobName});
	}
	
	/**
	 * 根据编号删除作业,删除标识置1
	 * @param job_name 
	 * @param jobid 作业编号
	 */
	private void deleteJobById(Integer jobId) {
		getSession().createQuery("update CheckJobInfoVo e set e.delete_flag=1 where e.job_code=?").setString(0, jobId.toString()).executeUpdate();
	}
	
    /**
     * 根据应用系统、作业名称、作业类型、巡检方式、脚本名称判断该作业是否存在
     * @return 
     *      存在返回true , 不存在返回false 
     */
	public Boolean jobIsExist(String appsysCode,String jobName){
		Boolean b = false ;
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CHECK_JOB_INFO e where e.appsys_code=:appsysCode and e.job_name=:jobName and e.job_type = '2' and e.delete_flag = '0' ");
		Query query = getSession().createSQLQuery(hql.toString());
		query.setParameter("appsysCode", appsysCode);
		query.setParameter("jobName", jobName);
		Long num = Long.valueOf(query.uniqueResult().toString());
		if(num>0){
			b = true ;
		}
		return b ;
	}
	
	/**
	 * 根据应用系统和脚本名称获取BSA上的sh路径
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getShPath(CheckJobInfoVo checkJobInfoVo) throws AxisFault,SQLException, Exception {
		String appsysCode=checkJobInfoVo.getAppsys_code();
		String scriptName = checkJobInfoVo.getScript_name();
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
		//获取路径值
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","getLocationByGroupAndName",new String[] {"/"+checkPath+"/"+appsysCode+"/SCRIPTS",""+scriptName+""});
		String bsaShPath = (String) jobParentGroupNames.get_return().getReturnValue();
		return bsaShPath;
	}
	
	
	/**
	 * 执行临时脚本作业
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void exeTempJob(CheckJobInfoVo checkJobInfoVo,String basShPath,String resultPath) throws AxisFault,SQLException, Exception {
		String appsysCode=checkJobInfoVo.getAppsys_code();
		String nshScriptName="DepotFilecopy.nsh";
		//替换脚本的位置
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		//创建替换脚本的作业文件夹名
		String tempPath = "TOOLS";
		//替换脚本创建的作业名字
		String toolJobName = nshScriptName.substring(0,nshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		
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
		String nshToolsGroup=(String)jobGroupExists(appsysCode, tempPath);
		//存在该文件夹
		if(nshToolsGroup.equals("false")){
			createJobGroup(appsysCode, tempPath);
		}
		createToolJob(appsysCode,tempPath,toolJobName,toolNshScriptPath,nshScriptName,bsaServer);
		//清除参数
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName});
		jobParentGroupNames1.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName,"0",basShPath});
		jobParentGroupNames2.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/CHECK/"+appsysCode+"/"+tempPath,toolJobName,"1",resultPath});
		jobParentGroupNames3.get_return().getReturnValue();
		
		//获取作业的DbKey
		String nshJobDbkey=(String) getTempJobDbKey(toolJobName, appsysCode, tempPath);
		//执行作业
		exceNshJob(nshJobDbkey);
		//删除作业
		deleteTempJob(appsysCode,tempPath,toolJobName);
	}
	
	/**
	 * 删除nsh作业
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Boolean deleteNshJob(String jobPath,String jobName) throws Exception {
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
		//删除nsh作业
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {jobPath,jobName});
		return cliResponse.get_return().getSuccess();
	}
	
	/**
	 * 删除.sh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteShFile(String group,String scriptName) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DepotFile","deleteFileByGroupAndName",new String[] {"/"+group+"",scriptName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 删除.nsh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteNshFile(String group,String nshName) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","deleteNSHScriptByGroupAndName",new String[] {"/"+group+"",nshName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 检查CHECK目录下的子目录是否存在
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupExists(String appsysCode,String catalog) throws Exception {
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
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("JobGroup","groupExists",new String[] { "/CHECK/"+appsysCode+"/"+catalog});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	
	/**
	 * 创建CHECK子目录
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createJobGroup(String appsysCode,String catalog) throws Exception {
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
		ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("JobGroup","createGroupWithParentName",new String[] {catalog,"/CHECK/"+appsysCode});
		String value = (String) result.get_return().getReturnValue();
		return value;
	}
}




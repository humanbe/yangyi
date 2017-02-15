 package com.nantian.check.service;

import java.io.File;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.databinding.types.soapencoding.Array;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.CheckConstants;
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.check.vo.CheckJobLogInfoVo;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.dply.vo.AppGroupServerVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 初始化脚本执行
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class ScriptExecService {

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
	 private ScriptUploadService scriptUploadService;
    @Autowired
	private AppInfoService appInfoService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	private SecurityUtils securityUtils; 
    /**
     * 构造方法
     */
    public ScriptExecService() {
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
    	String deployValue=checkItemInfoVo.getDeployValue();
    	String scriptDeployValue=checkItemInfoVo.getScriptDeployValue();
    	List<String> list = new ArrayList<String>();
    	JSONArray checkInit = JSONArray.fromObject(scriptDeployValue);
		List<String> checkInitList = (List<String>) JSONArray.toCollection(checkInit, String.class);
		if(scriptDeployValue.length()>0){
			for (String param : checkInitList) {
				list.add(param);
			}
		}
		List<String> ipList = new ArrayList<String>();
    	JSONArray serverIp = JSONArray.fromObject(deployValue);
		List<String> serverIpList = (List<String>) JSONArray.toCollection(serverIp, String.class);
		if(deployValue.length()>0){
			for (String server : serverIpList) {
				ipList.add(server);
			}
		}
		StringBuffer sb= new StringBuffer();
		for(int i=0;i<ipList.size();i++){
			if(i==ipList.size()-1){
				sb.append(ipList.get(i));
			}else{
				sb.append(ipList.get(i)).append(",");
			}
		}
		String binScirptName=checkItemInfoVo.getBinScriptName();
		String itemNshName=binScirptName.substring(0,binScirptName.indexOf(".")).concat("_item.nsh");
		
		String osType=scriptUploadService.getOstype(checkItemInfoVo.getOsTypes());
		String fieldType=checkItemInfoVo.getFieldTypes();
		String jobGroup=CheckConstants.ChenkGroupName+"/"+osType;
		String execJobName="EXEC_"+itemNshName.substring(0, itemNshName.indexOf(".")).concat("_").concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String itemNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String jobDbKye=(String) createNshScriptJob(jobGroup, execJobName, itemNshGroup, itemNshName);
		addTargetServers(jobDbKye,sb.toString());
		//Job - addTargetServer
		addJobParam(jobGroup,execJobName,list);
		String jobDbKye1=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
		scriptUploadService.exceNshJob(jobDbKye1);
		String jobDbKye2=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
		applyJobAclPolicy(jobDbKye2, CheckConstants.celv);
		String jobDbKye3=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
		applyJobAclPolicy(jobDbKye3, CheckConstants.allSysadminCelv);
			//将作业信息入库
		saveJob(execJobName,jobGroup,itemNshName,jobDbKye1,"3");
		/*String jobName="OS_LINUX_COMPLIANCE";
		String jobGroup="/COMMON_CHECK/OS";
		String jobDbKey="DBKey:SJobModelKeyImpl:2011027-4-2288920";
		saveComplianceJob(jobName, jobGroup, jobDbKey, "1");*/
    }
    /**
	 * 保存作业信息

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
    public void saveJob(String jobName, String jobGroup,String scriptName,String jobDbKey,String jobType) throws Exception {
    	CheckJobLogInfoVo checkJobLogInfoVo=new CheckJobLogInfoVo();
    	String uuid = UUID.randomUUID().toString();
    	String runKey = (String) findLastRunKeyByJobKey(jobDbKey);
    	String runId = (String)jobRunKeyToJobRunId(runKey);
    	String status = (String) getJobRunHadErrors(runKey);
    	String username = securityUtils.getUser().getUsername();
    	String startTime = (String)getStartTimeByRunKey(runKey);
    	String endTime = (String)getEndTimeByRunKey(runKey);
    	String saJobPath="/tmp/"+jobName+".csv";
    	File outDir = new File(messages.getMessage("check.sysJobLogPathForLinux"));
		if (!outDir.exists()) {
			outDir.mkdirs();
		}
    	String copyLogName = "CopyJobLog.nsh";
    	String copyLogJobName="CopyJobLog".concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
    	String copyLogPath ="/BMC Maintenance/SysTools/filepush";
    	String copyFile = jobName.concat(".csv");
    	String copyTarget = "//"+messages.getMessage("systemServer.ip")+messages.getMessage("check.sysJobLogPathForLinux");
    	String jobDbKye=(String)createNshScriptJob(jobGroup, copyLogJobName, copyLogPath, copyLogName);
    	addTargetServers(jobDbKye,messages.getMessage("bsa.ipAddress"));
    	addJobParam1(jobGroup, copyLogJobName, runId,copyFile,copyTarget);
    	String jobDbKye1=(String) scriptUploadService.getNshJobDbKey(jobGroup, copyLogJobName);
		scriptUploadService.exceNshJob(jobDbKye1);
		deleteJob(jobGroup, copyLogJobName);
    	checkJobLogInfoVo.setGuId(uuid);
		checkJobLogInfoVo.setCheckJobName(jobName);
		if(status.equals("true")){
			checkJobLogInfoVo.setCheckJobStatus("失败");
		}else{
			checkJobLogInfoVo.setCheckJobStatus("成功");
		}
		checkJobLogInfoVo.setJobDbkey(jobDbKey);
		checkJobLogInfoVo.setJobRunDbkey(runKey);
		checkJobLogInfoVo.setJobRunId(runId);
		checkJobLogInfoVo.setCheckJobPath("/"+jobGroup);
		checkJobLogInfoVo.setScriptName(scriptName);
		checkJobLogInfoVo.setJobStartTime(Timestamp.valueOf(startTime.concat(".000").toString()));
		checkJobLogInfoVo.setJobEndTime(Timestamp.valueOf(endTime.concat(".000").toString()));
		checkJobLogInfoVo.setCheckJobExecuter(username);
		checkJobLogInfoVo.setJobLogPath(messages.getMessage("check.sysJobLogPathForLinux").concat("/").concat(jobName).concat(".csv"));
		checkJobLogInfoVo.setJobType(jobType);
		getSession().save(checkJobLogInfoVo);
	}
    
    
    /**
   	 * 保存合规巡检作业信息

   	 * 
   	 * @throws Exception
   	 * @throws JEDAException  
   	 */
       public void saveComplianceJob(String jobName, String jobGroup,String jobDbKey,String jobType) throws Exception {
       	CheckJobLogInfoVo checkJobLogInfoVo=new CheckJobLogInfoVo();
       	String uuid = UUID.randomUUID().toString();
       	String runKey = (String) findLastRunKeyByJobKey(jobDbKey);
       	String runId = (String)jobRunKeyToJobRunId(runKey);
       	String status = (String) getJobRunHadErrors(runKey);
       	String username = securityUtils.getUser().getUsername();
       	String startTime = (String)getStartTimeByRunKey(runKey);
       	String endTime = (String)getEndTimeByRunKey(runKey);
       	String saJobPath="/tmp/"+jobName+".csv";
       	File outDir = new File(messages.getMessage("check.sysJobLogPathForLinux"));
   		if (!outDir.exists()) {
   			outDir.mkdirs();
   		}
       	String copyLogName = "CopyCompilanceJobLog.nsh";
       	String copyLogJobName="CopyCompilanceJobLog".concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
       	String copyLogPath ="/BMC Maintenance/SysTools/filepush";
       	String copyFile = jobName.concat(".csv");
       	//String copyTarget="//10.1.120.147/D/test";
       	String copyTarget = "//"+messages.getMessage("systemServer.ip")+messages.getMessage("check.sysJobLogPathForLinux");
       	String jobDbKye=(String)createNshScriptJob(jobGroup, copyLogJobName, copyLogPath, copyLogName);
       	addTargetServers(jobDbKye,messages.getMessage("bsa.ipAddress"));
       	addJobParam2(jobGroup, copyLogJobName, jobName,copyTarget);
       	String jobDbKye1=(String) scriptUploadService.getNshJobDbKey(jobGroup, copyLogJobName);
   		scriptUploadService.exceNshJob(jobDbKye1);
   		deleteJob(jobGroup, copyLogJobName);
       	checkJobLogInfoVo.setGuId(uuid);
   		checkJobLogInfoVo.setCheckJobName(jobName);
   		if(status.equals("true")){
   			checkJobLogInfoVo.setCheckJobStatus("失败");
   		}else{
   			checkJobLogInfoVo.setCheckJobStatus("成功");
   		}
   		checkJobLogInfoVo.setJobDbkey(jobDbKey);
   		checkJobLogInfoVo.setJobRunDbkey(runKey);
   		checkJobLogInfoVo.setJobRunId(runId);
   		checkJobLogInfoVo.setCheckJobPath("/"+jobGroup);
   		checkJobLogInfoVo.setScriptName("");
   		checkJobLogInfoVo.setJobStartTime(Timestamp.valueOf(startTime.concat(".000").toString()));
   		checkJobLogInfoVo.setJobEndTime(Timestamp.valueOf(endTime.concat(".000").toString()));
   		checkJobLogInfoVo.setCheckJobExecuter(username);
   		checkJobLogInfoVo.setJobLogPath(messages.getMessage("check.sysJobLogPathForLinux").concat("/").concat(jobName).concat(".csv"));
   		checkJobLogInfoVo.setJobType(jobType);
   		getSession().save(checkJobLogInfoVo);
   	}
    
    
	/**
	 * 删除作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteJob(String jobGroup,String jobName) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {"/"+jobGroup+"",jobName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
    /**
	 * 创建TOOLS作业附参数

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public void addJobParam1(String jobGroup,String jobName,String runId,String fileName,String filePath) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",jobName});
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"0",runId});
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"1",fileName});
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"2",filePath});
	}
	  /**
		 * 创建TOOLS作业附参数

		 * 
		 * @throws Exception
		 * @throws JEDAException  
		 */
		public void addJobParam2(String jobGroup, String copyLogJobName,String jobName, String copyTarget) throws Exception {
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
			ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",copyLogJobName});
			ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",copyLogJobName,"0",jobGroup});
			ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",copyLogJobName,"1",jobName});
			ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",copyLogJobName,"2",copyTarget});
		}
    /**
   	 * 获取作业开始时间 
   	 * @throws Exception
   	 * @throws JEDAException
   	 */
   	private Object getEndTimeByRunKey(String jobRunKey) throws Exception {
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
   		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobRun","getEndTimeByRunKey",new String[] {jobRunKey,"yyyy-MM-dd HH:mm:ss"});
   		String value = (String) serverPropertyNames.get_return().getReturnValue();
   		return value;
   	}
    /**
   	 * 获取作业开始时间 
   	 * @throws Exception
   	 * @throws JEDAException
   	 */
   	private Object getStartTimeByRunKey(String jobRunKey) throws Exception {
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
   		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobRun","getStartTimeByRunKey",new String[] {jobRunKey,"yyyy-MM-dd HH:mm:ss"});
   		String value = (String) serverPropertyNames.get_return().getReturnValue();
   		return value;
   	}
    /**
	 * 获取作业执行状态
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object getJobRunHadErrors(String jobRunKey) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobRun","getJobRunHadErrors",new String[] {jobRunKey});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
    /**
	 * 取得作业的runId
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object jobRunKeyToJobRunId(String runKey) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobRun","jobRunKeyToJobRunId",new String[] {runKey});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
    /**
	 * 取得作业的runkey
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object findLastRunKeyByJobKey(String jobDbKey) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("JobRun","findLastRunKeyByJobKey",new String[] {jobDbKey});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 添加服务器到作业中

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	private Object addTargetServers(String jobDbKye, String serverIps) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("Job","addTargetServers",new String[] {jobDbKye,serverIps});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}

	/**
	 * 创建TOOLS作业附参数

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public void addJobParam(String jobGroup,String jobName,List<String>list) throws Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",jobName});
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"0","??TARGET.IP_ADDRESS??"});
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"1","??TARGET.CHECK_PushFile??"});
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"2","??TARGET.CHECK_SYSPATH??"});
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"3","n"});
		ExecuteCommandByParamListResponse jobParentGroupNames5 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"4","y"});
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"5","??TARGET.CHECK_ExecuteCommonInitnsh??"});
		for(int i=0;i<list.size();i++){
			if(list.get(i).equals("SET")){
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"6","y"});
				list.remove(i);
			}else{
				ExecuteCommandByParamListResponse jobParentGroupNames6 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"6","n"});
			}
		}
		if(list.size()>0){
			for(int i=0;i<list.size();i++){
				if(list.get(i).equals("INIT")){
					ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"7","y"});
				}else{
					ExecuteCommandByParamListResponse jobParentGroupNames7 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"7","n"});
				}
			}
		}
		ExecuteCommandByParamListResponse jobParentGroupNames8 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"8","n"});
	}
    /**
	 * 新建一个nshJob
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unused")
	private Object createNshScriptJob(String jobGroup, String jobName,String scriptGroup, String scriptName) throws Exception {
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
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/"+jobGroup+"",jobName," ","/"+scriptGroup+"",scriptName,"100"});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * job作业附策略

	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object applyJobAclPolicy(String jobDbKey,String ceLv) throws NoSuchMessageException, Exception {
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
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","applyAclPolicy",new String[] {jobDbKey,ceLv});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
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
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)
			throws SQLException {
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
		List<HashMap<String,String>> list=query.list();
		HashMap<String,String> map=new HashMap<String,String>();
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		String oldCole = null;
		for(int i=0;i<list.size();i++){
			if(i == 0) {
				oldCole= list.get(0).get("checkItemCode");
				map.put("checkItemCode", list.get(i).get("checkItemCode"));
				map.put("osType", list.get(i).get("osType"));
				map.put("fieldType", list.get(i).get("fieldType"));
				map.put("checkItemName", list.get(i).get("checkItemName"));
				if(list.get(i).get("scriptType").equals("BIN")){
					map.put("binScriptName", list.get(i).get("scriptName"));
				}
				if(list.get(i).get("scriptType").equals("SET")){
					map.put("setScriptName", list.get(i).get("scriptName"));
				}
				if(list.get(i).get("scriptType").equals("INIT")){
					map.put("initScriptName", list.get(i).get("scriptName"));
				}
				param.add(map);
			}else{
				if(oldCole.equals(list.get(i).get("checkItemCode"))){
					map.put("checkItemCode", list.get(i).get("checkItemCode"));
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if(list.get(i).get("scriptType").equals("BIN")){
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("SET")){
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("INIT")){
						map.put("initScriptName", list.get(i).get("scriptName"));
					}
				}else{
					map=new HashMap<String,String>();
					oldCole= list.get(i).get("checkItemCode");
					map.put("checkItemCode", list.get(i).get("checkItemCode"));
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if(list.get(i).get("scriptType").equals("BIN")){
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("SET")){
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("INIT")){
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
					sql.append(" and " + key + " = :" + key );
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
                .append("from (select t.script_type as scriptType from check_item_script_info t ,check_item_info d where t.check_item_code=d.check_item_code and d.os_type='"+osType+"' and t.check_item_code='"+checkItemCode+"' and t.script_type!='BIN') o ");
        Query query = (Query) getSession().createSQLQuery(sql.toString())
                .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
        return query.list();
	}
	/**
	 * 查询操作系统下的服务器
	 * @param serverIp 
	 * 
	 * @param params
	 * @return
	 * @throws SQLException 
	 */
	public Object queryServerIp(String osType, String serverIp,String appsysCode) throws SQLException {
		String osTypeName=scriptUploadService.getOstype(osType);
		  StringBuilder sql = new StringBuilder();
		  sql.append("select d.appsysName as \"appsysName\",  ")
		   .append("  d.serverName as \"serverName\" , ")
		   .append("  d.appsysCode as \"appsysCode\" , ")
		    .append(" d.serverIp as \"serverIp\" ")
		    .append("from( select o. appsys_code as appsysCode ,o.systemname as appsysName, t.server_name as serverName, t.server_ip as serverIp from cmn_servers_info t ,v_cmn_app_info o where t.appsys_code=o.appsys_code and t.os_type='"+osTypeName+"' and t.bsa_agent_flag='1' and  t.delete_flag='0'");
			if(null!=appsysCode && !"".equals(serverIp)){
				sql.append(" and t.server_ip like '%"+serverIp+"%' ");
			}
			if(null!=appsysCode && !"".equals(appsysCode)){
				sql.append(" and t.appsys_code like '%"+appsysCode+"%' ");
			}
			sql.append( ") d where d.appsysCode in :sysList");
		  Query query = getSession().createSQLQuery(sql.toString())
	                .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
	                .setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
	        return query.list();
	}
	/**
	 * 查询操作系统下的初始化项
	 * @param params
	 * @return
	 * @throws SQLException 
	 */
	public List<Map<String, String>> queryTree(String osType) {
		  StringBuilder sql = new StringBuilder();
		  sql.append("select t.check_item_code,t.check_item_name from check_item_info t where t.os_type='"+osType+"'");
		  Query query = (Query) getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	/**
	 * 查询子节点
	 * @param params
	 * @return
	 * @throws SQLException 
	 */
	public List<Map<String, String>> queryChildren(String checkItemCode) {
				  StringBuilder sql = new StringBuilder();
				  sql.append("select o.check_item_name, t.script_type ,t.script_name from check_item_script_info t, check_item_info o  where t.check_item_code = o.check_item_code  and t.script_type <> 'BIN' and  t.check_item_code='"+checkItemCode+"' order by t.script_type desc");
				  Query query = (Query) getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);	
		return query.list();
	}
	/**
	 * 树的数据
	 * @param serverIp 
	 * @param params
	 * @return
	 * @throws SQLException 
	 */
	public List<JSONObject> scriptExecService(List<Map<String, String>> dataList) {

		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject cjo = null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;
		for (Map<String, String> map : dataList) {
				if(map.get("CHECK_ITEM_NAME") != null){
					cjsonList = new ArrayList<JSONObject>();
					cjo = new JSONObject();
					// cjo.put("id", map.get("serverGroup"));
					cjo.put("text", map.get("CHECK_ITEM_NAME"));
					cjo.put("iconCls", "node-treenode");
					cjo.put("isType", true);
					cjo.put("checked", false);
					List<Map<String, String>> serverList = queryChildren(map.get("CHECK_ITEM_CODE"));
			
				for (Map<String, String> scMap1 : serverList) {
					if (scMap1.get("SCRIPT_NAME") != null) {
						cjo1 = new JSONObject();
						cjo1.put("text", scMap1.get("SCRIPT_NAME"));
						cjo1.put("scriptType", scMap1.get("SCRIPT_TYPE"));
						cjo1.put("checkItemName", map.get("CHECK_ITEM_NAME"));
						cjo1.put("iconCls", "node-leaf");
						cjo1.put("leaf", true);
						cjo1.put("checked", false);
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
		}
		return sysJsonList;
	}
	/**
	 * 批量执行
	 * @param serverIp 
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public void execall(CheckItemInfoVo checkItemInfoVo) throws Exception {
		// TODO Auto-generated method stub
		String serverIpJson = checkItemInfoVo.getServerValue();
		String checkInitJson = checkItemInfoVo.getCheckInitValue();
		String osType=scriptUploadService.getOstype(checkItemInfoVo.getExecOsType());
		JSONArray serverparam = JSONArray.fromObject(serverIpJson);
		List<String> serverIplist = (List<String>) JSONArray.toCollection(serverparam, String.class);
		JSONArray checkParam = JSONArray.fromObject(checkInitJson);
		List<String> checklist = (List<String>) JSONArray.toCollection(checkParam, String.class);
		for (String mapparam : checklist) {
			List<String> list = new ArrayList<String>();
			String checkItemName=mapparam.split(Constants.SPLIT_SEPARATEOR)[0];
			
			if(mapparam.split(Constants.SPLIT_SEPARATEOR).length<3 && mapparam.split(Constants.SPLIT_SEPARATEOR).length>1){
				list.add(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			}else{
				list.add(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[2]));
			}
			 StringBuilder sql = new StringBuilder();
			 sql.append("select t.item_script_name,t.item_script_path from check_item_nsh_info t ,check_item_info o where t.check_item_code=o.check_item_code and o.check_item_name='"+checkItemName+"'");
			 Map<String,String> query = (Map<String, String>) getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();
			 String itemNshName = query.get("ITEM_SCRIPT_NAME");
			 String itemNshPath = query.get("ITEM_SCRIPT_PATH").substring(1);
			 String jobGroup=CheckConstants.ChenkGroupName+"/"+osType;
			 String execJobName="EXEC_"+itemNshName.substring(0, itemNshName.indexOf(".")).concat("_").concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
			 String jobDbKye=(String) createNshScriptJob(jobGroup, execJobName, itemNshPath, itemNshName);
			 StringBuffer sb= new StringBuffer();
				for(int i=0;i<serverIplist.size();i++){
					if(i==serverIplist.size()-1){
						sb.append(serverIplist.get(i));
					}else{
						sb.append(serverIplist.get(i)).append(",");
					}
				}
			addTargetServers(jobDbKye,sb.toString());
			addJobParam(jobGroup,execJobName,list);
			String jobDbKye1=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
			scriptUploadService.exceNshJob(jobDbKye1);
			String jobDbKye2=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
			applyJobAclPolicy(jobDbKye2, CheckConstants.celv);
			String jobDbKye3=(String) scriptUploadService.getNshJobDbKey(jobGroup, execJobName);
			applyJobAclPolicy(jobDbKye3, CheckConstants.allSysadminCelv);
			//将作业信息入库
			saveJob(execJobName,jobGroup,itemNshName,jobDbKye1,"3");
		}
	}
}

package com.nantian.rept.service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.xml.namespace.QName;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.util.SecurityUtils;
/**
 * @author liruihao
 *
 */
@Service
@Repository
public class RptDataInterfaceService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptDataInterfaceService.class);
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	public Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 删除bsa服务器上的文件

	 * 
	 * @param String appsys_code
	 * 
	 * @throws AxisFault
	 * @throws Exception 
	 */
	@Transactional
	public void importSysResource(String DataType,String startDate,String endDate,String jsonStr,String TypeNumber) throws AxisFault, Exception {
		jsonStr=jsonStr.replaceAll("\"", "\\\\\"").replace(",", "\\,");
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		String tt = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String userName = securityUtils.getUser().getUsername();
		String jobPath = messages.getMessage("bsa.importDataManage.job");
		String jobName = new StringBuilder().append(messages.getMessage("bsa.importDataManage.jobName"))
											.append("_").append(DataType)
											.append("_").append(tt)
											.append("_").append(userName).toString();
		String depotPath = messages.getMessage("bsa.importDataManage.depot");
		String depotName = messages.getMessage("bsa.importDataManage.depotName");
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{jobPath,jobName,"",depotPath,depotName,messages.getMessage("bsa.fileServerIp"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();

		/*executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();*/
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"0",DataType});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"1",startDate});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"2",endDate});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"3",jsonStr});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//Json格式：[{\"aplCode\":\"NEXCH\"\,\"srvCode\":\"BL685-005\"},{\"aplCode\":\"NEXCH\"\,\"srvCode\":\"BL685-005\"}]
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"4",TypeNumber});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{jobPath,jobName});

	}

	public void Execute(String aplCode, String date) throws Exception {
		// TODO Auto-generated method stub /SYSMANAGE/BatchTask/
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		String jobPath = "/SYSMANAGE/BatchTask";
		String jobName = "TempThresholdCheck";
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {jobPath,jobName});
		String DbKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"1",aplCode});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"2",date});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DbKey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
	}

	public void importMultTrans(String aplCode, String date) throws Exception {

		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		String jobPath = "/SYSMANAGE/BatchTask";
		String jobName = "TempMultTrans";
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {jobPath,jobName});
		String DbKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"1",aplCode});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"2",date});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DbKey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}

	public void sysTransPeak(String aplCode, String date) throws Exception {

		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		String jobPath = "/SYSMANAGE/BatchTask";
		String jobName = "TempSysTransPeak";
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {jobPath,jobName});
		String DbKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"1",aplCode});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"2",date});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DbKey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
	}

	public void expRstat(String aplCode, String date) throws Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		String jobPath = "/SYSMANAGE/BatchTask";
		String jobName = "TempExpRstat";
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {jobPath,jobName});
		String DbKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{jobPath,jobName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"1",aplCode});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{jobPath,jobName,"2",date});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DbKey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}

}

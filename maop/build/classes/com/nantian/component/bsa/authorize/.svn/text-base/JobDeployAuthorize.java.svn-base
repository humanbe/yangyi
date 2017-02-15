package com.nantian.component.bsa.authorize;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nantian.common.util.DateFunction;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

/**
 * BSA服务器的'作业/Deploy'目录授权
 * @author linaWang
 *
 */
public class JobDeployAuthorize {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDeployAuthorize.class);
	
	private String policyName = "";
	/**
	 * 执行授权操作
	 * @param appsysCode 应用系统编号
	 * @param env 环境
	 */
	public void authorize(String appsysCode,String env) throws AxisFault,Exception{
		
		//增加开关控制
		String on_off="";
		if(on_off.equals("off")){
			logger.info("授权操作关闭");
		}else{
			/*appsysCode = "MBANK"; //测试*/
			policyName = "PLCY_"+env+"_"+appsysCode+"_APPADMIN" ;
			logger.info("Job/Deploy目录授权开始，权限值为："+policyName);
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponse = null;
			
			//对应用系统目录授权

			cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{"/DEPLOY/"+env+"/"+appsysCode,policyName});
			//获取应用系统下的目录结构
			cliResponse = cliClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{"/DEPLOY/"+env+"/"+appsysCode});
			if(cliResponse.get_return().getSuccess()){
				String groupNames = (String)cliResponse.get_return().getReturnValue();
				logger.info("应用系统目录下的所有子节点："+groupNames);
				if(!groupNames.equals("void")){
					String[] gNames = groupNames.split("\n");
					String group = "";
					for(String gName : gNames){
						if(gName.length()>17){
							boolean b=DateFunction.isDate(gName.substring(3, 11));
							if(b&&gName.substring(0, 3).toString().equals("BAK")){
								continue;
							}
						}
						
						//对该group目录授权
						group = "/DEPLOY/"+env+"/"+appsysCode+"/"+gName ;
						logger.info("对"+group+"目录授权开始");
						cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{group,policyName});
						logger.info("对"+group+"目录授权结束");
						logger.info("对"+group+"目录下的所有作业授权开始");
						//获取该分组下的所有作业

						cliResponse = cliClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{group});
						if(cliResponse.get_return().getSuccess()){
							String jobs = (String)cliResponse.get_return().getReturnValue();
							String jobDBKey = "" ; //作业的DBKey
							if(!jobs.equals("void")){
								String[] depotJobs = jobs.split("\n");
								for(String jobName : depotJobs){
									cliResponse = cliClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{group,jobName});
									String DeployJobDBkey=(String) cliResponse.get_return().getReturnValue();
									
									cliResponse = cliClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{group,jobName});
									String NSHScriptJob=(String) cliResponse.get_return().getReturnValue();
									
									if(!DeployJobDBkey.equals("void")){
										jobDBKey = DeployJobDBkey;
									}else if(!NSHScriptJob.equals("void")){
										jobDBKey = NSHScriptJob;
									}
									cliResponse = cliClient.executeCommandByParamList("Job", "applyAclPolicy", new String[]{jobDBKey,policyName});
								}
							}
						}
						logger.info("对"+group+"目录下的所有作业授权结束");
					}
				}
			}
			logger.info("Job/Deploy目录授权结束，权限值为："+policyName);
		}
		
		
	}
	
	/**
	 * 统计BSA中Job/DEPLOY目录下需要授权的所有文件数量
	 * @param appsysCode 系统编号
	 * @param env 环境标示
	 * @return
	 * @throws Exception
	 */
	public int countJobTotal(String appsysCode,String env) throws Exception{
		int count = 1;  //应用系统节点授权
		//BSAd登录
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		String[] gNames = null ; //应用系统目录下的所有专业领域分组
		String[] depotJobs = null ; //专业领域分组目录下的所有作业
		
		//获取应用系统下的目录结构
		cliResponse = cliClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{"/DEPLOY/"+env+"/"+appsysCode});
		if(cliResponse.get_return().getSuccess()){
			String groupNames = (String)cliResponse.get_return().getReturnValue();
			if(!groupNames.equals("void")){
				gNames = groupNames.split("\n");
				String group = "";
				for(String gName : gNames){
					//对该group目录授权
					group = "/DEPLOY/"+env+"/"+appsysCode+"/"+gName ;
					cliResponse = cliClient.executeCommandByParamList("JobGroup", "applyAclPolicy", new String[]{group,policyName});
					//获取该分组下的所有作业
					cliResponse = cliClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{group});
					if(cliResponse.get_return().getSuccess()){
						String jobs = (String)cliResponse.get_return().getReturnValue();
						if(!jobs.equals("void")){
							depotJobs = jobs.split("\n");
						}
					}
				}
			}
		}
		if(gNames!=null && gNames.length>0){
			count += gNames.length ;
		}
		if(depotJobs!=null && depotJobs.length>0){
			count += depotJobs.length ;
		}
		return count;
	}
	
}

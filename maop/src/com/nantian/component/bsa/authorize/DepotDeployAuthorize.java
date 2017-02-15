package com.nantian.component.bsa.authorize;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nantian.common.util.DateFunction;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

/**
 * BSA服务器的'Depot/Deploy'目录授权
 * @author linaWang
 *
 */
public class DepotDeployAuthorize {
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(DepotDeployAuthorize.class);
	
	//权限名称
	public String policyName = "";
	
	/**
	 * 执行授权操作
	 * @param appsysCode 应用系统编号
	 * @param groupMaps 对象路径map(eg:["/DEPLOY/DEV/MBANK/APP/BLPACKAGE", "BLPACKAGE"])
	 * @param env 环境
	 */
	public void authorize(String appsysCode,Map<String,String> groupMaps,String env) throws AxisFault,Exception{
		//增加开关控制
				String on_off="";
				if(on_off.equals("off")){
					logger.info("授权操作关闭");
				}else{
		/*appsysCode = "MBANK"; //测试*/
		policyName = "PLCY_"+env+"_"+appsysCode+"_APPADMIN" ;
		logger.info("Depot/Deploy目录授权开始，权限值为："+policyName);
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		Set<String> groupsLast = new HashSet<String>(); //最后一个分组
		Set<String> groupsLastButOne = new HashSet<String>(); //倒数第二个分组（专业领域分组）
		Set<String> groupsAppsys = new HashSet<String>(); //应用系统分组
		if(groupMaps!=null){
			logger.info("叶子节点授权开始");
			for(String objectGroup : groupMaps.keySet()){
				
				String tmp_name= objectGroup.substring(objectGroup.lastIndexOf("/")+1);
				if(tmp_name.length()>17){
				boolean b=DateFunction.isDate(tmp_name.substring(3, 11));
				if(b&&tmp_name.substring(0, 3).toString().equals("BAK")){
					continue;
				}
				}
				groupsLast.add(objectGroup);
				String field = objectGroup.substring(0,objectGroup.lastIndexOf("/"));
				String appsys = field.substring(0,field.lastIndexOf("/"));
				groupsLastButOne.add(field);
				groupsAppsys.add(appsys);
				String objectType = groupMaps.get(objectGroup) ;
				//获取叶子节点DepotObject
				cliResponse = cliClient.executeCommandByParamList("DepotObject", "listAllByGroup", new String[]{objectGroup});
				if(cliResponse.get_return().getSuccess()){
					String objects = (String)cliResponse.get_return().getReturnValue();
					if(!objects.equals("void")){
						String[] objs = objects.split("\n");
						String objDBKey = "" ; //叶子节点的DBKey
						for(String obj : objs){
							cliResponse = cliClient.executeCommandByParamList("DepotObject", "getDBKeyByTypeStringGroupAndName", new String[]{objectType,objectGroup,obj});
							if(cliResponse.get_return().getSuccess()){
								objDBKey = (String)cliResponse.get_return().getReturnValue(); 
								cliClient.executeCommandByParamList("DepotObject", "applyAclPolicy", new String[]{objDBKey,policyName});
							}
						}
					}
				}
			}
			logger.info("叶子节点授权结束");
			logger.info("NSHELLS/SCRIPTS授权开始");
			//对目录进行授权
			for(String groupLast : groupsLast){
				cliClient.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{groupLast,policyName});
			}
			logger.info("NSHELLS/SCRIPTS授权结束");
			logger.info("NSHELLS/SCRIPTS父节点授权开始");
			for(String groupLastButOne : groupsLastButOne){
				cliClient.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{groupLastButOne,policyName});
			}
			logger.info("NSHELLS/SCRIPTS父节点授权结束");
			logger.info("应用系统节点授权开始");
			for(String groupAppsys : groupsAppsys){
				cliClient.executeCommandByParamList("DepotGroup", "applyAclPolicy", new String[]{groupAppsys,policyName});
			}
			logger.info("应用系统节点授权结束");
		}
		logger.info("Depot/Deploy目录授权结束，权限值为："+policyName);
				}
	}
	
	/**
	 * 统计BSA中Depot/DEPLOY目录下需要授权的所有文件数量
	 * @param appsysCode 应用系统编号
	 * @param groupMaps 对象路径map(eg:["/DEPLOY/MBANK/APP/BLPACKAGE", "BLPACKAGE"])
	 * @return
	 * @throws Exception
	 */
	public int countDepotTotal(String appsysCode,Map<String,String> groupMaps) throws Exception{
		int count = 0; 
		//BSAd登录
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		Set<String> groupsLast = new HashSet<String>(); //最后一个分组
		Set<String> groupsLastButOne = new HashSet<String>(); //倒数第二个分组（专业领域分组）
		Set<String> groupsAppsys = new HashSet<String>(); //应用系统分组
		String[] objs = null; //叶子节点
		if(groupMaps!=null){ 
			for(String objectGroup : groupMaps.keySet()){
				groupsLast.add(objectGroup);
				String field = objectGroup.substring(0,objectGroup.lastIndexOf("/"));
				String appsys = field.substring(0,field.lastIndexOf("/"));
				groupsLastButOne.add(field);
				groupsAppsys.add(appsys);
				//获取叶子节点DepotObject
				cliResponse = cliClient.executeCommandByParamList("DepotObject", "listAllByGroup", new String[]{objectGroup});
				if(cliResponse.get_return().getSuccess()){
					String objects = (String)cliResponse.get_return().getReturnValue();
					if(!objects.equals("void")){
						objs = objects.split("\n");
					}
				}
			}
		}
		if(groupsAppsys!=null && groupsAppsys.size()>0){
			count += groupsAppsys.size();
		}
		if(groupsLastButOne!=null && groupsLastButOne.size()>0){
			count += groupsLastButOne.size();
		}
		if(groupsLast!=null && groupsLast.size()>0){
			count += groupsLast.size();
		}
		if(objs!=null && objs.length>0){
			count += objs.length;
		}
		return count;
	}
	
}

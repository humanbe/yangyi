package com.nantian.component.bsa.test;

import org.apache.axis2.AxisFault;

import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

public class CLITunnelServiceTest {

	
	public static void main(String[] args) throws Exception {

		//1.用户登录
		LoginServiceClient client = LoginServiceClient.getInstance();
		//client.setTrueStorePath("E:\\caskey\\bladelogic.keystore");
//		client.getBrpmCredential();
		//System.setProperty("javax.net.ssl.trustStore", "E:\\caskey\\bladelogic.keystore");
		//System.setProperty("javax.net.ssl.trustStorePassword", "111111");
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		//2.执行cli命令，无参数
		//sample1 无参数 : 获取所有服务器
//		System.out.println(loginResponse.getReturnSessionId());
		CLITunnelServiceClient cliClient = null;
		try {
			cliClient = CLITunnelServiceClient.getInstance(loginResponse.getReturnSessionId(), null);
		} catch (AxisFault f) {
			org.apache.axiom.om.OMElement faultElt = f.getDetail();
			 if (faultElt!=null){
				 new org.apache.axis2.client.FaultMapKey(faultElt.getQName(),"loginUsingUserCredential");
			 }
		}
//		ExecuteCommandByParamStringResponse cliResponse = cliClient.executeCommandByParamString("Server", "listAllServers");
//		System.out.println(cliResponse.get_return().getReturnValue());

		ExecuteCommandByParamListResponse listresponse = cliClient.executeCommandByParamList("PropertyInstance", "listAllPropertyValues", 
				new String[]{"Class://SystemObject/CEB-NEXCH/QUOTE/QUOTE&ONLINE"});
//		System.out.println(listresponse.get_return().getReturnValue());
		String returnVal = listresponse.get_return().getReturnValue().toString();
		System.out.println(returnVal);
//		String [] properties = returnVal.split("\n");
		/*for(String prop : properties){
			ExecuteCommandByParamListResponse res = 
					cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", 
							new String[]{"Class://SystemObject/CLASS_ECS", prop});
			System.out.println(prop + ".editable=" + res.get_return().getReturnValue());
		}*/
		
		
/*		ExecuteCommandByParamListResponse listresponse = cliClient.executeCommandByParamList("PropertyInstance", "listAllFullyResolvedPropertyValues", new String[]{"Class://SystemObject/CLASS_ECS/OBJ_ECS_01"});
		System.out.println(listresponse.get_return().getReturnValue());
*/		//创建用户
		//1.用户登录
		/*LoginServiceClient client2 = new LoginServiceClient("devadmin", "bmcadmin", "SRP",null);
		LoginUsingUserCredentialResponse loginResponse2 = client2.loginUsingUserCredential();
		//2.设置用户角色
		AssumeRoleServiceClient aRoleClient = new AssumeRoleServiceClient(loginResponse2.getReturnSessionId(),null);
		aRoleClient.assumeRole("RBACAdmins");
		//3.执行cli命令，无参数
		//sample2 有参数 : 创建用户
		CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(loginResponse2.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse2 = cliClient2.executeCommandByParamList("RBACUser", "createUser", new String[]{"w02072","password","desc"});
		System.out.println(cliResponse2.get_return().getSuccess());*/
		
	}

}

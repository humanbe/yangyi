package com.nantian.check.utils;

import java.util.ArrayList;
import java.util.List;

import org.apache.axis2.AxisFault;

import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

/**
 * BSA巡检相关的参数导出
 * @author linaWang
 *
 */
public class CheckParamExport {
	/**
	 * 执行导出操作
	 */
	public String doExportParams() throws AxisFault,Exception{
		//主路径
		String mainPath = "Class://SystemObject";
		//系统内置对象属性
		List<String> sysInnerPro = new ArrayList<String>(); 
		sysInnerPro.add("USER_MODIFIED");
		sysInnerPro.add("USER_CREATED");
		sysInnerPro.add("ROLE_MODIFIED");
		sysInnerPro.add("ROLE_CREATED");
		sysInnerPro.add("NAME");
		sysInnerPro.add("DATE_MODIFIED");
		sysInnerPro.add("DATE_CREATED");
		sysInnerPro.add("BROKEN_OBJECT");
		sysInnerPro.add("GROUPS*");
		sysInnerPro.add("GROUP*");
		sysInnerPro.add("DESCRIPTION");
		sysInnerPro.add("BL_ACL*");
		sysInnerPro.add("AUTO_GENERATED");
		sysInnerPro.add("AUDIT_TRAILS*");
		
		String paramExportXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		//导出内置属性server目录下的相关属性
		paramExportXml += "<server_attributes>" ;
		String serverPath = mainPath+"/SERVER" ;
		String[] serverProperties = null ; //服务器目录下的属性数组
		cliResponse = cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNamesWithTypes", new String[]{serverPath});
		if(cliResponse.get_return().getSuccess()){
			String pros = (String)cliResponse.get_return().getReturnValue();
			if(!pros.equals("void")){
				serverProperties = pros.split("\n");
				for(String serverProperty : serverProperties){
					String[] nameVal = serverProperty.split(",");
					String proName = nameVal[0];
					//导出server目录下"CHECK_"开头的属性（用于巡检）
					if(proName.indexOf("CHECK_")!=-1){
						//该属性是否可编辑
						String isEditabe = "true" ;
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", new String[]{serverPath,proName});
						if(cliResponse.get_return().getSuccess()){
							isEditabe = (String)cliResponse.get_return().getReturnValue();
						}
						//该属性的默认值
						String defaultVal = "" ;
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getDefaultValue", new String[]{serverPath,proName});
						if(cliResponse.get_return().getSuccess()){
							String ret = (String)cliResponse.get_return().getReturnValue();
							if(!ret.equals("void")){
								defaultVal = (String)cliResponse.get_return().getReturnValue();
							}
						}
						if(!sysInnerPro.contains(nameVal[0])){
							paramExportXml += "<attribute>" ;
							paramExportXml += "<path>"+serverPath+"</path>" ;
							paramExportXml += "<name>"+proName+"</name>" ;
							paramExportXml += "<desc></desc>" ;
							String type = "" ;
							if(nameVal.length>1){
								type = nameVal[1].substring(1) ;
							}
							if(type.indexOf("Class")!=-1){
								paramExportXml += "<type>"+type+"</type>" ; //静态组类型
							}else{
								paramExportXml += "<type>Primitive:/"+type+"</type>" ; //原始数据类型
							}
							paramExportXml += "<isEditable>"+isEditabe+"</isEditable>" ;
							paramExportXml += "<isRequired>false</isRequired>" ;
							paramExportXml += "<defaultVal>"+defaultVal+"</defaultVal>" ;
							paramExportXml += "</attribute>" ;
						}
					}
				}
			}
		}
		paramExportXml += "</server_attributes>" ;
		/*System.out.println(paramExportXml); //用于测试 */
		return paramExportXml ;
	}
}

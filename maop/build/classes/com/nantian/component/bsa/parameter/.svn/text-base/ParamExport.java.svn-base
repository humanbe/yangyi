package com.nantian.component.bsa.parameter;

import java.util.ArrayList;
import java.util.List;

import org.apache.axis2.AxisFault;

import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

/**
 * BSA参数导出
 * @author linaWang
 *
 */
public class ParamExport {
	
	/**
	 * 执行导出操作
	 * @param appsysCode 应用系统编号
	 */
	public String doExportParams(String appsysCode) throws AxisFault,Exception{
		//主路径
		String mainPath = "Class://SystemObject";
		//应用系统路径
		String sysPath = mainPath+"/CLASS_";
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
		sysPath = sysPath+appsysCode ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		//判断该目录是否存在
		cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassDefined",new String[]{sysPath});
		if(cliResponse.get_return().getSuccess()){
			String isExist = (String)cliResponse.get_return().getReturnValue();
			if(isExist.equals("true")){
				paramExportXml += "<property_class>" ;
				String sysClass = "CLASS_"+appsysCode;
				paramExportXml += "<path>"+mainPath+"</path>" ;
				paramExportXml += "<name>"+sysClass+"</name>" ;
				paramExportXml += "<desc></desc>" ;
				String[] sysClassProperties = null ; //应用系统目录属性数组[{名称,类型}]
				//获取应用系统目录属性
				cliResponse = cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNamesWithTypes", new String[]{sysPath});
				if(cliResponse.get_return().getSuccess()){
					String properties = (String)cliResponse.get_return().getReturnValue();
					if(!properties.equals("void")){
						sysClassProperties = properties.split("\n");
					}
				}
				if(sysClassProperties!=null){
					paramExportXml += "<attributes>" ;
					for(String sysClassProperty : sysClassProperties){
						String[] nameVal = sysClassProperty.split(",");
						//该属性是否可编辑
						String isEditabe = "true" ;
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", new String[]{sysPath,nameVal[0]});
						if(cliResponse.get_return().getSuccess()){
							isEditabe = (String)cliResponse.get_return().getReturnValue();
						}
						//该属性的默认值
						String defaultVal = "" ;
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getDefaultValue", new String[]{sysPath,nameVal[0]});
						if(cliResponse.get_return().getSuccess()){
							String ret = (String)cliResponse.get_return().getReturnValue();
							if(!ret.equals("void")){
								defaultVal = (String)cliResponse.get_return().getReturnValue();
							}
						}
						if(!sysInnerPro.contains(nameVal[0])){
							paramExportXml += "<attribute>" ;
							paramExportXml += "<path>"+sysPath+"</path>" ;
							paramExportXml += "<name>"+nameVal[0]+"</name>" ;
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
					paramExportXml += "</attributes>" ;
				}
				//获取应用系统目录下的子目录
				paramExportXml += "<subClasses>" ;
				String[] subClasses = null ;
				cliResponse = cliClient.executeCommandByParamList("PropertyClass", "listAllSubclassNames", new String[]{sysPath});
				if(cliResponse.get_return().getSuccess()){
					String classes = (String)cliResponse.get_return().getReturnValue();
					if(!classes.equals("void")){
						subClasses = classes.split("\n");
						for(int t=0 ; t<subClasses.length ; t++){
							paramExportXml += "<property_class>" ;
							//子目录的名称
							String subClass = subClasses[t].substring(subClasses[t].lastIndexOf("/")+1);
							paramExportXml += "<path>"+sysPath+"</path>" ;
							paramExportXml += "<name>"+subClass+"</name>" ;
							paramExportXml += "<desc></desc>" ;
							//获取子目录的所有属性
							String[] subClassProperties = null ; //子目录属性数组
							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNamesWithTypes", new String[]{subClasses[t]});
							if(cliResponse.get_return().getSuccess()){
								String subClassPros = (String)cliResponse.get_return().getReturnValue();
								if(!subClassPros.equals("void")){
									subClassProperties = subClassPros.split("\n");
								}
							}
							if(subClassProperties!=null){
								paramExportXml += "<attributes>" ;
								for(String subClassProperty : subClassProperties){
									String[] nameVal = subClassProperty.split(",");
									//该属性是否可编辑
									String isEditabe = "true" ;
									cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", new String[]{subClasses[t],nameVal[0]});
									if(cliResponse.get_return().getSuccess()){
										isEditabe = (String)cliResponse.get_return().getReturnValue();
									}
									//该属性的默认值
									String defaultVal = "" ;
									cliResponse = cliClient.executeCommandByParamList("PropertyClass", "getDefaultValue", new String[]{subClasses[t],nameVal[0]});
									if(cliResponse.get_return().getSuccess()){
										String ret = (String)cliResponse.get_return().getReturnValue();
										if(!ret.equals("void")){
											defaultVal = (String)cliResponse.get_return().getReturnValue();
										}
									}
									if(!sysInnerPro.contains(nameVal[0])){
										paramExportXml += "<attribute>" ;
										paramExportXml += "<path>"+subClasses[t]+"</path>" ;
										paramExportXml += "<name>"+nameVal[0]+"</name>" ;
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
								paramExportXml += "</attributes>" ;
							}
							//获取子目录实例 
							String[] instances = null ; //子目录实例数组							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "listAllInstanceNames", new String[]{subClasses[t]});
							if(cliResponse.get_return().getSuccess()){
								String insts = (String)cliResponse.get_return().getReturnValue();
								if(!insts.equals("void")){
									instances = insts.split("\n");
									paramExportXml += "<instances>" ;
									for(int m=0 ; m<instances.length ; m++){
										paramExportXml += "<instance>";
										paramExportXml += "<path>"+subClasses[t]+"</path>" ;
										//instances[m].substring(instances[m].lastIndexOf("/")+1) 截取实例名称
										paramExportXml += "<name>"+instances[m].substring(instances[m].lastIndexOf("/")+1)+"</name>" ;
										paramExportXml += "<desc></desc>" ;
										paramExportXml += "</instance>" ;
									}
									paramExportXml += "</instances>" ;
								}
							}
							paramExportXml += "</property_class>" ;
						}
					}
				}
				paramExportXml += "</subClasses>" ;
				
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
							/*//导出server目录下"ATTR_"+appsysCode与"CHECK_"开头的属性（前者用于应用发布，后者用于巡检）
							if(proName.indexOf("ATTR_"+appsysCode)!=-1 || proName.indexOf("CHECK_")!=-1){*/
							if(proName.indexOf("ATTR_"+appsysCode)!=-1){
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
				paramExportXml += "</property_class>" ;
			}
		}
		/*System.out.println(paramExportXml); //用于测试 */
		return paramExportXml ;
	}
	
}

package com.nantian.check.utils;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;

import org.apache.axis2.AxisFault;
import org.jdom2.Document;
import org.jdom2.Element;

import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;

/**
 * BSA巡检相关的参数导入
 * @author linaWang
 *
 */
public class CheckParamImport {
	/**
	 * 执行导入操作
	 * @param filePath 参数导入文件路径
	 */
	public void doImportParams(String filePath) throws AxisFault,Exception{
		//内置属性类服务器目录主路径
		String serverPath = "Class://SystemObject/SERVER";
		CheckParamImport pi = new CheckParamImport();
		//内置属性server目录下的相关属性
		List<Property> serverProperties = null;
		
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		String xml = readFile(filePath);
		//解析导入xml文件
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			//内置属性类中服务器目录下的系统属性
			List<Element> serverPros = root4.getChildren("attribute");
			if(serverPros!=null && serverPros.size()>0){
				serverProperties = new ArrayList<Property>();
				for (Element serverAttribute : serverPros) {
					Property p = pi.new Property();
					p.setPath(serverAttribute.getChildText("path"));
					p.setName(serverAttribute.getChildText("name"));
					p.setDesc(serverAttribute.getChildText("desc"));
					p.setType(serverAttribute.getChildText("type"));
					p.setIsEditable(serverAttribute.getChildText("isEditable"));
					p.setIsRequired(serverAttribute.getChildText("isRequired"));
					p.setDafaultVal(serverAttribute.getChildText("defaultVal"));
					serverProperties.add(p);
				}
			}
		}
		
		//导入内置属性类服务器目录下的相关属性
		cliResponse = cliClient.executeCommandByParamList("PropertyClass","isPropertyClassDefined",new String[]{serverPath});
		if(cliResponse.get_return().getSuccess()){
			String isExist = (String)cliResponse.get_return().getReturnValue();
			if(isExist.equals("true")){
				if(serverProperties!=null){
					for(Property serverProperty : serverProperties){
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyDefined", 
								new String[]{serverProperty.getPath(),serverProperty.getName()});
						if(cliResponse.get_return().getSuccess()){
							String b = (String)cliResponse.get_return().getReturnValue();
							if(b.equals("false")){
								cliResponse = cliClient.executeCommandByParamList("PropertyClass", "addProperty", 
										new String[]{serverProperty.getPath(),serverProperty.getName(),serverProperty.getDesc(),
										serverProperty.getType(),serverProperty.getIsEditable(),
										serverProperty.getIsRequired(),serverProperty.getDafaultVal()});
							}
						}
					}
				}
			}
		}
	}
	
	/**
	 * 对象属性实体	 */
	public class Property{
		String path ; //路径
		String name ; //名称
		String desc ; //描述
		String type ; //类型
		String isEditable ; //是否可编辑
		String isRequired ; //是否必须
		String dafaultVal ; //默认值
		public String getPath() {
			return path;
		}
		public void setPath(String path) {
			this.path = path;
		}
		public String getName() {
			return name;
		}
		public void setName(String name) {
			this.name = name;
		}
		public String getDesc() {
			return desc;
		}
		public void setDesc(String desc) {
			this.desc = desc;
		}
		public String getType() {
			return type;
		}
		public void setType(String type) {
			this.type = type;
		}
		public String getIsEditable() {
			return isEditable;
		}
		public void setIsEditable(String isEditable) {
			this.isEditable = isEditable;
		}
		public String getIsRequired() {
			return isRequired;
		}
		public void setIsRequired(String isRequired) {
			this.isRequired = isRequired;
		}
		public String getDafaultVal() {
			return dafaultVal;
		}
		public void setDafaultVal(String dafaultVal) {
			this.dafaultVal = dafaultVal;
		}
	}
	
	/**
	 * 读取文件内容
	 * @param filePath 文件路径
	 */
	public static String readFile(String filePath) throws FileNotFoundException,IOException {
		Reader reader = new InputStreamReader(new FileInputStream(filePath),"utf-8");
		BufferedReader br = new BufferedReader(reader);
		String xmlLine = new String();
		String xml = new String();
		while((xmlLine = br.readLine()) != null){
			xml+=xmlLine;
		}
		br.close();
		return xml;
	}
	
	
}




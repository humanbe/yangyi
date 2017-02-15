package com.nantian.component.bsa.parameter;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.axis2.AxisFault;
import org.jdom2.Document;
import org.jdom2.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.nantian.common.util.JDOMParserUtil;
import com.nantian.common.util.MyApplicationContextUtil;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.jeda.config.service.SubItemService;

/**
 * BSA参数导入
 * @author linaWang
 *
 */
@Component
public class ParamImport {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ParamImport.class);
	
	@Autowired
	private SubItemService subItemService;
	
	/**
	 * 执行导入操作
	 * @param filePath 参数导入文件路径 eg:D:\\test.xml
	 * @param appsysCode 应用系统编号 eg:MBANK
	 */
	public void doImportParams(String filePath,String appsysCode,String env) throws AxisFault,Exception{
		String policyName = "PLCY_"+env+"_"+appsysCode+"_APPADMIN" ;
		logger.info("BSA属性字典|自定义属性类目录树，导入开始。");
		logger.info("目录树的相关对象权限值为："+policyName);
		//内置属性类服务器目录主路径
		String serverPath = "Class://SystemObject/SERVER";
		ParamImport pi = new ParamImport();
		//应用系统对象
		SubClass sysClass = pi.new SubClass() ; 
		//应用系统对象属性列表
		List<Property> sysClassProperties = null;
		//应用系统分组对象
		List<SubClass> subClassList = null ; 
		//应用系统分组对象属性列表
		List<Property> subClassProperties = null;
		//应用系统分组对象实例列表
		List<Instance> subClassInstances = null;
		//内置属性server目录下的相关属性
		List<Property> serverProperties = null;
		
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null;
		
		//获取平台配置的所有环境
		if(null == subItemService){
			subItemService = (SubItemService) MyApplicationContextUtil.springContext
					.getBean("subItemService");
		}
		List<String> itemList = subItemService.getSubItemByParentId("SYSTEM_ENVIRONMENT");
		
		String xml = importFile(filePath);
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			//应用系统目录
			if(root4.getChildText("path")!=null && !root4.getChildText("path").equals("")){
				sysClass.setPath(root4.getChildText("path"));
			}
			if(root4.getChildText("name")!=null && !root4.getChildText("name").equals("")){
				sysClass.setName(root4.getChildText("name"));
			}
			if(root4.getChildText("desc")!=null && !root4.getChildText("desc").equals("")){
				sysClass.setDesc(root4.getChildText("desc"));
			}
			List<Element> sysAttributes = root4.getChild("attributes").getChildren();
			if(sysAttributes!=null && sysAttributes.size()>0){
				sysClassProperties = new ArrayList<Property>();
				for (Element sysAttribute : sysAttributes) {
					Property p = pi.new Property();
					p.setPath(sysAttribute.getChildText("path"));
					p.setName(sysAttribute.getChildText("name"));
					p.setDesc(sysAttribute.getChildText("desc"));
					p.setType(sysAttribute.getChildText("type"));
					p.setIsEditable(sysAttribute.getChildText("isEditable"));
					p.setIsRequired(sysAttribute.getChildText("isRequired"));
					p.setDafaultVal(sysAttribute.getChildText("defaultVal"));
					sysClassProperties.add(p);
				}
			}
			
			List<Element> subClasses = root4.getChild("subClasses").getChildren("property_class");
			if(subClasses!=null && subClasses.size()>0){
				subClassList = new ArrayList<SubClass>();
				subClassProperties = new ArrayList<Property>();
				subClassInstances = new ArrayList<Instance>();
				for (Element subClass : subClasses) {
					SubClass sc = pi.new SubClass();
					sc.setPath(subClass.getChildText("path"));
					sc.setName(subClass.getChildText("name"));
					sc.setDesc(subClass.getChildText("desc"));
					subClassList.add(sc);
					List<Element> subClassChildAttr = subClass.getChildren("attributes");
					//判断是否存在attributes子节点
					if(subClassChildAttr!=null && subClassChildAttr.size()>0){
						//获取attributes子节点下的attribute节点
						List<Element> subAttributes = subClass.getChild("attributes").getChildren() ;
						if(subAttributes!=null && subAttributes.size()>0){
							for (Element subAttribute : subAttributes) {
								Property p = pi.new Property();
								p.setPath(subAttribute.getChildText("path"));
								p.setName(subAttribute.getChildText("name"));
								p.setDesc(subAttribute.getChildText("desc"));
								p.setType(subAttribute.getChildText("type"));
								p.setIsEditable(subAttribute.getChildText("isEditable"));
								p.setIsRequired(subAttribute.getChildText("isRequired"));
								p.setDafaultVal(subAttribute.getChildText("defaultVal"));
								subClassProperties.add(p);
							}
						}
					}
					List<Element> subClassChildInstance = subClass.getChildren("instances");
					//判断是否存在instances子节点
					if(subClassChildInstance!=null && subClassChildInstance.size()>0){
						//获取instances子节点下的instance节点
						List<Element> instances = subClass.getChild("instances").getChildren();
						if(instances!=null && instances.size()>0){
							for (Element instance : instances) {
								Instance ins = pi.new Instance();
								ins.setPath(instance.getChildText("path"));
								ins.setName(instance.getChildText("name"));
								ins.setDesc(instance.getChildText("desc"));
								subClassInstances.add(ins);
							}
						}
					}
				}
			}
			
			//内置属性类中服务器目录下的系统属性
			List<Element> serverPros = root4.getChild("server_attributes").getChildren("attribute");
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
			logger.info("导入应用系统对象目录，开始");
			//导入应用系统对象目录
			cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassDefined", 
					new String[]{sysClass.getPath()+"/"+sysClass.getName()});
			if(cliResponse.get_return().getSuccess()){
				String isExist = (String)cliResponse.get_return().getReturnValue();
				if(isExist.equals("false")){
					//创建目录
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "createSubClass", 
							new String[]{sysClass.getPath(),sysClass.getName(),sysClass.getDesc()});
				}else{ //目录已存在
//					//删除目录 - 产品缺陷，不能真正删除
//					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "deleteClass", 
//							new String[]{sysClass.getPath()+"/"+sysClass.getName(),"true"}); 
//					//创建目录
//					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "createSubClass", 
//							new String[]{sysClass.getPath(),sysClass.getName(),sysClass.getDesc()});
				}
				cliResponse = cliClient.executeCommandByParamList("PropertyClass", "applyAclPolicy", 
						new String[]{sysClass.getPath()+"/"+sysClass.getName(),policyName});
			}
			logger.info("导入应用系统对象目录，结束");
			logger.info("导入应用系统对象属性，开始");
			//导入应用系统对象属性
			if(sysClassProperties!=null){
				for(Property sysClassProperty : sysClassProperties){
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyDefined", 
							new String[]{sysClassProperty.getPath(),sysClassProperty.getName()});
					if(cliResponse.get_return().getSuccess()){
						String b = (String)cliResponse.get_return().getReturnValue();
						if(b.equals("false")){
							sysClassProperty.setDafaultVal(""); //默认值设为空
							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "addProperty", 
									new String[]{sysClassProperty.getPath(),sysClassProperty.getName(),sysClassProperty.getDesc(),
									sysClassProperty.getType(),sysClassProperty.getIsEditable(),
									sysClassProperty.getIsRequired(),sysClassProperty.getDafaultVal()});
						}
					}
				}
			}
			logger.info("导入应用系统对象属性，结束");
			logger.info("导入应用系统分组对象目录，开始");
			//导入应用系统分组对象目录
			if(subClassList!=null){
				for(SubClass subClass : subClassList){
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassDefined", 
							new String[]{subClass.getPath()+"/"+subClass.getName()});
					if(cliResponse.get_return().getSuccess()){
						String b = (String)cliResponse.get_return().getReturnValue();
						if(b.equals("false")){
							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "createSubClass", 
									new String[]{subClass.getPath(),subClass.getName(),subClass.getDesc()});
						}
						cliResponse = cliClient.executeCommandByParamList("PropertyClass", "applyAclPolicy", 
								new String[]{subClass.getPath()+"/"+subClass.getName(),policyName});
					}
				}
			}
			logger.info("导入应用系统分组对象目录，结束");
			logger.info("导入应用系统分组对象属性，开始");
			//导入应用系统分组对象属性
			if(subClassProperties!=null){
				for(Property subClassProperty : subClassProperties){
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyDefined", 
							new String[]{subClassProperty.getPath(),subClassProperty.getName()});
					if(cliResponse.get_return().getSuccess()){
						String b = (String)cliResponse.get_return().getReturnValue();
						if(b.equals("false")){
							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "addProperty", 
									new String[]{subClassProperty.getPath(),subClassProperty.getName(),subClassProperty.getDesc(),
									subClassProperty.getType(),subClassProperty.getIsEditable(),
									subClassProperty.getIsRequired(),subClassProperty.getDafaultVal()});
						}
					}
				}
			}
			logger.info("导入应用系统分组对象属性，结束");
			logger.info("导入应用系统分组实例，开始");
			//导入应用系统分组实例
			if(subClassInstances!=null){
				for(Instance subClassInstance : subClassInstances){
					String instanceName = "" ;
					//导出文件中的实例名称，eg:OBJ_QCT_APP_01
					String exportName = subClassInstance.getName();
					String[] nameItems = exportName.split("_");
					String exportEnv = "";
					if(nameItems.length > 1){
						exportEnv = nameItems[1];
					}
					if(itemList.contains(exportEnv)){ //导出实例名称包含环境字段，替换
						for(int t=0 ; t<nameItems.length ; t++){
							if(t==1){
								instanceName = instanceName + env + "_" ;
							}else{
								instanceName = instanceName + nameItems[t] + "_";
							}
						}
					}else{ //导出实例名称不包含环境字段，插入
						for(int t=0 ; t<nameItems.length ; t++){
							if(t==0){
								instanceName = nameItems[t] + "_" + env + "_" ;
							}else{
								instanceName = instanceName + nameItems[t] + "_";
							}
						}
					}
					//eg： OBJ_PROV_QCT_WEB_01
					instanceName = instanceName.substring(0,instanceName.length()-1);
					//判断该实例是否存在
					cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyClassInstanceDefined", 
							new String[]{subClassInstance.getPath(),instanceName});
					if(cliResponse.get_return().getSuccess()){
						String b = (String)cliResponse.get_return().getReturnValue();
						if(b.equals("false")){
							//创建实例并授权
							cliResponse = cliClient.executeCommandByParamList("PropertyInstance", "createInstance", 
									new String[]{subClassInstance.getPath(),instanceName,subClassInstance.getDesc()});
						}
						//eg:{Class://SystemObject/CLASS_MBANK_004/APP/OBJ_MBANK_004_APP_01,PLCY_MBANK_APPADMIN} 
						cliResponse = cliClient.executeCommandByParamList("PropertyInstance", "applyAclPolicy", 
								new String[]{subClassInstance.getPath()+"/"+instanceName,policyName});
					}
				}
			}
			logger.info("导入应用系统分组实例，结束");
			logger.info("将应用系统内置属性导入内置属性类服务器目录，开始");
			//将应用系统内置属性导入内置属性类服务器目录
			cliResponse = cliClient.executeCommandByParamList("PropertyClass","isPropertyClassDefined",new String[]{serverPath});
			if(cliResponse.get_return().getSuccess()){
				String isExist = (String)cliResponse.get_return().getReturnValue();
				if(isExist.equals("true")){
					if(serverProperties!=null){
						for(Property serverProperty : serverProperties){
							//导出名称  eg:ATTR_NEXCH_WEB
							String serverProName = serverProperty.getName();
							//导入名称  eg:ATTR_DEV_NEXCH_WEB
							String serverProNameImport = "";
							String[] nameItems = serverProName.split("_");
							String exportEnv = "";
							if(nameItems.length > 1){
								exportEnv = nameItems[1];
							}
							if(itemList.contains(exportEnv)){ //导出名称包含环境字段，替换
								for(int t=0 ; t<nameItems.length ; t++){
									if(t==1){
										serverProNameImport = serverProNameImport + env + "_" ;
									}else{
										serverProNameImport = serverProNameImport + nameItems[t] + "_";
									}
								}
							}else{ //导出名称不包含环境字段，插入
								for(int t=0 ; t<nameItems.length ; t++){
									if(t==0){
										serverProNameImport = nameItems[t] + "_" + env + "_" ;
									}else{
										serverProNameImport = serverProNameImport + nameItems[t] + "_";
									}
								}
							}
							//去掉名称后多余符号"_"
							serverProNameImport = serverProNameImport.substring(0,serverProNameImport.length()-1);
							cliResponse = cliClient.executeCommandByParamList("PropertyClass", "isPropertyDefined", 
									new String[]{serverProperty.getPath(),serverProNameImport});
							if(cliResponse.get_return().getSuccess()){
								String b = (String)cliResponse.get_return().getReturnValue();
								if(b.equals("false")){
									cliResponse = cliClient.executeCommandByParamList("PropertyClass", "addProperty", 
											new String[]{serverProperty.getPath(),serverProNameImport,serverProperty.getDesc(),
											serverProperty.getType(),serverProperty.getIsEditable(),
											serverProperty.getIsRequired(),serverProperty.getDafaultVal()});
								}
							}
						}
					}
				}
			}
			logger.info("将应用系统内置属性导入内置属性类服务器目录，结束");
		}
		logger.info("BSA属性字典|自定义属性类目录树，导入结束");
	}
	
	/**
	 * 统计当前应用系统下需要授权的所有参数数量
	 * @param filePath 参数导入文件路径 eg:D:\\test.xml
	 * @param appsysCode 应用系统编号 eg:MBANK
	 * @return
	 * @throws Exception
	 */
	public int countParamTotal(String filePath,String appsysCode) throws Exception{
		int count = 0;  //应用系统节点授权
		//内置属性类服务器目录主路径
		ParamImport pi = new ParamImport();
		//应用系统对象
		SubClass sysClass = pi.new SubClass() ; 
		//应用系统对象属性列表
		List<Property> sysClassProperties = null;
		//应用系统分组对象
		List<SubClass> subClassList = null ; 
		//应用系统分组对象属性列表
		List<Property> subClassProperties = null;
		//应用系统分组对象实例列表
		List<Instance> subClassInstances = null;
		//内置属性server目录下的相关属性
		List<Property> serverProperties = null;
		
		String xml = importFile(filePath);
		/*String xml = importFile("D:\\test.xml");  //用于测试*/
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			//应用系统目录
			if(root4.getChildText("path")!=null && !root4.getChildText("path").equals("")){
				sysClass.setPath(root4.getChildText("path"));
			}
			if(root4.getChildText("name")!=null && !root4.getChildText("name").equals("")){
				sysClass.setName(root4.getChildText("name"));
			}
			if(root4.getChildText("desc")!=null && !root4.getChildText("desc").equals("")){
				sysClass.setDesc(root4.getChildText("desc"));
			}
			List<Element> sysAttributes = root4.getChild("attributes").getChildren();
			if(sysAttributes!=null && sysAttributes.size()>0){
				sysClassProperties = new ArrayList<Property>();
				for (Element sysAttribute : sysAttributes) {
					Property p = pi.new Property();
					p.setPath(sysAttribute.getChildText("path"));
					p.setName(sysAttribute.getChildText("name"));
					p.setDesc(sysAttribute.getChildText("desc"));
					p.setType(sysAttribute.getChildText("type"));
					p.setIsEditable(sysAttribute.getChildText("isEditable"));
					p.setIsRequired(sysAttribute.getChildText("isRequired"));
					p.setDafaultVal(sysAttribute.getChildText("defaultVal"));
					sysClassProperties.add(p);
				}
			}
			
			List<Element> subClasses = root4.getChild("subClasses").getChildren("property_class");
			if(subClasses!=null && subClasses.size()>0){
				subClassList = new ArrayList<SubClass>();
				subClassProperties = new ArrayList<Property>();
				subClassInstances = new ArrayList<Instance>();
				for (Element subClass : subClasses) {
					SubClass sc = pi.new SubClass();
					sc.setPath(subClass.getChildText("path"));
					sc.setName(subClass.getChildText("name"));
					sc.setDesc(subClass.getChildText("desc"));
					subClassList.add(sc);
					List<Element> subClassChildAttr = subClass.getChildren("attributes");
					//判断是否存在attributes子节点
					if(subClassChildAttr!=null && subClassChildAttr.size()>0){
						//获取attributes子节点下的attribute节点
						List<Element> subAttributes = subClass.getChild("attributes").getChildren() ;
						if(subAttributes!=null && subAttributes.size()>0){
							for (Element subAttribute : subAttributes) {
								Property p = pi.new Property();
								p.setPath(subAttribute.getChildText("path"));
								p.setName(subAttribute.getChildText("name"));
								p.setDesc(subAttribute.getChildText("desc"));
								p.setType(subAttribute.getChildText("type"));
								p.setIsEditable(subAttribute.getChildText("isEditable"));
								p.setIsRequired(subAttribute.getChildText("isRequired"));
								p.setDafaultVal(subAttribute.getChildText("defaultVal"));
								subClassProperties.add(p);
							}
						}
					}
					List<Element> subClassChildInstance = subClass.getChildren("instances");
					//判断是否存在instances子节点
					if(subClassChildInstance!=null && subClassChildInstance.size()>0){
						//获取instances子节点下的instance节点
						List<Element> instances = subClass.getChild("instances").getChildren();
						if(instances!=null && instances.size()>0){
							for (Element instance : instances) {
								Instance ins = pi.new Instance();
								ins.setPath(instance.getChildText("path"));
								ins.setName(instance.getChildText("name"));
								ins.setDesc(instance.getChildText("desc"));
								subClassInstances.add(ins);
							}
						}
					}
				}
			}
			
			//内置属性类中服务器目录下的系统属性
			List<Element> serverPros = root4.getChild("server_attributes").getChildren("attribute");
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
		if(sysClass!=null && !sysClass.getName().equals("")){
			count += 1 ;
		}
		if(sysClassProperties!=null && sysClassProperties.size()>0){
			count += sysClassProperties.size() ;
		}
		if(subClassList!=null && subClassList.size()>0){
			count += subClassList.size() ;
		}
		if(subClassProperties!=null && subClassProperties.size()>0){
			count += sysClassProperties.size() ;
		}
		if(subClassInstances!=null && subClassInstances.size()>0){
			count += sysClassProperties.size() ;
		}
		if(serverProperties!=null && serverProperties.size()>0){
			count += sysClassProperties.size() ;
		}
		return count;
	}
	
	/**
	 * 读取文件内容
	 * @param filePath 文件路径
	 */
	public String importFile(String filePath) throws FileNotFoundException,IOException {
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
	
	
	/**
	 * 对象实体
	 */
	public class SubClass{
		String path ; //对象路径
		String name ; //对象名称
		String desc ; //对象描述
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
	}
	
	/**
	 * 实例实体
	 */
	public class Instance{
		String path ; //实例路径
		String name ; //实例名称
		String desc ; //实例描述
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
	}
	
	/**
	 * 对象属性实体

	 */
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
	
}




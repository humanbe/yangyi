package com.nantian.check.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.utils.CheckParamExport;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
/**
 * 巡检作业导出service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class CheckExportService {

//	/** 日志输出 */
//	private static Logger logger =  Logger.getLogger(CheckExportService.class);
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
	private JobDesignService jobDesignService;
	
	private static String commonSysCode = "COMMON";
	//已存在模板的导出文件后缀
	private static String templateConflict = "_Conflict";
	//用于末班导出的脚本文件
	private static String templateExportScript = "exportTemplate";
	
	/**
	 * 获取BSA组件模板COMMON_CHECK目录的孩子节点	 * @return
	 */
	public String getCommonTempSubNodes() throws AxisFault,Exception {
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "listChildGroupsInGroup", new String[]{"/COMMON_CHECK"});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 获取BSA组件模板SYS_CHECK目录的孩子节点	 * @return
	 */
	public String getAppTempSubNodes() throws AxisFault,Exception{
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "listChildGroupsInGroup", new String[]{"/CHECK"});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 构建模板目录树	 * @param appFiles CHECK目录应用系统子节点	 * @param commonFiles COMMON_CHECK目录二级节点
	 * @return
	 */
	public List<JSONObject> buildTemplateTree(String[] appFiles,String[] commonFiles)throws AxisFault,Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null ;
		List<String> appFileList = new ArrayList<String>();
		List<String> commonFileList = new ArrayList<String>();
		if(appFiles!=null){
			for(int t=0 ; t<appFiles.length ; t++){
				appFileList.add(appFiles[t]);
			}
		}
		if(commonFiles!=null){
			for(int t=0 ; t<commonFiles.length ; t++){
				commonFileList.add(commonFiles[t]);
			}
		}
		List<JSONObject> outJsonList = new ArrayList<JSONObject>();
		JSONObject  cjo =  null;
		JSONObject  cjoSys =  null;
		JSONObject  second =  null; //二级目录
		JSONObject  third =  null; //三级目录
		JSONObject  secondItem =  null; //check目录
		List<JSONObject> cjsonList = null;
		List<JSONObject> cjsonListSys = null;
		JSONObject cjo1 = null;
		JSONObject cjo1Sys = null;
		List<JSONObject> jsonList = null; //第四级目录
		List<JSONObject> jsonListSys = new ArrayList<JSONObject>(); 
		List<JSONObject> jsonListApp = null; 
		
		//COMMON_CHECK目录
		for(int i=0 ; i<commonFileList.size() ; i++){
			cjsonListSys = new ArrayList<JSONObject>();
			cjoSys = new JSONObject();
			cjoSys.put("text", commonFileList.get(i).toString());
			cjoSys.put("iconCls", "node-module");
			cjoSys.put("isType", true);
			cjoSys.put("leaf", false);
			cjoSys.put("checked", false); 
			cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "groupNameToId", new String[]{"/COMMON_CHECK/"+commonFileList.get(i).toString()});
			String templateSysId = "";
			if(cliResponse.get_return().getSuccess()){
				templateSysId = (String)cliResponse.get_return().getReturnValue();
				cliResponse = cliClient.executeCommandByParamList("Template", "listAllByGroup", new String[]{templateSysId}) ;
				String apiSysVal = "";
				if(cliResponse.get_return().getSuccess()){
					apiSysVal = (String)cliResponse.get_return().getReturnValue();
					if(apiSysVal!=null && !apiSysVal.equals("void")){
						String[] apiSysValStr = apiSysVal.split("\n");
						List<String> templatesSys = new ArrayList<String>();
						for(int t=0 ; t<apiSysValStr.length ; t++){
							templatesSys.add(apiSysValStr[t]);
						}
						if(templatesSys!=null){
							for (int t=0 ; t<templatesSys.size() ; t++) {
								if(templatesSys.get(t).toString()!=null ){
									cjo1Sys = new JSONObject();
									cjo1Sys.put("text", templatesSys.get(t).toString());
									cjo1Sys.put("iconCls", "node-leaf");
									cjo1Sys.put("leaf", true);
									cjo1Sys.put("checked", false);
									cjsonListSys.add(cjo1Sys);
								}
							}
						}
					}
				}
			}
			cjoSys.put("children", JSONArray.fromObject(cjsonListSys));
			jsonListSys.add(cjoSys);
		}
		if(jsonListSys!=null){
			secondItem = new JSONObject();
			secondItem.put("text", "COMMON_CHECK");
			secondItem.put("iconCls", "node-module");
			secondItem.put("isType", true);
			secondItem.put("leaf", false);
			secondItem.put("checked", false); 
			secondItem.put("children", JSONArray.fromObject(jsonListSys));
			outJsonList.add(secondItem);
		}
		
		//CHECK目录
		if(appFiles!=null && !appFiles[0].equals("void") ){ 
			jsonListApp = new ArrayList<JSONObject>();
			for(int t=0 ; t<appFileList.size() ; t++){
				String appsys = appFileList.get(t).toString();
				third = new JSONObject();
				third.put("text", appsys);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", false);
				third.put("checked", false); 
				cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "listChildGroupsInGroup", new String[]{"/CHECK/"+appsys});
				String appGroups = "";
				String[] appGroupNames = null;
				if(cliResponse.get_return().getSuccess()){
					appGroups = (String)cliResponse.get_return().getReturnValue();
					if(appGroups!=null && !appGroups.equals("void")){
						appGroupNames = appGroups.split("\n"); //应用系统分组
						jsonList = new ArrayList<JSONObject>(); 
						for(int i=0 ; i<appGroupNames.length ; i++){
							cjsonList = new ArrayList<JSONObject>();
							cjo = new JSONObject();
							cjo.put("text", appGroupNames[i]);
							cjo.put("iconCls", "node-module");
							cjo.put("isType", true);
							cjo.put("leaf", false);
							cjo.put("checked", false); 
							cliResponse = cliClient.executeCommandByParamList("TemplateGroup", "groupNameToId", new String[]{"/CHECK/"+appsys+"/"+appGroupNames[i]});
							String templateId = "";
							if(cliResponse.get_return().getSuccess()){
								templateId = (String)cliResponse.get_return().getReturnValue();
								cliResponse = cliClient.executeCommandByParamList("Template", "listAllByGroup", new String[]{templateId}) ;
								String apiVal = "";
								if(cliResponse.get_return().getSuccess()){
									apiVal = (String)cliResponse.get_return().getReturnValue();
									if(apiVal!=null && !apiVal.equals("void")){
										String[] apiValStr = apiVal.split("\n");
										List<String> templates = new ArrayList<String>();
										for(int m=0 ; m<apiValStr.length ; m++){
											templates.add(apiValStr[m]);
										}
										if(templates!=null){
											for (int n=0 ; n<templates.size() ; n++) {
												if(templates.get(n).toString()!=null ){
													cjo1 = new JSONObject();
													cjo1.put("text", templates.get(n).toString());
													cjo1.put("iconCls", "node-leaf");
													cjo1.put("leaf", true);
													cjo1.put("checked", false);
													cjsonList.add(cjo1);
												}
											}
										}
									}
								}	
							}
							cjo.put("children", JSONArray.fromObject(cjsonList));
							jsonList.add(cjo);
						}
					}
				}
				third.put("children", JSONArray.fromObject(jsonList));
				jsonListApp.add(third);
			}
			if(jsonListApp!=null){
				second = new JSONObject();
				second.put("text", "CHECK");
				second.put("iconCls", "node-module");
				second.put("isType", true);
				second.put("leaf", false);
				second.put("checked", false); 
				second.put("children", JSONArray.fromObject(jsonListApp));
			}
			outJsonList.add(second);
		}
		return outJsonList;
	}
	
	/**
	 * 获取BSA作业COMMON_CHECK目录的孩子节点	 * @return
	 */
	public String getCommonJobSubNodes() throws AxisFault,Exception {
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{"/COMMON_CHECK"});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 获取BSA作业CHECK目录的孩子节点	 * @return
	 */
	public String getAppJobSubNodes() throws AxisFault,Exception{
		CLITunnelServiceClient cliClient;
		ExecuteCommandByParamListResponse cliResponse = null ;
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliResponse = cliClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{"/CHECK"});
		return (String)cliResponse.get_return().getReturnValue();
	}
	
	/**
	 * 构建作业目录树	 * @param appFiles CHECK目录应用系统子节点	 * @param commonFiles COMMON_CHECK目录二级节点
	 * @return
	 */
	public List<JSONObject> buildJobTree(String[] appFiles,String[] commonFiles)throws AxisFault,Exception{
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponse = null ;
		List<String> appFileList = new ArrayList<String>();
		List<String> commonFileList = new ArrayList<String>();
		if(appFiles!=null){
			for(int t=0 ; t<appFiles.length ; t++){
				appFileList.add(appFiles[t]);
			}
		}
		if(commonFiles!=null){
			for(int t=0 ; t<commonFiles.length ; t++){
				commonFileList.add(commonFiles[t]);
			}
		}
		List<JSONObject> outJsonList = new ArrayList<JSONObject>();
		JSONObject  cjo =  null;
		JSONObject  cjoSys =  null;
		JSONObject  second =  null; //二级目录
		JSONObject  third =  null; //三级目录
		JSONObject  secondItem =  null; //check目录
		List<JSONObject> cjsonList = null;
		List<JSONObject> cjsonListSys = null;
		JSONObject cjo1 = null;
		JSONObject cjo1Sys = null;
		List<JSONObject> jsonList = null; //第四级目录
		List<JSONObject> jsonListSys = new ArrayList<JSONObject>(); 
		List<JSONObject> jsonListApp = null; 
		
		//COMMON_CHECK目录
		for(int i=0 ; i<commonFileList.size() ; i++){
			cjsonListSys = new ArrayList<JSONObject>();
			cjoSys = new JSONObject();
			cjoSys.put("text", commonFileList.get(i).toString());
			cjoSys.put("iconCls", "node-module");
			cjoSys.put("isType", true);
			cjoSys.put("leaf", false);
			cjoSys.put("checked", false); 
			cliResponse = cliClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{"/COMMON_CHECK/"+commonFileList.get(i).toString()}) ;
			String apiSysVal = "";
			if(cliResponse.get_return().getSuccess()){
				apiSysVal = (String)cliResponse.get_return().getReturnValue();
				if(apiSysVal!=null && !apiSysVal.equals("void")){
					String[] apiSysValStr = apiSysVal.split("\n");
					List<String> templatesSys = new ArrayList<String>();
					for(int t=0 ; t<apiSysValStr.length ; t++){
						templatesSys.add(apiSysValStr[t]);
					}
					if(templatesSys!=null){
						for (int t=0 ; t<templatesSys.size() ; t++) {
							if(templatesSys.get(t).toString()!=null ){
								cjo1Sys = new JSONObject();
								cjo1Sys.put("text", templatesSys.get(t).toString());
								cjo1Sys.put("iconCls", "node-leaf");
								cjo1Sys.put("leaf", true);
								cjo1Sys.put("checked", false);
								cjsonListSys.add(cjo1Sys);
							}
						}
					}
				}
			}
			cjoSys.put("children", JSONArray.fromObject(cjsonListSys));
			jsonListSys.add(cjoSys);
		}
		if(jsonListSys!=null){
			secondItem = new JSONObject();
			secondItem.put("text", "COMMON_CHECK");
			secondItem.put("iconCls", "node-module");
			secondItem.put("isType", true);
			secondItem.put("leaf", false);
			secondItem.put("checked", false); 
			secondItem.put("children", JSONArray.fromObject(jsonListSys));
			outJsonList.add(secondItem);
		}
		
		//CHECK目录
		if(appFiles!=null && !appFiles[0].equals("void") ){ 
			jsonListApp = new ArrayList<JSONObject>();
			for(int t=0 ; t<appFileList.size() ; t++){
				String appsys = appFileList.get(t).toString();
				third = new JSONObject();
				third.put("text", appsys);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", false);
				third.put("checked", false); 
				cliResponse = cliClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{"/CHECK/"+appsys});
				String appGroups = "";
				String[] appGroupNames = null;
				if(cliResponse.get_return().getSuccess()){
					appGroups = (String)cliResponse.get_return().getReturnValue();
					if(appGroups!=null && !appGroups.equals("void")){
						appGroupNames = appGroups.split("\n"); //应用系统分组
						jsonList = new ArrayList<JSONObject>(); 
						String jobPath = "";
						for(int i=0 ; i<appGroupNames.length ; i++){
							//APP目录下的应用巡检作业不导出							if(!appGroupNames[i].equals("APP") && !appGroupNames[i].equals("TOOLS")){
								cjsonList = new ArrayList<JSONObject>();
								cjo = new JSONObject();
								cjo.put("text", appGroupNames[i]);
								cjo.put("iconCls", "node-module");
								cjo.put("isType", true);
								cjo.put("leaf", false);
								cjo.put("checked", false); 
								jobPath = "/CHECK/"+appsys+"/"+appGroupNames[i];
								cliResponse = cliClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{jobPath}) ;
								String apiVal = "";
								if(cliResponse.get_return().getSuccess()){
									apiVal = (String)cliResponse.get_return().getReturnValue();
									if(apiVal!=null && !apiVal.equals("void")){
										String[] apiValStr = apiVal.split("\n");
										List<String> jobs = new ArrayList<String>();
										for(int m=0 ; m<apiValStr.length ; m++){
											Map<String, Object> map = jobDesignService.getJobCodeByNameAndPath(apiValStr[m],jobPath);
											if(map!=null && !map.isEmpty() && map.size()>0){
												jobs.add(apiValStr[m]);
											}
										}
										if(jobs!=null){
											for (int n=0 ; n<jobs.size() ; n++) {
												if(jobs.get(n).toString()!=null ){
													cjo1 = new JSONObject();
													cjo1.put("text", jobs.get(n).toString());
													cjo1.put("iconCls", "node-leaf");
													cjo1.put("leaf", true);
													cjo1.put("checked", false);
													cjsonList.add(cjo1);
												}
											}
										}
									}
								}	
								cjo.put("children", JSONArray.fromObject(cjsonList));
								jsonList.add(cjo);
							}
						}
					}
				}
				third.put("children", JSONArray.fromObject(jsonList));
				jsonListApp.add(third);
			}
			if(jsonListApp!=null){
				second = new JSONObject();
				second.put("text", "CHECK");
				second.put("iconCls", "node-module");
				second.put("isType", true);
				second.put("leaf", false);
				second.put("checked", false); 
				second.put("children", JSONArray.fromObject(jsonListApp));
			}
			outJsonList.add(second);
		}
		return outJsonList;
	}
	
	/**
	 * 执行文件的导出操作	 * @param exportFileType 导出文件类型（组件模板-template,巡检作业-job,扩展对象-extends）	 * @param exportFiles 导出文件
	 * @throws AxisFault,Exception 
	 */
	@SuppressWarnings("unchecked")
	public void doCheckExport(String exportFileType,String exportFiles) throws AxisFault,Exception{
		//导出文件列表
		List<Map<String, Object>> listExportFiles = null ; 
		String sourceFilePath = null;
		String zipFilePath = null;
		File sourceFile = null;
		String objectType = null;
		String fileType = null;
		String jobDBData = null;
		if(exportFiles!=null && !exportFiles.equals("")){
			JSONArray arrayTemplates = JSONArray.fromObject(exportFiles);
			//将json格式的数据转换成list对象
			listExportFiles = (List<Map<String, Object>>) JSONArray.toCollection(arrayTemplates, Map.class);
			
			//BSA登陆
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
			//创建目录
			mkdir(exportFileType);
			//遍历导出文件
			for (int i=0;i<listExportFiles.size();i++) {
				String exportFileName = (String) listExportFiles.get(i).get("file_name");
				String exportFileGroup = (String) listExportFiles.get(i).get("file_group");
				String exportFileGroupAndName = exportFileGroup.replace("/", "@").concat("#").concat(exportFileName);
				if(exportFileType.equals("template")){
					fileType = "Template";
					objectType = "250";
					//导出的模本路径更改为临时目录 - 用于导入已存在的模板
					doCheckExportForTemplateConflict(exportFileType,listExportFiles.get(i));
				}else if(exportFileType.equals("job")){
					fileType = "ComplianceJob";
					objectType = "5106";
				}
				
				//动态创建导出作业 (作业路径，作业名称，作业描述，脚本路径，脚本名称，服务器IP，序号)
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),
						"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob"),messages.getMessage("bsa.ipAddress"),"3"});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//动态创建打包作业				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),
						"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(".nsh"),messages.getMessage("bsa.ipAddress"),"2"});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//创建删除作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),
						"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//获取删除作业的DBkey
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName",
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String DeleteDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				//清除删除作业的所有参数
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//删除作业赋值
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),
						"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux"))});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),"1",exportFileGroupAndName});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//执行删除作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DeleteDBkey});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//获取导出作业的DBkey
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				//获取导出文件的DBkey
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(fileType, "getDBKeyByGroupAndName", new String[]{exportFileGroup,exportFileName});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String DBkey2=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				//清除导出作业的所有参数
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//导出作业参数赋值（作业路径,作业名称,参数索引,参数值）
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),"0",objectType});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),"1",DBkey2});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
								
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),
						"2",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux")).concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//执行导出作业(导出文件为2个xml文件)
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//获取打包文件的DBkey
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String dBkeyZip=(String) executeCommandByParamListResponse.get_return().getReturnValue();
                //清除打包文件的所有参数
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//打包文件赋值
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),
						"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux"))});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName",
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),"1",exportFileGroupAndName});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				//执行打包文件（将导出的2个xml文件达成tar包）
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyZip});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				//删除临时导出作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
				//删除临时打包作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
						new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
				
				if(ComUtil.isWindows){
					sourceFilePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipPath")).concat(File.separator).concat(exportFileType).concat(File.separator).concat(exportFileGroupAndName).concat(File.separator);
					zipFilePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipPath")).concat(File.separator).concat(exportFileType).concat(File.separator);

				}else{
					sourceFilePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipPathForLinux")).concat(File.separator).concat(exportFileGroupAndName).concat(File.separator);
					zipFilePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipPathForLinux")).concat(File.separator);

				}
				sourceFile = new File(sourceFilePath);
				if(!sourceFile.exists()){
					sourceFile.mkdirs();
				}
				//BSA导出的文件上传到FTP
				exportFtp(sourceFilePath.concat(exportFileGroupAndName).concat(".tar"),exportFileGroupAndName,exportFileType);
				//导出作业的数据库文件
				if(exportFileType.equals("job")){
					jobDBData = exportDBData(exportFileName,exportFileGroup); 
					printWriterFile(jobDBData,sourceFilePath,exportFileGroupAndName);                                 
				}
				//导出巡检参数
				CheckParamExport checkParamExport = new CheckParamExport();
				String xml = checkParamExport.doExportParams();
				//巡检参数导出文件上传倒FTP
				exportFile(xml,sourceFilePath.concat(exportFileGroupAndName).concat("Param").concat(".xml"));
				//文件打包（将tar包与巡检参数xml文件打成zip包）
				fileToZip(sourceFilePath, zipFilePath,exportFileGroupAndName);
				//打包文件上传到FTP
				ftpPutFileServer(zipFilePath.concat(exportFileGroupAndName).concat(".zip"),exportFileGroupAndName,exportFileType);
				//删除文件
				delFile(zipFilePath.concat(exportFileGroupAndName).concat(".zip"));
				delAllFile(sourceFilePath);
			}
		}
	}
	
	/**
	 * 数据写入到文件中.
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void exportFile(String xmlFile,String filePath) throws UnsupportedEncodingException, FileNotFoundException{
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath),"utf-8"));
			out.println(xmlFile);
			out.flush();
			out.close();
	}


	/**
	 * FTP获取文件
	 * @param  String localPath,String appsys_code
	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 */
	@Transactional
	public void exportFtp(String localPath,String exportFileGroupAndName,String exportFileType) throws NoSuchMessageException, IOException {
		String host=messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		
		ftpFile.doMkdirs(messages.getMessage("bsa.moveFilePath"),messages.getMessage("path.linux").concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType));
		ftpLogin.disconnect();
		
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		
		ftpFile2.doGet(messages.getMessage("bsa.moveFilePath").concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux")).concat(exportFileGroupAndName).concat(".tar"), localPath, true,new StringBuffer());
		ftpLogin2.disconnect();
	}
	
	/**
	 * ftp到bsa服务器	 * @param String appsys_code,String path1,String path2
	 */
	@Transactional
	public void mkdir(String exportFileType) {
		String host = messages.getMessage("bsa.fileServerIp");// "10.200.36.191";
		Integer port = Integer.valueOf(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host, port, user, password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		
		ftpFile.doMkdir(exportFileType, new StringBuffer());
		ftpLogin.disconnect();
	}
	
	/**
	 * FTP发送文件
	 * @param  String localFilename,String appsys_code,String bmc
	 * @throws AxisFault 
	 */
	@Transactional
	public void ftpPutFileServer(String localFilename,String exportFileGroupAndName,String exportFileType) throws AxisFault,Exception {
		String host=messages.getMessage("exportServer.ipAdress");
		int port = (Integer.parseInt(messages.getMessage("exportServer.port")));
		String user = messages.getMessage("exportServer.user");
		String password=messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String remoteFilename = "";
		
		String existDir = messages.getMessage("exportServer.path.check");
		String inexistDir = messages.getMessage("exportServer.checkPath").concat(messages.getMessage("path.linux")).concat(exportFileType);
		ftpFile.doMkdirs(existDir,inexistDir);
		ftpLogin.disconnect();
		
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		remoteFilename = messages.getMessage("exportServer.path.check").concat(messages.getMessage("path.linux")).concat( messages.getMessage("exportServer.checkPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux")).concat(exportFileGroupAndName).concat(".zip");
        ftpFile2.doPut(localFilename, remoteFilename, true,new StringBuffer());
		ftpLogin2.disconnect();
	}
	
	/**
	 * 
	 * 删除指定文件
	 * @param path String 文件夹路径	 */
	public void delFile(String path){
		File file = new File(path);
	    if(file.isFile() && file.exists()){
	    	file.delete();
	    } 
	}
	
	/**
	 * 删除文件夹里面的所有文件	 * @param path String 文件夹路径	 */
	public void delAppZipFile(String path,String exportFileType) {
		File file = new File(path);
		if (!file.exists()) {
			return;
		}
		if (!file.isDirectory()) {
			return;
		}
		String[] tempList = file.list();
		File temp = null;
		for (int i = 0; i < tempList.length; i++) {
			temp = new File(path.concat(File.separator).concat(tempList[i]));
			if (temp.isFile() &&
				(temp.getAbsoluteFile().getName().indexOf(exportFileType.concat(CommonConst.FILE_SUFFIX_ZIP)) != -1
				|| temp.getAbsoluteFile().getName().indexOf(exportFileType.concat(CommonConst.FILE_SUFFIX_TAR)) != -1)) {
				temp.delete();
			}
		}
	}
	
	/**
	 * 删除文件夹里面的所有文件	 * @param path String 文件夹路径	 */
	public void delAllFile(String path) {
		File file = new File(path);
		if (!file.exists()) {
			return;
		}
		if (!file.isDirectory()) {
			return;
		}
		String[] tempList = file.list();
		File temp = null;
		for (int i = 0; i < tempList.length; i++) {
			temp = new File(path.concat(File.separator).concat(tempList[i]));
			if (temp.isDirectory()) {
				delAllFile(path.concat( File.separator).concat(tempList[i]) );// 先删除文件夹里面的文件
			}
			temp.delete();
		}
	}
	
	//导出当前作业的数据库信息
	public String exportDBData(String jobName,String jobPath){
		String dbDataXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" ;
		String[] fullPath = jobPath.split("/");
		String appsysCode = "";
		String filedType = "";
		if(fullPath.length>3){   //CHECK目录   eg:/CHECK/NEXCH/OS
			appsysCode = fullPath[2];
			filedType = fullPath[3];
		}else{  //common目录   eg:/COMMON_CHECK/OS
			appsysCode = commonSysCode;
			filedType = fullPath[2];
		}
		//获取CheckJobInfoVo数据
		Map<String, Object> jobInfo = jobDesignService.getJedaJobBySysAndFieldAndName(appsysCode,filedType,jobName);
		if(jobInfo!=null){
			int jobCodeJade =  Integer.valueOf(jobInfo.get("job_code").toString());
			//获取CheckJobTemplateVo数据
			List<Map<String, Object>> jobTemplates = jobDesignService.getTemplatesByJobCode(jobCodeJade);
			//获取CheckJobServerVo数据
			List<Map<String, Object>> serverInfos = jobDesignService.getServersByJobCode(jobCodeJade);
			//获取CheckJobTimerVo数据
			List<Map<String, Object>> timerInfos = jobDesignService.getTimersByJobCode(jobCodeJade);
			//作业基本信息
			dbDataXml += "<CheckJobInfoVo>" ;
			dbDataXml += "<appsys_code>"+jobInfo.get("appsys_code")+"</appsys_code>" ;
			dbDataXml += "<job_code>"+jobInfo.get("job_code")+"</job_code>" ;
			dbDataXml += "<check_type>"+jobInfo.get("check_type")+"</check_type>" ;
			dbDataXml += "<authorize_lever_type>"+jobInfo.get("authorize_lever_type")+"</authorize_lever_type>" ;
			dbDataXml += "<field_type>"+jobInfo.get("field_type")+"</field_type>" ;
			dbDataXml += "<job_name>"+jobInfo.get("job_name")+"</job_name>" ;
			dbDataXml += "<job_path>"+jobInfo.get("job_path")+"</job_path>" ;
			dbDataXml += "<job_type>"+jobInfo.get("job_type")+"</job_type>" ;
			dbDataXml += "<job_desc>"+jobInfo.get("job_desc")+"</job_desc>" ;
			dbDataXml += "<tool_status>"+jobInfo.get("tool_status")+"</tool_status>" ;
			dbDataXml += "<frontline_flag>"+jobInfo.get("frontline_flag")+"</frontline_flag>" ;
			dbDataXml += "<authorize_flag>"+jobInfo.get("authorize_flag")+"</authorize_flag>" ;
			dbDataXml += "<delete_flag>"+jobInfo.get("delete_flag")+"</delete_flag>" ;
			dbDataXml += "<tool_creator>"+jobInfo.get("tool_creator")+"</tool_creator>" ;
			
			//作业模板信息
			if(jobTemplates!=null && jobTemplates.size()>0){
				dbDataXml += "<CheckJobTemplateVos>" ;
				for(Map<String, Object> map : jobTemplates){
					dbDataXml += "<CheckJobTemplateVo>" ;
					dbDataXml += "<appsys_code>"+map.get("appsys_code")+"</appsys_code>" ;
					dbDataXml += "<job_code>"+map.get("job_code")+"</job_code>" ;
					dbDataXml += "<template_group>"+map.get("template_group")+"</template_group>" ;
					dbDataXml += "<template_name>"+map.get("template_name")+"</template_name>" ;
					dbDataXml += "</CheckJobTemplateVo>" ;
				}
				dbDataXml += "</CheckJobTemplateVos>" ;
			}
			//作业服务器信息			if(serverInfos!=null && serverInfos.size()>0){
				dbDataXml += "<CheckJobServerVos>" ;
				for(Map<String, Object> map : serverInfos){
					dbDataXml += "<CheckJobServerVo>" ;
					dbDataXml += "<appsys_code>"+map.get("appsys_code")+"</appsys_code>" ;
					dbDataXml += "<job_code>"+map.get("job_code")+"</job_code>" ;
					dbDataXml += "<server_group>"+map.get("server_path")+"</server_group>" ;
					dbDataXml += "<server_ip>"+map.get("server_name")+"</server_ip>" ;
					dbDataXml += "</CheckJobServerVo>" ;
				}
				dbDataXml += "</CheckJobServerVos>" ;
			}
			//作业时间表信息			if(timerInfos!=null && timerInfos.size()>0){
				dbDataXml += "<CheckJobTimerVos>" ;
				for(Map<String, Object> map : timerInfos){
					dbDataXml += "<CheckJobTimerVo>" ;
					dbDataXml += "<appsys_code>"+map.get("appsys_code")+"</appsys_code>" ;
					dbDataXml += "<job_code>"+map.get("job_code")+"</job_code>" ;
					dbDataXml += "<timer_code>"+map.get("timer_code")+"</timer_code>" ;
					dbDataXml += "<exec_freq_type>"+map.get("exec_freq_type")+"</exec_freq_type>" ;
					dbDataXml += "<exec_start_date>"+map.get("exec_start_date")+"</exec_start_date>" ;
					dbDataXml += "<exec_start_time>"+map.get("exec_start_time")+"</exec_start_time>" ;
					dbDataXml += "<week1_flag>"+map.get("week1_flag")+"</week1_flag>" ;
					dbDataXml += "<week2_flag>"+map.get("week2_flag")+"</week2_flag>" ;
					dbDataXml += "<week3_flag>"+map.get("week3_flag")+"</week3_flag>" ;
					dbDataXml += "<week4_flag>"+map.get("week4_flag")+"</week4_flag>" ;
					dbDataXml += "<week5_flag>"+map.get("week5_flag")+"</week5_flag>" ;
					dbDataXml += "<week6_flag>"+map.get("week6_flag")+"</week6_flag>" ;
					dbDataXml += "<week7_flag>"+map.get("week7_flag")+"</week7_flag>" ;
					dbDataXml += "<interval_weeks>"+map.get("interval_weeks")+"</interval_weeks>" ;
					dbDataXml += "<month_day>"+map.get("month_days")+"</month_day>" ;
					dbDataXml += "<interval_days>"+map.get("interval_days")+"</interval_days>" ;
					dbDataXml += "<interval_hours>"+map.get("interval_hours")+"</interval_hours>" ;
					dbDataXml += "<interval_minutes>"+map.get("interval_minutes")+"</interval_minutes>" ;
					dbDataXml += "<exec_priority>"+map.get("exec_priority")+"</exec_priority>" ;
					dbDataXml += "<exec_notice_mail_list>"+map.get("exec_notice_mail_list")+"</exec_notice_mail_list>" ;
					dbDataXml += "<mail_success_flag>"+map.get("mail_success_flag")+"</mail_success_flag>" ;
					dbDataXml += "<mail_failure_flag>"+map.get("mail_failure_flag")+"</mail_failure_flag>" ;
					dbDataXml += "<mail_cancel_flag>"+map.get("mail_cancel_flag")+"</mail_cancel_flag>" ;
					dbDataXml += "</CheckJobTimerVo>" ;
				}
				dbDataXml += "</CheckJobTimerVos>" ;
			}
			dbDataXml += "</CheckJobInfoVo>" ;
		}
		return dbDataXml ;
	}
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void printWriterFile(String xmlFile,String filePath,String fileName) throws UnsupportedEncodingException, FileNotFoundException{
			File file = new File(filePath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath.concat(File.separator).concat(fileName).concat(".xml")),"utf-8"));
			out.println(xmlFile);
			out.flush();
			out.close();
	}
	
	/**
	 * ftp到bsa服务器	 * @param String
	 *            appsys_code,String path1,String path2
	 */
	@Transactional
	public void importFtp(String path1, String path2) {
		String host = messages.getMessage("bsa.fileServerIp");// "10.200.36.191";
		Integer port = Integer.valueOf(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host, port, user, password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doPut(path1, path2, true, new StringBuffer());
		ftpLogin.disconnect();
	}
	
	/**
	 * 文件打包成zip压缩包.
	 * @param String sourceFilePath, String zipFilePath,String fileName
	 * @throws IOException
	 */
	public  boolean fileToZip(String sourceFilePath, String zipFilePath,
			String fileName) throws IOException {
		boolean flag = false;
		File sourceFile = new File(sourceFilePath);
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		FileOutputStream fos = null;
		ZipOutputStream zos = null;
		if (sourceFile.exists() == false) {
		} else {
				File zipFile = new File(zipFilePath.concat(File.separator).concat(fileName).concat(".zip"));
				if (zipFile.exists()) {
					
				} else {
					File[] sourceFiles = sourceFile.listFiles();
					if (null == sourceFiles || sourceFiles.length < 1) {
						
					} else {
						fos = new FileOutputStream(zipFile );
						zos = new ZipOutputStream(new BufferedOutputStream(fos));
						zos.setEncoding("gbk");
						byte[] bufs = new byte[1024 * 10];
						for (int i = 0; i < sourceFiles.length; i++) {
							try {
								// 创建ZIP实体,并添加进压缩包								ZipEntry zipEntry = new ZipEntry(sourceFiles[i].getName());
								zos.putNextEntry(zipEntry);
								// 读取待压缩的文件并写进压缩包里								fis = new FileInputStream(sourceFiles[i]);
								bis = new BufferedInputStream(fis, 1024 * 10);
								int read = 0;
								while ((read = bis.read(bufs, 0, 1024 * 10)) != -1) {
									zos.write(bufs, 0, read);
								}
							} catch (IOException e) {
								e.printStackTrace();
							}finally{
								if (null != bis){
									bis.close();
								}
								if (null != fis){
									fis.close();
								}
							}
						}
						flag = true;
					}
				}
				if (null != zos){
					zos.close();
				}
				if (null != fos){
					fos.close();
				}
			}
		return flag;
	}
	
	/**
	 * 执行文件的导出操作
	 * @param exportFileType 导出文件类型（组件模板-template,巡检作业-job,扩展对象-extends）
	 * @param exportFiles 导出文件
	 * @throws AxisFault,Exception 
	 */
	public void doCheckExportForTemplateConflict(String exportFileType,Map<String, Object> listExportFile) 
			throws AxisFault,Exception{
		String sourceFilePath = null;
		String zipFilePath = null;
		File sourceFile = null;
		String objectType = null;
		String fileType = null;
		//BSA登陆
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		mkdir(exportFileType);
		
		String exportFileName = (String) listExportFile.get("file_name");
		String exportFileGroup = ((String) listExportFile.get("file_group"));
		String exportFileGroupAndName = exportFileGroup.replace("/", "@").concat("#").concat(exportFileName).concat(templateConflict);
		fileType = "Template";
		objectType = "250";
		
		//动态创建导出作业（作业路径，作业名称，作业描述，脚本路径，脚本名称，服务器IP,序号）
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),
				"",messages.getMessage("bsa.moveJobPath"),templateExportScript,messages.getMessage("bsa.ipAddress"),"3"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//动态创建打包作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),
				"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(".nsh"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),
				"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName",
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DeleteDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),
				"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux"))});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName),"1",exportFileGroupAndName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DeleteDBkey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(fileType, "getDBKeyByGroupAndName", new String[]{exportFileGroup,exportFileName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey2=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),"0",objectType});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),"1",DBkey2});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
						
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),
				"2",messages.getMessage("bsa.moveFilePath").concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux")).concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName),
				"3",messages.getMessage("bsa.fileServerIp")});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String dBkeyZip=(String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),
				"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(exportFileType).concat(messages.getMessage("path.linux"))});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName",
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName),"1",exportFileGroupAndName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyZip});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		//删除临时导出作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob").concat(exportFileGroupAndName)});
		//删除临时打包作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.zipJob").concat(exportFileGroupAndName)});
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(exportFileGroupAndName)});
		if(ComUtil.isWindows){
			sourceFilePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipPath")).concat(File.separator).concat(exportFileType).concat(File.separator).concat(exportFileGroupAndName).concat(File.separator);
			zipFilePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipPath")).concat(File.separator).concat(exportFileType).concat(File.separator);

		}else{
			sourceFilePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipPathForLinux")).concat(File.separator).concat(exportFileGroupAndName).concat(File.separator);
			zipFilePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipPathForLinux")).concat(File.separator);

		}
		sourceFile = new File(sourceFilePath);
		if(!sourceFile.exists()){
			sourceFile.mkdirs();
		}
        //BSA导出文件上传到FTP
		exportFtp(sourceFilePath.concat(exportFileGroupAndName).concat(".tar"),exportFileGroupAndName,exportFileType);
		//巡检参数导出
		CheckParamExport checkParamExport = new CheckParamExport();
		String xml = checkParamExport.doExportParams();
		//将巡检导出参数上传到FTP
		exportFile(xml,sourceFilePath.concat(exportFileGroupAndName).concat("Param").concat(".xml"));
		//文件打包
		fileToZip(sourceFilePath, zipFilePath,exportFileGroupAndName);
		//文件上传到FTP
		ftpPutFileServer(zipFilePath.concat(exportFileGroupAndName).concat(".zip"),exportFileGroupAndName,exportFileType);
		//删除文件
		delFile(zipFilePath.concat(exportFileGroupAndName).concat(".zip"));
		delAllFile(sourceFilePath);
	}
	
	
	
}




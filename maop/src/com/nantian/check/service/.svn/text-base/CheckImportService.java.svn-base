package com.nantian.check.service;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.SocketTimeoutException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.utils.CheckParamImport;
import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.check.vo.CheckJobServerVo;
import com.nantian.check.vo.CheckJobTemplateVo;
import com.nantian.check.vo.CheckJobTimerVo;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;

/**
 * 巡检数据迁移-导入service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class CheckImportService {

	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(CheckImportService.class);

	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	private JobDesignService jobDesignService;
	
	private static final int buffer = 1;
	//已存在模板的导出文件后缀
	private static String templateConflict = "_Conflict";
	//临时模板路径前缀
	private static String tempTemplatePath = "/COMMON_CHECKTMP/";
	private static String commonTemplatePath = "/COMMON_CHECK/";
	
	/**
	 * 获取FTP上可导入的资源文件	 * @param importFileType 导入的文件类型（巡检作业-job,模板-template）	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 */
	@Transactional(readOnly = true)
	public List<Map<String, String>> getImportabledFileList(String importFileType,String userId) throws NoSuchMessageException, IOException {
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
		//创建FTP目录
		String existDir = messages.getMessage("importServer.path.check");
		String inexistDir = messages.getMessage("importServer.checkPath").concat(messages.getMessage("path.linux")).concat(importFileType);
		componentFtp.doMkdirs(existDir,inexistDir);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		
		String[] doGetFilesNamelist = ftpFile2.doGetFilesNamelist(messages.getMessage("importServer.path.check").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.checkPath")).concat(messages.getMessage("path.linux")).concat(importFileType));
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		for(int i=0;i<doGetFilesNamelist.length;i++){
			Map<String,String> map = new HashMap<String,String>();
			if(doGetFilesNamelist[i].indexOf(templateConflict)<0){
				map.put("file_group", doGetFilesNamelist[i].split("#")[0].replace("@", "/"));
				map.put("file_name", doGetFilesNamelist[i].split("#")[1]);
				jsonMapList.add(map);
			}
		}
		ftpLogin2.disconnect();
		return jsonMapList;
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
				delAllFile(path.concat( File.separator).concat(tempList[i]) );// 先删除文件夹里面的文件			}
			temp.delete();
		}
	}
	
	/**
	 * 执行文件的导入操作
	 * 说明：FTP上的CHECK目录需要手动创建，其下的子目录自动创建
	 * @param importFileType 导入的文件类型（巡检作业-job,模板-template）	 * @param importFiles 待导入文件	 * @throws Throwable 
	 * @throws Exception 
	 * @throws IOException 
	 * @throws SocketTimeoutException 
	 */
	@SuppressWarnings("unchecked")
	public String doCheckImport(String importFileType,String importFiles,String userId) throws SocketTimeoutException, IOException, Exception, Throwable{
		String fileExists = "";
		//导入文件列表
		List<Map<String, Object>> listImportFiles = null ; 
		if(importFiles!=null && !importFiles.equals("")){
			JSONArray arrayFiles = JSONArray.fromObject(importFiles);
			//将json格式的数据转换成list对象
			listImportFiles = (List<Map<String, Object>>) JSONArray.toCollection(arrayFiles, Map.class);
			//资源文件导入操作
			String host = messages.getMessage("importServer.ipAdress");
			Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
			String user = messages.getMessage("importServer.user");
			String password = messages.getMessage("importServer.password");
			ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
			ftpLogin.connect(host,port,user,password);
			ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
			
			String fileType = "";
			if(importFileType.equals("template")){
				fileType = "Template";
			}else if(importFileType.equals("job")){
				fileType = "ComplianceJob";
			}
			LoginServiceClient loginClient = null;
			LoginUsingUserCredentialResponse loginResponse = null;
			//遍历导入文件
			for (int i=0;i<listImportFiles.size();i++) {
				String importFileName = (String) listImportFiles.get(i).get("file_name");
				String importFileGroup = (String) listImportFiles.get(i).get("file_group");
				String importFileGroupAndName = importFileGroup.replace("/", "@").concat("#").concat(importFileName);
				
				// 用户登录
				loginClient = new LoginServiceClient(
						messages.getMessage("bsa.userName"),
						messages.getMessage("bsa.userPassword"),
						messages.getMessage("bsa.authenticationType"), null,
						System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
						messages.getMessage("bsa.truststoreFilePassword"));
				loginResponse = loginClient.loginUsingUserCredential();
				
				CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse response = null;
				//获取BDkey，判断该作业/模板是否已存在
				response = cliTunnelServiceClient.executeCommandByParamList(fileType,"getDBKeyByGroupAndName",new String[] {importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
				String fileDBkey = (String) response.get_return().getReturnValue();
				if(importFileType.equals("job")){ //导入作业
					if(!fileDBkey.equals("void")){ //同名作业已存在
						deleteJobByGroupAndName(importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip")));
					}
					importNoConflict(importFileGroupAndName,importFileType,userId,importFileGroup,importFileName,componentFtp);
				}else if(importFileType.equals("template")){ //导入模板
					if(!fileDBkey.equals("void")){ //同名模板存在
						importFileGroupAndName = importFileGroupAndName.substring(0, importFileGroupAndName.indexOf(".zip")).concat(templateConflict).concat(".zip");
						importFileGroup = importFileGroup.replace(commonTemplatePath,tempTemplatePath);
						importNoConflict(importFileGroupAndName,importFileType,userId,importFileGroup,importFileName,componentFtp);
						//获取临时模板的BDkey
						response = cliTunnelServiceClient.executeCommandByParamList(fileType,"getDBKeyByGroupAndName",
								new String[] {importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
						String fileDBkeyNew = (String) response.get_return().getReturnValue();
						//获取原有模板的BDkey
						String fieldType  = importFileGroup.substring(importFileGroup.lastIndexOf("/")+1);
						response = cliTunnelServiceClient.executeCommandByParamList("Template","getDBKeyByGroupAndName",
								new String[] {commonTemplatePath.concat(fieldType),importFileName.substring(0, importFileName.indexOf(".zip"))});
						String fileDBkeyOld = (String) response.get_return().getReturnValue();
						//临时模板替换原有模板
						response = cliTunnelServiceClient.executeCommandByParamList("Template","updateByDBKey",
								new String[] {fileDBkeyNew,fileDBkeyOld});
						//删除临时模板
						response = cliTunnelServiceClient.executeCommandByParamList("Template","deleteTemplate",
								new String[] {importFileName.substring(0, importFileName.indexOf(".zip")),importFileGroup});
					}else{
						importNoConflict(importFileGroupAndName,importFileType,userId,importFileGroup,importFileName,componentFtp);
					}
					//增加配置属性默认值
					cliTunnelServiceClient.executeCommandByParamList("PropertyClass","setDefaultValue",
							new String[] {"Class://SystemObject/Server", "CHECK_STOREPATH", messages.getMessage("check.bsa.CHECK_STOREPATH")});
					cliTunnelServiceClient.executeCommandByParamList("PropertyClass","setDefaultValue",
							new String[] {"Class://SystemObject/Server", "CHECK_SYSLOGPATH", messages.getMessage("check.bsa.CHECK_SYSLOGPATH")});
				}
			}
			ftpLogin.disconnect();
		}
		if(fileExists.length()!=0){
			fileExists = fileExists.substring(0,fileExists.lastIndexOf(","))+ "<br>";
		}
		return fileExists;
	}
	
	
	/**
	 * 导入bsa
	 * 
	 * @param appsys_code
	 * @throws Exception
	 * @throws IOException Throwable
	 */
	public void doImportBsa(String importFileGroupAndName,String userId,String localFilename,String bsaFileImpPath,String importFileType) throws IOException,SocketTimeoutException, Exception, Throwable {
		if(ComUtil.isWindows){
			localFilename = localFilename.concat(messages.getMessage("path.linux")).concat(importFileGroupAndName).concat(".tar");
		}else{
			localFilename = localFilename.concat(File.separator).concat(importFileGroupAndName).concat(".tar");
		}
		
		importFtp(localFilename,bsaFileImpPath,importFileType);
		delFile(localFilename);
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
		
		// 用户登录
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userName"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
				messages.getMessage("bsa.truststoreFilePassword"));
		loginResponse = loginClient.loginUsingUserCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(".nsh"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String UnzipDBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName) });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName),"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName), "1", importFileGroupAndName });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",
				new String[] { UnzipDBkey });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//删除临时作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(importFileGroupAndName)});
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", 
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String importDBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName) ,"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName) });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",
				new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName),"1",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName).concat(messages.getMessage("path.linux")).concat("mapping.xml")});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { importDBkey });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//删除临时作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(importFileGroupAndName)});
	}
	
	
	/**
	 * ftp到bsa服务器	 * @param String appsys_code,String path1,String path2
	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 */
	@Transactional
	public void importFtp(String path1, String path2,String importFileType) throws NoSuchMessageException, IOException {
		String host = messages.getMessage("bsa.fileServerIp");// "10.200.36.191";
		Integer port = Integer.valueOf(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host, port, user, password);
		
		/*ftpFile.doMkdir(messages.getMessage("bsa.deployPath").substring(1,messages.getMessage("bsa.deployPath").length()-2), new StringBuffer());
		ftpLogin.disconnect();		
		
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdir(importFileType, new StringBuffer());
		ftpLogin.disconnect();*/
		
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdirs(messages.getMessage("bsa.moveFilePath"),messages.getMessage("path.linux").concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType));
		ftpLogin.disconnect();
		
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doPut(path1, path2, true, new StringBuffer());
		ftpLogin2.disconnect();
	}
	
	/**
	 * 删除指定文件
	 * @param path String 文件夹路径	 * @return flag
	 */

	public void delFile(String path) {
		File file = new File(path);
		if (file.isFile() && file.exists()) {
			file.delete();
		}
	}
	
	/**
	 * 删除bsa服务器上的文件	 * @param String appsys_code,String path1,String path2
	 * @throws AxisFault,Exception 
	 */
	@Transactional
	public void deleteBsaFile(String importFileGroupAndName,String importFileType) throws AxisFault,Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
		
		// 用户登录
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userName"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
				messages.getMessage("bsa.truststoreFilePassword"));
		loginResponse = loginClient.loginUsingUserCredential();
		
		importFileGroupAndName = importFileGroupAndName.substring(0,importFileGroupAndName.indexOf(".zip"));
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String deleteDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName),"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux"))});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName),"1",importFileGroupAndName});//.split("#")[0]
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{deleteDBkey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//删除临时作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", 
				new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(importFileGroupAndName)});
	}
	
	/**
	 * FTP在文件服务器备份文件
	 * 
	 * @param customer
     * @throws IOException 
	 */
	@Transactional
	public void ftpDelToolstar(String from,String to,String fileType,String delFtpPath) throws FtpCmpException, IOException {
		String host = messages.getMessage("exportServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("exportServer.user");
		String password = messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String existDir = messages.getMessage("exportServer.path.check");
		String inexistDir = messages.getMessage("exportServer.bakPath").concat(messages.getMessage("path.linux")).concat(messages.getMessage("exportServer.checkPath")).concat(messages.getMessage("path.linux")).concat(fileType)
				.concat(messages.getMessage("path.linux")).concat(new SimpleDateFormat("yyyyMMdd").format(new Date()));
		ftpFile.doMkdirs(existDir,inexistDir);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
        ftpFile2.renamelFile(from, to); //备份导入压缩文件
        ftpFile2.deleteFile(delFtpPath); //删除多余的重复文件
		ftpLogin2.disconnect();
	}
	
	/**
	 * 执行作业数据库文件的导入 - 作业的关联组件不执行导入操作
	 * @param filePath 文件存放路径
	 * @throws Exception 
	 * @throws SQLException 
	 */
	public void importDBData(String filePath) throws SQLException, Exception{
		String xml = readFile(filePath);
		CheckJobInfoVo CheckJobInfoVo = null ;
		List<CheckJobTemplateVo> checkJobTemplateVos = null ;
		List<CheckJobServerVo> checkJobServerVos = null ;
		List<CheckJobTimerVo> checkJobTimerVos = null ;
		//解析导入xml文件
		if(!xml.equals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")){
			Document doc4 = JDOMParserUtil.xmlParse(xml);
			Element root4 = doc4.getRootElement();
			
			//作业基本信息
			CheckJobInfoVo = new CheckJobInfoVo();
			if(!root4.getChildText("appsys_code").equals("null") && !root4.getChildText("appsys_code").equals("")){
				CheckJobInfoVo.setAppsys_code(root4.getChildText("appsys_code"));
			}else{
				CheckJobInfoVo.setAppsys_code(null);
			}
			if(!root4.getChildText("check_type").equals("null") && !root4.getChildText("check_type").equals("")){
				CheckJobInfoVo.setCheck_type(root4.getChildText("check_type"));
			}else{
				CheckJobInfoVo.setCheck_type(null);
			}
			if(!root4.getChildText("authorize_lever_type").equals("null") && !root4.getChildText("authorize_lever_type").equals("")){
				CheckJobInfoVo.setAuthorize_lever_type(root4.getChildText("authorize_lever_type"));
			}else{
				CheckJobInfoVo.setAuthorize_lever_type(null);
			}
			if(!root4.getChildText("field_type").equals("null") && !root4.getChildText("field_type").equals("")){
				CheckJobInfoVo.setField_type(root4.getChildText("field_type"));
			}else{
				CheckJobInfoVo.setField_type(null);
			}
			if(!root4.getChildText("job_name").equals("null") && !root4.getChildText("job_name").equals("")){
				CheckJobInfoVo.setJob_name(root4.getChildText("job_name"));
			}else{
				CheckJobInfoVo.setJob_name(null);
			}
			if(!root4.getChildText("job_path").equals("null") && !root4.getChildText("job_path").equals("")){
				CheckJobInfoVo.setJob_path(root4.getChildText("job_path"));
			}else{
				CheckJobInfoVo.setJob_path(null);
			}
			if(!root4.getChildText("job_type").equals("null") && !root4.getChildText("job_type").equals("")){
				CheckJobInfoVo.setJob_type(root4.getChildText("job_type"));
			}else{
				CheckJobInfoVo.setJob_type(null);
			}
			if(!root4.getChildText("job_desc").equals("null") && !root4.getChildText("job_desc").equals("")){
				CheckJobInfoVo.setJob_desc(root4.getChildText("job_desc"));
			}else{
				CheckJobInfoVo.setJob_desc(null);
			}
			if(!root4.getChildText("tool_status").equals("null") && !root4.getChildText("tool_status").equals("")){
				CheckJobInfoVo.setTool_status(root4.getChildText("tool_status"));
			}else{
				CheckJobInfoVo.setTool_status(null);
			}
			if(!root4.getChildText("frontline_flag").equals("null") && !root4.getChildText("frontline_flag").equals("")){
				CheckJobInfoVo.setFrontline_flag(root4.getChildText("frontline_flag"));
			}else{
				CheckJobInfoVo.setFrontline_flag(null);
			}
			if(!root4.getChildText("authorize_flag").equals("null") && !root4.getChildText("authorize_flag").equals("")){
				CheckJobInfoVo.setAuthorize_flag(root4.getChildText("authorize_flag"));
			}else{
				CheckJobInfoVo.setAuthorize_flag(null);
			}
			if(!root4.getChildText("delete_flag").equals("null") && !root4.getChildText("delete_flag").equals("")){
				CheckJobInfoVo.setDelete_flag(root4.getChildText("delete_flag"));
			}else{
				CheckJobInfoVo.setDelete_flag(null);
			}
			if(!root4.getChildText("tool_creator").equals("null") && !root4.getChildText("tool_creator").equals("")){
				CheckJobInfoVo.setTool_creator(root4.getChildText("tool_creator"));
			}else{
				CheckJobInfoVo.setTool_creator(null);
			}
			if(CheckJobInfoVo!=null){
				//根据作业名称、作业路径获取作业信息
				Map<String, Object> map = jobDesignService.getJobCodeByNameAndPath(CheckJobInfoVo.getJob_name(),CheckJobInfoVo.getJob_path());
				if(map!=null && !map.isEmpty() && map.size()>0){
					int jobCode = Integer.valueOf(map.get("job_code").toString());
					//如果存在同名作业，删之
					jobDesignService.deleteJobById(jobCode,CheckJobInfoVo.getJob_name(),new SimpleDateFormat("yyyyMMddhhmmss").format(new Date())); 
				}
				//保存作业基本信息
				jobDesignService.saveJobInfo(CheckJobInfoVo);
				//作业关联模板信息
				if(root4.getChild("CheckJobTemplateVos")!=null){
					List<Element> jobTemplates = root4.getChild("CheckJobTemplateVos").getChildren("CheckJobTemplateVo");
					if(jobTemplates!=null && jobTemplates.size()>0){
						checkJobTemplateVos = new ArrayList<CheckJobTemplateVo>();
						for (Element template : jobTemplates) {
							CheckJobTemplateVo jobTemplate = new CheckJobTemplateVo();
							jobTemplate.setJob_code(CheckJobInfoVo.getJob_code());
							if(!template.getChildText("appsys_code").equals("null") && !template.getChildText("appsys_code").equals("")){
								jobTemplate.setAppsys_code(template.getChildText("appsys_code"));
							}else{
								jobTemplate.setAppsys_code(null);
							}
							if(!template.getChildText("template_group").equals("null") && !template.getChildText("template_group").equals("")){
								jobTemplate.setTemplate_group(template.getChildText("template_group"));
							}else{
								jobTemplate.setTemplate_group(null);
							}
							if(!template.getChildText("template_name").equals("null") && !template.getChildText("template_name").equals("")){
								jobTemplate.setTemplate_name(template.getChildText("template_name"));
							}else{
								jobTemplate.setTemplate_name(null);
							}
							checkJobTemplateVos.add(jobTemplate);
						}
					}
				}
				//作业关联组件信息
				if(root4.getChild("CheckJobServerVos")!=null){
					List<Element> jobServers = root4.getChild("CheckJobServerVos").getChildren("CheckJobServerVo");
					if(jobServers!=null && jobServers.size()>0){
						checkJobServerVos = new ArrayList<CheckJobServerVo>();
						for (Element server : jobServers) {
							CheckJobServerVo jobServer = new CheckJobServerVo();
							jobServer.setJob_code(CheckJobInfoVo.getJob_code());
							if(!server.getChildText("appsys_code").equals("null") && !server.getChildText("appsys_code").equals("")){
								jobServer.setAppsys_code(server.getChildText("appsys_code"));
							}else{
								jobServer.setAppsys_code(null);
							}
							if(!server.getChildText("server_group").equals("null") && !server.getChildText("server_group").equals("")){
								jobServer.setServer_path(server.getChildText("server_group"));
							}else{
								jobServer.setServer_path(null);
							}
							if(!server.getChildText("server_ip").equals("null") && !server.getChildText("server_ip").equals("")){
								jobServer.setServer_name(server.getChildText("server_ip"));
							}else{
								jobServer.setServer_name(null);
							}
							checkJobServerVos.add(jobServer);
						}
					}
				}
				//作业关联时间表信息				if(root4.getChild("CheckJobTimerVos")!=null){
					List<Element> jobTimers = root4.getChild("CheckJobTimerVos").getChildren("CheckJobTimerVo");
					if(jobTimers!=null && jobTimers.size()>0){
						checkJobTimerVos = new ArrayList<CheckJobTimerVo>();
						for (Element timer : jobTimers) {
							CheckJobTimerVo jobTimer = new CheckJobTimerVo();
							if(!timer.getChildText("appsys_code").equals("null") && !timer.getChildText("appsys_code").equals("")){
								jobTimer.setAppsys_code(timer.getChildText("appsys_code"));
							}else{
								jobTimer.setAppsys_code(null);
							}
							jobTimer.setJob_code(CheckJobInfoVo.getJob_code());
							if(!timer.getChildText("exec_freq_type").equals("null") && !timer.getChildText("exec_freq_type").equals("")){
								jobTimer.setExec_freq_type(timer.getChildText("exec_freq_type"));
							}else{
								jobTimer.setExec_freq_type(null);
							}
							if(!timer.getChildText("exec_start_date").equals("null") && !timer.getChildText("exec_start_date").equals("")){
								jobTimer.setExec_start_date(timer.getChildText("exec_start_date"));
							}else{
								jobTimer.setExec_start_date(null);
							}
							if(!timer.getChildText("exec_start_time").equals("null") && !timer.getChildText("exec_start_time").equals("")){
								jobTimer.setExec_start_time(timer.getChildText("exec_start_time"));
							}else{
								jobTimer.setExec_start_time(null);
							}
							if(!timer.getChildText("week1_flag").equals("null") && !timer.getChildText("week1_flag").equals("")){
								jobTimer.setWeek1_flag(timer.getChildText("week1_flag"));
							}else{
								jobTimer.setWeek1_flag(null);
							}
							if(!timer.getChildText("week2_flag").equals("null") && !timer.getChildText("week2_flag").equals("")){
								jobTimer.setWeek2_flag(timer.getChildText("week2_flag"));
							}else{
								jobTimer.setWeek2_flag(null);
							}
							if(!timer.getChildText("week3_flag").equals("null") && !timer.getChildText("week3_flag").equals("")){
								jobTimer.setWeek3_flag(timer.getChildText("week3_flag"));
							}else{
								jobTimer.setWeek3_flag(null);
							}
							if(!timer.getChildText("week4_flag").equals("null") && !timer.getChildText("week4_flag").equals("")){
								jobTimer.setWeek4_flag(timer.getChildText("week4_flag"));
							}else{
								jobTimer.setWeek4_flag(null);
							}
							if(!timer.getChildText("week5_flag").equals("null") && !timer.getChildText("week5_flag").equals("")){
								jobTimer.setWeek5_flag(timer.getChildText("week5_flag"));
							}else{
								jobTimer.setWeek5_flag(null);
							}
							if(!timer.getChildText("week6_flag").equals("null") && !timer.getChildText("week6_flag").equals("")){
								jobTimer.setWeek6_flag(timer.getChildText("week6_flag"));
							}else{
								jobTimer.setWeek6_flag(null);
							}
							if(!timer.getChildText("week7_flag").equals("null") && !timer.getChildText("week7_flag").equals("")){
								jobTimer.setWeek7_flag(timer.getChildText("week7_flag"));
							}else{
								jobTimer.setWeek7_flag(null);
							}
							if(!timer.getChildText("interval_weeks").equals("") && !timer.getChildText("interval_weeks").equals("null")){
								jobTimer.setInterval_weeks(Integer.valueOf(timer.getChildText("interval_weeks")));
							}else{
								jobTimer.setInterval_weeks(null);
							}
							if(!timer.getChildText("month_day").equals("") && !timer.getChildText("month_day").equals("null")){
								jobTimer.setMonth_day(Integer.valueOf(timer.getChildText("month_day")));
							}else{
								jobTimer.setMonth_day(null);
							}
							if(!timer.getChildText("interval_days").equals("") && !timer.getChildText("interval_days").equals("null")){
								jobTimer.setInterval_days(Integer.valueOf(timer.getChildText("interval_days")));				
							}else{
								jobTimer.setInterval_days(null);
							}
							if(!timer.getChildText("interval_hours").equals("") && !timer.getChildText("interval_hours").equals("null")){
								jobTimer.setInterval_hours(Integer.valueOf(timer.getChildText("interval_hours")));
							}else{
								jobTimer.setInterval_hours(null);
							}
							if(!timer.getChildText("interval_minutes").equals("") && !timer.getChildText("interval_minutes").equals("null")){
								jobTimer.setInterval_minutes(Integer.valueOf(timer.getChildText("interval_minutes")));
							}else{
								jobTimer.setInterval_minutes(null);
							}
							if(!timer.getChildText("exec_priority").equals("") && !timer.getChildText("exec_priority").equals("null")){
								jobTimer.setExec_priority(timer.getChildText("exec_priority"));
							}else{
								jobTimer.setExec_priority(null);
							}
							if(!timer.getChildText("exec_notice_mail_list").equals("") && !timer.getChildText("exec_notice_mail_list").equals("null")){
								jobTimer.setExec_notice_mail_list(timer.getChildText("exec_notice_mail_list"));
							}else{
								jobTimer.setExec_notice_mail_list(null);
							}
							if(!timer.getChildText("mail_success_flag").equals("") && !timer.getChildText("mail_success_flag").equals("null")){
								jobTimer.setMail_success_flag(timer.getChildText("mail_success_flag"));
							}else{
								jobTimer.setMail_success_flag(null);
							}
							if(!timer.getChildText("mail_failure_flag").equals("") && !timer.getChildText("mail_failure_flag").equals("null")){
								jobTimer.setMail_failure_flag(timer.getChildText("mail_failure_flag"));
							}else{
								jobTimer.setMail_failure_flag(null);
							}
							if(!timer.getChildText("mail_cancel_flag").equals("") && !timer.getChildText("mail_cancel_flag").equals("null")){
								jobTimer.setMail_cancel_flag(timer.getChildText("mail_cancel_flag"));
							}else{
								jobTimer.setMail_cancel_flag(null);
							}
							checkJobTimerVos.add(jobTimer);
						}
					}
				}
				if(checkJobTemplateVos!=null){
					jobDesignService.saveJobTemplates(checkJobTemplateVos);
				}
				if(checkJobServerVos!=null){
					jobDesignService.saveJobServers(checkJobServerVos);
					//作业关联智能组
					addTargetGroupsForJob(CheckJobInfoVo,checkJobServerVos);
				}
				if(checkJobTimerVos!=null){
					for(CheckJobTimerVo checkJobTimerVo : checkJobTimerVos){
						jobDesignService.saveJobTimer(checkJobTimerVo);
					}
					//作业设置时间表
					handleJobTimers(CheckJobInfoVo,checkJobTimerVos);
				}
			}
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

	/**
	 * FTP获取文件
	 * @param  String localPath,String appsys_code
	 */
	@Transactional
	public void exportFtp(String path1, String path2) {
		String host=messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doGet(path1, path2, true,new StringBuffer());
		ftpLogin.disconnect();

	}
	
	/**
	 * 解压zip文件包	 * @param String
	 *            path,String appsys_code
	 * @throws IOException
	 */
	public void unZip(String path, String appsys_code) throws IOException {
		String fName = null;
		File fpath = new File(path);
		File[] flist = printAllFile(fpath);
		for (File f : flist) {
			if (f.isFile()) {
				fName = f.getName();
				int indexOf = fName.indexOf(appsys_code);
				if (indexOf != -1) {
					int count = -1;
					int index = -1;
					String savepath = "";

					File file = null;
					InputStream is = null;
					FileOutputStream fos = null;
					BufferedOutputStream bos = null;

					savepath = path;
					String path2 = path .concat(fName) ;
					ZipFile zipFile = new ZipFile(path2, "GBK");
					Enumeration<?> entries = zipFile.getEntries();

					while (entries.hasMoreElements()) {
						byte buf[] = new byte[buffer];
						ZipEntry entry = (ZipEntry) entries.nextElement();
						String filename = entry.getName();
						index = filename.lastIndexOf(messages
								.getMessage("path.linux"));
						if (index > -1)
							filename = filename.substring(index + 1);
						filename = savepath.concat(File.separator) .concat(fName.substring(0, fName.indexOf(".zip")))
								.concat(File.separator).concat(filename) ;
						// filename = "E:\\workspace\\brpmFile\\" + filename;
						// flag = isPics(filename);
						/*
						 * if(!flag) continue;
						 */
						File sourceFile = new File(savepath.concat(File.separator).concat(fName.substring(0, fName.indexOf(".zip"))) 
								.concat(File.separator) );
						if (!sourceFile.exists()) {
							sourceFile.mkdirs();
						}
						file = new File(filename);
						file.createNewFile();

						is = zipFile.getInputStream(entry);
						fos = new FileOutputStream(file);
						bos = new BufferedOutputStream(fos, buffer);
						while ((count = is.read(buf)) > -1) {
							bos.write(buf, 0, count);
						}
						fos.close();
						is.close();
					}
					zipFile.close();
					delFile(savepath.concat(File.separator).concat(fName.substring(0, fName.indexOf(".zip"))));
				}
			}
		}
	}
	
	/**
	 * 读取文件
	 * @param path
	 *            String 文件夹路径	 * @return File[]
	 */
	public File[] printAllFile(File fpath) {
		File[] flist = fpath.listFiles();
		for (File f : flist) {
			if (f.isFile()) {
			} else if (f.isDirectory()) {
				printAllFile(f);
			}
		}
		return flist;
	}
	
	/**
	 * 模板授权
	 * @throws NoSuchMessageException 
	 * @throws Exception
	 */
	private void applyTemplateAclPolicy(String importFileGroup,String importFileName) throws NoSuchMessageException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		String plcy1="PLCY_COMMON_SYSADMIN";
		String plcy2="PLCY_ALL_ROOT";
		//获取DBKey
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeResponse = client.executeCommandByParamList("Template","getDBKeyByGroupAndName", new String[] {importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
		client.ResponseCheck4ExecuteCommand(executeResponse);
		String templateDBkey = (String) executeResponse.get_return().getReturnValue();
		//模板授权
		ExecuteCommandByParamListResponse response = client.executeCommandByParamList("Template","applyAclPolicy",new String[] {templateDBkey,plcy1});
		String DbKey = (String) response.get_return().getReturnValue();
		client.executeCommandByParamList("Template","applyAclPolicy",new String[] {DbKey,plcy2});
		//目录授权
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK",plcy1});
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK",plcy2});
		
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/DB",plcy1});
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/DB",plcy2});
		
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/OS",plcy1});
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/OS",plcy2});
		
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/MW",plcy1});
		client.executeCommandByParamList("TemplateGroup","applyAclPolicy",new String[] {"/COMMON_CHECK/MW",plcy2});
	}
	
	/**
	 * 作业授权
	 * @throws NoSuchMessageException 
	 * @throws Exception
	 */
	private void applyJobAclPolicy(String importFileGroup,String importFileName) throws NoSuchMessageException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		
		String[] groups = importFileGroup.split("/");
		String mainGroup = "";
		String appsys = "";
		String fieldType = "";
		if(groups.length==4){ //非通用作业 eg:/CHECK/NEXCH/OS
			mainGroup = groups[1];
			appsys = groups[2];
			fieldType = groups[3];
		}else{ //通用作业 eg:/COMMON_CHECK/OS
			mainGroup = groups[1];
			appsys = "COMMON";
			fieldType = groups[2];
		}
		String plcyAll="PLCY_ALL_ROOT";
		String plcyApp="PLCY_"+appsys+"_APPADMIN";
		String plcySys="PLCY_"+appsys+"_SYSADMIN";
		
		//获取DBKey
		String jobDBKey = "" ;
		ExecuteCommandByParamListResponse cliResponse ;
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		cliResponse = client.executeCommandByParamList("ComplianceJob", "getDBKeyByGroupAndName", new String[]{importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
		String complianceJobDBkey=(String) cliResponse.get_return().getReturnValue();
		
		cliResponse = client.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
		String NSHScriptJob=(String) cliResponse.get_return().getReturnValue();
		
		if(!complianceJobDBkey.equals("void")){
			jobDBKey = complianceJobDBkey;
		}else if(!NSHScriptJob.equals("void")){
			jobDBKey = NSHScriptJob;
		}
		if(fieldType.equals("")){ //通用巡检作业
			//作业授权
			cliResponse = client.executeCommandByParamList("Job", "applyAclPolicy",new String[]{jobDBKey,plcySys});
			//目录授权
			client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup,plcyAll});
			client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys,plcySys});
		}else{
			if(fieldType.equals("APP")){
				//作业授权
				cliResponse = client.executeCommandByParamList("Job", "applyAclPolicy",new String[]{jobDBKey,plcyApp});
				//目录授权
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup,plcyAll});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys,plcySys});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys,plcyApp});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys+"/"+fieldType,plcyApp});
			}else{
				//作业授权
				cliResponse = client.executeCommandByParamList("Job", "applyAclPolicy",new String[]{jobDBKey,plcySys});
				//目录授权
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup,plcyAll});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys,plcySys});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys,plcyApp});
				client.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+mainGroup+"/"+appsys+"/"+fieldType,plcySys});
			}
		}
	}
	
	/**
	 * 删除BSA系统巡检作业
	 * @param job_path 作业路径
	 * @param job_name 作业名称
	 * @throws Exception 
	 */
	public void deleteJobByGroupAndName(String job_path,String job_name) throws Exception {
		//临时作业路径
		String tempJobPath = "/SYSMANAGE/CHECKMANAGE";
		//临时作业名称
		String tempJobName = "tempComplianceJob";
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String dateStr = matter.format(date);
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
        //删除BSA系统巡检作业
		tempJobName=tempJobName.concat("_").concat(dateStr);
		
		CLITunnelServiceClient cliClientCreatExportJob2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseCreatExportJob2= cliClientCreatExportJob2.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{tempJobPath,tempJobName,"","/SYSMANAGE/ComplianceJob","ComplianceJobDelete.nsh","3"});
		cliClientCreatExportJob2.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob2);
		String DBkey=(String) cliResponseCreatExportJob2.get_return().getReturnValue();

		CLITunnelServiceClient cliClientExportLinkServer3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExportLinkServer3 = cliClientExportLinkServer3.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkey,messages.getMessage("bsa.ipAddress")});
		cliClientExportLinkServer3.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer3);
		
		CLITunnelServiceClient cliClientClean4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseClean4 = cliClientClean4.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{tempJobPath,tempJobName});
		cliClientClean4.ResponseCheck4ExecuteCommand(cliResponseClean4);
		
		CLITunnelServiceClient cliClientAdd6 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd6 = cliClientAdd6.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"0",job_path});
		cliClientAdd6.ResponseCheck4ExecuteCommand(cliResponseAdd6);
		
		CLITunnelServiceClient cliClientAdd8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd8 = cliClientAdd8.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{tempJobPath,tempJobName,"1",job_name});
		cliClientAdd8.ResponseCheck4ExecuteCommand(cliResponseAdd8);
		
		CLITunnelServiceClient cliClientExport7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExport7 = cliClientExport7.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey});
		cliClientExport7.ResponseCheck4ExecuteCommand(cliResponseExport7);
		//删除临时脚本作业
		CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{tempJobPath,tempJobName});
	}
	
	/**
	 * 导入bsa
	 * @param appsys_code
	 * @throws Exception
	 * @throws IOException Throwable
	 */
	public void importBsa(String importFileGroupAndName,String userId,String localFilename,String bsaFileImpPath,String importFileType,String importFileName,String importFileGroup) 
			throws IOException,SocketTimeoutException, Exception, Throwable {
		String fileType = "";
		if(importFileType.equals("template")){
			fileType = "Template";
		}else if(importFileType.equals("job")){
			fileType = "ComplianceJob";
		}
		
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
		
		// 用户登录
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userName"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
				messages.getMessage("bsa.truststoreFilePassword"));
		loginResponse = loginClient.loginUsingUserCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse response = null;
		
		//获取BDkey，判断该作业/模板是否已存在
		response = cliTunnelServiceClient.executeCommandByParamList(fileType,"getDBKeyByGroupAndName",new String[] {importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
		String fileDBkey = (String) response.get_return().getReturnValue();
		if(importFileType.equals("job")){ //导入作业
			if(!fileDBkey.equals("void")){ //同名作业已存在
				deleteJobByGroupAndName(importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip")));
			}
			doImportBsa(importFileGroupAndName,userId,localFilename,bsaFileImpPath,importFileType);
		}else if(importFileType.equals("template")){ //导入模板
			if(!fileDBkey.equals("void")){ //同名模板存在
				localFilename = localFilename.substring(0, localFilename.indexOf(".tar")).concat(templateConflict).concat(".tar");
				bsaFileImpPath = bsaFileImpPath.substring(0, bsaFileImpPath.indexOf(".tar")).concat(templateConflict).concat(".tar");
				doImportBsa(importFileGroupAndName.concat(templateConflict),userId,localFilename,bsaFileImpPath,importFileType);
				//获取原始模板的BDkey
				response = cliTunnelServiceClient.executeCommandByParamList(fileType,"getDBKeyByGroupAndName",
						new String[] {importFileGroup,importFileName.substring(0, importFileName.indexOf(".zip"))});
				fileDBkey = (String) response.get_return().getReturnValue();
				//获取临时模板的BDkey
				String fieldType  = importFileGroup.substring(importFileGroup.lastIndexOf("/")+1);
				response = cliTunnelServiceClient.executeCommandByParamList("Template","getDBKeyByGroupAndName",
						new String[] {tempTemplatePath.concat(fieldType),importFileName.substring(0, importFileName.indexOf(".zip"))});
				String fileDBkeyNew = (String) response.get_return().getReturnValue();
				//临时模板替换原有模板
				response = cliTunnelServiceClient.executeCommandByParamList("Template","updateByDBKey",
						new String[] {fileDBkey,fileDBkeyNew});
				//删除临时模板
				response = cliTunnelServiceClient.executeCommandByParamList("Template","deleteTemplate",
						new String[] {importFileName.substring(0, importFileName.indexOf(".zip")),tempTemplatePath.concat(fieldType)});
			}else{
				doImportBsa(importFileGroupAndName,userId,localFilename,bsaFileImpPath,importFileType);
			}
		}
		
		
		
	}
	
	
	/**
	 * 导入作业关联智能组
	 * @param checkJobInfo
	 * @param checkJobServers
	 * @throws Exception 
	 * @throws SQLException 
	 * @throws AxisFault 
	 */
	public void addTargetGroupsForJob(CheckJobInfoVo checkJobInfo,List<CheckJobServerVo> checkJobServerVos) throws AxisFault, SQLException, Exception{
		String groups = "" ;
		for(CheckJobServerVo checkJobServer:checkJobServerVos){
			groups = groups + "," + checkJobServer.getServer_path()+"/"+checkJobServer.getServer_name();
		}
		if(!groups.equals("")){
			groups = groups.substring(1);
		}
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		//BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//作业关联智能组
		CLITunnelServiceClient client = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		String jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		ExecuteCommandByParamListResponse resp = client.executeCommandByParamList("Job","clearTargetGroups",new String[] {jobDBKey});
		jobDBKey = (String) resp.get_return().getReturnValue();
		ExecuteCommandByParamListResponse response1 = client.executeCommandByParamList("Job","clearTargetServers",new String[] {jobDBKey});
		jobDBKey = (String) response1.get_return().getReturnValue();
		client.executeCommandByParamList("Job","addTargetGroups",new String[] {jobDBKey,groups});
	}
	
	/**
	 * 处理导入常规巡检作业的时间表
	 * @throws Exception 
	 * @throws SQLException 
	 * @throws AxisFault 
	 */
	@SuppressWarnings("static-access")
	public void handleJobTimers(CheckJobInfoVo checkJobInfo,List<CheckJobTimerVo> checkJobTimerVos) throws AxisFault, SQLException, Exception{
		String curDateTime = new DateFunction().getSystemTime();
		String priority = "NORMAL" ;
		String jobDBKey = "";
		//清空所有时间表
		jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
		jobDesignService.removeAllSchedules(jobDBKey); 
		//1:一次
		List<CheckJobTimerVo> onceList = new ArrayList<CheckJobTimerVo>(); 
		//2:每天
		List<CheckJobTimerVo> dailyList = new ArrayList<CheckJobTimerVo>(); 
		//3:每周
		List<CheckJobTimerVo> weeklyList = new ArrayList<CheckJobTimerVo>(); 
		//4:每月
		List<CheckJobTimerVo> monthlyList = new ArrayList<CheckJobTimerVo>(); 
		//5:时间间隔
		List<CheckJobTimerVo> intervalList = new ArrayList<CheckJobTimerVo>(); 
		for(CheckJobTimerVo checkJobTimer : checkJobTimerVos){
			if(checkJobTimer.getExec_freq_type()!=null && checkJobTimer.getExec_freq_type().equals("1")){
				onceList.add(checkJobTimer);
			}else if(checkJobTimer.getExec_freq_type()!=null && checkJobTimer.getExec_freq_type().equals("2")){
				dailyList.add(checkJobTimer);
			}else if(checkJobTimer.getExec_freq_type()!=null && checkJobTimer.getExec_freq_type().equals("3")){
				weeklyList.add(checkJobTimer);
			}else if(checkJobTimer.getExec_freq_type()!=null && checkJobTimer.getExec_freq_type().equals("4")){
				monthlyList.add(checkJobTimer);
			}else if(checkJobTimer.getExec_freq_type()!=null && checkJobTimer.getExec_freq_type().equals("5")){
				intervalList.add(checkJobTimer);
			}
		}
		if(onceList!=null && onceList.size()>0){
			for(CheckJobTimerVo onceTimer : onceList){
				String addDateTime = onceTimer.getExec_start_date().replaceAll("-", "").concat(onceTimer.getExec_start_time().replaceAll(":", ""));
				//作业执行时间早于当前时间
				if(Long.valueOf(addDateTime)>Long.valueOf(curDateTime)){
					String dateString = onceTimer.getExec_start_date()+" "+onceTimer.getExec_start_time();
					if(onceTimer.getExec_priority()!=null){
						priority = onceTimer.getExec_priority();
					}
					jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
					jobDesignService.addOneTimeScheduleWithPriority(jobDBKey,dateString,priority);
				}
			}
		}
		if(dailyList!=null && dailyList.size()>0){
			for(CheckJobTimerVo dailyTimer : dailyList){
				String addDateTime = dailyTimer.getExec_start_date().replaceAll("-", "").concat(dailyTimer.getExec_start_time().replaceAll(":", ""));
				//作业执行时间早于当前时间
				if(Long.valueOf(addDateTime)>Long.valueOf(curDateTime)){
					String dateString = dailyTimer.getExec_start_date()+" "+dailyTimer.getExec_start_time();
					if(dailyTimer.getExec_priority()!=null){
						priority = dailyTimer.getExec_priority();
					}
					jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
					jobDesignService.addDailyScheduleWithPriority(jobDBKey,dateString,priority);
				}
			}
		}
		if(weeklyList!=null && weeklyList.size()>0){
			for(CheckJobTimerVo weeklyTimer : weeklyList){
				String addDateTime = weeklyTimer.getExec_start_date().replaceAll("-", "").concat(weeklyTimer.getExec_start_time().replaceAll(":", ""));
				//作业执行时间早于当前时间
				if(Long.valueOf(addDateTime)>Long.valueOf(curDateTime)){
					String dateString = weeklyTimer.getExec_start_date()+" "+weeklyTimer.getExec_start_time();
					int daysOfWeek = 0;
					String frequency = String.valueOf(weeklyTimer.getInterval_weeks());
					if(weeklyTimer.getExec_priority()!=null){
						priority = weeklyTimer.getExec_priority();
					}
					if(weeklyTimer.getWeek7_flag().equals("1")){
						daysOfWeek = daysOfWeek + 1;
					}
					if(weeklyTimer.getWeek1_flag().equals("1")){
						daysOfWeek = daysOfWeek + 2;
					}
					if(weeklyTimer.getWeek2_flag().equals("1")){
						daysOfWeek = daysOfWeek + 4;
					}
					if(weeklyTimer.getWeek3_flag().equals("1")){
						daysOfWeek = daysOfWeek + 8;
					}
					if(weeklyTimer.getWeek4_flag().equals("1")){
						daysOfWeek = daysOfWeek + 16;
					}
					if(weeklyTimer.getWeek5_flag().equals("1")){
						daysOfWeek = daysOfWeek + 32;
					}
					if(weeklyTimer.getWeek6_flag().equals("1")){
						daysOfWeek = daysOfWeek + 64;
					}
					jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
					jobDesignService.addWeeklyScheduleWithPriority(jobDBKey,dateString,frequency,String.valueOf(daysOfWeek),priority);
				}
			}
				
		}
		if(monthlyList!=null && monthlyList.size()>0){
			for(CheckJobTimerVo monthlyTimer : monthlyList){
				String addDateTime = monthlyTimer.getExec_start_date().replaceAll("-", "").concat(monthlyTimer.getExec_start_time().replaceAll(":", ""));
				//作业执行时间早于当前时间
				if(Long.valueOf(addDateTime)>Long.valueOf(curDateTime)){
					String dateString = monthlyTimer.getExec_start_date()+" "+monthlyTimer.getExec_start_time();
					String dayOfMonth = String.valueOf(monthlyTimer.getMonth_day());
					if(monthlyTimer.getExec_priority()!=null){
						priority = monthlyTimer.getExec_priority();
					}
					jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
					jobDesignService.addMonthlyScheduleWithPriority(jobDBKey,dateString,dayOfMonth,priority);
				}
			}
		}
		if(intervalList!=null && intervalList.size()>0){
			for(CheckJobTimerVo intervalTimer : intervalList){
				String addDateTime = intervalTimer.getExec_start_date().replaceAll("-", "").concat(intervalTimer.getExec_start_time().replaceAll(":", ""));
				//作业执行时间早于当前时间
				if(Long.valueOf(addDateTime)>Long.valueOf(curDateTime)){
					String dateString = intervalTimer.getExec_start_date()+" "+intervalTimer.getExec_start_time();
					String days = String.valueOf(intervalTimer.getInterval_days());
					String hours = String.valueOf(intervalTimer.getInterval_hours());
					String mins = String.valueOf(intervalTimer.getInterval_minutes());
					jobDBKey = (String)jobDesignService.getJobDBKeyByGroupAndName(checkJobInfo.getJob_path(),checkJobInfo.getJob_name());
					jobDesignService.addIntervalSchedule(jobDBKey,dateString,days,hours,mins);
				}
			}
		}
	}
	
	/**
	 * 直接导入，不管是否存在冲突
	 * @param importFileGroupAndName 文件名称，带.zip后缀
	 * @param importFileType
	 * @param userId
	 * @param importFileGroup
	 * @param importFileName
	 * @param componentFtp
	 * @throws Throwable
	 */
	public void importNoConflict(String importFileGroupAndName,String importFileType,String userId,
			String importFileGroup,String importFileName,ComponentFtp componentFtp) throws Throwable{
		String remoteFilename = null;
		String localFilename = null;
		String bsaFileImpPath = null;
		String jobDBDataPath = null;
		File zipPackagebsa = null;
		String zipPackagebsaPath = null;
		String importFileGroupAndName2 = null;
		String yyyyMMddHHmmss = null;
		String from = null;
		String to = null;
		File bsaFileZipPackageImpPath = null;
		if(ComUtil.isWindows){
			bsaFileZipPackageImpPath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipImpPath")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId));
		}else{
			bsaFileZipPackageImpPath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipImpPathForLinux")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId));
		}
		
		String delFileName = ""; //需要删除的文件名称
		if(importFileGroupAndName.indexOf(templateConflict)<0){ //不是解决冲突文件
			delFileName = importFileGroupAndName.substring(0, importFileGroupAndName.indexOf(".zip")).concat(templateConflict).concat(".zip");
		}else{
			delFileName = importFileGroupAndName.substring(0, importFileGroupAndName.indexOf(templateConflict)).concat(".zip");
		}
		delAppZipFile(bsaFileZipPackageImpPath.getAbsolutePath(),importFileGroupAndName);
		delAppZipFile(bsaFileZipPackageImpPath.getAbsolutePath(),delFileName);
		delAllFile(bsaFileZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(importFileGroupAndName));
		delAllFile(bsaFileZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(delFileName));
		
		if(!bsaFileZipPackageImpPath.exists()){
			logger.log("Deploy0001", bsaFileZipPackageImpPath.getAbsolutePath());
			logger.log("Deploy0001", bsaFileZipPackageImpPath.exists());
			bsaFileZipPackageImpPath.mkdirs();
		}
		importFileGroupAndName2 = importFileGroupAndName.substring(0, importFileGroupAndName.indexOf(".zip"));
		
		String delLocalFileName = ""; //需要删除的本地文件名称
		if(importFileGroupAndName2.indexOf(templateConflict)<0){ //不是解决冲突文件
			delLocalFileName = importFileGroupAndName2.concat(templateConflict);
		}else{
			delLocalFileName = importFileGroupAndName2.substring(0, importFileGroupAndName2.indexOf(templateConflict));
		}
		
		remoteFilename = messages.getMessage("importServer.path.check").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.checkPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName);
		if(ComUtil.isWindows){
			zipPackagebsaPath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipImpPath")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator);
			localFilename = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipImpPath")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator).concat(importFileGroupAndName2);
		}else{
			zipPackagebsaPath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipImpPathForLinux")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator);
			localFilename = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipImpPathForLinux")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator).concat(importFileGroupAndName2);
		}
		zipPackagebsa = new File(zipPackagebsaPath);
		if (!zipPackagebsa.exists()) {
			zipPackagebsa.mkdirs();
		}
		
		deleteBsaFile(importFileGroupAndName,importFileType);
		deleteBsaFile(delFileName,importFileType);
		
		componentFtp.doGet(remoteFilename, localFilename.concat(".zip"), true, new StringBuffer());
		if(ComUtil.isWindows){
			jobDBDataPath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaFileZipImpPath")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator).concat(importFileGroupAndName2);
		}else{
			jobDBDataPath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaFileZipImpPathForLinux")).concat(File.separator).concat(importFileType).concat(File.separator).concat(userId).concat(File.separator).concat(importFileGroupAndName2);
		}
		//zip包解压
		unZip(zipPackagebsaPath, importFileGroupAndName);
		
		//导入巡检相关参数
		CheckParamImport checkParamImport = new CheckParamImport();
		checkParamImport.doImportParams(jobDBDataPath.concat(File.separator).concat(importFileGroupAndName2).concat("Param").concat(".xml"));
		delFile(jobDBDataPath.concat(File.separator).concat(importFileGroupAndName2).concat("Param").concat(".xml"));
		//delFile(jobDBDataPath.concat(File.separator).concat(delLocalFileName).concat("Param").concat(".xml"));
		
		//导入BSA
		bsaFileImpPath = messages.getMessage("bsa.moveFilePath").concat(messages.getMessage("path.linux")).concat(messages.getMessage("bsa.dplyPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName2).concat(".tar");
		doImportBsa(importFileGroupAndName2,userId,localFilename,bsaFileImpPath,importFileType);
		
		//导入文件授权
		if(importFileType.equals("template")){
			applyTemplateAclPolicy(importFileGroup,importFileName);
		}
		if(importFileType.equals("job")){
			applyJobAclPolicy(importFileGroup,importFileName);
		}
		
		//删除本地相关文件
		delFile(localFilename.concat(File.separator).concat(importFileGroupAndName2).concat(".tar"));
		delFile(localFilename.concat(File.separator).concat(delLocalFileName).concat(".tar"));
		delFile(zipPackagebsaPath.concat(importFileGroupAndName2).concat(".tar"));
		delFile(zipPackagebsaPath.concat(delLocalFileName).concat(".tar"));

		//删除BSA相关文件
		deleteBsaFile(importFileGroupAndName,importFileType);
		deleteBsaFile(delFileName,importFileType);
		
		//导入作业相关数据库信息
		if(importFileType.equals("job")){  //导入文件类型为系统巡检作业
			importDBData(jobDBDataPath.concat(File.separator).concat(importFileGroupAndName2).concat(".xml"));
			delFile(jobDBDataPath.concat(File.separator).concat(importFileGroupAndName2).concat(".xml"));
			//delFile(jobDBDataPath.concat(File.separator).concat(delLocalFileName).concat(".xml"));
		}
		//文件备份
		yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String delFtpPath = messages.getMessage("importServer.path.check").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.checkPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(delFileName);
		from  = messages.getMessage("importServer.path.check").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.checkPath")).concat(messages.getMessage("path.linux")).concat(importFileType).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName);
		to  = messages.getMessage("exportServer.path.check").concat(messages.getMessage("path.linux")).concat(messages.getMessage("exportServer.bakPath")).concat(messages.getMessage("path.linux")).concat(messages.getMessage("exportServer.checkPath")).concat(messages.getMessage("path.linux")).concat(importFileType)
				.concat(messages.getMessage("path.linux")).concat(new SimpleDateFormat("yyyyMMdd").format(new Date())).concat(messages.getMessage("path.linux")).concat(importFileGroupAndName2).concat(yyyyMMddHHmmss).concat(".zip");
		ftpDelToolstar(from,to,importFileType,delFtpPath);
	}
	
}




package com.nantian.dply.service;

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
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.conn.HttpHostConnectException;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * @author liruihao
 * 
 */
@Service
public class MoveBrpmImportService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveBrpmImportService.class);

	public static Map<String, String> fields = new HashMap<String, String>();

	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private SecurityUtils securityUtils;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	/** BRPM调用接口 */
	@Autowired
	private BrpmService method;

	private static final int buffer = 1;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	public MoveBrpmImportService() {
		super();
	}

	/**
	 * 
	 * 查询系统平台
	 * 
	 * @throws SQLException
	 * 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object getCmnAppInfo() {
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		String sql = "SELECT s.appsys_code as appsys_code,s.systemname as appsys_name FROM V_CMN_APP_INFO s order by appsys_code ";
		Query query = getSession().createSQLQuery(sql.toString());
		List<Object[]> lis = query.list();
		for (Object[] str : lis) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("appsys_code2", String.valueOf(str[0]));
			map.put("appsys_name", String.valueOf(str[1]));
			jsonMapList.add(map);
		}
		return jsonMapList;
	}
	

	
	/**
	 * 
	 * ftp到bsa服务器
	 * 
	 * @param String appsys_code,String path1,String path2
	 * 
	 */
	@Transactional
	public void importFtp(String appsys_code, String path1, String path2) {
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = Integer.valueOf(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host, port, user, password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdir(messages.getMessage("bsa.dplyPath"), new StringBuffer());
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doPut(path1, path2, true, new StringBuffer());
		ftpLogin2.disconnect();
	}

	
	
	/**
	 * 
     * 创建导出开始记录.
     * 
     * @param entryId
     * @param appsys_code
     * @param status
     * @param operateSource
     * 
     */
    @Transactional
	public void saveDplyExcuteStatusVo(String entryId, String status, String appsys_code,String operateSource,String env){
		DplyExcuteStatusVo vo = new DplyExcuteStatusVo();
		vo.setEntryId(entryId);
		vo.setAppsysCode(appsys_code);
		vo.setUserId(securityUtils.getUser().getUsername());
		vo.setMoveStatus(status);
		vo.setOperateType("导入");
		vo.setOperateSource(operateSource);
		vo.setEnvironment(env);
		getSession().save(vo);
	}
	
    /**
     * 
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * 
     */
    @Transactional
	public void updateDplyExcuteStatusVo(String entryId,String moveStatus,String errMsg){
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		getSession().createQuery(
			"update DplyExcuteStatusVo t set t.moveStatus = :moveStatus,t.excuteEndTime = :excuteEndTime, t.operateLog = :operateLog where t.entryId=:entryId ")
				.setString("moveStatus", moveStatus)
				.setTimestamp("excuteEndTime", tt)
				.setString("operateLog", errMsg)
				.setString("entryId", entryId)
				.executeUpdate();
	}
    
    /**
     * 
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * 
     */
    @Transactional
	public void updateDplyExcuteStatusRunningVo(String entryId,String moveStatus,String errMsg){
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		getSession().createQuery(
			"update DplyExcuteStatusVo t set t.moveStatus = :moveStatus,t.excuteStartTime = :excuteStartTime, t.operateLog = :operateLog where t.entryId=:entryId ")
				.setString("moveStatus", moveStatus)
				.setTimestamp("excuteStartTime", tt)
				.setString("operateLog", errMsg)
				.setString("entryId", entryId)
				.executeUpdate();
	}
	
    
    /**
     * 
     * brpm用户检查是否同步

     * 
     * @param requestor_name
     * @param uuids
     * 
     * 
     */
    @Transactional
    public String checkBrpmUser(String requestor_name,String[] uuids){
		String usersXml;
		String requestor_id = "";
		try {
			logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_USER + " { \"filters\": { \"keyword\":\"" + requestor_name + "\" }}");
			usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"keyword\":\"" + requestor_name + "\" }}");
			logger.log("BRPM0002", usersXml);
			if(usersXml!=null){
				Document docUsers = JDOMParserUtil.xmlParse(usersXml);
				Element rootUsers = docUsers.getRootElement();
				requestor_id = rootUsers.getChild("user").getChildText("id");
			}
		} catch (Exception e) {
			for(int i=0;i<uuids.length;i++){
				updateDplyExcuteStatusVo(uuids[i], CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
			}
		}
		return requestor_id;
    }
    
    /**
     * 
     * 获取请求信息列表文件，ftp到jeda服务器并解压缩包后删除压缩包。
     * 
     * @param appsys_code
     * @param tranItemS
     * @param brpm
     * @param userId
     * 
     * @throws IOException
     * @throws BrpmInvocationException
     * @throws URISyntaxException
     * 
     * 
     */
	@Transactional
    public String[] getRequestsInfo(String appsys_code, String tranItemS, String brpm, String userId, String env, String envExp) throws IOException, BrpmInvocationException, URISyntaxException,Exception{
		String[] tranItemSid = tranItemS.split(",");
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
		String[] doGetFilesNamelist = componentFtp.doGetFilesNamelist(
				new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(envExp)
					.append(messages.getMessage("path.linux"))
					.append( messages.getMessage("importServer.brpmPath"))
					.toString()
				);
		String[] doGetRequestsNamelist = new String[tranItemSid.length]; 
		for(int i=0;i<tranItemSid.length;i++){
			for(int j=0;j<doGetFilesNamelist.length;j++){
				if(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[0].substring(0, appsys_code.length()+1).equals(appsys_code.concat("_"))&&doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0].equals(tranItemSid[i])){
					doGetRequestsNamelist[i] = doGetFilesNamelist[j];
					ftpGetFileServer(doGetFilesNamelist[j], "brpm", userId,env,envExp);

					File brpmFile2 = null;
					if(ComUtil.isWindows){
						brpmFile2 = new File(
								new StringBuilder().append(System.getProperty("maop.root"))
									.append(messages.getMessage("systemServer.brpmPackageImpPath"))
									.append(File.separator)
									.append(userId)
									.append(File.separator)
									.append(env)
									.append(File.separator)
									.append(doGetFilesNamelist[j])
									.toString()
								);
					}else{
						brpmFile2 = new File(
								new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
									.append(File.separator)
									.append(userId)
									.append(File.separator)
									.append(env)
									.append(File.separator)
									.append(doGetFilesNamelist[j])
									.toString()
								);
					}
					if (!brpmFile2.isDirectory()) {
						if(ComUtil.isWindows){
							unZip(new StringBuilder().append(System.getProperty("maop.root"))
										.append(messages.getMessage("systemServer.brpmPackageImpPath"))
										.append(File.separator)
										.append(userId)
										.append(File.separator)
										.append(env)
										.append(File.separator)
										.toString()
									,doGetFilesNamelist[j]);
							delFile(brpmFile2.getAbsolutePath());
						}else{
							unZip(new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
									.append(File.separator)
									.append(userId)
									.append(File.separator)
									.append(env)
									.append(File.separator)
									.toString()
								,doGetFilesNamelist[j]);
							delFile(brpmFile2.getAbsolutePath());
						}

					}
				}
			}
		}
		return doGetRequestsNamelist;
    }
	/**
     * 
     * 获取请求信息列表文件，ftp到jeda服务器并解压缩包后删除压缩包。

     * 
     * @param appsys_code
     * @param tranItemS
     * @param brpm
     * @param userId
     * 
     * @throws IOException
     * @throws BrpmInvocationException
     * @throws URISyntaxException
     * 
     * 
     */
	@Transactional
    public String[] getRequestsInfo2(String appsys_code, String tranItemS, String brpm, String userId, String envExp) throws IOException, BrpmInvocationException, URISyntaxException{
		String[] tranItemSid = tranItemS.split(",");
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
		String[] doGetFilesNamelist = componentFtp.doGetFilesNamelist(
				new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(envExp)
					.append(messages.getMessage("path.linux"))
					.append( messages.getMessage("importServer.brpmPath"))
					.toString()
				);
		
		ftpLogin.disconnect();
		String[] doGetRequestsNamelist = new String[tranItemSid.length]; 
		for(int i=0;i<tranItemSid.length;i++){
			for(int j=0;j<doGetFilesNamelist.length;j++){
				if(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[0].substring(0, appsys_code.length()+1).equals(appsys_code.concat("_"))&&doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0].equals(tranItemSid[i])){
					doGetRequestsNamelist[i] = doGetFilesNamelist[j];
				}
			}
		}
		return doGetRequestsNamelist;
    }
	
	/**
	 * ALLAPP_DB_CHECK.
     * @throws Exception 
	 * 
	 * 
	 */
	public String allappDbCheck(String[] doGetFilesNamelist, String userId) throws Exception{
		String msg = "";
		//boolean allappDbCheckFlag = false;
		String reqId = null;
		String reqName = null;
		String reqDbCheckFlag = null;
		for (int i=0;i<doGetFilesNamelist.length;i++) {
			//allappDbCheckFlag = false;
			reqId = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1];
			reqName = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0];
			reqDbCheckFlag = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[2];
			if(reqDbCheckFlag.indexOf("DBCheck1")==-1){
				msg += "请求" + reqName + "缺少" + CommonConst.DB_CHECK + "步骤！</br>";
			}
		}
		return msg;
	}
	
	/**
	 * ALLAPP_DB_CHECK.
     * @throws Exception 
	 * 
	 * 
	 */
	/*public String allappDbCheck(String[] doGetFilesNamelist, String userId) throws Exception{
		String reqId = null;
		String reqName = null;
		String stepId = null;
		String stepName = null;
		String msg = "";
		String fName = null;
		String fNameDis = "";
		String description = "";
		boolean allappDbCheckFlag = false;
		
		String filePath = null;
		if(ComUtil.isWindows){
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.brpmPackageImpPath"))
							.append(File.separator) 
							.append(userId)
							.toString();
		}else{
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
							.append(File.separator) 
							.append(userId)
							.toString();
		}
		//String uuid = null;
		File[] fileList = new File(filePath).listFiles();
		
		for (int i=0;i<doGetFilesNamelist.length;i++) {
			allappDbCheckFlag = false;
			reqId = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1];
			reqName = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0];
			fNameDis += reqName + ",";

			
		}
		
		String requestName = "";
		int i=0;
		for (File file : fileList) {
			if(file.isDirectory()){

				File[] flist = printAllFile(file.getAbsoluteFile());
				//for (int i = 0; i < fRequstNameDiss.length; i++) {
				allappDbCheckFlag = false;
				for (File f : flist) {
					if (f.isFile()) {
						fName = f.getName();
						int iFlag = 0;
						for (int j = 0; j < fName.length(); j++) {
							if (String.valueOf(fName.charAt(j)).equals(CommonConst.REPLACE_CHAR)) {
								iFlag++;
							}
						}
						if (iFlag == 3 ) {
							String fName2 = fName.substring(0,fName.lastIndexOf(".xml"));
							fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
							fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
							requestName = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
							
							if(fNameDis.indexOf(requestName)!=-1){
								String stepXmlFile = importFile(
										new StringBuilder().append(file.getAbsolutePath())
											.append(File.separator)
											.append(fName)
											.toString()
										);
								Document descriptionDoc = JDOMParserUtil.xmlParse(stepXmlFile);
								Element descriptionRoot = descriptionDoc.getRootElement();
								description = descriptionRoot.getChildText("description");
								if(description.indexOf(CommonConst.DB_CHECK)!=-1){
									allappDbCheckFlag = true;break;
								}
							}
						}
					}
				}
				
				if(allappDbCheckFlag == false){
					msg += "请求" + requestName + "缺少ALLAPP_DB_CHECK步骤！</br>";
				}
				//刪除ZIP
				delFile(new StringBuilder().append(file.getAbsolutePath())
							.append(CommonConst.FILE_SUFFIX_ZIP)
							.toString());
				//刪除目录下所有文件

				delAllFile(file.getAbsolutePath());
				i++;
			}
		}
		return msg;
	}*/
	
	/**
	 * 
	 * 导入BRPM.
	 * 
	 * @param String[] doGetFilesNamelist
	 * @param Map<String,String> uuidBrpmMap
	 * @param String appsys_code,
	 * @param String brpm
	 * @param String env
	 * @param String userId
	 * @param String requestor_id
	 * 
	 * 
	 */
	public Object BrpmImport(String[] doGetFilesNamelist,Map<String,String> uuidBrpmMap,String appsys_code, String brpm,
			String env, String userId,String requestor_id,String envExp) {
		String envImp = env.split(CommonConst.UNDERLINE)[1].toString();
		String yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String jobType = null;
		String filePath = null;
		if(ComUtil.isWindows){
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.brpmPackageImpPath"))
							.append(File.separator) 
							.append(userId)
							.append(File.separator) 
							.append(envImp)
							.toString();
		}else{
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
							.append(File.separator) 
							.append(userId)
							.append(File.separator) 
							.append(envImp)
							.toString();
		}
		String uuid = null;
		File[] fileList = new File(filePath).listFiles();
		String brpmToBsaInfo = null;
		if (doGetFilesNamelist.length > 0 && !doGetFilesNamelist.equals("")) {
			for (File file : fileList) {
				try{
					if(file.isDirectory()){
						String ffName = file.getName();
						if(ffName.substring(0, ffName.indexOf("_")).equals(appsys_code)){
						uuid=uuidBrpmMap.get(ffName.split(CommonConst.REPLACE_CHAR)[1]);//.split(CommonConst.DOT)[0]
						//更新导入状态表当前发起的BRPM请求任务状态

						updateDplyExcuteStatusRunningVo(uuid, CommonConst.MOVESTATUS_RUNNING_CH, "");
						File[] flist = printAllFile(file.getAbsoluteFile());
						String fName = null;
						String reqName = null;
						String reqId = null;
						boolean flag = false;
						String[] fRequstNameDiss = null;
						if ((brpm != null) && (brpm.length() != 0)) {
							for (File f : flist) {
								if (f.isFile()) {
									fName = f.getName();
									int iFlag = 0;
									boolean fileFlag = false;
									if (appsys_code != null && !"".equals(appsys_code)) {
										if (fName.startsWith(appsys_code)) {
											String fName2 = fName;
											reqName = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
											fName2 = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
											for (int i = 0; i < fName.length(); i++) {
												if (String.valueOf(fName.charAt(i)).equals(CommonConst.REPLACE_CHAR)) {
													iFlag++;
												}
											}
											if (iFlag == 1) {
												reqId = fName2.substring(0,fName2.indexOf(".xml"));
											}
											
											if (iFlag == 3 || iFlag == 5) {
												reqId = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
											}
											for (int j = 0; j < doGetFilesNamelist.length; j++) {
												if(doGetFilesNamelist[j].indexOf("DBCheck")!=-1){
													if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1])) {
														fileFlag = true;
														break;
													}
												}else{
													if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0])) {
														fileFlag = true;
														break;
													}
												}
											}
										}
									}
									
									if (iFlag == 5 && fileFlag == true && brpm.indexOf("1") != -1) {
										String step = fName.substring(0,fName.lastIndexOf(CommonConst.REPLACE_CHAR));
										String componentName = step.substring(step.lastIndexOf(CommonConst.REPLACE_CHAR) + 1);
										String componentId = fName.substring(fName.lastIndexOf(CommonConst.REPLACE_CHAR) + 1,fName.lastIndexOf(".xml"));
										String componentIdDis = "";
										{
											if (componentIdDis.equals("")) {
												logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_COMPONENTS + " { \"filters\": { \"name\":\"" + componentName + "\" }}");
												String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + componentName + "\" }}");
												logger.log("BRPM0002", componentsXml);
												if(componentsXml!=null){
													flag = true;
													Document docComponents = JDOMParserUtil.xmlParse(componentsXml);
													Element rootComponents = docComponents.getRootElement();
													String id = rootComponents.getChild("component").getChildText("id");
													
													StringBuffer putComponents = new StringBuffer();
													putComponents.append("<component><app_name>").append(appsys_code).append("</app_name></component>");
													logger.log("BRPM0001", "putMethod " + BrpmConstants.KEYWORD_COMPONENTS +  " id=" + id + " " + putComponents.toString());
													String componentsRes = method.putMethod(BrpmConstants.KEYWORD_COMPONENTS, id, putComponents.toString());
													logger.log("BRPM0002", componentsRes);
													StringBuffer comToEnv = new StringBuffer();
													comToEnv.append("<installed_component>")
														.append("<app_name>")
														.append(appsys_code)
														.append("</app_name>")
														.append("<component_name>")
														.append(componentName)
														.append("</component_name>")
														.append("<environment_name>")
														.append(env)
														.append("</environment_name>")
														.append("</installed_component>");
													logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_INSTALLED_COMPONENTS +  " " + comToEnv.toString());
													String installedComponentsRes = null;
													try{
														installedComponentsRes = method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,comToEnv.toString() );										
													}catch(Exception e){
														
													}
													logger.log("BRPM0002", installedComponentsRes);
												}
												
												if (flag == false) {
													StringBuffer componentXml = new StringBuffer();
													componentXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
														.append("<component>")
														.append("<name>")
														.append(componentName)
														.append("</name>")
														.append("<app_name>")
														.append(appsys_code)
														.append("</app_name>")
														.append("</component>");
													logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_COMPONENTS +  " " + componentXml.toString());
													String componentsRes = method.postMethod(BrpmConstants.KEYWORD_COMPONENTS,componentXml.toString());
													logger.log("BRPM0002", componentsRes);
													StringBuffer comToEnv = new StringBuffer();
													comToEnv.append("<installed_component>")
														.append("<app_name>")
														.append(appsys_code)
														.append("</app_name>")
														.append("<component_name>")
														.append(componentName)
														.append("</component_name>")
														.append("<environment_name>")
														.append(env)
														.append("</environment_name>")
														.append("</installed_component>");
													logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_INSTALLED_COMPONENTS +  " " + comToEnv.toString());
													String installedComponentsRes = null;
													try{
														installedComponentsRes = method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );
													}catch(Exception e){
														
													}
													logger.log("BRPM0002", installedComponentsRes);
													componentIdDis += componentId + ",";
												}
												flag = false;
											} else {
												String[] componentIds = componentIdDis.split(",");
												for (int i = 0; i < componentIds.length; i++) {
													if (componentIds[i].equals(componentId)) {
														logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_COMPONENTS + " { \"filters\": { \"name\":\"" + componentName + "\" }}");
														String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + componentName + "\" }}");
														logger.log("BRPM0002", componentsXml);
														if(componentsXml!=null){
															flag = true;
															Document docComponents = JDOMParserUtil.xmlParse(componentsXml);
															Element rootComponents = docComponents.getRootElement();
															String id = rootComponents.getChild("component").getChildText("id");
															StringBuffer putComponents = new StringBuffer();
															putComponents.append("<component><app_name>")
																.append(appsys_code)
																.append("</app_name></component>");
															logger.log("BRPM0001", "putMethod " + BrpmConstants.KEYWORD_COMPONENTS +  " id=" + id + " " + putComponents.toString());
															String componentsRes = method.putMethod(BrpmConstants.KEYWORD_COMPONENTS, id, putComponents.toString());
															logger.log("BRPM0002", componentsRes);
															StringBuffer comToEnv = new StringBuffer();
															comToEnv.append("<installed_component>")
																.append("<app_name>")
																.append(appsys_code)
																.append("</app_name>")
																.append("<component_name>")
																.append(componentName)
																.append("</component_name>")
																.append("<environment_name>")
																.append(env)
																.append("</environment_name>")
																.append("</installed_component>");
															logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_INSTALLED_COMPONENTS +  " " + comToEnv.toString());
															String installedComponentsRes = null;
															try{
																installedComponentsRes = method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );										
															}catch(Exception e){
																
															}
															logger.log("BRPM0002", installedComponentsRes);
															
														}
														if (flag == false) {
															StringBuffer componentXml = new StringBuffer();
															componentXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
																.append("<component>")
																.append("<name>")
																.append(componentName)
																.append("</name>")
																.append("<app_name>")
																.append(appsys_code)
																.append("</app_name>")
																.append("</component>");
															logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_COMPONENTS +  " " + componentXml.toString());
															String componentsRes = method.postMethod(BrpmConstants.KEYWORD_COMPONENTS,componentXml.toString());
															logger.log("BRPM0002", componentsRes);
															StringBuffer comToEnv = new StringBuffer();
															comToEnv.append("<installed_component>")
																.append("<app_name>")
																.append(appsys_code)
																.append("</app_name>")
																.append("<component_name>")
																.append(componentName)
																.append("</component_name>")
																.append("<environment_name>")
																.append(env)
																.append("</environment_name>")
																.append("</installed_component>");
															logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_INSTALLED_COMPONENTS +  " " + comToEnv.toString());
															String installedComponentsRes = null;
															try{
																installedComponentsRes = method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );
															}catch(Exception e){
																
															}
															logger.log("BRPM0002", installedComponentsRes);
															componentIdDis += componentId + ",";
														}
														flag = false;
													}
												}
											}
										}
									}
								}
							}
							//导入请求
							flag = false;
							String fNameDis = "";
							String requestName = null;
//							String requestId = null;
							String requestNewXml = null;
							for (File f : flist) {
								if (f.isFile()) {
									fName = f.getName();
									int iFlag = 0;
									boolean fileFlag = false;
									if (appsys_code != null && !"".equals(appsys_code)) {
										if (fName.startsWith(appsys_code)) {
											String fName2 = fName;
											reqName = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
											fName2 = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
											for (int i = 0; i < fName.length(); i++) {
												if (String.valueOf(fName.charAt(i)).equals(CommonConst.REPLACE_CHAR)) {
													iFlag++;
												}
											}
											if (iFlag == 1) {
												reqId = fName2.substring(0,fName2.indexOf(".xml"));
											}
											if (iFlag == 3 || iFlag == 5) {
												reqId = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
											}
											for (int j = 0; j < doGetFilesNamelist.length; j++) {
												/*if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split("DBCheck")[0])) {
													fileFlag = true;
													break;
												}*/
												if(doGetFilesNamelist[j].indexOf("DBCheck")!=-1){
													if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1])) {
														fileFlag = true;
														break;
													}
												}else{
													if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0])) {
														fileFlag = true;
														break;
													}
												}
												
											}
										}
									}
									if (iFlag == 1 && fileFlag == true) {
										requestName = fName.substring(0,fName.lastIndexOf(CommonConst.REPLACE_CHAR));
										fNameDis += requestName + ",";
									}
									if (iFlag == 1 && fileFlag == true && brpm.indexOf("3") != -1) {
										requestName = fName.substring(0,fName.lastIndexOf(CommonConst.REPLACE_CHAR));
//										requestId = fName.substring(fName.lastIndexOf(CommonConst.REPLACE_CHAR) + 1,fName.lastIndexOf(".xml"));
										{
											/*logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_REQUSET + " { \"filters\": { \"name\":\"" + requestName + "\" }}");
											String requestsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET, "{ \"filters\": { \"name\":\"" + requestName + "\" }}");
											logger.log("BRPM0002", requestsXml);*/
											if(null != method.checkRequest(requestName,env) && !("").equals(method.checkRequest(requestName,env))){											
												String id = method.checkRequest(requestName,env);
												logger.log("BRPM0001", "deleteMethod" + BrpmConstants.KEYWORD_REQUSET +  " id=" + id);
												String requestsRes = method.deleteMethod(BrpmConstants.KEYWORD_REQUSET,id);
												logger.log("BRPM0002", requestsRes);
											}
											
											if (flag == false) {
												StringBuffer requestXml = new StringBuffer();
												requestXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
													.append("<request>")
													.append("<name>")
													.append(requestName)
													.append("</name>")
													.append("<deployment_coordinator_id>")
													.append(requestor_id)
													.append("</deployment_coordinator_id>")
													.append("<requestor_id>")
													.append(requestor_id)
													.append("</requestor_id>")
													.append("<owner_id>")
													.append(requestor_id)
													.append("</owner_id>");
												logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_ENVIRONMENTS + " { \"filters\": { \"name\":\"" + env + "\" }}");
												String environmentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS, "{ \"filters\": { \"name\":\"" + env + "\" }}");
												logger.log("BRPM0002", environmentsXml);
												if(environmentsXml!=null){
													Document docEnvironments = JDOMParserUtil.xmlParse(environmentsXml);
													Element rootEnvironments = docEnvironments.getRootElement();
													String id = rootEnvironments.getChild("environment").getChildText("id");
													requestXml.append("<environment_id>")
														.append(id)
														.append("</environment_id>");
												}
												logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_APPS + " { \"filters\": { \"name\":\"" + appsys_code + "\" }}");
												String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + appsys_code + "\" }}");	
												logger.log("BRPM0002", appsXml);
												if(appsXml!=null){
													Document docApps = JDOMParserUtil.xmlParse(appsXml);
													Element rootApps = docApps.getRootElement();
													String id = rootApps.getChild("app").getChildText("id");	
													requestXml.append("<app_ids>")
														.append(id)
														.append("</app_ids>");
												}
												requestXml.append("</request>");
												logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_REQUSET +  " " + requestXml.toString());
												requestNewXml = method.postMethod(BrpmConstants.KEYWORD_REQUSET,requestXml.toString());
												logger.log("BRPM0002", requestNewXml);
											}
											flag = false;
										}
										String requestXml = importFile(
												new StringBuilder().append(file.getAbsolutePath())
													.append(File.separator)
													.append(fName)
													.toString()
												);
										Document descriptionDoc = JDOMParserUtil.xmlParse(requestXml);
										Element descriptionRoot = descriptionDoc.getRootElement();
										String description = descriptionRoot.getChildText("description");
										
										dplyReqInfoDelAndAdd(appsys_code,requestName,env,description);
									}
								}
							}
							fRequstNameDiss = fNameDis.split(",");
							List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
							for (int i = 0; i < fRequstNameDiss.length; i++) {
								for (File f : flist) {
									if (f.isFile()) {
										fName = f.getName();
										int iFlag = 0;
										boolean fileFlag = false;
										if (appsys_code != null && !"".equals(appsys_code)) {
											if (fName.startsWith(appsys_code)) {
												String fName2 = fName;
												reqName = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
												fName2 = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
												for (int j = 0; j < fName.length(); j++) {
													if (String.valueOf(fName.charAt(j)).equals(CommonConst.REPLACE_CHAR)) {
														iFlag++;
													}
												}
												if (iFlag == 1) {
													reqId = fName2.substring(0,fName2.indexOf(".xml"));
												}
												if (iFlag == 3 || iFlag == 5) {
													reqId = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
												}
												for (int j = 0; j < doGetFilesNamelist.length; j++) {
													/*if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split("DBCheck")[0])) {
														fileFlag = true;
														break;
													}*/
													if(doGetFilesNamelist[j].indexOf("DBCheck")!=-1){
														if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1])) {
															fileFlag = true;
															break;
														}
													}else{
														if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0])) {
															fileFlag = true;
															break;
														}
													}
												}
											}
										}
										if (iFlag == 3 && fileFlag == true && brpm.indexOf("2") != -1) {
											String fName2 = fName.substring(0,fName.lastIndexOf(".xml"));
											fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
											fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
											requestName = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
//											requestId = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
											if (fRequstNameDiss[i].equals(requestName)) {
												Map<String, String> map = new HashMap<String, String>();
												String stepXmlFile = importFile(
														new StringBuilder().append(file.getAbsolutePath())
															.append(File.separator)
															.append(fName)
															.toString()
														);
												String position = "";
												Document doc = JDOMParserUtil.xmlParse(stepXmlFile);
												Element root = doc.getRootElement();
												position = root.getChildText("position");
												map.put("position", position);
												map.put("fName", fName);
												jsonMapList.add(map);
											}
											
										}
									}
								}
							}
							String postStepXml = "";
							String different_level_from_previous = "";
							LoginServiceClient loginClient = null;
							LoginUsingUserCredentialResponse loginResponse = null;
							List<Map<String, String>> jsonMapList2 = null;
							List<Map<String, String>> jsonMapList3 = null;
							for (int i = 0; i < fRequstNameDiss.length; i++) {
								jsonMapList2 = new ArrayList<Map<String, String>>();
								jsonMapList3 = new ArrayList<Map<String, String>>();
								for (Map<String, String> map : jsonMapList) {
									reqName = map.get("fName").substring(0, map.get("fName").indexOf(CommonConst.REPLACE_CHAR));
									if (reqName.equals(fRequstNameDiss[i])) {
										Map<String, String> map2 = new HashMap<String, String>();
										map2.put("position", map.get("position"));
										map2.put("fName", map.get("fName"));
										jsonMapList2.add(map2);
									}
								}
								//步骤排序
								for (int j = 0; j < jsonMapList2.size(); j++) {
									for (Map<String, String> map2 : jsonMapList2) {
										if (map2.get("position").equals(String.valueOf(j + 1))) {
											Map<String, String> map3 = new HashMap<String, String>();
											map3.put("position", map2.get("position"));
											map3.put("fName", map2.get("fName"));
											jsonMapList3.add(map3);
										}
									}
								}
								//步骤导入
								for (Map<String, String> map3 : jsonMapList3) {
									fName = map3.get("fName");
//									int iFlag = 0;
//									boolean fileFlag = false;
//									if (appsys_code != null && !"".equals(appsys_code)) {
//										if (fName.startsWith(appsys_code)) {
//											String fName2 = fName;
//											reqName = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
//											fName2 = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
//											for (int j = 0; j < fName.length(); j++) {
//												if (String.valueOf(fName.charAt(j)).equals(CommonConst.REPLACE_CHAR)) {
//													iFlag++;
//												}
//											}
//											if (iFlag == 1) {
//												reqId = fName2.substring(0,fName2.indexOf(".xml"));
//											}
//											if (iFlag == 3 || iFlag == 5) {
//												reqId = fName2.substring(0,fName2.indexOf(CommonConst.REPLACE_CHAR));
//											}
//											for (int j = 0; j < doGetFilesNamelist.length; j++) {
//												if (reqId.equals(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0])) {
//													fileFlag = true;
//													break;
//												}
//											}
//										}
//									}
//									if (iFlag == 3 && fileFlag == true && brpm.indexOf("2") != -1) {
										String fName2 = fName.substring(0,fName.lastIndexOf(".xml"));
										fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
										String stepName = fName2.substring(fName2.lastIndexOf(CommonConst.REPLACE_CHAR) + 1);
										fName2 = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
										requestName = fName2.substring(0,fName2.lastIndexOf(CommonConst.REPLACE_CHAR));
//										requestId = fName2.substring(fName2.indexOf(CommonConst.REPLACE_CHAR) + 1);
										{
											if (flag == false) {
												String stepXmlFile = importFile(new StringBuilder().append(file.getAbsolutePath())
															.append(File.separator)
															.append(fName)
															.toString());
												StringBuilder stepXml = new StringBuilder();
												stepXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
													.append("<step>")
													.append("<name>")
													.append(stepName)
													.append("</name>");
												Document docRequests = JDOMParserUtil.xmlParse(requestNewXml);
												Element rootRequests = docRequests.getRootElement();		
												stepXml.append("<request_id>")
													.append(rootRequests.getChildText("id"))
													.append("</request_id>");
												Document manualDoc = JDOMParserUtil.xmlParse(stepXmlFile);
												Element manualRoot = manualDoc.getRootElement();
												String manual = manualRoot.getChildText("manual");
												String description = "";
												stepXml.append("<manual>")
													.append(manual)
													.append("</manual>");
												if (manual.equals("false")) {
													Document scriptIdDoc = JDOMParserUtil.xmlParse(stepXmlFile);
													Element scriptIdRoot = scriptIdDoc.getRootElement();
													String script_id = scriptIdRoot.getChild("script").getChildText("id");
													stepXml.append("<script_id>")
														.append(script_id)
														.append("</script_id>")
														.append("<script_type>BladelogicScript</script_type>");
													Document descriptionDoc = JDOMParserUtil.xmlParse(stepXmlFile);
													Element descriptionRoot = descriptionDoc.getRootElement();
													description = descriptionRoot.getChildText("description");
												}
												stepXml.append("<owner_id>")
													.append(requestor_id)
													.append("</owner_id>");
												Document doc2 = JDOMParserUtil.xmlParse(stepXmlFile);
												Element root2 = doc2.getRootElement();
												String owner_type = root2.getChildText("owner-type");
												stepXml.append("<owner_type>")
													.append(owner_type)
													.append("</owner_type>");
												String component_name = "";
												Document doc4 = JDOMParserUtil.xmlParse(stepXmlFile);
												Element root4 = doc4.getRootElement();
												if (root4.getChild("component") != null) {
													component_name = root4.getChild("component").getChildText("name");
													logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_COMPONENTS + " { \"filters\": { \"name\":\"" + component_name + "\" }}");
													String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + component_name + "\" }}");
													logger.log("BRPM0002", componentsXml);
													Document docComponents = JDOMParserUtil.xmlParse(componentsXml);
													Element rootComponents = docComponents.getRootElement();
													String id = rootComponents.getChild("component").getChildText("id");
													stepXml.append("<component_id>")
														.append(id)
														.append("</component_id>")
														.append("<installed_component_id>")
														.append(id)
														.append("</installed_component_id>");
												}
												Document doc = JDOMParserUtil.xmlParse(stepXmlFile);
												Element root = doc.getRootElement();
												different_level_from_previous = root.getChildText("different-level-from-previous");
												stepXml.append("<different_level_from_previous>")
													.append(different_level_from_previous)
													.append("</different_level_from_previous>")
													.append("</step>");
												logger.log("BRPM0001", "postMethod " + BrpmConstants.KEYWORD_STEPS +  " " + stepXml.toString());
												postStepXml = method.postMethod(BrpmConstants.KEYWORD_STEPS,stepXml.toString());
												logger.log("BRPM0002", postStepXml);
												if ((!description.equals("")) && manual.equals("false")) {
													
													Document docStepDoc = JDOMParserUtil.xmlParse(postStepXml);
													Element StepRoot = docStepDoc.getRootElement();
													String id = StepRoot.getChildText("id");
													if(description.indexOf("#")!=-1){
														String jobPath = null;
														String[] jobPaths = null;
														String jobName = null;
														if(description.indexOf(CommonConst.DB_CHECK)!=-1){
															jobPath = CommonConst.DB_CHECK_PATH;
															jobName = CommonConst.DB_CHECK;// ,description.indexOf("@")
															
														}else{
															jobPath = description.substring(1, description.indexOf("#"));
															
															jobPaths = jobPath.split(CommonConst.SLASH);
															jobPath = "";
															if(jobPaths[0].equals(envExp)){
																jobPaths[0]=envImp;
																for(int j=0;j<jobPaths.length;j++){
																	if(j==0){
																		jobPath +=  jobPaths[j];
																	}else{
																		jobPath += CommonConst.SLASH + jobPaths[j];
																	}
																}
															}else{
																jobPath = envImp;
																for(int j=0;j<jobPaths.length;j++){
																	jobPath += CommonConst.SLASH + jobPaths[j];
																}
															}
															jobPath = messages.getMessage("bsa.deployPath").concat(jobPath);
															jobName = description.substring(description.indexOf("#") + 1);// ,description.indexOf("@")
															
														}
														// 用户登录
														loginClient = new LoginServiceClient(
																messages.getMessage("bsa.userName")
																,messages.getMessage("bsa.userPassword")
																,messages.getMessage("bsa.authenticationType")
																,null
																,new StringBuilder().append(System.getProperty("maop.root"))
																	.append(File.separator)
																	.append(messages.getMessage("bsa.truststoreFile"))
																	.toString()
																,messages.getMessage("bsa.truststoreFilePassword"));
														loginResponse = loginClient.loginUsingUserCredential();
														
														CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
														ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
														
														executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
														String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
														
														executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
														String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
														brpmToBsaInfo = null;
														if(DeployJobDBkey.equals("void")&&NSHScriptJob.equals("void")){
															brpmToBsaInfo = "请求步骤".concat(stepName).concat("关联BSA作业").concat(jobPath).concat("/").concat(jobName).concat("失败,因为此作业不存在！");
															break;
														}else if(!DeployJobDBkey.equals("void")){
															jobType = "DeployJob";
														}else if(!NSHScriptJob.equals("void")){
															jobType = "NSHScriptJob";
														}
														
														executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(jobType,"getDBKeyByGroupAndName",new String[] { jobPath,jobName });
														String groupNameToDBKey = (String) executeCommandByParamListResponse.get_return().getReturnValue();
														
														executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupNameToDBKey",new String[] { jobPath });
														String groupNameToDBKey2 = (String) executeCommandByParamListResponse.get_return().getReturnValue();
														
														if(!groupNameToDBKey.equals("void")&&!groupNameToDBKey2.equals("void")){
															
															executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("GenericObject","getRESTfulURI",new String[] { groupNameToDBKey });
															String getRESTfulURI = (String) executeCommandByParamListResponse.get_return().getReturnValue();
															
															if(getRESTfulURI.lastIndexOf("/")!=-1){
																getRESTfulURI = getRESTfulURI.substring(getRESTfulURI.lastIndexOf("/")+1);
																logger.log("BRPM0001", "update steps and insert into step_script_arguments");
																method.scriptArguId(id,	groupNameToDBKey,getRESTfulURI, jobName,jobType);
															}
														}
													}
													
													
												}
											}
											flag = false;
										}
//									}
								}
							}
						}
						//刪除ZIP
						delFile(new StringBuilder().append(file.getAbsolutePath())
									.append(CommonConst.FILE_SUFFIX_ZIP)
									.toString());
						//刪除目录下所有文件

						delAllFile(file.getAbsolutePath());
						if(brpmToBsaInfo==null||brpmToBsaInfo.equals("")||brpmToBsaInfo.length()==0){
							//备份FTP上的BRPM请求ZIP文件
							String remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
									.append(messages.getMessage("path.linux"))
									.append(envExp)
									.append(messages.getMessage("path.linux"))
									.append( messages.getMessage("importServer.brpmPath"))
									.append(messages.getMessage("path.linux"))
									.append(file.getAbsoluteFile().getName())
									.append(CommonConst.FILE_SUFFIX_ZIP).toString();
							String remoteFileBakname = new StringBuilder().append(messages.getMessage("exportServer.path"))
									.append(messages.getMessage("path.linux"))
									.append(envImp)
									.append(messages.getMessage("path.linux"))
									.append(messages.getMessage("exportServer.bakPath"))
									.append(messages.getMessage("path.linux"))
									.append( messages.getMessage("exportServer.brpmPath"))
									.append(messages.getMessage("path.linux"))
									.append(file.getAbsoluteFile().getName())
									.append(yyyyMMddHHmmss)
									.append(CommonConst.FILE_SUFFIX_ZIP).toString();
							ftpDelToolstar(remoteFilename,remoteFileBakname,envImp);
							//更新状态表
							updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_OK_CH, "");
						}else{
							updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, brpmToBsaInfo);
						}
						
						}
					}
				}catch(Exception e){
					updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
				}
			}
		}
		return true;
	}

	/**
	 * 
	 * 遍历读取指定路径下的文件名.
	 * 
	 * @param File fpath
	 * 
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
	 * 
	 * 解压zip文件包
	 * 
	 * @param String path
	 * @param String appsys_code
	 * 
	 * @throws IOException
	 */
	public void unZip(String path, String appsys_code) throws Exception {
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
					
					ZipFile zipFile = null;
					try{
						zipFile = new ZipFile(path2, "GBK");
						Enumeration<?> entries = zipFile.getEntries();
						while (entries.hasMoreElements()) {
							byte buf[] = new byte[buffer];
							ZipEntry entry = (ZipEntry) entries.nextElement();
							String filename = entry.getName();
							index = filename.lastIndexOf(messages.getMessage("path.linux"));
							if (index > -1){
								filename = filename.substring(index + 1);
							}
							filename = new StringBuilder().append(savepath)
									.append(File.separator) 
									.append(fName.substring(0, fName.indexOf(".zip")))
									.append(File.separator)
									.append(filename)
									.toString();
							
							File sourceFile = new File(
									new StringBuilder().append(savepath)
										.append(File.separator)
										.append(fName.substring(0, fName.indexOf(".zip"))) 
										.append(File.separator)
										.toString()
									);
							if (!sourceFile.exists()) {
								sourceFile.mkdirs();
							}
							file = new File(filename);
							file.createNewFile();
							try{
								is = zipFile.getInputStream(entry);
								fos = new FileOutputStream(file);
								bos = new BufferedOutputStream(fos, buffer);
								while ((count = is.read(buf)) > -1) {
									bos.write(buf, 0, count);
								}
							}catch(Exception e){
								throw e;
							}finally{
								if(null != fos){
									fos.close();
								}
								if(null != is){
									is.close();
								}
							}
						}
					}catch(Exception e){
						throw e;
					}finally{
						if(null != zipFile){
							zipFile.close();
						}
					}
					
					delFile(
							new StringBuilder().append(savepath)
								.append(File.separator)
								.append(fName.substring(0, fName.indexOf(".zip")))
								.toString()
							);
				}
			}
		}
	}

	/**
	 * 
	 * 删除指定路径文件夹里面的所有文件.
	 * 
	 * @param path String 
	 * 
	 */
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
			temp = new File(
					new StringBuilder().append(path)
						.append(File.separator)
						.append(tempList[i])
						.toString()
					);
			if (temp.isDirectory()) {
				delAllFile(
						new StringBuilder().append(path)
							.append(File.separator)
							.append(tempList[i])
							.toString()
						);// 先删除文件夹里面的文件
			}
			temp.delete();
		}
	}
	
	/**
	 * 
	 * 删除文件夹里面的所有文件
	 * 
	 * @param path String 文件夹路径
	 * 
	 */
	public void delAppZipFile(String path,String appSysCd) {
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
			temp = new File(
					new StringBuilder().append(path)
						.append(File.separator)
						.append(tempList[i])
						.toString()
					);
			if (temp.isFile() 
				&& (temp.getAbsoluteFile().getName().indexOf(appSysCd.concat(CommonConst.FILE_SUFFIX_ZIP)) != -1
				|| temp.getAbsoluteFile().getName().indexOf(appSysCd.concat(CommonConst.FILE_SUFFIX_TAR)) != -1)) {
				temp.delete();
			}
		}
	}


	/**
	 * 
	 * 读取文件内容
	 * 
	 * @param String path
	 * 
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public String importFile(String fpath) throws Exception {
		
		String xmlLine = new String();
		StringBuilder xml = new StringBuilder();
		Reader reader = null;
		BufferedReader br = null;
		try{
			reader = new InputStreamReader(new FileInputStream(fpath),"utf-8");
			br = new BufferedReader(reader);
			while ((xmlLine = br.readLine()) != null) {
				xml.append(xmlLine) ;
			}
		}catch(Exception e){
			throw e;
		}finally{
			if(null != br){
				br.close();
			}
		}
		
		return xml.toString();
	}

	/**
	 * 
	 * FTP获取文件
	 * 
	 * @param String appsys_code
	 * @param String bmc
	 * @param String userId
	 * 
	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 * 
	 */
	@Transactional
	public void ftpGetFileServer(String appsys_code, String bmc, String userId, String env, String envExp) throws NoSuchMessageException, IOException {
		String host = messages.getMessage("importServer.ipAdress");
		int port = (Integer.parseInt(messages.getMessage("importServer.port")));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host, port, user, password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String remoteFilename = "";
		String localFilename = "";
		File zipPackagebsa = null;
		if (bmc.equals("bsa")) {
			remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(envExp)
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("importServer.bsaPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".tar")
					.toString();
			if(ComUtil.isWindows){
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".tar")
						.toString();
				zipPackagebsa = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
							.append(File.separator)
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
			}else{
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".tar")
						.toString();
				zipPackagebsa = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
							.append(File.separator)
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
			}
			if (!zipPackagebsa.exists()) {
				zipPackagebsa.mkdirs();
			}
		}
		if (bmc.equals("brpm")) {
			remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(envExp)
					.append(messages.getMessage("path.linux"))
					.append( messages.getMessage("importServer.brpmPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.toString();
			File zipPackage = null;
			if(ComUtil.isWindows){
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.brpmPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.toString();
				zipPackage = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.brpmPackageImpPath"))
							.append(File.separator)
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
			}else{
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.toString();
				zipPackage = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
							.append(File.separator)
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
			}
			if (!zipPackage.exists()) {
				zipPackage.mkdirs();
			}
		}
		if (bmc.equals("param")) {
			remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(envExp)
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("importServer.paramPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".zip")
					.toString();
			File zipPackage = null;
			if(ComUtil.isWindows){
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.paramPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".zip")
						.toString();
				zipPackage = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.paramPackageImpPath"))
							.append(File.separator) 
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
				
			}else{
				localFilename = new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".zip")
						.toString();
				zipPackage = new File(
						new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
							.append(File.separator)
							.append(userId)
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString()
						);
				
			}
			if (!zipPackage.exists()) {
				zipPackage.mkdirs();
			}
		}
		String remoteFilename2 = remoteFilename.substring(remoteFilename.indexOf(messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat(envExp).concat(messages.getMessage("path.linux"))),remoteFilename.lastIndexOf(messages.getMessage("path.linux")));
        ftpFile.renamelFile(messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat(envExp), remoteFilename2);
		ftpFile.doGet(remoteFilename, localFilename, true, new StringBuffer());
		ftpLogin.disconnect();
	}

	
	/**
	 * 根据条件查找交易信息记录
	 * 
	 * @param appsys_code
	 * @param userId
	 * 
	 * @throws ParseException
	 * @throws IOException
	 * @throws HttpHostConnectException
	 * @throws FtpCmpException
	 * 
	 * 
	 */
	@Transactional(readOnly = true)
	public Object getRequest(String appsys_code, String userId,String env) throws ParseException,IOException, HttpHostConnectException,FtpCmpException {
		File brpmZipPackageImpPath = null;
		File bsaZipPackageImpPath = null;
		File paramPackagePath = null;
		if(ComUtil.isWindows){
			brpmZipPackageImpPath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.brpmPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
			bsaZipPackageImpPath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
			paramPackagePath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.paramPackagePath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
		}else{
			brpmZipPackageImpPath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.brpmPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
			bsaZipPackageImpPath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
			paramPackagePath = new File(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.paramPackagePathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.toString()
					);
			
		}
		
		delAppZipFile(bsaZipPackageImpPath.getAbsolutePath(),appsys_code);
		delAllFile(
				new StringBuilder().append(bsaZipPackageImpPath.getAbsolutePath())
					.append(File.separator)
					.append(appsys_code)
					.toString()
				);
		
		delAppZipFile(paramPackagePath.getAbsolutePath(),appsys_code);
		delAllFile(
				new StringBuilder().append(paramPackagePath.getAbsolutePath())
					.append(File.separator)
					.append(appsys_code)
					.toString()
				);

		//MKDIR
		if(!brpmZipPackageImpPath.exists()){
			logger.log("Deploy0001", brpmZipPackageImpPath.getAbsolutePath());
			logger.log("Deploy0001", brpmZipPackageImpPath.exists());
			brpmZipPackageImpPath.mkdirs();
		}
		if(!bsaZipPackageImpPath.exists()){
			logger.log("Deploy0001", bsaZipPackageImpPath.getAbsolutePath());
			logger.log("Deploy0001", bsaZipPackageImpPath.exists());
			bsaZipPackageImpPath.mkdirs();
		}
		if(!paramPackagePath.exists()){
			logger.log("Deploy0001", paramPackagePath.getAbsolutePath());
			logger.log("Deploy0001", paramPackagePath.exists());
			paramPackagePath.mkdirs();
		}
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
		String[] doGetFilesNamelist = componentFtp.doGetFilesNamelist(
				new StringBuilder().append(messages.getMessage("importServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(env)
					.append(messages.getMessage("path.linux"))
					.append( messages.getMessage("importServer.brpmPath"))
					.toString()
				);
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
//		Date date = new Date();
//		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String reqId = null;
		String reqName = null;
		for(int i=0;i<doGetFilesNamelist.length;i++){
			Map<String,String> map = new HashMap<String,String>();
			if(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0].substring(0, appsys_code.length()+1).equals(appsys_code.concat("_"))){
				map.put("reqId", doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0]);
				map.put("reqName", doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0]);
				jsonMapList.add(map);
			}
		}
		ftpLogin.disconnect();
		//按日期排序
		for (int i = 0; i < jsonMapList.size() - 1; i++) {
			for (int j = 0; j < jsonMapList.size() - i - 1; j++) {
				SimpleDateFormat dateFormat = new SimpleDateFormat(
						"yyyyMMdd");
				if(jsonMapList.get(j).get("reqName").indexOf("REQ_")!=-1
				  ||jsonMapList.get(j).get("reqName").indexOf("REQRST_")!=-1){
					int indexDate1 = -1;
					if(jsonMapList.get(j).get("reqName").indexOf("REQ_")!=-1){
						indexDate1 = jsonMapList.get(j).get("reqName").indexOf("REQ_")+4;
					}
					if(jsonMapList.get(j).get("reqName").indexOf("REQRST_")!=-1){
						indexDate1 = jsonMapList.get(j).get("reqName").indexOf("REQRST_")+7;
					}
					int indexDate2 = -1;
					if(jsonMapList.get(j+1).get("reqName").indexOf("REQ_")!=-1){
						indexDate2 = jsonMapList.get(j+1).get("reqName").indexOf("REQ_")+4;
					}
					if(jsonMapList.get(j+1).get("reqName").indexOf("REQRST_")!=-1){
						indexDate2 = jsonMapList.get(j+1).get("reqName").indexOf("REQRST_")+7;
					}
					Date date1 = dateFormat.parse(jsonMapList.get(j).get("reqName").substring(indexDate1, indexDate1 + 8));
					Date date2 = dateFormat.parse(jsonMapList.get(j + 1).get("reqName").substring(indexDate2, indexDate2 + 8));
					if (date1.before(date2)) {
						Map<String, String> map = new HashMap<String, String>();
						Map<String, String> map2 = new HashMap<String, String>();
						reqId = jsonMapList.get(j).get("reqId");
						reqName = jsonMapList.get(j).get("reqName");
						map.put("reqId", reqId);
						map.put("reqName", reqName);
						String reqId2 = jsonMapList.get(j + 1).get("reqId");
						String reqName2 = jsonMapList.get(j + 1).get("reqName");
						map2.put("reqId", reqId2);
						map2.put("reqName", reqName2);
						jsonMapList.set(j, map2);
						jsonMapList.set(j + 1, map);
					}
				}
			}
		}
		return jsonMapList;
	}



	/**
	 * 
	 * 删除指定文件
	 * 
	 * @param String path 文件夹路径

	 * 
	 * 
	 */

	public void delFile(String path) {
		File file = new File(path);
		if (file.isFile() && file.exists()) {
			file.delete();
		}
	}

	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUser(String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("select s.appsys_code as \"appsysCode\", ")
				.append(" s.systemname as \"appsysName\" ")
				.append(" from v_cmn_app_info s  ")
				.append(" where exists (select * from cmn_user_app u  ")
				.append(" where s.appsys_code = u.appsys_code ")
				.append(" and u.user_id = :userId)   and s.status = '使用中' and s.delete_flag=0 ")
				.append(" order by s.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	/*@Transactional(readOnly = true)
	public Object queryEnv(String userId) {
		StringBuilder sql = new StringBuilder();
		
		sql.append(" select c.environment_code as \"env\", ")
			.append(" j.sub_item_name ||'('|| c.environment_code ||')' as \"envName\" ")
			.append(" from cmn_environment c, jeda_sub_item j , v_cmn_app_info s ")
			.append(" where exists ")
			.append(" (select * from cmn_user_app ua,cmn_user_env ue ")
			.append("  where s.appsys_code = ua.appsys_code ")
			.append("  and c.appsys_code   = ua.appsys_code ")
			.append("  and ua.user_id       = :userId ")
			.append("  and ue.user_id = :userId ")
			.append("  and c.environment_code = ")
			.append("  substr(c.environment_code,0,instr(c.environment_code,'_')-1)||'_'|| ")
			.append("  (case when ue.env='DEV' then 'DEV' ")
			.append("        when ue.env='QA' then 'QA' ")
			.append("        when ue.env='PROV' then 'PROV' ")
			.append("        when ue.env='PROD' then 'PROD' ")
			.append("        else '' end )||'_ENV' ) ")
			.append(" and c.environment_type = j.sub_item_value ")
			.append(" and j.item_id          ='SYSTEM_ENVIRONMENT' ")
			.append(" and s.status           = '使用中' ");

		return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();		
	}*/
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object queryEnv(String appsysCode,String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append(" SELECT  '")
			.append(appsysCode)
			.append("_'||me.sub_item_name||'_ENV' AS \"env\", ")
			.append(" (case when me.sub_item_name='DEV' then '开发' ")
			.append("       when me.sub_item_name='QA' then '测试' ")
			.append("       when me.sub_item_name='PROV' then '验证' ")
			.append("       when me.sub_item_name='PROD' then '生产' ")
			.append("       else '' end )||'(")
			.append(appsysCode)
			.append("_'||me.sub_item_name||'_ENV)' AS \"envName\" ")
			.append(" FROM jeda_sub_item me,cmn_user_env ue ")
			.append(" WHERE me.item_id='MOVE_ENV' ")
			.append(" and ue.user_id=:userId ")
			.append(" and ue.env=me.sub_item_name ")
			.append(" GROUP BY me.sub_item_name ");
		 

	
		
		
		return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();		
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object queryExpEnv(String env) {
		
		
		StringBuilder sql = new StringBuilder();
		
		/*sql.append("select t.env as \"envExp\",")
			.append("    si.sub_item_name")
			.append("  ||'('")
			.append("  || t.env")
			.append("  ||')' as \"envNameExp\"")
			.append("from (")
			.append("select '")
			.append(env.split(CommonConst.UNDERLINE)[0].toString())
			.append("_'")
			.append("  ||sub_item_value")
			.append("  ||'_ENV' as env")
			.append(" from jeda_sub_item j ")
			.append(" where j.item_id  ='MOVE_ENV' ")
			.append(" and j.sub_item_name='")
			.append(env.split(CommonConst.UNDERLINE)[1].toString())
			.append("') t,jeda_sub_item si ,cmn_environment c ")
			.append(" where c.environment_code=t.env ")
			.append(" and c.environment_type = si.sub_item_value ")
			.append(" and si.item_id          ='SYSTEM_ENVIRONMENT' ");*/
		
		
		sql.append("select t.app_env as \"envExp\",")
		.append("    si.sub_item_name")
		.append("  ||'('")
		.append("  || t.app_env")
		.append("  ||')' as \"envNameExp\"")
		.append("from (")
		.append("select '")
		.append(env.split(CommonConst.UNDERLINE)[0].toString())
		.append("_'")
		.append("  ||sub_item_value")
		.append("  ||'_ENV' as app_env, j.sub_item_value env")
		.append(" from jeda_sub_item j ")
		.append(" where j.item_id  ='MOVE_ENV' ")
		.append(" and j.sub_item_name='")
		.append(env.split(CommonConst.UNDERLINE)[1].toString())
		.append("') t,jeda_sub_item si  ")
		.append(" where si.item_id ='SYSTEM_ENVIRONMENT' ")
		.append(" and si.sub_item_value = t.env ");
		
		return getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();		
	}
	
	
	/**
	 * 更新请求信息表
	 * 
	 * @param String appsys_code
	 * @param String requestName
	 * @param String env
	 * @param String description
	 * 
	 * 
	 */
	@Transactional(readOnly = true)
	public void dplyReqInfoDelAndAdd(String appsys_code,String requestName,String env,String description){
		StringBuilder deleteReqSql = new StringBuilder();
		deleteReqSql.append("delete from dply_request_info where APPSYS_CODE ='")
			.append(appsys_code)
			.append("' and REQUEST_CODE = '")
			.append(requestName)
			.append("' ");
		getSession().createSQLQuery(deleteReqSql.toString()).executeUpdate();
		StringBuilder insertReqSql = new StringBuilder();
		insertReqSql.append("insert into dply_request_info")
			.append("(APPSYS_CODE ,")
			.append("REQUEST_CODE, ")
			.append("REQUEST_NAME,")
			.append("ENVIRONMENT,")
			.append("TURN_SWITCH ,")
			.append("EXEC_STATUS,")
			.append("EXPORT_USER,")
			.append("IMPORT_USER) ")
			.append("values ( '")
			.append(appsys_code)
			.append("' , '")
			.append(requestName)
			.append("', '")
			.append(requestName)
			.append("','")
			.append(env)
			.append("','0','1','")
			.append(description)
			.append("','")
			.append(securityUtils.getUser().getUsername())
			.append("')");
		getSession().createSQLQuery(insertReqSql.toString()).executeUpdate();
	}
	
	/**
	 * FTP在文件服务器备份文件
	 * 
	 * @param from
	 * @param to
	 * 
	 * @throws FtpCmpException
	 * @throws IOException 
	 */
	@Transactional
	public  void ftpDelToolstar(String from,String to,String envImp) throws FtpCmpException, IOException {
		String host = messages.getMessage("exportServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("exportServer.user");
		String password = messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String to2 = to.substring(to.indexOf(messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(envImp).concat(messages.getMessage("path.linux")))+messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(envImp).concat(messages.getMessage("path.linux")).length(),to.lastIndexOf(messages.getMessage("path.linux")));
		ftpFile.doMkdirs(messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(envImp),to2);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
        ftpFile2.renamelFile(from, to);
		ftpLogin2.disconnect();
	}
	
	/**
	 * 单用户导入多系统数据字典开关检查

	 * 
	 */
	@Transactional
	public boolean singUserImpMulSysSwitchCheck(){
		String sql = "select sub_item_name from jeda_sub_item where item_id='SING_USER_IMP_MUL_SYS_SWITCH' AND sub_item_value='1'";
		Query query = getSession().createSQLQuery(sql.toString());
		String singUserImpMulSysSwitchCheckFlag = query.uniqueResult().toString();
		if(singUserImpMulSysSwitchCheckFlag.equals("关闭")){
			return false;
		}else{
			return true;
		}
	}
	
	/**
	 * 单用户导入多系统检查

	 * 
	 */
	@Transactional
	public boolean singUserImpMulSysCheck(String userId,String env){
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from dply_execute_status where USER_ID='")
			.append(userId)
			.append("' and ENVIRONMENT='")
			.append(env)
			.append("' AND (MOVE_STATUS='等待' OR MOVE_STATUS = '进行中')");
		//select count(*) from dply_execute_status where USER_ID='w03505' AND （MOVE_STATUS='等待' OR MOVE_STATUS = '进行中'）

		Query query = getSession().createSQLQuery(sql.toString());
		String singUserImpMulSysCheckFlag = query.uniqueResult().toString();
		if(singUserImpMulSysCheckFlag.equals("0")){
			return true;
		}else{
			return false;
		}
	}
	
	/**
	 * 多用户导入单系统检查

	 * 
	 */
	@Transactional
	public boolean mulUserImpSingSysCheck(String appsys_code,String env){
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from dply_execute_status where APPSYS_CODE='")
			.append(appsys_code)
			.append("' and ENVIRONMENT='")
			.append(env)
			.append("' AND (MOVE_STATUS='等待' OR MOVE_STATUS = '进行中')");
		//select count(*) from dply_execute_status where APPSYS_CODE='NEXCH' AND (MOVE_STATUS='等待' OR MOVE_STATUS = '进行中')
		Query query = getSession().createSQLQuery(sql.toString());
		String mulUserImpSingSysCheckFlag = query.uniqueResult().toString();
		if(mulUserImpSingSysCheckFlag.equals("0")){
			return true;
		}else{
			return false;
		}
	}
	
	/**
	 * 单用户导入多系统数据字典开关检查
	 * 
	 */
	@Transactional
	public boolean envCheck(String env){
		try {
			logger.log("BRPM0001", "getMethodByFilter " + BrpmConstants.KEYWORD_ENVIRONMENTS + " { \"filters\": { \"name\":\"" + env + "\" }}");
			String environmentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS, "{ \"filters\": { \"name\":\"" + env + "\" }}");
			logger.log("BRPM0002", environmentsXml);
			if(environmentsXml!=null){
				return true;

			}else{
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false; 
		
	}
	
	
	/**
	 * FTP在DB服务器获取BSA信息目录

	 * 
	 * @param customer
	 * @throws IOException 
	 */
	@Transactional
	public boolean ftpgetBSAs(String appsys_code,String env,String bsa) throws FtpCmpException, IOException {
		boolean b=false;
		String str="";
		String path="";
		if(bsa.equals("bsa")){
			path=messages.getMessage("importServer.path")+CommonConst.SLASH+env+CommonConst.SLASH+messages.getMessage("importServer.bsaPath");
			str=appsys_code.concat(".tar");
		}else{
			path=messages.getMessage("importServer.path")+CommonConst.SLASH+env+CommonConst.SLASH+messages.getMessage("importServer.paramPath");
			str=appsys_code.concat(".zip");
		}
		
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String[] scrppts=ftpFile.doGetFilesNamelist(path);
		ftpLogin.disconnect();
		for(String script :scrppts)	{
			if(str.equals(script)){
				b=true;
			}
		}
		return b;

	}
	
}
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
import java.net.SocketTimeoutException;
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

import org.apache.axis2.AxisFault;
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
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.authorize.DepotDeployAuthorize;
import com.nantian.component.bsa.authorize.JobDeployAuthorize;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.parameter.ParamImport;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
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
public class MoveImport4Service {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveImport4Service.class);

	public static Map<String, String> fields = new HashMap<String, String>();

	/** 功能ID */
	private static final String FUNCTION_ID = "MoveImport4Service";

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

	public MoveImport4Service() {
		super();
	}

	/**
	 * 查询系统平台
	 * 
	 * @throws SQLException
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object getCmnAppInfo() {
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();

		String sql = "SELECT s.appsys_code as appsys_code,s.appsys_name as appsys_name FROM CMN_APP_INFO s order by appsys_code ";

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
	 * ftp到bsa服务器

	 * 
	 * @param String
	 *            appsys_code,String path1,String path2
	 */
	@Transactional
	public void importFtp(String appsys_code, String path1, String path2) {
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
	 * 删除bsa服务器上的文件

	 * 
	 * @param String
	 *            appsys_code,String path1,String path2
	 * @throws AxisFault,Exception 
	 */
	@Transactional
	public void deleteBsaFile(String appsys_code) throws AxisFault,Exception {
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();

		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code)});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyCreatExportJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code)});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code),"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath"))});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob").concat(appsys_code),"1",appsys_code});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}
	
	/**
     * 创建导出开始记录.
     * @param entryId
     * @param appsys_code
     * @param tranItemS
     * @param brpm
     * @param bsa
     * @throws Exception 
     */
    @Transactional
	public void save(String entryId, String status, String appsys_code,String tranItemS,String brpm,String bsa){
		DplyExcuteStatusVo vo = new DplyExcuteStatusVo();
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		vo.setEntryId(entryId);
		vo.setAppsysCode(appsys_code);
		vo.setUserId(securityUtils.getUser().getUsername());
		vo.setExcuteStartTime(tt);
		vo.setMoveStatus(status);
		vo.setOperateType("导入");
		if((brpm!=null)&&(brpm.length()!=0)&&(bsa!=null)&&(bsa.length()!=0)){
			vo.setOperateSource("发布请求资源和发布作业资源");
		}else if((bsa!=null && bsa.length()!=0) && (brpm==null || "".equals(brpm))){
			vo.setOperateSource("发布作业资源");
		}else if((brpm!=null && brpm.length()!=0) && (bsa==null || "".equals(bsa))){
			vo.setOperateSource("发布请求资源");
		}
		getSession().save(vo);
	}
	
    /**
     * 更新导出记录状态信息.
     * @param entryId
     * @param moveStatus
     * @param errMsg
     * @throws Exception 
     */
    @Transactional
	public void update(String entryId,String moveStatus,String errMsg){
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
	 * 导入.
	 * 
	 * @param String
	 *            appsys_code,String tranItemS,String brpm,String bsa
	 * @throws URISyntaxException
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws Throwable
	 * @throws Exception
	 */
	@Transactional
	public void import2(String appsys_code, String tranItemS, String brpm,
			String bsa, String env, String userId) throws IOException,
			BrpmInvocationException, URISyntaxException, Exception,
			HttpHostConnectException, SocketTimeoutException, Throwable {

		// String filePath = "E:\\workspace\\brpmPackage\\brpmPackage";
String appsys_code2 = null;
		String jobType = null;
for(Integer z=1;z<50;z++){
	
	if(z<10){
		appsys_code2 = "APP0"+z.toString();
	}else{
		appsys_code2 = "APP"+z.toString();
	}
	env = appsys_code2+"_DEV_ENV";
	
	
	
	/*if ((bsa != null) && (bsa.length() != 0)) {
		if (bsa.equals("1")) {
			// importFtp(appsys_code,System.getProperty("maop.root")+File.separator+messages.getMessage("systemServer.bsaZipPackageImpPath")+File.separator+appsys_code+".tar");
			
			deleteBsaFile(appsys_code);
			
			ftpGetFileServer(appsys_code, "bsa", userId);
			ftpGetFileServer(appsys_code, "param", userId);
			importBsa(appsys_code,userId);
			String remoteFilename = null;
			remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.bsaPath")).concat(messages.getMessage("path.linux")).concat(appsys_code).concat(".tar");
			ftpDelToolstar(remoteFilename);
			if(ComUtil.isWindows){
				unZip(System.getProperty("maop.root").concat(messages.getMessage("systemServer.paramPackageImpPath"))
						.concat(File.separator) .concat(userId) .concat(File.separator) , appsys_code);
				delFile(System.getProperty("maop.root").concat(messages.getMessage("systemServer.paramPackageImpPath"))
						.concat(File.separator) .concat(userId).concat(File.separator).concat(appsys_code).concat(".zip"));
				// String paramXml =
				// importFile(System.getProperty("maop.root")+messages.getMessage("systemServer.paramPackageImpPath")+File.separator+appsys_code+File.separator+appsys_code+".xml");
				ParamImport pi = new ParamImport();
				pi.doImportParams(System.getProperty("maop.root").concat(messages.getMessage("systemServer.paramPackageImpPath"))
						.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(File.separator)
						.concat(appsys_code).concat(".xml"));
				
			}else{
				unZip(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
						.concat(File.separator) .concat(userId) .concat(File.separator) , appsys_code);
				delFile(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
						.concat(File.separator) .concat(userId).concat(File.separator).concat(appsys_code).concat(".zip"));
				// String paramXml =
				// importFile(System.getProperty("maop.root")+messages.getMessage("systemServer.paramPackageImpPath")+File.separator+appsys_code+File.separator+appsys_code+".xml");
				ParamImport pi = new ParamImport();
				pi.doImportParams(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
						.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(File.separator)
						.concat(appsys_code).concat(".xml"));
				
			}
			
			remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.paramPath")).concat(messages.getMessage("path.linux")).concat(appsys_code).concat(".zip");
			ftpDelToolstar(remoteFilename);
		}

	}*/

	//String remoteFilename2 = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.paramPath")).concat(messages.getMessage("path.linux")).concat(appsys_code).concat(".zip");
	//ftpDelToolstar(remoteFilename2);
	
	tranItemS += ",";
	String[] tranItemSid = tranItemS.split(",");
	String host = messages.getMessage("importServer.ipAdress");
	Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
	String user = messages.getMessage("importServer.user");
	String password = messages.getMessage("importServer.password");
	ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
	ftpLogin.connect(host,port,user,password);
	ComponentFtp componentFtp = new ComponentFtp(ftpLogin);
	String[] doGetFilesNamelist = componentFtp.doGetFilesNamelist(messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.brpmPath")));
	String filePath = null;
	for(int i=0;i<tranItemSid.length;i++){
		for(int j=0;j<doGetFilesNamelist.length;j++){
			Map<String,String> map = new HashMap<String,String>();
				if(doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[0].substring(0, appsys_code.length()+1).equals(appsys_code.concat("_"))&&doGetFilesNamelist[j].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0].equals(tranItemSid[i])){

					ftpGetFileServer(doGetFilesNamelist[j], "brpm", userId);
					File brpmFile2 = null;
					if(ComUtil.isWindows){
						brpmFile2 = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath"))
								 .concat(File.separator).concat(userId).concat(File.separator).concat(doGetFilesNamelist[j]));
					}else{
						brpmFile2 = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux"))
								 .concat(File.separator).concat(userId).concat(File.separator).concat(doGetFilesNamelist[j]));
					}
					if (!brpmFile2.isDirectory()) {
						if(ComUtil.isWindows){
							unZip(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath"))
									 .concat(File.separator).concat(userId).concat(File.separator)
									 , doGetFilesNamelist[j]);
							delFile(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath"))
									 .concat(File.separator).concat(userId).concat(File.separator).concat(doGetFilesNamelist[j]));
							File brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath")).concat(File.separator).concat(userId));
							delAppZipFile(brpmZipPackageImpPath.getAbsolutePath(),doGetFilesNamelist[j].substring(0, doGetFilesNamelist[j].indexOf(".zip")));
						}else{
							unZip(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux"))
									 .concat(File.separator).concat(userId).concat(File.separator)
									 , doGetFilesNamelist[j]);
							delFile(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux"))
									 .concat(File.separator).concat(userId).concat(File.separator).concat(doGetFilesNamelist[j]));
							File brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux")).concat(File.separator).concat(userId));
							delAppZipFile(brpmZipPackageImpPath.getAbsolutePath(),doGetFilesNamelist[j].substring(0, doGetFilesNamelist[j].indexOf(".zip")));
						}
						//delAllFile(brpmZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(doGetFilesNamelist[j].substring(0, doGetFilesNamelist[j].indexOf(".zip"))));
						/*unZip(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath"))
								.concat(File.separator).concat(userId)
								.concat(File.separator).concat(appsys_code).concat(File.separator),
								appsys_code);*/
					}
			}
		}
	}
	
	if(ComUtil.isWindows){
		filePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath")).concat(File.separator) 
				.concat(userId);
	}else{
		filePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux")).concat(File.separator) 
				.concat(userId);
	}
	File[] arrFile = new File(filePath).listFiles();
	if (tranItemS.length() > 0 && !tranItemS.equals("")) {
		for (File ff : arrFile) {
			/*
			 * if(!ff.isDirectory()){
			 * delFile(ff.getAbsoluteFile().toString()); continue; }
			 */
			// jsonMapList = new ArrayList<Map<String,String>>();
			if(ff.isDirectory()){
				File fpath = new File(filePath.concat(File.separator).concat(
						ff.getAbsoluteFile().getName()));
				// File fpath = new File(filePath);
				File[] flist = printAllFile(fpath);
				String fName = null;
				String reqName = null;
				String reqId = null;
				boolean flag = false;
				String[] fRequstNameDiss = null;
				// brpm += ",";
				// String[] brpmId = brpm.split(",");
				
				if ((brpm != null) && (brpm.length() != 0)) {
					// for(int k = 0;k < brpmId.length;k++){
					for (File f : flist) {
						if (f.isFile()) {
							fName = f.getName();
							int iFlag = 0;
							boolean fileFlag = false;
							if (appsys_code != null && !"".equals(appsys_code)) {
								if (fName.startsWith(appsys_code)) {
									String fName2 = fName;
									reqName = fName2.substring(0,
											fName2.indexOf("@"));
									
									fName2 = fName2.substring(fName2
											.indexOf("@") + 1);
									
									for (int i = 0; i < fName.length(); i++) {
										
										if (String.valueOf(
												fName.charAt(i)).equals("@")) {
											
											iFlag++;
										}
									}
									if (iFlag == 1) {
										reqId = fName2.substring(0,
												fName2.indexOf(".xml"));
									}
									
									if (iFlag == 3 || iFlag == 5) {
										reqId = fName2.substring(0,
												fName2.indexOf("@"));
									}
									
									for (int j = 0; j < tranItemSid.length; j++) {
										if (reqId.equals(tranItemSid[j])) {
											fileFlag = true;
											break;
										}
									}
								}
							}
							if (iFlag == 5 && fileFlag == true
									&& brpm.indexOf("1") != -1) {
								String step = fName.substring(0,
										fName.lastIndexOf("@"));
								String componentName = step.substring(step
										.lastIndexOf("@") + 1);
								String componentId = fName.substring(
										fName.lastIndexOf("@") + 1,
										fName.lastIndexOf(".xml"));
								String componentIdDis = "";
								//String app_name = null;
								{
									if (componentIdDis.equals("")) {
										componentName = appsys_code2 + "_APP_CPNT_01";

										String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + componentName + "\" }}");
										if(componentsXml!=null){
											// method.putMethod(id,
											// "<component><name>"+name+"#"+id+"</name></component>","components",
											// IP, TOKEN);
											// break;
											// method.deleteMethod(BrpmConstants.KEYWORD_COMPONENTS,id);
											flag = true;
											Document docComponents = JDOMParserUtil
													.xmlParse(componentsXml);
											Element rootComponents = docComponents
													.getRootElement();
											String id = rootComponents.getChild("component").getChildText("id");
											
											StringBuffer putComponents = new StringBuffer();
											
	
											putComponents.append("<component><app_name>").append(appsys_code2).append("</app_name></component>");
											System.out.println(putComponents);
											method.putMethod(BrpmConstants.KEYWORD_COMPONENTS, id, putComponents.toString());
											try{
												StringBuffer comToEnv = new StringBuffer();
												comToEnv.append("<installed_component>")
												.append("<app_name>")
												.append(appsys_code2)
												.append("</app_name>")
												.append("<component_name>")
												.append(componentName)
												.append("</component_name>")
												.append("<environment_name>")
												.append(env)
												.append("</environment_name>")
												.append("</installed_component>");
												System.out.println(comToEnv);
												method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,comToEnv.toString() );										
											}catch(Exception e){
												e.printStackTrace();
											}
											// break;
											
										}
										
										
										if (flag == false) {// .concat(File.separator).concat(ff.getAbsoluteFile().getName())
											/*String componentXmlfile = importFile(fpath
												.toString()
												.concat(File.separator)
												.concat(fName));*/
											componentName = appsys_code2 + "_APP_CPNT_01";
											StringBuffer componentXml = new StringBuffer();
											componentXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
											.append("<component>")
											.append("<name>")
											.append(componentName)
											.append("</name>");
											
											
											/*Document doc = JDOMParserUtil
												.xmlParse(componentXmlfile);
										Element root = doc.getRootElement();
										List<Element> accounts = root
												.getChild("apps")
												.getChildren();

										for (Element account : accounts) {
											app_name = account
													.getChildText("name");

											String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + app_name + "\" }}");
													//.getMethod(BrpmConstants.KEYWORD_APPS);
											if(appsXml!=null){
												Document docApps = JDOMParserUtil
														.xmlParse(appsXml);
												Element rootApps = docApps
														.getRootElement();
												String Appname = rootApps.getChild("app")
															.getChildText("name");
												componentXml.append("<app_name>")
															.append(app_name)
															.append("</app_name>");
														
												
											}
												
											
										}*/
											componentXml.append("<app_name>")
											.append(appsys_code2)
											.append("</app_name>");
											componentXml.append("</component>");
											
											method.postMethod(
													BrpmConstants.KEYWORD_COMPONENTS,
													componentXml.toString());
											StringBuffer comToEnv = new StringBuffer();
											comToEnv.append("<installed_component>")
											.append("<app_name>")
											.append(appsys_code2)
											.append("</app_name>")
											.append("<component_name>")
											.append(componentName)
											.append("</component_name>")
											.append("<environment_name>")
											.append(env)
											.append("</environment_name>")
											.append("</installed_component>");
											method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );
											componentIdDis += componentId + ",";
										}
										flag = false;
									} else {
										String[] componentIds = componentIdDis
												.split(",");
										for (int i = 0; i < componentIds.length; i++) {
											if (componentIds[i]
													.equals(componentId)) {
												componentName = appsys_code2 + "_APP_CPNT_01";
												String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + componentName + "\" }}");
												if(componentsXml!=null){
													
													// method.putMethod(id,
													// "<component><name>"+name+"#"+id+"</name></component>","components",
													// IP, TOKEN);
													// break;
													// method.deleteMethod(BrpmConstants.KEYWORD_COMPONENTS,id);
													flag = true;
													
													Document docComponents = JDOMParserUtil
															.xmlParse(componentsXml);
													Element rootComponents = docComponents
															.getRootElement();
													String id = rootComponents.getChild("component").getChildText("id");
													
													StringBuffer putComponents = new StringBuffer();
													putComponents.append("<component><app_name>").append(appsys_code2).append("</app_name></component>");
													method.putMethod(BrpmConstants.KEYWORD_COMPONENTS, id, putComponents.toString());
													try{

														StringBuffer comToEnv = new StringBuffer();
														comToEnv.append("<installed_component>")
														.append("<app_name>")
														.append(appsys_code2)
														.append("</app_name>")
														.append("<component_name>")
														.append(componentName)
														.append("</component_name>")
														.append("<environment_name>")
														.append(env)
														.append("</environment_name>")
														.append("</installed_component>");
														method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );										
													}catch(Exception e){
														e.printStackTrace();
													}
													// break;
													
												}
												/*.getMethod(BrpmConstants.KEYWORD_COMPONENTS);
											Document docComponents = JDOMParserUtil
													.xmlParse(componentsXml);
											Element rootComponents = docComponents
													.getRootElement();
											List<Element> accountsComponents = rootComponents
													.getChildren();
											for (Element accountComponents : accountsComponents) {
												String id = accountComponents
														.getChildText("id");
												String name = accountComponents
														.getChildText("name");
												if (componentName
														.equals(name)) {
													// method.putMethod(id,
													// "<component><name>"+name+"#"+id+"</name></component>","components",
													// IP, TOKEN);
													// method.deleteMethod(id,"components",
													// IP, TOKEN);
													flag = true;
													// System.out.println("组件已存在");
													// break;
												}
											}*/
												if (flag == false) {
													/*String componentXmlfile = importFile(fpath
														.toString()
														.concat(File.separator)
														.concat(fName));*/
													StringBuffer componentXml = new StringBuffer();
													componentName = appsys_code2 + "_APP_CPNT_01";

													componentXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
													.append("<component>")
													.append("<name>")
													.append(componentName)
													.append("</name>");
													
													/*Document doc = JDOMParserUtil
														.xmlParse(componentXmlfile);
												Element root = doc
														.getRootElement();
												List<Element> accounts = root
														.getChild("apps")
														.getChildren();
												for (Element account : accounts) {
													app_name = account
															.getChildText("name");
													String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + app_name + "\" }}");
													if(appsXml!=null){
													componentXml.append("<app_name>")
														.append(app_name)
														.append("</app_name>");
												
													}
													
												}*/
													componentXml.append("<app_name>")
													.append(appsys_code2)
													.append("</app_name>");
													
													
													componentXml.append("</component>");
													
													method.postMethod(
															BrpmConstants.KEYWORD_COMPONENTS,
															componentXml.toString());
													StringBuffer comToEnv = new StringBuffer();
													comToEnv.append("<installed_component>")
													.append("<app_name>")
													.append(appsys_code2)
													.append("</app_name>")
													.append("<component_name>")
													.append(componentName)
													.append("</component_name>")
													.append("<environment_name>")
													.append(env)
													.append("</environment_name>")
													.append("</installed_component>");
													method.postMethod(BrpmConstants.KEYWORD_INSTALLED_COMPONENTS,  comToEnv.toString() );
													
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
					flag = false;
					String fNameDis = "";
					String requestName = null;
					String requestId = null;
					for (File f : flist) {
						if (f.isFile()) {
							fName = f.getName();
							int iFlag = 0;
							boolean fileFlag = false;
							if (appsys_code != null && !"".equals(appsys_code)) {
								if (fName.startsWith(appsys_code)) {
									String fName2 = fName;
									reqName = fName2.substring(0,
											fName2.indexOf("@"));
									fName2 = fName2.substring(fName2
											.indexOf("@") + 1);
									for (int i = 0; i < fName.length(); i++) {
										if (String.valueOf(
												fName.charAt(i)).equals("@")) {
											iFlag++;
										}
									}
									if (iFlag == 1) {
										reqId = fName2.substring(0,
												fName2.indexOf(".xml"));
									}
									if (iFlag == 3 || iFlag == 5) {
										reqId = fName2.substring(0,
												fName2.indexOf("@"));
									}
									for (int j = 0; j < tranItemSid.length; j++) {
										if (reqId.equals(tranItemSid[j])) {
											fileFlag = true;
											break;
										}
									}
								}
							}
							if (iFlag == 1 && fileFlag == true) {
								requestName = fName.substring(0,
										fName.lastIndexOf("@"));
								fNameDis += requestName + ",";
							}
							if (iFlag == 1 && fileFlag == true
									&& brpm.indexOf("3") != -1) {
								requestName = fName.substring(0,
										fName.lastIndexOf("@"));
								requestId = fName.substring(
										fName.lastIndexOf("@") + 1,
										fName.lastIndexOf(".xml"));
								{
									requestName = appsys_code2 + "_REQ_20140305_NSH";

									String requestsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET, "{ \"filters\": { \"name\":\"" + requestName + "\" }}");
									//.getMethod(BrpmConstants.KEYWORD_REQUSET);
									/*List<Element> accountsRequests = rootRequests
										.getChildren();
								for (Element accountRequests : accountsRequests) {
									String id = accountRequests
											.getChildText("id");
									String name = accountRequests
											.getChildText("name");
									if (requestName.equals(name)) {
										flag = true;
										method.deleteMethod(
												BrpmConstants.KEYWORD_REQUSET,
												id);
										// method.putMethod(id,
										// "<request><name>"+name+"_bak</name></request>","requests",
										// IP, TOKEN);
									}
									
									
								}*/
									if(requestsXml!=null){
										Document docRequests = JDOMParserUtil
												.xmlParse(requestsXml);
										Element rootRequests = docRequests
												.getRootElement();
										String id = rootRequests.getChild("request")
												.getChildText("id");
										//flag = true;
										method.deleteMethod(
												BrpmConstants.KEYWORD_REQUSET,
												id);
									}
									
									if (flag == false) {
										/*String requestXmlFile = importFile(fpath
											.toString()
											.concat(File.separator)
											.concat(fName));*/
										StringBuffer requestXml = new StringBuffer();
										requestName = appsys_code2 + "_REQ_20140305_NSH";
										requestXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
										.append("<request>")
										.append("<name>")
										.append(requestName)
										.append("</name>");
										
										String requestor_name = securityUtils
												.getUser().getUsername();
										String usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"login\":\"" + requestor_name + "\" }}");
										//.getMethod(BrpmConstants.KEYWORD_USER);
										if(usersXml!=null){
											Document docUsers = JDOMParserUtil
													.xmlParse(usersXml);
											Element rootUsers = docUsers
													.getRootElement();
											
											String id = rootUsers.getChild("user")
													.getChildText("id");
											
											
											requestXml.append("<deployment_coordinator_id>")
											.append(id)
											.append("</deployment_coordinator_id>")
											.append("<requestor_id>")
											.append(id)
											.append("</requestor_id>");
										}
										
										
										
										
										/*
										 * String environmentName=""; Document
										 * doc3 =
										 * JDOMParserUtil.xmlParse(requestXmlFile
										 * ); Element root3 =
										 * doc3.getRootElement();
										 * if(root3.getChild
										 * ("environment")!=null){
										 * environmentName =
										 * root3.getChild("environment"
										 * ).getChildText("name"); }
										 * 
										 * String environmentsXml =
										 * method.getMethod
										 * (BrpmConstants.KEYWORD_ENVIRONMENTS);
										 * Document docEnvironments =
										 * JDOMParserUtil
										 * .xmlParse(environmentsXml); Element
										 * rootEnvironments =
										 * docEnvironments.getRootElement();
										 * List<Element> accountsEnvironments =
										 * rootEnvironments.getChildren(); for
										 * (Element accountEnvironments :
										 * accountsEnvironments) { String id =
										 * accountEnvironments
										 * .getChildText("id"); String name =
										 * accountEnvironments
										 * .getChildText("name");
										 * 
										 * if(environmentName.equals(name)){
										 * requestXml +=
										 * "<environment_id>"+id+"</environment_id>"
										 * ; } }
										 */
										/*StringBuilder environment = new StringBuilder();
									if (port.equals("1")) {
										environment.append(appsys_code).append("_DEV_ENV");
									} else if (port.equals("2")) {
										environment.append(appsys_code).append("_QA_ENV");
									} else if (port.equals("3")) {
										environment.append(appsys_code).append("_PROD_ENV");
									}*/
										String environmentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS, "{ \"filters\": { \"name\":\"" + env + "\" }}");
										if(environmentsXml!=null){
											Document docEnvironments = JDOMParserUtil
													.xmlParse(environmentsXml);
											Element rootEnvironments = docEnvironments
													.getRootElement();
											
											String id = rootEnvironments.getChild("environment")
													.getChildText("id");
											
											requestXml.append("<environment_id>")
											.append(id)
											.append("</environment_id>");
											
										}
										
										
										
										// requestXml +=
										// "<environment_id>"+environment+"</environment_id>";
										
										/*Document doc4 = JDOMParserUtil
											.xmlParse(requestXmlFile);
									Element root4 = doc4.getRootElement();
									List<Element> accounts4 = root4
											.getChild("apps").getChildren();
									for (Element account4 : accounts4) {
										String name = account4
												.getChildText("name");*/
										
										String appsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + appsys_code2 + "\" }}");	
										if(appsXml!=null){
											Document docApps = JDOMParserUtil
													.xmlParse(appsXml);
											Element rootApps = docApps
													.getRootElement();
											String id = rootApps.getChild("app")
													.getChildText("id");	
											requestXml.append("<app_ids>")
											.append(id)
											.append("</app_ids>");
										}
										
										requestXml.append("</request>");
										method.postMethod(
												BrpmConstants.KEYWORD_REQUSET,
												requestXml.toString());
										
										//}
										
									}
									flag = false;
								}
								
								
								/*String requestXml = importFile(fpath.toString()
										.concat(File.separator)
										.concat(fName));
								Document descriptionDoc = JDOMParserUtil
										.xmlParse(requestXml);
								Element descriptionRoot = descriptionDoc
										.getRootElement();
								String description = descriptionRoot
										.getChildText("description");
								
								
								
								
								StringBuilder deleteReqSql = new StringBuilder();
								deleteReqSql.append("delete from dply_request_info where APPSYS_CODE ='")
								.append(appsys_code)
								.append("' and REQUEST_CODE = '")
								.append(requestName)
								.append("' ");
								getSession().createSQLQuery(deleteReqSql.toString())
								.executeUpdate();
								
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
								.append(requestName)//.append(requestIdSql)
								.append("', '")
								.append(requestName)
								.append("','")
								.append(env)
								.append("','0','1','")
								.append(description)
								.append("','")
								.append(securityUtils.getUser().getUsername())
								.append("')");
								getSession().createSQLQuery(insertReqSql.toString())
								.executeUpdate();*/
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
								if (appsys_code != null
										&& !"".equals(appsys_code)) {
									if (fName.startsWith(appsys_code)) {
										String fName2 = fName;
										reqName = fName2.substring(0,
												fName2.indexOf("@"));
										fName2 = fName2.substring(fName2
												.indexOf("@") + 1);
										for (int j = 0; j < fName.length(); j++) {
											if (String.valueOf(
													fName.charAt(j))
													.equals("@")) {
												iFlag++;
											}
										}
										if (iFlag == 1) {
											reqId = fName2.substring(0,
													fName2.indexOf(".xml"));
										}
										if (iFlag == 3 || iFlag == 5) {
											reqId = fName2.substring(0,
													fName2.indexOf("@"));
										}
										for (int j = 0; j < tranItemSid.length; j++) {
											if (reqId.equals(tranItemSid[j])) {
												fileFlag = true;
												break;
											}
										}
									}
								}
								if (iFlag == 3 && fileFlag == true
										&& brpm.indexOf("2") != -1) {
									String fName2 = fName.substring(0,
											fName.lastIndexOf(".xml"));
									fName2 = fName2.substring(0,
											fName2.lastIndexOf("@"));
									fName2 = fName2.substring(0,
											fName2.lastIndexOf("@"));
									requestName = fName2.substring(0,
											fName2.lastIndexOf("@"));
									requestId = fName2.substring(fName2
											.indexOf("@") + 1);
									
									if (fRequstNameDiss[i].equals(requestName)) {
										Map<String, String> map = new HashMap<String, String>();
										String stepXmlFile = importFile(fpath
												.toString()
												.concat(File.separator)
												.concat(fName));
										String position = "";
										Document doc = JDOMParserUtil
												.xmlParse(stepXmlFile);
										Element root = doc.getRootElement();
										position = root
												.getChildText("position");
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
							
							reqName = map.get("fName").substring(0, map.get("fName").indexOf("@"));
							if (reqName.equals(fRequstNameDiss[i])) {
								
								Map<String, String> map2 = new HashMap<String, String>();
								map2.put("position", map.get("position"));
								map2.put("fName", map.get("fName"));
								jsonMapList2.add(map2);
								
							}
						}
						for (int j = 0; j < jsonMapList2.size(); j++) {
							for (Map<String, String> map3 : jsonMapList2) {
								if (map3.get("position").equals(String.valueOf(j + 1))) {
									Map<String, String> map4 = new HashMap<String, String>();
									map4.put("position", map3.get("position"));
									map4.put("fName", map3.get("fName"));
									jsonMapList3.add(map4);
								}
							}
						}
						for (Map<String, String> map5 : jsonMapList3) {
							fName = map5.get("fName");
							int iFlag = 0;
							boolean fileFlag = false;
							if (appsys_code != null && !"".equals(appsys_code)) {
								if (fName.startsWith(appsys_code)) {
									String fName2 = fName;
									reqName = fName2.substring(0,
											fName2.indexOf("@"));
									fName2 = fName2.substring(fName2
											.indexOf("@") + 1);
									for (int j = 0; j < fName.length(); j++) {
										if (String.valueOf(
												fName.charAt(j)).equals("@")) {
											iFlag++;
										}
									}
									if (iFlag == 1) {
										reqId = fName2.substring(0,
												fName2.indexOf(".xml"));
									}
									if (iFlag == 3 || iFlag == 5) {
										reqId = fName2.substring(0,
												fName2.indexOf("@"));
									}
									for (int j = 0; j < tranItemSid.length; j++) {
										if (reqId.equals(tranItemSid[j])) {
											fileFlag = true;
											break;
										}
									}
								}
							}
							if (iFlag == 3 && fileFlag == true
									&& brpm.indexOf("2") != -1) {
								String fName2 = fName.substring(0,
										fName.lastIndexOf(".xml"));
								fName2 = fName2.substring(0,
										fName2.lastIndexOf("@"));
								String stepName = fName2.substring(fName2
										.lastIndexOf("@") + 1);
								fName2 = fName2.substring(0,
										fName2.lastIndexOf("@"));
								requestName = fName2.substring(0,
										fName2.lastIndexOf("@"));
								requestId = fName2.substring(fName2
										.indexOf("@") + 1);
								{

									//String stepsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_STEPS, "{ \"filters\": { \"name\":\"" + stepName + "\" }}");
									/*		.getMethod(BrpmConstants.KEYWORD_STEPS);
								Document docSteps = JDOMParserUtil
										.xmlParse(stepsXml);
								Element rootSteps = docSteps
										.getRootElement();
								List<Element> accountsSteps = rootSteps
										.getChildren();
								for (Element accountSteps : accountsSteps) {
									String id = accountSteps
											.getChildText("id");
									String name = accountSteps
											.getChildText("name");

									if (stepName.equals(name)) {
										// method.putMethod(id,
										// "<step><name>"+name+"_bak</name></step>","steps",
										// IP, TOKEN);
										method.deleteMethod(
												BrpmConstants.KEYWORD_STEPS,
												id);
										flag = true;
										// break;
									}
								}*/
									//if(stepsXml!=null){
										/*Document docSteps = JDOMParserUtil
											.xmlParse(stepsXml);
									Element rootSteps = docSteps
											.getRootElement();
									String id = rootSteps.getChild("step")
											.getChildText("id");
									method.deleteMethod(
											BrpmConstants.KEYWORD_STEPS,
											id);*/
										//flag = true;
									//}
									if (flag == false) {
										String stepXmlFile = importFile(fpath
												.toString()
												.concat(File.separator)
												.concat(fName));
										StringBuilder stepXml = new StringBuilder();
										stepXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
										.append("<step>")
										.append("<name>")
										.append(stepName)
										.append("</name>");
										requestName = appsys_code2 + "_REQ_20140305_NSH";

										String requestsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET, "{ \"filters\": { \"name\":\"" + requestName + "\" }}");
										/*		.getMethod(BrpmConstants.KEYWORD_REQUSET);
									Document docRequests = JDOMParserUtil
											.xmlParse(requestsXml);
									Element rootRequests = docRequests
											.getRootElement();
									List<Element> accountsRequests = rootRequests
											.getChildren();
									for (Element accountRequests : accountsRequests) {
										String id = accountRequests
												.getChildText("id");
										String name = accountRequests
												.getChildText("name");

										if (requestName.equals(name)) {
											stepXml.append("<request_id>").append(id).append("</request_id>");
										}
									}*/
										Document docRequests = JDOMParserUtil
												.xmlParse(requestsXml);
										Element rootRequests = docRequests
												.getRootElement();		
										stepXml.append("<request_id>").append(rootRequests.getChild("request").getChildText("id")).append("</request_id>");
										Document manualDoc = JDOMParserUtil
												.xmlParse(stepXmlFile);
										Element manualRoot = manualDoc
												.getRootElement();
										String manual = manualRoot
												.getChildText("manual");
										String description = "";
										stepXml.append("<manual>").append(manual).append("</manual>");
										if (manual.equals("false")) {
											Document scriptIdDoc = JDOMParserUtil
													.xmlParse(stepXmlFile);
											Element scriptIdRoot = scriptIdDoc
													.getRootElement();
											String script_id = scriptIdRoot
													.getChild("script")
													.getChildText("id");
											stepXml.append("<script_id>")
											.append(script_id)
											.append("</script_id>")
											.append("<script_type>BladelogicScript</script_type>");
											
											Document descriptionDoc = JDOMParserUtil
													.xmlParse(stepXmlFile);
											Element descriptionRoot = descriptionDoc
													.getRootElement();
											description = descriptionRoot
													.getChildText("description");
											
										}
										String userName = securityUtils
												.getUser().getUsername();
										String usersXml = method.getMethodByFilter(BrpmConstants.KEYWORD_USER, "{ \"filters\": { \"login\":\"" + userName + "\" }}");
										//.getMethod();
										if(usersXml!=null){
											Document docUsers = JDOMParserUtil
													.xmlParse(usersXml);
											Element rootUsers = docUsers
													.getRootElement();
											String id = rootUsers.getChild("user")
													.getChildText("id");
											stepXml.append("<owner_id>")
											.append(id)
											.append("</owner_id>");
											
										}
										
										Document doc2 = JDOMParserUtil
												.xmlParse(stepXmlFile);
										Element root2 = doc2.getRootElement();
										String owner_type = root2
												.getChildText("owner-type");
										stepXml.append("<owner_type>")
										.append(owner_type)
										.append("</owner_type>");
										
										String component_name = "";
										Document doc4 = JDOMParserUtil
												.xmlParse(stepXmlFile);
										Element root4 = doc4.getRootElement();
										if (root4.getChild("component") != null) {
											component_name = root4.getChild(
													"component").getChildText(
															"name");
											component_name = appsys_code2 + "_APP_CPNT_01";

											String componentsXml = method.getMethodByFilter(BrpmConstants.KEYWORD_COMPONENTS, "{ \"filters\": { \"name\":\"" + component_name + "\" }}");
											Document docComponents = JDOMParserUtil.xmlParse(componentsXml);
											Element rootComponents = docComponents.getRootElement();
											
											String id = rootComponents.getChild("component")
													.getChildText("id");
											/*String name = accountComponents
													.getChildText("name");*/
											//if (component_name.equals(name)) {
											stepXml.append("<component_id>")
											.append(id)
											.append("</component_id>")
											.append("<installed_component_id>")
											.append(id)
											.append("</installed_component_id>");
											//}
											
											
										}
										
										Document doc = JDOMParserUtil
												.xmlParse(stepXmlFile);
										Element root = doc.getRootElement();
										different_level_from_previous = root
												.getChildText("different-level-from-previous");
										stepXml.append("<different_level_from_previous>")
										.append(different_level_from_previous)
										.append("</different_level_from_previous>")
										.append("</step>");
										
										postStepXml = method.postMethod(
												BrpmConstants.KEYWORD_STEPS,
												stepXml.toString());
										
										if ((!description.equals(""))
												&& manual.equals("false")) {
											Document docStepDoc = JDOMParserUtil
													.xmlParse(postStepXml);
											Element StepRoot = docStepDoc
													.getRootElement();
											String id = StepRoot
													.getChildText("id");
											if(description.indexOf("#")!=-1){
												String jobPath2 = messages.getMessage("bsa.deployPath").concat(description.substring(0, description.indexOf("#")));
												
												
												String jobPath = messages.getMessage("bsa.deployPath").concat(appsys_code2).concat("/APP");
												String jobName = description
														.substring(description
																.indexOf("#") + 1);// ,description.indexOf("@")
												
												// String exportName =
												// description.substring(
												// description.indexOf("@")+1);
												// 用户登录
												loginClient = new LoginServiceClient(
														messages.getMessage("bsa.userName"),
														messages.getMessage("bsa.userPassword"),
														messages.getMessage("bsa.authenticationType"),
														null,
														System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
														messages.getMessage("bsa.truststoreFilePassword"));
												loginResponse = loginClient.loginUsingUserCredential();
												
												
												/*if(jobName.split("_")[2].equals("ALLFILES")){
												jobType = "DeployJob";
											}else {
												jobType = "NSHScriptJob";

											}*/
												
												CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
												ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
												
												executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
												String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
												
												executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{jobPath,jobName});
												String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
												
												if(!DeployJobDBkey.equals("void")){
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
														method.scriptArguId(id,	groupNameToDBKey,getRESTfulURI, jobName,jobType);
													}
												}
											}
											
											
										}
									}
									flag = false;
								}
							}
						}
					}
				}

			}
			File brpmZipPackageImpPath = null;
			if(ComUtil.isWindows){
				brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath")).concat(File.separator).concat(userId));
			}else{
				brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux")).concat(File.separator).concat(userId));
			}
			delAppZipFile(brpmZipPackageImpPath.getAbsolutePath(),ff.getAbsoluteFile().getName());
			delAllFile(brpmZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(ff.getAbsoluteFile().getName()));
			String remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.brpmPath")).concat(messages.getMessage("path.linux")).concat(ff.getAbsoluteFile().getName()).concat(".zip");
			//ftpDelToolstar(remoteFilename);

		}
	}
}
		
	}

	/**
	 * 
	 * 读取文件
	 * 
	 * @param path
	 *            String 文件夹路径

	 * 
	 * @return File[]
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
	 * @param String
	 *            path,String appsys_code
	 * 
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
					boolean flag = false;

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
	 * 
	 * 删除文件夹里面的所有文件
	 * 
	 * @param path String 文件夹路径

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
			temp = new File(path.concat(File.separator).concat(tempList[i]));
			if (temp.isDirectory()) {
				delAllFile(path.concat( File.separator).concat(tempList[i]) );// 先删除文件夹里面的文件
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
			temp = new File(path.concat(File.separator).concat(tempList[i]));
			if (temp.isFile() &&
				(temp.getAbsoluteFile().getName().indexOf(appSysCd.concat(CommonConst.FILE_SUFFIX_ZIP)) != -1
				|| temp.getAbsoluteFile().getName().indexOf(appSysCd.concat(CommonConst.FILE_SUFFIX_TAR)) != -1)) {
				temp.delete();
			}
		}
	}


	/**
	 * 
	 * 读取文件内容
	 * 
	 * @param String
	 *            path,String appsys_code
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public String importFile(String fpath) throws FileNotFoundException,
			IOException {
		Reader reader = new InputStreamReader(new FileInputStream(fpath),
				"utf-8");
		BufferedReader br = new BufferedReader(reader);
		String xmlLine = new String();
		StringBuilder xml = new StringBuilder();
		while ((xmlLine = br.readLine()) != null) {
			xml.append(xmlLine) ;
		}
		br.close();
		return xml.toString();
	}

	/**
	 * FTP获取文件
	 * 
	 * @param String
	 *            appsys_code,String bmc
	 */
	@Transactional
	public void ftpGetFileServer(String appsys_code, String bmc, String userId) {
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
			remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux"))
					.concat(messages.getMessage("importServer.bsaPath")).concat(messages.getMessage("path.linux"))
					.concat(appsys_code).concat(".tar");
			if(ComUtil.isWindows){
				localFilename = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar");
				zipPackagebsa = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.concat(File.separator).concat(userId).concat(File.separator));
			}else{
				localFilename = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar");
				zipPackagebsa = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.concat(File.separator).concat(userId).concat(File.separator));
			}
			if (!zipPackagebsa.exists()) {
				zipPackagebsa.mkdirs();
			}
		}
		if (bmc.equals("brpm")) {
			remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux"))
					.concat( messages.getMessage("importServer.brpmPath"))
					.concat(messages.getMessage("path.linux"))
					.concat(appsys_code);
			File zipPackage = null;
			if(ComUtil.isWindows){
				localFilename = System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath"))
						 .concat(File.separator).concat(userId)
						.concat(File.separator).concat(appsys_code) ;
				zipPackage = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmPackagePath"))
						.concat(File.separator).concat(userId).concat(File.separator));
			}else{
				localFilename = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux"))
						 .concat(File.separator).concat(userId)
						.concat(File.separator).concat(appsys_code) ;
				zipPackage = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmPackagePathForLinux"))
						.concat(File.separator).concat(userId).concat(File.separator));
			}
			if (!zipPackage.exists()) {
				zipPackage.mkdirs();
			}
		}
		if (bmc.equals("param")) {
			remoteFilename = messages.getMessage("importServer.path").concat(messages.getMessage("path.linux"))
					.concat(messages.getMessage("importServer.paramPath")).concat(messages.getMessage("path.linux"))
					.concat(appsys_code).concat(".zip") ;
			File zipPackage = null;
			if(ComUtil.isWindows){
				localFilename = System.getProperty("maop.root")
						.concat(messages.getMessage("systemServer.paramPackageImpPath")).concat(File.separator).concat(userId)
						.concat(File.separator).concat(appsys_code).concat(".zip");
				zipPackage = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.paramPackageImpPath"))
						.concat(File.separator) .concat(userId).concat(File.separator));
				
			}else{
				localFilename = System.getProperty("maop.root").concat(File.separator)
						.concat(messages.getMessage("systemServer.paramPackageImpPathForLinux")).concat(File.separator).concat(userId)
						.concat(File.separator).concat(appsys_code).concat(".zip");
				zipPackage = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
						.concat(File.separator) .concat(userId).concat(File.separator));
				
			}
			if (!zipPackage.exists()) {
				zipPackage.mkdirs();
			}
		}
		ftpFile.doGet(remoteFilename, localFilename, true, new StringBuffer());
		ftpLogin.disconnect();
	}

	/**
	 * 根据条件查找交易信息记录
	 * 
	 * @param appsys_code
	 * @throws ParseException
	 * @throws IOException
	 */
	@Transactional(readOnly = true)
	public Object getRequest(String appsys_code, String userId) throws ParseException,
			IOException, HttpHostConnectException,FtpCmpException {
		File brpmZipPackageImpPath = null;
		File bsaZipPackageImpPath = null;
		File paramPackagePath = null;
		if(ComUtil.isWindows){
			brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath")).concat(File.separator).concat(userId));
			bsaZipPackageImpPath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath")).concat(File.separator).concat(userId));
			paramPackagePath = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.paramPackagePath")).concat(File.separator).concat(userId));
			
		}else{
			brpmZipPackageImpPath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.brpmZipPackageImpPathForLinux")).concat(File.separator).concat(userId));
			bsaZipPackageImpPath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux")).concat(File.separator).concat(userId));
			paramPackagePath = new File(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.paramPackagePathForLinux")).concat(File.separator).concat(userId));
			
		}

		//DELETE FILE
		/*delAppZipFile(brpmZipPackageImpPath.getAbsolutePath(),appsys_code);
		delAllFile(brpmZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(appsys_code));*/
		
		delAppZipFile(bsaZipPackageImpPath.getAbsolutePath(),appsys_code);
		delAllFile(bsaZipPackageImpPath.getAbsolutePath().concat(File.separator).concat(appsys_code));
		
		delAppZipFile(paramPackagePath.getAbsolutePath(),appsys_code);
		delAllFile(paramPackagePath.getAbsolutePath().concat(File.separator).concat(appsys_code));

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
		
		String[] doGetFilesNamelist = componentFtp.doGetFilesNamelist(messages.getMessage("importServer.path").concat(messages.getMessage("path.linux")).concat( messages.getMessage("importServer.brpmPath")));
																		
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		
		//!!!ftpGetFileServer(appsys_code, "brpm", userId);

		//List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();

		//String brpmFilePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath")).concat(File.separator).concat(userId);
		//File[] brpmFile = new File(brpmFilePath).listFiles();
		/*!!!File brpmFile2 = new File(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath"))
				 .concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".zip"));*/
		//for (File bf : brpmFile) {
			//if (!bf.isDirectory()) {
		
		
			/*!!!if (!brpmFile2.isDirectory()) {
				unZip(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath"))
						 .concat(File.separator).concat(userId).concat(File.separator)
						 , appsys_code);
				delFile(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath"))
						 .concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".zip"));
				unZip(System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath")).concat(File.separator).concat(userId)
						.concat(File.separator).concat(appsys_code).concat(File.separator),
						appsys_code);
			}

			String filePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.brpmZipPackageImpPath"))
					.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code);
			File[] arrFile = new File(filePath).listFiles();
			*/
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
			/*String strDate = matter.format(date);
			String yyyyMM = strDate.substring(0, 6);*/
			String strDate = matter.format(date);
			String strDate1 = new Integer(new Integer(strDate)-1).toString();
			String strDate2 = new Integer(new Integer(strDate)-2).toString();
			String strDate3 = new Integer(new Integer(strDate)-3).toString();
			String strDate4 = new Integer(new Integer(strDate)-4).toString();
			
			String reqId = null;
			String reqName = null;
			
			//获取所有请求名称

			/*!!!for (File ff : arrFile) {
				if (!ff.isDirectory()) {
					Map<String,String> map = new HashMap<String,String>();
//					String reqDate = ff.getAbsoluteFile().getName().split(CommonConst.UNDERLINE)[2];
//					if(reqDate.equals(strDate)||reqDate.equals(strDate1)||reqDate.equals(strDate2)||reqDate.equals(strDate3)||reqDate.equals(strDate4)){
						map.put("reqId", ff.getAbsoluteFile().getName().split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0]);
						map.put("reqName", ff.getAbsoluteFile().getName().split(CommonConst.REPLACE_CHAR)[0]);
						jsonMapList.add(map);
//					}
					delFile(ff.getAbsoluteFile().toString());
					continue;
				}
			}*/
			
			for(int i=0;i<doGetFilesNamelist.length;i++){
				
				//if (!ff.isDirectory()) {
					Map<String,String> map = new HashMap<String,String>();
//					String reqDate = ff.getAbsoluteFile().getName().split(CommonConst.UNDERLINE)[2];
//					if(reqDate.equals(strDate)||reqDate.equals(strDate1)||reqDate.equals(strDate2)||reqDate.equals(strDate3)||reqDate.equals(strDate4)){
						if(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0].substring(0, appsys_code.length()+1).equals(appsys_code.concat("_"))){
							map.put("reqId", doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0]);
							map.put("reqName", doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0]);
							jsonMapList.add(map);
						}
						
//					}
					//delFile(ff.getAbsoluteFile().toString());
					//continue;
				//}

			}
			
			ftpLogin.disconnect();
			
			//按日期排序

			for (int i = 0; i < jsonMapList.size() - 1; i++) {
				for (int j = 0; j < jsonMapList.size() - i - 1; j++) {
					SimpleDateFormat dateFormat = new SimpleDateFormat(
							"yyyyMMdd");
					if(jsonMapList.get(j).get("reqName").indexOf("REQ_")!=-1
							||jsonMapList.get(j).get("reqName").indexOf("REQRST_")!=-1){
						/*int indexDate1 = jsonMapList.get(j).get("reqName")
								.indexOf("REQ_") + 4;
						int indexDate2 = jsonMapList.get(j + 1).get("reqName")
								.indexOf("REQ_") + 4;*/
						
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
						
						
						Date date1 = dateFormat.parse(jsonMapList.get(j)
								.get("reqName")
								.substring(indexDate1, indexDate1 + 8));
						Date date2 = dateFormat.parse(jsonMapList.get(j + 1)
								.get("reqName")
								.substring(indexDate2, indexDate2 + 8));

						if (date1.before(date2)) {

							Map<String, String> map = new HashMap<String, String>();
							Map<String, String> map2 = new HashMap<String, String>();

							reqId = jsonMapList.get(j).get("reqId");
							reqName = jsonMapList.get(j).get("reqName");

							map.put("reqId", reqId);
							map.put("reqName", reqName);

							String reqId2 = jsonMapList.get(j + 1).get("reqId");
							String reqName2 = jsonMapList.get(j + 1).get(
									"reqName");

							map2.put("reqId", reqId2);
							map2.put("reqName", reqName2);

							jsonMapList.set(j, map2);
							jsonMapList.set(j + 1, map);
						}

					}
					

				}
			}
				/*
				 * if(!ff.isDirectory()){
				 * delFile(ff.getAbsoluteFile().toString()); continue; }
				 */
		//}
		return jsonMapList;
	}

	/**
	 * 导入bsa
	 * 
	 * @param appsys_code
	 * @throws Exception
	 * @throws IOException
	 *             Throwable
	 */

	public void importBsa(String appsys_code,String userId) throws IOException,
			SocketTimeoutException, Exception, Throwable {

		String filePath = null;
		if(ComUtil.isWindows){
			filePath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath")).concat(File.separator)
					.concat(userId).concat(File.separator).concat(appsys_code);
			// String filePath = "C:\\export\\"+appsys_code;

			// unZip(System.getProperty("maop.root")+File.separator+messages.getMessage("systemServer.bsaZipPackageImpPath")+File.separator,appsys_code);

			ComUtil.doOsbtCmdExec("MoveImportService.java", "tar -xf ".concat(appsys_code).concat(".tar") , System.getProperty("maop.root")
					.concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
					.concat(File.separator).concat(userId).concat(File.separator) , new StringBuffer(), new StringBuffer());
			importFtp(
					appsys_code,
					System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
							.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar"),
							messages.getMessage("bsa.moveFilePath").concat(appsys_code).concat(".tar"));//messages.getMessage("bsa.fileServerIp")+
			delFile(System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
					.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar"));

		}else{
			filePath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux")).concat(File.separator)
					.concat(userId).concat(File.separator).concat(appsys_code);
			// String filePath = "C:\\export\\"+appsys_code;

			// unZip(System.getProperty("maop.root")+File.separator+messages.getMessage("systemServer.bsaZipPackageImpPath")+File.separator,appsys_code);

			ComUtil.doOsbtCmdExec("MoveImportService.java", "tar -xf ".concat(appsys_code).concat(".tar") , System.getProperty("maop.root").concat(File.separator)
					.concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
					.concat(File.separator).concat(userId).concat(File.separator) , new StringBuffer(), new StringBuffer());
			importFtp(
					appsys_code,
					System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
							.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar"),
							messages.getMessage("bsa.moveFilePath").concat(appsys_code).concat(".tar"));//messages.getMessage("bsa.fileServerIp")+
			delFile(System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
					.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(".tar"));

		}
		String scriptPathDis = "";
		String blpackagePathDis = "";
		File fpath = new File(filePath);
		File[] flist = printAllFile(fpath);
		String fServerFolder = null;
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
		

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code)});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code)});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code)});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code)});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code), "",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyCreatJob = (String) executeCommandByParamListResponse.get_return().getReturnValue();


		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code), "",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(".nsh"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		DBkeyCreatJob = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code), "",messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		DBkeyCreatJob = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code), "",messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		DBkeyCreatJob = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code) });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyUnzip = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code) });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[]{messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code),"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath"))});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.unzipJob").concat(appsys_code), "1", appsys_code });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkeyUnzip });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		String fJobFolder = null;
		for(File f : flist) {
			fServerFolder = f.getName();

			File fpath2 = new File(filePath .concat(File.separator).concat(fServerFolder));
			File[] flist2 = printAllFile(fpath2);
			fJobFolder = null;
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupExists", new String[]{messages.getMessage("bsa.deployPath").concat(appsys_code)});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String sys=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			 
			if(sys.equals("true")){  
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupExists",new String[]{messages.getMessage("bsa.deployPath").concat(appsys_code).concat(messages.getMessage("path.linux")).concat(fServerFolder)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String server=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			 
				if(server.equals("true")){
					 
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code)});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					String DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code)});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code),"0",messages.getMessage("bsa.deployPath").concat(appsys_code).concat(messages.getMessage("path.linux")).concat(fServerFolder)});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameJob").concat(appsys_code),"1",fServerFolder.concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString())});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
						
						
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code)  });
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code)});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code) ,"0",messages.getMessage("bsa.deployPath").concat(appsys_code).concat(messages.getMessage("path.linux")).concat(fServerFolder)});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.renameJobPath"),messages.getMessage("bsa.renameDepot").concat(appsys_code) ,"1",fServerFolder.concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString())});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

				 }
			 }
			
			
			for (File f2 : flist2) {
				fJobFolder = f2.getName();
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code)});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code) ,"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(appsys_code).concat(messages.getMessage("path.linux")).concat(fServerFolder).concat(messages.getMessage("path.linux")).concat(fJobFolder) });
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				

				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob").concat(appsys_code),"1",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("bsa.moveFilePath")).concat(appsys_code).concat(messages.getMessage("path.linux")).concat(fServerFolder).concat(messages.getMessage("path.linux")).concat(fJobFolder).concat(messages.getMessage("path.linux")).concat("mapping.xml")});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				

				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

				String mappingPath = null;
				if(ComUtil.isWindows){
					mappingPath = System.getProperty("maop.root").concat(messages.getMessage("systemServer.bsaZipPackageImpPath"))
							.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(File.separator)
							.concat(fServerFolder).concat(File.separator).concat(fJobFolder).concat(File.separator).concat("mapping.xml") ;
				}else{
					mappingPath = System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
							.concat(File.separator).concat(userId).concat(File.separator).concat(appsys_code).concat(File.separator)
							.concat(fServerFolder).concat(File.separator).concat(fJobFolder).concat(File.separator).concat("mapping.xml") ;
				}
				
				String mappingXml = importFile(mappingPath);

				String scriptPath = "";
				String scriptName = "";
				String blpackagePath = "";
				String blpackageName = "";

				String title = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
				if(mappingXml.indexOf("<mapping>")!=-1){
					mappingXml = mappingXml.substring(mappingXml
							.indexOf("<mapping>"));
					Document docMapping = JDOMParserUtil.xmlParse(title.concat(mappingXml));
					Element rootMapping = docMapping.getRootElement();
					List<Element> accountsMapping = rootMapping
							.getChildren("grouped_object_mapping");
					for (Element accountMapping : accountsMapping) {
						String mappingTyep = accountMapping.getChild(
								"source_object").getChildText("object_type");
						if (mappingTyep.equals("DEPOT_FILE_OBJECT")) {
							scriptPath = accountMapping
									.getChildText("containing_group");
						} else if (mappingTyep.equals("BLPACKAGE")) {
							blpackagePath = accountMapping
									.getChildText("containing_group");
						}
						int index1 = scriptPathDis.indexOf(scriptPath);
						if (index1 == -1) {
							scriptPathDis += scriptPath + ",";
						}
						int index2 = blpackagePathDis.indexOf(blpackagePath);
						if (index2 == -1) {
							blpackagePathDis += blpackagePath + ",";
						}
					}
				}
			}
		}
		String[] script = scriptPathDis.split(",");
		for (int i = 0; i < script.length; i++) {
			System.out.println(script[i]);
			Map scriptMap = new HashMap();
			scriptMap.put(script[i], "DEPOT_FILE_OBJECT");
			DepotDeployAuthorize scriptDepotDeployAuthorize = new DepotDeployAuthorize();
			if(!scriptMap.isEmpty()){
				scriptDepotDeployAuthorize.authorize(appsys_code, scriptMap);		
			}
		}

		String[] blpackage = blpackagePathDis.split(",");
		for (int i = 0; i < blpackage.length; i++) {
			System.out.println(blpackage[i]);
			Map blpackageMap = new HashMap();
			blpackageMap.put(blpackage[i], "BLPACKAGE");
			DepotDeployAuthorize blpackageDepotDeployAuthorize = new DepotDeployAuthorize();
			if(!blpackageMap.isEmpty()){
				blpackageDepotDeployAuthorize.authorize(appsys_code, blpackageMap);	
			}
		}

		JobDeployAuthorize jda = new JobDeployAuthorize();
		jda.authorize(appsys_code);
	}

	/**
	 * 
	 * 删除指定文件
	 * 
	 * @param path
	 *            String 文件夹路径

	 * 
	 * @return flag
	 */
	public void delFile(String path) {
		File file = new File(path);
		if (file.isFile() && file.exists()) {
			file.delete();
		}
	}

	/**
	 * 查询登录用户关联应用系统信息列表
	 * 
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUser(String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("select s.appsys_code as \"appsysCode\", ")
				.append(" s.appsys_name as \"appsysName\" ")
				.append(" from cmn_app_info s  ")
				.append(" where exists (select * from cmn_user_app u  ")
				.append(" where s.appsys_code = u.appsys_code ")
				.append(" and u.user_id = :userId)   and s.flag = '使用中' ")
				.append(" order by s.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * 
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object queryEnv(String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("select c.environment_code as \"env\", j.sub_item_name ||'('|| c.environment_code||')'  as \"envName\" from cmn_environment c, jeda_sub_item j ,cmn_app_info s where exists (select * from cmn_user_app u  where s.appsys_code = u.appsys_code and c.appsys_code = u.appsys_code  and u.user_id = :userId )  and c.environment_type = j.sub_item_value and j.item_id='EnvironmentType' and s.flag = '使用中'");
		return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();		
	}
	
	/**
	 * FTP在文件服务器备份文件
	 * 
	 * @param customer
	 * @throws IOException 
	 */
	@Transactional
	public  void ftpDelToolstar(String remoteFilename) throws FtpCmpException, IOException {
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
        ftpFile.deleteFile(remoteFilename);
		ftpLogin.disconnect();

	}
}

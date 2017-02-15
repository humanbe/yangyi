package com.nantian.dply.service;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Reader;
import java.net.SocketTimeoutException;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CountDownLatch;

import org.apache.axis2.AxisFault;
import org.apache.http.conn.HttpHostConnectException;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.CDATA;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import weblogic.utils.collections.ConcurrentHashSet;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmInvocationException;
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
public class MoveBsaImportService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveBsaImportService.class);

	public static Map<String, String> fields = new HashMap<String, String>();

	/** 功能ID */
	private static final String FUNCTION_ID = "MoveBsaImportService";

	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private SecurityUtils securityUtils;
	
	@Autowired
	private ThreadPoolTaskExecutor taskExcutor;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	private static final int buffer = 1;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	public MoveBsaImportService() {
		super();
	}
	
	
	/**
	 * 作者：李瑞浩
	 * 功能：ftp文件(.tar)到bsa服务器
	 * 时间：2014-12-09
	 * 
	 */
	private void importFtp( String path1, String path2) {
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
	 * 作者：李瑞浩
	 * 功能：删除bsa服务器上的文件
	 * 时间：2014-12-09
	 * 
	 */
	private void deleteBsaFileAndFolder(String appsys_code,String env) throws AxisFault,Exception {
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		StringBuilder deleteJobPath = new StringBuilder();
		deleteJobPath.append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString()});
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		StringBuilder deleteJobFilePath = new StringBuilder();
		deleteJobFilePath.append(messages.getMessage("bsa.fileServerIp"))
			.append(messages.getMessage("bsa.moveFilePath"))
			.append(messages.getMessage("path.linux"))
			.append(env)
			.append(messages.getMessage("path.linux"))
			.append(messages.getMessage("bsa.dplyPath"))
			.append(messages.getMessage("path.linux"));
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString(),"0",deleteJobFilePath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString(),"1",appsys_code});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),deleteJobPath.toString()});
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能：删除bsa服务器上的文件
	 * 时间：2014-12-09
	 * 
	 */
	@SuppressWarnings("unused")
	private void deleteBsaFile(String jobPath ,String filePath,String fileName) throws AxisFault,Exception {
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString()});
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString(),"0",messages.getMessage("bsa.fileServerIp").concat(filePath).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString(),"1",fileName});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),jobPath.toString()});
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能：新建迁移状态表信息(创建迁移记录)
	 * 时间：2014-12-09
	 * 
	 */
    @Transactional
	public void saveDplyExcuteStatusVo(String entryId, String status, String appsys_code,String operateSource,String env){
		DplyExcuteStatusVo vo = new DplyExcuteStatusVo();
		Date date = new Date();
		Timestamp tt =new Timestamp(date.getTime());
		vo.setEntryId(entryId);
		vo.setAppsysCode(appsys_code);
		vo.setUserId(securityUtils.getUser().getUsername());
		vo.setExcuteStartTime(tt);
		vo.setMoveStatus(status);
		vo.setOperateType("导入");
		vo.setOperateSource(operateSource);
		vo.setEnvironment(env);
		getSession().save(vo);
	}
	
   
    /**
	 * 作者：李瑞浩
	 * 功能：更新迁移状态表信息
	 * 时间：2014-12-09
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
	 * 作者：李瑞浩
	 * 功能：导入bsa
	 * 时间：2014-12-09
	 * 
	 */
	@Transactional
	public Object BsaImport(String uuid,String appsys_code, 
			String bsa, String userId,String env,String envExp) throws IOException,
			BrpmInvocationException, URISyntaxException,
			HttpHostConnectException, SocketTimeoutException, Throwable, Exception {
		String yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String message = null;
		if ((bsa != null) && (bsa.length() != 0)) {
			if (bsa.equals("1")) {
				deleteBsaFileAndFolder(appsys_code,env);
				//从10.1.32.1下载作业文件
				ftpGetFileServer(appsys_code, "bsa", userId, env, envExp);
				//从10.1.32.1下载作业参数文件
				
				ftpGetFileServer(appsys_code, "param", userId, env, envExp);
				
				
				String remoteFilename = null;
				String remoteFileBakname = null;
			
				 if(ComUtil.isWindows){
					 String path = new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.paramPackageImpPath"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator).append(appsys_code).toString() ;
					 deleteDir(path);
						
						 
					unZip(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.paramPackageImpPath"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.toString() 
							,appsys_code
						);
					//删除制定文件
					delFile(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.paramPackageImpPath"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.append(".zip")
								.toString()
							);
					ParamImport pi = new ParamImport();
					pi.doImportParams(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.paramPackageImpPath"))
								.append(File.separator)
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.append(File.separator)
								.append(appsys_code)
								.append(".xml")
								.toString()
							,appsys_code,env
									);
					
				}else{
					 String path = new StringBuilder().append(System.getProperty("maop.root"))
							 	.append(File.separator)
								.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator).append(appsys_code).toString() ;
					deleteDir(path);
					unZip(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(File.separator)
								.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.toString()
							,appsys_code
						 );
					delFile(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(File.separator)
								.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
								.append(File.separator) 
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.append(".zip")
								.toString()
							);
					ParamImport pi = new ParamImport();
					pi.doImportParams(
							new StringBuilder().append(System.getProperty("maop.root"))
								.append(File.separator)
								.append(messages.getMessage("systemServer.paramPackageImpPathForLinux"))
								.append(File.separator)
								.append(userId)
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.append(File.separator)
								.append(appsys_code)
								.append(".xml")
								.toString()
							,appsys_code,env
									);
					
				}
				
			    message=(String) JobImport(uuid,appsys_code,userId,env,envExp);
				
				deleteBsaFileAndFolder(appsys_code,env);
				remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
						.append(messages.getMessage("path.linux"))
						.append(envExp)
						.append(messages.getMessage("path.linux"))
						.append( messages.getMessage("importServer.bsaPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(".tar")
						.toString();
				remoteFileBakname = new StringBuilder().append(messages.getMessage("exportServer.path"))
						.append(messages.getMessage("path.linux"))
						.append(env)
						.append(messages.getMessage("path.linux"))
						.append(messages.getMessage("exportServer.bakPath"))
						.append(messages.getMessage("path.linux"))
						.append( messages.getMessage("exportServer.bsaPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(yyyyMMddHHmmss)
						.append(".tar")
						.toString();
				ftpDelToolstar(remoteFilename,remoteFileBakname,env);
				
				 remoteFilename = new StringBuilder().append(messages.getMessage("importServer.path"))
						.append(messages.getMessage("path.linux"))
						.append(envExp)
						.append(messages.getMessage("path.linux"))
						.append( messages.getMessage("importServer.paramPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(".zip")
						.toString();
				remoteFileBakname = new StringBuilder().append(messages.getMessage("exportServer.path"))
						.append(messages.getMessage("path.linux"))
						.append(env)
						.append(messages.getMessage("path.linux"))
						.append(messages.getMessage("exportServer.bakPath"))
						.append(messages.getMessage("path.linux"))
						.append( messages.getMessage("exportServer.paramPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(yyyyMMddHHmmss)
						.append(".zip")
						.toString();
				ftpDelToolstar(remoteFilename,remoteFileBakname,env);
				
			}
		}
		String info="";
		if(!("").equals(message) && null!=message){
			info=message;
		}
		return info;
	}

	
	private void deleteDir(String path) {
		 File outDir = new File(path);
		 if (outDir.exists()) {
			 for (File tmpFile : outDir.listFiles()) {
					tmpFile.delete();
				}
			 outDir.delete();
		 }
	}

	/**
	 * 作者：李瑞浩
	 * 功能：遍历指定路径下的文件夹集合
	 * 时间：2014-12-09
	 * 
	 */
	public File[] ergodicFile(File fpath) {
		File[] flist = fpath.listFiles();
		for (File f : flist) {
			if (f.isFile()) {
			} else if (f.isDirectory()) {
				ergodicFile(f);
			}
		}
		return flist;
	}

	/**
	 * 作者：李瑞浩
	 * 功能：遍历指定路径下的所有文件集合
	 * 时间：2014-12-09
	 * 
	 */
	public void findBlpackageFilesXml(File fpath,List<File> blpackageFileList) {
		File[] flist = fpath.listFiles();
		for (File f : flist) {
			if (f.isFile()) {
				if(f.getName().endsWith(".xml")){
					blpackageFileList.add(f);
				}
			} else if (f.isDirectory()) {
				findBlpackageFilesXml(f,blpackageFileList);
			}
		}
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能：解压zip文件包
	 * 时间：2014-12-09
	 * 
	 */
	public void unZip(String path, String appsys_code) throws IOException,Exception {
		String fName = null;
		File fpath = new File(path);
		//遍历指定路径下的文件文件集合
		File[] flist = ergodicFile(fpath);
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
					String path2 = new StringBuilder().append(path).append(fName).toString();
					
					ZipFile zipFile = null;
					try{
						zipFile = new ZipFile(path2, "GBK");
						Enumeration<?> entries = zipFile.getEntries();
						while (entries.hasMoreElements()) {
							byte buf[] = new byte[buffer];
							ZipEntry entry = (ZipEntry) entries.nextElement();
							String filename = entry.getName();
							index = filename.lastIndexOf(messages
									.getMessage("path.linux"));
							if (index > -1)
								filename = filename.substring(index + 1);
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
										.toString());
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
								if (null != fos){
									fos.close();
								}
								if (null != is){
									is.close();
								}
							}
							
						}
					}catch(Exception e){
						throw e;
					}finally{
						if (null != zipFile){
							zipFile.close();
						}
					}
					//删除指定文件
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
	 * 作者：李瑞浩
	 * 功能：删除文件夹里面的所有文件
	 * 时间：2014-12-09
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
	 * 作者:李瑞浩
	 * 功能:读取文件内容
	 * 时间：2014-12-09
	 * 
	 */
	public String readFileContent(String filePath) throws FileNotFoundException,
			IOException,Exception {
		
		String fileLine = new String();
		StringBuilder fileContent = new StringBuilder();
		Reader reader = null;
		BufferedReader br = null;
		try{
			reader = new InputStreamReader(new FileInputStream(filePath),
					"utf-8");
			br = new BufferedReader(reader);
			while ((fileLine = br.readLine()) != null) {
				fileContent.append(fileLine) ;
			}
		}catch(Exception e){
			throw e;
		}finally{
			if(null != br){
				br.close();
			}
		}
		return fileContent.toString();
	}

	
	/**
	 * 作者:李瑞浩
	 * 功能:FTP获取10.1.32.1服务器的文件
	 * 时间：2014-12-09
	 * 
	 */
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
	 * 作者：李瑞浩
	 * 功能:增加<!DOCTYPE mapping SYSTEM "file://bladelogic.com/dtds/Import-Mapping.dtd">标签
	 * 时间：2014-12-11
	 * 
	 */
	private String addMappingXmlLabel(String mappingXml){
		final String FIRST = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		final String SECOND = "<!DOCTYPE mapping SYSTEM \"file://bladelogic.com/dtds/Import-Mapping.dtd\">";

		if(mappingXml.indexOf("<mapping>")!=-1){
			mappingXml = FIRST.concat(SECOND).concat(mappingXml.substring(mappingXml.indexOf("<mapping>")));
		}
		return mappingXml;
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:增加<!DOCTYPE mapping SYSTEM "file://bladelogic.com/dtds/Import-Mapping.dtd">标签
	 * 时间：2014-12-11
	 * 
	 */
	private String addBlexportXmlLabel(String blexportXml){
		final String FIRST = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		final String SECOND = "<!DOCTYPE model_object_graph SYSTEM \"file://bladelogic.com/dtds/BLObjectGraph_v01.dtd\">";

		if(blexportXml.indexOf("<model_object_graph")!=-1){
			blexportXml = FIRST.concat(SECOND).concat(blexportXml.substring(blexportXml.indexOf("<model_object_graph")));
		}
		return blexportXml;
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:写文件
	 * 时间：2014-12-11
	 * 
	 */
	private void writeFile(String filePath,String fileName,String fileContent) throws Exception{
		File file = new File(filePath);
		PrintWriter out = null;
		try{
			if(!file.exists()){
				file.mkdirs();
			}
			out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new StringBuilder().append(filePath).append(File.separator).append(fileName).toString()),"utf-8"));
			out.println(fileContent);
		}catch(Exception e){
			throw e;
		}finally{
			if(null != out){
				out.flush();	
				out.close();
			}
		}
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:导入bsa
	 * 时间：2014-12-09
	 * 
	 */
	public Object JobImport(String uuid,String appsys_code,String userId,String env,String envExp) throws IOException,
			SocketTimeoutException, Exception, Throwable {
		String filePath = null;
		if(ComUtil.isWindows){
			String path = new StringBuilder().append(System.getProperty("maop.root"))
					.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
					.append(File.separator)
					.append(userId)
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
			deleteDir(path);
		 
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
					.append(File.separator)
					.append(userId)
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
			
			ComUtil.doOsbtCmdExec(
					FUNCTION_ID
					,"tar -xf ".concat(appsys_code).concat(".tar")
					,new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator) 
						.toString()
					,new StringBuffer()
					,new StringBuffer()
					);
			
			//删除指定文件
			delFile(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".tar")
						.toString()
					);
			
			
			

		}else{
			String path = new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
					.append(File.separator)
					.append(userId)
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
			deleteDir(path);
		 
		 
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
					.append(File.separator)
					.append(userId)
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
			ComUtil.doOsbtCmdExec(
					FUNCTION_ID
					,"tar -xf ".concat(appsys_code).concat(".tar")
					,new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.toString()
					,new StringBuffer()
					,new StringBuffer()
					);
			
			delFile(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.append(".tar")
						.toString()
					);

		}
		File fpath = new File(filePath);
		//遍历指定路径下的文件文件集合
		File[] flist = ergodicFile(fpath);
		StringBuffer message = new StringBuffer();
		int j=0;
		String[] fServerFolders = new String[flist.length];
		for(File f : flist) {
			String fServerFolder = f.getName();
			fServerFolders[j] = fServerFolder;
			
			File fpath2 = new File(filePath .concat(File.separator).concat(fServerFolder));
			//遍历指定路径下的文件文件集合
			File[] flist2 = ergodicFile(fpath2);
			for(int k=0;k<flist2.length;k++){
				String fJobFolder1 = flist2[k].getName();
				
				//构建mapping.xml文件的路径
				String mappingFilePath = getMappingFilePath(fServerFolder, fJobFolder1, env, appsys_code, userId);
				//构建mapping.xml文件的路径加文件名
				String mappingFilePathAddName = new StringBuilder().append(mappingFilePath).append(File.separator).append("mapping.xml").toString();
				
				//读取mapping.xml文件
				String mappingXml = readFileContent(mappingFilePathAddName);
						
				//mapping.xml文件的内容解析
				Document docMapping = editMappingFileGrop(mappingXml,env,envExp);
				
				//修改本地mapping.xml文件
				saveXML(docMapping, mappingFilePathAddName); 
				
				//再次读取mapping.xml文件
				String mappingXmlAddFirst = readFileContent(mappingFilePathAddName);
				
				//增加<!DOCTYPE mapping SYSTEM "file://bladelogic.com/dtds/Import-Mapping.dtd">标签
				String mappingXmlAddFirstAddSecond = addMappingXmlLabel(mappingXmlAddFirst);
				
				//再次写入到mapping.xml文件中
				writeFile( mappingFilePath, "mapping.xml", mappingXmlAddFirstAddSecond);
				
				
				
				//构建blexport.xml文件的路径
				String blexportFilePath = mappingFilePath;
				
				//构建blexport.xml文件的路径加文件名
				String blexportFilePathAddName = new StringBuilder().append(blexportFilePath).append(File.separator).append("blexport.xml").toString();
				
				//读取blexport.xml文件
				String blexportXml = readFileContent(blexportFilePathAddName);
				
				//blexport.xml文件的内容解析
				Document docBlexport = editBlexportFileGrop(blexportXml,env,envExp);
				
				//修改本地blexport.xml文件
				saveXML(docBlexport, blexportFilePathAddName); 
				
				//再次读取blexport.xml文件
				String blexportXmlAddFirst = readFileContent(blexportFilePathAddName);
				
				//增加<!DOCTYPE model_object_graph SYSTEM "file://bladelogic.com/dtds/BLObjectGraph_v01.dtd">标签
				String blexportXmlAddFirstAddSecond = addBlexportXmlLabel(blexportXmlAddFirst);
				
				//再次写入到blexport.xml文件中
				writeFile( blexportFilePath, "blexport.xml", blexportXmlAddFirstAddSecond);
				
				//allfiles文件
				String blpackagesXml = null;
				
				Document docBlpackages = null;
				if(fJobFolder1.indexOf("ALLFILES")!=-1){
					File allFilesPath = new File(blexportFilePath.concat(File.separator).concat("files"));
					if(allFilesPath.isDirectory()){
						
						List<File> blpackageFileList = new ArrayList<File>();
						findBlpackageFilesXml(allFilesPath,blpackageFileList);
						for (File file : blpackageFileList) {
							blpackagesXml = new String();
							blpackagesXml = readFileContent(file.getAbsolutePath());
							if(file.getAbsolutePath().endsWith("bldeploy.xml")){
								docBlpackages = editBlpackagesFileGrop( blpackagesXml, env, envExp);
								saveXML(docBlpackages, file.getAbsolutePath()); 
								blpackagesXml = readFileContent(file.getAbsolutePath());
								blpackagesXml = blpackagesXml.replaceAll("@@@@", "&#xA;");
							}else{
								docBlpackages = editBlpackagesNumFileGrop( blpackagesXml, env, envExp);
								saveXML(docBlpackages, file.getAbsolutePath()); 
								blpackagesXml = readFileContent(file.getAbsolutePath());
							}
							/*saveXML(docBlpackages, file.getAbsolutePath()); 
							blpackagesXml = readFileContent(file.getAbsolutePath());*/
							writeFile(file.getParentFile().getAbsolutePath(), file.getName(), blpackagesXml);
						}
					}else{
						//updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, ""+fJobFolder1+"下没有files目录");
						message.append(""+fJobFolder1+"下没有files目录").append(",");
					}
				}
			}
			j++;
		}
		if(null!=message.toString() && !"".equals(message.toString())){
			return message.append("请检查导入作业中是否存在关联脚本").toString();
		}
		
		
		if(ComUtil.isWindows){
			
			ComUtil.doOsbtCmdExec(
					FUNCTION_ID
					,"tar -cvf new".concat(appsys_code).concat(".tar ").concat(appsys_code)
					,new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator) 

						.toString()
					,new StringBuffer()
					,new StringBuffer()
					);
			
			importFtp(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append("new")
						.append(appsys_code)
						.append(".tar")
						.toString()
					,new StringBuilder().append(messages.getMessage("bsa.moveFilePath"))
						.append(messages.getMessage("path.linux"))
						.append(env)
						.append(messages.getMessage("path.linux"))
						.append(messages.getMessage("bsa.dplyPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(".tar")
						.toString()
					);
			
		}else{
			ComUtil.doOsbtCmdExec(
					FUNCTION_ID
					,"tar -cvf new".concat(appsys_code).concat(".tar ").concat(appsys_code)
					,new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.toString()
					,new StringBuffer()
					,new StringBuffer()
					);
			
			importFtp(
					new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
						.append(File.separator)
						.append(userId)
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append("new")
						.append(appsys_code)
						.append(".tar")
						.toString()
					,new StringBuilder().append(messages.getMessage("bsa.moveFilePath"))
						.append(messages.getMessage("path.linux"))
						.append(env)
						.append(messages.getMessage("path.linux"))
						.append(messages.getMessage("bsa.dplyPath"))
						.append(messages.getMessage("path.linux"))
						.append(appsys_code)
						.append(".tar")
						.toString()
					);
			
		}
		
		
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse loginResponse = null;
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
				,messages.getMessage("bsa.truststoreFilePassword")
				);
		loginResponse = loginClient.loginUsingUserCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		//删除旧的作业：解压缩和改名作业		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString()});
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString()});
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString()});
		//新建解压缩作业		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString(), "",messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(".nsh").toString(),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//新建改JOB目录名NSH作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString(), "",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.renameJob"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//新建改Depot目录名NSH作业
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString(), "",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.renameDepot"),messages.getMessage("bsa.ipAddress"),"2" });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//清除解压缩作业参数		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString() });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//设置解压缩作业参数1
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(env).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//设置解压缩作业参数2
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString(), "1", appsys_code });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		//获取解压缩作业DBKey
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyUnzip = (String) executeCommandByParamListResponse.get_return().getReturnValue();
		//依据DBKey执行解压缩作业		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkeyUnzip });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		int i=0;
		//String[] fServerFolders = new String[flist.length];
		CountDownLatch end = new CountDownLatch(flist.length);
//		ExecutorService pool = Executors.newFixedThreadPool(10);
		StringBuffer errorSb = new StringBuffer();
		for(File f : flist) {
			String fServerFolder = f.getName();
			fServerFolders[i] = fServerFolder;
			i++;
			File fpath2 = new File(filePath .concat(File.separator).concat(fServerFolder));
			
			//遍历指定路径下的文件文件集合
			File[] flist2 = ergodicFile(fpath2);
			//删除旧的Import导入作业
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(
					"NSHScriptJob"
					,"deleteJobByGroupAndName"
					,new String[] {
							messages.getMessage("bsa.moveJobPath")
							,new StringBuilder().append(messages.getMessage("bsa.importJob")).append(env)
								.append(appsys_code)
								.append(fServerFolder)
								.toString()
							}
					);
			//新建基于服务名的Import导入作业
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.importJob")).append(env).append(appsys_code).append(fServerFolder).toString(), "",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.importJob"),messages.getMessage("bsa.ipAddress"),"2" });
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			//查询BSA DEPLOY下是否存在系统目录			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupExists", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String sys=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			//存在系统目录
			if(sys.equals("true")){
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup","groupExists",new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(fServerFolder).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String server=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				//系统目录下存在循环的服务目录
				if(server.equals("true")){
					//修改备份服务目录名称为 BAKyyyymmddHHMMSS服务名
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					String DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(fServerFolder).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString(),"1",new StringBuilder().append(messages.getMessage("exportServer.bakPath")).append((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString()).append(fServerFolder).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
						
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString() ,"0",new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(fServerFolder).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString() ,"1",new StringBuilder().append(messages.getMessage("exportServer.bakPath")).append((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString()).append(fServerFolder).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				 }
			 }
			
			Runnable runner = new Executor(appsys_code, userId, fServerFolder, end, flist2, errorSb, env, envExp);
			taskExcutor.execute(runner);
		}

		//主线程等待所有子线程结束，即CountDownLatch为0
		end.await();
		if(errorSb.length() != 0) {
			updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, errorSb.toString());
		}
//		pool.shutdown();
		
		// 用户登录,重新获取session
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userName")
				,messages.getMessage("bsa.userPassword")
				,messages.getMessage("bsa.authenticationType")
				,null
				,new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("bsa.truststoreFile"))
					.toString()
				,messages.getMessage("bsa.truststoreFilePassword")
				);
		loginResponse = loginClient.loginUsingUserCredential();
		CLITunnelServiceClient cliTunnelServiceClientForDel = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		
		//删除导入创建的服务线程作业importWebSRB、importAppSRB
		for (String fServerFolder : fServerFolders) {
			cliTunnelServiceClientForDel.executeCommandByParamList(
					"NSHScriptJob"
					,"deleteJobByGroupAndName"
					,new String[] {
							messages.getMessage("bsa.moveJobPath")
							,new StringBuilder().append(messages.getMessage("bsa.importJob"))
							.append(env)
							.append(appsys_code)
							.append(fServerFolder)
							.toString()
					}
					);
		}
		//删除BSA上的解压缩作业unzipSRB
		executeCommandByParamListResponse = cliTunnelServiceClientForDel.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.unzipJob")).append(env).append(appsys_code).toString()});
		//删除BSA上的改JOB下目录名的NSH作业
		executeCommandByParamListResponse = cliTunnelServiceClientForDel.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameJob")).append(env).append(appsys_code).toString()});
		//删除BSA上的改DEPOT下目录的NSH作业
		executeCommandByParamListResponse = cliTunnelServiceClientForDel.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.renameDepot")).append(env).append(appsys_code).toString()});
		
		//添加BSA作业权限
		JobDeployAuthorize jda = new JobDeployAuthorize();
		jda.authorize(appsys_code,env);
		
		return errorSb.toString();
		
	}
	
	
	/**
	 * 作者：李瑞浩
	 * 功能:构建mapping.xml文件的路径
	 * 时间：2014-12-09
	 * 
	 */
	private String getMappingFilePath(String fServerFolder,String fJobFolder1,String env,String appsys_code,String userId){
		StringBuilder mappingPath = new StringBuilder();
		if(ComUtil.isWindows){
			mappingPath.append(System.getProperty("maop.root"))
				.append(messages.getMessage("systemServer.bsaZipPackageImpPath"))
				.append(File.separator).append(userId).append(File.separator).append(env).append(File.separator).append(appsys_code).append(File.separator)
				.append(fServerFolder).append(File.separator).append(fJobFolder1) ;
		}else{
			mappingPath.append(System.getProperty("maop.root"))
				.append(File.separator).append(messages.getMessage("systemServer.bsaZipPackageImpPathForLinux"))
				.append(File.separator).append(userId).append(File.separator).append(env).append(File.separator).append(appsys_code).append(File.separator)
				.append(fServerFolder).append(File.separator).append(fJobFolder1) ;
		}
		return mappingPath.toString();
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:修改blpackages目录下的（数字）.xml文件的参数
	 * 时间：2014-12-09
	 * 
	 */
	private Document editBlpackagesNumFileGrop(String blpackagesNumXml,String env,String envExp) throws Exception{
		Document docBlpackages = null;
		docBlpackages = JDOMParserUtil.xmlParse(blpackagesNumXml);
		Element rootBlpackages = docBlpackages.getRootElement();
		String accountsBlpackages = rootBlpackages.getAttributeValue("Path");
		
		String[] property = accountsBlpackages.split(CommonConst.DOT);
		if(property[1].indexOf("ATTR_")!=-1){
			String[] propertyDivide = property[1].split(CommonConst.UNDERLINE);
			String newProperty = editBlexportXmlLikeProperty(propertyDivide, env, envExp);
			property[1] = newProperty;
			newProperty = property[0];
			for(int i=1;i<property.length;i++){
				newProperty += CommonConst.DOT_UNESCAPE + property[i];
			}
			docBlpackages.getRootElement().getAttribute("Path").setValue(newProperty);
		}
		return docBlpackages;
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:修改blpackages目录下的bldeploy.xml文件的参数
	 * 时间：2014-12-09
	 * 
	 */
	private Document editBlpackagesFileGrop(String blpackagesNumXml,String env,String envExp) throws Exception{
		Document docBlpackages = null;
		docBlpackages = JDOMParserUtil.xmlParse(blpackagesNumXml.replaceAll("&#xA;", "@@@@"));
		Element rootBlpackages = docBlpackages.getRootElement();
		
		List<Element> accountsBlpackagesDepot = null;
		String accountBlpackages = null;
		accountsBlpackagesDepot = rootBlpackages.getChildren("DEPOTFILE");
		if(accountsBlpackagesDepot != null){
			int k=0;
			for (Element accountBlpackagesDepot : accountsBlpackagesDepot) {
				accountBlpackages = accountBlpackagesDepot.getAttributeValue("Path");
				String[] property = accountBlpackages.split(CommonConst.DOT);
				if(property[1].indexOf("ATTR_")!=-1){
					String[] propertyDivide = property[1].split(CommonConst.UNDERLINE);
					String newProperty = editBlexportXmlLikeProperty(propertyDivide, env, envExp);
					property[1] = newProperty;
					newProperty = property[0];
					for(int i=1;i<property.length;i++){
						newProperty += CommonConst.DOT_UNESCAPE + property[i];
					}
					docBlpackages.getRootElement().getChildren("DEPOTFILE").get(k).getAttribute("Path").setValue(newProperty);
				}
				k++;
			}
		}
		
		List<Element> accountsBlpackagesCmd = null;
		accountsBlpackagesCmd = rootBlpackages.getChildren("EXTERNALCMD");
		if(accountsBlpackagesCmd != null){
			int k=0;
			String newProperty = null;
			for (Element accountBlpackagesCmd : accountsBlpackagesCmd) {
				accountBlpackages = accountBlpackagesCmd.getChildTextNormalize("Cmd");//.setContent(new CDATA())
				String[] property = accountBlpackages.split(CommonConst.DOT);
				for(int i=0;i<property.length;i++){
					if(property[i].indexOf("ATTR_")!=-1){
						String[] propertyDivide = property[i].split(CommonConst.UNDERLINE);
						newProperty = editBlexportXmlLikeProperty(propertyDivide, env, envExp);
						property[i] = newProperty;
						newProperty = property[0];
						for(int j=1;j<property.length;j++){
							newProperty += CommonConst.DOT_UNESCAPE + property[j];
						}
					}
				}
				docBlpackages.getRootElement().getChildren("EXTERNALCMD").get(k).getChild("Cmd").setText(newProperty);
				k++;
			}	
		}
		return docBlpackages;
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:修改mapping.xml文件的参数
	 * 时间：2014-12-09
	 * 
	 */
	private Document editBlexportFileGrop(String blexportXml,String env,String envExp) throws Exception{
		String title = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		Document docBlexport = null;
		String field = null;
		String[] property = null;
		String[] propertyDivide = null;

		List<Element> accountsBlexport = null;
		List<Element> accountsField = null;
		
		String newProperty = null;
		final String ATTR_HEAD = "";
		final String ATTR_FOOT = "";

		if(blexportXml.indexOf("<model_object_graph")!=-1){
			blexportXml = blexportXml.substring(blexportXml.indexOf("<model_object_graph"));
			docBlexport = JDOMParserUtil.xmlParse(title.concat(blexportXml));
			Element rootBlexport = docBlexport.getRootElement();
			accountsBlexport = rootBlexport.getChild("object_list").getChildren("object_info");
			int k=0;
			int j=0;
			for (Element accountBlexport : accountsBlexport) {
				accountsField = accountBlexport.getChild("object").getChild("field_list").getChildren("field");
				j=0;
				for (Element accountField : accountsField) {
					field = accountField.getText();
					if(field!=null&&field.indexOf("ATTR_")!=-1){
						
						if(field.indexOf(CommonConst.DOT_UNESCAPE)==-1){
							propertyDivide = field.split(CommonConst.UNDERLINE);
							newProperty = new String();

							newProperty = ATTR_HEAD.concat(editBlexportXmlLikeProperty(propertyDivide, env, envExp)).concat(ATTR_FOOT);
							docBlexport.getRootElement().getChild("object_list").getChildren("object_info").get(k).getChild("object").getChild("field_list").getChildren("field").get(j).setContent(new CDATA(newProperty));	
							
						}else{
							property = field.split(CommonConst.DOT);
							if(property[1].indexOf("ATTR_")!=-1){
								propertyDivide = property[1].split(CommonConst.UNDERLINE);
								newProperty = new String();

								newProperty = ATTR_HEAD.concat(property[0]).concat(CommonConst.DOT_UNESCAPE)
										.concat(editBlexportXmlLikeProperty(propertyDivide, env, envExp))
										.concat(CommonConst.DOT_UNESCAPE).concat(property[2]).concat(ATTR_FOOT);
								docBlexport.getRootElement().getChild("object_list").getChildren("object_info").get(k).getChild("object").getChild("field_list").getChildren("field").get(j).setContent(new CDATA(newProperty));	
							}
						}				
					}
					j++;
				}
				k++;
			}

		}
		return docBlexport;

	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:blexport.xml文件参数链接构造
	 * 时间：2014-12-09
	 * 
	 */
	private String editBlexportXmlLikeProperty(String[] propertyDivide,String env,String envExp) throws Exception{
		String newProperty = new String();
		if(propertyDivide[1].equals(envExp)){
			propertyDivide[1]=env;
			for(int i=0;i<propertyDivide.length;i++){
				if(i == 0){
					newProperty += propertyDivide[i];
				}else{
					newProperty += CommonConst.UNDERLINE + propertyDivide[i];
				}
			}
		}else{
			newProperty += propertyDivide[0] + CommonConst.UNDERLINE + env;
			for(int i=1;i<propertyDivide.length;i++){
				newProperty += CommonConst.UNDERLINE + propertyDivide[i];
			}
		}
		return newProperty;
	}
	
	/**
	 * 作者：李瑞浩	 * 功能:修改mapping.xml文件的
	 * 时间：2014-12-09
	 * 
	 */
	private Document editMappingFileGrop(String mappingXml,String env,String envExp) throws Exception{
		String title = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		String containingGroup = null;
		String[] containingGroups = null;
		String newContainingGroup = null;
		String propertySetClass = null;
		String sourceProperty = null;
		String targetProperty = null;
		String[] sourcePropertys = null;
		String[] targetPropertys = null;
		String newSourceProperty = null;
		String newTargetProperty = null;

		Document docMapping = null;
		if(mappingXml.indexOf("<mapping>")!=-1){
			mappingXml = mappingXml.substring(mappingXml.indexOf("<mapping>"));
			docMapping = JDOMParserUtil.xmlParse(title.concat(mappingXml));
			Element rootMapping = docMapping.getRootElement();
			//修改mapping.xml文件路径
			List<Element> accountsMapping = rootMapping.getChildren("grouped_object_mapping");
			int k=0;
			for (Element accountMapping : accountsMapping) {
				containingGroup = accountMapping.getChildText("containing_group");
				if(containingGroup!=null){
					newContainingGroup = new String();
					containingGroups = containingGroup.split(CommonConst.SLASH);
					if(containingGroups[2].equals(envExp)){
						containingGroups[2]=env;
						for(int i=1;i<containingGroups.length;i++){
							newContainingGroup += CommonConst.SLASH + containingGroups[i];
						}
					}else{
						newContainingGroup += CommonConst.SLASH + containingGroups[1] + CommonConst.SLASH + env;
						for(int i=2;i<containingGroups.length;i++){
							newContainingGroup += CommonConst.SLASH + containingGroups[i];
						}
					}
					docMapping.getRootElement().getChildren("grouped_object_mapping").get(k).getChild("containing_group").setText(newContainingGroup);
					k++;
				}
			}
			//修改mapping.xml属性值
			accountsMapping = rootMapping.getChildren("property_mapping");
			k=0;
			for (Element accountMapping : accountsMapping) {
				propertySetClass = accountMapping.getChildText("property_set_class");
				if(propertySetClass!=null&&propertySetClass.equals("Server")){
					
					sourceProperty = accountMapping.getChildText("source_property");
					if(sourceProperty!=null){
						newSourceProperty = new String();
						sourcePropertys = sourceProperty.split(CommonConst.UNDERLINE);
						if(sourcePropertys[1].equals(envExp)){
							sourcePropertys[1]=env;
							for(int i=0;i<sourcePropertys.length;i++){
								if(i == 0){
									newSourceProperty += sourcePropertys[i];
								}else{
									newSourceProperty += CommonConst.UNDERLINE + sourcePropertys[i];
								}
							}
						}else{
							newSourceProperty += sourcePropertys[0] + CommonConst.UNDERLINE + env;
							for(int i=1;i<sourcePropertys.length;i++){
								newSourceProperty += CommonConst.UNDERLINE + sourcePropertys[i];
							}
						}
					}
					
					targetProperty = accountMapping.getChildText("target_property");
					if(targetProperty!=null){
						newTargetProperty = new String();
						targetPropertys = targetProperty.split(CommonConst.UNDERLINE);
						if(targetPropertys[1].equals(envExp)){
							targetPropertys[1]=env;
							for(int i=0;i<targetPropertys.length;i++){
								if(i == 0){
									newTargetProperty += targetPropertys[i];
								}else{
									newTargetProperty += CommonConst.UNDERLINE + targetPropertys[i];
								}
							}
						}else{
							newTargetProperty += targetPropertys[0] + CommonConst.UNDERLINE + env;
							for(int i=1;i<sourcePropertys.length;i++){
								newTargetProperty += CommonConst.UNDERLINE + targetPropertys[i];
							}
						}
					}
					docMapping.getRootElement().getChildren("property_mapping").get(k).getChild("source_property").setText(newSourceProperty);
					docMapping.getRootElement().getChildren("property_mapping").get(k).getChild("target_property").setText(newTargetProperty);
					break;
				}
				k++;

			}
		}
		return docMapping;
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能:启动动态创建的import作业
	 * 时间：2014-12-09
	 * 
	 */
	private void runImportJob(String env,String appsys_code,String fServerFolder,String fJobFolder1,String sessionId)throws Exception{
		StringBuilder importJobSB = new StringBuilder();
		StringBuilder resourceJobPath = new StringBuilder();
		StringBuilder resourceJobXml = new StringBuilder();
		ExecuteCommandByParamListResponse executeCommandByParamListResponse;
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(sessionId, null);
		importJobSB.append(messages.getMessage("bsa.importJob"))
			.append(env)
			.append(appsys_code)
			.append(fServerFolder);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName", new String[] {messages.getMessage("bsa.moveJobPath"),importJobSB.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey = (String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),importJobSB.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		resourceJobPath.append(messages.getMessage("bsa.fileServerIp"))
			.append(messages.getMessage("bsa.moveFilePath"))
			.append(messages.getMessage("path.linux"))
			.append(env)
			.append(messages.getMessage("path.linux"))
			.append(messages.getMessage("bsa.dplyPath"))
			.append(messages.getMessage("path.linux"))
			.append(appsys_code)
			.append(messages.getMessage("path.linux"))
			.append(fServerFolder)
			.append(messages.getMessage("path.linux"))
			.append(fJobFolder1);
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),importJobSB.toString() ,"0", resourceJobPath.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);

		resourceJobXml.append(messages.getMessage("bsa.fileServerIp"))
			.append(messages.getMessage("bsa.moveFilePath"))
			.append(messages.getMessage("path.linux"))
			.append(env)
			.append(messages.getMessage("path.linux"))
			.append(messages.getMessage("bsa.dplyPath"))
			.append(messages.getMessage("path.linux"))
			.append(appsys_code)
			.append(messages.getMessage("path.linux"))
			.append(fServerFolder)
			.append(messages.getMessage("path.linux"))
			.append(fJobFolder1)
			.append(messages.getMessage("path.linux"))
			.append("mapping.xml");
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {messages.getMessage("bsa.moveJobPath"),importJobSB.toString() ,"1", resourceJobXml.toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] { DBkey });
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}
	
	
	/**
	 * 作者：李瑞浩
	 * 功能:分别调用BSA服务器的'Depot/Deploy'目录授权功能
	 * 时间：2014-12-09
	 * 
	 */
	private void bsaAuthorize(String mappingXml,String appsys_code,String env)throws Exception{
		String scriptPath = "";
		String nshscriptPath = "";
		String blpackagePath = "";
		
		Set<String> scriptSet = new ConcurrentHashSet();
		Set<String> blpackageSet = new ConcurrentHashSet();
		Set<String> nshscripSet = new ConcurrentHashSet();

		String title = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		if(mappingXml.indexOf("<mapping>")!=-1){
			mappingXml = mappingXml.substring(mappingXml.indexOf("<mapping>"));
			Document docMapping = JDOMParserUtil.xmlParse(title.concat(mappingXml));
			Element rootMapping = docMapping.getRootElement();
			List<Element> accountsMapping = rootMapping
					.getChildren("grouped_object_mapping");
			DepotDeployAuthorize scriptDepotDeployAuthorize = new DepotDeployAuthorize();
			for (Element accountMapping : accountsMapping) {
				String mappingTyep = accountMapping.getChild("source_object").getChildText("object_type");
				if (mappingTyep.equals("DEPOT_FILE_OBJECT")) {
					scriptPath = accountMapping.getChildText("containing_group");
					if(scriptSet.contains(scriptPath)) continue;
					scriptSet.add(scriptPath);
					Map<String, String> scriptMap = new HashMap<String, String>();
					scriptMap.put(scriptPath, "DEPOT_FILE_OBJECT");
					scriptDepotDeployAuthorize.authorize(appsys_code, scriptMap, env);
				} else if (mappingTyep.equals("BLPACKAGE")) {
					blpackagePath = accountMapping.getChildText("containing_group");
					if(blpackageSet.contains(blpackagePath)) continue;
					blpackageSet.add(blpackagePath);
					Map<String, String> nshscriptMap = new HashMap<String, String>();
					nshscriptMap.put(blpackagePath, "BLPACKAGE");
					scriptDepotDeployAuthorize.authorize(appsys_code, nshscriptMap,env);
				} else if (mappingTyep.equals("NSHSCRIPT")) {
					nshscriptPath = accountMapping.getChildText("containing_group");
					if(nshscripSet.contains(nshscriptPath)) continue;
					nshscripSet.add(nshscriptPath);
					Map<String, String> nshscriptMap = new HashMap<String, String>();
					nshscriptMap.put(nshscriptPath, "NSHSCRIPT");
					scriptDepotDeployAuthorize.authorize(appsys_code, nshscriptMap,env);
				}
				
			}
		}
	}
	
	
	/**
	 * 作者：李瑞浩
	 * 功能:导入bsa作业执行
	 * 时间：2014-12-09
	 * 
	 */
	@SuppressWarnings("unchecked")
	private void bsaOperator(
			String appsys_code,String userId,String fServerFolder,String sessionId,File f2,String env,String envExp)
			throws FileNotFoundException, IOException, AxisFault,Exception {

		String fJobFolder1 = f2.getName();
		runImportJob( env, appsys_code, fServerFolder, fJobFolder1, sessionId);
		
		//构建mapping.xml文件的路径		String mappingFilePath = getMappingFilePath(fServerFolder, fJobFolder1, env, appsys_code, userId);
		
		//构建mapping.xml文件的路径加文件名		String mappingFilePathAddName = new StringBuilder().append(mappingFilePath).append(File.separator).append("mapping.xml").toString();
		
		
		//读取mapping.xml文件
		String mappingXml = readFileContent(mappingFilePathAddName);
				
		//分别调用BSA服务器的'Depot/Deploy'目录授权功能
		bsaAuthorize(mappingXml,appsys_code,env);
		
		//mapping.xml文件的内容解析
		//Document docMapping = editMappingFileGrop(mappingFilePath,mappingXml,env,envExp);
		
		//修改本地mapping.xml文件
		//saveXML(docMapping, mappingFilePath); 
		
		//备份bsa文件服务器上的mapping.xml文件
		/*String mappingXmlFilePath = new StringBuilder()
				.append(messages.getMessage("bsa.moveFilePath"))
				.append(messages.getMessage("path.linux"))
				.append(env)
				.append(messages.getMessage("path.linux"))
				.append(messages.getMessage("bsa.dplyPath"))
				.append(messages.getMessage("path.linux"))
				.append(appsys_code)
				.append(messages.getMessage("path.linux"))
				.append(fServerFolder)
				.append(messages.getMessage("path.linux"))
				.append(fJobFolder1)
				.append(messages.getMessage("path.linux"))
				.toString();
		String mappingXmlFileName = "mapping.xml";
		String moveFileJobPath = new StringBuilder()
			.append(messages.getMessage("bsa.movefileJob"))
			.append(env)
			.append(appsys_code)
			.toString();
		deleteBsaFile( moveFileJobPath, mappingXmlFilePath, mappingXmlFileName);*/
		
		//ftp mapping.xml本地文件到bsa文件服务器
		//importFtp(mappingFilePath,new StringBuilder(mappingXmlFilePath).append(mappingXmlFileName).toString());
		
		//启动动态创建的import作业
		//runImportJob( env, appsys_code, fServerFolder, fJobFolder1, sessionId);
		
		
	
	}

	private void saveXML(Document document, String filePath) throws Exception {
        // 将doc对象输出到文件
		FileWriter writer = null;
        try {
            // 创建xml文件输出流            XMLOutputter xmlopt = new XMLOutputter();
            // 创建文件输出流            writer = new FileWriter(filePath);
            // 指定文档格式
            Format fm = Format.getPrettyFormat();
            //fm.setEncoding("GB2312");
            xmlopt.setFormat(fm);
            // 将doc写入到指定的文件中            xmlopt.output(document, writer);
        }catch(Exception e){
			throw e;
		}finally{
			if (null != writer){
				writer.close();
			}
		}

    }

	
	/**
	 * 作者：李瑞浩
	 * 功能:删除指定文件
	 * 时间：2014-12-09
	 * 
	 */
	private void delFile(String path) {
		File file = new File(path);
		if (file.isFile() && file.exists()) {
			file.delete();
		}
	}
	
	
	/**
	 * 作者：李瑞浩
	 * 功能：ftp备份文件(.tar、.zip)到10.1.32.1服务器
	 * 时间：2014-12-09
	 * 
	 */
	public void ftpDelToolstar(String from,String to,String env) throws FtpCmpException, IOException {
		String host = messages.getMessage("exportServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("exportServer.user");
		String password = messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String to2 = to.substring(to.indexOf(messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(env).concat(messages.getMessage("path.linux")))+messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(env).concat(messages.getMessage("path.linux")).length(),to.lastIndexOf(messages.getMessage("path.linux")));
		ftpFile.doMkdirs(messages.getMessage("exportServer.path").concat(messages.getMessage("path.linux")).concat(env),to2);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
        ftpFile2.renamelFile(from, to);
		ftpLogin2.disconnect();
	}
	
	/**
	 * 作者：李瑞浩
	 * 功能：多线程
	 * 时间：2014-12-09
	 * 
	 */
	class Executor implements Runnable {

		private String appsys_code; 
		private String userId;
		private String fServerFolder;
		private CountDownLatch end;
		private File[] fileList;
		private StringBuffer errorSb;
		private String env;
		private String envExp;
		
		public Executor(String appsys_code, String userId, String fServerFolder,
				CountDownLatch end, File[] f2, StringBuffer errorSb ,String env ,String envExp) {
			super();
			this.appsys_code = appsys_code;
			this.userId = userId;
			this.fServerFolder = fServerFolder;
			this.end = end;
			this.fileList = f2;
			this.errorSb = errorSb;
			this.env = env;
			this.envExp = envExp;
		}

		@Override
		public void run() {
			try {
				// 用户登录
				LoginServiceClient loginClient = null;
				LoginUsingUserCredentialResponse loginResponse = null;
				loginClient = new LoginServiceClient(
						messages.getMessage("bsa.userName")
						,messages.getMessage("bsa.userPassword")
						,messages.getMessage("bsa.authenticationType")
						,null
						,new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("bsa.truststoreFile"))
							.toString()
						,messages.getMessage("bsa.truststoreFilePassword")
						);
				loginResponse = loginClient.loginUsingUserCredential();
				String sessionId = loginResponse.getReturnSessionId();
				
				for(int i = 0; i < fileList.length; i++){
					bsaOperator(appsys_code, userId, fServerFolder,sessionId , fileList[i] ,env ,envExp);
				}
				end.countDown();
			} catch (Exception e) {
				errorSb.append(e.getMessage() + ";");
				end.countDown();
			}
		}
	}
}


package com.nantian.dply.service;

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
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import org.apache.axis2.AxisFault;
import org.apache.http.conn.HttpHostConnectException;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.parameter.ParamExport;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
@Service
public class MoveBsaExportService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveBsaExportService.class);
	public static Map<String,String> fields = new HashMap<String,String>();
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	
	@Autowired
	private ThreadPoolTaskExecutor taskExcutor;
	
	@Autowired
	private DplyExcuteStatusService dplyExcuteStatusService;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	public Session getSession(){
		return sessionFactory.getCurrentSession();
	}

	

	
	/**
     * 构造方法
     */
    public MoveBsaExportService() {
        fields.put("entryId", FieldType.STRING);
        fields.put("appsysCode", FieldType.STRING);
        fields.put("userId", FieldType.STRING);
        fields.put("excuteStartTime", FieldType.STRING);
        fields.put("excuteEndTime", FieldType.STRING);
        fields.put("moveStatus", FieldType.STRING);
        fields.put("operateTyep", FieldType.STRING);
        fields.put("operateSource", FieldType.STRING);
        fields.put("operateLog", FieldType.STRING);
    }
    
    /**
	 * FTP获取文件
	 * 
	 * @param String localPath
	 * @param String appsys_code
	 */
	@Transactional
	public void exportFtp(String localPath,String appsys_code,String env) {
		String host=messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdir(messages.getMessage("bsa.dplyPath"), new StringBuffer());
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doGet(
				new StringBuilder().append(messages.getMessage("bsa.moveFilePath"))
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("bsa.dplyPath"))
					.append(messages.getMessage("path.linux"))
					.append(env)
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".tar")
					.toString()
				,localPath
				,true
				,new StringBuffer()
			);
		ftpLogin2.disconnect();
	}
    
	
	/**
	 * FTP发送文件到10.1.32.1
	 * 
	 * @param String localFilename
	 * @param String appsys_code
	 * @param String bmc
	 * 
	 * @throws AxisFault 
	 * @throws Exception
	 */
	@Transactional
	public void ftpPutFileServer(String localFilename,String appsys_code,String bmc,String env) throws AxisFault,Exception {
		String host=messages.getMessage("exportServer.ipAdress");
		int port = (Integer.parseInt(messages.getMessage("exportServer.port")));
		String user = messages.getMessage("exportServer.user");
		String password=messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String remoteFilename = "";
		String remoteFilename2 = "";
		if(bmc.equals("bsa")){
			remoteFilename = new StringBuilder().append(messages.getMessage("exportServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(env)
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("exportServer.bsaPath"))
					.append(messages.getMessage("path.linux"))
					
					.append(appsys_code).append(".tar")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.bsaPath");
		}
		
		if(bmc.equals("param")){
			remoteFilename = new StringBuilder().append(messages.getMessage("exportServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(env)
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("exportServer.paramPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".zip")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.paramPath");
		}
		ftpFile.doMkdirs(new StringBuilder().append(messages.getMessage("exportServer.path")).append(messages.getMessage("path.linux"))
				.append(env).toString(),remoteFilename2);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doPut(localFilename, remoteFilename, true,new StringBuffer());
		ftpLogin2.disconnect();
	}

	/**
	 * 删除bsa服务器上的文件

	 * 
	 * @param String appsys_code
	 * 
	 * @throws AxisFault
	 * @throws Exception 
	 */
	@SuppressWarnings("unused")
	@Transactional
	public void deleteBsaFile(String appsys_code,String env) throws AxisFault,Exception {
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString()});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyCreatExportJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).append(env).append(messages.getMessage("path.linux")).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString(),"1",appsys_code});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}
	
	/**
	 * 导出brpm和bsa.
	 * 
	 * @param String appsys_code
	 * @param String tranItemS
	 * @param String brpm
	 * @param String bsa
	 * 
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws URISyntaxException
	 * @throws HttpHostConnectException
	 * @throws Exception 
	 */
	@Transactional
	public void BsaExport(String uuid,String appsys_code,String bsa,String env) throws IOException, BrpmInvocationException, URISyntaxException,HttpHostConnectException,Exception   {
		//uuid, appsys_code, bsa, userName
		String sourceFilePath = null;
		File sourceFile = null;
		String paramFileLocalPath = null;
		String paramFilePath = null;
		File paramFileLocalFile = null;
		File paramFileFile = null;
		ParamExport pe = null;
		String paramExportXml = null;
		

		if((bsa!=null)&&(bsa.length()!=0)&&(!appsys_code.equals(""))&&(!env.equals(""))&&(appsys_code.length()!=0)){
			if(bsa.equals("1")){
				if(ComUtil.isWindows){
					sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.bsaZipPackagePath"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();

				}else{
					sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.bsaZipPackagePathForLinux"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();
				}
				sourceFile = new File(sourceFilePath);
				if(!sourceFile.exists()){
					sourceFile.mkdirs();
				}
				
				deleteBsaFile(appsys_code,env);
				JobExport(uuid,appsys_code,env);
				exportFtp(
						new StringBuilder().append(sourceFilePath)
							.append(appsys_code)
							.append(".tar")
							.toString()
						,appsys_code
						,env
						);
				ftpPutFileServer(
						new StringBuilder().append(sourceFilePath)
							.append(appsys_code)
							.append(".tar")
							.toString()
						,appsys_code
						,"bsa"
						,env
						);
				delFile(
						new StringBuilder().append(sourceFilePath)
							.append(appsys_code)
							.append(".tar")
							.toString()
						);
				 if(ComUtil.isWindows){
					paramFileLocalPath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.paramFilePath"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();
					paramFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.paramPackagePath"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();
				}else{
					paramFileLocalPath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.paramFilePathForLinux"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();
					paramFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.paramPackagePathForLinux"))
							.append(File.separator)
							.append(env)
							.append(File.separator)
							.toString();
				}
				delFile(
						new StringBuilder().append(paramFilePath)
							.append(File.separator)
							.append(appsys_code)
							.append(".zip")
							.toString()
						);

				paramFileLocalFile = new File(paramFileLocalPath);
				if(!paramFileLocalFile.exists()){
					paramFileLocalFile.mkdirs();
				}
				paramFileFile = new File(paramFilePath);
				if(!paramFileFile.exists()){
					paramFileFile.mkdirs();
				}
				pe = new ParamExport();
				paramExportXml = pe.doExportParams(appsys_code);
				exportParamFile(
						paramExportXml
						,new StringBuilder().append(appsys_code)
							.append(".xml")
							.toString()
						,appsys_code
						,env
						);
				fileToZip(
						new StringBuilder().append(paramFileLocalPath)
							.append(File.separator)
							.append(appsys_code)
							.toString()
						,paramFilePath
						,appsys_code
						);
				ftpPutFileServer(
						new StringBuilder().append(paramFilePath)
							.append(File.separator)
							.append(appsys_code)
							.append(".zip")
							.toString()
						,appsys_code
						,"param"
						,env
						);	
				delAllFile(
						new StringBuilder().append(paramFileLocalPath)
							.append(File.separator)
							.append(appsys_code)
							.append(File.separator)
							.toString()
						);
				delFile(
						new StringBuilder().append(paramFilePath)
							.append(File.separator)
							.append(appsys_code)
							.append(".zip")
							.toString()
						);
						
			}
		}
	}
	
	
	/**
	 * 文件打包成zip压缩包.
	 * 
	 * @param String sourceFilePath
	 * @param String zipFilePath
	 * @param String fileName
	 * 
	 * @throws IOException
	 */
	public  boolean fileToZip(String sourceFilePath, String zipFilePath,
			String fileName) throws IOException ,Exception{
		boolean flag = false;
		File sourceFile = new File(sourceFilePath);
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		FileOutputStream fos = null;
		ZipOutputStream zos = null;
		if (sourceFile.exists() == false) {
			
		} else {
			File zipFile = new File(
					new StringBuilder().append(zipFilePath)
						.append(File.separator)
						.append(fileName)
						.append(".zip")
						.toString()
					);
			try{
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
								// 创建ZIP实体,并添加进压缩包

								ZipEntry zipEntry = new ZipEntry(sourceFiles[i].getName());
								zos.putNextEntry(zipEntry);
								// 读取待压缩的文件并写进压缩包里

								fis = new FileInputStream(sourceFiles[i]);
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
			}catch(Exception e){
				throw e;
			}finally{
				if (null != zos){
					zos.close();
				}
				if (null != fos){
					fos.close();
				}
			}
			
			
		}
		return flag;
	}
	
	
	/**
	 * 删除文件夹里面的所有文件.
	 * 
	 * @param path String 文件夹路径.
	 */
	public void delAllFile(String path){
		File file = new File(path);
	     if (!file.exists()){
			return;
		}
		if (!file.isDirectory()){
			return;
		}
		String[] tempList = file.list();
		File temp = null;
		for (int i = 0; i < tempList.length; i++ ){
			if (path.endsWith(File.separator)){
				temp = new File(path.concat(tempList[i]) );
			}
			if (temp.isFile()){
				temp.delete();
			}
			if (temp.isDirectory()){
				delAllFile(
						new StringBuilder().append(path)
							.append(File.separator)
							.append(tempList[i])
							.append(File.separator)
							.toString()
						);//先删除文件夹里面的文件
			}
		}		
	}
	/**
	 * 删除指定文件
	 * 
	 * @param path String 文件夹路径
	 */
	public void delFile(String path){
		File file = new File(path);
	    if(file.isFile()&&file.exists()){
	    	file.delete();
	    } 
	}
	
	/**
	 * bsa导出
	 * @param String appsys_code
	 * @throws AxisFault
	 * @throws Exception 
	 */
	public void JobExport(String uuid,String appsys_code,String env) throws AxisFault,Exception  {
		
		if(appsys_code != null && !"".equals(appsys_code)){
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
			//清理上次导出打包作业并新建打包作业
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString()});
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString(),"",messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(".nsh").toString(),messages.getMessage("bsa.ipAddress"),"2"});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			//获取DEPLOY下指定系统的目录下的所有服务目录
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String serFolder=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			String[] JobFolder = serFolder.split("\n");
			
			//过滤备份及其他目录后的实际发布作业服务目录信息缓冲区
			List<String> jobServiceGroupFolder = new ArrayList<String>();
			//记录抽取后需要导出作业的服务目录数
			int JobFolderCount = 0;
			//抽取需要导出作业的服务目录
			for(int i=0; i<JobFolder.length; i++){
				if(JobFolder[i].equals("TOOLS")){
					continue;
				}
				
				if(JobFolder[i].length() > 10
						&& JobFolder[i].substring(0,3).equals("BAK")
						&& DateFunction.isDate(JobFolder[i].substring(3,11))){
					continue;
				}
				JobFolderCount++;
				jobServiceGroupFolder.add(JobFolder[i]);
			}
			
			//线程计数器
			CountDownLatch end = new CountDownLatch(JobFolderCount);
			//线程异常信息缓冲区
			StringBuffer errorSb = new StringBuffer();
			
			for(int i=0; i<jobServiceGroupFolder.size(); i++){
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(jobServiceGroupFolder.get(i)).toString()});
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(jobServiceGroupFolder.get(i)).toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob"),messages.getMessage("bsa.ipAddress"),"3"});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(jobServiceGroupFolder.get(i)).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				
				Runnable runner = new Executor(appsys_code, jobServiceGroupFolder.get(i), end, DBkey1, errorSb,env);

				taskExcutor.execute(runner);
			}
			//主线程等待所有子线程结束，即CountDownLatch为0
			end.await();
			if(errorSb.length() != 0) {
				updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, errorSb.toString());
			}
			
			client = new LoginServiceClient();
			loginResponse = client.getBsaCredential();
			cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			executeCommandByParamListResponse = null;
			
			if(JobFolderCount != 0){
				//执行打包作业，将导出的发布作业进行打包				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String dBkeyZip=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).append(env).append(messages.getMessage("path.linux")).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString(),"1",appsys_code});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyZip});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				for(int i=0; i<jobServiceGroupFolder.size(); i++){
					//删除临时导出作业
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(jobServiceGroupFolder.get(i)).toString()});
				}
				//删除临时打包作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(env).append(appsys_code).toString()});
				//删除临时删除作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(env).append(appsys_code).toString()});
				
			}
		}
	}
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void exportParamFile(String xmlFile,String fileName,String appsys_code,String env) throws UnsupportedEncodingException, FileNotFoundException, Exception{
			String filePath = null;
			if(ComUtil.isWindows){
				filePath = new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.paramFilePath"))
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.toString();
			}else{
				filePath = new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.paramFilePathForLinux"))
						.append(File.separator)
						.append(env)
						.append(File.separator)
						.append(appsys_code)
						.toString();
			}
			File file = new File(filePath);
			if(!file.exists()){
				file.mkdirs();
			}
			
			PrintWriter out = null;
			try{
				out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new StringBuilder().append(filePath).append(File.separator).append(fileName).toString()),"utf-8"));
				out.println(xmlFile);
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
     * 更新导出记录状态信息.
     * 
     * @param entryId
     * @param moveStatus
     * @param errMsg
     */
    @Transactional
	public void updateDplyExcuteStatusVo(String entryId,String moveStatus,String errMsg){
		Date date = new Date();
		Timestamp executeEndTime =new Timestamp(date.getTime());
		DplyExcuteStatusVo dExeVo = (DplyExcuteStatusVo) dplyExcuteStatusService.get(entryId);
		
		dExeVo.setExcuteEndTime(executeEndTime);
		dExeVo.setMoveStatus(moveStatus);
		dExeVo.setOperateLog(errMsg);
		
		getSession().update(dExeVo);
//		getSession().createQuery(
//			"update DplyExcuteStatusVo t set t.moveStatus = :moveStatus,t.excuteEndTime = :excuteEndTime, t.operateLog = :operateLog where t.entryId=:entryId ")
//				.setString("moveStatus", moveStatus)
//				.setTimestamp("excuteEndTime", executeEndTime)
//				.setString("operateLog", errMsg)
//				.setString("entryId", entryId)
//				.executeUpdate();
	}
	
	class Executor implements Runnable {

		private String appsys_code; 
		private String fServerFolder;
		private CountDownLatch end;
		private String DBkey1;
		private StringBuffer errorSb;
		private String env;
		
		public Executor(String appsys_code, String fServerFolder,
				CountDownLatch end,String DBkey1, StringBuffer errorSb,String env) {
			super();
			this.appsys_code = appsys_code;
			this.fServerFolder = fServerFolder;
			this.end = end;
			this.DBkey1 = DBkey1;
			this.errorSb = errorSb;
			this.env = env;
		}

		@Override
		public void run() {
			try {
//				System.out.println(Thread.currentThread().getName() + "==============");
//				System.out.println(fServerFolder);
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
				
				
				ExecuteCommandByParamListResponse executeCommandByParamListResponse;
				CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(sessionId, null);
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(fServerFolder).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String serJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				String[] JobName = serJob.split("\n");
				
				for(int j=0;j<JobName.length;j++){

					bsaOperator(appsys_code
							,fServerFolder
							,sessionId
							,JobName[j]
							,DBkey1
							,env);
				}
				end.countDown();
			} catch (Exception e) {
				errorSb.append(e.getMessage() + ";");
				end.countDown();
			}
		}
	}
	
	/**
	 * 导入bsa作业执行
	 * 
	 * @param String String appsys_code
	 * @param String userId
	 * @param String fServerFolder
	 * @param String sessionId
	 * @param File f2
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws AxisFault
	 * @throws Exception
	 * 
	 */
	private void bsaOperator(String appsys_code
							,String JobFolder
							,String sessionId
							,String JobName
							,String DBkey1
							,String env
							)
			throws FileNotFoundException, IOException, AxisFault,Exception {

		
		ExecuteCommandByParamListResponse executeCommandByParamListResponse;
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(sessionId, null);
		
		
		
		String objectType = null;
		String jobType = null;
		
			
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder).toString(),JobName});
			String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder).toString(),JobName});
			String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			
			if(DeployJobDBkey.equals("void")&&NSHScriptJob.equals("void")){
				return;
			}else if(!DeployJobDBkey.equals("void")){
				objectType = "30";
				jobType = "DeployJob";
			}else if(!NSHScriptJob.equals("void")){
				objectType = "111";
				jobType = "NSHScriptJob";
			}
			
			
			//执行导出作业
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(jobType, "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder).toString(),JobName});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String DBkey2=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(JobFolder).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(JobFolder).toString(),"0",objectType});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(JobFolder).toString(),"1",DBkey2});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
							
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(env).append(appsys_code).append(JobFolder).toString(),"2",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).append(env).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder).append(messages.getMessage("path.linux")).append(JobName).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
	
	}
	
	/**
     * 创建导出开始记录.
     * 
     * @param entryId
     * @param appsys_code
     * @param tranItemS
     * @param brpm
     * @param bsa
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
		vo.setOperateType("导出");
		vo.setOperateSource(operateSource);
		vo.setEnvironment(env);
		getSession().save(vo);
	}
    
    
}

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
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.axis2.AxisFault;
import org.apache.http.conn.HttpHostConnectException;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;
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

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
@Service
public class MoveBrpmExportService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveBrpmExportService.class);
	public static Map<String,String> fields = new HashMap<String,String>();
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	@Autowired
	private AppInfoService appInfoService;
  	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;
	/** BRPM调用接口 */
	@Autowired
	private BrpmService method;
	
	public Session getSession(){
		return sessionFactory.getCurrentSession();
	}

	
	@Autowired
	private SecurityUtils securityUtils;
	
	/**
     * 构造方法


     */
    public MoveBrpmExportService() {
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
     * 查询数据
     * 
     * @param Integer start
     * @param Integer limit
     * @param String sort
     * @param String dir
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return List<Map<String, String>>
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    @Transactional(readOnly = true)
    public List<Map<String, String>> queryDplyExctueStatus(Integer start, Integer limit, String sort, String dir,String appsysCode,String userId,String excuteStartTime,String excuteEndTime,String moveStatus,String operateType,String operateSource,String environment) {

        StringBuilder sql = new StringBuilder();
        sql.append("select o.ENTRY_ID as \"entryId\",")
        	.append("o.APPSYS_CODE as \"appsysCode\",")
        	.append("o.USER_ID as \"userId\",")
        	.append("to_char(o.EXECUTE_START_TIME, 'yyyymmdd hh24:mi:ss') as \"excuteStartTime\",")
        	.append("to_char(o.EXECUTE_END_TIME, 'yyyymmdd hh24:mi:ss') as \"excuteEndTime\",")
        	.append("o.MOVE_STATUS as \"moveStatus\",")
        	.append("o.OPERATE_TYPE as \"operateType\",")
        	.append("o.OPERATE_SOURCE as \"operateSource\",")
        	.append("o.OPERATE_LOG as \"operateLog\",")
        	.append("o.ENVIRONMENT as \"environment\" ")
        	.append("from dply_execute_status o where o.APPSYS_CODE in :sysList");
        	
        if(null != appsysCode && appsysCode.length() > 0){
        	sql.append(" and o.APPSYS_CODE = '" + appsysCode+"'");
        }
        
        if(null != userId && userId.length() > 0){
        	sql.append(" and o.USER_ID = '" + userId+"'");
        }
        
        if(null != excuteStartTime && excuteStartTime.length() > 0){
        	sql.append(" and o.EXECUTE_START_TIME > to_timestamp('" + excuteStartTime + "', 'yyyymmdd hh24:mi:ss')");
        }
        
        if(null != excuteEndTime && excuteEndTime.length() > 0){
        	sql.append(" and o.EXECUTE_END_TIME < to_timestamp('" + excuteEndTime + "', 'yyyymmdd hh24:mi:ss')");
        }
        
        if(null != moveStatus && moveStatus.length() > 0){
        	sql.append(" and o.MOVE_STATUS = '" + moveStatus+"'");
        }
        
        if(null != operateType && operateType.length() > 0){
        	sql.append(" and o.OPERATE_TYPE = '" + operateType+"'");
        }
        
        if(null != operateSource && operateSource.length() > 0){
        	sql.append(" and o.OPERATE_SOURCE = '" + operateSource+"'");
        }
        
        if(null != environment && environment.length() > 0){
        	sql.append(" and o.ENVIRONMENT = '" + environment+"'");
        }
        
        sql.append(" order by EXECUTE_END_TIME DESC,EXECUTE_START_TIME ASC,move_status DESC,APPSYS_CODE ASC,OPERATE_SOURCE ASC ");//APPSYS_CODE asc,OPERATE_SOURCE asc,EXECUTE_START_TIME desc
        Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult(start).setMaxResults(limit);
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        List s=query.list();
        return s;
    }
    /**
     * 查询数据总数
     * 
     * @param String appsysCode
     * @param String userId
     * @param String excuteStartTime
     * @param String excuteEndTime
     * @param String moveStatus
     * @param String operateType
     * @param String operateSource
     * 
     * @return Long
     */
    @Transactional(readOnly = true)
    public Long count(String appsysCode,String userId,String excuteStartTime,String excuteEndTime,String moveStatus,String operateType,String operateSource,String environment) {

    	StringBuilder sql = new StringBuilder();
    	sql.append("select count(*) ")
    	.append("from dply_execute_status o where o.APPSYS_CODE in :sysList");

    	if(null != appsysCode && appsysCode.length() > 0){
        	sql.append(" and o.APPSYS_CODE = '" + appsysCode+"'");
        }
        
        if(null != userId && userId.length() > 0){
        	sql.append(" and o.USER_ID = '" + userId+"'");
        }
        
        if(null != excuteStartTime && excuteStartTime.length() > 0){
        	sql.append(" and o.EXECUTE_START_TIME > to_timestamp('" + excuteStartTime + "', 'yyyymmdd hh24:mi:ss')");
        }
        
        if(null != excuteEndTime && excuteEndTime.length() > 0){
        	sql.append(" and o.EXECUTE_END_TIME < to_timestamp('" + excuteEndTime + "', 'yyyymmdd hh24:mi:ss')");
        }
        
        if(null != moveStatus && moveStatus.length() > 0){
        	sql.append(" and o.MOVE_STATUS = '" + moveStatus+"'");
        }
        
        if(null != operateType && operateType.length() > 0){
        	sql.append(" and o.OPERATE_TYPE = '" + operateType+"'");
        }
        
        if(null != operateSource && operateSource.length() > 0){
        	sql.append(" and o.OPERATE_SOURCE = '" + operateSource+"'");
        }
        
        if(null != environment && environment.length() > 0){
        	sql.append(" and o.ENVIRONMENT = '" + environment+"'");
        }
        
	    Query query = getSession().createSQLQuery(sql.toString());
	    query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        return Long.valueOf(query.uniqueResult().toString());
    }
    
    /**
	 * 批量修改删除标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void editByIds(String[] entryId) throws SQLException {
		for (int i = 0; i < entryId.length && i < entryId.length; i++) {
			//getSession().createQuery("update dply_execute_status tb set tb.MOVE_STATUS='失败' where tb.entryId = '" + entryId + "'").executeUpdate();
			Date date = new Date();
			Timestamp tt =new Timestamp(date.getTime());
			getSession().createQuery(
					"update DplyExcuteStatusVo t set t.moveStatus = '失败',t.excuteStartTime = :excuteStartTime,t.excuteEndTime = :excuteEndTime,t.operateLog = :operateLog where t.entryId=:entryId ")
					.setTimestamp("excuteStartTime", tt)
					.setTimestamp("excuteEndTime", tt)
					.setString("operateLog", "手动置为失败")
					.setString("entryId", entryId[i]).executeUpdate();
		}
	}
    
    /**
   	 * 通过主键查找唯一的一条记录



   	 * 
   	 * @param String entryId
   	 * @return Object 
   	 */
   	@Transactional(readOnly = true)
   	public Object findByPrimaryKey(String entryId){
   		StringBuilder hql = new StringBuilder();
   		hql.append("select o.OPERATE_LOG as \"operateLog\" ")
   	       .append("from DPLY_EXECUTE_STATUS o where o.ENTRY_ID = '"+entryId+"'");
   		return	getSession().createSQLQuery(hql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();
   	}
   	

    
	/**
	 * 查询系统平台
	 * @throws SQLException
	 * @return Object 
	 */
   	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object getCmnAppInfo()throws SQLException{
		List<Map<String ,String>>  jsonMapList = new ArrayList<Map<String,String>>();
		String sql="SELECT s.appsys_code as appsys_code,s.systemname as appsys_name FROM V_CMN_APP_INFO s order by appsys_code ";//where s.ID='CEB-NBANK' OR s.ID='CEB-NEXCH'
		Query query = getSession().createSQLQuery(sql.toString());
		List<Object[]> lis = query.list();
		for(Object[] str :lis){
			Map<String ,String> map = new HashMap<String,String>();
			map.put("appsys_code", String.valueOf(str[0]));
			map.put("appsys_name", String.valueOf(str[1]));
			jsonMapList.add(map);
		}
		return jsonMapList;
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
		
		if(bmc.equals("brpm")){
			remoteFilename = new StringBuilder().append(messages.getMessage("exportServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(env)
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("exportServer.brpmPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".zip")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.brpmPath");
		}
		
		ftpFile.doMkdirs(messages.getMessage("exportServer.path"),remoteFilename2);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doPut(localFilename, remoteFilename, true,new StringBuffer());
		ftpLogin2.disconnect();
	}
	
    /**
     * 
     * 获取请求信息列表文件，ftp到jeda服务器并解压缩包后删除压缩包。
     * 
     * @param appsys_code
     * @param tranItemS
     * @param brpm
     * @param userId
     * @throws Exception 
     * 
     * 
     */
	@Transactional
    public String[] getRequestsInfo(String appsys_code, String tranItemS, String brpm,  String userId) throws Exception{
		List<Object[]> lis = brpmService.getRequests();
		String[] tranItemSid = tranItemS.split(",");
		String[] doGetRequestsNamelist = new String[tranItemSid.length];
		String reqId = null;
		String reqName = null;
		int i = 0;
		for(int j=0;j<tranItemSid.length;j++){
			for (Object[] str :lis) {
				reqId = String.valueOf(str[0]);
				reqName = String.valueOf(str[1]);
				if(tranItemSid[j].equals(reqId)){
					doGetRequestsNamelist[i] = reqName+CommonConst.REPLACE_CHAR+reqId;
					i++;
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
	public String allappDbCheck(String[] doGetFilesNamelist) throws Exception{
		String reqId = null;
		String reqName = null;
		String stepId = null;
		String stepName = null;
		String msg = "";
		boolean allappDbCheckFlag = false;
		for (int i=0;i<doGetFilesNamelist.length;i++) {
			allappDbCheckFlag = false;
			reqId = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1];
			reqName = doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0];
			List<Object[]> lisSteps = brpmService.getSteps(reqId);
			//int size = lisSteps.size();
			for (Object[] str1 :lisSteps) {
				//size--;
				if(String.valueOf(str1[0])!=null){
					stepId = String.valueOf(str1[0]);
					//stepName = String.valueOf(str1[1]);
				}
			}
			
			String jobPath = brpmService.bsaJobPath(stepId);
			if(jobPath.indexOf(CommonConst.DB_CHECK)!=-1){
				allappDbCheckFlag = true;
			}
			if(allappDbCheckFlag == false){
				msg += "请求" + reqName + "缺少" + CommonConst.DB_CHECK + "步骤！</br>";
			}
		}
		
		return msg;
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
	public void BrpmExport(String[] doGetFilesNamelist,Map<String,String> uuidBrpmMap,String appsys_code,String brpm,String userName,String env){
		String reqId = null;
		String reqName = null;
		String zipFilePath = null;
		String fileName = null;
		String stepId = null;
		String stepName = null;
		String stepXml = null;
		Document manualDoc = null;
		Element manualRoot = null;
		String manual = null;
		String jobPath = null;
		Document stepDoc = null;
		Element stepRoot = null;
		String componentId = null;
		String componentName = null;
		String sourceFilePath = null;
		File sourceFile = null;
		File zipFile = null;
		String uuid = null;
		String allappDbCheckFlag = "";
		for (int x=0;x<doGetFilesNamelist.length;x++) {
			allappDbCheckFlag = "DBCheck2";
			reqId = doGetFilesNamelist[x].split(CommonConst.REPLACE_CHAR)[1];
			reqName = doGetFilesNamelist[x].split(CommonConst.REPLACE_CHAR)[0];
			uuid=uuidBrpmMap.get(reqId);
			//更新导入状态表当前发起的BRPM请求任务状态


			updateDplyExcuteStatusRunningVo(uuid, CommonConst.MOVESTATUS_RUNNING_CH, "");

			try{
				if((brpm!=null)&&(brpm.length()!=0)&&(!appsys_code.equals(""))&&(appsys_code.length()!=0)){
					brpmService.putMethod(BrpmConstants.KEYWORD_REQUSET, reqId,
							new StringBuilder().append("<request><description>").append(userName).append("</description></request>").toString());
					exportFile(
							brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, reqId)
							,new StringBuilder()
								.append(reqName)
								.append("@")
								.append(reqId)
								.append(".xml")
								.toString()
							,appsys_code
							,env
							);
					List<Object[]> lisSteps = brpmService.getSteps(reqId);
					for (Object[] str2 :lisSteps) {
						if(String.valueOf(str2[0])!=null){
							stepId = String.valueOf(str2[0]);
							stepName = String.valueOf(str2[1]);
							
							stepXml=brpmService.getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
							manualDoc = JDOMParserUtil.xmlParse(stepXml);
							manualRoot = manualDoc.getRootElement();
							manual = manualRoot.getChildText("manual");
							if(manual.equals("false")){
								jobPath = brpmService.bsaJobPath(stepId);
								jobPath = messages.getMessage("path.linux") + env + jobPath;
								if(jobPath.indexOf(CommonConst.DB_CHECK)!=-1){
									allappDbCheckFlag = "DBCheck1";
								}
								brpmService.putMethod(BrpmConstants.KEYWORD_STEPS, stepId, new StringBuilder().append("<step><description>").append(jobPath).append("</description></step>").toString());
							}
							stepXml=brpmService.getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
							exportFile(
									stepXml
									,new StringBuilder().append(reqName)
										.append("@")
										.append(reqId)
										.append("@")
										.append(stepName)
										.append("@")
										.append(stepId)
										.append(".xml")
										.toString()
									,appsys_code
									,env
									);
						}
						stepDoc = JDOMParserUtil.xmlParse(stepXml);
						stepRoot = stepDoc.getRootElement();

						if(stepRoot.getChild("component")!=null){
							componentId = stepRoot.getChild("component").getChildText("id");
							componentName = stepRoot.getChild("component").getChildText("name");
							exportFile(
									brpmService.getMethodById(BrpmConstants.KEYWORD_COMPONENTS, componentId)
									,new StringBuilder().append(reqName).append("@")
										.append(reqId)
										.append("@")
										.append(stepName)
										.append("@")
										.append(stepId)
										.append("@")
										.append(componentName)
										.append("@")
										.append(componentId)
										.append(".xml")
										.toString()
									,appsys_code
									,env
									);
						}
					}
					
					if(ComUtil.isWindows){
						sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.brpmFilePath"))
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.toString();
					}else{
						sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
								.append(File.separator)
								.append(messages.getMessage("systemServer.brpmFilePathForLinux"))
								.append(File.separator)
								.append(env)
								.append(File.separator)
								.append(appsys_code)
								.toString();
					}
					sourceFile = new File(sourceFilePath);
					if(!sourceFile.exists()){
						sourceFile.mkdirs();
					}
					if(ComUtil.isWindows){
						zipFilePath = new StringBuilder().append(System.getProperty("maop.root"))
								.append(messages.getMessage("systemServer.brpmPackagePath"))
								.append(File.separator)
								.append(env)
								.toString();
					}else{
						zipFilePath = new StringBuilder().append(System.getProperty("maop.root"))
								.append(File.separator)
								.append(messages.getMessage("systemServer.brpmPackagePathForLinux"))
								.append(File.separator)
								.append(env)
								.toString();
					}
					zipFile = new File(zipFilePath);
					if(!zipFile.exists()){
						zipFile.mkdirs();
					}
					fileName = new StringBuilder().append(reqName)
							.append(CommonConst.REPLACE_CHAR)
							.append(reqId).append(CommonConst.REPLACE_CHAR).append(allappDbCheckFlag)
							.toString();
					fileToZip(sourceFilePath, zipFilePath, fileName);
					delAllFile(
							new StringBuilder().append(sourceFilePath)
								.append(File.separator)
								.toString()
							);
					
					ftpPutFileServer(
							new StringBuilder().append(zipFilePath)
								.append(File.separator)
								.append(fileName)
								.append(".zip")
								.toString()
							,fileName
							,"brpm"
							,env
							);
					delAllFile(
							new StringBuilder().append(zipFilePath)
								.append(File.separator)
								.toString()
							);
					if(ComUtil.isWindows){
						delFile(
								new StringBuilder().append(System.getProperty("maop.root"))
									.append(messages.getMessage("systemServer.brpmPackagePath"))
									.append(File.separator)
									.append(env)
									.append(File.separator)
									.append(fileName)
									.append(".zip")
									.toString()
								);		
					}else{
						delFile(
								new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("systemServer.brpmPackagePathForLinux"))
									.append(File.separator)
									.append(env)
									.append(File.separator)
									.append(fileName)
									.append(".zip")
									.toString()
								);		
					}
						
				}
				
				updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_OK_CH, "");
			}catch(Exception e){
				updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
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
	public void exportFile(String xmlFile,String fileName,String appsys_code,String env) throws Exception{
		String filePath = null;
		if(ComUtil.isWindows){
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(messages.getMessage("systemServer.brpmFilePath"))
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
		}else{
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("systemServer.brpmFilePathForLinux"))
					.append(File.separator)
					.append(env)
					.append(File.separator)
					.append(appsys_code)
					.toString();
		}
		File file = new File(filePath);
		PrintWriter out = null;
		try{
			if(!file.exists()){
				file.mkdirs();
			}
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
	 * 文件打包成zip压缩包.
	 * 
	 * @param String sourceFilePath
	 * @param String zipFilePath
	 * @param String fileName
	 * 
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
			File zipFile = new File(
					new StringBuilder().append(zipFilePath)
						.append(File.separator)
						.append(fileName)
						.append(".zip")
						.toString()
					);
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
   	 * 查询请求
   	 * @param reqList 请求列表
   	 * @return List
   	 */
   	@Transactional(readOnly = true)
   	public Object findReqListByReqNames(List<String> reqNames){
 		StringBuilder sql = new StringBuilder();
  		sql.append("select request_name as \"reqName\" from dply_request_info where request_name in(:reqNames)");
   		return getSession().createSQLQuery(sql.toString())
   					.setParameterList("reqNames", reqNames)
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
   				
   	}
	
	/**
	 * 从文件中获取请求
	 * @param String appsys_code
	 * @throws ParseException
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws URISyntaxException 
	 * @throws HttpHostConnectException
	 * @throws Exception
	 * @return Object
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object getRequest(String appsys_code,String env) throws ParseException, IOException, BrpmInvocationException, URISyntaxException,HttpHostConnectException,Exception {

		List<String> reqNameList =  new ArrayList<String>();
		List<Map<String ,String>>  jsonMapList = new ArrayList<Map<String,String>>();
		Map<String,String> reqMap = new HashMap<String,String>();
		{
			String reqId=new String();
			String reqName=new String();
			String reqUpdateDate =new String();
			String reqEnv =new String();
			String sql = "select SUB_ITEM_VALUE from jeda_sub_item where ITEM_ID='REQUEST_MAX_DAY' and SUB_ITEM_CASCADE=0";
			Query query = getSession().createSQLQuery(sql.toString());
			Long day = new Long(query.uniqueResult().toString());
			long DAY_MILLISECOND = 24*60*60*1000;
			List<Object[]> lis = brpmService.getRequests();
			if(appsys_code != null && !"".equals(appsys_code)){
				Date nowdate = new Date();
				SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd",Locale.CHINA);
				for (Object[] str :lis) {
					reqId = String.valueOf(str[0]);
					reqName = String.valueOf(str[1]);
					reqUpdateDate = String.valueOf(str[2]);
					reqEnv = String.valueOf(str[3]);
					if(env.equals(reqEnv)){
						if(reqName.length()>15){
							int indexOf = -1;
							if(reqName.indexOf("REQ_")!=-1){
								indexOf = reqName.indexOf("REQ_")+4;
							}
							if(reqName.indexOf("REQRST_")!=-1){
								indexOf = reqName.indexOf("REQRST_")+7;
							}
							if(indexOf!=-1&&reqName.substring(indexOf).length()>8){
								Date reqDateMatter = matter.parse(reqUpdateDate);
								if(reqName.startsWith(appsys_code)){
									if((nowdate.getTime()-reqDateMatter.getTime())/DAY_MILLISECOND<day){//yyyyMM
										reqMap.put(reqName, reqId);	
										reqNameList.add(reqName);
									}
								}
							}
						}
					}
				}
			}
		}
		if(reqNameList.size() != 0){
			List<Map<String,String>> list = (List<Map<String,String>>) findReqListByReqNames(reqNameList);
			Map<String ,String> map = null;
			for (Map<String,String> reqNameMap : list) {
				map = new HashMap<String,String>();
				map.put("reqId", reqMap.get(reqNameMap.get("reqName")));
				map.put("reqName", reqNameMap.get("reqName"));
				jsonMapList.add(map);
			}
		}
		for(int i=0;i<jsonMapList.size()-1;i++){
			for(int j=0;j<jsonMapList.size()-i-1;j++){
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
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
				Date date1 = dateFormat.parse(jsonMapList.get(j).get("reqName").substring(indexDate1,indexDate1+8));
				Date date2 = dateFormat.parse(jsonMapList.get(j+1).get("reqName").substring(indexDate2,indexDate2+8));
				if(date1.before(date2)){
					Map<String ,String> map = new HashMap<String,String>();
					Map<String ,String> map2 = new HashMap<String,String>();
					String reqId = jsonMapList.get(j).get("reqId");
					String reqName = jsonMapList.get(j).get("reqName");
					map.put("reqId", reqId);
					map.put("reqName", reqName);
					String reqId2 = jsonMapList.get(j+1).get("reqId");
					String reqName2 = jsonMapList.get(j+1).get("reqName");
					map2.put("reqId", reqId2);
					map2.put("reqName", reqName2);
					jsonMapList.set(j, map2);
					jsonMapList.set(j+1, map);	
				}
			}
		}
		return jsonMapList;
	}
	
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	public Object querySystemIDAndNamesByUser(String userId){
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
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
					.list();
	}

	/**
	 * 单用户导入多系统数据字典开关检查



	 * 
	 */
	@Transactional
	public boolean singUserDplyMulSysSwitchCheck(){
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
	public boolean mulUserDplySingSysCheck(String appsys_code,String env){
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
		vo.setOperateType("导出");
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
    
    
}

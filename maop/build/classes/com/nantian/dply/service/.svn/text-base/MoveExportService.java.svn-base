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
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.parameter.ParamExport;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * @author liruihao
 *
 */
@Service
public class MoveExportService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MoveExportService.class);
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
	
	public Session getSession(){
		return sessionFactory.getCurrentSession();
	}

	
	@Autowired
	private SecurityUtils securityUtils;
	
	/**
     * 构造方法     */
    public MoveExportService() {
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
    public List<Map<String, String>> queryDplyExctueStatus(Integer start, Integer limit, String sort, String dir,String appsysCode,String userId,String excuteStartTime,String excuteEndTime,String moveStatus,String operateType,String operateSource) {

        StringBuilder sql = new StringBuilder();
        sql.append("select o.ENTRY_ID as \"entryId\",")
        	.append("o.APPSYS_CODE as \"appsysCode\",")
        	.append("o.USER_ID as \"userId\",")
        	.append("to_char(o.EXECUTE_START_TIME, 'yyyymmdd hh24:mi:ss') as \"excuteStartTime\",")
        	.append("to_char(o.EXECUTE_END_TIME, 'yyyymmdd hh24:mi:ss') as \"excuteEndTime\",")
        	.append("o.MOVE_STATUS as \"moveStatus\",")
        	.append("o.OPERATE_TYPE as \"operateType\",")
        	.append("o.OPERATE_SOURCE as \"operateSource\",")
        	.append("o.OPERATE_LOG as \"operateLog\"")
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
    public Long count(String appsysCode,String userId,String excuteStartTime,String excuteEndTime,String moveStatus,String operateType,String operateSource) {

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
			
			getSession().createQuery(
					"update DplyExcuteStatusVo t set t.moveStatus = '失败' where t.entryId=:entryId ")
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
	 * 
	 * @throws SQLException
	 * @return Object 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object getCmnAppInfo()throws SQLException{
		List<Map<String ,String>>  jsonMapList = new ArrayList<Map<String,String>>();
		String sql="SELECT s.appsys_code as appsys_code,s.appsys_name as appsys_name FROM CMN_APP_INFO s order by appsys_code ";//where s.ID='CEB-NBANK' OR s.ID='CEB-NEXCH'
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
	 * FTP获取文件
	 * 
	 * @param String localPath
	 * @param String appsys_code
	 */
	@Transactional
	public void exportFtp(String localPath,String appsys_code) {
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
	public void ftpPutFileServer(String localFilename,String appsys_code,String bmc) throws AxisFault,Exception {
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
					.append(messages.getMessage("exportServer.bsaPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code).append(".tar")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.bsaPath");
		}
		if(bmc.equals("brpm")){
			remoteFilename = new StringBuilder().append(messages.getMessage("exportServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("exportServer.brpmPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".zip")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.brpmPath");
		}
		if(bmc.equals("param")){
			remoteFilename = new StringBuilder().append(messages.getMessage("exportServer.path"))
					.append(messages.getMessage("path.linux"))
					.append(messages.getMessage("exportServer.paramPath"))
					.append(messages.getMessage("path.linux"))
					.append(appsys_code)
					.append(".zip")
					.toString();
			remoteFilename2 = messages.getMessage("exportServer.paramPath");
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
	 * 删除bsa服务器上的文件
	 * 
	 * @param String appsys_code
	 * 
	 * @throws AxisFault
	 * @throws Exception 
	 */
	@SuppressWarnings("unused")
	@Transactional
	public void deleteBsaFile(String appsys_code) throws AxisFault,Exception {
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		
		CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString()});

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.deleteJob"),messages.getMessage("bsa.ipAddress"),"2"});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkeyCreatExportJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();

		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).toString()});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString(),"1",appsys_code});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
		
		executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
		cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
	}
	
    /**
     * 创建导出开始记录.
     * 
     * @param String entryId
     * @param String status
     * @param String appsys_code
     * @param String tranItemS
     * @param String brpm
     * @param String bsa
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
		vo.setOperateType("导出");
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
     * 
     * @param String entryId
     * @param String moveStatus
     * @param String errMsg
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
	@SuppressWarnings("unchecked")
	@Transactional
	public void export(String appsys_code,String tranItemS,String brpm,String bsa) throws IOException, BrpmInvocationException, URISyntaxException,HttpHostConnectException,Exception   {
		List<Object[]> lis = brpmService.getRequests();
		String reqId = null;
		String reqName = null;
		String zipFilePath = null;
		String fileName = null;
		String stepId = null;
		String stepName = null;
		String stepXml = null;
		String[] id = null;
		String userName =  securityUtils.getUser().getUsername();
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
		boolean flag;
		String paramFileLocalPath = null;
		String paramFilePath = null;
		File paramFileLocalFile = null;
		File paramFileFile = null;
		ParamExport pe = null;
		String paramExportXml = null;
		
		for (Object[] str :lis) {
			reqId = String.valueOf(str[0]);
			reqName = String.valueOf(str[1]);

			if((!tranItemS.equals(""))&&(tranItemS.length()!=0)&&(brpm!=null)&&(brpm.length()!=0)&&(!appsys_code.equals(""))&&(appsys_code.length()!=0)){
			
				id = tranItemS.split(",");
				for(int i = 0;i < id.length;i++){
					if(reqId.startsWith(id[i])){
						brpmService.putMethod(BrpmConstants.KEYWORD_REQUSET, reqId, new StringBuilder().append("<request><description>").append(userName).append("</description></request>").toString());
						exportFile(
								brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET, reqId)
								,new StringBuilder()
									.append(reqName)
									.append("@")
									.append(reqId)
									.append(".xml")
									.toString()
								,appsys_code
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
										);
							}
						}
						
						if(ComUtil.isWindows){
							sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
									.append(messages.getMessage("systemServer.brpmFilePath"))
									.append(File.separator)
									.append(appsys_code)
									.toString();
						}else{
							sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("systemServer.brpmFilePathForLinux"))
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
									.toString();
						}else{
							zipFilePath = new StringBuilder().append(System.getProperty("maop.root"))
									.append(File.separator)
									.append(messages.getMessage("systemServer.brpmPackagePathForLinux"))
									.toString();
						}
						zipFile = new File(zipFilePath);
						if(!zipFile.exists()){
							zipFile.mkdirs();
						}
						fileName = new StringBuilder().append(reqName)
								.append(CommonConst.REPLACE_CHAR)
								.append(reqId)
								.toString();
						flag = fileToZip(sourceFilePath, zipFilePath, fileName);
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
										.append(fileName)
										.append(".zip")
										.toString()
									);		
						}
					}
				}
			}
		}

		if((bsa!=null)&&(bsa.length()!=0)&&(!appsys_code.equals(""))&&(appsys_code.length()!=0)){
			if(bsa.equals("1")){
				if(ComUtil.isWindows){
					sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.bsaZipPackagePath"))
							.append(File.separator)
							.toString();

				}else{
					sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.bsaZipPackagePathForLinux"))
							.append(File.separator)
							.toString();
				}
				sourceFile = new File(sourceFilePath);
				if(!sourceFile.exists()){
					sourceFile.mkdirs();
				}
				
				deleteBsaFile(appsys_code);
				exportBsa(appsys_code);
				exportFtp(
						new StringBuilder().append(sourceFilePath)
							.append(appsys_code)
							.append(".tar")
							.toString()
						,appsys_code
						);
				ftpPutFileServer(
						new StringBuilder().append(sourceFilePath)
							.append(appsys_code)
							.append(".tar")
							.toString()
						,appsys_code
						,"bsa"
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
							.toString();
					paramFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(messages.getMessage("systemServer.paramPackagePath"))
							.toString();
				}else{
					paramFileLocalPath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.paramFilePathForLinux"))
							.toString();
					paramFilePath = new StringBuilder().append(System.getProperty("maop.root"))
							.append(File.separator)
							.append(messages.getMessage("systemServer.paramPackagePathForLinux"))
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
	 * 数据写入到文件中.
	 * 
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void exportFile(String xmlFile,String fileName,String appsys_code) throws UnsupportedEncodingException, FileNotFoundException{
		String filePath = null;
		if(ComUtil.isWindows){
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(messages.getMessage("systemServer.brpmFilePath"))
					.append(File.separator)
					.append(appsys_code)
					.toString();
		}else{
			filePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append(messages.getMessage("systemServer.brpmFilePathForLinux"))
					.append(File.separator)
					.append(appsys_code)
					.toString();
		}
		File file = new File(filePath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new StringBuilder().append(filePath).append(File.separator).append(fileName).toString()),"utf-8"));
		out.println(xmlFile);
		out.flush();
		out.close();
	}

	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void exportParamFile(String xmlFile,String fileName,String appsys_code) throws UnsupportedEncodingException, FileNotFoundException{
			String filePath = null;
			if(ComUtil.isWindows){
				filePath = new StringBuilder().append(System.getProperty("maop.root"))
						.append(messages.getMessage("systemServer.paramFilePath"))
						.append(File.separator)
						.append(appsys_code)
						.toString();
			}else{
				filePath = new StringBuilder().append(System.getProperty("maop.root"))
						.append(File.separator)
						.append(messages.getMessage("systemServer.paramFilePathForLinux"))
						.append(File.separator)
						.append(appsys_code)
						.toString();
			}
			File file = new File(filePath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new StringBuilder().append(filePath).append(File.separator).append(fileName).toString()),"utf-8"));
			out.println(xmlFile);
			out.flush();
			out.close();
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
						);//先删除文件夹里面的文件			}
		}		
	}
	
	/**
	 * 删除指定文件
	 * 
	 * @param path String 文件夹路径	 */
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
	public Object getRequest(String appsys_code) throws ParseException, IOException, BrpmInvocationException, URISyntaxException,HttpHostConnectException,Exception {

		List<String> reqNameList =  new ArrayList<String>();
		List<Map<String ,String>>  jsonMapList = new ArrayList<Map<String,String>>();
		Map<String,String> reqMap = new HashMap<String,String>();
		{
			String reqId=new String();
			String reqName=new String();
			String reqUpdateDate =new String();
			String sql = "select SUB_ITEM_VALUE from jeda_sub_item where ITEM_ID='REQUEST_MAX_DAY' and SUB_ITEM_CASCADE=0";
			Query query = getSession().createSQLQuery(sql.toString());
			Long day = new Long(query.uniqueResult().toString());
			long DAY_MILLISECOND = 24*60*60*1000;
			List<Object[]> lis = brpmService.getRequests();
			int endStats;
			if(appsys_code != null && !"".equals(appsys_code)){
				Date nowdate = new Date();
				SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd",Locale.CHINA);
				for (Object[] str :lis) {
					reqId = String.valueOf(str[0]);
					reqName = String.valueOf(str[1]);
					reqUpdateDate = String.valueOf(str[2]);
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
	 * bsa导出
	 * @param String appsys_code
	 * @throws AxisFault
	 * @throws Exception 
	 */
	public void exportBsa(String appsys_code) throws AxisFault,Exception  {
		String objectType = null;
		String jobType = null;
		if(appsys_code != null && !"".equals(appsys_code)){
			LoginServiceClient client = new LoginServiceClient();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliTunnelServiceClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse executeCommandByParamListResponse = null;
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString()});
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString()});
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString(),"",messages.getMessage("bsa.moveJobPath"),messages.getMessage("bsa.exportJob"),messages.getMessage("bsa.ipAddress"),"3"});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String DBkeyCreatExportJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString(),"",messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(".nsh").toString(),messages.getMessage("bsa.ipAddress"),"2"});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String DBkeyCreatZipJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("JobGroup", "findAllGroupsByParentGroupName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(appsys_code).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String serFolder=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			String[] JobFolder = serFolder.split("\n");
			executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString()});
			cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
			String DBkey1=(String) executeCommandByParamListResponse.get_return().getReturnValue();
			for(int i=0;i<JobFolder.length;i++){
				if(JobFolder[i].equals("TOOLS")){
					continue;
				}
				if(JobFolder[i].length()>5&&JobFolder[i].substring(0,6).equals("BAK201")){
					continue;
				}
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("Job", "listAllByGroup", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder[i]).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String serJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				String[] JobName = serJob.split("\n");
				
				for(int j=0;j<JobName.length;j++){
					
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("DeployJob", "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder[i]).toString(),JobName[j]});
					String DeployJobDBkey=(String) executeCommandByParamListResponse.get_return().getReturnValue();
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder[i]).toString(),JobName[j]});
					String NSHScriptJob=(String) executeCommandByParamListResponse.get_return().getReturnValue();
					
					if(DeployJobDBkey.equals("void")&&NSHScriptJob.equals("void")){
						break;
					}else if(!DeployJobDBkey.equals("void")){
						objectType = "30";
						jobType = "DeployJob";
					}else if(!NSHScriptJob.equals("void")){
						objectType = "111";
						jobType = "NSHScriptJob";
					}
					
					
					//执行导出作业
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList(jobType, "getDBKeyByGroupAndName", new String[]{new StringBuilder().append(messages.getMessage("bsa.deployPath")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder[i]).toString(),JobName[j]});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					String DBkey2=(String) executeCommandByParamListResponse.get_return().getReturnValue();
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString(),"0",objectType});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString(),"1",DBkey2});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
									
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString(),"2",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).append(appsys_code).append(messages.getMessage("path.linux")).append(JobFolder[i]).append(messages.getMessage("path.linux")).append(JobName[j]).toString()});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					
					executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{DBkey1});
					cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
					String Export=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				}
			}
			
			if(JobFolder.length != 0){
				//生成临时打包作业并执行				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				String dBkeyZip=(String) executeCommandByParamListResponse.get_return().getReturnValue();
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString(),"0",new StringBuilder().append(messages.getMessage("bsa.fileServerIp")).append(messages.getMessage("bsa.moveFilePath")).append(messages.getMessage("path.linux")).append(messages.getMessage("bsa.dplyPath")).append(messages.getMessage("path.linux")).toString()});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString(),"1",appsys_code});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyZip});
				cliTunnelServiceClient.ResponseCheck4ExecuteCommand(executeCommandByParamListResponse);
				
				//删除临时导出作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.exportJob")).append(appsys_code).toString()});
				//删除临时打包作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.zipJob")).append(appsys_code).toString()});
				//删除临时删除作业
				executeCommandByParamListResponse = cliTunnelServiceClient.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("bsa.moveJobPath"),new StringBuilder().append(messages.getMessage("bsa.deleteJob")).append(appsys_code).toString()});
				
			}
		}
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * @param String userId
	 * @return Object
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesByUser(String userId){
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
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
					.list();
	}
}

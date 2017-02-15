package com.nantian.dply.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFComment;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.util.Assert;
import org.xml.sax.InputSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.dply.DplyConstants;
import com.nantian.dply.vo.DplyParamInfoVo;
import com.nantian.dply.vo.DplyRequestInfoVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.config.service.ItemService;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;

@Service
public class DplyRequestInfoService{
	
    public Map<String, String> fields = new HashMap<String, String>();
    
    private Map<String, String> reqNameIdMap = new HashMap<String, String>();
   	
   	/** 日志输出 */
   	final Logger logger = LoggerFactory.getLogger(DplyRequestInfoService.class);
    @Autowired
    private BrpmService brpmService;
    
    @Autowired
    private AppInfoService appInfoService;
    
    /** 国际化资源 */
    @Autowired
    private MessageSourceAccessor messages;
    @Autowired
	private NshJobService nshJobService;
    @Autowired
	private SecurityUtils securityUtils;
    @Autowired
	private UserService userService;
    /**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;

    public Session getSession() {
        return sessionFactory.getCurrentSession();
    }
    private Session getSession2(){
    	return sessionFactory.openSession();
    }
    /**
     * 构造方法.
     */
    public DplyRequestInfoService() {
        fields.put("appSysCode", FieldType.STRING);
        fields.put("environment", FieldType.STRING);
        fields.put("planDeployDate", FieldType.STRING);
        fields.put("deployCode", FieldType.STRING);
        fields.put("execStatus", FieldType.STRING);
        fields.put("trunSwitch", FieldType.STRING);
    }
    
    /**
     * 批量更新或保存


     * @param requestInfos
     */
    @Transactional
    public void saveOrUpdate(List<DplyRequestInfoVo> requestInfos){
    	for(int i = 0; i < requestInfos.size(); i++){
    		saveOrUpdate(requestInfos.get(i));
    	}
    }
    
    /**
     * 更新或保存


     * @param requestInfo
     */
    public void saveOrUpdate(DplyRequestInfoVo requestInfo){
    	getSession().saveOrUpdate(requestInfo);
    }
    
    /**
     * 查询发布请求信息
     * @param start 起始索引
	 * @param limit 每页至多显示的记录数
	 * @param sort  排序的字段


	 * @param dir 排序的方式


     * @param params 参数
     * @return
     */
    @Transactional(readOnly = true)
    public Object queryDplyRequestAuthorizeInfo(Integer start, Integer limit,
            String sort, String dir, Map<String, Object> params, HttpServletRequest request,String deployMonth,String requestStatus){
    	StringBuilder sql = new StringBuilder();
    	sql.append("select  o.appSysCode as \"appSysCode\",")
		.append("o.requestCode as \"requestCode\", ")
		.append(" o.planDeployDate as \"planDeployDate\", ")
		.append("o.deployCode as \"deployCode\", ")
		.append("o.requestName as \"requestName\", ")
		.append("o.environment as \"environment\", ")
		.append("o.trunSwitch as \"trunSwitch\", ")
		.append("o.execStatus as \"execStatus\", ")
		.append("o.planStartTime as \"planStartTime\", ")
		.append("o.planEndTime as \"planEndTime\", ")
		.append("o.realStartDate as \"realStartDate\", ")
		.append(" o.realEndDate as \"realEndDate\", ")
		.append(" o.requestStatus as \"requestStatus\" ")
		.append(" from (  ")
		.append(" select b.appsys_code as appSysCode,  ")
		.append(" b.request_code as requestCode,")
		.append(" b.environment as environment,")
		.append(" b.plan_deploy_date as planDeployDate,")
		.append(" b.deploy_code as deployCode,")
		.append(" b.request_name as requestName,")
		.append("   b.turn_switch as trunSwitch,  ")
		.append("  b.exec_status as execStatus,  ")
		.append("  b.plan_start_time as planStartTime,  ")
		.append("  b.plan_end_time as planEndTime,  ")
		.append("  b.real_start_date as realStartDate,  ")
		.append("  b.real_end_date as realEndDate,  ")
		.append("  substr(b.request_name,instr(b.request_name,'_',1,1)+1,instr(b.request_name,'_',1,2)-1-instr(b.request_name,'_',1,1))  as requestStatus ")
		.append(" from dply_request_info b) o where o.environment in :envList ");
    	
    	if(null==deployMonth  && null==params.get("planDeployDate") || null==deployMonth && "".equals(params.get("planDeployDate"))){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  to_char(sysdate,'yyyymm')||'%' ");
    	}
    	if(null!=deployMonth){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  '"+deployMonth+"%'");
    	}
    	if(null != requestStatus  && !"".equals(requestStatus)){
    		sql.append("and substr(o.requestName,instr(o.requestName,'_',1,1)+1,instr(o.requestName,'_',1,2)-1-instr(o.requestName,'_',1,1)) = '"+requestStatus+"' ");
    	}
    	
    	if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and o." + key + " like :" + key);
				} else {
					sql.append(" and o." + key + " = :" + key);
				}
			}
		}
    	
    	sql.append(" order by o." + sort + " " + dir);
		 
		Query query = getSession().createSQLQuery(sql.toString())
				.addScalar("appSysCode", StringType.INSTANCE)
				.addScalar("requestCode", StringType.INSTANCE)
				.addScalar("environment", StringType.INSTANCE)
				.addScalar("planDeployDate", StringType.INSTANCE)
				.addScalar("deployCode", StringType.INSTANCE)
				.addScalar("requestName", StringType.INSTANCE)
				.addScalar("trunSwitch", StringType.INSTANCE)
				.addScalar("execStatus", StringType.INSTANCE)
				.addScalar("planStartTime", StringType.INSTANCE)
				.addScalar("planEndTime", StringType.INSTANCE)
				.addScalar("realStartDate", TimestampType.INSTANCE)
				.addScalar("realEndDate", TimestampType.INSTANCE)
				.addScalar("requestStatus", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		query.setParameterList("envList", userService.getPersonalEnvs());
		
		request.getSession().setAttribute("dplyRequestInfo4ExportAuthorize", query.list());
		
        return query.setMaxResults(limit).setFirstResult(start).list();
    	
    }
    
    
    /**
     * 查询发布请求信息
     * @param start 起始索引
	 * @param limit 每页至多显示的记录数
	 * @param sort  排序的字段
     * @return
     */
    @Transactional(readOnly = true)
    public Object queryDplyRequestInfo(Integer start, Integer limit,
            String sort, String dir, Map<String, Object> params, HttpServletRequest request,String deployMonth,String requestStatus){
    	StringBuilder sql = new StringBuilder();
    	sql.append("select  o.appSysCode as \"appSysCode\",")
		.append("o.requestCode as \"requestCode\", ")
		.append(" o.planDeployDate as \"planDeployDate\", ")
		.append("o.deployCode as \"deployCode\", ")
		.append("o.requestName as \"requestName\", ")
		.append("o.environment as \"environment\", ")
		.append("o.trunSwitch as \"trunSwitch\", ")
		.append("o.execStatus as \"execStatus\", ")
		.append("o.planStartTime as \"planStartTime\", ")
		.append("o.planEndTime as \"planEndTime\", ")
		.append("o.realStartDate as \"realStartDate\", ")
		.append(" o.realEndDate as \"realEndDate\", ")
		.append(" o.autostart as \"autostart\", ")
		.append(" o.requestStatus as \"requestStatus\" ")
		.append(" from (  ")
		.append(" select b.appsys_code as appSysCode,  ")
		.append(" b.request_code as requestCode,")
		.append(" b.environment as environment,")
		.append(" b.plan_deploy_date as planDeployDate,")
		.append(" b.deploy_code as deployCode,")
		.append(" b.request_name as requestName,")
		.append("   b.turn_switch as trunSwitch,  ")
		.append("  b.exec_status as execStatus,  ")
		.append("  b.plan_start_time as planStartTime,  ")
		.append("  b.plan_end_time as planEndTime,  ")
		.append("  b.real_start_date as realStartDate,  ")
		.append("  b.real_end_date as realEndDate,  ")
		.append("  b.autostart as autostart,  ")
		.append("  substr(b.request_name,instr(b.request_name,'_',1,1)+1,instr(b.request_name,'_',1,2)-1-instr(b.request_name,'_',1,1))  as requestStatus ")
		.append(" from dply_request_info b) o where  o.appSysCode in :sysList and o.environment in :envList ");
    	
    	if(null==deployMonth  && null==params.get("planDeployDate") || null==deployMonth && "".equals(params.get("planDeployDate"))){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  to_char(sysdate,'yyyymm')||'%' ");
    	}
    	if(null!=deployMonth){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  '"+deployMonth+"%'");
    	}
    	if(null != requestStatus  && !"".equals(requestStatus)){
    		sql.append("and substr(o.requestName,instr(o.requestName,'_',1,1)+1,instr(o.requestName,'_',1,2)-1-instr(o.requestName,'_',1,1)) = '"+requestStatus+"' ");
    	}
    	
    	if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and o." + key + " like :" + key);
				} else {
					sql.append(" and o." + key + " = :" + key);
				}
			}
		}
    	
    	sql.append(" order by o." + sort + " " + dir);
		 
		Query query = getSession().createSQLQuery(sql.toString())
				.addScalar("appSysCode", StringType.INSTANCE)
				.addScalar("requestCode", StringType.INSTANCE)
				.addScalar("planDeployDate", StringType.INSTANCE)
				.addScalar("deployCode", StringType.INSTANCE)
				.addScalar("requestName", StringType.INSTANCE)
				.addScalar("environment", StringType.INSTANCE)
				.addScalar("trunSwitch", StringType.INSTANCE)
				.addScalar("execStatus", StringType.INSTANCE)
				.addScalar("planStartTime", StringType.INSTANCE)
				.addScalar("planEndTime", StringType.INSTANCE)
				.addScalar("realStartDate", TimestampType.INSTANCE)
				.addScalar("realEndDate", TimestampType.INSTANCE)
				.addScalar("requestStatus", StringType.INSTANCE)
				.addScalar("autostart", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		

		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		
		query.setParameterList("envList", userService.getPersonalEnvs());
		
		
		request.getSession().setAttribute("dplyRequestInfo4ExportOn", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
    	
    }
    
    /**
     * 查询
     * @param appSysCode
     * @param requestCode
     * @return
     */
    @Transactional(readOnly = true)
    public DplyRequestInfoVo queryDplyRequestInfo(String appSysCode, String requestCode, String environment){
    	return (DplyRequestInfoVo) getSession().createQuery(
    			"from DplyRequestInfoVo t where t.appSysCode = :appSysCode and t.requestCode = :requestCode and t.environment = :environment")
    																.setString("appSysCode", appSysCode)
											    					.setString("requestCode", requestCode)
											    					.setString("environment", environment)
											    					.uniqueResult();
    }

    /**
     * 批量更新启动开关.
     * @param appSysCodes
     * @param requestCodes
     * @throws JDOMException 
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     */
    @Transactional
	public void updateSwitchOn(String[] appSysCodes, String[] requestCodes, String[] environment)
			throws NoSuchMessageException, IOException,
			BrpmInvocationException, URISyntaxException, JDOMException {
		for(int i = 0; i < appSysCodes.length && i < requestCodes.length && i < environment.length; i++){
			updateSwitchOn(appSysCodes[i], requestCodes[i], environment[i]);
		}
		
	}

    /**
     * 批量更新启动开关.
     * @param appSysCodes
     * @param requestCodes
     * @throws JDOMException 
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     */
    @Transactional
	public void updateSwitchOff(String[] appSysCodes, String[] requestCodes, String[] environment)
			throws NoSuchMessageException, IOException,
			BrpmInvocationException, URISyntaxException, JDOMException {
		for(int i = 0; i < appSysCodes.length && i < requestCodes.length && i < environment.length; i++){
			updateSwitchOff(appSysCodes[i], requestCodes[i], environment[i]);
		}
		
	}
    
    /**
     * 更新启动开关.
     * @param appSysCode
     * @param requestCode
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     * @throws JDOMException 
     */
	private void updateSwitchOn(String appSysCode, String requestCode, String environment)
			throws NoSuchMessageException, IOException,
			BrpmInvocationException, URISyntaxException, JDOMException {
		String requestId = findReqIdByName(requestCode,environment);
		//请求更新为planned(可执行)状态

		
		String sql = "select t.autostart from dply_request_info t where t.appsys_code = '" + appSysCode + "' and t.request_code = '" + requestCode + "' and t.environment = '" + environment + "' ";
		Query query = getSession().createSQLQuery(sql.toString());
		String autostart = query.uniqueResult().toString();
		if(autostart!=null){
			if(autostart.equals("1")){
				brpmService.putMethod("requests", requestId, "<request><aasm_state>planned</aasm_state><notify_on_request_start>true</notify_on_request_start><auto_start>true</auto_start></request>");
			}else{
				brpmService.putMethod("requests", requestId, "<request><aasm_state>planned</aasm_state><notify_on_request_start>false</notify_on_request_start><auto_start>false</auto_start></request>");
			}
		}else{
			brpmService.putMethod("requests", requestId, "<request><aasm_state>planned</aasm_state><notify_on_request_start>false</notify_on_request_start><auto_start>false</auto_start></request>");
		}
		String result = brpmService.getMethodById("requests", requestId);
		StringReader reader = new StringReader(result);
		InputSource  source = new InputSource(reader);
		SAXBuilder sb = new SAXBuilder();
		Document doc = sb.build(source);
		Element root = doc.getRootElement();
		List<Element> stepsRoot = root.getChild("steps").getChildren();
		for(Element step: stepsRoot){
			if(!step.getChildText("aasm-state").equalsIgnoreCase("locked")){
				//步骤更新为locked(可执行)状态


				brpmService.putMethod("steps", step.getChildText("id"), "<step><aasm-state>locked</aasm-state></step>");
			}
		}
		
		getSession().createQuery(
				"update DplyRequestInfoVo t set t.trunSwitch = 1 where t.appSysCode=:appSysCode and t.requestCode = :requestCode and t.environment = :environment ")
						  .setString("appSysCode", appSysCode)
						  .setString("requestCode", requestCode)
						  .setString("environment", environment)
						  .executeUpdate();
	}

	/**
     * 更新启动开关.
     * @param appSysCodes
     * @param requestCodes
	 * @throws ParseException 
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     * @throws JDOMException 
     */
	public String checkStartTime(String appSysCode, String requestCode, String environment) throws ParseException {
		/*String sql = null;
		Query query = null;
		sql = "select plan_deploy_date as planDeployDate from dply_request_info t where t.appsys_code = '" + appSysCode + "' and t.request_code = '" + requestCode + "' and t.environment = '" + environment + "' ";
		query = getSession().createSQLQuery(sql.toString());
		String planDeployDate = query.uniqueResult().toString();*/

	/*	long DAY_MILLISECOND = 24*60*60*1000;
		String planDeployDate = query.uniqueResult().toString();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd",Locale.CHINA);
		boolean dateFlat = DateFunction.isDate(planDeployDate);
		if(dateFlat==true){
			Date planDeployDateMatter = matter.parse(planDeployDate);
			Date nowdate = new Date();
			if((planDeployDateMatter.getTime()-nowdate.getTime())/DAY_MILLISECOND<=-1){
				return "环境：" + environment + "，应用系统：" + appSysCode + "，请求：" + requestCode + "，排期日期小于当前日期，无法授权！";
			}else 	if((planDeployDateMatter.getTime()-nowdate.getTime())/DAY_MILLISECOND==0){
				
			}

			
		}*/
		
		/*sql = "select plan_start_time as planStartTime from dply_request_info t where t.appsys_code = '" + appSysCode + "' and t.request_code = '" + requestCode + "' and t.environment = '" + environment + "' ";
		query = getSession().createSQLQuery(sql.toString());
		String planStartTime = query.uniqueResult().toString();
		
		
		
		long planStart = DateFunction.convertStr2Date(planDeployDate+planStartTime, "yyyyMMdd HH:mm:ss").getTime();
		Timestamp planStartStamp = new Timestamp(planStart);*/
		
		DplyRequestInfoVo vo = queryDplyRequestInfo(appSysCode, requestCode, environment);
		String planDeployDate = vo.getPlanDeployDate().toString();
		String planStartTime = vo.getPlanStartTime().toString();
		long planStart = DateFunction.convertStr2Date(planDeployDate + " " + planStartTime, "yyyyMMdd HHmm").getTime();
		
		String nowStr = DateFunction.getSystemTime();
		long nowDate = DateFunction.convertStr2Date(nowStr, "yyyyMMddHHmmss").getTime();

		Timestamp planStartStamp = new Timestamp(planStart);
		Timestamp nowStamp = new Timestamp(nowDate);
		if(planStartStamp.getTime()<=nowStamp.getTime()){
			String envCN = environment.split("_")[1];
			if(envCN.equals("DEV")){
				envCN = "开发";
			}
			if(envCN.equals("QA")){
				envCN = "测试";
			}
			if(envCN.equals("PROV")){
				envCN = "验证";
			}
			if(envCN.equals("PROD")){
				envCN = "生产";
			}
			return envCN + "环境请求" + requestCode + "的排期时间早于当前系统时间，请重新排期！" + "</br>";
		}
		return "";
	}
	
	/**
     * 更新启动开关.
     * @param appSysCode
     * @param requestCode
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     * @throws JDOMException 
     */
	private void updateSwitchOff(String appSysCode, String requestCode, String environment)
			throws NoSuchMessageException, IOException,
			BrpmInvocationException, URISyntaxException, JDOMException {
		String requestId = findReqIdByName(requestCode,environment);
		//请求更新为planned(可执行)状态


		
		brpmService.putMethod("requests", requestId, "<request><scheduled_at></scheduled_at><target-completion-at></target-completion-at><aasm_state>created</aasm_state><notify_on_request_start>false</notify_on_request_start><auto_start>false</auto_start></request>");

		//brpmService.putMethod("requests", requestId, "<request><scheduled_at></scheduled_at><target-completion-at></target-completion-at><auto_start>false</auto_start><aasm_state>created</aasm_state></request>");
		String result = brpmService.getMethodById("requests", requestId);
		StringReader reader = new StringReader(result);
		InputSource  source = new InputSource(reader);
		SAXBuilder sb = new SAXBuilder();
		Document doc = sb.build(source);
		Element root = doc.getRootElement();
		List<Element> stepsRoot = root.getChild("steps").getChildren();
		for(Element step: stepsRoot){
			if(!step.getChildText("aasm-state").equalsIgnoreCase("locked")){
				//步骤更新为locked(可执行)状态



				brpmService.putMethod("steps", step.getChildText("id"), "<step><aasm-state>locked</aasm-state></step>");
			}
		}
		
		getSession().createQuery(
				"update DplyRequestInfoVo t set t.trunSwitch = null where t.appSysCode=:appSysCode and t.requestCode = :requestCode and t.environment = :environment ")
						  .setString("appSysCode", appSysCode)
						  .setString("requestCode", requestCode)
						  .setString("environment", environment)
						  .executeUpdate();
	}
	
	/**
	 * 通过请求编号查找请求ID
	 * @param requestCode
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException
	 */
/*	private String findReqIdByName(String requestCode) throws IOException,
			BrpmInvocationException, URISyntaxException {
		String requestXml = brpmService.getMethodByFilter("requests", "{\"filters\":{\"name\":\"" + requestCode + "\"}}");
		Assert.notNull(requestXml, messages.getMessage("message.invalid.requests"));
		Document doc = JDOMParserUtil.xmlParse(requestXml);
		Element root = doc.getRootElement();
		List<Element> accounts = root.getChildren();
		for (Element element : accounts) {
			if ((null == element.getChildText("deleted-at") || ("").equals(element.getChildText("deleted-at"))) 
					&& null == element.getChild("request-template") ) {
				return element.getChildText("id");
			}
		}
		throw new BrpmInvocationException("BRPM中找不到对应的请求");
	}*/

	/**
	 * 通过请求编号查找请求ID
	 * @param requestCode
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException
	 */
	public String findReqIdByName(String requestCode,String environment) throws IOException,
			BrpmInvocationException, URISyntaxException {
		String requestXml = brpmService.getMethodByFilter("requests", "{\"filters\":{\"name\":\"" + requestCode + "\"}}");
		Assert.notNull(requestXml, messages.getMessage("message.invalid.requests"));
		Document doc = JDOMParserUtil.xmlParse(requestXml);
		Element root = doc.getRootElement();
		List<Element> accounts = root.getChildren();
		for (Element element : accounts) {
			if ((null == element.getChildText("deleted-at") || ("").equals(element.getChildText("deleted-at"))) 
					&& null == element.getChild("request-template") && element.getChild("environment").getChildText("name").equals(environment)) {
				return element.getChildText("id");
			}
		}
		throw new BrpmInvocationException("BRPM中找不到对应的请求");
	}
	
	/**
	 * 更新排期的日期和时间
	 * @param dplyRequestInfoVo
	 * @throws IOException 
	 * @throws JDOMException 
	 * @throws URISyntaxException 
	 * @throws NoSuchMessageException 
	 */
	public void updateArrange(DplyRequestInfoVo dplyRequestInfoVo)
			throws BrpmInvocationException, IOException, JDOMException,
			NoSuchMessageException, URISyntaxException {
		String requestId = findReqIdByName(dplyRequestInfoVo.getRequestCode(),dplyRequestInfoVo.getEnvironment());	
		brpmService.putMethod("requests", 
				requestId, 
				"<request><scheduled_at>"
					+ dplyRequestInfoVo.getPlanDeployDate()
					+ " " 
					+ dplyRequestInfoVo.getPlanStartTime()
					+ "</scheduled_at><target-completion-at>" 
					+ dplyRequestInfoVo.getPlanDeployDate()
					+ " " 
					+ dplyRequestInfoVo.getPlanEndTime()
					+ "</target-completion-at>" 
					+ "</request>");
		
		if(null != dplyRequestInfoVo.getAutostart() && dplyRequestInfoVo.getAutostart().equals("true")){
			dplyRequestInfoVo.setAutostart("1");
		}else {
			dplyRequestInfoVo.setAutostart("0");
		}
		
		update(dplyRequestInfoVo);
	}
	
	/**
	 * 更新
	 * @param vo
	 * @return
	 */
	@Transactional
	public int update(DplyRequestInfoVo vo){
		StringBuilder sql = new StringBuilder();
		sql.append("update DplyRequestInfoVo t ")
			.append("set t.planDeployDate = :planDeployDate, ")
			.append("	   t.deployCode = :deployCode, ")
			.append("	   t.planStartTime = :planStartTime, ")
			.append("	   t.planEndTime = :planEndTime, ")
			.append("	   t.autostart = :autostart ")
			.append("where t.appSysCode = :appSysCode ")
			.append("	and t.requestCode = :requestCode ")
			.append("	and t.environment = :environment ");
		
		return getSession().createQuery(sql.toString()).setProperties(vo).executeUpdate();
	}
	
	/**
	 * 更新属性类实例的参数值


	 * @param instancePath 实例路径
	 * @param propsValues 属性值键值对
	 * @param appSysCode 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor=Exception.class)
	public void updatePropInstance(String propsValues, String appSysCode) throws Exception {
		JSONArray array = JSONArray.fromObject(propsValues);
		List<Map<String, String>> list = (List<Map<String, String>>) JSONArray.toCollection(array, Map.class);
		
		LoginServiceClient client = LoginServiceClient.getInstance();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		DplyParamInfoVo vo=null;
		for(Map<String, String> map : list){
			cliClient.executeCommandByParamList("PropertyInstance", "setOverriddenValue", 
					new String[]{map.get("instPath"), map.get("property"), map.get("value")});
		}
		for(Map<String, String> map1 : list){
			if(!("").equals(map1.get("flag")) && null!=map1.get("flag")){
				vo = new DplyParamInfoVo();
				vo.setAppsysCode(appSysCode);
				vo.setInstanceValue(map1.get("instPath"));
				vo.setDplyParamCode(map1.get("name"));
				vo.setImportanceLevel(map1.get("flag"));
				getSession().saveOrUpdate(vo);
			}
		}
	}

	
	/**
     *请求执行时间验证
     * @param appSysCodes
     * @param requestCodes
	 * @throws environment 
     * @throws URISyntaxException 
     * @throws BrpmInvocationException 
     * @throws IOException 
     * @throws NoSuchMessageException 
     * @throws JDOMException 
     */
	public String checkStartTime2(String appSysCode, String requestCode, String environment) throws ParseException {
		
		
		DplyRequestInfoVo vo = queryDplyRequestInfo(appSysCode, requestCode, environment);
		String planDeployDate = vo.getPlanDeployDate().toString();
		String planStartTime = vo.getPlanStartTime().toString();
		long planStart = DateFunction.convertStr2Date(planDeployDate + " " + planStartTime, "yyyyMMdd HHmm").getTime();
		
		String nowStr = DateFunction.getSystemTime();
		long nowDate = DateFunction.convertStr2Date(nowStr, "yyyyMMddHHmmss").getTime();

		Timestamp planStartStamp = new Timestamp(planStart);
		Timestamp nowStamp = new Timestamp(nowDate);
		if(planStartStamp.getTime()>nowStamp.getTime()){
			String envCN = environment.split("_")[1];
			if(envCN.equals("DEV")){
				envCN = "开发";
			}
			if(envCN.equals("QA")){
				envCN = "测试";    
			}
			if(envCN.equals("PROV")){
				envCN = "验证";
			}
			if(envCN.equals("PROD")){
				envCN = "生产";
			}
			return envCN + "环境请求" + requestCode + "还未到排期开始时间("+planStartTime+")，请耐心等待！" + "</br>";
		}
		return "";
	}
	/**
	 * 执行请求
	 * @param appSysCodes
	 * @param requestCodes
	 * @throws IOException
	 */
	@Transactional
	public int executeRequests(String[] appSysCodes, String[] requestCodes, String[] environment) throws Exception {
		int success = 0;
		StringBuilder hql = new StringBuilder();
		hql.append("update DplyRequestInfoVo t ")
			.append("set t.execStatus = :execStatus ")
			.append("where t.appSysCode = :appSysCode ")
			.append("	and t.requestCode = :requestCode ")
			.append("	and t.environment = :environment ");
		
		for(int i = 0; i < appSysCodes.length && i < requestCodes.length && i < environment.length; i++){
			String requestId = findReqIdByName(requestCodes[i], environment[i]);
			if(requestId != null){
				brpmService.putMethod("requests", requestId, "<request><aasm_event>start</aasm_event></request>");
				getSession().createQuery(hql.toString()).setString("execStatus", "3")
								  .setString("appSysCode", appSysCodes[i])
								  .setString("requestCode", requestCodes[i])
								  .setString("environment", environment[i])
								  .executeUpdate();
				success ++;
			}
		}
		
		return success;
	}

	/**
	 * 获取当前用户创建的计划发布时间范围内的请求.
	 * @param user 用户
	 * @param plannedStartDate 计划发布时间下限, MM/dd/yyyy格式
	 * @param plannedEndDate 计划发布时间上限, MM/dd/yyyy格式
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws JDOMException
	 * @throws NoSuchMessageException
	 * @throws URISyntaxException
	 */
	private void getRequestMapping(String user, String plannedStartDate,
			String plannedEndDate) throws BrpmInvocationException, IOException,
			JDOMException, NoSuchMessageException, URISyntaxException {
		reqNameIdMap.clear();
		String userfilter = "{\"filters\":{\"first_name\" : \"" + user + "\"}}";
		String usrResponseXml = brpmService.getMethodByFilter("users", userfilter);
		
		List<String> envlist = userService.getPersonalEnvs();
		String env = null;
		if(usrResponseXml != null){
			StringReader reader = new StringReader(usrResponseXml);
			InputSource  source = new InputSource(reader);
			SAXBuilder sb = new SAXBuilder();
			Document doc = null;
			doc = sb.build(source);
			
			Element root = doc.getRootElement();
			if(root.getChildren().size() == 1){
				String userId = root.getChildren().get(0).getChildText("id");
				//请求的时间段过滤器, 已经排期的请求的日期范围
				//这里取的时间范围
				String filter = "{\"filters\":{\"owner_id\" : \"" + userId + "\", \"planned_start_date\":\""
						+ plannedStartDate + "\", \"planned_end_date\":\""
						+ plannedEndDate + "\"}}";
				String responseXml = brpmService.getMethodByFilter("requests", filter);
				if(responseXml != null){
					reader = new StringReader(responseXml);
					 source = new InputSource(reader);
					sb = new SAXBuilder();
					doc = null;
					doc = sb.build(source);
					
					root = doc.getRootElement();
					for(Element child: root.getChildren()){
						env=child.getChild("environment").getChildText("name");
						if (null != env || ("").equals(env)){
							for(String envs:envlist){
								if(env.equals(envs)){
									if ((null == child.getChildText("deleted-at") || ("").equals(child.getChildText("deleted-at"))) 
											&& null == child.getChild("request-template") ) {
									reqNameIdMap.put(child.getChildText("name")+"|+|"+child.getChildText("id"), child.getChildText("id"));
									}
									break;
								}
							}
						}
						
					}
				}
			}
		}
	}

	/**
	 * 获取某系统下的所有实例的属性和值.
	 * @param appSysCode 系统编号
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> getAllPropertyAndValues(String appSysCode,String env) throws Exception{
		List<Map<String, Object>> dataList = new ArrayList<Map<String, Object>>();
		LoginServiceClient client = LoginServiceClient.getInstance();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		int count = 0;
		//获取所有子类名
		ExecuteCommandByParamListResponse cmdReponse = 
				cliClient.executeCommandByParamList("PropertyClass", "listAllSubclassNames", 
						new String[]{DplyConstants.PARAMSMETER_CLASS_PREFIX + appSysCode });
		String[] subClasses = cmdReponse.get_return().getReturnValue().toString().split("\n");
		if(!subClasses[0].equalsIgnoreCase("void")){
			for(String subClass : subClasses){
				Map<String, Object> subMap = new HashMap<String, Object>();
				subMap.put("mixColumn", subClass);
				subMap.put("name", subClass.substring(subClass.lastIndexOf("/") + 1));
				subMap.put("_id", ++count);
				
				//获取子类下所有的属性				
				ExecuteCommandByParamListResponse propResponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNames", 
								new String[]{subClass});
				String propReturnVal = propResponse.get_return().getReturnValue().toString();
				String [] properties = propReturnVal.split("\n");
				Map<String, String> editableMap = new HashMap<String, String>();
				for(String prop : properties){
					ExecuteCommandByParamListResponse editableRes = 
							cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", 
									new String[]{subClass, prop});
					editableMap.put(prop, editableRes.get_return().getReturnValue().toString());
				}
				//获取子类所有的对象实例
				ExecuteCommandByParamListResponse subInstReponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllInstanceNames", 
								new String[]{subClass});
				String retVal = subInstReponse.get_return().getReturnValue().toString();
				if(retVal.equalsIgnoreCase("void")){
					subMap.put("_is_leaf", true);
					dataList.add(subMap);
				}else{
					dataList.add(subMap);
					String [] instances = subInstReponse.get_return().getReturnValue().toString().split("\n");
					Boolean b = false ;
					for(String instPath : instances){
						//只显示对应环境的实例及其相关属性
						if(instPath.indexOf(env)>0){ //eg:instPath=Class://SystemObject/CLASS_QCT/WEB/OBJ_PROV_QCT_WEB_01
							b = true ;
							Map<String, Object> subInstMap = new HashMap<String, Object>();
							subInstMap.put("mixColumn", instPath);
							subInstMap.put("name", instPath.substring(instPath.lastIndexOf("/") + 1));
							subInstMap.put("_id", ++count);
							subInstMap.put("_is_leaf", false);
							subInstMap.put("_parent", subMap.get("_id"));
							dataList.add(subInstMap);
							
							StringBuilder sql = new StringBuilder();
							sql.append("select t.sub_item_name from  jeda_sub_item t where t.item_id='DPLY_FILTER_PARAMS'" );
							Query query1 = getSession().createSQLQuery(sql.toString());
							List<String> filterParam=(List<String>) query1.list();		
							
							//获取子类实例下所有的属性和值						
							ExecuteCommandByParamListResponse instResponse = 
									cliClient.executeCommandByParamList("PropertyInstance", "listAllPropertyValues", 
											new String[]{instPath});
							String instReturnVal = instResponse.get_return().getReturnValue().toString();
							String [] instProperties = instReturnVal.split("\n");
							for(String inst : instProperties){
								String[] paramVal = inst.split("=");
								if( editableMap.get(paramVal[0].trim()) != null  && editableMap.get(paramVal[0].trim()).equalsIgnoreCase("true") 
										&& !filterParam.contains(paramVal[0].trim())){
									Map<String, Object> subInstPVMap = new HashMap<String, Object>();
									subInstPVMap.put("_id", ++count);
									subInstPVMap.put("_is_leaf", true);
									
									StringBuilder paramSql = new StringBuilder();
									paramSql.append("select  t.importance_level from dply_param_info t where t.dply_param_code='"+paramVal[0].trim()+"' and t.instance_value ='"+instPath+"' and t.appsys_code ='"+appSysCode+"'" );
									Query paramQuery = getSession().createSQLQuery(paramSql.toString());
									List<String> param=(List<String>) paramQuery.list();		
									if(param.size()>0){
										if(param.get(0).equals("是")){
											subInstPVMap.put("name", paramVal[0].trim());
											subInstPVMap.put("value", paramVal[1].trim());
											subInstPVMap.put("flag",param.get(0));
										}else{
											subInstPVMap.put("name", paramVal[0].trim());
											subInstPVMap.put("value", paramVal[1].trim());
											subInstPVMap.put("flag",param.get(0));
										}
									}else{
										subInstPVMap.put("name", paramVal[0].trim());
										subInstPVMap.put("value", paramVal[1].trim());
										subInstPVMap.put("flag","");
									}
									
									
									subInstPVMap.put("_parent", subInstMap.get("_id"));
									subInstPVMap.put("mixColumn", paramVal[0].trim());
									subInstPVMap.put("property", paramVal[0].trim());
									subInstPVMap.put("instPath", instPath);
									dataList.add(subInstPVMap);
								}
							}
						}
					}
					if(b){
						subMap.put("_is_leaf", false);
					}else{
						subMap.put("_is_leaf", true);	
					}
				}
			}
		}
		return dataList;
	}

	/**
	 * 同步当前用户创建的BRPM发布请求信息.
	 * @param plannedStartDate 计划发布时间下限
	 * @param plannedEndDate 计划发布时间上限
	 * @return
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws JDOMException
	 * @throws ParseException
	 * @throws NoSuchMessageException
	 * @throws URISyntaxException
	 */
	@Transactional
	public String synBrpmCurMonthReqInfos(String plannedStartDate,
			String plannedEndDate) throws BrpmInvocationException, IOException,
			JDOMException, ParseException, NoSuchMessageException,
			URISyntaxException {
		List<DplyRequestInfoVo> requestInfos = new ArrayList<DplyRequestInfoVo>();
		//List<String> requestCodes = new ArrayList<String>();
		String requestCodes = "";
		DplyRequestInfoVo vo = null;
		String curUser = securityUtils.getUser().getUsername();
		plannedStartDate = DateFunction.getFormatDateStr(plannedStartDate, "yyyyMMdd", "MM/dd/yyyy");
		plannedEndDate = DateFunction.getFormatDateStr(plannedEndDate, "yyyyMMdd", "MM/dd/yyyy");
		getRequestMapping(curUser, plannedStartDate, plannedEndDate);
		String appSql = "select distinct appsys_code from v_cmn_app_info";
		Query query = getSession().createSQLQuery(appSql.toString());
		List applist = query.list();
		String requestNameError = "";
		for(String key : reqNameIdMap.keySet()){
			String result = brpmService.getMethodById("requests", reqNameIdMap.get(key));
			StringReader reader = new StringReader(result);
			InputSource  source = new InputSource(reader);
			SAXBuilder sb = new SAXBuilder();
			Document doc = null;
			doc = sb.build(source);
			
			Element root = doc.getRootElement();
			String requestName = root.getChildText("name");
			
			String[] requestNameCheck = requestName.split("_");
			
			if(requestNameCheck.length<4){
				requestNameError += requestName + ",";
				continue;
			}else if (!(requestNameCheck[1].equals("REQ")||requestNameCheck[1].equals("REQRST"))){
				requestNameError += requestName + ",";
				continue;
			}else if(!DateFunction.isDate(requestNameCheck[2])){
				requestNameError += requestName + ",";
				continue;
			}
			
			String environment = "";
			String appSysCode = "";
			String executeStatus = "";
			String planStartTime = "";
			String planEndTime = "";
			String execDate = "";
			Timestamp startTimeStamp = null;
			Timestamp endTimeStamp = null;
			boolean appSysCodeFlag = false;
			if(requestName.indexOf("_") != -1){
				appSysCode = requestName.substring(0, requestName.indexOf("_"));
				for(int i=0;i<applist.size();i++){
					if(appSysCode.equals(applist.get(i).toString())){
						appSysCodeFlag = true;break;
					}
				}
			}else{
				requestNameError += requestName + ",";
				continue;
			}
			if(appSysCodeFlag == false){
				requestNameError += requestName + ",";
				continue;
			}
			
			
			switch(DplyConstants.requestStateItem.getRequestState(root.getChildText("aasm-state"))){
				case created:
				case planned:
					executeStatus = "1";
					break;
				case started:
					executeStatus = "3";
					break;
				case cancelled:
				case hold:
					executeStatus = "2";
					break;
				case complete:
					executeStatus = "4";
					break;
				case problem:
					executeStatus = "5";
					break;
				case deleted:
					executeStatus = "0";
					break;
			}
			
			if(!root.getChild("environment").getChildText("name").equals("")){
				environment = root.getChild("environment").getChildText("name");
			}
			
			if(!root.getChildText("planned-at").equals("")){
				planStartTime = root.getChildText("planned-at").substring(11, 16).replaceAll(":", "");
				execDate = root.getChildText("planned-at").substring(0, 10).replaceAll("-", "");
			}
			
			if(!root.getChildText("target-completion-at").equals("")){
				planEndTime = root.getChildText("target-completion-at").substring(11, 16).replaceAll(":", "");
			}
			
			if(!root.getChildText("started-at").equals("")){
				String startDateTime = root.getChildText("started-at");
				startDateTime = startDateTime.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
				long startTime = DateFunction.convertStr2Date(startDateTime, "yyyyMMdd HH:mm:ss").getTime();
				startTimeStamp = new Timestamp(startTime);
			}
			
			if(!root.getChildText("completed-at").equals("")){
				String endDateTime = root.getChildText("completed-at");
				endDateTime = endDateTime.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
				long endTime = DateFunction.convertStr2Date(endDateTime, "yyyyMMdd HH:mm:ss").getTime();
				endTimeStamp = new Timestamp(endTime);
			}
			
			vo = new DplyRequestInfoVo();
			vo.setAppSysCode(appSysCode);
			vo.setRequestCode(requestName);
			vo.setRequestName(requestName);
			vo.setEnvironment(environment);
			vo.setDescribe(root.getChildText("description"));
			vo.setExecStatus(executeStatus);
			vo.setPlanDeployDate(execDate);
			vo.setPlanStartTime(planStartTime);
			vo.setPlanEndTime(planEndTime);
			vo.setRealStartDate(startTimeStamp);
			vo.setRealEndDate(endTimeStamp);
			/*vo.setExportUser("");
			vo.setImportUser("");*/
			DplyRequestInfoVo existVo = queryDplyRequestInfo(appSysCode, requestName, environment);
			if(existVo != null){
				vo.setDeployCode(existVo.getDeployCode());
				vo.setExportUser(existVo.getExportUser());
				vo.setImportUser(existVo.getImportUser());
				vo.setExecStatus(existVo.getExecStatus());
				vo.setTrunSwitch(existVo.getTrunSwitch());
			}
			getSession().evict(existVo);
			requestInfos.add(vo);
			//requestCodes.add(vo.getRequestCode());
			requestCodes += vo.getRequestCode() + ",";
		}
		
		saveOrUpdate(requestInfos);
		if(!requestCodes.equals("")){
			requestCodes = "</br>已同步成功的请求：</br>[" + requestCodes.substring(0, requestCodes.length()-1) + "]";
		}else{
			requestCodes = "</br>已同步成功的请求：</br>[ ]";
		}
		if(!requestNameError.equals("")){
			requestNameError = requestNameError.substring(0, requestNameError.length()-1);
			requestCodes += "</br></br>命名不规范，未同步成功的请求：</br>[" + requestNameError + "]";
		}
		return requestCodes;
		
	}

	/**
	 * 系统发布参数导入
	 * @param filePath
	 * @param appSysCode
	 * @param size
	 * @param env
	 * @throws Exception
	 */
	public void importBsaParams(String filePath, String appSysCode, int size,String env) throws Exception  {
		File f = new File(filePath);
		InputStream in = null;
		try {
			in = new FileInputStream(f);
			HSSFWorkbook workbook = new HSSFWorkbook(in);
			HSSFSheet sheet = workbook.getSheetAt(0);
			HSSFRow row = null;
			HSSFCell subClassCell = null;
			HSSFCell instanceCell = null;
			HSSFCell paramCell = null;
			HSSFCell valueCell = null;
			int[] classIndex = new int[] {size + 1, size + 1, size + 1};
			int count = 0;
			int rows =	sheet.getPhysicalNumberOfRows();
			
			Assert.state(rows - 1 == size, messages.getMessage("message.rows.not.match"));
			
			for(int i = 1; i < size; i++) {
				row = sheet.getRow(i);
				subClassCell = row.getCell(0);
				if(subClassCell != null) {
					subClassCell.setCellType(HSSFCell.CELL_TYPE_STRING);
					if(!subClassCell.getStringCellValue().equals("")) {
						classIndex[count ++] = i;
					}
				}
			}
			
			LoginServiceClient client = LoginServiceClient.getInstance();
			LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
			CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			
			for(int i = 0; i < classIndex.length; i++) {
				if(classIndex[i] == 0 || classIndex[i] + 1 >= rows) break;
				row = sheet.getRow(classIndex[i]);
				subClassCell = row.getCell(0);
				Assert.state(subClassCell != null);
				String subClassPath = DplyConstants.PARAMSMETER_CLASS_PREFIX + appSysCode + "/" + subClassCell.getStringCellValue();
				String instance = "";
				int gapRow = i + 1 < classIndex.length ? classIndex[i + 1] : rows;
				
				for(int j = classIndex[i] + 2; j < gapRow; j++) {
				//eg:OBJ_PROV_QCT_WEB_01
				instanceCell = sheet.getRow(j - 1).getCell(1);
					paramCell = sheet.getRow(j).getCell(2);
					valueCell = sheet.getRow(j).getCell(3);
					if(instanceCell != null) {
						instanceCell.setCellType(HSSFCell.CELL_TYPE_STRING);
						if(!instanceCell.getStringCellValue().equals("")) {
							instance = instanceCell.getStringCellValue();
						}
					}
					if(paramCell != null) {
						paramCell.setCellType(HSSFCell.CELL_TYPE_STRING);
						String param = paramCell.getStringCellValue();
						if(!param.equals("")) {
							String value = "";
							if(valueCell != null) {
								valueCell.setCellType(HSSFCell.CELL_TYPE_STRING);
								value = valueCell.getStringCellValue();
							}
							//实例中包含当前环境时，执行导入
							if(instance.toString().indexOf(env)!=-1){
								cliClient.executeCommandByParamList("PropertyInstance", "setOverriddenValue", 
										new String[]{subClassPath + "/" + instance, param, value});
							}
						}
					}
				}
			}
		} catch (Exception e) {
			if(e instanceof NullPointerException) {
				throw new Exception(messages.getMessage("message.file.format.error"));
			}
			throw e;
		} finally {
			if(in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if(f.exists()) {
				f.delete();
			}
		}
	}

	/**
	 * 重置请求
	 * @param appSysCodes
	 * @param requestCodes
	 */
	@Transactional
	public void reopenRequests(String[] appSysCodes, String[] requestCodes, String[] environment) {
		for (int i = 0; i < appSysCodes.length && i < requestCodes.length && i < environment.length ; i++) {
			DplyRequestInfoVo vo = queryDplyRequestInfo(appSysCodes[i], requestCodes[i], environment[i]);
			vo.setTrunSwitch(null);
			vo.setExecStatus("1");
			vo.setRealStartDate(null);
			vo.setRealEndDate(null);
			saveOrUpdate(vo);
		}
	}
	/**
	 * 删除请求
	 * @param appSysCodes
	 * @param requestCodes
	 */
	public void deleteByIds(String[] appSysCds, String[] requestCodes) {
		for (int i = 0; i < appSysCds.length && i < requestCodes.length; i++) {
			deleteById(appSysCds[i], requestCodes[i]);
		}
	}
	/**
	 * 根据系统代码和请求编号删除.
	 * 
	 * @param appsysCode
	 * @param environmentCode
	 */
	private void deleteById(String appSysCd, String requestCode) {
		String sql = "delete dply_request_info where appsys_code = '"+appSysCd+"' and request_code = '"+requestCode+"'";
		getSession().createSQLQuery(sql).executeUpdate();
	}
	
	/**
	 * 查询登录用户关联应用系统信息列表
	 * 
	 * @param String userId
	 * 
	 * @return Object
	 */
/*	@Transactional//(readOnly = true)
	public Object queryEnv(String userId) {
		StringBuilder sql = new StringBuilder();
		sql.append("select c.environment_code as \"env\", j.sub_item_name ||'('|| c.environment_code||')'  as \"envName\" from cmn_environment c, jeda_sub_item j ,v_cmn_app_info s where exists (select * from cmn_user_app u  where s.appsys_code = u.appsys_code and c.appsys_code = u.appsys_code  and u.user_id = :userId )  and c.environment_type = j.sub_item_value and j.item_id='SYSTEM_ENVIRONMENT' and s.status = '使用中'");
		return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();		
	}*/
	
	 @Transactional//(readOnly = true)
	 public Object queryEnv(String userId) {
	  StringBuilder sql = new StringBuilder();
	  sql.append("select c.environment_code as \"env\", j.sub_item_name ||'('|| c.environment_code||')'  as \"envName\"" );
	  sql.append(" from cmn_environment c, jeda_sub_item j ,v_cmn_app_info s");
	  sql.append(" where exists (select * from cmn_user_app u " );
	  sql.append("where s.appsys_code = u.appsys_code and c.appsys_code = u.appsys_code  and c.appsys_code in :sysList");
	  sql.append(" and u.user_id = :userId )  and c.environment_type = j.sub_item_value and j.item_id='SYSTEM_ENVIRONMENT' and s.status = '使用中' and c.environment_code in :envList");
	  return getSession().createSQLQuery(sql.toString()).setString("userId", userId)
	    .setParameterList("envList", userService.getPersonalEnvs())
	    .setParameterList("sysList", appInfoService.getPersonalSysListForDply())
	    .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();  
	 }
	
	/**
	 * 获取某系统下的所有实例的属性和值.
	 * @param appSysCode 系统编号
	 * @return
	 * @throws Exception
	 */
	public String getAllProperty(String appSysCode,String env) throws Exception{
		//List<Map<String, Object>> dataList = new ArrayList<Map<String, Object>>();
		LoginServiceClient client = LoginServiceClient.getInstance();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		//int count = 0;
		
		String msg = "";
		String sub1Name = null;
		String sub2Name = null;
		String sub3Name = null;
		String sub3value = null;
		
		long DAY_MILLISECOND = 24*60*60*1000;
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd",Locale.CHINA);

		Date nowdate = new Date();
		Date yesterday = new Date(System.currentTimeMillis()-DAY_MILLISECOND);
		Date updateDateMatter = null;
		boolean dateFlat = true;
		
		//获取所有子类名
		ExecuteCommandByParamListResponse cmdReponse = 
				cliClient.executeCommandByParamList("PropertyClass", "listAllSubclassNames", 
						new String[]{DplyConstants.PARAMSMETER_CLASS_PREFIX + appSysCode });
		String[] subClasses = cmdReponse.get_return().getReturnValue().toString().split("\n");
		if(!subClasses[0].equalsIgnoreCase("void")){
			for(String subClass : subClasses){
				/*Map<String, Object> subMap = new HashMap<String, Object>();
				subMap.put("mixColumn", subClass);
				subMap.put("name", subClass.substring(subClass.lastIndexOf("/") + 1));
				subMap.put("_id", ++count);*/
				sub1Name = subClass.substring(subClass.lastIndexOf("/") + 1);
				//获取子类下所有的属性				
				ExecuteCommandByParamListResponse propResponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNames", 
								new String[]{subClass});
				String propReturnVal = propResponse.get_return().getReturnValue().toString();
				String [] properties = propReturnVal.split("\n");
				Map<String, String> editableMap = new HashMap<String, String>();
				for(String prop : properties){
					ExecuteCommandByParamListResponse editableRes = 
							cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", 
									new String[]{subClass, prop});
					editableMap.put(prop, editableRes.get_return().getReturnValue().toString());
				}
				//获取子类所有的对象实例
				ExecuteCommandByParamListResponse subInstReponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllInstanceNames", 
								new String[]{subClass});
				String retVal = subInstReponse.get_return().getReturnValue().toString();
				
				if(retVal.equalsIgnoreCase("void")){
					/*subMap.put("_is_leaf", true);
					dataList.add(subMap);*/
				}else{
					/*subMap.put("_is_leaf", false);
					dataList.add(subMap);*/
					String [] instances = subInstReponse.get_return().getReturnValue().toString().split("\n");
					for(String instPath : instances){
						/*Map<String, Object> subInstMap = new HashMap<String, Object>();
						subInstMap.put("mixColumn", instPath);
						subInstMap.put("name", instPath.substring(instPath.lastIndexOf("/") + 1));
						subInstMap.put("_id", ++count);
						subInstMap.put("_is_leaf", false);
						subInstMap.put("_parent", subMap.get("_id"));
						dataList.add(subInstMap);*/
						sub2Name = instPath.substring(instPath.lastIndexOf("/") + 1);
						
						String[] sub2 = sub2Name.split(CommonConst.UNDERLINE);//CommonConst.UNDERLINE
						if(sub2.length>3&&sub2[0].equals("OBJ")&&sub2[1].equals(env.split(CommonConst.UNDERLINE)[1])){
							//获取子类实例下所有的属性和值						
							ExecuteCommandByParamListResponse instResponse = 
									cliClient.executeCommandByParamList("PropertyInstance", "listAllPropertyValues", 
											new String[]{instPath});
							String instReturnVal = instResponse.get_return().getReturnValue().toString();
							String [] instProperties = instReturnVal.split("\n");
							for(String inst : instProperties){
								String[] paramVal = inst.split("=");
								if(editableMap.get(paramVal[0].trim()) != null 
										&& editableMap.get(paramVal[0].trim()).equalsIgnoreCase("true")){
									/*Map<String, Object> subInstPVMap = new HashMap<String, Object>();
									subInstPVMap.put("_id", ++count);
									subInstPVMap.put("_is_leaf", true);
									subInstPVMap.put("_parent", subInstMap.get("_id"));
									subInstPVMap.put("mixColumn", paramVal[0].trim());
									subInstPVMap.put("name", paramVal[0].trim());
									subInstPVMap.put("property", paramVal[0].trim());
									subInstPVMap.put("value", paramVal[1].trim());
									subInstPVMap.put("instPath", instPath);
									dataList.add(subInstPVMap);*/
									sub3Name = paramVal[0].trim();
									sub3value = paramVal[1].trim();
									if(sub3Name.equals(sub1Name+"_ExecPath")){
										if(sub3value.equals("")){
											msg += "</br>" + sub1Name + "->" + sub2Name + "->" + sub3Name + "值不能为空！";
										}
									}
									if(sub3Name.equals(sub1Name+"_AppUserGroup")){
										if(sub3value.equals("")){
											msg += "</br>" + sub1Name + "->" + sub2Name + "->" + sub3Name + "值不能为空！";
										}
									}
									if(sub3Name.equals(sub1Name+"_AppUser")){
										if(sub3value.equals("")){
											msg += "</br>" + sub1Name + "->" + sub2Name + "->" + sub3Name + "值不能为空！";
										}
									}
									if(sub3Name.equals("PUB_UpdateDate")){
										if(!sub3value.equals("")){
											dateFlat = DateFunction.isDate(sub3value);
											if(dateFlat==true){
												updateDateMatter = matter.parse(sub3value);
												if((updateDateMatter.getTime()-nowdate.getTime())/DAY_MILLISECOND<-1){
													msg += "</br>" + sub1Name + "->" + sub2Name + "->" + sub3Name + "日期范围不正确！(最小日期为：" + matter.format(yesterday).toString() + ")";
												}
											}else{
												msg += "</br>" + sub1Name + "->" + sub2Name + "->" + sub3Name + "日期格式不正确！(正确格式，例：" + matter.format(nowdate).toString() + ")";
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		String msg2 = "";
		if(msg.length()!=0){
			msg2 += "<font style=\"color:red;\">参数：</font>" + msg + "</br>";
		}
		return msg2;
	}
	
	public String getRequest4Servers(DplyRequestInfoVo dplyRequestInfoVo) throws Exception{
		String msg = "";
		
		String requestName = dplyRequestInfoVo.getRequestCode();
		String env = dplyRequestInfoVo.getEnvironment();
		String envCN = null;
		String stepId = null;
		String stepName = null;
		String stepXml = null;
		Document document = null;
		Element element = null;
		
		String componentId = null;
		String componentName = null;
		String componentXml = null;
		List<Element> accounts = null;
		List<Element> accounts2 = null;

		String componentNameHis = "";
		
		if(null != brpmService.checkRequest(requestName,env) && !("").equals(brpmService.checkRequest(requestName,env))){											
			String requestId = brpmService.checkRequest(requestName,env);
			List<Object[]> lisSteps = brpmService.getSteps(requestId);
			for (Object[] str :lisSteps) {
				if(String.valueOf(str[0])!=null){
					stepId = String.valueOf(str[0]);
					stepName = String.valueOf(str[1]);
					stepXml=brpmService.getMethodById(BrpmConstants.KEYWORD_STEPS, stepId);
					
					document = JDOMParserUtil.xmlParse(stepXml);
					element = document.getRootElement();

					if(element.getChild("component")!=null){
						componentId = element.getChild("component").getChildText("id");
						componentName = element.getChild("component").getChildText("name");
						
						if(componentNameHis.indexOf(componentName)==-1){
							componentNameHis += componentName + ",";
							
							componentXml=brpmService.getMethodById(BrpmConstants.KEYWORD_COMPONENTS, componentId);
							document = JDOMParserUtil.xmlParse(componentXml);
							element = document.getRootElement();
							accounts = element.getChild("installed-components").getChildren();

							for (Element account : accounts) {
								String envName = account.getChild("application-environment").getChild("environment").getChildText("name");
								if(envName.equals(env)){
									accounts2 = null;
									accounts2 = account.getChild("servers").getChildren();
									if(null==accounts2||accounts2.size()==0){
										
										envCN = env.split("_")[1];
										if(envCN.equals("DEV")){
											envCN = "开发";
										}
										if(envCN.equals("QA")){
											envCN = "测试";
										}
										if(envCN.equals("PROV")){
											envCN = "验证";
										}
										if(envCN.equals("PROD")){
											envCN = "生产";
										}
										msg += "</br>" + componentName + "在" + envCN + "环境中未关联服务器！";
									}
								}
							}
						}
					}
				}
			}
		}
		String msg2 = "";
		if(msg.length()!=0){
			msg2 += "<font style=\"color:red;\">组件：</font>" + msg + "</br>";
		}
		return msg2;
	}
	
	/**
	 * 获取某系统下的所有实例的属性和值.
	 * @param appSysCode 系统编号
	 * @return
	 * @throws Exception
	 */
	public String getAllProperty2File(String appSysCode,String filePath) throws Exception{
		
		LoginServiceClient client = LoginServiceClient.getInstance();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
		
		String sub1Name = null;
		String sub2Name = null;
		String sub3Name = null;
		String sub3value = null;
		StringBuilder msg = null;
		
		
		//获取所有子类名
		ExecuteCommandByParamListResponse cmdReponse = 
				cliClient.executeCommandByParamList("PropertyClass", "listAllSubclassNames", 
						new String[]{DplyConstants.PARAMSMETER_CLASS_PREFIX + appSysCode });
		String[] subClasses = cmdReponse.get_return().getReturnValue().toString().split("\n");
		if(!subClasses[0].equalsIgnoreCase("void")){
			for(String subClass : subClasses){
				
				sub1Name = subClass.substring(subClass.lastIndexOf("/") + 1);
				//获取子类下所有的属性				
				ExecuteCommandByParamListResponse propResponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllPropertyNames", 
								new String[]{subClass});
				String propReturnVal = propResponse.get_return().getReturnValue().toString();
				String [] properties = propReturnVal.split("\n");
				Map<String, String> editableMap = new HashMap<String, String>();
				for(String prop : properties){
					ExecuteCommandByParamListResponse editableRes = 
							cliClient.executeCommandByParamList("PropertyClass", "getIsEditable", 
									new String[]{subClass, prop});
					editableMap.put(prop, editableRes.get_return().getReturnValue().toString());
				}
				//获取子类所有的对象实例
				ExecuteCommandByParamListResponse subInstReponse = 
						cliClient.executeCommandByParamList("PropertyClass", "listAllInstanceNames", 
								new String[]{subClass});
				String retVal = subInstReponse.get_return().getReturnValue().toString();
				
				if(retVal.equalsIgnoreCase("void")){
					
				}else{
					
					String [] instances = subInstReponse.get_return().getReturnValue().toString().split("\n");
					for(String instPath : instances){
						
						sub2Name = instPath.substring(instPath.lastIndexOf("/") + 1);
						msg = new StringBuilder();
						//获取子类实例下所有的属性和值						
						ExecuteCommandByParamListResponse instResponse = 
								cliClient.executeCommandByParamList("PropertyInstance", "listAllPropertyValues", 
										new String[]{instPath});
						String instReturnVal = instResponse.get_return().getReturnValue().toString();
						String [] instProperties = instReturnVal.split("\n");
						//实例属性map
						Map<String,String> propertyMap = new HashMap<String,String>();
						for(String inst : instProperties){
							String[] paramVal = inst.split("=");
							if(editableMap.get(paramVal[0].trim()) != null 
									&& editableMap.get(paramVal[0].trim()).equalsIgnoreCase("true")){
								propertyMap.put(paramVal[0].trim(), paramVal[1].trim());
							}
						}
						//遍历实例属性，拼写sh文件
						for(String inst : instProperties){
							String[] paramVal = inst.split("=");
							if(editableMap.get(paramVal[0].trim()) != null 
									&& editableMap.get(paramVal[0].trim()).equalsIgnoreCase("true")){
								sub3Name = paramVal[0].trim();
								//递归替换paramVal[1].trim()中的引用变量
								sub3value = replaceQuoteProperty(propertyMap , paramVal[1].trim());
								msg.append("export ").append(sub3Name).append("=\"").append(sub3value).append("\"").append("\n");
							}
						}
						msg.append("sh $1").append("\n").append("exit 0");
						exportFile(msg.toString(), sub2Name+".sh", appSysCode,filePath);
					}
				}
			}
		}
		return "";
	}
	
	/**
	 * 递归替换属性之中的反复引用
	 * @param propertyMap 属性名称与属性值的映射关系
	 * @param newValue 属性原始值

	 * @return 返回属性引用替换值

	 */
	public String replaceQuoteProperty(Map<String,String> propertyMap , String oldValue){
		String newValue = oldValue ;
		if(oldValue.indexOf("??")!=-1){
			String[] items = oldValue.split("\\?\\?");
			for(String item : items){
				if(item!=null && !item.equals("")){
					for(String key : propertyMap.keySet()){
						if(key.equals(item)){
							newValue = oldValue.replaceAll("\\?\\?"+item+"\\?\\?", propertyMap.get(key));
							break ;
						}
					}
				}
			}
		}
		if(newValue.indexOf("??")!=-1){
			return replaceQuoteProperty(propertyMap,newValue);
		}
		return newValue;
	}
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String xmlFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void exportFile(String xmlFile,String fileName,String appsys_code,String filePath) throws UnsupportedEncodingException, FileNotFoundException{
		
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
	 * 获取某系统下的所有实例的属性和值.
	 * @param appSysCode 系统编号
	 * @return
	 * @throws Exception
	 */
	public ModelMap getRequestInfo2Excel(String ids) throws Exception{
		String env = null;
		String requestsXml = null;
		Document doc = null;
		Element root = null;
		ModelMap modelMap = new ModelMap();
		String requestsId[] = ids.split(",");
		Map<String, String> stepChangeColumns = new LinkedHashMap<String, String>();
		stepChangeColumns.put("position", "序号");
		stepChangeColumns.put("serviceCode", "服务编码");
		stepChangeColumns.put("name", "步骤名称");
		stepChangeColumns.put("component", "目标组件");
		stepChangeColumns.put("server", "服务器");
		stepChangeColumns.put("manual", "步骤类型");
		//stepChangeColumns.put("differentLevelFromPrevious", "是否并发");
		//stepChangeColumns.put("userName", "执行人员");
		//stepChangeColumns.put("autoJobName", "自动化作业名称");
		stepChangeColumns.put("operateContent", "操作内容");
		modelMap.addAttribute("stepColumns", stepChangeColumns);
//序号	服务编码	步骤名称	目标组件	服务器	步骤类型	操作内容
//position serviceCode name component server manual operateContent
		Map<String, String> requestNum = new LinkedHashMap<String, String>();
		requestNum.put("requestNum", ids);
		modelMap.addAttribute("requestNum", requestNum);
		
		for(int i=0;i<requestsId.length;i++){			
			requestsXml = brpmService.getMethodById(BrpmConstants.KEYWORD_REQUSET,requestsId[i]);
			if(requestsXml!=null){
				
				doc = JDOMParserUtil.xmlParse(requestsXml);
				root = doc.getRootElement();
				env = root.getChild("environment").getChildText("name");
				
				modelMap.addAttribute("requestData"+i, brpmService.queryExcelExportRequestService(requestsId[i]));
				modelMap.addAttribute("stepData"+i, brpmService.queryUrgentDplyStepService(requestsId[i],env));//request.getSession().getAttribute("requestChangeColumns")
			}
			
		}
		/*ExcelView4Request excelView4Request = new ExcelView4Request();
		excelView4Request.*/
		
		return modelMap;
	}
	
	
	/**
	 * 获取某系统下的应急请求到excel文件中.
	 * @param appSysCode 系统编号
	 * @return
	 * @throws Exception
	 */
	public void buildExcelDocument(String requestIds,String filePath)throws Exception {
		
		//ModelMap model = new ModelMap();
		String tempName = "emergency_request_templet.xls";
		String sourceFilePath = null;
		if(ComUtil.isWindows){
			sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append("file")
					.append(File.separator)
					.append(tempName)
					.toString();
		}else{
			sourceFilePath = new StringBuilder().append(System.getProperty("maop.root"))
					.append(File.separator)
					.append("file")
					.append(File.separator)
					.append(tempName)
					.toString();
		}
		File excelFile = new File(sourceFilePath);
		HSSFWorkbook workbook = readExcel(excelFile);
		ModelMap model = getRequestInfo2Excel(requestIds);
		
		Map<String, String> map = (Map<String, String>) model.get("requestNum");
		Map<String, String> requestNum = map;
		Map<String, String> columns = (Map<String, String>) model.get("stepColumns");
		int sheetIndex = workbook.getSheetIndex("request");
		String[] sheetName = null;
		
		//普通数据样式：无背景色+边框样式实线
		HSSFCellStyle normalStyle = workbook.createCellStyle();
		normalStyle.setBorderTop((short)1);
		normalStyle.setBorderRight((short)1);
		normalStyle.setBorderBottom((short)1);
		normalStyle.setBorderLeft((short)1);
		
		if(requestNum != null && columns != null){
			String count[] = requestNum.toString().split("=")[1].split(",");
			sheetName = new String[count.length];
			sheetName[0] = "request";
			for(int i=1;i<count.length;i++){
				HSSFSheet sheet = workbook.cloneSheet(sheetIndex);
				sheetName[i] = sheet.getSheetName();
			}
			HSSFSheet sheet = null;
			List<Map<String, String>> data = null;
			List<Map<String, String>> requestData = null;
			for(int i=0;i<count.length;i++){
				data = (List<Map<String, String>>) model.get("stepData"+i);
				requestData = (List<Map<String, String>>) model.get("requestData"+i);

				for(int j=0;j<workbook.getNumberOfSheets();j++){
					sheet = workbook.getSheetAt(j);
					if(sheet.getSheetName().equals(sheetName[i])){
						if(data != null && columns != null){
							writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
						}
						
					}
				}
			}
		}
		
		String sourceFilePath2 = filePath + File.separator + "emergency_request_templet.xls";
		File excelFile2 = new File(sourceFilePath2);
		saveExcel(excelFile2, workbook);
	}
	
	/**
	 * 将对应的列和数据写入报表
	 * @param book 工作簿



	 * @param sheet 工作报表
	 * @param data 数据
	 * @param columns 列



	 */
	public void writeSheetByName(HSSFWorkbook book, HSSFSheet sheet,
			List<Map<String, String>> data, Map<String, String> columns, List<Map<String, String>> requestData ,HSSFCellStyle normalStyle) {
		HSSFComment cell = null;
		//cell.getDateCellValue();
		int col = 0;

		String app = requestData.get(0).get("app").toString();
		String environment = requestData.get(0).get("environment").toString();
		String name = requestData.get(0).get("name").toString();
		sheet.getRow(0).getCell(1).setCellValue(name == null ? "" : name.toString());
		sheet.getRow(1).getCell(1).setCellValue(app == null ? "" : app.toString());
		sheet.getRow(2).getCell(1).setCellValue(environment == null ? "" : environment.toString());

		
		int row = 0;
		for (; row < data.size(); row++) {
			Map<String, String> map = data.get(row);

			col = 0;
			for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
				Object columnKey = i.next();
				for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
					String dataKey = iterator.next();
					if (columnKey.toString().equalsIgnoreCase(dataKey)) {
						Object value = map.get(dataKey);
						
						if(sheet.getRow(row + 5)==null){
							sheet.createRow(row + 5).createCell(col).setCellValue(value == null ? "" : value.toString());
						}else if(sheet.getRow(row + 5).getCell(col)==null){
							sheet.getRow(row + 5).createCell(col).setCellValue(value == null ? "" : value.toString());
						}else{
							sheet.getRow(row + 5).getCell(col).setCellValue(value == null ? "" : value.toString());
						}
						sheet.getRow(row + 5).getCell(col).setCellStyle(normalStyle);

						
						col++;
					}
				}
			}
		}
		
	}
	


	/**
	 * 读取模板 read the template
	 * 
	 * @param excelFile -the excelFile Path
	 * @return HSSFWorkbook return HSSFWorkbook's variables
	 * @throws Exception 
	 */
	public HSSFWorkbook readExcel(File excelFile) throws Exception {
		HSSFWorkbook result = null;
		
		try {
			POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(excelFile));
			result = new HSSFWorkbook(fs);
		} catch (FileNotFoundException e) {
			throw new Exception("找不到指定的模板文件路径, 请重新上传模板");
		} catch (IOException e) {
			throw new Exception("创建文件时发生异常");
		}
		
		return result;
	}
	
    /**  
     * 保存Excel文件  
     *   
     * @param excelPath  
     * @param workBook  
     * @return  
     * @throws Exception 
     */  
    public void saveExcel(File excelFile, HSSFWorkbook workBook) throws Exception {   
        FileOutputStream fileOut = null;   
        try {
			fileOut = new FileOutputStream(excelFile);
			workBook.write(fileOut);
		} catch (FileNotFoundException e1) {
			throw new Exception("找不到创建的文件路径");
		} catch (IOException e1) {
			throw new Exception("写入文件时发生错误");
		}finally{   
            try {
				fileOut.flush();   
				fileOut.close();
			} catch (IOException e) {
				e.printStackTrace();
				throw new Exception("文件流发生错误");
			}
            	
        }
    }

    
    /**
     * 查询发布请求信息
     * @param start 起始索引
	 * @param limit 每页至多显示的记录数
	 * @param sort  排序的字段


	 * @param dir 排序的方式


     * @param params 参数
     * @return
     */
    @Transactional(readOnly = true)
    public Object queryDplyRequestEmergencybakInfo(Integer start, Integer limit,
            String sort, String dir, Map<String, Object> params, HttpServletRequest request,String deployMonth,String requestStatus){
    	StringBuilder sql = new StringBuilder();
    	sql.append("select  o.appSysCode as \"appSysCode\",")
		.append("o.requestCode as \"requestCode\", ")
		.append(" o.planDeployDate as \"planDeployDate\", ")
		.append("o.deployCode as \"deployCode\", ")
		.append("o.requestName as \"requestName\", ")
		.append("o.environment as \"environment\", ")
		.append("o.trunSwitch as \"trunSwitch\", ")
		.append("o.execStatus as \"execStatus\", ")
		.append("o.planStartTime as \"planStartTime\", ")
		.append("o.planEndTime as \"planEndTime\", ")
		.append("o.realStartDate as \"realStartDate\", ")
		.append(" o.realEndDate as \"realEndDate\", ")
		.append(" o.requestStatus as \"requestStatus\" ")
		.append(" from (  ")
		.append(" select b.appsys_code as appSysCode,  ")
		.append(" b.request_code as requestCode,")
		.append(" b.environment as environment,")
		.append(" b.plan_deploy_date as planDeployDate,")
		.append(" b.deploy_code as deployCode,")
		.append(" b.request_name as requestName,")
		.append("   b.turn_switch as trunSwitch,  ")
		.append("  b.exec_status as execStatus,  ")
		.append("  b.plan_start_time as planStartTime,  ")
		.append("  b.plan_end_time as planEndTime,  ")
		.append("  b.real_start_date as realStartDate,  ")
		.append("  b.real_end_date as realEndDate,  ")
		.append("  substr(b.request_name,instr(b.request_name,'_',1,1)+1,instr(b.request_name,'_',1,2)-1-instr(b.request_name,'_',1,1))  as requestStatus ")
		.append(" from dply_request_info b) o where o.appSysCode in :sysList and o.environment in :envList ");
    	
    	if(null==deployMonth  && null==params.get("planDeployDate") || null==deployMonth && "".equals(params.get("planDeployDate"))){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  to_char(sysdate,'yyyymm')||'%' ");
    	}
    	if(null!=deployMonth){
    		sql.append(" and substr(o.requestName,instr(o.requestName,'_',1,2)+1,6)  like  '"+deployMonth+"%'");
    	}
    	if(null != requestStatus  && !"".equals(requestStatus)){
    		sql.append("and substr(o.requestName,instr(o.requestName,'_',1,1)+1,instr(o.requestName,'_',1,2)-1-instr(o.requestName,'_',1,1)) = '"+requestStatus+"' ");
    	}
    	
    	if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and o." + key + " like :" + key);
				} else {
					sql.append(" and o." + key + " = :" + key);
				}
			}
		}
    	
    	sql.append(" order by o." + sort + " " + dir);
		 
		Query query = getSession().createSQLQuery(sql.toString())
				.addScalar("appSysCode", StringType.INSTANCE)
				.addScalar("requestCode", StringType.INSTANCE)
				.addScalar("environment", StringType.INSTANCE)
				.addScalar("planDeployDate", StringType.INSTANCE)
				.addScalar("deployCode", StringType.INSTANCE)
				.addScalar("requestName", StringType.INSTANCE)
				.addScalar("trunSwitch", StringType.INSTANCE)
				.addScalar("execStatus", StringType.INSTANCE)
				.addScalar("planStartTime", StringType.INSTANCE)
				.addScalar("planEndTime", StringType.INSTANCE)
				.addScalar("realStartDate", TimestampType.INSTANCE)
				.addScalar("realEndDate", TimestampType.INSTANCE)
				.addScalar("requestStatus", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		query.setParameterList("envList", userService.getPersonalEnvs());
		
		request.getSession().setAttribute("dplyRequestInfo4ExportBack", query.list());
		
        return query.setFirstResult(start).setMaxResults(limit).list();
    	
    }
    
    
 	 /**
      * 查询发布请求信息
      * @param start 起始索引
 	 * @param limit 每页至多显示的记录数
 	 * @param sort  排序的字段
 	 * @param dir 排序的方式
      * @param params 参数
      * @return
      */
     @SuppressWarnings("unchecked")
     public List<Map<String, String>> requestBackup(){
     	
     	Session session = getSession2();
      	
     	StringBuilder sql = new StringBuilder();
     	sql.append("select o1.appsys_code as \"appsys_code\", ");   
     	sql.append("o2.environment as \"environment\" , ");   
     	sql.append("o2.request_code as \"request_code\" ");   
     	sql.append("from (select  ");   
     	sql.append("max(t1.appsys_code) as  appsys_code,  ");   
     	sql.append("max(t1.move_status) as move_status, ");   
     	sql.append("max(t1.operate_type) as operate_type, ");   
     	sql.append("max(t1.operate_source)  as operate_source ");   
     	sql.append(",max(t1.execute_end_time) as execute_end_time ");   
     	sql.append("from dply_execute_status t1   ");   
     	sql.append("where t1.move_status='完成'   ");   
     	sql.append(" and t1.operate_type='导入' ");   
     	sql.append(" and t1.operate_source like '%REQ%' ");   
     	sql.append(" group by   ");   
     	sql.append(" t1.appsys_code ,  ");   
     	sql.append("t1.move_status,    ");   
     	sql.append("t1.operate_type,  ");   
     	sql.append("t1.operate_source    ");   
     	sql.append(") o1 ,");   
     	sql.append("(select ");   
     	sql.append("t2.request_code as request_code , ");   
     	sql.append("t2.environment as environment  ");   
     	sql.append("from dply_request_info t2) o2  ");   
     	sql.append("where o1.operate_source=o2.request_code  ");   
    		sql.append("and to_char( o1.execute_end_time ,'yyyymmdd  hh24:mm:ss')>=to_char( sysdate-1  ,'yyyymmdd')||' 12:00:00'"); 
     	
 		 
 		Query query = session.createSQLQuery(sql.toString())
 				
 				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

 		List<Map<String, String>> list=query.list();
         
         
         
         return list;
     	
     }
     
     
   
 	
     /**
 	 * 文件打包成zip压缩包.
 	 * 
 	 * @param String sourceFilePath, String zipFilePath,String fileName
 	 * @throws IOException
 	 */
 	public  boolean fileToZip(String sourceFilePath, String zipFilePath,
 			String ast,String zipname){
 		
 	
 		boolean flag = false;
 		try {
 		File sourceFile = new File(sourceFilePath);
 		File zipFile=null;
 		FileInputStream fis = null;
 		BufferedInputStream bis = null;
 		FileOutputStream fos = null;
 		ZipOutputStream zos = null;
 		if (sourceFile.exists() == false) {
 			
 		} else {
 				zipFile = new File(zipFilePath.concat(File.separator).concat(zipname).concat(".zip"));
 				if (zipFile.exists()) {
 					
 				} else {
 					File[] sourceFiles = sourceFile.listFiles();
 					if (null == sourceFiles || sourceFiles.length < 1) {
 						
 					} else {
 						try {
 							fos = new FileOutputStream(zipFile);
 						} catch (FileNotFoundException e1) {
 							logger.error("ZIP命令错误:"+e1.toString());
 							
 						}
 						zos = new ZipOutputStream(new BufferedOutputStream(fos));
 						zos.setEncoding("GBK");
 						byte[] bufs = new byte[1024 * 10];
 						for (int i = 0; i < sourceFiles.length; i++) {
 							try {
 								// 创建ZIP实体,并添加进压缩包


 								ZipEntry zipEntry = new ZipEntry(ast+File.separator+sourceFiles[i].getName());
 								zos.putNextEntry(zipEntry);
 								// 读取待压缩的文件并写进压缩包里


 								fis = new FileInputStream(sourceFiles[i]);
 								bis = new BufferedInputStream(fis, 1024 * 10);
 								int read = 0;
 								while ((read = bis.read(bufs, 0, 1024 * 10)) != -1) {
 									zos.write(bufs, 0, read);
 								}
 							} catch (IOException e) {
 								logger.error("ZIP命令错误:"+e.toString());
 							//e.printStackTrace();
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

 		File file = new File(sourceFilePath);
 	     if (file.exists()){
 	    	 File[] files=file.listFiles();
 	    	 for(int i=0;i<files.length;i++){
 	    		 files[i].delete();
 		   }
 	    	 file.delete();
 	     }
 		}catch (IOException e) {
 			logger.error("ZIP命令错误:"+e.toString());
 		//	e.printStackTrace();
 		}
 		return flag;
 	}
 	

 	  
 	  /**
 		 * 获取请求ID

 		 */
 	public String getrequestId(String request_code,String environment ){
 		String requestsXml;
 		String requestId="";
 		try {
 			requestsXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_REQUSET,"{ \"filters\": { \"name\":\"" +request_code + "\" }}");
 			Document doc = JDOMParserUtil.xmlParse(requestsXml);
 			Element root = doc.getRootElement();
 			List<Element> accounts = root.getChildren();
 			
 			for (Element account : accounts) {
 				String envRoot = account.getChild("environment").getChildText("name");
 				if(envRoot.equals(environment)){
 					requestId=account.getChildText("id");
 				}
 			}
 		} catch (IOException e) {
 			logger.error("获取请求ID错误:"+e.toString());
 		} catch (BrpmInvocationException e) {
 			logger.error("获取请求ID错误:"+e.toString());
 		} catch (URISyntaxException e) {
 			logger.error("获取请求ID错误:"+e.toString());
 			//e.printStackTrace();
 		}
 		return requestId;
 	}  
 	  
 	/**
 	 * 获取服务器分组名称



 	 */
 	
 	public String getEmergencyBakType(String name){
 		
 		String s="";
 		Session session = getSession2();
 		Transaction tran = session.getTransaction();
 		tran.begin();
 		try{
 			
 			
 		StringBuilder sql = new StringBuilder();
 		sql.append("select o.sub_item_value from jeda_sub_item o where o.item_id='ONOFF_SWITCH' and o.sub_item_name=:sub_item_name ");
 		Query query = session.createSQLQuery(sql.toString())
 				.setString("sub_item_name",name);
 		s= query.list().get(0).toString();
 		//提交事物
 		tran.commit();
 		
 		} catch (Exception e) {
 			logger.error("获取应急备份类型出错:"+e.toString());
 			//回滚事物
 			tran.rollback();
 			//关闭连接
 			if(session.isOpen()) session.close();
 		}

 		//关闭连接
 		if(session.isOpen()) session.close();
 		return s;
 		
 	} 

 	
 	
 	
 	 /**
 	   *上传导出文件目录
 	   * 
 	   * @param customer
 	   * @throws IOException 
 	   */
 	  
 	    @Transactional
 	  public void FTPRequest(String zipFilePath,String zipname,String envcode){
 	    try {
 	   //  String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("request.Filepath");
 	    String localFilename=zipFilePath+File.separator+zipname+CommonConst.FILE_SUFFIX_ZIP;
 	    String path=messages.getMessage("request.rootpath")+CommonConst.SLASH+envcode+CommonConst.SLASH+messages.getMessage("request.FTPFilepath")+CommonConst.SLASH+zipname+CommonConst.FILE_SUFFIX_ZIP;
 	    String datapath=messages.getMessage("request.rootpath")+CommonConst.SLASH+envcode;
 	    String requestpath =messages.getMessage("request.FTPFilepath");
 	    
 	    String host = messages.getMessage("exportServer.ipAdress");
 	    Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
 	    String user = messages.getMessage("exportServer.user");
 	    String password = messages.getMessage("exportServer.password");
 	    ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
 	    ftpLogin.connect(host,port,user,password);
 	    ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
 	   
 	     ftpFile.doMkdirs(datapath,requestpath);
 	    
 	    ftpLogin.disconnect();
 	    ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
 	    ftpLogin2.connect(host,port,user,password);
 	    ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
 	    ftpFile2.doPut(localFilename,path, true,new StringBuffer());
 	    ftpLogin2.disconnect();
 	    } catch (IOException e) {
 	     logger.error("FTP命令错误:"+e.toString());
 	     //e.printStackTrace();
 	    }
 	  }


 
     
     /**
      * 备份请求zip包

      * 
      * @param customer
      * @throws IOException 
      */
     @Transactional
     public void requestBak(String zipFilePath,String zipname,String envcode){
      
      try {
        
        String path=messages.getMessage("request.rootpath")+CommonConst.SLASH+envcode+CommonConst.SLASH+messages.getMessage("request.FTPFilepath")+CommonConst.SLASH+zipname+CommonConst.FILE_SUFFIX_ZIP;
        String ToPath2=messages.getMessage("request.rootpath")+CommonConst.SLASH+envcode+CommonConst.SLASH+messages.getMessage("request.RequestBak_Path")+CommonConst.SLASH+zipname+CommonConst.FILE_SUFFIX_ZIP;
        
        String datapath=messages.getMessage("request.rootpath")+CommonConst.SLASH+envcode;
        String requestpath =messages.getMessage("request.RequestBak_Path");
        
        String host = messages.getMessage("exportServer.ipAdress");
        Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
        String user = messages.getMessage("exportServer.user");
        String password = messages.getMessage("exportServer.password");
        ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
        ftpLogin.connect(host,port,user,password);
        ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
       
         ftpFile.doMkdirs(datapath,requestpath);
        
        ftpLogin.disconnect();
        ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
        ftpLogin2.connect(host,port,user,password);
        ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
        ftpFile2.renamelFile(path, ToPath2);
        ftpLogin2.disconnect();
        } catch (IOException e) {
         logger.error("FTP备份命令错误:"+e.toString());
         //e.printStackTrace();
        }
      
     }

     /**
      * 手动备份
      * @throws Exception 

      */
     
     
     public void handlebak(String[] appSysCodes, String[] requestCodes,
       String[] environments){
      //应用系统
         Set<String> appsys_setlist=new HashSet<String>();
         Set<String> appenv_setlist=new HashSet<String>();
      String time=new SimpleDateFormat("yyyyMMddHHmm").format(new Date());
      //存放路径
      String zipFilePath =null;
      if(appSysCodes.length>0){
       for(int k=0;k<appSysCodes.length;k++){
        appsys_setlist.add(appSysCodes[k].toString());
        appenv_setlist.add(environments[k].toString());
       }
       
       for(String env :appenv_setlist){
       String appcode=env.split("_")[0].toString();
       String envcode=env.split("_")[1].toString();
       
       for(String appsys_code :appsys_setlist){
        if(appcode.equals(appsys_code)){
        zipFilePath=System.getProperty("maop.root") +File.separator + messages.getMessage("request.Filepath") +File.separator + envcode+"_"+time;
        
        //存放路径
        String path =System.getProperty("maop.root") +File.separator + messages.getMessage("request.Filepath")+File.separator +envcode+"_"+time+File.separator +appsys_code+"+"+envcode+"_"+time;

        //创建路径
        File file = new File(path);
        if(!file.exists()){
         file.mkdirs();
        }
        //请求ID
        String requestIds="";
        //方法1  放脚本

        //public void method1(path,appsys_code){}
        try {
         this.getAllProperty2File(appsys_code,path);
        } catch (Exception e) {
         logger.error(appsys_code+"系统,获取请求实例脚本方法错误:"+e.toString());
         //e.printStackTrace();
        }
        
       //获取系统执行脚本 
        try {
         nshJobService.downloadScript(appsys_code, path,envcode);
        } catch (NoSuchMessageException e1) {
         logger.error(appsys_code+"系统,下载脚本方法错误:"+e1.toString());
        } catch (Exception e1) {
         logger.error(appsys_code+"系统,下载脚本方法错误:"+e1.toString());
        }
        //方法2  放实例

        for(int j=0;j<appSysCodes.length;j++){
         if(appsys_code.equals(appSysCodes[j].toString())&&env.equals(environments[j].toString())){
          
          String request_code=requestCodes[j].toString();
          String environment=environments[j].toString();
          //获取 BRPM请求ID
          try {
           String requestid =this.getrequestId(request_code,environment);
            requestIds =requestIds.concat(requestid).concat(",");
          } catch (Exception e) {
           logger.error(appsys_code+"系统,获取BRPM请求ID方法错误:"+e.toString());
          }
         }
        }
        if(requestIds.length()>0){
        
        requestIds=requestIds.substring(0,requestIds.length()-1);
        }else{
         logger.error(appsys_code+"系统,无请求ID");
        }
        //方法3  放请求

        try {
         this.buildExcelDocument( requestIds, path);
        } catch (Exception e) {
         logger.error(appsys_code+"系统,获取请求exel错误:"+e.toString());
        }
        String ast=appsys_code+"_"+time;
        String zipname=appsys_code;
        try {
        //方法4  打zip包 上传32.1
        this.fileToZip(path, zipFilePath, ast,zipname);
        } catch (Exception e) {
         logger.error(appsys_code+"系统,ZIP命令错误:"+e.toString());
        }
        
        try {
         this.requestBak(zipFilePath, zipname,envcode);
        } catch (Exception e) {
         logger.error(appsys_code+"FTP备份zip命令错误:"+e.toString());
         }
        
        
        try {
        this.FTPRequest(zipFilePath, zipname,envcode);
       } catch (Exception e) {
        logger.error(appsys_code+"FTP上传zip命令错误:"+e.toString());
        }
        }
       }
        
      }
      
      
      
      //删除已上传的zip文件
      File file2 = new File(zipFilePath);
       if (file2.exists()){
           File[] files2=file2.listFiles();
           for(int i=0;i<files2.length;i++){
           boolean b1= files2[i].delete();
         }
           boolean b2=file2.delete();
          }
      }
     }
    /**
      * 自动备份
      * 调用备份方法及备份使用的参数
      * @throws Exception 
      */
        public void back(){
         String on_off=this.getEmergencyBakType("autoSyn_requestEmergencyBak");
         
         //String on_off =itemService.getSubItemValueByItemIdAndSubItemName("ONOFF_SWITCH","autoSyn_requestEmergencyBak");
         
         if(on_off.equals("on")){
         
         List<Map<String, String>> list=this.requestBackup();
         //应用系统
         Set<String> appsys_setlist=new HashSet<String>();
        Set<String> appenv_setlist=new HashSet<String>();
      String time=new SimpleDateFormat("yyyyMMddHHmm").format(new Date());
        
      if(list.size()>0){
       for(int k=0;k<list.size();k++){
        appsys_setlist.add(list.get(k).get("appsys_code").toString());
        appenv_setlist.add(list.get(k).get("environment").toString());
       }
       
       for(String env :appenv_setlist){
        String appcode=env.split("_")[0].toString();
         String envcode=env.split("_")[1].toString();
        
       for(String appsys_code :appsys_setlist){
        if(appsys_code.equals(appcode)){
        //应用系统
        //存放路径
        String zipFilePath=System.getProperty("maop.root") +File.separator + messages.getMessage("request.Filepath") +File.separator + envcode+"_"+time;
        
        //存放路径
        String path =System.getProperty("maop.root") +File.separator + messages.getMessage("request.Filepath")+File.separator +envcode+"_"+time+File.separator +appsys_code+"+"+envcode+"_"+time;
        //创建路径
        File file = new File(path);
        if(!file.exists()){
         file.mkdirs();
        }
        //请求ID
        String requestIds="";
        //方法1  放脚本

        try {
         this.getAllProperty2File(appsys_code,path);
        } catch (Exception e) {
         logger.error(appsys_code+"系统,获取请求脚本方法错误:"+e.toString());
        }
        
        //获取系统执行脚本 
        try {
        	 nshJobService.downloadScript(appsys_code, path,envcode);
        } catch (NoSuchMessageException e1) {
         logger.error(appsys_code+"系统,下载脚本方法错误:"+e1.toString());
        } catch (Exception e1) {
         logger.error(appsys_code+"系统,下载脚本方法错误:"+e1.toString());
        }
        //方法2  放实例

        for(int j=0;j<list.size();j++){
         if(appsys_code.equals(list.get(j).get("appsys_code").toString())&&env.equals(list.get(j).get("environment").toString())){
          String request_code=list.get(j).get("request_code").toString();
          String environment=list.get(j).get("environment").toString();
          //获取 BRPM请求ID
          try {
           String requestid =this.getrequestId(request_code,environment);
            requestIds =requestIds.concat(requestid).concat(",");
          } catch (Exception e) {
           logger.error(appsys_code+"系统,获取BRPM请求ID方法错误:"+e.toString());
          }
         }
        }
        if(requestIds.length()>0){
         requestIds=requestIds.substring(0,requestIds.length()-1);
         }else{
          logger.error(appsys_code+"系统,无请求ID");
         }

        //方法3  放请求

        try {
         this.buildExcelDocument( requestIds, path);
        } catch (Exception e) {
         logger.error(appsys_code+"系统,获取请求exel错误:"+e.toString());
        }
        String ast=appsys_code+"_"+time;
        String zipname=appsys_code;
        try {
        //方法4  打zip包 上传32.1
        this.fileToZip(path, zipFilePath, ast,zipname);
         } catch (Exception e) {
          logger.error(appsys_code+"系统,ZIP命令错误:"+e.toString());
         }
         
         try {
         this.FTPRequest(zipFilePath, zipname,envcode);
        } catch (Exception e) {
         logger.error(appsys_code+"FTP上传zip命令错误:"+e.toString());
        }
         
         
       //删除已上传的zip文件
        File file2 = new File(zipFilePath);
           if (file2.exists()){
               File[] files2=file2.listFiles();
               for(int i=0;i<files2.length;i++){
               boolean b1= files2[i].delete();
             }
               boolean b2=file2.delete();
              }
          }
        }
       }
      }
           }
         
        }
        
        
        /**
    	 * 检查BSA参数是否为空
    	 * @param request
    	 * @param modelMap
    	 * @return
    	 * @throws JEDAException
    	 */    
	public String checkBSAParams(List<Map<String, Object>> dataList) {
		
		StringBuilder error=new StringBuilder();
		
		for(Map<String, Object> map :dataList ){
			if(null==map.get("value")||!"".equals(map.get("value").toString())){
				
		}else{
			String path =map.get("instPath").toString();
			String appname=path.substring(path.lastIndexOf("/")+1,path.length());
			String o=path.substring(0,path.lastIndexOf("/"));
			String app=o.substring(o.lastIndexOf("/")+1, o.length());
			String name=map.get("name").toString();
			error.append(app)
			     .append(".")
			     .append(appname)
			     .append(".")
			     .append(name)
			     .append("\r\n");
		  }
		}
		

		return error.toString();
		
	}
	
}
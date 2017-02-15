package com.nantian.check.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.axis2.databinding.types.soapencoding.Array;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.ServletRequestDataBinder;

import com.nantian.check.vo.CheckComplianceResultInfoVo;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.DateFunction;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnDetailLogVo;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.config.service.SubItemService;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 巡检错误处理service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class CheckErrorService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckErrorService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;
	/** 数据字典 */
	@Autowired
	private SubItemService subItemService;
	@Autowired
    private AppInfoService appInfoService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	private static boolean isWindows = false;
	private static String osName = null;
	static {
		osName = System.getProperty("os.name");
		System.getProperty("sun.jnu.encoding");
		if (osName.toUpperCase().startsWith("WINDOWS")) {
			isWindows = true;
		}
	}
	
	/**
	 * 构造方法
	 */
	public CheckErrorService() {
		fields.put("appsysCode", FieldType.STRING);
		fields.put("checkType", FieldType.STRING);
		fields.put("appsysCode_ip", FieldType.STRING);
		fields.put("ServerName", FieldType.STRING);
		fields.put("ServerIp", FieldType.STRING);
		fields.put("FlucDatetime", FieldType.STRING);
		fields.put("StartDatetime", FieldType.STRING);
		fields.put("RuleName", FieldType.STRING);
		fields.put("InconsistentShellLog", FieldType.CLOB);
		fields.put("InconsistentHandleDesc", FieldType.STRING);
		fields.put("InconsistentHandleResult", FieldType.STRING);
		fields.put("InconsistentHandleStatus", FieldType.INTEGER);
		fields.put("InconsistentHandleUser", FieldType.STRING);
		fields.put("InconsistentHandleDate", FieldType.TIMESTAMP);
		fields.put("checkstatus", FieldType.STRING);
		fields.put("checkDate", FieldType.STRING);
		fields.put("ExtendObject", FieldType.STRING);
		fields.put("subItemDetail", FieldType.STRING);
	}

	/**
	 * 查询应用系统及管理员分配信息
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @return 应用系统及管理员分配信息映射集合
	 */
	@Transactional(readOnly = true)
	public List<Map<String, Object>> queryErrorList(Integer start,Integer limit,String sort,String dir,Map<String, Object> params,
			HttpServletRequest request) throws SQLException{
		List<Map<String,Object>> serversList= new ArrayList<Map<String,Object>>();
		String LastDate=""; //最后一次巡检时间
		String FlucDatetime=""; //巡检时间前移
		String checkDate =""; //巡检日期
		if( (String)params.get("checkDate")!=null){
			checkDate=((String) params.get("checkDate")).replace("%", "");
			//获取当天最近一次的检查时间
			List<Map<String,String>> CheckDateList = queryLastCheckDate(checkDate.replace("-", ""));
			if(CheckDateList.size()!=0){
				String sdt = CheckDateList.get(0).get("StartDatetime");
				sdt = checkDate.concat(" ").concat(sdt);
				FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(sdt,1,-getFloatMinutes()); //时间前移
				LastDate = DateFunction.getDateTimeByFormatAndOffset(sdt,1,getFloatMinutes()); //时间后移
			}
		}
		if((String) params.get("StartDatetime")!=null && (String) params.get("FlucDatetime")!=null){
			String startDatetime = ((String)params.get("StartDatetime")).replace("%", "");
			String flucDatetime = ((String)params.get("FlucDatetime")).replace("%", "");
			//查询字段的'巡检时间'不为空时
			if(!flucDatetime.equals("")){ 
				if(flucDatetime.equals("all")){
					FlucDatetime = checkDate.concat(" 00:00:00");
					LastDate = checkDate.concat(" 23:59:59");
				}else{
					//时间前移
					FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(startDatetime),1,-getFloatMinutes());
					//时间后移
					LastDate = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(startDatetime),1,getFloatMinutes());
				}
			}
		}else{
			FlucDatetime = checkDate.concat(" 00:00:00");
			LastDate = checkDate.concat(" 23:59:59");
		}
		//yyyy-MM-dd转yyyyMMdd
		LastDate = LastDate.replace("-", "");
		FlucDatetime = FlucDatetime.replace("-", "");
		serversList=queryservers(start,limit,sort,dir,LastDate,FlucDatetime,params);
		for(int i=0; i< serversList.size();i++){
			String ServerName = (String) serversList.get(i).get("ServerName");
			String appsysCode = (String) serversList.get(i).get("appsysCode");
			//查询巡检总数，报错数量，正常数量
			List<Map<String,Object>> CheckNumList=queryCheckNumAndErrorNum(ServerName,LastDate,FlucDatetime,appsysCode);
			if(CheckNumList.size()!=0){
				if(!(CheckNumList.get(0).get("normal")==null) && !(CheckNumList.get(0).get("error")==null) && !(CheckNumList.get(0).get("total")==null)){
					serversList.get(i).put("normal", CheckNumList.get(0).get("normal"));
					serversList.get(i).put("error", CheckNumList.get(0).get("error"));
					serversList.get(i).put("total", CheckNumList.get(0).get("total"));
				}
			/*String subItemDetail=(String) serversList.get(i).get("subItemDetail");
				if(subItemDetail!=null){
					if(subItemDetail.split(";").length>0){
						String[] StartDatetime= subItemDetail.split(";");
						for(int m=0;m<StartDatetime.length;m++){
							if(StartDatetime[m].contains("CheckDate")){
								String datetime=StartDatetime[m].substring(StartDatetime[m].indexOf("=")+1);
								datetime=datetime.substring(0,4).concat("-").concat(datetime.substring(4,6)).concat("-").concat(datetime.substring(6,8)).concat(" ").concat(datetime.substring(8,10)).concat(":").concat(datetime.substring(10,12)).concat(":").concat(datetime.substring(12,14)) ;
								serversList.get(i).put("StartDatetime", datetime);
							}
						}
					}
				}*/
				//未处理 
				String Notreatment = CheckNumList.get(0).get("Notreatment").toString();
				//处理中  
				String Processing = CheckNumList.get(0).get("Processing").toString();
				//已处理 
				String Processed = CheckNumList.get(0).get("Processed").toString();
				if(!Processing.equals("0") || (!Notreatment.equals("0") && !Processed.equals("0") )){
					serversList.get(i).put("checkstatus", 3); //处理中

				}
				if(Processing.equals("0") && !Notreatment.equals("0") && Processed.equals("0")){
					serversList.get(i).put("checkstatus", 1); //未处理

				}
				if(Processing.equals("0") && Notreatment.equals("0") && Processed.equals("0")){
					serversList.get(i).put("checkstatus", 4); //正常
				}
				if(Processing.equals("0") && Notreatment.equals("0") && !Processed.equals("0")){
					serversList.get(i).put("checkstatus", 2); //已解决

				}
			}
		}	
		//根据巡检状态查询
		if(params.containsKey("checkstatus")){
			String checkstatus = ((String) params.get("checkstatus")).replace("%", "");
			if(!checkstatus.equals("")){ //非所有状态时
				if(checkstatus.equals("5")){ 
					for(int m=0;m<serversList.size();m++){
						String aaa =  serversList.get(m).get("checkstatus").toString();
						if(aaa.equals("4")){
							serversList.remove(m);
							m--;
						}
					}
				}else{
					for(int m=0;m<serversList.size();m++){
						String aaa =  serversList.get(m).get("checkstatus").toString();
						if(!aaa.equals(checkstatus)){
							serversList.remove(m);
							m--;
						}
					}
				}
			}
		}
		
		
	    return serversList;
	}
	
	/**
	 * 查询应用系统及管理员分配信息   - 统计总数量

	 * @param params 参数对象
	 */
	@Transactional(readOnly = true)
	public Long countQueryErrorList(Map<String, Object> params) throws SQLException{
		List<Map<String,Object>> serversList= new ArrayList<Map<String,Object>>();
		String LastDate=""; //最后一次巡检时间
		String FlucDatetime=""; //巡检时间前移
		String checkDate =""; //巡检日期
		if( (String)params.get("checkDate")!=null){
			checkDate=((String) params.get("checkDate")).replace("%", "");
			//获取当天最近一次的检查时间
			List<Map<String,String>> CheckDateList = queryLastCheckDate(checkDate.replace("-", ""));
			if(CheckDateList.size()!=0){
				String sdt = CheckDateList.get(0).get("StartDatetime");
				sdt = checkDate.concat(" ").concat(sdt);
				FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(sdt,1,-getFloatMinutes()); //时间前移
				LastDate = DateFunction.getDateTimeByFormatAndOffset(sdt,1,getFloatMinutes()); //时间后移
			}
		}
		if((String) params.get("StartDatetime")!=null && (String) params.get("FlucDatetime")!=null){
			String startDatetime = ((String)params.get("StartDatetime")).replace("%", "");
			String flucDatetime = ((String)params.get("FlucDatetime")).replace("%", "");
			//查询字段的'巡检时间'不为空时
			if(!flucDatetime.equals("")){ 
				if(flucDatetime.equals("all")){
					FlucDatetime = checkDate.concat(" 00:00:00");
					LastDate = checkDate.concat(" 23:59:59");
				}else{
					//时间前移
					FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(startDatetime),1,-getFloatMinutes());
					//时间后移
					LastDate = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(startDatetime),1,getFloatMinutes());
				}
			}
		}
		//yyyy-MM-dd转yyyyMMdd
		LastDate = LastDate.replace("-", "");
		FlucDatetime = FlucDatetime.replace("-", "");
		serversList=queryserversForCount(LastDate,FlucDatetime,params);
		for(int i=0; i< serversList.size();i++){
			String ServerName = (String) serversList.get(i).get("ServerName");
			String appsysCode = (String) serversList.get(i).get("appsysCode");
			//查询巡检总数，报错数量，正常数量
			List<Map<String,Object>> CheckNumList=queryCheckNumAndErrorNum(ServerName,LastDate,FlucDatetime,appsysCode);
			if(CheckNumList.size()!=0){
				if(!(CheckNumList.get(0).get("normal")==null) && !(CheckNumList.get(0).get("normal")==null) && !(CheckNumList.get(0).get("normal")==null)){
					serversList.get(i).put("normal", CheckNumList.get(0).get("normal"));
					serversList.get(i).put("error", CheckNumList.get(0).get("error"));
					serversList.get(i).put("total", CheckNumList.get(0).get("total"));
				}
				//未处理 
				String Notreatment = CheckNumList.get(0).get("Notreatment").toString();
				//处理中  
				String Processing = CheckNumList.get(0).get("Processing").toString();
				//已处理 
				String Processed = CheckNumList.get(0).get("Processed").toString();
				if(!Processing.equals("0") || (!Notreatment.equals("0") && !Processed.equals("0") )){
					serversList.get(i).put("checkstatus", 3); //处理中

				}
				if(Processing.equals("0") && !Notreatment.equals("0") && Processed.equals("0")){
					serversList.get(i).put("checkstatus", 1); //未处理

				}
				if(Processing.equals("0") && Notreatment.equals("0") && Processed.equals("0")){
					serversList.get(i).put("checkstatus", 4); //正常
				}
				if(Processing.equals("0") && Notreatment.equals("0") && !Processed.equals("0")){
					serversList.get(i).put("checkstatus", 2); //已解决

				}
			}
		}	
		//根据巡检状态查询
		if(params.containsKey("checkstatus")){
			String checkstatus = ((String) params.get("checkstatus")).replace("%", "");
			if(!checkstatus.equals("")){ //非所有状态时
				if(checkstatus.equals("5")){ 
					for(int m=0;m<serversList.size();m++){
						String aaa =  serversList.get(m).get("checkstatus").toString();
						if(aaa.equals("4")){
							serversList.remove(m);
							m--;
						}
					}
				}else{
					for(int m=0;m<serversList.size();m++){
						String aaa =  serversList.get(m).get("checkstatus").toString();
						if(!aaa.equals(checkstatus)){
							serversList.remove(m);
							m--;
						}
					}
				}
			}
		}
	    return Long.valueOf(serversList.size());
	}
		
	/**
	 * 查询报错数量，巡检总数
	 * @param ServerName 主机名称
	 * @param lastDate 巡检时间
	 * @param flucDatetime 浮动后的巡检时间
	 * @param appsysCode 应用系统
	 */	
	@SuppressWarnings("unchecked")
	@Transactional
	private List<Map<String, Object>> queryCheckNumAndErrorNum(String ServerName, String lastDate, String flucDatetime, String appsysCode) throws SQLException{
		/*
		 * 未处理=Notreatment
		 * 处理中=Processing
		 * 已处理=Processed
		 * 正常=normal_1
		*/
		StringBuilder sql = new StringBuilder();
		sql.append(" select sum(decode(consistent,'normal',nvl(INCONSISTENT_HANDLE_STATUS, 0),0)) as  \"normal\", ")
		   .append(" sum(decode(consistent,'error',nvl(INCONSISTENT_HANDLE_STATUS, 0),0)) as \"error\", ")
		   .append("	sum(INCONSISTENT_HANDLE_STATUS) as \"total\",max((select sum(decode(consistent,'error1',nvl(INCONSISTENT_HANDLE_STATUS, 0),0))  ")
		   .append("	from(select consistent,COUNT(INCONSISTENT_HANDLE_STATUS) as INCONSISTENT_HANDLE_STATUS from (select case when INCONSISTENT_HANDLE_STATUS = '4' then 'normal' ")
		   .append("              when INCONSISTENT_HANDLE_STATUS = '1' then 'error1'  ")
		   .append("              when INCONSISTENT_HANDLE_STATUS = '2' then 'error2' ")
		   .append("               when INCONSISTENT_HANDLE_STATUS = '3' then 'error3' end as consistent,INCONSISTENT_HANDLE_STATUS ")
		   .append("         from CHECK_COMPLIANCE_RESULT_INFO where SERVER_NAME = '"+ServerName+"' and APPSYS_CODE='"+appsysCode+"' and to_char(START_DATETIME, 'yyyyMMdd hh24:mi:ss') between '"+flucDatetime+"' and '"+lastDate+"')  ")
		   .append("     group by consistent))) as \"Notreatment\",max((select sum(decode(consistent,'error3', nvl(INCONSISTENT_HANDLE_STATUS, 0),0))  ")
		   .append("       from(select consistent,COUNT(INCONSISTENT_HANDLE_STATUS) as INCONSISTENT_HANDLE_STATUS  ")
		   .append("  from (select case when INCONSISTENT_HANDLE_STATUS = '4' then 'normal' when INCONSISTENT_HANDLE_STATUS = '1' then 'error1'  ")
		   .append("              when INCONSISTENT_HANDLE_STATUS = '2' then 'error2'  ")
		   .append("              when INCONSISTENT_HANDLE_STATUS = '3' then 'error3'  end as consistent, INCONSISTENT_HANDLE_STATUS  ")
		   .append("        from CHECK_COMPLIANCE_RESULT_INFO where SERVER_NAME = '"+ServerName+"' and APPSYS_CODE='"+appsysCode+"' and to_char(START_DATETIME, 'yyyyMMdd hh24:mi:ss') between '"+flucDatetime+"' and '"+lastDate+"')  ")
		   .append("  group by consistent)))  as \"Processing\", max((select sum(decode(consistent, 'error2', nvl(INCONSISTENT_HANDLE_STATUS, 0),  0))  ")
		   .append("      from(select consistent, COUNT(INCONSISTENT_HANDLE_STATUS) as INCONSISTENT_HANDLE_STATUS  ")
		   .append("  from (select case when INCONSISTENT_HANDLE_STATUS = '4' then 'normal'  ")
		   .append("   when INCONSISTENT_HANDLE_STATUS = '1' then 'error1'  ")
		   .append("   when INCONSISTENT_HANDLE_STATUS = '2' then  'error2'   ")
		   .append("   when INCONSISTENT_HANDLE_STATUS = '3' then    'error3'   end as consistent, INCONSISTENT_HANDLE_STATUS   ")
		   .append("     from CHECK_COMPLIANCE_RESULT_INFO where SERVER_NAME = '"+ServerName+"' and APPSYS_CODE='"+appsysCode+"'   and to_char(START_DATETIME, 'yyyyMMdd hh24:mi:ss') between '"+flucDatetime+"' and '"+lastDate+"')   ")
		   .append("  group by consistent)))  as \"Processed\",  max((select sum(decode(consistent,   'normal',     nvl(INCONSISTENT_HANDLE_STATUS, 0),     0))   ")
		   .append("      from(select consistent,  COUNT(INCONSISTENT_HANDLE_STATUS) as INCONSISTENT_HANDLE_STATUS  ")
		   .append("    from (select case when INCONSISTENT_HANDLE_STATUS = '4' then 'normal'  ")
		   .append("       when INCONSISTENT_HANDLE_STATUS = '1' then 'error1'  ")
		   .append("   when INCONSISTENT_HANDLE_STATUS = '2' then 'error2'  ")
		   .append("        when INCONSISTENT_HANDLE_STATUS = '3' then    'error3'  end as consistent,  INCONSISTENT_HANDLE_STATUS  ")
		   .append("    from CHECK_COMPLIANCE_RESULT_INFO where SERVER_NAME = '"+ServerName+"' and APPSYS_CODE='"+appsysCode+"'  and to_char(START_DATETIME, 'yyyyMMdd hh24:mi:ss') between  '"+flucDatetime+"' and '"+lastDate+"')  ")
		   .append("   group by consistent)))  as \"normal_1\" from (select consistent, COUNT(INCONSISTENT_HANDLE_STATUS) as INCONSISTENT_HANDLE_STATUS  ")
		   .append("    from (select case  when INCONSISTENT_HANDLE_STATUS = '4' then 'normal'  ")
		   .append("        when INCONSISTENT_HANDLE_STATUS <> '4' then  'error' end as consistent, INCONSISTENT_HANDLE_STATUS  ")
		   .append("     from CHECK_COMPLIANCE_RESULT_INFO where SERVER_NAME = '"+ServerName+"' and APPSYS_CODE='"+appsysCode+"' and to_char(START_DATETIME, 'yyyyMMdd hh24:mi:ss') between  '"+flucDatetime+"' and '"+lastDate+"') group by consistent)   ") ;
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

	/**
	 * 根据巡检最后一次巡检时间（往前波动一个小时查询）服务器
	 * @param object 
	 * @param flucDatetime 
	 * @param params 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	private List<Map<String,Object>> queryservers(Integer start,Integer limit,String sort,String dir,String LastDate, String flucDatetime, Map<String, Object> params) throws SQLException{
		//根据IP获取应用系统，根据IP和应用系统获取主机名称


		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsysCode as \"appsysCode\",")
		   .append("case when t.appsysCode='COMMON' then '1' else '2' end as \"checkType\", ") //COMMON-常规巡检
		   .append("t.StartDatetime as \"StartDatetime\", ")
		   .append("t.ServerIp as \"ServerIp\", ")
		   .append("server.server_name as \"ServerName\", ")
		   .append("t.appsysCode_ip as \"appsysCode_ip\" ")
		   .append("from (  ")
		    .append(" select b.APPSYS_CODE as appsysCode,")
		   .append("   b.SERVER_NAME as ServerName,")
		   .append("   b.SERVER_IP as ServerIp,  ")
		   .append("   t.appsys_code as appsysCode_ip,  ")
		   .append("   to_char(b.START_DATETIME,'yyyy-MM-dd') as StartDatetime  ")
	       .append(" from CHECK_COMPLIANCE_RESULT_INFO b,v_cmn_servers_info t ")
	       .append(" where b.server_ip=t.server_ip ")
	       .append(" and t.appsys_code in (:sysList) ")
	       .append(" and to_char(b.START_DATETIME,'yyyyMMdd hh24:mi:ss') ")
		   .append(" between '"+flucDatetime+"' and '"+LastDate+"' ")
		   //.append(" and b.SERVER_IP in (:ipList)  ")
		   .append(" ) t,v_cmn_servers_info server where 1=1 ")
		   .append(" and t.appsysCode_ip=server.appsys_code and t.ServerIp=server.server_ip ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("checkType")){
					if(((String) params.get("checkType")).replaceAll("%", "").equals("1")){ //常规巡检
						sql.append(" and t.appsysCode='COMMON' ");
					}else{
						sql.append(" and t.appsysCode='TEMP' ");
					}
				}else if(key.equals("ServerName")){
					sql.append(" and server.server_name like '" + (String) params.get(key)+"'");
				}else if(!key.equals("StartDatetime") && !key.equals("FlucDatetime") && !key.equals("checkstatus")  && !key.equals("checkDate")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and t." + key + " like '" + (String) params.get(key)+"'");
					} else {
						sql.append(" and t." + key + " = '" + (String) params.get(key)+"'");
					}
				}
			}
		}
		sql.append(" order by "+sort+" "+dir);
		Query query = getSession().createSQLQuery(sql.toString())
				.setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
				//.setParameterList("ipList", getPersonalIPList())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setFirstResult(start).setMaxResults(limit);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	/**
	 * 根据最后一次巡检时间（往前波动一个小时查询）获取服务器信息   - 不分页

	 * @param object 
	 * @param flucDatetime 
	 * @param params 
	 */
	@SuppressWarnings({ "unchecked"})
	@Transactional
	private List<Map<String,Object>> queryserversForCount(
			String LastDate, String flucDatetime, Map<String, Object> params) throws SQLException{
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsysCode as \"appsysCode\",")
		   .append("case when t.appsysCode='COMMON' then '1' else '2' end as \"checkType\", ") //COMMON-常规巡检
		   .append("t.StartDatetime as \"StartDatetime\", ")
		   .append("t.ServerIp as \"ServerIp\", ")
		   .append("server.server_name as \"ServerName\", ")
		   .append("t.appsysCode_ip as \"appsysCode_ip\" ")
		   .append("from (  ")
		   .append(" select b.APPSYS_CODE as appsysCode,")
		   .append("   b.SERVER_NAME as ServerName,")
		   .append("   b.SERVER_IP as ServerIp,  ")
		   .append("   t.appsys_code as appsysCode_ip,  ")
		   .append("   to_char(b.START_DATETIME,'yyyy-MM-dd') as StartDatetime  ")
	       .append(" from CHECK_COMPLIANCE_RESULT_INFO b,v_cmn_servers_info t ")
	       .append(" where b.server_ip=t.server_ip ")
	       .append(" and t.appsys_code in (:sysList) ")
	       .append(" and to_char(b.START_DATETIME,'yyyyMMdd hh24:mi:ss') ")
		   .append(" between '"+flucDatetime+"' and '"+LastDate+"' ")
		   //.append(" and b.SERVER_IP in (:ipList)  ")
		   .append(" ) t,v_cmn_servers_info server where 1=1 ")
		   .append(" and t.appsysCode_ip=server.appsys_code and t.ServerIp=server.server_ip ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("checkType")){
					if(((String) params.get("checkType")).replaceAll("%", "").equals("1")){ //常规巡检
						sql.append(" and t.appsysCode='COMMON' ");
					}else{
						sql.append(" and t.appsysCode='TEMP' ");
					}
				}else if(key.equals("ServerName")){
					sql.append(" and server.server_name like '" + (String) params.get(key)+"'");
				}else if(!key.equals("StartDatetime") && !key.equals("FlucDatetime") && !key.equals("checkstatus")  && !key.equals("checkDate")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and t." + key + " like '" + (String) params.get(key)+"'");
					} else {
						sql.append(" and t." + key + " = '" + (String) params.get(key)+"'");
					}
				}
			}
		}
		Query query = getSession().createSQLQuery(sql.toString())
				.setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
				//.setParameterList("ipList", getPersonalIPList())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	/**
	 * 查询最后一次巡检时间 - 格式:hh24:mi:ss
	 * @param checkDate 巡检日期
	 */ 
	@SuppressWarnings("unchecked")
	@Transactional
	public List<Map<String, String>> queryLastCheckDate(String checkDate) throws SQLException{
		StringBuilder sql = new StringBuilder();
		sql.append(" select  substr(START_DATETIME,10) as \"StartDatetime\" ")
		   .append(" from ( select  distinct to_char( START_DATETIME,'yyyyMMdd hh24:mi:ss') as START_DATETIME ")
		   .append(" from CHECK_COMPLIANCE_RESULT_INFO  order by START_DATETIME  DESC  ) where rownum=1   ");
		if(checkDate==null || checkDate.equals("")){
			sql.append(" and substr(START_DATETIME, 0, 8)=to_char(sysdate,'yyyyMMdd') ");
		}else{
			sql.append(" and substr(START_DATETIME, 0, 8)='"+checkDate+"' ");
		}
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 查询巡检时间 - Fluc_DATETIME：往前浮动值

	 * @param checkDate 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public List<Map<String, String>> queryCheckDate(String checkDate) throws SQLException{
		StringBuilder sql = new StringBuilder();
		sql.append(" select  substr(START_DATETIME,10) as \"StartDatetime\" ,substr(START_DATETIME,10) as \"FlucDatetime\" ")
		   .append(" from ( select  distinct to_char( START_DATETIME,'yyyyMMdd hh24:mi:ss') as START_DATETIME ")
		   .append(" from CHECK_COMPLIANCE_RESULT_INFO order by START_DATETIME  DESC ) where 1=1  ");
		if(checkDate==null){
			sql.append("  and substr(START_DATETIME, 0, 8)=to_char( sysdate,'yyyyMMdd') ");
		}else{
			sql.append(" and substr(START_DATETIME, 0, 8)='"+checkDate+"' ");
		}
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 获取配置的浮动时间（分钟）

	 * @return
	 */
	public int getFloatMinutes(){
		int floatTime = 0 ;
		//获取数据字典中CHECK_FLOAT_TIME对应的数值

		List<Map<String, Object>> list = subItemService.findMapByItem("CHECK_FLOAT_TIME"); 
		if(list!=null && list.size()>0){
			floatTime = Integer.valueOf(list.get(0).get("value").toString());
		}
		return floatTime;
	}
	
	/**
	 * 查询明细纪录
	 * @param appsysCode 应用系统
	 * @param checkDate 巡检时间
	 * @param serverName 主机名称
	 * @param LastDate 巡检时间
	 * @param FlucDatetime 浮动后的巡检时间
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public List<Map<String, String>> oneDetail(Integer start, Integer limit, String sort, String dir,
			String appsysCode,String appsysCode_ip,String checkDate,String serverName,Map<String, Object> params, 
			String LastDate, String FlucDatetime, String checkstatus,
			String queryCheckType,String queryServer) throws SQLException{
		/*
		 * InconsistentHandleStatus：

		 *    1-未处理   2-已完成(已解决) 3-处理中   4-正常   5-异常   6-未解决

		 */
		String lastDateTime= LastDate ;
		String flucDatetime= FlucDatetime ;
		List<String> serverNames = null;
		if(serverName!=null && !serverName.equals("")){
			serverNames = new ArrayList<String>();
			String[] str = serverName.split(",") ;
			for(String name : str){
				if(!serverNames.contains(name)){
					serverNames.add(name);
				}
			}
		}
		List<String> appsysCodes = null;
		if(appsysCode!=null && !appsysCode.equals("")){
			appsysCodes = new ArrayList<String>();
			String[] str = appsysCode.split(",") ;
			for(String code : str){
				if(!appsysCodes.contains(code)){
					appsysCodes.add(code);
				}
			}
		}
		List<String> appsysCodes_ip = null;
		if(appsysCode_ip!=null && !appsysCode_ip.equals("")){
			appsysCodes_ip = new ArrayList<String>();
			String[] str = appsysCode_ip.split(",") ;
			for(String code : str){
				if(!appsysCodes_ip.contains(code)){
					appsysCodes_ip.add(code);
				}
			}
		}
		//获取当天最近一次的检查时间

		List<Map<String,String>> CheckDateList = queryLastCheckDate(checkDate.replace("-", ""));
		if(CheckDateList.size()!=0){
			String sdt = checkDate.concat(" ").concat(CheckDateList.get(0).get("StartDatetime"));
			FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(sdt,1,-getFloatMinutes()); //时间前移
			LastDate = DateFunction.getDateTimeByFormatAndOffset(sdt,1,getFloatMinutes()); //时间后移
		}
		if(lastDateTime!=null && flucDatetime!=null){
			//查询字段的'巡检时间'不为空时
			if(!flucDatetime.equals("")){ 
				if(flucDatetime.equals("all")){
					FlucDatetime = checkDate.concat(" 00:00:00");
					LastDate = checkDate.concat(" 23:59:59");
				}else{
					//时间前移
					FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(lastDateTime),1,-getFloatMinutes());
					//时间后移
					LastDate = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(lastDateTime),1,getFloatMinutes());
				}
			}
		}
		//yyyy-MM-dd转yyyyMMdd
		LastDate = LastDate.replace("-", "");
		FlucDatetime = FlucDatetime.replace("-", "");
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsysCode as \"appsysCode\",  ")
		   .append("    case when t.appsysCode='COMMON' then '1' else '2' end as \"checkType\", ") //COMMON-常规巡检
	       .append("    t.ServerIp as \"ServerIp\", ")
	       .append("    server.server_name as \"ServerName\", ") 
	       .append("    t.StartDatetime as \"StartDatetime\", ")
		   .append("    t.RuleName as \"RuleName\", ")
		   .append("    t.RuleString as \"RuleString\", ")
	       .append("    t.InconsistentHandleStatus as \"InconsistentHandleStatus\", ")
	       .append("    t.ExtendObject as \"ExtendObject\", ")
	       .append("    t.RuleResultString as \"RuleResultString\", ")
	       .append("    t.appsysCode_ip as \"appsysCode_ip\",  ")
	       .append("    t.subItemDetail as \"subItemDetail\",  ")
	       .append("    t.isConsistent as \"isConsistent\"  ")
		   .append("from (select a.APPSYS_CODE as appsysCode ,")
		   .append("         a.IS_CONSISTENT as isConsistent ,")
		   .append("         a.SUB_ITEM_DETAIL as subItemDetail ,")
		   .append("    	 a.SERVER_IP as ServerIp,to_char(a.START_DATETIME,'yyyy-MM-dd hh24:mi:ss') as StartDatetime, ")
		   .append("    	 a.RULE_NAME as RuleName,a.RULE_STRING as RuleString, ")
		   .append("    	 a.INCONSISTENT_HANDLE_STATUS as InconsistentHandleStatus,a.EXTEND_OBJECT as ExtendObject, ")
		   .append("         a.rule_result_string as RuleResultString,b.appsys_code as appsysCode_ip  ") 
		   .append("     from CHECK_COMPLIANCE_RESULT_INFO a,v_cmn_servers_info b  ")
		   .append("     where a.server_ip=b.server_ip and a.server_name=b.server_name")
		   .append("        and b.appsys_code in (:sysList) ")
		   .append("        and to_char(a.START_DATETIME,'yyyyMMdd hh24:mi:ss') between '"+FlucDatetime+"' and '"+LastDate+"' ")
		   .append("        and a.appsys_code in (:appsysCodes) and b.server_name in (:serverNames)) t,v_cmn_servers_info server ")
		   .append(" where 1=1 ")
		   .append("    and t.appsysCode_ip=server.appsys_code and t.ServerIp=server.server_ip ");
		if(!params.containsKey("InconsistentHandleStatus") ){
	      	sql.append(" and t.InconsistentHandleStatus in ('1','3')  "); //未处理和处理中的数据
	    }else{
	    	String status = String.valueOf(params.get("InconsistentHandleStatus")) ;
	    	if(!status.equals("")){
	    		if(status.equals("5")){  //异常
		    		sql.append(" and t.InconsistentHandleStatus<>'4' ");
		    	}else if(status.equals("6")){ //未解决


		    	}else if(status.equals("7")){ //全部
		    	}else{
		    		sql.append(" and t.InconsistentHandleStatus='"+status+"'");
		    	}
	    	}
	    }
		if(params.containsKey("ServerIp") ){
	      	sql.append(" and t.ServerIp like '%" + params.get("ServerIp").toString().replaceAll("%", "")+"%'"); 
	    }
		if(params.containsKey("subItemDetail") ){
			String value = params.get("subItemDetail").toString().replaceAll("%", "") ;
			if(value!=null && value.equals("OK")){
				sql.append(" and t.subItemDetail is null"); 
			}else{ //大写比较
				sql.append(" and upper(t.subItemDetail) like '%" + value +"%'"); 
			}
	    }
		if(queryCheckType!=null && !queryCheckType.equals("") ){
			if(queryCheckType.equals("1")){ //常规巡检
				sql.append(" and t.appsysCode='COMMON'");
			}else{
				sql.append(" and t.appsysCode='TEMP' ");
			}
	    }
	    if(queryServer!=null && !queryServer.equals("") ){
	      	sql.append(" and server.ServerName like '%" + queryServer+"%'");
	    }
	    sql.append(" order by "+sort+" "+dir);
		Query query = getSession().createSQLQuery(sql.toString())
								  .addScalar("appsysCode", StringType.INSTANCE)
								  .addScalar("checkType", StringType.INSTANCE)
								  .addScalar("ServerIp", StringType.INSTANCE)
								  .addScalar("ServerName", StringType.INSTANCE)
								  .addScalar("StartDatetime", StringType.INSTANCE)
								  .addScalar("RuleName", StringType.INSTANCE)
								  .addScalar("RuleString", StringType.INSTANCE)
								  .addScalar("RuleString", StringType.INSTANCE)
								  .addScalar("InconsistentHandleStatus", StringType.INSTANCE)
								  .addScalar("ExtendObject", StringType.INSTANCE)
								  .addScalar("appsysCode_ip", StringType.INSTANCE)
								  .addScalar("RuleResultString", StringType.INSTANCE)
								  .addScalar("subItemDetail", StringType.INSTANCE)
								  .addScalar("isConsistent", StringType.INSTANCE)
								  .setFirstResult(start).setMaxResults(limit)
				                  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		query.setParameterList("serverNames", serverNames);
		query.setParameterList("appsysCodes", appsysCodes);
		query.setParameterList("sysList", appsysCodes_ip);
		List<Map<String,String>> list=query.list();
		List<Map<String,String>> result = new ArrayList<Map<String,String>>();
		for(int i=0;i<list.size();i++){
			HashMap<String,String> map=new HashMap<String,String>();
			List<String> detailList=new ArrayList<String>();
			String subItemDetail=(String) list.get(i).get("subItemDetail");
			map.put("appsysCode", list.get(i).get("appsysCode"));
			map.put("checkType", list.get(i).get("checkType"));
			map.put("ServerIp", list.get(i).get("ServerIp"));
			map.put("ServerName", list.get(i).get("ServerName"));
			map.put("RuleName", list.get(i).get("RuleName"));
			map.put("RuleString", list.get(i).get("RuleString"));
			map.put("InconsistentHandleStatus", list.get(i).get("InconsistentHandleStatus"));
			map.put("ExtendObject", list.get(i).get("ExtendObject"));
			map.put("RuleResultString", list.get(i).get("RuleResultString"));
			map.put("appsysCode_ip", list.get(i).get("appsysCode_ip"));
			map.put("isConsistent", list.get(i).get("isConsistent"));
			String[] itemDetail=list.get(i).get("subItemDetail").split(";");
			StringBuffer sb = new StringBuffer();
			for(int n=0;n<itemDetail.length;n++){
				if(!itemDetail[n].contains("CheckDate")){
						sb.append(itemDetail[n]);
						sb.append(";");
				}
			}
			map.put("subItemDetail", sb.toString().substring(0,sb.toString().lastIndexOf(";")));
			if(subItemDetail!=null){
				if(subItemDetail.split(";").length>0){
					String[] StartDatetime= subItemDetail.split(";");
					for(int m=0;m<StartDatetime.length;m++){
						if(StartDatetime[m].contains("CheckDate")){
							String datetime=StartDatetime[m].substring(StartDatetime[m].indexOf("=")+1);
							datetime=datetime.substring(0,4).concat("-").concat(datetime.substring(4,6)).concat("-").concat(datetime.substring(6,8)).concat(" ").concat(datetime.substring(8,10)).concat(":").concat(datetime.substring(10,12)).concat(":").concat(datetime.substring(12,14)) ;
							map.put("StartDatetime", datetime);
						}
					}
				}
			}
			result.add(map);
		}
		return result;
	}
	
	/**
	 * 获取明细纪录总数量
	 * @param appsysCode 应用系统
	 * @param checkDate 巡检时间
	 * @param serverName 主机名称
	 * @param LastDate 巡检时间
	 * @param FlucDatetime 浮动后的巡检时间
	 */
	@Transactional
	public Long countOneDetail(String appsysCode,String appsysCode_ip,String checkDate,String serverName,Map<String, Object> params, 
			String LastDate, String FlucDatetime, String checkstatus,
			String queryCheckType,String queryServer) throws SQLException{
		/*
		 * InconsistentHandleStatus：
		 *    1-未处理   2-已完成(已解决) 3-处理中   4-正常   5-异常   6-未解决
		 */
		String lastDateTime= LastDate ;
		String flucDatetime= FlucDatetime ;
		List<String> serverNames = null;
		if(serverName!=null && !serverName.equals("")){
			serverNames = new ArrayList<String>();
			String[] str = serverName.split(",") ;
			for(String name : str){
				if(!serverNames.contains(name)){
					serverNames.add(name);
				}
			}
		}
		List<String> appsysCodes = null;
		if(appsysCode!=null && !appsysCode.equals("")){
			appsysCodes = new ArrayList<String>();
			String[] str = appsysCode.split(",") ;
			for(String code : str){
				if(!appsysCodes.contains(code)){
					appsysCodes.add(code);
				}
			}
		}
		List<String> appsysCodes_ip = null;
		if(appsysCode_ip!=null && !appsysCode_ip.equals("")){
			appsysCodes_ip = new ArrayList<String>();
			String[] str = appsysCode_ip.split(",") ;
			for(String code : str){
				if(!appsysCodes_ip.contains(code)){
					appsysCodes_ip.add(code);
				}
			}
		}
		//获取当天最近一次的检查时间
		List<Map<String,String>> CheckDateList = queryLastCheckDate(checkDate.replace("-", ""));
		if(CheckDateList.size()!=0){
			String sdt = checkDate.concat(" ").concat(CheckDateList.get(0).get("StartDatetime"));
			FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(sdt,1,-getFloatMinutes()); //时间前移
			LastDate = DateFunction.getDateTimeByFormatAndOffset(sdt,1,getFloatMinutes()); //时间后移
		}
		if(lastDateTime!=null && flucDatetime!=null){
			//查询字段的'巡检时间'不为空时
			if(!flucDatetime.equals("")){ 
				if(flucDatetime.equals("all")){
					FlucDatetime = checkDate.concat(" 00:00:00");
					LastDate = checkDate.concat(" 23:59:59");
				}else{
					//时间前移
					FlucDatetime = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(lastDateTime),1,-getFloatMinutes());
					//时间后移
					LastDate = DateFunction.getDateTimeByFormatAndOffset(checkDate.concat(" ").concat(lastDateTime),1,getFloatMinutes());
				}
			}
		}
		//yyyy-MM-dd转yyyyMMdd
		LastDate = LastDate.replace("-", "");
		FlucDatetime = FlucDatetime.replace("-", "");
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) ")
		   .append("from (select distinct t.appsysCode as \"appsysCode\", ")
		   .append("    case when t.appsysCode='COMMON' then '1' else '2' end as \"checkType\", ") //COMMON-常规巡检
	       .append("    t.ServerIp as \"ServerIp\", ")
	       .append("    server.server_name as \"ServerName\", ") 
	       .append("    t.StartDatetime as \"StartDatetime\", ")
		   .append("    t.RuleName as \"RuleName\", ")
		   .append("    t.RuleString as \"RuleString\", ")
	       .append("    t.InconsistentHandleStatus as \"InconsistentHandleStatus\", ")
	       .append("    t.ExtendObject as \"ExtendObject\", ")
	       .append("    t.appsysCode_ip as \"appsysCode_ip\",  ")
	       .append("    t.subItemDetail as \"subItemDetail\",  ")
	       .append("    t.isConsistent as \"isConsistent\"  ")
		   .append("from (select a.APPSYS_CODE as appsysCode ,")
		   .append("         a.IS_CONSISTENT as isConsistent ,")
		   .append("         a.SUB_ITEM_DETAIL as subItemDetail ,")
		   .append("    	 a.SERVER_IP as ServerIp,to_char(a.START_DATETIME,'yyyy-MM-dd hh24:mi:ss') as StartDatetime, ")
		   .append("    	 a.RULE_NAME as RuleName,a.RULE_STRING as RuleString, ")
		   .append("    	 a.INCONSISTENT_HANDLE_STATUS as InconsistentHandleStatus,a.EXTEND_OBJECT as ExtendObject, ")
		   .append("         b.appsys_code as appsysCode_ip  ") 
		   .append("     from CHECK_COMPLIANCE_RESULT_INFO a,v_cmn_servers_info b ")
		   .append("     where a.server_ip=b.server_ip and a.server_name=b.server_name")
		   .append("        and b.appsys_code in (:sysList) ")
		   .append("        and to_char(a.START_DATETIME,'yyyyMMdd hh24:mi:ss') between '"+FlucDatetime+"' and '"+LastDate+"' ")
		   .append("        and a.appsys_code in (:appsysCodes) and b.server_name in (:serverNames)) t,v_cmn_servers_info server ")
		   .append(" where 1=1 ")
		   .append("    and t.appsysCode_ip=server.appsys_code and t.ServerIp=server.server_ip ");
		if(!params.containsKey("InconsistentHandleStatus") ){
	      	sql.append(" and t.InconsistentHandleStatus in ('1','3')  "); //未处理和处理中的数据
	    }else{
	    	String status = String.valueOf(params.get("InconsistentHandleStatus")) ;
	    	if(!status.equals("")){
	    		if(status.equals("5")){  //异常
		    		sql.append(" and t.InconsistentHandleStatus<>'4' ");
		    	}else if(status.equals("6")){ //未解决

		    	}else if(status.equals("7")){ //全部
		    	}else{
		    		sql.append(" and t.InconsistentHandleStatus='"+status+"'");
		    	}
	    	}
	    }
		if(params.containsKey("ServerIp") ){
	      	sql.append(" and t.ServerIp like '%" + params.get("ServerIp").toString().replaceAll("%", "")+"%'"); 
	    }
		if(params.containsKey("subItemDetail") ){
			String value = params.get("subItemDetail").toString().replaceAll("%", "") ;
			if(value!=null && value.equals("OK")){
				sql.append(" and t.subItemDetail is null"); 
			}else{ //大写比较
				sql.append(" and upper(t.subItemDetail) like '%" + value +"%'"); 
			}
	    }
		if(queryCheckType!=null && !queryCheckType.equals("") ){
			if(queryCheckType.equals("1")){ //常规巡检
				sql.append(" and t.appsysCode='COMMON'");
			}else{
				sql.append(" and t.appsysCode='TEMP' ");
			}
	    }
	    if(queryServer!=null && !queryServer.equals("") ){
	      	sql.append(" and server.ServerName like '%" + queryServer+"%'");
	    }
	    sql.append(")");
		Query query = getSession().createSQLQuery(sql.toString());
		query.setParameterList("serverNames", serverNames);
		query.setParameterList("appsysCodes", appsysCodes);
		query.setParameterList("sysList", appsysCodes_ip);
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 单条明细纪录
	 * @param customer
	 */
	@Transactional
	public Object findHand(String ServerName, String StartDatetime , String RuleName) throws SQLException{
		StringBuilder sql = new StringBuilder();
		
		String datetime=StartDatetime.replace(" ", "").replace(":", "").replace("-", "");
		sql.append("select  m.ServerName as \"ServerName\",")
		.append(" m.appsysCode as \"appsysCode\", ")
		.append("m.RuleName as \"RuleName\", ")
		.append("m.InconsistentHandleResult as \"InconsistentHandleResult\", ")
		.append("m.InconsistentHandleDesc as \"InconsistentHandleDesc\", ")
		.append("m.InconsistentHandleStatus as \"InconsistentHandleStatus\", ")
		.append("m.InconsistentHandleUser as \"InconsistentHandleUser\", ")
		.append("m.InconsistentHandleDate as \"InconsistentHandleDate\", ")
		.append("m.ExtendObject as \"ExtendObject\" ")
		.append(" from (  ")
		.append(" select tb.server_name as ServerName,  ")
		.append(" tb.appsys_code as appsysCode, tb.rule_name as RuleName,  ")
		.append(" tb.inconsistent_handle_desc as InconsistentHandleDesc,  ")
		.append(" tb.inconsistent_handle_result as InconsistentHandleResult, ")
		.append(" tb.inconsistent_handle_status as InconsistentHandleStatus,")
		.append(" tb.inconsistent_handle_user as InconsistentHandleUser,  ")
		.append(" to_char(tb.inconsistent_handle_date ,'yyyyMMdd hh24:mi:ss') as InconsistentHandleDate,  ")
		.append(" tb.extend_object as ExtendObject   from CHECK_COMPLIANCE_RESULT_INFO tb ")
		.append(" where instr(tb.sub_item_detail,'"+datetime+"') <> 0  and tb.server_name='"+ServerName+"'  and tb.rule_name='"+RuleName+"' ) m where 1=1 ");
		
		
		
		
		
		
		
	/*	
		hql.append("select new map(");
		hql.append(" tb.ServerName as ServerName,");
		hql.append(" tb.appsysCode as appsysCode,");
		hql.append(" to_char(tb.StartDatetime ,'yyyyMMdd hh24:mi:ss') as StartDatetime,");
		hql.append(" tb.RuleName as RuleName,");
		hql.append(" tb.InconsistentHandleDesc as InconsistentHandleDesc,");
		hql.append(" tb.InconsistentHandleResult as InconsistentHandleResult,");
		hql.append(" tb.InconsistentHandleStatus as InconsistentHandleStatus,");
		hql.append(" tb.InconsistentHandleUser as InconsistentHandleUser,");
		hql.append(" to_char(tb.InconsistentHandleDate ,'yyyyMMdd hh24:mi:ss') as InconsistentHandleDate,");
		hql.append(" tb.ExtendObject as ExtendObject");
		hql.append("  )from CheckComplianceResultInfoVo tb where instr(tb.SubItemDetail,'20150105155054') <> 0 ");
		hql.append("  and tb.ServerName=:ServerName  and tb.RuleName=:RuleName ");*/
		Query query = (Query) getSession().createSQLQuery(sql.toString())
				  .addScalar("appsysCode", StringType.INSTANCE)
				  .addScalar("ServerName", StringType.INSTANCE)
				  .addScalar("RuleName", StringType.INSTANCE)
				  .addScalar("InconsistentHandleResult", StringType.INSTANCE)
				  .addScalar("InconsistentHandleDesc", StringType.INSTANCE)
				  .addScalar("InconsistentHandleStatus", StringType.INSTANCE)
				  .addScalar("InconsistentHandleUser", StringType.INSTANCE)
				  .addScalar("InconsistentHandleDate", StringType.INSTANCE)
				  .addScalar("ExtendObject", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list=query.list();
		HashMap<String,String> map=new HashMap<String,String>();
		for(int i=0;i<list.size();i++){
			map.put("ServerName", list.get(i).get("ServerName"));
			map.put("appsysCode", list.get(i).get("appsysCode"));
			map.put("RuleName", list.get(i).get("RuleName"));
			map.put("InconsistentHandleResult", list.get(i).get("InconsistentHandleResult"));
			map.put("InconsistentHandleDesc", list.get(i).get("InconsistentHandleDesc"));
			map.put("InconsistentHandleStatus", list.get(i).get("InconsistentHandleStatus"));
			map.put("InconsistentHandleUser", list.get(i).get("InconsistentHandleUser"));
			map.put("InconsistentHandleDate", list.get(i).get("InconsistentHandleDate"));
			map.put("ExtendObject", list.get(i).get("ExtendObject"));
			map.put("StartDatetime", StartDatetime);
		}
		return  map;
	}
	
	/**
	 * 更新处理信息
	 * @param customer
	 */
	@Transactional
	public void update(CheckComplianceResultInfoVo checkComplianceResultInfoVo) {
		getSession().update(checkComplianceResultInfoVo);
	}
	
	/**
	 * 获取实体
	 * @param appChangeId
	 * @return
	 */
	@Transactional
	public CheckComplianceResultInfoVo getResultInfo(String AppsysCode,String ServerName,String StartDatetime,String RuleName)throws SQLException{
		StringBuilder hql = new StringBuilder();
		hql.append("  from CheckComplianceResultInfoVo tb ")
		   .append("  where tb.ServerName=:ServerName and tb.RuleName=:RuleName and tb.appsysCode=:AppsysCode")
		   .append("  and instr(tb.SubItemDetail,'"+StartDatetime+"') <> 0");
		Query query = getSession().createQuery(hql.toString());
		return (CheckComplianceResultInfoVo) query.setString("ServerName",ServerName)
				                                  .setString("AppsysCode",AppsysCode)
												  .setString("RuleName",RuleName)
												  .uniqueResult();
	}
	
	/**
	 * 保存处理单数据

	 * @param ServerName 主机名称
	 * @param StartDatetime 作业执行开始时间

	 * @param RuleName 巡检项

	 * @param Result 处理结果
	 * @param AppsysCode 应用系统
	 * @param HandleState 处理状态

	 * @param Desc 故障描述
	 * @return
	 */
	public void editHand(String ServerName, String StartDatetime, String RuleName, String Result, 
			String AppsysCode,String HandleState,String Desc,HttpServletRequest request) throws SQLException{
		//插入执行日志表

		Date startDate = new Date();
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(AppsysCode);
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(messages.getMessage("job.error_handle")); //错误处理
		cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus("0"); //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		Long logJnlNo = cmnLogService.save(cmnLog);
		
		//插入详细日志表
		CmnDetailLogVo cdlv = new CmnDetailLogVo();
		cdlv.setLogJnlNo(logJnlNo);
		cdlv.setDetailLogSeq(String.valueOf(1));
		cdlv.setAppsysCode(AppsysCode);
		cdlv.setStepName(messages.getMessage("job.error_handle"));
		cdlv.setJobName(RuleName);
		cdlv.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cdlv.setExecStatus("0");
		cdlv.setExecDate(execdate);
		cdlv.setExecStartTime(Timestamp.valueOf(starttime));
		
		//保存处理单信息
		CheckComplianceResultInfoVo	vo=(CheckComplianceResultInfoVo)getResultInfo(AppsysCode,ServerName,StartDatetime.replace(" ", "").replace(":", "").replace("-", ""),RuleName);
		ServletRequestDataBinder binder = new ServletRequestDataBinder(vo);
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
	    binder.bind(request);
	    Calendar cal = Calendar.getInstance();
		Long ss=cal.getTimeInMillis();
		Timestamp upTime = new Timestamp(ss);
		vo.setInconsistentHandleDesc(Desc);
		vo.setInconsistentHandleResult(Result);
		vo.setInconsistentHandleStatus(Integer.valueOf(HandleState));
		vo.setInconsistentHandleDate(upTime); //完成时间
	    vo.setInconsistentHandleUser(securityUtils.getUser().getUsername());
		update(vo);
		
		//修改日志信息数据
		Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cdlv.setExecCompletedTime(timestamp);
		cdlv.setExecCreatedTime(timestamp);
		cdlv.setExecUpdatedTime(timestamp);
		cmnDetailLogService.save(cdlv);
		cmnLog.setExecCompletedTime(timestamp);
		cmnLog.setExecUpdatedTime(timestamp);
		cmnLogService.update(cmnLog);
	}
		
	
	/**
	 * 保存处理单数据
	 * @param serverName 主机名称
	 * @param startDatetime 作业执行开始时间
	 * @param username 处理人
	 * @param result 处理结果
	 * @param desc 问题描述
	 * @param ruleName 巡检规则名称
	 * @param appsysCodes 应用系统
	 * @param handleState 处理状态

	 * @return
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public void editEntr(List<String> serverNames, List<String> startDatetimes, String username, String result, 
			String desc,List<String> ruleNames,List<String> appsysCodes,String handleState) throws SQLException{
		//插入执行日志表

		Date startDate = new Date();
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode("--");
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(messages.getMessage("job.error_handle")); //错误处理
		cmnLog.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus("0"); //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		Long logJnlNo = cmnLogService.save(cmnLog);
		
		for(int i = 0;i<serverNames.size();i++){
			//插入详细日志表

			Date startDateDet = new Date();
			String execdateDet = new SimpleDateFormat("yyyyMMdd").format(startDateDet) ;
			String starttimeDet = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDateDet);
			CmnDetailLogVo cdlv = new CmnDetailLogVo();
			cdlv.setLogJnlNo(logJnlNo);
			cdlv.setDetailLogSeq(String.valueOf(i));
			cdlv.setAppsysCode(appsysCodes.get(i));
			cdlv.setStepName(messages.getMessage("job.error_handle"));
			cdlv.setJobName(ruleNames.get(i));
			cdlv.setLogType("3"); //1:应用发布、2：工具箱、3：自动巡检
			cdlv.setExecStatus("0");
			cdlv.setExecDate(execdateDet);
			cdlv.setExecStartTime(Timestamp.valueOf(starttimeDet));
			//执行数据库操作

			StringBuilder sql = new StringBuilder();
			sql.append(" update CHECK_COMPLIANCE_RESULT_INFO set  INCONSISTENT_HANDLE_DESC='"+desc+"' ,INCONSISTENT_HANDLE_RESULT='"+result+"' ,INCONSISTENT_HANDLE_USER='"+username+"' , ");
			sql.append(" INCONSISTENT_HANDLE_STATUS='"+handleState+"',INCONSISTENT_HANDLE_DATE=sysdate");
		    sql.append(" where SERVER_NAME='"+serverNames.get(i)+"'  and  to_char(START_DATETIME,'yyyyMMdd hh24:mi:ss')='"+startDatetimes.get(i)+"'  ");
		    sql.append(" and RULE_NAME='"+ruleNames.get(i)+"' and APPSYS_CODE='"+appsysCodes.get(i)+"'  ");
			getSession().createSQLQuery(sql.toString()).executeUpdate();
			//保存日志信息
			Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cdlv.setExecCompletedTime(timestamp);
			cdlv.setExecCreatedTime(timestamp);
			cdlv.setExecUpdatedTime(timestamp);
			cmnDetailLogService.save(cdlv);
		}
		Timestamp ts2 = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts2);
		cmnLog.setExecUpdatedTime(ts2);
		cmnLogService.update(cmnLog);
	}
	
	/**
	 * 获取所有巡检规则
	 */
	public Object queryRuleName() throws SQLException{
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map( tb.RuleName as RuleName ) from CheckComplianceResultInfoVo tb ");
		Query query = getSession().createQuery(hql.toString());
		return  query.list();
	}
	
	/**
	 * 查询巡检时间
	 * @param codes 应用系统编号 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public List<Map<String, Object>> getAppsysByCodes(List<String> codes) throws SQLException{
		StringBuilder sql = new StringBuilder();
		sql.append("select appsys_code as \"appsysCode\" ,systemname as \"appsysName\" ")
		   .append("from v_cmn_app_info@DB_JEDA_LINK")
		   .append("where appsys_code in (:appsysCodes) ");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		query.setParameterList("appsysCodes", codes);
		return query.list();
	}
	
	/**
	 * 读取文件内容
	 * @param serverName 主机名称
	 * @param checkTime 检查时间（yyyyMMddHHmm）
	 * @param log 日志文件名称
	 */
	public String readFile(String serverName,String startTime,String log) throws FileNotFoundException,IOException {
		String filePath="";
		//时间格式 yyyyMMddHHmm
		String checkTime = startTime.replace(" ", "").replace(":", "").replace("-", "");
		//m_主机名_时间_对应日志名称(m:日志来源<maop系统>)
		String logName = "m_"+serverName.concat("_").concat(checkTime).concat("_").concat(log.trim());
		if(isWindows){
			filePath=messages.getMessage("check.sysLogPathForWin").concat(File.separator).concat(checkTime.substring(0, 8)).concat(File.separator).concat(logName);
		}else{
			filePath=messages.getMessage("check.sysLogPathForLinux").concat(File.separator).concat(checkTime.substring(0, 8)).concat(File.separator).concat(logName);
		}
		/* 用于测试
		 * filePath = "D://maop/log/check/syslog/20140219/BCS-DB-TE01V_201402191953_syslog_check.log";*/
		logger.info("Log File Path : "+filePath);
		String fileText = "";
		if(new File(filePath).exists()){
			Reader reader = null;
			if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
				reader = new InputStreamReader(new FileInputStream(filePath),"utf-8");
			} else {
				reader = new InputStreamReader(new FileInputStream(filePath),"GBK");
			}
			BufferedReader br = new BufferedReader(reader);
			String strLine = new String();
			while((strLine = br.readLine()) != null){
				fileText+=strLine+"\n";
			}
			br.close();
		}
		return fileText;
	}
	
	/**
	 * 获取当前用户权限系统内的所有IP列表
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalIPList(){
    	List<String> ipList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.server_ip as \"serverIp\" ")
		.append(" from v_cmn_servers_info t  ")
		.append(" where t.delete_flag='0'  ")      //未删除

		.append(" and t.appsys_code in (:sysList) ")
		.append(" and t.bsa_agent_flag = '1' ");   //已安装代理

		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
												.setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.list();
    	if(list == null || (list != null && list.size() == 0)){
    		ipList.add("");
    	}else{
    		ipList = new ArrayList<String>();
    		for (Map<String, Object> map : list) {
    			ipList.add(map.get("serverIp").toString());
    		}
    	}
    	return ipList;
	}
	

}




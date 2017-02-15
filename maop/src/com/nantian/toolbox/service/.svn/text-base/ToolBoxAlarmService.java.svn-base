package com.nantian.toolbox.service;

import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.config.service.ItemService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.toolbox.vo.BusinessAlarmRelationVo;
import com.nantian.toolbox.vo.BusinessFieldDataInfoVo;
import com.nantian.toolbox.vo.BusinessImpactInfoVo;
import com.nantian.toolbox.vo.BusinessKeyWordRelationVo;
import com.nantian.toolbox.vo.MonitorEventTypeConfigVo;
import com.nantian.toolbox.vo.MonitorPolicyConfigVo;
import com.nantian.toolbox.vo.MonitorWarninginfoVo;
import com.nantian.toolbox.vo.ToolBoxEventGroupInfoVo;
import com.nantian.toolbox.vo.ToolBoxKeyWordInfoVo;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ToolBoxAlarmService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ToolBoxAlarmService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	@Autowired
	private SecurityUtils securityUtils; 
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
	private ItemService itemService;
	@Autowired
	private ToolBoxService toolBoxService;
	private String imapctTypeDic = "BUSINESS_IMPACT_TYPE";
	private String imapctLevelDic = "BUSINESS_IMPACT_LEVEL";
	
	//业务影响级别与展示颜色映射关系
	public static Map<String,String> levelColorMap = new HashMap<String,String>();
	static{
		levelColorMap.put("最高", "red");
		levelColorMap.put("高", "orange");
		levelColorMap.put("中", "brown");
		levelColorMap.put("低", "black");
	}

	/**
	 * 构造方法	 */
	public ToolBoxAlarmService() {
		fields.put("event_id", FieldType.STRING);
		fields.put("customerseverity", FieldType.INTEGER);
		fields.put("device_id", FieldType.STRING);		
		fields.put("device_ip", FieldType.STRING);
		fields.put("alarmobject", FieldType.STRING);
		fields.put("componenttype", FieldType.STRING);
		fields.put("component", FieldType.STRING);
		fields.put("subcomponent", FieldType.STRING);	
		fields.put("summarycn", FieldType.STRING);
		fields.put("eventstatus", FieldType.INTEGER);
		
		fields.put("first_time", FieldType.TIMESTAMP);
		fields.put("last_time", FieldType.TIMESTAMP);		
		fields.put("alarminstance", FieldType.STRING);
		fields.put("appname", FieldType.STRING);
		fields.put("managebycenter", FieldType.INTEGER);
		fields.put("managebyuser", FieldType.STRING);
		fields.put("managetimeexceed", FieldType.STRING);	
		fields.put("managetime", FieldType.TIMESTAMP);
		fields.put("maintainstatus", FieldType.INTEGER);
		fields.put("repeat_number", FieldType.INTEGER);
		fields.put("mgtorg", FieldType.STRING);		
		fields.put("orgname", FieldType.STRING);
		fields.put("event_group", FieldType.STRING);
		fields.put("monitor_tool", FieldType.STRING);
		fields.put("is_ticket", FieldType.STRING);
		fields.put("n_ticketid", FieldType.STRING);	
		fields.put("ump_id", FieldType.STRING);
		fields.put("cause_effect", FieldType.STRING);
		fields.put("parent_event_id", FieldType.STRING);
		fields.put("handle_status", FieldType.STRING);		
		fields.put("handle_user", FieldType.STRING);
		fields.put("handle_time_exceed", FieldType.STRING);
		fields.put("close_time", FieldType.TIMESTAMP);
		fields.put("result_summary", FieldType.STRING);
		fields.put("match_tools_message", FieldType.STRING);
		fields.put("alarm_received_time", FieldType.DATE);
	}
	
	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	public Object get(Serializable eventId) {
		return getSession().get(MonitorWarninginfoVo.class, eventId);
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(MonitorWarninginfoVo monitorWarninginfoVo) {
		getSession().save(monitorWarninginfoVo);
	}
	
	/**
	 * 批量保存监控告警信息表.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(List<MonitorWarninginfoVo> monitorWarninginfoVos) {
		for (MonitorWarninginfoVo monitorWarninginfo : monitorWarninginfoVos) {
			getSession().save(monitorWarninginfo);
		}
	}
	
	/**
	 * 批量保存监控事件分类配置表.
	 * 
	 * @param customer
	 */
	@Transactional
	public void saveEventTypes(List<MonitorEventTypeConfigVo> monitorEventTypeConfigVos) {
		for (MonitorEventTypeConfigVo monitorEventTypeConfigVo : monitorEventTypeConfigVos) {
			getSession().saveOrUpdate(monitorEventTypeConfigVo);
		}
	}
	
	/**
	 * 批量保存监控策略配置表.
	 * 
	 * @param customer
	 */
	@Transactional
	public void savePolicyConfig(List<MonitorPolicyConfigVo> monitorPolicyConfigVos,List<MonitorPolicyConfigVo> postMsgsData) {
		if(postMsgsData!=null){
			for (MonitorPolicyConfigVo Vo : postMsgsData) {
				getSession().evict(Vo);
			}
		}
		for (MonitorPolicyConfigVo monitorPolicyConfigVo : monitorPolicyConfigVos) {
			getSession().saveOrUpdate(monitorPolicyConfigVo);
		}
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void saveOrUpdate(MonitorWarninginfoVo monitorWarninginfoVo) {
		getSession().saveOrUpdate(monitorWarninginfoVo);
	}

	/**
	 * 查询监控信息列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmTreatedInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("mw.event_id as event_id,");
		hql.append("mw.customerseverity as customerseverity,");
		hql.append("mw.device_id as device_id,");
		hql.append("mw.device_ip as device_ip,");
		hql.append("mw.alarmobject as alarmobject,");
		hql.append("mw.componenttype as componenttype,");
		hql.append("mw.component as component,");
		hql.append("mw.subcomponent as subcomponent,");
		hql.append("mw.summarycn as summarycn,");
		hql.append("mw.eventstatus as eventstatus,");
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.result_summary as result_summary");
		
		
		hql.append(") from MonitorWarninginfoVo mw where mw.handle_status='2'");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
	         }
	         
	         if(null != stoptime && stoptime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
	         }
		
		hql.append(" order by last_time desc ");
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countTreated(Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from  MonitorWarninginfoVo mw where mw.handle_status='2'  ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
	         }
	         
	         if(null != stoptime && stoptime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
	         }
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 查询监控信息列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmIgnoredInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map( ");
		hql.append("mw.event_id as event_id, ");
		hql.append("mw.customerseverity as customerseverity, ");
		hql.append("mw.device_id as device_id, ");
		hql.append("mw.device_ip as device_ip, ");
		hql.append("mw.alarmobject as alarmobject, ");
		hql.append("mw.componenttype as componenttype, ");
		hql.append("mw.component as component, ");
		hql.append("mw.subcomponent as subcomponent, ");
		hql.append("mw.summarycn as summarycn, ");
		hql.append("mw.eventstatus as eventstatus, ");
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.result_summary as result_summary");
		
		
		hql.append(") from MonitorWarninginfoVo mw where mw.handle_status='3' ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
	         }
	         
	         if(null != stoptime && stoptime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
	         }
		
		hql.append(" order by last_time desc ");
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);;

		if(params.size() > 0){
			query.setProperties(params);
		}
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countIgnored(Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from  MonitorWarninginfoVo mw where mw.handle_status='3'  ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
	         }
	         
	         if(null != stoptime && stoptime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
	         }
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 查询监控信息列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmUntreatedInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("mw.event_id as event_id,");
		hql.append("mw.customerseverity as customerseverity,");
		hql.append("mw.device_id as device_id,");
		hql.append("mw.device_ip as device_ip,");
		hql.append("mw.alarmobject as alarmobject,");
		hql.append("mw.componenttype as componenttype,");
		hql.append("mw.component as component,");
		hql.append("mw.subcomponent as subcomponent,");
		hql.append("mw.summarycn as summarycn,");
		hql.append("mw.eventstatus as eventstatus,");
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.match_tools_message as match_tools_message,");
		hql.append("to_char(mw.alarm_received_time,'yyyy-MM-dd hh24:mi:ss') as alarm_received_time,");
		hql.append("mw.result_summary as result_summary");
		
		hql.append(") from MonitorWarninginfoVo mw where mw.handle_status='1' ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
         }
         
         if(null != stoptime && stoptime.length() > 0){
         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
         }
		
		
		hql.append(" order by mw.first_time desc ");
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countUntreated(Map<String, Object> params,String starttime,String stoptime)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from  MonitorWarninginfoVo mw where mw.handle_status='1'  ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mw." + key + " like :" + key);
				} else {
					hql.append(" and mw." + key + " = :" + key);
				}
			}
		}
		 if(null != starttime && starttime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') >= '" + starttime + "'");
	         }
	         
	         if(null != stoptime && stoptime.length() > 0){
	         	hql.append(" and to_char(mw.first_time,'yyyymmdd') <= '" + stoptime + "')");
	         }
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 根据工具编号，应用系统 获取工具属性.
	 * @param tool_code
	 *        工具编号
	 * @param appsys_code
	 *        应用系统
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String event_id)throws SQLException {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("mw.event_id as event_id,");
		hql.append("mw.customerseverity as customerseverity,");
		hql.append("mw.device_id as device_id,");
		hql.append("mw.device_ip as device_ip,");
		hql.append("mw.alarmobject as alarmobject,");
		hql.append("mw.componenttype as componenttype,");
		hql.append("mw.component as component,");
		hql.append("mw.subcomponent as subcomponent,");
		hql.append("mw.summarycn as summarycn,");
		hql.append("mw.eventstatus as eventstatus,");
		
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.match_tools_message as match_tools_message,");
		hql.append("to_char(mw.alarm_received_time,'yyyy-MM-dd hh24:mi:ss') as alarm_received_time,");
		hql.append("mw.result_summary as result_summary");
		hql.append(") from MonitorWarninginfoVo mw where mw.event_id=:event_id ");

		return getSession().createQuery(hql.toString()).setString("event_id", event_id)
				.uniqueResult();

	}
	
	/**
	 * 修改诊断描述.
	
	 * @throws SQLException 
	 */
	public void updateAlarmDesc(String event_id ,String result_summary)throws SQLException {
		getSession().createQuery(
				"update  MonitorWarninginfoVo mw set mw.handle_status='2',mw.result_summary=?  where mw.event_id=?")
		.setString(0, result_summary).setString(1, event_id)
		.executeUpdate();
		
	}
	
	
	/**
	 * 保存告警诊断后业务数据
	
	 * @throws SQLException 
	 */
	public void saveBussinesData(List<Map<String, Object>> businesslist,String event_id)throws SQLException {
		
		BusinessFieldDataInfoVo vo = null;
	List<BusinessFieldDataInfoVo> businessList = new ArrayList<BusinessFieldDataInfoVo>();
	for (Map<String, Object> mapprarm : businesslist) {
		vo = new BusinessFieldDataInfoVo();
	
		vo.setBusiness_id(Integer.valueOf(mapprarm.get("id").toString()));
		vo.setAppsys_code(null != mapprarm.get("appsys_code")?ComUtil.checkJSONNull(mapprarm
				.get("appsys_code")):null);
		vo.setBusiness_impact_content(null != mapprarm.get("business_impact_content")?ComUtil.checkJSONNull(mapprarm
				.get("business_impact_content")):null);
		
		vo.setBusiness_impact_level(null != mapprarm.get("business_impact_level")?ComUtil.checkJSONNull(mapprarm
				.get("business_impact_level")):null);
	
		vo.setBusiness_impact_type(null != mapprarm.get("business_impact_type")?ComUtil.checkJSONNull(mapprarm
				.get("business_impact_type")):null);
		
		vo.setDiangostic_status(null != mapprarm.get("diangostic_status")?ComUtil.checkJSONNull(mapprarm
				.get("diangostic_status")):null);
		vo.setEvent_id(event_id);
		businessList.add(vo);
	}
	
	this.saveFileldData(businessList);
	}
	/**
	 * 保存告警诊断后业务数据
	
	 * @throws SQLException 
	 */
	public void saveFileldData(List<BusinessFieldDataInfoVo> businessList)throws SQLException {
for (BusinessFieldDataInfoVo vo : businessList) {
			
			getSession().saveOrUpdate(vo);
		}
	}
	
	
	
	/**
	 * 修改工具监控关键字.
	 * @param tool_code
	 * @param event_group
	 * @param summarycn
	 * @throws SQLException 
	 */
	@Transactional
	public void updatekeywords(String tool_code, String event_group,String summarycn)throws SQLException {
		 Date startDate = new Date();
		 Timestamp update_time = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate)) ;
		 String username = securityUtils.getUser().getUsername() ;
		getSession().createQuery(
						"update  ToolBoxInfoVo tb set tb.tool_modifier=?,tb.tool_updated_time=?  where tb.tool_code=?")
				.setString(0, username).setTimestamp(1, update_time).setString(2, tool_code)
				.executeUpdate();
		
		ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo=new ToolBoxEventGroupInfoVo();
		ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo=new ToolBoxKeyWordInfoVo();
		this.deleteEventGroup(tool_code);
		this.deleteKeyWord(tool_code);
		if(event_group.length()>0){
			
			toolBoxEventGroupInfoVo.setTool_code(tool_code);
			toolBoxEventGroupInfoVo.setEvent_group(event_group);
			getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		}
		
		
		if(summarycn.length()>0){
			
			toolBoxKeyWordInfoVo.setTool_code(tool_code);
			toolBoxKeyWordInfoVo.setSummarycn(summarycn);
			getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		}
	}
	
	
	/**
	 * 删除关键字


	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteKeyWord(String tool_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxKeyWordInfoVo tk where tk.tool_code = ?")
				.setString(0, tool_code).executeUpdate();
	}
	
	/**
	 * 删除策略


	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteEventGroup(String tool_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxEventGroupInfoVo tg where tg.tool_code = ?")
				.setString(0, tool_code).executeUpdate();
	}
	
	/**
	 * 修改忽略
	 * @param tool_code
	 * @param event_group
	 * @param summarycn
	 * @param alarminstance
	 * @throws SQLException 
	 */
	public void updataIgnored(String[] event_ids)throws SQLException {
		for (int i = 0; i < event_ids.length ; i++) {
			updataIgnoredHs(event_ids[i]);
		}
	}
	
	public void updataIgnoredHs(String event_id)throws SQLException {
		getSession().createQuery(
				"update  MonitorWarninginfoVo mw set mw.handle_status='3' where mw.event_id=?")
		.setString(0, event_id)
		.executeUpdate();
	}


	/**
	 * 查询监控信息列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmInfo(String event_id)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("mw.event_id as event_id,");
		hql.append("mw.customerseverity as customerseverity,");
		hql.append("mw.device_id as device_id,");
		hql.append("mw.device_ip as device_ip,");
		hql.append("mw.alarmobject as alarmobject,");
		hql.append("mw.componenttype as componenttype,");
		hql.append("mw.component as component,");
		hql.append("mw.subcomponent as subcomponent,");
		hql.append("mw.summarycn as summarycn,");
		hql.append("mw.eventstatus as eventstatus,");
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.match_tools_message as match_tools_message,");
		hql.append("to_char(mw.alarm_received_time,'yyyy-MM-dd hh24:mi:ss') as alarm_received_time,");
		hql.append("mw.result_summary as result_summary");
		
		
		hql.append(") from MonitorWarninginfoVo mw where mw.event_id=:event_id");

		
		Query query = getSession().createQuery(hql.toString()).setString("event_id", event_id);

		return query.list();
	}

	@SuppressWarnings("unchecked")
	public List<MonitorPolicyConfigVo> queryMonitorPolicyConfig() {
		// TODO Auto-generated method stub
		return getSession().createQuery(
				"from  MonitorPolicyConfigVo mw where mw.policyDataSource='0' ").list();
		
	}
	
	/**
	 * 获取大类
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getEventone()throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.component_type as \"componenttype\"");
		sql.append(" from  MONITOR_EVENT_TYPE_CONFIG f  ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	/**
	 * 获取小类
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getEventtwo(String componenttype)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.component_type as \"componenttype\",");
		sql.append(" f.component as \"component\" ");
		sql.append("  from  MONITOR_EVENT_TYPE_CONFIG f where  f.component_type= :componenttype ");
	
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("componenttype",componenttype);
		return query.list();
	}
	
	/**
	 * 获取细类
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getEventthree(String componenttype,String component)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.component as \"component\",");
		sql.append(" f.component_type as \"componenttype\",");
		sql.append(" f.sub_component as \"subcomponent\" ");
		sql.append("  from  MONITOR_EVENT_TYPE_CONFIG f where    f.component_type= :componenttype and  f.component= :component");
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("componenttype",componenttype)
				.setString("component",component);
		return query.list();
	}
	

	
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServerOsuser(String tool_code )throws SQLException  {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct tc.os_user as  \"os_user\"  from TOOL_BOX_SERVER_INFO tc where tc.tool_code =? ");
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
		
	}	
	
	
	/**
	 * 查询业务影响列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryalarmbusinessInfo(Integer start, Integer limit,
			String sort, String dir, 
			String event_id)throws SQLException, UnsupportedEncodingException {
		
		  List<Map<String, Object>> list=  this.queryToolboxAlarmInfo(event_id);
		 String  event_group = (null!= list.get(0).get("event_group")?ComUtil.checkNull(list.get(0).get("event_group")):"");
		String key1=(null!= list.get(0).get("summarycn")?ComUtil.checkNull(list.get(0).get("summarycn")):"");
		String key2=(null!= list.get(0).get("alarminstance")?ComUtil.checkNull(list.get(0).get("alarminstance")):"");
		// String  componenttype  =(null!= list.get(0).get("componenttype")?ComUtil.checkNull(list.get(0).get("componenttype")):"");
		
		String alarm_key_word =key1+key2;
		String appsysName = (null!=list.get(0).get("appname")?ComUtil.checkNull(list.get(0).get("appname")):""); 
		
		String or_and = this.or_and("0");
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("bi.id as \"id\",");
		sql.append("bi.appsys_code as \"appsys_code\",");
		sql.append("bi.business_impact_type as \"business_impact_type\",");
		sql.append("bi.business_impact_level as \"business_impact_level\",");
		sql.append("bi.business_impact_content as \"business_impact_content\",");
		
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.alarm_key_word as \"alarm_key_word\" ");
		
			sql.append(" from BUSINESS_IMPACT_INFO bi  " );
			sql.append(" left join BUSINESS_ALARM_RELATION tg on tg.business_id=bi.id");
			sql.append(" left join BUSINESS_KEY_WORD_RELATION tk on tk.business_id=bi.id");
			sql.append(",  v_cmn_app_info ca  ");
			sql.append("  where  bi.appsys_code = ca.appsys_code " );
			sql.append("  and ( ca.systemname = :appsysName or bi.appsys_code='COMMON' )");
		
		
		
		sql.append(" order by bi.business_impact_level  ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
        		query.setParameter("appsysName", appsysName);
		
		List<Map<String, Object>> business= query.list();
		List<Map<String, Object>> event_business= new ArrayList<Map<String,Object>>();
		
		if(or_and.equals("1")){
		List<Map<String, Object>> event_IDbusiness= new ArrayList<Map<String,Object>>();
		
		
		for(Map<String, Object> mapbusiness : business ){
			String business_event_group =ComUtil.checkNull(mapbusiness.get("event_group"));
			if(!business_event_group.equals("")&&event_group.equals("")){
				String [] business_event_group_params = business_event_group.split("\\|");
				int k=0;
				for(int i=0;i<business_event_group_params.length;i++){
					if(event_group.indexOf(business_event_group_params[i])!=-1){
						k++;
						break;
					}
				}
				if(k>0){
					event_IDbusiness.add(mapbusiness);
				}
			}
		};
		
		for(Map<String, Object> mapbusiness : event_IDbusiness ){
			
			String business_alarm_key_word =ComUtil.checkNull(mapbusiness.get("alarm_key_word"));
			int m=0;
			
			
			if(!(business_alarm_key_word.equals("")&&alarm_key_word.equals(""))){
				String [] business_alarm_key_word_params = business_alarm_key_word.split("\\|");
				int k=0;
				for(int i=0;i<business_alarm_key_word_params.length;i++){
					
					
					String [] alarm_key_word_params=business_alarm_key_word_params[i].split("&");
					boolean alarm_key_word_flag=true;
					for(int j=0 ;j<alarm_key_word_params.length;j++){
						
						if(alarm_key_word.indexOf(alarm_key_word_params[j])==-1){
							alarm_key_word_flag=false;
							break;
						}
						
					}
					
					if(alarm_key_word_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};
			
			
			
			if(m>0){
				event_business.add(mapbusiness);
			}
		}
		
		
		}else{
		
		
		for(Map<String, Object> mapbusiness : business ){
			String business_event_group =ComUtil.checkNull(mapbusiness.get("event_group"));
			String business_alarm_key_word =ComUtil.checkNull(mapbusiness.get("alarm_key_word"));
			int m=0;
			if(!business_event_group.equals("")&&!event_group.equals("")){
				String [] business_event_group_params = business_event_group.split("\\|");
				int k=0;
				
				for(int i=0;i<business_event_group_params.length;i++){
					
					boolean event_group_flag=false;
					
						if(event_group.indexOf(business_event_group_params[i])!=-1){
							event_group_flag = true;
							
					}
					
					if(event_group_flag){
						k++;
						break;
					}
				}
				if(k>0){
					m++;
				}
			};
			
			if(!business_alarm_key_word.equals("")&&!alarm_key_word.equals("")){
				String [] business_alarm_key_word_params = business_alarm_key_word.split("\\|");
				int k=0;
				for(int i=0;i<business_alarm_key_word_params.length;i++){
					
					
					String [] alarm_key_word_params=business_alarm_key_word_params[i].split("&");
					boolean alarm_key_word_flag=true;
					for(int j=0 ;j<alarm_key_word_params.length;j++){
						
						if(alarm_key_word.indexOf(alarm_key_word_params[j])==-1){
							alarm_key_word_flag=false;
							break;
						}
						
					}
					
					if(alarm_key_word_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};
			
			
			
			if(m>0){
				event_business.add(mapbusiness);
			}
		 }
		}
		
		//增加告警匹配信息
		
		/*StringBuilder sql2 = new StringBuilder();
		sql2.append("select  ");
		sql2.append("tb.tool_code as \"tool_code\",");
		sql2.append("tb.appsys_code as \"appsys_code\",");
		sql2.append("tb.tool_name as \"tool_name\",");
		sql2.append("ts.shell_name as \"shell_name\",");
		sql2.append("tb.tool_desc as \"tool_desc\",");
		sql2.append("ts.server_group as \"server_group\",");
		sql2.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql2.append("tb.field_type_one as \"field_type_one\",");
		sql2.append("tb.field_type_two as \"field_type_two\",");
		sql2.append("tb.field_type_three as \"field_type_three\",");
		sql2.append("tb.tool_type as \"tool_type\",");
		sql2.append("ts.os_type as \"os_type\",");
		sql2.append("ts.position_type as \"position_type\", ");
		sql2.append("ts.os_user_flag as \"os_user_flag\",");
		sql2.append("ts.group_server_flag as \"group_server_flag\",");
		sql2.append("ts.os_user as \"os_user\",");
		sql2.append("ts.tool_charset as \"tool_charset\",");
		sql2.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql2.append("tg.event_group as \"event_group\",");
		sql2.append("tk.summarycn as \"summarycn\",");
		sql2.append("tb.tool_creator as \"tool_creator\", ");
		sql2.append("ta.tool_status as \"tool_status\",");
		//sql2.append("td.tool_content as \"tool_content\",");
		sql2.append("ta.tool_returnreasons as \"tool_returnreasons\"");
	
			sql2.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
			sql2.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
			sql2.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
			sql2.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
			sql2.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
			//sql2.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
			sql2.append("  , v_cmn_app_info ca  ");
			sql2.append("  where tb.delete_flag='0'  and tb.appsys_code = ca.appsys_code " );
			sql2.append("  and ( ca.systemname = :appsysName or tb.appsys_code='COMMON' )");
	
		
		
		sql2.append(" order by tb.field_type_one,tb.field_type_two,tb.field_type_three ");
		Query query2 = getSession().createSQLQuery(sql2.toString())
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

        		query2.setParameter("appsysName", appsysName);

		List<Map<String, Object>> tools= query2.list();
		
		
		for(int a=0;a<event_business.size();a++){
			int count=0;
			String  b_event_group = (null!= event_business.get(a).get("event_group")?ComUtil.checkNull(event_business.get(a).get("event_group")):"");
			String b_key_word=(null!= event_business.get(a).get("alarm_key_word")?ComUtil.checkNull(event_business.get(a).get("alarm_key_word")):"");
			
			List<Map<String, Object>> event_tools= new ArrayList<Map<String,Object>>();
			for(Map<String, Object> maptool : tools ){
			String tool_event_group =ComUtil.checkNull(maptool.get("event_group"));
			String tool_summarycn =ComUtil.checkNull(maptool.get("summarycn"));
		//	String tool_alarminstance =ComUtil.checkNull(maptool.get("alarminstance"));
			int m=0;
			if(!tool_event_group.equals("")&&!b_event_group.equals("")){
				String [] tool_event_group_params = tool_event_group.split("\\|");
				int k=0;
				
				for(int i=0;i<tool_event_group_params.length;i++){
					
					boolean event_group_flag=false;
					
						if(b_event_group.indexOf(tool_event_group_params[i])!=-1){
							event_group_flag = true;
							
					}
					
					if(event_group_flag){
						k++;
						break;
					}
				}
				if(k>0){
					m++;
				}
			};
			
			if(!tool_summarycn.equals("")&&!b_key_word.equals("")){
				String [] tool_summarycn_params = tool_summarycn.split("\\|");
				int k=0;
				for(int i=0;i<tool_summarycn_params.length;i++){
					
					
					String [] summarycn_params=tool_summarycn_params[i].split("&");
					boolean summarycn_flag=true;
					for(int j=0 ;j<summarycn_params.length;j++){
						
						if(b_key_word.indexOf(summarycn_params[j])==-1){
							summarycn_flag=false;
							break;
						}
						
					}
					
					if(summarycn_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};
			
		
			
			if(m>0){
				event_tools.add(maptool);
			}
		 }
			count=event_tools.size();
			event_business.get(a).put("math_tool_num", count);
		}
		*/
	
		
		 return event_business;
		 
	}
	
	
	/**
	 * 获取或且名称
	 */
	@Transactional(readOnly = true)
	public String or_and(String value)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='OR_AND' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	
	
	/**
	 * 查询业务影响列表保留数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryalarmbusinessdata(Integer start, Integer limit,
			String sort, String dir, 
			String event_id)throws SQLException, UnsupportedEncodingException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("bd.event_id as \"event_id\",");
		sql.append("bd.business_id as \"business_id\",");
		sql.append("bd.appsys_code as \"appsys_code\",");
		sql.append("bd.business_impact_type as \"business_impact_type\",");
		sql.append("bd.business_impact_level as \"business_impact_level\",");
		sql.append("bd.business_impact_content as \"business_impact_content\",");
		sql.append("bd.DIAGNOSTIC_STATUS as \"diagnostic_status\" ");
		sql.append("  from  BUSINESS_FIELD_DATA_INFO bd " );
		sql.append("  where  bd.event_id =:event_id " );
		sql.append(" order by bd.business_impact_level  ");
		Query query = getSession().createSQLQuery(sql.toString()).setString("event_id",event_id)
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> business= query.list();
		return business;
	}
	
	/**
	 * 根据系统编号、业务影响分类、业务影响级别获取业务影响内容等信息
	 * @param appsys_code 系统编号 
	 * @param business_impact_type 业务影响分类
	 * @param business_impact_level 业务影响级别
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getImpactRecords(
			String appsys_code,String business_impact_type,String business_impact_level){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct");
		sql.append(" t.id as \"id\",");
		sql.append(" t.appsys_code as \"appsys_code\",");
		sql.append(" t.business_impact_type as \"business_impact_type\",");
		sql.append(" t.business_impact_level as \"business_impact_level\",");
		sql.append(" t.business_impact_content as \"business_impact_content\" ");
		sql.append(" from business_impact_info t " );
		sql.append(" where 1=1 " );
		if(appsys_code!=null && !appsys_code.equals("")){
			sql.append(" and t.appsys_code = '"+appsys_code+"'" );
		}
		if(business_impact_type!=null && !business_impact_type.equals("")){
			sql.append(" and t.business_impact_type ='"+business_impact_type+"'" );
		}
		if(business_impact_level!=null && !business_impact_level.equals("")){
			sql.append(" and t.business_impact_level = '"+business_impact_level+"'" );
		}
		sql.append(" order by t.appsys_code");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> business= query.list();
		return business;
	}
	
	
	/**
	 * 构建工具箱业务影响配置目录树
	 * @param systemList 当前用户的权限系统列表<appsysCode,appsysName>
	 * @param impact_type 影响分类
	 * @param impact_level 影响级别
	 * @return
	 */
	public List<JSONObject> buildImpactConfTree(List<Map<String, String>> systemList,String impact_type,String impact_level) {
		List<JSONObject> confJsonList = new ArrayList<JSONObject>();
		JSONObject sysObj =  null;
		JSONObject typeObj = null;
		JSONObject levelObj = null;
		JSONObject contentObj = null;
		List<JSONObject> sysjsonList = null;
		List<JSONObject> typejsonList = null;
		List<JSONObject> leveljsonList = null;
        //Map<String, Object>字段：name value cascade
		List<Map<String, Object>> impactTypes = itemService.getSubMap(imapctTypeDic) ; //业务影响分类
		List<Map<String, Object>> impactLevels = itemService.getSubMap(imapctLevelDic) ; //业务影响级别
        //遍历应用系统
		for (Map<String,String> map : systemList) {
			sysjsonList = new ArrayList<JSONObject>();
			sysObj = new JSONObject();
			sysObj.put("id", map.get("appsysCode"));
			sysObj.put("text", map.get("appsysName"));
			sysObj.put("iconCls", "node-module");
			sysObj.put("leaf", false);
			//sysObj.put("checked", false);
			if(impact_type!=null && !impact_type.equals("")){ //业务影响分类查询条件不为空
				typejsonList = new ArrayList<JSONObject>();
				typeObj = new JSONObject();
				typeObj.put("text", impact_type);
				typeObj.put("iconCls", "node-module");
				typeObj.put("leaf", false);
				typeObj.put("checked", false);
				if(impact_level!=null && !impact_level.equals("")){ //业务影响级别查询条件不为空
					leveljsonList = new ArrayList<JSONObject>();
					levelObj = new JSONObject();
					levelObj.put("text", impact_level);
					levelObj.put("iconCls", "node-module");
					levelObj.put("leaf", false);
					levelObj.put("checked", false);
					List<Map<String, Object>> contents = getImpactRecords(
							(map.get("appsysCode")).toString(),impact_type,impact_level);
					for(Map<String, Object> content : contents){
						contentObj = new JSONObject();
						if(levelColorMap.containsKey(impact_level)){
							contentObj.put("text", "<span style='color:"+levelColorMap.get(impact_level)+"'>"+content.get("business_impact_content")+"</span>");
						}else{
							contentObj.put("text", content.get("business_impact_content"));
						}
						contentObj.put("id", content.get("id").toString());
						contentObj.put("iconCls", "node-leaf");
						contentObj.put("leaf", true);
						contentObj.put("checked", false);
						leveljsonList.add(contentObj);
					}
					levelObj.put("children", JSONArray.fromObject(leveljsonList));
					typejsonList.add(levelObj);
				}else{  //业务影响级别查询条件为空
					for (Map<String,Object> level : impactLevels) {  //遍历所有影响级别
						leveljsonList = new ArrayList<JSONObject>();
						levelObj = new JSONObject();
						levelObj.put("text", level.get("name"));
						levelObj.put("iconCls", "node-module");
						levelObj.put("leaf", false);
						levelObj.put("checked", false);
						List<Map<String, Object>> contents = getImpactRecords(
								(map.get("appsysCode")).toString(),impact_type,(level.get("name")).toString());
						for(Map<String, Object> content : contents){
							contentObj = new JSONObject();
							if(levelColorMap.containsKey(level.get("name"))){
								contentObj.put("text", "<span style='color:"+levelColorMap.get(level.get("name"))+"'>"+content.get("business_impact_content")+"</span>");
							}else{
								contentObj.put("text", content.get("business_impact_content"));
							}
							contentObj.put("id", content.get("id").toString());
							contentObj.put("iconCls", "node-leaf");
							contentObj.put("leaf", true);
							contentObj.put("checked", false);
							leveljsonList.add(contentObj);
						}
						levelObj.put("children", JSONArray.fromObject(leveljsonList));
						typejsonList.add(levelObj);
					}
				}
				typeObj.put("children", JSONArray.fromObject(typejsonList));
				sysjsonList.add(typeObj);
			}else{  //业务影响分类查询条件为空
				for (Map<String,Object> type : impactTypes) { //遍历所有业务分类
					typejsonList = new ArrayList<JSONObject>();
					typeObj = new JSONObject();
					typeObj.put("text", type.get("name"));
					typeObj.put("iconCls", "node-module");
					typeObj.put("leaf", false);
					typeObj.put("checked", false);
					if(impact_level!=null && !impact_level.equals("")){ //业务影响级别查询条件不为空
						leveljsonList = new ArrayList<JSONObject>();
						levelObj = new JSONObject();
						levelObj.put("text", impact_level);
						levelObj.put("iconCls", "node-module");
						levelObj.put("leaf", false);
						levelObj.put("checked", false);
						List<Map<String, Object>> contents = getImpactRecords(
								(map.get("appsysCode")).toString(),(type.get("name")).toString(),impact_level);
						for(Map<String, Object> content : contents){
							contentObj = new JSONObject();
							if(levelColorMap.containsKey(impact_level)){
								contentObj.put("text", "<span style='color:"+levelColorMap.get(impact_level)+"'>"+content.get("business_impact_content")+"</span>");
							}else{
								contentObj.put("text", content.get("business_impact_content"));
							}
							contentObj.put("id", content.get("id").toString());
							contentObj.put("iconCls", "node-leaf");
							contentObj.put("leaf", true);
							contentObj.put("checked", false);
							leveljsonList.add(contentObj);
						}
						levelObj.put("children", JSONArray.fromObject(leveljsonList));
						typejsonList.add(levelObj);
					}else{  //业务影响级别查询条件为空
						for (Map<String,Object> level : impactLevels) {
							leveljsonList = new ArrayList<JSONObject>();
							levelObj = new JSONObject();
							levelObj.put("text", level.get("name"));
							levelObj.put("iconCls", "node-module");
							levelObj.put("leaf", false);
							levelObj.put("checked", false);
							List<Map<String, Object>> contents = getImpactRecords(
									(map.get("appsysCode")).toString(),(type.get("name")).toString(),(level.get("name")).toString());
							for(Map<String, Object> content : contents){
								contentObj = new JSONObject();
								if(levelColorMap.containsKey(level.get("name"))){
									contentObj.put("text", "<span style='color:"+levelColorMap.get(level.get("name"))+"'>"+content.get("business_impact_content")+"</span>");
								}else{
									contentObj.put("text", content.get("business_impact_content"));
								}
								contentObj.put("id", content.get("id").toString());
								contentObj.put("iconCls", "node-leaf");
								contentObj.put("leaf", true);
								contentObj.put("checked", false);
								leveljsonList.add(contentObj);
							}
							levelObj.put("children", JSONArray.fromObject(leveljsonList));
							typejsonList.add(levelObj);
						}
					}
					typeObj.put("children", JSONArray.fromObject(typejsonList));
					sysjsonList.add(typeObj);
				}
			}
			sysObj.put("children", JSONArray.fromObject(sysjsonList));
			confJsonList.add(sysObj);
		}
		return confJsonList;
	}
	
	/**
	 * 删除业务影响配置信息
	 * @param businessConfIds 业务影响配置编号数组
	 */
	public void multDeleteImpactConfInfo(String[] businessConfIds){
		if(businessConfIds!=null && businessConfIds.length>0){
			for(int t=0 ; t<businessConfIds.length ; t++){
				deleteImpactConfInfo(businessConfIds[t]);
			}
		}
	}
	
	/**
	 * 删除业务影响配置信息，以及关联关键字与告警策略信息
	 * @param businessConfId 业务影响配置编号
	 */
	public void deleteImpactConfInfo(String businessConfId){
		//删除关联关键字信息
		StringBuffer sqlKeyword = new StringBuffer();
		sqlKeyword.append("delete from business_key_word_relation t ");
		sqlKeyword.append(" where t.business_id ='" + businessConfId + "'");
		getSession().createSQLQuery(sqlKeyword.toString()).executeUpdate();
		//删除关联告警策略信息
		StringBuffer sqlAlarm = new StringBuffer();
		sqlAlarm.append("delete from business_alarm_relation t ");
		sqlAlarm.append(" where t.business_id ='" + businessConfId + "'");
		getSession().createSQLQuery(sqlAlarm.toString()).executeUpdate();
		//删除业务影响配置信息
		StringBuffer sql = new StringBuffer();
		sql.append("delete from business_impact_info t ");
		sql.append(" where t.id ='" + businessConfId + "'");
		getSession().createSQLQuery(sql.toString()).executeUpdate();
	}
	
	/**
	 * 批量保存业务影响配置数据
	 * @param appsysCode 系统编号 
	 * @param impactType 业务影响分类
	 * @param impactLevel 业务影响级别
	 * @param impactContents 业务影响内容数组
	 */
	@Transactional
	public void saveImpactConfs(String appsysCode,String impactType,String impactLevel,String[] impactContents) {
		for(int t=0 ; t<impactContents.length ; t++){
			if(impactContents[t]!=null && !impactContents[t].equals("")){
				BusinessImpactInfoVo businessImpactInfoVo = new BusinessImpactInfoVo();
				businessImpactInfoVo.setAppsys_code(appsysCode);
				businessImpactInfoVo.setBusiness_impact_type(impactType);
				businessImpactInfoVo.setBusiness_impact_level(impactLevel);
				businessImpactInfoVo.setBusiness_impact_content(impactContents[t]);
				saveImpactConfVo(businessImpactInfoVo);
			}
		}
	}
	
	/**
	 * 保存业务影响配置数据
	 * @param businessImpactInfoVo 业务影响配置实例
	 */
	@Transactional
	public void saveImpactConfVo(BusinessImpactInfoVo businessImpactInfoVo) {
		getSession().save(businessImpactInfoVo);
	}
	
	/**
	 * 删除业务告警策略信息
	 * @param businessConfId 业务影响配置编号
	 */
	public void deleteBusinessAlarms(String businessConfId){
		StringBuffer sql = new StringBuffer();
		sql.append("delete from business_alarm_relation t ");
		sql.append(" where t.business_id ='" + businessConfId + "'");
		getSession().createSQLQuery(sql.toString()).executeUpdate();
	}
	
	/**
	 * 批量保存业务影响告警策略数据
	 * @param businessConfId 业务影响配置编号
	 * @param appsysCode 系统编号 
	 * @param eventGroup 告警策略
	 */
	@Transactional
	public void saveBusinessAlarms(String businessConfId,String appsysCode,String eventGroup) {
		//删除业务配置编号关联的数据
		deleteBusinessAlarms(businessConfId);
		//新增关联数据
		if(eventGroup!=null && !eventGroup.equals("")){
			BusinessAlarmRelationVo businessAlarmRelationVo = new BusinessAlarmRelationVo();
			businessAlarmRelationVo.setAppsys_code(appsysCode);
			businessAlarmRelationVo.setBusiness_id(Integer.valueOf(businessConfId));
			businessAlarmRelationVo.setEvent_group(eventGroup);
			saveBusinessAlarmVo(businessAlarmRelationVo);
		}
	}
	
	/**
	 * 保存业务告警策略信息
	 * @param businessAlarmRelationVo 业务告警策略关联表
	 */
	@Transactional
	public void saveBusinessAlarmVo(BusinessAlarmRelationVo businessAlarmRelationVo) {
		getSession().save(businessAlarmRelationVo);
	}
	
	/**
	 * 删除业务告警关键字信息
	 * @param businessConfId 业务影响配置编号
	 */
	public void deleteBusinessKeywords(String businessConfId){
		StringBuffer sql = new StringBuffer();
		sql.append("delete from business_key_word_relation t ");
		sql.append(" where t.business_id ='" + businessConfId + "'");
		getSession().createSQLQuery(sql.toString()).executeUpdate();
	}
	
	/**
	 * 保存业务告警关键字数据
	 * @param businessConfId 业务影响配置编号
	 * @param appsysCode 系统编号 
	 * @param keyword 告警关键字
	 */
	@Transactional
	public void saveBusinessKeyword(String businessConfId,String appsysCode,String keyword) {
		deleteBusinessKeywords(businessConfId); //先删除，后新增
		if(keyword!=null && !keyword.equals("")){
			BusinessKeyWordRelationVo businessKeyWordRelationVo = new BusinessKeyWordRelationVo();
			businessKeyWordRelationVo.setAppsys_code(appsysCode);
			businessKeyWordRelationVo.setBusiness_id(Integer.valueOf(businessConfId));
			businessKeyWordRelationVo.setAlarm_key_word(keyword);
			saveBusinessKeywordVo(businessKeyWordRelationVo);
		}
	}
	
	/**
	 * 保存业务告警关键字信息
	 * @param BusinessKeyWordRelationVo 业务告警关键字关联表
	 */
	@Transactional
	public void saveBusinessKeywordVo(BusinessKeyWordRelationVo businessKeyWordRelationVo) {
		getSession().save(businessKeyWordRelationVo);
	}
	
	/**
	 * 根据系统编号、业务影响分类、业务影响级别、业务影像内容获取业务影响内容等信息
	 * @param appsys_code 系统编号 
	 * @param business_impact_type 业务影响分类
	 * @param business_impact_level 业务影响级别
	 * @param business_impact_content 业务影响内容
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getImpactRecordsByContent(
			String appsys_code,String business_impact_type,String business_impact_level,String business_impact_content){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct");
		sql.append(" t.id as \"id\",");
		sql.append(" t.appsys_code as \"appsys_code\",");
		sql.append(" t.business_impact_type as \"business_impact_type\",");
		sql.append(" t.business_impact_level as \"business_impact_level\",");
		sql.append(" t.business_impact_content as \"business_impact_content\" ");
		sql.append(" from business_impact_info t " );
		sql.append(" where 1=1 " );
		sql.append(" and t.appsys_code = '"+appsys_code+"'" );
		sql.append(" and t.business_impact_type ='"+business_impact_type+"'" );
		sql.append(" and t.business_impact_level = '"+business_impact_level+"'" );
		sql.append(" and t.business_impact_content = '"+business_impact_content+"'" );
		sql.append(" order by t.appsys_code");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> business= query.list();
		return business;
	}
	
	/**
	 * 根据工具箱告警业务影响配置ID获取告警策略编码
	 * @param businesesId 工具箱告警业务影响配置ID
	 */
	@Transactional
	public String getEventGroupsByBusinesesId(String businesesId) {
		String val = "";
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.event_group as \"event_group\" ")
		   .append(" from business_alarm_relation t " ) 
		   .append(" where t.business_id =:business_id ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setString("business_id", businesesId);
		if(query.list()!=null && query.list().size()>0){
			if(query.list().get(0)!=null){
				val = query.list().get(0).toString();
			}
		}
		return val;
	}
	
	/**
	 * 根据工具箱告警业务影响配置ID获取告警信息关键字
	 * @param businesesId 工具箱告警业务影响配置ID
	 */
	@Transactional
	public String getImpactKeyWordByBusinesesId(String businesesId) {
		String val = "";
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.alarm_key_word as \"alarm_key_word\" ")
		   .append(" from business_key_word_relation t " ) 
		   .append(" where t.business_id =:business_id ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setString("business_id", businesesId);
		if(query.list()!=null && query.list().size()>0){
			if(query.list().get(0)!=null){
				val = query.list().get(0).toString();
			}
		}
		return val;
	}
	
	/**
	 * 构建业务告警策略配置树
	 * @param dataList 一级目录菜单节点列表
	 * @param businessConfId 业务影响配置表主键
	 * @return
	 */
	public List<JSONObject> buildImpactEventConfTree(List<Map<String, Object>> dataList,String businessConfId) {
		String eventGroups=getEventGroupsByBusinesesId(businessConfId);
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		JSONObject  third =  null; 
		JSONObject  four =  null; 
		JSONObject  policy =  null;
		JSONObject  policy2 =  null;
		for (Map<String,Object> map : dataList) {
			String policy_type_one =  map.get("policy_type_one").toString() ;
			second = new JSONObject();
			second.put("text", policy_type_one);
			second.put("iconCls", "node-module");
			second.put("isType", true);
			second.put("leaf", false);
			Boolean mapFlag = false;
			List<Map<String, Object>> dataList2=toolBoxService.queryTwoTree(map.get("appsys_code").toString(),policy_type_one);
			List<JSONObject> sencondList = new ArrayList<JSONObject>();
			for (Map<String,Object> map2 : dataList2) {
				List<JSONObject> thirdList = new ArrayList<JSONObject>();
				String policy_type_two =  map2.get("policy_type_two").toString() ;
				third = new JSONObject();
				third.put("text", policy_type_two);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", false);
				Boolean map2Flag = false ;
				List<Map<String, Object>> dataList3=toolBoxService.queryThreeTree(map2.get("appsys_code").toString(),policy_type_one,policy_type_two);
				for (Map<String,Object> map3 : dataList3) {
					if(map3.get("policy_type_three")!=null && !map3.get("policy_type_three").equals("")&& !map3.get("policy_type_three").equals("NULL")){
						String policy_type_three =  map3.get("policy_type_three").toString() ;
						four = new JSONObject();
						four.put("text", policy_type_three);
						four.put("iconCls", "node-module");
						four.put("isType", true);
						four.put("leaf", false);
						List<Map<String, Object>> dataList4=toolBoxService.queryPolicyTree2(map3.get("appsys_code").toString(),policy_type_one,policy_type_two,policy_type_three);
						List<JSONObject> policyList = new ArrayList<JSONObject>();
						Boolean map3Flag = false ;
						for (Map<String,Object> endmap : dataList4) {
							String policy_old_name =  endmap.get("policy_old_name").toString() ;
							String policy_name =  endmap.get("policy_name").toString() ;
							String Ep=policy_old_name+"  ("+policy_name+")";
							policy = new JSONObject();
							policy.put("text", Ep);
							policy.put("iconCls", "node-leaf");
							policy.put("isType", true);
							policy.put("leaf", true);
							if(eventGroups.indexOf(policy_old_name)==-1){
								policy.put("checked", false); 
							}else{
								policy.put("checked", true); 
								map3Flag = true;
							}
							policyList.add(policy);
						}
						if(map3Flag){
							four.put("checked", true); 
							map2Flag = true;
						}else{
							four.put("checked", false); 
						}
						four.put("children", JSONArray.fromObject(policyList));
						thirdList.add(four);
					}else{
						List<Map<String, Object>> dataList5=toolBoxService.queryPolicyTree(map2.get("appsys_code").toString(),policy_type_one,policy_type_two);
						for (Map<String,Object> endmap2 : dataList5) {
							String policy_old_name =  endmap2.get("policy_old_name").toString() ;
							String policy_name =  endmap2.get("policy_name").toString() ;
							String Ep=policy_old_name+"  ("+policy_name+")";
							policy2 = new JSONObject();
							policy2.put("text", Ep);
							policy2.put("iconCls", "node-leaf");
							policy2.put("isType", true);
							policy2.put("leaf", true);
							if(eventGroups.indexOf(policy_old_name)==-1){
								policy2.put("checked", false); 
							}else{
								policy2.put("checked", true); 
								map2Flag = true;
							}
							thirdList.add(policy2);
						}
					}
				}
				if(map2Flag){
					third.put("checked", true); 
					mapFlag = true;
				}else{
					third.put("checked", false);
				}
				third.put("children", JSONArray.fromObject(thirdList));
				sencondList.add(third);
			}
			if(mapFlag){
				second.put("checked", true); 
			}else{
				second.put("checked", false); 
			}
			second.put("children", JSONArray.fromObject(sencondList));
			sysJsonList.add(second);
		}
		return sysJsonList;
	}
	
	/**
	 * 查询所有未删除的应用系统编号及名称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNamesForAlarm(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct v.appsys_code as \"appsysCode\", ")
		  	.append(" v.systemname as \"appsysName\" ")
			.append(" from v_cmn_app_info v  ")
			.append(" where v.delete_flag != '1' ")
			.append(" order by v.appsys_code ");
		return getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
	}
}

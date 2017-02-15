package com.nantian.toolbox.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.hibernate.SessionFactory;
import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.JEDAException;
import com.nantian.toolbox.service.ToolBoxAlarmService;
import com.nantian.toolbox.service.ToolBoxServerService;
import com.nantian.toolbox.service.ToolBoxService;
import com.nantian.toolbox.vo.MonitorEventTypeConfigVo;
import com.nantian.toolbox.vo.MonitorPolicyConfigVo;
import com.nantian.toolbox.vo.MonitorWarninginfoVo;

@Controller
@RequestMapping("/toolbox")
public class ToolBoxWebServiceController {
	/** 日志输出 */
	private static Logger logger = Logger.getLogger(ToolBoxWebServiceController.class);
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	
	}
	@Autowired
	private ToolBoxAlarmService toolBoxAlarmService;
	@Autowired
	private ToolBoxService toolBoxService;
	//请求内容类型
//	private static final String APPLICATION_JSON = "application/json";
//	private static final String APPLICATION_XML = "application/xml";
	
	/**
	 * 获取指定的监控告警信息
	 * @param id
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException
	 */
	@RequestMapping(value = "/monitor_messages/{id}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap getMonitorMessage(@PathVariable String id,
			ModelMap modelMap) throws JEDAException, SQLException {
//		MonitorWarninginfoVo mw = (MonitorWarninginfoVo) toolBoxAlarmService.get(id);
	    
		modelMap.addAttribute("success", Boolean.TRUE);
	    return modelMap;
	}
	
	/**
	 * 
	 * @param body
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/monitor_messages", method = RequestMethod.POST)
	public @ResponseBody
	void postMonitorMessages(@RequestBody String body,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		PrintWriter out = null;
		MonitorWarninginfoVo mwVo;
		List<MonitorWarninginfoVo> postMsgs = new ArrayList<MonitorWarninginfoVo>();
		List<Map<String, Object>> list =null ;
	     try {
	    	out = response.getWriter();
//	    	if(request.getHeader("Content-type").indexOf(APPLICATION_JSON) != -1){
	    	response.setContentType("application/json; charset=utf-8");
 			JSONArray array = JSONArray.fromObject(body.trim());
	    	//将json格式的数据转换成list对象
 			list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
			for(Map<String, Object> map : list){
				mwVo = new MonitorWarninginfoVo();
				mwVo.setEvent_id(ComUtil.checkJSONNull(map.get("eventId")));//事件ID（必填）
	        	mwVo.setCustomerseverity("".equals(ComUtil.checkJSONNull(map.get("customerSeverity")))?null:Integer.parseInt(ComUtil.checkJSONNull(map.get("customerSeverity"))));//级别
	        	mwVo.setDevice_id(ComUtil.checkJSONNull(map.get("deviceId")));//设备
	        	mwVo.setDevice_ip(ComUtil.checkJSONNull(map.get("deviceIp")));//IP
	        	mwVo.setAlarmobject(ComUtil.checkJSONNull(map.get("alarmObject")));//告警对象
	        	mwVo.setComponenttype(ComUtil.checkJSONNull(map.get("componentType")));//事件大类
	        	mwVo.setComponent(ComUtil.checkJSONNull(map.get("component")));//事件子类
	        	mwVo.setSubcomponent(ComUtil.checkJSONNull(map.get("subcomponent")));//事件细类
	        	mwVo.setSummarycn(ComUtil.checkJSONNull(map.get("summarycn")));//摘要
	        	mwVo.setEventstatus("".equals(ComUtil.checkJSONNull(map.get("eventStatus")))?null:Integer.parseInt(ComUtil.checkJSONNull(map.get("eventStatus"))));//事件状态
	        	mwVo.setFirst_time("".equals(ComUtil.checkJSONNull(map.get("firstTime")))?null:new Timestamp(Long.valueOf(map.get("firstTime").toString())));//首次发生时间
	        	mwVo.setLast_time("".equals(ComUtil.checkJSONNull(map.get("lastTime")))?null:new Timestamp(Long.valueOf(map.get("lastTime").toString())));//最后发生时间
	        	//时间格式"yyyy-MM-dd HH:mm:ss"
	        	//mwVo.setFirst_time("".equals(ComUtil.checkJSONNull(map.get("firstTime")))?null:Timestamp.valueOf(map.get("firstTime").toString()));//首次发生时间
	        	//mwVo.setLast_time("".equals(ComUtil.checkJSONNull(map.get("lastTime")))?null:Timestamp.valueOf(map.get("lastTime").toString()));//最后发生时间
	        	
	        	mwVo.setAlarminstance(ComUtil.checkJSONNull(map.get("alarmInstance")));//告警实例
	        	mwVo.setAppname(ComUtil.checkJSONNull(map.get("appName")));//系统名称
	        	mwVo.setManagebycenter("".equals(ComUtil.checkJSONNull(map.get("manageByCenter")))?null:Integer.parseInt(ComUtil.checkJSONNull(map.get("manageByCenter"))));//接管状态
	        	mwVo.setManagebyuser(ComUtil.checkJSONNull(map.get("manageByUser")));//接管人
	        	mwVo.setManagetimeexceed(ComUtil.checkJSONNull(map.get("manageTimeExceed")));//接管超时
	        	mwVo.setManagetime("".equals(ComUtil.checkJSONNull(map.get("manageTime")))?null:new Timestamp(Long.valueOf(map.get("manageTime").toString())));//接管时间
	        	
	        	//mwVo.setManagetime("".equals(ComUtil.checkJSONNull(map.get("manageTime")))?null:Timestamp.valueOf(map.get("manageTime").toString()));//接管时间
	        	
	        	mwVo.setMaintainstatus("".equals(ComUtil.checkJSONNull(map.get("maintainStatus")))?null:Integer.parseInt(ComUtil.checkJSONNull(map.get("maintainStatus"))));//维护期
	        	mwVo.setRepeat_number("".equals(ComUtil.checkJSONNull(map.get("repeatNumber")))?null:Integer.parseInt(ComUtil.checkJSONNull(map.get("repeatNumber"))));//重复次数
	        	mwVo.setMgtorg(ComUtil.checkJSONNull(map.get("mgtorg")));//管理机构
	        	mwVo.setOrgname(ComUtil.checkJSONNull(map.get("orgName")));//所属机构
	        	mwVo.setEvent_group(ComUtil.checkJSONNull(map.get("eventGroup")));//事件组
	        	mwVo.setMonitor_tool(ComUtil.checkJSONNull(map.get("monitorTool")));//监控工具
	        	mwVo.setIs_ticket(ComUtil.checkJSONNull(map.get("isTicket")));//是否生成工单
	        	mwVo.setN_ticketid(ComUtil.checkJSONNull(map.get("nTicketid")));//工单ID
	        	mwVo.setUmp_id(ComUtil.checkJSONNull(map.get("umpId")));//UMP现场数据关联ID
	        	mwVo.setCause_effect(ComUtil.checkJSONNull(map.get("causeEffect")));//因果分类
	        	mwVo.setParent_event_id(ComUtil.checkJSONNull(map.get("parentEventId")));//父类事件号
	        	mwVo.setHandle_status("1");
	        	postMsgs.add(mwVo);
			}
//		     }else if(request.getHeader("Content-type").indexOf(APPLICATION_XML) != -1){
//		    	//解析XML
//		    	 Document doc = JDOMParserUtil.xmlParse(body);
//		    	 List<Element> warningMessages =doc.getRootElement().getChildren();//获得所有子要素集合
//		    	 for(Element warningMessage : warningMessages){
//		        		mwVo = new MonitorWarninginfoVo();
//			        	mwVo.setEvent_id(warningMessage.getChildTextTrim("eventId"));//事件ID（必填）
//			        	if(null != warningMessage.getChildText("customerSeverity")) mwVo.setCustomerseverity(Integer.parseInt(warningMessage.getChildText("customerSeverity")));//级别
//			        	if(null != warningMessage.getChildText("deviceId")) mwVo.setDevice_id(warningMessage.getChildText("deviceId"));//设备
//			        	if(null != warningMessage.getChildText("deviceIp")) mwVo.setDevice_ip(warningMessage.getChildText("deviceIp"));//IP
//			        	if(null != warningMessage.getChildText("alarmObject")) mwVo.setAlarmobject(warningMessage.getChildText("alarmObject"));//告警对象
//			        	if(null != warningMessage.getChildText("componentType")) mwVo.setComponenttype(warningMessage.getChildText("componentType"));//事件大类
//			        	if(null != warningMessage.getChildText("component")) mwVo.setComponent(warningMessage.getChildText("component"));//事件子类
//			        	if(null != warningMessage.getChildText("subcomponent")) mwVo.setSubcomponent(warningMessage.getChildText("subcomponent"));//事件细类
//			        	if(null != warningMessage.getChildText("summarycn")) mwVo.setSummarycn(warningMessage.getChildText("summarycn"));//摘要
//			        	if(null != warningMessage.getChildText("eventStatus")) mwVo.setEventstatus(Integer.parseInt(warningMessage.getChildText("eventStatus")));//事件状态
//			        	if(null != warningMessage.getChildText("firstTime")) mwVo.setFirst_time(Timestamp.valueOf(warningMessage.getChildText("firstTime")));//首次发生时间
//			        	if(null != warningMessage.getChildText("lastTime")) mwVo.setLast_time(Timestamp.valueOf(warningMessage.getChildText("lastTime")));//最后发生时间
//			        	if(null != warningMessage.getChildText("alarmInstance")) mwVo.setAlarminstance(warningMessage.getChildText("alarmInstance"));//告警实例
//			        	if(null != warningMessage.getChildText("appName")) mwVo.setAppname(warningMessage.getChildText("appName"));//系统名称
//			        	if(null != warningMessage.getChildText("manageByCenter")) mwVo.setManagebycenter(Integer.parseInt(warningMessage.getChildText("manageByCenter")));//接管状态
//			        	if(null != warningMessage.getChildText("manageByUser")) mwVo.setManagebyuser(warningMessage.getChildText("manageByUser"));//接管人
//			        	if(null != warningMessage.getChildText("manageTimeExceed")) mwVo.setManagetimeexceed(warningMessage.getChildText("manageTimeExceed"));//接管超时
//			        	if(null != warningMessage.getChildText("manageTime")) mwVo.setManagetime(Timestamp.valueOf(warningMessage.getChildText("manageTime")));//接管时间
//			        	if(null != warningMessage.getChildText("maintainStatus")) mwVo.setMaintainstatus(Integer.parseInt(warningMessage.getChildText("maintainStatus")));//维护期	
//			        	if(null != warningMessage.getChildText("repeatNumber")) mwVo.setRepeat_number(Integer.parseInt(warningMessage.getChildText("repeatNumber")));//重复次数
//			        	if(null != warningMessage.getChildText("mgtorg")) mwVo.setMgtorg(warningMessage.getChildText("mgtorg"));//管理机构
//			        	if(null != warningMessage.getChildText("orgName")) mwVo.setOrgname(warningMessage.getChildText("orgName"));//所属机构
//			        	if(null != warningMessage.getChildText("eventGroup")) mwVo.setEvent_group(warningMessage.getChildText("eventGroup"));//事件组
//			        	if(null != warningMessage.getChildText("monitorTool")) mwVo.setMonitor_tool(warningMessage.getChildText("monitorTool"));//监控工具
//			        	if(null != warningMessage.getChildText("isTicket")) mwVo.setIs_ticket(warningMessage.getChildText("isTicket"));//是否生成工单
//			        	if(null != warningMessage.getChildText("nTicketid")) mwVo.setN_ticketid(warningMessage.getChildText("nTicketid"));//工单ID	
//			        	if(null != warningMessage.getChildText("umpId")) mwVo.setUmp_id(warningMessage.getChildText("umpId"));//UMP现场数据关联ID
//			        	if(null != warningMessage.getChildText("causeEffect")) mwVo.setCause_effect(warningMessage.getChildText("causeEffect"));//因果分类
//			        	if(null != warningMessage.getChildText("parentEventId")) mwVo.setParent_event_id(warningMessage.getChildText("parentEventId"));//父类事件号
//			        	mwVo.setHandle_status("1");
//			        	postMsgs.add(mwVo);
//		        }
//		     }
	 		if(postMsgs.size() != 0) toolBoxAlarmService.save(postMsgs);
		    modelMap.put("success", Boolean.TRUE);
		    modelMap.put("errMsg", "");
		    out.print(JSONArray.fromObject(modelMap));
	     }	catch (Exception e) {
	    	 modelMap.put("success", Boolean.FALSE);
	    	 modelMap.put("errMsg", e.getMessage());
	    	 out = response.getWriter();
	    	 out.print(JSONArray.fromObject(modelMap));
	    	 logger.log("Toolbox0004", e.getMessage());
		}
	     
	     try {
	    	 if(null!=list){
		    	 this.MatchToolMessages(list);
		      }
		  } catch (Exception e) {
			  logger.log("Toolbox0004", e.getMessage());
		 }
	    
	}
	
	/**
	 * 报警匹配工具信息初始化数据
	 * @throws UnsupportedEncodingException 
	 */
	
	public void  MatchToolMessages(List<Map<String, Object>> list)throws SQLException, UnsupportedEncodingException {
		for(Map<String, Object> map : list){
			String num=getToolsNum(map);
			String event_id=ComUtil.checkJSONNull(map.get("eventId"));
			
			getSession().createQuery(
					"update  MonitorWarninginfoVo m set m.match_tools_message=? where m.event_id = ? ")
			.setString(0, num).setString(1, event_id)
			.executeUpdate();
		}
		
	}
	
	
	/**
	 * 查询工具列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	
	public String  getToolsNum(Map<String, Object> map) throws SQLException, UnsupportedEncodingException {
		
		
		 String  event_group =ComUtil.checkJSONNull(map.get("eventGroup"));
			String key1=ComUtil.checkJSONNull(map.get("summarycn"));
			String key2=ComUtil.checkJSONNull(map.get("alarmInstance"));
			 String  componenttype  =ComUtil.checkJSONNull(map.get("componentType"));
			
			String summarycn =key1+key2;
			String appsysName = ComUtil.checkJSONNull(map.get("appName"));  
			String or_and = toolBoxService.or_and("0");
			String matchType = toolBoxService.matchType("0");
			StringBuilder sql = new StringBuilder();
			sql.append("select  ");
			sql.append("tb.tool_code as \"tool_code\",");
			sql.append("tb.appsys_code as \"appsys_code\",");
			sql.append("tb.tool_name as \"tool_name\",");
			sql.append("ts.shell_name as \"shell_name\",");
			sql.append("tb.tool_desc as \"tool_desc\",");
			sql.append("ts.server_group as \"server_group\",");
			sql.append("tb.authorize_level_type as \"authorize_level_type\",");
			sql.append("tb.field_type_one as \"field_type_one\",");
			sql.append("tb.field_type_two as \"field_type_two\",");
			sql.append("tb.field_type_three as \"field_type_three\",");
			sql.append("tb.tool_type as \"tool_type\",");
			sql.append("ts.os_type as \"os_type\",");
			sql.append("ts.position_type as \"position_type\", ");
			sql.append("ts.os_user_flag as \"os_user_flag\",");
			sql.append("ts.group_server_flag as \"group_server_flag\",");
			sql.append("ts.os_user as \"os_user\",");
			sql.append("ts.tool_charset as \"tool_charset\",");
			sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
			sql.append("tg.event_group as \"event_group\",");
			sql.append("tk.summarycn as \"summarycn\",");
			sql.append("tb.tool_creator as \"tool_creator\", ");
			sql.append("ta.tool_status as \"tool_status\",");
			//sql.append("td.tool_content as \"tool_content\",");
			sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
			
			if(matchType.equals("0")){
				sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
				sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
				sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
				sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
				sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
				//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
				sql.append("  , v_cmn_app_info ca  ");
				sql.append("  where tb.delete_flag='0'  and tb.appsys_code = ca.appsys_code " );
				sql.append("  and ( ca.systemname = :appsysName or tb.appsys_code='COMMON' )");
			}else if(matchType.equals("1")){
				if(componenttype.equals("应用")){
					
					sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
					sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
					sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
					sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
					sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
					//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
					sql.append("  , v_cmn_app_info ca  ");
					sql.append("  where tb.delete_flag='0'  and tb.appsys_code = ca.appsys_code " );
					sql.append("  and ca.systemname = :appsysName");
					
					}else{
						sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
						sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
						sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
						sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
						sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
						//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
						sql.append("  where tb.delete_flag='0'   " );
						sql.append("  and tb.appsys_code ='COMMON' ");
						
					}
			}
			
			
			sql.append(" order by tb.field_type_one,tb.field_type_two,tb.field_type_three ");
			
			
	
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		if(matchType.equals("0")){
        	
    		query.setParameter("appsysName", appsysName);
    		
	  }else if(matchType.equals("1")){
		  if(componenttype.equals("应用")){
				query.setParameter("appsysName", appsysName);
				}
	}
	
		
		List<Map<String, Object>> tools= query.list();
		List<Map<String, Object>> event_tools= new ArrayList<Map<String,Object>>();
		
		if(or_and.equals("1")){
		List<Map<String, Object>> event_IDtools= new ArrayList<Map<String,Object>>();
		
		
		for(Map<String, Object> maptool : tools ){
			String tool_event_group =ComUtil.checkNull(maptool.get("event_group"));
			if(!tool_event_group.equals("")&&event_group.equals("")){
				String [] tool_event_group_params = tool_event_group.split("\\|");
				int k=0;
				for(int i=0;i<tool_event_group_params.length;i++){
					if(event_group.indexOf(tool_event_group_params[i])!=-1){
						k++;
						break;
					}
				}
				if(k>0){
					event_IDtools.add(maptool);
				}
			}
		};
		
		for(Map<String, Object> maptool : event_IDtools ){
			
			String tool_summarycn =ComUtil.checkNull(maptool.get("summarycn"));
			int m=0;
			
			
			if(!(tool_summarycn.equals("")&&summarycn.equals(""))){
				String [] tool_summarycn_params = tool_summarycn.split("\\|");
				int k=0;
				for(int i=0;i<tool_summarycn_params.length;i++){
					
					
					String [] summarycn_params=tool_summarycn_params[i].split("&");
					boolean summarycn_flag=true;
					for(int j=0 ;j<summarycn_params.length;j++){
						
						if(summarycn.indexOf(summarycn_params[j])==-1){
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
		
		
		}else{
		
		
		for(Map<String, Object> maptool : tools ){
			String tool_event_group =ComUtil.checkNull(maptool.get("event_group"));
			String tool_summarycn =ComUtil.checkNull(maptool.get("summarycn"));
			int m=0;
			if(!tool_event_group.equals("")&&!event_group.equals("")){
				String [] tool_event_group_params = tool_event_group.split("\\|");
				int k=0;
				
				for(int i=0;i<tool_event_group_params.length;i++){
					
					boolean event_group_flag=false;
					
						if(event_group.indexOf(tool_event_group_params[i])!=-1){
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
			
			if(!tool_summarycn.equals("")&&!summarycn.equals("")){
				String [] tool_summarycn_params = tool_summarycn.split("\\|");
				int k=0;
				for(int i=0;i<tool_summarycn_params.length;i++){
					
					
					String [] summarycn_params=tool_summarycn_params[i].split("&");
					boolean summarycn_flag=true;
					for(int j=0 ;j<summarycn_params.length;j++){
						
						if(summarycn.indexOf(summarycn_params[j])==-1){
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
		}
		String num= String.valueOf(event_tools.size());
		 
		 return num;
		 
	}
	
	

	/**
	 * 同步事件分类数据.
	 * @param body
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/event_types", method = RequestMethod.POST)
	public @ResponseBody
	void postComponentTypes(@RequestBody String body,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		PrintWriter out = null;
		MonitorEventTypeConfigVo eventTypeVo;
		List<MonitorEventTypeConfigVo> postMsgs = new ArrayList<MonitorEventTypeConfigVo>();
		try {
	    	out = response.getWriter();
//	 		if(request.getHeader("Content-type").indexOf(APPLICATION_JSON) != -1){
	    	response.setContentType("application/json; charset=utf-8");
 			JSONArray array = JSONArray.fromObject(body.trim());
	    	//将json格式的数据转换成list对象
 			List<Map<String, Object>> list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
			for(Map<String, Object> map : list){
				eventTypeVo = new MonitorEventTypeConfigVo();
				eventTypeVo.setComponentType(ComUtil.checkJSONNull(map.get("componentType")));//事件大类
				eventTypeVo.setComponent(ComUtil.checkJSONNull(map.get("component")));//事件小类
				eventTypeVo.setSubComponent(ComUtil.checkJSONNull(map.get("subComponent")));//事件细类
	        	postMsgs.add(eventTypeVo);
			}
//		     }else if(request.getHeader("Content-type").indexOf(APPLICATION_JSON) != -1){
//		    	 response.setContentType("application/xml; charset=utf-8");
//		    	//解析XML
//		    	 Document doc = JDOMParserUtil.xmlParse(body);
//		    	 List<Element> eventTypes =doc.getRootElement().getChildren();//获得所有子要素集合
//		    	 for(Element eventType : eventTypes){
//			        	eventTypeVo = new MonitorEventTypeConfigVo();
//			        	eventTypeVo.setName(eventType.getChildText("componentType"));//事件大类
//			        	eventTypeVo.setDescription(eventType.getChildText("component"));//事件小类
//			        	eventTypeVo.setParentId(eventType.getChildText("subComponent"));//事件细类
//			        	postMsgs.add(eventTypeVo);
//			        }
//		     }
	 		if(postMsgs.size() != 0) toolBoxAlarmService.saveEventTypes(postMsgs);
	 		
		    modelMap.put("success", Boolean.TRUE);
		    modelMap.put("errMsg", "");
		    out.print(JSONArray.fromObject(modelMap));
	     }	catch (Exception e) {
	    	 modelMap.put("success", Boolean.FALSE);
	    	 modelMap.put("errMsg", e.getMessage());
	    	 out = response.getWriter();
	    	 out.print(JSONArray.fromObject(modelMap));
	    	 logger.log("Toolbox0004", e.getMessage());
		}
	}
	
	/**
	 * 同步事件组（策略名称）数据.
	 * @param body
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/event_groups", method = RequestMethod.POST)
	public @ResponseBody
	void postEventGroups(@RequestBody String body,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		PrintWriter out = null;
		MonitorPolicyConfigVo ploicyConfigVo1;
		MonitorPolicyConfigVo ploicyConfigVo2;
		List <MonitorPolicyConfigVo> postMsgsData=toolBoxAlarmService.queryMonitorPolicyConfig();
		List<MonitorPolicyConfigVo> postMsgsData1 = new ArrayList<MonitorPolicyConfigVo>();
		List<MonitorPolicyConfigVo> postMsgsData2 = new ArrayList<MonitorPolicyConfigVo>();
		List<MonitorPolicyConfigVo> postMsgsData3 = new ArrayList<MonitorPolicyConfigVo>();
		List<MonitorPolicyConfigVo> postMsgsDataEnd = new ArrayList<MonitorPolicyConfigVo>();
		
		
		try {
	    	out = response.getWriter();
//	 		if(request.getHeader("Content-type").indexOf(APPLICATION_JSON) != -1){
	    	response.setContentType("application/json;charset=utf-8");
 			JSONArray array = JSONArray.fromObject(body.trim());
	    	//将json格式的数据转换成list对象
 			List<Map<String, Object>> list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
 			Set<String> setVo =new HashSet<String>();
			for(Map<String, Object> map : list){
				if(Integer.parseInt(ComUtil.checkJSONNull(map.get("policyDataSource")))!=1){
				ploicyConfigVo1 = new MonitorPolicyConfigVo();
				ploicyConfigVo1.setAppSysCode(ComUtil.checkJSONNull(map.get("appSysCode")));//应用系统编号
				ploicyConfigVo1.setAppSysName(ComUtil.checkJSONNull(map.get("appSysName")));//应用系统名称
				ploicyConfigVo1.setPolicyTypeOne(ComUtil.checkJSONNull(map.get("policyTypeOne")));//策略一级分类
				ploicyConfigVo1.setPolicyTypeTwo(ComUtil.checkJSONNull(map.get("policyTypeTwo")));//策略二级分类
				ploicyConfigVo1.setPolicyTypeThree(ComUtil.checkJSONNull(map.get("policyTypeThree")));//策略三级分类
				ploicyConfigVo1.setPolicyOldName(ComUtil.checkJSONNull(map.get("policyOldName")));//原策略名
				ploicyConfigVo1.setPolicyName(ComUtil.checkJSONNull(map.get("policyName")));//策略名称
				ploicyConfigVo1.setPolicyCode(ComUtil.checkJSONNull(map.get("policyCode")));//策略编号
				ploicyConfigVo1.setPolicyDataSource(Integer.parseInt(ComUtil.checkJSONNull(map.get("policyDataSource"))));//数据来源
				
				Boolean flag =setVo.add(ComUtil.checkJSONNull(map.get("appSysCode"))+ComUtil.checkJSONNull(map.get("policyCode")));
				if(flag){
					postMsgsData1.add(ploicyConfigVo1);
				}
				
				}else{
					ploicyConfigVo2 = new MonitorPolicyConfigVo();
					ploicyConfigVo2.setAppSysCode(ComUtil.checkJSONNull(map.get("appSysCode")));//应用系统编号
					ploicyConfigVo2.setAppSysName(ComUtil.checkJSONNull(map.get("appSysName")));//应用系统名称
					ploicyConfigVo2.setPolicyTypeOne(ComUtil.checkJSONNull(map.get("policyTypeOne")));//策略一级分类

					ploicyConfigVo2.setPolicyTypeTwo(ComUtil.checkJSONNull(map.get("policyTypeTwo")));//策略二级分类
					ploicyConfigVo2.setPolicyTypeThree(ComUtil.checkJSONNull(map.get("policyTypeThree")));//策略三级分类
					ploicyConfigVo2.setPolicyOldName(ComUtil.checkJSONNull(map.get("policyOldName")));//原策略名
					ploicyConfigVo2.setPolicyName(ComUtil.checkJSONNull(map.get("policyName")));//策略名称
					ploicyConfigVo2.setPolicyCode(ComUtil.checkJSONNull(map.get("policyCode")));//策略编号
					ploicyConfigVo2.setPolicyDataSource(Integer.parseInt(ComUtil.checkJSONNull(map.get("policyDataSource"))));//数据来源
					postMsgsData2.add(ploicyConfigVo2);
				}
			}
//		     }else if(request.getHeader("Content-type").indexOf(APPLICATION_XML) != -1){
//		    	//解析XML
//		    	 Document doc = JDOMParserUtil.xmlParse(body);
//		    	 List<Element> eventTypes =doc.getRootElement().getChildren();//获得所有子要素集合
//		    	 for(Element eventType : eventTypes){
//			        	ploicyConfigVo = new MonitorPolicyConfigVo();
//			        	ploicyConfigVo.setId(eventType.getChildTextTrim("id"));//主键id
//			        	if(null != eventType.getChildText("appSysCode")) ploicyConfigVo.setAppSysCode(eventType.getChildText("appSysCode"));//应用系统编号
//			        	if(null != eventType.getChildText("appSysName")) ploicyConfigVo.setAppSysName(eventType.getChildText("appSysName"));//应用系统名称
//			        	if(null != eventType.getChildText("policyTypeOne")) ploicyConfigVo.setPolicyTypeOne(eventType.getChildText("policyTypeOne"));//策略一级分类
//			        	if(null != eventType.getChildText("policyTypeTwo")) ploicyConfigVo.setPolicyTypeTwo(eventType.getChildText("policyTypeTwo"));//策略一级分类
//			        	if(null != eventType.getChildText("policyTypeThree")) ploicyConfigVo.setPolicyTypeThree(eventType.getChildText("policyTypeThree"));//策略三级分类
//			        	if(null != eventType.getChildText("policyName")) ploicyConfigVo.setPolicyName(eventType.getChildText("policyName"));//策略名称
//			        	if(null != eventType.getChildText("policyCode")) ploicyConfigVo.setPolicyCode(eventType.getChildText("policyCode"));//策略编号
//			        	if(null != eventType.getChildText("policyOldName")) ploicyConfigVo.setPolicyOldName(eventType.getChildText("policyOldName"));//原策略名
//			        	postMsgs.add(ploicyConfigVo);
//			        }
//		     }
			
			
			if( postMsgsData.size()!=0&&postMsgsData2.size()!=0){
				
				for(int i=0;i<postMsgsData.size();i++){
					
						for(int j=0;j<postMsgsData2.size();j++){
							if(!(postMsgsData.get(i).getAppSysCode().equals(postMsgsData2.get(j).getAppSysCode()) &&
							   postMsgsData.get(i).getPolicyOldName().equals(postMsgsData2.get(j).getPolicyOldName()))){
								postMsgsData3.add(postMsgsData2.get(j));
							}
						}
					}
				}else{
					postMsgsData3=postMsgsData2;
				}
			
				if(postMsgsData1.size() !=0&&postMsgsData3.size()!=0){
				for(int k=0;k<postMsgsData1.size();k++){
					
						for(int m=0;m<postMsgsData3.size();m++){
							if(!(postMsgsData1.get(k).getAppSysCode().equals(postMsgsData3.get(m).getAppSysCode()) &&
							   postMsgsData1.get(k).getPolicyOldName().equals(postMsgsData3.get(m).getPolicyOldName()))){
								String pOne=postMsgsData3.get(m).getPolicyOldName();
								postMsgsData3.get(m).setPolicyName(pOne);
								postMsgsData3.get(m).setPolicyCode(pOne);
								postMsgsDataEnd.add(postMsgsData3.get(m));
						}
					}
				}
				}else{
					postMsgsDataEnd=postMsgsData3;
				}
				
				if(postMsgsData1.size()!=0){
				for(int a=0;a<postMsgsData1.size();a++){
					postMsgsDataEnd.add(postMsgsData1.get(a));
				 }
				}
			
			
			
			
			if(postMsgsDataEnd.size() != 0) toolBoxAlarmService.savePolicyConfig(postMsgsDataEnd,postMsgsData);
	 		
		    modelMap.put("success", Boolean.TRUE);
		    modelMap.put("errMsg", "");
		    out.print(JSONArray.fromObject(modelMap));
	     }	catch (Exception e) {
	    	 modelMap.put("success", Boolean.FALSE);
	    	 modelMap.put("errMsg", e.getMessage());
	    	 out = response.getWriter();
	    	 out.print(JSONArray.fromObject(modelMap));
	    	 logger.log("Toolbox0004", e.getMessage());
		}
	}
	
	
}///:~

package com.nantian.toolbox.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.jboss.seam.annotations.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.toolbox.service.ToolBoxAlarmService;
import com.nantian.toolbox.service.ToolBoxService;

@Controller
@RequestMapping("/" + Constants.APP_PATH + "/ToolBoxAlarmController")
public class ToolBoxAlarmController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ToolBoxAlarmController.class);

	/** 监控领域对象名称 */
	private static final String domain = "toolbox";
	/** 视图前缀 */
	private static final String viewPrefix = domain + "/" + domain+"_";
	@Autowired
	private ToolBoxAlarmService toolBoxAlarmService;
	@Autowired
	private ToolBoxService toolBoxService;
	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	private SecurityUtils securityUtils;
	@Autowired
	private CmnLogService cmnLogService;
	
	/**
	 * 注册Editor
	 * 
	 * @param binder
	 */
	@InitBinder
	public void initBinder(WebDataBinder binder) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(
				dateFormat, true));
	}

	/**
	 * 返回报警信息未处理界面.
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarmuntreated", method = RequestMethod.GET)
	public String alarmuntreated() throws JEDAException {
		
		return  viewPrefix+ "alarmuntreated";
	}
	
	/**
	 * 返回报警信息已忽略界面.
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarmignored", method = RequestMethod.GET)
	public String alarmignored() throws JEDAException {
		
		return  viewPrefix+ "alarmignored";
	}
	
	/**
	 * 返回报警信息已处理界面.
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarmtreated", method = RequestMethod.GET)
	public String alarmtreated() throws JEDAException {
		
		return  viewPrefix+ "alarmtreated";
	}
	
	/**
	 * 返回诊断工具.
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarmtools", method = RequestMethod.GET)
	public String alarmtools(
			@RequestParam("event_id") String event_id,
			@RequestParam("device_ip") String device_ip
			) throws JEDAException {
		
		return  viewPrefix+ "alarmtools";
	}
	/**
	 * 返回执行界面 
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/AlarmExc", method = RequestMethod.GET)
	public String AlarmExc(@RequestParam("tool_code") String tool_code,
			@RequestParam("appsys_code") String appsys_code, 
			@RequestParam("usercode") String usercode,
			@RequestParam("os_type") String os_type,
			@RequestParam("event_id") String event_id
			) throws JEDAException {

		return viewPrefix + "alarmexc";
	}
	
	/**
	 * 返回执行界面 
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/AlarmExcDesc", method = RequestMethod.GET)
	public String AlarmExcDesc(@RequestParam("tool_code") String tool_code,
			@RequestParam("appsys_code") String appsys_code, 
			@RequestParam("usercode") String usercode,
			@RequestParam("os_type") String os_type,
			@RequestParam("event_id") String event_id,
			@RequestParam("device_ip") String device_ip
			) throws JEDAException {

		//插入执行日志表
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(appsys_code);
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(tool_code+"_exc");
		cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setAuthorizedUser(usercode);
		cmnLog.setEvent_id(event_id);
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		cmnLogService.save(cmnLog);
		return viewPrefix + "alarmexcdesc";
	}
	
	 /**
		 * 返回诊断结果修改界面.
		 * 
		 * @param request
		 * @return
		 * @throws JEDAException
		 */
		@RequestMapping(value = "/alarmeditview", method = RequestMethod.GET)
		public String alarmeditview() throws JEDAException {
			
			return  viewPrefix+ "alarmeditview";
		}
		/**
		 * 返回诊断结果修改界面.
		 * 
		 * @param request
		 * @return
		 * @throws JEDAException
		 */
		@RequestMapping(value = "/alarmDescView", method = RequestMethod.GET)
		public String alarmDescView() throws JEDAException {
			
			return  viewPrefix+ "alarmdescview";
		}
		
		 /**
			 * 返回诊断工具日志.
			 * 
			 * @param request
			 * @return
			 * @throws JEDAException
			 */
			@RequestMapping(value = "/eventlog", method = RequestMethod.GET)
			public String eventlog(
					@RequestParam("event_id") String event_id
					) throws JEDAException {
				
				return  viewPrefix+ "eventlogindex";
			}
	/**
	 * 加载监控未处理数据	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start	起始记录行	 * @param limit		查询记录数	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/untreatedindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryuntreatedToolboxAlarmInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("AlarmUntreatedStartTime") String AlarmUntreatedStartTime,
			@RequestParam("AlarmUntreatedCompletedTime") String AlarmUntreatedCompletedTime,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxAlarmService.fields);
		try {
			modelMap.addAttribute("data",
					toolBoxAlarmService.queryToolboxAlarmUntreatedInfo(start, limit, sort, dir, params,AlarmUntreatedStartTime,AlarmUntreatedCompletedTime));
			modelMap.addAttribute("count", toolBoxAlarmService.countUntreated(params,AlarmUntreatedStartTime,AlarmUntreatedCompletedTime));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	/**
	 * 加载监控已处理数据	 * 根据分页、排序和其他条件查询记录.
	 * @param start	起始记录行	 * @param limit		查询记录数	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/treatedindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap querytreatedToolboxAlarmInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("AlarmTreatedStartTime") String AlarmTreatedStartTime,
			@RequestParam("AlarmTreatedCompletedTime") String AlarmTreatedCompletedTime,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxAlarmService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxAlarmService.queryToolboxAlarmTreatedInfo(start, limit, sort, dir, params,AlarmTreatedStartTime,AlarmTreatedCompletedTime));
			modelMap.addAttribute("count", toolBoxAlarmService.countTreated(params,AlarmTreatedStartTime,AlarmTreatedCompletedTime));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	/**
	 * 加载监控诊断工具
	 * 根据分页、排序和其他条件查询记录.
	 * @param start	起始记录行	 * @param limit		查询记录数	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarmtoolsindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryalarmtoolsInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("event_id") String event_id,
			@RequestParam("device_ip") String device_ip,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryalarmtoolsInfo(start, limit, sort, dir, params,event_id,device_ip));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
		
	/**
	 * 加载监控已忽略数据
	 * 根据分页、排序和其他条件查询记录.
	 * @param start	起始记录行
	 * @param limit		查询记录数
	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/ignoredindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryignoredToolboxAlarmInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("AlarmIgnoredStartTime") String AlarmIgnoredStartTime,
			@RequestParam("AlarmIgnoredCompletedTime") String AlarmIgnoredCompletedTime,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxAlarmService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxAlarmService.queryToolboxAlarmIgnoredInfo(start, limit, sort, dir, params,AlarmIgnoredStartTime,AlarmIgnoredCompletedTime));
			modelMap.addAttribute("count", toolBoxAlarmService.countIgnored(params,AlarmIgnoredStartTime,AlarmIgnoredCompletedTime));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	/**
	 * 返回执行界面
	 * @param toolcode	工具编号
	 * @param appsyscode	应用系统
	 * @param shellname	脚本名称
	 * @param usercode	用户 
	 * @param server_route	存放路径
	
	 * *@param event_id	事件编号
	 * @param position_type	存放位置
	 * @param serverGroup	服务器分组名称
	 * @param os_type	操作系统
	 * @param toolcharset 字符集
	 * @param serverip 服务器IP
	 * @return
	 * @throws UnsupportedEncodingException 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/alarmexction", method = RequestMethod.GET)
	public String exction(@RequestParam("toolcode") String toolcode,
			@RequestParam("osuser") String osuser,
			@RequestParam("usercode") String usercode,
			@RequestParam("serverip") String serverip,
			@RequestParam("appsyscode") String appsyscode, 
			@RequestParam("event_id") String event_id, 
			@RequestParam("position_type") String position_type,
			@RequestParam("shellname") String shellname,
			@RequestParam("serverGroup") String serverGroup,
			@RequestParam("os_type") String os_type,
			@RequestParam("toolcharset") String toolcharset,
			@RequestParam("server_route") String server_route,
			 ModelMap modelMap,
			HttpServletRequest request) throws JEDAException, UnsupportedEncodingException, SQLException {
		return viewPrefix+"alarmrunview";
	}
	
	/**
	 * 根据事件号，回填事件单	 * @param event_id	事件号	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/editview", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getViewInfo(@RequestParam("event_id") String event_id,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",toolBoxAlarmService.findById(event_id));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	/**
	 * 
	 * @param event_id
	 * @param handle_status
	 * @param result_summary
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/editDesc", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editDesc(
			@RequestParam("event_id") String event_id,
			@RequestParam("result_summary") String result_summary,
			@RequestParam("jsonBusiness") String jsonBusiness,
			ModelMap modelMap) throws JEDAException, SQLException {
		modelMap.clear();
		JSONArray business = JSONArray.fromObject(jsonBusiness);
		List<Map<String, Object>> businesslist = (List<Map<String, Object>>) JSONArray.toCollection(business, Map.class);	
		toolBoxAlarmService.saveBussinesData(businesslist,event_id);
		toolBoxAlarmService.updateAlarmDesc(event_id,result_summary);
		modelMap.addAttribute("success", Boolean.TRUE);
	
	    return modelMap;
	}
	
	/**
	 * 
	 * @param tool_code
	 * @param event_group
	 * @param summarycn
	 * @param alarminstance
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@Transactional
	@RequestMapping(value = "/editkeywords", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editkeywords(
			@RequestParam(value = "tool_code", required = true) String tool_code,
			@RequestParam(value = "event_group", required = true) String event_group,
			@RequestParam(value = "summarycn", required = true) String summarycn,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		toolBoxAlarmService.updatekeywords(tool_code, event_group,summarycn);
		modelMap.addAttribute("success", Boolean.TRUE);
	
	    return modelMap;
	}
	
	/**
	  
	 * 
	 * @param event_ids
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	
	@RequestMapping(value = "/updataIgnored", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap updataIgnored(
			@RequestParam(value = "event_ids", required = true) String[] event_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		     toolBoxAlarmService.updataIgnored(event_ids);
		     modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	/**
	  
	 * 
	 * @param event_id
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	
	@RequestMapping(value = "/doIgnored", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap doIgnored(
			@RequestParam(value = "event_id", required = true) String event_id,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		     toolBoxAlarmService.updataIgnoredHs(event_id);
		     modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	/**
	 * 
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getEventone", method = RequestMethod.POST)
	public @ResponseBody void getFTone(
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxAlarmService.getEventone();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取小类
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getEventtwo", method = RequestMethod.POST)
	public @ResponseBody void getFTtwo(
			@RequestParam(value = "componenttype" )String componenttype,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		PrintWriter out = null;
		Object names = toolBoxAlarmService.getEventtwo(componenttype);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	
	/**
	 * 获取细类
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getEventthree", method = RequestMethod.POST)
	public @ResponseBody void getFTthree(
			@RequestParam(value = "componenttype" )String componenttype,
			@RequestParam(value = "component" )String component,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxAlarmService.getEventthree(componenttype,component);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	
	/**
	 * 加载监控业务影响
	 * 根据分页、排序和其他条件查询记录.
	 * @param start	起始记录行
	 * @param limit		查询记录数
	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarm_business", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap alarm_business(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("event_id") String event_id,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			
			modelMap.addAttribute("data",
					toolBoxAlarmService.queryalarmbusinessInfo(start, limit, sort, dir, event_id));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	/**
	 * 加载监控业务影响保留数据
	 * 根据分页、排序和其他条件查询记录.
	 * @param start	起始记录行
	 * @param limit		查询记录数
	 * @param sort		排序字段
	 * @param dir		排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/alarm_business_data", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap alarm_business_data(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam("event_id") String event_id,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			
			modelMap.addAttribute("data",
					toolBoxAlarmService.queryalarmbusinessdata(start, limit, sort, dir, event_id));
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}

	/**
	 * 工具箱业务影响配置主页面
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/businessImpactConf", method = RequestMethod.GET)
	public String businessImpactConf() throws JEDAException {
		return viewPrefix+ "businessImpactConf";
	}
	
	/**
	 * 获取业务影响配置目录树数据
	 * @param appsys_code 系统编号
	 * @param business_impact_type 影响分类
	 * @param business_impact_level 影响级别
	 * @return 
	 */
	@RequestMapping(value = "/getImpactConfTree", method = RequestMethod.POST)
	@ResponseBody
	public void getImpactConfTree(
			@RequestParam(value = "appsys_code", required =false ) String appsys_code,
			@RequestParam(value = "business_impact_type", required =false ) String business_impact_type,
			@RequestParam(value = "business_impact_level", required =false ) String business_impact_level,
			HttpServletRequest request, HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		//当前用户的权限系统列表<appsysCode,appsysName>
		List<Map<String,String>> systemList = null ;
		systemList = appInfoService.getSystemIDAndNamesByUserAndIDForTool(securityUtils.getUser().getUsername(),appsys_code);
		//获取服务器分组下的服务器IP，构建目录树
		jsonList = toolBoxAlarmService.buildImpactConfTree(systemList,business_impact_type,business_impact_level);
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 删除业务影响配置数据
	 * @param businessConfId 业务影响配置编号
	 * @return 
	 */
	@RequestMapping(value = "/deleteImpactConf", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteImpactConf(
			@RequestParam(value = "businessConfId", required =false ) String businessConfId,
			ModelMap modelMap) throws IOException{
		toolBoxAlarmService.deleteImpactConfInfo(businessConfId);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap ;
    }
	
	/**
	 * 删除业务影响配置数据
	 * @param businessConfIds 业务影响配置编号数组
	 * @return 
	 */
	@RequestMapping(value = "/multDeleteImpactConf", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap multDeleteImpactConf(
			@RequestParam(value = "businessConfIds", required =false ) String[] businessConfIds,
			ModelMap modelMap) throws IOException{
		toolBoxAlarmService.multDeleteImpactConfInfo(businessConfIds);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap ;
    }
	
	/**
	 * 右键增加弹出框
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/addImpactConfWindow", method = RequestMethod.GET)
	public String addImpactConf() throws JEDAException {
		return viewPrefix+ "businessImpactConfCreate";
	}
	
	
	/**
	 * 增加业务影响配置数据
	 * @param appsys_code 系统编号
	 * @param business_impact_type 影响分类
	 * @param business_impact_level 影响级别
	 * @param business_impact_contents 影响内容数组
	 * @return 
	 * @throws ServletRequestBindingException 
	 */
	@RequestMapping(value = "/saveImpactConf", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap saveImpactConf(
			@RequestParam(value = "appsys_code", required =false ) String appsys_code,
			@RequestParam(value = "business_impact_type", required =false ) String business_impact_type,
			@RequestParam(value = "business_impact_level", required =false ) String business_impact_level,
			@RequestParam(value = "business_impact_contents", required =false ) String[] business_impact_contents,
			ModelMap modelMap) throws IOException, ServletRequestBindingException{
		toolBoxAlarmService.saveImpactConfs(appsys_code,business_impact_type,business_impact_level,business_impact_contents);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap ;
    }
	
	/**
	 * 导出数据至excel文件.
	 * @param appsys_code 系统编号
	 * @param business_impact_type 影响分类
	 * @param business_impact_level 影响级别
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(@RequestParam(value = "appsys_code", required =false ) String appsysCode,
			@RequestParam(value = "business_impact_type", required =false ) String impactType,
			@RequestParam(value = "business_impact_level", required =false ) String impactLevel,
			ModelMap modelMap) throws UnsupportedEncodingException{
		if(impactLevel!=null && !impactLevel.equals("")){
			impactLevel = java.net.URLDecoder.decode(impactLevel,"utf-8") ;
		}
		if(impactType!=null && !impactLevel.equals("")){
			impactType = java.net.URLDecoder.decode(impactType,"utf-8") ;
		}
		if(appsysCode!=null && !impactLevel.equals("")){
			appsysCode = java.net.URLDecoder.decode(appsysCode,"utf-8") ;
		}
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("id", "编号");
		columns.put("appsys_code", "应用系统编号");
		columns.put("business_impact_type", "业务影响分类");
		columns.put("business_impact_level", "业务影响级别");
		columns.put("business_impact_content", "业务影响内容");
		// 显示数据
		List<Map<String,Object>> showMap = new ArrayList<Map<String,Object>>();
		List<Map<String, Object>> impactConflist = toolBoxAlarmService.getImpactRecords(appsysCode,impactType,impactLevel);
		if(impactConflist!=null && impactConflist.size()>0){
			for (Map<String,Object> map : impactConflist) {
				map.put("id", map.get("id").toString());
				map.put("appsys_code", map.get("appsys_code").toString());
				map.put("business_impact_type", map.get("business_impact_type").toString());
				map.put("business_impact_level", map.get("business_impact_level").toString());
				map.put("business_impact_content", map.get("business_impact_content").toString());
				showMap.add(map);
			}
		}
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY,columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,showMap);
		return "excelView";
	}
	
	/**
	 * 构建业务告警策略配置树
	 * @param appsysCode 应用系统编号
	 * @param businessConfId 业务影响配置编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/buildImpactEventConfTree", method = RequestMethod.POST)
	public void buildImpactEventConfTree(
			@RequestParam("appsysCode") String appsysCode,
			@RequestParam("businessConfId") String businessConfId,
			HttpServletRequest request, HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
		//根据应用系统获取报警策略一级分类
		dataList = toolBoxService.queryOneTree(appsysCode);
		jsonList = toolBoxAlarmService.buildImpactEventConfTree(dataList,businessConfId);
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 构建业务告警策略配置树
	 * @param appsysCode 应用系统编号
	 * @param businessConfId 业务影响配置编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getImpactKeyWord", method = RequestMethod.POST)
	public  @ResponseBody ModelMap getImpactKeyWord(
			@RequestParam("appsysCode") String appsysCode,
			@RequestParam("businessConfId") String businessConfId,
			ModelMap modelMap) throws IOException{
		String keyWord = "";
		if(businessConfId!=null && !businessConfId.equals("")){
			keyWord = toolBoxAlarmService.getImpactKeyWordByBusinesesId(businessConfId);
		}
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("keyWord", keyWord);
		return modelMap ;
    }
	
	/**
	 * 增加告警关键字、告警策略配置数据
	 * @param appsys_code 系统编号
	 * @param businessConfId 业务影响配置编号
	 * @param eventGroup 告警策略编码
	 * @param keyword 告警关键字
	 * @return 
	 * @throws ServletRequestBindingException 
	 */
	@RequestMapping(value = "/saveBusinessAlarmAndKeyword", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap saveBusinessAlarmAndKeyword(
			@RequestParam(value = "appsys_code", required =false ) String appsysCode,
			@RequestParam(value = "businessConfId", required =false ) String businessConfId,
			@RequestParam(value = "event_group", required =false ) String eventGroup,
			@RequestParam(value = "keyword", required =false ) String keyword,
			ModelMap modelMap){
		if(businessConfId!=null && !businessConfId.equals("")){
			toolBoxAlarmService.saveBusinessKeyword(businessConfId,appsysCode,keyword);
			toolBoxAlarmService.saveBusinessAlarms(businessConfId,appsysCode,eventGroup);
		}
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap ;
    }
	
	/**
	 * 查询所有未删除的应用系统编号及名称
	 * @param response
	 */
	@RequestMapping(value = "/querySystemIDAndNamesForAlarm", method = RequestMethod.GET)
	public @ResponseBody void querySystemIDAndNamesForAlarm(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIDs = toolBoxAlarmService.querySystemIDAndNamesForAlarm();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIDs));
		} catch (Exception e) {
			e.printStackTrace();
			
		}
		
	}
	
	
}

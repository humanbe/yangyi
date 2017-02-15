package com.nantian.check.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.JobDesignService;
import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.check.vo.CheckJobTimerVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.util.RequestUtil;

/**
 * 巡检作业controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/jobdesign")
public class JobDesignController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignController.class);
	/** 领域对象名称 */
	private static final String domain = "jobdesign";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private JobDesignService jobDesignService;
	@Autowired
	private UserService userService;
	@Autowired
	private MessageSourceAccessor messages;

	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index";
	}

	/**
	 * 分页查询作业信息
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getJobInfoList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getJobInfoList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, jobDesignService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getJobInfoList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, jobDesignService.countJobInfoList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String createJob(){
		return viewPrefix + "create";
	}
	
	/**
	 * 新建系统巡检作业
	 * @param checkJobInfo 作业基本信息数据对象
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap saveJobInfo(@ModelAttribute CheckJobInfoVo checkJobInfo,@ModelAttribute CheckJobTimerVo checkJobTimer,
			      HttpServletRequest request) throws DataIntegrityViolationException,Exception {
		ModelMap modelMap = new ModelMap();
		//获取模板信息
		String templates = ServletRequestUtils.getStringParameter(request, "templates");
		//获取组件IP信息
		String servers = ServletRequestUtils.getStringParameter(request, "servers");
		//获取时间表信息		String timersOnce = ServletRequestUtils.getStringParameter(request, "timerOnceVals");
		String timersDaily = ServletRequestUtils.getStringParameter(request, "timerDailyVals");
		String timersWeekly = ServletRequestUtils.getStringParameter(request, "timerWeeklyVals");
		String timersMonthly = ServletRequestUtils.getStringParameter(request, "timerMonthlyVals");
		String timersInterval = ServletRequestUtils.getStringParameter(request, "timerIntervalVals");
		String bsaFlag = "success";
		//if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
			bsaFlag = jobDesignService.createCommonJob(checkJobInfo,templates,servers,checkJobTimer,
					timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
	//	}
		if(!bsaFlag.equals("success")){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("job.bsaError"));
		}else{
			modelMap.addAttribute("success", Boolean.TRUE);
		}
		return modelMap;
	}
	
	/**
	 * 获取组件目录树数据	 * @param appsysCode 应用系统编号
	 * @throws Exception 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/getServerTree", method = RequestMethod.POST)
	public void getServerTree(
			@RequestParam(value = "fieldType", required =false ) String fieldType,
			@RequestParam(value = "templates", required =false ) String templates,
			HttpServletRequest request, HttpServletResponse response) throws SQLException, Exception{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		jsonList = jobDesignService.buildServerTreeForCommonJob(fieldType,null,null,templates);
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取组件目录树数据 - 编辑
	 * @param appsysCode 应用系统编号
	 * @param jobCode 作业编号
	 * @throws Exception 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/getServerTreeForEdit", method = RequestMethod.POST)
	public @ResponseBody void getServerTreeForEdit(
			@RequestParam(value = "fieldType", required =false )String fieldType,
			@RequestParam(value = "templates", required =false ) String templates,
			@RequestParam(value = "jobCode", required =false )Integer jobCode,
			@RequestParam(value = "isView", required =false )String isView,
		HttpServletRequest request, HttpServletResponse response) throws SQLException, Exception{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		jsonList = jobDesignService.buildServerTreeForCommonJob(fieldType,jobCode,isView,templates);
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取模板目录树数据	 * @param appsysCode 应用系统编号
	 * @throws IOException,Exception 
	 */
	@RequestMapping(value = "/getTemplateTree", method = RequestMethod.POST)
	public @ResponseBody void getTemplateTree(
		   @RequestParam(value = "fieldType", required =false )String fieldType,
		HttpServletRequest request, HttpServletResponse response) throws IOException,Exception{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		if(fieldType !=null && !fieldType.equals("")){
			//获取模板分组下的模板，构建目录树
			jsonList = jobDesignService.buildTemplateTree(fieldType,null,null);
		}
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取模板目录树数据 - 编辑
	 * @param 应用系统编号
	 * @param 作业编号
	 * @throws Exception 
	 */
	@RequestMapping(value = "/getTemplateTreeForEdit", method = RequestMethod.POST)
	public @ResponseBody void getTemplateTreeForEdit(
			@RequestParam(value = "jobCode", required =false )Integer jobCode,
			@RequestParam(value = "isView", required =false )String isView,
			@RequestParam(value = "fieldType", required =false )String fieldType,
		HttpServletRequest request, HttpServletResponse response) throws Exception{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		if(fieldType !=null && !fieldType.equals("")){
			//获取模板分组下的模板，构建目录树
			jsonList = jobDesignService.buildTemplateTree(fieldType,jobCode,null);
		}
		out = response.getWriter();
		out.print(jsonList);
     }
	
	/**
	 * 返回查看页面
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String viewJob() {
		return viewPrefix + "view";
	}

	/**
	 * 根据ID查询作业相关信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/view/{jobid}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap viewJob(@PathVariable("jobid") String jobid, ModelMap modelMap) throws Exception {
		//获取作业信息
		modelMap.addAttribute("data", jobDesignService.getJobInfoById(Integer.valueOf(jobid)));
		//获取时间表信息		modelMap.addAttribute("dataOnce", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"1")); //1:一次		modelMap.addAttribute("dataDaily", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"2")); //2:每天
		modelMap.addAttribute("dataWeekly", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"3")); //3:每周
		modelMap.addAttribute("dataMonthly", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"4")); //4:每月
		modelMap.addAttribute("dataInterval", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"5")); //5:时间间隔
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String editJob() {
		return viewPrefix + "edit";
	}

	/**
	 * 更新修改数据
	 * @param jobid 作业编号
	 * @param checkJobInfo 作业基本信息对象
	 */
	@RequestMapping(value = "/edit/{jobid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editJob(@PathVariable("jobid") java.lang.Integer jobid, HttpServletRequest request,
			@ModelAttribute CheckJobInfoVo checkJobInfo, @ModelAttribute CheckJobTimerVo checkJobTimer
			) throws HibernateOptimisticLockingFailureException,Exception {
		ModelMap modelMap = new ModelMap();
		CheckJobInfoVo jobBaseInfo = (CheckJobInfoVo) jobDesignService.getJobById(jobid);
		//获取巡检模板信息
		 String templates = ServletRequestUtils.getStringParameter(request, "templates");
		//获取组件IP信息
		String servers = ServletRequestUtils.getStringParameter(request, "servers");
		jobBaseInfo.setCheck_type(checkJobInfo.getCheck_type());
		jobBaseInfo.setJob_desc(checkJobInfo.getJob_desc());
		//获取时间表信息		String timersOnce = ServletRequestUtils.getStringParameter(request, "timerOnceVals_edit");
		String timersDaily = ServletRequestUtils.getStringParameter(request, "timerDailyVals_edit");
		String timersWeekly = ServletRequestUtils.getStringParameter(request, "timerWeeklyVals_edit");
		String timersMonthly = ServletRequestUtils.getStringParameter(request, "timerMonthlyVals_edit");
		String timersInterval = ServletRequestUtils.getStringParameter(request, "timerIntervalVals_edit");
		String bsaFlag = "success";
		//if(checkJobInfo.getAuthorize_lever_type().equals("1")){ //常规巡检作业
			bsaFlag = jobDesignService.updateCommonJob(jobBaseInfo,templates,servers,checkJobTimer,
					timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval);
		//}
		if(!bsaFlag.equals("success")){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("job.bsaError"));
		}else{
			modelMap.addAttribute("success", Boolean.TRUE);
		}
		return modelMap;
	}

	/**
	 * 获取该作业关联的组件IP信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/getCheckedServer/{jobid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCheckedServer(@PathVariable("jobid") java.lang.Integer jobid, HttpServletRequest request, ModelMap modelMap)
			throws Exception,Throwable {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getCheckedServer(jobid));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取该作业关联的组件IP信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/getJobServer/{jobid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getJobServer(@PathVariable("jobid") java.lang.Integer jobid, HttpServletRequest request, ModelMap modelMap)
			throws Exception,Throwable {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getJobServerList(jobid));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 获取该作业关联的服务器信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/getServer", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getServer(@RequestParam(value = "osType", required =false )String osType, 
			@RequestParam(value = "serverIp", required =false )String serverIp,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,HttpServletRequest request, ModelMap modelMap)
			throws Exception,Throwable {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getServer(osType,serverIp,sort,dir));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 获取该作业关联的模板信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/getJobTemplate/{jobid}", method = RequestMethod.POST)
	public @ResponseBody 
	ModelMap getJobTemplate(@PathVariable("jobid") java.lang.Integer jobid,
			HttpServletRequest request, ModelMap modelMap)
			throws Exception,Throwable {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getBsaJobInfoList(jobid));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}

	/**
	 * 批量删除,将删除标识置1
	 * @param jobids 作业编号数组
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteJobs(@RequestParam(value = "jobids", required = true) Integer[] jobCodes, ModelMap modelMap)
			throws DataIntegrityViolationException,Exception {
		jobDesignService.deleteJobByIds(jobCodes);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 导出数据至excel文件.
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap){
		Map<String, Object> params = RequestUtil.getQueryMap(request,jobDesignService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		//需要根据现实情况修改		columns.put("job_code", messages.getMessage("job.code_jeda"));
		columns.put("appsys_code", messages.getMessage("job.appsys_code"));
		columns.put("job_name", messages.getMessage("job.name"));
		columns.put("tool_status", messages.getMessage("job.status"));
		columns.put("check_type", messages.getMessage("job.type"));
		columns.put("authorize_lever_type", messages.getMessage("job.authorize_lever_type"));
		columns.put("field_type", messages.getMessage("job.field_type"));
		columns.put("tool_creator", messages.getMessage("job.creator"));
		List<Map<String, Object>> joblist = jobDesignService.getJobInfoList(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, 
				Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params);
		//经过数据字典处理后导出Excel的数据列表		List<Map<String,Object>> showMap = new ArrayList<Map<String,Object>>();
		//获取数据字典显示值与数据库存储值的映射关系
		Map<String, String> itemMap = jobDesignService.findMap();
		if(joblist!=null && joblist.size()>0){
			for (Map<String,Object> map : joblist) {
				String toolStatus = itemMap.get("JOB_STATUS".concat(map.get("tool_status").toString())) ;
				String checkType = itemMap.get("CHECK_TYPE".concat(map.get("check_type").toString())) ;
				String anthorizeType = itemMap.get("CHECK_AUTHORIZE_LEVEL_TYPE".concat(map.get("authorize_lever_type").toString())) ;
				String fieldType = itemMap.get("CHECK_FIELD_TYPE".concat(map.get("field_type").toString())) ;
				map.put("tool_status", toolStatus);
				map.put("check_type", checkType);
				map.put("authorize_lever_type", anthorizeType);
				map.put("field_type", fieldType);
				showMap.add(map);
			}
		}
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY,columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,showMap);
		return "excelView";
	}
	
	/**
	 * 根据用户账号获取账户名称
	 * @param response
	 * @return [username=id,name=name]
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getNameByUsername", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getNameByUsername(@RequestParam(value = "username", required = true) String username,ModelMap modelMap){
		Object name = userService.findByUsername(username);
		modelMap.addAttribute("success", Boolean.FALSE);
		modelMap.addAttribute("info", name); 
		return modelMap;
	}
	
	/**
	 * 查询用户信息系统列表
	 * @param response
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getUsers", method = RequestMethod.GET)
	public @ResponseBody void getUsers(HttpServletResponse response) throws IOException{
		PrintWriter out = null;
		Object users = userService.getUsers();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(users));
		if(out != null){
			out.close();
		}
	}
	
	/**
	 * 查询用户信息系统列表
	 * @param response
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getUserIdNames", method = RequestMethod.GET)
	public @ResponseBody void getUserIdNames(HttpServletResponse response) throws IOException{
		PrintWriter out = null;
		Object users = userService.getUserIdNames();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(users));
		if(out != null){
			out.close();
		}
	}
	
}

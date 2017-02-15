package com.nantian.check.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.check.service.AppJobDesignService;
import com.nantian.check.service.AppJobExcuteService;
import com.nantian.check.service.JobDesignService;
import com.nantian.check.vo.CheckJobInfoVo;
import com.nantian.check.vo.CheckJobTimerVo;
import com.nantian.common.util.ComUtil;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 巡检作业controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/appjobdesign")
public class AppJobDesignController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppJobDesignController.class);
	/** 领域对象名称 */
	private static final String domain = "appjobdesign";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private AppJobDesignService appJobDesignService;
	@Autowired
	private AppJobExcuteService appJobExcuteService;
	@Autowired
	private JobDesignService jobDesignService;
	@Autowired
	private UserService userService;
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	 private SecurityUtils securityUtils; 

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
		Map<String, Object> params = RequestUtil.getQueryMap(request, appJobDesignService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appJobDesignService.getJobInfoList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, appJobDesignService.countJobInfoList(params));
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
	 * 保存新建数据
	 * @param checkJobJedaInfo 作业基本信息数据对象
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	void saveJobInfo(@ModelAttribute CheckJobInfoVo checkJobInfo,@ModelAttribute CheckJobTimerVo checkJobTimer,
			      HttpServletRequest request,HttpServletResponse response) throws DataIntegrityViolationException,Exception {
		PrintWriter resOut = response.getWriter();
		String uploadPath = null;
        //去得当前登录用户
        String username = securityUtils.getUser().getUsername();
        //取得上传脚本
		ServletContext servletContext = request.getSession().getServletContext();
		String shPath = servletContext.getRealPath(File.separatorChar + "CHECK"+ File.separatorChar + username + File.separatorChar);
		DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
		Iterator<?> fileNames = multipartRequest.getFileNames();
		String fileTxt = "";
		MultipartFile multiFile = null;
		if (fileNames.hasNext()) {
			String fileName = (String) fileNames.next();
			multiFile = multipartRequest.getFile(fileName);
			if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
				fileTxt = multiFile.getOriginalFilename();
			} else {
				fileTxt = new String(multiFile.getOriginalFilename().getBytes("GBK"), ComUtil.charset);
			}
			if (fileTxt.length() > 0) {
				uploadPath = shPath +File.separatorChar+ fileTxt;
				InputStream in = null;
				FileOutputStream out = null;
				int len = 0;
				File outDir = new File(shPath);
				if (!outDir.exists()) {
					outDir.mkdirs();
				}
				for (File tmpFile : outDir.listFiles()) {
					tmpFile.delete();
				}
				in = multiFile.getInputStream();
				out = new FileOutputStream(uploadPath);
				byte[] buf = new byte[1024];
				while ((len = in.read(buf)) != -1) {
					out.write(buf, 0, len);
				}
				if (in != null) {
					in.close();
				}
				if (out != null) {
					out.flush();
					out.close();
				}
			}
		}
		
		//获取组件IP信息
		String serverips = ServletRequestUtils.getStringParameter(request, "serverips_appjob");
		//获取时间表信息
		String timersOnce = ServletRequestUtils.getStringParameter(request, "timerOnceVals_appjob");
		String timersDaily = ServletRequestUtils.getStringParameter(request, "timerDailyVals_appjob");
		String timersWeekly = ServletRequestUtils.getStringParameter(request, "timerWeeklyVals_appjob");
		String timersMonthly = ServletRequestUtils.getStringParameter(request, "timerMonthlyVals_appjob");
		String timersInterval = ServletRequestUtils.getStringParameter(request, "timerIntervalVals_appjob");
		String saveFlag = appJobDesignService.createAppJob(checkJobInfo,serverips,checkJobTimer,
				timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval,shPath);
		if(!saveFlag.equals("success")){
			resOut.write("{\"success\":false,\"error\":\""+messages.getMessage("job.bsaError")+ "\"}");
		}else{
			resOut.write("{\"success\":true}");
		}
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
		modelMap.addAttribute("data", appJobExcuteService.getJobInfoById(Integer.valueOf(jobid)));
		//获取时间表信息
		modelMap.addAttribute("dataOnce", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"1")); //1:一次
		modelMap.addAttribute("dataDaily", jobDesignService.getTimersByJobCodeAndFreq(Integer.valueOf(jobid),"2")); //2:每天
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
	 * @param checkJobJedaInfo 作业基本信息对象
	 */
	@RequestMapping(value = "/edit/{jobid}", method = RequestMethod.POST)
	public @ResponseBody
	void editJob(@PathVariable("jobid") java.lang.Integer jobid, HttpServletRequest request,HttpServletResponse response,
			@ModelAttribute CheckJobInfoVo checkJobJedaInfo, @ModelAttribute CheckJobTimerVo checkJobTimer
			) throws HibernateOptimisticLockingFailureException,Exception {
		PrintWriter resOut = response.getWriter();
		//文件上传
		String uploadPath = null;
        //获取当前登录用户
        String username = securityUtils.getUser().getUsername();
        //取得上传脚本
		ServletContext servletContext = request.getSession().getServletContext();
		String shPath = servletContext.getRealPath(File.separatorChar + "CHECK"+ File.separatorChar + username + File.separatorChar);
		DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
		Iterator<?> fileNames = multipartRequest.getFileNames();
		String fileTxt = "";
		MultipartFile multiFile = null;
		if (fileNames.hasNext()) {
			String fileName = (String) fileNames.next();
			multiFile = multipartRequest.getFile(fileName);
			if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
				fileTxt = multiFile.getOriginalFilename();
			} else {
				fileTxt = new String(multiFile.getOriginalFilename().getBytes("GBK"), ComUtil.charset);
			}
			if (fileTxt.length() > 0) {
				uploadPath = shPath +File.separatorChar+ fileTxt;
				InputStream in = null;
				FileOutputStream out = null;
				int len = 0;
				File outDir = new File(shPath);
				if (!outDir.exists()) {
					outDir.mkdirs();
				}
				for (File tmpFile : outDir.listFiles()) {
					tmpFile.delete();
				}
				in = multiFile.getInputStream();
				out = new FileOutputStream(uploadPath);
				byte[] buf = new byte[1024];
				while ((len = in.read(buf)) != -1) {
					out.write(buf, 0, len);
				}
				if (in != null) {
					in.close();
				}
				if (out != null) {
					out.flush();
					out.close();
				}
			}
		}
		//作业基本信息
		CheckJobInfoVo jobBaseInfo = (CheckJobInfoVo) jobDesignService.getJobById(jobid);
		jobBaseInfo.setJob_name(checkJobJedaInfo.getJob_name());
		jobBaseInfo.setCheck_type(checkJobJedaInfo.getCheck_type());
		jobBaseInfo.setJob_desc(checkJobJedaInfo.getJob_desc());
		jobBaseInfo.setAuthorize_lever_type(checkJobJedaInfo.getAuthorize_lever_type()); //巡检方式(临时巡检、常规巡检)
		jobBaseInfo.setFrontline_flag(checkJobJedaInfo.getFrontline_flag()); //一线是否可用
		//jobBaseInfo.setTool_status(checkJobJedaInfo.getTool_status()); //作业状态（开发中、已发布）
		//jobBaseInfo.setAuthorize_flag(checkJobJedaInfo.getAuthorize_flag()); //是否需要授权
		jobBaseInfo.setScript_name(checkJobJedaInfo.getScript_name());
		jobBaseInfo.setExec_path(checkJobJedaInfo.getExec_path());
		jobBaseInfo.setExec_user(checkJobJedaInfo.getExec_user());
		jobBaseInfo.setExec_user_group(checkJobJedaInfo.getExec_user_group());
		jobBaseInfo.setLanguage_type(checkJobJedaInfo.getLanguage_type());
		
		//获取最新上传的sh文件名称
		Boolean newSh = false ; //是否重新上传脚本
		String newShName = ServletRequestUtils.getStringParameter(request, "local_shName_edit");
		if(newShName!=null && !newShName.equals("")){
			newSh = true ;
		}
		//获取组件IP信息
		String serverips = ServletRequestUtils.getStringParameter(request, "serverips");
		//获取时间表信息
		String timersOnce = ServletRequestUtils.getStringParameter(request, "timerOnceVals_edit_appjob");
		String timersDaily = ServletRequestUtils.getStringParameter(request, "timerDailyVals_edit_appjob");
		String timersWeekly = ServletRequestUtils.getStringParameter(request, "timerWeeklyVals_edit_appjob");
		String timersMonthly = ServletRequestUtils.getStringParameter(request, "timerMonthlyVals_edit_appjob");
		String timersInterval = ServletRequestUtils.getStringParameter(request, "timerIntervalVals_edit_appjob");
		String saveFlag = appJobDesignService.updateAppJob(jobBaseInfo,serverips,checkJobTimer,
				timersOnce,timersDaily,timersWeekly,timersMonthly,timersInterval,shPath,newSh);
		if(!saveFlag.equals("success")){
			resOut.write("{\"success\":false,\"error\":\""+messages.getMessage("job.bsaError")+ "\"}");
		}else{
			resOut.write("{\"success\":true}");
		}
	}

	/**
	 * 获取该作业关联的组件IP信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/getJobServer/{jobid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getJobServer(@PathVariable("jobid") java.lang.Integer jobid,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws Exception,Throwable {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, jobDesignService.getJobServerList(jobid));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 批量删除(BSA作业删除，JEDA删除标识置1)
	 * @param jobids 作业编号数组
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteJobs(@RequestParam(value = "jobids", required = true) Integer[] jobCodes, ModelMap modelMap)
			throws DataIntegrityViolationException,Exception {
		appJobDesignService.deleteJobByIds(jobCodes);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取组件目录树数据
	 * @param appsysCode 应用系统编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getServerTree", method = RequestMethod.POST)
	public void getServerTree(
			@RequestParam(value = "appsysCode", required =false ) String appsysCode,
			HttpServletRequest request, HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
		if(appsysCode!=null && !appsysCode.equals("COMMON") ){ //非通用工具系统
			//获取应用系统和服务器分组信息
			dataList = jobDesignService.queryTree(appsysCode);
			//获取服务器分组下的服务器IP，构建目录树
			jsonList = jobDesignService.buildServerTree(dataList,null,null);
		}else{
			//获取服务器的所有操作系统
			dataList = jobDesignService.getServerOsTypes();
			//获取服务器分组下的服务器IP，构建目录树
			jsonList = jobDesignService.buildServerTreeForCommonJob(dataList,null,null);
		}
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取组件目录树数据 - 编辑
	 * @param appsysCode 应用系统编号
	 * @param jobCode 作业编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getServerTreeForEdit", method = RequestMethod.POST)
	public @ResponseBody void getServerTreeForEdit(
			@RequestParam(value = "appsysCode", required =false )String appsysCode,
			@RequestParam(value = "jobCode", required =false )Integer jobCode,
			@RequestParam(value = "isView", required =false )String isView,
		HttpServletRequest request, 
		HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
		if(appsysCode!=null && !appsysCode.equals("COMMON") ){ //非通用工具系统
			//获取应用系统和服务器分组信息
			dataList = jobDesignService.queryTree(appsysCode);
			//获取服务器分组下的服务器IP，构建目录树
			jsonList = jobDesignService.buildServerTree(dataList,jobCode,isView);
		}else{
			//获取服务器的所有操作系统
			dataList = jobDesignService.getServerOsTypes();
			//获取服务器分组下的服务器IP，构建目录树
			jsonList = jobDesignService.buildServerTreeForCommonJob(dataList,jobCode,isView);
		}
		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 导出数据至excel文件.
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap){
		Map<String, Object> params = RequestUtil.getQueryMap(request,appJobDesignService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		//需要根据现实情况修改
		columns.put("job_code", messages.getMessage("job.code_jeda"));
		columns.put("appsys_code", messages.getMessage("job.appsys_code"));
		columns.put("job_name", messages.getMessage("job.name"));
		columns.put("tool_status", messages.getMessage("job.status"));
		columns.put("check_type", messages.getMessage("job.type"));
		columns.put("authorize_lever_type", messages.getMessage("job.authorize_lever_type"));
		columns.put("field_type", messages.getMessage("job.field_type"));
		columns.put("tool_creator", messages.getMessage("job.creator"));
		List<Map<String, Object>> joblist = appJobDesignService.getJobInfoList(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, 
				Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params);
		//经过数据字典处理后导出Excel的数据列表
		List<Map<String,Object>> showMap = new ArrayList<Map<String,Object>>();
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
	
	/**
	 * 根据上传路径读取文件信息
	 * @param checkJobInfoVo 作业基本信息
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/showShData", method = RequestMethod.POST)
	public @ResponseBody
	void list(@ModelAttribute CheckJobInfoVo checkJobInfoVo,
			HttpServletRequest request,HttpServletResponse response, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
		modelMap.clear();
        PrintWriter resOut = response.getWriter();
		try {
			String uploadPath = null;
			//取得当前登录用户
			String username = securityUtils.getUser().getUsername();
			//取得上传脚本
	 		ServletContext servletContext = request.getSession().getServletContext();
	 		String shPath = servletContext.getRealPath(File.separatorChar + "CHECK"+ File.separatorChar + username + File.separatorChar);
	 		DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
	 		Iterator<?> fileNames = multipartRequest.getFileNames();
	 		String fileTxt = "";
	 		MultipartFile multiFile = null;
			if (fileNames.hasNext()) {
				String fileName = (String) fileNames.next();
				multiFile = multipartRequest.getFile(fileName);
				if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
					fileTxt = multiFile.getOriginalFilename();
				} else {
					fileTxt = new String(multiFile.getOriginalFilename().getBytes("GBK"), ComUtil.charset);
				}
				if (fileTxt.length() > 0) {
					uploadPath = shPath +File.separatorChar+ fileTxt;
					InputStream in = null;
					FileOutputStream out = null;
					int len = 0;
					File outDir = new File(shPath);
					if (!outDir.exists()) {
						outDir.mkdirs();
					}
					for (File tmpFile : outDir.listFiles()) {
						tmpFile.delete();
					}
					in = multiFile.getInputStream();
					out = new FileOutputStream(uploadPath);
					byte[] buf = new byte[1024];
					while ((len = in.read(buf)) != -1) {
						out.write(buf, 0, len);
					}
					if (in != null) {
						in.close();
					}
					if (out != null) {
						out.flush();
						out.close();
					}
				}
			}
			String name=checkJobInfoVo.getScript_name();
			shPath=shPath+File.separatorChar+name;
			modelMap.addAttribute("success", Boolean.TRUE);
			resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) appJobDesignService.readText(shPath,checkJobInfoVo), "utf-8")+"\"}");
		}catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
		}catch (AxisFault eo) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("AxisFault"));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("AxisFault"), "utf-8")+ "\"}");
		}catch(Exception eo){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("Exception"));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
		}
	}
	
	/**
	 * 根据上传路径读取文件信息
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/showShDataFromBsa", method = RequestMethod.POST)
	public @ResponseBody
	void fileView(@ModelAttribute CheckJobInfoVo checkJobInfoVo,
			HttpServletRequest request,HttpServletResponse response, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
		 modelMap.clear();
         PrintWriter resOut = response.getWriter();
			try {
				String username = securityUtils.getUser().getUsername();
				String scriptName= checkJobInfoVo.getScript_name();
				ServletContext servletContext = request.getSession().getServletContext();
				String shPath = servletContext.getRealPath(File.separatorChar +"download"+ File.separatorChar + username + File.separatorChar);
				File outDir = new File(shPath);
				if (!outDir.exists()) {
					outDir.mkdirs();
				}
				//通过API取bas上.sh文件路径
				String basShPath=(String) appJobDesignService.getShPath(checkJobInfoVo);
				//调起nsh作业将.sh脚本复制到本地
				String filePath=shPath+File.separatorChar+scriptName;
				//sh放到服务器中的路径
				String resultpath="";
				if(ComUtil.isWindows){
					resultpath="//"+messages.getMessage("systemServer.ip") + "/" + filePath.replace(":", "").replace("\\", "/");
				}else{
					resultpath="//"+messages.getMessage("systemServer.ip") +  filePath;
				}
				appJobDesignService.exeTempJob(checkJobInfoVo,basShPath,resultpath);
				modelMap.addAttribute("success", Boolean.TRUE);
				resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) appJobDesignService.readText(filePath,checkJobInfoVo), "utf-8")+"\"}");
		}catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
		}catch (AxisFault eo) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("AxisFault"));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("AxisFault"), "utf-8")+ "\"}");
		}catch(Exception eo)
		{
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", messages.getMessage("Exception"));
			resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
		}
	}
	
	/**
	 * 判断作业是否重复
	 * @param 
	 * @rerurn 存在返回true , 不存在返回false 
	 */
	@RequestMapping(value = "/isJobRepeat", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap isJobRepeat(@RequestParam(value = "appsysCode", required = true) String appsysCode,
			@RequestParam(value = "jobName", required = true) String jobName,
			ModelMap modelMap)
			throws DataIntegrityViolationException,Exception {
		modelMap.addAttribute("success",appJobDesignService.jobIsExist(appsysCode,jobName));
		return modelMap;
	}
	
	/**
	 * 脚本下载
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/downloadfile", method = RequestMethod.GET)
	public String downloadfile(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("jobid") String jobId) throws JEDAException, SQLException {
		ServletContext servletContext = request.getSession().getServletContext();
		//当前用户
		String username = securityUtils.getUser().getUsername();
		//脚本名称
		String scriptName= ((CheckJobInfoVo) jobDesignService.getJobById(Integer.valueOf(jobId))).getScript_name();
		String shPath = servletContext.getRealPath(File.separatorChar +"download"+ File.separatorChar + username + File.separatorChar);
		//脚本下载路径
		String filePath=shPath+File.separatorChar+scriptName;
		modelMap.addAttribute("PATH",filePath);
		//返回servletName
		return "fileView";
	}
	
}

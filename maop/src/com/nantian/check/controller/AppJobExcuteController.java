package com.nantian.check.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.AppJobDesignService;
import com.nantian.check.service.AppJobExcuteService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.util.RequestUtil;

/**
 * 应用巡检作业执行controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/appjobexcute")
public class AppJobExcuteController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppJobExcuteController.class);
	/** 领域对象名称 */
	private static final String domain = "appjobexcute";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private AppJobExcuteService appJobExcuteService;
	@Autowired
	private AppJobDesignService appJobDesignService;
	@Autowired
	private UserService userService;
	
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
		Map<String, Object> params = RequestUtil.getQueryMap(request, appJobExcuteService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appJobDesignService.getJobInfoList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, appJobDesignService.countJobInfoList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
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
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	

	/**
	 * 批量执行作业
	 * @param jobCodes 作业编号数组
	 */
	@RequestMapping(value = "/excute", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap excuteJobs(@RequestParam(value = "jobCodes", required = true) Integer[] jobCodes,ModelMap modelMap)
		 throws DataIntegrityViolationException,Exception {
		String nums = appJobExcuteService.excuteJobByDBKeys(jobCodes);
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("info", nums);
		return modelMap;
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
	
}

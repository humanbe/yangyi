package com.nantian.toolbox.controller;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.controller.JobDesignController;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.toolbox.service.ToolBoxParamService;

@Controller
@RequestMapping("/" + Constants.APP_PATH + "/ToolBoxParamController")
public class ToolBoxParamController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignController.class);

	@Autowired
	private ToolBoxParamService toolBoxParamService;
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
	 * 根据工具编号，应用系统获取工具参数列表
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			ModelMap modelMap,HttpServletRequest request)
			throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			
			modelMap.addAttribute("data", toolBoxParamService.findById(tool_code,appsys_code));
			modelMap.addAttribute("count", toolBoxParamService.countParam(tool_code, appsys_code));
			
			
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}


	/**
	 * 批量删除参数
	 * @param tool_codes
	 * @param appsys_codes
	 * @param param_names
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes, 
			@RequestParam(value = "appsys_codes", required = true) String[] appsys_codes, 
			@RequestParam(value = "param_names", required = true) String []param_names, 
			ModelMap modelMap) throws JEDAException, SQLException {	
			toolBoxParamService.deleteByIds(tool_codes,appsys_codes,param_names);
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
			

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 *            起始记录行
	 * @param limit
	 *            查询记录数
	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/createparam", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap saveParam(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				toolBoxParamService.fields);
		try {
			modelMap.addAttribute("data",toolBoxParamService.queryCreateParam(start, limit, sort, dir, params));
			modelMap.addAttribute("count", toolBoxParamService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	
	
	
	

}

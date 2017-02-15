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
import org.springframework.dao.DataIntegrityViolationException;
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
import com.nantian.toolbox.service.ToolBoxServerService;
import com.nantian.toolbox.service.ToolBoxService;

@Controller
@RequestMapping("/" + Constants.APP_PATH + "/ToolBoxServerController")
public class ToolBoxServerController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignController.class);

	@Autowired
	private ToolBoxServerService toolBoxServerService;
	@Autowired
	private ToolBoxService toolboxService;

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
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/findip", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap findServerIp(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam(value = "server_group") String server_group,
			@RequestParam(value = "appsys_code") String appsys_code,
			@RequestParam(value = "os_type") String os_type,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, SQLException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				toolBoxServerService.fields);
		if(null==os_type||"".equals(os_type)){
			os_type="";
       }else{
    	   os_type=toolboxService.getOstype(os_type);
       }
		try {
			modelMap.addAttribute("data3", toolBoxServerService.findServerIp(start,
					limit, sort, dir, params,appsys_code,os_type));
			modelMap.addAttribute("count", toolBoxServerService.count(params,appsys_code,os_type));
			modelMap.addAttribute("success", Boolean.TRUE);			
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}

	
	/**
	 * 根据工具编号，应用系统获取服务器列表
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(
			@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			@RequestParam("os_type") String os_type,
			@RequestParam("ip") String ip,
			@RequestParam("app") String app,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			
			os_type=toolboxService.getOstype(os_type);
			modelMap.addAttribute("data3",toolBoxServerService.findById(tool_code, appsys_code,os_type,ip,app));
			
			modelMap.addAttribute("count", toolBoxServerService.findById(tool_code, appsys_code,os_type,ip,app).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 根据工具编号，应用系统获取服务器列表
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/viewEdit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap viewEdit(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			@RequestParam(value = "server_group" )String server_group,
			@RequestParam(value = "os_type") String os_type,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			
			os_type=toolboxService.getOstype(os_type);
			modelMap.addAttribute("data",toolBoxServerService.findByIdEdit(tool_code, appsys_code,server_group,os_type));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}


	/**
	 * 批量删除服务器
	 * 
	 * @param tool_code
	 *           工具编号
	 *  @param appsys_codes         
	 *           工具编号
	 * @param server_ips
	 *         服务器ip           
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "appsys_codes", required = true) String[] appsys_codes,
			@RequestParam(value = "server_ips", required = true) String[] server_ips,
			ModelMap modelMap) throws DataIntegrityViolationException,Exception,JEDAException {	
		
			toolBoxServerService.deleteByIds(tool_codes, appsys_codes,server_ips);
			modelMap.addAttribute("success", Boolean.TRUE);		
		    return modelMap;
	}
	


}

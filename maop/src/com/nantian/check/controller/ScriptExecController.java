package com.nantian.check.controller;

import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.hibernate.exception.ConstraintViolationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.nantian.check.service.ScriptDeployService;
import com.nantian.check.service.ScriptExecService;
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
import com.nantian.dply.controller.CmnEnvironmentController;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;

/**
 * 日志管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/scriptExec")
public class ScriptExecController {

	/** 领域对象名称 */
	private static final String domain = "scriptExec";

	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain +"_";
	
	/** Service */
	@Autowired
	private ScriptExecService scriptExecService;
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(CmnEnvironmentController.class);
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
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "index";
	}

	/**
	 * 根据分页、排序和其他条件查询编码信息记录
	 * @param start         起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段
	 * @param dir	  		   排序的方式
	 * @param appsysCode  系统代码
	 * @param environmentType  环境类型
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptExecService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptExecService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, scriptExecService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}

	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/exec", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "exec";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param cmnEnvironmentVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CheckItemInfoVo checkItemInfoVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            scriptExecService.save(checkItemInfoVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 查询数据库中是否存在值
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryInit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryInit(
			@RequestParam(value = "osType", required = false) String osType,
			@RequestParam(value = "checkItemCode", required = false) String checkItemCode,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptExecService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptExecService.queryInit( osType,checkItemCode));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 查询数据库中是否存在值


	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryServerIp", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryGroupExist(
			@RequestParam(value = "osType", required = false) String osType,
			@RequestParam(value = "serverIp", required = false) String serverIp,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptExecService.queryServerIp( osType,serverIp,appsysCode));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/execall", method = RequestMethod.GET)
	public String execall() throws JEDAException {
		return viewPrefix + "all";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param cmnEnvironmentVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/execall", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap execall(@ModelAttribute CheckItemInfoVo checkItemInfoVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            scriptExecService.execall(checkItemInfoVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 查询巡检项脚本
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryScript", method = RequestMethod.POST)
	public @ResponseBody
	void queryScript(
			@RequestParam(value = "osType", required = false) String osType,
			HttpServletRequest request,
			HttpServletResponse response) throws DataAccessException, SQLException,Exception {
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		try{
		List<Map<String, String>> dataList = scriptExecService.queryTree(osType);
		//List<Map<String,String>> list = scriptExecService.findScript(dataList);
		jsonList = scriptExecService.scriptExecService(dataList);
		
		out = response.getWriter();
		out.print(jsonList);
		
		} catch (Throwable e) {
		e.printStackTrace();
		
		// 输出异常结束日志
		if (logger.isEnableFor("Component0999")) {
			logger.log("Component0999", ComUtil.getCurrentMethodName());
			}
		}
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
			}
   }
}

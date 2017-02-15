package com.nantian.check.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.hibernate.exception.ConstraintViolationException;
import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
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
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.dply.service.DplySystemLogService;
import com.nantian.dply.vo.CmnEnvironmentVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;

/**
 * 日志管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/scriptDeploy")
public class ScriptDeployController {

	/** 领域对象名称 */
	private static final String domain = "scriptDeploy";

	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain +"_";
	
	/** Service */
	@Autowired
	private ScriptDeployService scriptDeployService;

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
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptDeployService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptDeployService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, scriptDeployService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}

	
	/**
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/allindex", method = RequestMethod.GET)
	public String allindex() throws JEDAException {
		return viewPrefix + "allindex";
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
	@RequestMapping(value = "/allindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap alllist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptDeployService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptDeployService.queryAllinit(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, scriptDeployService.countAllinit(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}

	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/allinit", method = RequestMethod.GET)
	public String allinitView() throws JEDAException {
		return viewPrefix + "allinit";
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/deploy", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "deploy";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CheckItemInfoVo checkItemInfoVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            scriptDeployService.save(checkItemInfoVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	/**
	 * 总项初始化保存
	 * 
	 * @return
	 */
	@RequestMapping(value = "/exec", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap execAllInit(@ModelAttribute CheckItemInfoVo checkItemInfoVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            scriptDeployService.execAllInit(checkItemInfoVo);
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
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptDeployService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptDeployService.queryInit( osType,checkItemCode));
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
	@RequestMapping(value = "/queryAllInit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryAllInit(@RequestParam(value = "flag", required = false) String flag,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptDeployService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptDeployService.queryAllInit(flag ));
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
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptDeployService.queryServerIp( osType,serverIp));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
}

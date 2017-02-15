package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
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

import com.nantian.check.controller.JobDesignController;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.RptDatasourceConfService;
import com.nantian.rept.vo.RptDatasourceConfVo;
import com.nantian.toolbox.service.FieldTypeService;
import com.nantian.toolbox.vo.FieldTypeInfoVo;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/rptdatasourceconf")
public class RptDatasourceConfController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignController.class);

	/** 监控领域对象名称 */
	private static final String domain = "RptDatasourceConf";
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	@Autowired
	private RptDatasourceConfService rptDatasourceConfService;
	@Autowired
    private SecurityUtils securityUtils; 
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
	 * 返回服务器配置页面

	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	/**
	 * 返回工具分类新建
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		
		return  viewPrefix+ "Create";
	}
	
	/**
	 * 返回工具分类查看
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String fieldtypeView() throws JEDAException {
		
		return  viewPrefix+ "View";
	}
	/**
	 * 返回工具分类修改页面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String fieldtypeEdit() throws JEDAException {
		
		return  viewPrefix+ "Edit";
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
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap findServerIp(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, SQLException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				rptDatasourceConfService.fields);
		
		try {
			modelMap.addAttribute("data", rptDatasourceConfService.query(start,
					limit, sort, dir, params));
			//modelMap.addAttribute("count", fieldTypeService.count(params));
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
	ModelMap view(@RequestParam("aplCode") String aplCode,
			@RequestParam("dataType") Integer dataType,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("data",rptDatasourceConfService.queryAllfieldTypeInfo(aplCode, dataType));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 保存修改数据
	 * 
	 * @param osuser 数据对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@ModelAttribute RptDatasourceConfVo rptDatasourceConfVo,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		rptDatasourceConfService.saveOrUpdate(rptDatasourceConfVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param osuser 数据对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap create(@ModelAttribute RptDatasourceConfVo rptDatasourceConfVo,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		rptDatasourceConfService.save(rptDatasourceConfVo);
		modelMap.addAttribute("success", Boolean.TRUE);
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
			@RequestParam(value = "aplCodes", required = true) String[] aplCodes,
			@RequestParam(value = "dataTypes", required = true) Integer[] dataTypes,
			ModelMap modelMap) throws DataIntegrityViolationException,Exception,JEDAException {	
		
			rptDatasourceConfService.deleteByIds(aplCodes,dataTypes);
			modelMap.addAttribute("success", Boolean.TRUE);		
		    return modelMap;
	}
	
	/**
	 * 获取专业领域分类一级信息，返回[field_type_one]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getDatasource", method = RequestMethod.POST)
	public @ResponseBody void getDatasource(
			@RequestParam(value = "dataType", required =false )String fieldType,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = rptDatasourceConfService.getDatasource(fieldType);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}

}

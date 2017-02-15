package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.WeblogicConfService;
import com.nantian.rept.vo.WeblogicConfVo;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/weblogicconfmanage")
public class WeblogicConfController {
	/** 模板管理领域对象名称 */
	private static final String domain = "WeblogicConfManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private WeblogicConfService weblogicConfService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
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
	 * 返回weblogic配置页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询weblogic配置信息
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param changeMonth
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, weblogicConfService.fields);
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					weblogicConfService.queryWeblogicConfList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<Map<String, String>>)request.getSession().getAttribute("weblogicConfList4Export")).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method  = RequestMethod.GET)
	public String view() throws JEDAException{
		return viewPrefix + "View";
	}
	
	/**
	 * 根据系统编号、ip、服务名和端口号查询
	 * @param aplCode 系统编号
	 * @param ipAddress ip地址
	 * @param serverName 服务名
	 * @param weblogicPort 端口号
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "ipAddress", required = true) String ipAddress,
			@RequestParam(value = "serverName", required = true) String serverName,
			@RequestParam(value = "weblogicPort", required = true) String weblogicPort,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					weblogicConfService.queryWeblogicConfInfo(aplCode, ipAddress, serverName, weblogicPort));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String create() throws JEDAException{
		return viewPrefix + "Create";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param weblogicConfVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute WeblogicConfVo weblogicConfVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			weblogicConfService.save(weblogicConfVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("aplCode", weblogicConfVo.getAplCode());
			modelMap.addAttribute("ipAddress", weblogicConfVo.getIpAddress());
			modelMap.addAttribute("serverName", weblogicConfVo.getServerName());
			modelMap.addAttribute("serverJdbcName", weblogicConfVo.getServerJdbcName());
			modelMap.addAttribute("weblogicPort", weblogicConfVo.getWeblogicPort());
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("error.record.exist") + "]");
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}
	
	/**
	 * 编辑更新数据
	 * @param aplCode 系统编号
	 * @param ipAddress ip地址
	 * @param serverName 服务名
	 * @param weblogicPort 端口
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{ipAddress}/{serverName}/{weblogicPort}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@PathVariable("aplCode") String aplCode,
			@PathVariable("ipAddress") String ipAddress,
			@PathVariable("serverName") String serverName,
			@PathVariable("weblogicPort") String weblogicPort,
			HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {
		try {
			WeblogicConfVo weblogicConfVo = (WeblogicConfVo) weblogicConfService.queryWeblogicConfInfo(
					aplCode, ipAddress, serverName, weblogicPort);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(weblogicConfVo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
			//操作流水保存更新前数据
		    binder.bind(request);
		    weblogicConfService.update(weblogicConfVo);
		    modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 批量删除信息
	 * @param aplCodes 系统编号数组
	 * @param ipAddresses ip地址数组
	 * @param serverNames 服务名数组
	 * @param weblogicPorts 端口数组
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String [] aplCodes,
			@RequestParam(value = "ipAddresses", required = true) String[] ipAddresses,
			@RequestParam(value = "serverNames", required = true) String[] serverNames,
			@RequestParam(value = "weblogicPorts", required = true) String[] weblogicPorts,
			ModelMap modelMap) throws JEDAException{
		try {
			weblogicConfService.deleteByUnionKeys(aplCodes, ipAddresses, serverNames, weblogicPorts);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 导出查询结果
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("aplCode", messages.getMessage("property.appsyscd"));
		columns.put("ipAddress", messages.getMessage("property.ipAddress"));
		columns.put("serverName", messages.getMessage("property.serverName"));
		columns.put("serverJdbcName", "服务JDBC名称");
		columns.put("weblogicFlg", messages.getMessage("property.weblogicFlg"));
		columns.put("clusterServer", messages.getMessage("property.clusterServer"));
		columns.put("weblogicPort", messages.getMessage("property.weblogicPort"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, request.getSession().getAttribute("weblogicConfList4Export"));
		
		return "excelView";
	}
	
	/**
	 * 查询所有应用系统编号简称
	 * @param response
	 */
	@RequestMapping(value = "/queryAplCodes", method = RequestMethod.GET)
	public @ResponseBody void queryAplCodes(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIds = weblogicConfService.queryAplCodes();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIds));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 根据应用系统编号 获取服务器名称
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/servername", method = RequestMethod.GET)
	public @ResponseBody void servername(
			@RequestParam(value = "appsysCode", required = true) String appsysCode,
			@RequestParam(value = "itemName", required = false) String itemName,
			HttpServletResponse response) throws JEDAException, UnsupportedEncodingException{
		PrintWriter out = null;
		Object itemLevelsMap = weblogicConfService.queryWeblogicServernameForRpt(appsysCode,"");
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(itemLevelsMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
	}
	
	@RequestMapping(value = "/weblogicservername", method = RequestMethod.GET)
	public @ResponseBody void weblogicservername(
			@RequestParam(value = "appsysCode", required = true) String appsysCode,
			@RequestParam(value = "itemName", required = false) String itemName,
			HttpServletResponse response) throws JEDAException, UnsupportedEncodingException{
		PrintWriter out = null;
		Object itemLevelsMap = weblogicConfService.queryWeblogicServernameForRpt(appsysCode,"WBLG_JDBC");
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(itemLevelsMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
	}
}

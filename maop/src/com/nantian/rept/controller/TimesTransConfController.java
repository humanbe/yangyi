package com.nantian.rept.controller;

import java.io.PrintWriter;
import java.net.URLDecoder;
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
import com.nantian.rept.service.TimesTransConfService;
import com.nantian.rept.service.impl.TimesTransService;
import com.nantian.rept.vo.TimesTransConfVo;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/timestransconfmanage")
public class TimesTransConfController {
	/** 模板管理领域对象名称 */
	private static final String domain = "TimesTransConfManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private TimesTransConfService timesTransConfService;
	
	@Autowired
	private TimesTransService timesTransService;
	
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
	 * 返回分钟和秒交易量配置页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询分钟和秒交易量配置信息
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
		Map<String, Object> params = RequestUtil.getQueryMap(request, timesTransConfService.fields);
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					timesTransConfService.queryTimesTransConfList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<Map<String, String>>)request.getSession().getAttribute("timesTransConfList4Export")).size());
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
	 * 根据系统编号和统计科目名查询
	 * @param aplCode 系统编号
	 * @param countItem 统计科目名
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "countItem", required = true) String countItem,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					timesTransConfService.queryTimesTransConfInfo(aplCode, countItem));
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
	 * @param timesTransConfVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute TimesTransConfVo timesTransConfVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			timesTransConfService.save(timesTransConfVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("aplCode", timesTransConfVo.getAplCode());
			modelMap.addAttribute("countItem", timesTransConfVo.getCountItem());
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
	 * @param countItem 统计科目名
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{countItem}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@PathVariable("aplCode") String aplCode,
			@PathVariable("countItem") String countItem,
			HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {
		try {
			countItem = URLDecoder.decode(countItem, "utf-8");
			TimesTransConfVo timesTransConfVo = (TimesTransConfVo) timesTransConfService.queryTimesTransConfInfo(
					aplCode, countItem);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(timesTransConfVo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
			//操作流水保存更新前数据
		    binder.bind(request);
		    timesTransConfService.update(timesTransConfVo);
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
	 * @param countItems 统计科目名数组
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String [] aplCodes,
			@RequestParam(value = "countItems", required = true) String[] countItems,
			ModelMap modelMap) throws JEDAException{
		try {
			timesTransConfService.deleteByUnionKeys(aplCodes, countItems);
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
		columns.put("countItem", messages.getMessage("property.countItem"));
		columns.put("relatedItem", messages.getMessage("property.relatedItem"));
		columns.put("type", messages.getMessage("property.type"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, request.getSession().getAttribute("timesTransConfList4Export"));
		
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
			Object sysIds = timesTransConfService.queryAplCodes();
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
	 * 查询最近的分钟和秒科目列表
	 * @param response
	 */
	@RequestMapping(value = "/queryLatestItems", method = RequestMethod.GET)
	public @ResponseBody void queryLatestItems(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object items = timesTransService.queryLatestItems(aplCode);
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(items));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
}

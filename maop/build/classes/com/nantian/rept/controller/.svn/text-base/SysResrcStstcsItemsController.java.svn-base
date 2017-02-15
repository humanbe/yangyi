package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
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

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.SysResrcStstcsItemsService;
import com.nantian.rept.vo.SysResrcStstcsItemsVo;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/sysresrcststcs")
public class SysResrcStstcsItemsController {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(SysResrcStstcsItemsController.class);
	
	/** 领域对象名称 */
	private static final String domain = "SysResrcStstcs";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	/** 服务 */
	@Autowired
	private SysResrcStstcsItemsService sysResrcStstcsItemsService;
	
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
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询系统资源统计口径
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "hostsType", required = false) String hostsType,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, sysResrcStstcsItemsService.fields);
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					sysResrcStstcsItemsService.querySysResrcStstcsItemsList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					request.getSession().getAttribute("ststcsItemsList4Export"));
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
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
	 * 根据系统编号和类型查询
	 * @param aplCode
	 * @param hostsType
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "hostsType", required = true) String hostsType,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					sysResrcStstcsItemsService.querySysResrcStstcsItems(aplCode, hostsType));
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
	 * @param ststcsItemsVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute SysResrcStstcsItemsVo ststcsItemsVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			sysResrcStstcsItemsService.save(ststcsItemsVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("aplCode", ststcsItemsVo.getAplCode());
			modelMap.addAttribute("hostsType", ststcsItemsVo.getHostsType());
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
	 * @param hostsType 类型
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{hostsType}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@PathVariable("aplCode") String aplCode,
			@PathVariable("hostsType") String hostsType,
			HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {
		try {
			SysResrcStstcsItemsVo ststcsItemsVo = 
					(SysResrcStstcsItemsVo)sysResrcStstcsItemsService.querySysResrcStstcsItems(aplCode, hostsType);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(ststcsItemsVo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
			//操作流水保存更新前数据
		    binder.bind(request);
		    sysResrcStstcsItemsService.update(ststcsItemsVo);
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
	 * 批量删除变更信息
	 *  @param aplCodes 系统编号数组
	 * @param hostsTypes 类型数组
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String [] aplCodes,
			@RequestParam(value = "hostsTypes", required = true) String [] hostsTypes,
			ModelMap modelMap) throws JEDAException{
		try {
			sysResrcStstcsItemsService.deleteByUnionKeys(aplCodes, hostsTypes);
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
	 * 查询所有应用系统编号简称
	 * @param response
	 */
	@RequestMapping(value = "/queryAplCodes", method = RequestMethod.GET)
	public @ResponseBody void queryAplCodes(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIds = sysResrcStstcsItemsService.queryAplCodes();
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
	 * 查询系统编号和系统名称的映射集合
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseAplCodeNm", method = RequestMethod.GET)
	public @ResponseBody void browseWeekRptAplCode(
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object aplCodeNmMap = sysResrcStstcsItemsService.queryAplCodeNm();
		
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(aplCodeNmMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
		
	}
	
}

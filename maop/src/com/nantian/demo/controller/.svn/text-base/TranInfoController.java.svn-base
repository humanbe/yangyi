//Controller
//.java
/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.demo.controller;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

import com.nantian.demo.vo.TranInfoVo;
import com.nantian.demo.service.TranInfoService;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;


/**
 * @author <a href="mailto:qiaoxiaolei@nantian.com.cn">qiaoxiaolei</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/traninfo")
public class TranInfoController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(TranInfoController.class);

	/** 领域对象名称 */
	private static final String domain = "TranInfo";

	/** 视图前缀 */
	private static final String viewPrefix = "demo/" + domain + "/" + domain;
	
	/** 服务 */
	@Autowired
	private TranInfoService traninfoService;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
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
		binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
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
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, traninfoService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, traninfoService.find(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, traninfoService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			//logger.info(messages.getMessage("log.info.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			//logger.error(messages.getMessage("log.error.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		}
		return modelMap;
	}
	
		/**
	 * 导出数据至excel文件.
	 * 
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, traninfoService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		//需要根据现实情况修改
		columns.put("name", messages.getMessage("resource.name"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, traninfoService.find(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params));
		return "excelView";
	}

	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		return viewPrefix + "Create";
	}

	/**
	 * 保存新建数据
	 * 
	 * @param customer 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute TranInfoVo traninfo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			//securityUtils.setCreateEntity(traninfo);// 设置新建数据的操作用户及时间信息
			traninfoService.save(traninfo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("tranid", traninfo.getTranid());
			//logger.info(messages.getMessage("log.info.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), traninfo.getTranid() }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("resource.error.duplicate.id") + "]");
			//logger.error(messages.getMessage("log.error.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			//logger.error(messages.getMessage("log.error.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		}
		return modelMap;
	}

	/**
	 * 返回编辑页面
	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}

	/**
	 * 更新编辑数据
	 * 
	 * @param id
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{tranid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@PathVariable("tranid") java.lang.String tranid, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			TranInfoVo traninfo = (TranInfoVo) traninfoService.get(tranid);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(traninfo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
		    binder.bind(request);
			//securityUtils.setModifyEntity(traninfo);// 设置修改数据的操作用户及时间信息
			traninfoService.update(traninfo);
			modelMap.addAttribute("success", Boolean.TRUE);
			//logger.info(messages.getMessage("log.info.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), tranid }));
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			//logger.error(messages.getMessage("log.error.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), tranid }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			//logger.error(messages.getMessage("log.error.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), tranid }));
		}
		return modelMap;
	}

	/**
	 * 返回查看页面
	 * 
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "View";
	}

	/**
	 * 根据ID查询.
	 * 
	 * @param id 主键
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view/{tranid}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap view(@PathVariable("tranid") String tranid, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data", traninfoService.findById(tranid));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 批量删除.
	 * 
	 * @param ids 主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(@RequestParam(value = "tranids", required = true) String[] tranids, ModelMap modelMap)
			throws JEDAException {
		try {
			traninfoService.deleteByIds(tranids);
			modelMap.addAttribute("success", Boolean.TRUE);
			//logger.info(messages.getMessage("log.info.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
			//logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			//logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		}
		return modelMap;
	}

}
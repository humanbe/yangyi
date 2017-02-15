/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
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
import com.nantian.jeda.common.model.Module;
import com.nantian.jeda.security.service.ModuleService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 模块控制器.
 * 
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/module")
public class ModuleController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ModuleController.class);

	/** 领域对象名称 */
	private static final String domain = Module.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private final String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_SECURITY + "/" + domain + "/" + domain + "_";

	/** 服务 */
	@Autowired
	private ModuleService moduleService;

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
	}

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String list() throws JEDAException {
		return viewPrefix + "list";
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param parent 上级机构
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/list", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir, HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, moduleService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, moduleService.find(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, moduleService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (DataAccessException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			logger.error(messages.getMessage("log.error.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		}
		return modelMap;
	}

	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		return viewPrefix + "create";
	}

	/**
	 * 保存新建数据
	 * 
	 * @param module 数据对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute Module module) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			securityUtils.setCreateEntity(module);// 设置新建数据的操作用户及时间信息
			moduleService.save(module);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", module.getId());
			logger.info(messages.getMessage("log.info.create",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), module.getId() }));
		} catch (DataIntegrityViolationException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("menu.error.duplicate.identity") + "]");
			logger.error(messages.getMessage("log.error.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
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
		return viewPrefix + "edit";
	}

	/**
	 * 更新编辑数据
	 * 
	 * @param id
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{id}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap update(@PathVariable("id") String id, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			Module module = (Module) moduleService.get(id);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(module);
			binder.bind(request);
			securityUtils.setModifyEntity(module);// 设置修改数据的操作用户及时间信息
			moduleService.update(module);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id }));
		} catch (HibernateOptimisticLockingFailureException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			logger.error(messages.getMessage("log.error.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.edit", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id }));
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
		return viewPrefix + "view";
	}

	/**
	 * 返回查看数据
	 * 
	 * @param id 主键
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view/{id}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap get(@PathVariable("id") String id, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, moduleService.findById(id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 批量删除
	 * 
	 * @param ids 主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(@RequestParam(value = "ids", required = true) String[] ids, ModelMap modelMap) throws JEDAException {
		try {
			moduleService.deleteByIds(ids);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		} catch (DataIntegrityViolationException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
			logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		}
		return modelMap;
	}

	/**
	 * 返回所有数据.
	 * 
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/get", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap get(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, moduleService.find());
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataAccessException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}
}

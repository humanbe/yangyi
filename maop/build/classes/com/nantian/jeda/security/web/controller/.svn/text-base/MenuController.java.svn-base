/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
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
import com.nantian.jeda.common.model.Menu;
import com.nantian.jeda.security.service.MenuService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.security.web.editor.MenuEditor;
import com.nantian.jeda.util.RequestUtil;

/**
 * 菜单控制器.
 * 
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/menu")
public class MenuController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(MenuController.class);

	/** 领域对象名称 */
	private final String domain = Menu.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private final String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_SECURITY + "/" + domain + "/" + domain + "_";

	/** 服务 */
	@Autowired
	private MenuService menuService;

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
		binder.registerCustomEditor(Menu.class, new MenuEditor(menuService));
	}

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "index";
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param parent 上级菜单
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam(value = "parent", required = false, defaultValue = "") String parent, HttpServletRequest request, ModelMap modelMap)
			throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, menuService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, menuService.find(parent, start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, menuService.count(parent, params));
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			logger.error(messages.getMessage("log.error.list", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain) }));
		}
		return modelMap;
	}

	/**
	 * 导出数据至excel文件.
	 * 
	 * @param request
	 * @param parent
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, @RequestParam(value = "parent", required = false, defaultValue = "") String parent,
			ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, menuService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("id", messages.getMessage("menu.id"));
		columns.put("name", messages.getMessage("menu.name"));
		columns.put("url", messages.getMessage("menu.url"));
		columns.put("parent", messages.getMessage("menu.parent"));
		columns.put("description", messages.getMessage("menu.description"));
		columns.put("order", messages.getMessage("column.order"));

		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, menuService.find(parent, 0, Constants.DEFAULT_EXCEL_ROW_LIMIT,
				Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params));
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
		return viewPrefix + "create";
	}

	/**
	 * 保存新建数据
	 * 
	 * @param menu 数据对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute Menu menu) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			securityUtils.setCreateEntity(menu);// 设置新建数据的操作用户及时间信息
			menuService.save(menu);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", menu.getId());
			logger.info(messages.getMessage("log.info.create",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), menu.getId() }));
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
			Menu menu = (Menu) menuService.get(id);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(menu);
			binder.registerCustomEditor(Menu.class, new MenuEditor(menuService));
			binder.bind(request);
			securityUtils.setModifyEntity(menu);// 设置修改数据的操作用户及时间信息
			menuService.update(menu);
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
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, menuService.findById(id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
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
			menuService.deleteByIds(ids);
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
	 * 返回导航菜单列表
	 * 
	 * @param node 上级菜单ID
	 * @return 导航菜单列表
	 */
	@RequestMapping(value = "/nav", method = RequestMethod.GET)
	public @ResponseBody
	List<Map<String, String>> nav(@RequestParam("node") String node) {
		return menuService.findNav(node);
	}

	/**
	 * 返回下级记录集合.
	 * 
	 * @param node 记录主键
	 * @return
	 */
	@RequestMapping(value = "/children", method = RequestMethod.GET)
	public @ResponseBody
	List<Map<String, Object>> children(@RequestParam("node") String node) {
		return menuService.findByParent(node);
	}

}

/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.controller;

import java.util.ArrayList;
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
import org.springframework.web.bind.ServletRequestUtils;
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
import com.nantian.jeda.common.model.Field;
import com.nantian.jeda.common.model.Function;
import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.common.model.Permission;
import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.common.model.User;
import com.nantian.jeda.config.service.SubItemService;
import com.nantian.jeda.security.service.FieldService;
import com.nantian.jeda.security.service.FunctionService;
import com.nantian.jeda.security.service.OrgService;
import com.nantian.jeda.security.service.PermissionService;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.PermissionProvider;
import com.nantian.jeda.security.util.UserSession;
import com.nantian.jeda.security.web.editor.FieldEditor;
import com.nantian.jeda.security.web.editor.FunctionEditor;
import com.nantian.jeda.security.web.editor.SubItemEditor;
import com.nantian.jeda.util.RequestUtil;

/**
 * 权限功能控制器.
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/permission")
public class PermissionController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PermissionController.class);

	/** 领域对象名称 */
	private final String domain = Permission.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private final String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_SECURITY + "/" + domain + "/" + domain + "_";

	/** 用户权限类型:登录用户 */
	public final static String USER_TYPE_CREATOR = "1";

	/** 用户权限类型:指定用户 */
	public final static String USER_TYPE_CREATOR_ASSIGN = "2";

	/** 服务 */
	@Autowired
	private PermissionService permissionService;

	@Autowired
	private FunctionService functionService;

	@Autowired
	private SubItemService subitemService;

	@Autowired
	private FieldService fieldService;

	@Autowired
	private UserService userService;

	@Autowired
	private OrgService orgService;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	@Autowired
	private UserSession userSession;
	@Autowired
	private PermissionProvider permissionProvider;

	/**
	 * 注册Editor
	 * 
	 * @param binder
	 */
	@InitBinder
	public void initBinder(WebDataBinder binder) {
		binder.registerCustomEditor(Function.class, new FunctionEditor(functionService));
		binder.registerCustomEditor(SubItem.class, new SubItemEditor(subitemService));
		binder.registerCustomEditor(Field.class, new FieldEditor(fieldService));
	}

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String list() throws JEDAException {
		return viewPrefix + "list";
	}

	/**
	 * 返回列表数据
	 * 
	 * @param start 起始记录行
	 * @param limit 查询记录数
	 * @param sort 排序字段
	 * @param dir 排序方向
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

		Map<String, Object> params = RequestUtil.getQueryMap(request, permissionService.fields);
		try {
			String functionId = ServletRequestUtils.getStringParameter(request, "functionId");
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, permissionService.find(start, limit, sort, dir, functionId, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, permissionService.count(functionId, params));
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.list", new String[] { userSession.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			logger.error(messages.getMessage("log.error.list", new String[] { userSession.getUserFullName(), messages.getMessage(domain) }));
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

		Map<String, Object> params = RequestUtil.getQueryMap(request, permissionService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("name", messages.getMessage("permission.name"));
		columns.put("function", messages.getMessage("permission.function"));
		columns.put("expression", messages.getMessage("permission.expression"));
		columns.put("description", messages.getMessage("permission.description"));
		columns.put("order", messages.getMessage("column.order"));
		columns.put("creator", messages.getMessage("column.creator"));
		columns.put("created", messages.getMessage("column.created"));
		columns.put("modifier", messages.getMessage("column.modifier"));
		columns.put("modified", messages.getMessage("column.modified"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, permissionService.find(0, Constants.DEFAULT_EXCEL_ROW_LIMIT,
				Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, null, params));
		return Constants.DEFAULT_EXCEL_VIEW;
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
	 * @param permission 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap create(@ModelAttribute Permission permission, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			userSession.setCreateEntity(permission);// 设置新建数据的操作用户及时间信息
			if (permission.getType().equals(Permission.TYPE_USER)) {// 用户权限
				if (permission.getUserType().equals(USER_TYPE_CREATOR)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.username='" + permissionProvider.USER_NAME + "'");
				} else if (permission.getUserType().equals(USER_TYPE_CREATOR_ASSIGN)) {//
					String[] checkedUsers = ServletRequestUtils.getStringParameters(request, "checkedUsers");
					for (String username : checkedUsers) {
						permission.addAssociatedUser((User) userService.get(username));
					}
				}
			} else if (permission.getType().equals(Permission.TYPE_ORG)) {// 机构权限
				if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.id='" + permissionProvider.ORG_ID + "'");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_DOWN)) {
					permission.setExpression("@" + permission.getField().getCode() + "@ in (" + permissionProvider.HIGHER_ORGS + ")");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_UP)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.path like '%" + permissionProvider.ORG_ID + "%'");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_ASSIGN)) {
					String[] checkedOrgs = ServletRequestUtils.getStringParameters(request, "checkedOrgs");
					for (String orgId : checkedOrgs) {
						permission.addAssociatedOrg((Org) orgService.get(orgId));
					}
				}
			} else if (permission.getType().equals(Permission.TYPE_ITEM)) {// 字典权限
				permission.setExpression("@" + permission.getField().getCode() + "@='" + permission.getSubitem().getValue() + "'");
			} else if (permission.getType().equals(Permission.TYPE_CONSTANT)) {// 数值权限
				permission.setExpression("@" + permission.getField().getCode() + "@" + permission.getFieldValue());
			}
			permissionService.save(permission);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", permission.getId());
			logger.info(messages.getMessage("log.info.create", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					permission.getId().toString() }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.create", new String[] { userSession.getUserFullName(), messages.getMessage(domain) }));
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
	 * @param permission
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@ModelAttribute Permission permission, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		Permission p = (Permission) permissionService.get(permission.getId());
		try {
			userSession.setModifyEntity(permission);// 设置修改数据的操作用户及时间信息
			if (permission.getType().equals(Permission.TYPE_USER)) {// 用户权限
				if (permission.getUserType().equals(USER_TYPE_CREATOR)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.username='" + permissionProvider.USER_NAME + "'");
				} else if (permission.getUserType().equals(USER_TYPE_CREATOR_ASSIGN)) {
					permission.setAssociatedUsers(p.getAssociatedUsers());
					String[] checkedUsers = ServletRequestUtils.getStringParameters(request, "checkedUsers");
					String[] uncheckedUsers = ServletRequestUtils.getStringParameters(request, "uncheckedUsers");
					for (String username : uncheckedUsers) {
						permission.getAssociatedUsers().remove(userService.get(username));
					}
					for (String username : checkedUsers) {
						permission.getAssociatedUsers().add((User) userService.get(username));
					}

				}
			} else if (permission.getType().equals(Permission.TYPE_ORG)) {// 机构权限
				if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.id='" + permissionProvider.ORG_ID + "'");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_DOWN)) {
					permission.setExpression("@" + permission.getField().getCode() + "@ in (" + permissionProvider.HIGHER_ORGS + ")");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_UP)) {
					permission.setExpression("@" + permission.getField().getCode() + "@.path like '%" + permissionProvider.ORG_ID + "%'");
				} else if (permission.getOrgType().equals(Permission.ORG_TYPE_CREATOR_ORG_ASSIGN)) {
					permission.setAssociatedOrgs(p.getAssociatedOrgs());
					String[] checkedOrgs = ServletRequestUtils.getStringParameters(request, "checkedOrgs");
					String[] uncheckedOrgs = ServletRequestUtils.getStringParameters(request, "uncheckedOrgs");
					for (String orgId : uncheckedOrgs) {
						permission.getAssociatedOrgs().remove(orgService.get(orgId));
					}
					for (String orgId : checkedOrgs) {
						permission.getAssociatedOrgs().add((Org) orgService.get(orgId));
					}

				}
			} else if (permission.getType().equals(Permission.TYPE_ITEM)) {// 字典权限
				permission.setExpression("@" + permission.getField().getCode() + "@='" + permission.getSubitem().getValue() + "'");
			} else if (permission.getType().equals(Permission.TYPE_CONSTANT)) {// 数值权限
				permission.setExpression("@" + permission.getField().getCode() + "@" + permission.getFieldValue());
			}
			permissionService.evict(p);
			permissionService.update(permission);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.edit", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					permission.getId().toString() }));
		} catch (HibernateOptimisticLockingFailureException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			logger.error(messages.getMessage("log.error.edit", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					permission.getId().toString() }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.edit", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					permission.getId().toString() }));
		}
		return modelMap;
	}

	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "view";
	}

	/**
	 * 根据ID查询.
	 * 
	 * @param id 主键
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view/{id}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap view(@PathVariable("id") String id, ModelMap modelMap) throws JEDAException {

		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, permissionService.findById(id));
			modelMap.addAttribute("success", Boolean.TRUE);
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
	ModelMap delete(@RequestParam(value = "ids", required = true) Long[] ids, ModelMap modelMap) throws JEDAException {
		try {
			permissionService.deleteByIds(ids);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage(
					"log.info.delete",
					new String[] { userSession.getUserFullName(), messages.getMessage(domain),
							StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
			logger.error(messages.getMessage("log.error.delete", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.delete", new String[] { userSession.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		}
		return modelMap;
	}

	/**
	 * 返回模块或者可配权限功能的树形数据.
	 * 
	 * @param node 上级节点ID
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/function", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> function(@RequestParam("node") String node) throws JEDAException {
		return functionService.findModuleAndFunction(node);
	}

	/**
	 * 
	 * @param orgId
	 * @param permissionId
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/user", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> getUser(@RequestParam("node") String orgId,
			@RequestParam(value = "permissionId", defaultValue = "") String permissionId) throws JEDAException {
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		list.addAll(userService.findByOrgAndPermission(orgId, permissionId));
		list.addAll(orgService.findByParent(orgId, true));
		return list;
	}

	/**
	 * 根据上级机构查询机构信息.用于新建机构权限页面树型数据显示.
	 * 
	 * @param org
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/org", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> getOrgTree(@RequestParam("node") String org) throws JEDAException {
		return orgService.findByParent(org);
	}

	/**
	 * 根据上级机构和相关联权限查询.用于修改机构权限页面树型数据显示.
	 * 
	 * @param org
	 * @param permission
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/{permission}/org", method = RequestMethod.GET)
	public @ResponseBody
	List<Map<String, Object>> getOrgTree(@RequestParam("node") String org, @PathVariable("permission") String permission) throws JEDAException {
		return orgService.findByPermission(org, permission);
	}
}

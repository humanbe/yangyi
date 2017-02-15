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
import org.springframework.security.web.access.intercept.JedaFilterInvocationSecurityMetadataSource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.CommonConst;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Function;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.service.FunctionService;
import com.nantian.jeda.security.service.MenuService;
import com.nantian.jeda.security.service.OrgService;
import com.nantian.jeda.security.service.PermissionService;
import com.nantian.jeda.security.service.RoleService;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 角色控制器.
 * 
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/role")
public class RoleController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(RoleController.class);

	/** 领域对象名称 */
	private final String domain = Role.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private final String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_SECURITY + "/" + domain + "/" + domain + "_";

	/** 服务 */
	@Autowired
	private RoleService roleService;

	@Autowired
	private UserService userService;

	@Autowired
	private FunctionService functionService;

	@Autowired
	private MenuService menuService;

	@Autowired
	private OrgService orgService;

	@Autowired
	private PermissionService permissionService;

	@Autowired
	private JedaFilterInvocationSecurityMetadataSource filterInvocationSecurityMetadataSource;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	@Autowired
	private SecurityUtils securityUtils;

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws FrameworkException
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
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap list(@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir, HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, roleService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, roleService.find(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, roleService.count(params));
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
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, roleService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("name", messages.getMessage("role.name"));
		columns.put("description", messages.getMessage("role.description"));
		columns.put("order", messages.getMessage("column.order"));
		columns.put("creator", messages.getMessage("column.creator"));
		columns.put("created", messages.getMessage("column.created"));
		columns.put("modifier", messages.getMessage("column.modifier"));
		columns.put("modified", messages.getMessage("column.modified"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
				roleService.find(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params));
		modelMap.addAttribute("count", roleService.count(params));
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
	 * @param role 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap save(@ModelAttribute Role role) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			securityUtils.setCreateEntity(role);// 设置新建数据的操作用户及时间信息

			Function index = (Function) functionService.get("INDEX");// 新建角色默认具有首页访问权限
			role.addFunction(index);

			roleService.save(role);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", role.getId());
			logger.info(messages.getMessage("log.info.create",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), role.getId() }));
		} catch (DataIntegrityViolationException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("role.error.duplicate.id") + "]");
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
	@ResponseBody
	public ModelMap update(@PathVariable("id") String id, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			Role role = (Role) roleService.get(id);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(role);
			binder.bind(request);
			securityUtils.setModifyEntity(role);// 设置修改数据的操作用户及时间信息
			roleService.update(role);
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
	 * 返回查看数据.
	 * 
	 * @param id 主键
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view/{id}", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap get(@PathVariable("id") String id, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, roleService.findById(id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 查询所有数据
	 * 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/find", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap find(ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, roleService.findMap());
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
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	@ResponseBody
	public ModelMap delete(@RequestParam(value = "ids", required = true) String[] ids, ModelMap modelMap) throws JEDAException {
		try {
			roleService.deleteByIds(ids);
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

	// ------------------------------------------------------------------------------------------------------------------------

	/**
	 * 返回分配用户页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/user", method = RequestMethod.GET)
	public String assignUser() throws JEDAException {
		return viewPrefix + "user_assign";
	}

	/**
	 * 根据组织机构和角色查询用户.
	 * 
	 * @param org 组织机构ID
	 * @param role 角色
	 * @return 记录集合
	 */
	@RequestMapping(value = "/user/{role}", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> assignUser(@RequestParam("node") String org, @PathVariable("role") String role) throws JEDAException {
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		list.addAll(userService.findByOrgAndRole(org, role));
		list.addAll(orgService.findByRole(org, role));
		return list;
	}

	/**
	 * 保存与用户的关联信息.
	 * 
	 * @param menus 用户名数组
	 * @param role 角色编码
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/user", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap saveRoleUser(@RequestParam("checked") String[] checked, @RequestParam("unchecked") String[] unchecked,
			@RequestParam("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRoleUser(checked, unchecked, role);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	// ------------------------------------------------------------------------------------------------------------------------

	/**
	 * 返回分配菜单页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/menu", method = RequestMethod.GET)
	public String assignMenu() throws JEDAException {
		return viewPrefix + "menu_assign";
	}

	/**
	 * 根据父级记录和角色查询菜单.
	 * 
	 * @param node 父级菜单ID
	 * @param role 角色
	 * @return 记录集合
	 */
	@RequestMapping(value = "/menu/{role}", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> assignMenu(@RequestParam("node") String node, @PathVariable("role") String role) throws JEDAException {
		return menuService.findByRole(node, role);
	}

	/**
	 * 保存与菜单的关联信息.
	 * 
	 * @param menus 菜单编码数组
	 * @param role 角色编码
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/menu", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap assignMenu(@RequestParam("menus") String[] menus, @RequestParam("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRelationWithMenu(menus, role);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	// ------------------------------------------------------------------------------------------------------------------------

	/**
	 * 返回分配功能页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/function", method = RequestMethod.GET)
	public String function() throws JEDAException {
		return viewPrefix + "function";
	}

	/**
	 * 
	 * 
	 * @param role
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/function/{role}", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> function(@RequestParam("node") String node, @PathVariable("role") String role, ModelMap modelMap)
			throws JEDAException {
		return functionService.findModuleAndFunctionByRole(node, role);
	}

	/**
	 * 保存与资源的关联信息.
	 * 
	 * @param checkedIds
	 * @param avaliableIds
	 * @param role
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/function", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap function(@RequestParam("checked") String[] checkedIds, @RequestParam("unchecked") String[] uncheckedIds,
			@RequestParam("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRoleFunction(checkedIds, uncheckedIds, role);
			filterInvocationSecurityMetadataSource.init();
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	// ------------------------------------------------------------------------------------------------------------------------

	/**
	 * 返回分配数据权限页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/permission", method = RequestMethod.GET)
	public String assignPermission() throws JEDAException {
		return viewPrefix + "permission";
	}

	/**
	 * 根据分页、排序和角色信息查询数据权限.
	 * 
	 * @param role
	 * @param function
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/permission/{role}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap assignPermission(@PathVariable("role") String role, HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			String functionId = ServletRequestUtils.getStringParameter(request, "functionId");
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, permissionService.findByRoleAndFunction(role, functionId));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 保存角色与权限的关联信息.
	 * 
	 * @param permissionIds 权限ID数组
	 * @param roleId 角色ID
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/permission", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap assignPermission(@RequestParam("permissionIds") Long[] permissionIds, @RequestParam("roleId") String roleId,
			@RequestParam("functionId") String functionId, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRolePermission(permissionIds, roleId, functionId);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回分配BRPM角色页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/brpmrole", method = RequestMethod.GET)
	public String assignBrpmRole() throws JEDAException {
		return viewPrefix + "brpmrole_assign";
	}

	/**
	 * 返回用户的brpm角色数据.
	 * 
	 * @param user
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/brpmrole/{role}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap assignBrpmRole(@PathVariable("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("roles", roleService.findBrpmRoleByRole(role, CommonConst.CHAR_ZERO));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 保存与brpm角色的关联信息.
	 * 
	 * @param ids 已选中brpm角色数组
	 * @param role 角色编码
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/brpmroles", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap saveBrpmRole(@RequestParam("ids") String[] ids,
			@RequestParam("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRoleBrpm(ids, role);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回分配bsa角色页面
	 * 
	 * @return 授权页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/bsarole", method = RequestMethod.GET)
	public String assignBsaRole() throws JEDAException {
		return viewPrefix + "bsarole_assign";
	}

	/**
	 * 返回用户的bsa角色数据.
	 * 
	 * @param user
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/bsarole/{role}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap assignBsaRole(@PathVariable("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("roles", roleService.findBsaRoleByRole(role, CommonConst.CHAR_ONE));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 保存与bsa角色的关联信息.
	 * 
	 * @param ids 已选中bsa角色数组
	 * @param role 角色编码
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/bsaroles", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap saveBsaRole(@RequestParam("ids") String[] ids,
			@RequestParam("role") String role, ModelMap modelMap) throws JEDAException {
		try {
			roleService.saveRoleBsa(ids, role);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

}

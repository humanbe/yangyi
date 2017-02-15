/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.controller;

import java.util.List;
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
import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.common.model.Position;
import com.nantian.jeda.common.model.PositionLevel;
import com.nantian.jeda.security.service.OrgService;
import com.nantian.jeda.security.service.PositionLevelService;
import com.nantian.jeda.security.service.PositionService;
import com.nantian.jeda.security.service.RoleService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 岗位控制器.
 * 
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/position")
public class PositionController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(FunctionController.class);

	/** 领域对象名称 */
	private final String domain = Position.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private final String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_SECURITY + "/" + domain + "/" + domain + "_";

	/** 岗位类型:全局 */
	private static final String TYPE_GLOBLE = "0";
	/** 岗位类型:指定机构 */
	private static final String TYPE_ORG = "1";
	/** 岗位类型:指定级别 */
	private static final String TYPE_LEVEL = "2";

	/** 服务 */
	@Autowired
	private PositionService positionService;

	@Autowired
	private RoleService roleService;

	@Autowired
	private OrgService orgService;

	@Autowired
	private PositionLevelService positionLevelService;

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
		Map<String, Object> params = RequestUtil.getQueryMap(request, positionService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, positionService.find(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, positionService.count(params));
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
	 * @param position 数据对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute Position position, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			securityUtils.setCreateEntity(position);// 设置新建数据的操作用户及时间信息
			if (position.getType().equalsIgnoreCase(TYPE_GLOBLE)) {

			} else if (position.getType().equalsIgnoreCase(TYPE_ORG)) {
				String[] checkedOrgs = ServletRequestUtils.getStringParameters(request, "checkedOrgs");
				for (String orgId : checkedOrgs) {
					Object org = orgService.get(orgId);
					if (org != null) {
						position.addOrg((Org) org);
					}
				}
			} else if (position.getType().equalsIgnoreCase(TYPE_LEVEL)) {
				String[] positionLevels = ServletRequestUtils.getStringParameters(request, "positionLevel");
				for (String pl : positionLevels) {
					Object positionLevel = positionLevelService.get(pl);
					if (positionLevel != null) {
						position.addPositionLevel((PositionLevel) positionLevel);
					}
				}
			}
			positionService.save(position);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", position.getId());
			logger.info(messages.getMessage("log.info.create", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain),
					position.getId().toString() }));
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
	ModelMap update(@PathVariable("id") Long id, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			Position position = (Position) positionService.get(id);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(position);
			binder.bind(request);
			securityUtils.setModifyEntity(position);// 设置修改数据的操作用户及时间信息
			if (position.getType().equalsIgnoreCase(TYPE_GLOBLE)) {
				position.clearPositionLevel();
				position.clearOrg();
			} else if (position.getType().equalsIgnoreCase(TYPE_ORG)) {
				String[] checkedOrgs = ServletRequestUtils.getStringParameters(request, "checkedOrgs");
				String[] uncheckedOrgs = ServletRequestUtils.getStringParameters(request, "uncheckedOrgs");
				for (String orgId : uncheckedOrgs) {
					Object org = orgService.get(orgId);
					if (org != null) {
						position.getOrgs().remove(org);
					}
				}
				for (String orgId : checkedOrgs) {
					Object org = orgService.get(orgId);
					if (org != null) {
						position.addOrg((Org) org);
					}
				}
				position.clearPositionLevel();
			} else if (position.getType().equalsIgnoreCase(TYPE_LEVEL)) {
				String[] positionLevels = ServletRequestUtils.getStringParameters(request, "positionLevel");
				position.clearPositionLevel();
				for (String pl : positionLevels) {
					Object positionLevel = positionLevelService.get(pl);
					if (positionLevel != null) {
						position.addPositionLevel((PositionLevel) positionLevel);
					}
				}
				position.clearOrg();
			}
			positionService.update(position);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.edit",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id.toString() }));
		} catch (HibernateOptimisticLockingFailureException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			logger.error(messages.getMessage("log.error.edit",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id.toString() }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			logger.error(messages.getMessage("log.error.edit",
					new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), id.toString() }));
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
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, positionService.findById(id));
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
			positionService.deleteByIds(ids);
			modelMap.addAttribute("success", Boolean.TRUE);
			logger.info(messages.getMessage("log.info.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain),
					StringUtils.arrayToDelimitedString((Object[]) ids, "|") }));
		} catch (DataIntegrityViolationException e) {
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
	 * 返回岗位关联角色页面
	 * 
	 * @return 关联角色页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/role", method = RequestMethod.GET)
	public String role() throws JEDAException {
		return viewPrefix + "role";
	}

	/**
	 * 返回岗位的角色数据.
	 * 
	 * @param position
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/{position}/role", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap role(@PathVariable("position") String position, ModelMap modelMap) {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, roleService.findByPosition(position));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 保存岗位与角色的关联信息.
	 * 
	 * @param roleIds 角色id数组
	 * @param positionId 岗位
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/{position}/role", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap role(@PathVariable("position") Long positionId, @RequestParam("ids") String[] roleIds, ModelMap modelMap) {
		try {
			positionService.savePositionRole(positionId, roleIds);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 根据上级机构和相关联岗位查询.
	 * 
	 * @param org
	 * @param position
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/{position}/org", method = RequestMethod.GET)
	public @ResponseBody
	List<Map<String, Object>> getOrgTree(@RequestParam("node") String org, @PathVariable("position") String position) throws JEDAException {
		return orgService.findByPosition(org, position);
	}

	/**
	 * 根据上级机构查询机构信息.
	 * 
	 * @param org
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/org", method = RequestMethod.GET)
	public @ResponseBody
	List<Map<String, Object>> getOrgTree(@RequestParam("node") String org) throws JEDAException {
		return orgService.findByParent(org);
	}

	/**
	 * 返回门户应用设置页面
	 * 
	 * @return 门户应用设置页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/portlet", method = RequestMethod.GET)
	public String portlet() throws JEDAException {
		return viewPrefix + "portlet";
	}

}

/**
 * 
 */
package com.nantian.jeda.config.web.controller;

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
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Item;
import com.nantian.jeda.config.service.ItemService;
import com.nantian.jeda.security.util.ItemProvider;
import com.nantian.jeda.security.util.UserSession;
import com.nantian.jeda.util.RequestUtil;

/**
 * 数据项控制器.
 * 
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/item")
public class ItemController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ItemController.class);

	/** 领域对象名称 */
	private String domain = Item.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/" + Constants.MODULE_CATEGORY_CONFIG + "/" + domain + "/" + domain + "_";

	/** 服务 */
	@Autowired
	private ItemService itemService;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	@Autowired
	private UserSession userSession;

	@Autowired
	private ItemProvider itemProvider;

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String list() throws JEDAException {
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
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/list", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap list(@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir, HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, itemService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemService.find(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemService.count(params));
		return modelMap;
	}
	
	/**
	 * 返回列表页面_报表定制-参数配置
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/rptParam", method = RequestMethod.GET)
	public String rptParam() throws JEDAException {
		return viewPrefix + "rpt_param";
	}
	
	/**
	 * 获取数据字典数据_报表定制-参数配置
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/rptParam", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap rptParam(HttpServletRequest request,ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, itemService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemService.findCheckList(params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemService.count(params));
		return modelMap;
	}
	
	/**
	 * 返回列表页面_报表定制-参数配置(修改)
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/rptParamForEdit", method = RequestMethod.GET)
	public String rptParamForEdit() throws JEDAException {
		return viewPrefix + "rpt_param_edit";
	}
	
	/**
	 * 返回列表页面_报表定制-字段配置
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/rptColumn", method = RequestMethod.GET)
	public String rptColumn() throws JEDAException {
		return viewPrefix + "rpt_column";
	}
	
	/**
	 * 获取数据字典数据_报表定制-字段配置
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/rptColumn", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap rptColumn(HttpServletRequest request,ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, itemService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemService.findCheckList(params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemService.count(params));
		return modelMap;
	}
	
	/**
	 * 返回列表页面_报表定制-字段配置(修改)
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/rptColumnForEdit", method = RequestMethod.GET)
	public String rptColumnForEdit() throws JEDAException {
		return viewPrefix + "rpt_column_edit";
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
	public String exportXls(HttpServletRequest request, ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request, itemService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("pid", messages.getMessage("item.id"));
		columns.put("pname", messages.getMessage("item.name"));
		columns.put("pdescription", messages.getMessage("item.description"));
		columns.put("porder", messages.getMessage("column.order"));
		columns.put("name", messages.getMessage("subitem.name"));
		columns.put("value", messages.getMessage("subitem.value"));
		columns.put("order", messages.getMessage("column.order"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
				itemService.findSubs(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, Constants.DEFAULT_SORT_FIELD, Constants.DEFAULT_SORT_DIRECTION, params));
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
	 * @param item
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap create(@ModelAttribute Item item) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			userSession.setCreateEntity(item);// 设置新建数据的操作用户及时间信息
			itemService.save(item);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("id", item.getId());
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
			Item item = (Item) itemService.get(id);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(item);
			binder.bind(request);
			userSession.setModifyEntity(item);// 设置修改数据的操作用户及时间信息
			itemService.update(item);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
			e.printStackTrace();
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
	 * @param id
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view/{id}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap get(@PathVariable("id") String id, ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemService.findById(id));
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
	public @ResponseBody
	ModelMap delete(@RequestParam(value = "ids", required = true) String[] ids, ModelMap modelMap) throws JEDAException {
		try {
			itemService.deleteByIds(ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataIntegrityViolationException e) {
			e.printStackTrace();
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
	 * 返回数据子项集合.
	 * 
	 * @param id 数据项ID
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/{itemId}/sub", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap getSubItem(@PathVariable("itemId") String itemId, ModelMap modelMap) throws JEDAException {
		Object subs = itemProvider.getSubItemMap(itemId);
		if (subs != null) {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, subs);
		}
		return modelMap;
	}

	/**
	 * 返回根据权限过滤后的数据子项集合.
	 * 
	 * @param id 数据项ID
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/{itemId}/{functionId}/permission/sub", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap getSubItemByPermission(@PathVariable("itemId") String itemId, @PathVariable("functionId") String functionId, ModelMap modelMap)
			throws JEDAException {
		List<Map<String, Object>> permissionSubs = itemProvider.getSubItemMapByPermission(itemId, functionId);
		if (permissionSubs != null && !permissionSubs.isEmpty()) {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, permissionSubs);
		} else {
			Object subs = itemProvider.getSubItemMap(itemId);
			if (subs != null) {
				modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, subs);
			}
		}
		return modelMap;
	}

	/**
	 * 返回数据子项集合.
	 * 
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/sub", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap getSubItem(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		String itemId = ServletRequestUtils.getStringParameter(request, "itemId", null);
		if (itemId == null || itemId.isEmpty()) {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, new ArrayList<Map<String, Object>>());
		} else {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemProvider.getSubItemMap(itemId));
		}
		return modelMap;
	}

	/**
	 * 返回所有权限数据项信息.
	 * 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/permission", method = RequestMethod.GET)
	@ResponseBody
	public ModelMap getPermissionItems(ModelMap modelMap) throws JEDAException {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemService.findPermissionItems());
		return modelMap;
	}

}

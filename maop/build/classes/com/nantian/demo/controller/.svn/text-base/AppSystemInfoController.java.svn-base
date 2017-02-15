//Controller
//.java
/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.demo.controller;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
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

import com.nantian.demo.vo.AppSystemInfoVo;
import com.nantian.demo.service.AppSystemInfoService;

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
@RequestMapping("/" + Constants.APP_PATH + "/appsysteminfo")
public class AppSystemInfoController {

	/** 日志输出 */
	final Logger logger = LoggerFactory
			.getLogger(AppSystemInfoController.class);

	/** 领域对象名称 */
	private static final String domain = "AppSystemInfo";

	/** 视图前缀 */
	private static final String viewPrefix = "demo/" + domain + "/" + domain;

	/** 服务 */
	@Autowired
	private AppSystemInfoService appsysteminfoService;

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
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request,
				appsysteminfoService.fields);
		try {
			List<Map<String, String>> temp_appSystemsList = new ArrayList<Map<String, String>>();
			List<Map<String, String>> appSystemsList = new ArrayList<Map<String, String>>();
			Map<String, String> appsystemmap = null;

			temp_appSystemsList = (List<Map<String, String>>) appsysteminfoService
					.findAdminname(start, limit, sort, dir, params);
			for (Map<String, String> temp_map : temp_appSystemsList) {
				appsystemmap = new HashMap<String, String>();
				appsystemmap.put("appsystemid", temp_map.get("APPSYSTEMID"));
				appsystemmap
						.put("appsystemname", temp_map.get("APPSYSTEMNAME"));
				appsystemmap.put("issysflag", temp_map.get("ISSYSFLAG"));
				appsystemmap
						.put("appsystemtype", temp_map.get("APPSYSTEMTYPE"));
				appsystemmap
						.put("appsystemtime", temp_map.get("APPSYSTEMTIME"));
				appsystemmap.put("meno", temp_map.get("MENO"));
				appsystemmap.put("appadminidA", temp_map.get("APPADMINIDA"));
				appsystemmap.put("sysadminidA", temp_map.get("SYSADMINIDA"));
				appsystemmap.put("appadminidB", temp_map.get("APPADMINIDB"));
				appsystemmap.put("sysadminidB", temp_map.get("SYSADMINIDB"));
				appsystemmap.put("bmanagerid", temp_map.get("BMANAGERID"));
				appsystemmap.put("cmanagerid", temp_map.get("CMANAGERID"));
				appsystemmap.put("busicontact1id",
						temp_map.get("BUSICONTACT1ID"));
				appsystemmap.put("busicontact2id",
						temp_map.get("BUSICONTACT2ID"));
				appSystemsList.add(appsystemmap);
			}

			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					appSystemsList);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,
					appsysteminfoService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.list", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			// logger.error(messages.getMessage("log.error.list", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain) }));
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
	public String excel(HttpServletRequest request, ModelMap modelMap)
			throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request,
				appsysteminfoService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();

		// 需要根据现实情况修改
		columns.put("name", messages.getMessage("resource.name"));

		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY,
				columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
				appsysteminfoService.find(0, Constants.DEFAULT_EXCEL_ROW_LIMIT,
						Constants.DEFAULT_SORT_FIELD,
						Constants.DEFAULT_SORT_DIRECTION, params));
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
	 * @param customer
	 *            数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute AppSystemInfoVo appsysteminfo)
			throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			// securityUtils.setCreateEntity(appsysteminfo);// 设置新建数据的操作用户及时间信息
			appsysteminfoService.save(appsysteminfo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("appsystemid", appsysteminfo.getAppsystemid());
			// logger.info(messages.getMessage("log.info.create", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// appsysteminfo.getAppsystemid() }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION
					+ "[" + messages.getMessage("resource.error.duplicate.id")
					+ "]");
			// logger.error(messages.getMessage("log.error.create", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain)
			// }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.create", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain)
			// }));
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
	@RequestMapping(value = "/edit/{appsystemid}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@PathVariable("appsystemid") java.lang.String appsystemid,
			HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			AppSystemInfoVo appsysteminfo = (AppSystemInfoVo) appsysteminfoService
					.get(appsystemid);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(
					appsysteminfo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(
					dateFormat, true));
			binder.bind(request);
			// securityUtils.setModifyEntity(appsysteminfo);// 设置修改数据的操作用户及时间信息
			appsysteminfoService.update(appsysteminfo);
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// appsystemid }));
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			// logger.error(messages.getMessage("log.error.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// appsystemid }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// appsystemid }));
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
	 * @param id
	 *            主键
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view/{appsystemid}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap view(@PathVariable("appsystemid") String appsystemid,
			ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",
					appsysteminfoService.findById(appsystemid));
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
	 * @param ids
	 *            主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "appsystemids", required = true) String[] appsystemids,
			ModelMap modelMap) throws JEDAException {
		try {
			appsysteminfoService.deleteByIds(appsystemids);
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.delete", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// StringUtils.arrayToDelimitedString((Object[]) appsystemids, "|")
			// }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
			// logger.error(messages.getMessage("log.error.delete", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain),
			// StringUtils.arrayToDelimitedString((Object[]) appsystemids, "|")
			// }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.delete", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain),
			// StringUtils.arrayToDelimitedString((Object[]) appsystemids, "|")
			// }));
		}
		return modelMap;
	}

}
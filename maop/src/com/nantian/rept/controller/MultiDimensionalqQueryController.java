package com.nantian.rept.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/multidimensionalqquery")
public class MultiDimensionalqQueryController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(MultiDimensionalqQueryController.class);
	
	/** 领域对象名称 */
	private static final String domain = "MultiDimensionalqQuery";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
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
	 * 返回应用配置管理页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询应用系统及管理员分配信息列表
	 * @param start 起始记录数	 * @param limit 限制记录数	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param sysId 系统编号
	 * @param sysName 系统名称
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
			@RequestParam(value = "sysId", required = false) String sysId,
			@RequestParam(value = "sysName", required = false) String sysName,
			@RequestParam(value = "appA", required = false) String appA,
			@RequestParam(value = "appB", required = false) String appB,
			@RequestParam(value = "sysA", required = false) String sysA,
			@RequestParam(value = "sysB", required = false) String sysB,
			@RequestParam(value = "sysStatus", required = false) String sysStatus,
			@RequestParam(value = "disasterRecoverPriority", required = false) String disasterRecoverPriority,
			@RequestParam(value = "groupName", required = false) String groupName,
			@RequestParam(value = "coreRank", required = false) String coreRank,
			@RequestParam(value = "importantRank", required = false) String importantRank,
			@RequestParam(value = "hingeRank", required = false) String hingeRank,
			@RequestParam(value = "outSourcingFlag", required = false) String outSourcingFlag,
			@RequestParam(value = "appType", required = false) String appType,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
//		Map<String, Object> params = RequestUtil.getQueryMap(request, appConfigManageService.fields);
		try{
			modelMap.addAttribute("success", Boolean.TRUE);
//			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appConfigManageService.queryAppSystemInfo(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, ((List<Map<String, String>>)request.getSession().getAttribute("appSystemInfos4Export")).size());
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	
}///:~

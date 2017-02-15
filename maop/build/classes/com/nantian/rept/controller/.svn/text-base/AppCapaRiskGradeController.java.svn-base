package com.nantian.rept.controller;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

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
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.AppConfigManageService1;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/appcapariskgrade")
public class AppCapaRiskGradeController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppCapaRiskGradeController.class);
	
	/** 领域对象名称 */
	private static final String domain = "AppCapaRiskGrade";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private AppConfigManageService1 appConfigManageService;
	
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
	 * @param appA 应用管理员A角	 * @param appB 应用管理员B角	 * @param sysA 系统管理员A角	 * @param sysB 系统管理员B角	 * @param sysStatus 系统状态	 * @param disasterRecoverPriority 灾备优先级	 * @param groupName 组别
	 * @param coreRank 核心级别
	 * @param importantRank 重要级别
	 * @param hingeRank 关键级别
	 * @param outSourcingFlag 外包标识
	 * @param appType 系统类型
	 * @param request 请求对象
	 * @param modelMap 响应对象
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
		Map<String, Object> params = RequestUtil.getQueryMap(request, appConfigManageService.fields);
		try{
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appConfigManageService.queryAppSystemInfo(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, ((List<Map<String, String>>)request.getSession().getAttribute("appSystemInfos4Export")).size());
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 查询应用系统所有编号	 * @param response
	 */
	@RequestMapping(value = "/querySystemIDAndNames", method = RequestMethod.GET)
	public @ResponseBody void querySystemIDAndNames(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIDs = appConfigManageService.querySystemIDAndNames();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIDs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询所有系统的系统管理员A角	 * @param response
	 */
	@RequestMapping(value = "/querySystemAdminAs", method = RequestMethod.GET)
	public @ResponseBody void querySystemAdminAs(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysAs = appConfigManageService.querySystemAdminAs();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysAs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询所有系统的系统管理员B角	 * @param response
	 */
	@RequestMapping(value = "/querySystemAdminBs", method = RequestMethod.GET)
	public @ResponseBody void querySystemAdminBs(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysBs = appConfigManageService.querySystemAdminBs();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysBs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询所有系统的应用管理员A角及对应的组别	 * @param response
	 */
	@RequestMapping(value = "/queryAppAdminAs", method = RequestMethod.GET)
	public @ResponseBody void queryAppAdminAs(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object appAs = appConfigManageService.queryAppAdminAs();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(appAs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询所有系统的应用管理员B角	 * @param response
	 */
	@RequestMapping(value = "/queryAppAdminBs", method = RequestMethod.GET)
	public @ResponseBody void queryAppAdminBs(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object appBs = appConfigManageService.queryAppAdminBs();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(appBs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 导出查询结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("sysId", messages.getMessage("property.appsyscd"));
		columns.put("sysName", messages.getMessage("property.appsystemname"));
		columns.put("operationsManager", messages.getMessage("property.operationsManager"));
		columns.put("sysA", messages.getMessage("property.sysadminidA"));
		columns.put("sysB", messages.getMessage("property.sysadminidB"));
		columns.put("appA", messages.getMessage("property.appadminidA"));
		columns.put("appB", messages.getMessage("property.appadminidB"));
		columns.put("projectLeader", messages.getMessage("property.projectLeader"));
		columns.put("sysStatus", messages.getMessage("property.systemStatus"));
		columns.put("department", messages.getMessage("property.department"));
		columns.put("serviceTime", messages.getMessage("property.serviceTime"));
		columns.put("disasterRecoverPriority", messages.getMessage("property.disasterRecoverPriority"));
		columns.put("securityRank", messages.getMessage("property.securityRank"));
		columns.put("groupName", messages.getMessage("property.groupName"));
		columns.put("takeOverFlag", messages.getMessage("property.isTakeOver"));
		columns.put("coreRank", messages.getMessage("property.isCoreSystem"));
		columns.put("importantRank", messages.getMessage("property.isImportantSystem"));
		columns.put("hingeRank", messages.getMessage("property.isHingeSystem"));
		columns.put("outSourcingFlag", messages.getMessage("property.isOutSourcing"));
		columns.put("appType", messages.getMessage("property.appType"));
		columns.put("evaluateMonth", messages.getMessage("property.evaluateMonth"));
		columns.put("evaluateResult", messages.getMessage("property.evaluateResult"));
		columns.put("levelCauseDesc", messages.getMessage("property.levelCauseDesc"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, request.getSession().getAttribute("appSystemInfos4Export"));
		return "excelView";
	}
}

package com.nantian.dply.controller;

import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.jdom2.JDOMException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
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
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.dply.service.AppChangeService;
import com.nantian.dply.service.DplyRequestInfoService;
import com.nantian.dply.vo.AppChangeRiskEvalVo;
import com.nantian.dply.vo.AppChangeSummaryVo;
import com.nantian.dply.vo.AppChangeVo;
import com.nantian.dply.vo.DplyRequestInfoVo;
import com.nantian.dply.vo.MonitorWarnVo;

/**
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH +  "/appchangemanage")
public class AppChangeController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppChangeController.class);
	
	/** 领域对象名称 */
	private static final String domain = "AppChangeManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain;
	
	@Autowired
	private AppChangeService appChangeService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private DplyRequestInfoService dplyRequestInfoService;
	
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
	 * 返回应用变更页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param planStartDate
	 * @param request
	 * @param modelMap
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
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "changeMonth", required = false) String changeMonth,
			@RequestParam(value = "operation", required = false) String operation,
			@RequestParam(value = "maintainTomo", required = false) String maintainTomo,
			@RequestParam(value = "changeDateStart", required = false) String changeDateStart,
			@RequestParam(value = "changeDateEnd", required = false) String changeDateEnd,
			
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, appChangeService.fields);
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					appChangeService.queryAppChangeList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<Map<String, String>>)request.getSession().getAttribute("appChangeList4Export")).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method  = RequestMethod.GET)
	public String view() throws JEDAException{
		return viewPrefix + "View";
	}
	
	/**
	 * 根据id查询
	 * 
	 * @param appChangeId
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "appChangeId", required = true) Long appChangeId,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appChangeService.queryAppChangeMap(appChangeId));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String create() throws JEDAException{
		return viewPrefix + "Create";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param appChangeInfo 变更信息数据对象
	 * @param appChangeRiskEvalVo 风险评估数据对象
	 * @param appChangeSummaryVo 问题汇总数据对象
	 * @param monitorWarnVo 监控告警数据对象
	 * @return
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(
			@ModelAttribute AppChangeVo appChangeInfo,
			@ModelAttribute AppChangeRiskEvalVo appChangeRiskEvalVo,
			@ModelAttribute AppChangeSummaryVo appChangeSummaryVo,
			@ModelAttribute MonitorWarnVo monitorWarnVo,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		//ModelMap modelMap = new ModelMap();
		String appsys_code=appChangeInfo.getAplCode();
		
		JSONArray jsonRequests = JSONArray.fromObject(appChangeInfo.getRequests_create());				          	   
		List<String> requestslist = (List<String>) JSONArray.toCollection(jsonRequests, String.class);
		List<DplyRequestInfoVo> list =appChangeService.getRequests(appsys_code,requestslist);
		String msg = "";
		try {
		for(DplyRequestInfoVo dplyRequestInfoVo :list){
	
				msg += dplyRequestInfoService.getRequest4Servers(dplyRequestInfoVo);
				msg += dplyRequestInfoService.getAllProperty(dplyRequestInfoVo.getAppSysCode(),dplyRequestInfoVo.getEnvironment());
		}
	
			if(!msg.equals("")){
				String msg2 = "</br>" + msg;
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", msg2 ); 
				return modelMap;
			}else{
				appChangeService.save(appChangeInfo, appChangeRiskEvalVo, appChangeSummaryVo, monitorWarnVo,list);
				
				modelMap.addAttribute("success", Boolean.TRUE);
				modelMap.addAttribute("appChangeId", appChangeInfo.getAppChangeId());
			}
			
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("error.record.exist") + "]");
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
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}
	
	/**
	 * 编辑更新数据
	 * @param aplCode 系统编号
	 * @param planStartDate 变更日期
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/edit/{appChangeId}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@ModelAttribute AppChangeVo appChangeInfo,
			@ModelAttribute AppChangeRiskEvalVo appChangeRiskEvalVo,
			@ModelAttribute AppChangeSummaryVo appChangeSummaryVo,
			@ModelAttribute MonitorWarnVo monitorWarnVo,
			@PathVariable("appChangeId") Long appChangeId,
			HttpServletRequest request,ModelMap modelMap) throws JEDAException {
		modelMap.clear();
		 appChangeInfo.setAppChangeId(appChangeId);
        String appsys_code=appChangeInfo.getAplCode();
		JSONArray jsonRequests = JSONArray.fromObject(appChangeInfo.getRequests_create());				          	   
		List<String> requestslist = (List<String>) JSONArray.toCollection(jsonRequests, String.class);
		List<DplyRequestInfoVo> list =appChangeService.getRequests(appsys_code,requestslist);
		String msg = "";
		try {
			for(DplyRequestInfoVo dplyRequestInfoVo :list){
				
				msg += dplyRequestInfoService.getRequest4Servers(dplyRequestInfoVo);
				msg += dplyRequestInfoService.getAllProperty(dplyRequestInfoVo.getAppSysCode(),dplyRequestInfoVo.getEnvironment());
		}
	
			if(!msg.equals("")){
				String msg2 = "</br>" + msg;
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", msg2 ); 
				return modelMap;
			}else{
				AppChangeVo appChange = appChangeService.get(appChangeId);
				appChangeService.saveOrUpdate(appChange, appChangeRiskEvalVo, appChangeSummaryVo, monitorWarnVo, request,list);
				
			}
			
		    modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
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
	 * 返回变更投产进度情况页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/progress", method = RequestMethod.GET)
	public String progress() throws JEDAException {
		return viewPrefix + "Progress";
	}
	
	/**
	 * 查询变更进度情况汇总
	 * @param changeMonth
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/progress", method = RequestMethod.POST)
	public @ResponseBody ModelMap progress(
			@RequestParam(value = "changeMonth", required = false) String changeMonth,
			ModelMap modelMap) throws JEDAException{
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					appChangeService.queryAppChangeProgress(changeMonth));
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回变更投产进度情况详细页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/progressDetail", method = RequestMethod.GET)
	public String progressDetail() throws JEDAException {
		return viewPrefix + "ProgressDetail";
	}
	
	/**
	 * 查询变更进度情况详细
	 * @param changeMonth
	 * @param aplCodes
	 * @param status
	 * @param progress
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/progressDetail", method = RequestMethod.POST)
	public @ResponseBody ModelMap progressDetail(
			@RequestParam(value = "changeMonth", required = false) String changeMonth,
			@RequestParam(value = "aplCodes", required = false) String aplCodes,
			@RequestParam(value = "status", required = false) String status,
			@RequestParam(value = "progress", required = false) String progress,
			ModelMap modelMap) throws JEDAException{
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					appChangeService.queryAppChangeProgressDetail(changeMonth, aplCodes, status, progress));
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 批量删除变更信息
	 * @param appChangeIds 主键数组
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody ModelMap delete(
			@RequestParam(value = "appChangeIds", required = true) Long[] appChangeIds,
			ModelMap modelMap) throws JEDAException{
		try {
			appChangeService.deleteByIds(appChangeIds);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataIntegrityViolationException e) {
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
	 * 根据系统编号查询最近一次的数据
	 * @param aplCode
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/loadLatest", method = RequestMethod.POST)
	public @ResponseBody ModelMap loadLatest(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appChangeService.queryLastestAppChangeInfo(aplCode));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 查询所有应用系统编号简称	 * @param response
	 */
	@RequestMapping(value = "/queryAplCodes", method = RequestMethod.GET)
	public @ResponseBody void queryAplCodes(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIds = appChangeService.queryAplCodes();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIds));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询某月份的所有应用系统编号简称	 * @param response
	 */
	@RequestMapping(value = "/queryAplCodes4ChangeMonth", method = RequestMethod.GET)
	public @ResponseBody void queryAplCodes4ChangeMonth(
			@RequestParam(value = "changeMonth", required = true) String changeMonth,
			HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIds = appChangeService.queryAplCodes4ChangeMonth(changeMonth);
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIds));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 导出查询结果
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		Map<String, String> appChangeColumns = new LinkedHashMap<String, String>();
		appChangeColumns.put("sequence", messages.getMessage("property.cellSequence"));
		appChangeColumns.put("sysName", messages.getMessage("property.appsystemname"));
		appChangeColumns.put("eapsCode", messages.getMessage("property.changeCode"));
		appChangeColumns.put("changeName", messages.getMessage("property.changeName"));
		appChangeColumns.put("dplyLocation", messages.getMessage("property.dplyLocation"));
		appChangeColumns.put("planStartDate", messages.getMessage("property.planStartDate"));
		appChangeColumns.put("planStartTime", messages.getMessage("property.planStartTime"));
		appChangeColumns.put("actualStartTime", messages.getMessage("property.actualStartTime"));
		appChangeColumns.put("planEndDate", messages.getMessage("property.planEndDate"));
		appChangeColumns.put("planEndTime", messages.getMessage("property.planEndTime"));
		appChangeColumns.put("actualEndDate", messages.getMessage("property.actualEndDate"));
		appChangeColumns.put("actualEndTime", messages.getMessage("property.actualEndTime"));
		appChangeColumns.put("endFlagDisplay", messages.getMessage("property.endFlag"));
		appChangeColumns.put("changeGrantNo", messages.getMessage("property.changeGrantNo"));
		appChangeColumns.put("appA", messages.getMessage("property.appadminidA"));
		appChangeColumns.put("develop", messages.getMessage("property.projectChangeLeader"));
		appChangeColumns.put("primaryChangeRiskLink", messages.getMessage("property.primaryChangeRisk"));
		appChangeColumns.put("changeTypeDisplay", messages.getMessage("property.changeType"));
		appChangeColumns.put("changeTableDisplay", messages.getMessage("property.changeTable"));
		appChangeColumns.put("lastRebootDate", messages.getMessage("property.lastRebootDate"));
		appChangeColumns.put("nowRebootTime", messages.getMessage("property.nowRebootTime"));
		appChangeColumns.put("rebootExecInfo", messages.getMessage("property.rebootExecInfo"));
		appChangeColumns.put("verifyInfo", messages.getMessage("property.verifyInfo"));
		appChangeColumns.put("operationId", messages.getMessage("property.operationId"));
		appChangeColumns.put("operation", messages.getMessage("property.operation"));
		appChangeColumns.put("operationTel", messages.getMessage("property.operationTel"));
		appChangeColumns.put("maintainTomo", messages.getMessage("property.maintainTomo"));
		appChangeColumns.put("reviewerId", messages.getMessage("property.reviewerId"));
		appChangeColumns.put("reviewer", messages.getMessage("property.reviewer"));
		appChangeColumns.put("reviewerTel", messages.getMessage("property.reviewerTel"));
		
		modelMap.addAttribute("appChangeColumns", appChangeColumns);
		modelMap.addAttribute("appChangeData", request.getSession().getAttribute("appChangeList4Export"));
		
		return "ExcelViewManageChange";
	}
	
	/**
	 * 根据日期，应用系统获请求列表
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/arrange_request", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap arrange_request(@RequestParam("appsysCode") String appsysCode,
			@RequestParam("changeDate") String changeDate,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			
			modelMap.addAttribute("data",appChangeService.queryRequestByAppCode(appsysCode, changeDate));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 
	 * @param appsysCode
	 * @param modelMap
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/hide", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap hide(@RequestParam(value = "appsysCode", required = true) String appsysCode,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			String loginUser =securityUtils.getUser().getUsername();
			modelMap.addAttribute("data",appChangeService.hide(appsysCode,loginUser));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
}

package com.nantian.dply.controller;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.dply.service.AppChangeRiskEvalService;
import com.nantian.dply.service.AppChangeService;
import com.nantian.dply.service.AppChangeSummaryService;
import com.nantian.dply.service.MonitorWarnService;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/appchangetemplate")
public class AppChangeTemplateController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppChangeTemplateController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "AppChangeTemplate";
	
	/** 模板管理视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain;
	
	@Autowired
	private AppChangeService appChangeService;
	
	@Autowired
	private AppChangeRiskEvalService appChangeRiskEvalService;
	
	@Autowired
	private AppChangeSummaryService appChangeSummaryService;
	
	@Autowired
	private MonitorWarnService monitorWarnService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/**
	 * 返回变更控制表下载页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 导出与变更相关的表数据
	 * @param changeMonitor 变更月份
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String download(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		String changeMonth = "";
		String aplCodes = "";
		try {
			changeMonth = ServletRequestUtils.getStringParameter(request, "changeMonth");
			aplCodes = ServletRequestUtils.getStringParameter(request, "aplCodes");
		} catch (ServletRequestBindingException e) {
			e.printStackTrace();
		}
		
		List<String> aplCodeList = Arrays.asList(aplCodes.split(","));
		
		modelMap.addAttribute("month", changeMonth);
		
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
		appChangeColumns.put("endFlag", messages.getMessage("property.endFlag"));
		appChangeColumns.put("changeGrantNo", messages.getMessage("property.changeGrantNo"));
		appChangeColumns.put("appA", messages.getMessage("property.appadminidA"));
		appChangeColumns.put("develop", messages.getMessage("property.projectChangeLeader"));
		appChangeColumns.put("primaryChangeRiskLink", messages.getMessage("property.primaryChangeRisk"));
		appChangeColumns.put("changeType", messages.getMessage("property.changeType"));
		appChangeColumns.put("changeTable", messages.getMessage("property.changeTable"));
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
		modelMap.addAttribute("appChangeData", appChangeService.queryAppChangeList(changeMonth, aplCodeList));
		
		Map<String, String> riskEvalColumns = new LinkedHashMap<String, String>();
		riskEvalColumns.put("sequence", messages.getMessage("property.cellSequence"));
		riskEvalColumns.put("sysName", messages.getMessage("property.appsystemname"));
		riskEvalColumns.put("eapsCode", messages.getMessage("property.eapsCode"));
		riskEvalColumns.put("changeName", messages.getMessage("property.changeName"));
		riskEvalColumns.put("appA", messages.getMessage("property.appadminidA"));
		riskEvalColumns.put("changeRiskEval", messages.getMessage("property.changeRiskEval"));
		riskEvalColumns.put("stopServiceTime", messages.getMessage("property.stopServiceTime"));
		riskEvalColumns.put("primaryChangeRisk", messages.getMessage("property.primaryChangeRisk"));
		riskEvalColumns.put("riskHandleMethod", messages.getMessage("property.riskHandleMethod"));
		riskEvalColumns.put("other", messages.getMessage("property.other"));
		
		modelMap.addAttribute("riskEvalColumns", riskEvalColumns);
		modelMap.addAttribute("riskEvalData", appChangeRiskEvalService.queryAppChangeRiskEvalList(changeMonth, aplCodeList));
		
		Map<String, String> summaryColumns = new LinkedHashMap<String, String>();
		summaryColumns.put("sequence", messages.getMessage("property.cellSequence"));
		summaryColumns.put("sysName", messages.getMessage("property.appsystemname"));
		summaryColumns.put("time", messages.getMessage("property.time"));
		summaryColumns.put("type", messages.getMessage("property.type"));
		summaryColumns.put("phenomenon", messages.getMessage("property.phenomenon"));
		summaryColumns.put("cause", messages.getMessage("property.cause"));
		summaryColumns.put("handleMethod", messages.getMessage("property.handleMethod"));
		summaryColumns.put("improveMethod", messages.getMessage("property.improveMethod"));
		
		modelMap.addAttribute("summaryColumns", summaryColumns);
		modelMap.addAttribute("summaryData", appChangeSummaryService.queryAppChangeSummaryList(changeMonth, aplCodeList));
		
		Map<String, String> monitorWarnColumns = new LinkedHashMap<String, String>();
		monitorWarnColumns.put("sequence", messages.getMessage("property.cellSequence"));
		monitorWarnColumns.put("monitorEffectContent", messages.getMessage("property.monitorEffectContent"));
		monitorWarnColumns.put("sysName", messages.getMessage("property.appsystemname"));
		monitorWarnColumns.put("deviceName", messages.getMessage("property.deviceName"));
		monitorWarnColumns.put("ipAddress", messages.getMessage("property.ipAddress"));
		monitorWarnColumns.put("explainDevice", messages.getMessage("property.explainDevice"));
		monitorWarnColumns.put("explainMonitorPlatform", messages.getMessage("property.explainMonitorPlatform"));
		monitorWarnColumns.put("explainMonitorToolDisplay", messages.getMessage("property.explainMonitorTool"));
		monitorWarnColumns.put("explainMonitorScreenDisplay", messages.getMessage("property.explainMonitorScreen"));
		monitorWarnColumns.put("effectStartDate", messages.getMessage("property.effectStartDate"));
		monitorWarnColumns.put("effectStartTime", messages.getMessage("property.effectStartTime"));
		monitorWarnColumns.put("effectEndDate", messages.getMessage("property.effectEndDate"));
		monitorWarnColumns.put("effectEndTime", messages.getMessage("property.effectEndTime"));
		
		modelMap.addAttribute("monitorWarnColumns", monitorWarnColumns);
		modelMap.addAttribute("monitorWarnData", monitorWarnService.queryMonitorWarnList(changeMonth, aplCodeList));
		
		//监控告警UMP
		Map<String, String> umpMonitorWarnColumns = new LinkedHashMap<String, String>();
		umpMonitorWarnColumns.put("sequence", messages.getMessage("property.cellSequence"));
		umpMonitorWarnColumns.put("monitorStartTime", messages.getMessage("property.monitorStartTime"));
		umpMonitorWarnColumns.put("monitorEndTime", messages.getMessage("property.monitorEndTime"));
		umpMonitorWarnColumns.put("ipAddress", messages.getMessage("property.ipAddress"));
		umpMonitorWarnColumns.put("sysName", messages.getMessage("property.appsystemname"));
		umpMonitorWarnColumns.put("monitorCreator", messages.getMessage("property.monitorCreator"));
		umpMonitorWarnColumns.put("eapsCode", messages.getMessage("property.changeCode"));
		
		modelMap.addAttribute("umpMonitorWarnColumns", umpMonitorWarnColumns);
		modelMap.addAttribute("umpMonitorWarnData", monitorWarnService.queryMonitorWarnListForUmp(changeMonth, aplCodeList));
		
		//变更日历
		Map<String, String> changeCalendarColumns = new LinkedHashMap<String, String>();
		changeCalendarColumns.put("changeName", messages.getMessage("property.subject"));
		changeCalendarColumns.put("sysName", messages.getMessage("property.effectAppsystemname"));
		changeCalendarColumns.put("riskGrade", messages.getMessage("property.riskGrade"));
		changeCalendarColumns.put("changeType", messages.getMessage("property.changeClass"));
		changeCalendarColumns.put("eapsCode", messages.getMessage("property.changeCode2"));
		changeCalendarColumns.put("reviewGrade", messages.getMessage("property.reviewGrade"));
		changeCalendarColumns.put("planStartTime", messages.getMessage("property.planStartTime"));
		changeCalendarColumns.put("planEndTime", messages.getMessage("property.planEndTime"));
		changeCalendarColumns.put("planDescription", messages.getMessage("property.planDescription"));
		changeCalendarColumns.put("operationOrReviewer", messages.getMessage("property.operationOrReviewer"));
		changeCalendarColumns.put("userId", messages.getMessage("property.userNumber"));
		changeCalendarColumns.put("userTel", messages.getMessage("property.userTel"));
		
		modelMap.addAttribute("changeCalendarColumns", changeCalendarColumns);
		modelMap.addAttribute("changeCalendarData", appChangeService.queryAppChangeListForChangeCalendar(changeMonth, aplCodeList));
		
		return "ExcelViewManageChange";
	}
}

package com.nantian.check.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.CheckReportService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.AplAnalyzeService;
import com.nantian.rept.vo.AplAnalyzeVo;

/**
 * 巡检报告controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/checkreport")
public class CheckReportController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckReportController.class);
	/** 领域对象名称 */
	private static final String domain = "checkreport";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private AplAnalyzeService aplAnalyzeService;
	@Autowired
	private SecurityUtils securityUtils; 
	@Autowired
	private CheckReportService checkReportService;

	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index";
	}
	
	/**
	 * 返回报告分析页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/analyse", method = RequestMethod.GET)
	public String analyse() throws JEDAException {
		return viewPrefix + "analyse";
	}
	
	/**
	 * 根据主键查询应用系统分析科目数据
	 * @param aplCode
	 * @param transDate
	 * @param anaItem
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/showAnalyseData", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap showAnalyseData(@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "transDate", required = true) String transDate,
			@RequestParam(value = "transTime", required = true) String transTime,
			@RequestParam(value = "anaItem", required = true) String anaItem,
			ModelMap modelMap)
			throws JEDAException {
		AplAnalyzeVo aplAnalyze = aplAnalyzeService.findByPrimaryKey(aplCode,transDate,transTime,anaItem);
		modelMap.addAttribute("status", aplAnalyze.getStatus());
		modelMap.addAttribute("exeAnaDesc", aplAnalyze.getExeAnaDesc());
		modelMap.addAttribute("handleState", aplAnalyze.getHandleState());
		return modelMap;
	}
	
	/**
	 * 保存应用系统科目分析数据
	 * @param aplCode
	 * @param transDate
	 * @param anaItem
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/saveAnalyseData", method = RequestMethod.POST)
	public @ResponseBody
	void saveAnalyseData(@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "transDate", required = true) String transDate,
			@RequestParam(value = "transTime", required = true) String transTime,
			@RequestParam(value = "anaItem", required = true) String anaItem,
			@RequestParam(value = "status", required = true) String status,
			@RequestParam(value = "exeAnaDesc", required = true) String exeAnaDesc,
			@RequestParam(value = "handleState", required = true) String handleState)
			throws JEDAException {
		AplAnalyzeVo aplAnalyze = new AplAnalyzeVo();
		aplAnalyze.setAplCode(aplCode);
		aplAnalyze.setTransDate(transDate);
		aplAnalyze.setTransTime(transTime);
		aplAnalyze.setAnaItem(anaItem);
		if(handleState.length()>1){
			aplAnalyze.setHandleState("0");
		}else{
			aplAnalyze.setHandleState(handleState);
		}
		aplAnalyze.setStatus(status);
		aplAnalyze.setExeAnaDesc(exeAnaDesc);
		aplAnalyze.setAnaUser(securityUtils.getUser().getUsername()); //用户账号
		aplAnalyzeService.saveOrUpdate(aplAnalyze);
	}
	
	/**
	 * 分页获取巡检查询主页面数据
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/checkQueryList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCheckQueryList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "unhandle_state", required = false) String unhandle_state, 
			HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, checkReportService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, checkReportService.getReportSumList(start, limit, sort, dir, params,unhandle_state));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, checkReportService.countReportSumList(params,unhandle_state));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/count", method = RequestMethod.GET)
	public String count(){ 
		return viewPrefix + "count";
	}
	
	/**
	 * 分页获取巡检统计数据
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/checkCountList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCheckCountList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, 
		
			HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, checkReportService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, checkReportService.getReportCountList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, checkReportService.countReportCountList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 */
	@RequestMapping(value = "/detail", method = RequestMethod.GET)
	public String editJob() {
		return viewPrefix + "detail";
	}
	
	/**
	 * 分页获取巡检统计明细数据
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getCountDetailList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCountDetailList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "transDate", required = true) String transDate,
			@RequestParam(value = "transTime", required = true) String transTime , ModelMap modelMap)
			throws AxisFault, Exception{
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, checkReportService.getCountDetailList(start,limit,aplCode,transDate,transTime));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, checkReportService.countCountDetailList(aplCode,transDate,transTime));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
}

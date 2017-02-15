package com.nantian.dply.controller;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.CommonConst;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.dply.service.DetailStepsService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;

/**
 * 进度展示
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH + "/monitor")
public class MonitorController {
	/** 监控领域对象名称 */
	private static final String domain = "schedule";
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain+ "_";
	@Autowired
	private DetailStepsService detailStepsService;

	/**
	 * 返回任务调度视图
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "index";
	}

	/**
	 * 根据执行状态查询系统队列的系统信息
	 * 
	 * @param executeStatus
	 *            执行状态: 1:创建、2：计划、3：开始、4：问题、5：保留、6：取消、7：完成、8：删除
	 * 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/findReadySysByReqStatus", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap ReadySystem(
			@RequestParam(value = "reqStatus", required = true) String reqStatus,
			ModelMap modelMap) throws BrpmInvocationException,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data",detailStepsService.findReadySysByReqStatus(reqStatus));
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}

	/**
	 * 根据执行状态查询已经成功的系统信息
	 * 
	 * @param executeStatus
	 *            执行状态: 1:创建、2：计划、3：开始、4：问题、5：保留、6：取消、7：完成、8：删除
	 * 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/findSuccessSysByExecStatus", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap SuccessSystem(
			@RequestParam(value = "reqStatus", required = false) String reqStatus,
			ModelMap modelMap, HttpServletRequest request) throws BrpmInvocationException,DataIntegrityViolationException,Exception  {
			modelMap.clear();	
			modelMap.addAttribute("data",detailStepsService.findSuccessSysByExecStatus(reqStatus, request));
			modelMap.addAttribute("requestFinishNums", request.getSession().getAttribute("requestFinishNums"));
			modelMap.addAttribute("requestWhole", request.getSession().getAttribute("requestWhole"));
			modelMap.addAttribute("stepWhole", request.getSession().getAttribute("stepWhole"));
			modelMap.addAttribute("stepFinishNums", request.getSession().getAttribute("stepFinishNums"));
			modelMap.addAttribute("sysFinishNums", request.getSession().getAttribute("sysFinishNums"));
			modelMap.addAttribute("sysWhole", request.getSession().getAttribute("sysWhole"));
			modelMap.addAttribute("runAppnum", request.getSession().getAttribute("runAppnum"));
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}



	/**
	 * 根据执行状态查询正在执行的系统信息
	 * 
	 * @param executeStatus
	 *            执行状态: 1:创建、2：计划、3：开始、4：问题、5：保留、6：取消、7：完成、8：删除
	 * 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/findExeSysByExecStatus", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap ExecutSystem(
			@RequestParam(value = "reqStatus", required = true) String reqStatus,
			ModelMap modelMap) throws BrpmInvocationException,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data",detailStepsService.findExeSysByExecStatus(reqStatus));
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
		
	}

/**
	 * 根据执行状态查询已经失败的系统信息
	 * 
	 * @param executeStatus
	 *            执行状态: 1:创建、2：计划、3：开始、4：问题、5：保留、6：取消、7：完成、8：删除

	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/findfailedSysByExecStatus", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap FailedSystem(
			@RequestParam(value = "reqStatus", required = true) String reqStatus,
			ModelMap modelMap) throws BrpmInvocationException,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data",detailStepsService.findfailedSysByExecStatus(reqStatus));
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	
	/**
	 * 返回任务调度视图
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/stepIndex", method = RequestMethod.GET)
	public String stepIndex() throws JEDAException {
		return viewPrefix + "step_index";
	}

	/**
	 * 根据执行状态查询已经失败的系统信息
	 * 
	 * @param executeStatus
	 *            执行状态: 1:创建、2：计划、3：开始、4：问题、5：保留、6：取消、7：完成、8：删除


	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/stepMonitor", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap stepMonitor(
			@RequestParam(value = "reqStatus", required = false) String reqStatus,
			ModelMap modelMap, HttpServletRequest request) throws BrpmInvocationException,DataIntegrityViolationException,Exception  {
	/*	StringBuilder xAxisDataOptions = new StringBuilder();
		xAxisDataOptions.append("{")
		.append("\"xAxisDataOptions\":").append(CommonConst.BRACKET_LEFT)
		.append("\"").append("NBANK").append("\"").append(CommonConst.BRACKET_RIGHT)
		.append("}");*/
		
			modelMap.clear();
			modelMap.addAttribute("data", detailStepsService.queryStep());
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
}

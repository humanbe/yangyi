package com.nantian.dply.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.system.controller.AppInfoController;
import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.ExcelCreateRequestService;
import com.nantian.dply.service.MoveBrpmExportService;
import com.nantian.dply.vo.RequestsVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.dply.vo.StepsVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * @author <a href="mailto:liruihao@nantian.com.cn"></a>
 * 应用发布通过excel创建请求
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/excelcreaterequest")
public class ExcelCreateRequestController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(ExcelCreateRequestController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "excel_create_request";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/excel/" + domain;
	
	@Autowired
	private ExcelCreateRequestService excelCreateRequestService;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	/**
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String info() throws JEDAException {
		return viewPrefix;
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view(
			@RequestParam(value = "requestsId", required = false) Integer requestsId
			) throws JEDAException {
		return viewPrefix + "_view";
	}
	
	/**
	 * 根据分页、排序和其他条件查询编码信息记录
	 * 
	 * @param start        起始索引
	 * @param limit        每页至多显示的记录数
	 * @param sort         排序的字段
	 * @param dir          排序的方式
	 * @param appsysCode   应用系统编号
	 * @param execStartTime   实际开始时间
	 * @param execCompletedTime 实际结束时间
	 * @param logType      日志类型
	 * @param logResourceType 日志来源类型
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,//'id','name','app','environment','brpmRequestId','createdAt','updatedAt','stepNum','stepFinishNum','requestStatus'
			@RequestParam(value = "name", required = false) String name,
			@RequestParam(value = "app", required = false) String app,
			@RequestParam(value = "environment", required = false) String environment,
			@RequestParam(value = "requestStatus", required = false) String requestStatus,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		    modelMap=new ModelMap();
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,excelCreateRequestService.queryExcelCreateRequestService(start,limit,sort,dir,name,app,environment,requestStatus));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,excelCreateRequestService.countExcelCreateRequestService(name,app,environment,requestStatus));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	/**
	 * 查询用户关联应用系统列表
	 * @param response
	 */
	@RequestMapping(value = "/querySystemIDAndNamesByUser", method = RequestMethod.GET)
	public @ResponseBody void querySystemIDAndNamesByUser(HttpServletResponse response){
		PrintWriter out = null;
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		
		try {
			Object sysIDs = excelCreateRequestService.querySystemIDAndNamesByUser(securityUtils.getUser().getUsername());
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIDs));
		} catch (Exception e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0999")) {
				logger.log("Component0999", ComUtil.getCurrentMethodName());
				}
		}finally{
			if(out != null){
				out.close();
			}
		}
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
			}
	}
	
	/**
	 * 查询用户关联应用系统列表
	 * @param response
	 */
	@RequestMapping(value = "/queryEnv", method = RequestMethod.GET)
	public @ResponseBody void queryEnv(@RequestParam(value = "appsysCode", required = false) String appsysCode,HttpServletResponse response){
		PrintWriter out = null;
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		try {
			Object queryEnv = excelCreateRequestService.queryEnv(securityUtils.getUser().getUsername());
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(queryEnv));
		} catch (Exception e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0999")) {
				logger.log("Component0999", ComUtil.getCurrentMethodName());
				}
		}finally{
			if(out != null){
				out.close();
			}
		}
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
	}
	
	/**
	 * 导入服务器信息

	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap upload(
			@RequestParam(value = "filePath", required = true) String filePath,
			HttpServletRequest request, ModelMap modelMap) throws Exception {
		//读取excel中的数据
		String info = "true";
		File f = new File(filePath);
		InputStream in = null;
		in = new FileInputStream(f);
		HSSFWorkbook workbook =  new HSSFWorkbook(in);
		//System.out.println(workbook.getNumberOfSheets());
		for(int i=0;i<workbook.getNumberOfSheets();i++){
			HSSFSheet sheet = workbook.getSheetAt(i);
			if(sheet.getSheetName().toString().indexOf("request")!=-1){
				
				info = excelCreateRequestService.checkRequestsList(sheet);
				
				if(!info.equals("true")){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", info);
					return modelMap;

				}
				RequestsVo requestsVo = excelCreateRequestService.achieveRequestsList(sheet);
				Long requestId = excelCreateRequestService.saveRequests(requestsVo);
				info = excelCreateRequestService.checkStepsList(sheet,requestsVo,requestId);
				if(!info.equals("true")){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", info);
					return modelMap;

				}
				List<StepsVo> stepsList = excelCreateRequestService.achieveStepsList(sheet, requestsVo, requestId);
				excelCreateRequestService.saveStepsVo(stepsList);
				String requestNewXml = excelCreateRequestService.createRequests(requestsVo);
				excelCreateRequestService.createSteps(stepsList,requestNewXml,requestsVo,requestId);
				
			}
			
		}
		if(!info.equals("true")){
			modelMap.addAttribute("success", Boolean.FALSE);
			//modelMap.addAttribute("error", info);
			return modelMap;
		}else{
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;

		}
		
	}
	

	
	/**
	 * 返回查看数据
	 * 
	 * @return 查看页面视图数据
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "requestsId", required = false) Integer requestsId,
			HttpServletRequest request,ModelMap modelMap) {
			
		/*modelMap=new ModelMap();
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,excelCreateRequestService.queryExcelCreateStepService(start,limit,sort,dir,requestsId));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,excelCreateRequestService.countExcelCreateStepService(requestsId));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;*/
		
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",excelCreateRequestService.queryExcelCreateStepService(start,limit,sort,dir,requestsId));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * stepCheckDB
	 * @throws Exception 
	 * allappDbCheck
	 */
	@RequestMapping(value = "/allappDbCheck", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap allappDbCheck(
			@RequestParam(value = "fileDbCheckPath", required = true) String filePath,
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		String allappDbCheckMsg = "";
		
		allappDbCheckMsg = excelCreateRequestService.allappDbCheck(filePath);
		if(!allappDbCheckMsg.equals("")){
			allappDbCheckMsg = "</br>" + allappDbCheckMsg + "</br>是否继续导入？";
		}
		modelMap.addAttribute("success", allappDbCheckMsg);
		return modelMap;
		
		
	}
}

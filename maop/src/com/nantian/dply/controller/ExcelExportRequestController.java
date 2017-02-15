package com.nantian.dply.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import com.nantian.jeda.Constants;

import com.nantian.component.brpm.BrpmService;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.DplyRequestInfoService;
import com.nantian.dply.service.ExcelCreateRequestService;
import com.nantian.dply.service.MoveBrpmExportService;
import com.nantian.jeda.security.util.SecurityUtils;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONArray;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.hibernate.exception.SQLGrammarException;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.nantian.common.system.controller.AppInfoController;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.jeda.JEDAException;

/**
 * @author <a href="mailto:liruihao@nantian.com.cn"></a>
 * 应用发布通过excel创建请求
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/excelexportrequest")
public class ExcelExportRequestController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(ExcelExportRequestController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "excel_export_request";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/excel/" + domain;

	@Autowired
	private SecurityUtils securityUtils;
	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;
	@Autowired
	private MoveBrpmExportService moveBrpmExportService;
	@Autowired
	DplyRequestInfoService dplyRequestInfoService;
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
			@RequestParam(value = "environment", required = false) String environment,
			@RequestParam(value = "app", required = false) String app,
			@RequestParam(value = "userName", required = false) String userName,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		    modelMap=new ModelMap();
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,brpmService.queryExcelExportRequestService(start,limit,sort,dir,app,name,environment,userName));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,brpmService.countExcelExportRequestService(app,name,environment,userName));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
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
			HttpServletRequest request,ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		modelMap=new ModelMap();
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,brpmService.queryExcelExportStepService(start,limit,sort,dir,requestsId));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,brpmService.countExcelExportStepService(requestsId));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	/**
	 * 导出查询结果
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/downloadrequestTemplet", method = RequestMethod.GET)
	public String excel(
			/*@RequestParam(value = "requestsId", required = false) Integer requestsId,
			@RequestParam(value = "name", required = false) String name,
			@RequestParam(value = "environment", required = false) String environment,*/
			@RequestParam(value = "ids", required = false) String ids,

			HttpServletRequest request, ModelMap modelMap) throws Exception{
		String requestsId[] = URLDecoder.decode(ids,"utf-8").split(",");
		Map<String, String> stepChangeColumns = new LinkedHashMap<String, String>();
		stepChangeColumns.put("position", "序号");
		stepChangeColumns.put("serviceCode", "服务编码");
		stepChangeColumns.put("name", "步骤名称");
		stepChangeColumns.put("component", "目标组件");
		stepChangeColumns.put("manual", "步骤类型");
		stepChangeColumns.put("differentLevelFromPrevious", "是否并发");
		stepChangeColumns.put("userName", "执行人员");
		stepChangeColumns.put("autoJobName", "自动化作业名称");
		modelMap.addAttribute("stepColumns", stepChangeColumns);

		Map<String, String> requestNum = new LinkedHashMap<String, String>();
		requestNum.put("requestNum", ids);
		modelMap.addAttribute("requestNum", requestNum);
		
		for(int i=0;i<requestsId.length;i++){
			modelMap.addAttribute("stepData"+i, brpmService.queryExcelExportStepService(requestsId[i]));//request.getSession().getAttribute("requestChangeColumns")
			modelMap.addAttribute("requestData"+i, brpmService.queryExcelExportRequestService(requestsId[i]));
		}
		/*String app = name.split("_")[0];
		if(environment.equals(app+"_DEV_ENV")){
			environment = "开发";
		}
		if(environment.equals(app+"_QA_ENV")){
			environment = "测试";
		}
		if(environment.equals(app+"_PROV_ENV")){
			environment = "验证";
		}
		if(environment.equals(app+"_PROD_ENV")){
			environment = "生产";
		}*/
		/*List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		Map<String, String> map = new HashMap<String, String>();
		map.put("name", name);
		map.put("app", app);
		map.put("environment", environment);
		jsonMapList.add(map);

		Map<String, String> stepChangeColumns = new LinkedHashMap<String, String>();
		stepChangeColumns.put("position", "序号");
		stepChangeColumns.put("serviceCode", "服务编码");
		stepChangeColumns.put("name", "步骤名称");
		stepChangeColumns.put("component", "目标组件");
		stepChangeColumns.put("manual", "步骤类型");
		stepChangeColumns.put("differentLevelFromPrevious", "是否并发");
		stepChangeColumns.put("userName", "执行人员");
		stepChangeColumns.put("autoJobName", "自动化作业名称");

		modelMap.addAttribute("stepChangeColumns", stepChangeColumns);
		modelMap.addAttribute("stepChangeData", brpmService.queryExcelExportStepService(requestsId));//request.getSession().getAttribute("requestChangeColumns")
		modelMap.addAttribute("requestChangeData", jsonMapList);*/
		return "excelView4Request";
	}
	
	
	/**
	 * 导出查询结果
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/downloadControlTemplet", method = RequestMethod.GET)
	public String downloadControlTemplet(
			
			@RequestParam(value = "requestids", required = false) String requestids,
			@RequestParam(value = "appsys_code", required = false) String appsys_code,
			
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		String requestid[] = URLDecoder.decode(requestids,"utf-8").split(",");
		String  ids="" ;
		List<String> rids=new ArrayList<String>();
		String requestcode="";
		for(int i=0;i<requestid.length ;i++){
			String id =dplyRequestInfoService.findReqIdByName(requestid[i].split(CommonConst.REPLACE_CHAR)[0],requestid[i].split(CommonConst.REPLACE_CHAR)[1]);
			ids =id+","+ids;
			rids.add(id);
			requestcode= requestcode+","+requestid[i].split(CommonConst.REPLACE_CHAR)[0].toString();
		}
		ids=ids.substring(0, ids.length()-1);
		requestcode=requestcode.substring(1, requestcode.length());
		Map<String, String> stepChangeColumns = new LinkedHashMap<String, String>();
		stepChangeColumns.put("position", "序号");
		stepChangeColumns.put("serviceCode", "服务编码");
		stepChangeColumns.put("name", "步骤名称");
		stepChangeColumns.put("component", "目标组件");
		stepChangeColumns.put("manual", "步骤类型");
		stepChangeColumns.put("differentLevelFromPrevious", "是否并发");
		stepChangeColumns.put("userName", "执行人员");
		stepChangeColumns.put("autoJobName", "自动化作业名称");
		modelMap.addAttribute("stepColumns", stepChangeColumns);

		Map<String, String> requestNum = new LinkedHashMap<String, String>();
		Map<String, String> requestcodes = new LinkedHashMap<String, String>();
		requestNum.put("requestNum", ids);
		requestcodes.put("requestcodes", requestcode);
		modelMap.addAttribute("requestNum", requestNum);
		modelMap.addAttribute("requestcodes", requestcodes);
		request.setAttribute("appsys_code", appsys_code);
		for(int i=0;i<rids.size();i++){
			modelMap.addAttribute("stepData"+i, brpmService.queryExcelExportStepService(rids.get(i)));//request.getSession().getAttribute("requestChangeColumns")
			modelMap.addAttribute("requestData"+i, brpmService.queryExcelExportRequestService(rids.get(i)));
		}
		
		return "excelControlRequest";
	}
	
	/**
	 * stepCheckDB
	 * @throws Exception 
	 * allappDbCheck
	 */
	@RequestMapping(value = "/allappDbCheck", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap allappDbCheck(
			@RequestParam(value = "idAndNames", required = false) String idAndNames,
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		
		//多用户导入单系统检查.
		String allappDbCheckMsg = "";
		//String userName = securityUtils.getUser().getUsername();
		String[] doGetFilesNamelist = URLDecoder.decode(idAndNames,"utf-8").split(",");

		//doGetFilesNamelist = moveBrpmExportService.getRequestsInfo(appsys_code, tranItemS, brpm, userName);

		allappDbCheckMsg = moveBrpmExportService.allappDbCheck(doGetFilesNamelist);
		if(!allappDbCheckMsg.equals("")){
			allappDbCheckMsg = "</br>" + allappDbCheckMsg + "</br>是否继续导出？";
		}
		modelMap.addAttribute("success", allappDbCheckMsg);
		return modelMap;
		
		
	}
	
}

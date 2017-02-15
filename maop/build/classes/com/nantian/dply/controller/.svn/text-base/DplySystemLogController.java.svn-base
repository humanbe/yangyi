package com.nantian.dply.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.dply.service.DplySystemLogService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;

/**
 * 日志管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/dplysystemlog")
public class DplySystemLogController {

	/** 领域对象名称 */
	private static final String domain = "cmnlog";

	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain +"_";

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/** Service */
	@Autowired
	private DplySystemLogService dplySystemLogService;

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
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "index";
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
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "execStartTime", required = false) String execStartTime,
			@RequestParam(value = "execCompletedTime", required = false) String execCompletedTime,
			@RequestParam(value = "logType", required = false) String logType,
			@RequestParam(value = "logResourceType", required = false) String logResourceType,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		    modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request,dplySystemLogService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dplySystemLogService.queryAll(start, limit, sort, dir,appsysCode,execStartTime,execCompletedTime,logType,logResourceType));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,dplySystemLogService.count(appsysCode,execStartTime,execCompletedTime,logType,logResourceType));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
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
	@RequestMapping(value = "/eventlogindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap eventloglist(
			@RequestParam(value = "event_id", required = false) String event_id,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		    modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request,dplySystemLogService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dplySystemLogService.queryAllEventLog(event_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 查询应用系统所有编号
	 * 
	 */
	@RequestMapping(value = "/querySystemIDAndNames", method = RequestMethod.GET)
	public @ResponseBody
	void querySystemIDAndNames(HttpServletResponse response) throws IOException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception{
		PrintWriter out = null;
		try {
			Object sysIDs = dplySystemLogService.querySystemIDAndNames();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIDs));
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (out != null) {
				out.close();
			}
		}
	}


	/**
	 * 导出日志 
	 * 
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/export", method = RequestMethod.GET)
	public String export(HttpServletRequest request, ModelMap modelMap)
			throws JEDAException,Exception {
		modelMap.clear();
		Map<String, Object> params = RequestUtil.getQueryMap(request,dplySystemLogService.fields);
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("logJnlNo", messages.getMessage("column.logJnlNo"));
		columns.put("execDate", messages.getMessage("column.execDate"));
		columns.put("appsysCode", messages.getMessage("column.appsysCode"));
		columns.put("logResourceType", messages.getMessage("column.logResourceType"));
		columns.put("requestName", messages.getMessage("column.requestName"));
		columns.put("logType", messages.getMessage("column.logType"));
		columns.put("execStatus", messages.getMessage("column.execStatus"));
		columns.put("execStartTime", messages.getMessage("column.execStartTime"));
		columns.put("execCompletedTime", messages.getMessage("column.execCompletedTime"));
		columns.put("execCreatedTime", messages.getMessage("column.execCreatedTime"));
		columns.put("execUpdatedTime", messages.getMessage("column.execUpdatedTime"));
		columns.put("authorizedUser", messages.getMessage("column.authorizedUser"));
		columns.put("platformUser", messages.getMessage("column.platformUser"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY,columns);
		// 设定导出用模板文件对应的sheet名字
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
		dplySystemLogService.queryAll(0,Constants.DEFAULT_EXCEL_ROW_LIMIT, "logJnlNo",Constants.DEFAULT_SORT_DIRECTION, params));
		// 返回servletName
		return "excelView";
	}
	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "view";
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
			@RequestParam(value = "logJnlNo", required = false) String logJnlNo,
			HttpServletRequest request,ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
			modelMap.clear();
			Map<String, Object> params = RequestUtil.getQueryMap(request,dplySystemLogService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dplySystemLogService.findByPrimaryKey(start, limit, sort, dir,params,logJnlNo));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,dplySystemLogService.countLog(logJnlNo));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	

	/**
	 * 返回查看步骤详细日志页面
	 * 
	 * @return 查看步骤详细日志页面视图名称
	 */
	@RequestMapping(value = "/detail", method = RequestMethod.GET)
	public String detail() throws JEDAException {
		return viewPrefix + "runview";
	}
	
	/**
	 * 返回查看数据
	 * 
	 * @return 查看步骤详细日志页面视图数据
	 */
	@RequestMapping(value = "/detail", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap detail(
			@RequestParam(value = "resultsPath", required = false) String resultsPath,
			@RequestParam(value = "logJnlNo", required = false) String logJnlNo,
			ModelMap modelMap)  throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,FileNotFoundException,Exception{
			modelMap.clear();
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dplySystemLogService.findDetail(URLDecoder.decode(resultsPath,"utf-8")));
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("success", Boolean.FALSE);
		    return modelMap;
	}
}

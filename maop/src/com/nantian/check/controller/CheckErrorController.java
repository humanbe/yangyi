package com.nantian.check.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.hibernate.exception.SQLGrammarException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.CheckDataSynService;
import com.nantian.check.service.CheckErrorService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 巡检错误处理controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/checkerror")
public class CheckErrorController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckErrorController.class);
	/** 领域对象名称 */
	private static final String domain = "checkerror";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private CheckErrorService checkErrorService;
	@Autowired
	private SecurityUtils securityUtils; 
	@Autowired
	private CheckDataSynService checkDataSynService;
	
	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index"; 
	}

	/**
	 * 查询服务器信息	 * @param start 分页查询起始位置
	 * @param limit 分页查询结束位置
	 * @param sort  排序字段
	 * @param dir 排序方法
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryErrorlist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, checkErrorService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
				checkErrorService.queryErrorList(start, limit, sort, dir,params, request));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,
				checkErrorService.countQueryErrorList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取某一天的所有巡检时间点
	 * @param checkDate 巡检日期
	 * @return
	 */
	@RequestMapping(value = "/queryCheckDate", method = RequestMethod.POST)
	public @ResponseBody void queryCheckDate(
			@RequestParam(value = "checkDate", required = false) String checkDate,
			HttpServletRequest request, HttpServletResponse response) throws DataAccessException,SQLException,SQLGrammarException,IOException{
		PrintWriter out = null;
		Object names = checkErrorService.queryCheckDate(checkDate);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 根据应用系统编号获取应用系统信息
	 * @param appsysCodes 应用系统编号
	 * @return
	 */
	@RequestMapping(value = "/getAppsysByCodes", method = RequestMethod.POST)
	public @ResponseBody void getAppsysByCodes(
			@RequestParam(value = "appsysCodes", required = false) List<String> appsysCodes,
			HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException{
		PrintWriter out = null;
		List<Map<String, Object>> list = checkErrorService.getAppsysByCodes(appsysCodes);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(list));
		if(out != null){
			out.close();
		}
	}
	
	/**
	 * 返回明细页面
	 */
	@RequestMapping(value = "/oneDetail", method = RequestMethod.GET)
	public String deta(){
		return viewPrefix + "deta"; 
	}
	
	/**
	 * 明细
	 * @param LastDate 巡检时间
	 * @param FlucDatetime 巡检时间前移
	 * @param ServerName 主机名称
	 * @param appsysCode 应用系统
	 * @param checkDate 巡检日期
	 * @param checkstatus 检查状态
	 * @param queryAppsys 应用系统查询字段
	 * @param queryServer 主机名称查询字段
	 * @return
	 */
	@RequestMapping(value = "/oneDetail", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap oneDetail(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "LastDate", required = false) String LastDate,
			@RequestParam(value = "FlucDatetime", required = false) String FlucDatetime,
			@RequestParam(value = "ServerName", required = false) String ServerName,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "appsysCode_ip", required = false) String appsysCode_ip,
			@RequestParam(value = "checkDate", required = false) String checkDate,
			@RequestParam(value = "checkstatus", required = false) String checkstatus,
			//@RequestParam(value = "queryAppsys", required = false) String queryAppsys,
			@RequestParam(value = "queryCheckType", required = false) String queryCheckType,
			@RequestParam(value = "queryServer", required = false) String queryServer,
			HttpServletRequest request, ModelMap modelMap)throws Exception ,SQLException {
	    Map<String, Object> params = RequestUtil.getQueryMap(request, checkErrorService.fields);
	    if(ServerName!=null && !ServerName.equals("")){
	    	ServerName = java.net.URLDecoder.decode(ServerName,"utf-8") ;
	    }
	    if(appsysCode!=null && !appsysCode.equals("")){
	    	appsysCode = java.net.URLDecoder.decode(appsysCode,"utf-8") ;
	    }
	    if(LastDate!=null && !LastDate.equals("")){
	    	LastDate = java.net.URLDecoder.decode(LastDate,"utf-8") ;
	    }
	    if(FlucDatetime!=null && !FlucDatetime.equals("")){
	    	FlucDatetime = java.net.URLDecoder.decode(FlucDatetime,"utf-8") ;
	    }
	    if(checkDate!=null && !checkDate.equals("")){
	    	checkDate = java.net.URLDecoder.decode(checkDate,"utf-8") ;
	    }
	    if(checkstatus!=null && !checkstatus.equals("")){
	    	checkstatus = java.net.URLDecoder.decode(checkstatus,"utf-8") ;
	    }
//	    if(queryAppsys!=null && !queryAppsys.equals("")){
//	    	queryAppsys = java.net.URLDecoder.decode(queryAppsys,"utf-8") ;
//	    }
	    if(queryCheckType!=null && !queryCheckType.equals("")){
	    	queryCheckType = java.net.URLDecoder.decode(queryCheckType,"utf-8") ;
	    }
	    if(queryServer!=null && !queryServer.equals("")){
	    	queryServer = java.net.URLDecoder.decode(queryServer,"utf-8") ;
	    }
	    modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
	    		checkErrorService.oneDetail(start, limit, sort, dir,appsysCode,appsysCode_ip,checkDate, ServerName,params,
	    				LastDate,FlucDatetime,checkstatus,queryCheckType,queryServer));
	    modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,
	    		checkErrorService.countOneDetail(appsysCode,appsysCode_ip,checkDate, ServerName,params,
	    				LastDate,FlucDatetime,checkstatus,queryCheckType,queryServer));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回单条纪录查询
	 */
	@RequestMapping(value = "/edithand", method = RequestMethod.GET)
	public String hand(){
		return viewPrefix + "hand"; 
	}
	
	/**
	 * 查询单条纪录信息
	 * @param ServerName 主机名称
	 * @param StartDatetime 巡检时间
	 * @param RuleName 巡检项
	 */
	@RequestMapping(value = "/hand", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap hand(
			@RequestParam(value = "ServerName", required = false) String ServerName,
			@RequestParam(value = "StartDatetime", required = false) String StartDatetime,
			@RequestParam(value = "RuleName", required = false) String RuleName,
			HttpServletRequest request, ModelMap modelMap) throws Exception ,SQLException {
		String ruleName = java.net.URLDecoder.decode(RuleName,"utf-8") ;
		modelMap.addAttribute("data",checkErrorService.findHand(ServerName,StartDatetime,ruleName));
		modelMap.addAttribute("success", Boolean.TRUE);
	    return modelMap;
	}
	
	/**
	 * 执行单条纪录的处理单数据保存操作
	 * @param ServerName 主机名称
	 * @param StartDatetime 巡检时间
	 * @param RuleName 巡检项
	 * @param Result 处理结果
	 * @param AppsysCode 应用系统
	 * @param HandleState 处理状态
	 * @param Desc 问题描述
	 */
	@RequestMapping(value = "/edithand", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edithand(@RequestParam("ServerName") String ServerName, 
			@RequestParam("StartDatetime") String StartDatetime, 
			@RequestParam("RuleName") String RuleName, 
			@RequestParam(value = "Result", required = false) String Result,
			@RequestParam(value = "AppsysCode", required = false) String AppsysCode,
			@RequestParam(value = "HandleState", required = false) String HandleState,
			@RequestParam(value = "Desc", required = false) String Desc,
			HttpServletRequest request, ModelMap modelMap) throws Exception ,SQLException {
		checkErrorService.editHand(ServerName,StartDatetime,RuleName,Result,AppsysCode,HandleState,Desc,request);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回多条纪录处理
	 */
	@RequestMapping(value = "/entr", method = RequestMethod.GET)
	public String entr(){
		return viewPrefix + "entr"; 
	}
	
	/**
	 * 批量处理
	 * @param ServerName 主机名称
	 * @param StartDatetime 巡检时间
	 * @param RuleName 巡检项
	 * @param Result 处理结果
	 * @param AppsysCode 应用系统
	 * @param HandleState 处理状态
	 * @param Desc 问题描述
	 */
	@RequestMapping(value = "/editEntr", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editEntr(
			@RequestParam(value = "ServerName", required = false) List<String> ServerName,
			@RequestParam(value = "StartDatetime", required = false) List<String> StartDatetime,
			@RequestParam(value = "RuleName", required = false) List<String> RuleName,
			@RequestParam(value = "Result", required = false) String Result,
			@RequestParam(value = "AppsysCode", required = false) List<String> AppsysCode,
			@RequestParam(value = "HandleState", required = false) String HandleState,
			@RequestParam(value = "Desc", required = false) String Desc,
			HttpServletRequest request, ModelMap modelMap)
			throws Exception  ,SQLException{
		String username = securityUtils.getUser().getUsername() ; //处理人		checkErrorService.editEntr(ServerName,StartDatetime,username,Result,Desc,RuleName,AppsysCode,HandleState);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取当前用户名称
	 */
	@RequestMapping(value = "/getUserName", method = RequestMethod.POST)
	public @ResponseBody void getUserName(
			ModelMap modelMap,HttpServletRequest request, 
			HttpServletResponse response) throws IOException,SQLException{
		Object username = securityUtils.getUser().getName() ;
		List<Map<String, Object>> list =new ArrayList<Map<String, Object>>();
		Map<String, Object> map = new HashMap<String,Object>();
		map.put("UName", username);
		list.add(map);
		PrintWriter out = null;
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(list));
	}
	
	/**
	 * 获取巡检规则信息
	 */
	@RequestMapping(value = "/queryRuleName", method = RequestMethod.GET)
	public @ResponseBody void queryRuleName(
			HttpServletRequest request, HttpServletResponse response) throws DataAccessException, SQLException,SQLGrammarException, IOException{
		PrintWriter out = null;
		Object names = checkErrorService.queryRuleName();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 根据主机名、作业执行开始时间、扩展对象读取日志文件信息	 * @param serverName 主机名称
	 * @param startTime 作业执行开始时间	 * @param ExtendObject 扩展对象名称
	 * @param log 日志文件名称
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 */
	@RequestMapping(value = "/getLogByServerAndTimeAndExtend", method = RequestMethod.POST)
	public @ResponseBody
		ModelMap getLogByServerAndTimeAndExtend(
				@RequestParam(value = "serverName", required = true) String serverName,
				@RequestParam(value = "startTime", required = true) String startTime,
				@RequestParam(value = "extendObject", required = true) String extendObject,
				@RequestParam(value = "log", required = true) String log,
				ModelMap modelMap) throws FileNotFoundException, IOException{
		String logInfo = "" ;  //日志文件信息
		if(serverName!=null && !serverName.equals("") && startTime!=null && !startTime.equals("") 
				&& log!=null && !log.equals("")){
				logInfo = checkErrorService.readFile(serverName,startTime,log);
		}
		modelMap.addAttribute("info", logInfo); 
		modelMap.addAttribute("id", log); 
		return modelMap;
	}
	
	/**
	 * 同步作业的执行结果数据	 */
	@RequestMapping(value = "/synCheckResultInfo", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap synCheckResultInfo(ModelMap modelMap) throws Exception {
		String synNum = checkDataSynService.synCheckResultData(); 
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("info", synNum);
		return modelMap;
	}
	
	
}

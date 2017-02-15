package com.nantian.dply.controller;

import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.hibernate.exception.ConstraintViolationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.dao.DataAccessException;
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

import com.nantian.common.util.ComUtil;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.CmnEnvironmentService;
import com.nantian.dply.vo.AppGroupVo;
import com.nantian.dply.vo.CmnEnvironmentVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;

/**
 * 应用系统环境管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/cmnenvironment")
public class CmnEnvironmentController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(CmnEnvironmentController.class);

	/** 领域对象名称 */
	private static final String domain = "cmnenv";

	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain +"_";
	
	@Autowired
	private CmnEnvironmentService cmnEnvironmentService;
	
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
	 * @param start         起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段
	 * @param dir	  		   排序的方式
	 * @param appSysCd   应用系统编号
	 * @param sysseqnum  流水号

	 * @param appsysCode  系统代码
	 * @param environmentType  环境类型
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
			@RequestParam(value = "environmentType", required = false) String environmentType,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, cmnEnvironmentService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, cmnEnvironmentService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, cmnEnvironmentService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	
	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/ipIndex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap ipList(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "serverIp", required = false) String serverIp,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
			List<ServersInfoVo> appSystemsList = null;
			Map<String, Object> params = RequestUtil.getQueryMap(request, cmnEnvironmentService.fields);
			appSystemsList = (List<ServersInfoVo>) cmnEnvironmentService.queryServersInfo(limit,start,sort, dir,appsysCode,serverIp,/* params,*/ request);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appSystemsList);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, cmnEnvironmentService.serverCount(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		return viewPrefix + "create";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param cmnEnvironmentVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CmnEnvironmentVo cmnEnvironmentVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
			cmnEnvironmentService.save(cmnEnvironmentVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	

	
	/**
	 * 返回编辑页面
	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "edit";
	}
	
	/**
	 * 编辑更新数据
	 * @param appsysCode 应用系统编号
	 * @param environmentCode 环境编号
	 * @param request
	 * @return 
	 */
	@RequestMapping(value = "/edit/{appsysCode}/{environmentCode}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@ModelAttribute CmnEnvironmentVo cmnEnvironmentVo,
			HttpServletRequest request,ModelMap modelMap)  throws HibernateOptimisticLockingFailureException,Exception  {
			modelMap.clear();
			cmnEnvironmentService.edit(cmnEnvironmentVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}

	/**
	 * 返回新建分组页面
	 * 
	 * @return 列表页面视图名称
	 */

	@RequestMapping(value = "/creategroup", method  = RequestMethod.GET)
	public String groupcreate() throws JEDAException{
		return viewPrefix + "group_create";
	}
	/**
	 * 返回新建分组页面
	 * 
	 * @return 列表页面视图名称
	 */

	@RequestMapping(value = "/editcreategroup", method  = RequestMethod.GET)
	public String editgroupcreate() throws JEDAException{
		return viewPrefix + "group_edit";
	}
	/**
	 * 保存新建分组
	 * @param AppGroupVo 数据对象
	 * @return  
	 */
@RequestMapping(value = "/createSave", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap createSave(@ModelAttribute AppGroupVo appGroupVo,
			@RequestParam(value = "appsysCode", required =false )String appsysCode,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception {
			modelMap.clear();
			cmnEnvironmentService.saveGroup(appGroupVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("appsysCode",appsysCode);
			modelMap.addAttribute("environmentCode",appGroupVo.getEnvironmentCode());
		return modelMap;
	}
/**
 * 新建查看环境编号
 * @param appsysCode 系统编号
 * @param environmentCode 环境编号
 * @return  
 */
@RequestMapping(value = "/viewEnvTest/{environmentCode}/{appsysCode}", method = RequestMethod.GET)
public @ResponseBody
ModelMap viewEnv(@ModelAttribute AppGroupVo appGroupVo,
		@PathVariable("environmentCode") String environmentCode,
		@PathVariable("appsysCode") String appsysCode,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,Exception {
		modelMap.clear();
		appGroupVo.setEnvironmentCode(environmentCode);
		appGroupVo.setAppsysCode(appsysCode);
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("data", appGroupVo);
	return modelMap;
}
	/**
	 * 查询所有分组

	 * @param start          起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段

	 * @param dir	  		   排序的方式 
	 * @param appsysCodes    系统代码 
	 * @return
	 */
	@RequestMapping(value = "/findGroup", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap findGroup(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "environmentCode", required = false) String environmentCode,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception{
			modelMap.clear();
			Map<String, Object> params = RequestUtil.getQueryMap(request, cmnEnvironmentService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, cmnEnvironmentService.queryServerGroup(start, limit, sort, dir,appsysCode,environmentCode));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, cmnEnvironmentService.countGroup(params));
			modelMap.addAttribute("success", Boolean.TRUE);	
			return modelMap;
	}
	/**
	 * 查询服务器Ip
	 * @param start          起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段

	 * @param dir	  		   排序的方式 
	 * @param appsysCodes    系统代码
	 * @return
	 */
	@RequestMapping(value = "/findIp", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap findIp(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			HttpServletRequest request, ModelMap modelMap)  throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, cmnEnvironmentService.fields);
			modelMap.addAttribute("data3", cmnEnvironmentService.queryServerIp(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, cmnEnvironmentService.countIp(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	
	/**
	 * 刪除环境表内容

	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组

	 * @return
	 */
	@RequestMapping(value = "/delete",  method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "appsysCodes", required = true) String[] appsysCodes, 
			@RequestParam(value = "environmentCodes", required = true) String[] environmentCodes,
			ModelMap modelMap)throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			cmnEnvironmentService.deleteByIds(appsysCodes, environmentCodes);
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	
	/**
	 * 删除分组. 
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组

	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/deleteGroup", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteGroup(
			@RequestParam(value = "appsysCodes", required = true) String[] appsysCodes, 
			@RequestParam(value = "serverGroups", required = true) String[] serverGroups, 
			@RequestParam(value = "environmentCodes", required = true) String[] environmentCodes, 
			ModelMap modelMap)
			throws DataAccessException, SQLException ,DataIntegrityViolationException,HibernateOptimisticLockingFailureException,Exception {
			modelMap.clear();
			cmnEnvironmentService.deleteByUnionKeys(appsysCodes, serverGroups,environmentCodes);
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
	
	/**
	 * 删除服务器分组. 
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组

	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/deleteServerGroup", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteServerGroup(
			@RequestParam(value = "appsysCodes", required = true) String[] appsysCodes, 
			@RequestParam(value = "serverGroups", required = true) String[] serverGroups,  
			ModelMap modelMap)
			throws DataAccessException, SQLException ,DataIntegrityViolationException,HibernateOptimisticLockingFailureException,Exception {
			modelMap.clear();
			cmnEnvironmentService.deleteGroupByUnionKeys(appsysCodes, serverGroups);
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
	/**
	 * 查询环境
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组

     * @return
	 */
	@RequestMapping(value = "/findEnv/{appsysCode}/{environmentCode}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap findEnv(
			@PathVariable("appsysCode") String appsysCode,
			@PathVariable("environmentCode") String environmentCode,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data", cmnEnvironmentService.queryEnv(appsysCode,environmentCode));
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
	/**
	 * 查询树的数据
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryTree", method = RequestMethod.POST)
	public @ResponseBody void queryTree(
			@RequestParam(value = "appsysCode", required =false )String appsysCode,
			@RequestParam(value = "environmentCode", required =false )String environmentCode,
			HttpServletRequest request, 
			HttpServletResponse response){
			List<JSONObject> jsonList = new ArrayList<JSONObject>();
			PrintWriter out = null;
			if (logger.isEnableFor("Component0001")) {
				logger.log("Component0001", ComUtil.getCurrentMethodName());
				}
			try{
			List<Map<String,Object>> dataList = cmnEnvironmentService.queryTree(appsysCode,environmentCode);
			jsonList = cmnEnvironmentService.getJosnObjectForTree(dataList);
			
			out = response.getWriter();
			out.print(jsonList);
			
			} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0999")) {
				logger.log("Component0999", ComUtil.getCurrentMethodName());
				}
			}
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", ComUtil.getCurrentMethodName());
				}
       }
	
	/**
	 * 查询树的数据
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryCreateTree", method = RequestMethod.POST)
	public @ResponseBody void queryCreateTree(
			@RequestParam(value = "appsysCode", required =false )String appsysCode,
			@RequestParam(value = "environmentCode", required =false )String environmentCode,
			HttpServletRequest request, 
			HttpServletResponse response){
			List<JSONObject> jsonList = new ArrayList<JSONObject>();
			PrintWriter out = null;
			if (logger.isEnableFor("Component0001")) {
				logger.log("Component0001", ComUtil.getCurrentMethodName());
				}
			try{
			List<Map<String,Object>> dataList = cmnEnvironmentService.queryCreateTree(appsysCode,environmentCode);
			jsonList = cmnEnvironmentService.getJosnObjectForTree(dataList);
			
			out = response.getWriter();
			out.print(jsonList);
			
			} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0999")) {
				logger.log("Component0999", ComUtil.getCurrentMethodName());
				}
			}
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", ComUtil.getCurrentMethodName());
				}
       }
	/**
	 * 同步BRPM数据
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/synbrpm", method = RequestMethod.POST)
	public @ResponseBody ModelMap synbrpm(
			@RequestParam(value = "data", required = true) String data,
			HttpServletRequest request, 
			ModelMap modelMap)throws DataIntegrityViolationException,BrpmInvocationException,Exception{
			modelMap.clear();
			JSONArray array = JSONArray.fromObject(data);
			List<String> list = (List<String>) JSONArray.toCollection(array, String.class);
			cmnEnvironmentService.synBRPM(list);
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	
	/**
	 * 同步BSA数据
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/synbsa", method = RequestMethod.POST)
	public @ResponseBody ModelMap syncToBsa(
			@RequestParam(value = "data", required = true) String data,HttpServletRequest request, ModelMap modelMap) throws AxisFault,DataIntegrityViolationException,Exception{
		modelMap.clear();
		JSONArray array = JSONArray.fromObject(data);
		List<String> list = (List<String>) JSONArray.toCollection(array, String.class);
		cmnEnvironmentService.synBsa(list);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 同步BRPM数据
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/queryENV", method = RequestMethod.GET)
	public @ResponseBody void synenv(
			HttpServletResponse response)throws DataIntegrityViolationException,BrpmInvocationException,Exception{
		PrintWriter out = null;
		Object names = cmnEnvironmentService.queryENV();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	/**
	 * 同步BRPM数据
	 * @returnqueryRuleEnv
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/queryRuleEnv", method = RequestMethod.GET)
	public @ResponseBody void queryRuleEnv(
			HttpServletResponse response, ModelMap modelMap)throws DataIntegrityViolationException,BrpmInvocationException,Exception{
		PrintWriter out = null;
		try {
			Object sysIDs = cmnEnvironmentService.queryRuleEnv();
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
	/*	
		modelMap.clear();
		modelMap.addAttribute("data", cmnEnvironmentService.queryRuleEnv());
		modelMap.addAttribute("success", Boolean.TRUE);
	    return modelMap;*/
	}
}///:~

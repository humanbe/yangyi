package com.nantian.dply.controller;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.system.controller.AppInfoController;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.MoveBrpmImportService;
import com.nantian.dply.service.MoveBsaImportService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
/**
 * @author <a href="mailto:liruihao@nantian.com.cn"></a>
 * 发布迁移导入
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/moveimport")
public class MoveImportController {

	
	/** 模板管理领域对象名称 */
	private static final String domain = "move_import";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/move/" + domain;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	@Autowired
	private MoveBsaImportService moveBsaImportService;
	
	@Autowired
	private MoveBrpmImportService moveBrpmImportService;
	
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(AppInfoController.class);
	
	/**
	 * 返回应用发布迁移导入页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix ;
	}
	
	/**
	 * 查询系统
	 * 
	 * 
	 */
	@RequestMapping(value = "/getCmnAppInfo", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCmnAppInfo(HttpServletRequest request,ModelMap modelMap)throws JEDAException{
		modelMap.addAttribute("CmnAppInfo", moveBrpmImportService.getCmnAppInfo());
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	
	/**
	 * 从BRPM查询请求列表
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getRequest", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getRequest(@RequestParam(value = "appsys_code2", required = false) String appsys_code,
			@RequestParam(value = "env2", required = false) String env,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, ParseException, IOException,FtpCmpException {
	    Object l = moveBrpmImportService.getRequest(appsys_code,securityUtils.getUser().getUsername(),env.split(CommonConst.UNDERLINE)[1].toString());
		modelMap.addAttribute("RequestInfo",l);
		modelMap.addAttribute("success", Boolean.TRUE);
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
			@RequestParam(value = "appsys_code2", required = false) String appsys_code,      
			@RequestParam(value = "envExp", required = false) String envExp,  
			@RequestParam(value = "brpm2", required = false) String brpm,
			//@RequestParam(value = "bsa", required = false) String bsa,
			@RequestParam(value = "tranItemS2", required = false) String tranItemS,
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		
		//多用户导入单系统检查.
		String allappDbCheckMsg = "";
		String userName = securityUtils.getUser().getUsername();
		String[] doGetFilesNamelist = null;

		doGetFilesNamelist = moveBrpmImportService.getRequestsInfo2(appsys_code, tranItemS, brpm, userName,envExp.split(CommonConst.UNDERLINE)[1].toString());

		allappDbCheckMsg = moveBrpmImportService.allappDbCheck(doGetFilesNamelist, userName);
		
		if(!allappDbCheckMsg.equals("")){
			allappDbCheckMsg = "</br>" + allappDbCheckMsg + "</br>是否继续导入？";
		}
		modelMap.addAttribute("success", allappDbCheckMsg);
		return modelMap;
	}
	
	/**
	 * 应用发布迁移导入功能
	 * @throws URISyntaxException 
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 * @throws Throwable 
	 * @throws Exception 
	 * 
	 */
	@RequestMapping(value = "/dplyImport", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap dplyImport(
			@RequestParam(value = "appsys_code2", required = false) String appsys_code2,
			@RequestParam(value = "tranItemS2", required = false) String tranItemS2,
			@RequestParam(value = "brpm2", required = false) String brpm2,
			@RequestParam(value = "bsa2", required = false) String bsa2,
			@RequestParam(value = "env", required = false) String env,
			@RequestParam(value = "envExp", required = false) String envExp,
			HttpServletRequest request, ModelMap modelMap) throws IOException, BrpmInvocationException, URISyntaxException, Exception{
		String uuid = null;
		modelMap.clear();
		
		String userName = securityUtils.getUser().getUsername();
		String[] doGetFilesNamelist = null;
		String requestor_id = "";
		Map<String,String> uuidBrpmMap = new HashMap<String,String>();
		String[] uuids = null;
		
		//多用户导入单系统检查.
		boolean mulUserImpSingSysCheck = moveBrpmImportService.mulUserImpSingSysCheck(appsys_code2,env);
		if(mulUserImpSingSysCheck == false){
			modelMap.addAttribute("success", "mulUserImpSingSysCheck");
			return modelMap;
		}
		
		//单用户导入多系统数据字典开关检查.
		boolean singUserImpMulSysSwitchCheck = moveBrpmImportService.singUserImpMulSysSwitchCheck();
		if(singUserImpMulSysSwitchCheck == false){
			//单用户导入多系统检查.
			boolean singUserImpMulSysCheck = moveBrpmImportService.singUserImpMulSysCheck(userName,env);
			if(singUserImpMulSysCheck == false){
				modelMap.addAttribute("success", "singUserImpMulSysCheck");
				return modelMap;
			}
		}
		
		//环境是否在brpm中存在检查.
		boolean envCheck = moveBrpmImportService.envCheck(env);
		if(envCheck == false){
			modelMap.addAttribute("success", "envCheck");
			return modelMap;
		}
		
		//ftp获取导入文件.
		if((brpm2 != null) && (brpm2.length() != 0)){
			doGetFilesNamelist = moveBrpmImportService.getRequestsInfo(appsys_code2, tranItemS2, brpm2, userName, env.split(CommonConst.UNDERLINE)[1].toString(), envExp.split(CommonConst.UNDERLINE)[1].toString());
			uuids = new String[doGetFilesNamelist.length];
			for(int i=0;i<doGetFilesNamelist.length&&doGetFilesNamelist[i]!=null;i++){
				uuid = UUID.randomUUID().toString();
				uuids[i] = uuid;
				uuidBrpmMap.put(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0], uuid);
				moveBrpmImportService.saveDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_WAIT_CH, appsys_code2, doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0], env);
			}
		}
		
		//导入BSA.
		if((bsa2 != null) && (bsa2.length() != 0)){
			uuid = UUID.randomUUID().toString();
			moveBsaImportService.saveDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_RUNNING_CH, appsys_code2, appsys_code2 + " job Import ...", env);
			try {
				String message=(String) moveBsaImportService.BsaImport(uuid, appsys_code2, bsa2, userName, env.split(CommonConst.UNDERLINE)[1].toString(), envExp.split(CommonConst.UNDERLINE)[1].toString());
				if(("").equals(message) || message==null){
					moveBsaImportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_OK_CH, "");
				}else{
					moveBsaImportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, message);
					modelMap.addAttribute("success", Boolean.FALSE);
					return modelMap;
				}
			} catch (Throwable e) {
				moveBsaImportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
			}
		}
		
		//导入BRPM.
		if((brpm2 != null) && (brpm2.length() != 0)){
			//brpm用户check
			requestor_id = moveBrpmImportService.checkBrpmUser(userName, uuids);
			if(requestor_id.equals("")){
				for(int i=0;i<doGetFilesNamelist.length;i++){
					uuid=uuidBrpmMap.get(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0]);
					moveBrpmImportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, "当前用户在BRPM中不存在，请联系平台管理员！");
				}
			}else if((!requestor_id.equals(""))&&doGetFilesNamelist.length>0){
				moveBrpmImportService.BrpmImport(doGetFilesNamelist,uuidBrpmMap,appsys_code2, brpm2, env, userName, requestor_id, envExp.split(CommonConst.UNDERLINE)[1].toString());
			}
		}
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
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		
		try {
			Object sysIDs = moveBrpmImportService.querySystemIDAndNamesByUser(securityUtils.getUser().getUsername());
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
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		try {
			//Object queryEnv = moveBrpmImportService.queryEnv(securityUtils.getUser().getUsername());
			Object queryEnv = moveBrpmImportService.queryEnv(appsysCode,securityUtils.getUser().getUsername());

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
	 * 查询用户关联应用系统列表
	 * @param response
	 */
	@RequestMapping(value = "/queryExpEnv", method = RequestMethod.GET)
	public @ResponseBody void queryExpEnv(@RequestParam(value = "env", required = false) String env,HttpServletResponse response){
		
		
		
		PrintWriter out = null;
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
		try {
			Object queryEnv = moveBrpmImportService.queryExpEnv(env);
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
	 * stepCheckDB
	 * @throws Exception 
	 * allappDbCheck
	 */
	@RequestMapping(value = "/bsaCheck", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap bsaCheck(
			@RequestParam(value = "appsys_code2", required = false) String appsys_code,
			@RequestParam(value = "envExp", required = false) String envExp,  
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		
		//多用户导入单系统检查.
		String BSACheckMsg = "";
		String env =envExp.split(CommonConst.UNDERLINE)[1].toString();
		boolean bsa = moveBrpmImportService.ftpgetBSAs(appsys_code,env, "bsa");
		
		boolean para = moveBrpmImportService.ftpgetBSAs(appsys_code,env, "para");
		
		if(bsa&&para){
			BSACheckMsg="success";
		}else{
			BSACheckMsg="error";
		}
		modelMap.addAttribute("success", BSACheckMsg);
		return modelMap;
	}
}



package com.nantian.dply.controller;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

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
import com.nantian.common.util.CommonConst;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.DplyExcuteStatusService;
import com.nantian.dply.service.MoveBrpmExportService;
import com.nantian.dply.service.MoveBsaExportService;
import com.nantian.dply.vo.DplyExcuteStatusVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
/**
 * @author <a href="mailto:liruihao@nantian.com.cn"></a>
 * 应用发布迁移导出
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/moveexport")
public class MoveExportController {
	
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(AppInfoController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "move_export";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/move/" + domain;
	
	@Autowired
	private MoveBrpmExportService moveBrpmExportService;
	
	@Autowired
	private MoveBsaExportService moveBsaExportService;
	
	@Autowired
	private DplyExcuteStatusService dplyExcuteStatusService;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	/**
	 * 返回应用发布迁移导出页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix ;
	}
	
	/**
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/info", method = RequestMethod.GET)
	public String info() throws JEDAException {
		return "dply/move/move_info";
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return "dply/move/move_view";
	}
	
	/**
	 * 返回查看数据
	 * 
	 * @return 查看页面视图数据
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(
			@RequestParam(value = "entryId", required = false) String entryId,
			HttpServletRequest request,ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
			modelMap.clear();
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,moveBrpmExportService.findByPrimaryKey(entryId));
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
	@RequestMapping(value = "/info", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "userId", required = false) String userId,
			@RequestParam(value = "excuteStartTime", required = false) String excuteStartTime,
			@RequestParam(value = "excuteEndTime", required = false) String excuteEndTime,
			@RequestParam(value = "moveStatus", required = false) String moveStatus,
			@RequestParam(value = "operateType", required = false) String operateType,
			@RequestParam(value = "operateSource", required = false) String operateSource,
			@RequestParam(value = "environment", required = false) String environment,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,InvalidDataAccessResourceUsageException,SQLGrammarException,Exception {
		    modelMap=new ModelMap();//entryId,appsysCode,userId,excuteStartTime,excuteEndTime,moveStatus,operateTyep,operateSource,operateLog
		    /*Map<String, Object> params = RequestUtil.getQueryMap(request,moveExportService.fields);*/
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,moveBrpmExportService.queryDplyExctueStatus(start,limit,sort,dir,appsysCode,userId,excuteStartTime,excuteEndTime,moveStatus,operateType,operateSource,environment));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,moveBrpmExportService.count(appsysCode,userId,excuteStartTime,excuteEndTime,moveStatus,operateType,operateSource,environment));
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 批量删除用户标示
	 * 
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(
			@RequestParam(value = "entryId", required = true) String[] entryId,
			
			ModelMap modelMap) throws JEDAException, SQLException {
		
			moveBrpmExportService.editByIds(entryId);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	/**
	 * 查询系统
	 * 
	 * 
	 */
	@RequestMapping(value = "/getCmnAppInfo", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getCmnAppInfo(HttpServletRequest request,ModelMap modelMap)throws JEDAException,SQLException{
		
		modelMap.addAttribute("CmnAppInfo", moveBrpmExportService.getCmnAppInfo());
		modelMap.addAttribute("success", Boolean.TRUE);

		return modelMap;
	}
	
	/**
	 * 从BRPM查询请求列表
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getRequest", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getRequest(@RequestParam(value = "appsys_code", required = false) String appsys_code,
			@RequestParam(value = "envExpId", required = false) String env,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, ParseException, IOException, BrpmInvocationException, URISyntaxException,Exception {
	
		modelMap.addAttribute("RequestInfo",moveBrpmExportService.getRequest(appsys_code,env));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 应用发布迁移导出功能
	 * @throws Exception 
	 * 
	 */
	@RequestMapping(value = "/dplyExport", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap dplyExport(
			@RequestParam(value = "appsys_code", required = false) String appsys_code,
			@RequestParam(value = "env", required = false) String env,      
			@RequestParam(value = "brpm", required = false) String brpm,
			@RequestParam(value = "bsa", required = false) String bsa,
			@RequestParam(value = "tranItemS", required = false) String tranItemS,
			HttpServletRequest request, ModelMap modelMap) throws Exception
					{
		
		String uuid = null;
		modelMap.clear();
		
		String userName = securityUtils.getUser().getUsername();
		String[] doGetFilesNamelist = null;
		String requestor_id = "";
		Map<String,String> uuidBrpmMap = new HashMap<String,String>();
		String[] uuids = null;
		
		//多用户导入单系统检查.
		boolean mulUserDplySingSysCheck = moveBrpmExportService.mulUserDplySingSysCheck(appsys_code,env);
		if(mulUserDplySingSysCheck == false){
			modelMap.addAttribute("success", "mulUserDplySingSysCheck");
			return modelMap;
		}
		
		//单用户导入多系统数据字典开关检查.
		boolean singUserImpMulSysSwitchCheck = moveBrpmExportService.singUserDplyMulSysSwitchCheck();
		if(singUserImpMulSysSwitchCheck == false){
			//单用户导入多系统检查.
			boolean singUserDplyMulSysCheck = moveBrpmExportService.singUserImpMulSysCheck(userName,env);
			if(singUserDplyMulSysCheck == false){
				modelMap.addAttribute("success", "singUserDplyMulSysCheck");
				return modelMap;
			}
		}
		
		//访问brpm数据库查找请求.
		if((brpm != null) && (brpm.length() != 0)){
			doGetFilesNamelist = moveBrpmExportService.getRequestsInfo(appsys_code, tranItemS, brpm, userName);
			uuids = new String[doGetFilesNamelist.length];
			for(int i=0;i<doGetFilesNamelist.length&&doGetFilesNamelist[i]!=null;i++){
				uuid = UUID.randomUUID().toString();
				uuids[i] = uuid;
				uuidBrpmMap.put(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1], uuid);
				moveBrpmExportService.saveDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_WAIT_CH, appsys_code, doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[0],env);
			}
		}
		
		//导入BSA.
		if((bsa != null) && (bsa.length() != 0)){
			uuid = UUID.randomUUID().toString();
			moveBsaExportService.saveDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_RUNNING_CH, appsys_code, appsys_code + " job Export ...",env);
			try {
				moveBsaExportService.BsaExport(uuid, appsys_code, bsa,env.split(CommonConst.UNDERLINE)[1].toString());
				DplyExcuteStatusVo dExeVo = (DplyExcuteStatusVo) dplyExcuteStatusService.get(uuid);
				if(null != dExeVo && CommonConst.MOVESTATUS_RUNNING_CH.equals(dExeVo.getMoveStatus())){
					moveBsaExportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_OK_CH, "");
				}
			} catch (Exception e) {
				moveBsaExportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());
			}
		}
		
		//导入BRPM.
		if((brpm != null) && (brpm.length() != 0)){
			//brpm用户check
			requestor_id = moveBrpmExportService.checkBrpmUser(userName, uuids);
			if(requestor_id.equals("")){
				for(int i=0;i<doGetFilesNamelist.length;i++){
					uuid=uuidBrpmMap.get(doGetFilesNamelist[i].split(CommonConst.REPLACE_CHAR)[1].split(CommonConst.DOT)[0]);
					moveBrpmExportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, "当前用户在BRPM中不存在，请联系平台管理员！");
				}
			}else if((!requestor_id.equals(""))&&doGetFilesNamelist.length>0){
				//moveBrpmExportService.BrpmExport(doGetFilesNamelist,uuidBrpmMap,appsys_code, brpm,  userName, requestor_id);
				try {
					moveBrpmExportService.BrpmExport(doGetFilesNamelist,uuidBrpmMap, appsys_code, brpm,userName,env.split(CommonConst.UNDERLINE)[1].toString());
				} catch (Exception e) {
					moveBrpmExportService.updateDplyExcuteStatusVo(uuid, CommonConst.MOVESTATUS_ERR_CH, e.getMessage());

				} 
			}
		}
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
			@RequestParam(value = "appsys_code", required = false) String appsys_code,      
			@RequestParam(value = "brpm", required = false) String brpm,
			//@RequestParam(value = "bsa", required = false) String bsa,
			@RequestParam(value = "tranItemS", required = false) String tranItemS,
			HttpServletRequest request, ModelMap modelMap) throws Exception{
		
		//多用户导入单系统检查.
		String allappDbCheckMsg = "";
		String userName = securityUtils.getUser().getUsername();
		String[] doGetFilesNamelist = null;

		doGetFilesNamelist = moveBrpmExportService.getRequestsInfo(appsys_code, tranItemS, brpm, userName);

		allappDbCheckMsg = moveBrpmExportService.allappDbCheck(doGetFilesNamelist);
		if(!allappDbCheckMsg.equals("")){
			allappDbCheckMsg = "</br>" + allappDbCheckMsg + "</br>是否继续导出？";
		}
		modelMap.addAttribute("success", allappDbCheckMsg);
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
			Object sysIDs = moveBrpmExportService.querySystemIDAndNamesByUser(securityUtils.getUser().getUsername());
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
	
	
}

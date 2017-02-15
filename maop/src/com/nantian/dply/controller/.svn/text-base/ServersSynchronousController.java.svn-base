package com.nantian.dply.controller;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONArray;
import org.apache.axis2.AxisFault;
import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.service.ServersSynchronousService;
import com.nantian.dply.vo.ApposUserVo;
import com.nantian.dply.vo.CmnServerAgentApplyVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;


/**
 * 服务器信息检索
 */


@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/serverssynchronous")
public class ServersSynchronousController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(ServersSynchronousController.class);
	/** 模板管理领域对象名称 */
	private static final String domain = "servers";
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain+"_";

	@Autowired
	private ServersSynchronousService serversSynchronousService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	AppInfoService appInfoService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String upload() throws JEDAException {
		return viewPrefix + "sync_index";
	}
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/osuser", method = RequestMethod.GET)
	public String osupload() {
		return viewPrefix + "os_user";
	}
	/**
	 * 返回新建页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/createOsUser", method = RequestMethod.GET)
	public String createOsUser() {
		return viewPrefix + "os_user_create";
	}
	
	/**
	 * 返回编辑页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/viewOsUuser", method = RequestMethod.GET)
	public String viewOsUuser(@RequestParam("osUser") String osUser,
			@RequestParam("appsysCode") String appsysCode, 
			@RequestParam("serverIp") String serverIp,
			@RequestParam("userId") String userId
			) {
		return viewPrefix + "os_user_view";
	}
	
	/**
	 * 返回新建页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editOsUuser", method = RequestMethod.GET)
	public String editOsUuser(@RequestParam("osUser") String osUser,
			@RequestParam("appsysCode") String appsysCode, 
			@RequestParam("serverIp") String serverIp,
			@RequestParam("userId") String userId
			) {
		return viewPrefix + "os_user_edit";
	}
	
	/**
	 *获取操作用户信息
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/viewOsuser", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap viewOsuser(@RequestParam("osUser") String osUser,
			@RequestParam("appsysCode") String appsysCode, 
			@RequestParam("serverIp") String serverIp,
			@RequestParam("userId") String userId,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",serversSynchronousService.findById(osUser, appsysCode,serverIp,userId));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	

	
	/**
	 * 保存新建数据
	 * 
	 * @param osuser 数据对象
	 * @return
	 */
	@RequestMapping(value = "/editOsUuser", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editOsUuser(@ModelAttribute ApposUserVo osuser,
			ModelMap modelMap) throws JEDAException {
//		ModelMap modelMap = new ModelMap();
		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		osuser.setDeleteFlag("0");
		osuser.setUpdateTime(updateTime);
		serversSynchronousService.updateOsUser(osuser);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param osuser 数据对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/createOsUser", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap createOsUser(@ModelAttribute ApposUserVo osuser,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		List <ApposUserVo>  list =new ArrayList<ApposUserVo>();
		
		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String osUser =osuser.getOsUser();
		String appsysCode= osuser.getAppsysCode(); 
		String serverIp= osuser.getServerIp();
		String userId= osuser.getUserId();
		String   []userIds=userId.split(",");
		String   []serverIps=serverIp.split(",");
		for(int i=0;i<userIds.length;i++){
			for(int j=0;j<serverIps.length;j++){
			ApposUserVo Vo =new ApposUserVo();
			Vo.setAppsysCode(appsysCode);
			Vo.setDeleteFlag("0");
			Vo.setOsUser(osUser);
			Vo.setServerIp(serverIps[j]);
			Vo.setUpdateTime(updateTime);
			Vo.setUserId(userIds[i]);
			Vo.setDataType("H");
			list.add(Vo);
			}
		}
		serversSynchronousService.saveOrUpdateOsuser(list);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 批量删除用户标示
	 * 
	 * @param 
	 * @param 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/deleteOsUser", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteOsUser(
			@RequestParam(value = "osUsers", required = true) String[] osUsers,
			@RequestParam(value = "appsysCodes", required = true) String[] appsysCodes,
			@RequestParam(value = "serverIps", required = true) String[] serverIps,
			@RequestParam(value = "userIds", required = true) String[] userIds,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		serversSynchronousService.deleteByIds(osUsers, appsysCodes,serverIps,userIds);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	
	/**
	 * 查询服务器信息
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @param serverIp 服务器IP
	 * @param appsysCode 系统代码
	 * @param bsaAgentFlag BSA上线标示
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryServerlist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "serverIp", required = false) String serverIp,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "bsaAgentFlag", required = false) String bsaAgentFlag,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, serversSynchronousService.fields);
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					serversSynchronousService.queryserversSynchronousList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<ServersInfoVo>)request.getSession().getAttribute("ServersSynchronousList4Export")).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	/**
	 * 查询系统服务器用户信息

	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @param serverIp 服务器IP
	 * @param appsysCode 系统代码
	 * @param bsaAgentFlag BSA上线标示
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/osuser", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryOsuserlist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "serverIp", required = false) String serverIp,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "bsaAgentFlag", required = false) String bsaAgentFlag,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, serversSynchronousService.fields);
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					serversSynchronousService.queryosuserList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<ServersInfoVo>)request.getSession().getAttribute("osUserList4Export")).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	
	/**
	 * 检查服务器是否安装Agent
	 * @throws Exception 
	 * @throws DataAccessException
	 *  @throws AxisFault 
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/agent", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryInstallationAgent(@RequestParam(value = "data", required = true) String data,HttpServletRequest request, ModelMap modelMap) 
			throws DataAccessException,AxisFault, Exception{
		
			JSONArray array = JSONArray.fromObject(data);
			//将json格式的数据转换成list对象 
			List<String> list = (List<String>) JSONArray.toCollection(array, String.class);
			
			String lastAgentInfo = serversSynchronousService.doAgent(list);
			if(lastAgentInfo.equals("")){
				modelMap.addAttribute("agentInfo",lastAgentInfo+"检测成功");
			}else{
				modelMap.addAttribute("agentInfo",lastAgentInfo+"<br>"+"不能被BSA纳管，请安装代理");
			}
			modelMap.addAttribute("success", Boolean.TRUE);
			
	
		return modelMap;
	}
	

	
	/**
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/apply", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "agent_apply";
	}
	
	/**
	 * 安装Agent申请
	 * @throws Exception 
	 * @throws DataAccessException
	 *  @throws AxisFault 
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/agentApply", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap agentApply(@ModelAttribute CmnServerAgentApplyVo cmnServerAgentApplyVo,
						HttpServletRequest request,
			            ModelMap modelMap) 
			throws DataAccessException,AxisFault, Exception{
			modelMap.clear();
			String data = cmnServerAgentApplyVo.getValue();
			String desc=cmnServerAgentApplyVo.getDescValue();
			JSONArray array = JSONArray.fromObject(data);
			List<String> list = (List<String>) JSONArray.toCollection(array, String.class);
			serversSynchronousService.saveServers(list,desc);
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
	/**
	 * 同步配置信息管理系统信息
	 * @return 
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/syncSmartGroup", method = RequestMethod.POST)
	public @ResponseBody ModelMap syncSmartGroup(ModelMap modelMap, HttpServletRequest request)
			throws DataAccessException ,FileNotFoundException,IOException, SQLException,FtpCmpException,DataException,Exception{
		
			//数据库中查询的信息			List<ServersInfoVo> serverList=serversSynchronousService.queryServer();
			
			//查询出BSA ALLServer中的服务器信息
			List<String> saServerList=serversSynchronousService.queryAllServers();
			
			//巡检作业自动添加服务器
			serversSynchronousService.doSynServer(serverList,saServerList);
			
			modelMap.addAttribute("success", Boolean.TRUE);
	
		return modelMap;
	}

	/**
	 * 同步配置服务器信息管理系统信息
	 * @return 
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/syncFromConfManagement", method = RequestMethod.POST)
	public @ResponseBody ModelMap syncFromConfManagement(ModelMap modelMap, HttpServletRequest request)
			throws DataAccessException ,FileNotFoundException,IOException, SQLException,FtpCmpException,DataException{
		
			//开始插入日志
		     Long logJnlNo =cmnLogService.logPaltform(1);
			//详细日志开始
		   	cmnDetailLogService.saveBydetailLog(logJnlNo,1,"1");
			List<ServersInfoVo> inputFileList = new ArrayList<ServersInfoVo>();
			StringBuilder errNum =new StringBuilder();
			StringBuilder Num =new StringBuilder();
			StringBuilder Path =new StringBuilder();
			//读取文件信息
			inputFileList = serversSynchronousService.readServersInfosFromFile(logJnlNo,errNum,Num,Path);
			//数据库中查询的信息
			List<ServersInfoVo> serverList=serversSynchronousService.queryServerInfo();
			
			//执行保存和更新
			serversSynchronousService.saveOrUpdateAdmin(inputFileList,serverList);
			
			//日志结束更新数据
			cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
			cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
			modelMap.addAttribute("success", Boolean.TRUE);
				modelMap.addAttribute("error", ComUtil.encodeCNString("同步成功"+Num+"条数据,<br>格式错误"+errNum.toString()+"条数据", "utf-8"));
				modelMap.addAttribute("errNum", errNum.toString());
				modelMap.addAttribute("Path", ComUtil.encodeCNString(Path.toString(), "utf-8"));
		return modelMap;
	}
	
	
	/**
	 * 返回错误信息页面
	 * 
	 * @return 查看页面视图名称
	 */
	@RequestMapping(value = "/errorlist", method = RequestMethod.GET)
	public String errorlist() throws JEDAException {
		return  "dply/servers/error_info";
	}
	
	/**
	 * 错误信息列表数据获取
	 * @param modelMap
	 * @return 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/errorlistdata", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap errorlistdata(
			@RequestParam("Path") String Path, 
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException, UnsupportedEncodingException {
		String Path2= java.net.URLDecoder.decode(Path,"utf-8");
		List<Map<String,String>> errorlistdata = serversSynchronousService.readErrorInfo(Path2,request);
			
			modelMap.addAttribute("data",errorlistdata);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	
	/**
	 * 返回修改页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editServersInfo", method = RequestMethod.GET)
	public String editServersInfo(
			@RequestParam("appsysCode") String appsysCode, 
			@RequestParam("serverIp") String serverIp
			
			) {
		return viewPrefix + "info_edit";
	}
	
	/**
	 * 根据服务器IP，应用系统获取服务器信息
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/viewServer", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap viewServer(
			@RequestParam("appsysCode") String appsysCode, 
			@RequestParam("serverIp") String serverIp,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",serversSynchronousService.findByServerId( appsysCode,serverIp));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 保存修改服务器数据
	 * 
	 * @param server 数据对象
	 * @return
	 */
	@RequestMapping(value = "/editServer", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editServer(@ModelAttribute ServersInfoVo server,
			ModelMap modelMap) throws JEDAException {
//		ModelMap modelMap = new ModelMap();
		modelMap.clear();

		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		server.setDeleteFlag("0");
		server.setUpdateTime(updateTime);
		serversSynchronousService.updateServer(server);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	/**
	 * 从同步sump信息
	 * @return 
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/sump", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap syncFromSump(ModelMap modelMap, HttpServletRequest request)  
			throws DataAccessException ,FileNotFoundException,IOException, SQLException,FtpCmpException{
			StringBuilder errNum =new StringBuilder();
			StringBuilder Num =new StringBuilder();
			StringBuilder Path =new StringBuilder();
			StringBuilder CheckError =new StringBuilder();
		    //开始插入日志
		    Long logJnlNo =cmnLogService.logPaltform(2);
			//详细日志开始
			cmnDetailLogService.saveBydetailLog(logJnlNo,2,"1");
			List<ApposUserVo> inputSumpList = new ArrayList<ApposUserVo>();
			//读取文件信息
			inputSumpList = serversSynchronousService.readApposUserFromFile(logJnlNo,errNum,Num,Path,CheckError);
			

			//数据库中查询的信息			List<ApposUserVo> ApposUserList=serversSynchronousService.queryApposUser();
			//执行保存和更新			serversSynchronousService.saveOrUpdateSump(inputSumpList,ApposUserList);
			
			//执行保存和更新用户系统表
			int strErrCount = serversSynchronousService.saveOrUpdateUserApp(inputSumpList,logJnlNo,Path,CheckError);
			
			//日志结束更新数据
			cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
			cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
			String msg = "<br>同步用户系统权限数据总数："+inputSumpList.size()+"<br>成功同步总数："+(inputSumpList.size()-strErrCount)+"<br>失败同步总数："+strErrCount+"(失败原因请查询日志文件)";
			modelMap.addAttribute("error", ComUtil.encodeCNString("文件格式正确"+Num+"条数据,<br>格式错误"+errNum.toString()+"条数据", "utf-8"));
			modelMap.addAttribute("errNum", errNum.toString());
			modelMap.addAttribute("Path", ComUtil.encodeCNString(Path.toString(), "utf-8"));
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("message", msg);
		
		return modelMap;
	}

	@RequestMapping(value = "/findip", method = RequestMethod.POST)
	public @ResponseBody void findip(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
		    ModelMap modelMap,HttpServletRequest request, HttpServletResponse response) throws JEDAException, IOException, SQLException {
			PrintWriter out = null;
			
			Object serIPs = serversSynchronousService.findServerIp(appsys_code);
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(serIPs));
		}
	
	@RequestMapping(value = "/findOsUser", method = RequestMethod.POST)
	public @ResponseBody void findOsUser(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
		    ModelMap modelMap,HttpServletRequest request, HttpServletResponse response) throws JEDAException, IOException, SQLException {
			PrintWriter out = null;
			
			Object serIPs = serversSynchronousService.findOsUser(appsys_code);
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(serIPs));
		}
	
	@RequestMapping(value = "/findUserId", method = RequestMethod.POST)
	public @ResponseBody void findUserId(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
		    ModelMap modelMap,HttpServletRequest request, HttpServletResponse response) throws JEDAException, IOException, SQLException {
			PrintWriter out = null;
			Object serIPs = serversSynchronousService.findUserId(appsys_code);
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(serIPs));
		}
	
	
	/**
	 * 导入服务器信息
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importServers", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap importServers(
			@RequestParam(value = "filePath", required = true) String filePath,
			HttpServletRequest request, ModelMap modelMap) throws Exception {
		   //开始插入日志
	       Long logJnlNo =cmnLogService.logPaltform(1);
	 	   //详细日志开始
	    	cmnDetailLogService.saveBydetailLog(logJnlNo,1,"1");
		   List<ServersInfoVo> ServerList= serversSynchronousService.getServerList(filePath,logJnlNo);
		 
		   List<ServersInfoVo> importServerList=serversSynchronousService.queryAllServersInfo();
			try {
				
				serversSynchronousService.importServers(importServerList,ServerList);
				//日志结束更新数据
				cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
				cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
				modelMap.addAttribute("success", Boolean.TRUE);
			} catch (Exception e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", e.getMessage());
			}
		 
		return modelMap;
}
	
	/**
	 * 下载模板文件
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/downloadserverImport", method = RequestMethod.GET)
	public String export(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		String downpath = System.getProperty("maop.root")+ File.separatorChar+"file"+ File.separatorChar+"serversImport.xls";
		
		modelMap.addAttribute("PATH", downpath);
		//返回servletName
		return "fileView";
	}
	
	
	/**
	 * 导出错误信息 结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/error_excel", method = RequestMethod.GET)
	public String error_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("errorRownumber", "错误行数");
		columns.put("errorType", "错误类型");
		columns.put("errorData", "错误数据");
		
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("ErrorExport");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
	/**
	 * 导出查询服务器结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/servers_excel", method = RequestMethod.GET)
	public String servers_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("serverIp", messages.getMessage("property.serverIp"));
		columns.put("serverName", messages.getMessage("property.serverName"));
		columns.put("appsysCode", messages.getMessage("property.appsysCode"));
		columns.put("bsaAgentFlag", messages.getMessage("property.bsaAgentFlag"));
		columns.put("floatingIp", messages.getMessage("property.floatingIp"));
		columns.put("osType", messages.getMessage("property.osType"));
		columns.put("mwType", messages.getMessage("property.mwType"));
		columns.put("dbType", messages.getMessage("property.dbType"));
		columns.put("collectionState", messages.getMessage("property.collectionState"));
		columns.put("environmentType", messages.getMessage("property.environmentType"));
		columns.put("machineroomPosition", messages.getMessage("property.machineroomPosition"));
		columns.put("serverRole", messages.getMessage("property.serverRole"));
		columns.put("serverUse", messages.getMessage("property.serverUse"));
		columns.put("dataType", messages.getMessage("property.dataType"));
		
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("ServersSynchronousList4Export");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
	
	/**
	 * 导出查询操作用户结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/osuser_excel", method = RequestMethod.GET)
	public String osuser_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("appsysCode", messages.getMessage("property.appsysCode"));
		columns.put("serverIp", messages.getMessage("property.serverIp"));
		columns.put("osUser", messages.getMessage("property.osUser"));
		columns.put("userId", messages.getMessage("property.userId"));
		columns.put("dataType", messages.getMessage("property.dataType"));
		
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("osUserList4Export");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}

}

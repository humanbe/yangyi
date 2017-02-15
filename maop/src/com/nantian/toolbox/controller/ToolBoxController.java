package com.nantian.toolbox.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.UnknownHostException;
import java.sql.Blob;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateSystemException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.check.controller.JobDesignController;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtpConst;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.toolbox.service.ToolBoxParamService;
import com.nantian.toolbox.service.ToolBoxServerService;
import com.nantian.toolbox.service.ToolBoxService;
import com.nantian.toolbox.vo.OccToolBoxFilesVo;
import com.nantian.toolbox.vo.ToolBoxDescInfoVo;
import com.nantian.toolbox.vo.ToolBoxEventGroupInfoVo;
import com.nantian.toolbox.vo.ToolBoxExtendAttriVo;
import com.nantian.toolbox.vo.ToolBoxFilesVo;
import com.nantian.toolbox.vo.ToolBoxInfoVo;
import com.nantian.toolbox.vo.ToolBoxKeyWordInfoVo;
import com.nantian.toolbox.vo.ToolBoxParamInfoVo;
import com.nantian.toolbox.vo.ToolBoxScriptInfoVo;

@Controller
@RequestMapping("/" + Constants.APP_PATH + "/ToolBoxController")
public class ToolBoxController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(JobDesignController.class);

	/** 监控领域对象名称 */
	private static final String domain = "toolbox";
	/** 视图前缀 */
	private static final String viewPrefix = domain + "/" + domain+"_";
	
	@Autowired
	private ToolBoxService toolBoxService;
	@Autowired
	private ToolBoxParamService toolBoxParamService;
	@Autowired
	private ToolBoxServerService toolBoxServerService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	private CmnLogService cmnLogService;
	/**
	 * 注册Editor
	 * 
	 * @param binder
	 */
	@InitBinder
	public void initBinder(WebDataBinder binder) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(
				dateFormat, true));
	}

	/**
	 * 返回工具箱主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excindex", method = RequestMethod.GET)
	public String excindex() throws JEDAException {
		
		return  viewPrefix+ "excindex";
	}
	/**
	 * 返回工具箱导出主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/exportindex", method = RequestMethod.GET)
	public String exportindex() throws JEDAException {
		
		return  viewPrefix+ "exportindex";
	}
	/**
	 * 返回工具箱导入主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/importindex", method = RequestMethod.GET)
	public String importindex() throws JEDAException{
		
		return  viewPrefix+ "importindex";
	}
	/**
	 * 返回工具箱接收工具主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/receiveindex", method = RequestMethod.GET)
	public String receiveindex() throws JEDAException {
		
		return  viewPrefix+ "receiveindex";
	}
	
	/**
	 * 返回工具箱主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		
		return  viewPrefix+ "index";
	}
	
	/**
	 * 返回工具一线工具执行主界面
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/frontlineexcindex", method = RequestMethod.GET)
	public String frontlineexcindex() throws JEDAException {
		
		return  viewPrefix+ "frontlineexcindex";
	}

	/**
	 * 返回执行界面 
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Exc", method = RequestMethod.GET)
	public String Exc(@RequestParam("tool_code") String tool_code,
			@RequestParam("appsys_code") String appsys_code, 
			@RequestParam("usercode") String usercode,
			@RequestParam("os_type") String os_type,
			@RequestParam("event_id") String event_id
			) throws JEDAException {

		return viewPrefix + "exc";
	}
	/**
	 * 返回执行界面 
	 * 
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excDesc", method = RequestMethod.GET)
	public String excDesc(@RequestParam("tool_code") String tool_code,
			@RequestParam("appsys_code") String appsys_code, 
			@RequestParam("usercode") String usercode,
			@RequestParam("os_type") String os_type,
			@RequestParam("event_id") String event_id
			) throws JEDAException {
		//插入执行日志表
				Date startDate = new Date();
				String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

				String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
				String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
				CmnLogVo cmnLog = new CmnLogVo(); 
				cmnLog.setAppsysCode(appsys_code);
				cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
				cmnLog.setRequestName(tool_code+"_exc");
				cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
				cmnLog.setAuthorizedUser(usercode);
				cmnLog.setEvent_id(event_id);
				cmnLog.setExecStatus(logState);
				cmnLog.setExecDate(execdate);
				cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
				Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
				cmnLog.setExecCompletedTime(ts);
				cmnLog.setExecCreatedTime(ts);
				cmnLog.setExecUpdatedTime(ts);
				cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
				cmnLogService.save(cmnLog);
		return viewPrefix + "excdesc";
	}	
	
	/**
	 * 获取授权用户信息
	 * 
	 */

	@RequestMapping(value = "/getDyn_user", method = RequestMethod.POST)
	public @ResponseBody void getDyn_user(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		PrintWriter out = null;
		Object names = toolBoxService.getDynuser(appsys_code);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}

	
	/**
	 * 获取登陆用户信息
	 * 
	 */

	@RequestMapping(value = "/getUserName", method = RequestMethod.POST)
	public @ResponseBody void getUserName(
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException
			{
		Set<Role> userRole = securityUtils.getUser().getRoles() ;
		String username = securityUtils.getUser().getUsername() ; 
		String  rolename=null;
		String  userID=null;
		for (Role role : userRole) {
			rolename=role.getName();
			userID=role.getId();
		}
		List<Map<String, Object>> list =new ArrayList<Map<String, Object>>();
		Map<String, Object> map = new HashMap<String,Object>();
		map.put("UName", username);
		map.put("RoleName", rolename);
		map.put("UId", userID);
		list.add(map);
		PrintWriter out = null;
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(list));
	}
	
	
	
	/**
	 * 获取执行用户信息
	 * 
	 */

	@RequestMapping(value = "/getOs_user", method = RequestMethod.POST)
	public @ResponseBody void getOsuser(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
			@RequestParam(value = "serverips", required =false )String serverips,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		String username = securityUtils.getUser().getUsername() ;
		PrintWriter out = null;
		Object names = toolBoxService.getOsuser(appsys_code,username,serverips);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取服务器操作服务器用户信息，返回[os_user]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getServerOs_user", method = RequestMethod.POST)
	public @ResponseBody void getServerOs_user(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
			@RequestParam(value = "serverips", required =false )String serverips,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
	
		PrintWriter out = null;
		Object names = toolBoxService.getServerOs_user(appsys_code,serverips);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取操作组用户信息，返回[os_user]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getGroupOsuser", method = RequestMethod.POST)
	public @ResponseBody void getGroupOsuser(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getGroupOsuser(appsys_code);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	/**
	 * 获取分组信息，返回[serrver_group]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/findGroup", method = RequestMethod.POST)
	public @ResponseBody void findGroup(
			@RequestParam(value = "appsys_code", required =false )String appsys_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.findGroup(appsys_code);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取专业领域分类一级信息，返回[field_type_one]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getFTone", method = RequestMethod.POST)
	public @ResponseBody void getFTone(
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getFTone();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取专业领域分类二级信息，返回[field_type_two]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getFTtwo", method = RequestMethod.POST)
	public @ResponseBody void getFTtwo(
			@RequestParam(value = "field_type_one" )String field_type_one,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getFTtwo(field_type_one);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	
	/**
	 * 获取专业领域分类三级信息，返回[field_type_three]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getFTthree", method = RequestMethod.POST)
	public @ResponseBody void getFTthree(
			@RequestParam(value = "field_type_one" )String field_type_one,
			@RequestParam(value = "field_type_two" )String field_type_two,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getFTthree(field_type_one,field_type_two);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	

	
	@RequestMapping(value = "/AlarmViewtoolListindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap AlarmViewtoolList(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam(value = "policy_old_name" ) String policy_old_name,
			@RequestParam(value = "policy_code" ) String policy_code,
			
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryToolboxAlarmtoolListInfo(start, limit, sort, dir, params,policy_code,policy_old_name));
			modelMap.addAttribute("count", toolBoxService.queryToolboxAlarmtoolListInfoCount(start, limit, sort, dir, params,policy_code,policy_old_name).size());
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	/**
	 * 加载工具箱数据


	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 *            起始记录行

	 * @param limit
	 *            查询记录数

	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryToolboxInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryToolboxInfo(start, limit, sort, dir, params,request));
			long l=	toolBoxService.queryToolboxInfoCount(params);
			modelMap.addAttribute("count",l );
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	


	/**
	 * 加载工具箱数据



	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 *            起始记录行


	 * @param limit
	 *            查询记录数


	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/receiveindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryToolboxreceiveInfo(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryToolboxreceiveInfo(start, limit, sort, dir, params));
			modelMap.addAttribute("count", toolBoxService.queryToolboxreceiveInfoCount(start, limit, sort, dir, params).size());
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	
	/**
	 * 返回工具箱创建页面


	 * @throws JEDAException
	 */
	@RequestMapping(value = "/createAllinfo", method = RequestMethod.GET)
	public String createAllinfo() throws JEDAException {
		return viewPrefix + "allInfo";
	}

	
	/**
	 * 返回工具箱创建页面


	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		return viewPrefix + "create";
	}
	/**
	 * 返回工具箱创建页面


	 * @throws JEDAException
	 */
	@RequestMapping(value = "/createDesc", method = RequestMethod.GET)
	public String createDesc() throws JEDAException {
		return viewPrefix + "createdesc";
	}

	/**
	 * 保存新建数据
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/createDesc", method = RequestMethod.POST)
	public  @ResponseBody
	ModelMap createDesc(	@ModelAttribute ToolBoxInfoVo toolBoxInfoVo,
			@ModelAttribute ToolBoxDescInfoVo toolBoxDescInfoVo,
			@ModelAttribute ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			@ModelAttribute ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException, SQLException{
		modelMap.clear();
		ToolBoxExtendAttriVo attriVo=new ToolBoxExtendAttriVo();
		String uname =securityUtils.getUser().getUsername();
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String appsyscode = toolBoxInfoVo.getAppsys_code();
		String toolcode=toolBoxInfoVo.getTool_code();
		
		toolBoxInfoVo.setTool_code(toolcode);
		toolBoxInfoVo.setDelete_flag("0");
		toolBoxInfoVo.setTool_creator(uname);
		toolBoxInfoVo.setTool_modifier(uname);
		toolBoxInfoVo.setTool_created_time(Timestamp.valueOf(created_time.concat(".000").toString()));
		toolBoxInfoVo.setTool_updated_time(Timestamp.valueOf(created_time.concat(".000").toString()));
		
		attriVo.setTool_code(toolcode);
		attriVo.setTool_status("0");
		
		if(null!=toolBoxKeyWordInfoVo.getSummarycn()&&toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			toolBoxKeyWordInfoVo.setTool_code(toolcode);
		}
		
		if(null!=toolBoxEventGroupInfoVo.getEvent_group()&&toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			toolBoxEventGroupInfoVo.setTool_code(toolcode);
		}
		if(toolBoxDescInfoVo.getTool_content().toString().length()>0){
			String tool_content=toolBoxDescInfoVo.getTool_content();
			if(tool_content.indexOf("<A href=\"http")!=-1){
				tool_content=tool_content.replaceAll("<A href=\"http", "<A target=\"_blank\" href=\"http");
			}
			toolBoxDescInfoVo.setTool_content(tool_content);
			toolBoxDescInfoVo.setTool_code(toolcode);
		}
		toolBoxService.saveDesc(appsyscode,toolcode,attriVo,toolBoxInfoVo,toolBoxDescInfoVo,toolBoxEventGroupInfoVo,toolBoxKeyWordInfoVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}

	/**
	 * 保存新建数据
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	void saveCreate(	@ModelAttribute ToolBoxInfoVo toolBoxInfoVo,
			@ModelAttribute ToolBoxScriptInfoVo toolBoxScriptInfoVo,
			@ModelAttribute ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			@ModelAttribute ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException{
		modelMap.clear();
		String uploadPath = null;	
		PrintWriter resOut = response.getWriter();
			try {
				   String uname = securityUtils.getUser().getUsername();
					//取得上传工具
					ServletContext servletContext = request.getSession().getServletContext();
					String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
							
					DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
					Iterator<?> fileNames = multipartRequest.getFileNames();
					String fileTxt = "";
					MultipartFile multiFile = null;

					if (fileNames.hasNext()) {

						String fileName = (String) fileNames.next();
						multiFile = multipartRequest.getFile(fileName);

						if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
							fileTxt = multiFile.getOriginalFilename();
						} else {
							fileTxt = new String(multiFile.getOriginalFilename()
									.getBytes("GBK"), ComUtil.charset);
						}
						if (fileTxt.length() > 0) {
							uploadPath = toolPath +File.separatorChar+ fileTxt;
							InputStream in = null;
							FileOutputStream out = null;

							int len = 0;
							File outDir = new File(toolPath);

							if (!outDir.exists()) {
								outDir.mkdirs();
							}

							for (File tmpFile : outDir.listFiles()) {
								tmpFile.delete();
							}

							in = multiFile.getInputStream();

							out = new FileOutputStream(uploadPath);
							byte[] buf = new byte[1024];
							while ((len = in.read(buf)) != -1) {
								out.write(buf, 0, len);

							}

							if (in != null) {
								in.close();
							}
							if (out != null) {
								out.flush();
								out.close();
							}
						}
					}
					
				String shellname;
				String sn;
				String toolcode;
				String t;
				Date startDate = new Date();
				String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
				
				
				
				ToolBoxExtendAttriVo attriVo=new ToolBoxExtendAttriVo();
				
				String paramjson = toolBoxInfoVo.getParamValue();
				String serverjson = toolBoxInfoVo.getServerValue();
				String appsyscode = toolBoxInfoVo.getAppsys_code();
				String os_user=toolBoxScriptInfoVo.getOs_user();
				String serverGroup=toolBoxScriptInfoVo.getServer_group();
				String os_type=toolBoxScriptInfoVo.getOs_type();
				
				if(null==serverGroup||"".equals(serverGroup)){
					
					t=toolBoxService.getOstype(os_type);
				}else{
					t=toolBoxService.getGroupName(serverGroup);
				}
				
				if(fileTxt.equals("")){
					shellname =toolBoxScriptInfoVo.getShell_name();
					
					
					sn=shellname.substring(0,shellname.lastIndexOf('.'));
				}else{
					 shellname=fileTxt;
					 sn=shellname.substring(0,shellname.lastIndexOf('.'));					
					 toolBoxScriptInfoVo.setShell_name(shellname);	
					 
				}
				toolBoxScriptInfoVo.setOs_user(os_user);
				
				toolcode =appsyscode+"_"+t+"_"+sn;
				toolBoxInfoVo.setTool_code(toolcode);
				
				toolBoxInfoVo.setDelete_flag("0");
				toolBoxInfoVo.setTool_creator(uname);
				toolBoxInfoVo.setTool_modifier(uname);
				toolBoxInfoVo.setTool_created_time(Timestamp.valueOf(created_time.concat(".000").toString()));
				toolBoxInfoVo.setTool_updated_time(Timestamp.valueOf(created_time.concat(".000").toString()));
				os_type=toolBoxService.getOstype(os_type);
				if(null==serverGroup||"".equals(serverGroup)){
		        
				}else{
					serverGroup=toolBoxService.getGroupName(serverGroup);
				}
				
				if(null!=toolBoxKeyWordInfoVo.getSummarycn()&&toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
					toolBoxKeyWordInfoVo.setTool_code(toolcode);
				}
				
				if(null!=toolBoxEventGroupInfoVo.getEvent_group()&&toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
					toolBoxEventGroupInfoVo.setTool_code(toolcode);
				}
				if(toolBoxScriptInfoVo.getShell_name().toString().length()>0){
					toolBoxScriptInfoVo.setTool_code(toolcode);
				}
				/*if(toolBoxScriptInfoVo.getShell_name().toString().length()>0){
					toolBoxScriptInfoVo.setTool_code(toolcode);
				}*/
				attriVo.setTool_code(toolcode);
				attriVo.setTool_status("0");
				JSONArray arrayparam = JSONArray.fromObject(paramjson);				          	   
				List<Map<String, Object>> paramlist = (List<Map<String, Object>>) JSONArray.toCollection(arrayparam, Map.class);	
				JSONArray arrayserver = JSONArray.fromObject(serverjson);
				List<String> serverlist = (List<String>) JSONArray.toCollection(arrayserver, String.class);
				 toolBoxService.saveCreate(toolBoxInfoVo, paramlist, serverlist,shellname,fileTxt,appsyscode,toolcode,serverGroup,os_type,
						                   attriVo,toolBoxScriptInfoVo,toolBoxEventGroupInfoVo,toolBoxKeyWordInfoVo);
				 modelMap.addAttribute("success", Boolean.TRUE);
				 resOut.write("{\"success\":true}");
			} catch (DataIntegrityViolationException e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
			}catch (SQLException ce) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage(ce.getClass().getSimpleName()));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(ce.getClass().getSimpleName()), "utf-8")+ "\"}");
			}catch(HibernateSystemException eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("HibernateSystemException"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("HibernateSystemException"), "utf-8") +"\"}");
			}catch(ComponentException eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("ComponentException"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("ComponentException"), "utf-8") +"\"}");
			}catch(Exception eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("Exception"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
			}
	}

	/**
	 * 返回查看工具页面
	 * 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "view";
	}
	
	/**
	 * 返回查看工具页面
	 * 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/viewDesc", method = RequestMethod.GET)
	public String viewDesc() throws JEDAException {
		return viewPrefix + "viewdesc";
	}

	/**
	 * 根据工具编号，应用系统获取工具属性

	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getViewInfo(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",toolBoxService.findById(tool_code, appsys_code));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	
	/**
	 * 返回编辑工具页面
	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editDesc", method = RequestMethod.GET)
	public String editDesc(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code
			) throws JEDAException {
		return viewPrefix + "editdesc";
	}
	
	
	/**
	 * 保存新建数据
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/editDesc", method = RequestMethod.POST)
	public  @ResponseBody
	ModelMap editDesc(	@ModelAttribute ToolBoxInfoVo toolBoxInfoVo,
			@ModelAttribute ToolBoxDescInfoVo toolBoxDescInfoVo,
			@ModelAttribute ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			@ModelAttribute ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException, SQLException{
		modelMap.clear();
		ToolBoxExtendAttriVo attriVo=new ToolBoxExtendAttriVo();
		String uname =securityUtils.getUser().getUsername();
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String appsyscode = toolBoxInfoVo.getAppsys_code();
		
		String toolcode=toolBoxInfoVo.getTool_code();
		
		toolBoxInfoVo.setTool_modifier(uname);
		toolBoxInfoVo.setTool_updated_time(Timestamp.valueOf(created_time.concat(".000").toString()));
		toolBoxInfoVo.setDelete_flag("0");
		
		attriVo.setTool_code(toolcode);
		attriVo.setTool_status("0");
		attriVo.setTool_received_user("");
		
		String tool_content=toolBoxDescInfoVo.getTool_content();
		if(tool_content.indexOf("<A href=\"http")!=-1){
			tool_content=tool_content.replaceAll("<A href=\"http", "<A target=\"_blank\" href=\"http");
		}
		toolBoxDescInfoVo.setTool_content(tool_content);
		if(toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			toolBoxKeyWordInfoVo.setTool_code(toolcode);
		}
		if(toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			toolBoxEventGroupInfoVo.setTool_code(toolcode);
		}
		
		toolBoxService.saveDescEdit(appsyscode,toolcode,attriVo,toolBoxInfoVo,toolBoxDescInfoVo,toolBoxEventGroupInfoVo,toolBoxKeyWordInfoVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 返回编辑工具页面
	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code
			) throws JEDAException {
		return viewPrefix + "edit";
	}
	
	/**
	 * 返回编辑工具监控关键字页面

	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/keywords", method = RequestMethod.GET)
	public String keywords(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code) throws JEDAException {
		return viewPrefix + "keywords";
	}

	/**
	 * 保存工具箱编辑数据

	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *          应用系统
	 * @return
	 * @throws IOException 
	 ** @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	void saveEdit(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			@ModelAttribute ToolBoxInfoVo toolBoxInfoVo,
			@ModelAttribute ToolBoxScriptInfoVo toolBoxScriptInfoVo,
			@ModelAttribute ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			@ModelAttribute ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo,
			HttpServletRequest request, HttpServletResponse response)
			throws JEDAException, IOException {
		PrintWriter resOut = null;
		String uploadPath = null;	
		resOut = response.getWriter();
		JSONObject json = new JSONObject();
		try {
			   String uname = securityUtils.getUser().getUsername() ;
				ServletContext servletContext = request.getSession().getServletContext();
				String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
				DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
				Iterator<?> fileNames = multipartRequest.getFileNames();
				String fileTxt = "";
				MultipartFile multiFile = null;

				if (fileNames.hasNext()) {

					String fileName = (String) fileNames.next();
					multiFile = multipartRequest.getFile(fileName);

					if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
						fileTxt = multiFile.getOriginalFilename();
					} else {
						fileTxt = new String(multiFile.getOriginalFilename()
								.getBytes("GBK"), ComUtil.charset);
					}
					if (fileTxt.length() > 0) {
						uploadPath = toolPath +File.separatorChar+ fileTxt;
						InputStream in = null;
						FileOutputStream out = null;

						int len = 0;
						File outDir = new File(toolPath);

						if (!outDir.exists()) {
							outDir.mkdirs();
						}
						for (File tmpFile : outDir.listFiles()) {
							tmpFile.delete();
						}
						in = multiFile.getInputStream();
						out = new FileOutputStream(uploadPath);
						byte[] buf = new byte[1024];
						while ((len = in.read(buf)) != -1) {
							out.write(buf, 0, len);
						}
						if (in != null) {
							in.close();
						}
						if (out != null) {
							out.flush();
							out.close();
						}
					}
				}

				
				ToolBoxExtendAttriVo attriVo=new ToolBoxExtendAttriVo();
				
				
				String paramjson = toolBoxInfoVo.getParamValue();
				String serverjson = toolBoxInfoVo.getServerValue();
				String appsyscode = toolBoxInfoVo.getAppsys_code();
				String toolcode = toolBoxInfoVo.getTool_code();
				String shellname = toolBoxScriptInfoVo.getShell_name();
				String serverGroup=toolBoxScriptInfoVo.getServer_group();
				if(!(null==serverGroup||"".equals(serverGroup))){
				serverGroup=toolBoxService.getGroupName(serverGroup);
				}
				String os_type=toolBoxScriptInfoVo.getOs_type();
				os_type= toolBoxService.getOstype(os_type);
				
				Date startDate = new Date();
				String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
				toolBoxInfoVo.setTool_updated_time(Timestamp.valueOf(created_time.concat(".000").toString()));
				toolBoxInfoVo.setTool_modifier(uname);
				toolBoxInfoVo.setDelete_flag("0");
				
				attriVo.setTool_code(toolcode);
				attriVo.setTool_status("0");
				attriVo.setTool_received_user("");
				
				JSONArray arrayparam = JSONArray.fromObject(paramjson);				          	   
				List<Map<String, Object>> paramlist = (List<Map<String, Object>>) JSONArray.toCollection(arrayparam, Map.class);	
				
				JSONArray arrayserver = JSONArray.fromObject(serverjson);				          	   
				List<String> serverlist = (List<String>) JSONArray.toCollection(arrayserver, String.class);
				

				toolBoxService.saveEdit(toolBoxInfoVo, paramlist, serverlist,
						shellname,fileTxt,appsyscode,toolcode,serverGroup,os_type,attriVo,
						toolBoxScriptInfoVo,toolBoxEventGroupInfoVo,toolBoxKeyWordInfoVo);
 				json.put("success", true);
                resOut.print(json);
		} catch (Exception e) {
			try{
				json.put("success", false);
				json.put("error",ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8"));
				resOut.print(json);
			}catch(Exception oe){
				json.put("success", false);
				json.put("error", ComUtil.encodeCNString(messages.getMessage("HibernateSystemException"), "utf-8"));
				resOut.print(json);
			}
		}
		         

	}

	/**
	  批量修改授权级别
	 * 
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/updatetool_authorize_flag", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap updatetool_authorize_flag(
			@RequestParam(value = "appsyscodes", required = true) String[] appsyscodes,
			@RequestParam(value = "toolcodes", required = true) String[] toolcodes,
			@RequestParam(value = "tool_authorize_flag", required = true) String tool_authorize_flag,
			
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.updateAuthorizeflag(toolcodes, appsyscodes,tool_authorize_flag);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}

	/**
	 * 批量导出工具
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	
	@RequestMapping(value = "/exporttools", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap exporttools(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "appsys_codes", required = true) String[] appsys_codes,
			@RequestParam(value = "server_groups") String[] server_groups,
			@RequestParam(value = "os_types") String[] os_types,
			@RequestParam(value = "shell_names") String[] shell_names,
			@RequestParam(value = "position_types") String[] position_types,
			@RequestParam(value = "tool_types", required = true) String[] tool_types,
			@RequestParam(value = "tool_names", required = true) String[] tool_names,
			ModelMap modelMap) throws NoSuchMessageException, Exception {
		    String username=securityUtils.getUser().getUsername() ;
		    toolBoxService.delAllexportFile(username);
		    toolBoxService.exporttoolstar(appsys_codes,tool_codes,server_groups,shell_names,position_types,username,os_types,tool_types);
		    for(int i = 0; i < tool_codes.length ; i++){
		    	   //生成数据库文件

		    	 String filename=appsys_codes[i].concat("_").concat(tool_types[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_codes[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_names[i]);
		    	    String toolfile= toolBoxService.exporttools(tool_codes[i], appsys_codes[i]);
				    toolBoxService.toolFile(toolfile,tool_codes[i],username,filename);
				    
				    if("1".equals(tool_types[i].toString())){
				    	    String toolScriptfile=toolBoxService.exporttoolScripts(tool_codes[i]);
						    toolBoxService.toolScriptFile(toolScriptfile, tool_codes[i],username,filename);
						    
						    
						    String toolparamfile= toolBoxParamService.exporttoolparams(tool_codes[i], appsys_codes[i]);
						    toolBoxParamService.toolparamFile(toolparamfile,tool_codes[i],username,filename);
						 // 从介质服务器获取脚本  
						    if(position_types[i].equals("1")){
						    toolBoxService.ftpGettarFile(username,tool_codes[i],filename);
						    }
				    }
				    if("2".equals(tool_types[i].toString())){
				    	     String toolDescfile=toolBoxService.exporttoolDescs(tool_codes[i]);
						    toolBoxService.toolDescFile(toolDescfile, tool_codes[i],username,filename);
						    String toolDescfiles=toolBoxService.exporttoolDescfiles(tool_codes[i]);
						    toolBoxService.toolDescFiles(toolDescfiles, tool_codes[i],username,filename);
						    
				    }
				    
				  
				   
				    String tooleventgroupfile=toolBoxService.exporttoolEventGroup(tool_codes[i]);
				    	  toolBoxService.toolEventgroupFile(tooleventgroupfile, tool_codes[i],username,filename);
				  
				    
				    String toolSummarycnfile=toolBoxService.exporttoolSummarycn(tool_codes[i]);
				    	 toolBoxService.toolSummarycnFile(toolSummarycnfile, tool_codes[i],username,filename);
				   
				    
				    String toolattri = toolBoxService.exporttoolattris(tool_codes[i]);
				    toolBoxService.toolAttriFile(toolattri,tool_codes[i],username,filename);
					
				    //将工具打成ZIP包

				    String zipFilePath=System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxExpPath")+File.separator +username;
				    String sourceFilePath=System.getProperty("maop.root") +File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator +username+File.separator+filename;
				   
				    toolBoxService.fileToZip(sourceFilePath, zipFilePath, filename,tool_codes[i]);
				    //上传到文件服务器
				    toolBoxService.exportToolstar(tool_codes[i],username);
				    
		    }
		    
		    toolBoxService.deltoolstar(username);
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
	
	
	/**
	 * ftp获取导入工具
	 * @throws IOException 
	 * 
	 */

	@RequestMapping(value = "/ftpgettools", method = RequestMethod.POST)
	public @ResponseBody ModelMap ftpgettools(
			ModelMap modelMap) throws FtpCmpException, IOException
			{
		toolBoxService.ftpGetFileList();
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}

	/**
	 * 获取导入脚本信息，返回[list]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws ParseException 
	 * @throws FtpCmpException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getToolslist", method = RequestMethod.POST)
	public @ResponseBody ModelMap getToolslist(
		   @RequestParam(value = "appsys_code", required = false) String appsys_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException, FtpCmpException, ParseException
			{
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("data",toolBoxService.getToolslist(appsys_code));
		
	    return modelMap;
	}
	/**
	 * 批量导入工具
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 * @throws IOException 
	 * @throws NoSuchMessageException 
	 * @throws DataException 
	 */
	@RequestMapping(value = "/importtools", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap importtools(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "appsys_codes", required = true) String[] appsys_codes,
			@RequestParam(value = "tool_types", required = true) String[] tool_types,
			@RequestParam(value = "tool_names", required = true) String[] tool_names,
			@RequestParam(value = "file_names", required = true) String[] file_names,
			ModelMap modelMap) 
			throws DataException, NoSuchMessageException, IOException, Exception {
		    String username=securityUtils.getUser().getUsername() ;
		 
		    for(int i = 0; i < tool_codes.length ; i++){
		  //  toolBoxService.unZip(username, tool_codes[i],file_names[i]);
		 String filename=appsys_codes[i].concat("_").concat(tool_types[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_codes[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_names[i]);
		    toolBoxService.ftpPutToolstar(username,tool_codes[i],filename);
		    
		     }
		    
		    toolBoxService.importtoolstar(username,tool_codes,appsys_codes,tool_types);
		    
		    for(int i = 0; i < tool_codes.length ; i++){
		    	String filename=appsys_codes[i].concat("_").concat(tool_types[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_codes[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_names[i]);
		     List<ToolBoxInfoVo> toolboxinfoList=toolBoxService.readToolBoxInfoVoFromFile(username,tool_codes[i],filename);
			 List<ToolBoxExtendAttriVo> toolboxextendattriList=toolBoxService.readToolBoxExtendAttriVoFromFile(username,tool_codes[i],filename); 
			 List<ToolBoxEventGroupInfoVo> toolboxeventgroupinfoList=toolBoxService.readToolBoxEventGroupInfoVoFromFile(username,tool_codes[i],filename);
			 List<ToolBoxKeyWordInfoVo> toolboxkeywordinfoList=toolBoxService.readToolBoxKeyWordInfoVoFromFile(username,tool_codes[i],filename);
			 List<ToolBoxScriptInfoVo> toolboxscriptinfoList=null;
			 List<ToolBoxDescInfoVo> toolboxdescinfoList=null;
			 List<ToolBoxParamInfoVo> toolboxparamList=null;
			 List<ToolBoxFilesVo> toolboxfileList=null;
			 if("1".equals(tool_types[i])){
				   toolboxparamList=toolBoxParamService.readToolBoxParamInfoVoFromFile(username,tool_codes[i],filename);
				  toolboxscriptinfoList=toolBoxService.readToolBoxScriptInfoVoFromFile(username,tool_codes[i],filename);
			 }
			 if("2".equals(tool_types[i])){
				 toolboxdescinfoList=toolBoxService.readToolBoxDescInfoVoFromFile(username,tool_codes[i],filename);
				 toolboxfileList=toolBoxService.readToolBoxFilesVoFromFile(username,tool_codes[i],filename);
			 }
			 
			 //执行保存和更新

			 toolBoxService.saveOrUpdateToolboxinfo(toolboxinfoList);
			 toolBoxService.saveOrUpdateToolboxextendattri(toolboxextendattriList);
			 toolBoxService.saveOrUpdateToolboxkeywordinfo(toolboxkeywordinfoList); 
			 toolBoxService.saveOrUpdateToolboxeventgroupinfo(toolboxeventgroupinfoList);
			 
			 
			 
			 if("1".equals(tool_types[i])){
				 toolBoxService.saveOrUpdateToolboxscriptinfo(toolboxscriptinfoList);
				 toolBoxParamService.saveOrUpdatetoolboxinfo(toolboxparamList);
				 toolBoxServerService.Delimporttoolboxserverinfo(tool_codes[i]);
				 
			 }
			 if("2".equals(tool_types[i])){
				 toolBoxService.saveOrUpdateToolboxdescinfo(toolboxdescinfoList);
				 toolBoxService.saveOrUpdateToolboxdescfilesinfo(toolboxfileList);
			 }
			 
			
		     }
		    
		    
		   //备份已导入的工具
		    for(int i = 0; i < tool_codes.length ; i++){
		    	String filename=appsys_codes[i].concat("_").concat(tool_types[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_codes[i]).concat(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE).concat(tool_names[i]);
			    toolBoxService.ftpDelToolstar(username,tool_codes[i],filename);
			     }
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
	/**
	 * 批量删除 标示
	 * 
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "appsys_codes", required = true) String[] appsys_codes,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.deleteByIds(tool_codes, appsys_codes);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}

	/**
	 * 批量删除附件
	 * 
	 * @param tool_codes
	 * @param file_ids
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/deleteFile", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteFile(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "file_ids", required = true) String[] file_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.deleteByfile_ids(tool_codes, file_ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	/**
	 * 返回执行日志界面 
	 *           
	 * @param toolcode
	 *        工具编号
	 * @param appsyscode
	 *        应用系统
	 * @param shellname
	 *        脚本名称
	 * @param osuser
	 *        操作用户 
	 * @param paramdata
	 *        参数
	 * @param serverips
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/exction", method = RequestMethod.GET)
	public String exction(@RequestParam("toolcode") String toolcode,
			@RequestParam("appsyscode") String appsyscode, 
			@RequestParam("position_type") String position_type,
			@RequestParam("shellname") String shellname,
			@RequestParam("osuser") String osuser,
			@RequestParam("group_osuser") String group_osuser,
			@RequestParam("serverGroup") String serverGroup,
			@RequestParam("usercode") String usercode,
			@RequestParam("event_id") String event_id,
			@RequestParam("os_type") String os_type,
			@RequestParam("toolcharset") String toolcharset,
			@RequestParam("paramdata") String paramdata,
			//@RequestParam("repetitions") String repetitions,
			//@RequestParam("time_interval") String time_interval,
			@RequestParam("serverips") String serverips) throws JEDAException {
	
		return viewPrefix+"runview";
	}
	
	/**
	 * 返回执行日志界面 
	 *           
	 * @param toolcode
	 *        工具编号
	 * @param appsyscode
	 *        应用系统
	 * @param shellname
	 *        脚本名称
	 * @param osuser
	 *        操作用户 
	 * @param paramdata
	 *        参数
	 * @param serverips
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/alarmexction", method = RequestMethod.GET)
	public String alarmexction(@RequestParam("toolcode") String toolcode,
			@RequestParam("appsyscode") String appsyscode, 
			@RequestParam("position_type") String position_type,
			@RequestParam("shellname") String shellname,
			@RequestParam("osuser") String osuser,
			@RequestParam("group_osuser") String group_osuser,
			@RequestParam("serverGroup") String serverGroup,
			@RequestParam("usercode") String usercode,
			@RequestParam("event_id") String event_id,
			@RequestParam("os_type") String os_type,
			@RequestParam("toolcharset") String toolcharset,
			@RequestParam("paramdata") String paramdata,
			//@RequestParam("repetitions") String repetitions,
			//@RequestParam("time_interval") String time_interval,
			@RequestParam("serverips") String serverips, ModelMap modelMap,
			HttpServletRequest request) throws JEDAException, UnsupportedEncodingException {

	
		return viewPrefix+"alarmrunview";
	}

	/**
	 * 执行脚本
	 *           
	 * @param toolcode
	 *        工具编号
	 * @param appsyscode
	 *        应用系统
	 * @param shellname
	 *        脚本名称
	 * @param osuser
	 *        操作用户 
	 * @param paramdata
	 *        参数
	 * @param serverips
	 * @return
	 * @throws IOException ,JEDAException
	 * @throws InterruptedException 
	 * @throws SQLException 
	 * @throws ArrayIndexOutOfBoundsException 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/run", method = RequestMethod.POST)
	@ResponseBody
	public void runShell(@RequestParam("toolcode") String toolcode,
			@RequestParam("appsyscode") String appsyscode,
			@RequestParam("position_type") String position_type,
			@RequestParam("serverips") String serverips,
			@RequestParam("shellname") String shellname,
			@RequestParam("osuser") String osuser,
			@RequestParam("serverGroup") String serverGroup,
			@RequestParam("os_type") String os_type,
			@RequestParam("usercode") String usercode,
			@RequestParam("event_id") String event_id,
			@RequestParam("toolcharset") String toolcharset,
			@RequestParam("group_osuser") String group_osuser,
			@RequestParam("paramdata") String paramdata,
			//@RequestParam("repetitions") String repetitions,
			//@RequestParam("time_interval") String time_interval,
			HttpServletRequest request, HttpServletResponse respons)
			throws JEDAException,IOException, InterruptedException, ArrayIndexOutOfBoundsException, SQLException {
		if(null==serverGroup||"".equals(serverGroup)){
			serverGroup="";
		}else{
			serverGroup=toolBoxService.getGroupName(serverGroup);
		}
		os_type=toolBoxService.getOstype(os_type);
		toolcharset=toolBoxService.getCharsetName(toolcharset);
		JSONArray array = JSONArray.fromObject( java.net.URLDecoder.decode(paramdata,"utf-8"));
		JSONArray arrayserverip = JSONArray.fromObject( java.net.URLDecoder.decode(serverips,"utf-8"));
		
		List<Map<String, Object>> list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
		List<Map<String, Object>> listServers = (List<Map<String, Object>>) JSONArray.toCollection(arrayserverip, Map.class);
		toolBoxService.shellexc(toolcode,list,shellname,listServers,osuser,appsyscode,group_osuser,position_type,serverGroup,toolcharset,os_type,usercode,event_id);
		//toolBoxService.shellexc(toolcode,list,shellname,listServers,osuser,appsyscode,group_osuser,position_type,serverGroup,toolcharset,os_type,usercode,event_id,repetitions,time_interval);
	}
	
	/**
	 * 获取日志
	 * @param row 行号
	 * @param server 服务器Ip
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws UnsupportedEncodingException
	 */
	@RequestMapping(value = "/runview", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap runview(
			@RequestParam("row") Integer row,
			@RequestParam("server") String server,
			@RequestParam("shellname") String shellname,
			HttpServletRequest request, ModelMap modelMap)
			throws JEDAException, UnsupportedEncodingException {
	    modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, toolBoxService.find(row, server,shellname));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}

	
	/**
	 *   返回动态口令界面 
	 *           
	 * @param toolcodes
	 *        工具编号
	 * @param appsyscodes
	 *        应用系统
	 * @return
	 * @throws JEDAException
	 * @throws UnknownHostException 
	 */
	@RequestMapping(value = "/isdynpassword", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap isdynpassword(
			@RequestParam("usercode") String usercode,
			@RequestParam("dynpassword") String dynpassword,
			@RequestParam("pinCode") String pinCode,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, UnknownHostException {
		Map<String, String> Map = toolBoxService.isDynPassword(usercode, dynpassword,pinCode);
		
	if(Map.get("error")!=null){
		modelMap.addAttribute("error", Map.get("error"));
		modelMap.addAttribute("success", Boolean.FALSE);	
	}else{
		modelMap.addAttribute("success", Boolean.TRUE);	
	}
		
		return modelMap;
	}
	
	/**
	 * 获取组件目录树数据

	 * @param appsysCode 应用系统编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getEventGroupTree", method = RequestMethod.POST)
	public void getServerTree(
			@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			HttpServletRequest request, HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
		
			
			dataList = toolBoxService.queryOneTree(appsys_code);
			
			jsonList = toolBoxService.buildEcentGroupTree(dataList,tool_code);
	

		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取工具目录树数据

	 * 
	 * @throws IOException 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/getToolTree", method = RequestMethod.POST)
	public void getToolTree(
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
			
			dataList = toolBoxService.querytooltype();
			jsonList = toolBoxService.buildToolTree(dataList);

		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 获取工具接收目录树数据
	 * @throws IOException 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/getToolTree2", method = RequestMethod.POST)
	public void getToolTree2(
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
			
			dataList = toolBoxService.querytooltype2();
			jsonList = toolBoxService.buildToolsTree(dataList);

		out = response.getWriter();
		out.print(jsonList);
    }
	
	/**
	 * 一线工具使用目录树数据
	 * @throws IOException 
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/getToolTree3", method = RequestMethod.POST)
	public void getToolTree3(
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<Map<String,Object>> dataList = null ;
			
			dataList = toolBoxService.querytooltype3();
			jsonList = toolBoxService.buildToolsTreeOne(dataList);

		out = response.getWriter();
		out.print(jsonList);
    }
	
	
	/**
	 * 批量修改交接状态标示 
	 * 
	 * @param tool_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/toolStatus", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap toolStatus(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.toolStatus(tool_codes );
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	/**
	 * 批量修改交接状态标示 
	 * 
	 * @param tool_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/received", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap received(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.receivedByIds(tool_codes );
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	/**
	 * 批量修改交接状态标示 
	 * 
	 * @param tool_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/returned", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap returned(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "tool_returnreasons") String tool_returnreasons,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.returnedByIds(tool_codes,tool_returnreasons);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	/**
	 * 加载工具箱一线数据



	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 *            起始记录行


	 * @param limit
	 *            查询记录数


	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/frontlineindex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryToolboxInfoFL(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		modelMap.clear();
		Map<String, Object> params = RequestUtil.getQueryMap(request,toolBoxService.fields);
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryToolboxInfoFL(start, limit, sort, dir, params));
			modelMap.addAttribute("count",toolBoxService.queryToolboxInfoFLCount(start, limit, sort, dir, params).size());
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	
	
	/**
	 * 获取脚本内容
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 */
	@RequestMapping(value = "/ftpScript", method = RequestMethod.POST)
	public @ResponseBody
	void ftpScript(	@ModelAttribute ToolBoxScriptInfoVo toolBoxScriptInfoVo,
			@ModelAttribute ToolBoxInfoVo toolBoxInfoVo,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException{
		modelMap.clear();
		
		PrintWriter resOut = response.getWriter();
			try {
				String uname = securityUtils.getUser().getUsername() ;
					//取得上传工具
					ServletContext servletContext = request.getSession().getServletContext();
					String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
					
					File outDir = new File(toolPath);

					if (!outDir.exists()) {
						outDir.mkdirs();
					}
					String script=toolBoxScriptInfoVo.getShell_name();
					String app=toolBoxInfoVo.getAppsys_code();
					String s_o;
					if(app.equals("COMMON")){
						s_o=toolBoxService.getOstype(toolBoxScriptInfoVo.getOs_type());
					}else{
						s_o=toolBoxService.getGroupName(toolBoxScriptInfoVo.getServer_group());
					}
				String downloadPath= toolPath+File.separatorChar + script;
					
				String 	chartset=toolBoxService.getCharsetName(toolBoxScriptInfoVo.getTool_charset());
				String  ftpPath=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+app+CommonConst.SLASH+s_o+CommonConst.SLASH+script;
				toolBoxService.ftpGetScript(downloadPath,ftpPath);
				
					modelMap.addAttribute("success", Boolean.TRUE);
					resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) this.queryText(downloadPath, chartset), "utf-8")+"\"}");
				}catch (DataIntegrityViolationException e) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
				}catch (AxisFault eo) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("AxisFault"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("AxisFault"), "utf-8")+ "\"}");
				}catch (FtpCmpException feo) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", ComponentFtpConst.ERROR_CANNOT_GET);
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString("要下载的文件不存在", "utf-8")+ "\"}");
				}catch(Exception eo)
				{
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("Exception"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
				}
			}
	
	
	/**
	 * 获取脚本内容
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 */
	@RequestMapping(value = "/getScript", method = RequestMethod.POST)
	public @ResponseBody
	void getScript(	@ModelAttribute ToolBoxScriptInfoVo toolBoxScriptInfoVo,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException{
		modelMap.clear();
		String uploadPath = null;	
		PrintWriter resOut = response.getWriter();
			try {
				String uname = securityUtils.getUser().getUsername() ;
					//取得上传工具
					ServletContext servletContext = request.getSession().getServletContext();
					String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
							
					DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
					Iterator<?> fileNames = multipartRequest.getFileNames();
					String fileTxt = "";
					MultipartFile multiFile = null;

					if (fileNames.hasNext()) {

						String fileName = (String) fileNames.next();
						multiFile = multipartRequest.getFile(fileName);

						if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
							fileTxt = multiFile.getOriginalFilename();
						} else {
							fileTxt = new String(multiFile.getOriginalFilename()
									.getBytes("GBK"), ComUtil.charset);
						}
						if (fileTxt.length() > 0) {
							uploadPath = toolPath +File.separatorChar+ fileTxt;
							InputStream in = null;
							FileOutputStream out = null;

							int len = 0;
							File outDir = new File(toolPath);

							if (!outDir.exists()) {
								outDir.mkdirs();
							}

							for (File tmpFile : outDir.listFiles()) {
								tmpFile.delete();
							}

							in = multiFile.getInputStream();

							out = new FileOutputStream(uploadPath);
							byte[] buf = new byte[1024];
							while ((len = in.read(buf)) != -1) {
								out.write(buf, 0, len);

							}

							if (in != null) {
								in.close();
							}
							if (out != null) {
								out.flush();
								out.close();
							}
						}
					}
					
				
				String 	chartset=toolBoxService.getCharsetName(toolBoxScriptInfoVo.getTool_charset());
				
					modelMap.addAttribute("success", Boolean.TRUE);
					resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) this.queryText(uploadPath, chartset), "utf-8")+"\"}");
				}catch (DataIntegrityViolationException e) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
				}catch (AxisFault eo) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("AxisFault"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("AxisFault"), "utf-8")+ "\"}");
				}catch(Exception eo)
				{
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("Exception"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
				}
			}
	
	/**
	 * 查看脚本内容
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object queryText(String toolFilePath, String chartset) throws Exception {
		int b;
		File file = new File(toolFilePath);
		FileInputStream in=new FileInputStream(file);
		StringBuilder Nr=new StringBuilder();
		InputStreamReader br = null;

			br = new InputStreamReader(in,chartset);	
		try {
			while ((b = br.read()) != -1) {
				Nr.append((char)b);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			br.close();
		}
		return Nr.toString();
	}
	
	
	/**
	 * 下载当前脚本
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/downloadfile", method = RequestMethod.GET)
	public String downloadfile(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("appsys_code") String appsys_code,
			@RequestParam("os_type") String os_type,
			@RequestParam("server_group") String server_group,
			@RequestParam("shell_name") String shell_name) throws JEDAException, SQLException {
		String uname = securityUtils.getUser().getUsername() ;
		String s_o;
		if(appsys_code.equals("COMMON")){
			s_o=toolBoxService.getOstype(os_type);
		}else{
			s_o=toolBoxService.getGroupName(server_group);
		}
		String downpath = System.getProperty("maop.root")+File.separator+messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.filedownloadPath")+ File.separatorChar+uname+File.separatorChar;
		File outDir = new File(downpath);

		if (!outDir.exists()) {
			outDir.mkdirs();
		}

		for (File tmpFile : outDir.listFiles()) {
			tmpFile.delete();
		}
		String downloadPath=downpath+shell_name;
		String ftppath=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+appsys_code+CommonConst.SLASH+s_o+CommonConst.SLASH+shell_name;
		toolBoxService.ftpGetScript(downloadPath,ftppath);
		modelMap.addAttribute("PATH",downloadPath );
		//返回servletName
		return "fileView";
	}
	
	
	
	
	/**
	 * 获取组件目录树数据


	 * @param appsysCode 应用系统编号
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getHistoryScript", method = RequestMethod.POST)
	public void getHistoryScript(
			@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			@RequestParam("shell_name") String shell_name,
			HttpServletRequest request, HttpServletResponse response) throws IOException{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		List<String> dataList = null ;
		
			//获取脚本目录
		dataList = toolBoxService.ftpgetHistoryTools(appsys_code,tool_code,shell_name);
			//获取服务器分组下的服务器IP，构建目录树
			jsonList = toolBoxService.buildHistoryStriptTree(dataList,tool_code);
		out = response.getWriter();
		out.print(jsonList);
    }
	
	
	/**
	 * 下载历史脚本
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@RequestMapping(value = "/downloadhistory", method = RequestMethod.GET)
	public String downloadhistory(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			@RequestParam("ScriptInfos") String ScriptInfos) throws JEDAException, SQLException, IOException {
		String uname = securityUtils.getUser().getUsername() ;
		String ftppath=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+messages.getMessage("toolbox.DBServerToolBak")+CommonConst.SLASH+appsys_code+CommonConst.SLASH;
		String downpath = System.getProperty("maop.root")+File.separator+messages.getMessage("toolbox.rootPath")+ File.separatorChar+messages.getMessage("toolbox.filedownloadPath")+ File.separatorChar+uname+File.separatorChar;
		
		String zipname=tool_code+".zip";
		String downZipPath=downpath+zipname;
		File outDir = new File(downpath);

		if (!outDir.exists()) {
			outDir.mkdirs();
		}

		for (File tmpFile : outDir.listFiles()) {
			tmpFile.delete();
		}
		String downloadPath="";
		String[] scripts=ScriptInfos.split("\\|");
		for(int i=0;i<scripts.length;i++){
			downloadPath=downpath+scripts[i];
			String ftppathName=ftppath+scripts[i];
			toolBoxService.ftpGetScript(downloadPath,ftppathName);
		}
		
		if(scripts.length==1){
		modelMap.addAttribute("PATH",downloadPath );
		}else{
			
			toolBoxService.scriptfileToZip(downpath,downpath,tool_code);
			modelMap.addAttribute("PATH",downZipPath );
			
		}
		//返回servletName
		return "fileView";
	}
	
	/*
	
	@RequestMapping(value = "/addImages", method = RequestMethod.POST)
			public @ResponseBody
			ModelMap addImages(HttpServletRequest request,
			    HttpServletResponse response,
			    ModelMap modelMap) throws Exception {
			   logger.info("上传图片");
			//   logger.info(json);
			   String uploadPath = null;
			   
			   ServletContext servletContext = request.getSession().getServletContext();
				String imagePath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath")+ File.separatorChar);
						
				DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
				Iterator<?> fileNames = multipartRequest.getFileNames();
				String fileTxt = "";
				MultipartFile multiFile = null;

				if (fileNames.hasNext()) {

					String fileName = (String) fileNames.next();
					multiFile = multipartRequest.getFile(fileName);

					if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
						fileTxt = multiFile.getOriginalFilename();
					} else {
						fileTxt = new String(multiFile.getOriginalFilename()
								.getBytes("GBK"), ComUtil.charset);
					}
					if (fileTxt.length() > 0) {
						uploadPath = imagePath +File.separatorChar+ fileTxt;
						InputStream in = null;
						FileOutputStream out = null;

						int len = 0;
						File outDir = new File(imagePath);

						if (!outDir.exists()) {
							outDir.mkdirs();
						}

						for (File tmpFile : outDir.listFiles()) {
							tmpFile.delete();
						}

						in = multiFile.getInputStream();

						out = new FileOutputStream(uploadPath);
						byte[] buf = new byte[1024];
						while ((len = in.read(buf)) != -1) {
							out.write(buf, 0, len);

						}

						if (in != null) {
							in.close();
						}
						if (out != null) {
							out.flush();
							out.close();
						}
					}
				}
				 modelMap.addAttribute("success", "true");
				 modelMap.addAttribute("imagePath",uploadPath);
				 return modelMap;
			}
	*/
	
	
	
	/**
	 * 加载工具箱数据
	 * 
	 * @param start
	 *            起始记录行

	 * @param limit
	 *            查询记录数

	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/tool_box_files", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap querytool_box_files(
			
			@RequestParam(value = "tool_code", required = false) String tool_code,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryToolBoxFiles(tool_code));
			long l=	toolBoxService.countToolBoxFiles(tool_code);
			modelMap.addAttribute("count",l );
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	/**
	 * 加载工具箱数据
	 * 
	 * @param start
	 *            起始记录行

	 * @param limit
	 *            查询记录数

	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/tool_box_files_occ", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap querytool_box_files_occ(
			
			@RequestParam(value = "tool_code", required = false) String tool_code,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		
		try {
			
			modelMap.addAttribute("data",
					toolBoxService.queryOccToolBoxFiles(tool_code));
			long l=	toolBoxService.countOccToolBoxFiles(tool_code);
			modelMap.addAttribute("count",l );
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
		}
		return modelMap;
	}
	
	
	
	/**
	 * 下载当前附件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@RequestMapping(value = "/downloadFiles", method = RequestMethod.GET)
	public String downloadFiles(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("file_id") String file_id,
			@RequestParam("tool_code") String tool_code,
			@RequestParam("file_type") String file_type,
			@RequestParam("file_name") String file_name) throws JEDAException, SQLException, IOException {
		
		Blob b=toolBoxService.queryToolBoxFileContent(tool_code, file_id);
		String userId=securityUtils.getUser().getUsername();
		String file =java.net.URLDecoder.decode(file_name,"utf-8")+"."+file_type;
		String uploadPath = System.getProperty("maop.root")+File.separator+"fujian"+File.separatorChar+userId;
		InputStream in = b.getBinaryStream();
		FileOutputStream out = null;

		int len = 0;
		File outDir = new File(uploadPath);

		if (!outDir.exists()) {
			outDir.mkdirs();
		}

		for (File tmpFile : outDir.listFiles()) {
			tmpFile.delete();
		}

		uploadPath = uploadPath+File.separatorChar+file;
		
		out = new FileOutputStream(uploadPath);
		byte[] buf = new byte[1024];
		while ((len = in.read(buf)) != -1) {
			out.write(buf, 0, len);
		}

		if (out != null) {
			out.flush();
			out.close();
		}
	
		modelMap.addAttribute("PATH",uploadPath);
		//返回servletName
		return "fileView";
	}
	/**
	 * 下载当前附件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@RequestMapping(value = "/downloadFilesById", method = RequestMethod.GET)
	public String downloadFiles(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("file_id") String file_id
			) throws JEDAException, SQLException, IOException {
		
		List<Map<String, Object>> list =toolBoxService.queryToolBoxFile(file_id);
		
        Blob b= (Blob) list.get(0).get("file_content");
		
		String file_name=list.get(0).get("file_name").toString();
		String file_type=list.get(0).get("file_type").toString();
		
		String userId=securityUtils.getUser().getUsername();
		
		String file =file_name.concat(".").concat(file_type) ;
		String uploadPath = System.getProperty("maop.root")+File.separator+"fujian"+File.separatorChar+userId;
		InputStream in = b.getBinaryStream();
		FileOutputStream out = null;

		int len = 0;
		File outDir = new File(uploadPath);

		if (!outDir.exists()) {
			outDir.mkdirs();
		}

		for (File tmpFile : outDir.listFiles()) {
			tmpFile.delete();
		}

		uploadPath = uploadPath+File.separatorChar+file;
		
		out = new FileOutputStream(uploadPath);
		byte[] buf = new byte[1024];
		while ((len = in.read(buf)) != -1) {
			out.write(buf, 0, len);
		}

		if (out != null) {
			out.flush();
			out.close();
		}
	
		modelMap.addAttribute("PATH",uploadPath);
		//返回servletName
		return "fileView";
	}
	
	
	/**
	 * 下载当前临时附件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@RequestMapping(value = "/downloadOccFiles", method = RequestMethod.GET)
	public String downloadOccFiles(HttpServletRequest request, ModelMap modelMap,
			@RequestParam("file_id") String file_id,
			@RequestParam("tool_code") String tool_code,
			@RequestParam("file_type") String file_type,
			@RequestParam("file_name") String file_name) throws JEDAException, SQLException, IOException {
		
		Blob b=toolBoxService.queryOccToolBoxFileContent(tool_code, file_id);
		String userId=securityUtils.getUser().getUsername();
		String file =java.net.URLDecoder.decode(file_name,"utf-8")+"."+file_type;
		String uploadPath = System.getProperty("maop.root")+File.separator+"fujian"+File.separatorChar+userId;
		InputStream in = b.getBinaryStream();
		FileOutputStream out = null;

		int len = 0;
		File outDir = new File(uploadPath);

		if (!outDir.exists()) {
			outDir.mkdirs();
		}

		for (File tmpFile : outDir.listFiles()) {
			tmpFile.delete();
		}

		uploadPath = uploadPath+File.separatorChar+file;
		
		out = new FileOutputStream(uploadPath);
		byte[] buf = new byte[1024];
		while ((len = in.read(buf)) != -1) {
			out.write(buf, 0, len);
		}

		if (out != null) {
			out.flush();
			out.close();
		}
	
		modelMap.addAttribute("PATH",uploadPath);
		//返回servletName
		return "fileView";
	}
	
	
	/**
	 * 获取描述工具 toolcode
	 * 
	 */

	@RequestMapping(value = "/getDesc_toolcode", method = RequestMethod.POST)
	public @ResponseBody void getDesc_toolcode(
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		PrintWriter out = null;
		Object toolcode = toolBoxService.findTooldescSeqMap();
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(toolcode));
	}
	
	@RequestMapping(value = "/addFile", method = RequestMethod.POST)
	public @ResponseBody
	void addFile(
			@RequestParam(value = "tool_code", required =false )String tool_code,
			@RequestParam("uploadPath") String uploadPath,
			@RequestParam("file_name") String file_name,
			@RequestParam("file_type") String file_type,
			HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		modelMap.clear();
		String fileuploadPath = null;	
		PrintWriter resOut = response.getWriter();
			try {
				   String uname = securityUtils.getUser().getUsername();
					//取得上传工具
					ServletContext servletContext = request.getSession().getServletContext();
					String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
							
					DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
					Iterator<?> fileNames = multipartRequest.getFileNames();
					String fileTxt = "";
					MultipartFile multiFile = null;

					if (fileNames.hasNext()) {

						String fileName = (String) fileNames.next();
						multiFile = multipartRequest.getFile(fileName);

						if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
							fileTxt = multiFile.getOriginalFilename();
						} else {
							fileTxt = new String(multiFile.getOriginalFilename()
									.getBytes("GBK"), ComUtil.charset);
						}
						if (fileTxt.length() > 0) {
							fileuploadPath = toolPath +File.separatorChar+ fileTxt;
							InputStream in = null;
							FileOutputStream out = null;

							int len = 0;
							File outDir = new File(toolPath);

							if (!outDir.exists()) {
								outDir.mkdirs();
							}

							for (File tmpFile : outDir.listFiles()) {
								tmpFile.delete();
							}

							in = multiFile.getInputStream();

							out = new FileOutputStream(fileuploadPath);
							byte[] buf = new byte[1024];
							while ((len = in.read(buf)) != -1) {
								out.write(buf, 0, len);

							}

							if (in != null) {
								in.close();
							}
							if (out != null) {
								out.flush();
								out.close();
							}
						}
					}
		
		
				   File file = new File(fileuploadPath);
				   toolBoxService.checkFile(file);
				   
			       InputStream fileStream = new FileInputStream(file);
			       byte[] file2=IOUtils.toByteArray(fileStream);
			      int l= new FileInputStream(new File(fileuploadPath)).available() / 1024 / 1024;
			       if(l>5){
			    	     modelMap.addAttribute("success", Boolean.FALSE);
			    	     resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString("文件大于5M", "utf-8")+ "\"}");
			       }else{
			    	   
			      
					String id  =UUID.randomUUID().toString();	 
			    	
					 ToolBoxFilesVo vo =new ToolBoxFilesVo();
					 vo.setFile_id(id);
					 vo.setTool_code(tool_code);
					 vo.setFile_name(file_name);
					 vo.setFile_type(file_type);
					 vo.setFile_content(file2);
					 toolBoxService.save(vo);
					 modelMap.addAttribute("success", Boolean.TRUE);
					 resOut.write("{\"success\":true}");
			       }
				} catch (DataIntegrityViolationException e) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
				}catch(HibernateSystemException eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("HibernateSystemException"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("HibernateSystemException"), "utf-8") +"\"}");
				}catch(ComponentException eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("ComponentException"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString("文件大于5M, 请重新上传!", "utf-8") +"\"}");
				}catch(Exception eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("Exception"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
				}
		 
	}
	
	@RequestMapping(value = "/addOccFile", method = RequestMethod.POST)
	public @ResponseBody
	void addOccFile(
			@RequestParam(value = "tool_code", required =false )String tool_code,
			@RequestParam("uploadPath") String uploadPath,
			@RequestParam("file_name") String file_name,
			@RequestParam("file_type") String file_type,
			HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		modelMap.clear();
		String fileuploadPath = null;	
		PrintWriter resOut = response.getWriter();
			try {
				   String uname = securityUtils.getUser().getUsername();
					//取得上传工具
					ServletContext servletContext = request.getSession().getServletContext();
					String toolPath = servletContext.getRealPath(File.separatorChar +messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath") + File.separatorChar+uname+ File.separatorChar);
							
					DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
					Iterator<?> fileNames = multipartRequest.getFileNames();
					String fileTxt = "";
					MultipartFile multiFile = null;

					if (fileNames.hasNext()) {

						String fileName = (String) fileNames.next();
						multiFile = multipartRequest.getFile(fileName);

						if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
							fileTxt = multiFile.getOriginalFilename();
						} else {
							fileTxt = new String(multiFile.getOriginalFilename()
									.getBytes("GBK"), ComUtil.charset);
						}
						if (fileTxt.length() > 0) {
							fileuploadPath = toolPath +File.separatorChar+ fileTxt;
							InputStream in = null;
							FileOutputStream out = null;

							int len = 0;
							File outDir = new File(toolPath);

							if (!outDir.exists()) {
								outDir.mkdirs();
							}

							for (File tmpFile : outDir.listFiles()) {
								tmpFile.delete();
							}

							in = multiFile.getInputStream();

							out = new FileOutputStream(fileuploadPath);
							byte[] buf = new byte[1024];
							while ((len = in.read(buf)) != -1) {
								out.write(buf, 0, len);

							}

							if (in != null) {
								in.close();
							}
							if (out != null) {
								out.flush();
								out.close();
							}
						}
					}
		
		
				   File file = new File(fileuploadPath);
				   
				   toolBoxService.checkFile(file);
			       InputStream fileStream = new FileInputStream(file);
			       byte[] file2=IOUtils.toByteArray(fileStream);
					String id  =UUID.randomUUID().toString();	 
			    	
					 OccToolBoxFilesVo vo =new OccToolBoxFilesVo();
					 vo.setFile_id(id);
					 vo.setTool_code(tool_code);
					 vo.setFile_name(file_name);
					 vo.setFile_type(file_type);
					 vo.setFile_content(file2);
					 toolBoxService.save(vo);
					 modelMap.addAttribute("success", Boolean.TRUE);
					 resOut.write("{\"success\":true}");
				} catch (DataIntegrityViolationException e) {
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName()), "utf-8")+ "\"}");
				}catch(HibernateSystemException eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("HibernateSystemException"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("HibernateSystemException"), "utf-8") +"\"}");
				}catch(ComponentException eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("ComponentException"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString("文件大于5M, 请重新上传!", "utf-8") +"\"}");
				}catch(Exception eo){
					modelMap.addAttribute("success", Boolean.FALSE);
					modelMap.addAttribute("error", messages.getMessage("Exception"));
					resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception"), "utf-8") +"\"}");
				}
	   
	} 
	/**
	 * 
	 * 批量删除附件
	 * 
	 * @param tool_codes
	 * @param file_ids
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/deleteOccFile", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteOccFile(
			@RequestParam(value = "tool_codes", required = true) String[] tool_codes,
			@RequestParam(value = "file_ids", required = true) String[] file_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			toolBoxService.deleteByOccfile_ids(tool_codes, file_ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	
	/**
	 * 获取附件信息
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getFileList", method = RequestMethod.POST)
	public @ResponseBody void getFileList(
			@RequestParam(value = "tool_code", required = true) String tool_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getFileList(tool_code);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 获取临时附件信息
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getOccFileList", method = RequestMethod.POST)
	public @ResponseBody void getOccFileList(
			@RequestParam(value = "tool_code", required = true) String tool_code,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = toolBoxService.getOccFileList(tool_code);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	
	/**
	 * 跳转到一线接收工具的编辑描述界面
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/front_edit", method = RequestMethod.GET)
	public String fedit() throws JEDAException {
		return viewPrefix + "front_edit";
	}
	
	/**
	 * 根据工具编号，应用系统获取工具属性
	 * 保存一线接收工具的编辑描述
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/front_edit", method = RequestMethod.POST)
	public  @ResponseBody
	ModelMap fedit(	@RequestParam(value = "tool_code", required = true) String tool_code,
			@RequestParam(value = "appsys_code", required = true) String appsys_code,
			@RequestParam(value = "front_tool_desc", required = true) String front_tool_desc,
			HttpServletRequest request, HttpServletResponse response,
			ModelMap modelMap)throws IOException{
			
		modelMap.clear();
		try{
			toolBoxService.saveOrUpdateToolboxinfo(tool_code,appsys_code,front_tool_desc);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	
	/**
	 * 返回一线查看工具页面
	 * 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/front_view", method = RequestMethod.GET)
	public String front_view() throws JEDAException {
		return viewPrefix + "front_view";
	}
	
     /*
      * 返回一线查看工具页面
	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/front_view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getFrontViewInfo(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",toolBoxService.frontFindById(tool_code, appsys_code));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 双击查看
	 * 返回查看工具页面
	 * 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/dblview", method = RequestMethod.GET)
	public String dblview() throws JEDAException {
		return viewPrefix + "view";
	}
	
	/**
	 * 双击查看
	 * 返回查看工具页面
	 * 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/dblviewDesc", method = RequestMethod.GET)
	public String dblviewDesc() throws JEDAException {
		return viewPrefix + "viewdesc";
	}

	/**
	 * 双击查看、
	 * 根据工具编号，应用系统获取工具属性


	 * @param tool_code
	 *          工具编号
	 * @param appsys_code
	 *           应用系统
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/dblview", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getdblViewInfo(@RequestParam("appsys_code") String appsys_code,
			@RequestParam("tool_code") String tool_code,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",toolBoxService.dblfindById(tool_code, appsys_code));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

}
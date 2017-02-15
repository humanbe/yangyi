package com.nantian.dply.controller;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateSystemException;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.ApplicationProcessService;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.service.ServersSynchronousService;
import com.nantian.dply.vo.ApplicationProcessRecordsVo;
import com.nantian.dply.vo.ApposUserVo;
import com.nantian.dply.vo.OccasServersInfoVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.toolbox.vo.ToolBoxEventGroupInfoVo;
import com.nantian.toolbox.vo.ToolBoxExtendAttriVo;
import com.nantian.toolbox.vo.ToolBoxInfoVo;
import com.nantian.toolbox.vo.ToolBoxKeyWordInfoVo;
import com.nantian.toolbox.vo.ToolBoxScriptInfoVo;


/**
 * 服务器信息检索
 */


@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/ApplicationProcess")
public class ApplicationProcessController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(ApplicationProcessController.class);
	/** 模板管理领域对象名称 */
	private static final String domain = "applicationprocess";
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain+"_";

	@Autowired
	private ApplicationProcessService applicationProcessService;
	@Autowired
	 private SecurityUtils securityUtils; 
	
//---------------------------------------------------------	
	@Autowired
	private ServersSynchronousService serversSynchronousService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	AppInfoService appInfoService;
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "index";
	}
	
	/**
	 * 查询审批流程信息

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
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryApplicationProcesslist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
		//	@RequestParam(value = "status", required = false) String status,
			
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, applicationProcessService.fields);
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					applicationProcessService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,applicationProcessService.count( params) );
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	
	@RequestMapping(value = "/findUserId", method = RequestMethod.POST)
	public @ResponseBody void findUserId(HttpServletRequest request, HttpServletResponse response) throws JEDAException, IOException, SQLException {
			PrintWriter out = null;
			Object serIPs = applicationProcessService.findUserId();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(serIPs));
		}
	/**
	 * 代理安装下载页
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/download", method = RequestMethod.GET)
	public String download() throws JEDAException {
		return viewPrefix + "download";
	}
	
	/**
	 * 代理安装下载页

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
	@RequestMapping(value = "/downloadIndex", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryDownloadApplicationProcesslist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, applicationProcessService.fields);
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					applicationProcessService.queryDownloadAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,applicationProcessService.count( params) );
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	
	/**
	 * 导出服务器结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/servers_download", method = RequestMethod.GET)
	public String servers_download(@RequestParam("recordIds") String[] recordIds,HttpServletRequest request, ModelMap modelMap) throws JEDAException, SQLException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("date", "安装日期");
		columns.put("appsysCode","系统名称");
		columns.put("sysa", "系统管理员A");
		columns.put("sysb", "系统管理员B");
		columns.put("serverIp","IP");
		columns.put("installPerson", "安装人员");
		columns.put("inspectorPerson", "复核人员");
		columns.put("installStatus", "安装状态");
		columns.put("rubStatus", "运行状态");
		columns.put("desc", "备注");
		columns.put("message","其他信息");
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= applicationProcessService.queryDownloadInfo(recordIds);
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
	/**
	 * 批量删除
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
			@RequestParam(value = "record_ids", required = true) String[] record_ids,
			@RequestParam(value = "subject_infos", required = true) String[] subject_infos,

			ModelMap modelMap) throws JEDAException, SQLException {
		
		    applicationProcessService.deleteByIds(record_ids,subject_infos);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	
	/**
	 * 批量审批通过
	 * 
	 * @param tool_codes
	 * @param appsys_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/doOk", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap doOk(
			@RequestParam(value = "record_ids", required = true) String[] record_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		    applicationProcessService.doOkByIds(record_ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	
	
	
	/**
	 * 批量退回
	 * 
	 * @param tool_codes
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/doBacked", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap doBack(
			@RequestParam(value = "record_ids", required = true) String[] record_ids,
			@RequestParam(value = "process_Backreasons") String process_Backreasons,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			applicationProcessService.backedByIds(record_ids,process_Backreasons);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
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
	 * 返回流程新建页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String asi_create() {
		return viewPrefix + "create";
	}
	
	
	/**
	 * 保存新建数据
	 * 
	 * @return
	 * @throws IOException ,JEDAException
	 */
	
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	void saveCreate(	@ModelAttribute ApplicationProcessRecordsVo applicationProcessRecordsVo,
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
					
				Date startDate = new Date();
				String created_time = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
				String created_time2 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
				String createUser =applicationProcessService.findbyUserId();
				String subject_info ="1";
				
				String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
				String process_description =time+"<br>"+createUser+": 服务器审批流程提交;";
				String record_id ="SERVER_IMP"+created_time+"-"+applicationProcessService.findProcessSeq();
				
				applicationProcessRecordsVo.setApplication_user(uname);
				applicationProcessRecordsVo.setApplication_time(Timestamp.valueOf(created_time2.concat(".000").toString()));
				applicationProcessRecordsVo.setRecord_id(record_id);
				applicationProcessRecordsVo.setProcess_description(process_description);
				applicationProcessRecordsVo.setSubject_info(subject_info);
				applicationProcessRecordsVo.setDelete_flag("0");
				
				List<OccasServersInfoVo> list =applicationProcessService.getServerList(uploadPath,record_id);
				applicationProcessService.saveOccasServersInfo(list);
				
				applicationProcessService.save(applicationProcessRecordsVo);
				
				 modelMap.addAttribute("success", Boolean.TRUE);
				 resOut.write("{\"success\":true}");
			} catch (DataIntegrityViolationException e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage(e.getClass().getSimpleName()));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(e.getClass().getSimpleName())+"<br>"+e, "utf-8")+ "\"}");
			}catch (SQLException ce) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage(ce.getClass().getSimpleName()));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage(ce.getClass().getSimpleName())+"<br>"+ce, "utf-8")+ "\"}");
			}catch(HibernateSystemException eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("HibernateSystemException"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("HibernateSystemException")+"<br>"+eo, "utf-8") +"\"}");
			}catch(ComponentException eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("ComponentException"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("ComponentException")+"<br>"+eo, "utf-8") +"\"}");
			}catch(Exception eo){
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", messages.getMessage("Exception"));
				resOut.write("{\"success\":false,\"error\":\""+ ComUtil.encodeCNString(messages.getMessage("Exception")+"<br>"+eo, "utf-8") +"\"}");
			}
	}
	
	
	
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() {
		return viewPrefix + "view";
	}
	
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/systemAuthView", method = RequestMethod.GET)
	public String systemAuthView() {
		return viewPrefix + "systemAuth_view";
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
	@RequestMapping(value = "/systemAuthView", method = RequestMethod.POST)
	public @ResponseBody ModelMap systemAuthView(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "record_id", required = false) String record_id,
			
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					applicationProcessService.systemAuthViewList(start, limit, sort, dir,record_id));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					applicationProcessService.countSystemAuthView(record_id));
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
	@RequestMapping(value = "/viewdata", method = RequestMethod.POST)
	public @ResponseBody ModelMap viewdata(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "record_id", required = false) String record_id,
			
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					applicationProcessService.viewdataList(start, limit, sort, dir,  record_id));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					applicationProcessService.countOccasServerIp(record_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}
	
	
	/** 用户数据服务 */
	@Autowired
	private UserService userService;

	
	/**
	 * 导入服务器信息
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@Transactional
	@RequestMapping(value = "/doImported", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap importServers(
			@RequestParam(value = "record_id", required = false) String record_id,
			@RequestParam(value = "subject_info", required = false) String subject_info,
			@RequestParam(value = "handled_user", required = false) String username,
			HttpServletRequest request, ModelMap modelMap) throws Exception {

		try {
				
				if(subject_info.equals("3")){
					
					List<String> list=applicationProcessService.querySystemAuth(record_id);
					applicationProcessService.doSystemAuth(list);			

					//应用系统权限同步到brpm、bsa
					String[] usernames = new String[1];
					if(username.indexOf("(")!=-1){
						usernames[0] = username.substring(0,username.indexOf("(")).toString();
					}else{
						usernames[0] = username;
					}
					StringBuilder checkMsg = new StringBuilder();
					userService.syncUserToBrpm(usernames, checkMsg);
					userService.syncUserToBsaForDply(usernames, checkMsg);
					
					applicationProcessService.completedProcess(record_id);					

					
					modelMap.addAttribute("success", Boolean.TRUE);
				}else if(subject_info.equals("2")){//临时服务器
					List<String> list=applicationProcessService.queryServer(record_id);
					String lastAgentInfo = serversSynchronousService.doAgent(list);
					if(lastAgentInfo.equals("")){
						modelMap.addAttribute("agentInfo",lastAgentInfo+"检测成功");
						applicationProcessService.completedProcess(record_id);
					}else{
						modelMap.addAttribute("agentInfo",lastAgentInfo+"<br>"+"不能被BSA纳管，请安装代理");
					}
					modelMap.addAttribute("success", Boolean.TRUE);
				}else{
					List<ServersInfoVo> ServerList= applicationProcessService.List(record_id) ;
					   //数据库所有服务器
				    List<ServersInfoVo> importServerList=serversSynchronousService.queryAllServersInfo();
					serversSynchronousService.importServers(importServerList,ServerList);
					applicationProcessService.completedProcess(record_id);
					modelMap.addAttribute("success", Boolean.TRUE);
				}
			} catch (Exception e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", e.getMessage());
			}
		 
		return modelMap;
}
	
	
	
	/**
	 * 批量取消流程
	 * 
	 * @param record_ids
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/doCancel", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap doCancel(
			@RequestParam(value = "record_ids", required = true) String[] record_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
			applicationProcessService.doCancelByIds(record_ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	//-------------------------------------------------------------------------------------------------------------
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
	
	

}

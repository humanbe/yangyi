package com.nantian.dply.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.hibernate.exception.ConstraintViolationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.NshJobService;
import com.nantian.dply.vo.CmnAppGroupServiceVo;
import com.nantian.dply.vo.DplyJobInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * 应用系统环境管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/nshjob")
public class NshJobController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(NshJobController.class);

	/** 领域对象名称 */
	private static final String domain = "nshjob";

	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain +"_";
	
	@Autowired
	private NshJobService nshJobService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	 private SecurityUtils securityUtils; 
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
	@RequestMapping(value = "/groupIndex", method = RequestMethod.GET)
	public String groupIndex() throws JEDAException {
		return viewPrefix + "group_index";
	}
	/**
	 * 根据分页、排序和其他条件查询编码信息记录
	 * @param start         起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段
	 * @param dir	  		   排序的方式
	 * @param appsysCode  系统代码
	 * @param environmentType  环境类型
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/groupIndex", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap groupList(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "serverGroup", required = false) String serverGroup,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryGroup(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, nshJobService.countGroup(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/groupCreate", method = RequestMethod.GET)
	public String groupCreate() throws JEDAException {
		return viewPrefix + "group_create";
	}
	/**
	 * 保存新建数据
	 * 
	 * @param cmnEnvironmentVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/groupCreate", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CmnAppGroupServiceVo cmnAppGroupServiceVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            nshJobService.saveGroup(cmnAppGroupServiceVo);
			modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/groupEdit", method = RequestMethod.GET)
	public String groupEdit() throws JEDAException {
		return viewPrefix + "group_edit";
	}
	/**
	 * 保存新建数据
	 * 
	 * @param cmnEnvironmentVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/groupEdit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editSave(@ModelAttribute CmnAppGroupServiceVo cmnAppGroupServiceVo
			,HttpServletRequest request,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            nshJobService.editGroup(cmnAppGroupServiceVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("error", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 查询数据库中是否存在值

	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryNR/{appsysCode}/{serverGroup}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap queryNR(
			@PathVariable("appsysCode") String appsysCode,
			@PathVariable("serverGroup") String serverGroup,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryNR( appsysCode,serverGroup));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
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
	 * @param sort           排序的字段	 * @param dir	  		   排序的方式	 * @param appsysCode  系统代码
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
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, nshJobService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 根据上传路径读取文件信息
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	void list(@ModelAttribute DplyJobInfoVo dplyJobInfoVo,
			HttpServletRequest request,HttpServletResponse response, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
		 modelMap.clear();
         PrintWriter resOut = response.getWriter();
			try {
         String uploadPath = null;
       //去得当前登录用户
         String username = securityUtils.getUser().getUsername();
       //取得上传工具
			ServletContext servletContext = request.getSession().getServletContext();
			String shPath = servletContext.getRealPath(File.separatorChar +"upload"+ File.separatorChar + username + File.separatorChar);
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
					uploadPath = shPath +File.separatorChar+ fileTxt;
					InputStream in = null;
					FileOutputStream out = null;

					int len = 0;
					File outDir = new File(shPath);

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
			String name=dplyJobInfoVo.getScriptBlpackageName();
			shPath=shPath+File.separatorChar+name;
			modelMap.addAttribute("success", Boolean.TRUE);
			resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) nshJobService.queryText(shPath,dplyJobInfoVo), "utf-8")+"\"}");
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
	 * 根据上传路径读取文件信息
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/fileView", method = RequestMethod.POST)
	public @ResponseBody
	void fileView(@ModelAttribute DplyJobInfoVo dplyJobInfoVo,
			@RequestParam(value = "envCode", required = false) String envCode,
			HttpServletRequest request,HttpServletResponse response, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
		 modelMap.clear();
         PrintWriter resOut = response.getWriter();
         envCode = java.net.URLDecoder.decode(envCode,"utf-8") ;
			try {
				String username = securityUtils.getUser().getUsername();
				String scriptName=dplyJobInfoVo.getScriptBlpackageName();
				ServletContext servletContext = request.getSession().getServletContext();
				String shPath = servletContext.getRealPath(File.separatorChar +"download"+ File.separatorChar + username + File.separatorChar);
				File outDir = new File(shPath);
				if (!outDir.exists()) {
					outDir.mkdirs();
				}
				//通过API去取bas上.sh文件路径
				String basShPath=(String) nshJobService.queryShPath(dplyJobInfoVo,envCode);
				//调起nsh作业将.sh脚本复制到本地
				String filePath=shPath+File.separatorChar+scriptName;
				//sh放到服务器中的路径
				String resultpath="";
				if(ComUtil.isWindows){
					resultpath="//"+messages.getMessage("systemServer.ip") + "/" + filePath.replace(":", "").replace("\\", "/");
				}else{
					resultpath="//"+messages.getMessage("systemServer.ip") +  filePath;
				}
				 nshJobService.exeJob(dplyJobInfoVo,basShPath,resultpath,envCode);
				modelMap.addAttribute("success", Boolean.TRUE);
				resOut.write("{\"success\":true,\"data\":\""+ComUtil.encodeCNString((String) nshJobService.queryText(filePath,dplyJobInfoVo), "utf-8")+"\"}");
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
	 * 查询数据库中是否存在值
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryExist", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryExist(
			@RequestParam(value = "appsysCodes", required = false) String appsysCodes,
			@RequestParam(value = "jobParentGroups", required = false) String jobParentGroups,
			@RequestParam(value = "scriptBlpackageNames", required = false) String scriptBlpackageNames,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryExist( appsysCodes,jobParentGroups,scriptBlpackageNames));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 查询数据库中是否存在值

	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryGroupExist", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryGroupExist(
			@RequestParam(value = "appsysCodes", required = false) String appsysCodes,
			@RequestParam(value = "serviceNames", required = false) String serviceNames,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryGroupExist( appsysCodes,serviceNames));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	/**
	 * 必选参数的信息显示
	 * 
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/generalParam", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap generalParam(
			@RequestParam(value = "jobGroupName", required = false) String jobGroupName,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "envName", required = false) String envName,
			HttpServletRequest request, DplyJobInfoVo dplyJobInfoVo,ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.generalParam( appsysCode,jobGroupName,envName));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	
	/**
	 * 可选参数的信息显示
	 *  checkedCheckParam
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/checkParam", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap checkParam(
			@RequestParam(value = "jobGroupName", required = false) String jobGroupName,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "envName", required = false) String envName,
			HttpServletRequest request, DplyJobInfoVo dplyJobInfoVo,ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.checkParam( appsysCode,jobGroupName,envName));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	
	/**
	 * 可选参数的信息显示queryosType
	 *  checkedCheckParam
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/checkedCheckParam", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap checkedCheckParam(
			@RequestParam(value = "jobGroupName", required = false) String jobGroupName,
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "scriptBlpackageName", required = false) String scriptBlpackageName,
			@RequestParam(value = "envName", required = false) String envName,
			HttpServletRequest request, DplyJobInfoVo dplyJobInfoVo,ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.checkedCheckParam( appsysCode,jobGroupName,scriptBlpackageName,envName));
			modelMap.addAttribute("success", Boolean.TRUE);		
		return modelMap;
	}
	
	/**
	 * 可选参数的信息显示
	 *  checkedCheckParam
	 * @param nshJobFilePath
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/queryosType", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap queryosType(
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "serviceName", required = false) String serviceName,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, nshJobService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, nshJobService.queryosType( appsysCode,serviceName));
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
	 * @param 
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	void save(@ModelAttribute DplyJobInfoVo dplyJobInfoVo
			,HttpServletRequest request,HttpServletResponse response,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            PrintWriter resOut = response.getWriter();
			try {
            String uploadPath = null;
          //去得当前登录用户
            String username = securityUtils.getUser().getUsername();
          //取得上传工具
        	ServletContext servletContext = request.getSession().getServletContext();
			String shPath = servletContext.getRealPath(File.separatorChar +"upload"+ File.separatorChar + username + File.separatorChar);
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
					uploadPath = shPath +File.separatorChar+ fileTxt;
					InputStream in = null;
					FileOutputStream out = null;

					int len = 0;
					File outDir = new File(shPath);

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
			nshJobService.save(dplyJobInfoVo,shPath);
			modelMap.addAttribute("success", Boolean.TRUE);
			resOut.write("{\"success\":true}");
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
	 * 查询服务分组名
	 * @param response
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/queryjobParentGroup", method = RequestMethod.GET)
	public @ResponseBody void queryjobParentGroup(@RequestParam(value = "appsysCode", required =false )String appsysCode,
			@RequestParam(value = "envCode", required =false )String envCode,
			 HttpServletResponse response) throws UnsupportedEncodingException{
		PrintWriter out = null;
		// 输出开始日志		envCode = java.net.URLDecoder.decode(envCode,"utf-8") ;

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
				
		try {
			Object sysIDs = nshJobService.queryjobParentGroup(appsysCode,envCode);
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
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	void edit(@ModelAttribute DplyJobInfoVo dplyJobInfoVo
			,HttpServletRequest request,HttpServletResponse response,ModelMap modelMap)  throws HibernateOptimisticLockingFailureException,Exception  {
		  modelMap.clear();
          PrintWriter resOut = response.getWriter();
			try {
          String uploadPath = null;
        //去得当前登录用户
          String username = securityUtils.getUser().getUsername();
        //取得上传工具
      	ServletContext servletContext = request.getSession().getServletContext();
		String shPath = servletContext.getRealPath(File.separatorChar +"upload"+ File.separatorChar + username + File.separatorChar);
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
				uploadPath = shPath +File.separatorChar+ fileTxt;
				InputStream in = null;
				FileOutputStream out = null;

				int len = 0;
				File outDir = new File(shPath);

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
			nshJobService.edit(dplyJobInfoVo,shPath);
			modelMap.addAttribute("success", Boolean.TRUE);
			resOut.write("{\"success\":true}");
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
	 * 查询脚本内容
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组

     * @return
	 */
	@RequestMapping(value = "/queryNsh/{appsysCode}/{jobParentGroup}/{scriptBlpackageName}/{jobName}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap queryNsh(
			@PathVariable("appsysCode") String appsysCode,
			@PathVariable("jobParentGroup") String jobParentGroup,
			@PathVariable("scriptBlpackageName") String scriptBlpackageName,
			@PathVariable("jobName") String jobName,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data", nshJobService.queryNsh(appsysCode,jobParentGroup,scriptBlpackageName,jobName));
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
			@RequestParam(value = "jobParentGroups", required = true) String[] jobParentGroups,
			@RequestParam(value = "scriptBlpackageNames", required = true) String[] scriptBlpackageNames,
			@RequestParam(value = "jobNames", required = true) String[] jobNames,
			ModelMap modelMap,HttpServletRequest request)throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			 String username = securityUtils.getUser().getUsername();
			ServletContext servletContext = request.getSession().getServletContext();
			String shPath = servletContext.getRealPath(File.separatorChar +"upload"+ File.separatorChar + username + File.separatorChar);
			nshJobService.deleteByIds(appsysCodes, jobParentGroups,scriptBlpackageNames,jobNames,shPath);
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
	}
}///:~

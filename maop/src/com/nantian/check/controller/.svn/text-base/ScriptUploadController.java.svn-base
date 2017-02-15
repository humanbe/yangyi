package com.nantian.check.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.hibernate.exception.ConstraintViolationException;
import org.jboss.seam.annotations.Transactional;
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

import com.nantian.check.service.ScriptUploadService;
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
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
@RequestMapping("/" + Constants.MANAGE_PATH + "/scriptUpload")
public class ScriptUploadController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(ScriptUploadController.class);

	/** 领域对象名称 */
	private static final String domain = "scriptUpload";

	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain +"_";
	
	@Autowired
	private ScriptUploadService scriptUploadService;
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
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,Exception {
			modelMap.clear();
		    Map<String, Object> params = RequestUtil.getQueryMap(request, scriptUploadService.fields);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, scriptUploadService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, scriptUploadService.count(params));
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
	void save(@ModelAttribute CheckItemInfoVo checkItemInfoVo
			,HttpServletRequest request,HttpServletResponse response,ModelMap modelMap) throws DataIntegrityViolationException,SQLException,ConstraintViolationException,Exception{
            modelMap.clear();
            PrintWriter resOut = response.getWriter();
			try {
            String uploadPath = null;
          //去得当前登录用户
            String username = securityUtils.getUser().getUsername();
          //取得上传工具
        	ServletContext servletContext = request.getSession().getServletContext();
			String shPath = servletContext.getRealPath(File.separatorChar +"checkUpload"+ File.separatorChar + username + File.separatorChar);
			DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
			Iterator<?> fileNames = multipartRequest.getFileNames();
			String fileTxt = "";
			MultipartFile multiFile = null;
			List<String> scriptNameList=new ArrayList<String>();
			while (fileNames.hasNext()) {

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
					//将sh脚本上传到bsa中
					scriptUploadService.addShScriptToBsa(checkItemInfoVo,fileTxt,shPath);
					scriptNameList.add(fileTxt);
				}
			}
			
			String itemNshName=(String) scriptUploadService.addItemScriptToBsa(checkItemInfoVo,scriptNameList,shPath);
			scriptUploadService.save(checkItemInfoVo,scriptNameList,itemNshName);
			scriptUploadService.addAllInitScriptToBsa(checkItemInfoVo,itemNshName,shPath,scriptNameList);
			//将脚本下发到BSA文件服务器上
			scriptUploadService.deployToBsa(checkItemInfoVo,scriptNameList);
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
	@Transactional
	public @ResponseBody
	void edit(@ModelAttribute CheckItemInfoVo checkItemInfoVo
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
		List<String> scriptNameList=new ArrayList<String>();
		while (fileNames.hasNext()) {

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
				//将sh脚本上传到bsa中
				scriptUploadService.editShScriptToBsa(checkItemInfoVo,fileTxt,shPath);
				scriptNameList.add(fileTxt);
			}
		}
			scriptUploadService.edit(checkItemInfoVo,scriptNameList,shPath);
			scriptUploadService.editItemScript(checkItemInfoVo,scriptNameList,shPath);
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
	 * 刪除脚本
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组
	 * @return
	 */
	@RequestMapping(value = "/delete",  method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "osTypes", required = true) String[] osTypes, 
			@RequestParam(value = "fieldTypes", required = true) String[] fieldTypes,
			@RequestParam(value = "binScriptNames", required = true) String[] binScriptNames,
			@RequestParam(value = "setScriptNames", required = true) String[] setScriptNames,
			@RequestParam(value = "initScriptNames", required = true) String[] initScriptNames,
			HttpServletRequest request,
			ModelMap modelMap)throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			ServletContext servletContext = request.getSession().getServletContext();
			String username = securityUtils.getUser().getUsername();
			String shPath = servletContext.getRealPath(File.separatorChar +"deleteScript"+ File.separatorChar + username + File.separatorChar);
			File outDir = new File(shPath);
			if (!outDir.exists()) {
				outDir.mkdirs();
			}
			for (File tmpFile : outDir.listFiles()) {
				tmpFile.delete();
			}
			scriptUploadService.deleteByIds(osTypes, fieldTypes,binScriptNames,setScriptNames,initScriptNames,shPath);
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
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

	@RequestMapping(value = "/getFieldTypeone", method = RequestMethod.POST)
	public @ResponseBody void getFieldTypeone(
			@RequestParam(value = "fieldType", required =false )String fieldType,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
		
		PrintWriter out = null;
		Object names = scriptUploadService.getFieldTypeone(fieldType);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(names));
	}
	/**
	 * 查询脚本内容
	 * @param appsysCodes 系统代码
     * @param serverGroups 服务器分组


     * @return
	 */
	@RequestMapping(value = "/query/{osType}/{binScriptName}/{fieldType}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap queryNsh(
			@PathVariable("osType") String osType,
			@PathVariable("binScriptName") String binScriptName,
			@PathVariable("fieldType") String fieldType,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException ,DataIntegrityViolationException,Exception {
			modelMap.clear();
			modelMap.addAttribute("data", scriptUploadService.query(osType,fieldType,binScriptName));
			modelMap.addAttribute("success", Boolean.TRUE);
		    return modelMap;
	}
}///:~

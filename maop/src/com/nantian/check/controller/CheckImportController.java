package com.nantian.check.controller;

import java.io.IOException;
import java.net.SocketTimeoutException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.CheckImportService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 巡检数据迁移-导入controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/checkimport")
public class CheckImportController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckImportController.class);
	/** 领域对象名称 */
	private static final String domain = "checkimport";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private CheckImportService checkImportService;
	@Autowired
	private SecurityUtils securityUtils;
	/**
	 * 进入功能操作页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index";
	}
	
	/**
	 * 获取可导入的文件列表
	 * @throws IOException,Exception 
	 */
	@RequestMapping(value = "/getImportabledFiles", method = RequestMethod.POST)
	public @ResponseBody ModelMap getJobServer(
			@RequestParam(value = "importFileType", required = false) String importFileType, 
			HttpServletRequest request, ModelMap modelMap) throws Exception,Throwable {
		List<Map<String, String>> importabledFiles = checkImportService.getImportabledFileList(importFileType,securityUtils.getUser().getUsername());
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, importabledFiles);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 执行导入操作 - 扩展对象的导入暂时不做	 * @throws Throwable 
	 * @throws Exception 
	 * @throws IOException 
	 * @throws SocketTimeoutException 
	 */
	@RequestMapping(value = "/importCheckFiles", method = RequestMethod.POST)
	public @ResponseBody ModelMap exportCheckFiles(HttpServletRequest request) throws SocketTimeoutException, IOException, Exception, Throwable{
		ModelMap modelMap = new ModelMap();
		//获取待导入文件类型(template-组件模板、job-巡检作业、extends-扩展对象)
		String importFileType = ServletRequestUtils.getStringParameter(request, "importFileType");
		//获取待导入文件信息		String importFiles = ServletRequestUtils.getStringParameter(request, "importFiles");
		String info = checkImportService.doCheckImport(importFileType,importFiles,securityUtils.getUser().getUsername());
		modelMap.addAttribute("success", Boolean.TRUE);
		modelMap.addAttribute("info", info);
		return modelMap;
	}
	
}

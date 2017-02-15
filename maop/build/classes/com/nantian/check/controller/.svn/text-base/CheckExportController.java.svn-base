package com.nantian.check.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
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

import com.nantian.check.service.CheckExportService;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 巡检作业controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/checkexport")
public class CheckExportController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckExportController.class);
	/** 领域对象名称 */
	private static final String domain = "checkexport";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	@Autowired
	private CheckExportService checkExportService;
	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	private SecurityUtils securityUtils;
	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index";
	}
	
	/**
	 * 获取目录树数据
	 * @param exportFileType 导出文件类型
	 * @throws IOException,Exception 
	 */
	@RequestMapping(value = "/getFileTree", method = RequestMethod.POST)
	public @ResponseBody void getTemplateTree(
		   @RequestParam(value = "exportFileType", required =false )String exportFileType,
		HttpServletRequest request, HttpServletResponse response) throws IOException,Exception{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		String[] appFiles = null;
		String[] commonFiles = null;
		//获取该用户的授权应用系统
		Object appCodes = appInfoService.querySystemIDAndNamesByUser(securityUtils.getUser().getUsername());
		if(exportFileType.equals("job")){
			//COMMON_CHECK
			commonFiles = checkExportService.getCommonJobSubNodes().split("\n");
			//CHECK
			String[] appFilesBsa = checkExportService.getAppJobSubNodes().split("\n");
			String appsysCodes = "" ;
			for(int t=0;t<appFilesBsa.length;t++){
				if(appCodes.toString().indexOf(appFilesBsa[t])>=0){
					appsysCodes = appsysCodes+appFilesBsa[t]+",";
				}
			}
			if(!appsysCodes.equals("")){
				appsysCodes.substring(0, appsysCodes.length()-1);
				appFiles = appsysCodes.split(",");
			}
			//构建目录树			jsonList = checkExportService.buildJobTree(appFiles,commonFiles);
		}
		if(exportFileType.equals("template")){
			//COMMON_CHECK
			commonFiles = checkExportService.getCommonTempSubNodes().split("\n");
			//CHECK
			/* 组件模板下的CHECK目录已取消
			String[] appFilesBsa = checkExportService.getAppTempSubNodes().split("\n");
			String appsysCodes = "" ;
			for(int t=0;t<appFilesBsa.length;t++){
				if(appCodes.toString().indexOf(appFilesBsa[t])>=0){
					appsysCodes = appsysCodes+appFilesBsa[t]+",";
				}
			}
			if(!appsysCodes.equals("")){
				appFiles = (appsysCodes.substring(0, appsysCodes.length()-1)).split(",");
			}*/
			//构建目录树			jsonList = checkExportService.buildTemplateTree(appFiles,commonFiles);
		}
		out = response.getWriter();
		out.print(jsonList);
    }

	/**
	 * 执行导出操作 - 扩展对象的导出暂时不做	 * @throws ServletException 
	 */
	@RequestMapping(value = "/exportCheckFiles", method = RequestMethod.POST)
	public @ResponseBody ModelMap exportCheckFiles(HttpServletRequest request) throws ServletException,AxisFault,Exception{
		ModelMap modelMap = new ModelMap();
		//获取导出文件类型(template-组件模板、job-巡检作业、extends-扩展对象)
		String exportFileType = ServletRequestUtils.getStringParameter(request, "exportFileType");
		//获取导出文件信息
		String exportFiles = ServletRequestUtils.getStringParameter(request, "exportFiles");
		checkExportService.doCheckExport(exportFileType,exportFiles);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
}

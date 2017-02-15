package com.nantian.check.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.AppCheckDesignService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.toolbox.service.ToolBoxService;

/**
 * 巡检作业controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH+ "/appcheckdesign")
public class AppCheckDesignController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(AppJobDesignController.class);
	/** 领域对象名称 */
	private static final String domain = "appcheckdesign";
	/** 视图前缀 */
	private static final String viewPrefix = "check/" + domain + "/" + domain+"_";
	
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	private  ToolBoxService toolBoxService;
	@Autowired
	 private AppCheckDesignService appCheckDesignService; 
	

	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/app_check_design", method = RequestMethod.GET)
	public String index(
			@RequestParam(value = "appsysCode", required = false) String appsysCode,
			@RequestParam(value = "environmentCode", required = false) String environmentCode){
		return viewPrefix + "info";
	}

	
	/**
	 * 查询服务器配置信息

	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param changeMonth
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/server_index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "environmentCode", required = false) String environmentCode,
			
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		try{

			Map<String, Object> Level1Map = new HashMap<String, Object>();//系统
			Map<String, Object> Level2Map = new HashMap<String, Object>();//分组
			Map<String, Object> Level3Map = new HashMap<String, Object>();//服务器
			Map<String, Object> Level4Map = new HashMap<String, Object>();
			Map<String, Object> Level5Map = new HashMap<String, Object>();
			List<Map <String ,String >>  serverlist= appCheckDesignService.queryServerConfList(aplCode, request);
			List<Map <String ,String >>  serverlistdel= appCheckDesignService.queryServerConfListDel(aplCode, request);
			List<Map<String, Object>> dataList = new ArrayList<Map<String, Object>>();
			List<Map <String ,String >>  Grouplist= appCheckDesignService.queryServerGroup(aplCode);
			StringBuilder reportTypes = new StringBuilder();
			
	     	int count = 0;
	     		
	     			reportTypes.delete(0, reportTypes.length());
	     			Level1Map = new HashMap<String, Object>();
	     			Level1Map.put("srvCode",aplCode) ;
	     			Level1Map.put("_id", ++count);
	     			Level1Map.put("_parent", null);
	     			Level1Map.put("_is_leaf", false);
	     			Level1Map.put("serClass", null);
	     			Level1Map.put("appsys_code", null);
	    			Level1Map.put("server_ip", null);
	    			Level1Map.put("server_name", null);
	    			Level1Map.put("server_group", null);
	     			Level1Map.put("ipAddress", null);
	     			Level1Map.put("loadMode", null);
	     			Level1Map.put("serName", null);
	     			Level1Map.put("memConf", null);
	     			Level1Map.put("cpuConf", null);
	     			Level1Map.put("diskConf", null);
	     			Level1Map.put("ipAddress", null);
	     			Level1Map.put("floatAddress", null);
	     			Level1Map.put("autoCapture", null);
	     			Level1Map.put("checkflag", null);
	     			
	     			dataList.add(Level1Map);

	     		for(Map<String,String> map2: Grouplist){
	              String  serverGroup =map2.get("serverGroup").toString();
	              String sg =toolBoxService.getGroupName(serverGroup);
	              Level2Map = new HashMap<String, Object>();//分组
	     			Level2Map.put("srvCode",sg) ;
	     			Level2Map.put("_id", ++count);
	     			Level2Map.put("_parent", Level1Map.get("_id"));
	     			Level2Map.put("_is_leaf", false);
	     			Level2Map.put("serClass", null);

	     			Level2Map.put("appsys_code", null);
	    			Level2Map.put("server_ip", null);
	    			Level2Map.put("server_name", null);
	    			Level2Map.put("server_group", null);
	     			Level2Map.put("ipAddress", null);
	     			Level2Map.put("loadMode", null);
	     			Level2Map.put("serName", null);
	     			Level2Map.put("memConf", null);
	     			Level2Map.put("cpuConf", null);
	     			Level2Map.put("diskConf", null);
	     			Level2Map.put("ipAddress", null);
	     			Level2Map.put("floatAddress", null);
	     			Level2Map.put("autoCapture", null);
	     			Level2Map.put("checkflag", null);
	     			dataList.add(Level2Map);
	     			
	     			for(Map<String,String> map: serverlist ){
	     				if(serverGroup.equals(String.valueOf(map.get("server_group")))){
	     			
			     		Level3Map = new HashMap<String, Object>();//服务器
			     		Level3Map.put("srvCode", map.get("server_ip"));
			     		Level3Map.put("aplCode",aplCode) ;
		     			Level3Map.put("_id", ++count);
		     			Level3Map.put("_parent", Level2Map.get("_id"));
		     			Level3Map.put("_is_leaf", true);
		     			Level3Map.put("serClass", serverGroup);
		     			Level3Map.put("appsys_code",  map.get("appsys_code"));
		    			Level3Map.put("server_ip",  map.get("server_ip"));
		    			Level3Map.put("server_name",  map.get("server_name"));
		    			Level3Map.put("server_group",  map.get("serve_group"));
		     			
		     			Level3Map.put("ipAddress", map.get("ipAddress"));
		     			Level3Map.put("loadMode", map.get("loadMode"));
		     			Level3Map.put("serName", map.get("serName"));
		     			Level3Map.put("memConf", map.get("memConf"));
		     			Level3Map.put("cpuConf", map.get("cpuConf"));
		     			Level3Map.put("diskConf", map.get("diskConf"));
		     			Level3Map.put("ipAddress", map.get("ipAddress"));
		     			Level3Map.put("floatAddress", map.get("floating_ip"));
		     			Level3Map.put("autoCapture", map.get("autoCapture"));
		     			if(map.get("ipAddress") != null&&map.get("ipAddress").toString().length()!=0){
		     				Level3Map.put("checkflag", "是");
		     			}else{
		     				Level3Map.put("checkflag", "否");
		     			}
		     			
			     		dataList.add(Level3Map);
	     				}
			     	}
					}
		     	
	     		if(serverlistdel.size()>0){
	     			reportTypes.delete(0, reportTypes.length());
	     			Level4Map = new HashMap<String, Object>();
	     			Level4Map.put("srvCode","环境中已删除的服务器") ;
	     			Level4Map.put("_id", ++count);
	     			Level4Map.put("_parent", null);
	     			Level4Map.put("_is_leaf", false);
	     			Level4Map.put("serClass", null);
	     			Level4Map.put("appsys_code", null);
	    			Level4Map.put("server_ip", null);
	    			Level4Map.put("server_name", null);
	    			Level4Map.put("server_group", null);
	     			Level4Map.put("ipAddress", null);
	     			Level4Map.put("loadMode", null);
	     			Level4Map.put("serName", null);
	     			Level4Map.put("memConf", null);
	     			Level4Map.put("cpuConf", null);
	     			Level4Map.put("diskConf", null);
	     			Level4Map.put("ipAddress", null);
	     			Level4Map.put("floatAddress", null);
	     			Level4Map.put("autoCapture", null);
	     			Level4Map.put("checkflag", null);
	     			dataList.add(Level4Map);
	     			
	     			for(Map<String,String> map5: serverlistdel ){
	     				
	     				Level5Map = new HashMap<String, Object>(); 
			     		Level5Map.put("srvCode", map5.get("ipAddress"));
			     		Level5Map.put("aplCode",aplCode) ;
		     			Level5Map.put("_id", ++count);
		     			Level5Map.put("_parent", Level4Map.get("_id"));
		     			Level5Map.put("_is_leaf", true);
		     			Level5Map.put("serClass", map5.get("serClass"));
		     			Level5Map.put("appsys_code",  map5.get("appsys_code"));
		    			Level5Map.put("server_ip",  map5.get("server_ip"));
		    			Level5Map.put("server_name",  map5.get("srvCode"));
		    			Level5Map.put("server_group",  map5.get("serve_group"));
		     			
		     			Level5Map.put("ipAddress", map5.get("ipAddress"));
		     			Level5Map.put("loadMode", map5.get("loadMode"));
		     			Level5Map.put("serName", map5.get("serName"));
		     			Level5Map.put("memConf", map5.get("memConf"));
		     			Level5Map.put("cpuConf", map5.get("cpuConf"));
		     			Level5Map.put("diskConf", map5.get("diskConf"));
		     			Level5Map.put("ipAddress", map5.get("ipAddress"));
		     			Level5Map.put("floatAddress", map5.get("floating_ip"));
		     			Level5Map.put("autoCapture", map5.get("autoCapture"));
		     			Level5Map.put("checkflag", null);
			     		dataList.add(Level5Map);
	     			}
	     		}
	     		
	     	
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, dataList);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, dataList.size());
			modelMap.addAttribute("success", Boolean.TRUE);
					
			
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 更新属性类实例的参数值.
	 * @param serverValues 属性值键值对
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/saveServer", method = RequestMethod.POST)
	public @ResponseBody ModelMap saveServer(
			@RequestParam String serverValues,
			ModelMap modelMap) throws Exception {
		appCheckDesignService.saveServer(serverValues);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 查询weblogic配置信息
	 * @param aplCode
	 * @param changeMonth
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/weblogic_index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "aplCode", required = false) String aplCode,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					appCheckDesignService.queryWeblogicConfList(aplCode,request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, appCheckDesignService.queryWeblogicConfList(aplCode,request).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	
	/**
	 * 返回新建页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/createWeblogic", method  = RequestMethod.GET)
	public String create(
			@RequestParam(value = "aplCode", required = false) String aplCode
			) throws JEDAException{
		return viewPrefix + "weblogicConfCreate";
	}
	/**
	 * 返回编辑页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editWeblogic", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "weblogicConfEdit";
	}
	
	
	/**
	 * 获取服务器，返回[serverIps]
	 * 
	 * @param response
	 *            响应对象
	 * @throws IOException 
	 * @throws SQLException 
	 * @throws JEDAException
	 */

	@RequestMapping(value = "/getServerIps", method = RequestMethod.POST)
	public @ResponseBody void getServerOs_user(
			@RequestParam(value = "aplCode", required =false )String aplCode,
			ModelMap modelMap,
			HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
			{
	
		PrintWriter out = null;
		Object serverips = appCheckDesignService.getServerIps(aplCode);
		response.setCharacterEncoding("utf-8");
		out = response.getWriter();
		out.print(JSONArray.fromObject(serverips));
	}
}

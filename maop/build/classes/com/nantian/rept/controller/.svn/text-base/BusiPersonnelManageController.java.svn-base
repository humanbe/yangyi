package com.nantian.rept.controller;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.BusiPersonnelManageService;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/busipersonnelmanage")
public class BusiPersonnelManageController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(BusiPersonnelManageController.class);
	
	/** 领域对象名称 */
	private static final String domain = "BusiPersonnelManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private BusiPersonnelManageService busiPersonnelService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
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
	 * 返回业务联系人信息页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询业务联系人信息
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param sysId 系统编号
	 * @param sysName 系统名称
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "sysId", required = false) String sysId,
			@RequestParam(value = "sysName", required = false) String sysName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try{
			Map<String, Object> params = RequestUtil.getQueryMap(request, busiPersonnelService.fields);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					busiPersonnelService.queryBusiPersonnels(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<Map<String, String>>)request.getSession().getAttribute("buisPersonnelList4Export")).size());
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 查询业务联系人关联的所有应用系统编号简称
	 * @param response
	 */
	@RequestMapping(value = "/querySysIds", method = RequestMethod.GET)
	public @ResponseBody void querySysIds(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIds = busiPersonnelService.querySysIds();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIds));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 导出查询结果到文件
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("sysId", messages.getMessage("property.appsyscd"));
		columns.put("sequence", messages.getMessage("property.sequence"));
		columns.put("bpName", messages.getMessage("property.bpName"));
		columns.put("department", messages.getMessage("property.department"));
		columns.put("mobile", messages.getMessage("property.mobile"));
		columns.put("phone", messages.getMessage("property.phone"));
		columns.put("email", messages.getMessage("property.email"));
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, request.getSession().getAttribute("buisPersonnelList4Export"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		
		return "excelView";
	}
}

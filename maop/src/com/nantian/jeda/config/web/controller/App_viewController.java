/**
 * 
 */
package com.nantian.jeda.config.web.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;


import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.App_view;
import com.nantian.jeda.common.model.App_view_detail;
import com.nantian.jeda.config.service.App_viewService;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.component.log.Logger;



/**
 * 
 * @author gyc
 *
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/config/app_view")
public class App_viewController {
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(App_viewController.class);
	/**服务*/
	@Autowired
	private App_viewService appViewService;

	/** 领域对象名称 */
	private String domain = App_view.class.getSimpleName().toLowerCase();
	
	/** 视图前缀 */
	private String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/config/" + domain + "/" + domain + "_";
	
	/**
	 * 跳转到小窗页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/avportlet", method = RequestMethod.GET)
	public String aViewPortlet(ModelMap modelMap) throws JEDAException {
		return /*"jeda/config/app_view/app_view_portlet";*/viewPrefix + "portlet";
	}
	
	/**
	 * 后台管理起始页
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aviewindex", method = RequestMethod.GET)
	public String aViewIndex(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "info";
	}
	
	/**
	 * 双击查看页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewView", method = RequestMethod.GET)
	public String aViewView(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "view";
	}
	/**
	 * 小窗页面点击查看详情页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewDetail", method = RequestMethod.GET)
	public String aViewDetail(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "show";
	}
	
	/**
	 * 主编辑页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewMainEdit", method = RequestMethod.GET)
	public String aViewMainEdit(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "mainEdit";
	}
	/**
	 * 从表编辑页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewEdit", method = RequestMethod.GET)
	public String aViewEdit(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "edit";
	}
	/**
	 * 主新建页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewMainCreate", method = RequestMethod.GET)
	public String aViewMainCreate(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "maincreate";
	}
	
	/**
	 * 从表新建页面
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewCreate", method = RequestMethod.GET)
	public String aViewCreate(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "create";
	}
	
	/**
	 * 门户小窗数据加载
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@ResponseBody
	@RequestMapping(value = "/aViewFind", method = RequestMethod.POST)
	public ModelMap aViewFind(HttpServletRequest request,ModelMap modelMap,
			@RequestParam(value = "aview_time", required = false)String aview_time) throws JEDAException {
		
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, appViewService.aViewFind(aview_time));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 起始页数据加载
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/avtype", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aViewData(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, SQLException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				appViewService.avfields);
		
		try {
			modelMap.addAttribute("data", appViewService.queryAViewInfo(start,
					limit, sort, dir, params,request));
			
			//modelMap.addAttribute("count", appViewService.aViewCount(params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, (
					(List<App_view_detail>)request.getSession().getAttribute("appViewInfoExport")).size());
			
			modelMap.addAttribute("success", Boolean.TRUE);			
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}
	
	/**
	 * 双击查看页面加载
	 * @param avd_id
	 * @param avd_rel_id
	 * @param modelMap
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewView", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aviewview(
			@RequestParam(value="avd_id",required = true) String avd_id,
			@RequestParam(value="avd_rel_id",required=true) String avd_rel_id,
			ModelMap modelMap,
			HttpServletRequest request){
		try {
			modelMap.addAttribute("data",appViewService.queryDblViewById(avd_id,avd_rel_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	/**
	 * 从表编辑页面数据加载
	 * @param avd_id
	 * @param avd_rel_id
	 * @param modelMap
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/aViewSubView", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aviewsubview(
			@RequestParam(value="avd_id",required = true) String avd_id,
			@RequestParam(value="avd_rel_id",required=true) String avd_rel_id,
			ModelMap modelMap,
			HttpServletRequest request){
		try {
			modelMap.addAttribute("data",appViewService.querySubViewById(avd_id,avd_rel_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 小窗详细数据加载
	 * @param avd_id
	 * @param avd_rel_id
	 * @param modelMap
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/aViewDetail", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aviewDetail(
			@RequestParam(value="avd_id",required = true) String avd_id,
			@RequestParam(value="avd_rel_id",required=true) String avd_rel_id,
			ModelMap modelMap,
			HttpServletRequest request){
		try {
			modelMap.addAttribute("data",appViewService.queryDblViewById(avd_id,avd_rel_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 后台起始页删除数据
	 * @param avd_ids
	 * @param modelMap
	 * @return
	 * @throws DataIntegrityViolationException
	 * @throws Exception
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewDelete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap aviewdelete(
			@RequestParam(value = "avd_ids", required = true) String[] avd_ids,
			@RequestParam(value = "rel_ids", required = true) String[] rel_ids,
			ModelMap modelMap) throws DataIntegrityViolationException,Exception,JEDAException {	
		try{
			appViewService.deleteByIds(avd_ids,rel_ids);
			modelMap.addAttribute("success", Boolean.TRUE);		
			} catch (Exception e) {
				e.printStackTrace();
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			}
		    return modelMap;
	}
	/**
	 * 主编辑和主新建页面的删除
	 * @param avd_ids
	 * @param rel_ids
	 * @param modelMap
	 * @return
	 * @throws DataIntegrityViolationException
	 * @throws Exception
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/aViewSubDelete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap aviewsubdelete(
			@RequestParam(value = "avd_ids", required = true) String[] avd_ids,
			@RequestParam(value = "rel_ids", required = true) String[] rel_ids,
			ModelMap modelMap) throws DataIntegrityViolationException,Exception,JEDAException {	
		try{
			appViewService.deleteSubByIds(avd_ids,rel_ids);
			modelMap.addAttribute("success", Boolean.TRUE);		
			} catch (Exception e) {
				e.printStackTrace();
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			}
		    return modelMap;
	}
	
	/**
	 * 主编辑页面
	 * @param aview_rel_id
	 * @param aview_name
	 * @param aview_desc
	 * @param aview_oper
	 * @param aview_time
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/aViewMainEdit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aViewMainEdit(
			@RequestParam(value = "aview_rel_id", required = true) String aview_rel_id,
			@RequestParam(value = "aview_name",required = true) String aview_name,
			@RequestParam(value = "aview_desc", required = true) String aview_desc,
			@RequestParam(value = "aview_oper",required  = true) String aview_oper,
			@RequestParam(value = "aview_time",required = true) String aview_time,
			ModelMap modelMap) throws Exception {
		try{
			appViewService.saveOrUpdate(aview_rel_id,aview_name,aview_desc,aview_oper,aview_time);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 从表数据编辑
	 * @param avd_id
	 * @param avd_rel_id
	 * @param avd_simpdesc
	 * @param avd_descdetail
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/aViewEdit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap gycEdit(
			@RequestParam(value = "avd_id", required = true) String avd_id,
			@RequestParam(value = "avd_rel_id",required = true) String avd_rel_id,
			@RequestParam(value = "avd_type", required = true) String avd_type,
			@RequestParam(value = "avd_simpdesc",required  = true) String avd_simpdesc,
			@RequestParam(value = "avd_descdetail",required = true) String avd_descdetail,
			ModelMap modelMap) throws Exception {
		try{
			appViewService.subSaveOrUpdate(avd_id, avd_rel_id, avd_type,avd_simpdesc, avd_descdetail);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	/**
	 * 新建主表
	 * @param aview_rel_id
	 * @param aview_name
	 * @param aview_desc
	 * @param aview_oper
	 * @param aview_time
	 * @param request
	 * @param response
	 * @param modelMap
	 * @throws IOException
	 */
	@RequestMapping(value = "/aViewMainCreate", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap saveCreate(
			@ModelAttribute App_view app_view,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException{
			modelMap.clear();
			try{
				appViewService.mainSave(app_view);
				modelMap.addAttribute("success", Boolean.TRUE);
			} catch (Exception e) {
				e.printStackTrace();
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			}
			return modelMap;
	}
	/**
	 * 新建从表
	 * @param aview_rel_id
	 * @param aview_name
	 * @param aview_desc
	 * @param aview_oper
	 * @param aview_time
	 * @param request
	 * @param response
	 * @param modelMap
	 * @throws IOException
	 */
	@RequestMapping(value = "/aViewCreate", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap aViewCreate(
			@ModelAttribute App_view_detail app_view_detail,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap)
			throws IOException{
		modelMap.clear();
		try{
			appViewService.save(app_view_detail);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 获取主表的序列
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/seqFind", method = RequestMethod.POST)
	public @ResponseBody
	void seqFind( ModelMap modelMap,
	HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
	{
			PrintWriter out = null;
			Object aview_rel_id = appViewService.seqFind();
			HashMap<String,String> map =new HashMap<String, String>();
			map.put("aview_rel_id", aview_rel_id.toString());
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(map));
	}
	/**
	 * 从表序列
	 * @param modelMap
	 * @param request
	 * @param response
	 * @throws IOException
	 * @throws SQLException
	 */
	@RequestMapping(value = "/subSeqFind", method = RequestMethod.POST)
	public @ResponseBody
	void subSeqFind( ModelMap modelMap,
	HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException
	{
			PrintWriter out = null;
			Object avd_id = appViewService.subSeqFind();
			HashMap<String,String> map =new HashMap<String, String>();
			map.put("avd_id", avd_id.toString());
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(map));
	}
	/**
	 * 根据一条主表数据对应的所有从表数据
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/tableFind", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap tableFind(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			@RequestParam(value = "aview_rel_id", required = true) String aview_rel_id,
			HttpServletRequest request, HttpServletResponse response,ModelMap modelMap){
		
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				appViewService.avfields);
		try{
			modelMap.addAttribute("data",appViewService.tableFind(start,limit,sort,dir,aview_rel_id,params));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	/**
	 * 导出为excel文件
	 * @RequestMapping value对应的值加上'.xls'后缀 
	 * @param request
	 * @param modelMap
	 * @return "aViewExcel"
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/aViewExcel.xls", method = RequestMethod.GET)
	public String aViewExcel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		columns.put("aview_rel_id","关联序号");
		columns.put("aview_desc", "功能描述");
		
		columns.put("avd_simpdesc", "概括描述");
		columns.put("avd_descdetail", "详细描述");
		columns.put("avd_type", "工具类型");
		
		columns.put("aview_oper","发布人员");
		columns.put("aview_time", "发布时间");

		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("appViewInfoExport");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		
		return "excelView";//在mvc.xml中的配置项
	}
}

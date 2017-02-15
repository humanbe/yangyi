package com.nantian.jedarpt.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.ComUtil;
import com.nantian.jeda.Constants;
import com.nantian.jeda.common.model.Menu;
import com.nantian.jeda.security.service.MenuService;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.jedarpt.service.ReportDesignService;
import com.nantian.jedarpt.service.ReportShowService;
import com.nantian.jedarpt.vo.JedaExcelTemplateVo;
import com.nantian.jedarpt.vo.JedaReportMenuVo;
import com.nantian.jedarpt.vo.JedaReportVo;

/**
 * 报表定制controller
 * @author linaWang
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/jedarpt")
public class ReportDesignController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ReportDesignController.class);
	/** 领域对象名称 */
	private static final String domain = "rptmanage";
	/** 视图前缀 */
	private static final String viewPrefix = "jedarpt/" + domain + "/" + domain+"_";
    
	@Autowired
	private ReportDesignService reportDesignService;
	@Autowired
	private MenuService menuService;
	@Autowired
	private ReportShowService reportShowService;
	
	/**
	 * 返回列表页面
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index(){
		return viewPrefix + "index";
	}

	/**
	 * 分页查询报表信息
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getJedaRptList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getJobInfoList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, reportDesignService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, reportDesignService.getReportInfoList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, reportDesignService.countReportInfoList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String createJedaRpt(){
		return viewPrefix + "create";
	}
	
	/**
	 * 保存定制报表数据
	 * @param 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	void createJedaRpt(@ModelAttribute JedaReportVo jedaReportVo,
			@ModelAttribute JedaExcelTemplateVo jedaExcelTemplateVo,
			@ModelAttribute JedaReportMenuVo jedaReportMenuVo,
			HttpServletRequest request,HttpServletResponse response) throws Exception{
		PrintWriter resOut = response.getWriter();
		//获取报表参数信息
		String params = ServletRequestUtils.getStringParameter(request, "report_params_create");
		//获取报表字段信息
		String columns = ServletRequestUtils.getStringParameter(request, "report_columns_create");
		//获取报表规则信息
		String rules = ServletRequestUtils.getStringParameter(request, "report_rules_create");
		//获取报表角色信息
		String roles = ServletRequestUtils.getStringParameter(request, "report_roles_create");
		reportDesignService.createJedaRpt(jedaReportVo,jedaExcelTemplateVo,jedaReportMenuVo,
				params,columns,rules,roles,request);
		resOut.write("{\"success\":true}");
	}
	
	/**
	 * 获取报表参数信息
	 * Map<String,String> columns的key为下列字段：
		    param_en_name
		 	param_ch_name
		 	param_type
		 	default_value
			dic_code
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/getReportParamList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getReportParamList(@RequestParam(value = "sql", required = false) String sql, 
			@RequestParam(value = "params", required = false) String oldParams,
			@RequestParam(value = "reportId", required = false) String reportId, 
			HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		List<Map<String,String>> params = new ArrayList<Map<String,String>>();
		if(reportId!=null && !reportId.equals("")){ //修改
			params = reportShowService.getReportParamsByReportCode(Integer.valueOf(reportId));
		}else{ //新建、SQL更新
			List<Map<String, Object>> listParams = null;
	        if(oldParams!=null && !oldParams.equals("")){
				JSONArray arrayParams = JSONArray.fromObject(oldParams);
				//将json格式的数据转换成list对象
				listParams = (List<Map<String, Object>>) JSONArray.toCollection(arrayParams, Map.class);
			}
			if(sql!=null && !sql.equals("")){
				String[] s = sql.split("#");
				for(int t=0 ; t<s.length ; t++){
					if(!s[t].equals(",")){
						Map<String,String> param = new HashMap<String,String>();
						if(t%2 != 0){
							if(listParams!=null && listParams.size()>0){
								String paramName = "";
								Boolean b = false ;
								for(Map<String, Object> map : listParams){
									paramName = ComUtil.checkJSONNull(map.get("param_en_name")) ;
									if(paramName.equals(s[t])){
										b = true;
										param.put("param_en_name", paramName); //名称
										param.put("param_ch_name", ComUtil.checkJSONNull(map.get("param_ch_name")));   //别名
										param.put("param_type", ComUtil.checkJSONNull(map.get("param_type")));  //类型
										if(map.get("default_value")!=null && !map.get("default_value").equals("")){
											param.put("default_value",ComUtil.checkJSONNull(map.get("default_value")));
										}else{
											param.put("default_value", ""); //默认值
										}
										if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
											param.put("dic_code",ComUtil.checkJSONNull(map.get("dic_code")));
										}
										break ;
									}
								}
								if(!b){
									param.put("param_en_name", s[t]); //名称
									param.put("param_ch_name", s[t]);   //别名
									param.put("param_type", "textfield");  //类型
									param.put("default_value", ""); //默认值
								}
							}else{
								param.put("param_en_name", s[t]); //名称
								param.put("param_ch_name", s[t]);   //别名
								param.put("param_type", "textfield");  //类型
								param.put("default_value", ""); //默认值
								//param.put("dic_code", ""); //关联字典
							}
							if(!params.contains(param)){
								params.add(param);
							}
						}
					}
				}
			}
		}
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,params);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取报表字段信息
	 * Map<String,String> columns的key为下列字段：
		    column_trans_name
		 	column_show_name
		 	column_desc
		 	column_width
			column_visible
			column_trans
			column_dic_item
			column_sort
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getReportColumnList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getReportColumnList(@RequestParam(value = "sql", required = false) String sql, 
			@RequestParam(value = "reportId", required = false) String reportId, 
			HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		List<Map<String,String>> columns = new ArrayList<Map<String,String>>();
		if(reportId!=null && !reportId.equals("")){ //修改
			columns = reportShowService.getReportColumnsByReportCode(Integer.valueOf(reportId));
		}else{ //新建
			if(sql!=null && !sql.equals("")){
				int fromIndex = 0;
				int fromIndex1 = sql.indexOf("from");
				int fromIndex2 = sql.indexOf("FROM");
				if(fromIndex1==-1 && fromIndex2!=-1){
					fromIndex = fromIndex2;
				}else if(fromIndex2==-1 && fromIndex1!=-1 ){
					fromIndex = fromIndex1;
				}else if(fromIndex2!=-1 && fromIndex1!=-1){
					if(fromIndex1 <= fromIndex2){
						fromIndex = fromIndex1;
					}else{
						fromIndex = fromIndex2;
					}
				}else{
					logger.info("报表SQL语法错误：未找到FROM关键字！");
					logger.info("错误SQL："+sql);
				}
				String str = (sql.substring(sql.indexOf("select")+6, fromIndex)).trim();
				String[] cols = str.split("#,#");
				for(int t=0 ; t<cols.length ; t++){
					Map<String,String> column = new HashMap<String,String>();
					//查询字段
					String col = cols[t]; 
					col = (col.substring(col.lastIndexOf(" as ")+4)).trim();
					column.put("column_en_name", col); //字段名称
					List<Map<String, String>> list = reportDesignService.getColumnByName(col);
					if(list!=null && list.size()>0){ //字段属性值复用
						Map<String, String> map = list.get(0);
						if(map.get("column_ch_name")!=null && !map.get("column_ch_name").equals("")){
							column.put("column_ch_name", map.get("column_ch_name"));
						}else{
							column.put("column_ch_name", col);  
						}
						if(map.get("column_desc")!=null && !map.get("column_desc").equals("")){
							column.put("column_desc", map.get("column_desc"));
						}else{
							column.put("column_desc", "");  
						}
						if(map.get("is_trans")!=null && !map.get("is_trans").equals("")){
							column.put("is_trans", map.get("is_trans"));
						}else{
							column.put("is_trans", "0");   
						}
						if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
							column.put("dic_code", map.get("dic_code"));
						}
					}else{
						column.put("column_ch_name", col);   //字段别名
						column.put("column_desc", "");     //描述
						column.put("is_trans", "0");   //不关联转换
						//column.put("dic_code", ""); //关联字典
					}
					column.put("column_width", "自动"); //宽度自动
					column.put("is_visible", "1"); //字段可见
					column.put("column_sort", String.valueOf(t+1)); //排序
					columns.add(column);
				}
			}
		}
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,columns);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 获取未删除的报表规则信息
	 * @param sort 排序字段
	 * @param dir  排序方式
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getRuleList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getRuleList(@RequestParam(value = "reportId", required = true) String reportId,
			ModelMap modelMap) throws AxisFault, Exception{
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,reportDesignService.getRules(reportId));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回展现路径配置页面
	 * @return 
	 */
	@RequestMapping(value = "/getShowPath", method = RequestMethod.GET)
	public String getShowPath(){
		return viewPrefix + "show_path";
	}
	
	/**
	 * 返回展现路径配置页面
	 * @return 
	 */
	@RequestMapping(value = "/getShowPathForEdit", method = RequestMethod.GET)
	public String getShowPathForEdit(){
		return viewPrefix + "show_path_edit";
	}

	/**
	 * 获取配置菜单目录树，定制报表节点不显示
	 * @param node 父级菜单编号
	 * @return 
	 */
	@RequestMapping(value = "/getShowPathTree", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> getShowPathTree(
			@RequestParam("node") String node){
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		List<String> reportCodes = reportDesignService.getReportCodes();
		List<Map<String, Object>> menus = menuService.findByParentNode(node);
		for(Map<String, Object> map : menus){
			String menuCode = (String)map.get("id");
			Boolean b = false;
			for(int t=0;t<reportCodes.size();t++){
				String code = String.valueOf(reportCodes.get(t)).trim();
				if(code.equals(menuCode)){
					b = true;
					break ;
				}
			}
			if(!b){
				map.put("checked", false);
				list.add(map);
			}
		}
		return list;
	}
	
	/**
	 * 获取未删除的报表规则信息
	 * @param sort 排序字段
	 * @param dir  排序方式
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getRoleList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getRoleList(@RequestParam(value = "reportId", required = true) String reportId,
			ModelMap modelMap) throws AxisFault, Exception{
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,reportDesignService.getRoleList(reportId));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String viewJedaRpt() {
		return viewPrefix + "view";
	}

	/**
	 * 根据ID查询作业相关信息
	 * @param jobid 作业编号
	 */
	@RequestMapping(value = "/view/{reportId}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap viewJedaRpt(@PathVariable("reportId") String reportId, ModelMap modelMap) throws Exception {
		Map<String,String> map = new HashMap<String,String>();
		//报表基本信息
		Map<String, String> report = reportShowService.getReportInfoByReportCode(Integer.valueOf(reportId));
		//报表关联模板信息
		Map<String, String> template = reportShowService.getTemplateByReportCode(Integer.valueOf(reportId));
		//报表关联菜单信息
		Map<String, String> menu = reportDesignService.getReportMenuByReportCode(Integer.valueOf(reportId));
		if(report!=null && report.size()>0){
			map.putAll(report);
		}
		if(template!=null && template.size()>0){
			map.putAll(template);
		}
		if(menu!=null && menu.size()>0){
			map.putAll(menu);
		}
		modelMap.addAttribute("data", map);
		//报表关联规则信息
		modelMap.addAttribute("dataRules",reportDesignService.getReportRulesByReportCode(Integer.valueOf(reportId))); 
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String editJedaRpt() {
		return viewPrefix + "edit";
	}

	/**
	 * 更新修改数据
	 * @param jobid 作业编号
	 * @param checkJobInfo 作业基本信息对象
	 */
	@RequestMapping(value = "/edit/{reportId}", method = RequestMethod.POST)
	public @ResponseBody
	void editJedaRpt(@ModelAttribute JedaReportVo jedaReportVo,
			@ModelAttribute JedaExcelTemplateVo jedaExcelTemplateVo,
			@ModelAttribute JedaReportMenuVo jedaReportMenuVo,
			@PathVariable("reportId") java.lang.Integer reportId,
			HttpServletRequest request,HttpServletResponse response) throws Exception{
		PrintWriter resOut = response.getWriter();
		//获取报表参数信息
		String params = ServletRequestUtils.getStringParameter(request, "report_params_edit");
		//获取报表字段信息
		String columns = ServletRequestUtils.getStringParameter(request, "report_columns_edit");
		//获取报表规则信息
		String rules = ServletRequestUtils.getStringParameter(request, "report_rules_edit");
		//获取报表角色信息
		String roles = ServletRequestUtils.getStringParameter(request, "report_roles_edit");
		reportDesignService.editJedaRpt(jedaReportVo,jedaExcelTemplateVo,jedaReportMenuVo,
				params,columns,rules,roles,request);
		resOut.write("{\"success\":true}");
	}
	
	/**
	 * 根据菜单编号获取所有父级菜单
	 * @param response
	 * @return 
	 * @throws IOException 
	 */
	@RequestMapping(value = "/getPathByMenuCode", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getPathByMenuCode(@RequestParam(value = "menuCode", required = true) String menuCode,ModelMap modelMap){
		String path = "";
		if(menuCode!=null && !menuCode.equals("")){
			Menu menu = (Menu)menuService.get(menuCode);
			path = getParentByMenuCode(menuCode,"[" + menu.getName() + "]"); ;
		}
		modelMap.addAttribute("path", path); 
		return modelMap;
	}
	
	/**
	 * 迭代获取所有父级菜单名称
	 * @param menuCode 菜单编号
	 * @return
	 */
	public String getParentByMenuCode(String menuCode,String parent){
		Menu menu = (Menu)menuService.get(menuCode);
		if(menu.getParent()!=null){
			parent = "[" + menu.getParent().getName() + "]--" + parent;
			return getParentByMenuCode(menu.getParent().getId(),parent);
		}
		return parent;
	}
	
	/**
	 * 批量删除
	 * @param reportIds 报表编号数组
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteJedaRpts(@RequestParam(value = "reportIds", required = true) Integer[] reportIds, ModelMap modelMap)
			throws DataIntegrityViolationException,Exception {
		reportDesignService.deleteJedaRptByIds(reportIds);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
}

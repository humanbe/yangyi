package com.nantian.jedarpt.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.check.service.JobDesignService;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jedarpt.service.ReportShowService;

/**
 * 报表展现controller
 * @author linaWang
 *
 */
/**
 * @author user
 *
 */
@Controller
@RequestMapping("/" + Constants.APP_PATH+ "/jedarptshow")
public class ReportShowController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ReportShowController.class);
	/** 领域对象名称 */
	private static final String domain = "rptshow";
	/** 视图前缀 */
	private static final String viewPrefix = "jedarpt/" + domain + "/" + domain+"_";

	@Autowired
	private ReportShowService reportShowService;
	
	@Autowired
	private JobDesignService jobDesignService;
	
	@Autowired
	private AppInfoService appInfoService;
	
	//文本格式
	private String STRING = "textfield";
    //日期格式
	private String DATE = "datefield";
    //时间格式
	private String TIME = "timefield";
	//下拉框
	private String COMBO = "combo";
	//应用系统编号（与jeda_column表中的column_en_name对应）
	private String APPSYSCODE = "appsys_code";
	private String APPSYSNAME = "appsys_name";
	//应用系统名称（与appInfoService.querySystemIDAndNames4NoDelHasAop()中的系统名称别名对应）
	private String APPSYS_CODE = "appsysCode";
	private String APPSYS_NAME = "appsysName";
	
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
	@RequestMapping(value = "/getReportInfoList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getReportInfoList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "reportId", required = false) String reportId,
			HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		//查询字段与字段值映射map
		Map<String, Object> params = new HashMap<String, Object>();
		//获取报表编号
		String reportCode = reportId;
		if(reportCode!=null && !reportCode.equals("")){
			request.getSession().removeAttribute("jedaReportShowList");//移除上次查询的数据
			params = reportShowService.getQueryMap(request, getFormParams(reportCode));
			//分页查询数据
			List<Map<String, Object>> list = reportShowService.getReportList(start,limit,sort,dir,reportCode,params);
			//查询所有数据
			List<Map<String, Object>> listExp = reportShowService.getReportListForExp(reportCode,params);
			request.getSession().setAttribute("jedaReportShowList"+reportCode, listExp);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,list);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, listExp.size());
			modelMap.addAttribute("success", Boolean.TRUE);
		}else{
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}
	
	/**
	 * 获取前台GridPanel动态列
	 * @param reportId 报表编号
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getCols", method = RequestMethod.POST)
	public @ResponseBody ModelMap getCols(
			@RequestParam(value = "reportId", required = true) String reportId,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		String fieldsNamesStr = "";
		String columnModelsStr = "";
		
		//获取报表编号
		String reportCode = reportId;
		if(reportCode!=null && !reportCode.equals("")){
			//获取报表关联字段
			List<Map<String, String>> columns = reportShowService.getReportColumnsByReportCode(Integer.valueOf(reportCode));
			if(columns!=null && columns.size()>0){
				fieldsNames.append("[");
				columnModels.append("[new Ext.grid.RowNumberer() , ");
			}
			for(Map<String, String> map : columns){
				String nameEn = (String) map.get("column_en_name");
				String nameCh = (String) map.get("column_ch_name");
				String width = (String) map.get("column_width");
				String visible = (String) map.get("is_visible");
				String dicCode = (String) map.get("dic_code");
				String isTrans = (String) map.get("is_trans"); //1-需要转换
				fieldsNames.append("{name:'").append(nameEn).append("'},");
				columnModels.append("{header:'").append(nameCh).append("',")
									.append("dataIndex:'").append(nameEn).append("',");
				if(width!=null && !width.equals("")){
					columnModels.append("width:").append(width).append(",");
				}
				if(visible!=null && visible.equals("0")){
					columnModels.append("hidden:true,");
				}	
				if(dicCode!=null && !dicCode.equals("")){ //数据字典存储值转显示值
					if(isTrans!=null && isTrans.equals("1")){
						columnModels.append("renderer : function(value) {");
						columnModels.append("var index = store_"+dicCode+".find('value', value);");
						columnModels.append("if (index == -1) {");
						columnModels.append("return value;");
						columnModels.append("} else {");
						columnModels.append("return store_"+dicCode+".getAt(index).get('name');");
						columnModels.append("}");
						columnModels.append("},");
					}
				}	
				if(nameEn.equals(APPSYSCODE)){ //显示系统名称
					columnModels.append("renderer : function(value) {");
					columnModels.append("var index = appsysStore.find('appsysCode', value);");
					columnModels.append("if (index == -1) {");
					columnModels.append("return value;");
					columnModels.append("} else {");
					columnModels.append("return appsysStore.getAt(index).get('appsysName');");
					columnModels.append("}");
					columnModels.append("},");
				}
				columnModels.append("sortable:true },");
			}
		}
		if(fieldsNames!=null){
			fieldsNamesStr = fieldsNames.toString();
			fieldsNamesStr = fieldsNamesStr.substring(0, fieldsNamesStr.length()-1).concat("]");
		}
		if(columnModels!=null){
			columnModelsStr = columnModels.toString();
			columnModelsStr = columnModelsStr.substring(0, columnModelsStr.length()-1).concat("]");
		}
		modelMap.addAttribute("fieldsNames", fieldsNamesStr);
		modelMap.addAttribute("columnModel", columnModelsStr);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}

	/**
	 * 获取前台FormPanel动态查询条件
	 * @param reportId 报表编号
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getFormItems", method = RequestMethod.POST)
	public @ResponseBody ModelMap getFormItems(
			@RequestParam(value = "reportId", required = true) String reportId,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		StringBuilder formItems = new StringBuilder();
		String formItemsStr = "";
		
		//获取报表编号
		String reportCode = reportId;
		if(reportCode!=null && !reportCode.equals("")){
			//获取报表关联参数
			List<Map<String, String>> params = reportShowService.getReportParamsByReportCode(Integer.valueOf(reportCode));
			if(params!=null && params.size()>0){
				formItems.append("[");
			}
			for(Map<String, String> map : params){
				String nameEn = (String) map.get("param_en_name");
				String nameCh = (String) map.get("param_ch_name");
				String type = (String) map.get("param_type");
				String defaultVal = (String) map.get("default_value");
				String dicCode = (String) map.get("dic_code");
				formItems.append("{xtype : '").append(type).append("',");
				formItems.append(" fieldLabel : '").append(nameCh).append("',");
				formItems.append(" name : '").append(nameEn).append("',");
				if(defaultVal!=null && !defaultVal.equals("")){
					formItems.append("value : '").append(defaultVal).append("',");
				}
				if(type!=null && type.equals(STRING)){  //文本框
					formItems.append(" maxLength : 100,");
				}else if(type!=null && type.equals(COMBO)){ //下拉菜单项
					if(nameEn.equals(APPSYSCODE)){ //传系统编号
						formItems.append(" store : appsysStore,");
						formItems.append(" valueField : 'appsysCode',");
						formItems.append(" displayField : 'appsysName',");
						//查询匹配
						formItems.append(" listeners : {");
						formItems.append("  scope : this ,");
						formItems.append("  beforequery : function(e){");
						formItems.append("   var combo = e.combo;");
						formItems.append("   combo.collapse();");
						formItems.append("   if(!e.forceAll){");
						formItems.append("     var input = e.query.toUpperCase();");
						formItems.append("     var regExp = new RegExp('.*' + input + '.*');");
						formItems.append("     combo.store.filterBy(function(record, id){");
						formItems.append("       var text = record.get(combo.displayField);");
						formItems.append("       return regExp.test(text);");
						formItems.append("     });");
						formItems.append("     combo.restrictHeight();");
						formItems.append("     combo.expand();");
						formItems.append("     return false;");
						formItems.append("   }");
						formItems.append("  }");
						formItems.append(" },");
					}
					if(nameEn.equals(APPSYSNAME)){ //传系统名称
						formItems.append(" store : appsysStore,");
						formItems.append(" valueField : 'appsysName',");
						formItems.append(" displayField : 'appsysName',");
					}
					formItems.append(" hiddenName : '").append(nameEn).append("',");
					formItems.append(" mode : 'local',");
					formItems.append(" triggerAction : 'all',");
					formItems.append(" forceSelection : true,");
				}else if(type!=null && type.equals(DATE)){  //日期
					formItems.append(" format : 'Ymd',");
					formItems.append(" editable : false,");
					formItems.append(" value : new Date(),");
				}else if(type!=null && type.equals(TIME)){  //时间
					formItems.append(" format : 'H:i:s',");
					formItems.append(" maxValue : '23:59 PM',");
					formItems.append(" minValue : '0:00 AM',");
					formItems.append(" increment : 60 ,");
					formItems.append(" value : new Date().format('Y-m-d H:i:s').substring(11),");
				}
				//配置数据字典
				if(dicCode!=null && !dicCode.equals("")){
					formItems.append(" store : ").append("store_").append(dicCode).append(",");
					formItems.append(" valueField : 'value',");
					formItems.append(" displayField : 'name',");
				}
				formItems.append(" tabIndex : this.tabIndex++ },");
			}
		}
		if(formItems!=null){
			formItemsStr = formItems.toString();
			formItemsStr = formItemsStr.substring(0, formItemsStr.length()-1).concat("]");
		}
		modelMap.addAttribute("formItems", formItemsStr);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 根据菜单编号获取报表关联的所有数据字典对象
	 * @param reportId 报表编号
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getDicItems", method = RequestMethod.POST)
	public @ResponseBody ModelMap getDicItems(
			@RequestParam(value = "reportId", required = true) String reportId,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Set<String> dicItems = new HashSet<String>();
		//获取报表编号
		String reportCode = reportId;
		if(reportCode!=null && !reportCode.equals("")){
			//获取报表关联参数
			List<Map<String, String>> params = reportShowService.getReportParamsByReportCode(Integer.valueOf(reportCode));
			for(Map<String, String> param : params){
				String dicCode = (String) param.get("dic_code");
				if(dicCode!=null && !dicCode.equals("")){
					dicItems.add(dicCode);
				}
			}
			//获取报表关联字段
			List<Map<String, String>> columns = reportShowService.getReportColumnsByReportCode(Integer.valueOf(reportCode));
			for(Map<String, String> column : columns){
				String dicCode = (String) column.get("dic_code");
				if(dicCode!=null && !dicCode.equals("")){
					dicItems.add(dicCode);
				}
			}
		}
		modelMap.addAttribute("dicItems", dicItems);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 配置查询表单的字段及其字段类型
	 * @param reportCode
	 * @return
	 */
	public Map<String, String> getFormParams(String reportCode){
		//查询字段与字段类型映射map
		Map<String, String> fields = new HashMap<String, String>();
		//获取报表关联字段
		List<Map<String, String>> reportParams = reportShowService.getReportParamsByReportCode(Integer.valueOf(reportCode));
		if(reportParams!=null && reportParams.size()>0){
			for(Map<String, String> map : reportParams){
				String nameEn = (String) map.get("param_en_name");
				String type = (String) map.get("param_type");
				if(null != nameEn && !nameEn.isEmpty()) {
					if(type.equals(DATE)) {
						fields.put(nameEn,FieldType.DATE);
					}else if(type.equals(TIME)) {
						fields.put(nameEn,FieldType.TIME);
					}else if(type.equals(COMBO)) {
						fields.put(nameEn,FieldType.OBJECT);
					}else{
						fields.put(nameEn,FieldType.STRING);
					}
				}
			}
		}
		return fields;
	}
	
	/**
	 * Excel导出报表数据
	 * @param reportId 报表编号
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String export(@RequestParam(value = "reportId", required = true) String reportId,
									HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		//经过数据字典处理后导出Excel的数据列表
		List<Map<String,Object>> showMap = new ArrayList<Map<String,Object>>();
		//获取报表编号
		//String reportCode = reportShowService.getReportCodeByMenuCode(menuId);
		String reportCode = reportId;
		//定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		if(reportCode!=null && !reportCode.equals("")){
			//获取报表关联字段
			List<Map<String, String>> reportColumns = reportShowService.getReportColumnsByReportCode(Integer.valueOf(reportCode));
			for(Map<String, String> map : reportColumns){
				String nameEn = (String) map.get("column_en_name");
				String nameCh = (String) map.get("column_ch_name");
				columns.put(nameEn, nameCh);
			}
			//获取查询列表数据
			List<Map<String, Object>> reportlist = (List<Map<String, Object>>) request.getSession().getAttribute("jedaReportShowList"+reportId);
			//获取数据字典显示值与数据库存储值的映射关系
			Map<String, String> itemMap = jobDesignService.findMap();
			//获取报表字段关联数据字典
			Map<String,String> dicItems = reportShowService.getReportColumnDicItemsMap(Integer.valueOf(reportCode));
			//获取未删除、已上线的所有应用系统编号及名称
			List<Map<String, String>> appsyss = (List<Map<String, String>>)appInfoService.querySystemIDAndNames4NoDelHasAop();
			//处理列表中的数据字典显示字段及应用系统名称
			if(reportlist!=null && reportlist.size()>0){
				for (Map<String,Object> map : reportlist) {
					for(String nameEn : dicItems.keySet()){
						String dicItemValue = String.valueOf(map.get(nameEn));
						String dicItemName = dicItems.get(nameEn);
						if(dicItemValue!=null && !dicItemValue.equals("")){
							String showValue = itemMap.get(dicItemName.concat(dicItemValue));
							if(showValue!=null && !showValue.equals("")){
								map.put(nameEn,showValue);
							}
						}
					}
					//应用系统编号
					String appsysCode = (String) map.get(APPSYSCODE);
					if(appsysCode!=null && !appsysCode.equals("")){
						for(Map<String, String> appsys : appsyss){
							if(appsys.get(APPSYS_CODE).equals(appsysCode)){
								String showValue = appsys.get(APPSYS_NAME);
								if(showValue!=null && !showValue.equals("")){
									map.put(APPSYSCODE,showValue);
								}
							}
						}
					}
					showMap.add(map);
				}
			}
			
			//获取报表关联模板
			Map<String, String> template = reportShowService.getTemplateByReportCode(Integer.valueOf(reportCode));
			if(template!=null && template.size()>0){
				String templateCode = String.valueOf(template.get("template_code"));
				String templateName = template.get("template_en_name");
				String startRow = template.get("start_row_num");
				String startCol = template.get("start_col_num");
				//模板编号#模板名称#开始行号#开始列号
				request.getSession().setAttribute("jedaRptTemplate", templateCode+"#"+templateName+"#"+startRow+"#"+startCol);
			}else{
				request.getSession().setAttribute("jedaRptTemplate", null);
			}
		}
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY,columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,showMap);
		return "excelViewJedaRpt";
	}
	
	
	/**
	 * 获取报表柱形图图表数据
	 * @param reportId 报表编号
	 * @param xItem x轴数据
	 * @param yItem y轴数据
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/getColumnChart", method = RequestMethod.POST)
	public @ResponseBody ModelMap getColumnChart(
			@RequestParam(value = "reportId", required = true) String reportId,
			@RequestParam(value = "groupItem", required = true) String groupItem,
			@RequestParam(value = "xItem", required = true) String xItem,
			@RequestParam(value = "yItem", required = true) String yItem,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		// 输出开始日志
		logger.info("获取柱形图图表数据开始，报表编号为："+reportId);
		logger.info("统计分组："+groupItem);
		logger.info("统计科目名称："+xItem);
		logger.info("统计科目值："+yItem);
		try {
			String chartOptionJson = reportShowService.getRptColumnChart(reportId,groupItem,xItem,yItem,request);
			modelMap.addAttribute("columnChartOptionJson", chartOptionJson);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Throwable e) {
			e.printStackTrace();
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		logger.info("获取柱形图图表数据结束，报表编号为："+reportId);
		return modelMap;
	}
	
	/**
	 * 获取报表饼状图图表数据
	 * @param reportId 报表编号
	 * @param nameItem 统计科目名称
	 * @param valueItem 统计科目值
	 * @param percision 精度
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/getPieChart", method = RequestMethod.POST)
	public @ResponseBody ModelMap getPieChart(                                   
			@RequestParam(value = "reportId", required = true) String reportId,
			@RequestParam(value = "nameItem", required = true) String nameItem,
			@RequestParam(value = "valueItem", required = true) String valueItem,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		logger.info("获取饼状图图表数据开始，报表编号为："+reportId);
		logger.info("统计科目名称："+nameItem);
		logger.info("统计科目值："+valueItem);
		try {
			String chartOptionJson = reportShowService.getRptPieChart(reportId,nameItem,valueItem,request);
			modelMap.addAttribute("pieChartOptionJson", chartOptionJson);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Throwable e) {
			e.printStackTrace();
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		logger.info("获取饼状图图表数据结束，报表编号为："+reportId);
		return modelMap;
	}
	
	/**
	 * 获取报表查询列，作为图表下拉菜单的数据源
	 * @param response
	 */
	@RequestMapping(value = "/getRepColsStoreByReportCode", method = RequestMethod.GET)
	public @ResponseBody void getRepColsStoreByReportCode(
			@RequestParam(value = "reportId", required = true) String reportId,
			HttpServletResponse response){
		PrintWriter out = null;
		try {
			List<Map<String, String>> colList = new ArrayList<Map<String, String>>();
			List<Map<String, String>> cols = reportShowService.getRepColsStoreByReportCode(Integer.valueOf(reportId));
			for(Map<String, String> map : cols){
				for(String key : map.keySet()){
					if(key.equals("name")){
						if(map.get(key).equals(APPSYSCODE)){
							map.put(key, "应用系统");
						}
					}
				}
				colList.add(map);
			}
			Object rptCols = colList;
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(rptCols));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	public static void main(String[] args){
		Double d  = 10d ;
		String t = "2.4" ;
		System.out.println(Double.valueOf(t));
		System.out.println(Double.valueOf(t)/d);
		System.out.println(String.valueOf(Double.valueOf(t)/d*100).concat("%"));
	}
	
}

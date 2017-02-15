package com.nantian.rept.controller;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.batik.transcoder.Transcoder;
import org.apache.batik.transcoder.TranscoderException;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.JPEGTranscoder;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.fop.svg.PDFTranscoder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.NumberUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.MonthRptManageService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.service.impl.BatchTransService;
import com.nantian.rept.service.impl.MonthRptRescrService;
import com.nantian.rept.service.impl.MonthRptTimesTransService;
import com.nantian.rept.service.impl.MonthRptTransService;
import com.nantian.rept.service.impl.NetResrcService;
import com.nantian.rept.service.impl.TimesTransService;
import com.nantian.rept.service.impl.TransService;
import com.nantian.rept.service.impl.WeblogicService;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.smrpt.service.MonthRptDayResrcService;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/monthrptmanage")
public class MonthRptManageController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(MonthRptManageController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "MonthRptManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private MonthRptManageService monthRptManageService;
	
	@Autowired
	private RptItemConfService rptItemConfService;
	
	@Autowired
	private TransService transService;
	
	@Autowired
	private MonthRptTransService monthRptTransService;
	
	@Autowired
	private NetResrcService netResrcService;
	
	@Autowired
	private BatchTransService batchTransService;
	
	@Autowired
	private WeblogicService weblogicService;
	
	@Autowired
	private TimesTransService timesTransService;
	
	@Autowired
	private MonthRptRescrService monthRptRescrService;
	
	@Autowired
	private MonthRptTimesTransService monthRptTimesTransService;
	
	@Autowired
	private MonthRptDayResrcService monthRptDayResrcService;
	
	/**
	 * 返回月报管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询月报数据集合
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @param subSheetName
	 * @param month
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			@RequestParam(value = "month", required = true) String month,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
			// 输出开始日志
			if (logger.isEnableFor("Component0001")) {
				logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
			List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
			List<Map<String, Object>> copyList = new ArrayList<Map<String, Object>>();
			
			try{
				// 动态获取科目名
				List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
				// 获取数据
				Map<String, Object> dateTransData = monthRptManageService.monthRptDataSwitchMethod(
						itemList, sheetName, aplCode, month, subSheetName, request);
				if(null != dateTransData && (dateTransData.size() >0)){
					if(null != dateTransData.get("statisticalData") && (((List<Map<String,Object>>)dateTransData.get("statisticalData")).size() >0)){
						dataList.addAll((List<Map<String,Object>>)dateTransData.get("statisticalData"));
					}
					if(null != dateTransData.get("metadata") && (((List<Map<String,Object>>)dateTransData.get("metadata")).size() >0)){
						dataList.addAll((List<Map<String,Object>>)dateTransData.get("metadata"));
					}
				}
				
				//深拷贝数据从而进行格式化数据, 防止影响其他引用
				for(int i = 0; i < dataList.size(); i++){
					Map<String, Object> map = dataList.get(i);
					Map<String, Object> copyMap = new LinkedHashMap<String, Object>();
					for(String key : map.keySet()){
						copyMap.put(key, map.get(key));
					}
					copyList.add(copyMap);
				}
				
				//格式化数值格式
				for (Map<String,Object> dataMap : copyList) {
						for (String mapKey : dataMap.keySet()) {
							String value = ComUtil.checkNull(dataMap.get(mapKey));
							if(NumberUtils.isNumber(value)){
								dataMap.put(mapKey, NumberUtil.format(Double.valueOf(value), 
										NumberUtil.FORMAT_PATTERN_10));
							}
						}
				}
				request.getSession().setAttribute("monthRptData", copyList);
				modelMap.addAttribute("data", copyList);
				modelMap.addAttribute("success", Boolean.TRUE);
			}catch(Exception e){
				e.printStackTrace();
				// 输出异常结束日志
				if (logger.isEnableFor("Component0099")) {
					logger.log("Component0099", ComUtil.getCurrentMethodName());
				}
				modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
				modelMap.addAttribute("success", Boolean.FALSE);
			}
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		return modelMap;
	}
	
	/**
	 * 取得前台页面原型gridpanel动态列
	 * @param aplCode 系统编码
	 * @param reportType 报表类型
	 * @param sheetName 报表名称
	 * @param subSheetName 子名称
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/getCols", method = RequestMethod.POST)
	public @ResponseBody ModelMap getColumns(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		// 动态获取科目名
		List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		switch(ReptConstants.sheetEnum.getSheetEnum(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 最近13个月日交易量: 
			case	最近13个月月交易量: monthRptTransService.getColumns(itemList, modelMap);
				break;
			case 当月日交易量: 
			case 当月日交易成功率: 
			case 当月日交易响应时间: transService.getColumns(itemList, modelMap);
				break;
			case 当月日网络资源使用情况: netResrcService.getColumns(itemList, modelMap);
				break;
			case 当月日批量执行情况: batchTransService.getColumns(itemList, modelMap);
				break;
			case 当月weblogic使用情况: weblogicService.getColumns(itemList, modelMap);
				break;
			case 当月分钟和秒交易情况: timesTransService.getColumns(itemList, modelMap);
				break;
			case 当月系统资源使用率: monthRptDayResrcService.getColumns(itemList, modelMap);
				break;
			case 最近13个月系统资源使用率: monthRptRescrService.getColumns(itemList, modelMap);
				break;
			case	最近13个月秒钟交易量峰值:
			case 最近13个月分钟交易量峰值: monthRptTimesTransService.getColumns(itemList, modelMap);
				break;
			default : 
				if(itemList.size() > 0){
					fieldsNames.append("[");
					columnModels.append("[new Ext.grid.RowNumberer(),");
				}
				for (RptItemConfVo rptItemConfVo : itemList) {
					// 1.动态字段
					fieldsNames.append("{name : '")
									  .append("item")
									  .append(rptItemConfVo.getItemSeq())
									  .append("'}")
									  .append(",");
					// 2.动态列
					columnModels.append("{header : '")
										.append(rptItemConfVo.getItemName())
										.append("',")
										.append("dataIndex : '")
										.append("item")
										.append(rptItemConfVo.getItemSeq())
										.append("',")
										.append("sortable : true,")
										.append("width : 150")
										.append("}")
										.append(",");
				}
				if(itemList.size() > 0){
					fieldsNames.deleteCharAt(fieldsNames.length()-1);
					columnModels.deleteCharAt(columnModels.length()-1);
				}
				fieldsNames.append("]");
				columnModels.append("]");
				modelMap.addAttribute("fieldsNames", fieldsNames.toString());
				modelMap.addAttribute("columnModel", columnModels.toString());
				break;
		}
		return modelMap;
	}
	
	/**
	 * 根据数据库配置项获取chart图表
	 * @param appsysCd
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getCharts", method = RequestMethod.POST)
	public @ResponseBody ModelMap getCharts(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "month", required = true) String month,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		try {
			// 根据数据库配置项获取chart图表
			Map<String, String> chartOptionJsonMap = monthRptManageService.getRptCharts(
					aplCode, reportType, sheetName, month, subSheetName, request);

			modelMap.addAttribute("chartOptionJson", chartOptionJsonMap);
			modelMap.addAttribute("success", Boolean.TRUE);
			
		} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		
		return modelMap;
	}
	
	/**
	 * 导出月报数据及图表
	 * @param aplCode 系统代码
	 * @param reportType 报表类型
	 * @param sheetName 功能名称
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String export(@RequestParam(value = "aplCode", required = true) String aplCode,
									@RequestParam(value = "reportType", required = true) String reportType,
									@RequestParam(value = "sheetName", required = false) String sheetName,
									@RequestParam(value = "month", required = true) String month,
									@RequestParam(value = "subSheetName", required = true) String subSheetName,
									@RequestParam(value = "clearFlag", required = true) String clearFlag,
									HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		Map<String, Object> params = RequestUtil.getQueryMap(request, rptItemConfService.fields);
		List<Map<String,Object>> dataList = null;//new ArrayList<Map<String,Object>>();
		
		//中文查询条件解码
		String decodeSheetName = "";
		if(params.get("sheetName") != null){
			try {
				decodeSheetName = URLDecoder.decode(params.get("sheetName").toString().substring(1, params.get("sheetName").toString().length()-1),"utf-8");
				params.put("sheetName", "%"+decodeSheetName+"%");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
				// 输出异常结束日志
				if (logger.isEnableFor("Component0099")) {
					logger.log("Component0099", ComUtil.getCurrentMethodName());
				}
			}
		}
		try {
			// 动态获取科目名
			List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, decodeSheetName);
			dataList = (List<Map<String, Object>>) request.getSession().getAttribute("monthRptData");
			if(dataList == null){
				dataList = new ArrayList<Map<String,Object>>();
				// 获取数据
				Map<String, Object> dateTransData = monthRptManageService.monthRptDataSwitchMethod(itemList, decodeSheetName,
						aplCode, month, URLDecoder.decode(subSheetName, "utf-8"), request);
				if(null != dateTransData && (dateTransData.size() >0)){
					if(null != dateTransData.get("statisticalData") && (((List<Map<String,Object>>) dateTransData.get("statisticalData")).size() >0)){
						dataList.addAll((List<Map<String,Object>>)dateTransData.get("statisticalData"));
					}
					if(null != dateTransData.get("metadata") && (((List<Map<String,Object>>)dateTransData.get("metadata")).size() >0)){
						dataList.addAll((List<Map<String,Object>>)dateTransData.get("metadata"));
					}
				}
				
				//格式化数值格式
				for (Map<String,Object> dataMap : dataList) {
					for (String mapKey : dataMap.keySet()) {
						if(NumberUtil.isNumeric(dataMap.get(mapKey).toString())){
							dataMap.put(mapKey, NumberUtil.format(Double.valueOf(dataMap.get(mapKey).toString()), NumberUtil.FORMAT_PATTERN_10));
						}
					}
				}
			}
			// 定义列显示顺序以及列标题
			Map<String, String> columns = monthRptManageService.configExcelColumns(
					itemList, decodeSheetName, month, URLDecoder.decode(subSheetName, "utf-8"));
			modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
			// 运行情报总结sheet信息
			// chart图表数据
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dataList);
			// chart下载图片全路径名
			if(Boolean.valueOf(clearFlag)){
				request.getSession().removeAttribute("monthRptChart");
			}
			modelMap.addAttribute("monthRptChart", (Map<String, List<byte[]>>)request.getSession().getAttribute("monthRptChart"));
			// chart图表及数据对应的sheetName及subSheetName
			modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME, sheetName);
			modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SUB_SHEETNAME, subSheetName);
			// 运行情报总结sheet信息
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		return "excelViewMonthRpt";			//返回servletName
	}
	
	/**
	 * 根据已选的报表列表导出
	 * @param aplCode
	 * @param month
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/excelSelected", method = RequestMethod.GET)
	public String excelSelected(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		try {
			//chart图表信息
			modelMap.addAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, 
					(Map<String, List<byte[]>>)request.getSession().getAttribute("monthRptChart"));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		
		//返回servletName
		return "excelViewMonthRptSelected";
	}
	
	/**
	 * 获取日报树形菜单
	 * @param response
	 */
	@RequestMapping(value = "/browseTreeData", method = RequestMethod.POST)
	public @ResponseBody void browseTreeData(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			HttpServletRequest request, HttpServletResponse response) {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
    	List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		try{
			List<Map<String,Object>> dataList = rptItemConfService.queryTreeObj(aplCode, reportType);
			jsonList = monthRptManageService.transform2MenuTree(dataList);
			
			out = response.getWriter();
			out.print(jsonList);
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", ComUtil.getCurrentMethodName());
			}
		} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
		}finally{
			out.close();
		}
	}
	
	/**
	 * 导出图片到字节输出流
	 * @param type
	 * @param svg
	 * @param count
	 * @param request
	 * @param modelMap
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/exportChartPic", method = RequestMethod.POST)
	public @ResponseBody ModelMap exportChartPic(
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "type", required = true) String type,
			@RequestParam(value = "svg", required = true) String svg,
			@RequestParam(value = "count", required = true) int count,
			HttpServletRequest request, ModelMap modelMap){
		
		// 下载图片的字节输出流
		ByteArrayOutputStream bo = null;
		List<byte[]> chartBytesList = new ArrayList<byte[]>();
		Map<String,List<byte[]>> chartBytesListMap = new LinkedHashMap<String , List<byte[]>>();
		if(count == 0){
			//清空上次执行导出时保存在session中的图片流数据
			request.getSession().removeAttribute("monthRptChart");
		}
		try{
			svg = svg.replaceAll(":rect", "rect");
			Transcoder t = null;
			if(type.equals("image/png")){
				t = new PNGTranscoder();
			}else if(type.equals("image/jpeg")){
				t = new JPEGTranscoder();
			}else if(type.equals("application/pdf")){
				t = new PDFTranscoder();
			}
			bo = new ByteArrayOutputStream();
			if(null != t){
				TranscoderInput input = new TranscoderInput(new StringReader(svg));
				TranscoderOutput output = new TranscoderOutput(bo);
				try{
					t.transcode(input, output);
				}catch(TranscoderException e){
					e.printStackTrace();
				}
			}
			bo.close();
			
			if(null != request.getSession().getAttribute("monthRptChart")){
				chartBytesListMap = (Map<String, List<byte[]>>) request.getSession().getAttribute("monthRptChart");
				if(null != chartBytesListMap.get(sheetName)){//判断是否存在此功能名字的键值
					chartBytesListMap.get(sheetName).add(bo.toByteArray());
				}else{
					chartBytesList.add(bo.toByteArray());
					chartBytesListMap.put(sheetName, chartBytesList);
				}
				request.getSession().setAttribute("monthRptChart", chartBytesListMap);
				/*chartBytesList = (List<byte[]>) request.getSession().getAttribute("monthRptChart");
				chartBytesList.add(bo.toByteArray());
				request.getSession().setAttribute("monthRptChart", chartBytesList);*/
			}else{
				chartBytesList.add(bo.toByteArray());
				chartBytesListMap.put(sheetName, chartBytesList);
				request.getSession().setAttribute("monthRptChart", chartBytesListMap);
				/*chartBytesList.add(bo.toByteArray());
				request.getSession().setAttribute("monthRptChart", chartBytesList);*/
			}
			
			modelMap.addAttribute("success", Boolean.TRUE);
			return modelMap;
		
		}catch(IOException e){
			e.printStackTrace();
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
			return modelMap;
		}finally{
			try {
					if(null != bo)	bo.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
	}
	
	/**
	 * 获取已选的月报列表的图表
	 * @param aplCode
	 * @param reportType
	 * @param month
	 * @param sheetNames
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/getSelectedMonthReport", method = RequestMethod.POST)
	public @ResponseBody ModelMap getSelectedMonthReport(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "month", required = true) String month,
			@RequestParam(value = "sheetNames", required = true) String sheetNames,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		
		String[] sheetName = sheetNames.split(",");
		String subSheetName = "";
		Map<String,Map<String,String>> chartsMap = new LinkedHashMap<String, Map<String,String>>();
		Map<String, String> chartOptionJsonMap = new LinkedHashMap<String, String>();
		//清空session标志
		boolean withoutChart = true;
		
		try {
			for(String sheet : sheetName){
				int startPos = sheet.lastIndexOf("(");
				int endPos = sheet.lastIndexOf(")");
				if(startPos > 0 && endPos > 0 && endPos >= startPos){
					subSheetName = sheet.substring(startPos + 1, endPos);
				}
				chartOptionJsonMap = monthRptManageService.getRptCharts(aplCode, reportType, sheet, month, subSheetName, request);
				chartsMap.put(sheet, chartOptionJsonMap);
				if(withoutChart && !chartOptionJsonMap.isEmpty()){
					withoutChart = false;
				}
			}
			
			//当要导出的sheet都没有图导出时清空session的图片数据
			if(withoutChart){
				request.getSession().removeAttribute("monthRptChart");
			}
			modelMap.addAttribute("chartsMap", chartsMap);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("withoutChart", withoutChart);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		
		return modelMap;
	}
}

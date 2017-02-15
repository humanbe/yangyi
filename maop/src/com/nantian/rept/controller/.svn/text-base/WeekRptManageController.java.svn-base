package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.RptChartConfService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.service.TransItemService;
import com.nantian.rept.service.WeekRptManageService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.rept.vo.WeekResourceVo;

/**
 * 周报控制处理器
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/weekrptmanage")
public class WeekRptManageController {
	/** 日志输出 */
	private static Logger logger = Logger.getLogger(WeekRptManageController.class);
	/** 模板管理领域对象名称 */
	private static String domain = "WeekRptManage";
	/** 视图前缀 */
	private static String viewPrefix = "rept/" + domain + "/" + domain;
	@Autowired
	private RptItemConfService rptItemConfService;
	@Autowired
	private WeekRptManageService weekRptManageService;
	@Autowired
	private RptChartConfService rptChartConfService;
	@Autowired
	private TransItemService transItemService;
	
	/**
	 * 返回周报管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException{
		return viewPrefix + "Index";
	}
	
	/**
	 * 获取周报数据
	 * @param start 开始记录索引
	 * @param limit 分页限制的记录数
	 * @param sort 排序字符串
	 * @param dir 升序或降序字符串
	 * @param aplCode 系统编号
	 * @param startDate 开始日期
	 * @param srvCode 服务器编号
	 * @param request 请求对象
	 * @param modelMap json格式的响应对象
	 * @return json格式的响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "srvCode", required = true) String srvCode,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		
		try {
			List<Map<String,Object>> list = weekRptManageService.findRptWeekTranAndResource(start, limit, sort, dir, aplCode, startDate, srvCode);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data", list);
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		
		return modelMap;
	}
	
	/**
	 * 编辑周报数据
	 * @param data json格式的数据字符串
	 * @param aplCode 系统编号
	 * @param srvCode 服务器编号
	 * @param request 请求对象
	 * @param modelMap json格式的响应对象
	 * @return json格式的响应对象
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@RequestParam(value = "data", required = true) String data,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "srvCode", required = true) String srvCode,
			HttpServletRequest request, 
			ModelMap modelMap)throws JEDAException{
		List<WeekResourceVo> resrcList = new ArrayList<WeekResourceVo>();
		WeekResourceVo vo = null;
		JSONArray array = JSONArray.fromObject(data);
		//将json格式的数据转换成list对象
		List<Map<String, Object>> list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
		
		for(Map<String, Object> map : list){
			vo = new WeekResourceVo();
			vo.setAplCode(aplCode);
			vo.setSrvCode(srvCode);
			vo.setCountWeek(ComUtil.checkJSONNull(map.get("countWeekValue")));
			vo.setCpuPeak(ComUtil.checkJSONNull(map.get("cpuPeak")));
			vo.setCpuOnlinePeakAvg(ComUtil.checkJSONNull(map.get("cpuOnlinePeakAvg")));
			vo.setCpuBatchPeakAvg(ComUtil.checkJSONNull(map.get("cpuBatchPeakAvg")));
			vo.setMemPeak(ComUtil.checkJSONNull(map.get("memPeak")));
			vo.setMemOnlinePeakAvg(ComUtil.checkJSONNull(map.get("memOnlinePeakAvg")));
			vo.setMemBatchPeakAvg(ComUtil.checkJSONNull(map.get("memBatchPeakAvg")));
			vo.setIoPeak(ComUtil.checkJSONNull(map.get("ioPeak")));
			vo.setIoOnlinePeakAvg(ComUtil.checkJSONNull(map.get("ioOnlinePeakAvg")));
			vo.setIoBatchPeakAvg(ComUtil.checkJSONNull(map.get("ioBatchPeakAvg")));
			resrcList.add(vo);
		}
		
		try{
			int result = 0;
			if(resrcList.size() != 0){
				result = weekRptManageService.update(resrcList);
			}
			
			if(result != 0) {
				modelMap.addAttribute("success", Boolean.TRUE);
			}else{
				modelMap.addAttribute("success", Boolean.FALSE);
			}
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 取得报表的动态列
	 * @param aplCode 系统编号
	 * @param reportType 报表类型(1:日报;2:周报;3:月报)
	 * @param sheetName 报表的sheet名称
	 * @param request 请求对象
	 * @param modelMap json格式的响应对象
	 * @return json格式的响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/getColumns", method = RequestMethod.POST)
	public @ResponseBody ModelMap getData(
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "reportType", required = false) String reportType,
			@RequestParam(value = "sheetName", required = false) String sheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		//可修改的字段
		Map<String, String> fieldsNmMap = new HashMap<String, String>();
		//不可修改的字段
		Map<String, String> fieldsNmMapNotAllowEdit = new HashMap<String, String>();
		//动态字段
		StringBuilder fieldsNames = new StringBuilder();
		//动态列
		StringBuilder columnModels = new StringBuilder();
		String field = "unkown";
		//ext页面的编辑器
		String editor = "";
		
		fieldsNmMap.put("CPU峰值(周)", "cpuPeak");
		fieldsNmMap.put("CPU联机峰值均值(周)", "cpuOnlinePeakAvg");
		fieldsNmMap.put("CPU批量峰值均值(周)", "cpuBatchPeakAvg");
		fieldsNmMap.put("内存峰值(周)", "memPeak");
		fieldsNmMap.put("内存联机峰值均值(周)", "memOnlinePeakAvg");
		fieldsNmMap.put("内存批量峰值均值(周)", "memBatchPeakAvg");
		fieldsNmMap.put("IO峰值(周)", "ioPeak");
		fieldsNmMap.put("IO联机峰值均值(周)", "ioOnlinePeakAvg");
		fieldsNmMap.put("IO批量峰值均值(周)", "ioBatchPeakAvg");
		fieldsNmMapNotAllowEdit.put("周数", "countWeek");
		fieldsNmMapNotAllowEdit.put("交易量值(周)", "weekTotalTrans");
		fieldsNmMapNotAllowEdit.put("交易量峰值(周)", "weekPeakTrans");
		
		try {
			// 动态获取科目名
			List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
			
			fieldsNames.append("[");
			columnModels.append("[new Ext.grid.RowNumberer()");
			for(int i = 0; i < itemList.size(); i++){
				if(i == 0){
					columnModels.append(",");
				}
				
				if(fieldsNmMap.get(itemList.get(i).getItemName()) != null){
					field = fieldsNmMap.get(itemList.get(i).getItemName());
					editor = "editor:new Ext.form.NumberField({minValue:0,maxValue:99999,allowDecimals:false,allowNegative:false})";
				}else if(fieldsNmMapNotAllowEdit.get(itemList.get(i).getItemName()) != null){
					field = fieldsNmMapNotAllowEdit.get(itemList.get(i).getItemName());
					editor = "";
				}
				
				fieldsNames.append("{name:'")
								  .append(field)
								  .append("'}");
				columnModels.append("{header:'")
									.append(itemList.get(i).getItemName())
									.append("',")
									.append("dataIndex:'")
									.append(field)
									.append("',")
									.append(" sortable : true}");
				
				if(editor != null && !"".equals(editor)){
					columnModels.insert(columnModels.length() - 1, "," + editor);
				}
				
				if(i == itemList.size() - 1){
					//统计周开始日的原始数据, 当数据需要更新时使用的表主键之一
					fieldsNames.append(",{name:'countWeekValue'}, {name:'reviseFlag'}");
					columnModels.append(",{dataIndex:'countWeekValue', hidden:true}, {dataIndex:'reviseFlag', hidden:true}");
				}else{
					fieldsNames.append(",");
					columnModels.append(",");
				}
			}
			
			fieldsNames.append("]");
			columnModels.append("]");
			
			modelMap.addAttribute("fieldsNames", fieldsNames.toString());
			modelMap.addAttribute("columnModel", columnModels.toString());
			modelMap.addAttribute("success", Boolean.TRUE);
			
		} catch (Throwable e) {
			e.printStackTrace();
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}
	
	/**
	 * 报表生成图像需要的数据
	 * @param aplCode 系统编号
	 * @param reportType 报表类型(1:日报;2:周报;3:月报)
	 * @param sheetName 报表的sheet名称
	 * @param startDate 统计周开始日
	 * @param srvCode 服务器编号
	 * @param request 请求对象
	 * @param response 响应对象
	 */
	@RequestMapping(value = "/getChartData", method = RequestMethod.POST)
	public @ResponseBody void chartData(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "srvCodes", required = true) String srvCodes,
			HttpServletRequest request, HttpServletResponse response){
		Map<String, String> yAxisMap = new LinkedHashMap<String, String>();
		Map<String, String> xAxisMap = new HashMap<String, String>();
		List<String> jsonList = new ArrayList<String>();
		
		PrintWriter out = null;
		String jsonData = "{}";
		//动态列
		yAxisMap.put("weekTotalTrans", "交易量值(周)");
		yAxisMap.put("weekPeakTrans",  "交易量峰值(周)");
		yAxisMap.put("cpuPeak", "CPU峰值(周)");
		yAxisMap.put("cpuOnlinePeakAvg", "CPU联机峰值均值(周)");
		yAxisMap.put("cpuBatchPeakAvg", "CPU批量峰值均值(周)");
		yAxisMap.put("memPeak", "内存峰值(周)"); 
		yAxisMap.put("memOnlinePeakAvg", "内存联机峰值均值(周)");
		yAxisMap.put("memBatchPeakAvg", "内存批量峰值均值(周)");
		yAxisMap.put("ioPeak", "IO峰值(周)");
		yAxisMap.put("ioOnlinePeakAvg", "IO联机峰值均值(周)");
		yAxisMap.put("ioBatchPeakAvg",  "IO批量峰值均值(周)");
		
		xAxisMap.put("countWeek", "周数");
		
		// 动态获取科目名
		List<RptItemConfVo> itemConfList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
		//获取配置信息
		List<RptChartConfVo> chartConfList = rptChartConfService.queryRptChartConfList(aplCode, reportType, sheetName);
		
		String[] srvCodeArr = srvCodes.split(",");
		for(String srvCode : srvCodeArr){
			//获取30周的数据, 一周一条数据
			List<Map<String,Object>> DataList = weekRptManageService.findRptWeekTranAndResource(
					0, 30, "", "ASC", aplCode, startDate, srvCode);
			
			if(itemConfList.size() != 0 && chartConfList.size() != 0 && DataList.size() != 0){
				jsonData = weekRptManageService.getChartData(
						itemConfList, chartConfList, DataList, xAxisMap, yAxisMap);
				jsonList.add(jsonData);
			}
		}
		
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(jsonList));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null) out.close();
		}
	}
	
	/**
	 * 查询系统编号和系统名称的映射集合
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseWeekRptAplCode", method = RequestMethod.GET)
	public @ResponseBody void browseWeekRptAplCode(
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object aplCodeNmMap = transItemService.queryAplCodeNmMap();
		
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(aplCodeNmMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
		
	}
	
	/**
	 * 查询服务器编号和服务器名称的映射集合
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseWeekRptSrvCode", method = RequestMethod.GET)
	public @ResponseBody void browseWeekRptSrvCode(
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object svrCodeNmMap = transItemService.querySrvCodeNmMap();
		
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(svrCodeNmMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null) out.close();
		}
	}
	
	/**
	 * 使用session保存图片的二进制数据
	 * @param aplCode 系统编号
	 * @param svg 图像数据
	 * @param imgType 图像类型
	 * @param request 请求对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/transformSvgDat", method = RequestMethod.POST)
	public @ResponseBody void transformSvgDat(
			@RequestParam(value = "svg", required = false) String svg, 
			@RequestParam(value = "imgType", required = false) String imgType, 
			HttpServletRequest request) throws JEDAException{
		request.getSession().removeAttribute("weekRptSvgDat");
		
		if(svg != null && !svg.equals("")){
			Map<String, byte[]> srvCodeSvgMap = new LinkedHashMap<String, byte[]>();
			JSONArray jsonArr = JSONArray.fromObject(svg);
			
			for(int i = 0; i < jsonArr.size(); i++){
				Object obj = jsonArr.getJSONObject(i);
				if(obj instanceof JSONObject){
					JSONObject json = (JSONObject) obj;
					byte[] svgDat = null;
					try {
						svgDat = weekRptManageService.transformChart2ByteArray(json.getString("chart"), imgType);
						srvCodeSvgMap.put(json.getString("srvCode"), svgDat);
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
			request.getSession().setAttribute("weekRptSvgDat", srvCodeSvgMap);
		}
	}
	
	/**
	 * 导出数据称excel文件
	 * @param aplCode 系统编号
	 * @param reportType 报表类型(1:日报;2:周报;3:月报)
	 * @param sheetName 报表的sheet名称
	 * @param startDate 统计周开始日
	 * @param srvCode 服务器编号
	 * @param request 请求对象
	 * @param modelMap json格式的响应对象
	 * @return servlet拦截器对应的bean名称
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String expose(
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "reportType", required = false) String reportType,
			@RequestParam(value = "sheetName", required = false) String sheetName,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "srvCodes", required = false) String srvCodes,
			HttpServletRequest request, ModelMap modelMap)throws JEDAException{
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		
		Map<String, String> pointerNmMap = new LinkedHashMap<String, String>();
		//动态列
		pointerNmMap.put("countWeek", "周数");
		pointerNmMap.put("weekTotalTrans", "交易量值(周)");
		pointerNmMap.put("weekPeakTrans",  "交易量峰值(周)");
		pointerNmMap.put("cpuPeak", "CPU峰值(周)");
		pointerNmMap.put("cpuOnlinePeakAvg", "CPU联机峰值均值(周)");
		pointerNmMap.put("cpuBatchPeakAvg", "CPU批量峰值均值(周)");
		pointerNmMap.put("memPeak", "内存峰值(周)"); 
		pointerNmMap.put("memOnlinePeakAvg", "内存联机峰值均值(周)");
		pointerNmMap.put("memBatchPeakAvg", "内存批量峰值均值(周)");
		pointerNmMap.put("ioPeak", "IO峰值(周)");
		pointerNmMap.put("ioOnlinePeakAvg", "IO联机峰值均值(周)");
		pointerNmMap.put("ioBatchPeakAvg",  "IO批量峰值均值(周)");
		
		Map<String, List<Map<String, Object>>> dataMap = new LinkedHashMap<String, List<Map<String, Object>>>();
		List<Map<String, Object>> dataList;
		String[] srvCodeArr = srvCodes.split(",");
		
		try{
			for(String srvCode : srvCodeArr){
			//获取30周的数据, 一条数据代表一周
				dataList = weekRptManageService.findRptWeekTranAndResource(
						0, 30, "", "ASC", aplCode, startDate, srvCode);
				dataMap.put(srvCode, dataList);
			}
			
			//获取图片的二进制数据
			Map<String, byte[]> chartBinDataMap = (Map<String, byte[]>) request.getSession().getAttribute("weekRptSvgDat");
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, dataMap);
			modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, pointerNmMap);
			modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME, sheetName);
			modelMap.addAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, chartBinDataMap);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		
		return "excelViewWeekRpt";
	}

}

package com.nantian.rept.controller;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.batik.transcoder.Transcoder;
import org.apache.batik.transcoder.TranscoderException;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.JPEGTranscoder;
import org.apache.batik.transcoder.image.PNGTranscoder;
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
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.NumberUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.AplAnalyzeService;
import com.nantian.rept.service.DayRptManageService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.service.ServerConfService;
import com.nantian.rept.service.TransItemService;
import com.nantian.rept.service.impl.BatchTransService;
import com.nantian.rept.service.impl.HoursTransService;
import com.nantian.rept.service.impl.MultTransService;
import com.nantian.rept.service.impl.NetResrcService;
import com.nantian.rept.service.impl.SysResrcService;
import com.nantian.rept.service.impl.TimesTransService;
import com.nantian.rept.service.impl.TransService;
import com.nantian.rept.service.impl.WeblogicService;
import com.nantian.rept.vo.AplAnalyzeVo;
import com.nantian.rept.vo.HoursTransVo;
import com.nantian.rept.vo.RptItemConfVo;
/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/dayrptmanage")
public class DayRptManageController {
	
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(DayRptManageController.class);
	
	/** 模板管理领域对象名称 */
	private static final String domain = "DayRptManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private DayRptManageService dayRptManageService;
	
	@Autowired
	private RptItemConfService rptItemConfService;
	
	@Autowired
	private BatchTransService batchTransService;
	
	@Autowired
	private TransService transService;
	
	@Autowired
	private HoursTransService hoursTransService;
	
	@Autowired
	private NetResrcService netResrcService;
	
	@Autowired
	private WeblogicService weblogicService;
	
	@Autowired
	private AplAnalyzeService aplAnalyzeService;
	
	@Autowired
	private TransItemService transItemService;
	
	@Autowired
	private MultTransService multTransService;
	
	@Autowired
	private TimesTransService timesTransService;
	
	@Autowired
	private SysResrcService sysResrcService;
	
	@Autowired
	private ServerConfService serverConfService;
	
	/**
	 * 返回日报管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 日报管理数据查询
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
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
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
		List<Map<String, Object>> copyList = new ArrayList<Map<String, Object>>();
		
		try {
			// 动态获取科目名
			List<RptItemConfVo> itemList = 	rptItemConfService.queryRptItemConfListForEval(aplCode, reportType, sheetName);
			
			// 获取数据
			Map<String, Object> dateTransData = (Map<String, Object>) dayRptManageService.dayRptDataSwitchMethod(itemList, sheetName, aplCode,
							startDate, endDate, subSheetName, request);
			if(null != dateTransData && (dateTransData.size() >0)){
				if(null != dateTransData.get("statisticalData") && (((List<Map<String,Object>>) dateTransData.get("statisticalData")).size() >0)){
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
			
			switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
				case 最近31天日交易情况:
				case 最近7天分小时交易情况:
				case 最近7天日批量执行情况:
				case 最近31天分钟和秒交易情况:
				case 最近31天日批量执行情况:
				case 最近31天日网络资源使用情况:
				case 当日网络资源使用情况:
				case 最近31天日weblogic使用情况:
				case 当日weblogic使用情况:
				case 系统资源使用率图表:
					//格式化数值格式&超峰值判断					for (Map<String,Object> dataMap : copyList) {
							for (String mapKey : dataMap.keySet()) {
								if(dataMap.get(mapKey) != null && NumberUtil.isNumeric(dataMap.get(mapKey).toString())){
									dataMap.put(mapKey, NumberUtil.format(Double.valueOf(dataMap.get(mapKey).toString()),
											NumberUtil.FORMAT_PATTERN_11));
								}
							}
							if(null != dataMap.get("exceedPeaks")){
								for (String exceedPeakItem : dataMap.get("exceedPeaks").toString().split(CommonConst.STRING_COMMA)) {
									dataMap.put(exceedPeakItem, dataMap.get(exceedPeakItem).toString().concat(CommonConst.SPACE).concat("超峰值"));
								}
							}
							if(null != dataMap.get("lowPeaks")){
								for (String lowPeakItem : dataMap.get("lowPeaks").toString().split(CommonConst.STRING_COMMA)) {
									dataMap.put(lowPeakItem, dataMap.get(lowPeakItem).toString().concat(CommonConst.SPACE).concat("低峰值")+NumberUtil.format(Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL), NumberUtil.FORMAT_PATTERN_5));
								}
							}
					}
					break;
				default:
					//多科目的查询
					
					break;
			}
			
			request.getSession().setAttribute("dayRptData", copyList);
			modelMap.addAttribute("data", copyList);
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
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		try {
			// 根据数据库配置项获取chart图表
			Map<String, String> chartOptionJsonMap = dayRptManageService.getRptCharts(aplCode, reportType, sheetName, startDate,
							endDate, subSheetName, request);
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
	 * 取得gridpanel动态列
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @param endDate
	 * @param subSheetName
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getCols", method = RequestMethod.POST)
	public @ResponseBody ModelMap getCols(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		
		try {
			// 动态获取科目名
			List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
			
			switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
				case 最近31天日交易情况:
					transService.getColumns(itemList, modelMap);
					break;
				case 最近7天分小时交易情况:
					hoursTransService.getColumns(itemList, modelMap, endDate);
					break;
				case 实时分小时累计交易情况:
					for (int i=0; i < itemList.size(); i++) {
						if(i == 0){
							fieldsNames.append("[");
							fieldsNames.append("{name : 'hour'}");
							columnModels.append("[new Ext.grid.RowNumberer(),");
							columnModels.append("{header : '小时', dataIndex : 'hour'}");
						}else{
							columnHeaderGroupList.add(itemList.get(i).getItemName());
							//当日
							fieldsNames.append("{name : '")
											.append("item").append(itemList.get(i).getItemSeq()).append(endDate)
											.append("'}")
											.append(",");
							columnModels.append("{header : '").append(endDate).append("',")
											.append("dataIndex : '").append("item").append(itemList.get(i).getItemSeq()).append(endDate).append("',")
											.append("sortable : true,")
											.append("width : 100")
											.append("}")
											.append(",");
							//峰值日
							HoursTransVo vo = (HoursTransVo) hoursTransService.queryPeakDate(aplCode, itemList.get(i).getItemCd(), endDate);
							if(vo!=null){
								fieldsNames.append("{name : '")
												.append("item").append(itemList.get(i).getItemSeq()).append(((HoursTransVo) hoursTransService.queryPeakDate(aplCode, itemList.get(i).getItemCd(), endDate)).getTransDate())
												.append("'}")
												.append(",");
								columnModels.append("{header : '").append(((HoursTransVo) hoursTransService.queryPeakDate(aplCode, itemList.get(i).getItemCd(), endDate)).getTransDate() + "峰值日").append("',")
												.append("dataIndex : '").append("item").append(itemList.get(i).getItemSeq()).append(((HoursTransVo) hoursTransService.queryPeakDate(aplCode, itemList.get(i).getItemCd(), endDate)).getTransDate()).append("',")
												.append("sortable : true,")
												.append("width : 100")
												.append("}")
												.append(",");
								//峰值占比	
								fieldsNames.append("{name : '")
												.append("item").append(itemList.get(i).getItemSeq()).append("percent")
												.append("'}");
								columnModels.append("{header : '").append("峰值占比").append("',")
												.append("dataIndex : '").append("item").append(itemList.get(i).getItemSeq()).append("percent").append("',")
												.append("sortable : true,")
												.append("width : 100")
												.append("}");
							}
						}
						
						if(i == itemList.size() - 1){
							fieldsNames.append("]");
							columnModels.append("]");
						}else{
							fieldsNames.append(",");
							columnModels.append(",");
						}
					}
					modelMap.addAttribute("columnHeaderGroupColspan", CommonConst.THREE_INT);
					modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
					modelMap.addAttribute("fieldsNames", fieldsNames.toString());
					modelMap.addAttribute("columnModel", columnModels.toString());
					break;
				case 最近7天日批量执行情况:
					String batchField = "unkown";
					Map<String, String> batchFieldsNmMap = new HashMap<String, String>();
					for (RptItemConfVo iVo : itemList) {
						batchFieldsNmMap.put(iVo.getItemName(), iVo.getItemCd());
					}
//					batchFieldsNmMap.put("批量名称", "PLTJ_PLMC");
//					batchFieldsNmMap.put("开始时间", "PLTJ_KSSJ");
//					batchFieldsNmMap.put("结束时间", "PLTJ_JSSJ");
//					batchFieldsNmMap.put("结束标志", "PLTJ_ZXSC");
//					batchFieldsNmMap.put("执行时长(秒)", "PLTJ_JSBZ");
					//获取最近七天日期列表					String fmEndDate = DateFunction.getNewFormatDateStr(endDate, "yyyyMMdd", "yyyy-MM-dd");
					for(int i =0; i > -7 ; i--){
						columnHeaderGroupList.add(DateFunction.getDateByFormatAndOffset(fmEndDate, 1, i));
					}
					for (int i=0; i < columnHeaderGroupList.size(); i++) {
						if(i == 0){
							fieldsNames.append("[{name : 'PLTJ_PLMC'},");
							for (String key : batchFieldsNmMap.keySet()) {
								if(batchFieldsNmMap.get(key).equalsIgnoreCase("PLTJ_PLMC")){
									columnModels.append("[new Ext.grid.RowNumberer() , {header : '")
												.append(key)
												.append("', dataIndex : 'PLTJ_PLMC', width : 200},");
								}
							}
						}
						//循环科目列表
						for(int j = 0; j < itemList.size(); j ++){
							if(batchFieldsNmMap.get(itemList.get(j).getItemName()) != null){
								batchField = batchFieldsNmMap.get(itemList.get(j).getItemName());
							}
							fieldsNames.append("{name:'").append(columnHeaderGroupList.get(i)).append(batchField).append("'}");
							columnModels.append("{header:'").append(itemList.get(j).getItemName()).append("',")
												.append("dataIndex:'").append(columnHeaderGroupList.get(i)).append(batchField).append("',")
												.append(" sortable : true");
							if(itemList.get(j).getItemCd().indexOf("PLTJ_PLMC") != -1){
								columnModels.append(",hidden : true");
							}
							columnModels.append("}");
							if(j != itemList.size() - 1){
								fieldsNames.append(",");
								columnModels.append(",");
							}
						}
						if(i == columnHeaderGroupList.size() - 1){
							fieldsNames.append("]");
							columnModels.append("]");
						}else{
							fieldsNames.append(",");
							columnModels.append(",");
						}
					}
					modelMap.addAttribute("columnHeaderGroupColspan", itemList.size());
					modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
					modelMap.addAttribute("fieldsNames", fieldsNames.toString());
					modelMap.addAttribute("columnModel", columnModels.toString());
					break;
				case 最近31天分钟和秒交易情况:
					timesTransService.getColumns(itemList, modelMap);
					break;
				case 最近31天日批量执行情况 :
					batchTransService.getColumns(itemList, modelMap);
					break;
				case 最近31天日网络资源使用情况:
					netResrcService.getColumns(itemList, modelMap);
					break;
				case 当日网络资源使用情况:
					netResrcService.getColumns(itemList, modelMap);
					break;
				case 最近31天日weblogic使用情况:
					weblogicService.getColumns(itemList, modelMap);
					break;
				case 当日weblogic使用情况:
					List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
					Map<String, Object> map = null;
					columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE);
					columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC);
					columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY);
					int childNum = 0;
					
					for(int i = 0; i < columnHeaderGroupList.size(); i++){
						String targetTypeName = "";
						if(i == 0){
							fieldsNames.append("[");
							columnModels.append("[new Ext.grid.RowNumberer(),");
						}
						
						childNum = 0;
						for(int j = 0; j < itemList.size(); j++){
							RptItemConfVo vo = itemList.get(j);
							targetTypeName = rptItemConfService.getItemAppName(itemList.get(i).getAplCode(), columnHeaderGroupList.get(i));
							if(i == 0 && (vo.getItemCd().toString().indexOf("日期") != -1 || vo.getItemCd().toString().indexOf("时间") != -1)){
								fieldsNames.append("{name:'item1'},");
								columnModels.append("{header:'" + vo.getItemCd().toString() + "', dataIndex : 'item1'},");
								map = new LinkedHashMap<String, Object>();
								map.put("columnsHeader", "");
								map.put("childNum", 1);
								listMap.add(map);
							}
							
							if(vo.getGroupParent() != null){
								if(vo.getGroupParent().indexOf(columnHeaderGroupList.get(i)) != -1){

									fieldsNames.append("{name:'")
													  .append(targetTypeName)
													  .append(CommonConst.UNDERLINE)
													  .append("item")
													  .append(vo.getItemSeq())
													  .append("'},");
									columnModels.append("{header:'")
														.append(vo.getItemCd())
														.append("',")
														.append("dataIndex:'")
														.append(targetTypeName)
														.append(CommonConst.UNDERLINE)
														.append("item")
														.append(vo.getItemSeq())
														.append("',")
														.append("sortable : true,")
														.append("width : 150},");
									childNum ++;
								}
							}
							
							if(j == itemList.size() -1){
								fieldsNames.deleteCharAt(fieldsNames.length() - 1);
								columnModels.deleteCharAt(columnModels.length() - 1);
							}
						}
						
						map = new LinkedHashMap<String, Object>();

						map.put("columnsHeader", targetTypeName);
						map.put("childNum", childNum);
						listMap.add(map);
						
						if(i != columnHeaderGroupList.size() -1){
							fieldsNames.append(",");
							columnModels.append(",");
						}
					}
					
					int count = 0;
					for(int i = 0; i < itemList.size(); i++){
						if(i == itemList.size() - 1){
							fieldsNames.append(", {name:'holidayFlag'},") //节假日标识
											  .append("{name:'statisticalFlag'}"); //统计值标识
							columnModels.append(",{header:'").append("节假日标识").append("',")
												.append("dataIndex:'").append("holidayFlag").append("',")
												.append("sortable:true").append(",")
												.append("hidden:true")
												.append("}")
												.append(",{header:'").append("统计值标识").append("',")//节假日标识
												.append("dataIndex:'").append("statisticalFlag").append("',")
												.append("sortable:true").append(",")
												.append("hidden:true")
												.append("}");//统计值标识
							map = new LinkedHashMap<String, Object>();
							map.put("columnsHeader", "");
							map.put("childNum", 2);
							listMap.add(map);
						}
						RptItemConfVo vo = itemList.get(i);
						if(vo.getGroupParent() != null || vo.getItemCd().toString().indexOf("日期") == -1 || vo.getItemCd().toString().indexOf("时间") == -1){
							continue;
						}
						
						if(count++ == 0){
							fieldsNames.append(",");
							columnModels.append(",");
						}
						
						fieldsNames.append("{name:'")
										  .append(vo.getItemCd())
										  .append("item")
										  .append(vo.getItemSeq())
										  .append("'}");
						columnModels.append("{header:'")
											.append(vo.getItemCd().toString())
											.append("',")
											.append("dataIndex:'")
											.append(vo.getItemCd().toString())
											.append("item")
											.append(vo.getItemSeq())
											.append("'}");
						
						map = new LinkedHashMap<String, Object>();
						map.put("columnsHeader", "");
						map.put("childNum", 1);
						listMap.add(map);
					}
					
					fieldsNames.append("]");
					columnModels.append("]");
					
					modelMap.addAttribute("fieldsNames", fieldsNames.toString());
					modelMap.addAttribute("columnModel", columnModels.toString());
					modelMap.addAttribute("columnHeaderGroupList", listMap);
					break;
				case 系统资源使用率图表:
					sysResrcService.getColumns(itemList, modelMap, subSheetName);
					break;
				default:
					//查询多科目的columns列表
					multTransService.getColumns(itemList, modelMap);
					break;
			}
			
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
	 * 获取日报树形菜单
	 * @param response
	 */
	@RequestMapping(value = "/browseTreeData", method = RequestMethod.POST)
	public @ResponseBody void browseTreeData(@RequestParam(value = "aplCode", required = true) String aplCode,
																	@RequestParam(value = "reportType", required = true) String reportType,
																	HttpServletRequest request, 
																	HttpServletResponse response){
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
    	List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		try{
			List<Map<String,Object>> dataList = rptItemConfService.queryTreeObj(aplCode, reportType);
			jsonList = dayRptManageService.getJosnObjectForTree(dataList);
			
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
	 * 获取日报树形菜单 -- 报告分析
	 * @param response
	 */
	@RequestMapping(value = "/browseTreeDataForAnalyse", method = RequestMethod.POST)
	public @ResponseBody void browseTreeDataForAnalyse(@RequestParam(value = "aplCode", required = true) String aplCode,
																	@RequestParam(value = "reportType", required = true) String reportType,
																	HttpServletRequest request, 
																	HttpServletResponse response){
		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
    	List<JSONObject> jsonList = new ArrayList<JSONObject>();
		PrintWriter out = null;
		try{
			List<Map<String,Object>> dataList = rptItemConfService.queryTreeObj(aplCode, reportType);
			jsonList = dayRptManageService.getJosnObjectForTreeForAnalyse(dataList);
			
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
			@RequestParam(value = "subSheetName", required = true) String subSheetName,
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
			request.getSession().removeAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY);
		}
		try{
			switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 系统资源使用率图表:
				if(!"".equals(subSheetName) && subSheetName.split(CommonConst.STRING_COMMA).length == 1){//单机查询系统资源
					sheetName = sheetName.concat("(").concat(subSheetName).concat(")");
				}
				break;
			default:
				break;
			}
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
			
			if(null != request.getSession().getAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY)){
				chartBytesListMap = (Map<String, List<byte[]>>) request.getSession().getAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY);
				if(null != chartBytesListMap.get(sheetName)){//判断是否存在此功能名字的键值
					chartBytesListMap.get(sheetName).add(bo.toByteArray());
				}else{
					chartBytesList.add(bo.toByteArray());
					chartBytesListMap.put(sheetName, chartBytesList);
				}
				request.getSession().setAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, chartBytesListMap);
			}else{
				chartBytesList.add(bo.toByteArray());
				chartBytesListMap.put(sheetName, chartBytesList);
				request.getSession().setAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, chartBytesListMap);
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
	 * 导出日报数据及图表
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
									@RequestParam(value = "startDate", required = true) String startDate,
									@RequestParam(value = "endDate", required = true) String endDate,
									@RequestParam(value = "subSheetName", required = true) String subSheetName,
									@RequestParam(value = "clearFlag", required = true) String clearFlag,
									HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		List<Map<String,Object>> dataList = null;
		try {
			String decodeSheetName = URLDecoder.decode(sheetName, "utf-8");
			String decodeSubSheetName = URLDecoder.decode(subSheetName, "utf-8");
			// 动态获取科目名（按科目名称长度排序）
			List<RptItemConfVo> itemListForEval = rptItemConfService.queryRptItemConfListForEval(aplCode, reportType, decodeSheetName);
			dataList = (List<Map<String, Object>>) request.getSession().getAttribute("dayRptData");
			if(dataList == null){
				dataList = new ArrayList<Map<String,Object>>();
				// 获取数据
				Map<String, Object> dateTransData = dayRptManageService.dayRptDataSwitchMethod(itemListForEval, 																																					decodeSheetName, 
																	aplCode,
																	startDate, 
																	endDate, 
																	URLDecoder.decode(subSheetName, "utf-8"), 
																	request);
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
							dataMap.put(mapKey, NumberUtil.format(Double.valueOf(dataMap.get(mapKey).toString()), NumberUtil.FORMAT_PATTERN_11));
						}
					}
				}
			}
			
			String transPeakDate =(null==dataList.get(0).get("transPeakDate"))?"":dataList.get(0).get("transPeakDate").toString();
			// 动态获取科目名(按科目序号排序)
			List<RptItemConfVo> itemListForExport = rptItemConfService.queryRptItemConfList(aplCode, reportType, decodeSheetName);
			// 定义列显示顺序以及列标题
			Map<String, String> columns = configExcelColumns(itemListForExport, decodeSheetName, endDate, URLDecoder.decode(subSheetName, "utf-8"),transPeakDate);
			modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
			// 运行情报总结sheet信息
			Map<String, Object> queryMap = new HashMap<String,Object>();
			queryMap.put("aplCode", aplCode);
			queryMap.put("transDate", endDate);
			List<AplAnalyzeVo> runStateDataList = aplAnalyzeService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "aplCode", "ASC", queryMap);
			modelMap.addAttribute(ReptConstants.DEFAULT_RUN_STATE_SUMMARY, runStateDataList);
			// chart图表数据
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dataList);
			// chart下载图片全路径名
			if(Boolean.valueOf(clearFlag)){
				request.getSession().removeAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY);
			}
			modelMap.addAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, (Map<String, List<byte[]>>)request.getSession().getAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY));
			// chart图表及数据对应的sheetName及subSheetName
			switch(ReptConstants.sheetNameItem.getSheetNameItem(decodeSheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 系统资源使用率图表:
				if(decodeSubSheetName.split(CommonConst.STRING_COMMA).length > 1){//多台主机组合查询系统资源
					modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME, sheetName);
				}else{//单机查询系统资源
					modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME, sheetName.concat("(").concat(subSheetName).concat(")"));
				}
				break;
			default:
				modelMap.addAttribute(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME, sheetName);
				break;
			}
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
		return "excelViewDayRpt";			//返回servletName
	}
	
	/**
	 * 配置导出excel的数据列标题
	 * @param itemList 科目列表
	 * @param sheetName 功能名称
	 * @param endDate 日报日期
	 * @return Map<String, String>
	 */
	public Map<String, String> configExcelColumns(List<RptItemConfVo> itemList, String sheetName, String endDate, String subSheetName, String transPeakDate){
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		//	分支判断
		switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
		case 最近7天分小时交易情况:
			columns = hoursTransService.getConfigurableXlsColumns(itemList, endDate);
			break;
		case 实时分小时累计交易情况:
			columns = hoursTransService.getConfigurableXlsColumns2(itemList,endDate,transPeakDate);
			break;
		case 最近7天日批量执行情况:
			columns.put("rows", "2");
			columns.put("PLTJ_PLMC", "步骤名");
			LinkedHashMap<String,Object> columnsKeys = new LinkedHashMap<String,Object>();
			columnsKeys.put("PLTJ_PLMC", "步骤名");
			columnsKeys.put("PLTJ_KSSJ", "开始时间");
			columnsKeys.put("PLTJ_JSSJ", "结束时间");
			columnsKeys.put("PLTJ_JSBZ", "批量状态");
			columnsKeys.put("PLTJ_ZXSC", "用时（分）");
			String fmEndDate = DateFunction.getNewFormatDateStr(endDate, "yyyyMMdd", "yyyy-MM-dd");
			for(int i =0; i > -7 ; i--){
				for (String _colKey : columnsKeys.keySet()) {
					if(!"步骤名".equals(columnsKeys.get(_colKey).toString())){
						columns.put(DateFunction.getDateByFormatAndOffset(fmEndDate, 1, i)
														     .concat(_colKey),
										 DateFunction.getDateByFormatAndOffset(fmEndDate, 1, i)
														     .concat(CommonConst.UNDERLINE)
														     .concat(columnsKeys.get(_colKey).toString()));
					}
				}
			}
			break;
		case 最近31天分钟和秒交易情况:
			columns = timesTransService.getConfigurableXlsColumns(itemList);
			break;
		case 最近31天日批量执行情况: 
			columns = batchTransService.getConfigurableXlsColumns(itemList);
			break;
		case 最近31天日网络资源使用情况:
			columns = netResrcService.getConfigurableXlsColumns(itemList);
			break;
		case 当日网络资源使用情况:
			columns = netResrcService.getConfigurableXlsColumns(itemList);
			break;
		case 最近31天日weblogic使用情况:
			columns = weblogicService.getConfigurableXlsColumns(itemList);
			break;
		case 当日weblogic使用情况:
			Map<String, String> treeMap = new TreeMap<String, String>();
			for (RptItemConfVo _ricVo : itemList) {
				columns.put("rows", "2");
				if(_ricVo.getItemCd().contains("时间")){
					columns.put("item1", _ricVo.getItemCd());
				}else if(_ricVo.getGroupParent() != null){
					String ItemName = "";
					if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC) != -1){
						ItemName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC);
						treeMap.put(ItemName + "_item" + _ricVo.getItemSeq(), 
								ItemName+"_"+_ricVo.getItemCd());
					}
					if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY) != -1){
						ItemName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY);
						
						treeMap.put(ItemName+ "_item" + _ricVo.getItemSeq(), 
								ItemName+"_"+_ricVo.getItemCd());
					}
					if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE) != -1){
						ItemName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE);
						treeMap.put(ItemName + "_item" + _ricVo.getItemSeq(), 
								ItemName+"_"+_ricVo.getItemCd());
					}
				}
			}
			//保证columns的顺序
			for(String key : treeMap.keySet()){
				columns.put(key, treeMap.get(key));
			}
			break;
		case 系统资源使用率图表:
			columns = sysResrcService.getConfigurableXlsColumns(itemList, subSheetName);
			break;
		default:
			//多科目
			columns = multTransService.getConfigurableXlsColumns(itemList);
			break;
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		return columns;
	}
	
	/**
	 * 查询系统编号和系统名称的映射集合
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseDayRptAplCode", method = RequestMethod.GET)
	public @ResponseBody void browseWeekRptAplCode(
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object aplCodeNmMap = transItemService.queryAplCodeNmMapForRpt();
		
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
	 * 根据数据库配置项获取chart图表
	 * @param appsysCd
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
	 */
	@RequestMapping(value = "/getAllReport", method = RequestMethod.POST)
	public @ResponseBody ModelMap getAllReport(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "endDate", required = true) String endDate,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		Map<String, String> chartOptionJsonMap = new LinkedHashMap<String, String>();
		Map<String,Map<String,String>> chartsMap = new LinkedHashMap<String, Map<String,String>>();
//		Map<String,Map<String,Object>> chartsDataMap = new LinkedHashMap<String, Map<String,Object>>();
		try {
			String sheetName = "";
			String subSheetName = "";
			String startDate = "";
			List<Map<String,Object>> sheetNames = rptItemConfService.querySheetNames(aplCode, reportType);
			for (Map<String, Object> sheetNameMap : sheetNames) {
				request.getSession().removeAttribute("dateTransData");//移除上次查询的数据
				sheetName = sheetNameMap.get("sheetName").toString();
				
				switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
				case 最近7天分小时交易情况:
				case 最近7天日批量执行情况:
					//子名称
					if(sheetName.indexOf(CommonConst.LEFT_SMALL_BRACKETS_NOESCAPE)  != -1){
						subSheetName = sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[1].split(CommonConst.RIGHT_SMALL_BRACKETS)[0];
					}
					//开始日期
					startDate = DateFunction.getDateByFormatAndOffset(endDate, 0, -7);
					// 根据数据库配置项获取chart图表
					chartOptionJsonMap = dayRptManageService.getRptCharts(aplCode, reportType, sheetName, startDate,
									endDate, subSheetName, request);
					chartsMap.put(sheetName, chartOptionJsonMap);
					break;
				case 最近31天日交易情况:
				case 最近31天分钟和秒交易情况:
				case 最近31天日批量执行情况:
				case 最近31天日网络资源使用情况:
				case 最近31天日weblogic使用情况:
					//子名称
					if(sheetName.indexOf(CommonConst.LEFT_SMALL_BRACKETS_NOESCAPE)  != -1){
						subSheetName = sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[1].split(CommonConst.RIGHT_SMALL_BRACKETS)[0];
					}
					//开始日期
					startDate = DateFunction.getDateByFormatAndOffset(endDate, 0, -31);
					// 根据数据库配置项获取chart图表
					chartOptionJsonMap = dayRptManageService.getRptCharts(aplCode, reportType, sheetName, startDate,
									endDate, subSheetName, request);
					chartsMap.put(sheetName, chartOptionJsonMap);
					break;
				case 当日网络资源使用情况:
				case 当日weblogic使用情况:
					//子名称
					if(sheetName.indexOf(CommonConst.LEFT_SMALL_BRACKETS_NOESCAPE)  != -1){
						subSheetName = sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[1].split(CommonConst.RIGHT_SMALL_BRACKETS)[0];
					}
					//开始日期
					startDate = endDate;
					// 根据数据库配置项获取chart图表
					chartOptionJsonMap = dayRptManageService.getRptCharts(aplCode, reportType, sheetName, startDate,
									endDate, subSheetName, request);
					chartsMap.put(sheetName, chartOptionJsonMap);
					break;
				case 系统资源使用率图表:
//					dateTransData = sysResrcService.getRptData(itemList, sheetName, aplCode, startDate, endDate, subSheetName);
					List<Map<String,Object>> serverAndTrannameList = serverConfService.queryAllServerAndTran(aplCode);
					for (Map<String, Object> map : serverAndTrannameList) {
						chartOptionJsonMap = dayRptManageService.getRptCharts(aplCode, reportType, sheetName, startDate,
								endDate, map.get("combinKey").toString(), request);
						chartsMap.put(sheetName.concat(map.get("combinNames").toString())
															, chartOptionJsonMap);
						request.getSession().removeAttribute("dateTransData");//移除上次查询的数据
					}
					break;
				default://多科目
					break;
				}
			}
			
//			//获取chart数据源数据
//			Map<String, Object> chartsData = (Map<String, Object>) request.getSession().getAttribute("dateTransData");
//			chartsDataMap.put("最近31天日交易情况(重点交易统计)", chartsData);
//			quest.getSession().removeAttribute("dateTransData");//移除上次查询的数据
//			//存储在session中，全量导出方法使用此数据源
//			request.getSession().setAttribute("chartsDataMap", chartsDataMap);

			modelMap.addAttribute("chartsMap", chartsMap);//chartOptionJson
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
	 * 导出日报数据及图表
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
	@RequestMapping(value = "/excelAll", method = RequestMethod.GET)
	public String excelAll(@RequestParam(value = "aplCode", required = true) String aplCode,
									@RequestParam(value = "endDate", required = true) String endDate,
									HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", ComUtil.getCurrentMethodName());
		}
		try {
			// 运行情报总结sheet信息
			Map<String, Object> queryMap = new HashMap<String,Object>();
			queryMap.put("aplCode", aplCode);
			queryMap.put("transDate", endDate);
			List<AplAnalyzeVo> runStateDataList = aplAnalyzeService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "aplCode", "ASC", queryMap);
			modelMap.addAttribute(ReptConstants.DEFAULT_RUN_STATE_SUMMARY, runStateDataList);
			//chart图表信息
			modelMap.addAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY, (Map<String, List<byte[]>>)request.getSession().getAttribute(ReptConstants.DEFAULT_CHART_DAT_KEY));
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
		
		return "excelViewDayRptAll";			//返回servletName
	}
	
	/**
	 * 根据应用系统编号查询科目一级分类

	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseDayRptItemLevel1", method = RequestMethod.GET)
	public @ResponseBody void browseDayRptItemLevel1(
			@RequestParam(value = "appsysCode", required = true) String appsysCode,
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object itemLevelsMap =  transItemService.queryItemLevel1MapForRpt(appsysCode);
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(itemLevelsMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
	}
	
	/**
	 * 根据应用系统编号、科目一级分类查询科目二级分类	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseDayRptItemLevel2", method = RequestMethod.GET)
	public @ResponseBody void browseDayRptItemLevel2(
			@RequestParam(value = "appsysCode", required = true) String appsysCode,
			@RequestParam(value = "itemLevel1", required = true) String itemLevel1,
			HttpServletResponse response) throws JEDAException, UnsupportedEncodingException{
		PrintWriter out = null;
		appsysCode = java.net.URLDecoder.decode(appsysCode,"utf-8");
		itemLevel1 = java.net.URLDecoder.decode(itemLevel1,"utf-8");
		Object itemLevelsMap = transItemService.queryItemLevel2MapForRpt(appsysCode,itemLevel1);
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(itemLevelsMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
	}
	
	/**
	 * 根据应用系统编号、科目一级分类、科目二级分类查询科目三级分类	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseDayRptItemLevel3", method = RequestMethod.GET)
	public @ResponseBody void browseDayRptItemLevel3(
			@RequestParam(value = "appsysCode", required = true) String appsysCode,
			@RequestParam(value = "itemLevel1", required = true) String itemLevel1,
			@RequestParam(value = "itemLevel2", required = true) String itemLevel2,
			HttpServletResponse response) throws JEDAException, UnsupportedEncodingException{
		PrintWriter out = null;
		appsysCode = java.net.URLDecoder.decode(appsysCode,"utf-8");
		itemLevel1 = java.net.URLDecoder.decode(itemLevel1,"utf-8");
		itemLevel2 = java.net.URLDecoder.decode(itemLevel2,"utf-8");
		Object itemLevelsMap = transItemService.queryItemLevel3MapForRpt(appsysCode,itemLevel1,itemLevel2);
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(itemLevelsMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
	}
	
	
}///:~

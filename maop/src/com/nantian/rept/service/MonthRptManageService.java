package com.nantian.rept.service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.impl.BatchTransService;
import com.nantian.rept.service.impl.MonthRptRescrService;
import com.nantian.rept.service.impl.MonthRptTimesTransService;
import com.nantian.rept.service.impl.MonthRptTransService;
import com.nantian.rept.service.impl.MultTransService;
import com.nantian.rept.service.impl.NetResrcService;
import com.nantian.rept.service.impl.TimesTransService;
import com.nantian.rept.service.impl.TransService;
import com.nantian.rept.service.impl.WeblogicService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.smrpt.service.MonthRptDayResrcService;

@Repository
@Service
@Transactional
public class MonthRptManageService {
	
	@Autowired
	private RptItemConfService rptItemConfService;
	
	@Autowired
	private RptChartConfService rptChartConfService;
	
	@Autowired
	private ServerConfService serverConfService;
	
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
	private MultTransService multTransService;
	
	@Autowired
	private MonthRptDayResrcService monthRptDayResrcService;
	
	/**
	 * 根据功能名进行方法的分支判断
	 * @param itemList
	 * @param sheetName
	 * @param aplCode
	 * @param month
	 * @param subSheetName
	 * @param request
	 * @return
	 * @throws Exception
	 */
	public Map<String, Object> monthRptDataSwitchMethod(
			List<RptItemConfVo> itemList, String sheetName, String aplCode,
			String month, String subSheetName, HttpServletRequest request) throws Exception {
		Map<String, Object> rptData = null;
		
		Date date = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		try {
			date = sdf.parse(month);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.MONTH, 1);
		cal.add(Calendar.DAY_OF_MONTH, -1);
		//当月第一天
		String firstDayOfMonth = DateFunction.convertDateToStr(date, 6);
		//当月最后一天
		String lastDayOfMonth = DateFunction.convertDateToStr(cal.getTime(), 6);
		cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.MONTH, -12);
		String startMonth = sdf.format(cal.getTime());
		
		switch(ReptConstants.sheetEnum.getSheetEnum(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 当月日交易量: 
			case 当月日交易成功率: 
			case 当月日交易响应时间:
				rptData = transService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
				break;
			case 最近13个月日交易量:
			case	最近13个月月交易量:
				rptData = monthRptTransService.getRptData(itemList, sheetName, aplCode, startMonth, month);
				break;
			case 当月日网络资源使用情况:
				rptData = netResrcService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
				break;
			case 当月日批量执行情况:
				rptData = batchTransService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
				break;
			case 当月weblogic使用情况: 
				rptData = weblogicService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
				break;
			case 当月分钟和秒交易情况:
				rptData = timesTransService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
				break;
			case 最近13个月系统资源使用率:
				rptData = monthRptRescrService.getRptData(itemList, sheetName, aplCode, startMonth, month, subSheetName);
				break;
			case 最近13个月秒钟交易量峰值:
			case 最近13个月分钟交易量峰值:
				rptData = monthRptTimesTransService.getRptData(itemList, sheetName, aplCode, startMonth, month);
				break;
			case 当月系统资源使用率:
				rptData = monthRptDayResrcService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth, subSheetName);
				break;
			default : rptData = multTransService.getRptData(itemList, sheetName, aplCode, firstDayOfMonth, lastDayOfMonth);
		}
		
		//数据存储在session中，再导出的时候使用
		request.getSession().setAttribute(sheetName, rptData);
		return rptData;
	}
	
	/**
	 * 通过访问报表图表配置表动态获取报表图表数据
	 * @param aplCode 系统编号
	 * @param reportType 报表类型
	 * @param sheetName 报表名称
	 * @param startDate 开始时间
	 * @param endDate 结束时间
	 * @param subSheetName 子名称
	 * @param request 请求对象
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public Map<String, String> getRptCharts(String aplCode, String reportType,
			String sheetName, String month,
			String subSheetName, HttpServletRequest request) throws Exception {
		Map<String, String> chartMap = new HashMap<String,String>();
		
		String sheetEnum = sheetName;
		int startPos = sheetName.lastIndexOf("(");
		int endPos = sheetName.lastIndexOf(")");
		if((sheetName.indexOf(ReptConstants.sheetEnum.最近13个月系统资源使用率.toString()) != -1 
				|| sheetName.indexOf(ReptConstants.sheetEnum.当月系统资源使用率.toString()) != -1)
				&& startPos > 0 && endPos > 0 && endPos >= startPos){
			//兼容月报导出多个"最近13个月系统资源使用率(***)"的科目查询
			sheetEnum = sheetName.substring(0, startPos);
		}
		
		// 动态获取科目名
		List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetEnum);
		// 查询图表数据
		Map<String, Object> rptData = 
				(Map<String, Object>) request.getSession().getAttribute(sheetName);
		if (rptData == null){
			rptData = monthRptDataSwitchMethod(
					itemList, sheetName, aplCode, month, subSheetName, request);
		}
		
		// 查询图表配置信息
		List<RptChartConfVo> chartsList = rptChartConfService.queryRptChartConfList(aplCode, reportType, sheetEnum);
		if(chartsList.size() > 0){
			chartMap = monthRptDynamicChartsSwitchMethod(itemList, chartsList, (List<Map<String, Object>>)rptData.get("metadata"), sheetName, month, subSheetName);
		}
		
		return chartMap;						
	}
	
	/**
	 * 根据功能名进行方法的分支判断,而后创建图表配置数据
	 * @param itemList 报表科目配置表数据
	 * @param chartsList 报表图表配置表数据
	 * @param metedataMapList 图表元数据
	 * @param sheetName 功能名称
	 * @param month 月报月份
	 * @param subSheetName 子名称
	 * @throws Throwable
	 */
	public Map<String, String> monthRptDynamicChartsSwitchMethod(
			List<RptItemConfVo> itemList, List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, String sheetName,
			String month, String subSheetName) throws Exception {
		Map<String, String> chartMap = new HashMap<String,String>();
		//功能分支判断
		switch(ReptConstants.sheetEnum.getSheetEnum(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 当月日交易量: 
			case 当月日交易成功率: 
			case 当月日交易响应时间: chartMap = transService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 最近13个月日交易量: 
			case	最近13个月月交易量: chartMap = monthRptTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当月日网络资源使用情况: chartMap = netResrcService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当月日批量执行情况: chartMap = batchTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当月weblogic使用情况: chartMap = weblogicService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当月分钟和秒交易情况: chartMap = timesTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 最近13个月系统资源使用率: chartMap = monthRptRescrService.getChart(itemList, chartsList, metedataMapList);
				break;
			case	最近13个月秒钟交易量峰值:
			case 最近13个月分钟交易量峰值: chartMap = monthRptTimesTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当月系统资源使用率: chartMap = monthRptDayResrcService.getChart(itemList, chartsList, metedataMapList, subSheetName);
				break;
			default: chartMap = multTransService.getChart(itemList, chartsList, metedataMapList);
		}
		return chartMap;			
	}
	
	/**
	 * 配置导出excel的数据列标题
	 * @param itemList 科目列表
	 * @param sheetName 功能名称
	 * @param endDate 日报日期
	 * @return Map<String, String>
	 */
	public Map<String, String> configExcelColumns(List<RptItemConfVo> itemList, String sheetName, String endDate, String subSheetName){
		Map<String, String> columns = new LinkedHashMap<String, String>();
		//	分支判断
		switch(ReptConstants.sheetEnum.getSheetEnum(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 当月日交易量: 
			case 当月日交易成功率: 
			case 当月日交易响应时间: columns = transService.getConfigurableXlsColumns(itemList);
				break;
			case 最近13个月日交易量: 
			case	最近13个月月交易量: columns = monthRptTransService.getConfigurableXlsColumns(itemList);
				break;
			case 当月日网络资源使用情况: columns = netResrcService.getConfigurableXlsColumns(itemList);
				break;
			case 当月日批量执行情况: columns = batchTransService.getConfigurableXlsColumns(itemList);
				break;
			case 当月weblogic使用情况: columns = weblogicService.getConfigurableXlsColumns(itemList);
				break;
			case 当月分钟和秒交易情况: columns = timesTransService.getConfigurableXlsColumns(itemList);
				break;
			case 最近13个月系统资源使用率: columns = monthRptRescrService.getConfigurableXlsColumns(itemList);
				break;
			case	最近13个月秒钟交易量峰值:
			case 最近13个月分钟交易量峰值: columns = monthRptTimesTransService.getConfigurableXlsColumns(itemList);
				break;
			case 当月系统资源使用率: columns = monthRptDayResrcService.getConfigurableXlsColumns(itemList, subSheetName);
				break;
			default:
				columns = multTransService.getConfigurableXlsColumns(itemList, subSheetName);
		}
		
		return columns;
	}
	
	public List<JSONObject> transform2MenuTree(List<Map<String,Object>> dataList) throws Throwable{
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		List<JSONObject> normalJsonList = new ArrayList<JSONObject>();
		for (Map<String,Object> map : dataList) {
			switch(ReptConstants.sheetEnum.getSheetEnum(map.get("text").toString())){
			case 当月系统资源使用率:
			case 最近13个月系统资源使用率:
				sysJsonList.add(jsonTreeNode(map));
				break;
			default : 
				JSONObject json = new JSONObject();
				json.put("text", map.get("text"));
				json.put("iconCls", map.get("iconCls"));
				json.put("leaf", "false".equals(map.get("leaf"))?false:true);
				json.put("qtip", "鼠标单击打开");
				normalJsonList.add(json);
			}
		}
		
		//编辑菜单组合
		jsonList.addAll(normalJsonList);//普通功能树形菜单
		jsonList.addAll(sysJsonList);//系统资源树形菜单
		return jsonList;
	}

	private JSONObject jsonTreeNode(Map<String, Object> map) {
		JSONObject json = new JSONObject();
		json.put("text", map.get("text"));
		json.put("iconCls", "node-treenode");
		json.put("leaf", false);
		List<Map<String,Object>> serverList = serverConfService.queryAllServer(map.get("aplCode").toString());
		List<Map<String, String>> serClassList = serverConfService.queryAllSerClass(map.get("aplCode").toString());
		List<JSONObject> cjsonList = new ArrayList<JSONObject>();
		for (Map<String, String> serClassMap : serClassList) {
			cjsonList.add(configTreeNode(map.get("aplCode").toString(), String.valueOf(serClassMap.get("serClass")),
					serverList, map.get("text").toString()));
		}
		json.put("children", JSONArray.fromObject(cjsonList));
		return json;
	}

	private JSONObject configTreeNode(String aplCode, String serverType,
			List<Map<String,Object>> serverList, String sheetName) {
		JSONObject cjo = new JSONObject();
		List<JSONObject> cjsonList1 = new ArrayList<JSONObject>();
		List<JSONObject> cjsonList2 = new ArrayList<JSONObject>();
		Map<String, String> serverTypeMap = new HashMap<String, String>();
		serverTypeMap.put("1", "Web");
		serverTypeMap.put("2", "App");
		serverTypeMap.put("3", "DB");
		
		JSONObject cjo1 = null;
		JSONObject cjo2;
		cjo.put("text", serverTypeMap.get(serverType));
		cjo.put("iconCls", "node-treenode");
		cjo.put("leaf", false);
		cjo.put("sysRes", true);
		cjo.put("serClass", true);
		cjo.put("sheetName", sheetName);
		for (Map<String,Object> scMap : serverList) {
			if(null != scMap.get("serClass") && serverType.equals(scMap.get("serClass").toString())){
				if(null != scMap.get("tranName") && !"ALL".equals(scMap.get("tranName").toString())){
					cjo2 = new JSONObject();
					if(null == cjo1){
						//首次为空时创建父节点
						cjo1 = new JSONObject();
						cjsonList2 = new ArrayList<JSONObject>();
						cjo1.put("text", scMap.get("tranName"));
						cjo1.put("iconCls", "node-treenode");
						cjo1.put("leaf", false);
						cjo1.put("sysRes", true);
						cjo1.put("serClass", true);
						cjo1.put("sheetName", sheetName);
					}else if(!cjo1.get("text").equals(scMap.get("tranName"))){
						//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
						}
						cjo1 = new JSONObject();
						cjsonList2 = new ArrayList<JSONObject>();
						cjo1.put("text", scMap.get("tranName"));
						cjo1.put("iconCls", "node-treenode");
						cjo1.put("leaf", false);
						cjo1.put("sysRes", true);
						cjo1.put("serClass", true);
						cjo1.put("sheetName", sheetName);
					}
					cjo2.put("text", scMap.get("serName").toString().concat("(").concat(scMap.get("tranName").toString()).concat(" ").concat(scMap.get("srvCode").toString()).concat(")"));
					cjo2.put("iconCls", "node-leaf");
					cjo2.put("leaf", true);
					cjo2.put("sysRes", true);
					cjo2.put("sheetName", sheetName);
					cjo2.put("subSheetName", serverTypeMap.get(serverType).concat(" ").concat(scMap.get("tranName").toString()).concat(" ").concat(scMap.get("srvCode").toString()));
					cjsonList2.add(cjo2);
				}else{
					if(null != cjsonList2 && cjsonList2.size() != 0){
						cjo1.put("children", JSONArray.fromObject(cjsonList2));
						cjsonList1.add(cjo1);
					}
					cjo1 = new JSONObject();
					cjo1.put("text", scMap.get("serName").toString().concat("(").concat(scMap.get("srvCode").toString()).concat(")"));
					cjo1.put("iconCls", "node-leaf");
					cjo1.put("leaf", true);
					cjo1.put("sysRes", true);
					cjo1.put("sheetName", sheetName);
					if(null != scMap.get("tranName")){
						cjo1.put("subSheetName", serverTypeMap.get(serverType).concat(" ").concat(scMap.get("tranName").toString()).concat(" ").concat(scMap.get("srvCode").toString()));
					}else{
						cjo1.put("subSheetName", serverTypeMap.get(serverType).concat(" ").concat(scMap.get("srvCode").toString()));
					}
					cjsonList1.add(cjo1);
				}
			}
		}
		cjo.put("children", JSONArray.fromObject(cjsonList1));
		return cjo;
	}

}

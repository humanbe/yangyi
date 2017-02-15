package com.nantian.rept.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.impl.BatchTransService;
import com.nantian.rept.service.impl.HoursTransService;
import com.nantian.rept.service.impl.MultTransService;
import com.nantian.rept.service.impl.NetResrcService;
import com.nantian.rept.service.impl.SysResrcService;
import com.nantian.rept.service.impl.TimesTransService;
import com.nantian.rept.service.impl.TransService;
import com.nantian.rept.service.impl.WebJdbcService;
import com.nantian.rept.service.impl.WebMemoryService;
import com.nantian.rept.service.impl.WebQueueService;
import com.nantian.rept.service.impl.WeblogicService;
import com.nantian.rept.vo.BatchTransVo;
import com.nantian.rept.vo.HoursTransVo;
import com.nantian.rept.vo.NetResrcVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author donghui
 *
 */
@Service
public class DayRptManageService {
	
	@Autowired
	private RptItemConfService rptItemConfService;
	
	@Autowired
	private HoursTransService hoursTransService;
	
	@Autowired
	private TimesTransService timesTransService;
	
	@Autowired
	private BatchTransService batchTransService;
	
	@Autowired
	private RptChartConfService rptChartConfService;
	
	@Autowired
	private TransService transService;
	
	@Autowired
	private NetResrcService netResrcService;
	
	@Autowired
	private WeblogicService weblogicService;
	
	@Autowired
	private SysResrcService sysResrcService;
	
	@Autowired
	private ServerConfService serverConfService;
	
	@Autowired
	private MultTransService multTransService;
	
	@Autowired
	private WebJdbcService webJdbcService;
	
	@Autowired
	private WebMemoryService webMemoryService;
	
	@Autowired
	private WebQueueService webQueueService;
	
	public DayRptManageService() {
		super();
	}
	
	/**
	 * 通过访问报表图表配置表动态获取报表图表数据
	 * @param 报表图表配置表键值对
	 * @throws Throwable
	 */
	@SuppressWarnings("unchecked")
	public Map<String, String> getRptCharts(String aplCode, 
																String reportType,
																String sheetName, 
																String startDate, 
																String endDate,
																String subSheetName, 
																HttpServletRequest request) throws Throwable {
		Map<String,String> chartMap = new HashMap<String,String>();
		try{
			// 动态获取科目名
			List<RptItemConfVo> itemList = rptItemConfService.queryRptItemConfList(aplCode, reportType, sheetName);
			
			// 查询图表数据
			Map<String, Object> dateTransData = (Map<String, Object>) request
								.getSession().getAttribute("dateTransData");
			if (dateTransData == null){
				dateTransData = dayRptDataSwitchMethod(
						itemList, sheetName, aplCode, startDate, endDate, subSheetName, request);
			}
			// 查询图表配置信息
			List<RptChartConfVo> chartsList = rptChartConfService.queryRptChartConfList(aplCode, reportType, sheetName);
			if(chartsList.size() > 0){
				chartMap = dayRptDynamicChartsSwitchMethod(itemList, chartsList, (List<Map<String, Object>>) dateTransData.get("metadata"), sheetName, endDate, subSheetName);
			}
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 根据功能名进行方法的分支判断,而后创建图表配置数据
	 * @param 报表科目配置表数据
	 * @param 报表图表配置表数据
	 * @param 图表元数据
	 * @param 功能名称
	 * @param 日报日期
	 * @throws Throwable
	 */
	public Map<String,String> dayRptDynamicChartsSwitchMethod(List<RptItemConfVo> itemList, 
																								List<RptChartConfVo> chartsList, 
																								List<Map<String,Object>> metedataMapList, 
																								String sheetName, 
																								String endDate, 
																								String subSheetName) throws Throwable{
		Map<String,String> chartMap = new HashMap<String,String>();
		try{
			//功能分支判断
			switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
			case 最近31天日交易情况:
				chartMap = transService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 最近7天分小时交易情况:
				chartMap = hoursTransService.getChart(itemList, chartsList, metedataMapList, endDate);
				break;
			case 实时分小时累计交易情况:
				chartMap = hoursTransService.getChartForRealtime(itemList, chartsList, metedataMapList, endDate);
				break;
			case 最近31天分钟和秒交易情况:
				chartMap = timesTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 最近31天日批量执行情况:
				chartMap = batchTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 最近31天日网络资源使用情况:
				chartMap = netResrcService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当日网络资源使用情况:
				chartMap = getNetresrcDayChart(itemList, chartsList, metedataMapList, endDate);
				break;
			case 最近31天日weblogic使用情况:
				chartMap = weblogicService.getChart(itemList, chartsList, metedataMapList);
				break;
			case 当日weblogic使用情况:
				chartMap = getTimeWebresrcCharts(itemList, chartsList, metedataMapList, endDate);
				break;
			case 系统资源使用率图表:
				chartMap = sysResrcService.getChart(itemList, chartsList, metedataMapList, subSheetName);
				break;
			default:
				//多科目的查询
				chartMap = multTransService.getChart(itemList, chartsList, metedataMapList);
				break;
			}
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 根据功能名进行方法的分支判断
	 * @param 报表科目配置表科目列表
	 * @param 功能名称
	 * @param 系统代码
	 * @param 起始日期
	 * @param 日报日期
	 * @throws Throwable
	 */
	public Map<String, Object> dayRptDataSwitchMethod(List<RptItemConfVo> itemList, 
																					String sheetName, 
																					String aplCode,
																					String startDate, 
																					String endDate, 
																					String subSheetName,
																					HttpServletRequest request) throws Throwable {
		Map<String,Object> dateTransData = null;
		try{
			switch(ReptConstants.sheetNameItem.getSheetNameItem(sheetName.split(CommonConst.LEFT_SMALL_BRACKETS)[0])){
				case 最近31天日交易情况:
					dateTransData = transService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 最近7天分小时交易情况:
					dateTransData = hoursTransService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 实时分小时累计交易情况:
					dateTransData = getHourRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 最近7天日批量执行情况:
					dateTransData = getBatchtrans(itemList, aplCode, startDate, endDate, sheetName);
					break;
				case 最近31天分钟和秒交易情况:
					dateTransData = timesTransService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 最近31天日批量执行情况:
					dateTransData = batchTransService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 最近31天日网络资源使用情况:
					dateTransData = netResrcService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 当日网络资源使用情况:
					dateTransData = getNetResrc(itemList, sheetName, aplCode, startDate, endDate,subSheetName);
					break;
				case 最近31天日weblogic使用情况:
					dateTransData = weblogicService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
				case 当日weblogic使用情况:
					dateTransData = getTimeWebresrc(itemList, sheetName, aplCode, startDate, endDate, subSheetName);
					break;
				case 系统资源使用率图表:
					dateTransData = sysResrcService.getRptData(itemList, sheetName, aplCode, startDate, endDate, subSheetName);
					break;
				default:
					//多科目的查询 - sheetName字段去掉
					dateTransData = multTransService.getRptData(itemList, sheetName, aplCode, startDate, endDate);
					break;
			}
			
			//数据存储在session中，再生成chart图表的时候使用
			request.getSession().setAttribute("dateTransData", dateTransData);
			return dateTransData;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 通过访问小时交易量统计表动态获取数据(实时分小时累计交易情况)
	 * @param elist 报表科目配置表科目列表

	 * @param sheetName 功能名称
	 * @param aplCode 系统代码
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @return
	 * @throws Throwable
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, Object> getHourRptData(List<RptItemConfVo> elist,
															String sheetName, 
															String aplCode, 
															String startDate, 
															String endDate) throws Exception {
		// 方法返回值对象

		Map<String,Object> returnDataMap = new HashMap<String,Object>();
		// 存储数据map对象
		List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
		// 中间编辑对象
		Map<String,Object> dataMap = null;
		LinkedHashMap<String,Map<String,Object>> hoursKeyMap = new LinkedHashMap<String, Map<String,Object>>();
		// 未与小时交易量统计表匹配的科目列表

		List<Map<String,Object>> filterMapList  = new ArrayList<Map<String,Object>>();
		for (String hour : ComUtil.hoursListRealTime) {
			dataMap = new HashMap<String, Object>();
			hoursKeyMap.put(hour, dataMap);
		}
		try{
			//查询当日数据
			List<Map<String,Object>> list = (List<Map<String, Object>>) hoursTransService.queryAllList(aplCode,startDate,endDate,sheetName);
			
			for (Map<String, Object> map : list) {
				if(map.get("itemName").toString().equals("小时") && null==map.get("expression")){
					filterMapList.add(map);
					continue;
				}else if(null != map.get("expression") && !"".equals(map.get("expression").toString())){
					filterMapList.add(map);
					continue;
				}else if(null != map.get("transDate") && null != map.get("countHourTime") && !"".equals(map.get("transDate").toString()) && !"".equals(map.get("countHourTime").toString())){
					// 科目名

					hoursKeyMap.get(map.get("countHourTime")).put("item".concat(map.get("itemSeq").toString()).concat(map.get("transDate").toString()).concat(CommonConst.UNDERLINE).concat("Name"), map.get("itemName"));
					// 科目值

					hoursKeyMap.get(map.get("countHourTime")).put("item".concat(map.get("itemSeq").toString()).concat(map.get("transDate").toString()), map.get("countAmount"));
					//日期
					hoursKeyMap.get(map.get("countHourTime")).put("transDate", map.get("transDate"));
				}
			}
			
			///峰值日数据
			String peakDate = null;
			for (RptItemConfVo itemVo : elist) {
				if("小时".equals(itemVo.getItemCd()) || null != itemVo.getExpression()){
					continue;
				}else{
					//峰值日
					peakDate = ((HoursTransVo) hoursTransService.queryPeakDate(aplCode, itemVo.getItemCd(), endDate)).getTransDate();
					if(peakDate!=null){
						List<Map<String,Object>> peakList = (List<Map<String, Object>>) hoursTransService.queryPeakDateList(aplCode , peakDate , itemVo.getItemCd());
						for (Map<String, Object> map : peakList) {
							if(null != map.get("transDate") && null != map.get("countHourTime") && !"".equals(map.get("transDate").toString()) && !"".equals(map.get("countHourTime").toString())){
								// 科目名	
	
								hoursKeyMap.get(map.get("countHourTime")).put("item".concat(itemVo.getItemSeq().toString()).concat(map.get("transDate").toString()).concat(CommonConst.UNDERLINE).concat("Name"), itemVo.getItemCd());
								// 科目值	
	
								hoursKeyMap.get(map.get("countHourTime")).put("item".concat(itemVo.getItemSeq().toString()).concat(map.get("transDate").toString()), map.get("countAmount"));
								//日期
								hoursKeyMap.get(map.get("countHourTime")).put("transPeakDate", map.get("transDate"));
								//峰值占比	
	
								if(null != hoursKeyMap.get(map.get("countHourTime")).get("item".concat(itemVo.getItemSeq().toString()).concat(endDate))){
									hoursKeyMap.get(map.get("countHourTime")).put("item".concat(itemVo.getItemSeq().toString()).concat("percent"), 
											NumberUtil.format(Double.valueOf(NumberUtil.eval(hoursKeyMap.get(map.get("countHourTime")).get("item".concat(itemVo.getItemSeq().toString()).concat(endDate)) 
													+ "/" + map.get("countAmount"))),NumberUtil.FORMAT_PATTERN_5));
								}
							}
						}
					}
				}
			}
			// 编辑未与日交易量统计表匹配的计算式科目列表

			hoursTransService.evalExpression(hoursKeyMap,filterMapList,elist,dataList,endDate);
			
			// 元数据

			returnDataMap.put("metadata", dataList);
			
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	
	/**
	 * 通过访问weblogic统计表动态获取数据(当日weblogic使用情况)
	 * @param itemList 报表科目配置表科目列表
	 * @param sheetName 报表名
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 日报日期
	 * @param srvCode 服务器编号（IP）
	 * @return
	 * @throws Throwable
	 */
	public Map<String, Object> getTimeWebresrc(List<RptItemConfVo> itemList, 
																		String sheetName, 
																		String aplCode,
																		String startDate, 
																		String endDate, 
																		String subSheetName) throws Throwable {
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		Map<String, List<String>> servers4Jdbc = new HashMap<String, List<String>>();
		List<String> servers4Mem = new ArrayList<String>();
		List<String> servers4Queue = new ArrayList<String>();
		List<String> servers = new ArrayList<String>();
		List<String> jdbcNames = new ArrayList<String>();
		Map<String, Map<String, Object>> timeMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		String server = null;
		String jdbcName = null;
		boolean queueExistPortFlag = false;
		boolean memExistPortFlag = false;
		boolean jdbcExistPortFlag = false;
		List<Map<String, String>> queueList = new ArrayList<Map<String, String>>();//队列使用数
		List<Map<String, String>> jdbcList = new ArrayList<Map<String, String>>();//JDBC链接使用数
		List<Map<String, String>> memList = new ArrayList<Map<String, String>>();//WebLogic内存使用率

		String srvCode = null;
		try{
			if(subSheetName.indexOf(CommonConst.UNDERLINE) != -1){
				srvCode = subSheetName.split(CommonConst.UNDERLINE)[0];
			}else{
				//是否为服务器check.
				if(serverConfService.checkExist(subSheetName) != 0){
					srvCode = subSheetName;
				}
			}
			//编辑当日5分钟时间列表.
			Map<String, Object > keyMap = null;
			for(String strTime : ComUtil.weblogicTimeList){
				keyMap = new HashMap<String, Object>();
				keyMap.put("item1", strTime);
				timeMap.put(strTime, keyMap);
			}
			
			for(RptItemConfVo vo : itemList){
				if(vo.getGroupParent() != null){
					int startPos = vo.getItemCd().toString().lastIndexOf("(");
					int endPos = vo.getItemCd().toString().lastIndexOf(")");
					//JDBC链接使用数.
					if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC)){
						if(startPos != -1 && endPos != -1 &&  endPos > startPos){
							String[] options = vo.getItemCd().toString().substring(startPos + 1, endPos).split(" ");
							//规定第一个参数为JDBC名称，第二个参数为端口号.
							if(options.length == 2){
								jdbcExistPortFlag = true;
							}
							server = vo.getItemCd().toString().substring(0, startPos);
							jdbcName = options[0];
							if(!servers.contains(server)){
								servers.add(server);
							}
							if(!jdbcNames.contains(jdbcName)){
								jdbcNames.add(jdbcName);
							}
						}else{
							if(!servers.contains(vo.getItemCd().toString())){
								servers.add(vo.getItemCd().toString());
							}
							jdbcNames.add("");
						}
					} 
					//WebLogic内存使用率
					if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY)){
						if(startPos != -1){
							memExistPortFlag = true;
							server = vo.getItemCd().toString().substring(0, startPos);
							if(!servers4Mem.contains(server)){
								servers4Mem.add(server);
							}
						}else{
							if(!servers4Mem.contains(vo.getItemCd().toString())){
								servers4Mem.add(vo.getItemCd().toString());
							}
						}
					} 
					//队列使用数
					if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE)){
						if(startPos != -1){
							queueExistPortFlag = true;
							server = vo.getItemCd().toString().substring(0, startPos);
							if(!servers4Queue.contains(server)){
								servers4Queue.add(server);
							}
						}else{
							if(!servers4Queue.contains(vo.getItemCd().toString())){
								servers4Queue.add(vo.getItemCd().toString());
							}
						}
						
					}
				}
			}
			
			if(servers.size() != 0){
				servers4Jdbc.put("servers", servers);
			}
			
			if(jdbcNames.size() != 0){
				servers4Jdbc.put("jdbcNames", jdbcNames);
			}
			
			if(null != srvCode && !"".equals(srvCode)){
				//查询单个主机指定服务的当日weblogic资源数据，获取指定服务数据

				if(servers4Queue.size() != 0){
					queueList = webQueueService.queryWebQueue4One(aplCode, endDate, srvCode, queueExistPortFlag, servers4Queue);
				}
				if(servers4Mem.size() != 0){
					memList = webMemoryService.queryWebMemory4One(aplCode, endDate, srvCode, memExistPortFlag, servers4Mem);
				}
				if(servers4Jdbc.size() != 0){
					jdbcList = webJdbcService.queryWebJdbc4One(aplCode, endDate, srvCode, jdbcExistPortFlag, servers4Jdbc);
				}
			}else{
				//查询集群服务器指定cluster服务的当日weblogic资源数据，获取包含所有服务的最大值
				//例如CCS的CLUSTER_SERVER(SD10pp6)包含服务(Server61、Server62、Server71、Server72、Server81、Server82、Server91、Server92)
				if(servers4Queue.size() != 0){
					queueList = webQueueService.queryWebQueue4More(aplCode, endDate, servers4Queue);
				}
				if(servers4Jdbc.size() != 0){
					jdbcList = webJdbcService.queryWebJdbc4More(aplCode, endDate, servers4Jdbc);
				}
				if(servers4Mem.size() != 0){
					memList = webMemoryService.queryWebMemory4More(aplCode, endDate, servers4Mem);
				}
			}
			
			for(RptItemConfVo itemVo : itemList){
				if(itemVo.getGroupParent() != null){
					dataMapBuilder(queueList, timeMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE, itemVo, queueExistPortFlag);
					dataMapBuilder(memList, timeMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY, itemVo, memExistPortFlag);
					dataMapBuilder(jdbcList, timeMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC, itemVo, jdbcExistPortFlag);
				}
			}
			
			for(String key : timeMap.keySet()){
				dataList.add(timeMap.get(key));
			}
			
			returnDataMap.put("metadata", dataList);
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}

	/**
	 * 根据weblogic被统计的资源类型构建数据对象
	 * @param targetList 目标数据列表
	 * @param targetMap 目标数据映射
	 * @param targetType 目标类型
	 * @param target 科目配置表实体类
	 * @throws Throwable
	 */
	private void dataMapBuilder(List<Map<String, String>> targetList,
												Map<String, Map<String, Object>> targetMap, 
												String targetType,
												RptItemConfVo target,
												Boolean existPortFlag) throws Throwable{
		Map<String, Object> keyMap = null;
		try{
			if(target.getGroupParent().indexOf(targetType) != -1){
				for(int i = 0; i < targetList.size(); i++){
					Map<String, String> map = targetList.get(i);
					if(target.getItemCd().contains(map.get("weblogicServer"))){
						if(targetType.equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC)
								&& !target.getItemCd().contains(map.get("jdbcName"))){
							continue;
						}
						
						keyMap = targetMap.get(map.get("monitorTime"));
						if(keyMap == null){
							keyMap = new HashMap<String, Object>();
							keyMap.put("item1", map.get("monitorTime"));
						}
						
						if(targetType.equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE)){
							if(existPortFlag){
								if(target.getItemCd().contains(map.get("weblogicPort"))){
									String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
									keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("usedQueue"));
								}else{
									continue;
								}
							}else{
								String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
								keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("usedQueue"));
							}
						}else if(targetType.equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC)){
							if(existPortFlag){
								if(target.getItemCd().contains(map.get("weblogicPort"))){
									String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
									keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("currentActive"));
								}else{
									continue;
								}
							}else{
								String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
								keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("currentActive"));
							}
						}else if(targetType.equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY)){
							if(existPortFlag){
								if(target.getItemCd().contains(map.get("weblogicPort"))){
									String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
									keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("memoryRate"));
								}else{
									continue;
								}
							}else{
								String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);
								keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("memoryRate"));
							}
						}
						targetMap.put(map.get("monitorTime"), keyMap);
					}
				}
			}
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 创建图表配置数据(当日weblogic使用情况)
	 * @param itemList 报表科目配置表数据
	 * @param chartsList 报表图表配置表数据
	 * @param metedataMapList 图表元数据
	 * @param endDate 日报日期
	 * @return
	 * throws Throwable
	 */
	private Map<String, String> getTimeWebresrcCharts(List<RptItemConfVo> itemList,
																					List<RptChartConfVo> chartsList,
																					List<Map<String, Object>> metedataMapList, 
																					String endDate)	throws Throwable {
		StringBuilder charOptions = null;
		StringBuilder titleOption = null;
		StringBuilder yAxisOptions = null;
		StringBuilder xCategoriesOptions = null;
		StringBuilder toolTipUnit = null;
		StringBuilder seriesOptions = null;
		Map<String, String> chartMap = new HashMap<String, String>();
		try{
			for(int i = 0; i < chartsList.size(); i++){
				charOptions = new StringBuilder();
				titleOption = new StringBuilder();
				yAxisOptions = new StringBuilder();
				xCategoriesOptions = new StringBuilder();
				toolTipUnit = new StringBuilder();
				seriesOptions = new StringBuilder();
				switch(ComUtil.changeToChar(chartsList.get(i).getChartType())){
				case  '1':	// 1：趋势图
					// 标题
					titleOption.append(chartsList.get(i).getChartName());
					// Y轴信息(左&右)
					yAxisOptions.append("{")
										.append("\"yAxis\":{")
										.append("\"yAxisTitle\":").append("\"").append(ComUtil.checkNull(chartsList.get(i).getChartYaxisTitle())).append("\"").append(CommonConst.COMMA)
										.append("\"yAxisMinval\":").append(NumberUtil.formatNumByUnit(chartsList.get(i).getChartYaxisMinval(), ComUtil.checkNull(chartsList.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
										.append("\"yAxisMaxval\":").append(NumberUtil.formatNumByUnit(chartsList.get(i).getChartYaxisMaxval(), ComUtil.checkNull(chartsList.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
										.append("\"yAxisInterval\":").append(NumberUtil.formatNumByUnit(chartsList.get(i).getChartYaxisInterval(), ComUtil.checkNull(chartsList.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
										.append("\"yAxisUnit\":").append("\"").append(ComUtil.checkNull(chartsList.get(i).getChartYaxisUnit())).append("\"")
										.append("}")
										.append("}");
					// X轴科目信息
					for(int m = 0; m < metedataMapList.size(); m++){
						xCategoriesOptions.append(metedataMapList.get(m).get("item1")).append(CommonConst.COMMA);
					}
					if(xCategoriesOptions.length() != 0){
						xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
					}
					//坐标tip提示信息数组
					toolTipUnit.append("{");
					int count = 0;
					for(int j = 0; j < itemList.size(); j++){
						RptItemConfVo vo = itemList.get(j);
						if(vo.getExpressionUnit() != null){
							count ++;
							toolTipUnit.append("\\'" + vo.getItemCd() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
						}
						
						if(count > 0 && j == itemList.size() - 1){
							toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
						}
					}
					toolTipUnit.append("}");
					// 图表统计科目信息
					seriesOptions.append("[");
					for (String itemName : chartsList.get(i).getItemList().split(",")) {
						seriesOptions.append("{name:\"").append(itemName.toString().substring(itemName.lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2)).append("\",").append("data:[");
						for(int j = 0; j < metedataMapList.size(); j++){
							for(RptItemConfVo vo : itemList){
								if(null != vo.getGroupParent() && vo.getItemCd().equals(itemName)){
									if(chartsList.get(i).getChartName().indexOf("JDBC") != -1
											&& vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC) != -1){
										String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_JDBC);

										seriesOptions.append(metedataMapList.get(j).get(targetTypeName + "_item" + vo.getItemSeq()));
									}else if(vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY) != -1
											&& chartsList.get(i).getChartName().indexOf("内存") != -1){
										String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_MEMORY);

										seriesOptions.append(metedataMapList.get(j).get(targetTypeName + "_item" + vo.getItemSeq()));
									}else if(vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE) != -1
											&& chartsList.get(i).getChartName().indexOf("队列") != -1){
										String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_QUEUE);

										seriesOptions.append(metedataMapList.get(j).get(targetTypeName + "_item" + vo.getItemSeq()));
									}
									break;
								}
							}
							if(j != metedataMapList.size()-1){
								// 最后一次循环时不添加逗号，删除最后一个多余逗号data:[1,2,3,
								seriesOptions.append(CommonConst.COMMA);
							}
						}
						seriesOptions.append("]},");
					}
					// 删除最后一个多余逗号[{name:'xxxx',data:[1,2,3]},{name:'xxxx',data:[4,5,6]},
					seriesOptions.deleteCharAt(seriesOptions.length()-1);
					seriesOptions.append("]");
					break;
				case '2':	// 2：柱状图
					break;
				case '3':	// 3：饼图

					break;
				case '4':	//4：条形图
					break;
			}
			// 编辑返回JSON数据
			charOptions.append("{")
							.append("\"chartType\":").append("\"").append(chartsList.get(i).getChartType()).append("\"").append(CommonConst.COMMA)
							.append("\"titleOption\":").append("\"").append(titleOption.toString()).append("\"").append(CommonConst.COMMA)
							.append("\"yAxisOptions\":").append(yAxisOptions.toString()).append(CommonConst.COMMA)
							.append("\"xCategoriesOptions\":").append("\"").append(xCategoriesOptions).append("\"").append(CommonConst.COMMA)
							.append("\"toolTipUnit\":").append("\"").append(toolTipUnit).append("\"").append(CommonConst.COMMA)
							.append("\"seriesOptions\":").append(seriesOptions.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
							.append("}");
			chartMap.put("rptChart"+i, charOptions.toString());
			}
			
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 通过访问五分钟网络资源统计表动态获取数据(当日网络资源使用情况).
	 * @param itemList 报表科目配置表科目列表.
	 * @param aplCode 系统编号.
	 * @param startDate 开始时间.
	 * @param endDate 日报日期.
	 * @param sheetName 报表名.
	 * @return
	 * @throws Throwable
	 */
	public Map<String, Object> getNetResrc(List<RptItemConfVo> itemList, 
																String sheetName, 
																String aplCode,
																String startDate, 
																String endDate,
																String subSheetName)  throws Throwable{
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> timeMap = new LinkedHashMap<String, Map<String,Object>>();
		List<String> itemNameList = new ArrayList<String>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		String srvCode = null;
		try{
			if(subSheetName.indexOf(CommonConst.UNDERLINE) != -1){
				srvCode = subSheetName.split(CommonConst.UNDERLINE)[0];
			}else{
				srvCode = subSheetName;
			}
			//编辑当日5分钟时间列表
			for(String strTime : ComUtil.netResrcTimeList){
				keyMap = new HashMap<String, Object>();
				timeMap.put(strTime, keyMap);
			}
			
			for(RptItemConfVo vo : itemList){
				itemNameList.add(vo.getItemCd());
			}
			List<NetResrcVo> netResrcDayList = netResrcService.queryNetResrcDayList(aplCode, endDate, srvCode,sheetName, itemNameList);
			
			for(NetResrcVo _vo: netResrcDayList){
				if(timeMap.get(_vo.getMonitorTime()) != null){
					keyMap = timeMap.get(_vo.getMonitorTime());
				}else{
					keyMap = new HashMap<String, Object>();
				}
				for(RptItemConfVo rvo : itemList){
					if(rvo.getItemCd().equals(_vo.getMonitorItem())){
						if(rvo.getExpression() != null){
							String expression = rvo.getExpression();
							for(NetResrcVo nvo : netResrcDayList){
								if(expression.indexOf(nvo.getMonitorItem()) != -1 && _vo.getMonitorTime().equals(nvo.getMonitorTime())){
									expression = StringUtil.replaceWithEscape(expression, nvo.getMonitorItem(), nvo.getMonitorValue());
								}
							}
							keyMap.put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), 
								Math.round(Double.valueOf(NumberUtil.eval(expression))));
						}else{
							keyMap.put(rvo.getItemCd() + "item" + rvo.getItemSeq(), 
								_vo.getMonitorValue());
						}
						break;
					}
				}
				keyMap.put("item1", _vo.getMonitorTime());
				timeMap.put(_vo.getMonitorTime(), keyMap);
			}
			
			for(String key : timeMap.keySet()){
				dataList.add(timeMap.get(key));
			}
			
			//编辑合计、平均、最大、最小			List<Double> statisticalValList  = null;
			Map<String,Object> dataMap = null;
			// 存储合计值map对象
			LinkedHashMap<String,Map<String,Object>> statisticalKeyMap = new LinkedHashMap<String, Map<String,Object>>();
			// 存储合计值数据列表			List<Map<String,Object>> statisticalDataList  = new ArrayList<Map<String,Object>>();
			for(RptItemConfVo rvo : itemList){
				statisticalValList  = new ArrayList<Double>();
				for (Map<String, Object> dMap : dataList) {
					if(null != dMap.get(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())))){
						statisticalValList.add(Double.valueOf(dMap.get(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq()))).toString()));
					}
				}
				if(statisticalValList.size() != 0){
					// 合计值.
					if(null == statisticalKeyMap.get("合计值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getSumValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("合计值", dataMap);
					}else{
						statisticalKeyMap.get("合计值").put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getSumValue(statisticalValList));
					}
					// 平均值.
					if(null == statisticalKeyMap.get("平均值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getAvgValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("平均值", dataMap);
					}else{
						statisticalKeyMap.get("平均值").put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getAvgValue(statisticalValList));
					}
					// 最大值.
					if(null == statisticalKeyMap.get("最大值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getMaxValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("最大值", dataMap);
					}else{
						statisticalKeyMap.get("最大值").put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getMaxValue(statisticalValList));
					}
					// 最小值.
					if(null == statisticalKeyMap.get("最小值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getMinValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("最小值", dataMap);
					}else{
						statisticalKeyMap.get("最小值").put(rvo.getItemCd().concat("item").concat(String.valueOf(rvo.getItemSeq())), NumberUtil.getMinValue(statisticalValList));
					}
				}
			}
			for (String key : statisticalKeyMap.keySet()) {
				statisticalKeyMap.get(key).put("item1", key);
				statisticalDataList.add(statisticalKeyMap.get(key));
			}
			
			returnDataMap.put("metadata", dataList);
			returnDataMap.put("statisticalData", statisticalDataList);
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 通过访问应用批量执行统计表动态获取数据(最近7天日批量执行情况)
	 * @param itemList 报表科目配置表科目列表	 * @param aplCode 系统代码
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @param sheetName 功能名称
	 * @return
	 * @throws Throwable
	 */
	public Map<String, Object> getBatchtrans(List<RptItemConfVo> itemList, 
																	String aplCode, 
																	String startDate, 
																	String endDate, 
																	String sheetName) throws Throwable{
		// 方法返回值对象
		Map<String,Object> returnDataMap = new HashMap<String,Object>();
		// 存储数据map对象
		List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
		// 中间编辑对象
		Map<String,Object> dataMap = new HashMap<String, Object>();
		LinkedHashMap<String,Map<String,Object>> keyMap = new LinkedHashMap<String, Map<String,Object>>();
//		Map<String, String> columnsKeys = new HashMap<String, String>();
//		columnsKeys.put("批量名称", "PLTJ_PLMC");
//		columnsKeys.put("开始时间", "PLTJ_KSSJ");
//		columnsKeys.put("结束时间", "PLTJ_JSSJ");
//		columnsKeys.put("结束标志", "PLTJ_JSBZ");
//		columnsKeys.put("执行时长(秒)", "PLTJ_ZXSC");
		try{
			List<BatchTransVo> list = batchTransService.queryBatchTransListForSevenDay(aplCode, startDate, endDate);
			for (BatchTransVo _batchVo : list) {
				if(null != keyMap.get(_batchVo.getBatchName()) && !"".equals(keyMap.get(_batchVo.getBatchName()))){
					keyMap.get(_batchVo.getBatchName()).put(_batchVo.getBatchDate().concat("PLTJ_KSSJ"), _batchVo.getBatchStartTime());
					keyMap.get(_batchVo.getBatchName()).put(_batchVo.getBatchDate().concat("PLTJ_JSSJ"), _batchVo.getBatchEndTime());
					keyMap.get(_batchVo.getBatchName()).put(_batchVo.getBatchDate().concat("PLTJ_JSBZ"), _batchVo.getEndFlag());
					keyMap.get(_batchVo.getBatchName()).put(_batchVo.getBatchDate().concat("PLTJ_ZXSC"), _batchVo.getBatchExeTime());
				}else{
					dataMap.put(_batchVo.getBatchDate().concat("PLTJ_KSSJ"), _batchVo.getBatchStartTime());
					dataMap.put(_batchVo.getBatchDate().concat("PLTJ_JSSJ"), _batchVo.getBatchEndTime());
					dataMap.put(_batchVo.getBatchDate().concat("PLTJ_JSBZ"), _batchVo.getEndFlag());
					dataMap.put(_batchVo.getBatchDate().concat("PLTJ_ZXSC"), _batchVo.getBatchExeTime());
					keyMap.put(_batchVo.getBatchName(), dataMap);
					dataMap = new HashMap<String, Object>();
				}
			}
			for (String _mapKey : keyMap.keySet()) {
				keyMap.get(_mapKey).put("PLTJ_PLMC", _mapKey);
				dataList.add(keyMap.get(_mapKey));
			}
			// 元数据
			returnDataMap.put("metadata", dataList);
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 创建图表配置数据(当日网络资源使用情况)
	 * @param itemList 报表科目配置表数据
	 * @param chartsList 报表图表配置表数据
	 * @param metedataMapList 图表元数据
	 * @param endDate 日报日期
	 * @return
	 * @throws Throwable
	 */
	private Map<String, String> getNetresrcDayChart(List<RptItemConfVo> itemList,
																				List<RptChartConfVo> chartsList,
																				List<Map<String, Object>> metedataMapList, 
																				String endDate) throws Throwable{
		StringBuilder charOptions = null;
		StringBuilder titleOption = null;
		StringBuilder yAxisOptions = null;
		StringBuilder xCategoriesOptions = null;
		StringBuilder toolTipUnit = null;
		StringBuilder seriesOptions = null;
		Map<String, String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;//new ArrayList<RptChartConfVo>();
		try{
			for(int i = 0; i < chartsList.size(); i++){
				RptChartConfVo vo1 = chartsList.get(i);
				dataChartList = new ArrayList<RptChartConfVo>();
				dataChartList.add(vo1);
				chartsList.remove(i);
				i--;
				for(int j = i + 1; j < chartsList.size(); j++){
					RptChartConfVo vo2 = chartsList.get(j);
					if(vo1.getAplCode().equals(vo2.getAplCode()) 
							&& vo1.getReportType().equals(vo2.getReportType())
							&& vo1.getSheetName().equals(vo2.getSheetName())
							&& vo1.getChartName().equals(vo2.getChartName())
							&& vo1.getChartType().equals(vo2.getChartType())
							&& vo1.getChartSeq() == vo2.getChartSeq()){
						dataChartList.add(vo2);
						chartsList.remove(vo2);
						j--;
					}
					
				}
				mutipleDataChartList.add(dataChartList);
			}
			
			for(int i = 0; i < mutipleDataChartList.size(); i++){
				charOptions = new StringBuilder();
				titleOption = new StringBuilder();
				yAxisOptions = new StringBuilder();
				xCategoriesOptions = new StringBuilder();
				toolTipUnit = new StringBuilder();
				seriesOptions = new StringBuilder();
				List<RptChartConfVo> multiChartList = mutipleDataChartList.get(i);
				
				titleOption.append(multiChartList.get(0).getChartName());
				// Y轴信息(左&右)
				yAxisOptions.append("{\"yAxis\":[");
				for(int j = 0; j < multiChartList.size(); j++){
					yAxisOptions.append("{\"yAxisTitle\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisTitle())).append("\"").append(CommonConst.COMMA)
						.append("\"yAxisMinval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMinval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisMaxval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMaxval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisInterval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisInterval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisUnit\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit())).append("\"").append(CommonConst.COMMA)
						.append("\"yAxisPosition\":").append(multiChartList.get(j).getChartYaxisPosition())
						.append("}");
					if(j != multiChartList.size() - 1){
						yAxisOptions.append(",");
					}
				}
				yAxisOptions.append("]}");
				// X轴科目信息
				for (Map<String, Object> _map : metedataMapList) {
					xCategoriesOptions.append(_map.get("item1")).append(CommonConst.COMMA);
				}
				if(xCategoriesOptions.length() != 0){
					xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
				}
				//坐标tip提示信息数组
				toolTipUnit.append("{");
				int count = 0;
				for(int j = 0; j < itemList.size(); j++){
					RptItemConfVo vo = itemList.get(j);
					if(vo.getExpressionUnit() != null){
						count ++;
						toolTipUnit.append("\\'" + vo.getItemCd() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
					}
					
					if(count > 0 && j == itemList.size() - 1){
						toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
					}
				}
				toolTipUnit.append("}");
				// 图表统计科目信息
				seriesOptions.append("[");
				for(int j = 0; j < multiChartList.size(); j++){
					for (String itemCd : multiChartList.get(j).getItemList().split(",")) {
						//遍历itemList查询匹配编码的编码中文名称
						for(int m=0;m<itemList.size();m++){
							if(itemList.get(m).getItemCd().equals(itemCd)){
								seriesOptions.append("{name:\"").append(itemList.get(m).getItemName()).append("\",").append("data:[");
							}
						}
						
						for(int k = 0; k < metedataMapList.size(); k++){
							for(RptItemConfVo _rvo : itemList){
								if(_rvo.getItemCd().equals(itemCd)){
									seriesOptions.append(metedataMapList.get(k).get(_rvo.getItemCd().concat("item").concat(String.valueOf(_rvo.getItemSeq()))));
									break;
								}
							}
							if(k != metedataMapList.size() - 1){
								seriesOptions.append(CommonConst.COMMA);
							}
						}
						seriesOptions.append("]");
						seriesOptions.append(", yAxis :  "+ j +"},");
					}
				}
				// 删除最后一个多余逗号
				seriesOptions.deleteCharAt(seriesOptions.length() - 1);
				seriesOptions.append("]");
				// 编辑返回JSON数据
				charOptions.append("{")
								.append("\"chartType\":").append("\"").append(multiChartList.get(0).getChartType()).append("\"").append(CommonConst.COMMA)
								.append("\"titleOption\":").append("\"").append(titleOption.toString()).append("\"").append(CommonConst.COMMA)
								.append("\"yAxisOptions\":").append(yAxisOptions.toString()).append(CommonConst.COMMA)
								.append("\"xCategoriesOptions\":").append("\"").append(xCategoriesOptions).append("\"").append(CommonConst.COMMA)
								.append("\"toolTipUnit\":").append("\"").append(toolTipUnit).append("\"").append(CommonConst.COMMA)
								.append("\"seriesOptions\":").append(seriesOptions.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
								.append("}");
				chartMap.put("rptChart"+i, charOptions.toString());
			}
			
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}

	/**
	 * 获取日报管理树形菜单 - 报告分析
	 * @param 报表科目配置表树形菜单数据

	 * @return
	 * @throws Throwable
	 */
	public List<JSONObject> getJosnObjectForTreeForAnalyse(List<Map<String,Object>> dataList) throws Throwable{
		JSONObject jo = new JSONObject();
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		List<JSONObject> runSummaryJsonList = new ArrayList<JSONObject>();
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		List<JSONObject> normalJsonList = new ArrayList<JSONObject>();
		try{
		// 循环处理
		for (Map<String,Object> map : dataList) {
			jo = new JSONObject();
			if(ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY.equals(map.get("text"))){
				jo.put("text", map.get("text"));
				jo.put("iconCls", map.get("iconCls"));
				jo.put("leaf", "false".equals(map.get("leaf"))?false:true);
				jo.put("qtip", "鼠标单击打开");
				runSummaryJsonList.add(jo);
			}else	if(ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC.equals(map.get("text"))){
				jo.put("text", map.get("text"));
				jo.put("iconCls", "node-module");
				jo.put("leaf", false);
				List<Map<String,Object>> serverList = serverConfService.queryAllServer(map.get("aplCode").toString());
				List<Map<String, String>> serClassList = serverConfService.queryAllSerClass(map.get("aplCode").toString());
				JSONObject cjo = null;
				JSONObject cjo1 = null;
				JSONObject cjo2 = null;
				List<JSONObject> cjsonList = new ArrayList<JSONObject>();
				List<JSONObject> cjsonList1 = null;
				List<JSONObject> cjsonList2 = null;
				for (Map<String, String> serClassMap : serClassList) {
					cjo = new JSONObject();
					cjsonList1 = new ArrayList<JSONObject>();
					switch(ComUtil.changeToChar(String.valueOf(serClassMap.get("serClass")))){
					case '1':
						cjo.put("text", "Web");
						cjo.put("iconCls", "node-leaf");
						//cjo.put("leaf", true);
						cjo.put("leaf", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap1 : serverList) {
							if(null != scMap1.get("serClass") && "1".equals(scMap1.get("serClass").toString())){
								if(null != scMap1.get("tranName") && !"ALL".equals(scMap1.get("tranName").toString())){
									cjo2 = new JSONObject();
									if(null == cjo1){
										//首次为空时创建父节点
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap1.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("hidden", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}else if(!cjo1.get("text").equals(scMap1.get("tranName"))){
										//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
										if(null != cjsonList2 && cjsonList2.size() != 0){
											cjo1.put("children", JSONArray.fromObject(cjsonList2));
											cjsonList1.add(cjo1);
										}
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap1.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("hidden", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}
									cjo2.put("text", (null != scMap1.get("serName")?scMap1.get("serName").toString():"").concat("(").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()).concat(")"));
									cjo2.put("iconCls", "node-leaf");
									cjo2.put("leaf", true);
									cjo2.put("checked", false);
									cjo2.put("sysRes", true);
									cjo1.put("hidden", true);
									cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									cjo2.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()));
									cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap1.get("serName")?scMap1.get("serName").toString():"").concat("(").concat(scMap1.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("hidden", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap1.get("tranName")){
										cjo1.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					case '2':
						cjo.put("text", "APP");
						cjo.put("iconCls", "node-leaf");
						//cjo.put("leaf", true);
						cjo.put("leaf", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap2 : serverList) {
							if(null != scMap2.get("serClass") && "2".equals(scMap2.get("serClass").toString())){
								if(null != scMap2.get("tranName") && !"ALL".equals(scMap2.get("tranName").toString())){
									cjo2 = new JSONObject();
									if(null == cjo1){
										//首次为空时创建父节点
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap2.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("hidden", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}else if(!cjo1.get("text").equals(scMap2.get("tranName"))){
										//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
										if(null != cjsonList2 && cjsonList2.size() != 0){
											cjo1.put("children", JSONArray.fromObject(cjsonList2));
											cjsonList1.add(cjo1);
										}
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap2.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("hidden", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}
									cjo2.put("text", (null != scMap2.get("serName")?scMap2.get("serName").toString():"").concat("(").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()).concat(")"));
									cjo2.put("iconCls", "node-leaf");
									cjo2.put("leaf", true);
									cjo2.put("checked", false);
									cjo2.put("sysRes", true);
									cjo1.put("hidden", true);
									cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									cjo2.put("subSheetName", "APP".concat(" ").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()));
									cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap2.get("serName")?scMap2.get("serName").toString():"").concat("(").concat(scMap2.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("hidden", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap2.get("tranName")){
										cjo1.put("subSheetName", "APP".concat(" ").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "APP".concat(" ").concat(scMap2.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					case '3':
						cjo.put("text", "DB");
						cjo.put("iconCls","node-leaf");
						//cjo.put("leaf", true);
						cjo.put("leaf", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap3 : serverList) {
							if(null != scMap3.get("serClass") && "3".equals(scMap3.get("serClass").toString())){
									if(null != scMap3.get("tranName") && !"ALL".equals(scMap3.get("tranName"))){
										cjo2 = new JSONObject();
										if(null == cjo1){
											//首次为空时创建父节点
											cjo1 = new JSONObject();
											cjsonList2 = new ArrayList<JSONObject>();
											cjo1.put("text", scMap3.get("tranName"));
											cjo1.put("iconCls", "node-treenode");
											cjo1.put("leaf", false);
											cjo1.put("checked", false);
											cjo1.put("sysRes", true);
											cjo1.put("serClass", true);
											cjo1.put("hidden", true);
											cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										}else if(!cjo1.get("text").equals(scMap3.get("tranName"))){
											//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
											if(null != cjsonList2 && cjsonList2.size() != 0){
												cjo1.put("children", JSONArray.fromObject(cjsonList2));
												cjsonList1.add(cjo1);
											}
											cjo1 = new JSONObject();
											cjsonList2 = new ArrayList<JSONObject>();
											cjo1.put("text", scMap3.get("tranName"));
											cjo1.put("iconCls", "node-treenode");
											cjo1.put("leaf", false);
											cjo1.put("checked", false);
											cjo1.put("sysRes", true);
											cjo1.put("serClass", true);
											cjo1.put("hidden", true);
											cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										}
										cjo2.put("text", (null != scMap3.get("serName")?scMap3.get("serName").toString():"").concat("(").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()).concat(")"));
										cjo2.put("iconCls", "node-leaf");
										cjo2.put("leaf", true);
										cjo2.put("checked", false);
										cjo2.put("sysRes", true);
										cjo1.put("hidden", true);
										cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										cjo2.put("subSheetName", "DB".concat(" ").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()));
										cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap3.get("serName")?scMap3.get("serName").toString():"").concat("(").concat(scMap3.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("hidden", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap3.get("tranName")){
										cjo1.put("subSheetName", "DB".concat(" ").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "DB".concat(" ").concat(scMap3.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					}
				}
				jo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(jo);
			}else{
				jo.put("text", map.get("text"));
				jo.put("iconCls", map.get("iconCls"));
				jo.put("leaf", "false".equals(map.get("leaf"))?false:true);
				jo.put("qtip", "鼠标单击打开");
				normalJsonList.add(jo);
			}
		}
		
		//编辑菜单组合
		jsonList.addAll(runSummaryJsonList);//运行总结树形菜单
		jsonList.addAll(normalJsonList);//普通功能树形菜单		jsonList.addAll(sysJsonList);//系统资源树形菜单
		return jsonList;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 获取日报管理树形菜单
	 * @param 报表科目配置表树形菜单数据

	 * @return
	 * @throws Throwable
	 */
	public List<JSONObject> getJosnObjectForTree(List<Map<String,Object>> dataList) throws Throwable{
		JSONObject jo = new JSONObject();
		List<JSONObject> jsonList = new ArrayList<JSONObject>();
		List<JSONObject> runSummaryJsonList = new ArrayList<JSONObject>();
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		List<JSONObject> normalJsonList = new ArrayList<JSONObject>();
		try{
		// 循环处理
		for (Map<String,Object> map : dataList) {
			jo = new JSONObject();
			if(ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY.equals(map.get("text"))){
				jo.put("text", map.get("text"));
				jo.put("iconCls", map.get("iconCls"));
				jo.put("leaf", "false".equals(map.get("leaf"))?false:true);
				jo.put("qtip", "鼠标单击打开");
				runSummaryJsonList.add(jo);
			}else	if(ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC.equals(map.get("text"))){
				jo.put("text", map.get("text"));
				jo.put("iconCls", "node-treenode");
				jo.put("leaf", false);
				List<Map<String,Object>> serverList = serverConfService.queryAllServer(map.get("aplCode").toString());
				List<Map<String, String>> serClassList = serverConfService.queryAllSerClass(map.get("aplCode").toString());
				JSONObject cjo = null;
				JSONObject cjo1 = null;
				JSONObject cjo2 = null;
				List<JSONObject> cjsonList = new ArrayList<JSONObject>();
				List<JSONObject> cjsonList1 = null;
				List<JSONObject> cjsonList2 = null;
				for (Map<String, String> serClassMap : serClassList) {
					cjo = new JSONObject();
					cjsonList1 = new ArrayList<JSONObject>();
					switch(ComUtil.changeToChar(String.valueOf(serClassMap.get("serClass")))){
					case '1':
						cjo.put("text", "Web");
						cjo.put("iconCls", "node-treenode");
						cjo.put("leaf", false);
						cjo.put("checked", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap1 : serverList) {
							if(null != scMap1.get("serClass") && "1".equals(scMap1.get("serClass").toString())){
								if(null != scMap1.get("tranName") && !"ALL".equals(scMap1.get("tranName").toString())){
									cjo2 = new JSONObject();
									if(null == cjo1){
										//首次为空时创建父节点
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap1.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}else if(!cjo1.get("text").equals(scMap1.get("tranName"))){
										//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
										if(null != cjsonList2 && cjsonList2.size() != 0){
											cjo1.put("children", JSONArray.fromObject(cjsonList2));
											cjsonList1.add(cjo1);
										}
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap1.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}
									cjo2.put("text", (null != scMap1.get("serName")?scMap1.get("serName").toString():"").concat("(").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()).concat(")"));
									cjo2.put("iconCls", "node-leaf");
									cjo2.put("leaf", true);
									cjo2.put("checked", false);
									cjo2.put("sysRes", true);
									cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									cjo2.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()));
									cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap1.get("serName")?scMap1.get("serName").toString():"").concat("(").concat(scMap1.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap1.get("tranName")){
										cjo1.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("tranName").toString()).concat(" ").concat(scMap1.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "WEB".concat(" ").concat(scMap1.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					case '2':
						cjo.put("text", "APP");
						cjo.put("iconCls", "node-treenode");
						cjo.put("leaf", false);
						cjo.put("checked", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap2 : serverList) {
							if(null != scMap2.get("serClass") && "2".equals(scMap2.get("serClass").toString())){
								if(null != scMap2.get("tranName") && !"ALL".equals(scMap2.get("tranName").toString())){
									cjo2 = new JSONObject();
									if(null == cjo1){
										//首次为空时创建父节点
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap2.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}else if(!cjo1.get("text").equals(scMap2.get("tranName"))){
										//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
										if(null != cjsonList2 && cjsonList2.size() != 0){
											cjo1.put("children", JSONArray.fromObject(cjsonList2));
											cjsonList1.add(cjo1);
										}
										cjo1 = new JSONObject();
										cjsonList2 = new ArrayList<JSONObject>();
										cjo1.put("text", scMap2.get("tranName"));
										cjo1.put("iconCls", "node-treenode");
										cjo1.put("leaf", false);
										cjo1.put("checked", false);
										cjo1.put("sysRes", true);
										cjo1.put("serClass", true);
										cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									}
									cjo2.put("text", (null != scMap2.get("serName")?scMap2.get("serName").toString():"").concat("(").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()).concat(")"));
									cjo2.put("iconCls", "node-leaf");
									cjo2.put("leaf", true);
									cjo2.put("checked", false);
									cjo2.put("sysRes", true);
									cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									cjo2.put("subSheetName", "APP".concat(" ").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()));
									cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap2.get("serName")?scMap2.get("serName").toString():"").concat("(").concat(scMap2.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap2.get("tranName")){
										cjo1.put("subSheetName", "APP".concat(" ").concat(scMap2.get("tranName").toString()).concat(" ").concat(scMap2.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "APP".concat(" ").concat(scMap2.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					case '3':
						cjo.put("text", "DB");
						cjo.put("iconCls", "node-treenode");
						cjo.put("leaf", false);
						cjo.put("checked", false);
						cjo.put("sysRes", true);
						cjo.put("serClass", true);
						cjo.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
						for (Map<String,Object> scMap3 : serverList) {
							if(null != scMap3.get("serClass") && "3".equals(scMap3.get("serClass").toString())){
									if(null != scMap3.get("tranName") && !"ALL".equals(scMap3.get("tranName"))){
										cjo2 = new JSONObject();
										if(null == cjo1){
											//首次为空时创建父节点
											cjo1 = new JSONObject();
											cjsonList2 = new ArrayList<JSONObject>();
											cjo1.put("text", scMap3.get("tranName"));
											cjo1.put("iconCls", "node-treenode");
											cjo1.put("leaf", false);
											cjo1.put("checked", false);
											cjo1.put("sysRes", true);
											cjo1.put("serClass", true);
											cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										}else if(!cjo1.get("text").equals(scMap3.get("tranName"))){
											//交易名称改变，重新设定父节点，之前先插入前父节点的字节点
											if(null != cjsonList2 && cjsonList2.size() != 0){
												cjo1.put("children", JSONArray.fromObject(cjsonList2));
												cjsonList1.add(cjo1);
											}
											cjo1 = new JSONObject();
											cjsonList2 = new ArrayList<JSONObject>();
											cjo1.put("text", scMap3.get("tranName"));
											cjo1.put("iconCls", "node-treenode");
											cjo1.put("leaf", false);
											cjo1.put("checked", false);
											cjo1.put("sysRes", true);
											cjo1.put("serClass", true);
											cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										}
										cjo2.put("text", (null != scMap3.get("serName")?scMap3.get("serName").toString():"").concat("(").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()).concat(")"));
										cjo2.put("iconCls", "node-leaf");
										cjo2.put("leaf", true);
										cjo2.put("checked", false);
										cjo2.put("sysRes", true);
										cjo2.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
										cjo2.put("subSheetName", "DB".concat(" ").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()));
										cjsonList2.add(cjo2);
								}else{
									if(null != cjsonList2 && cjsonList2.size() != 0){
										cjo1.put("children", JSONArray.fromObject(cjsonList2));
										cjsonList1.add(cjo1);
									}
									cjo1 = new JSONObject();
									cjo1.put("text", (null != scMap3.get("serName")?scMap3.get("serName").toString():"").concat("(").concat(scMap3.get("srvCode").toString()).concat(")"));
									cjo1.put("iconCls", "node-leaf");
									cjo1.put("leaf", true);
									cjo1.put("checked", false);
									cjo1.put("sysRes", true);
									cjo1.put("sheetName", ReptConstants.SPECIAL_SHEETNAME_SYS_RESRC);
									if(null != scMap3.get("tranName")){
										cjo1.put("subSheetName", "DB".concat(" ").concat(scMap3.get("tranName").toString()).concat(" ").concat(scMap3.get("srvCode").toString()));
									}else{
										cjo1.put("subSheetName", "DB".concat(" ").concat(scMap3.get("srvCode").toString()));
									}
									cjsonList1.add(cjo1);
								}
							}
						}
						//处理最后跨服务器分类后，未进行插入的编辑好的子节点
						if(null != cjsonList2 && cjsonList2.size() != 0){
							cjo1.put("children", JSONArray.fromObject(cjsonList2));
							cjsonList1.add(cjo1);
							cjsonList2 = null;
						}
						cjo.put("children", JSONArray.fromObject(cjsonList1));
						cjsonList.add(cjo);
						break;
					}
				}
				jo.put("children", JSONArray.fromObject(cjsonList));
				sysJsonList.add(jo);
			}else{
				jo.put("text", map.get("text"));
				jo.put("iconCls", map.get("iconCls"));
				jo.put("leaf", "false".equals(map.get("leaf"))?false:true);
				jo.put("qtip", "鼠标单击打开");
				normalJsonList.add(jo);
			}
		}
		
		//编辑菜单组合
		jsonList.addAll(runSummaryJsonList);//运行总结树形菜单
		jsonList.addAll(normalJsonList);//普通功能树形菜单

		jsonList.addAll(sysJsonList);//系统资源树形菜单
		return jsonList;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
}///:~

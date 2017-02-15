package com.nantian.smrpt.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
@Repository
@Transactional
public class MonthRptDayResrcService implements BaseService<RptItemConfVo, RptChartConfVo>{
	@Autowired
	private SessionFactory sessionFactorySmrpt;
	
	public Session getSession() {
		return sessionFactorySmrpt.getCurrentSession();
	}
	
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,
			Object... options) {

		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
//		List<String> columnHeaderGroupList = new ArrayList<String>();
//		String field = "unkown";

//		String subSheetName = (String) options[0];
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		fieldsNmMap.put("日期", "date");
		fieldsNmMap.put("CPU使用率日峰值", "cpuPeak");
		fieldsNmMap.put("CPU使用率日均值", "cpuAvg");
		fieldsNmMap.put("CPU使用率联机峰值", "cpuOnlinePeak");
		fieldsNmMap.put("CPU使用率联机均值", "cpuOnlineAvg");
		fieldsNmMap.put("CPU使用率批量峰值", "cpuBatchPeak");
		fieldsNmMap.put("CPU使用率批量均值", "cpuBatchAvg");
		fieldsNmMap.put("内存使用率日峰值", "memPeak");
		fieldsNmMap.put("内存使用率日均值", "memAvg");
		fieldsNmMap.put("内存使用率联机峰值", "memOnlinePeak");
		fieldsNmMap.put("内存使用率联机均值", "memOnlineAvg");
		fieldsNmMap.put("内存使用率批量峰值", "memBatchPeak");
		fieldsNmMap.put("内存使用率批量均值", "memBatchAvg");
		fieldsNmMap.put("磁盘IO日峰值", "diskPeak");
		fieldsNmMap.put("磁盘IO日均值", "diskAvg");
		fieldsNmMap.put("磁盘IO联机峰值", "diskOnlinePeak");
		fieldsNmMap.put("磁盘IO联机均值", "diskOnlineAvg");
		fieldsNmMap.put("磁盘IO批量峰值", "diskBatchPeak");
		fieldsNmMap.put("磁盘IO批量均值", "diskBatchAvg");
		
		/*for (String mapKey : fieldsNmMap.keySet()) {
			columnHeaderGroupList.add(mapKey);
		}*/
		
		fieldsNames.append("[");
		columnModels.append("[new Ext.grid.RowNumberer(),");
		
		for(String key : fieldsNmMap.keySet()){
			for(int i = 0; i < itemList.size(); i++){
				if(key.equals(itemList.get(i).getItemName())){
					fieldsNames.append("{name:'").append(fieldsNmMap.get(key)).append("'}, ");
					columnModels.append("{header:'")
										.append(key)
										.append("', dataIndex:'")
										.append(fieldsNmMap.get(key))
										.append("', sortable:true},");
					break;
				}
			}
		}
		
		fieldsNames.deleteCharAt(fieldsNames.length() - 1).append("]");
		columnModels.deleteCharAt(columnModels.length() - 1).append("]");
		
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
		/*fieldsNames.append("{name : 'statisticalFlag'}");	 //统计值标识


		columnModels.append("{header : '").append("统计值标识").append("',")
							.append("dataIndex : '").append("statisticalFlag").append("',")
							.append("sortable : true").append(",")
							.append("hidden : true")
							.append("}");		//统计值标识


		fieldsNames.append("]");
		columnModels.append("]");*/
		
//		modelMap.addAttribute("columnHeaderGroupColspan", subSheetName.split(CommonConst.STRING_COMMA).length);
//		modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
	
	}

	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> itemList,
			String sheetName, String aplCode, String startDate, String endDate,
			Object... options) throws Exception {
		String subSheetName = "";
		String srvCode = "";
//		List<String> srvCodes = new ArrayList<String>();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		
		fieldsNmMap.put("日期", "date");
		fieldsNmMap.put("CPU使用率日峰值", "cpuPeak");
		fieldsNmMap.put("CPU使用率日均值", "cpuAvg");
		fieldsNmMap.put("CPU使用率联机峰值", "cpuOnlinePeak");
		fieldsNmMap.put("CPU使用率联机均值", "cpuOnlineAvg");
		fieldsNmMap.put("CPU使用率批量峰值", "cpuBatchPeak");
		fieldsNmMap.put("CPU使用率批量均值", "cpuBatchAvg");
		fieldsNmMap.put("内存使用率日峰值", "memPeak");
		fieldsNmMap.put("内存使用率日均值", "memAvg");
		fieldsNmMap.put("内存使用率联机峰值", "memOnlinePeak");
		fieldsNmMap.put("内存使用率联机均值", "memOnlineAvg");
		fieldsNmMap.put("内存使用率批量峰值", "memBatchPeak");
		fieldsNmMap.put("内存使用率批量均值", "memBatchAvg");
		fieldsNmMap.put("磁盘IO日峰值", "diskPeak");
		fieldsNmMap.put("磁盘IO日均值", "diskAvg");
		fieldsNmMap.put("磁盘IO联机峰值", "diskOnlinePeak");
		fieldsNmMap.put("磁盘IO联机均值", "diskOnlineAvg");
		fieldsNmMap.put("磁盘IO批量峰值", "diskBatchPeak");
		fieldsNmMap.put("磁盘IO批量均值", "diskBatchAvg");
		
		
		//解析服务器编码
		if(options.length > 0){
			subSheetName = options[0].toString();
			//查询多个主机的系统资源
			for (String _subName : subSheetName.split(CommonConst.STRING_COMMA)) {
				String tranNameAndSrvCodes[] = _subName.split(" ");
				if (tranNameAndSrvCodes.length == 3) {
					// 服务器类型、交易名称、服务器编码组合（WEB IVR CEB-IVR-8）
					srvCode = tranNameAndSrvCodes[2];
				}else if (tranNameAndSrvCodes.length == 2){
					//服务器类型、服务器编码组合（WEB CEB-IVR-8）
					srvCode = tranNameAndSrvCodes[1];
				}else{
					srvCode = _subName;
				}
//				srvCodes.add(srvCode);
			}
		}
		
		List<Map<String, String>> list = queryRptDayResource(aplCode, srvCode, startDate, endDate);
		
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		
		for(int i = 0; i < list.size(); i++){
			Map<String, String> map = list.get(i);
			if(dateMap.get(map.get("date")) != null){
				keyMap = dateMap.get(map.get("date"));
			}else{
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			for(RptItemConfVo rvo : itemList){
				for(String key : fieldsNmMap.keySet()){
					if(rvo.getItemName().trim().equals(key)){
						keyMap.put(fieldsNmMap.get(key), map.get(fieldsNmMap.get(key)));
						break;
					}
				}
			}
			
			dateMap.put(map.get("date"), keyMap);
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		returnDataMap.put("metadata", dataList);
		
		return returnDataMap;
	}

	@SuppressWarnings("unchecked")
	private List<Map<String, String>> queryRptDayResource(String aplCode,
			String hostName, String startDate, String endDate) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	to_char(c.date, 'yyyy-mm-dd') as date, ")
			.append("	c.dayPeak as cpuPeak, ")
			.append("	c.dayAvg as cpuAvg, ")
			.append("	c.onlinePeak as cpuOnlinePeak, ")
			.append("	c.onlineAvg as cpuOnlineAvg, ")
			.append("	c.batchPeak as cpuBatchPeak, ")
			.append("	c.batchAvg as cpuBatchAvg, ")
			.append("	m.dayPeak as memPeak, ")
			.append("	m.dayAvg as memAvg, ")
			.append("	m.onlinePeak as memOnlinePeak, ")
			.append("	m.onlineAvg as memOnlineAvg, ")
			.append("	m.batchPeak as memBatchPeak, ")
			.append("	m.batchAvg as memBatchAvg, ")
			.append("	d.dayPeak as diskPeak, ")
			.append("	d.dayAvg as diskAvg, ")
			.append("	d.onlinePeak as diskOnlinePeak, ")
			.append("	d.onlineAvg as diskOnlineAvg, ")
			.append("	d.batchPeak as diskBatchPeak, ")
			.append("	d.batchAvg as diskBatchAvg) ")
			.append("from DayCpuVo c, DayMemoryVo m, DayDiskVo d ")
			.append("where c.date = m.date ")
			.append("	and c.date = d.date ")
			.append("	and c.hostName = m.hostName ")
			.append("	and c.hostName = d.hostName ")
			.append("	and c.date between to_date(:startDate, 'yyyymmdd') ")
			.append("	and to_date(:endDate, 'yyyymmdd') ")
			.append(" and c.hostName = :hostName ");
		
		return getSession().createQuery(hql.toString())
									 .setString("startDate", startDate)
									 .setString("endDate", endDate)
									 .setString("hostName", hostName)
									 .list();
		
	}

	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, Object... options)
			throws Exception {
		StringBuilder charOptions;
		StringBuilder titleOption;
		StringBuilder yAxisOptions;
		StringBuilder xCategoriesOptions;
		StringBuilder toolTipUnit;
		StringBuilder seriesOptions;
		Map<String, String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();
		List<RptChartConfVo> dataChartList = null;
		//动态列
		Map<String, String> yAxisMap = new LinkedHashMap<String, String>();
		
		yAxisMap .put("cpuPeak", "CPU使用率日峰值");
		yAxisMap.put("cpuAvg", "CPU使用率日均值");
		yAxisMap.put("cpuOnlinePeak", "CPU使用率联机峰值");
		yAxisMap.put("cpuOnlineAvg", "CPU使用率联机均值");
		yAxisMap.put("cpuBatchPeak", "CPU使用率批量峰值");
		yAxisMap.put("cpuBatchAvg", "CPU使用率批量均值");
		yAxisMap.put("memPeak", "内存使用率日峰值");
		yAxisMap.put("memAvg", "内存使用率日均值");
		yAxisMap.put("memOnlinePeak", "内存使用率联机峰值");
		yAxisMap.put("memOnlineAvg", "内存使用率联机均值");
		yAxisMap.put("memBatchPeak", "内存使用率批量峰值");
		yAxisMap.put("memBatchAvg", "内存使用率批量均值");
		yAxisMap.put("diskPeak", "磁盘IO日峰值");
		yAxisMap.put("diskAvg", "磁盘IO日均值");
		yAxisMap.put("diskOnlinePeak", "磁盘IO联机峰值");
		yAxisMap.put("diskOnlineAvg", "磁盘IO联机均值");
		yAxisMap.put("diskBatchPeak", "磁盘IO批量峰值");
		yAxisMap.put("diskBatchAvg", "磁盘IO批量均值");
		
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
			for(int j = i + 1;j < mutipleDataChartList.size(); j++){
				List<RptChartConfVo> listj = mutipleDataChartList.get(j);
				if(listj.get(0).getChartName().equals(multiChartList.get(0).getChartName())){
					multiChartList.addAll(listj);
					mutipleDataChartList.remove(listj);
					j--;
				}
			}
			// Y轴信息(左&右)
			yAxisOptions.append("{\"yAxis\":[");
			for(int j = 0; j < multiChartList.size(); j++){
				yAxisOptions.append("{\"yAxisTitle\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisTitle())).append("\"").append(CommonConst.COMMA)
					.append("\"yAxisMinval\":").append(multiChartList.get(j).getChartYaxisMinval()).append(CommonConst.COMMA)
					.append("\"yAxisMaxval\":").append(multiChartList.get(j).getChartYaxisMaxval()).append(CommonConst.COMMA)
					.append("\"yAxisInterval\":").append(multiChartList.get(j).getChartYaxisInterval()).append(CommonConst.COMMA)
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
				xCategoriesOptions.append(_map.get("date")).append(CommonConst.COMMA);
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
					toolTipUnit.append("\\'" + vo.getItemName() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
				}
				if(count > 0 && j == itemList.size() - 1){
					toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
				}
			}
			toolTipUnit.append("}");
			// 图表统计科目信息
			seriesOptions.append("[");
			for(int j = 0; j < multiChartList.size(); j++){
				for (String itemName : multiChartList.get(j).getItemList().split(",")) {
					seriesOptions.append("{name:\"").append(itemName).append("\",").append("data:[");
					for(int k = 0; k < metedataMapList.size(); k++){
						for(String key : yAxisMap.keySet()){
							if(yAxisMap.get(key).equals(itemName)){
								seriesOptions.append(metedataMapList.get(k).get(key));
								break;
							}
						}
						if(k != metedataMapList.size() - 1){
							seriesOptions.append(CommonConst.COMMA);
						}
					}
					seriesOptions.append("]");
					seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
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
	}

	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> itemList, Object... options) {
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		fieldsNmMap.put("日期", "date");
		fieldsNmMap.put("CPU使用率日峰值", "cpuPeak");
		fieldsNmMap.put("CPU使用率日均值", "cpuAvg");
		fieldsNmMap.put("CPU使用率联机峰值", "cpuOnlinePeak");
		fieldsNmMap.put("CPU使用率联机均值", "cpuOnlineAvg");
		fieldsNmMap.put("CPU使用率批量峰值", "cpuBatchPeak");
		fieldsNmMap.put("CPU使用率批量均值", "cpuBatchAvg");
		fieldsNmMap.put("内存使用率日峰值", "memPeak");
		fieldsNmMap.put("内存使用率日均值", "memAvg");
		fieldsNmMap.put("内存使用率联机峰值", "memOnlinePeak");
		fieldsNmMap.put("内存使用率联机均值", "memOnlineAvg");
		fieldsNmMap.put("内存使用率批量峰值", "memBatchPeak");
		fieldsNmMap.put("内存使用率批量均值", "memBatchAvg");
		fieldsNmMap.put("磁盘IO日峰值", "diskPeak");
		fieldsNmMap.put("磁盘IO日均值", "diskAvg");
		fieldsNmMap.put("磁盘IO联机峰值", "diskOnlinePeak");
		fieldsNmMap.put("磁盘IO联机均值", "diskOnlineAvg");
		fieldsNmMap.put("磁盘IO批量峰值", "diskBatchPeak");
		fieldsNmMap.put("磁盘IO批量均值", "diskBatchAvg");
		
		for(int i = 0; i < itemList.size(); i++){
			for(String key : fieldsNmMap.keySet()){
				if(itemList.get(i).getItemName().equals(key)){
					columns.put(fieldsNmMap.get(key), key);
				}
			}
		}
		return columns;
	}
}

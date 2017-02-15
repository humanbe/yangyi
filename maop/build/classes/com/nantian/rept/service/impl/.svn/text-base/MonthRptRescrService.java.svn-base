package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * 月报系统资源统计处理服务层
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
@Service
@Transactional
public class MonthRptRescrService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/**hibernate session factory*/
	@Resource(name = "sessionFactoryMaopRpt")
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 查询交易量和系统资源统计的合成数据
	 * @param aplCode
	 * @param srvCode
	 * @param startMonth
	 * @param endMonth
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, String>> queryRptMonthTranAndResource(
			String aplCode, List<String> srvCodes, String startMonth, String endMonth) {
		StringBuilder sql = new StringBuilder();
		sql.append("select t.apl_code as \"aplCode\", ")
			.append("       to_char(to_date(t.count_month, 'yyyymm'), 'yyyy-mm') as \"countMonth\", ")
			.append("       t.day_avg_trans as \"dayAvgTrans\", ")
			.append("       t.month_peak_trans as \"monthPeakTrans\", ")
			.append("       r.srv_code as \"srvCode\", ")
			.append("       r.cpu_peak as \"cpuPeak\", ")
			.append("       r.cpu_online_peak_avg as \"cpuOnlinePeakAvg\", ")
			.append("       r.cpu_batch_peak_avg as \"cpuBatchPeakAvg\", ")
			.append("       r.mem_peak as \"memPeak\", ")
			.append("       r.mem_online_peak_avg as \"memOnlinePeakAvg\", ")
			.append("       r.mem_batch_peak_avg as \"memBatchPeakAvg\", ")
			.append("       r.io_peak as \"ioPeak\", ")
			.append("       r.io_online_peak_avg as \"ioOnlinePeakAvg\", ")
			.append("       r.io_batch_peak_avg as \"ioBatchPeakAvg\" ")
			.append("  from month_tran t ")
			.append("  left join month_resource r on t.apl_code = r.apl_code ")
			.append("                           and t.count_month = r.count_month ")
			.append("                           and r.srv_code in :srvCodes ")
			.append(" where t.apl_code = :aplCode ")
			.append("   and t.count_month between :startMonth and :endMonth  ")
			.append(" order by to_date(t.count_month, 'yyyymm') ");
		
		return getSession().createSQLQuery(sql.toString())
									 .setString("aplCode", aplCode)
									 .setParameterList("srvCodes", srvCodes)
									 .setString("startMonth", startMonth)
									 .setString("endMonth", endMonth)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .list();
	}

	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap, Object...options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		
		fieldsNmMap.put("月份", "countMonth");
		fieldsNmMap.put("交易量月峰值", "monthPeakTrans");
		fieldsNmMap.put("交易量月均值", "dayAvgTrans");
		fieldsNmMap.put("CPU月峰值", "cpuPeak");
		fieldsNmMap.put("CPU联机峰值月均值", "cpuOnlinePeakAvg");
		fieldsNmMap.put("CPU批量峰值月均值", "cpuBatchPeakAvg");
		fieldsNmMap.put("内存月峰值", "memPeak");
		fieldsNmMap.put("内存联机峰值月均值", "memOnlinePeakAvg");
		fieldsNmMap.put("内存批量峰值月均值", "memBatchPeakAvg");
		fieldsNmMap.put("IO月峰值", "ioPeak");
		fieldsNmMap.put("IO联机峰值月均值", "ioOnlinePeakAvg");
		fieldsNmMap.put("IO批量峰值月均值", "ioBatchPeakAvg");
		
		for (String mapKey : fieldsNmMap.keySet()) {
			columnHeaderGroupList.add(mapKey);
		}
		
		fieldsNames.append("[");
		columnModels.append("[new Ext.grid.RowNumberer(),");
		
		for(String key : fieldsNmMap.keySet()){
			fieldsNames.append("{name:'").append(fieldsNmMap.get(key)).append("'}, ");
			columnModels.append("{header:'")
								.append(key)
								.append("', dataIndex:'")
								.append(fieldsNmMap.get(key))
								.append("', sortable:true},");
		}
		
		fieldsNames.deleteCharAt(fieldsNames.length() - 1).append("]");
		columnModels.deleteCharAt(columnModels.length() - 1).append("]");
		
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());			
	}

	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> itemList,
			String sheetName, String aplCode, String startMonth, String endMonth, Object...options)
			throws Exception {
		String subSheetName = "";
		String srvCode = "";
		List<String> srvCodes = new ArrayList<String>();
		Map<String, String> commonMap = new LinkedHashMap<String, String>();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		
		commonMap.put("月份", "countMonth");
		commonMap.put("交易量月峰值", "monthPeakTrans");
		commonMap.put("交易量月均值", "dayAvgTrans");
		
		fieldsNmMap.put("CPU月峰值", "cpuPeak");
		fieldsNmMap.put("CPU联机峰值月均值", "cpuOnlinePeakAvg");
		fieldsNmMap.put("CPU批量峰值月均值", "cpuBatchPeakAvg");
		fieldsNmMap.put("内存月峰值", "memPeak");
		fieldsNmMap.put("内存联机峰值月均值", "memOnlinePeakAvg");
		fieldsNmMap.put("内存批量峰值月均值", "memBatchPeakAvg");
		fieldsNmMap.put("IO月峰值", "ioPeak");
		fieldsNmMap.put("IO联机峰值月均值", "ioOnlinePeakAvg");
		fieldsNmMap.put("IO批量峰值月均值", "ioBatchPeakAvg");
		
		
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
				srvCodes.add(srvCode);
			}
		}
		
		List<Map<String, String>> list = queryRptMonthTranAndResource(aplCode, srvCodes, startMonth, endMonth);
		
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		
		for(int i = 0; i < list.size(); i++){
			Map<String, String> map = list.get(i);
			if(dateMap.get(map.get("countMonth")) != null){
				keyMap = dateMap.get(map.get("countMonth"));
			}else{
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			for(RptItemConfVo rvo : itemList){
				for(String key : commonMap.keySet()){
					if(rvo.getItemName().trim().equals(key)){
						if(!keyMap.containsKey(commonMap.get(key))){
							keyMap.put(commonMap.get(key), map.get(commonMap.get(key)));
							break;
						}
					}
				}
				
				for(String key : fieldsNmMap.keySet()){
					if(rvo.getItemName().trim().equals(key)){
						keyMap.put(fieldsNmMap.get(key), map.get(fieldsNmMap.get(key)));
						break;
					}
				}
			}
			
			dateMap.put(map.get("countMonth"), keyMap);
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		returnDataMap.put("metadata", dataList);
		
		return returnDataMap;
	}

	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, Object...options) throws Exception {
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
//		yAxisMap.put("countMonth", "月份");
		yAxisMap.put("monthPeakTrans", "交易量月峰值");
		yAxisMap.put("dayAvgTrans", "交易量月均值");
		yAxisMap.put("cpuPeak", "CPU月峰值");
		yAxisMap.put("cpuOnlinePeakAvg", "CPU联机峰值月均值");
		yAxisMap.put("cpuBatchPeakAvg", "CPU批量峰值月均值");
		yAxisMap.put("memPeak", "内存月峰值");
		yAxisMap.put("memOnlinePeakAvg", "内存联机峰值月均值");
		yAxisMap.put("memBatchPeakAvg", "内存批量峰值月均值");
		yAxisMap.put("ioPeak", "IO月峰值");
		yAxisMap.put("ioOnlinePeakAvg", "IO联机峰值月均值");
		yAxisMap.put("ioBatchPeakAvg", "IO批量峰值月均值");
		
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
				xCategoriesOptions.append(_map.get("countMonth")).append(CommonConst.COMMA);
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
		
		fieldsNmMap.put("月份", "countMonth");
		fieldsNmMap.put("交易量月峰值", "monthPeakTrans");
		fieldsNmMap.put("交易量月均值", "dayAvgTrans");
		fieldsNmMap.put("CPU月峰值", "cpuPeak");
		fieldsNmMap.put("CPU联机峰值月均值", "cpuOnlinePeakAvg");
		fieldsNmMap.put("CPU批量峰值月均值", "cpuBatchPeakAvg");
		fieldsNmMap.put("内存月峰值", "memPeak");
		fieldsNmMap.put("内存联机峰值月均值", "memOnlinePeakAvg");
		fieldsNmMap.put("内存批量峰值月均值", "memBatchPeakAvg");
		fieldsNmMap.put("IO月峰值", "ioPeak");
		fieldsNmMap.put("IO联机峰值月均值", "ioOnlinePeakAvg");
		fieldsNmMap.put("IO批量峰值月均值", "ioBatchPeakAvg");
		
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

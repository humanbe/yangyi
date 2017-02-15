package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.jeda.FieldType;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.vo.MonthTransVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
@Repository
@Transactional
public class MonthRptTransService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	public MonthRptTransService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("countMonth", FieldType.STRING);
	}
	
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<MonthTransVo> queryMonthTransList(String aplCode, String startMonth, String endMonth){
		StringBuilder sql = new StringBuilder();
		sql.append("select t.apl_code, ")
			.append("		   to_char(to_date(t.count_month, 'yyyymm'), 'yyyy-mm') as count_month, ")
			.append("		   t.day_avg_trans, ")
			.append("		   t.workday_avg_trans, ")
			.append("   	   t.holiday_avg_trans, ")
			.append("		   t.month_peak_trans, ")
			.append("		   t.month_total_trans ")
			.append("from month_tran t ")
			.append("where t.apl_code = :aplCode ")
			.append("	and t.count_month between :startMonth and :endMonth ")
			.append("order by t.count_month desc");
		return getSession().createSQLQuery(sql.toString()).addEntity(MonthTransVo.class)
									.setString("aplCode", aplCode)
									.setString("startMonth", startMonth)
									.setString("endMonth", endMonth)
									.list();
	}
	
	@Override
	public Map<String, Object> getRptData(
			List<RptItemConfVo> itemList, String sheetName, String aplCode,
			String startMonth, String endMonth, Object...options) {
		List<MonthTransVo> monthTransList = queryMonthTransList(aplCode, startMonth, endMonth);
		
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		
		for(int i = 0; i < monthTransList.size(); i++){
			MonthTransVo vo = monthTransList.get(i);
			if(dateMap.get(vo.getCountMonth()) != null){
				keyMap = dateMap.get(vo.getCountMonth());
			}else{
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			for(RptItemConfVo rvo : itemList){
				if(rvo.getItemName().contains("月份")){
					keyMap.put("countMonth", vo.getCountMonth());
				}else if(rvo.getItemName().equals("日均交易量")){
					keyMap.put("dayAvgTrans", vo.getDayAvgTrans());
				}else if(rvo.getItemName().equals("工作日日均交易量")){
					keyMap.put("workdayAvgTrans", vo.getWorkdayAvgTrans());
				}else if(rvo.getItemName().equals("休息日日均交易量")){
					keyMap.put("holidayAvgTrans", vo.getHolidayAvgTrans());
				}else if(rvo.getItemName().equals("月峰值交易量")){
					keyMap.put("monthPeakTrans", vo.getMonthPeakTrans());
				}else if(rvo.getItemName().equals("月总交易量")){
					keyMap.put("monthTotalTrans", vo.getMonthTotalTrans());
				}
			}
			
			dateMap.put(vo.getCountMonth(), keyMap);
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		returnDataMap.put("metadata", dataList);
		
		return returnDataMap;
	}
	
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap, Object...options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		Map<String, String> fieldsNmMap = new HashMap<String, String>();
		boolean hasElement;
		
		fieldsNmMap.put("月份", "countMonth");
		fieldsNmMap.put("日均交易量", "dayAvgTrans");
		fieldsNmMap.put("工作日日均交易量", "workdayAvgTrans");
		fieldsNmMap.put("休息日日均交易量", "holidayAvgTrans");
		fieldsNmMap.put("月峰值交易量", "monthPeakTrans");
		fieldsNmMap.put("月总交易量", "monthTotalTrans");
		
		for(int i = 0; i < itemList.size(); i++){
			RptItemConfVo vo = itemList.get(i);
			if(i == 0){
				fieldsNames.append("[");
				columnModels.append("[new Ext.grid.RowNumberer(),");
			}
			
			hasElement = false;
			if(fieldsNmMap.get(vo.getItemName()) != null){
				hasElement = true;
				fieldsNames.append("{name:'").append(fieldsNmMap.get(vo.getItemName())).append("'}");
				columnModels.append("{header : '")
									.append(vo.getItemName())
									.append("',")
									.append("dataIndex : '")
									.append(fieldsNmMap.get(vo.getItemName()))
									.append("',")
									.append("sortable : true,")
									.append("width : 150}");
			}
			
			if(i != itemList.size() - 1 && hasElement){
				fieldsNames.append(",");
				columnModels.append(",");
			}else if(i == itemList.size() - 1){
				fieldsNames.append("]");
				columnModels.append("]");
			}
		}
		
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
		
	}

	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, Object...options)
			throws Exception {
		StringBuilder charOptions;
		StringBuilder titleOption;
		StringBuilder yAxisOptions;
		StringBuilder xCategoriesOptions;
		StringBuilder toolTipUnit;
		StringBuilder seriesOptions;
		Map<String, String> chartMap = new HashMap<String,String>();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String,String>();
		
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();
		List<RptChartConfVo> dataChartList = null;
		
		fieldsNmMap.put("月份", "countMonth");
		fieldsNmMap.put("日均交易量", "dayAvgTrans");
		fieldsNmMap.put("工作日日均交易量", "workdayAvgTrans");
		fieldsNmMap.put("休息日日均交易量", "holidayAvgTrans");
		fieldsNmMap.put("月峰值交易量", "monthPeakTrans");
		fieldsNmMap.put("月总交易量", "monthTotalTrans");
		
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

			for(int m = metedataMapList.size() -1; m > -1; m--){
				xCategoriesOptions.append(metedataMapList.get(m).get("countMonth")).append(CommonConst.COMMA);
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
					for(int k = metedataMapList.size()-1; k > -1; k--){
						for(RptItemConfVo vo1 : itemList){
							if(vo1.getItemName().equals(itemName) && fieldsNmMap.get(vo1.getItemName()) != null){
								seriesOptions.append(metedataMapList.get(k).get(fieldsNmMap.get(vo1.getItemName())));
								break;
							}
						}
						
						if(k != 0){
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
		fieldsNmMap.put("日均交易量", "dayAvgTrans");
		fieldsNmMap.put("工作日日均交易量", "workdayAvgTrans");
		fieldsNmMap.put("休息日日均交易量", "holidayAvgTrans");
		fieldsNmMap.put("月峰值交易量", "monthPeakTrans");
		fieldsNmMap.put("月总交易量", "monthTotalTrans");
		
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

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
public class MonthRptTimesTransService implements BaseService<RptItemConfVo, RptChartConfVo> {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	private List<Map<String, String>> queryMonthTimesTransList(String aplCode,
			String startMonth, String endMonth, List<RptItemConfVo> itemList) {
		if(itemList.size() == 0) return null;
		
		StringBuilder sql = new StringBuilder();
		sql.append("select ");
		//纵表转横表

		for(int i = 0; i < itemList.size(); i++){
			RptItemConfVo vo = itemList.get(i);
			if(vo.getItemName().contains("月份")){
				sql.append("to_char(to_date(t.count_month, 'yyyymm'), 'yyyy-mm') as " + vo.getItemName());
			}else if(vo.getItemName().contains("峰值日期")){
				sql.append("to_char(to_date(t.peak_date, 'yyyymmdd'), 'yyyy-mm-dd') as " + vo.getItemName());
			}else{
				sql.append("max(case t.peak_item ")
					.append("when '" + vo.getItemName() + "' then ")
					.append("t.peak_value ")
					.append("else null end ) as " + vo.getItemName());
			}
			
			if(i != itemList.size() - 1){
				sql.append(", ");
			}else{
				sql.append(" ");
			}
		}
		
		sql.append("from month_times_trans t ")
    		.append("where t.apl_code = :aplCode ")
    		.append("	and t.count_month between :startMonth and :endMonth ")
    		.append("	and exists (select * ")
         	.append("		from times_trans_conf c ")
          	.append("		where t.apl_code = c.apl_code ")
          	.append("		 and (");
        //穷举只跟itemList相关的记录

		//判断是否配置表times_trans_conf的科目名或是相关的科目名, 是则取, 反之舍弃
		for(int i = 0; i < itemList.size(); i++){
			sql.append("  			(c.count_item = '" + itemList.get(i).getItemName() + "' and ")
	            .append("   		(instr(c.related_item, t.peak_item) > 0 or ")
	            .append("   		t.peak_item = c.count_item)) ");
			
			if(i != itemList.size() - 1){
				sql.append(" 		or ");
			}
		}
		
		sql.append("   )) ")
    	 	.append("group by t.apl_code, t.peak_date, t.count_month ")
    		.append("order by t.count_month desc ");
		
		return getSession().createSQLQuery(sql.toString())
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .setString("aplCode", aplCode)
									 .setString("startMonth", startMonth)
									 .setString("endMonth", endMonth)
									 .list();
	}
	
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,
			Object... options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		
		for(RptItemConfVo vo : itemList){
			fieldsNmMap.put(vo.getItemName(), vo.getItemName());
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
			String sheetName, String aplCode, String startMonth, String endMonth,
			Object... options) throws Exception {
		List<Map<String, String>> list = queryMonthTimesTransList(aplCode, startMonth, endMonth, itemList);
		
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		Map<String, String> fieldsNmMap = new LinkedHashMap<String, String>();
		
		for(RptItemConfVo vo : itemList){
			fieldsNmMap.put(vo.getItemName(), vo.getItemName());
		}
		
		for(int i = 0; i < list.size(); i++){
			Map<String, String> map = list.get(i);
			if(dateMap.get(map.get("峰值日期")) != null){
				keyMap = dateMap.get(map.get("峰值日期"));
			}else{
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			for(RptItemConfVo rvo : itemList){
				for(String key : fieldsNmMap.keySet()){
					if(rvo.getItemName().trim().equals(key)){
						if(!keyMap.containsKey(fieldsNmMap.get(key))){
							keyMap.put(fieldsNmMap.get(key), map.get(fieldsNmMap.get(key)));
							break;
						}
					}
				}
				
			}
			
			dateMap.put(map.get("峰值日期"), keyMap);
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		returnDataMap.put("metadata", dataList);
		
		return returnDataMap;
	}

	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartList,
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
		
		for(RptItemConfVo vo : itemList){
			fieldsNmMap.put(vo.getItemName(), vo.getItemName());
		}
		
		for(int i = 0; i < chartList.size(); i++){
			RptChartConfVo vo1 = chartList.get(i);
			dataChartList = new ArrayList<RptChartConfVo>();
			dataChartList.add(vo1);
			chartList.remove(i);
			i--;
			for(int j = i + 1; j < chartList.size(); j++){
				RptChartConfVo vo2 = chartList.get(j);
				if(vo1.getAplCode().equals(vo2.getAplCode()) 
						&& vo1.getReportType().equals(vo2.getReportType())
						&& vo1.getSheetName().equals(vo2.getSheetName())
						&& vo1.getChartName().equals(vo2.getChartName())
						&& vo1.getChartSeq() == vo2.getChartSeq()){
					dataChartList.add(vo2);
					chartList.remove(vo2);
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
				xCategoriesOptions.append(metedataMapList.get(m).get("月份")).append(CommonConst.COMMA);
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
		Map<String, String> columns = new LinkedHashMap<String, String>();
		for(RptItemConfVo vo : itemList){
			columns.put(vo.getItemName(), vo.getItemName());
		}
		
		return columns;
	}

}

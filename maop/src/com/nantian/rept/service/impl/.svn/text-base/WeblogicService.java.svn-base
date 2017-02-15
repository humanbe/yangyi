package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.annotation.Resource;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.NumberUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
public class WeblogicService implements BaseService<RptItemConfVo, RptChartConfVo> {
	@Autowired
	private SysDateService sysDateService;
	
	@Autowired
	private WebJdbcService webJdbcService;
	
	@Autowired
	private WebMemoryService webMemoryService;
	
	@Autowired
	private WebQueueService webQueueService;

	@Autowired
	private RptItemConfService rptItemConfService;

	/**
	 * 取得gridpanel动态列(最近31天日weblogic使用情况)
	 * @param itemList 报表科目配置表科目列表
	 * @param modelMap 响应对象
	 */
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,Object...options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		Map<String, Object> map = null;
		List<String> columnHeaderGroupList = new ArrayList<String>();
		columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE);
		columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC);
		columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY);
		int childNum = 0;

		for(int i = 0; i < columnHeaderGroupList.size(); i++){
			String targetTypeName = "";
			//getItemAppName(aplCode, columnHeaderGroupList.get(i))
			/*if(columnHeaderGroupList.get(i).equals("WBLG_DLFZ")){
				targetTypeName = "队列使用数峰值";
			}else if(columnHeaderGroupList.get(i).equals("WBLG_JDBC")){
				targetTypeName = "JDBC使用数峰值";
			}else if(columnHeaderGroupList.get(i).equals("WBLG_NCFZ")){
				targetTypeName = "内存使用率峰值";
			}*/
			
			if(i == 0){
				fieldsNames.append("[");
				columnModels.append("[new Ext.grid.RowNumberer(),");
			}
			
			childNum = 0;
			for(int j = 0; j < itemList.size(); j++){
				
				String aplCode = itemList.get(i).getAplCode();
				targetTypeName = rptItemConfService.getItemAppName(aplCode, columnHeaderGroupList.get(i));
				RptItemConfVo vo = itemList.get(j);
				String itemName = "";
				if(vo.getItemName()==null){
					itemName = vo.getItemCd();
				}else{
					itemName = vo.getItemName();

				}
				if(i == 0 && (itemName.indexOf("日期") != -1 || itemName.indexOf("时间") != -1)){
					fieldsNames.append("{name:'item1'},");
					columnModels.append("{header:'" + itemName + "', dataIndex : 'item1'},");
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
						
//						String itemName = vo.getItemName();
//						if(!columnHeaderGroupList.get(i).equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC)){
//							int startPos = itemName.lastIndexOf("(");
//							int endPos = itemName.lastIndexOf(")");
//							
//							if(startPos != -1 && endPos != -1 && endPos >= startPos){
//								itemName = itemName.substring(0, startPos);
//							}
//						}
						
						columnModels.append("{header:'")
											.append(vo.getItemCd().toString())
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
			
			if(childNum > 0){
				map = new LinkedHashMap<String, Object>();
				map.put("columnsHeader", targetTypeName);
				map.put("childNum", childNum);
				listMap.add(map);
			}
			
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
							.append("}").append(",")//节假日标识

							.append("{header:'").append("统计值标识").append("',")
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
			String itemName = "";
			if(vo.getItemName()==null){
				itemName = vo.getItemCd();
			}else{
				itemName = vo.getItemName();

			}
			if(vo.getGroupParent() != null || itemName.toString().indexOf("日期") != -1){
				continue;
			}
			
			if(count++ == 0){
				fieldsNames.append(",");
				columnModels.append(",");
			}
			
			fieldsNames.append("{name:'")
							  .append(itemName)
							  .append("item")
							  .append(vo.getItemSeq())
							  .append("'}");
			columnModels.append("{header:'")
								.append(itemName)
								.append("',")
								.append("dataIndex:'")
								.append(itemName)
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
	}

	/**
	 * 通过访问日交易量统计表动态获取数据(最近31天日weblogic使用情况)
	 * @param itemList 报表科目配置表科目列表
	 * @param sheetName 报表名
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 日报日期
	 * @return
	 * @throws Exception
	 */
	@Override
	public Map<String, Object> getRptData(
			List<RptItemConfVo> itemList, String sheetName, String aplCode,
			String startDate, String endDate, Object...options) throws Exception {
		
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		List<Map<String, String>> jdbcList = null;
		List<Map<String, String>> memList = null;
		List<Map<String, String>> queueList = null;
		Map<String, List<String>> clusterServers4Jdbc = new HashMap<String, List<String>>();
		List<String> clusterServers4Mem = new ArrayList<String>();
		List<String> clusterServers4Queue = new ArrayList<String>();
		List<String> clusterServers = new ArrayList<String>();
		List<String> jdbcNames = new ArrayList<String>();
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		String server;
		String jdbcName;
		
		
		for(RptItemConfVo vo : itemList){
			
			if(vo.getGroupParent() != null){
				int startPos = vo.getItemCd().lastIndexOf("(");
				int endPos = vo.getItemCd().lastIndexOf(")");
				if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC)){//
					if(startPos != -1 && endPos != -1 &&  endPos > startPos){
						server = vo.getItemCd().substring(0, startPos);
						jdbcName = vo.getItemCd().substring(startPos + 1, endPos);
						if(!clusterServers.contains(server)){
							clusterServers.add(server);
						}
						if(!jdbcNames.contains(jdbcName)){
							jdbcNames.add(jdbcName);
						}
					}else{
						if(!clusterServers.contains(vo.getItemCd())){
							clusterServers.add(vo.getItemCd().toString());
						}
						jdbcNames.add("");
					}
				} 
				
				if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY)){//
					if(startPos != -1){
						server = vo.getItemCd().substring(0, startPos);
						if(!clusterServers4Mem.contains(server)){
							clusterServers4Mem.add(server);
						}
					}else{
						if(!clusterServers4Mem.contains(vo.getItemCd())){
							clusterServers4Mem.add(vo.getItemCd().toString());
						}
					}
				} 
				
				if(vo.getGroupParent().contains(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE)){//
					if(startPos != -1){
						server = vo.getItemCd().substring(0, startPos);
						if(!clusterServers4Queue.contains(server)){
							clusterServers4Queue.add(server);
						}
					}else{
						if(!clusterServers4Queue.contains(vo.getItemCd())){
							clusterServers4Queue.add(vo.getItemCd().toString());
						}
					}
					
				}
			}
		}
		
		if(clusterServers.size() != 0){
			clusterServers4Jdbc.put("clusterServers", clusterServers);
		}
		
		if(jdbcNames.size() != 0){
			clusterServers4Jdbc.put("jdbcNames", jdbcNames);
		}
		
		//根据查询条件动态获取节假日数据
		Map<String, String> holiday = sysDateService.queryAllHoliday(startDate, endDate);
		if(clusterServers4Jdbc.size() > 0){
			jdbcList = webJdbcService.queryWebJdbcPeak(aplCode, startDate, endDate, clusterServers4Jdbc);
		}
		
		if(clusterServers4Mem.size() > 0){
			memList = webMemoryService.queryWebMemoryPeak(aplCode, startDate, endDate, clusterServers4Mem);
		}
		
		if(clusterServers4Queue.size() > 0){
			queueList = webQueueService.queryWebQueuePeak(aplCode, startDate, endDate, clusterServers4Queue);
		}
		
		for(RptItemConfVo vo : itemList){
			if(vo.getGroupParent() != null){
				dataMapBuilder(jdbcList, dateMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC, vo, holiday);//
				dataMapBuilder(memList, dateMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY, vo, holiday);//
				dataMapBuilder(queueList, dateMap, ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE, vo, holiday);//
			}
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		returnDataMap.put("metadata", dataList);
		return returnDataMap;
	}

	/**
	 * 根据weblogic被统计的资源类型构建数据对象
	 * @param targetList 目标数据列表
	 * @param targetMap 目标数据映射
	 * @param targetType 目标类型
	 * @param target 科目配置表实体类
	 * @param holiday 节假日映射列表
	 */
	private void dataMapBuilder(List<Map<String, String>> targetList,
			Map<String, Map<String, Object>> targetMap, String targetType,
			RptItemConfVo target, Map<String, String> holiday) {
		Map<String, Object> keyMap = null;
		String holidayFlag = null;
		if(target.getGroupParent().indexOf(targetType) != -1){
			for(int i = 0; i < targetList.size(); i++){
				Map<String, String> map = targetList.get(i);
				if(target.getItemCd().contains(map.get("clusterServer"))){
					if(targetType.equals(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC) //ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC
							&& !target.getItemCd().contains(map.get("jdbcName"))){
						continue;
					}
					
					keyMap = targetMap.get(map.get("monitorDate"));
					if(keyMap == null){
						keyMap = new HashMap<String, Object>();
						keyMap.put("item1", map.get("monitorDate"));
						holidayFlag = holiday.get(map.get("monitorDate"));
						keyMap.put("holidayFlag", holidayFlag == null ? CommonConst.HOLIDAY_FLAG_1 : holidayFlag);
					}
					/*String targetTypeName = "";
					if(targetType.equals("WBLG_DLFZ")){
						targetTypeName = "队列使用数峰值";
					}else if(targetType.equals("WBLG_JDBC")){
						targetTypeName = "JDBC使用数峰值";
					}else if(targetType.equals("WBLG_NCFZ")){
						targetTypeName = "内存使用率峰值";
					}*/
					String targetTypeName = rptItemConfService.getItemAppName(target.getAplCode(), targetType);

					keyMap.put(targetTypeName + "_item" + target.getItemSeq(), map.get("usedValue"));
					targetMap.put(map.get("monitorDate"), keyMap);
				}
			}
		}
	}
	
	/**
	* 创建图表配置数据(最近31天日weblogic使用情况)
	 * @param itemList 报表科目配置表数据
	 * @param chartsList 报表图表配置表数据
	 * @param metedataMapList 图表元数据
	 * @param endDate 日报日期
	 * @return
	 */
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
		Map<String, String> chartMap = new HashMap<String, String>();
		
		for(int i = 0; i < chartsList.size(); i++){
			charOptions = new StringBuilder();
			titleOption = new StringBuilder();
			yAxisOptions = new StringBuilder();
			xCategoriesOptions = new StringBuilder();
			toolTipUnit = new StringBuilder();
			seriesOptions = new StringBuilder();
			
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
			for(int m = metedataMapList.size() -1; m > -1; m--){
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
				seriesOptions.append("{name:\"").append(itemName.toString()).append("\",").append("data:[");
				for(int j = metedataMapList.size()-1; j > -1; j--){
					for(RptItemConfVo vo : itemList){
						if(null != vo.getGroupParent() && vo.getItemCd().equals(itemName)){
							if(chartsList.get(i).getChartName().indexOf("JDBC") != -1
									&& vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC) != -1){
								String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), "WBLG_JDBC");

								seriesOptions.append(metedataMapList.get(j).get(targetTypeName + "_item" + vo.getItemSeq()));//ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC 
							}else if(vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY) != -1
									&& chartsList.get(i).getChartName().indexOf("内存") != -1){
								String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), "WBLG_NCFZ");

								seriesOptions.append(metedataMapList.get(j).get( targetTypeName + "_item" + vo.getItemSeq()));//ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY
							}else	if(vo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE) != -1
									&& chartsList.get(i).getChartName().indexOf("队列") != -1){
								String targetTypeName = rptItemConfService.getItemAppName(vo.getAplCode(), "WBLG_DLFZ");
								
								seriesOptions.append(metedataMapList.get(j).get(targetTypeName + "_item" + vo.getItemSeq()));//ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE
							}
							break;
						}
					}
					if(j != 0){
						// 最后一次循环时不添加逗号，删除最后一个多余逗号data:[1,2,3,
						seriesOptions.append(CommonConst.COMMA);
					}
				}
				seriesOptions.append("]},");
			}
			// 删除最后一个多余逗号[{name:'xxxx',data:[1,2,3]},{name:'xxxx',data:[4,5,6]},
			seriesOptions.deleteCharAt(seriesOptions.length()-1);
			seriesOptions.append("]");
			
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
	}

	/**
	 * 配置导出excel的数据列标题(最近31天日weblogic使用情况)
	 * @param itemList 报表科目配置表数据

	 * @param date 日报日期
	 * @return
	 */
	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> itemList, Object... options) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		Map<String, String> treeMap = new TreeMap<String, String>();
		String targetTypeName = "";
		for (RptItemConfVo _ricVo : itemList) {
			columns.put("rows", "2");
			if(_ricVo.getItemCd().contains("日期")){
				columns.put("item1", _ricVo.getItemCd());
			}else if(_ricVo.getGroupParent() != null){
				if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC) != -1){
					targetTypeName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_JDBC);
					treeMap.put(targetTypeName + "_item" + _ricVo.getItemSeq(), 
							targetTypeName+"_"+_ricVo.getItemCd());
				}
				if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY) != -1){
					
					targetTypeName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_MEMORY);
					if(_ricVo.getItemCd().indexOf("(")==-1){
						treeMap.put(targetTypeName + "_item" + _ricVo.getItemSeq(), 
								targetTypeName+"_"+_ricVo.getItemCd());
					 }else{
						 treeMap.put(targetTypeName + "_item" + _ricVo.getItemSeq(), 
									targetTypeName+"_"+_ricVo.getItemCd().substring(0,_ricVo.getItemCd().indexOf("(")));
					 }
					
				}
				if(_ricVo.getGroupParent().indexOf(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE) != -1){
					targetTypeName = rptItemConfService.getItemAppName(_ricVo.getAplCode(), ReptConstants.DEFAULT_COLUMN_HEADER_KEY_PEAK_QUEUE);

					if(_ricVo.getItemCd().indexOf("(")==-1){
						treeMap.put(targetTypeName + "_item" + _ricVo.getItemSeq(), 
								targetTypeName+"_"+_ricVo.getItemCd());
					 }else{
						 treeMap.put(targetTypeName + "_item" + _ricVo.getItemSeq(), 
									targetTypeName+"_"+_ricVo.getItemCd().substring(0,_ricVo.getItemCd().indexOf("(")));
					 }
				}
			}
		}
		
		//保证columns的顺序

		for(String key : treeMap.keySet()){
			columns.put(key, treeMap.get(key));
		}
		
		return columns;
	}
	
	
}

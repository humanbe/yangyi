package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.BatchTransVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
@Repository
public class BatchTransService implements BaseService<RptItemConfVo, RptChartConfVo>{
	@Autowired
	private SysDateService sysDateService;

	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 查询批量执行情况
	 * @param aplCode
	 * @param startDate
	 * @param endDate
	 * @param batchNameList
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<BatchTransVo> queryBatchTransList(String aplCode, String startDate,
			String endDate, List<String> batchNameList ,String sheetName){
		StringBuilder sql = new StringBuilder();
		sql.append("select bt.apl_code,   ")
			.append("to_char(to_date(bt.batch_date, 'yyyymmdd'), 'yyyy-mm-dd') as batch_date,  ")
			.append("r.item_name as batch_name, bt.batch_start_time,  ")
			.append("bt.batch_end_time, bt.batch_exe_time,  ")
			.append("bt.end_flg,  bt.comments ")
			.append("from batch_trans bt ,rpt_item_conf r ")
			.append("where bt.apl_code = :aplCode and r.apl_code=bt.apl_code ")
			.append("and bt.batch_name =  substr(r.item_name, instr(r.item_name, '=>', -1) + 2) ")
			.append("and r.report_type = '1' and r.sheet_name = :sheetName ")
			.append("and bt.batch_date between :startDate and :endDate ")
			.append("and r.item_name in :batchNameList ")
			.append("order by bt.batch_date desc, bt.batch_name ");
		
		return getSession().createSQLQuery(sql.toString())
									.addEntity(BatchTransVo.class)
									.setString("aplCode", aplCode)
									.setString("startDate", startDate)
									.setString("endDate", endDate)
									.setString("sheetName", sheetName)
									.setParameterList("batchNameList", batchNameList)
									.list();
	}
	
	/**
	 * 查询批量执行情况(最近7天日批量执行情况)
	 * @param aplCode
	 * @param startDate
	 * @param endDate
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<BatchTransVo> queryBatchTransListForSevenDay(String aplCode, String startDate,
			String endDate){
		StringBuilder sql = new StringBuilder();
		sql.append("select bt.apl_code,  ")
			.append("to_char(to_date(bt.batch_date, 'yyyymmdd'), 'yyyy-mm-dd') as batch_date, ")
			.append("bt.batch_name,  ")
			.append("bt.batch_start_time, ")
			.append("bt.batch_end_time, ")
			.append("bt.batch_exe_time, ")
			.append("bt.end_flg, ")
			.append("bt.comments ")
			.append("from batch_trans bt ")
			.append("where bt.apl_code = :aplCode ")
			.append("	and bt.batch_date between :startDate and :endDate ")
			.append("order by bt.batch_date desc, bt.batch_name ");
		
		return getSession().createSQLQuery(sql.toString()).addEntity(BatchTransVo.class)
									.setString("aplCode", aplCode)
									.setString("startDate", startDate)
									.setString("endDate", endDate)
									.list();
	}

	/**
	 * 创建图表配置数据(最近31天日批量执行情况)
	 * @param itemList 报表科目配置表数据

	 * @param chartsList 报表图表配置表数据

	 * @param metedataMapList 图表元数据

	 * @param endDate 日报日期
	 * @return
	 * @throws Exception
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
		Map<String, String> chartMap = new HashMap<String,String>();
		
		for(int i = 0; i < chartsList.size(); i++){
			charOptions = new StringBuilder();
			titleOption = new StringBuilder();
			yAxisOptions = new StringBuilder();
			xCategoriesOptions = new StringBuilder();
			toolTipUnit = new StringBuilder();
			seriesOptions = new StringBuilder();
			
			switch(ComUtil.changeToChar(chartsList.get(i).getChartType())){
			// 1：趋势图
			case  '1':
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
						toolTipUnit.append("\\'" + vo.getItemName() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
					}
					
					if(count > 0 && j == itemList.size() - 1){
						toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
					}
				}
				toolTipUnit.append("}");
				// 图表统计科目信息
				seriesOptions.append("[");
				for (String itemName : chartsList.get(i).getItemList().split(",")) {
					seriesOptions.append("{name:\"").append(itemName.substring(itemName.lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2)).append("\",").append("data:[");
					for(int j = metedataMapList.size()-1; j > -1; j--){
						//只需要第三项的数据作为图展示的数据, 即运行时间

						seriesOptions.append(metedataMapList.get(j).get(itemName.substring(itemName.lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2).concat("item3")));
						
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
				break;
			// 2：柱状图
			case '2':
				break;
			// 3：饼图

			case '3':
				break;
			//4：条形图
			case '4':
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
	
	}

	/**
	 * 取得gridpanel动态列(最近31天日批量执行情况)
	 * @param itemList 报表科目配置表科目列表

	 * @param modelMap 响应对象
	 */
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,Object...options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		
		for(int i = 0; i < itemList.size(); i++){
			
		if(!(itemList.get(i).getItemName().toString().equals("交易日期")))
			columnHeaderGroupList.add(itemList.get(i).getItemName().toString());
		}
		
		for(int i = 0; i < columnHeaderGroupList.size(); i++){
			if(i == 0){
				fieldsNames.append("[");
				fieldsNames.append("{name : 'item1'},");
				columnModels.append("[new Ext.grid.RowNumberer(),");
				columnModels.append("{header : '交易日期', dataIndex : 'item1'},");
			}
			
			fieldsNames.append("{name:'")
							  .append(columnHeaderGroupList.get(i))
							  .append("item1")
							  .append("'}, ")
							  .append("{name:'")
							  .append(columnHeaderGroupList.get(i))
							  .append("item2")
							  .append("'}, ")
							  .append("{name:'")
							  .append(columnHeaderGroupList.get(i))
							  .append("item3")
							  .append("'} ");
			columnModels.append("{header:'")
								.append(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_START_TIME)
								.append("',")
								.append("dataIndex:'")
								.append(columnHeaderGroupList.get(i))
								.append("item1")
								.append("'}, ")
								.append("{header:'")
								.append(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_END_TIME)
								.append("',")
								.append("dataIndex:'")
								.append(columnHeaderGroupList.get(i))
								.append("item2")
								.append("'}, ")
								.append("{header:'")
								.append(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_EXCUTE_TIME)
								.append("',")
								.append("dataIndex:'")
								.append(columnHeaderGroupList.get(i))
								.append("item3")
								.append("'}");
			
			if(i != columnHeaderGroupList.size() - 1){
				fieldsNames.append(",");
				columnModels.append(",");
			}else{
				fieldsNames.append(",{name : 'holidayFlag'},") //节假日标识

								  .append("{name : 'statisticalFlag'}") //统计值标识

								  .append("]");
				columnModels.append(",{header : '").append("节假日标识").append("',")
									.append("dataIndex : '").append("holidayFlag").append("',")
									.append("sortable : true").append(",")
									.append("hidden : true")
									.append("}").append(",")		//节假日标识

	
									.append("{header : '").append("统计值标识").append("',")
									.append("dataIndex : '").append("statisticalFlag").append("',")
									.append("sortable : true").append(",")
									.append("hidden : true")
									.append("}")		//统计值标识

									.append("]");
			}
		}
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
		modelMap.addAttribute("columnHeaderGroupColspan", 3);
		modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
	}

	/**
	 * 配置导出excel的数据列标题(最近31天日批量执行情况)
	 * @param itemList 报表科目配置表数据

	 * @param date 日报日期
	 * @return
	 */
	@Override
	public Map<String, String> getConfigurableXlsColumns(List<RptItemConfVo> itemList, Object... options) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		for (RptItemConfVo _ricVo : itemList) {
			columns.put("rows", "2");
			if(_ricVo.getItemName().equals("交易日期")){
				columns.put("item1", _ricVo.getItemName());
			}else{
				columns.put(_ricVo.getItemName() + "item1",
								  _ricVo.getItemName()
										  + CommonConst.UNDERLINE
										  + ReptConstants.DEFAULT_COLUMN_HEADER_KEY_START_TIME);
				columns.put(_ricVo.getItemName() + "item2",
								  _ricVo.getItemName()
								  		  + CommonConst.UNDERLINE
								  		  + ReptConstants.DEFAULT_COLUMN_HEADER_KEY_END_TIME);
				columns.put(_ricVo.getItemName() + "item3",
								  _ricVo.getItemName()
								  		  + CommonConst.UNDERLINE
								  		  + ReptConstants.DEFAULT_COLUMN_HEADER_KEY_EXCUTE_TIME);
			}
		}
		return columns;
	}

	/**
	 * 通过访问日交易量统计表动态获取数据(最近31天日批量执行情况)
	 * @param itemList 报表科目配置表科目列表

	 * @param sheetName 报表名

	 * @param aplCode 系统编号
	 * @param startDate 开始时间

	 * @param endDate 日报日期
	 * @return
	 * @throws Exception
	 */
	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> getRptData(
			List<RptItemConfVo> itemList, String sheetName, String aplCode,
			String startDate, String endDate, Object...options) throws Exception {
		
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		List<String> batchNameList = new ArrayList<String>();
		Map<String, Object> keyMap = null;
		String holidayFlag = null;
		//根据查询条件动态获取节假日数据
		Map<String, String> holiday = sysDateService.queryAllHoliday(startDate, endDate);
		
		for(RptItemConfVo vo : itemList){
			if(!vo.getItemName().equals("交易日期")){
				batchNameList.add(vo.getItemName());
			}
		}
		
		List<BatchTransVo> batchTransList = queryBatchTransList(aplCode, startDate, endDate, batchNameList,sheetName);
		for(int i = 0; i < batchTransList.size(); i++){
			if(i % (itemList.size() - 1) == 0){
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			BatchTransVo bvo = batchTransList.get(i);
			keyMap.put(bvo.getBatchName().substring(bvo.getBatchName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2) + "item1", bvo.getBatchStartTime());
			keyMap.put(bvo.getBatchName().substring(bvo.getBatchName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2) + "item2", bvo.getBatchEndTime());
			String expression = null;
			for(RptItemConfVo vo : itemList){
				if(vo.getItemName().equals(bvo.getBatchName()) && vo.getExpression() != null){
					expression = vo.getExpression();
					for(BatchTransVo btvo : batchTransList){
						if(expression.indexOf(btvo.getBatchName()) != -1 && bvo.getBatchDate().equals(btvo.getBatchDate())){
							expression = StringUtil.replaceWithEscape(expression, btvo.getBatchName(), btvo.getBatchExeTime());
						}
					}
					keyMap.put(bvo.getBatchName().substring(bvo.getBatchName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2) + "item3", Math.round(Double.valueOf(NumberUtil.eval(expression))));
					break;
				}
			}
			
			if(expression == null){
				keyMap.put(bvo.getBatchName().substring(bvo.getBatchName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2) + "item3", bvo.getBatchExeTime());
			}
			
			if(i % (itemList.size() - 1) == 0){
				holidayFlag = holiday.get(bvo.getBatchDate());
				keyMap.put("item1", bvo.getBatchDate());
				keyMap.put("holidayFlag", holidayFlag == null ? CommonConst.HOLIDAY_FLAG_1 : holidayFlag);
				dataList.add(keyMap);
			}
		}
		
		returnDataMap.put("metadata", dataList);
		
		return returnDataMap;
	}
}

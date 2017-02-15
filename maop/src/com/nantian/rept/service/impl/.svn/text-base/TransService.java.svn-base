package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;

import org.apache.commons.lang.math.NumberUtils;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.CapThresholdAcqService;
import com.nantian.rept.service.DateTransService;
import com.nantian.rept.service.ITransService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.DateTransVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
@Repository
@Transactional
public class TransService implements ITransService, BaseService<RptItemConfVo, RptChartConfVo>{
	@Autowired
	private SysDateService sysDateService;
	
	@Autowired
	private DateTransService dateTransService;
	
	@Autowired
	private CapThresholdAcqService capThresholdAcqService;
	
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	
	private Session getSession(){
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	/**
	 * 查询昨天的交易量, 历史峰值, 阀值等
	 */
	public String queryTransData(){
		//默认取昨天的数据
		Calendar cal = Calendar.getInstance();
		cal.setTime(new Date());
		cal.add(Calendar.DATE, -1);
		Date yesterday = cal.getTime();
		
		return queryTransData(yesterday);
	}
	
	/**
	 * 查询指定日期的交易量, 历史峰值, 阀值等
	 * @param date
	 * @return
	 */
	@Transactional(readOnly = true)
	public String queryTransData(Date date) {
		String dateStr = "";
		if(date == null){
			dateStr = DateFunction.getSystemDate(-1);
		}else if(date.after(new Date())){
			return "[]";
		}else{
			dateStr = DateFunction.convertDateToStr(date, 6);
		}
		
		StringBuilder sql = new StringBuilder();
		sql.append("select max(a.apl_all_name) as \"sysname\", ")
			.append("      max(tt.count_amount) as \"businesscount\", ")
			.append("      '' as \"businessrate\", ")
			.append("      max(to_number(t.peak_value)) as \"historymax\", ")
			.append("      max(to_number(v.peak_value)) as \"threshold\" ")
			.append(" from peak_item t  ")
			.append(" 		left join (select v.peak_value, v.apl_code ")
			.append("           					from peak_item v ")
			.append("          					where v.count_item = :valveItem) v  ")
			.append("          	on t.apl_code = v.apl_code, ")
			.append("      apl_system a, ")
			.append("      (select a.apl_code, dt.count_amount ")
			.append("         from apl_system a ")
			.append("         left join (select max(t.apl_code) as apl_code, ")
			.append("                          sum(t.count_amount) as count_amount ")
			.append("                     from date_trans t ")
			.append("                    where exists (select * ")
			.append("                             from tran_item i ")
			.append("                            where t.apl_code = i.apl_code ")
			.append("                              and t.count_item = i.count_item) ")
			.append("                      and t.trans_date = :date ")
			.append("                    group by t.apl_code) dt on a.apl_code = dt.apl_code ")
			.append("        where a.apl_code in  (:aplCodeList)) tt  ")
			.append("where t.count_item = :countItem ")
			.append("  and t.apl_code = tt.apl_code ")
			.append("  and a.apl_code = t.apl_code ")
			.append("  and to_date(t.peak_date, 'yyyymmdd') < to_date(:date, 'yyyymmdd') ")
			.append("group by t.apl_code ")
			.append("order by t.apl_code ");
		
		Query query = getSession().createSQLQuery(sql.toString())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.setString("valveItem", ReptConstants.RPT_VAVLE_TRANS_ITEM_NAME)
												.setString("date", dateStr)
												.setString("countItem", ReptConstants.RPT_PEAK_TRANS_ITEM_NAME)
												.setParameterList("aplCodeList", Arrays.asList(ReptConstants.RPT_IMPORTANT_SYSTEM_LIST.split(",")));
		return JSONArray.fromObject(query.list()).toString();
	}

	/**
	 * 取得gridPanel动态列
	 * @param itemList 报表科目配置表科目列表
	 * @param modelMap 响应对象
	 */
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,Object...options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		if(itemList.size() > 0){
			fieldsNames.append("[");
			columnModels.append("[new Ext.grid.RowNumberer(),");
		}
		for (RptItemConfVo rptItemConfVo : itemList) {
			// 1.动态字段			fieldsNames.append("{name : '").append("item").append(rptItemConfVo.getItemSeq()).append("'}")
								.append(",");
			// 2.动态列
			if(rptItemConfVo.getItemName()==null){
				columnModels.append("{header : '")
				.append(rptItemConfVo.getItemCd().toString()).append("',")
				.append("dataIndex : '").append("item").append(rptItemConfVo.getItemSeq()).append("',")
				.append("sortable : true , width : 150 , ")
				.append("renderer : function(value){if(value.indexOf(\"超峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else if(value.indexOf(\"低峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else{return value;}}")
				.append("},");
			}
			if(rptItemConfVo.getItemName()!=null){
				columnModels.append("{header : '")
				.append(rptItemConfVo.getItemName().toString()).append("',")
				.append("dataIndex : '").append("item").append(rptItemConfVo.getItemSeq()).append("',")
				.append("sortable : true , width : 150 , ")
				.append("renderer : function(value){if(value.indexOf(\"超峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else if(value.indexOf(\"低峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else{return value;}}")
				.append("},");
			}
		}
		fieldsNames.append("{name : 'holidayFlag'} , {name : 'statisticalFlag'}")//节假日标识、统计值标识、超峰值列表					.append("]");
		columnModels.append("{header : '节假日标识' , dataIndex : 'holidayFlag' , sortable : true , hidden : true},")	//节假日标识					.append("{header : '统计值标识' , dataIndex : 'statisticalFlag', sortable : true, hidden : true}")	//统计值标识					.append("]");
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
	}
	
	/**
	 * 通过访问日交易量统计表动态获取数据
	 * @param itemList 科目列表
	 * @param sheetName 报表名称
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 结束时间
	 */
	@SuppressWarnings("unchecked")
	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> itemList, 
															String sheetName, 
															String aplCode,
															String startDate, 
															String endDate, 
															Object...options) throws Exception {
		// 方法返回值对象
		Map<String,Object> returnDataMap = new HashMap<String,Object>();
		// 存储数据map对象
		List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
		// 存储合计值、平均值、最大值等统计值map对象
		List<Map<String,Object>> statisticalDataList  = new ArrayList<Map<String,Object>>();
		// 中间编辑对象
		Map<String,Object> dataMap = new HashMap<String, Object>();
		LinkedHashMap<String,Map<String,Object>> statisticalKeyMap = new LinkedHashMap<String, Map<String,Object>>();
		LinkedHashMap<String,Map<String,Object>> keyMap = new LinkedHashMap<String, Map<String,Object>>();
		// 未与日交易量统计表匹配的科目列表
		List<RptItemConfVo> filterMapList  = new ArrayList<RptItemConfVo>();
		try{
			int days = DateFunction.daysBetween(DateFunction.convertStrToDate(startDate, 6), DateFunction.convertStrToDate(endDate, 6)) + 1;
			//根据查询条件动态获取节假日数据
			Map<String,String> holiday = sysDateService.queryAllHoliday(startDate,endDate);
			//保存最近days天日期列表
			String fmEndDate = DateFunction.getNewFormatDateStr(endDate, "yyyyMMdd", "yyyy-MM-dd");
			for(int i = 0; i > - days; i--){
				dataMap = new HashMap<String, Object>();
				keyMap.put(DateFunction.getDateByFormatAndOffset(fmEndDate, 1, i), dataMap);
			}
			// 循环科目列表
			String itemSeq = null;
			String itemName = null;
			for (RptItemConfVo rptItemConfVo : itemList) {
				itemSeq = String.valueOf(rptItemConfVo.getItemSeq());
			
					itemName = rptItemConfVo.getItemCd();
			
				// 查询数据 
				List<DateTransVo> dataTranList = dateTransService.queryDateTransList(aplCode, startDate, endDate, itemName);
				if((dataTranList.size() == 0) && ("日期".equals(itemName) || null != rptItemConfVo.getExpression())){
					// 未与日交易量统计表匹配的科目列表
					filterMapList.add(rptItemConfVo);
					continue;
				}
				String transDate = null;
				for (DateTransVo dateTransConfVo : dataTranList) {
					transDate = dateTransConfVo.getTransDate();
					// 科目名
					keyMap.get(transDate).put("item".concat(itemSeq).concat(CommonConst.UNDERLINE).concat("Name"), dateTransConfVo.getCountItem());
					// 科目值
					keyMap.get(transDate).put("item".concat(itemSeq), dateTransConfVo.getCountAmount());
					// 交易日期
					keyMap.get(transDate).put("transDate", transDate);
					// 节假日标识
					if(null != holiday.get(transDate)){
						// 节假日
						keyMap.get(transDate).put("holidayFlag", CommonConst.HOLIDAY_FLAG_2);
					}else{
						// 工作日
						keyMap.get(transDate).put("holidayFlag", CommonConst.HOLIDAY_FLAG_1);
					}
				}
				//某科目某日数据不存在则置为0
				if(dataTranList.size() != days){
					for (String dateKey : keyMap.keySet()) {
						if(null == keyMap.get(dateKey).get("item".concat(itemSeq))){
							// 科目名
							keyMap.get(dateKey).put("item".concat(itemSeq).concat(CommonConst.UNDERLINE).concat("Name"), itemName);
							// 科目值
							keyMap.get(dateKey).put("item".concat(itemSeq), CommonConst.ZERO);
							// 交易日期
							keyMap.get(dateKey).put("transDate", dateKey);
							// 节假日标识
							if(null != holiday.get(dateKey)){
								// 节假日
								keyMap.get(dateKey).put("holidayFlag", CommonConst.HOLIDAY_FLAG_2);
							}else{
								// 工作日
								keyMap.get(dateKey).put("holidayFlag", CommonConst.HOLIDAY_FLAG_1);
							}
						}
					}
				}
			}
			
			// 编辑未与日交易量统计表匹配的计算式科目列表
			evalExpression(keyMap,filterMapList,itemList,dataList);
			
			// 统计所有科目的合计值、平均值、最大值及历史峰值、容量阀值
			if(itemList.size() != 0){
				List<Map<String,Object>> statisticalList = (List<Map<String, Object>>) dateTransService.queryCtatisticalandPeakVal(aplCode,startDate,endDate,itemList.get(0).getSheetName());
				// 合计值
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("sumValue")){
						dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("sumValue"));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("合计", dataMap);
				}
				// 平均值
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("avgValue")){
						dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("avgValue"));
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("平均值", dataMap);
				}
				// 最大值
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("maxValue")){
						dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("maxValue"));
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("最大值", dataMap);
				}
				// 历史峰值
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("peakValue")){
						if(null != map.get("expression") && null != map.get("expressionUnit") && CommonConst.PERCENT_SYMBOL.equals(map.get("expressionUnit"))){
							dataMap.put("item".concat(map.get("itemSeq").toString()), NumberUtil.format(Double.valueOf(map.get("peakValue").toString()),NumberUtil.FORMAT_PATTERN_60));
						}else{
							dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("peakValue"));
						}
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						
						//当日峰值超出或低于峰值成功率判断
						if(map.get("peakCountItem").toString().indexOf(ReptConstants.KW_SUCCESS_RATE) != -1){
							if(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
										< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
									dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(Double.parseDouble(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString())
										< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
									dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}
						}else{
							if(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
										> Double.parseDouble(map.get("peakValue").toString())){
									dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(Double.parseDouble(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString())
										> Double.parseDouble(map.get("peakValue").toString())){
									dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}
						}
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("历史峰值", dataMap);
				}
				// 峰值日期
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("peakDate")){
						dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("peakDate"));
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("峰值日期", dataMap);
				}
				// 最后一次交易量与历史峰值占比
				dataMap = new HashMap<String, Object>();
				StringBuilder peakExpression = new StringBuilder();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("peakValue")){
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						// 历史峰值占比
						if(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
							peakExpression.append(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString(), 
																																	CommonConst.PERCENT_SYMBOL, 
																																	"")
																						.concat("/100")))
													.append("/")
													.append(map.get("peakValue"));
						}else{
							peakExpression.append(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))))
													.append("/")
													.append(map.get("peakValue"));
						}
						dataMap.put("item".concat(map.get("itemSeq").toString()), NumberUtil.format(Double.valueOf(NumberUtil.eval(peakExpression.toString())), NumberUtil.FORMAT_PATTERN_60));
						peakExpression.delete(0, peakExpression.length());
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("历史峰值占比", dataMap);
				}
				
				//容量阀值统计

				capThresholdAcqService.statisticalCapacityThreshold(aplCode, itemList.get(0).getReportType(), sheetName, statisticalKeyMap,dataList, endDate);
			}
			
			// 编辑未与日交易量统计表匹配的科目列表,包括日期科目与计算表达式科目
			List<Double> statisticalValList  = null;
			for (String key : statisticalKeyMap.keySet()) {
				// 未与日交易量统计表匹配的科目列表
				for (RptItemConfVo rptItemConfVo : filterMapList) {
					statisticalValList = new ArrayList<Double>();	//统计计算用list
					if("".equals(rptItemConfVo.getExpression()) || null == rptItemConfVo.getExpression()){
						// 设定对应的日期科目

						statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), key);
					}else{
						// 计算表达式科目数据列表
						for (Map<String, Object> dMap : dataList) {
							if(null != rptItemConfVo.getExpressionUnit() && !"".equals(rptItemConfVo.getExpressionUnit())){
								statisticalValList.add(Double.valueOf(dMap.get("item".concat(String.valueOf(rptItemConfVo.getItemSeq()))).toString().replaceAll(rptItemConfVo.getExpressionUnit(), "")));
							}else{
								statisticalValList.add(Double.valueOf(dMap.get("item".concat(String.valueOf(rptItemConfVo.getItemSeq()))).toString()));
							}
						}
						if(null != rptItemConfVo.getExpressionUnit() && !"".equals(rptItemConfVo.getExpressionUnit())){
							// 分支判断
							switch(ReptConstants.statisticalItem.getItem(key)){
							case 合计:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), String.valueOf(NumberUtil.format(NumberUtil.getSumValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10)).concat(rptItemConfVo.getExpressionUnit()));
								break;
							case 平均值:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), String.valueOf(NumberUtil.format(NumberUtil.getAvgValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10)).concat(rptItemConfVo.getExpressionUnit()));
								break;
							case 最大值:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), String.valueOf(NumberUtil.format(NumberUtil.getMaxValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10)).concat(rptItemConfVo.getExpressionUnit()));
								break;
							default:
								break;
							}
						}else{
							// 分支判断
							switch(ReptConstants.statisticalItem.getItem(key)){
							case 合计:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.format(NumberUtil.getSumValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10));
								break;
							case 平均值:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.format(NumberUtil.getAvgValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10));
								break;
							case 最大值:
								statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.format(NumberUtil.getMaxValue(statisticalValList),NumberUtil.FORMAT_PATTERN_10));
								break;
							default:
								break;
							}
						}
					}
				}
				statisticalDataList.add(statisticalKeyMap.get(key));
			}
			
			// 元数据
			returnDataMap.put("metadata", dataList);
			// 统计值数据
			returnDataMap.put("statisticalData", statisticalDataList);
			return returnDataMap;
		}catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 科目计算式计算功能

	 * @param keyDataList 当前处理完成的结果数据（包含日期键值）
	 * @param filterMapList 前期过滤后的包括首日期科目与需要计算的科目列表
	 * @param itemList 当前功能下的所有科目列表

	 * @param dataList 当前处理完成的结果数据

	 */
	private void evalExpression(Map<String, Map<String, Object>> keyMap,
												List<RptItemConfVo> filterMapList,
												List<RptItemConfVo> itemList,
												List<Map<String,Object>> dataList) throws Exception {
		try{
			String editExpression;
			boolean noDataFlag = false;
				for (String dateKey : keyMap.keySet()) {
					// 未与日交易量统计表匹配的科目列表
					for (RptItemConfVo filterItemVo : filterMapList) {
						// 设定对应的日期科目

						if("".equals(filterItemVo.getExpression()) || null == filterItemVo.getExpression()){
							keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq()).concat(CommonConst.UNDERLINE).concat("Name")), filterItemVo.getItemCd());
							keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq())), dateKey);
						}else{
							// 计算表达式科目

							noDataFlag = false;
							editExpression = filterItemVo.getExpression();
							// 替换表达式中的汉字为具体的数值
							for (RptItemConfVo itemVo : itemList) {
								if(itemVo.getItemName()!=null){
									if(editExpression.indexOf(itemVo.getItemCd()) != -1){
										if(null == keyMap.get(dateKey).get("item".concat(String.valueOf(itemVo.getItemSeq())))){
											if(null != itemVo.getExpression()){
												//递归处理process
												editExpression = process(editExpression,itemVo,keyMap.get(dateKey),itemList,noDataFlag);
											}else{
												editExpression = ComUtil.getMessage(itemVo.getItemCd());
												noDataFlag = true;
											}
										}else{
											editExpression = StringUtil.replaceWithEscape(editExpression, itemVo.getItemCd(), keyMap.get(dateKey).get("item".concat(String.valueOf(itemVo.getItemSeq()))).toString());
										}
									}
								}
							}
							
							keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq()).concat(CommonConst.UNDERLINE).concat("Name")), filterItemVo.getItemCd());
							if(!noDataFlag){
								if(null != filterItemVo.getExpressionUnit() && !"".equals(filterItemVo.getExpressionUnit())){
									if(CommonConst.PERCENT_SYMBOL.equals(filterItemVo.getExpressionUnit())){
										keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq())), NumberUtil.format(Double.valueOf(NumberUtil.eval(editExpression)),NumberUtil.FORMAT_PATTERN_60));
									}
								}else{
									keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq())), Math.round(Double.valueOf(NumberUtil.eval(editExpression))));
								}
							}else{
								keyMap.get(dateKey).put("item".concat(String.valueOf(filterItemVo.getItemSeq())), editExpression);
							}
						}
					}
					dataList.add(keyMap.get(dateKey));
				}
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 递归编辑处理科目计算式

	 * @param editExpression 当前表达式

	 * @param RptItemConfVo 当前表达式中匹配的科目对象

	 * @param currDataMap 当前行数据

	 * @param itemList 当前功能下的所有科目列表

	 * @param noDataFlag 无数据标志

	 */
	private String process(String editExpression, RptItemConfVo processItemVo, 
									Map<String, Object> currDataMap, 
									List<RptItemConfVo> itemList,
									boolean noDataFlag){
		if(null != currDataMap.get("item".concat(String.valueOf(processItemVo.getItemSeq())))){
			editExpression = StringUtil.replaceWithEscape(editExpression, processItemVo.getItemCd(), currDataMap.get("item".concat(String.valueOf(processItemVo.getItemSeq()))).toString());
		}else{
			editExpression = StringUtil.replaceWithEscape(editExpression, processItemVo.getItemCd(), "(".concat(processItemVo.getExpression()).concat(")"));
			for (RptItemConfVo _ivo : itemList) {
				if(editExpression.indexOf(_ivo.getItemCd()) != -1){
					if(null == currDataMap.get("item".concat(String.valueOf(_ivo.getItemSeq())))){
						if(null != _ivo.getExpression()){
							editExpression = process(editExpression,_ivo,currDataMap,itemList,noDataFlag);
						}else{
							editExpression = ComUtil.getMessage(_ivo.getItemCd());
							noDataFlag = true;
						}
					}else{
						editExpression = StringUtil.replaceWithEscape(editExpression, _ivo.getItemCd(), currDataMap.get("item".concat(String.valueOf(_ivo.getItemSeq()))).toString());
					}
				}
			}
		}
		return editExpression;
	}

	/**
	 * 创建图表配置数据
	 * @param itemList 报表科目配置表数据
	 * @param chartsList 报表图表配置表数据
	 * @param metedataMapList 图表元数据
	 * @param endDate 时间字符串
	 * @throws Exception
	 */
	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
															List<RptChartConfVo> chartsList,
															List<Map<String, Object>> metedataMapList, 
															Object...options) throws Exception {
		StringBuilder charOptions = new StringBuilder();
		StringBuilder titleOption = new StringBuilder();
		StringBuilder yAxisOptions = new StringBuilder();
		StringBuilder xCategoriesOptions = new StringBuilder();
		StringBuilder seriesOptions = new StringBuilder();
		Map<String,String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;
		
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
				seriesOptions = new StringBuilder();
				List<RptChartConfVo> multiChartList = mutipleDataChartList.get(i);
				int chartType = Integer.parseInt(multiChartList.get(0).getChartType());
				
				// 标题
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
				for(int m = metedataMapList.size() -1; m > -1; m--){
					xCategoriesOptions.append(metedataMapList.get(m).get("item1")).append(CommonConst.COMMA);
				}
				if(xCategoriesOptions.length() != 0){
					xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
				}
				// 图表统计科目信息
				boolean breakFlag = false;
				seriesOptions.append("[");
				for(int j = 0; j < multiChartList.size(); j++){
					String [] itemNames = multiChartList.get(j).getItemList().split(",");
					for (int k = 0; k < itemNames.length; k++) {
						String itemName = itemNames[k];
						switch(chartType){
							case 1 ://趋势图

							case 2 ://柱状图
							for(int m=0;m<itemList.size();m++){
								if(itemList.get(m).getItemCd().equals(itemName)){
									seriesOptions.append("{name:\"").append(itemList.get(m).getItemName()).append("\",").append("data:[");
								}
							}
								for(int m = metedataMapList.size()-1; m > -1; m--){
									for (String key : metedataMapList.get(m).keySet()) {
										if(itemName.equals(metedataMapList.get(m).get(key))){
											seriesOptions.append(metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]));
											breakFlag = true;
											break;
										}
									}
									if(!breakFlag){
										seriesOptions.append("null"); //某日无数据时设置为null，否则图表无法展示data数据异常 
									}
									if(m != 0){
										// 最后一次循环时不添加逗号，删除最后一个多余逗号
										seriesOptions.append(CommonConst.COMMA);
									}
									breakFlag = false;
								}
								seriesOptions.append("]");
								seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
								break;
							case 3 ://饼图
								if(k == 0){
									seriesOptions.append("{name:\"").append(multiChartList.get(j).getChartName()).append("\",").append("data:[");
								}
								double sumValue = 0;
								for(int m = metedataMapList.size()-1; m > -1; m--){
									for (String key : metedataMapList.get(m).keySet()) {
										if(itemName.equals(metedataMapList.get(m).get(key))){
											Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
											if(itemValue != null && NumberUtils.isNumber(itemValue.toString())){
												sumValue += Double.parseDouble(itemValue.toString());
												break;
											}
										}
									}
									if(m == 0){
										seriesOptions.append("['" +itemName + "', " + sumValue + "]");
										if(k != itemNames.length - 1){
											seriesOptions.append(CommonConst.COMMA);
										}
									}
								}
								
								if(k == itemNames.length - 1){
									seriesOptions.append("]");
									seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
								}
								break;
						}
						
					}
				}
				// 删除最后一个多余逗号
				seriesOptions.deleteCharAt(seriesOptions.length()-1);
				seriesOptions.append("]");

				// 编辑返回JSON数据
				charOptions.append("{")
								.append("\"chartType\":").append("\"").append(multiChartList.get(0).getChartType()).append("\"").append(CommonConst.COMMA)
								.append("\"titleOption\":").append("\"").append(titleOption.toString()).append("\"").append(CommonConst.COMMA)
								.append("\"yAxisOptions\":").append(yAxisOptions.toString()).append(CommonConst.COMMA)
								.append("\"xCategoriesOptions\":").append("\"").append(xCategoriesOptions).append("\"").append(CommonConst.COMMA)
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
	 * 配置导出excel的数据列标题
	 * @param itemList 报表科目配置表数据
	 * @param date 日报日期
	 * @return
	 */
	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> itemList, Object... options) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		for (RptItemConfVo _ricVo : itemList) {
			columns.put("item".concat(String.valueOf(_ricVo.getItemSeq())), _ricVo.getItemName());
		}
		return columns;
	}
	
}

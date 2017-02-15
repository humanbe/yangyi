package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

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
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.NetResrcVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

@Service
@Repository
public class NetResrcService implements BaseService<RptItemConfVo, RptChartConfVo>{
	@Autowired
	private SysDateService sysDateService;
	
	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 根据系统编号、日报日期、科目列表查询网络资源当日5分钟时间段数据
	 * @param aplCode 系统编号
	 * @param endDate 结束时间
	 * @param srvCode 服务编码
	 * @param monitorItems 科目列表
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<NetResrcVo> queryNetResrcDayList(String aplCode, String endDate, String srvCode,String sheetName, List<String> monitorItems) {
		StringBuilder sql = new StringBuilder();
		sql.append("select tt.apl_code,tt.srv_code,  ")
			.append(" to_char(to_date(tt.monitor_date, 'yyyymmdd'), 'yyyy-mm-dd') as monitor_date, ")
			.append(" tt.monitor_item,tt.monitor_time, ")
			.append(" max(to_number(tt.monitor_value)) as monitor_value ")
			.append(" from (select t.apl_code,t.srv_code,t.monitor_date,")
			.append(" r.item_cd as monitor_item,")
			.append(" to_char(to_date(to_char(to_date(t.monitor_time, 'hh24:mi'),'yyyymmddhh24mi') - mod(to_char(to_date(t.monitor_time, 'hh24:mi'),'yyyymmddhh24mi'),5) + 1,'yyyymmdd hh24:mi'),'hh24:mi') as monitor_time,")
			.append(" t.monitor_value from net_resrc t, rpt_item_conf r")
			.append(" where t.monitor_item = r.item_cd")
			.append(" and r.item_cd in :monitorItems ")
			.append(" and r.report_type ='1'  and r.sheet_name = :sheetName")
			.append(" and t.apl_code = r.apl_code ")
			.append(" and t.srv_code = :srvCode ")
			.append(" and t.monitor_date = :endDate ")
			.append(" and t.apl_code = :aplCode ) tt")
			.append(" group by tt.apl_code,tt.srv_code,tt.monitor_date,tt.monitor_item, tt.monitor_time ")
			.append(" order by tt.monitor_item, tt.monitor_time ");
		
		return getSession().createSQLQuery(sql.toString())
									.addEntity(NetResrcVo.class)
							 		.setString("aplCode", aplCode)
							 		.setString("sheetName", sheetName)
							 		.setString("endDate", endDate)
							 		.setString("srvCode", srvCode)
							 		.setParameterList("monitorItems", monitorItems)
							 		.list();
	}
	
	/**
	 * 根据时间段, 系统编号, 科目列表查询网络资源每天的峰值
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 结束时间
	 * @param monitorItems 科目列表
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<NetResrcVo> queryNetResrcPeakList(String aplCode, String startDate,
			String endDate, String sheetName,List<String> monitorItems) {
		StringBuilder sql = new StringBuilder();
		sql.append(" select n.apl_code,  n.srv_code as, n.monitor_item,")
			.append(" to_char(to_date(n.monitor_date, 'yyyymmdd'), 'yyyy-mm-dd') as monitor_date, ")
			.append(" n.monitor_time,  n.monitor_value ")
			.append(" from (select t.apl_code,t.srv_code,t.monitor_date,t.monitor_time,t.monitor_value,r.item_cd as monitor_item,  ")
			.append(" row_number() over(partition by t.monitor_item, t.monitor_date order by to_number(t.monitor_value) desc) rn ")
			.append(" from net_resrc t , rpt_item_conf r ")
			.append(" where t.monitor_item =  r.item_cd ")
			.append(" and r.item_cd in :monitorItems")
			.append(" and r.report_type = '1' and r.sheet_name = :sheetName")
			.append(" and t.apl_code = r.apl_code  and t.apl_code = :aplCode")
			.append(" and t.monitor_date between :startDate and :endDate) n ")
			.append(" where rn = 1 ")
			.append(" order by n.monitor_date desc ");
		
		return getSession().createSQLQuery(sql.toString())
									.addEntity(NetResrcVo.class)
							 		.setString("aplCode", aplCode)
							 		.setString("sheetName", sheetName)
							 		.setString("startDate", startDate)
							 		.setString("endDate", endDate)
							 		.setParameterList("monitorItems", monitorItems)
							 		.list();
		
	}
	
	/**
	 * 查询数据—获取合计值、平均值、最大值	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryCtatisticalandPeakVal(String aplCode, String startDate, String endDate, String sheetName) {
		StringBuilder sql = new StringBuilder();
		sql.append("select w.countItem as \"countItem\", ")
			.append(" 			w.itemSeq as \"itemSeq\", ")
			.append(" 			w.expression as \"expression\", ")
			.append(" 			w.expressionUnit as \"expressionUnit\", ")
			.append(" 			w.sumValue as \"sumValue\", ")
			.append(" 			w.avgValue as \"avgValue\", ")
			.append(" 			w.maxValue as \"maxValue\", ")
			.append(" 			w.countItem as \"peakCountItem\", ")
			.append(" 			to_char(to_date(w.peakDate,'YYYY-MM-DD'),'YYYY-MM-DD') as \"peakDate\", ")
			.append(" 			w.peakValue as \"peakValue\", ")
			.append("           w.peakPreDate as \"peakPreDate\", ")
			.append("           w.peakPreValue as \"peakPreValue\", ")
			.append("           w.peakGrowthRate as \"peakGrowthRate\" ")
			.append(" from (select o.countItem as countItem, ")
			.append("			 		o.itemSeq as itemSeq, ")
			.append(" 					o.expression as expression, ")
			.append(" 					o.expressionUnit as expressionUnit, ")
			.append(" 					o.sumVal as sumValue, ")
			.append("					o.avgVal as avgValue, ")
			.append(" 					o.maxVal as maxValue, ")
			.append(" 					pi.count_item as peakCountItem, ")
			.append(" 					to_char(to_date(pi.peak_date,'YYYY-MM-DD'),'YYYY-MM-DD') as peakDate, ")
			.append("				 	pi.peak_value as peakValue, ")
			.append(" 					to_char(to_date(pi.peak_pre_date, 'YYYY-MM-DD'), 'YYYY-MM-DD') as peakPreDate, ")
			.append("				 	pi.peak_pre_value as peakPreValue, ")
			.append("				 	pi.peak_growth_rate as peakGrowthRate, ")
			.append("					row_number() over(partition by o.aplCode, o.countItem order by to_number(pi.peak_value) desc) as rn ")
			.append("		from ( select ri.item_cd as countItem, ")
			.append("							ri.item_seq as itemSeq, ")
			.append("							max(ri.apl_code) as aplCode, ")
			.append("                          max(ri.sheet_name) as sheetName, ")
			.append("							max(ri.expression) as expression, ")
			.append("							max(ri.expression_unit) as expressionUnit, ")
			.append("							sum(cast(dt.monitor_value as int)) as sumVal, ")
			.append("							round(avg(cast(dt.monitor_value as int))) as avgVal, ")
			.append("							max(cast(dt.monitor_value as int)) as maxVal ")
			.append(" 				from rpt_item_conf ri left join net_resrc dt ")
			.append(" 						on ri.apl_code = dt.apl_code and ri.item_cd = dt.monitor_item ")
			.append(" 						and dt.monitor_date between :startDate and :endDate ")
			.append(" 				where 1=1  and ri.apl_code =:aplCode ")
			.append(" 				and ri.sheet_name =:sheetName ")
			.append(" 				group by ri.item_cd,ri.item_seq) o left join peak_item pi ")
			.append(" 		on o.countItem = pi.count_item ")
			.append(" 		and pi.apl_code = :aplCode ")
			.append(" 		and pi.peak_date < :endDate ")
			.append(" 		order by o.itemSeq")
			.append(" ) w where w.rn = 1 ");
		 
		Query query = getSession().createSQLQuery(sql.toString());
		query.setString("aplCode", aplCode)
				.setString("startDate", startDate)
				.setString("endDate", endDate)
				.setString("sheetName", sheetName)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		return  query.list();
	}

	/**
	 * 取得gridpanel动态列(最近31天日网络资源使用情况)
	 * @param itemList 报表科目配置表科目列表	 * @param modelMap 响应对象
	 */
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,Object...options) {
		Map<String, Object> map = null;
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		
		List<String> columnHeaderGroupList = new ArrayList<String>();
		int[] childNumArr;
		
		for(int i = 0; i < itemList.size(); i++){
			RptItemConfVo vo = itemList.get(i);
			if(vo.getGroupParent() != null && !columnHeaderGroupList.contains(vo.getGroupParent())){
				columnHeaderGroupList.add(vo.getGroupParent());
			}
		}
		
		childNumArr = new int[columnHeaderGroupList.size()];
		
		for(int i = 0; i < itemList.size(); i++){
			if(i == 0){
				fieldsNames.append("[");
				columnModels.append("[new Ext.grid.RowNumberer(),");
			}
			
			RptItemConfVo vo = itemList.get(i);
			if(vo.getItemCd().indexOf("日期") != -1 || vo.getItemCd().indexOf("时间") != -1){
				fieldsNames.append("{name : 'item1'}");
				columnModels.append("{header : '" + vo.getItemCd() + "', dataIndex : 'item1'}");
				map = new LinkedHashMap<String, Object>();
				map.put("columnsHeader", "");
				map.put("childNum", 1);
				listMap.add(map);
			}else if(vo.getGroupParent() != null){
				fieldsNames.append("{name:'").append(vo.getItemCd()).append("item").append(vo.getItemSeq()).append("'}");
				columnModels.append("{header : '").append(vo.getItemName()).append("',")
									.append("dataIndex : '").append(vo.getItemCd()).append("item").append(vo.getItemSeq()).append("',")
									.append("sortable : true,")
									.append("renderer : function(value){if(value.indexOf(\"超峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else if(value.indexOf(\"低峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else{return value;}},")
									.append("width : 150}");
				for(int j = 0; j < columnHeaderGroupList.size(); j++){
					if(columnHeaderGroupList.get(j).equals(vo.getGroupParent())){
						for(int k = 0; k < listMap.size(); k++){
							Map<String, Object> m = listMap.get(k);
							if(m.get("columnsHeader").toString().equals(vo.getGroupParent())){
								m.put("childNum", ++childNumArr[j]);
							}else if(k == listMap.size() - 1){
								map = new LinkedHashMap<String, Object>();
								map.put("columnsHeader", columnHeaderGroupList.get(j));
								map.put("childNum", ++childNumArr[j]);
								listMap.add(map);
								break;
							}
						}
					}
				}
			}else{
				fieldsNames.append("{name:'").append(vo.getItemCd()).append("item").append(vo.getItemSeq()).append("'}");
				columnModels.append("{header : '").append(vo.getItemName()).append("',")
									.append("dataIndex : '").append(vo.getItemCd()).append("item").append(vo.getItemSeq()).append("',")
									.append("sortable : true,")
									.append("renderer : function(value){if(value.indexOf(\"超峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else if(value.indexOf(\"低峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else{return value;}},")
									.append("width : 150}");
				
				map = new LinkedHashMap<String, Object>();
				map.put("columnsHeader", "");
				map.put("childNum", 1);
				listMap.add(map);
			}
			
			if(i != itemList.size() -1){
				fieldsNames.append(",");
				columnModels.append(",");
			}else{
				fieldsNames.append(", {name : 'holidayFlag'},") //节假日标识.
								  .append("{name : 'statisticalFlag'}") //统计值标识.
								  .append("]");
				columnModels.append(",{header : '").append("节假日标识").append("',")
									.append("dataIndex : '").append("holidayFlag").append("',")
									.append("sortable : true").append(",")
									.append("hidden : true")
									.append("}").append(",")		//节假日标识.
									.append("{header : '").append("统计值标识").append("',")
									.append("dataIndex : '").append("statisticalFlag").append("',")
									.append("sortable : true").append(",")
									.append("hidden : true")
									.append("}")		//统计值标识.
									.append("]");
				map = new LinkedHashMap<String, Object>();
				map.put("columnsHeader", "");
				map.put("childNum", 2);
				listMap.add(map);
			}
		}
		
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
		modelMap.addAttribute("columnHeaderGroupList", listMap);
	}

	/**
	 * 通过访问日交易量统计表动态获取数据(最近31天日网络资源使用情况)
	 * @param itemList 报表科目配置表科目列表
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 日报日期
	 * @param sheetName 报表名
	 * @return
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> getRptData(
			List<RptItemConfVo> itemList, String sheetName, String aplCode,
			String startDate, String endDate, Object...options) throws Exception {

		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		Map<String, Object> keyMap = null;
		Map<String, Map<String, Object>> dateMap = new LinkedHashMap<String, Map<String,Object>>();
		Map<String,Object> dataMap = new HashMap<String, Object>();
		LinkedHashMap<String,Map<String,Object>> statisticalKeyMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String,Object>> statisticalDataList  = new ArrayList<Map<String,Object>>();
		List<String> itemNameList = new ArrayList<String>();
		String holidayFlag = null;
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		
		//根据查询条件动态获取节假日数据
		Map<String, String> holiday = sysDateService.queryAllHoliday(startDate, endDate);
		
		for(RptItemConfVo vo : itemList){
			itemNameList.add(vo.getItemCd());
		}
		
		List<NetResrcVo> netResrcPeakList = queryNetResrcPeakList(aplCode, startDate, endDate,sheetName, itemNameList);
		for(int i = 0; i < netResrcPeakList.size(); i++){
			NetResrcVo vo = netResrcPeakList.get(i);
			if(dateMap.get(vo.getMonitorDate()) != null){
				keyMap = dateMap.get(vo.getMonitorDate());
			}else{
				keyMap = new LinkedHashMap<String, Object>();
			}
			
			for(RptItemConfVo rvo : itemList){
				if(rvo.getItemCd().equals(vo.getMonitorItem())){
					if(rvo.getExpression() != null){
						String expression = rvo.getExpression();
						for(NetResrcVo nvo : netResrcPeakList){
							if(expression.indexOf(nvo.getMonitorItem()) != -1 && vo.getMonitorDate().equals(nvo.getMonitorDate())){
								expression = StringUtil.replaceWithEscape(expression, nvo.getMonitorItem(), nvo.getMonitorValue());
							}
						}
						keyMap.put(rvo.getItemCd() + "item" + rvo.getItemSeq(), 
							Math.round(Double.valueOf(NumberUtil.eval(expression))));
					}else{
						keyMap.put(rvo.getItemCd() + "item" + rvo.getItemSeq(), 
							vo.getMonitorValue());
					}
					break;
				}
			}
			
			holidayFlag = holiday.get(vo.getMonitorDate());
			keyMap.put("item1", vo.getMonitorDate());
			keyMap.put("holidayFlag", holidayFlag == null ? CommonConst.HOLIDAY_FLAG_1 : holidayFlag);
			dateMap.put(vo.getMonitorDate(), keyMap);				
		}
		
		for(String key : dateMap.keySet()){
			dataList.add(dateMap.get(key));
		}
		
		// 统计所有科目的最大值及历史峰值.
		if(itemList.size() != 0){
			List<Map<String,Object>> statisticalList = (List<Map<String, Object>>) queryCtatisticalandPeakVal(aplCode,startDate,endDate,itemList.get(0).getSheetName());
			// 最大值.
			dataMap = new HashMap<String, Object>();
			for (Map<String, Object> map : statisticalList) {
				if(null != map.get("maxValue")){
					if(null != map.get("expression") && !"".equals(map.get("expression"))){
						dataMap.put(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString()), Math.round(Double.valueOf(NumberUtil.eval(String.valueOf(map.get("expression")).replaceAll(String.valueOf(map.get("peakCountItem")), String.valueOf(map.get("maxValue")))))));
					}else{
						dataMap.put(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString()), map.get("maxValue"));
					}
					//统计值标志位
					dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
				}
			}
			if(dataMap.size() != 0){
				statisticalKeyMap.put("最大值", dataMap);
			}
			// 历史峰值			dataMap = new HashMap<String, Object>();
			for (Map<String, Object> map : statisticalList) {
				if(null != map.get("peakValue")){
					if(null != map.get("expression") && !"".equals(map.get("expression"))){
						dataMap.put(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString()), Math.round(Double.valueOf(NumberUtil.eval(String.valueOf(map.get("expression")).replaceAll(String.valueOf(map.get("peakCountItem")), String.valueOf(map.get("peakValue")))))));
					}else{
						dataMap.put(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString()), map.get("peakValue"));
					}
					//统计值标志位
					dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					
					//当日峰值超出或低于峰值成功率判断
					if(map.get("peakCountItem").toString().indexOf(ReptConstants.KW_SUCCESS_RATE) != -1){
						if(dataList!=null && !dataList.isEmpty() && dataList.size()>0){
							if(dataList.get(0).get(String.valueOf(map.get("peakCountItem")).concat("item").concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
										//< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
										< (Double.parseDouble(dataMap.get(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString())).toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
									dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat(String.valueOf(map.get("peakCountItem"))).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(Double.parseDouble(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString())
//										< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
										< (Double.parseDouble(dataMap.get(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString())).toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
									dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat(String.valueOf(map.get("peakCountItem"))).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}
						}
					}else{
						if(dataList!=null && !dataList.isEmpty() && dataList.size()>0){
							if(dataList.get(0).get(String.valueOf(map.get("peakCountItem")).concat("item").concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get("item".concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
//										> Double.parseDouble(map.get("peakValue").toString())){
										> Double.parseDouble(dataMap.get(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString())).toString())){
									dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat(String.valueOf(map.get("peakCountItem"))).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(Double.parseDouble(dataList.get(0).get(String.valueOf(map.get("peakCountItem")).concat("item").concat(String.valueOf(map.get("itemSeq")))).toString())
//										> Double.parseDouble(map.get("peakValue").toString())){
										> Double.parseDouble(dataMap.get(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString())).toString())){
									dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat(String.valueOf(map.get("peakCountItem"))).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}
						}
					}
				}
			}
			if(dataMap.size() != 0){
				statisticalKeyMap.put("历史峰值", dataMap);
			}
			// 峰值日期.
			dataMap = new HashMap<String, Object>();
			for (Map<String, Object> map : statisticalList) {
				if(null != map.get("peakDate")){
					dataMap.put(String.valueOf(map.get("peakCountItem")).concat("item").concat(map.get("itemSeq").toString()), map.get("peakDate"));
					//统计值标志位
					dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
				}
			}
			if(dataMap.size() != 0){
				statisticalKeyMap.put("峰值日期", dataMap);
			}
		}
		for (String key : statisticalKeyMap.keySet()) {
			statisticalKeyMap.get(key).put("item1", key);
			statisticalDataList.add(statisticalKeyMap.get(key));
		}
		
		// 元数据		returnDataMap.put("metadata", dataList);
		// 统计值数据		returnDataMap.put("statisticalData", statisticalDataList);
		
		return returnDataMap;
	}

	/**
	* 创建图表配置数据(最近31天日网络资源使用情况)
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
		Map<String, String> chartMap = new HashMap<String,String>();
		
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();
		List<RptChartConfVo> dataChartList = null;
		
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
				for (String itemCd : multiChartList.get(j).getItemList().split(",")) {
					//遍历itemList查询匹配编码的编码中文名称
					for(int m=0;m<itemList.size();m++){
						if(itemList.get(m).getItemCd().equals(itemCd)){
							seriesOptions.append("{name:\"").append(itemList.get(m).getItemName()).append("\",").append("data:[");
						}
					}
					for(int k = metedataMapList.size()-1; k > -1; k--){
						for(RptItemConfVo vo1 : itemList){
							if(vo1.getItemCd().equals(itemCd)){
								seriesOptions.append(metedataMapList.get(k).get(vo1.getItemCd() + "item" + vo1.getItemSeq()));
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

	/**
	 * 配置导出excel的数据列标题(最近31天日网络资源使用情况)
	 * @param itemList 报表科目配置表数据

	 * @param date 日报日期
	 * @return
	 */
	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> itemList, Object... options) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		for (RptItemConfVo _ricVo : itemList) {
			columns.put("rows", "2");
			if(_ricVo.getItemName().indexOf("日期") != -1 || _ricVo.getItemName().indexOf("时间") != -1){
				columns.put("item1", _ricVo.getItemName());
			}else if(_ricVo.getGroupParent() != null){
				columns.put(_ricVo.getItemName() + "item" + _ricVo.getItemSeq(),
						_ricVo.getGroupParent() + CommonConst.UNDERLINE + _ricVo.getItemName());
			}else{
				columns.put(_ricVo.getItemName() + "item" + _ricVo.getItemSeq(), _ricVo.getItemName());
			}
		}
		
		return columns;
	}

}

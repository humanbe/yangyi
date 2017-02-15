package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.jeda.FieldType;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.CapThresholdAcqService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.rept.vo.TimesTransVo;

@Service
@Repository
public class TimesTransService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SysDateService sysDateService;
	
	@Autowired
	private CapThresholdAcqService capThresholdAcqService;
	
	/** HIBERNATE Session Factory */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 构造方法
	 */
	public TimesTransService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("transDate", FieldType.STRING);
		fields.put("countItem", FieldType.STRING);
		fields.put("countAmount", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(TimesTransVo timesTransVo) {
		getSession().save(timesTransVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(TimesTransVo timesTransVo) {
		getSession().update(timesTransVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<TimesTransVo> timesTransVos) {
		for (TimesTransVo timesTransVo : timesTransVos) {
			getSession().save(timesTransVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param timesTransVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<TimesTransVo> timesTransVos) {
		for (TimesTransVo timesTransVo : timesTransVos) {
			getSession().saveOrUpdate(timesTransVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param timesTransVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(TimesTransVo timesTransVo) {
			getSession().saveOrUpdate(timesTransVo);
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param aplCode 应用系统编号
	 * @param transDate 交易日期
	 * @param countItem 统计科目
	 * @return DateTransConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public TimesTransVo findByUnionKey(String aplCode, String transDate, String countItem){
		return (TimesTransVo) getSession()
				.createQuery("from TimesTransVo tt where tt.aplCode=:aplCode and tt.transDate=:transDate and tt.countItem=:countItem ")
				.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setString("countItem", countItem)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(TimesTransVo timesTransVo) {
		getSession().delete(timesTransVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[3];
		for (String key : primaryKeys) {
			keyArr = key.split(CommonConst.STRING_COMMA);
			deleteById(keyArr[0],keyArr[1],keyArr[2]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode, String transDate, String countItem) {
		getSession().createQuery("delete from TimesTransVo tt where tt.aplCode=? and tt.transDate=? and tt.countItem=?")
			.setString(0, aplCode)
			.setString(1, transDate)
			.setString(2, countItem)
			.executeUpdate();
	}

	/**
	 * 查询数据
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<TimesTransVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from TimesTransVo tt where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(!key.equals("startDate") && !key.equals("endDate")){
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and tt." + key + " like :" + key);
					} else {
						hql.append(" and tt." + key + " = :" + key);
					}
				}
			}
		}
		hql.append(" and tt.transDate between :startDate and :endDate");
		hql.append(" order by tt." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询最近的分钟和秒科目列表
	 * @param aplCode 系统编号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryLatestItems(String aplCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map( ")
			.append("  t.countItem as countItem) ")
			.append("  from TimesTransVo t ")
			.append(" where t.aplCode = :aplCode ")
			.append("   and t.transDate = (select max(t.transDate) ")
			.append("                         			from TimesTransVo t ")
			.append("                       		  where t.aplCode = :aplCode) ");
		
		return getSession().createQuery(hql.toString()).setString("aplCode", aplCode).list();
	}
	
	/**
	 * 查询天分钟和秒交易情况统计表
	 * @param aplCode
	 * @param startDate
	 * @param endDate
	 * @param countItem
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<TimesTransVo> queryTimesTransList(String aplCode, String startDate, String endDate, String countItem) {

		StringBuilder sql = new StringBuilder();
		sql.append("select tt.apl_code,  ")
			.append("to_char(to_date(tt.trans_date, 'yyyymmdd'), 'yyyy-mm-dd') as trans_date, ")
			.append("tt.count_item, ")
			.append("tt.count_amount ")
			.append("from Times_Trans tt where 1=1 ")
			.append(" and tt.apl_code = :aplCode")
			.append(" and tt.trans_date between :startDate and :endDate")
			.append(" and tt.count_item = :countItem ");
		
		 sql.append(" order by tt.apl_code, tt.trans_date desc, tt.count_item ");
		 
		Query query = getSession().createSQLQuery(sql.toString()).addEntity(TimesTransVo.class);
		query.setString("aplCode", aplCode)
				.setString("startDate", startDate)
				.setString("endDate", endDate)
				.setString("countItem", countItem);
		
		return query.list();
	}
	
	/**
	 * 查询数据—获取合计值、平均值、最大值.
	 * @param start
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
			.append(" 			to_char(to_date(w.peakDate,'YYYY-MM-DD'),'YYYY-MM-DD') as \"peakDate\", ")
			.append(" 			w.countItem as \"peakCountItem\", ")
			.append(" 			w.peakValue as \"peakValue\" ")
			.append("  from (select o.countItem as countItem, ")
			.append("			 		o.itemSeq as itemSeq, ")
			.append(" 					o.expression as expression, ")
			.append(" 					o.expressionUnit as expressionUnit, ")
			.append(" 					o.sumVal as sumValue, ")
			.append("					o.avgVal as avgValue, ")
			.append(" 					o.maxVal as maxValue, ")
			.append(" 					to_char(to_date(pi.peak_date,'YYYY-MM-DD'),'YYYY-MM-DD') as peakDate, ")
			.append(" 					pi.count_item as peakCountItem, ")
			.append("				 	pi.peak_value as peakValue, ")
			.append("					row_number() over(partition by o.aplCode,o.countItem order by pi.peak_value desc) as rn ")
			.append("		from ( select ri.item_cd as countItem, ")
			.append("							ri.item_seq as itemSeq, ")
			.append("							max(ri.apl_code) as aplCode, ")
			.append("                          max(ri.sheet_name) as sheetName, ")
			.append("							max(ri.expression) as expression, ")
			.append("							max(ri.expression_unit) as expressionUnit, ")
			.append("							sum(cast(tt.count_amount as float)) as sumVal, ")
			 
			.append("							round(avg(cast(tt.count_amount as float)),4) as avgVal,  ")
			.append("							max(cast(tt.count_amount as float)) as maxVal ")
			.append(" 				from rpt_item_conf ri left join times_trans tt ")
			.append(" 						on ri.apl_code = tt.apl_code and ri.item_cd = tt.count_item ")
			.append(" 						and tt.trans_date between :startDate and :endDate ")
			.append("                      and regexp_like(tt.count_amount,'^[0-9]*[.]*[0-9]*$') ")
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
	 * 取得gridpanel动态列
	 * @param itemList 报表科目配置表科目列表
	 * @param modelMap 响应对象
	 * @param options 其他选项
	 */
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,
			Object... options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		StringBuilder sb = new StringBuilder();

		columnHeaderGroupList.add(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS);
		for (int i=0; i < columnHeaderGroupList.size(); i++) {
			if(i == 0){
				fieldsNames.append("[{name : 'item1'},");
				columnModels.append("[new Ext.grid.RowNumberer() , {header : '日期', dataIndex : 'item1'},");
			}
			for (int j=0; j < itemList.size(); j++) {
				// 1.动态fields fieldsNames.append("[{name : 'xxx'}]");
					fieldsNames.append("{name : '")
										.append(columnHeaderGroupList.get(i)).append("item").append(itemList.get(j).getItemSeq())
										.append("'}");
					if(itemList.get(j).getItemName()==null){
						columnModels.append("{header : '").append(itemList.get(j).getItemCd()).append("',")
											.append("dataIndex : '").append(columnHeaderGroupList.get(i)).append("item").append(itemList.get(j).getItemSeq()).append("',")
											.append("sortable : true , width : 150");
					}else{
						columnModels.append("{header : '").append(itemList.get(j).getItemName()).append("',")
						.append("dataIndex : '").append(columnHeaderGroupList.get(i)).append("item").append(itemList.get(j).getItemSeq()).append("',")
						.append("sortable : true , width : 150");
					}
					if(itemList.get(j).getItemCd().indexOf("日期") != -1 && itemList.get(j).getItemCd().trim().length() == 2){
						columnModels.append(",hidden : true");
					}
					columnModels.append(", renderer : function(value){if(value.indexOf(\"超峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else if(value.indexOf(\"低峰值\") != -1){return '<span style=\"color:red;font-size:14px;font-weight: 900\">' + value + '</span>';}else{return value;}}")
										.append("}");
					if(j != itemList.size() -1){
						fieldsNames.append(",");
						columnModels.append(",");
					}
			}
			if(i == columnHeaderGroupList.size() - 1){
				fieldsNames.append(",{name : 'holidayFlag'} , {name : 'statisticalFlag'}") //节假日标识、统计值标识、超峰值列表
									.append("]");
				columnModels.append(",{header : '节假日标识', dataIndex : 'holidayFlag' , sortable : true , hidden : true}")		//节假日标识
									.append(",{header : '统计值标识', dataIndex : 'statisticalFlag', sortable : true , hidden : true}")		//统计值标识
									.append("]");
			}else{
				fieldsNames.append(",");
				columnModels.append(",");
			}
		}
		modelMap.addAttribute("columnHeaderGroupColspan", itemList.size());
		modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
		
	}

	/**
	 * 通过访问天分钟和秒交易情况统计表动态获取数据
	 * @param itemList 报表科目配置表科目列表
	 * @param sheetName 功能名称
	 * @param aplCode 系统代码
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @param options 其他选项
	 * @return
	 * @throws Exception
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	@SuppressWarnings("unchecked")
	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> itemList,
			String sheetName, String aplCode, String startDate, String endDate,
			Object... options) throws Exception {
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
			//根据查询条件动态获取节假日数据
			Map<String,String> holiday = sysDateService.queryAllHoliday(startDate,endDate);
			//获取日期差

			int days = DateFunction.daysBetween(DateFunction.convertStrToDate(startDate, 6), DateFunction.convertStrToDate(endDate, 6)) + 1;
			//保存最近days天日期列表

			String fmEndDate = DateFunction.getNewFormatDateStr(endDate, "yyyyMMdd", "yyyy-MM-dd");
			for(int i = 0; i > - days; i--){
				dataMap = new HashMap<String, Object>();
				keyMap.put(DateFunction.getDateByFormatAndOffset(fmEndDate, 1, i), dataMap);
			}
			// 循环科目列表
			for (RptItemConfVo rptItemConfVo : itemList) {
				// 查询数据 
				List<TimesTransVo> timesTranList = queryTimesTransList(aplCode, startDate, endDate, rptItemConfVo.getItemCd());
				if((timesTranList.size() == 0) && ("日期".equals(rptItemConfVo.getItemCd()) || null != rptItemConfVo.getExpression())){
					// 未与日交易量统计表匹配的科目列表
					filterMapList.add(rptItemConfVo);
					continue;
				}
				for (TimesTransVo timesTransVo : timesTranList) {
					// 科目名

					keyMap.get(timesTransVo.getTransDate()).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), timesTransVo.getCountItem());
					// 科目值

					keyMap.get(timesTransVo.getTransDate()).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), timesTransVo.getCountAmount());
					// 交易日期
					keyMap.get(timesTransVo.getTransDate()).put("transDate", timesTransVo.getTransDate());
					// 节假日标识

					if(null != holiday.get(timesTransVo.getTransDate())){
						// 节假日

						keyMap.get(timesTransVo.getTransDate()).put("holidayFlag", CommonConst.HOLIDAY_FLAG_2);
					}else{
						// 工作日

						keyMap.get(timesTransVo.getTransDate()).put("holidayFlag", CommonConst.HOLIDAY_FLAG_1);
					}
				}
				//某科目某日数据不存在则置为0
				if(timesTranList.size() != days){
					for (String dateKey : keyMap.keySet()) {
						if(null == keyMap.get(dateKey).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())))){
							// 科目名

							keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), rptItemConfVo.getItemName());
							// 科目值

							keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), CommonConst.ZERO);
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
			
			// 编辑未与日交易量统计表匹配的科目列表
			String editExpression;
			boolean noDataFlag = false;
			for (String dateKey : keyMap.keySet()) {
				// 未与日交易量统计表匹配的科目列表
				for (RptItemConfVo rptItemConfVo : filterMapList) {
					// 设定对应的日期科目


					if("".equals(rptItemConfVo.getExpression()) || null == rptItemConfVo.getExpression()){
						keyMap.get(dateKey).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq()).concat(CommonConst.UNDERLINE).concat("Name")), rptItemConfVo.getItemName());
						keyMap.get(dateKey).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), dateKey);
					}else{
						// 计算表达式科目


						noDataFlag = false;
						editExpression = rptItemConfVo.getExpression();
						// 替换表达式中的汉字为具体的数值


						for (RptItemConfVo itemVo : itemList) {
							if(editExpression.indexOf(itemVo.getItemCd()) != -1){
								if(null == keyMap.get(dateKey).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(itemVo.getItemSeq())))){
									editExpression = ComUtil.getMessage(itemVo.getItemCd());
									noDataFlag = true;
								}else{
									editExpression = StringUtil.replaceWithEscape(editExpression, itemVo.getItemCd(), keyMap.get(dateKey).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(itemVo.getItemSeq()))).toString());
								}
							}
						}
						
						keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq()).concat(CommonConst.UNDERLINE).concat("Name")), rptItemConfVo.getItemCd());
						if(!noDataFlag){
							if(null != rptItemConfVo.getExpressionUnit() && !"".equals(rptItemConfVo.getExpressionUnit())){
								if(CommonConst.PERCENT_SYMBOL.equals(rptItemConfVo.getExpressionUnit())){
									keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.format(Double.valueOf(NumberUtil.eval(editExpression)),NumberUtil.FORMAT_PATTERN_60));
								}
							}else{
								keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), Math.round(Double.valueOf(NumberUtil.eval(editExpression))));
							}
						}else{
							keyMap.get(dateKey).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), editExpression);
						}
					}
				}
				dataList.add(keyMap.get(dateKey));
			}
			
			// 统计所有科目的合计值、平均值、最大值及历史峰值

			if(itemList.size() != 0){
				List<Map<String,Object>> statisticalList = (List<Map<String, Object>>) queryCtatisticalandPeakVal(aplCode,startDate,endDate,itemList.get(0).getSheetName());
				// 合计值

				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("sumValue")){
						dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), map.get("sumValue"));
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
						dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), map.get("avgValue"));
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
						dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), map.get("maxValue"));
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
							dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), NumberUtil.format(Double.valueOf(map.get("peakValue").toString()),NumberUtil.FORMAT_PATTERN_60));
						}else{
							dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), map.get("peakValue"));
						}
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						
						//当日峰值超出或低于峰值成功率判断
						if(map.get("peakCountItem").toString().indexOf(ReptConstants.KW_SUCCESS_RATE) != -1){
							if(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
										< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
									dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(NumberUtil.isNumeric(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString())){
									if(Double.parseDouble(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString())
											< (Double.parseDouble(map.get("peakValue").toString())-Double.parseDouble(ReptConstants.KW_SUCCESS_RATE_WARN_INTERVAL))){
										dataList.get(0).put("lowPeaks", (null==dataList.get(0).get("lowPeaks")?"":dataList.get(0).get("lowPeaks")).toString().concat(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
									}
								}
							}
						}else{
							if(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
								if(Double.parseDouble(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString(), 
										CommonConst.PERCENT_SYMBOL, "").concat("/100")))
										> Double.parseDouble(map.get("peakValue").toString())){
									dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
								}
							}else{
								if(NumberUtil.isNumeric(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString())){
									if(Double.parseDouble(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString())
											> Double.parseDouble(map.get("peakValue").toString())){
										dataList.get(0).put("exceedPeaks", (null==dataList.get(0).get("exceedPeaks")?"":dataList.get(0).get("exceedPeaks")).toString().concat(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS).concat("item").concat(String.valueOf(map.get("itemSeq"))).concat(CommonConst.STRING_COMMA));
									}
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
						dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), map.get("peakDate"));
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
					if(null != map.get("peakValue") && NumberUtil.isNumeric(String.valueOf(map.get("peakValue")))){
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						// 历史峰值占比

						if(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString().contains(CommonConst.PERCENT_SYMBOL)){
							peakExpression.append(NumberUtil.eval(StringUtil.replaceWithEscape(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))).toString(),
																																		CommonConst.PERCENT_SYMBOL, 
																																	"")
																						.concat("/100")))
													.append("/")
													.append(map.get("peakValue"));
						}else{
							peakExpression.append(dataList.get(0).get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(map.get("itemSeq")))))
													.append("/")
													.append(map.get("peakValue"));
						}
						dataMap.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(map.get("itemSeq").toString()), NumberUtil.format(Double.valueOf(NumberUtil.eval(peakExpression.toString())), NumberUtil.FORMAT_PATTERN_60));
						peakExpression.delete(0, peakExpression.length());
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("历史峰值占比", dataMap);
				}
				
				//容量阀值统计				capThresholdAcqService.statisticalCapacityThreshold(aplCode, itemList.get(0).getReportType(), sheetName, statisticalKeyMap,dataList, endDate);
			}
			
			// 编辑未与天分钟和秒交易情况统计表匹配的科目列表,包括日期科目与计算表达式科目
			List<Double> statisticalValList  = null;
			for (String key : statisticalKeyMap.keySet()) {
				// 未与日交易量统计表匹配的科目列表
				for (RptItemConfVo rptItemConfVo : filterMapList) {
					statisticalValList  = new ArrayList<Double>();	//统计计算用list
					if("".equals(rptItemConfVo.getExpression()) || null == rptItemConfVo.getExpression()){
						// 设定对应的日期科目


						statisticalKeyMap.get(key).put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), key);
					}else{
						// 计算表达式科目数据列表

						for (Map<String, Object> dMap : dataList) {
							if(null != rptItemConfVo.getExpressionUnit() && !"".equals(rptItemConfVo.getExpressionUnit())){
								statisticalValList.add(Double.valueOf(dMap.get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq()))).toString().replaceAll(rptItemConfVo.getExpressionUnit(), "")));
							}else{
								statisticalValList.add(Double.valueOf(dMap.get(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq()))).toString()));
							}
						}
						// 分支判断
						switch(ReptConstants.statisticalItem.getItem(key)){
						case 合计:
							statisticalKeyMap.get(key).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.getSumValue(statisticalValList));
							break;
						case 平均值:
							statisticalKeyMap.get(key).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.getAvgValue(statisticalValList));
							break;
						case 最大值:
							statisticalKeyMap.get(key).put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS.concat("item").concat(String.valueOf(rptItemConfVo.getItemSeq())), NumberUtil.getMaxValue(statisticalValList));
							break;
						default:
							break;
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
		} catch (Exception ex) {
			throw ex;
		}
		
	}


	/**
	 * 创建图表配置数据
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
		StringBuilder charOptions = null;
		StringBuilder titleOption = null;
		StringBuilder yAxisOptions = null;
		StringBuilder xCategoriesOptions = null;
		StringBuilder seriesOptions = null;
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
//						seriesOptions.append("[{name: '对公账务总交易量',data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]}")
//						.append(",{name: '银企通账务总交易量',data: [-0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]}")
//						.append(",{name: '对私账务总交易量',data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]}")
//						.append(",{name: '对私查询交易量',data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]}")
//						.append("]");
				boolean breakFlag = false;
				seriesOptions.append("[");
				for(int j = 0; j < multiChartList.size(); j++){
					String [] itemNames = multiChartList.get(j).getItemList().split(",");
					for (int k = 0; k < itemNames.length; k++) {
						String itemName = itemNames[k];
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
						
					}
				}
				// 删除最后一个多余逗号[{name:'xxxx',data:[1,2,3]},{name:'xxxx',data:[4,5,6]},
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
		columns.put("rows", "2");
		columns.put("item1", "日期");
		for (RptItemConfVo _ricVo : itemList) {
			
			if(null!=_ricVo.getItemName()&&!"日期".equals(_ricVo.getItemName())){
				columns.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
											  		.concat("item")
											  		.concat(String.valueOf(_ricVo.getItemSeq())),
								ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
													.concat(CommonConst.UNDERLINE)
											  		.concat(_ricVo.getItemName()));
			}else{
				columns.put(ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
				  		.concat("item")
				  		.concat(String.valueOf(_ricVo.getItemSeq())),
	ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
						.concat(CommonConst.UNDERLINE)
				  		.concat(_ricVo.getItemCd()));
			}
		}
		return columns;
	}

}

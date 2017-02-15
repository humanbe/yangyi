package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.vo.HoursTransVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class HoursTransService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/** 日志输出 */
	final Logger logger = Logger.getLogger(HoursTransService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法
	 */
	public HoursTransService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("transDate", FieldType.STRING);
		fields.put("countHourTime", FieldType.STRING);
		fields.put("countItem", FieldType.STRING);
		fields.put("countAmount", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(HoursTransVo hoursTransVo) {
		getSession().save(hoursTransVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(HoursTransVo hoursTransVo) {
		getSession().update(hoursTransVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<HoursTransVo> hoursTransVos) {
		for (HoursTransVo hoursTransVo : hoursTransVos) {
			getSession().save(hoursTransVo);
		}
	}
	
	/**
	 * 批量保存或者更新

	 * @param dateTransVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<HoursTransVo> hoursTransVos) {
		for (HoursTransVo hoursTransVo : hoursTransVos) {
			getSession().saveOrUpdate(hoursTransVo);
		}
	}
	
	/**
	 * 保存或者更新

	 * @param dateTransVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(HoursTransVo hoursTransVo) {
			getSession().saveOrUpdate(hoursTransVo);
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param aplCode 应用系统编号
	 * @param transDate 交易日期
	 * @param countHourTime 统计小时
	 * @param countItem 统计科目
	 * @return DateTransConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public HoursTransVo findByUnionKey(String aplCode, String transDate, String countHourTime, String countItem){
		return (HoursTransVo) getSession()
				.createQuery("from HoursTransVo ht where ht.aplCode=:aplCode and ht.transDate=:transDate and ht.countHourTime=:countHourTime and ht.countItem=:countItem ")
				.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setString("countHourTime", countHourTime)
				.setString("countItem", countItem)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(HoursTransVo hoursTransVo) {
		getSession().delete(hoursTransVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[4];
		for (String key : primaryKeys) {
			keyArr = key.split(CommonConst.STRING_COMMA);
			deleteById(keyArr[0],keyArr[1],keyArr[2],keyArr[3]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode, String transDate, String countHourTime, String countItem) {
		getSession().createQuery("delete from HoursTransVo ht where ht.aplCode=? and ht.transDate=? and ht.countHourTime=? and ht.countItem=?")
			.setString(0, aplCode)
			.setString(1, transDate)
			.setString(2, countHourTime)
			.setString(3, countItem)
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
	public List<HoursTransVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from HoursTransVo ht where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(!key.equals("startDate") && !key.equals("endDate")){
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and ht." + key + " like :" + key);
					} else {
						hql.append(" and ht." + key + " = :" + key);
					}
				}
			}
		}
		hql.append(" and ht.transDate between :startDate and :endDate");
		hql.append(" order by ht." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询分小时数据

	 * @param aplCode
	 * @param startDate
	 * @param endDate
	 * @param sheetName
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryAllList(String aplCode, String startDate, String endDate, String sheetName) {

		StringBuilder sql = new StringBuilder();
		
		sql.append("select ri.apl_code as \"aplCode\", ")
			.append(" ri.report_type as \"reportType\", ")
			.append(" ri.sheet_name as \"sheetName\", ")
			.append(" ri.item_cd as \"itemName\", ")
			.append(" ri.item_seq as \"itemSeq\", ")
			.append(" ri.expression as \"expression\", ")
			.append(" ri.expression_unit as \"expressionUnit\", ")
			.append(" to_char(to_date(o.trans_date,'YYYYMMDD'),'YYYYMMDD') as \"transDate\", ")
			.append(" case length(to_number(o.count_hour_time)) when 1 then to_char('0'||to_number(o.count_hour_time)) else to_char(to_number(o.count_hour_time)) end as \"countHourTime\", ")
			.append(" o.count_item as \"countItem\", ")
			.append(" o.count_amount as \"countAmount\" ")
			.append(" from rpt_item_conf ri left join ( select t.sheet_name,t.item_cd,t.item_seq,t.expression,h.apl_code,h.trans_date,h.count_hour_time,h.count_item,h.count_amount ")
			.append(" from rpt_item_conf t,hours_trans h where 1=1 ")
			.append(" and t.sheet_name like :sheetName ")
			.append(" and t.apl_code = h.apl_code ")
			.append(" and t.item_cd = h.count_item ")
			.append(" and h.trans_date between :startDate and :endDate")
			.append(" and t.apl_code = :aplCode ) o ")
			.append(" on ri.apl_code = o.apl_code ")
			.append(" and ri.item_cd = o.item_cd ")
			.append(" where ri.apl_code = :aplCode ")
			.append(" and ri.sheet_name = :sheetName ")
			.append(" order by ri.item_seq,o.trans_date,o.count_hour_time");
		 
		Query query = getSession().createSQLQuery(sql.toString());

		query.setString("aplCode", aplCode)
				.setString("startDate", startDate)
				.setString("endDate", endDate)
				.setString("sheetName", sheetName)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		return  query.list();
	}
	
	/**
	 * 查询峰值日数据
	 * @param aplCode
	 * @param peakDate
	 * @param itemName
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryPeakDateList(String aplCode, String peakDate, String itemName) {

		StringBuilder sql = new StringBuilder();
		
		sql.append("select t.apl_code as \"aplCode\", ")
			.append(" to_char(to_date(t.trans_date,'YYYYMMDD'),'YYYYMMDD') as \"transDate\", ")
			.append(" case length(to_number(t.count_hour_time)) when 1 then to_char('0'||to_number(t.count_hour_time)) else to_char(to_number(t.count_hour_time)) end as \"countHourTime\", ")
			.append(" t.count_item as \"countItem\", ")
			.append(" t.count_amount as \"countAmount\" ")
			.append(" from hours_trans t where 1=1 ")
			.append(" and t.apl_code = :aplCode ")
			.append(" and t.trans_date = :peakDate ")
			.append(" and t.count_item = :countItem ")
			.append(" order by t.count_hour_time");
		 
		Query query = getSession().createSQLQuery(sql.toString());

		query.setString("aplCode", aplCode)
				.setString("peakDate", peakDate)
				.setString("countItem", itemName)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		return  query.list();
	}
	
	/**
	 * 查询实时分小时累计交易量峰值日期

	 * @param aplCode
	 * @param countItem
	 * @param endDate
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryPeakDate(String aplCode, String countItem, String endDate) {

		StringBuilder sql = new StringBuilder();
		
		sql.append("select o.* from ( ")
			.append(" select t.*, ")
			.append(" row_number() over(partition by t.apl_code, t.count_item order by to_number(t.count_amount) desc) rn ")
			.append(" from hours_trans t ")
			.append(" where t.apl_code =:aplCode ")
			.append(" and  t.count_item =:countItem ")
			.append(" and  to_date(t.trans_date,'yyyyMMdd') < to_date(:endDate,'yyyyMMdd') ")
			.append(" ) o where rn = 1 ");
		 
		Query query = getSession().createSQLQuery(sql.toString()).addEntity(HoursTransVo.class);

		query.setString("aplCode", aplCode)
				.setString("countItem", countItem)
				.setString("endDate", endDate);
		
		return  query.uniqueResult();
	}
	

	@Override
	public void getColumns(List<RptItemConfVo> elist, 
									ModelMap modelMap,
									Object... options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		StringBuilder sb = new StringBuilder();
		StringBuilder ss = new StringBuilder();
		for(int i =0; i > -7 ; i--){
			columnHeaderGroupList.add(DateFunction.getDateByFormatAndOffset(options[0].toString(), 0, i));
		}
		
		for (int i=0; i < columnHeaderGroupList.size(); i++) {
			if(i == 0){
				fieldsNames.append("[");
				fieldsNames.append("{name : 'hour'},");
				columnModels.append("[new Ext.grid.RowNumberer(),");
				columnModels.append("{header : '小时', dataIndex : 'hour'},");
			}
			for (int j=0; j < elist.size(); j++) {
					fieldsNames.append("{name : '")
										.append(columnHeaderGroupList.get(i)).append("item").append(elist.get(j).getItemSeq())
										.append("'}");
						if(elist.get(j).getItemName()==null){
							columnModels.append("{header : '").append(elist.get(j).getItemCd()).append("',")
							.append("dataIndex : '").append(columnHeaderGroupList.get(i)).append("item").append(elist.get(j).getItemSeq()).append("',")
							.append("sortable : true,")
							.append("width : 150");
						}else{
							columnModels.append("{header : '").append(elist.get(j).getItemName()).append("',")
							.append("dataIndex : '").append(columnHeaderGroupList.get(i)).append("item").append(elist.get(j).getItemSeq()).append("',")
							.append("sortable : true,")
							.append("width : 150");
						}
						if(elist.get(j).getItemCd().indexOf("小时") != -1 && elist.get(j).getItemCd().trim().length() == 2){//elist.get(j).getItemName().trim().length() == 2
							columnModels.append(",hidden : true");
						}
						columnModels.append("}");
						if(j != elist.size() -1){
							fieldsNames.append(",");
							columnModels.append(",");
						}
			}
			if(i == columnHeaderGroupList.size() - 1){
				fieldsNames.append("]");
				columnModels.append("]");
			}else{
				fieldsNames.append(",");
				columnModels.append(",");
			}
		}
		modelMap.addAttribute("columnHeaderGroupColspan", elist.size());
		modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
	}

	/**
	 * 通过访问小时交易量统计表动态获取数据(最近七天分小时交易情况)
	 * @param itemList 报表科目配置表科目列表
	 * @param sheetName 功能名称
	 * @param aplCode 系统代码
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @return
	 * @throws Throwable
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> elist,
															String sheetName, 
															String aplCode, 
															String startDate, 
															String endDate,
															Object... options) throws Exception {
		// 方法返回值对象
		Map<String,Object> returnDataMap = new HashMap<String,Object>();
		// 存储数据map对象
		List<Map<String,Object>> dataList = new ArrayList<Map<String,Object>>();
		// 中间编辑对象
		Map<String,Object> dataMap = null;
		LinkedHashMap<String,Map<String,Object>> hoursKeyMap = new LinkedHashMap<String, Map<String,Object>>();
		// 未与小时交易量统计表匹配的科目列表
		List<Map<String,Object>> filterMapList  = new ArrayList<Map<String,Object>>();
		for (String hour : ComUtil.hoursList) {
			dataMap = new HashMap<String, Object>();
			hoursKeyMap.put(hour, dataMap);
		}
		try{
			List<Map<String,Object>> list = (List<Map<String, Object>>) queryAllList(aplCode,startDate,endDate,sheetName);
			for (Map<String, Object> map : list) {
				if(map.get("itemName").toString().equals("小时") && null==map.get("expression")){
					filterMapList.add(map);
					continue;
				}else if(null != map.get("expression") && !"".equals(map.get("expression").toString())){
					filterMapList.add(map);
					continue;
				}else if(null != map.get("transDate") && null != map.get("countHourTime") && !"".equals(map.get("transDate").toString()) && !"".equals(map.get("countHourTime").toString())){
					if(null != hoursKeyMap.get(map.get("countHourTime"))){
						// 科目名
						hoursKeyMap.get(map.get("countHourTime")).put(map.get("transDate").toString().concat("item").concat(map.get("itemSeq").toString()).concat(CommonConst.UNDERLINE).concat("Name"), map.get("itemName"));
						// 科目值
						hoursKeyMap.get(map.get("countHourTime")).put(map.get("transDate").toString().concat("item").concat(map.get("itemSeq").toString()), map.get("countAmount"));
					}else{
						dataMap = new HashMap<String, Object>();
						// 科目名
						dataMap.put(map.get("transDate").toString().concat("item").concat(map.get("itemSeq").toString()).concat(CommonConst.UNDERLINE).concat("Name"), map.get("itemName"));
						// 科目值
						dataMap.put(map.get("transDate").toString().concat("item").concat(map.get("itemSeq").toString()), map.get("countAmount"));
						dataMap.put("transDate", map.get("transDate"));
						hoursKeyMap.put(map.get("countHourTime").toString(), dataMap);
					}
				}
			}
			
			//没有的数据补0
			List<String> columnHeaderGroupList = new ArrayList<String>();
			for(int i =0; i > -7 ; i--){
				columnHeaderGroupList.add(DateFunction.getDateByFormatAndOffset(endDate, 0, i));
			}
			for (String hour : ComUtil.hoursList) {
				for (String day : columnHeaderGroupList) {
					for (RptItemConfVo eVo : elist) {
						if(null == hoursKeyMap.get(hour).get(day.concat("item").concat(eVo.getItemSeq().toString()))){
							// 科目名

							hoursKeyMap.get(hour).put(day.concat("item").concat(eVo.getItemSeq().toString()).concat(CommonConst.UNDERLINE).concat("Name"), eVo.getItemName());
							// 科目值

							hoursKeyMap.get(hour).put(day.concat("item").concat(eVo.getItemSeq().toString()), 0);
						}
					}
				}
			}
			
			// 编辑未与日交易量统计表匹配的计算式科目列表
			evalExpression(hoursKeyMap,filterMapList,elist,dataList,endDate);
			
			// 元数据
			returnDataMap.put("metadata", dataList);
			
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 科目计算式计算功能
	 * @param keyMap 当前处理完成的结果数据（包含小时键值）
	 * @param filterMapList 前期过滤后的包括首日期科目与需要计算的科目列表
	 * @param itemList 当前功能下的所有科目列表
	 * @param dataList 当前处理完成的结果数据
	 */
	public void evalExpression(Map<String, Map<String, Object>> keyMap,
												List<Map<String,Object>> filterMapList,
												List<RptItemConfVo> itemList,
												List<Map<String,Object>> dataList,
												String endDate) throws Exception {
		try{
			String editExpression;
			String oldExpression;
			boolean noDataFlag = false;
			for (String timeKey : keyMap.keySet()) {
				for (Map<String,Object> filterMap : filterMapList) {
					if(filterMap.get("itemName").toString().equals("小时")){//sb = "ALL=>ALL=>小时"
							keyMap.get(timeKey).put("hour", timeKey);
					}else{
						// 计算表达式科目

						noDataFlag = false;
						editExpression = filterMap.get("expression").toString();
						oldExpression = editExpression;
						// 替换表达式中的变量名为具体的数值

						for(int i =0; i > -7 ; i--){
							for (RptItemConfVo itemVo : itemList) {
								if(editExpression.indexOf(itemVo.getItemCd()) != -1){
									if(null == keyMap.get(timeKey).get(DateFunction.getDateByFormatAndOffset(endDate, 0, i).concat("item").concat(String.valueOf(itemVo.getItemSeq())))){
										if(null != itemVo.getExpression()){
											//递归处理process
											editExpression = process(editExpression,itemVo,keyMap.get(timeKey),itemList,DateFunction.getDateByFormatAndOffset(endDate, 0, i),noDataFlag);
										}else{
											editExpression = ComUtil.getMessage(itemVo.getItemCd());
											noDataFlag = true;
										}
									}else{
										editExpression = StringUtil.replaceWithEscape(editExpression, itemVo.getItemCd(), keyMap.get(timeKey).get(DateFunction.getDateByFormatAndOffset(endDate, 0, i).concat("item").concat(String.valueOf(itemVo.getItemSeq()))).toString());
									}
								}
							}
							if(!noDataFlag){
								if(null != filterMap.get("expressionUnit") && !"".equals(filterMap.get("expressionUnit").toString())){
									if(CommonConst.PERCENT_SYMBOL.equals(filterMap.get("expressionUnit").toString())){
										keyMap.get(timeKey).put(DateFunction.getDateByFormatAndOffset(endDate, 0, i).concat("item").concat(String.valueOf(filterMap.get("itemSeq"))), NumberUtil.format(Double.valueOf(NumberUtil.eval(editExpression)),NumberUtil.FORMAT_PATTERN_60));
									}
								}else{
									keyMap.get(timeKey).put(DateFunction.getDateByFormatAndOffset(endDate, 0, i).concat("item").concat(String.valueOf(filterMap.get("itemSeq"))), Math.round(Double.valueOf(NumberUtil.eval(editExpression))));
								}
							}else{
								keyMap.get(timeKey).put(DateFunction.getDateByFormatAndOffset(endDate, 0, i).concat("item").concat(String.valueOf(filterMap.get("itemSeq"))), editExpression);
							}
							editExpression = oldExpression;
						}
					}
				}
				dataList.add(keyMap.get(timeKey));
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

	 * @param currDate 当期处理日期
	 * @param noDataFlag 无数据标志

	 */
	private String process(String editExpression, 
										RptItemConfVo processItemVo, 
										Map<String, Object> currDataMap, 
										List<RptItemConfVo> itemList,
										String currDate,
										boolean noDataFlag){
		if(null != currDataMap.get(currDate.concat("item").concat(String.valueOf(processItemVo.getItemSeq())))){
			editExpression = StringUtil.replaceWithEscape(editExpression, processItemVo.getItemName(), currDataMap.get(currDate.concat("item").concat(String.valueOf(processItemVo.getItemSeq()))).toString());
		}else{
			editExpression = StringUtil.replaceWithEscape(editExpression, processItemVo.getItemName(), "(".concat(processItemVo.getExpression()).concat(")"));
			for (RptItemConfVo itemVo : itemList) {
				if(editExpression.indexOf(itemVo.getItemName()) != -1){
					if(null == currDataMap.get(currDate.concat("item").concat(String.valueOf(itemVo.getItemSeq())))){
						if(null != itemVo.getExpression()){
							//递归处理process
							editExpression = process(editExpression,itemVo,currDataMap,itemList,currDate,noDataFlag);
						}else{
							editExpression = ComUtil.getMessage(itemVo.getItemName());
							noDataFlag = true;
						}
					}else{
						editExpression = StringUtil.replaceWithEscape(editExpression, itemVo.getItemName(), currDataMap.get(currDate.concat("item").concat(String.valueOf(itemVo.getItemSeq()))).toString());
					}
				}
			}
		}
		return editExpression;
	}
	
	/**
	 * 创建图表配置数据(最近七天分小时交易情况)
	 * @param 报表科目配置表数据
	 * @param 报表图表配置表数据
	 * @param 图表元数据
	 * @param 日报日期
	 * @throws Throwable
	 */
	@Override
	public Map<String, String> getChart(List<RptItemConfVo> elist,
			List<RptChartConfVo> clist,
			List<Map<String, Object>> metedataMapList, Object...options)
			throws Exception {
		StringBuilder charOptions = null ;
		StringBuilder titleOption = null ;
		StringBuilder yAxisOptions = null ;
		StringBuilder xCategoriesOptions = null ;
		StringBuilder seriesOptions = null ;
		Map<String,String> chartMap = new HashMap<String,String>();
		String endDate = "";
		if(options.length > 0){
			endDate = (String) options[0];
		}
		try{
			for(int i = 0; i < clist.size(); i++){
				charOptions = new StringBuilder();
				titleOption = new StringBuilder();
				yAxisOptions = new StringBuilder();
				xCategoriesOptions = new StringBuilder();
				seriesOptions = new StringBuilder();
				switch(ComUtil.changeToChar(clist.get(i).getChartType())){
					case  '1':	// 1：趋势图
						// 标题
						titleOption.append(clist.get(i).getChartName());
						// Y轴信息(左&右)
						yAxisOptions.append("{")
											.append("\"yAxis\":{")
											.append("\"yAxisTitle\":").append("\"").append(clist.get(i).getChartYaxisTitle()).append("\"").append(CommonConst.COMMA)
											.append("\"yAxisMinval\":").append(NumberUtil.formatNumByUnit(clist.get(i).getChartYaxisMinval(), ComUtil.checkNull(clist.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
											.append("\"yAxisMaxval\":").append(NumberUtil.formatNumByUnit(clist.get(i).getChartYaxisMaxval(), ComUtil.checkNull(clist.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
											.append("\"yAxisInterval\":").append(NumberUtil.formatNumByUnit(clist.get(i).getChartYaxisInterval(), ComUtil.checkNull(clist.get(i).getChartYaxisUnit()))).append(CommonConst.COMMA)
											.append("\"yAxisUnit\":").append("\"").append(ComUtil.checkNull(clist.get(i).getChartYaxisUnit())).append("\"")
											.append("}")
											.append("}");
						// X轴科目信息
						for (Map<String,Object> map : metedataMapList) {
							xCategoriesOptions.append(map.get("hour")).append(CommonConst.COMMA);
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
						seriesOptions.append("[");
						for(int k =0; k > -7 ; k--){
							seriesOptions.append("{name:\"").append(DateFunction.getDateByFormatAndOffset(endDate, 0, k)).append("\",").append("data:[");
							for (String itemName : clist.get(i).getItemList().split(",")) {
								for (RptItemConfVo itemVo : elist) {
									if(itemName.equals(itemVo.getItemCd())){
										for (int m =0; m < metedataMapList.size(); m++) {
											seriesOptions.append(metedataMapList.get(m).get(DateFunction.getDateByFormatAndOffset(endDate, 0, k).concat("item").concat(String.valueOf(itemVo.getItemSeq()))));
											if(m != metedataMapList.size()-1){
												//最后一次循环不添加逗号，删除最后一个多余逗号data:[1,2,3,
												seriesOptions.append(CommonConst.COMMA);
											}
										}
										break;
									}
								}
							}
							if(k != -6){
								seriesOptions.append("]},");
							}else{
								// 最后一次混换不添加逗号，删除最后一个多余逗号[{name:'xxxx',data:[1,2,3]},{name:'xxxx',data:[4,5,6]},
								seriesOptions.append("]}");
							}
						}
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
								.append("\"chartType\":").append("\"").append(clist.get(i).getChartType()).append("\"").append(CommonConst.COMMA)
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
	 * 创建图表配置数据(实时分小时累计交易情况)
	 * @param 报表科目配置表数据

	 * @param 报表图表配置表数据

	 * @param 图表元数据

	 * @param 日报日期
	 * @throws Throwable
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Map<String, String> getChartForRealtime(List<RptItemConfVo> elist,
			List<RptChartConfVo> clist,
			List<Map<String, Object>> metedataMapList, Object...options)
			throws Exception {
		StringBuilder charOptions = null ;
		StringBuilder titleOption = null ;
		StringBuilder yAxisOptions = null ;
		StringBuilder xCategoriesOptions = null ;
		StringBuilder seriesOptions = null ;
		Map<String,String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;
		String endDate = null;
		if(options.length > 0){
			endDate = (String) options[0];
		}
		try{
			for(int i = 0; i < clist.size(); i++){
				RptChartConfVo vo1 = clist.get(i);
				dataChartList = new ArrayList<RptChartConfVo>();
				dataChartList.add(vo1);
				clist.remove(i);
				i--;
				for(int j = i + 1; j < clist.size(); j++){
					RptChartConfVo vo2 = clist.get(j);
					if(vo1.getAplCode().equals(vo2.getAplCode()) 
							&& vo1.getReportType().equals(vo2.getReportType())
							&& vo1.getSheetName().equals(vo2.getSheetName())
							&& vo1.getChartName().equals(vo2.getChartName())
							&& vo1.getChartType().equals(vo2.getChartType())
							&& vo1.getChartSeq() == vo2.getChartSeq()){
						dataChartList.add(vo2);
						clist.remove(vo2);
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
				seriesOptions.append("[");
				for(int j = 0; j < multiChartList.size(); j++){
					String [] itemNames = multiChartList.get(j).getItemList().split(",");
					String aplCode = multiChartList.get(j).getAplCode();
					for (int k = 0; k < itemNames.length; k++) {
						String itemName = itemNames[k];
						switch(chartType){
							case 1 ://趋势图

							case 2 ://柱状图

								for(int m=0;m<elist.size();m++){
									if(elist.get(m).getItemCd().equals(itemName)){
										seriesOptions.append("{name:\"").append(elist.get(m).getItemName().replaceAll("累计", "").concat("(").concat("当日").concat(")")).append("\",").append("data:[");
									}
								}
								for (RptItemConfVo itemVo : elist) {
									if(itemName.equals(itemVo.getItemCd())){
										for (int m =0; m < metedataMapList.size(); m++) {
											if(m == 0){
												seriesOptions.append(metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(endDate)));
											}else{
												if(null != metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(endDate))){
													seriesOptions.append(NumberUtil.eval(metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(endDate)) + "-" + metedataMapList.get(m-1).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(endDate))));
												}else{
													seriesOptions.append("null");
												}
											}
											if(m != metedataMapList.size()-1){
												//最后一次循环不添加逗号，删除最后一个多余逗号data:[1,2,3,
												seriesOptions.append(CommonConst.COMMA);
											}
										}
										break;
									}
								}
								seriesOptions.append("]");
								seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
								
								//峰值日
								String peakDate = ((HoursTransVo) queryPeakDate(aplCode,itemName, endDate)).getTransDate();
								for(int m=0;m<elist.size();m++){
									if(elist.get(m).getItemCd().equals(itemName)){
										seriesOptions.append("{name:\"").append(elist.get(m).getItemName().replaceAll("累计", "").concat("(").concat("峰值日").concat(")")).append("\",").append("data:[");
										}
									}
										for (RptItemConfVo itemVo : elist) {
									if(itemName.equals(itemVo.getItemCd())){
										for (int m =0; m < metedataMapList.size(); m++) {
											if(m == 0){
												seriesOptions.append(metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(peakDate)));
											}else{
												if(null != metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(peakDate))){
													seriesOptions.append(NumberUtil.eval(metedataMapList.get(m).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(peakDate)) + "-" + metedataMapList.get(m-1).get("item".concat(String.valueOf(itemVo.getItemSeq())).concat(peakDate))));
												}else{
													seriesOptions.append("null");
												}
											}
											if(m != metedataMapList.size()-1){
												//最后一次循环不添加逗号，删除最后一个多余逗号data:[1,2,3,
												seriesOptions.append(CommonConst.COMMA);
											}
										}
										break;
									}
								}
								seriesOptions.append("]");
								seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
								break;
							case 3 ://饼图
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

	@Override
	public Map<String, String> getConfigurableXlsColumns(List<RptItemConfVo> elist, 
			Object... options) {
		String date = "";
		if(options.length > 0){
			date = (String) options[0];
		}
		
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("rows", "2");
		columns.put("hour", "小时");
		for(int i =0; i > -7 ; i--){
			for (RptItemConfVo _ricVo : elist) {
				
				if(null!=_ricVo.getItemName()&&!"小时".equals(_ricVo.getItemName())){
					columns.put(DateFunction.getDateByFormatAndOffset(date, 0, i)
													     .concat("item")
													     .concat(String.valueOf(_ricVo.getItemSeq())),
									 DateFunction.getDateByFormatAndOffset(date, 0, i)
													     .concat(CommonConst.UNDERLINE)
													     .concat(_ricVo.getItemName()));
				}
			}
		}
		return columns;
	}
	public Map<String, String> getConfigurableXlsColumns2(
			List<RptItemConfVo> elist,String endDate,String transPeakDate) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		columns.put("hour", "小时");
		for (RptItemConfVo _ricVo : elist) {
			if(null!=_ricVo.getItemName()){
				columns.put("item".concat(String.valueOf(_ricVo.getItemSeq())).concat(endDate), endDate);
				columns.put("item".concat(String.valueOf(_ricVo.getItemSeq())).concat(transPeakDate), transPeakDate.concat("峰值日"));
				
			}
		}
		columns.put("item2percent","峰值占比");
		return columns;
	
	}
	
}///:~

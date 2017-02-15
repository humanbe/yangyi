package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.math.NumberUtils;
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
import com.nantian.common.util.NumberUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.vo.MultTransVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class MultTransService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/** 日志输出 */
	final Logger logger = Logger.getLogger(MultTransService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	@Autowired
	private RptItemConfService rptItemConfService;
	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法
	 */
	public MultTransService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("transDate", FieldType.STRING);
		fields.put("sheetName", FieldType.STRING);
		fields.put("dataNum", FieldType.STRING);
		fields.put("countItem", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(MultTransVo multTransVo) {
		getSession().save(multTransVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(MultTransVo multTransVo) {
		getSession().update(multTransVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<MultTransVo> multTransVos) {
		for (MultTransVo multTransVo : multTransVos) {
			getSession().save(multTransVo);
		}
	}
	
	/**
	 * 批量保存或者更新

	 * @param multTransVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<MultTransVo> multTransVos) {
		for (MultTransVo multTransVo : multTransVos) {
			getSession().saveOrUpdate(multTransVo);
		}
	}
	
	/**
	 * 保存或者更新

	 * @param multTransVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(MultTransVo multTransVo) {
			getSession().saveOrUpdate(multTransVo);
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param aplCode 应用系统编号
	 * @param transDate 日期
	 * @param countHourTime 统计小时
	 * @param countItem 统计科目
	 * @return DateTransConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public MultTransVo findByUnionKey(String aplCode, String transDate, String countHourTime, String countItem){
		return (MultTransVo) getSession()
				.createQuery("from MultTransVo ht where ht.aplCode=:aplCode and ht.transDate=:transDate and ht.countHourTime=:countHourTime and ht.countItem=:countItem ")
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
	public void delete(MultTransVo hoursTransVo) {
		getSession().delete(hoursTransVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param aplCodes
	 * @param transDates
	 * @param sheetNames
	 * @param dateNums
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] aplCodes, String[] transDates, String[] sheetNames, String[] dateNums) {
		for(int i = 0; i < aplCodes.length; i++){
			deleteById(aplCodes[i],transDates[i],sheetNames[i],dateNums[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode, String transDate, String sheetName, String dateNum) {
		getSession().createQuery("delete from MultTransVo mt where mt.aplCode=? and mt.transDate=? and mt.sheetName=? and mt.dateNum=?")
			.setString(0, aplCode)
			.setString(1, transDate)
			.setString(2, sheetName)
			.setString(3, dateNum)
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
	public List<MultTransVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from MultTransVo mt where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and mt." + key + " like :" + key);
				} else {
					hql.append(" and mt." + key + " = :" + key);
				}
			}
		}
		hql.append(" order by mt." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
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
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> queryAll(String aplCode, String transDate,String sheetName) {
		StringBuilder sql = new StringBuilder();
		sql.append("select apl_code,trans_date,data_num, TRANSLATE (LTRIM (text, '<,>'), '*/', '*,') count_item ")
		   .append(" from (select apl_code,trans_date,ROW_NUMBER() OVER (PARTITION BY data_num order by data_num,lvl desc) rn,data_num, text")
		   .append(" from (select apl_code,trans_date,data_num, LEVEL lvl,SYS_CONNECT_BY_PATH (count_show,'<,>') text")
		   .append(" from (select apl_code,trans_date,data_num, count_show as count_show,")
		   .append(" ROW_NUMBER () OVER (PARTITION BY data_num order by data_num,count_show) x")
		   .append(" from (select distinct mt.apl_code,")
		   .append(" to_char(to_date(mt.trans_date, 'yyyymmdd'), 'yyyy-mm-dd') as trans_date,")
		   .append(" mt.data_num ,")
		   .append(" mt.count_item, ")
		   .append(" mt.count_value,")
		   .append(" mt.count_item || '<:>' || mt.count_value as count_show")
		   .append(" from mult_trans mt , rpt_item_conf r ")
		   .append(" where mt.apl_code='"+ aplCode +"' and mt.trans_date='"+ transDate + "'")
		   .append(" and mt.count_item = r.item_cd ")
		   .append(" and r.sheet_name = :sheetName ")
		   .append(" order by mt.data_num")
		   .append(" )")
		   .append(" order by data_num, count_show")
		   .append(" ) a")
		   .append(" CONNECT BY data_num = PRIOR data_num AND x - 1 = PRIOR x")
		   .append(" )")
		   .append(" )")
		   .append(" where rn = 1")
		   .append(" order by data_num");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		query.setString("sheetName", sheetName);
		return query.list();
	}
	
	/**
	 * 查询合计、均值、最大值
	 * @param aplCode
	 * @param transDate
	 * @param sheetName
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String,Object>> queryCountAll(String aplCode, String transDate,String sheetName){
		StringBuilder sql = new StringBuilder();
		sql.append("select ri.item_cd as \"countItem\",");
		sql.append(" ri.item_seq as \"itemSeq\",");
		sql.append(" max(ri.apl_code) as \"aplCode\",");
		sql.append(" max(ri.sheet_name) as \"sheetName\",");
		sql.append(" max(ri.expression) as \"expression\",");
		sql.append(" max(ri.expression_unit) as \"expressionUnit\",");
		sql.append(" sum(cast(mt.count_value as int)) as \"sumValue\",");
		sql.append(" round(avg(cast(mt.count_value as int))) as \"avgValue\",");
		sql.append(" max(cast(mt.count_value as int)) as \"maxValue\"");
		sql.append(" from rpt_item_conf ri");
		sql.append(" left join mult_trans mt on ri.apl_code = mt.apl_code");
		sql.append(" and ri.item_cd = mt.count_item");
		sql.append(" and mt.trans_date ='" +transDate+ "'");
		sql.append(" and regexp_like(mt.count_value,'^[0-9]*[.]*[0-9]*$')");
		sql.append(" where 1 = 1");
		sql.append(" and ri.apl_code = '" +aplCode+ "'");
		sql.append(" and ri.sheet_name = '" +sheetName+ "'");
		sql.append(" group by ri.item_cd, ri.item_seq");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 查询
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Long existCheck(String aplCode, String transDate, String sheetName) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) ")
			.append(" from MultTransVo mt where 1=1 ")
			.append(" and mt.aplCode  =:aplCode ")
			.append(" and mt.transDate = :transDate ")
			.append(" and mt.sheetName = :sheetName ");
		 
		Query query = getSession().createQuery(hql.toString());
		query.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setString("sheetName", sheetName);
		
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	
	/**
	 * 查询多科目饼图科目关系数据

	 * @param aplCode 系统代码
	 * @param sheetName 功能名称
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public Map<String,Object> queryMultPieRel(String aplCode, String sheetName, String itemValCol) {
		StringBuilder sql = new StringBuilder();
		sql.append(" select t.apl_code as \"aplCode\", ")
			.append(" 			t.sheet_name as \"sheetName\", ")
			.append(" 			t.item_val_col as \"itemValCol\", ")
			.append(" 			t.item_name_col as \"itemNameCol\", ")
			.append(" 			t.separate_rownum as \"separateRownum\", ")
			.append(" 			t.separate_threshold as \"separateThreshold\" ")
			.append(" from rpt_chart_conf_mult t ")
			.append(" where t.apl_code = :aplCode ")
			.append(" 		and t.sheet_name = :sheetName ")
			.append(" 		and t.item_val_col = :itemValCol ");
		 
		return (Map<String, Object>)  getSession().createSQLQuery(sql.toString())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.setString("aplCode", aplCode)
												.setString("sheetName", sheetName)
												.setString("itemValCol", itemValCol)
												.uniqueResult();
	}
	
	@Override
	public void getColumns(List<RptItemConfVo> elist, 
									ModelMap modelMap,
									Object... options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		if(elist.size() > 0){
			fieldsNames.append("[");
			columnModels.append("[new Ext.grid.RowNumberer(),");
		}
		for (RptItemConfVo rptItemConfVo : elist) {
			// 1.动态字段			// fieldsNames.append("[{name : 'tranCont2'}]");
			fieldsNames.append("{name : '").append("item").append(rptItemConfVo.getItemSeq()).append("'}")
								.append(",");
			// 2.动态列
			// columnModel.append("[new Ext.grid.RowNumberer(),{header : '对公账务总交易量',dataIndex : 'tranCont2',sortable : true}]");
			String getItemAppName = "";
			if("日期".equals(rptItemConfVo.getItemCd())){
				getItemAppName = "日期";
			}else{
				getItemAppName = rptItemConfService.getItemAppName(rptItemConfVo.getAplCode(),rptItemConfVo.getItemCd());
			}
			columnModels.append("{header : '")
								.append(getItemAppName).append("',")
								.append("dataIndex : '").append("item").append(rptItemConfVo.getItemSeq()).append("',")
								.append("sortable : true,")
								.append("width : 150")
								.append("}").append(",");
		}
		fieldsNames.append("{name : 'statisticalFlag'}").append("]");//统计值标识
		columnModels.append("{header : '统计值标识' , dataIndex : 'statisticalFlag', sortable : true, hidden : true}")	//统计值标识
			.append("]");
		if(elist.size() > 0){
			fieldsNames.deleteCharAt(fieldsNames.length()-1);
			columnModels.deleteCharAt(columnModels.length()-1);
		}
		fieldsNames.append("]");
		columnModels.append("]");
		modelMap.addAttribute("fieldsNames", fieldsNames.toString());
		modelMap.addAttribute("columnModel", columnModels.toString());
	}

	/**
	 * 通过访问多科目表动态获取数据(多科目表查询)
	 * @param itemList 报表科目配置表科目列表

	 * @param aplCode 系统编号
	 * @param endDate 日报日期
	 * @param sheetName 功能名

	 * @return
	 * @throws Throwable 
	 * @throws NumberFormatException 
	 */
	@Transactional(readOnly = true)
	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> elist,
															String sheetName, 
															String aplCode, 
															String startDate, 
															String endDate,
															Object... options) throws Exception {
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		Map<String,Object> dataMap = new HashMap<String,Object>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		
		// 存储合计值、平均值、最大值等统计值map对象
		List<Map<String,Object>> statisticalDataList  = new ArrayList<Map<String,Object>>();
		// 中间编辑对象
		LinkedHashMap<String,Map<String,Object>> statisticalKeyMap = new LinkedHashMap<String, Map<String,Object>>();
				
		// 计算式科目列表		List<RptItemConfVo> filterExpList  = new ArrayList<RptItemConfVo>();
		List<RptItemConfVo> sumExpList  = new ArrayList<RptItemConfVo>();
		//时间<:>16:45:01<,>城市名称<:>北京1<,>中继总线路数<:>30<,>峰值线路数<:>30
		String[] multDataItems = null; //存储多科目的统计科目的数据（时间<:>16:45:01 , 城市名称<:>北京1 , 中继总线路数<:>30 , 峰值线路数<:>30）		String[] multDatas = null; 	    //存储多科目的统计科目的数据（时间 , 16:45:01）
		
		try{
			List<Map<String,Object>>  multTransDatas = queryAll(aplCode,endDate,sheetName);
			for (Map<String,Object> map : multTransDatas) {
				dataMap = new HashMap<String,Object>();
				for (RptItemConfVo rptItemConfVo : elist) {
					if(null != rptItemConfVo.getExpression()){
						if(rptItemConfVo.getExpression().indexOf("SUM(") != -1){
							if(!sumExpList.contains(rptItemConfVo)){
								sumExpList.add(rptItemConfVo);
							}
						}else{
							if(!filterExpList.contains(rptItemConfVo)){
								filterExpList.add(rptItemConfVo);
							}
						}
						continue;
					}
					multDataItems = ((String)map.get("COUNT_ITEM")).split(CommonConst.MULT_TRANS_SPLIT_ITEM);
					for (String dataItem : multDataItems) {
						multDatas = dataItem.split(CommonConst.MULT_TRANS_SPLIT_DATA);
						String itemCd = rptItemConfVo.getItemCd();
						if("日期".equals(itemCd)){
							dataMap.put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), (String)map.get("TRANS_DATE"));
							break;
						}else{
							if(rptItemConfVo.getItemCd().equals(multDatas[0])){
								// 科目名.
								dataMap.put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), multDatas[0]);
								// 科目值.
								dataMap.put("item".concat(String.valueOf(rptItemConfVo.getItemSeq())), multDatas.length==CommonConst.TWO_INT?multDatas[1]:CommonConst.ZERO_INT);
								break;
							}
						}
					}
				}
				dataList.add(dataMap);
			}
			// 编辑计算式科目列表(无SUM)
			evalExpression(filterExpList,elist,dataList,endDate);
			// 编辑计算式科目列表(有SUM)
			evalSumExpression(sumExpList,elist,dataList);
			// 元数据			returnDataMap.put("metadata", dataList);
			
			// -----------------合计、均值、最大值 -------------------------begin
			// 统计所有科目的合计值、平均值、最大值及历史峰值
			if(elist.size() != 0){
				List<Map<String,Object>> statisticalList = (List<Map<String, Object>>) queryCountAll(aplCode,endDate,elist.get(0).getSheetName());
				// 合计值
				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : statisticalList) {
					if(null != map.get("sumValue")){
						dataMap.put("item".concat(map.get("itemSeq").toString()), map.get("sumValue"));
						dataMap.put("item1", "合计");
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
						dataMap.put("item1", "平均值");
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
						dataMap.put("item1", "最大值");
						//统计值标志位
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
					}
				}
				if(dataMap.size() != 0){
					statisticalKeyMap.put("最大值", dataMap);
				}
			}
			// 编辑日期科目与计算表达式科目
			List<Double> statisticalValList  = null;
			List<RptItemConfVo> filterMapList  = new ArrayList<RptItemConfVo>();
			filterMapList.addAll(filterExpList);
			filterMapList.addAll(sumExpList);
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
			// 统计值数据
			returnDataMap.put("statisticalData", statisticalDataList);
			// -----------------合计、均值、最大值 -------------------------end
			
			
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 科目计算式计算功能

	 * @param sumExpList 前期过滤后的需要计算的存在SUM求和的科目列表

	 * @param itemList 当前功能下的所有科目列表

	 * @param dataList 当前处理完成的结果数据

	 */
	private void evalSumExpression(List<RptItemConfVo> sumExpList,
			List<RptItemConfVo> itemList,
			List<Map<String,Object>> dataList) throws Exception {
		StringBuilder changeExp = new StringBuilder();
		String editExpression = null;
		String sumChangeExp = null;
		String subStr = null;
		List<Double> sumList = new ArrayList<Double>();
		for (RptItemConfVo sumItemVo : sumExpList) {
			
			changeExp.append(sumItemVo.getExpression().substring(0, sumItemVo.getExpression().indexOf("SUM(")));
			subStr = sumItemVo.getExpression().substring(sumItemVo.getExpression().indexOf("SUM(", -1) + 4);//合计)/SUM(合计)+SUM(AA)
			for (RptItemConfVo item : itemList) {
				
				if(item.getItemName().equals(subStr.substring(0, subStr.indexOf(")")))){
					for (Map<String, Object> map : dataList) {
						sumList.add(Double.valueOf(map.get("item".concat(String.valueOf(item.getItemSeq()))).toString()));
					}
					changeExp.append(NumberUtil.getSumValue(sumList));
					sumList.clear();
					break;
				}
			}
			if(subStr.indexOf(")") != (subStr.length()-1) && subStr.indexOf("SUM(") != -1){
				sumChangeExp = sumProcess(changeExp, subStr.substring(subStr.indexOf(")")+1), itemList, dataList, sumList);
			}else{
				changeExp.append(subStr.substring(subStr.indexOf(")") + 1));
				sumChangeExp = changeExp.toString();
			}
			
			// 替换表达式中的变量名为具体的数值

			boolean noDataFlag = false;
			for(Map<String,Object> dataMap : dataList){
				editExpression = sumChangeExp;
				for (RptItemConfVo itemVo : itemList) {
					if(editExpression.indexOf(itemVo.getItemName()) != -1){
						if(null == dataMap.get("item".concat(String.valueOf(itemVo.getItemSeq())))){
							editExpression = ComUtil.getMessage(itemVo.getItemName());
							noDataFlag = true;
						}else{
							editExpression = StringUtil.replaceWithEscape(editExpression, itemVo.getItemName(), dataMap.get("item".concat(String.valueOf(itemVo.getItemSeq()))).toString());
						}
					}
				}
				if(!noDataFlag){
					if(null != sumItemVo.getExpressionUnit() && !"".equals(sumItemVo.getExpressionUnit())){
						if(CommonConst.PERCENT_SYMBOL.equals(sumItemVo.getExpressionUnit())){
							// 科目名.
							dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), sumItemVo.getItemName());
							// 科目值.
							dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())), NumberUtil.format(Double.valueOf(NumberUtil.eval(editExpression)),NumberUtil.FORMAT_PATTERN_60));
						}
					}else{
						// 科目名.
						dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), sumItemVo.getItemName());
						// 科目值.
						dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())), Math.round(Double.valueOf(NumberUtil.eval(editExpression))));
					}
				}else{
					// 科目名.
					dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), sumItemVo.getItemName());
					// 科目值.
					dataMap.put("item".concat(String.valueOf(sumItemVo.getItemSeq())), editExpression);
				}
			}
			
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
	private String sumProcess(StringBuilder changeExp, 
										String subStr, 
										List<RptItemConfVo> itemList,
										List<Map<String,Object>> dataList,
										List<Double> sumList){
		///SUM(合计)+SUM(AA)
		changeExp.append(subStr.substring(0, subStr.indexOf("SUM(")));
		subStr = subStr.substring(subStr.indexOf("SUM(", -1) + 4);//合计)/SUM(合计)+SUM(AA)
		for (RptItemConfVo item : itemList) {
			if(item.getItemName().equals(subStr.substring(0, subStr.indexOf(")")))){
				for (Map<String, Object> map : dataList) {
					sumList.add(Double.valueOf(map.get("item".concat(String.valueOf(item.getItemSeq()))).toString()));
				}
				changeExp.append(NumberUtil.getSumValue(sumList));
				sumList.clear();
				break;
			}
		}
		if(subStr.indexOf(")") != (subStr.length()-1) && subStr.indexOf("SUM(") != -1){
			sumProcess(changeExp, subStr.substring(subStr.indexOf(")")+1), itemList, dataList, sumList);
		}else{
			changeExp.append(subStr.substring(subStr.indexOf(")") + 1));
		}
		return changeExp.toString();
	}
	
	/**
	 * 科目计算式计算功能
	 * @param filterMapList 前期过滤后的需要计算的科目列表
	 * @param itemList 当前功能下的所有科目列表
	 * @param dataList 当前处理完成的结果数据
	 */
	private void evalExpression(List<RptItemConfVo> filterExpList,
												List<RptItemConfVo> itemList,
												List<Map<String,Object>> dataList,
												String endDate) throws Exception {
		try{
			String editExpression;
			boolean noDataFlag = false;
			for (RptItemConfVo filterVo : filterExpList) {
				for(Map<String,Object> dataMap : dataList){
					// 计算表达式科目					noDataFlag = false;
					editExpression = filterVo.getExpression();
					// 替换表达式中的变量名为具体的数值					for (RptItemConfVo itemVo : itemList) {
						//String itemName = itemVo.getItemName().substring(itemVo.getItemName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2);
						String itemName = itemVo.getItemName();
						if(editExpression.indexOf(itemName) != -1){
							if(null == dataMap.get("item".concat(String.valueOf(itemVo.getItemSeq())))){
								if(null != itemVo.getExpression()){
									//递归处理process
									editExpression = process(editExpression,itemVo,dataMap,itemList,noDataFlag);
								}else{
									editExpression = ComUtil.getMessage(itemName);
									noDataFlag = true;
								}
							}else{
								editExpression = StringUtil.replaceWithEscape(editExpression, itemName, dataMap.get("item".concat(String.valueOf(itemVo.getItemSeq()))).toString());
							}
						}
					}
					System.out.println("editExpression="+editExpression);
					if(!noDataFlag){
						if(null != filterVo.getExpressionUnit() && !"".equals(filterVo.getExpressionUnit())){
							if(CommonConst.PERCENT_SYMBOL.equals(filterVo.getExpressionUnit())){
								// 科目名.
								dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), filterVo.getItemName());
								// 科目值.
								dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())), NumberUtil.format(Double.valueOf(NumberUtil.eval(editExpression)),NumberUtil.FORMAT_PATTERN_60));
							}
						}else{
							// 科目名.
							dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), filterVo.getItemName());
							// 科目值.
							dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())), Math.round(Double.valueOf(NumberUtil.eval(editExpression))));
						}
					}else{
						// 科目名.
						dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())).concat(CommonConst.UNDERLINE).concat("Name"), filterVo.getItemName());
						// 科目值.
						dataMap.put("item".concat(String.valueOf(filterVo.getItemSeq())), editExpression);
					}
				}
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
	private String process(String editExpression, 
										RptItemConfVo processItemVo, 
										Map<String, Object> currDataMap, 
										List<RptItemConfVo> itemList,
										boolean noDataFlag){
		//String itemName1 = processItemVo.getItemName().substring(processItemVo.getItemName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2);
		String itemName1 = processItemVo.getItemName();
		if(null != currDataMap.get("item".concat(String.valueOf(processItemVo.getItemSeq())))){
			editExpression = StringUtil.replaceWithEscape(editExpression, itemName1, currDataMap.get("item".concat(String.valueOf(processItemVo.getItemSeq()))).toString());
		}else{
			editExpression = StringUtil.replaceWithEscape(editExpression, itemName1, "(".concat(processItemVo.getExpression()).concat(")"));
			for (RptItemConfVo itemVo : itemList) {
				//String itemName2 = itemVo.getItemName().substring(itemVo.getItemName().lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2);
				String itemName2 = itemVo.getItemName();
				if(editExpression.indexOf(itemName2) != -1){
					if(null == currDataMap.get("item".concat(String.valueOf(itemVo.getItemSeq())))){
						if(null != itemVo.getExpression()){
							//递归处理process
							editExpression = process(editExpression,itemVo,currDataMap,itemList,noDataFlag);
						}else{
							editExpression = ComUtil.getMessage(itemName2);
							noDataFlag = true;
						}
					}else{
						editExpression = StringUtil.replaceWithEscape(editExpression,itemName2,currDataMap.get("item".concat(String.valueOf(itemVo.getItemSeq()))).toString());
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

	 * @throws Exception
	 */
	@Transactional(readOnly = true)
	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, Object...options)
			throws Exception {
		StringBuilder charOptions = new StringBuilder();
		StringBuilder titleOption = new StringBuilder();
		StringBuilder yAxisOptions = new StringBuilder();
		StringBuilder xCategoriesOptions = new StringBuilder();
		StringBuilder seriesOptions = new StringBuilder();
		Map<String,String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;
		Map<String,Object> multPieRel = new HashMap<String,Object>();//存储多科目饼图科目关系表
		
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
				// X轴科目信息.
				for(int m = 0; m < metedataMapList.size(); m++){
					xCategoriesOptions.append(metedataMapList.get(m).get("item1")).append(CommonConst.COMMA);
				}
				if(xCategoriesOptions.length() != 0){
					xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
				}
				// 图表统计科目信息.
				seriesOptions.append("[");
 				for(int j = 0; j < multiChartList.size(); j++){
					String [] itemNames = multiChartList.get(j).getItemList().split(",");
					for (int k = 0; k < itemNames.length; k++) {
						String itemName = itemNames[k];
						switch(chartType){
							case 1 ://趋势图

								break;
							case 2 ://柱状图

								multPieRel = queryMultPieRel(multiChartList.get(j).getAplCode(),multiChartList.get(j).getSheetName(), itemName);
								if(null != multPieRel){
									xCategoriesOptions = new StringBuilder();
									double sumValue = 0;
									String[] colNames = multPieRel.get("itemNameCol").toString().split(CommonConst.STRING_COMMA);
									Integer separateRownum = null != multPieRel.get("separateRownum")?Integer.valueOf(multPieRel.get("separateRownum").toString()):null;
									Double separateThreshold = null != multPieRel.get("separateThreshold")?Double.valueOf(multPieRel.get("separateThreshold").toString()):null;
									seriesOptions.append("{name:\"").append(multiChartList.get(j).getChartName()).append("\",").append("data:[");
									for(int m = 0; m < metedataMapList.size(); m++){
										if(null != separateThreshold){
											for (String key : metedataMapList.get(m).keySet()) {
												if(itemName.equals(metedataMapList.get(m).get(key))){
													Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
													if(Double.valueOf(String.valueOf(itemValue).replaceAll(CommonConst.PERCENT_SYMBOL, "")) >= separateThreshold){
														StringBuilder itemNamesb = new StringBuilder();
														for(int c = 0; c < colNames.length ; c++){
															for (String key2 : metedataMapList.get(m).keySet()) {
																if(colNames[c].equals(metedataMapList.get(m).get(key2))){
																	itemNamesb.append(metedataMapList.get(m).get(key2.split(CommonConst.UNDERLINE)[0]));
																	xCategoriesOptions.append(itemNamesb).append(CommonConst.COMMA);
																}
															}
															if(c != colNames.length -1){
																itemNamesb.append(CommonConst.UNDERLINE);
															}
														}
														seriesOptions.append(itemValue).append(CommonConst.COMMA);
														break;
													}
												}
											}
										}else{
											if((null == separateRownum) || (null != separateRownum && m < separateRownum)){
												for (String key : metedataMapList.get(m).keySet()) {
													if(itemName.equals(metedataMapList.get(m).get(key))){
														Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
														StringBuilder itemNamesb = new StringBuilder();
														for(int c = 0; c < colNames.length ; c++){
															for (String key2 : metedataMapList.get(m).keySet()) {
																if(colNames[c].equals(metedataMapList.get(m).get(key2))){
																	itemNamesb.append(metedataMapList.get(m).get(key2.split(CommonConst.UNDERLINE)[0]));
																	xCategoriesOptions.append(itemNamesb).append(CommonConst.COMMA);
																}
															}
															if(c != colNames.length -1){
																itemNamesb.append(CommonConst.UNDERLINE);
															}
														}
														seriesOptions.append(itemValue);
														break;
													}
												}
												if(m != metedataMapList.size()-1) seriesOptions.append(CommonConst.COMMA);
											}else{
												for (String key : metedataMapList.get(m).keySet()) {
													if(itemName.equals(metedataMapList.get(m).get(key))){
														Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
														if(itemValue != null && NumberUtils.isNumber(itemValue.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))){
															sumValue += Double.parseDouble(itemValue.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""));
															break;
														}
													}
												}
											}
										}
										if(m == metedataMapList.size()-1){
											if(null != separateRownum){
												xCategoriesOptions.append("'其他'").append(CommonConst.COMMA);
												seriesOptions.append(sumValue);
											}else if(null != separateThreshold){
												seriesOptions.deleteCharAt(seriesOptions.length() -1);
											}
										}
									}
									if(k == itemNames.length - 1){
										seriesOptions.append("]");
										seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
									}
								}
								if(xCategoriesOptions.length() != 0){
									xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
								}
								break;
							case 3 ://饼图
								boolean qitaFlag = false;
								multPieRel = queryMultPieRel(multiChartList.get(j).getAplCode(),multiChartList.get(j).getSheetName(), itemName);
								if(null != multPieRel){
									double sumValue = 0;
									String[] colNames = multPieRel.get("itemNameCol").toString().split(CommonConst.STRING_COMMA);
									Integer separateRownum = null != multPieRel.get("separateRownum")?Integer.valueOf(multPieRel.get("separateRownum").toString()):null;
									Double separateThreshold = null != multPieRel.get("separateThreshold")?Double.valueOf(multPieRel.get("separateThreshold").toString()):null;
									seriesOptions.append("{name:\"").append(multiChartList.get(j).getChartName()).append("\",").append("data:[");
									for(int m = 0; m < metedataMapList.size(); m++){
										if(null != separateThreshold){
											for (String key : metedataMapList.get(m).keySet()) {
												if(itemName.equals(metedataMapList.get(m).get(key))){
													Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
													if(Double.valueOf(String.valueOf(itemValue).replaceAll(CommonConst.PERCENT_SYMBOL, "")) >= separateThreshold){
														StringBuilder itemNamesb = new StringBuilder();
														for(int c = 0; c < colNames.length ; c++){
															for (String key2 : metedataMapList.get(m).keySet()) {
																if(colNames[c].equals(metedataMapList.get(m).get(key2))){
																	itemNamesb.append(metedataMapList.get(m).get(key2.split(CommonConst.UNDERLINE)[0]));
																}
															}
															if(c != colNames.length -1){
																itemNamesb.append(CommonConst.UNDERLINE);
															}
														}
														if(m==0){
															seriesOptions.append("{ name:'" + itemNamesb.toString() + "', sliced: true, selected: true, y:" + itemValue + "}");
														}else{
															seriesOptions.append("['" +itemNamesb.toString() + "', " + itemValue + "]");
														}
														if(m != metedataMapList.size()-1) seriesOptions.append(CommonConst.COMMA);
													}else{
														qitaFlag = true;
														sumValue += Double.parseDouble(itemValue.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""));
													}
													break;
												}
											}
										}else{
											if((null == separateRownum) || (null != separateRownum && m < separateRownum)){
												for (String key : metedataMapList.get(m).keySet()) {
													if(itemName.equals(metedataMapList.get(m).get(key))){
														Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
														StringBuilder itemNamesb = new StringBuilder();
														for(int c = 0; c < colNames.length ; c++){
															for (String key2 : metedataMapList.get(m).keySet()) {
																if(colNames[c].equals(metedataMapList.get(m).get(key2))){
																	itemNamesb.append(metedataMapList.get(m).get(key2.split(CommonConst.UNDERLINE)[0]));
																}
															}
															if(c != colNames.length -1){
																itemNamesb.append(CommonConst.UNDERLINE);
															}
														}
														if(m==0){
															seriesOptions.append("{ name:'" + itemNamesb.toString() + "', sliced: true, selected: true, y:" + itemValue + "}");
														}else{
															seriesOptions.append("['" +itemNamesb.toString() + "', " + itemValue + "]");
														}
														break;
													}
												}
												if(m != metedataMapList.size()-1) seriesOptions.append(CommonConst.COMMA);
											}else{
												qitaFlag = true;
												for (String key : metedataMapList.get(m).keySet()) {
													if(itemName.equals(metedataMapList.get(m).get(key))){
														Object itemValue = metedataMapList.get(m).get(key.split(CommonConst.UNDERLINE)[0]);
														if(itemValue != null && NumberUtils.isNumber(itemValue.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))){
															sumValue += Double.parseDouble(itemValue.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""));
															break;
														}
													}
												}
											}
										}
										if(m == metedataMapList.size()-1 && (null != separateRownum || null != separateThreshold) && qitaFlag) seriesOptions.append("['其他', " + sumValue + "]");
									}
									if(k == itemNames.length - 1){
										seriesOptions.append("]");
										seriesOptions.append(", yAxis :  "+ j + ", type : "+ multiChartList.get(j).getChartType() + "},");
									}
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

	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> elist, Object... options) {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		for (RptItemConfVo _ricVo : elist) {
			if(null!=_ricVo.getItemName()){
				columns.put("item".concat(String.valueOf(_ricVo.getItemSeq())), _ricVo.getItemName());
			}else{
			columns.put("item".concat(String.valueOf(_ricVo.getItemSeq())), _ricVo.getItemCd());
			}
		}
		return columns;
	}
	
	
}///:~

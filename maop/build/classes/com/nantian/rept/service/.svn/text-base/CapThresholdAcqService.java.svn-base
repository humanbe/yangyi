package com.nantian.rept.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.CommonConst;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.vo.CapThresholdAcqVo;

@Service
@Repository
@Transactional
public class CapThresholdAcqService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	private Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	public CapThresholdAcqService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("capacityType", FieldType.STRING);
		fields.put("thresholdType", FieldType.STRING);
		fields.put("thresholdItem", FieldType.STRING);
		fields.put("thresholdItemName", FieldType.STRING);
	}

	/**
	 * 查询应用阀值采集信息集合
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @param request
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryCapThresholdAcqList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(").append("	t.aplCode as aplCode, ")
				.append("	t.thresholdItem as thresholdItem, ")
				.append("   ri.item_app_name as thresholdItemName, ")
				.append("	t.capacityType as capacityType, ")
				.append("	t.thresholdType as thresholdType, ")
				.append("	t.busiDemand as busiDemand, ")
				.append("	t.threshold as threshold, ")
				.append("	t.thresholdDate as thresholdDate, ")
				.append("	t.thresholdFrom as thresholdFrom, ")
				.append("	t.thresholdCheckFlag as thresholdCheckFlag, ")
				.append("	t.thresholdExplain as thresholdExplain, ")
				.append("	t.additionalExplain as additionalExplain, ")
				.append("	t.thresholdCreator as thresholdCreator, ")
				.append("	t.thresholdCreated as thresholdCreated, ")
				.append("	t.thresholdModifier as thresholdModifier, ")
				.append("	t.thresholdModified as thresholdModified) ")
				.append(" from CapThresholdAcqVo t,RptItemAppVo ri where 1=1 ")
				.append(" and t.aplCode = ri.apl_code and t.thresholdItem = ri.item_cd_app ");

		for (String key : params.keySet()) {
			if (fields.get(key).equals(FieldType.STRING)) {
				if("thresholdItemName".equals(key)){
					hql.append(" and ri.item_app_name like :" + key);
				}else{
					hql.append(" and t." + key + " like :" + key);
				}
			} else {
				hql.append(" and t." + key + " = :" + key);
			}
		}

		hql.append(" order by t." + sort + " " + dir);

		Query query = getSession().createQuery(hql.toString());

		if (params.size() > 0) {
			query.setProperties(params);
		}

		request.getSession().setAttribute("capThresholdAcqList4Export",
				query.list());

		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 查询导出excel所需的应用阀值采集数据列表
	 * 
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> queryCapThresholdAcqList()
			throws JEDAException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
				.append("	a.appsysName as appsysName, ")
				.append("	(case t.capacityType when '1' then '应用类' when '2' then '系统类' when '3' then '网络类' end) as capacityType, ")
				.append("	(case t.thresholdType when '1' then '联机' when '2' then '批量' when '3' then '操作系统' when '4' then '数据库' ")
				.append("		when '5' then '中间件' when '6' then '网络层' when '7' then 'web层' when '8' then '其他' end) as thresholdType, ")
				.append("	t.thresholdItem as thresholdItem, ")
				.append("   ri.item_app_name as thresholdItemName, ")
				.append("	t.busiDemand as busiDemand, ")
				.append("	t.threshold as threshold, ")
				.append("	t.thresholdDate as thresholdDate, ")
				.append("	t.thresholdFrom as thresholdFrom, ")
				.append("	(case t.thresholdCheckFlag when '0' then '否' when '1' then '是' end) as thresholdCheckFlag, ")
				.append("	t.thresholdExplain as thresholdExplain, ")
				.append("	t.thresholdCreator as thresholdCreator, ")
				.append("	t.thresholdCreated as thresholdCreated, ")
				.append("	t.thresholdModifier as thresholdModifier, ")
				.append("	t.thresholdModified as thresholdModified, ")
				.append("	t.additionalExplain as additionalExplain) ")
				.append(" from CapThresholdAcqVo t, ViewAppInfoVo a, RptItemAppVo ri ")
				.append(" where t.aplCode = a.appsysCode ")
				.append(" and t.thresholdItem = ri.item_cd_app and t.aplCode = ri.apl_code  ")
				.append(" order by t.aplCode, t.capacityType, t.thresholdType, t.thresholdItem ");
		

		return getSession().createQuery(hql.toString()).list();
	}

	/**
	 * 查询应用阀值采集实体
	 * 
	 * 
	 * @param aplCode
	 * @param capacityType
	 * @param thresholdType
	 * @param thresholdItem
	 * @param thresholdSubItem
	 * @return
	 */
	@Transactional(readOnly = true)
	public CapThresholdAcqVo queryCapThresholdAcqInfo(String aplCode, String thresholdItem) {
		return (CapThresholdAcqVo) getSession()
				.createQuery(
						"from CapThresholdAcqVo t where t.aplCode = :aplCode and t.thresholdItem = :thresholdItem ")
				.setString("aplCode", aplCode)
				.setString("thresholdItem", thresholdItem).uniqueResult();
	}

	/**
	 * 保存
	 * 
	 * @param capThresholdAcqVo
	 */
	@Transactional
	public void save(CapThresholdAcqVo capThresholdAcqVo) {
		getSession().save(capThresholdAcqVo);

	}

	/**
	 * 更新
	 * 
	 * @param capThresholdAcqVo
	 */
	@Transactional
	public void update(CapThresholdAcqVo capThresholdAcqVo) {
		getSession().update(capThresholdAcqVo);

	}

	/**
	 * 批量删除
	 * 
	 * @param aplCodes
	 * @param capacityTypes
	 * @param thresholdTypes
	 * @param thresholdItems
	 * @param thresholdSubItems
	 */
	public void deleteByUnionKeys(String[] aplCodes, String[] thresholdItems) {
		for (int i = 0; i < aplCodes.length && i < thresholdItems.length ; i++) {
			deleteByUnionKey(aplCodes[i], thresholdItems[i]);
		}

	}

	/**
	 * 删除
	 * 
	 * @param aplCode
	 * @param capacityType
	 * @param thresholdType
	 * @param thresholdItem
	 * @param thresholdSubItem
	 */
	@Transactional
	private void deleteByUnionKey(String aplCode, String thresholdItem) {
		getSession()
				.createQuery(
						"delete from CapThresholdAcqVo t where t.aplCode = :aplCode and t.thresholdItem = :thresholdItem ")
				.setString("aplCode", aplCode)
				.setString("thresholdItem", thresholdItem)
				.executeUpdate();

	}

	/**
	 * 查询数据—获取科目阀值
	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryCapacityThreshold(String aplCode, String reportType,
			String sheetName, String endDate) {
		StringBuilder sql = new StringBuilder();
		sql.append(" select t.apl_code  as \"aplCode\", ")
				.append(" 			t.report_type as \"reportType\", ")
				.append(" 			t.sheet_seq   as \"sheetSeq\", ")
				.append(" 			t.sheet_name         as \"sheetName\", ")
				.append(" 			t.item_seq           as \"itemSeq\", ")
				.append(" 			t.item_cd          as \"itemName\", ")
				.append(" 			t.expression         as \"expression\", ")
				.append(" 			t.expression_unit    as \"expressionUnit\", ")
				.append(" 			t.group_parent       as \"groupParent\", ")
				.append(" 			c.threshold          as \"threshold\", ")
				.append(" 			c.threshold_date     as \"thresholdDate\", ")
				.append(" 			c.exceed_threshold_percent as \"exceedThresholdPercent\" ")
				.append(" from rpt_item_conf t, cap_threshold_chk_result c ")
				.append(" where case when instr(c.apl_code, '-') != 0 then substr(c.apl_code, 0, instr(c.apl_code, '-') - 1) else c.apl_code end = t.apl_code ")
				.append(" 		and ( t.item_cd = c.item_cd_app)  ")
				.append(" 		and t.apl_code = :aplCode ")
				.append(" 		and t.report_type = :reportType ")
				.append(" 		and t.sheet_name = :sheetName ")
				.append("       and c.datetime like :endDate ");

		Query query = getSession().createSQLQuery(sql.toString());
		query.setString("aplCode", aplCode).setString("reportType", reportType)
				.setString("sheetName", sheetName)
				.setString("endDate", endDate + "%")
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

	/**
	 * 统计容量阀值
	 * 
	 * 
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public void statisticalCapacityThreshold(String aplCode, String reportType,
			String sheetName,
			Map<String, Map<String, Object>> statisticalKeyMap,
			List<Map<String, Object>> dataList, String endDate) throws Exception {
		List<Map<String, Object>> capacityThresholdList = (List<Map<String, Object>>) queryCapacityThreshold(
				aplCode, reportType, sheetName, endDate);
		Map<String, Object> dataMap = new HashMap<String, Object>();
//		StringBuilder peakExpression = new StringBuilder();
		try {
			switch (ReptConstants.sheetNameItem.getSheetNameItem(sheetName
					.split(CommonConst.LEFT_SMALL_BRACKETS)[0])) {
			case 最近31天日交易情况:
				// 容量阀值

				for (Map<String, Object> map : capacityThresholdList) {
					if (null != map.get("threshold")) {
						dataMap.put(
								"item".concat(map.get("itemSeq").toString()),
								map.get("threshold"));// 阀值

						dataMap.put("statisticalFlag",
								CommonConst.STATISTICAL_FLAG);// 统计值标志位
					}
				}
				if (dataMap.size() != 0) {
					statisticalKeyMap.put("容量阀值", dataMap);
				}
				// 最后一次交易量与容量阀值占比

				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : capacityThresholdList) {
					if (null != map.get("threshold")) {
						dataMap.put("statisticalFlag",
								CommonConst.STATISTICAL_FLAG);// 统计值标志位
						// 阀值占比

						/*
						 * if(dataList.get(0).get("item".concat(String.valueOf(map
						 * .get("itemSeq")))).toString().contains(CommonConst.
						 * PERCENT_SYMBOL)){
						 * peakExpression.append(StringUtil.replaceWithEscape
						 * (dataList
						 * .get(0).get("item".concat(String.valueOf(map.
						 * get("itemSeq")))).toString(),
						 * CommonConst.PERCENT_SYMBOL, "")) .append("/")
						 * .append(map.get("threshold")); }else{
						 * peakExpression.append
						 * (dataList.get(0).get("item".concat
						 * (String.valueOf(map.get("itemSeq"))))) .append("/")
						 * .append(map.get("threshold")); }
						 */
						dataMap.put(
								"item".concat(map.get("itemSeq").toString()),
								map.get("exceedThresholdPercent").toString());
						// peakExpression.delete(0, peakExpression.length());
					}
				}
				if (dataMap.size() != 0) {
					statisticalKeyMap.put("超阀值比例", dataMap);
				}
				break;
			case 最近31天分钟和秒交易情况:
				// 容量阀值
				for (Map<String, Object> map : capacityThresholdList) {
					if (null != map.get("threshold")) {
						dataMap.put(
								ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
										.concat("item").concat(
												map.get("itemSeq").toString()),
								map.get("threshold"));// 阀值

						dataMap.put("statisticalFlag",
								CommonConst.STATISTICAL_FLAG);// 统计值标志位
					}
				}
				if (dataMap.size() != 0) {
					statisticalKeyMap.put("容量阀值", dataMap);
				}
				// 最后一次交易量与容量阀值占比

				dataMap = new HashMap<String, Object>();
				for (Map<String, Object> map : capacityThresholdList) {
					if (null != map.get("threshold")) {
						dataMap.put("statisticalFlag",
								CommonConst.STATISTICAL_FLAG);// 统计值标志位
						// 阀值占比
						/*
						 * if(dataList.get(0).get(ReptConstants.
						 * DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
						 * .concat("item").concat
						 * (String.valueOf(map.get("itemSeq"
						 * )))).toString().contains
						 * (CommonConst.PERCENT_SYMBOL)){
						 * peakExpression.append(StringUtil
						 * .replaceWithEscape(dataList
						 * .get(0).get("item".concat(String
						 * .valueOf(map.get("itemSeq")))).toString(),
						 * CommonConst.PERCENT_SYMBOL, "")) .append("/")
						 * .append(map.get("threshold")); }else{
						 * peakExpression.append
						 * (dataList.get(0).get(ReptConstants
						 * .DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
						 * .concat("item").concat
						 * (String.valueOf(map.get("itemSeq"))))) .append("/")
						 * .append(map.get("threshold")); }
						 */
						dataMap.put(
								ReptConstants.DEFAULT_COLUMN_HEADER_KEY_TIMESTRANS
										.concat("item").concat(
												map.get("itemSeq").toString()),
								map.get("exceedThresholdPercent").toString());
						// peakExpression.delete(0, peakExpression.length());
					}
				}
				if (dataMap.size() != 0) {
					statisticalKeyMap.put("超阀值比例", dataMap);
				}
				break;
			}

		} catch (Exception ex) {
			ex.printStackTrace();
			throw ex;
		}
	}

}

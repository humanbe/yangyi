package com.nantian.rept.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
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

import com.nantian.common.util.CommonConst;
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class RptItemConfService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptItemConfService.class);

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
	public RptItemConfService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("reportType", FieldType.STRING);
		fields.put("sheetName", FieldType.STRING);
		fields.put("sheetSeq", FieldType.INTEGER);
		fields.put("itemCd", FieldType.STRING);
		fields.put("itemSeq", FieldType.INTEGER);
		fields.put("expression", FieldType.STRING);
		fields.put("expressionUnit", FieldType.STRING);
		fields.put("itemName", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(RptItemConfVo rptItemConfVo) {
		getSession().save(rptItemConfVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(RptItemConfVo rptItemConfVo) {
		getSession().update(rptItemConfVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<RptItemConfVo> rptItemConfVos) {
		for (RptItemConfVo rptItemConfVo : rptItemConfVos) {
			getSession().save(rptItemConfVo);
		}
	}
	
	/**
	 * 批量保存或者更新

	 * @param rptItemConfVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<RptItemConfVo> rptItemConfVos) {
		for (RptItemConfVo rptItemConfVo : rptItemConfVos) {
			getSession().saveOrUpdate(rptItemConfVo);
		}
	}
	
	/**
	 * 获取科目级别------------------------(无用)
	 */
	@SuppressWarnings("rawtypes")
	@Transactional(readOnly = true)
	public List getCountItemLevelType(String appsys_code,String one,String two,String three)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" e.COUNT_ITEM_LEVEL_TYPE as \"COUNT_ITEM_LEVEL_TYPE\"");
		sql.append("  from  RPT_ITEM_APP e where  e.APL_CODE = '"+appsys_code+"' and e.ITEM_CD_LVL1='"+one+"'");
		sql.append(" and e.ITEM_CD_LVL2='"+two+"' and e.ITEM_CD_APP='"+three+"'");
		Query query = getSession().createSQLQuery(sql.toString());
		return query.list();
	}
	/**
	 * 保存或者更新

	 * @param rptItemConfVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(RptItemConfVo rptItemConfVo) {
			getSession().saveOrUpdate(rptItemConfVo);
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param aplCode 应用系统编号
	 * @param reportType 报表类型
	 * @param sheetName 日报SHEET名

	 * @param itemCd 科目名

	 * @return RptItemConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public RptItemConfVo findByUnionKey(String aplCode, String reportType, String sheetName, String itemCd){
		return (RptItemConfVo) getSession()
				.createQuery("from RptItemConfVo rt where rt.aplCode=:aplCode and rt.reportType=:reportType and rt.sheetName=:sheetName and rt.itemCd=:itemCd ")
				.setString("aplCode", aplCode)
				.setString("reportType", reportType)
				.setString("she etName", sheetName)
				.setString("itemCd", itemCd)
				.uniqueResult();
	}
	
	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(RptItemConfVo rptItemConfVo) {
		getSession().delete(rptItemConfVo);
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
	private void deleteById(String aplCode, String reportType, String sheetName, String itemCd) {
		getSession().createQuery("delete from RptItemConfVo rt where rt.aplCode=? and rt.reportType=? and rt.sheetName=? and rt.itemCd=?")
			.setString(0, aplCode)
			.setString(1, reportType)
			.setString(2, sheetName)
			.setString(3, itemCd)
			.executeUpdate();
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	@Transactional("maoprpt")
	public void deleteById(String aplCode, String reportType, String sheetName) {
		getSession().createQuery("delete from RptItemConfVo rt where rt.aplCode=? and rt.reportType=? and rt.sheetName=?")
			.setString(0, aplCode)
			.setString(1, reportType)
			.setString(2, sheetName)
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
	public List<RptItemConfVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from RptItemConfVo rt where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rt." + key + " like :" + key);
				} else {
					hql.append(" and rt." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by rt." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询科目配置表数据(按科目序号排序，解决导出时列排序问题)
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptItemConfVo> queryRptItemConfList(String aplCode, String reportType, String sheetName) {

		StringBuilder sql = new StringBuilder();
		sql.append(" select distinct a.apl_code, a.report_type,  ");
			sql.append(" a.sheet_name, a.item_cd,  ");
			sql.append(" b.item_app_name,  a.item_seq, ");
			sql.append(" a.expression, a.expression_unit, ");
			sql.append(" a.group_parent,  a.sheet_seq");
			
			sql.append(" from rpt_item_conf a left join rpt_item_app b");
			sql.append(" on a.item_cd=b.item_cd_app and a.apl_code=b.apl_code ");
			if(null != aplCode)sql.append(" where a.apl_code= :aplCode ");
			if(null != reportType)sql.append(" and a.report_type = :reportType  ");
			if(null != sheetName)sql.append(" and a.sheet_name = :sheetName  ");
		    sql.append(" order by a.apl_code, a.report_type, a.sheet_seq, a.sheet_name, a.item_seq ");
		 
		Query query = getSession().createSQLQuery(sql.toString());
		if(null != aplCode)query.setString("aplCode", aplCode);
		if(null != reportType)query.setString("reportType", reportType);
		if(null != sheetName)query.setString("sheetName", sheetName);
		query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list = query.list();
		List<RptItemConfVo> voList= new ArrayList<RptItemConfVo>();
		for(int i=0; i<list.size(); i++ ){
			RptItemConfVo vo =new RptItemConfVo();
			vo.setAplCode(list.get(i).get("APL_CODE"));
		//	Object countItemLevelType = list.get(i).get("COUNT_ITEM_LEVEL_TYPE");
		//	vo.setCountItemLevelType(Integer.parseInt(countItemLevelType.toString()));
			vo.setExpression(list.get(i).get("EXPRESSION"));
			vo.setExpressionUnit(list.get(i).get("EXPRESSION_UNIT"));
			vo.setGroupParent(list.get(i).get("GROUP_PARENT"));
			vo.setItemCd(list.get(i).get("ITEM_CD"));
			vo.setItemName(list.get(i).get("ITEM_APP_NAME"));
			Object itemSeq = list.get(i).get("ITEM_SEQ");
			vo.setItemSeq(Integer.parseInt(itemSeq.toString()));
			Object ReportType = list.get(i).get("REPORT_TYPE");
			vo.setReportType(ReportType.toString());
			vo.setSheetName(list.get(i).get("SHEET_NAME"));
			Object sheetSeq = list.get(i).get("SHEET_SEQ");
			if(sheetSeq!=null){
				vo.setSheetSeq(Integer.parseInt(sheetSeq.toString()));
			}
			voList.add(vo);
		}
		return voList;
	}
	
	
	/**
	 * 查询科目配置表数据(按科目序号排序，解决导出时列排序问题)
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptItemConfVo> queryRptItemConf(String aplCode, String reportType, String sheetName) {

		StringBuilder sql = new StringBuilder();
		sql.append(" select distinct a.apl_code, a.report_type,  ");
			sql.append(" a.sheet_name, a.item_cd,  ");
			sql.append(" b.item_app_name,  a.item_seq, ");
			sql.append(" a.expression, a.expression_unit, ");
			sql.append(" a.group_parent,  a.sheet_seq");
			
			sql.append(" from rpt_item_conf a left join rpt_item_app b");
			sql.append(" on a.item_cd=b.item_cd_app and a.apl_code=b.apl_code ");
			if(null != aplCode)sql.append(" where a.apl_code= :aplCode ");
			if(null != reportType)sql.append(" and a.report_type = :reportType  ");
			if(null != sheetName)sql.append(" and a.sheet_name = :sheetName  ");
		    sql.append(" order by a.apl_code, a.report_type, a.sheet_seq, a.sheet_name, a.item_seq ");
		 
		Query query = getSession().createSQLQuery(sql.toString());
		if(null != aplCode)query.setString("aplCode", aplCode);
		if(null != reportType)query.setString("reportType", reportType);
		if(null != sheetName)query.setString("sheetName", sheetName);
		query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list = query.list();
		List<RptItemConfVo> voList= new ArrayList<RptItemConfVo>();
		for(int i=0; i<list.size(); i++ ){
			RptItemConfVo vo =new RptItemConfVo();
			vo.setAplCode(list.get(i).get("APL_CODE"));
			vo.setExpression(list.get(i).get("EXPRESSION"));
			vo.setExpressionUnit(list.get(i).get("EXPRESSION_UNIT"));
			vo.setGroupParent(list.get(i).get("GROUP_PARENT"));
			vo.setItemCd(list.get(i).get("ITEM_CD"));
			if(null==list.get(i).get("ITEM_APP_NAME")){
				vo.setItemName(list.get(i).get("ITEM_CD"));
			}else{
				vo.setItemName(list.get(i).get("ITEM_APP_NAME"));
			}
			
			Object itemSeq = list.get(i).get("ITEM_SEQ");
			vo.setItemSeq(Integer.parseInt(itemSeq.toString()));
			Object ReportType = list.get(i).get("REPORT_TYPE");
			vo.setReportType(ReportType.toString());
			vo.setSheetName(list.get(i).get("SHEET_NAME"));
			Object sheetSeq = list.get(i).get("SHEET_SEQ");
			if(sheetSeq!=null){
				vo.setSheetSeq(Integer.parseInt(sheetSeq.toString()));
			}
			voList.add(vo);
		}
		return voList;
	}
	
	
	/**
	 * 编辑 查询科目配置表数据(按科目序号排序，解决导出时列排序问题)
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> queryRptItemConfList2(String aplCode, String reportType, String sheetName) {


		StringBuilder sql = new StringBuilder();
		sql.append(" select distinct a.apl_code, a.report_type,  ");
			sql.append(" a.sheet_name, a.item_cd,  ");
			sql.append(" b.item_app_name,  a.item_seq, ");
			sql.append(" a.expression, a.expression_unit, ");
			sql.append(" a.group_parent,  a.sheet_seq, ");
			sql.append(" b.item_cd_lvl1,b.item_cd_lvl2 ");
			sql.append(" from rpt_item_conf a left join rpt_item_app b ");
			sql.append(" on a.item_cd=b.item_cd_app and a.apl_code = b.apl_code ");
			if(null != aplCode)sql.append(" where a.apl_code= :aplCode ");
			if(null != reportType)sql.append(" and a.report_type = :reportType  ");
			if(null != sheetName)sql.append(" and a.sheet_name = :sheetName  ");
		    sql.append(" order by a.apl_code, a.report_type, a.sheet_seq, a.sheet_name, a.item_seq ");
		 
		Query query = getSession().createSQLQuery(sql.toString());
		if(null != aplCode)query.setString("aplCode", aplCode);
		if(null != reportType)query.setString("reportType", reportType);
		if(null != sheetName)query.setString("sheetName", sheetName);
		query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,Object>> list = query.list();
		
		return list;
	}
	
	/**
	 * 获取科目名称
	 * @param lvl      级别 1  2
	 * @param itemCd   科目编码
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public String getItemName( String lvl, String item_cd_lvl1,String item_cd_lvl2) {


		StringBuilder sql = new StringBuilder();
		sql.append(" select distinct  ");
			sql.append("  rb.item_name  ");
			sql.append(" from rpt_item_base  rb ");
			sql.append(" where rb.item_cd = :item_cd_lvl1  ");
			if(lvl.equals("1")){
				sql.append(" and rb.parent_item_cd = 'NULL'  ");
			}else{
				sql.append(" and rb.parent_item_cd = :item_cd_lvl2  ");
			}
		 
		Query query = getSession().createSQLQuery(sql.toString());
	    query.setString("item_cd_lvl1", item_cd_lvl1);
	    if(!lvl.equals("1"))query.setString("item_cd_lvl2", item_cd_lvl2);
		
	String  item_name=(String) query.uniqueResult();
	if(null==item_name||item_name.equals("")){
		if(!lvl.equals("1")){
			item_name=item_cd_lvl2;
		}else{
			item_name=item_cd_lvl1;
		}
	}else{
		
		
	}
	return item_name;
	
	}
	
	
	/**
	 * 查询科目配置表数据(按科目名称程度降序排列，解决计算表达式替换科目值时科目1名称包含科目2名称的情况)
	 * @param aplCode
	 * @param reportType
	 * @param sheetName
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptItemConfVo> queryRptItemConfListForEval(String aplCode, String reportType, String sheetName) {
		StringBuilder sql = new StringBuilder();
		sql.append(" select distinct a.apl_code, a.report_type,  ");
			sql.append(" a.sheet_name, a.item_cd,  ");
			sql.append(" b.item_app_name,  a.item_seq, ");
			sql.append(" a.expression, a.expression_unit, ");
			sql.append(" a.group_parent,  a.sheet_seq");
			
			sql.append(" from rpt_item_conf a left join rpt_item_app b");
			sql.append(" on a.item_cd=b.item_cd_app and a.apl_code=b.apl_code ");
			if(null != aplCode)sql.append(" where a.apl_code= :aplCode ");
			if(null != reportType)sql.append(" and a.report_type = :reportType  ");
			if(null != sheetName)sql.append(" and a.sheet_name = :sheetName  ");
		    sql.append(" order by a.apl_code, a.report_type, a.sheet_seq, a.sheet_name, a.item_seq ,");
		    sql.append(" case when a.item_seq = '1' then 999 else length(a.item_cd) end desc");
		Query query = getSession().createSQLQuery(sql.toString());
		if(null != aplCode)query.setString("aplCode", aplCode);
		if(null != reportType)query.setString("reportType", reportType);
		if(null != sheetName)query.setString("sheetName", sheetName);
		query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list = query.list();
		List<RptItemConfVo> voList= new ArrayList<RptItemConfVo>();
		for(int i=0; i<list.size(); i++ ){
			RptItemConfVo vo =new RptItemConfVo();
			vo.setAplCode(list.get(i).get("APL_CODE"));
		//	Object countItemLevelType = list.get(i).get("COUNT_ITEM_LEVEL_TYPE");
		//	vo.setCountItemLevelType(Integer.parseInt(countItemLevelType.toString()));
			vo.setExpression(list.get(i).get("EXPRESSION"));
			vo.setExpressionUnit(list.get(i).get("EXPRESSION_UNIT"));
			vo.setGroupParent(list.get(i).get("GROUP_PARENT"));
			vo.setItemCd(list.get(i).get("ITEM_CD"));
			vo.setItemName(list.get(i).get("ITEM_APP_NAME"));
			Object itemSeq = list.get(i).get("ITEM_SEQ");
			vo.setItemSeq(Integer.parseInt(itemSeq.toString()));
			Object ReportType = list.get(i).get("REPORT_TYPE");
			vo.setReportType(ReportType.toString());
			vo.setSheetName(list.get(i).get("SHEET_NAME"));
			Object sheetSeq = list.get(i).get("SHEET_SEQ");
			if(sheetSeq!=null){
				vo.setSheetSeq(Integer.parseInt(sheetSeq.toString()));
			}
			voList.add(vo);
		}
		return voList;
	}
	

	/**
	 * 查询功能列表
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> querySheetNames(String aplCode, String reportType) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.aplCode as aplCode,")
			.append(" rt.reportType as reportType,")
			.append(" rt.sheetName as valueField,")
			.append(" rt.sheetName as displayField,")
			.append(" rt.sheetName as sheetName,")
			.append(" rt.sheetSeq as sheetSeq,")
			//.append(" ra.item_cd_lvl1 as item_cd_lvl1,")
			//.append(" ra.item_cd_lvl2 as item_cd_lvl2,")
			.append(" a.systemname as aplAllName) ")
			.append(" from RptItemConfVo rt, ViewAppInfoVo a" )
			.append(" where rt.aplCode = a.appsysCode ");

		if(null != aplCode) hql.append(" and rt.aplCode = :aplCode ");
		if(null != reportType) hql.append(" and rt.reportType = :reportType ");

		 hql.append(" order by rt.aplCode, rt.reportType, rt.sheetSeq, case when rt.sheetName ='")
		 		.append(ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY)
		 		.append("' then '0'  else  rt.sheetName end ");
		 
		Query query = getSession().createQuery(hql.toString());
		if(null != aplCode) query.setString("aplCode", aplCode);
		if(null != reportType) query.setString("reportType", reportType);
		
		return query.list();
	}
	
	
	/**
	 * 查询日报管理树形菜单
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> queryTreeObj(String aplCode, String reportType) {

		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append(" rt.aplCode as aplCode,")
			.append(" rt.reportType as reportType,")
			.append(" rt.sheetSeq as sheetSeq,")
			.append(" rt.sheetName as text,")
			.append(" 'node-leaf' as iconCls,")
			.append(" 'true' as leaf) ")
			.append("from RptItemConfVo rt where 1=1 ");
		if(null != aplCode) hql.append(" and rt.aplCode = :aplCode ");
		if(null != reportType) hql.append(" and rt.reportType = :reportType ");
		hql.append(" order by rt.sheetSeq, rt.sheetName ");
		 
		Query query = getSession().createQuery(hql.toString());
		if(null != aplCode) query.setString("aplCode", aplCode);
		if(null != reportType) query.setString("reportType", reportType);
		
		return query.list();
	}
	
	
	/**
	 * 查询日报功能名称
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> querySheetNames2(String aplCode, String reportType) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.sheetName as valueField,")
			.append(" rt.sheetName as displayField )")
			.append(" from RptItemConfVo rt" )
			.append("  where  rt.aplCode = :aplCode ");
		if(null != reportType) hql.append(" and rt.reportType = :reportType ");
		 
		Query query = getSession().createQuery(hql.toString());
		if(null != aplCode) query.setString("aplCode", aplCode);
		if(null != reportType) query.setString("reportType", reportType);
		
		return query.list();
	}
	
	/**
	 * 查询ItemAppName
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public String getItemAppName(String aplCode, String itemCdApp) {

		StringBuilder sql = new StringBuilder();
		sql.append("select item_app_name from rpt_item_app where apl_code='"+aplCode+"' AND item_cd_app='"+itemCdApp+"'");
		Query query = getSession().createSQLQuery(sql.toString());
		String  itemAppName=(String) query.uniqueResult();
		
		return itemAppName;
	}
	
	/**
	 * 查询ItemAppName
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public String getItemCdApp(String aplCode, String itemAppName) {

		StringBuilder sql = new StringBuilder();
		sql.append("select item_cd_app from rpt_item_app where apl_code='"+aplCode+"' AND item_app_name='"+itemAppName+"'");
		Query query = getSession().createSQLQuery(sql.toString());
		String  itemCdApp=(String) query.uniqueResult();
		
		return itemCdApp;
	}
	
	/**
	 * 查询weblogic数据
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> WeblogicDataList(String aplCode, String reportType,String sheetName) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.aplCode as aplCode,")
			
			.append(" rt.sheetName as sheetName,")
			.append(" rt.sheetSeq as sheetSeq,")
			.append(" rt.itemCd as itemCd,")
			.append(" rt.groupParent as groupParent,")
			.append(" rt.itemSeq as itemSeq,")
			
			.append(" rt.reportType as reportType )")
			.append(" from RptItemConfVo rt" )
			.append("  where  rt.aplCode = :aplCode ");
		 hql.append(" and rt.reportType = :reportType ");
		 hql.append(" and rt.sheetName = :sheetName ");
		 
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
		 query.setString("reportType", reportType);
		 query.setString("sheetName", sheetName);
		
		return query.list();
	}
	
	
	/**
	 * 查询weblogic  一级 二级
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> WeblogicDataLVL(String aplCode,String itemcd) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.item_app_name as item_app_name,")
			.append(" rt.apl_code as apl_code,")
			.append(" rt.item_cd_lvl1 as item_cd_lvl1,")
			.append(" rt.item_cd_lvl2 as item_cd_lvl2 )")
			.append(" from RptItemAppVo rt" )
			.append("  where  rt.apl_code = :aplCode ");
		 hql.append(" and rt.item_cd_app = :itemcd ");
		 
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
		 query.setString("itemcd", itemcd);
		
		return query.list();
	}
	
	/**
	 * 查询weblogic  一级 二级
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,String>> getItemMap(String aplCode) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.item_app_name as item_app_name,")
			.append(" rt.item_cd_app as item_cd_app ) ")
			
			.append(" from RptItemAppVo rt" )
			.append("  where  rt.apl_code = :aplCode ");
		 
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
		
		return query.list();
	}
	
}///:~

package com.nantian.rept.service;

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

import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.vo.AplAnalyzeVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class AplAnalyzeService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(AplAnalyzeService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法	 */
	public AplAnalyzeService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("transDate", FieldType.STRING);
		fields.put("anaItem", FieldType.STRING);
		fields.put("exeAnaDesc", FieldType.STRING);
		fields.put("status", FieldType.STRING);
		fields.put("anaUser", FieldType.STRING);
		fields.put("revUser", FieldType.STRING);
		fields.put("endDate", FieldType.STRING);
		fields.put("filePath", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(AplAnalyzeVo aplAnalyzeVo) {
		getSession().save(aplAnalyzeVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(AplAnalyzeVo aplAnalyzeVo) {
		getSession().update(aplAnalyzeVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<AplAnalyzeVo> aplAnalyzeVos) {
		for (AplAnalyzeVo aplAnalyzeVo : aplAnalyzeVos) {
			getSession().save(aplAnalyzeVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param aplAnalyzeVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<AplAnalyzeVo> aplAnalyzeVos) {
		for (AplAnalyzeVo aplAnalyzeVo : aplAnalyzeVos) {
			getSession().saveOrUpdate(aplAnalyzeVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param aplAnalyzeVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(AplAnalyzeVo aplAnalyzeVo) {
			getSession().saveOrUpdate(aplAnalyzeVo);
	}

	/**
	 * 通过主键查找唯一的一条记录
	 * @param aplCode 应用系统编号
	 * @param transDate 交易日期
	 * @param anaItem 分析科目
	 * @return ServerConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public AplAnalyzeVo findByPrimaryKey(String aplCode,String transDate,String transTime,String anaItem){
		return (AplAnalyzeVo) getSession()
				.createQuery("from AplAnalyzeVo a where a.aplCode=:aplCode and a.transDate=:transDate and a.transTime=:transTime and a.anaItem=:anaItem  ")
				.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setString("transTime", transTime)
				.setString("anaItem", anaItem)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(AplAnalyzeVo aplAnalyzeVo) {
		getSession().delete(aplAnalyzeVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param aplCodes
	 * @param transDates
	 * @param anaItems
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] aplCodes,String[] transDates,String[] anaItems) {
		for(int i = 0; i < aplCodes.length; i++){
			deleteById(aplCodes[i],transDates[i],anaItems[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode,String transDate,String anaItem) {
		getSession().createQuery("delete from AplAnalyzeVo a where a.aplCode=? and a.transDate=? and a.anaItem=? ")
				.setString(0, aplCode)
				.setString(1, transDate)
				.setString(2, anaItem)
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
	public List<AplAnalyzeVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from AplAnalyzeVo a where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and a." + key + " like :" + key);
					} else {
						hql.append(" and a." + key + " = :" + key);
					}
			}
		}
		hql.append(" order by a." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询应用系统运行分析科目列表（在科目配置表存在但在分析表中不存在的）
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object querySheetNmMapForAplAnalyze(String aplCode, String transDate){
		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct ")
			.append(" r.sheet_Name as \"valueField\", ")
			.append(" r.sheet_Name as \"displayField\" ")
			.append(" from rpt_item_conf r ")
			.append(" where not exists( ")
			.append(" select a.ana_item from apl_analyze a ")
			.append(" where r.sheet_name = a.ana_item ")
			.append(" and r.apl_code = a.apl_code ")
			.append(" and a.apl_code = :aplCode ")
			.append(" and a.trans_date = :transDate) ")
			.append(" and r.apl_code = :aplCode ")
			.append(" and r.report_Type = '1' ")
			.append(" order by r.sheet_Name ");
		
		return getSession().createSQLQuery(hql.toString())
				.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询应用系统运行分析科目列表(科目配置表与运行分析表汇总结果)
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object querySheetNmMapSumItems(String aplCode, String reportType,String endDate,String filterSheetName){
		StringBuilder hql = new StringBuilder();
		hql.append(" select  to_char(to_date('").append(endDate).append("','YYYYMMDD'),'YYYYMMDD') as \"rptDate\", ")
			.append(" 			o.apl_code as \"aplCode\", ")
			.append(" 			o.sheet_name as \"sheetName\", ")
			.append(" 			o.sheet_seq as \"sheetSeq\", ")
			.append("          to_char(to_date(t.trans_date,'YYYYMMDD'),'YYYYMMDD') as \"transDate\", ")
			.append(" 			t.ana_item as \"anaItem\", ")
			.append(" 			t.exe_ana_desc as \"exeAnaDesc\", ")
			.append(" 			t.status as \"status\", ")
			.append(" 			t.ana_user as \"anaUser\", ")
			.append(" 			t.rev_user as \"revUser\", ")
			.append("          to_char(to_date(t.end_date,'YYYYMMDD'),'YYYYMMDD') as \"endDate\", ")
			.append(" 			t.file_path as \"filePath\" ")
			.append(" from (select distinct r.apl_code, ")
			.append(" 					r.report_type, ")
			.append(" 					r.sheet_name, ")
			.append(" 					r.sheet_seq ")
			.append(" 			from rpt_item_conf r ")
			.append(" 			where r.apl_code = :aplCode ")
			.append(" 			and r.report_type = :reportType ")
			.append(" 			and r.sheet_name != :filterSheetName ) o ")
			.append(" left join apl_analyze t ")
			.append(" on t.apl_code = o.apl_code ")
			.append(" and t.ana_item = o.sheet_name ")
			.append(" and t.apl_code = :aplCode ")
			.append(" and t.trans_date = :endDate ")
			.append(" 	order by o.report_type, o.sheet_seq, case when o.sheet_name ='").append(ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY)
			.append("' then '0'  else  o.sheet_name end ");
		
		return getSession().createSQLQuery(hql.toString())
				.setString("aplCode", aplCode)
				.setString("reportType", reportType)
				.setString("endDate", endDate)
				.setString("filterSheetName", filterSheetName)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 通过查询最新的历史变更实例来返回常用属性的实例
	 * @param aplCode
	 * @return
	 */
	@Transactional(readOnly = true, value = "maoprpt")
	public Object queryLatestInfo(String aplCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("  to_char(to_date(t.transDate,'YYYYMMDD'),'YYYYMMDD') as transDate, ")
			.append("	t.anaItem as anaItem, ")
			.append("	t.exeAnaDesc as exeAnaDesc, ")
			.append("	t.status as status, ")
			.append("	t.anaUser as anaUser, ")
			.append("	t.revUser as revUser, ")
			.append("  to_char(to_date(t.endDate,'YYYYMMDD'),'YYYYMMDD') as endDate, ")
			.append("	t.filePath as filePath) ")
			.append(" from AplAnalyzeVo t ")
			.append(" where t.aplCode = :aplCode ")
			.append(" and to_date(t.transDate, 'YYYYMMDD') = ")
			.append("		(select max(to_date(ta.transDate, 'YYYYMMDD')) ")
			.append("		 	from AplAnalyzeVo ta where ta.aplCode = t.aplCode) ")
			.append(" order by t.anaItem ");
		return getSession().createQuery(hql.toString()).setString("aplCode", aplCode).list();
	}
	
	
}///:~

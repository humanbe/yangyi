package com.nantian.rept.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.RptChartConfMultVo;
import com.nantian.rept.vo.RptChartConfVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class RptChartConfService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptChartConfService.class);

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
	public RptChartConfService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("reportType", FieldType.STRING);
		fields.put("sheetName", FieldType.STRING);
		fields.put("chartType", FieldType.STRING);
		fields.put("chartName", FieldType.STRING);
		fields.put("chartSeq", FieldType.INTEGER);
		fields.put("itemList", FieldType.STRING);
		fields.put("chartYaxisTitleLeft", FieldType.STRING);
		fields.put("chartYaxisTitleRight", FieldType.STRING);
		
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(RptChartConfVo rptItemConfVo) {
		getSession().save(rptItemConfVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(RptChartConfVo rptChartConfVo) {
		getSession().update(rptChartConfVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<RptChartConfVo> rptChartConfVos) {
		for (RptChartConfVo rptChartConfVo : rptChartConfVos) {
			getSession().save(rptChartConfVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param rptChartConfVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<RptChartConfVo> rptChartConfVos) {
		for (RptChartConfVo rptChartConfVo : rptChartConfVos) {
			getSession().saveOrUpdate(rptChartConfVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param rptChartConfVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(RptChartConfVo rptChartConfVo) {
			getSession().saveOrUpdate(rptChartConfVo);
	}

	
	/**
	 * 保存或者更新报表图表扩展表（饼图、柱形图）
	 * @param rptChartConfMultVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdateForMult(RptChartConfMultVo rptChartConfMultVo) {
			getSession().saveOrUpdate(rptChartConfMultVo);
	}
	
	/**
	 * 通过主键查找唯一的一条记录	 * @param aplCode 应用系统编号
	 * @param reportType 报表类型
	 * @param sheetName 日报SHEET名	 * @param chartType 图表类型
	 * @param chartName 图表名称
	 * @param chartSeq 图表顺序号
	 * @return RptChartConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public RptChartConfVo findByUnionKey(String aplCode, String reportType, String sheetName, String chartType, String chartName, String chartSeq){
		return (RptChartConfVo) getSession()
				.createQuery("from RptChartConfVo rc where rc.aplCode=:aplCode and rc.reportType=:reportType and rc.sheetName=:sheetName and rc.chartType=:chartType and rc.chartName=:chartName  and rc.chartSeq=:chartSeq ")
				.setString("aplCode", aplCode)
				.setString("reportType", reportType)
				.setString("sheetName", sheetName)
				.setString("chartType", chartType)
				.setString("chartName", chartName)
				.setString("chartSeq", chartSeq)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(RptChartConfVo rptChartConfVo) {
		getSession().delete(rptChartConfVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[primaryKeys[0].split(Constants.SPLIT_SEPARATEOR, -1).length];
		for (String key : primaryKeys) {
			keyArr = key.split(Constants.SPLIT_SEPARATEOR, -1);
			deleteById(keyArr[0],keyArr[1],keyArr[2],keyArr[3],keyArr[4],keyArr[5],keyArr[6]);
			deleteByIdForMult(keyArr[0],keyArr[1],keyArr[2],keyArr[3],keyArr[4]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	@Transactional("maoprpt")
	public void deleteById(String aplCode, String reportType, String sheetName, String chartType, String chartName, String chartSeq, String chartYaxisPosition) {
		getSession().createQuery("delete from RptChartConfVo rc where rc.aplCode=? and rc.reportType=? and rc.sheetName=? and rc.chartType=? and rc.chartName=? and rc.chartSeq=? and rc.chartYaxisPosition=? ")
			.setString(0, aplCode)
			.setString(1, reportType)
			.setString(2, sheetName)
			.setString(3, chartType)
			.setString(4, chartName)
			.setString(5, chartSeq)
			.setString(6, chartYaxisPosition)
			.executeUpdate();
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	@Transactional("maoprpt")
	public void deleteByIdForMult(String aplCode, String reportType, String sheetName, String chartType, String chartName) {
		getSession().createQuery("delete from RptChartConfMultVo rcm where rcm.aplCode=? and rcm.reportType=? and rcm.sheetName=? and rcm.chartType=? and rcm.chartName=? ")
			.setString(0, aplCode)
			.setString(1, reportType)
			.setString(2, sheetName)
			.setString(3, chartType)
			.setString(4, chartName)
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
	public List<RptChartConfVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from RptChartConfVo rc where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rc." + key + " like :" + key);
				} else {
					hql.append(" and rc." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by rc." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> queryAllOutMap(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append(" select new map(")
			.append(" rc.aplCode as aplCode, ")
			.append(" rc.reportType as reportType, ")
			.append(" rc.sheetName as sheetName, ")
			.append(" rc.chartType as chartType, ")
			.append(" rc.chartName as chartName, ")
			.append(" rc.chartSeq as chartSeq, ")
			.append(" rc.itemList as itemList, ")
			.append(" rc.chartYaxisTitle as chartYaxisTitle, ")
			.append(" rc.chartYaxisMinval as chartYaxisMinval, ")
			.append(" rc.chartYaxisMaxval as chartYaxisMaxval, ")
			.append(" rc.chartYaxisInterval as chartYaxisInterval, ")
			.append(" rc.chartYaxisUnit as chartYaxisUnit, ")
			.append(" rc.chartYaxisPosition as chartYaxisPosition, ")
			.append(" (select rcm.itemNameCol from RptChartConfMultVo rcm where rc.aplCode=rcm.aplCode and rc.reportType=rcm.reportType")
			.append("  and rc.sheetName=rcm.sheetName and rc.chartType=rcm.chartType and rc.chartName=rcm.chartName) as itemNameCol,")
			.append(" (select rcm.itemValCol from RptChartConfMultVo rcm where rc.aplCode=rcm.aplCode and rc.reportType=rcm.reportType")
			.append("  and rc.sheetName=rcm.sheetName and rc.chartType=rcm.chartType and rc.chartName=rcm.chartName) as itemValCol,")
			.append(" (select case when rcm.separateRowNum is not null then 1 when rcm.separateThreshold is not null then 2 end as separate_condition")
			.append("  from RptChartConfMultVo rcm where rc.aplCode=rcm.aplCode and rc.reportType=rcm.reportType")
			.append("  and rc.sheetName=rcm.sheetName and rc.chartType=rcm.chartType and rc.chartName=rcm.chartName) as separate_condition, ")
			.append(" (select case when rcm.separateRowNum is not null then rcm.separateRowNum when rcm.separateThreshold is not null then rcm.separateThreshold  end as separate_value")
			.append("  from RptChartConfMultVo rcm where rc.aplCode=rcm.aplCode and rc.reportType=rcm.reportType")
			.append("  and rc.sheetName=rcm.sheetName and rc.chartType=rcm.chartType and rc.chartName=rcm.chartName) as separate_value )")
			.append(" from RptChartConfVo rc where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rc." + key + " like :" + key);
				} else {
					hql.append(" and rc." + key + " = :" + key);
				}
			}
		}
		hql.append(" order by rc." + sort + " " + dir);
		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptChartConfVo> queryRptChartConfList(String aplCode, String reportType, String sheetName) {

		StringBuilder hql = new StringBuilder();
		hql.append("from RptChartConfVo rc where 1=1 ")
			.append(" and rc.aplCode = :aplCode")
			.append(" and rc.reportType = :reportType")
			.append(" and rc.sheetName = :sheetName ");
		
		 hql.append(" order by rc.aplCode, rc.sheetName, rc.chartSeq ");
		
		Query query = getSession().createQuery(hql.toString());
		query.setString("aplCode", aplCode)
				.setString("reportType", reportType)
				.setString("sheetName", sheetName);
		
		return query.list();
	}
	
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<RptChartConfVo> queryRptChartConfList( Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from RptChartConfVo rc where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and rc." + key + " like :" + key);
				} else {
					hql.append(" and rc." + key + " = :" + key);
				}
			}
		}
		
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}

	
	
	
		
		/**
		 * 查询日报管理树形菜单
		 * @param params
		 * @return
		 */
		@SuppressWarnings({ "unchecked" })
		@Transactional(value = "maoprpt", readOnly = true)
		public List<Map<String, Object>> queryItem_list(String aplCode) {

			StringBuilder hql = new StringBuilder();
			hql.append("select distinct new map(")
				.append(" rt.item_cd_app as value,")
				.append(" rt.item_app_name as name ) ")
				.append("from RptItemAppVo rt where 1=1 ");
		 hql.append(" and rt.apl_code = :aplCode ");
			 
			Query query = getSession().createQuery(hql.toString());
			 query.setString("aplCode", aplCode);
			
			return query.list();
		
	}
		
		
		/**
		 * 查询日报管理树形菜单
		 * @param params
		 * @return
		 */
		@Transactional(value = "maoprpt", readOnly = true)
		public String get_itemname(String aplCode,String value) {

			StringBuilder sql = new StringBuilder();
			sql.append("select distinct ")
				.append(" rt.item_app_name as name  ")
				.append("from RPT_ITEM_APP rt where rt.item_cd_app =:value  ");
		 sql.append(" and rt.apl_code = :aplCode ");
			 
			Query query = getSession().createSQLQuery(sql.toString());
			 query.setString("aplCode", aplCode);
			 query.setString("value", value);
			
			return (String) query.uniqueResult();
		
	}
	
	
}///:~

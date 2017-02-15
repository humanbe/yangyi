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
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.DateTransVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class DateTransService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(DateTransService.class);

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
	public DateTransService() {
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
	public void save(DateTransVo dateTransVo) {
		getSession().save(dateTransVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(DateTransVo dateTransVo) {
		getSession().update(dateTransVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<DateTransVo> dateTransVos) {
		for (DateTransVo dateTransVo : dateTransVos) {
			getSession().save(dateTransVo);
		}
	}
	
	/**
	 * 批量保存或者更新

	 * @param dateTransVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<DateTransVo> dateTransVos) {
		for (DateTransVo dateTransVo : dateTransVos) {
			getSession().saveOrUpdate(dateTransVo);
		}
	}
	
	/**
	 * 保存或者更新

	 * @param dateTransVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(DateTransVo dateTransVo) {
			getSession().saveOrUpdate(dateTransVo);
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
	public List<DateTransVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("from DateTransVo dt where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(!key.equals("startDate") && !key.equals("endDate")){
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and dt." + key + " like :" + key);
					} else {
						hql.append(" and dt." + key + " = :" + key);
					}
				}
			}
		}
		hql.append(" and dt.transDate between :startDate and :endDate");
		hql.append(" order by dt." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询日交易量统计表

	 * @param aplCode
	 * @param startDate
	 * @param endDate
	 * @param countItem
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<DateTransVo> queryDateTransList(String aplCode, String startDate, String endDate, String countItem) {
		StringBuilder hql = new StringBuilder();
		hql.append("select  ")
			.append("dt.apl_code,  ")
			.append("to_char(to_date(dt.trans_date, 'yyyymmdd'), 'yyyy-mm-dd') as trans_date, ")
			.append("dt.count_item, ")
			.append("dt.count_amount ")
			.append("from date_trans dt ")
			.append("where  dt.apl_code = :aplCode")
			.append(" and dt.trans_date between :startDate and :endDate")
			.append(" and dt.count_item = :countItem ");
		 hql.append(" order by dt.apl_code, dt.trans_date desc, dt.count_item ");
		 
		Query query = getSession().createSQLQuery(hql.toString()).addEntity(DateTransVo.class);
		query.setString("aplCode", aplCode)
				.setString("startDate", startDate)
				.setString("endDate", endDate)
				.setString("countItem", countItem);
		
		return query.list();
	}
	
	
	/**
	 * 查询数据—获取合计值、平均值、最大值
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
			.append(" from (select o.countItem as countItem, ")
			.append("			 		o.itemSeq as itemSeq, ")
			.append(" 					o.expression as expression, ")
			.append(" 					o.expressionUnit as expressionUnit, ")
			.append(" 					o.sumVal as sumValue, ")
			.append("					o.avgVal as avgValue, ")
			.append(" 					o.maxVal as maxValue, ")
			.append(" 					to_char(to_date(pi.peak_date,'YYYY-MM-DD'),'YYYY-MM-DD') as peakDate, ")
			.append(" 					pi.count_item as peakCountItem, ")
			.append("				 	pi.peak_value as peakValue, ")
			.append("					row_number() over(partition by o.aplCode, o.countItem order by to_number(pi.peak_value) desc) as rn ")
			.append("		from ( select ri.item_cd as countItem, ")
			.append("							ri.item_seq as itemSeq, ")
			.append("							max(ri.apl_code) as aplCode, ")
			.append("                          max(ri.sheet_name) as sheetName, ")
			.append("							max(ri.expression) as expression, ")
			.append("							max(ri.expression_unit) as expressionUnit, ")
			.append("							sum(cast(dt.count_amount as int)) as sumVal, ")
			.append("							round(avg(cast(dt.count_amount as int))) as avgVal, ")
			.append("							max(cast(dt.count_amount as int)) as maxVal ")
			.append(" 				from rpt_item_conf ri left join date_trans dt ")
			.append(" 						on ri.apl_code = dt.apl_code and ri.item_cd = dt.count_item ")
			.append(" 						and dt.trans_date between :startDate and :endDate ")
			.append("                      and regexp_like(dt.count_amount,'^[0-9]*[.]*[0-9]*$') ")
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
	
	
}///:~

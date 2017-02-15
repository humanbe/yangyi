package com.nantian.check.service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.DateFunction;
import com.nantian.jeda.FieldType;
import com.nantian.rept.service.AplAnalyzeService;
import com.nantian.rept.service.ServerConfService;
import com.nantian.rept.vo.AplAnalyzeVo;

/**
 * 巡检报告统计service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class CheckReportService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckReportService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
	private ServerConfService serverConfService;
	@Autowired
	private AplAnalyzeService aplAnalyzeService;
	@Autowired
	private AppInfoService appInfoService;
	/**
	 * 构造方法	 */
	public CheckReportService() {
		fields.put("APLCODE", FieldType.STRING);
		fields.put("APLNAME", FieldType.STRING);
		fields.put("TRANSDATE", FieldType.STRING);
		fields.put("TRANSTIME", FieldType.STRING);
		fields.put("TOTAL", FieldType.INTEGER);
		fields.put("UNHANDLE",FieldType.INTEGER);
		fields.put("USUAL", FieldType.INTEGER); 
		fields.put("UNUSUAL", FieldType.INTEGER); 
		fields.put("TRANSDATE_BEGIN", FieldType.INTEGER); 
		fields.put("TRANSDATE_END", FieldType.INTEGER); 
	}
	/**
	 * 分页查询统计信息
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getReportSumList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params,String unhandle_state) {
		StringBuilder sql = new StringBuilder();
		sql.append("select o.aplCode as aplCode,o.aplName as aplName,o.transDate as transDate,o.transTime as transTime,");
		sql.append("o.total as total,o.unhandle as unhandle,o.usual as usual,o.unusual as unusual , o.unhandlestate as unhandlestate ");
		sql.append(" from (select m.apl_code as aplCode,n.systemname as aplName,m.trans_date as transDate,m.trans_time as transTime,");
		sql.append("count(*) as total,sum(unhandle) as unhandle,sum(usual) as usual,sum(unusual) as unusual , sum(unhandlestate) as unhandlestate ");
		sql.append("from (select  t.apl_code,t.trans_date,t.trans_time,");
		sql.append("case when t.status='1' then 1 else 0 end as usual,");
		sql.append("case when t.status='2' then 1 else 0 end as unusual," );
		sql.append("case when t.handle_state is null then 1 else 0 end as unhandle,");
		sql.append(" case when t.handle_state='2' then 1 else 0 end as unhandlestate ");
		sql.append(" from apl_analyze t) m,V_CMN_APP_INFO n ");
		sql.append("where m.apl_code=n.appsys_code ");
		sql.append("and m.apl_code in (:sysList) ");
		
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("APLCODE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.apl_code like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.apl_code=" + value.substring(1, value.length()-1));
					}
				}
				if(key.equals("TRANSDATE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.trans_date like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.trans_date=" + value.substring(1, value.length()-1));
					}
				}
			}
		}else{
			String curDate = DateFunction.getFormatDateStr(new Date(),"yyyyMMdd") ;
			sql.append(" and m.trans_date='"+DateFunction.getDateByFormatAndOffset(curDate,0,-1)+"' ");
		}
		sql.append(" group by m.apl_code,n.systemname,m.trans_date,m.trans_time ");
		if(sort!=null && !sort.equals("")){
			sql.append(" order by m." + sort );
			if(dir!=null && !dir.equals("")){
				sql.append(" " + dir );
			}else{
				sql.append(" desc");
			}
		}else{
			sql.append(" order by m.apl_code,m.trans_date,m.trans_time ");
		}
		
		if(unhandle_state.equals("0")){
			sql.append(" ) o where o.unhandle != '0' ");
		}else if(unhandle_state.equals("1")){
			sql.append(" ) o where o..unhandle = '0' ");
		}else{
			sql.append(" ) o ");
		}
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
                  .setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				  .setFirstResult(start).setMaxResults(limit);
		return query.list();
	}
	/**
	 * 获取记录总数
	 * @param params
	 */
	@Transactional(readOnly = true)
	public Long countReportSumList(Map<String, Object> params,String unhandle_state) {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from ( ");
		sql.append("select o.aplCode as aplCode,o.aplName as aplName,o.transDate as transDate,o.transTime as transTime,");
		sql.append("o.total as total,o.unhandle as unhandle,o.usual as usual,o.unusual as unusual , o.unhandlestate as unhandlestate ");
		sql.append(" from (select m.apl_code as aplCode,n.systemname as aplName,");
		sql.append("m.trans_date as transDate,m.trans_time as transTime,");
		sql.append("count(*) as total,sum(unhandle) as unhandle,");
		sql.append("sum(usual) as usual,sum(unusual) as unusual, sum(unhandlestate) as unhandlestate   ");
		sql.append("from (select  t.apl_code,t.trans_date,t.trans_time,");
		sql.append("case when t.handle_state is null then 1 else 0 end as unhandle,");
		sql.append("case when t.status='1' then 1 else 0 end as usual,");
		sql.append("case when t.status='2' then 1 else 0 end as unusual, ");
		sql.append(" case when t.handle_state='2' then 1 else 0 end as unhandlestate ");
		sql.append("from apl_analyze t) m,V_CMN_APP_INFO n ");
		sql.append("where m.apl_code=n.appsys_code ");
		sql.append("and m.apl_code in (:sysList) ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("APLCODE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.apl_code like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.apl_code=" + value.substring(1, value.length()-1));
					}
				}
				if(key.equals("TRANSDATE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.trans_date like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.trans_date=" + value.substring(1, value.length()-1));
					}
				}
			}
		}else{
			sql.append(" and m.trans_date='"+DateFunction.getFormatDateStr(new Date(),"yyyyMMdd")+"' ");
		}
		sql.append(" group by m.apl_code,n.systemname,m.trans_date,m.trans_time) o");
		if(unhandle_state.equals("0")){
			sql.append(" where  o.unhandle != '0' ");
		}else if(unhandle_state.equals("1")){
			sql.append(" where  o.unhandle = '0' ");
		}
		sql.append(") ");
		
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
                  .setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
                  ;
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 分页查询统计信息
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getReportCountList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params) {
		StringBuilder sql = new StringBuilder();
		sql.append("select m.apl_code as aplCode,n.systemname as aplName,");
		sql.append("m.trans_date as transDate,m.trans_time as transTime,");
		sql.append("sum(unhandle) as unhandle,");
		sql.append("count(*) ||' / '||sum(unhandle)||' / '||sum(handle) as total, ");
		sql.append("sum(usual)||' / '||sum(unusual) as unusual, ");
		sql.append(" sum(handlestate)||' / '||sum(unhandlestate) as unhandlestate ");
		sql.append("from (select t.apl_code,t.trans_date,t.trans_time,");
		sql.append("case when t.handle_state is null then 1 else 0 end as unhandle,");
		sql.append("case when t.status='1' then 1 else 0 end as usual,");
		sql.append("case when t.status='2' then 1 else 0 end as unusual, ");
		sql.append(" case when t.handle_state is null then 0 else 1 end as handle, ");
		sql.append(" case when t.handle_state='2' then 1 else 0 end as unhandlestate, ");
		sql.append(" case when t.handle_state='1' then 1 else 0 end as handlestate ");
		sql.append("from apl_analyze t) m,V_CMN_APP_INFO n ");
		sql.append("where m.apl_code=n.appsys_code ");
		sql.append("and m.apl_code in (:sysList) ");
	
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("APLCODE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.apl_code like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.apl_code=" + value.substring(1, value.length()-1));
					}
				}
				if(key.equals("TRANSDATE_BEGIN")){
					sql.append(" and  m.trans_date>='" + params.get(key).toString()+"'");
				}
				if(key.equals("TRANSDATE_END")){
					sql.append(" and  m.trans_date<='" + params.get(key).toString()+"'");
				}
			}
		}else{ //默认显示昨天与今天的统计数据
			String today = DateFunction.getFormatDateStr(new Date(),"yyyyMMdd");
			String yesterday = DateFunction.getDateByFormatAndOffset(today,0,-1);
			sql.append(" and m.trans_date>='"+yesterday+"' ");
			sql.append(" and m.trans_date<='"+today+"' ");
		}
		sql.append(" group by m.apl_code,n.systemname,m.trans_date,m.trans_time ");
		if(sort!=null && !sort.equals("")){
			sql.append(" order by m." + sort );
			if(dir!=null && !dir.equals("")){
				sql.append(" " + dir );
			}else{
				sql.append(" desc");
			}
		}else{
			sql.append(" order by m.apl_code,m.trans_date,m.trans_time ");
		}
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
                  .setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				  .setFirstResult(start).setMaxResults(limit);
		return query.list();
	}
	/**
	 * 获取记录总数
	 * @param params
	 */
	@Transactional(readOnly = true)
	public Long countReportCountList(Map<String, Object> params) {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from (select m.apl_code as aplCode,n.systemname as aplName,");
		sql.append("m.trans_date as transDate,m.trans_time as transTime,");
		sql.append("count(*) as total,sum(unhandle) as unhandle,");
		sql.append("sum(usual)||' / '||sum(unusual) as unusual, ");
		sql.append(" sum(handlestate)||' / '||sum(unhandlestate) as unhandlestate ");
		sql.append("from (select t.apl_code,t.trans_date,t.trans_time,");
		sql.append("case when t.handle_state is null then 1 else 0 end as unhandle,");
		sql.append("case when t.status='1' then 1 else 0 end as usual,");
		sql.append("case when t.status='2' then 1 else 0 end as unusual, ");
		sql.append(" case when t.handle_state='2' then 1 else 0 end as unhandlestate, ");
		sql.append(" case when t.handle_state='1' then 1 else 0 end as handlestate ");
		sql.append("from apl_analyze t) m,V_CMN_APP_INFO n ");
		sql.append("where m.apl_code=n.appsys_code ");
		sql.append("and m.apl_code in (:sysList) ");
		
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if(key.equals("APLCODE")){
					if (fields.get(key).equals(FieldType.STRING)) {
						sql.append(" and  m.apl_code like '" + params.get(key) + "'");
					}else {
						String value = params.get(key).toString();
						sql.append(" and  m.apl_code=" + value.substring(1, value.length()-1));
					}
				}
				if(key.equals("TRANSDATE_BEGIN")){
					sql.append(" and  m.trans_date>='" + params.get(key).toString()+"'");
				}
				if(key.equals("TRANSDATE_END")){
					sql.append(" and  m.trans_date<='" + params.get(key).toString()+"'");
				}
			}
		}else{ //默认显示昨天与今天的统计数据
			String today = DateFunction.getFormatDateStr(new Date(),"yyyyMMdd");
			String yesterday = DateFunction.getDateByFormatAndOffset(today,0,-1);
			sql.append(" and m.trans_date>='"+yesterday+"' ");
			sql.append(" and m.trans_date<='"+today+"' ");
		}
		sql.append(" group by m.apl_code,n.systemname,m.trans_date,m.trans_time) ");
		
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
                  .setParameterList("sysList", appInfoService.getPersonalSysListForCheck())
                  ;
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 检汇总报告	 */
	@Transactional(readOnly = true)
	public void checkDataSyn() {
		List<Map<String, String>> checkDataSynQuery = checkDataSynQuery();
		for(int i=0 ; i<checkDataSynQuery.size() ; i++){
			String aplCode = (String) checkDataSynQuery.get(i).get("aplCode");
			String sheetName = (String) checkDataSynQuery.get(i).get("sheetName");
			String itemCd = (String) checkDataSynQuery.get(i).get("itemCd");
			String groupParents = (String) checkDataSynQuery.get(i).get("groupParent");
			checkDataSynAdd(aplCode, sheetName,itemCd,groupParents);
		}
	}
	
	/**
	 * 检汇总报告数据查询	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> checkDataSynQuery() {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.aplCode as aplCode,");
 		hql.append(" t.itemCd as itemCd,");
 		hql.append(" t.groupParent as groupParent,");
 		hql.append(" t.sheetName as sheetName");
 		hql.append(" ) from RptItemConfVo t");
 		hql.append(" group by t.aplCode, t.sheetName,t.itemCd,t.groupParent ");
		Query query = getSession().createQuery(hql.toString());
		List<Map<String, Object>> checkDataSynQuery = query.list();
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		for(int i=0 ; i<checkDataSynQuery.size() ; i++){
			String aplCode = (String) checkDataSynQuery.get(i).get("aplCode");
			String sheetName = (String) checkDataSynQuery.get(i).get("sheetName");
			String itemCd = (String) checkDataSynQuery.get(i).get("itemCd");
			String groupParent = (String) checkDataSynQuery.get(i).get("groupParent");
			if(sheetName.equals("系统资源使用率图表")){
				  List<Map<String, String>> serClassList = serverConfService.queryAllSerClass(aplCode);
				  for (Map<String, String> serClassMap : serClassList) {
					   sheetName="系统资源使用率图表";
						switch(ComUtil.changeToChar(String.valueOf(serClassMap.get("serClass")))){
						case '1': sheetName=sheetName.concat("_Web");break;
						case '2': sheetName=sheetName.concat("_APP");break;
						case '3': sheetName=sheetName.concat("_DB");break;
						}
						
						if(sheetName!=null && !sheetName.equals("系统资源使用率图表")){
							Map<String,String> map = new HashMap<String,String>();
							map.put("aplCode", aplCode);
							map.put("sheetName", sheetName);
							map.put("itemCd", itemCd);
							map.put("groupParent", groupParent);
							jsonMapList.add(map);
						}
				  }
			}
			if(sheetName!=null && sheetName.indexOf("系统资源使用率图表")==-1){
				Map<String,String> map = new HashMap<String,String>();
				map.put("aplCode", aplCode);
				map.put("sheetName", sheetName);
				map.put("itemCd", itemCd);
				map.put("groupParent", groupParent);
				jsonMapList.add(map);
			}
		}
		return jsonMapList;
	}
	
	/**
	 * 检汇总报告数据插入
	 * @param groupParent 
	 * @param itemCd 
	 */
	@Transactional(readOnly = true)
	public void checkDataSynAdd(String aplCode,String sheetName, String itemCd, String groupParents) {
	//	String yyyyMMdd = new SimpleDateFormat("yyyyMMdd").format(new Date());
		String yyyyMMdd= DateFunction.getSystemDate(-1);
		AplAnalyzeVo aplAnalyze = new AplAnalyzeVo();
		aplAnalyze.setAplCode(aplCode);
		aplAnalyze.setTransDate(yyyyMMdd);
		aplAnalyze.setTransTime("09:00");
		aplAnalyze.setAnaItem(sheetName);
		StringBuilder itemCdSql = new StringBuilder();
		itemCdSql.append("select * from cap_threshold_chk_result t where t.item_cd_app='"+itemCd+"'");
		List itemCdList = getSession().createSQLQuery(itemCdSql.toString()).list();
		if(itemCdList.size()>0){ 
			aplAnalyze.setStatus("2");
		}else{
			aplAnalyze.setStatus("1");
		}
		if(groupParents!=null){
			String[] groupParent = groupParents.split(",");
			for(int i = 0;i<groupParent.length;i++ ){
				StringBuilder groupParentSql = new StringBuilder();
				groupParentSql.append("select * from cap_threshold_chk_result t where t.item_cd_app='"+groupParent[i]+"'");
				List groupParentList = getSession().createSQLQuery(groupParentSql.toString()).list();
				if(groupParentList.size()>0){
					aplAnalyze.setStatus("2");
				}else{
					aplAnalyze.setStatus("1");
				}
			}
		}
		aplAnalyzeService.saveOrUpdate(aplAnalyze);
	}
	
	/**
	 * 分页获取统计明细数据
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getCountDetailList(Integer start, Integer limit, String aplCode,
			 String transDate,String transTime) {
		String sql = new String("select distinct " +
				" t.apl_code as aplCode," +
				" t.trans_date as transDate," +
				" t.trans_time as transTime," +
				" t.ana_item as anaItem," +
				" t.exe_ana_desc as exeAnaDesc," +
				" t.status as status," +
				" t.handle_state as handleState," +
				" t.ana_user as anaUser " +
				" from apl_analyze t " +
				" where t.apl_code='"+aplCode+"' " +
				" and t.trans_date='"+transDate+"' " +
				" and t.trans_time='"+transTime+"' " +
				" order by t.status,t.ana_item,t.ana_user desc");
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString())
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				  .setFirstResult(start).setMaxResults(limit);
		return query.list();
	}
	
	/**
	 * 获取记录总数
	 * @param params
	 */
	@Transactional(readOnly = true)
	public Long countCountDetailList(String aplCode,String transDate,String transTime) {
		String sql = new String("select count(*) from ( " +
				" select distinct * " +
				" from apl_analyze t " +
				" where t.apl_code='"+aplCode+"' " +
				" and t.trans_date='"+transDate+"' " +
				" and t.trans_time='"+transTime+"' " +
				" )");
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString());
		return Long.valueOf(query.uniqueResult().toString());
	}
}




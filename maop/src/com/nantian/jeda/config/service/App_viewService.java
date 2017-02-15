/**
 * 
 */
package com.nantian.jeda.config.service;

import java.sql.Clob;
import java.sql.SQLException;
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
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.StringUtil;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.App_view;
import com.nantian.jeda.common.model.App_view_detail;


/**
 * 
 * @author gyc
 *
 */
@Repository
public class App_viewService {

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/** 查询字段及类型 */
	public Map<String, String> avfields = new HashMap<String, String>();
	/**
	 * 构造函数
	 */
	public App_viewService(){
		
		avfields.put("aview_rel_id",FieldType.INTEGER);
		avfields.put("aview_name", FieldType.STRING);
		avfields.put("aview_desc", FieldType.STRING);
		avfields.put("aview_oper", FieldType.STRING);
		avfields.put("aview_time", FieldType.STRING);

		avfields.put("avd_id", FieldType.INTEGER);
		avfields.put("avd_rel_id", FieldType.INTEGER);
		avfields.put("avd_simpdesc", FieldType.STRING);
		avfields.put("avd_descdetail", FieldType.CLOB);
		avfields.put("avd_type", FieldType.STRING);
	}

	/**
	 * 小窗内的内容
	 * @param aview_time
	 * @return str.toString();
	 * @throws SQLException
	 */
	@Transactional(readOnly = true)
	public Object aViewFind(String aview_time) throws SQLException{

		StringBuilder str = new StringBuilder();
		//hql语句从相应的VO中查数据
		StringBuilder hql = new StringBuilder();
		hql.append("select new map( avd.avd_rel_id as avd_rel_id, avd.avd_id as avd_id, " +
				"avd.avd_simpdesc||'&nbsp;&nbsp;['||avw.aview_time||'-'||avd.avd_type||']<br>' as app_view_content) " +
				"from  App_view avw,App_view_detail avd " +
				"where avw.aview_rel_id = avd.avd_rel_id ");

		if(aview_time.equals("1")){
			hql.append("and avw.aview_time > to_char(add_months(sysdate, -1), 'yyyy-mm-dd')");
		}
		if(aview_time.equals("2")){
			hql.append("and avw.aview_time > to_char(add_months(sysdate, -2), 'yyyy-mm-dd')");
		}
		if(aview_time.equals("3")){
			hql.append("and avw.aview_time > to_char(add_months(sysdate, -3), 'yyyy-mm-dd')");
		}
		if(aview_time.equals("6")){
			hql.append("and avw.aview_time > to_char(add_months(sysdate, -6), 'yyyy-mm-dd')");
		}

		hql.append(" order by avd.avd_type, avw.aview_time ");

		@SuppressWarnings("unchecked")
		List<Map<String,String>> list= getSession().createQuery(hql.toString()).list();//多条数据用list

		str.append(" <marquee direction=up scrollamount=2 onmouseover=this.stop() onmouseout=this.start()>");
		for(Map<String,String> map:list){
			str.append("<a href=\"javascript:show_detail("+map.get("avd_rel_id")+","+map.get("avd_id")+")\">"+
					map.get("app_view_content")+"</a>");
		}
		str.append("</marquee>");

		return str.toString();
	}
	
	/**
	 * 后台起始页所有数据
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return query.list();
	 * @throws SQLException
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryAViewInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,HttpServletRequest request)throws SQLException {


		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("avw.aview_rel_id as aview_rel_id,");
		hql.append("avw.aview_name as aview_name,");
		hql.append("avw.aview_desc as aview_desc,");
		hql.append("avw.aview_oper as aview_oper,");
		hql.append("avw.aview_time as aview_time,");
		hql.append("avd.avd_id as avd_id,");
		hql.append("avd.avd_simpdesc as avd_simpdesc,");
		hql.append("avd.avd_descdetail as avd_descdetail,");
		hql.append("avd.avd_type as avd_type,");
		hql.append("avd.avd_rel_id as avd_rel_id");
		hql.append(") from App_view avw ,  App_view_detail avd");
		hql.append(" where avw.aview_rel_id = avd.avd_rel_id");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (avfields.get(key).equals(FieldType.STRING)) {
					if(key.equals("avd_type"))
					{
						hql.append(" and avd." + key +" like :" + key);
					}
					else{
						hql.append(" and avw." + key + " like :" + key);
					}
				} else {
					hql.append(" and avw." + key + " = :" + key);
				}
			}
		}
		
		hql.append(" order by avw.aview_rel_id");

		Query query = getSession().createQuery(hql.toString());
		//.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("appViewInfoExport", query.list());

		return query.list();
	}

	/**
	 * 后台起始页数据量统计
	 * @param params
	 * @return Long.valueOf(query.uniqueResult().toString());
	 * @throws SQLException
	 */
	@Transactional(readOnly = true)
	public Long aViewCount(Map<String, Object> params)throws SQLException  {


		StringBuilder hql = new StringBuilder();
		hql.append("select distinct count(*) from App_view avw,App_view_detail avd" +
				" where avw.aview_rel_id = avd.avd_rel_id "); 

		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (avfields.get(key).equals(FieldType.STRING)) {
					if(key.equals("avd_type"))
					{
						hql.append(" and avd." + key +" like :" + key);
					}
					else{
						hql.append(" and avw." + key + " like :" + key);
					}
				} else {
					hql.append(" and avw." + key + " = :" + key);
					hql.append(" and avd." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());

	}
	
	/**
	 * 后台起始页双击查看数据查询
	 * @param avd_id
	 * @param avd_rel_id
	 * @return map
	 */
	@Transactional(readOnly = true)
	public Object queryDblViewById(String avd_id, String avd_rel_id) {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("avw.aview_rel_id as \"aview_rel_id\",");
		sql.append("avw.aview_name as \"aview_name\",");
		sql.append("avw.aview_desc as \"aview_desc\",");
		sql.append("avw.aview_oper as \"aview_oper\",");
		sql.append("avw.aview_time as \"aview_time\",");
		sql.append("avd.avd_id as \"avd_id\",");
		sql.append("avd.avd_rel_id as \"avd_rel_id\",");
		sql.append("avd.avd_type as \"avd_type\",");
		sql.append("avd.avd_simpdesc as \"avd_simpdesc\",");
		sql.append("avd.avd_descdetail as \"avd_descdetail\"");
		sql.append(" from app_view avw, app_view_detail avd");
		sql.append(" where avw.aview_rel_id = avd.avd_rel_id and avd.avd_id = ?");

		@SuppressWarnings("unchecked")
		Map<String,Object> map= (Map<String, Object>) getSession()
		.createSQLQuery(sql.toString())
		.setString(0, avd_id)
		.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

		if(null!=map.get("avd_descdetail")){
			String avd_descdetail=ComUtil.checkNull(StringUtil.clobToString((Clob)map.get("avd_descdetail")));
			map.put("avd_descdetail", avd_descdetail);
		}

		return map;
	}
	
	/**
	 * 修改页面数据加载
	 * @param avd_id
	 * @param avd_rel_id
	 * @return map
	 */
	@Transactional(readOnly = true)
	public Object querySubViewById(String avd_id, String avd_rel_id) {
		StringBuilder sql = new StringBuilder();

		sql.append("select  ");
		sql.append("avd.avd_id as \"avd_id\",");
		sql.append("avd.avd_rel_id as \"avd_rel_id\",");
		sql.append("avd.avd_type as \"avd_type\",");
		sql.append("avd.avd_simpdesc as \"avd_simpdesc\",");
		sql.append("avd.avd_descdetail as \"avd_descdetail\"");
		sql.append(" from app_view_detail avd");
		sql.append(" where  avd.avd_id = ?");

		@SuppressWarnings("unchecked")
		Map<String,Object> map= (Map<String, Object>) getSession()
		.createSQLQuery(sql.toString())
		.setString(0, avd_id)
		.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

		if(null!=map.get("avd_descdetail")){
			String avd_descdetail=ComUtil.checkNull(StringUtil.clobToString((Clob)map.get("avd_descdetail")));
			map.put("avd_descdetail", avd_descdetail);
		}

		return map;
	}

	/**
	 * 后台起始页删除组数据
	 * @param avd_ids
	 * @throws SQLException
	 */
	@Transactional(readOnly = true)
	public void deleteByIds(String[] avd_ids,String[] rel_ids) throws SQLException {
		for(int i = 0; i < avd_ids.length;i++){ 
			deleteById(avd_ids[i]);
		}

		for(int i = 0; i < rel_ids.length;i++){
			getSession()
			.createSQLQuery("delete from app_view avw where avw.aview_rel_id = ? and avw.aview_rel_id " +
					"not in (select avd_rel_id from app_view_detail)")
					.setString(0,rel_ids[i])
					.executeUpdate();
		}

	}
	/**
	 * 主编辑和主新建页面组删除数据
	 * @param avd_ids
	 * @param rel_ids
	 * @throws SQLException
	 */
	@Transactional
	public void deleteSubByIds(String[] avd_ids,String[] rel_ids) throws SQLException {
		for(int i = 0; i < avd_ids.length;i++){ 
			deleteById(avd_ids[i]);
		}
	}
	
	/**
	 * 单条删除数据
	 * @param gyc_id
	 * @throws SQLException
	 */
	private void deleteById(String avd_id)throws SQLException  {
		getSession()
		.createSQLQuery("delete from app_view_detail avd where avd.avd_id=?")
		.setString(0, avd_id).executeUpdate();
	}
	
	/**
	 * 更新从表数据
	 * @param app_view
	 * @param app_view_detail
	 */
	@Transactional
	public void subSaveOrUpdate(String avd_id, String avd_rel_id,String avd_type,String avd_simpdesc,String avd_descdetail) {

		getSession().createQuery(
				"update  App_view_detail avd set avd.avd_type = ?,avd.avd_simpdesc = ?,avd.avd_descdetail = ?  where avd.avd_id = ? ")
				.setString(0, avd_type)
				.setString(1, avd_simpdesc)
				.setString(2, avd_descdetail)
				.setString(3, avd_id)
				.executeUpdate();
	}
	
	/**
	 * 更新主表数据
	 * @param aview_rel_id
	 * @param aview_name
	 * @param aview_desc
	 * @param aview_oper
	 * @param aview_time
	 */
	@Transactional
	public void saveOrUpdate(String aview_rel_id, String aview_name,
			String aview_desc, String aview_oper, String aview_time) {

		getSession().createQuery(
				"update  App_view avw set avw.aview_name = ?,avw.aview_desc = ?, avw.aview_oper = ?," +
				" avw.aview_time = ? where avw.aview_rel_id = ? ")
				.setString(0, aview_name)
				.setString(1, aview_desc)
				.setString(2, aview_oper)
				.setString(3, aview_time)
				.setString(4, aview_rel_id)
				.executeUpdate();
	}
	
	/**
	 * 保存主表数据
	 * @param app_view
	 */
	@Transactional
	public void mainSave(App_view app_view){
		getSession().save(app_view);
	}
	
	/**
	 * 保存从表数据
	 * @param app_view_detail
	 */
	@Transactional
	public void save(App_view_detail app_view_detail) {

		getSession().save(app_view_detail);
	}

	/**
	 * 查询主表序列
	 * @return seq
	 */
	@Transactional
	public String seqFind(){
		String seq=	(String) getSession().createSQLQuery(
				"select to_char (app_view_seq.nextval) as \"aview_rel_id\" from dual")
				.uniqueResult();
		return seq;
	}
	
	/**
	 * 查询从表序列
	 * @return seq
	 */
	@Transactional
	public String subSeqFind(){
		String seq=	(String) getSession().createSQLQuery(
				"select to_char (app_view_det_seq.nextval) as \"avd_id\" from dual")
				.uniqueResult();
		return seq;
	}
	
	/**
	 * 查询一条主表数据关联的所有从表数据
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aview_rel_id
	 * @param params
	 * @return query.list()
	 * @throws SQLException
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> tableFind(Integer start, Integer limit,
			String sort, String dir,String aview_rel_id,  Map<String, Object> params)throws SQLException {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("avd.avd_id as avd_id,");
		hql.append("avd.avd_simpdesc as avd_simpdesc,");
		hql.append("avd.avd_descdetail as avd_descdetail,");
		hql.append("avd.avd_type as avd_type,");
		hql.append("avd.avd_rel_id as avd_rel_id");
		hql.append(") from App_view_detail avd");
		hql.append(" where avd.avd_rel_id = ?");

		Query query = getSession().createQuery(hql.toString()).setString(0, aview_rel_id);
		//.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return query.list();
	}
}

package com.nantian.toolbox.service;

import java.io.Serializable;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

import com.nantian.jeda.FieldType;
import com.nantian.toolbox.vo.ToolBoxServerInfoVo;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */

@Service
@Repository
@Transactional
public class ToolBoxServerService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ToolBoxServerService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/** 国际化资源 */
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法
	 */
	public ToolBoxServerService() {
		fields.put("tool_code", FieldType.STRING);
		fields.put("appsys_code", FieldType.STRING);
		fields.put("serverz_ip", FieldType.STRING);
		fields.put("server_route", FieldType.STRING);
		fields.put("server_group", FieldType.STRING);
		fields.put("os_user", FieldType.STRING);
		
		
		
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ToolBoxServerInfoVo toolBoxServerinfo) {
		getSession().saveOrUpdate(toolBoxServerinfo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(ToolBoxServerInfoVo toolBoxServerinfo) {
		getSession().update(toolBoxServerinfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ToolBoxServerInfoVo> toolBoxServerinfos) {
		for (ToolBoxServerInfoVo toolBoxServerinfo : toolBoxServerinfos) {
			getSession().save(toolBoxServerinfo);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable tool_code) {
		return getSession().get(ToolBoxServerInfoVo.class, tool_code);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ToolBoxServerInfoVo toolBoxServerinfo) {
		getSession().delete(toolBoxServerinfo);
	}

	

	/**
	 * 查询数据库中所有toolboxserverinfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxServerInfoVo> queryAlltoolboxserverinfo() throws SQLException{
		return getSession().createQuery("from ToolBoxServerInfoVo t").list();
	}
	
	/**
	 * 查找服务器ip
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findServerIp(Integer start, Integer limit,
			String sort, String dir,Map<String, Object> params, String appsys_code,String os_type)throws SQLException  {
		
		if(!appsys_code.equals("COMMON")){
		StringBuilder hql = new StringBuilder();
		hql.append("select DISTINCT new map(");
		hql.append("tc.server_ip as server_ip");
		
		hql.append(") from ToolBoxCmnInfoVo tc where 1=1  ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and tc." + key + " like :" + key);
				} else {
					hql.append(" and tc." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
		}else{
			
			StringBuilder sql = new StringBuilder();
			Query query;
			
				 sql.append("select distinct tc.server_ip as  \"server_ip\"  from CMN_SERVERS_INFO tc where tc.bsa_agent_flag='1' and tc.delete_flag='0' and  lower(tc.os_type)= lower(:os_type)");
				 query = getSession().createSQLQuery(sql.toString())
						 .setParameter("os_type", os_type)
						 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			
			return query.list();
	 }
	}
	
	/**
	 * 根据ID查询.
	 * 
	 * @param appsys_code
	 *        应用系统
	 * @param tool_code
	 *        工具编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findById(String tool_code, String appsys_code,String os_type,String ip,String app)throws SQLException  {
      if(appsys_code.equals("COMMON")){
			StringBuilder sql = new StringBuilder();
			sql.append("select DISTINCT  ")
			.append("cs.server_ip as \"server_ip\",")
			.append(" '' as \"server_route\",")
			.append(" '' as \"os_user\", ")
			.append("cs.server_name as \"server_name\" ")
			.append("from  CMN_SERVERS_INFO cs  ")
			.append("where  cs.BSA_AGENT_FLAG='1' and cs.DELETE_FLAG='0' ")
			.append(" and  lower(cs.os_type)= lower(:os_type) ");
			if(null!=app&&app.trim().length()>0){
				sql.append(" and  cs.appsys_code = :app ");
			}
			if(null!=ip&&!"".equals(ip)){
				sql.append(" and  cs.server_ip like '")
				   .append(ip)
				   .append("%'");
			} 
			
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			if(null!=app&&app.trim().length()>0){
				query.setString("app", app);
			}
			
			query.setString("os_type", os_type);
			return  query.list();	
		
		}else{
			StringBuilder sql = new StringBuilder();
			sql.append("select DISTINCT ")
			.append("ts.server_ip as \"server_ip\",")
			.append("ts.server_route as \"server_route\",")
			.append("ts.os_user as \"os_user\", ")
			.append("cs.server_name as \"server_name\" ")
			
			.append("from TOOL_BOX_SERVER_INFO ts ,CMN_SERVERS_INFO cs  ")
			.append("where ts.server_ip =cs.server_ip and cs.delete_flag='0'  ")
			.append(" and ts.tool_code= :tool_code and ts.appsys_code= :appsys_code and cs.appsys_code= :appsys_code");
			if(null!=ip&&!"".equals(ip)){
				sql.append(" and  ts.server_ip like '")
				   .append(ip)
				   .append("%' ");
			} 
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			
			query.setString("tool_code", tool_code).setString("appsys_code", appsys_code);
			return  query.list();
 
		}
		
	}
	
	/**
	 * 获取服务器IP数据.
	 * 
	 * @param appsys_code
	 *        应用系统
	 * @param tool_code
	 *        工具编号  
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findByIdEdit(String tool_code, String appsys_code,String server_group,String os_type)throws SQLException  {

		if(appsys_code.equals("COMMON")){
		/*StringBuilder sql = new StringBuilder();
		sql.append("select p.tool_code as \"tool_code\",");
		sql.append("p.appsys_code as \"appsys_code\",");
		sql.append("o.server_ip as \"server_ip\",");
		sql.append("p.server_route as \"server_route\",");
		sql.append("p.os_user as \"os_user\" ,");
		sql.append("(case when (select count(*)");
		sql.append(" from  ( select DISTINCT SERVER_IP as server_ip  from cmn_servers_info where lower(os_type) = lower(:os_type)) m ");
		sql.append(" where  m.server_ip = p.server_ip) > 0 then 'true' else 'false' end) as \"checked\" ");
		sql.append("from (select DISTINCT SERVER_IP as server_ip from cmn_servers_info where lower(os_type) = lower(:os_type)) o ");
		sql.append(" left join (select DISTINCT t.tool_code as tool_code, t.server_ip as server_ip,t.appsys_code as appsys_code,t.os_user as os_user,t.server_route as server_route  from TOOL_BOX_SERVER_INFO t where t.tool_code = :tool_code) p ");
		sql.append(" on  o.server_ip = p.server_ip  ");
		
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		query.setString("os_type", os_type).setString("tool_code", tool_code);		
		return  query.list();*/
			
			StringBuilder sql = new StringBuilder();
			Query query;
			
				 sql.append("select distinct tc.server_ip as  \"server_ip\"  from CMN_SERVERS_INFO tc where tc.bsa_agent_flag='1' and tc.delete_flag='0' and  lower(tc.os_type)= lower(:os_type)");
				 query = getSession().createSQLQuery(sql.toString())
						 .setParameter("os_type", os_type)
						 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			
			return query.list();
		}else{
			StringBuilder sql = new StringBuilder();
			sql.append("select  DISTINCT p.tool_code as \"tool_code\",");
			sql.append("p.appsys_code as \"appsys_code\",");
			sql.append("o.server_ip as \"server_ip\",");
			sql.append("p.server_route as \"server_route\",");
			sql.append("p.os_user as \"os_user\" ,");
			sql.append("(case when (select count(*)");
		    sql.append(" from  ( select DISTINCT SERVER_IP as server_ip  from CMN_APP_GROUP_SERVER where appsys_code= :appsys_code and server_group = :server_group and delete_flag='0' ) m ");
		    sql.append(" where  m.server_ip = p.server_ip) > 0 then 'true' else 'false' end) as \"checked\" ");
		    sql.append("from (select DISTINCT SERVER_IP as server_ip from CMN_APP_GROUP_SERVER where appsys_code= :appsys_code and server_group = :server_group and delete_flag='0' ) o ");
		    sql.append(" left join (select DISTINCT t.tool_code as tool_code, t.server_ip as server_ip,t.appsys_code as appsys_code,t.os_user as os_user,t.server_route as server_route  from TOOL_BOX_SERVER_INFO t where t.tool_code = :tool_code) p ");
		    sql.append(" on  o.server_ip = p.server_ip  ");
			
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			query.setString("tool_code", tool_code).setString("appsys_code", appsys_code).setString("server_group", server_group);
			return  query.list();
 
		}
	}
	
	

	
	/**
	 * 查询数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryAllserver(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException  {

		StringBuilder hql = new StringBuilder();
		hql.append("select DISTINCT  new map(");
		hql.append("ts.tool_code as tool_code,");
		hql.append("ts.appsys_code as appsys_code,");
		hql.append("ts.server_ip as server_ip,");
		hql.append("ts.server_route as server_route,");
		hql.append("ts.os_user as os_user");
		
		hql.append(") from ToolBoxServerInfoVo ts where 1=1");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ts." + key + " like :" + key);
				} else {
					hql.append(" and ts." + key + " = :" + key);
				}
			}
		}
		
		 
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}


	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params,String appsys_code,String os_type)throws SQLException  {
		
		
	
		if(!appsys_code.equals("COMMON")){
			StringBuilder hql = new StringBuilder();
		hql.append("select distinct count(*) from  ToolBoxCmnInfoVo tc where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and tc." + key + " like :" + key);
				} else {
					hql.append(" and tc." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
		}else{
			StringBuilder sql = new StringBuilder();
			sql.append("select distinct count(*) from CMN_SERVERS_INFO tc  where tc.bsa_agent_flag='1' and tc.delete_flag='0' and  lower(tc.os_type)= lower(:os_type) ");
			Query query = getSession().createSQLQuery(sql.toString()).setString("os_type", os_type);
			//query.setParameterList("sysList", appInfoService.getPersonalSysList());
			return Long.valueOf(query.uniqueResult().toString());
		}
	}

	
	/**
	 * 删除
	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteServer(String tool_code ,String appsys_code )throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxServerInfoVo ts where ts.tool_code = ? and ts.appsys_code= ? ")
				.setString(0, tool_code).setString(1, appsys_code).executeUpdate();
	}
	/**
	 * 删除
	 * @param tool_code
	 * @param appsys_code
	 * @param server_ip
	 */
	private void deleteById(String tool_code ,String appsys_code ,String server_ip)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxServerInfoVo ts where ts.tool_code = ? and ts.appsys_code= ? and ts.server_ip=?")
				.setString(0, tool_code).setString(1, appsys_code).setString(2, server_ip).executeUpdate();
	}

	/**
	 * 批量删除
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(String[] tool_codes, String[] appsys_codes,  String[] server_ips) throws SQLException {
		for(int i = 0; i < tool_codes.length && i < appsys_codes.length && i<server_ips.length;i++){
			deleteById(tool_codes[i], appsys_codes[i],server_ips[i]);
		}
	}



	
	/**
	 * 删除信息
	 * @return
	 */
	
	public void Delimporttoolboxserverinfo(String tool_code) {
		getSession()
		.createQuery("delete from ToolBoxServerInfoVo ts where ts.tool_code = ?  ")
		.setString(0, tool_code).executeUpdate();
	}

	/**
	 * 查找信息
	 * @return
	 */
	public ToolBoxServerInfoVo queryAlltoolboxServerinfo(String toolcode,
			String serverip) {
		
		return  (ToolBoxServerInfoVo)getSession()
				.createQuery("from ToolBoxServerInfoVo tb where tb.tool_code =? and tb.server_ip=?")
				.setString(0, toolcode).setString(1, serverip).uniqueResult();
	}

}

package com.nantian.rept.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Repository
public class WebJdbcService {
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 查询某段时间内各个集群服务指定的JDBC每天CPU的峰值列表
	 * 其中集群服务指多台机器的CPU数据或者多个weblogic服务的
	 * CPU数据
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 结束时间
	 * @param serverMap 集群服务器和JDBC连接名称的映射对象
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebJdbcPeak(String aplCode, String startDate,
			String endDate, Map<String, List<String>> serverMap){
		StringBuilder sql = new StringBuilder();
		sql.append("	select j.apl_code as \"aplCode\", ")
			.append("	       w.cluster_server as \"clusterServer\", ")
			.append("	       to_char(to_date(j.monitor_date, 'yyyymmdd'), 'yyyy-mm-dd') as \"monitorDate\", ")
			.append("	       j.jdbc_name as \"jdbcName\", ")
			.append("	       max(j.current_active) as \"usedValue\" ")
			.append("	  from (select t.apl_code as apl_code, ")
			.append("	               to_char(to_date(t.monitor_date, 'yyyymmdd'), 'yyyymmdd') as monitor_date, ")
			.append("	               t.weblogic_server as weblogic_server, ")
			.append("	               t.srv_code as srv_code, ")
			.append("	               t.jdbc_name as jdbc_name, ")
			.append("	               max(to_number(t.current_active)) as current_active, ")
			.append("	               t.weblogic_port as weblogic_port ")
			.append("	          from web_jdbc t ")
			.append("	         where t.apl_code = :aplCode ")              
			.append("	           and t.monitor_date between :startDate and :endDate ")        
			.append("	         group by t.apl_code, t.srv_code, t.weblogic_server, t.jdbc_name, t.monitor_date, t.weblogic_port) j, ")
			.append("       weblogic_conf w ")
			.append(" where j.apl_code = w.apl_code ")
			.append("   and w.cluster_server in :clusterServers ")
			.append("   and j.jdbc_name in :jdbcNames ")
			.append("   and j.weblogic_server = w.server_name ")
			.append("   and j.weblogic_port = w.weblogic_port ")
			.append("   and (j.srv_code = w.cluster_server or exists ")
			.append("	        (select * ")
			.append("				   from server_conf s ")
			.append("				  where s.apl_code = w.apl_code ")
			.append("				    and (w.ip_address = s.ip_address or ")
			.append("				            w.ip_address = s.float_address) ")
			.append("				    and (s.srv_code = j.srv_code or ")
			.append("				        j.srv_code = (case when s.float_address is null then ")
			.append("				         	s.ip_address else s.float_address end)))) ")
			.append(" group by j.apl_code, w.cluster_server, j.jdbc_name, j.monitor_date ")
			.append(" order by j.apl_code, w.cluster_server, j.jdbc_name, j.monitor_date desc ");
		
		return getSession().createSQLQuery(sql.toString())
									.setString("aplCode", aplCode)
									.setString("startDate", startDate)
									.setString("endDate", endDate)
									.setParameterList("clusterServers", serverMap.get("clusterServers"))
									.setParameterList("jdbcNames", serverMap.get("jdbcNames"))
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询指定服务器的指定服务的当日五分钟间隔JDBC链接使用数数据	 * @param aplCode 系统编号
	 * @param startDate 开始时间	 * @param endDate 结束时间
	 * @param serverMap 集群服务器和JDBC连接名称的映射对象	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebJdbc4One(String aplCode, String endDate, String srvCode, Boolean existPortFlag, Map<String, List<String>> serverMap){
		StringBuilder sql = new StringBuilder();
		sql.append("	select T.monitor_time as \"monitorTime\", ")
			.append("	          T.weblogic_server as \"weblogicServer\", ")
			.append("             max(T.weblogic_port) as \"weblogicPort\", ")
			.append("	          T.jdbc_name  as \"jdbcName\", ")
			.append("	          MAX(to_number(trim(T.current_active))) as \"currentActive\" ")
			.append("	  from (select to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'HH24:mi:ss'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi') as MONITOR_TIME, ")
			.append("                 max(weblogic_port) as weblogic_port, ")
			.append("	               weblogic_server, ")
			.append("	               jdbc_name, ")
			.append("	               max(to_number(trim(current_active))) as current_active ")
			.append("	          from web_jdbc t ")
			.append("	         where t.apl_code = :aplCode ")
			.append("	           and exists(select * from server_conf s  ")
			.append("	           					where (s.srv_code=t.srv_code or t.srv_code=s.ip_address or t.srv_code=s.float_address) ")
			.append("	           					and (s.srv_code=:srvCode or s.ip_address=:srvCode or s.float_address=:srvCode)) ")
			.append("             and monitor_date = :endDate ")
			.append("             and weblogic_server in (:servers) ")
			.append("             and jdbc_name in (:jdbcNames)")
			.append("             and to_date(to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'HH24:mi:ss'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') > to_date('00:00','hh24:mi') ")
			.append("             and to_date(to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'HH24:mi:ss'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') < to_date('23:59','hh24:mi') ")
			.append("	         group by monitor_time, weblogic_server, jdbc_name ");
		if(existPortFlag){
			sql.append("                                                                         , weblogic_port ");
		}
		sql.append("                ) T ");
		sql.append("   group by T.monitor_time, T.weblogic_server, T.jdbc_name ");
		if(existPortFlag){
			sql.append("                                                                         , T.weblogic_port ");
		}
		sql.append("   order by T.weblogic_server, jdbc_name, T.monitor_time ");
		if(existPortFlag){
			sql.append("                                                                         , T.weblogic_port ");
		}
		List<Map<String, String>> list = getSession().createSQLQuery(sql.toString())
				.setString("aplCode", aplCode)
				.setString("endDate", endDate)
				.setString("srvCode", srvCode)
				.setParameterList("servers", serverMap.get("servers"))
				.setParameterList("jdbcNames", serverMap.get("jdbcNames"))
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
		return list;
	}
	
	/**
	 * 查询当日集群服务器的指定服务的五分钟间隔JDBC链接使用数数据
	 * 集群服务器，通过集群服务名获取多个服务，获取时点的最大值
	 * @param aplCode 系统编号
	 * @param endDate 结束时间
	 * @param serverMap 集群服务器和JDBC连接名称的映射对象
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebJdbc4More(String aplCode, String endDate, Map<String, List<String>> serverMap){
		StringBuilder sql = new StringBuilder();
		sql.append("	select T.monitor_time as \"monitorTime\", ")
			.append("               w.cluster_server as \"weblogicServer\", ")
			.append("                T.jdbc_name as \"jdbcName\", ")
			.append("               MAX(T.current_active) as \"currentActive\" ")
			.append("	  	from (select ")
			.append("                 max(wj.apl_code) as apl_code, ")
			.append("	               to_char(to_date(trunc(to_char(to_date(substr(wj.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi')/ 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi') as monitor_time, ")
			.append("	               max(wj.srv_code) as srv_code, ")
			.append("	               max(wj.jdbc_name) as jdbc_name, ")
			.append("                 max(wj.weblogic_server) as weblogic_server, ")
			.append("	               max(to_number(wj.current_active)) as current_active ")
			.append("                 from web_jdbc wj ")
			.append("                 where wj.apl_code= :aplCode ")
			.append("	               and wj.monitor_date = :endDate ")
			.append("	               and to_date(to_char(to_date(trunc(to_char(to_date(substr(wj.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') > to_date('00:00','hh24:mi') ")
			.append("	               and to_date(to_char(to_date(trunc(to_char(to_date(substr(wj.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') < to_date('23:59','hh24:mi') ")              
			.append("	               group by wj.monitor_time, wj.srv_code, wj.weblogic_server, wj.jdbc_name) T, ")
			.append("       weblogic_conf w ")
			.append(" where T.apl_code = w.apl_code ")
			.append("   and w.cluster_server in :clusterServers ")
			.append("   and T.jdbc_name in :jdbcNames ")
			.append("   and T.weblogic_server = w.server_name ")
			.append("   and (T.srv_code = w.cluster_server or exists ")
			.append("	        (select * ")
			.append("				   from server_conf s ")
			.append("				  where s.apl_code = w.apl_code ")
			.append("				    and (w.ip_address = s.ip_address or ")
			.append("				            w.ip_address = s.float_address) ")
			.append("				    and (s.srv_code = T.srv_code or ")
			.append("				        T.srv_code = (case when s.float_address is null then ")
			.append("				         	s.ip_address else s.float_address end)))) ")
			.append("   group by w.cluster_server, T.monitor_time, T.jdbc_name")
			.append("   order by w.cluster_server, T.monitor_time, T.jdbc_name");
	
		return getSession().createSQLQuery(sql.toString())
									.setString("aplCode", aplCode)
									.setString("endDate", endDate)
									.setParameterList("clusterServers", serverMap.get("servers"))
									.setParameterList("jdbcNames", serverMap.get("jdbcNames"))
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	
}

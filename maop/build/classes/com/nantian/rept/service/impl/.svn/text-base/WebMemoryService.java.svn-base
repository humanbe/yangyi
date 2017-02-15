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
public class WebMemoryService {
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 查询某段时间内各个集群服务每天内存的峰值列表
	 * 其中集群服务指多台机器的内存数据或者多个
	 * weblogic服务的内存数据
	 * @param aplCode 系统编号
	 * @param startDate 开始时间
	 * @param endDate 结束时间
	 * @param clusterServers 集群服务器列表
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebMemoryPeak(String aplCode, String startDate,
			String endDate, List<String> clusterServers){
		StringBuilder sql = new StringBuilder();
		sql.append("	select j.apl_code as \"aplCode\", ")
			.append("	       w.cluster_server as \"clusterServer\", ")
			.append("	       to_char(to_date(j.monitor_date, 'yyyymmdd'), 'yyyy-mm-dd') as \"monitorDate\", ")
			.append("	       max(j.memory_rate) as \"usedValue\" ")
			.append("	  from (select max(t.apl_code) as apl_code, ")
			.append("	               to_char(to_date(max(t.monitor_date), 'yyyymmdd'), 'yyyymmdd') as monitor_date, ")
			.append("	               max(t.weblogic_server) as weblogic_server, ")
			.append("	               max(t.srv_code) as srv_code, ")
			.append("	               max(to_number(replace(t.memory_rate,'%',''))) as memory_rate, ")
			.append("	               max(t.weblogic_port) as weblogic_port ")
			.append("	          from web_memory t ")
			.append("	         where t.apl_code = :aplCode ")              
			.append("	           and t.monitor_date between :startDate and :endDate ")        
			.append("	         group by t.apl_code, t.weblogic_server, t.srv_code, t.monitor_date, t.weblogic_port) j, ")
			.append("       weblogic_conf w ")
			.append(" where j.apl_code = w.apl_code ")
			.append("	 and j.weblogic_port = w.weblogic_port ")
			.append("   and w.cluster_server in :clusterServers ")
			.append("   and j.weblogic_server = w.server_name ")
			.append("   and (j.srv_code = w.cluster_server or exists ")
			.append("	        (select * ")
			.append("				   from server_conf s ")
			.append("				  where s.apl_code = w.apl_code ")
			.append("				    and (w.ip_address = s.ip_address or ")
			.append("				            w.ip_address = s.float_address) ")
			.append("				    and (s.srv_code = j.srv_code or ")
			.append("				        j.srv_code = (case when s.float_address is null then ")
			.append("				         	s.ip_address else s.float_address end)))) ")
			.append(" group by j.apl_code, w.cluster_server, j.monitor_date ")
			.append(" order by j.apl_code, w.cluster_server, j.monitor_date desc ");
		
		return getSession().createSQLQuery(sql.toString())
									.setString("aplCode", aplCode)
									.setString("startDate", startDate)
									.setString("endDate", endDate)
									.setParameterList("clusterServers", clusterServers)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	/**
	 * 查询指定服务器的指定服务的当日五分钟间隔weblogic内存使用率数据	 * @param aplCode 系统编号
	 * @param endDate 日报时间
	 * @param srvCode 服务器编码	 * @param existPortFlag 是否存在端口标识
	 * @param servers weblogic服务列表
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebMemory4One(String aplCode, String endDate, String srvCode, Boolean existPortFlag, List<String> servers){
		StringBuilder sql = new StringBuilder();
		sql.append("	select t.monitor_time as \"monitorTime\", ")
			.append("	             t.weblogic_server \"weblogicServer\", ")
			.append("	             max(t.weblogic_port) as \"weblogicPort\", ")
			.append("	             max(to_number(trim(t.memory_rate))) as \"memoryRate\" ")
			.append("	  from (select ")
			.append("	               to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'hh24:mi'),'yyyymmddhh24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi') as monitor_time, ")
			.append("	               max(weblogic_port) as weblogic_port, ")
			.append("	               weblogic_server, ")
			.append("	               max(to_number(trim(replace(memory_rate,'%','')))) as memory_rate ")
			.append("	          from web_memory t ")
			.append("	         where t.apl_code = :aplCode ")
			.append("	           and exists(select * from server_conf s  ")
			.append("	           					where (s.srv_code=t.srv_code or t.srv_code=s.ip_address or t.srv_code=s.float_address) ")
			.append("	           					and (s.srv_code=:srvCode or s.ip_address=:srvCode or s.float_address=:srvCode)) ")
			.append("             and monitor_date = :endDate ")
			.append("             and weblogic_server in (:servers) ")
			.append("             and to_date(to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'hh24:mi'),'yyyymmddhh24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') > to_date('00:00','hh24:mi') ")
			.append("             and to_date(to_char(to_date(trunc(to_char(to_date(substr(monitor_time,0,5),'hh24:mi'),'yyyymmddhh24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') < to_date('23:59','hh24:mi') ")
			.append("	         group by monitor_time, weblogic_server ");
			if(existPortFlag){
				sql.append("                                                                       , weblogic_port ");
			}
			sql.append("       ) T ")
			    .append("  group by T.monitor_time, T.weblogic_server ");
			if(existPortFlag){
				sql.append("                                                                       ,T.weblogic_port ");
			}
			sql.append("  order by T.weblogic_server, T.monitor_time ");
			if(existPortFlag){
				sql.append("                                                                       ,T.weblogic_port ");
			}
		
		return getSession().createSQLQuery(sql.toString())
									.setString("aplCode", aplCode)
									.setString("endDate", endDate)
									.setString("srvCode", srvCode)
									.setParameterList("servers", servers)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	
	/**
	 * 查询当日集群服务器的指定服务的五分钟间隔weblogic内存使用率数据
	 * 集群服务器，通过集群服务名获取多个服务，获取时点的最大值
	 * @param aplCode 系统编号
	 * @param endDate 结束时间
	 * @param clusterServers 集群服务器列表	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true, value = "maoprpt")
	public List<Map<String, String>> queryWebMemory4More(String aplCode, String endDate, List<String> clusterServers){
		StringBuilder sql = new StringBuilder();
		sql.append("	select T.monitor_time as \"monitorTime\", ")
			.append("               w.cluster_server as \"weblogicServer\", ")
			.append("               max(to_number(trim(T.memory_rate))) as \"memoryRate\" ")
			.append("	  from (select ")
			.append("                 max(wm.apl_code) as apl_code, ")
			.append("	               to_char(to_date(trunc(to_char(to_date(substr(wm.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi')/ 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi') as monitor_time, ")
			.append("	               max(wm.srv_code) as srv_code, ")
			.append("                 max(wm.weblogic_server) as weblogic_server, ")
			.append("	               max(to_number(trim(replace(wm.memory_rate,'%','')))) as memory_rate ")
			.append("                 from web_memory wm ")
			.append("                 where wm.apl_code= :aplCode ")
			.append("	               and wm.monitor_date = :endDate ")
			.append("	               and to_date(to_char(to_date(trunc(to_char(to_date(substr(wm.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') > to_date('00:00','hh24:mi') ")
			.append("	               and to_date(to_char(to_date(trunc(to_char(to_date(substr(wm.monitor_time,0,5),'HH24:mi'),'yyyyMMddHH24mi') / 5) *5 + 1, 'yyyymmddhh24mi'),'hh24:mi'),'hh24:mi') < to_date('23:59','hh24:mi') ")              
			.append("	               group by wm.monitor_time, wm.srv_code, wm.weblogic_server ) T, ")
			.append("       weblogic_conf w ")
			.append(" where T.apl_code = w.apl_code ")
			.append("   and w.cluster_server in :clusterServers ")
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
			.append("   group by w.cluster_server, T.monitor_time")
			.append("   order by w.cluster_server, T.monitor_time");
		
		return getSession().createSQLQuery(sql.toString())
									.setString("aplCode", aplCode)
									.setString("endDate", endDate)
									.setParameterList("clusterServers", clusterServers)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
	}
	
	
}

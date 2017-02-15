package com.nantian.rept.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

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
import com.nantian.rept.vo.ServerConfVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class ServerConfService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ServerConfService.class);

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
	public ServerConfService() {
		fields.put("srvCode", FieldType.STRING);
		fields.put("loadMode", FieldType.STRING);
		fields.put("aplCode", FieldType.STRING);
		fields.put("serClass", FieldType.STRING);
		fields.put("serName", FieldType.STRING);
		fields.put("memConf", FieldType.STRING);
		fields.put("cpuConf", FieldType.STRING);
		fields.put("diskConf", FieldType.STRING);
		fields.put("ipAddress", FieldType.STRING);
		fields.put("floatAddress", FieldType.STRING);
		fields.put("autoCapture", FieldType.STRING);
		fields.put("alive", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(ServerConfVo serverConfVo) {
		getSession().save(serverConfVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(ServerConfVo serverConfVo) {
		getSession().update(serverConfVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<ServerConfVo> serverConfVos) {
		for (ServerConfVo serverConfVo : serverConfVos) {
			getSession().save(serverConfVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param serverConfVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<ServerConfVo> serverConfVos) {
		for (ServerConfVo serverConfVo : serverConfVos) {
			getSession().saveOrUpdate(serverConfVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param serverConfVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(ServerConfVo serverConfVo) {
			getSession().saveOrUpdate(serverConfVo);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param srvCode 服务器编号	 * @return ServerConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public ServerConfVo queryServerConfInfo(String aplCode, String srvCode){
		return (ServerConfVo) getSession().createQuery("from ServerConfVo s where s.aplCode = :aplCode and s.srvCode = :srvCode ")
															.setString("aplCode", aplCode)
															.setString("srvCode", srvCode)
															.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(ServerConfVo serverConfVo) {
		getSession().delete(serverConfVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByUnionKeys(String[] aplCodes, String[] srvCodes) {
		for(int i = 0; i < aplCodes.length && i < srvCodes.length; i++){
			deleteByUnionKey(aplCodes[i], srvCodes[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteByUnionKey(String aplCode, String srvCode) {
		getSession().createQuery("delete from ServerConfVo s where s.aplCode = :aplCode and s.srvCode=:srvCode")
						  .setString("aplCode", aplCode)
						  .setString("srvCode", srvCode)
						  .executeUpdate();
	}
	
	/**
	 * 通过主键查找唯一的一条记录
	 * @param srvCode 服务器编号
	 * @return ServerConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public ServerConfVo findByPrimaryKey(String srvCode){
		return (ServerConfVo) getSession()
				.createQuery("from ServerConfVo s where s.srvCode=:srvCode ")
				.setString("srvCode", srvCode)
				.uniqueResult();
	}
	
	/**
	 * 检查是否为服务器
	 * @param srvCodeOrIp 服务器编号或者IP地址
	 * @return count(*)
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public Long checkExist(String srvCodeOrIp){
		return Long.valueOf(getSession()
				.createQuery("select count(*) from ServerConfVo t where t.srvCode=:srvCodeOrIp or t.ipAddress=:srvCodeOrIp or t.floatAddress=:srvCodeOrIp")
				.setString("srvCodeOrIp", srvCodeOrIp)
				.uniqueResult().toString());
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
	public List<ServerConfVo> queryServerConfList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	t.srvCode as srvCode, ")
			.append("	(case t.loadMode when '0' then '主机' when '1' then '备机' when '2' then 'F5' end) as loadMode, ")
			.append("	t.aplCode as aplCode, ")
			.append("	t.serClass as serClass, ")
			.append("	t.serName as serName, ")
			.append("	t.memConf as memConf, ")
			.append("	t.cpuConf as cpuConf, ")
			.append("	t.diskConf as diskConf, ")
			.append("	t.ipAddress as ipAddress, ")
			.append("	t.floatAddress as floatAddress, ")
			.append("	(case t.autoCapture when '0' then '自动获取' when '1' then '不自动获取' end) as autoCapture) ")
			.append("from ServerConfVo t where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and t." + key + " like :" + key);
					} else {
						hql.append(" and t." + key + " = :" + key);
					}
			}
		}
		hql.append(" order by t." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}

		request.getSession().setAttribute("serverConfList4Export", query.list());
		
		return query.setFirstResult(start).setMaxResults(limit).list();
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
	public List<Map<String,Object>> queryAllServer(String aplCode) {
		
		StringBuilder hql = new StringBuilder();
		hql.append("select s.srv_code as \"srvCode\", ")
			.append("			s.apl_code as \"aplCode\", ")
			.append("			s.ser_class as \"serClass\", ")
			.append("			s.ser_name as \"serName\", ")
			.append("			sr.tran_name as \"tranName\", ")
			.append("			sr.srv_type as \"srvType\" ")
			.append(" from server_conf s left join sys_resrc_trans sr on  s.apl_code = sr.apl_code and s.ser_class = sr.srv_type and s.srv_code = sr.srv_code ")
			.append(" where s.apl_code =:aplCode ")
			.append(" order by s.ser_class, case when sr.tran_name is null then '0' else sr.tran_name end, s.srv_code");
		
		Query query = getSession().createSQLQuery(hql.toString());
		query.setString("aplCode", aplCode);
		//返回
		return query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
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
	public List<Map<String,Object>> queryAllServerAndTran(String aplCode) {
		
		StringBuilder hql = new StringBuilder();
		hql.append(" select rel.apl_code as \"aplCode\", ")
			.append("			case when rel.ser_class = '1' then 'WEB' when rel.ser_class = '2' then 'APP' when rel.ser_class = '3' then 'DB' end as \"serClass\", ")
			.append("			rel.tran_name as \"tranName\", ")
			.append("			wm_concat(case when rel.ser_class = '1' then 'WEB' when rel.ser_class = '2' then 'APP' when rel.ser_class = '3' then 'DB' end || ' ' || rel.tran_name || ' ' || rel.srv_code) as \"combinKey\", ")
			.append("			'(' || case when rel.ser_class = '1' then 'WEB' when rel.ser_class = '2' then 'APP' when rel.ser_class = '3' then 'DB' end || ' ' || rel.tran_name || ' ' || wm_concat(rel.srv_code)  || ')' as \"combinNames\" ")
			.append(" from (select s.srv_code, ")
			.append("					s.apl_code, ")
			.append("					s.ser_class, ")
			.append("					s.ser_name, ")
			.append("					sr.tran_name, ")
			.append("					sr.srv_type ")
			.append(" 			from server_conf s left join sys_resrc_trans sr on  s.apl_code = sr.apl_code and s.ser_class = sr.srv_type and s.srv_code = sr.srv_code ")
			.append(" 			where s.apl_code =:aplCode ")
			.append(" 			order by s.ser_class, case when sr.tran_name is null then '0' else sr.tran_name end, s.srv_code ) rel")
			.append(" group by rel.apl_code, rel.ser_class, rel.tran_name ")
			.append(" order by rel.apl_code, rel.ser_class, rel.tran_name ");
		
		Query query = getSession().createSQLQuery(hql.toString());
		query.setString("aplCode", aplCode);
		//返回
		return query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
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
	public List<Map<String, String>> queryAllSerClass(String aplCode) {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct s.ser_class as \"serClass\" from server_conf s where 1=1 ")
			.append(" and s.apl_code =:aplCode")
			.append(" order by s.SER_CLASS");
		
		return getSession().createSQLQuery(sql.toString())
				.setString("aplCode", aplCode)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
	}

	/**
	 * 查询配置表所有的系统编号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryAplCodes(){
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from ServerConfVo t order by t.aplCode ").list();
	}
	
	/**
	 * 指定系统代码查询对应的主机列表
	 * @param aplCode
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object querySysSrvCode(String aplCode){
		return getSession().createQuery(
				"select distinct new map(t.srvCode as srvCode) from ServerConfVo t where t.aplCode = :aplCode ")
									.setString("aplCode", aplCode)
									.list();
	}
	
}///:~

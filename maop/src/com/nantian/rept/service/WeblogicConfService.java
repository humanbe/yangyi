package com.nantian.rept.service;

import java.util.HashMap;
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
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.WeblogicConfVo;

@Service
@Repository
public class WeblogicConfService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(WeblogicConfService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	public WeblogicConfService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("ipAddress", FieldType.STRING);
		fields.put("serverName", FieldType.STRING);
		fields.put("serverJdbcName", FieldType.STRING);
		fields.put("clusterServer", FieldType.STRING);
		fields.put("weblogicFlg", FieldType.STRING);
		fields.put("weblogicPort", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param weblogicConfVo
	 */
	@Transactional(value = "maoprpt")
	public void save(WeblogicConfVo weblogicConfVo) {
		getSession().save(weblogicConfVo);
	}
	
	/**
	 * 更新.
	 * @param weblogicConfVo
	 */
	@Transactional(value = "maoprpt")
	public void update(WeblogicConfVo weblogicConfVo) {
		getSession().update(weblogicConfVo);
	}

	/**
	 * 批量保存.
	 * @param weblogicConfVo
	 */
	@Transactional(value = "maoprpt")
	public void save(Set<WeblogicConfVo> weblogicConfVos) {
		for (WeblogicConfVo weblogicConfVo : weblogicConfVos) {
			getSession().save(weblogicConfVo);
		}
	}
	
	/**
	 * 查询系统代码与IP对应的列表
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryConfigIps(String aplCode){
		return getSession().createQuery(
				"select distinct new map(t.ipAddress as ipAddress) from WeblogicConfVo t where t.aplCode = :aplCode order by t.ipAddress")
									.setString("aplCode", aplCode)
									.list();
	}

	/**
	 * 查询系统代码与系统全称对应的列表
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object querySysAplNames() {
		return getSession().createQuery(
				"select new map(t.appsysCode as aplCode, t.systemname as aplAllName) from ViewAppInfoVo t order by t.appsysCode").list();
	}

	
	
	/**
	 * 查询weblogic数据导入配置信息列表
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @param request
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryWeblogicConfList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder sql = new StringBuilder();
		sql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	t.ipAddress as ipAddress, ")
			.append("	t.serverName as serverName, ")
			.append("	t.serverJdbcName as serverJdbcName, ")
			.append("	(case t.weblogicFlg when '1' then '不导入' when '0' then '定时导入' end) as weblogicFlg, ")
			.append("	t.clusterServer as clusterServer, ")
			.append("	t.weblogicPort as weblogicPort) ")
			.append("from WeblogicConfVo t where 1=1 ");
		
		for(String key : params.keySet()){
			if(fields.get(key).equals(FieldType.STRING)){
				sql.append(" and t." + key + " like :" + key);
			}else{
				sql.append(" and t." + key + " = :" + key);
			}
		}
		
		sql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(sql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("weblogicConfList4Export", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 根据主键查询实体
	 * @param aplCode 系统编号
	 * @param ipAddress ip地址
	 * @param serverName 服务名
	 * @param weblogicPort 端口号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public WeblogicConfVo queryWeblogicConfInfo(String aplCode, String ipAddress,
			String serverName, String weblogicPort) {
		return (WeblogicConfVo) getSession().createQuery(
				"from WeblogicConfVo t where t.aplCode=:aplCode and t.ipAddress=:ipAddress and t.serverName=:serverName and t.weblogicPort=:weblogicPort")
																.setString("aplCode", aplCode)
																.setString("ipAddress", ipAddress)
																.setString("serverName", serverName)
																.setString("weblogicPort", weblogicPort)
																.uniqueResult();
	}

	/**
	 * 根据主键数组删除
	 * @param aplCodes 系统编号数组
	 * @param ipAddresses ip地址数组
	 * @param serverNames 服务名数组
	 * @param weblogicPorts 端口号数组
	 */
	@Transactional(value = "maoprpt")
	public void deleteByUnionKeys(String[] aplCodes, String[] ipAddresses,
			String[] serverNames, String[] weblogicPorts) {
		for(int i = 0; i < aplCodes.length && i< ipAddresses.length && i < serverNames.length && i < weblogicPorts.length; i++){
			deleteByUnionKey(aplCodes[i], ipAddresses[i], serverNames[i], weblogicPorts[i]);
		}
		
	}

	/**
	 * 根据主键删除
	 * @param aplCode 系统编号
	 * @param ipAddress ip地址
	 * @param serverName 服务名
	 * @param weblogicPort 端口号
	 */
	@Transactional(value = "maoprpt")
	public void deleteByUnionKey(String aplCode, String ipAddress,
			String serverName, String weblogicPort) {
		getSession().createQuery(
				"delete from WeblogicConfVo t where t.aplCode = :aplCode and t.ipAddress=:ipAddress and t.serverName=:serverName and t.weblogicPort=:weblogicPort")
						  .setString("aplCode", aplCode)
						  .setString("ipAddress", ipAddress)
						  .setString("serverName", serverName)
						  .setString("weblogicPort", weblogicPort)
						  .executeUpdate();
		
	}
	
	/**
	 * 查询配置表所有的系统编号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryAplCodes(){
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from WeblogicConfVo t order by t.aplCode ").list();
	}


		/**
		 * 根据应用系统编号查询科目三级分类
		 * @return
		 */
		@Transactional(readOnly = true, value = "maoprpt")
		public Object queryWeblogicServernameForRpt(String appsysCode,String itemName) {
			StringBuilder sql = new StringBuilder();
		if(itemName.equals("WBLG_JDBC")){
			sql.append("select distinct  case ")
			.append("	 when wc.server_jdbc_name is not null ")
			.append("	then wc.server_name||'('||wc.server_jdbc_name||')' ")
			.append(" 	else wc.server_name ")
			.append(" end as \"valueField\" ,")
			.append(" case ")
			.append("	 when wc.server_jdbc_name is not null ")
			.append("	then wc.server_name||'('||wc.server_jdbc_name||')' ")
			.append(" 	else wc.server_name ")
			.append(" end as \"displayField\" ")
			.append(" from weblogic_conf wc")
		.append(" where  wc.apl_code=? ");
		}else{
			sql.append("select  distinct  wc.server_name as \"valueField\" ,")
			.append("  wc.server_name as \"displayField\" ")
			.append(" from weblogic_conf wc")
		.append(" where  wc.apl_code=? ");
		}
			
			return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
					.setString(0,appsysCode).list();
		}
	
}

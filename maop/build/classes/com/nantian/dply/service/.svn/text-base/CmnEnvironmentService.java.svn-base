package com.nantian.dply.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.axis2.AxisFault;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.exception.ConstraintViolationException;
import org.jdom2.Document;
import org.jdom2.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.dply.vo.AppGroupServerVo;
import com.nantian.dply.vo.AppGroupVo;
import com.nantian.dply.vo.CmnEnvironmentVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
/**
 * 应用系统环境管理
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class CmnEnvironmentService {

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	@Autowired
	 private SecurityUtils securityUtils; 
	@Autowired
	private AppInfoService appInfoService;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法

	 */
	public CmnEnvironmentService() {
		fields.put("appsysCode", FieldType.STRING);
		fields.put("environmentCode", FieldType.STRING);
		fields.put("environmentName", FieldType.STRING);
		fields.put("environmentType", FieldType.STRING);
		fields.put("describe", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
		fields.put("serverGroup", FieldType.STRING);
		fields.put("paramValue", FieldType.STRING);
		fields.put("serverValue", FieldType.STRING);
	}

	/**
	 * 保存环境数据.
	 * 
	 * @param cmnEnvironmentVo
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public void save(CmnEnvironmentVo cmnEnvironmentVo) throws ConstraintViolationException,SQLException {
		String serverIpJson = cmnEnvironmentVo.getServerValue();
		String groupJson=cmnEnvironmentVo.getGroupValue();
		String appsysCode = cmnEnvironmentVo.getAppsysCode();
		String environmentCode = cmnEnvironmentVo.getEnvironmentCode();
		JSONArray arrayparam = JSONArray.fromObject(serverIpJson);
		List<String> serverIplist = (List<String>) JSONArray.toCollection(arrayparam, String.class);
		List<AppGroupServerVo> serverIpList = new ArrayList<AppGroupServerVo>();
		AppGroupServerVo vo = null;
		for (String mapparam : serverIplist) {
			vo = new AppGroupServerVo();
			vo.setAppsysCode(appsysCode);
			vo.setEnvironmentCode(environmentCode);
			vo.setServerGroup(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			vo.setServerIp(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[0]));
			vo.setAppsysCode(appsysCode);
			vo.setEnvironmentCode(environmentCode);
			serverIpList.add(vo);
		}
		
		JSONArray groupparam = JSONArray.fromObject(groupJson);
		List<String> grouplist = (List<String>) JSONArray.toCollection(groupparam, String.class);
		List<AppGroupVo> groupList = new ArrayList<AppGroupVo>();
		AppGroupVo groupvo = null;
		for (String mapparam : grouplist) {
			groupvo = new AppGroupVo();
			groupvo.setAppsysCode(appsysCode);
			groupvo.setEnvironmentCode(environmentCode);
			groupvo.setServerGroup(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[0]));
			groupvo.setFloatIp(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[3]));
			groupvo.setServerUse(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			groupvo.setShareStoreFlag(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[2]));
			groupList.add(groupvo);
		}
		
		String sqlEnv = "delete cmn_environment where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "'";
		getSession().createSQLQuery(sqlEnv).executeUpdate();
		
		String sqlgroup = "delete cmn_app_group where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "'";
		getSession().createSQLQuery(sqlgroup).executeUpdate();
		
		String sqlIp = "delete  cmn_app_group_server where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "' ";
		getSession().createSQLQuery(sqlIp).executeUpdate();
		
		cmnEnvironmentVo.setDeleteFlag("0");
		getSession().save(cmnEnvironmentVo);
		for(AppGroupVo vo2 : groupList){
			vo2.setDeleteFlage("0");
			getSession().save(vo2);
		}
		for (AppGroupServerVo vo1 : serverIpList) {
			vo1.setDeleteFlage("0");
			getSession().save(vo1);
		}
	}

	/**
	 * 保存分组数据
	 * 
	 * @param AppGroupVo
	 *            应用系统资源
	 */

	@Transactional
	public void saveGroup(AppGroupVo appGroupVo) {
		appGroupVo.setDeleteFlage("0");
		getSession().save(appGroupVo);

	}

	/**
	 * 修改保存.
	 * 
	 * @param cmnEnvironmentVo
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public void edit(CmnEnvironmentVo cmnEnvironmentVo) throws SQLException {
		String serverIpJson = cmnEnvironmentVo.getServerValue();
		String appsysCode = cmnEnvironmentVo.getAppsysCode();
		String groupJson=cmnEnvironmentVo.getValue();
		String environmentCode = cmnEnvironmentVo.getEnvironmentCode();
		// di2biaodan
		List<AppGroupServerVo> serverIpList = new ArrayList<AppGroupServerVo>();
		List<String> GroupList = new ArrayList<String>();
		List<String> ipList = new ArrayList<String>();
		AppGroupServerVo vo = null;
		JSONArray arrayparam = JSONArray.fromObject(serverIpJson);
		List<String> serverIplist = (List<String>) JSONArray.toCollection(arrayparam, String.class);
		for (String mapparam : serverIplist) {
			vo = new AppGroupServerVo();
			vo.setAppsysCode(appsysCode);
			vo.setEnvironmentCode(environmentCode);
			vo.setServerGroup(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			vo.setServerIp(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[0]));
			vo.setAppsysCode(appsysCode);
			vo.setEnvironmentCode(environmentCode);
			GroupList.add(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			ipList.add(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[0]));
			serverIpList.add(vo);
		}
		
		JSONArray groupparam = JSONArray.fromObject(groupJson);
		List<String> grouplist = (List<String>) JSONArray.toCollection(groupparam, String.class);
		List<AppGroupVo> groupList = new ArrayList<AppGroupVo>();
		AppGroupVo groupvo = null;
		for (String mapparam : grouplist) {
			groupvo = new AppGroupVo();
			groupvo.setAppsysCode(appsysCode);
			groupvo.setEnvironmentCode(environmentCode);
			groupvo.setServerGroup(mapparam.split(Constants.SPLIT_SEPARATEOR)[0]);
			groupvo.setFloatIp(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[3]));
			groupvo.setServerUse(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[1]));
			groupvo.setShareStoreFlag(ComUtil.checkNull(mapparam.split(Constants.SPLIT_SEPARATEOR)[2]));
			groupList.add(groupvo);
		}
		
		cmnEnvironmentVo.setDeleteFlag("0");
		String sqlEnv = "delete cmn_environment where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "'";
		getSession().createSQLQuery(sqlEnv).executeUpdate();
		
		String sqlgroup = "delete cmn_app_group where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "'";
		getSession().createSQLQuery(sqlgroup).executeUpdate();
		
		String sqlIp = "delete  cmn_app_group_server where appsys_code = '"
				+ appsysCode + "' and environment_code = '" + environmentCode
				+ "' ";
		getSession().createSQLQuery(sqlIp).executeUpdate();

		getSession().save(cmnEnvironmentVo);

		for(AppGroupVo vo3 : groupList){
			vo3.setDeleteFlage("0");
			getSession().save(vo3);
		}
		for (AppGroupServerVo vo1 : serverIpList) {
			vo1.setDeleteFlage("0");
			getSession().save(vo1);
		}
	}

	/**
	 * 修改根据ID批量删除分组和服务器Ip表.
	 * 
	 * @param appsysCodes
	 * @param serverGroups
	 */

	@Transactional
	public void deleteByUnionKeys(String[] appsysCodes, String[] serverGroups,
			String[] environmentCodes) throws SQLException {
		for (int i = 0; i < appsysCodes.length && i < serverGroups.length; i++) {
			deleteByUnionKey(appsysCodes[i], serverGroups[i]);

		}
		for (int j = 0; j < appsysCodes.length && j < serverGroups.length
				&& j < environmentCodes.length; j++) {
			deleteByUnionKeyServer(appsysCodes[j], serverGroups[j],
					environmentCodes[j]);
		}
	}

	/**
	 * 根据ID批量删除分组.
	 * 
	 * @param appsysCodes
	 * @param serverGroups
	 */

	@Transactional
	public void deleteGroupByUnionKeys(String[] appsysCodes,
			String[] serverGroups) throws SQLException {
		for (int i = 0; i < appsysCodes.length && i < serverGroups.length; i++) {
			deleteByUnionKey(appsysCodes[i], serverGroups[i]);
		}
	}

	/**
	 * 根据ID删除服务器.
	 * 
	 * @param appsysCodes
	 * @param serverGroups
	 * @param environmentCode
	 */
	@Transactional
	private void deleteByUnionKeyServer(String appsysCode, String serverGroup,
			String environmentCode) throws SQLException {
		getSession()
				.createQuery(
						"delete from AppGroupServerVo s where s.appsysCode = :appsysCode and s.serverGroup=:serverGroup and s.environmentCode=:environmentCode")
				.setString("appsysCode", appsysCode)
				.setString("serverGroup", serverGroup)
				.setString("environmentCode", environmentCode).executeUpdate();
	}

	/**
	 * 根据ID删除分组.
	 * 
	 * @param appsysCodes
	 * @param serverGroups
	 */
	@Transactional
	private void deleteByUnionKey(String appsysCode, String serverGroup)
			throws SQLException {
		getSession()
				.createQuery(
						"delete from AppGroupVo s where s.appsysCode = :appsysCode and s.serverGroup=:serverGroup")
				.setString("appsysCode", appsysCode)
				.setString("serverGroup", serverGroup).executeUpdate();
	}

	/**
	 * 删除.
	 * 
	 * @param cmnEnvironmentVo
	 */
	@Transactional
	public void delete(CmnEnvironmentVo cmnEnvironmentVo) {
		getSession().delete(cmnEnvironmentVo);
	}

	/**
	 * 查询服务器分组关系表
	 * 
	 * @return
	 * @param serverIp
	 * @param appsysCode
	 * @throws IOException
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public List<AppGroupServerVo> queryAppGroupServer(String encironmentCode,
			String appsysCode) throws SQLException {
		return getSession().createQuery(
				"from AppGroupServerVo a where  appsysCode='" + appsysCode
						+ "' and environmentCode='" + encironmentCode + "'")
				.list();
	}

	/**
	 * 查询环境表数据

	 * 
	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)
			throws SQLException {
		String username = securityUtils.getUser().getUsername();
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\",")
				.append("o.environmentCode as \"environmentCode\", ")
				.append(" o.environmentName as \"environmentName\", ")
				.append("o.environmentType as \"environmentType\", ")
				.append("o.describe as \"describe\", ")
				.append(" o.deleteFlag as \"deleteFlag\" ")
				.append(" from (  ")
				.append(" select b.appsys_code as appsysCode,  ")
				.append(" b.environment_code as environmentCode,")
				.append("   b.environment_name as environmentName,  ")
				.append("  t.sub_item_name as environmentType,  ")
				.append("  b.describe as describe,  ")
				.append(" b.delete_flag as deleteFlag  ")
				.append(" from CMN_ENVIRONMENT b ,jeda_sub_item t ,cmn_user_env m where t.sub_item_value=b.environment_type and t.item_id = 'SYSTEM_ENVIRONMENT' ")
				.append(" and b.environment_type=m.env  ")
				.append(" and m.user_id='"+username+"'  ")
				.append("  ) o where deleteFlag = 0 and o.appsysCode in :sysList ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) throws SQLException {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CmnEnvironmentVo b where 1=1 and b.deleteFlag='0' and b.appsysCode in :sysList");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and b." + key + " like :" + key);
				} else {
					hql.append(" and b." + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
		return Long.valueOf(query.uniqueResult().toString());
	}
	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long serverCount(Map<String, Object> params) throws SQLException {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from ServersInfoVo b where 1=1 and b.deleteFlag='0' ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and b." + key + " like :" + key);
				} else {
					hql.append(" and b." + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return Long.valueOf(query.uniqueResult().toString());
	}
	/**
	 * 查询分组数据
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryServerGroup(Integer start,
			Integer limit, String sort, String dir, String appsysCode, String environmentCode)
			throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append("   select distinct p.environmentCode as \"environmentCode\",")
				.append("  p.appsysCode    as \"appsysCode\", ")
				.append("  p.serverGroup   as \"serverGroup\", ")
				.append("  p.shareStoreFlag as \"shareStoreFlag\", ")
				.append("  p.serverUse   as \"serverUse\",")
				.append("  p.floatIp   as \"floatIp\",")
				.append("  p.checked   as \"checked\" ")
				.append("  from (select t.appsys_code as appsysCode,t.environment_code as environmentCode, ")
				.append("  o.sub_item_name as serverGroup,t.share_store_flag as shareStoreFlag,")
				.append("  t.server_use as serverUse,t.float_ip as floatIp,")
				.append("  (case when (select count(*) from jeda_sub_item j  where j.sub_item_value = t.server_group) > 0 then 'true' else 'false' end) as checked")
				.append(" from jeda_sub_item o  left join cmn_app_group t on o.sub_item_value =t.server_group")
				.append(" and t.appsys_code = :appsysCode and t.environment_code = :environmentCode where o.ITEM_ID = 'SERVER_GROUP') p where 1 = 1");
		
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("environmentCode", environmentCode);
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询分组数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countGroup(Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from AppGroupServerVo b where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and b." + key + " like :" + key);
				} else {
					hql.append(" and b." + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询服务器分组数据

	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryServerIp(Integer start,
			Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder sql = new StringBuilder();
		sql.append("select o.serverIp as \"serverIp\", ")
				.append("o.appsysCode as \"appsysCode\" ")
				.append(" from(select b.server_ip as serverIp, ")
				.append("  b.appsys_code as appsysCode ")
				.append(" from cmn_app_group_server b)  o where 1=1");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询分组数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countIp(Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from AppGroupServerVo b where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and b." + key + " like :" + key);
				} else {
					hql.append(" and b." + key + " = :" + key);
				}
			}
		}

		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 查询环境表数据

	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param appsysCode
	 * @param environmentCode
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryEnv(String appsysCode, String environmentCode) {

		StringBuilder sql = new StringBuilder();
		sql.append("select o.appsysCode as \"appsysCode\", ")
				.append(" o.environmentCode as \"environmentCode\", ")
				.append(" o.environmentName as \"environmentName\", ")
				.append(" o.environmentType as \"environmentType\", ")
				.append(" o.describe as \"describe\", ")
				.append(" o.deleteFlag as \"deleteFlag\" ")
				.append(" from ( ")
				.append("select b.appsys_code as appsysCode, ")
				.append(" b.environment_code as environmentCode, ")
				.append(" b.environment_name as environmentName, ")
				.append(" b.environment_type as environmentType, ")
				.append(" b.describe as describe, ")
				.append(" b.delete_flag as deleteFlag ")
				.append(" from cmn_environment b ) o where o.appsysCode=:appsysCode and o.environmentCode=:environmentCode");
		return getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("environmentCode", environmentCode).uniqueResult();
	}

	/**
	 * 删除环境表数据

	 * 
	 * 
	 * @param appsysCodes
	 * @param environmentCodes
	 * @return
	 */
	@Transactional(readOnly = true)
	public void deleteByIds(String[] appsysCodes, String[] environmentCodes) {
		for (int i = 0; i < appsysCodes.length && i < environmentCodes.length; i++) {
			deleteById(appsysCodes[i], environmentCodes[i]);
		}
	}

	/**
	 * 根据系统代码和环境ID删除.
	 * 
	 * @param appsysCode
	 * @param environmentCode
	 */
	private void deleteById(String appsysCode, String environmentCode) {
		String sql = "update cmn_environment set delete_flag='1'   where appsys_code='"
				+ appsysCode
				+ "' and  environment_code='"
				+ environmentCode
				+ "' ";
		getSession().createSQLQuery(sql).executeUpdate();
		String sql1 = "update cmn_app_group set delete_flag='1'   where appsys_code='"
				+ appsysCode
				+ "' and  environment_code='"
				+ environmentCode
				+ "' ";
		getSession().createSQLQuery(sql1).executeUpdate();
		String sql2 = "update cmn_app_group_server set delete_flag='1'   where appsys_code='"
				+ appsysCode
				+ "' and  environment_code='"
				+ environmentCode
				+ "' ";
		getSession().createSQLQuery(sql2).executeUpdate();
		
	}

	/**
	 * 查询数据字典所有信息.
	 * 
	 * @param typicalCapaAnaArr
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public Map<String, String> findMap() {
		List<Map<String, String>> itemList = new ArrayList<Map<String, String>>();
		Map<String, String> itemMap = new HashMap<String, String>();

		StringBuilder sql = new StringBuilder();
		sql.append("   select name as \"name\", value as \"value\"  from ( ")
				.append("   select T.ITEM_ID || T.SUB_ITEM_VALUE as name, T.SUB_ITEM_NAME as value from jeda_sub_item t) o");
		SQLQuery query = getSession().createSQLQuery(sql.toString());
		itemList = query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.list();
		for (Map<String, String> map : itemList) {
			itemMap.put(map.get("name"), map.get("value"));
		}
		return itemMap;
	}

	/**
	 * 查询树状数据
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param appsysCode
	 * @param environmentCode
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryTree(String appsysCode,
			String environmentCode) {
		StringBuilder sql = new StringBuilder();
		sql.append(
				"select distinct appsys_code as \"appsysCode\",server_group as \"serverGroup\", environment_code as \"environmentCode\" from ( ")
				.append(" select t.appsys_code , ")
				.append(" t.server_group,t.environment_code ")
				.append("from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code  and  t.environment_code =s.environment_code) where appsys_code =:appsysCode and environment_code=:environmentCode");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("environmentCode", environmentCode);
		return query.list();
	}

	/**
	 * 查询树状数据下的服务器(修改时)
	 * 
	 * @param dataList
	 * @return
	 */
	public List<JSONObject> getJosnObjectForTree(
			List<Map<String, Object>> dataList) {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject cjo = null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;
		Map<String, String> itemMap = this.findMap();
		for (Map<String, Object> map : dataList) {
			cjsonList = new ArrayList<JSONObject>();
			cjo = new JSONObject();
			// cjo.put("id", map.get("serverGroup"));
			cjo.put("text", itemMap.get("SERVER_GROUP".concat(map.get(
					"serverGroup").toString())));
			cjo.put("iconCls", "node-treenode");
			cjo.put("isType", true);
			cjo.put("checked", false);
			List<Map<String, Object>> serverList = queryChildren(
					map.get("appsysCode").toString(), map.get("serverGroup")
							.toString(), map.get("environmentCode").toString());
			for (Map<String, Object> scMap1 : serverList) {
				if (scMap1.get("serverIp") != null) {
					cjo1 = new JSONObject();
					cjo1.put("text", scMap1.get("serverIp"));
					cjo1.put("iconCls", "node-treenode");
					cjo1.put("leaf", true);
					cjo1.put("checked", false);
					cjsonList.add(cjo1);
				}
			}
			if (cjo1 == null) {
				cjo.put("leaf", true);
			} else {
				cjo.put("leaf", false);
			}
			cjo.put("children", JSONArray.fromObject(cjsonList));

			sysJsonList.add(cjo);
		}

		return sysJsonList;
	}

	/**
	 * 查询服务器总表数据
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param appsysCode
	 * @param serverIp
	 * @param request
	 * @return
	 */
	@Transactional
	public Object queryServersInfo(Integer limit, Integer start, String sort,
			String dir, String appsysCode, String serverIp,
			HttpServletRequest request) {
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.serverIp as \"serverIp\",")
				.append("o.serverName as \"serverName\",  ")
				.append("o.bsaAgentFlag as \"bsaAgentFlag\", ")
				.append("o.floatingIp as \"floatingIp\",  ")
				.append("o.osType as \"osType\", ")
				.append("o.appsysCode as \"appsysCode\", ")
				.append("o.deleteFlag as \"deleteFlag\" ")
				.append("from   ( SELECT SERVER_IP as serverIp,")
				.append("SERVER_NAME as serverName, ")
				.append("BSA_AGENT_FLAG as bsaAgentFlag,")
				.append("FLOATING_IP as floatingIp, ")
				.append("OS_TYPE as osType,")
				.append("APPSYS_CODE as appsysCode,")
				.append("DELETE_FLAG as deleteFlag ")
				.append("FROM CMN_SERVERS_INFO) o where o.deleteFlag='0' and o.bsaAgentFlag='1'");
	
			sql.append("and o.serverIp like  '" + serverIp + "%'");
	
			sql.append(" and o.appsysCode like  '" + appsysCode + "%'");
		

		sql.append(" order by o." + sort + " " + dir);

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		;

		return query.setMaxResults(limit).setFirstResult(start).list();
	}

	/**
	 * 查询树状结构下的服务器数据(修改时)
	 * 
	 * @param serverGroup
	 * @param appsysCode
	 * @param environmentCode
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryChildren(String appsysCode,
			String serverGroup, String environmentCode) {

		StringBuilder sql = new StringBuilder();
		sql.append(
				"select distinct o.appsys_code as \"appsysCode\",o.server_group as \"serverGroup\",o.SERVER_IP as \"serverIp\" from ( ")
				.append(" select t.appsys_code , s.SERVER_IP,t.server_group,t.environment_code")
				.append(" from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code  and    t.environment_code= s.environment_code ")
				.append("  and s.appsys_code =:appsysCode and s.server_group =:serverGroup and s.environment_code=:environmentCode) o,cmn_servers_info f ")
				.append(" where o.SERVER_IP = f.SERVER_IP  and f.delete_flag = '0' ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("serverGroup", serverGroup)
				.setString("environmentCode", environmentCode);

		return query.list();
	}

	/**
	 * 查询树状数据下的服务器(创建时)
	 * 
	 * @param dataList
	 * @return
	 */
	public List<JSONObject> getCreateJosnObjectForTree(
			List<Map<String, Object>> dataList) {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject cjo = null;
		List<JSONObject> cjsonList = null;
		JSONObject cjo1 = null;
		Map<String, String> itemMap = this.findMap();
		for (Map<String, Object> map : dataList) {
			cjsonList = new ArrayList<JSONObject>();
			cjo = new JSONObject();
			// cjo.put("id", map.get("serverGroup"));
			cjo.put("text", itemMap.get("SERVER_GROUP".concat(map.get(
					"serverGroup").toString())));
			cjo.put("iconCls", "node-treenode");
			cjo.put("isType", true);
			cjo.put("checked", false);
			List<Map<String, Object>> serverList = queryCreateChildren(
					map.get("appsysCode").toString(), map.get("serverGroup")
							.toString());
			for (Map<String, Object> scMap1 : serverList) {
				if (scMap1.get("serverIp") != null) {
					cjo1 = new JSONObject();
					cjo1.put("text", scMap1.get("serverIp"));
					cjo1.put("iconCls", "node-treenode");
					cjo1.put("leaf", true);
					cjo1.put("checked", false);
					cjsonList.add(cjo1);
				}
			}
			if (cjo1 == null) {
				cjo.put("leaf", true);
			} else {
				cjo.put("leaf", false);
			}
			cjo.put("children", JSONArray.fromObject(cjsonList));

			sysJsonList.add(cjo);
		}

		return sysJsonList;
	}

	/**
	 * 查询树状结构下的服务器数据(创建时)
	 * 
	 * @param appsysCode
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryCreateTree(String appsysCode,
			String environmentCode) {
		StringBuilder sql = new StringBuilder();
		sql.append(
				"select distinct appsys_code as \"appsysCode\",server_group as \"serverGroup\", environment_code as \"environmentCode\" from ( ")
				.append(" select t.appsys_code , ")
				.append(" t.server_group,t.environment_code ")
				.append("from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code  and  t.environment_code =s.environment_code) where appsys_code =:appsysCode and environment_code=:environmentCode");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("environmentCode", environmentCode);
		return query.list();
	}

	/**
	 * 查询树状结构下的服务器数据(创建时)
	 * 
	 * @param serverGroup
	 * @param appsysCode
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryCreateChildren(String appsysCode,
			String serverGroup) {

		StringBuilder sql = new StringBuilder();
		sql.append(
				"select distinct o.appsys_code as \"appsysCode\",o.server_group as \"serverGroup\",o.SERVER_IP as \"serverIp\" from ( ")
				.append(" select t.appsys_code , s.SERVER_IP,t.server_group,t.environment_code")
				.append(" from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code  and    t.environment_code= s.environment_code ")
				.append("  and t.appsys_code =:appsysCode and t.server_group =:serverGroup ) o,cmn_servers_info f ")
				.append(" where o.SERVER_IP = f.SERVER_IP  and f.delete_flag = '0' ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsysCode", appsysCode)
				.setString("serverGroup", serverGroup);

		return query.list();
	}

	/**
	 * 同步brpm.
	 * 
	 */
	public void synBRPM(List<String> list) throws BrpmInvocationException,
			Exception {
		List<AppGroupServerVo> resrcList = new ArrayList<AppGroupServerVo>();
		List<AppGroupServerVo> envlist = null;
		for (String record : list) {
			String environmentCode = record.split(Constants.SPLIT_SEPARATEOR)[0];
			String AppsysCode = record.split(Constants.SPLIT_SEPARATEOR)[1];
			envlist = queryAppGroupServer(environmentCode, AppsysCode);

			for (AppGroupServerVo l : envlist) {
				resrcList.add(l);
			}
		}
		List<String> groupList = null;
		List<String> serverIpList = null;
		for (int i = 0; i < resrcList.size(); i++) {
			groupList = new ArrayList<String>();
			serverIpList = new ArrayList<String>();
			String appName = resrcList.get(i).getAppsysCode();
			String envCode = resrcList.get(i).getEnvironmentCode();
			String groupName = "";
			String groupName1="";
			if (resrcList.get(i).getServerGroup().equals("1")) {
				groupName = appName + "_" + "WEB";
			}
			if (resrcList.get(i).getServerGroup().equals("2")) {
				groupName = appName + "_" + "APP";
			}
			if (resrcList.get(i).getServerGroup().equals("3")) {
				groupName = appName + "_" + "DB";
			}
			groupList.add(groupName);
			String serverName = resrcList.get(i).getServerIp();
			serverIpList.add(serverName);
			List<String> getEnvIdList = null;
			List<String> getServerIdList = null;
			List<String> getGroupEnvIdList = null;
			List<String> EnvIdList3=null;
			List<String> getEnvIdList1 = new ArrayList<String>();
			List<String> getEnvIdList2 = new ArrayList<String>();
			List<String> getGroupIdList1 = new ArrayList<String>();
			List<String> getGroupIdList2 = new ArrayList<String>();
			String envId = "";
			String serversId = "";
			String groupId = "";
			String serversIds = "";
			//环境
			String envXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS,"{ \"filters\": { \"name\":\"" + envCode + "\" }}");
			if (envXml == null) {
				brpmService.postMethod(BrpmConstants.KEYWORD_ENVIRONMENTS,"<environment><name>" + envCode + "</name></environment>");
				String env1Xml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS,"{ \"filters\": { \"name\":\"" + envCode + "\" }}");
				Document envdoc = JDOMParserUtil.xmlParse(env1Xml);
				Element envroot = envdoc.getRootElement();
				List<Element> envaccounts = envroot.getChildren();
				for (Element account : envaccounts) {
					envId = account.getChildText("id");
				}
				//环境没有时候的服务器

				String serverXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS,"{ \"filters\": { \"name\":\"" + serverName + "\" }}");
				if (serverXml == null) {
					brpmService.postMethod(BrpmConstants.KEYWORD_SERVERS,"<server><name>" + serverName+ "</name><environment_ids type=\"array\"><id type=\"integer\">" + envId + "</id></environment_ids></server>");
				} else {
					String serverIps = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS,"{ \"filters\": { \"name\":\"" + serverName + "\" }}");
					Document serverdoc = JDOMParserUtil.xmlParse(serverIps);
					Element serverroot = serverdoc.getRootElement();
					List<Element> serveraccounts = serverroot.getChildren();
					for (Element serveraccount : serveraccounts) {
						String serverId = serveraccount.getChildText("id");
						List<Element> environmentIdList = serveraccount.getChild("environments").getChildren();
						if (environmentIdList.size() > 0) {
							List<Element> envIdAccounts = serveraccount.getChild("environments").getChildren();
							getEnvIdList = new ArrayList<String>();
							for (Element envIdAccount : envIdAccounts) {
								String getEnvId = envIdAccount.getChildText("id");
								getEnvIdList.add(getEnvId);
								String strXml1 = "<server><environment_ids type=\"array\">";
								for (int k = 0; k < getEnvIdList.size(); k++) {
									strXml1 += "<id type=\"integer\">" + getEnvIdList.get(k) + "</id>";
								}
								strXml1 += "<id type=\"integer\">" + envId + "</id>";
								strXml1 += "</environment_ids></server>";
								brpmService.putMethod(BrpmConstants.KEYWORD_SERVERS, serverId,strXml1);
							}
						} else {
							brpmService.putMethod(BrpmConstants.KEYWORD_SERVERS,serverId, "<server><environment_ids type=\"array\"><id type=\"integer\">" + envId + "</id></environment_ids></server>");
						}
					}
				}
				//环境没有时候的分组
				String groupXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS,"{ \"filters\": { \"name\":\"" + groupName + "\" }}");
				if (groupXml == null) {
					brpmService.postMethod(BrpmConstants.KEYWORD_SERVER_GROUPS,"<server_group><name>" + groupName + "</name><environment_ids type=\"array\"><id type=\"integer\">" + envId + "</id></environment_ids></server_group>");
					String groupXml1 = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS,"{ \"filters\": { \"name\":\"" + groupName + "\" }}");
					Document doc = JDOMParserUtil.xmlParse(groupXml1);
					Element root = doc.getRootElement();
					List<Element> accounts = root.getChildren();
					for (Element account : accounts) {
						groupId = account.getChildText("id");
					}
				} else {
					String groups = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS,"{ \"filters\": { \"name\":\"" + groupName + "\" }}");
					Document groupdoc = JDOMParserUtil.xmlParse(groups);
					Element grouproot = groupdoc.getRootElement();
					List<Element> groupaccounts = grouproot.getChildren();
					for (Element groupaccount : groupaccounts) {
						groupId = groupaccount.getChildText("id");
						List<Element> environmentIdList = groupaccount.getChild("environments").getChildren();
						if (environmentIdList.size() > 0) {
							List<Element> envIdAccounts = groupaccount.getChild("environments").getChildren();
							getGroupEnvIdList = new ArrayList<String>();
							for (Element envIdAccount : envIdAccounts) {
								String getEnvId = envIdAccount.getChildText("id");
								getGroupEnvIdList.add(getEnvId);
								String strXml = "<server_group><environment_ids type=\"array\">";
								for (int k = 0; k < getGroupEnvIdList.size(); k++) {
									strXml += "<id type=\"integer\">" + getGroupEnvIdList.get(k) + "</id>";
								}
								strXml += "<id type=\"integer\">" + envId + "</id>";
								strXml += "</environment_ids></server_group>";
								brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS,groupId, strXml);
							}
						} else {
							brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS, groupId,"<server_group><environment_ids type=\"array\"><id type=\"integer\">" + envId + "</id></environment_ids></server_group>");
						}
					}
				}
				/*String servers = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS,"{ \"filters\": { \"name\":\"" + serverName + "\" }}");
				Document doc = JDOMParserUtil.xmlParse(servers);
				Element root = doc.getRootElement();
				List<Element> accounts = root.getChildren();
				for (Element account : accounts) {
					serversId = account.getChildText("id");
				}
				String groups1 = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS,"{ \"filters\": { \"name\":\"" + groupName + "\" }}");
				Document groupdoc1 = JDOMParserUtil.xmlParse(groups1);
				Element grouproot1 = groupdoc1.getRootElement();
				List<Element> groupaccounts1 = grouproot1.getChildren();
				for (Element groupaccount : groupaccounts1) {
					List<Element> serverIdList = groupaccount.getChild("servers").getChildren();
					if (serverIdList.size() > 0) {
						List<Element> serverIdAccounts = groupaccount.getChild("servers").getChildren();
						getServerIdList = new ArrayList<String>();
						for (Element serverIdAccount : serverIdAccounts) {
							String getGroupserverId = serverIdAccount.getChildText("id");
							getServerIdList.add(getGroupserverId);
							String strXml = "<server_group>";
							for (int k = 0; k < getServerIdList.size(); k++) {
								strXml += "<server_ids>" + getServerIdList.get(k) + "</server_ids>";
							}
							strXml += "<server_ids>" + serversId + "</server_ids>";
							strXml += "</server_group>";
							brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS, groupId,strXml);

						}
					} else {
						brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS,groupId, "<server-group><server_ids>" + serversId+ "</server_ids></server-group>");
					}
				}*/
			} else {
				String env1Xml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_ENVIRONMENTS,"{ \"filters\": { \"name\":\"" + envCode + "\" }}");
				Document envdoc = JDOMParserUtil.xmlParse(env1Xml);
				Element envroot = envdoc.getRootElement();
				List<Element> envaccounts = envroot.getChildren();
				for (Element account : envaccounts) {
					envId = account.getChildText("id");
				}
		/*	//往分组和服务器的List中加数据
				for(int b = 0; b < resrcList.size(); b++){
					if(resrcList.get(b).getAppsysCode().equals(appName)){
						
						if (resrcList.get(b).getServerGroup().equals("1")) {
							groupName = appName + "_" + "WEB";
						}
						if (resrcList.get(b).getServerGroup().equals("2")) {
							groupName = appName + "_" + "APP";
						}
						if (resrcList.get(b).getServerGroup().equals("3")) {
							groupName = appName + "_" + "DB";
						} 
						if(!groupList.contains(groupName)) groupList.add(groupName);
						if(!serverIpList.contains(serverName)) serverIpList.add(serverName);
					}
				}*/
				//服务器

				for (int p = 0; p < resrcList.size(); p++) {
					if(resrcList.get(p).getAppsysCode().equals(appName)){
						
						if (resrcList.get(p).getServerGroup().equals("1")) {
							groupName1 = appName + "_" + "WEB";
						}
						if (resrcList.get(p).getServerGroup().equals("2")) {
							groupName1 = appName + "_" + "APP";
						}
						if (resrcList.get(p).getServerGroup().equals("3")) {
							groupName1 = appName + "_" + "DB";
						}
						if(!groupList.contains(groupName1)) groupList.add(groupName1);
						if (brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS, "{ \"filters\": { \"name\":\""+ resrcList.get(p).getServerIp()+ "\" }}") == null) {
							brpmService.postMethod(BrpmConstants.KEYWORD_SERVERS, "<server><name>" + resrcList.get(p).getServerIp() + "</name></server>");
							String serverXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS,"{ \"filters\": { \"name\":\""+ resrcList.get(p).getServerIp() + "\" }}");
							Document doc = JDOMParserUtil.xmlParse(serverXml);
							Element root = doc.getRootElement();
							List<Element> accounts = root.getChildren();
							for (Element account : accounts) {
								serversIds = account.getChildText("id");
								getEnvIdList2.add(serversIds);
								String strXml = "<environment><server_ids type=\"array\">";
								for (int k = 0; k < getEnvIdList2.size(); k++) {
									strXml += "<id type=\"integer\">" + getEnvIdList2.get(k) + "</id>";
								}
								for (int j = 0; j < getEnvIdList1.size(); j++) {
									strXml += "<id type=\"integer\">" + getEnvIdList1.get(j) + "</id>";
								}
								strXml += "</server_ids></environment>";
								brpmService.putMethod(BrpmConstants.KEYWORD_ENVIRONMENTS, envId, strXml);
							}
						} else {
							String serverXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS, "{ \"filters\": { \"name\":\""+ resrcList.get(p).getServerIp() + "\" }}");
							Document doc = JDOMParserUtil.xmlParse(serverXml);
							Element root = doc.getRootElement();
							List<Element> accounts = root.getChildren();
							for (Element account : accounts) {
								String serverId = account.getChildText("id");
								getEnvIdList1.add(serverId);
								String strXml = "<environment><server_ids type=\"array\">";
								for (int j = 0; j < getEnvIdList1.size(); j++) {
									strXml += "<id type=\"integer\">" + getEnvIdList1.get(j) + "</id>";
								}
								for (int h = 0; h < getEnvIdList2.size(); h++) {
									strXml += "<id type=\"integer\">" + getEnvIdList2.get(h) + "</id>";
								}
								strXml += "</server_ids></environment>";
								brpmService.putMethod(BrpmConstants.KEYWORD_ENVIRONMENTS, envId, strXml);
							}
						}
					}
				}
				//分组
				for (int m = 0; m < groupList.size(); m++) {
					if (brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS, "{ \"filters\": { \"name\":\"" + groupList.get(m) + "\" }}") == null) {
						brpmService.postMethod(BrpmConstants.KEYWORD_SERVER_GROUPS, "<server_group><name>" + groupList.get(m) + "</name></server_group>");
						String serverGroupXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS, "{ \"filters\": { \"name\":\"" + groupList.get(m) + "\" }}");
						Document doc = JDOMParserUtil.xmlParse(serverGroupXml);
						Element root = doc.getRootElement();
						List<Element> accounts = root.getChildren();
						for (Element account : accounts) {
							groupId = account.getChildText("id");
							getGroupIdList1.add(groupId);
							String strXml = "<environment><server_group_ids type=\"array\">";
							for (int k = 0; k < getGroupIdList1.size(); k++) {
								strXml += "<id type=\"integer\">" + getGroupIdList1.get(k) + "</id>";
							}
							for (int j = 0; j < getGroupIdList2.size(); j++) {
								strXml += "<id type=\"integer\">" + getGroupIdList2.get(j) + "</id>";
							}
							strXml += "</server_group_ids></environment>";
							brpmService.putMethod(BrpmConstants.KEYWORD_ENVIRONMENTS, envId, strXml);
						}
					} else {
						String serverGroupXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS, "{ \"filters\": { \"name\":\"" + groupList.get(m) + "\" }}");
						Document doc = JDOMParserUtil.xmlParse(serverGroupXml);
						Element root = doc.getRootElement();
						List<Element> accounts = root.getChildren();
						for (Element account : accounts) {
							groupId = account.getChildText("id");
							getGroupIdList2.add(groupId);
							String strXml = "<environment><server_group_ids type=\"array\">";
							for (int j = 0; j < getGroupIdList2.size(); j++) {
								strXml += "<id type=\"integer\">" + getGroupIdList2.get(j) + "</id>";
							}
							for (int k = 0; k < getGroupIdList1.size(); k++) {
								strXml += "<id type=\"integer\">" + getGroupIdList1.get(k) + "</id>";
							}
							strXml += "</server_group_ids></environment>";
							brpmService.putMethod(BrpmConstants.KEYWORD_ENVIRONMENTS, envId, strXml);
						}
					}
				}
			}
			//应用
			String appXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{ \"filters\": { \"name\":\"" + appName + "\" }}");
			if (appXml == null) {
				brpmService.postMethod(BrpmConstants.KEYWORD_APPS,"<app><name>" + appName + "</name></app>");
				String appXml1 = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\"" + appName + "\" }}");
				Document appdoc = JDOMParserUtil.xmlParse(appXml1);
				Element approot = appdoc.getRootElement();
				List<Element> appaccounts = approot.getChildren();
				for (Element account : appaccounts) {
					String appid1 = account.getChildText("id");
					brpmService.saveAppsEnviroment(appid1, envId,appName);
					brpmService.saveAssignedEnvironments(appid1, envId, appName);
				}
			} 
			else{
				String appXml1 = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\"" + appName + "\" }}");
				Document appdoc = JDOMParserUtil.xmlParse(appXml1);
				Element approot = appdoc.getRootElement();
				List<Element> appaccounts = approot.getChildren();
				for (Element account : appaccounts) {
					String appid = account.getChildText("id");
					List<Element> environmentList = account.getChild("environments").getChildren();
					if(environmentList.size()==0){
						brpmService.saveAppsEnviroment(appid, envId,appName);
						brpmService.saveAssignedEnvironments(appid, envId, appName);
					}else{
					List<Element> envs = account.getChild("environments").getChildren();
					EnvIdList3=new ArrayList<String>();
					for(Element env:envs){
						String appEnvId=env.getChildText("id");
						EnvIdList3.add(appEnvId);
						}
					for(int v=0;v<EnvIdList3.size();v++){
						if(!EnvIdList3.contains(envId)){
							brpmService.saveAppsEnviroment(appid, envId,appName);
							brpmService.saveAssignedEnvironments(appid, envId, appName);
							}
						}
					}
				}
			}
			String servers = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVERS,"{ \"filters\": { \"name\":\"" + serverName + "\" }}");
			Document doc = JDOMParserUtil.xmlParse(servers);
			Element root = doc.getRootElement();
			List<Element> accounts = root.getChildren();
			for (Element account : accounts) {
				serversId = account.getChildText("id");
			}
			String groups1 = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_SERVER_GROUPS,"{ \"filters\": { \"name\":\"" + groupName + "\" }}");
			Document groupdoc1 = JDOMParserUtil.xmlParse(groups1);
			Element grouproot1 = groupdoc1.getRootElement();
			List<Element> groupaccounts1 = grouproot1.getChildren();
			for (Element groupaccount : groupaccounts1) {
				List<Element> serverIdList = groupaccount.getChild("servers").getChildren();
				String GroupId=groupaccount.getChildText("id");
				if (serverIdList.size() > 0) {
					List<Element> serverIdAccounts = groupaccount.getChild("servers").getChildren();
					getServerIdList = new ArrayList<String>();
					for (Element serverIdAccount : serverIdAccounts) {
						String getGroupserverId = serverIdAccount.getChildText("id");
						getServerIdList.add(getGroupserverId);
						String strXml = "<server_group><server_ids type=\"array\">";
						for (int k = 0; k < getServerIdList.size(); k++) {
							strXml += "<id type=\"integer\">" + getServerIdList.get(k) + "</id>";
						}
						strXml += "<id type=\"integer\">" + serversId + "</id>";
						strXml += "</server_ids></server_group>";
						brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS, GroupId,strXml);
					}
				} else {
					brpmService.putMethod(BrpmConstants.KEYWORD_SERVER_GROUPS,GroupId, "<server-group><server_ids type=\"array\"><id type=\"integer\">" + serversId+ "</id></server_ids></server-group>");
				}
			}
		}
	}

	/**
	 * 同步bsa.
	 * 
	 */
	public void synBsa(List<String> list) throws AxisFault, Exception {

		List<AppGroupServerVo> bsaList = new ArrayList<AppGroupServerVo>();
		// AppGroupServerVo vo = null;
		List<AppGroupServerVo> envlist = null;
		String envName=null;
		for (String record : list) {
			String environmentCode = record.split(Constants.SPLIT_SEPARATEOR)[0];
			String AppsysCode = record.split(Constants.SPLIT_SEPARATEOR)[1];
			envlist = queryAppGroupServer(environmentCode, AppsysCode);
			envName = environmentCode.substring(environmentCode.indexOf("_")+1,environmentCode.lastIndexOf("_"));
			for (AppGroupServerVo l : envlist) {
				bsaList.add(l);
			}
		}

		// 1.用户登录 LoginServiceClient
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client
				.getBsaCredential();
		String ss = "/按应用系统";
		for (int m = 0; m < bsaList.size(); m++) {
			String AppsysCode = bsaList.get(m).getAppsysCode();
			String ServerGroup = "";
			if (bsaList.get(m).getServerGroup().equals("1")) {
				ServerGroup = "WEB";
			}
			if (bsaList.get(m).getServerGroup().equals("2")) {
				ServerGroup = "APP";
			}
			if (bsaList.get(m).getServerGroup().equals("3")) {
				ServerGroup = "DB";
			}
			String ServerIp = bsaList.get(m).getServerIp();
			// 增加系统ACL
			CLITunnelServiceClient cliClientAppACL = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			// 取父节点/按应用系统信息

			CLITunnelServiceClient cliClientsysapp = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponsesysapp = cliClientsysapp.executeCommandByParamList("StaticServerGroup","groupExists", new String[] { "" + ss + "" });
			String sysapp = (String) cliResponsesysapp.get_return().getReturnValue();
			if (sysapp.equals("true")) {
				// 3.执行cli命令 取应用系统信息

				CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("StaticServerGroup","groupExists", new String[] { "" + ss + "/" + AppsysCode + "" });
				String appinfo = (String) cliResponse.get_return().getReturnValue();
				if (appinfo.equals("true")) {
					// 取服务器分组信息
					CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("StaticServerGroup","groupExists", new String[] { "" + ss + "/" + AppsysCode + "/" + ServerGroup + "" });
					String SerGroup = (String) cliResponse1.get_return().getReturnValue();
					if (SerGroup.equals("true")) {
						// 取该分组下的服务器信息


						CLITunnelServiceClient cliClient4 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponse4 = cliClient4.executeCommandByParamList("Server","listServersInGroup", new String[] { "" + ss + "/" + AppsysCode + "/" + ServerGroup + "" });
						String ser = (String) cliResponse4.get_return().getReturnValue();
						String[] aa = ser.split("\n");
						boolean flag = false;
						for (int j = 0; j < aa.length; j++) {
							if (aa[j].equals(ServerIp)) {
								flag = true;
								break;
							}
						}
						if (flag == false) {
							// 取服务器分组ID "+ss+"/"+AppsysCode+"/"+ServerGroup+"
							CLITunnelServiceClient cliClient5 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
							ExecuteCommandByParamListResponse cliResponse5 = cliClient5.executeCommandByParamList("ServerGroup","groupNameToId", new String[] { "" + ss + "/" + AppsysCode + "/" + ServerGroup + "" });
							String SerGroupId = (String) cliResponse5.get_return().getReturnValue();
							// 创建服务器							CLITunnelServiceClient cliClient6 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
							ExecuteCommandByParamListResponse cliResponse6 = cliClient6.executeCommandByParamList("StaticServerGroup","addServerToServerGroupByName",new String[] {"" + SerGroupId + "","" + ServerIp + "" });
							// 增加服务器ACL
							cliClientAppACL.executeCommandByParamList("Server","applyAclPolicy", new String[] {"" + ServerIp + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
						}
					} else {
						// 取系统ID
						CLITunnelServiceClient cliClientsys = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponsesys = cliClientsys.executeCommandByParamList("ServerGroup","groupNameToId", new String[] { "" + ss + "/" + AppsysCode + "" });
						String sysId = (String) cliResponsesys.get_return().getReturnValue();
						// 创建服务器分组						CLITunnelServiceClient cliClientserGoup = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseserGoup = cliClientserGoup.executeCommandByParamList("StaticServerGroup","createServerGroup", new String[] {"" + ServerGroup + "","" + sysId + "" });
						String serGoupId = (String) cliResponseserGoup.get_return().getReturnValue();
						// 增加服务器分组ACL
						cliClientAppACL.executeCommandByParamList("ServerGroup", "applyAclPolicy", new String[] {"" + ss + "/" + AppsysCode + "/" + ServerGroup + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
						// 添加服务器到分组
						CLITunnelServiceClient cliClientser = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
						ExecuteCommandByParamListResponse cliResponseser = cliClientser.executeCommandByParamList("StaticServerGroup","addServerToServerGroupByName",new String[] { "" + serGoupId + "","" + ServerIp + "" });
						// 增加服务器ACL
						cliClientAppACL.executeCommandByParamList("Server","applyAclPolicy", new String[] {"" + ServerIp + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
					}
				} else {
					// 取父节点按应用系统


					CLITunnelServiceClient cliClient22 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse22 = cliClient22.executeCommandByParamList("ServerGroup","groupNameToId", new String[] { "" + ss + "" });
					String sysappId = (String) cliResponse22.get_return().getReturnValue();
					// 创建应用系统
					CLITunnelServiceClient cliClientApp = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponseApp = cliClientApp.executeCommandByParamList("StaticServerGroup","createServerGroup", new String[] {"" + AppsysCode + "","" + sysappId + "" });
					String appId = (String) cliResponseApp.get_return().getReturnValue();
					// 增加系统ACL
					cliClientAppACL.executeCommandByParamList("ServerGroup","applyAclPolicy", new String[] {"" + ss + "/" + AppsysCode + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
					// 创建服务器分组

					CLITunnelServiceClient cliClient2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse2 = cliClient2.executeCommandByParamList("StaticServerGroup","createServerGroup", new String[] {"" + ServerGroup + "","" + appId + "" });
					String groupId = (String) cliResponse2.get_return().getReturnValue();
					// 增加服务器分组ACL
					cliClientAppACL.executeCommandByParamList("ServerGroup","applyAclPolicy", new String[] {"" + ss + "/" + AppsysCode + "/" + ServerGroup + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
					// 添加服务器到分组
					CLITunnelServiceClient cliClient3 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
					ExecuteCommandByParamListResponse cliResponse3 = cliClient3.executeCommandByParamList("StaticServerGroup","addServerToServerGroupByName",new String[] { "" + groupId + "","" + ServerIp + "" });
					// 增加服务器ACL
					cliClientAppACL.executeCommandByParamList("Server","applyAclPolicy", new String[] {"" + ServerIp + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
				}
			} else {
				// 创建"/按应用系统";
				CLITunnelServiceClient cliClient20 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse20 = cliClient20.executeCommandByParamList("StaticServerGroup","createGroupWithParentName", new String[] {"按应用系统", "/" });
				String ssId = (String) cliResponse20.get_return().getReturnValue();
				// 增加/按应用系统ACL
				cliClientAppACL.executeCommandByParamList("ServerGroup","applyAclPolicy", new String[] { "/按应用系统","PLCY_ALL_ROOT" });
				// 创建应用系统
				CLITunnelServiceClient cliClient17 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse17 = cliClient17.executeCommandByParamList("StaticServerGroup","createServerGroup", new String[] {"" + AppsysCode + "", "" + ssId + "" });
				String appId = (String) cliResponse17.get_return().getReturnValue();
				// 增加系统ACL
				cliClientAppACL.executeCommandByParamList("ServerGroup","applyAclPolicy", new String[] {"" + ss + "/" + AppsysCode + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
				// 创建服务器分组


				CLITunnelServiceClient cliClient18 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse18 = cliClient18.executeCommandByParamList("StaticServerGroup","createServerGroup",new String[] { "" + ServerGroup + "","" + appId + "" });
				String groupId = (String) cliResponse18.get_return().getReturnValue();
				// 增加服务器分组ACL
				cliClientAppACL.executeCommandByParamList("ServerGroup","applyAclPolicy", new String[] {"" + ss + "/" + AppsysCode + "/" + ServerGroup + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
				// 添加服务器到分组
				CLITunnelServiceClient cliClient19 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse19 = cliClient19.executeCommandByParamList("StaticServerGroup","addServerToServerGroupByName", new String[] {"" + groupId + "", "" + ServerIp + "" });
				// 增加服务器ACL
				cliClientAppACL.executeCommandByParamList("Server","applyAclPolicy", new String[] { "" + ServerIp + "","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
			}
			// 查看DEPOT下面是否有deploy文件夹			CLITunnelServiceClient cliClientdepot = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponsedepot = cliClientdepot.executeCommandByParamList("DepotGroup", "groupExists",new String[] { "/DEPLOY" });
			String depot = (String) cliResponsedepot.get_return().getReturnValue();
			if(!depot.equals("true")){
				//创建deploy文件夹
				CLITunnelServiceClient cliClient8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse8 = cliClient8.executeCommandByParamList("DepotGroup","createGroupWithParentName", new String[] {"DEPLOY", "/" });
				cliClientAppACL.executeCommandByParamList("DepotGroup","applyAclPolicy", new String[] { "/DEPLOY","PLCY_ALL_ROOT" });
			}
			CLITunnelServiceClient cliClientdepot1 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponsedepot1 = cliClientdepot1.executeCommandByParamList("DepotGroup", "groupExists",new String[] { "/DEPLOY/"+envName+"" });
			String depot1 = (String) cliResponsedepot1.get_return().getReturnValue();
			if(!depot1.equals("true")){
				CLITunnelServiceClient cliClient8 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse8 = cliClient8.executeCommandByParamList("DepotGroup","createGroupWithParentName", new String[] {envName, "/DEPLOY" });
				cliClientAppACL.executeCommandByParamList("DepotGroup","applyAclPolicy", new String[] { "/DEPLOY/"+envName+"","PLCY_ALL_ROOT" });
			}
				// 创建应用系统文件夹				CLITunnelServiceClient cliClient7 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse7 = cliClient7.executeCommandByParamList("DepotGroup","createGroupWithParentName", new String[] {"" + AppsysCode + "", "/DEPLOY/"+envName+"" });
				// 增加系统文件夹ACL
				cliClientAppACL.executeCommandByParamList("DepotGroup","applyAclPolicy", new String[] {"/DEPLOY/"+envName+"/"+AppsysCode+"","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
			
			// 查看作业下是否存在deploy和appcheck文件夹			CLITunnelServiceClient cliClientjop = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponsejop = cliClientjop.executeCommandByParamList("JobGroup", "groupExists",new String[] { "/DEPLOY" });
			String jop = (String) cliResponsejop.get_return().getReturnValue();
			if (!jop.equals("true")) {
				CLITunnelServiceClient cliClient11 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse11 = cliClient11.executeCommandByParamList("JobGroup","createGroupWithParentName", new String[] {"DEPLOY", "/" });
				cliClientAppACL.executeCommandByParamList("JobGroup","applyAclPolicy", new String[] { "/DEPLOY","PLCY_ALL_ROOT" });
			}
			CLITunnelServiceClient cliClientjop1 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponsejop1 = cliClientjop1.executeCommandByParamList("JobGroup", "groupExists",new String[] { "/DEPLOY/"+envName+""  });
			String jop1 = (String) cliResponsejop1.get_return().getReturnValue();
			if (!jop1.equals("true")) {
				CLITunnelServiceClient cliClient11 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse11 = cliClient11.executeCommandByParamList("JobGroup","createGroupWithParentName", new String[] {envName, "/DEPLOY" });
				cliClientAppACL.executeCommandByParamList("JobGroup","applyAclPolicy", new String[] { "/DEPLOY/"+envName+"","PLCY_ALL_ROOT" });
			}
				CLITunnelServiceClient cliClient12 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse12 = cliClient12.executeCommandByParamList("JobGroup","createGroupWithParentName", new String[] {"" + AppsysCode + "", "/DEPLOY/"+envName+"" });
				// 增加系统ACL
				cliClientAppACL.executeCommandByParamList("JobGroup","applyAclPolicy", new String[] {"/DEPLOY/"+envName+"/"+AppsysCode+"","PLCY_"+envName+"_" + AppsysCode + "_APPADMIN" });
		}
	}
	/**
	 * 根据DBKey批量执行巡检作业
	 * @param servers 
	 * @param jobIds 作业编号数组
	 * @return 
	 */
	@Transactional
	public Object queryENV() throws AxisFault,Exception{
		String username = securityUtils.getUser().getUsername();
		StringBuilder sql = new StringBuilder();
		sql.append("select t.sub_item_name as NAME,t.sub_item_value as ENV from jeda_sub_item t, cmn_user_env b where t.item_id = 'SYSTEM_ENVIRONMENT' and t.sub_item_value = b.env and b.user_id='"+username+"'");
		return getSession().createSQLQuery(sql.toString())
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									.list();
			}

	public Object queryRuleEnv() {
		StringBuilder sql = new StringBuilder();
		sql.append(" select p.name    as \"name\", ")
				.append("  p.value   as \"value\" ")
				.append("  from (select t.sub_item_name as name, t.sub_item_value as value ")
				.append("  from jeda_sub_item t, cmn_user_env m")
				.append("  where t.sub_item_value = m.env")
				.append("   and m.user_id = 'w03511' and t.item_id = 'SYSTEM_ENVIRONMENT' ) p ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		return query.list();
	}
}
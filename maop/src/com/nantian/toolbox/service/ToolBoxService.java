package com.nantian.toolbox.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.net.UnknownHostException;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;
import org.apache.commons.io.IOUtils;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.http.conn.HttpHostConnectException;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;
import org.apache.tools.zip.ZipOutputStream;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.Constants;
import com.nantian.common.util.StringUtil;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.dply.vo.CmnDetailLogVo;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.toolbox.ToolConstants;
import com.nantian.toolbox.vo.OccToolBoxFilesVo;
import com.nantian.toolbox.vo.ToolBoxDescInfoVo;
import com.nantian.toolbox.vo.ToolBoxEventGroupInfoVo;
import com.nantian.toolbox.vo.ToolBoxExtendAttriVo;
import com.nantian.toolbox.vo.ToolBoxFilesVo;
import com.nantian.toolbox.vo.ToolBoxInfoVo;
import com.nantian.toolbox.vo.ToolBoxKeyWordInfoVo;
import com.nantian.toolbox.vo.ToolBoxParamInfoVo;
import com.nantian.toolbox.vo.ToolBoxScriptInfoVo;
import com.nantian.toolbox.vo.ToolBoxServerInfoVo;
import com.ultrapower.casp.client.LoginUtil;
import com.ultrapower.casp.common.code.ResultCode;
import com.ultrapower.casp.common.datatran.data.ticket.TransferTicket;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ToolBoxService {

	/** 日志输出 */
	private static Logger logger = Logger.getLogger(ToolBoxService.class);
	
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	private static final int buffer = 1;
	
	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	@Autowired
	 private SecurityUtils securityUtils; 
	//存放以用户,主机IP和脚本名称为单位执行结果输出列表

	private static Map<String, List<Map<String, Object>>> outPutMap = new ConcurrentHashMap<String, List<Map<String, Object>>>();
	//存放超过执行结果输出长度的部分的列表
	private static Map<String, List<Map<String, Object>>> overflowOutPutMap = new ConcurrentHashMap<String, List<Map<String, Object>>>();
	//存放以用户,主机IP和脚本名称为单位缓冲输入流


	private static Map<String, BufferedReader> readerMap = new ConcurrentHashMap<String, BufferedReader>();
	
	private static String osName = null;
	private static boolean isWindows = false;
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	
	
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	static {
		osName = System.getProperty("os.name");
		System.getProperty("sun.jnu.encoding");
		if (osName.toUpperCase().startsWith("WINDOWS")) {
			isWindows = true;
		}
	}
	
	/**
	 * 构造方法
	 */
	public ToolBoxService() {
		fields.put("tool_code", FieldType.STRING);
		fields.put("appsys_code", FieldType.STRING);
		fields.put("shell_name", FieldType.STRING);
		fields.put("tool_name", FieldType.STRING);
		fields.put("tool_desc", FieldType.STRING);
		fields.put("server_group", FieldType.STRING);
		fields.put("field_type_one", FieldType.STRING);
		fields.put("field_type_two", FieldType.STRING);
		fields.put("field_type_three", FieldType.STRING);
		fields.put("authorize_level_type", FieldType.STRING);
		fields.put("os_type", FieldType.STRING);
		fields.put("position_type", FieldType.STRING);
		fields.put("tool_authorize_flag", FieldType.STRING);
		fields.put("group_server_flag", FieldType.STRING);
		fields.put("os_user_flag", FieldType.STRING);
		fields.put("os_user", FieldType.STRING);
		fields.put("tool_creator", FieldType.STRING);
		fields.put("tool_charset", FieldType.STRING);
		fields.put("tool_type", FieldType.STRING);
		fields.put("delete_flag", FieldType.STRING);
		fields.put("event_group", FieldType.STRING);
		fields.put("summarycn", FieldType.STRING);
		fields.put("serverValue", FieldType.STRING);
		fields.put("paramValue", FieldType.STRING);
		fields.put("tool_status", FieldType.STRING);
		fields.put("tool_returnreasons", FieldType.STRING);
		fields.put("tool_modifier", FieldType.STRING);
		fields.put("tool_created_time", FieldType.TIMESTAMP);
		fields.put("tool_updated_time", FieldType.TIMESTAMP);
		fields.put("tool_received_user", FieldType.STRING);
		fields.put("tool_received_time", FieldType.TIMESTAMP);
		fields.put("tool_content", FieldType.CLOB);
		
		/**一级工具描述*/
		fields.put("front_tool_desc",FieldType.STRING);

	}
	
	public static List<Map<String, Object>> getPrivateOutPut(String user, String server,String shellname) {
		String key = user + "_" + server+"_"+shellname;
		if(outPutMap.get(key) == null){
			List<Map<String, Object>> outPut = new LinkedList<Map<String, Object>>();
			outPutMap.put(key, outPut);
			return outPut;
		}else{
			return outPutMap.get(key);
		}
	}
	
	public static List<Map<String, Object>> getPrivateOverflowOutPut(String user, String server,String shellname) {
		String key = user + "_" + server+"_"+shellname;
		if(overflowOutPutMap.get(key) == null){
			List<Map<String, Object>> outPut = new LinkedList<Map<String, Object>>();
			overflowOutPutMap.put(key, outPut);
			return outPut;
		}else{
			return overflowOutPutMap.get(key);
		}
	}


	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ToolBoxInfoVo toolBoxinfo) {
		getSession().save(toolBoxinfo);
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(OccToolBoxFilesVo vo) {
		getSession().save(vo);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ToolBoxFilesVo vo) {
		getSession().save(vo);
	}

	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional
	public void update(ToolBoxInfoVo toolBoxinfo) {
		getSession().update(toolBoxinfo);
	}

	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdate(ToolBoxInfoVo toolBoxinfo) {
		getSession().saveOrUpdate(toolBoxinfo);
		
	}
	
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxextendattri(ToolBoxExtendAttriVo toolBoxExtendAttriVo) {
		getSession().saveOrUpdate(toolBoxExtendAttriVo);
		
	}
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxscriptinfo(ToolBoxScriptInfoVo toolBoxScriptInfoVo) {
		getSession().saveOrUpdate(toolBoxScriptInfoVo);
		
	}
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxdescinfo(ToolBoxDescInfoVo toolBoxDescInfoVo) {
		getSession().saveOrUpdate(toolBoxDescInfoVo);
		
	}
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxdescfileinfo(ToolBoxFilesVo toolBoxFilesVo) {
		getSession().saveOrUpdate(toolBoxFilesVo);
		
	}
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxkeywordinfo(ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo) {
		getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		
	}
	
	/**
	 * 保存导入信息
	 * @return
	 */
	private void saveOrUpdatetoolboxeventgroupinfo(ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo) {
		getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		
	}
	
	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ToolBoxInfoVo> toolBoxinfos) {
		for (ToolBoxInfoVo toolBoxinfo : toolBoxinfos) {
			getSession().save(toolBoxinfo);
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
		return getSession().get(ToolBoxInfoVo.class, tool_code);
	}

	/**
	 * 删除.
	 * @param customer
	 */
	@Transactional
	public void delete(ToolBoxInfoVo toolBoxinfo) {
		getSession().delete(toolBoxinfo);
	}
	/**
	 * 删除参数
	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteParam(String tool_code ,String appsys_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxParamInfoVo tp where tp.tool_code = ? and tp.appsys_code= ? ")
				.setString(0, tool_code).setString(1, appsys_code).executeUpdate();
	}
	/**
	 * 删除服务器

	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteServer(String tool_code ,String appsys_code )throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxServerInfoVo ts where ts.tool_code = ? and ts.appsys_code= ? ")
				.setString(0, tool_code).setString(1, appsys_code).executeUpdate();
	}
	
	/**
	 * 删除关键字

	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteKeyWord(String tool_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxKeyWordInfoVo tk where tk.tool_code = ?")
				.setString(0, tool_code).executeUpdate();
	}
	
	/**
	 * 删除策略


	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteEventGroup(String tool_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxEventGroupInfoVo tg where tg.tool_code = ?")
				.setString(0, tool_code).executeUpdate();
	}
	
	/**
	 * 删除服务器


	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteAttri(String tool_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxExtendAttriVo ts where ts.tool_code = ?")
				.setString(0, tool_code).executeUpdate();
	}
	
	/**
	 *根据数据字典值获取名称
	 */
	@Transactional(readOnly = true)
	
	public String getNAME(String id,String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id=:id and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("id",id)
				.setString("sub_item_value",value);
		List<String>list =query.list();
		if(list.size()>0){
		return list.get(0).toString();
		}else{
			return value;
		}
	}
	/**
	 * 获取执行用户
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getOsuser(String appsys_code,String username,String serverips)throws SQLException {
		List<String> ips = null;
		if(serverips!=null && !serverips.equals("")){
			ips = new ArrayList<String>();
			String[] ipStr = serverips.split(",") ;
			for(String ip : ipStr){
				ips.add(ip);
			}
		}
		int countIp;
		if(ips!=null){
			countIp=ips.size();
		}else{
			countIp=0;
		}
		
		Query query;
		StringBuilder sql = new StringBuilder();
		if(appsys_code.equals("COMMON")){
		sql.append("select o.os_user as \"osUser\" from ( ");
		sql.append(" select t3.os_user as os_user , count(t3.server_ip) as num");
		sql.append(" from (select distinct t1.server_ip, t2.os_user ");
		sql.append(" from (select distinct s.server_ip, '' as os_user  from cmn_servers_info s");
		sql.append(" where s.delete_flag = '0' and  ");
		if(ips!=null){
			sql.append("  s.server_ip in (:serverList)");
		}else{
			sql.append("  s.server_ip in ('') ");
		}
		sql.append(" ) t1 left join ");
		sql.append(" (select distinct t.server_ip, t.os_user");
		sql.append(" from cmn_app_os_user t");
		sql.append(" where t.user_id = :user_id and t.delete_flag = '0' ) t2 ");
		sql.append("  on t1.server_ip = t2.server_ip ) t3");
		sql.append(" group by t3.os_user ) o where o.num= '");
		sql.append(countIp);
		sql.append("'");
		
		 query = getSession().createSQLQuery(sql.toString()).setString("user_id", username);
				
		}else{
			sql.append("select o.os_user as \"osUser\" from ( ");
			sql.append(" select t3.os_user as os_user , count(t3.server_ip) as num");
			sql.append(" from (select distinct t1.server_ip, t2.os_user ");
			sql.append(" from (select distinct s.server_ip, '' as os_user  from cmn_servers_info s");
			sql.append(" where s.delete_flag = '0' and  ");
			if(ips!=null){
				sql.append("  s.server_ip in (:serverList)");
			}else{
				sql.append("  s.server_ip in ('') ");
			}
			sql.append(" ) t1 left join ");
			sql.append(" (select distinct t.server_ip, t.os_user");
			sql.append(" from cmn_app_os_user t");
			sql.append(" where t.user_id = :user_id and t.delete_flag = '0' and t.appsys_code= :appsys_code ) t2 ");
			sql.append("  on t1.server_ip = t2.server_ip ) t3");
			sql.append(" group by t3.os_user ) o where o.num= '");
			sql.append(countIp);
			sql.append("'");
			
			query = getSession().createSQLQuery(sql.toString()).setString("appsys_code",
					appsys_code).setString("user_id", username);
		}

		
		
	
		if(ips!=null){
			query.setParameterList("serverList", ips).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		}
		return query.list();
	}
	/**
	 * 获取服务器用户
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getServerOs_user(String appsys_code,String serverips)throws SQLException {
		List<String> ips = null;
		if(serverips!=null && !serverips.equals("")){
			ips = new ArrayList<String>();
			String[] ipStr = serverips.split(",") ;
			for(String ip : ipStr){
				ips.add(ip);
			}
		}
		String userID=securityUtils.getUser().getUsername() ;
		Query query;
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
		//hql.append("e.appsysCode as appsysCode,");
		//hql.append("e.userId as userId,");
		hql.append("e.osUser as osUser");
		hql.append(") from ApposUserVo e where e.deleteFlag='0'  ");
		if(ips!=null){
			hql.append(" and serverIp in :serverList");
		}
		hql.append(" and e.userId = :userId");
		if(appsys_code.equals("COMMON")){
			query = getSession().createQuery(hql.toString()).setString("userId", userID);
		}else{
			hql.append(" and e.appsysCode = :appsys_code");
			  query = getSession().createQuery(hql.toString()).setString("appsys_code",
						appsys_code).setString("userId", userID);
			
		}
		if(ips!=null){
			query.setParameterList("serverList", ips);
		}
		return query.list();
	}
	/**
	 * 获取按组用户
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getGroupOsuser(String appsys_code)throws SQLException {
		
		
		String userID=securityUtils.getUser().getUsername() ;
		 Query query;
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
		//hql.append("e.appsysCode as appsysCode,");
	   // hql.append("e.userId as userId,");
		hql.append("e.osUser as osUser");
		hql.append(") from ApposUserVo e where e.deleteFlag='0'  ");
		
		if(appsys_code.equals("COMMON")){
			hql.append(" and e.appsysCode = :appsys_code");
			query = getSession().createQuery(hql.toString()).setString("appsys_code",
					appsys_code);
			  
		}else{
			 hql.append(" and e.userId = :userId");
			hql.append(" and e.appsysCode = :appsys_code");
			 query = getSession().createQuery(hql.toString()).setString("appsys_code",
						appsys_code).setString("userId", userID);
		}
		
		
		
		return query.list();
	}
	/**
	 * 获取授权用户
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getDynuser(String appsys_code)throws SQLException {
		List<Map<String, Object>>  list=new ArrayList<Map<String,Object>>();
		List<Map<String, Object>>  list2=new ArrayList<Map<String,Object>>();
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct  ");
		sql.append("e.user_id as \"dynUser\", ");
		sql.append(" j.user_id||'('|| j.user_name ||')' as \"name\" ");
		
		sql.append(" from cmn_user_app  e , JEDA_ROLE_USER u ,JEDA_USER j " );
		sql.append("where e.appsys_code=? and u.user_id=j.user_id and u.user_id=e.user_id and ( u.role_id like '%AppAdmin' or  u.role_id like '%SysAdmin' ) ");
		Query query1 = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString(0,appsys_code);
		list =query1.list();
		
		StringBuilder sql2 = new StringBuilder();
		sql2.append("select distinct  ");
		sql2.append("u.user_id as \"dynUser\" ,");
		sql2.append(" e.user_id||'('|| e.user_name ||')' as \"name\" ");
		sql2.append(" from JEDA_ROLE_USER u, JEDA_USER  e " );
		sql2.append("where u.user_id=e.user_id and u.role_id in ('ProdAppTeamLeader', 'ProdSysTeamLeader','ProdOpeRunLeader') ");
		
		Query query2= getSession().createSQLQuery(sql2.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		list2=query2.list();
		for(int i=0;i<list2.size();i++){
			list.add(list2.get(i));
		}
		return list; 
	}
	/**
	 * 获取分组
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> findGroup(String appsys_code)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" e.appsysCode as \"appsysCode\",");
		sql.append(" e.serverGroup as \"serverGroup\",");
		sql.append(" e.value as \"value\" from(");
		sql.append(" select t.appsys_code as appsysCode, o.sub_item_name as serverGroup,");
		sql.append(" o.sub_item_value as value from ");
		sql.append(" jeda_sub_item o  left join cmn_app_group t on o.sub_item_value =t.server_group");
		sql.append("   where o.ITEM_ID = 'SERVER_GROUP') e where  e.appsysCode = :appsys_code");
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("appsys_code",appsys_code);
		return query.list();
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFTone()throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_one as \"field_type_one\"");
		sql.append(" from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='专业领域' ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	

	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFTtwo(String field_type_one)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_one as \"field_type_one\",");
		sql.append(" f.field_type_two as \"field_type_two\" ");
		sql.append("  from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='专业领域' and f.field_type_one= :field_type_one ");
		
	
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("field_type_one",field_type_one);
		return query.list();
	}
	
	/**
	 * 获取专业三级分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFTthree(String field_type_one,String field_type_two)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_one as \"field_type_one\",");
		sql.append(" f.field_type_two as \"field_type_two\",");
		sql.append(" f.field_type_three as \"field_type_three\" ");
		sql.append("  from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='专业领域' and  f.field_type_one= :field_type_one and  f.field_type_two= :field_type_two");
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("field_type_one",field_type_one)
				.setString("field_type_two",field_type_two);
		return query.list();
	}
	
	/**
	 * 获取服务器分组名称
	 */
	@Transactional(readOnly = true)
	
	public String getGroupName(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='SERVER_GROUP' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	
	/**
	 * 获取或且名称
	 */
	@Transactional(readOnly = true)
	
	public String or_and(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='OR_AND' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	
	/**
	 * 获取告警匹配工具类型
	 * 0: 应用只匹配应用  系统只匹配系统
	 * 1:应用可以匹配系统   系统可以匹配应用
	 */
	@Transactional(readOnly = true)
	
	public String matchType(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='MATCH_TYPE' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	/**
	 * 获取字符集名称
	 */
	@Transactional(readOnly = true)
	
	public String getCharsetName(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='TOOL_CHARSET' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	/**
	 * 获取操作系统名称
	 */
	@Transactional(readOnly = true)
	
	public String getOstype(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='OS_TYPE' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	
	/**
	 * 查询数据库中所有toolboxinfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxInfoVo> queryAlltoolboxinfo() throws SQLException{
		return getSession().createQuery("from ToolBoxInfoVo t").list();
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxScriptInfoVo> queryAlltoolboxscriptinfo() throws SQLException{
		return getSession().createQuery("from ToolBoxScriptInfoVo t").list();
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxDescInfoVo> queryAlltoolboxdescinfo() throws SQLException{
		return getSession().createQuery("from ToolBoxDescInfoVo t").list();
	}
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxExtendAttriVo> queryAlltoolboxextendattri() throws SQLException{
		return getSession().createQuery("from ToolBoxExtendAttriVo t").list();
	}
	
	@Transactional(readOnly = true)
	public ToolBoxInfoVo queryAlltoolboxinfo2(String tool_code) throws SQLException{
		return (ToolBoxInfoVo) getSession().createQuery("from ToolBoxInfoVo t where t.tool_code=:tool_code")
				.setString("tool_code",tool_code)
				.uniqueResult();
	}
	/**
	 * 查询工具列表数据.
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
	public List<Map<String, Object>> queryToolboxInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,HttpServletRequest request)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		/**一级工具描述*/
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		
		sql.append("ta.tool_status as \"tool_status\",");
	//	sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0' and tb.appsys_code in :sysList   " );
		

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return query.list();
	}

	@Transactional(readOnly = true)
	public Long queryToolboxInfoCount( Map<String, Object> params)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
	    sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		
		sql.append("ta.tool_status as \"tool_status\",");
	//	sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0' and tb.appsys_code in :sysList   " );

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return (long) query.list().size();
	}

	/**
	 * 查询监控信息列表数据.
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmInfo(String event_id)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("mw.event_id as event_id,");
		hql.append("mw.customerseverity as customerseverity,");
		hql.append("mw.device_id as device_id,");
		hql.append("mw.device_ip as device_ip,");
		hql.append("mw.alarmobject as alarmobject,");
		hql.append("mw.componenttype as componenttype,");
		hql.append("mw.component as component,");
		hql.append("mw.subcomponent as subcomponent,");
		hql.append("mw.summarycn as summarycn,");
		hql.append("mw.eventstatus as eventstatus,");
		
		hql.append("to_char(mw.first_time,'yyyy-MM-dd hh24:mi:ss') as first_time,");
		hql.append("to_char(mw.last_time,'yyyy-MM-dd hh24:mi:ss') as last_time, ");
		hql.append("mw.alarminstance as alarminstance,");
		hql.append("mw.appname as appname,");
		hql.append("mw.managebycenter as managebycenter,");
		hql.append("mw.managebyuser as managebyuser,");
		hql.append("mw.managetimeexceed as managetimeexceed,");
		hql.append("to_char(mw.managetime,'yyyy-MM-dd hh24:mi:ss') as managetime,");
		hql.append("mw.maintainstatus as maintainstatus,");
		hql.append("mw.repeat_number as repeat_number,");
		
		hql.append("mw.mgtorg as mgtorg,");
		hql.append("mw.orgname as orgname,");
		hql.append("mw.event_group as event_group,");
		hql.append("mw.monitor_tool as monitor_tool,");
		hql.append("mw.is_ticket as is_ticket,");
		hql.append("mw.n_ticketid as n_ticketid,");
		hql.append("mw.ump_id as ump_id,");
		hql.append("mw.cause_effect as cause_effect,");
		hql.append("mw.parent_event_id as parent_event_id,");
		hql.append("mw.handle_status as handle_status, ");
		
		hql.append("mw.handle_user as handle_user,");
		hql.append("mw.handle_time_exceed as handle_time_exceed,");
		hql.append("to_char(mw.close_time,'yyyy-MM-dd hh24:mi:ss') as close_time,");
		hql.append("mw.match_tools_message as match_tools_message,");
		hql.append("to_char(mw.alarm_received_time,'yyyy-MM-dd hh24:mi:ss') as alarm_received_time,");
		hql.append("mw.result_summary as result_summary");
		hql.append(") from MonitorWarninginfoVo mw where mw.event_id=:event_id");
		Query query = getSession().createQuery(hql.toString()).setString("event_id", event_id);
		return query.list();
	}
	
	
	/**
	 * 查询工具列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 * @throws UnsupportedEncodingException 
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryalarmtoolsInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			String event_id,String device_ip)throws SQLException, UnsupportedEncodingException {
		
		  List<Map<String, Object>> list=  queryToolboxAlarmInfo(event_id);
		 String  event_group = (null!= list.get(0).get("event_group")?ComUtil.checkNull(list.get(0).get("event_group").toString().trim()):"");
		String key1=(null!= list.get(0).get("summarycn")?ComUtil.checkNull(list.get(0).get("summarycn")):"");
		String key2=(null!= list.get(0).get("alarminstance")?ComUtil.checkNull(list.get(0).get("alarminstance")):"");
		 String  componenttype  =(null!= list.get(0).get("componenttype")?ComUtil.checkNull(list.get(0).get("componenttype")):"");
		
		String summarycn =key1+key2;
		String appsysName = (null!=list.get(0).get("appname")?ComUtil.checkNull(list.get(0).get("appname")):""); 
		
		String or_and = or_and("0");
		String matchType = matchType("0");
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//一线接收工具描述
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
		
		if(matchType.equals("0")){
			sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
			sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
			sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
			sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
			sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
			//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
			sql.append("  , v_cmn_app_info ca  ");
			sql.append("  where tb.delete_flag='0'  and tb.appsys_code = ca.appsys_code " );
			sql.append("  and ( ca.systemname = :appsysName or tb.appsys_code='COMMON' )");
		}else if(matchType.equals("1")){
			if(componenttype.equals("应用")){
				
				sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
				sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
				sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
				sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
				sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
				//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
				sql.append("  , v_cmn_app_info ca  ");
				sql.append("  where tb.delete_flag='0'  and tb.appsys_code = ca.appsys_code " );
				sql.append("  and ca.systemname = :appsysName");
				
				}else{
					sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
					sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
					sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
					sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
					sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
					//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
					sql.append("  where tb.delete_flag='0'   " );
					sql.append("  and tb.appsys_code ='COMMON' ");
					
				}
		}
		
		
		sql.append(" order by tb.field_type_one,tb.field_type_two,tb.field_type_three ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		
        if(matchType.equals("0")){
        	
        		query.setParameter("appsysName", appsysName);
        		
		  }else if(matchType.equals("1")){
			  if(componenttype.equals("应用")){
					query.setParameter("appsysName", appsysName);
					}
		}
		
		
		List<Map<String, Object>> tools= query.list();
		List<Map<String, Object>> event_tools= new ArrayList<Map<String,Object>>();
		
		if(or_and.equals("1")){
		List<Map<String, Object>> event_IDtools= new ArrayList<Map<String,Object>>();
		
		
		for(Map<String, Object> maptool : tools ){
			String tool_event_group =ComUtil.checkNull(maptool.get("event_group"));
			if(!tool_event_group.equals("")&&event_group.equals("")){
				String [] tool_event_group_params = tool_event_group.split("\\|");
				int k=0;
				for(int i=0;i<tool_event_group_params.length;i++){
					if(event_group.equals(tool_event_group_params[i].trim())){
						k++;
						break;
					}
				}
				if(k>0){
					event_IDtools.add(maptool);
				}
			}
		};
		
		for(Map<String, Object> maptool : event_IDtools ){
			
			String tool_summarycn =ComUtil.checkNull(maptool.get("summarycn"));
		//	String tool_alarminstance =ComUtil.checkNull(maptool.get("alarminstance"));
			int m=0;
			
			
			if(!(tool_summarycn.equals("")&&summarycn.equals(""))){
				String [] tool_summarycn_params = tool_summarycn.split("\\|");
				int k=0;
				for(int i=0;i<tool_summarycn_params.length;i++){
					
					
					String [] summarycn_params=tool_summarycn_params[i].split("&");
					boolean summarycn_flag=true;
					for(int j=0 ;j<summarycn_params.length;j++){
						
						if(summarycn.indexOf(summarycn_params[j])==-1){
							summarycn_flag=false;
							break;
						}
						
					}
					
					if(summarycn_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};
			
			
		/*	if(!tool_alarminstance.equals("")&&!alarminstance.equals("")){
				String [] tool_alarminstance_params = tool_alarminstance.split("\\|");
				int k=0;
				for(int i=0;i<tool_alarminstance_params.length;i++){
					
					
					String [] alarminstance_params=tool_alarminstance_params[i].split("&");
					boolean event_group_flag=true;
					for(int j=0 ;j<alarminstance_params.length;j++){
						
						if(alarminstance.indexOf(alarminstance_params[j])==-1){
							event_group_flag=false;
							break;
						}
						
					}
					
					if(event_group_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};*/
			
			if(m>0){
				event_tools.add(maptool);
			}
		}
		
		
		}else{
		
		
		for(Map<String, Object> maptool : tools ){
			String tool_event_group =ComUtil.checkNull(maptool.get("event_group"));
			String tool_summarycn =ComUtil.checkNull(maptool.get("summarycn"));
		//	String tool_alarminstance =ComUtil.checkNull(maptool.get("alarminstance"));
			int m=0;
			if(!tool_event_group.equals("")&&!event_group.equals("")){
				String [] tool_event_group_params = tool_event_group.split("\\|");
				int k=0;
				
				for(int i=0;i<tool_event_group_params.length;i++){
					
					boolean event_group_flag=false;
					
						if(event_group.equals(tool_event_group_params[i].trim())){
							event_group_flag = true;
							
					}
					
					if(event_group_flag){
						k++;
						break;
					}
				}
				if(k>0){
					m++;
				}
			};
			
			if(!tool_summarycn.equals("")&&!summarycn.equals("")){
				String [] tool_summarycn_params = tool_summarycn.split("\\|");
				int k=0;
				for(int i=0;i<tool_summarycn_params.length;i++){
					
					
					String [] summarycn_params=tool_summarycn_params[i].split("&");
					boolean summarycn_flag=true;
					for(int j=0 ;j<summarycn_params.length;j++){
						
						if(summarycn.indexOf(summarycn_params[j])==-1){
							summarycn_flag=false;
							break;
						}
						
					}
					
					if(summarycn_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};
			
			
		/*	if(!tool_alarminstance.equals("")&&!alarminstance.equals("")){
				String [] tool_alarminstance_params = tool_alarminstance.split("\\|");
				int k=0;
				for(int i=0;i<tool_alarminstance_params.length;i++){
					
					
					String [] alarminstance_params=tool_alarminstance_params[i].split("&");
					boolean event_group_flag=true;
					for(int j=0 ;j<alarminstance_params.length;j++){
						
						if(alarminstance.indexOf(alarminstance_params[j])==-1){
							event_group_flag=false;
							break;
						}
						
					}
					
					if(event_group_flag){
						k++;
						break;
					}
					
				}
				if(k>0){
					m++;
				}
			};*/
			
			if(m>0){
				event_tools.add(maptool);
			}
		 }
		}
		
		
		for(Map<String, Object> mapeventtool : event_tools ){
			mapeventtool.put("event_id", event_id);
			mapeventtool.put("device_ip", device_ip);
			String tool_code=ComUtil.checkNull(mapeventtool.get("tool_code"));
			String os_user_flag=ComUtil.checkNull(mapeventtool.get("os_user_flag"));
			String group_server_flag=ComUtil.checkNull(mapeventtool.get("group_server_flag"));
			String os_user=ComUtil.checkNull(mapeventtool.get("os_user"));
			
			if("1".equals(mapeventtool.get("tool_type").toString())){
				if(os_user_flag.equals("0")){
					mapeventtool.put("os_user", os_user);
				}else{
				      if(group_server_flag.equals("1")){
					     mapeventtool.put("os_user", os_user);
				      }else{
				    	 
				    	 if(getServerOsuser(tool_code).size()>0){

				 String server_user=ComUtil.checkNull(getServerOsuser(tool_code).get(0).get("server_ip"));
				    	  mapeventtool.remove("os_user");
				    	  mapeventtool.put("os_user", server_user);
				    	 }else{
				    		 mapeventtool.put("os_user", "");
				    	 }
				      }
				}
			}
			
			
		
		}
		
		
		
		 return event_tools;
		 
	}
	
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getServerOsuser(String tool_code )throws SQLException  {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct tc.os_user as  \"os_user\"  from TOOL_BOX_SERVER_INFO tc where tc.tool_code =? ");
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
		
	}	
/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countalarmtools(Map<String, Object> params)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from  TOOL_BOX_INFO tb,TOOL_BOX_EXTEND_ATTRI ta  where tb.delete_flag='0' and ta.tool_code=tb.tool_code and tb.appsys_code in :sysList ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and tb." + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and tb." + key + " = :" + key);
					}
				}
			}
		}
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);;
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return Long.valueOf(query.uniqueResult().toString());
	}

	
	/**
	 * 保存工具箱

	 * @throws DataIntegrityViolationException 
	 * @throws SQLException 
	 * @throws IOException 
	 * @throws FtpCmpException 
	 */
	@Transactional
	public void saveCreate(ToolBoxInfoVo toolBoxInfoVo,List<Map<String, Object>> paramlist, List<String> serverlist , 
			String shellname, String fileTxt,String appsyscode,String toolcode,String serverGroup,String os_type, ToolBoxExtendAttriVo attriVo,
			ToolBoxScriptInfoVo toolBoxScriptInfoVo,ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			 ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo)
	throws DataIntegrityViolationException, SQLException, FtpCmpException, IOException{
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		
		ToolBoxParamInfoVo vo = null;
		List<ToolBoxParamInfoVo> paramList = new ArrayList<ToolBoxParamInfoVo>();
		for (Map<String, Object> mapprarm : paramlist) {
			vo = new ToolBoxParamInfoVo();
			vo.setTool_code(toolcode);
			vo.setAppsys_code(appsyscode);
			vo.setParam_default_value(null!= mapprarm.get("param_default_value")?ComUtil.checkJSONNull(mapprarm
					.get("param_default_value")):null);
			vo.setParam_desc(null != mapprarm.get("param_desc")?ComUtil.checkJSONNull(mapprarm
					.get("param_desc")):null);
			vo.setParam_format(null != mapprarm.get("param_format")?ComUtil.checkJSONNull(mapprarm
					.get("param_format")):null);
			if("".equals(ComUtil.checkNull(mapprarm.get("param_length")))||
					"".equals(ComUtil.checkJSONNull(mapprarm.get("param_length"))) ){
				vo.setParam_length(null);
			}else{
				vo.setParam_length(Long.valueOf(mapprarm.get("param_length").toString()));
			}
			vo.setParam_name(null != mapprarm.get("param_name")?ComUtil.checkJSONNull(mapprarm
					.get("param_name")):null);
		
			vo.setParam_type(null != mapprarm.get("param_type")?ComUtil.checkJSONNull(mapprarm
					.get("param_type")):null);

			paramList.add(vo);
		}  
		
		ToolBoxServerInfoVo servervo = null;
		List<ToolBoxServerInfoVo> serverList = new ArrayList<ToolBoxServerInfoVo>();
		
		for (String mapserver : serverlist) {
			servervo = new ToolBoxServerInfoVo();
			servervo.setTool_code(toolcode);
			servervo.setAppsys_code(appsyscode);
	
			servervo.setServer_ip(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[0]));
			servervo.setServer_route(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[1]));
			servervo.setOs_user(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[2]));
			serverList.add(servervo);
		}
		ToolBoxInfoVo Vo=queryAlltoolboxinfo2(toolcode);
		if(Vo==null){
			getSession().save(toolBoxInfoVo);
		}else{
			
			if("1".equals(Vo.getDelete_flag())){
				this.deleteParam(toolcode, appsyscode);
				this.deleteServer(toolcode, appsyscode);
				this.deleteAttri(toolcode);
				this.deleteEventGroup(toolcode);
				this.deleteKeyWord(toolcode);
				getSession().evict(Vo);
				getSession().saveOrUpdate(toolBoxInfoVo);
			}else{
				getSession().evict(Vo);
				getSession().save(toolBoxInfoVo);
			}
		}
		
		
		if (!fileTxt.equals("")) {
			
			this.importFtp(shellname,appsyscode,serverGroup,os_type);
		}
		getSession().saveOrUpdate(attriVo);
		getSession().saveOrUpdate(toolBoxScriptInfoVo);
		
		if(null!=toolBoxEventGroupInfoVo.getEvent_group()&&toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		}
		
		if(null!=toolBoxKeyWordInfoVo.getSummarycn()&&toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		}
		
		for (ToolBoxParamInfoVo paramVo : paramList) {
			
			getSession().saveOrUpdate(paramVo);
		}
		
		for (ToolBoxServerInfoVo serverVo : serverList) {
			getSession().saveOrUpdate(serverVo);
		}
		
		
		//插入注册日志表

		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(toolBoxInfoVo.getAppsys_code());
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(toolBoxInfoVo.getTool_name()+"_"+toolBoxInfoVo.getTool_code()+"_create");
		cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		/*Long logJnlNo = cmnLogService.save(cmnLog);*/
		cmnLogService.save(cmnLog);

	}
	
	/**
	 * 根据工具编号，应用系统 获取工具属性

	 * @param tool_code
	 *        工具编号
	 * @param appsys_code
	 *        应用系统
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String tool_code, String appsys_code)throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		
		sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_status as \"tool_status\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
				
		sql.append("  where tb.delete_flag='0' and  tb.tool_code =? and tb.appsys_code=?  " );
		
		

		@SuppressWarnings("unchecked")
		Map<String,Object> map= (Map<String, Object>) getSession().createSQLQuery(sql.toString()).setString(0, tool_code)
				.setString(1, appsys_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

		if(null!=map.get("tool_content")){
			String tool_content=ComUtil.checkNull(StringUtil.clobToString((Clob)map.get("tool_content")));
			map.put("tool_content", tool_content);
		}
		
		return map;

	}
	
	@Transactional(readOnly = true)
	public Object dblfindById(String tool_code, String appsys_code)throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		//描述合并
		sql.append(" '<font style=bold color=green>工具描述:</font><br>&nbsp;&nbsp;'" +
				"||tb.tool_desc||'<br><font style=bold color=blue>一线工具描述:</font><br>&nbsp;&nbsp;'" +
				"||tb.front_tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		//sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		
		sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_status as \"tool_status\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
				
		sql.append("  where tb.delete_flag='0' and  tb.tool_code =? and tb.appsys_code=?  " );
		
		

		@SuppressWarnings("unchecked")
		Map<String,Object> map= (Map<String, Object>) getSession().createSQLQuery(sql.toString()).setString(0, tool_code)
				.setString(1, appsys_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

		if(null!=map.get("tool_content")){
			String tool_content=ComUtil.checkNull(StringUtil.clobToString((Clob)map.get("tool_content")));
			map.put("tool_content", tool_content);
		}
		
		return map;

	}
	
	/**
	 * 保存修改信息 
	 * @throws SQLException 
	 * @throws IOException 
	 * @throws FtpCmpException 
	 */
	@Transactional
	public void saveEdit(ToolBoxInfoVo toolBoxInfoVo,
			 List<Map<String, Object>> paramlist,
			 List<String> serverlist, String shellname, String fixTxt,
			 String appsyscode,String toolcode,String serverGroup,String os_type, ToolBoxExtendAttriVo attriVo,
			 ToolBoxScriptInfoVo toolBoxScriptInfoVo,ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			 ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo) throws IndexOutOfBoundsException,ArrayIndexOutOfBoundsException, SQLException, FtpCmpException, IOException {
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

		
		ToolBoxServerInfoVo servervo = null;
		List<ToolBoxServerInfoVo> serverList = new ArrayList<ToolBoxServerInfoVo>();
		
		for (String mapserver : serverlist) {
			servervo = new ToolBoxServerInfoVo();
			servervo.setTool_code(toolcode);
			servervo.setAppsys_code(appsyscode);
	
			servervo.setServer_ip(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[0]));
			servervo.setServer_route(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[1]));
			servervo.setOs_user(ComUtil.checkNull(mapserver.split(Constants.SPLIT_SEPARATEOR)[2]));
			serverList.add(servervo);
		}
		
		
		ToolBoxParamInfoVo vo = null;
		List<ToolBoxParamInfoVo> paramList = new ArrayList<ToolBoxParamInfoVo>();
		for (Map<String, Object> mapprarm : paramlist) {
			vo = new ToolBoxParamInfoVo();
			vo.setTool_code(toolcode);
			vo.setAppsys_code(appsyscode);

			vo.setParam_default_value(null!= mapprarm.get("param_default_value")?ComUtil.checkJSONNull(mapprarm
					.get("param_default_value")):null);
			vo.setParam_desc(null != mapprarm.get("param_desc")?ComUtil.checkJSONNull(mapprarm
					.get("param_desc")):null);
			vo.setParam_format(null != mapprarm.get("param_format")?ComUtil.checkJSONNull(mapprarm
					.get("param_format")):null);
			if("".equals(ComUtil.checkNull(mapprarm.get("param_length")))||
					"".equals(ComUtil.checkJSONNull(mapprarm.get("param_length"))) ){
				vo.setParam_length(null);
			}else{
				vo.setParam_length(Long.valueOf(mapprarm.get("param_length").toString()));
			}
			vo.setParam_name(null != mapprarm.get("param_name")?ComUtil.checkJSONNull(mapprarm
					.get("param_name")):null);
			
			vo.setParam_type(null != mapprarm.get("param_type")?ComUtil.checkJSONNull(mapprarm
					.get("param_type")):null);
			paramList.add(vo);
		} 
		
		
		this.deleteParam(toolcode, appsyscode);
		this.deleteServer(toolcode, appsyscode);
		this.deleteAttri(toolcode);
		this.deleteEventGroup(toolcode);
		this.deleteKeyWord(toolcode);
		
		getSession().saveOrUpdate(toolBoxInfoVo);
		getSession().saveOrUpdate(attriVo);
		getSession().saveOrUpdate(toolBoxScriptInfoVo);
		if(toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		}
		
		if(toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		}
		
		if (!fixTxt.equals("")) {
			this.importFtpBak(shellname,appsyscode,serverGroup,os_type,toolcode);
			this.importFtp(shellname,appsyscode,serverGroup,os_type);
		}
		
		for (ToolBoxParamInfoVo paramVo : paramList) {
			getSession().save(paramVo);
		}

		for (ToolBoxServerInfoVo serverVo : serverList) {
			getSession().save(serverVo);
		}
		
		//插入修改日志表
		String toolname=toolBoxInfoVo.getTool_name();
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(appsyscode);
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(toolname+"_"+toolcode+"_update");
		cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检shellname
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		cmnLogService.save(cmnLog);

	}

	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttools(String tool_code, String appsys_code) throws SQLException {
	
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_INFO tb where tb.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> tools=query.list();
		StringBuilder toolfile = new StringBuilder();
		int lng=tools.size()-1;
		
		toolfile.append(tools.get(lng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("APPSYS_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("TOOL_NAME"))
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("TOOL_DESC")?tools.get(lng).get("TOOL_DESC").toString().replaceAll(CommonConst.CHANGE_LINE, "@#@"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("AUTHORIZE_LEVEL_TYPE"))
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("FIELD_TYPE_ONE")?tools.get(lng).get("FIELD_TYPE_ONE"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("FIELD_TYPE_TWO")?tools.get(lng).get("FIELD_TYPE_TWO"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("FIELD_TYPE_THREE")?tools.get(lng).get("FIELD_TYPE_THREE"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("TOOL_AUTHORIZE_FLAG"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("TOOL_TYPE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("DELETE_FLAG"));
		
		return toolfile.toString();
	}
	
	
	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolScripts(String tool_code) throws SQLException {
	
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_SCRIPT_INFO ts where ts.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> tools=query.list();
		StringBuilder toolScriptfile = new StringBuilder();
		int lng=tools.size()-1;
		
		toolScriptfile.append(tools.get(lng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("SHELL_NAME"))
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("SERVER_GROUP")?tools.get(lng).get("SERVER_GROUP"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("GROUP_SERVER_FLAG")?tools.get(lng).get("GROUP_SERVER_FLAG"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("OS_USER_FLAG")?tools.get(lng).get("OS_USER_FLAG"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(lng).get("OS_USER")?tools.get(lng).get("OS_USER"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("OS_TYPE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("POSITION_TYPE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("TOOL_CHARSET"));
		
		return toolScriptfile.toString();
	}
	
	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolDescs(String tool_code) throws SQLException {
	
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_DESC_INFO ts where ts.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> tools=query.list();
		StringBuilder toolDescfile = new StringBuilder();
		int lng=tools.size()-1;
		
		toolDescfile.append(tools.get(lng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(StringUtil.clobToString((Clob)tools.get(lng).get("TOOL_CONTENT")));
		
		return toolDescfile.toString();
	}
	
	/**
	 * 工具导出 附件
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 * @throws IOException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolDescfiles(String tool_code) throws SQLException, IOException {
	
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_FILES ts where ts.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> tools=query.list();
		StringBuilder toolDescfiles = new StringBuilder();
		int lng=tools.size()-1;
		if(tools.size()>0){
		for(int i = 0; i < tools.size()-1 ; i++){
			Blob b=(Blob)tools.get(i).get("FILE_CONTENT");
			InputStream in = b.getBinaryStream();
		      byte[] file=IOUtils.toByteArray(in);
		      
			toolDescfiles.append(tools.get(i).get("TOOL_CODE"))
			.append(Constants.DATA_SEPARATOR)
			.append(tools.get(i).get("FILE_ID"))
			.append(Constants.DATA_SEPARATOR)
			.append(tools.get(i).get("FILE_NAME"))
			.append(Constants.DATA_SEPARATOR)
			.append(tools.get(i).get("FILE_TYPE"))
			.append(Constants.DATA_SEPARATOR)
			.append(StringUtil.bytesToHexString(file))
			.append("\n");
		}
		
		Blob b=(Blob)tools.get(lng).get("FILE_CONTENT");
		InputStream in = b.getBinaryStream();
	      byte[] file=IOUtils.toByteArray(in);
		toolDescfiles.append(tools.get(lng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("FILE_ID"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("FILE_NAME"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(lng).get("FILE_TYPE"))
		.append(Constants.DATA_SEPARATOR)
		.append(StringUtil.bytesToHexString(file));
		}
		
		return toolDescfiles.toString();
	}
	
	
	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolEventGroup(String tool_code) throws SQLException {
	
		
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_EVENT_GROUP_INFO tg where tg.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> tooleventgroups=query.list();
		StringBuilder tooleventgroupfile = new StringBuilder();
		if(tooleventgroups.size()>0){
			int lng=tooleventgroups.size()-1;
			
			tooleventgroupfile.append(tooleventgroups.get(lng).get("TOOL_CODE"))
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tooleventgroups.get(lng).get("EVENT_GROUP")?tooleventgroups.get(lng).get("EVENT_GROUP"):"");
		}
			
		return tooleventgroupfile.toString();
	}
	
	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolSummarycn(String tool_code) throws SQLException {
	
		
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_KEY_WORD_INFO tk where tk.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> toolSummarycn=query.list();
		StringBuilder toolSummarycnfile = new StringBuilder();
		if(toolSummarycn.size()>0){
			int lng=toolSummarycn.size()-1;
			
			toolSummarycnfile.append(toolSummarycn.get(lng).get("TOOL_CODE"))
			.append(Constants.DATA_SEPARATOR)
			.append(null!=toolSummarycn.get(lng).get("SUMMARYCN")?toolSummarycn.get(lng).get("SUMMARYCN").toString().replaceAll(CommonConst.CHANGE_LINE, "@#@"):"");
			
		}
		
		return toolSummarycnfile.toString();
	}
	
	/**
	 * 工具导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public String exporttoolattris(String tool_code) throws SQLException {
	
		
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_EXTEND_ATTRI ta where ta.tool_code =?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String, Object>> toolattris=query.list();
		StringBuilder toolattrifile = new StringBuilder();
		int lng=toolattris.size()-1;
		
		toolattrifile.append(toolattris.get(lng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append("0")
		.append(Constants.DATA_SEPARATOR)
		.append("");
		
		return toolattrifile.toString();
	}
	
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolFile(String toolfile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
		    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
			File file = new File(filepath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+".dat"),"GBK"));
			out.print(toolfile);
			out.flush();
			out.close();
	}
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolattrifile,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolScriptFile(String toolscriptfile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"Script.dat"),"GBK"));
		out.print(toolscriptfile);
		out.flush();
		out.close();
}
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolattrifile,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolDescFile(String tooldescfile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"Desc.dat"),"GBK"));
		out.print(tooldescfile);
		out.flush();
		out.close();
}
	/**
	 * 附件数据写入到文件中.
	 * 
	 * @param  String tooldescfiles,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolDescFiles(String tooldescfiles,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"DescFiles.dat"),"GBK"));
		out.print(tooldescfiles);
		out.flush();
		out.close();
}
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolattrifile,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolAttriFile(String toolattrifile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"Attri.dat"),"GBK"));
		out.print(toolattrifile);
		out.flush();
		out.close();
}
	
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolattrifile,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolEventgroupFile(String tooleventgroupfile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"Eventgroup.dat"),"GBK"));
		out.print(tooleventgroupfile);
		out.flush();
		out.close();
}
	
	
	/**
	 * 数据写入到文件中.
	 * 
	 * @param  String toolsummarycnfile,String fileName
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolSummarycnFile(String toolsummarycnfile,String toolboxinfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
	    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
		File file = new File(filepath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxinfo+"Summarycn.dat"),"GBK"));
		out.print(toolsummarycnfile);
		out.flush();
		out.close();
}
	
	
	
	/**
	 * 导出目录写入到文件中.
	 * 
	 * @param  String toolFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolsExpTxtFile(String toolfile,String username) throws UnsupportedEncodingException, FileNotFoundException{
		    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username;
			File file = new File(filepath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +username+".txt"),"GBK"));
			out.print(toolfile);
			out.flush();
			out.close();
	}
	/**
	 *上传导出文件目录
	 * 
	 * @param customer
	 */
	
	  @Transactional
	public void FTPtoolsExpTxt(String username) throws FtpCmpException {
		
		
		  String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username;
			String ToPath=messages.getMessage("toolbox.bsaFileServerPath");
			
			String localFilename=filepath+File.separator+username+CommonConst.FILE_SUFFIX_TXT;
			String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username+CommonConst.SLASH+username+CommonConst.FILE_SUFFIX_TXT;
			String host = messages.getMessage("bsa.fileServerIp");
			Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
			String user = messages.getMessage("bsa.ftpUser");
			String password = messages.getMessage("bsa.ftpPassword");
			ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
			ftpLogin.connect(host,port,user,password);
			ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
			ftpFile.doChdir(ToPath, new StringBuffer());
			ftpFile.doMkdir(username, new StringBuffer());
			ftpFile.doPut(localFilename,path, true,new StringBuffer());
			ftpLogin.disconnect();
	}
	
	/**
	 * 导出文件调用作业.
	 * 
	 * @param  String appsys_codes,String tool_codes,String server_groups,String shellnames,String position_types,String username
	 */
	
	public void exporttoolstar(String[] appsys_codes,String[] tool_codes,String[]server_groups,String[]shellnames,String []position_types,String username,String []os_types,String []tool_types) throws Exception{
		
		String TOOLCODE="";
		for (int i = 0;i < appsys_codes.length; i++) {
			if("1".equals(tool_types[i].toString())){
				
			if(position_types[i].equals("1")){
			if(appsys_codes[i].equals("COMMON")){
			String sg=getOstype(os_types[i]);
			TOOLCODE=TOOLCODE.concat(appsys_codes[i]).concat(CommonConst.PERCENT_SYMBOL).concat(sg).concat(CommonConst.PERCENT_SYMBOL).concat(shellnames[i]).concat(CommonConst.SPACE);       
			  }else{
				  String sg=getGroupName(server_groups[i]);
					TOOLCODE=TOOLCODE.concat(appsys_codes[i]).concat(CommonConst.PERCENT_SYMBOL).concat(sg).concat(CommonConst.PERCENT_SYMBOL).concat(shellnames[i]).concat(CommonConst.SPACE);       
				 	  
			     }
			   }
			 }
			}
		if(TOOLCODE.trim().length()>0){
		//目录文件
		toolsExpTxtFile(TOOLCODE,username);
		//上传脚本文件目录
		FTPtoolsExpTxt(username);
		
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String strDate = matter.format(date);
		String workname=strDate+username+messages.getMessage("toolbox.bsa.exportJob");
		
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		//创建作业
			CLITunnelServiceClient cliClientCreatTarJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseCreatTarJob = cliClientCreatTarJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"",messages.getMessage("toolbox.bsa.impExpJobPath"),messages.getMessage("toolbox.bsa.exportJob"),"2"});
			cliClientCreatTarJob.ResponseCheck4ExecuteCommand(cliResponseCreatTarJob);
			String DBkeyCreatTarJob=(String) cliResponseCreatTarJob.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientTarLinkServer = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTarLinkServer = cliClientTarLinkServer.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkeyCreatTarJob,messages.getMessage("bsa.ipAddress")});
			cliClientTarLinkServer.ResponseCheck4ExecuteCommand(cliResponseTarLinkServer);
		//参数及执行作业

			CLITunnelServiceClient cliClientDBkeyTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseDBkeyTar = cliClientDBkeyTar.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientDBkeyTar.ResponseCheck4ExecuteCommand(cliResponseDBkeyTar);
			String dBkeyTar=(String) cliResponseDBkeyTar.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientClean2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseClean2 = cliClientClean2.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientClean2.ResponseCheck4ExecuteCommand(cliResponseClean2);
			
			
			CLITunnelServiceClient cliClientAddpath = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd1 = cliClientAddpath.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("toolbox.bsaFileServerPath"))});
			cliClientAddpath.ResponseCheck4ExecuteCommand(cliResponseAdd1);
			
			CLITunnelServiceClient cliClientAdduser = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdduser.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"1",username});
			cliClientAdduser.ResponseCheck4ExecuteCommand(cliResponseAdd2);
			
			CLITunnelServiceClient cliClientTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTar = cliClientTar.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyTar});
			cliClientTar.ResponseCheck4ExecuteCommand(cliResponseTar);
			
			//删除临时打包作业
			CLITunnelServiceClient cliClientTarJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseZipJobDelete = cliClientTarJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
		}
	}
	
	/**
	 * 删除文件调用作业.
	 * 
	 * @param  String username
	 */
	
	public void deltoolstar(String username) throws Exception{
	
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String strDate = matter.format(date);
		String workname=strDate+username+messages.getMessage("toolbox.bsa.deltarJob");
		
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		//创建作业
			CLITunnelServiceClient cliClientCreatTarJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseCreatTarJob = cliClientCreatTarJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"",messages.getMessage("toolbox.bsa.impExpJobPath"),messages.getMessage("toolbox.bsa.deltarJob"),"2"});
			cliClientCreatTarJob.ResponseCheck4ExecuteCommand(cliResponseCreatTarJob);
			String DBkeyCreatTarJob=(String) cliResponseCreatTarJob.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientTarLinkServer = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTarLinkServer = cliClientTarLinkServer.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkeyCreatTarJob,messages.getMessage("bsa.ipAddress")});
			cliClientTarLinkServer.ResponseCheck4ExecuteCommand(cliResponseTarLinkServer);
		//参数及执行作业

			CLITunnelServiceClient cliClientDBkeyTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseDBkeyTar = cliClientDBkeyTar.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientDBkeyTar.ResponseCheck4ExecuteCommand(cliResponseDBkeyTar);
			String dBkeyTar=(String) cliResponseDBkeyTar.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientClean2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseClean2 = cliClientClean2.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientClean2.ResponseCheck4ExecuteCommand(cliResponseClean2);
			
			
			CLITunnelServiceClient cliClientAddpath = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd1 = cliClientAddpath.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("toolbox.bsaFileServerPath"))});
			cliClientAddpath.ResponseCheck4ExecuteCommand(cliResponseAdd1);
			
			CLITunnelServiceClient cliClientAdduser = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdduser.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"1",username});
			cliClientAdduser.ResponseCheck4ExecuteCommand(cliResponseAdd2);
			
			CLITunnelServiceClient cliClientTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTar = cliClientTar.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyTar});
			cliClientTar.ResponseCheck4ExecuteCommand(cliResponseTar);
			
			//删除临时打包作业
			CLITunnelServiceClient cliClientTarJobDelete = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseZipJobDelete = cliClientTarJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
		
	}
	
	
	
	/**
	 * 导入目录写入到文件中.
	 * 
	 * @param  String toolFile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolsImpTxtFile(String appfile,String toolfile,String username) throws UnsupportedEncodingException, FileNotFoundException{
		    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username;
			File file = new File(filepath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +username+".txt"),"GBK"));
			out.print(toolfile);
			out.flush();
			out.close();
			
			
			PrintWriter out2 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +username+"app.txt"),"GBK"));
			out2.print(appfile);
			out2.flush();
			out2.close();
			
	}
	
	/**
	 *上传导入文件的目录

	 * 
	 * @param customer
	 */
	
	  @Transactional
	public void FTPtoolsImpTxt(String username) throws FtpCmpException {
		
		
		    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username;
			String ToPath=messages.getMessage("toolbox.bsaFileServerPath");
			
			String localFilename=filepath+File.separator+username+CommonConst.FILE_SUFFIX_TXT;
			String localFilename2=filepath+File.separator+username+"app"+CommonConst.FILE_SUFFIX_TXT;
			String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username+CommonConst.SLASH+username+CommonConst.FILE_SUFFIX_TXT;
			String path2=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username+CommonConst.SLASH+username+"app"+CommonConst.FILE_SUFFIX_TXT;
			String host = messages.getMessage("bsa.fileServerIp");
			Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
			String user = messages.getMessage("bsa.ftpUser");
			String password = messages.getMessage("bsa.ftpPassword");
			ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
			ftpLogin.connect(host,port,user,password);
			ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
			ftpFile.doChdir(ToPath, new StringBuffer());
			ftpFile.doMkdir(username, new StringBuffer());
			ftpFile.doPut(localFilename,path, true,new StringBuffer());
			ftpFile.doPut(localFilename2,path2, true,new StringBuffer());
			ftpLogin.disconnect();
			
	}
	
	/**
	 * 导入文件调用作业.
	 * 
	 * @param  String toolcodes,String username
	 */
	public void importtoolstar(String username,String []toolcodes ,String []appsys_codes,String []tool_types) throws Exception{
		String TOOLCODE="";
		String APPSYSCODE="";
		for (int i = 0;i < toolcodes.length; i++) {
			if("1".equals(tool_types[i])){
			
			if(APPSYSCODE.indexOf(appsys_codes[i])==-1){
			APPSYSCODE=APPSYSCODE.concat(appsys_codes[i]).concat(CommonConst.SPACE);    
			}
			TOOLCODE=TOOLCODE.concat(toolcodes[i]).concat(CommonConst.FILE_SUFFIX_TAR).concat(CommonConst.SPACE);       
			  }
		}
		if(TOOLCODE.trim().length()>0){
		toolsImpTxtFile(APPSYSCODE,TOOLCODE,username);
		FTPtoolsImpTxt(username);
		
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String strDate = matter.format(date);
		String workname=strDate+username+"toolsImport";
		
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		//创建作业
			CLITunnelServiceClient cliClientCreatTarJob = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseCreatTarJob = cliClientCreatTarJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"",messages.getMessage("toolbox.bsa.impExpJobPath"),messages.getMessage("toolbox.bsa.importJob"),"2"});
			cliClientCreatTarJob.ResponseCheck4ExecuteCommand(cliResponseCreatTarJob);
			String DBkeyCreatTarJob=(String) cliResponseCreatTarJob.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientTarLinkServer = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTarLinkServer = cliClientTarLinkServer.executeCommandByParamList("Job", "addTargetServer", new String[]{DBkeyCreatTarJob,messages.getMessage("bsa.ipAddress")});
			cliClientTarLinkServer.ResponseCheck4ExecuteCommand(cliResponseTarLinkServer);
			
		//参数及执行作业

			CLITunnelServiceClient cliClientDBkeyTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseDBkeyTar = cliClientDBkeyTar.executeCommandByParamList("NSHScriptJob", "getDBKeyByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientDBkeyTar.ResponseCheck4ExecuteCommand(cliResponseDBkeyTar);
			String dBkeyTar=(String) cliResponseDBkeyTar.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientClean2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseClean2 = cliClientClean2.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
			cliClientClean2.ResponseCheck4ExecuteCommand(cliResponseClean2);
			
			CLITunnelServiceClient cliClientAdduser = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdduser.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"0",messages.getMessage("bsa.fileServerIp").concat(messages.getMessage("toolbox.bsaFileServerPath"))});
			cliClientAdduser.ResponseCheck4ExecuteCommand(cliResponseAdd2);
			
			
			CLITunnelServiceClient cliClientAddTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseAddTar = cliClientAddTar.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname,"1",username});
			cliClientAddTar.ResponseCheck4ExecuteCommand(cliResponseAddTar);
			String addTar=(String) cliResponseAddTar.get_return().getReturnValue();
			
			CLITunnelServiceClient cliClientTar = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseTar = cliClientTar.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", new String[]{dBkeyTar});
			cliClientTar.ResponseCheck4ExecuteCommand(cliResponseTar);
			//删除临时打包作业
		    CLITunnelServiceClient cliClientTarJobDelete2 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponseZipJobDelete2 = cliClientTarJobDelete2.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{messages.getMessage("toolbox.bsa.impExpJobPath"),workname});
		}
	}
	
	
	/**
	 * 文件打包成zip压缩包.
	 * 
	 * @param String sourceFilePath, String zipFilePath,String fileName
	 * @throws IOException
	 */
	public  boolean fileToZip(String sourceFilePath, String zipFilePath,
			String fileName,String tool_code) throws IOException {
		boolean flag = false;
		File sourceFile = new File(sourceFilePath);
		File zipFile=null;
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		FileOutputStream fos = null;
		ZipOutputStream zos = null;
		if (sourceFile.exists() == false) {
			
		} else {
				zipFile = new File(zipFilePath.concat(File.separator).concat(tool_code).concat(".zip"));
				if (zipFile.exists()) {
					
				} else {
					File[] sourceFiles = sourceFile.listFiles();
					if (null == sourceFiles || sourceFiles.length < 1) {
						
					} else {
						fos = new FileOutputStream(zipFile);
						zos = new ZipOutputStream(new BufferedOutputStream(fos));
						zos.setEncoding("GBK");
						byte[] bufs = new byte[1024 * 10];
						for (int i = 0; i < sourceFiles.length; i++) {
							try {
								// 创建ZIP实体,并添加进压缩包

								ZipEntry zipEntry = new ZipEntry(fileName+File.separator+sourceFiles[i].getName());
								zos.putNextEntry(zipEntry);
								// 读取待压缩的文件并写进压缩包里

								fis = new FileInputStream(sourceFiles[i]);
								bis = new BufferedInputStream(fis, 1024 * 10);
								int read = 0;
								while ((read = bis.read(bufs, 0, 1024 * 10)) != -1) {
									zos.write(bufs, 0, read);
								}
							} catch (IOException e) {
								e.printStackTrace();
							}finally{
								if (null != bis){
									bis.close();
								}
								if (null != fis){
									fis.close();
								}
							}
						}
						flag = true;
					}
				}
				if (null != zos){
					zos.close();
				}
				if (null != fos){
					fos.close();
				}
			}

	
		
		File file = new File(sourceFilePath);
	     if (file.exists()){
	    	 File[] files=file.listFiles();
	    	 for(int i=0;i<files.length;i++){
	    		 files[i].delete();
		   }
	    	 file.delete();
	     }
		return flag;
	}
	
	/**
	 * 历史脚本文件打包成zip压缩包.
	 * 
	 * @param String sourceFilePath, String zipFilePath,String fileName
	 * @throws IOException
	 */
	public  boolean scriptfileToZip(String sourceFilePath, String zipFilePath,
			String fileName) throws IOException {
		boolean flag = false;
		File sourceFile = new File(sourceFilePath);
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		FileOutputStream fos = null;
		ZipOutputStream zos = null;
		if (sourceFile.exists() == false) {
			
		} else {
				File zipFile = new File(zipFilePath.concat(File.separator).concat(fileName).concat(".zip"));
				if (zipFile.exists()) {
					
				} else {
					File[] sourceFiles = sourceFile.listFiles();
					if (null == sourceFiles || sourceFiles.length < 1) {
						
					} else {
						fos = new FileOutputStream(zipFile );
						zos = new ZipOutputStream(new BufferedOutputStream(fos));
						zos.setEncoding("gbk");
						byte[] bufs = new byte[1024 * 10];
						for (int i = 0; i < sourceFiles.length; i++) {
							try {
								// 创建ZIP实体,并添加进压缩包
 
								ZipEntry zipEntry = new ZipEntry(sourceFiles[i].getName());
								zos.putNextEntry(zipEntry);
								// 读取待压缩的文件并写进压缩包里

								fis = new FileInputStream(sourceFiles[i]);
								bis = new BufferedInputStream(fis, 1024 * 10);
								int read = 0;
								while ((read = bis.read(bufs, 0, 1024 * 10)) != -1) {
									zos.write(bufs, 0, read);
								}
							} catch (IOException e) {
								e.printStackTrace();
							}finally{
								if (null != bis){
									bis.close();
								}
								if (null != fis){
									fis.close();
								}
							}
						}
						flag = true;
					}
				}
				if (null != zos){
					zos.close();
				}
				if (null != fos){
					fos.close();
				}
			}
		
		return flag;
	}
	

	/**
	 *上传10.1.32.1 ZIP文件
	 * 
	 * @param toolcodetar
     * @param username
	 * @throws IOException 
	 */
	@Transactional
	public void exportToolstar(String toolcodetar,String username) throws FtpCmpException, IOException {
		
		String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator +username;
		String localFilename=filepath+File.separator+toolcodetar+CommonConst.FILE_SUFFIX_ZIP;
		String path=messages.getMessage("exportServer.toolpath")+CommonConst.SLASH+messages.getMessage("exportServer.toolboxPath")+CommonConst.SLASH+toolcodetar+CommonConst.FILE_SUFFIX_ZIP;
		String datapath=messages.getMessage("exportServer.toolpath");
		String exppath =messages.getMessage("importServer.toolboxPath");
		
		String host = messages.getMessage("exportServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("exportServer.user");
		String password = messages.getMessage("exportServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdirs(datapath,exppath);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.doPut(localFilename,path, true,new StringBuffer());
		ftpLogin2.disconnect();
		
	}
	
	/**
	 * 
	 * 删除文件夹里面的所有文件.
	 * 
	 * @param path String 文件夹路径.
	 * 
	 */
	public void delFile(String username,String file_name){
		String path = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator +file_name;
		String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+username+CommonConst.FILE_SUFFIX_TXT;
		String filepath2 = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+username+"app"+CommonConst.FILE_SUFFIX_TXT;
		File file = new File(path);
		if (file.exists()){
	    	 File[] files=file.listFiles();
	    	
	    	 for(int i=0;i<files.length;i++){
	    		 if(files[i].isFile()){
	    			 files[i].delete();
	    		 }
	    		 else{
	    			 File[] ff=files[i].listFiles();
		    		 for(int j=0;j<ff.length;j++){
		    		 ff[j].delete();
	    		 }
		    		 files[i].delete(); 
		      }
	     }
	    	 file.delete();
	  }
	     
	     File file2 = new File(filepath);
	     if (file2.exists()){
	    	 file2.delete();
		}
	     File file3 = new File(filepath2);
	     if (file3.exists()){
	    	 file3.delete();
		}
	}
	
	/**
	 * 
	 * 删除导出文件夹里面的所有文件.
	 * 
	 * @param username.
	 * 
	 */
	public void delAllexportFile(String username){
		String path = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator +username;
		File file = new File(path);
	     if (file.exists()){
	    	 File[] files=file.listFiles();
	    	
	    	 for(int i=0;i<files.length;i++){
	    		 if(files[i].isFile()){
	    			 files[i].delete();
	    		 }
	    		 else{
	    			 File[] ff=files[i].listFiles();
		    		 for(int j=0;j<ff.length;j++){
		    		 ff[j].delete();
	    		 }
		    		 files[i].delete(); 
		      }
	     }
	    	 file.delete();
	  }
	}
	
	
	/**
	 * 
	 * 删除导入文件夹里面的所有文件.
	 * 
	 * @param username
	 * 
	 */
	public void delAllimportFile(String username){
		String path = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator +username;
		File file = new File(path);
	     if (file.exists()){
	    	 File[] files=file.listFiles();
	    	
	    	 for(int i=0;i<files.length;i++){
	    		 if(files[i].isFile()){
	    			 files[i].delete();
	    		 }
	    		 else{
	    			 File[] ff=files[i].listFiles();
		    		 for(int j=0;j<ff.length;j++){
		    		 ff[j].delete();
	    		 }
		    		 files[i].delete(); 
		      }
	     }
	    	 file.delete();
	}
	}
	
	
    /**
	 * FTP在文件服务器备份文件
	 * @param username
	 * @param toolcode
     * @throws IOException 
	 */
	@Transactional
	public  void ftpDelToolstar(String username,String toolcode,String file_name) throws FtpCmpException, IOException {
		
		delFile(username,file_name);
		
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String time=new SimpleDateFormat("HHmmss").format(new Date());
		String strDate = matter.format(date);
		
		String datapath=messages.getMessage("exportServer.toolpath");
		String bak =messages.getMessage("exportServer.bakPath")+CommonConst.SLASH+messages.getMessage("importServer.toolboxPath");
		
		String to=datapath+CommonConst.SLASH+bak+CommonConst.SLASH+strDate+CommonConst.SLASH+toolcode+time+".zip";
		String path=messages.getMessage("importServer.toolpath")+CommonConst.SLASH+messages.getMessage("importServer.toolboxPath");
		String from =path+CommonConst.SLASH+toolcode+".zip";
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		
		ftpFile.doMkdirs(datapath,bak);
		ftpFile.doMkdir(strDate, new StringBuffer());
		ftpLogin.disconnect();
		
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
        ftpFile2.renamelFile(from, to);
		ftpLogin2.disconnect();

	}
	
/**
	 * FTP在DB服务器获取历史脚本目录
	 * 
	 * @param customer
	 * @throws IOException 
	 */
	@Transactional
	public  List<String> ftpgetHistoryTools(String appsys_code,String tool_code,String shell_name) throws FtpCmpException, IOException {
		
		String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+messages.getMessage("toolbox.DBServerToolBak")+CommonConst.SLASH+appsys_code;
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		String[] scrppts=ftpFile.doGetFilesNamelist(path);
		ftpLogin.disconnect();
		List<String> script=new ArrayList<String>();
		for(int i=0;i<scrppts.length;i++){
			String s=scrppts[i].substring(scrppts[i].indexOf("_")+1);
			String t= tool_code+shell_name.substring(shell_name.lastIndexOf("."));
		
			if(s.equals(t)){
				script.add(scrppts[i].toString());
			};
		}
		
		
		return script;

	}
	
	
	/**
	 * FTP在文件服务器获取文件
	 * 
	 * @param customer
	 * @throws IOException 
	 */
	@Transactional
	public  void ftpGetFileList() throws FtpCmpException, IOException {
		String username=securityUtils.getUser().getUsername() ;
		String filePath=System.getProperty("maop.root") +File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username;
		File file = new File(filePath);
	     if (!file.exists()){
	    	 file.mkdirs();
	     }else{
	    	 delAllimportFile(username);
	    	 file.mkdirs();
	     }
		String path=messages.getMessage("importServer.toolpath")+CommonConst.SLASH+messages.getMessage("importServer.toolboxPath");
		String host = messages.getMessage("importServer.ipAdress");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("importServer.user");
		String password = messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
        ftpFile.doGetFiles(path, filePath, new StringBuffer());
		ftpLogin.disconnect();
		
	    this.unZip(username);
		
	}
	
	
	
	/**
	 * 读取文件
	 * @param path
	 *            String 文件夹路径

	 * 
	 * @return File[]
	 */
	public File[] printAllFile(File fpath) {
		File[] flist = fpath.listFiles();
		for (File f : flist) {
			if (f.isFile()) {
			} else if (f.isDirectory()) {
				printAllFile(f);
			}
		}
		return flist;
	}
	/**
	 * 
	 * 解压zip文件包	 * @param String
	 *            path,String appsys_code
	 * @throws IOException
	 */
	public void unZip(String username) throws IOException {
		
		 String zipFilePath=System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxImpPath")+File.separator +username;
		String fName = null;
		File fpath = new File(zipFilePath);
		File[] flist = printAllFile(fpath);
		for (File f : flist) {
			if (f.isFile()) {
				fName = f.getName();
					int count = -1;
					int index = -1;
					String savepath = "";
					boolean flag = false;

					File file = null;
					InputStream is = null;
					FileOutputStream fos = null;
					BufferedOutputStream bos = null;

					savepath = zipFilePath;
					String path2 = zipFilePath.concat(File.separator ).concat(fName) ;

					ZipFile zipFile = new ZipFile(path2, "GBK");

					Enumeration<?> entries = zipFile.getEntries();

					while (entries.hasMoreElements()) {
						byte buf[] = new byte[buffer];

						ZipEntry entry = (ZipEntry) entries.nextElement();

						String filename = entry.getName();
						index = filename.lastIndexOf(messages
								.getMessage("path.linux"));
						/*if (index > -1)
							filename = filename.substring(index + 1);*/

						filename = savepath.concat(File.separator).concat(filename) ;
						File sourceFile = new File(savepath.concat(File.separator) );
						if (!sourceFile.exists()) {
							sourceFile.mkdirs();
						}
						file = new File(filename);
						File file2 =new File(filename.substring(0,filename.lastIndexOf(File.separator)));
						if(!file2.exists()){
							file2.mkdirs();
						}
						file.createNewFile();

						is = zipFile.getInputStream(entry);

						fos = new FileOutputStream(file);

						bos = new BufferedOutputStream(fos, buffer);

						while ((count = is.read(buf)) > -1) {
							bos.write(buf, 0, count);
						}

						fos.close();

						is.close();
					}

					zipFile.close();
					
				}
		}
	}
	/*public void unZip(String username, String toolcode,String file_name) throws IOException {
		
		 String zipFilePath=System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxImpPath")+File.separator +username;
		String fName = null;
		File fpath = new File(zipFilePath);
		File[] flist = printAllFile(fpath);
		for (File f : flist) {
			if (f.isFile()) {
				fName = f.getName();
				int indexOf = fName.indexOf(toolcode);
				if (indexOf != -1) {
					int count = -1;
					int index = -1;
					String savepath = "";
					boolean flag = false;

					File file = null;
					InputStream is = null;
					FileOutputStream fos = null;
					BufferedOutputStream bos = null;

					savepath = zipFilePath;
					String path2 = zipFilePath.concat(File.separator ).concat(fName) ;

					ZipFile zipFile = new ZipFile(path2, "GBK");

					Enumeration<?> entries = zipFile.getEntries();

					while (entries.hasMoreElements()) {
						byte buf[] = new byte[buffer];

						ZipEntry entry = (ZipEntry) entries.nextElement();

						String filename = entry.getName();
						index = filename.lastIndexOf(messages
								.getMessage("path.linux"));
						if (index > -1)
							filename = filename.substring(index + 1);

						filename = savepath.concat(File.separator) .concat(toolcode)
								.concat(File.separator).concat(filename) ;
						File sourceFile = new File(savepath.concat(File.separator).concat(toolcode) 
								.concat(File.separator) );
						if (!sourceFile.exists()) {
							sourceFile.mkdirs();
						}
						file = new File(filename);
						file.createNewFile();

						is = zipFile.getInputStream(entry);

						fos = new FileOutputStream(file);

						bos = new BufferedOutputStream(fos, buffer);

						while ((count = is.read(buf)) > -1) {
							bos.write(buf, 0, count);
						}

						fos.close();

						is.close();
					}

					zipFile.close();
					
				}
			}
		}
	}*/
	/**
	 * FTP在测试介质服务器获取tar文件
	 * @param username
	 * @param toolcodetar
	 */
	@Transactional
	public  void ftpGettarFile(String username,String toolcodetar,String filename) throws FtpCmpException {
		
		String filePath=System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxExpPath")+File.separator +username+File.separator+filename+File.separator+toolcodetar+CommonConst.FILE_SUFFIX_TAR;
		String ToPath=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username;
		String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username+CommonConst.SLASH+toolcodetar+CommonConst.FILE_SUFFIX_TAR;
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doChdir(ToPath, new StringBuffer());
        ftpFile.doGet(path, filePath, true,new StringBuffer());
		ftpLogin.disconnect();

	}
	

	/**
	 * FTP上传到生产介质服务器 tar文件
	 * @param username
	 * @param toolcode
	 */
	@Transactional
	public  void ftpPutToolstar(String username,String toolcode,String filename) throws FtpCmpException {
		
		String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename;
		String ToPath=messages.getMessage("toolbox.bsaFileServerPath");
		String ToPath2=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username;
		String localFilename=filepath+File.separator+toolcode+CommonConst.FILE_SUFFIX_TAR;
		File localFile=new File(localFilename);
		if(localFile.exists()){
		String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+username+CommonConst.SLASH+toolcode+CommonConst.FILE_SUFFIX_TAR;
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doChdir(ToPath, new StringBuffer());
		ftpFile.doMkdir(username, new StringBuffer());
		ftpFile.doChdir(ToPath2, new StringBuffer());
		ftpFile.doPut(localFilename,path, true,new StringBuffer());
		ftpLogin.disconnect();
		}
	}



	/**
	 * 根据条件查找导入信息记录
	 * 
	 * @param appsys_code
	 * @throws ParseException
	 * @throws IOException
	 */
	@Transactional(readOnly = true)
	public Object getToolslist(String appsys_code) throws ParseException,
			IOException, HttpHostConnectException,FtpCmpException {
		String username=securityUtils.getUser().getUsername() ;
		List<Map<String, String>> jsonMapList = new ArrayList<Map<String, String>>();
		
			String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxImpPath")+File.separator+username;
			File[] arrFile = new File(filepath).listFiles();			
	
			//获取所有请求名称

			for (File ff : arrFile) {
				if (ff.isDirectory()) {
					Map<String,String> map = new HashMap<String,String>();
					    String f=ff.getAbsoluteFile().getName();
						map.put("appsys_code", f.split(CommonConst.UNDERLINE)[0]);
						
						String tool_type=f.split(CommonConst.UNDERLINE)[1].toString();
						map.put("tool_type",tool_type );
						
						String	tool_code=f.split(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE)[1];
						//String	tool_name=(f.split(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE)[2]).split(CommonConst.DOT)[0].toString();
						String	tool_name=(f.split(CommonConst.REPLACE_CHAR_BETWEEN_DOUBLE_UDERLINE)[2]).toString();
						map.put("tool_code", tool_code);
						map.put("tool_name",tool_name);
						map.put("file_name",f);
						jsonMapList.add(map);
				}
			}
			if(appsys_code!=null && !"".equals(appsys_code)){
				List<Map<String, String>> jsonMapList2 = new ArrayList<Map<String, String>>();
				for(int i = 0; i < jsonMapList.size(); i++){
					if(jsonMapList.get(i).get("appsys_code").equals(appsys_code)){
						Map<String,String> map2 = new HashMap<String,String>();
						map2.put("appsys_code",jsonMapList.get(i).get("appsys_code"));
						map2.put("tool_code", jsonMapList.get(i).get("tool_code") );
						map2.put("tool_type",jsonMapList.get(i).get("tool_type"));
						map2.put("tool_name", jsonMapList.get(i).get("tool_name") );
						map2.put("file_name", jsonMapList.get(i).get("file_name") );
						
						jsonMapList2.add(map2);
					};
				 }
				return jsonMapList2;
			}else{
				List<Map<String, String>> jsonMapList3 = new ArrayList<Map<String, String>>();
				List<String> appcodelist = appInfoService.getPersonalSysListForTool();
				for(int j=0;j<appcodelist.size();j++){
					appsys_code =appcodelist.get(j);
					if(appsys_code!=null && !"".equals(appsys_code)){
					for(int i = 0; i < jsonMapList.size(); i++){
						if(jsonMapList.get(i).get("appsys_code").equals(appsys_code)){
							Map<String,String> map3 = new HashMap<String,String>();
							map3.put("appsys_code",jsonMapList.get(i).get("appsys_code"));
							map3.put("tool_code", jsonMapList.get(i).get("tool_code") );
							map3.put("tool_type",jsonMapList.get(i).get("tool_type"));
							map3.put("tool_name", jsonMapList.get(i).get("tool_name") );
							map3.put("file_name", jsonMapList.get(i).get("file_name") );
							jsonMapList3.add(map3);
						};
					  }
					}
				}
				return jsonMapList3;
			}
			
			
		
	}
	
	
	/**
	 * 读取工具公共属性文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxInfoVo> readToolBoxInfoVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		
		
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		
		String toolboxinfo=toolcode+CommonConst.FILE_SUFFIX_DAT;
		
		String crlf=System.getProperty("line.separator");
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxInfoVo> toolboxinfoList = new ArrayList<ToolBoxInfoVo>();
		ToolBoxInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxInfoVo();
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setAppsys_code(typicalCapaAnaArr[1]); 
				vo.setTool_name(typicalCapaAnaArr[2]);
				vo.setTool_desc(typicalCapaAnaArr[3].replaceAll("@#@", CommonConst.CHANGE_LINE));
				vo.setAuthorize_level_type(typicalCapaAnaArr[4]);
				vo.setField_type_one(typicalCapaAnaArr[5]);
				vo.setField_type_two(typicalCapaAnaArr[6]);
				vo.setField_type_three(typicalCapaAnaArr[7]);
				vo.setTool_authorize_flag(typicalCapaAnaArr[8]);
				vo.setTool_type(typicalCapaAnaArr[9]);
				vo.setDelete_flag(typicalCapaAnaArr[10]);
				
				toolboxinfoList.add(vo);
			
			
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxinfoList;
		
		
	}
	
	
	/**
	 * 读取脚本工具文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxScriptInfoVo> readToolBoxScriptInfoVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		
		
		
		String toolboxscriptinfo=toolcode+"Script"+CommonConst.FILE_SUFFIX_DAT;
		
		String crlf=System.getProperty("line.separator");
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxscriptinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxScriptInfoVo> toolboxscriptinfoList = new ArrayList<ToolBoxScriptInfoVo>();
		ToolBoxScriptInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxScriptInfoVo();
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setShell_name(typicalCapaAnaArr[1]);
				vo.setServer_group(typicalCapaAnaArr[2]);
				vo.setGroup_server_flag(typicalCapaAnaArr[3]);
				vo.setOs_user_flag(typicalCapaAnaArr[4]);
				vo.setOs_user(typicalCapaAnaArr[5]);
				vo.setOs_type(typicalCapaAnaArr[6]);
				vo.setPosition_type(typicalCapaAnaArr[7]);
				vo.setTool_charset(typicalCapaAnaArr[8]);
				toolboxscriptinfoList.add(vo);
			
			
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxscriptinfoList;
		
		
	}
	
	
	/**
	 * 读取描述工具文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxDescInfoVo> readToolBoxDescInfoVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		
		String toolboxdescinfo=toolcode +"Desc"+CommonConst.FILE_SUFFIX_DAT;
		
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxdescinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxDescInfoVo> toolboxdescinfoList = new ArrayList<ToolBoxDescInfoVo>();
		ToolBoxDescInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxDescInfoVo();
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setTool_content(typicalCapaAnaArr[1]);
				
				toolboxdescinfoList.add(vo);
			
			
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxdescinfoList;
		
		
	}
	
	/**
	 * 读取工具文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxFilesVo> readToolBoxFilesVoFromFile(String username,String toolcode,String filenamwe) 
			throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		String toolboxparaminfo=toolcode+"DescFiles.dat";
		
		String filePath = System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filenamwe+File.separator+toolboxparaminfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXPARAMINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxFilesVo> toolboxfilesList = new ArrayList<ToolBoxFilesVo>();
		ToolBoxFilesVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxFilesVo();
			
				vo.setTool_code(typicalCapaAnaArr[0]); 
				vo.setFile_id(typicalCapaAnaArr[1]);
				
				vo.setFile_name(typicalCapaAnaArr[2]);
				vo.setFile_type(typicalCapaAnaArr[3]);
				vo.setFile_content( StringUtil.hexToBytes(typicalCapaAnaArr[4].toString()));
				toolboxfilesList.add(vo);
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxfilesList;
		
		
	}
	
	
	
	/**
	 * 读取策略文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxEventGroupInfoVo> readToolBoxEventGroupInfoVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		
		String toolboxeventgroupinfo=toolcode +"Eventgroup"+CommonConst.FILE_SUFFIX_DAT;
		
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxeventgroupinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxEventGroupInfoVo> toolboxeventgroupinfoList = new ArrayList<ToolBoxEventGroupInfoVo>();
		ToolBoxEventGroupInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxEventGroupInfoVo();
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setEvent_group(typicalCapaAnaArr[1]);
				
				toolboxeventgroupinfoList.add(vo);
			
			
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxeventgroupinfoList;
		
		
	}
	
	
	
	/**
	 * 读取描述工具文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxKeyWordInfoVo> readToolBoxKeyWordInfoVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		
		String toolboxkeywordinfo=toolcode +"Summarycn"+CommonConst.FILE_SUFFIX_DAT;
		
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxkeywordinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxKeyWordInfoVo> toolboxkeywordinfoList = new ArrayList<ToolBoxKeyWordInfoVo>();
		ToolBoxKeyWordInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxKeyWordInfoVo();
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setSummarycn(typicalCapaAnaArr[1]);
				
				toolboxkeywordinfoList.add(vo);
			
			
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxkeywordinfoList;
		
		
	}
	
	
	@Transactional
	public List<ToolBoxExtendAttriVo> readToolBoxExtendAttriVoFromFile(String username,String toolcode,String filename) throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		String toolboxinfo=toolcode+"Attri"+CommonConst.FILE_SUFFIX_DAT;
		
		
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filename+File.separator+toolboxinfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXEXTENDATTRI_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxExtendAttriVo> toolboxextendattriList = new ArrayList<ToolBoxExtendAttriVo>();
		ToolBoxExtendAttriVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxExtendAttriVo();
			
				
				vo.setTool_code(typicalCapaAnaArr[0]);
				vo.setTool_status("0");
				vo.setTool_returnreasons("");
				
				toolboxextendattriList.add(vo);
			
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxextendattriList;
		
		
	}
	
    /**
	 * 导入工具箱公共属性工具

	 * @param toolboxinfoList 
	 * @param importtoolboxinfolist 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */

	

	public void saveOrUpdateToolboxinfo(List<ToolBoxInfoVo> toolboxList) {
		 String username=securityUtils.getUser().getUsername() ;
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		for(int i=0;i<toolboxList.size();i++){
			ToolBoxInfoVo vo=toolboxList.get(i);
			vo.setTool_creator(username);
			vo.setTool_created_time(Timestamp.valueOf(created_time.concat(".000").toString()));
			vo.setTool_modifier(username);
			vo.setTool_updated_time(Timestamp.valueOf(created_time.concat(".000").toString()));
			saveOrUpdate(vo);
		}
	}
	
	
	
	
	/**
	 * 处理导入脚本工具信息
	 * @return
	 */
	

	
	public void saveOrUpdateToolboxscriptinfo(List<ToolBoxScriptInfoVo> toolboxscriptinfoList) {
		
		for(int i=0;i<toolboxscriptinfoList.size();i++){
			ToolBoxScriptInfoVo vo=toolboxscriptinfoList.get(i);
			
			this.saveOrUpdatetoolboxscriptinfo(vo);
		}
	}
	
	
	/**
	 * 处理导入描述工具信息
	 * @return
	 */
	

	
	public void saveOrUpdateToolboxdescinfo(List<ToolBoxDescInfoVo> toolboxDescinfoList) {
		
		for(int i=0;i<toolboxDescinfoList.size();i++){
			ToolBoxDescInfoVo vo=toolboxDescinfoList.get(i);
			
			this.saveOrUpdatetoolboxdescinfo(vo);
		}
	}
	
	/**
	 * 处理导入描述工具信息
	 * @return
	 */
	

	
	public void saveOrUpdateToolboxdescfilesinfo(List<ToolBoxFilesVo> toolboxDescfilesList) {
		
		for(int i=0;i<toolboxDescfilesList.size();i++){
			ToolBoxFilesVo vo=toolboxDescfilesList.get(i);
			this.saveOrUpdatetoolboxdescfileinfo(vo);
		}
	}
	
	
	/**
	 * 处理导入关键字信息
	 * @return
	 */
	
	public void saveOrUpdateToolboxkeywordinfo(List<ToolBoxKeyWordInfoVo> toolboxkeywordinfoList) {
		 
		for(int i=0;i<toolboxkeywordinfoList.size();i++){
			ToolBoxKeyWordInfoVo vo=toolboxkeywordinfoList.get(i);
			
			this.saveOrUpdatetoolboxkeywordinfo(vo);
		}
	}
	
	
	/**
	 * 处理导入策略信息
	 * @return
	 */
	
	public void saveOrUpdateToolboxeventgroupinfo(List<ToolBoxEventGroupInfoVo> toolboxeventgroupinfoList) {
		
		for(int i=0;i<toolboxeventgroupinfoList.size();i++){
			ToolBoxEventGroupInfoVo vo=toolboxeventgroupinfoList.get(i);
			
			this.saveOrUpdatetoolboxeventgroupinfo(vo);
		}
	}
	
	/**
	 * 处理导入信息
	 * @return
	 */

	
	public void saveOrUpdateToolboxextendattri(List<ToolBoxExtendAttriVo> toolboxextendattriList) {
		
		for(int i=0;i<toolboxextendattriList.size();i++){
			ToolBoxExtendAttriVo vo=toolboxextendattriList.get(i);
					vo.setTool_received_time(null);
					vo.setTool_received_user(null);
			this.saveOrUpdatetoolboxextendattri(vo);
		}
	}
	
	
	/**
	 * 批量修改授权级别
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void updateAuthorizeflag(String[] tool_codes, String[] appsys_codes,String tool_authorize_flag) throws SQLException {
		for (int i = 0; i < tool_codes.length && i < appsys_codes.length; i++) {
			updateAuthorizeID(tool_codes[i], appsys_codes[i],tool_authorize_flag);
		}
	}

	/**
	 * 修改授权级别

	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	public void updateAuthorizeID(String tool_code, String appsys_code,String tool_authorize_flag)throws SQLException {
		getSession().createQuery(
						"update  ToolBoxInfoVo tb set tb.tool_authorize_flag=? where tb.tool_code = ? and tb.appsys_code= ?")
				.setString(0, tool_authorize_flag).setString(1, tool_code).setString(2, appsys_code)
				.executeUpdate();
	}
	/**
	 * 批量修改删除标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(String[] tool_codes, String[] appsys_codes) throws SQLException {
		for (int i = 0; i < tool_codes.length && i < appsys_codes.length; i++) {
			Date startDate = new Date();
			String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

			deleteById(tool_codes[i], appsys_codes[i]); //执行删除操作
			//插入执行日志表

			
			String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
			String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
			CmnLogVo cmnLog = new CmnLogVo(); 
			cmnLog.setAppsysCode(appsys_codes[i]);
			cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
			cmnLog.setRequestName(tool_codes[i]+"_delete");
			cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
			cmnLog.setExecStatus(logState);
			cmnLog.setExecDate(execdate);
			cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
			Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cmnLog.setExecCompletedTime(ts);
			cmnLog.setExecCreatedTime(ts);
			cmnLog.setExecUpdatedTime(ts);
			cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
			cmnLogService.save(cmnLog);
		}
	}
	
	/**
	 * 修改删除标示 
	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteById(String tool_code, String appsys_code)throws SQLException {
		getSession().createQuery(
						"update  ToolBoxInfoVo tb set tb.delete_flag='1' where tb.tool_code = ? and tb.appsys_code= ?")
				.setString(0, tool_code).setString(1, appsys_code)
				.executeUpdate();
	}
	/**
	 * 批量 删除附件 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByfile_ids(String[] tool_codes, String[] file_ids) throws SQLException {
		for (int i = 0; i < tool_codes.length && i < file_ids.length; i++) {
			

			deleteByfile_id(tool_codes[i], file_ids[i]); //执行删除操作

		}
	}
	/**
	 * 删除附件
	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteByfile_id(String tool_code, String file_id)throws SQLException {
		getSession().createQuery(
						"delete from  ToolBoxFilesVo tb   where tb.tool_code = ? and tb.file_id= ?")
				.setString(0, tool_code).setString(1, file_id)
				.executeUpdate();
	}
	
	
	/**
	 * 批量 删除附件 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByOccfile_ids(String[] tool_codes, String[] file_ids) throws SQLException {
		for (int i = 0; i < tool_codes.length && i < file_ids.length; i++) {
			

			deleteByOccfile_id(tool_codes[i], file_ids[i]); //执行删除操作

		}
	}
	/**
	 * 删除附件
	 * @param tool_code
	 * @param appsys_code
	 */
	public void deleteByOccfile_id(String tool_code, String file_id)throws SQLException {
		getSession().createQuery(
						"delete from  OccToolBoxFilesVo tb   where tb.tool_code = ? and tb.file_id= ?")
				.setString(0, tool_code).setString(1, file_id)
				.executeUpdate();
	}
	
	
	/**
	 * 保存导出数据.
	 * 
	 * @param customer
	 */
	@Transactional
	public void ftpGetScript(String downloadPath,String ftpPath)throws FtpCmpException {
		
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doGet(ftpPath, downloadPath, true,new StringBuffer());
		ftpLogin.disconnect();
	}
	/**
	 * 将介质脚本下发被管服务器，并执行脚本.
	 * @return
	 * @throws IOException
	 * @throws InterruptedException 
	 * @throws SQLException 
	 */
	
	public int nexecCmd(String[] serverIps, String[] server_routes,String shellname, String[] paramvalues,String[] paramnames,
			String osuser,String[] osusers,String appsyscode ,String group_osuser,String position_type,
			String serverGroup,String toolcharset,String os_type) 
					throws IOException, InterruptedException, SQLException {
		String username = securityUtils.getUser().getUsername() ;
		int existValue = -1;
		String cmdExe = "";
		String option = "";
		String params = "";
		String server_route="";
		String scrpictsuffix=shellname.substring(shellname.lastIndexOf('.') + 1).toLowerCase();
		Process process=null;
		if (scrpictsuffix.equals("bat")) {
		for (int c = 0; c < paramvalues.length; c++){
			String param=paramnames[c]+"="+CommonConst.DAN_QUOTATION_MARK +paramvalues[c]+CommonConst.DAN_QUOTATION_MARK;
			params = params  +param+ CommonConst.SPACE;
		}
		}else{
			for (int c = 0; c < paramvalues.length; c++){
				String param=paramnames[c]+"="+"\\"+CommonConst.DAN_QUOTATION_MARK +CommonConst.DAN_QUOTATION_MARK+paramvalues[c]+CommonConst.DAN_QUOTATION_MARK+"\\"+CommonConst.DAN_QUOTATION_MARK;
				params = params  +param+ CommonConst.SPACE;
			}
		}
		for (int k = 0; k < serverIps.length; k++) {
			Thread.sleep(100);
			Long currentTime = System.currentTimeMillis();
			StringBuilder cmd = new StringBuilder();
			String scrpict;
			if (isWindows) {
				if(position_type.contains("1")){
					
					
					if(scrpictsuffix.equals("bat")){
						
						scrpict = messages.getMessage("toolbox.bsaServerBatBat");
					}else{
						scrpict = messages.getMessage("toolbox.bsaServerShellBat");
					}
					
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k])
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SLASH)
					  .append(appsyscode)
					  .append(CommonConst.SLASH);
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(shellname)
					  .append(CommonConst.SPACE);
					  if(scrpictsuffix.equals("bat")){
						  cmd.append(messages.getMessage("toolbox.servercpPath"))
						  .append(CommonConst.SLASH);
					  }else{
						  cmd.append(messages.getMessage("toolbox.serverPath"))
						  .append(CommonConst.SLASH);
						  }
					    if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					    }else{
						  cmd.append(os_type);
					    }
				      cmd.append(CommonConst.SLASH)
					     .append(username)
					     .append(CommonConst.SPACE);
				
				if(!scrpictsuffix.equals("bat")){
					if(osuser.length()>0){
						cmd.append(osuser);
					}else if(group_osuser.length()>0){
						cmd.append(group_osuser);
					}else{
						cmd.append(osusers[k]);
					}
				}else{
					cmd.append(CommonConst.SPACE)
					   .append(CommonConst.DAN_QUOTATION_MARK)
					   .append(messages.getMessage("toolbox.serverexPath"))
					   .append(CommonConst.RIGHT_SLASH)
					   .append(CommonConst.RIGHT_SLASH);
					if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					    }else{
						  cmd.append(os_type);
					    }
				      cmd.append(CommonConst.RIGHT_SLASH)
				         .append(CommonConst.RIGHT_SLASH)
					     .append(username)
					     .append(CommonConst.DAN_QUOTATION_MARK)
					     .append(CommonConst.SPACE);
					 
				}
				cmd.append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				
				}else{
					
					if(scrpictsuffix.equals("bat")){
						server_route =server_routes[k].replaceAll("\\\\" , "\\\\\\\\");
						scrpict = messages.getMessage("toolbox.bsaTargetServerBatBat");
					}else{
						scrpict = messages.getMessage("toolbox.bsaTargetServerShellBat");
					}
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k]);
					  cmd.append(CommonConst.SPACE)
				      .append(CommonConst.DAN_QUOTATION_MARK)
				      .append(server_routes[k])
					 // .append(server_route)
					  .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(CommonConst.SPACE);
		 if(!scrpictsuffix.equals("bat")){
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
				
			 }
				cmd.append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}
				cmdExe = Constants.CMD_COMMAND;
				option = "/C";
			} else {
				
				if(position_type.contains("1")){
					if(scrpictsuffix.equals("bat")){
						
						scrpict = messages.getMessage("toolbox.bsaServerBatShellForLinux");
					}else{
						scrpict = messages.getMessage("toolbox.bsaServerShellShellForLinux");
					}
					
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k])
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SLASH)
					  .append(appsyscode)
					  .append(CommonConst.SLASH);
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(shellname)
					  .append(CommonConst.SPACE);
				   if(scrpictsuffix.equals("bat")){
						  cmd.append(messages.getMessage("toolbox.servercpPath"))
						  .append(CommonConst.SLASH);
					  }else{
						  cmd.append(messages.getMessage("toolbox.serverPath"))
						  .append(CommonConst.SLASH);
						  }
					 
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(username)
					  .append(CommonConst.SPACE);
		 if(!scrpictsuffix.equals("bat")){   
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
		 }else{
		
				cmd.append(CommonConst.SPACE)
				   .append(CommonConst.DAN_QUOTATION_MARK)
				   .append(messages.getMessage("toolbox.serverexPath"))
				   .append(CommonConst.RIGHT_SLASH)
				   .append(CommonConst.RIGHT_SLASH);
				if(serverGroup.length()>0){
					  cmd.append(serverGroup);
				    }else{
					  cmd.append(os_type);
				    }
			      cmd.append(CommonConst.RIGHT_SLASH)
			         .append(CommonConst.RIGHT_SLASH)
				     .append(username)
				     .append(CommonConst.DAN_QUOTATION_MARK)
				     .append(CommonConst.SPACE);
				 
			}
				cmd.append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}else{
					if(scrpictsuffix.equals("bat")){
						server_route =server_routes[k].replaceAll("\\\\" , "\\\\\\\\");
						scrpict = messages.getMessage("toolbox.bsaTargetServerBatShellForLinux");
					}else{
						server_route=server_routes[k];
						scrpict = messages.getMessage("toolbox.bsaTargetServerShellShellForLinux");
					}
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k]);
				cmd.append(CommonConst.SPACE)
				      .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(server_route)
					  .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(CommonConst.SPACE);
			 if(!scrpictsuffix.equals("bat")){      
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
			 }
				cmd.append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}
				cmdExe = Constants.SHELL_COMMAND;
				option = "-c";
			}
			String key = securityUtils.getUser().getUsername() + "_" + serverIps[k]+"_"+shellname;
			if(readerMap.get(key) == null){
			String[] exec = new String[] {cmdExe, option, cmd.toString()};
			ProcessBuilder pb = new ProcessBuilder(exec);
			// 连接输入流和错误流的管道输出
			pb.redirectErrorStream(true);
			process = pb.start();
			
			BufferedReader reader = null;
				try {
					
					reader = new BufferedReader(new InputStreamReader(process.getInputStream(),toolcharset));
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
				readerMap.put(key, reader);
				
			}
		}
		return existValue;
	}
	
	/*public int nexecCmd(String[] serverIps, String[] server_routes,String shellname, String[] paramvalues,String[] paramnames,
			String osuser,String[] osusers,String appsyscode ,String group_osuser,String position_type,
			String serverGroup,String toolcharset,String os_type
		,String repetitions,String time_interval
		)throws IOException, InterruptedException, SQLException {
		String username = securityUtils.getUser().getUsername() ;
		int existValue = -1;
		String cmdExe = "";
		String option = "";
		String params = "";
		String server_route="";
		String scrpictsuffix=shellname.substring(shellname.lastIndexOf('.') + 1).toLowerCase();
		Process process=null;
		if (scrpictsuffix.equals("bat")) {
			//String pa1="repetitions="+CommonConst.DAN_QUOTATION_MARK+repetitions+CommonConst.DAN_QUOTATION_MARK;
			//String pa2="time_interval="+CommonConst.DAN_QUOTATION_MARK+time_interval+CommonConst.DAN_QUOTATION_MARK;
			params =params +repetitions+CommonConst.SPACE +time_interval+CommonConst.SPACE;
		for (int c = 0; c < paramvalues.length; c++){
			String param=paramnames[c]+"="+CommonConst.DAN_QUOTATION_MARK +paramvalues[c]+CommonConst.DAN_QUOTATION_MARK;
			params = params  +param+ CommonConst.SPACE;
		}
		
		
		}else{
			//String pa1="repetitions="+"\\"+CommonConst.DAN_QUOTATION_MARK +CommonConst.DAN_QUOTATION_MARK+repetitions+CommonConst.DAN_QUOTATION_MARK+"\\"+CommonConst.DAN_QUOTATION_MARK;
			//String pa2="time_interval="+"\\"+CommonConst.DAN_QUOTATION_MARK +CommonConst.DAN_QUOTATION_MARK+time_interval+CommonConst.DAN_QUOTATION_MARK+"\\"+CommonConst.DAN_QUOTATION_MARK;
			params =params +repetitions+CommonConst.SPACE +time_interval+CommonConst.SPACE;
			for (int c = 0; c < paramvalues.length; c++){
				String param=paramnames[c]+"="+"\\"+CommonConst.DAN_QUOTATION_MARK +CommonConst.DAN_QUOTATION_MARK+paramvalues[c]+CommonConst.DAN_QUOTATION_MARK+"\\"+CommonConst.DAN_QUOTATION_MARK;
				params = params  +param+ CommonConst.SPACE;
			}
			
		}
		
		
		
		for (int k = 0; k < serverIps.length; k++) {
			Thread.sleep(100);
			Long currentTime = System.currentTimeMillis();
			StringBuilder cmd = new StringBuilder();
			String scrpict;
			if (isWindows) {
				if(position_type.contains("1")){
					
					
					if(scrpictsuffix.equals("bat")){
						
						scrpict = messages.getMessage("toolbox.bsaServerBatBat");
					}else{
						scrpict = messages.getMessage("toolbox.bsaServerShellBat");
					}
					
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k])
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SLASH)
					  .append(appsyscode)
					  .append(CommonConst.SLASH);
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(shellname)
					  .append(CommonConst.SPACE);
					  if(scrpictsuffix.equals("bat")){
						  cmd.append(messages.getMessage("toolbox.servercpPath"))
						  .append(CommonConst.SLASH);
					  }else{
						  cmd.append(messages.getMessage("toolbox.serverPath"))
						  .append(CommonConst.SLASH);
						  }
					    if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					    }else{
						  cmd.append(os_type);
					    }
				      cmd.append(CommonConst.SLASH)
					     .append(username)
					     .append(CommonConst.SPACE);
				
				if(!scrpictsuffix.equals("bat")){
					if(osuser.length()>0){
						cmd.append(osuser);
					}else if(group_osuser.length()>0){
						cmd.append(group_osuser);
					}else{
						cmd.append(osusers[k]);
					}
				}else{
					cmd.append(CommonConst.SPACE)
					   .append(CommonConst.DAN_QUOTATION_MARK)
					   .append(messages.getMessage("toolbox.serverexPath"))
					   .append(CommonConst.RIGHT_SLASH)
					   .append(CommonConst.RIGHT_SLASH);
					if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					    }else{
						  cmd.append(os_type);
					    }
				      cmd.append(CommonConst.RIGHT_SLASH)
				         .append(CommonConst.RIGHT_SLASH)
					     .append(username)
					     .append(CommonConst.DAN_QUOTATION_MARK)
					     .append(CommonConst.SPACE);
					 
				}
				cmd.append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				
				}else{
					
					if(scrpictsuffix.equals("bat")){
						server_route =server_routes[k].replaceAll("\\\\" , "\\\\\\\\");
						scrpict = messages.getMessage("toolbox.bsaTargetServerBatBat");
					}else{
						scrpict = messages.getMessage("toolbox.bsaTargetServerShellBat");
					}
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k]);
					  cmd.append(CommonConst.SPACE)
				      .append(CommonConst.DAN_QUOTATION_MARK)
				      .append(server_routes[k])
					 // .append(server_route)
					  .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(CommonConst.SPACE);
		 if(!scrpictsuffix.equals("bat")){
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
				
			 }
				cmd.append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}
				cmdExe = Constants.CMD_COMMAND;
				option = "/C";
			} else {
				
				if(position_type.contains("1")){
					if(scrpictsuffix.equals("bat")){
						
						scrpict = messages.getMessage("toolbox.bsaServerBatShellForLinux");
					}else{
						scrpict = messages.getMessage("toolbox.bsaServerShellShellForLinux");
					}
					
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k])
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SLASH)
					  .append(appsyscode)
					  .append(CommonConst.SLASH);
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(shellname)
					  .append(CommonConst.SPACE);
				   if(scrpictsuffix.equals("bat")){
						  cmd.append(messages.getMessage("toolbox.servercpPath"))
						  .append(CommonConst.SLASH);
					  }else{
						  cmd.append(messages.getMessage("toolbox.serverPath"))
						  .append(CommonConst.SLASH);
						  }
					 
					  if(serverGroup.length()>0){
						  cmd.append(serverGroup);
					  }else{
						  cmd.append(os_type);
					  }
				   cmd.append(CommonConst.SLASH)
					  .append(username)
					  .append(CommonConst.SPACE);
		 if(!scrpictsuffix.equals("bat")){   
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
		 }else{
		
				cmd.append(CommonConst.SPACE)
				   .append(CommonConst.DAN_QUOTATION_MARK)
				   .append(messages.getMessage("toolbox.serverexPath"))
				   .append(CommonConst.RIGHT_SLASH)
				   .append(CommonConst.RIGHT_SLASH);
				if(serverGroup.length()>0){
					  cmd.append(serverGroup);
				    }else{
					  cmd.append(os_type);
				    }
			      cmd.append(CommonConst.RIGHT_SLASH)
			         .append(CommonConst.RIGHT_SLASH)
				     .append(username)
				     .append(CommonConst.DAN_QUOTATION_MARK)
				     .append(CommonConst.SPACE);
				 
			}
				cmd.append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}else{
					if(scrpictsuffix.equals("bat")){
						server_route =server_routes[k].replaceAll("\\\\" , "\\\\\\\\");
						scrpict = messages.getMessage("toolbox.bsaTargetServerBatShellForLinux");
					}else{
						server_route=server_routes[k];
						scrpict = messages.getMessage("toolbox.bsaTargetServerShellShellForLinux");
					}
			       cmd.append(scrpict)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("bsa.fileServerIp"))
					  .append(CommonConst.SPACE)
					  .append(currentTime)
					  .append(CommonConst.SPACE)
					  .append(messages.getMessage("toolbox.bsaFileServerPath"))
					  .append(CommonConst.SPACE)
					  .append(serverIps[k]);
				cmd.append(CommonConst.SPACE)
				      .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(server_route)
					  .append(CommonConst.DAN_QUOTATION_MARK)
					  .append(CommonConst.SPACE);
			 if(!scrpictsuffix.equals("bat")){      
				if(osuser.length()>0){
					cmd.append(osuser);
				}else if(group_osuser.length()>0){
					cmd.append(group_osuser);
				}else{
					cmd.append(osusers[k]);
				}
			 }
				cmd.append(CommonConst.SPACE)
				   .append(shellname)
				   .append(CommonConst.SPACE)
				   .append(messages.getMessage("bsa.ipAddress"))
				   .append(CommonConst.SPACE)
				   .append(CommonConst.QUOTATION_MARK)
				   .append(params)
				   .append(CommonConst.QUOTATION_MARK);
				}
				cmdExe = Constants.SHELL_COMMAND;
				option = "-c";
			}
			String key = securityUtils.getUser().getUsername() + "_" + serverIps[k]+"_"+shellname;
			if(readerMap.get(key) == null){
			String[] exec = new String[] {cmdExe, option, cmd.toString()};
			ProcessBuilder pb = new ProcessBuilder(exec);
			// 连接输入流和错误流的管道输出
			pb.redirectErrorStream(true);
			process = pb.start();
			
			BufferedReader reader = null;
				try {
					
					reader = new BufferedReader(new InputStreamReader(process.getInputStream(),toolcharset));
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
				readerMap.put(key, reader);
				
			}
		}
		return existValue;
	}*/

	/**
	 * 执行脚本
	 * @return
	 * @throws IOException，UnsupportedEncodingException
	 * @throws InterruptedException 
	 * @throws SQLException 
	 */

		public void shellexc(String toolcode,List<Map<String, Object>> list, String shellname,
				List<Map<String, Object>> listServers, String osuser,String appsyscode,String group_osuser,
				String position_type,String serverGroup,String toolcharset,String os_type,String usercode,String event_id
			//	,String repetitions,String time_interval
				)throws UnsupportedEncodingException,IOException, InterruptedException,ArrayIndexOutOfBoundsException, SQLException {
			
			Date startDate = new Date();
			String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

			String[] paramvalues = new String[list.size()];
			String[] paramnames = new String[list.size()];
			for (int i = 0; i < list.size(); i++) {
				Map<String, Object> map = list.get(i);
				paramvalues[i] = ComUtil.checkJSONNull( map.get("param_default_value"));
				paramnames[i] = ComUtil.checkJSONNull( map.get("param_name"));
			}
			String[] serverIps = new String[listServers.size()];
			String[] server_routes =new String[listServers.size()];
			String[] osusers =new String[listServers.size()];
			for (int i = 0; i < listServers.size(); i++) {
				Map<String, Object> map = listServers.get(i);
				serverIps[i] = ComUtil.checkJSONNull(map.get("server_ip"));
				server_routes[i]=ComUtil.checkJSONNull(map.get("server_route"));
				osusers[i] = ComUtil.checkJSONNull(map.get("os_user")) ;
			}	
			//调用脚本执行
			nexecCmd(serverIps,server_routes, shellname, paramvalues,paramnames, osuser,osusers,appsyscode,group_osuser,position_type,serverGroup,toolcharset,os_type);
			//nexecCmd(serverIps,server_routes, shellname, paramvalues,paramnames, osuser,osusers,appsyscode,group_osuser,position_type,serverGroup,toolcharset,os_type, repetitions,time_interval);
		
			//插入执行日志表

			String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
			String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
			CmnLogVo cmnLog = new CmnLogVo(); 
			cmnLog.setAppsysCode(appsyscode);
			cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
			cmnLog.setRequestName(toolcode+"_exc");
			cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
			cmnLog.setAuthorizedUser(usercode);
			cmnLog.setEvent_id(event_id);
			cmnLog.setExecStatus(logState);
			cmnLog.setExecDate(execdate);
			cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
			Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
			cmnLog.setExecCompletedTime(ts);
			cmnLog.setExecCreatedTime(ts);
			cmnLog.setExecUpdatedTime(ts);
			cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
			Long logJnlNo = cmnLogService.save(cmnLog);
			
			for (int a = 0; a < serverIps.length; a++) {
				//执行开始时间


				String starttimedet = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
				//插入详细日志表


				CmnDetailLogVo cdlv = new CmnDetailLogVo();
				cdlv.setLogJnlNo(logJnlNo);
				cdlv.setDetailLogSeq(String.valueOf(a+1));
				cdlv.setAppsysCode(appsyscode);
				cdlv.setStepName(shellname+"_exc");
				cdlv.setJobName(shellname);
				cdlv.setExecServerIp(serverIps[a]);
				cdlv.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
				cdlv.setExecStatus(logState);
				cdlv.setExecDate(execdate);
				cdlv.setExecStartTime(Timestamp.valueOf(starttimedet));
				Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
				cdlv.setExecCompletedTime(timestamp);
				cdlv.setExecCreatedTime(timestamp);
				cdlv.setExecUpdatedTime(timestamp);
				cmnDetailLogService.save(cdlv);
				
				Runnable task = new Executor(serverIps[a], securityUtils.getUser().getUsername(),shellname,cdlv,appsyscode,logJnlNo);
				new Thread(task).start();
				
			}
			
		}
	
	/**
	 * 日志页面获取数据
	 * @return
	 * 
	 */
	public List<Map<String, Object>> find(int startRow, String server,String shellname) {
		List<Map<String, Object>> outPut = getPrivateOutPut(securityUtils.getUser().getUsername(), server,shellname);
		if(outPut.size() <= startRow){
			return Collections.emptyList();
		}else{
			return new LinkedList<Map<String, Object>>(outPut.subList(startRow, outPut.size()));
		}
	}
	
	/**
	 *获取执行脚本的输出流
	 * @return
	 * @throws IOException
	 */
	public void startUpdate(String server, String user,String shellname,CmnDetailLogVo cdlv,String appsyscode,Long logJnlNo) throws Exception {
		boolean flag=true;
		/*String scrpictsuffix=shellname.substring(shellname.lastIndexOf('.') + 1).toLowerCase();
		
		if (scrpictsuffix.equals("bat")) {
			flag=true;
		
		}else{
			flag=false;
		}*/
		
		
		String key = user + "_" + server+ "_" +shellname;
		List<Map<String, Object>> outPut = getPrivateOutPut(user, server,shellname);
		List<Map<String, Object>> overflowOutPut = getPrivateOverflowOutPut(user, server,shellname);
		Integer row = outPut.size();
		String line;
		String logday=new SimpleDateFormat("yyyyMMdd").format(new Date());
		String time=new SimpleDateFormat("HHmmss").format(new Date());
		String logname=key+"_"+time+".txt";
		String toollogPath;
		if(isWindows){
			toollogPath=messages.getMessage("toolbox.logPath").concat(File.separator).concat(logday).concat(File.separator).concat(appsyscode);
		    
		}else{
			 toollogPath=messages.getMessage("toolbox.logPathForLinux").concat(File.separator).concat(logday).concat(File.separator).concat(appsyscode);
		}
		
		File outDir = new File(toollogPath);
		if (!outDir.exists()) {
			outDir.mkdirs();
		}
		toollogPath =toollogPath.concat(File.separator).concat(logname);
		FileWriter writer =new FileWriter(toollogPath);
		BufferedWriter bw =new BufferedWriter(writer);
		if(readerMap.get(key) == null) return ;
	
		while((line = readerMap.get(key).readLine()) != null){
			
			if(line.toString().equals("===============printend===============")){
				flag=false;
			};
			
			if(flag){
			bw.write(line.toString()+"\n");
				//line=line.replaceAll(" ","　");
			line=line.replaceAll(" ","&nbsp");
			Map<String, Object> log = new HashMap<String, Object>();
			log.put("row", row++);
			log.put("info", line);
			outPut.add(log);
			}
			
			if(line.toString().equals("===============printstart===============")){
				flag=true;
			}
		}
		bw.close();
		writer.close();
		
		int extra = overflowOutPut.size() - 1000;
		if (extra > 0) {
			for (int i = 0; i < extra; i++) {
				overflowOutPut.add(outPut.get(i));
			}
			outPut.removeAll(overflowOutPut);
		}
		
		
		outPutMap.remove(key);
		overflowOutPutMap.remove(key);
		readerMap.remove(key);
		
		Timestamp threadEndTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cdlv.setExecCompletedTime(threadEndTime);
		cdlv.setExecUpdatedTime(threadEndTime);
		cdlv.setResultsPath(toollogPath);
		//更新脚步目标服务器执行结束时间及日志文件路径
		cmnLogService.updatecdlv(cdlv);
		//更新脚步执行结束时间
		cmnLogService.updateCMNLOG(threadEndTime,logJnlNo);
		
	}
	

	/**
	 * 异步获取执行脚本的输出流
	 * @author user
	 *
	 */
	public class Executor implements Runnable {
		private String server;
		private String user;
		private String shellname;
		private CmnDetailLogVo cdlv;
		private String appsyscode;
		private Long logJnlNo;
		
		public Executor(String server, String user,String shellname,CmnDetailLogVo cdlv,String appsyscode, Long logJnlNo){
			this.server = server;
			this.user = user;
			this.shellname=shellname;
			this.cdlv=cdlv;
			this.appsyscode=appsyscode;
			this.logJnlNo=logJnlNo;
		}
		@Override
		public void run() {
			try {
				startUpdate(server,user,shellname,cdlv,appsyscode,logJnlNo);
			} catch (Exception e) {
				logger.log("Toolbox0004", e.getMessage());
			}
		}
	}


	/**
	 *动态口令验证

	 * @author user
	 * @param pinCode 
	 * @return 
	 * @throws UnknownHostException 
	 *
	 */
	public Map<String,String>  isDynPassword(String usercode, String dynpassword, String pinCode) throws UnknownHostException  {
		Map<String, String> Map=new HashMap<String, String>();
		//取服务器的ip   客户端IP地址，用来访问控制，没有访问控制时该属性为空

			String userLoginIp= messages.getMessage("bsa.ipAddress");
		//令牌PIN码，当token中已有PIN码时该值为空
		TransferTicket ticket = LoginUtil.getInstance().accTokenAuth(usercode, 
				dynpassword, pinCode , userLoginIp,usercode);

		if (ticket != null && !ResultCode.RESULT_OK.equals(ticket.getRetCode())) {
		
			// 生成提示信息进行提示；
			String error = LoginUtil.getInstance().getCodeMess(ticket.getRetCode()).toString();
			Map.put("error", error);
		
	} 
		
		
		return Map;
	}
	
	
	/**
	 * 根据应用系统获取报警策略一级分类	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryOneTree(String appsys_code) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code as \"appsys_code\" ,t.policy_type_one as \"policy_type_one\" ")
		
		.append(" from MONITOR_POLICY_CONFIG t " ) 
		.append(" where t.appsys_code =:appsys_code ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("appsys_code", appsys_code);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取报警策略二级分类
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryTwoTree(String appsys_code,String policy_type_one) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code as \"appsys_code\" ,t.policy_type_one as \"policy_type_one\",t.policy_type_two as \"policy_type_two\" ")
		.append(" from MONITOR_POLICY_CONFIG t " ) 
		.append(" where t.appsys_code =:appsys_code and t.policy_type_one= :policy_type_one ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("policy_type_one", policy_type_one)
								  .setString("appsys_code", appsys_code);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取报警策略三级分类
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryThreeTree(String appsys_code,String policy_type_one,String policy_type_two) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code as \"appsys_code\" ,t.policy_type_one as \"policy_type_one\",t.policy_type_two as \"policy_type_two\",t.policy_type_three as \"policy_type_three\" ")
		.append(" from MONITOR_POLICY_CONFIG t " ) 
		.append(" where t.appsys_code =:appsys_code and t.policy_type_one= :policy_type_one and  t.policy_type_two= :policy_type_two ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("policy_type_one", policy_type_one)
								  .setString("policy_type_two", policy_type_two)
								  .setString("appsys_code", appsys_code);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取报警策略
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryPolicyTree(String appsys_code,String policy_type_one,String policy_type_two) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.POLICY_OLD_NAME as \"policy_old_name\" , ")
		.append("t.POLICY_NAME as \"policy_name\" " ) 
		.append(" from MONITOR_POLICY_CONFIG t " ) 
		.append(" where t.appsys_code =:appsys_code and t.policy_type_one= :policy_type_one and  t.policy_type_two= :policy_type_two and t.policy_type_three='NULL'");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("policy_type_one", policy_type_one)
								  .setString("policy_type_two", policy_type_two)
								  .setString("appsys_code", appsys_code);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取报警策略
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryPolicyTree2(String appsys_code,String policy_type_one,String policy_type_two,String policy_type_three) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.POLICY_OLD_NAME as \"policy_old_name\" , ")
		.append("t.POLICY_NAME as \"policy_name\" " ) 
		.append(" from MONITOR_POLICY_CONFIG t " ) 
		.append(" where t.appsys_code =:appsys_code and t.policy_type_one= :policy_type_one and  t.policy_type_two= :policy_type_two and t.policy_type_three= :policy_type_three ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("policy_type_one", policy_type_one)
								  .setString("policy_type_two", policy_type_two)
								  .setString("policy_type_three", policy_type_three)
								  .setString("appsys_code", appsys_code);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取报警策略
	 */
	
	@Transactional
	public String  queryPolicy(String tool_code) {
		String val = "";
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.event_group as \"event_group\" ")
		.append(" from TOOL_BOX_EVENT_GROUP_INFO t " ) 
		.append(" where t.tool_code =:tool_code ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setString("tool_code", tool_code);
		if(query.list()!=null && query.list().size()>0){
			if( query.list().get(0)!=null){
				val = query.list().get(0).toString();
			}
		}
		return val;
	}
	
	/**
	 * 构建目录树 -- 报警策略
	 * @param dataList 父节点列表

	 * @param 
	 * @return
	 */
	public List<JSONObject> buildEcentGroupTree(List<Map<String, Object>> dataList,String tool_code) {
		String eventGroup=queryPolicy(tool_code);
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		JSONObject  third =  null; 
		JSONObject  four =  null; 
		JSONObject  policy =  null;
		JSONObject  policy2 =  null;
		for (Map<String,Object> map : dataList) {
			String policy_type_one =  map.get("policy_type_one").toString() ;
			second = new JSONObject();
			second.put("text", policy_type_one);
			second.put("iconCls", "node-module");
			second.put("isType", true);
			second.put("leaf", false);
			Boolean mapFlag = false;
			List<Map<String, Object>> dataList2=queryTwoTree(map.get("appsys_code").toString(),policy_type_one);
			List<JSONObject> sencondList = new ArrayList<JSONObject>();
			for (Map<String,Object> map2 : dataList2) {
				List<JSONObject> thirdList = new ArrayList<JSONObject>();
				String policy_type_two =  map2.get("policy_type_two").toString() ;
				third = new JSONObject();
				third.put("text", policy_type_two);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", false);
				Boolean map2Flag = false ;
				List<Map<String, Object>> dataList3=queryThreeTree(map2.get("appsys_code").toString(),policy_type_one,policy_type_two);
				for (Map<String,Object> map3 : dataList3) {
					if(map3.get("policy_type_three")!=null && !map3.get("policy_type_three").equals("")&& !map3.get("policy_type_three").equals("NULL")){
						String policy_type_three =  map3.get("policy_type_three").toString() ;
						four = new JSONObject();
						four.put("text", policy_type_three);
						four.put("iconCls", "node-module");
						four.put("isType", true);
						four.put("leaf", false);
						Boolean map3Flag = false ;
						List<Map<String, Object>> dataList4=queryPolicyTree2(map3.get("appsys_code").toString(),policy_type_one,policy_type_two,policy_type_three);
						List<JSONObject> policyList = new ArrayList<JSONObject>();
						for (Map<String,Object> endmap : dataList4) {
							String policy_old_name =  endmap.get("policy_old_name").toString() ;
							String policy_name =  endmap.get("policy_name").toString() ;
							String Ep=policy_old_name+"  ("+policy_name+")";
							policy = new JSONObject();
							policy.put("text", Ep);
							policy.put("iconCls", "node-leaf");
							policy.put("isType", true);
							policy.put("leaf", true);
							if(eventGroup.indexOf(policy_old_name)==-1){
								policy.put("checked", false); 
							}else{
								policy.put("checked", true); 
								map3Flag = true;
							}
							policyList.add(policy);
						}
						if(map3Flag){
							four.put("checked", true); 
							map2Flag = true;
						}else{
							four.put("checked", false); 
						}
						four.put("children", JSONArray.fromObject(policyList));
						thirdList.add(four);
					}else{
						List<Map<String, Object>> dataList5=queryPolicyTree(map2.get("appsys_code").toString(),policy_type_one,policy_type_two);
						for (Map<String,Object> endmap2 : dataList5) {
							String policy_old_name =  endmap2.get("policy_old_name").toString() ;
							String policy_name =  endmap2.get("policy_name").toString() ;
							String Ep=policy_old_name+"  ("+policy_name+")";
							policy2 = new JSONObject();
							policy2.put("text", Ep);
							policy2.put("iconCls", "node-leaf");
							policy2.put("isType", true);
							policy2.put("leaf", true);
							if(eventGroup.indexOf(policy_old_name)==-1){
								policy2.put("checked", false); 
							}else{
								policy2.put("checked", true); 
								map2Flag = true;
							}
							thirdList.add(policy2);
						}
					}
				}
				if(map2Flag){
					third.put("checked", true); 
					mapFlag = true;
				}else{
					third.put("checked", false);
				}
				third.put("children", JSONArray.fromObject(thirdList));
				sencondList.add(third);
			}
			if(mapFlag){
				second.put("checked", true); 
			}else{
				second.put("checked", false); 
			}
			second.put("children", JSONArray.fromObject(sencondList));
			sysJsonList.add(second);
		}
		return sysJsonList;
	}
	
	/**
	 * 查询工具列表数据.
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
	public List<Map<String, Object>> queryToolboxAlarmtoolListInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,String policy_code,String policy_old_name)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
		
		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'  and " );
		sql.append(	"tg.event_group = '");
		sql.append(policy_old_name);
		sql.append("' or tg.event_group like '");
		sql.append(policy_old_name);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_old_name);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_old_name);
		sql.append("' or " );
		sql.append(	"tg.event_group ='");
		sql.append(policy_code);
		sql.append("' or tg.event_group like '");
		sql.append(policy_code);
		sql.append("|%' or" );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_code);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_code);
		sql.append("' " );
		 

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.field_type_one,tb.field_type_two asc");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return query.list();
	}
	
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxAlarmtoolListInfoCount(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,String policy_code,String policy_old_name)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
		
		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'  and " );
		sql.append(	"tg.event_group = '");
		sql.append(policy_old_name);
		sql.append("' or tg.event_group like '");
		sql.append(policy_old_name);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_old_name);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_old_name);
		sql.append("' or " );
		sql.append(	"tg.event_group ='");
		sql.append(policy_code);
		sql.append("' or tg.event_group like '");
		sql.append(policy_code);
		sql.append("|%' or" );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_code);
		sql.append("|%' or " );
		sql.append("  tg.event_group like '%|");
		sql.append(policy_code);
		sql.append("' " );
		 

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.field_type_one,tb.field_type_two asc");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				;

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}

		return query.list();
	}


	/**
	 * 查询工具列表数据.
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
	public List<Map<String, Object>> queryToolboxreceiveInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
		
		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'   " );
		

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}
	
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryToolboxreceiveInfoCount(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");
		
		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		//sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'   " );
		

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}

	
	/**
	 * 批量修改交接状态标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void toolStatus(String[] tool_codes) throws SQLException {
		for (int i = 0; i < tool_codes.length ; i++) {
		
			toolStatusById(tool_codes[i]);
			

		}
	}

	
	/**
	 * 修改交接状态标示 
	 * @param tool_code
	 * @param appsys_code
	 */
	
	public void toolStatusById(String tool_code)throws SQLException {
		getSession().createQuery(
						"update  ToolBoxExtendAttriVo ta set ta.tool_status='1' ,ta.tool_returnreasons='' where ta.tool_code = ? ")
				.setString(0, tool_code)
				.executeUpdate();
	}
	//一线接收功能
	/**
	 * 批量修改交接状态标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void receivedByIds(String[] tool_codes) throws SQLException {
		for (int i = 0; i < tool_codes.length ; i++) {
		
			receivedById(tool_codes[i]);
			

		}
	}

	
	/**
	 * 修改交接状态标示 
	 * @param tool_code
	 * @param appsys_code
	 */
	
	public void receivedById(String tool_code)throws SQLException {
		Date startDate = new Date();
		 Timestamp received_time = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate)) ;
		 String username = securityUtils.getUser().getUsername() ;
		getSession().createQuery(
						"update  ToolBoxExtendAttriVo ta set ta.tool_status='2',ta.tool_received_user=?,ta.tool_received_time=?  where ta.tool_code = ? ")
				.setString(0, username).setTimestamp(1, received_time).setString(2, tool_code)
				.executeUpdate();
	}
	
	
	/**
	 * 批量修改交接状态标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	
	@Transactional
	public void returnedByIds(String[] tool_codes,String tool_returnreasons) throws SQLException {
		for (int i = 0; i < tool_codes.length ; i++) {
		
			returnedById(tool_codes[i],tool_returnreasons);
			

		}
	}
	
	/**
	 * 修改交接状态标示 
	 * @param tool_code
	 * @param appsys_code
	 */
	
	public void returnedById(String tool_code,String tool_returnreasons)throws SQLException {
		getSession().createQuery(
						"update  ToolBoxExtendAttriVo ta set ta.tool_status='3',ta.tool_returnreasons=? where ta.tool_code = ? ")
						.setString(0, tool_returnreasons)
				        .setString(1, tool_code)
				        .executeUpdate();
	}
	
	
	/**
	 * 查询工具列表数据.
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
	public List<Map<String, String>> queryToolboxInfoFL(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'   " );
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}
	
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, String>> queryToolboxInfoFLCount(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException {
		Set<Role> userRole = securityUtils.getUser().getRoles();
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("ts.shell_name as \"shell_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("ts.server_group as \"server_group\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\",");
		sql.append("ts.os_type as \"os_type\",");
		sql.append("ts.position_type as \"position_type\", ");
		sql.append("ts.os_user_flag as \"os_user_flag\",");
		sql.append("ts.group_server_flag as \"group_server_flag\",");
		sql.append("ts.os_user as \"os_user\",");
		sql.append("ts.tool_charset as \"tool_charset\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tg.event_group as \"event_group\",");
		sql.append("tk.summarycn as \"summarycn\",");
		sql.append("tb.tool_creator as \"tool_creator\", ");
		sql.append("tb.tool_modifier as \"tool_modifier\",");
		sql.append("to_char(tb.tool_created_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_created_time\",");
		sql.append("to_char(tb.tool_updated_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_updated_time\",");
		sql.append("ta.tool_received_user as \"tool_received_user\",");
		sql.append("to_char(ta.tool_received_time,'yyyy-MM-dd hh24:mi:ss') as \"tool_received_time\",");
		sql.append("ta.tool_status as \"tool_status\",");
		//sql.append("td.tool_content as \"tool_content\",");
		sql.append("ta.tool_returnreasons as \"tool_returnreasons\"");

		sql.append(" from tool_box_info tb  left join TOOL_BOX_EXTEND_ATTRI ta on ta.tool_code=tb.tool_code " );
		sql.append(" left join tool_box_script_info ts on ts.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_DESC_INFO td on td.tool_code=tb.tool_code ");
		sql.append(" left join TOOL_BOX_EVENT_GROUP_INFO tg on tg.tool_code=tb.tool_code");
		sql.append(" left join TOOL_BOX_KEY_WORD_INFO tk on tk.tool_code=tb.tool_code");
		sql.append("  where tb.delete_flag='0'   " );
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				
				if (fields.get(key).equals(FieldType.STRING)) {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " like :" + key);
					}else{
					sql.append(" and  " + key + " like :" + key);
					}
				} else {
					if(key.equals("tool_status")||key.equals("tool_returnreasons")){
						sql.append(" and ta." + key + " = :" + key);
					}else{
					sql.append(" and  " + key + " = :" + key);
					}
				}
			}
		}
		
		sql.append(" order by tb.appsys_code,tb.tool_code asc");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}
	
	
	/**
	 * 备份脚本
	 * 
	 * @param customer
	 * @throws IOException 
	 */
	@Transactional
	public void importFtpBak(String shellname,String appsyscode,String serverGroup,String os_type,String toolcode)throws FtpCmpException, IOException {
		String time = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String s_o;
		if(appsyscode.equals("COMMON")){
			s_o=os_type;
		}else{
			s_o=serverGroup;
		}
		String hz=shellname.substring(shellname.lastIndexOf('.'));
		String serverPath=messages.getMessage("toolbox.DBServerPath");
		String path=messages.getMessage("toolbox.DBServerPath")+CommonConst.SLASH+appsyscode+CommonConst.SLASH+s_o+CommonConst.SLASH+shellname;
		String ToPath=messages.getMessage("toolbox.DBServerToolBak")+CommonConst.SLASH+appsyscode;
		String ToPath2=messages.getMessage("toolbox.DBServerPath")+CommonConst.SLASH+messages.getMessage("toolbox.DBServerToolBak")+CommonConst.SLASH+appsyscode+CommonConst.SLASH+time+CommonConst.UNDERLINE+toolcode+hz;
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doMkdirs(serverPath,ToPath);
		ftpLogin.disconnect();
		ComponentFtpConnection ftpLogin2 = new ComponentFtpConnection();
		ftpLogin2.connect(host,port,user,password);
		ComponentFtp ftpFile2 = new ComponentFtp(ftpLogin2);
		ftpFile2.renamelFile(path, ToPath2);
		ftpLogin2.disconnect();
	}
	
	/**
	 * 获取脚本
	 * 
	 * @param customer
	 */
	@Transactional
	public void importFtp(String shellname,String appsyscode,String serverGroup,String os_type)throws FtpCmpException {
		String uname = securityUtils.getUser().getUsername() ;
		String filepath = System.getProperty("maop.root")+File.separator+messages.getMessage("toolbox.rootPath")+ File.separatorChar+ messages.getMessage("toolbox.fileuploadPath")+ File.separatorChar+uname+ File.separatorChar;
		String localFilename=filepath+File.separator+shellname;
		String s_o;
		if(appsyscode.equals("COMMON")){
			s_o=os_type;
		}else{
			s_o=serverGroup;
		}
		String path=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+appsyscode+CommonConst.SLASH+s_o+CommonConst.SLASH+shellname;
		String ToPath=messages.getMessage("toolbox.bsaFileServerPath");
		String ToPath2=messages.getMessage("toolbox.bsaFileServerPath")+CommonConst.SLASH+appsyscode;
		String host = messages.getMessage("bsa.fileServerIp");
		Integer port = new Integer(messages.getMessage("bsa.ftpPort"));
		String user = messages.getMessage("bsa.ftpUser");
		String password = messages.getMessage("bsa.ftpPassword");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		ftpFile.doChdir(ToPath, new StringBuffer());
		ftpFile.doMkdir(appsyscode, new StringBuffer());
		ftpFile.doChdir(ToPath2, new StringBuffer());
		ftpFile.doMkdir(s_o, new StringBuffer());
		ftpFile.doPut(localFilename,path, true,new StringBuffer());
		ftpLogin.disconnect();
	}
	
	/**
	 * 构建目录树 -- 报警策略
	 * @param dataList 父节点列表
	 * @param 
	 * @return
	 */
	public List<JSONObject> buildHistoryStriptTree(List<String> dataList,String appsys_code) {
		
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		
		
		for (Object toolcodename : dataList) {
			String t =  toolcodename.toString() ;
			second = new JSONObject();
			
			second.put("text", t);
			second.put("iconCls", "node-leaf");
			second.put("isType", true);
			second.put("leaf", true);
			second.put("checked", false); 
			sysJsonList.add(second);
		}
		return sysJsonList;
	}

	public void saveDesc(String appsyscode,String toolcode,
			ToolBoxExtendAttriVo attriVo,
			ToolBoxInfoVo toolBoxInfoVo,
			ToolBoxDescInfoVo toolBoxDescInfoVo,
			ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo) throws SQLException {
		
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		
		
		ToolBoxInfoVo Vo=queryAlltoolboxinfo2(toolcode);
		if(Vo==null){
			
			getSession().save(toolBoxInfoVo);
		}else{
			
			if("1".equals(Vo.getDelete_flag())){
				
				this.deleteAttri(toolcode);
				this.deleteEventGroup(toolcode);
				this.deleteKeyWord(toolcode);
				getSession().evict(Vo);
				getSession().saveOrUpdate(toolBoxInfoVo);
			}else{
				getSession().evict(Vo);
				getSession().save(toolBoxInfoVo);
			}
		}
		
		
		getSession().saveOrUpdate(attriVo);
		getSession().saveOrUpdate(toolBoxDescInfoVo);
		if(null!=toolBoxEventGroupInfoVo.getEvent_group()&&toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		}
		
		if(null!=toolBoxKeyWordInfoVo.getSummarycn()&&toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		}
		
		List<OccToolBoxFilesVo> list =this.getOccFiles(toolcode);
		for(OccToolBoxFilesVo ovo :list){
			ToolBoxFilesVo vo =new ToolBoxFilesVo();
			vo.setTool_code(ovo.getTool_code());
			vo.setFile_id(ovo.getFile_id());
			vo.setFile_name(ovo.getFile_name());
			vo.setFile_type(ovo.getFile_type());
			vo.setFile_content(ovo.getFile_content());
			this.save(vo);
		}
		//插入注册日志表

		String toolname=toolBoxInfoVo.getTool_name();

		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(toolBoxInfoVo.getAppsys_code());
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(toolname+"_"+toolcode+"_create");
		cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		/*Long logJnlNo = cmnLogService.save(cmnLog);*/
		cmnLogService.save(cmnLog);	
		
	}
	
	@SuppressWarnings("unchecked")
	public List<OccToolBoxFilesVo> getOccFiles(String toolcode){
		return getSession().createQuery("from OccToolBoxFilesVo t where t.tool_code=? ").setString(0, toolcode).list();
		
	}
	
	
	public void saveDescEdit(String appsyscode,String toolcode,
			ToolBoxExtendAttriVo attriVo,
			ToolBoxInfoVo toolBoxInfoVo,
			ToolBoxDescInfoVo toolBoxDescInfoVo,
			ToolBoxEventGroupInfoVo toolBoxEventGroupInfoVo,
			ToolBoxKeyWordInfoVo toolBoxKeyWordInfoVo) throws SQLException {
		
		this.deleteParam(toolcode, appsyscode);
		this.deleteServer(toolcode, appsyscode);
		this.deleteAttri(toolcode);
		this.deleteEventGroup(toolcode);
		this.deleteKeyWord(toolcode);
		
		getSession().saveOrUpdate(toolBoxInfoVo);
		getSession().saveOrUpdate(attriVo);
		getSession().saveOrUpdate(toolBoxDescInfoVo);
		if(toolBoxEventGroupInfoVo.getEvent_group().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxEventGroupInfoVo);
		}
		
		if(toolBoxKeyWordInfoVo.getSummarycn().toString().length()>0){
			
			getSession().saveOrUpdate(toolBoxKeyWordInfoVo);
		}
		//插入修改日志表
		Date startDate = new Date();
		String logState = "0" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		String toolname=toolBoxInfoVo.getTool_name();
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo(); 
		cmnLog.setAppsysCode(appsyscode);
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3：BSA
		cmnLog.setRequestName(toolname+"_"+toolcode+"_update");
		cmnLog.setLogType("2"); //1:应用发布、2：工具箱、3：自动巡检shellname
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		cmnLogService.save(cmnLog);
		
	}

	
	/**
	 * 查序列
	 * 
	 */
	
	public String findTooldescSeq()throws SQLException {
		String seq=	(String) getSession().createSQLQuery(
						"select to_char (TOOL_BOX_DESC_SEQ.nextval) as \"toolcode\" from dual")
						.uniqueResult();
		return seq;
	}

	/**
	 * 查序列

	 * 
	 */
	
	public List<Map<String, Object>> findTooldescSeqMap( )throws SQLException {
		StringBuilder sql=new StringBuilder();
		sql.append("select t.sub_item_order||to_char (TOOL_BOX_DESC_SEQ.nextval) as \"toolcode\" from dual,  jeda_sub_item t where t.item_id= 'SYSTEM_ENVIRONMENT'");
		sql.append(" and t.sub_item_value in  ");
		sql.append(" (select t1.sub_item_value from jeda_sub_item t1 where t1.item_id= 'PLATFORM_ENV' ) "); 
		Query query  = getSession().createSQLQuery(sql.toString())
						.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

	
	
	
	
	/**
	 * 根据系统获取工具箱类型
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> querytooltype() {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.tool_type as \"tool_type\" ")
		.append(" from tool_box_info t  " ) 
		.append(" where  t.appsys_code in:sysList ")
		.append(" and t.delete_flag ='0' ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return query.list();
	}
	
	/**
	 * 根据系统获取工具箱类型
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> querytooltype2() {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.tool_type as \"tool_type\" ")
		.append(" from tool_box_info t  " ) 
		.append(" where   t.delete_flag ='0' ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	/**
	 * 根据系统获取工具箱类型
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> querytooltype3() {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.tool_type as \"tool_type\" ")
		.append(" from tool_box_info t,TOOL_BOX_EXTEND_ATTRI ta  " ) 
		.append(" where   t.delete_flag ='0'  and t.tool_code=ta.tool_code and ta.tool_status='2' ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 根据应用系统获取一级分类
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryOneLevelTree(String tool_type) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.field_type_one as \"field_type_one\" ")
		
		.append(" from tool_box_info t " ) 
		.append(" where t.tool_type =:tool_type and t.appsys_code in:sysList ")
		.append(" and t.delete_flag ='0' ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  .setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return query.list();
	}
	
	/**
	 * 根据应用系统获取一级分类
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryOneLevelTree2(String tool_type) {
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.field_type_one as \"field_type_one\" ")
		
		.append(" from tool_box_info t " ) 
		.append(" where t.tool_type =:tool_type  ")
		.append(" and t.delete_flag ='0' ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  ;
		return query.list();
	}
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTool_status(String tool_type) {
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append("case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " ) 
		.append(" and t.tool_type =:tool_type and t.appsys_code in:sysList ")
		.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  .setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return query.list();
	}
	
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTool_status2(String tool_type,String field_type_one) {
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append(" case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " ) 
		.append(" and t.tool_type =:tool_type and t.field_type_one =:field_type_one  and t.appsys_code in:sysList ")
		.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  .setString("field_type_one", field_type_one)
								  .setParameterList("sysList", appInfoService.getPersonalSysListForTool());
		return query.list();
	}
	
	
	
	
	/**
	 * 构建目录树 --tool
	 * @param dataList 父节点列表


	 * @param 
	 * @return
	 * @throws SQLException 
	 */
	public List<JSONObject> buildToolTree(List<Map<String, Object>> dataList) throws SQLException {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		JSONObject  third =  null; 
		
		for (Map<String,Object> map : dataList) {
			String tool_type =  map.get("tool_type").toString();
			String type_name =this.getNAME("TOOL_TYPE", tool_type);
			Map<String, Object> m =this.countTool_status(tool_type).get(0);
			String status =m.get("c1").toString()+"/"+m.get("c2").toString()+"/"+m.get("c3").toString()+"/"+m.get("c4").toString();
			String type_name2=type_name+"("+status+")";
			second = new JSONObject();
			second.put("text", type_name2);
			second.put("iconCls", "node-module");
			second.put("isType", true);
			second.put("leaf", false);
			List<Map<String, Object>> dataList2=queryOneLevelTree(tool_type);
			List<JSONObject> sencondList = new ArrayList<JSONObject>();
			for (Map<String,Object> map2 : dataList2) {
				List<JSONObject> thirdList = new ArrayList<JSONObject>();
				String field_type_one =  map2.get("field_type_one").toString() ;
				Map<String, Object> m2 =this.countTool_status2(tool_type,field_type_one).get(0);
				String status2 ="<font color=red>"+m2.get("c1").toString()+"</font>"+"/"+"<font color=blue>"+m2.get("c2").toString()+"</font>"+"/"+"<font color=orange>"+m2.get("c3").toString()+"</font>"+"/"+"<font color=green>"+m2.get("c4").toString()+"</font>";
				String field_type_one2 =field_type_one+"("+status2+")";
				third = new JSONObject();
				third.put("text", field_type_one2);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", true);
				
				third.put("children", JSONArray.fromObject(thirdList));
				sencondList.add(third);
			}
			
			second.put("children", JSONArray.fromObject(sencondList));
			sysJsonList.add(second);
		}
		return sysJsonList;
	}
	
	
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTools_status(String tool_type) {
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append("case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " ) 
		.append(" and t.tool_type =:tool_type  ")
		.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type);
		return query.list();
	}
	
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTools_statusOne(String tool_type) {
		int frontlineFlag= 0;
		Set<Role> userRole = securityUtils.getUser().getRoles();
		int limt=userRole.size();
		if(limt>1){
			frontlineFlag=3;
			
		}else{
		for (Role role : userRole) {
			if(role.getId().indexOf(ToolConstants.App+ToolConstants.FRONTLINE) != -1){
				frontlineFlag = 1;
			}
			if(role.getId().indexOf(ToolConstants.System+ToolConstants.FRONTLINE) != -1){
				frontlineFlag = 2;
			}
			if(role.getId().indexOf(ToolConstants.FRONTLINEAdmin) != -1){
				frontlineFlag = 0;
			}
		 }
		}
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append("case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " ) 
		.append(" and t.tool_type =:tool_type  ");
		if(frontlineFlag==3){
			sql.append("  and  ta.tool_status='2' ");
		}
		if(frontlineFlag==2){
			sql.append("  and  ta.tool_status='2' and  t.appsys_code ='COMMON' ");
		}
		
		if(frontlineFlag==1){
			sql.append(" and  ta.tool_status='2' and  t.appsys_code ！='COMMON' ");
		}
		sql.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type);
		return query.list();
	}
	
	
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTools_status2(String tool_type,String field_type_one) {
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append(" case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " ) 
		.append(" and t.tool_type =:tool_type and t.field_type_one =:field_type_one   ")
		.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  .setString("field_type_one", field_type_one);
		return query.list();
	}
	
	/**
	 * 根据工具类型分组
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> countTools_status3(String tool_type,String field_type_one) {
		
		int frontlineFlag= 0;
		Set<Role> userRole = securityUtils.getUser().getRoles();
		int limt=userRole.size();
		if(limt>1){
			frontlineFlag=3;
			
		}else{
		for (Role role : userRole) {
			if(role.getId().indexOf(ToolConstants.App+ToolConstants.FRONTLINE) != -1){
				frontlineFlag = 1;
			}
			if(role.getId().indexOf(ToolConstants.System+ToolConstants.FRONTLINE) != -1){
				frontlineFlag = 2;
			}
			if(role.getId().indexOf(ToolConstants.FRONTLINEAdmin) != -1){
				frontlineFlag = 0;
			}
		 }
		}
		StringBuilder sql = new StringBuilder();
		sql.append("select case when sum(c1) is null then 0 else sum(c1) end as \"c1\", case when sum(c2) is null then 0 else sum(c2) end as \"c2\",  ")
		.append(" case when sum(c3) is null then 0 else sum(c3) end as \"c3\",case when sum(c4) is null then 0 else sum(c4) end as \"c4\" from ")
		.append(" (select  case when   ta.tool_status ='0'  then 1 else 0 end as c1 , ")
		.append("  case when   ta.tool_status ='1'  then 1 else 0 end as c2 , ")
		.append("  case when   ta.tool_status ='2'  then 1 else 0 end as c3 , ")
		.append("  case when   ta.tool_status ='3'  then 1 else 0 end as c4   ")
		.append("  from tool_box_info t , TOOL_BOX_EXTEND_ATTRI ta where t.tool_code = ta.tool_code  " )
		.append(" and t.tool_type =:tool_type and t.field_type_one =:field_type_one   ");
		if(frontlineFlag==3){
			sql.append("  and  ta.tool_status='2' ");
		}
		if(frontlineFlag==2){
			sql.append("  and  ta.tool_status='2' and  t.appsys_code ='COMMON' ");
		}
		
		if(frontlineFlag==1){
			sql.append(" and  ta.tool_status='2' and  t.appsys_code ！='COMMON' ");
		}
		sql.append(" and t.delete_flag ='0')  ");
		Query query = getSession().createSQLQuery(sql.toString())
								  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
								  .setString("tool_type", tool_type)
								  .setString("field_type_one", field_type_one);
		return query.list();
	}
	
	/**
	 * 构建目录树 --tool
	 * @param dataList 父节点列表
	 * @return
	 * @throws SQLException 
	 */
	public List<JSONObject> buildToolsTree(List<Map<String, Object>> dataList) throws SQLException {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		JSONObject  third =  null; 
		
		for (Map<String,Object> map : dataList) {
			String tool_type =  map.get("tool_type").toString();
			String type_name =this.getNAME("TOOL_TYPE", tool_type);
			Map<String, Object> m =this.countTools_status(tool_type).get(0);
			String status =m.get("c1").toString()+"/"+m.get("c2").toString()+"/"+m.get("c3").toString()+"/"+m.get("c4").toString();
			String type_name2=type_name+"("+status+")";
			second = new JSONObject();
			second.put("text", type_name2);
			second.put("iconCls", "node-module");
			second.put("isType", true);
			second.put("leaf", false);
			List<Map<String, Object>> dataList2=queryOneLevelTree2(tool_type);
			List<JSONObject> sencondList = new ArrayList<JSONObject>();
			for (Map<String,Object> map2 : dataList2) {
				List<JSONObject> thirdList = new ArrayList<JSONObject>();
				String field_type_one =  map2.get("field_type_one").toString() ;
				Map<String, Object> m2 =this.countTools_status2(tool_type,field_type_one).get(0);
				String status2 ="<font color=red>"+m2.get("c1").toString()+"</font>"+"/"+"<font color=blue>"+m2.get("c2").toString()+"</font>"+"/"+"<font color=orange>"+m2.get("c3").toString()+"</font>"+"/"+"<font color=green>"+m2.get("c4").toString()+"</font>";
				String field_type_one2 =field_type_one+"("+status2+")";
				third = new JSONObject();
				third.put("text", field_type_one2);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", true);
				
				third.put("children", JSONArray.fromObject(thirdList));
				sencondList.add(third);
			}
			
			second.put("children", JSONArray.fromObject(sencondList));
			sysJsonList.add(second);
		}
		return sysJsonList;
	}
	
	/**
	 * 构建目录树 --tool
	 * @param dataList 父节点列表
	 * @return
	 * @throws SQLException 
	 */
	public List<JSONObject> buildToolsTreeOne(List<Map<String, Object>> dataList) throws SQLException {
		List<JSONObject> sysJsonList = new ArrayList<JSONObject>();
		JSONObject  second =  null; 
		JSONObject  third =  null; 
		
		for (Map<String,Object> map : dataList) {
			String tool_type =  map.get("tool_type").toString();
			String type_name =this.getNAME("TOOL_TYPE", tool_type);
			Map<String, Object> m =this.countTools_statusOne(tool_type).get(0);
			String status =m.get("c3").toString();
			String type_name2=type_name+"("+status+")";
			second = new JSONObject();
			second.put("text", type_name2);
			second.put("iconCls", "node-module");
			second.put("isType", true);
			second.put("leaf", false);
			List<Map<String, Object>> dataList2=queryOneLevelTree2(tool_type);
			List<JSONObject> sencondList = new ArrayList<JSONObject>();
			for (Map<String,Object> map2 : dataList2) {
				List<JSONObject> thirdList = new ArrayList<JSONObject>();
				String field_type_one =  map2.get("field_type_one").toString() ;
				Map<String, Object> m3 =this.countTools_status3(tool_type,field_type_one).get(0);
				String status3 ="<font color=orange>"+m3.get("c3").toString()+"</font>";
				String field_type_one3 =field_type_one+"("+status3+")";
				third = new JSONObject();
				third.put("text", field_type_one3);
				third.put("iconCls", "node-module");
				third.put("isType", true);
				third.put("leaf", true);
				
				third.put("children", JSONArray.fromObject(thirdList));
				sencondList.add(third);
			}
			
			second.put("children", JSONArray.fromObject(sencondList));
			sysJsonList.add(second);
		}
		return sysJsonList;
	}
	

	/**
	 * 查询工具列表数据.
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
	public List<Map<String, Object>> queryToolBoxFiles(String tool_code)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.file_id as \"file_id\",");
	
		sql.append("tb.file_type as \"file_type\",");
		sql.append("tb.file_name as \"file_name\"");
		sql.append(" from tool_box_files tb ");
		sql.append(" where tb.tool_code=? ");
		sql.append(" order by tb.file_id asc");
		
		
		Query query = getSession().createSQLQuery(sql.toString()).setString(0,tool_code )
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		return query.list();
	}
	
	/**
	 * 返回列表数据数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countToolBoxFiles(String tool_code) {
		String hql = "select count(*) from ToolBoxFilesVo t where t.tool_code=?";
		Query query = getSession().createQuery(hql).setString(0, tool_code);
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 查询工具列表数据.
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
	public List<Map<String, Object>> queryOccToolBoxFiles(String tool_code)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.file_id as \"file_id\",");
	
		sql.append("tb.file_type as \"file_type\",");
		sql.append("tb.file_name as \"file_name\"");
		sql.append(" from occ_tool_box_files tb ");
		sql.append(" where tb.tool_code=? ");
		sql.append(" order by tb.file_id asc");
		
		
		Query query = getSession().createSQLQuery(sql.toString()).setString(0,tool_code )
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		return query.list();
	}
	
	/**
	 * 返回列表数据数量.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countOccToolBoxFiles(String tool_code) {
		String hql = "select count(*) from OccToolBoxFilesVo t where t.tool_code=?";
		Query query = getSession().createQuery(hql).setString(0, tool_code);
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/**
	 * 查询工具列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Blob queryToolBoxFileContent(String tool_code,String file_id)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.FILE_CONTENT as \"file_content\" ");
		sql.append(" from tool_box_files tb ");
		sql.append(" where tb.tool_code=? and tb.file_id =? ");
		
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setString(0, tool_code)
				.setString(1, file_id)
				;
		Blob b= (Blob) query.list().get(0);
		
		return b;
	}
	
	/**
	 * 查询下载附件数据
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public List<Map<String, Object>> queryToolBoxFile(String file_id)throws SQLException {

		
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.FILE_CONTENT as \"file_content\" , ");
		sql.append("tb.file_type as \"file_type\",");
		sql.append("tb.file_name as \"file_name\"");
		sql.append(" from tool_box_files tb ");
		sql.append(" where   tb.file_id =? ");
		
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, file_id)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		return query.list();
		
	}
	
	/**
	 * 查询工具列表数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Blob queryOccToolBoxFileContent(String tool_code,String file_id)throws SQLException {
		 
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.FILE_CONTENT as \"file_content\" ");
		sql.append(" from occ_tool_box_files tb ");
		sql.append(" where tb.tool_code=? and tb.file_id =? ");
		
		
		Query query = getSession().createSQLQuery(sql.toString())
				.setString(0, tool_code)
				.setString(1, file_id)
				;
		Blob b= (Blob) query.list().get(0);
		
		return b;
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFileList(String tool_code)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.FILE_ID as \"file_id\",");
		sql.append(" f.file_name as \"file_name\" ");
		sql.append(" from  tool_box_files f where f.tool_code=? ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setString(0, tool_code)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getOccFileList(String tool_code)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.FILE_ID as \"file_id\",");
		sql.append(" f.file_name as \"file_name\" ");
		sql.append(" from  occ_tool_box_files f where f.tool_code=? ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setString(0, tool_code)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	public void checkFile(File file) throws Exception {
		
		 if(file.length()>5242880){
			
				throw new ComponentException("文件大于5M, 请重新上传!", 0);
			
		   }
	}
	/**
	 * 添加的保存方法
	 * @param appsyscode
	 * @param toolcode
	 * @param toolBoxInfoVo
	 * @throws SQLException 
	 */
	public void saveDescEdit(String appsyscode,String toolcode,
			ToolBoxInfoVo toolBoxInfoVo) throws SQLException{
		getSession().saveOrUpdate(toolBoxInfoVo);
	}
	/**
	 * 只更改front_tool_desc
	 * @param toolBoxInfoVo
	 */
	@Transactional
	public void saveOrUpdateToolboxinfo(String tool_code,String appsys_code,String front_tool_desc){
		getSession().createQuery(
				"update  ToolBoxInfoVo tb set tb.front_tool_desc=? where tb.tool_code = ? and tb.appsys_code= ?")
		.setString(0, front_tool_desc).setString(1, tool_code).setString(2, appsys_code)
		.executeUpdate();
	}
	
	/**
	 * 
	 * @param tool_code
	 * @param appsys_code
	 * @return
	 * @throws SQLException
	 */
	@Transactional(readOnly = true)
	public Object frontFindById(String tool_code, String appsys_code)throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("tb.tool_code as \"tool_code\",");
		sql.append("tb.appsys_code as \"appsys_code\",");
		sql.append("tb.tool_name as \"tool_name\",");
		sql.append("tb.tool_desc as \"tool_desc\",");
		//添加一线工具描述列
		sql.append("tb.front_tool_desc as \"front_tool_desc\",");
		sql.append("tb.tool_authorize_flag as \"tool_authorize_flag\",");
		sql.append("tb.authorize_level_type as \"authorize_level_type\",");
		sql.append("tb.field_type_one as \"field_type_one\",");
		sql.append("tb.field_type_two as \"field_type_two\",");
		sql.append("tb.field_type_three as \"field_type_three\",");
		sql.append("tb.tool_type as \"tool_type\"");
		sql.append(" from tool_box_info tb " );			
		sql.append("  where tb.delete_flag='0' and  tb.tool_code =? and tb.appsys_code=?  " );
		
		@SuppressWarnings("unchecked")
		Map<String,Object> map= (Map<String, Object>) getSession().createSQLQuery(sql.toString()).setString(0, tool_code)
				.setString(1, appsys_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).uniqueResult();

		if(null!=map.get("tool_content")){
			String tool_content=ComUtil.checkNull(StringUtil.clobToString((Clob)map.get("tool_content")));
			map.put("tool_content", tool_content);
		}
		
		return map;
	}
}

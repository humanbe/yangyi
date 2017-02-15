package com.nantian.dply.service;



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
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.axis2.AxisFault;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.system.vo.AppConfVo;
import com.nantian.common.system.vo.AppInfoItsmVo;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.com.DataException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.dply.vo.AppGroupServerVo;
import com.nantian.dply.vo.ApplicationProcessRecordsVo;
import com.nantian.dply.vo.ApposUserVo;
import com.nantian.dply.vo.CmnUserAppVo;
import com.nantian.dply.vo.OccasServersInfoVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.config.service.ItemService;
import com.nantian.jeda.config.service.SubItemService;
import com.nantian.jeda.security.util.SecurityUtils;


@Service
@Transactional
public class ServersSynchronousService {
	

	@Autowired
	private SessionFactory sessionFactory;
	
	@Transactional
	public void update(ServersInfoVo vo) {
		getSession().update(vo);
		
	}
	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	private CmnLogService cmnLogService;
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	@Autowired
	SubItemService subItemService;
	@Autowired
	private SecurityUtils securityUtils; 
	@Autowired
	private ItemService itemService; 
	@Autowired
	private ApplicationProcessService applicationProcessService;
	
/*	*//**
	 * 保存.
	 * 
	 * @param osuser
	 * @throws SQLException 
	 *//*
	@Transactional
	public void save(ApposUserVo osuser,String osUser, String appsysCode,String serverIp,String userIds) throws Exception {
		
		// ApposUserVo Vo= queryAllAppOsUser(osUser, appsysCode, serverIp, userId);
			if(Vo==null){
				getSession().save(osuser);
			}else{
				
				if("1".equals(Vo.getDeleteFlag())){
					getSession().evict(Vo);
					getSession().saveOrUpdate(osuser);
				}else{
					getSession().evict(Vo);
					getSession().save(osuser);
				}
			}
		
		
	}*/
	
	public void saveOrUpdateOsuser(List<ApposUserVo> list) {
		for(ApposUserVo Vo : list){
			getSession().saveOrUpdate(Vo);
		}
		
	}
	

	
	@Transactional
	public void updateOsUser(ApposUserVo vo) {
		getSession().update(vo);
		
	}
	
	@Transactional
	public void updateServer(ServersInfoVo server) {
		getSession().update(server);
		
	}
	
	
	public ApposUserVo queryAllAppOsUser(String osUser, String appsysCode,String serverIp,String userId) throws SQLException{
		return (ApposUserVo) getSession().createQuery("from ApposUserVo tb  where tb.osUser = :osUser and tb.appsysCode= :appsysCode and tb.serverIp= :serverIp and tb.userId= :userId")
					.setString("osUser", osUser)
					.setString("appsysCode", appsysCode)
					.setString("serverIp", serverIp)
					.setString("userId", userId)
				    .uniqueResult();
	}
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	public Map<String, String> fields = new HashMap<String, String>();
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	public ServersSynchronousService(){
		fields.put("serverIp", FieldType.STRING);
		fields.put("appsysCode", FieldType.STRING);
		fields.put("bsaAgentFlag", FieldType.STRING);
		fields.put("machineroomPosition", FieldType.STRING);
		fields.put("osType", FieldType.STRING);
		fields.put("serverUse", FieldType.STRING);
		fields.put("osUser", FieldType.STRING);
		fields.put("userId", FieldType.STRING);
		fields.put("dataType", FieldType.STRING);
	}
	
	/**
	 * 操作用户信息
	 * @return
	 */

	
	public Object findById(String osUser, String appsysCode, String serverIp,
			String userId) {

			StringBuilder hql = new StringBuilder();
			hql.append("select new map(");
			hql.append("tb.serverIp as serverIp,");
			hql.append("tb.appsysCode as appsysCode,");
			hql.append("tb.osUser as osUser,");
			hql.append("tb.userId as userId");

			hql.append(") from ApposUserVo tb where tb.userId=:userId and tb.serverIp=:serverIp and tb.appsysCode =:appsysCode and tb.osUser=:osUser  ");

			return getSession().createQuery(hql.toString())
					.setString("userId", userId)
					.setString("serverIp", serverIp)
					.setString("osUser", osUser)
					.setString("appsysCode", appsysCode)
					.uniqueResult();

		}
	
	/**
	 * 服务器

	 * @return
	 */

	
	public Object findByServerId( String appsysCode, String serverIp) {
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\" ,")
				.append(" o.serverName as \"serverName\", ")
				.append(" o.serverIp as \"serverIp\", ")
				.append(" o.serverIp as \"serverIpHide\", ")
				.append("o.appsysCode as \"appsysCodeHide\" , ")
				.append(" o.machineroomPosition as \"machineroomPosition\", ")
				.append(" o.bsaAgentFlag as \"bsaAgentFlag\", ")
				.append(" o.floatingIp as \"floatingIp\", ")
				.append(" o.serverRole as \"serverRole\", ")
				.append(" o.serverUse as \"serverUse\", ")
				.append("  o.osType as \"osType\" ,")
				.append("  o.mwType as \"mwType\" ,")
				.append("  o.dbType as \"dbType\" ,")
				.append("  o.collectionState as \"collectionState\" ,")
				.append("  o.attrFlag as \"attrFlag\" ,")
				
				.append("  o.deleteFlag as \"deleteFlag\" ,")
				.append("  o.environmentType as \"environmentType\" ,")
				.append("  o.dataType as \"dataType\" ")
				.append(" from (select  t.APPSYS_CODE as appsysCode,    ")
				.append(" t.SERVER_NAME as serverName, 	  ")
				.append(" t.SERVER_IP as serverIp, 	  ")
				.append(" t.MACHINEROOM_POSITION as machineroomPosition,  ")
				.append(" t.BSA_AGENT_FLAG as bsaAgentFlag,   ")
				.append(" t.FLOATING_IP as floatingIp,    ")
				.append(" t.SERVER_ROLE as serverRole,    ")
				.append(" t.SERVER_USE as serverUse, 	  ")
				.append(" t.OS_TYPE as osType,  ")
				.append(" t.MW_TYPE as mwType,  ")
				.append(" t.DB_TYPE as dbType,  ")
				.append(" t.COLLECTION_STATE as collectionState,  ")
				.append(" t.ATTR_FLAG as attrFlag,  ")
				.append(" t.DELETE_FLAG as deleteFlag,  ")
				.append(" t.ENVIRONMENT_TYPE as environmentType, ")
				.append(" t.DATA_TYPE as dataType ")
				.append(" from CMN_SERVERS_INFO t  )  o where deleteFlag='0' and o.serverIp=:serverIp and o.appsysCode =:appsysCode ");
			return getSession().createSQLQuery(sql.toString())
					.setString("serverIp", serverIp)
					.setString("appsysCode", appsysCode).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
					.uniqueResult();

		}
	
	/** 
	 * 查询服务器信息


	 * */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryserversSynchronousList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) throws SQLException{
		
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\" ,")
				.append(" o.serverName as \"serverName\", ")
				.append(" o.serverIp as \"serverIp\", ")
				.append(" o.serverIp as \"serverIpHide\", ")
				.append("o.appsysCode as \"appsysCodeHide\" , ")
				.append(" o.machineroomPosition as \"machineroomPosition\", ")
				.append(" o.bsaAgentFlag as \"bsaAgentFlag\", ")
				.append(" o.floatingIp as \"floatingIp\", ")
				.append(" o.serverRole as \"serverRole\", ")
				.append(" o.serverUse as \"serverUse\", ")
				.append("  o.osType as \"osType\" ,")
				.append("  o.mwType as \"mwType\" ,")
				.append("  o.dbType as \"dbType\" ,")
				.append("  o.collectionState as \"collectionState\" ,")
				.append("  o.deleteFlag as \"deleteFlag\" ,")
				.append("  o.environmentType as \"environmentType\" ,")
				.append("  o.dataType as \"dataType\" ")
				.append(" from(select  t.APPSYS_CODE as appsysCode,    ")
				.append(" t.SERVER_NAME as serverName, 	  ")
				.append(" t.SERVER_IP as serverIp, 	  ")
				.append(" t.MACHINEROOM_POSITION as machineroomPosition,  ")
				.append(" t.BSA_AGENT_FLAG as bsaAgentFlag,   ")
				.append(" t.FLOATING_IP as floatingIp,    ")
				.append(" t.SERVER_ROLE as serverRole,    ")
				.append(" t.SERVER_USE as serverUse, 	  ")
				.append(" t.OS_TYPE as osType,  ")
				.append(" t.MW_TYPE as mwType,  ")
				.append(" t.DB_TYPE as dbType,  ")
				.append(" t.COLLECTION_STATE as collectionState,  ")
				.append(" t.DELETE_FLAG as deleteFlag,  ")
				.append(" t.ENVIRONMENT_TYPE as environmentType, ")
				.append(" t.DATA_TYPE as dataType ")
				.append(" from CMN_SERVERS_INFO t  )  o where deleteFlag='0' ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and lower(" + key + ") like  lower(:" + key + " ) ");
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		sql.append(" order by \"" + sort + "\" " + dir);

		Query query = getSession().createSQLQuery(sql.toString())									 
									.addScalar("appsysCode", StringType.INSTANCE)
									.addScalar("serverName", StringType.INSTANCE)
									.addScalar("serverIp", StringType.INSTANCE)
									.addScalar("machineroomPosition", StringType.INSTANCE)
									.addScalar("bsaAgentFlag", StringType.INSTANCE)
									.addScalar("floatingIp", StringType.INSTANCE)
									.addScalar("serverRole", StringType.INSTANCE)
									.addScalar("serverUse", StringType.INSTANCE)
									.addScalar("osType", StringType.INSTANCE)
									.addScalar("mwType", StringType.INSTANCE)
									.addScalar("dbType", StringType.INSTANCE)
									.addScalar("collectionState", StringType.INSTANCE)
									.addScalar("deleteFlag", StringType.INSTANCE)
									.addScalar("environmentType", StringType.INSTANCE)
									.addScalar("dataType", StringType.INSTANCE)
									.addScalar("serverIpHide", StringType.INSTANCE)
									.addScalar("appsysCodeHide", StringType.INSTANCE)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		List<Map<String,String>> list =query.list();
		for(Map<String, String> allmap :list){
			if(allmap.get("bsaAgentFlag").equals("1")){
				allmap.put("bsaAgentFlag", "已安装");
			}else{
				allmap.put("bsaAgentFlag", "未安装");
			}
			
		}
		
		request.getSession().setAttribute("ServersSynchronousList4Export",list );
		List<Map<String, String>> alllist=query.setMaxResults(limit).setFirstResult(start).list();
		
		//当前时间
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		
		StringBuilder hqlupdate = new StringBuilder();
		hqlupdate.append("select new map( t.serverIp as serverIp,t.appsysCode as appsysCode, to_char(t.updateTime ,'yyyymmdd ') as updateTime,t.updateBeforeRecord as updateBeforeRecord ) from  ServersInfoVo  t where to_char(t.updateTime,'yyyymmdd')=to_char(sysdate,'yyyymmdd')");
		Query query2 = getSession().createQuery(hqlupdate.toString());
		List<Map<String, String>> updatelist =query2.list();
		
		for(Map<String, String> updatemap :updatelist){
			
			Map<String, String > oldmap = new HashMap<String, String>();
			//更新纪录
			String updateRecord = ComUtil.checkNull(updatemap.get("updateBeforeRecord"));
		
			for(Map<String, String> allmap :alllist){
			if(!(updateRecord.equals("")||updateRecord==null) && updatemap.get("serverIp").equals(allmap.get("serverIp"))&& updatemap.get("appsysCode").equals(allmap.get("appsysCode"))){
				String serverIp = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[0]);
				String serverName = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[1]);
				String appsysCode = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[2]);
				String floatingIp = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[3]);
				String osType = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[4]);
				String mwType = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[5]);
				String dbType = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[6]);
				String collectionState = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[7]);
				String environmentType = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[8]);
				String machineroomPosition = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[9]);
				String serverRole = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[10]);
				String serverUse = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[11]);
				String dataType = ComUtil.checkNull(updateRecord.split(Constants.SPLIT_SEPARATEOR)[12]);
				oldmap.put("serverIp", serverIp);
				oldmap.put("serverName", serverName);
				oldmap.put("appsysCode", appsysCode);
				oldmap.put("floatingIp", floatingIp);
				oldmap.put("osType", osType);
				oldmap.put("mwType", mwType);
				oldmap.put("dbType", dbType);
				oldmap.put("collectionState", collectionState);
				oldmap.put("environmentType", environmentType);
				oldmap.put("machineroomPosition", machineroomPosition);
				oldmap.put("serverRole", serverRole);
				oldmap.put("serverUse", serverUse);
				oldmap.put("dataType", dataType);
				for(String key : oldmap.keySet()){
					String o=oldmap.get(key);
					String a =(String)allmap.get(key);
					
					if(!o.equals(a) ){
						allmap.put(key , "<span style=\"color:red\">" + ComUtil.checkNull(allmap.get(key))+ "</span>");
					}
				} 
			  }
			if((updateRecord.equals("")||updateRecord==null) && updatemap.get("serverIp").equals(allmap.get("serverIp"))&&updatemap.get("appsysCode").equals(allmap.get("appsysCode")) ){
				for(String key : allmap.keySet()){
					if(!(key.equals("bsaAgentFlag")||key.equals("serverIpHide")||key.equals("appsysCodeHide")||key.equals("dataType"))){
						allmap.put(key , "<span style=\"color:red\">" + ComUtil.checkNull(allmap.get(key))+ "</span>");
					}
					} 
			}
			
			}	
		}
		

		return alllist;
	}


	
	/**
	 * 查询应用系统及管理员分配信息
	 * @param start 起始记录数

	 * @param limit 限制记录数

	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @return 应用系统及管理员分配信息映射集合
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String,String>> queryosuserList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) throws SQLException{
		StringBuilder hql = new StringBuilder();
				
			hql.append("select new map( ")
				.append("	t.appsysCode as appsysCode, ")
				.append("	t.serverIp as serverIp, ")
				.append("	t.osUser as osUser, ")
				.append("	t.userId as userId, ")
				.append("	t.appsysCode as appsysCodeHide, ")
				.append("	t.serverIp as serverIpHide, ")
				.append("	t.dataType as dataType, ")
				.append("	t.osUser as osUserHide, ")
				.append("	t.userId as userIdHide) ")
				.append("from ApposUserVo t ")
				.append("where deleteFlag='0' ");
				for(String key : params.keySet()){
					if(fields.get(key).equals(FieldType.STRING)){
						hql.append(" and t." + key + " like :" + key);
					}else{
						hql.append(" and t." + key + " = :" + key);
					}
				}
				hql.append(" order by t." + sort + " " + dir);
				
				Query query = getSession().createQuery(hql.toString());
				if(params.size() > 0){
					query.setProperties(params);
				}
				
				request.getSession().setAttribute("osUserList4Export", query.list());
				List<Map<String, String>> alllist = query.setMaxResults(limit).setFirstResult(start).list();
			
				
				//当前时间
				Date date = new Date();
				SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
				String strDate = matter.format(date);
				
				StringBuilder hqlupdate = new StringBuilder();
				hqlupdate.append("select new map( t.serverIp as serverIp,t.appsysCode as appsysCode,t.dataType as dataType,t.osUser as osUser,t.userId as userId,to_char(t.updateTime ,'yyyymmdd ') as updateTime,t.updateBeforeRecord as updateBeforeRecord ) from  ApposUserVo  t where to_char(t.updateTime,'yyyymmdd')=to_char(sysdate,'yyyymmdd')");
				Query query2 = getSession().createQuery(hqlupdate.toString());
				List<Map<String, String>> updatelist =query2.list();
				
				for(Map<String, String> updatemap :updatelist){
					
					//更新纪录
					String updateRecord = ComUtil.checkNull(updatemap.get("updateBeforeRecord"));
				
					for(Map<String, String> allmap :alllist){
					if((updateRecord.equals("")||updateRecord==null) && updatemap.get("serverIp").equals(allmap.get("serverIp"))&& updatemap.get("appsysCode").equals(allmap.get("appsysCode"))&& updatemap.get("osUser").equals(allmap.get("osUser"))&& updatemap.get("userId").equals(allmap.get("userId")) ){
						for(String key : allmap.keySet()){
							if(key.indexOf("Hide")==-1){
								String s;
								if(key.indexOf("appsysCode")!=-1){
									List<Map<String, Object>> appsysname=getAppName(ComUtil.checkNull(allmap.get(key)).toString());
									s=ComUtil.checkNull(appsysname.size()>0?appsysname.get(0).get("appsys_name"):ComUtil.checkNull(allmap.get(key)).toString());
									//s=ComUtil.checkNull(getAppName(ComUtil.checkNull(allmap.get(key)).toString()).get(0).get("appsys_name")).toString();
									
								}else if(key.indexOf("userId")!=-1){
									List<Map<String, Object>> uid=getIdName(ComUtil.checkNull(allmap.get(key)).toString());
									  s=ComUtil.checkNull(uid.size()>0?uid.get(0).get("userId"):ComUtil.checkNull(allmap.get(key)).toString());
								}
								else{
									s=ComUtil.checkNull(allmap.get(key)).toString();
								}
								  
							allmap.put(key , "<span style=\"color:red\">" + s+ "</span>");
							}
							} 
					}
					
					}	
				}
				return alllist;
	}
	/**
	 * 查询树的子节点数据

	 * @param serverGroup 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> queryChildren(String appsysCode, String serverGroup) {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct o.appsys_code as \"appsysCode\",o.server_group as \"serverGroup\",o.SERVER_IP as \"serverIp\" from ( ")
		.append(" select t.appsys_code , s.SERVER_IP,t.server_group")
		.append(" from cmn_app_group t LEFT JOIN  CMN_APP_GROUP_SERVER s on t.server_group=s.server_group and t.appsys_code=s.appsys_code ")
		.append("  and appsys_code =:appsysCode and server_group =:serverGroup ) o,cmn_servers_info f ")
		.append(" where o.SERVER_IP = f.SERVER_IP  and f.appsys_code =:appsysCode and f.delete_flag = '0' ");
		Query query = getSession().createSQLQuery(sql.toString())
				  .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				  .setString("appsysCode", appsysCode)
				  .setString("serverGroup", serverGroup);
								  
			return query.list();
	}

	
	/**
	 * 查询数据库中所有系统信息
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<AppInfoItsmVo> queryAppinfo() throws SQLException{
		return getSession().createQuery("from AppInfoItsmVo t").list();
	}
	
	/**
	 * 检查服务器是否安装Agent
	 * @param list 
	 * @return 
	 * @throws AxisFault 
	 * @throws Exception 
	 */
	@Transactional
	public String doAgent(List<String> list)  throws DataAccessException, AxisFault,Exception{
		List<String> serList=new ArrayList<String>();
		List<String> AppList=new ArrayList<String>();
		for(String record : list){
			String ServerIp = record.split(Constants.SPLIT_SEPARATEOR)[0];
			String AppsysCode = record.split(Constants.SPLIT_SEPARATEOR)[1];
			AppList.add(AppsysCode);
			serList.add(ServerIp);
		}
		//更新最后一次BSA巡检时间
		this.saveOrUpdateDate(AppList);
		
		String lastAgentInfo=""; //BSA返回信息
		String agentInfoAll = "";// 传到界面的VOID信息
		String serverIp = "";//服务器信息
		int appindex ;// “>”的位置
		int sysindex ;// “<”的位置
		//1.用户登录
		LoginServiceClient client = new LoginServiceClient();
		LoginUsingSessionCredentialResponse loginResponse = client.getBsaCredential();
		for(int i=0;i<serList.size();i++){
			serverIp=serList.get(i);
			
			if(serList.get(i).contains("</span>")){
				 appindex = serList.get(i).indexOf(">");
				 sysindex=serList.get(i).lastIndexOf("<");
				 serverIp = serList.get(i).substring(appindex+1, sysindex);
			}

			//3.执行cli命令
			CLITunnelServiceClient cliClient = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
			ExecuteCommandByParamListResponse cliResponse = cliClient.executeCommandByParamList("Server", "getFullyResolvedPropertyValue", new String[]{""+serverIp+"","AGENT_STATUS"});
			String agentinfo = (String) cliResponse.get_return().getReturnValue();
			lastAgentInfo = agentinfo.substring(agentinfo.lastIndexOf(" ")+1);
			 if(!lastAgentInfo.equals("void")){
				 if(lastAgentInfo.equals("alive")){
					 String sql="update cmn_servers_info set bsa_agent_flag='1'   where server_ip='"+serverIp+"'";
					 getSession().createSQLQuery(sql).executeUpdate();
				 }else{
					 String sql2="update cmn_servers_info set bsa_agent_flag='0'   where server_ip='"+serverIp+"'";
					 getSession().createSQLQuery(sql2).executeUpdate(); 
					
				 }
				
			 }else{
				 
				 //添加服务器到BSA中

				CLITunnelServiceClient cliClient1 = new CLITunnelServiceClient(loginResponse.getReturnSessionId(), null);
				ExecuteCommandByParamListResponse cliResponse1 = cliClient1.executeCommandByParamList("Server", "addServer", new String[]{""+serverIp+""});
				String serinfo = (String) cliResponse1.get_return().getReturnValue();
				if(!serinfo.equals("void")){
					 String sql="update cmn_servers_info set bsa_agent_flag='1'   where server_ip='"+serverIp+"'";
					 getSession().createSQLQuery(sql).executeUpdate();
				}else{

					 String sql2="update cmn_servers_info set bsa_agent_flag='0'   where server_ip='"+serverIp+"'";
					 getSession().createSQLQuery(sql2).executeUpdate(); 
					
					 // 传到界面的VOID信息
					 agentInfoAll += serverIp+"\n";
				}
				 
				 
			 }
			
		}
		return agentInfoAll;
	}
	
	/**
	 * 同步配置信息管理系统信息FTP获取文件
	 * 
	 * @param customer
	 */
	@Transactional
	public  void ftpFile(String filePath) throws FtpCmpException{
		/*String host="10.1.7.28";
		int port = 21;
		String user = "appdata";
		String password = "appdataceb";*/
		String host=messages.getMessage("importServer.ipAdress");
		int port = (Integer.parseInt(messages.getMessage("importServer.port")));
		String user = messages.getMessage("importServer.user");
		String password=messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);

		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		String serInfo=messages.getMessage("exportServer.toolpath").concat(CommonConst.SLASH).concat(messages.getMessage("importServer.interfaceFilePath")).concat(CommonConst.SLASH).concat("SERVERS_INFO-").concat(strDate).concat(CommonConst.FILE_SUFFIX_DAT);
        
        ftpFile.doGet(serInfo, filePath, true,new StringBuffer());
		//ftpFile.doGet("/appdata/SERVERS_INFO-20131201.dat", filePath, true,new StringBuffer());
		ftpLogin.disconnect();
	}
	
	/**
	 * 同步配置信息管理系统信息
	 * @return 
	 * @throws Exception 
	 * @throws NoSuchMessageException 
	 */
	@Transactional(readOnly = true , propagation=Propagation.NOT_SUPPORTED)
	public List<ServersInfoVo> readServersInfosFromFile(Long logJnlNo,StringBuilder errNum,StringBuilder Num,StringBuilder Path) throws UnsupportedEncodingException, FileNotFoundException,IOException{
		//String filePath="D:\\test\\SERVERS_INFO-20131201.dat";
		int err=0;
		String crlf=System.getProperty("line.separator");
		String fileFoder=System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.interfaceFile");
		File foder = new File(fileFoder);
		//创建interface文件夹

		if(!foder.exists()){
			foder.mkdir();
		}
		
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		
		String filePath = System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.interfaceFile")+ File.separator + "SERVERS_INFO-"+strDate+".dat";
		ftpFile(filePath);
		
		String[] typicalCapaAnaArr = new String[Constants.SERVER_INFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ServersInfoVo> inputFileList = new ArrayList<ServersInfoVo>();
		List<String>  flagFordata = new ArrayList<String>();
		ServersInfoVo vo = null;
		StringBuilder stdErr =new StringBuilder();
		List<String> primaryKeyCheckList = new ArrayList<String>();
		List<String> primaryKeyCheckList3 = new ArrayList<String>();
		int rowNumber = 0;
		in = new FileInputStream(file);
		reader = new BufferedReader(new InputStreamReader(in,"gbk"));
		while((typicalCapaAnaStr = reader.readLine()) != null){
			String typicalCapaAnaStrError=typicalCapaAnaStr;
			//拆分数据
			typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
			
			//行号计数
			++rowNumber;
			
			//行的长度Check
			if(typicalCapaAnaArr.length != Constants.SERVER_INFO_COLUMNS){
				err++;
				stdErr.append(">@>"+ messages.getMessage("check.error.line", new Object[]{rowNumber}) );
				stdErr.append(">@>");
				stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.SERVER_INFO_COLUMNS)}));
				stdErr.append(">@>"+typicalCapaAnaStrError);
				stdErr.append(crlf);
				continue;
			}
			//校验服务器表的有效性
			boolean bl=CheckData(typicalCapaAnaStrError,typicalCapaAnaArr, stdErr, rowNumber,primaryKeyCheckList);
			if(bl){
				
				primaryKeyCheckList3.add(typicalCapaAnaStrError);
			}else{
				err++;
			}
			
		}
		if(reader != null){
			reader.close();
		}
		errNum.append(String.valueOf(err));
		//数据验证异常
        if(stdErr.length() > 0 ){
        	String logpath=ComUtil.writeLogFile(stdErr.toString(), 1);
        	
        	cmnDetailLogService.updateBydetailLog(logJnlNo, 1, logpath);
    		//更新脚步执行结束时间
    		cmnLogService.updateCMNLOGPaltForm(logJnlNo);
    		Path.append(logpath);
    		
    		//throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
        }
        
        Num.append(String.valueOf(primaryKeyCheckList3.size()));

        	
//			in = new FileInputStream(file);
//			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			
//			while((typicalCapaAnaStr = reader.readLine()) != null){
            for(int k=0;k<primaryKeyCheckList3.size();k++){
        	
        
				//拆分数据
				typicalCapaAnaArr = primaryKeyCheckList3.get(k).split(Constants.SPLIT_SEPARATEOR, -1);
				
			
				
				if(flagFordata.contains(typicalCapaAnaArr[1]+typicalCapaAnaArr[3])){
					
				}else{
					flagFordata.add(typicalCapaAnaArr[1]+typicalCapaAnaArr[3]);
					vo=new ServersInfoVo();
					vo.setServerIp(typicalCapaAnaArr[1]);
					vo.setServerName(typicalCapaAnaArr[2]);
					vo.setAppsysCode(typicalCapaAnaArr[3]);
					vo.setFloatingIp(typicalCapaAnaArr[4]);
					
					vo.setServerRole(typicalCapaAnaArr[5]);
					vo.setServerUse(typicalCapaAnaArr[6]);
					
					vo.setMachineroomPosition(typicalCapaAnaArr[7]);
					vo.setOsType(typicalCapaAnaArr[8]);
					vo.setMwType(typicalCapaAnaArr[9]);
					vo.setDbType(typicalCapaAnaArr[10]);
					vo.setCollectionState(typicalCapaAnaArr[11]);
					vo.setEnvironmentType(typicalCapaAnaArr[12]);
					vo.setDataType(typicalCapaAnaArr[13]);
					inputFileList.add(vo);
				}
				
				if(typicalCapaAnaArr[4]!=null&&!typicalCapaAnaArr[4].equals("")&&!typicalCapaAnaArr[4].equals(typicalCapaAnaArr[1])){
					String []FIPs=typicalCapaAnaArr[4].split(" ");
					for(int i=0;i<FIPs.length;i++){
						if(flagFordata.contains(FIPs[i]+typicalCapaAnaArr[3])){
							
						}else{
					vo=new ServersInfoVo();
					flagFordata.add(FIPs[i]+typicalCapaAnaArr[3]);
					vo.setServerIp(FIPs[i]);
					vo.setServerName(typicalCapaAnaArr[2]);
					vo.setAppsysCode(typicalCapaAnaArr[3]);
					vo.setFloatingIp(FIPs[i]);
					
					vo.setServerRole(typicalCapaAnaArr[5]);
					vo.setServerUse(typicalCapaAnaArr[6]);
					
					vo.setMachineroomPosition(typicalCapaAnaArr[7]);
					vo.setOsType(typicalCapaAnaArr[8]);
					vo.setMwType(typicalCapaAnaArr[9]);
					vo.setDbType(typicalCapaAnaArr[10]);
					vo.setCollectionState(typicalCapaAnaArr[11]);
					vo.setEnvironmentType(typicalCapaAnaArr[12]);
					vo.setDataType(typicalCapaAnaArr[13]);
					inputFileList.add(vo);
						}
					}
								
				}		
            }
//			}
			
			
//			if(reader != null){
//				reader.close();
//			}
	        
			
			
      	file.delete();
        	
		return inputFileList;
		
	}
	
	/**
	 * 读取错误数据文件
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public List<Map<String, String>> readErrorInfo( String Path ,HttpServletRequest request)
			 {
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(Path);
	    String error ="";
		HashMap<String,String> map=new HashMap<String,String>();
		List<Map<String, String>> errorlistdata = new ArrayList<Map<String, String>>();
		try {
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"utf-8"));
			while((error = reader.readLine()) != null){
				String[] errors=error.split(">@>");
				map=new HashMap<String,String>();
				map.put("errorRownumber", errors[1]);
				map.put("errorType", errors[2]);
				map.put("errorData", errors[3]);
				errorlistdata.add(map);
			}
			if(reader != null){
				reader.close();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		request.getSession().setAttribute("ErrorExport",errorlistdata );
		return errorlistdata;
	}
	
	/**
	 * 检查配置服务器信息系统内容

	 * @return 
	 * @throws Exception 
	 * @throws NoSuchMessageException 
	 
	 */
	
	public boolean CheckData(String typicalCapaAnaStrError,String[] typicalCapaAnaArr, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		String crlf=System.getProperty("line.separator");
		boolean bl=true;
		Pattern p=Pattern.compile("[\\s0-9.]*");
		
		StringBuilder errMsg = new StringBuilder();
		String ziDuan=typicalCapaAnaArr[1]+","+typicalCapaAnaArr[3];
		String FloatIP=typicalCapaAnaArr[4];
		if(!primaryKeyCheckList.contains(ziDuan)){
			primaryKeyCheckList.add(ziDuan);
		}else{
			errMsg.append(">@>存在主键重复数据,主键=[" + typicalCapaAnaArr[1] + "|+|"+typicalCapaAnaArr[3]+"]");
			errMsg.append(">@>"+typicalCapaAnaStrError);
		}
		
		if(FloatIP.length()>0){
			Matcher m=p.matcher(FloatIP);
			boolean b=m.matches();
			if(!b){
				errMsg.append(">@>浮动IP格式不对=["+typicalCapaAnaArr[4]+"]");
				errMsg.append(">@>"+typicalCapaAnaStrError);
			}
		}
		
		//结束
		if(errMsg.length() != 0){
			bl=false;
			if(rowNumber > 0){
				stdErr.append(">@>" + messages.getMessage("check.error.line", new Object[]{rowNumber}));
			}
			stdErr.append(errMsg.toString());
			stdErr.append(crlf);
		}
		
		return bl;
	}
	
	public void CheckDataServerinfo(String serverIp,String appsysCode, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		String ziDuan=serverIp+","+appsysCode;
		if(!primaryKeyCheckList.contains(ziDuan)){
			primaryKeyCheckList.add(ziDuan);
		}else{
			errMsg.append("存在主键重复数据,主键=[" + serverIp + "|+|"+appsysCode+"]");
		}
		
		//结束
		if(errMsg.length() != 0){
			if(rowNumber > 0){
				stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
			}
			stdErr.append(errMsg.toString());
			stdErr.append("<br>");
		}
	}
	
	
	/**
	 * 查询服务器信息
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public List<ServersInfoVo> queryServerInfo() throws SQLException {
		return getSession().createQuery("from ServersInfoVo t ").list();
	}
	
	/**
	 * 查询服务器信息

	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	public List<ServersInfoVo> queryServer() throws SQLException {
		return getSession().createQuery("from ServersInfoVo t where t.bsaAgentFlag='1'").list();
	}
	/**
	 * 处理配置系统信息
	 * @return 
	 * @throws IOException 
	 */
	
	@Transactional
	public void saveOrUpdateAdmin(List<ServersInfoVo> inputFileList,
			List<ServersInfoVo> serverList) throws IOException  {
		List<ServersInfoVo> serInfoList = new ArrayList<ServersInfoVo>();
		for(int i=0;i<inputFileList.size();i++){
			ServersInfoVo svo=null;
			//配置管理系统的服务器IP
			String fileSer = inputFileList.get(i).getServerIp();
			String fileserverName = inputFileList.get(i).getServerName();
			String fileappsysCode = inputFileList.get(i).getAppsysCode();
			String filefloatingIp = inputFileList.get(i).getFloatingIp();
			String fileosType = inputFileList.get(i).getOsType();
			String filemwType = inputFileList.get(i).getMwType();
			String filedbType = inputFileList.get(i).getDbType();
			String filecollectionState = inputFileList.get(i).getCollectionState();
			String fileenvironmentType = inputFileList.get(i).getEnvironmentType();
			String filemachineroomPosition = inputFileList.get(i).getMachineroomPosition();
			String fileserverRole = inputFileList.get(i).getServerRole();
			String fileserverUse = inputFileList.get(i).getServerUse();
			String filedataType=inputFileList.get(i).getDataType();
			
			Calendar cal = Calendar.getInstance();
			Long ss=cal.getTimeInMillis();
			Timestamp upTime	=new Timestamp(ss);
			if(serverList.size()==0){
				svo=new ServersInfoVo();
				svo.setDeleteFlag("0");
				svo.setBsaAgentFlag("0");
				svo.setServerIp(fileSer);
				svo.setUpdateTime(upTime);
				svo.setServerName(inputFileList.get(i).getServerName());
				svo.setAppsysCode(inputFileList.get(i).getAppsysCode());
				svo.setFloatingIp(inputFileList.get(i).getFloatingIp());
				svo.setServerRole(inputFileList.get(i).getServerRole());
				svo.setServerUse(inputFileList.get(i).getServerUse());
				svo.setMachineroomPosition(inputFileList.get(i).getMachineroomPosition());
				svo.setOsType(inputFileList.get(i).getOsType());
				svo.setMwType(inputFileList.get(i).getMwType());
				svo.setDbType(inputFileList.get(i).getDbType());
				svo.setCollectionState(inputFileList.get(i).getCollectionState());
				svo.setEnvironmentType(inputFileList.get(i).getEnvironmentType());
				svo.setDataType(inputFileList.get(i).getDataType());
				svo.setAttrFlag("0");
			}else{
			for(int j=0;j<serverList.size();j++){
				//数据库中的服务器IP
				String ser = serverList.get(j).getServerIp();
				String serverName = serverList.get(j).getServerName();
				String appsysCode = serverList.get(j).getAppsysCode();
				String floatingIp = serverList.get(j).getFloatingIp();
				String osType = serverList.get(j).getOsType();
				String mwType = serverList.get(j).getMwType();
				String dbType = serverList.get(j).getDbType();
				String collectionState = serverList.get(j).getCollectionState();
				String environmentType = serverList.get(j).getEnvironmentType();
				String machineroomPosition = serverList.get(j).getMachineroomPosition();
				String serverRole = serverList.get(j).getServerRole();
				String serverUse = serverList.get(j).getServerUse();
				String dataType = serverList.get(j).getDataType();
				
					if(fileSer.equals(ser)&&fileappsysCode.equals(appsysCode)){
						svo=serverList.get(j);
						if(!fileserverName.equals(ComUtil.checkNull(serverName))||!fileappsysCode.equals(ComUtil.checkNull(appsysCode))
								||!filefloatingIp.equals(ComUtil.checkNull(floatingIp))||!fileosType.equals(ComUtil.checkNull(osType))
								||!filemwType.equals(ComUtil.checkNull(mwType))||!filedbType.equals(ComUtil.checkNull(dbType))
								||!filecollectionState.equals(ComUtil.checkNull(collectionState))||!fileenvironmentType.equals(ComUtil.checkNull(environmentType))
								||!filemachineroomPosition.equals(ComUtil.checkNull(machineroomPosition))||!fileserverRole.equals(ComUtil.checkNull(serverRole))
								||!fileserverUse.equals(ComUtil.checkNull(serverUse))||!filedataType.equals(ComUtil.checkNull(dataType))){
							  if(collectionState.equals("成功")&&!filecollectionState.equals("成功")){
									
								}else{
							
								svo.setUpdateBeforeRecord(ser+"|+|"+serverName+"|+|"+appsysCode+"|+|"+floatingIp+"|+|"+osType+"|+|"+mwType+"|+|"+dbType+"|+|"+collectionState+"|+|"+environmentType+"|+|"+machineroomPosition+"|+|"+serverRole+"|+|"+serverUse+"|+|"+dataType);
								svo.setUpdateTime(upTime);
								svo.setAttrFlag("0");
								}
							}
						if(serverList.get(j).getDeleteFlag().equals("1")){
							svo.setUpdateBeforeRecord("");
							svo.setUpdateTime(upTime);
							svo.setDeleteFlag("0");
							serverList.remove(j);
							j--;
							
							svo.setServerName(inputFileList.get(i).getServerName());
							svo.setAppsysCode(inputFileList.get(i).getAppsysCode());
							svo.setFloatingIp(inputFileList.get(i).getFloatingIp());
							svo.setServerRole(inputFileList.get(i).getServerRole());
							svo.setServerUse(inputFileList.get(i).getServerUse());
							svo.setMachineroomPosition(inputFileList.get(i).getMachineroomPosition());
							svo.setOsType(inputFileList.get(i).getOsType());
							svo.setMwType(inputFileList.get(i).getMwType());
							svo.setDbType(inputFileList.get(i).getDbType());
							svo.setCollectionState(inputFileList.get(i).getCollectionState());
							svo.setEnvironmentType(inputFileList.get(i).getEnvironmentType());
							svo.setDataType(inputFileList.get(i).getDataType());
							svo.setAttrFlag("0");
						}else{
							if(collectionState.equals("成功")&&!filecollectionState.equals("成功")){
								
							}else{
								svo.setServerName(inputFileList.get(i).getServerName());
								svo.setAppsysCode(inputFileList.get(i).getAppsysCode());
								svo.setFloatingIp(inputFileList.get(i).getFloatingIp());
								svo.setServerRole(inputFileList.get(i).getServerRole());
								svo.setServerUse(inputFileList.get(i).getServerUse());
								svo.setMachineroomPosition(inputFileList.get(i).getMachineroomPosition());
								svo.setOsType(inputFileList.get(i).getOsType());
								svo.setMwType(inputFileList.get(i).getMwType());
								svo.setDbType(inputFileList.get(i).getDbType());
								svo.setCollectionState(inputFileList.get(i).getCollectionState());
								svo.setEnvironmentType(inputFileList.get(i).getEnvironmentType());
								svo.setDataType(inputFileList.get(i).getDataType());
								
							}
							serverList.remove(j);
							j--;
						}
						
						break;
					}
				
				if(j==serverList.size()-1){
					svo=new ServersInfoVo();
					svo.setDeleteFlag("0");
					svo.setBsaAgentFlag("0");
					svo.setAttrFlag("0");
					svo.setServerIp(fileSer);
					svo.setUpdateTime(upTime);
					svo.setServerName(inputFileList.get(i).getServerName());
					svo.setAppsysCode(inputFileList.get(i).getAppsysCode());
					svo.setFloatingIp(inputFileList.get(i).getFloatingIp());
					svo.setServerRole(inputFileList.get(i).getServerRole());
					svo.setServerUse(inputFileList.get(i).getServerUse());
					svo.setMachineroomPosition(inputFileList.get(i).getMachineroomPosition());
					svo.setOsType(inputFileList.get(i).getOsType());
					svo.setMwType(inputFileList.get(i).getMwType());
					svo.setDbType(inputFileList.get(i).getDbType());
					svo.setCollectionState(inputFileList.get(i).getCollectionState());
					svo.setEnvironmentType(inputFileList.get(i).getEnvironmentType());
					svo.setDataType(inputFileList.get(i).getDataType());
				}
			}
		}
			
			
			serInfoList.add(svo);
			
		}
		saveOrUpdate(serInfoList,serverList);
		
		
	}
	/**
	 * 处理配置系统LIST信息
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@Transactional
	private void saveOrUpdate(List<ServersInfoVo> serInfoList,List<ServersInfoVo> serverList) throws IOException{
		if(serInfoList!=null && serInfoList.size()>0){
			for(int i=0;i<serInfoList.size();i++){
				saveOrUpdate2(serInfoList.get(i));
			}
		}
		if(serverList!=null && serverList.size()>0){
			for(int j=0;j<serverList.size();j++){
				if(!serverList.get(j).getDeleteFlag().equals("1")&&!serverList.get(j).getDataType().equals("H")){
					serverList.get(j).setDeleteFlag("1");
				}
				saveOrUpdate2(serverList.get(j));
			}
		}
	}
	
	/**
	 * 保存并更新配置系统信息

	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	private void saveOrUpdate2(ServersInfoVo serversInfoVo) {
		getSession().saveOrUpdate(serversInfoVo);		
	}
	/**
	 * sumpFTP获取文件
	 * 
	 * @param customer
	 */
	@Transactional
	public  void ftpSumpFile(String filePath) {
	/*	String host="10.1.7.28";
		int port = 21;
		String user = "appdata";
		String password = "appdataceb";*/
		String host=messages.getMessage("importServer.ipAdress");
		int port = (Integer.parseInt(messages.getMessage("importServer.port")));
		String user = messages.getMessage("importServer.user");
		String password=messages.getMessage("importServer.password");
		ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
		ftpLogin.connect(host,port,user,password);
		ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
		
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date);
		
		String appOsInfo=messages.getMessage("exportServer.toolpath").concat(CommonConst.SLASH).concat(messages.getMessage("importServer.interfaceFilePath")).concat(CommonConst.SLASH).concat("APP_OS_USER-").concat(strDate).concat(CommonConst.FILE_SUFFIX_DAT);
		ftpFile.doGet(appOsInfo, filePath, true,new StringBuffer());
		//ftpFile.doGet("/home/jeda/maop/APP_OS_USER-20131201.dat", filePath, true,new StringBuffer());
		ftpLogin.disconnect();
	}
	/**
	 * 同步sump系统信息
	 * @param path 
	 * @param num 
	 * @param errNum 
	 * @param CheckError 
	 * @return 
	 * @throws UnsupportedEncodingException 
	 * @throws FileNotFoundException 
	 * @throws IOException 
	 
	 */
	@Transactional
	public List<ApposUserVo> readApposUserFromFile(Long logJnlNo, StringBuilder errNum, StringBuilder Num, StringBuilder Path, StringBuilder CheckError) throws UnsupportedEncodingException, FileNotFoundException,IOException {

		
		int err=0;
		String crlf=System.getProperty("line.separator");
		String fileFoder= System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.interfaceFile");
		File foder = new File(fileFoder);
		//创建interface文件夹

		if(!foder.exists()){
			foder.mkdir();
		}
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMdd");
		String strDate = matter.format(date); 
		
		String filePath = System.getProperty("maop.root")+File.separator  + messages.getMessage("systemServer.interfaceFile")+ File.separator + "APP_OS_USER-"+strDate+".dat";
		ftpSumpFile(filePath);
		
		List<ApposUserVo> inputSumpList = new ArrayList<ApposUserVo>();
		String[] typicalCapaAnaArr = new String[Constants.APPOS_User_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		ApposUserVo vo = null;
		StringBuilder stdErr = new StringBuilder();
		int rowNumber = 0;
		List<String> primaryKeyCheckList = new ArrayList<String>();
		List<String> primaryKeyCheckList3 = new ArrayList<String>();
		in = new FileInputStream(file);
		reader = new BufferedReader(new InputStreamReader(in,"gbk"));
		while((typicalCapaAnaStr = reader.readLine()) != null){
			//拆分数据
			typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
			
			//行号计数
			++rowNumber;
			
			//行的长度Check
			if(typicalCapaAnaArr.length != Constants.APPOS_User_COLUMNS){
				err++;
				stdErr.append(">@>" + messages.getMessage("check.error.line", new Object[]{rowNumber}) );
				stdErr.append(">@>");
				stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.APPOS_User_COLUMNS)}));
				stdErr.append(">@>");
				stdErr.append(typicalCapaAnaStr);
				stdErr.append(crlf);
				continue;
			}
			
			//校验服务器表的有效性

			String oSuser=typicalCapaAnaArr[0]+"|+|"+typicalCapaAnaArr[1]+"|+|"+typicalCapaAnaArr[2]+"|+|"+typicalCapaAnaArr[3];
			boolean bl=CheckDataSump(typicalCapaAnaStr,oSuser, stdErr, rowNumber,primaryKeyCheckList);
			if(bl){
				primaryKeyCheckList3.add(typicalCapaAnaStr);
			}else{
				err++;
			}
		}
		if(reader != null){
			reader.close();
		}
		errNum.append(String.valueOf(err));
		//数据验证异常
        if(stdErr.length() > 0 ){
        	String logpath=ComUtil.writeLogFile(stdErr.toString(), 2);
        	
        	cmnDetailLogService.updateBydetailLog(logJnlNo, 1, logpath);
    		//更新脚步执行结束时间
    		cmnLogService.updateCMNLOGPaltForm(logJnlNo);
    		Path.append(logpath);
        	//throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
        }
        Num.append(String.valueOf(primaryKeyCheckList3.size()));
        CheckError.append(stdErr.toString());
//		in = new FileInputStream(file);
//		reader = new BufferedReader(new InputStreamReader(in,"gbk"));
//		while((typicalCapaAnaStr = reader.readLine()) != null){
			//拆分数据
        for(int k=0;k<primaryKeyCheckList3.size();k++){
			typicalCapaAnaArr = primaryKeyCheckList3.get(k).split(Constants.SPLIT_SEPARATEOR, -1);
			vo=new ApposUserVo();
			vo.setUserId(typicalCapaAnaArr[0]);
			//根据ITSM系统编号获取MAOP系统编码
			AppConfVo existConf = appInfoService.getAppConfByItsmCode(typicalCapaAnaArr[1]);
			if(existConf!=null){
				vo.setAppsysCode(existConf.getMaopAppsysCode());
			}else{
				vo.setAppsysCode(typicalCapaAnaArr[1]); //MAOP平台未配置时，存入系统编号
			}
			
			
			vo.setServerIp(typicalCapaAnaArr[2]);
			vo.setOsUser(typicalCapaAnaArr[3]);
			inputSumpList.add(vo);
			
		}
	/*	if(reader != null){
			reader.close();
		}*/
		
		file.delete();
		
		
		return inputSumpList;
	}

	
	/**
	 * 检查SUMP系统信息内容
	 * @return 
	 * @throws Exception 
	 * @throws NoSuchMessageException 
	 
	 */
	
	public boolean CheckDataSump(String typicalCapaAnaStr,String oSuser, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		String crlf=System.getProperty("line.separator");
		boolean bl=true;
		if(!primaryKeyCheckList.contains(oSuser)){
			primaryKeyCheckList.add(oSuser);
		}else{
			errMsg.append(">@>存在主键重复数据,主键=[" + oSuser + "]");
			errMsg.append(">@>"+typicalCapaAnaStr);
		}
		
		//结束
		if(errMsg.length() != 0){
			bl=false;
			if(rowNumber > 0){
				stdErr.append(">@>" + messages.getMessage("check.error.line", new Object[]{rowNumber}));
				errMsg.append(">@>"+typicalCapaAnaStr);
			}
			stdErr.append(errMsg.toString());
			stdErr.append(crlf);
		}
		return bl;
	}
	/**
	 * 查询操作系统用户管理表
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	public List<ApposUserVo> queryApposUser() throws SQLException{
		return getSession().createQuery("from ApposUserVo t").list();
	}
	
	/**
	 * 处理sump信息
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@Transactional
	public void saveOrUpdateSump(List<ApposUserVo> inputSumpList,
			List<ApposUserVo> apposUserList) throws IOException{
		List<ApposUserVo> UserList = new ArrayList<ApposUserVo>();
		for(int i=0;i<inputSumpList.size();i++){
			ApposUserVo avo=null;
			//配置管理系统的服务器IP
			String fileSer = inputSumpList.get(i).getServerIp();
			String fileapp=	inputSumpList.get(i).getAppsysCode();
			String fileosUser=inputSumpList.get(i).getOsUser();
			String fileuserId=inputSumpList.get(i).getUserId();
			
			Calendar cal = Calendar.getInstance();
			Long ss=cal.getTimeInMillis();
			Timestamp upTime	=new Timestamp(ss);
			boolean flag=false;
			if(apposUserList.size()==0){
				avo=new ApposUserVo();
				avo.setAppsysCode(fileapp);
				avo.setOsUser(fileosUser);
				avo.setServerIp(fileSer);
				avo.setUserId(fileuserId);
				avo.setDeleteFlag("0");
				avo.setDataType("A");
				avo.setUpdateTime(upTime);
				UserList.add(avo);
			}else{
			for(int j=0;j<apposUserList.size();j++){
				//数据库中的服务器IP
				String ser = apposUserList.get(j).getServerIp();
				String app =apposUserList.get(j).getAppsysCode();
				String osUser=apposUserList.get(j).getOsUser();
				String userId=apposUserList.get(j).getUserId();
				if(fileSer.equals(ser)&&fileapp.equals(app)&& fileosUser.equals(osUser) && fileuserId.equals(userId) ){
					flag=true;
					avo=apposUserList.get(j);
					if(apposUserList.get(j).getDeleteFlag().equals("1")){
						avo.setUpdateTime(upTime);	
					}
					avo.setDeleteFlag("0");
					avo.setDataType("A");
					apposUserList.remove(j);
					j--;
					break;
				  }
			    }
		
			if(flag==false ){
				avo=new ApposUserVo();
				avo.setAppsysCode(fileapp);
				avo.setOsUser(fileosUser);
				avo.setServerIp(fileSer);
				avo.setUserId(fileuserId);
				avo.setDeleteFlag("0");
				avo.setDataType("A");
				avo.setUpdateTime(upTime);
				UserList.add(avo);
			   }
		   }
		}
		saveOrUpdateApp(UserList,apposUserList);
		
	}
	/**
	 * 处理sump信息
	 * @param Path 
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@Transactional
	public int saveOrUpdateUserApp(List<ApposUserVo> inputSumpList,Long logJnlNo, StringBuilder Path, StringBuilder CheckError) throws IOException{
		String crlf=System.getProperty("line.separator");
		List<CmnUserAppVo> UserAppList = new ArrayList<CmnUserAppVo>();
		String UserId = null;
		String AppsysCode = null;
		String AppType = null;
		boolean flag = true;
		Long countUser = 0L;
		Long countApp = 0L;
		StringBuilder stdErr = CheckError;
		int strErrCount = 0;
		for(int i=0;i<inputSumpList.size();i++){
			String fileapp = inputSumpList.get(i).getAppsysCode();
			//if(fileapp.equals("null"))break;
			String fileuserId = inputSumpList.get(i).getUserId();
			countUser = Long.valueOf(getSession().createSQLQuery("select count(*) from jeda_user where user_id=:UserId")
					.setString("UserId", fileuserId).uniqueResult().toString());
			countApp = Long.valueOf(getSession().createSQLQuery("select COUNT(*) from v_cmn_app_info where appsys_code=:AppsysCode")
					.setString("AppsysCode", fileapp).uniqueResult().toString());
			if(countUser==0L||countApp==0L){
				if(countUser==0L&&countApp==0L){
					stdErr.append(">@>"+fileuserId+">@>"+fileapp+">@>错误信息：用户和应用系统都不存在！");
					
				}
				if(countUser==0L&&countApp!=0L){
					stdErr.append(">@>"+fileuserId+">@>"+fileapp+">@>错误信息：用户不存在！");
				}
				if(countUser!=0L&&countApp==0L){
					stdErr.append(">@>"+fileuserId+">@>"+fileapp+">@>错误信息：应用系统不存在！");
				}
				stdErr.append(crlf);
				strErrCount++;
				continue;
			}
			//System.out.println(fileapp+"|+|"+fileuserId);
			CmnUserAppVo cuao=null;
			if(UserAppList.size()==0){
				cuao = new CmnUserAppVo();
				cuao.setUserId(fileuserId);
				cuao.setAppsysCode(fileapp);
				//cuao.setAppType("A");
				UserAppList.add(cuao);
			}else{
				flag = true;
				for(int j=0;j<UserAppList.size();j++){
					UserId = UserAppList.get(j).getUserId();
					AppsysCode = UserAppList.get(j).getAppsysCode();
					if(UserId.equals(fileuserId)&&AppsysCode.equals(fileapp)){
						flag = false;
						break;
					}
				}
				if(flag==true){
					cuao = new CmnUserAppVo();
					cuao.setUserId(fileuserId);
					cuao.setAppsysCode(fileapp);
					//cuao.setAppType("A");
					UserAppList.add(cuao);
				}
			}
		}
		//System.out.println("====");
		
		String delSql = "delete cmn_user_app where app_type='A' ";
		getSession().createSQLQuery(delSql).executeUpdate();
		String countSql = null;
		String updateSql = null;
		String insertSql = null;
		Query query = null;
		Long count = 0L;
		for(int i=0;i<UserAppList.size();i++){
			UserId=UserAppList.get(i).getUserId();
			AppsysCode=UserAppList.get(i).getAppsysCode();
			AppType="A";//UserAppList.get(i).getAppType()
			//System.out.println(UserId+"|+|"+AppsysCode+"|+|"+AppType);
			countSql = "select count(*) from cmn_user_app where user_id=:UserId and appsys_code=:AppsysCode";
		    query = getSession().createSQLQuery(countSql.toString()).setString("UserId", UserId).setString("AppsysCode", AppsysCode);
		    count = Long.valueOf(query.uniqueResult().toString());
		    if(count>0){
		    	updateSql = "update cmn_user_app set app_type='H' where user_id=:UserId and appsys_code=:AppsysCode";
		    	getSession().createSQLQuery(updateSql.toString()).setString("UserId", UserId).setString("AppsysCode", AppsysCode).executeUpdate();
		    }else{
		    	insertSql = "insert into cmn_user_app(user_id,appsys_code,app_type,dply_flag,check_flag,tool_flag) values (:UserId,:AppsysCode,:AppType,'0','1','1')";
		    	getSession().createSQLQuery(insertSql.toString()).setString("UserId", UserId).setString("AppsysCode", AppsysCode).setString("AppType", AppType).executeUpdate();
		    }
		}
		
		if(stdErr.length() > 0 ){
			if(Path.toString().length()>0){
				String logPath =Path.toString();
				FileWriter writer =new FileWriter(logPath);
				BufferedWriter bw =new BufferedWriter(writer);
				stdErr.toString().replaceAll("<br>", "\n");
				bw.write(stdErr.toString());
				bw.close();
				writer.close();
				cmnDetailLogService.updateBydetailLog(logJnlNo, 1, Path.toString());
			}else{
				String logpath=ComUtil.writeLogFile(stdErr.toString(), 2);
	        	cmnDetailLogService.updateBydetailLog(logJnlNo, 1,logpath);
	        	Path.append(logpath);
			}
        	
        	
        }
		return strErrCount;
	}
	
	/**
	 * 处理sump系统LIST信息
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@Transactional
	private void saveOrUpdateApp(List<ApposUserVo> userList,
			List<ApposUserVo> apposUserList) throws IOException{
		
		for(int i=0;i<userList.size();i++){
			saveOrUpdateOsUser(userList.get(i));
		}
		for(int j=0;j<apposUserList.size();j++){
			if(!apposUserList.get(j).getDeleteFlag().equals("1")&&!apposUserList.get(j).getDataType().equals("H")){
				apposUserList.get(j).setDeleteFlag("1");
			}
			saveOrUpdateOsUser(apposUserList.get(j));
			
		}
	}
	
	/**
	 * 保存并更新sump系统信息
	 * @return 
	 * @throws IOException 
	 * @throws Exception 
	 */
	@Transactional
	private void saveOrUpdateOsUser(ApposUserVo apposUserVo) {
		getSession().saveOrUpdate(apposUserVo);		
		
	}
	
	/**
	 * 查询服务器分组关系表
	 * @return 
	 * @param serverIp
	 * @param appsysCode
	 * @throws IOException 
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	public List<AppGroupServerVo> queryAppGroupServer(
			String appsysCode) {
		
		return  getSession().createQuery("from AppGroupServerVo a where  appsysCode='"+appsysCode+"'").list();
	}
	
	
	
	/**
	 * BSA最后一次扫描时间
	 * @return 
	 * @param appsysCode
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	public void saveOrUpdateDate( List<String> appList) {
		String app = "";
		int appindex ;// “>”的位置
		int sysindex ;// “<”的位置
		for(int i=0;i<appList.size();i++){
			if(app.indexOf(appList.get(i))==-1){
				String appsysCode = appList.get(i);
				if(appList.get(i).contains("</span>")){
					 appindex = appList.get(i).indexOf(">");
					 sysindex=appList.get(i).lastIndexOf("<");
					 appsysCode = appList.get(i).substring(appindex+1, sysindex);
				}
				String sql="Update cmn_app_conf set last_scan_time= sysdate where maop_appsys_code='"+appsysCode+"'";
				getSession().createSQLQuery(sql).executeUpdate();
				app += appList.get(i);
			}
			
		}
		
	}

	/**
	 * 批量修改删除标示 
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(String[] osUsers, String[] appsysCodes,String[] serverIps,String[] userIds) throws SQLException {
		for (int i = 0; i < osUsers.length ; i++) {

			deleteById(osUsers[i], appsysCodes[i],serverIps[i], userIds[i]);
		}
		}
		
		/**
		 * 修改删除标示 
		 * @param osUser
		 * @param appsysCode
		 * @param serverIp
		 * @param userId
		 */
		public void deleteById(String osUser, String appsysCode,String serverIp,String userId)throws SQLException {
			getSession().createQuery(
							"update  ApposUserVo tb set tb.deleteFlag='1' where tb.osUser = :osUser and tb.appsysCode= :appsysCode and tb.serverIp= :serverIp and tb.userId= :userId")
					.setString("osUser", osUser)
					.setString("appsysCode", appsysCode)
					.setString("serverIp", serverIp)
					.setString("userId", userId)
					.executeUpdate();
			
		}
		
		/**
		 * 查找服务器ip
		 * 
		 * @param appsys_code
		 * @return
		 */
	@SuppressWarnings("unchecked")
		public List<Map<String, Object>> findServerIp(String appsys_code)throws SQLException  {

			if(!appsys_code.equals("COMMON")){
			StringBuilder hql = new StringBuilder();
			hql.append("select DISTINCT new map(");
			hql.append("tc.appsys_code as appsys_code,");
			hql.append("tc.server_ip as serverIp");
			
			hql.append(") from ToolBoxCmnInfoVo tc where tc.appsys_code=? ");
			Query query = getSession().createQuery(hql.toString()).setString(0, appsys_code);
			return query.list();
			}else{
			StringBuilder sql = new StringBuilder();
			sql.append("select distinct tc.server_ip as  \"serverIp\"  from CMN_SERVERS_INFO tc  ");
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			return query.list();
			}
		}
	
	/**
	 * 查找服务器ip
	 * 
	 * @param appsys_code
	 * @return
	 */
@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findOsUser(String appsys_code)throws SQLException  {

		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.os_user as  \"osUser\"  from cmn_app_os_user t where t.appsys_code=:appsys_code ");
		Query query = getSession().createSQLQuery(sql.toString()).setString("appsys_code", appsys_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
		
	}

	/**
	 * 查找用户ID
	 * 
	 * @param appsys_code
	
	 * @return
	 */
    @SuppressWarnings("unchecked")
	public List<Map<String, Object>> findUserId(String appsys_code)throws SQLException  {

		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct tc.user_id as  \"userId\" , u.user_id||'('|| u.user_name ||')' as \"name\"  from CMN_USER_APP tc , JEDA_USER u where  tc.user_id= u.user_id and  tc.appsys_code= ?  ");
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, appsys_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();

	} 
	/**
	 *根据应用编号获取应用名称
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getAppName(String appsys_code)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.systemname as \"appsys_name\"");
		sql.append(" from  v_cmn_app_info f where f.appsys_code= :appsys_code ");

		Query query = getSession().createSQLQuery(sql.toString()).setString("appsys_code", appsys_code)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	
	/**
	 *根据userIdh获取Idname
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getIdName(String user_id)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct  u.user_id||'('|| u.user_name ||')' as \"userId\"" );
		sql.append(" from  JEDA_USER u where u.user_id= :user_id ");
		

		Query query = getSession().createSQLQuery(sql.toString()).setString("user_id", user_id)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}

	

	public List<ServersInfoVo> getServerList(String filePath,Long logJnlNo) throws Exception  {
		
		File f = new File(filePath);
		InputStream in = null;
		StringBuilder stdErr = new StringBuilder();
		try {
			in = new FileInputStream(f);
			HSSFWorkbook workbook = new HSSFWorkbook(in);
			HSSFRow cells;
			HSSFCell cell;
			int rowstop=1;
			//获取第一个sheet
			HSSFSheet sheet = workbook.getSheetAt(0);
			int rowNumber = 1;
			List<String> primaryKeyCheckList = new ArrayList<String>();
			//exl的行数
			 // 确定工作表起始行号

			  for (int k = 0; k < 500; k++) {
			  cells = sheet.getRow(k);
			   
			   if(cells == null){
				   rowstop = k;
				    break;
			   }else{
				   cell = cells.getCell(0);
				   if (cell == null || cell.getStringCellValue() == null
				     ||"".equals(cell.getStringCellValue().trim())) {
				    rowstop = k;
				    break;
				   }
			   }
				    
			   
			  }
            int rows =rowstop;
			//int rows =	sheet.getPhysicalNumberOfRows();
            for(int i = 1; i <rows; i++) {
				
				//行号计数
				++rowNumber;
				
				/*if(sheet.getRow(i).getCell(0)==null){
					 stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append("主键有空值");
						stdErr.append("<br>");
						continue;
				 }*/
				 int cols=sheet.getRow(0).getPhysicalNumberOfCells();
				//行的长度Check
					if(cols != Constants.SERVERINFO_COLUMNS){
						stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.SERVERINFO_COLUMNS)}));
						stdErr.append("<br>");
						continue;
					}
					
					 String serverIp=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
			         String appsysCode=(null!= sheet.getRow(i).getCell(2)?sheet.getRow(i).getCell(2).toString():"");
			         CheckDataServerinfo(serverIp,appsysCode, stdErr, rowNumber,primaryKeyCheckList);
				}
           
          
            
            if(stdErr.length() > 0 ){
            	String logpath=ComUtil.writeLogFile(stdErr.toString(), 2);
            	
            	cmnDetailLogService.updateBydetailLog(logJnlNo, 1, logpath);
        		//更新脚步执行结束时间
        		cmnLogService.updateCMNLOGPaltForm(logJnlNo);
	        	throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
	        }
			
		    List<ServersInfoVo> list = new ArrayList<ServersInfoVo>();
		    ServersInfoVo vo=null;
			for(int i = 1; i <rows; i++) {
				
				 vo = new ServersInfoVo();
										 
				String serverIp=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
				String serverName=(null!= sheet.getRow(i).getCell(1)?sheet.getRow(i).getCell(1).toString():"");
				String appsysCode=(null!= sheet.getRow(i).getCell(2)?sheet.getRow(i).getCell(2).toString():"");
				String floatingIp=(null!= sheet.getRow(i).getCell(4)?sheet.getRow(i).getCell(4).toString():"");
				String osType=(null!= sheet.getRow(i).getCell(5)?sheet.getRow(i).getCell(5).toString():"");
				String mwType=(null!= sheet.getRow(i).getCell(6)?sheet.getRow(i).getCell(6).toString():"");
				String dbType=(null!= sheet.getRow(i).getCell(7)?sheet.getRow(i).getCell(7).toString():"");
				String environmentType=(null!= sheet.getRow(i).getCell(9)?sheet.getRow(i).getCell(9).toString():"");
				String machineroomPosition=(null!= sheet.getRow(i).getCell(10)?sheet.getRow(i).getCell(10).toString():"");
				String serverRole=(null!= sheet.getRow(i).getCell(11)?sheet.getRow(i).getCell(11).toString():"");
				
				String serverUse=(null!= sheet.getRow(i).getCell(12)?sheet.getRow(i).getCell(12).toString():"");
			
				vo.setServerIp(serverIp);
				vo.setServerName(serverName);
				vo.setAppsysCode(appsysCode);
				vo.setFloatingIp(floatingIp);
				vo.setServerRole(serverRole);
				vo.setServerUse(serverUse);
				vo.setMachineroomPosition(machineroomPosition);
				vo.setOsType(osType);
				vo.setMwType(mwType);
				vo.setDbType(dbType);
				vo.setCollectionState("成功");
				vo.setEnvironmentType(environmentType);
				vo.setBsaAgentFlag("0");
				vo.setDataType("H");
				vo.setDeleteFlag("0");
				
				list.add(vo);
					
				}
				
			return list;
		
		} catch (Exception e) {
			if(e instanceof NullPointerException) {
				throw new Exception(messages.getMessage("message.file.format.error"));
			}
			throw e;
		} finally {
			if(in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if(f.exists()) {
				f.delete();
			}
		}
		
	}
	
	/**
	 * 查询数据库中所有ServersInfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ServersInfoVo> queryAllServersInfo() throws SQLException{
		return getSession().createQuery("from ServersInfoVo t").list();
	}  
	
	
	/**
	 * 导入服务器


	 * @param ServerList 
	 * @param importServerList 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional
	public void importServers(List<ServersInfoVo> importServerList, List<ServersInfoVo> ServerList) {
        
		List<ServersInfoVo> serverinfoList = new ArrayList<ServersInfoVo>();
		for(int i=0;i<ServerList.size();i++){
			ServersInfoVo svo=null;
			boolean flag=true;
			//文件中的工具箱信息

			String fileappsysCode = ServerList.get(i).getAppsysCode().trim();
			String fileserverIp = ServerList.get(i).getServerIp().trim();
			Calendar cal = Calendar.getInstance();
			Long ss=cal.getTimeInMillis();
			Timestamp upTime =new Timestamp(ss);
				if(importServerList.size()==0){
					svo=new ServersInfoVo();
					svo.setServerIp(fileserverIp);
					svo.setAppsysCode(fileappsysCode);
					svo.setBsaAgentFlag("0");
					svo.setAttrFlag("0");
				}else{
					for(int j=0;j<importServerList.size();j++){
						//数据库中的工具箱信息
						String appsysCode  = importServerList.get(j).getAppsysCode().trim();
						String serverIp= importServerList.get(j).getServerIp().trim();
						String dataType=importServerList.get(j).getDataType();
						String deleteFlag=importServerList.get(j).getDeleteFlag();
							if(appsysCode.equals(fileappsysCode)&&serverIp.equals(fileserverIp)){
								
								if((deleteFlag.equals("0")&&dataType.equals("H"))||(deleteFlag.equals("1"))){
									svo=importServerList.get(j);
									importServerList.remove(j);
									j--;
								}else{
									
									flag=false;
								}
								
								break;
							}
						
							if(j==importServerList.size()-1){
								svo=new ServersInfoVo();
								svo.setServerIp(fileserverIp);
								svo.setAppsysCode(fileappsysCode);
								svo.setBsaAgentFlag("0");
								svo.setAttrFlag("0");
								
							}
						}
					}
				        
				if(flag){
				        svo.setDataType("H");
				        svo.setDeleteFlag("0");
				        svo.setUpdateTime(upTime);
						svo.setServerName(ServerList.get(i).getServerName());
						svo.setFloatingIp(ServerList.get(i).getFloatingIp());
						svo.setServerRole(ServerList.get(i).getServerRole());
						svo.setServerUse(ServerList.get(i).getServerUse());
						svo.setMachineroomPosition(ServerList.get(i).getMachineroomPosition());
						svo.setOsType(ServerList.get(i).getOsType());
						svo.setMwType(ServerList.get(i).getMwType());
						svo.setDbType(ServerList.get(i).getDbType());
						svo.setCollectionState(ServerList.get(i).getCollectionState());
						svo.setEnvironmentType(ServerList.get(i).getEnvironmentType());
						serverinfoList.add(svo);
				}
		}
		saveOrUpdateserveripinfo(serverinfoList);
	}
	/**
	 * 处理导入信息
	 * @return
	 */
	private void saveOrUpdateserveripinfo(List<ServersInfoVo> serverinfoList) {
		for(int i=0;i<serverinfoList.size();i++){
			saveOrUpdate2(serverinfoList.get(i));
		}
	}

	/**
	 * 查询出BSA AllServer中的所有服务器
	 * @return 
	 * @return
	 */
	public List<String> queryAllServers() throws AxisFault,SQLException, Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名


		CLITunnelServiceClient serversName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverName = serversName.executeCommandByParamList("Server","listServersInGroup",new String[] {"/所有服务器"});
		String servers = (String) serverName.get_return().getReturnValue();
		String[] server = servers.split("\n");
		List<String> saServerList = new ArrayList<String>();
		for (int j = 0; j < server.length; j++) {
			saServerList.add(server[j]);
		}
		return saServerList;
	}

	/**
	 *巡检自动关联服务器

	 * @return 
	 * @return
	 * @throws Exception 
	 * @throws AxisFault 
	 * @throws DataAccessException 
	 */
	@Transactional(rollbackFor=Exception.class)
	public String doSynServer(List<ServersInfoVo> serverList,
			List<String> saServerList) throws DataAccessException, AxisFault, Exception {
		// TODO Auto-generated method stub
		String crlf=System.getProperty("line.separator");
		StringBuilder workStatus = new StringBuilder();
		List<String> serverIpsList = null;
		//存放HP-UX服务器
		List<String> hpuxList = new ArrayList<String>();
		//存放LINUX服务器	
		List<String> linuxList = new ArrayList<String>();
		//存放WINDOWS服务器
		List<String> windowsList = new ArrayList<String>();
		//存放AIX服务器
		List<String> aixList = new ArrayList<String>();
		//存放DB服务器
		List<String> dbList = new ArrayList<String>();
		//存放MW服务器 
		List<String> mwList = new ArrayList<String>();
		//存放OS模板 
		Set<String> osTemplateSet = new HashSet<String>();
		//存放MW模板 
		Set<String> mwTemplateSet = new HashSet<String>();
		//存放DB模板  
		Set<String> dbTemplateSet = new HashSet<String>();
		for(int i=0;i<serverList.size();i++){
			serverIpsList=new ArrayList<String>();
			if(serverList.get(i).getOsType().equals("HP-UX")){
				hpuxList.add(serverList.get(i).getServerIp());
				osTemplateSet.add("OS"+"_"+serverList.get(i).getOsType());
			}
			if(serverList.get(i).getOsType().equals("LINUX")){
				linuxList.add(serverList.get(i).getServerIp());
				osTemplateSet.add("OS"+"_"+serverList.get(i).getOsType());
			}
			if(serverList.get(i).getOsType().equals("WINDOWS")){
				windowsList.add(serverList.get(i).getServerIp());
				osTemplateSet.add("OS"+"_"+serverList.get(i).getOsType());
			}
			if(serverList.get(i).getOsType().equals("AIX")){
				aixList.add(serverList.get(i).getServerIp());
				osTemplateSet.add("OS"+"_"+serverList.get(i).getOsType());
			}
			if(null != serverList.get(i).getDbType() && !"".equals(serverList.get(i).getDbType().toString())){
				dbList.add(serverList.get(i).getServerIp());
				dbTemplateSet.add("DB"+"_"+serverList.get(i).getOsType()+"_"+serverList.get(i).getDbType());
			}
			if(null != serverList.get(i).getMwType() && !"".equals(serverList.get(i).getMwType().toString())){
				mwList.add(serverList.get(i).getServerIp());
				mwTemplateSet.add("MW"+"_"+serverList.get(i).getOsType()+"_"+serverList.get(i).getMwType());
			}
			if(serverList.get(i).getDeleteFlag().equals("1")){
				//给服务器工作状态属性名称
				workStatus.append(serverList.get(i).getServerIp()).append(",").append("ATTR_WORK_STATUS").append(",").append("STOP").append(crlf);
			}else{
				//给服务器工作状态属性名称
				workStatus.append(serverList.get(i).getServerIp()).append(",").append("ATTR_WORK_STATUS").append(",").append("RUN").append(crlf);
			}
			//给服务器OS属性赋值
			if(serverList.get(i).getAttrFlag().equals("0")){
		/*		serverIpsList.add(serverList.get(i).getServerIp()+Constants.DATA_SEPARATOR+serverList.get(i).getAppsysCode());
				System.out.println(serverList.get(i).getServerIp()+new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()).toString());
				String success=doAgent(serverIpsList);
				
				if(success.length()==0){
				}*/
				workStatus.append(serverList.get(i).getServerIp()).append(",").append("ATTR_OS_TYPE").append(",").append(serverList.get(i).getOsType()).append(crlf);
				String sql="update cmn_servers_info t set t.attr_flag= '1' where t.server_ip='"+serverList.get(i).getServerIp()+"'";
				getSession().createSQLQuery(sql).executeUpdate();
			}
			//给服务器DB属性赋值
			if(serverList.get(i).getAttrFlag().equals("0") && null != serverList.get(i).getDbType() && !"".equals(serverList.get(i).getDbType())){
				workStatus.append(serverList.get(i).getServerIp()).append(",").append("ATTR_DB_TYPE").append(",").append(serverList.get(i).getDbType()).append(crlf);
			}
			//给服务器MW属性赋值
			if(serverList.get(i).getAttrFlag().equals("0") && null != serverList.get(i).getMwType() && !"".equals(serverList.get(i).getMwType())){
				workStatus.append(serverList.get(i).getServerIp()).append(",").append("ATTR_MW_TYPE").append(",").append(serverList.get(i).getMwType()).append(crlf);
			}
		}
		String username=securityUtils.getUser().getUsername() ;
		String filePath = System.getProperty("maop.root")+"ATTR_FLAG"+File.separator + username;
		String fileName = "ServerPropertyValues"+(new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString() +".csv";
		File file = new File(filePath);
		if(null != file.listFiles()){
			for (File tmpFile : file.listFiles()) {
				tmpFile.delete();
			}
		}
			file.mkdirs();
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filePath+ File.separator + fileName),"utf-8"));
		out.println(workStatus);
		out.flush();
		out.close();
		String Path="";
		if(ComUtil.isWindows){
			Path=filePath.replace(":", "").replace("\\", "/");
		}else{
			Path=filePath.substring(1);
		}
		//本机服务器ip
		String ip=messages.getMessage("systemServer.ip");
		//赋值脚本名称
		String scriptName = "bulkSetServerPropertyValues.nsh";
		//赋值脚本所在路径
		String scriptPath = "/SYSMANAGE/ServerManage";
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		//赋值作业所在路径
		String jobPath = "/SYSMANAGE/ServerManage";
		//作业名称
		String jobName = scriptName.substring(0,scriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		//给赋值作业第一个参数(服务器文件存在的路径+nsh脚本名称)
		String FilePath="//"+ip+"/"+Path;
		//创建赋值脚本的作业
		createToolJob(jobPath,jobName,scriptPath,scriptName,bsaServer);
		//给作业附参数
		addToolJobParam(jobPath,jobName,FilePath,fileName,bsaServer);
		//获取作业的DbKey
		String nshJobDbkey=(String) getNshJobDbKey(jobPath, jobName);
		//执行作业
		exceNshJob(nshJobDbkey);
		//删除作业
		deleteJob(jobPath, jobName);
		//获取Db的模板
		Set<String> dbTemplate=new HashSet<String>();
		Set<String> hpuxTemplate=new HashSet<String>();
		Set<String> windowsTemplate=new HashSet<String>();
		Set<String> linuxTemplate=new HashSet<String>();
		Set<String> aixTemplate=new HashSet<String>();
		Set<String> mwTemplate=new HashSet<String>();
		if(dbTemplateSet.size()>0){
			String templateGroup="DB";
			String templates=(String) getTemplate(templateGroup);
			String[] dbTemplates = templates.split("\n");
			for(int i=0;i<dbTemplates.length;i++){
				dbTemplate.add(dbTemplates[i]);
			}
		}
		//获取OS的模板

		if(osTemplateSet.size()>0){
			String templateGroup="OS";
			String templates=(String) getTemplate(templateGroup);
			String[] dbTemplates = templates.split("\n");
			for(int i=0;i<dbTemplates.length;i++){
				for(String templateName : osTemplateSet){
					if(dbTemplates[i].substring(0,dbTemplates[i].lastIndexOf("_")).equals(templateName) && dbTemplates[i].substring(dbTemplates[i].indexOf("_")+1,dbTemplates[i].lastIndexOf("_")).equals("HP-UX")){
						hpuxTemplate.add(dbTemplates[i]);
					}
					if(dbTemplates[i].substring(0,dbTemplates[i].lastIndexOf("_")).equals(templateName) && dbTemplates[i].substring(dbTemplates[i].indexOf("_")+1,dbTemplates[i].lastIndexOf("_")).equals("LINUX")){
						linuxTemplate.add(dbTemplates[i]);
					}																												
					if(dbTemplates[i].substring(0,dbTemplates[i].lastIndexOf("_")).equals(templateName) && dbTemplates[i].substring(dbTemplates[i].indexOf("_")+1,dbTemplates[i].lastIndexOf("_")).equals("WINDOWS")){
						windowsTemplate.add(dbTemplates[i]);
					}
					if(dbTemplates[i].substring(0,dbTemplates[i].lastIndexOf("_")).equals(templateName) && dbTemplates[i].substring(dbTemplates[i].indexOf("_")+1,dbTemplates[i].lastIndexOf("_")).equals("AIX")){
						aixTemplate.add(dbTemplates[i]);
					}
				}
			}
		}
		//获取MW的模板

		if(mwTemplateSet.size()>0){
			String templateGroup="MW";
			String templates=(String) getTemplate(templateGroup);
			String[] dbTemplates = templates.split("\n");
			for(int i=0;i<dbTemplates.length;i++){
				mwTemplate.add(dbTemplates[i]);
			}
		}
		//创建AIX模板作业
		String templateJobName = null;
		if(aixTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:aixTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				templateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,templateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(aixList,templateJobName);
				//执行自动发现作业
				exeDiscoverJob(templateJobName);
				//删除作业
				deleteDiscoverJob(templateJobName);
		}else if(aixTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:aixTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/OS";
				templateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,templateJobName);
				aixTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:aixTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				addMoreTemplate(templateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(aixList,templateJobName);
				//执行自动发现作业
				exeDiscoverJob(templateJobName);
				//删除作业
				deleteDiscoverJob(templateJobName);
		}
		
		//创建HP-UX模板作业
		String hpTemplateJobName = null;
		if(hpuxTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:hpuxTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				hpTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,hpTemplateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(hpuxList,hpTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(hpTemplateJobName);
				//删除作业
				deleteDiscoverJob(hpTemplateJobName);
		}else if(hpuxTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:hpuxTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/OS";
				hpTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,hpTemplateJobName);
				hpuxTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:hpuxTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				addMoreTemplate(hpTemplateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(hpuxList,hpTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(hpTemplateJobName);
				//删除作业
				deleteDiscoverJob(hpTemplateJobName);
		}
		//创建WINDOWS模板作业
		String windowsTemplateJobName = null;
		if(windowsTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:windowsTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				windowsTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,windowsTemplateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(windowsList,windowsTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(windowsTemplateJobName);
				//删除作业
				deleteDiscoverJob(windowsTemplateJobName);
		}else if(windowsTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:windowsTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/OS";
				windowsTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,windowsTemplateJobName);
				windowsTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:windowsTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				addMoreTemplate(windowsTemplateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(windowsList,windowsTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(windowsTemplateJobName);
				//删除作业
				deleteDiscoverJob(windowsTemplateJobName);
		}
		//创建LINUX模板作业
		String linuxTemplateJobName = null;
		if(linuxTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:linuxTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				linuxTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,linuxTemplateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(linuxList,linuxTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(linuxTemplateJobName);
				//删除作业
				deleteDiscoverJob(linuxTemplateJobName);
		}else if(linuxTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:linuxTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/OS";
				linuxTemplateJobName=templateName.substring(0,templateName.lastIndexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,linuxTemplateJobName);
				linuxTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:linuxTemplate){
				String templateGroup="/COMMON_CHECK/OS";
				addMoreTemplate(linuxTemplateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(linuxList,linuxTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(linuxTemplateJobName);
				//删除作业
				deleteDiscoverJob(linuxTemplateJobName);
		}
		//创建DB模板作业
		String dbTemplateJobName = null;
		if(dbTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:dbTemplate){
				String templateGroup="/COMMON_CHECK/DB";
				dbTemplateJobName=templateName.substring(0,templateName.indexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,dbTemplateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(dbList,dbTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(dbTemplateJobName);
				//删除作业
				deleteDiscoverJob(dbTemplateJobName);
		}else if(dbTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:dbTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/DB";
				dbTemplateJobName=templateName.substring(0,templateName.indexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,dbTemplateJobName);
				dbTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:dbTemplate){
				String templateGroup="/COMMON_CHECK/DB";
				addMoreTemplate(dbTemplateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(dbList,dbTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(dbTemplateJobName);
				//删除作业
				deleteDiscoverJob(dbTemplateJobName);
		}
		//创建MW模板作业
		String mwTemplateJobName = null;
		if(mwTemplate.size()==1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			for(String templateName:mwTemplate){
				String templateGroup="/COMMON_CHECK/MW";
				mwTemplateJobName=templateName.substring(0,templateName.indexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,mwTemplateJobName);
			}
				//像作业中添加目标服务器

				addTargetServers(mwList,mwTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(mwTemplateJobName);
				//删除作业
				deleteDiscoverJob(mwTemplateJobName);
		}else if(mwTemplate.size()>1){
			Date date = new Date();
			SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
			int i=0;
			for(String templateName:mwTemplate){
				if(i==0){
				i++;
				String templateGroup="/COMMON_CHECK/MW";
				mwTemplateJobName=templateName.substring(0,templateName.indexOf("_")).concat("_").concat(matter.format(date));
				createDiscoverJob(templateName,templateGroup,mwTemplateJobName);
				mwTemplate.remove(templateName);
				}
				break;
			}
			for(String templateName:mwTemplate){
				String templateGroup="/COMMON_CHECK/MW";
				addMoreTemplate(mwTemplateJobName,templateGroup,templateName);
			}
				//像作业中添加目标服务器

				addTargetServers(mwList,mwTemplateJobName);
				//执行自动发现作业
				exeDiscoverJob(mwTemplateJobName);
				//删除作业
				deleteDiscoverJob(mwTemplateJobName);
		}
		return null;
	}
	/**
	 * 删除自动发现作业
	 * @throws NoSuchMessageException,Exception 
	 * @throws AxisFault 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void deleteDiscoverJob(String jobName) throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("ComponentDiscoveryJob","deleteJobByGroupAndName",new String[] {"/COMMON_CHECK/DISCOVERY",jobName});
	}
	/**
	 * 执行自动发现作业
	 * @throws NoSuchMessageException,Exception 
	 * @throws AxisFault 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void exeDiscoverJob(String templateJobName) throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("ComponentDiscoveryJob","getDBKeyByGroupAndName",new String[] {"/COMMON_CHECK/DISCOVERY",""+templateJobName+""});
		String jobDbkey = (String) jobParentGroupNames3.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("ComponentDiscoveryJob","executeJobAndWait",new String[] {jobDbkey});
	}
	/**
	 * 添加目标服务器

	 * @throws NoSuchMessageException,Exception 
	 * @throws AxisFault 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void addTargetServers(List<String> aixList,String templateJobName) throws AxisFault, NoSuchMessageException,Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		
		
		for(int i=0;i<aixList.size();i++){
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("ComponentDiscoveryJob","getDBKeyByGroupAndName",new String[] {"/COMMON_CHECK/DISCOVERY",""+templateJobName+""});
		String jobDbkey = (String) jobParentGroupNames3.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("Job","addTargetServer",new String[] {jobDbkey,aixList.get(i)});
		}
	}

	/**
	 * 添加模板
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void addMoreTemplate(String templateJobName,String templateGroup, String templateName) throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//临时作业路径
		String tempJobPath = "/SYSMANAGE/CHECKMANAGE";
		//临时作业名称
		Date date = new Date();
		SimpleDateFormat matter = new SimpleDateFormat("yyyyMMddhhmmss");
		String tempJobName = "ComponentDiscoveryJob";
		tempJobName=tempJobName.concat("_").concat(matter.format(date));
		//新建临时脚本作业
		CLITunnelServiceClient cliClientCreatExportJob = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseCreatExportJob = cliClientCreatExportJob.executeCommandByParamList("NSHScriptJob", "createNSHScriptJob", 
				new String[]{tempJobPath,tempJobName,"","/SYSMANAGE/DiscoveryJob","DiscoveryJobAddTemplate.nsh","4"});
		cliClientCreatExportJob.ResponseCheck4ExecuteCommand(cliResponseCreatExportJob);
		String DBkeyCreatExportJob=(String) cliResponseCreatExportJob.get_return().getReturnValue();
		
		CLITunnelServiceClient cliClientExportLinkServer = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExportLinkServer = cliClientExportLinkServer.executeCommandByParamList("Job", "addTargetServer", 
				new String[]{DBkeyCreatExportJob,messages.getMessage("bsa.ipAddress")});
		cliClientExportLinkServer.ResponseCheck4ExecuteCommand(cliResponseExportLinkServer);
		 
		CLITunnelServiceClient cliClientClean = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseClean = cliClientClean.executeCommandByParamList("NSHScriptJob", "clearNSHScriptParameterValuesByGroupAndName", 
				new String[]{tempJobPath,tempJobName});
		cliClientClean.ResponseCheck4ExecuteCommand(cliResponseClean);
		//设置参数
		CLITunnelServiceClient cliClientAdd2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd2 = cliClientAdd2.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{tempJobPath,tempJobName,"0","/COMMON_CHECK/DISCOVERY"});
		cliClientAdd2.ResponseCheck4ExecuteCommand(cliResponseAdd2);
		
		CLITunnelServiceClient cliClientAdd3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd3 = cliClientAdd3.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{tempJobPath,tempJobName,"1",templateJobName});
		cliClientAdd3.ResponseCheck4ExecuteCommand(cliResponseAdd3);
		
		CLITunnelServiceClient cliClientAdd4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd4 = cliClientAdd4.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{tempJobPath,tempJobName,"2",templateGroup});
		cliClientAdd4.ResponseCheck4ExecuteCommand(cliResponseAdd4);
		
		CLITunnelServiceClient cliClientAdd5 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseAdd5 = cliClientAdd5.executeCommandByParamList("NSHScriptJob", "addNSHScriptParameterValueByGroupAndName", 
				new String[]{tempJobPath,tempJobName,"3",templateName});
		cliClientAdd5.ResponseCheck4ExecuteCommand(cliResponseAdd5);
		//执行作业
		CLITunnelServiceClient cliClientExport = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse cliResponseExport = cliClientExport.executeCommandByParamList("NSHScriptJob", "executeJobGetJobResultKey", 
				new String[]{DBkeyCreatExportJob});
		cliClientExport.ResponseCheck4ExecuteCommand(cliResponseExport);
		//删除作业
		CLITunnelServiceClient cliClientExportJobDelete = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		cliClientExportJobDelete.executeCommandByParamList("NSHScriptJob", "deleteJobByGroupAndName", new String[]{tempJobPath,tempJobName});
	}



	/**
	 * 创建临时发现作业
	 * @return 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private String createDiscoverJob(String templateName, String templateGroup,String templateJobName) throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("JobGroup","groupNameToId",new String[] {"/COMMON_CHECK/DISCOVERY"});
		String jobGroupId = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("Template","getDBKeyByGroupAndName",new String[] {templateGroup,templateName});
		String templateDbkey = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("ComponentDiscoveryJob","createComponentDiscoveryJob",new String[] {""+templateJobName+"",""+jobGroupId+"",""+templateDbkey+"",""+messages.getMessage("bsa.ipAddress")+""});
		
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("ComponentDiscoveryJob","getDBKeyByGroupAndName",new String[] {"/COMMON_CHECK/DISCOVERY",""+templateJobName+""});
		String jobDbkey = (String) jobParentGroupNames3.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName4.executeCommandByParamList("Job","clearTargetServers",new String[] {""+jobDbkey+""});
		String value = (String) jobParentGroupNames4.get_return().getReturnValue();
		return jobDbkey;
	}



	/**
	 * 创建TOOLS作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createToolJob(String jobPath,String jobName,String scriptPath,String scriptName,String bsaServer) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名


		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {""+jobPath+"",""+jobName+""," ",""+scriptPath+"",""+scriptName+"",""+bsaServer+"","10"});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	
	/**
	 * 创建TOOLS作业附参数


	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam(String jobPath,String jobName,String FilePath,String fileName,String bsaServer) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {""+jobPath+"",""+jobName+""});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {""+jobPath+"",""+jobName+"","0",""+FilePath+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {""+jobPath+"",""+jobName+"","1",""+fileName+""});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {""+jobPath+"",""+jobName+"","2",""+bsaServer+""});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		return DbKey;
	}
	
	/**
	 * 取NshJob的DbKey
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getNshJobDbKey(String jobPath,String jobName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名


		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {""+jobPath+"",""+jobName+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 执行NshJob
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object exceNshJob(String nshJobDbkey) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名


		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] {""+nshJobDbkey+""});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteJob(String jobPath,String jobName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名


		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {""+jobPath+"",""+jobName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 获取模板
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getTemplate(String templateGroup) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		CLITunnelServiceClient groupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse templateGroupName = groupName.executeCommandByParamList("TemplateGroup","listChildGroupsInGroup",new String[] {"/COMMON_CHECK"});
		String value = (String) templateGroupName.get_return().getReturnValue();
		
		CLITunnelServiceClient groupIds = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse groupId = groupIds.executeCommandByParamList("TemplateGroup","groupNameToId",new String[] {"/COMMON_CHECK/"+templateGroup+""});
		String templateGroupId = (String) groupId.get_return().getReturnValue();
		
		CLITunnelServiceClient templateNames = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse templateName = templateNames.executeCommandByParamList("Template","listAllByGroup",new String[] {""+templateGroupId+""});
		String templates = (String) templateName.get_return().getReturnValue();
		
		return templates;
	}
	
	public void saveServer(String appsysCode, String serverIp, String record_id) throws SQLException {
		OccasServersInfoVo vo=new OccasServersInfoVo();
		vo.setRecord_id(record_id);
		vo.setAppsysCode(appsysCode);
		vo.setServerIp(serverIp);
		getSession().save(vo);
	}

	public void saveServers(List<String> list, String descList) throws SQLException {
		// TODO Auto-generated method stub
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String record_id ="AGENT_SETUP_"+created_time+"_"+applicationProcessService.findProcessSeq();
		for(String record : list){
			saveServer(record.split(Constants.SPLIT_SEPARATEOR)[1], record.split(Constants.SPLIT_SEPARATEOR)[0],record_id);
		}
		saveApplicationProcessRecord(descList,record_id);
	}
	
	private void saveApplicationProcessRecord(String descList, String record_id) throws SQLException {
		String desc=descList;
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String created_time2 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		ApplicationProcessRecordsVo vo1=new ApplicationProcessRecordsVo();
		String username = securityUtils.getUser().getUsername();
		vo1.setRecord_id(record_id);
		vo1.setSubject_info("2");
		vo1.setApplication_user(username);
		vo1.setCurrent_state("1");
		vo1.setApplication_time(Timestamp.valueOf(created_time2.concat(".000").toString()));
		vo1.setApplication_reasons(desc.replaceAll("\"", ""));
		String process_description =created_time2+"<br>"+applicationProcessService.findbyUserId()+": 服务器代理检测流程提交;";
		vo1.setProcess_description(process_description);
		vo1.setDelete_flag("0");
		getSession().save(vo1);
	}
	
	/**
	 * 定时自动同步用户权限信息
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException 
	 * @throws SQLException 
	 */
	public void autoSynOsUser() throws UnsupportedEncodingException, FileNotFoundException, IOException, SQLException{
		//获取数据字典中操作用户权限自动同步开关数值
		String onOff = "";
		onOff = itemService.getSubItemValueByItemIdAndSubItemName("ONOFF_SWITCH","autoSyn_osUserInfo");		
		if(onOff.equals("on")){ //开启自动同步
			StringBuilder errNum = new StringBuilder();
			StringBuilder Num = new StringBuilder();
			StringBuilder Path = new StringBuilder();
			StringBuilder CheckError = new StringBuilder();
		    //开始插入日志
		    Long logJnlNo = cmnLogService.logPaltformForAutoSyn(2,"admin");
			//详细日志开始
			cmnDetailLogService.saveBydetailLog(logJnlNo,2,"1");
			List<ApposUserVo> inputSumpList = new ArrayList<ApposUserVo>();
			//读取文件信息
			inputSumpList = readApposUserFromFile(logJnlNo,errNum,Num,Path,CheckError);
			//数据库中查询的信息
			List<ApposUserVo> ApposUserList = queryApposUser();
			//执行保存和更新
			saveOrUpdateSump(inputSumpList,ApposUserList);
			//执行保存和更新用户系统表
			saveOrUpdateUserApp(inputSumpList,logJnlNo,Path,CheckError);
			//日志结束更新数据
			cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
			cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
		}
	}
	
	/**
	 * 定时自动同步服务器信息
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException 
	 * @throws SQLException 
	 */
	public void autoSynServerInfo() throws UnsupportedEncodingException, FileNotFoundException, IOException, SQLException{
		//获取数据字典中服务器信息自动同步开关数值
		String onOff = "";
		onOff = itemService.getSubItemValueByItemIdAndSubItemName("ONOFF_SWITCH","autoSyn_serverInfo");		
		if(onOff.equals("on")){ //开启自动同步
			//开始插入日志
		    Long logJnlNo =cmnLogService.logPaltformForAutoSyn(1,"admin");
			//详细日志开始
		   	cmnDetailLogService.saveBydetailLog(logJnlNo,1,"1");
			List<ServersInfoVo> inputFileList = new ArrayList<ServersInfoVo>();
			StringBuilder errNum = new StringBuilder();
			StringBuilder Num = new StringBuilder();
			StringBuilder Path = new StringBuilder();
			//读取文件信息
			inputFileList = readServersInfosFromFile(logJnlNo,errNum,Num,Path);
			//数据库中查询的信息
			List<ServersInfoVo> serverList = queryServerInfo();
			//执行保存和更新
			saveOrUpdateAdmin(inputFileList,serverList);
			//日志结束更新数据
			cmnDetailLogService.updateBydetailLogSucess(logJnlNo, 1);
			cmnLogService.updateCMNLOGPaltFormSuccess(logJnlNo);
		}
	}
}
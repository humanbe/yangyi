	package com.nantian.check.service;

	import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.dply.service.CmnDetailLogService;
import com.nantian.dply.service.CmnLogService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.rept.vo.ServerConfVo;

	/**
	 * 应用巡检作业设计service
	 * @author linaWang
	 *
	 */
	@Service
	@Repository
	@Transactional
	public class AppCheckDesignService {

		/** 日志输出 */
		final Logger logger = LoggerFactory.getLogger(AppCheckDesignService.class);
		
		@Autowired
		private SessionFactory sessionFactoryMaopRpt;

		public Session getSession() {
			return sessionFactoryMaopRpt.getCurrentSession();
		}
		@Autowired
	    private AppInfoService appInfoService;
		@Autowired
		private SecurityUtils securityUtils; 
		@Autowired
		private CmnLogService cmnLogService;
		@Autowired
		private CmnDetailLogService cmnDetailLogService;
		/** 国际化资源 */
		@Autowired
		private MessageSourceAccessor messages;
		
		/** 查询字段及类型 */
		public Map<String, String> fields = new HashMap<String, String>();
		public String frontFlag = "一线";
		//BSAdepot目录下巡检主目录

		public String checkPath="CHECK";
		//BSA存放nsh脚本的文件夹
		public String nshPath="NSHELLS";
		//BSA存放sh脚本的文件夹
		public String shPath = "SCRIPTS";
		//nsh文件的Dbkey类型
		public String nshFileType = "NSHSCRIPT";
		//.sh文件的Dbkey类型
		public String fileType="DEPOT_FILE_OBJECT";
		
		/**
		 * 构造方法

		 */
		public AppCheckDesignService() {
			
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
		public List<Map <String ,String >> queryServerConfList(String aplCode,  
				HttpServletRequest request) {

			StringBuilder sql = new StringBuilder();
			sql.append("select  distinct")
				.append("	t.SRV_CODE as \"srvCode\", ")
				.append("	  t.LOAD_MODE as \"loadMode\", ")
				.append("	v.appsys_code as \"appsys_code\", ")
				.append("	v.server_ip as \"server_ip\", ")
				.append("	v.server_name as \"server_name\", ")
				.append("	v.server_group as \"server_group\", ")
				.append("	v.FLOATING_IP as \"floating_ip\", ")
				.append("	t.APL_CODE as \"aplCode\", ")
				.append("	t.SER_CLASS as \"serClass\", ")
				.append("	t.SER_NAME as \"serName\", ")
				.append("	t.MEM_CONF as \"memConf\", ")
				.append("	t.CPU_CONF as \"cpuConf\", ")
				.append("	t.DISK_CONF as \"diskConf\", ")
				.append("	t.IP_ADDRESS as \"ipAddress\", ")
				.append("	t.FLOAT_ADDRESS as \"floatAddress\", ")
				.append("	 t.AUTO_CAPTURE   as \"autoCapture\"  ")
				.append("from  v_cmn_app_server v left join server_conf  t on v.SERVER_GROUP=t.SER_CLASS and v.SERVER_IP=t.IP_ADDRESS where 1=1 ")
			    .append(" and v.APPSYS_CODE= '"+aplCode+"'");
			 
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			
			return query.list();
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
		public List<Map <String ,String >> queryServerConfListDel(String aplCode,  
				HttpServletRequest request) {

			StringBuilder sql = new StringBuilder();
		sql.append("  select distinct     ")
		.append("	t.SRV_CODE as \"srvCode\", ")
		.append("	  t.LOAD_MODE as \"loadMode\", ")
		.append("	t.APL_CODE as \"aplCode\", ")
		.append("	t.SER_CLASS as \"serClass\", ")
		.append("	t.SER_NAME as \"serName\", ")
		.append("	t.MEM_CONF as \"memConf\", ")
		.append("	t.CPU_CONF as \"cpuConf\", ")
		.append("	t.DISK_CONF as \"diskConf\", ")
		.append("	t.IP_ADDRESS as \"ipAddress\", ")
		.append("	t.FLOAT_ADDRESS as \"floatAddress\", ")
		.append("	 t.AUTO_CAPTURE   as \"autoCapture\"  ")
		.append("from server_conf t       ")
		.append("where   t.apl_code= '"+aplCode+"'  ")
		.append("and  t.ip_address not in     ")
		.append("  (select DISTINCT v.server_ip    ")
		.append("  from v_cmn_app_server v   ")
		.append("  where v.APPSYS_CODE='"+aplCode+"' )  ");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		return query.list();
		}
		
		public List<Map<String, String>> queryServerGroup(String aplCode) {
			
			 StringBuilder sql = new StringBuilder();
			  sql.append("select  distinct SERVER_GROUP as \"serverGroup\" from V_CMN_APP_SERVER  t");
			   sql.append("  where t.APPSYS_CODE ='"+aplCode+"'");
			    Query query=getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);  
			return query.list();
		}
		
		/**
		 * 更新属性类实例的参数值


		 * @param serverValues 属性值键值对
		 * @throws Exception
		 */
		@SuppressWarnings("unchecked")
		@Transactional(value = "maoprpt" )
		public void saveServer(String serverValues) throws Exception {
			JSONArray array = JSONArray.fromObject(serverValues);
			List<Map<String, Object>> list = (List<Map<String, Object>>) JSONArray.toCollection(array, Map.class);
			
			for(Map<String, Object> map1 : list){
				Boolean b=(Boolean)map1.get("_is_leaf");
				if(("是").equals(map1.get("checkflag").toString())&&b){
					ServerConfVo vo = new ServerConfVo();
					
					vo.setAplCode(map1.get("appsys_code").toString());
					
					vo.setIpAddress(map1.get("server_ip").toString());
					vo.setSrvCode(map1.get("server_name").toString());
					vo.setLoadMode(map1.get("loadMode").toString());
					vo.setSerName(map1.get("serName").toString());
					vo.setAutoCapture(map1.get("autoCapture").toString());
					vo.setCpuConf(map1.get("cpuConf").toString());
					vo.setDiskConf(map1.get("diskConf").toString());
					vo.setFloatAddress(map1.get("floatAddress").toString());
					vo.setMemConf(map1.get("memConf").toString());
					vo.setSerClass(map1.get("serClass").toString());
					getSession().saveOrUpdate(vo);
				}else  if(("否").equals(map1.get("checkflag").toString())&&b){
					ServerConfVo vo = new ServerConfVo();
					
					vo.setAplCode(map1.get("appsys_code").toString());
					
					vo.setIpAddress(map1.get("server_ip").toString());
					vo.setSrvCode(map1.get("server_name").toString());
					vo.setLoadMode(map1.get("loadMode").toString());
					vo.setSerName(map1.get("serName").toString());
					vo.setAutoCapture(map1.get("autoCapture").toString());
					vo.setCpuConf(map1.get("cpuConf").toString());
					vo.setDiskConf(map1.get("diskConf").toString());
					vo.setFloatAddress(map1.get("floatAddress").toString());
					vo.setMemConf(map1.get("memConf").toString());
					vo.setSerClass(map1.get("serClass").toString());
					getSession().delete(vo);
				}
			}
		}
		
		/**
		 * 查询weblogic数据导入配置信息列表
		 * @param aplCode
		 * @param request
		 * @return
		 */
		@SuppressWarnings("unchecked")
		@Transactional(value = "maoprpt", readOnly = true)
		public List<Map<String, Object>> queryWeblogicConfList(String  aplCode,
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
				.append("from WeblogicConfVo t where 1=1 ")
			    .append(" and  aplCode='"+aplCode+"' ");
			
			sql.append(" order by t.ipAddress");
			
			Query query = getSession().createQuery(sql.toString());
			return query.list();
		}

		/**
		 * 获取服务器信息

		 */
		@Transactional(value = "maoprpt", readOnly = true)
		@SuppressWarnings({ "unchecked" })
		public List<Map<String, Object>> getServerIps(String aplCode )throws SQLException {
			StringBuilder sql = new StringBuilder();
			sql.append("  select distinct     ")
			
			.append("	t.IP_ADDRESS as \"serverip\"")
			.append("from server_conf t    ")
			.append("where   t.apl_code= '"+aplCode+"'  ") 
			.append("and  t.ip_address   in     ")
			.append("  (select DISTINCT v.server_ip    ")
			.append("  from v_cmn_app_server v   ")
			.append("  where v.APPSYS_CODE='"+aplCode+"' )  ");
			
			Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			
			return query.list();
		}
}

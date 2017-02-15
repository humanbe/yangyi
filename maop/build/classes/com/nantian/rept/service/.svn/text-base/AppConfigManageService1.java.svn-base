package com.nantian.rept.service;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.DateFunction;
import com.nantian.component.ftp.ComponentFtp;
import com.nantian.component.ftp.ComponentFtpConnection;
import com.nantian.jeda.FieldType;

@Service
@Repository
@Transactional
public class AppConfigManageService1 {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	public AppConfigManageService1(){
		fields.put("sysId", FieldType.STRING);
		fields.put("sysName", FieldType.STRING);
		fields.put("operationsManager", FieldType.STRING);
		fields.put("sysA", FieldType.STRING);
		fields.put("sysB", FieldType.STRING);
		fields.put("appA", FieldType.STRING);
		fields.put("appB", FieldType.STRING);
		fields.put("projectLeader", FieldType.STRING);
		fields.put("sysStatus", FieldType.STRING);
		fields.put("department", FieldType.STRING);
		fields.put("serviceTime", FieldType.STRING);
		fields.put("disasterRecoverPriority", FieldType.STRING);
		fields.put("securityRank", FieldType.STRING);
		fields.put("groupName", FieldType.STRING);
		fields.put("outSourcingFlag", FieldType.STRING);
		fields.put("coreRank", FieldType.STRING);
		fields.put("importantRank", FieldType.STRING);
		fields.put("hingeRank", FieldType.STRING);
		fields.put("appType", FieldType.STRING);
		fields.put("appOutline", FieldType.STRING);
	}
	
	/**
	 * 查询应用系统及管理员分配信息.
	 * @param start 起始记录数	 * @param limit 限制记录数	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @return 应用系统及管理员分配信息映射集合
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> queryAppSystemInfo(int start, int limit, String sort, String dir, Map<String, Object> params, HttpServletRequest request){
		StringBuilder sql = new StringBuilder();
		sql.append("select * ")
			.append("from (select t.id as \"sysId\", ")
            .append("   				t.sysname as \"sysName\", ")
            .append("   				t.manager as \"operationsManager\", ")
            .append("   				t.sysa as \"sysA\", ")
            .append("   				t.sysb as \"sysB\", ")
            .append("   				t.appa as \"appA\", ")
            .append("   				t.appb as \"appB\", ")
            .append("   				t.develop as \"projectLeader\", ")
            .append("   				t.flag as \"sysStatus\", ")
            .append("   				t.depart as \"department\", ")
            .append("   				t.fuwu as \"serviceTime\", ")
            .append("   				t.anquan \"disasterRecoverPriority\", ")
            .append("   				t.jibie as \"securityRank\", ")
            .append("					t.app_outline as \"appOutline\", ")
            .append("					case when t.app_type='1' then '平稳形' when  t.app_type='2' then  '震荡形' end as \"appType\", ")
            .append("   				(select groupname from member where username = t.appa) as \"groupName\", ")
            .append("   				(select '是' from member where username = t.appa) as \"takeOverFlag\", ")
            .append("   				(select '是' ")
            .append("      					from app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.hexin_jibie is not null) as \"coreRank\", ")
            .append("   				(select '是' ")
            .append("      					from app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.zhongyao_jibie is not null) as \"importantRank\", ")
            .append("   				(select '是' ")
            .append("      					from app_attribute a ")
            .append("     				 where substr(t.id,5) = a.id ")
            .append("       				and a.guanjian_jibie is not null) as \"hingeRank\", ")
            .append("       			(select '是' from member where username = t.appa and flag = 2) as \"outSourcingFlag\", ")
            .append(" 					(select to_char(to_date(co.EVALUATE_MONTH,'yyyyMM'),'yyyyMM') from ( ")
            .append("                      select c.*,row_number() over(partition by c.APL_CODE order by c.EVALUATE_MONTH desc) rn from cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"evaluateMonth\", ")
            .append(" 					(select co.EVALUATE_RESULT from ( ")
            .append("                      select c.*,row_number() over(partition by c.APL_CODE order by c.EVALUATE_MONTH desc) rn from cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"evaluateResult\", ")
            .append(" 					(select co.LEVEL_CAUSE_DESC from ( ")
            .append("                      select c.*,row_number() over(partition by c.APL_CODE order by c.EVALUATE_MONTH desc) rn from cap_risk_grade c) co ")
            .append("					    where rn = 1 and co.apl_code = t.id)  as \"levelCauseDesc\" ")
            .append(" 		from LIEBIAO t) s")
            .append(" where 1=1 ");
		
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and \"" + key + "\" like :" + key);
				} else {
					sql.append(" and \"" + key + "\" = :" + key);
				}
			}
		}
		
		sql.append(" order by \"" + sort + "\" " + dir);
		
		Query query = getSession().createSQLQuery(sql.toString())
												.addScalar("sysId", StringType.INSTANCE)
												.addScalar("sysName", StringType.INSTANCE)
												.addScalar("operationsManager", StringType.INSTANCE)
												.addScalar("sysA", StringType.INSTANCE)
												.addScalar("sysB", StringType.INSTANCE)
												.addScalar("appA", StringType.INSTANCE)
												.addScalar("appB", StringType.INSTANCE)
												.addScalar("projectLeader", StringType.INSTANCE)
												.addScalar("sysStatus", StringType.INSTANCE)
												.addScalar("department", StringType.INSTANCE)
												.addScalar("serviceTime", StringType.INSTANCE)
												.addScalar("disasterRecoverPriority", StringType.INSTANCE)
												.addScalar("securityRank", StringType.INSTANCE)
												.addScalar("appOutline", StringType.INSTANCE)
												.addScalar("appType", StringType.INSTANCE)
												.addScalar("groupName", StringType.INSTANCE)
												.addScalar("takeOverFlag", StringType.INSTANCE)
												.addScalar("coreRank", StringType.INSTANCE)
												.addScalar("importantRank", StringType.INSTANCE)
												.addScalar("hingeRank", StringType.INSTANCE)
												.addScalar("outSourcingFlag", StringType.INSTANCE)
												.addScalar("evaluateMonth", StringType.INSTANCE)
												.addScalar("evaluateResult", StringType.INSTANCE)
												.addScalar("levelCauseDesc", StringType.INSTANCE)
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		//保存为导出或统计总条数使用
		request.getSession().setAttribute("appSystemInfos4Export", query.list());
	
		return query.setMaxResults(limit).setFirstResult(start).list();
	}
	
	/**
	 * 查询所有的系统.
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> queryAppSystemInfos(){
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(t.id, 5) as id, t.sysname, t.manager, ")
	        .append("	t.sysa, t.sysb, t.appa, ")
	        .append("	t.appb, t.develop, t.flag, ")
	        .append("	t.depart, t.fuwu, t.anquan, ")
	        .append("	t.jibie, t.app_outline, t.app_type, ")
	        .append("	(select groupname from member where username = t.appa) as groupname, ")
	        .append("	(select a.hexin_jibie ")
	        .append("		from app_attribute a ")
	        .append("		where substr(t.id,5) = a.id ")
	        .append("      		and a.hexin_jibie is not null) as hexin_jibie, ")
	        .append("	(select a.zhongyao_jibie ")
	        .append("		from app_attribute a ")
	        .append("  		where substr(t.id,5) = a.id ")
	        .append("      		and a.zhongyao_jibie is not null) as zhongyao_jibie, ")
	        .append("	(select a.guanjian_jibie ")
	        .append("   	from app_attribute a ")
	        .append("    	where substr(t.id,5) = a.id ")
	        .append("       	and a.guanjian_jibie is not null) as guanjian_jibie ")
	        .append("	from LIEBIAO t ")
	        .append("	order by t.id");
		
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询应用系统所有的编号.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemIDAndNames(){
		return getSession().createQuery("select new map(s.sysId as sysId, s.sysName as sysName) from SystemInfoVo s order by s.sysId").list();
	}
	
	/**
	 * 查询所有系统的系统管理员A角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemAdminAs(){
		return getSession().createQuery("select distinct new map(s.sysA as sysA) from SystemInfoVo s order by s.sysA").list();
	}
	
	/**
	 * 查询所有系统的系统管理员B角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySystemAdminBs(){
		return getSession().createQuery("select distinct new map(s.sysB as sysB) from SystemInfoVo s order by s.sysB").list();
	}
	
	/**
	 * 查询所有系统的应用管理员A角及对应的组别.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppAdminAs(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appa as \"appA\", ")
			.append("						(select m.groupname from member m where t.appa = m.username) as \"groupName\" ")
			.append("from LIEBIAO t ")
			.append("order by t.appa ");
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询所有系统的应用管理员B角.
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAppAdminBs(){
		return getSession().createQuery("select distinct new map(s.appB as appB) from SystemInfoVo s order by s.appB").list();
	}
	
	/**
	 * 查询系统列表并写入到.dat文件,
	 * 再通过ftp上传到文件中转机服务器.
	 * 该方法主要推送的文件是MAOP平台要同步的系统列表信息.
	 */
	public void saveSystemInfos2FileAndFtp2Server() {
		File file = saveSystemInfos2File();
		ftp2Server(file);
	}

	/**
	 * 通过ftp方式将文件上传到文件中转机服务器.
	 * @param file 目标文件
	 */
	private void ftp2Server(File file) {
		try {
			String host = messages.getMessage("fileServer.ipAdress");
			int port = (Integer.parseInt(messages.getMessage("fileServer.port")));
			String user = messages.getMessage("fileServer.maop.user");
			String password = messages.getMessage("fileServer.maop.password");
			ComponentFtpConnection ftpLogin = new ComponentFtpConnection();
			ftpLogin.connect(host, port, user, password);
			ComponentFtp ftpFile = new ComponentFtp(ftpLogin);
			String remoteFilename = messages.getMessage("fileServer.maop.path").concat(file.getName());
			ftpFile.doPut(file.getAbsolutePath(), remoteFilename, true, new StringBuffer());
			ftpLogin.disconnect();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if(file != null && file.exists()) {
				file.delete();
			}
		}
	}

	/**
	 * 查询系统列表并写入到.dat文件.
	 * @return
	 */
	private File saveSystemInfos2File() {
		List<Map<String, String>> list = querySystemInfos4FtpServer();
		OutputStream out = null;
		BufferedOutputStream bout = null;
		OutputStreamWriter osWriter = null;
		PrintWriter pWriter = null;
		Assert.notEmpty(list);
		
		//格式化
		String today = DateFunction.convertDateToStr(Calendar.getInstance().getTime(), 6);
		
		File f = new File("APPLICATION_INFO-"+ today +".dat");
		try {
			out = new FileOutputStream(f);
			bout = new BufferedOutputStream(out);
			osWriter = new OutputStreamWriter(bout, "utf-8");
			pWriter = new PrintWriter(osWriter);
			
			for(int i = 0; i < list.size(); i++){
				StringBuilder line = new StringBuilder();
				Map<String, String> map = list.get(i);
				
				line.append(ComUtil.checkNull(map.get("sysId")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("sysName")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("sysA")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("sysB")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("appA")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("appB")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("projectLeader")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("sysStatus")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("department")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("serviceTime")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("disasterRecoverPriority")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("securityRank")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("manager")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("appOutline")).replaceAll("\r\n", "<br>").replaceAll("\n", "<br>"))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("appType")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("coreRank")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("importantRank")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("hingeRank")))
					 .append("|+|")
					 .append(ComUtil.checkNull(map.get("groupName")));
							
				pWriter.print(line.toString());
				pWriter.print("\n");
				pWriter.flush();
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} finally {
			try {
				if(out != null){
					out.close();
				}
				
				if(bout != null){
					bout.close();
				}
				
				if(osWriter != null){
					osWriter.close();
				}
				
				if(pWriter != null){
					pWriter.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return f;
	}
	
	/**
	 * 查询系统列表.
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional
	private List<Map<String, String>> querySystemInfos4FtpServer(){
		StringBuilder sql = new StringBuilder();
		sql.append("select substr(t.id, 5) as \"sysId\", ")
			.append("       t.sysname as \"sysName\", ")
			.append("       t.sysa as \"sysA\", ")
			.append("       t.sysb as \"sysB\", ")
			.append("       t.appa as \"appA\", ")
			.append("       t.appb as \"appB\", ")
			.append("       t.develop as \"projectLeader\", ")
			.append("       t.flag as \"sysStatus\", ")
			.append("       t.depart as \"department\", ")
			.append("       t.fuwu as \"serviceTime\", ")
			.append("       t.anquan as \"disasterRecoverPriority\", ")
			.append("       t.jibie as \"securityRank\", ")
			.append("       t.manager as \"manager\", ")
			.append("       t.app_outline as \"appOutline\", ")
			.append("       t.app_type as \"appType\", ")
			.append("       (select groupname from member where username = t.appa) as \"groupName\", ")
			.append("       (select a.hexin_jibie ")
			.append("          from app_attribute a ")
			.append("         where substr(t.id, 5) = a.id ")
			.append("           and a.hexin_jibie is not null) as \"coreRank\", ")
			.append("       (select a.zhongyao_jibie ")
			.append("          from app_attribute a ")
			.append("         where substr(t.id, 5) = a.id ")
			.append("           and a.zhongyao_jibie is not null) as \"importantRank\", ")
			.append("       (select a.guanjian_jibie ")
			.append("          from app_attribute a ")
			.append("         where substr(t.id, 5) = a.id ")
			.append("           and a.guanjian_jibie is not null) as \"hingeRank\" ")
			.append("  from liebiao t ");
		
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
}
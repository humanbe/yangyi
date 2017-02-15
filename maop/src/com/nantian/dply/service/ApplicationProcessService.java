package com.nantian.dply.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.dozer.util.mapping.vo.inheritance.twolevel.A;
import net.sf.json.JSONArray;

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
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.com.DataException;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.ApplicationProcessRecordsVo;
import com.nantian.dply.vo.OccasServersInfoVo;
import com.nantian.dply.vo.ServersInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ApplicationProcessService {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(ApplicationProcessService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	@Autowired
	 private SecurityUtils securityUtils; 

	/**
	 * 构造方法
	 */
	public ApplicationProcessService() {
		fields.put("record_id", FieldType.STRING);
		fields.put("subject_info", FieldType.STRING);
		fields.put("handled_user", FieldType.STRING);
		fields.put("application_user", FieldType.STRING);
		fields.put("current_state", FieldType.STRING);
		fields.put("order_consuming_time", FieldType.STRING);
		fields.put("completed_time", FieldType.TIMESTAMP);
		fields.put("handled_time", FieldType.TIMESTAMP);
		fields.put("completed_time", FieldType.TIMESTAMP);
		fields.put("handled_user", FieldType.STRING);
		fields.put("application_reasons", FieldType.STRING);	
		fields.put("process_description", FieldType.STRING);
		fields.put("delete_flag", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ApplicationProcessRecordsVo applicationProcessRecordsVo) {
		getSession().save(applicationProcessRecordsVo);
	}

	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional
	public void update(ApplicationProcessRecordsVo applicationProcessRecordsVo) {
		getSession().update(applicationProcessRecordsVo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void saveOccasServersInfo(List<OccasServersInfoVo> occasServersInfoVos) {
		for (OccasServersInfoVo occasServersInfoVo : occasServersInfoVos) {
			getSession().save(occasServersInfoVo);
		}
	}
	

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(Set<ApplicationProcessRecordsVo> applicationProcessRecordsVos) {
		for (ApplicationProcessRecordsVo applicationProcessRecordsVo : applicationProcessRecordsVos) {
			getSession().save(applicationProcessRecordsVo);
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
	public Object get(Serializable record_id) {
		return getSession().get(ApplicationProcessRecordsVo.class, record_id);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ApplicationProcessRecordsVo applicationProcessRecordsVo) {
		getSession().delete(applicationProcessRecordsVo);
	}
	
	

//有用数据-------------------------------------------------------------------------------------------------------------------------------------	
	
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
	public List<Map<String, Object>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params) {
		//,String status
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("t.record_id as \"record_id\",");
		sql.append("t.subject_info as \"subject_info\",");
		sql.append("t.handled_user as \"handled_user\",");
		sql.append("t.completed_user as \"completed_user\",");
		sql.append("t.application_user as \"application_user\",");
		sql.append("t.current_state as \"current_state\",");
		
		sql.append("case when t.completed_time is null  ");
		sql.append("then to_date(to_char(sysdate,'yyyymmdd'),'yyyymmdd')-to_date(to_char(t.application_time,'yyyymmdd'),'yyyymmdd') ");
		sql.append("else to_date(to_char(t.completed_time,'yyyymmdd'),'yyyymmdd')-to_date(to_char(t.application_time,'yyyymmdd'),'yyyymmdd') ");
		sql.append("end as \"order_consuming_time\" ,");
		
		sql.append(" to_char(t.completed_time ,'yyyy-mm-dd HH24:mi:ss')  as \"completed_time\",");
		sql.append(" to_char(t.application_time ,'yyyy-mm-dd HH24:mi:ss') as \"application_time\",");
		sql.append(" to_char(t.handled_time ,'yyyy-mm-dd HH24:mi:ss') as \"handled_time\",");
		sql.append("t.application_reasons as \"application_reasons\", ");
		sql.append("t.process_description as \"process_description\" ");
		sql.append("   from Application_Process_Records  t where t.delete_flag=0 ");
		
		/*if(status.equals("1")){
			sql.append(" and  t.current_state  in ('1','2','3')"  );
		}*/

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and t." + key + " like :" + key);
				} else {
					sql.append(" and t." + key + " = :" + key);
				}
			}
		}
		 sql.append(" order by t.current_state asc, t." + sort + " " + dir);
		 
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

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
	public Long count(Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from ApplicationProcessRecordsVo t where t.delete_flag=0 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and t." + key + " like :" + key);
				} else {
					hql.append(" and t." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	
	/**
	 * 查找用户ID
	 * 
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findUserId()throws SQLException  {

		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct u.user_id as  \"userId\" , u.user_id||'('|| u.user_name ||')' as \"name\"  from  JEDA_USER u  ");
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();

	} 
	
	
	/**
	 * 查找用户ID(用户名)
	 * 
	 * @param userId
	
	 * @return
	 */
	public String findbyUserId()throws SQLException  {
		String userId = securityUtils.getUser().getUsername() ;
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct   u.user_id||'('|| u.user_name ||')' as \"name\"  from  JEDA_USER u where u.user_id=?   ");
		Query query =  getSession().createSQLQuery(sql.toString()).setString(0, userId);
		return query.list().get(0).toString();

	} 
	
	/**
	 * 查找用户ID(用户名)
	 * 
	 * @param userId
	
	 * @return
	 */
	public String findbyUserName()throws SQLException  {
		String userId = securityUtils.getUser().getUsername() ;
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct   u.user_name as \"name\"  from  JEDA_USER u where u.user_id=?   ");
		Query query =  getSession().createSQLQuery(sql.toString()).setString(0, userId);
		return query.list().get(0).toString();

	} 
	
	/**
	 * 获取当前登陆用户
	 * 
	 * @return
	 */
	public String getUserId()throws SQLException  {

		
		String userID = securityUtils.getUser().getUsername() ;
		return userID.toString();

	}
	
	
	
	/**
	 * 根据ID批量审批.
	 * 
	 * @param ids
	 * @throws SQLException 
	 */
	@Transactional
	public void doOkByIds(String[] record_ids) throws SQLException {
		for (String record_id : record_ids) {
			doOkById(record_id);
		}
	}
	/**
	 * 根据ID审批.
	 * 
	 * @param id
	 * @throws SQLException 
	 */
	private void doOkById(String record_id) throws SQLException {
		String user =this.findbyUserId();
		ApplicationProcessRecordsVo vo =new ApplicationProcessRecordsVo();
		vo =(ApplicationProcessRecordsVo) this.get(record_id);
		
		Date startDate = new Date();
		Timestamp handled_time = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String  ps=vo.getProcess_description()+"<br>"+time+"<br>"+CommonConst.CHANGE_LINE +user+ " : 审批通过;";
		vo.setHandled_user(user);
		vo.setCurrent_state("2");
		vo.setProcess_description(ps);
		vo.setHandled_time(handled_time);
		this.update(vo);
	}



	

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] record_ids,String[] subject_infos) {
		int i=0;
		for (String record_id : record_ids) {
			deleteById(record_id,subject_infos[i]);
			i++;
		}
	}
	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String record_id,String subject_info) {
		getSession()
				.createQuery("delete from  ApplicationProcessRecordsVo ap  where ap.record_id = ?")
				.setString(0, record_id).executeUpdate();
		if(subject_info.equals("3")){
			StringBuilder sql = new StringBuilder();
			sql.append("delete from application_system_auth where record_id=:record_id");
			getSession().createSQLQuery(sql.toString()).setParameter("record_id", record_id)
						.executeUpdate();
			
		}else{
			getSession()
			.createQuery("delete from  OccasServersInfoVo ap  where ap.record_id = ?")
			.setString(0, record_id).executeUpdate();
		}
		
	}
	
	
	
	
	/**
	 * 批量退回审批
	 * @param record_ids
	 * @param process_Backreasons
	 * @throws SQLException 
	 */
	
	@Transactional
	public void backedByIds(String[] record_ids,String process_Backreasons) throws SQLException {
		for (int i = 0; i < record_ids.length ; i++) {
		
			backedById(record_ids[i],process_Backreasons);
			

		}
	}
	
	/**
	 * 完成审批流程当前状态标示 
	 * @param record_id
	* @param process_Backreasons
	 */
	
	public void backedById(String record_id,String process_Backreasons)throws SQLException {
		String user =this.findbyUserId();
		ApplicationProcessRecordsVo vo =new ApplicationProcessRecordsVo();
		vo =(ApplicationProcessRecordsVo) this.get(record_id);
		Date startDate = new Date();
		Timestamp Time = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String  ps=vo.getProcess_description()+"<br>"+time+"<br>"+CommonConst.CHANGE_LINE +user+ " : 审批未通过;";
		ps =ps+CommonConst.CHANGE_LINE+"<br>"+" 退回意见:"+  process_Backreasons;
		vo.setHandled_user(user);
		vo.setCurrent_state("3");
		vo.setProcess_description(ps);
		vo.setHandled_time(Time);
		this.update(vo);
		
	}
	
	
	
	
	/**
	 * 查序列

	 * 
	 */
	
	public String findProcessSeq( )throws SQLException {
		String seq=	(String) getSession().createSQLQuery(
						"select to_char (APPLICATION_PROCESS_SEQ.nextval) from dual")
						.uniqueResult();
		return seq;
	}
	
	
	/**
	 * 读取excel数据
	 * 服务器信息加入临时表
	 */
	
	
	public List<OccasServersInfoVo> getServerList(String filePath,String record_id) throws Exception  {
		
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
				
				if(sheet.getRow(i).getCell(5)==null){
					 stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append("操作系统有空值");
						stdErr.append("<br>");
						continue;
				 }
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
            	
        		//更新脚步执行结束时间
	        	throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
	        }
			
		    List<OccasServersInfoVo> list = new ArrayList<OccasServersInfoVo>();
		    OccasServersInfoVo vo=null;
			for(int i = 1; i <rows; i++) {
				
				 vo = new OccasServersInfoVo();
							 
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
			
				vo.setRecord_id(record_id);	
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
				vo.setAttrFlag("0");
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

	 * */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> viewdataList(Integer start, Integer limit,
			String sort, String dir, String record_id) throws SQLException{
		
		StringBuilder sql = new StringBuilder();
		sql.append("select  o.appsysCode as \"appsysCode\" ,")
				.append(" o.serverName as \"serverName\", ")
				.append(" o.record_id as \"record_id\", ")
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
				.append(" t.record_id as record_id, 	  ")
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
				.append(" from OCCAS_SERVERS_INFO t  )  o where record_id=? ");

		Query query = getSession().createSQLQuery(sql.toString())
				                    .addScalar("record_id", StringType.INSTANCE)
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
									.setString(0, record_id)
									.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		List<Map<String,String>> list =query.list();
		
	return list;
	}
	
	
	
	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countOccasServerIp(String record_id) {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from OCCAS_SERVERS_INFO t where t.record_id=? ");
		
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, record_id);
		
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/** 
	 * 查询服务器信息


	 * */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> systemAuthViewList(Integer start, Integer limit,
			String sort, String dir, String record_id) throws SQLException{
		StringBuilder sql = new StringBuilder();
		sql.append("select sa.RECORD_ID as \"record_id\", ")
			.append("u.user_name||'('||u.user_id||')' as \"userName\", ")
			.append("sa.APPLICATION_USER as \"applicationUser\", ")
			.append("t.systemname as \"appsysName\", ")
			.append("sa.appsys_code as \"appsysCode\", ")
			.append("sa.APPLICATION_AUTY_DPLY as \"applicationAuthDply\", ")
			.append("sa.APPLICATION_AUTH_TOOLBOX as \"applicationAuthToolbox\", ")
			.append("sa.APPLICATION_AUTH_CHECK as \"applicationAuthCheck\" ")
			.append("from application_system_auth sa,v_cmn_app_info t, jeda_user u ")
			.append("where sa.APPSYS_CODE = t.APPSYS_CODE and sa.APPLICATION_USER=u.user_id ")
			.append("and sa.record_id=?");
		Query query = getSession().createSQLQuery(sql.toString())
                .addScalar("record_id", StringType.INSTANCE)
				.addScalar("userName", StringType.INSTANCE)
				.addScalar("applicationUser", StringType.INSTANCE)
				.addScalar("appsysName", StringType.INSTANCE)
				.addScalar("appsysCode", StringType.INSTANCE)
				.addScalar("applicationAuthDply", StringType.INSTANCE)
				.addScalar("applicationAuthToolbox", StringType.INSTANCE)
				.addScalar("applicationAuthCheck", StringType.INSTANCE)
				.setString(0, record_id)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		//userName,applicationUser,appsysName,appsysCode,applicationAuthDply,applicationAuthToolbox,applicationAuthCheck
		List<Map<String,String>> list =query.list();
		
		return list;

	}
	
	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countSystemAuthView(String record_id) {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from application_system_auth t where t.record_id=? ");
		
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, record_id);
		
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	/** 
	 * 查询临时服务器信息

	 * */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ServersInfoVo> List(String record_id) throws SQLException{
		
		StringBuilder hql = new StringBuilder();
		hql.append(" from OccasServersInfoVo  t where t.record_id=? ");

		Query query = getSession().createQuery(hql.toString()).setString(0, record_id);

		List<OccasServersInfoVo> list =query.list();
		List<ServersInfoVo> listserver=new ArrayList<ServersInfoVo>();
		for(OccasServersInfoVo occasServersInfoVo :list){
			ServersInfoVo vo=new ServersInfoVo();
			vo.setAppsysCode(null != occasServersInfoVo.getAppsysCode()?ComUtil.checkJSONNull(occasServersInfoVo.getAppsysCode()):null);
			vo.setAttrFlag(null != occasServersInfoVo.getAttrFlag()?ComUtil.checkJSONNull(occasServersInfoVo.getAttrFlag()):null);
			vo.setServerIp(null != occasServersInfoVo.getServerIp()?ComUtil.checkJSONNull(occasServersInfoVo.getServerIp()):null);
			vo.setServerName(null != occasServersInfoVo.getServerName()?ComUtil.checkJSONNull(occasServersInfoVo.getServerName()):null);
			vo.setFloatingIp(null != occasServersInfoVo.getFloatingIp()?ComUtil.checkJSONNull(occasServersInfoVo.getFloatingIp()):null);
			vo.setServerRole(null != occasServersInfoVo.getServerRole()?ComUtil.checkJSONNull(occasServersInfoVo.getServerRole()):null);
			vo.setServerUse(null != occasServersInfoVo.getServerUse()?ComUtil.checkJSONNull(occasServersInfoVo.getServerUse()):null);
			vo.setMachineroomPosition(null != occasServersInfoVo.getMachineroomPosition()?ComUtil.checkJSONNull(occasServersInfoVo.getMachineroomPosition()):null);
			vo.setOsType(null != occasServersInfoVo.getOsType()?ComUtil.checkJSONNull(occasServersInfoVo.getOsType()):null);
			vo.setMwType(null != occasServersInfoVo.getMwType()?ComUtil.checkJSONNull(occasServersInfoVo.getMwType()):null);
			vo.setDbType(null != occasServersInfoVo.getDbType()?ComUtil.checkJSONNull(occasServersInfoVo.getDbType()):null);
			vo.setCollectionState("成功");
			vo.setEnvironmentType(null != occasServersInfoVo.getEnvironmentType()?ComUtil.checkJSONNull(occasServersInfoVo.getEnvironmentType()):null);
			vo.setBsaAgentFlag("0");
			vo.setDataType("H");
			vo.setDeleteFlag("0");
			listserver.add(vo);
		}
	return listserver;
	}
	
	
	
	/**
	 * 完成导入流程当前状态标示 
	 * @param record_id
	* @param process_Backreasons
	 */
	@Transactional
	public void completedProcess(String record_id)throws SQLException {
		String user =this.findbyUserId();
		ApplicationProcessRecordsVo vo =new ApplicationProcessRecordsVo();
		vo =(ApplicationProcessRecordsVo) this.get(record_id);
		Date startDate = new Date();
		Timestamp completedTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String  ps=vo.getProcess_description()+CommonConst.CHANGE_LINE+"<br>"+time +"<br>"+user+ " : 审批流程完成;";
		vo.setCurrent_state("4");
		vo.setCompleted_user(user);
		vo.setCompleted_time(completedTime);
		vo.setProcess_description(ps);
		this.update(vo);
		
	}
	
	/**
	 * 取消审批流程
	 * @param record_ids
	* @param process_Backreasons
	 * @throws SQLException 
	 */
	public void doCancelByIds(String[] record_ids) throws SQLException {
		
		for (String record_id : record_ids) {
			doCancelById(record_id);
		}
	}
	/**
	 * 根据ID取消.
	 * 
	 * @param id
	 * @throws SQLException 
	 */
	private void doCancelById(String record_id) throws SQLException {
		String user =this.findbyUserId();
		ApplicationProcessRecordsVo vo =new ApplicationProcessRecordsVo();
		vo =(ApplicationProcessRecordsVo) this.get(record_id);
		Date startDate = new Date();
		Timestamp completedTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		String  ps=vo.getProcess_description()+CommonConst.CHANGE_LINE+"<br>"+time +"<br>"+user+ " : 审批流程取消;";
		vo.setCurrent_state("5");
		vo.setCompleted_time(completedTime);
		vo.setProcess_description(ps);
		this.update(vo);
		
	}
	
//-------------------------------------------------------------------------------------------------------------------------------------	
	
	
	
	/**
	 * 根据ID查询.
	 * 
	 * @param hostip
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String hostIp) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ds.hostIp as hostIp,");
		hql.append("ds.hostName as hostName,");
		hql.append("ds.osType as osType,");
		hql.append("ds.osVersion as osVersion,");
		hql.append("ds.environType as environType,");
		hql.append("ds.fileTransferType as fileTransferType,");
		hql.append("ds.fileTransferUser as fileTransferUser,");
		hql.append("ds.fileTransferPswd as fileTransferPswd,");
		hql.append("ds.deleteFlag as deleteFlag ");
		hql.append(") from ServerInfoVo ds where ds.hostIp =? and ds.deleteFlag = '0' ");

		return getSession().createQuery(hql.toString())
				.setString(0, hostIp).uniqueResult();

	}


	public Object queryDownloadAll(Integer start, Integer limit, String sort,
			String dir, Map<String, Object> params) {
		//,String status
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
		sql.append("t.record_id as \"record_id\",");
		sql.append("t.subject_info as \"subject_info\",");
		sql.append("t.handled_user as \"handled_user\",");
		sql.append("t.completed_user as \"completed_user\",");
		sql.append("t.application_user as \"application_user\",");
		sql.append("t.current_state as \"current_state\",");
		
		sql.append("case when t.completed_time is null  ");
		sql.append("then to_date(to_char(sysdate,'yyyymmdd'),'yyyymmdd')-to_date(to_char(t.application_time,'yyyymmdd'),'yyyymmdd') ");
		sql.append("else to_date(to_char(t.completed_time,'yyyymmdd'),'yyyymmdd')-to_date(to_char(t.application_time,'yyyymmdd'),'yyyymmdd') ");
		sql.append("end as \"order_consuming_time\" ,");
		
		sql.append(" to_char(t.completed_time ,'yyyy-mm-dd HH24:mi:ss')  as \"completed_time\",");
		sql.append(" to_char(t.application_time ,'yyyy-mm-dd HH24:mi:ss') as \"application_time\",");
		sql.append(" to_char(t.handled_time ,'yyyy-mm-dd HH24:mi:ss') as \"handled_time\",");
		sql.append("t.application_reasons as \"application_reasons\", ");
		sql.append("t.process_description as \"process_description\" ");
		sql.append("   from Application_Process_Records  t where t.delete_flag=0 and t.subject_info='2'");
		

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and t." + key + " like :" + key);
				} else {
					sql.append(" and t." + key + " = :" + key);
				}
			}
		}
		 sql.append(" order by t.current_state asc, t." + sort + " " + dir);
		 
		Query query = getSession().createSQLQuery(sql.toString())
				.setFirstResult(start).setMaxResults(limit).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.list();
	}

	public List<Map<String, String>> queryDownloadInfo(String[] recordIds) throws SQLException {
		String user =this.findbyUserName();
		StringBuilder sql = new StringBuilder();
		sql.append("select to_char(sysdate ,'yyyy-mm-dd') as \"date\",t.appsys_code as \"appsysCode\", o.SYSTEMMANAGERA as \"sysa\",o.SYSTEMMANAGERB as \"sysb\",  ");
		sql.append(" '"+user+"' as \"installPerson\" , '"+user+"' as \"inspectorPerson\" ,t.server_ip as \"serverIp\" from cmn_servers_info t , ");
		sql.append("v_cmn_app_info o ,occas_servers_info n,application_process_records m ");
		sql.append("where t.appsys_code=o.appsys_code ");
		sql.append("and m.record_id=n.record_id ");
		sql.append("and n.appsys_code=t.appsys_code ");
		sql.append("and n.server_ip=t.server_ip ");
		sql.append("and m.subject_info='2'  and  m.record_id in :sysList ");
		Query query = getSession().createSQLQuery(sql.toString())
				 .addScalar("date", StringType.INSTANCE)
				 .addScalar("appsysCode", StringType.INSTANCE)
				 .addScalar("sysa", StringType.INSTANCE)
				 .addScalar("sysb", StringType.INSTANCE)
				 .addScalar("installPerson", StringType.INSTANCE)
				 .addScalar("inspectorPerson", StringType.INSTANCE)
				 .addScalar("serverIp", StringType.INSTANCE)
				 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		query.setParameterList("sysList", recordIds);
		return query.list();
	}

	public List<String> queryServer(String record_id) {
		StringBuilder sql = new StringBuilder();
		sql.append("select t.server_ip || '|+|' || t.appsys_code as server from occas_servers_info t where t.record_id='"+record_id+"' ");
		Query query = getSession().createSQLQuery(sql.toString());
		
		return query.list();
	}
	
	public List<String> querySystemAuth(String record_id) {
		StringBuilder sql = new StringBuilder();
		sql.append("select APPLICATION_USER|| '|+|' ||APPSYS_CODE|| '|+|' ||APPLICATION_AUTY_DPLY|| '|+|' ||APPLICATION_AUTH_TOOLBOX|| '|+|' ||APPLICATION_AUTH_CHECK as systemAuth from APPLICATION_SYSTEM_AUTH t where t.record_id='"+record_id+"' ");
		Query query = getSession().createSQLQuery(sql.toString());
		return query.list();
	}
	
	public void doSystemAuth(List<String> list){
		String user = null;
		String app = null;
		String dply = null;
		String tool = null;
		String check = null;
		StringBuilder sqlCount = null;
		StringBuilder sqlAdd = null;
		StringBuilder sqlEdit = null;
		
		Query query = null;
		for(String record : list){
			user = record.split(Constants.SPLIT_SEPARATEOR)[0];
			app = record.split(Constants.SPLIT_SEPARATEOR)[1];
			dply = record.split(Constants.SPLIT_SEPARATEOR)[2];
			tool = record.split(Constants.SPLIT_SEPARATEOR)[3];
			check = record.split(Constants.SPLIT_SEPARATEOR)[4];
			
			sqlCount = new StringBuilder();
			sqlCount.append("select count(*) from cmn_user_app where user_id='")
				.append(user)
				.append("' and appsys_code='")
				.append(app)
				.append("'");
			query = getSession().createSQLQuery(sqlCount.toString());

			if(Long.valueOf(query.uniqueResult().toString())==0L){
				sqlAdd = new StringBuilder();
				sqlAdd.append("insert into CMN_USER_APP ")
					.append(" (USER_ID,APPSYS_CODE,APP_TYPE,DPLY_FLAG,CHECK_FLAG,TOOL_FLAG) ")
					.append("values ( '")
					.append(user)
					.append("' , '")
					.append(app)
					.append("' , 'H','")
					.append(dply)
					.append("' , '")
					.append(check)
					.append("' , '")
					.append(tool)
					.append("')");
				getSession().createSQLQuery(sqlAdd.toString()).executeUpdate();
			}else{
				sqlEdit = new StringBuilder();
				String dplyToolCheck = null;
				if(dply.equals("1")){
					if(tool.equals("1")){
						if(check.equals("1")){
							dplyToolCheck = " DPLY_FLAG='1',CHECK_FLAG='1',TOOL_FLAG='1' ";
						}else{
							dplyToolCheck = " DPLY_FLAG='1',CHECK_FLAG='1' ";
						}
					}else{
						if(check.equals("1")){
							dplyToolCheck = " DPLY_FLAG='1',TOOL_FLAG='1' ";
						}else{
							dplyToolCheck = " DPLY_FLAG='1' ";
						}
					}
				}else{
					if(tool.equals("1")){
						if(check.equals("1")){
							dplyToolCheck = " CHECK_FLAG='1',TOOL_FLAG='1' ";
						}else{
							dplyToolCheck = " CHECK_FLAG='1' ";
						}
					}else{
						if(check.equals("1")){
							dplyToolCheck = " TOOL_FLAG='1' ";
						}else{
							break;
						}
					}
				}
				if(dplyToolCheck!=null){
					sqlEdit.append("update cmn_user_app set ")
						.append(dplyToolCheck)
						.append(" where user_id='")
						.append(user)
						.append("' and appsys_code='")
						.append(app)
						.append("'");
					getSession().createSQLQuery(sqlEdit.toString()).executeUpdate();
				}
			}
		}
		
	}
	
}///:~

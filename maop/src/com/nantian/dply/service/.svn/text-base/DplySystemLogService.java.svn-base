 package com.nantian.dply.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.dply.vo.DplySystemLogVo;
import com.nantian.jeda.FieldType;

/**
 * 日志管理
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class DplySystemLogService {

    public Map<String, String> fields = new HashMap<String, String>();
    
    /**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;

    public Session getSession() {
        return sessionFactory.getCurrentSession();
    }
    @Autowired
	 private AppInfoService appInfoService;
    /**
     * 构造方法
     */
    public DplySystemLogService() {
        fields.put("logJnlNo", FieldType.STRING);
        fields.put("execDate", FieldType.STRING);
        fields.put("appsysCode", FieldType.STRING);
        fields.put("logResourceType", FieldType.STRING);
        fields.put("requestName", FieldType.STRING);
        fields.put("logType", FieldType.STRING);
        fields.put("execStatus", FieldType.STRING);
        fields.put("execStartTime", FieldType.STRING);
        fields.put("execCompletedTime", FieldType.STRING);
        fields.put("execCreatedTime", FieldType.STRING);
        fields.put("execUpdatedTime", FieldType.STRING);
        fields.put("authorizedUser", FieldType.STRING);
        fields.put("platformUser", FieldType.STRING);
        fields.put("resultsPath", FieldType.STRING);
    }

    /**
     * 保存.
     * 
     * @param batchOvertimeAnaVo
     */
    @Transactional
    public void save(DplySystemLogVo dplySystemLogVo) {
        getSession().save(dplySystemLogVo);
    }

    /**
     * 更新.
     * 
     * @param customer
     */
    @Transactional
    public void update(DplySystemLogVo dplySystemLogVo) {
        getSession().update(dplySystemLogVo);
    }

    /**
     * 保存.
     * 
     * @param batchOvertimeAnaVo
     */
    @Transactional
    public void saveOrUpdate(CmnLogVo cmnLog) {
        getSession().saveOrUpdate(cmnLog);
    }

    /**
     * 查询应用系统所有的编号
     * @return queryReqID
     */
    @Transactional(readOnly = true)
    public Object querySystemIDAndNames() {
        return getSession()
                .createQuery(
                        "select new map(s.appsysCode as sysId, s.systemname as sysName) from  ViewAppInfoVo s order by s.appsysCode")
                .list();
    }
   
    /**
	 * 通过主键查找唯一的一条记录
	 * @param logJnlNo 日志流水号
	 * @return CmnLogVo 实体
	 */
	@Transactional(readOnly = true)
	public Object findByPrimaryKey(Integer start, Integer limit, String sort, String dir, Map<String, Object> params,String logJnlNo){
		 StringBuilder hql = new StringBuilder();
		 hql.append("select o.logJnlNo as \"logJnlNo\", ")
		 			.append("o.detailLogSeq as \"detailLogSeq\", ")
					.append("o.execDate as \"execDate\", ")
					.append("o.appsysCode as \"appsysCode\", ")
					.append("o.stepName as \"stepName\", ")
					.append("o.jobName as \"jobName\",")
					.append("o.execServerIp as \"execServerIp\", ")
					.append("o.logType as \"logType\", ")
					.append("o.execStatus as \"execStatus\", ")
					.append("o.execStartTime as \"execStartTime\", ")
					.append("o.execCompletedTime as \"execCompletedTime\", ")
					.append("o.execCreatedTime as \"execCreatedTime\", ")
					.append("o.execUpdatedTime as \"execUpdatedTime\", ")
					.append("o.resultsPath as \"resultsPath\" ")
	                .append("from (select b.log_jnl_no as logJnlNo, ")
	                .append("b.DETAIL_LOG_SEQ as detailLogSeq, ")
	                .append("b.exec_date as execDate, ")
	                .append("b.appsys_code as appsysCode, ")
	                .append("b.step_Name as stepName, ")
	                .append("b.job_Name as jobName, ")
	                .append("b.EXEC_SERVER_IP as execServerIp, ")
	                .append("b.log_type as logType, ")
	                .append("b.exec_status as execStatus, ")
	                .append("to_char(b.exec_start_time, 'yyyymmdd hh:mi:ss') as execStartTime, ")
	                .append("to_char(b.exec_completed_time, 'yyyymmdd hh:mi:ss') as execCompletedTime, ")
	                .append("to_char(b.exec_created_time, 'yyyymmdd hh:mi:ss') as execCreatedTime, ")
	                .append("to_char(b.exec_updated_time, 'yyyymmdd hh:mi:ss') as execUpdatedTime, ")
	                .append("b.results_path as resultsPath ")
	                .append("from cmn_detail_log b where b.log_jnl_no =:logJnlNo) o  ")
	                .append(" order by detailLogSeq ");
	        Query query =getSession().createSQLQuery(hql.toString())
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
					.setString("logJnlNo", logJnlNo);
		return query.setFirstResult(start).setMaxResults(limit).list();
				
	}
    /**
     * 查询数据
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
    public List<Map<String, String>> queryAll(Integer start, Integer limit, String sort, String dir, String appsysCode,String execStartTime,String execCompletedTime,String logType,String logResourceType) {

        StringBuilder sql = new StringBuilder();
                sql.append("select o.logJnlNo as \"logJnlNo\", ")
                .append("o.execDate as \"execDate\",")
                .append("o.appsysCode as \"appsysCode\",")
                .append("o.logResourceType as \"logResourceType\",")
                .append("o.requestName as \"requestName\",")
                .append("o.logType as \"logType\",")
                .append("o.execStatus  as \"execStatus\",")
                .append("o.execStartTime  as \"execStartTime\",")
                .append("o.execCompletedTime as \"execCompletedTime\",")
                .append("o.execCreatedTime as \"execCreatedTime\",")
                .append("o.execUpdatedTime as \"execUpdatedTime\",")
                .append("o.authorizedUser as \"authorizedUser\",")
                .append("o.platformUser as \"platformUser\"")
                .append("from (select b.log_jnl_no as logJnlNo,")
                .append("b.exec_date as execDate, ")
                .append("b.appsys_code as appsysCode, ")
                .append("b.log_resource_type as logResourceType, ")
                .append("b.request_name as requestName, ")
                .append("b.log_type as logType, ")
                .append("b.exec_status as execStatus,")
                .append("to_char(b.exec_start_time, 'yyyymmdd hh24:mi:ss') as execStartTime,")
                .append("to_char(b.exec_completed_time,'yyyymmdd hh24:mi:ss') as execCompletedTime,")
                .append("to_char(b.exec_created_time,'yyyymmdd hh24:mi:ss') as execCreatedTime, ")
                .append("to_char(b.exec_updated_time,'yyyymmdd hh24:mi:ss') as execUpdatedTime, ")
                .append("b.authorized_user as authorizedUser, ")
                .append("b.platform_user as platformUser ")
                .append("from cmn_log b) o where o.appsysCode in (:sysList)");
                
                if(null != appsysCode && appsysCode.length() > 0){
                	sql.append(" and o.appsysCode like '%" + appsysCode+"%'");
                }
                
                if(null != logType && logType.length() > 0){
                	sql.append(" and o.logType = '" + logType+"'");
                }
                
                if(null != logResourceType && logResourceType.length() > 0){
                	sql.append(" and o.logResourceType = '" + logResourceType+"'");
                }
                
                if(null != execStartTime && execStartTime.length() > 0){
                	sql.append(" and o.execStartTime >= to_char('" + execStartTime + "')");
                }
                
                if(null != execCompletedTime && execCompletedTime.length() > 0){
                	sql.append(" and o.execCompletedTime <= to_char('" + execCompletedTime + "+1')");
                }
                
        sql.append(" order by " + sort + " " + dir);
        Query query = getSession().createSQLQuery(sql.toString())
                .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
      
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        
        return query.setFirstResult(start).setMaxResults(limit).list();
    }

    /**
     * 查询数据
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
    public List<Map<String, String>> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

        StringBuilder sql = new StringBuilder();
                sql.append("select o.logJnlNo as \"logJnlNo\", ")
                .append("o.execDate as \"execDate\",")
                .append("o.appsysCode as \"appsysCode\",")
                .append("o.logResourceType as \"logResourceType\",")
                .append("o.requestName as \"requestName\",")
                .append("o.logType as \"logType\",")
                .append("o.execStatus  as \"execStatus\",")
                .append("o.execStartTime  as \"execStartTime\",")
                .append("o.execCompletedTime as \"execCompletedTime\",")
                .append("o.execCreatedTime as \"execCreatedTime\",")
                .append("o.execUpdatedTime as \"execUpdatedTime\",")
                .append("o.authorizedUser as \"authorizedUser\",")
                .append("o.platformUser as \"platformUser\"")
                .append("from (select b.log_jnl_no as logJnlNo,")
                .append("b.exec_date as execDate, ")
                .append("b.appsys_code as appsysCode, ")
                .append("b.log_resource_type as logResourceType, ")
                .append("b.request_name as requestName, ")
                .append("b.log_type as logType, ")
                .append("b.exec_status as execStatus,")
                .append("to_char(b.exec_start_time, 'yyyymmdd hh24:mi:ss') as execStartTime,")
                .append("to_char(b.exec_completed_time,'yyyymmdd hh24:mi:ss') as execCompletedTime,")
                .append("to_char(b.exec_created_time,'yyyymmdd hh24:mi:ss') as execCreatedTime, ")
                .append("to_char(b.exec_updated_time,'yyyymmdd hh24:mi:ss') as execUpdatedTime, ")
                .append("b.authorized_user as authorizedUser, ")
                .append("b.platform_user as platformUser ")
                .append("from cmn_log b) o where o.appsysCode in :sysList ");
        if (params.keySet().size() > 0) {
            for (String key : params.keySet()) {
                if (fields.get(key).equals(FieldType.STRING)) {
                    sql.append(" and " + key + " like :" + key);
                } else {
                    sql.append(" and " + key + " = :" + key);
                }
            }
        }
        sql.append(" order by " + sort + " " + dir);
        Query query = getSession().createSQLQuery(sql.toString())
                .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
        if (params.keySet().size() > 0) {
            query.setProperties(params);
        }
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        
        return query.setFirstResult(start).setMaxResults(limit).list();
    }
    
    /**
     * 查询数据
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
    public List<Map<String, String>> queryAllEventLog( String event_id) {

        StringBuilder sql = new StringBuilder();
                sql.append("select o.logJnlNo as \"logJnlNo\", ")
                .append("o.execDate as \"execDate\",")
                .append("o.appsysCode as \"appsysCode\",")
                .append("o.logResourceType as \"logResourceType\",")
                .append("o.requestName as \"requestName\",")
                .append("o.logType as \"logType\",")
                .append("o.execStatus  as \"execStatus\",")
                .append("o.execStartTime  as \"execStartTime\",")
                .append("o.execCompletedTime as \"execCompletedTime\",")
                .append("o.execCreatedTime as \"execCreatedTime\",")
                .append("o.execUpdatedTime as \"execUpdatedTime\",")
                .append("o.authorizedUser as \"authorizedUser\",")
                .append("o.platformUser as \"platformUser\",")
                .append("o.event_id as \"event_id\"")
                .append("from (select b.log_jnl_no as logJnlNo,")
                .append("b.exec_date as execDate, ")
                .append("b.appsys_code as appsysCode, ")
                .append("b.log_resource_type as logResourceType, ")
                .append("b.request_name as requestName, ")
                .append("b.log_type as logType, ")
                .append("b.exec_status as execStatus,")
                .append("to_char(b.exec_start_time, 'yyyymmdd hh24:mi:ss') as execStartTime,")
                .append("to_char(b.exec_completed_time,'yyyymmdd hh24:mi:ss') as execCompletedTime,")
                .append("to_char(b.exec_created_time,'yyyymmdd hh24:mi:ss') as execCreatedTime, ")
                .append("to_char(b.exec_updated_time,'yyyymmdd hh24:mi:ss') as execUpdatedTime, ")
                .append("b.authorized_user as authorizedUser, ")
                .append("b.platform_user as platformUser, ")
                .append("b.event_id as event_id ")
                .append("from cmn_log b) o where o.appsysCode in :sysList and  o.event_id= :event_id");
      
        
        Query query = getSession().createSQLQuery(sql.toString())
                .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
        
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        query.setParameter("event_id", event_id);
        return query.list();
    }

    /**
     * 查询数据总数
     * 
     * @param params
     * @return
     */
    @Transactional(readOnly = true)
    public Long count( String appsysCode,String execStartTime,String execCompletedTime,String logType,String logResourceType) {

    	StringBuilder sql = new StringBuilder();
    	   sql.append("select count(*) from ( ")
    	 .append("select o.logJnlNo as \"logJnlNo\", ")
         .append("o.execDate as \"execDate\",")
         .append("o.appsysCode as \"appsysCode\",")
         .append("o.logResourceType as \"logResourceType\",")
         .append("o.requestName as \"requestName\",")
         .append("o.logType as \"logType\",")
         .append("o.execStatus  as \"execStatus\",")
         .append("o.execStartTime  as \"execStartTime\",")
         .append("o.execCompletedTime as \"execCompletedTime\",")
         .append("o.execCreatedTime as \"execCreatedTime\",")
         .append("o.execUpdatedTime as \"execUpdatedTime\",")
         .append("o.authorizedUser as \"authorizedUser\",")
         .append("o.platformUser as \"platformUser\"")
         .append("from (select b.log_jnl_no as logJnlNo,")
         .append("b.exec_date as execDate, ")
         .append("b.appsys_code as appsysCode, ")
         .append("b.log_resource_type as logResourceType, ")
         .append("b.request_name as requestName, ")
         .append("b.log_type as logType, ")
         .append("b.exec_status as execStatus,")
         .append("to_char(b.exec_start_time, 'yyyymmdd hh24:mi:ss') as execStartTime,")
         .append("to_char(b.exec_completed_time,'yyyymmdd hh24:mi:ss') as execCompletedTime,")
         .append("to_char(b.exec_created_time,'yyyymmdd hh24:mi:ss') as execCreatedTime, ")
         .append("to_char(b.exec_updated_time,'yyyymmdd hh24:mi:ss') as execUpdatedTime, ")
         .append("b.authorized_user as authorizedUser, ")
         .append("b.platform_user as platformUser ")
         .append("from cmn_log b) o where o.appsysCode in (:sysList) ");
    	 
      
    	    if(null != appsysCode && appsysCode.length() > 0){
            	sql.append(" and o.appsysCode like '%" + appsysCode+"%'");
            }
            
            if(null != logType && logType.length() > 0){
            	sql.append(" and o.logType = '" + logType+"'");
            }
            
            if(null != logResourceType && logResourceType.length() > 0){
            	sql.append(" and o.logResourceType = '" + logResourceType+"'");
            }
            
            if(null != execStartTime && execStartTime.length() > 0){
            	sql.append(" and o.execStartTime >= to_char('" + execStartTime + "')");
            }
            
            if(null != execCompletedTime && execCompletedTime.length() > 0){
            	sql.append(" and o.execCompletedTime <= to_char('" + execCompletedTime + "+1')");
            }
            
            sql.append(" ) p where 1=1");
        Query query = getSession().createSQLQuery(sql.toString());
      
        query.setParameterList("sysList", appInfoService.getPersonalSysListForDply());
        return Long.valueOf(query.uniqueResult().toString());
    }
    
    
    /**
     * 查询详细日志
     * 
     * @param params
     * @return
     * @throws Exception 
     */
    @Transactional(readOnly = true)
	public Object findDetail(String resultsPath) throws IOException,FileNotFoundException,Exception {
    	String line = null;
    	File file=new File(resultsPath);
    	Map<String,String> lineMap = null;
    	List<Map<String,String>> linesMap = new ArrayList<Map<String,String>>();
    	BufferedReader br=new BufferedReader(new FileReader(file));
    	try{
        	while ((line = br.readLine())!=null){
        		lineMap = new HashMap<String,String>();
        		line=line.replaceAll(" ","&nbsp;");
        		lineMap.put("info", line);
        		linesMap.add(lineMap);
        	}
    	}catch(Exception e){
    		throw e;
    	}finally{
    		br.close();
    	}
    	return linesMap;
	}

	/**
	 * 查询分组数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countLog(String logJnlNo) {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from CmnDetailLogVo b where b.logJnlNo =:logJnlNo ");
		Query query = getSession().createQuery(hql.toString()).setString("logJnlNo", logJnlNo);
		return Long.valueOf(query.uniqueResult().toString());
	}

}

package com.nantian.check.service;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.vo.CheckComplianceBatchConfigVo;
import com.nantian.check.vo.CheckComplianceResultInfoVo;
import com.nantian.common.util.ComUtil;

/**
 * 巡检错误处理service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class CheckDataSynService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CheckDataSynService.class);

	@Autowired
	/** 报表数据库 */
	@Resource(name = "sessionFactoryMaopRpt")
	private SessionFactory sessionFactoryRpt;

	public Session getSessionRpt() {
		return sessionFactoryRpt.getCurrentSession();
	}
	
	/**
	 * 获取合规巡检数据批量同步配置表中的最后同步时间	 */
	@SuppressWarnings("unchecked")
	public String getLastSynTime(){
		StringBuilder sql = new StringBuilder();
		sql.append("select t.last_synchronize_time from check_compliance_batch_config t");
		Query query = getSessionRpt().createSQLQuery(sql.toString());
		List<Timestamp> list = query.list();
		if(list!=null && list.size()>0){
			return list.get(0).toString().replace("-", "");
		}else{
			return "";
		}
	}
	
	/**
	 * 获取作业执行结果最新数据-获取作业结束时间在lataSynTime与newSynTime之间的结果记录	 * @param lataSynTime
	 *            最后一次同步时间，格式为：yyyyMMdd hh24:mi:ss
	 * @param newSynTime
	 *            最新同步时间，格式为：Date
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getCheckResultData(String lastSynTime,Date newSynTime){
		String newSynTimeStr = new SimpleDateFormat("yyyyMMdd HH:mm:ss").format(newSynTime);
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.appsys_code,")
		   .append("       t.appsys_name,")
		   .append("       t.job_code_jeda,")
		   .append("       t.job_name,")
		   .append("       t.job_path,")
		   .append("       t.template_path,")
		   .append(" 	   t.server_name,")
		   .append(" 	   t.job_id,")
		   .append(" 	   t.template_id,")
		   .append("       t.template_name,")
		   .append("       t.rule_name,")
		   .append("       t.rule_string,")
		   .append("       t.ip_address,")
		   .append("       t.os_name,")
		   .append("       t.result_id,")
		   .append("       t.is_consistent,")
		   .append("       t.is_inconsistent,")
		   .append("       t.rule_result_string,")
		   .append("       to_char(t.rule_check_date,'yyyy-MM-dd hh24:mi:ss') as rule_check_date,")
		   .append("       t.job_is_errors,")
		   .append("       t.job_errors_message,")
		   .append("       t.start_time,")
		   .append("       t.end_time,")
		   .append("       substr(t.rule_string,startnum,endnum-startnum) as extend_object ")
   		   .append("from (select distinct appInfo.appsys_code,appInfo.systemname as appsys_name,job_jeda.job_code as job_code_jeda, ")
		   .append("         job_jeda.job_path as job_path,job_template.template_path as template_path,serverInfo.server_name as server_name,check_result.*, ")
		   .append("         to_char(check_result.job_start_time,'yyyy-MM-dd hh24:mi:ss') as start_time, ")
		   .append("         to_char(check_result.job_end_time,'yyyy-MM-dd hh24:mi:ss') as end_time, ")
		   .append("         instr(check_result.rule_string,'pub') as startnum , ")
		   .append("         case when instr(check_result.rule_string,'//')=0 then instr(check_result.rule_string,'\"',1,2) ")
		   .append("           when instr(check_result.rule_string,'//')>instr(check_result.rule_string,'\"',1,2) and instr(check_result.rule_string,'\"',1,2)>0 ")
		   .append("           then instr(check_result.rule_string,'\"',1,2) ")
		   .append("           else instr(check_result.rule_string,'//') end as endnum ")
   		   .append("   from v_cmn_app_info@DB_JEDA_LINK appInfo,v_check_job_template job_template,v_check_job_info job_jeda,")
		   .append("         v_cmn_servers_info serverInfo,v_compliance_result_for_maop check_result ")
		   .append("   where job_jeda.appsys_code = appInfo.appsys_code ")
		   .append("         and job_jeda.job_code = job_template.job_code ")
		   .append("         and job_jeda.job_type = '1' ") //系统巡检
		   .append("         and job_jeda.job_name = check_result.job_name ")
		   .append("         and job_template.template_name = check_result.template_name ")
		   .append("         and serverInfo.server_ip = check_result.ip_address ")
		   .append("         and job_jeda.job_path = substr(check_result.full_path,6,length(check_result.full_path)) ");
		if(lastSynTime!=null && !lastSynTime.equals("")){
			sql.append("     and to_char(check_result.job_end_time,'yyyyMMdd hh24:mi:ss') > '"+lastSynTime+"' ");
			sql.append("     and to_char(check_result.job_end_time,'yyyyMMdd hh24:mi:ss') <= '"+newSynTimeStr+"' ");
		}
		sql.append(") t");
		Query query = getSessionRpt().createSQLQuery(sql.toString())
									 .addScalar("appsys_code", StringType.INSTANCE)
									 .addScalar("appsys_name", StringType.INSTANCE)
									 .addScalar("job_code_jeda", StringType.INSTANCE)
									 .addScalar("job_name", StringType.INSTANCE)
									 .addScalar("job_path", StringType.INSTANCE)
									 .addScalar("template_path", StringType.INSTANCE)
									 .addScalar("server_name", StringType.INSTANCE)
									 .addScalar("job_id", StringType.INSTANCE)
									 .addScalar("template_id", StringType.INSTANCE)
									 .addScalar("template_name", StringType.INSTANCE)
									 .addScalar("rule_name", StringType.INSTANCE)
									 .addScalar("rule_string", StringType.INSTANCE)
									 .addScalar("ip_address", StringType.INSTANCE)
									 .addScalar("os_name", StringType.INSTANCE)
									 .addScalar("result_id", StringType.INSTANCE)
									 .addScalar("is_consistent", StringType.INSTANCE)
									 .addScalar("is_inconsistent", StringType.INSTANCE)
									 .addScalar("rule_result_string", StringType.INSTANCE)
									 .addScalar("rule_check_date", StringType.INSTANCE)
									 .addScalar("job_is_errors", StringType.INSTANCE)
									 .addScalar("job_errors_message", StringType.INSTANCE)
									 .addScalar("start_time", StringType.INSTANCE)
									 .addScalar("end_time", StringType.INSTANCE)
									 .addScalar("extend_object", StringType.INSTANCE)
								     .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 同步作业执行结果
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
    public String synCheckResultData(){
    	int t = 0; //同步失败记录数量
    	Date newSynTime = new Date(); //系统当前时间
    	Timestamp newSynTimeStamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(newSynTime));
    	String lastSynTime = getLastSynTime(); //上一次同步时间    	List<Map<String, Object>> newDataList = getCheckResultData(lastSynTime,newSynTime);
    	if(newDataList.size() > 0){
    		//同步作业执行结果数据
    		for(Map<String, Object> obj : newDataList){
    			try{
	    			CheckComplianceResultInfoVo  ccriv = new CheckComplianceResultInfoVo();
	    			ccriv.setAppsysCode(ComUtil.checkNull(obj.get("appsys_code")));
	    			ccriv.setJobCodeJeda(Integer.valueOf(ComUtil.checkNull(obj.get("job_code_jeda"))));
	    			ccriv.setJobId(Integer.valueOf(ComUtil.checkNull(obj.get("job_id"))));
	    			ccriv.setJobNameBsa(ComUtil.checkNull(obj.get("job_name")));
	    			ccriv.setJobPath(ComUtil.checkNull(obj.get("job_path")));
	    			ccriv.setTemplateId(Integer.valueOf(ComUtil.checkNull(obj.get("template_id"))));
	    			ccriv.setTemplateName(ComUtil.checkNull(obj.get("template_name")));
	    			ccriv.setTemplatePath(ComUtil.checkNull(obj.get("template_path")));
	    			ccriv.setRuleName(ComUtil.checkNull(obj.get("rule_name")));
	    			ccriv.setRuleString(ComUtil.checkNull(obj.get("rule_string")));
	    			ccriv.setServerName(ComUtil.checkNull(obj.get("server_name")));
	    			ccriv.setServerIp(ComUtil.checkNull(obj.get("ip_address")));
	    			ccriv.setOsName(ComUtil.checkNull(obj.get("os_name")));
	    			ccriv.setResultId(Integer.valueOf(ComUtil.checkNull(obj.get("result_id"))));
	    			//ccriv.setIsConsistent(Integer.valueOf(ComUtil.checkNull(obj.get("is_consistent"))));
	    			//ccriv.setIsInconsistent(Integer.valueOf(ComUtil.checkNull(obj.get("is_inconsistent"))));
	    			//巡检子项状态集合	    			Set<String> statusSet = new HashSet<String>();
	    			//巡检结果
	    			String ruleResultString = ComUtil.checkNull(obj.get("rule_result_string"));
	    			ccriv.setRuleResultString(ruleResultString);
	    			//巡检子项详情
	    			StringBuilder subItemDetail = new StringBuilder();
	    			if(null != ruleResultString && !"".equals(ruleResultString)){
						String[] rusults=ruleResultString.substring(ruleResultString.indexOf("[[")+2,ruleResultString.indexOf("]]")).split(",");
	    				for(int j=0;j<rusults.length;j++){
	    					String result = rusults[j].substring(rusults[j].indexOf("//")+2,rusults[j].indexOf("\".\""));
	    					String status = rusults[j].substring(rusults[j].indexOf("[")+1,rusults[j].indexOf("]"));
	    					if(status!=null && !status.equals("")){
	    						status = status.replaceAll("\"", "");
	    					}
	    					statusSet.add(status.toLowerCase());
	    					if(j != rusults.length-1){
	    						subItemDetail.append(result+"="+status);
	    						subItemDetail.append(";");
	    					}else{
	    						subItemDetail.append(result+"="+status);
	    					}
	    				}
	    			}
	    			ccriv.setSubItemDetail(subItemDetail.toString());
	    			//巡检子项中存在FALSE或NOSCRIPT状态,则不合规
	    			if(!statusSet.isEmpty() && (statusSet.contains("false") || statusSet.contains("noscript"))){
	    				ccriv.setIsConsistent(Integer.valueOf("0"));
	        			ccriv.setIsInconsistent(Integer.valueOf("1"));
	        			ccriv.setInconsistentHandleStatus(1); //不合规：默认状态值为1(未处理)
	    			}else{ //巡检子项中不存在FALSE状态且不存在NOSCRIPT状态,视为合规
	    				ccriv.setIsConsistent(Integer.valueOf("1"));
	        			ccriv.setIsInconsistent(Integer.valueOf("0"));
	        			ccriv.setInconsistentHandleStatus(4); //合规：默认状态值为4(正常)
	    			}
	    			ccriv.setRuleDate(Timestamp.valueOf(ComUtil.checkNull(obj.get("rule_check_date"))));
	    			ccriv.setStartDatetime(Timestamp.valueOf(ComUtil.checkNull(obj.get("start_time"))));
	    			ccriv.setEndDatetime(Timestamp.valueOf(ComUtil.checkNull(obj.get("end_time"))));
	    			ccriv.setJobIsErrors(Integer.valueOf(ComUtil.checkNull(obj.get("job_is_errors"))));
	    			ccriv.setJobErrorsMessage(ComUtil.checkNull(obj.get("job_errors_message")));
	    			ccriv.setDateCreated(newSynTimeStamp);
	    			ccriv.setExtendObject(ComUtil.checkNull(obj.get("extend_object")));
	    			saveCheckResultInfo(ccriv);
    			}catch(Exception e){
    				t = t+1 ;
    				logger.info("巡检结果字段解析异常！job_id="+obj.get("job_id") + "  result_id="+obj.get("result_id")
    						+"  start_time="+obj.get("start_time")+"  rule_result_string="+obj.get("rule_result_string"));
    			}
    		}
    		//修改同步配置表数据    		CheckComplianceBatchConfigVo  ccbcv = new CheckComplianceBatchConfigVo();
    		ccbcv.setLast_synchronize_time(newSynTimeStamp);
    		if(lastSynTime!=null && !lastSynTime.equals("")){
    			deleteCheckBatchConfig();
    		}
			saveCheckBatchConfig(ccbcv);
    	}
    	return newDataList.size()+"#"+t;
    }
    
    /**
	 * 保存作业执行结果数据
	 * @param ccriv 作业执行结果信息对象
	 */
	@Transactional
	public void saveCheckResultInfo(CheckComplianceResultInfoVo ccriv) {
		getSessionRpt().save(ccriv);
	}
	
	/**
	 * 保存合规巡检数据批量同步配置信息
	 * @param ccbcv 合规巡检数据批量同步配置对象
	 */
	@Transactional
	public void saveCheckBatchConfig(CheckComplianceBatchConfigVo ccbcv) {
		getSessionRpt().save(ccbcv);
	}
	
	/**
	 * 删除规巡检数据批量同步配置信息
	 */
	@Transactional
	public void deleteCheckBatchConfig() {
        getSessionRpt().createSQLQuery("delete from check_compliance_batch_config").executeUpdate();
	}

	
}




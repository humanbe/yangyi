package com.nantian.rept.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
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
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.BatchOvertimeAnaVo;
import com.nantian.rept.vo.CapEarlyWarningTimeVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class BatchOvertimeAnaService {

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	
	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	/**
	 * 构造方法	 */
	public BatchOvertimeAnaService() {
		fields.put("jobName", FieldType.STRING);
		fields.put("appSysCd", FieldType.STRING);
		fields.put("errorTime", FieldType.STRING);
		fields.put("jobDesc", FieldType.STRING);
		fields.put("overtimeFlag", FieldType.STRING);
		fields.put("capaRiskType", FieldType.STRING);
		fields.put("jobEffect", FieldType.STRING);
		fields.put("errorCauseAna", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param batchOvertimeAnaVo
	 */
	@Transactional(value="maoprpt")
	public void save(BatchOvertimeAnaVo batchOvertimeAnaVo) {
		getSession().save(batchOvertimeAnaVo);
	}

	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(BatchOvertimeAnaVo batchOvertimeAnaVo) {
		getSession().update(batchOvertimeAnaVo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param batchOvertimeAnaVos
	 */
	@Transactional(value="maoprpt")
	public void save(Set<BatchOvertimeAnaVo> batchOvertimeAnaVos) {
		for (BatchOvertimeAnaVo batchOvertimeAnaVo : batchOvertimeAnaVos) {
			getSession().save(batchOvertimeAnaVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param batchOvertimeAnaVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<BatchOvertimeAnaVo> batchOvertimeAnaVos) {
		for (BatchOvertimeAnaVo batchOvertimeAnaVo : batchOvertimeAnaVos) {
			getSession().saveOrUpdate(batchOvertimeAnaVo);
		}
	}
	
	/**
	 * 通过主键查找唯一的一条记录
	 * @param jobName 任务名
	 * @param errorTime 报错时间
	 * @return BatchOvertimeAnaVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public BatchOvertimeAnaVo findByPrimaryKey(String jobName,String errorTime){
		return (BatchOvertimeAnaVo) getSession()
				.createQuery("from BatchOvertimeAnaVo t where t.jobName=:jobName and t.errorTime=:errorTime ")
				.setString("jobName", jobName)
				.setString("errorTime", errorTime)
				.uniqueResult();
	}
	
	/**
	 * 删除.
	 * @param batchOvertimeAnaVo
	 */
	@Transactional(value="maoprpt")
	public void delete(BatchOvertimeAnaVo batchOvertimeAnaVo) {
		getSession().delete(batchOvertimeAnaVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param jobNames
	 * @param errorTimes
	 */

	@Transactional("maoprpt")
	public void deleteByUnionKeys(String[] jobNames, String[] errorTimes) {
		for(int i = 0; i < jobNames.length && i < errorTimes.length; i++){
			deleteByUnionKey(jobNames[i], errorTimes[i]);
		}
	}
	
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteByUnionKey(String jobName, String errorTime) {
		getSession().createQuery("delete from BatchOvertimeAnaVo s where s.jobName = :jobName and s.errorTime=:errorTime")
						  .setString("jobName", jobName)
						  .setString("errorTime", errorTime)
						  .executeUpdate();
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
	public List<Map<String,String>> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder sql = new StringBuilder();
		sql.append("select * from ( ")
			.append(" select b.job_name as \"jobName\", ")
			.append("         	l.sysname as \"sysName\", ")
			.append(" 			b.APPSYSCD as \"appSysCd\", ")
			.append(" 			to_char(to_date(b.ERROR_TIME,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss') as \"errorTime\", ")
			.append(" 			b.JOB_DESC as \"jobDesc\", ")
			.append(" 			b.OVERTIME_FLAG as \"overtimeFlag\", ")
			.append(" 			b.CAPA_RISK_TYPE as \"capaRiskType\", ")
			.append(" 			b.JOB_EFFECT as \"jobEffect\", ")
			.append("			b.ERROR_CAUSE_ANA as \"errorCauseAna\" ")
			.append("from BATCH_OVERTIME_ANA b, LIEBIAO l where b.appsyscd = substr(l.id,5) ) o where 1 = 1 ");

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
		 
		Query query = getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询数据总数
	 * @param params
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Long count(Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from BatchOvertimeAnaVo b where 1=1 ");

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
	 * 从文件读取交易信息并返回信息集合
	 * @param filePath 文件路径
	 * @param request
	 * @return Set<BatchOvertimeAnaVo> 交易信息集合
	 * @throws Exception
	 */
	public List<BatchOvertimeAnaVo> readBatchOvertimeAnaFromFile(String filePath,HttpServletRequest request) throws Exception {
		List<BatchOvertimeAnaVo> inputFileList = new ArrayList<BatchOvertimeAnaVo>();
		List<String> primaryKeyCheckList = new ArrayList<String>();
		BatchOvertimeAnaVo vo = null;
		String batchOvertimeAnaStr = "";
		String[] batchOvertimeAnaArr = new String[Constants.BATCH_OVERTIME_ANA_COLUMNS];
		File file = new File(filePath);
		InputStream in = null;
		BufferedReader reader = null;
    	StringBuilder stdErr = new StringBuilder();
    	int rowNumber = 0;
    	double percentage = 0;
		
		if(!file.exists()){
			throw new Exception(messages.getMessage("file.not.found"));
		}else{
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((batchOvertimeAnaStr = reader.readLine()) != null){
				//拆分数据
				batchOvertimeAnaArr = batchOvertimeAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				
				//行号计数
				++rowNumber;
				//上传文件的进度保存到Session, 以便启动校验文件信息的进度条
				request.getSession().setAttribute("importTranInfoPercentage", percentage);
				
				//行的长度Check
				if(batchOvertimeAnaArr.length != Constants.BATCH_OVERTIME_ANA_COLUMNS){
					stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
					stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.BATCH_OVERTIME_ANA_COLUMNS)}));
					stdErr.append("<br>");
					continue;
				}
				//校验容量预警时间表的有效性
				CheckData(batchOvertimeAnaArr, stdErr, rowNumber, request,primaryKeyCheckList);
			}
			if(reader != null){
				reader.close();
			}
			//数据验证异常
            if(stdErr.length() > 0 ){
            	throw new Exception("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString());
            }

          //数据验证正常
        	if(stdErr.length() == 0){
        		in = new FileInputStream(file);
        		reader = new BufferedReader(new InputStreamReader(in,"gbk"));
    			while((batchOvertimeAnaStr = reader.readLine()) != null){
    				//拆分数据
    				batchOvertimeAnaArr = batchOvertimeAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
    				
    				vo = new BatchOvertimeAnaVo();
    				vo.setJobName(batchOvertimeAnaArr[0]);
    				vo.setAppSysCd(batchOvertimeAnaArr[1]);
    				vo.setErrorTime(batchOvertimeAnaArr[2]);
    				vo.setJobDesc(batchOvertimeAnaArr[3]);
    				vo.setOvertimeFlag(batchOvertimeAnaArr[4]);
    				vo.setCapaRiskType(batchOvertimeAnaArr[5]);
    				vo.setJobEffect(batchOvertimeAnaArr[6]);
    				vo.setErrorCauseAna(batchOvertimeAnaArr[7]);
    				
    				inputFileList.add(vo);
    			}
    			if(reader != null){
    				reader.close();
    			}
        	}
		}
		return inputFileList;
	}
	
	/**
	 * 检查上传批量超时事件分析表信息每条记录值的合法性
	 * @param String[] batchOvertimeAnaArr
	 * @param int rowNumber
	 * @param HttpServletRequest
	 * @throws Exception
	 */
	public void CheckData(String[] batchOvertimeAnaArr, StringBuilder stdErr, int rowNumber, HttpServletRequest request, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		
		if(!primaryKeyCheckList.contains(batchOvertimeAnaArr[0])){
			primaryKeyCheckList.add(batchOvertimeAnaArr[0]);
		}else{
			errMsg.append("存在主键重复数据,主键=[" + batchOvertimeAnaArr[0] + "]");
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

	
}///~:

package com.nantian.rept.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
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
import com.nantian.rept.vo.TypicalCapaAnaVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class TypicalCapaAnaService {

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
	public TypicalCapaAnaService() {
		fields.put("sysseqnum", FieldType.STRING);
		fields.put("appSysCd", FieldType.STRING);
		fields.put("errorTime", FieldType.STRING);
		fields.put("riskType", FieldType.STRING);
		fields.put("workorderSubject", FieldType.STRING);
		fields.put("caseCause", FieldType.STRING);
		fields.put("handleMethod", FieldType.STRING);
		fields.put("optimizePlan", FieldType.STRING);
		fields.put("caseAna", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param typicalCapaAnaVo
	 */
	@Transactional(value="maoprpt")
	public void save(TypicalCapaAnaVo typicalCapaAnaVo) {
		getSession().save(typicalCapaAnaVo);
	}

	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(TypicalCapaAnaVo typicalCapaAnaVo) {
		getSession().update(typicalCapaAnaVo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param typicalCapaAnaVos
	 */
	@Transactional(value="maoprpt")
	public void save(Set<TypicalCapaAnaVo> typicalCapaAnaVos) {
		for (TypicalCapaAnaVo typicalCapaAnaVo : typicalCapaAnaVos) {
			getSession().save(typicalCapaAnaVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param typicalCapaAnaVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<TypicalCapaAnaVo> typicalCapaAnaVos) {
		for (TypicalCapaAnaVo typicalCapaAnaVo : typicalCapaAnaVos) {
			getSession().saveOrUpdate(typicalCapaAnaVo);
		}
	}
	
	/**
	 * 根据主键查询.
	 * 
	 * @param id
	 *            主键
	 * @return
	 */
	public Object get(Serializable sysseqnum) {
		return getSession().get(TypicalCapaAnaVo.class, sysseqnum);
	}

	/**
	 * 删除.
	 * @param typicalCapaAnaVo
	 */
	@Transactional(value="maoprpt")
	public void delete(TypicalCapaAnaVo typicalCapaAnaVo) {
		getSession().delete(typicalCapaAnaVo);
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String jobName) {
		getSession().createQuery("delete from TypicalCapaAnaVo t where t.sysseqnum=?")
				.setString(0, jobName)
			.executeUpdate();
	}
	
	/**
	 * 根据ID批量删除.
	 * @param sysseqnums
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] sysseqnums) {
		for(int i = 0; i < sysseqnums.length; i++){
			deleteById(sysseqnums[i]);
		}
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
			.append(" select t.sysseqnum as \"sysseqnum\", ")
			.append("         	l.sysname as \"sysName\", ")
			.append(" 			t.appsyscd as \"appSysCd\", ")
			.append(" 			to_char(to_date(t.error_time,'yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss') as \"errorTime\", ")
			.append(" 			t.risk_type as \"riskType\", ")
			.append(" 			t.workorder_subject as \"workorderSubject\", ")
			.append(" 			t.case_cause as \"caseCause\", ")
			.append(" 			t.handle_method as \"handleMethod\", ")
			.append("			t.optimize_plan as \"optimizePlan\", ")
			.append("			t.case_ana as \"caseAna\" ")
			.append("from TYPICAL_CAPA_ANA t, LIEBIAO l where t.appsyscd = substr(l.id,5) ) o where 1 = 1 ");

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
		hql.append("select count(*) from TypicalCapaAnaVo t where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and t." + key + " like :" + key);
					} else {
						hql.append(" and t." + key + " = :" + key);
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
	public List<TypicalCapaAnaVo> readTypicalCapaAnaFromFile(String filePath,HttpServletRequest request) throws Exception {
		List<TypicalCapaAnaVo> inputFileList = new ArrayList<TypicalCapaAnaVo>();
		List<String> primaryKeyCheckList = new ArrayList<String>();
		TypicalCapaAnaVo vo = null;
		String typicalCapaAnaStr = "";
		String[] typicalCapaAnaArr = new String[Constants.TYPICAL_CAPA_ANA_COLUMNS];
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
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				
				//行号计数
				++rowNumber;
				//上传文件的进度保存到Session, 以便启动校验文件信息的进度条
				request.getSession().setAttribute("importTranInfoPercentage", percentage);
				
				//行的长度Check
				if(typicalCapaAnaArr.length != Constants.TYPICAL_CAPA_ANA_COLUMNS){
					stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
					stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.TYPICAL_CAPA_ANA_COLUMNS)}));
					stdErr.append("<br>");
					continue;
				}
				//校验容量预警时间表的有效性
				CheckData(typicalCapaAnaArr, stdErr, rowNumber, request,primaryKeyCheckList);
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
    			while((typicalCapaAnaStr = reader.readLine()) != null){
    				//拆分数据
    				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
    				
    				vo = new TypicalCapaAnaVo();
    				vo.setSysseqnum(typicalCapaAnaArr[0]);
    				vo.setAppSysCd(typicalCapaAnaArr[1]);
    				vo.setErrorTime(typicalCapaAnaArr[2]);
    				vo.setRiskType(typicalCapaAnaArr[3]);
    				vo.setWorkorderSubject(typicalCapaAnaArr[4]);
    				vo.setCaseCause(typicalCapaAnaArr[5]);
    				vo.setHandleMethod(typicalCapaAnaArr[6]);
    				vo.setOptimizePlan(typicalCapaAnaArr[7]);
    				vo.setCaseAna(typicalCapaAnaArr[8]);
    				
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
	 * @param String[] typicalCapaAnaArr
	 * @param int rowNumber
	 * @param HttpServletRequest
	 * @throws Exception
	 */
	public void CheckData(String[] typicalCapaAnaArr, StringBuilder stdErr, int rowNumber, HttpServletRequest request, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		
		if(!primaryKeyCheckList.contains(typicalCapaAnaArr[0])){
			primaryKeyCheckList.add(typicalCapaAnaArr[0]);
		}else{
			errMsg.append("存在主键重复数据,主键=[" + typicalCapaAnaArr[0] + "]");
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
	 * 通过主键查找唯一的一条记录
	 * @param sysseqnum 任务名
	 * @return TypicalCapaAnaVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public TypicalCapaAnaVo findByPrimaryKey(String sysseqnum){
		return (TypicalCapaAnaVo) getSession()
				.createQuery("from TypicalCapaAnaVo t where t.sysseqnum=:sysseqnum")
				.setString("sysseqnum", sysseqnum)
				.uniqueResult();
	}
	
}///~:

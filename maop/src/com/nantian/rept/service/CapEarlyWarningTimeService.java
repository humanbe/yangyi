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

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.CapEarlyWarningTimeVo;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class CapEarlyWarningTimeService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(CapEarlyWarningTimeService.class);

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
	public CapEarlyWarningTimeService() {
		fields.put("aplCode", FieldType.STRING);
		fields.put("busiKeyDate", FieldType.STRING);
		fields.put("summaryDesc", FieldType.STRING);
		fields.put("riskDesc", FieldType.STRING);
		fields.put("handleMethod", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(CapEarlyWarningTimeVo capEarlyWarningTimeVo) {
		getSession().save(capEarlyWarningTimeVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(CapEarlyWarningTimeVo capEarlyWarningTimeVo) {
		getSession().update(capEarlyWarningTimeVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<CapEarlyWarningTimeVo> capEarlyWarningTimeVos) {
		for (CapEarlyWarningTimeVo capEarlyWarningTimeVo : capEarlyWarningTimeVos) {
			getSession().save(capEarlyWarningTimeVo);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param capEarlyWarningTimeVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<CapEarlyWarningTimeVo> capEarlyWarningTimeVos) {
		for (CapEarlyWarningTimeVo capEarlyWarningTimeVo : capEarlyWarningTimeVos) {
			getSession().saveOrUpdate(capEarlyWarningTimeVo);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param capEarlyWarningTimeVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(CapEarlyWarningTimeVo capEarlyWarningTimeVo) {
			getSession().saveOrUpdate(capEarlyWarningTimeVo);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param aplCode 应用系统编号
	 * @param busiKeyDate 业务关键日期
	 * @return ServerConfVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public CapEarlyWarningTimeVo findByPrimaryKey(String aplCode,String busiKeyDate){
		return (CapEarlyWarningTimeVo) getSession()
				.createQuery("from CapEarlyWarningTimeVo c where c.aplCode=:aplCode and c.busiKeyDate=:busiKeyDate ")
				.setString("aplCode", aplCode)
				.setString("busiKeyDate", busiKeyDate)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(CapEarlyWarningTimeVo capEarlyWarningTimeVo) {
		getSession().delete(capEarlyWarningTimeVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param aplCodes
	 * @param busiKeyDates
	 */
	@Transactional("maoprpt")
	public void deleteByUnionKeys(String[] aplCodes,String[] busiKeyDates) {
		for(int i = 0; i < aplCodes.length; i++){
			deleteById(aplCodes[i],busiKeyDates[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode,String busiKeyDate) {
		getSession().createQuery("delete from CapEarlyWarningTimeVo c where c.aplCode=? and c.busiKeyDate=? ")
				.setString(0, aplCode)
				.setString(1, busiKeyDate)
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
			.append(" select c.apl_code as \"aplCode\", ")
			.append("         	l.sysname as \"sysName\", ")
			.append(" 			to_char(to_date(c.busi_key_date,'yyyyMMdd'),'yyyyMMdd') as \"busiKeyDate\", ")
			.append(" 			c.summary_desc as \"summaryDesc\", ")
			.append(" 			c.risk_desc as \"riskDesc\", ")
			.append("			c.handle_tactics as \"handleTactics\" ")
			.append("from CAP_EARLY_WARNING_TIME c, LIEBIAO l where c.apl_code = substr(l.id,5) ) o where 1 = 1 ");

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
		hql.append("select count(*) from CapEarlyWarningTimeVo c where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and c." + key + " like :" + key);
					} else {
						hql.append(" and c." + key + " = :" + key);
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
	 * 查询应用系统所有的编号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object querySystemIDAndNames(){
		return getSession().createQuery("select new map(substr(s.sysId,5) as sysId, s.sysName as sysName) from SystemInfoVo s order by s.sysId").list();
	}
	
	/**
	 * 从文件读取交易信息并返回信息集合
	 * @param filePath 文件路径
	 * @param request
	 * @return Set<CapEarlyWarningTimeVo> 交易信息集合
	 * @throws Exception
	 */
	public List<CapEarlyWarningTimeVo> readCapEarlyWarnFromFile(String filePath,HttpServletRequest request) throws Exception {
		List<CapEarlyWarningTimeVo> inputFileList = new ArrayList<CapEarlyWarningTimeVo>();
		List<String> primaryKeyCheckList = new ArrayList<String>();
		CapEarlyWarningTimeVo vo = null;
		String capEarlyWarnStr = "";
		String[] capEarlyWarnArr = new String[Constants.CAP_EARLY_WARNING_TIME_COLUMNS];
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
			while((capEarlyWarnStr = reader.readLine()) != null){
				//拆分数据
				capEarlyWarnArr = capEarlyWarnStr.split(Constants.SPLIT_SEPARATEOR, -1);
				
				//行号计数
				++rowNumber;
				//上传文件的进度保存到Session, 以便启动校验文件信息的进度条
				request.getSession().setAttribute("importTranInfoPercentage", percentage);
				
				//行的长度Check
				if(capEarlyWarnArr.length != Constants.CAP_EARLY_WARNING_TIME_COLUMNS){
					stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
					stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(Constants.CAP_EARLY_WARNING_TIME_COLUMNS)}));
					stdErr.append("<br>");
					continue;
				}
				//校验容量预警时间表的有效性
				CheckData(capEarlyWarnArr, stdErr, rowNumber, request,primaryKeyCheckList);
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
    			while((capEarlyWarnStr = reader.readLine()) != null){
    				//拆分数据
    				capEarlyWarnArr = capEarlyWarnStr.split(Constants.SPLIT_SEPARATEOR, -1);
    				
    				vo = new CapEarlyWarningTimeVo();
    				vo.setAplCode(capEarlyWarnArr[0]);
    				vo.setBusiKeyDate(capEarlyWarnArr[1]);
    				vo.setSummaryDesc(capEarlyWarnArr[2]);
    				vo.setRiskDesc(capEarlyWarnArr[3]);
    				vo.setHandleTactics(capEarlyWarnArr[4]);
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
	 * 检查上传容量预警时间表信息每条记录值的合法性
	 * @param String[] capEarlyWarnArr
	 * @param int rowNumber
	 * @param HttpServletRequest
	 * @throws Exception
	 */
	public void CheckData(String[] capEarlyWarnArr, StringBuilder stdErr, int rowNumber, HttpServletRequest request, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		StringBuilder primaryKey = new StringBuilder();
		
		primaryKey.append(capEarlyWarnArr[0]+","+capEarlyWarnArr[1]);
		if(!primaryKeyCheckList.contains(primaryKey.toString())){
			primaryKeyCheckList.add(primaryKey.toString());
		}else{
			errMsg.append("存在主键重复数据,主键=[" + primaryKey.toString() + "]");
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

	
	
}///:~

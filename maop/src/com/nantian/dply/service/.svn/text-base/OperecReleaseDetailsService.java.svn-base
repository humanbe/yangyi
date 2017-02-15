package com.nantian.dply.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.CommonConst;
import com.nantian.component.log.Logger;
import com.nantian.dply.vo.OperecReleaseDetailsVo;
import com.nantian.jeda.FieldType;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class OperecReleaseDetailsService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(OperecReleaseDetailsService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法	 */
	public OperecReleaseDetailsService() {
		fields.put("functionId", FieldType.STRING);
		fields.put("execYmdhmsf", FieldType.STRING);
		fields.put("procomInputFile", FieldType.STRING);
		fields.put("jobCode", FieldType.INTEGER);
		fields.put("execStep", FieldType.INTEGER);
		fields.put("resourceId", FieldType.STRING);
		fields.put("resourcePath", FieldType.INTEGER);
		fields.put("targetIp", FieldType.STRING);
		fields.put("targetEnvId", FieldType.STRING);
		fields.put("execResultStatus", FieldType.STRING);
		fields.put("execMessage", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
		fields.put("reserve2", FieldType.STRING);
		fields.put("reserve3", FieldType.STRING);
		fields.put("reserve4", FieldType.STRING);
		fields.put("reserve5", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(OperecReleaseDetailsVo operecReleaseDetails) {
		getSession().save(operecReleaseDetails);
	}
	
	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void update(OperecReleaseDetailsVo operecReleaseDetails) {
		getSession().update(operecReleaseDetails);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(Set<OperecReleaseDetailsVo> operecReleaseDetailss) {
		for (OperecReleaseDetailsVo operecReleaseDetails : operecReleaseDetailss) {
			getSession().save(operecReleaseDetails);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * 
	 * @param operecSourceDetails
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(List<OperecReleaseDetailsVo> operecReleaseDetailss) {
		for (OperecReleaseDetailsVo operecReleaseDetails : operecReleaseDetailss) {
			getSession().saveOrUpdate(operecReleaseDetails);
		}
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param functionId 功能ID
	 * @param execYmdhmsf 执行年月日时分毫秒	 * @param procomInputFile 处理完成输入文件
	 * @param jobCode 任务编号
	 * @return OperationRecordVo 实体
	 */
	@Transactional(value="dply",propagation=Propagation.NOT_SUPPORTED)
	public OperecReleaseDetailsVo findByUnionKey(String functionId, String execYmdhmsf, String procomInputFile,String jobCode){
		return (OperecReleaseDetailsVo) getSession().createQuery("from OperecReleaseDetailsVo or where or.functionId = :functionId and or.execYmdhmsf = :execYmdhmsf and or.procomInputFile = :procomInputFile and or.jobCode = :jobCode ")
														 .setString("functionId", functionId)
														 .setString("execYmdhmsf", execYmdhmsf)
														 .setString("procomInputFile", procomInputFile)
														 .setString("jobCode", jobCode)
														 .uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional(value="dply")
	public void delete(OperecReleaseDetailsVo operecReleaseDetails) {
		getSession().delete(operecReleaseDetails);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional(value="dply")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[4];
		for (String key : primaryKeys) {
			keyArr = key.split(CommonConst.STRING_COMMA);
			deleteById(keyArr[0],keyArr[1],keyArr[2],keyArr[3]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String functionId, String execYmdhmsf, String procomInputFile, String jobCode) {
		getSession().createQuery("delete from OperecReleaseDetailsVo or where or.functionId=? and or.execYmdhmsf=? and or.procomInputFile=? and or.jobCode=? ")
			.setString(0, functionId)
			.setString(1, execYmdhmsf)
			.setString(2, procomInputFile)
			.setString(3, jobCode)
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
	@Transactional(value="dply",propagation=Propagation.NOT_SUPPORTED)
	public List<OperecReleaseDetailsVo> queryAll(String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from OperecReleaseDetailsVo or where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and or." + key + " like :" + key);
				} else {
					hql.append(" and or." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by or." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	
}///:~

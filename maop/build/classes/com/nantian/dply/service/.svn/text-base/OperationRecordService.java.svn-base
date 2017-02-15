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
import com.nantian.dply.vo.OperationRecordVo;
import com.nantian.jeda.FieldType;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class OperationRecordService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(OperationRecordService.class);

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
	public OperationRecordService() {
		fields.put("functionId", FieldType.STRING);
		fields.put("execYmdhmsf", FieldType.STRING);
		fields.put("procomInputFile", FieldType.STRING);
		fields.put("fileType", FieldType.STRING);
		fields.put("execUserId", FieldType.INTEGER);
		fields.put("entryId", FieldType.STRING);
		fields.put("clientInputFileName", FieldType.INTEGER);
		fields.put("serverInputFilePath", FieldType.STRING);
		fields.put("serverInputFileName", FieldType.STRING);
		fields.put("resultOutputFilePath", FieldType.STRING);
		fields.put("resultOutputFileName", FieldType.STRING);
		fields.put("resultGetFlag", FieldType.STRING);
		fields.put("execResultStatus", FieldType.STRING);
		fields.put("execStartYmdhms", FieldType.STRING);
		fields.put("execEndYmdhms", FieldType.STRING);
		fields.put("reserve1", FieldType.STRING);
		fields.put("reserve2", FieldType.STRING);
		fields.put("reserve3", FieldType.STRING);
		fields.put("reserve4", FieldType.STRING);
		fields.put("reserve5", FieldType.STRING);
		fields.put("deleteFlag", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(OperationRecordVo operationRecord) {
		getSession().save(operationRecord);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="dply")
	public void update(OperationRecordVo operationRecord) {
		getSession().update(operationRecord);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(Set<OperationRecordVo> operationRecords) {
		for (OperationRecordVo operationRecord : operationRecords) {
			getSession().save(operationRecord);
		}
	}
	
	/**
	 * 批量保存或者更新
	 * @param operationRecords
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(List<OperationRecordVo> operationRecords) {
		for (OperationRecordVo operationRecord : operationRecords) {
			getSession().saveOrUpdate(operationRecord);
		}
	}
	
	/**
	 * 保存或者更新
	 * @param operationRecord
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(OperationRecordVo operationRecord) {
			getSession().saveOrUpdate(operationRecord);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param functionId 功能ID
	 * @param execYmdhmsf 执行年月日时分毫秒	 * @param procomInputFile 处理完成输入文件
	 * @return OperationRecordVo 实体
	 */
	@Transactional(value = "dply", propagation=Propagation.NOT_SUPPORTED)
	public OperationRecordVo findByUnionKey(String functionId, String execYmdhmsf, String procomInputFile){
		return (OperationRecordVo) getSession()
				.createQuery("from OperationRecordVo o where o.functionId = :functionId and o.execYmdhmsf = :execYmdhmsf and o.procomInputFile = :procomInputFile ")
				.setString("functionId", functionId)
				.setString("execYmdhmsf", execYmdhmsf)
				.setString("procomInputFile", procomInputFile)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("dply")
	public void delete(OperationRecordVo operationRecord) {
		getSession().delete(operationRecord);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("dply")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[3];
		for (String key : primaryKeys) {
			keyArr = key.split(CommonConst.STRING_COMMA);
			deleteById(keyArr[0],keyArr[1],keyArr[2]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String functionId, String execYmdhmsf, String procomInputFile) {
		getSession().createQuery("delete from OperationRecordVo o where o.functionId=? and o.execYmdhmsf=? and o.procomInputFile=?")
			.setString(0, functionId)
			.setString(1, execYmdhmsf)
			.setString(2, procomInputFile)
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
	public List<OperationRecordVo> queryAll(String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from OperationRecordVo o where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and o." + key + " like :" + key);
				} else {
					hql.append(" and o." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by o." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	
}///:~

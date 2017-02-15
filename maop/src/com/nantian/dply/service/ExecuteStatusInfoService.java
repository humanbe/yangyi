/**
 * Copyright 2012 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.service;

import java.io.Serializable;
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
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.dply.vo.ExecuteStatusInfoVo;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ExecuteStatusInfoService {
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ExecuteStatusInfoService.class);

	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 构造方法
	 */
	public ExecuteStatusInfoService() {
		fields.put("entryId", FieldType.STRING);
		fields.put("userId", FieldType.STRING);
		fields.put("queueName", FieldType.STRING);
		fields.put("className", FieldType.STRING);
		fields.put("method", FieldType.INTEGER);
		fields.put("executePlanTime", FieldType.STRING);
		fields.put("executeStartTime", FieldType.INTEGER);
		fields.put("executeEndTime", FieldType.STRING);
		fields.put("jobStatus", FieldType.STRING);
		fields.put("aplStatus", FieldType.STRING);
		fields.put("uploadFileClientName", FieldType.STRING);
		fields.put("uploadFileTmpName", FieldType.STRING);
		fields.put("uploadFileRecordCount", FieldType.INTEGER);
		fields.put("loginTime", FieldType.STRING);
		fields.put("modifyTime", FieldType.STRING);
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
	 * @param executeStatusInfo
	 */
	@Transactional
	public void save(ExecuteStatusInfoVo executeStatusInfo) {
		getSession().save(executeStatusInfo);
	}

	/**
	 * 更新.
	 * 
	 * @param executeStatusInfo
	 */
	@Transactional
	public void update(ExecuteStatusInfoVo executeStatusInfo) {
		getSession().update(executeStatusInfo);
	}

	/**
	 * 批量保存.
	 * 
	 * @param executeStatusInfos
	 */
	@Transactional
	public void save(Set<ExecuteStatusInfoVo> executeStatusInfos) {
		for (ExecuteStatusInfoVo executeStatusInfo : executeStatusInfos) {
			getSession().save(executeStatusInfo);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * 
	 * @param executeStatusInfos
	 */
	@Transactional
	public void saveOrUpdate(List<ExecuteStatusInfoVo> executeStatusInfos) {
		for (ExecuteStatusInfoVo executeStatusInfo : executeStatusInfos) {
			getSession().saveOrUpdate(executeStatusInfo);
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
	public Object get(Serializable entryId) {
		return getSession().get(ExecuteStatusInfoVo.class, entryId);
	}

	/**
	 * 删除.
	 * 
	 * @param customer
	 */
	@Transactional
	public void delete(ExecuteStatusInfoVo executeStatusInfo) {
		getSession().delete(executeStatusInfo);
	}
	
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

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
		 	.append("des.entryId as entryId,")
		 	.append("des.userId as userId,")
		 	.append("des.queueName as queueName,")
		 	.append("des.className as className,")
		 	.append("des.method as method,")
		 	.append("des.executePlanTime as executePlanTime,")
		 	.append("des.executeStartTime as executeStartTime,")
		 	.append("des.executeEndTime as executeEndTime,")
		 	.append("des.jobStatus as jobStatus, ")
		 	.append("des.aplStatus as aplStatus, ")
		 	.append("des.uploadFileClientName as uploadFileClientName, ")
		 	.append("des.uploadFileTmpName as uploadFileTmpName, ")
		 	.append("des.uploadFileRecordCount as uploadFileRecordCount, ")
		 	.append("des.loginTime as loginTime, ")
		 	.append("des.modifyTime as modifyTime, ")
		 	.append("des.reserve1 as reserve1, ")
		 	.append("des.reserve2 as reserve2, ")
		 	.append("des.reserve3 as reserve3, ")
		 	.append("des.reserve4 as reserve4, ")
		 	.append("des.reserve5 as reserve5, ")
		 	.append("des.deleteFlag as deleteFlag, ")
		 	.append(") from ExecuteStatusInfoVo des where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and des." + key + " like :" + key);
				} else {
					hql.append(" and des." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by des." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

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
		hql.append("select count(*) from ExecuteStatusInfoVo des where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and des." + key + " like :" + key);
				} else {
					hql.append(" and des." + key + " = :" + key);
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
	 * 根据ID查询.
	 * 
	 * @param hostip
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String entryId) {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
	 		.append("des.entryId as entryId,")
	 		.append("des.userId as userId,")
	 		.append("des.queueName as queueName,")
	 		.append("des.className as className,")
	 		.append("des.method as method,")
	 		.append("des.executePlanTime as executePlanTime,")
	 		.append("des.executeStartTime as executeStartTime,")
	 		.append("des.executeEndTime as executeEndTime,")
	 		.append("des.jobStatus as jobStatus, ")
	 		.append("des.aplStatus as aplStatus, ")
	 		.append("des.uploadFileClientName as uploadFileClientName, ")
	 		.append("des.uploadFileTmpName as uploadFileTmpName, ")
	 		.append("des.uploadFileRecordCount as uploadFileRecordCount, ")
	 		.append("des.loginTime as loginTime, ")
	 		.append("des.modifyTime as modifyTime, ")
	 		.append("des.functionId as functionId, ")
	 		.append("des.afterFilePath as afterFilePath, ")
	 		.append("des.reserve1 as reserve1, ")
	 		.append("des.reserve2 as reserve2, ")
	 		.append("des.reserve3 as reserve3, ")
	 		.append("des.reserve4 as reserve4, ")
	 		.append("des.reserve5 as reserve5, ")
	 		.append("des.deleteFlag as deleteFlag ")
	 		.append(") from ExecuteStatusInfoVo des where des.entryId =? and (des.deleteFlag = '0' or des.deleteFlag is null) ");

		return getSession().createQuery(hql.toString())
				.setString(0, entryId).uniqueResult();

	}
	
	/**
	 * 根据ID删除.
	 * 
	 * @param id
	 */
	private void deleteById(String entryId) {
		getSession().createQuery("delete from ExecuteStatusInfoVo des where ds.entryId = ?")
			.setString(0, entryId).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
	 * 
	 * @param ids
	 */
	@Transactional
	public void deleteByIds(String[] entryIds) {
		for (String entryId : entryIds) {
			deleteById(entryId);
		}
	}
	

}///:~

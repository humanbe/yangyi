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
import com.nantian.dply.vo.OperecSourceDetailsVo;
import com.nantian.jeda.FieldType;

/**
 * @author donghui
 *
 */
@Service
@Repository
public class OperecSourceDetailsService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(OperecSourceDetailsService.class);

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
	public OperecSourceDetailsService() {
		fields.put("functionId", FieldType.STRING);
		fields.put("execYmdhmsf", FieldType.STRING);
		fields.put("procomInputFile", FieldType.STRING);
		fields.put("seqNo", FieldType.INTEGER);
		fields.put("appsysCode", FieldType.INTEGER);
		fields.put("subAppsysCode", FieldType.STRING);
		fields.put("resourceId", FieldType.INTEGER);
		fields.put("resourcePath", FieldType.STRING);
		fields.put("recordMessage", FieldType.STRING);
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
	public void save(OperecSourceDetailsVo operecSourceDetails) {
		getSession().save(operecSourceDetails);
	}
	
	/**
	 * 更新.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void update(OperecSourceDetailsVo operecSourceDetails) {
		getSession().update(operecSourceDetails);
	}

	/**
	 * 批量保存.
	 * 
	 * @param customer
	 */
	@Transactional(value="dply")
	public void save(Set<OperecSourceDetailsVo> operecSourceDetailss) {
		for (OperecSourceDetailsVo operecSourceDetails : operecSourceDetailss) {
			getSession().save(operecSourceDetails);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * @param operecSourceDetails
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(List<OperecSourceDetailsVo> operecSourceDetailss) {
		for (OperecSourceDetailsVo operecSourceDetails : operecSourceDetailss) {
			getSession().saveOrUpdate(operecSourceDetails);
		}
	}
	
	/**
	 * 批量保存或者更新(
	 * @param operecSourceDetails
	 */
	@Transactional(value="dply")
	public void saveOrUpdate(OperecSourceDetailsVo operecSourceDetails) {
			getSession().saveOrUpdate(operecSourceDetails);
	}

	/**
	 * 通过主键查找唯一的一条记录	 * @param functionId 功能ID
	 * @param execYmdhmsf 执行年月日时分毫秒	 * @param procomInputFile 处理完成输入文件
	 * @param seqNo 序列号
	 * @return OperationRecordVo 实体
	 */
	@Transactional(value="dply",propagation=Propagation.NOT_SUPPORTED)
	public OperecSourceDetailsVo findByUnionKey(String functionId, String execYmdhmsf, String procomInputFile,int seqNo){
		return (OperecSourceDetailsVo) getSession().createQuery("from OperecSourceDetailsVo os where os.functionId = :functionId and os.execYmdhmsf = :execYmdhmsf and os.procomInputFile = :procomInputFile and os.seqNo = :seqNo ")
														 .setString("functionId", functionId)
														 .setString("execYmdhmsf", execYmdhmsf)
														 .setString("procomInputFile", procomInputFile)
														 .setInteger("seqNo", seqNo)
														 .uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional(value="dply")
	public void delete(OperecSourceDetailsVo operecSourceDetails) {
		getSession().delete(operecSourceDetails);
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
			deleteById(keyArr[0],keyArr[1],keyArr[2],Integer.valueOf(keyArr[3]));
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String functionId, String execYmdhmsf, String procomInputFile, int seqNo) {
		getSession().createQuery("delete from OperecSourceDetailsVo o where o.functionId=? and o.execYmdhmsf=? and o.procomInputFile=? and os.seqNo=? ")
			.setString(0, functionId)
			.setString(1, execYmdhmsf)
			.setString(2, procomInputFile)
			.setInteger(3, seqNo)
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
	public List<OperecSourceDetailsVo> queryAll(String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from OperecSourceDetailsVo os where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and os." + key + " like :" + key);
				} else {
					hql.append(" and os." + key + " = :" + key);
				}
			}
		}
		 hql.append(" order by os." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}
	
	
}///:~

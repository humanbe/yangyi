package com.nantian.jeda.config.service;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.config.vo.sboxInfoVo;

@Service
@Repository
@Transactional
public class SBoxService {
	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(SBoxService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	/**
	 * 构造方法

	 */
	public SBoxService() {
		fields.put("sbox_id", FieldType.INTEGER);
		fields.put("sbox_initiator", FieldType.STRING);
		fields.put("sbox_value", FieldType.STRING);
		fields.put("sbox_time", FieldType.TIMESTAMP);
		fields.put("sbox_statenum", FieldType.STRING);
		fields.put("sbox_confirm_user", FieldType.STRING);
		fields.put("sbox_confirm_time", FieldType.TIMESTAMP);
		fields.put("sbox_reject_user", FieldType.STRING);
		fields.put("sbox_reject_time", FieldType.TIMESTAMP);
	}
	
	
	/**
	 * 保存添加数据.
	 * 
	 */
	@Transactional
	public void save(sboxInfoVo sboxInfo) {
		getSession().save(sboxInfo);
	}
	/**
	 * 查询数据库中所有sboxInfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<sboxInfoVo> queryAllSBoxInfo() throws SQLException{
		return getSession().createQuery("from sboxInfoVo ft").list();
	}
	
	/**
	 * 查找被选中的所有SBoxInfo信息
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryAllSBoxInfo(Integer sbox_id) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ft.sbox_id as sbox_id,");
		hql.append("ft.sbox_initiator as sbox_initiator,");
		hql.append("ft.sbox_value as sbox_value,");
		hql.append("to_char(ft.sbox_time,'yyyy-mm-dd hh24:mi:ss') as sbox_time,");
		hql.append("case when ft.sbox_statenum='1' then '提交'");
		hql.append(" when ft.sbox_statenum='2' then '确认'");
		hql.append(" when ft.sbox_statenum='3' then '发布'");
		hql.append(" when ft.sbox_statenum='4' then '驳回'");
		hql.append(" end as sbox_statenum ,");
		hql.append("ft.sbox_confirm_user as sbox_confirm_user,");
		hql.append("to_char(ft.sbox_confirm_time,'yyyy-mm-dd hh24:mi:ss') as sbox_confirm_time,");
		hql.append("ft.sbox_reject_user as sbox_reject_user,");
		hql.append("to_char(ft.sbox_reject_time,'yyyy-mm-dd hh24:mi:ss') as sbox_reject_time");
		hql.append(")from sboxInfoVo ft  where ft.sbox_id =?  ");
		return  getSession().createQuery(hql.toString()).setInteger(0,sbox_id).uniqueResult();
	}
	
	/**
	 * 查询数据库中SBoxInfo信息
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> querySBoxInfo(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,HttpServletRequest request)throws SQLException {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("ft.sbox_id as sbox_id,");
		hql.append("ft.sbox_initiator as sbox_initiator,");
		hql.append("ft.sbox_value as sbox_value,");
		hql.append("to_char(ft.sbox_time,'yyyy-mm-dd hh24:mi:ss') as sbox_time,");
		hql.append("case when ft.sbox_statenum='1' then '提交'");
		hql.append(" when ft.sbox_statenum='2' then '确认'");
		hql.append(" when ft.sbox_statenum='3' then '发布'");
		hql.append(" when ft.sbox_statenum='4' then '驳回'");
		hql.append(" end as sbox_statenum ,");
		hql.append("ft.sbox_confirm_user as sbox_confirm_user,");
		hql.append("to_char(ft.sbox_confirm_time,'yyyy-mm-dd hh24:mi:ss') as sbox_confirm_time,");
		hql.append("ft.sbox_reject_user as sbox_reject_user,");
		hql.append("to_char(ft.sbox_reject_time,'yyyy-mm-dd hh24:mi:ss') as sbox_reject_time");
		hql.append(")from sboxInfoVo ft  where 1=1  ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ft." + key + " like :" + key);
				} else {
					hql.append(" and ft." + key + " = :" + key);
				}
			}
		}else{
			
		}
	    hql.append(" order by ft.sbox_statenum asc ,ft.sbox_time desc");
	    Query query = getSession().createQuery(hql.toString());
	    if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
	    request.getSession().setAttribute("sboxInfoListExport", query.list());
		query = query.setFirstResult(start).setMaxResults(limit);		
		return query.list();
	}
	

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params)throws SQLException  {
 
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct count(*) from  sboxInfoVo ft where 1=1 "); 
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and ft." + key + " like :" + key);
				} else {
					hql.append(" and ft." + key + " = :" + key);
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
	 * 批量修改意见箱状态
	 * @param sbox_ids
	 * @param state_id
	 * @throws SQLException 
	 */
	@Transactional
	public void sboxState(String[] sbox_ids,String state_id,Timestamp updateTime,String user) throws SQLException {
		for (int i = 0; i < sbox_ids.length ; i++) {	
			this.sboxStateById(state_id,sbox_ids[i],updateTime,user);	
		}
	}
	/**
	 * 修改意见箱状态
	 * @param sbox_id
	 * @param state
	 */
	
	public void sboxStateById(String state_id,String sbox_id,Timestamp updateTime,String user)throws SQLException {
		if(state_id.equals("1")==true) {
			getSession().createQuery(
					"update  sboxInfoVo ta set ta.sbox_statenum=?,ta.sbox_initiator=?,ta.sbox_time=?,ta.sbox_confirm_user=''," +
					"ta.sbox_confirm_time='',ta.sbox_reject_user='',ta.sbox_reject_time='' where ta.sbox_id = ? ")
				.setString(0, state_id).setString(1,user).setTimestamp(2,updateTime).setString(3, sbox_id)
				.executeUpdate();
		}
		if(state_id.equals("2")==true) {
			getSession().createQuery(
					  "update  sboxInfoVo ta set ta.sbox_statenum=?,ta.sbox_confirm_user=?,ta.sbox_confirm_time=? where ta.sbox_id = ? ")
					.setString(0, state_id).setString(1, user).setTimestamp(2, updateTime).setString(3,sbox_id)
					.executeUpdate();
			}
		if(state_id.equals("3")==true) {
			getSession().createQuery(
					"update  sboxInfoVo ta set ta.sbox_statenum=?  where ta.sbox_id = ? ")
			.setString(0, state_id).setString(1, sbox_id)
			.executeUpdate();
		}
		if(state_id.equals("4")==true) {
			getSession().createQuery(
					  "update  sboxInfoVo ta set ta.sbox_statenum=?,ta.sbox_reject_user=?,ta.sbox_reject_time=? where ta.sbox_id = ? ")
					.setString(0, state_id).setString(1, user).setTimestamp(2, updateTime).setString(3,sbox_id)
					.executeUpdate();
		}
	}
	
	

}

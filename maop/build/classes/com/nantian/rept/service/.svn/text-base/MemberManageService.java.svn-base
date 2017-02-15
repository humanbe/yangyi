package com.nantian.rept.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.MemberVo;

@Service
@Repository
@Transactional
public class MemberManageService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	
	private Session getSession(){
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	public MemberManageService(){
		fields.put("userId", FieldType.STRING);
		fields.put("userName", FieldType.STRING);
		fields.put("sex", FieldType.STRING);
		fields.put("mobile", FieldType.STRING);
		fields.put("phone", FieldType.STRING);
		fields.put("otherContact", FieldType.STRING);
		fields.put("email", FieldType.STRING);
		fields.put("serilNo", FieldType.STRING);
		fields.put("groupName", FieldType.STRING);
		fields.put("teamName", FieldType.STRING);
		fields.put("outSourcingFlag", FieldType.STRING);
	}
	
	/**
	 * 根据主键查询.
	 * @param userId
	 * @return
	 */
	public Object get(Serializable userId){
		return getSession().get(MemberVo.class, userId);
	}
	
	/**
	 * 更新.
	 * @param vo
	 */
	public void update(MemberVo vo){
		getSession().update(vo);
	}

	/**
	 * 查询人员信息列表
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @param request 请求对象
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> queryMemberList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params, HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(")
			.append("	m.userId as userId, ")
			.append("	m.userName as userName, ")
			.append("	m.sex as sex, ")
			.append("	m.mobile as mobile, ")
			.append("	m.phone as phone, ")
			.append("	m.otherContact as otherContact, ")
			.append("	m.email as email, ")
			.append("	m.serilNo as serilNo, ")
			.append("	m.groupName as groupName, ")
			.append("	m.teamName as teamName, ")
			.append("	m.outSourcingFlag as outSourcingFlag) ")
			.append("from MemberVo m where 1=1 ");
		
		for(String key : params.keySet()){
			if (fields.get(key).equals(FieldType.STRING)) {
				hql.append(" and m." + key + " like :" + key);
			} else {
				hql.append(" and m." + key + " = :" + key);
			}
		}
		
		hql.append(" order by m." + sort + " " + dir);
		
		Query query = getSession().createQuery(hql.toString());
		
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		//保存为导出或统计总条数使用
		request.getSession().setAttribute("memberList4Export", query.list());
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询用户名及员工号
	 * @return
	 */
	public Object queryUsernameSerilNos() {
		return getSession().createQuery("select new map(m.userName as userName, m.serilNo as serilNo) from MemberVo m order by m.userName, m.serilNo")
									 .list();
	}

	/**
	 * 根据用户ID查人员信息
	 * @param userId 用户ID
	 * @return
	 */
	public MemberVo queryMember(String userId) {
		return (MemberVo) getSession().createQuery("from MemberVo m where userId = :userId").setString("userId", userId).uniqueResult();
	}
	
	/**
	 * 查询人员信息的所有组别
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryGroupNames(){
		return getSession().createQuery("select distinct new map(m.groupName as groupName) from MemberVo m order by m.groupName").list();
	}
}

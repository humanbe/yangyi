package com.nantian.rept.service;

import java.util.HashMap;
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

@Service
@Repository
@Transactional
public class BusiPersonnelManageService {
	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	
	private Session getSession(){
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	public BusiPersonnelManageService(){
		fields.put("sysId", FieldType.STRING);
		fields.put("sysName", FieldType.STRING);
		fields.put("pbName", FieldType.STRING);
		fields.put("department", FieldType.STRING);
		fields.put("mobile", FieldType.STRING);
		fields.put("phone", FieldType.STRING);
		fields.put("email", FieldType.STRING);
	}
	
	/**
	 * 查询业务联系人员信息
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param params 参数对象
	 * @param request 请求对象
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object queryBusiPersonnels(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(")
			.append("	t.sysId as sysId, ")
			.append("	t.sequence as sequence, ")
			.append("	t.bpName as bpName, ")
			.append("	t.department as department, ")
			.append("	t.mobile as mobile, ")
			.append("	t.phone as phone, ")
			.append("	t.email as email) ")
			.append("from BusinessPersonnelVo t, SystemInfoVo s where t.sysId = substr(s.sysId, 5) ");
		
		for(String key : params.keySet()){
			if(FieldType.STRING.equals(fields.get(key))){
				if(key.equals("sysName")){
					hql.append("and s." + key + " like :" + key);
				}else{
					hql.append("and t." + key + " like :" + key);
				}
			}else{
				if(key.equals("sysName")){
					hql.append("and s." + key + " = :" + key);
				}else{
					hql.append("and t." + key + " = :" + key);
				}
			}
		}
		
		hql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(hql.toString());
		if(params.keySet().size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("buisPersonnelList4Export", query.list());
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}

	/**
	 * 查询业务联系人关联的所有应用系统编号简称
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object querySysIds() {
		return getSession().createQuery("select distinct new map(t.sysId as sysId) from BusinessPersonnelVo t order by t.sysId").list();
	}
}

package com.nantian.rept.service;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.vo.TimesTransConfVo;

@Service
@Repository
public class TimesTransConfService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(TimesTransConfService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	public TimesTransConfService(){
		fields.put("aplCode", FieldType.STRING);
		fields.put("countItem", FieldType.STRING);
		fields.put("relatedItem", FieldType.STRING);
		fields.put("type", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param timesTransConfVo
	 */
	@Transactional(value = "maoprpt")
	public void save(TimesTransConfVo timesTransConfVo) {
		getSession().save(timesTransConfVo);
	}
	
	/**
	 * 更新.
	 * @param timesTransConfVo
	 */
	@Transactional(value = "maoprpt")
	public void update(TimesTransConfVo timesTransConfVo) {
		getSession().update(timesTransConfVo);
	}

	/**
	 * 批量保存.
	 * @param timesTransConfVo
	 */
	@Transactional(value = "maoprpt")
	public void save(Set<TimesTransConfVo> weblogicConfVos) {
		for (TimesTransConfVo timesTransConfVo : weblogicConfVos) {
			getSession().save(timesTransConfVo);
		}
	}
	
	/**
	 * 根据主键数组删除
	 * @param aplCodes 系统编号数组
	 * @param countItems 统计科目名数组
	 */
	@Transactional(value = "maoprpt")
	public void deleteByUnionKeys(String[] aplCodes, String[] countItems) {
		for(int i = 0; i < aplCodes.length && i< countItems.length; i++){
			deleteByUnionKey(aplCodes[i], countItems[i]);
		}
		
	}

	/**
	 * 根据主键删除
	 * @param aplCode 系统编号
	 * @param countItem 统计科目名
	 */
	@Transactional(value = "maoprpt")
	public void deleteByUnionKey(String aplCode, String countItem) {
		getSession().createQuery("delete from TimesTransConfVo t where t.aplCode = :aplCode and t.countItem=:countItem")
						  .setString("aplCode", aplCode)
						  .setString("countItem", countItem)
						  .executeUpdate();
		
	}
	
	/**
	 * 根据主键查询实体
	 * @param aplCode 系统编号
	 * @param countItem 统计科目名
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public TimesTransConfVo queryTimesTransConfInfo(String aplCode, String countItem) {
		return (TimesTransConfVo) getSession().createQuery("from TimesTransConfVo t where t.aplCode=:aplCode and t.countItem=:countItem")
																.setString("aplCode", aplCode)
																.setString("countItem", countItem)
																.uniqueResult();
	}
	
	/**
	 * 查询分钟和秒交易量数据导入配置信息列表
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @param request
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryTimesTransConfList(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params,
			HttpServletRequest request) {
		StringBuilder sql = new StringBuilder();
		sql.append("select new map(")
			.append("	t.aplCode as aplCode, ")
			.append("	t.countItem as countItem, ")
			.append("	t.relatedItem as relatedItem, ")
			.append("	(case t.type when 1 then '分钟' when 2 then '秒钟' end) as type) ")
			.append("from TimesTransConfVo t where 1=1 ");
		
		for(String key : params.keySet()){
			if(fields.get(key).equals(FieldType.STRING)){
				sql.append(" and t." + key + " like :" + key);
			}else{
				sql.append(" and t." + key + " = :" + key);
			}
		}
		
		sql.append(" order by t." + sort + " " + dir);
		
		Query query = getSession().createQuery(sql.toString());
		
		if(params.size() > 0){
			query.setProperties(params);
		}
		
		request.getSession().setAttribute("timesTransConfList4Export", query.list());
		
		return query.setMaxResults(limit).setFirstResult(start).list();
	}
	
	/**
	 * 查询配置表所有的系统编号
	 * @return
	 */
	@Transactional(value = "maoprpt", readOnly = true)
	public Object queryAplCodes(){
		return getSession().createQuery("select distinct new map(t.aplCode as aplCode) from TimesTransConfVo t order by t.aplCode ").list();
	}
}

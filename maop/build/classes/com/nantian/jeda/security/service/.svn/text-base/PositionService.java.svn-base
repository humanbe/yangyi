/**
 * 
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.transform.Transformers;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.common.model.Position;
import com.nantian.jeda.common.model.Role;

/**
 * 岗位服务.
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class PositionService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PositionService.class);

	/** 查询参数信息.[字段-类型] */
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
	 * 构造方法.初始化查询参数.
	 */
	public PositionService() {
		fields.put("name", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param position
	 */
	@Transactional
	public void save(Position position) {
		getSession().save(position);
	}

	/**
	 * 更新.
	 * 
	 * @param position
	 */
	@Transactional
	public void update(Position position) {
		getSession().update(position);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Position.class, id);
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		return getSession()
				.createQuery(
						"select new map(p.id as id,p.name as name,p.id as id,p.name as name,p.description as description,p.type as type,p.order as order,p.creator.name as creator,p.created as created,p.modifier.name as modifier,p.modified as modified,p.version as version) "
								+ "from Position p where p.id =? ").setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param position
	 */
	@Transactional
	public void delete(Position position) {
		getSession().delete(position);
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Position p where p.id=?").setString(0, id).executeUpdate();
	}

	/**
	 * 批量删除.
	 * 
	 * @param ids 主键数组
	 */
	@Transactional
	public void deleteByIds(String[] ids) {
		for (String id : ids) {
			deleteById(id);
		}
	}

	/**
	 * 根据翻页、排序和其他参数查询记录.
	 * 
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		String hql = "select new map(p.id as id,p.name as name,p.description as description,p.type as type,p.order as order,p.creator.name as creator,p.created as created,p.modifier.name as modifier,p.modified as modified) "
				+ "from Position p left join p.creator left join p.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and p." + key + " like :" + key;
				} else {
					hql += " and p." + key + " = :" + key;
				}
			}
		}

		hql += " order by p." + sort + " " + dir;
		Query query = getSession().createQuery(hql).setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) {
		String hql = "select count(*) from Position where 1=1 ";
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		Query query = getSession().createQuery(hql);
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 保存岗位与角色的关联关系.
	 * 
	 * @param roleIds 角色ID数组
	 * @param positionId 岗位
	 */
	@Transactional
	public void savePositionRole(Long positionId, String[] roleIds) {
		Object position = getSession().get(Position.class, positionId);
		if (null != position) {
			((Position) position).clearRole();
			for (String id : roleIds) {
				Object role = getSession().get(Role.class, id);
				if (role != null) {
					((Position) position).addRole((Role) role);
				}
			}
			getSession().update(position);
		}

	}

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByOrg(String orgId) {
		Org org = (Org) getSession().get(Org.class, orgId);
		if (org != null) {
			String sql = "(select JP.POSITION_ID as id,JP.POSITION_NAME as name from JEDA_POSITION JP,JEDA_POSITION_ORG JPO where JP.POSITION_ID=JPO.POSITION_ID and JPO.ORG_ID=?) ";
			sql += "UNION (select JP.POSITION_ID,JP.POSITION_NAME from JEDA_POSITION JP,JEDA_POSITION_PL JPP,JEDA_POSITION_LEVEL JPL where JP.POSITION_ID=JPP.POSITION_ID and JPP.PL_ID = JPL.PL_ID and JPL.PL_VALUE=?) ";
			sql += "UNION (select JP.POSITION_ID,JP.POSITION_NAME from JEDA_POSITION JP where JP.POSITION_TYPE='0')";
			return getSession().createSQLQuery(sql).setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP).setString(0, org.getId())
					.setLong(1, org.getLevel()).list();
		}
		return null;
	}
}

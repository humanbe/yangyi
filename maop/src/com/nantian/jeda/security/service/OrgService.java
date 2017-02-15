/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.common.model.TransferOrg;
import com.nantian.jeda.security.util.PermissionProvider;
import com.nantian.jeda.security.util.UserSession;

/**
 * 组织机构服务.
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class OrgService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(OrgService.class);

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private PermissionProvider permissionProvider;

	@Autowired
	private UserSession userSession;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法.初始化查询参数.
	 */
	public OrgService() {
		fields.put("id", FieldType.STRING);
		fields.put("name", FieldType.STRING);
		fields.put("category", FieldType.STRING);
		fields.put("property", FieldType.STRING);
		fields.put("level", FieldType.INTEGER);
		fields.put("enabled", FieldType.BOOLEAN);
	}

	/**
	 * 保存.
	 * 
	 * @param org
	 */
	@Transactional
	public void save(Org org) {
		org.setPath(org.getParent().getPath() + "|" + org.getId());
		org.setLevel(org.getPath().split("\\|").length);
		getSession().save(org);
	}

	/**
	 * 批量保存.
	 * 
	 * @param orgs
	 */
	@Transactional
	public void save(Set<Org> orgs) {
		for (Org org : orgs) {
			getSession().save(org);
		}
	}

	@Transactional
	public void saveTransferOrg(TransferOrg org) {
		Date date = new Date();
		getSession()
				.createSQLQuery(
						"insert into JEDA_ORG(ORG_ID,ORG_NAME,PARENT_ORG_ID,ORG_DESCRIPTION,ORG_TEL,ORG_ADDRESS,ORG_CONTACT,ORG_ENABLED,ORG_TYPE,ORG_VERSION,ORG_CREATOR,ORG_CREATED,ORG_MODIFIER,ORG_MODIFIED) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
				.setString(0, org.getId()).setString(1, org.getName()).setString(2, org.getParent()).setString(3, org.getDescription())
				.setString(4, org.getTel()).setString(5, org.getAddress()).setString(6, org.getContact()).setBoolean(7, org.isEnabled())
				.setString(8, org.getCategory()).setInteger(9, 0).setString(10, "admin").setDate(11, date).setString(12, "admin").setDate(13, date)
				.executeUpdate();

	}

	@Transactional
	public void updateTransferOrg(TransferOrg org) {

		Date date = new Date();
		getSession()
				.createSQLQuery(
						"update JEDA_ORG set ORG_NAME=?,PARENT_ORG_ID=?,ORG_DESCRIPTION=?,ORG_TEL=?,ORG_ADDRESS=?,ORG_CONTACT=?,ORG_ENABLED=?,ORG_TYPE=?,ORG_MODIFIED=? where ORG_ID=?")
				.setString(0, org.getName()).setString(1, org.getParent()).setString(2, org.getDescription()).setString(3, org.getTel())
				.setString(4, org.getAddress()).setString(5, org.getContact()).setBoolean(6, org.isEnabled()).setString(7, org.getCategory())
				.setDate(8, date).setString(9, org.getId()).executeUpdate();

	}

	@Transactional
	public void saveOrUpdate(Set<Org> orgs) {
		for (Org org : orgs) {
			getSession().saveOrUpdate(org);
		}
	}

	/**
	 * 更新同步过来的机构数据.
	 * 
	 * @param orgs
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public void updateSynchronizedOrgs() {
		List<Org> roots = getSession().createQuery("from Org where parent is null").list();
		if (roots != null && roots.size() > 0) {
			for (Org org : roots) {
				org.setPath(org.getId());
				org.setLevel(1);
				getSession().update(org);
				setSynchronizedOrg(org);
			}
		}
	}

	@SuppressWarnings("unchecked")
	private void setSynchronizedOrg(Org parent) {
		List<Org> children = getSession().createQuery("from Org where parent.id=?").setString(0, parent.getId()).list();
		if (children != null && children.size() > 0) {
			for (Org child : children) {
				child.setPath(parent.getPath() + "|" + child.getId());
				child.setLevel(parent.getLevel() + 1);
				getSession().update(child);
				setSynchronizedOrg(child);
			}
		}
	}

	/**
	 * 更新.
	 * 
	 * @param org
	 */
	@Transactional
	public void update(Org org) {
		getSession().update(org);
	}

	@Transactional
	public void update(Set<Org> orgs) {
		for (Org org : orgs) {
			getSession().update(org);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(Org.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param org
	 */
	@Transactional
	public void delete(Org org) {
		getSession().delete(org);
	}

	@Transactional
	@SuppressWarnings("unchecked")
	public List<Org> findAll() {
		return getSession().createQuery("from Org o left join fetch o.users").list();
	}

	/**
	 * 
	 * @return
	 */
	@Transactional
	@SuppressWarnings("unchecked")
	public List<Org> find() {
		return getSession().createQuery("select new Org(o.id) from Org o order by o.id asc").list();
	}

	/**
	 * 根据分页、排序和其他参数查询记录.
	 * 
	 * @param parent 上级机构
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 * @throws DataAccessException
	 * @throws JEDAException
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find(String parent, Integer start, Integer limit, String sort, String dir, Map<String, Object> params)
			throws DataAccessException, JEDAException {
		Query query = null;
		String hql = "select new map(o.id as id,o.name as name,o.path as path,o.level as level,o.description as description,o.contact as contact,o.address as address,o.tel as tel,o.category as category,o.property as property,o.enabled as enabled,o.parent.id as parent,"
				+ "o.order as order,o.creator.name as creator,o.created as created,o.modifier.name as modifier,o.modified as modified) "
				+ "from Org o left join o.parent left join o.creator left join o.modifier where 1=1 ";
		Map<String, String> permissionField = new HashMap<String, String>();
		permissionField.put("creator", "o.creator");
		permissionField.put("category", "o.category");
		hql += permissionProvider.getPermissionHqlByFunction("ORG_LIST", permissionField);
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and o." + key + " like :" + key;
				} else {
					hql += " and o." + key + " = :" + key;
				}
			}
		}
		String orderBy = " order by o." + sort + " " + dir;
		if (parent.isEmpty()) {
			hql += " and o.path like :path ";
			query = getSession().createQuery(hql + orderBy).setString("path", "%" + userSession.getUser().getOrg().getId() + "%");
		} else {
			hql += " and o.parent.id=:parent ";
			query = getSession().createQuery(hql + orderBy).setString("parent", parent);
		}
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.setFirstResult(start).setMaxResults(limit).list();

	}

	/**
	 * 根据参数记录查询记录数量.
	 * 
	 * @param parent 父级ID
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(String parent, Map<String, Object> params) {
		Query query = null;
		String hql = "select count(*) from Org where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		if (parent.isEmpty()) {
			hql += " and path like :path ";
			query = getSession().createQuery(hql).setString("path", "%" + userSession.getUser().getOrg().getId() + "%");
		} else {
			hql += " and parent.id=:parentId";
			query = getSession().createQuery(hql).setString("parentId", parent);
		}
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 根据父级查询.
	 * 
	 * @param parent 父级记录ID
	 * @param userSelect 是否用于用户选择
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByParent(String parent, boolean userSelect) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as text,o.id as qtip,o.path as path,o.level as level,'menu-node-org' as iconCls,"
								+ "(case when o.children.size>0 " + (userSelect ? "or o.users.size>0" : "")
								+ " then false  else true end ) as leaf ) "
								+ "from Org o left join o.parent where o.parent.id=? and o.enabled =1 order by o.order asc").setString(0, parent)
				.list();
	}

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByRole(String parent, String role) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as text,o.id as qtip,o.path as path,o.level as level,'menu-node-org' as iconCls,"
								+ "(case when o.children.size>0 or (select count(u.username) from User u inner join u.position.roles role where role.id=:role and u.org.parent.id=:org)>0 then false  else true end ) as leaf ) "
								+ "from Org o left join o.parent where o.parent.id=:org and o.enabled =1 order by o.order asc")
				.setString("org", parent).setString("role", role).list();
	}

	/**
	 * 根据上级机构查询.用于新建页面中选择机构.
	 * 
	 * @param parent
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByParent(String parent) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as text,o.id as qtip,o.path as path,o.level as level,'menu-node-org' as iconCls,"
								+ "(case when o.children.size>0 then false  else true end ) as leaf, (case when 1=1 then false end) as checked ) "
								+ "from Org o left join o.parent where o.parent.id=? and o.enabled =1 order by o.order asc").setString(0, parent)
				.list();
	}

	/**
	 * 根据上级机构和岗位查询.用于岗位修改页面中选择机构.
	 * 
	 * @param parent
	 * @param position
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByPosition(String parent, String position) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as text,o.id as qtip,o.path as path,o.level as level,'menu-node-org' as iconCls,"
								+ "(case when o.children.size>0 then false else true end ) as leaf,"
								+ "(case when (select count(*) from Position position inner join position.orgs org where position.id = :position and org.id = o.id )>0 then true else false end ) as checked ) "
								+ "from Org o left join o.parent where o.parent.id=:parent and o.enabled =1 order by o.order asc")
				.setString("position", position).setString("parent", parent).list();
	}

	/**
	 * 根据上级机构和权限查询.用于权限修改页面中选择机构.
	 * 
	 * @param parent
	 * @param permissionId
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByPermission(String parent, String permissionId) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as text,o.id as qtip,o.path as path,o.level as level,'menu-node-org' as iconCls,"
								+ "(case when o.children.size>0 then false else true end ) as leaf,"
								+ "(case when (select count(*) from Permission permission inner join permission.associatedOrgs org where permission.id = :permission and org.id = o.id )>0 then true else false end ) as checked ) "
								+ "from Org o left join o.parent where o.parent.id=:parent and o.enabled =1 order by o.order asc")
				.setString("permission", permissionId).setString("parent", parent).list();
	}

	/**
	 * 根据ID查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		return getSession()
				.createQuery(
						"select new map(o.id as id,o.name as name,o.description as description,o.contact as contact,o.address as address,o.tel as tel,o.category as category,o.property as property,o.path as path,o.level as level,o.enabled as enabled,o.enabled as _enabled,o.parent.id as parent,o.order as order, o.version as version) "
								+ "from Org o left join o.parent where o.id =? ").setString(0, id).uniqueResult();
	}

	/**
	 * 根据ID删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Org o where o.id=?").setString(0, id).executeUpdate();
	}

	/**
	 * 根据ID批量删除.
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
	 * 查询指定机构的所有上级机构.
	 * 
	 * @param path 机构路径
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Org> findHigherMap(String path) {
		String[] ids = path.split("\\|");
		return getSession()
				.createQuery(
						"select new Org(o.id as id,o.name as text,o.path as path,o.level as level) from Org o where o.id in (:ids) order by o.order asc")
				.setParameterList("ids", ids).list();
	}

	/**
	 * 查询指定机构的所有上级机构.
	 * 
	 * @param path 机构路径
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Org> findHigherEntity(String path) {
		String[] ids = path.split("\\|");
		return getSession().createQuery("from Org o where o.id in (:ids) order by o.order asc").setParameterList("ids", ids).list();
	}

	/**
	 * 查询指定机构的所有下级机构.
	 * 
	 * @param path 机构路径
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Org> findLowerMap(String path) {
		return getSession()
				.createQuery(
						"select new Org(o.id as id,o.name as text,o.path as path,o.level as level) from Org o where o.path like :path order by o.order asc")
				.setString("path", path + "%").list();
	}

	/**
	 * 查询指定机构的所有下级机构.
	 * 
	 * @param path 机构路径
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Org> findLowerEntity(String path) {
		return getSession().createQuery("from Org o where o.path like :path order by o.order asc").setString("path", path + "%").list();
	}

}

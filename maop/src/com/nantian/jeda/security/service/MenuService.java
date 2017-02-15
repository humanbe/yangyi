/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
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
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Menu;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 菜单服务.
 * 
 * @author daizhenzhong
 * 
 */
@Repository
public class MenuService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(MenuService.class);

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private SecurityUtils securityUtils;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法.初始化查询参数.
	 */
	public MenuService() {
		fields.put("name", FieldType.STRING);
		fields.put("url", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param menu
	 */
	@Transactional
	public void save(Menu menu) {
		getSession().save(menu);
	}

	/**
	 * 更新.
	 * 
	 * @param menu
	 */
	@Transactional
	public void update(Menu menu) {
		getSession().update(menu);
	}

	/**
	 * 批量保存.
	 * 
	 * @param menus
	 */
	@Transactional
	public void save(Set<Menu> menus) {
		for (Menu menu : menus) {
			getSession().save(menu);
		}
	}

	@Transactional
	public void saveOrUpdate(Set<Menu> menus) {
		for (Menu menu : menus) {
			getSession().saveOrUpdate(menu);
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
		return getSession().get(Menu.class, id);
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
						"select new map(m.id as id,m.name as name,m.url as url,m.iframe as iframe,m.iframe as _iframe,m.openInHome as openInHome,m.openInHome as _openInHome,m.description as description,m.order as order,m.parent.id as parent,m.version as version) "
								+ "from Menu m left join m.parent where m.id =? ").setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param menu
	 */
	@Transactional
	public void delete(Menu menu) {
		getSession().delete(menu);
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Menu m where m.id=?").setString(0, id).executeUpdate();
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
	 * 查询导航菜单.
	 * 
	 * @param parent父级记录
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> findNav(String parent) {
		Query query = null;
		String hql = "select new map(m.id as id ,m.name as text,m.url as link,m.openInHome as openInHome,'menu-node-'||m.icon as iconCls,m.iframe as iframe,(case when m.children.size>0 then false  else true end ) as leaf) ";
		hql += "from Menu m where m.id in (select distinct menu.id from Menu menu left join menu.parent left join menu.roles role left join role.users user where user.username=:username) ";
		String orderBy = " order by m.order asc";
		if (parent.isEmpty()) {
			hql += "  and m.parent.id is null";
			query = getSession().createQuery(hql + orderBy);
		} else {
			hql += "  and m.parent.id=:parent";
			query = getSession().createQuery(hql + orderBy).setString("parent", parent);
		}
		return query.setString("username", securityUtils.getUser().getUsername()).list();

	}

	/**
	 * 根据翻页、排序和其他参数查询记录.
	 * 
	 * @param parent 父级记录
	 * @param start 开始记录条数
	 * @param limit 返回记录条数
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return 记录集合
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find(String parent, Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		Query query = null;
		String hql = "select new map(m.id as id,m.name as name,m.url as url,m.description as description,m.order as order,"
				+ "m.parent.id as parent) " + "from Menu m left join m.parent where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and m." + key + " like :" + key;
				} else {
					hql += " and m." + key + " = :" + key;
				}
			}
		}
		String orderBy = " order by m." + sort + " " + dir;
		if (parent == null || parent.isEmpty()) {
			query = getSession().createQuery(hql + orderBy);
		} else if (parent.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += " and m.parent.id is null";
			query = getSession().createQuery(hql + orderBy);
		} else {
			hql += " and m.parent.id=:parent";
			query = getSession().createQuery(hql + orderBy).setString("parent", parent);
		}
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.setFirstResult(start).setMaxResults(limit).list();

	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param parent
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(String parent, Map<String, Object> params) {
		Query query = null;
		String hql = "select count(*) from Menu where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		if (parent == null || parent.isEmpty()) {
			query = getSession().createQuery(hql);
		} else if (parent.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += " and parent.id is null";
			query = getSession().createQuery(hql);
		} else {
			hql += " and parent.id=:parent";
			query = getSession().createQuery(hql).setString("parent", parent);
		}
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 根据父级记录查询.
	 * 
	 * @param parent 父级记录
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByParent(String parent) {

		Query query = null;
		String hql = "select new map(m.id as id ,m.name as text,m.url as link,'menu-node-menu' as iconCls,(case when m.children.size>0 then false  else true end ) as leaf) ";
		hql += "from Menu m left join m.parent p where ";
		String orderBy = " order by m.order asc";
		if (parent == null || parent.isEmpty()) {
			query = getSession().createQuery(hql + orderBy);
		} else if (parent.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += "  p is null";
			query = getSession().createQuery(hql + orderBy);
		} else {
			hql += "  p.id=:parent";
			query = getSession().createQuery(hql + orderBy).setString("parent", parent);
		}
		return query.list();
	}

	/**
	 * 根据角色查询
	 * 
	 * @param parent
	 * @param role
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByRole(String parent, String role) {
		String hql = "select new map(m.id as id ,m.name as text,m.url as link,'menu-node-menu' as iconCls,(case when m.children.size>0 then false  else true end) as leaf,";
		hql += "(case when (select count(*) from Role r inner join r.menus menu where r.id = ? and menu.id = m.id )>0 then true else false end ) as checked) ";
		hql += "from Menu m left join m.parent ";
		if (parent.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += "where m.parent.id is null order by m.order asc";
			return getSession().createQuery(hql).setString(0, role).list();
		} else {
			hql += "where m.parent.id=? order by m.order asc";
			return getSession().createQuery(hql).setString(0, role).setString(1, parent).list();
		}
	}
	
	/**
	 * 根据父节点获取菜单列表
	 * @param parent
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByParentNode(String parent) {
		String hql = "select new map(m.id as id ,m.name as text,m.url as link,'menu-node-menu' as iconCls,(case when m.children.size>0 then false  else true end) as leaf)";
		hql += " from Menu m left join m.parent ";
		if (parent.equalsIgnoreCase(Constants.TREE_ROOT_NODE)) {
			hql += " where m.parent.id is null order by m.order asc";
			return getSession().createQuery(hql).list();
		} else {
			hql += " where m.parent.id=? order by m.order asc";
			return getSession().createQuery(hql).setString(0, parent).list();
		}
	}
	
	/**
	 * 菜单给角色授权
	 * @param roleCode 角色编号
	 * @param menuCode 菜单编号
	 */
	public void addRoleMenu(String roleCode,String menuCode){
		getSession()
		.createSQLQuery(
				"insert into JEDA_ROLE_MENU(ROLE_ID,MENU_ID) values(?,?)")
		.setString(0, roleCode).setString(1, menuCode)
		.executeUpdate();
	}
	
	/**
	 * 删除菜单角色权限
	 * @param menuCode 菜单编号
	 */
	public void deleteRoleMenu(String menuCode){
		getSession()
		.createSQLQuery(
				"delete from JEDA_ROLE_MENU t where t.MENU_ID=?")
		.setString(0, menuCode)
		.executeUpdate();
	}
}

/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.vo.RoleProductVo;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Function;
import com.nantian.jeda.common.model.Menu;
import com.nantian.jeda.common.model.Permission;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.common.model.User;

/**
 * 角色业务逻辑服务
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Service
@Repository
public class RoleService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(RoleService.class);

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
	public RoleService() {
		fields.put("name", FieldType.STRING);
		fields.put("description", FieldType.STRING);
	}

	/**
	 * 保存.
	 * 
	 * @param role
	 */
	@Transactional
	public void save(Role role) {
		getSession().save(role);
	}

	/**
	 * 批量保存.
	 * 
	 * @param roles
	 */
	@Transactional
	public void save(Set<Role> roles) {
		for (Role role : roles) {
			getSession().save(role);
		}
	}

	/**
	 * 更新.
	 * 
	 * @param role
	 */
	@Transactional
	public void update(Role role) {
		getSession().update(role);
	}

	/**
	 * 批量更新.
	 * 
	 * @param roles
	 */
	@Transactional
	public void update(Set<Role> roles) {
		for (Role role : roles) {
			getSession().update(role);
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
		return getSession().get(Role.class, id);
	}

	/**
	 * 删除.
	 * 
	 * @param role
	 */
	@Transactional
	public void delete(Role role) {
		getSession().delete(role);
	}

	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> findMap() {
		String hql = "select new map(r.id as id,r.name as name,r.type as type,r.description as description,r.order as order) from Role r order by r.order asc";

		return getSession().createQuery(hql).list();
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
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
		String hql = "select new map(r.id as id,r.name as name,r.type as type,r.description as description,r.order as order,"
				+ "r.creator.name as creator,r.created as created,r.modifier.name as modifier,r.modified as modified) "
				+ "from Role r left join r.creator left join r.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and r." + key + " like :" + key;
				} else {
					hql += " and r." + key + " = :" + key;
				}
			}
		}

		hql += " order by r." + sort + " " + dir;
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
		String hql = "select count(*) from Role where 1=1 ";
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
	 * 根据ID查询.
	 * 
	 * @param id 主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findById(String id) {
		return getSession()
				.createQuery(
						"select new map(id as id, name as name,type as type, description as description, order as order, version as version) "
								+ "from Role where id =?").setString(0, id).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param id 主键
	 */
	private void deleteById(String id) {
		getSession().createQuery("delete from Role where id=?").setString(0, id).executeUpdate();
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
	 * 保存与菜单的关联信息
	 * 
	 * @param menuIds 菜单编码数组
	 * @param roleId 角色编码
	 */
	@Transactional
	public void saveRelationWithMenu(String[] menuIds, String roleId) {
		Object role = getSession().get(Role.class, roleId);
		if (null != role) {
			((Role) role).clearMenu();// 清除与该角色关联的所有菜单信息
			for (String menuId : menuIds) {
				Object menu = getSession().get(Menu.class, menuId);
				if (menu != null) {
					((Role) role).addMenu((Menu) menu);
				}
			}
			getSession().update(role);
		}

	}

	@Transactional
	public void saveRoleUser(String[] checked, String[] unchecked, String roleId) {
		Role role = (Role) getSession().get(Role.class, roleId);
		if (null != role) {
			for (String username : unchecked) {
				Object user = getSession().get(User.class, username);
				if (user != null && role.getUsers() != null) {
					role.getUsers().remove(user);
				}
			}
			for (String username : checked) {
				Object user = getSession().get(User.class, username);
				if (user != null) {
					role.addUser((User) user);
				}
			}
			getSession().update(role);
		}

	}
	
	/**
	 * 保存与brpm角色的关联关系.
	 * 
	 * @param checkedIds 选中的功能ID数组
	 * @param uncheckedIds 未选中的功能ID数组
	 * @param roleId 角色ID
	 */
	@Transactional
	public void saveRoleBrpm(String[] ids, String roleId) {
		Role role = (Role) getSession().get(Role.class, roleId);
		if (null != role) {
			((Role) role).clearRoleBrpm();
			for (String brole : ids) {
				Object rolePro = getSession().get(RoleProductVo.class, brole);
				if (rolePro != null) {
					role.addRoleBrpm((RoleProductVo) rolePro);
				}
			}
			getSession().update(role);
		}

	}
	
	/**
	 * 保存与bsa角色的关联关系.
	 * 
	 * @param checkedIds 选中的功能ID数组
	 * @param uncheckedIds 未选中的功能ID数组
	 * @param roleId 角色ID
	 */
	@Transactional
	public void saveRoleBsa(String[] ids, String roleId) {
		Role role = (Role) getSession().get(Role.class, roleId);
		if (null != role) {
			((Role) role).clearRoleBsa();
			for (String brole : ids) {
				Object rolePro = getSession().get(RoleProductVo.class, brole);
				if (rolePro != null) {
					role.addRoleBsa((RoleProductVo) rolePro);
				}
			}
			getSession().update(role);
		}

	}

	/**
	 * 保存与功能的关联关系.
	 * 
	 * @param checkedIds 选中的功能ID数组
	 * @param uncheckedIds 未选中的功能ID数组
	 * @param roleId 角色ID
	 */
	@Transactional
	public void saveRoleFunction(String[] checkedIds, String[] uncheckedIds, String roleId) {
		Role role = (Role) getSession().get(Role.class, roleId);
		if (null != role) {
			for (String id : uncheckedIds) {
				Object function = getSession().get(Function.class, id);
				if (function != null && role.getFunctions() != null) {
					role.getFunctions().remove(function);// 清除关联信息
				}
			}
			for (String id : checkedIds) {
				Object function = getSession().get(Function.class, id);
				if (function != null) {
					role.addFunction((Function) function);
				}
			}
			getSession().update(role);
		}

	}

	/**
	 * 保存角色和权限的关联关系.
	 * 
	 * @param permissionIds 权限ID数组
	 * @param roleId 角色ID
	 */
	@Transactional
	public void saveRolePermission(Long[] permissionIds, String roleId, String functionId) {
		Role role = (Role) getSession().get(Role.class, roleId);
		if (null != role) {
			if (functionId == null || functionId.isEmpty()) {
				role.clearPermission();// 清除所有功能的权限关联信息
			} else {
				Set<Permission> removeSet = new HashSet<Permission>(); 
				for (Permission permission : role.getPermissions()) {
					if (permission.getField().getFunction().getId().equalsIgnoreCase(functionId)) {
						removeSet.add(permission);
					}
				}
				role.getPermissions().removeAll(removeSet);
			}
			for (Long id : permissionIds) {
				Object permission = getSession().get(Permission.class, id);
				if (permission != null) {
					role.addPermission((Permission) permission);
				}
			}
			getSession().update(role);
		}

	}

	/**
	 * 根据用户信息查询角色.
	 * 
	 * @param user 用户名
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByUser(String user) {
		String hql = "select new map(r.id as id, r.name as name, r.order as order,"
				+ "(case when (select count(*) from User user inner join user.roles role where user.username=:username and role.id = r.id)>0 then true else false end ) as checked) "
				+ "from Role r inner join r.positions position inner join position.users u where u.username=:username order by r.order asc";
		return getSession().createQuery(hql).setString("username", user).list();
	}

	/**
	 * 根据岗位查询角色
	 * 
	 * @param position 岗位
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findByPosition(String position) {
		String hql = "select new map(r.id as id, r.name as name, r.order as order,"
				+ "(case when (select count(*) from Position p inner join p.roles role where p.id=? and role.id = r.id)>0 then true else false end ) as checked) "
				+ "from Role r order by r.order asc";
		return getSession().createQuery(hql).setString(0, position).list();
	}
	
	/**
	 * 根据角色查询BRPM关联角色.
	 * 
	 * @param roleName 角色id
	 * @param proRoleType 产品角色类型
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findBrpmRoleByRole(String roleName, char proRoleType) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(t.proRoleId as id, t.proRoleId as roleId, t.proRoleName as proRoleName, t.proRoleDesc as proRoleDesc, ")
			.append(" (case when (select count(*) from Role role inner join role.roleBrpms brpms where role.id=:roleName and brpms.proRoleId = t.proRoleId) > 0 then true else false end ) as checked) ")
			.append(" from RoleProductVo t where t.proRoleType = :proRoleType ")
			.append(" order by t.proRoleId asc");
		return getSession().createQuery(hql.toString())
				.setString("roleName", roleName)
				.setCharacter("proRoleType", proRoleType)
				.list();
	}
	
	/**
	 * 根据角色查询BSA关联角色.
	 * 
	 * @param roleName 角色id
	 * @param proRoleType 产品角色类型
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> findBsaRoleByRole(String roleName, char proRoleType) {
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(t.proRoleId as id, t.proRoleId as roleId, t.proRoleName as proRoleName, t.proRoleDesc as proRoleDesc, ")
			.append(" (case when (select count(*) from Role role inner join role.roleBsas bsas where role.id=:roleName and bsas.proRoleId = t.proRoleId) > 0 then true else false end ) as checked) ")
			.append(" from RoleProductVo t where t.proRoleType = :proRoleType ")
			.append(" order by t.proRoleId asc");
		return getSession().createQuery(hql.toString())
				.setString("roleName", roleName)
				.setCharacter("proRoleType", proRoleType)
				.list();
	}

}

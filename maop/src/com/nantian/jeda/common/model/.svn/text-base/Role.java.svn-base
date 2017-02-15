/**
 *  Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import com.nantian.common.system.vo.RoleProductVo;


/**
 * 角色领域对象
 * 
 * @author daizhenzhong
 * 
 */
public class Role implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public static final String TYPE_PRIORITY = "PRIORITY";
	public static final String TYPE_FORBIDDEN = "FORBIDDEN";
	public static final String TYPE_PERMISSION = "PERMISSION";

	/**
	 * 主键
	 */
	private String id;

	/**
	 * 名称
	 */
	private String name;

	/**
	 * 描述
	 */
	private String description;

	/**
	 * 类型
	 */
	private String type;

	/**
	 * 关联的用户
	 */
	private Set<User> users;

	/**
	 * 关联的菜单
	 */
	private Set<Menu> menus;

	/**
	 * 关联的功能
	 */
	private Set<Function> functions;

	/**
	 * 关联的数据权限
	 */
	private Set<Permission> permissions;

	/**
	 * 关联的岗位
	 */
	private Set<Position> positions;
	
	/**
	 * 关联BRPM的角色
	 */
	private Set<RoleProductVo> roleBrpms;
	
	/**
	 * 关联BSA的角色
	 */
	private Set<RoleProductVo> roleBsas;

	/**
	 * 次序
	 */
	private Integer order;

	/**
	 * 创建者
	 */
	private User creator;

	/**
	 * 创建时间
	 */
	private Date created;

	/**
	 * 最后修改者
	 */
	private User modifier;

	/**
	 * 最后修改时间
	 */
	private Date modified;

	/**
	 * 乐观锁
	 */
	private Integer version;

	/**
	 * @param id
	 */
	public Role(String id) {
		this.id = id;
	}

	/**
	 * 
	 */
	public Role() {
	}

	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * @return the type
	 */
	public String getType() {
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		this.type = type;
	}

	/**
	 * @return the users
	 */
	public Set<User> getUsers() {
		return users;
	}

	/**
	 * @param users the users to set
	 */
	public void setUsers(Set<User> users) {
		this.users = users;
	}

	/**
	 * @return the menus
	 */
	public Set<Menu> getMenus() {
		return menus;
	}

	/**
	 * @param menus the menus to set
	 */
	public void setMenus(Set<Menu> menus) {
		this.menus = menus;
	}

	/**
	 * @return the functions
	 */
	public Set<Function> getFunctions() {
		return functions;
	}

	/**
	 * @param functions the functions to set
	 */
	public void setFunctions(Set<Function> functions) {
		this.functions = functions;
	}

	/**
	 * @return the permissions
	 */
	public Set<Permission> getPermissions() {
		return permissions;
	}

	/**
	 * @param permissions the permissions to set
	 */
	public void setPermissions(Set<Permission> permissions) {
		this.permissions = permissions;
	}

	/**
	 * @return the positions
	 */
	public Set<Position> getPositions() {
		return positions;
	}

	/**
	 * @param positions the positions to set
	 */
	public void setPositions(Set<Position> positions) {
		this.positions = positions;
	}
	
	/**
	 * @return the roleBrpms
	 */
	public Set<RoleProductVo> getRoleBrpms() {
		return roleBrpms;
	}

	/**
	 * @param roleBrpms the roleBrpms to set
	 */
	public void setRoleBrpms(Set<RoleProductVo> roleBrpms) {
		this.roleBrpms = roleBrpms;
	}
	
	/**
	 * @return the roleBrpms
	 */
	public Set<RoleProductVo> getRoleBsas() {
		return roleBsas;
	}

	/**
	 * @param roleBsas the roleBsas to set
	 */
	public void setRoleBsas(Set<RoleProductVo> roleBsas) {
		this.roleBsas = roleBsas;
	}

	/**
	 * @return the creator
	 */
	public User getCreator() {
		return creator;
	}

	/**
	 * @param creator the creator to set
	 */
	public void setCreator(User creator) {
		this.creator = creator;
	}

	/**
	 * @return the created
	 */
	public Date getCreated() {
		return created;
	}

	/**
	 * @param created the created to set
	 */
	public void setCreated(Date created) {
		this.created = created;
	}

	/**
	 * @return the modifier
	 */
	public User getModifier() {
		return modifier;
	}

	/**
	 * @param modifier the modifier to set
	 */
	public void setModifier(User modifier) {
		this.modifier = modifier;
	}

	/**
	 * @return the modified
	 */
	public Date getModified() {
		return modified;
	}

	/**
	 * @param modified the modified to set
	 */
	public void setModified(Date modified) {
		this.modified = modified;
	}

	/**
	 * @return the version
	 */
	public Integer getVersion() {
		return version;
	}

	/**
	 * @param version the version to set
	 */
	public void setVersion(Integer version) {
		this.version = version;
	}

	/**
	 * @return the order
	 */
	public Integer getOrder() {
		return order;
	}

	/**
	 * @param order the order to set
	 */
	public void setOrder(Integer order) {
		this.order = order;
	}

	public void addMenu(Menu menu) {
		if (menus == null) {
			menus = new HashSet<Menu>();
		}
		menus.add(menu);
	}

	public void addUser(User user) {
		if (users == null) {
			users = new HashSet<User>();
		}
		users.add(user);
	}

	public void clearMenu() {
		if (menus == null) {
			menus = new HashSet<Menu>();
		}
		menus.clear();
	}

	public void clearUser() {
		if (users == null) {
			users = new HashSet<User>();
		}
		users.clear();
	}

	public void addFunction(Function function) {
		if (functions == null) {
			functions = new HashSet<Function>();
		}
		functions.add(function);
	}

	public void clearFunction() {
		if (functions == null) {
			functions = new HashSet<Function>();
		} else {
			functions.clear();
		}
	}

	public void addRoleBrpm(RoleProductVo roleBrpm) {
		if (roleBrpms == null) {
			roleBrpms = new HashSet<RoleProductVo>();
		}
		roleBrpms.add(roleBrpm);
	}

	public void clearRoleBrpm() {
		if (roleBrpms == null) {
			roleBrpms = new HashSet<RoleProductVo>();
		} else {
			roleBrpms.clear();
		}
	}
	
	public void addRoleBsa(RoleProductVo roleBsa) {
		if (roleBsas == null) {
			roleBsas = new HashSet<RoleProductVo>();
		}
		roleBsas.add(roleBsa);
	}

	public void clearRoleBsa() {
		if (roleBsas == null) {
			roleBsas = new HashSet<RoleProductVo>();
		} else {
			roleBsas.clear();
		}
	}
	
	public void addPermission(Permission permission) {
		if (permissions == null) {
			permissions = new HashSet<Permission>();
		}
		permissions.add(permission);
	}

	public void clearPermission() {
		if (permissions == null) {
			permissions = new HashSet<Permission>();
		} else {
			permissions.clear();
		}
	}
}

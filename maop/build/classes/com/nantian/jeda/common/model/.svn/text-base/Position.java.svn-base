/**
 * 
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * 岗位实体对象.
 * 
 * @author daizhenzhong
 * 
 */
public class Position implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/** 总行参数管理员 */
	public static final String SUPER_PARA_ADMIN = "1";
	/** 分行参数管理员 */
	public static final String CENTER_PARA_ADMIN = "2";
	/** 中心柜员 */
	public static final String CENTER_OPERATOR = "3";
	/** 网点柜员 */
	public static final String BRANCH_OPERATOR = "4";
	/** 业务主管 */
	public static final String SYS_ADMIN = "5";
	/** 缩微柜员 */
	public static final String SCAN_ADMIN = "6";

	/**
	 * 岗位主键
	 */
	private Long id;

	/**
	 * 岗位名称
	 */
	private String name;

	/**
	 * 岗位描述
	 */
	private String description;

	/**
	 * 岗位类型
	 */
	private String type;

	/**
	 * 岗位顺序
	 */
	private Integer order;

	/**
	 * 岗位级别
	 */
	private Set<PositionLevel> levels;

	/**
	 * 所属机构
	 */
	private Set<Org> orgs;

	/**
	 * 关联角色
	 */
	private Set<Role> roles;

	/**
	 * 用户
	 */
	private Set<User> users;

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

	public Position() {
	}

	public Position(Long id) {
		this.id = id;
	}

	/**
	 * @return the id
	 */
	public Long getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(Long id) {
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
	 * @return the levels
	 */
	public Set<PositionLevel> getLevels() {
		return levels;
	}

	/**
	 * @param levels the levels to set
	 */
	public void setLevels(Set<PositionLevel> levels) {
		this.levels = levels;
	}

	/**
	 * @return the orgs
	 */
	public Set<Org> getOrgs() {
		return orgs;
	}

	/**
	 * @param orgs the orgs to set
	 */
	public void setOrgs(Set<Org> orgs) {
		this.orgs = orgs;
	}

	/**
	 * @return the roles
	 */
	public Set<Role> getRoles() {
		return roles;
	}

	/**
	 * @param roles the roles to set
	 */
	public void setRoles(Set<Role> roles) {
		this.roles = roles;
	}

	public void addRole(Role role) {
		if (roles == null) {
			roles = new HashSet<Role>();
		}
		roles.add(role);
	}

	public void clearRole() {
		if (roles == null) {
			roles = new HashSet<Role>();
		} else {
			roles.clear();
		}
	}

	public void addOrg(Org org) {
		if (orgs == null) {
			orgs = new HashSet<Org>();
		}
		orgs.add(org);
	}

	public void clearOrg() {
		if (orgs == null) {
			orgs = new HashSet<Org>();
		} else {
			orgs.clear();
		}
	}

	public void addPositionLevel(PositionLevel positionLevel) {
		if (levels == null) {
			levels = new HashSet<PositionLevel>();
		}
		levels.add(positionLevel);
	}

	public void clearPositionLevel() {
		if (levels == null) {
			levels = new HashSet<PositionLevel>();
		} else {
			levels.clear();
		}
	}

}

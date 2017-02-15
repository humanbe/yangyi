/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 权限实体对象
 * 
 * @author daizhenzhong
 * 
 */
public class Permission implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/** 用户权限类型 */
	public final static String TYPE_USER = "PERMISSION_TYPE_USER";
	/** 机构权限类型 */
	public final static String TYPE_ORG = "PERMISSION_TYPE_ORG";
	/** 字典权限类型 */
	public final static String TYPE_ITEM = "PERMISSION_TYPE_ITEM";
	/** 常量权限类型 */
	public final static String TYPE_CONSTANT = "PERMISSION_TYPE_CONSTANT";

	/** 机构权限类型:登录用户所在机构 */
	public final static String ORG_TYPE_CREATOR_ORG = "1";

	/** 机构权限类型:登录用户所在机构及其下属机构 */
	public final static String ORG_TYPE_CREATOR_ORG_DOWN = "2";

	/** 机构权限类型:登录用户所在机构及其上级机构 */
	public final static String ORG_TYPE_CREATOR_ORG_UP = "3";

	/** 机构权限类型:指定机构 */
	public final static String ORG_TYPE_CREATOR_ORG_ASSIGN = "4";

	/**
	 * 权限ID
	 */
	private Long id;

	/**
	 * 权限名称
	 */
	private String name;

	/**
	 * 权限类型
	 */
	private String type;

	/**
	 * 权限表达式
	 */
	private String expression;

	/**
	 * 权限描述
	 */
	private String description;

	/**
	 * 字段
	 */
	private Field field;

	/**
	 * 用户权限类型
	 */
	private String userType;

	/**
	 * 机构权限类型
	 */
	private String orgType;

	/**
	 * 字段数值
	 */
	private String fieldValue;

	/**
	 * 权限顺序
	 */
	private Integer order;

	/**
	 * 数据子项
	 */
	private SubItem subitem;

	/**
	 * 权限机构
	 */
	private List<Org> orgs;

	/**
	 * 关联角色
	 */
	private Set<Role> roles;

	/**
	 * 指定关联的机构
	 */
	private Set<Org> associatedOrgs;

	/**
	 * 指定关联的用户
	 */
	private Set<User> associatedUsers;

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
	 * @return the expression
	 */
	public String getExpression() {
		return expression;
	}

	/**
	 * @param expression the expression to set
	 */
	public void setExpression(String expression) {
		this.expression = expression;
	}

	/**
	 * @return the userType
	 */
	public String getUserType() {
		return userType;
	}

	/**
	 * @param userType the userType to set
	 */
	public void setUserType(String userType) {
		this.userType = userType;
	}

	/**
	 * @return the orgType
	 */
	public String getOrgType() {
		return orgType;
	}

	/**
	 * @param orgType the orgType to set
	 */
	public void setOrgType(String orgType) {
		this.orgType = orgType;
	}

	/**
	 * @return the fieldValue
	 */
	public String getFieldValue() {
		return fieldValue;
	}

	/**
	 * @param fieldValue the fieldValue to set
	 */
	public void setFieldValue(String fieldValue) {
		this.fieldValue = fieldValue;
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
	 * @return the subitem
	 */
	public SubItem getSubitem() {
		return subitem;
	}

	/**
	 * @param subitem the subitem to set
	 */
	public void setSubitem(SubItem subitem) {
		this.subitem = subitem;
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
	 * @return the field
	 */
	public Field getField() {
		return field;
	}

	/**
	 * @param field the field to set
	 */
	public void setField(Field field) {
		this.field = field;
	}

	/**
	 * @return the orgs
	 */
	public List<Org> getOrgs() {
		return orgs;
	}

	/**
	 * @param orgs the orgs to set
	 */
	public void setOrgs(List<Org> orgs) {
		this.orgs = orgs;
	}

	/**
	 * @return the associatedOrgs
	 */
	public Set<Org> getAssociatedOrgs() {
		return associatedOrgs;
	}

	/**
	 * @param associatedOrgs the associatedOrgs to set
	 */
	public void setAssociatedOrgs(Set<Org> associatedOrgs) {
		this.associatedOrgs = associatedOrgs;
	}

	/**
	 * @return the associatedUsers
	 */
	public Set<User> getAssociatedUsers() {
		return associatedUsers;
	}

	/**
	 * @param associatedUsers the associatedUsers to set
	 */
	public void setAssociatedUsers(Set<User> associatedUsers) {
		this.associatedUsers = associatedUsers;
	}

	/**
	 * 
	 * @param org
	 */
	public void addOrg(Org org) {
		if (this.orgs == null) {
			this.orgs = new ArrayList<Org>();
		}
		this.orgs.add(org);
	}

	/**
	 * 
	 * @param org
	 */
	public void addAssociatedOrg(Org org) {
		if (this.associatedOrgs == null) {
			this.associatedOrgs = new HashSet<Org>();
		}
		this.associatedOrgs.add(org);
	}

	/**
	 * 
	 * @param user
	 */
	public void addAssociatedUser(User user) {
		if (this.associatedUsers == null) {
			this.associatedUsers = new HashSet<User>();
		}
		this.associatedUsers.add(user);
	}

	/**
	 * @return
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		return super.hashCode();
	}

	/**
	 * @param obj
	 * @return
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (!(obj instanceof Permission))
			return false;
		final Permission permission = (Permission) obj;
		if (!permission.getId().equals(getId()))
			return false;
		return true;
	}

}

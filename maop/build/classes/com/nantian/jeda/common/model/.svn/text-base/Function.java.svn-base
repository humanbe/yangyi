/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.Set;


/**
 * 功能实体对象
 * 
 * @author daizhenzhong
 * 
 */
public class Function implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 功能ID
	 */
	private String id;

	/**
	 * 功能名称
	 */
	private String name;

	/**
	 * 功能地址
	 */
	private String url;

	/**
	 * 功能类型
	 */
	private String type;

	/**
	 * 可配权限
	 */
	private boolean hasPermission;
	
	/**
	 * 功能字段
	 */
	private Set<Field> fields;

	/**
	 * 功能顺序
	 */
	private Integer order;

	/**
	 * 所属模块
	 */
	private Module module;

	/**
	 * 关联的角色
	 */
	private Set<Role> roles;

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
	 * 域访问控制IP
	 */
	private String accessDomainIp;
	
	/**
	 * 乐观锁
	 */
	private Integer version;

	public Function() {
	}

	public Function(String id) {
		this.id = id;
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
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}

	/**
	 * @param url the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
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
	 * @return the hasPermission
	 */
	public boolean isHasPermission() {
		return hasPermission;
	}

	/**
	 * @param hasPermission the hasPermission to set
	 */
	public void setHasPermission(boolean hasPermission) {
		this.hasPermission = hasPermission;
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
	 * @return the module
	 */
	public Module getModule() {
		return module;
	}

	/**
	 * @param module the module to set
	 */
	public void setModule(Module module) {
		this.module = module;
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
	 * @return the fields
	 */
	public Set<Field> getFields() {
		return fields;
	}

	/**
	 * @param fields the fields to set
	 */
	public void setFields(Set<Field> fields) {
		this.fields = fields;
	}
	
	/**
	 * @return the accessDomainIp
	 */
	public String getAccessDomainIp() {
		return accessDomainIp;
	}
	
	/**
	 * @param accessDomainIp the accessDomainIp to set
	 */
	public void setAccessDomainIp(String accessDomainIp) {
		this.accessDomainIp = accessDomainIp;
	}
}

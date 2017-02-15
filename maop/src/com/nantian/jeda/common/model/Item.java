/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;


/**
 * 数据项领域对象
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class Item implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

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
	 * 数据子项
	 */
	private Set<SubItem> children;

	/**
	 * 是字典权限
	 */
	private boolean permission;
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
	 * 
	 */
	public Item() {
	}

	/**
	 * @param id
	 * @param name
	 * @param version
	 */
	public Item(String id, String name, Integer order, User creator, Date created) {
		this.id = id;
		this.name = name;
		this.order = order;
		this.creator = creator;
		this.created = created;
		this.modifier = creator;
		this.modified = created;
	}

	/**
	 * @param id
	 */
	public Item(String id) {
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
	 * @return the permission
	 */
	public boolean isPermission() {
		return permission;
	}

	/**
	 * @param permission the permission to set
	 */
	public void setPermission(boolean permission) {
		this.permission = permission;
	}

	/**
	 * @return the children
	 */
	public Set<SubItem> getChildren() {
		return children;
	}

	/**
	 * @param children the children to set
	 */
	public void setChildren(Set<SubItem> children) {
		this.children = children;
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

	public void addSub(SubItem sub) {
		if (children == null) {
			children = new HashSet<SubItem>();
		}
		children.add(sub);
	}
}

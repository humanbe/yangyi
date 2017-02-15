/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.Set;

/**
 * 模块实体对象
 * 
 * @author daizhenzhong
 * 
 */
public class Module implements SecurityEntity, Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 模块ID
	 */
	private String id;

	/**
	 * 模块名称
	 */
	private String name;

	/**
	 * 模块描述
	 */
	private String description;

	/**
	 * 包含功能
	 */
	private Set<Function> functions;

	/**
	 * 模块顺序
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
	public Module() {
	}

	/**
	 * @param id
	 */
	public Module(String id) {
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

}

/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * 菜单领域对象
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class Menu implements SecurityEntity, Serializable {

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
	 * URL
	 */
	private String url;

	/**
	 * 描述
	 */
	private String description;

	/**
	 * 上级菜单
	 */
	private Menu parent;

	/**
	 * 子菜单集合
	 */
	private Set<Menu> children;

	/**
	 * 关联的角色
	 */
	private Set<Role> roles;

	/**
	 * 是否嵌入页面
	 */
	private boolean iframe;

	/**
	 * 菜单图标
	 */
	private String icon;

	/**
	 * 是否主页中打开
	 */
	private boolean openInHome;

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

	public Menu(String id) {
		this.id = id;
	}

	public Menu() {
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
	 * @return the parent
	 */
	public Menu getParent() {
		return parent;
	}

	/**
	 * @param parent the parent to set
	 */
	public void setParent(Menu parent) {
		this.parent = parent;
	}

	/**
	 * @return the iframe
	 */
	public boolean isIframe() {
		return iframe;
	}

	/**
	 * @param iframe the iframe to set
	 */
	public void setIframe(boolean iframe) {
		this.iframe = iframe;
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
	 * @return the icon
	 */
	public String getIcon() {
		return icon;
	}

	/**
	 * @param icon the icon to set
	 */
	public void setIcon(String icon) {
		this.icon = icon;
	}

	/**
	 * @return the children
	 */
	public Set<Menu> getChildren() {
		return children;
	}

	/**
	 * @param children the children to set
	 */
	public void setChildren(Set<Menu> children) {
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
	 * @return the openInHome
	 */
	public boolean isOpenInHome() {
		return openInHome;
	}

	/**
	 * @param openInHome the openInHome to set
	 */
	public void setOpenInHome(boolean openInHome) {
		this.openInHome = openInHome;
	}

	public void addRole(Role role) {
		if (roles == null) {
			roles = new HashSet<Role>();
		}
		roles.add(role);
	}
}

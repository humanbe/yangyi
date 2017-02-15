/**
 * 
 */
package com.nantian.jeda.common.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.GrantedAuthorityImpl;
import org.springframework.security.core.userdetails.UserDetails;

import com.nantian.common.system.vo.ViewAppInfoVo;


/**
 * 用户领域对象
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class User implements UserDetails, SecurityEntity {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 用户名.主键
	 */
	private String username;

	/**
	 * 姓名
	 */
	private String name;

	/**
	 * 描述
	 */
	private String description;

	/**
	 * 密码
	 */
	private String password;

	/**
	 * 邮件
	 */
	private String email;

	/**
	 * 性别
	 */
	private String gender;

	/**
	 * 身份证号
	 */
	private String identity;

	/**
	 * 地址
	 */
	private String address;

	/**
	 * 邮编
	 */
	private String post;

	/**
	 * 电话
	 */
	private String tel;

	/**
	 * 手机
	 */
	private String mobile;

	/**
	 * 生日
	 */
	private Date birthday;

	/**
	 * 启用
	 */
	private boolean enabled;

	/**
	 * 帐户未过期
	 */
	private boolean accountNonExpired;

	/**
	 * 帐户未锁定
	 */
	private boolean accountNonLocked;

	/**
	 * 凭证未过期
	 */
	private boolean credentialsNonExpired;

	/**
	 * 所属机构
	 */
	private Org org;

	/**
	 * 岗位
	 */
	private Position position;

	/**
	 * 关联的角色
	 */
	private Set<Role> roles;
	
	/**
	 * 关联的系统
	 */
	private Set<ViewAppInfoVo> apps;
	
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

	public User() {
		setAccountNonLocked(true);
		setAccountNonExpired(true);
		setCredentialsNonExpired(true);
	}

	/**
	 * @param name
	 */
	public User(String name) {
		super();
		this.name = name;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#getAuthorities()
	 */
	@Override
	public Collection<GrantedAuthority> getAuthorities() {
		Set<Role> roles = getRoles();
		List<GrantedAuthority> grandtedAuthorities = new ArrayList<GrantedAuthority>();
		for (Role role : roles) {
			Set<Function> functions = role.getFunctions();
			for (Function function : functions) {
				grandtedAuthorities.add(new GrantedAuthorityImpl(function.getId()));
			}
		}
		return grandtedAuthorities;
	}

	// -------------------------------SETTER/GETTER BELOW-------------------------------

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#getPassword()
	 */
	@Override
	public String getPassword() {
		return password;
	}

	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#getUsername()
	 */
	@Override
	public String getUsername() {
		return username;
	}

	/**
	 * @param username the username to set
	 */
	public void setUsername(String username) {
		this.username = username;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#isAccountNonExpired()
	 */
	@Override
	public boolean isAccountNonExpired() {
		return accountNonExpired;
	}

	/**
	 * @param accountNonExpired the accountNonExpired to set
	 */
	public void setAccountNonExpired(boolean accountNonExpired) {
		this.accountNonExpired = accountNonExpired;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#isAccountNonLocked()
	 */
	@Override
	public boolean isAccountNonLocked() {
		return accountNonLocked;
	}

	/**
	 * @param accountNonLocked the accountNonLocked to set
	 */
	public void setAccountNonLocked(boolean accountNonLocked) {
		this.accountNonLocked = accountNonLocked;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#isCredentialsNonExpired()
	 */
	@Override
	public boolean isCredentialsNonExpired() {
		return credentialsNonExpired;
	}

	/**
	 * @param credentialsNonExpired the credentialsNonExpired to set
	 */
	public void setCredentialsNonExpired(boolean credentialsNonExpired) {
		this.credentialsNonExpired = credentialsNonExpired;
	}

	/**
	 * @return
	 * @see org.springframework.security.core.userdetails.UserDetails#isEnabled()
	 */
	@Override
	public boolean isEnabled() {
		return enabled;
	}

	/**
	 * @param enabled the enabled to set
	 */
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	/**
	 * @return the post
	 */
	public String getPost() {
		return post;
	}

	/**
	 * @param post the post to set
	 */
	public void setPost(String post) {
		this.post = post;
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
	 * @return the email
	 */
	public String getEmail() {
		return email;
	}

	/**
	 * @param email the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * @return the identity
	 */
	public String getIdentity() {
		return identity;
	}

	/**
	 * @param identity the identity to set
	 */
	public void setIdentity(String identity) {
		this.identity = identity;
	}

	/**
	 * @return the address
	 */
	public String getAddress() {
		return address;
	}

	/**
	 * @param address the address to set
	 */
	public void setAddress(String address) {
		this.address = address;
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
	 * @return the gender
	 */
	public String getGender() {
		return gender;
	}

	/**
	 * @param gender the gender to set
	 */
	public void setGender(String gender) {
		this.gender = gender;
	}

	/**
	 * @return the tel
	 */
	public String getTel() {
		return tel;
	}

	/**
	 * @param tel the tel to set
	 */
	public void setTel(String tel) {
		this.tel = tel;
	}

	/**
	 * @return the mobile
	 */
	public String getMobile() {
		return mobile;
	}

	/**
	 * @param mobile the mobile to set
	 */
	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	/**
	 * @return the birthday
	 */
	public Date getBirthday() {
		return birthday;
	}

	/**
	 * @param birthday the birthday to set
	 */
	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}

	/**
	 * @return the org
	 */
	public Org getOrg() {
		return org;
	}

	/**
	 * @param org the org to set
	 */
	public void setOrg(Org org) {
		this.org = org;
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
	 * @return the apps
	 */
	public Set<ViewAppInfoVo> getApps() {
		return apps;
	}

	/**
	 * @param the roles to set
	 */
	public void setApps(Set<ViewAppInfoVo> apps) {
		this.apps = apps;
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

	/**
	 * @return the position
	 */
	public Position getPosition() {
		return position;
	}

	/**
	 * @param position the position to set
	 */
	public void setPosition(Position position) {
		this.position = position;
	}

	// -------------------------------SETTER/GETTER ABOVE-------------------------------

	public void addApp(ViewAppInfoVo app) {
		if (apps == null) {
			apps = new HashSet<ViewAppInfoVo>();
		}
		apps.add(app);
	}

	public void clearApp() {
		if (apps == null) {
			apps = new HashSet<ViewAppInfoVo>();
		}
		apps.clear();
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
		}
		roles.clear();
	}

	/**
	 * @return
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return getName();
	}

	/**
	 * 因为org.springframework.security.core.session. SessionRegistryImpl的成员principals （类型为Map<Object,Set<String>>），是以User的实例为Key，故覆写此方法。
	 */
	@Override
	public int hashCode() {
		return username.hashCode();
	}

	/**
	 * 与覆写hashCode方法的原委一致。
	 */
	@Override
	public boolean equals(Object thatUser) {
		return this.hashCode() == thatUser.hashCode();
	}

	/**
	 * 返回优先类型角色集合.
	 * 
	 * @return
	 */
	public Set<Role> getPriorityRoles() {
		return getRoleByType(Role.TYPE_PRIORITY);
	}

	/**
	 * 返回禁止类型角色集合.
	 * 
	 * @return
	 */
	public Set<Role> getForbiddenRoles() {
		return getRoleByType(Role.TYPE_FORBIDDEN);
	}

	/**
	 * 返回权限类型角色集合.
	 * 
	 * @return
	 */
	public Set<Role> getPermissionRoles() {
		return getRoleByType(Role.TYPE_PERMISSION);
	}

	/**
	 * 根据角色类型返回相应的角色对象集合.
	 * 
	 * @param type 角色类型
	 * @return
	 */
	private Set<Role> getRoleByType(String type) {
		Set<Role> roles = new HashSet<Role>();
		for (Role role : getRoles()) {
			if (role.getType().equalsIgnoreCase(type)) {
				roles.add(role);
			}
		}
		return roles;
	}

}

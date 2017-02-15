/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.service;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.security.authentication.encoding.Md5PasswordEncoder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.vo.RoleProductVo;
import com.nantian.common.system.vo.ViewAppInfoVo;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.BsaConstants;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamStringResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Role;
import com.nantian.jeda.common.model.TransferUser;
import com.nantian.jeda.common.model.User;
import com.nantian.jeda.security.util.SecurityUtils;

/**
 * 用户服务接口.
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Repository
public class UserService {

	/** 日志输出 */
	private static Logger logger = Logger.getLogger(UserService.class);

	/** 查询参数信息.[字段-类型] */
	public Map<String, String> fields = new HashMap<String, String>();

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private SecurityUtils securityUtils;

	@Autowired
	private Md5PasswordEncoder passwordEncoder;
	
	@Autowired
	private BrpmService brpmService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法.初始化查询参数.
	 */
	public UserService() {
		fields.put("username", FieldType.STRING);
		fields.put("name", FieldType.STRING);
		fields.put("email", FieldType.STRING);
		fields.put("birthday", FieldType.DATE);
		fields.put("tel", FieldType.STRING);
		fields.put("mobile", FieldType.STRING);
		fields.put("order", FieldType.INTEGER);
		fields.put("enabled", FieldType.BOOLEAN);
	}

	/**
	 * 保存.
	 * 
	 * @param user
	 */
	@Transactional
	public void save(User user) {
		getSession().save(user);
	}

	/**
	 * 
	 * @param user
	 */
	@Transactional
	public void saveTransferUser(TransferUser user) {
		user.setPassword(passwordEncoder.encodePassword(Constants.DEFAULT_PASSWORD, ""));
		Date date = new Date();
		getSession()
				.createSQLQuery(
						"insert into JEDA_USER(USER_ID,ORG_ID,USER_NAME,USER_PASSWORD,USER_ENABLED,"
								+ "USER_ACCOUNT_NONEXPIRED,USER_ACCOUNT_NONLOCKED,USER_CREDENTIALS_NONEXPIRED,USER_VERSION,"
								+ "USER_CREATOR,USER_CREATED,USER_MODIFIER,USER_MODIFIED) values(?,?,?,?,?,?,?,?,?,?,?,?,?)")
				.setString(0, user.getUsername()).setString(1, user.getOrg()).setString(2, user.getName()).setString(3, user.getPassword())
				.setBoolean(4, user.isEnabled()).setBoolean(5, true).setBoolean(6, true).setBoolean(7, true).setInteger(8, 0).setString(9, "admin")
				.setDate(10, date).setString(11, "admin").setDate(12, date).executeUpdate();
	}

	@Transactional
	public void updateTransferUser(TransferUser user) {
		Date date = new Date();
		getSession().createSQLQuery("update JEDA_USER set ORG_ID=?,USER_NAME=?,USER_ENABLED=?,USER_MODIFIED=? where USER_ID=?")
				.setString(0, user.getOrg()).setString(1, user.getName()).setBoolean(2, user.isEnabled()).setDate(3, date)
				.setString(4, user.getUsername()).executeUpdate();
	}

	/**
	 * 更新.
	 * 
	 * @param user
	 */
	@Transactional
	public void update(User user) {
		getSession().update(user);
	}

	/**
	 * 批量保存.
	 * 
	 * @param users 用户对象集合
	 */
	@Transactional
	public void save(Set<User> users) {
		for (User user : users) {
			getSession().save(user);
		}
	}

	/**
	 * 批量保存或者更新.
	 * 
	 * @param users 用户对象集合
	 */
	@Transactional
	public void saveOrUpdate(Set<User> users) {
		for (User user : users) {
			getSession().saveOrUpdate(user);
		}
	}

	/**
	 * 批量更新.
	 * 
	 * @param users 用户对象集合
	 */
	@Transactional
	public void update(Set<User> users) {
		for (User user : users) {
			getSession().update(user);
		}
	}

	/**
	 * 根据主键查询.
	 * 
	 * @param id 用户主键
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object get(Serializable id) {
		return getSession().get(User.class, id);
	}

	/**
	 * 根据用户名查询.
	 * 
	 * @param username 用户名


	 * @return
	 */
	@Transactional(readOnly = true)
	public Object findByUsername(String username) {
		return getSession()
				.createQuery(
						"select new map(u.username as username, u.name as name, u.gender as gender, u.identity as identity, u.email as email, u.address as address, u.post as post, "
								+ "u.tel as tel, u.mobile as mobile, u.birthday as birthday, u.position.id as position, u.position.name as positionname, "
								+ "u.enabled as enabled, u.enabled as _enabled, u.accountNonExpired as accountNonExpired, u.accountNonLocked as accountNonLocked, "
								+ "u.credentialsNonExpired as credentialsNonExpired, u.org.id as org, u.org.name as orgName, u.order as order, u.version as version) "
								+ "from User u where u.username =? ").setString(0, username).uniqueResult();
	}

	/**
	 * 删除.
	 * 
	 * @param user 用户对象
	 */
	@Transactional
	public void delete(User user) {
		getSession().delete(user);
	}

	/**
	 * 根据用户名删除.
	 * 
	 * @param username 用户名


	 */
	@Transactional
	private void deleteByUsername(String username) {
		getSession().createQuery("delete from User u where u.username=?").setString(0, username).executeUpdate();
		getSession().createQuery("delete from ApposUserVo t where t.userId=?").setString(0, username).executeUpdate();
	}

	/**
	 * 根据用户名批量删除.
	 * 
	 * @param usernames 用户名数组


	 */
	@Transactional
	public void deleteByUsernames(String[] usernames) {
		for (String username : usernames) {
			deleteByUsername(username);
		}
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param org 组织机构ID
	 * @param start 起始记录行数
	 * @param limit 查询记录数量
	 * @param sort 排序字段
	 * @param dir 排序方向
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> find(String org, Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {
		Query query = null;
		String hql = "select new map(u.username as username, u.name as name, u.gender as gender, u.identity as identity, u.email as email, u.address as address, u.post as post, u.tel as tel, u.birthday as birthday, u.position.id as position, u.position.name as positionname, u.enabled as enabled, u.org.id as org, u.org.name as orgname, u.order as order,"
				+ "u.creator.name as creator,u.created as created,u.modifier.name as modifier,u.modified as modified) "
				+ "from User u left join u.creator left join u.modifier where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and u." + key + " like :" + key;
				} else {
					hql += " and u." + key + " = :" + key;
				}
			}
		}
		String orderBy = " order by u." + sort + " " + dir;
		if (org.isEmpty()) {
			hql += " and u.org.path like :path ";
			query = getSession().createQuery(hql + orderBy).setString("path", "%" + securityUtils.getUser().getOrg().getId() + "%");
		} else {
			hql += " and u.org.id=:org";
			query = getSession().createQuery(hql + orderBy).setString("org", org);
		}

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.setFirstResult(start).setMaxResults(limit).list();

	}

	/**
	 * 根据参数查询记录数量.
	 * 
	 * @param org 组织机构ID
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(String org, Map<String, Object> params) {
		Query query = null;
		String hql = "select count(*) from User where 1=1 ";
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql += " and " + key + " like :" + key;
				} else {
					hql += " and " + key + " = :" + key;
				}
			}
		}
		if (org.isEmpty()) {
			hql += " and org.path like :path ";
			query = getSession().createQuery(hql).setString("path", "%" + securityUtils.getUser().getOrg().getId() + "%");
		} else {
			hql += " and org.id=:org";
			query = getSession().createQuery(hql).setString("org", org);
		}

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 保存用户与角色的关联关系.
	 * 
	 * @param ids 角色ID数组
	 * @param username 用户名


	 */
	@Transactional
	public void saveUserRole(String[] ids, String username) {
		Object user = getSession().get(User.class, username);
		if (null != user) {
			((User) user).clearRole();
			for (String id : ids) {
				Object role = getSession().get(Role.class, id);
				if (role != null) {
					((User) user).addRole((Role) role);
				}
			}
			getSession().update(user);
		}

	}
	
	/**
	 * 保存用户与系统的关联关系.
	 * 
	 * @param ids 系统ID数组
	 * @param username 用户名


	 */
	@Transactional
	public void saveUserApp(String[] ids, String username) {
		Object user = getSession().get(User.class, username);
		if (null != user) {
			((User) user).clearApp();
			for (String id : ids) {
				Object app = getSession().get(ViewAppInfoVo.class, id);
				if (app != null) {
					((User) user).addApp((ViewAppInfoVo) app);
				}
			}
			getSession().update(user);
		}
	}
	/**
	 * 更新用户与系统的关联表的系统更新类型.
	 * @param ids 系统ID数组
	 * @param username 用户名
	 */
	public void updateUserApp(String[] ids,String username,String[] dplyFlags,String[] checkFlags,String[] toolFlags) {
		if(ids!=null && ids.length>0){
			for(int t=0 ; t<ids.length ; t++){
				StringBuffer sql = new StringBuffer();
				sql.append(" update cmn_user_app set app_type='H'");
				if(dplyFlags[t]!=null && !dplyFlags[t].equals("")){
					sql.append(" ,dply_flag = '" + dplyFlags[t] + "'");
				}else{
					sql.append(" ,dply_flag = '0'" );
				}
				if(checkFlags[t]!=null && !checkFlags[t].equals("")){
					sql.append(" ,check_flag = '" + checkFlags[t] + "'");
				}else{
					sql.append(" ,check_flag = '0'" );
				}
				if(toolFlags[t]!=null && !toolFlags[t].equals("")){
					sql.append(" ,tool_flag = '" + toolFlags[t] + "'");
				}else{
					sql.append(" ,tool_flag = '0'" );
				}
				sql.append(" where user_id=:username ");
				sql.append(" and appsys_code = '" + ids[t] + "'");
				getSession().createSQLQuery(sql.toString()).setString("username", username).executeUpdate();
			}
		}
	}

	/**
	 * 根据用户名查询用户及其角色与资源信息.
	 * 
	 * @param username 用户名


	 * @return
	 */
	@Transactional(readOnly = true)
	public User loadByUsername(String username) {
		return (User) getSession()
				.createQuery(
						"select u from User u left join fetch u.roles r left join fetch r.functions left join fetch r.permissions "
								+ "where u.username=:username order by u.order asc").setString("username", username).uniqueResult();

	}

	/**
	 * 根据组织机构ID和角色ID查询用户,以树节点格式返回.角色关联用户功能中使用.
	 * 
	 * @param org 组织机构ID
	 * @param role 角色ID
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findByOrgAndRole(String org, String role) {
		return getSession()
				.createQuery(
						"select new map(u.username as id, u.name as text, 1 as leaf, u.username as qtip,'node-user' as iconCls,"
								+ "(case when (select count(*) from Role role inner join role.users user where role.id = :role and user.username = u.username )>0 then true else false end ) as checked) "
								+ "from User u inner join u.position.roles r where u.org.id=:org and r.id = :role").setString("role", role)
				.setString("org", org).list();

	}

	/**
	 * 根据组织机构ID查询用户,以树节点格式返回. 选择用户组件中使用.
	 * 
	 * @param org 组织机构ID
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findByOrg(String org) {
		return getSession()
				.createQuery("select new map(u.username as id, u.name as text, 1 as leaf, u.username as qtip) from User u where u.org.id=:org")
				.setString("org", org).list();

	}

	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> findByOrgAndPermission(String orgId, String permissionId) {
		return getSession()
				.createQuery(
						"select new map(u.username as id, u.name as text, 1 as leaf, u.username as qtip,'node-user' as iconCls,"
								+ "(case when (select count(*) from Permission p inner join p.associatedUsers user where p.id = :permissionId and user.username = u.username )>0 then true else false end ) as checked) "
								+ "from User u where u.org.id=:orgId").setString("permissionId", permissionId).setString("orgId", orgId).list();

	}
	
	/**
	 * 同步用户至brpm.
	 * @param usernames 用户ID列表
	 * @param checkMsg 异常信息
	 * @return 同步用户数
	 * @throws Exception
	 */
	public String syncUserToBrpm(String[] usernames, StringBuilder checkMsg) throws Exception {
		User user = null;
		String errorUsername = ""; //同步失败的用户ID
		int syncNum = 0;
		boolean syncFlag = false;
		String resVal = null;
		Map<String,String> brpmUserMap = new HashMap<String,String>();
		//文档对象
		Document document = null;
		//要素
		Element element = null;
		//要素
		Element rolesElement = null;
		//输出对象
		XMLOutputter outputter = null;
		try{
			//获取brpm已经存在用户列表及对应id
			Document doc = JDOMParserUtil.xmlParse(brpmService.getMethod(BrpmConstants.KEYWORD_USER));
			//获得所有子要素集合
			List<Element> accounts =doc.getRootElement().getChildren();
			//获得所有用户登录名及唯一ID值
			for(Element account : accounts){
				brpmUserMap.put(account.getChildTextTrim("login"), account.getChildTextTrim("id"));
			}
			//同步
			for (String userName : usernames) {
				syncFlag = false;
				user = (User) loadByUsername(userName);
				//关联角色列表
				rolesElement = new Element("roles").setAttribute("type", "array");
				if(user.getRoles().size() != 0){
					for (Role role : user.getRoles()) {
						if(role.getRoleBrpms().size() != 0){
							for (RoleProductVo vo : role.getRoleBrpms()) {
								if (logger.isEnableFor("Common0002")) {
									logger.log("Common0002", vo.getProRoleId());
								}
								rolesElement.addContent(new Element("role").addContent(vo.getProRoleId()));
								syncFlag = true;
							}
						}else{
							checkMsg.append(">><span style=\"color:red\">")
										.append(user.getUsername())
										.append(CommonConst.SPACE)
										.append(user.getName())
										.append(CommonConst.SPACE)
										.append(role.getName())
										.append(CommonConst.SPACE)
										.append("该用户角色未关联brpm角色</span>").append("<br>");
						}
					}
				}else{
					checkMsg.append(">><span style=\"color:red\">")
								.append(user.getName())
								.append(CommonConst.SPACE)
								.append("该用户未分配平台角色</span>").append("<br>");
				}
				//同步操作
				if(syncFlag){
					if(!brpmUserMap.keySet().contains(userName)){
						//不存在该用户，新建用户
						//编辑用户XMLdata
						element = new Element("user");
						document = new Document(element);
						//登录账号
						element.addContent(new Element("login").addContent(user.getUsername()));
						element.addContent(new Element("first_name").addContent(user.getUsername()));
						element.addContent(new Element("last_name").addContent(user.getEmail().split(CommonConst.REPLACE_CHAR)[0]));
						element.addContent(new Element("password").addContent(BrpmConstants.DEFAULT_PASSWORD));
						element.addContent(new Element("password_confirmation").addContent(BrpmConstants.DEFAULT_PASSWORD));
						element.addContent(new Element("time_zone").addContent(BrpmConstants.USER_ATTRI_TIMEZONE_BEIJING));
						element.addContent(rolesElement);
						element.addContent(new Element("email").addContent(user.getEmail()));
						//将 JDOM 转化为 XML 文本
						outputter = new XMLOutputter();
						//调用BRPM API新建用户
						if (logger.isEnableFor("Common0002")) {
							logger.log("Common0002", outputter.outputString(document));
						}
						resVal = brpmService.postMethod(BrpmConstants.KEYWORD_USER, outputter.outputString(document));
						if(null != resVal){
							//更新用户关联app
							Document userDoc = JDOMParserUtil.xmlParse(resVal);
							Element userRoot = userDoc.getRootElement();
							updateBrpmUserApp(user, userRoot.getChildText("id"));
						}
					}else{
						//存在该用户，更新用户
						//编辑用户XMLdata
						element = new Element("user");
						document = new Document(element);
						
						element.addContent(new Element("first_name").addContent(user.getUsername()));
						element.addContent(new Element("last_name").addContent(user.getEmail().split(CommonConst.REPLACE_CHAR)[0]));
						element.addContent(rolesElement);
						element.addContent(new Element("email").addContent(user.getEmail()));
						//将 JDOM 转化为 XML 文本
						outputter = new XMLOutputter();
						//调用BRPM API更新用户信息
						if (logger.isEnableFor("Common0002")) {
							logger.log("Common0002", outputter.outputString(document));
						}
						brpmService.putMethod(BrpmConstants.KEYWORD_USER, brpmUserMap.get(userName), outputter.outputString(document));
						//更新用户关联app
						updateBrpmUserApp(user, brpmUserMap.get(userName));
					}
					syncNum++;
				}else{
					errorUsername = errorUsername + "," + userName ;
				}
			}
		}catch(Exception e){
			throw e;
		}
		if(!errorUsername.equals("")){
			errorUsername = errorUsername.substring(1);
		}
		return String.valueOf(syncNum).concat("#").concat(errorUsername);
	}

	
	/**
	 * 更新BRPM用户关联app.
	 * 
	 * @param user 当前用户对象
	 * @param brpmUserId brpm中用户唯一id
	 * @throws Exception 
	 */
	private void updateBrpmUserApp(User user, String brpmUserId) throws Exception{
		//api返回值

		String resVal = null;
		//brpm中app已经关联的用户列表

		List<String> appHasUserIds = null;
		//文档对象
		Document document = null;
		//要素
		Element element = null;
		//要素
		Element usersElement = null;
		//输出对象
		XMLOutputter outputter = null;
		
//		//删除用户关联所有应用

		//brpmService.deleteAssignedApps(brpmUserId);
		
		for (ViewAppInfoVo app : user.getApps()) {
			//根据用户ID、系统编码获取dply权限值
			String dplyFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"dply");
			if(dplyFlag.equals("1")){
				resVal = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS, "{\"filters\": {\"name\":\"".concat(app.getAppsysCode()).concat("\"}}"));
				if(null != resVal){
					Document appDoc = JDOMParserUtil.xmlParse(resVal);
					List<Element> apps = appDoc.getRootElement().getChildren();//获得所有子要素集合
					for (Element appEle : apps) {
						appHasUserIds = new ArrayList<String>();
						List<Element> users = appEle.getChild("users").getChildren();
						for (Element userEle : users) {
							appHasUserIds.add(userEle.getChildText("id"));
						}
						if(!appHasUserIds.contains(brpmUserId)){
	//						//编辑app关联用户xml
	//						element = new Element("app");
	//						document = new Document(element);
	//						usersElement = new Element("user_ids").setAttribute("type", "array");
	//						outputter = new XMLOutputter();
	//						for (String userId : appHasUserIds) {
	//							usersElement.addContent(new Element("id").setAttribute("type","integer").addContent(userId));
	//						}
	//						usersElement.addContent(new Element("id").setAttribute("type","integer").addContent(brpmUserId));
	//						element.addContent(usersElement);
	//						if (logger.isEnableFor("Common0002")) {
	//							logger.log("Common0002", outputter.outputString(document));
	//						}
	//						//调用BRPM API更新应用信息
	//						brpmService.putMethod(BrpmConstants.KEYWORD_APPS, appEle.getChildText("id"), outputter.outputString(document));
							
							//API替代方案，直接修改数据库
							brpmService.saveAssignedApps(brpmUserId, appEle.getChildText("id"));
							
							String appXml = brpmService.getMethodByFilter(BrpmConstants.KEYWORD_APPS,"{ \"filters\": { \"name\":\"" + appEle.getChildText("name") + "\" }}");
							Document appdoc = JDOMParserUtil.xmlParse(appXml);
							Element approot = appdoc.getRootElement();
							List<Element> appaccounts = approot.getChildren();
							for (Element account : appaccounts) {
								List<Element> environmentList = account.getChild("environments").getChildren();
								//获取当前用户的授权环境
								List<String> userEnvs = getEnvsByUserIsAndSysCode(user.getUsername());
								//过滤不在权限范围内的系统环境
								if(environmentList!=null && environmentList.size()>0){
									//需要删除的系统环境
									List<Element> delEnvList = new ArrayList<Element>();
									for(Element environment : environmentList){
										String brpmAuth = environment.getChildText("name") ;
										String brpmEnv = brpmAuth.substring(brpmAuth.indexOf("_")+1, brpmAuth.lastIndexOf("_"));
										if(!userEnvs.contains(brpmEnv)){
											delEnvList.add(environment);
										}
									}
									if(delEnvList!=null && delEnvList.size()>0){
										environmentList.removeAll(delEnvList);
									}
								}
								brpmService.saveAssignedAppsEnvironments(brpmUserId, appEle.getChildText("id"), environmentList);
							}
						}
					}
				}
			}
		}
	}
	
	/**
	 * 同步用户至bsa.
	 * 
	 * @param usernames 用户ID列表
	 * @param checkMsg 异常信息
	 * @return 同步用户数
	 * @throws Exception 
	 */
	public String syncUserToBsaForCheck(String[] usernames, StringBuilder checkMsg) throws Exception {
		User user = null;
		String errorUsername = ""; //同步失败的用户ID
		int syncNum = 0;
		boolean syncFlag = false;
		List<String> relBsaRoles = new ArrayList<String>();
		List<String> appDplyRoles = null;
		List<String> appCheckRoles = null;
		List<String> existUsers = new ArrayList<String>();
		List<String> userRolesInBsa = null;
		String[] existUsera = null;
		String[] existRolea = null;
		//BSA定义
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		CLITunnelServiceClient client4Cli = null;
		ExecuteCommandByParamStringResponse res4Users = null;
		ExecuteCommandByParamStringResponse res4Roles = null;
		ExecuteCommandByParamListResponse res4AddRole = null;
		ExecuteCommandByParamListResponse res4CreateUser = null;
		ExecuteCommandByParamListResponse res4BelongsRole = null;
		ExecuteCommandByParamListResponse res4RemoveRole = null;
		
		//用户登录
		loginClient = new LoginServiceClient(messages.getMessage("bsa.userNameRbac"), 
																					messages.getMessage("bsa.userPassword"),
																					messages.getMessage("bsa.authenticationType"), null,
																					System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
																					messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(),null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac"));
		//获取bsa已存在用户列表


		client4Cli = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		res4Users = client4Cli.executeCommandByParamString("RBACUser", "listAllUserNames");
		if(null != res4Users.get_return().getReturnValue()){
			existUsera = res4Users.get_return().getReturnValue().toString().split(CommonConst.LINE_FEED);
			for (String userName : existUsera) {
				existUsers.add(userName);
			}
		}
		//获取bsa已存在角色列表
		res4Roles = client4Cli.executeCommandByParamString("RBACRole", "listAllRoleNames");
		if(null != res4Roles.get_return().getReturnValue()){
			existRolea = res4Roles.get_return().getReturnValue().toString().split(CommonConst.LINE_FEED);
		}
		//同步用户
		String dplyFlag = null;
		String checkFlag = null;
		for (String userName : usernames) {
			syncFlag = false;
			user = (User) loadByUsername(userName);
			//获取用户关联系统角色列表
			appDplyRoles = new ArrayList<String>();
			appCheckRoles = new ArrayList<String>();
			for (ViewAppInfoVo app : user.getApps()) {
				//获取当前用户对该系统是否有应用发布权限
				dplyFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"dply");
				if(dplyFlag.equals("1")){
					//获取当前用户的授权环境
					List<String> userEnvs = getEnvsByUserIsAndSysCode(user.getUsername());
					for(String userEnv : userEnvs){
						if(app.getAppsysCode().equals("COMMON")){
							appDplyRoles.add(app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_SYS_ROLE_KEY));
						}else{
							appDplyRoles.add(app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_APP_ROLE_KEY));
						}
					}
				}
				//获取当前用户对该系统是否有巡检权限
				checkFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"check");
				if(checkFlag.equals("1")){
					if(app.getAppsysCode().equals("COMMON")){
						appCheckRoles.add(app.getAppsysCode().concat(BsaConstants.DEFAULT_SYS_ROLE_KEY));
					}else{
						appCheckRoles.add(app.getAppsysCode().concat(BsaConstants.DEFAULT_APP_ROLE_KEY));
					}
				}
			}
			//关联角色列表
			if(user.getRoles().size() != 0){
				for (Role role : user.getRoles()) {
					if(role.getRoleBsas().size() != 0 || appCheckRoles.size() != 0){
						syncFlag = true;
						for (RoleProductVo vo : role.getRoleBsas()) {
							if (logger.isEnableFor("Common0002")) {
								logger.log("Common0002", vo.getProRoleId());
							}
							if(CommonConst.ONE_INT == vo.getProRoleIsrelationApp()){
								for (ViewAppInfoVo app : user.getApps()) {
									if(!relBsaRoles.contains(app.getAppsysCode().concat(CommonConst.UNDERLINE).concat(vo.getProRoleId()))){
										//获取当前用户对该系统是否有巡检权限
										checkFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"check");
										if(checkFlag.equals("1")){
											relBsaRoles.add(app.getAppsysCode().concat(CommonConst.UNDERLINE).concat(vo.getProRoleId()));
										}
									}
								}
							}else{
								if(!relBsaRoles.contains(vo.getProRoleId())){
									relBsaRoles.add(vo.getProRoleId());
								}
							}
						}
					}/*else{
						checkMsg.append(">><span style=\"color:red\">")
									.append(user.getUsername())
									.append(CommonConst.SPACE)
									.append(user.getName())
									.append(CommonConst.SPACE)
									.append(role.getName())
									.append(CommonConst.SPACE)
									.append("请关联该用户BSA角色或指定用户关联应用系统</span>").append("<br>");
					}*/
				}
			}else{
				checkMsg.append(">><span style=\"color:red\">")
							.append(user.getName())
							.append(CommonConst.SPACE)
							.append("该用户未分配平台角色</span>").append("<br>");
			}
			//同步操作
			if(syncFlag){
				if(!existUsers.contains(userName)){
					//不存在该用户，新建用户
					res4CreateUser = client4Cli.executeCommandByParamList("RBACUser", "createUser", new String[]{userName,BsaConstants.DEFAULT_PASSWORD,user.getName()});
					for (String role : relBsaRoles) {
						res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, role});
					}
					for (ViewAppInfoVo app : user.getApps()) {
						//获取当前用户对该系统是否有巡检权限
						checkFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"check");
						if(checkFlag.equals("1")){
							res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, app.getAppsysCode().concat(BsaConstants.DEFAULT_APP_ROLE_KEY)});
							if(app.getAppsysCode().equals("COMMON")){ //针对COMMON系统增加SYSADMIN策略
								res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, app.getAppsysCode().concat(BsaConstants.DEFAULT_SYS_ROLE_KEY)});
							}
						}
					}
				}else{
					//存在该用户，更新用户角色
					//查询用户在bsa中的角色
					userRolesInBsa = new ArrayList<String>();
					for (String userRoleInBsa: existRolea) {
						res4BelongsRole = client4Cli.executeCommandByParamList("RBACUser", "belongsToRole", new String[]{userName, userRoleInBsa});
						if(res4BelongsRole.get_return().getSuccess() == true && "true".equals(res4BelongsRole.get_return().getReturnValue())){
							userRolesInBsa.add(userRoleInBsa);
						}
					}
					//添加关联角色
					for (String role : relBsaRoles) {
						if(!userRolesInBsa.contains(role)){
							res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, role});
						}
					}
					//添加用户关联系统角色
					for (String appCheckRole : appCheckRoles) {
						if(!userRolesInBsa.contains(appCheckRole)){
							res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, appCheckRole});
						}
					}
					//删除用户多余角色
					for(String role : userRolesInBsa){
						if(!relBsaRoles.contains(role) && !appCheckRoles.contains(role) && !appDplyRoles.contains(role)){
							res4RemoveRole = client4Cli.executeCommandByParamList("RBACUser", "removeRole", new String[]{userName, role});
						}
					}
				}
				syncNum++;
			}else{
				errorUsername = errorUsername + "," + userName;
			}
		}
		if(!errorUsername.equals("")){
			errorUsername = errorUsername.substring(1);
		}
		return String.valueOf(syncNum).concat("#").concat(errorUsername);
	}
	
	/**
	 * 同步用户至bsa_用于应用发布.
	 * 
	 * @param usernames 用户ID列表
	 * @param checkMsg 异常信息
	 * @return 同步用户数
	 * @throws Exception 
	 */
	public String syncUserToBsaForDply(String[] usernames, StringBuilder checkMsg) throws Exception {
		User user = null;
		String errorUsername = ""; //同步失败的用户ID
		int syncNum = 0;
		boolean syncFlag = false;
		List<String> relBsaRoles = new ArrayList<String>();
		List<String> appDplyRoles = null;
		List<String> appCheckRoles = null;
		List<String> existUsers = new ArrayList<String>();
		List<String> userRolesInBsa = null;
		String[] existUsera = null;
		String[] existRolea = null;
		//BSA定义
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		CLITunnelServiceClient client4Cli = null;
		ExecuteCommandByParamStringResponse res4Users = null;
		ExecuteCommandByParamStringResponse res4Roles = null;
		ExecuteCommandByParamListResponse res4AddRole = null;
		ExecuteCommandByParamListResponse res4CreateUser = null;
		ExecuteCommandByParamListResponse res4BelongsRole = null;
		ExecuteCommandByParamListResponse res4RemoveRole = null;
		
		//用户登录
		loginClient = new LoginServiceClient(messages.getMessage("bsa.userNameRbac"), 
																					messages.getMessage("bsa.userPassword"),
																					messages.getMessage("bsa.authenticationType"), null,
																					System.getProperty("maop.root").concat(File.separator).concat(messages.getMessage("bsa.truststoreFile")),
																					messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		//设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(),null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac"));
		//获取bsa已存在用户列表


		client4Cli = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		res4Users = client4Cli.executeCommandByParamString("RBACUser", "listAllUserNames");
		if(null != res4Users.get_return().getReturnValue()){
			existUsera = res4Users.get_return().getReturnValue().toString().split(CommonConst.LINE_FEED);
			for (String userName : existUsera) {
				existUsers.add(userName);
			}
		}
		//获取bsa已存在角色列表
		res4Roles = client4Cli.executeCommandByParamString("RBACRole", "listAllRoleNames");
		if(null != res4Roles.get_return().getReturnValue()){
			existRolea = res4Roles.get_return().getReturnValue().toString().split(CommonConst.LINE_FEED);
		}
		//同步用户
		String dplyFlag = null;
		String checkFlag = null;
		for (String userName : usernames) {
			syncFlag = false;
			user = (User) loadByUsername(userName);
			//获取用户关联系统角色列表
			appDplyRoles = new ArrayList<String>();
			appCheckRoles = new ArrayList<String>();
			for (ViewAppInfoVo app : user.getApps()) {
				//获取当前用户对该系统是否有应用发布权限				dplyFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"dply");
				if(dplyFlag.equals("1")){
					//获取当前用户的授权环境					List<String> userEnvs = getEnvsByUserIsAndSysCode(user.getUsername());
					for(String userEnv : userEnvs){
						if(app.getAppsysCode().equals("COMMON")){
							appDplyRoles.add(app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_SYS_ROLE_KEY));
						}else{
							appDplyRoles.add(app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_APP_ROLE_KEY));
						}
					}
				}
				
				//获取当前用户对该系统是否有巡检权限
				checkFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"check");
				if(checkFlag.equals("1")){
					if(app.getAppsysCode().equals("COMMON")){
						appCheckRoles.add(app.getAppsysCode().concat(BsaConstants.DEFAULT_SYS_ROLE_KEY));
					}else{
						appCheckRoles.add(app.getAppsysCode().concat(BsaConstants.DEFAULT_APP_ROLE_KEY));
					}
				}
				
				
			}
			//关联角色列表
			if(user.getRoles().size() != 0){
				for (Role role : user.getRoles()) {
					if(role.getRoleBsas().size() != 0 || appDplyRoles.size() != 0){
						syncFlag = true;
						for (RoleProductVo vo : role.getRoleBsas()) {
							if (logger.isEnableFor("Common0002")) {
								logger.log("Common0002", vo.getProRoleId());
							}
							if(CommonConst.ONE_INT == vo.getProRoleIsrelationApp()){
								for (ViewAppInfoVo app : user.getApps()) {
									if(!relBsaRoles.contains(app.getAppsysCode().concat(CommonConst.UNDERLINE).concat(vo.getProRoleId()))){
										//获取当前用户对该系统是否有应用发布权限										dplyFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"dply");
										if(dplyFlag.equals("1")){
											//获取当前用户的授权环境											List<String> userEnvs = getEnvsByUserIsAndSysCode(user.getUsername());
											for(String userEnv : userEnvs){
												relBsaRoles.add(app.getAppsysCode().concat("_"+userEnv).concat(CommonConst.UNDERLINE).concat(vo.getProRoleId()));
											}
										}
									}
								}
							}else{
								if(!relBsaRoles.contains(vo.getProRoleId())){
									relBsaRoles.add(vo.getProRoleId());
								}
							}
						}
					}else{
						checkMsg.append(">><span style=\"color:red\">")
									.append(user.getUsername())
									.append(CommonConst.SPACE)
									.append(user.getName())
									.append(CommonConst.SPACE)
									.append(role.getName())
									.append(CommonConst.SPACE)
									.append("请关联该用户BSA角色或指定用户关联应用系统</span>").append("<br>");
					}
				}
			}else{
				checkMsg.append(">><span style=\"color:red\">")
							.append(user.getName())
							.append(CommonConst.SPACE)
							.append("该用户未分配平台角色</span>").append("<br>");
			}
			//同步操作
			if(syncFlag){
				if(!existUsers.contains(userName)){
					//不存在该用户，新建用户					res4CreateUser = client4Cli.executeCommandByParamList("RBACUser", "createUser", new String[]{userName,BsaConstants.DEFAULT_PASSWORD,user.getName()});
					for (String role : relBsaRoles) {
						res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, role});
					}
					for (ViewAppInfoVo app : user.getApps()) {
						//获取当前用户对该系统是否有应用发布权限						dplyFlag = getDplyFlagByUserIsAndSysCode(user.getUsername(),app.getAppsysCode(),"dply");
						if(dplyFlag.equals("1")){
							//获取当前用户的授权环境							List<String> userEnvs = getEnvsByUserIsAndSysCode(user.getUsername());
							for(String userEnv : userEnvs){
								res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_APP_ROLE_KEY)});
								if(app.getAppsysCode().equals("COMMON")){ //针对COMMON系统增加SYSADMIN策略
									res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, app.getAppsysCode().concat("_"+userEnv).concat(BsaConstants.DEFAULT_SYS_ROLE_KEY)});
								}
							}
						}
					}
				}else{
					//存在该用户，更新用户角色
					//查询用户在bsa中的角色
					userRolesInBsa = new ArrayList<String>();
					for (String userRoleInBsa: existRolea) {
						res4BelongsRole = client4Cli.executeCommandByParamList("RBACUser", "belongsToRole", new String[]{userName, userRoleInBsa});
						if(res4BelongsRole.get_return().getSuccess() == true && "true".equals(res4BelongsRole.get_return().getReturnValue())){
							userRolesInBsa.add(userRoleInBsa);
						}
					}
					//添加关联角色
					for (String role : relBsaRoles) {
						if(!userRolesInBsa.contains(role)){
							res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, role});
						}
					}
					//添加用户关联系统角色
					for (String appDplyRole : appDplyRoles) {
						if(!userRolesInBsa.contains(appDplyRole)){
							res4AddRole = client4Cli.executeCommandByParamList("RBACUser", "addRole", new String[]{userName, appDplyRole});
						}
					}
					//删除用户多余角色
					for(String role : userRolesInBsa){
						if(!relBsaRoles.contains(role) && !appDplyRoles.contains(role) && !appCheckRoles.contains(role)){
							res4RemoveRole = client4Cli.executeCommandByParamList("RBACUser", "removeRole", new String[]{userName, role});
						}
					}
				}
				syncNum++;
			}else{
				errorUsername = errorUsername + "," + userName;
			}
		}
		if(!errorUsername.equals("")){
			errorUsername = errorUsername.substring(1);
		}
		return String.valueOf(syncNum).concat("#").concat(errorUsername);
	}
	
	/**
	 * 查询用户信息列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object getUsers(){
		StringBuilder sql = new StringBuilder();
		sql.append("select u.USER_ID as \"username\",u.USER_NAME as \"name\" ")
		  	.append(" from JEDA_USER u ");
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 查询用户信息列表
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object getUserIdNames(){
		StringBuilder sql = new StringBuilder();
		sql.append("select u.USER_ID as \"username\",u.USER_ID ||'(' || u.USER_NAME || ')' as \"name\" ")
		  	.append(" from JEDA_USER u ");
		return getSession().createSQLQuery(sql.toString()).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}

	
	 /**
	  * 根据用户信息查询系统.
	  * 
	  * @return
	  */
	 @Transactional(readOnly = true)
	 public Object findByUser4Env(String user) {
	  String sql = "select env.sub_item_value as \"id\", " +
	    " env.sub_item_name as \"envName\", " +
	    " (case when (select count(*) from cmn_user_env ue " +
	    " where ue.user_id=:username and ue.env = env.sub_item_value)>0 " +
	    " then 'true' else 'false' end ) as \"checked\" " +
	    " from jeda_sub_item env where item_id='SYSTEM_ENVIRONMENT' ";
	  return getSession().createSQLQuery(sql).setString("username", user).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	 }

	
	/**
	 * 根据用户信息查询系统.
	 * 
	 * @return
	 */
	@Transactional(readOnly = true)
	public void saveUserEnv(String[] ids, String username) {
		String delSql = "delete cmn_user_env where user_id=:user_id";
		getSession().createSQLQuery(delSql).setString("user_id", username).executeUpdate();
		String addSql = null;
		for(int i=0;i<ids.length;i++){
			addSql = "insert into cmn_user_env(user_id,env) values(:user_id,:env) ";
	    	getSession().createSQLQuery(addSql.toString()).setString("user_id", username).setString("env", ids[i]).executeUpdate();
		}
	}
	
	/**
	 * 获取当前用户的环境列表

	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<String> getPersonalEnvs(){
    	List<String> envList = new ArrayList<String>();
		StringBuilder sql = new StringBuilder();
		sql.append(" select ce.environment_code as \"envCode\" from cmn_environment ce WHERE CE.environment_type IN (")
		.append(" select env.sub_item_value as id from jeda_sub_item env where item_id='SYSTEM_ENVIRONMENT' and ")
		.append(" (select count(*) from cmn_user_env ue  where ue.user_id=:userId and ue.env = env.sub_item_value)>0)  ")
		.append(" order by ce.environment_code ");
		List<Map<String, Object>> list = getSession().createSQLQuery(sql.toString())
												.setString("userId", securityUtils.getUser().getUsername())
												.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
												.list();
		
    	if(list == null || (list != null && list.size() == 0)){
    		envList.add("");
    	}else{
    		envList = new ArrayList<String>();
    		for (Map<String, Object> map : list) {
    			envList.add(map.get("envCode").toString());
    		}
    	}
		
    	return envList;
	}
	
	/**
	 * 根据用户编号、系统编号、权限类型，获取对应的授权值.
	 * @param username 用户ID
	 * @param appsysCode 应用系统编码
	 * @param type 权限分类(dply/check/tool)
	 */
	@SuppressWarnings("unchecked")
	public String getDplyFlagByUserIsAndSysCode(String username,String appsysCode,String type) {
		String typeFlag = "";
		StringBuffer sql = new StringBuffer();
		if(type!=null && type.equals("dply")){
			sql.append(" select dply_flag ");
		}else if(type!=null && type.equals("check")){
			sql.append(" select check_flag ");
		}else if(type!=null && type.equals("tool")){
			sql.append(" select tool_flag ");
		}
		if(sql!=null && !sql.toString().equals("")){
			sql.append(" from cmn_user_app");
			sql.append(" where user_id='"+username+"'");
			sql.append(" and appsys_code='"+appsysCode+"'");
			List<String> list = getSession().createSQLQuery(sql.toString()).list();
			if(list!=null && list.size()>0){
				typeFlag = String.valueOf(list.get(0));
			}
		}
		return typeFlag;
	}
	
	/**
	 * 根据用户编号获取授权环境.
	 * @param username 用户ID
	 */
	@SuppressWarnings("unchecked")
	public List<String> getEnvsByUserIsAndSysCode(String username) {
		StringBuffer sql = new StringBuffer();
		sql.append(" select ");
		sql.append(" case when env='1' then 'DEV' ");
		sql.append(" when env='2' then 'QA' ");
		sql.append(" when env='3' then 'PROV' ");
		sql.append(" when env='4' then 'PROD' ");
		sql.append(" else env end as env ");
		sql.append(" from cmn_user_env");
		sql.append(" where user_id='"+username+"'");
		List<String> list = getSession().createSQLQuery(sql.toString()).list();
		return list;
	}
}

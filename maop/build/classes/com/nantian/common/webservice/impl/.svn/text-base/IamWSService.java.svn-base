package com.nantian.common.webservice.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.encoding.Md5PasswordEncoder;

import com.nantian.common.system.service.IamStatusService;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.JDOMParserUtil;
import com.nantian.common.webservice.IIamWSService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.common.model.Position;
import com.nantian.jeda.common.model.User;
import com.nantian.jeda.security.service.OrgService;
import com.nantian.jeda.security.service.PositionService;
import com.nantian.jeda.security.service.UserService;

/**
 * MAOP IAM web serive服务类
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 *
 */
public class IamWSService implements IIamWSService{
	
	@Autowired
	private UserService userService;
	
	@Autowired
	private OrgService orgService;
	
	@Autowired
	private PositionService positionService;
	
	@Autowired
	private IamStatusService iamStatusService;
	
	@Autowired
	private Md5PasswordEncoder passwordEncoder;
	
	/**
	 * 6.2.1.1.1.2.1	单个从帐号查询接口
	 * 根据从帐号ID获取从帐号信息
	 * @param userID  从帐号ID
	 * @return 从帐号信息
	 */
	public String findUser(String userID){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element accountElement = null;//子要素
		XMLOutputter outputter = null;//输出对象
		try {
			//查询用户
			User user = userService.loadByUsername(userID);
			//编辑XML并输出
			rootElement = new Element("accounts");
			resultDocument = new Document(rootElement);
			rootElement.addContent("");//添加空值，解决未得到从账号返回数据格式不正确问题
			if(null != user){
				//创建一个 Document
				accountElement = new Element("account");
				rootElement.addContent(accountElement);
				//用简洁形式添加元素
				accountElement.addContent(new Element("accId").addContent(user.getUsername()));//账号ID
				accountElement.addContent(new Element("userPassword").addContent(user.getPassword()));//密码
				accountElement.addContent(new Element("name").addContent(user.getName()));//姓名
				accountElement.addContent(new Element("employeeNumber").addContent(""));//工号
				accountElement.addContent(new Element("employeeType").addContent(""));//员工类型
				accountElement.addContent(new Element("idCardNumber").addContent(user.getIdentity()));//身份证号码
				accountElement.addContent(new Element("postOfficeBox").addContent(user.getEmail()));//邮箱
				accountElement.addContent(new Element("telephoneNumber").addContent(user.getTel()));//电话号码
				accountElement.addContent(new Element("mobile").addContent(user.getMobile()));//用户移动电话
				accountElement.addContent(new Element("address").addContent(user.getAddress()));//地址
				accountElement.addContent(new Element("gender").addContent(user.getGender()));//性别
				accountElement.addContent(new Element("workOrg").addContent(user.getOrg().getName()));//所属组织结构
				accountElement.addContent(new Element("status").addContent(String.valueOf(user.isEnabled())));//用户状态
				accountElement.addContent(new Element("endTime").addContent(""));//用户结束生效时间
				accountElement.addContent(new Element("birthday").addContent((null != user.getBirthday() && !"".equals(user.getBirthday()))?DateFunction.convertDateToStr(user.getBirthday(), 6):""));//生日
				accountElement.addContent(new Element("religion").addContent(""));//政治面貌
				accountElement.addContent(new Element("nation").addContent(""));//民族
				accountElement.addContent(new Element("duty").addContent(""));//职务
				accountElement.addContent(new Element("supporterCorpName").addContent(""));//所在公司
//				accountElement.addContent(new Element("position").addContent(String.valueOf(user.getPosition().getName())));//岗位
			}
			//将 JDOM 转化为 XML 文本
		    outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		} catch (java.io.IOException e) {
			System.out.println(e.getMessage());
		    e.printStackTrace();
		}
		return xml;
	}
		
	/**
	 * 6.2.1.1.1.2.2	从帐号总数查询接口
	 * 获取应用系统从帐号总数
	 * @param 无
	 * @return 从帐号总数
	 */
	public String getUserAmount(){
		//预留接口，暂时不实现
		return "-1";
	}
	
	/**
	 * 6.2.1.1.1.2.3	全部从帐号信息查询接口
	 * 获取应用系统的所有从帐号的信息列表
	 * @param 无
	 * @return 从帐号信息列表
	 */
	public String queryUsers(){
		//预留接口，暂时不实现
		return "";
	}
	
	/**
	 * 6.2.1.1.1.2.4	分页查询从帐号接口
	 * 获取应用系统的所有从帐号的信息列表（分页查询）
	 * @param  pageSize 分页大小
	 * @param  pageNum 页数
	 * @return 从帐号信息列表
	 */
	public String queryUsersByPage(String pageSize,String pageNum){
		//预留接口，暂时不实现
		return "";
	}
	
	/**
	 * 6.2.1.1.1.2.5	全部组织机构查询接口
	 * 获取全部的组织机构
	 * @param  无
	 * @return 组织机构信息列表
	 */
	public String queryOrgs(){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element orgElement = null;//子要素
		XMLOutputter outputter = null;//输出对象
		List<String> existOrg = new ArrayList<String>();//XML已经存在的org
		try{
			//查询所有组织机构
			List<Org> orgs = orgService.findAll();
			
			//编辑XML并输出
			rootElement = new Element("orgs");
			resultDocument = new Document(rootElement);
			rootElement.addContent("");//添加空值，解决未得到从账号返回数据格式不正确问题
			for (Org org : orgs) {
				if(!existOrg.contains(org.getId())){
					existOrg.add(org.getId());
					//创建一个 Document
					orgElement = new Element("org");
					rootElement.addContent(orgElement);
					//用简洁形式添加元素
					orgElement.addContent(new Element("orgId").addContent(org.getId()));//组织机构ID
					orgElement.addContent(new Element("name").addContent(org.getName()));//组织机构名称
					orgElement.addContent(new Element("parentOrgId").addContent(null != org.getParent()?org.getParent().getId():""));//父组织机构ID
					orgElement.addContent(new Element("initials").addContent(""));//组织机构简称
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}
	
	/**
	 * 全部岗位查询接口
	 * 获取全部的岗位
	 * @param  无
	 * @return 岗位信息列表
	 */
	public String queryPositions(){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element positionElement = null;//子要素
		XMLOutputter outputter = null;//输出对象
		Map<String, Object> params = new HashMap<String, Object>();
		try{
			//查询所有组织机构
			List<Map<String, String>> positions = positionService.find(0, 3000, "id", "asc", params);
			
			//编辑XML并输出
			rootElement = new Element("positions");
			resultDocument = new Document(rootElement);
			rootElement.addContent("");//添加空值，解决未得到从账号返回数据格式不正确问题
			for (Map<String,String> position : positions) {
				//创建一个 Document
				positionElement = new Element("position");
				rootElement.addContent(positionElement);
				//用简洁形式添加元素
				positionElement.addContent(new Element("positionId").addContent(String.valueOf(position.get("id"))));//岗位ID
				positionElement.addContent(new Element("name").addContent(position.get("name")));//岗位名称
				positionElement.addContent(new Element("description").addContent(position.get("description")));//岗位描述
				positionElement.addContent(new Element("type").addContent(position.get("type")));//岗位类型
				switch(ComUtil.changeToChar(position.get("type"))){
				case '0' :
					positionElement.addContent(new Element("typeDescription").addContent("全局"));//岗位类型描述
					break;
				case '1' :
					positionElement.addContent(new Element("typeDescription").addContent("指定机构"));//岗位类型描述
					break;
				case '2' :
					positionElement.addContent(new Element("typeDescription").addContent("指定级别"));//岗位类型描述
					break;
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}
	
	/**
	 * 6.2.1.1.2.2.1	从帐号添加接口
	 * 在应用系统中添加帐号
	 * @param  userInfos从帐号信息列表
	 * @return 操作结果信息
	 */
	public String addUserInfo(String userInfos){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element okElement = null;//成功要素
		Element errElement = null;//失败要素
		XMLOutputter outputter = null;
		List<String> okList = new ArrayList<String>();//正常列表
		List<String> errList = new ArrayList<String>();//异常列表
		User user = null;
		try{
			//1.读xml
			Document doc = JDOMParserUtil.xmlParse(userInfos);
	        List<Element> accounts =doc.getRootElement().getChildren();//获得所有子要素集合
	        for(Element account : accounts){
	        	try{
		        	user = new User();
		        	user.setUsername(account.getChildTextTrim("accId"));//账号ID（必填）
//		        	由于IAM无法同步岗位和组织机构数据，所以同步用户时默认为：岗位：应用运维普通用户107 组织结构：总行1000
//		        	if(null != account.getChildText("position") && !"".equals(account.getChildText("position"))) user.setPosition((Position) positionService.get(Long.parseLong(account.getChildText("position"))));//职务（必填）
//		        	if(null != account.getChildText("workOrg") && !"".equals(account.getChildText("workOrg"))) user.setOrg((Org) orgService.get(account.getChildText("workOrg")));//所属组织结构（必填）
		        	user.setPosition((Position) positionService.get(Long.parseLong("113")));//职务
		        	user.setOrg((Org) orgService.get("1000"));//所属组织结构
		        	if(null != account.getChildText("name")) user.setName(account.getChildText("name"));//姓名
//		        	if(null != account.getChildTextTrim("userPassword")) user.setPassword(passwordEncoder.encodePassword(account.getChildTextTrim("userPassword"), ""));//密码
		        	user.setPassword(passwordEncoder.encodePassword(Constants.DEFAULT_PASSWORD, ""));
		        	if(null != account.getChildText("idCardNumber")) user.setIdentity(account.getChildText("idCardNumber"));//身份证号码
		        	if(null != account.getChildText("postOfficeBox")) user.setEmail(account.getChildText("postOfficeBox"));//邮箱
		        	if(null != account.getChildText("telephoneNumber")) user.setTel(account.getChildText("telephoneNumber"));//电话号码
		        	if(null != account.getChildText("mobile")) user.setMobile(account.getChildText("mobile"));//用户移动电话
		        	if(null != account.getChildText("address")) user.setAddress(account.getChildText("address"));//地址
		        	if(null != account.getChildText("gender") && !"".equals(account.getChildText("gender"))){
		        		switch(ComUtil.changeToChar(account.getChildTextTrim("gender"))){
		        		case '1' :
		        			user.setGender("M");//性别男
		        			break;
		        		case '2':
		        			user.setGender("F");//性别女
		        			break;
		        		case '3':
		        			user.setGender("");//未知
		        			break;
		        		}
		        	}
		        	if(null != account.getChildText("birthday") && !"".equals(account.getChildText("birthday"))) user.setBirthday(DateFunction.convertStrToDate(account.getChildText("birthday"), 6));
		        	user.setEnabled(true);//用户启用
		        	user.setCreator((User) userService.get("admin"));//设置默认超级管理员用户、固定值
		        	user.setCreated(DateFunction.convertStrToDate(DateFunction.getSystemTimeByFormat(1), 1));//创建时间
		        	user.setModifier((User) userService.get("admin"));//设置默认超级管理员用户、固定值
		        	user.setModified(DateFunction.convertStrToDate(DateFunction.getSystemTimeByFormat(1), 1));//修改时间

	        		userService.save(user);
	        		okList.add(account.getChildTextTrim("accId"));
	        	}catch(Exception e){
	        		System.out.println(e.getMessage());
	        		e.printStackTrace();
	        		errList.add(account.getChildTextTrim("accId"));
	        	}
	        }
			//2.编辑XML并输出
			rootElement = new Element("results");//根要素
			resultDocument = new Document(rootElement);//文档对象
			
			okElement = new Element("result").setAttribute("returncode", "1300");//成功要素
			rootElement.addContent(okElement);//添加成功要素
			
			errElement  = new Element("result").setAttribute("returncode", "1301");//失败要素
			rootElement.addContent(errElement);//添加失败要素
			if(okList.size() ==0){
				okElement.addContent("");
			}else{
				for (String okId : okList) {//OK列表
					okElement.addContent(new Element("accId").addContent(okId));
				}
			}
			
			if(errList.size() ==0){
				errElement.addContent("");
			}else{
				for (String errId : errList) {//ERR列表
					errElement.addContent(new Element("accId").addContent(errId));
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}
	
	/**
	 * 6.2.1.1.3.2.1	从帐号修改接口
	 * 修改应用系统中的帐号信息
	 * @param  userInfos从帐号信息列表
	 * @return 操作结果信息
	 */
	public String modifyUserInfo(String userInfos){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element okElement = null;//成功要素
		Element errElement = null;//失败要素
		List<String> okList = new ArrayList<String>();//正常列表
		List<String> errList = new ArrayList<String>();//异常列表
		XMLOutputter outputter = null;
		User user = null;
		try{
			//1.读xml
			Document doc = JDOMParserUtil.xmlParse(userInfos);
	        List<Element> accounts =doc.getRootElement().getChildren();//获得所有子要素集合
	        for(Element account : accounts){
	        	try{
	        		//查询用户数据转换成vo
		        	user = new User();
		        	user = (User) userService.get(account.getChildTextTrim("accId"));//账号ID（必填）
		        	
//		        	if(null != account.getChildText("position") && !"".equals(account.getChildText("position"))) user.setPosition((Position) positionService.get(Long.parseLong(account.getChildText("position"))));//职务
//		        	if(null != account.getChildText("workOrg") && !"".equals(account.getChildText("workOrg"))) user.setOrg((Org) orgService.get(account.getChildText("workOrg")));//所属组织结构
		        	if(null != account.getChildText("name")) user.setName(account.getChildText("name"));//姓名
//		        	if(null != account.getChildTextTrim("userPassword") && !"".equals(account.getChildTextTrim("userPassword"))) user.setPassword(passwordEncoder.encodePassword(account.getChildTextTrim("userPassword"), ""));//密码
		        	if(null != account.getChildText("idCardNumber")) user.setIdentity(account.getChildText("idCardNumber"));//身份证号码
		        	if(null != account.getChildText("postOfficeBox")) user.setEmail(account.getChildText("postOfficeBox"));//邮箱
		        	if(null != account.getChildText("telephoneNumber")) user.setTel(account.getChildText("telephoneNumber"));//电话号码
		        	if(null != account.getChildText("mobile")) user.setMobile(account.getChildText("mobile"));//用户移动电话
		        	if(null != account.getChildText("address")) user.setAddress(account.getChildText("address"));//地址
		        	if(null != account.getChildText("gender") && !"".equals(account.getChildText("gender"))){
		        		switch(ComUtil.changeToChar(account.getChildTextTrim("gender"))){
		        		case '1' :
		        			user.setGender("M");//性别男
		        			break;
		        		case '2':
		        			user.setGender("F");//性别女
		        			break;
		        		case '3':
		        			user.setGender("");//未知
		        			break;
		        		}
		        	}
		        	if(null != account.getChildText("birthday") && !"".equals(account.getChildText("birthday"))) user.setBirthday(DateFunction.convertStrToDate(account.getChildText("birthday"), 6));//生日
		        	user.setModified(DateFunction.convertStrToDate(DateFunction.getSystemTimeByFormat(1), 1));//修改时间
		        	user.setEnabled(true);
		        	
	        		userService.update(user);
	        		okList.add(account.getChildTextTrim("accId"));
	        	}catch(Exception e){
	        		System.out.println(e.getMessage());
	        		e.printStackTrace();
	        		errList.add(account.getChildTextTrim("accId"));
	        	}
	        }
			//2.编辑XML并输出
			rootElement = new Element("results");//根要素
			resultDocument = new Document(rootElement);//文档对象
			
			okElement = new Element("result").setAttribute("returncode", "1302");//成功要素
			rootElement.addContent(okElement);//添加成功要素
			
			errElement  = new Element("result").setAttribute("returncode", "1303");//失败要素
			rootElement.addContent(errElement);//添加失败要素
			
			if(okList.size() == 0){
				okElement.addContent("");
			}else{
				for (String okId : okList) {//OK列表
					okElement.addContent(new Element("accId").addContent(okId));
				}
			}
			
			if(errList.size() == 0){
				errElement.addContent("");
			}else{
				for (String errId : errList) {//ERR列表
					errElement.addContent(new Element("accId").addContent(errId));
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}
	
	/**
	 * 6.2.1.1.4.2.1	从帐号删除接口
	 * 在应用系统中添加帐号
	 * @param 删除应用系统中的从帐号
	 * @return 操作结果信息
	 */
	public String delUser(String userIDs){
		String xml = null;//返回值
		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素
		Element okElement = null;//成功要素
		Element errElement = null;//失败要素
		List<String> okList = new ArrayList<String>();//正常列表
		List<String> errList = new ArrayList<String>();//异常列表
		XMLOutputter outputter = null;
		User user = null;
//		JedaUserSystemVo userSystem = null;
		try{
			//1.读xml
			Document doc = JDOMParserUtil.xmlParse(userIDs);
	        List<Element> accounts =doc.getRootElement().getChildren();//获得所有子要素集合
	        for(Element account : accounts){
	        	try{
	        		//查询用户数据转换成vo
		        	user = new User();
		        	user = (User) userService.get(account.getTextTrim());
		        	
		        	//逻辑删除用户（禁用）
		        	user.setEnabled(false);
		        	userService.update(user);
		        	
//		        	//物理删除用户
//	        		userService.delete(user);
	        		//物理删除用户关联系统数据
//	        		userSystem = new JedaUserSystemVo();
//	        		userSystem = (JedaUserSystemVo) userSystemService.get(account.getTextTrim());
//	        		if(null != userSystem){
//	        			userSystemService.delete(userSystem);
//	        		}
		        	
	        		okList.add(account.getTextTrim());
	        	}catch(Exception e){
	        		System.out.println(e.getMessage());
	        		e.printStackTrace();
	        		errList.add(account.getTextTrim());
	        	}
	        }
			
			//2.编辑XML并输出
			rootElement = new Element("delresults");//根要素
			resultDocument = new Document(rootElement);//文档对象
			
			okElement = new Element("result").setAttribute("returncode", "1304");//成功要素
			rootElement.addContent(okElement);//添加成功要素
			
			errElement  = new Element("result").setAttribute("returncode", "1305");//失败要素
			rootElement.addContent(errElement);//添加失败要素
			
			if(okList.size() == 0){
				okElement.addContent("");
			}else{
				for (String okId : okList) {//OK列表
					okElement.addContent(new Element("accId").addContent(okId));
				}
			}
			
			if(errList.size() == 0){
				errElement.addContent("");
			}else{
				for (String errId : errList) {//ERR列表
					errElement.addContent(new Element("accId").addContent(errId));
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}
	
	/**
	 * 应急切换状态查询.
	 * @return 正常状态返回字符串0 ，应急状态返回字符串1
	 */
	public String stateQuery(){
		String state = "";
		try {
			state = iamStatusService.queryState().toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return state;
	}

	/**
	 * 应急切换.
	 * @param 值为1 切换到应急状态，值为 0切换到正常状态
	 * @return 返回应用切换后的状态，正常状态返回字符串 0 ，应急状态返回 字符串1
	 */
	public String setState(String emergencyValue){
		try {
			iamStatusService.updateStatus(Integer.valueOf(emergencyValue));
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
		return emergencyValue;
	}

}///:~

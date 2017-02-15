package com.nantian.common.system.vo;

import java.io.Serializable;

public class MemberVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**用户ID*/
	private String userId;
	/**用户名*/
	private String userName;
	/**性别*/
	private String sex;
	/**手机*/
	private String mobile;
	/**座机*/
	private String phone;
	/**其他联系方式*/
	private String otherContact;
	/**电子邮件*/
	private String email;
	/**员工编号*/
	private String serilNo;
	/**团队组别*/
	private String groupName;
	/**所属团队*/
	private String teamName;
	/**外包标识*/
	private String outSourcingFlag;

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getOtherContact() {
		return otherContact;
	}

	public void setOtherContact(String otherContact) {
		this.otherContact = otherContact;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getSerilNo() {
		return serilNo;
	}

	public void setSerilNo(String serilNo) {
		this.serilNo = serilNo;
	}

	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public String getTeamName() {
		return teamName;
	}

	public void setTeamName(String teamName) {
		this.teamName = teamName;
	}

	public String getOutSourcingFlag() {
		return outSourcingFlag;
	}

	public void setOutSourcingFlag(String outSourcingFlag) {
		this.outSourcingFlag = outSourcingFlag;
	}
}

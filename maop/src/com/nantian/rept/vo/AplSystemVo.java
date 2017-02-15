package com.nantian.rept.vo;

import java.io.Serializable;

public class AplSystemVo implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String aplCode;
	
	private String aplName;
	
	private String aplAllName;
	
	private String aplBusiness;
	
	private String userId;
	
	private String mailSendToList;
	
	private String mailSendCCList;
	
	private String mailSendFlag;
	
	private String mailSendTime;

	public String getAplCode() {
		return aplCode;
	}

	public void setAplCode(String aplCode) {
		this.aplCode = aplCode;
	}

	public String getAplName() {
		return aplName;
	}

	public void setAplName(String aplName) {
		this.aplName = aplName;
	}

	public String getAplAllName() {
		return aplAllName;
	}

	public void setAplAllName(String aplAllName) {
		this.aplAllName = aplAllName;
	}

	public String getAplBusiness() {
		return aplBusiness;
	}

	public void setAplBusiness(String aplBusiness) {
		this.aplBusiness = aplBusiness;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getMailSendToList() {
		return mailSendToList;
	}

	public void setMailSendToList(String mailSendToList) {
		this.mailSendToList = mailSendToList;
	}

	public String getMailSendCCList() {
		return mailSendCCList;
	}

	public void setMailSendCCList(String mailSendCCList) {
		this.mailSendCCList = mailSendCCList;
	}

	public String getMailSendFlag() {
		return mailSendFlag;
	}

	public void setMailSendFlag(String mailSendFlag) {
		this.mailSendFlag = mailSendFlag;
	}

	public String getMailSendTime() {
		return mailSendTime;
	}

	public void setMailSendTime(String mailSendTime) {
		this.mailSendTime = mailSendTime;
	}
	
}

package com.nantian.rept.vo;

import java.io.Serializable;

public class AplAnalyzeVo implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String aplCode;
	
	private String transDate;
	
	private String transTime;
	
	private String anaItem;
	
	private String exeAnaDesc;
	
	private String status;
	
	private String anaUser;
	
	private String revUser;
	
	private String endDate;
	
	private String filePath;
	
	private String handleState;

	
	public String getHandleState() {
		return handleState;
	}

	public void setHandleState(String handleState) {
		this.handleState = handleState;
	}

	public String getAplCode() {
		return aplCode;
	}

	public void setAplCode(String aplCode) {
		this.aplCode = aplCode;
	}

	public String getTransDate() {
		return transDate;
	}

	public void setTransDate(String transDate) {
		this.transDate = transDate;
	}

	public String getAnaItem() {
		return anaItem;
	}

	public void setAnaItem(String anaItem) {
		this.anaItem = anaItem;
	}

	public String getExeAnaDesc() {
		return exeAnaDesc;
	}

	public void setExeAnaDesc(String exeAnaDesc) {
		this.exeAnaDesc = exeAnaDesc;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getAnaUser() {
		return anaUser;
	}

	public void setAnaUser(String anaUser) {
		this.anaUser = anaUser;
	}

	public String getRevUser() {
		return revUser;
	}

	public void setRevUser(String revUser) {
		this.revUser = revUser;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}
	
	public String getTransTime() {
		return transTime;
	}

	public void setTransTime(String transTime) {
		this.transTime = transTime;
	}

}

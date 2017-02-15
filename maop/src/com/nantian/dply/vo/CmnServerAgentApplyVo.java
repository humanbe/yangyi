package com.nantian.dply.vo;

import java.io.Serializable;

public class CmnServerAgentApplyVo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String recordId;
	private String appsysCode;
	private String serverIp;
	private String Value;
	private String descValue;
	public String getRecordId() {
		return recordId;
	}
	public void setRecordId(String recordId) {
		this.recordId = recordId;
	}
	public String getAppsysCode() {
		return appsysCode;
	}
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}
	public String getServerIp() {
		return serverIp;
	}
	public void setServerIp(String serverIp) {
		this.serverIp = serverIp;
	}
	public String getValue() {
		return Value;
	}
	public void setValue(String value) {
		Value = value;
	}
	public String getDescValue() {
		return descValue;
	}
	public void setDescValue(String descValue) {
		this.descValue = descValue;
	}

}

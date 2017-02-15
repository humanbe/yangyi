package com.nantian.dply.vo;

import java.io.Serializable;

public class DplyParamInfoVo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String appsysCode;
	private String instanceValue;
	private String dplyParamCode;
	private String importanceLevel;
	public String getDplyParamCode() {
		return dplyParamCode;
	}
	public void setDplyParamCode(String dplyParamCode) {
		this.dplyParamCode = dplyParamCode;
	}
	public String getImportanceLevel() {
		return importanceLevel;
	}
	public void setImportanceLevel(String importanceLevel) {
		this.importanceLevel = importanceLevel;
	}
	public String getAppsysCode() {
		return appsysCode;
	}
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}
	public String getInstanceValue() {
		return instanceValue;
	}
	public void setInstanceValue(String instanceValue) {
		this.instanceValue = instanceValue;
	}
	
}

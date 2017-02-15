package com.nantian.dply.vo;

import java.io.Serializable;

public class DplyJobScriptInfoVo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String appsysCode;
	private String scriptBlpackageName;
	private String jobParentGroup;
	private String scriptName;
	private String paramName;
	private String scriptBlpackagePath;
	private String scriptPath;
	private Integer paramType;
	private String paramValue;
	public String getAppsysCode() {
		return appsysCode;
	}
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}
	public String getScriptBlpackageName() {
		return scriptBlpackageName;
	}
	public void setScriptBlpackageName(String scriptBlpackageName) {
		this.scriptBlpackageName = scriptBlpackageName;
	}
	public String getJobParentGroup() {
		return jobParentGroup;
	}
	public void setJobParentGroup(String jobParentGroup) {
		this.jobParentGroup = jobParentGroup;
	}
	public String getScriptName() {
		return scriptName;
	}
	public void setScriptName(String scriptName) {
		this.scriptName = scriptName;
	}
	public String getParamName() {
		return paramName;
	}
	public void setParamName(String paramName) {
		this.paramName = paramName;
	}
	public String getScriptBlpackagePath() {
		return scriptBlpackagePath;
	}
	public void setScriptBlpackagePath(String scriptBlpackagePath) {
		this.scriptBlpackagePath = scriptBlpackagePath;
	}
	public String getScriptPath() {
		return scriptPath;
	}
	public void setScriptPath(String scriptPath) {
		this.scriptPath = scriptPath;
	}
	public Integer getParamType() {
		return paramType;
	}
	public void setParamType(Integer paramType) {
		this.paramType = paramType;
	}
	public String getParamValue() {
		return paramValue;
	}
	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	
}

package com.nantian.dply.vo;

import java.io.Serializable;

public class DplyJobInfoVo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String appsysCode;
	private String jobName;
	private Integer jobType;
	private String jobParentGroup;
	private String scriptBlpackageName;
	private String jobPath;
	private String jobCreator;
	private java.sql.Timestamp jobCreated;
	private String jobModifier;
	private java.sql.Timestamp jobModified;
	private String nshValue;
	private String paramValue;
	private String typeValue;
	private String pathValue;
	private String environmentCode;
	public String getAppsysCode() {
		return appsysCode;
	}
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}
	public String getJobName() {
		return jobName;
	}
	public void setJobName(String jobName) {
		this.jobName = jobName;
	}
	public Integer getJobType() {
		return jobType;
	}
	public void setJobType(Integer jobType) {
		this.jobType = jobType;
	}
	public String getJobParentGroup() {
		return jobParentGroup;
	}
	public void setJobParentGroup(String jobParentGroup) {
		this.jobParentGroup = jobParentGroup;
	}
	public String getScriptBlpackageName() {
		return scriptBlpackageName;
	}
	public void setScriptBlpackageName(String scriptBlpackageName) {
		this.scriptBlpackageName = scriptBlpackageName;
	}
	public String getJobPath() {
		return jobPath;
	}
	public void setJobPath(String jobPath) {
		this.jobPath = jobPath;
	}
	public String getJobCreator() {
		return jobCreator;
	}
	public void setJobCreator(String jobCreator) {
		this.jobCreator = jobCreator;
	}
	public java.sql.Timestamp getJobCreated() {
		return jobCreated;
	}
	public void setJobCreated(java.sql.Timestamp jobCreated) {
		this.jobCreated = jobCreated;
	}
	public String getJobModifier() {
		return jobModifier;
	}
	public void setJobModifier(String jobModifier) {
		this.jobModifier = jobModifier;
	}
	public java.sql.Timestamp getJobModified() {
		return jobModified;
	}
	public void setJobModified(java.sql.Timestamp jobModified) {
		this.jobModified = jobModified;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public String getNshValue() {
		return nshValue;
	}
	public void setNshValue(String nshValue) {
		this.nshValue = nshValue;
	}
	public String getParamValue() {
		return paramValue;
	}
	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}
	public String getTypeValue() {
		return typeValue;
	}
	public void setTypeValue(String typeValue) {
		this.typeValue = typeValue;
	}
	public String getPathValue() {
		return pathValue;
	}
	public void setPathValue(String pathValue) {
		this.pathValue = pathValue;
	}
	public String getEnvironmentCode() {
		return environmentCode;
	}
	public void setEnvironmentCode(String environmentCode) {
		this.environmentCode = environmentCode;
	}
	
	
}

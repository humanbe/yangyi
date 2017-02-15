package com.nantian.common.system.vo;

import java.io.Serializable;

public class SystemInfoVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**系统编号*/
	private String sysId;
	/**系统名称*/
	private String sysName;
	/**运维经理*/
	private String operationsManager;
	/**系统管理员A*/
	private String sysA;
	/**系统管理员B*/
	private String sysB;
	/**应用管理员A*/
	private String appA;
	/**应用管理员B*/
	private String appB;
	/**项目组负责人*/
	private String projectLeader;
	/**系统状态*/
	private String sysStatus;
	/**业务主管部门*/
	private String department;
	/**服务时间的级别*/
	private String serviceTime;
	/**灾备优先级*/
	private String disasterRecoverPriority;
	/**安全定级*/
	private String securityRank;

	public String getSysId() {
		return sysId;
	}

	public void setSysId(String sysId) {
		this.sysId = sysId;
	}

	public String getSysName() {
		return sysName;
	}

	public void setSysName(String sysName) {
		this.sysName = sysName;
	}

	public String getOperationsManager() {
		return operationsManager;
	}

	public void setOperationsManager(String operationsManager) {
		this.operationsManager = operationsManager;
	}

	public String getSysA() {
		return sysA;
	}

	public void setSysA(String sysA) {
		this.sysA = sysA;
	}

	public String getSysB() {
		return sysB;
	}

	public void setSysB(String sysB) {
		this.sysB = sysB;
	}

	public String getAppA() {
		return appA;
	}

	public void setAppA(String appA) {
		this.appA = appA;
	}

	public String getAppB() {
		return appB;
	}

	public void setAppB(String appB) {
		this.appB = appB;
	}

	public String getProjectLeader() {
		return projectLeader;
	}

	public void setProjectLeader(String projectLeader) {
		this.projectLeader = projectLeader;
	}

	public String getSysStatus() {
		return sysStatus;
	}

	public void setSysStatus(String sysStatus) {
		this.sysStatus = sysStatus;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getServiceTime() {
		return serviceTime;
	}

	public void setServiceTime(String serviceTime) {
		this.serviceTime = serviceTime;
	}

	public String getDisasterRecoverPriority() {
		return disasterRecoverPriority;
	}

	public void setDisasterRecoverPriority(String disasterRecoverPriority) {
		this.disasterRecoverPriority = disasterRecoverPriority;
	}

	public String getSecurityRank() {
		return securityRank;
	}

	public void setSecurityRank(String securityRank) {
		this.securityRank = securityRank;
	}
}

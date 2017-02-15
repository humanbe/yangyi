package com.nantian.common.system.vo;

import java.io.Serializable;
import java.sql.Timestamp;

public class AppInfoVo implements Serializable {

	/**
	 * 系统代码信息
	 */
	private static final long serialVersionUID = 1L;
	/**系统编号*/
	private String appsysCode;
	/**系统名称*/
	private String appsysName;
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
	/**运维经理*/
	private String operationsManager;
	/**系统概要*/
	private String appOutline;
	/**系统类型*/
	private String appType;
	/**核心级别*/
	private String hexinJibie;
	/**重要级别*/
	private String zhongyaoJibie;
	/**关键级别*/
	private String guanjianJibie;
	/**团队组别*/
	private String groupName;
	/**运维自动化平台上线标示*/
	private String aopFlag;
	/**上次扫描时间*/
	private Timestamp  lastScanTime;
	/**删除标示*/
	private String  deleteFlag;
	/**更新时间*/
	private Timestamp  updateTime;
	/**更新前纪录*/
	private String  updateBeforeRecord;
	
	
	
	
	

	public Timestamp getUpdateTime() {
		return updateTime;
	}
	public void setUpdateTime(Timestamp updateTime) {
		this.updateTime = updateTime;
	}
	public Timestamp getLastScanTime() {
		return lastScanTime;
	}
	public void setLastScanTime(Timestamp lastScanTime) {
		this.lastScanTime = lastScanTime;
	}
	public String getDeleteFlag() {
		return deleteFlag;
	}
	public void setDeleteFlag(String deleteFlag) {
		this.deleteFlag = deleteFlag;
	}
	
	public String getHexinJibie() {
		return hexinJibie;
	}
	public void setHexinJibie(String hexinJibie) {
		this.hexinJibie = hexinJibie;
	}
	public String getZhongyaoJibie() {
		return zhongyaoJibie;
	}
	public void setZhongyaoJibie(String zhongyaoJibie) {
		this.zhongyaoJibie = zhongyaoJibie;
	}
	public String getGuanjianJibie() {
		return guanjianJibie;
	}
	public void setGuanjianJibie(String guanjianJibie) {
		this.guanjianJibie = guanjianJibie;
	}
	public String getGroupName() {
		return groupName;
	}
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}
	
	
	

	public String getUpdateBeforeRecord() {
		return updateBeforeRecord;
	}
	public void setUpdateBeforeRecord(String updateBeforeRecord) {
		this.updateBeforeRecord = updateBeforeRecord;
	}
	public String getAppsysCode() {
		return appsysCode;
	}
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}
	
	public String getAppsysName() {
		return appsysName;
	}
	public void setAppsysName(String appsysName) {
		this.appsysName = appsysName;
	}
	public String getAopFlag() {
		return aopFlag;
	}
	public void setAopFlag(String aopFlag) {
		this.aopFlag = aopFlag;
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
	public String getOperationsManager() {
		return operationsManager;
	}
	public void setOperationsManager(String operationsManager) {
		this.operationsManager = operationsManager;
	}
	public String getAppOutline() {
		return appOutline;
	}
	public void setAppOutline(String appOutline) {
		this.appOutline = appOutline;
	}
	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
	}
	
}

package com.nantian.dply.vo;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * @author <a href="mailto:liruihao@nantian.com.cn">liruihao</a>
 * 
 */
public class StepsVo implements Serializable{
	private static final long serialVersionUID = 1L;
	private java.lang.Long id;
	private java.lang.Long position;
	private java.lang.Long requestId;
	private java.lang.String name;
	private java.lang.Long differentLevelFromPrevious;
	private java.lang.String serviceCode;
	private java.lang.String servers;
	private java.lang.String component;
	private java.lang.Long manual;
	private java.lang.String owner;
	private java.lang.String autoJobName;
	private java.lang.String createStatus;
	private java.lang.String operateLog;
	private Timestamp createdAt;
	private Timestamp updatedAt;
	public java.lang.Long getId() {
		return id;
	}
	public void setId(java.lang.Long id) {
		this.id = id;
	}
	public java.lang.Long getPosition() {
		return position;
	}
	public void setPosition(java.lang.Long position) {
		this.position = position;
	}
	public java.lang.Long getRequestId() {
		return requestId;
	}
	public void setRequestId(java.lang.Long requestId) {
		this.requestId = requestId;
	}
	public java.lang.String getName() {
		return name;
	}
	public void setName(java.lang.String name) {
		this.name = name;
	}
	public java.lang.Long getDifferentLevelFromPrevious() {
		return differentLevelFromPrevious;
	}
	public void setDifferentLevelFromPrevious(
			java.lang.Long differentLevelFromPrevious) {
		this.differentLevelFromPrevious = differentLevelFromPrevious;
	}
	public java.lang.String getServiceCode() {
		return serviceCode;
	}
	public void setServiceCode(java.lang.String serviceCode) {
		this.serviceCode = serviceCode;
	}
	public java.lang.String getServers() {
		return servers;
	}
	public void setServers(java.lang.String servers) {
		this.servers = servers;
	}
	public java.lang.String getComponent() {
		return component;
	}
	public void setComponent(java.lang.String component) {
		this.component = component;
	}
	public java.lang.Long getManual() {
		return manual;
	}
	public void setManual(java.lang.Long manual) {
		this.manual = manual;
	}
	public java.lang.String getOwner() {
		return owner;
	}
	public void setOwner(java.lang.String owner) {
		this.owner = owner;
	}
	public java.lang.String getAutoJobName() {
		return autoJobName;
	}
	public void setAutoJobName(java.lang.String autoJobName) {
		this.autoJobName = autoJobName;
	}
	public java.lang.String getCreateStatus() {
		return createStatus;
	}
	public void setCreateStatus(java.lang.String createStatus) {
		this.createStatus = createStatus;
	}
	public java.lang.String getOperateLog() {
		return operateLog;
	}
	public void setOperateLog(java.lang.String operateLog) {
		this.operateLog = operateLog;
	}
	public Timestamp getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}
	public Timestamp getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}
}

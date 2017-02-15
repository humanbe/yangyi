package com.nantian.common.system.vo;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * ITSM同步应用系统附加配置表
 * @author linaWang
 *
 */
public class AppConfVo implements Serializable {

	private static final long serialVersionUID = 1L;
	/**ITMS平台应用系统编号*/
	private String itsmAppsysCode;
	/**MAOP平台应用系统编号*/
	private String maopAppsysCode;
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
	/**系统上线环境*/
	private String  onlineEnv;
	/**同步类型*/
	private String  syncType;
	
	public String getItsmAppsysCode() {
		return itsmAppsysCode;
	}
	public void setItsmAppsysCode(String itsmAppsysCode) {
		this.itsmAppsysCode = itsmAppsysCode;
	}
	public String getMaopAppsysCode() {
		return maopAppsysCode;
	}
	public void setMaopAppsysCode(String maopAppsysCode) {
		this.maopAppsysCode = maopAppsysCode;
	}
	public String getAopFlag() {
		return aopFlag;
	}
	public void setAopFlag(String aopFlag) {
		this.aopFlag = aopFlag;
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
	public Timestamp getUpdateTime() {
		return updateTime;
	}
	public void setUpdateTime(Timestamp updateTime) {
		this.updateTime = updateTime;
	}
	public String getUpdateBeforeRecord() {
		return updateBeforeRecord;
	}
	public void setUpdateBeforeRecord(String updateBeforeRecord) {
		this.updateBeforeRecord = updateBeforeRecord;
	}
	public String getOnlineEnv() {
		return onlineEnv;
	}
	public void setOnlineEnv(String onlineEnv) {
		this.onlineEnv = onlineEnv;
	}
	public String getSyncType() {
		return syncType;
	}
	public void setSyncType(String syncType) {
		this.syncType = syncType;
	}
}

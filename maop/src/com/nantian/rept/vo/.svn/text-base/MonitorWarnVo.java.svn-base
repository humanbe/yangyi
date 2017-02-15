package com.nantian.rept.vo;

import java.io.Serializable;

public class MonitorWarnVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**序列号*/
	private Long appChangeId;
	/**系统编号*/
	private String aplCode;
	/**变更日期*/
	private String changeDate;
	/**监控影响事由*/
	private String monitorEffectContent;
	/**设备名称*/
	private String deviceName;
	/**IP地址*/
	private String ipAddress;
	/**网络设备、线路影响说明*/
	private String explainDevice;
	/**统一监控平台影响说明*/
	private String explainMonitorPlatform;
	/**专用监控工具影响说明.1:忽略告警,0:不忽略告警*/
	private String explainMonitorTool;
	/**监控大屏影响说明.1:忽略告警,0:不忽略告警*/
	private String explainMonitorScreen;
	/**影响开始时间*/
	private String effectStartTime;
	/**影响结束时间*/
	private String effectEndTime;
	
	private AppChangeVo appChange;

	public Long getAppChangeId() {
		return appChangeId;
	}

	public void setAppChangeId(Long appChangeId) {
		this.appChangeId = appChangeId;
	}

	public String getAplCode() {
		return aplCode;
	}

	public void setAplCode(String aplCode) {
		this.aplCode = aplCode;
	}

	public String getChangeDate() {
		return changeDate;
	}

	public void setChangeDate(String changeDate) {
		this.changeDate = changeDate;
	}

	public String getMonitorEffectContent() {
		return monitorEffectContent;
	}

	public void setMonitorEffectContent(String monitorEffectContent) {
		this.monitorEffectContent = monitorEffectContent;
	}

	public String getDeviceName() {
		return deviceName;
	}

	public void setDeviceName(String deviceName) {
		this.deviceName = deviceName;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public String getExplainDevice() {
		return explainDevice;
	}

	public void setExplainDevice(String explainDevice) {
		this.explainDevice = explainDevice;
	}

	public String getExplainMonitorPlatform() {
		return explainMonitorPlatform;
	}

	public void setExplainMonitorPlatform(String explainMonitorPlatform) {
		this.explainMonitorPlatform = explainMonitorPlatform;
	}

	public String getExplainMonitorTool() {
		return explainMonitorTool;
	}

	public void setExplainMonitorTool(String explainMonitorTool) {
		this.explainMonitorTool = explainMonitorTool;
	}

	public String getExplainMonitorScreen() {
		return explainMonitorScreen;
	}

	public void setExplainMonitorScreen(String explainMonitorScreen) {
		this.explainMonitorScreen = explainMonitorScreen;
	}

	public String getEffectStartTime() {
		return effectStartTime;
	}

	public void setEffectStartTime(String effectStartTime) {
		this.effectStartTime = effectStartTime;
	}

	public String getEffectEndTime() {
		return effectEndTime;
	}

	public void setEffectEndTime(String effectEndTime) {
		this.effectEndTime = effectEndTime;
	}
	
	public AppChangeVo getAppChange() {
		return appChange;
	}

	public void setAppChange(AppChangeVo appChange) {
		this.appChange = appChange;
	}

	public boolean isValid(MonitorWarnVo vo){
		if ((vo.getMonitorEffectContent() == null || "".equals(vo.getMonitorEffectContent()))
				&& (vo.getDeviceName() == null || "".equals(vo.getDeviceName()))
				&& (vo.getIpAddress() == null || "".equals(vo.getIpAddress()))
				&& (vo.getExplainDevice() == null || "".equals(vo.getExplainDevice()))
				&& (vo.getExplainMonitorPlatform() == null || "".equals(vo.getExplainMonitorPlatform()))
				&& (vo.getExplainMonitorTool() == null || "".equals(vo.getExplainMonitorTool()))
				&& (vo.getExplainMonitorScreen() == null || "".equals(vo.getExplainMonitorScreen()))
				&& (vo.getEffectStartTime() == null || "".equals(vo.getEffectStartTime()))
				&& (vo.getEffectEndTime() == null || "".equals(vo.getEffectEndTime()))) {
			return false;
		}
		return true;
	}
}

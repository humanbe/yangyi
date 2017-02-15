package com.nantian.dply.vo;

import java.io.Serializable;

public class AppChangeVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**序列号*/
	private Long appChangeId;
	/**系统编号*/
	private String aplCode;
	/**变更月份*/
	private String changeMonth;
	/**变更日期*/
	private String changeDate;
	/**EAPS编号*/
	private String eapsCode;
	/**变更名称*/
	private String changeName;
	/**变更牌号*/
	private String changeGrantNo;
	/**投产地点*/
	private String dplyLocation;
	/**投产计划开始日期*/
	private String planStartDate;
	/**计划投产开始时间*/
	private String planStartTime;
	/**实际投产开始时间*/
	private String actualStartTime;
	/**计划完成日期*/
	private String planEndDate;
	/**计划完成时间*/
	private String planEndTime;
	/**实际完成日期*/
	private String actualEndDate;
	/**实际投产完成时间*/
	private String actualEndTime;
	/**是否完成投产.0:否;1:是*/
	private String endFlag;
	/**项目组变更负责人*/
	private String develop;
	/**变更类型.1:常规投产,2:临时投产,3:临时操作,4:紧急修复*/
	private String changeType;
	/**变更表格.0:否;1:是;2:已归档*/
	private String changeTable;
	/**上次重启日期*/
	private String lastRebootDate;
	/**本次重启时间安排*/
	private String nowRebootTime;
	/**重启执行情况*/
	private String rebootExecInfo;
	/**验证结果*/
	private String verifyInfo;
	/**计划实施人工号*/
	private String operationId;
	/**计划实施人*/
	private String operation;
	/**计划实施人联系方式*/
	private String operationTel;
	/**次日维护人员*/
	private String maintainTomo;
	/**计划复核人工号*/
	private String reviewerId;
	/**计划复核人*/
	private String reviewer;
	/**计划复核人联系方式*/
	private String reviewerTel;

	private AppChangeRiskEvalVo riskEval;
	
	private AppChangeSummaryVo summary;
	
	private MonitorWarnVo monitorWarn;
	
	/**请求排期数据*/
	private String Requests_create;
	
	

	public String getRequests_create() {
		return Requests_create;
	}

	public void setRequests_create(String requests_create) {
		Requests_create = requests_create;
	}

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

	public String getChangeMonth() {
		return changeMonth;
	}

	public void setChangeMonth(String changeMonth) {
		this.changeMonth = changeMonth;
	}

	public String getChangeDate() {
		return changeDate;
	}

	public void setChangeDate(String changeDate) {
		this.changeDate = changeDate;
	}

	public String getEapsCode() {
		return eapsCode;
	}

	public void setEapsCode(String eapsCode) {
		this.eapsCode = eapsCode;
	}

	public String getChangeName() {
		return changeName;
	}

	public void setChangeName(String changeName) {
		this.changeName = changeName;
	}

	public String getChangeGrantNo() {
		return changeGrantNo;
	}

	public void setChangeGrantNo(String changeGrantNo) {
		this.changeGrantNo = changeGrantNo;
	}

	public String getDplyLocation() {
		return dplyLocation;
	}

	public void setDplyLocation(String dplyLocation) {
		this.dplyLocation = dplyLocation;
	}

	public String getPlanStartDate() {
		return planStartDate;
	}

	public void setPlanStartDate(String planStartDate) {
		this.planStartDate = planStartDate;
	}

	public String getPlanStartTime() {
		return planStartTime;
	}

	public void setPlanStartTime(String planStartTime) {
		this.planStartTime = planStartTime;
	}

	public String getActualStartTime() {
		return actualStartTime;
	}

	public void setActualStartTime(String actualStartTime) {
		this.actualStartTime = actualStartTime;
	}

	public String getPlanEndDate() {
		return planEndDate;
	}

	public void setPlanEndDate(String planEndDate) {
		this.planEndDate = planEndDate;
	}

	public String getPlanEndTime() {
		return planEndTime;
	}

	public void setPlanEndTime(String planEndTime) {
		this.planEndTime = planEndTime;
	}

	public String getActualEndDate() {
		return actualEndDate;
	}

	public void setActualEndDate(String actualEndDate) {
		this.actualEndDate = actualEndDate;
	}

	public String getActualEndTime() {
		return actualEndTime;
	}

	public void setActualEndTime(String actualEndTime) {
		this.actualEndTime = actualEndTime;
	}

	public String getEndFlag() {
		return endFlag;
	}

	public void setEndFlag(String endFlag) {
		this.endFlag = endFlag;
	}

	public String getDevelop() {
		return develop;
	}

	public void setDevelop(String develop) {
		this.develop = develop;
	}

	public String getChangeType() {
		return changeType;
	}

	public void setChangeType(String changeType) {
		this.changeType = changeType;
	}

	public String getChangeTable() {
		return changeTable;
	}

	public void setChangeTable(String changeTable) {
		this.changeTable = changeTable;
	}

	public String getLastRebootDate() {
		return lastRebootDate;
	}

	public void setLastRebootDate(String lastRebootDate) {
		this.lastRebootDate = lastRebootDate;
	}

	public String getNowRebootTime() {
		return nowRebootTime;
	}

	public void setNowRebootTime(String nowRebootTime) {
		this.nowRebootTime = nowRebootTime;
	}

	public String getRebootExecInfo() {
		return rebootExecInfo;
	}

	public void setRebootExecInfo(String rebootExecInfo) {
		this.rebootExecInfo = rebootExecInfo;
	}

	public String getVerifyInfo() {
		return verifyInfo;
	}

	public void setVerifyInfo(String verifyInfo) {
		this.verifyInfo = verifyInfo;
	}

	public String getOperation() {
		return operation;
	}

	public void setOperation(String operation) {
		this.operation = operation;
	}

	public String getMaintainTomo() {
		return maintainTomo;
	}

	public void setMaintainTomo(String maintainTomo) {
		this.maintainTomo = maintainTomo;
	}

	public String getReviewer() {
		return reviewer;
	}

	public void setReviewer(String reviewer) {
		this.reviewer = reviewer;
	}

	public AppChangeRiskEvalVo getRiskEval() {
		return riskEval;
	}

	public void setRiskEval(AppChangeRiskEvalVo riskEval) {
		this.riskEval = riskEval;
	}

	public AppChangeSummaryVo getSummary() {
		return summary;
	}

	public void setSummary(AppChangeSummaryVo summary) {
		this.summary = summary;
	}

	public MonitorWarnVo getMonitorWarn() {
		return monitorWarn;
	}

	public void setMonitorWarn(MonitorWarnVo monitorWarn) {
		this.monitorWarn = monitorWarn;
	}

	public String getOperationId() {
		return operationId;
	}

	public void setOperationId(String operationId) {
		this.operationId = operationId;
	}

	public String getOperationTel() {
		return operationTel;
	}

	public void setOperationTel(String operationTel) {
		this.operationTel = operationTel;
	}

	public String getReviewerId() {
		return reviewerId;
	}

	public void setReviewerId(String reviewerId) {
		this.reviewerId = reviewerId;
	}

	public String getReviewerTel() {
		return reviewerTel;
	}

	public void setReviewerTel(String reviewerTel) {
		this.reviewerTel = reviewerTel;
	}

}

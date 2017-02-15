/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.vo;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author ky
 *
 */
public class JobDetailStepsVo implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String jobCode;
	private Integer stepSeq;
	private String stepDecribe;
	private String releaseStep;
	private String backingStep;
	private String errorMessage;
	private String excuteStatus;
	private String startDate;
	private String startTime;
	private String endDate;
	private String endTime;
	private String excute;
	private String verify;
	
	public JobDetailStepsVo(){
		super();
	}

	/**
	 * 任务编号
	 */
	public String getJobCode() {
		return jobCode;
	}

	/**
	 * 任务编号
	 */
	public void setJobCode(String jobCode) {
		this.jobCode = jobCode;
	}

	/**
	 * 工作事项序号
	 */
	public Integer getStepSeq() {
		return stepSeq;
	}

	/**
	 * 工作事项序号
	 */
	public void setStepSeq(Integer stepSeq) {
		this.stepSeq = stepSeq;
	}

	/**
	 * 工作事项描述
	 */
	public String getStepDecribe() {
		return stepDecribe;
	}

	/**
	 * 工作事项描述
	 */
	public void setStepDecribe(String stepDecribe) {
		this.stepDecribe = stepDecribe;
	}

	/**
	 * 详细投产步骤
	 */
	public String getReleaseStep() {
		return releaseStep;
	}

	/**
	 * 详细投产步骤
	 */
	public void setReleaseStep(String releaseStep) {
		this.releaseStep = releaseStep;
	}

	/**
	 * 详细回退步骤
	 */
	public String getBackingStep() {
		return backingStep;
	}

	/**
	 * 详细回退步骤
	 */
	public void setBackingStep(String backingStep) {
		this.backingStep = backingStep;
	}

	/**
	 * 返回执行信息
	 */
	public String getErrorMessage() {
		return errorMessage;
	}

	/**
	 * 返回执行信息
	 */
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}

	/**
	 * 执行状态
	 */
	public String getExcuteStatus() {
		return excuteStatus;
	}

	/**
	 * 执行状态
	 */
	public void setExcuteStatus(String excuteStatus) {
		this.excuteStatus = excuteStatus;
	}

	/**
	 * 实际开始日期
	 */
	public String getStartDate() {
		return startDate;
	}

	/**
	 * 实际开始日期
	 */
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	/**
	 * 实际开始时间
	 */
	public String getStartTime() {
		return startTime;
	}
	/**
	 * 实际开始时间
	 */
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	
	public void setStartDateAndTimeByNow(){
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
		this.setStartDate(dateFormat.format(date));
		this.setStartTime(timeFormat.format(date));
	}

	/**
	 * 实际完成日期
	 */
	public String getEndDate() {
		return endDate;
	}

	/**
	 * 实际完成日期
	 */
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	/**
	 * 实际完成时间
	 */
	public String getEndTime() {
		return endTime;
	}

	/**
	 * 实际完成时间
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	
	public void setEndDateAndTimeByNow(){
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
		this.setEndDate(dateFormat.format(date));
		this.setEndTime(timeFormat.format(date));
	}

	/**
	 * 操作人
	 */
	public String getExcute() {
		return excute;
	}

	/**
	 * 操作人
	 */
	public void setExcute(String excute) {
		this.excute = excute;
	}

	/**
	 * 审核人
	 */
	public String getVerify() {
		return verify;
	}

	/**
	 * 审核人
	 */
	public void setVerify(String verify) {
		this.verify = verify;
	}
	
	@Override
	public String toString() {
		StringBuffer result = new StringBuffer();
		
		result.append("JobDetailteps["+this.getJobCode()+"].data{");
		result.append("stepSeq : "+this.getStepSeq());
		result.append(" , stepDecribe : "+this.getStepDecribe());
		result.append(" , releaseStep : "+this.getReleaseStep());
		result.append(" , backingStep : "+this.getBackingStep());
		result.append(" , errorMessage : "+this.getErrorMessage());
		result.append(" , excuteStatus : "+this.getExcuteStatus());
		result.append(" , startDate : "+this.getStartDate());
		result.append(" , startTime : "+this.getStartTime());
		result.append(" , endDate : "+this.getEndDate());
		result.append(" , endTime : "+this.getEndTime());
		result.append(" , excute : "+this.getExcute());
		result.append(" , verify : "+this.getVerify());
		
		return result.toString();
	}
}
